import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/widgets/lb/lb_coin_fly.dart';
import 'package:snake_classic/widgets/lb/lb_rolling_number.dart';

void main() {
  group('LBRollPlan', () {
    List<(int, String?, String)> pairs(LBRollPlan p) =>
        [for (final s in p.slots) (s.index, s.from, s.to)];

    test('99 -> 100 matches digits from the right and rolls every column', () {
      final plan = LBRollPlan.of('99', '100');
      expect(pairs(plan), [(0, null, '1'), (1, '9', '0'), (2, '9', '0')]);
      expect(plan.dropped, isEmpty);
    });

    test('1,234 -> 1,240 rolls only the last two digits', () {
      final plan = LBRollPlan.of('1,234', '1,240');
      expect(pairs(plan), [(3, '3', '4'), (4, '4', '0')]);
    });

    test('decreasing 100 -> 99 drops the leading digit', () {
      final plan = LBRollPlan.of('100', '99');
      expect(pairs(plan), [(0, '0', '9'), (1, '0', '9')]);
      expect(plan.dropped, ['1']);
    });

    test('text around a number stays still', () {
      final plan = LBRollPlan.of('2 OF 3 DONE', '3 OF 3 DONE');
      expect(pairs(plan), [(0, '2', '3')]);
    });

    test('rightmost rolling character moves first', () {
      final plan = LBRollPlan.of('99', '100');
      expect([for (final s in plan.slots) s.order], [2, 1, 0]);
    });
  });

  group('LBRollingNumber', () {
    Widget host(int value, {bool reduce = false, bool cells = false}) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduce),
            child: Scaffold(
              body: Center(
                child: cells
                    ? LBRollingNumber.cells(value, cell: 4)
                    : LBRollingNumber(value, format: (v) => v == 1234 ? '1,234' : (v == 1240 ? '1,240' : '$v')),
              ),
            ),
          ),
        );

    testWidgets('rolls through a painter, then rests on plain text', (tester) async {
      await tester.pumpWidget(host(99));
      expect(find.text('99'), findsOneWidget);

      await tester.pumpWidget(host(100));
      await tester.pump(const Duration(milliseconds: 50));
      // Mid-roll: the resting Text is kept for layout but hidden.
      expect(find.byType(Visibility), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pump(LBRollingNumber.durationFor(3));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      expect(find.byType(Visibility), findsNothing);
    });

    testWidgets('grouped values roll too (1,234 -> 1,240)', (tester) async {
      await tester.pumpWidget(host(1234));
      await tester.pumpWidget(host(1240));
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.byType(Visibility), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1,240'), findsOneWidget);
    });

    testWidgets('decreasing values roll and settle', (tester) async {
      await tester.pumpWidget(host(100));
      await tester.pumpWidget(host(99));
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.byType(Visibility), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('reduce motion shows the final value immediately', (tester) async {
      await tester.pumpWidget(host(99, reduce: true));
      await tester.pumpWidget(host(100, reduce: true));
      // No frames pumped past the rebuild: already the final text, no roll.
      expect(find.text('100'), findsOneWidget);
      expect(find.byType(Visibility), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('cell variant rolls and returns to LBCellText', (tester) async {
      await tester.pumpWidget(host(9, cells: true));
      await tester.pumpWidget(host(10, cells: true));
      await tester.pump(const Duration(milliseconds: 30));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('LBCoinFly', () {
    testWidgets('flies, lands on the target, and removes its overlay', (tester) async {
      final source = GlobalKey();
      final target = GlobalKey<LBCoinTargetState>();
      var balance = 10;
      late StateSetter setOuter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuter = setState;
                return Column(
                  children: [
                    LBCoinTarget(
                      key: target,
                      value: balance,
                      builder: (context, shown, icon) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [icon(const SizedBox(width: 12, height: 12)), Text('$shown')],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(key: source, width: 80, height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final context = tester.element(find.byKey(source));
      var done = false;
      LBCoinFly.play(context, from: LBCoinFly.rectOf(source)!, to: target, coins: 6)
          .then((_) => done = true);
      // Credit after launch: the counter holds the old value while in flight.
      setOuter(() => balance = 35);
      await tester.pump();
      expect(find.byKey(LBCoinFly.layerKey), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      await tester.pump(LBMotion.slow);
      await tester.pumpAndSettle();
      expect(find.byKey(LBCoinFly.layerKey), findsNothing);
      expect(done, isTrue);
      expect(find.text('35'), findsOneWidget);
    });

    // SNAKE-CLASSIC-FLUTTER-20: the overlay rebuilt the flight after the
    // screen that launched it had closed, and the builder read the dead
    // caller's context (MediaQuery.of -> null check).
    testWidgets('survives the launching route closing mid-flight', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      final source = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const Scaffold(body: SizedBox())),
      );
      navigator.currentState!.push(
        PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => Scaffold(
            body: Center(child: SizedBox(key: source, width: 80, height: 40)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byKey(source));
      var done = false;
      LBCoinFly.play(context, from: LBCoinFly.rectOf(source)!).then((_) => done = true);
      await tester.pump();
      expect(find.byKey(LBCoinFly.layerKey), findsOneWidget);

      // Close the sheet/screen while the coins are in the air (its element
      // is unmounted at the end of that frame), then make the overlay
      // rebuild its entries, as any other insert/remove does.
      navigator.currentState!.pop();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(source), findsNothing);
      final overlay = navigator.currentState!.overlay!;
      final other = OverlayEntry(builder: (_) => const SizedBox());
      overlay.insert(other);
      await tester.pump();
      other.remove();
      other.dispose();
      await tester.pump(LBMotion.slow);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(LBCoinFly.layerKey), findsNothing);
      expect(done, isTrue);
    });

    testWidgets('reduce motion skips the flight', (tester) async {
      final source = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: SizedBox(key: source, width: 40, height: 40)),
          ),
        ),
      );
      await LBCoinFly.play(tester.element(find.byKey(source)), from: LBCoinFly.rectOf(source)!);
      await tester.pump();
      expect(find.byKey(LBCoinFly.layerKey), findsNothing);
    });
  });
}
