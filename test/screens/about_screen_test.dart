import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/about_screen.dart';
import 'package:snake_classic/utils/constants.dart';

/// The About screen (8.3): a full page for the game and its maker, replacing
/// the credits dialog. It must fit a small phone at the largest text size,
/// show the player's own numbers (or a friendly line before game one), and
/// its feature chips must actually open their screens.
void main() {
  late GoRouter router;

  final played = GameStatistics(
    totalGamesPlayed: 42,
    highScore: 380,
    totalFoodConsumed: 517,
    totalGameTime: 3 * 3600 + 25 * 60,
    firstPlayedDate: DateTime(2026, 8, 14),
  );

  Widget app({required GameStatistics stats, double textScale = 1.0}) {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(
          path: AppRoutes.about,
          builder: (_, _) =>
              AboutScreen(statistics: stats, version: ('8.3.0', '90')),
        ),
        GoRoute(
          path: AppRoutes.dailyChallenges,
          builder: (_, _) => const Scaffold(body: Text('DAILY SCREEN')),
        ),
        GoRoute(
          path: AppRoutes.instructions,
          builder: (_, _) => const Scaffold(body: Text('HELP SCREEN')),
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => _StubThemeCubit()),
        BlocProvider<PremiumCubit>(create: (_) => _StubPremiumCubit()),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    );
  }

  Future<void> pump(
    WidgetTester tester, {
    GameStatistics? stats,
    Size size = const Size(390, 844),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(stats: stats ?? played, textScale: textScale));
    await tester.pumpAndSettle();
    router.push(AppRoutes.about);
    await tester.pumpAndSettle();
  }

  testWidgets('every section is there, in order', (tester) async {
    await pump(tester);
    const headings = [
      'THE GAME',
      "WHAT'S INSIDE",
      'YOUR STORY SO FAR',
      'MADE BY',
      'THANK YOU',
    ];
    // Scrolling down only: each heading is found below the previous one.
    for (final heading in headings) {
      final finder = find.text(heading);
      await tester.scrollUntilVisible(finder, 200);
      expect(finder, findsOneWidget, reason: heading);
    }
    expect(find.text('Pranta Dutta'), findsOneWidget);
  });

  testWidgets("the player's own numbers", (tester) async {
    await pump(tester);
    await tester.scrollUntilVisible(find.text('42'), 200);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('380'), findsOneWidget);
    expect(find.text('517'), findsOneWidget);
    expect(find.text('3h 25m'), findsOneWidget);
    expect(find.textContaining('Playing since'), findsOneWidget);
  });

  testWidgets('before the first game it says so instead of zeros',
      (tester) async {
    await pump(tester, stats: const GameStatistics());
    final line = find.textContaining('Your story starts with your first game');
    await tester.scrollUntilVisible(line, 200);
    expect(line, findsOneWidget);
    expect(find.textContaining('Playing since'), findsNothing);
  });

  testWidgets('a feature chip opens its screen', (tester) async {
    await pump(tester);
    final daily = find.text('Daily');
    await tester.scrollUntilVisible(daily, 200);
    await tester.tap(daily);
    await tester.pumpAndSettle();
    expect(find.text('DAILY SCREEN'), findsOneWidget);
  });

  for (final (name, size) in [
    ('small phone', const Size(360, 640)),
    ('tablet', const Size(800, 1340)),
  ]) {
    testWidgets('fits a $name at 1.6x text, top to bottom', (tester) async {
      await pump(tester, size: size, textScale: 1.6);
      expect(tester.takeException(), isNull);
      // Scroll the whole page: nothing overflows on the way down.
      await tester.scrollUntilVisible(
        find.textContaining('All rights reserved'),
        300,
      );
      expect(tester.takeException(), isNull);
    });
  }
}

class _StubThemeCubit extends Cubit<ThemeState> implements ThemeCubit {
  _StubThemeCubit() : super(const ThemeState(currentTheme: GameTheme.classic));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _StubPremiumCubit extends Cubit<PremiumState> implements PremiumCubit {
  _StubPremiumCubit() : super(PremiumState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
