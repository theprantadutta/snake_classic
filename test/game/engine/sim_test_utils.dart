import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// Builds a straight [length]-segment snake whose head is at [head] and whose
/// body trails away in the direction opposite to [direction], so the next
/// move is always into open space (unless the test arranges otherwise).
Snake makeSnake({
  Position head = const Position(5, 5),
  Direction direction = Direction.right,
  int length = 3,
}) {
  final Position trail;
  switch (direction) {
    case Direction.up:
      trail = const Position(0, 1);
    case Direction.down:
      trail = const Position(0, -1);
    case Direction.left:
      trail = const Position(1, 0);
    case Direction.right:
      trail = const Position(-1, 0);
  }
  final body = [
    for (var i = 0; i < length; i++)
      Position(head.x + trail.x * i, head.y + trail.y * i),
  ];
  return Snake(body: body, currentDirection: direction);
}

/// A snake with an explicit body (head first). The body list is copied so the
/// caller's list is safe from mutation.
Snake snakeFromBody(List<Position> body, Direction direction) =>
    Snake(body: List.of(body), currentDirection: direction);

/// A playing [GameState] with sensible defaults for simulation tests.
/// [comboMultiplier] and [maxCombo] default to values consistent with
/// [currentCombo] so tier-crossing flags behave as they would in a real game.
GameState makeState({
  required Snake snake,
  Food? food,
  List<Food> foods = const [],
  PowerUp? powerUp,
  List<ActivePowerUp> activePowerUps = const [],
  int score = 0,
  int level = 1,
  int currentCombo = 0,
  int? maxCombo,
  double? comboMultiplier,
  int comboIdleMs = 0,
  GameMode gameMode = GameMode.classic,
  int boardWidth = 20,
  int boardHeight = 20,
}) {
  return GameState(
    snake: snake,
    food: food,
    foods: foods,
    powerUp: powerUp,
    activePowerUps: activePowerUps,
    score: score,
    level: level,
    status: GameStatus.playing,
    currentCombo: currentCombo,
    maxCombo: maxCombo ?? currentCombo,
    comboMultiplier:
        comboMultiplier ?? GameState.calculateComboMultiplier(currentCombo),
    comboIdleMs: comboIdleMs,
    gameMode: gameMode,
    boardWidth: boardWidth,
    boardHeight: boardHeight,
  );
}

Food foodAt(
  Position position, {
  FoodType type = FoodType.normal,
  DateTime? createdAt,
}) =>
    Food(position: position, type: type, createdAt: createdAt);
