import 'dart:math';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:flutter/material.dart';

enum PowerUpType {
  speedBoost,
  invincibility,
  scoreMultiplier,
  slowMotion;
  
  String get name {
    switch (this) {
      case PowerUpType.speedBoost:
        return 'Speed Boost';
      case PowerUpType.invincibility:
        return 'Invincibility';
      case PowerUpType.scoreMultiplier:
        return 'Score Multiplier';
      case PowerUpType.slowMotion:
        return 'Slow Motion';
    }
  }
  
  String get description {
    switch (this) {
      case PowerUpType.speedBoost:
        return 'Increases snake speed for 10 seconds';
      case PowerUpType.invincibility:
        return 'Pass through walls and yourself for 8 seconds';
      case PowerUpType.scoreMultiplier:
        return 'Double points for 15 seconds';
      case PowerUpType.slowMotion:
        return 'Slows down game for precise control (12 seconds)';
    }
  }
  
  String get icon {
    switch (this) {
      case PowerUpType.speedBoost:
        return '⚡';
      case PowerUpType.invincibility:
        return '🛡️';
      case PowerUpType.scoreMultiplier:
        return '💰';
      case PowerUpType.slowMotion:
        return '🐌';
    }
  }
  
  Color get color {
    switch (this) {
      case PowerUpType.speedBoost:
        return Colors.yellow;
      case PowerUpType.invincibility:
        return Colors.blue;
      case PowerUpType.scoreMultiplier:
        return Colors.green;
      case PowerUpType.slowMotion:
        return Colors.purple;
    }
  }
  
  Duration get duration {
    switch (this) {
      case PowerUpType.speedBoost:
        return const Duration(seconds: 10);
      case PowerUpType.invincibility:
        return const Duration(seconds: 8);
      case PowerUpType.scoreMultiplier:
        return const Duration(seconds: 15);
      case PowerUpType.slowMotion:
        return const Duration(seconds: 12);
    }
  }
  
  int get rarity {
    switch (this) {
      case PowerUpType.speedBoost:
        return 3; // Common
      case PowerUpType.invincibility:
        return 1; // Rare
      case PowerUpType.scoreMultiplier:
        return 2; // Uncommon
      case PowerUpType.slowMotion:
        return 2; // Uncommon
    }
  }
}

class PowerUp {
  final Position position;
  final PowerUpType type;
  final DateTime createdAt;

  PowerUp({
    required this.position,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static Position generateRandomPosition(
    int boardWidth,
    int boardHeight,
    Snake snake, {
    Position? foodPosition,
  }) {
    final random = Random();
    Position newPosition;
    
    do {
      newPosition = Position(
        random.nextInt(boardWidth),
        random.nextInt(boardHeight),
      );
    } while (snake.occupiesPosition(newPosition) || 
             (foodPosition != null && newPosition == foodPosition));
    
    return newPosition;
  }

  static PowerUp? generateRandom(
    int boardWidth,
    int boardHeight,
    Snake snake, {
    Position? foodPosition,
  }) {
    final random = Random();
    
    // Power-ups have a 5% chance to spawn
    if (random.nextDouble() > 0.05) {
      return null;
    }
    
    final position = generateRandomPosition(
      boardWidth, 
      boardHeight, 
      snake, 
      foodPosition: foodPosition,
    );
    
    // Select power-up type based on rarity
    final totalRarity = PowerUpType.values.fold(0, (sum, type) => sum + type.rarity);
    final randomValue = random.nextInt(totalRarity);
    
    int currentValue = 0;
    for (final type in PowerUpType.values) {
      currentValue += type.rarity;
      if (randomValue < currentValue) {
        return PowerUp(position: position, type: type);
      }
    }
    
    return PowerUp(position: position, type: PowerUpType.speedBoost);
  }

  bool get isExpired {
    // Power-ups expire after 20 seconds if not collected
    return DateTime.now().difference(createdAt).inSeconds > 20;
  }

  // Time remaining before expiration
  int get secondsRemaining {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (20 - elapsed).clamp(0, 20);
  }

  // Returns true if power-up is about to expire (last 5 seconds)
  bool get isExpiringSoon {
    return secondsRemaining <= 5 && secondsRemaining > 0;
  }

  // Warning intensity from 0.0 (5 seconds left) to 1.0 (0 seconds left)
  double get warningIntensity {
    if (!isExpiringSoon) return 0.0;
    return 1.0 - (secondsRemaining / 5.0);
  }

  double get pulsePhase {
    // Create a pulsing animation effect
    final secondsSinceCreated = DateTime.now().difference(createdAt).inMilliseconds / 1000.0;
    return (sin(secondsSinceCreated * 3.0) + 1.0) / 2.0; // 0.0 to 1.0
  }
}

class ActivePowerUp {
  final PowerUpType type;
  final DateTime activatedAt;
  final Duration duration;

  ActivePowerUp({
    required this.type,
    DateTime? activatedAt,
    Duration? duration,
  }) : activatedAt = activatedAt ?? DateTime.now(),
       duration = duration ?? type.duration;

  bool get isExpired {
    return DateTime.now().difference(activatedAt) >= duration;
  }
  
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(activatedAt);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  double get progress {
    final elapsed = DateTime.now().difference(activatedAt).inMilliseconds;
    final total = duration.inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}