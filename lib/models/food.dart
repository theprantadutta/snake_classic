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
    // Bounded retry mirrors PowerUp.generateRandom — on a near-full late-game
    // board the random walk could theoretically spin forever; cap attempts
    // then deterministically scan for the first free cell.
    for (var attempt = 0; attempt < 64; attempt++) {
      final candidate = Position(
        random.nextInt(boardWidth),
        random.nextInt(boardHeight),
      );
      if (!snake.occupiesPosition(candidate)) {
        return candidate;
      }
    }
    for (var x = 0; x < boardWidth; x++) {
      for (var y = 0; y < boardHeight; y++) {
        final fallback = Position(x, y);
        if (!snake.occupiesPosition(fallback)) {
          return fallback;
        }
      }
    }
    return Position(0, 0);
  }

  static Food generateRandom(int boardWidth, int boardHeight, Snake snake) {
    final position = generateRandomPosition(boardWidth, boardHeight, snake);
    final random = Random();

    FoodType type = FoodType.normal;
    final chance = random.nextDouble();

    // Roughly: 8% special (50pt star), 10% bonus (25pt), 82% normal (10pt).
    // Bumped special from 5% to 8% so players see a special target every
    // ~12 foods on average instead of every ~20 — still rare enough to feel
    // like a reward but no longer feels random-luck-only.
    if (chance < 0.08) {
      type = FoodType.special;
    } else if (chance < 0.18) {
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
