import 'package:flutter/material.dart';

class BoardSize {
  final int width;
  final int height;
  final String name;
  final String description;

  const BoardSize(this.width, this.height, this.name, this.description);

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
}

class GameConstants {
  // Board dimensions
  static const int defaultBoardWidth = 20;
  static const int defaultBoardHeight = 20;
  
  // Available board sizes
  static const List<BoardSize> availableBoardSizes = [
    BoardSize(15, 15, 'Small', 'Quick games, tight spaces'),
    BoardSize(20, 20, 'Classic', 'The original Snake experience'),
    BoardSize(25, 25, 'Large', 'More room to grow'),
    BoardSize(30, 30, 'Huge', 'Maximum challenge and space'),
  ];
  
  // Game timing
  static const int initialGameSpeed = 300; // milliseconds
  static const int minGameSpeed = 100;
  static const int maxGameSpeed = 500;
  
  // Crash feedback duration options
  static const List<Duration> availableCrashFeedbackDurations = [
    Duration(seconds: 2),
    Duration(seconds: 3),
    Duration(seconds: 4),
    Duration(seconds: 5),
    Duration(seconds: 6),
    Duration(seconds: 8),
    Duration(seconds: 10),
  ];
  static const Duration defaultCrashFeedbackDuration = Duration(seconds: 5);
  
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
  static const Color modernSnake = Color(0xFF4fc3f7);      // Bright cyan-blue
  static const Color modernFood = Color(0xFFe94560);       // Kept - good contrast
  static const Color modernAccent = Color(0xFF64b5f6);     // Light blue for better visibility
  
  // Colors - Neon Theme (Enhanced)
  static const Color neonBackground = Color(0xFF0a0a0a);
  static const Color neonSnake = Color(0xFF00ffff);         // Electric cyan
  static const Color neonFood = Color(0xFFff1493);         // Deep pink
  static const Color neonGlow = Color(0xFF00ff00);         // Pure lime green
  
  // Colors - Retro Theme
  static const Color retroBackground = Color(0xFF2C1810);   // Dark brown
  static const Color retroSnake = Color(0xFFD2691E);       // Chocolate/orange
  static const Color retroFood = Color(0xFFFFD700);        // Gold
  static const Color retroAccent = Color(0xFFCD853F);      // Peru/tan
  
  // Colors - Space Theme
  static const Color spaceBackground = Color(0xFF0B0C2A);   // Deep space blue
  static const Color spaceSnake = Color(0xFF9932CC);       // Dark orchid
  static const Color spaceFood = Color(0xFF00CED1);        // Dark turquoise
  static const Color spaceAccent = Color(0xFF4169E1);      // Royal blue
  
  // Colors - Ocean Theme
  static const Color oceanBackground = Color(0xFF001B3D);   // Deep ocean blue
  static const Color oceanSnake = Color(0xFF20B2AA);       // Light sea green
  static const Color oceanFood = Color(0xFFFF7F50);        // Coral
  static const Color oceanAccent = Color(0xFF4682B4);      // Steel blue
  
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
}

enum GameTheme {
  classic,
  modern,
  neon,
  retro,
  space,
  ocean;
  
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
    }
  }
}