import 'dart:convert';

class GameStatistics {
  // Basic game metrics
  final int totalGamesPlayed;
  final int totalScore;
  final int highScore;
  final int totalGameTime; // in seconds
  final int averageGameTime; // in seconds

  // Food consumption stats
  final int totalFoodConsumed;
  final Map<String, int> foodTypeCount; // normal, bonus, special
  final int totalFoodPoints;

  // Power-up statistics
  final int totalPowerUpsCollected;
  final Map<String, int> powerUpTypeCount; // speedBoost, invincibility, etc.
  final int totalPowerUpTime; // total time with active power-ups (seconds)

  // Survival and performance metrics
  final int longestSurvivalTime; // in seconds
  final int highestLevel;
  final int totalLevelsGained;
  final double averageScore;
  final double survivalRate; // percentage of games that lasted > 30 seconds

  // Collision statistics
  final int wallCollisions;
  final int selfCollisions;
  final int totalCollisions;
  final double collisionRate; // collisions per game

  // Streak and consistency metrics
  final int currentWinStreak; // games without dying quickly (>30s)
  final int longestWinStreak;
  final int gamesWithoutWallHit;
  final int perfectGames; // games with no collisions

  // Session and time-based stats
  final int totalSessions;
  final int averageGamesPerSession;
  final DateTime? lastPlayedDate;
  final DateTime? firstPlayedDate;
  final List<int> recentScores; // last 10 scores
  final Map<String, int> dailyPlayTime; // date -> seconds played

  // Achievement progress
  final int achievementsUnlocked;
  final int totalAchievements;
  final double achievementProgress; // percentage

  const GameStatistics({
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.highScore = 0,
    this.totalGameTime = 0,
    this.averageGameTime = 0,
    this.totalFoodConsumed = 0,
    this.foodTypeCount = const {},
    this.totalFoodPoints = 0,
    this.totalPowerUpsCollected = 0,
    this.powerUpTypeCount = const {},
    this.totalPowerUpTime = 0,
    this.longestSurvivalTime = 0,
    this.highestLevel = 1,
    this.totalLevelsGained = 0,
    this.averageScore = 0.0,
    this.survivalRate = 0.0,
    this.wallCollisions = 0,
    this.selfCollisions = 0,
    this.totalCollisions = 0,
    this.collisionRate = 0.0,
    this.currentWinStreak = 0,
    this.longestWinStreak = 0,
    this.gamesWithoutWallHit = 0,
    this.perfectGames = 0,
    this.totalSessions = 0,
    this.averageGamesPerSession = 0,
    this.lastPlayedDate,
    this.firstPlayedDate,
    this.recentScores = const [],
    this.dailyPlayTime = const {},
    this.achievementsUnlocked = 0,
    this.totalAchievements = 16, // We have 16 achievements
    this.achievementProgress = 0.0,
  });

  factory GameStatistics.initial() {
    return GameStatistics(
      firstPlayedDate: DateTime.now(),
      lastPlayedDate: DateTime.now(),
    );
  }

  // Calculate derived metrics
  double get averageFoodPerGame {
    return totalGamesPlayed > 0 ? totalFoodConsumed / totalGamesPlayed : 0.0;
  }

  double get averagePowerUpsPerGame {
    return totalGamesPlayed > 0
        ? totalPowerUpsCollected / totalGamesPlayed
        : 0.0;
  }

  double get averagePointsPerFood {
    return totalFoodConsumed > 0 ? totalFoodPoints / totalFoodConsumed : 0.0;
  }

  double get averageLevelPerGame {
    return totalGamesPlayed > 0 ? totalLevelsGained / totalGamesPlayed : 1.0;
  }

  double get wallCollisionRate {
    return totalGamesPlayed > 0 ? wallCollisions / totalGamesPlayed : 0.0;
  }

  double get selfCollisionRate {
    return totalGamesPlayed > 0 ? selfCollisions / totalGamesPlayed : 0.0;
  }

  String get favoriteFood {
    if (foodTypeCount.isEmpty) return 'none';

    final sortedFood = foodTypeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedFood.first.key;
  }

  String get favoritePowerUp {
    if (powerUpTypeCount.isEmpty) return 'none';

    final sortedPowerUps = powerUpTypeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedPowerUps.first.key;
  }

  int get totalPlayTimeHours {
    return (totalGameTime / 3600).round();
  }

  int get gamesPlayedToday {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    return dailyPlayTime[todayKey] ?? 0;
  }

  // Update statistics with new game data
  GameStatistics updateWithGameResult({
    required int score,
    required int gameTime,
    required int level,
    required int foodConsumed,
    required Map<String, int> foodTypes,
    required int foodPoints,
    required int powerUpsCollected,
    required Map<String, int> powerUpTypes,
    required int powerUpTime,
    required bool hitWall,
    required bool hitSelf,
    required bool isPerfectGame,
    required List<String> unlockedAchievements,
  }) {
    final newTotalGames = totalGamesPlayed + 1;
    final newTotalScore = totalScore + score;
    final newHighScore = score > highScore ? score : highScore;
    final newTotalGameTime = totalGameTime + gameTime;
    final newAverageGameTime = (newTotalGameTime / newTotalGames).round();

    final newTotalFoodConsumed = totalFoodConsumed + foodConsumed;
    final newFoodTypeCount = Map<String, int>.from(foodTypeCount);
    foodTypes.forEach((key, value) {
      newFoodTypeCount[key] = (newFoodTypeCount[key] ?? 0) + value;
    });

    final newTotalPowerUps = totalPowerUpsCollected + powerUpsCollected;
    final newPowerUpTypeCount = Map<String, int>.from(powerUpTypeCount);
    powerUpTypes.forEach((key, value) {
      newPowerUpTypeCount[key] = (newPowerUpTypeCount[key] ?? 0) + value;
    });

    final newWallCollisions = hitWall ? wallCollisions + 1 : wallCollisions;
    final newSelfCollisions = hitSelf ? selfCollisions + 1 : selfCollisions;
    final newTotalCollisions = newWallCollisions + newSelfCollisions;

    final survived30Seconds = gameTime >= 30;
    final newCurrentStreak = survived30Seconds ? currentWinStreak + 1 : 0;
    final newLongestStreak = newCurrentStreak > longestWinStreak
        ? newCurrentStreak
        : longestWinStreak;

    final newGamesWithoutWallHit = hitWall ? 0 : gamesWithoutWallHit + 1;
    final newPerfectGames = isPerfectGame ? perfectGames + 1 : perfectGames;

    final newRecentScores = [...recentScores, score];
    if (newRecentScores.length > 10) {
      newRecentScores.removeAt(0);
    }

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final newDailyPlayTime = Map<String, int>.from(dailyPlayTime);
    newDailyPlayTime[todayKey] = (newDailyPlayTime[todayKey] ?? 0) + gameTime;

    final survivedGames =
        recentScores.where((s) => s > 0).length + (survived30Seconds ? 1 : 0);
    final newSurvivalRate = survivedGames / newTotalGames;

    final newAchievementsUnlocked =
        achievementsUnlocked + unlockedAchievements.length;
    final newAchievementProgress = newAchievementsUnlocked / totalAchievements;

    return GameStatistics(
      totalGamesPlayed: newTotalGames,
      totalScore: newTotalScore,
      highScore: newHighScore,
      totalGameTime: newTotalGameTime,
      averageGameTime: newAverageGameTime,
      totalFoodConsumed: newTotalFoodConsumed,
      foodTypeCount: newFoodTypeCount,
      totalFoodPoints: totalFoodPoints + foodPoints,
      totalPowerUpsCollected: newTotalPowerUps,
      powerUpTypeCount: newPowerUpTypeCount,
      totalPowerUpTime: totalPowerUpTime + powerUpTime,
      longestSurvivalTime: gameTime > longestSurvivalTime
          ? gameTime
          : longestSurvivalTime,
      highestLevel: level > highestLevel ? level : highestLevel,
      totalLevelsGained: totalLevelsGained + (level - 1),
      averageScore: newTotalScore / newTotalGames,
      survivalRate: newSurvivalRate,
      wallCollisions: newWallCollisions,
      selfCollisions: newSelfCollisions,
      totalCollisions: newTotalCollisions,
      collisionRate: newTotalCollisions / newTotalGames,
      currentWinStreak: newCurrentStreak,
      longestWinStreak: newLongestStreak,
      gamesWithoutWallHit: newGamesWithoutWallHit,
      perfectGames: newPerfectGames,
      totalSessions: totalSessions,
      averageGamesPerSession: totalSessions > 0
          ? (newTotalGames / totalSessions).round()
          : newTotalGames,
      lastPlayedDate: today,
      firstPlayedDate: firstPlayedDate ?? today,
      recentScores: newRecentScores,
      dailyPlayTime: newDailyPlayTime,
      achievementsUnlocked: newAchievementsUnlocked,
      totalAchievements: totalAchievements,
      achievementProgress: newAchievementProgress,
    );
  }

  GameStatistics startNewSession() {
    return GameStatistics(
      totalGamesPlayed: totalGamesPlayed,
      totalScore: totalScore,
      highScore: highScore,
      totalGameTime: totalGameTime,
      averageGameTime: averageGameTime,
      totalFoodConsumed: totalFoodConsumed,
      foodTypeCount: foodTypeCount,
      totalFoodPoints: totalFoodPoints,
      totalPowerUpsCollected: totalPowerUpsCollected,
      powerUpTypeCount: powerUpTypeCount,
      totalPowerUpTime: totalPowerUpTime,
      longestSurvivalTime: longestSurvivalTime,
      highestLevel: highestLevel,
      totalLevelsGained: totalLevelsGained,
      averageScore: averageScore,
      survivalRate: survivalRate,
      wallCollisions: wallCollisions,
      selfCollisions: selfCollisions,
      totalCollisions: totalCollisions,
      collisionRate: collisionRate,
      currentWinStreak: currentWinStreak,
      longestWinStreak: longestWinStreak,
      gamesWithoutWallHit: gamesWithoutWallHit,
      perfectGames: perfectGames,
      totalSessions: totalSessions + 1,
      averageGamesPerSession: averageGamesPerSession,
      lastPlayedDate: DateTime.now(),
      firstPlayedDate: firstPlayedDate,
      recentScores: recentScores,
      dailyPlayTime: dailyPlayTime,
      achievementsUnlocked: achievementsUnlocked,
      totalAchievements: totalAchievements,
      achievementProgress: achievementProgress,
    );
  }

  // Create a copy with updated high score (for sync purposes)
  GameStatistics withHighScore(int newHighScore) {
    return GameStatistics(
      totalGamesPlayed: totalGamesPlayed,
      totalScore: totalScore,
      highScore: newHighScore,
      totalGameTime: totalGameTime,
      averageGameTime: averageGameTime,
      totalFoodConsumed: totalFoodConsumed,
      foodTypeCount: foodTypeCount,
      totalFoodPoints: totalFoodPoints,
      totalPowerUpsCollected: totalPowerUpsCollected,
      powerUpTypeCount: powerUpTypeCount,
      totalPowerUpTime: totalPowerUpTime,
      longestSurvivalTime: longestSurvivalTime,
      highestLevel: highestLevel,
      totalLevelsGained: totalLevelsGained,
      averageScore: averageScore,
      survivalRate: survivalRate,
      wallCollisions: wallCollisions,
      selfCollisions: selfCollisions,
      totalCollisions: totalCollisions,
      collisionRate: collisionRate,
      currentWinStreak: currentWinStreak,
      longestWinStreak: longestWinStreak,
      gamesWithoutWallHit: gamesWithoutWallHit,
      perfectGames: perfectGames,
      totalSessions: totalSessions,
      averageGamesPerSession: averageGamesPerSession,
      lastPlayedDate: lastPlayedDate,
      firstPlayedDate: firstPlayedDate,
      recentScores: recentScores,
      dailyPlayTime: dailyPlayTime,
      achievementsUnlocked: achievementsUnlocked,
      totalAchievements: totalAchievements,
      achievementProgress: achievementProgress,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'highScore': highScore,
      'totalGameTime': totalGameTime,
      'averageGameTime': averageGameTime,
      'totalFoodConsumed': totalFoodConsumed,
      'foodTypeCount': foodTypeCount,
      'totalFoodPoints': totalFoodPoints,
      'totalPowerUpsCollected': totalPowerUpsCollected,
      'powerUpTypeCount': powerUpTypeCount,
      'totalPowerUpTime': totalPowerUpTime,
      'longestSurvivalTime': longestSurvivalTime,
      'highestLevel': highestLevel,
      'totalLevelsGained': totalLevelsGained,
      'averageScore': averageScore,
      'survivalRate': survivalRate,
      'wallCollisions': wallCollisions,
      'selfCollisions': selfCollisions,
      'totalCollisions': totalCollisions,
      'collisionRate': collisionRate,
      'currentWinStreak': currentWinStreak,
      'longestWinStreak': longestWinStreak,
      'gamesWithoutWallHit': gamesWithoutWallHit,
      'perfectGames': perfectGames,
      'totalSessions': totalSessions,
      'averageGamesPerSession': averageGamesPerSession,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'firstPlayedDate': firstPlayedDate?.toIso8601String(),
      'recentScores': recentScores,
      'dailyPlayTime': dailyPlayTime,
      'achievementsUnlocked': achievementsUnlocked,
      'totalAchievements': totalAchievements,
      'achievementProgress': achievementProgress,
    };
  }

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      highScore: json['highScore'] ?? 0,
      totalGameTime: json['totalGameTime'] ?? 0,
      averageGameTime: json['averageGameTime'] ?? 0,
      totalFoodConsumed: json['totalFoodConsumed'] ?? 0,
      foodTypeCount: Map<String, int>.from(json['foodTypeCount'] ?? {}),
      totalFoodPoints: json['totalFoodPoints'] ?? 0,
      totalPowerUpsCollected: json['totalPowerUpsCollected'] ?? 0,
      powerUpTypeCount: Map<String, int>.from(json['powerUpTypeCount'] ?? {}),
      totalPowerUpTime: json['totalPowerUpTime'] ?? 0,
      longestSurvivalTime: json['longestSurvivalTime'] ?? 0,
      highestLevel: json['highestLevel'] ?? 1,
      totalLevelsGained: json['totalLevelsGained'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      survivalRate: (json['survivalRate'] ?? 0.0).toDouble(),
      wallCollisions: json['wallCollisions'] ?? 0,
      selfCollisions: json['selfCollisions'] ?? 0,
      totalCollisions: json['totalCollisions'] ?? 0,
      collisionRate: (json['collisionRate'] ?? 0.0).toDouble(),
      currentWinStreak: json['currentWinStreak'] ?? 0,
      longestWinStreak: json['longestWinStreak'] ?? 0,
      gamesWithoutWallHit: json['gamesWithoutWallHit'] ?? 0,
      perfectGames: json['perfectGames'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      averageGamesPerSession: json['averageGamesPerSession'] ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
      firstPlayedDate: json['firstPlayedDate'] != null
          ? DateTime.parse(json['firstPlayedDate'])
          : null,
      recentScores: List<int>.from(json['recentScores'] ?? []),
      dailyPlayTime: Map<String, int>.from(json['dailyPlayTime'] ?? {}),
      achievementsUnlocked: json['achievementsUnlocked'] ?? 0,
      totalAchievements: json['totalAchievements'] ?? 16,
      achievementProgress: (json['achievementProgress'] ?? 0.0).toDouble(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory GameStatistics.fromJsonString(String jsonString) {
    return GameStatistics.fromJson(jsonDecode(jsonString));
  }
}
