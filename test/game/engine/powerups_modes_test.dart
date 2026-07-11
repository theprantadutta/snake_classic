import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/engine/snake_simulation.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/premium_power_up.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

import 'sim_test_utils.dart';

void main() {
  late SnakeSimulation sim;

  setUp(() {
    sim = SnakeSimulation();
  });

  group('power-up collection', () {
    test('collecting on the next head cell fires the event and activates it',
        () {
      final powerUp = PowerUp(
        position: const Position(6, 5),
        type: PowerUpType.invincibility,
      );
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        powerUp: powerUp,
      ));

      final event = result.events.whereType<PowerUpCollectedEvent>().single;
      expect(event.powerUp, same(powerUp));

      final next = result.nextState!;
      expect(next.powerUp, isNull, reason: 'board slot must be cleared');
      expect(next.activePowerUps, hasLength(1));
      expect(next.activePowerUps.single.type, PowerUpType.invincibility);
      expect(next.activePowerUps.single.isExpired, isFalse);
    });

    test('a power-up sitting on the current head cell is also collected', () {
      final powerUp = PowerUp(
        position: const Position(5, 5), // exactly under the head
        type: PowerUpType.slowMotion,
      );
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        powerUp: powerUp,
      ));

      expect(result.events.whereType<PowerUpCollectedEvent>(), hasLength(1));
      expect(result.nextState!.powerUp, isNull);
      expect(result.nextState!.activePowerUps.single.type,
          PowerUpType.slowMotion);
    });

    test('collection appends to already-active power-ups', () {
      final existing = ActivePowerUp(type: PowerUpType.scoreMultiplier);
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        powerUp: PowerUp(
          position: const Position(6, 5),
          type: PowerUpType.speedBoost,
        ),
        activePowerUps: [existing],
      ));

      final types =
          result.nextState!.activePowerUps.map((p) => p.type).toList();
      expect(types,
          [PowerUpType.scoreMultiplier, PowerUpType.speedBoost]);
    });

    test('a power-up elsewhere on the board is left in place', () {
      final powerUp = PowerUp(
        position: const Position(0, 0),
        type: PowerUpType.speedBoost,
      );
      final result = sim.step(makeState(
        snake: makeSnake(head: const Position(5, 5)),
        powerUp: powerUp,
      ));

      expect(result.events.whereType<PowerUpCollectedEvent>(), isEmpty);
      expect(result.nextState!.powerUp, same(powerUp));
      expect(result.nextState!.activePowerUps, isEmpty);
    });
  });

  group('power-up expiry', () {
    test('an uncollected board power-up expires after 20s and is cleared', () {
      final stale = PowerUp(
        position: const Position(0, 0),
        type: PowerUpType.speedBoost,
        createdAt: DateTime.now().subtract(const Duration(seconds: 25)),
      );
      final result = sim.step(makeState(
        snake: makeSnake(),
        powerUp: stale,
      ));

      expect(result.nextState!.powerUp, isNull);
      expect(result.events.whereType<PowerUpCollectedEvent>(), isEmpty);
      expect(result.nextState!.activePowerUps, isEmpty);
    });

    test('expired active power-ups are dropped, fresh ones kept', () {
      final expiredBoost = ActivePowerUp(
        type: PowerUpType.speedBoost, // 7s duration
        activatedAt: DateTime.now().subtract(const Duration(seconds: 8)),
      );
      final freshMultiplier = ActivePowerUp(type: PowerUpType.scoreMultiplier);
      final result = sim.step(makeState(
        snake: makeSnake(),
        activePowerUps: [expiredBoost, freshMultiplier],
      ));

      final actives = result.nextState!.activePowerUps;
      expect(actives, hasLength(1));
      expect(actives.single, same(freshMultiplier));
    });
  });

  group('gameSpeed', () {
    test('base speed is 300ms at level 1', () {
      expect(makeState(snake: makeSnake()).gameSpeed, 300);
    });

    test('speedBoost halves the tick length (0.5x)', () {
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [ActivePowerUp(type: PowerUpType.speedBoost)],
      );
      expect(state.gameSpeed, 150);
    });

    test('slowMotion stretches the tick length (1.5x)', () {
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [ActivePowerUp(type: PowerUpType.slowMotion)],
      );
      expect(state.gameSpeed, 450);
    });

    test('speedBoost and slowMotion stack multiplicatively', () {
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [
          ActivePowerUp(type: PowerUpType.speedBoost),
          ActivePowerUp(type: PowerUpType.slowMotion),
        ],
      );
      expect(state.gameSpeed, 225); // 300 * 0.5 * 1.5
    });

    test('an expired speed power-up has no effect', () {
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [
          ActivePowerUp(
            type: PowerUpType.speedBoost,
            activatedAt: DateTime.now().subtract(const Duration(seconds: 8)),
          ),
        ],
      );
      expect(state.gameSpeed, 300);
    });

    test('speed scales with level per mode', () {
      expect(makeState(snake: makeSnake(), level: 5).gameSpeed, 260);
      expect(
        makeState(
          snake: makeSnake(),
          level: 3,
          gameMode: GameMode.speedChallenge,
        ).gameSpeed,
        270,
      );
      expect(
        makeState(
          snake: makeSnake(),
          level: 5,
          gameMode: GameMode.timeAttack,
        ).gameSpeed,
        220,
      );
    });

    test('speed is clamped to a 50ms floor at very high levels', () {
      expect(makeState(snake: makeSnake(), level: 30).gameSpeed, 50);
    });
  });

  group('invincibility', () {
    test('prevents wall death: the snake wraps to the opposite edge', () {
      final result = sim.step(makeState(
        snake: makeSnake(
          head: const Position(19, 10),
          direction: Direction.right,
        ),
        activePowerUps: [ActivePowerUp(type: PowerUpType.invincibility)],
      ));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(0, 10));
    });

    test('prevents self-collision death', () {
      final snake = snakeFromBody(
        const [
          Position(4, 5),
          Position(4, 6),
          Position(5, 6),
          Position(5, 5), // the cell the head moves into
          Position(6, 5),
        ],
        Direction.right,
      );
      final result = sim.step(makeState(
        snake: snake,
        activePowerUps: [ActivePowerUp(type: PowerUpType.invincibility)],
      ));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(5, 5));
    });

    test('an expired invincibility does not protect', () {
      final result = sim.step(makeState(
        snake: makeSnake(
          head: const Position(19, 10),
          direction: Direction.right,
        ),
        activePowerUps: [
          ActivePowerUp(
            type: PowerUpType.invincibility, // 6s duration
            activatedAt: DateTime.now().subtract(const Duration(seconds: 7)),
          ),
        ],
      ));

      expect(result.crashed, isTrue);
      expect(result.crashEvent!.reason, CrashReason.wallCollision);
    });

    test('ghost mode (premium) also grants wall immunity', () {
      final result = sim.step(makeState(
        snake: makeSnake(
          head: const Position(19, 10),
          direction: Direction.right,
        ),
        activePowerUps: [
          PremiumActivePowerUp(premiumType: PremiumPowerUpType.ghostMode),
        ],
      ));

      expect(result.crashed, isFalse);
      expect(result.nextState!.snake.head, const Position(0, 10));
    });
  });

  group('perfect game (no-revisit) mode', () {
    test('stepping onto fresh cells is fine and visitedCells is snapshotted',
        () {
      final snake = makeSnake(head: const Position(5, 5));
      sim.reset(snakeBody: snake.body);

      final result = sim.step(
        makeState(snake: snake, gameMode: GameMode.perfectGame),
      );

      expect(result.crashed, isFalse);
      expect(result.nextState!.visitedCells, {
        const Position(3, 5),
        const Position(4, 5),
        const Position(5, 5),
        const Position(6, 5),
      });
    });

    test('re-entering a previously visited cell is fatal', () {
      final snake = makeSnake(head: const Position(5, 5));
      sim.reset(snakeBody: snake.body);
      // Simulate an old trail through the cell the head is about to enter.
      sim.visitedCells.add(const Position(6, 5));

      final result = sim.step(
        makeState(snake: snake, gameMode: GameMode.perfectGame),
      );

      expect(result.crashed, isTrue);
      expect(result.nextState, isNull);
      final crash = result.crashEvent!;
      expect(crash.reason, CrashReason.selfCollision);
      expect(crash.position, const Position(6, 5));
      expect(crash.collisionBodyPart, isNull,
          reason: 'a trail-cross has no live body part');
    });

    test('immunity bypasses the no-revisit rule', () {
      final snake = makeSnake(head: const Position(5, 5));
      sim.reset(snakeBody: snake.body);
      sim.visitedCells.add(const Position(6, 5));

      final result = sim.step(makeState(
        snake: snake,
        gameMode: GameMode.perfectGame,
        activePowerUps: [ActivePowerUp(type: PowerUpType.invincibility)],
      ));

      expect(result.crashed, isFalse);
    });

    test('visited cells are not enforced (or snapshotted) in other modes', () {
      final snake = makeSnake(head: const Position(5, 5));
      sim.reset(snakeBody: snake.body);
      sim.visitedCells.add(const Position(6, 5));

      final result = sim.step(makeState(snake: snake));

      expect(result.crashed, isFalse);
      expect(result.nextState!.visitedCells, isEmpty);
    });

    test('reset() clears the trail and seeds it with the new body', () {
      sim.visitedCells.addAll(const [Position(1, 1), Position(2, 2)]);

      sim.reset(snakeBody: const [Position(5, 5), Position(4, 5)]);

      expect(sim.visitedCells, {
        const Position(5, 5),
        const Position(4, 5),
      });
    });

    test('isPro is sticky across resets that omit it', () {
      sim.reset(snakeBody: const [Position(5, 5)], isPro: true);
      sim.reset(snakeBody: const [Position(6, 5)]);

      expect(sim.isPro, isTrue);
    });
  });

  group('trySpawnPowerUp', () {
    test('spawned power-ups avoid the snake and all food positions', () {
      final snake = makeSnake();
      final state = makeState(
        snake: snake,
        food: foodAt(const Position(0, 0)),
        foods: [foodAt(const Position(0, 19)), foodAt(const Position(19, 0))],
        gameMode: GameMode.powerUpMadness, // 0.9 spawn chance
      );

      var spawned = 0;
      for (var i = 0; i < 60; i++) {
        final powerUp = sim.trySpawnPowerUp(state);
        if (powerUp == null) continue;
        spawned++;
        expect(snake.occupiesPosition(powerUp.position), isFalse);
        expect(powerUp.position, isNot(const Position(0, 0)));
        expect(powerUp.position, isNot(const Position(0, 19)));
        expect(powerUp.position, isNot(const Position(19, 0)));
        expect(powerUp.position.isWithinBounds(20, 20), isTrue);
      }
      // With a 0.9 spawn chance, 60 straight failures are impossible in
      // practice (p ~= 1e-60).
      expect(spawned, greaterThan(0));
    });
  });

  group('premium power-up effect mapping (regression: ghost-as-speed-boost)',
      () {
    GameState withPremium(PremiumPowerUpType type) => makeState(
          snake: makeSnake(),
          activePowerUps: [PremiumActivePowerUp(premiumType: type)],
        );

    test('ghost mode grants NO speed change (used to halve the tick)', () {
      final state = withPremium(PremiumPowerUpType.ghostMode);
      expect(state.gameSpeed, 300);
      expect(state.hasSpeedBoost, isFalse);
      expect(state.hasSlowMotion, isFalse);
      // Its real effect — phasing — is untouched.
      expect(state.hasGhostMode, isTrue);
    });

    test('no-analog premium types grant no basic effects at all', () {
      const noAnalog = [
        PremiumPowerUpType.teleport,
        PremiumPowerUpType.sizeReducer,
        PremiumPowerUpType.scoreShield,
        PremiumPowerUpType.comboMultiplier,
        PremiumPowerUpType.magneticFood,
        PremiumPowerUpType.doubleTrouble,
        PremiumPowerUpType.luckyCharm,
        PremiumPowerUpType.powerSurge,
      ];
      for (final type in noAnalog) {
        final state = withPremium(type);
        expect(state.gameSpeed, 300, reason: '$type must not change speed');
        expect(state.hasInvincibility, isFalse, reason: '$type');
        expect(state.scoreMultiplier, 1, reason: '$type');
      }
    });

    test('mega variants still grant their basic effects', () {
      expect(withPremium(PremiumPowerUpType.megaSpeedBoost).gameSpeed, 150);
      expect(withPremium(PremiumPowerUpType.megaSlowMotion).gameSpeed, 450);
      expect(
        withPremium(PremiumPowerUpType.megaInvincibility).hasInvincibility,
        isTrue,
      );
      expect(
        withPremium(PremiumPowerUpType.megaScoreMultiplier).scoreMultiplier,
        2,
      );
    });

    test('time warp behaves as slow motion (used to be a SPEED boost)', () {
      final state = withPremium(PremiumPowerUpType.timeWarp);
      expect(state.gameSpeed, 450);
      expect(state.hasSlowMotion, isTrue);
    });
  });
}
