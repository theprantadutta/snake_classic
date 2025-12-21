import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/achievement_repository.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/utils/logger.dart';

/// Implementation of AchievementRepository with caching
class AchievementRepositoryImpl implements AchievementRepository {
  final ApiDataSource _remote;
  final CacheDataSource _cache;
  final NetworkInfo _network;

  AchievementRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  })  : _remote = remote,
        _cache = cache,
        _network = network;

  @override
  Future<Either<Failure, List<Achievement>>> getAllAchievements() async {
    const cacheKey = CacheKeys.achievementsMetadata;

    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<List<Achievement>>(
        cacheKey,
        (data) {
          final List<dynamic> list = jsonDecode(data as String);
          return list.map((e) => Achievement.fromJson(e)).toList();
        },
      );
      if (cached != null) {
        AppLogger.debug('Achievements metadata cache hit');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.getAllAchievements();
        final achievements = data.map((e) => Achievement.fromJson(e)).toList();

        // Store in cache (1 hour TTL - static data)
        await _cache.setCache<List<Achievement>>(
          cacheKey,
          achievements,
          (d) => jsonEncode(d.map((e) => e.toJson()).toList()),
          customTtl: CacheTtl.achievementsMetadata,
        );

        AppLogger.debug('Achievements metadata fetched from network');
        return Right(achievements);
      } catch (e) {
        AppLogger.warning('Network fetch failed for achievements: $e');
        // Fall through to stale cache or defaults
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<List<Achievement>>(
      cacheKey,
      (data) {
        final List<dynamic> list = jsonDecode(data as String);
        return list.map((e) => Achievement.fromJson(e)).toList();
      },
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for achievements');
      return Right(stale);
    }

    // 4. Use default achievements if no network and no cache
    AppLogger.info('Using default achievements definitions');
    return Right(Achievement.getDefaultAchievements());
  }

  @override
  Future<Either<Failure, UserAchievementProgress>> getUserAchievements() async {
    const cacheKey = CacheKeys.userAchievements;

    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<UserAchievementProgress>(
        cacheKey,
        (data) => UserAchievementProgress.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('User achievements cache hit');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.getUserAchievements();
        final progress = UserAchievementProgress.fromJson(data);

        // Store in cache (5 minutes TTL)
        await _cache.setCache<UserAchievementProgress>(
          cacheKey,
          progress,
          (d) => jsonEncode(d.toJson()),
          customTtl: CacheTtl.scoreStats,
        );

        AppLogger.debug('User achievements fetched from network');
        return Right(progress);
      } catch (e) {
        AppLogger.warning('Network fetch failed for user achievements: $e');
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<UserAchievementProgress>(
      cacheKey,
      (data) => UserAchievementProgress.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for user achievements');
      return Right(stale);
    }

    return Left(NetworkFailure('Unable to fetch user achievements'));
  }

  @override
  Future<Either<Failure, Achievement>> updateAchievementProgress({
    required String achievementId,
    int progressIncrement = 1,
  }) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final data = await _remote.updateAchievementProgress(
        achievementId: achievementId,
        progressIncrement: progressIncrement,
      );

      // Invalidate user achievements cache
      await _cache.invalidate(CacheKeys.userAchievements);

      final achievement = Achievement.fromJson(data['achievement'] ?? data);
      return Right(achievement);
    } catch (e) {
      AppLogger.error('Failed to update achievement progress', e);
      return Left(ServerFailure('Failed to update achievement'));
    }
  }

  @override
  Future<void> refresh() async {
    await _cache.invalidate(CacheKeys.achievementsMetadata);
    await _cache.invalidate(CacheKeys.userAchievements);
    AppLogger.info('Achievements caches invalidated');
  }
}
