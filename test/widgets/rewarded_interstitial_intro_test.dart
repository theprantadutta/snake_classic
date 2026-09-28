import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/ads/rewarded_interstitial_intro.dart';

/// The intro Google requires before a rewarded interstitial. What the policy
/// asks of it, checked one by one: the player can say no (button and back
/// gesture both count), saying nothing plays the ad once the countdown runs
/// out, and a tap that arrives with the card, the second half of a
/// double-tap on PLAY AGAIN, is not taken as an answer.
void main() {
  Widget harness(Widget child) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  /// Opens the intro and returns a holder for its eventual answer.
  Future<List<bool>> open(WidgetTester tester) async {
    final answers = <bool>[];
    await tester.pumpWidget(harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => answers.add(
            await showRewardedInterstitialIntro(
              context,
              theme: GameTheme.values.first,
              coins: 25,
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump(); // route pushed
    await tester.pump(const Duration(milliseconds: 200)); // transition done
    return answers;
  }

  testWidgets('states the reward before anything plays', (tester) async {
    await open(tester);
    expect(find.text('Bonus coins!'), findsOneWidget);
    expect(find.text('Watch a short ad and get +25 coins.'), findsOneWidget);
    expect(find.text('Ad starts in 5s'), findsOneWidget);
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('NO THANKS skips the ad', (tester) async {
    final answers = await open(tester);
    await tester.pump(const Duration(milliseconds: 600)); // armed
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();
    expect(answers, [false]);
  });

  testWidgets('the back gesture is a skip too', (tester) async {
    final answers = await open(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.maybePop();
    await tester.pumpAndSettle();
    expect(answers, [false]);
  });

  testWidgets('WATCH NOW plays it', (tester) async {
    final answers = await open(tester);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Watch now'));
    await tester.pumpAndSettle();
    expect(answers, [true]);
  });

  testWidgets('the countdown running out plays it', (tester) async {
    final answers = await open(tester);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(answers, [true]);
  });

  testWidgets('the countdown does not run out while the app is away',
      (tester) async {
    final answers = await open(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 10));
    expect(answers, isEmpty, reason: 'no ad may start unseen');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(answers, [true]);
  });

  testWidgets('a tap that lands with the card is not an answer',
      (tester) async {
    final answers = await open(tester);
    // Still inside the arming window.
    await tester.tap(find.text('No thanks'), warnIfMissed: false);
    await tester.pump();
    expect(answers, isEmpty);
    expect(find.text('Bonus coins!'), findsOneWidget);
    // And once armed, the same tap counts.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('No thanks'));
    await tester.pumpAndSettle();
    expect(answers, [false]);
  });
}
