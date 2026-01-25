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
  List<Map<String, dynamic>>? _friendsLeaderboard;

  // Tournaments
  List<Tournament>? _activeTournaments;
  List<Tournament>? _historyTournaments;

  // Social
  List<UserProfile>? _friendsList;
  List<FriendRequest>? _friendRequests;

  bool _isFullyLoaded = false;
  bool _isLoading = false;

  // === Public Getters (instant access) ===

  bool get isFullyLoaded => _isFullyLoaded;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? get statistics => _statistics;
  Map<String, dynamic>? get performanceTrends => _performanceTrends;
  Map<String, dynamic>? get playPatterns => _playPatterns;
  List<Achievement>? get recentAchievements => _recentAchievements;
  List<String>? get replayKeys => _replayKeys;
  Map<String, dynamic>? get settingsData => _settingsData;
  List<DailyChallenge>? get dailyChallenges => _dailyChallenges;
  List<Map<String, dynamic>>? get globalLeaderboard => _globalLeaderboard;
  List<Map<String, dynamic>>? get weeklyLeaderboard => _weeklyLeaderboard;
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
      // Load ALL data in parallel using Future.wait
      await Future.wait([
        // Group 1: Local data (fast)
        _loadStatistics(),
        _loadRecentAchievements(),
        _loadReplayKeys(),
        _loadSettingsData(),

        // Group 2: Services that need initialization
        _loadDailyChallenges(),

        // Group 3: Network data (with fallback to cache)
        _loadLeaderboards(),
        _loadTournaments(),
        _loadSocialData(),
      ]);

      _isFullyLoaded = true;
      AppLogger.success('AppDataCache: All data preloaded successfully');
    } catch (e) {
      AppLogger.error('AppDataCache: Error during preload', e);
      // Even if some fail, mark as loaded so screens can still function
      _isFullyLoaded = true;
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
      _dailyChallenges = service.challenges;
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Daily challenges load warning: $e');
    }
  }

  Future<void> _loadLeaderboards() async {
    try {
      final service = LeaderboardService();
      // Load global and weekly leaderboards concurrently
      final results = await Future.wait([
        service
            .getGlobalLeaderboard(limit: 100)
            .catchError((_) => <Map<String, dynamic>>[]),
        service
            .getWeeklyLeaderboard(limit: 100)
            .catchError((_) => <Map<String, dynamic>>[]),
      ]);
      _globalLeaderboard = results[0];
      _weeklyLeaderboard = results[1];
      // Note: Friends leaderboard requires friend IDs and will be loaded on-demand
      _friendsLeaderboard = [];
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Leaderboards load warning: $e');
    }
  }

  Future<void> _loadTournaments() async {
    try {
      final service = TournamentService();
      final results = await Future.wait([
        service.getActiveTournaments().catchError((_) => <Tournament>[]),
        service.getTournamentHistory().catchError((_) => <Tournament>[]),
      ]);
      _activeTournaments = results[0];
      _historyTournaments = results[1];
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Tournaments load warning: $e');
    }
  }

  Future<void> _loadSocialData() async {
    try {
      final service = SocialService();
      // Load friends and requests separately to avoid type issues
      _friendsList = await service.getFriends().catchError((_) => <UserProfile>[]);
      _friendRequests = await service.getFriendRequests().catchError((_) => <FriendRequest>[]);
    } catch (e) {
      if (kDebugMode) print('AppDataCache: Social data load warning: $e');
    }
  }

  /// Background refresh - call when entering a screen for silent updates
  Future<void> refreshInBackground() async {
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
