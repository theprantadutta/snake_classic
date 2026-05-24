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

    if (kDebugMode) {
      AppLogger.network('SyncEngine initialized');
    }
  }

  /// Run the first-sign-in flow: if this device has never seen a
  /// sign-in before (fresh install OR reinstall), attempt to pull
  /// the user's cloud snapshot, wipe local state, and apply the
  /// snapshot. Subsequent sign-ins on the same install short-circuit.
  ///
  /// Order is "pull first, wipe second" so a network failure can't
  /// wipe local data before we have a replacement.
  Future<void> maybeRunFirstSignInPull(String userId) async {
    if (_db == null || _syncDao == null) return;
    if (!_api.isAuthenticated) return;
    if (!_connectivity.isOnline) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_hasEverSignedInPrefsKey) == true) {
      // Normal subsequent sign-in. Local data stays put; the outbox
      // drain handles any pending writes the usual way.
      return;
    }

    if (kDebugMode) {
      AppLogger.network('SyncEngine: first-sign-in flow for $userId');
    }

    Map<String, dynamic>? snapshot;
    try {
      snapshot = await _api.pullSyncSnapshot();
    } catch (e) {
      // Hard error from the network layer (timeout, DNS, …). Bail
      // without setting the flag so the next launch retries.
      AppLogger.error('SyncEngine: pull threw, deferring first-sign-in', e);
      return;
    }

    if (snapshot == null) {
      // Backend has no data for this user OR the endpoint returned
      // null. Treat as "fresh user" — leave local alone (the user's
      // pre-signin play is preserved) and let the outbox drain push
      // it up. Flag stays set to true going forward.
      await prefs.setBool(_hasEverSignedInPrefsKey, true);
      if (kDebugMode) {
        AppLogger.network('SyncEngine: fresh-user path, preserving local');
      }
      return;
    }

    // Cloud has data → cloud wins. Wipe local + apply snapshot in a
    // single transaction and drop the outbox so we don't echo the
    // pull straight back as a push.
    try {
      await _db!.clearAllData();
      await _applyCloudSnapshot(snapshot);
      await _syncDao!.clearSyncQueue();
      await prefs.setBool(_hasEverSignedInPrefsKey, true);
      if (kDebugMode) {
        AppLogger.network('SyncEngine: first-sign-in restore complete');
      }
    } catch (e) {
      AppLogger.error('SyncEngine: snapshot apply failed', e);
      // Don't set the flag — next launch retries the whole flow.
    }
  }

  /// Schedule a drain after the debounce window. Pass `immediate`
  /// to skip the debounce (e.g. on connectivity restore).
  void _scheduleDrain({bool immediate = false}) {
    _debounceTimer?.cancel();
    if (immediate) {
      _drain();
    } else {
      _debounceTimer = Timer(_debounce, _drain);
    }
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
        if (kDebugMode) {
          AppLogger.network('SyncEngine: synced $dataType x${items.length}');
        }
        break;

      case _DispatchResult.notReady:
        // Leave items pending; will retry on next drain.
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
              final balance = await _storeDao!.getCoinBalance();
              return {
                'balance': balance,
                'updated_at': DateTime.now().toUtc().toIso8601String(),
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
          // outbox references, read their current state from Drift,
          // send as a batch.
          final ids = _extractIds(items, prefix: 'achievement:');
          if (ids.isEmpty) return _DispatchResult.success;
          final rows = <Map<String, dynamic>>[];
          for (final id in ids) {
            final row = await _gameDao!.getAchievementById(id);
            if (row != null) rows.add(_achievementToPayload(row));
          }
          if (rows.isEmpty) return _DispatchResult.success;
          final result = await _api.syncAchievements(rows);
          return result == null ? _DispatchResult.notReady : _DispatchResult.success;

        case SyncDataType.battlePass:
          final ids = _extractIds(items, prefix: 'battle_pass:');
          if (ids.isEmpty) return _DispatchResult.success;
          final rows = <Map<String, dynamic>>[];
          for (final seasonId in ids) {
            final row = await _storeDao!.getBattlePass(seasonId);
            if (row != null) rows.add(_battlePassToPayload(row));
          }
          if (rows.isEmpty) return _DispatchResult.success;
          final result = await _api.syncBattlePass(rows);
          return result == null ? _DispatchResult.notReady : _DispatchResult.success;

        case SyncDataType.coinTransaction:
          // Event-typed: payload was frozen at outbox-write time.
          final payloads = _extractPayloads(items);
          final result = await _api.syncCoinTransactions(payloads);
          return result == null ? _DispatchResult.notReady : _DispatchResult.success;

        case SyncDataType.unlockedItem:
          final payloads = _extractPayloads(items);
          final result = await _api.syncUnlockedItems(payloads);
          return result == null ? _DispatchResult.notReady : _DispatchResult.success;

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
          final result = await _api.syncDailyChallengeClaims(rows);
          return result == null ? _DispatchResult.notReady : _DispatchResult.success;

        default:
          // Unknown outbox type — shouldn't happen if SyncDataType is
          // the source of truth. Drop silently so the queue doesn't
          // grow unbounded.
          if (kDebugMode) {
            AppLogger.warning('SyncEngine: unknown outbox dataType $dataType');
          }
          return _DispatchResult.success;
      }
    } catch (e) {
      AppLogger.error('SyncEngine dispatch ($dataType) errored', e);
      return _DispatchResult.failed;
    }
  }

  Future<_DispatchResult> _dispatchSnapshot({
    required Future<Map<String, dynamic>?> Function() read,
    required Future<Map<String, dynamic>?> Function(Map<String, dynamic>) send,
  }) async {
    final payload = await read();
    if (payload == null) return _DispatchResult.success; // nothing to send
    final result = await send(payload);
    return result == null ? _DispatchResult.notReady : _DispatchResult.success;
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
        'claimed_rewards': jsonDecode(r.claimedRewards),
        'season_start_date': _utcIsoNullable(r.seasonStartDate),
        'season_end_date': _utcIsoNullable(r.seasonEndDate),
        'updated_at': _utcIso(r.updatedAt),
      };

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
      final transactions = snapshot['coin_transactions'];
      if (transactions is List) {
        for (final raw in transactions) {
          if (raw is! Map<String, dynamic>) continue;
          // Note: we re-insert via the bare table to skip outbox enqueue
          // AND the running-balance touch — backend already gave us
          // the authoritative balance separately.
          await _db!.into(_db!.coinTransactions).insert(
                CoinTransactionsCompanion.insert(
                  amount: raw['amount'] as int? ?? 0,
                  type: raw['type'] as String? ?? 'earned',
                  source: raw['source'] as String? ?? 'cloud',
                  description: Value(raw['description'] as String?),
                  createdAt: Value(_parseDate(raw['created_at']) ?? DateTime.now()),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }

      // ----- achievements -----
      final achievements = snapshot['achievements'];
      if (achievements is List) {
        for (final raw in achievements) {
          if (raw is! Map<String, dynamic>) continue;
          final id = raw['id'] as String?;
          if (id == null) continue;
          await _gameDao!.upsertAchievement(
            AchievementsCompanion(
              id: Value(id),
              // Backend doesn't echo name/description because the
              // catalog is client-seeded — leave them at whatever the
              // local seed already wrote.
              name: const Value.absent(),
              description: const Value.absent(),
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
          final rewards = raw['claimed_rewards'];
          await _storeDao!.saveBattlePass(
            BattlePassesCompanion(
              seasonId: Value(seasonId),
              currentTier: Value(raw['current_tier'] as int? ?? 0),
              currentXp: Value(raw['current_xp'] as int? ?? 0),
              xpForNextTier: Value(raw['xp_for_next_tier'] as int? ?? 100),
              isPremiumPass: Value(raw['is_premium_pass'] as bool? ?? false),
              claimedRewards: Value(rewards is List ? jsonEncode(rewards) : '[]'),
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
    _outboxWatcher = null;
    _connectivityWatcher = null;
    _debounceTimer = null;
    _periodicTimer = null;
  }
}
