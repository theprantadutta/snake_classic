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

  /// Reserved key inside the saved progress JSON for persisting
  /// `_pendingUnlocks` across app restarts. Without this the list lives
  /// in memory only, so an unlock-then-crash flow loses the backend sync.
  static const String _pendingUnlocksJsonKey = '__pendingUnlocks';
  static const int _recentUnlocksMaxLength = 20;

  List<Achievement> _achievements = [];
  final List<Achievement> _recentUnlocks = [];
  final List<String> _pendingUnlocks = []; // Achievements unlocked offline
  /// Achievements unlocked during the most recent gameplay session.
  /// Reset by [resetLastGameUnlocks] at game start; populated by
  /// [_unlockAchievementLocal]. The game-over screen reads this to show
  /// celebration toasts only for the current game's unlocks.
  final List<Achievement> _lastGameUnlocks = [];

  List<Achievement> get achievements => _achievements;
  List<Achievement> get recentUnlocks => _recentUnlocks;
  List<Achievement> get lastGameUnlocks => List.unmodifiable(_lastGameUnlocks);
  bool get hasPendingUnlocks => _pendingUnlocks.isNotEmpty;

  /// Clear the per-game unlock list. Call at game start so that
  /// `lastGameUnlocks` only reflects this game's unlocks.
  void resetLastGameUnlocks() {
    _lastGameUnlocks.clear();
  }

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

      // Claim XP + coin rewards for any unlocks the server confirmed but
      // hasn't yet credited. The backend's ClaimAchievementRewardCommand
      // increments user.coins and user.experience atomically.
      await _claimUnclaimedRewards();
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing achievements with backend: $e');
      }
    }
  }

  /// POST /achievements/claim for every achievement that is server-unlocked
  /// but not yet reward-claimed. Idempotent — the server rejects repeat
  /// claims, and our local `rewardClaimed` flag is updated only on success
  /// so a failed claim retries on the next sync.
  Future<void> _claimUnclaimedRewards() async {
    if (!_connectivityService.isOnline || !_apiService.isAuthenticated) {
      return;
    }

    bool anyClaimed = false;
    for (int i = 0; i < _achievements.length; i++) {
      final a = _achievements[i];
      if (!a.isUnlocked || a.rewardClaimed) continue;

      try {
        final result = await _apiService.claimAchievementReward(a.id);
        if (result != null) {
          _achievements[i] = a.copyWith(rewardClaimed: true);
          anyClaimed = true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error claiming achievement ${a.id}: $e');
        }
        // Don't break — try the next one. Failed claims retry next sync.
      }
    }

    if (anyClaimed) {
      await _saveProgress();
      notifyListeners();
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
    // The /achievements/me payload shape is:
    //   { achievements: [{ id, achievement: { achievement_id, xp_reward,
    //     coin_reward, ... }, current_progress, is_unlocked, unlocked_at,
    //     reward_claimed }] }
    // Earlier this method looked for `achievement_id` at the top level —
    // which never matched, so the merge silently no-op'd. Fixed below to
    // read the nested catalog object.
    String? idOf(Map<String, dynamic> entry) {
      final nested = entry['achievement'];
      if (nested is Map) {
        return (nested['achievement_id'] ?? nested['achievementId'])?.toString();
      }
      return (entry['achievement_id'] ?? entry['achievementId'])?.toString();
    }

    Map<String, dynamic> catalogOf(Map<String, dynamic> entry) {
      final nested = entry['achievement'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return entry;
    }

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      final backendData = backendAchievements.firstWhere(
        (a) => idOf(a) == achievement.id,
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
        final backendRewardClaimed =
            backendData['reward_claimed'] ??
            backendData['rewardClaimed'] ??
            false;

        final catalog = catalogOf(backendData);
        final backendXp = catalog['xp_reward'] ?? catalog['xpReward'];
        final backendCoins = catalog['coin_reward'] ?? catalog['coinReward'];

        // Use the most up-to-date data (local wins if unlocked locally but not synced yet)
        final shouldUseLocal = achievement.isUnlocked && !backendUnlocked;

        if (!shouldUseLocal) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: backendUnlocked,
            currentProgress: backendProgress,
            unlockedAt: backendUnlockedAt,
            rewardClaimed: backendRewardClaimed,
            // Overlay backend reward values when present so the UI shows
            // authoritative amounts; fall back to the seeded defaults.
            xpReward: backendXp is int ? backendXp : null,
            coinReward: backendCoins is int ? backendCoins : null,
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
          rewardClaimed: savedData['rewardClaimed'] ?? false,
        );
      }
    }

    // Restore pending offline unlocks so a crashed sync resumes on next launch.
    final pending = data[_pendingUnlocksJsonKey];
    if (pending is List) {
      _pendingUnlocks
        ..clear()
        ..addAll(pending.whereType<String>());
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
          'rewardClaimed': achievement.rewardClaimed,
        };
      }

      // Persist pending offline unlocks so they survive an app crash before
      // syncUnlockedAchievements() flushes to the backend.
      if (_pendingUnlocks.isNotEmpty) {
        progressData[_pendingUnlocksJsonKey] = List<String>.from(_pendingUnlocks);
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
  ///
  /// Only `special` achievements queue for explicit backend sync. Score /
  /// games / survival unlocks are derived server-side from the score submit
  /// (see AchievementAutoEvaluator on the backend); the local check just
  /// drives immediate UI feedback. Posting them anyway would be redundant
  /// and re-opens the self-report exploit the server-side eval closes.
  void _unlockAchievementLocal(int index, Achievement achievement) {
    _achievements[index] = achievement.copyWith(
      isUnlocked: true,
      currentProgress: achievement.targetValue,
      unlockedAt: DateTime.now(),
    );

    if (achievement.type == AchievementType.special &&
        !_pendingUnlocks.contains(achievement.id)) {
      _pendingUnlocks.add(achievement.id);
    }
    _lastGameUnlocks.add(_achievements[index]);
  }

  /// Trim `_recentUnlocks` so it never exceeds [_recentUnlocksMaxLength].
  /// Called after each check method adds new unlocks.
  void _trimRecentUnlocks() {
    while (_recentUnlocks.length > _recentUnlocksMaxLength) {
      _recentUnlocks.removeAt(0);
    }
  }

  /// Batch-sync all pending achievement unlocks to the backend in a single API call.
  ///
  /// Only special-category achievements are eligible to be pushed. Score /
  /// games / survival unlocks are evaluated authoritatively by the backend
  /// from the score submission (see AchievementAutoEvaluator). Any non-special
  /// IDs in [_pendingUnlocks] (e.g. stale state from before this constraint
  /// was added) are stripped here and not retried.
  Future<void> syncUnlockedAchievements() async {
    // Filter out any non-special IDs that may have been persisted before
    // the special-only invariant was enforced in [_unlockAchievementLocal].
    _pendingUnlocks.removeWhere((id) {
      final a = getAchievementById(id);
      return a == null || a.type != AchievementType.special;
    });

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
            // Persist the cleared state so a crash after this point doesn't
            // resurrect already-synced unlocks on next launch.
            await _saveProgress();
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
      _trimRecentUnlocks();
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
      _trimRecentUnlocks();
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
      _trimRecentUnlocks();
      _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  /// Per-game achievement checks — peak metrics observable at game-end
  /// but not derivable from the score submission alone. Called from
  /// `GameCubit._trackGameEndLocal` immediately after the game ends so
  /// the toast can fire at the same time as the game-over screen.
  List<Achievement> checkSpecialAchievements({
    int? level,
    bool? hitWall,
    bool? hitSelf,
    Set<String>? foodTypesEaten,
    int? noWallGames,
    int? maxCombo,
    int? snakeLength,
    DateTime? gameEndTime,
  }) {
    final newUnlocks = <Achievement>[];
    final hourOfDay = gameEndTime?.hour;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];

      if (achievement.type == AchievementType.special &&
          !achievement.isUnlocked) {
        bool shouldUnlock = false;
        int newProgress = achievement.currentProgress;

        switch (achievement.id) {
          // -------- existing 4 --------
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

          // -------- combo (max combo this game) --------
          case 'combo_starter':
          case 'combo_master':
          case 'combo_pro':
          case 'combo_god':
          case 'combo_legend':
            if (maxCombo != null && maxCombo >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (maxCombo != null && maxCombo > achievement.currentProgress) {
              newProgress = maxCombo;
            }
            break;

          // -------- snake length (final length this game) --------
          case 'growing_snake':
          case 'big_snake':
          case 'huge_snake':
          case 'massive_snake':
          case 'anaconda':
            if (snakeLength != null && snakeLength >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (snakeLength != null && snakeLength > achievement.currentProgress) {
              newProgress = snakeLength;
            }
            break;

          // -------- in-game level (peak level this game) --------
          // velocity=15, mach_speed=20, cosmic_snake=25
          case 'velocity':
          case 'mach_speed':
          case 'cosmic_snake':
            if (level != null && level >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (level != null && level > achievement.currentProgress) {
              newProgress = level;
            }
            break;

          // -------- time of day --------
          case 'night_owl':
            if (hourOfDay != null && hourOfDay >= 0 && hourOfDay < 5) {
              shouldUnlock = true;
              newProgress = 1;
            }
            break;

          case 'early_bird':
            if (hourOfDay != null && hourOfDay >= 5 && hourOfDay < 8) {
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
      _trimRecentUnlocks();
      _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  /// Lifetime-stat achievement checks — fed by the post-update
  /// `GameStatistics`. Called from `GameCubit._postGameSync` after
  /// `recordGameResult` so the values reflect the just-finished game.
  ///
  /// Covers categories R/S/T/U/W of the catalog plus weekend tracking:
  ///   * Power-ups: total + per-type + variety (first_power_up..power_master,
  ///     variety_pack, speed_demon, immortal_streak)
  ///   * Food variety: special_diet, bonus_hunter
  ///   * Perfection: untouchable_5/20/50
  ///   * Streaks: hot_streak/on_fire/unstoppable (win streak),
  ///     daily_three/week_warrior (consecutive-day streak)
  ///   * Weekend warrior
  List<Achievement> checkLifetimeAchievements({
    required int totalPowerUps,
    required Map<String, int> powerUpTypeCount,
    required Map<String, int> foodTypeCount,
    required int perfectGames,
    required int currentWinStreak,
    required Map<String, int> dailyPlayTime,
  }) {
    final newUnlocks = <Achievement>[];

    final distinctPowerUpTypes = powerUpTypeCount.keys
        .where((k) => (powerUpTypeCount[k] ?? 0) > 0)
        .length;
    final speedBoostCount = powerUpTypeCount['speedBoost'] ?? 0;
    final invincibilityCount = powerUpTypeCount['invincibility'] ?? 0;
    final totalSpecialFoods = foodTypeCount['special'] ?? 0;
    final totalBonusFoods = foodTypeCount['bonus'] ?? 0;
    final consecutiveDays = _consecutiveDayStreak(dailyPlayTime);
    final weekendDaysPlayed = _weekendDaysPlayed(dailyPlayTime);

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;
      int newProgress = achievement.currentProgress;

      switch (achievement.id) {
        // Lifetime power-up totals
        case 'first_power_up':
        case 'power_player':
        case 'power_hungry':
        case 'power_addict':
        case 'power_master':
          if (totalPowerUps >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (totalPowerUps > achievement.currentProgress) {
            newProgress = totalPowerUps;
          }
          break;

        case 'variety_pack':
          if (distinctPowerUpTypes >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (distinctPowerUpTypes > achievement.currentProgress) {
            newProgress = distinctPowerUpTypes;
          }
          break;

        case 'speed_demon':
          if (speedBoostCount >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (speedBoostCount > achievement.currentProgress) {
            newProgress = speedBoostCount;
          }
          break;

        case 'immortal_streak':
          if (invincibilityCount >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (invincibilityCount > achievement.currentProgress) {
            newProgress = invincibilityCount;
          }
          break;

        // Food type variety lifetime
        case 'special_diet':
          if (totalSpecialFoods >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (totalSpecialFoods > achievement.currentProgress) {
            newProgress = totalSpecialFoods;
          }
          break;

        case 'bonus_hunter':
          if (totalBonusFoods >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (totalBonusFoods > achievement.currentProgress) {
            newProgress = totalBonusFoods;
          }
          break;

        // Perfection lifetime
        case 'untouchable_5':
        case 'untouchable_20':
        case 'untouchable_50':
          if (perfectGames >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (perfectGames > achievement.currentProgress) {
            newProgress = perfectGames;
          }
          break;

        // Game streaks
        case 'hot_streak':
        case 'on_fire':
        case 'unstoppable':
          if (currentWinStreak >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (currentWinStreak > achievement.currentProgress) {
            newProgress = currentWinStreak;
          }
          break;

        // Daily streaks
        case 'daily_three':
        case 'week_warrior':
          if (consecutiveDays >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (consecutiveDays > achievement.currentProgress) {
            newProgress = consecutiveDays;
          }
          break;

        // Weekend warrior — counts weekend days played (each day = at
        // least one game), close enough to "weekend games" for the spirit
        // of the achievement without a dedicated counter.
        case 'weekend_warrior':
          if (weekendDaysPlayed >= achievement.targetValue) {
            shouldUnlock = true;
            newProgress = achievement.targetValue;
          } else if (weekendDaysPlayed > achievement.currentProgress) {
            newProgress = weekendDaysPlayed;
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

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      _trimRecentUnlocks();
      _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  /// Compute the length of the consecutive-day streak ending today
  /// (inclusive). 0 if today wasn't played.
  int _consecutiveDayStreak(Map<String, int> dailyPlayTime) {
    if (dailyPlayTime.isEmpty) return 0;
    final today = DateTime.now();
    int streak = 0;
    for (int back = 0; back < 366; back++) {
      final d = today.subtract(Duration(days: back));
      final key = '${d.year}-${d.month}-${d.day}';
      if (dailyPlayTime.containsKey(key) && (dailyPlayTime[key] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Count distinct Saturdays + Sundays present in [dailyPlayTime].
  int _weekendDaysPlayed(Map<String, int> dailyPlayTime) {
    int count = 0;
    for (final entry in dailyPlayTime.entries) {
      if ((entry.value) <= 0) continue;
      final parts = entry.key.split('-');
      if (parts.length != 3) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) continue;
      final wd = DateTime(y, m, d).weekday;
      if (wd == DateTime.saturday || wd == DateTime.sunday) count++;
    }
    return count;
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
