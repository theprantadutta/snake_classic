import 'package:flutter/material.dart';

enum AchievementType {
  score,
  games,
  streak,
  survival,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.targetValue,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    int? points,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      points: points ?? this.points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  double get progressPercentage {
    if (targetValue == 0) return isUnlocked ? 1.0 : 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'type': type.name,
      'rarity': rarity.name,
      'targetValue': targetValue,
      'points': points,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: IconData(
        json['iconCodePoint'] ?? Icons.star.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.score,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      targetValue: json['targetValue'] ?? 0,
      points: json['points'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
        ? DateTime.parse(json['unlockedAt'])
        : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      // Score Achievements
      const Achievement(
        id: 'first_score',
        title: 'First Bite',
        description: 'Score your first 10 points',
        icon: Icons.star,
        type: AchievementType.score,
        rarity: AchievementRarity.common,
        targetValue: 10,
        points: 10,
      ),
      const Achievement(
        id: 'score_100',
        title: 'Century Club',
        description: 'Reach 100 points in a single game',
        icon: Icons.emoji_events,
        type: AchievementType.score,
        rarity: AchievementRarity.common,
        targetValue: 100,
        points: 25,
      ),
      const Achievement(
        id: 'score_500',
        title: 'High Roller',
        description: 'Reach 500 points in a single game',
        icon: Icons.trending_up,
        type: AchievementType.score,
        rarity: AchievementRarity.rare,
        targetValue: 500,
        points: 50,
      ),
      const Achievement(
        id: 'score_1000',
        title: 'Snake Master',
        description: 'Reach 1000 points in a single game',
        icon: Icons.military_tech,
        type: AchievementType.score,
        rarity: AchievementRarity.epic,
        targetValue: 1000,
        points: 100,
      ),
      const Achievement(
        id: 'score_2000',
        title: 'Legendary Serpent',
        description: 'Reach 2000 points in a single game',
        icon: Icons.diamond,
        type: AchievementType.score,
        rarity: AchievementRarity.legendary,
        targetValue: 2000,
        points: 250,
      ),

      // Games Played Achievements
      const Achievement(
        id: 'games_1',
        title: 'Getting Started',
        description: 'Play your first game',
        icon: Icons.play_arrow,
        type: AchievementType.games,
        rarity: AchievementRarity.common,
        targetValue: 1,
        points: 5,
      ),
      const Achievement(
        id: 'games_10',
        title: 'Persistent Player',
        description: 'Play 10 games',
        icon: Icons.videogame_asset,
        type: AchievementType.games,
        rarity: AchievementRarity.common,
        targetValue: 10,
        points: 15,
      ),
      const Achievement(
        id: 'games_50',
        title: 'Dedicated Gamer',
        description: 'Play 50 games',
        icon: Icons.sports_esports,
        type: AchievementType.games,
        rarity: AchievementRarity.rare,
        targetValue: 50,
        points: 50,
      ),
      const Achievement(
        id: 'games_100',
        title: 'Snake Addict',
        description: 'Play 100 games',
        icon: Icons.gamepad,
        type: AchievementType.games,
        rarity: AchievementRarity.epic,
        targetValue: 100,
        points: 100,
      ),

      // Survival Achievements
      const Achievement(
        id: 'survive_60',
        title: 'Survivor',
        description: 'Survive for 60 seconds',
        icon: Icons.timer,
        type: AchievementType.survival,
        rarity: AchievementRarity.common,
        targetValue: 60,
        points: 20,
      ),
      const Achievement(
        id: 'survive_300',
        title: 'Endurance Master',
        description: 'Survive for 5 minutes',
        icon: Icons.schedule,
        type: AchievementType.survival,
        rarity: AchievementRarity.rare,
        targetValue: 300,
        points: 75,
      ),

      // Special Achievements
      const Achievement(
        id: 'no_walls',
        title: 'Wall Avoider',
        description: 'Play 5 games without hitting walls',
        icon: Icons.shield,
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        targetValue: 5,
        points: 60,
      ),
      const Achievement(
        id: 'speedster',
        title: 'Speedster',
        description: 'Reach level 10 (max speed)',
        icon: Icons.speed,
        type: AchievementType.special,
        rarity: AchievementRarity.epic,
        targetValue: 10,
        points: 80,
      ),
      const Achievement(
        id: 'perfectionist',
        title: 'Perfectionist',
        description: 'Complete a game without hitting yourself',
        icon: Icons.verified,
        type: AchievementType.special,
        rarity: AchievementRarity.epic,
        targetValue: 1,
        points: 90,
      ),
      const Achievement(
        id: 'all_food_types',
        title: 'Gourmet',
        description: 'Eat all 3 types of food in a single game',
        icon: Icons.restaurant,
        type: AchievementType.special,
        rarity: AchievementRarity.rare,
        targetValue: 1,
        points: 40,
      ),
    ];
  }
}