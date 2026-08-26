import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

/// How to Play, in the language the rest of the app settled on.
///
/// The screen predated it and showed: every section in a shadowed box with a
/// filled icon pill on its header, every line of body text in the accent
/// colour, and a fixed 140px pill around each control name — which was fine
/// for "Swipe Up" in English and nothing else. "Croix directionnelle à
/// l'écran" wrapped to three lines inside it at ordinary text size, and at a
/// 2.0 accessibility scale the whole reference collapsed into a column of
/// squeezed pills.
///
/// Settings and Profile are the reference: an uppercase accent eyebrow over a
/// hairline-bordered translucent card, one column, monochrome against the
/// active theme, and the accent colour reserved for the things that are
/// actually accents. This screen now reads as part of the same app, and its
/// reference tables lay out as key/value pairs that can wrap.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final theme = state.currentTheme;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          bottomNavigationBar: const SnakeBannerAd(),
          extendBodyBehindAppBar: true,
          appBar: appScreenBar(context, theme, l10n.insHowToPlay),
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: Padding(
                // Same inset as Settings, including the tablet side inset that
                // caps the column at a readable width instead of running
                // reference tables the full width of an iPad.
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0 + context.sideInset(),
                  vertical: 24.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildObjective(context, theme, l10n),
                      const SizedBox(height: 32),
                      _buildControls(context, theme, l10n),
                      const SizedBox(height: 32),
                      _buildVersus(context, theme, l10n),
                      const SizedBox(height: 32),
                      _buildFood(context, theme, l10n),
                      const SizedBox(height: 32),
                      _buildRules(context, theme, l10n),
                      const SizedBox(height: 32),
                      _buildTips(context, theme, l10n),
                      const SizedBox(height: 32),
                      GradientButton(
                        onPressed: () => context.pop(),
                        text: l10n.insBackToGame,
                        primaryColor: theme.accentColor,
                        secondaryColor: theme.primaryColor,
                        icon: Icons.arrow_back,
                        width: double.infinity,
                        height: 48,
                        outlined: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== Sections ====================

  /// The one sentence that has to land, deliberately not in a card.
  ///
  /// Everything below it is reference material a player scans; this is the
  /// answer to "what am I doing", and giving it the same bordered box as the
  /// controls table would flatten it into another row of documentation.
  Widget _buildObjective(
    BuildContext context,
    GameTheme theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow(context, l10n.insObjective, theme),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Text(
            l10n.insObjectiveBody,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(
    BuildContext context,
    GameTheme theme,
    AppLocalizations l10n,
  ) {
    return _section(context, l10n.insControls, theme, Icons.videogame_asset_rounded, 0, [
      _groupLabel(context, l10n.insOnPhone),
      const SizedBox(height: 10),
      _row(l10n.insSwipeUp, l10n.insSwipeUpDesc),
      _row(l10n.insSwipeDown, l10n.insSwipeDownDesc),
      _row(l10n.insSwipeLeft, l10n.insSwipeLeftDesc),
      _row(l10n.insSwipeRight, l10n.insSwipeRightDesc),
      _row(l10n.insDpad, l10n.insDpadDesc),
      // "Tap Screen — Pause/Resume" used to be here, describing a handler the
      // game has never had. The pause button is the real one.
      _row(l10n.insHudPause, l10n.insHudPauseDesc),
      const SizedBox(height: 18),
      _groupLabel(context, l10n.insOnKeyboard),
      const SizedBox(height: 10),
      _row(l10n.insArrowKeys, l10n.insArrowKeysDesc),
      _row(l10n.insWasd, l10n.insWasdDesc),
      _row(l10n.insSpacebar, l10n.insSpacebarDesc),
      const SizedBox(height: 16),
      _footnote(l10n.insControlsNote),
    ]);
  }

  /// Versus. Factual about Quick Match — it finds you an opponent — because
  /// promising a person is a promise the matchmaker does not make.
  Widget _buildVersus(
    BuildContext context,
    GameTheme theme,
    AppLocalizations l10n,
  ) {
    return _section(context, l10n.insVersus, theme, Icons.people_alt_rounded, 1, [
      _row(l10n.insVersusOnline, l10n.insVersusOnlineDesc),
      _row(l10n.insVersusQuick, l10n.insVersusQuickDesc),
      _row(l10n.insVersusRoom, l10n.insVersusRoomDesc),
    ]);
  }

  Widget _buildFood(
    BuildContext context,
    GameTheme theme,
    AppLocalizations l10n,
  ) {
    return _section(context, l10n.insFoodTypes, theme, Icons.restaurant_rounded, 2, [
      _foodRow(l10n.insNormalFood, l10n.insPoints10, theme.foodColor, theme),
      _foodRow(l10n.insBonusFood, l10n.insPoints25, Colors.orange, theme),
      _foodRow(
        l10n.insSpecialFood,
        l10n.insPoints50,
        const Color(0xFFFFD700),
        theme,
      ),
    ]);
  }

  Widget _buildRules(
    BuildContext context,
    GameTheme theme,
    AppLocalizations l10n,
  ) {
    return _section(context, l10n.insRules, theme, Icons.rule_rounded, 3, [
      for (final rule in [
        l10n.insRule1,
        l10n.insRule2,
        l10n.insRule3,
        l10n.insRule4,
        l10n.insRule5,
      ])
        _bulletRow(rule, Colors.white.withValues(alpha: 0.35)),
    ]);
  }

  Widget _buildTips(
    BuildContext context,
    GameTheme theme,
    AppLocalizations l10n,
  ) {
    return _section(context, l10n.insProTips, theme, Icons.lightbulb_rounded, 4, [
      for (final tip in [
        l10n.insTip1,
        l10n.insTip2,
        l10n.insTip3,
        l10n.insTip4,
      ])
        _bulletRow(tip, theme.accentColor.withValues(alpha: 0.8)),
    ]);
  }

  // ==================== Shared pieces ====================

  /// Uppercase accent label above a card. Identical to Settings' section
  /// heading, which is what makes the two screens read as one product.
  /// The objective's heading, which is the only eyebrow here that is not
  /// attached to a card.
  Widget _eyebrow(BuildContext context, String title, GameTheme theme) =>
      screenEyebrow(context, theme, title, icon: Icons.flag_rounded);

  /// One section panel.
  ///
  /// Was a hand-rolled copy of the shell's eyebrow and card — the comment
  /// above it even said it existed so this screen would "read as one product"
  /// with Settings. It now reads as one product because it is built from the
  /// same parts.
  Widget _section(
    BuildContext context,
    String title,
    GameTheme theme,
    IconData icon,
    int index,
    List<Widget> children,
  ) {
    return screenSection(
      context,
      theme,
      title,
      // stretch, not the default centre: a bare Text shrink-wraps, which
      // is how a caption ends up centred under a left-aligned table.
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
      icon: icon,
      index: index,
    );
  }

  /// A quiet heading inside a card, for the two halves of the controls table.
  Widget _groupLabel(BuildContext context, String label) =>
      screenGroupLabel(context, label);

  /// One line of reference: the thing, and what it does.
  ///
  /// Two flexible columns rather than a fixed-width pill and a remainder. The
  /// pill was 140 logical pixels wide whatever went in it, so a long
  /// localized control name wrapped to three lines inside a box built for
  /// one, and large accessibility text had nowhere to go at all. Both sides
  /// wrap now, and the pair still reads as a table.
  Widget _row(String label, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              description,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A food type: its colour, its name, and what it is worth.
  ///
  /// The dot is the only place on this screen where a colour other than the
  /// theme's own appears, and it earns it — that IS the food, exactly as
  /// rendered on the board.
  Widget _foodRow(String name, String points, Color color, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Nudged down to sit on the text's baseline rather than its box.
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              points,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A hanging bullet, so a wrapped line aligns with the text above it rather
  /// than sliding back under the marker. The rules used to carry their own
  /// "• " inside the translated string, which put the marker in the
  /// translators' hands and wrapped every second line under it.
  Widget _bulletRow(String text, Color markerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footnote(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 12.5,
        height: 1.4,
      ),
    );
  }
}
