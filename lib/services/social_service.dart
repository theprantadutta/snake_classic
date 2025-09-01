import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/services/auth_service.dart';

class SocialService {
  static SocialService? _instance;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SocialService._internal();

  factory SocialService() {
    _instance ??= SocialService._internal();
    return _instance!;
  }

  // Search for users by display name or email
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.length < 2) return [];
    
    try {
      final currentUserId = _authService.currentUser?.uid;
      if (currentUserId == null) return [];

      // Search by display name
      final nameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .where('isPublic', isEqualTo: true)
          .limit(20)
          .get();

      // Search by email if query looks like an email
      QuerySnapshot? emailQuery;
      if (query.contains('@')) {
        emailQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: query.toLowerCase())
            .where('isPublic', isEqualTo: true)
            .limit(5)
            .get();
      }

      final users = <UserProfile>[];
      final seenUids = <String>{};

      // Add name search results
      for (final doc in nameQuery.docs) {
        final data = doc.data();
        final user = UserProfile.fromJson(data);
        
        // Skip current user and duplicates
        if (user.uid != currentUserId && !seenUids.contains(user.uid)) {
          users.add(user);
          seenUids.add(user.uid);
        }
      }

      // Add email search results
      if (emailQuery != null) {
        for (final doc in emailQuery.docs) {
          final data = doc.data();
          final user = UserProfile.fromJson(data);
          
          // Skip current user and duplicates
          if (user.uid != currentUserId && !seenUids.contains(user.uid)) {
            users.add(user);
            seenUids.add(user.uid);
          }
        }
      }

      return users;
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final fromUserId = currentUser.uid;
      if (fromUserId == toUserId) return false;

      // Check if already friends or request already exists
      final fromProfile = await getUserProfile(fromUserId);
      final toProfile = await getUserProfile(toUserId);
      
      if (fromProfile == null || toProfile == null) return false;
      
      if (fromProfile.isFriend(toUserId) || 
          fromProfile.hasSentRequestTo(toUserId) || 
          toProfile.hasSentRequestTo(fromUserId)) {
        return false;
      }

      final batch = _firestore.batch();

      // Create friend request document
      final requestDoc = _firestore.collection('friendRequests').doc();
      batch.set(requestDoc, {
        'id': requestDoc.id,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'fromUserName': currentUser.displayName ?? 'Unknown',
        'toUserName': toProfile.displayName,
        'fromUserPhotoUrl': currentUser.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update sender's sent requests
      final fromUserDoc = _firestore.collection('users').doc(fromUserId);
      batch.update(fromUserDoc, {
        'sentRequests': FieldValue.arrayUnion([toUserId]),
      });

      // Update receiver's friend requests
      final toUserDoc = _firestore.collection('users').doc(toUserId);
      batch.update(toUserDoc, {
        'friendRequests': FieldValue.arrayUnion([fromUserId]),
      });

      await batch.commit();
      return true;
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final toUserId = currentUser.uid;
      final batch = _firestore.batch();

      // Add to friends lists
      final fromUserDoc = _firestore.collection('users').doc(fromUserId);
      batch.update(fromUserDoc, {
        'friends': FieldValue.arrayUnion([toUserId]),
        'sentRequests': FieldValue.arrayRemove([toUserId]),
      });

      final toUserDoc = _firestore.collection('users').doc(toUserId);
      batch.update(toUserDoc, {
        'friends': FieldValue.arrayUnion([fromUserId]),
        'friendRequests': FieldValue.arrayRemove([fromUserId]),
      });

      // Remove friend request document
      final requestQuery = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      for (final doc in requestQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final toUserId = currentUser.uid;
      final batch = _firestore.batch();

      // Remove from sent and received requests
      final fromUserDoc = _firestore.collection('users').doc(fromUserId);
      batch.update(fromUserDoc, {
        'sentRequests': FieldValue.arrayRemove([toUserId]),
      });

      final toUserDoc = _firestore.collection('users').doc(toUserId);
      batch.update(toUserDoc, {
        'friendRequests': FieldValue.arrayRemove([fromUserId]),
      });

      // Remove friend request document
      final requestQuery = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      for (final doc in requestQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final userId = currentUser.uid;
      final batch = _firestore.batch();

      // Remove from both users' friends lists
      final userDoc = _firestore.collection('users').doc(userId);
      batch.update(userDoc, {
        'friends': FieldValue.arrayRemove([friendUserId]),
      });

      final friendDoc = _firestore.collection('users').doc(friendUserId);
      batch.update(friendDoc, {
        'friends': FieldValue.arrayRemove([userId]),
      });

      await batch.commit();
      return true;
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
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return [];

      final userProfile = await getUserProfile(currentUser.uid);
      if (userProfile == null || userProfile.friends.isEmpty) return [];

      final friends = <UserProfile>[];
      
      // Batch get friends (Firestore allows up to 10 documents in a single 'in' query)
      final friendIds = userProfile.friends;
      final chunks = <List<String>>[];
      
      for (int i = 0; i < friendIds.length; i += 10) {
        chunks.add(friendIds.sublist(i, (i + 10 < friendIds.length) ? i + 10 : friendIds.length));
      }

      for (final chunk in chunks) {
        final query = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in query.docs) {
          friends.add(UserProfile.fromJson(doc.data()));
        }
      }

      // Sort friends by status (online first) and then by name
      friends.sort((a, b) {
        if (a.status != b.status) {
          if (a.status == UserStatus.playing) return -1;
          if (b.status == UserStatus.playing) return 1;
          if (a.status == UserStatus.online) return -1;
          if (b.status == UserStatus.online) return 1;
        }
        return a.displayName.compareTo(b.displayName);
      });

      return friends;
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return [];

      final userId = currentUser.uid;
      final requests = <FriendRequest>[];

      // Get received requests
      final receivedQuery = await _firestore
          .collection('friendRequests')
          .where('toUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      for (final doc in receivedQuery.docs) {
        requests.add(FriendRequest.fromJson(doc.data(), FriendRequestType.received));
      }

      // Get sent requests
      final sentQuery = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      for (final doc in sentQuery.docs) {
        requests.add(FriendRequest.fromJson(doc.data(), FriendRequestType.sent));
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
      final friends = await getFriends();
      final currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        // Include current user in the leaderboard
        final currentProfile = await getUserProfile(currentUser.uid);
        if (currentProfile != null) {
          friends.add(currentProfile);
        }
      }

      // Sort by high score
      friends.sort((a, b) => b.highScore.compareTo(a.highScore));
      
      return friends;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting friends leaderboard: $e');
      }
      return [];
    }
  }

  // Update user status
  Future<void> updateUserStatus(UserStatus status, {String? statusMessage}) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'status': status.name,
        'lastSeen': FieldValue.serverTimestamp(),
        if (statusMessage != null) 'statusMessage': statusMessage,
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'isPublic': isPublic,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating privacy setting: $e');
      }
      return false;
    }
  }

  // Stream friends for real-time updates
  Stream<List<UserProfile>> watchFriends() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return <UserProfile>[];
      
      final userData = userDoc.data()!;
      final friendIds = List<String>.from(userData['friends'] ?? []);
      
      if (friendIds.isEmpty) return <UserProfile>[];

      final friends = <UserProfile>[];
      
      // Batch get friends
      final chunks = <List<String>>[];
      for (int i = 0; i < friendIds.length; i += 10) {
        chunks.add(friendIds.sublist(i, (i + 10 < friendIds.length) ? i + 10 : friendIds.length));
      }

      for (final chunk in chunks) {
        final query = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in query.docs) {
          friends.add(UserProfile.fromJson(doc.data()));
        }
      }

      // Sort friends by status and name
      friends.sort((a, b) {
        if (a.status != b.status) {
          if (a.status == UserStatus.playing) return -1;
          if (b.status == UserStatus.playing) return 1;
          if (a.status == UserStatus.online) return -1;
          if (b.status == UserStatus.online) return 1;
        }
        return a.displayName.compareTo(b.displayName);
      });

      return friends;
    });
  }

  // Stream friend requests for real-time updates
  Stream<List<FriendRequest>> watchFriendRequests() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendRequest.fromJson(doc.data(), FriendRequestType.received))
          .toList();
    });
  }
}