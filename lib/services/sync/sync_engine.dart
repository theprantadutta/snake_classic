import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/daos/game_dao.dart';
import 'package:snake_classic/data/daos/settings_dao.dart';
import 'package:snake_classic/data/daos/store_dao.dart';
import 'package:snake_classic/data/daos/sync_dao.dart';
import 'package:snake_classic/models/achievement.dart' as ach_model;
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Result of a single backend dispatch.
enum _DispatchResult {
  /// Backend accepted the batch; drop the items from the outbox.
  success,

  /// Backend isn't ready yet (e.g., stub returned null) — leave the
  /// items pending without bumping the retry counter, so when the
  /// endpoint lands the engine just picks them up.
  notReady,

  /// Backend explicitly rejected the batch. Bump retry; if max
  /// retries exceeded the items get marked failed.
  failed,
}

/// Outcome of [SyncEngine.maybeRunFirstSignInPull]. The UI uses this
/// to drive the "restoring your data…" loading modal during sign-in.
enum FirstSignInResult {
  /// Device has previously completed first-sign-in. No-op.
  alreadyDone,

  /// User just registered on the backend (is_new_user = true).
  /// No cloud data to restore; flag set so future sign-ins are
  /// normal sessions.
  brandNew,

  /// Returning user; backend snapshot pulled and applied to local
  /// Drift. Flag set.
  restored,

  /// Returning user but the pull failed or returned null. Flag
  /// stays unset so next launch retries the whole flow. UI should
  /// show a non-blocking warning and proceed with whatever local
  /// data exists (likely empty defaults).
  pullFailed,
}

/// UI-facing state stream emitted by the SyncEngine during the
/// first-sign-in flow. The global overlay subscribes to this and
/// renders a modal whenever the state is anything other than
/// [idle] / [done]. `welcoming` covers the brand-new-user path so
/// the user still sees a setup modal during their first sign-in
/// (even when there's nothing to pull).
enum FirstSignInState { idle, welcoming, pulling, applying, restored, failed, done }

/// Drains the local outbox (the `SyncQueue` Drift table) to the
/// backend. Owns the periodic + reactive (Drift-stream-driven)
/// drain loop and the first-sign-in pull flow.
///
/// Architecture:
///   * Every synced DAO mutation writes an outbox row in the same
///     Drift transaction (see [GameDao], [StoreDao], [SettingsDao]).
///   * This engine watches the outbox stream and drains in batches,
///     grouped by dataType, hitting one batch endpoint per group.
///   * Gated on `apiService.isAuthenticated && connectivity.isOnline`.
///   * `notReady` results (backend stub or 5xx) leave rows pending;
///     `failed` results bump retry with exponential backoff.
///
/// First-sign-in: when a particular user logs in on this device for
/// the first time, the engine pulls the cloud snapshot (if any) and
/// replaces local data, then clears the outbox so we don't echo
/// the pull back as a push.
class SyncEngine {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  final ApiService _api = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();

  AppDatabase? _db;
  SyncDao? _syncDao;
  GameDao? _gameDao;
  StoreDao? _storeDao;
  SettingsDao? _settingsDao;

  static const int _maxRetries = 5;
  static const Duration _debounce = Duration(seconds: 3);
  /// Hard ceiling on how far a burst of mutations can defer the drain.
  /// Without this, a sustained mutation rate >1 / 3s would keep
  /// resetting [_debounceTimer] indefinitely and starve the drain.
  static const Duration _debounceMaxDefer = Duration(seconds: 10);
  static const Duration _periodic = Duration(minutes: 2);

  /// Device-scoped flag — flips true the first time ANY user signs in
  /// successfully on this install. A subsequent reinstall (which
  /// wipes SharedPreferences) returns the flag to false and the
  /// first-sign-in pull runs again to restore cloud data.
  static const String _hasEverSignedInPrefsKey = 'sync_engine_has_ever_signed_in';

  bool _isDraining = false;
  StreamSubscription<List<SyncQueueData>>? _outboxWatcher;
  StreamSubscription<bool>? _connectivityWatcher;
  Timer? _debounceTimer;
  Timer? _periodicTimer;
  Timer? _failedDismissTimer;
  /// The earliest moment a debounce-deferred drain MUST run by, set
  /// the first time the debounce begins ticking. Rapid mutations can
  /// keep restarting [_debounceTimer] but can never push the actual
  /// drain past this deadline.
  DateTime? _debounceDeadline;

  /// How long to leave the "Couldn't restore" modal visible before
  /// auto-transitioning to [FirstSignInState.done] so the rest of the
  /// UI becomes interactive. The user can still retry on next launch.
  static const Duration _failedDismissDelay = Duration(seconds: 2);

  /// Signals that [initialize] has finished. Callers that race the
  /// init (notably [maybeRunFirstSignInPull] when sign-in fires
  /// during cold start) await this so they don't no-op on a not-
  /// yet-initialized engine.
  final Completer<void> _initialized = Completer<void>();

  /// Broadcast stream the UI subscribes to for the loading modal
  /// during first-sign-in restore.
  final StreamController<FirstSignInState> _firstSignInStateController =
      StreamController<FirstSignInState>.broadcast();
  Stream<FirstSignInState> get firstSignInStateStream =>
      _firstSignInStateController.stream;
  FirstSignInState _firstSignInState = FirstSignInState.idle;
  FirstSignInState get firstSignInState => _firstSignInState;

  void _emitFirstSignInState(FirstSignInState state) {
    _firstSignInState = state;
    _firstSignInStateController.add(state);
  }

  /// Emit [FirstSignInState.failed] and schedule a transition to
  /// [FirstSignInState.done] so the modal auto-dismisses. Without
  /// this, every pull-failure path left the overlay blocking the UI
  /// indefinitely (the user had to kill and relaunch the app).
  void _emitFailedAndScheduleDismiss() {
    _emitFirstSignInState(FirstSignInState.failed);
    _failedDismissTimer?.cancel();
    _failedDismissTimer = Timer(_failedDismissDelay, () {
      // Only auto-dismiss if we're still in `failed` — a later flow
      // (e.g., a retry on the same session) could have moved the
      // engine past this state already.
      if (_firstSignInState == FirstSignInState.failed) {
        _emitFirstSignInState(FirstSignInState.done);
      }
    });
  }

  /// One-shot init. Hook this from app boot after the database +
  /// connectivity + auth singletons are ready.
  Future<void> initialize(AppDatabase db) async {
    if (_db != null) return; // already initialized
    _db = db;
    _syncDao = db.syncDao;
    _gameDao = db.gameDao;
    _storeDao = db.storeDao;
    _settingsDao = db.settingsDao;

    // Drift's watch stream fires whenever a row gets added to the
    // outbox. We debounce 3s so a burst of mutations (e.g. a
    // game-end that touches stats + coins + achievements + battle
    // pass all at once) collapses into a single drain.
    _outboxWatcher = _syncDao!.watchPendingSyncItems().listen((_) {
      _scheduleDrain();
    });

    // Drain immediately on reconnect so the user doesn't have to
    // wait for the next periodic tick.
    _connectivityWatcher = _connectivity.onlineStatusStream.listen((isOnline) {
      if (isOnline) _scheduleDrain(immediate: true);
    });

    // Backup heartbeat — handles edge cases where a row was added
    // before the stream was attached, or a previous drain failed
    // silently.
    _periodicTimer = Timer.periodic(_periodic, (_) => _scheduleDrain());

    // Try once on init in case there's already a pending backlog.
    _scheduleDrain(immediate: true);

    if (!_initialized.isCompleted) _initialized.complete();

    if (kDebugMode) {
      AppLogger.network('SyncEngine initialized');
    }
  }

  /// Run the first-sign-in flow.
  ///
  /// [isNewUser] comes from the `/auth/firebase` response's
  /// `is_new_user` flag — true means the backend just minted this
  /// user record. We use it to disambiguate "brand new user, no
  /// cloud data" (legit empty snapshot) from "returning user but
  /// the pull failed for some reason" (transient — must retry).
  ///
  /// Behaviour:
  ///   * Flag already true → no-op, returns [alreadyDone].
  ///   * isNewUser == true → no cloud data exists by definition;
  ///     set flag + return [brandNew]. The outbox drain seeds cloud
  ///     with whatever the user has played pre-signin.
  ///   * Returning user + populated snapshot → wipe local + apply
  ///     + clear outbox + set flag. Returns [restored].
  ///   * Returning user + null/failed pull → flag stays unset so
  ///     the next launch retries. Returns [pullFailed].
  ///
  /// Order is "pull first, wipe second" so a transient pull failure
  /// can't wipe local data before we have a replacement.
  Future<FirstSignInResult> maybeRunFirstSignInPull({
    required String userId,
    required bool isNewUser,
  }) async {
    // Wait up to 8s for [initialize] to complete. The engine boots
    // from main.dart with `unawaited(...)`, so sign-in can race the
    // init. A timeout means something is very wrong (initialize
    // never resolved) — we treat that as a pull failure so the
    // flag stays unset and next launch retries.
    try {
      await _initialized.future.timeout(const Duration(seconds: 8));
    } catch (e) {
      AppLogger.error(
        'SyncEngine.maybeRunFirstSignInPull: initialize did not complete',
        e,
      );
      _emitFailedAndScheduleDismiss();
      return FirstSignInResult.pullFailed;
    }

    if (!_api.isAuthenticated) {
      AppLogger.warning(
        'SyncEngine.maybeRunFirstSignInPull: skipped, not authenticated',
      );
      return FirstSignInResult.pullFailed;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_hasEverSignedInPrefsKey) == true) {
      AppLogger.network(
        'SyncEngine.maybeRunFirstSignInPull: flag already set, no-op',
      );
      return FirstSignInResult.alreadyDone;
    }

    AppLogger.network(
      'SyncEngine.maybeRunFirstSignInPull: starting for $userId '
      '(isNewUser=$isNewUser)',
    );

    if (isNewUser) {
      // Backend just created the user — no cloud data exists.
      // Leave local alone (user's pre-signin play is preserved
      // and will sync up via the outbox drain). Set the flag.
      // Emit `welcoming` so the global overlay shows a setup modal
      // briefly — without this, brand-new users see zero feedback
      // during sign-in and assume the auth flow is broken.
      _emitFirstSignInState(FirstSignInState.welcoming);
      AppLogger.network(
        'SyncEngine: brand-new user (no cloud data to restore), '
        'showing welcome modal for 1.5s',
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      await prefs.setBool(_hasEverSignedInPrefsKey, true);
      _emitFirstSignInState(FirstSignInState.done);
      return FirstSignInResult.brandNew;
    }

    // Returning user — must successfully pull (or confirm null
    // snapshot from the backend) before we set the flag.
    // Track the pulling-state start time so we can hold the modal
    // visible for a minimum duration (the actual HTTP call often
    // completes faster than the user's eye can register).
    final pullingStart = DateTime.now();
    _emitFirstSignInState(FirstSignInState.pulling);
    if (!_connectivity.isOnline) {
      AppLogger.warning(
        'SyncEngine: returning user but offline — will retry next launch',
      );
      await _ensureMinModalTime(pullingStart);
      _emitFailedAndScheduleDismiss();
      return FirstSignInResult.pullFailed;
    }

    Map<String, dynamic>? snapshot;
    try {
      AppLogger.network('SyncEngine: GET /sync/pull …');
      snapshot = await _api.pullSyncSnapshot();
      if (snapshot == null) {
        AppLogger.warning(
          'SyncEngine: pull returned null — backend has no data for '
          'user $userId. (Either previous syncs never landed OR the '
          'endpoint returned HTTP non-2xx. Check backend logs + DB.)',
        );
      } else {
        AppLogger.network(
          'SyncEngine: pull returned snapshot with sections '
          '${snapshot.keys.toList()}',
        );
        // Dump per-section summary so the user can see what's actually
        // populated vs missing.
        for (final entry in snapshot.entries) {
          final v = entry.value;
          final summary = v == null
              ? 'null'
              : v is List
                  ? '${v.length} item(s)'
                  : v is Map
                      ? '${v.length} field(s)'
                      : v.toString();
          AppLogger.network('  • ${entry.key}: $summary');
        }
      }
    } catch (e) {
      AppLogger.error('SyncEngine: pull threw, will retry next launch', e);
      _emitFailedAndScheduleDismiss();
      return FirstSignInResult.pullFailed;
    }

    if (snapshot == null) {
      // Returning user but backend has no data for them. Could be:
      //   (a) Their previous syncs never actually landed.
      //   (b) Transient null parse from the API.
      // Either way: don't set the flag, retry next launch. If it
      // really is (a), the outbox drain on this session will seed
      // cloud, and on the next launch the pull will succeed.
      AppLogger.warning(
        'SyncEngine: returning user but pull returned null. '
        "Flag NOT set — will retry next launch. Local data preserved.",
      );
      await _ensureMinModalTime(pullingStart);
      _emitFailedAndScheduleDismiss();
      return FirstSignInResult.pullFailed;
    }

    // Cloud has data → apply each non-null section to local. We do
    // NOT clearAllData() — the backend auto-creates a
    // UserPremiumContent row for every authenticated user, so every
    // returning user's snapshot is non-null even before any
    // gameplay sync has landed. A blanket wipe-and-replace would
    // nuke stats/coins/achievements/etc. that were never in the
    // snapshot, leaving the user with zeros.
    //
    // The DAO apply helpers use insertOnConflictUpdate semantics, so
    // each section that IS in the snapshot replaces the matching
    // local row; sections that aren't in the snapshot leave local
    // alone. This is the right "cloud-wins-per-section" behaviour
    // for the offline-first build.
    _emitFirstSignInState(FirstSignInState.applying);
    try {
      await _applyCloudSnapshot(snapshot);
      await _syncDao!.clearSyncQueue();
      await prefs.setBool(_hasEverSignedInPrefsKey, true);
      await _ensureMinModalTime(pullingStart);
      // Show "Restore complete" briefly before dismissing.
      _emitFirstSignInState(FirstSignInState.restored);
      AppLogger.network(
        'SyncEngine: first-sign-in restore complete '
        '(sections: ${snapshot.keys.toList()})',
      );
      await Future.delayed(const Duration(milliseconds: 800));
      _emitFirstSignInState(FirstSignInState.done);
      return FirstSignInResult.restored;
    } catch (e) {
      AppLogger.error('SyncEngine: snapshot apply failed', e);
      // Don't set the flag — next launch retries the whole flow.
      await _ensureMinModalTime(pullingStart);
      _emitFailedAndScheduleDismiss();
      return FirstSignInResult.pullFailed;
    }
  }

  /// Hold the modal visible for a perceptible minimum so the user
  /// gets meaningful feedback even when the pull / apply completes
  /// in tens of milliseconds. Without this, the overlay flashes
  /// invisibly and the user can't tell the flow ran at all.
  Future<void> _ensureMinModalTime(DateTime startedAt) async {
    const minVisible = Duration(milliseconds: 1500);
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minVisible) {
      await Future.delayed(minVisible - elapsed);
    }
  }

  /// Schedule a drain after the debounce window. Pass `immediate`
  /// to skip the debounce (e.g. on connectivity restore).
  ///
  /// Sustained bursts can keep resetting the debounce; [_debounceMaxDefer]
  /// caps how far the actual drain can be pushed back from the FIRST
  /// scheduling so the queue isn't starved.
  void _scheduleDrain({bool immediate = false}) {
    _debounceTimer?.cancel();
    if (immediate) {
      _debounceDeadline = null;
      _drain();
      return;
    }

    final now = DateTime.now();
    _debounceDeadline ??= now.add(_debounceMaxDefer);
    final remainingDefer = _debounceDeadline!.difference(now);
    final delay =
        remainingDefer < _debounce ? remainingDefer : _debounce;

    _debounceTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () {
        _debounceDeadline = null;
        _drain();
      },
    );
  }

  Future<void> _drain() async {
    if (_isDraining) return;
    if (_db == null || _syncDao == null) return;
    if (!_api.isAuthenticated) return;
    if (!_connectivity.isOnline) return;

    _isDraining = true;
    try {
      final items = await _syncDao!.getPendingSyncItems();
      // Only handle outbox-owned dataTypes — the legacy
      // DataSyncService still owns 'preferences' and
      // 'fcm_token_register'.
      final mine = items.where(_isOwned).toList();
      if (mine.isEmpty) return;

      final groups = <String, List<SyncQueueData>>{};
      for (final item in mine) {
        groups.putIfAbsent(item.dataType, () => []).add(item);
      }

      for (final entry in groups.entries) {
        await _drainGroup(entry.key, entry.value);
      }
    } catch (e) {
      AppLogger.error('SyncEngine drain failed', e);
    } finally {
      _isDraining = false;
    }
  }

  Future<void> _drainGroup(String dataType, List<SyncQueueData> items) async {
    final result = await _dispatch(dataType, items);

    switch (result) {
      case _DispatchResult.success:
        for (final item in items) {
          await _syncDao!.removeSyncItem(item.id);
        }
        AppLogger.network(
          'SyncEngine: drained $dataType x${items.length} OK',
        );
        break;

      case _DispatchResult.notReady:
        // Leave items pending; will retry on next drain.
        AppLogger.warning(
          'SyncEngine: $dataType x${items.length} drain returned null — '
          'will retry. Check backend logs for the failed POST.',
        );
        break;

      case _DispatchResult.failed:
        for (final item in items) {
          await _syncDao!.incrementRetryCount(item.id);
          if (item.retryCount + 1 >= _maxRetries) {
            await _syncDao!.updateSyncItemStatus(
              item.id,
              2, // failed
              error: 'max retries exceeded',
            );
          }
        }
        break;
    }
  }

  Future<_DispatchResult> _dispatch(
    String dataType,
    List<SyncQueueData> items,
  ) async {
    try {
      switch (dataType) {
        case SyncDataType.settings:
          return _dispatchSnapshot(
            read: () async {
              final row = await _settingsDao!.getSettings();
              return row == null ? null : _settingsToPayload(row);
            },
            send: _api.syncSettings,
          );

        case SyncDataType.statistics:
          return _dispatchSnapshot(
            read: () async {
              final row = await _gameDao!.getStatistics();
              if (row == null) return null;
              return {
                'model_json': row.modelJson,
                'updated_at': row.updatedAt.toUtc().toIso8601String(),
              };
            },
            send: _api.syncStatistics,
          );

        case SyncDataType.coinBalance:
          return _dispatchSnapshot(
            read: () async {
              final row = await _storeDao!.getCoinBalanceRow();
              if (row == null) return null;
              return {
                'balance': row.balance,
                // Use the row's actual updatedAt — sending now() here
                // would break server-side LWW (every push would win).
                'updated_at': _utcIso(row.updatedAt),
              };
            },
            send: _api.syncCoinBalance,
          );

        case SyncDataType.premiumStatus:
          return _dispatchSnapshot(
            read: () async {
              final row = await _storeDao!.getPremiumStatus();
              return row == null ? null : _premiumToPayload(row);
            },
            send: _api.syncPremiumStatus,
          );

        case SyncDataType.achievement:
          // Per-row snapshot: collect the unique achievement ids the
          // outbox references, read their current state from Drift
          // in a single batched query, send as a batch.
          final ids = _extractIds(items, prefix: 'achievement:');
          if (ids.isEmpty) return _DispatchResult.success;
          final achievementRows =
              await _gameDao!.getAchievementsByIds(ids);
          if (achievementRows.isEmpty) return _DispatchResult.success;
          final payload =
              achievementRows.map(_achievementToPayload).toList();
          return _mapOutcome(await _api.syncAchievements(payload));

        case SyncDataType.battlePass:
          final ids = _extractIds(items, prefix: 'battle_pass:');
          if (ids.isEmpty) return _DispatchResult.success;
          final passes =
              await _storeDao!.getBattlePassesBySeasonIds(ids);
          if (passes.isEmpty) return _DispatchResult.success;
          final passPayload = passes.map(_battlePassToPayload).toList();
          return _mapOutcome(await _api.syncBattlePass(passPayload));

        case SyncDataType.coinTransaction:
          // Event-typed: payload was frozen at outbox-write time.
          final payloads = _extractPayloads(items);
          return _mapOutcome(await _api.syncCoinTransactions(payloads));

        case SyncDataType.unlockedItem:
          final payloads = _extractPayloads(items);
          return _mapOutcome(await _api.syncUnlockedItems(payloads));

        case SyncDataType.dailyChallengeClaim:
          // Per-row snapshot keyed by challenge id — read the current
          // Drift row to get the authoritative coin reward + claim
          // timestamp instead of the frozen outbox payload.
          final ids = _extractIds(items, prefix: 'daily_challenge_claim:');
          if (ids.isEmpty) return _DispatchResult.success;
          final all = await _gameDao!.getTodaysChallenges();
          final rows = all
              .where((c) => ids.contains(c.challengeId))
              .map(_dailyChallengeToPayload)
              .toList();
          if (rows.isEmpty) return _DispatchResult.success;
          return _mapOutcome(await _api.syncDailyChallengeClaims(rows));

        default:
          // Unknown outbox type — likely a new SyncDataType constant
          // wasn't wired into this switch. Treat as permanent failure
          // so retries bump the counter and the items eventually move
          // to the failed bucket instead of silently dropping (which
          // the previous `return success` did, masking the regression).
          AppLogger.warning('SyncEngine: unknown outbox dataType $dataType');
          return _DispatchResult.failed;
      }
    } catch (e) {
      AppLogger.error('SyncEngine dispatch ($dataType) errored', e);
      return _DispatchResult.failed;
    }
  }

  /// Map an ApiService [SyncOutcome] onto the engine's drain result.
  _DispatchResult _mapOutcome(SyncOutcome outcome) {
    switch (outcome.kind) {
      case SyncOutcomeKind.success:
        return _DispatchResult.success;
      case SyncOutcomeKind.transient:
        return _DispatchResult.notReady;
      case SyncOutcomeKind.permanent:
        return _DispatchResult.failed;
    }
  }

  Future<_DispatchResult> _dispatchSnapshot({
    required Future<Map<String, dynamic>?> Function() read,
    required Future<SyncOutcome> Function(Map<String, dynamic>) send,
  }) async {
    final payload = await read();
    if (payload == null) return _DispatchResult.success; // nothing to send
    return _mapOutcome(await send(payload));
  }

  Set<String> _extractIds(List<SyncQueueData> items, {required String prefix}) {
    final ids = <String>{};
    for (final item in items) {
      try {
        final decoded = jsonDecode(item.data) as Map<String, dynamic>;
        final entityKey = decoded['entityKey'] as String?;
        if (entityKey == null) continue;
        if (entityKey.startsWith(prefix)) {
          ids.add(entityKey.substring(prefix.length));
        }
      } catch (_) {
        // Skip malformed rows
      }
    }
    return ids;
  }

  List<Map<String, dynamic>> _extractPayloads(List<SyncQueueData> items) {
    final out = <Map<String, dynamic>>[];
    for (final item in items) {
      try {
        final decoded = jsonDecode(item.data) as Map<String, dynamic>;
        final payload = decoded['payload'];
        if (payload is Map<String, dynamic>) out.add(payload);
      } catch (_) {
        // Skip malformed rows
      }
    }
    return out;
  }

  bool _isOwned(SyncQueueData item) {
    switch (item.dataType) {
      case SyncDataType.settings:
      case SyncDataType.statistics:
      case SyncDataType.achievement:
      case SyncDataType.coinBalance:
      case SyncDataType.coinTransaction:
      case SyncDataType.premiumStatus:
      case SyncDataType.unlockedItem:
      case SyncDataType.battlePass:
      case SyncDataType.dailyChallengeClaim:
        return true;
      default:
        return false;
    }
  }

  // Backend uses JsonNamingPolicy.SnakeCaseLower so payloads have to
  // use snake_case keys — every name here mirrors the matching
  // SyncSettingsPayload / SyncAchievementPayload / etc. DTO record
  // property in dotnet land.
  //
  // All DateTimes serialized via `_utcIso` because Postgres + Npgsql
  // refuses `timestamp with time zone` writes for Unspecified-kind
  // values. Drift reads come back as Local; we coerce to UTC at the
  // wire boundary so the backend never sees a non-UTC timestamp.

  Map<String, dynamic> _settingsToPayload(GameSetting r) => {
        'theme_index': r.themeIndex,
        'sound_enabled': r.soundEnabled,
        'music_enabled': r.musicEnabled,
        'd_pad_enabled': r.dPadEnabled,
        'd_pad_position_index': r.dPadPositionIndex,
        'board_size_index': r.boardSizeIndex,
        'high_score': r.highScore,
        'crash_feedback_duration_seconds': r.crashFeedbackDurationSeconds,
        'trail_system_enabled': r.trailSystemEnabled,
        'screen_shake_enabled': r.screenShakeEnabled,
        'selected_skin_id': r.selectedSkinId,
        'selected_trail_id': r.selectedTrailId,
        'updated_at': _utcIso(r.updatedAt),
      };

  Map<String, dynamic> _achievementToPayload(Achievement r) => {
        'id': r.id,
        'current_progress': r.currentProgress,
        'target_progress': r.targetProgress,
        'is_unlocked': r.isUnlocked,
        'unlocked_at': _utcIsoNullable(r.unlockedAt),
        'reward_claimed': r.rewardClaimed,
        'updated_at': _utcIso(r.updatedAt),
      };

  Map<String, dynamic> _premiumToPayload(PremiumStatusData r) => {
        'is_premium_active': r.isPremiumActive,
        'premium_expiration_date': _utcIsoNullable(r.premiumExpirationDate),
        'is_on_trial': r.isOnTrial,
        'trial_start_date': _utcIsoNullable(r.trialStartDate),
        'trial_end_date': _utcIsoNullable(r.trialEndDate),
        'bronze_tournament_entries': r.bronzeTournamentEntries,
        'silver_tournament_entries': r.silverTournamentEntries,
        'gold_tournament_entries': r.goldTournamentEntries,
        'updated_at': _utcIso(r.updatedAt),
      };

  Map<String, dynamic> _battlePassToPayload(BattlePassesData r) => {
        'season_id': r.seasonId,
        'current_tier': r.currentTier,
        'current_xp': r.currentXp,
        'xp_for_next_tier': r.xpForNextTier,
        'is_premium_pass': r.isPremiumPass,
        // Wire schema is a flat List<int>; the local Drift column
        // stores `{"free": [...], "premium": [...]}` (see StoreDao).
        // Flatten via union+sort here. Cross-device restore loses the
        // free-vs-premium split — acceptable until the wire format is
        // updated to carry the structure.
        'claimed_rewards': _flattenClaimedRewards(r.claimedRewards),
        'season_start_date': _utcIsoNullable(r.seasonStartDate),
        'season_end_date': _utcIsoNullable(r.seasonEndDate),
        'updated_at': _utcIso(r.updatedAt),
      };

  /// Reduce the structured `{"free":[...], "premium":[...]}` Drift
  /// payload (or a legacy flat array) to the flat `List<int>` the
  /// backend expects.
  List<int> _flattenClaimedRewards(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final free = (decoded['free'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const <int>[];
        final premium = (decoded['premium'] as List?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const <int>[];
        final union = <int>{...free, ...premium}.toList()..sort();
        return union;
      }
      if (decoded is List) {
        return decoded.map((e) => (e as num).toInt()).toList()..sort();
      }
    } catch (_) {
      // Malformed payload — send empty rather than crashing the drain.
    }
    return const <int>[];
  }

  Map<String, dynamic> _dailyChallengeToPayload(DailyChallenge r) => {
        'challenge_id': r.challengeId,
        'challenge_type': r.challengeType,
        'title': r.title,
        'description': r.description,
        'current_progress': r.currentProgress,
        'target_progress': r.targetProgress,
        'reward_coins': r.rewardCoins,
        'is_completed': r.isCompleted,
        'reward_claimed': r.rewardClaimed,
        'challenge_date': _utcIso(r.challengeDate),
        'expires_at': _utcIso(r.expiresAt),
        'completed_at': _utcIsoNullable(r.completedAt),
        'updated_at': _utcIso(r.updatedAt),
      };

  /// Serialize a DateTime as a UTC ISO 8601 string with the trailing
  /// "Z" suffix — required by Postgres + Npgsql on the backend.
  String _utcIso(DateTime dt) => dt.toUtc().toIso8601String();

  String? _utcIsoNullable(DateTime? dt) => dt?.toUtc().toIso8601String();

  /// Apply a server snapshot to local Drift, suppressing outbox
  /// enqueues so the data doesn't echo back as a push. Wrapped in a
  /// single transaction — if any section throws, the whole apply
  /// rolls back so we never leave the DB in a half-restored state.
  ///
  /// Section keys mirror the backend SyncSnapshotDto record. Any
  /// missing / null section is skipped (the user has no cloud data
  /// of that kind yet).
  Future<void> _applyCloudSnapshot(Map<String, dynamic> snapshot) async {
    if (_db == null) return;

    await _db!.transaction(() async {
      // ----- settings -----
      final settings = snapshot['settings'];
      if (settings is Map<String, dynamic>) {
        await _settingsDao!.applySettingsSnapshot(
          GameSettingsCompanion(
            themeIndex: Value(settings['theme_index'] as int? ?? 0),
            soundEnabled: Value(settings['sound_enabled'] as bool? ?? true),
            musicEnabled: Value(settings['music_enabled'] as bool? ?? true),
            dPadEnabled: Value(settings['d_pad_enabled'] as bool? ?? false),
            dPadPositionIndex:
                Value(settings['d_pad_position_index'] as int? ?? 1),
            boardSizeIndex: Value(settings['board_size_index'] as int? ?? 1),
            highScore: Value(settings['high_score'] as int? ?? 0),
            crashFeedbackDurationSeconds: Value(
                settings['crash_feedback_duration_seconds'] as int? ?? 3),
            trailSystemEnabled:
                Value(settings['trail_system_enabled'] as bool? ?? false),
            screenShakeEnabled:
                Value(settings['screen_shake_enabled'] as bool? ?? false),
            selectedSkinId: Value(settings['selected_skin_id'] as String?),
            selectedTrailId: Value(settings['selected_trail_id'] as String?),
            lastUpdated: Value(_parseDate(settings['updated_at']) ?? DateTime.now()),
            updatedAt: Value(_parseDate(settings['updated_at']) ?? DateTime.now()),
          ),
        );
      }

      // ----- statistics -----
      final stats = snapshot['statistics'];
      if (stats is Map<String, dynamic>) {
        final modelJson = stats['model_json'] as String? ?? '{}';
        await _gameDao!.updateStatisticsFromJson(modelJson, enqueueSync: false);
      }

      // ----- coin balance -----
      final balance = snapshot['coin_balance'];
      if (balance is Map<String, dynamic>) {
        await _storeDao!.applyCoinBalanceSnapshot(
          balance: balance['balance'] as int? ?? 0,
          updatedAt: _parseDate(balance['updated_at']),
        );
      }

      // ----- coin transactions (event-typed, append-only) -----
      //
      // Re-insert via the bare table to skip outbox enqueue AND the
      // running-balance touch — backend already gave us the
      // authoritative balance separately.
      //
      // Dedup by (createdAt, amount, type, source) fingerprint: the
      // local table has an autoIncrement primary key, so
      // InsertMode.insertOrIgnore alone never catches conflicts. Today
      // the apply runs at most once per install (gated by the
      // `sync_engine_has_ever_signed_in` flag), but a future re-import
      // / admin tool / repeated apply would otherwise duplicate every
      // historical row on each run.
      final transactions = snapshot['coin_transactions'];
      if (transactions is List && transactions.isNotEmpty) {
        final existing = await _db!.select(_db!.coinTransactions).get();
        final fingerprints = <String>{};
        for (final row in existing) {
          fingerprints.add(_coinTxnFingerprint(
            row.createdAt,
            row.amount,
            row.type,
            row.source,
          ));
        }
        for (final raw in transactions) {
          if (raw is! Map<String, dynamic>) continue;
          final createdAt =
              _parseDate(raw['created_at']) ?? DateTime.now();
          final amount = raw['amount'] as int? ?? 0;
          final type = raw['type'] as String? ?? 'earned';
          final source = raw['source'] as String? ?? 'cloud';
          final fingerprint =
              _coinTxnFingerprint(createdAt, amount, type, source);
          if (!fingerprints.add(fingerprint)) continue; // duplicate
          await _db!.into(_db!.coinTransactions).insert(
                CoinTransactionsCompanion.insert(
                  amount: amount,
                  type: type,
                  source: source,
                  description: Value(raw['description'] as String?),
                  createdAt: Value(createdAt),
                ),
              );
        }
      }

      // ----- achievements -----
      // Backend doesn't echo name/description because the catalog is
      // client-seeded. If a local row already exists (post-seed) we leave
      // name/description as Value.absent() to preserve them. If the row
      // doesn't exist yet (reinstall — snapshot apply can race the
      // AchievementService seed running in parallel on the loading
      // screen), we look up the metadata from the local default
      // catalog so the insert satisfies the not-null columns.
      final achievements = snapshot['achievements'];
      if (achievements is List && achievements.isNotEmpty) {
        final defaultsById = {
          for (final a in ach_model.Achievement.getDefaultAchievements())
            a.id: a,
        };
        // Pre-fetch existing rows in a single query instead of doing
        // one Drift round-trip per snapshot entry. 50 achievements ×
        // per-call overhead adds up, even though each lookup is cheap.
        final existingRows = await _gameDao!.getAllAchievements();
        final existingById = {for (final r in existingRows) r.id: r};
        for (final raw in achievements) {
          if (raw is! Map<String, dynamic>) continue;
          final id = raw['id'] as String?;
          if (id == null) continue;

          final existing = existingById[id];
          final ach_model.Achievement? defaultEntry = defaultsById[id];

          Value<String> nameValue = const Value.absent();
          Value<String> descriptionValue = const Value.absent();
          Value<String> categoryValue = const Value.absent();
          Value<int> rewardCoinsValue = const Value.absent();
          Value<String> iconNameValue = const Value.absent();
          Value<bool> isSecretValue = const Value.absent();

          if (existing == null) {
            // Row doesn't exist locally — fill required columns from the
            // local default catalog. If a server-side achievement id has
            // no local default (shouldn't happen but defend), skip it
            // rather than crash the whole snapshot apply.
            if (defaultEntry == null) {
              AppLogger.network(
                'SyncEngine: skipping unknown achievement "$id" — '
                'no local default catalog entry',
              );
              continue;
            }
            nameValue = Value(defaultEntry.title);
            descriptionValue = Value(defaultEntry.description);
            categoryValue = Value(defaultEntry.type.name);
            rewardCoinsValue = Value(defaultEntry.coinReward);
            iconNameValue = Value(defaultEntry.icon.codePoint.toString());
            isSecretValue = const Value(false);
          }

          await _gameDao!.upsertAchievement(
            AchievementsCompanion(
              id: Value(id),
              name: nameValue,
              description: descriptionValue,
              category: categoryValue,
              rewardCoins: rewardCoinsValue,
              iconName: iconNameValue,
              isSecret: isSecretValue,
              currentProgress: Value(raw['current_progress'] as int? ?? 0),
              targetProgress: Value(raw['target_progress'] as int? ?? 1),
              isUnlocked: Value(raw['is_unlocked'] as bool? ?? false),
              unlockedAt: Value(_parseDate(raw['unlocked_at'])),
              rewardClaimed: Value(raw['reward_claimed'] as bool? ?? false),
              updatedAt:
                  Value(_parseDate(raw['updated_at']) ?? DateTime.now()),
            ),
            enqueueSync: false,
          );
        }
      }

      // ----- unlocked items -----
      final unlocked = snapshot['unlocked_items'];
      if (unlocked is List) {
        for (final raw in unlocked) {
          if (raw is! Map<String, dynamic>) continue;
          final itemId = raw['item_id'] as String?;
          final itemType = raw['item_type'] as String?;
          if (itemId == null || itemType == null) continue;
          await _storeDao!.unlockItem(
            itemId,
            itemType,
            unlockedBy: raw['unlocked_by'] as String?,
            enqueueSync: false,
          );
        }
      }

      // ----- battle pass (per-season) -----
      final battlePasses = snapshot['battle_passes'];
      if (battlePasses is List) {
        for (final raw in battlePasses) {
          if (raw is! Map<String, dynamic>) continue;
          final seasonId = raw['season_id'] as String?;
          if (seasonId == null) continue;
          // Wire payload is a flat List<int>; store under "free" in the
          // structured local format. The free-vs-premium split is lost
          // on restore (see [_flattenClaimedRewards] comment) — a user
          // who reinstalls may need to re-claim premium-side rewards.
          final wireRewards = raw['claimed_rewards'];
          final freeList = wireRewards is List
              ? wireRewards.map((e) => (e as num).toInt()).toList()
              : const <int>[];
          final claimedJson = jsonEncode({
            'free': freeList,
            'premium': <int>[],
          });
          await _storeDao!.saveBattlePass(
            BattlePassesCompanion(
              seasonId: Value(seasonId),
              currentTier: Value(raw['current_tier'] as int? ?? 0),
              currentXp: Value(raw['current_xp'] as int? ?? 0),
              xpForNextTier: Value(raw['xp_for_next_tier'] as int? ?? 100),
              isPremiumPass: Value(raw['is_premium_pass'] as bool? ?? false),
              claimedRewards: Value(claimedJson),
              seasonStartDate: Value(_parseDate(raw['season_start_date'])),
              seasonEndDate: Value(_parseDate(raw['season_end_date'])),
            ),
            enqueueSync: false,
          );
        }
      }

      // ----- premium status -----
      final premium = snapshot['premium_status'];
      if (premium is Map<String, dynamic>) {
        await _storeDao!.applyPremiumStatusSnapshot(
          PremiumStatusCompanion(
            isPremiumActive: Value(premium['is_premium_active'] as bool? ?? false),
            premiumExpirationDate:
                Value(_parseDate(premium['premium_expiration_date'])),
            isOnTrial: Value(premium['is_on_trial'] as bool? ?? false),
            trialStartDate: Value(_parseDate(premium['trial_start_date'])),
            trialEndDate: Value(_parseDate(premium['trial_end_date'])),
            bronzeTournamentEntries:
                Value(premium['bronze_tournament_entries'] as int? ?? 0),
            silverTournamentEntries:
                Value(premium['silver_tournament_entries'] as int? ?? 0),
            goldTournamentEntries:
                Value(premium['gold_tournament_entries'] as int? ?? 0),
          ),
        );
      }

      // ----- daily challenge claims -----
      final claims = snapshot['daily_challenge_claims'];
      if (claims is List) {
        for (final raw in claims) {
          if (raw is! Map<String, dynamic>) continue;
          final challengeId = raw['challenge_id'] as String?;
          if (challengeId == null) continue;
          await _gameDao!.upsertDailyChallenge(
            DailyChallengesCompanion(
              challengeId: Value(challengeId),
              challengeType: Value(raw['challenge_type'] as String? ?? ''),
              title: Value(raw['title'] as String? ?? ''),
              description: Value(raw['description'] as String? ?? ''),
              currentProgress: Value(raw['current_progress'] as int? ?? 0),
              targetProgress: Value(raw['target_progress'] as int? ?? 0),
              rewardCoins: Value(raw['reward_coins'] as int? ?? 0),
              isCompleted: Value(raw['is_completed'] as bool? ?? false),
              rewardClaimed: Value(raw['reward_claimed'] as bool? ?? false),
              challengeDate:
                  Value(_parseDate(raw['challenge_date']) ?? DateTime.now()),
              expiresAt: Value(_parseDate(raw['expires_at']) ??
                  DateTime.now().add(const Duration(days: 1))),
              completedAt: Value(_parseDate(raw['completed_at'])),
            ),
            enqueueSync: false,
          );
        }
      }
    });

    if (kDebugMode) {
      AppLogger.network('SyncEngine: snapshot apply committed');
    }
  }

  /// Stable identity for a coin-transaction row that doesn't depend
  /// on the local autoIncrement PK. Used by the snapshot apply to
  /// skip rows that already exist locally.
  String _coinTxnFingerprint(
    DateTime createdAt,
    int amount,
    String type,
    String source,
  ) =>
      '${createdAt.toUtc().toIso8601String()}|$amount|$type|$source';

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  /// Cleanup. Idempotent.
  Future<void> dispose() async {
    await _outboxWatcher?.cancel();
    await _connectivityWatcher?.cancel();
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _failedDismissTimer?.cancel();
    _outboxWatcher = null;
    _connectivityWatcher = null;
    _debounceTimer = null;
    _periodicTimer = null;
    _failedDismissTimer = null;
  }
}
