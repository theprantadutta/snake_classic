import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/control_layout_picker.dart';

import 'control_test_harness.dart';

/// The Button Layout picker, pumped the way the settings screen actually
/// hosts it: inside a scroll view, with no bounded height.
///
/// 6.4.0 shipped a version whose option row stretched its children on the
/// cross axis. In a scroll view that is a request for infinite height, and
/// the whole settings screen failed to lay out. Nothing caught it because
/// the picker was a private method on a screen too heavy to pump. This
/// file is the regression test that would have.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    required ControlLayout selected,
    required ValueChanged<ControlLayout> onSelect,
    Size size = const Size(360, 640),
  }) async {
    await useScreen(tester, size);
    await tester.pumpWidget(
      harness(
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ControlLayoutPicker(
              theme: GameTheme.classic,
              selected: selected,
              onSelect: onSelect,
            ),
          ),
        ),
        size: size,
      ),
    );
  }

  testWidgets('lays out inside an unbounded scroll view', (tester) async {
    await pump(tester, selected: ControlLayout.dPad, onSelect: (_) {});
    expect(tester.takeException(), isNull);
    expect(find.byType(ControlLayoutPicker), findsOneWidget);
  });

  testWidgets('offers all three layouts', (tester) async {
    await pump(tester, selected: ControlLayout.dPad, onSelect: (_) {});
    expect(find.text('D-Pad'), findsOneWidget);
    expect(find.text('Turn Buttons'), findsOneWidget);
    expect(find.text('Joystick'), findsOneWidget);
  });

  testWidgets('tapping a card reports that layout', (tester) async {
    final picked = <ControlLayout>[];
    await pump(tester, selected: ControlLayout.dPad, onSelect: picked.add);
    await tester.tap(find.text('Joystick'));
    await tester.tap(find.text('Turn Buttons'));
    expect(picked, [ControlLayout.joystick, ControlLayout.turnButtons]);
  });

  testWidgets('survives the narrowest phone and a large text scale', (
    tester,
  ) async {
    await useScreen(tester, const Size(320, 568));
    await tester.pumpWidget(
      harness(
        SingleChildScrollView(
          child: ControlLayoutPicker(
            theme: GameTheme.classic,
            selected: ControlLayout.turnButtons,
            onSelect: (_) {},
          ),
        ),
        size: const Size(320, 568),
        textScale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
