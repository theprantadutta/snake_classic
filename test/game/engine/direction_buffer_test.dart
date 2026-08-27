import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/engine/snake_simulation.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/direction.dart';

import 'sim_test_utils.dart';

/// The input buffer, which had no tests at all.
///
/// `Snake.changeDirection` is what decides whether a swipe becomes a turn or
/// gets dropped on the floor, and it is the whole of "the snake missed my
/// input". It buffers two turns per tick: the first applies on the next move,
/// the second on the move after. Everything here asserts where the head
/// actually ends up rather than poking at the buffer's internals, because the
/// head is the only thing a player can see.
void main() {
  /// A snake at (5,5) travelling right, body trailing left behind it.
  Snake movingRight() => Snake.fromPositions(
        const [Position(5, 5), Position(4, 5), Position(3, 5)],
        Direction.right,
      );

  group('a single turn', () {
    test('applies on the next move', () {
      final snake = movingRight();
      expect(snake.changeDirection(Direction.up), isTrue);
      snake.move(ateFood: false);

      expect(snake.head, const Position(5, 4), reason: 'turned up');
    });

    test('a reversal into its own neck is refused', () {
      final snake = movingRight();
      expect(snake.changeDirection(Direction.left), isFalse);
      snake.move(ateFood: false);

      expect(snake.head, const Position(6, 5), reason: 'carried straight on');
    });
  });

  group('two turns inside one tick', () {
    test('both execute, in the order the player made them', () {
      // The sequence every player makes rounding a corner: up, then left,
      // faster than one tick. Both were accepted, so both must happen — and
      // the FIRST one must happen first.
      final snake = movingRight();
      expect(snake.changeDirection(Direction.up), isTrue);
      expect(snake.changeDirection(Direction.left), isTrue);

      snake.move(ateFood: false);
      expect(
        snake.head,
        const Position(5, 4),
        reason: 'the first turn is the one that moves first',
      );

      snake.move(ateFood: false);
      expect(
        snake.head,
        const Position(4, 4),
        reason: 'the second turn follows on the next tick',
      );
    });

    test('the first turn is never skipped into the body', () {
      // The failure this guards: if the second turn overwrites the first
      // before the move instead of after it, a right-moving snake told
      // "up, then left" moves LEFT immediately — straight back down its own
      // neck — and dies on a pair of inputs that were both accepted.
      final snake = movingRight();
      snake.changeDirection(Direction.up);
      snake.changeDirection(Direction.left);
      snake.move(ateFood: false);

      expect(
        snake.checkSelfCollision(),
        isFalse,
        reason: 'two legal turns must not kill the snake',
      );
    });
  });

  group('what the buffer refuses', () {
    test('a third turn in the same tick is rejected, not silently dropped', () {
      final snake = movingRight();
      expect(snake.changeDirection(Direction.up), isTrue);
      expect(snake.changeDirection(Direction.left), isTrue);

      // The caller uses this false to flash and buzz "denied" — the player
      // is told the input did not land rather than left wondering.
      expect(snake.changeDirection(Direction.down), isFalse);
    });

    test('repeating the current direction does not spend a slot', () {
      final snake = movingRight();
      expect(snake.changeDirection(Direction.up), isTrue);
      expect(snake.changeDirection(Direction.up), isTrue,
          reason: 'a no-op, accepted');
      expect(snake.changeDirection(Direction.left), isTrue,
          reason: 'the real turn still fits');
    });

    test('cannot reverse by chaining two perpendicular turns', () {
      // right → up → (next tick) → down would be a 180 in two hops. The
      // second slot validates against the turn ahead of it, so it cannot.
      final snake = movingRight();
      snake.changeDirection(Direction.up);
      expect(snake.changeDirection(Direction.down), isFalse);
    });

    test('after a tick commits, the buffer reopens', () {
      final snake = movingRight();
      snake.changeDirection(Direction.up);
      snake.changeDirection(Direction.left);
      snake.move(ateFood: false);

      expect(
        snake.changeDirection(Direction.down),
        isTrue,
        reason: 'a fresh tick accepts input again',
      );
    });
  });
  group('through the real simulation, not just the model', () {
    test('cornering with two quick swipes does not kill the snake', () {
      // The model test above proves the ordering. This proves the game loop
      // actually runs it that way — the engine calls snake.move() and then
      // checkSelfCollision(), so a skipped first turn is not a cosmetic
      // glitch: it is a crash the player did nothing to earn.
      final sim = SnakeSimulation();
      final snake = Snake.fromPositions(
        const [Position(5, 5), Position(4, 5), Position(3, 5)],
        Direction.right,
      );
      snake.changeDirection(Direction.up);
      snake.changeDirection(Direction.left);

      final result = sim.step(makeState(snake: snake));

      expect(
        result.crashed,
        isFalse,
        reason: 'up-then-left around a corner is a legal pair of turns',
      );
      expect(result.nextState!.snake.head, const Position(5, 4));
    });
  });
}
