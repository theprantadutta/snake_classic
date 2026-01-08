import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';

/// Leaderboard entry data model
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int score;
  final String? gameMode;
  final DateTime? achievedAt;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.score,
    this.gameMode,
    this.achievedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? 'Unknown',
      photoUrl: json['photo_url'] ?? json['photoUrl'],
      score: json['score'] ?? 0,
      gameMode: json['game_mode'] ?? json['gameMode'],
      achievedAt: json['achieved_at'] != null || json['achievedAt'] != null
          ? DateTime.tryParse(json['achieved_at'] ?? json['achievedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'user_id': userId,
    'display_name': displayName,
    'photo_url': photoUrl,
    'score': score,
    'game_mode': gameMode,
    'achieved_at': achievedAt?.toIso8601String(),
  };
}

/// Leaderboard data with pagination info
class LeaderboardData {
  final List<LeaderboardEntry> entries;
  final int totalCount;
  final int page;
  final int pageSize;
  final LeaderboardEntry? userEntry;

  const LeaderboardData({
    required this.entries,
    required this.totalCount,
    this.page = 1,
    this.pageSize = 50,
    this.userEntry,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    final entriesJson =
        json['entries'] as List<dynamic>? ??
        json['leaderboard'] as List<dynamic>? ??
        [];
    return LeaderboardData(
      entries: entriesJson.map((e) => LeaderboardEntry.fromJson(e)).toList(),
      totalCount:
          json['total_count'] ?? json['totalCount'] ?? entriesJson.length,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? json['pageSize'] ?? 50,
      userEntry: json['user_entry'] != null || json['userEntry'] != null
          ? LeaderboardEntry.fromJson(json['user_entry'] ?? json['userEntry'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'entries': entries.map((e) => e.toJson()).toList(),
    'total_count': totalCount,
    'page': page,
    'page_size': pageSize,
    'user_entry': userEntry?.toJson(),
  };
}

/// Abstract repository for leaderboard operations
abstract class LeaderboardRepository {
  /// Get global all-time leaderboard
  /// Cache TTL: 15 minutes (Tier 2)
  Future<Either<Failure, LeaderboardData>> getGlobalLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  });

  /// Get weekly leaderboard
  /// Cache TTL: 5 minutes (Tier 2)
  Future<Either<Failure, LeaderboardData>> getWeeklyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  });

  /// Get daily leaderboard
  /// Cache TTL: 60 seconds (Tier 3 - volatile)
  Future<Either<Failure, LeaderboardData>> getDailyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  });

  /// Get friends leaderboard
  /// Cache TTL: 10 minutes (Tier 2)
  Future<Either<Failure, LeaderboardData>> getFriendsLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  });

  /// Force refresh all leaderboards
  Future<void> refreshAll();
}
