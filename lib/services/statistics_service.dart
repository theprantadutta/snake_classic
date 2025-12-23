import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';

class StatisticsService {
  static StatisticsService? _instance;
  final StorageService _storageService = StorageService();
  final DataSyncService _syncService = DataSyncService();
  final UnifiedUserService _userService = UnifiedUserService();
  
  GameStatistics _currentStatistics = GameStatistics.initial();
  bool _initialized = false;

  StatisticsService._internal();

  factory StatisticsService() {
    _instance ??= StatisticsService._internal();
    return _instance!;
  }

  GameStatistics get statistics => _currentStatistics;

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load local statistics first
      await _loadLocalStatistics();
      
      // If user is signed in, sync with cloud
      if (_userService.isSignedIn) {
        await _syncWithCloud();
      }
      
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing statistics service: $e');
      }
      // Continue with local statistics only
      _initialized = true;
    }
  }

  Future<void> _loadLocalStatistics() async {
    try {
      final statisticsJson = await _storageService.getStatistics();
      if (statisticsJson != null) {
        _currentStatistics = GameStatistics.fromJsonString(statisticsJson);
      } else {
        _currentStatistics = GameStatistics.initial();
      }

      // Sync high score between statistics and the separate highScore key
      // This ensures both sources stay in sync
      final separateHighScore = await _storageService.getHighScore();
      final statsHighScore = _currentStatistics.highScore;

      if (separateHighScore != statsHighScore) {
        // Take the maximum of both values
        final syncedHighScore =
            separateHighScore > statsHighScore ? separateHighScore : statsHighScore;

        // Update statistics if separate key had higher value
        if (separateHighScore > statsHighScore) {
          _currentStatistics = _currentStatistics.withHighScore(syncedHighScore);
          await _saveLocalStatistics();
        }

        // Update separate key if statistics had higher value
        if (statsHighScore > separateHighScore) {
          await _storageService.saveHighScore(syncedHighScore);
        }

        if (kDebugMode) {
          print('High score synced: stats=$statsHighScore, separate=$separateHighScore -> $syncedHighScore');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading local statistics: $e');
      }
      _currentStatistics = GameStatistics.initial();
    }
  }

  Future<void> _syncWithCloud() async {
    if (!_userService.isSignedIn) return;
    
    try {
      // Get cloud statistics
      final cloudStats = await _syncService.getData('statistics');
      
      if (cloudStats != null) {
        // Merge local and cloud statistics (keep the most recent data)
        final localStatsWithTimestamp = {
          ..._currentStatistics.toJson(),
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
        final mergedData = _syncService.mergeData(localStatsWithTimestamp, cloudStats);
        _currentStatistics = GameStatistics.fromJson(mergedData);
      }
      
      // Upload current statistics to cloud
      await _uploadToCloud();
      
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing with cloud: $e');
      }
      // Continue with local statistics
    }
  }

  Future<void> _uploadToCloud() async {
    if (!_userService.isSignedIn) return;
    
    try {
      final statisticsWithTimestamp = {
        ..._currentStatistics.toJson(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await _syncService.queueSync('statistics', statisticsWithTimestamp);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading to cloud: $e');
      }
    }
  }


  Future<void> recordGameResult({
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
  }) async {
    if (!_initialized) {
      await initialize();
    }
    
    // Update statistics with new game data
    _currentStatistics = _currentStatistics.updateWithGameResult(
      score: score,
      gameTime: gameTime,
      level: level,
      foodConsumed: foodConsumed,
      foodTypes: foodTypes,
      foodPoints: foodPoints,
      powerUpsCollected: powerUpsCollected,
      powerUpTypes: powerUpTypes,
      powerUpTime: powerUpTime,
      hitWall: hitWall,
      hitSelf: hitSelf,
      isPerfectGame: isPerfectGame,
      unlockedAchievements: unlockedAchievements,
    );
    
    // Save locally
    await _saveLocalStatistics();
    
    // Upload to cloud if signed in
    if (_userService.isSignedIn) {
      await _uploadToCloud();
    }
  }

  Future<void> _saveLocalStatistics() async {
    try {
      await _storageService.saveStatistics(_currentStatistics.toJsonString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving local statistics: $e');
      }
    }
  }

  Future<void> startNewSession() async {
    if (!_initialized) {
      await initialize();
    }
    
    _currentStatistics = _currentStatistics.startNewSession();
    await _saveLocalStatistics();
    
    if (_userService.isSignedIn) {
      await _uploadToCloud();
    }
  }

  // Get specific statistics for UI display
  Map<String, dynamic> getDisplayStatistics() {
    return {
      'totalGames': _currentStatistics.totalGamesPlayed,
      'highScore': _currentStatistics.highScore,
      'totalPlayTime': _currentStatistics.totalPlayTimeHours,
      'averageScore': _currentStatistics.averageScore.round(),
      'totalFood': _currentStatistics.totalFoodConsumed,
      'totalPowerUps': _currentStatistics.totalPowerUpsCollected,
      'longestSurvival': _formatDuration(_currentStatistics.longestSurvivalTime),
      'highestLevel': _currentStatistics.highestLevel,
      'winStreak': _currentStatistics.currentWinStreak,
      'longestStreak': _currentStatistics.longestWinStreak,
      'survivalRate': '${(_currentStatistics.survivalRate * 100).round()}%',
      'perfectGames': _currentStatistics.perfectGames,
      'favoriteFood': _currentStatistics.favoriteFood,
      'favoritePowerUp': _currentStatistics.favoritePowerUp,
      'achievementProgress': '${(_currentStatistics.achievementProgress * 100).round()}%',
      'recentScores': _currentStatistics.recentScores,
      'foodBreakdown': _currentStatistics.foodTypeCount,
      'powerUpBreakdown': _currentStatistics.powerUpTypeCount,
      'collisionStats': {
        'wall': _currentStatistics.wallCollisions,
        'self': _currentStatistics.selfCollisions,
        'total': _currentStatistics.totalCollisions,
      },
    };
  }

  // Get performance trends for charts
  Map<String, dynamic> getPerformanceTrends() {
    final recentScores = _currentStatistics.recentScores;
    final trend = _calculateTrend(recentScores);
    
    return {
      'recentScores': recentScores,
      'trend': trend, // 'improving', 'declining', 'stable'
      'averageRecentScore': recentScores.isNotEmpty 
          ? (recentScores.reduce((a, b) => a + b) / recentScores.length).round()
          : 0,
      'bestRecentScore': recentScores.isNotEmpty ? recentScores.reduce((a, b) => a > b ? a : b) : 0,
      'worstRecentScore': recentScores.isNotEmpty ? recentScores.reduce((a, b) => a < b ? a : b) : 0,
    };
  }

  String _calculateTrend(List<int> scores) {
    if (scores.length < 3) return 'stable';
    
    final recent = scores.sublist(scores.length - 3);
    final older = scores.length >= 6 ? scores.sublist(scores.length - 6, scores.length - 3) : scores.sublist(0, scores.length - 3);
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    const threshold = 0.1; // 10% change threshold
    
    if ((recentAvg - olderAvg) / olderAvg > threshold) {
      return 'improving';
    } else if ((olderAvg - recentAvg) / olderAvg > threshold) {
      return 'declining';
    } else {
      return 'stable';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }

  // Get daily/weekly play patterns for charts
  Map<String, dynamic> getPlayPatterns() {
    final dailyPlayTime = _currentStatistics.dailyPlayTime;
    
    // Get last 7 days
    final now = DateTime.now();
    final last7Days = <String, int>{};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      last7Days[_formatDateForChart(date)] = dailyPlayTime[key] ?? 0;
    }
    
    return {
      'dailyPlayTime': last7Days,
      'totalWeeklyTime': last7Days.values.reduce((a, b) => a + b),
      'averageDailyTime': (last7Days.values.reduce((a, b) => a + b) / 7).round(),
      'mostActiveDay': _getMostActiveDay(last7Days),
    };
  }

  String _formatDateForChart(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  String _getMostActiveDay(Map<String, int> dailyData) {
    if (dailyData.isEmpty) return 'None';
    
    final sortedDays = dailyData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedDays.first.key;
  }

  // Reset statistics (for testing or user request)
  Future<void> resetStatistics() async {
    _currentStatistics = GameStatistics.initial();
    await _saveLocalStatistics();
    
    if (_userService.isSignedIn) {
      await _syncService.queueSync('statistics', _currentStatistics.toJson());
    }
  }

  // Force sync with cloud (for manual sync)
  Future<bool> forceSync() async {
    if (!_userService.isSignedIn) return false;
    
    try {
      await _uploadToCloud();
      await _syncService.forceSyncNow();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error in force sync: $e');
      }
      return false;
    }
  }
}