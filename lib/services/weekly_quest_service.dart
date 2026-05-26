import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/models/daily_challenge.dart' show ChallengeDifficulty;
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/weekly_quest.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Weekly quests service.
///
/// Source of truth: the backend (catalog generated weekly via the Hangfire
/// `generate-weekly-quests` job, progress via `/weekly-quests/progress`).
/// Drift mirrors only ROWS THE USER ACTUALLY INTERACTED WITH — at minimum
/// the quests they've claimed — so the screen state survives reinstall
/// and the SyncEngine has something to push to the backend's
/// UserWeeklyQuestClaim table.
///
/// Modelled tightly on [DailyChallengeService] — same shape, same lifecycle,
/// same Drift + sync queue choreography.
class WeeklyQuestService extends ChangeNotifier {
  static final WeeklyQuestService _instance = WeeklyQuestService._internal();
  factory WeeklyQuestService() => _instance;
  WeeklyQuestService._internal();

  final StorageService _storageService = StorageService();

  List<WeeklyQuest> _quests = [];
  bool _isLoading = false;
  DateTime? _lastSuccessfulRefresh;

  List<WeeklyQuest> get quests => _quests;
  bool get isLoading => _isLoading;

  int get completedCount => _quests.where((q) => q.isCompleted).length;
  int get claimableCount => _quests.where((q) => q.canClaim).length;
  bool get hasUnclaimedRewards =>
      _quests.any((q) => q.isCompleted && !q.claimedReward);

  /// True when the cached quest list is older than 12h. The screen uses
  /// this to hint at a stale state without forcing a blocking refresh.
  bool get isStale {
    final last = _lastSuccessfulRefresh;
    if (last == null) return true;
    return DateTime.now().difference(last) > const Duration(hours: 12);
  }

  /// Idempotent. Re-hydrates from Drift and triggers a background refresh
  /// from the backend if the user is authenticated. Safe to call from
  /// build() — only loads if not already loaded.
  Future<void> initialize() async {
    if (_quests.isNotEmpty) {
      // Already hydrated — let a manual refresh handle staleness.
      return;
    }
    await _hydrateFromDrift();
    if (ApiService().isAuthenticated) {
      // Fire-and-forget — never block UI on the network round-trip.
      unawaited(refresh());
    }
  }

  /// Pull-to-refresh entry point. Fetches the current week's quests from
  /// the backend, persists them to Drift (without enqueuing sync rows
  /// — these came FROM the backend), and rebuilds the in-memory list.
  /// Failures leave the previous list in place so offline doesn't blank
  /// the screen.
  Future<void> refresh() async {
    if (!ApiService().isAuthenticated) return;
    _isLoading = true;
    notifyListeners();
    try {
      final body = await ApiService().getCurrentWeeklyQuestsRemote();
      if (body == null) return;
      final raw = body['quests'] ?? body['weekly_quests'] ?? body['data'];
      if (raw is! List) {
        AppLogger.warning(
          'WeeklyQuestService.refresh: missing quests list in response',
        );
        return;
      }

      final parsed = <WeeklyQuest>[];
      for (final entry in raw) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          parsed.add(WeeklyQuest.fromJson(entry));
        } catch (e) {
          AppLogger.warning(
            'WeeklyQuestService.refresh: skipping malformed entry: $e',
          );
        }
      }

      // Merge in the claimed bit from Drift — the backend's
      // /weekly-quests/current endpoint may return canonical state, but
      // if the client claimed offline since the last server sync, the
      // local Drift row is the more recent authority for that field.
      final claimedIds = await _loadClaimedIds();
      _quests = [
        for (final q in parsed)
          if (claimedIds.contains(q.id))
            q.copyWith(isCompleted: true, claimedReward: true)
          else
            q,
      ];

      // Persist freshly-fetched quests to Drift so the next cold-start
      // can hydrate from cache without a network round-trip. Don't
      // enqueue sync — these came FROM the backend.
      for (final q in _quests) {
        await _storageService.gameDao.upsertWeeklyQuest(
          _toCompanion(q),
          enqueueSync: false,
        );
      }

      _lastSuccessfulRefresh = DateTime.now();
    } catch (e) {
      AppLogger.error('WeeklyQuestService.refresh errored', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Set<String>> _loadClaimedIds() async {
    try {
      final rows = await _storageService.gameDao.getAllWeeklyQuests();
      return rows
          .where((r) => r.claimedReward)
          .map((r) => r.questId)
          .toSet();
    } catch (e) {
      AppLogger.error('WeeklyQuestService: error loading claimed ids', e);
      return const {};
    }
  }

  Future<void> _hydrateFromDrift() async {
    try {
      final rows = await _storageService.gameDao
          .getWeeklyQuestsForWeek(reference: DateTime.now());
      _quests = rows.map(_fromRow).toList();
      notifyListeners();
    } catch (e) {
      AppLogger.error('WeeklyQuestService: hydrate from Drift failed', e);
    }
  }

  /// Single-type progress increment — used when only one quest type can
  /// possibly match the event. Most game-end paths use the batch variant.
  Future<void> reportProgress({
    required WeeklyQuestType type,
    required int incrementBy,
    String? gameMode,
  }) async {
    if (incrementBy <= 0) return;
    await reportProgressBatch([
      (type: type, incrementBy: incrementBy, gameMode: gameMode),
    ]);
  }

  /// Batched per-game progress events. Fires the backend update +
  /// updates the in-memory list optimistically so the UI reflects the
  /// gain immediately without waiting for a refresh.
  Future<void> reportProgressBatch(
    List<({WeeklyQuestType type, int incrementBy, String? gameMode})> updates,
  ) async {
    final positive = updates.where((u) => u.incrementBy > 0).toList();
    if (positive.isEmpty) return;

    // Optimistic local update — apply the deltas to in-memory quests so
    // the user sees the bump right away. Refresh later will reconcile.
    for (final u in positive) {
      _applyLocalProgress(u.type, u.incrementBy, gameMode: u.gameMode);
    }
    notifyListeners();

    if (!ApiService().isAuthenticated) return;

    // Fire the backend batch — its handler is the authoritative writer
    // of canonical UserWeeklyQuest rows. We don't await an update of
    // _quests from the response; the next refresh will reconcile.
    try {
      await ApiService().updateWeeklyQuestProgressBatch(
        positive
            .map((u) => {
                  'type': u.type.apiValue,
                  'increment_by': u.incrementBy,
                  if (u.gameMode != null) 'game_mode': u.gameMode,
                })
            .toList(),
      );
    } catch (e) {
      AppLogger.error('WeeklyQuestService.reportProgressBatch errored', e);
    }
  }

  void _applyLocalProgress(WeeklyQuestType type, int incrementBy,
      {String? gameMode}) {
    for (int i = 0; i < _quests.length; i++) {
      final quest = _quests[i];
      if (quest.type != type) continue;
      if (quest.isCompleted) continue;
      if (type == WeeklyQuestType.gameMode &&
          quest.requiredGameMode != null &&
          gameMode != null &&
          quest.requiredGameMode!.toLowerCase() != gameMode.toLowerCase()) {
        continue;
      }

      int newProgress;
      if (type == WeeklyQuestType.score || type == WeeklyQuestType.survival) {
        // Max-wins semantics for high-water-mark quest types.
        newProgress = incrementBy > quest.currentProgress
            ? incrementBy
            : quest.currentProgress;
      } else {
        newProgress = quest.currentProgress + incrementBy;
      }
      final isNowCompleted = newProgress >= quest.targetValue;

      _quests[i] = quest.copyWith(
        currentProgress: newProgress,
        isCompleted: isNowCompleted,
      );
    }
  }

  /// Claim a completed quest. Writes the row to Drift (the sync engine
  /// drains it to the backend's UserWeeklyQuestClaim), credits coins +
  /// battle-pass XP via the in-app cubits, and returns true on success.
  Future<bool> claimReward(String questId) async {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index < 0) return false;

    final quest = _quests[index];
    if (!quest.isCompleted || quest.claimedReward) return false;

    final claimed = quest.copyWith(
      claimedReward: true,
      completedAt: quest.completedAt ?? DateTime.now(),
    );
    _quests[index] = claimed;
    await _persistClaim(claimed);

    // Optimistic credit — the backend's /weekly-quests/claim endpoint is
    // the authoritative source for the actual coin transfer, but we
    // credit locally so the UI doesn't lag waiting on the network.
    if (claimed.coinReward > 0 && GetIt.I.isRegistered<CoinsCubit>()) {
      await GetIt.I<CoinsCubit>().earnCoins(
        CoinEarningSource.dailyChallenge, // closest existing source
        customAmount: claimed.coinReward,
        itemName: claimed.title,
      );
    }

    _grantBattlePassXp(claimed.battlePassXpReward);

    // Server-side acknowledgement — fire-and-forget. If the server
    // disagrees (already claimed elsewhere, expired, etc.) the next
    // refresh will reconcile the local state.
    if (ApiService().isAuthenticated) {
      unawaited(ApiService().claimWeeklyQuestRewardRemote(claimed.id));
    }

    notifyListeners();
    return true;
  }

  Future<void> _persistClaim(WeeklyQuest quest) async {
    try {
      await _storageService.gameDao.upsertWeeklyQuest(
        _toCompanion(quest),
      );
    } catch (e) {
      AppLogger.error('Error persisting claimed weekly quest to Drift', e);
    }
  }

  void _grantBattlePassXp(int xp) {
    if (xp <= 0) return;
    if (!GetIt.I.isRegistered<BattlePassCubit>()) return;
    final cubit = GetIt.I<BattlePassCubit>();
    // bufferXP source is a free-form string used for analytics/audit;
    // mirrors the daily_challenge source string used elsewhere.
    cubit.bufferXP(xp, source: 'weekly_quest');
    cubit.flushXP();
  }

  // ---------------------------------------------------------------------------
  // Drift <-> model conversions
  // ---------------------------------------------------------------------------

  WeeklyQuest _fromRow(db.WeeklyQuest row) {
    return WeeklyQuest(
      id: row.questId,
      weekStartDate: row.weekStartDate,
      type: WeeklyQuestType.fromString(row.questType),
      difficulty: ChallengeDifficulty.easy, // Drift mirror doesn't track this
      title: row.title,
      description: row.description,
      targetValue: row.targetValue,
      currentProgress: row.currentProgress,
      isCompleted: row.isCompleted,
      claimedReward: row.claimedReward,
      coinReward: row.coinReward,
      battlePassXpReward: row.battlePassXpReward,
      completedAt: row.completedAt,
    );
  }

  db.WeeklyQuestsCompanion _toCompanion(WeeklyQuest q) {
    return db.WeeklyQuestsCompanion(
      questId: Value(q.id),
      questType: Value(q.type.apiValue),
      title: Value(q.title),
      description: Value(q.description),
      currentProgress: Value(q.currentProgress),
      targetValue: Value(q.targetValue),
      coinReward: Value(q.coinReward),
      battlePassXpReward: Value(q.battlePassXpReward),
      isCompleted: Value(q.isCompleted),
      claimedReward: Value(q.claimedReward),
      weekStartDate: Value(q.weekStartDate),
      completedAt: Value(q.completedAt),
    );
  }
}
