import 'dart:convert';
import 'dart:io';

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/analytics/analytics_values.dart';
import 'package:snake_classic/services/first_run_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/home_versus_cta.dart';
import 'package:snake_classic/widgets/walkthrough/home_walkthrough.dart';

import '../widgets/control_test_harness.dart';

/// What the game tells a new player, and when.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations en;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Map<String, dynamic> arb(String code) => jsonDecode(
    File('lib/l10n/app_$code.arb').readAsStringSync(),
  ) as Map<String, dynamic>;

  const locales = ['en', 'hi', 'pt', 'es', 'fr', 'ru', 'pl', 'ar', 'it'];

  group('Help describes the controls the game actually has', () {
    test('tap-to-pause is gone from every locale', () {
      // "Tap Screen — Pause/Resume game" described a handler the game has
      // never had. It was the first thing a new player would try.
      for (final code in locales) {
        expect(
          arb(code).keys,
          isNot(contains('insTapScreen')),
          reason: code,
        );
        expect(
          arb(code).keys,
          isNot(contains('insTapScreenDesc')),
          reason: code,
        );
      }
    });

    test('the real pause controls are taught instead', () {
      expect(en.insHudPause, isNotEmpty);
      expect(en.insHudPauseDesc.toLowerCase(), contains('pause'));
      expect(en.insSpacebarDesc.toLowerCase(), contains('pause'));
    });

    test('the D-pad is documented and points at Settings', () {
      expect(en.insDpad.toLowerCase(), contains('d-pad'));
      expect(en.insControlsNote.toLowerCase(), contains('settings'));
      expect(en.insControlsNote.toLowerCase(), contains('controls'));
    });

    test('every locale defines the new control copy', () {
      for (final code in locales) {
        final keys = arb(code).keys;
        for (final key in ['insHudPause', 'insHudPauseDesc', 'insDpad',
            'insDpadDesc', 'insControlsNote']) {
          expect(keys, contains(key), reason: '$key missing in $code');
        }
      }
    });
  });

  group('Help introduces Versus honestly', () {
    test('it says what the mode is', () {
      expect(en.insVersus, isNotEmpty);
      expect(en.insVersusOnline.toLowerCase(), contains('1v1'));
      expect(en.insVersusQuickDesc.toLowerCase(), contains('opponent'));
      expect(en.insVersusRoomDesc.toLowerCase(), contains('code'));
    });

    test('it never mentions bots', () {
      // Not an implementation detail to leak, in any locale.
      for (final code in locales) {
        final values = arb(code).entries
            .where((e) => !e.key.startsWith('@'))
            .map((e) => e.value.toString().toLowerCase());
        for (final value in values) {
          expect(value.contains(' bot '), isFalse, reason: '$code: $value');
          expect(value.startsWith('bot '), isFalse, reason: '$code: $value');
        }
      }
    });

    test('it never promises the opponent is a person', () {
      // "Finds you an opponent" is accurate. "Play a real person" is a
      // promise the matchmaker does not make.
      final claims = [
        'real person',
        'real player',
        'real people',
        'human opponent',
        'against humans',
      ];
      final versusCopy = [
        en.insVersusOnline,
        en.insVersusOnlineDesc,
        en.insVersusQuick,
        en.insVersusQuickDesc,
        en.insVersusRoom,
        en.insVersusRoomDesc,
        en.homeVersusSubtitle,
        en.hwVersusMsg,
      ].map((s) => s.toLowerCase());

      for (final copy in versusCopy) {
        for (final claim in claims) {
          expect(copy.contains(claim), isFalse, reason: '"$copy" claims $claim');
        }
      }
    });
  });

  group('the tutorial does not insist on swiping', () {
    test('its practice steps ask for a turn, not a gesture', () {
      expect(en.wtPracticeRightTitle.toLowerCase(), contains('turn'));
      expect(en.wtPracticeRightTitle.toLowerCase(), isNot(contains('swipe')));
      expect(en.wtPracticeUpTitle.toLowerCase(), contains('turn'));
      expect(en.wtSwipeRightUpper.toLowerCase(), contains('turn'));
      expect(en.wtSwipeUpUpper.toLowerCase(), contains('turn'));
    });

    test('and the hint names every input method', () {
      final hint = en.wtSwipeAnywhereScreen.toLowerCase();
      expect(hint, contains('swipe'));
      expect(hint, contains('d-pad'));
      expect(hint, contains('arrow'));
    });

    test('the controls step points at the setting', () {
      final msg = en.wtControlsMsg.toLowerCase();
      expect(msg, contains('d-pad'));
      expect(msg, contains('arrow keys'));
    });
  });

  group('the Home tour', () {
    test('is at most three steps', () {
      // It was seven: Play, coins, daily, store, cosmetics, profile,
      // settings — a metagame tour for someone who had played once.
      expect(HomeWalkthrough.getSteps(en).length, lessThanOrEqualTo(3));
    });

    test('opens on Versus', () {
      final steps = HomeWalkthrough.getSteps(en);

      expect(steps.first.id, 'home_versus');
      expect(steps.first.targetKey, same(HomeWalkthrough.versusKey));
    });

    test('every step points at something', () {
      for (final step in HomeWalkthrough.getSteps(en)) {
        expect(step.targetKey, isNotNull, reason: step.id);
        expect(step.title, isNotEmpty, reason: step.id);
        expect(step.message, isNotEmpty, reason: step.id);
      }
    });

    test('it does not tour the store or the profile any more', () {
      final ids = HomeWalkthrough.getSteps(en).map((s) => s.id);

      expect(ids, isNot(contains('home_store')));
      expect(ids, isNot(contains('home_cosmetics')));
      expect(ids, isNot(contains('home_profile')));
      expect(ids, isNot(contains('home_settings')));
    });

    test('its version was bumped so the numbers stay comparable', () {
      expect(kHomeTourVersion, greaterThan(1));
    });
  });

  group('the three-game gate', () {
    Future<FirstRunService> serviceAfter(int games) async {
      SharedPreferences.setMockInitialValues({
        'first_run_games_started': games,
      });
      final service = FirstRunService()..resetForTest();
      await service.initialize();
      return service;
    }

    test('one game start is not enough for the tour', () async {
      // The queue used to fire the moment isFirstGame flipped — after one
      // START, which a player who quit two seconds in has also done.
      for (final games in [0, 1, 2]) {
        final service = await serviceAfter(games);
        expect(
          service.hasCompletedOnboarding,
          isFalse,
          reason: '$games games started',
        );
      }
    });

    test('three is', () async {
      final service = await serviceAfter(FirstRunService.onboardingGameCount);

      expect(service.hasCompletedOnboarding, isTrue);
    });
  });

  group('the Versus call to action', () {
    test('is labelled as the audit specified', () {
      expect(en.homeVersusCta, 'VERSUS');
      expect(en.homeVersusSubtitle, contains('1v1 Classic'));
      expect(en.homeVersusSubtitle.toLowerCase(), contains('quick match'));
      expect(en.homeVersusSubtitle.toLowerCase(), contains('friend'));
    });

    test('it opens the existing lobby route', () {
      // Not a queue, not a new screen: the lobby, where the player chooses.
      expect(AppRoutes.multiplayerLobby, '/multiplayer');
    });

    testWidgets('renders both lines and opens the lobby on tap', (
      tester,
    ) async {
      var opened = 0;
      await tester.pumpWidget(
        harness(
          HomeVersusCta(theme: GameTheme.classic, onOpen: () => opened++),
        ),
      );

      expect(find.text('VERSUS'), findsOneWidget);
      expect(
        find.text('1v1 Classic · Quick match or invite a friend'),
        findsOneWidget,
      );

      await tester.tap(find.byType(HomeVersusCta));
      await tester.pump();

      expect(opened, 1, reason: 'one tap, one lobby');
    });

    testWidgets('is a labelled button with a 48dp target', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        harness(HomeVersusCta(theme: GameTheme.classic, onOpen: () {})),
      );

      expect(
        find.bySemanticsLabel(
          'VERSUS. 1v1 Classic · Quick match or invite a friend',
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(HomeVersusCta)).height,
        greaterThanOrEqualTo(48.0),
      );

      handle.dispose();
    });

    testWidgets('a screen reader can actually activate it', (tester) async {
      // A label plus button: true and nothing else announces a button that
      // cannot be pressed. excludeSemantics drops the GestureDetector's own
      // tap action along with everything else beneath, so the action has to
      // live on this node.
      final handle = tester.ensureSemantics();
      var opened = 0;
      await tester.pumpWidget(
        harness(
          HomeVersusCta(theme: GameTheme.classic, onOpen: () => opened++),
        ),
      );

      final node = tester.getSemantics(find.byType(HomeVersusCta));
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
        reason: 'the node advertises a tap action',
      );

      tester.semantics.tap(
        find.semantics.byLabel(
          'VERSUS. 1v1 Classic · Quick match or invite a friend',
        ),
      );
      await tester.pump();

      expect(opened, 1, reason: 'activating it opens the lobby exactly once');
      handle.dispose();
    });

    testWidgets('it does not queue anything by itself', (tester) async {
      // The CTA's whole contract: it opens a screen. Anything that starts
      // matchmaking from Home would be a behaviour change the audit
      // explicitly ruled out.
      var opened = 0;
      await tester.pumpWidget(
        harness(
          HomeVersusCta(theme: GameTheme.classic, onOpen: () => opened++),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(opened, 0, reason: 'nothing happens until the player taps');
    });

    test('the lobby entry points are a closed, low-cardinality set', () {
      expect(
        {LobbyEntryPoint.homeVersus, LobbyEntryPoint.navTile},
        hasLength(2),
      );
      expect(
        {TutorialEntryPoint.pause, TutorialEntryPoint.settingsReplay},
        hasLength(2),
      );
      expect(
        {OnboardingStage.onboarding, OnboardingStage.established},
        hasLength(2),
      );
    });
  });
}
