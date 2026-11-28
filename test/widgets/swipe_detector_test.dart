import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';

import 'control_test_harness.dart';

/// What may and may not become a turn.
///
/// The gesture policy itself — a distance threshold (14 dp on Normal since
/// 8.3, set by the player's swipe sensitivity), a 1.3 directional-ratio gate
/// mid-drag, a velocity fallback for flicks with no ratio gate, and multiple
/// turns within one drag — is deliberate and unchanged. These tests pin it so
/// the next person to touch the recognizer finds out immediately, and cover
/// the two things that did change: a cancelled drag no longer poisons the
/// next one, and a tap with nobody listening no longer buzzes.
void main() {
  late List<Direction> swipes;

  Future<void> pumpDetector(
    WidgetTester tester, {
    VoidCallback? onTap,
    Widget? child,
    SwipeSensitivity? sensitivity,
  }) async {
    swipes = [];
    await tester.pumpWidget(
      harness(
        SwipeDetector(
          // Fresh state per pump: the spam guards read the wall clock.
          key: UniqueKey(),
          onSwipe: swipes.add,
          onTap: onTap,
          sensitivity: sensitivity,
          child:
              child ??
              Container(width: 300, height: 300, color: const Color(0xFF000000)),
        ),
      ),
    );
  }

  group('threshold', () {
    testWidgets('a drag shorter than the threshold is not a turn', (
      tester,
    ) async {
      await pumpDetector(tester);
      final centre = tester.getCenter(find.byType(SwipeDetector));

      final gesture = await tester.startGesture(centre);
      await gesture.moveBy(const Offset(10, 0));
      await gesture.up();
      await tester.pump();

      expect(swipes, isEmpty);
    });

    testWidgets('a drag past it is', (tester) async {
      await pumpDetector(tester);
      final centre = tester.getCenter(find.byType(SwipeDetector));

      final gesture = await tester.startGesture(centre);
      await gesture.moveBy(const Offset(40, 0));
      await gesture.up();
      await tester.pump();

      expect(swipes, [Direction.right]);
    });
  });

  group('diagonals', () {
    testWidgets('an ambiguous diagonal drag turns nowhere', (tester) async {
      // 40/40 is exactly on the diagonal: neither axis clears 1.3x the
      // other, and guessing here caused genuine misfires.
      await pumpDetector(tester);
      final centre = tester.getCenter(find.byType(SwipeDetector));

      final gesture = await tester.startGesture(centre);
      await gesture.moveBy(const Offset(40, 40));
      await tester.pump();

      expect(swipes, isEmpty);
      await gesture.up();
    });

    testWidgets('a dominant axis still resolves', (tester) async {
      await pumpDetector(tester);
      final centre = tester.getCenter(find.byType(SwipeDetector));

      final gesture = await tester.startGesture(centre);
      await gesture.moveBy(const Offset(60, 10));
      await gesture.up();
      await tester.pump();

      expect(swipes, [Direction.right]);
    });
  });

  testWidgets('a flick too diagonal for the mid-drag gate resolves on release', (
    tester,
  ) async {
    // The velocity fallback, and the one place the ratio gate is
    // deliberately absent. An exactly-diagonal drag is refused while the
    // finger is down — it may still resolve itself — but once the finger
    // lifts nothing further can disambiguate it, and dropping it silently is
    // what read to players as "the snake ignores me". The dominant axis wins,
    // ties going to horizontal.
    await pumpDetector(tester);
    final centre = tester.getCenter(find.byType(SwipeDetector));

    final gesture = await tester.startGesture(centre);
    for (var i = 1; i <= 5; i++) {
      await gesture.moveBy(
        const Offset(-4, -4),
        timeStamp: Duration(milliseconds: 4 * i),
      );
    }
    expect(swipes, isEmpty, reason: 'the ratio gate refuses it mid-drag');

    await gesture.up(timeStamp: const Duration(milliseconds: 24));
    await tester.pump();

    expect(swipes, [Direction.left]);
  });

  testWidgets('one drag can take two corners', (tester) async {
    await pumpDetector(tester);
    final centre = tester.getCenter(find.byType(SwipeDetector));

    final gesture = await tester.startGesture(centre);
    await gesture.moveBy(const Offset(0, -40));
    // Real elapsed time, not pumped time: the recognizer's spam guard reads
    // the wall clock, and two turns 50ms apart are two intended turns.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await gesture.moveBy(const Offset(40, 0));
    await gesture.up();
    await tester.pump();

    expect(swipes, [Direction.up, Direction.right]);
  });

  testWidgets('a cancelled drag does not lend its distance to the next one', (
    tester,
  ) async {
    // The accumulator used to survive a cancellation, so the following drag
    // started part-way to a threshold it had not earned.
    await pumpDetector(tester);
    final centre = tester.getCenter(find.byType(SwipeDetector));

    final cancelled = await tester.startGesture(centre);
    await cancelled.moveBy(const Offset(12, 0));
    await cancelled.cancel();
    await tester.pump();

    final next = await tester.startGesture(centre);
    await next.moveBy(const Offset(6, 0));
    await tester.pump();

    expect(swipes, isEmpty, reason: '18dp total, but only 6dp of this drag');
    await next.up();
  });

  group('taps', () {
    testWidgets('a tap with no listener produces no haptic', (tester) async {
      // Both gameplay screens pass onTap: null. This buzzed anyway, which
      // teaches the player that tapping the board does something.
      final haptics = HapticRecorder()..install();
      HapticService().setEnabled(true);
      await pumpDetector(tester);

      await tester.tap(find.byType(SwipeDetector));
      await tester.pump();

      expect(haptics.calls, isEmpty);
      expect(swipes, isEmpty);
    });

    testWidgets('a tap with a listener still fires it', (tester) async {
      var taps = 0;
      await pumpDetector(tester, onTap: () => taps++);

      await tester.tap(find.byType(SwipeDetector));
      await tester.pump();

      expect(taps, 1);
    });
  });

  group('scope', () {
    // The fix that matters: the detector wraps the board and nothing else.
    // It used to wrap the whole gameplay column, so a drag that began on the
    // HUD or the control strip steered the snake.
    Future<void> pumpGameplayColumn(WidgetTester tester) async {
      swipes = [];
      await tester.pumpWidget(
        harness(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const Key('hud'),
                width: 300,
                height: 80,
                color: const Color(0xFF222222),
              ),
              SwipeDetector(
                onSwipe: swipes.add,
                child: Container(
                  key: const Key('board'),
                  width: 300,
                  height: 300,
                  color: const Color(0xFF000000),
                ),
              ),
              Container(
                key: const Key('strip'),
                width: 300,
                height: 100,
                color: const Color(0xFF222222),
              ),
            ],
          ),
        ),
      );
    }

    Future<void> dragAcross(WidgetTester tester, Key key) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(key)),
      );
      await gesture.moveBy(const Offset(60, 0));
      await gesture.up();
      await tester.pump();
    }

    testWidgets('a drag on the board steers', (tester) async {
      await pumpGameplayColumn(tester);
      await dragAcross(tester, const Key('board'));

      expect(swipes, [Direction.right]);
    });

    testWidgets('a drag starting on the HUD does not', (tester) async {
      await pumpGameplayColumn(tester);
      await dragAcross(tester, const Key('hud'));

      expect(swipes, isEmpty);
    });

    testWidgets('nor one starting on the control strip', (tester) async {
      await pumpGameplayColumn(tester);
      await dragAcross(tester, const Key('strip'));

      expect(swipes, isEmpty);
    });

    testWidgets('nor a tap anywhere on the chrome', (tester) async {
      final haptics = HapticRecorder()..install();
      HapticService().setEnabled(true);
      await pumpGameplayColumn(tester);

      await tester.tap(find.byKey(const Key('hud')));
      await tester.tap(find.byKey(const Key('strip')));
      await tester.pump();

      expect(swipes, isEmpty);
      expect(haptics.calls, isEmpty);
    });

    testWidgets('an overlay covering the board blocks steering', (
      tester,
    ) async {
      // Reconnect overlays and dialogs sit above the board. They must
      // swallow the drag rather than let it through to the snake.
      swipes = [];
      await tester.pumpWidget(
        harness(
          Stack(
            children: [
              SwipeDetector(
                onSwipe: swipes.add,
                child: Container(
                  width: 300,
                  height: 300,
                  color: const Color(0xFF000000),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: const ColoredBox(color: Color(0x88000000)),
                ),
              ),
            ],
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SwipeDetector)),
      );
      await gesture.moveBy(const Offset(60, 0));
      await gesture.up();
      await tester.pump();

      expect(swipes, isEmpty);
    });
  });

  group('latency (8.3: raw pointer events, no pan slop)', () {
    testWidgets('the turn fires while the finger is still moving', (
      tester,
    ) async {
      // The old pan recognizer swallowed ~36 px of slop before it counted
      // anything, then needed the threshold on top: ~50 px of travel before a
      // turn. Now 16 px is enough on Normal, mid-drag, before any release.
      await pumpDetector(tester);
      final centre = tester.getCenter(find.byType(SwipeDetector));

      final gesture = await tester.startGesture(centre);
      await gesture.moveBy(const Offset(0, 8));
      await gesture.moveBy(const Offset(0, 8));
      await tester.pump();

      expect(swipes, [Direction.down], reason: 'fired before lift-off');
      await gesture.up();
      await tester.pump();
      expect(swipes, [Direction.down], reason: 'and only once');
    });

    testWidgets('a second finger takes over steering', (tester) async {
      await pumpDetector(tester);
      final centre = tester.getCenter(find.byType(SwipeDetector));

      final first = await tester.startGesture(centre, pointer: 1);
      final second = await tester.startGesture(
        centre + const Offset(0, 40),
        pointer: 2,
      );
      // The first finger's movement no longer steers...
      await first.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(swipes, isEmpty);
      // ...the newest one does.
      await second.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(swipes, [Direction.up]);
      await first.up();
      await second.up();
    });
  });

  group('swipe sensitivity', () {
    Future<List<Direction>> dragBy(
      WidgetTester tester,
      SwipeSensitivity sensitivity,
      double dx,
    ) async {
      await pumpDetector(tester, sensitivity: sensitivity);
      final centre = tester.getCenter(find.byType(SwipeDetector));
      final gesture = await tester.startGesture(centre);
      // Slow, so the release-velocity fallback can't rescue a short drag.
      for (var i = 0; i < 4; i++) {
        await gesture.moveBy(
          Offset(dx / 4, 0),
          timeStamp: Duration(milliseconds: 200 * (i + 1)),
        );
      }
      await gesture.up(timeStamp: const Duration(milliseconds: 2000));
      await tester.pump();
      return swipes;
    }

    testWidgets('high turns on a short drag that normal ignores', (
      tester,
    ) async {
      expect(await dragBy(tester, SwipeSensitivity.normal, 10), isEmpty);
      expect(await dragBy(tester, SwipeSensitivity.high, 10), [
        Direction.right,
      ]);
    });

    testWidgets('low ignores a drag that normal takes', (tester) async {
      expect(await dragBy(tester, SwipeSensitivity.normal, 18), [
        Direction.right,
      ]);
      expect(await dragBy(tester, SwipeSensitivity.low, 18), isEmpty);
    });

    testWidgets('every level still turns on a full swipe', (tester) async {
      for (final level in SwipeSensitivity.values) {
        expect(
          await dragBy(tester, level, 60),
          [Direction.right],
          reason: level.name,
        );
      }
    });
  });
}
