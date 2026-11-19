import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_parts.dart';

import 'control_test_harness.dart';

/// The store's six tabs don't fit a 360 dp phone. The row must scroll, say
/// so with an edge fade on the side that has more, and bring the selected
/// tab into view; on a tablet, where they fit, no fade is drawn.
void main() {
  const labels = ['Pro', 'Coins', 'Themes', 'Skins', 'Trails', 'Power-Ups'];

  Widget strip({int initialIndex = 0}) => DefaultTabController(
        length: labels.length,
        initialIndex: initialIndex,
        child: Builder(
          builder: (context) => StoreTabStrip(
            controller: DefaultTabController.of(context),
            labels: labels,
          ),
        ),
      );

  StoreTabStripState state(WidgetTester tester) =>
      tester.state<StoreTabStripState>(find.byType(StoreTabStrip));

  void expectFullyVisible(WidgetTester tester, String label, double width) {
    final rect = tester.getRect(find.text(label.toUpperCase()));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(width));
  }

  testWidgets('360 dp: fades the trailing edge, reaches POWER-UPS',
      (tester) async {
    await useScreen(tester, const Size(360, 640));
    await tester.pumpWidget(harness(strip()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(state(tester).moreBefore, isFalse);
    expect(state(tester).moreAfter, isTrue);
    expect(find.byType(ShaderMask), findsOneWidget);

    DefaultTabController.of(
      tester.element(find.byType(StoreTabStrip)),
    ).animateTo(labels.length - 1);
    await tester.pumpAndSettle();

    expectFullyVisible(tester, 'Power-Ups', 360);
    expect(state(tester).moreBefore, isTrue);
  });

  testWidgets('360 dp: deep link to Power-Ups lands with it visible',
      (tester) async {
    await useScreen(tester, const Size(360, 640));
    await tester.pumpWidget(harness(strip(initialIndex: labels.length - 1)));
    await tester.pumpAndSettle();
    expectFullyVisible(tester, 'Power-Ups', 360);
    expect(state(tester).moreBefore, isTrue);
  });

  testWidgets('800 dp tablet: everything fits, no fade', (tester) async {
    await useScreen(tester, const Size(800, 1280));
    await tester.pumpWidget(harness(strip(), size: const Size(800, 1280)));
    await tester.pumpAndSettle();
    expect(state(tester).moreBefore, isFalse);
    expect(state(tester).moreAfter, isFalse);
    expect(find.byType(ShaderMask), findsNothing);
    expectFullyVisible(tester, 'Power-Ups', 800);
  });

  testWidgets('RTL 360 dp: still scrolls and reaches the last tab',
      (tester) async {
    await useScreen(tester, const Size(360, 640));
    await tester.pumpWidget(
      harness(strip(), locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();
    expect(state(tester).moreAfter, isTrue);
    DefaultTabController.of(
      tester.element(find.byType(StoreTabStrip)),
    ).animateTo(labels.length - 1);
    await tester.pumpAndSettle();
    expectFullyVisible(tester, 'Power-Ups', 360);
  });
}
