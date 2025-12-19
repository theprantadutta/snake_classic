import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/offline_cache_service.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();

  // Cache keys
  static const String _globalLeaderboardKey = 'leaderboard_global';
  static const String _weeklyLeaderboardKey = 'leaderboard_weekly';
  static const String _dailyLeaderboardKey = 'leaderboard_daily';
  static const String _friendsLeaderboardKey = 'leaderboard_friends';

  /// Get global leaderboard with cache-first pattern
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({int limit = 50}) async {
    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _globalLeaderboardKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      // Cache hit - return cached data and refresh in background if online
      if (_connectivityService.isOnline) {
        _refreshGlobalLeaderboardInBackground(limit);
      }
      return cached;
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      // Try to get stale cached data as fallback
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        _globalLeaderboardKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheGlobalLeaderboard(limit);
  }

  Future<List<Map<String, dynamic>>> _fetchAndCacheGlobalLeaderboard(int limit) async {
    try {
      final response = await _apiService.getGlobalLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        final mapped = entries.map((entry) => _mapLeaderboardEntry(entry)).toList();

        // Cache the result
        await _cacheService.setCache<List<Map<String, dynamic>>>(
          _globalLeaderboardKey,
          mapped,
          (data) => data,
        );

        return mapped;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching global leaderboard: $e');
      }
      return [];
    }
  }

  void _refreshGlobalLeaderboardInBackground(int limit) {
    // Non-blocking background refresh
    _fetchAndCacheGlobalLeaderboard(limit).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <Map<String, dynamic>>[];
    });
  }

  Stream<List<Map<String, dynamic>>> getGlobalLeaderboardStream({int limit = 50}) {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getGlobalLeaderboard(limit: limit))
        .distinct();
  }

  Future<Map<String, dynamic>?> getUserRank(String userId) async {
    try {
      final leaderboard = await getGlobalLeaderboard(limit: 100);

      int rank = -1;
      int userScore = 0;

      for (int i = 0; i < leaderboard.length; i++) {
        if (leaderboard[i]['uid'] == userId) {
          rank = i + 1;
          userScore = leaderboard[i]['highScore'] ?? 0;
          break;
        }
      }

      if (rank == -1) {
        return null;
      }

      return {
        'rank': rank,
        'totalPlayers': leaderboard.length,
        'userScore': userScore,
        'percentile': leaderboard.isNotEmpty
            ? ((leaderboard.length - rank + 1) / leaderboard.length * 100).round()
            : 0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get weekly leaderboard with cache-first pattern
  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({int limit = 50}) async {
    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _weeklyLeaderboardKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshWeeklyLeaderboardInBackground(limit);
      }
      return cached;
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        _weeklyLeaderboardKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheWeeklyLeaderboard(limit);
  }

  Future<List<Map<String, dynamic>>> _fetchAndCacheWeeklyLeaderboard(int limit) async {
    try {
      final response = await _apiService.getWeeklyLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        final mapped = entries.map((entry) => _mapLeaderboardEntry(entry)).toList();

        await _cacheService.setCache<List<Map<String, dynamic>>>(
          _weeklyLeaderboardKey,
          mapped,
          (data) => data,
        );

        return mapped;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weekly leaderboard: $e');
      }
      return [];
    }
  }

  void _refreshWeeklyLeaderboardInBackground(int limit) {
    _fetchAndCacheWeeklyLeaderboard(limit).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <Map<String, dynamic>>[];
    });
  }

  Stream<List<Map<String, dynamic>>> getWeeklyLeaderboardStream({int limit = 50}) {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getWeeklyLeaderboard(limit: limit))
        .distinct();
  }

  /// Get daily leaderboard with cache-first pattern
  Future<List<Map<String, dynamic>>> getDailyLeaderboard({int limit = 50}) async {
    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _dailyLeaderboardKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshDailyLeaderboardInBackground(limit);
      }
      return cached;
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        _dailyLeaderboardKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheDailyLeaderboard(limit);
  }

  Future<List<Map<String, dynamic>>> _fetchAndCacheDailyLeaderboard(int limit) async {
    try {
      final response = await _apiService.getDailyLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        final mapped = entries.map((entry) => _mapLeaderboardEntry(entry)).toList();

        await _cacheService.setCache<List<Map<String, dynamic>>>(
          _dailyLeaderboardKey,
          mapped,
          (data) => data,
        );

        return mapped;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching daily leaderboard: $e');
      }
      return [];
    }
  }

  void _refreshDailyLeaderboardInBackground(int limit) {
    _fetchAndCacheDailyLeaderboard(limit).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <Map<String, dynamic>>[];
    });
  }

  /// Get friends leaderboard with cache-first pattern
  Future<List<Map<String, dynamic>>> getFriendsLeaderboard(List<String> friendIds, {int limit = 50}) async {
    if (friendIds.isEmpty) return [];

    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _friendsLeaderboardKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshFriendsLeaderboardInBackground(limit);
      }
      return cached;
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        _friendsLeaderboardKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheFriendsLeaderboard(limit);
  }

  Future<List<Map<String, dynamic>>> _fetchAndCacheFriendsLeaderboard(int limit) async {
    try {
      final response = await _apiService.getFriendsLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        final mapped = entries.map((entry) => _mapLeaderboardEntry(entry)).toList();

        await _cacheService.setCache<List<Map<String, dynamic>>>(
          _friendsLeaderboardKey,
          mapped,
          (data) => data,
        );

        return mapped;
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching friends leaderboard: $e');
      }
      return [];
    }
  }

  void _refreshFriendsLeaderboardInBackground(int limit) {
    _fetchAndCacheFriendsLeaderboard(limit).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <Map<String, dynamic>>[];
    });
  }

  /// Check if we have any cached leaderboard data
  Future<bool> hasCachedData() async {
    return await _cacheService.hasCachedData(_globalLeaderboardKey) ||
           await _cacheService.hasCachedData(_weeklyLeaderboardKey) ||
           await _cacheService.hasCachedData(_dailyLeaderboardKey);
  }

  /// Get cache freshness info for UI
  Future<Map<String, dynamic>?> getCacheInfo(String leaderboardType) async {
    String key;
    switch (leaderboardType) {
      case 'global':
        key = _globalLeaderboardKey;
        break;
      case 'weekly':
        key = _weeklyLeaderboardKey;
        break;
      case 'daily':
        key = _dailyLeaderboardKey;
        break;
      case 'friends':
        key = _friendsLeaderboardKey;
        break;
      default:
        return null;
    }
    return await _cacheService.getCacheInfo(key);
  }

  /// Clear all cached leaderboard data
  Future<void> clearCache() async {
    await _cacheService.invalidateCache(_globalLeaderboardKey);
    await _cacheService.invalidateCache(_weeklyLeaderboardKey);
    await _cacheService.invalidateCache(_dailyLeaderboardKey);
    await _cacheService.invalidateCache(_friendsLeaderboardKey);
  }

  /// Force refresh all leaderboards
  Future<void> forceRefreshAll({int limit = 50}) async {
    if (!_connectivityService.isOnline) return;

    await Future.wait([
      _fetchAndCacheGlobalLeaderboard(limit),
      _fetchAndCacheWeeklyLeaderboard(limit),
      _fetchAndCacheDailyLeaderboard(limit),
      _fetchAndCacheFriendsLeaderboard(limit),
    ]);
  }

  /// Map backend response to the expected format
  Map<String, dynamic> _mapLeaderboardEntry(Map<String, dynamic> entry) {
    return {
      'uid': entry['user_id'] ?? entry['uid'] ?? '',
      'displayName': entry['display_name'] ?? entry['displayName'] ?? 'Anonymous',
      'username': entry['username'] ?? entry['display_name'] ?? 'Anonymous',
      'highScore': entry['high_score'] ?? entry['highScore'] ?? entry['score'] ?? 0,
      'photoURL': entry['photo_url'] ?? entry['photoURL'],
      'totalGamesPlayed': entry['total_games_played'] ?? entry['totalGamesPlayed'] ?? 0,
      'isAnonymous': entry['is_anonymous'] ?? entry['isAnonymous'] ?? false,
      'highScoreDate': entry['high_score_date'] ?? entry['highScoreDate'] ?? entry['created_at'],
      'rank': entry['rank'],
    };
  }
}
