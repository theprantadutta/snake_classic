import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/screens/instructions_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

/// How to Play, laid out.
///
/// The screen it replaced put every control name in a fixed 140-pixel pill,
/// which fit "Swipe Up" and very little else: a long localized name wrapped
/// to three lines inside a box built for one, and large accessibility text
/// had nowhere to go. These tests pin the content down and then run the
/// layout across the screens and text scales where that used to fall apart.
void main() {
  /// The screen needs a ThemeCubit, localizations and a router that can pop.
  /// Everything else it draws comes from l10n.
  late GoRouter router;

  Widget harness({required double textScale, required Locale locale}) {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/help',
          builder: (context, state) => const InstructionsScreen(),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => _StubThemeCubit()),
        // The screen's banner-ad slot watches this. It renders nothing in a
        // test (no ad service), but it still looks the cubit up.
        BlocProvider<PremiumCubit>(create: (_) => _StubPremiumCubit()),
      ],
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        // Inside the app, so it survives MaterialApp building its own
        // MediaQuery from the view.
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
    Size size = const Size(390, 844),
    double textScale = 1.0,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness(textScale: textScale, locale: locale));
    await tester.pumpAndSettle();
    // Pushed rather than started on, so the back action has somewhere to go —
    // which is how a player always reaches this screen.
    router.push('/help');
    await tester.pumpAndSettle();
  }

  group('everything a player came for is on the page', () {
    testWidgets('the objective leads', (tester) async {
      await pump(tester);

      expect(find.text('OBJECTIVE'), findsOneWidget);
      expect(
        find.textContaining('eat food and grow', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('every section is present, in order', (tester) async {
      await pump(tester);

      const headings = [
        'OBJECTIVE',
        'CONTROLS',
        'VERSUS',
        'FOOD TYPES',
        'RULES',
        'PRO TIPS',
      ];
      var previousY = -1.0;
      for (final heading in headings) {
        final finder = find.text(heading);
        expect(finder, findsOneWidget, reason: heading);
        final y = tester.getTopLeft(finder).dy;
        expect(y, greaterThan(previousY), reason: '$heading is out of order');
        previousY = y;
      }
    });

    testWidgets('the controls split into touch and keyboard', (tester) async {
      await pump(tester);

      expect(find.text('ON YOUR PHONE'), findsOneWidget);
      expect(find.text('ON A KEYBOARD'), findsOneWidget);
      expect(find.text('Arrow keys'), findsOneWidget);
      expect(find.text('Spacebar'), findsOneWidget);
    });

    testWidgets('the pause button is taught and tapping the screen is not', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Pause Button'), findsOneWidget);
      expect(find.text('Tap Screen'), findsNothing);
    });

    testWidgets('Versus explains itself without naming the opponent', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('Online 1v1'), findsOneWidget);
      expect(find.text('Quick Match'), findsOneWidget);
      expect(find.text('Private Room'), findsOneWidget);
    });

    testWidgets('the rules no longer carry their own bullet glyphs', (
      tester,
    ) async {
      // The marker used to live inside the translated string, which put it in
      // the translators' hands and wrapped every second line underneath it.
      await pump(tester);

      final rule = tester.widget<Text>(
        find.text('Eat food to grow and increase score'),
      );
      expect(rule.data, isNot(startsWith('•')));
      expect(rule.data, isNot(startsWith('-')));
    });

    testWidgets('scoring shows what each food is worth', (tester) async {
      await pump(tester);

      expect(find.text('Normal Food'), findsOneWidget);
      expect(find.text('10 points'), findsOneWidget);
      expect(find.text('50 points + Level Up'), findsOneWidget);
    });
  });

  group('it looks like the rest of the app', () {
    testWidgets('the title is uppercase and accent-coloured', (tester) async {
      await pump(tester);

      final title = tester.widget<Text>(find.text('HOW TO PLAY'));
      expect(title.style?.color, GameTheme.classic.accentColor);
      expect(title.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('no card carries a drop shadow any more', (tester) async {
      // The old sections each sat under an accent-tinted shadow, which is the
      // single loudest difference from Settings and Profile.
      await pump(tester);

      // The section cards are the hairline-bordered, 16-radius boxes. Buttons
      // and the background are allowed their own treatment.
      final cards = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where(
            (d) =>
                d.border != null &&
                d.borderRadius == BorderRadius.circular(16),
          )
          .toList();

      expect(cards, hasLength(5), reason: 'five sections are carded');
      for (final card in cards) {
        expect(card.boxShadow ?? const [], isEmpty);
      }
    });

    testWidgets('the back action still pops', (tester) async {
      await pump(tester);
      expect(find.byType(InstructionsScreen), findsOneWidget);

      // Invoked directly rather than tapped: GradientButton's gesture handler
      // constructs AudioService first, which throws without the audio plugin
      // and would swallow the press before it reached the callback. The
      // callback is what this test is about.
      await tester.scrollUntilVisible(find.text('BACK TO GAME'), 300);
      final button = tester.widget<GradientButton>(
        find.byType(GradientButton),
      );
      expect(button.onPressed, isNotNull);
      button.onPressed!();
      await tester.pumpAndSettle();

      expect(
        find.byType(InstructionsScreen),
        findsNothing,
        reason: 'the button leaves the screen, like the app bar arrow',
      );
    });
  });

  group('it survives the screens and text sizes it used to break on', () {
    const screens = <String, Size>{
      'small phone': Size(320, 568),
      'common phone': Size(360, 640),
      'tall phone': Size(393, 852),
      'tablet portrait': Size(834, 1112),
    };

    for (final entry in screens.entries) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('${entry.key} at text scale $scale', (tester) async {
          await pump(tester, size: entry.value, textScale: scale);

          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a long locale does not overflow the controls table', (
      tester,
    ) async {
      // French is the longest of the shipped locales for these labels — "Croix
      // directionnelle à l'écran" is what broke the old fixed-width pill.
      await pump(
        tester,
        size: const Size(320, 568),
        textScale: 1.3,
        locale: const Locale('fr'),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('and neither does an RTL one', (tester) async {
      await pump(
        tester,
        size: const Size(360, 640),
        locale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
      expect(Directionality.of(tester.element(find.byType(SingleChildScrollView))),
          TextDirection.rtl);
    });

    testWidgets('the whole page is reachable by scrolling', (tester) async {
      // Everything below the fold on a short phone still has to be gettable.
      await pump(tester, size: const Size(320, 568));

      await tester.scrollUntilVisible(find.text('PRO TIPS'), 300);

      expect(find.text('PRO TIPS'), findsOneWidget);
    });
  });
}

/// A ThemeCubit that just holds the classic theme. The real one wants a
/// storage service and an analytics facade, and this screen only ever reads
/// `state.currentTheme`.
class _StubThemeCubit extends Cubit<ThemeState> implements ThemeCubit {
  _StubThemeCubit() : super(const ThemeState(currentTheme: GameTheme.classic));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// Likewise for the banner slot's premium lookup.
class _StubPremiumCubit extends Cubit<PremiumState> implements PremiumCubit {
  _StubPremiumCubit() : super(PremiumState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
