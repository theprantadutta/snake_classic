import 'dart:convert';

enum TournamentType {
  daily,
  weekly,
  monthly,
  special;

  String get displayName {
    switch (this) {
      case TournamentType.daily:
        return 'Daily Challenge';
      case TournamentType.weekly:
        return 'Weekly Tournament';
      case TournamentType.monthly:
        return 'Monthly Championship';
      case TournamentType.special:
        return 'Special Event';
    }
  }

  String get emoji {
    switch (this) {
      case TournamentType.daily:
        return '📅';
      case TournamentType.weekly:
        return '🏆';
      case TournamentType.monthly:
        return '👑';
      case TournamentType.special:
        return '⭐';
    }
  }

  Duration get duration {
    switch (this) {
      case TournamentType.daily:
        return const Duration(days: 1);
      case TournamentType.weekly:
        return const Duration(days: 7);
      case TournamentType.monthly:
        return const Duration(days: 30);
      case TournamentType.special:
        return const Duration(days: 3);
    }
  }
}

enum TournamentStatus {
  upcoming,
  active,
  ended,
  cancelled;

  String get displayName {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'Upcoming';
      case TournamentStatus.active:
        return 'Active';
      case TournamentStatus.ended:
        return 'Ended';
      case TournamentStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get canJoin => this == TournamentStatus.active;
  bool get canSubmitScore => this == TournamentStatus.active;
}

enum TournamentGameMode {
  classic,
  speedRun,
  survival,
  noWalls,
  powerUpMadness,
  perfectGame;

  String get displayName {
    switch (this) {
      case TournamentGameMode.classic:
        return 'Classic';
      case TournamentGameMode.speedRun:
        return 'Speed Run';
      case TournamentGameMode.survival:
        return 'Survival';
      case TournamentGameMode.noWalls:
        return 'No Walls';
      case TournamentGameMode.powerUpMadness:
        return 'Power-up Madness';
      case TournamentGameMode.perfectGame:
        return 'Perfect Game';
    }
  }

  String get description {
    switch (this) {
      case TournamentGameMode.classic:
        return 'Standard Snake game rules';
      case TournamentGameMode.speedRun:
        return 'Game speed increases rapidly';
      case TournamentGameMode.survival:
        return 'Survive as long as possible';
      case TournamentGameMode.noWalls:
        return 'Snake wraps around screen edges';
      case TournamentGameMode.powerUpMadness:
        return 'Frequent power-ups spawn';
      case TournamentGameMode.perfectGame:
        return 'No mistakes allowed - one hit ends game';
    }
  }

  String get emoji {
    switch (this) {
      case TournamentGameMode.classic:
        return '🐍';
      case TournamentGameMode.speedRun:
        return '⚡';
      case TournamentGameMode.survival:
        return '⏱️';
      case TournamentGameMode.noWalls:
        return '🌐';
      case TournamentGameMode.powerUpMadness:
        return '🎆';
      case TournamentGameMode.perfectGame:
        return '💎';
    }
  }
}

class TournamentReward {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final int coins;
  final List<String> badges;
  final String type; // 'achievement', 'badge', 'coins', 'title'

  const TournamentReward({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.coins = 0,
    this.badges = const [],
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'coins': coins,
      'badges': badges,
      'type': type,
    };
  }

  factory TournamentReward.fromJson(Map<String, dynamic> json) {
    return TournamentReward(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'],
      coins: json['coins'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      type: json['type'] ?? 'achievement',
    );
  }
}

class TournamentParticipant {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int highScore;
  final int attempts;
  final DateTime lastScoreDate;
  final DateTime joinedDate;
  final Map<String, dynamic> gameStats;

  const TournamentParticipant({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.highScore,
    required this.attempts,
    required this.lastScoreDate,
    required this.joinedDate,
    this.gameStats = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'highScore': highScore,
      'attempts': attempts,
      'lastScoreDate': lastScoreDate.toIso8601String(),
      'joinedDate': joinedDate.toIso8601String(),
      'gameStats': gameStats,
    };
  }

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? 'Unknown',
      photoUrl: json['photoUrl'],
      highScore: json['highScore'] ?? 0,
      attempts: json['attempts'] ?? 0,
      lastScoreDate: DateTime.parse(
        json['lastScoreDate'] ?? DateTime.now().toIso8601String(),
      ),
      joinedDate: DateTime.parse(
        json['joinedDate'] ?? DateTime.now().toIso8601String(),
      ),
      gameStats: Map<String, dynamic>.from(json['gameStats'] ?? {}),
    );
  }
}

class Tournament {
  final String id;
  final String name;
  final String description;
  final TournamentType type;
  final TournamentStatus status;
  final TournamentGameMode gameMode;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final int currentParticipants;
  final Map<int, TournamentReward> rewards; // rank -> reward
  final Map<String, dynamic> gameSettings;
  final Map<String, dynamic> rules;
  final String? imageUrl;
  final bool requiresEntry;
  final int entryCost;
  final List<TournamentParticipant> leaderboard;
  final DateTime? userLastAttempt;
  final int? userBestScore;
  final int? userAttempts;

  const Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.gameMode,
    required this.startDate,
    required this.endDate,
    this.maxParticipants = 1000,
    this.currentParticipants = 0,
    this.rewards = const {},
    this.gameSettings = const {},
    this.rules = const {},
    this.imageUrl,
    this.requiresEntry = false,
    this.entryCost = 0,
    this.leaderboard = const [],
    this.userLastAttempt,
    this.userBestScore,
    this.userAttempts,
  });

  Duration get timeRemaining {
    final now = DateTime.now();
    if (status == TournamentStatus.upcoming) {
      return startDate.difference(now);
    } else if (status == TournamentStatus.active) {
      return endDate.difference(now);
    }
    return Duration.zero;
  }

  String get timeRemainingFormatted {
    final duration = timeRemaining;
    if (duration.isNegative || duration == Duration.zero) {
      return status == TournamentStatus.upcoming ? 'Starting...' : 'Ended';
    }

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }

  int get userRank {
    if (userBestScore == null) return 0;

    int rank = 1;
    for (final participant in leaderboard) {
      if (participant.highScore > userBestScore!) {
        rank++;
      }
    }
    return rank;
  }

  bool get hasJoined =>
      userBestScore != null || (userAttempts != null && userAttempts! > 0);

  TournamentReward? get userReward {
    if (!hasJoined || status != TournamentStatus.ended) return null;
    return rewards[userRank];
  }

  String get formattedDateRange {
    final start = startDate;
    final end = endDate;

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      // Same day
      return '${start.month}/${start.day}/${start.year}';
    } else if (start.year == end.year && start.month == end.month) {
      // Same month
      return '${start.month}/${start.day}-${end.day}/${start.year}';
    } else {
      // Different months or years
      return '${start.month}/${start.day} - ${end.month}/${end.day}/${end.year}';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'gameMode': gameMode.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'rewards': rewards.map((k, v) => MapEntry(k.toString(), v.toJson())),
      'gameSettings': gameSettings,
      'rules': rules,
      'imageUrl': imageUrl,
      'requiresEntry': requiresEntry,
      'entryCost': entryCost,
      'leaderboard': leaderboard.map((p) => p.toJson()).toList(),
      'userLastAttempt': userLastAttempt?.toIso8601String(),
      'userBestScore': userBestScore,
      'userAttempts': userAttempts,
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: TournamentType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => TournamentType.daily,
      ),
      status: TournamentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TournamentStatus.upcoming,
      ),
      gameMode: TournamentGameMode.values.firstWhere(
        (mode) => mode.name == json['gameMode'],
        orElse: () => TournamentGameMode.classic,
      ),
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] ??
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      ),
      maxParticipants: json['maxParticipants'] ?? 1000,
      currentParticipants: json['currentParticipants'] ?? 0,
      rewards:
          (json['rewards'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), TournamentReward.fromJson(v)),
          ) ??
          {},
      gameSettings: Map<String, dynamic>.from(json['gameSettings'] ?? {}),
      rules: Map<String, dynamic>.from(json['rules'] ?? {}),
      imageUrl: json['imageUrl'],
      requiresEntry: json['requiresEntry'] ?? false,
      entryCost: json['entryCost'] ?? 0,
      leaderboard:
          (json['leaderboard'] as List?)
              ?.map((p) => TournamentParticipant.fromJson(p))
              .toList() ??
          [],
      userLastAttempt: json['userLastAttempt'] != null
          ? DateTime.parse(json['userLastAttempt'])
          : null,
      userBestScore: json['userBestScore'],
      userAttempts: json['userAttempts'],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Tournament.fromJsonString(String jsonString) {
    return Tournament.fromJson(jsonDecode(jsonString));
  }

  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    TournamentType? type,
    TournamentStatus? status,
    TournamentGameMode? gameMode,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    int? currentParticipants,
    Map<int, TournamentReward>? rewards,
    Map<String, dynamic>? gameSettings,
    Map<String, dynamic>? rules,
    String? imageUrl,
    bool? requiresEntry,
    int? entryCost,
    List<TournamentParticipant>? leaderboard,
    DateTime? userLastAttempt,
    int? userBestScore,
    int? userAttempts,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      gameMode: gameMode ?? this.gameMode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      rewards: rewards ?? this.rewards,
      gameSettings: gameSettings ?? this.gameSettings,
      rules: rules ?? this.rules,
      imageUrl: imageUrl ?? this.imageUrl,
      requiresEntry: requiresEntry ?? this.requiresEntry,
      entryCost: entryCost ?? this.entryCost,
      leaderboard: leaderboard ?? this.leaderboard,
      userLastAttempt: userLastAttempt ?? this.userLastAttempt,
      userBestScore: userBestScore ?? this.userBestScore,
      userAttempts: userAttempts ?? this.userAttempts,
    );
  }
}
