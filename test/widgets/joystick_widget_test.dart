import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/joystick_controls.dart';

import 'control_test_harness.dart';

/// The floating joystick as a widget: touch-down delivery like the other
/// steering controls, and the whole box as the touch zone.
void main() {
  Future<Rect> pump(
    WidgetTester tester,
    List<Direction> fired, {
    bool canSteer = true,
  }) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 320,
          child: SteerableJoystick(
            onDirection: fired.add,
            theme: GameTheme.classic,
            height: 130,
            canSteer: canSteer,
          ),
        ),
      ),
    );
    return tester.getRect(find.byType(FloatingJoystick));
  }

  testWidgets('a push steers with no clock advanced', (tester) async {
    final fired = <Direction>[];
    final r = await pump(tester, fired);

    final finger = await tester.startGesture(r.center);
    await finger.moveBy(const Offset(0, -40));
    expect(fired, [Direction.up]);
    await finger.up();
    await tester.pump();
  });

  testWidgets('landing anywhere in the box works — corners included', (
    tester,
  ) async {
    final fired = <Direction>[];
    final r = await pump(tester, fired);

    final finger = await tester.startGesture(r.topLeft + const Offset(8, 8));
    await finger.moveBy(const Offset(40, 0));
    expect(fired, [Direction.right]);
    await finger.up();
    await tester.pump();
  });

  testWidgets('a corner is two directions on one touch', (tester) async {
    final fired = <Direction>[];
    final r = await pump(tester, fired);

    final finger = await tester.startGesture(r.center);
    await finger.moveBy(const Offset(40, 0));
    await finger.moveBy(const Offset(0, -40));
    expect(fired, [Direction.right, Direction.up]);
    await finger.up();
    await tester.pump();
  });

  testWidgets('a tap without a push steers nothing', (tester) async {
    final fired = <Direction>[];
    final r = await pump(tester, fired);
    await tester.tapAt(r.center);
    expect(fired, isEmpty);
  });

  testWidgets('the knob appears under the thumb and goes on lift', (
    tester,
  ) async {
    final fired = <Direction>[];
    final r = await pump(tester, fired);

    final finger = await tester.startGesture(r.center);
    await tester.pump();
    // Idle hint is replaced by the stick while a thumb is down.
    expect(find.text('PUSH TO STEER'), findsNothing);
    await finger.up();
    await tester.pump();
    expect(find.text('PUSH TO STEER'), findsOneWidget);
  });

  testWidgets('a control that cannot steer takes no pushes', (tester) async {
    final fired = <Direction>[];
    final r = await pump(tester, fired, canSteer: false);
    final finger = await tester.startGesture(r.center);
    await finger.moveBy(const Offset(0, -40));
    expect(fired, isEmpty);
    await finger.up();
    await tester.pump();
  });
}
