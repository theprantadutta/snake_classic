import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/cross_promo.dart';
import 'package:snake_classic/screens/more_games_screen.dart';
import 'package:snake_classic/widgets/lb_screens/settings/more_games_section.dart';

import '../widgets/control_test_harness.dart';

/// Records `more_games` events.
class _Facade implements AnalyticsFacade {
  final List<(String, Map<String, Object>)> events = [];

  @override
  Future<void> trackEvent(String name, Map<String, Object> parameters) async =>
      events.add((name, parameters));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

void main() {
  group('CrossPromo store-policy invariants', () {
    test("only the owner's games, in display order (owner, 2026-11-23)", () {
      expect(CrossPromo.games.map((g) => g.id), [
        'cosmo_strike',
        'sunstone',
        'pourfect',
        'screw_out',
        'gridwell',
        'jadewell',
      ]);
    });

    test('a game shows only where it is live', () {
      List<String> ids(TargetPlatform p) =>
          [for (final g in CrossPromo.forPlatform(p, isWeb: false)) g.id];
      expect(ids(TargetPlatform.android), isNot(contains('jadewell')));
      expect(ids(TargetPlatform.iOS), isNot(contains('screw_out')));
      expect(ids(TargetPlatform.android), hasLength(5));
      expect(ids(TargetPlatform.iOS), hasLength(5));
    });

    test('each platform links to its own store, with attribution', () {
      for (final g in CrossPromo.games) {
        final android = g.urlFor(TargetPlatform.android, isWeb: false);
        final ios = g.urlFor(TargetPlatform.iOS, isWeb: false);
        expect(android != null || ios != null, isTrue, reason: g.id);
        if (android != null) {
          final u = Uri.parse(android);
          expect(u.host, 'play.google.com');
          expect(u.queryParameters['id'], startsWith('com.pranta.'));
          expect(
            Uri.splitQueryString(u.queryParameters['referrer']!),
            {'utm_source': 'snake_classic', 'utm_medium': 'more_games'},
          );
        }
        if (ios != null) {
          final u = Uri.parse(ios);
          expect(u.host, 'apps.apple.com');
          expect(u.path, matches(RegExp(r'^/app/id\d+$')));
          expect(u.queryParameters['ct'], 'snake_classic_more_games');
        }
      }
    });

    test('nothing on web or desktop', () {
      expect(CrossPromo.forPlatform(TargetPlatform.android, isWeb: true),
          isEmpty);
      expect(CrossPromo.forPlatform(TargetPlatform.windows, isWeb: false),
          isEmpty);
      expect(CrossPromo.forPlatform(TargetPlatform.macOS, isWeb: false),
          isEmpty);
    });
  });

  group('More games UI', () {
    late _Facade facade;
    setUp(() {
      facade = _Facade();
      GetIt.I.registerSingleton<AnalyticsFacade>(facade);
    });
    tearDown(() => GetIt.I.unregister<AnalyticsFacade>());

    testWidgets('Settings: one row naming the games', (tester) async {
      await tester.pumpWidget(harness(ListView(children: const [
        MoreGamesSection(platform: TargetPlatform.android, isWeb: false),
      ])));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('MORE GAMES'), findsOneWidget);
      expect(
        find.text('Cosmo Strike, Sunstone, Pourfect, Screw Out, Gridwell'),
        findsOneWidget,
      );
    });

    testWidgets('Settings: hidden on web', (tester) async {
      await tester.pumpWidget(harness(ListView(children: const [
        MoreGamesSection(platform: TargetPlatform.android, isWeb: true),
      ])));
      await tester.pumpAndSettle();
      expect(find.text('MORE GAMES'), findsNothing);
    });

    for (final (platform, missing) in [
      (TargetPlatform.android, 'JADEWELL'),
      (TargetPlatform.iOS, 'SCREW OUT'),
    ]) {
      testWidgets('screen on ${platform.name}: a card per live game, each '
          'logged as shown', (tester) async {
        tester.view.physicalSize = const Size(1080, 3200);
        tester.view.devicePixelRatio = 2.5;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          harness(MoreGamesList(platform: platform, isWeb: false)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(MoreGameCard), findsNWidgets(5));
        expect(find.text('COSMO STRIKE'), findsOneWidget);
        expect(find.text('Arcade space shooter with boss battles'),
            findsOneWidget);
        expect(find.text(missing), findsNothing);
        final shown = [
          for (final e in facade.events)
            if (e.$2['stage'] == 'shown') e.$2['game'],
        ];
        expect(shown, hasLength(5));
      });
    }
  });
}
