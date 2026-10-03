import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/widgets/lb/lb_game_hud.dart';

import 'control_test_harness.dart';

/// The gameplay HUD as assistive tech and large fingers meet it.
///
/// Every gameplay control was once a bare GestureDetector: no label, no
/// button role, and hit targets of 36–42 dp. The Living Board top bar draws
/// its pause block at two grid cells (40 dp) — these keep it a labelled,
/// pressable, 48 dp target anyway.
void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    GameStatus status = GameStatus.playing,
    double textScale = 1.0,
    Size size = const Size(360, 640),
    VoidCallback? onPause,
  }) async {
    await useScreen(tester, size);
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: size.width,
          child: LBGameTopBar(
            gameState: playingState(status: status),
            onPause: onPause ?? () {},
          ),
        ),
        size: size,
        textScale: textScale,
      ),
    );
  }

  group('the pause control announces itself', () {
    testWidgets('it is a labelled button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBar(tester);

      expect(find.bySemanticsLabel('Pause game'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('it renames itself when the game is paused', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBar(tester, status: GameStatus.paused);

      expect(find.bySemanticsLabel('Resume game'), findsOneWidget);
      expect(find.bySemanticsLabel('Pause game'), findsNothing);

      handle.dispose();
    });

    testWidgets('it exposes a tap action, not just a role', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBar(tester);

      final node = tester.getSemantics(find.bySemanticsLabel('Pause game'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      handle.dispose();
    });

    testWidgets('a finger tap pauses exactly once', (tester) async {
      var paused = 0;
      await pumpBar(tester, onPause: () => paused++);

      await tester.tap(find.bySemanticsLabel('Pause game'));
      await tester.pump();

      expect(paused, 1);
    });

    testWidgets('screen-reader activation pauses exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      var paused = 0;
      await pumpBar(tester, onPause: () => paused++);

      tester.semantics.tap(find.semantics.byLabel('Pause game'));
      await tester.pump();

      expect(paused, 1);
      handle.dispose();
    });

    testWidgets('and resumes exactly once when paused', (tester) async {
      final handle = tester.ensureSemantics();
      var resumed = 0;
      await pumpBar(tester, status: GameStatus.paused, onPause: () => resumed++);

      tester.semantics.tap(find.semantics.byLabel('Resume game'));
      await tester.pump();

      expect(resumed, 1);
      handle.dispose();
    });
  });

  testWidgets('the pause target is at least 48 dp though it draws at 40', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBar(tester);

    final size = tester.getSize(find.bySemanticsLabel('Pause game'));
    expect(size.width, greaterThanOrEqualTo(48.0));
    expect(size.height, greaterThanOrEqualTo(48.0));

    handle.dispose();
  });

  group('the bar holds its shape', () {
    const screens = <String, Size>{
      'small phone': Size(320, 568),
      'common phone': Size(360, 640),
      'tall phone': Size(393, 852),
      'tablet portrait': Size(834, 1112),
    };
    for (final entry in screens.entries) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('${entry.key} at text scale $scale', (tester) async {
          await pumpBar(tester, size: entry.value, textScale: scale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
