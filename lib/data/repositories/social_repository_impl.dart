import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/core/network/network_info.dart';
import 'package:snake_classic/data/datasources/local/cache_datasource.dart';
import 'package:snake_classic/data/datasources/remote/api_datasource.dart';
import 'package:snake_classic/domain/repositories/social_repository.dart';
import 'package:snake_classic/utils/logger.dart';

/// Implementation of SocialRepository with caching
class SocialRepositoryImpl implements SocialRepository {
  final ApiDataSource _remote;
  final CacheDataSource _cache;
  final NetworkInfo _network;

  SocialRepositoryImpl({
    required ApiDataSource remote,
    required CacheDataSource cache,
    required NetworkInfo network,
  }) : _remote = remote,
       _cache = cache,
       _network = network;

  @override
  Future<Either<Failure, FriendsData>> getFriends() async {
    const cacheKey = CacheKeys.friendsList;

    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<FriendsData>(
        cacheKey,
        (data) => FriendsData.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('Friends list cache hit');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.getFriends();
        final friendsData = FriendsData.fromJson(data);

        // Store in cache (10 minutes TTL)
        await _cache.setCache<FriendsData>(
          cacheKey,
          friendsData,
          (d) => jsonEncode(d.toJson()),
          customTtl: CacheTtl.friendsList,
        );

        AppLogger.debug('Friends list fetched from network');
        return Right(friendsData);
      } catch (e) {
        AppLogger.warning('Network fetch failed for friends: $e');
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<FriendsData>(
      cacheKey,
      (data) => FriendsData.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for friends');
      return Right(stale);
    }

    return Left(NetworkFailure('Unable to fetch friends'));
  }

  @override
  Future<Either<Failure, PendingRequestsData>> getPendingRequests() async {
    const cacheKey = CacheKeys.friendRequests;

    // 1. Check fresh cache
    if (await _cache.isCacheFresh(cacheKey)) {
      final cached = await _cache.getCached<PendingRequestsData>(
        cacheKey,
        (data) => PendingRequestsData.fromJson(jsonDecode(data as String)),
      );
      if (cached != null) {
        AppLogger.debug('Friend requests cache hit');
        return Right(cached);
      }
    }

    // 2. Try network
    if (await _network.isConnected) {
      try {
        final data = await _remote.getPendingRequests();
        final requestsData = PendingRequestsData.fromJson(data);

        // Store in cache (2 minutes TTL - real-time feel)
        await _cache.setCache<PendingRequestsData>(
          cacheKey,
          requestsData,
          (d) => jsonEncode(d.toJson()),
          customTtl: CacheTtl.friendRequests,
        );

        AppLogger.debug('Friend requests fetched from network');
        return Right(requestsData);
      } catch (e) {
        AppLogger.warning('Network fetch failed for friend requests: $e');
      }
    }

    // 3. Stale cache fallback
    final stale = await _cache.getCachedFallback<PendingRequestsData>(
      cacheKey,
      (data) => PendingRequestsData.fromJson(jsonDecode(data as String)),
    );
    if (stale != null) {
      AppLogger.debug('Using stale cache for friend requests');
      return Right(stale);
    }

    return Left(NetworkFailure('Unable to fetch pending requests'));
  }

  @override
  Future<Either<Failure, List<Friend>>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    // No caching for search - always real-time
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final data = await _remote.searchUsers(query, limit: limit);
      final friends = data.map((e) => Friend.fromJson(e)).toList();
      return Right(friends);
    } catch (e) {
      AppLogger.error('Failed to search users', e);
      return Left(ServerFailure('Search failed'));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest({
    String? username,
    String? userId,
  }) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remote.sendFriendRequest(username: username, userId: userId);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Failed to send friend request', e);
      return Left(ServerFailure('Failed to send friend request'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String requestId) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remote.acceptFriendRequest(requestId);
      // Invalidate caches
      await _cache.invalidate(CacheKeys.friendsList);
      await _cache.invalidate(CacheKeys.friendRequests);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Failed to accept friend request', e);
      return Left(ServerFailure('Failed to accept friend request'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFriendRequest(String requestId) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remote.rejectFriendRequest(requestId);
      // Invalidate friend requests cache
      await _cache.invalidate(CacheKeys.friendRequests);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Failed to reject friend request', e);
      return Left(ServerFailure('Failed to reject friend request'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend(String friendId) async {
    if (!await _network.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remote.removeFriend(friendId);
      // Invalidate friends cache
      await _cache.invalidate(CacheKeys.friendsList);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Failed to remove friend', e);
      return Left(ServerFailure('Failed to remove friend'));
    }
  }

  @override
  Future<void> refresh() async {
    await _cache.invalidate(CacheKeys.friendsList);
    await _cache.invalidate(CacheKeys.friendRequests);
    AppLogger.info('Social caches invalidated');
  }
}
