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
}
