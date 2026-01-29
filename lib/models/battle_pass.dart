import 'package:flutter/material.dart';

enum BattlePassRewardType {
  xp,
  coins,
  theme,
  skin,
  trail,
  powerUp,
  tournamentEntry,
  title,
  avatar,
  special;

  String get displayName {
    switch (this) {
      case BattlePassRewardType.xp:
        return 'XP Boost';
      case BattlePassRewardType.coins:
        return 'Coins';
      case BattlePassRewardType.theme:
        return 'Theme';
      case BattlePassRewardType.skin:
        return 'Snake Skin';
      case BattlePassRewardType.trail:
        return 'Trail Effect';
      case BattlePassRewardType.powerUp:
        return 'Power-Up';
      case BattlePassRewardType.tournamentEntry:
        return 'Tournament Entry';
      case BattlePassRewardType.title:
        return 'Player Title';
      case BattlePassRewardType.avatar:
        return 'Avatar';
      case BattlePassRewardType.special:
        return 'Special Reward';
    }
  }

  String get icon {
    switch (this) {
      case BattlePassRewardType.xp:
        return '⭐';
      case BattlePassRewardType.coins:
        return '🪙';
      case BattlePassRewardType.theme:
        return '🎨';
      case BattlePassRewardType.skin:
        return '🐍';
      case BattlePassRewardType.trail:
        return '✨';
      case BattlePassRewardType.powerUp:
        return '⚡';
      case BattlePassRewardType.tournamentEntry:
        return '🏆';
      case BattlePassRewardType.title:
        return '👑';
      case BattlePassRewardType.avatar:
        return '🖼️';
      case BattlePassRewardType.special:
        return '🎁';
    }
  }
}

enum BattlePassTier {
  free,
  premium;

  String get displayName {
    switch (this) {
      case BattlePassTier.free:
        return 'Free';
      case BattlePassTier.premium:
        return 'Premium';
    }
  }

  Color get color {
    switch (this) {
      case BattlePassTier.free:
        return Colors.grey;
      case BattlePassTier.premium:
        return Colors.amber;
    }
  }
}

class BattlePassReward {
  final String id;
  final String name;
  final String description;
  final BattlePassRewardType type;
  final BattlePassTier tier;
  final int quantity;
  final String? itemId; // For specific items like skins, themes
  final String icon;
  final Color color;
  final bool isSpecial; // Highlighted rewards

  const BattlePassReward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    this.quantity = 1,
    this.itemId,
    String? icon,
    Color? color,
    this.isSpecial = false,
  }) : icon = icon ?? '🎁',
       color = color ?? Colors.blue;

  bool get isPremium => tier == BattlePassTier.premium;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'tier': tier.name,
      'quantity': quantity,
      'item_id': itemId,
      'icon': icon,
      'color': color.toARGB32(),
      'is_special': isSpecial,
    };
  }

  factory BattlePassReward.fromJson(Map<String, dynamic> json) {
    return BattlePassReward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: BattlePassRewardType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => BattlePassRewardType.xp,
      ),
      tier: BattlePassTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => BattlePassTier.free,
      ),
      quantity: json['quantity'] ?? 1,
      itemId: json['item_id'],
      icon: json['icon'] ?? '🎁',
      color: Color(json['color'] ?? 0xFF2196F3),
      isSpecial: json['is_special'] ?? false,
    );
  }
}

class BattlePassLevel {
  final int level;
  final int xpRequired;
  final BattlePassReward? freeReward;
  final BattlePassReward? premiumReward;
  final bool isMilestone; // Every 10th level is a milestone with better rewards

  const BattlePassLevel({
    required this.level,
    required this.xpRequired,
    this.freeReward,
    this.premiumReward,
    this.isMilestone = false,
  });

  bool get hasRewards => freeReward != null || premiumReward != null;

  int get totalXpRequired {
    // XP required from level 1 to this level
    return (level * 100) +
        ((level - 1) * level * 5); // Progressive XP requirement
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'xp_required': xpRequired,
      'free_reward': freeReward?.toJson(),
      'premium_reward': premiumReward?.toJson(),
      'is_milestone': isMilestone,
    };
  }

  factory BattlePassLevel.fromJson(Map<String, dynamic> json) {
    return BattlePassLevel(
      level: json['level'],
      xpRequired: json['xp_required'],
      freeReward: json['free_reward'] != null
          ? BattlePassReward.fromJson(json['free_reward'])
          : null,
      premiumReward: json['premium_reward'] != null
          ? BattlePassReward.fromJson(json['premium_reward'])
          : null,
      isMilestone: json['is_milestone'] ?? false,
    );
  }
}

class BattlePassSeason {
  final String id;
  final String name;
  final String description;
  final String theme;
  final DateTime startDate;
  final DateTime endDate;
  final List<BattlePassLevel> levels;
  final double price;
  final String bannerImage;
  final Color themeColor;
  final Map<String, dynamic> metadata;

  const BattlePassSeason({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.startDate,
    required this.endDate,
    required this.levels,
    required this.price,
    this.bannerImage = '',
    this.themeColor = Colors.purple,
    this.metadata = const {},
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get hasEnded => DateTime.now().isAfter(endDate);
  bool get hasStarted => DateTime.now().isAfter(startDate);

  Duration get timeRemaining {
    if (hasEnded) return Duration.zero;
    return endDate.difference(DateTime.now());
  }

  int get daysRemaining => timeRemaining.inDays;
  int get maxLevel => levels.length;

  BattlePassLevel? getLevelData(int level) {
    if (level < 1 || level > levels.length) return null;
    return levels[level - 1];
  }

  int getXpForLevel(int level) {
    final levelData = getLevelData(level);
    return levelData?.xpRequired ?? 0;
  }

  int getTotalXpForLevel(int level) {
    int totalXp = 0;
    for (int i = 1; i <= level && i <= levels.length; i++) {
      totalXp += getXpForLevel(i);
    }
    return totalXp;
  }

  int getLevelFromXp(int totalXp) {
    int currentLevel = 1;
    int xpAccumulated = 0;

    for (int i = 1; i <= levels.length; i++) {
      xpAccumulated += getXpForLevel(i);
      if (totalXp >= xpAccumulated) {
        currentLevel = i + 1;
      } else {
        break;
      }
    }

    return currentLevel.clamp(1, maxLevel);
  }

  List<BattlePassReward> getUnlockedRewards(int currentLevel, bool hasPremium) {
    final rewards = <BattlePassReward>[];

    for (int i = 1; i <= currentLevel && i <= levels.length; i++) {
      final levelData = levels[i - 1];

      // Add free rewards
      if (levelData.freeReward != null) {
        rewards.add(levelData.freeReward!);
      }

      // Add premium rewards if user has premium
      if (hasPremium && levelData.premiumReward != null) {
        rewards.add(levelData.premiumReward!);
      }
    }

    return rewards;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'theme': theme,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'levels': levels.map((l) => l.toJson()).toList(),
      'price': price,
      'banner_image': bannerImage,
      'theme_color': themeColor.toARGB32(),
      'metadata': metadata,
    };
  }

  factory BattlePassSeason.fromJson(Map<String, dynamic> json) {
    return BattlePassSeason(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      theme: json['theme'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      levels: (json['levels'] as List)
          .map((l) => BattlePassLevel.fromJson(l))
          .toList(),
      price: json['price']?.toDouble() ?? 9.99,
      bannerImage: json['banner_image'] ?? '',
      themeColor: Color(json['theme_color'] ?? 0xFF9C27B0),
      metadata: json['metadata'] ?? {},
    );
  }

  // Create a sample season for testing/demo
  static BattlePassSeason createSampleSeason() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 5));
    final endDate = now.add(const Duration(days: 55));

    final levels = <BattlePassLevel>[];

    for (int i = 1; i <= 100; i++) {
      final isMilestone = i % 10 == 0;
      final xpRequired = 100 + (i * 5); // Progressive XP requirement

      BattlePassReward? freeReward;
      BattlePassReward? premiumReward;

      // Create rewards based on level
      if (i % 5 == 0) {
        // Free rewards every 5 levels
        freeReward = BattlePassReward(
          id: 'free_$i',
          name: 'Free Reward $i',
          description: 'Free reward for level $i',
          type: _getRewardTypeForLevel(i, false),
          tier: BattlePassTier.free,
          quantity: _getQuantityForLevel(i, false),
          icon: _getRewardTypeForLevel(i, false).icon,
        );
      }

      if (i % 3 == 0) {
        // Premium rewards every 3 levels
        premiumReward = BattlePassReward(
          id: 'premium_$i',
          name: 'Premium Reward $i',
          description: 'Premium reward for level $i',
          type: _getRewardTypeForLevel(i, true),
          tier: BattlePassTier.premium,
          quantity: _getQuantityForLevel(i, true),
          isSpecial: isMilestone,
          icon: _getRewardTypeForLevel(i, true).icon,
          color: Colors.amber,
        );
      }

      levels.add(
        BattlePassLevel(
          level: i,
          xpRequired: xpRequired,
          freeReward: freeReward,
          premiumReward: premiumReward,
          isMilestone: isMilestone,
        ),
      );
    }

    return BattlePassSeason(
      id: 'season_1',
      name: 'Cosmic Serpent Season',
      description: 'Explore the cosmos with exclusive space-themed rewards',
      theme: 'cosmic',
      startDate: startDate,
      endDate: endDate,
      levels: levels,
      price: 9.99,
      bannerImage: 'assets/images/battle_pass_cosmic_banner.png',
      themeColor: const Color(0xFF4B0082),
      metadata: {
        'featured_skins': ['galaxy', 'cosmic', 'crystal'],
        'featured_themes': ['space', 'cyberpunk'],
        'special_events': ['cosmic_tournament', 'starlight_challenge'],
      },
    );
  }

  static BattlePassRewardType _getRewardTypeForLevel(
    int level,
    bool isPremium,
  ) {
    if (level % 50 == 0) return BattlePassRewardType.special;
    if (level % 25 == 0)
      return isPremium ? BattlePassRewardType.skin : BattlePassRewardType.title;
    if (level % 20 == 0) return BattlePassRewardType.theme;
    if (level % 15 == 0) return BattlePassRewardType.trail;
    if (level % 10 == 0)
      return isPremium
          ? BattlePassRewardType.powerUp
          : BattlePassRewardType.tournamentEntry;
    if (level % 7 == 0) return BattlePassRewardType.coins;
    return BattlePassRewardType.xp;
  }

  static int _getQuantityForLevel(int level, bool isPremium) {
    if (level % 50 == 0) return 1; // Special rewards
    if (level % 25 == 0) return 1; // Skins/themes
    if (level % 10 == 0) return isPremium ? 3 : 1; // Milestone rewards
    if (level % 5 == 0) return isPremium ? 100 : 50; // Coins
    return isPremium ? 25 : 15; // XP
  }
}

class UserBattlePass {
  final String userId;
  final String seasonId;
  final bool hasPremium;
  final int currentLevel;
  final int currentXp;
  final DateTime purchaseDate;
  final List<String> claimedRewards;
  final Map<String, dynamic> progress;

  const UserBattlePass({
    required this.userId,
    required this.seasonId,
    required this.hasPremium,
    required this.currentLevel,
    required this.currentXp,
    required this.purchaseDate,
    this.claimedRewards = const [],
    this.progress = const {},
  });

  bool isRewardClaimed(String rewardId) {
    return claimedRewards.contains(rewardId);
  }

  int getXpForNextLevel(BattlePassSeason season) {
    if (currentLevel >= season.maxLevel) return 0;
    final nextLevelData = season.getLevelData(currentLevel + 1);
    return nextLevelData?.xpRequired ?? 0;
  }

  double getLevelProgress(BattlePassSeason season) {
    final xpForNext = getXpForNextLevel(season);
    if (xpForNext == 0) return 1.0;

    final totalXpForCurrentLevel = season.getTotalXpForLevel(currentLevel);
    final xpIntoCurrentLevel = currentXp - totalXpForCurrentLevel;
    return (xpIntoCurrentLevel / xpForNext).clamp(0.0, 1.0);
  }

  UserBattlePass copyWith({
    bool? hasPremium,
    int? currentLevel,
    int? currentXp,
    List<String>? claimedRewards,
    Map<String, dynamic>? progress,
  }) {
    return UserBattlePass(
      userId: userId,
      seasonId: seasonId,
      hasPremium: hasPremium ?? this.hasPremium,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      purchaseDate: purchaseDate,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'season_id': seasonId,
      'has_premium': hasPremium,
      'current_level': currentLevel,
      'current_xp': currentXp,
      'purchase_date': purchaseDate.toIso8601String(),
      'claimed_rewards': claimedRewards,
      'progress': progress,
    };
  }

  factory UserBattlePass.fromJson(Map<String, dynamic> json) {
    return UserBattlePass(
      userId: json['user_id'],
      seasonId: json['season_id'],
      hasPremium: json['has_premium'] ?? false,
      currentLevel: json['current_level'] ?? 1,
      currentXp: json['current_xp'] ?? 0,
      purchaseDate: DateTime.parse(json['purchase_date']),
      claimedRewards: List<String>.from(json['claimed_rewards'] ?? []),
      progress: json['progress'] ?? {},
    );
  }
}

// XP sources and amounts
class BattlePassXpSource {
  static const Map<String, int> xpAmounts = {
    'game_completed': 5,
    'food_eaten': 0, // Removed to reduce XP inflation
    'score_milestone_100': 3,
    'score_milestone_500': 10,
    'score_milestone_1000': 20,
    'daily_game': 15,
    'achievement_unlocked_common': 8,
    'achievement_unlocked_rare': 15,
    'achievement_unlocked_epic': 30,
    'achievement_unlocked_legendary': 60,
    'multiplayer_win': 20,
    'multiplayer_participation': 8,
    'tournament_participation': 35,
    'tournament_win': 75,
    'power_up_collected': 1,
    'survival_60s': 10,
    'survival_300s': 35,
    'daily_challenge': 20,
    'weekly_challenge': 50,
  };

  static int getXpForAction(String action, [int multiplier = 1]) {
    return (xpAmounts[action] ?? 0) * multiplier;
  }
}
