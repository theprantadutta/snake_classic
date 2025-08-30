import 'package:flutter/material.dart';

class GameConstants {
  // Board dimensions
  static const int defaultBoardWidth = 20;
  static const int defaultBoardHeight = 20;
  
  // Game timing
  static const int initialGameSpeed = 300; // milliseconds
  static const int minGameSpeed = 100;
  static const int maxGameSpeed = 500;
  
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
}

enum GameTheme {
  classic,
  modern,
  neon;
  
  String get name {
    switch (this) {
      case GameTheme.classic:
        return 'Classic';
      case GameTheme.modern:
        return 'Modern';
      case GameTheme.neon:
        return 'Neon';
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
    }
  }
}