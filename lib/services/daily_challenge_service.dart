import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/offline_cache_service.dart';
import 'package:snake_classic/utils/logger.dart';

class DailyChallengeService extends ChangeNotifier {
  static final DailyChallengeService _instance =
      DailyChallengeService._internal();
  factory DailyChallengeService() => _instance;
  DailyChallengeService._internal();

  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();
  SharedPreferences? _prefs;

  // Cache keys
  static const String _challengesKey = 'daily_challenges';
  static const String _localProgressKey = 'daily_challenges_local_progress';

  List<DailyChallenge> _challenges = [];
  int _completedCount = 0;
  int _totalCount = 0;
  bool _allCompleted = false;
  int _bonusCoins = 0;
  bool _isLoading = false;
  String? _lastLoadDate;

  // Pending progress updates to sync
  final Map<ChallengeType, int> _pendingProgress = {};

  List<DailyChallenge> get challenges => _challenges;
  int get completedCount => _completedCount;
  int get totalCount => _totalCount;
  bool get allCompleted => _allCompleted;
  int get bonusCoins => _bonusCoins;
  bool get isLoading => _isLoading;

  bool get hasUnclaimedRewards =>
      _challenges.any((c) => c.isCompleted && !c.claimedReward);

  int get unclaimedRewardsCount =>
      _challenges.where((c) => c.isCompleted && !c.claimedReward).length;

  Future<void> initialize() async {
    await _loadFromCache();
    // Refresh silently in background — don't block initialization
    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      _refreshInBackground();
    }
  }

  void _refreshInBackground() {
    refreshChallenges().catchError((e) {
      AppLogger.error('Background refresh failed', e);
    });
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await _cacheService
          .getCachedFallback<Map<String, dynamic>>(
            _challengesKey,
            (data) => Map<String, dynamic>.from(data as Map),
          );

      if (cached != null) {
        _updateFromResponse(cached);
      }

      // Load local progress
      await _loadLocalProgress();
    } catch (e) {
      AppLogger.error('Error loading daily challenges from cache', e);
    }
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadLocalProgress() async {
    try {
      await _initPrefs();
      final localProgress = _prefs?.getString(_localProgressKey);
      if (localProgress != null) {
        final data = jsonDecode(localProgress) as Map<String, dynamic>;
        final savedDate = data['date'] as String?;
        final today = DateTime.now().toIso8601String().split('T')[0];

        // Only apply if it's from today
        if (savedDate == today) {
          final progress = Map<String, int>.from(data['progress'] as Map);
          for (final entry in progress.entries) {
            final type = ChallengeType.fromString(entry.key);
            _pendingProgress[type] = entry.value;
          }
        } else {
          // Clear old progress
          await _prefs?.remove(_localProgressKey);
        }
      }
    } catch (e) {
      AppLogger.error('Error loading local progress', e);
    }
  }

  Future<void> _saveLocalProgress() async {
    try {
      await _initPrefs();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final data = {
        'date': today,
        'progress': _pendingProgress.map((k, v) => MapEntry(k.apiValue, v)),
      };
      await _prefs?.setString(_localProgressKey, jsonEncode(data));
    } catch (e) {
      AppLogger.error('Error saving local progress', e);
    }
  }

  Future<void> refreshChallenges() async {
    if (_isLoading) return;

    _isLoading = true;
    // DON'T notifyListeners() here — no spinner

    try {
      if (_connectivityService.isOnline && _apiService.isAuthenticated) {
        final response = await _apiService.getDailyChallenges();
        if (response != null) {
          _updateFromResponse(response);

          // Cache the response with 12h TTL (challenges change once per day)
          await _cacheService.setCache<Map<String, dynamic>>(
            _challengesKey,
            response,
            (data) => data,
            customTtl: const Duration(hours: 12),
          );

          // Sync any pending progress
          await _syncPendingProgress();
        }
      }
    } catch (e) {
      AppLogger.error('Error refreshing daily challenges', e);
    } finally {
      _isLoading = false;
      notifyListeners(); // Only notify ONCE when data is ready
    }
  }

  void _updateFromResponse(Map<String, dynamic> response) {
    try {
      final challengesResponse = DailyChallengesResponse.fromJson(response);
      _challenges = challengesResponse.challenges;
      _completedCount = challengesResponse.completedCount;
      _totalCount = challengesResponse.totalCount;
      _allCompleted = challengesResponse.allCompleted;
      _bonusCoins = challengesResponse.bonusCoins;
      _lastLoadDate = DateTime.now().toIso8601String().split('T')[0];
    } catch (e) {
      AppLogger.error('Error parsing daily challenges response', e);
    }
  }

  /// Update progress for a specific challenge type
  /// Called after each game ends
  Future<void> updateProgress(
    ChallengeType type,
    int value, {
    String? gameMode,
  }) async {
    if (value <= 0) return;

    // Accumulate local progress
    _pendingProgress[type] = (_pendingProgress[type] ?? 0) + value;
    await _saveLocalProgress();

    // Update local challenges optimistically
    _updateLocalProgress(type, value, gameMode: gameMode);

    // Try to sync with backend
    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      try {
        final response = await _apiService.updateChallengeProgress(
          type: type.apiValue,
          value: value,
          gameMode: gameMode,
        );

        if (response != null) {
          // Update challenges from response
          final updatedChallenges = (response['updatedChallenges'] as List?)
              ?.map((c) => DailyChallenge.fromJson(c as Map<String, dynamic>))
              .toList();

          if (updatedChallenges != null) {
            for (final updated in updatedChallenges) {
              final index = _challenges.indexWhere((c) => c.id == updated.id);
              if (index >= 0) {
                _challenges[index] = updated;
              }
            }
          }

          // Check for newly completed
          final newlyCompleted = response['newlyCompletedIds'] as List?;
          if (newlyCompleted != null && newlyCompleted.isNotEmpty) {
            _completedCount = _challenges.where((c) => c.isCompleted).length;
            _allCompleted = _completedCount == _totalCount && _totalCount > 0;
            AppLogger.info(
              'Daily challenges completed: ${newlyCompleted.length}',
            );
          }

          // Clear pending progress for synced type
          _pendingProgress.remove(type);
          await _saveLocalProgress();
        }
      } catch (e) {
        AppLogger.error('Error syncing challenge progress', e);
        // Keep in pending for later sync
      }
    }

    notifyListeners();
  }

  /// Batch update progress for multiple challenge types in a single API call.
  /// Each entry: {type: ChallengeType, value: int, gameMode: String?}
  Future<void> updateProgressBatch(
    List<({ChallengeType type, int value, String? gameMode})> updates,
  ) async {
    if (updates.isEmpty) return;

    // Apply all local progress updates first (instant)
    for (final update in updates) {
      if (update.value <= 0) continue;
      _pendingProgress[update.type] =
          (_pendingProgress[update.type] ?? 0) + update.value;
      _updateLocalProgress(update.type, update.value, gameMode: update.gameMode);
    }
    await _saveLocalProgress();

    // Try batch sync with backend
    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      try {
        final apiUpdates = updates
            .where((u) => u.value > 0)
            .map((u) => <String, dynamic>{
                  'type': u.type.apiValue,
                  'value': u.value,
                  if (u.gameMode != null) 'gameMode': u.gameMode,
                })
            .toList();

        final response =
            await _apiService.batchUpdateChallengeProgress(apiUpdates);

        if (response != null) {
          // Update challenges from response
          final updatedChallenges = (response['updatedChallenges'] as List?)
              ?.map((c) => DailyChallenge.fromJson(c as Map<String, dynamic>))
              .toList();

          if (updatedChallenges != null) {
            for (final updated in updatedChallenges) {
              final index = _challenges.indexWhere((c) => c.id == updated.id);
              if (index >= 0) {
                _challenges[index] = updated;
              }
            }
          }

          // Check for newly completed
          final newlyCompleted = response['newlyCompletedIds'] as List?;
          if (newlyCompleted != null && newlyCompleted.isNotEmpty) {
            _completedCount = _challenges.where((c) => c.isCompleted).length;
            _allCompleted = _completedCount == _totalCount && _totalCount > 0;
            AppLogger.info(
              'Daily challenges completed: ${newlyCompleted.length}',
            );
          }

          // Clear pending progress for synced types
          for (final update in updates) {
            _pendingProgress.remove(update.type);
          }
          await _saveLocalProgress();
        }
      } catch (e) {
        AppLogger.error('Error batch syncing challenge progress', e);
        // Keep in pending for later sync
      }
    }

    notifyListeners();
  }

  void _updateLocalProgress(ChallengeType type, int value, {String? gameMode}) {
    for (int i = 0; i < _challenges.length; i++) {
      final challenge = _challenges[i];

      if (challenge.type != type) continue;
      if (challenge.isCompleted) continue;

      // Check game mode match if required
      if (type == ChallengeType.gameMode &&
          challenge.requiredGameMode != null &&
          gameMode != null &&
          challenge.requiredGameMode!.toLowerCase() != gameMode.toLowerCase()) {
        continue;
      }

      // Calculate new progress
      int newProgress;
      if (type == ChallengeType.score || type == ChallengeType.survival) {
        // Take max value for score/survival
        newProgress = value > challenge.currentProgress
            ? value
            : challenge.currentProgress;
      } else {
        // Accumulate for food/games
        newProgress = challenge.currentProgress + value;
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

  Future<void> _syncPendingProgress() async {
    if (_pendingProgress.isEmpty) return;

    for (final entry in Map.from(_pendingProgress).entries) {
      try {
        await _apiService.updateChallengeProgress(
          type: entry.key.apiValue,
          value: entry.value,
        );
        _pendingProgress.remove(entry.key);
      } catch (e) {
        AppLogger.error('Error syncing pending progress for ${entry.key}', e);
      }
    }

    await _saveLocalProgress();
  }

  /// Claim reward for a completed challenge (optimistic update)
  Future<bool> claimReward(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index < 0) return false;

    final challenge = _challenges[index];
    if (!challenge.isCompleted || challenge.claimedReward) return false;

    // Optimistic local update FIRST
    _challenges[index] = challenge.copyWith(claimedReward: true);
    notifyListeners();

    // Sync with backend in background
    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      try {
        final response = await _apiService.claimChallengeReward(challengeId);
        if (response != null) {
          final bonus = response['bonusCoins'] as int? ?? 0;
          if (bonus > 0) {
            _bonusCoins = bonus;
            AppLogger.info('All challenges completed! Bonus: $bonus coins');
          }
          notifyListeners();
        }
      } catch (e) {
        AppLogger.error('Error claiming challenge reward', e);
        // Queue for retry — local state already updated
        DataSyncService().queueSync('challenge_claim', {
          'challengeId': challengeId,
          'claimed_at': DateTime.now().toIso8601String(),
        }, priority: SyncPriority.high);
      }
    } else {
      // Offline — queue for sync
      DataSyncService().queueSync('challenge_claim', {
        'challengeId': challengeId,
        'claimed_at': DateTime.now().toIso8601String(),
      }, priority: SyncPriority.high);
    }

    return true; // Always succeeds locally
  }

  /// Claim all unclaimed rewards
  Future<int> claimAllRewards() async {
    int totalClaimed = 0;

    for (final challenge in _challenges) {
      if (challenge.canClaim) {
        final success = await claimReward(challenge.id);
        if (success) {
          totalClaimed += challenge.coinReward;
        }
      }
    }

    return totalClaimed;
  }

  /// Force sync with backend
  Future<void> syncWithBackend() async {
    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      await _syncPendingProgress();
      await refreshChallenges();
    }
  }

  /// Check if we need to refresh (new day)
  bool get needsRefresh {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _lastLoadDate != today || _challenges.isEmpty;
  }

  /// Get challenge by ID
  DailyChallenge? getChallengeById(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _initPrefs();
    await _cacheService.invalidateCache(_challengesKey);
    await _prefs?.remove(_localProgressKey);
    _challenges = [];
    _pendingProgress.clear();
    notifyListeners();
  }
}
