import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';

import 'control_test_harness.dart';

/// The d-pad must steer the instant a finger lands.
///
/// It used to be a GestureDetector with both tap and pan handlers. When two
/// recognisers compete for a pointer, Flutter withholds the tap's down
/// callback until the arena settles — for a stationary press that is the
/// 100ms press timeout, or the finger lifting. Every d-pad press therefore
/// reached the game up to 100ms late, on top of the tick it then had to
/// wait for. These tests hold the control to touch-down delivery: nothing
/// here advances the clock between the press and the assertion.
void main() {
  const size = 140.0;

  Future<Rect> pumpPad(
    WidgetTester tester,
    List<Direction> fired,
  ) async {
    await tester.pumpWidget(
      harness(
        DPadControls(
          onDirection: fired.add,
          theme: GameTheme.classic,
          size: size,
        ),
      ),
    );
    return tester.getRect(find.byType(DPadControls));
  }

  Offset upArm(Rect r) => Offset(r.center.dx, r.top + size * 0.15);
  Offset rightArm(Rect r) => Offset(r.right - size * 0.15, r.center.dy);
  Offset downArm(Rect r) => Offset(r.center.dx, r.bottom - size * 0.15);

  testWidgets('a press steers on touch-down, before any time passes', (
    tester,
  ) async {
    final fired = <Direction>[];
    final r = await pumpPad(tester, fired);

    final finger = await tester.startGesture(upArm(r));
    // Finger still down, no pump, no timers run.
    expect(fired, [Direction.up], reason: 'delivered on the down event');

    await finger.up();
    await tester.pump();
  });

  testWidgets('sliding to another arm fires the second turn immediately', (
    tester,
  ) async {
    final fired = <Direction>[];
    final r = await pumpPad(tester, fired);

    final finger = await tester.startGesture(upArm(r));
    await finger.moveTo(rightArm(r));
    expect(fired, [Direction.up, Direction.right]);

    await finger.up();
    await tester.pump();
  });

  testWidgets('holding still, or jittering inside one arm, fires once', (
    tester,
  ) async {
    final fired = <Direction>[];
    final r = await pumpPad(tester, fired);

    final finger = await tester.startGesture(upArm(r));
    await finger.moveBy(const Offset(3, 2));
    await finger.moveBy(const Offset(-4, 1));
    expect(fired, [Direction.up]);

    await finger.up();
    await tester.pump();
  });

  testWidgets('lifting and re-pressing the same arm counts again', (
    tester,
  ) async {
    final fired = <Direction>[];
    final r = await pumpPad(tester, fired);

    await tester.tapAt(upArm(r));
    await tester.tapAt(upArm(r));
    expect(fired, [Direction.up, Direction.up]);
  });

  testWidgets('the dead centre is not a direction', (tester) async {
    final fired = <Direction>[];
    final r = await pumpPad(tester, fired);

    await tester.tapAt(r.center);
    expect(fired, isEmpty);
  });

  testWidgets('a second finger takes over; the first lifting changes nothing',
      (tester) async {
    final fired = <Direction>[];
    final r = await pumpPad(tester, fired);

    final thumb = await tester.startGesture(upArm(r), pointer: 1);
    final finger = await tester.startGesture(downArm(r), pointer: 2);
    expect(fired, [Direction.up, Direction.down]);

    // The first finger is no longer steering — its release must not end the
    // second finger's gesture, and its movement must not fire turns.
    await thumb.moveTo(rightArm(r));
    await thumb.up();
    expect(fired, [Direction.up, Direction.down]);

    // The live finger still slides through normally.
    await finger.moveTo(rightArm(r));
    expect(fired, [Direction.up, Direction.down, Direction.right]);

    await finger.up();
    await tester.pump();
  });
}
