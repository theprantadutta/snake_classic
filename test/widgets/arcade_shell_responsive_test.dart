import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/arcade_controls.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/widgets/settings_category_rail.dart';

/// The arcade HUD language, laid out.
///
/// The panels, the throw switch, the option chips, the link rows and the
/// category rail replaced a screen made of Material `Switch`es and plain
/// boxes. Every one of them carries fixed pixel sizes multiplied by
/// `context.uiScale`, which is exactly the kind of arithmetic that looks right
/// on the phone it was written on and clips on an iPad at large text.
///
/// So these run the whole vocabulary across the four screens the app ships to
/// and the text scales it can actually reach. The real ceiling is 1.42 — the
/// root MediaQuery multiplies a large tablet's 1.18 base bump by the OS
/// accessibility factor, which is clamped to 1.2 — and 2.0 is here as margin.
void main() {
  /// Every control in the language, in one panel, so an overflow anywhere
  /// fails the test rather than depending on which screen happens to use it.
  Widget vocabulary(
    BuildContext context,
    GameTheme theme,
    ScrollController controller,
  ) {
    final categories = [
      for (final label in ['CONTROLS', 'GAMEPLAY', 'AUDIO', 'NOTIFICATIONS'])
        SettingsCategory(
          label: label,
          icon: Icons.videogame_asset_rounded,
          key: GlobalKey(),
        ),
    ];

    return Column(
      children: [
        SettingsCategoryRail(
          categories: categories,
          bodyController: controller,
          theme: theme,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                screenSection(
                  context,
                  theme,
                  'CONTROLS',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ArcadeSwitchTile(
                        title: 'D-Pad Controls',
                        description:
                            'Show on-screen directional buttons during gameplay',
                        value: true,
                        onChanged: (_) {},
                        theme: theme,
                      ),
                      ArcadeSwitchTile(
                        title: 'Smooth Motion',
                        description:
                            'Use the highest refresh rate this screen supports',
                        value: false,
                        enabled: false,
                        onChanged: (_) {},
                        theme: theme,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final label in ['Easy', 'Normal', 'Hard'])
                            ArcadeOptionChip(
                              label: label,
                              sublabel: 'starting speed',
                              leading: '🐍',
                              selected: label == 'Normal',
                              theme: theme,
                              onTap: () {},
                            ),
                        ],
                      ),
                      ArcadeLinkTile(
                        label: 'Statistics',
                        description: 'Everything you have done so far',
                        icon: Icons.analytics,
                        onTap: () {},
                        theme: theme,
                      ),
                    ],
                  ),
                  icon: Icons.videogame_asset_rounded,
                  index: 0,
                ),
                const SizedBox(height: 32),
                screenSection(
                  context,
                  theme,
                  'YOUR GAME',
                  screenKeyValue('Best score', '12,480'),
                  icon: Icons.insights_rounded,
                  index: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    GameTheme theme = GameTheme.classic,
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              // Builder so the widgets under test get a context that already
              // has the MediaQuery above — which is where uiScale and the
              // text scaler come from.
              body: Builder(
                builder: (context) => vocabulary(context, theme, controller),
              ),
            ),
          ),
        ),
      ),
    );
    // pumpAndSettle, not pump: the panels opt into the staggered entrance,
    // which schedules a delay timer per section. A bare pump leaves those
    // pending and the binding fails the test on teardown before it ever gets
    // to look at the layout.
    await tester.pumpAndSettle();
  }

  group('the language holds its shape on every screen it ships to', () {
    // uiScale keys off shortestSide: >=600 is a tablet, >=840 a large one.
    // One size either side of each boundary, so a branch that is a no-op on
    // phones stays that way.
    const screens = <String, Size>{
      'small phone': Size(320, 568),
      'common phone': Size(390, 844),
      'tablet portrait': Size(834, 1112),
      'large tablet portrait': Size(1024, 1366),
    };

    for (final entry in screens.entries) {
      // 1.42 is the real ceiling; 2.0 is margin beyond what the app allows.
      for (final scale in [1.0, 1.2, 1.42, 2.0]) {
        testWidgets('${entry.key} at text scale $scale', (tester) async {
          await pump(tester, size: entry.value, textScale: scale);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('and in RTL, where the switch throw reverses', (tester) async {
      await pump(
        tester,
        size: const Size(320, 568),
        textScale: 1.42,
        direction: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a rebuild does not replay the entrance', (tester) async {
      // Settings rebuilds its whole tree on every toggle. If the panels
      // re-ran their staggered fade each time, flipping one switch would make
      // the entire screen blink — which is worse than having no entrance at
      // all, and is the failure mode opting into `index` invites.
      final rebuild = ValueNotifier<bool>(false);
      addTearDown(rebuild.dispose);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: rebuild,
              builder: (context, _, _) => screenSection(
                context,
                GameTheme.classic,
                'CONTROLS',
                const SizedBox(height: 40),
                icon: Icons.videogame_asset_rounded,
                index: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      double minOpacity() => tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .map((f) => f.opacity.value)
          .fold<double>(1.0, (a, b) => a < b ? a : b);

      expect(minOpacity(), 1.0, reason: 'the entrance finished');

      // Flip the notifier the way a toggle would, and look at the very next
      // frame — a replayed entrance is at its lowest right after it starts.
      rebuild.value = true;
      await tester.pump();
      expect(
        minOpacity(),
        1.0,
        reason: 'the panel stayed put through the rebuild',
      );

      await tester.pump(const Duration(milliseconds: 16));
      expect(minOpacity(), 1.0);
    });

    testWidgets('on every theme, including the bright ones', (tester) async {
      // The selected states lean on an accent wash and a glow. Crystal and
      // desert are the pale accents those were tuned against, so a rendering
      // failure specific to them should not wait for a user to find it.
      for (final theme in GameTheme.values) {
        await pump(
          tester,
          size: const Size(390, 844),
          textScale: 1.0,
          theme: theme,
        );
        expect(tester.takeException(), isNull, reason: theme.name);
      }
    });
  });
}
