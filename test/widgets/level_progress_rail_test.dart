import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/widgets/level_progress_rail.dart';

/// The level rail sits in the score panel, which sits directly above the play
/// area — so anything it does wrong either paints outside its box or costs a
/// frame on every tick of every run. Both are asserted here.
void main() {
  Future<void> pump(
    WidgetTester tester,
    double value, {
    double height = 10,
    double width = 200,
    TextDirection direction = TextDirection.ltr,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: direction,
        child: Center(
          child: SizedBox(
            width: width,
            child: LevelProgressRail(
              value: value,
              snakeColor: const Color(0xFF4CAF50),
              foodColor: const Color(0xFFE53935),
              trackColor: const Color(0xFF8BC34A),
              height: height,
            ),
          ),
        ),
      ),
    );
  }

  group('it paints', () {
    for (final value in const [0.0, 0.01, 0.25, 0.5, 0.79, 0.8, 0.999, 1.0]) {
      testWidgets('at $value', (tester) async {
        await pump(tester, value);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('out-of-range values are clamped, not thrown', (tester) async {
      await pump(tester, -3);
      expect(tester.takeException(), isNull);
      await pump(tester, 42);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a width with no room for a single cell', (
      tester,
    ) async {
      // Expanded inside a squeezed row can hand this almost nothing. It has to
      // draw the track and give up, not divide by a zero-width lane.
      await pump(tester, 0.5, width: 6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a hairline height', (tester) async {
      await pump(tester, 0.5, height: 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mirrors in RTL without complaint', (tester) async {
      await pump(tester, 0.6, direction: TextDirection.rtl);
      expect(tester.takeException(), isNull);
    });
  });

  group('it only animates when it means something', () {
    testWidgets('mid-level, nothing is ticking', (tester) async {
      // The claim this guards: the rail is a static repaint for the first 80%
      // of every level. If it ever starts free-running, it burns a frame on
      // every tick of every run for a bar that is not moving.
      await pump(tester, 0.5);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('near level-up, the head bobs', (tester) async {
      await pump(tester, LevelProgressRail.nearThreshold);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('crossing the threshold starts it, dropping back stops it', (
      tester,
    ) async {
      // A level-up resets progress to near zero. The ticker has to notice and
      // stand down, or it leaks a repeating animation for the rest of the run.
      await pump(tester, 0.5);
      expect(tester.hasRunningAnimations, isFalse);

      await pump(tester, 0.95);
      expect(tester.hasRunningAnimations, isTrue);

      await pump(tester, 0.02);
      expect(
        tester.hasRunningAnimations,
        isFalse,
        reason: 'the ticker must stop when the level rolls over',
      );
    });
  });

  testWidgets('it takes exactly the height it is given', (tester) async {
    // The score panel's height decides where the board starts. A rail that
    // measured taller than requested would push the play area down.
    await pump(tester, 0.5, height: 9, width: 180);
    expect(
      tester.getSize(find.byType(LevelProgressRail)),
      const Size(180, 9),
    );
  });
}
