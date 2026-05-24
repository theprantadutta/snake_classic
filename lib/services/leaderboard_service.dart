import 'dart:async';

/// Offline-first stub. Online leaderboards (global / weekly / daily /
/// friends) are disabled in this build because the backing API was
/// unreliable. The service stays in the tree so DI and existing call
/// sites compile; every method returns empty data.
///
/// To revive: restore the prior implementation from git history and
/// re-add the leaderboard endpoints to [ApiService].
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({int limit = 50}) async =>
      const [];

  Stream<List<Map<String, dynamic>>> getGlobalLeaderboardStream({int limit = 50}) =>
      const Stream.empty();

  Future<Map<String, dynamic>?> getUserRank(String userId) async => null;

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({int limit = 50}) async =>
      const [];

  Stream<List<Map<String, dynamic>>> getWeeklyLeaderboardStream({int limit = 50}) =>
      const Stream.empty();

  Future<List<Map<String, dynamic>>> getDailyLeaderboard({int limit = 50}) async =>
      const [];

  Future<List<Map<String, dynamic>>> getFriendsLeaderboard(
    List<String> friendIds, {
    int limit = 50,
  }) async => const [];

  Future<bool> hasCachedData() async => false;

  Future<Map<String, dynamic>?> getCacheInfo(String leaderboardType) async => null;

  Future<void> clearCache() async {}

  Future<void> forceRefreshAll({int limit = 50}) async {}
}
