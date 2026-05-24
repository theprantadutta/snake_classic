import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/tournament_repository.dart';
import 'package:snake_classic/models/tournament.dart';

/// Offline-first stub. Tournaments are backend-driven (join, score,
/// rank, prize) and disabled in this build. Every method returns a
/// [NetworkFailure].
class TournamentRepositoryImpl implements TournamentRepository {
  TournamentRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  });

  static Failure get _disabled =>
      NetworkFailure('Tournaments are disabled in this build');

  @override
  Future<Either<Failure, TournamentsData>> getTournaments({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async => Left(_disabled);

  @override
  Future<Either<Failure, Tournament>> getTournament(String tournamentId) async =>
      Left(_disabled);

  @override
  Future<Either<Failure, TournamentLeaderboardData>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
    int offset = 0,
  }) async => Left(_disabled);

  @override
  Future<Either<Failure, Tournament>> joinTournament(
    String tournamentId,
  ) async => Left(_disabled);

  @override
  Future<Either<Failure, void>> submitTournamentScore({
    required String tournamentId,
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
  }) async => Left(_disabled);

  @override
  Future<void> refresh() async {}
}
