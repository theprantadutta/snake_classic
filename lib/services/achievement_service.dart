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

      // Sync with backend in background — don't block
      if (_connectivityService.isOnline && _apiService.isAuthenticated) {
        _syncWithBackend().catchError((e) {
          if (kDebugMode) {
            print('Background achievement sync failed: $e');
          }
        }); // No await!
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading achievement progress: $e');
      }
    }
  }

  Future<void> _loadFromLocalStorage() async {
    // Try to load from cache first
    Map<String, dynamic>? cached;
    try {
      cached = await _cacheService.getCachedFallback<Map<String, dynamic>>(
        _achievementsKey,
        (data) {
          if (data is Map<String, dynamic>) return data;
          if (data is Map) return Map<String, dynamic>.from(data);
          // Invalid format - throw to trigger fallback
          throw FormatException('Expected Map but got ${data.runtimeType}');
        },
      );
    } catch (e) {
      // Cache read failed (possibly wrong format), continue to fallback
      if (kDebugMode) {
        print('Achievement cache read failed, using fallback: $e');
      }
      cached = null;
    }

    if (cached != null) {
      _updateAchievementsFromData(cached);
    } else {
      // Fall back to storage service
      final localData = await _storageService.getAchievements();
      if (localData != null && localData.isNotEmpty) {
        final decoded = jsonDecode(localData);

        // Handle both Map format (new) and List format (legacy)
        if (decoded is Map<String, dynamic>) {
          _updateAchievementsFromData(decoded);
        } else if (decoded is Map) {
          _updateAchievementsFromData(Map<String, dynamic>.from(decoded));
        } else if (decoded is List) {
          // Legacy format: convert List to Map by achievement id
          final mapData = <String, dynamic>{};
          for (final item in decoded) {
            if (item is Map && item['id'] != null) {
              mapData[item['id'].toString()] = Map<String, dynamic>.from(item);
            }
          }
          if (mapData.isNotEmpty) {
            _updateAchievementsFromData(mapData);
          }
        }
        // Else: unknown format, skip loading (will use defaults)
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

    // Use the batch sync method which handles both online and fallback
    await syncUnlockedAchievements();
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

  /// Unlock an achievement locally only (no API call).
  /// Call [syncUnlockedAchievements] after all checks to batch-sync to backend.
  void _unlockAchievementLocal(int index, Achievement achievement) {
    _achievements[index] = achievement.copyWith(
      isUnlocked: true,
      currentProgress: achievement.targetValue,
      unlockedAt: DateTime.now(),
    );

    if (!_pendingUnlocks.contains(achievement.id)) {
      _pendingUnlocks.add(achievement.id);
    }
  }

  /// Batch-sync all pending achievement unlocks to the backend in a single API call.
  Future<void> syncUnlockedAchievements() async {
    if (_pendingUnlocks.isEmpty) return;

    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      try {
        final updates = <Map<String, dynamic>>[];
        for (final achievementId in _pendingUnlocks) {
          final achievement = getAchievementById(achievementId);
          if (achievement != null) {
            updates.add({
              'achievementId': achievementId,
              'progressIncrement': achievement.targetValue,
            });
          }
        }

        if (updates.isNotEmpty) {
          final success = await _apiService.batchUpdateAchievementProgress(updates);
          if (success) {
            _pendingUnlocks.clear();
            return;
          }
        }
      } catch (e) {
        // Fall through to queue for later sync
        if (kDebugMode) {
          print('Batch achievement sync failed, queuing: $e');
        }
      }
    }

    // Offline or batch failed — queue each for later sync via DataSyncService
    for (final achievementId in List<String>.from(_pendingUnlocks)) {
      final achievement = getAchievementById(achievementId);
      if (achievement != null) {
        await _syncService.queueSync('achievement_$achievementId', {
          'achievementId': achievementId,
          'progress': achievement.targetValue,
        }, priority: SyncPriority.high);
      }
    }
  }

  List<Achievement> checkScoreAchievements(int score) {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.score &&
          !achievement.isUnlocked) {
        if (score >= achievement.targetValue) {
          _unlockAchievementLocal(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else {
          _achievements[i] = achievement.copyWith(currentProgress: score);
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  List<Achievement> checkGamePlayedAchievements(int totalGames) {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.games &&
          !achievement.isUnlocked) {
        if (totalGames >= achievement.targetValue) {
          _unlockAchievementLocal(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else {
          _achievements[i] = achievement.copyWith(currentProgress: totalGames);
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  List<Achievement> checkSurvivalAchievements(int survivalTime) {
    final newUnlocks = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.survival &&
          !achievement.isUnlocked) {
        if (survivalTime >= achievement.targetValue) {
          _unlockAchievementLocal(i, achievement);
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
      _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  List<Achievement> checkSpecialAchievements({
    int? level,
    bool? hitWall,
    bool? hitSelf,
    Set<String>? foodTypesEaten,
    int? noWallGames,
  }) {
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
          _unlockAchievementLocal(i, achievement);
          newUnlocks.add(_achievements[i]);
        } else if (newProgress != achievement.currentProgress) {
          _achievements[i] = achievement.copyWith(currentProgress: newProgress);
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      _saveProgress();
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
