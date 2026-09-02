import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/turn_buttons.dart';

import 'control_test_harness.dart';

/// The two-button relative layout. Same delivery contract as the d-pad:
/// the turn fires on touch-down with no clock advanced.
void main() {
  Future<void> pump(
    WidgetTester tester,
    List<RelativeTurn> fired, {
    bool canSteer = true,
  }) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 360,
          child: SteerableTurnButtons(
            onTurn: fired.add,
            theme: GameTheme.classic,
            height: 120,
            canSteer: canSteer,
            centre: const Text('42'),
          ),
        ),
      ),
    );
  }

  testWidgets('each side fires its turn on touch-down', (tester) async {
    final fired = <RelativeTurn>[];
    await pump(tester, fired);

    final left = tester.getCenter(find.bySemanticsLabel('Turn left'));
    final right = tester.getCenter(find.bySemanticsLabel('Turn right'));

    final a = await tester.startGesture(left);
    expect(fired, [RelativeTurn.left], reason: 'on the down event');
    await a.up();

    final b = await tester.startGesture(right);
    expect(fired, [RelativeTurn.left, RelativeTurn.right]);
    await b.up();
    await tester.pump();
  });

  testWidgets('holding a button is one turn, not a stream of them', (
    tester,
  ) async {
    final fired = <RelativeTurn>[];
    await pump(tester, fired);

    final left = tester.getCenter(find.bySemanticsLabel('Turn left'));
    final finger = await tester.startGesture(left);
    await finger.moveBy(const Offset(4, -3));
    await tester.pump(const Duration(seconds: 1));
    expect(fired, [RelativeTurn.left]);
    await finger.up();
    await tester.pump();
  });

  testWidgets('the left corner is left and the right corner is right', (
    tester,
  ) async {
    // Layout, not just labels: the whole point is that the thumbs land on
    // the side they want to turn toward without looking.
    final fired = <RelativeTurn>[];
    await pump(tester, fired);

    final left = tester.getCenter(find.bySemanticsLabel('Turn left'));
    final right = tester.getCenter(find.bySemanticsLabel('Turn right'));
    expect(left.dx, lessThan(right.dx));

    final bar = tester.getRect(find.byType(SteerableTurnButtons));
    expect(left.dx, lessThan(bar.center.dx));
    expect(right.dx, greaterThan(bar.center.dx));
  });

  testWidgets('the readouts sit between the buttons', (tester) async {
    final fired = <RelativeTurn>[];
    await pump(tester, fired);

    final left = tester.getCenter(find.bySemanticsLabel('Turn left'));
    final right = tester.getCenter(find.bySemanticsLabel('Turn right'));
    final centre = tester.getCenter(find.text('42'));
    expect(centre.dx, greaterThan(left.dx));
    expect(centre.dx, lessThan(right.dx));
  });

  testWidgets('a control that cannot steer takes no presses', (tester) async {
    final fired = <RelativeTurn>[];
    await pump(tester, fired, canSteer: false);

    await tester.tap(find.bySemanticsLabel('Turn left'), warnIfMissed: false);
    await tester.tap(find.bySemanticsLabel('Turn right'), warnIfMissed: false);
    expect(fired, isEmpty);
  });

  testWidgets('assistive tech gets two labelled buttons', (tester) async {
    final handle = tester.ensureSemantics();
    final fired = <RelativeTurn>[];
    await pump(tester, fired);

    expect(find.bySemanticsLabel('Turn left'), findsOneWidget);
    expect(find.bySemanticsLabel('Turn right'), findsOneWidget);
    handle.dispose();
  });
}
