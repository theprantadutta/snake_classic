import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/screens/game_over_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/game_over/game_over_beat_sheet.dart';

/// The game over beat sheet: one clock, tap to skip, reduce motion and
/// revisits showing the end state. The screen itself is too
/// dependency-heavy to pump whole, so these pump the sheet with the real
/// score row and a stand-in AGAIN button gated like the real action rows.

Widget _app(Widget child, {bool reduced = false}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(extensions: [LBPalette.of(GameTheme.classic)]),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: child!,
  ),
  home: Scaffold(body: child),
);

class _Harness {
  GameOverReveal? reveal;
  final beats = <GameOverBeat>[];
  int againPresses = 0;

  Widget sheet({Object runKey = 1, bool isNewBest = true}) => GameOverBeatSheet(
    runKey: runKey,
    isNewBest: isNewBest,
    onBeat: beats.add,
    builder: (context, r) {
      reveal = r;
      return ListView(
        children: [
          GameOverScoreRowForTest(
            score: 1840,
            best: 1840,
            isNewBest: isNewBest,
            reveal: r,
          ),
          const SizedBox(height: 40),
          AbsorbPointer(
            absorbing: !r.actionsLive,
            child: BeatIn(
              animation: r.action(1),
              child: SizedBox(
                height: 80,
                child: GestureDetector(
                  key: const Key('again'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => againPresses++,
                  child: const Text('AGAIN'),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

String? _scoreText(WidgetTester tester) => tester
    .widgetList<LBCellText>(find.byType(LBCellText))
    .map((t) => t.text)
    .firstOrNull;

double _againOpacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text('AGAIN'), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  setUp(GameOverBeatSheet.resetRevealedRun);

  testWidgets('plays through to the end state and fires its beats', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(_app(h.sheet()));

    expect(h.reveal!.clock.value, 0);
    expect(h.reveal!.actionsLive, isFalse);
    expect(_againOpacity(tester), 0);

    // Mid count-up: the digits are somewhere between 0 and the score.
    await tester.pump(const Duration(milliseconds: 700));
    final mid = int.parse(_scoreText(tester)!);
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1840));

    await tester.pumpAndSettle();
    expect(h.reveal!.clock.value, 1);
    expect(h.reveal!.actionsLive, isTrue);
    expect(_scoreText(tester), '1840');
    expect(tester.widget<LBCellText>(find.byType(LBCellText)).glow, isTrue);
    expect(_againOpacity(tester), 1);
    expect(h.beats, [GameOverBeat.scoreLanded, GameOverBeat.newBest]);

    await tester.tap(find.byKey(const Key('again')));
    expect(h.againPresses, 1);
  });

  testWidgets('a tap before the end skips to it without pressing AGAIN', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(_app(h.sheet()));
    await tester.pump(const Duration(milliseconds: 200));

    // AGAIN has not arrived: the skip tap must not reach it.
    await tester.tap(find.byKey(const Key('again')), warnIfMissed: false);
    await tester.pump();
    expect(h.againPresses, 0);
    expect(h.reveal!.clock.value, 1);
    expect(h.reveal!.actionsLive, isTrue);
    expect(_scoreText(tester), '1840');
    expect(_againOpacity(tester), 1);
    // Beats jumped over are not replayed as a burst of haptics.
    expect(h.beats, isEmpty);
    expect(tester.binding.transientCallbackCount, 0);

    // Now visible: the next tap goes through.
    await tester.tap(find.byKey(const Key('again')));
    expect(h.againPresses, 1);
  });

  testWidgets('reduce motion renders the end state on the first frame', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(_app(h.sheet(), reduced: true));

    expect(h.reveal!.clock.value, 1);
    expect(h.reveal!.actionsLive, isTrue);
    expect(_scoreText(tester), '1840');
    expect(_againOpacity(tester), 1);
    expect(h.beats, isEmpty);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('coming back to the same run shows the end state', (
    tester,
  ) async {
    final first = _Harness();
    await tester.pumpWidget(_app(first.sheet(runKey: 'run-7')));
    await tester.pumpAndSettle();

    // Leave and come back (e.g. from the replay viewer) to a new instance.
    await tester.pumpWidget(_app(const SizedBox()));
    final again = _Harness();
    await tester.pumpWidget(_app(again.sheet(runKey: 'run-7')));
    expect(again.reveal!.clock.value, 1);
    expect(_scoreText(tester), '1840');

    // A different run plays the sheet again.
    await tester.pumpWidget(_app(const SizedBox()));
    final next = _Harness();
    await tester.pumpWidget(_app(next.sheet(runKey: 'run-8')));
    expect(next.reveal!.clock.value, 0);
    await tester.pumpAndSettle();
  });

  test('count-up uses a bounded number of steps and lands exactly', () {
    final shown = {
      for (var i = 0; i <= 1000; i++) BeatCount.shownAt(i / 1000, 98765, 14),
    };
    expect(shown.length, lessThanOrEqualTo(15));
    expect(BeatCount.shownAt(0, 98765, 14), 0);
    expect(BeatCount.shownAt(1, 98765, 14), 98765);
    expect(BeatCount.shownAt(.5, 3, 14), lessThanOrEqualTo(3));
    expect(BeatCount.shownAt(.3, 0, 14), 0);
  });
}
