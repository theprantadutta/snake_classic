import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/session/pause_shift.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/premium_power_up.dart';

import '../engine/sim_test_utils.dart';

void main() {
  group('stampPausedAt (freeze)', () {
    test('freezes remaining time of active power-ups at the stamp', () {
      final activatedAt = DateTime.now().subtract(const Duration(seconds: 2));
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [
          ActivePowerUp(
            type: PowerUpType.speedBoost, // 7s duration
            activatedAt: activatedAt,
          ),
        ],
      );

      final stamp = DateTime.now();
      final frozen = stampPausedAt(state, stamp);

      final p = frozen.activePowerUps.single;
      expect(p.pausedAt, stamp);
      // remainingTime is computed against pausedAt, so it must not change
      // however long real time passes: 7s - 2s elapsed = ~5s, exactly.
      expect(
        p.remainingTime,
        stamp.difference(activatedAt) > Duration.zero
            ? const Duration(seconds: 7) - stamp.difference(activatedAt)
            : const Duration(seconds: 7),
      );
      expect(frozen.pausedAt, stamp);
    });

    test('stamps the on-board power-up without moving its creation time', () {
      final createdAt = DateTime.now().subtract(const Duration(seconds: 5));
      final state = makeState(
        snake: makeSnake(),
        powerUp: PowerUp(
          type: PowerUpType.invincibility,
          position: const Position(3, 3),
          createdAt: createdAt,
        ),
      );

      final stamp = DateTime.now();
      final frozen = stampPausedAt(state, stamp);

      expect(frozen.powerUp!.pausedAt, stamp);
      expect(frozen.powerUp!.createdAt, createdAt);
      expect(frozen.powerUp!.position, const Position(3, 3));
    });

    test('preserves premium power-up identity (regression: pause used to '
        'downgrade PremiumActivePowerUp to a plain ActivePowerUp)', () {
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [
          PremiumActivePowerUp(
            premiumType: PremiumPowerUpType.ghostMode,
            additionalData: const {'crashes_remaining': 2},
          ),
        ],
      );

      final frozen = stampPausedAt(state, DateTime.now());

      final p = frozen.activePowerUps.single;
      expect(p, isA<PremiumActivePowerUp>());
      expect(
        (p as PremiumActivePowerUp).premiumType,
        PremiumPowerUpType.ghostMode,
      );
      expect(p.additionalData['crashes_remaining'], 2);
      // The whole point: ghost mode survives the pause.
      expect(frozen.hasGhostMode, isTrue);
    });
  });

  group('shiftAfterPause (unfreeze)', () {
    test('freeze → shift round-trip keeps remaining time identical', () {
      final activatedAt = DateTime.now().subtract(const Duration(seconds: 3));
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [
          ActivePowerUp(
            type: PowerUpType.scoreMultiplier, // 10s duration
            activatedAt: activatedAt,
          ),
        ],
      );

      final stamp = DateTime.now();
      final frozen = stampPausedAt(state, stamp);

      // Simulate a 30s pause: anchors shift forward by exactly that window.
      const pause = Duration(seconds: 30);
      final resumed = shiftAfterPause(frozen, pause);

      final p = resumed.activePowerUps.single;
      expect(p.pausedAt, isNull, reason: 'getters must unfreeze');
      // The preservation invariant IS this anchor arithmetic: at resume,
      // real "now" has advanced by the pause window, and activatedAt
      // advanced by the same amount, so elapsed — and therefore remaining
      // time — is unchanged. (Asserting remainingTime directly would need
      // the wall clock to actually advance, which a unit test can't do.)
      expect(p.activatedAt, activatedAt.add(pause));
      expect(p.duration, const Duration(seconds: 10));
      expect(resumed.pausedAt, isNull);
    });

    test('shifts food creation so bonus/special do not expire over a pause',
        () {
      final createdAt = DateTime.now().subtract(const Duration(seconds: 8));
      final state = makeState(
        snake: makeSnake(),
        // Special food expires at 10s of age; an 8s-old one would die
        // during any pause >2s without the shift.
        food: foodAt(
          const Position(7, 7),
          type: FoodType.special,
          createdAt: createdAt,
        ),
        foods: [
          foodAt(
            const Position(8, 8),
            type: FoodType.bonus,
            createdAt: createdAt,
          ),
        ],
      );

      const pause = Duration(seconds: 60);
      final resumed = shiftAfterPause(state, pause);

      expect(resumed.food!.createdAt, createdAt.add(pause));
      expect(resumed.food!.isExpired, isFalse);
      expect(resumed.foods.single.createdAt, createdAt.add(pause));
      expect(resumed.foods.single.isExpired, isFalse);
    });

    test('shifts the on-board power-up and the game-start anchor', () {
      final createdAt = DateTime.now().subtract(const Duration(seconds: 4));
      final gameStart = DateTime.now().subtract(const Duration(minutes: 1));
      final state = makeState(snake: makeSnake())
          .copyWith(
            powerUp: PowerUp(
              type: PowerUpType.slowMotion,
              position: const Position(4, 4),
              createdAt: createdAt,
            ),
            gameStartTime: gameStart,
          );

      const pause = Duration(seconds: 15);
      final resumed = shiftAfterPause(state, pause);

      expect(resumed.powerUp!.createdAt, createdAt.add(pause));
      expect(resumed.powerUp!.pausedAt, isNull);
      expect(resumed.gameStartTime, gameStart.add(pause));
    });

    test('premium identity also survives the resume shift', () {
      final state = makeState(
        snake: makeSnake(),
        activePowerUps: [
          PremiumActivePowerUp(
            premiumType: PremiumPowerUpType.megaScoreMultiplier,
          ),
        ],
      );

      final resumed = shiftAfterPause(
        stampPausedAt(state, DateTime.now()),
        const Duration(seconds: 20),
      );

      final p = resumed.activePowerUps.single;
      expect(p, isA<PremiumActivePowerUp>());
      expect(resumed.scoreMultiplier, 2,
          reason: 'mega multiplier still doubles after a pause');
    });
  });
}
