import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/direction.dart';

/// Relative steering: "turn left" and "turn right" measured from the heading
/// the snake will have once its buffered turns apply.
///
/// The property that makes the two-button layout worth having is the last
/// group: a relative turn can never be a reversal, so the one input the
/// d-pad has to refuse cannot be produced here at all.
void main() {
  group('rotations on screen', () {
    // Screen coordinates: y grows downward, so "left" of up is left, and
    // left of right is up — a counter-clockwise quarter turn as the player
    // sees it.
    const left = {
      Direction.up: Direction.left,
      Direction.left: Direction.down,
      Direction.down: Direction.right,
      Direction.right: Direction.up,
    };
    const right = {
      Direction.up: Direction.right,
      Direction.right: Direction.down,
      Direction.down: Direction.left,
      Direction.left: Direction.up,
    };

    for (final heading in Direction.values) {
      test('turning left from $heading', () {
        expect(RelativeTurn.left.applyTo(heading), left[heading]);
        expect(heading.rotatedLeft, left[heading]);
      });
      test('turning right from $heading', () {
        expect(RelativeTurn.right.applyTo(heading), right[heading]);
        expect(heading.rotatedRight, right[heading]);
      });
      test('left then right from $heading is where you started', () {
        expect(heading.rotatedLeft.rotatedRight, heading);
      });
    }
  });

  Snake heading(Direction d) => Snake.fromPositions(
        const [Position(10, 10), Position(9, 10), Position(8, 10)],
        d,
      );

  group('through the snake', () {
    test('one press turns off the current heading', () {
      final snake = heading(Direction.right);
      final target = RelativeTurn.left.applyTo(snake.plannedDirection);
      expect(snake.changeDirection(target), isTrue);
      snake.move(ateFood: false);
      expect(snake.head, const Position(10, 9), reason: 'turned up');
    });

    test('two quick presses compose into a U-turn over two ticks', () {
      // Moving right. Left, left — inside one tick. The second press must be
      // measured from the heading the FIRST press produced (up), not from
      // the committed heading (right), or both presses say "up" and the
      // corner never happens.
      final snake = heading(Direction.right);
      expect(
        snake.changeDirection(RelativeTurn.left.applyTo(snake.plannedDirection)),
        isTrue,
      );
      expect(
        snake.changeDirection(RelativeTurn.left.applyTo(snake.plannedDirection)),
        isTrue,
      );
      snake.move(ateFood: false);
      expect(snake.head, const Position(10, 9), reason: 'up first');
      snake.move(ateFood: false);
      expect(snake.head, const Position(9, 9), reason: 'then left');
    });
  });

  group('a relative turn is never refused', () {
    for (final d in Direction.values) {
      for (final turn in RelativeTurn.values) {
        test('$turn from a snake heading $d', () {
          final snake = heading(d);
          expect(
            snake.changeDirection(turn.applyTo(snake.plannedDirection)),
            isTrue,
          );
        });
      }
    }

    test('a third press inside one tick is refused, never misdirected', () {
      // The buffer holds two turns. Left, left, left inside one tick asks
      // for a 270-degree corner the snake cannot make before it moves: the
      // third target (down, off the pending left) would reverse the queued
      // up. It is refused with the usual denied cue — the honest answer —
      // and the two turns already accepted still happen, in order.
      final snake = heading(Direction.right);
      expect(
        snake.changeDirection(RelativeTurn.left.applyTo(snake.plannedDirection)),
        isTrue,
      );
      expect(
        snake.changeDirection(RelativeTurn.left.applyTo(snake.plannedDirection)),
        isTrue,
      );
      expect(
        snake.changeDirection(RelativeTurn.left.applyTo(snake.plannedDirection)),
        isFalse,
      );
      snake.move(ateFood: false);
      snake.move(ateFood: false);
      expect(snake.head, const Position(9, 9), reason: 'up, then left');
    });

    test('and across a long random session, only a full buffer refuses', () {
      // Any number of relative presses between ticks, in any order, on any
      // heading. The buffer holds two turns — including one carried over
      // from the previous tick — so a press CAN be refused, but only ever
      // because the buffer is full. Never because it was a reversal: with
      // room in the buffer, a relative press always lands.
      final random = Random(42);
      final snake = heading(Direction.right);
      var refusals = 0;
      for (var tick = 0; tick < 500; tick++) {
        final presses = random.nextInt(4);
        for (var i = 0; i < presses; i++) {
          final turn = random.nextBool() ? RelativeTurn.left : RelativeTurn.right;
          final roomBefore = snake.bufferedTurns < 2;
          final accepted =
              snake.changeDirection(turn.applyTo(snake.plannedDirection));
          if (!accepted) refusals++;
          expect(
            accepted || !roomBefore,
            isTrue,
            reason: 'tick $tick press $i ($turn) was refused with room in '
                'the buffer — that would be a reversal, which cannot happen',
          );
        }
        snake.move(ateFood: false);
      }
      // The session did exercise the full-buffer case, so the guard above
      // was actually tested rather than vacuously true.
      expect(refusals, greaterThan(0));
    });
  });
}
