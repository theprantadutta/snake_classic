import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/walkthrough/game_tutorial.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_step.dart';

import '../widgets/control_test_harness.dart';

/// The optional tutorial: getting into it, getting out of it exactly once,
/// and completing it with whichever control the player actually uses.
void main() {
  List<WalkthroughStep> steps() => const [
    WalkthroughStep(id: 'tutorial_welcome', title: 'w', message: 'm'),
    WalkthroughStep(
      id: 'tutorial_practice_right',
      title: 'r',
      message: 'm',
      isInteractive: true,
    ),
    WalkthroughStep(
      id: 'tutorial_practice_up',
      title: 'u',
      message: 'm',
      isInteractive: true,
    ),
    WalkthroughStep(id: 'tutorial_complete', title: 'c', message: 'm'),
  ];

  GameTutorialController controllerAt(int step) {
    final controller = GameTutorialController()..updateSteps(steps());
    controller.start();
    for (var i = 0; i < step; i++) {
      if (controller.awaitingInput) {
        controller.onSwipeDetected(controller.expectedDirection!);
      } else {
        controller.advance();
      }
    }
    return controller;
  }

  group('Settings can actually start it', () {
    test('the replay route carries the request', () {
      // The old implementation reset a stored flag and navigated to /game,
      // where nothing read the flag — so the player who explicitly asked to
      // be taught got an ordinary run. The intent rides on the route now.
      expect(AppRoutes.wantsTutorial(Uri.parse(AppRoutes.gameWithTutorial)),
          isTrue);
    });

    test('an ordinary game route does not', () {
      expect(AppRoutes.wantsTutorial(Uri.parse(AppRoutes.game)), isFalse);
      expect(
        AppRoutes.wantsTutorial(Uri.parse('/game?tutorial=0')),
        isFalse,
      );
      expect(
        AppRoutes.wantsTutorial(Uri.parse('/game?something=1')),
        isFalse,
      );
    });

    test('it points at the game screen, not somewhere else', () {
      expect(Uri.parse(AppRoutes.gameWithTutorial).path, AppRoutes.game);
    });
  });

  group('it ends exactly once', () {
    test('finishing the last step reports finished, once', () {
      final endings = <TutorialOutcome>[];
      final controller = controllerAt(3)..onFinished = endings.add;

      controller.advance();

      expect(endings, [TutorialOutcome.finished]);
    });

    test('skipping reports skipped, once', () {
      final endings = <TutorialOutcome>[];
      final controller = controllerAt(0)..onFinished = endings.add;

      controller.skip();

      expect(endings, [TutorialOutcome.skipped]);
    });

    test('skip followed by complete does not end it twice', () {
      // THE bug. The overlay called controller.skip(), whose callback already
      // ran the screen's completion handler, and then called onSkip which ran
      // it again: two resumes, two writes of the completion flag, and a
      // setState against a controller the first pass had disposed.
      final endings = <TutorialOutcome>[];
      final controller = controllerAt(0)..onFinished = endings.add;

      controller.skip();
      controller.complete();
      controller.skip();

      expect(endings, [TutorialOutcome.skipped]);
    });

    test('the first ending wins', () {
      final endings = <TutorialOutcome>[];
      final controller = controllerAt(3)..onFinished = endings.add;

      controller.advance();
      controller.skip();

      expect(endings, [TutorialOutcome.finished]);
    });

    test('advancing past the end cannot re-fire it', () {
      final endings = <TutorialOutcome>[];
      final controller = controllerAt(3)..onFinished = endings.add;

      controller.advance();
      controller.advance();
      controller.advance();

      expect(endings, hasLength(1));
    });
  });

  group('any control can complete it', () {
    // The controller takes a Direction and does not care where it came from.
    // That is the fix: the board's swipe detector, the D-pad and the arrow
    // keys all call the screen's one direction handler, which routes here.
    test('the practice steps expect the direction they name', () {
      final controller = controllerAt(1);
      expect(controller.expectedDirection, Direction.right);

      controller.onSwipeDetected(Direction.right);
      expect(controller.expectedDirection, Direction.up);
    });

    test('a wrong direction does not advance it', () {
      final controller = controllerAt(1);

      controller.onSwipeDetected(Direction.left);

      expect(controller.currentStep, 1);
      expect(controller.expectedDirection, Direction.right);
    });

    test('a direction from anywhere advances it', () {
      // Three "sources" that are indistinguishable by construction — which is
      // exactly the property that makes swipe, D-pad and keyboard equivalent.
      for (final source in ['swipe', 'dpad', 'keyboard']) {
        final controller = controllerAt(1);

        final consumed = controller.onSwipeDetected(Direction.right);

        expect(consumed, isTrue, reason: source);
        expect(controller.currentStep, 2, reason: source);
      }
    });

    test('input outside a practice step is not consumed', () {
      // The game screen needs to know when to hand the direction to the
      // tutorial and when it is an ordinary turn.
      final controller = controllerAt(0);

      expect(controller.onSwipeDetected(Direction.right), isFalse);
    });
  });

  group('the practice overlay does not eat the controls', () {
    testWidgets('a widget underneath still receives the drag', (tester) async {
      // The overlay used to be one full-screen GestureDetector with its own
      // drag handlers, so it swallowed every touch before the board or the
      // D-pad could see it. A player with the D-pad enabled could press their
      // visible control and have nothing happen.
      final controller = GameTutorialController()..updateSteps(steps());
      controller.start();
      controller.advance();
      addTearDown(controller.dispose);
      expect(controller.awaitingInput, isTrue);

      var boardTouches = 0;
      await tester.pumpWidget(
        harness(
          Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (_) => boardTouches++,
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned.fill(
                child: GameTutorialOverlay(
                  controller: controller,
                  theme: GameTheme.classic,
                ),
              ),
            ],
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 500));
      await gesture.moveBy(const Offset(60, 0));
      await gesture.up();
      await tester.pump();

      expect(boardTouches, greaterThan(0));
    });

    testWidgets('but its own skip button still works', (tester) async {
      final controller = GameTutorialController()..updateSteps(steps());
      controller.start();
      controller.advance();
      addTearDown(controller.dispose);

      final endings = <TutorialOutcome>[];
      controller.onFinished = endings.add;

      await tester.pumpWidget(
        harness(
          GameTutorialOverlay(
            controller: controller,
            theme: GameTheme.classic,
          ),
        ),
      );

      await tester.tap(find.byType(TextButton).first);
      await tester.pump();

      expect(endings, [TutorialOutcome.skipped]);
    });
  });
}
