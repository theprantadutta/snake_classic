import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/social_repository.dart';

/// Offline-first stub. Friends / requests / search all require the
/// backend; disabled in this build. Every method returns a
/// [NetworkFailure].
class SocialRepositoryImpl implements SocialRepository {
  SocialRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  });

  static Failure get _disabled =>
      NetworkFailure('Social features are disabled in this build');

  @override
  Future<Either<Failure, FriendsData>> getFriends() async => Left(_disabled);

  @override
  Future<Either<Failure, PendingRequestsData>> getPendingRequests() async =>
      Left(_disabled);

  @override
  Future<Either<Failure, List<Friend>>> searchUsers(
    String query, {
    int limit = 20,
  }) async => Left(_disabled);

  @override
  Future<Either<Failure, void>> sendFriendRequest({
    String? username,
    String? userId,
  }) async => Left(_disabled);

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String requestId) async =>
      Left(_disabled);

  @override
  Future<Either<Failure, void>> rejectFriendRequest(String requestId) async =>
      Left(_disabled);

  @override
  Future<Either<Failure, void>> removeFriend(String friendId) async =>
      Left(_disabled);

  @override
  Future<void> refresh() async {}
}
