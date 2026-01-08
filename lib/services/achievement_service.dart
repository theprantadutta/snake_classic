import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/offline_cache_service.dart';
import 'package:snake_classic/services/storage_service.dart';

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();
  final DataSyncService _syncService = DataSyncService();

  // Cache key
  static const String _achievementsKey = 'user_achievements';
  static const String _achievementsMetadataKey = 'achievements_metadata';

  List<Achievement> _achievements = [];
  final List<Achievement> _recentUnlocks = [];
  final List<String> _pendingUnlocks = []; // Achievements unlocked offline

  List<Achievement> get achievements => _achievements;
  List<Achievement> get recentUnlocks => _recentUnlocks;
  bool get hasPendingUnlocks => _pendingUnlocks.isNotEmpty;

  int get totalAchievementPoints => _achievements
      .where((a) => a.isUnlocked)
      .fold(0, (total, a) => total + a.points);

  double get completionPercentage => _achievements.isEmpty
      ? 0.0
      : _achievements.where((a) => a.isUnlocked).length / _achievements.length;

  Future<void> initialize() async {
    _achievements = Achievement.getDefaultAchievements();
    await _loadUserProgress();
    notifyListeners();
  }

  Future<void> _loadUserProgress() async {
    try {
      // First load from local cache/storage
      await _loadFromLocalStorage();

      // Then try to sync with backend if online
      if (_connectivityService.isOnline && _apiService.isAuthenticated) {
        await _syncWithBackend();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading achievement progress: $e');
      }
    }
  }

  Future<void> _loadFromLocalStorage() async {
    // Try to load from cache first
    final cached = await _cacheService.getCachedFallback<Map<String, dynamic>>(
      _achievementsKey,
      (data) => Map<String, dynamic>.from(data as Map),
    );

    if (cached != null) {
      _updateAchievementsFromData(cached);
    } else {
      // Fall back to storage service
      final localData = await _storageService.getAchievements();
      if (localData != null && localData.isNotEmpty) {
        _updateAchievementsFromData(jsonDecode(localData));
      }
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final response = await _apiService.getUserAchievements();

      if (response != null && response['achievements'] != null) {
        final backendAchievements = List<Map<String, dynamic>>.from(
          response['achievements'],
        );
        _updateAchievementsFromBackend(backendAchievements);

        // Cache the synced data
        await _saveProgress();
      }

      // Sync any pending offline unlocks
      await _syncPendingUnlocks();
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing achievements with backend: $e');
      }
    }
  }

  Future<void> _syncPendingUnlocks() async {
    if (_pendingUnlocks.isEmpty || !_connectivityService.isOnline) return;

    final synced = <String>[];

    for (final achievementId in _pendingUnlocks) {
      final achievement = getAchievementById(achievementId);
      if (achievement != null && achievement.isUnlocked) {
        try {
          await _apiService.updateAchievementProgress(
            achievementId: achievementId,
            progressIncrement: achievement.targetValue,
          );
          synced.add(achievementId);
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync achievement $achievementId: $e');
          }
        }
      }
    }

    _pendingUnlocks.removeWhere((id) => synced.contains(id));
  }

  void _updateAchievementsFromBackend(
    List<Map<String, dynamic>> backendAchievements,
  ) {
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      // Find matching backend achievement
      final backendData = backendAchievements.firstWhere(
        (a) =>
            a['achievement_id'] == achievement.id ||
            a['achievementId'] == achievement.id,
        orElse: () => {},
      );

      if (backendData.isNotEmpty) {
        final backendUnlocked =
            backendData['is_unlocked'] ?? backendData['isUnlocked'] ?? false;
        final backendProgress =
            backendData['current_progress'] ??
            backendData['currentProgress'] ??
            0;
        final backendUnlockedAt = backendData['unlocked_at'] != null
            ? DateTime.tryParse(backendData['unlocked_at'].toString())
            : backendData['unlockedAt'] != null
            ? DateTime.tryParse(backendData['unlockedAt'].toString())
            : null;

        // Use the most up-to-date data (local wins if unlocked locally but not synced yet)
        final shouldUseLocal = achievement.isUnlocked && !backendUnlocked;

        if (!shouldUseLocal) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: backendUnlocked,
            currentProgress: backendProgress,
            unlockedAt: backendUnlockedAt,
          );
        }
      }
    }
  }

  void _updateAchievementsFromData(Map<String, dynamic> data) {
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      final savedData = data[achievement.id] as Map<String, dynamic>?;

      if (savedData != null) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: savedData['isUnlocked'] ?? false,
          currentProgress: savedData['currentProgress'] ?? 0,
          unlockedAt: savedData['unlockedAt'] != null
              ? DateTime.parse(savedData['unlockedAt'])
              : null,
        );
      }
    }
  }

  Future<void> _saveProgress() async {
    try {
      final progressData = <String, dynamic>{};

      for (final achievement in _achievements) {
        progressData[achievement.id] = {
          'isUnlocked': achievement.isUnlocked,
          'currentProgress': achievement.currentProgress,
          'unlockedAt': achievement.unlockedAt?.toIso8601String(),
        };
      }

      // Save to cache
      await _cacheService.setCache<Map<String, dynamic>>(
        _achievementsKey,
        progressData,
        (data) => data,
        customTtl: const Duration(minutes: 1),
      );

      // Also save to local storage as backup
      await _storageService.saveAchievements(jsonEncode(progressData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving achievement progress: $e');
      }
    }
  }

  /// Unlock an achievement locally and queue for sync
  Future<void> _unlockAchievement(int index, Achievement achievement) async {
    _achievements[index] = achievement.copyWith(
      isUnlocked: true,
      currentProgress: achievement.targetValue,
      unlockedAt: DateTime.now(),
    );

    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      // Sync immediately
      try {
        await _apiService.updateAchievementProgress(
          achievementId: achievement.id,
          progressIncrement: achievement.targetValue,
        );
      } catch (e) {
        // Queue for later sync
        if (!_pendingUnlocks.contains(achievement.id)) {
          _pendingUnlocks.add(achievement.id);
        }
        // Also queue in sync service
        await _syncService.queueSync('achievement_${achievement.id}', {
          'achievementId': achievement.id,
          'progress': achievement.targetValue,
        }, priority: SyncPriority.high);
      }
    } else {
      // Offline - queue for later sync
      if (!_pendingUnlocks.contains(achievement.id)) {
        _pendingUnlocks.add(achievement.id);
      }
    }
  }

  Future<List<Achievement>> checkScoreAchievements(int score) async {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.score &&
          !achievement.isUnlocked) {
        if (score >= achievement.targetValue) {
          await _unlockAchievement(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else {
          _achievements[i] = achievement.copyWith(currentProgress: score);
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  Future<List<Achievement>> checkGamePlayedAchievements(int totalGames) async {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.games &&
          !achievement.isUnlocked) {
        if (totalGames >= achievement.targetValue) {
          await _unlockAchievement(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else {
          _achievements[i] = achievement.copyWith(currentProgress: totalGames);
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  Future<List<Achievement>> checkSurvivalAchievements(int survivalTime) async {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.survival &&
          !achievement.isUnlocked) {
        if (survivalTime >= achievement.targetValue) {
          await _unlockAchievement(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else if (survivalTime > achievement.currentProgress) {
          _achievements[i] = achievement.copyWith(
            currentProgress: survivalTime,
          );
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  Future<List<Achievement>> checkSpecialAchievements({
    int? level,
    bool? hitWall,
    bool? hitSelf,
    Set<String>? foodTypesEaten,
    int? noWallGames,
  }) async {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.special &&
          !achievement.isUnlocked) {
        bool shouldUnlock = false;
        int newProgress = achievement.currentProgress;

        switch (achievement.id) {
          case 'speedster':
            if (level != null && level >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (level != null) {
              newProgress = level;
            }
            break;

          case 'no_walls':
            if (noWallGames != null && noWallGames >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (noWallGames != null) {
              newProgress = noWallGames;
            }
            break;

          case 'perfectionist':
            if (hitSelf == false && hitWall != true) {
              shouldUnlock = true;
              newProgress = 1;
            }
            break;

          case 'all_food_types':
            if (foodTypesEaten != null && foodTypesEaten.length >= 3) {
              shouldUnlock = true;
              newProgress = 1;
            }
            break;
        }

        if (shouldUnlock) {
          await _unlockAchievement(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else if (newProgress != achievement.currentProgress) {
          _achievements[i] = achievement.copyWith(currentProgress: newProgress);
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  /// Force sync with backend (when coming online)
  Future<void> syncWithBackend() async {
    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      await _syncWithBackend();
      notifyListeners();
    }
  }

  void clearRecentUnlocks() {
    _recentUnlocks.clear();
    notifyListeners();
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return _achievements.where((a) => a.rarity == rarity).toList();
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  /// Clear cache (for debugging/testing)
  Future<void> clearCache() async {
    await _cacheService.invalidateCache(_achievementsKey);
    await _cacheService.invalidateCache(_achievementsMetadataKey);
  }
}
