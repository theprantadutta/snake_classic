import 'package:flutter/material.dart';

/// D-Pad position presets for user preference
enum DPadPosition {
  bottomLeft,
  bottomCenter,
  bottomRight;

  String get displayName {
    switch (this) {
      case DPadPosition.bottomLeft:
        return 'Left';
      case DPadPosition.bottomCenter:
        return 'Center';
      case DPadPosition.bottomRight:
        return 'Right';
    }
  }

  String get icon {
    switch (this) {
      case DPadPosition.bottomLeft:
        return '⬅️';
      case DPadPosition.bottomCenter:
        return '⬇️';
      case DPadPosition.bottomRight:
        return '➡️';
    }
  }
}

class BoardSize {
  final int width;
  final int height;
  final String name;
  final String description;
  final bool isPremium;
  final String icon;

  const BoardSize(
    this.width,
    this.height,
    this.name,
    this.description, {
    this.isPremium = false,
    this.icon = '📐',
  });

  // Static getters for common board sizes
  static const BoardSize small = BoardSize(
    15,
    15,
    'Small',
    'Quick games, tight spaces',
    icon: '🎯',
  );
  static const BoardSize classic = BoardSize(
    20,
    20,
    'Classic',
    'The original Snake experience',
    icon: '🐍',
  );
  static const BoardSize large = BoardSize(
    25,
    25,
    'Large',
    'More room to grow',
    icon: '📏',
  );
  static const BoardSize huge = BoardSize(
    30,
    30,
    'Huge',
    'Maximum challenge and space',
    icon: '🏟️',
  );

  // All board sizes list
  static const List<BoardSize> all = [small, classic, large, huge];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;

  @override
  String toString() => '$name (${width}x$height)';

  String get id => '${width}x$height';
}

class GameConstants {
  // Board dimensions
  static const int defaultBoardWidth = 20;
  static const int defaultBoardHeight = 20;

  // Available board sizes
  static const List<BoardSize> availableBoardSizes = [
    BoardSize(15, 15, 'Small', 'Quick games, tight spaces', icon: '🎯'),
    BoardSize(20, 20, 'Classic', 'The original Snake experience', icon: '🐍'),
    BoardSize(25, 25, 'Large', 'More room to grow', icon: '📏'),
    BoardSize(30, 30, 'Huge', 'Maximum challenge and space', icon: '🏟️'),
    BoardSize(
      35,
      35,
      'Epic',
      'Premium board for advanced players',
      isPremium: true,
      icon: '⭐',
    ),
    BoardSize(
      40,
      40,
      'Massive',
      'Enormous board for epic games',
      isPremium: true,
      icon: '🏆',
    ),
    BoardSize(
      50,
      50,
      'Ultimate',
      'The largest possible board',
      isPremium: true,
      icon: '👑',
    ),
  ];

  // Free board sizes (accessible without premium)
  static List<BoardSize> get freeBoardSizes =>
      availableBoardSizes.where((size) => !size.isPremium).toList();

  // Premium board sizes (require premium subscription)
  static List<BoardSize> get premiumBoardSizes =>
      availableBoardSizes.where((size) => size.isPremium).toList();

  // Game timing
  static const int initialGameSpeed = 300; // milliseconds
  static const int minGameSpeed = 100;
  static const int maxGameSpeed = 500;

  // === UI Layout Constants ===
  static const double containerMargin = 8.0;
  static const double smallScreenThreshold = 700.0;
  static const double defaultHorizontalPadding = 12.0;
  static const double smallScreenPadding = 8.0;
  static const double largeScreenPadding = 16.0;
  static const double gameBoardBorderWidth = 3.0;
  static const double gestureIndicatorSize = 70.0;

  // === Swipe Detection Constants ===
  static const double swipeMinDelta = 2.0;
  static const double swipeMinVelocity = 300.0;
  static const int swipeSpamPreventionMs = 50;
  static const int swipeSameDirectionThresholdMs = 150;

  // === Animation Constants ===
  static const double gridBackgroundSize = 30.0;
  static const int colorCycleIntervalMs = 500;
  static const int sparkleAnimationSpeedMs = 200;

  // === Safe Zone Warning Constants ===
  static const int wallWarningThreshold = 2; // cells from wall to start warning
  static const double wallWarningMaxIntensity = 0.8;

  // === Power-Up Constants ===
  static const int powerUpExpirationWarningSeconds = 5;
  static const int powerUpSpawnIntervalSeconds = 25;
  static const int powerUpExpirationSeconds = 20;

  // === Crash Feedback Special Modes ===
  static const int crashFeedbackUntilTap = -1; // marker for "until I tap" mode
  static const int crashFeedbackSkip = 0; // marker for "skip entirely" mode

  // Crash feedback duration options (includes special modes)
  // crashFeedbackSkip (0s) = skip entirely, crashFeedbackUntilTap (-1s) = wait for tap
  static const List<Duration> availableCrashFeedbackDurations = [
    Duration(seconds: 0), // Skip entirely
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 3),
    Duration(seconds: 5),
    Duration(seconds: -1), // Until I tap (negative duration as marker)
  ];
  static const Duration defaultCrashFeedbackDuration = Duration(seconds: 3);

  /// Gets a user-friendly label for crash feedback duration
  static String getCrashFeedbackLabel(Duration duration) {
    if (duration.inSeconds == crashFeedbackSkip) return 'Skip';
    if (duration.inSeconds == crashFeedbackUntilTap) return 'Until Tap';
    return '${duration.inSeconds}s';
  }

  // Scoring
  static const int baseScore = 10;
  static const int bonusScore = 25;
  static const int specialScore = 50;

  // Colors - Classic Theme
  static const Color classicBackground = Color(0xFF0F380F);
  static const Color classicSnake = Color(0xFF9BBD0F);
  static const Color classicFood = Color(0xFF9BBD0F);
  static const Color classicBorder = Color(0xFF8BAC0F);

  // Colors - Modern Theme (Improved Contrast)
  static const Color modernBackground = Color(0xFF1a1a2e);
  static const Color modernSnake = Color(0xFF4fc3f7); // Bright cyan-blue
  static const Color modernFood = Color(0xFFe94560); // Kept - good contrast
  static const Color modernAccent = Color(
    0xFF64b5f6,
  ); // Light blue for better visibility

  // Colors - Neon Theme (Enhanced)
  static const Color neonBackground = Color(0xFF0a0a0a);
  static const Color neonSnake = Color(0xFF00ffff); // Electric cyan
  static const Color neonFood = Color(0xFFff1493); // Deep pink
  static const Color neonGlow = Color(0xFF00ff00); // Pure lime green

  // Colors - Retro Theme
  static const Color retroBackground = Color(0xFF2C1810); // Dark brown
  static const Color retroSnake = Color(0xFFD2691E); // Chocolate/orange
  static const Color retroFood = Color(0xFFFFD700); // Gold
  static const Color retroAccent = Color(0xFFCD853F); // Peru/tan

  // Colors - Space Theme
  static const Color spaceBackground = Color(0xFF0B0C2A); // Deep space blue
  static const Color spaceSnake = Color(0xFF9932CC); // Dark orchid
  static const Color spaceFood = Color(0xFF00CED1); // Dark turquoise
  static const Color spaceAccent = Color(0xFF4169E1); // Royal blue

  // Colors - Ocean Theme
  static const Color oceanBackground = Color(0xFF001B3D); // Deep ocean blue
  static const Color oceanSnake = Color(0xFF20B2AA); // Light sea green
  static const Color oceanFood = Color(0xFFFF7F50); // Coral
  static const Color oceanAccent = Color(0xFF4682B4); // Steel blue

  // Colors - Cyberpunk Theme
  static const Color cyberpunkBackground = Color(0xFF0D0221); // Deep midnight purple
  static const Color cyberpunkSnake = Color(0xFFFF003C); // Neon red/magenta
  static const Color cyberpunkFood = Color(0xFFFCEE0A); // Electric yellow
  static const Color cyberpunkAccent = Color(0xFFB537F2); // Vivid purple

  // Colors - Forest Theme
  static const Color forestBackground = Color(0xFF0D2818); // Dark forest green
  static const Color forestSnake = Color(0xFF228B22); // Forest green
  static const Color forestFood = Color(0xFFDC143C); // Crimson berry
  static const Color forestAccent = Color(0xFF32CD32); // Lime green

  // Colors - Desert Theme
  static const Color desertBackground = Color(0xFF2F1B14); // Dark brown sand
  static const Color desertSnake = Color(0xFFDAA520); // Goldenrod
  static const Color desertFood = Color(0xFFFF4500); // Orange red cactus fruit
  static const Color desertAccent = Color(0xFFF4A460); // Sandy brown

  // Colors - Crystal Theme
  static const Color crystalBackground = Color(0xFF1A0033); // Deep purple
  static const Color crystalSnake = Color(0xFF9370DB); // Medium orchid
  static const Color crystalFood = Color(0xFFDA70D6); // Orchid
  static const Color crystalAccent = Color(0xFF8A2BE2); // Blue violet

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI dimensions
  static const double cellSize = 20.0;
  static const double borderWidth = 2.0;
  static const double borderRadius = 4.0;

  // Crash feedback timing
  static const Duration crashFeedbackDuration = Duration(seconds: 5);

  // Storage keys
  static const String highScoreKey = 'high_score';
  static const String selectedThemeKey = 'selected_theme';
  static const String soundEnabledKey = 'sound_enabled';
  static const String musicEnabledKey = 'music_enabled';
  static const String achievementsKey = 'achievements';
  static const String boardSizeKey = 'board_size';
  static const String crashFeedbackDurationKey = 'crash_feedback_duration';
  static const String statisticsKey = 'game_statistics';
  static const String trailSystemEnabledKey = 'trail_system_enabled';
}

enum GameTheme {
  classic,
  modern,
  neon,
  retro,
  space,
  ocean,
  cyberpunk,
  forest,
  desert,
  crystal;

  String get name {
    switch (this) {
      case GameTheme.classic:
        return 'Classic';
      case GameTheme.modern:
        return 'Modern';
      case GameTheme.neon:
        return 'Neon';
      case GameTheme.retro:
        return 'Retro';
      case GameTheme.space:
        return 'Space';
      case GameTheme.ocean:
        return 'Ocean';
      case GameTheme.cyberpunk:
        return 'Cyberpunk';
      case GameTheme.forest:
        return 'Forest';
      case GameTheme.desert:
        return 'Desert';
      case GameTheme.crystal:
        return 'Crystal';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case GameTheme.classic:
        return GameConstants.classicBackground;
      case GameTheme.modern:
        return GameConstants.modernBackground;
      case GameTheme.neon:
        return GameConstants.neonBackground;
      case GameTheme.retro:
        return GameConstants.retroBackground;
      case GameTheme.space:
        return GameConstants.spaceBackground;
      case GameTheme.ocean:
        return GameConstants.oceanBackground;
      case GameTheme.cyberpunk:
        return GameConstants.cyberpunkBackground;
      case GameTheme.forest:
        return GameConstants.forestBackground;
      case GameTheme.desert:
        return GameConstants.desertBackground;
      case GameTheme.crystal:
        return GameConstants.crystalBackground;
    }
  }

  Color get snakeColor {
    switch (this) {
      case GameTheme.classic:
        return GameConstants.classicSnake;
      case GameTheme.modern:
        return GameConstants.modernSnake;
      case GameTheme.neon:
        return GameConstants.neonSnake;
      case GameTheme.retro:
        return GameConstants.retroSnake;
      case GameTheme.space:
        return GameConstants.spaceSnake;
      case GameTheme.ocean:
        return GameConstants.oceanSnake;
      case GameTheme.cyberpunk:
        return GameConstants.cyberpunkSnake;
      case GameTheme.forest:
        return GameConstants.forestSnake;
      case GameTheme.desert:
        return GameConstants.desertSnake;
      case GameTheme.crystal:
        return GameConstants.crystalSnake;
    }
  }

  Color get foodColor {
    switch (this) {
      case GameTheme.classic:
        return GameConstants.classicFood;
      case GameTheme.modern:
        return GameConstants.modernFood;
      case GameTheme.neon:
        return GameConstants.neonFood;
      case GameTheme.retro:
        return GameConstants.retroFood;
      case GameTheme.space:
        return GameConstants.spaceFood;
      case GameTheme.ocean:
        return GameConstants.oceanFood;
      case GameTheme.cyberpunk:
        return GameConstants.cyberpunkFood;
      case GameTheme.forest:
        return GameConstants.forestFood;
      case GameTheme.desert:
        return GameConstants.desertFood;
      case GameTheme.crystal:
        return GameConstants.crystalFood;
    }
  }

  Color get accentColor {
    switch (this) {
      case GameTheme.classic:
        return GameConstants.classicBorder;
      case GameTheme.modern:
        return GameConstants.modernAccent;
      case GameTheme.neon:
        return GameConstants.neonGlow;
      case GameTheme.retro:
        return GameConstants.retroAccent;
      case GameTheme.space:
        return GameConstants.spaceAccent;
      case GameTheme.ocean:
        return GameConstants.oceanAccent;
      case GameTheme.cyberpunk:
        return GameConstants.cyberpunkAccent;
      case GameTheme.forest:
        return GameConstants.forestAccent;
      case GameTheme.desert:
        return GameConstants.desertAccent;
      case GameTheme.crystal:
        return GameConstants.crystalAccent;
    }
  }

  Color get primaryColor {
    switch (this) {
      case GameTheme.classic:
        return GameConstants.classicSnake;
      case GameTheme.modern:
        return GameConstants.modernSnake;
      case GameTheme.neon:
        return GameConstants.neonSnake;
      case GameTheme.retro:
        return GameConstants.retroSnake;
      case GameTheme.space:
        return GameConstants.spaceSnake;
      case GameTheme.ocean:
        return GameConstants.oceanSnake;
      case GameTheme.cyberpunk:
        return GameConstants.cyberpunkSnake;
      case GameTheme.forest:
        return GameConstants.forestSnake;
      case GameTheme.desert:
        return GameConstants.desertSnake;
      case GameTheme.crystal:
        return GameConstants.crystalSnake;
    }
  }

  Color get textColor {
    switch (this) {
      case GameTheme.classic:
      case GameTheme.modern:
      case GameTheme.retro:
        return Colors.black87;
      case GameTheme.neon:
      case GameTheme.space:
      case GameTheme.cyberpunk:
      case GameTheme.crystal:
        return Colors.white;
      case GameTheme.ocean:
      case GameTheme.forest:
        return Colors.white70;
      case GameTheme.desert:
        return Colors.black54;
    }
  }

  Color get cardColor {
    switch (this) {
      case GameTheme.classic:
        return Colors.white;
      case GameTheme.modern:
        return Colors.grey.shade100;
      case GameTheme.neon:
        return Colors.black12;
      case GameTheme.retro:
        return Colors.brown.shade100;
      case GameTheme.space:
        return Colors.indigo.shade900;
      case GameTheme.ocean:
        return Colors.blue.shade900;
      case GameTheme.cyberpunk:
        return Colors.purple.shade900;
      case GameTheme.forest:
        return Colors.green.shade900;
      case GameTheme.desert:
        return Colors.orange.shade100;
      case GameTheme.crystal:
        return Colors.purple.shade100;
    }
  }
}

enum GameMode {
  classic,
  zen,
  speedChallenge,
  multiFood,
  survival,
  timeAttack;

  String get name {
    switch (this) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.zen:
        return 'Zen Mode';
      case GameMode.speedChallenge:
        return 'Speed Challenge';
      case GameMode.multiFood:
        return 'Multi-Food';
      case GameMode.survival:
        return 'Survival';
      case GameMode.timeAttack:
        return 'Time Attack';
    }
  }

  String get description {
    switch (this) {
      case GameMode.classic:
        return 'The classic Snake game with walls';
      case GameMode.zen:
        return 'No walls - snake wraps around the screen';
      case GameMode.speedChallenge:
        return 'Speed increases rapidly for maximum challenge';
      case GameMode.multiFood:
        return 'Multiple food items appear at once';
      case GameMode.survival:
        return 'Survive as long as possible with limited lives';
      case GameMode.timeAttack:
        return 'Score as much as possible in limited time';
    }
  }

  String get icon {
    switch (this) {
      case GameMode.classic:
        return '🐍';
      case GameMode.zen:
        return '🧘';
      case GameMode.speedChallenge:
        return '⚡';
      case GameMode.multiFood:
        return '🍎';
      case GameMode.survival:
        return '❤️';
      case GameMode.timeAttack:
        return '⏰';
    }
  }

  bool get isPremium {
    switch (this) {
      case GameMode.classic:
        return false;
      case GameMode.zen:
      case GameMode.speedChallenge:
      case GameMode.multiFood:
      case GameMode.survival:
      case GameMode.timeAttack:
        return true;
    }
  }

  Duration? get timeLimit {
    switch (this) {
      case GameMode.timeAttack:
        return const Duration(minutes: 3);
      default:
        return null;
    }
  }

  int get initialLives {
    switch (this) {
      case GameMode.survival:
        return 3;
      default:
        return 1;
    }
  }

  bool get hasWalls {
    switch (this) {
      case GameMode.zen:
        return false;
      default:
        return true;
    }
  }

  bool get hasMultipleFood {
    switch (this) {
      case GameMode.multiFood:
        return true;
      default:
        return false;
    }
  }

  int get speedIncreaseRate {
    switch (this) {
      case GameMode.speedChallenge:
        return 15; // Faster speed increase
      case GameMode.timeAttack:
        return 20; // Very fast speed increase
      default:
        return 10; // Normal speed increase
    }
  }
}
