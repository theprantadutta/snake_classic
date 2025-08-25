import 'package:flutter/material.dart';

class GameConstants {
  static const int gridSize = 20;
  static const int initialGameSpeed = 200; // milliseconds
  static const int speedIncreasePerFood = 5; // milliseconds faster per food
  static const int pointsPerFood = 10;
  
  static const List<Offset> initialSnakePosition = [
    Offset(5, 5),
    Offset(4, 5),
    Offset(3, 5),
  ];
}

enum GameTheme {
  retro(
    name: "Retro",
    snakeColor: Color(0xFF00FF00),
    foodColor: Color(0xFFFF0000),
    backgroundColor: Color(0xFF000000),
    gridColor: Color(0xFF004400),
  ),
  neon(
    name: "Neon",
    snakeColor: Color(0xFF00FFFF),
    foodColor: Color(0xFFFF00FF),
    backgroundColor: Color(0xFF220022),
    gridColor: Color(0xFF440044),
  ),
  dark(
    name: "Dark",
    snakeColor: Color(0xFF44BB44),
    foodColor: Color(0xFFBB4444),
    backgroundColor: Color(0xFF111111),
    gridColor: Color(0xFF333333),
  ),
  light(
    name: "Light",
    snakeColor: Color(0xFF228822),
    foodColor: Color(0xFF882222),
    backgroundColor: Color(0xFFFFFFFF),
    gridColor: Color(0xFFEEEEEE),
  );

  const GameTheme({
    required this.name,
    required this.snakeColor,
    required this.foodColor,
    required this.backgroundColor,
    required this.gridColor,
  });

  final String name;
  final Color snakeColor;
  final Color foodColor;
  final Color backgroundColor;
  final Color gridColor;
}

enum GameStatus { notStarted, playing, paused, gameOver }

enum ControlType { swipe, buttons }

enum Difficulty {
  easy(name: "Easy", speedMultiplier: 1.5),
  medium(name: "Medium", speedMultiplier: 1.0),
  hard(name: "Hard", speedMultiplier: 0.7);

  const Difficulty({required this.name, required this.speedMultiplier});

  final String name;
  final double speedMultiplier;
}