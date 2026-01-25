import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/leaderboard_service.dart';
import 'package:snake_classic/providers/providers.dart';

/// Leaderboard types
enum LeaderboardType { global, weekly, daily, friends }

/// State for leaderboard data
class LeaderboardState {
  final List<Map<String, dynamic>> entries;
  final Map<String, dynamic>? userRank;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.entries = const [],
    this.userRank,
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<Map<String, dynamic>>? entries,
    Map<String, dynamic>? userRank,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      userRank: userRank ?? this.userRank,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for a specific leaderboard type with TTL-based auto-refresh
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final Ref _ref;
  final LeaderboardService _service;
  final LeaderboardType _type;
  Timer? _ttlTimer;

  // TTL varies by leaderboard type
  Duration get _ttl {
    switch (_type) {
      case LeaderboardType.daily:
        return const Duration(seconds: 60); // Daily changes frequently
      case LeaderboardType.weekly:
        return const Duration(minutes: 5);
      case LeaderboardType.global:
        return const Duration(minutes: 15);
      case LeaderboardType.friends:
        return const Duration(minutes: 2);
    }
  }

  LeaderboardNotifier(this._ref, this._type)
    : _service = LeaderboardService(),
      super(const LeaderboardState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    // Initial load
    _loadData();

    // Set up TTL-based refresh
    _startTtlTimer();

    // Listen for connectivity changes - refresh when coming online
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isNowOnline = next.value == true;
      if (wasOffline && isNowOnline) {
        refresh();
      }
    });
  }

  void _startTtlTimer() {
    _ttlTimer?.cancel();
    _ttlTimer = Timer.periodic(_ttl, (_) {
      final isOnline = _ref.read(isOnlineSyncProvider);
      if (isOnline) {
        refresh();
      }
    });
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final entries = await _fetchEntries();
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load leaderboard',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEntries({int limit = 50}) async {
    switch (_type) {
      case LeaderboardType.global:
        return await _service.getGlobalLeaderboard(limit: limit);
      case LeaderboardType.weekly:
        return await _service.getWeeklyLeaderboard(limit: limit);
      case LeaderboardType.daily:
        return await _service.getDailyLeaderboard(limit: limit);
      case LeaderboardType.friends:
        return await _service.getFriendsLeaderboard([], limit: limit);
    }
  }

  /// Refresh leaderboard from the server
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final entries = await _fetchEntries();
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh leaderboard',
      );
    }
  }

  /// Get user rank from the leaderboard
  Future<Map<String, dynamic>?> getUserRank(String userId) async {
    return await _service.getUserRank(userId);
  }

  /// Update user rank in state
  void setUserRank(Map<String, dynamic>? rank) {
    state = state.copyWith(userRank: rank);
  }

  @override
  void dispose() {
    _ttlTimer?.cancel();
    super.dispose();
  }
}

/// Family provider for leaderboards by type
final leaderboardProvider =
    StateNotifierProvider.family<
      LeaderboardNotifier,
      LeaderboardState,
      LeaderboardType
    >((ref, type) => LeaderboardNotifier(ref, type));

/// Combined leaderboard state for screens that show multiple types
class CombinedLeaderboardState {
  final List<Map<String, dynamic>> globalEntries;
  final List<Map<String, dynamic>> weeklyEntries;
  final Map<String, dynamic>? userRank;
  final bool isLoadingGlobal;
  final bool isLoadingWeekly;
  final String? globalError;
  final String? weeklyError;

  const CombinedLeaderboardState({
    this.globalEntries = const [],
    this.weeklyEntries = const [],
    this.userRank,
    this.isLoadingGlobal = false,
    this.isLoadingWeekly = false,
    this.globalError,
    this.weeklyError,
  });

  bool get isLoading => isLoadingGlobal || isLoadingWeekly;

  CombinedLeaderboardState copyWith({
    List<Map<String, dynamic>>? globalEntries,
    List<Map<String, dynamic>>? weeklyEntries,
    Map<String, dynamic>? userRank,
    bool? isLoadingGlobal,
    bool? isLoadingWeekly,
    String? globalError,
    String? weeklyError,
  }) {
    return CombinedLeaderboardState(
      globalEntries: globalEntries ?? this.globalEntries,
      weeklyEntries: weeklyEntries ?? this.weeklyEntries,
      userRank: userRank ?? this.userRank,
      isLoadingGlobal: isLoadingGlobal ?? this.isLoadingGlobal,
      isLoadingWeekly: isLoadingWeekly ?? this.isLoadingWeekly,
      globalError: globalError,
      weeklyError: weeklyError,
    );
  }
}

/// Notifier for combined leaderboard data (for main leaderboard screen)
class CombinedLeaderboardNotifier
    extends StateNotifier<CombinedLeaderboardState> {
  final Ref _ref;
  final LeaderboardService _service;
  final AppDataCache _appCache;
  Timer? _globalTimer;
  Timer? _weeklyTimer;

  static const _globalTtl = Duration(minutes: 15);
  static const _weeklyTtl = Duration(minutes: 5);

  CombinedLeaderboardNotifier(this._ref)
    : _service = LeaderboardService(),
      _appCache = AppDataCache(),
      super(
        const CombinedLeaderboardState(
          isLoadingGlobal: true,
          isLoadingWeekly: true,
        ),
      ) {
    _initialize();
  }

  void _initialize() {
    // Check cache first - use preloaded data if available
    if (_appCache.isFullyLoaded &&
        _appCache.globalLeaderboard != null &&
        _appCache.weeklyLeaderboard != null) {
      // Use cached data immediately - no loading state!
      state = CombinedLeaderboardState(
        globalEntries: _appCache.globalLeaderboard!,
        weeklyEntries: _appCache.weeklyLeaderboard!,
        isLoadingGlobal: false,
        isLoadingWeekly: false,
      );
      // Refresh in background (silent, no loading indicator)
      _refreshInBackground();
    } else {
      // No cache - load normally
      _loadData();
    }

    // Set up TTL-based refresh for each type
    _startTtlTimers();

    // Listen for connectivity changes - refresh when coming online
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isNowOnline = next.value == true;
      if (wasOffline && isNowOnline) {
        refresh();
      }
    });
  }

  Future<void> _refreshInBackground() async {
    // Silent refresh - don't set isLoading
    try {
      final results = await Future.wait([
        _service.getGlobalLeaderboard(),
        _service.getWeeklyLeaderboard(),
      ]);
      state = state.copyWith(
        globalEntries: results[0],
        weeklyEntries: results[1],
      );
    } catch (_) {
      // Ignore errors in background refresh
    }
  }

  void _startTtlTimers() {
    _globalTimer?.cancel();
    _weeklyTimer?.cancel();

    _globalTimer = Timer.periodic(_globalTtl, (_) {
      final isOnline = _ref.read(isOnlineSyncProvider);
      if (isOnline) {
        _refreshGlobal();
      }
    });

    _weeklyTimer = Timer.periodic(_weeklyTtl, (_) {
      final isOnline = _ref.read(isOnlineSyncProvider);
      if (isOnline) {
        _refreshWeekly();
      }
    });
  }

  Future<void> _loadData() async {
    // Load both in parallel
    await Future.wait([_loadGlobal(), _loadWeekly()]);

    // Calculate user rank from global leaderboard
    _calculateUserRank();
  }

  Future<void> _loadGlobal() async {
    state = state.copyWith(isLoadingGlobal: true, globalError: null);
    try {
      final entries = await _service.getGlobalLeaderboard();
      state = state.copyWith(globalEntries: entries, isLoadingGlobal: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingGlobal: false,
        globalError: 'Failed to load leaderboard',
      );
    }
  }

  Future<void> _loadWeekly() async {
    state = state.copyWith(isLoadingWeekly: true, weeklyError: null);
    try {
      final entries = await _service.getWeeklyLeaderboard();
      state = state.copyWith(weeklyEntries: entries, isLoadingWeekly: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingWeekly: false,
        weeklyError: 'Failed to load weekly leaderboard',
      );
    }
  }

  void _calculateUserRank() {
    // This will be called with userId from the screen
  }

  /// Calculate and set user rank for a given user ID
  void calculateUserRankFor(String? userId) {
    if (userId == null || state.globalEntries.isEmpty) {
      state = state.copyWith(userRank: null);
      return;
    }

    for (int i = 0; i < state.globalEntries.length; i++) {
      if (state.globalEntries[i]['uid'] == userId) {
        state = state.copyWith(
          userRank: {
            'rank': i + 1,
            'totalPlayers': state.globalEntries.length,
            'userScore': state.globalEntries[i]['highScore'] ?? 0,
            'percentile':
                ((state.globalEntries.length - i) /
                        state.globalEntries.length *
                        100)
                    .round(),
          },
        );
        return;
      }
    }

    state = state.copyWith(userRank: null);
  }

  /// Refresh all leaderboards
  Future<void> refresh() async {
    await Future.wait([_refreshGlobal(), _refreshWeekly()]);
  }

  Future<void> _refreshGlobal() async {
    state = state.copyWith(isLoadingGlobal: true, globalError: null);
    try {
      final entries = await _service.getGlobalLeaderboard();
      state = state.copyWith(globalEntries: entries, isLoadingGlobal: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingGlobal: false,
        globalError: 'Failed to refresh leaderboard',
      );
    }
  }

  Future<void> _refreshWeekly() async {
    state = state.copyWith(isLoadingWeekly: true, weeklyError: null);
    try {
      final entries = await _service.getWeeklyLeaderboard();
      state = state.copyWith(weeklyEntries: entries, isLoadingWeekly: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingWeekly: false,
        weeklyError: 'Failed to refresh weekly leaderboard',
      );
    }
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _weeklyTimer?.cancel();
    super.dispose();
  }
}

/// Provider for combined leaderboard state (for main leaderboard screen)
final combinedLeaderboardProvider =
    StateNotifierProvider<
      CombinedLeaderboardNotifier,
      CombinedLeaderboardState
    >((ref) => CombinedLeaderboardNotifier(ref));

/// Convenience provider for global leaderboard entries
final globalLeaderboardProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(combinedLeaderboardProvider).globalEntries;
});

/// Convenience provider for weekly leaderboard entries
final weeklyLeaderboardProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(combinedLeaderboardProvider).weeklyEntries;
});

/// Convenience provider for global loading state
final globalLeaderboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(combinedLeaderboardProvider).isLoadingGlobal;
});

/// Convenience provider for weekly loading state
final weeklyLeaderboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(combinedLeaderboardProvider).isLoadingWeekly;
});

/// Convenience provider for user rank
final userRankProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(combinedLeaderboardProvider).userRank;
});
