import 'dart:async';
import 'package:snake_classic/models/user_profile.dart';

/// Offline-first stub. Friends, requests, search, social graph all
/// require a live backend; they're disabled in this build. The service
/// stays in the tree so DI and existing call sites compile; every
/// method returns empty data or false.
///
/// To revive: restore the prior implementation from git history and
/// re-add the social endpoints to [ApiService].
class SocialService {
  static SocialService? _instance;

  SocialService._internal();

  factory SocialService() {
    _instance ??= SocialService._internal();
    return _instance!;
  }

  Future<List<UserProfile>> searchUsers(String query) async => const [];

  Future<bool> sendFriendRequest(String toUserId) async => false;

  Future<bool> acceptFriendRequest(String fromUserId) async => false;

  Future<bool> rejectFriendRequest(String fromUserId) async => false;

  Future<bool> removeFriend(String friendUserId) async => false;

  Future<UserProfile?> getUserProfile(String userId) async => null;

  Future<List<UserProfile>> getFriends() async => const [];

  Future<List<FriendRequest>> getFriendRequests() async => const [];

  Future<List<UserProfile>> getFriendsLeaderboard() async => const [];

  Future<void> updateUserStatus(
    UserStatus status, {
    String? statusMessage,
  }) async {}

  Future<bool> updatePrivacySetting(bool isPublic) async => false;

  Future<bool> hasCachedFriends() async => false;

  Future<void> clearCache() async {}

  Stream<List<UserProfile>> watchFriends() => const Stream.empty();

  Stream<List<FriendRequest>> watchFriendRequests() => const Stream.empty();
}
