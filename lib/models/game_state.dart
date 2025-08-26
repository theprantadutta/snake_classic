import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/snake.dart';

enum GameStatus {
  playing,
  paused,
  gameOver,
  menu;
}

class GameState {
  final Snake snake;
  final Food? food;
  final int score;
  final int highScore;
  final GameStatus status;
  final int level;
  final int boardWidth;
  final int boardHeight;
  final DateTime? lastMoveTime;

  const GameState({
    required this.snake,
    this.food,
    this.score = 0,
    this.highScore = 0,
    this.status = GameStatus.menu,
    this.level = 1,
    this.boardWidth = 20,
    this.boardHeight = 20,
    this.lastMoveTime,
  });

  factory GameState.initial() {
    return GameState(
      snake: Snake.initial(),
      status: GameStatus.menu,
    );
  }

  int get gameSpeed {
    // Speed increases with level (lower milliseconds = faster)
    // Start at 300ms, decrease by 20ms per level, minimum 100ms
    final baseSpeed = 300;
    final speedDecrease = (level - 1) * 20;
    return (baseSpeed - speedDecrease).clamp(100, 300);
  }

  int get targetScore => level * 100;

  bool get shouldLevelUp => score >= targetScore;

  GameState copyWith({
    Snake? snake,
    Food? food,
    int? score,
    int? highScore,
    GameStatus? status,
    int? level,
    int? boardWidth,
    int? boardHeight,
    DateTime? lastMoveTime,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      level: level ?? this.level,
      boardWidth: boardWidth ?? this.boardWidth,
      boardHeight: boardHeight ?? this.boardHeight,
      lastMoveTime: lastMoveTime ?? this.lastMoveTime,
    );
  }

  GameState clearFood() {
    return copyWith(food: null);
  }
}