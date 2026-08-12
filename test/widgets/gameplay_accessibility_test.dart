import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';
import 'package:snake_classic/widgets/game_bottom_bar.dart';
import 'package:snake_classic/widgets/game_hud.dart';
import 'package:snake_classic/widgets/steerable_dpad.dart';

import 'control_test_harness.dart';

/// The controls as assistive tech and large fingers meet them.
///
/// Every gameplay control was a bare GestureDetector: no label, no button
/// role, and hit targets of 36–42dp in the HUD and about 34dp for the
/// multiplayer exit. The D-pad was worse than unlabelled — its input is
/// "where inside this square did you touch", which cannot be performed
/// without sight at all.
void main() {
  Future<void> pumpHud(
    WidgetTester tester, {
    GameStatus status = GameStatus.playing,
    bool isSmallScreen = false,
    double textScale = 1.0,
    Size size = const Size(360, 640),
    VoidCallback? onHome,
    VoidCallback? onPause,
  }) async {
    await useScreen(tester, size);
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: size.width,
          child: GameHUD(
            gameState: playingState(status: status),
            theme: GameTheme.classic,
            onPause: onPause ?? () {},
            onHome: onHome ?? () {},
            isSmallScreen: isSmallScreen,
          ),
        ),
        size: size,
        textScale: textScale,
      ),
    );
  }

  group('HUD controls announce themselves', () {
    testWidgets('home and pause are labelled buttons', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHud(tester);

      expect(find.bySemanticsLabel('Go to home screen'), findsOneWidget);
      expect(find.bySemanticsLabel('Pause game'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('the pause control renames itself when the game is paused', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpHud(tester, status: GameStatus.paused);

      expect(find.bySemanticsLabel('Resume game'), findsOneWidget);
      expect(find.bySemanticsLabel('Pause game'), findsNothing);

      handle.dispose();
    });

    testWidgets('activating the labelled control runs the callback', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var paused = 0;
      await pumpHud(tester, onPause: () => paused++);

      await tester.tap(find.bySemanticsLabel('Pause game'));
      await tester.pump();

      expect(paused, 1);
      handle.dispose();
    });
  });

  group('HUD controls are big enough to hit', () {
    for (final small in [false, true]) {
      testWidgets('${small ? "compact" : "regular"} HUD keeps 48dp targets', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpHud(tester, isSmallScreen: small);

        for (final label in ['Go to home screen', 'Pause game']) {
          final size = tester.getSize(find.bySemanticsLabel(label));
          expect(
            size.width,
            greaterThanOrEqualTo(48.0),
            reason: '$label width on a ${small ? "short" : "tall"} screen',
          );
          expect(size.height, greaterThanOrEqualTo(48.0), reason: label);
        }

        handle.dispose();
      });
    }
  });

  group('the d-pad can be used without aiming', () {
    testWidgets('each arm is a labelled button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        harness(
          SteerableDPad(
            onDirection: (_) {},
            theme: GameTheme.classic,
            size: 140,
            canSteer: true,
          ),
        ),
      );

      for (final label in [
        'Steer up',
        'Steer down',
        'Steer left',
        'Steer right',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
      expect(find.bySemanticsLabel('Directional pad'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('activating an arm steers, without a pointer', (tester) async {
      final handle = tester.ensureSemantics();
      final steered = <Direction>[];
      await tester.pumpWidget(
        harness(
          SteerableDPad(
            onDirection: steered.add,
            theme: GameTheme.classic,
            size: 140,
            canSteer: true,
          ),
        ),
      );

      for (final label in ['Steer up', 'Steer right']) {
        await tester.tap(find.bySemanticsLabel(label));
        await tester.pump();
      }

      expect(steered, [Direction.up, Direction.right]);
      handle.dispose();
    });

    testWidgets('the quadrant layer is not announced as its own control', (
      tester,
    ) async {
      // Otherwise a screen reader offers an unlabelled tappable square whose
      // meaning depends on where you touched it — which is no control at all.
      await tester.pumpWidget(
        harness(
          DPadControls(
            onDirection: (_) {},
            theme: GameTheme.classic,
            size: 140,
          ),
        ),
      );

      final gestureLayer = tester.widget<GestureDetector>(
        find
            .descendant(
              of: find.byType(DPadControls),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      expect(gestureLayer.excludeFromSemantics, isTrue);
    });
  });

  group('nothing overflows across the device matrix', () {
    const screens = <String, Size>{
      'small phone': Size(320, 568),
      'common phone': Size(360, 640),
      'tall phone': Size(393, 852),
      'tablet portrait': Size(834, 1112),
    };

    for (final entry in screens.entries) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('${entry.key} at text scale $scale', (tester) async {
          await useScreen(tester, entry.value);
          await tester.pumpWidget(
            harness(
              SizedBox(
                width: entry.value.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameHUD(
                      gameState: playingState(length: 12),
                      theme: GameTheme.classic,
                      onPause: () {},
                      onHome: () {},
                      isSmallScreen: entry.value.height < 700,
                    ),
                    GameBottomBar(
                      gameState: playingState(length: 12),
                      theme: GameTheme.classic,
                      isSmallScreen: entry.value.height < 700,
                      dPadEnabled: true,
                      dPadPosition: DPadPosition.bottomLeft,
                      onDirection: (_) {},
                    ),
                  ],
                ),
              ),
              size: entry.value,
              textScale: scale,
            ),
          );

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a long locale does not overflow the compact bar', (
      tester,
    ) async {
      // German-length labels are not available, but Russian is the longest
      // shipped locale for these strings and the compact bar is the tightest
      // place they land.
      await useScreen(tester, const Size(320, 568));
      await tester.pumpWidget(
        harness(
          SizedBox(
            width: 320,
            child: GameBottomBar(
              gameState: playingState(length: 12),
              theme: GameTheme.classic,
              isSmallScreen: true,
              dPadEnabled: true,
              onDirection: (_) {},
            ),
          ),
          size: const Size(320, 568),
          textScale: 1.3,
          locale: const Locale('ru'),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
