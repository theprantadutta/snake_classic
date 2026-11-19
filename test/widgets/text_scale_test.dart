import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:refresh_rate/refresh_rate.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/app_localizations_en.dart';
import 'package:snake_classic/presentation/bloc/display/display_state.dart';
import 'package:snake_classic/screens/game_over_screen.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb/lb_game_hud.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_display_panel.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_rows.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_theme_strip.dart';

import 'control_test_harness.dart';

/// The app honours the system text size up to 1.6x (main.dart). These pump
/// the layouts that were fixed-size or single-line at that scale, on a
/// narrow phone and a tablet, and fail on any overflow.
///
/// Home, Settings and Game over are too dependency-heavy to pump whole
/// (DI container, a dozen cubits, Riverpod, ads), so each is represented by
/// the real widgets it is built from: the Settings sections on the real
/// [LBScaffold], Home's destination tiles at their grid size, and the game
/// over score row plus the gameplay HUD bands.

const _phone = Size(360, 780);
const _tablet = Size(800, 1340);

DisplayInfo _info({
  double current = 60,
  List<double> rates = const [60, 90],
  ThermalState thermal = ThermalState.nominal,
}) => DisplayInfo(
  currentRate: current,
  maxRate: rates.reduce((a, b) => a > b ? a : b),
  minRate: rates.reduce((a, b) => a < b ? a : b),
  supportedRates: rates,
  isVariableRefreshRate: false,
  engineTargetRate: current,
  thermalState: thermal,
);

Widget _app(Widget child, {GameTheme theme = GameTheme.classic, double scale = 1.6}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(extensions: [LBPalette.of(theme)]),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );
}

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child, {GameTheme theme = GameTheme.classic}) async {
  await useScreen(tester, size);
  await tester.pumpWidget(_app(child, theme: theme));
  // Not pumpAndSettle: the HUD's tickers repeat forever.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
}

class _SettingsSample extends StatelessWidget {
  const _SettingsSample({required this.display});

  final DisplayState display;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LBScaffold(
      title: l10n.lbSettingsTitle,
      subtitle: l10n.lbSettingsSubtitle,
      banner: false,
      children: [
        SettingsSection(
          label: l10n.lbTheme,
          aside: l10n.lbThemeAside('MIAMI NIGHTS', '5', '6'),
          children: [
            SettingsThemeStrip(
              current: GameTheme.miamiNights,
              isUnlocked: (_) => true,
              onTap: (_) {},
            ),
          ],
        ),
        SettingsSection(
          label: l10n.lbSoundFeel,
          children: [
            SettingsToggleRow(title: l10n.lbSoundFx, subtitle: l10n.lbSoundFxSub, value: true, onChanged: (_) {}),
            SettingsToggleRow(
              title: settingsHighRefreshTitle(l10n, display),
              subtitle: display.isSingleRate ? l10n.settingsHighRefreshUnavailable : l10n.lb120HzSub,
              value: false,
              onChanged: display.deviceSupportsHighRate ? (_) {} : null,
            ),
            SettingsNote(text: l10n.settingsDisplayThermalNote, icon: LBIcon.flame),
          ],
        ),
        SettingsSection(
          label: l10n.lbGameplay,
          children: [
            SettingsValueRow(title: l10n.lbMode, value: 'CLASSIC', onTap: () {}),
            SettingsValueRow(
              title: l10n.lbDifficulty,
              subtitle: l10n.settingsEasyNote,
              value: 'EASY',
              onTap: () {},
            ),
            SettingsOptionStrip<String>(
              options: const ['left', 'center', 'right'],
              selected: 'center',
              labelOf: (s) => s,
              onSelect: (_) {},
            ),
          ],
        ),
        SettingsSection(
          label: l10n.settingsSectionDisplay,
          children: [SettingsDisplayPanel(display: display)],
        ),
        SettingsFooterLinks(links: [(l10n.lbPrivacy, () {})], version: 'v7.7.0'),
      ],
    );
  }
}

class _HomeTiles extends StatelessWidget {
  const _HomeTiles();

  @override
  Widget build(BuildContext context) {
    final cell = context.lbCell;
    final half = (MediaQuery.sizeOf(context).width - context.lbGutter * 2) / 2;
    Widget tile(String title, String sub, {required bool tall}) => SizedBox(
      width: half,
      height: cell * (tall ? 4 : 3),
      child: HomeTileForTest(icon: LBIcon.swords, title: title, subtitle: sub, onTap: () {}, tall: tall),
    );
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tall in [false, true])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tile(l10n.lbHomeVersus, l10n.lbHomeVersusSub('1,240'), tall: tall),
                  tile(l10n.lbHomeVersus, l10n.lbHomeVersusSubOffline, tall: tall),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _GameOverAndHud extends StatelessWidget {
  const _GameOverAndHud();

  @override
  Widget build(BuildContext context) {
    final gs = playingState(length: 12).copyWith(score: 1840, level: 12, currentCombo: 4);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LBGameTopBar(gameState: gs, onPause: () {}),
            LBGameInfoRow(gameState: gs),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
              child: const GameOverScoreRowForTest(score: 1840, best: 3200, isNewBest: false),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
              child: const GameOverScoreRowForTest(score: 3300, best: 3300, isNewBest: true),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  final multiRate = DisplayState(loaded: true, info: _info());
  final singleRate = DisplayState(loaded: true, info: _info(rates: const [60]));

  for (final (name, size) in [('phone 360x780', _phone), ('tablet 800x1340', _tablet)]) {
    group('1.6x text on $name', () {
      testWidgets('Settings sections fit (multi-rate panel)', (tester) async {
        await _pumpAt(tester, size, _SettingsSample(display: multiRate));
        // Scroll the whole page through: rows below the fold lay out too.
        await tester.drag(find.byType(ListView).first, const Offset(0, -4000));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Settings sections fit (single-rate panel, Miami Nights)', (tester) async {
        await _pumpAt(tester, size, _SettingsSample(display: singleRate), theme: GameTheme.miamiNights);
        await tester.drag(find.byType(ListView).first, const Offset(0, -4000));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Home tiles fit their grid rows', (tester) async {
        await _pumpAt(tester, size, const _HomeTiles());
      });

      testWidgets('Game over score row and HUD bands fit', (tester) async {
        await _pumpAt(tester, size, const _GameOverAndHud());
      });
    });
  }

  group('theme strip', () {
    testWidgets('every swatch is a 48 dp target and the selected one is in view', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpAt(
        tester,
        _phone,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Center(
              child: SettingsThemeStrip(
                current: GameTheme.values.last,
                isUnlocked: (_) => true,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // Miami Nights is last by rule (themes are stored by index), so on a
      // phone it starts off-screen unless the strip scrolls to it.
      final swatch = find.bySemanticsLabel(RegExp('Miami', caseSensitive: false));
      expect(swatch, findsOneWidget);
      final rect = tester.getRect(swatch);
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      expect(rect.right, lessThanOrEqualTo(_phone.width));
      semantics.dispose();
    });
  });

  group('high refresh label', () {
    final l10n = AppLocalizationsEn();

    test('names the panel\'s real top rate', () {
      expect(settingsHighRefreshTitle(l10n, multiRate), '90 HZ');
      final r120 = DisplayState(loaded: true, info: _info(rates: const [60, 119.88]));
      expect(settingsHighRefreshTitle(l10n, r120), '120 HZ');
    });

    test('falls back to a generic label when unknown or single-rate', () {
      expect(settingsHighRefreshTitle(l10n, const DisplayState()), l10n.lbHighRefreshRateGeneric);
      expect(settingsHighRefreshTitle(l10n, singleRate), l10n.lbHighRefreshRateGeneric);
    });
  });

  group('thermal notice', () {
    DisplayState at(ThermalState t) => DisplayState(loaded: true, info: _info(thermal: t));

    test('stays hidden while the device is nominal or merely fair', () {
      expect(at(ThermalState.nominal).throttledByHeat, isFalse);
      expect(at(ThermalState.fair).throttledByHeat, isFalse);
      expect(at(ThermalState.unknown).throttledByHeat, isFalse);
      expect(const DisplayState().throttledByHeat, isFalse);
    });

    test('shows from serious up', () {
      expect(at(ThermalState.serious).throttledByHeat, isTrue);
      expect(at(ThermalState.critical).throttledByHeat, isTrue);
    });
  });
}
