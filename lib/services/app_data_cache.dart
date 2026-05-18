import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/daily_challenge_service.dart';
import 'package:snake_classic/services/leaderboard_service.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/tournament_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Centralized data cache that preloads all app data at startup.
///
/// This service loads ALL data concurrently during LoadingScreen so that
/// screens display instantly without loading indicators.
class AppDataCache extends ChangeNotifier {
  static final AppDataCache _instance = AppDataCache._internal();
  factory AppDataCache() => _instance;
  AppDataCache._internal();

  // === Cached Data ===

  // Statistics & Profile
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _performanceTrends;
  Map<String, dynamic>? _playPatterns;
  List<Achievement>? _recentAchievements;
  List<String>? _replayKeys;

  // Settings
  Map<String, dynamic>? _settingsData;

  // Daily Challenges
  List<DailyChallenge>? _dailyChallenges;

  // Leaderboards
  List<Map<String, dynamic>>? _globalLeaderboard;
  List<Map<String, dynamic>>? _weeklyLeaderboard;
  List<Map<String, dynamic>>? _dailyLeaderboard;
  List<Map<String, dynamic>>? _friendsLeaderboard;

  // Tournaments
  List<Tournament>? _activeTournaments;
  List<Tournament>? _historyTournaments;

  // Social
  List<UserProfile>? _friendsList;
  List<FriendRequest>? _friendRequests;

  bool _isFullyLoaded = false;
  bool _isLoading = false;
  DateTime? _lastRefreshTime;
  static const Duration _refreshThrottle = Duration(seconds: 60);

  // === Public Getters (instant access) ===

  bool get isFullyLoaded => _isFullyLoaded;
  bool get isLoading => _isLoading;
  DateTime? get lastRefreshTime => _lastRefreshTime;

  /// Returns true if data was refreshed recently (within throttle window)
  bool get isRecentlyRefreshed =>
      _lastRefreshTime != null &&
      DateTime.now().difference(_lastRefreshTime!) < _refreshThrottle;

  Map<String, dynamic>? get statistics => _statistics;
  Map<String, dynamic>? get performanceTrends => _performanceTrends;
  Map<String, dynamic>? get playPatterns => _playPatterns;
  List<Achievement>? get recentAchievements => _recentAchievements;
  List<String>? get replayKeys => _replayKeys;
  Map<String, dynamic>? get settingsData => _settingsData;
  List<DailyChallenge>? get dailyChallenges => _dailyChallenges;
  List<Map<String, dynamic>>? get globalLeaderboard => _globalLeaderboard;
  List<Map<String, dynamic>>? get weeklyLeaderboard => _weeklyLeaderboard;
  List<Map<String, dynamic>>? get dailyLeaderboard => _dailyLeaderboard;
  List<Map<String, dynamic>>? get friendsLeaderboard => _friendsLeaderboard;
  List<Tournament>? get activeTournaments => _activeTournaments;
  List<Tournament>? get historyTournaments => _historyTournaments;
  List<UserProfile>? get friendsList => _friendsList;
  List<FriendRequest>? get friendRequests => _friendRequests;

  /// Called by LoadingScreen - loads ALL data concurrently for maximum speed
  Future<void> preloadAll() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      // Load ALL data in parallel using Future.wait. Network groups use a
      // 4-second per-call timeout; if a backend group is slower than that
      // the loading screen no longer waits for it. The screen-level TTL
      // refresh on each provider will pick up the data later in the
      // background. Trade-off: a flaky connection might leave a cache miss
      // on first paint (skeletons / loading text shown) but the user reaches
      // the home screen up to ~4s sooner per slow endpoint.
      await Future.wait([
        // Group 1: Local data (fast, no timeout needed)
        _loadStatistics(),
        _loadRecentAchievements(),
        _loadReplayKeys(),
        _loadSettingsData(),
        _loadDailyChallenges(),

        // Group 2: Network data (with timeout + fallback)
        _loadLeaderboards().timeout(const Duration(seconds: 4), onTimeout: () {
          AppLogger.warning('AppDataCache: Leaderboards timed out');
        }),
        _loadTournaments().timeout(const Duration(seconds: 4), onTimeout: () {
          AppLogger.warning('AppDataCache: Tournaments timed out');
        }),
        _loadSocialData().timeout(const Duration(seconds: 4), onTimeout: () {
          AppLogger.warning('AppDataCache: Social data timed out');
        }),
      ]);

      _isFullyLoaded = true;
      _lastRefreshTime = DateTime.now();
      AppLogger.success('AppDataCache: All data preloaded successfully');
    } catch (e) {
      AppLogger.error('AppDataCache: Error during preload', e);
      // Even if some fail, mark as loaded so screens can still function
      _isFullyLoaded = true;
      _lastRefreshTime = DateTime.now();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Private Loaders (all run concurrently) ===

  Future<void> _loadStatistics() async {
    try {
      final statsService = getIt<StatisticsService>();
      await statsService.initialize();
      _statistics = statsService.getDisplayStatistics();
      _performanceTrends = statsService.getPerformanceTrends();
      _playPatterns = statsService.getPlayPatterns();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Stats load warning: $e');
    }
  }

  Future<void> _loadRecentAchievements() async {
    try {
      final service = getIt<AchievementService>();
      // Get the 3 most recently unlocked achievements
      final unlocked = service.getUnlockedAchievements();
      unlocked.sort((a, b) {
        final aTime = a.unlockedAt ?? DateTime(1970);
        final bTime = b.unlockedAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
      _recentAchievements = unlocked.take(3).toList();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Achievements load warning: $e');
    }
  }

  Future<void> _loadReplayKeys() async {
    try {
      final storageService = getIt<StorageService>();
      _replayKeys = await storageService.getReplayKeys();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Replays load warning: $e');
    }
  }

  Future<void> _loadSettingsData() async {
    try {
      final storage = getIt<StorageService>();
      // Load all settings concurrently
      final results = await Future.wait([
        storage.getBoardSize(),
        storage.getCrashFeedbackDuration(),
        storage.isDPadEnabled(),
        storage.getDPadPosition(),
        storage.isScreenShakeEnabled(),
      ]);
      _settingsData = {
        'boardSize': results[0],
        'crashFeedbackDuration': results[1],
        'dPadEnabled': results[2],
        'dPadPosition': results[3],
        'screenShakeEnabled': results[4],
      };
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Settings load warning: $e');
    }
  }

  Future<void> _loadDailyChallenges() async {
    try {
      final service = DailyChallengeService();
      await service.initialize();
      // service.initialize() reads from the local Drift cache and fires a
      // network refresh in the background. The refresh wasn't being awaited
      // here, so on a fresh install or after a new day rolled over we'd
      // capture an empty _challenges list and every screen would fall back
      // to its loading path. Explicitly await one refresh attempt with a
      // tight timeout so the cache holds real data on first paint, but
      // never block the loading screen for more than 4 s if the server is
      // slow or unreachable.
      try {
        await service
            .refreshChallenges()
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // Fall through with whatever the local cache + ongoing background
        // refresh produced. The provider can still skeleton/retry later.
      }
      _dailyChallenges = service.challenges;
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Daily challenges load warning: $e');
    }
  }

  Future<void> _loadLeaderboards() async {
    // Critical: per-list try/catch leaves the field NULL on fetch failure
    // (not []). Per-screen providers distinguish 'preload got data' from
    // 'preload failed' by checking `!= null`, and storing [] disguises
    // failure as success — which is why the leaderboard tabs were
    // showing 'No scores yet' permanently on a slow first launch.
    final service = LeaderboardService();
    try {
      _globalLeaderboard = await service.getGlobalLeaderboard(limit: 100);
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Global leaderboard load failed: $e');
      // Leave _globalLeaderboard as null so the provider falls through
      // to a fresh fetch with proper loading + error UX.
    }
    try {
      _weeklyLeaderboard = await service.getWeeklyLeaderboard(limit: 100);
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Weekly leaderboard load failed: $e');
    }
    try {
      _dailyLeaderboard = await service.getDailyLeaderboard(limit: 100);
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Daily leaderboard load failed: $e');
    }
    // Friends leaderboard requires friend IDs and is loaded on-demand.
    _friendsLeaderboard = [];
  }

  Future<void> _loadTournaments() async {
    // Same pattern as leaderboards: per-list try/catch so a failure on
    // one doesn't poison the cache for the other, and a failure leaves
    // the field NULL so the provider knows to refetch.
    final service = TournamentService();
    try {
      _activeTournaments = await service.getActiveTournaments();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Active tournaments load failed: $e');
    }
    try {
      _historyTournaments = await service.getTournamentHistory();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Tournament history load failed: $e');
    }
  }

  Future<void> _loadSocialData() async {
    final service = SocialService();
    try {
      _friendsList = await service.getFriends();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Friends load failed: $e');
    }
    try {
      _friendRequests = await service.getFriendRequests();
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Friend requests load failed: $e');
    }
  }

  /// Background refresh - call when entering a screen for silent updates.
  /// Throttled to avoid redundant refreshes within [_refreshThrottle].
  Future<void> refreshInBackground() async {
    // Skip if we just refreshed recently
    if (isRecentlyRefreshed) return;

    // Don't block - run in background
    Future.microtask(() async {
      try {
        await Future.wait([
          _loadStatistics(),
          _loadRecentAchievements(),
          _loadLeaderboards(),
          _loadTournaments(),
          _loadSocialData(),
          _loadDailyChallenges(),
        ]);
        _lastRefreshTime = DateTime.now();
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('AppDataCache: Background refresh warning: $e');
      }
    });
  }

  /// Refresh specific data types
  Future<void> refreshStatistics() async {
    await _loadStatistics();
    notifyListeners();
  }

  Future<void> refreshAchievements() async {
    await _loadRecentAchievements();
    notifyListeners();
  }

  Future<void> refreshLeaderboards() async {
    await _loadLeaderboards();
    notifyListeners();
  }

  Future<void> refreshTournaments() async {
    await _loadTournaments();
    notifyListeners();
  }

  Future<void> refreshSocial() async {
    await _loadSocialData();
    notifyListeners();
  }

  Future<void> refreshDailyChallenges() async {
    await _loadDailyChallenges();
    notifyListeners();
  }

  Future<void> refreshSettings() async {
    await _loadSettingsData();
    notifyListeners();
  }

  /// Clear all cached data
  void clearCache() {
    _statistics = null;
    _performanceTrends = null;
    _playPatterns = null;
    _recentAchievements = null;
    _replayKeys = null;
    _settingsData = null;
    _dailyChallenges = null;
    _globalLeaderboard = null;
    _weeklyLeaderboard = null;
    _friendsLeaderboard = null;
    _activeTournaments = null;
    _historyTournaments = null;
    _friendsList = null;
    _friendRequests = null;
    _isFullyLoaded = false;
    notifyListeners();
  }
}
