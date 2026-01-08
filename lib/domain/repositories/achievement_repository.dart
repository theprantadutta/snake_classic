import 'package:dartz/dartz.dart';
import 'package:snake_classic/core/error/failures.dart';
import 'package:snake_classic/models/achievement.dart';

/// User achievement progress data
class UserAchievementProgress {
  final String userId;
  final List<Achievement> achievements;
  final int totalPoints;
  final int unlockedCount;

  const UserAchievementProgress({
    required this.userId,
    required this.achievements,
    required this.totalPoints,
    required this.unlockedCount,
  });

  factory UserAchievementProgress.fromJson(Map<String, dynamic> json) {
    final achievementsJson = json['achievements'] as List<dynamic>? ?? [];
    return UserAchievementProgress(
      userId: json['user_id'] ?? json['userId'] ?? '',
      achievements: achievementsJson
          .map((e) => Achievement.fromJson(e))
          .toList(),
      totalPoints: json['total_points'] ?? json['totalPoints'] ?? 0,
      unlockedCount: json['unlocked_count'] ?? json['unlockedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'achievements': achievements.map((e) => e.toJson()).toList(),
    'total_points': totalPoints,
    'unlocked_count': unlockedCount,
  };
}

/// Abstract repository for achievement operations
abstract class AchievementRepository {
  /// Get all available achievements definitions
  /// Cache TTL: 1 hour (Tier 1 - static data)
  Future<Either<Failure, List<Achievement>>> getAllAchievements();

  /// Get user's achievement progress
  /// Cache TTL: 5 minutes (Tier 2)
  Future<Either<Failure, UserAchievementProgress>> getUserAchievements();

  /// Update achievement progress
  /// No caching - always hits network
  Future<Either<Failure, Achievement>> updateAchievementProgress({
    required String achievementId,
    int progressIncrement = 1,
  });

  /// Force refresh achievements
  Future<void> refresh();
}
