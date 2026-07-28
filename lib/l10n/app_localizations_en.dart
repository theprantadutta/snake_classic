// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'LANGUAGE';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageSystemDefaultSubtitle => 'Follow your device language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get mpVictory => 'VICTORY!';

  @override
  String get mpDraw => 'DRAW';

  @override
  String get mpDefeat => 'DEFEAT';

  @override
  String get mpYou => 'You';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Opponent';

  @override
  String get mpBackToLobby => 'Back to Lobby';

  @override
  String get mpPlayAgain => 'Play Again';

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
  String get mpSwipe => 'Swipe';

  @override
  String get mpReconnectingInline => 'reconnecting…';

  @override
  String get homePlay => 'PLAY';

  @override
  String get homeHighScore => 'HIGH SCORE';

  @override
  String homeArmedPowerUp(String name) {
    return 'Armed: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Loadout ($count)';
  }

  @override
  String get puSpeedBoost => 'Speed Boost';

  @override
  String get puInvincibility => 'Invincibility';

  @override
  String get puScoreMultiplier => 'Score Multiplier';

  @override
  String get puSlowMotion => 'Slow Motion';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'STORE';

  @override
  String get homeTileFree => 'FREE';

  @override
  String get homeTileDaily => 'DAILY';

  @override
  String get homeTileBattle => 'BATTLE';

  @override
  String get homeTileEvents => 'EVENTS';

  @override
  String get homeTileBoard => 'BOARD';

  @override
  String get homeTileFriends => 'FRIENDS';

  @override
  String get homeTileCosmetics => 'COSMETICS';

  @override
  String get homeTileAwards => 'AWARDS';

  @override
  String get homeTileVersus => 'VERSUS';

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
  String get homePickGameMode => 'Pick a Game Mode';

  @override
  String get homePickGameModeSubtitle =>
      'You can change this anytime in Settings';

  @override
  String get homeStartPlaying => 'START PLAYING';

  @override
  String get homeLoadoutTitle => 'Power-Up Loadout';

  @override
  String get homeLoadoutSubtitle =>
      'Pre-load one power-up — it activates 5 seconds into your next game.';

  @override
  String get homeWatchAdFreeSpeedBoost => 'Watch ad — free Speed Boost';

  @override
  String get homeNoPowerUps =>
      'You have no power-ups.\nVisit the store to buy some!';

  @override
  String homeOwnedCount(int count) {
    return 'Owned: $count';
  }

  @override
  String get homeArmed => 'ARMED';

  @override
  String get homeDone => 'DONE';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsBackToGame => 'BACK TO GAME';

  @override
  String get settingsSectionControls => 'CONTROLS';

  @override
  String get settingsSectionGameplay => 'GAMEPLAY';

  @override
  String get settingsSectionAudio => 'AUDIO';

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
  String get settingsDPadControls => 'D-Pad Controls';

  @override
  String get settingsDPadSubtitle =>
      'Show on-screen directional buttons during gameplay';

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
  String get settingsGameMode => 'Game Mode';

  @override
  String get settingsGameModeLocked =>
      'Complete current game to change game mode';

  @override
  String get settingsDifficulty => 'Difficulty';

  @override
  String get settingsDifficultySubtitle =>
      'Sets how fast the snake starts. Each mode still speeds up as you level.';

  @override
  String get settingsEasyNote =>
      'Coins, XP and achievements still count on Easy — only high scores and leaderboards are paused.';

  @override
  String get settingsDifficultyLocked =>
      'Finish your current game to change difficulty.';

  @override
  String get settingsCurrentSize => 'Current Size';

  @override
  String get settingsBoardSizeLocked =>
      'Complete current game to change board size';

  @override
  String get settingsCurrentDuration => 'Current Duration';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'How long to show crash explanation';

  @override
  String get settingsScreenShake => 'Screen Shake';

  @override
  String get settingsScreenShakeSubtitle =>
      'Shake the screen on collisions and game events';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationSubtitle =>
      'Vibrate on game events and button presses';

  @override
  String get settingsSoundEffects => 'Sound Effects';

  @override
  String get settingsBackgroundMusic => 'Background Music';

  @override
  String get settingsCurrentTheme => 'Current Theme';

  @override
  String get settingsBrowseThemes => 'BROWSE THEMES';

  @override
  String get settingsSnakeTrail => 'Snake Trail Effects';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Enable particle trails behind the snake';

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
  String get settingsAuthenticatedAccount => 'Authenticated Account';

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
}
