import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/offline_cache_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';

class TournamentService {
  static TournamentService? _instance;
  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();
  final DataSyncService _dataSyncService = DataSyncService();

  TournamentService._internal();

  factory TournamentService() {
    _instance ??= TournamentService._internal();
    return _instance!;
  }

  // Cache keys
  static const String _activeTournamentsKey = 'tournaments_active';
  static const String _tournamentHistoryKey = 'tournaments_history';

  /// Get all active and upcoming tournaments with cache-first pattern
  Future<List<Tournament>> getActiveTournaments() async {
    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _activeTournamentsKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      // Cache hit - return cached data and refresh in background if online
      if (_connectivityService.isOnline) {
        _refreshActiveTournamentsInBackground();
      }
      return cached.map((data) => _mapToTournament(data)).toList();
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      // Try to get stale cached data as fallback
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        _activeTournamentsKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback?.map((data) => _mapToTournament(data)).toList() ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheActiveTournaments();
  }

  Future<List<Tournament>> _fetchAndCacheActiveTournaments() async {
    try {
      final response = await _apiService.listTournaments(status: 'active');

      if (response == null || response['tournaments'] == null) return [];

      final tournaments = List<Map<String, dynamic>>.from(response['tournaments']);

      // Cache the raw data
      await _cacheService.setCache<List<Map<String, dynamic>>>(
        _activeTournamentsKey,
        tournaments,
        (data) => data,
      );

      return tournaments.map((data) => _mapToTournament(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting active tournaments: $e');
      }
      return [];
    }
  }

  void _refreshActiveTournamentsInBackground() {
    _fetchAndCacheActiveTournaments().catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <Tournament>[];
    });
  }

  /// Get tournament history (ended tournaments) with cache-first pattern
  Future<List<Tournament>> getTournamentHistory({int limit = 10}) async {
    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      _tournamentHistoryKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshTournamentHistoryInBackground(limit);
      }
      return cached.map((data) => _mapToTournament(data)).toList();
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        _tournamentHistoryKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback?.map((data) => _mapToTournament(data)).toList() ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheTournamentHistory(limit);
  }

  Future<List<Tournament>> _fetchAndCacheTournamentHistory(int limit) async {
    try {
      final response = await _apiService.listTournaments(
        status: 'ended',
        limit: limit,
      );

      if (response == null || response['tournaments'] == null) return [];

      final tournaments = List<Map<String, dynamic>>.from(response['tournaments']);

      await _cacheService.setCache<List<Map<String, dynamic>>>(
        _tournamentHistoryKey,
        tournaments,
        (data) => data,
        customTtl: const Duration(hours: 1), // History doesn't change often
      );

      return tournaments.map((data) => _mapToTournament(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tournament history: $e');
      }
      return [];
    }
  }

  void _refreshTournamentHistoryInBackground(int limit) {
    _fetchAndCacheTournamentHistory(limit).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <Tournament>[];
    });
  }

  /// Get specific tournament by ID with caching
  Future<Tournament?> getTournament(String tournamentId) async {
    final cacheKey = 'tournament_$tournamentId';

    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<Map<String, dynamic>>(
      cacheKey,
      (data) => Map<String, dynamic>.from(data as Map),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshTournamentInBackground(tournamentId);
      }
      return _mapToTournament(cached);
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService.getCachedFallback<Map<String, dynamic>>(
        cacheKey,
        (data) => Map<String, dynamic>.from(data as Map),
      );
      return fallback != null ? _mapToTournament(fallback) : null;
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheTournament(tournamentId);
  }

  Future<Tournament?> _fetchAndCacheTournament(String tournamentId) async {
    try {
      final data = await _apiService.getTournament(tournamentId);
      if (data == null) return null;

      await _cacheService.setCache<Map<String, dynamic>>(
        'tournament_$tournamentId',
        data,
        (d) => d,
        customTtl: const Duration(minutes: 5),
      );

      return _mapToTournament(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tournament: $e');
      }
      return null;
    }
  }

  void _refreshTournamentInBackground(String tournamentId) {
    _fetchAndCacheTournament(tournamentId).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return null;
    });
  }

  /// Join a tournament (requires online)
  Future<bool> joinTournament(String tournamentId) async {
    if (!_connectivityService.isOnline) {
      if (kDebugMode) {
        print('Cannot join tournament while offline');
      }
      return false;
    }

    try {
      final result = await _apiService.joinTournament(tournamentId);
      if (result != null && result['success'] == true) {
        // Invalidate cache to get updated participant count
        await _cacheService.invalidateCache('tournament_$tournamentId');
        await _cacheService.invalidateCache(_activeTournamentsKey);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining tournament: $e');
      }
      return false;
    }
  }

  /// Submit score to tournament (offline-first: queues for background sync)
  Future<bool> submitScore(String tournamentId, int score, Map<String, dynamic> gameStats) async {
    // Offline-first: Queue the score submission for background sync
    // This allows the user to continue playing without waiting for the API
    _dataSyncService.queueSync(
      'tournament_score',
      {
        'tournamentId': tournamentId,
        'score': score,
        'gameDuration': gameStats['duration'] ?? 0,
        'foodsEaten': gameStats['foodsEaten'] ?? 0,
        'playedAt': DateTime.now().toIso8601String(),
        'idempotencyKey': '${tournamentId}_${DateTime.now().millisecondsSinceEpoch}_$score',
      },
      priority: SyncPriority.critical, // Tournament scores are critical
    );

    // Invalidate leaderboard cache so next fetch gets fresh data
    await _cacheService.invalidateCache('tournament_leaderboard_$tournamentId');

    // Return true immediately - the score will be synced in the background
    return true;
  }

  /// Get tournament leaderboard with caching
  Future<List<TournamentParticipant>> getTournamentLeaderboard(String tournamentId, {int limit = 50}) async {
    final cacheKey = 'tournament_leaderboard_$tournamentId';

    // 1. Try to get cached data first
    final cached = await _cacheService.getCached<List<Map<String, dynamic>>>(
      cacheKey,
      (data) => List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      ),
    );

    if (cached != null) {
      if (_connectivityService.isOnline) {
        _refreshTournamentLeaderboardInBackground(tournamentId, limit);
      }
      return cached.map((data) => _mapToParticipant(data)).toList();
    }

    // 2. No fresh cache - check if we're offline
    if (!_connectivityService.isOnline) {
      final fallback = await _cacheService.getCachedFallback<List<Map<String, dynamic>>>(
        cacheKey,
        (data) => List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)),
        ),
      );
      return fallback?.map((data) => _mapToParticipant(data)).toList() ?? [];
    }

    // 3. Online with no cache - fetch fresh data
    return await _fetchAndCacheTournamentLeaderboard(tournamentId, limit);
  }

  Future<List<TournamentParticipant>> _fetchAndCacheTournamentLeaderboard(String tournamentId, int limit) async {
    try {
      final response = await _apiService.getTournamentLeaderboard(
        tournamentId,
        limit: limit,
      );

      if (response == null || response['entries'] == null) return [];

      final entries = List<Map<String, dynamic>>.from(response['entries']);

      await _cacheService.setCache<List<Map<String, dynamic>>>(
        'tournament_leaderboard_$tournamentId',
        entries,
        (data) => data,
        customTtl: const Duration(minutes: 2), // Short TTL for leaderboards
      );

      return entries.map((data) => _mapToParticipant(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tournament leaderboard: $e');
      }
      return [];
    }
  }

  void _refreshTournamentLeaderboardInBackground(String tournamentId, int limit) {
    _fetchAndCacheTournamentLeaderboard(tournamentId, limit).catchError((e) {
      if (kDebugMode) {
        print('Background refresh failed: $e');
      }
      return <TournamentParticipant>[];
    });
  }

  /// Get user's tournament statistics
  Future<Map<String, dynamic>> getUserTournamentStats() async {
    try {
      final response = await _apiService.listTournaments();
      if (response == null) return {};

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

  /// Check if we have cached tournament data
  Future<bool> hasCachedData() async {
    return await _cacheService.hasCachedData(_activeTournamentsKey);
  }

  /// Clear all tournament cache
  Future<void> clearCache() async {
    await _cacheService.invalidateCachePattern('tournament');
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
