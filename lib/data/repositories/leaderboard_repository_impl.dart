import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/leaderboard_repository.dart';
import 'package:snake_classic/utils/logger.dart';

/// Implementation of LeaderboardRepository with caching
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final ApiDataSource _remote;
  final CacheDataSource _cache;
  final NetworkInfo _network;

  LeaderboardRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  }) : _remote = remote,
       _cache = cache,
       _network = network;

  @override
  Future<Either<Failure, LeaderboardData>> getGlobalLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final cacheKey = CacheKeys.leaderboardGlobal(gameMode, page);
    return _getLeaderboard(
      cacheKey: cacheKey,
      ttl: CacheTtl.leaderboardGlobal,
      fetcher: () => _remote.getGlobalLeaderboard(
        gameMode: gameMode,
        difficulty: difficulty,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<Either<Failure, LeaderboardData>> getWeeklyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final cacheKey = CacheKeys.leaderboardWeekly(gameMode, page);
    return _getLeaderboard(
      cacheKey: cacheKey,
      ttl: CacheTtl.leaderboardWeekly,
      fetcher: () => _remote.getWeeklyLeaderboard(
        gameMode: gameMode,
        difficulty: difficulty,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<Either<Failure, LeaderboardData>> getDailyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final cacheKey = CacheKeys.leaderboardDaily(gameMode, page);
    return _getLeaderboard(
      cacheKey: cacheKey,
      ttl: CacheTtl.leaderboardDaily,
      fetcher: () => _remote.getDailyLeaderboard(
        gameMode: gameMode,
        difficulty: difficulty,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  @override
  Future<Either<Failure, LeaderboardData>> getFriendsLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final cacheKey = CacheKeys.leaderboardFriends(gameMode, page);
    return _getLeaderboard(
      cacheKey: cacheKey,
      ttl: CacheTtl.friendsList, // 10 minutes
      fetcher: () => _remote.getFriendsLeaderboard(
        gameMode: gameMode,
        difficulty: difficulty,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Generic leaderboard fetching with cache pattern
  Future<Either<Failure, LeaderboardData>> _getLeaderboard({
    required String cacheKey,
    required Duration ttl,
    required Future<Map<String, dynamic>> Function() fetcher,
  }) async {
    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<LeaderboardData>(
        cacheKey,
        (data) => LeaderboardData.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('Leaderboard cache hit: $cacheKey');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await fetcher();
        final leaderboardData = LeaderboardData.fromJson(data);

        // Store in cache
        await _cache.setCache<LeaderboardData>(
          cacheKey,
          leaderboardData,
          (d) => jsonEncode(d.toJson()),
          customTtl: ttl,
        );

        AppLogger.debug('Leaderboard fetched from network: $cacheKey');
        return Right(leaderboardData);
      } catch (e) {
        AppLogger.warning('Network fetch failed for $cacheKey: $e');
        // Fall through to stale cache
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<LeaderboardData>(
      cacheKey,
      (data) => LeaderboardData.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for: $cacheKey');
      return Right(stale);
    }

    // No data available
    return Left(NetworkFailure('Unable to fetch leaderboard'));
  }

  @override
  Future<void> refreshAll() async {
    // Invalidate all leaderboard caches
    await _cache.invalidatePattern('leaderboard_');
    AppLogger.info('All leaderboard caches invalidated');
  }
}
