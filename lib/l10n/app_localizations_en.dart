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
  String get mpLobbyDismiss => 'DISMISS';

  @override
  String get mpLobbyGo => 'GO!';

  @override
  String get mpLobbyGetReady => 'Get Ready!';

  @override
  String get mpLobbyTitle => 'MULTIPLAYER';

  @override
  String get mpLobbySubtitle => 'Play with friends online';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Room: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'Room code copied!';

  @override
  String get mpLobbyQuickMatch => 'QUICK MATCH';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      '1v1 Classic — find an opponent automatically';

  @override
  String get mpLobbyFinding => 'FINDING...';

  @override
  String get mpLobbyFindMatch => 'FIND MATCH';

  @override
  String get mpLobbySeconds => 'sec';

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
  String get mpLobbyCancelUpper => 'CANCEL';

  @override
  String get mpLobbyNoPlayersFound => 'NO PLAYERS FOUND';

  @override
  String get mpLobbyNoPlayersBody =>
      'Sorry, we couldn\'t find any opponents.\nTry again or create your own room!';

  @override
  String get mpLobbyGoBack => 'GO BACK';

  @override
  String get mpLobbyTryAgain => 'TRY AGAIN';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count W';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count L';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count D';
  }

  @override
  String get mpLobbyWinsLabel => 'Wins';

  @override
  String get mpLobbyLossesLabel => 'Losses';

  @override
  String get mpLobbyDrawsLabel => 'Draws';

  @override
  String get mpLobbyRatingLabel => 'Rating';

  @override
  String get mpLobbyJoinRoom => 'JOIN ROOM';

  @override
  String get mpLobbyJoinSubtitle => 'Enter room code to join';

  @override
  String get mpLobbyEnterRoomCode => 'Enter room code';

  @override
  String get mpLobbyCreateRoom => 'CREATE ROOM';

  @override
  String get mpLobbyCreateSubtitle => 'Start a 1v1 room and invite a friend';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'PLAYERS ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'YOU';

  @override
  String get mpLobbyWaitingForPlayer => 'Waiting for player...';

  @override
  String get mpLobbyStartGame => 'START GAME';

  @override
  String get mpLobbyWaitingForHost => 'Waiting for host to start...';

  @override
  String get mpLobbyLeave => 'LEAVE';

  @override
  String get mpLobbyReadyDone => 'READY!';

  @override
  String get mpLobbyReady => 'READY';

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
  String goWatchToDouble(Object count) {
    return 'Watch to double your $count coins';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins coins  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'Claimed $count coins from daily challenges!';
  }

  @override
  String get goRibbonNewHighScore => 'NEW HIGH SCORE!';

  @override
  String get goRibbonTournamentSubmitted => 'TOURNAMENT SCORE SUBMITTED!';

  @override
  String get goRibbonTournamentFailed =>
      'SCORE NOT SUBMITTED — CHECK CONNECTION';

  @override
  String get goRibbonTournamentSubmitting => 'SUBMITTING TOURNAMENT SCORE…';

  @override
  String get goVictory => 'VICTORY!';

  @override
  String get goGameOver => 'GAME OVER';

  @override
  String get goFinalScore => 'FINAL SCORE';

  @override
  String get goLevel => 'LEVEL';

  @override
  String get goBest => 'BEST';

  @override
  String get goCoinsEarned => 'Coins Earned';

  @override
  String get goDailyRewardsReady => 'DAILY REWARDS READY';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rewards',
      one: '$count reward',
    );
    return '$_temp0  •  +$coins coins  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'CLAIM ALL';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'Claim';

  @override
  String get goAchievements => 'ACHIEVEMENTS';

  @override
  String get goRecentlyUnlocked => 'Recently Unlocked';

  @override
  String get goInProgress => 'In Progress';

  @override
  String get goPlayAgain => 'PLAY AGAIN';

  @override
  String get goMenu => 'MENU';

  @override
  String get storeTitle => 'Snake Store';

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
  String get storeYourCoins => 'Your Snake Coins';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return '${multiplier}x BONUS';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Subscribe before your free Pro ends';

  @override
  String get storeChooseYourPlan => 'Choose your plan';

  @override
  String get storeWhatYouGet => 'What you get';

  @override
  String get storeProHeroSubtitle =>
      'All premium themes, skins & trails · big boards · 2× coins · premium power-ups · tournament entries · Battle Pass Premium';

  @override
  String get storeMonthly => 'Monthly';

  @override
  String get storeYearly => 'Yearly';

  @override
  String get storePerMonth => '/month';

  @override
  String get storePerYear => '/year';

  @override
  String get storeSave17 => 'Save 17%';

  @override
  String storePlanDisplayName(Object title) {
    return '$title plan';
  }

  @override
  String get storeVerifyingEllipsis => 'Verifying…';

  @override
  String get storeSubscribe => 'Subscribe';

  @override
  String get storeYoureOnFreePro => 'You\'re on free Pro!';

  @override
  String get storeYourePro => 'You\'re Pro!';

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
  String get storeFeatureExtraLife =>
      'Always-free extra life — revive every game, no ad, no coins';

  @override
  String get storeFeatureNoAds => 'No ads — play completely ad-free';

  @override
  String get storeFeatureThemes => 'All 6 premium themes';

  @override
  String get storeFeatureSkins => 'All 11 premium snake skins';

  @override
  String get storeFeatureTrails => 'All 11 premium trail effects';

  @override
  String get storeFeatureBoards => 'Premium board sizes (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => '2× coin earnings';

  @override
  String get storeFeaturePowerUps => '5× premium power-ups every cycle';

  @override
  String get storeFeatureTournaments =>
      'Bronze + Silver + Gold tournament entries each cycle';

  @override
  String get storeFeatureBattlePass => 'Battle Pass Premium track every season';

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
  String get storePillEquipped => 'EQUIPPED';

  @override
  String get storePillEquip => 'EQUIP';

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
  String get commonViewAll => 'View All';

  @override
  String get commonRetry => 'Retry';

  @override
  String get pfTitle => 'Profile';

  @override
  String get pfSigningOut => 'Signing out...';

  @override
  String get pfGuestPlayer => 'Guest Player';

  @override
  String get pfVerifiedAccount => 'Verified Account';

  @override
  String get pfStatistics => 'Statistics';

  @override
  String get pfReplays => 'Replays';

  @override
  String get pfAchievements => 'Achievements';

  @override
  String get pfLoadingStats => 'Loading stats...';

  @override
  String get pfHighScore => 'High Score';

  @override
  String get pfGamesPlayed => 'Games Played';

  @override
  String get pfPlayTime => 'Play Time';

  @override
  String get pfAverageScore => 'Average Score';

  @override
  String get pfFoodConsumed => 'Food Consumed';

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
  String get pfNoReplays => 'No replays yet. Play some games!';

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
  String get stScores => 'Scores';

  @override
  String get stTrendLine => 'Trend Line';

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
  String get stViewAllAchievements => 'View All Achievements →';

  @override
  String get stViewAchievements => 'VIEW ACHIEVEMENTS';

  @override
  String get stReplaysUpper => 'REPLAYS';

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
  String get stNoData => 'No data';

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
  String get frLeaderboardTitle => 'Friends Leaderboard';

  @override
  String get frLeaderboardSubtitle => 'Compete with your friends';

  @override
  String get frLoadingLeaderboard => 'Loading leaderboard...';

  @override
  String frRankBadge(Object rank) {
    return '#$rank';
  }

  @override
  String get frYou => 'YOU';

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
  String get acAll => 'All';

  @override
  String get acUnlocked => 'Unlocked';

  @override
  String get acLocked => 'Locked';

  @override
  String get acTotalUpper => 'TOTAL';

  @override
  String get acUnlockedUpper => 'UNLOCKED';

  @override
  String get acClaimedUpper => 'CLAIMED';

  @override
  String get acPendingUpper => 'PENDING';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% complete';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% of unlocked';
  }

  @override
  String get acEmpty => 'No achievements here';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Unlocked $date';
  }

  @override
  String get rpTitle => 'Game Replays';

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
  String get lbTitle => 'Leaderboards';

  @override
  String get lbGlobal => 'Global';

  @override
  String get lbWeekly => 'Weekly';

  @override
  String get lbWeeklySub =>
      'Ranked by your best single-game score this week (resets Sunday)';

  @override
  String get lbGlobalSub => 'Ranked by your highest single-game score ever';

  @override
  String lbScoreLine(Object score) {
    return 'Score: $score';
  }

  @override
  String get lbLoadingGlobal => 'Loading global leaderboard...';

  @override
  String get lbLoadingWeekly => 'Loading weekly leaderboard...';

  @override
  String get lbNoScores => 'No scores yet';

  @override
  String get lbBeFirst => 'Be the first to set a high score!';

  @override
  String get lbNoWeekly => 'No weekly scores yet';

  @override
  String get lbPlayThisWeek => 'Play this week to appear here!';

  @override
  String get lbAnonymous => 'Anonymous';

  @override
  String get lbGuestBadge => 'GUEST';

  @override
  String get lbPts => 'pts';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games played',
      one: '$count game played',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '$name claimed!';
  }

  @override
  String get bpTitle => 'Battle Pass';

  @override
  String get bpTitleUpper => 'BATTLE PASS';

  @override
  String get bpLoading => 'Loading battle pass...';

  @override
  String get bpWatchAdXp => 'Watch ad — +50 Battle Pass XP';

  @override
  String get bpXpEarned => '+50 Battle Pass XP earned!';

  @override
  String get bpSeasonEnded => 'Season ended';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h left';
  }

  @override
  String bpDaysLeft(Object days) {
    return '${days}d left';
  }

  @override
  String get bpTierUpper => 'TIER';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'Season complete';

  @override
  String get bpSeasonCompleteUpper => 'SEASON COMPLETE';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next XP to Tier $tier';
  }

  @override
  String get bpPremiumBadge => 'PREMIUM';

  @override
  String get bpSeasonCosmicSerpent => 'Cosmic Serpent Season';

  @override
  String get bpUnlockedEverything =>
      'You\'ve unlocked every tier in this season.';

  @override
  String get bpComingNext => 'COMING NEXT';

  @override
  String bpTierN(Object tier) {
    return 'Tier $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tiers away',
      one: '$count tier away',
    );
    return '$_temp0';
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
  String get bpCollapse => 'COLLAPSE';

  @override
  String get bpExpand => 'EXPAND';

  @override
  String get bpNow => 'NOW';

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
  String get pbActive => 'Premium Active!';

  @override
  String get pbActiveSub => 'You have access to all premium features';

  @override
  String get pbHeaderSub => 'Unlock everything the game has to offer';

  @override
  String get pbMonthlyPlan => 'Monthly Plan';

  @override
  String get pbYearlyPlan => 'Yearly Plan';

  @override
  String get pbSave33 => 'Save 33%';

  @override
  String get pbMostPopular => 'MOST POPULAR';

  @override
  String get pbFeatExtraLife => 'Always-Free Extra Life';

  @override
  String get pbFeatExtraLifeDesc =>
      'Crash and keep going — Pro members revive instantly for free, no ad and no coins, once every game';

  @override
  String get pbFeatNoAds => 'Remove All Ads';

  @override
  String get pbFeatNoAdsDesc =>
      'No banners, no interstitials — play completely ad-free, forever';

  @override
  String get pbFeatThemes => 'All Premium Themes';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'All Premium Snake Skins';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice & 5 more';

  @override
  String get pbFeatTrails => 'All Premium Trail Effects';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal & 5 more';

  @override
  String get pbFeatBoards => 'Large Game Boards';

  @override
  String get pbFeatBoardsDesc => 'Play on 35x35, 40x40 & 50x50 boards';

  @override
  String get pbFeatCoins => '2x Coin Rewards';

  @override
  String get pbFeatCoinsDesc => 'Double Snake Coins from every game';

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
  String get pbFeatBundle => 'Premium Power-up Bundle';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield & Mega Invincibility every billing cycle';

  @override
  String get pbFeatTournament => 'Tournament Entries';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronze + 1× Silver + 1× Gold tournament entry every billing cycle';

  @override
  String get pbIncludes => 'Premium Includes:';

  @override
  String get pbProPerk => 'PRO PERK';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'Subscribe — $price$period';
  }

  @override
  String get pbReassurance => 'No commitment • Cancel anytime • Secure payment';

  @override
  String get pbNotAvailable => 'Premium subscription not available';

  @override
  String get eaTitleLink => 'Save Your Progress';

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
  String get faWelcome => 'Welcome to\nSnake Classic!';

  @override
  String get faChooseHow => 'Choose how you\'d like to play:';

  @override
  String get faSigningIn => 'Signing you in...';

  @override
  String get faSignInEmail => 'Sign in with Email';

  @override
  String get faContinueGuest => 'Continue as Guest';

  @override
  String get faGuestNote =>
      'Guests can play and save progress locally, but cannot make purchases. Sign in with Apple, Google or Email when you are ready to subscribe or buy.';

  @override
  String get faPrivacyTerms => 'Privacy & Terms';

  @override
  String get faReviewNote =>
      'Please review our Privacy Policy and Terms of Use before continuing';

  @override
  String get faAgreeCheckbox =>
      'I have read and agree to the Privacy Policy and Terms of Use';

  @override
  String get faContinueToSignIn => 'Continue to Sign In';

  @override
  String get faHeadsUp => 'Heads up';

  @override
  String get faGuestBullet1 =>
      'Guest data is automatically deleted from our servers after 90 days of inactivity.';

  @override
  String get faGuestBullet2 =>
      'To save your progress permanently and play across devices, sign in with Apple, Google or Email instead.';

  @override
  String get faGuestBullet3 =>
      'Guest accounts cannot purchase products or subscriptions. Sign in if you want to upgrade to Pro or buy cosmetics.';

  @override
  String get faChangedMind => 'I changed my mind';

  @override
  String get faProceedAnyway => 'Proceed anyway';

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
  String get ldTip1 =>
      'Plan two moves ahead — your tail follows wherever the head just went.';

  @override
  String get ldTip2 =>
      'Bonus food is worth more points, but it disappears fast. Grab it quick!';

  @override
  String get ldTip3 =>
      'Crashed? Watch a quick ad or spend coins to revive and keep your score.';

  @override
  String get ldTip4 =>
      'Chain food without pausing to build a combo multiplier.';

  @override
  String get ldTip5 =>
      'Stuck in a tight spot? Hug the walls to buy yourself a moment.';

  @override
  String get ldTip6 =>
      'Daily challenges and weekly quests stack up coins fast.';

  @override
  String get ldTip7 =>
      'Snake Classic Pro unlocks bigger boards and removes all ads.';

  @override
  String get ldTip8 =>
      'Time Attack rewards speed — and you can watch an ad for +30 seconds.';

  @override
  String get ldTip9 =>
      'Power-ups stack: arm a shield before squeezing through a gap.';

  @override
  String get ldTip10 =>
      'Switch themes, skins, and trails anytime in the store for a fresh look.';

  @override
  String get ldStepCore => 'Initializing core systems...';

  @override
  String get ldStepCoreSub => 'Setting up Server connection';

  @override
  String get ldStepProfile => 'Creating your player profile...';

  @override
  String get ldStepProfileSub => 'Generating unique username';

  @override
  String get ldStepPrefs => 'Loading your preferences...';

  @override
  String get ldStepPrefsSub => 'Syncing themes and settings';

  @override
  String get ldStepCloud => 'Syncing with cloud...';

  @override
  String get ldStepCloudSub => 'Ensuring data is up to date';

  @override
  String get ldStepGameData => 'Loading game data...';

  @override
  String get ldStepGameDataSub => 'Fetching Game Data';

  @override
  String get ldStepAudio => 'Configuring audio system...';

  @override
  String get ldStepAudioSub => 'Loading sound effects';

  @override
  String get ldStepSetup => 'Checking setup status...';

  @override
  String get ldStepSetupSub => 'Almost ready!';

  @override
  String get ldWelcome => 'Welcome!';

  @override
  String get ldWelcomeSub => 'Choose how to continue';

  @override
  String get ldReady => 'Ready to play!';

  @override
  String get ldReadySub => 'Welcome back to Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Initialization failed: $error';
  }

  @override
  String get ldRetrying => 'Retrying initialization...';

  @override
  String get ldTagline => 'PREMIUM SNAKE EXPERIENCE';

  @override
  String get ldLoadingUpper => 'LOADING';

  @override
  String get ldDidYouKnow => 'DID YOU KNOW?';

  @override
  String get ldGameFeatures => 'GAME FEATURES';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Smooth Gameplay';

  @override
  String get ldFeatEffects => 'EFFECTS';

  @override
  String get ldFeatEffectsSub => 'Visual Particles';

  @override
  String get ldFeatLevels => 'LEVELS';

  @override
  String get ldFeatLevelsSub => 'Progressive Fun';

  @override
  String get ldFeatAudio => 'AUDIO';

  @override
  String get ldFeatAudioSub => 'Immersive Sound';

  @override
  String get ldFeatScores => 'SCORES';

  @override
  String get ldFeatScoresSub => 'Global Rankings';

  @override
  String get ldFeatThemes => 'THEMES';

  @override
  String get ldFeatThemesSub => 'Multiple Styles';

  @override
  String get ldDevelopedBy => 'DEVELOPED & MAINTAINED BY';

  @override
  String get ldDevTagline => 'Crafting premium mobile experiences';

  @override
  String get ldInitFailedUpper => 'INITIALIZATION FAILED';

  @override
  String get ldRetryUpper => 'RETRY';

  @override
  String get pgArena => 'Initializing arena...';

  @override
  String get pgControls => 'Calibrating controls...';

  @override
  String get pgSnake => 'Spawning the snake...';

  @override
  String get pgFood => 'Placing the food...';

  @override
  String get pgPowerUps => 'Charging power-ups...';

  @override
  String get pgAlmost => 'Almost there...';

  @override
  String get pgGo => 'Go!';

  @override
  String get pgTip1 => 'Hold a direction longer to build combo multipliers.';

  @override
  String get pgTip2 => 'Bonus food yields more points but vanishes quickly.';

  @override
  String get pgTip3 => 'Power-ups spawn at random — grab them while you can.';

  @override
  String get pgTip4 => 'Plan two moves ahead, not just one.';

  @override
  String get pgTip5 =>
      'Long snakes turn slower. Save tight curves for the start.';

  @override
  String get pgTip6 =>
      'Score Multiplier stacks with combos for monster scores.';

  @override
  String get pgTip7 => 'Special food is rare — when it appears, prioritize it.';

  @override
  String get pgTip8 => 'Time Attack speeds up fast. Pace your turns.';

  @override
  String get pgTip9 =>
      'In Zen Mode, the walls wrap. Use it to escape tight spots.';

  @override
  String get pgTip10 =>
      'Perfect Game: never re-enter a cell your body has touched.';

  @override
  String get pgTip11 => 'The D-Pad gives precise turns; swipe is faster.';

  @override
  String get pgTip12 =>
      'Pause anytime from the HUD — your timer holds with you.';

  @override
  String get pgPreparing => 'PREPARING ARENA';

  @override
  String get pgTournamentMode => 'TOURNAMENT MODE';

  @override
  String get pgGameMode => 'GAME MODE';

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
  String get pgProTip => 'PRO TIP';

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
  String get wtControlsTitle => 'Swipe to Move';

  @override
  String get wtControlsMsg =>
      'Swipe in any direction to change where your snake is heading. The snake will turn to follow your swipe.';

  @override
  String get wtPracticeRightTitle => 'Try it! Swipe RIGHT';

  @override
  String get wtPracticeRightMsg => 'Swipe RIGHT on the screen to continue.';

  @override
  String get wtPracticeUpTitle => 'Great! Now swipe UP';

  @override
  String get wtPracticeUpMsg => 'Swipe UP on the screen to continue.';

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
      'Tap the pause icon to freeze the run. From there you can resume, restart, open the Game Guide, replay this tutorial, or toggle the D-Pad.';

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
  String get wtSwipeRightUpper => 'SWIPE RIGHT';

  @override
  String get wtSwipeLeftUpper => 'SWIPE LEFT';

  @override
  String get wtSwipeUpUpper => 'SWIPE UP';

  @override
  String get wtSwipeDownUpper => 'SWIPE DOWN';

  @override
  String get wtSwipeAnywhereScreen => 'Swipe anywhere on screen!';

  @override
  String get wtSwipeAnywhere => 'Swipe anywhere!';

  @override
  String get wtGotIt => 'Got it!';

  @override
  String get wtNext => 'Next';

  @override
  String get wtSkip => 'Skip';

  @override
  String get wtWaiting => 'Waiting...';

  @override
  String get hwPlayTitle => 'Welcome to Snake Classic!';

  @override
  String get hwPlayMsg =>
      'Tap the PLAY button to start a game. Swipe to control your snake and eat food to grow!';

  @override
  String get hwCoinsTitle => 'Your Coins';

  @override
  String get hwCoinsMsg =>
      'Earn coins by playing games, completing challenges, and daily bonuses. Use them in the store!';

  @override
  String get hwDailyTitle => 'Daily Challenges';

  @override
  String get hwDailyMsg =>
      'Complete daily challenges for bonus coins and rewards. New challenges every day!';

  @override
  String get hwStoreTitle => 'The Store';

  @override
  String get hwStoreMsg =>
      'Buy themes, snake skins, trails, and power-ups with your coins. Unlock Pro for premium boards and exclusive cosmetics.';

  @override
  String get hwCosmeticsTitle => 'Skins & Trails';

  @override
  String get hwCosmeticsMsg =>
      'Customize your snake here. Skins change how the snake itself looks; trails leave a glow behind it. Earn with coins or unlock with Pro.';

  @override
  String get hwProfileTitle => 'Your Profile';

  @override
  String get hwProfileMsg =>
      'Stats, achievements, and high scores live here. Achievements unlock as you hit milestones — some require a specific mode (Classic, Hard, etc.). Sign in to sync across devices.';

  @override
  String get hwSettingsTitle => 'Settings';

  @override
  String get hwSettingsMsg =>
      'Customize your game experience - change themes, controls, audio, and more!';

  @override
  String get hudScoreUpper => 'SCORE';

  @override
  String hudScoreSemantics(Object value) {
    return 'Score $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'LV$level';
  }

  @override
  String get hudTournamentBadge => 'TOURNAMENT';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'PAUSED';

  @override
  String get poPremium => 'Premium';

  @override
  String get poStore => 'Store';

  @override
  String get poResume => 'RESUME';

  @override
  String get poRestart => 'RESTART';

  @override
  String get poHome => 'HOME';

  @override
  String get poDPadOn => 'D-PAD: ON';

  @override
  String get poDPadOff => 'D-PAD: OFF';

  @override
  String get poSound => 'SOUND';

  @override
  String get poMusic => 'MUSIC';

  @override
  String get poHowToPlay => 'HOW TO PLAY';

  @override
  String get poGameGuide => 'GAME GUIDE';

  @override
  String get poFoodUpper => 'FOOD';

  @override
  String get poPts10 => '10 pts';

  @override
  String get poPts25 => '25 pts';

  @override
  String get poPts50 => '50 pts';

  @override
  String get poComboUpper => 'COMBO';

  @override
  String get poBites5 => '5 bites';

  @override
  String get poBites10 => '10 bites';

  @override
  String get poBites20 => '20 bites';

  @override
  String get poComboHint =>
      'The fire chip near your score heats up and pulses on each tier crossing.';

  @override
  String get poPowerUpsUpper => 'POWER-UPS';

  @override
  String get poDur7s => '7s';

  @override
  String get poDur6s => '6s';

  @override
  String get poDur10s => '10s';

  @override
  String get poDur8s => '8s';

  @override
  String get poScore2x => 'Score 2×';

  @override
  String get poPowerUpHint =>
      'The ring around the icon drains as it expires. Timer freezes on pause.';

  @override
  String get poCrashUpper => 'CRASH';

  @override
  String get poCrashHint =>
      'A red shockwave fires at the cell you died on. Self-collision also highlights the body segment you hit in yellow.';

  @override
  String get poModesUpper => 'MODES';

  @override
  String get poModeWallsOn => 'walls on';

  @override
  String get poModeWallsOff => 'walls off';

  @override
  String get poModeFastTick => 'fast tick';

  @override
  String get poModeThreeFoods => '3 foods at once';

  @override
  String get poModeThreeLives => '3 lives, ramps up';

  @override
  String get poModeThreeMin => '3 min total';

  @override
  String get poModeFrequentPowerUps => 'frequent power-ups';

  @override
  String get poModeDontCross => 'don\'t cross your trail';

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
  String get gbLevel => 'Level';

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
  String get bundleTacticalPack => 'Tactical Power Pack';

  @override
  String get bundleTacticalPackDesc =>
      'Strategic power-ups for skilled players';

  @override
  String get bundleUltimatePack => 'Ultimate Power Pack';

  @override
  String get bundleUltimatePackDesc => 'Every premium power-up available';

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
  String get bprFree => 'Free';

  @override
  String get bprPremium => 'Premium';

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
  String get insTapScreen => 'Tap Screen';

  @override
  String get insTapScreenDesc => 'Pause/Resume game';

  @override
  String get insArrowKeys => 'Arrow Keys (Desktop)';

  @override
  String get insArrowKeysDesc => 'Change direction';

  @override
  String get insWasd => 'WASD (Desktop)';

  @override
  String get insWasdDesc => 'Change direction';

  @override
  String get insSpacebar => 'Spacebar (Desktop)';

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
  String get insRule1 => '• Eat food to grow and increase score';

  @override
  String get insRule2 => '• Snake speeds up as you level up';

  @override
  String get insRule3 => '• Game ends if you hit walls or yourself';

  @override
  String get insRule4 => '• Special food appears every 10 normal foods';

  @override
  String get insRule5 => '• Bonus food expires after 15 seconds';

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
  String get insBackToGame => 'BACK TO GAME';

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
  String get dchClaimAll => 'Claim All';

  @override
  String get dchTodaysProgress => 'Today\'s Progress';

  @override
  String get dchClaim => 'Claim';

  @override
  String get dchClaimed => 'Claimed';

  @override
  String get dchAllCompleteTitle => 'All Challenges Complete!';

  @override
  String get dchBonusClaimed => 'Bonus reward claimed';

  @override
  String get dchBonusPending => 'Bonus reward pending — claim any challenge';

  @override
  String get dchLoading => 'Loading challenges...';

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
  String get wqClaimReward => 'Claim Reward';

  @override
  String get rvNotFound => 'Replay not found';

  @override
  String get rvLoadFailed => 'Failed to load replay';

  @override
  String rvTitle(Object name) {
    return 'Replay: $name';
  }

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
  String get pcTitle => 'Privacy & Terms Updated';

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
      'Guest accounts can play and save progress locally, but cannot buy items or subscribe. Link a Google or email account to unlock purchases — your existing coins, cosmetics, and high scores stay attached.';

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
  String get rvoContinue => 'CONTINUE?';

  @override
  String get rvoSubtitlePro => 'Revive and keep your score · Free with Pro';

  @override
  String rvoSubtitleTimer(Object seconds) {
    return 'Revive and keep your score · ${seconds}s';
  }

  @override
  String get rvoGetLifePro => 'Get Life · Free for Pro';

  @override
  String get rvoWatchAd => 'Watch ad to revive';

  @override
  String rvoUseCoins(Object coins) {
    return 'Use $coins coins';
  }

  @override
  String get rvoNoThanks => 'No thanks';

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
  String ppgLvShort(Object level) {
    return 'Lv $level';
  }

  @override
  String ppgLvUpper(Object level) {
    return 'LV $level';
  }

  @override
  String ppgLevel(Object level) {
    return 'Level $level';
  }

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
  String dchProgressSummary(Object completed, Object total) {
    return '$completed of $total challenges completed';
  }

  @override
  String wqProgressSummary(Object completed, Object total) {
    return '$completed / $total complete';
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
  String get goTomorrowLabel => 'COME BACK TOMORROW';

  @override
  String goTomorrowReward(int coins, int day) {
    return 'Claim $coins coins on day $day of your streak';
  }

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
}
