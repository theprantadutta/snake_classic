// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsSectionLanguage => 'LANGUAGE';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageSystemDefaultSubtitle => 'Follow your device language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get mpOpponent => 'Opponent';

  @override
  String get mpTimeUpDraw => 'Time\'s up — dead even!';

  @override
  String get mpTimeUpYouWon => 'Time\'s up — you had the higher score.';

  @override
  String get mpTimeUpYouLost =>
      'Time\'s up — your opponent had the higher score.';

  @override
  String get mpMutualCrashDraw => 'Both snakes crashed — it\'s a tie!';

  @override
  String get mpMutualCrashYouWon =>
      'Both snakes crashed — your score decided it.';

  @override
  String get mpMutualCrashYouLost =>
      'Both snakes crashed — their score decided it.';

  @override
  String get mpMatchCancelled => 'The match was cancelled.';

  @override
  String get mpLastSnakeStanding =>
      'Your opponent crashed. Last snake standing!';

  @override
  String get mpDeathWall => 'You crashed into the wall.';

  @override
  String get mpDeathSelf => 'You crashed into yourself.';

  @override
  String get mpDeathOpponent => 'You crashed into your opponent.';

  @override
  String get mpDeathHeadOn => 'Head-on collision!';

  @override
  String get mpDeathForfeit => 'Disconnected too long — match forfeited.';

  @override
  String get mpBetterLuck => 'Better luck next time!';

  @override
  String get mpRewardProcessing => 'Rewards processing…';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count coins',
      one: '+$count coin',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Leave Game?';

  @override
  String get mpLeaveGameBody =>
      'The match keeps running on the server — leaving forfeits it.';

  @override
  String get mpLeave => 'Leave';

  @override
  String get mpReconnecting => 'RECONNECTING…';

  @override
  String get mpReconnectingBody => 'The match is still running on the server.';

  @override
  String get mpGetReady => 'GET READY';

  @override
  String get mpDroppingIntoArena => 'Dropping you into the arena…';

  @override
  String get mpWaitingPlayer => 'Waiting…';

  @override
  String get mpOut => 'OUT';

  @override
  String get mpLength => 'LENGTH';

  @override
  String get mpReconnectingInline => 'reconnecting…';

  @override
  String get puSpeedBoost => 'Speed Boost';

  @override
  String get puInvincibility => 'Invincibility';

  @override
  String get puScoreMultiplier => 'Score Multiplier';

  @override
  String get puSlowMotion => 'Slow Motion';

  @override
  String get homeNoAdReady =>
      'No ad ready just yet — try again in a few seconds.';

  @override
  String get homeFreeSpeedBoostTitle => 'Free Speed Boost';

  @override
  String get homeFreeSpeedBoostBody =>
      'Watch a short ad to add a free Speed Boost power-up to your loadout. It activates 5 seconds into your next game.';

  @override
  String get homeNotNow => 'Not now';

  @override
  String get homeWatchAd => 'Watch ad';

  @override
  String get homeFreeSpeedBoostAdded =>
      'Free Speed Boost added to your loadout!';

  @override
  String get homeAdNotFinished =>
      'Ad not finished — watch the full ad to earn your reward.';

  @override
  String get homeStartPlaying => 'START PLAYING';

  @override
  String get settingsSectionVisual => 'VISUAL';

  @override
  String get settingsSectionNotifications => 'NOTIFICATIONS';

  @override
  String get settingsSectionUserProfile => 'USER PROFILE';

  @override
  String get settingsSectionHelp => 'HELP & TUTORIAL';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get settingsSectionPremium => 'PREMIUM FEATURES';

  @override
  String get settingsSnapMovement => 'Snap Movement';

  @override
  String get settingsSnapMovementSubtitle =>
      'Move cell by cell like the original. Turns land the instant you press.';

  @override
  String get gameTurnLeft => 'Turn left';

  @override
  String get gameTurnRight => 'Turn right';

  @override
  String get gameTurnControls => 'Turn buttons';

  @override
  String get gameJoystick => 'Joystick';

  @override
  String get gameJoystickHint => 'Push to steer';

  @override
  String get wtControlOptionsTitle => 'Not a swiper?';

  @override
  String get wtControlOptionsMsg =>
      'Prefer buttons? Pause and pick a D-Pad, two big Turn buttons, or a floating Joystick. Turn on Snap Movement if you want every turn to land the instant you press. All of it lives in Settings → Controls too.';

  @override
  String get insTurnButtons => 'Turn Buttons';

  @override
  String get insTurnButtonsDesc =>
      'Two big buttons, one per corner: turn left, turn right. Never a reversal';

  @override
  String get insJoystick => 'Joystick';

  @override
  String get insJoystickDesc =>
      'Push anywhere in the bar toward where you want to go; keep pressing to keep steering';

  @override
  String get insSnap => 'Snap Movement';

  @override
  String get insSnapDesc =>
      'Move cell by cell like the original, so turns land the instant you press';

  @override
  String get settingsOnScreenControls => 'On-Screen Controls';

  @override
  String get settingsOnScreenControlsDesc =>
      'D-Pad, Turn buttons or Joystick — pick under Button Layout';

  @override
  String get settingsDPadPosition => 'D-Pad Position';

  @override
  String get settingsDesktopControls => 'Desktop/Web Controls';

  @override
  String get settingsArrowKeys => 'Arrow Keys';

  @override
  String get settingsWasdKeys => 'WASD Keys';

  @override
  String get settingsSpacebar => 'Spacebar';

  @override
  String get settingsMouseClick => 'Mouse Click';

  @override
  String get settingsChangeDirection => 'Change direction';

  @override
  String get settingsPauseResume => 'Pause/Resume game';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Touch Controls (if available)';

  @override
  String get settingsTouchControls => 'Touch Controls';

  @override
  String get settingsSwipeGestures => 'Swipe Gestures';

  @override
  String get settingsTapScreen => 'Tap Screen';

  @override
  String get settingsSwipeUp => 'Swipe Up ↑';

  @override
  String get settingsSwipeDown => 'Swipe Down ↓';

  @override
  String get settingsSwipeLeft => 'Swipe Left ←';

  @override
  String get settingsSwipeRight => 'Swipe Right →';

  @override
  String get settingsMoveSnakeUp => 'Move snake up';

  @override
  String get settingsMoveSnakeDown => 'Move snake down';

  @override
  String get settingsMoveSnakeLeft => 'Move snake left';

  @override
  String get settingsMoveSnakeRight => 'Move snake right';

  @override
  String get settingsGameModeLocked =>
      'Complete current game to change game mode';

  @override
  String get settingsEasyNote =>
      'Coins, XP and achievements still count on Easy — only high scores and leaderboards are paused.';

  @override
  String get settingsDifficultyLocked =>
      'Finish your current game to change difficulty.';

  @override
  String get settingsBoardSizeLocked =>
      'Complete current game to change board size';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'How long to show crash explanation';

  @override
  String get settingsScreenShake => 'Screen Shake';

  @override
  String get settingsScreenShakeSubtitle =>
      'Shake the screen on collisions and game events';

  @override
  String get settingsBrowseThemes => 'BROWSE THEMES';

  @override
  String get settingsSnakeTrail => 'Snake Trail Effects';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Enable particle trails behind the snake';

  @override
  String get settingsSectionDisplay => 'DISPLAY';

  @override
  String get settingsDisplayHz => 'Hz';

  @override
  String settingsDisplayUpTo(String rate) {
    return 'up to $rate Hz';
  }

  @override
  String get settingsDisplayReading => 'Reading your display…';

  @override
  String get settingsDisplayCurrentCaption =>
      'What your screen is refreshing at right now.';

  @override
  String get settingsDisplayBatteryNote =>
      'Battery saver is on, so your display may stay at its standard rate until you turn it off.';

  @override
  String get settingsDisplayThermalNote =>
      'Your device is warm. It may hold a lower rate for a while to cool down, which is normal.';

  @override
  String get settingsDisplaySingleRateNote =>
      'This screen runs at a single refresh rate, so there is nothing to unlock here. The game is already as smooth as it gets on this device.';

  @override
  String get settingsDisplayFooter =>
      'Higher refresh rates make the snake and menus feel smoother, and use a little more battery. Snake Classic leaves this on by default and never overrides your device\'s power saving.';

  @override
  String get settingsDisplaySupportedTitle => 'THIS DISPLAY';

  @override
  String get settingsNotifDailyReminder => 'Daily Reminder';

  @override
  String get settingsNotifTournament => 'Tournament Alerts';

  @override
  String get settingsNotifAchievement => 'Achievement Unlocks';

  @override
  String get settingsNotifSocial => 'Social Updates';

  @override
  String get settingsNotifSpecialEvents => 'Special Events';

  @override
  String get settingsNotSet => 'Not set';

  @override
  String get settingsUsername => 'Username';

  @override
  String get settingsGuestAccount => 'Guest Account';

  @override
  String get accountSwitchTitle => 'Sign in to an existing account?';

  @override
  String get accountSwitchBody =>
      'If this account has already played Snake Classic, its progress is restored and becomes the one you keep. Coins, scores and stats from this device do not transfer.\n\nTo keep this device\'s progress instead, use an account you haven\'t played with before.';

  @override
  String get accountSwitchConfirm => 'Sign in anyway';

  @override
  String get settingsAuthenticatedAccount => 'Authenticated Account';

  @override
  String get accountNotBackedUpTitle => 'Not backed up';

  @override
  String get accountNotBackedUpBody =>
      'This progress is tied to this install. Sign in so you can get it back after reinstalling or on a new phone.';

  @override
  String get settingsChangeUsername => 'CHANGE USERNAME';

  @override
  String get settingsGuestSignInHint =>
      'Sign in to keep your progress and play with friends';

  @override
  String get settingsUsernameVisibleHint =>
      'Your username is visible to friends and on leaderboards';

  @override
  String get settingsReplayTutorial => 'REPLAY TUTORIAL';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Watch the home tour or game tutorial again';

  @override
  String get settingsAboutCredits => 'ABOUT & CREDITS';

  @override
  String get settingsAboutCreditsSubtitle => 'App version, credits, and links';

  @override
  String get settingsRateApp => 'RATE SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'Enjoying the game? Leave a review on the App Store';

  @override
  String get settingsRateAppSubtitle => 'Enjoying the game? Leave us a review!';

  @override
  String get settingsAdPrivacy => 'PRIVACY & AD CHOICES';

  @override
  String get settingsAdPrivacySubtitle => 'Manage personalized ad consent';

  @override
  String get settingsAdPrivacyUnavailable =>
      'Ad privacy options aren\'t available right now.';

  @override
  String get settingsReplayDialogTitle => 'Replay Tutorial';

  @override
  String get settingsReplayDialogBody =>
      'Which tutorial would you like to replay?';

  @override
  String get settingsHomeTour => 'Home Tour';

  @override
  String get settingsGameTutorial => 'Game Tutorial';

  @override
  String get settingsPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicyButton => 'PRIVACY POLICY';

  @override
  String get settingsTermsTitle => 'Terms of Use';

  @override
  String get settingsTermsButton => 'TERMS OF USE';

  @override
  String get legalAutoRenewDisclosureAppStore =>
      'Payment is charged to your App Store account at confirmation of purchase. The subscription automatically renews for the same price and duration unless it is cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your account settings after purchase.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'Payment is charged to your Google Play account at confirmation of purchase. The subscription automatically renews for the same price and duration unless it is cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your Google Play subscription settings after purchase.';

  @override
  String get legalTermsEulaLink => 'Terms of Use (EULA)';

  @override
  String get settingsChangeUsernameTitle => 'Change Username';

  @override
  String get settingsCurrentLabel => 'Current:';

  @override
  String get settingsUsernameDialogBody =>
      'Choose a unique username that represents you in the game.';

  @override
  String get settingsEnterNewUsername => 'Enter new username';

  @override
  String get settingsUsernameRules =>
      '• 3-20 characters\n• Must start with a letter\n• Letters, numbers, and underscores only';

  @override
  String get settingsUsernameUpdateFailed => 'Failed to update username';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Username updated to \"$name\"';
  }

  @override
  String get settingsUpdate => 'Update';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Premium Status';

  @override
  String get settingsActiveSubscription => 'Active subscription';

  @override
  String get settingsUnlockPremium => 'Unlock premium features';

  @override
  String settingsRenews(String date) {
    return 'Renews $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Upgrade to Pro';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsPurchaseHistory => 'Purchase History';

  @override
  String get settingsSnakeCosmetics => 'Snake Cosmetics';

  @override
  String get settingsBattlePass => 'Battle Pass';

  @override
  String settingsTier(int tier) {
    return 'Tier $tier';
  }

  @override
  String get settingsRestoring => 'Restoring purchases...';

  @override
  String get settingsRestored => 'Purchases restored successfully!';

  @override
  String get settingsRestoreFailed =>
      'Failed to restore purchases. Please try again.';

  @override
  String get settingsNoPurchases => 'No purchases found';

  @override
  String get settingsUnknown => 'Unknown';

  @override
  String settingsStatusLine(String status) {
    return 'Status: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'Date: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'Purchase #$number';
  }

  @override
  String get settingsDataParseError => 'Data parsing error';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsHistoryLoadFailed => 'Failed to load purchase history';

  @override
  String get settingsUnknownDate => 'Unknown date';

  @override
  String get mpLobbyNoFriends =>
      'No friends yet — add some from the Friends screen!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Invite a friend to room $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 Invite sent to $name!';
  }

  @override
  String get mpLobbyInviteFailed => 'Could not send the invite — try again';

  @override
  String get mpLobbyOffline =>
      'You\'re offline. Multiplayer requires an internet connection.';

  @override
  String get mpLobbyGo => 'GO!';

  @override
  String get mpLobbyGetReady => 'Get Ready!';

  @override
  String get mpLobbyRoomCodeCopied => 'Room code copied!';

  @override
  String get mpLobbyFinding => 'FINDING...';

  @override
  String get mpLobbySearching => 'SEARCHING FOR PLAYERS...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Players',
      one: '$count Player',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Queue Position: $position';
  }

  @override
  String get mpLobbyConnectionLostTitle => 'CONNECTION LOST';

  @override
  String get mpLobbyConnectionLostBody =>
      'Your connection dropped while we were searching.\nCheck Wi-Fi or mobile data and try again.';

  @override
  String get mpLobbyTimedOutTitle => 'NO MATCH YET';

  @override
  String get mpLobbyTimedOutBody =>
      'This search ran longer than it should have.\nTry again — matches usually take under a minute.';

  @override
  String get mpLobbyWaitingForConnection =>
      'Connection lost — waiting to reconnect…';

  @override
  String get mpLobbyUnreachableTitle => 'CAN\'T REACH MATCHMAKING';

  @override
  String get mpLobbyUnreachableBody =>
      'We couldn\'t reach the server.\nCheck your connection and try again.';

  @override
  String get mpLobbyGoBack => 'GO BACK';

  @override
  String get mpLobbyTryAgain => 'TRY AGAIN';

  @override
  String get mpLobbyJoinRoom => 'JOIN ROOM';

  @override
  String get mpLobbyEnterRoomCode => 'Enter room code';

  @override
  String get mpLobbyWaitingForPlayer => 'Waiting for player...';

  @override
  String get mpLobbyStartGame => 'START GAME';

  @override
  String get mpLobbyWaitingForHost => 'Waiting for host to start...';

  @override
  String get mpLobbyReadyDone => 'READY!';

  @override
  String get mpModeClassicDesc => 'Traditional Snake battle';

  @override
  String get mpModeSpeedDesc => 'Speed increases over time';

  @override
  String get mpModeSurvivalDesc => 'Last snake standing wins';

  @override
  String get mpModePowerUpDesc => 'Power-ups everywhere!';

  @override
  String get mpStatusWaiting => 'Waiting';

  @override
  String get mpStatusReady => 'Ready';

  @override
  String get mpStatusPlaying => 'Playing';

  @override
  String get mpStatusCrashed => 'Crashed';

  @override
  String get mpStatusDisconnected => 'Disconnected';

  @override
  String get goNoAdAvailable => 'No ad available right now, try again shortly';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Coins doubled — +$count bonus coins!';
  }

  @override
  String goAdBonusCoins(Object count) {
    return '🎉 +$count bonus coins for watching!';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'Claimed $count coins from daily challenges!';
  }

  @override
  String get goRibbonTournamentSubmitted => 'TOURNAMENT SCORE SUBMITTED!';

  @override
  String get goRibbonTournamentFailed =>
      'SCORE NOT SUBMITTED — CHECK CONNECTION';

  @override
  String get goRibbonTournamentSubmitting => 'SUBMITTING TOURNAMENT SCORE…';

  @override
  String goAdNoticeRewarded(Object count) {
    return 'Short ad next · +$count coins for watching';
  }

  @override
  String get goAdNoticeInterstitial => 'A short ad plays next';

  @override
  String get adBreakStarting => 'Ad starting…';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Coins';

  @override
  String get storeTabThemes => 'Themes';

  @override
  String get storeTabSkins => 'Skins';

  @override
  String get storeTabTrails => 'Trails';

  @override
  String get storeTabPowerUps => 'Power-Ups';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return '${multiplier}x BONUS';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Subscribe before your free Pro ends';

  @override
  String get storeMonthly => 'Monthly';

  @override
  String get storeYearly => 'Yearly';

  @override
  String get storePerMonth => '/month';

  @override
  String get storePerYear => '/year';

  @override
  String storeFreeTrialBadge(Object days) {
    return '$days-day free trial';
  }

  @override
  String get storeStartFreeTrial => 'Start free trial';

  @override
  String storePlanDisplayName(Object title) {
    return '$title plan';
  }

  @override
  String get storeVerifyingEllipsis => 'Verifying…';

  @override
  String get storeYoureOnFreePro => 'You\'re on free Pro!';

  @override
  String get storeFreePro => 'Free Pro';

  @override
  String get storeProMonthly => 'Pro Monthly';

  @override
  String get storeKeepPro => 'Keep Pro — Subscribe';

  @override
  String get storePromoBadge => 'PROMO';

  @override
  String get storeEndingSoon => 'Ending soon';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Ends in ${days}d ${hours}h';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Ends in ${hours}h ${minutes}m';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Ends in ${minutes}m';
  }

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Initiating $name purchase...';
  }

  @override
  String get storeSubNotAvailable =>
      'Subscription not available. Please try again later.';

  @override
  String get storePurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get storePurchasePending =>
      'Payment pending. Your purchase will unlock once the store confirms it.';

  @override
  String get storeBuyCoins => 'Buy Snake Coins';

  @override
  String get storeEarnFreeCoins => 'Earn Free Coins';

  @override
  String get storeEarnPlay => 'Play a Game';

  @override
  String get storeEarnPlayReward => '5 coins per game';

  @override
  String get storeEarnDaily => 'Daily Login';

  @override
  String get storeEarnDailyReward => '10-50 coins daily';

  @override
  String get storeEarnAchievements => 'Achievements';

  @override
  String get storeEarnAchievementsReward => '25-100 coins';

  @override
  String get storeEarnTournaments => 'Tournaments';

  @override
  String get storeEarnTournamentsReward => '100+ coins';

  @override
  String get storePopularBadge => 'POPULAR';

  @override
  String storeBuyItem(Object name) {
    return 'Buy $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'Purchase $coins for $price?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'Buy - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'Initiating purchase for $name...';
  }

  @override
  String get storeProductNotAvailable =>
      'Product not available. Please try again later.';

  @override
  String get storeUnlockedWithPro => 'Unlocked with Pro';

  @override
  String get storeIncludedWithPro => 'Included with Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned =>
      'Every theme here is yours with your subscription.';

  @override
  String get storeProBannerThemesUpsell =>
      'Subscribe to Pro to unlock every theme here — no separate purchase needed.';

  @override
  String get storeProBannerSkinsOwned =>
      'Every skin here is yours with your subscription.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Subscribe to Pro to unlock every skin here — no separate purchase needed.';

  @override
  String get storeProBannerTrailsOwned =>
      'Every trail here is yours with your subscription.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Subscribe to Pro to unlock every trail here — no separate purchase needed.';

  @override
  String get storePremiumThemes => 'Premium themes';

  @override
  String get storeFreeThemes => 'Free themes';

  @override
  String get storeFreeThemesSubtitle =>
      'Always available — switch back any time.';

  @override
  String get storeAllThemesBundle => 'All Themes Bundle';

  @override
  String get storeAllThemesBundleSubtitle => 'All 6 premium themes · save 33%';

  @override
  String get storePillVerifying => 'VERIFYING';

  @override
  String get storePillOwned => 'OWNED';

  @override
  String get storePillFree => 'FREE';

  @override
  String get storePillActive => 'ACTIVE';

  @override
  String get storePillApply => 'APPLY';

  @override
  String get storeThemeDescClassic => 'The original look';

  @override
  String get storeThemeDescModern => 'Clean and minimal';

  @override
  String get storeThemeDescNeon => 'Glowing neon nights';

  @override
  String get storeThemeDescRetro => '80s neon arcade';

  @override
  String get storeThemeDescSpace => 'Cosmic starfield';

  @override
  String get storeThemeDescOcean => 'Deep-sea blues';

  @override
  String get storeThemeDescCyberpunk => 'Electric cyan & pink';

  @override
  String get storeThemeDescForest => 'Vivid emerald jungle';

  @override
  String get storeThemeDescDesert => 'Canyon + cactus teal';

  @override
  String get storeThemeDescCrystal => 'Icy crystalline blue';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'Unlock $name for $price?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Verifying $name purchase…';
  }

  @override
  String get storeThemeNotAvailable =>
      'Theme not available. Please try again later.';

  @override
  String get storeItemNotAvailable =>
      'Item not available. Please try again later.';

  @override
  String storeEquippedToast(Object name) {
    return '$name equipped';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 Free Speed Boost added to your inventory!';

  @override
  String get storeWatchAdTitle => 'Watch an ad — free Speed Boost';

  @override
  String get storeWatchAdReady => 'Adds 1 Speed Boost to your loadout';

  @override
  String get storeWatchAdNotReady => 'No ad available right now';

  @override
  String get puSpeedBoostDesc => 'Increases snake speed for 7 seconds.';

  @override
  String get puInvincibilityDesc =>
      'Pass through walls and yourself for 6 seconds.';

  @override
  String get puScoreMultiplierDesc => 'Double points for 10 seconds.';

  @override
  String get puSlowMotionDesc => 'Slows the game for precision (8 seconds).';

  @override
  String get storePowerUpsInfo =>
      'Buy with coins, then arm one from the home screen loadout chip — it activates 5s into your next game.';

  @override
  String get storePowerUps => 'Power-Ups';

  @override
  String get storePowerUpBundles => 'Power-Up Bundles';

  @override
  String get storeBundlesSubtitle =>
      'Unlock multiple power-up types at a discount.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'Insufficient coins!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'Buy 1 $name for $cost coins?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Buy - $cost coins';
  }

  @override
  String get storePurchaseFailedRetry => 'Purchase failed. Try again.';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name added to your loadout!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count coins';
  }

  @override
  String get storeBuyUpper => 'BUY';

  @override
  String get storeNeedCoins => 'NEED COINS';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name unlocked!';
  }

  @override
  String get modeClassic => 'Classic';

  @override
  String get modeZen => 'Zen Mode';

  @override
  String get modeSpeedChallenge => 'Speed Challenge';

  @override
  String get modeMultiFood => 'Multi-Food';

  @override
  String get modeSurvival => 'Survival';

  @override
  String get modeTimeAttack => 'Time Attack';

  @override
  String get modePowerUpMadness => 'Power-Up Madness';

  @override
  String get modePerfectGame => 'Perfect Game';

  @override
  String get modeClassicDesc => 'The classic Snake game with walls';

  @override
  String get modeZenDesc => 'No walls - snake wraps around the screen';

  @override
  String get modeSpeedChallengeDesc =>
      'Speed increases rapidly for maximum challenge';

  @override
  String get modeMultiFoodDesc => 'Multiple food items appear at once';

  @override
  String get modeSurvivalDesc =>
      'Survive as long as possible with limited lives';

  @override
  String get modeTimeAttackDesc => 'Score as much as possible in limited time';

  @override
  String get modePowerUpMadnessDesc =>
      'Power-ups spawn far more often — embrace the chaos';

  @override
  String get modePerfectGameDesc =>
      'Never cross your own trail. One step on a visited cell ends the run.';

  @override
  String get diffEasy => 'Easy';

  @override
  String get diffNormal => 'Normal';

  @override
  String get diffHard => 'Hard';

  @override
  String get diffEasyDesc =>
      'A slower snake to start. Scores stay off the leaderboards.';

  @override
  String get diffNormalDesc => 'The original Snake Classic pace.';

  @override
  String get diffHardDesc => 'Starts fast and only gets faster.';

  @override
  String get themeClassic => 'Classic';

  @override
  String get themeModern => 'Modern';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeRetro => 'Retro';

  @override
  String get themeSpace => 'Space';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeDesert => 'Desert';

  @override
  String get themeCrystal => 'Crystal';

  @override
  String get dpadLeft => 'Left';

  @override
  String get dpadCenter => 'Center';

  @override
  String get dpadRight => 'Right';

  @override
  String get mpModeClassicBattle => 'Classic Battle';

  @override
  String get mpModeSpeedRun => 'Speed Run';

  @override
  String get mpModeSurvivalMode => 'Survival Mode';

  @override
  String get mpModePowerUpMadnessName => 'Power-up Madness';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get pfSigningOut => 'Signing out...';

  @override
  String get pfStatistics => 'Statistics';

  @override
  String get pfReplays => 'Replays';

  @override
  String get pfLoadingStats => 'Loading stats...';

  @override
  String get pfPowerUps => 'Power-ups';

  @override
  String get pfUpgradeTitle => 'Upgrade to Google Account';

  @override
  String get pfUpgradeSubtitle => 'Save your progress and sync across devices';

  @override
  String get pfBenefitSync => 'Sync Progress';

  @override
  String get pfBenefitSyncSub => 'across devices';

  @override
  String get pfBenefitLeaderboards => 'Global Leaderboards';

  @override
  String get pfBenefitLeaderboardsSub => 'compete worldwide';

  @override
  String get pfBenefitSocial => 'Friends & Social';

  @override
  String get pfBenefitSocialSub => 'connect with others';

  @override
  String get pfSignInGoogle => 'Sign in with Google';

  @override
  String get pfSignInApple => 'Sign in with Apple';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replays saved',
      one: '$count replay saved',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Account Management';

  @override
  String get pfSignOut => 'Sign Out';

  @override
  String get pfDeleteAccount => 'Delete Account';

  @override
  String get pfAppleUpgradeSuccess =>
      'Successfully upgraded to Apple account! 🎉';

  @override
  String get pfAppleIdInUse =>
      'That Apple ID already has an account. Sign out, then sign in with Apple instead.';

  @override
  String get pfUpgradeFailed => 'Failed to upgrade account. Please try again.';

  @override
  String get pfUpgradeError => 'An error occurred during account upgrade.';

  @override
  String get pfGoogleUpgradeSuccess =>
      'Successfully upgraded to Google account! 🎉';

  @override
  String get pfDeleteAccountTitle => 'Delete Account?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'This permanently deletes your account and everything attached to it:\n\n• High scores and statistics\n• Coins and purchased items\n• Themes, skins, trails and power-ups\n• Battle pass and challenge progress\n• Leaderboard entries and friends\n\nThis cannot be undone. Active subscriptions must be cancelled separately in your $storeName settings.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'device\'s app store';

  @override
  String get pfAccountDeleted => 'Your account has been permanently deleted.';

  @override
  String get pfDeleteFailed =>
      'Could not delete your account. Check your connection and try again.';

  @override
  String get pfDeleteForever => 'Delete Forever';

  @override
  String get pfSignOutBody =>
      'Are you sure you want to sign out?\n\nYour progress will be saved if you\'re signed in with Google.';

  @override
  String get pfSignedOut => 'Signed out successfully 👋';

  @override
  String get stLoading => 'Loading Statistics...';

  @override
  String get stPerformanceOverview => 'Performance Overview';

  @override
  String get stTotalGames => 'Total Games';

  @override
  String get stWinStreak => 'Win Streak';

  @override
  String get stGameActivity => 'Game Activity';

  @override
  String get stLongestGame => 'Longest Game';

  @override
  String get stHighestLevel => 'Highest Level';

  @override
  String get stPerfectGames => 'Perfect Games';

  @override
  String get stFoodPowerUps => 'Food & Power-ups';

  @override
  String get stPowerUpsUsed => 'Power-ups Used';

  @override
  String get stFavoriteFood => 'Favorite Food';

  @override
  String get stFavoritePowerUp => 'Favorite Power-up';

  @override
  String get stPerformanceTrends => 'Performance Trends';

  @override
  String get stOverallTrend => 'Overall Trend';

  @override
  String get stRecentAverage => 'Recent Average';

  @override
  String get stBestRecent => 'Best Recent';

  @override
  String get stConsistency => 'Consistency';

  @override
  String get stPlayPatterns => 'Play Patterns (Last 7 Days)';

  @override
  String get stWeeklyTime => 'Weekly Time';

  @override
  String get stMostActiveDay => 'Most Active Day';

  @override
  String get stDailyActivity => 'Daily Activity';

  @override
  String get stAchievementProgress => 'Achievement Progress';

  @override
  String get stResetStatistics => 'RESET STATISTICS';

  @override
  String get stResetTitle => 'Reset Statistics?';

  @override
  String get stResetBody =>
      'This will permanently delete all your game statistics. This action cannot be undone.';

  @override
  String get stReset => 'Reset';

  @override
  String get stNA => 'N/A';

  @override
  String get stExcellent => 'Excellent';

  @override
  String get stGood => 'Good';

  @override
  String get stFair => 'Fair';

  @override
  String get stPoor => 'Poor';

  @override
  String get stNone => 'None';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Games',
      one: '$count Game',
    );
    return 'Progress (Last $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent Complete';
  }

  @override
  String get stInsights => 'Performance Insights';

  @override
  String get stInsightPlayMore =>
      'Play more games to get performance insights!';

  @override
  String get stInsightImproving =>
      'Great job! Your performance is on an upward trend.';

  @override
  String get stInsightAboveAverage =>
      'Your recent games are significantly above your average.';

  @override
  String get stInsightDeclined =>
      'Your performance has declined recently. Consider practicing more.';

  @override
  String get stInsightPractice =>
      'Try focusing on avoiding collisions and planning your moves ahead.';

  @override
  String get stInsightStable =>
      'Your performance is stable. Challenge yourself to improve!';

  @override
  String get stInsightPotential =>
      'You have potential for high scores - work on consistency.';

  @override
  String get stInsightSolid =>
      'You\'re maintaining solid performance across recent games.';

  @override
  String get frTitle => 'Friends';

  @override
  String get frBlockedUsers => 'Blocked users';

  @override
  String get frSearchHint => 'Search by name or email...';

  @override
  String get frSearching => 'Searching...';

  @override
  String get frSearchTitle => 'Search for Friends';

  @override
  String get frSearchSubtitle => 'Enter a name or email to find friends';

  @override
  String get frNoUsersFound => 'No Users Found';

  @override
  String get frNoUsersFoundSub =>
      'Try searching with a different name or email';

  @override
  String get frRequests => 'Requests';

  @override
  String get frSearch => 'Search';

  @override
  String get frNoCacheYet => 'No cache yet';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Updated $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · refresh failed, tap to retry';
  }

  @override
  String get frJustNow => 'just now';

  @override
  String frSecondsAgo(Object count) {
    return '${count}s ago';
  }

  @override
  String frMinutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String frHoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String frDaysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String get frLoadingFriends => 'Loading friends...';

  @override
  String get frNoFriendsYet => 'No Friends Yet';

  @override
  String get frNoFriendsSub => 'Search for users to add as friends!';

  @override
  String get frNoRequests => 'No Friend Requests';

  @override
  String get frNoRequestsSub => 'Friend requests will appear here';

  @override
  String get frChallengeMenu => 'Challenge to a Match';

  @override
  String get frViewProfile => 'View Profile';

  @override
  String get frRemoveFriend => 'Remove Friend';

  @override
  String get frBlockUser => 'Block User';

  @override
  String frReceivedHeader(Object count) {
    return 'Received ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Sent ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '$count game',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'Sent $date';
  }

  @override
  String get frPending => 'Pending';

  @override
  String get frCancelRequest => 'Cancel request';

  @override
  String get frReject => 'Reject';

  @override
  String get frAccept => 'Accept';

  @override
  String get frAlreadyFriends => '✓ Friends';

  @override
  String get frAddFriend => 'Add Friend';

  @override
  String get frSendRequestFailed =>
      'Could not send the friend request — check your connection and try again';

  @override
  String get frAcceptFailed =>
      'Could not accept the request — check your connection and try again';

  @override
  String get frRejectFailed =>
      'Could not reject the request — check your connection and try again';

  @override
  String get frCancelFailed =>
      'Could not cancel the request — check your connection and try again';

  @override
  String get frBlockFailed =>
      'Could not block this user — check your connection and try again';

  @override
  String get frSignInSocial => 'Sign in to add friends and use social features';

  @override
  String get frRequestSent => 'Friend request sent!';

  @override
  String get frRequestAccepted => 'Friend request accepted!';

  @override
  String get frRequestRejected => 'Friend request rejected';

  @override
  String get frRequestCancelled => 'Friend request cancelled';

  @override
  String frChallengeSent(Object name) {
    return '🎮 Challenge sent to $name!';
  }

  @override
  String get frChallengeFailed => 'Could not send the challenge — try again';

  @override
  String frBlocked(Object name) {
    return '$name blocked';
  }

  @override
  String frUnblocked(Object name) {
    return '$name unblocked';
  }

  @override
  String get frUnblockFailed => 'Could not unblock — try again';

  @override
  String frRemoved(Object name) {
    return '$name removed from friends';
  }

  @override
  String frBlockTitle(Object name) {
    return 'Block $name?';
  }

  @override
  String get frBlockBody =>
      'They will be removed from your friends and unable to send you friend requests or match challenges. They will not be notified.';

  @override
  String get frBlock => 'Block';

  @override
  String get frNoBlocked => 'You have not blocked anyone.';

  @override
  String get frUnblock => 'Unblock';

  @override
  String frHighScoreLine(Object score) {
    return 'High Score: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Total Games: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Level: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Status: \"$status\"';
  }

  @override
  String frRemoveBody(Object name) {
    return 'Remove $name from your friends list?';
  }

  @override
  String get frRemove => 'Remove';

  @override
  String get frLeaderboardSubtitle => 'Compete with your friends';

  @override
  String get frLoadingLeaderboard => 'Loading leaderboard...';

  @override
  String frRankBadge(Object rank) {
    return '#$rank';
  }

  @override
  String get frLeaderboardEmptySub =>
      'Add friends to see your private leaderboard!';

  @override
  String get frAddFriends => 'Add Friends';

  @override
  String get tnTitle => 'Tournaments';

  @override
  String get tnActive => 'Active';

  @override
  String get tnHistory => 'History';

  @override
  String get tnMyStats => 'My Stats';

  @override
  String get tnLoading => 'Loading tournaments...';

  @override
  String get tnNoActive => 'No Active Tournaments';

  @override
  String get tnNoActiveSub => 'Check back later for new tournaments!';

  @override
  String get tnNoHistory => 'No Tournament History';

  @override
  String get tnNoHistorySub =>
      'Participate in tournaments to see your history!';

  @override
  String get tnNoStats => 'No Tournament Stats';

  @override
  String get tnNoStatsSub => 'Join tournaments to track your progress!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max players';
  }

  @override
  String get tnJoined => 'Joined';

  @override
  String tnBestScoreChip(Object score) {
    return 'Best: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Rank #$rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rewards available',
      one: '$count reward available',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'View Details →';

  @override
  String get tnOverviewCard => 'Tournament Overview';

  @override
  String get tnWins => 'Wins';

  @override
  String get tnTopThree => 'Top 3 Finishes';

  @override
  String get tnBestScore => 'Best Score';

  @override
  String get tnDetailedStats => 'Detailed Statistics';

  @override
  String get tnTotalAttempts => 'Total Attempts';

  @override
  String get tnWinRate => 'Win Rate';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'Average Performance';

  @override
  String tnTopPercent(Object percent) {
    return 'Top $percent%';
  }

  @override
  String get tnNotFound => 'Tournament not found';

  @override
  String get tnLoadFailed => 'Failed to load tournament';

  @override
  String get tnLoadingTournament => 'Loading tournament...';

  @override
  String get tnGoBack => 'Go Back';

  @override
  String get tnParticipating => 'You\'re participating!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Best Score: $score • Attempts: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Rank #$rank';
  }

  @override
  String get tnOverview => 'Overview';

  @override
  String get tnLeaderboard => 'Leaderboard';

  @override
  String get tnRules => 'Rules';

  @override
  String get tnLeaderboardFailed => 'Couldn\'t load the leaderboard';

  @override
  String get tnCheckConnection => 'Check your connection and try again.';

  @override
  String get tnNoParticipants => 'No participants yet';

  @override
  String get tnBeFirst => 'Be the first to join!';

  @override
  String get tnDescription => 'Description';

  @override
  String get tnRewards => 'Rewards';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '$count attempt',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Tournament Rules';

  @override
  String get tnScoringSystem => 'Scoring System';

  @override
  String get tnScoringBody =>
      'Your highest score during the tournament period will count towards the final ranking. You can play multiple times to improve your score.';

  @override
  String get tnJoining => 'JOINING…';

  @override
  String get tnJoin => 'JOIN TOURNAMENT';

  @override
  String get tnPlayNow => 'PLAY NOW';

  @override
  String get tnProUnlimited => 'Pro · Unlimited entries';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Entries remaining: $count';
  }

  @override
  String get tnNoEntries => 'No entries — tap JOIN to buy';

  @override
  String tnStarts(Object time) {
    return 'Starts $time';
  }

  @override
  String get tnRule1 =>
      'Play during the tournament period to have your scores counted';

  @override
  String get tnRule2 =>
      'You can play multiple times - only your highest score counts';

  @override
  String get tnRule3 => 'Must be signed in to participate';

  @override
  String get tnRule4 => 'Final rankings are determined at tournament end';

  @override
  String get tnRuleSpeed => 'Game speed increases rapidly every 10 points';

  @override
  String get tnRuleSurvival =>
      'Score is based on survival time, not food consumed';

  @override
  String get tnRuleNoWalls =>
      'Snake wraps around screen edges instead of hitting walls';

  @override
  String get tnRulePowerUps => 'Power-ups spawn every 5 seconds';

  @override
  String get tnRulePerfect => 'Any collision immediately ends the game';

  @override
  String get tnRuleClassic => 'Standard Snake rules apply';

  @override
  String get tnJoinSuccess => 'Successfully joined tournament!';

  @override
  String get tnJoinFailed => 'Failed to join tournament';

  @override
  String get tnJoinError => 'Error joining tournament';

  @override
  String get tnTierBronze => 'Bronze';

  @override
  String get tnTierSilver => 'Silver';

  @override
  String get tnTierGold => 'Gold';

  @override
  String get tnEntryRequired => 'Entry Required';

  @override
  String tnEntryNeeded(Object tier) {
    return 'You need a $tier tournament entry to join this tournament.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Current $tier entries: $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Pro subscribers get unlimited tournament access.';

  @override
  String get tnFreeBronzeAdded => '🎉 Free Bronze tournament entry added!';

  @override
  String get tnFreeEntryAd => 'Free entry (ad)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Buy $tier Entry - $price';
  }

  @override
  String get acLocked => 'Locked';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% complete';
  }

  @override
  String get acEmpty => 'No achievements here';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String get rpRecent => 'Recent';

  @override
  String get rpBest => 'Best';

  @override
  String get rpCrashes => 'Crashes';

  @override
  String get rpLoading => 'Loading replays...';

  @override
  String get rpNoRecent => 'No recent replays';

  @override
  String get rpNoBest => 'No high-score replays';

  @override
  String get rpNoCrashes => 'No crash replays';

  @override
  String get rpEmptySub => 'Play some games to generate replays!';

  @override
  String get rpScore => 'Score';

  @override
  String get rpDuration => 'Duration';

  @override
  String get rpFood => 'Food';

  @override
  String get rpFrames => 'Frames';

  @override
  String get rpMaxLength => 'Max Length';

  @override
  String get rpWatch => 'Watch';

  @override
  String get rpYesterday => 'Yesterday';

  @override
  String get rpDeleteTitle => 'Delete Replay';

  @override
  String rpDeleteBody(Object date) {
    return 'Delete replay from $date?';
  }

  @override
  String get rpDelete => 'Delete';

  @override
  String get rpDeleted => 'Replay deleted';

  @override
  String get rpDeleteFailed => 'Failed to delete replay';

  @override
  String get lbWeeklySub =>
      'Ranked by your best single-game score this week (resets Sunday)';

  @override
  String get lbLoadingGlobal => 'Loading global leaderboard...';

  @override
  String get lbLoadingWeekly => 'Loading weekly leaderboard...';

  @override
  String get lbNoScores => 'No scores yet';

  @override
  String get lbNoWeekly => 'No weekly scores yet';

  @override
  String get lbPlayThisWeek => 'Play this week to appear here!';

  @override
  String get lbAnonymous => 'Anonymous';

  @override
  String get lbPts => 'pts';

  @override
  String bpClaimedToast(Object name) {
    return '$name claimed!';
  }

  @override
  String get bpLoading => 'Loading battle pass...';

  @override
  String get bpXpEarned => '+50 Battle Pass XP earned!';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h left';
  }

  @override
  String get bpSeasonCompleteUpper => 'SEASON COMPLETE';

  @override
  String get bpSeasonCosmicSerpent => 'Cosmic Serpent Season';

  @override
  String get bpUnlockedEverything =>
      'You\'ve unlocked every tier in this season.';

  @override
  String bpTierN(Object tier) {
    return 'Tier $tier';
  }

  @override
  String get bpUnlockWithPro => 'UNLOCK WITH PRO';

  @override
  String get bpAvailableNow => 'AVAILABLE NOW';

  @override
  String bpTierAbbrev(Object tier) {
    return 'T$tier';
  }

  @override
  String get bpClaim => 'CLAIM';

  @override
  String get bpPremiumWaiting => 'Premium rewards waiting';

  @override
  String get bpSubscribeToClaim => 'Subscribe to Pro to claim them.';

  @override
  String get bpHideTiers => 'Hide tiers';

  @override
  String bpViewAllTiers(Object count) {
    return 'View all $count tiers';
  }

  @override
  String bpTierUpperN(Object tier) {
    return 'TIER $tier';
  }

  @override
  String get bpUnlocked => 'Unlocked';

  @override
  String bpReachTier(Object tier) {
    return 'Reach Tier $tier to unlock';
  }

  @override
  String get bpBetweenSeasons => 'Between Seasons';

  @override
  String get bpNoSeasonBody =>
      'No Battle Pass is running right now — the next season will start automatically. Check back soon.';

  @override
  String get bpCheckNewSeason => 'Check for new season';

  @override
  String get pbActiveSub => 'You have access to all premium features';

  @override
  String get pbYourPlan => 'Your plan';

  @override
  String get pbPlanMonthly => 'Monthly';

  @override
  String get pbPlanYearly => 'Yearly';

  @override
  String pbRenewsOn(Object date) {
    return 'Renews $date';
  }

  @override
  String get pbSwitchToYearly => 'Switch to yearly';

  @override
  String get pbSwitchToMonthly => 'Switch to monthly';

  @override
  String get pbSwitchToYearlyBlurb =>
      'Starts today. The rest of this month is credited, and you save 33% a year.';

  @override
  String get pbSwitchToMonthlyBlurb =>
      'Starts when your paid year ends. Nothing is charged today.';

  @override
  String get pbManageSubscription => 'Manage subscription';

  @override
  String get pbManageBlurb => 'Cancel or update payment in the store';

  @override
  String get pbSwitchedToYearly => 'Switched to yearly';

  @override
  String get pbSwitchedToMonthly => 'Monthly starts when this period ends';

  @override
  String get pbAllUnlocked => 'Everything below is yours';

  @override
  String get pbFeatLucky => 'Lucky Forager — More Special Foods';

  @override
  String get pbFeatLuckyDesc =>
      '+50% chance to spawn the rare 50-point special food in every game';

  @override
  String get pbFeatPowerUps => 'More In-Game Power-ups';

  @override
  String get pbFeatPowerUpsDesc =>
      '+30% spawn rate for on-board power-ups during gameplay';

  @override
  String get pbFeatTournament => 'Tournament Entries';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronze + 1× Silver + 1× Gold tournament entry every billing cycle';

  @override
  String get pbNotAvailable => 'Premium subscription not available';

  @override
  String get eaTitleSignIn => 'Email Sign-In';

  @override
  String get eaExplainer =>
      'Add an email and password to your account so you can buy items, restore on reinstall, and sign in from any device.';

  @override
  String get eaLinkExisting => 'Link Existing';

  @override
  String get eaSignIn => 'Sign In';

  @override
  String get eaCreateAccount => 'Create Account';

  @override
  String get eaForgotPassword => 'Forgot password?';

  @override
  String get eaLinkToExisting => 'Link to Existing Account';

  @override
  String get eaMinChars => 'At least 8 characters';

  @override
  String eaMinCharsN(Object count) {
    return 'At least $count characters';
  }

  @override
  String get eaCreateAndLink => 'Create & Link Account';

  @override
  String get eaEmail => 'Email';

  @override
  String get eaEmailRequired => 'Email is required';

  @override
  String get eaEmailInvalid => 'Enter a valid email';

  @override
  String get eaPassword => 'Password';

  @override
  String get eaPasswordRequired => 'Password is required';

  @override
  String get eaForgotFirst =>
      'Enter your email above first, then tap Forgot password.';

  @override
  String eaResetSent(Object email) {
    return 'Password reset email sent to $email.';
  }

  @override
  String get eaErrInvalidEmail => 'That email address is not valid.';

  @override
  String get eaErrDisabled => 'This account has been disabled.';

  @override
  String get eaErrNoAccount => 'No account found with that email.';

  @override
  String get eaErrWrongCreds => 'Wrong email or password.';

  @override
  String get eaErrEmailInUse =>
      'An account with that email already exists. Try signing in instead.';

  @override
  String get eaErrWeakPassword =>
      'Password is too weak. Use at least 8 characters.';

  @override
  String get eaErrNotEnabled =>
      'Email/password sign-in is not enabled. Contact support.';

  @override
  String get eaErrTooMany =>
      'Too many attempts. Please wait a few minutes and try again.';

  @override
  String get eaErrNetwork => 'Network error. Check your connection.';

  @override
  String get eaErrAlreadyLinked =>
      'This account is already linked to email/password.';

  @override
  String get eaErrRecentLogin =>
      'For security, please sign in again before linking.';

  @override
  String get eaErrGeneric => 'Something went wrong. Please try again.';

  @override
  String get faChooseHow => 'Choose how you\'d like to play:';

  @override
  String get faSigningIn => 'Signing you in...';

  @override
  String get faSignInEmail => 'Sign in with Email';

  @override
  String get faContinueGuest => 'Continue as Guest';

  @override
  String get faReviewNote =>
      'Please review our Privacy Policy and Terms of Use before continuing';

  @override
  String get faAgreeCheckbox =>
      'I have read and agree to the Privacy Policy and Terms of Use';

  @override
  String get faContinueToSignIn => 'Continue to Sign In';

  @override
  String get faAppleFailed => 'Failed to sign in with Apple. Please try again.';

  @override
  String get faGoogleFailed =>
      'Failed to sign in with Google. Please try again.';

  @override
  String get faUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String get faGuestFailed => 'Failed to continue as guest. Please try again.';

  @override
  String get ldInitializing => 'Initializing Snake Classic...';

  @override
  String get ldStepCore => 'Initializing core systems...';

  @override
  String get ldStepProfile => 'Creating your player profile...';

  @override
  String get ldStepPrefs => 'Loading your preferences...';

  @override
  String get ldStepCloud => 'Syncing with cloud...';

  @override
  String get ldStepGameData => 'Loading game data...';

  @override
  String get ldStepAudio => 'Configuring audio system...';

  @override
  String get ldStepAds => 'Warming up rewards...';

  @override
  String get ldStepSetup => 'Checking setup status...';

  @override
  String get ldWelcome => 'Welcome!';

  @override
  String get ldReady => 'Ready to play!';

  @override
  String ldInitFailed(Object error) {
    return 'Initialization failed: $error';
  }

  @override
  String get ldRetrying => 'Retrying initialization...';

  @override
  String get ldInitFailedUpper => 'INITIALIZATION FAILED';

  @override
  String get ldRetryUpper => 'RETRY';

  @override
  String get pgPreparing => 'PREPARING ARENA';

  @override
  String get pgTournamentMode => 'TOURNAMENT MODE';

  @override
  String get pgDPadControls => 'D-Pad Controls';

  @override
  String get pgSwipeControls => 'Swipe Controls';

  @override
  String get pgLevel => 'LEVEL';

  @override
  String get pgBest => 'BEST';

  @override
  String get pgGames => 'GAMES';

  @override
  String get pgTapToStart => 'TAP ANYWHERE TO START';

  @override
  String get wtWelcomeTitle => 'Welcome to the Game!';

  @override
  String get wtWelcomeMsg =>
      'Let\'s learn how to play Snake Classic. This quick tutorial will show you the basics.';

  @override
  String get wtHudTitle => 'Game Info';

  @override
  String get wtHudMsg =>
      'The top bar shows your score, level, and high score. Watch your progress as you play!';

  @override
  String get wtControlsTitle => 'Steering';

  @override
  String get wtControlsMsg =>
      'Change direction by swiping the board, with an on-screen D-Pad, Turn buttons or Joystick, or with the arrow keys. Pick your style in Settings → Controls or from the pause menu.';

  @override
  String get wtPracticeRightTitle => 'Try it — turn RIGHT';

  @override
  String get wtPracticeRightMsg =>
      'Turn right to continue. Swipe, D-pad or arrow keys all work.';

  @override
  String get wtPracticeUpTitle => 'Nice — now turn UP';

  @override
  String get wtPracticeUpMsg => 'Turn up to continue.';

  @override
  String get wtFoodTitle => 'Eat to Grow';

  @override
  String get wtFoodMsg =>
      'Guide your snake to eat the food that appears on the board. Each food item makes your snake longer!';

  @override
  String get wtComboTitle => 'Build a Combo';

  @override
  String get wtComboMsg =>
      'Eat food without dying to build a combo. At 5 bites you get 1.5×, at 10 you get 2×, at 20 you get 3×. The fire chip near your score heats up and pulses as you climb.';

  @override
  String get wtPowerUpsTitle => 'Power-ups';

  @override
  String get wtPowerUpsMsg =>
      'Sparkly icons spawn occasionally — eat one to activate it. The ring around its icon drains as the effect runs out, and the timer freezes if you pause the game.';

  @override
  String get wtWallsTitle => 'Avoid the Walls!';

  @override
  String get wtWallsMsg =>
      'Don\'t hit the edges of the board - it\'s game over if you crash into a wall!';

  @override
  String get wtSelfTitle => 'Don\'t Hit Yourself!';

  @override
  String get wtSelfMsg =>
      'As your snake grows longer, be careful not to crash into your own body!';

  @override
  String get wtPauseTitle => 'Pause Anytime';

  @override
  String get wtPauseMsg =>
      'Tap the pause icon to freeze the run. From there you can resume, restart, open the Game Guide, replay this tutorial, switch your controls, or turn Snap Movement on.';

  @override
  String get wtReadyTitle => 'You\'re Ready!';

  @override
  String get wtReadyMsg =>
      'Good luck! Open the pause menu\'s Game Guide anytime to read up on combos, power-ups, modes, and crash feedback. Check your Profile to see achievements unlock as you hit goals.';

  @override
  String get wtStartPlaying => 'Start Playing!';

  @override
  String get wtSkipTutorial => 'Skip Tutorial';

  @override
  String get wtSwipeRightUpper => 'TURN RIGHT';

  @override
  String get wtSwipeLeftUpper => 'TURN LEFT';

  @override
  String get wtSwipeUpUpper => 'TURN UP';

  @override
  String get wtSwipeDownUpper => 'TURN DOWN';

  @override
  String get wtSwipeAnywhereScreen => 'Swipe, D-pad or arrow keys';

  @override
  String get wtSwipeAnywhere => 'Your move!';

  @override
  String get wtGotIt => 'Got it!';

  @override
  String get wtNext => 'Next';

  @override
  String get wtSkip => 'Skip';

  @override
  String get wtWaiting => 'Waiting...';

  @override
  String get hwDailyTitle => 'Daily Challenges';

  @override
  String get hwDailyMsg =>
      'Complete daily challenges for bonus coins and rewards. New challenges every day!';

  @override
  String get hudTournamentBadge => 'TOURNAMENT';

  @override
  String get poStore => 'Store';

  @override
  String get poSnapOn => 'SNAP: ON';

  @override
  String get poSnapOff => 'SNAP: OFF';

  @override
  String get updateReadyTitle => 'Update ready';

  @override
  String get updateReadyRestart => 'Restart';

  @override
  String get poUpdateReady => 'RESTART TO UPDATE';

  @override
  String get poHowToPlay => 'HOW TO PLAY';

  @override
  String get poGameGuide => 'GAME GUIDE';

  @override
  String get dcTitle => 'Daily Challenges';

  @override
  String get dcNoChallenges => 'No challenges available';

  @override
  String get dcAllComplete => 'All Complete!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count Bonus';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · build $build';
  }

  @override
  String get crTagline => 'The classic snake game, reimagined.';

  @override
  String get crChipModes => 'Modes';

  @override
  String get crChipAchievements => 'Achievements';

  @override
  String get crChipDaily => 'Daily';

  @override
  String get crChipLeaderboards => 'Leaderboards';

  @override
  String get crChipCosmetics => 'Cosmetics';

  @override
  String get crCraftedBy => 'Crafted by';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · All rights reserved';
  }

  @override
  String get gbSpeedNormal => 'Normal';

  @override
  String get gbSpeedFast => 'Fast';

  @override
  String get gbSpeedFaster => 'Faster';

  @override
  String get gbSpeedBlazing => 'Blazing';

  @override
  String get gbSpeedInsane => 'Insane';

  @override
  String get gbSpeedMax => 'MAX';

  @override
  String get gbLength => 'Length';

  @override
  String get gbSpeed => 'Speed';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get rarityDiamond => 'Diamond';

  @override
  String get achTitleFirstBite => 'First Bite';

  @override
  String get achDescFirstBite => 'Score your first point';

  @override
  String get achTitleGettingStarted => 'Getting Started';

  @override
  String get achDescGettingStarted => 'Score 100 points';

  @override
  String get achTitleHighScorer => 'High Scorer';

  @override
  String get achDescHighScorer => 'Score 500 points in a single game';

  @override
  String get achTitleMasterScorer => 'Master Scorer';

  @override
  String get achDescMasterScorer => 'Score 1000 points in a single game';

  @override
  String get achTitleLegendaryScorer => 'Legendary Scorer';

  @override
  String get achDescLegendaryScorer => 'Score 2000 points in a single game';

  @override
  String get achTitleFirstGame => 'First Game';

  @override
  String get achDescFirstGame => 'Play your first game';

  @override
  String get achTitleRegularPlayer => 'Regular Player';

  @override
  String get achDescRegularPlayer => 'Play 10 games';

  @override
  String get achTitleDedicatedPlayer => 'Dedicated Player';

  @override
  String get achDescDedicatedPlayer => 'Play 50 games';

  @override
  String get achTitleSnakeEnthusiast => 'Snake Enthusiast';

  @override
  String get achDescSnakeEnthusiast => 'Play 100 games';

  @override
  String get achTitleSnakeAddict => 'Snake Addict';

  @override
  String get achDescSnakeAddict => 'Play 500 games';

  @override
  String get achTitleSurvivor => 'Survivor';

  @override
  String get achDescSurvivor => 'Survive for 60 seconds';

  @override
  String get achTitleEndurance => 'Endurance';

  @override
  String get achDescEndurance => 'Survive for 2 minutes';

  @override
  String get achTitleMarathon => 'Marathon';

  @override
  String get achDescMarathon => 'Survive for 5 minutes';

  @override
  String get achTitleNoWalls => 'Wall Avoider';

  @override
  String get achDescNoWalls => 'Play 5 games without hitting walls';

  @override
  String get achTitleSpeedster => 'Speedster';

  @override
  String get achDescSpeedster => 'Reach level 10 (max speed)';

  @override
  String get achTitlePerfectionist => 'Perfectionist';

  @override
  String get achDescPerfectionist => 'Complete a game without hitting yourself';

  @override
  String get achTitleAllFoodTypes => 'Gourmet';

  @override
  String get achDescAllFoodTypes => 'Eat all 3 types of food in a single game';

  @override
  String get achTitleHalfGrand => 'Half Grand';

  @override
  String get achDescHalfGrand => 'Score 5,000 in a single game';

  @override
  String get achTitleScoreSniper => 'Score Sniper';

  @override
  String get achDescScoreSniper => 'Score 10,000 in a single game';

  @override
  String get achTitleFiveDigitClub => 'Five-Digit Club';

  @override
  String get achDescFiveDigitClub => 'Score 25,000 in a single game';

  @override
  String get achTitleScoreTycoon => 'Score Tycoon';

  @override
  String get achDescScoreTycoon => 'Score 50,000 in a single game';

  @override
  String get achTitleScoreGod => 'Score God';

  @override
  String get achDescScoreGod => 'Score 100,000 in a single game';

  @override
  String get achTitlePointCollector => 'Point Collector';

  @override
  String get achDescPointCollector => 'Accumulate 10,000 points lifetime';

  @override
  String get achTitlePointHoarder => 'Point Hoarder';

  @override
  String get achDescPointHoarder => 'Accumulate 100,000 points lifetime';

  @override
  String get achTitleHalfMillionClub => 'Half Million Club';

  @override
  String get achDescHalfMillionClub => 'Accumulate 500,000 points lifetime';

  @override
  String get achTitlePointMillionaire => 'Point Millionaire';

  @override
  String get achDescPointMillionaire => 'Accumulate 1,000,000 points lifetime';

  @override
  String get achTitleDecamillionaire => 'Decamillionaire';

  @override
  String get achDescDecamillionaire => 'Accumulate 10,000,000 points lifetime';

  @override
  String get achTitleSnakeVeteran => 'Snake Veteran';

  @override
  String get achDescSnakeVeteran => 'Play 1,000 games';

  @override
  String get achTitleSnakeLegend => 'Snake Legend';

  @override
  String get achDescSnakeLegend => 'Play 5,000 games';

  @override
  String get achTitleIronWill => 'Iron Will';

  @override
  String get achDescIronWill => 'Survive 10 minutes in a single game';

  @override
  String get achTitleEternalSnake => 'Eternal Snake';

  @override
  String get achDescEternalSnake => 'Survive 20 minutes in a single game';

  @override
  String get achTitleTimeLord => 'Time Lord';

  @override
  String get achDescTimeLord => 'Survive 30 minutes in a single game';

  @override
  String get achTitleFirstBiteSnack => 'First Bite Snack';

  @override
  String get achDescFirstBiteSnack => 'Eat 5 foods in one game';

  @override
  String get achTitleHungrySnake => 'Hungry Snake';

  @override
  String get achDescHungrySnake => 'Eat 20 foods in one game';

  @override
  String get achTitleFamished => 'Famished';

  @override
  String get achDescFamished => 'Eat 50 foods in one game';

  @override
  String get achTitleRavenous => 'Ravenous';

  @override
  String get achDescRavenous => 'Eat 100 foods in one game';

  @override
  String get achTitleInsatiable => 'Insatiable';

  @override
  String get achDescInsatiable => 'Eat 200 foods in one game';

  @override
  String get achTitleBlackHoleStomach => 'Black Hole Stomach';

  @override
  String get achDescBlackHoleStomach => 'Eat 500 foods in one game';

  @override
  String get achTitleFoodieApprentice => 'Foodie Apprentice';

  @override
  String get achDescFoodieApprentice => 'Eat 100 foods lifetime';

  @override
  String get achTitleFoodiePro => 'Foodie Pro';

  @override
  String get achDescFoodiePro => 'Eat 1,000 foods lifetime';

  @override
  String get achTitleFoodieMaster => 'Foodie Master';

  @override
  String get achDescFoodieMaster => 'Eat 10,000 foods lifetime';

  @override
  String get achTitleFoodieGod => 'Foodie God';

  @override
  String get achDescFoodieGod => 'Eat 50,000 foods lifetime';

  @override
  String get achTitleQuickPlayer => 'Quick Player';

  @override
  String get achDescQuickPlayer => 'Play for 1 hour total';

  @override
  String get achTitleEngagedPlayer => 'Engaged Player';

  @override
  String get achDescEngagedPlayer => 'Play for 10 hours total';

  @override
  String get achTitleHardcorePlayer => 'Hardcore Player';

  @override
  String get achDescHardcorePlayer => 'Play for 50 hours total';

  @override
  String get achTitleSnakeObsessed => 'Snake Obsessed';

  @override
  String get achDescSnakeObsessed => 'Play for 100 hours total';

  @override
  String get achTitleTouchGrass => 'Touch Grass';

  @override
  String get achDescTouchGrass =>
      'Play for 250 hours total — maybe step outside?';

  @override
  String get achTitleLevel5 => 'Apprentice';

  @override
  String get achDescLevel5 => 'Reach Level 5';

  @override
  String get achTitleLevel10 => 'Journeyman';

  @override
  String get achDescLevel10 => 'Reach Level 10';

  @override
  String get achTitleLevel25 => 'Expert';

  @override
  String get achDescLevel25 => 'Reach Level 25';

  @override
  String get achTitleLevel50 => 'Master';

  @override
  String get achDescLevel50 => 'Reach Level 50';

  @override
  String get achTitleLevel100 => 'Grandmaster';

  @override
  String get achDescLevel100 => 'Reach Level 100';

  @override
  String get achTitleClassicInitiate => 'Classic Initiate';

  @override
  String get achDescClassicInitiate => 'Finish 10 Classic-mode games';

  @override
  String get achTitleClassicVeteran => 'Classic Veteran';

  @override
  String get achDescClassicVeteran => 'Finish 100 Classic-mode games';

  @override
  String get achTitleClassic1000 => 'Classic Connoisseur';

  @override
  String get achDescClassic1000 => 'Score 1,000 in Classic mode';

  @override
  String get achTitleClassic5000 => 'Classic Maestro';

  @override
  String get achDescClassic5000 => 'Score 5,000 in Classic mode';

  @override
  String get achTitleZenInitiate => 'Zen Initiate';

  @override
  String get achDescZenInitiate => 'Finish 10 Zen games';

  @override
  String get achTitleZenGarden => 'Zen Garden';

  @override
  String get achDescZenGarden => 'Score 500 in Zen mode';

  @override
  String get achTitleZenMaster => 'Zen Master';

  @override
  String get achDescZenMaster => 'Score 5,000 in Zen mode';

  @override
  String get achTitleSpeedInitiate => 'Need For Speed';

  @override
  String get achDescSpeedInitiate => 'Finish 10 Speed Challenge games';

  @override
  String get achTitleSpeedrunner => 'Speedrunner';

  @override
  String get achDescSpeedrunner => 'Score 500 in Speed Challenge';

  @override
  String get achTitleLightning => 'Lightning';

  @override
  String get achDescLightning => 'Score 2,000 in Speed Challenge';

  @override
  String get achTitleMultifoodInitiate => 'Foodscape';

  @override
  String get achDescMultifoodInitiate => 'Finish 10 MultiFood games';

  @override
  String get achTitleBuffet => 'Buffet';

  @override
  String get achDescBuffet => 'Score 1,000 in MultiFood';

  @override
  String get achTitleSmorgasbord => 'Smorgasbord';

  @override
  String get achDescSmorgasbord => 'Score 5,000 in MultiFood';

  @override
  String get achTitleSurvivalInitiate => 'Survival Initiate';

  @override
  String get achDescSurvivalInitiate => 'Finish 10 Survival games';

  @override
  String get achTitleSurvivalPro => 'Survival Pro';

  @override
  String get achDescSurvivalPro => 'Survive 5 minutes in Survival mode';

  @override
  String get achTitleLastSnakeStanding => 'Last Snake Standing';

  @override
  String get achDescLastSnakeStanding => 'Score 2,500 in Survival';

  @override
  String get achTitleTimeattackInitiate => 'Time Attacker';

  @override
  String get achDescTimeattackInitiate => 'Finish 10 TimeAttack games';

  @override
  String get achTitleBeatTheClock => 'Beat the Clock';

  @override
  String get achDescBeatTheClock => 'Survive the full 3-minute TimeAttack';

  @override
  String get achTitleTimeattackMaster => 'TimeAttack Master';

  @override
  String get achDescTimeattackMaster => 'Score 3,000 in TimeAttack';

  @override
  String get achTitleComboStarter => 'Combo Starter';

  @override
  String get achDescComboStarter => 'Hit a 5x combo in a single game';

  @override
  String get achTitleComboMaster => 'Combo Master';

  @override
  String get achDescComboMaster => 'Hit a 10x combo in a single game';

  @override
  String get achTitleComboPro => 'Combo Pro';

  @override
  String get achDescComboPro => 'Hit a 20x combo in a single game';

  @override
  String get achTitleComboGod => 'Combo God';

  @override
  String get achDescComboGod => 'Hit a 50x combo in a single game';

  @override
  String get achTitleComboLegend => 'Combo Legend';

  @override
  String get achDescComboLegend => 'Hit a 100x combo in a single game';

  @override
  String get achTitleGrowingSnake => 'Growing Snake';

  @override
  String get achDescGrowingSnake => 'Grow snake to length 20';

  @override
  String get achTitleBigSnake => 'Big Snake';

  @override
  String get achDescBigSnake => 'Grow snake to length 50';

  @override
  String get achTitleHugeSnake => 'Huge Snake';

  @override
  String get achDescHugeSnake => 'Grow snake to length 100';

  @override
  String get achTitleMassiveSnake => 'Massive Snake';

  @override
  String get achDescMassiveSnake => 'Grow snake to length 200';

  @override
  String get achTitleAnaconda => 'Anaconda';

  @override
  String get achDescAnaconda => 'Grow snake to length 500';

  @override
  String get achTitleFirstPowerUp => 'Power Up!';

  @override
  String get achDescFirstPowerUp => 'Collect your first power-up';

  @override
  String get achTitlePowerPlayer => 'Power Player';

  @override
  String get achDescPowerPlayer => 'Collect 10 power-ups lifetime';

  @override
  String get achTitlePowerHungry => 'Power Hungry';

  @override
  String get achDescPowerHungry => 'Collect 50 power-ups lifetime';

  @override
  String get achTitlePowerAddict => 'Power Addict';

  @override
  String get achDescPowerAddict => 'Collect 200 power-ups lifetime';

  @override
  String get achTitlePowerMaster => 'Power Master';

  @override
  String get achDescPowerMaster => 'Collect 1,000 power-ups lifetime';

  @override
  String get achTitleVarietyPack => 'Variety Pack';

  @override
  String get achDescVarietyPack =>
      'Collect each of the 4 power-up types at least once';

  @override
  String get achTitleSpeedDemon => 'Speed Demon';

  @override
  String get achDescSpeedDemon => 'Collect 25 Speed Boost power-ups';

  @override
  String get achTitleImmortalStreak => 'Immortal Streak';

  @override
  String get achDescImmortalStreak => 'Collect 25 Invincibility power-ups';

  @override
  String get achTitleSpecialDiet => 'Special Diet';

  @override
  String get achDescSpecialDiet => 'Eat 50 special foods lifetime';

  @override
  String get achTitleBonusHunter => 'Bonus Hunter';

  @override
  String get achDescBonusHunter => 'Eat 100 bonus foods lifetime';

  @override
  String get achTitleUntouchable5 => 'Untouchable';

  @override
  String get achDescUntouchable5 => 'Complete 5 perfect games (no hits, 30s+)';

  @override
  String get achTitleUntouchable20 => 'Flawless';

  @override
  String get achDescUntouchable20 => 'Complete 20 perfect games';

  @override
  String get achTitleUntouchable50 => 'Untouchable Legend';

  @override
  String get achDescUntouchable50 => 'Complete 50 perfect games';

  @override
  String get achTitleHotStreak => 'Hot Streak';

  @override
  String get achDescHotStreak =>
      '5 consecutive games scoring >0 and lasting 30s+';

  @override
  String get achTitleOnFire => 'On Fire';

  @override
  String get achDescOnFire => '10-game streak (30s+ each)';

  @override
  String get achTitleUnstoppable => 'Unstoppable';

  @override
  String get achDescUnstoppable => '25-game streak (30s+ each)';

  @override
  String get achTitleDailyThree => 'Daily Player';

  @override
  String get achDescDailyThree => 'Play on 3 consecutive days';

  @override
  String get achTitleWeekWarrior => 'Week Warrior';

  @override
  String get achDescWeekWarrior => 'Play on 7 consecutive days';

  @override
  String get achTitleVelocity => 'Velocity';

  @override
  String get achDescVelocity => 'Reach in-game level 15 in one game';

  @override
  String get achTitleMachSpeed => 'Mach Speed';

  @override
  String get achDescMachSpeed => 'Reach in-game level 20 in one game';

  @override
  String get achTitleCosmicSnake => 'Cosmic Snake';

  @override
  String get achDescCosmicSnake => 'Reach in-game level 25 in one game';

  @override
  String get achTitleModeExplorer => 'Mode Explorer';

  @override
  String get achDescModeExplorer =>
      'Play at least one game in 3 distinct modes';

  @override
  String get achTitleAllModePlayer => 'All-Mode Player';

  @override
  String get achDescAllModePlayer =>
      'Play at least one game in every mode (8 modes)';

  @override
  String get achTitleNightOwl => 'Night Owl';

  @override
  String get achDescNightOwl => 'Finish a game between midnight and 5 AM';

  @override
  String get achTitleEarlyBird => 'Early Bird';

  @override
  String get achDescEarlyBird => 'Finish a game between 5 and 8 AM';

  @override
  String get achTitleWeekendWarrior => 'Weekend Warrior';

  @override
  String get achDescWeekendWarrior => 'Finish 10 games on weekends';

  @override
  String get ppuMegaSpeedBoost => 'Mega Speed Boost';

  @override
  String get ppuMegaInvincibility => 'Mega Invincibility';

  @override
  String get ppuMegaScoreMultiplier => 'Mega Score Multiplier';

  @override
  String get ppuMegaSlowMotion => 'Mega Slow Motion';

  @override
  String get ppuTeleport => 'Teleport';

  @override
  String get ppuSizeReducer => 'Size Reducer';

  @override
  String get ppuScoreShield => 'Score Shield';

  @override
  String get ppuComboMultiplier => 'Combo Multiplier';

  @override
  String get ppuTimeWarp => 'Time Warp';

  @override
  String get ppuMagneticFood => 'Magnetic Food';

  @override
  String get ppuGhostMode => 'Ghost Mode';

  @override
  String get ppuDoubleTrouble => 'Double Trouble';

  @override
  String get ppuLuckyCharm => 'Lucky Charm';

  @override
  String get ppuPowerSurge => 'Power Surge';

  @override
  String get bundleMegaPack => 'Mega Power Pack';

  @override
  String get bundleMegaPackDesc => 'Enhanced versions of classic power-ups';

  @override
  String get skinClassic => 'Classic';

  @override
  String get skinGolden => 'Golden Snake';

  @override
  String get skinRainbow => 'Rainbow Snake';

  @override
  String get skinGalaxy => 'Galaxy Snake';

  @override
  String get skinDragon => 'Dragon Snake';

  @override
  String get skinElectric => 'Electric Snake';

  @override
  String get skinFire => 'Fire Snake';

  @override
  String get skinIce => 'Ice Snake';

  @override
  String get skinShadow => 'Shadow Snake';

  @override
  String get skinNeon => 'Neon Snake';

  @override
  String get skinCrystal => 'Crystal Snake';

  @override
  String get skinCosmic => 'Cosmic Snake';

  @override
  String get skinClassicDesc => 'The original snake appearance';

  @override
  String get skinGoldenDesc =>
      'Gleaming gold snake that shines with every move';

  @override
  String get skinRainbowDesc =>
      'A colorful snake that shifts through rainbow colors';

  @override
  String get skinGalaxyDesc => 'Cosmic snake with starry patterns';

  @override
  String get skinDragonDesc =>
      'Fierce dragon-scaled snake with mystical powers';

  @override
  String get skinElectricDesc => 'Crackling with electric energy';

  @override
  String get skinFireDesc => 'Burning bright with fiery patterns';

  @override
  String get skinIceDesc => 'Frozen beauty with crystalline effects';

  @override
  String get skinShadowDesc => 'Dark and mysterious shadow snake';

  @override
  String get skinNeonDesc => 'Glowing with cyberpunk neon lights';

  @override
  String get skinCrystalDesc =>
      'Translucent crystal snake with prismatic effects';

  @override
  String get skinCosmicDesc => 'Snake made of stardust and cosmic matter';

  @override
  String get trailNone => 'No Trail';

  @override
  String get trailParticle => 'Particle Trail';

  @override
  String get trailGlow => 'Glow Trail';

  @override
  String get trailRainbow => 'Rainbow Trail';

  @override
  String get trailFire => 'Fire Trail';

  @override
  String get trailElectric => 'Electric Trail';

  @override
  String get trailStar => 'Star Trail';

  @override
  String get trailCosmic => 'Cosmic Trail';

  @override
  String get trailNeon => 'Neon Trail';

  @override
  String get trailShadow => 'Shadow Trail';

  @override
  String get trailCrystal => 'Crystal Trail';

  @override
  String get trailDragon => 'Dragon Trail';

  @override
  String get trailNoneDesc => 'Clean snake with no trail effects';

  @override
  String get trailParticleDesc => 'Leaves a trail of sparkling particles';

  @override
  String get trailGlowDesc => 'Glowing trail that fades behind the snake';

  @override
  String get trailRainbowDesc => 'Colorful rainbow trail effect';

  @override
  String get trailFireDesc => 'Blazing fire trail with ember particles';

  @override
  String get trailElectricDesc =>
      'Crackling electric trail with lightning effects';

  @override
  String get trailStarDesc => 'Twinkling stars follow the snake\'s path';

  @override
  String get trailCosmicDesc => 'Cosmic dust and nebula effects';

  @override
  String get trailNeonDesc => 'Bright neon glow with cyberpunk style';

  @override
  String get trailShadowDesc => 'Dark shadow trail with smoky effects';

  @override
  String get trailCrystalDesc => 'Crystalline shards that fade away';

  @override
  String get trailDragonDesc => 'Mystical dragon breath trail';

  @override
  String get coinPackSmall => 'Starter Pack';

  @override
  String get coinPackMedium => 'Value Pack';

  @override
  String get coinPackLarge => 'Premium Pack';

  @override
  String get coinPackMega => 'Ultimate Pack';

  @override
  String coinsAmount(Object coins) {
    return '$coins coins';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus bonus';
  }

  @override
  String get boardSmall => 'Small';

  @override
  String get boardClassic => 'Classic';

  @override
  String get boardLarge => 'Large';

  @override
  String get boardHuge => 'Huge';

  @override
  String get boardEpic => 'Epic';

  @override
  String get boardMassive => 'Massive';

  @override
  String get boardUltimate => 'Ultimate';

  @override
  String get boardSmallDesc => 'Quick games, tight spaces';

  @override
  String get boardClassicDesc => 'The original Snake experience';

  @override
  String get boardLargeDesc => 'More room to grow';

  @override
  String get boardHugeDesc => 'Maximum challenge and space';

  @override
  String get boardEpicDesc => 'A big board for advanced players';

  @override
  String get boardMassiveDesc => 'Enormous board for epic games';

  @override
  String get boardUltimateDesc => 'The largest possible board';

  @override
  String get crashLabelSkip => 'Skip';

  @override
  String get crashLabelUntilTap => 'Until Tap';

  @override
  String get tgmClassic => 'Classic';

  @override
  String get tgmSpeedRun => 'Speed Run';

  @override
  String get tgmSurvival => 'Survival';

  @override
  String get tgmNoWalls => 'No Walls';

  @override
  String get tgmPowerUpMadness => 'Power-up Madness';

  @override
  String get tgmPerfectGame => 'Perfect Game';

  @override
  String get tgmClassicDesc => 'Standard Snake game rules';

  @override
  String get tgmSpeedRunDesc => 'Game speed increases rapidly';

  @override
  String get tgmSurvivalDesc => 'Survive as long as possible';

  @override
  String get tgmNoWallsDesc => 'Snake wraps around screen edges';

  @override
  String get tgmPowerUpMadnessDesc => 'Frequent power-ups spawn';

  @override
  String get tgmPerfectGameDesc => 'No mistakes allowed - one hit ends game';

  @override
  String get ttDaily => 'Daily Challenge';

  @override
  String get ttWeekly => 'Weekly Tournament';

  @override
  String get ttSpecial => 'Special Event';

  @override
  String get tsUpcoming => 'Upcoming';

  @override
  String get tsActive => 'Active';

  @override
  String get tsEnded => 'Ended';

  @override
  String get cdEasy => 'Easy';

  @override
  String get cdMedium => 'Medium';

  @override
  String get cdHard => 'Hard';

  @override
  String get usOnline => 'Online';

  @override
  String get usOffline => 'Offline';

  @override
  String get usPlaying => 'Playing';

  @override
  String get bprXpBoost => 'XP Boost';

  @override
  String get bprCoins => 'Coins';

  @override
  String get bprTheme => 'Theme';

  @override
  String get bprSkin => 'Snake Skin';

  @override
  String get bprTrail => 'Trail Effect';

  @override
  String get bprPowerUp => 'Power-Up';

  @override
  String get bprTournamentEntry => 'Tournament Entry';

  @override
  String get bprTitle => 'Player Title';

  @override
  String get bprAvatar => 'Avatar';

  @override
  String get bprSpecial => 'Special Reward';

  @override
  String get bprnStarDust => 'Star Dust';

  @override
  String get bprnEnergyPack => 'Energy Pack';

  @override
  String get bprnBronzeEntry => 'Bronze Entry';

  @override
  String get bprnSilverEntry => 'Silver Entry';

  @override
  String get bprnStargazer => 'Stargazer';

  @override
  String get bprnVoyager => 'Voyager';

  @override
  String get bprnNebulaTheme => 'Nebula Theme';

  @override
  String get bprnStardustTrail => 'Stardust Trail';

  @override
  String get bprnLegendaryCrate => 'Legendary Crate';

  @override
  String get bprnMegaXp => 'Mega XP';

  @override
  String get bprnCosmicCharge => 'Cosmic Charge';

  @override
  String get bprnNovaBurst => 'Nova Burst';

  @override
  String get bprnGalaxySkin => 'Galaxy Skin';

  @override
  String get bprnCrystalSerpent => 'Crystal Serpent';

  @override
  String get bprnPlasmaWake => 'Plasma Wake';

  @override
  String get bprnCosmicAura => 'Cosmic Aura';

  @override
  String get bprnCyberpunkTheme => 'Cyberpunk Theme';

  @override
  String get bprnCrystalTheme => 'Crystal Theme';

  @override
  String get bprnSeasonTrophy => 'Season Trophy';

  @override
  String get bprnCosmicCrown => 'Cosmic Crown';

  @override
  String get bprnCosmicLegend => 'Cosmic Legend';

  @override
  String get bprnStarCommander => 'Star Commander';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity Coins';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'Free $type reward';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'Exclusive premium $type reward';
  }

  @override
  String get insHowToPlay => 'HOW TO PLAY';

  @override
  String get insObjective => 'OBJECTIVE';

  @override
  String get insObjectiveBody =>
      'Control the snake to eat food and grow as long as possible without hitting walls or yourself!';

  @override
  String get insControls => 'CONTROLS';

  @override
  String get insSwipeUp => 'Swipe Up ↑';

  @override
  String get insSwipeUpDesc => 'Move snake up';

  @override
  String get insSwipeDown => 'Swipe Down ↓';

  @override
  String get insSwipeDownDesc => 'Move snake down';

  @override
  String get insSwipeLeft => 'Swipe Left ←';

  @override
  String get insSwipeLeftDesc => 'Move snake left';

  @override
  String get insSwipeRight => 'Swipe Right →';

  @override
  String get insSwipeRightDesc => 'Move snake right';

  @override
  String get insArrowKeys => 'Arrow keys';

  @override
  String get insArrowKeysDesc => 'Change direction';

  @override
  String get insWasd => 'WASD';

  @override
  String get insWasdDesc => 'Change direction';

  @override
  String get insSpacebar => 'Spacebar';

  @override
  String get insSpacebarDesc => 'Pause/Resume game';

  @override
  String get insFoodTypes => 'FOOD TYPES';

  @override
  String get insNormalFood => 'Normal Food';

  @override
  String get insBonusFood => 'Bonus Food';

  @override
  String get insSpecialFood => 'Special Food';

  @override
  String get insRules => 'RULES';

  @override
  String get insRule1 => 'Eat food to grow and increase score';

  @override
  String get insRule2 => 'Snake speeds up as you level up';

  @override
  String get insRule3 => 'Game ends if you hit walls or yourself';

  @override
  String get insRule4 => 'Special food appears every 10 normal foods';

  @override
  String get insRule5 => 'Bonus food expires after 15 seconds';

  @override
  String get insProTips => 'PRO TIPS';

  @override
  String get insTip1 => 'Plan your moves ahead of time';

  @override
  String get insTip2 => 'Use edges to create safe spaces';

  @override
  String get insTip3 => 'Watch for visual swipe feedback';

  @override
  String get insTip4 => 'Practice different difficulty levels';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return 'Claimed $coins coins and $xp XP!';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return 'Claimed $coins coins!';
  }

  @override
  String get dchWatchTo2x => 'WATCH TO 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 Doubled! +$coins bonus coins!';
  }

  @override
  String get dchAllCompleteTitle => 'All Challenges Complete!';

  @override
  String get dchBonusClaimed => 'Bonus reward claimed';

  @override
  String get dchBonusPending => 'Bonus reward pending — claim any challenge';

  @override
  String get dchCheckBack => 'Check back later for new daily challenges!';

  @override
  String get dchAbout => 'About Daily Challenges';

  @override
  String get dchAbout1 => 'New challenges every day at midnight';

  @override
  String get dchAbout2 => 'Complete challenges to earn coins';

  @override
  String get dchAbout3 => 'Gain XP to level up your profile';

  @override
  String get dchAbout4 => 'Complete all 3 for a bonus reward!';

  @override
  String get dchAllBonusTitle => 'All Challenges Bonus';

  @override
  String get dchAllBonusDesc => 'Completed every daily challenge today.';

  @override
  String get wqNoQuests => 'No weekly quests yet — check back Monday';

  @override
  String get wqTitle => 'Weekly Quests';

  @override
  String get rvNotFound => 'Replay not found';

  @override
  String get rvLoadFailed => 'Failed to load replay';

  @override
  String get rvLoadingTitle => 'Loading Replay...';

  @override
  String get rvLoading => 'Loading replay...';

  @override
  String get rvGoBack => 'Go Back';

  @override
  String get rvScore => 'Score';

  @override
  String get rvLevel => 'Level';

  @override
  String get rvFrame => 'Frame';

  @override
  String get rvTime => 'Time';

  @override
  String get rvNoFrameData => 'No frame data';

  @override
  String get rvSpeedLabel => 'Speed: ';

  @override
  String rvAteFood(Object type) {
    return '🍎 Ate $type food';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ Collected $type power-up';
  }

  @override
  String get unEmpty => 'Username cannot be empty';

  @override
  String get unSetFailed => 'Failed to set username';

  @override
  String get unPickTitle => 'Pick your username';

  @override
  String get unPickBody =>
      'It\'s how you\'ll show up on the leaderboard. We\'ve picked one for you — keep it or change it.';

  @override
  String get unLabel => 'Username';

  @override
  String get unSaving => 'SAVING...';

  @override
  String get unContinue => 'CONTINUE';

  @override
  String get unChangeAnytime => 'You can change this anytime in Settings.';

  @override
  String unMinLength(Object min) {
    return 'Username must be at least $min characters long';
  }

  @override
  String unMaxLength(Object max) {
    return 'Username must be no more than $max characters long';
  }

  @override
  String get unPattern =>
      'Username must start with a letter and contain only letters, numbers, and underscores';

  @override
  String get unReserved => 'This username is reserved and cannot be used';

  @override
  String get unTaken => 'This username is already taken';

  @override
  String get unUpdateFailed => 'Failed to update username';

  @override
  String pcVersionLine(Object version) {
    return 'Version $version · please review and accept to continue';
  }

  @override
  String get pcTabPrivacy => 'Privacy Policy';

  @override
  String get pcTabTerms => 'Terms of Use';

  @override
  String get pcAgree =>
      'I have read and agree to the updated Privacy Policy and Terms of Use';

  @override
  String get pcContinue => 'Continue';

  @override
  String lgAvailableAt(Object url) {
    return 'This document is available at $url.';
  }

  @override
  String get lgUnavailable =>
      'This document is currently unavailable. Please try again later.';

  @override
  String get auTitle => 'Sign up to make purchases';

  @override
  String get auBody =>
      'Guest accounts can play and save progress locally, but cannot buy items or subscribe. Link an account to unlock purchases — your existing coins, cosmetics, and high scores stay attached.';

  @override
  String get auApple => 'Continue with Apple';

  @override
  String get auAppleSub =>
      'Sign in with your Apple ID. Your email can stay private.';

  @override
  String get auGoogle => 'Continue with Google';

  @override
  String get auGoogleSub => 'Fastest option. Sign in with your Google account.';

  @override
  String get auLinked => 'Account linked. You can now make purchases.';

  @override
  String get auEmail => 'Create an Email Account';

  @override
  String get auEmailSub =>
      'Use any email and a password you choose. Restore on any device.';

  @override
  String get auNotNow => 'Not now';

  @override
  String get auErrCredentialInUse =>
      'That credential is already linked to another account. Try signing in with it instead.';

  @override
  String get auErrAlreadyLinked => 'This account is already linked.';

  @override
  String get auErrRequiresRecentLogin =>
      'For security, sign in again before linking.';

  @override
  String get auErrNetwork => 'Network error. Check your connection.';

  @override
  String get auErrGeneric => 'Linking failed. Please try again.';

  @override
  String get sroSettingUpTitle => 'Setting up your account…';

  @override
  String get sroSettingUpBody =>
      'Getting things ready for your first session. This only happens once.';

  @override
  String get sroLoadingTitle => 'Loading your previous data…';

  @override
  String get sroLoadingBody =>
      'Fetching your stats, achievements, coins, and unlocks from the cloud.';

  @override
  String get sroRestoringTitle => 'Restoring your progress…';

  @override
  String get sroRestoringBody =>
      'Applying everything to this device. Don\'t close the app.';

  @override
  String get sroDoneTitle => 'All set!';

  @override
  String get sroDoneBody => 'Your progress has been restored.';

  @override
  String get sroFailedTitle => 'Couldn\'t restore your data';

  @override
  String get sroFailedBody =>
      'We couldn\'t reach the cloud just now. Check your internet connection and try again. You can also continue without restoring — we\'ll retry the next time you open the app.';

  @override
  String get sroTryAgain => 'Try Again';

  @override
  String get sroContinueAnyway => 'Continue Anyway';

  @override
  String get ssiOfflinePending => 'Offline - Changes will sync when connected';

  @override
  String get ssiSyncing => 'Syncing...';

  @override
  String get ssiAllSynced => 'All data synced';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items failed to sync',
      one: '1 item failed to sync',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items pending sync',
      one: '1 item pending sync',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'Offline';

  @override
  String get rvoLoadingAd => 'Loading ad…';

  @override
  String get tbTimesUp => 'TIME\'S UP!';

  @override
  String tbKeepGoing(Object seconds) {
    return 'Keep going · ${seconds}s';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'Watch ad — +${seconds}s';
  }

  @override
  String get tbEndRun => 'End run';

  @override
  String get dbTitle => 'Daily Bonus';

  @override
  String get dbClaimToday => 'Claim your daily reward!';

  @override
  String get dbComeBack => 'Come back tomorrow!';

  @override
  String dbDayChip(Object day) {
    return 'D$day';
  }

  @override
  String get dbTodaysReward => 'Today\'s Reward';

  @override
  String get dbAlreadyClaimed => 'Already claimed today';

  @override
  String get dbClaim => 'CLAIM REWARD';

  @override
  String get dbClaim2x => 'CLAIM 2× — WATCH AD';

  @override
  String get npPrimerTitle => 'Don\'t miss out!';

  @override
  String get npPrimerBody =>
      'We only send a couple of notifications a day — your daily challenge reminder and special events.\n\nNo spam, promise. 🐍';

  @override
  String get npMaybeLater => 'Maybe later';

  @override
  String get npAllSet => '🎉 You\'re all set!';

  @override
  String get npTurnOn => 'Turn on';

  @override
  String get npSoftTitle => 'Stay in the loop?';

  @override
  String get npSoftBody =>
      'Turn on notifications and we\'ll remind you about your daily challenges and streaks — plus the big stuff like FREE Premium giveaways and special events.\n\nJust a couple a day, no spam. 🐍';

  @override
  String get npNotNow => 'Not now';

  @override
  String get npEnable => 'Enable notifications';

  @override
  String get aroUnlocked => 'ACHIEVEMENT UNLOCKED';

  @override
  String get aroTapToContinue => 'Tap to continue';

  @override
  String get aroSkip => 'SKIP';

  @override
  String aroSkipCount(Object count) {
    return 'SKIP ($count)';
  }

  @override
  String get luLevelUp => 'LEVEL UP!';

  @override
  String luReached(Object level) {
    return 'You reached Level $level';
  }

  @override
  String get luNice => 'NICE';

  @override
  String get cfTapContinue => 'Tap anywhere to continue';

  @override
  String get cfTapSkip => 'Tap anywhere to skip';

  @override
  String get xgTitle => 'Exit Game?';

  @override
  String get xgBody =>
      'Are you sure you want to exit? Your current progress will be lost.';

  @override
  String get xgExit => 'Exit';

  @override
  String get ccTitle => 'How do you want to play?';

  @override
  String get ccBody =>
      'Pick one — you can change it anytime in Settings → Controls.';

  @override
  String get ccSwipe => 'Swipe Gestures';

  @override
  String get ccSwipeSub => 'Swipe anywhere on the board to turn.';

  @override
  String get ccDpad => 'D-Pad Controls';

  @override
  String get ccDpadSub => 'On-screen directional buttons.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 +$coins coins added to your wallet!';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'Watch an ad — +$coins coins';
  }

  @override
  String get rcNoAd => 'No ad available right now';

  @override
  String get raOptIn => 'Opt-in — watch to earn';

  @override
  String get compassSemantics => 'Swipe direction indicator';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 Daily bonus doubled — +$coins bonus coins!';
  }

  @override
  String get nsNewNotification => 'You have a new notification';

  @override
  String get nsAchievementUnlocked => '🏆 Achievement Unlocked!';

  @override
  String get nsDailyReminderTitle => '🐍 Time to play Snake Classic!';

  @override
  String get nsDailyReminderBody =>
      'Complete your daily challenge and climb the leaderboard!';

  @override
  String get mpErrMatchmaking => 'Matchmaking failed. Please try again.';

  @override
  String get mpErrCreateFailed => 'Failed to create game';

  @override
  String get mpErrJoinFailed =>
      'Failed to join game. Game might be full or not exist.';

  @override
  String get mpErrReadyFailed => 'Failed to update ready status';

  @override
  String get mpErrStartFailed => 'Failed to start game';

  @override
  String get mpErrStartTimeout => 'Start game timed out. Please try again.';

  @override
  String get mpErrReconnectFailed => 'Could not reconnect to the match.';

  @override
  String get mpErrConnectionLost =>
      'Connection lost — the match could not be resumed.';

  @override
  String get mpErrMatchEndedAway => 'The match ended while you were away.';

  @override
  String get mpErrWaitingReady => 'Waiting for all players to be ready';

  @override
  String get mpErrOnlyHost => 'Only the host can start the game';

  @override
  String get mpErrSessionExpired =>
      'Game session expired. Please create a new game';

  @override
  String get mpErrAlreadyStarted => 'This game has already started';

  @override
  String get mpErrNeedTwoPlayers => 'Matches need exactly 2 players';

  @override
  String get mpErrSignIn => 'Please sign in to play multiplayer';

  @override
  String get mpErrReconnectExpired => 'Reconnection time expired';

  @override
  String get mpErrCheckInternet =>
      'Connection lost. Please check your internet';

  @override
  String get mpErrUnableJoin => 'Unable to join room. Please try again';

  @override
  String get mpErrGeneric => 'Something went wrong. Please try again';

  @override
  String stDurSeconds(Object s) {
    return '${s}s';
  }

  @override
  String stDurMinutes(Object m) {
    return '${m}m';
  }

  @override
  String stDurHours(Object h) {
    return '${h}h';
  }

  @override
  String stDurMinSec(Object m, Object s) {
    return '${m}m ${s}s';
  }

  @override
  String stDurHourMin(Object h, Object m) {
    return '${h}h ${m}m';
  }

  @override
  String wqClaimable(Object count) {
    return '$count claimable';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins coins, +$xp BP XP';
  }

  @override
  String get insPoints10 => '10 points';

  @override
  String get insPoints25 => '25 points';

  @override
  String get insPoints50 => '50 points + Level Up';

  @override
  String get unRules =>
      '• 3-20 characters\n• Must start with a letter\n• Letters, numbers, and underscores only';

  @override
  String get dcTitleScoreEasy => 'Beginner Score';

  @override
  String get dcTitleScoreMedium => 'Skilled Player';

  @override
  String get dcTitleScoreHard => 'Score Master';

  @override
  String get dcTitleFoodEasy => 'Hungry Snake';

  @override
  String get dcTitleFoodMedium => 'Feast Mode';

  @override
  String get dcTitleFoodHard => 'Insatiable';

  @override
  String get dcTitleSurvivalEasy => 'Survivor';

  @override
  String get dcTitleSurvivalMedium => 'Endurance';

  @override
  String get dcTitleSurvivalHard => 'Immortal';

  @override
  String get dcTitleGamesEasy => 'Casual Player';

  @override
  String get dcTitleGamesMedium => 'Dedicated';

  @override
  String get dcTitleGamesHard => 'Snake Addict';

  @override
  String get dcTitleModeEasy => 'Classic Lover';

  @override
  String get dcTitleModeMedium => 'Zen Master';

  @override
  String get dcTitleModeHard => 'Speed Demon';

  @override
  String dcDescScore(Object target) {
    return 'Score at least $target points in a single game';
  }

  @override
  String dcDescFood(Object target) {
    return 'Eat $target foods today';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'Survive for $target seconds in a single game';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Play $target games today',
      one: 'Play 1 game today',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Play $target games in $mode mode',
      one: 'Play 1 game in $mode mode',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'Weekly Warmup';

  @override
  String get wqTitleScoreMedium => 'Sharper Reflexes';

  @override
  String get wqTitleScoreHard => 'Score Champion';

  @override
  String get wqTitleFoodEasy => 'Weekly Snacker';

  @override
  String get wqTitleFoodMedium => 'Voracious';

  @override
  String get wqTitleFoodHard => 'Bottomless';

  @override
  String get wqTitleGamesEasy => 'Five-a-Week';

  @override
  String get wqTitleGamesMedium => 'Routine Hatched';

  @override
  String get wqTitleGamesHard => 'Marathon Hatcher';

  @override
  String get wqTitleSurvivalEasy => 'Two-Minute Slither';

  @override
  String get wqTitleSurvivalMedium => 'Five-Minute Slither';

  @override
  String get wqTitleSurvivalHard => 'Ten-Minute Slither';

  @override
  String get wqTitleTournament => 'Tournament Regular';

  @override
  String get wqTitleDailyEasy => 'Daily Doer';

  @override
  String get wqTitleDailyMedium => 'Daily Adept';

  @override
  String wqDescScore(Object target) {
    return 'Score $target in a single game';
  }

  @override
  String wqDescFood(Object target) {
    return 'Eat $target foods this week';
  }

  @override
  String wqDescGames(Object target) {
    return 'Play $target games this week';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'Survive ${target}s in a single game';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Play $target tournament games',
      one: 'Play 1 tournament game',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'Complete $target daily challenges this week';
  }

  @override
  String tnNameDaily(Object date) {
    return 'Daily Challenge - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'Weekly Championship - Week $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'Monthly Grand Prix - $monthYear';
  }

  @override
  String get tnDescDaily =>
      'Compete for the highest score in today\'s 24-hour challenge! Top players win coins and glory.';

  @override
  String get tnDescWeekly =>
      'The ultimate weekly showdown! Compete against the best players for massive rewards.';

  @override
  String get tnDescMonthly =>
      'The biggest tournament of the month! Prove you\'re the ultimate Snake master.';

  @override
  String tnRewardRank(Object rank) {
    return 'Rank $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'Coin reward for rank $rank';
  }

  @override
  String get achTitleScore1500 => 'Momentum';

  @override
  String get achDescScore1500 => 'Score 1,500 points in a single game';

  @override
  String get achTitleScore3000 => 'On a Tear';

  @override
  String get achDescScore3000 => 'Score 3,000 points in a single game';

  @override
  String get achTitleScore7500 => 'Unrelenting';

  @override
  String get achDescScore7500 => 'Score 7,500 points in a single game';

  @override
  String get achTitleScore15000 => 'Apex Hunter';

  @override
  String get achDescScore15000 => 'Score 15,000 points in a single game';

  @override
  String get achTitleScore35000 => 'Machine Mind';

  @override
  String get achDescScore35000 => 'Score 35,000 points in a single game';

  @override
  String get achTitleScore75000 => 'Beyond Mortal';

  @override
  String get achDescScore75000 => 'Score 75,000 points in a single game';

  @override
  String get achTitleScore250000 => 'Quarter Million';

  @override
  String get achDescScore250000 => 'Score 250,000 points in a single game';

  @override
  String get achTitleBeyondTime => 'Beyond Time';

  @override
  String get achDescBeyondTime => 'Survive 45 minutes in a single game';

  @override
  String get achTitleHourbound => 'Hourbound';

  @override
  String get achDescHourbound => 'Survive a full hour in a single game';

  @override
  String get achTitleSnakeDevotee => 'Snake Devotee';

  @override
  String get achDescSnakeDevotee => 'Play 2,500 games';

  @override
  String get achTitleTenThousandClub => 'Ten Thousand Club';

  @override
  String get achDescTenThousandClub => 'Play 10,000 games';

  @override
  String get achTitleZenVeteran => 'Zen Veteran';

  @override
  String get achDescZenVeteran => 'Finish 100 Zen games';

  @override
  String get achTitleSpeedVeteran => 'Speed Veteran';

  @override
  String get achDescSpeedVeteran => 'Finish 100 Speed Challenge games';

  @override
  String get achTitleMultifoodVeteran => 'MultiFood Veteran';

  @override
  String get achDescMultifoodVeteran => 'Finish 100 MultiFood games';

  @override
  String get achTitleTimeattackVeteran => 'TimeAttack Veteran';

  @override
  String get achDescTimeattackVeteran => 'Finish 100 TimeAttack games';

  @override
  String get achTitleSurvivalVeteran => 'Survival Veteran';

  @override
  String get achDescSurvivalVeteran => 'Finish 100 Survival games';

  @override
  String get achTitlePumInitiate => 'Madness Initiate';

  @override
  String get achDescPumInitiate => 'Finish 10 Power-Up Madness games';

  @override
  String get achTitlePumVeteran => 'Madness Veteran';

  @override
  String get achDescPumVeteran => 'Finish 100 Power-Up Madness games';

  @override
  String get achTitlePerfectInitiate => 'Purist';

  @override
  String get achDescPerfectInitiate => 'Finish 10 Perfect Game runs';

  @override
  String get achTitlePerfectVeteran => 'Discipline';

  @override
  String get achDescPerfectVeteran => 'Finish 100 Perfect Game runs';

  @override
  String get achTitleZen10000 => 'Zen Overflow';

  @override
  String get achDescZen10000 => 'Score 10,000 in Zen mode';

  @override
  String get achTitleSpeed5000 => 'Blur';

  @override
  String get achDescSpeed5000 => 'Score 5,000 in Speed Challenge';

  @override
  String get achTitleMultifood10000 => 'Endless Buffet';

  @override
  String get achDescMultifood10000 => 'Score 10,000 in MultiFood';

  @override
  String get achTitleTimeattack5000 => 'Race the Clock';

  @override
  String get achDescTimeattack5000 => 'Score 5,000 in TimeAttack';

  @override
  String get achTitlePum2000 => 'Charged Up';

  @override
  String get achDescPum2000 => 'Score 2,000 in Power-Up Madness';

  @override
  String get achTitlePerfect1000 => 'Flawless Run';

  @override
  String get achDescPerfect1000 => 'Score 1,000 in Perfect Game mode';

  @override
  String get achTitleComboSingularity => 'Combo Singularity';

  @override
  String get achDescComboSingularity => 'Hit a 200x combo in a single game';

  @override
  String get achTitleWorldSerpent => 'World Serpent';

  @override
  String get achDescWorldSerpent => 'Grow snake to length 750';

  @override
  String get achTitleLightspeed => 'Lightspeed';

  @override
  String get achDescLightspeed => 'Reach in-game level 30 in one game';

  @override
  String get achTitlePowerOverwhelming => 'Power Overwhelming';

  @override
  String get achDescPowerOverwhelming => 'Collect 5,000 power-ups lifetime';

  @override
  String get achTitleGreedIsGood => 'Greed Is Good';

  @override
  String get achDescGreedIsGood => 'Collect 25 Score Multiplier power-ups';

  @override
  String get achTitleTimeBender => 'Time Bender';

  @override
  String get achDescTimeBender => 'Collect 25 Slow Motion power-ups';

  @override
  String get achTitleGastronome => 'Gastronome';

  @override
  String get achDescGastronome => 'Eat 100,000 foods lifetime';

  @override
  String get achTitleLivingLegend => 'Living Legend';

  @override
  String get achDescLivingLegend => 'Accumulate 50,000,000 points lifetime';

  @override
  String get achTitlePerpetualMotion => 'Perpetual Motion';

  @override
  String get achDescPerpetualMotion => '50-game streak (30s+ each)';

  @override
  String get achTitleImmaculate => 'Immaculate';

  @override
  String get achDescImmaculate => 'Complete 100 perfect games';

  @override
  String get achTitleFortnightFaithful => 'Fortnight Faithful';

  @override
  String get achDescFortnightFaithful => 'Play on 14 consecutive days';

  @override
  String get achTitleSteadySnake => 'Steady Snake';

  @override
  String get achDescSteadySnake => 'Survive 30+ seconds in 100 games';

  @override
  String get achTitleMarathonMonth => 'Marathon Spirit';

  @override
  String get achDescMarathonMonth => 'Survive 30+ seconds in 1,000 games';

  @override
  String get achTitleLunchtimeLegend => 'Lunchtime Legend';

  @override
  String get achDescLunchtimeLegend => 'Finish a game between noon and 2 PM';

  @override
  String get legalNoticePrefix => 'By playing, you agree to our ';

  @override
  String get legalNoticeAnd => ' and ';

  @override
  String get dayOneReminderTitle => 'Your snake misses you 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'Your best is $score. Think you can beat it?';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      'One quick run? Your first high score is waiting.';

  @override
  String get rvAteFoodUnknown => '🍎 Ate food';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ Collected a power-up';

  @override
  String get boardTall => 'Tall';

  @override
  String get boardTallDesc => 'Fills a phone screen — more room to run';

  @override
  String get boardTallPlus => 'Tall Plus';

  @override
  String get boardTallPlusDesc => 'A bigger phone-shaped arena';

  @override
  String get mpErrReadyTimeout =>
      'Both players weren\'t ready in time. Finding you a new match…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'Ready check · ${seconds}s';
  }

  @override
  String get mpLobbyWaitingOpponentReady =>
      'Waiting for your opponent to get ready…';

  @override
  String get gameDirectionalPad => 'Directional pad';

  @override
  String get gamePauseGame => 'Pause game';

  @override
  String get gameResumeGame => 'Resume game';

  @override
  String get gameLeaveMatch => 'Leave match';

  @override
  String get gameSteerUp => 'Steer up';

  @override
  String get gameSteerDown => 'Steer down';

  @override
  String get gameSteerLeft => 'Steer left';

  @override
  String get gameSteerRight => 'Steer right';

  @override
  String get mpTurnBlocked => 'Blocked';

  @override
  String get insHudPause => 'Pause Button';

  @override
  String get insHudPauseDesc =>
      'Pause or resume — top right of the game screen';

  @override
  String get insDpad => 'On-Screen D-Pad';

  @override
  String get insDpadDesc =>
      'Optional four-way buttons for turning, instead of swiping';

  @override
  String get insControlsNote =>
      'Turn on-screen controls on or off, choose D-Pad, Turn buttons or Joystick, and set Snap Movement in Settings → Controls — or from the pause menu mid-run.';

  @override
  String get insVersus => 'Versus';

  @override
  String get insVersusOnline => 'Online 1v1';

  @override
  String get insVersusOnlineDesc =>
      'Classic rules, two snakes, one board, in real time';

  @override
  String get insVersusQuick => 'Quick Match';

  @override
  String get insVersusQuickDesc => 'Finds you an opponent automatically';

  @override
  String get insVersusRoom => 'Private Room';

  @override
  String get insVersusRoomDesc =>
      'Create a room and share the code, or join a friend’s';

  @override
  String get homeVersusCta => 'VERSUS';

  @override
  String get homeVersusSubtitle =>
      '1v1 Classic · Quick match or invite a friend';

  @override
  String get hwVersusTitle => 'Play someone else';

  @override
  String get hwVersusMsg =>
      'Versus is online 1v1 Classic. Quick Match finds you an opponent, or create a private room and invite a friend.';

  @override
  String get hwHelpTitle => 'Anything else?';

  @override
  String get hwHelpMsg =>
      'Rules, controls and Versus are all explained here. Settings sits right beside it.';

  @override
  String get insOnPhone => 'On your phone';

  @override
  String get insOnKeyboard => 'On a keyboard';

  @override
  String get settingsSectionYourGame => 'YOUR GAME';

  @override
  String get settingsStatisticsSubtitle =>
      'Every run you have played, counted up';

  @override
  String get settingsReplaysSubtitle => 'Watch your saved runs back';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String version) {
    return 'Snake Classic $version is on the App Store. Update for the latest features and fixes.';
  }

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'This version of Snake Classic is no longer supported. Please update from the App Store to keep playing.';

  @override
  String get updateActionUpdate => 'Update';

  @override
  String get updateActionLater => 'Later';

  @override
  String get updateOpenStoreFailed => 'Could not open the App Store';

  @override
  String get lbHomeHint => 'STEER INTO A BLOCK. OR TAP. WE DON\'T JUDGE.';

  @override
  String get lbDailyAllFed => 'ALL FED. COME BACK TOMORROW.';

  @override
  String lbModeRow(String index, String count, String mode) {
    return 'MODE $index/$count · $mode';
  }

  @override
  String get lbYourBest => 'YOUR BEST';

  @override
  String get lbPlay => 'PLAY';

  @override
  String lbModeBoard(String mode, String board) {
    return '$mode · $board';
  }

  @override
  String get lbHomeVersus => 'VERSUS';

  @override
  String lbHomeVersusSub(String rating) {
    return '1v1 · rating $rating';
  }

  @override
  String lbHomeDaily(String done, String total) {
    return 'DAILY $done/$total';
  }

  @override
  String lbHomeDailySub(String time, String coins) {
    return 'resets in $time · +$coins¢';
  }

  @override
  String get lbHomeSeason => 'SEASON';

  @override
  String lbHomeSeasonSub(String tier, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return 'Tier $tier · $_temp0';
  }

  @override
  String get lbHomeRanks => 'RANKS';

  @override
  String lbHomeRanksSub(String rank) {
    return '#$rank · climbing';
  }

  @override
  String lbHomeRanksSubNone(String score) {
    return 'Best run: $score';
  }

  @override
  String get lbHomeStore => 'STORE';

  @override
  String get lbHomeStoreSub => 'Skins, themes, trails';

  @override
  String get lbHomeProfile => 'PROFILE';

  @override
  String lbHomeProfileSub(String level, String runs) {
    return 'LV $level · $runs runs';
  }

  @override
  String get lbHomeMenu => 'MENU';

  @override
  String get lbFreePowerUp => 'FREE POWER-UP · AD';

  @override
  String get lbTipLabel => 'TIP';

  @override
  String get lbTip1 => 'The wall doesn\'t move. You do.';

  @override
  String get lbTip2 => 'Combos decay after 6 seconds. Keep chewing.';

  @override
  String get lbTip3 => 'Zen mode has no walls. It still has you.';

  @override
  String get lbTip4 => 'Easy runs stay off the leaderboard. No shame.';

  @override
  String get lbTip5 => 'Bonus food is worth 25. Special is 50. Greed is free.';

  @override
  String get lbTip6 => 'Swipe early. The snake doesn\'t do sudden.';

  @override
  String get lbTip7 =>
      'Perfect Game: never step on the same cell twice. Good luck.';

  @override
  String get lbTip8 => 'Pro players revive free. Just saying.';

  @override
  String lbSplashStatus(String pct) {
    return 'WARMING UP THE APPLES… $pct%';
  }

  @override
  String lbSplashFooter(String version) {
    return 'v$version · NO SNAKES WERE HARMED';
  }

  @override
  String get lbSetupTitle => 'SETUP';

  @override
  String get lbSetupSubtitle =>
      'Pick your poison. Every mode is free. Forever.';

  @override
  String get lbSetupMode => 'MODE';

  @override
  String lbSetupModesAside(String count) {
    return '$count MODES · 0 PAYWALLS';
  }

  @override
  String get lbSetupBoard => 'BOARD';

  @override
  String get lbSetupDifficulty => 'DIFFICULTY';

  @override
  String get lbSetupLoadout => 'LOADOUT';

  @override
  String get lbSetupGet => 'GET';

  @override
  String get lbBoardTall => 'TALL';

  @override
  String get lbModeLineClassic => 'Walls bite.';

  @override
  String get lbModeLineZen => 'No walls. Just vibes.';

  @override
  String get lbModeLineSpeed => 'Fast. Then faster.';

  @override
  String get lbModeLineMultiFood => 'The buffet is open.';

  @override
  String get lbModeLineSurvival => '3 lives. Spend wisely.';

  @override
  String get lbModeLineTimeAttack => '3 minutes. Eat it all.';

  @override
  String get lbModeLinePowerUp => 'Power-ups. So many.';

  @override
  String get lbModeLinePerfect => 'Never step twice.';

  @override
  String get lbDiffEasyLine => 'practice · unranked';

  @override
  String get lbDiffNormalLine => 'the classic pace';

  @override
  String get lbDiffHardLine => 'for show-offs';

  @override
  String lbComboWarm(String mult) {
    return '×$mult WARM';
  }

  @override
  String lbComboHot(String mult) {
    return '×$mult HOT · KEEP EATING';
  }

  @override
  String lbComboFire(String mult) {
    return '×$mult ON FIRE';
  }

  @override
  String get lbComboDecay => 'EAT SOMETHING. NOW.';

  @override
  String get lbComboBroken => 'combo dropped. it happens.';

  @override
  String lbLevelUp(String level) {
    return 'LV $level · FASTER NOW';
  }

  @override
  String lbLevelShort(String level) {
    return 'LV $level';
  }

  @override
  String lbPowerInvincible(String secs) {
    return 'INVINCIBLE · ${secs}s';
  }

  @override
  String get lbPowerInvincibleLine => 'walls are more of a suggestion';

  @override
  String lbPowerSpeed(String secs) {
    return 'SPEED · ${secs}s';
  }

  @override
  String get lbPowerSpeedLine => 'hold on';

  @override
  String lbPowerSlow(String secs) {
    return 'SLOW-MO · ${secs}s';
  }

  @override
  String get lbPowerSlowLine => 'savor it';

  @override
  String lbPowerScore(String secs) {
    return '2× SCORE · ${secs}s';
  }

  @override
  String lbPowerEnding(String name, String secs) {
    return '$name ENDING · $secs';
  }

  @override
  String get lbTimeAttackPanic => '10 SECONDS. PANIC RESPONSIBLY.';

  @override
  String lbLifeLost(String left) {
    return '1 LIFE DOWN · $left TO GO';
  }

  @override
  String lbHudLen(String len) {
    return 'LEN $len';
  }

  @override
  String get lbScoreLabel => 'SCORE';

  @override
  String get lbTurnLeft => 'TURN LEFT';

  @override
  String get lbTurnRight => 'TURN RIGHT';

  @override
  String get lbSwipeToSteer => 'SWIPE TO STEER';

  @override
  String get lbPauseTitle => 'PAUSED';

  @override
  String get lbPauseLine => 'The apple will wait. Probably.';

  @override
  String get lbResume => 'RESUME';

  @override
  String get lbResumeSub => '3 · 2 · 1, THEN GO';

  @override
  String get lbRestart => 'RESTART';

  @override
  String get lbRestartSub => 'same mode';

  @override
  String get lbPauseSettings => 'SETTINGS';

  @override
  String get lbPauseSettingsSub => 'controls · sound';

  @override
  String get lbQuit => 'QUIT TO MENU';

  @override
  String get lbQuitSub => 'run ends here';

  @override
  String lbPauseSoFar(String score, String len, String time) {
    return 'SO FAR · $score PTS · LEN $len · $time';
  }

  @override
  String get lbCrashWallTitle => 'BONK!';

  @override
  String lbCrashWall1(String len) {
    return 'You kissed the wall at length $len.';
  }

  @override
  String get lbCrashWall2 => 'The wall was there first.';

  @override
  String get lbCrashWall3 => 'Walls: undefeated since forever.';

  @override
  String get lbCrashWallScore => 'THE WALL: 1 · YOU: 0';

  @override
  String get lbCrashSelfTitle => 'OUCH.';

  @override
  String get lbCrashSelf1 => 'You bit yourself. Why?';

  @override
  String get lbCrashSelf2 => 'Tail: delicious, apparently.';

  @override
  String get lbCrashSelf3 => 'Self-snack detected.';

  @override
  String get lbCrashTimeTitle => 'TIME!';

  @override
  String get lbCrashTime1 => 'Out of time. The apples got away.';

  @override
  String lbCrashTime2(String food) {
    return 'Three minutes, $food apples. Respect.';
  }

  @override
  String get lbCrashStepTitle => 'STEPPED.';

  @override
  String get lbCrashStep1 =>
      'You walked on your own path. Perfect Game is not forgiving.';

  @override
  String get lbCrashQuitTitle => 'BAILED.';

  @override
  String get lbCrashQuit1 => 'Run ended by you. We saw nothing.';

  @override
  String get lbCrashGeneric => 'Game over.';

  @override
  String lbGameOverHeadline(String line) {
    return '× $line';
  }

  @override
  String get lbReviveTitle => 'SECOND CHANCE?';

  @override
  String lbSeconds(String secs) {
    return '${secs}s';
  }

  @override
  String lbReviveLine(String len, String score) {
    return 'Keep length $len and all $score points.';
  }

  @override
  String get lbReviveWatch => 'WATCH AD · FREE';

  @override
  String lbRevivePay(String cost) {
    return 'PAY $cost¢';
  }

  @override
  String lbReviveYouHave(String coins) {
    return 'you have $coins';
  }

  @override
  String get lbReviveDecline => 'NAH, SHOW ME MY SCORE';

  @override
  String get lbRevivePro => 'REVIVE · FREE WITH PRO';

  @override
  String get lbReviveProHint => 'Pro players revive free. Just saying.';

  @override
  String get lbGoBest => 'BEST';

  @override
  String lbGoBehind(String gap) {
    return '−$gap';
  }

  @override
  String get lbGoBehindLine => 'so close. (not really.)';

  @override
  String get lbGoNewBest => 'NEW BEST!';

  @override
  String get lbGoNewBestLine => 'Frame this one.';

  @override
  String lbGoRun(String run) {
    return 'RUN $run';
  }

  @override
  String get lbGoChartTitle => 'YOUR RUN, UNCOILED';

  @override
  String lbGoChartStats(String food, String combo) {
    return '$food FOOD · PEAK ×$combo';
  }

  @override
  String get lbGoChartCaption => '1 COLUMN = 1 FOOD · TALLER = TASTIER';

  @override
  String get lbGoNoBites =>
      'No food this run. The chart starts at the first bite.';

  @override
  String get lbAgain => 'AGAIN';

  @override
  String get lbGoContinue => 'CONTINUE';

  @override
  String lbGoContinueSub(String cost, String len) {
    return '$cost¢ or ad · keep len $len';
  }

  @override
  String lbGoContinueProSub(String len) {
    return 'free with Pro · keep len $len';
  }

  @override
  String lbGoEarned(String coins) {
    return '+$coins¢ EARNED';
  }

  @override
  String lbGoRewardsLine(String ready, String coins, String xp) {
    return '$ready daily ready · +$coins¢ · +$xp XP';
  }

  @override
  String get lbGoNothingToClaim => 'nothing to claim yet · keep playing';

  @override
  String get lbClaim => 'CLAIM';

  @override
  String get lbGoDoubleCoins => '2× COINS · AD';

  @override
  String get lbGoWatchReplay => 'WATCH REPLAY';

  @override
  String get lbHome => 'HOME';

  @override
  String get lbDailyTitle => 'DAILY';

  @override
  String get lbDailySubtitle => 'Three snacks a day. Doctor\'s orders.';

  @override
  String lbDailyProgress(String done, String total) {
    return '$done OF $total DONE';
  }

  @override
  String lbDailyStreak(int days, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'streak: $days days',
      one: 'streak: 1 day',
    );
    return '$_temp0 · resets in $time';
  }

  @override
  String lbResetsIn(String time) {
    return 'resets in $time';
  }

  @override
  String get lbClaimAll => 'CLAIM ALL';

  @override
  String get lbClaimAllDouble => 'CLAIM ALL ×2';

  @override
  String get lbClaimAllDoubleLine => 'one short ad, double the loot';

  @override
  String lbWeeklyTeaser(String done, String total) {
    return 'WEEKLY QUESTS · $done/$total';
  }

  @override
  String get lbWeeklyTeaserLine => 'the big loot drops Sunday';

  @override
  String get lbWeeklyTitle => 'WEEKLY';

  @override
  String get lbWeeklySubtitle => 'Bigger snacks. Seven days to finish them.';

  @override
  String lbRewardCoinsXp(String coins, String xp) {
    return '$coins¢ · $xp XP';
  }

  @override
  String lbPlayMode(String mode) {
    return 'PLAY $mode';
  }

  @override
  String get lbTrophiesTitle => 'TROPHIES';

  @override
  String lbTrophiesSubtitle(String unlocked, String total, String locked) {
    return '$unlocked of $total. The other $locked are judging you.';
  }

  @override
  String get lbFilterAll => 'ALL';

  @override
  String lbFilterUnlocked(String count) {
    return 'UNLOCKED $count';
  }

  @override
  String lbFilterLocked(String count) {
    return 'LOCKED $count';
  }

  @override
  String lbTrophiesSummary(String pct, String claimed, String waiting) {
    return '$pct% COMPLETE · $claimed CLAIMED · $waiting WAITING';
  }

  @override
  String get lbClaimed => 'CLAIMED';

  @override
  String lbCoinsReward(String coins) {
    return '+$coins¢';
  }

  @override
  String get lbSeasonTitle => 'SEASON';

  @override
  String lbSeasonSubtitle(String season, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$season · $_temp0. Make them count.';
  }

  @override
  String lbSeasonEnded(String season) {
    return '$season · season over. A new one is coming.';
  }

  @override
  String get lbTier => 'TIER';

  @override
  String lbTierOf(String max) {
    return '/ $max';
  }

  @override
  String get lbProTrack => 'PRO TRACK';

  @override
  String lbXpToTier(String xp, String need, String tier) {
    return '$xp / $need XP TO TIER $tier';
  }

  @override
  String lbNextUp(String tier, String track) {
    return 'NEXT UP · TIER $tier · $track';
  }

  @override
  String lbTiersAwayLine(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tiers away. Eat faster.',
      one: '1 tier away. Eat faster.',
    );
    return '$_temp0';
  }

  @override
  String lbTiersAway(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n TIERS',
      one: '1 TIER',
    );
    return '$_temp0';
  }

  @override
  String lbXpAd(String xp) {
    return '+$xp XP · WATCH AD';
  }

  @override
  String get lbYouAreHere => 'YOU ARE HERE';

  @override
  String get lbFree => 'FREE';

  @override
  String get lbPro => 'PRO';

  @override
  String get lbRanksTitle => 'RANKS';

  @override
  String get lbRanksSubtitle => 'Ranked by your best single run. No pressure.';

  @override
  String get lbTabGlobal => 'GLOBAL';

  @override
  String get lbTabWeekly => 'WEEKLY';

  @override
  String get lbTabFriends => 'FRIENDS';

  @override
  String lbRanksYouRow(String rank, String name) {
    return '#$rank · YOU · $name';
  }

  @override
  String lbRanksYouUnranked(String name) {
    return 'YOU · $name';
  }

  @override
  String lbRanksGap(String gap, String leader) {
    return '$gap behind $leader. Snack harder.';
  }

  @override
  String get lbRanksLeader => 'You\'re #1. Everyone\'s chasing you.';

  @override
  String get lbRanksEasyOnly => 'Easy runs don\'t rank. Normal is waiting.';

  @override
  String get lbRanksOffline => 'Ranks need the internet. Your snake doesn\'t.';

  @override
  String get lbRanksEmpty => 'Nobody here yet. Be the first.';

  @override
  String lbRunsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n runs',
      one: '1 run',
    );
    return '$_temp0';
  }

  @override
  String get lbProfileTitle => 'PROFILE';

  @override
  String get lbProfileSubtitle => 'Your snake, by the numbers.';

  @override
  String get lbFunFact => 'FUN FACT';

  @override
  String lbFunApples(String apples, int pies) {
    String _temp0 = intl.Intl.pluralLogic(
      pies,
      locale: localeName,
      other: '$pies pies',
      one: '1 pie',
    );
    return '$apples apples eaten. That\'s about $_temp0.';
  }

  @override
  String lbFunMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0 of slithering. Hydrate.';
  }

  @override
  String lbFunPowerups(int powerups) {
    String _temp0 = intl.Intl.pluralLogic(
      powerups,
      locale: localeName,
      other: '$powerups power-ups',
      one: '1 power-up',
    );
    return '$_temp0 grabbed. Greedy, love it.';
  }

  @override
  String get lbSynced => 'PROGRESS SYNCED';

  @override
  String get lbSyncedLine => 'Offline? Play anyway. We\'ll catch up later.';

  @override
  String get lbSyncPending => 'SYNC PENDING';

  @override
  String get lbGuest => 'PLAYING AS GUEST';

  @override
  String get lbGuestLine => 'Link an account to keep this snake forever.';

  @override
  String lbSignedInWith(String provider) {
    return 'SIGNED IN · $provider';
  }

  @override
  String get lbStatBest => 'BEST';

  @override
  String get lbStatGames => 'GAMES';

  @override
  String get lbStatPlayTime => 'PLAY TIME';

  @override
  String get lbStatAverage => 'AVERAGE';

  @override
  String get lbStatFood => 'FOOD EATEN';

  @override
  String get lbStatPowerups => 'POWER-UPS';

  @override
  String get lbStats => 'STATS';

  @override
  String get lbReplays => 'REPLAYS';

  @override
  String get lbFriends => 'FRIENDS';

  @override
  String get lbTrophies => 'TROPHIES';

  @override
  String lbFriendsOn(String count) {
    return '$count ON';
  }

  @override
  String get lbStoreTitle => 'STORE';

  @override
  String get lbStoreSubPro => 'No ads. All the drip. Your call.';

  @override
  String get lbStoreSubCoins => 'Coins for the impatient.';

  @override
  String get lbStoreSubThemes => 'New board, same bad habits.';

  @override
  String get lbStoreSubSkins => 'Same snake. Way more drip.';

  @override
  String get lbStoreSubTrails => 'Leave a mark.';

  @override
  String get lbStoreSubPowerups => 'Tiny cheats. Fully legal.';

  @override
  String get lbSnakeCoins => 'SNAKE COINS';

  @override
  String lbFreeCoins(String coins) {
    return '+$coins¢ FREE';
  }

  @override
  String get lbFreeCoinsLine => 'watch a short ad';

  @override
  String get lbProName => 'SNAKE CLASSIC PRO';

  @override
  String get lbProPerkNoAds => 'No ads. Not one. Ever.';

  @override
  String get lbProPerkRevive => 'A free revive, every single run';

  @override
  String lbProPerkThemes(String count) {
    return 'All $count premium themes';
  }

  @override
  String lbProPerkCosmetics(String skins, String trails) {
    return 'All $skins skins + all $trails trails';
  }

  @override
  String get lbProPerkCoins => '2× coins from every run';

  @override
  String get lbMonthly => 'MONTHLY';

  @override
  String get lbYearly => 'YEARLY';

  @override
  String get lbPerMonth => 'per month';

  @override
  String get lbGoPro => 'GO PRO';

  @override
  String get lbProActive => 'PRO IS ON';

  @override
  String get lbProActiveLine => 'Thanks for backing the snake.';

  @override
  String get lbStoreFooter =>
      'Prices come from your app store. Cancel anytime.';

  @override
  String get lbRestorePurchases => 'RESTORE PURCHASES';

  @override
  String lbBuyPrice(String price) {
    return 'BUY · $price';
  }

  @override
  String lbBuyCoins(String coins) {
    return 'BUY · $coins¢';
  }

  @override
  String get lbOrFreeWithPro => 'or free with Pro';

  @override
  String get lbEquipped => 'EQUIPPED';

  @override
  String get lbEquip => 'EQUIP';

  @override
  String get lbSkinTagGolden => 'Rich. Famous. A little smug.';

  @override
  String get lbSkinTagFire => 'Hot to the touch.';

  @override
  String get lbSkinTagIce => 'Cool under pressure.';

  @override
  String get lbSkinTagElectric => 'Shockingly fast.';

  @override
  String get lbSkinTagRainbow => 'All of them. At once.';

  @override
  String get lbSkinTagNeon => 'Visible from space.';

  @override
  String get lbSkinTagShadow => 'Now you see it.';

  @override
  String get lbSkinTagGalaxy => 'Contains multitudes.';

  @override
  String get lbSkinTagCrystal => 'Handle with care.';

  @override
  String get lbSkinTagCosmic => 'Big universe energy.';

  @override
  String get lbSkinTagDragon => 'Legally not a dragon.';

  @override
  String get lbSettingsTitle => 'SETTINGS';

  @override
  String get lbSettingsSubtitle => 'Tweak it till it feels right.';

  @override
  String get lbControls => 'CONTROLS';

  @override
  String get lbCtrlSwipe => 'SWIPE';

  @override
  String get lbCtrlSwipeSub => 'anywhere';

  @override
  String get lbCtrlDpad => 'D-PAD';

  @override
  String get lbCtrlDpadSub => '4 arrows';

  @override
  String get lbCtrlTurn => 'TURN';

  @override
  String get lbCtrlTurnSub => 'left · right';

  @override
  String get lbCtrlStick => 'STICK';

  @override
  String get lbCtrlStickSub => 'floating';

  @override
  String get lbGameplay => 'GAMEPLAY';

  @override
  String get lbMode => 'MODE';

  @override
  String get lbBoard => 'BOARD';

  @override
  String get lbDifficulty => 'DIFFICULTY';

  @override
  String get lbCrashReplay => 'CRASH REPLAY';

  @override
  String get lbCrashReplaySub => 'how long we rub it in';

  @override
  String get lbTheme => 'THEME';

  @override
  String lbThemeAside(String theme, String free, String premium) {
    return '$theme · $free FREE · $premium PREMIUM';
  }

  @override
  String get lbSoundFeel => 'SOUND & FEEL';

  @override
  String get lbSoundFx => 'SOUND FX';

  @override
  String get lbSoundFxSub => 'crunchy, as intended';

  @override
  String get lbMusic => 'MUSIC';

  @override
  String get lbHaptics => 'HAPTICS';

  @override
  String get lbHapticsSub => 'tiny buzz on every bite';

  @override
  String get lb120Hz => '120 HZ';

  @override
  String get lb120HzSub => 'smooth like butter (if your phone is)';

  @override
  String get lbReplayTutorial => 'REPLAY TUTORIAL';

  @override
  String get lbPrivacy => 'PRIVACY';

  @override
  String get lbVersusTitle => 'VERSUS';

  @override
  String get lbVersusSubtitle => 'Real people. Real snakes. Real beef.';

  @override
  String get lbWins => 'WINS';

  @override
  String get lbLosses => 'LOSSES';

  @override
  String get lbDraws => 'DRAWS';

  @override
  String get lbRating => 'RATING';

  @override
  String get lbQuickMatch => 'QUICK MATCH';

  @override
  String get lbQuickMatchLine => '1v1 Classic. We find you a rival in seconds.';

  @override
  String get lbFindMatch => 'FIND MATCH';

  @override
  String lbSearching(String secs) {
    return 'SNIFFING OUT A RIVAL… ${secs}s';
  }

  @override
  String get lbCancel => 'CANCEL';

  @override
  String get lbGotCode => 'GOT A CODE?';

  @override
  String get lbGotCodeLine =>
      'Six letters. Case doesn\'t matter. Friendship might.';

  @override
  String get lbCreateRoom => 'CREATE ROOM';

  @override
  String get lbCreateRoomLine => 'Invite a friend. Or a frenemy.';

  @override
  String get lbHouseSnake =>
      'Nobody brave online? The house snake joins after 30s. It doesn\'t trash talk.';

  @override
  String get lbTournamentsLive => 'TOURNAMENTS · LIVE';

  @override
  String get lbTournamentsLine => 'Bronze free · Silver & Gold entries';

  @override
  String get lbRoomTitle => 'ROOM';

  @override
  String get lbRoomSubtitle => 'Share the code. Wait nervously.';

  @override
  String lbPlayersCount(String count, String max) {
    return 'PLAYERS $count/$max';
  }

  @override
  String get lbYou => 'YOU';

  @override
  String get lbRival => 'RIVAL';

  @override
  String get lbWaitingYou => 'WAITING · tap ready, hero';

  @override
  String get lbWaiting => 'WAITING';

  @override
  String get lbReadyThem => 'READY · stretching menacingly';

  @override
  String get lbReadyYou => 'READY · nerves of steel';

  @override
  String get lbReadyCheck => 'READY CHECK';

  @override
  String get lbReady => 'READY';

  @override
  String get lbLeaveRoom => 'LEAVE ROOM';

  @override
  String get lbVs => 'VS';

  @override
  String get lbLive => 'LIVE';

  @override
  String lbMatchBehind(String rival, String gap) {
    return '$rival is $gap points ahead. Rude.';
  }

  @override
  String lbMatchAhead(String gap) {
    return 'You\'re $gap ahead. Don\'t get cocky.';
  }

  @override
  String get lbMatchTied => 'Dead even. Eat something.';

  @override
  String get lbVictory => 'VICTORY';

  @override
  String lbVictoryLine(String rival) {
    return 'You out-snaked $rival.';
  }

  @override
  String get lbDefeat => 'DEFEAT';

  @override
  String lbDefeatLine(String rival) {
    return '$rival took this one.';
  }

  @override
  String get lbDefeatBothCrashed =>
      'Both snakes crashed. Their score decided it.';

  @override
  String lbDefeatLine2(String rival) {
    return '$rival will be insufferable now.';
  }

  @override
  String get lbDraw => 'DRAW';

  @override
  String get lbDrawLine => 'Perfectly balanced. Rematch?';

  @override
  String get lbVersusFooter =>
      'Every loss is just a rematch waiting to happen.';

  @override
  String get lbLength => 'LENGTH';

  @override
  String get lbSurvived => 'SURVIVED';

  @override
  String get lbRematch => 'REMATCH';

  @override
  String get lbBackToLobby => 'BACK TO LOBBY';

  @override
  String get lbAdBreak => 'AD BREAK';

  @override
  String lbAdBreakLine(String coins) {
    return 'A short ad. $coins coins for you.';
  }

  @override
  String get lbAdBreakLine2 => 'Fair trade? Your call either way.';

  @override
  String lbAdStartsIn(String secs) {
    return 'STARTS IN $secs · OR SKIP, NO HARD FEELINGS';
  }

  @override
  String lbAdRewardWhenEnds(String coins) {
    return '+$coins¢ WHEN IT ENDS';
  }

  @override
  String get lbWatchNow => 'WATCH NOW';

  @override
  String get lbNoThanks => 'NO THANKS';

  @override
  String get lbAdBackHint => 'The back gesture counts as no thanks, too.';

  @override
  String get lbAdStarting => 'AD STARTING…';

  @override
  String get lbNoAdNow => 'No ad right now. Try again in a sec.';

  @override
  String get lbServerDown =>
      'Our servers bonked. Your progress is safe on this phone.';

  @override
  String get lbHomeVersusSubOffline => '1v1 · real rivals';

  @override
  String get lbHomeSeasonSubNone => 'Earn XP every run';

  @override
  String get lbMenuHowToPlay => 'HOW TO PLAY';

  @override
  String get lbMenuTournaments => 'TOURNAMENTS';

  @override
  String get lbMenuAbout => 'ABOUT';

  @override
  String get lbMenuHowToPlaySub => 'swipes, modes, power-ups';

  @override
  String get lbMenuAboutSub => 'version, credits, legal';

  @override
  String get lbSetupLoadoutNone => 'TAP ONE TO ARM';

  @override
  String lbSetupLoadoutArmedOne(String name) {
    return '$name ARMED';
  }

  @override
  String lbOwnedCount(String count) {
    return '×$count';
  }

  @override
  String lbArmedChip(String name) {
    return 'ARMED · $name';
  }

  @override
  String get lbGuestNoteApple =>
      'Guests can play and save progress locally, but cannot make purchases. Sign in with Apple, Google or Email when you are ready to subscribe or buy.';

  @override
  String get lbGuestNoteNoApple =>
      'Guests can play and save progress locally, but cannot make purchases. Sign in with Google or Email when you are ready to subscribe or buy.';

  @override
  String get lbAuthLegalTitle => 'PRIVACY + TERMS';

  @override
  String get lbConsentTitle => 'TERMS UPDATED';

  @override
  String get lbEmailTitle => 'EMAIL';

  @override
  String get lbEmailLinkTitle => 'SAVE PROGRESS';

  @override
  String get lbUsernameTitle => 'USERNAME';

  @override
  String get lbShowPassword => 'Show password';

  @override
  String get lbHidePassword => 'Hide password';

  @override
  String get lbSignedIn => 'SIGNED IN';

  @override
  String get lbProviderGoogle => 'GOOGLE';

  @override
  String get lbProviderApple => 'APPLE';

  @override
  String get lbProviderEmail => 'EMAIL';

  @override
  String get lbStatsSubtitle => 'Every run, counted. Even the bad ones.';

  @override
  String get lbTrendUp => 'CLIMBING';

  @override
  String get lbTrendDown => 'SLIPPING';

  @override
  String get lbTrendFlat => 'STEADY';

  @override
  String get lbReplaysSubtitle => 'Kept on this phone. Never uploaded.';

  @override
  String get lbReplayTitle => 'REPLAY';

  @override
  String get lbReplayEnded => 'ENDED';

  @override
  String lbSpeedX(String speed) {
    return '$speed×';
  }

  @override
  String get lbPause => 'PAUSE';

  @override
  String get lbReplayPrevFrame => 'PREVIOUS FRAME';

  @override
  String get lbReplayNextFrame => 'NEXT FRAME';

  @override
  String get lbFriendsSubtitle => 'Snakes you know. Rivals you\'ll beat.';

  @override
  String lbDurDayHour(String d, String h) {
    return '${d}d ${h}h';
  }

  @override
  String lbBonusStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days DAY STREAK',
      one: '1 DAY STREAK',
    );
    return '$_temp0';
  }

  @override
  String lbPoints(String points) {
    return '$points PTS';
  }

  @override
  String get lbRefresh => 'REFRESH';

  @override
  String get lbRouteErrorTitle => 'LOST THE TRAIL';

  @override
  String get lbRouteErrorBody =>
      'That screen does not exist in this version of the game.';

  @override
  String get lbRouteErrorHome => 'BACK TO HOME';

  @override
  String lbVersionShort(String version) {
    return 'v$version';
  }

  @override
  String get lbCtrlReference => 'GESTURES & KEYS';

  @override
  String get lbCtrlReferenceSub => 'what every swipe and key does';

  @override
  String lbThemeSwatchLocked(String theme) {
    return '$theme, locked';
  }

  @override
  String get lbLanguageRow => 'APP LANGUAGE';

  @override
  String get lbPerYearBestValue => 'per year · best value';

  @override
  String get lbProAlsoIncluded => 'ALSO INCLUDED';

  @override
  String get lbFreeTrack => 'FREE TRACK';

  @override
  String lbSeasonSubtitleSoon(String season, String left) {
    return '$season · $left. Make them count.';
  }

  @override
  String get lbEndsIn => 'ENDS IN';

  @override
  String get lbStartsIn => 'STARTS IN';

  @override
  String get dfTitle => 'How\'s the game feeling?';

  @override
  String get dfBody => 'Rate it from 1 to 5. A comment is optional.';

  @override
  String get dfLow => 'Not great';

  @override
  String get dfHigh => 'Love it';

  @override
  String dfRatingOption(int rating) {
    return '$rating out of 5';
  }

  @override
  String get dfCommentLabel => 'Comment (optional)';

  @override
  String get dfSend => 'Send';

  @override
  String get dfNotNow => 'Not now';

  @override
  String get dfThanks => 'Thanks — that really helps.';
}
