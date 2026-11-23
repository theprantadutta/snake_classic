import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/cross_promo.dart';
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
    test('only Cosmo Strike is promoted (owner, 2026-11-23)', () {
      expect(CrossPromo.games.map((g) => g.id), ['cosmo_strike']);
    });

    test('each platform links to its own store only', () {
      for (final g in CrossPromo.games) {
        final android = g.urlFor(TargetPlatform.android, isWeb: false);
        final ios = g.urlFor(TargetPlatform.iOS, isWeb: false);
        if (android != null) {
          expect(Uri.parse(android).host, 'play.google.com');
        }
        if (ios != null) {
          expect(Uri.parse(ios).host, 'apps.apple.com');
        }
      }
    });

    test('links carry attribution so taps can be matched to installs', () {
      final g = CrossPromo.games.single;
      final android = Uri.parse(g.androidUrl!);
      expect(android.queryParameters['id'], 'com.pranta.cosmostrike');
      expect(
        Uri.splitQueryString(android.queryParameters['referrer']!),
        {'utm_source': 'snake_classic', 'utm_medium': 'more_games'},
      );
      expect(Uri.parse(g.iosUrl!).queryParameters['ct'],
          'snake_classic_more_games');
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

  group('MoreGamesSection', () {
    late _Facade facade;
    setUp(() {
      facade = _Facade();
      GetIt.I.registerSingleton<AnalyticsFacade>(facade);
    });
    tearDown(() => GetIt.I.unregister<AnalyticsFacade>());

    Widget host(TargetPlatform platform, {bool isWeb = false}) => harness(
      ListView(
        children: [MoreGamesSection(platform: platform, isWeb: isWeb)],
      ),
    );

    testWidgets('Android: one plain row, logs shown', (tester) async {
      await tester.pumpWidget(host(TargetPlatform.android));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('COSMO STRIKE'), findsOneWidget);
      expect(
        find.text('Arcade space shooter from the makers of Snake Classic'),
        findsOneWidget,
      );
      expect(facade.events, hasLength(1));
      expect(facade.events.single.$1, 'more_games');
      expect(facade.events.single.$2, {'stage': 'shown', 'game': 'cosmo_strike'});
    });

    testWidgets('iOS shows it too', (tester) async {
      await tester.pumpWidget(host(TargetPlatform.iOS));
      await tester.pumpAndSettle();
      expect(find.text('COSMO STRIKE'), findsOneWidget);
    });

    testWidgets('web: hidden, nothing logged', (tester) async {
      await tester.pumpWidget(host(TargetPlatform.android, isWeb: true));
      await tester.pumpAndSettle();
      expect(find.text('COSMO STRIKE'), findsNothing);
      expect(facade.events, isEmpty);
    });
  });
}
