import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/leaderboard_repository.dart';

/// Offline-first stub. Online leaderboards are disabled in this build.
/// Every method returns a [NetworkFailure] so callers gracefully fall
/// through to an empty-state UI. Constructor still takes the original
/// dependencies so DI bindings don't need to change when this is
/// revived.
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  // Dependencies retained on the constructor only so the existing DI
  // wiring continues to satisfy. They are not used in the stub.
  LeaderboardRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  });

  static Future<Either<Failure, LeaderboardData>> _disabled() async =>
      Left(NetworkFailure('Online leaderboards are disabled in this build'));

  @override
  Future<Either<Failure, LeaderboardData>> getGlobalLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) => _disabled();

  @override
  Future<Either<Failure, LeaderboardData>> getWeeklyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) => _disabled();

  @override
  Future<Either<Failure, LeaderboardData>> getDailyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) => _disabled();

  @override
  Future<Either<Failure, LeaderboardData>> getFriendsLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) => _disabled();

  @override
  Future<void> refreshAll() async {}
}
