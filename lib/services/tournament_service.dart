import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/services/api_service.dart';

class TournamentService {
  static TournamentService? _instance;
  final ApiService _apiService = ApiService();

  TournamentService._internal();

  factory TournamentService() {
    _instance ??= TournamentService._internal();
    return _instance!;
  }

  // Get all active and upcoming tournaments
  Future<List<Tournament>> getActiveTournaments() async {
    try {
      final response = await _apiService.listTournaments(status: 'active');

      if (response == null || response['tournaments'] == null) return [];

      final tournaments = List<Map<String, dynamic>>.from(response['tournaments']);
      return tournaments.map((data) => _mapToTournament(data)).toList();
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
      final response = await _apiService.listTournaments(
        status: 'ended',
        limit: limit,
      );

      if (response == null || response['tournaments'] == null) return [];

      final tournaments = List<Map<String, dynamic>>.from(response['tournaments']);
      return tournaments.map((data) => _mapToTournament(data)).toList();
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
      final data = await _apiService.getTournament(tournamentId);
      if (data == null) return null;
      return _mapToTournament(data);
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
      final result = await _apiService.joinTournament(tournamentId);
      return result != null && result['success'] == true;
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
      final result = await _apiService.submitTournamentScore(
        tournamentId: tournamentId,
        score: score,
        gameDuration: gameStats['duration'] ?? 0,
        foodsEaten: gameStats['foodsEaten'] ?? 0,
      );

      return result != null && result['success'] == true;
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
      final response = await _apiService.getTournamentLeaderboard(
        tournamentId,
        limit: limit,
      );

      if (response == null || response['entries'] == null) return [];

      final entries = List<Map<String, dynamic>>.from(response['entries']);
      return entries.map((data) => _mapToParticipant(data)).toList();
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
      // Get user's tournament participation history
      final response = await _apiService.listTournaments();
      if (response == null) return {};

      // Calculate stats from tournament data
      // This is a simplified version - the backend should provide these stats
      return {
        'totalTournaments': 0,
        'totalAttempts': 0,
        'bestScore': 0,
        'wins': 0,
        'topThreeFinishes': 0,
        'winRate': 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user tournament stats: $e');
      }
      return {};
    }
  }

  // Stream tournaments for real-time updates (polling-based)
  Stream<List<Tournament>> watchActiveTournaments() {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .asyncMap((_) => getActiveTournaments())
        .distinct();
  }

  // Stream tournament leaderboard for real-time updates (polling-based)
  Stream<List<TournamentParticipant>> watchTournamentLeaderboard(String tournamentId, {int limit = 50}) {
    return Stream.periodic(const Duration(seconds: 10), (_) => null)
        .asyncMap((_) => getTournamentLeaderboard(tournamentId, limit: limit))
        .distinct();
  }

  /// Map backend response to Tournament
  Tournament _mapToTournament(Map<String, dynamic> data) {
    final rewards = <int, TournamentReward>{};
    if (data['rewards'] != null) {
      final rewardsData = data['rewards'] as Map<String, dynamic>?;
      if (rewardsData != null) {
        rewardsData.forEach((key, value) {
          final rank = int.tryParse(key) ?? 1;
          if (value is Map<String, dynamic>) {
            rewards[rank] = TournamentReward(
              id: value['id'] ?? '',
              name: value['name'] ?? '',
              description: value['description'] ?? '',
              type: value['type'] ?? 'badge',
              coins: value['coins'] ?? 0,
            );
          }
        });
      }
    }

    return Tournament(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? 'Tournament',
      description: data['description'] ?? '',
      type: _parseTournamentType(data['type']),
      status: _parseTournamentStatus(data['status']),
      gameMode: _parseTournamentGameMode(data['game_mode'] ?? data['gameMode']),
      startDate: _parseDateTime(data['start_date'] ?? data['startDate']),
      endDate: _parseDateTime(data['end_date'] ?? data['endDate']),
      maxParticipants: data['max_participants'] ?? data['maxParticipants'] ?? 100,
      currentParticipants: data['current_participants'] ?? data['currentParticipants'] ?? 0,
      rewards: rewards,
      userBestScore: data['user_best_score'] ?? data['userBestScore'],
      userAttempts: data['user_attempts'] ?? data['userAttempts'],
    );
  }

  /// Map backend response to TournamentParticipant
  TournamentParticipant _mapToParticipant(Map<String, dynamic> data) {
    return TournamentParticipant(
      userId: data['user_id'] ?? data['userId'] ?? '',
      displayName: data['display_name'] ?? data['displayName'] ?? 'Anonymous',
      photoUrl: data['photo_url'] ?? data['photoUrl'],
      highScore: data['high_score'] ?? data['highScore'] ?? data['best_score'] ?? 0,
      attempts: data['attempts'] ?? data['games_played'] ?? 0,
      joinedDate: _parseDateTime(data['joined_date'] ?? data['joinedDate'] ?? data['joined_at']),
      lastScoreDate: _parseDateTime(data['last_score_date'] ?? data['lastScoreDate'] ?? data['updated_at']),
    );
  }

  TournamentType _parseTournamentType(dynamic type) {
    if (type == null) return TournamentType.daily;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'daily':
        return TournamentType.daily;
      case 'weekly':
        return TournamentType.weekly;
      case 'special':
        return TournamentType.special;
      default:
        return TournamentType.daily;
    }
  }

  TournamentStatus _parseTournamentStatus(dynamic status) {
    if (status == null) return TournamentStatus.upcoming;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'upcoming':
        return TournamentStatus.upcoming;
      case 'active':
        return TournamentStatus.active;
      case 'ended':
      case 'completed':
        return TournamentStatus.ended;
      default:
        return TournamentStatus.upcoming;
    }
  }

  TournamentGameMode _parseTournamentGameMode(dynamic mode) {
    if (mode == null) return TournamentGameMode.classic;
    final modeStr = mode.toString().toLowerCase();
    switch (modeStr) {
      case 'classic':
        return TournamentGameMode.classic;
      case 'speedrun':
      case 'speed_run':
        return TournamentGameMode.speedRun;
      case 'perfectgame':
      case 'perfect_game':
        return TournamentGameMode.perfectGame;
      case 'survival':
        return TournamentGameMode.survival;
      default:
        return TournamentGameMode.classic;
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
