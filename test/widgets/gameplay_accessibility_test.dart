import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';
import 'package:snake_classic/widgets/game_bottom_bar.dart';
import 'package:snake_classic/widgets/game_circle_button.dart';
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

  /// Every chip the secondary row can hold, all at once.
  ///
  /// The row lays out its non-flex chips first — time, lives, food — and
  /// splits what is left between the level card and the power-ups card. The
  /// matrix below never built this state: playingState() has no time limit,
  /// no food and no power-ups, so the row always had room and the squeeze
  /// never appeared in a test.
  GameState crowdedState() => GameState(
        snake: Snake(
          body: [for (var i = 0; i < 3; i++) Position(4 - i, 10)],
          currentDirection: Direction.right,
        ),
        status: GameStatus.playing,
        gameMode: GameMode.timeAttack,
        food: Food(position: const Position(9, 9), type: FoodType.normal),
        activePowerUps: [
          ActivePowerUp(type: PowerUpType.speedBoost),
          ActivePowerUp(type: PowerUpType.scoreMultiplier),
        ],
        score: 240,
        level: 3,
      );

  group('the secondary row survives being full', () {
    // A 32px overflow, from the level card being squeezed to 7.8 logical
    // pixels and its "points in level" ratio wrapping to six lines inside a
    // row whose entire purpose is a fixed height.
    const screens = <String, Size>{
      'small phone': Size(320, 568),
      'common phone': Size(360, 640),
      'tall phone': Size(393, 852),
      'tablet portrait': Size(834, 1112),
    };

    for (final entry in screens.entries) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('${entry.key} at text scale $scale with every chip shown',
            (tester) async {
          await useScreen(tester, entry.value);
          await tester.pumpWidget(
            harness(
              SizedBox(
                width: entry.value.width,
                child: GameHUD(
                  gameState: crowdedState(),
                  theme: GameTheme.classic,
                  onPause: () {},
                  onHome: () {},
                  isSmallScreen: entry.value.width < 360,
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
  });

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

    testWidgets('each one exposes a tap action, not just a role', (
      tester,
    ) async {
      // `excludeSemantics` drops the GestureDetector's own tap action along
      // with everything else beneath it, so a label plus button: true and
      // nothing more describes a control a screen reader cannot press. Every
      // HUD button was in that state.
      final handle = tester.ensureSemantics();
      await pumpHud(tester);

      for (final label in ['Go to home screen', 'Pause game']) {
        final node = tester.getSemantics(find.bySemanticsLabel(label));
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
          reason: label,
        );
      }

      handle.dispose();
    });

    testWidgets('screen-reader activation presses home exactly once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var home = 0;
      await pumpHud(tester, onHome: () => home++);

      tester.semantics.tap(find.semantics.byLabel('Go to home screen'));
      await tester.pump();

      expect(home, 1);
      handle.dispose();
    });

    testWidgets('and pause exactly once', (tester) async {
      final handle = tester.ensureSemantics();
      var paused = 0;
      await pumpHud(tester, onPause: () => paused++);

      tester.semantics.tap(find.semantics.byLabel('Pause game'));
      await tester.pump();

      expect(paused, 1);
      handle.dispose();
    });

    testWidgets('resume too, once the game is paused', (tester) async {
      final handle = tester.ensureSemantics();
      var resumed = 0;
      await pumpHud(
        tester,
        status: GameStatus.paused,
        onPause: () => resumed++,
      );

      tester.semantics.tap(find.semantics.byLabel('Resume game'));
      await tester.pump();

      expect(resumed, 1);
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

  group('the multiplayer exit is labelled and hittable', () {
    testWidgets('48dp target with a leave label', (tester) async {
      // The one button that abandons a live match was a ~34dp unlabelled
      // target tucked in the corner of the versus header.
      final handle = tester.ensureSemantics();
      var left = 0;
      await tester.pumpWidget(
        harness(
          GameCircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => left++,
            theme: GameTheme.classic,
            semanticLabel: 'Leave match',
          ),
        ),
      );

      final size = tester.getSize(find.byType(GameCircleButton));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.bySemanticsLabel('Leave match'));
      await tester.pump();
      expect(left, 1);

      handle.dispose();
    });

    testWidgets('a screen reader can leave the match too', (tester) async {
      // Same defect as the HUD buttons, on the one control that abandons a
      // live match: announced as a button, with no action behind it.
      final handle = tester.ensureSemantics();
      var left = 0;
      await tester.pumpWidget(
        harness(
          GameCircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => left++,
            theme: GameTheme.classic,
            semanticLabel: 'Leave match',
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(GameCircleButton));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      tester.semantics.tap(find.semantics.byLabel('Leave match'));
      await tester.pump();

      expect(left, 1, reason: 'one activation, one exit');
      handle.dispose();
    });
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

      final handle = tester.ensureSemantics();
      final inPad = find.byType(DPadControls);

      // The pointer layer is a raw Listener, which contributes nothing to
      // the semantics tree — there is no GestureDetector left to exclude.
      expect(
        find.descendant(of: inPad, matching: find.byType(GestureDetector)),
        findsNothing,
      );
      expect(
        find.descendant(of: inPad, matching: find.byType(Listener)),
        findsOneWidget,
      );

      // What IS announced is exactly the four labelled arms.
      final announcedButtons = find.descendant(
        of: inPad,
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.button == true,
        ),
      );
      expect(announcedButtons, findsNWidgets(4));
      handle.dispose();
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
