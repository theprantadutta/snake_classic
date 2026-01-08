import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';

/// Friend data model
class Friend {
  final String userId;
  final String displayName;
  final String? username;
  final String? photoUrl;
  final int highScore;
  final bool isOnline;
  final DateTime? lastSeen;

  const Friend({
    required this.userId,
    required this.displayName,
    this.username,
    this.photoUrl,
    this.highScore = 0,
    this.isOnline = false,
    this.lastSeen,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      userId: json['user_id'] ?? json['userId'] ?? json['id'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? 'Unknown',
      username: json['username'],
      photoUrl: json['photo_url'] ?? json['photoUrl'],
      highScore: json['high_score'] ?? json['highScore'] ?? 0,
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      lastSeen: json['last_seen'] != null || json['lastSeen'] != null
          ? DateTime.tryParse(json['last_seen'] ?? json['lastSeen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'display_name': displayName,
    'username': username,
    'photo_url': photoUrl,
    'high_score': highScore,
    'is_online': isOnline,
    'last_seen': lastSeen?.toIso8601String(),
  };
}

/// Friend request data model
class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String fromDisplayName;
  final String? fromPhotoUrl;
  final DateTime sentAt;

  const FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.fromDisplayName,
    this.fromPhotoUrl,
    required this.sentAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requestId: json['request_id'] ?? json['requestId'] ?? json['id'] ?? '',
      fromUserId: json['from_user_id'] ?? json['fromUserId'] ?? '',
      fromDisplayName:
          json['from_display_name'] ?? json['fromDisplayName'] ?? 'Unknown',
      fromPhotoUrl: json['from_photo_url'] ?? json['fromPhotoUrl'],
      sentAt:
          DateTime.tryParse(json['sent_at'] ?? json['sentAt'] ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'from_user_id': fromUserId,
    'from_display_name': fromDisplayName,
    'from_photo_url': fromPhotoUrl,
    'sent_at': sentAt.toIso8601String(),
  };
}

/// Friends list data
class FriendsData {
  final List<Friend> friends;
  final int totalCount;

  const FriendsData({required this.friends, required this.totalCount});

  factory FriendsData.fromJson(Map<String, dynamic> json) {
    final friendsJson = json['friends'] as List<dynamic>? ?? [];
    return FriendsData(
      friends: friendsJson.map((e) => Friend.fromJson(e)).toList(),
      totalCount:
          json['total_count'] ?? json['totalCount'] ?? friendsJson.length,
    );
  }

  Map<String, dynamic> toJson() => {
    'friends': friends.map((e) => e.toJson()).toList(),
    'total_count': totalCount,
  };
}

/// Pending requests data
class PendingRequestsData {
  final List<FriendRequest> requests;
  final int totalCount;

  const PendingRequestsData({required this.requests, required this.totalCount});

  factory PendingRequestsData.fromJson(Map<String, dynamic> json) {
    final requestsJson = json['requests'] as List<dynamic>? ?? [];
    return PendingRequestsData(
      requests: requestsJson.map((e) => FriendRequest.fromJson(e)).toList(),
      totalCount:
          json['total_count'] ?? json['totalCount'] ?? requestsJson.length,
    );
  }

  Map<String, dynamic> toJson() => {
    'requests': requests.map((e) => e.toJson()).toList(),
    'total_count': totalCount,
  };
}

/// Abstract repository for social operations
abstract class SocialRepository {
  /// Get friends list
  /// Cache TTL: 10 minutes (Tier 2)
  Future<Either<Failure, FriendsData>> getFriends();

  /// Get pending friend requests
  /// Cache TTL: 2 minutes (Tier 3 - real-time feel needed)
  Future<Either<Failure, PendingRequestsData>> getPendingRequests();

  /// Search users
  /// No caching - real-time search
  Future<Either<Failure, List<Friend>>> searchUsers(
    String query, {
    int limit = 20,
  });

  /// Send friend request
  /// No caching
  Future<Either<Failure, void>> sendFriendRequest({
    String? username,
    String? userId,
  });

  /// Accept friend request
  /// No caching
  Future<Either<Failure, void>> acceptFriendRequest(String requestId);

  /// Reject friend request
  /// No caching
  Future<Either<Failure, void>> rejectFriendRequest(String requestId);

  /// Remove friend
  /// No caching
  Future<Either<Failure, void>> removeFriend(String friendId);

  /// Force refresh social data
  Future<void> refresh();
}
