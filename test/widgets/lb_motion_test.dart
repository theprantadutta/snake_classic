import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

import 'control_test_harness.dart';

/// Motion behaviour of the Living Board primitives (docs/MOTION_SPEC.md).
void main() {
  Widget reducedHarness(Widget child) => harness(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child,
          ),
        ),
      );

  double opacityOf(WidgetTester tester, Finder f) {
    final o = tester.widget<Opacity>(
      find.ancestor(of: f, matching: find.byType(Opacity)).first,
    );
    return o.opacity;
  }

  Offset translationOf(WidgetTester tester, Finder f) {
    final t = tester.widget<Transform>(
      find.ancestor(of: f, matching: find.byType(Transform)).first,
    );
    final m = t.transform;
    return Offset(m.getTranslation().x, m.getTranslation().y);
  }

  group('LBStaggerIn', () {
    testWidgets('enters once and does not replay on rebuild', (tester) async {
      late StateSetter setOuter;
      var label = 'A';
      await tester.pumpWidget(
        harness(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return LBStaggerIn(index: 2, child: Text(label));
            },
          ),
        ),
      );
      // Index 2 waits 2 * stagger before it starts: still hidden and low.
      expect(opacityOf(tester, find.text('A')), 0);
      expect(translationOf(tester, find.text('A')).dy, 8);

      await tester.pump(LBStaggerIn.totalDuration);
      expect(opacityOf(tester, find.text('A')), 1);
      expect(translationOf(tester, find.text('A')).dy, 0);

      // A rebuild with new content stays put, no second entrance.
      setOuter(() => label = 'B');
      await tester.pump();
      expect(opacityOf(tester, find.text('B')), 1);
      expect(translationOf(tester, find.text('B')).dy, 0);
      await tester.pump(LBMotion.stagger);
      expect(opacityOf(tester, find.text('B')), 1);
      expect(translationOf(tester, find.text('B')).dy, 0);
    });

    testWidgets('items past the cap enter with the last staggered one', (tester) async {
      await tester.pumpWidget(
        harness(
          Column(
            children: [
              for (var i = 0; i < 12; i++) LBStaggerIn(index: i, child: Text('row $i')),
            ],
          ),
        ),
      );
      await tester.pump(LBMotion.stagger * 7 + LBMotion.gentle * .5);
      expect(opacityOf(tester, find.text('row 11')), opacityOf(tester, find.text('row 7')));
      await tester.pumpAndSettle();
      expect(opacityOf(tester, find.text('row 11')), 1);
    });

    testWidgets('reduced motion fades without any offset', (tester) async {
      await tester.pumpWidget(
        reducedHarness(const LBStaggerIn(index: 3, child: Text('calm'))),
      );
      expect(
        find.ancestor(of: find.text('calm'), matching: find.byType(FadeTransition)),
        findsWidgets,
      );
      // No translate anywhere between the stagger and its child.
      final translates = find.descendant(
        of: find.byType(LBStaggerIn),
        matching: find.byType(Transform),
      );
      expect(translates, findsNothing);
      await tester.pump(LBMotion.reducedFade);
      final fade = tester.widget<FadeTransition>(
        find.ancestor(of: find.text('calm'), matching: find.byType(FadeTransition)).first,
      );
      expect(fade.opacity.value, 1);
    });

    testWidgets('LBScaffold rows built after the entrance appear in place', (tester) async {
      await tester.pumpWidget(
        harness(
          SizedBox(
            height: 400,
            child: LBStaggerGroup(
              child: ListView(
                children: [
                  for (var i = 0; i < 40; i++)
                    LBStaggerIn(index: i, child: SizedBox(height: 60, child: Text('item $i'))),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pump();
      final late = find.textContaining('item 3').last;
      expect(opacityOf(tester, late), 1);
      expect(translationOf(tester, late).dy, 0);
    });
  });

  group('LBCellsBar', () {
    int litCells(WidgetTester tester) {
      // Count lit cells by sampling the painter through its semantics-free
      // render: easier to read the state's target via the painter's fields.
      final paint = tester.widget<CustomPaint>(
        find.descendant(of: find.byType(LBCellsBar), matching: find.byType(CustomPaint)),
      );
      return (paint.painter as dynamic).lit as int;
    }

    testWidgets('first build lights up and settles on the final value', (tester) async {
      await tester.pumpWidget(harness(const SizedBox(width: 160, child: LBCellsBar(count: 8, value: .5))));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(LBCellsBar.introCap);
      expect(tester.hasRunningAnimations, isFalse);
      expect(litCells(tester), 4);
    });

    testWidgets('an increase lights new cells in order and ends on the new value', (tester) async {
      var value = .25;
      late StateSetter set;
      await tester.pumpWidget(
        harness(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return SizedBox(width: 160, child: LBCellsBar(count: 8, value: value));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      set(() => value = .75);
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(litCells(tester), 6);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a decrease is instant', (tester) async {
      var value = 1.0;
      late StateSetter set;
      await tester.pumpWidget(
        harness(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return SizedBox(width: 160, child: LBCellsBar(count: 8, value: value));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      set(() => value = .5);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(litCells(tester), 4);
    });

    testWidgets('reduced motion never animates', (tester) async {
      await tester.pumpWidget(
        reducedHarness(const SizedBox(width: 160, child: LBCellsBar(count: 8, value: 1))),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('LBBlock press', () {
    testWidgets('a tap fires onTap exactly once', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        harness(LBBlock(onTap: () => taps++, child: const Text('GO'))),
      );
      await tester.tap(find.text('GO'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('filled block sinks while held and springs back', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        harness(LBBlock(kind: LBBlockKind.fill, onTap: () => taps++, child: const Text('PLAY'))),
      );
      final gesture = await tester.startGesture(tester.getCenter(find.text('PLAY')));
      await tester.pump(const Duration(milliseconds: 200)); // past the tap-down delay
      await tester.pump(LBMotion.pressDown);
      final scales = tester
          .widgetList<Transform>(find.ancestor(of: find.text('PLAY'), matching: find.byType(Transform)))
          .map((t) => t.transform.entry(0, 0));
      expect(scales.any((s) => s < 1), isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('idle glow pulse loops only when enabled', (tester) async {
      LBBlock.idleGlowPulse = true;
      addTearDown(() => LBBlock.idleGlowPulse = false);
      await tester.pumpWidget(
        harness(LBBlock(kind: LBBlockKind.fill, onTap: () {}, child: const Text('PLAY'))),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isTrue);
      expect(find.byType(RepaintBoundary), findsWidgets);

      // Disabled block: no loop.
      await tester.pumpWidget(
        harness(const LBBlock(kind: LBBlockKind.fill, child: Text('PLAY'))),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion: no pulse', (tester) async {
      LBBlock.idleGlowPulse = true;
      addTearDown(() => LBBlock.idleGlowPulse = false);
      await tester.pumpWidget(
        reducedHarness(LBBlock(kind: LBBlockKind.fill, onTap: () {}, child: const Text('PLAY'))),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('LBToggle', () {
    testWidgets('switching animates and settles', (tester) async {
      var value = false;
      await tester.pumpWidget(
        harness(
          StatefulBuilder(
            builder: (context, setState) => LBToggle(
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
      await tester.tap(find.byType(LBToggle));
      await tester.pump();
      expect(value, isTrue);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
