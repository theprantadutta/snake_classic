import 'dart:math';

import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/constants.dart';

/// Pure, framework-free Snake game mechanics.
///
/// This is the heart of the game extracted out of `GameCubit`: movement,
/// collision (wall / self / no-revisit), food expiry + regeneration,
/// multi-food handling, power-up expiry + collection, combo and level math.
/// It performs **no** side effects (no audio, haptics, analytics, coins, XP,
/// recording, or `emit`) — instead [step] returns the next [model.GameState]
/// plus a list of [TickEvent]s describing what happened, which the host
/// translates into side effects.
///
/// The only state the simulation owns is the per-run [visitedCells] set (for
/// PerfectGame mode) and the sticky [isPro] flag (which biases food / power-up
/// spawn rates). Everything else flows through the [model.GameState] passed to
/// [step].
class SnakeSimulation {
  /// Pro status snapshot, taken once per run at [reset]. Biases the special
  /// food rate and the in-game power-up spawn chance.
  bool isPro = false;

  /// Every cell the snake's head has occupied this life. Only consulted in
  /// modes where `gameMode.enforcesNoRevisit` is true (PerfectGame). Reset on
  /// game start and on each Survival respawn (the rule is per-life).
  final Set<Position> visitedCells = {};

  /// Reset the per-run simulation state. Call on game start and on Survival
  /// respawn. [isPro] is sticky for the run.
  void reset({required Iterable<Position> snakeBody, bool? isPro}) {
    if (isPro != null) this.isPro = isPro;
    visitedCells
      ..clear()
      ..addAll(snakeBody);
  }

  /// Advance the game by one logical tick. Returns the next state and the
  /// events that occurred. On a fatal collision, [TickResult.crashed] is true,
  /// `nextState` is null, and the events contain a [CrashEvent] carrying the
  /// fatal snake; the host owns the crash flow.
  TickResult step(model.GameState previousState) {
    final events = <TickEvent>[];
    final snake = previousState.snake.copy();
    final isMultiFood = previousState.gameMode.hasMultipleFood;

    // Expired primary food → regenerate.
    var currentFood = previousState.food;
    if (currentFood?.isExpired == true) {
      currentFood = Food.generateRandom(
        previousState.boardWidth,
        previousState.boardHeight,
        snake,
        isPremium: isPro,
      );
    }

    // MultiFood: refresh any expired extras so the board keeps its target
    // count of simultaneously-visible foods.
    var extraFoods = List<Food>.from(previousState.foods);
    if (isMultiFood) {
      for (var i = 0; i < extraFoods.length; i++) {
        if (extraFoods[i].isExpired) {
          extraFoods[i] = generateNonOverlappingFood(
            previousState.boardWidth,
            previousState.boardHeight,
            snake,
            existing: [
              ?currentFood,
              ...extraFoods.where((f) => f != extraFoods[i]),
            ],
            powerUpPosition: previousState.powerUp?.position,
          );
        }
      }
    }

    // Expired on-board power-up.
    var currentPowerUp = previousState.powerUp;
    var shouldClearPowerUp = false;
    if (currentPowerUp?.isExpired == true) {
      currentPowerUp = null;
      shouldClearPowerUp = true;
    }

    // Detect collisions before moving.
    final nextHeadPosition = snake.head.move(snake.currentDirection);
    final willEatPrimaryFood =
        currentFood != null && nextHeadPosition == currentFood.position;
    int eatenExtraIndex = -1;
    if (!willEatPrimaryFood && isMultiFood) {
      for (var i = 0; i < extraFoods.length; i++) {
        if (extraFoods[i].position == nextHeadPosition) {
          eatenExtraIndex = i;
          break;
        }
      }
    }
    final willEatFood = willEatPrimaryFood || eatenExtraIndex >= 0;

    // Power-up collision: check both current and next head position so we
    // don't miss collection if the snake spawned on / passed through it.
    final willCollectPowerUp = currentPowerUp != null &&
        (nextHeadPosition == currentPowerUp.position ||
            snake.head == currentPowerUp.position);

    // Immunity (invincibility / post-revive grace / ghost mode) bypasses the
    // walls. Bypassing is only safe if the snake stays on the board, so while
    // immune we wrap it to the opposite edge (same as no-wall modes).
    final hasImmunity =
        previousState.hasInvincibility || previousState.hasGhostMode;

    snake.move(
      ateFood: willEatFood,
      boardWidth: previousState.boardWidth,
      boardHeight: previousState.boardHeight,
      wrapAround: !previousState.gameMode.hasWalls || hasImmunity,
    );

    final wallCollision = !hasImmunity &&
        previousState.gameMode.hasWalls &&
        snake.checkWallCollision(
          previousState.boardWidth,
          previousState.boardHeight,
        );
    final selfCollision = !hasImmunity && snake.checkSelfCollision();

    if (wallCollision || selfCollision) {
      final reason = wallCollision
          ? model.CrashReason.wallCollision
          : model.CrashReason.selfCollision;
      final collisionBodyPart =
          selfCollision ? snake.getSelfCollisionBodyPart() : null;
      return TickResult(
        nextState: null,
        crashed: true,
        events: [
          CrashEvent(
            reason: reason,
            position: snake.head,
            collisionBodyPart: collisionBodyPart,
            fatalSnake: snake,
          ),
        ],
      );
    }

    // PerfectGame: head re-entering a previously-visited cell is fatal. The
    // self-collision branch above already catches landing on the live body, so
    // any revisit reaching here is a true trail-cross.
    if (previousState.gameMode.enforcesNoRevisit &&
        !hasImmunity &&
        visitedCells.contains(snake.head)) {
      return TickResult(
        nextState: null,
        crashed: true,
        events: [
          CrashEvent(
            reason: model.CrashReason.selfCollision,
            position: snake.head,
            fatalSnake: snake,
          ),
        ],
      );
    }
    visitedCells.add(snake.head);

    // Food consumption → score / combo / level.
    var newScore = previousState.score;
    var newLevel = previousState.level;
    var newCombo = previousState.currentCombo;
    var newMaxCombo = previousState.maxCombo;
    var newComboMultiplier = previousState.comboMultiplier;

    if (willEatFood) {
      final eatenFood =
          willEatPrimaryFood ? currentFood : extraFoods[eatenExtraIndex];

      newCombo++;
      newMaxCombo = max(newMaxCombo, newCombo);
      newComboMultiplier = model.GameState.calculateComboMultiplier(newCombo);
      final comboTierIncreased =
          newComboMultiplier > previousState.comboMultiplier;

      final basePoints = eatenFood.type.points;
      final comboBonus = (basePoints * newComboMultiplier).round();
      final multipliedPoints = comboBonus * previousState.scoreMultiplier;
      newScore += multipliedPoints;

      // Level up (unlimited levels). Loop so a high-combo bite can cross
      // multiple thresholds in one tick.
      final previousLevel = newLevel;
      while (newScore >= model.GameState.getTargetScoreForLevel(newLevel + 1)) {
        newLevel++;
      }

      events.add(FoodEatenEvent(
        food: eatenFood,
        basePoints: basePoints,
        awardedPoints: multipliedPoints,
        newCombo: newCombo,
        newMultiplier: newComboMultiplier,
        comboTierIncreased: comboTierIncreased,
      ));
      if (newLevel > previousLevel) {
        events.add(LeveledUpEvent(fromLevel: previousLevel, toLevel: newLevel));
      }

      // Regenerate only the eaten slot, preserving the other visible foods.
      if (willEatPrimaryFood) {
        currentFood = generateNonOverlappingFood(
          previousState.boardWidth,
          previousState.boardHeight,
          snake,
          existing: extraFoods,
          powerUpPosition: currentPowerUp?.position,
        );
      } else {
        extraFoods[eatenExtraIndex] = generateNonOverlappingFood(
          previousState.boardWidth,
          previousState.boardHeight,
          snake,
          existing: [
            ?currentFood,
            ...extraFoods.where((f) => f != extraFoods[eatenExtraIndex]),
          ],
          powerUpPosition: currentPowerUp?.position,
        );
      }
    }

    // Drop expired active power-ups. (Inline filter instead of
    // removeExpiredPowerUps() which allocates a throwaway GameState.)
    var activePowerUps =
        previousState.activePowerUps.where((p) => !p.isExpired).toList();

    if (willCollectPowerUp) {
      activePowerUps = [
        ...activePowerUps,
        ActivePowerUp(type: currentPowerUp.type),
      ];
      events.add(PowerUpCollectedEvent(currentPowerUp));
      currentPowerUp = null;
      shouldClearPowerUp = true;
    }

    // PerfectGame: snapshot visited cells into state for the painter; empty
    // out of mode so the painter early-outs at zero cost.
    final visitedSnapshot = previousState.gameMode.enforcesNoRevisit
        ? Set<Position>.of(visitedCells)
        : const <Position>{};

    final nextState = previousState.copyWith(
      snake: snake,
      food: currentFood,
      foods: extraFoods,
      powerUp: currentPowerUp,
      clearPowerUp: shouldClearPowerUp,
      score: newScore,
      level: newLevel,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      comboMultiplier: newComboMultiplier,
      activePowerUps: activePowerUps,
      lastMoveTime: DateTime.now(),
      visitedCells: visitedSnapshot,
    );

    return TickResult(nextState: nextState, events: events);
  }

  /// Generate the initial food (and MultiFood extras) for a fresh snake. Used
  /// by game start and Survival respawn.
  ({Food primary, List<Food> extras}) generateInitialFoods(
    int boardWidth,
    int boardHeight,
    Snake snake,
    GameMode mode,
  ) {
    final primary = Food.generateRandom(
      boardWidth,
      boardHeight,
      snake,
      isPremium: isPro,
    );
    final extras = <Food>[];
    if (mode.hasMultipleFood) {
      for (var i = 0; i < 2; i++) {
        extras.add(generateNonOverlappingFood(
          boardWidth,
          boardHeight,
          snake,
          existing: [primary, ...extras],
        ));
      }
    }
    return (primary: primary, extras: extras);
  }

  /// Generate a Food whose position doesn't overlap the snake, any already
  /// placed foods, or the active power-up. Bounded retry then unguarded
  /// fallback so the tick can never deadlock.
  Food generateNonOverlappingFood(
    int boardWidth,
    int boardHeight,
    Snake snake, {
    Iterable<Food> existing = const [],
    Position? powerUpPosition,
  }) {
    final taken = <Position>{
      ...existing.map((f) => f.position),
      ?powerUpPosition,
    };
    for (var attempt = 0; attempt < 32; attempt++) {
      final candidate = Food.generateRandom(
        boardWidth,
        boardHeight,
        snake,
        isPremium: isPro,
      );
      if (!taken.contains(candidate.position)) {
        return candidate;
      }
    }
    return Food.generateRandom(boardWidth, boardHeight, snake, isPremium: isPro);
  }

  /// Roll the in-game power-up spawn. Returns a new on-board power-up to place,
  /// or null if the roll failed or generation couldn't find a free cell. The
  /// caller is responsible for only calling this when no power-up is present.
  PowerUp? trySpawnPowerUp(model.GameState current) {
    final random = Random();
    final baseChance = current.gameMode.powerUpSpawnChanceOverride ?? 0.5;
    // Pro perk: 30% more spawns, capped at 0.95 so an already-high override
    // doesn't become a guarantee.
    final spawnChance = isPro ? min(0.95, baseChance * 1.3) : baseChance;
    if (random.nextDouble() >= spawnChance) return null;
    return PowerUp.generateRandom(
      current.boardWidth,
      current.boardHeight,
      current.snake,
      foodPosition: current.food?.position,
      foodPositions: current.foods.map((f) => f.position),
    );
  }
}
