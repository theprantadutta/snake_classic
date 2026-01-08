import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/tournament_repository.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/utils/logger.dart';

/// Implementation of TournamentRepository with caching
class TournamentRepositoryImpl implements TournamentRepository {
  final ApiDataSource _remote;
  final CacheDataSource _cache;
  final NetworkInfo _network;

  TournamentRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  }) : _remote = remote,
       _cache = cache,
       _network = network;

  @override
  Future<Either<Failure, TournamentsData>> getTournaments({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    final cacheKey = status == 'active'
        ? CacheKeys.tournamentsActive
        : CacheKeys.tournamentsUpcoming;

    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<TournamentsData>(
        cacheKey,
        (data) => TournamentsData.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('Tournaments cache hit: $cacheKey');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.listTournaments(
          status: status,
          type: type,
          limit: limit,
          offset: offset,
        );
        final tournamentsData = TournamentsData.fromJson(data);

        // Store in cache (5 minutes TTL)
        await _cache.setCache<TournamentsData>(
          cacheKey,
          tournamentsData,
          (d) => jsonEncode(d.toJson()),
          customTtl: CacheTtl.tournamentsActive,
        );

        AppLogger.debug('Tournaments fetched from network');
        return Right(tournamentsData);
      } catch (e) {
        AppLogger.warning('Network fetch failed for tournaments: $e');
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<TournamentsData>(
      cacheKey,
      (data) => TournamentsData.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for tournaments');
      return Right(stale);
    }

    return Left(NetworkFailure('Unable to fetch tournaments'));
  }

  @override
  Future<Either<Failure, Tournament>> getTournament(String tournamentId) async {
    final cacheKey = CacheKeys.tournamentDetails(tournamentId);

    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<Tournament>(
        cacheKey,
        (data) => Tournament.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('Tournament details cache hit: $tournamentId');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.getTournament(tournamentId);
        final tournament = Tournament.fromJson(data);

        // Store in cache (5 minutes TTL)
        await _cache.setCache<Tournament>(
          cacheKey,
          tournament,
          (d) => jsonEncode(d.toJson()),
          customTtl: CacheTtl.tournamentsActive,
        );

        AppLogger.debug('Tournament details fetched from network');
        return Right(tournament);
      } catch (e) {
        AppLogger.warning('Network fetch failed for tournament: $e');
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<Tournament>(
      cacheKey,
      (data) => Tournament.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for tournament');
      return Right(stale);
    }

    return Left(NetworkFailure('Unable to fetch tournament'));
  }

  @override
  Future<Either<Failure, TournamentLeaderboardData>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final cacheKey = '${CacheKeys.tournamentDetails(tournamentId)}_leaderboard';

    // 1. Check fresh cache (60 seconds - volatile)
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<TournamentLeaderboardData>(
        cacheKey,
        (data) =>
            TournamentLeaderboardData.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('Tournament leaderboard cache hit');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.getTournamentLeaderboard(
          tournamentId,
          limit: limit,
          offset: offset,
        );
        final leaderboardData = TournamentLeaderboardData.fromJson({
          'tournament_id': tournamentId,
          ...data,
        });

        // Store in cache (60 seconds TTL)
        await _cache.setCache<TournamentLeaderboardData>(
          cacheKey,
          leaderboardData,
          (d) => jsonEncode(d.toJson()),
          customTtl: CacheTtl.leaderboardDaily,
        );

        AppLogger.debug('Tournament leaderboard fetched from network');
        return Right(leaderboardData);
      } catch (e) {
        AppLogger.warning(
          'Network fetch failed for tournament leaderboard: $e',
        );
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<TournamentLeaderboardData>(
      cacheKey,
      (data) => TournamentLeaderboardData.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for tournament leaderboard');
      return Right(stale);
    }

    return Left(NetworkFailure('Unable to fetch tournament leaderboard'));
  }

  @override
  Future<Either<Failure, Tournament>> joinTournament(
    String tournamentId,
  ) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final data = await _remote.joinTournament(tournamentId);
      final tournament = Tournament.fromJson(data['tournament'] ?? data);

      // Invalidate tournament caches
      await _cache.invalidate(CacheKeys.tournamentDetails(tournamentId));
      await _cache.invalidate(CacheKeys.tournamentsActive);

      return Right(tournament);
    } catch (e) {
      AppLogger.error('Failed to join tournament', e);
      return Left(ServerFailure('Failed to join tournament'));
    }
  }

  @override
  Future<Either<Failure, void>> submitTournamentScore({
    required String tournamentId,
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
  }) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remote.submitTournamentScore(
        tournamentId: tournamentId,
        score: score,
        gameDuration: gameDuration,
        foodsEaten: foodsEaten,
      );

      // Invalidate tournament leaderboard cache
      await _cache.invalidate(
        '${CacheKeys.tournamentDetails(tournamentId)}_leaderboard',
      );
      await _cache.invalidate(CacheKeys.tournamentDetails(tournamentId));

      return const Right(null);
    } catch (e) {
      AppLogger.error('Failed to submit tournament score', e);
      return Left(ServerFailure('Failed to submit score'));
    }
  }

  @override
  Future<void> refresh() async {
    await _cache.invalidate(CacheKeys.tournamentsActive);
    await _cache.invalidate(CacheKeys.tournamentsUpcoming);
    // Note: Individual tournament details will expire naturally
    AppLogger.info('Tournaments caches invalidated');
  }
}
