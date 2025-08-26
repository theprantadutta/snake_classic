import 'dart:math';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/snake.dart';

enum FoodType {
  normal,
  bonus,
  special;
  
  int get points {
    switch (this) {
      case FoodType.normal:
        return 10;
      case FoodType.bonus:
        return 25;
      case FoodType.special:
        return 50;
    }
  }
}

class Food {
  final Position position;
  final FoodType type;
  final DateTime createdAt;

  Food({
    required this.position,
    this.type = FoodType.normal,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static Position generateRandomPosition(
    int boardWidth,
    int boardHeight,
    Snake snake,
  ) {
    final random = Random();
    Position newPosition;
    
    do {
      newPosition = Position(
        random.nextInt(boardWidth),
        random.nextInt(boardHeight),
      );
    } while (snake.occupiesPosition(newPosition));
    
    return newPosition;
  }

  static Food generateRandom(
    int boardWidth,
    int boardHeight,
    Snake snake,
  ) {
    final position = generateRandomPosition(boardWidth, boardHeight, snake);
    final random = Random();
    
    FoodType type = FoodType.normal;
    final chance = random.nextDouble();
    
    if (chance < 0.05) {
      type = FoodType.special;
    } else if (chance < 0.15) {
      type = FoodType.bonus;
    }
    
    return Food(position: position, type: type);
  }

  bool get isExpired {
    if (type == FoodType.normal) return false;
    
    final expiration = type == FoodType.special ? 10000 : 15000; // milliseconds
    return DateTime.now().difference(createdAt).inMilliseconds > expiration;
  }
}