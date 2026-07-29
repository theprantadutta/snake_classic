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

  /// Get the list of walkthrough steps
  /// Call this after the keys have been assigned to their widgets
  static List<WalkthroughStep> getSteps(AppLocalizations l10n) {
    return [
      // Step 1: Welcome and Play Button
      WalkthroughStep(
        id: 'home_play',
        title: l10n.hwPlayTitle,
        message: l10n.hwPlayMsg,
        targetKey: playButtonKey,
        position: TooltipPosition.above,
        icon: Icons.play_arrow_rounded,
        spotlightPadding: 12,
        spotlightBorderRadius: 100, // Circular button
      ),

      // Step 2: Coins Display
      WalkthroughStep(
        id: 'home_coins',
        title: l10n.hwCoinsTitle,
        message: l10n.hwCoinsMsg,
        targetKey: coinsKey,
        position: TooltipPosition.below,
        icon: Icons.monetization_on,
        spotlightPadding: 8,
        spotlightBorderRadius: 20,
      ),

      // Step 3: Daily Challenges
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

      // Step 4: Store
      WalkthroughStep(
        id: 'home_store',
        title: l10n.hwStoreTitle,
        message: l10n.hwStoreMsg,
        targetKey: storeKey,
        position: TooltipPosition.above,
        icon: Icons.store,
        spotlightPadding: 6,
        spotlightBorderRadius: 14,
      ),

      // Step 5: Cosmetics
      WalkthroughStep(
        id: 'home_cosmetics',
        title: l10n.hwCosmeticsTitle,
        message: l10n.hwCosmeticsMsg,
        targetKey: cosmeticsKey,
        position: TooltipPosition.above,
        icon: Icons.palette,
        spotlightPadding: 6,
        spotlightBorderRadius: 14,
      ),

      // Step 7: Profile
      WalkthroughStep(
        id: 'home_profile',
        title: l10n.hwProfileTitle,
        message: l10n.hwProfileMsg,
        targetKey: profileKey,
        position: TooltipPosition.below,
        icon: Icons.account_circle,
        spotlightPadding: 8,
        spotlightBorderRadius: 20,
      ),

      // Step 8: Settings
      WalkthroughStep(
        id: 'home_settings',
        title: l10n.hwSettingsTitle,
        message: l10n.hwSettingsMsg,
        targetKey: settingsKey,
        position: TooltipPosition.below,
        icon: Icons.settings,
        spotlightPadding: 8,
        spotlightBorderRadius: 20,
        actionLabel: l10n.wtStartPlaying,
      ),
    ];
  }
}
