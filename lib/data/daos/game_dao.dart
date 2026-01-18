import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart';

part 'game_dao.g.dart';

@DriftAccessor(tables: [Statistics, Achievements, Replays, DailyChallenges])
class GameDao extends DatabaseAccessor<AppDatabase> with _$GameDaoMixin {
  GameDao(super.db);

  // ==================== Statistics ====================

  /// Watch statistics for reactive UI
  Stream<Statistic?> watchStatistics() =>
      select(statistics).watchSingleOrNull();

  /// Get current statistics
  Future<Statistic?> getStatistics() => select(statistics).getSingleOrNull();

  /// Update statistics after a game
  Future<void> updateGameStats({
    required int score,
    required int snakeLength,
    required int foodsEaten,
    required int gameDurationSeconds,
    required String deathCause, // 'wall' or 'self'
    required String gameMode,
  }) async {
    final current = await getStatistics();
    if (current == null) return;

    final newTotalGames = current.totalGamesPlayed + 1;
    final newTotalScore = current.totalScore + score;
    final newHighestScore =
        score > current.highestScore ? score : current.highestScore;
    final newTotalFoods = current.totalFoodsEaten + foodsEaten;
    final newTotalTime = current.totalGameTimeSeconds + gameDurationSeconds;
    final newMaxLength =
        snakeLength > current.maxSnakeLength ? snakeLength : current.maxSnakeLength;
    final newTotalLength = current.totalSnakeLength + snakeLength;
    final newAvgLength = newTotalLength / newTotalGames;

    int newDeathsByWall = current.deathsByWall;
    int newDeathsBySelf = current.deathsBySelf;
    if (deathCause == 'wall') {
      newDeathsByWall++;
    } else if (deathCause == 'self') {
      newDeathsBySelf++;
    }

    final newShortestGame = current.shortestGameSeconds == 0 ||
            gameDurationSeconds < current.shortestGameSeconds
        ? gameDurationSeconds
        : current.shortestGameSeconds;
    final newLongestGame = gameDurationSeconds > current.longestGameSeconds
        ? gameDurationSeconds
        : current.longestGameSeconds;
    final newAvgDuration = newTotalTime / newTotalGames;

    await (update(statistics)..where((t) => t.id.equals(1))).write(
      StatisticsCompanion(
        totalGamesPlayed: Value(newTotalGames),
        totalScore: Value(newTotalScore),
        highestScore: Value(newHighestScore),
        totalFoodsEaten: Value(newTotalFoods),
        totalGameTimeSeconds: Value(newTotalTime),
        maxSnakeLength: Value(newMaxLength),
        totalSnakeLength: Value(newTotalLength),
        averageSnakeLength: Value(newAvgLength),
        deathsByWall: Value(newDeathsByWall),
        deathsBySelf: Value(newDeathsBySelf),
        totalDeaths: Value(newDeathsByWall + newDeathsBySelf),
        shortestGameSeconds: Value(newShortestGame),
        longestGameSeconds: Value(newLongestGame),
        averageGameDuration: Value(newAvgDuration),
        lastPlayedAt: Value(DateTime.now()),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Update full statistics from JSON (for sync)
  Future<void> updateStatisticsFromJson(String jsonData) async {
    final data = json.decode(jsonData) as Map<String, dynamic>;
    await (update(statistics)..where((t) => t.id.equals(1))).write(
      StatisticsCompanion(
        totalGamesPlayed: Value(data['totalGamesPlayed'] ?? 0),
        totalScore: Value(data['totalScore'] ?? 0),
        highestScore: Value(data['highestScore'] ?? 0),
        totalFoodsEaten: Value(data['totalFoodsEaten'] ?? 0),
        totalGameTimeSeconds: Value(data['totalGameTimeSeconds'] ?? 0),
        maxSnakeLength: Value(data['maxSnakeLength'] ?? 0),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  /// Get statistics as JSON string
  Future<String> getStatisticsAsJson() async {
    final stats = await getStatistics();
    if (stats == null) return '{}';

    return json.encode({
      'totalGamesPlayed': stats.totalGamesPlayed,
      'totalScore': stats.totalScore,
      'highestScore': stats.highestScore,
      'totalFoodsEaten': stats.totalFoodsEaten,
      'totalGameTimeSeconds': stats.totalGameTimeSeconds,
      'maxSnakeLength': stats.maxSnakeLength,
      'totalSnakeLength': stats.totalSnakeLength,
      'averageSnakeLength': stats.averageSnakeLength,
      'deathsByWall': stats.deathsByWall,
      'deathsBySelf': stats.deathsBySelf,
      'totalDeaths': stats.totalDeaths,
      'longestSessionSeconds': stats.longestSessionSeconds,
      'shortestGameSeconds': stats.shortestGameSeconds,
      'longestGameSeconds': stats.longestGameSeconds,
      'averageGameDuration': stats.averageGameDuration,
      'currentWinStreak': stats.currentWinStreak,
      'longestWinStreak': stats.longestWinStreak,
      'currentPlayStreak': stats.currentPlayStreak,
      'longestPlayStreak': stats.longestPlayStreak,
      'powerUpsCollected': stats.powerUpsCollected,
      'perfectGames': stats.perfectGames,
      'multiplayerGamesPlayed': stats.multiplayerGamesPlayed,
      'multiplayerWins': stats.multiplayerWins,
      'tournamentsEntered': stats.tournamentsEntered,
      'tournamentsWon': stats.tournamentsWon,
      'lastPlayedAt': stats.lastPlayedAt?.toIso8601String(),
      'lastUpdated': stats.lastUpdated.toIso8601String(),
    });
  }

  // ==================== Achievements ====================

  /// Watch all achievements
  Stream<List<Achievement>> watchAchievements() => select(achievements).watch();

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() =>
      select(achievements).get();

  /// Get unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() =>
      (select(achievements)..where((t) => t.isUnlocked.equals(true))).get();

  /// Update achievement progress
  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    final achievement = await (select(achievements)
          ..where((t) => t.id.equals(achievementId)))
        .getSingleOrNull();

    if (achievement == null) return;

    final isNowUnlocked = progress >= achievement.targetProgress;

    await (update(achievements)..where((t) => t.id.equals(achievementId)))
        .write(AchievementsCompanion(
      currentProgress: Value(progress),
      isUnlocked: Value(isNowUnlocked),
      unlockedAt: isNowUnlocked && !achievement.isUnlocked
          ? Value(DateTime.now())
          : const Value.absent(),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Unlock achievement directly
  Future<void> unlockAchievement(String achievementId) async {
    await (update(achievements)..where((t) => t.id.equals(achievementId)))
        .write(AchievementsCompanion(
      isUnlocked: const Value(true),
      unlockedAt: Value(DateTime.now()),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Claim achievement reward
  Future<int> claimAchievementReward(String achievementId) async {
    final achievement = await (select(achievements)
          ..where((t) => t.id.equals(achievementId)))
        .getSingleOrNull();

    if (achievement == null || achievement.rewardClaimed) return 0;

    await (update(achievements)..where((t) => t.id.equals(achievementId)))
        .write(const AchievementsCompanion(
      rewardClaimed: Value(true),
    ));

    return achievement.rewardCoins;
  }

  /// Insert or update achievement
  Future<void> upsertAchievement(AchievementsCompanion achievement) async {
    await into(achievements).insertOnConflictUpdate(achievement);
  }

  /// Get achievements as JSON
  Future<String> getAchievementsAsJson() async {
    final list = await getAllAchievements();
    return json.encode(list
        .map((a) => {
              'id': a.id,
              'name': a.name,
              'description': a.description,
              'category': a.category,
              'currentProgress': a.currentProgress,
              'targetProgress': a.targetProgress,
              'isUnlocked': a.isUnlocked,
              'unlockedAt': a.unlockedAt?.toIso8601String(),
              'rewardCoins': a.rewardCoins,
              'rewardClaimed': a.rewardClaimed,
            })
        .toList());
  }

  /// Load achievements from JSON
  Future<void> loadAchievementsFromJson(String jsonData) async {
    final List<dynamic> list = json.decode(jsonData);
    for (final item in list) {
      await upsertAchievement(AchievementsCompanion(
        id: Value(item['id']),
        name: Value(item['name']),
        description: Value(item['description']),
        category: Value(item['category'] ?? 'general'),
        currentProgress: Value(item['currentProgress'] ?? 0),
        targetProgress: Value(item['targetProgress'] ?? 1),
        isUnlocked: Value(item['isUnlocked'] ?? false),
        unlockedAt: item['unlockedAt'] != null
            ? Value(DateTime.parse(item['unlockedAt']))
            : const Value.absent(),
        rewardCoins: Value(item['rewardCoins'] ?? 0),
        rewardClaimed: Value(item['rewardClaimed'] ?? false),
      ));
    }
  }

  // ==================== Replays ====================

  /// Watch all replays
  Stream<List<Replay>> watchReplays() =>
      (select(replays)..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
          .watch();

  /// Get all replays
  Future<List<Replay>> getAllReplays() =>
      (select(replays)..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
          .get();

  /// Get replay by ID
  Future<Replay?> getReplay(String id) =>
      (select(replays)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Save a replay
  Future<void> saveReplay(ReplaysCompanion replay) async {
    await into(replays).insertOnConflictUpdate(replay);
  }

  /// Delete a replay
  Future<void> deleteReplay(String id) async {
    await (delete(replays)..where((t) => t.id.equals(id))).go();
  }

  /// Toggle replay favorite
  Future<void> toggleReplayFavorite(String id) async {
    final replay = await getReplay(id);
    if (replay == null) return;

    await (update(replays)..where((t) => t.id.equals(id)))
        .write(ReplaysCompanion(isFavorite: Value(!replay.isFavorite)));
  }

  /// Get replay keys (IDs)
  Future<List<String>> getReplayKeys() async {
    final list = await getAllReplays();
    return list.map((r) => r.id).toList();
  }

  // ==================== Daily Challenges ====================

  /// Watch today's challenges
  Stream<List<DailyChallenge>> watchTodaysChallenges() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(dailyChallenges)
          ..where((t) =>
              t.challengeDate.isBiggerOrEqualValue(startOfDay) &
              t.challengeDate.isSmallerThanValue(endOfDay)))
        .watch();
  }

  /// Get today's challenges
  Future<List<DailyChallenge>> getTodaysChallenges() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(dailyChallenges)
          ..where((t) =>
              t.challengeDate.isBiggerOrEqualValue(startOfDay) &
              t.challengeDate.isSmallerThanValue(endOfDay)))
        .get();
  }

  /// Update challenge progress
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final challenge = await (select(dailyChallenges)
          ..where((t) => t.challengeId.equals(challengeId)))
        .getSingleOrNull();

    if (challenge == null) return;

    final isNowCompleted = progress >= challenge.targetProgress;

    await (update(dailyChallenges)
          ..where((t) => t.challengeId.equals(challengeId)))
        .write(DailyChallengesCompanion(
      currentProgress: Value(progress),
      isCompleted: Value(isNowCompleted),
      completedAt: isNowCompleted && !challenge.isCompleted
          ? Value(DateTime.now())
          : const Value.absent(),
    ));
  }

  /// Claim challenge reward
  Future<int> claimChallengeReward(String challengeId) async {
    final challenge = await (select(dailyChallenges)
          ..where((t) => t.challengeId.equals(challengeId)))
        .getSingleOrNull();

    if (challenge == null || challenge.rewardClaimed || !challenge.isCompleted) {
      return 0;
    }

    await (update(dailyChallenges)
          ..where((t) => t.challengeId.equals(challengeId)))
        .write(const DailyChallengesCompanion(
      rewardClaimed: Value(true),
    ));

    return challenge.rewardCoins;
  }

  /// Insert or update daily challenge
  Future<void> upsertDailyChallenge(DailyChallengesCompanion challenge) async {
    await into(dailyChallenges).insertOnConflictUpdate(challenge);
  }

  /// Clean up expired challenges
  Future<void> cleanupExpiredChallenges() async {
    final now = DateTime.now();
    await (delete(dailyChallenges)..where((t) => t.expiresAt.isSmallerThanValue(now))).go();
  }
}
