import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/engine/snake_simulation.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
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

  group('basic movement', () {
    test('moves right: head advances one cell, body follows', () {
      final snake = makeSnake(
        head: const Position(5, 5),
        direction: Direction.right,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isFalse);
      final next = result.nextState!;
      expect(next.snake.head, const Position(6, 5));
      expect(next.snake.body, [
        const Position(6, 5),
        const Position(5, 5),
        const Position(4, 5),
      ]);
    });

    test('moves left', () {
      final snake = makeSnake(
        head: const Position(5, 5),
        direction: Direction.left,
      );
      final result = sim.step(makeState(snake: snake));

      final next = result.nextState!;
      expect(next.snake.head, const Position(4, 5));
      expect(next.snake.body, [
        const Position(4, 5),
        const Position(5, 5),
        const Position(6, 5),
      ]);
    });

    test('moves up', () {
      final snake = makeSnake(
        head: const Position(5, 5),
        direction: Direction.up,
      );
      final result = sim.step(makeState(snake: snake));

      final next = result.nextState!;
      expect(next.snake.head, const Position(5, 4));
      expect(next.snake.body, [
        const Position(5, 4),
        const Position(5, 5),
        const Position(5, 6),
      ]);
    });

    test('moves down', () {
      final snake = makeSnake(
        head: const Position(5, 5),
        direction: Direction.down,
      );
      final result = sim.step(makeState(snake: snake));

      final next = result.nextState!;
      expect(next.snake.head, const Position(5, 6));
      expect(next.snake.body, [
        const Position(5, 6),
        const Position(5, 5),
        const Position(5, 4),
      ]);
    });

    test('does not grow without food', () {
      final snake = makeSnake(length: 4);
      final result = sim.step(makeState(snake: snake));

      expect(result.nextState!.snake.length, 4);
    });

    test('tail cell is vacated after a move without food', () {
      final snake = makeSnake(
        head: const Position(5, 5),
        direction: Direction.right,
        length: 3,
      );
      final oldTail = snake.tail;
      final result = sim.step(makeState(snake: snake));

      expect(result.nextState!.snake.occupiesPosition(oldTail), isFalse);
    });

    test('successive steps keep advancing the snake', () {
      var state = makeState(
        snake: makeSnake(head: const Position(3, 5)),
      );
      for (var i = 0; i < 4; i++) {
        final result = sim.step(state);
        expect(result.crashed, isFalse);
        state = result.nextState!;
      }
      expect(state.snake.head, const Position(7, 5));
      expect(state.snake.length, 3);
    });
  });

  group('wall collisions (classic mode)', () {
    test('right wall: crashes with wallCollision at the out-of-bounds cell',
        () {
      final snake = makeSnake(
        head: const Position(19, 10),
        direction: Direction.right,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isTrue);
      expect(result.nextState, isNull);
      final crash = result.crashEvent!;
      expect(crash.reason, CrashReason.wallCollision);
      expect(crash.position, const Position(20, 10));
      expect(crash.collisionBodyPart, isNull);
      expect(crash.fatalSnake.head, const Position(20, 10));
    });

    test('left wall', () {
      final snake = makeSnake(
        head: const Position(0, 10),
        direction: Direction.left,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isTrue);
      final crash = result.crashEvent!;
      expect(crash.reason, CrashReason.wallCollision);
      expect(crash.position, const Position(-1, 10));
    });

    test('top wall', () {
      final snake = makeSnake(
        head: const Position(10, 0),
        direction: Direction.up,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isTrue);
      final crash = result.crashEvent!;
      expect(crash.reason, CrashReason.wallCollision);
      expect(crash.position, const Position(10, -1));
    });

    test('bottom wall', () {
      final snake = makeSnake(
        head: const Position(10, 19),
        direction: Direction.down,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isTrue);
      final crash = result.crashEvent!;
      expect(crash.reason, CrashReason.wallCollision);
      expect(crash.position, const Position(10, 20));
    });

    test('crash result carries exactly one event and a null nextState', () {
      final snake = makeSnake(
        head: const Position(19, 10),
        direction: Direction.right,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.events, hasLength(1));
      expect(result.events.single, isA<CrashEvent>());
      expect(result.nextState, isNull);
    });
  });

  group('zen mode wraps instead of crashing', () {
    test('right edge wraps to x = 0', () {
      final snake = makeSnake(
        head: const Position(19, 10),
        direction: Direction.right,
      );
      final result =
          sim.step(makeState(snake: snake, gameMode: GameMode.zen));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(0, 10));
    });

    test('left edge wraps to x = width - 1', () {
      final snake = makeSnake(
        head: const Position(0, 10),
        direction: Direction.left,
      );
      final result =
          sim.step(makeState(snake: snake, gameMode: GameMode.zen));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(19, 10));
    });

    test('top edge wraps to y = height - 1', () {
      final snake = makeSnake(
        head: const Position(10, 0),
        direction: Direction.up,
      );
      final result =
          sim.step(makeState(snake: snake, gameMode: GameMode.zen));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(10, 19));
    });

    test('bottom edge wraps to y = 0', () {
      final snake = makeSnake(
        head: const Position(10, 19),
        direction: Direction.down,
      );
      final result =
          sim.step(makeState(snake: snake, gameMode: GameMode.zen));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(10, 0));
    });
  });

  group('self collision', () {
    // U-shaped snake about to bite its own body:
    //   (4,5) head -> moving right into (5,5), which is body[3].
    List<Position> uShapeBody() => const [
          Position(4, 5), // head
          Position(4, 6),
          Position(5, 6),
          Position(5, 5), // collision target
          Position(6, 5),
        ];

    test('crashes with selfCollision and reports the hit body part', () {
      final snake = snakeFromBody(uShapeBody(), Direction.right);
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isTrue);
      final crash = result.crashEvent!;
      expect(crash.reason, CrashReason.selfCollision);
      expect(crash.position, const Position(5, 5));
      expect(crash.collisionBodyPart, const Position(5, 5));
    });

    test('moving into the just-vacated tail cell is safe', () {
      // Same shape minus the (6,5) segment: the target cell IS the tail,
      // which retracts on the same tick, so no collision.
      final snake = snakeFromBody(
        const [
          Position(4, 5),
          Position(4, 6),
          Position(5, 6),
          Position(5, 5), // tail
        ],
        Direction.right,
      );
      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(5, 5));
    });

    test('eating food on the tail cell kills (tail does not retract)', () {
      // Classic snake rule: growing into your own tail is fatal because the
      // tail stays put on an eating tick.
      final snake = snakeFromBody(
        const [
          Position(4, 5),
          Position(4, 6),
          Position(5, 6),
          Position(5, 5), // tail, and also the food cell
        ],
        Direction.right,
      );
      final result = sim.step(
        makeState(snake: snake, food: foodAt(const Position(5, 5))),
      );

      expect(result.crashed, isTrue);
      expect(result.crashEvent!.reason, CrashReason.selfCollision);
      // The crash preempts scoring: no FoodEatenEvent is emitted.
      expect(result.events.whereType<FoodEatenEvent>(), isEmpty);
    });
  });

  group('step() purity', () {
    test('does not mutate the input GameState', () {
      final snake = makeSnake(head: const Position(5, 5));
      final bodyBefore = List.of(snake.body);
      final food = foodAt(const Position(6, 5)); // will be eaten
      final extraFood = foodAt(const Position(0, 0));
      final powerUp = PowerUp(
        position: const Position(0, 19),
        type: PowerUpType.invincibility,
      );
      final active = ActivePowerUp(type: PowerUpType.scoreMultiplier);
      final foods = [extraFood];
      final activePowerUps = [active];

      final prev = makeState(
        snake: snake,
        food: food,
        foods: foods,
        powerUp: powerUp,
        activePowerUps: activePowerUps,
        score: 120,
        level: 2,
        currentCombo: 3,
        maxCombo: 6,
        comboIdleMs: 1000,
      );

      final result = sim.step(prev);
      expect(result.crashed, isFalse);

      // Snake untouched (step works on a copy).
      expect(prev.snake, same(snake));
      expect(prev.snake.body, bodyBefore);
      expect(prev.snake.currentDirection, Direction.right);

      // Scalar fields untouched.
      expect(prev.score, 120);
      expect(prev.level, 2);
      expect(prev.currentCombo, 3);
      expect(prev.maxCombo, 6);
      expect(prev.comboIdleMs, 1000);
      expect(prev.comboMultiplier, 1.0);

      // Object fields untouched (same instances, same contents).
      expect(prev.food, same(food));
      expect(prev.foods, same(foods));
      expect(prev.foods.single, same(extraFood));
      expect(prev.powerUp, same(powerUp));
      expect(prev.activePowerUps, same(activePowerUps));
      expect(prev.activePowerUps.single, same(active));
      expect(prev.visitedCells, isEmpty);

      // And the result is a distinct state object.
      expect(result.nextState, isNot(same(prev)));
    });
  });
}
