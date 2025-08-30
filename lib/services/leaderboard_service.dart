import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('highScore', isGreaterThan: 0)
          .orderBy('highScore', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'displayName': doc.data()['displayName'] ?? 'Anonymous',
                'highScore': doc.data()['highScore'] ?? 0,
                'photoURL': doc.data()['photoURL'],
                'totalGamesPlayed': doc.data()['totalGamesPlayed'] ?? 0,
                'isAnonymous': doc.data()['isAnonymous'] ?? false,
                'highScoreDate': doc.data()['highScoreDate'],
              })
          .toList();
    } catch (e) {
      // Error:Error fetching global leaderboard: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getGlobalLeaderboardStream({int limit = 50}) {
    return _firestore
        .collection('users')
        .where('highScore', isGreaterThan: 0)
        .orderBy('highScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'uid': doc.id,
                  'displayName': doc.data()['displayName'] ?? 'Anonymous',
                  'highScore': doc.data()['highScore'] ?? 0,
                  'photoURL': doc.data()['photoURL'],
                  'totalGamesPlayed': doc.data()['totalGamesPlayed'] ?? 0,
                  'isAnonymous': doc.data()['isAnonymous'] ?? false,
                  'highScoreDate': doc.data()['highScoreDate'],
                })
            .toList());
  }

  Future<Map<String, dynamic>?> getUserRank(String userId) async {
    try {
      // Get user's score
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;
      
      final userScore = userDoc.data()?['highScore'] ?? 0;
      
      // Count users with higher scores
      final higherScoresCount = await _firestore
          .collection('users')
          .where('highScore', isGreaterThan: userScore)
          .get();
      
      // User's rank is the count of higher scores + 1
      final rank = higherScoresCount.docs.length + 1;
      
      // Get total number of users with scores > 0
      final totalPlayersCount = await _firestore
          .collection('users')
          .where('highScore', isGreaterThan: 0)
          .get();
      
      return {
        'rank': rank,
        'totalPlayers': totalPlayersCount.docs.length,
        'userScore': userScore,
        'percentile': totalPlayersCount.docs.isNotEmpty 
          ? ((totalPlayersCount.docs.length - rank + 1) / totalPlayersCount.docs.length * 100).round()
          : 0,
      };
    } catch (e) {
      // Error:Error getting user rank: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      // Get scores from the last 7 days
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('highScore', isGreaterThan: 0)
          .where('highScoreDate', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
          .orderBy('highScore', descending: true)
          .orderBy('highScoreDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'displayName': doc.data()['displayName'] ?? 'Anonymous',
                'highScore': doc.data()['highScore'] ?? 0,
                'photoURL': doc.data()['photoURL'],
                'totalGamesPlayed': doc.data()['totalGamesPlayed'] ?? 0,
                'isAnonymous': doc.data()['isAnonymous'] ?? false,
                'highScoreDate': doc.data()['highScoreDate'],
              })
          .toList();
    } catch (e) {
      // Error:Error fetching weekly leaderboard: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getWeeklyLeaderboardStream({int limit = 50}) {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    return _firestore
        .collection('users')
        .where('highScore', isGreaterThan: 0)
        .where('highScoreDate', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
        .orderBy('highScore', descending: true)
        .orderBy('highScoreDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'uid': doc.id,
                  'displayName': doc.data()['displayName'] ?? 'Anonymous',
                  'highScore': doc.data()['highScore'] ?? 0,
                  'photoURL': doc.data()['photoURL'],
                  'totalGamesPlayed': doc.data()['totalGamesPlayed'] ?? 0,
                  'isAnonymous': doc.data()['isAnonymous'] ?? false,
                  'highScoreDate': doc.data()['highScoreDate'],
                })
            .toList());
  }

  Future<List<Map<String, dynamic>>> getFriendsLeaderboard(List<String> friendIds, {int limit = 50}) async {
    try {
      if (friendIds.isEmpty) return [];
      
      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .where('highScore', isGreaterThan: 0)
          .orderBy('highScore', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'displayName': doc.data()['displayName'] ?? 'Anonymous',
                'highScore': doc.data()['highScore'] ?? 0,
                'photoURL': doc.data()['photoURL'],
                'totalGamesPlayed': doc.data()['totalGamesPlayed'] ?? 0,
                'isAnonymous': doc.data()['isAnonymous'] ?? false,
                'highScoreDate': doc.data()['highScoreDate'],
              })
          .toList();
    } catch (e) {
      // Error:Error fetching friends leaderboard: $e');
      return [];
    }
  }
}