import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_step.dart';

/// Defines the walkthrough steps for the home screen
class HomeWalkthrough {
  /// GlobalKeys for target widgets on the home screen
  /// These need to be assigned to the corresponding widgets in HomeScreen
  static final playButtonKey = GlobalKey();
  static final coinsKey = GlobalKey();
  static final dailyChallengesKey = GlobalKey();
  static final storeKey = GlobalKey();
  static final profileKey = GlobalKey();
  static final settingsKey = GlobalKey();
  /// Cosmetics nav item (skins + trails).
  static final cosmeticsKey = GlobalKey();

  /// Versus call-to-action, directly under the Play button.
  static final versusKey = GlobalKey();

  /// The help ("?") button in the top navigation.
  static final helpKey = GlobalKey();

  /// The tour, cut from seven steps to three.
  ///
  /// It used to walk a first-session player through Coins, Daily Challenges,
  /// Store, Cosmetics, Profile and Settings — six screens of metagame for
  /// someone who had played once — and then hand off to a daily-bonus dialog
  /// and a notification permission ask in the same visit. That is the stacked
  /// interruption the play-first redesign existed to remove, rebuilt inside
  /// the tour.
  ///
  /// What is left is what a player cannot discover by looking: that there is
  /// a second mode, that today's challenges are worth a look, and where the
  /// rules live. Store, cosmetics and profile are visible on the screen and
  /// can be found by anyone curious enough to tap them.
  static List<WalkthroughStep> getSteps(AppLocalizations l10n) {
    return [
      // Step 1: Versus. First on purpose — it is the least discoverable
      // thing in the app and the reason the tour was re-cut.
      WalkthroughStep(
        id: 'home_versus',
        title: l10n.hwVersusTitle,
        message: l10n.hwVersusMsg,
        targetKey: versusKey,
        position: TooltipPosition.above,
        icon: Icons.sports_esports,
        spotlightPadding: 8,
        spotlightBorderRadius: 20,
      ),

      // Step 2: Daily Challenges — a reason to come back tomorrow.
      WalkthroughStep(
        id: 'home_daily',
        title: l10n.hwDailyTitle,
        message: l10n.hwDailyMsg,
        targetKey: dailyChallengesKey,
        position: TooltipPosition.above,
        icon: Icons.calendar_today,
        spotlightPadding: 6,
        spotlightBorderRadius: 18,
      ),

      // Step 3: Help — rules, controls and Versus, with Settings beside it.
      WalkthroughStep(
        id: 'home_help',
        title: l10n.hwHelpTitle,
        message: l10n.hwHelpMsg,
        targetKey: helpKey,
        position: TooltipPosition.below,
        icon: Icons.help_outline,
        spotlightPadding: 8,
        spotlightBorderRadius: 20,
        actionLabel: l10n.wtStartPlaying,
      ),
    ];
  }
}
