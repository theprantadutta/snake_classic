import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

import 'control_test_harness.dart';

/// A fill-the-width cell bar must survive parents that measure intrinsic
/// height. It used a LayoutBuilder, which cannot, so a bar inside
/// SliverFillRemaining(hasScrollBody: false) threw and blanked the whole
/// Versus screen the moment FIND MATCH showed its search bar.
void main() {
  testWidgets('inside SliverFillRemaining without a scroll body', (tester) async {
    await tester.pumpWidget(
      harness(
        CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  const LBCellsBar(count: 16, value: .5),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(LBCellsBar)).width, greaterThan(0));
  });

  testWidgets('inside IntrinsicHeight', (tester) async {
    await tester.pumpWidget(
      harness(
        const IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Expanded(child: LBCellsBar(count: 8, value: 1))],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('fills the width with square cells', (tester) async {
    await tester.pumpWidget(
      harness(const SizedBox(width: 320, child: LBCellsBar(count: 16, value: .25))),
    );
    expect(tester.getSize(find.byType(LBCellsBar)), const Size(320, 20));
  });
}
