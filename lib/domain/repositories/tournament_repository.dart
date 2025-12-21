import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/models/tournament.dart';

/// Tournaments list data
class TournamentsData {
  final List<Tournament> tournaments;
  final int totalCount;
  final int offset;
  final int limit;

  const TournamentsData({
    required this.tournaments,
    required this.totalCount,
    this.offset = 0,
    this.limit = 50,
  });

  factory TournamentsData.fromJson(Map<String, dynamic> json) {
    final tournamentsJson = json['tournaments'] as List<dynamic>? ?? [];
    return TournamentsData(
      tournaments: tournamentsJson.map((e) => Tournament.fromJson(e)).toList(),
      totalCount: json['total_count'] ?? json['totalCount'] ?? tournamentsJson.length,
      offset: json['offset'] ?? 0,
      limit: json['limit'] ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
        'tournaments': tournaments.map((e) => e.toJson()).toList(),
        'total_count': totalCount,
        'offset': offset,
        'limit': limit,
      };
}

/// Tournament leaderboard data
class TournamentLeaderboardData {
  final String tournamentId;
  final List<TournamentParticipant> participants;
  final int totalParticipants;
  final TournamentParticipant? userEntry;

  const TournamentLeaderboardData({
    required this.tournamentId,
    required this.participants,
    required this.totalParticipants,
    this.userEntry,
  });

  factory TournamentLeaderboardData.fromJson(Map<String, dynamic> json) {
    final participantsJson = json['participants'] as List<dynamic>? ?? json['leaderboard'] as List<dynamic>? ?? [];
    return TournamentLeaderboardData(
      tournamentId: json['tournament_id'] ?? json['tournamentId'] ?? '',
      participants: participantsJson.map((e) => TournamentParticipant.fromJson(e)).toList(),
      totalParticipants: json['total_participants'] ?? json['totalParticipants'] ?? participantsJson.length,
      userEntry: json['user_entry'] != null || json['userEntry'] != null
          ? TournamentParticipant.fromJson(json['user_entry'] ?? json['userEntry'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'tournament_id': tournamentId,
        'participants': participants.map((e) => e.toJson()).toList(),
        'total_participants': totalParticipants,
        'user_entry': userEntry?.toJson(),
      };
}

/// Abstract repository for tournament operations
abstract class TournamentRepository {
  /// Get list of tournaments
  /// Cache TTL: 5 minutes (Tier 3)
  Future<Either<Failure, TournamentsData>> getTournaments({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  });

  /// Get tournament details
  /// Cache TTL: 5 minutes (Tier 3)
  Future<Either<Failure, Tournament>> getTournament(String tournamentId);

  /// Get tournament leaderboard
  /// Cache TTL: 60 seconds (Tier 3 - volatile)
  Future<Either<Failure, TournamentLeaderboardData>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
    int offset = 0,
  });

  /// Join tournament
  /// No caching
  Future<Either<Failure, Tournament>> joinTournament(String tournamentId);

  /// Submit tournament score
  /// No caching
  Future<Either<Failure, void>> submitTournamentScore({
    required String tournamentId,
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
  });

  /// Force refresh tournaments
  Future<void> refresh();
}
