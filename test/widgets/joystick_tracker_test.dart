import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/joystick_controls.dart';

/// The floating stick's mapping from thumb movement to four-way steering,
/// tested without a widget. Screen coordinates throughout: y grows downward.
void main() {
  JoystickTracker tracker() =>
      JoystickTracker(deadRadius: 12, sectorHalfAngle: 35);

  group('the centre is wherever the thumb lands', () {
    test('a push from an arbitrary landing point steers', () {
      final t = tracker()..begin(const Offset(200, 300));
      expect(t.update(const Offset(230, 300)), Direction.right);
    });

    test('and from a different landing point, the same push, the same answer',
        () {
      final t = tracker()..begin(const Offset(20, 40));
      expect(t.update(const Offset(50, 40)), Direction.right);
    });
  });

  group('dead radius', () {
    test('a resting thumb steers nothing', () {
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(105, 103)), isNull);
      expect(t.update(const Offset(100, 111)), isNull);
    });

    test('past the radius it does', () {
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(100, 113)), Direction.down);
    });
  });

  group('sector hysteresis', () {
    test('a clean push resolves to its axis', () {
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(100, 60)), Direction.up);
    });

    test('a push near the diagonal is neither direction', () {
      // 45 degrees exactly: nearest-axis maths would pick one arbitrarily
      // and a wobble would flip it. The dead band says: not yet committed.
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(130, 70)), isNull);
      // 40 degrees off the up axis, still outside the 35-degree sector.
      expect(t.update(const Offset(125, 70)), isNull);
    });

    test('leaning into the sector commits', () {
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(130, 70)), isNull, reason: 'diagonal');
      // 20 degrees off the up axis.
      expect(t.update(const Offset(111, 70)), Direction.up);
    });

    test('holding the same push does not repeat the direction', () {
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(140, 100)), Direction.right);
      expect(t.update(const Offset(180, 100)), isNull);
      expect(t.update(const Offset(181, 102)), isNull);
    });
  });

  group('re-centring', () {
    test('the next push is measured from where the thumb already is', () {
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(140, 100)), Direction.right);
      expect(t.origin, const Offset(140, 100), reason: 'centre moved');
      // From (140,100), 20px straight up — a small motion, not a return to
      // the original centre and then some.
      expect(t.update(const Offset(140, 80)), Direction.up);
    });

    test('a corner is two pushes without a lift', () {
      final t = tracker()..begin(const Offset(100, 100));
      final fired = <Direction>[];
      for (final p in const [
        Offset(120, 100),
        Offset(140, 100),
        Offset(140, 85),
        Offset(140, 60),
      ]) {
        final d = t.update(p);
        if (d != null) fired.add(d);
      }
      expect(fired, [Direction.right, Direction.up]);
    });
  });

  group('pulling back', () {
    test('is returning to centre, not the opposite direction', () {
      // The game would refuse the reversal anyway; buzzing the player for
      // un-pushing a stick would read as a bug.
      final t = tracker()..begin(const Offset(100, 100));
      expect(t.update(const Offset(140, 100)), Direction.right);
      expect(t.update(const Offset(100, 100)), isNull);
      expect(t.origin, const Offset(100, 100), reason: 'silently re-centred');
    });

    test('and after pulling back, a fresh push in a new direction works', () {
      final t = tracker()..begin(const Offset(100, 100));
      t.update(const Offset(140, 100));
      t.update(const Offset(100, 100));
      expect(t.update(const Offset(100, 70)), Direction.up);
    });
  });

  group('lifting', () {
    test('ends the touch; the next landing is a fresh centre', () {
      final t = tracker()..begin(const Offset(100, 100));
      t.update(const Offset(140, 100));
      t.end();
      expect(t.isActive, isFalse);
      expect(t.update(const Offset(500, 500)), isNull,
          reason: 'no centre, nothing to measure from');
      t.begin(const Offset(300, 300));
      expect(t.update(const Offset(300, 340)), Direction.down);
    });
  });
}
