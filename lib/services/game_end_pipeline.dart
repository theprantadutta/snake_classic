import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:snake_classic/game/session/game_run_summary.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/weekly_quest.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/daily_challenge_service.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/weekly_quest_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';

/// The single post-game rewards/stats/achievements pipeline.
///
/// Both single-player ([GameCubit] via [runPostGame]) and multiplayer
/// ([MultiplayerCubit] via [recordMultiplayerMatch]/[creditMultiplayerRewards])
/// route their end-of-game choreography through here, so reward rules,
/// stat recording and sync ordering live in exactly one place.
///
/// The pipeline is stateless across runs: everything run-specific arrives in
/// a [GameRunSummary] (or explicit parameters), and coin grants are reported
/// back as return values so callers own their own "coins earned this game"
/// accounting and state emission.
class GameEndPipeline {
  GameEndPipeline({
    required this._statisticsService,
    required this._achievementService,
    required this._coinsCubit,
    required this._battlePassCubit,
    required this._dailyChallengeService,
    required this._weeklyQuestService,
    required this._progressionService,
    required this._appDataCache,
  });

  final StatisticsService _statisticsService;
  final AchievementService _achievementService;
  final CoinsCubit _coinsCubit;
  final BattlePassCubit _battlePassCubit;
  final DailyChallengeService _dailyChallengeService;
  final WeeklyQuestService _weeklyQuestService;
  final ProgressionService _progressionService;
  final AppDataCache _appDataCache;

  // ---------------------------------------------------------------------
  // Local (sync, fast) — runs BEFORE the game-over screen shows
  // ---------------------------------------------------------------------

  /// Filter-aware local achievement evaluation so offline play still reveals
  /// achievements at game-end. Per-game Score / Survival rows only fire when
  /// gameModeFilter (if set) matches the finished game. Per-mode games-count
  /// rows evaluate against GameStatistics.gameModeCount — projected forward
  /// by one since the stats update for THIS game runs later in [runPostGame].
  /// Special achievements (combo / snake length / no-wall etc.) are always
  /// client-only. Buffers battle-pass XP for every client-evaluated unlock.
  List<Achievement> evaluateLocalUnlocks(GameRunSummary summary) {
    const difficultyName = 'normal'; // mirrors the value sent in queueSync
    final projectedTotalGames =
        _statisticsService.statistics.totalGamesPlayed + 1;
    final projectedModeCounts =
        Map<String, int>.from(_statisticsService.statistics.gameModeCount);
    projectedModeCounts[summary.gameMode] =
        (projectedModeCounts[summary.gameMode] ?? 0) + 1;

    final scoreUnlocks = _achievementService.checkScoreAchievements(
      summary.score,
      gameMode: summary.gameMode,
      difficulty: difficultyName,
    );
    final survivalUnlocks = _achievementService.checkSurvivalAchievements(
      summary.durationSeconds,
      gameMode: summary.gameMode,
      difficulty: difficultyName,
    );
    final gamesUnlocks = _achievementService.checkGamePlayedAchievements(
      projectedTotalGames,
      gameModeCount: projectedModeCounts,
    );
    final specialUnlocks = _achievementService.checkSpecialAchievements(
      level: summary.level,
      hitWall: summary.hitWall,
      hitSelf: summary.hitSelf,
      foodTypesEaten: summary.foodTypesEaten,
      noWallGames: summary.consecutiveGamesWithoutWallHits,
      maxCombo: summary.maxCombo,
      snakeLength: summary.snakeLength,
      gameEndTime: DateTime.now(),
    );

    final allLocalUnlocks = [
      ...scoreUnlocks,
      ...survivalUnlocks,
      ...gamesUnlocks,
      ...specialUnlocks,
    ];
    _bufferUnlockXP(allLocalUnlocks);
    return allLocalUnlocks;
  }

  // ---------------------------------------------------------------------
  // Coins
  // ---------------------------------------------------------------------

  /// Wraps [CoinsCubit.earnCoins] and returns the amount ACTUALLY granted
  /// (post-Pro multiplier, post-daily-cap). `balance.earned` is a monotonic
  /// lifetime counter; the diff before and after the call is exactly what
  /// was credited this time.
  Future<int> grantCoins(
    CoinEarningSource source, {
    int? customAmount,
    Map<String, dynamic>? metadata,
  }) async {
    final before = _coinsCubit.state.balance.earned;
    await _coinsCubit.earnCoins(
      source,
      customAmount: customAmount,
      metadata: metadata,
    );
    final after = _coinsCubit.state.balance.earned;
    final delta = after - before;
    return delta > 0 ? delta : 0;
  }

  /// Grant coin awards for a list of levels gained during play (buffered
  /// off-tick by the caller). Returns the total actually granted.
  Future<int> flushLevelUpCoins(List<int> levels) async {
    var granted = 0;
    for (final level in levels) {
      granted += await grantCoins(
        CoinEarningSource.levelUp,
        metadata: {'level': level},
      );
    }
    return granted;
  }

  /// Completion coins: base + score bonus, perfect-game bonus, long-survival
  /// bonus. Returns the total actually granted.
  Future<int> awardCompletionCoins(GameRunSummary summary) async {
    var granted = 0;
    try {
      // Base coins + bonus based on score (1 base + 1 per 200 points, max 10)
      final coinsEarned = (1 + (summary.score ~/ 200)).clamp(1, 10);

      granted += await grantCoins(
        CoinEarningSource.gameCompleted,
        customAmount: coinsEarned,
        metadata: {
          'score': summary.score,
          'level': summary.level,
          'foodEaten': summary.foodEaten,
        },
      );

      if (summary.isPerfectGame) {
        granted += await grantCoins(
          CoinEarningSource.perfectGame,
          metadata: {
            'duration': summary.durationSeconds,
            'score': summary.score,
          },
        );
      }

      // Bonus for long survival (> 5 minutes = 300 seconds)
      if (summary.durationSeconds > 300) {
        granted += await grantCoins(
          CoinEarningSource.longSurvival,
          metadata: {
            'duration': summary.durationSeconds,
            'score': summary.score,
          },
        );
      }

      AppLogger.info(
        'Awarded game completion coins: $coinsEarned '
        '(score: ${summary.score}, perfect: ${summary.isPerfectGame}, '
        'long: ${summary.durationSeconds > 300})',
      );
    } catch (e) {
      AppLogger.error('Error awarding game completion coins', e);
    }
    return granted;
  }

  // ---------------------------------------------------------------------
  // Battle pass XP
  // ---------------------------------------------------------------------

  /// Buffer performance XP (game completed, survival milestones, tournament
  /// participation) before the flush in [runPostGame] sends everything in
  /// one API call. `awardedMilestones` is the caller's per-run guard set —
  /// shared with the in-play score-milestone buffering so nothing is
  /// double-awarded.
  void bufferPerformanceXP(
    GameRunSummary summary, {
    required Set<String> awardedMilestones,
  }) {
    final gameCompletedXp =
        BattlePassXpSource.getXpForAction('game_completed');
    if (gameCompletedXp > 0) {
      _battlePassCubit.bufferXP(gameCompletedXp, source: 'game_completed');
    }

    if (summary.durationSeconds >= 300 &&
        !awardedMilestones.contains('survival_300s')) {
      awardedMilestones.add('survival_300s');
      final xp = BattlePassXpSource.getXpForAction('survival_300s');
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: 'survival_300s');
      }
    }
    if (summary.durationSeconds >= 60 &&
        !awardedMilestones.contains('survival_60s')) {
      awardedMilestones.add('survival_60s');
      final xp = BattlePassXpSource.getXpForAction('survival_60s');
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: 'survival_60s');
      }
    }

    // Tournament participation XP — once per tournament game. The flush at
    // game end combines this with the per-game sources above into a single
    // backend POST that the AddBattlePassXp validator accepts via its
    // comma-separated source allowlist.
    if (summary.isTournament &&
        !awardedMilestones.contains('tournament_participation')) {
      awardedMilestones.add('tournament_participation');
      final xp =
          BattlePassXpSource.getXpForAction('tournament_participation');
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: 'tournament_participation');
      }
    }
  }

  // ---------------------------------------------------------------------
  // Post-game orchestration (async, fire-and-forget from the caller)
  // ---------------------------------------------------------------------

  /// Runs the full post-game choreography for a single-player run, in the
  /// same order the cubit historically used:
  ///
  ///  1. completion coins (incl. buffered level-up coins) → [onCoinsAwarded]
  ///  2. performance battle-pass XP buffering
  ///  3. local stats update + lifetime/general achievement checks + cache
  ///     refresh (fast local writes, done BEFORE any network so the
  ///     Profile/Statistics screens are fresh immediately after game-over)
  ///  4. network-bearing syncs (achievements, daily challenges, weekly
  ///     quests, battle-pass XP flush)
  ///  5. achievement/coins backend re-sync + XP for server-confirmed unlocks
  Future<void> runPostGame(
    GameRunSummary summary, {
    required List<int> pendingLevelUpCoinLevels,
    required Set<String> awardedMilestones,
    void Function(int coinsGranted)? onCoinsAwarded,
  }) async {
    try {
      // 1. Coins — level-up grants buffered during play first, so the
      // per-game total reported to the caller includes them.
      var coinsGranted =
          await flushLevelUpCoins(List<int>.from(pendingLevelUpCoinLevels));
      pendingLevelUpCoinLevels.clear();
      coinsGranted += await awardCompletionCoins(summary);
      onCoinsAwarded?.call(coinsGranted);

      // 2. Battle-pass XP for this run's performance.
      bufferPerformanceXP(summary, awardedMilestones: awardedMilestones);

      // 3. STEP A — Local stats update + cache refresh first. These are all
      // fast local writes (Drift + in-memory snapshot copy). Doing this
      // before the network-bearing Future.wait below guarantees that when
      // the user navigates to the Profile or Statistics screen right after
      // game-over, the AppDataCache snapshot already reflects the new data.
      await _statisticsService.recordGameResult(
        score: summary.score,
        gameTime: summary.durationSeconds,
        level: summary.level,
        foodConsumed: summary.foodEaten,
        foodTypes: summary.foodTypes,
        foodPoints: summary.foodPoints,
        powerUpsCollected: summary.powerUpsCollected,
        powerUpTypes: summary.powerUpTypes,
        powerUpTime: summary.powerUpTimeSeconds,
        wallHits: summary.wallHits,
        selfHits: summary.selfHits,
        isPerfectGame: summary.isPerfectGame,
        unlockedAchievements: [],
        gameMode: summary.gameMode,
      );

      // Now that lifetime stats include this game, check the catalog's
      // lifetime-driven achievements (power-ups, food variety, perfect
      // games, streaks, weekend days).
      final stats = _statisticsService.statistics;
      _achievementService.checkLifetimeAchievements(
        totalPowerUps: stats.totalPowerUpsCollected,
        powerUpTypeCount: stats.powerUpTypeCount,
        foodTypeCount: stats.foodTypeCount,
        perfectGames: stats.perfectGames,
        currentWinStreak: stats.currentWinStreak,
        dailyPlayTime: stats.dailyPlayTime,
      );

      // General-category achievements: lifetime player level, total
      // playtime, and mode exploration.
      _achievementService.checkGeneralAchievements(
        playerLevel: _progressionService.level,
        totalPlayTimeSeconds: stats.totalGameTime,
        // Count only real GameMode buckets — the stats map can carry
        // non-mode keys (multiplayer matches record as 'multiplayer').
        distinctModesPlayed: GameMode.values
            .where((m) => (stats.gameModeCount[m.name] ?? 0) > 0)
            .length,
      );

      await _appDataCache.refreshStatistics();

      // 4. STEP B — Network-bearing syncs. The caller fire-and-forgets
      // runPostGame, so even if these block on slow API calls the
      // user-visible game-over flow doesn't wait on them.
      await Future.wait([
        _achievementService.syncUnlockedAchievements(),
        _dailyChallengeService.updateProgressBatch([
          if (summary.score > 0)
            (
              type: ChallengeType.score,
              value: summary.score,
              gameMode: null,
            ),
          if (summary.foodEaten > 0)
            (
              type: ChallengeType.foodEaten,
              value: summary.foodEaten,
              gameMode: null,
            ),
          if (summary.durationSeconds > 0)
            (
              type: ChallengeType.survival,
              value: summary.durationSeconds,
              gameMode: null,
            ),
          (type: ChallengeType.gamesPlayed, value: 1, gameMode: null),
          (
            type: ChallengeType.gameMode,
            value: 1,
            gameMode: summary.gameMode,
          ),
        ]),
        // Mirror the daily-challenge progress events to the weekly-quest
        // tracker — the backend filters by Type so events without a matching
        // active quest are no-ops.
        _weeklyQuestService.reportProgressBatch([
          if (summary.score > 0)
            (
              type: WeeklyQuestType.score,
              incrementBy: summary.score,
              gameMode: null,
            ),
          if (summary.foodEaten > 0)
            (
              type: WeeklyQuestType.foodEaten,
              incrementBy: summary.foodEaten,
              gameMode: null,
            ),
          if (summary.durationSeconds > 0)
            (
              type: WeeklyQuestType.survival,
              incrementBy: summary.durationSeconds,
              gameMode: null,
            ),
          (
            type: WeeklyQuestType.gamesPlayed,
            incrementBy: 1,
            gameMode: null,
          ),
          if (summary.isTournament)
            (
              type: WeeklyQuestType.tournamentParticipation,
              incrementBy: 1,
              gameMode: null,
            ),
        ]),
        _battlePassCubit.flushXP(),
      ]);

      // 5. Refetch achievements so any server-derived unlocks replace the
      // local-only state. The sync also auto-claims pending rewards, which
      // increments User.Coins / User.Experience server-side — so chase it
      // with a coin balance refresh to pull the new total client-side.
      // Fire-and-forget — next refresh cycle catches anything missed. After
      // the achievement sync lands, buffer BP XP for any newly
      // server-confirmed unlocks.
      final preSyncIds =
          _achievementService.lastGameUnlocks.map((a) => a.id).toSet();
      unawaited(() async {
        await _achievementService.syncWithBackend();
        await _coinsCubit.syncWithBackend();
        _bufferUnlockXP(
          _achievementService.lastGameUnlocks
              .where((a) => !preSyncIds.contains(a.id)),
        );
      }());
    } catch (e) {
      debugPrint('🏁 [GameEndPipeline] Post-game sync error: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Multiplayer entry points
  // ---------------------------------------------------------------------

  /// Record a finished multiplayer match into the per-user statistics,
  /// entirely from server-reported values. Multiplayer matches record under
  /// the non-GameMode key 'multiplayer' on purpose — they must not count
  /// toward the per-mode / mode-exploration achievements.
  Future<void> recordMultiplayerMatch({
    required int score,
    required int foodsEaten,
    required int gameTimeSeconds,
    required bool alive,
    required String? deathReason,
  }) {
    final wallHits = deathReason == 'wall' ? 1 : 0;
    // self / opponent / head_on all bucket into selfHits — statistics
    // has no "other snake" column and multiplayer walls are always on.
    final selfHits = (!alive && wallHits == 0) ? 1 : 0;

    return _statisticsService.recordGameResult(
      score: score,
      gameTime: gameTimeSeconds,
      level: 1,
      foodConsumed: foodsEaten,
      foodTypes: {'apple': foodsEaten},
      foodPoints: score,
      powerUpsCollected: 0,
      powerUpTypes: const <String, int>{},
      powerUpTime: 0,
      wallHits: wallHits,
      selfHits: selfHits,
      isPerfectGame: alive && gameTimeSeconds >= 30,
      unlockedAchievements: const [],
      gameMode: 'multiplayer',
    );
  }

  /// Credit end-of-match multiplayer rewards through the standard economy
  /// paths: the winner earns the server-announced coin amount via CoinsCubit
  /// (caps/animations/sync apply) and both sides earn battle-pass XP via the
  /// usual buffer→flush flow. Callers guard for once-per-match idempotency.
  void creditMultiplayerRewards({
    required bool won,
    required int winnerCoinReward,
  }) {
    if (won && winnerCoinReward > 0) {
      unawaited(
        _coinsCubit.earnCoins(
          CoinEarningSource.multiplayer,
          customAmount: winnerCoinReward,
          itemName: 'Multiplayer Victory',
        ),
      );
    }

    final xpKey = won ? 'multiplayer_win' : 'multiplayer_participation';
    final xp = BattlePassXpSource.getXpForAction(xpKey);
    if (xp > 0) {
      _battlePassCubit.bufferXP(xp, source: xpKey);
    }
    unawaited(_battlePassCubit.flushXP());
  }

  // ---------------------------------------------------------------------

  /// Battle-pass XP for a batch of achievement unlocks, keyed by rarity.
  void _bufferUnlockXP(Iterable<Achievement> unlocks) {
    for (final achievement in unlocks) {
      final xpKey = 'achievement_unlocked_${achievement.rarity.name}';
      final xp = BattlePassXpSource.getXpForAction(xpKey);
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: xpKey);
      }
    }
  }
}
