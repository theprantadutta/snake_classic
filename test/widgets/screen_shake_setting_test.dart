import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/widgets/screen_shake.dart';

import 'control_test_harness.dart';

/// The motion setting, in both modes.
///
/// Single-player passed `screenShakeEnabled` through; multiplayer hard-coded
/// `applyShake: true`, so a player who had turned shake off because it makes
/// them ill got shaken by every multiplayer crash. Both screens now read the
/// same setting and feed it to the same two places — the widget that applies
/// the transform and the controller that runs the animation.
void main() {
  testWidgets('shake off means the board is never transformed', (tester) async {
    final controller = GameJuiceController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      harness(
        GameJuiceWidget(
          controller: controller,
          applyShake: false,
          child: const SizedBox(key: Key('board'), width: 200, height: 200),
        ),
      ),
    );
    final resting = tester.getCenter(find.byKey(const Key('board')));

    controller.wallHit();
    await tester.pump(const Duration(milliseconds: 60));

    expect(tester.getCenter(find.byKey(const Key('board'))), resting);
    expect(find.byType(ScreenShakeWidget), findsNothing);
  });

  testWidgets('shake on wraps the board in the shake transform', (
    tester,
  ) async {
    final controller = GameJuiceController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      harness(
        GameJuiceWidget(
          controller: controller,
          applyShake: true,
          child: const SizedBox(key: Key('board'), width: 200, height: 200),
        ),
      ),
    );

    expect(find.byType(ScreenShakeWidget), findsOneWidget);
  });

  test('a disabled controller does not start the animation either', () {
    // Belt and braces, and it is what keeps a disabled shake from burning
    // frames: the effect is refused at the source, not just dropped at the
    // widget. Both screens set this alongside applyShake.
    final controller = GameJuiceController();
    addTearDown(controller.dispose);

    controller.shakeEnabled = false;
    controller.wallHit();

    expect(controller.shakeController.isShaking, isFalse);

    controller.shakeEnabled = true;
    controller.wallHit();

    expect(controller.shakeController.isShaking, isTrue);
  });
}
