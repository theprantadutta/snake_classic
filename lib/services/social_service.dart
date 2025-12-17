import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/services/api_service.dart';

class SocialService {
  static SocialService? _instance;
  final ApiService _apiService = ApiService();

  SocialService._internal();

  factory SocialService() {
    _instance ??= SocialService._internal();
    return _instance!;
  }

  // Search for users by username, display name or email
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.length < 2) return [];

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

  // Send friend request
  Future<bool> sendFriendRequest(String toUserId) async {
    try {
      final result = await _apiService.sendFriendRequest(userId: toUserId);
      return result != null && result['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending friend request: $e');
      }
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String fromUserId) async {
    try {
      final result = await _apiService.acceptFriendRequest(fromUserId);
      return result != null && result['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting friend request: $e');
      }
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String fromUserId) async {
    try {
      final result = await _apiService.rejectFriendRequest(fromUserId);
      return result != null && result['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting friend request: $e');
      }
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String friendUserId) async {
    try {
      final result = await _apiService.removeFriend(friendUserId);
      return result != null && result['success'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error removing friend: $e');
      }
      return false;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final data = await _apiService.getUserProfile(userId);
      if (data == null) return null;
      return _mapToUserProfile(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  // Get friends list
  Future<List<UserProfile>> getFriends() async {
    try {
      final response = await _apiService.getFriends();
      if (response == null || response['friends'] == null) return [];

      final friends = List<Map<String, dynamic>>.from(response['friends']);
      final profiles = friends.map((data) => _mapToUserProfile(data)).toList();

      // Sort friends by status (online first) and then by name
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
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friends: $e');
      }
      return [];
    }
  }

  // Get friend requests
  Future<List<FriendRequest>> getFriendRequests() async {
    try {
      final response = await _apiService.getPendingRequests();
      if (response == null) return [];

      final requests = <FriendRequest>[];

      // Get received requests
      if (response['received'] != null) {
        final received = List<Map<String, dynamic>>.from(response['received']);
        for (final data in received) {
          requests.add(_mapToFriendRequest(data, FriendRequestType.received));
        }
      }

      // Get sent requests
      if (response['sent'] != null) {
        final sent = List<Map<String, dynamic>>.from(response['sent']);
        for (final data in sent) {
          requests.add(_mapToFriendRequest(data, FriendRequestType.sent));
        }
      }

      return requests;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friend requests: $e');
      }
      return [];
    }
  }

  // Get friends leaderboard
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

      // Sort by high score
      profiles.sort((a, b) => b.highScore.compareTo(a.highScore));

      return profiles;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friends leaderboard: $e');
      }
      return [];
    }
  }

  // Update user status
  Future<void> updateUserStatus(
    UserStatus status, {
    String? statusMessage,
  }) async {
    try {
      await _apiService.updateProfile({
        'status': status.name,
        if (statusMessage != null) 'status_message': statusMessage,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user status: $e');
      }
    }
  }

  // Update user privacy setting
  Future<bool> updatePrivacySetting(bool isPublic) async {
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

  // Stream friends for real-time updates (polling-based)
  Stream<List<UserProfile>> watchFriends() {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getFriends())
        .distinct();
  }

  // Stream friend requests for real-time updates (polling-based)
  Stream<List<FriendRequest>> watchFriendRequests() {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getFriendRequests())
        .where((requests) => requests.where((r) => r.type == FriendRequestType.received).isNotEmpty || requests.isEmpty)
        .map((requests) => requests.where((r) => r.type == FriendRequestType.received).toList())
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
      totalGamesPlayed: data['total_games_played'] ?? data['totalGamesPlayed'] ?? 0,
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(data['friend_requests'] ?? data['friendRequests'] ?? []),
      sentRequests: List<String>.from(data['sent_requests'] ?? data['sentRequests'] ?? []),
      joinedDate: _parseDateTime(data['joined_date'] ?? data['joinedDate'] ?? data['created_at']),
      lastSeen: _parseDateTime(data['last_seen'] ?? data['lastSeen']),
    );
  }

  /// Map backend response to FriendRequest
  FriendRequest _mapToFriendRequest(Map<String, dynamic> data, FriendRequestType type) {
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
