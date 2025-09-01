import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/services/auth_service.dart';

class TournamentService {
  static TournamentService? _instance;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TournamentService._internal();

  factory TournamentService() {
    _instance ??= TournamentService._internal();
    return _instance!;
  }

  // Get all active and upcoming tournaments
  Future<List<Tournament>> getActiveTournaments() async {
    try {
      final now = Timestamp.now();
      
      final query = await _firestore
          .collection('tournaments')
          .where('endDate', isGreaterThan: now)
          .orderBy('endDate')
          .orderBy('startDate')
          .limit(20)
          .get();

      final tournaments = <Tournament>[];
      final currentUserId = _authService.currentUser?.uid;

      for (final doc in query.docs) {
        final tournamentData = doc.data();
        
        // Get user-specific data if signed in
        if (currentUserId != null) {
          final userParticipation = await _getUserTournamentData(doc.id, currentUserId);
          tournamentData.addAll(userParticipation);
        }

        final tournament = Tournament.fromJson(tournamentData);
        
        // Update status based on current time
        final updatedTournament = _updateTournamentStatus(tournament);
        tournaments.add(updatedTournament);
      }

      return tournaments;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting active tournaments: $e');
      }
      return [];
    }
  }

  // Get tournament history (ended tournaments)
  Future<List<Tournament>> getTournamentHistory({int limit = 10}) async {
    try {
      final now = Timestamp.now();
      
      final query = await _firestore
          .collection('tournaments')
          .where('endDate', isLessThan: now)
          .orderBy('endDate', descending: true)
          .limit(limit)
          .get();

      final tournaments = <Tournament>[];
      final currentUserId = _authService.currentUser?.uid;

      for (final doc in query.docs) {
        final tournamentData = doc.data();
        
        if (currentUserId != null) {
          final userParticipation = await _getUserTournamentData(doc.id, currentUserId);
          tournamentData.addAll(userParticipation);
        }

        tournaments.add(Tournament.fromJson(tournamentData));
      }

      return tournaments;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tournament history: $e');
      }
      return [];
    }
  }

  // Get specific tournament by ID
  Future<Tournament?> getTournament(String tournamentId) async {
    try {
      final doc = await _firestore.collection('tournaments').doc(tournamentId).get();
      
      if (!doc.exists) return null;

      final tournamentData = doc.data()!;
      final currentUserId = _authService.currentUser?.uid;

      if (currentUserId != null) {
        final userParticipation = await _getUserTournamentData(tournamentId, currentUserId);
        tournamentData.addAll(userParticipation);
      }

      final tournament = Tournament.fromJson(tournamentData);
      return _updateTournamentStatus(tournament);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tournament: $e');
      }
      return null;
    }
  }

  // Join a tournament
  Future<bool> joinTournament(String tournamentId) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final tournament = await getTournament(tournamentId);
      if (tournament == null || !tournament.status.canJoin) return false;

      // Check if already joined
      if (tournament.hasJoined) return false;

      // Check max participants
      if (tournament.currentParticipants >= tournament.maxParticipants) return false;

      final batch = _firestore.batch();

      // Add user to tournament participants
      final participantDoc = _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(currentUser.uid);

      batch.set(participantDoc, {
        'userId': currentUser.uid,
        'displayName': currentUser.displayName ?? 'Player',
        'photoUrl': currentUser.photoURL,
        'highScore': 0,
        'attempts': 0,
        'joinedDate': FieldValue.serverTimestamp(),
        'lastScoreDate': FieldValue.serverTimestamp(),
        'gameStats': {},
      });

      // Update tournament participant count
      final tournamentDoc = _firestore.collection('tournaments').doc(tournamentId);
      batch.update(tournamentDoc, {
        'currentParticipants': FieldValue.increment(1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining tournament: $e');
      }
      return false;
    }
  }

  // Submit score to tournament
  Future<bool> submitScore(String tournamentId, int score, Map<String, dynamic> gameStats) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      final tournament = await getTournament(tournamentId);
      if (tournament == null || !tournament.status.canSubmitScore) return false;

      // Auto-join if not already joined
      if (!tournament.hasJoined) {
        final joined = await joinTournament(tournamentId);
        if (!joined) return false;
      }

      final participantDoc = _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(currentUser.uid);

      // Update participant data
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(participantDoc);
        
        if (!snapshot.exists) return;

        final currentData = snapshot.data()!;
        final currentHighScore = currentData['highScore'] ?? 0;
        final currentAttempts = currentData['attempts'] ?? 0;

        final updates = <String, dynamic>{
          'attempts': currentAttempts + 1,
          'lastScoreDate': FieldValue.serverTimestamp(),
          'gameStats': gameStats,
        };

        // Only update high score if new score is better
        if (score > currentHighScore) {
          updates['highScore'] = score;
        }

        transaction.update(participantDoc, updates);
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting tournament score: $e');
      }
      return false;
    }
  }

  // Get tournament leaderboard
  Future<List<TournamentParticipant>> getTournamentLeaderboard(String tournamentId, {int limit = 50}) async {
    try {
      final query = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .where('highScore', isGreaterThan: 0)
          .orderBy('highScore', descending: true)
          .orderBy('lastScoreDate')
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => TournamentParticipant.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tournament leaderboard: $e');
      }
      return [];
    }
  }

  // Get user's tournament statistics
  Future<Map<String, dynamic>> getUserTournamentStats() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return {};

      // Get all tournaments user has participated in
      final participations = await _firestore
          .collectionGroup('participants')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      int totalTournaments = participations.docs.length;
      int totalAttempts = 0;
      int bestScore = 0;
      int wins = 0;
      int topThreeFinishes = 0;

      for (final doc in participations.docs) {
        final data = doc.data();
        final attempts = data['attempts'] ?? 0;
        final highScore = data['highScore'] ?? 0;
        
        totalAttempts += attempts as int;
        if (highScore > bestScore) {
          bestScore = highScore;
        }

        // Get tournament to check final ranking
        final tournamentId = doc.reference.parent.parent!.id;
        final leaderboard = await getTournamentLeaderboard(tournamentId, limit: 3);
        
        for (int i = 0; i < leaderboard.length; i++) {
          if (leaderboard[i].userId == currentUser.uid) {
            if (i == 0) wins++;
            topThreeFinishes++;
            break;
          }
        }
      }

      return {
        'totalTournaments': totalTournaments,
        'totalAttempts': totalAttempts,
        'bestScore': bestScore,
        'wins': wins,
        'topThreeFinishes': topThreeFinishes,
        'winRate': totalTournaments > 0 ? (wins / totalTournaments * 100).round() : 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user tournament stats: $e');
      }
      return {};
    }
  }

  // Create a new tournament (admin function - could be used for testing)
  Future<String?> createTournament(Tournament tournament) async {
    try {
      final doc = await _firestore.collection('tournaments').add(tournament.toJson());
      return doc.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating tournament: $e');
      }
      return null;
    }
  }

  // Helper method to get user-specific tournament data
  Future<Map<String, dynamic>> _getUserTournamentData(String tournamentId, String userId) async {
    try {
      final participantDoc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(userId)
          .get();

      if (participantDoc.exists) {
        final data = participantDoc.data()!;
        return {
          'userBestScore': data['highScore'],
          'userAttempts': data['attempts'],
          'userLastAttempt': data['lastScoreDate']?.toDate()?.toIso8601String(),
        };
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  // Helper method to update tournament status based on current time
  Tournament _updateTournamentStatus(Tournament tournament) {
    final now = DateTime.now();
    
    TournamentStatus newStatus = tournament.status;
    
    if (now.isBefore(tournament.startDate)) {
      newStatus = TournamentStatus.upcoming;
    } else if (now.isAfter(tournament.endDate)) {
      newStatus = TournamentStatus.ended;
    } else {
      newStatus = TournamentStatus.active;
    }

    if (newStatus != tournament.status) {
      return tournament.copyWith(status: newStatus);
    }

    return tournament;
  }

  // Stream tournaments for real-time updates
  Stream<List<Tournament>> watchActiveTournaments() {
    final now = Timestamp.now();
    
    return _firestore
        .collection('tournaments')
        .where('endDate', isGreaterThan: now)
        .orderBy('endDate')
        .orderBy('startDate')
        .limit(20)
        .snapshots()
        .asyncMap((snapshot) async {
      final tournaments = <Tournament>[];
      final currentUserId = _authService.currentUser?.uid;

      for (final doc in snapshot.docs) {
        final tournamentData = doc.data();
        
        if (currentUserId != null) {
          final userParticipation = await _getUserTournamentData(doc.id, currentUserId);
          tournamentData.addAll(userParticipation);
        }

        final tournament = Tournament.fromJson(tournamentData);
        tournaments.add(_updateTournamentStatus(tournament));
      }

      return tournaments;
    });
  }

  // Stream tournament leaderboard for real-time updates
  Stream<List<TournamentParticipant>> watchTournamentLeaderboard(String tournamentId, {int limit = 50}) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .where('highScore', isGreaterThan: 0)
        .orderBy('highScore', descending: true)
        .orderBy('lastScoreDate')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TournamentParticipant.fromJson(doc.data()))
            .toList());
  }

  // Generate sample tournaments for testing
  Future<void> createSampleTournaments() async {
    if (!kDebugMode) return; // Only in debug mode

    final now = DateTime.now();
    
    final tournaments = [
      Tournament(
        id: 'daily_${now.millisecondsSinceEpoch}',
        name: 'Daily Speed Challenge',
        description: 'Test your reflexes in this fast-paced daily challenge!',
        type: TournamentType.daily,
        status: TournamentStatus.active,
        gameMode: TournamentGameMode.speedRun,
        startDate: now.subtract(const Duration(hours: 2)),
        endDate: now.add(const Duration(hours: 22)),
        rewards: {
          1: const TournamentReward(
            id: 'speed_master',
            name: 'Speed Master',
            description: 'Fastest snake in the daily challenge',
            type: 'badge',
            coins: 100,
          ),
          2: const TournamentReward(
            id: 'speed_runner',
            name: 'Speed Runner',
            description: 'Second place in daily challenge',
            type: 'badge',
            coins: 50,
          ),
          3: const TournamentReward(
            id: 'quick_snake',
            name: 'Quick Snake',
            description: 'Third place in daily challenge',
            type: 'badge',
            coins: 25,
          ),
        },
      ),
      Tournament(
        id: 'weekly_${now.millisecondsSinceEpoch}',
        name: 'Weekly Championship',
        description: 'Compete with players worldwide in the weekly tournament!',
        type: TournamentType.weekly,
        status: TournamentStatus.active,
        gameMode: TournamentGameMode.classic,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        maxParticipants: 500,
        rewards: {
          1: const TournamentReward(
            id: 'weekly_champion',
            name: 'Weekly Champion',
            description: 'Champion of the weekly tournament',
            type: 'title',
            coins: 500,
          ),
          2: const TournamentReward(
            id: 'weekly_runner_up',
            name: 'Weekly Runner-up',
            description: 'Second place in weekly tournament',
            type: 'badge',
            coins: 250,
          ),
          3: const TournamentReward(
            id: 'weekly_bronze',
            name: 'Weekly Bronze',
            description: 'Third place in weekly tournament',
            type: 'badge',
            coins: 100,
          ),
        },
      ),
      Tournament(
        id: 'perfect_${now.millisecondsSinceEpoch}',
        name: 'Perfect Game Challenge',
        description: 'One mistake and you\'re out! Can you achieve perfection?',
        type: TournamentType.special,
        status: TournamentStatus.upcoming,
        gameMode: TournamentGameMode.perfectGame,
        startDate: now.add(const Duration(hours: 4)),
        endDate: now.add(const Duration(days: 1)),
        maxParticipants: 100,
        rewards: {
          1: const TournamentReward(
            id: 'perfectionist',
            name: 'Perfectionist',
            description: 'Achieved perfection in the impossible challenge',
            type: 'achievement',
            coins: 1000,
          ),
        },
      ),
    ];

    for (final tournament in tournaments) {
      await createTournament(tournament);
    }
  }
}