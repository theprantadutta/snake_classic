import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/daily_challenge_hydration.dart';
import 'package:snake_classic/data/database/settlement_write.dart';
import 'package:snake_classic/services/daily_challenge_settlement_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Daily challenges service.
///
/// Source of truth (eventually): the backend generator. Until that's
/// wired up the in-memory list is empty — the screen just shows the
/// empty state.
///
/// Offline-first: both progress AND claims are written to Drift, which
/// enqueues a `dailyChallengeClaim` sync_outbox row in the same
/// transaction. So in-session progress survives an app-kill / offline
/// window, and the SyncEngine pushes the live snapshot (progress + claim
/// state) to the backend's UserDailyChallengeClaims mirror on the next
/// online tick. The in-memory list is the optimistic UI mirror that the
/// screen renders; the next backend refresh reconciles it.
class DailyChallengeService extends ChangeNotifier {
  static final DailyChallengeService _instance =
      DailyChallengeService._internal();
  factory DailyChallengeService() => _instance;
  DailyChallengeService._internal();

  final StorageService _storageService = StorageService();

  /// Applies server settlements exactly once. Built lazily so tests can run
  /// the service without a database.
  DailyChallengeSettlementServiceClient? _settlementsOverride;
  DailyChallengeSettlementServiceClient get _settlements =>
      _settlementsOverride ??= DailyChallengeSettlementServiceClient.forDatabase(
        _storageService.db,
        onApplied: (_) async {
          // Refresh from durable truth AFTER the commit, never before — a
          // rolled-back apply must not leave the UI showing coins that were
          // not banked.
          if (GetIt.I.isRegistered<CoinsCubit>()) {
            await GetIt.I<CoinsCubit>().reloadFromDrift();
          }
          if (GetIt.I.isRegistered<BattlePassCubit>()) {
            await GetIt.I<BattlePassCubit>().reloadFromDrift();
          }
        },
      );

  @visibleForTesting
  set settlementClientForTesting(DailyChallengeSettlementServiceClient client) =>
      _settlementsOverride = client;

  // Flat coin + XP bonus granted exactly once on the day the player
  // completes every daily challenge. Persisted as a synthetic
  // [DailyChallenge] row in Drift (id = 'all_complete_bonus_$YYYY-MM-DD')
  // so the existing dailyChallengeClaim sync push carries it to the
  // backend mirror automatically — no new outbox dataType needed.
  static const int allCompleteBonusCoins = 50;
  static const int allCompleteBonusXp = 100;

  List<DailyChallenge> _challenges = [];
  int _completedCount = 0;
  int _totalCount = 0;
  bool _allCompleted = false;
  bool _bonusClaimedToday = false;
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _lastLoadDate;

  List<DailyChallenge> get challenges => _challenges;
  int get completedCount => _completedCount;
  int get totalCount => _totalCount;
  bool get allCompleted => _allCompleted;
  int get bonusCoins => allCompleteBonusCoins;
  int get bonusXp => allCompleteBonusXp;
  bool get isBonusClaimed => _bonusClaimedToday;
  bool get isLoading => _isLoading;

  bool get hasUnclaimedRewards =>
      _challenges.any((c) => c.isCompleted && !c.claimedReward) ||
      (_allCompleted && !_bonusClaimedToday);

  int get unclaimedRewardsCount =>
      _challenges.where((c) => c.isCompleted && !c.claimedReward).length;

  /// Hydrate the in-memory list from Drift, which is the offline-durable
  /// source of truth for today's challenges.
  ///
  /// This used to be a no-op: the list was populated ONLY by a successful
  /// backend fetch, so on any launch where the server was unreachable the
  /// screen was empty — including for a challenge the player had already
  /// completed but not yet claimed, i.e. a reward they had earned and could
  /// no longer see. Drift held the row the whole time; nothing read it back.
  ///
  /// Read-only. Nothing here claims a reward, flips a claimed flag, or grants
  /// coins — it only decides what is visible. Claiming stays on its existing
  /// offline-first path (Drift write + `dailyChallengeClaim` outbox row in one
  /// transaction, keyed on the challenge id so retries settle once), so a
  /// challenge surfaced here can be claimed offline and the claim reaches the
  /// server on the next drain.
  Future<void> initialize() async {
    await hydrateFromLocal();

    // Settlements the server already owes this account are applied on the way
    // in — a reward claimed on another device, or one this device claimed
    // before it was killed, lands without the player doing anything.
    //
    // Unawaited: an offline start must not be held up by it, and a failure
    // leaves the intent exactly where it was.
    unawaited(refreshSettlements());
  }

  /// Load today's persisted rows into the in-memory list. Safe to call more
  /// than once; a later [setChallengesFromBackend] supersedes it.
  Future<void> hydrateFromLocal() async {
    try {
      final localById = await _loadTodaysLocalById();
      if (localById.isEmpty) return;

      _challenges = hydrateFromLocalRows(localById.values);
      _applyCounts();
      // Bonus state comes from the settlement ledger — what this device has
      // actually banked — not from the synthetic local row, which recorded an
      // intent the server may not have honoured yet.
      await _refreshBonusStateFromLedger();
      AppLogger.info(
        'DailyChallengeService hydrated ${_challenges.length} challenge(s) '
        'from Drift (${_challenges.where((c) => c.canClaim).length} claimable)',
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('DailyChallengeService: local hydration failed', e);
    }
  }

  void _applyCounts() {
    final counts = countsFor(_challenges);
    _completedCount = counts.completed;
    _totalCount = counts.total;
    _allCompleted = counts.allCompleted;
  }

  /// Fetch today's daily challenges from the backend and apply them
  /// to the in-memory list via [setChallengesFromBackend]. When the
  /// request fails (offline / 5xx) the in-memory list is left as-is
  /// — the screen continues to show whatever the previous successful
  /// refresh produced, or an empty state on a first-launch offline.
  Future<void> refreshChallenges() async {
    if (!ApiService().isAuthenticated) return;
    _isLoading = true;
    notifyListeners();
    try {
      final body = await ApiService().getTodaysChallengesRemote();
      if (body == null) return;
      final raw = body['challenges'];
      if (raw is! List) {
        AppLogger.warning(
          'DailyChallengeService.refreshChallenges: missing challenges list',
        );
        return;
      }
      final parsed = <DailyChallenge>[];
      for (final entry in raw) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          parsed.add(DailyChallenge.fromJson(entry));
        } catch (e) {
          AppLogger.warning(
            'DailyChallengeService.refreshChallenges: skipping malformed entry: $e',
          );
        }
      }
      await setChallengesFromBackend(parsed);
    } catch (e) {
      AppLogger.error('DailyChallengeService.refreshChallenges errored', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Entry point for the backend wiring: feed the freshly-fetched
  /// challenge list in, and mark any whose claim is already recorded
  /// in Drift as claimed so the UI doesn't ask the user to claim
  /// twice across reinstalls.
  Future<void> setChallengesFromBackend(
    List<DailyChallenge> fromBackend,
  ) async {
    // Reconcile each backend challenge against its local Drift row, which is
    // the offline-durable source of truth. currentProgress is monotonic so we
    // take MAX (client-ahead offline gains win); isCompleted / claimedReward
    // are absorbing-true. Without the MAX-merge a refresh would clobber
    // progress the client earned offline but hasn't pushed yet.
    final localById = await _loadTodaysLocalById();

    _challenges = mergeBackendWithLocal(fromBackend, localById);
    _applyCounts();
    // The synthetic bonus row uses today's local-day-anchored id; if
    // it's already in Drift (this device claimed earlier OR another
    // device claimed and the cold-start sync pulled it in) the bonus
    // is locked.
    _bonusClaimedToday = localById[_todayBonusId()]?.rewardClaimed ?? false;
    _lastLoadDate = DateTime.now().toIso8601String().split('T')[0];

    // Persist the reconciled challenges to Drift so its rows reflect the
    // merged state (e.g. a backend-ahead value from another device lands
    // locally). enqueueSync: false — any client-ahead delta already carries
    // its own outbox row from updateProgress.
    for (final c in _challenges) {
      try {
        await _storageService.gameDao
            .upsertDailyChallenge(_toCompanion(c), enqueueSync: false);
      } catch (e) {
        AppLogger.error('DailyChallengeService: refresh persist failed', e);
      }
    }
    notifyListeners();
  }

  /// Today's local Drift challenge rows keyed by challenge id — the
  /// offline-durable source of truth used both to hydrate on a cold start and
  /// to reconcile a backend refresh. Adapted to [LocalChallengeRow] so the
  /// rules that consume them stay free of Drift.
  Future<Map<String, LocalChallengeRow>> _loadTodaysLocalById() async {
    try {
      final rows = await _storageService.gameDao.getTodaysChallenges();
      return {for (final r in rows) r.challengeId: _toLocalRow(r)};
    } catch (e) {
      AppLogger.error('Error loading local challenges', e);
      return const {};
    }
  }

  static LocalChallengeRow _toLocalRow(db.DailyChallenge row) {
    return LocalChallengeRow(
      challengeId: row.challengeId,
      challengeType: row.challengeType,
      title: row.title,
      description: row.description,
      currentProgress: row.currentProgress,
      targetProgress: row.targetProgress,
      rewardCoins: row.rewardCoins,
      isCompleted: row.isCompleted,
      rewardClaimed: row.rewardClaimed,
      requiredGameMode: row.requiredGameMode,
      xpReward: row.xpReward,
      difficulty: row.difficulty,
    );
  }

  /// Synthetic challenge id for today's all-complete bonus. Local-day
  /// anchored so a new day creates a new claim row even if the user
  /// completed yesterday's challenges. Stays stable across app launches
  /// within the same calendar day.
  static String _todayBonusId() => allCompleteBonusIdFor(DateTime.now());

  /// The server's key for today's set bonus: `bonus:yyyy-MM-dd` in UTC.
  ///
  /// UTC, not local. The catalog is generated on the UTC day boundary, so a
  /// local-midnight key would disagree with the server for every player who is
  /// not on UTC — which is exactly the timezone edge case the old synthetic
  /// local bonus id created.
  static String _todayBonusSettlementKey() {
    final utc = DateTime.now().toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return 'bonus:$y-$m-$d';
  }

  /// Pull any settlements the server owes this account and apply them.
  ///
  /// Safe to call from anywhere and at any time: it is idempotent, it has no
  /// connectivity preflight (the request is the authority), and a failure
  /// leaves the intent exactly where it was.
  Future<void> refreshSettlements() async {
    try {
      final applied = await _settlements.syncPending();
      if (applied > 0) {
        await _refreshBonusStateFromLedger();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Daily challenge settlement refresh failed', e);
    }
  }

  /// The all-complete bonus is a SERVER settlement now, not a local grant.
  ///
  /// This used to write a synthetic bonus row and credit coins and XP
  /// directly, as soon as the set was complete and one card had been
  /// collected. The old server handler paid it only once every card had been
  /// collected — so whether a player got it, and when, depended on which app
  /// version they were running and the order they tapped things in. Two
  /// devices could also each grant it.
  ///
  /// One rule lives on the server now: it settles once all three are
  /// COMPLETE, regardless of collection order, keyed on the day so it can
  /// only exist once. Nothing here credits it.
  Future<void> _refreshBonusStateFromLedger() async {
    try {
      final settled = await _storageService.db.settledDailyChallengeKeys();
      _bonusClaimedToday = settled.contains(_todayBonusSettlementKey());
    } catch (e) {
      AppLogger.error('Failed to read daily settlement ledger', e);
    }
  }

  /// Update progress for a specific challenge type. Offline-first: the
  /// in-memory list is updated optimistically and the changed challenges
  /// are persisted to Drift (which enqueues a sync_outbox row), so the
  /// gain survives an app-kill / offline window and reaches the backend
  /// mirror via the SyncEngine.
  Future<void> updateProgress(
    ChallengeType type,
    int value, {
    String? gameMode,
  }) async {
    if (value <= 0) return;
    final changed = _updateLocalProgress(type, value, gameMode: gameMode);
    notifyListeners();
    await _persistProgress(changed);
  }

  /// Batched per-game progress update.
  Future<void> updateProgressBatch(
    List<({ChallengeType type, int value, String? gameMode})> updates,
  ) async {
    if (updates.isEmpty) return;
    final changed = <String, DailyChallenge>{};
    for (final update in updates) {
      if (update.value <= 0) continue;
      for (final c in _updateLocalProgress(update.type, update.value,
          gameMode: update.gameMode)) {
        changed[c.id] = c; // last state wins if updates touch the same one
      }
    }
    notifyListeners();
    await _persistProgress(changed.values);
  }

  /// Applies the delta to matching in-memory challenges and returns the
  /// ones that actually changed, so the caller can persist exactly those.
  List<DailyChallenge> _updateLocalProgress(ChallengeType type, int value,
      {String? gameMode}) {
    final changed = <DailyChallenge>[];
    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];

      if (challenge.type != type) continue;
      if (challenge.isCompleted) continue;

      if (type == ChallengeType.gameMode &&
          challenge.requiredGameMode != null &&
          gameMode != null &&
          challenge.requiredGameMode!.toLowerCase() != gameMode.toLowerCase()) {
        continue;
      }

      int newProgress;
      if (type == ChallengeType.score || type == ChallengeType.survival) {
        // Take max value for score/survival — keep the user's actual peak
        // because "scored 230 against a 200 target" is a meaningful flex
        // worth preserving in the mirror.
        newProgress = value > challenge.currentProgress
            ? value
            : challenge.currentProgress;
      } else {
        // Cumulative challenges (games played, foods eaten, etc.) — cap at
        // target so the synced mirror doesn't end up with values like
        // "125 / 10" once the user keeps playing after the daily goal hits.
        // Overshoot has no semantic value here (challenge is done at first
        // crossing) and reads as a bug on the admin dashboard.
        final raw = challenge.currentProgress + value;
        newProgress =
            raw > challenge.targetValue ? challenge.targetValue : raw;
      }

      final isNowCompleted = newProgress >= challenge.targetValue;

      // Skip no-op updates (e.g. a lower score for a max-wins challenge) so
      // we don't churn the Drift row / sync outbox for nothing.
      if (newProgress == challenge.currentProgress &&
          isNowCompleted == challenge.isCompleted) {
        continue;
      }

      final updated = challenge.copyWith(
        currentProgress: newProgress,
        isCompleted: isNowCompleted,
      );
      _challenges[i] = updated;
      changed.add(updated);
    }

    _completedCount = _challenges.where((c) => c.isCompleted).length;
    _allCompleted = _completedCount == _totalCount && _totalCount > 0;
    return changed;
  }

  /// Persist changed challenges to Drift. upsertDailyChallenge enqueues a
  /// dailyChallengeClaim outbox row in the same transaction, so the
  /// SyncEngine drains it and pushes the snapshot when online. This is the
  /// offline-durable source of truth for in-progress challenges.
  Future<void> _persistProgress(Iterable<DailyChallenge> challenges) async {
    for (final c in challenges) {
      try {
        await _storageService.gameDao.upsertDailyChallenge(_toCompanion(c));
      } catch (e) {
        AppLogger.error(
          'DailyChallengeService: progress persist to Drift failed',
          e,
        );
      }
    }
  }

  /// Build a Drift companion from a challenge's current state. The day
  /// anchors (challengeDate / expiresAt) mirror [_persistClaim]; rewardClaimed
  /// and completedAt reflect the live challenge rather than being forced.
  db.DailyChallengesCompanion _toCompanion(DailyChallenge c) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return db.DailyChallengesCompanion(
      challengeId: Value(c.id),
      challengeType: Value(c.type.apiValue),
      title: Value(c.title),
      description: Value(c.description),
      currentProgress: Value(c.currentProgress),
      targetProgress: Value(c.targetValue),
      rewardCoins: Value(c.coinReward),
      isCompleted: Value(c.isCompleted),
      rewardClaimed: Value(c.claimedReward),
      // Persisted so a hydrated challenge still knows which mode counts —
      // without it a Classic-only goal would credit any game (null means
      // "any mode" on both sides).
      requiredGameMode: Value(c.requiredGameMode),
      xpReward: Value(c.xpReward),
      difficulty: Value(c.difficulty.name),
      challengeDate: Value(startOfDay),
      expiresAt: Value(endOfDay),
      completedAt: c.isCompleted ? Value(today) : const Value.absent(),
    );
  }

  /// Claim a single completed challenge. Writes the row to Drift (the
  /// only thing that *does* get persisted locally), credits the coin
  /// reward, and grants battle-pass XP.
  Future<bool> claimReward(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index < 0) return false;

    final challenge = _challenges[index];
    if (!challenge.canClaim) return false;

    // Records a durable INTENT and pays nothing.
    //
    // This used to flip a local flag and then credit coins and XP directly,
    // which meant the device decided it had earned something. Two devices
    // offline could each see the same challenge legitimately unclaimed and
    // each pay themselves, and a crash between the flag and the credit lost
    // the reward for good on that install.
    //
    // The intent is durable (Drift row + sync outbox), so it survives an
    // app-kill and reaches the server on the next drain. The server settles it
    // once per ACCOUNT, and DailyChallengeSettlementServiceClient applies that
    // settlement here exactly once. Until then the card reads as pending —
    // saved, not paid — which is the truth.
    final coins = await _settleClaim(challenge);
    if (coins == null) return false;

    _challenges[index] = challenge.copyWith(claimedReward: true);

    // Nudge the settlement path so a player who is online sees the reward land
    // moments later rather than on the next app start. Offline this fails
    // harmlessly and the intent waits.
    unawaited(refreshSettlements());

    notifyListeners();
    return true;
  }

  /// Claim every unclaimed-but-completed challenge in one go.
  Future<int> claimAllRewards() async {
    final claimable = _challenges.where((c) => c.canClaim).toList();
    if (claimable.isEmpty) return 0;

    int totalClaimed = 0;
    int settledCount = 0;
    for (final challenge in claimable) {
      final coins = await _settleClaim(challenge);
      if (coins == null) continue; // already claimed — grant nothing
      final index = _challenges.indexWhere((c) => c.id == challenge.id);
      if (index >= 0) {
        _challenges[index] = _challenges[index].copyWith(claimedReward: true);
      }
      totalClaimed += coins;
      settledCount++;
    }

    // Same as claimReward: intents only. The coins arrive when the server's
    // settlements do.
    if (settledCount > 0) {
      unawaited(refreshSettlements());
    }

    notifyListeners();
    return totalClaimed;
  }

  /// Settle a claim against Drift and return the coins to grant, or null if
  /// the claim was refused because the row was already claimed.
  ///
  /// The refusal is decided by [GameDao.claimChallengeReward], which does the
  /// check-and-set inside one transaction alongside the outbox enqueue. That
  /// makes "never pay the same reward twice" a property of the database
  /// rather than of the in-memory list — which matters now that the list is
  /// hydrated from Drift on every cold start and can be stale relative to a
  /// claim another code path just made.
  ///
  /// The coin amount comes back from the persisted row, not from the model,
  /// so an in-memory copy with a stale reward value can't over-pay.
  Future<int?> _settleClaim(DailyChallenge challenge) async {
    try {
      // The row must exist for the atomic claim to find it. It normally does
      // (hydration, refresh, and progress writes all persist), but a
      // challenge claimed in the same breath as its first appearance would
      // otherwise be refused for the wrong reason.
      //
      // Insert ONLY when genuinely absent. An unconditional upsert here would
      // write this in-memory copy's `rewardClaimed: false` over a row that is
      // already claimed, and the atomic gate below would then happily pay out
      // a second time — reintroducing the exact bug it exists to prevent.
      final existing =
          await _storageService.gameDao.getChallengeById(challenge.id);
      if (existing == null) {
        await _storageService.gameDao
            .upsertDailyChallenge(_toCompanion(challenge), enqueueSync: false);
      }
      final coins =
          await _storageService.gameDao.claimChallengeReward(challenge.id);
      if (coins <= 0) {
        AppLogger.info(
          'Daily challenge ${challenge.id} was already claimed (Drift gate) '
          '— granting nothing',
        );
        return null;
      }
      return coins;
    } catch (e) {
      AppLogger.error('Error settling daily challenge claim', e);
      return null;
    }
  }

  // _grantBattlePassXp is gone. Per-challenge XP was granted here the moment
  // a card was collected, alongside the coins; both are settlement effects
  // now and are applied together, in one transaction, from what the server
  // says is owed.

  /// Legacy entry point. In the offline-first build "sync" = re-fetch
  /// from the backend, so this is a thin alias for [refreshChallenges].
  Future<void> syncWithBackend() async {
    await refreshChallenges();
  }

  /// True when the in-memory snapshot is stale and the screen should
  /// kick a refresh.
  bool get needsRefresh {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _lastLoadDate != today || _challenges.isEmpty;
  }

  DailyChallenge? getChallengeById(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear in-memory state. Doesn't touch Drift — claimed rows are
  /// historical and stay.
  Future<void> clearCache() async {
    _challenges = [];
    _completedCount = 0;
    _totalCount = 0;
    _allCompleted = false;
    _bonusClaimedToday = false;
    _lastLoadDate = null;
    notifyListeners();
  }
}
