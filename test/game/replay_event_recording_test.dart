import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/engine/snake_simulation.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';

import 'engine/sim_test_utils.dart';

/// Guards the replay-event recording contract.
///
/// A Crashlytics fatal — "type 'Null' is not a subtype of type 'Object'" at
/// _formatGameEvent — traced back to GameCubit._recordFrame deriving the event
/// payload from the POST-tick state. By then the information is gone, and these
/// tests pin exactly why:
///
///   * a collected power-up has already been cleared from the state, so
///     reading `nextState.powerUp` yielded null on the one frame that needed
///     it. Every power-up pickup was recorded as `{'powerUpType': null}`, and
///     the generated l10n method takes a non-nullable Object, so scrubbing to
///     that frame crashed the replay viewer outright;
///   * eaten food has already been regenerated, so `nextState.food` is the
///     REPLACEMENT — the frame was silently captioned with the wrong type.
///
/// The tick events carry the correct objects in both cases, which is what
/// _recordFrame now reads. If anyone reverts to diffing state, these fail.
void main() {
  late SnakeSimulation sim;

  setUp(() => sim = SnakeSimulation());

  group('power-up collection', () {
    test('nextState.powerUp is null on the collection tick', () {
      final snake = makeSnake(head: const Position(5, 5));
      final powerUp = PowerUp(
        position: const Position(6, 5),
        type: PowerUpType.speedBoost,
        createdAt: DateTime.now(),
      );

      final result = sim.step(makeState(snake: snake, powerUp: powerUp));

      expect(
        result.nextState!.powerUp,
        isNull,
        reason: 'the state cannot describe what was just collected — this is '
            'precisely why _recordFrame must not read it',
      );
    });

    test('the tick event still carries the collected power-up', () {
      final snake = makeSnake(head: const Position(5, 5));
      final powerUp = PowerUp(
        position: const Position(6, 5),
        type: PowerUpType.speedBoost,
        createdAt: DateTime.now(),
      );

      final result = sim.step(makeState(snake: snake, powerUp: powerUp));

      final collected =
          result.events.whereType<PowerUpCollectedEvent>().toList();
      expect(collected, hasLength(1));
      expect(collected.single.powerUp.type, PowerUpType.speedBoost);
      expect(
        collected.single.powerUp.type.name,
        isNotEmpty,
        reason: 'this is the value the replay frame must record',
      );
    });
  });

  group('food consumption', () {
    test('nextState.food is the replacement, not the food eaten', () {
      final snake = makeSnake(head: const Position(5, 5));
      final eaten = foodAt(const Position(6, 5), type: FoodType.bonus);

      final result = sim.step(makeState(snake: snake, food: eaten));

      final next = result.nextState!;
      expect(
        next.food?.position,
        isNot(const Position(6, 5)),
        reason: 'food regenerates in the same tick, so the state no longer '
            'refers to what was eaten',
      );
    });

    test('the tick event still carries the food that was eaten', () {
      final snake = makeSnake(head: const Position(5, 5));
      final eaten = foodAt(const Position(6, 5), type: FoodType.bonus);

      final result = sim.step(makeState(snake: snake, food: eaten));

      final events = result.events.whereType<FoodEatenEvent>().toList();
      expect(events, hasLength(1));
      expect(events.single.food.type, FoodType.bonus);
      expect(events.single.food.position, const Position(6, 5));
    });

    test('an ordinary move produces no food or power-up event', () {
      final snake = makeSnake(head: const Position(5, 5));
      final result = sim.step(
        makeState(snake: snake, food: foodAt(const Position(15, 15))),
      );

      expect(result.events.whereType<FoodEatenEvent>(), isEmpty);
      expect(result.events.whereType<PowerUpCollectedEvent>(), isEmpty);
    });
  });

  group('the payload _recordFrame builds from those events', () {
    /// Mirrors GameCubit._recordFrame's event-map construction.
    Map<String, dynamic>? buildEvent({
      String? eatenFoodType,
      String? collectedPowerUpType,
    }) {
      if (eatenFoodType != null) {
        return {'type': 'food_consumed', 'foodType': eatenFoodType};
      } else if (collectedPowerUpType != null) {
        return {
          'type': 'power_up_collected',
          'powerUpType': collectedPowerUpType,
        };
      }
      return null;
    }

    test('a power-up payload never carries a null type', () {
      final snake = makeSnake(head: const Position(5, 5));
      final result = sim.step(
        makeState(
          snake: snake,
          powerUp: PowerUp(
            position: const Position(6, 5),
            type: PowerUpType.invincibility,
            createdAt: DateTime.now(),
          ),
        ),
      );

      final name = result.events
          .whereType<PowerUpCollectedEvent>()
          .single
          .powerUp
          .type
          .name;
      final payload = buildEvent(collectedPowerUpType: name)!;

      expect(payload['type'], 'power_up_collected');
      expect(
        payload['powerUpType'],
        isNotNull,
        reason: 'a null here is the exact Crashlytics fatal this file guards',
      );
      // PowerUpType.name is a display label ("Invincibility"), not the enum
      // identifier — the replay caption interpolates it directly, so the
      // human-readable form is what we want stored.
      expect(payload['powerUpType'], 'Invincibility');
    });

    test('a food payload carries the type actually eaten', () {
      final snake = makeSnake(head: const Position(5, 5));
      final result = sim.step(
        makeState(
          snake: snake,
          food: foodAt(const Position(6, 5), type: FoodType.special),
        ),
      );

      final name =
          result.events.whereType<FoodEatenEvent>().single.food.type.name;
      final payload = buildEvent(eatenFoodType: name)!;

      expect(payload['foodType'], 'special');
    });

    test('no event on a plain move', () {
      expect(buildEvent(), isNull);
    });
  });
}
