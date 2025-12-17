import 'dart:async';
import 'package:snake_classic/services/api_service.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final ApiService _apiService = ApiService();

  // Cache for leaderboard data
  List<Map<String, dynamic>>? _cachedGlobalLeaderboard;
  DateTime? _lastGlobalFetch;
  static const Duration _cacheExpiry = Duration(minutes: 2);

  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      // Check cache
      if (_cachedGlobalLeaderboard != null &&
          _lastGlobalFetch != null &&
          DateTime.now().difference(_lastGlobalFetch!) < _cacheExpiry) {
        return _cachedGlobalLeaderboard!;
      }

      final response = await _apiService.getGlobalLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        _cachedGlobalLeaderboard = entries.map((entry) => _mapLeaderboardEntry(entry)).toList();
        _lastGlobalFetch = DateTime.now();
        return _cachedGlobalLeaderboard!;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getGlobalLeaderboardStream({int limit = 50}) {
    // For real-time updates, we poll the API periodically
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getGlobalLeaderboard(limit: limit))
        .distinct();
  }

  Future<Map<String, dynamic>?> getUserRank(String userId) async {
    try {
      // Get global leaderboard and find user's position
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

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final response = await _apiService.getWeeklyLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        return entries.map((entry) => _mapLeaderboardEntry(entry)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getWeeklyLeaderboardStream({int limit = 50}) {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getWeeklyLeaderboard(limit: limit))
        .distinct();
  }

  Future<List<Map<String, dynamic>>> getDailyLeaderboard({int limit = 50}) async {
    try {
      final response = await _apiService.getDailyLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        return entries.map((entry) => _mapLeaderboardEntry(entry)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFriendsLeaderboard(List<String> friendIds, {int limit = 50}) async {
    try {
      if (friendIds.isEmpty) return [];

      final response = await _apiService.getFriendsLeaderboard(pageSize: limit);

      if (response != null && response['entries'] != null) {
        final entries = List<Map<String, dynamic>>.from(response['entries']);
        return entries.map((entry) => _mapLeaderboardEntry(entry)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Clear cached data
  void clearCache() {
    _cachedGlobalLeaderboard = null;
    _lastGlobalFetch = null;
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
