import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/offline_cache_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';

class SocialService {
  static SocialService? _instance;
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();
  final DataSyncService _dataSyncService = DataSyncService();

  SocialService._internal();

  factory SocialService() {
    _instance ??= SocialService._internal();
    return _instance!;
  }

  // Cache keys
  static const String _friendsListKey = 'friends_list';
  static const String _friendRequestsKey = 'friend_requests';

  /// Search for users by username, display name or email (requires online)
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.length < 2) return [];

    if (!_connectivityService.isOnline) {
      return [];
    }

    try {
      final results = await _apiService.searchUsers(query);
      if (results == null) return [];

      return results.map((data) => _mapToUserProfile(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching users: $e');
      }
      return [];
    }
  }

  /// Send friend request (offline-first: queues for background sync)
  Future<bool> sendFriendRequest(String toUserId) async {
    // Queue for background sync - returns immediately
    _dataSyncService.queueSync('friend_request_send', {
      'userId': toUserId,
      'sent_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.normal);

    // Invalidate friend requests cache so next fetch gets fresh data
    await _cacheService.invalidateCache(_friendRequestsKey);
    return true;
  }

  /// Accept friend request (offline-first: queues for background sync)
  Future<bool> acceptFriendRequest(String fromUserId) async {
    // Queue for background sync - returns immediately
    _dataSyncService.queueSync('friend_request_accept', {
      'requestId': fromUserId,
      'accepted_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.normal);

    // Invalidate caches so next fetch gets fresh data
    await _cacheService.invalidateCache(_friendsListKey);
    await _cacheService.invalidateCache(_friendRequestsKey);
    return true;
  }

  /// Reject friend request (offline-first: queues for background sync)
  Future<bool> rejectFriendRequest(String fromUserId) async {
    // Queue for background sync - returns immediately
    _dataSyncService.queueSync('friend_request_reject', {
      'requestId': fromUserId,
      'rejected_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.normal);

    // Invalidate cache so next fetch gets fresh data
    await _cacheService.invalidateCache(_friendRequestsKey);
    return true;
  }

  /// Remove friend (offline-first: queues for background sync)
  Future<bool> removeFriend(String friendUserId) async {
    // Queue for background sync - returns immediately
    _dataSyncService.queueSync('friend_remove', {
      'friendId': friendUserId,
      'removed_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.normal);

    // Invalidate cache so next fetch gets fresh data
    await _cacheService.invalidateCache(_friendsListKey);
    return true;
  }

  /// Get user profile with caching
  Future<UserProfile?> getUserProfile(String userId) async {
    final cacheKey = 'user_profile_$userId';

    // Try cached first
    final cached = await _cacheService.getCached<Map<String, dynamic>>(
      cacheKey,
      (data) => Map<String, dynamic>.from(data as Map),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshUserProfileInBackground(userId);
      }
      return _mapToUserProfile(cached);
    }

    // Offline fallback
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService
          .getCachedFallback<Map<String, dynamic>>(
            cacheKey,
            (data) => Map<String, dynamic>.from(data as Map),
          );
      return fallback != null ? _mapToUserProfile(fallback) : null;
    }

    // Fetch fresh
    return await _fetchAndCacheUserProfile(userId);
  }

  Future<UserProfile?> _fetchAndCacheUserProfile(String userId) async {
    try {
      final data = await _apiService.getUserProfile(userId);
      if (data == null) return null;

      await _cacheService.setCache<Map<String, dynamic>>(
        'user_profile_$userId',
        data,
        (d) => d,
        customTtl: const Duration(minutes: 5),
      );

      return _mapToUserProfile(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  void _refreshUserProfileInBackground(String userId) {
    _fetchAndCacheUserProfile(userId).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return null;
    });
  }

  /// Get friends list with cache-first pattern
  Future<List<UserProfile>> getFriends() async {
    // 1. Try cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _friendsListKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshFriendsInBackground();
      }
      return _sortFriends(
        cached.map((data) => _mapToUserProfile(data)).toList(),
      );
    }

    // 2. Offline fallback
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService
          .getCachedFallback<List<Map<String, dynamic>>>(
            _friendsListKey,
            (data) => List<Map<String, dynamic>>.from(
              (data as List).map((e) => Map<String, dynamic>.from(e)),
            ),
          );
      return fallback != null
          ? _sortFriends(
              fallback.map((data) => _mapToUserProfile(data)).toList(),
            )
          : [];
    }

    // 3. Fetch fresh
    return await _fetchAndCacheFriends();
  }

  Future<List<UserProfile>> _fetchAndCacheFriends() async {
    try {
      final response = await _apiService.getFriends();
      if (response == null || response['friends'] == null) return [];

      final friends = List<Map<String, dynamic>>.from(response['friends']);

      await _cacheService.setCache<List<Map<String, dynamic>>>(
        _friendsListKey,
        friends,
        (data) => data,
      );

      return _sortFriends(
        friends.map((data) => _mapToUserProfile(data)).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friends: $e');
      }
      return [];
    }
  }

  void _refreshFriendsInBackground() {
    _fetchAndCacheFriends().catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <UserProfile>[];
    });
  }

  List<UserProfile> _sortFriends(List<UserProfile> profiles) {
    profiles.sort((a, b) {
      if (a.status != b.status) {
        if (a.status == UserStatus.playing) return -1;
        if (b.status == UserStatus.playing) return 1;
        if (a.status == UserStatus.online) return -1;
        if (b.status == UserStatus.online) return 1;
      }
      return a.displayName.compareTo(b.displayName);
    });
    return profiles;
  }

  /// Get friend requests with cache-first pattern
  Future<List<FriendRequest>> getFriendRequests() async {
    // 1. Try cached data first
    final cached = await _cacheService.getCached<Map<String, dynamic>>(
      _friendRequestsKey,
      (data) => Map<String, dynamic>.from(data as Map),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshFriendRequestsInBackground();
      }
      return _parseFriendRequests(cached);
    }

    // 2. Offline fallback
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService
          .getCachedFallback<Map<String, dynamic>>(
            _friendRequestsKey,
            (data) => Map<String, dynamic>.from(data as Map),
          );
      return fallback != null ? _parseFriendRequests(fallback) : [];
    }

    // 3. Fetch fresh
    return await _fetchAndCacheFriendRequests();
  }

  Future<List<FriendRequest>> _fetchAndCacheFriendRequests() async {
    try {
      final response = await _apiService.getPendingRequests();
      if (response == null) return [];

      await _cacheService.setCache<Map<String, dynamic>>(
        _friendRequestsKey,
        response,
        (data) => data,
        customTtl: const Duration(minutes: 3),
      );

      return _parseFriendRequests(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friend requests: $e');
      }
      return [];
    }
  }

  void _refreshFriendRequestsInBackground() {
    _fetchAndCacheFriendRequests().catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <FriendRequest>[];
    });
  }

  List<FriendRequest> _parseFriendRequests(Map<String, dynamic> response) {
    final requests = <FriendRequest>[];

    if (response['received'] != null) {
      final received = List<Map<String, dynamic>>.from(response['received']);
      for (final data in received) {
        requests.add(_mapToFriendRequest(data, FriendRequestType.received));
      }
    }

    if (response['sent'] != null) {
      final sent = List<Map<String, dynamic>>.from(response['sent']);
      for (final data in sent) {
        requests.add(_mapToFriendRequest(data, FriendRequestType.sent));
      }
    }

    return requests;
  }

  /// Get friends leaderboard with caching (uses LeaderboardService cache key)
  Future<List<UserProfile>> getFriendsLeaderboard() async {
    try {
      final response = await _apiService.getFriendsLeaderboard();
      if (response == null || response['entries'] == null) return [];

      final entries = List<Map<String, dynamic>>.from(response['entries']);
      final profiles = entries.map((entry) {
        return _mapToUserProfile({
          'uid': entry['user_id'],
          'displayName': entry['display_name'],
          'username': entry['username'],
          'photoURL': entry['photo_url'],
          'highScore': entry['high_score'] ?? entry['score'],
          'status': 'offline',
        });
      }).toList();

      profiles.sort((a, b) => b.highScore.compareTo(a.highScore));

      return profiles;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friends leaderboard: $e');
      }
      return [];
    }
  }

  /// Update user status (requires online)
  Future<void> updateUserStatus(
    UserStatus status, {
    String? statusMessage,
  }) async {
    if (!_connectivityService.isOnline) return;

    try {
      await _apiService.updateProfile({
        'status': status.name,
        'status_message': ?statusMessage,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user status: $e');
      }
    }
  }

  /// Update user privacy setting (requires online)
  Future<bool> updatePrivacySetting(bool isPublic) async {
    if (!_connectivityService.isOnline) return false;

    try {
      final result = await _apiService.updateProfile({'is_public': isPublic});
      return result != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating privacy setting: $e');
      }
      return false;
    }
  }

  /// Check if we have cached friends data
  Future<bool> hasCachedFriends() async {
    return await _cacheService.hasCachedData(_friendsListKey);
  }

  /// Clear all social cache
  Future<void> clearCache() async {
    await _cacheService.invalidateCache(_friendsListKey);
    await _cacheService.invalidateCache(_friendRequestsKey);
    await _cacheService.invalidateCachePattern('user_profile_');
  }

  // Stream friends for real-time updates (polling-based)
  Stream<List<UserProfile>> watchFriends() {
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => null,
    ).asyncMap((_) => getFriends()).distinct();
  }

  // Stream friend requests for real-time updates (polling-based)
  Stream<List<FriendRequest>> watchFriendRequests() {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getFriendRequests())
        .where(
          (requests) =>
              requests
                  .where((r) => r.type == FriendRequestType.received)
                  .isNotEmpty ||
              requests.isEmpty,
        )
        .map(
          (requests) => requests
              .where((r) => r.type == FriendRequestType.received)
              .toList(),
        )
        .distinct();
  }

  /// Map backend response to UserProfile
  UserProfile _mapToUserProfile(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['id']?.toString() ?? data['uid'] ?? data['user_id'] ?? '',
      displayName: data['display_name'] ?? data['displayName'] ?? 'Anonymous',
      username: data['username'] ?? data['display_name'] ?? 'Anonymous',
      email: data['email'] ?? '',
      photoUrl: data['photo_url'] ?? data['photoURL'] ?? data['photoUrl'],
      isPublic: data['is_public'] ?? data['isPublic'] ?? true,
      status: _parseUserStatus(data['status']),
      statusMessage: data['status_message'] ?? data['statusMessage'],
      highScore: data['high_score'] ?? data['highScore'] ?? 0,
      totalGamesPlayed:
          data['total_games_played'] ?? data['totalGamesPlayed'] ?? 0,
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(
        data['friend_requests'] ?? data['friendRequests'] ?? [],
      ),
      sentRequests: List<String>.from(
        data['sent_requests'] ?? data['sentRequests'] ?? [],
      ),
      joinedDate: _parseDateTime(
        data['joined_date'] ?? data['joinedDate'] ?? data['created_at'],
      ),
      lastSeen: _parseDateTime(data['last_seen'] ?? data['lastSeen']),
    );
  }

  /// Map backend response to FriendRequest
  FriendRequest _mapToFriendRequest(
    Map<String, dynamic> data,
    FriendRequestType type,
  ) {
    return FriendRequest(
      id: data['id']?.toString() ?? '',
      fromUserId: data['from_user_id'] ?? data['fromUserId'] ?? '',
      toUserId: data['to_user_id'] ?? data['toUserId'] ?? '',
      fromUserName: data['from_user_name'] ?? data['fromUserName'] ?? 'Unknown',
      toUserName: data['to_user_name'] ?? data['toUserName'] ?? '',
      fromUserPhotoUrl: data['from_user_photo_url'] ?? data['fromUserPhotoUrl'],
      createdAt: _parseDateTime(data['created_at'] ?? data['createdAt']),
      type: type,
    );
  }

  UserStatus _parseUserStatus(dynamic status) {
    if (status == null) return UserStatus.offline;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'online':
        return UserStatus.online;
      case 'playing':
        return UserStatus.playing;
      case 'offline':
      default:
        return UserStatus.offline;
    }
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
