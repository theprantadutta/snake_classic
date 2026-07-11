import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/engine/snake_simulation.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

import 'sim_test_utils.dart';

void main() {
  late SnakeSimulation sim;

  setUp(() {
    sim = SnakeSimulation();
  });

  /// Snake at (5,5) heading right; food directly in its path at (6,5).
  GameState eatingState({
    FoodType foodType = FoodType.normal,
    int score = 0,
    int level = 1,
    int currentCombo = 0,
    int comboIdleMs = 0,
    List<ActivePowerUp> activePowerUps = const [],
  }) {
    return makeState(
      snake: makeSnake(head: const Position(5, 5)),
      food: foodAt(const Position(6, 5), type: foodType),
      score: score,
      level: level,
      currentCombo: currentCombo,
      comboIdleMs: comboIdleMs,
      activePowerUps: activePowerUps,
    );
  }

  group('eating', () {
    test('fires FoodEatenEvent with the eaten food', () {
      final result = sim.step(eatingState());

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.food.position, const Position(6, 5));
      expect(event.basePoints, 10);
      expect(event.awardedPoints, 10);
      expect(event.newCombo, 1);
      expect(event.newMultiplier, 1.0);
      expect(event.comboTierIncreased, isFalse);
    });

    test('snake grows by exactly one segment', () {
      final result = sim.step(eatingState());

      final snake = result.nextState!.snake;
      expect(snake.length, 4);
      expect(snake.head, const Position(6, 5));
      // Tail stays put on an eating tick.
      expect(snake.tail, const Position(3, 5));
    });

    test('score increases by the awarded points', () {
      final result = sim.step(eatingState(score: 40));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(result.nextState!.score, 40 + event.awardedPoints);
    });

    test('a new food respawns and does not overlap the snake', () {
      final result = sim.step(eatingState());

      final next = result.nextState!;
      expect(next.food, isNotNull);
      expect(next.food, isNot(same(result.events.whereType<FoodEatenEvent>().single.food)));
      expect(next.snake.occupiesPosition(next.food!.position), isFalse);
      expect(next.food!.isExpired, isFalse);
    });

    test('no FoodEatenEvent when nothing is eaten', () {
      final food = foodAt(const Position(0, 0));
      final result = sim.step(
        makeState(snake: makeSnake(), food: food),
      );

      expect(result.events.whereType<FoodEatenEvent>(), isEmpty);
      expect(result.nextState!.food, same(food));
      expect(result.nextState!.score, 0);
      expect(result.nextState!.snake.length, 3);
    });
  });

  group('food tiers', () {
    test('normal food awards 10 points', () {
      final result = sim.step(eatingState(foodType: FoodType.normal));
      expect(result.nextState!.score, 10);
    });

    test('bonus food awards 25 points', () {
      final result = sim.step(eatingState(foodType: FoodType.bonus));
      expect(result.nextState!.score, 25);
    });

    test('special food awards 50 points', () {
      final result = sim.step(eatingState(foodType: FoodType.special));
      expect(result.nextState!.score, 50);
    });

    test('score-multiplier power-up doubles awarded points', () {
      final result = sim.step(eatingState(
        foodType: FoodType.bonus,
        activePowerUps: [ActivePowerUp(type: PowerUpType.scoreMultiplier)],
      ));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.basePoints, 25);
      expect(event.awardedPoints, 50);
      expect(result.nextState!.score, 50);
    });
  });

  group('combo', () {
    test('each bite increments the combo and resets the idle clock', () {
      final result = sim.step(eatingState(currentCombo: 2, comboIdleMs: 4000));

      final next = result.nextState!;
      expect(next.currentCombo, 3);
      expect(next.comboIdleMs, 0);
    });

    test('maxCombo tracks the best streak', () {
      final grew = sim.step(eatingState(currentCombo: 7));
      expect(grew.nextState!.maxCombo, 8);

      // maxCombo is retained even when the current streak is lower.
      final state = makeState(
        snake: makeSnake(head: const Position(5, 5)),
        food: foodAt(const Position(6, 5)),
        currentCombo: 3,
        maxCombo: 9,
      );
      final kept = sim.step(state);
      expect(kept.nextState!.currentCombo, 4);
      expect(kept.nextState!.maxCombo, 9);
    });

    test('multiplier tiers: 1.0 below 5, 1.5 at 5, 2.0 at 10, 3.0 at 20', () {
      expect(GameState.calculateComboMultiplier(1), 1.0);
      expect(GameState.calculateComboMultiplier(4), 1.0);
      expect(GameState.calculateComboMultiplier(5), 1.5);
      expect(GameState.calculateComboMultiplier(9), 1.5);
      expect(GameState.calculateComboMultiplier(10), 2.0);
      expect(GameState.calculateComboMultiplier(19), 2.0);
      expect(GameState.calculateComboMultiplier(20), 3.0);
    });

    test('crossing into the 1.5x tier (bite #5) flags comboTierIncreased', () {
      final result = sim.step(eatingState(currentCombo: 4));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.newCombo, 5);
      expect(event.newMultiplier, 1.5);
      expect(event.comboTierIncreased, isTrue);
      expect(event.awardedPoints, 15); // (10 * 1.5).round()
      expect(result.nextState!.comboMultiplier, 1.5);
    });

    test('bite within the same tier does not flag comboTierIncreased', () {
      final result = sim.step(eatingState(currentCombo: 5));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.newCombo, 6);
      expect(event.newMultiplier, 1.5);
      expect(event.comboTierIncreased, isFalse);
    });

    test('crossing into the 2x tier (bite #10)', () {
      final result = sim.step(eatingState(currentCombo: 9));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.newMultiplier, 2.0);
      expect(event.comboTierIncreased, isTrue);
      expect(event.awardedPoints, 20);
    });

    test('crossing into the 3x tier (bite #20)', () {
      final result = sim.step(eatingState(currentCombo: 19));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.newMultiplier, 3.0);
      expect(event.comboTierIncreased, isTrue);
      expect(event.awardedPoints, 30);
    });

    test('combo bonus and score-multiplier power-up stack', () {
      final result = sim.step(eatingState(
        foodType: FoodType.special,
        currentCombo: 19,
        activePowerUps: [ActivePowerUp(type: PowerUpType.scoreMultiplier)],
      ));

      final event = result.events.whereType<FoodEatenEvent>().single;
      // (50 * 3.0).round() * 2
      expect(event.awardedPoints, 300);
      expect(result.nextState!.score, 300);
    });
  });

  group('combo decay', () {
    test('idle game-time accumulates by gameSpeed each tick without a bite',
        () {
      final result = sim.step(makeState(
        snake: makeSnake(),
        currentCombo: 3,
        comboIdleMs: 0,
      ));

      // Level 1 classic tick is 300ms.
      expect(result.nextState!.comboIdleMs, 300);
      expect(result.nextState!.currentCombo, 3);
      expect(result.events.whereType<ComboBrokenEvent>(), isEmpty);
    });

    test('idle time accumulates at the effective (slow-motion) tick length',
        () {
      final result = sim.step(makeState(
        snake: makeSnake(),
        currentCombo: 3,
        comboIdleMs: 0,
        activePowerUps: [ActivePowerUp(type: PowerUpType.slowMotion)],
      ));

      // 300ms * 1.5 slow-motion = 450ms of experienced game-time.
      expect(result.nextState!.comboIdleMs, 450);
    });

    test('streak breaks once idle time reaches comboDecayMs', () {
      final result = sim.step(makeState(
        snake: makeSnake(),
        currentCombo: 7,
        comboIdleMs: GameConstants.comboDecayMs - 300,
      ));

      final broken = result.events.whereType<ComboBrokenEvent>().single;
      expect(broken.previousCombo, 7);
      final next = result.nextState!;
      expect(next.currentCombo, 0);
      expect(next.comboMultiplier, 1.0);
      expect(next.comboIdleMs, 0);
    });

    test('streak survives one tick short of the decay threshold', () {
      final result = sim.step(makeState(
        snake: makeSnake(),
        currentCombo: 7,
        comboIdleMs: GameConstants.comboDecayMs - 301,
      ));

      expect(result.events.whereType<ComboBrokenEvent>(), isEmpty);
      expect(result.nextState!.currentCombo, 7);
      expect(result.nextState!.comboIdleMs, GameConstants.comboDecayMs - 1);
    });

    test('eating just before the deadline keeps the streak alive', () {
      final result = sim.step(eatingState(
        currentCombo: 7,
        comboIdleMs: GameConstants.comboDecayMs - 300,
      ));

      expect(result.events.whereType<ComboBrokenEvent>(), isEmpty);
      expect(result.nextState!.currentCombo, 8);
      expect(result.nextState!.comboIdleMs, 0);
    });

    test('zen mode never decays the combo', () {
      final result = sim.step(makeState(
        snake: makeSnake(),
        gameMode: GameMode.zen,
        currentCombo: 12,
        comboMultiplier: 2.0,
        comboIdleMs: 999999,
      ));

      expect(result.events.whereType<ComboBrokenEvent>(), isEmpty);
      final next = result.nextState!;
      expect(next.currentCombo, 12);
      expect(next.comboMultiplier, 2.0);
      // The idle clock is not even advanced in zen.
      expect(next.comboIdleMs, 999999);
    });

    test('no idle accumulation while the combo is zero', () {
      final result = sim.step(makeState(snake: makeSnake()));

      expect(result.nextState!.comboIdleMs, 0);
      expect(result.events.whereType<ComboBrokenEvent>(), isEmpty);
    });
  });

  group('level up', () {
    test('level thresholds follow the triangular progression', () {
      expect(GameState.getTargetScoreForLevel(1), 0);
      expect(GameState.getTargetScoreForLevel(2), 100);
      expect(GameState.getTargetScoreForLevel(3), 300);
      expect(GameState.getTargetScoreForLevel(4), 600);
      expect(GameState.getTargetScoreForLevel(5), 1000);
    });

    test('crossing a threshold fires LeveledUpEvent(from, to)', () {
      final result = sim.step(eatingState(score: 95));

      final event = result.events.whereType<LeveledUpEvent>().single;
      expect(event.fromLevel, 1);
      expect(event.toLevel, 2);
      expect(result.nextState!.level, 2);
      expect(result.nextState!.score, 105);
    });

    test('a single high-combo bite can jump multiple levels', () {
      // Score 90 at level 1; special food at combo 20 with a 2x score
      // multiplier awards (50 * 3.0).round() * 2 = 300 points -> score 390,
      // which crosses both the level-2 (100) and level-3 (300) thresholds.
      final result = sim.step(eatingState(
        foodType: FoodType.special,
        score: 90,
        currentCombo: 19,
        activePowerUps: [ActivePowerUp(type: PowerUpType.scoreMultiplier)],
      ));

      final event = result.events.whereType<LeveledUpEvent>().single;
      expect(event.fromLevel, 1);
      expect(event.toLevel, 3);
      expect(result.nextState!.level, 3);
      expect(result.nextState!.score, 390);
    });

    test('events are ordered FoodEatenEvent then LeveledUpEvent', () {
      final result = sim.step(eatingState(score: 95));

      expect(result.events, hasLength(2));
      expect(result.events[0], isA<FoodEatenEvent>());
      expect(result.events[1], isA<LeveledUpEvent>());
    });

    test('no LeveledUpEvent when the threshold is not crossed', () {
      final result = sim.step(eatingState(score: 40));

      expect(result.events.whereType<LeveledUpEvent>(), isEmpty);
      expect(result.nextState!.level, 1);
    });
  });

  group('food expiry', () {
    test('expired special food (>10s) is regenerated', () {
      final stale = foodAt(
        const Position(0, 0),
        type: FoodType.special,
        createdAt: DateTime.now().subtract(const Duration(seconds: 11)),
      );
      final result = sim.step(makeState(snake: makeSnake(), food: stale));

      final regenerated = result.nextState!.food!;
      expect(regenerated, isNot(same(stale)));
      expect(regenerated.isExpired, isFalse);
      expect(regenerated.createdAt.isAfter(stale.createdAt), isTrue);
    });

    test('expired bonus food (>15s) is regenerated', () {
      final stale = foodAt(
        const Position(0, 0),
        type: FoodType.bonus,
        createdAt: DateTime.now().subtract(const Duration(seconds: 16)),
      );
      final result = sim.step(makeState(snake: makeSnake(), food: stale));

      final regenerated = result.nextState!.food!;
      expect(regenerated, isNot(same(stale)));
      expect(regenerated.isExpired, isFalse);
    });

    test('normal food never expires', () {
      final ancient = foodAt(
        const Position(0, 0),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      final result = sim.step(makeState(snake: makeSnake(), food: ancient));

      expect(result.nextState!.food, same(ancient));
    });

    test('bonus food within its 15s lifetime is kept', () {
      final fresh = foodAt(
        const Position(0, 0),
        type: FoodType.bonus,
        createdAt: DateTime.now().subtract(const Duration(seconds: 5)),
      );
      final result = sim.step(makeState(snake: makeSnake(), food: fresh));

      expect(result.nextState!.food, same(fresh));
    });
  });

  group('multi-food mode', () {
    test('eating an extra food scores it and regenerates only that slot', () {
      final primary = foodAt(const Position(0, 0));
      final extraInPath = foodAt(const Position(6, 5), type: FoodType.bonus);
      final otherExtra = foodAt(const Position(0, 19));
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        gameMode: GameMode.multiFood,
        food: primary,
        foods: [extraInPath, otherExtra],
      ));

      final event = result.events.whereType<FoodEatenEvent>().single;
      expect(event.food, same(extraInPath));
      expect(event.basePoints, 25);

      final next = result.nextState!;
      expect(next.score, 25);
      expect(next.snake.length, 4);
      // Primary and the other extra are untouched.
      expect(next.food, same(primary));
      expect(next.foods, hasLength(2));
      expect(next.foods[1], same(otherExtra));
      // The eaten slot is regenerated without overlaps.
      final regenerated = next.foods[0];
      expect(regenerated, isNot(same(extraInPath)));
      expect(next.snake.occupiesPosition(regenerated.position), isFalse);
      expect(regenerated.position, isNot(primary.position));
      expect(regenerated.position, isNot(otherExtra.position));
    });

    test('eating the primary food leaves the extras untouched', () {
      final extra1 = foodAt(const Position(0, 0));
      final extra2 = foodAt(const Position(0, 19));
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        gameMode: GameMode.multiFood,
        food: foodAt(const Position(6, 5)),
        foods: [extra1, extra2],
      ));

      final next = result.nextState!;
      expect(next.foods[0], same(extra1));
      expect(next.foods[1], same(extra2));
      // Regenerated primary avoids the snake and the extras.
      expect(next.food, isNotNull);
      expect(next.snake.occupiesPosition(next.food!.position), isFalse);
      expect(next.food!.position, isNot(extra1.position));
      expect(next.food!.position, isNot(extra2.position));
    });

    test('an expired extra food is regenerated in place', () {
      final staleExtra = foodAt(
        const Position(0, 10),
        type: FoodType.special,
        createdAt: DateTime.now().subtract(const Duration(seconds: 11)),
      );
      final freshExtra = foodAt(const Position(0, 19));
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        gameMode: GameMode.multiFood,
        food: foodAt(const Position(0, 0)),
        foods: [staleExtra, freshExtra],
      ));

      final next = result.nextState!;
      expect(next.foods, hasLength(2));
      expect(next.foods[0], isNot(same(staleExtra)));
      expect(next.foods[0].isExpired, isFalse);
      expect(next.foods[1], same(freshExtra));
    });

    test('extras are ignored outside multi-food modes', () {
      // In classic mode an expired entry in `foods` is left alone.
      final staleExtra = foodAt(
        const Position(0, 10),
        type: FoodType.special,
        createdAt: DateTime.now().subtract(const Duration(seconds: 11)),
      );
      final result = sim.step(makeState(
        snake: makeSnake(),
        food: foodAt(const Position(0, 0)),
        foods: [staleExtra],
      ));

      expect(result.nextState!.foods.single, same(staleExtra));
    });
  });

  group('generateNonOverlappingFood', () {
    test('never lands on the snake, existing foods, or the power-up '
        '(crowded 10x10 board, 100 samples)', () {
      final body = [
        for (var x = 0; x < 10; x++) Position(x, 0),
        for (var x = 9; x >= 0; x--) Position(x, 1),
      ];
      final snake = snakeFromBody(body, Direction.right);
      final existing = [
        for (var x = 0; x < 10; x++) foodAt(Position(x, 2)),
        for (var x = 0; x < 10; x++) foodAt(Position(x, 3)),
      ];
      const powerUpPos = Position(0, 4);
      final blocked = <Position>{
        ...body,
        ...existing.map((f) => f.position),
        powerUpPos,
      };

      for (var i = 0; i < 100; i++) {
        final food = sim.generateNonOverlappingFood(
          10,
          10,
          snake,
          existing: existing,
          powerUpPosition: powerUpPos,
        );
        expect(
          blocked.contains(food.position),
          isFalse,
          reason: 'sample $i landed on a blocked cell ${food.position}',
        );
        expect(food.position.isWithinBounds(10, 10), isTrue);
      }
    });
  });

  group('generateInitialFoods', () {
    test('multi-food mode spawns a primary plus two distinct extras', () {
      final snake = makeSnake();
      final foods =
          sim.generateInitialFoods(20, 20, snake, GameMode.multiFood);

      expect(foods.extras, hasLength(2));
      final positions = <Position>{
        foods.primary.position,
        ...foods.extras.map((f) => f.position),
      };
      expect(positions, hasLength(3), reason: 'foods must not overlap');
      for (final p in positions) {
        expect(snake.occupiesPosition(p), isFalse);
      }
    });

    test('classic mode spawns only the primary', () {
      final foods =
          sim.generateInitialFoods(20, 20, makeSnake(), GameMode.classic);

      expect(foods.extras, isEmpty);
      expect(foods.primary.position.isWithinBounds(20, 20), isTrue);
    });
  });

  group('expired-food regeneration overlap (regression)', () {
    test('regenerated primary food avoids extras and the on-board power-up',
        () {
      // Small board, heavily crowded: the snake sits mid-board, extras and
      // the power-up occupy most other cells. The expired primary must
      // regenerate on none of them (this path used to avoid only the
      // snake). 40 rounds make a lucky-miss pass astronomically unlikely.
      final snake = makeSnake(head: const Position(2, 2), length: 3);
      const powerUpPos = Position(2, 1);
      // 8 extras (not more): the generator rejection-samples 32 times and
      // then falls back WITHOUT avoidance — over-crowding the board would
      // make the fallback fire often enough to flake this test. At 12/25
      // cells taken the fallback probability is ~6e-11 per round.
      final extraPositions = <Position>[
        for (var x = 0; x < 5; x++)
          for (var y = 0; y < 5; y++)
            if (x != 2 && y != 2) Position(x, y),
      ].take(8).toList();
      final extras = [for (final p in extraPositions) foodAt(p)];
      final taken = {
        ...extraPositions,
        powerUpPos,
        ...snake.body,
      };

      for (var round = 0; round < 40; round++) {
        final result = sim.step(makeState(
          snake: snake,
          boardWidth: 5,
          boardHeight: 5,
          // Special food expires after 10s — 12s old is expired.
          food: foodAt(
            const Position(2, 3),
            type: FoodType.special,
            createdAt: DateTime.now().subtract(const Duration(seconds: 12)),
          ),
          foods: extras,
          powerUp: PowerUp(
            type: PowerUpType.speedBoost,
            position: powerUpPos,
          ),
        ));

        expect(result.crashed, isFalse);
        final regenerated = result.nextState!.food;
        expect(regenerated, isNotNull);
        expect(
          taken.contains(regenerated!.position),
          isFalse,
          reason: 'regenerated food landed on an occupied cell '
              '${regenerated.position} (round $round)',
        );
      }
    });
  });

  group('GameState.clearFood (regression: used to be a no-op)', () {
    test('clearFood() actually clears the primary food', () {
      final state = makeState(
        snake: makeSnake(),
        food: foodAt(const Position(1, 1)),
      );
      expect(state.food, isNotNull);
      expect(state.clearFood().food, isNull);
    });

    test('copyWith without clearFood still preserves the food', () {
      final state = makeState(
        snake: makeSnake(),
        food: foodAt(const Position(1, 1)),
      );
      expect(state.copyWith(score: 10).food, isNotNull);
    });
  });
}
