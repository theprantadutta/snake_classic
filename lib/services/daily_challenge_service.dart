import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Daily challenges service.
///
/// Source of truth (eventually): the backend generator. Until that's
/// wired up the in-memory list is empty — the screen just shows the
/// empty state.
///
/// Drift is **claim-only**: we never persist a challenge until the
/// user actually claims its reward. That way the Drift table only
/// holds rows the user cared enough about to collect, and there's no
/// drift between a stale local copy and whatever the backend feeds us
/// later. Progress accumulated in-memory during a session is lost on
/// app close — that's fine, it's just optimistic UI.
class DailyChallengeService extends ChangeNotifier {
  static final DailyChallengeService _instance =
      DailyChallengeService._internal();
  factory DailyChallengeService() => _instance;
  DailyChallengeService._internal();

  final StorageService _storageService = StorageService();

  List<DailyChallenge> _challenges = [];
  int _completedCount = 0;
  int _totalCount = 0;
  bool _allCompleted = false;
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _lastLoadDate;

  List<DailyChallenge> get challenges => _challenges;
  int get completedCount => _completedCount;
  int get totalCount => _totalCount;
  bool get allCompleted => _allCompleted;
  int get bonusCoins => 0;
  bool get isLoading => _isLoading;

  bool get hasUnclaimedRewards =>
      _challenges.any((c) => c.isCompleted && !c.claimedReward);

  int get unclaimedRewardsCount =>
      _challenges.where((c) => c.isCompleted && !c.claimedReward).length;

  Future<void> initialize() async {
    // Nothing to load locally — challenges arrive from the backend
    // call we haven't wired yet. Claimed rows live in Drift but we
    // don't surface them on the daily-challenges screen because the
    // screen wants the full *today's* catalog, not the user's history.
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
    final claimedIds = await _loadClaimedIdsForToday();

    _challenges = [
      for (final c in fromBackend)
        if (claimedIds.contains(c.id))
          c.copyWith(isCompleted: true, claimedReward: true)
        else
          c,
    ];
    _totalCount = _challenges.length;
    _completedCount = _challenges.where((c) => c.isCompleted).length;
    _allCompleted = _completedCount == _totalCount && _totalCount > 0;
    _lastLoadDate = DateTime.now().toIso8601String().split('T')[0];
    notifyListeners();
  }

  Future<Set<String>> _loadClaimedIdsForToday() async {
    try {
      final rows = await _storageService.gameDao.getTodaysChallenges();
      return rows
          .where((r) => r.rewardClaimed)
          .map((r) => r.challengeId)
          .toSet();
    } catch (e) {
      AppLogger.error('Error loading claimed challenge ids', e);
      return const {};
    }
  }

  /// Update progress for a specific challenge type. In-memory only —
  /// the buffer is never persisted because the backend authoritatively
  /// tracks per-user progress and we don't want a stale local copy.
  Future<void> updateProgress(
    ChallengeType type,
    int value, {
    String? gameMode,
  }) async {
    if (value <= 0) return;
    _updateLocalProgress(type, value, gameMode: gameMode);
    notifyListeners();
  }

  /// Batched per-game progress update.
  Future<void> updateProgressBatch(
    List<({ChallengeType type, int value, String? gameMode})> updates,
  ) async {
    if (updates.isEmpty) return;
    for (final update in updates) {
      if (update.value <= 0) continue;
      _updateLocalProgress(update.type, update.value, gameMode: update.gameMode);
    }
    notifyListeners();
  }

  void _updateLocalProgress(ChallengeType type, int value, {String? gameMode}) {
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

      _challenges[i] = challenge.copyWith(
        currentProgress: newProgress,
        isCompleted: isNowCompleted,
      );
    }

    _completedCount = _challenges.where((c) => c.isCompleted).length;
    _allCompleted = _completedCount == _totalCount && _totalCount > 0;
  }

  /// Claim a single completed challenge. Writes the row to Drift (the
  /// only thing that *does* get persisted locally), credits the coin
  /// reward, and grants battle-pass XP.
  Future<bool> claimReward(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index < 0) return false;

    final challenge = _challenges[index];
    if (!challenge.isCompleted || challenge.claimedReward) return false;

    _challenges[index] = challenge.copyWith(claimedReward: true);
    await _persistClaim(_challenges[index]);

    if (challenge.coinReward > 0 && GetIt.I.isRegistered<CoinsCubit>()) {
      await GetIt.I<CoinsCubit>().earnCoins(
        CoinEarningSource.dailyChallenge,
        customAmount: challenge.coinReward,
        itemName: challenge.title,
      );
    }

    _grantBattlePassXp(['daily_challenge']);

    notifyListeners();
    return true;
  }

  /// Claim every unclaimed-but-completed challenge in one go.
  Future<int> claimAllRewards() async {
    final claimable = _challenges.where((c) => c.canClaim).toList();
    if (claimable.isEmpty) return 0;

    int totalClaimed = 0;
    for (final challenge in claimable) {
      final index = _challenges.indexWhere((c) => c.id == challenge.id);
      if (index < 0) continue;
      _challenges[index] = challenge.copyWith(claimedReward: true);
      await _persistClaim(_challenges[index]);
      totalClaimed += challenge.coinReward;
    }

    if (totalClaimed > 0 && GetIt.I.isRegistered<CoinsCubit>()) {
      await GetIt.I<CoinsCubit>().earnCoins(
        CoinEarningSource.dailyChallenge,
        customAmount: totalClaimed,
        itemName: 'Daily challenges',
      );
    }

    _grantBattlePassXp(
      List<String>.filled(claimable.length, 'daily_challenge'),
    );

    notifyListeners();
    return totalClaimed;
  }

  Future<void> _persistClaim(DailyChallenge challenge) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      await _storageService.gameDao.upsertDailyChallenge(
        db.DailyChallengesCompanion(
          challengeId: Value(challenge.id),
          challengeType: Value(challenge.type.apiValue),
          title: Value(challenge.title),
          description: Value(challenge.description),
          currentProgress: Value(challenge.currentProgress),
          targetProgress: Value(challenge.targetValue),
          rewardCoins: Value(challenge.coinReward),
          isCompleted: Value(challenge.isCompleted),
          rewardClaimed: const Value(true),
          challengeDate: Value(startOfDay),
          expiresAt: Value(endOfDay),
          completedAt: Value(today),
        ),
      );
    } catch (e) {
      AppLogger.error('Error persisting claimed challenge to Drift', e);
    }
  }

  /// Buffer + flush battle-pass XP for one or more claim sources.
  /// Fire-and-forget: failure here must not roll back the user-visible claim.
  void _grantBattlePassXp(List<String> sources) {
    if (sources.isEmpty) return;
    if (!GetIt.I.isRegistered<BattlePassCubit>()) return;
    final cubit = GetIt.I<BattlePassCubit>();
    for (final source in sources) {
      final xp = BattlePassXpSource.getXpForAction(source);
      if (xp > 0) cubit.bufferXP(xp, source: source);
    }
    cubit.flushXP();
  }

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
    _lastLoadDate = null;
    notifyListeners();
  }
}
