import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// App title shown in the OS task switcher. Brand name — keep as-is in every language.
  ///
  /// In en, this message translates to:
  /// **'Snake Classic'**
  String get appTitle;

  /// Settings section header for the app language picker. Uppercase like the other section headers.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsSectionLanguage;

  /// Language picker option that follows the device language.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// Subtitle under the system-default language option.
  ///
  /// In en, this message translates to:
  /// **'Follow your device language'**
  String get languageSystemDefaultSubtitle;

  /// Generic cancel action in dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Match result dialog title when the player won. Uppercase, celebratory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY!'**
  String get mpVictory;

  /// No description provided for @mpDraw.
  ///
  /// In en, this message translates to:
  /// **'DRAW'**
  String get mpDraw;

  /// No description provided for @mpDefeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get mpDefeat;

  /// Label for the local player's own score/snake.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get mpYou;

  /// The 'versus' medallion between the two players. Short — 2-3 characters.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get mpVs;

  /// No description provided for @mpOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get mpOpponent;

  /// No description provided for @mpBackToLobby.
  ///
  /// In en, this message translates to:
  /// **'Back to Lobby'**
  String get mpBackToLobby;

  /// No description provided for @mpPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get mpPlayAgain;

  /// No description provided for @mpTimeUpDraw.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up — dead even!'**
  String get mpTimeUpDraw;

  /// No description provided for @mpTimeUpYouWon.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up — you had the higher score.'**
  String get mpTimeUpYouWon;

  /// No description provided for @mpTimeUpYouLost.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up — your opponent had the higher score.'**
  String get mpTimeUpYouLost;

  /// No description provided for @mpMutualCrashDraw.
  ///
  /// In en, this message translates to:
  /// **'Both snakes crashed — it\'s a tie!'**
  String get mpMutualCrashDraw;

  /// No description provided for @mpMutualCrashYouWon.
  ///
  /// In en, this message translates to:
  /// **'Both snakes crashed — your score decided it.'**
  String get mpMutualCrashYouWon;

  /// No description provided for @mpMutualCrashYouLost.
  ///
  /// In en, this message translates to:
  /// **'Both snakes crashed — their score decided it.'**
  String get mpMutualCrashYouLost;

  /// No description provided for @mpMatchCancelled.
  ///
  /// In en, this message translates to:
  /// **'The match was cancelled.'**
  String get mpMatchCancelled;

  /// No description provided for @mpLastSnakeStanding.
  ///
  /// In en, this message translates to:
  /// **'Your opponent crashed. Last snake standing!'**
  String get mpLastSnakeStanding;

  /// No description provided for @mpDeathWall.
  ///
  /// In en, this message translates to:
  /// **'You crashed into the wall.'**
  String get mpDeathWall;

  /// No description provided for @mpDeathSelf.
  ///
  /// In en, this message translates to:
  /// **'You crashed into yourself.'**
  String get mpDeathSelf;

  /// No description provided for @mpDeathOpponent.
  ///
  /// In en, this message translates to:
  /// **'You crashed into your opponent.'**
  String get mpDeathOpponent;

  /// No description provided for @mpDeathHeadOn.
  ///
  /// In en, this message translates to:
  /// **'Head-on collision!'**
  String get mpDeathHeadOn;

  /// No description provided for @mpDeathForfeit.
  ///
  /// In en, this message translates to:
  /// **'Disconnected too long — match forfeited.'**
  String get mpDeathForfeit;

  /// No description provided for @mpBetterLuck.
  ///
  /// In en, this message translates to:
  /// **'Better luck next time!'**
  String get mpBetterLuck;

  /// Coin reward chip on the victory dialog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{+{count} coin} other{+{count} coins}}'**
  String mpCoinReward(int count);

  /// No description provided for @mpLeaveGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Game?'**
  String get mpLeaveGameTitle;

  /// No description provided for @mpLeaveGameBody.
  ///
  /// In en, this message translates to:
  /// **'The match keeps running on the server — leaving forfeits it.'**
  String get mpLeaveGameBody;

  /// No description provided for @mpLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get mpLeave;

  /// No description provided for @mpReconnecting.
  ///
  /// In en, this message translates to:
  /// **'RECONNECTING…'**
  String get mpReconnecting;

  /// No description provided for @mpReconnectingBody.
  ///
  /// In en, this message translates to:
  /// **'The match is still running on the server.'**
  String get mpReconnectingBody;

  /// No description provided for @mpGetReady.
  ///
  /// In en, this message translates to:
  /// **'GET READY'**
  String get mpGetReady;

  /// No description provided for @mpDroppingIntoArena.
  ///
  /// In en, this message translates to:
  /// **'Dropping you into the arena…'**
  String get mpDroppingIntoArena;

  /// Placeholder name in the versus header before the opponent is known. Keep short — the slot fits ~9 characters.
  ///
  /// In en, this message translates to:
  /// **'Waiting…'**
  String get mpWaitingPlayer;

  /// Tag on a player whose snake is dead. Very short.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get mpOut;

  /// Stat pill label for the snake's body length. Uppercase, short.
  ///
  /// In en, this message translates to:
  /// **'LENGTH'**
  String get mpLength;

  /// Label on the swipe input indicator.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get mpSwipe;

  /// Small inline status under an opponent who lost connection. Lowercase.
  ///
  /// In en, this message translates to:
  /// **'reconnecting…'**
  String get mpReconnectingInline;

  /// The big main-menu play button. Uppercase, punchy.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get homePlay;

  /// No description provided for @homeHighScore.
  ///
  /// In en, this message translates to:
  /// **'HIGH SCORE'**
  String get homeHighScore;

  /// Loadout chip when a power-up is pre-loaded for the next game.
  ///
  /// In en, this message translates to:
  /// **'Armed: {name}'**
  String homeArmedPowerUp(String name);

  /// No description provided for @homeLoadoutCount.
  ///
  /// In en, this message translates to:
  /// **'Loadout ({count})'**
  String homeLoadoutCount(int count);

  /// No description provided for @puSpeedBoost.
  ///
  /// In en, this message translates to:
  /// **'Speed Boost'**
  String get puSpeedBoost;

  /// No description provided for @puInvincibility.
  ///
  /// In en, this message translates to:
  /// **'Invincibility'**
  String get puInvincibility;

  /// No description provided for @puScoreMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Score Multiplier'**
  String get puScoreMultiplier;

  /// No description provided for @puSlowMotion.
  ///
  /// In en, this message translates to:
  /// **'Slow Motion'**
  String get puSlowMotion;

  /// No description provided for @homeTilePro.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get homeTilePro;

  /// No description provided for @homeTileStore.
  ///
  /// In en, this message translates to:
  /// **'STORE'**
  String get homeTileStore;

  /// No description provided for @homeTileFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get homeTileFree;

  /// No description provided for @homeTileDaily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get homeTileDaily;

  /// No description provided for @homeTileBattle.
  ///
  /// In en, this message translates to:
  /// **'BATTLE'**
  String get homeTileBattle;

  /// No description provided for @homeTileEvents.
  ///
  /// In en, this message translates to:
  /// **'EVENTS'**
  String get homeTileEvents;

  /// No description provided for @homeTileBoard.
  ///
  /// In en, this message translates to:
  /// **'BOARD'**
  String get homeTileBoard;

  /// No description provided for @homeTileFriends.
  ///
  /// In en, this message translates to:
  /// **'FRIENDS'**
  String get homeTileFriends;

  /// No description provided for @homeTileCosmetics.
  ///
  /// In en, this message translates to:
  /// **'COSMETICS'**
  String get homeTileCosmetics;

  /// No description provided for @homeTileAwards.
  ///
  /// In en, this message translates to:
  /// **'AWARDS'**
  String get homeTileAwards;

  /// Home grid tile labels — very short, they sit under icons in a fixed-size tile.
  ///
  /// In en, this message translates to:
  /// **'VERSUS'**
  String get homeTileVersus;

  /// No description provided for @homeNoAdReady.
  ///
  /// In en, this message translates to:
  /// **'No ad ready just yet — try again in a few seconds.'**
  String get homeNoAdReady;

  /// No description provided for @homeFreeSpeedBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Speed Boost'**
  String get homeFreeSpeedBoostTitle;

  /// No description provided for @homeFreeSpeedBoostBody.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to add a free Speed Boost power-up to your loadout. It activates 5 seconds into your next game.'**
  String get homeFreeSpeedBoostBody;

  /// No description provided for @homeNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get homeNotNow;

  /// No description provided for @homeWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get homeWatchAd;

  /// No description provided for @homeFreeSpeedBoostAdded.
  ///
  /// In en, this message translates to:
  /// **'Free Speed Boost added to your loadout!'**
  String get homeFreeSpeedBoostAdded;

  /// No description provided for @homeAdNotFinished.
  ///
  /// In en, this message translates to:
  /// **'Ad not finished — watch the full ad to earn your reward.'**
  String get homeAdNotFinished;

  /// No description provided for @homePickGameMode.
  ///
  /// In en, this message translates to:
  /// **'Pick a Game Mode'**
  String get homePickGameMode;

  /// No description provided for @homePickGameModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings'**
  String get homePickGameModeSubtitle;

  /// No description provided for @homeStartPlaying.
  ///
  /// In en, this message translates to:
  /// **'START PLAYING'**
  String get homeStartPlaying;

  /// No description provided for @homeLoadoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Power-Up Loadout'**
  String get homeLoadoutTitle;

  /// No description provided for @homeLoadoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-load one power-up — it activates 5 seconds into your next game.'**
  String get homeLoadoutSubtitle;

  /// No description provided for @homeWatchAdFreeSpeedBoost.
  ///
  /// In en, this message translates to:
  /// **'Watch ad — free Speed Boost'**
  String get homeWatchAdFreeSpeedBoost;

  /// No description provided for @homeNoPowerUps.
  ///
  /// In en, this message translates to:
  /// **'You have no power-ups.\nVisit the store to buy some!'**
  String get homeNoPowerUps;

  /// No description provided for @homeOwnedCount.
  ///
  /// In en, this message translates to:
  /// **'Owned: {count}'**
  String homeOwnedCount(int count);

  /// No description provided for @homeArmed.
  ///
  /// In en, this message translates to:
  /// **'ARMED'**
  String get homeArmed;

  /// No description provided for @homeDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get homeDone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsBackToGame.
  ///
  /// In en, this message translates to:
  /// **'BACK TO GAME'**
  String get settingsBackToGame;

  /// No description provided for @settingsSectionControls.
  ///
  /// In en, this message translates to:
  /// **'CONTROLS'**
  String get settingsSectionControls;

  /// No description provided for @settingsSectionGameplay.
  ///
  /// In en, this message translates to:
  /// **'GAMEPLAY'**
  String get settingsSectionGameplay;

  /// No description provided for @settingsSectionAudio.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get settingsSectionAudio;

  /// No description provided for @settingsSectionVisual.
  ///
  /// In en, this message translates to:
  /// **'VISUAL'**
  String get settingsSectionVisual;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionUserProfile.
  ///
  /// In en, this message translates to:
  /// **'USER PROFILE'**
  String get settingsSectionUserProfile;

  /// No description provided for @settingsSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'HELP & TUTORIAL'**
  String get settingsSectionHelp;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get settingsSectionLegal;

  /// No description provided for @settingsSectionPremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM FEATURES'**
  String get settingsSectionPremium;

  /// No description provided for @settingsDPadControls.
  ///
  /// In en, this message translates to:
  /// **'D-Pad Controls'**
  String get settingsDPadControls;

  /// No description provided for @settingsDPadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show on-screen directional buttons during gameplay'**
  String get settingsDPadSubtitle;

  /// No description provided for @settingsDPadPosition.
  ///
  /// In en, this message translates to:
  /// **'D-Pad Position'**
  String get settingsDPadPosition;

  /// No description provided for @settingsDesktopControls.
  ///
  /// In en, this message translates to:
  /// **'Desktop/Web Controls'**
  String get settingsDesktopControls;

  /// No description provided for @settingsArrowKeys.
  ///
  /// In en, this message translates to:
  /// **'Arrow Keys'**
  String get settingsArrowKeys;

  /// No description provided for @settingsWasdKeys.
  ///
  /// In en, this message translates to:
  /// **'WASD Keys'**
  String get settingsWasdKeys;

  /// No description provided for @settingsSpacebar.
  ///
  /// In en, this message translates to:
  /// **'Spacebar'**
  String get settingsSpacebar;

  /// No description provided for @settingsMouseClick.
  ///
  /// In en, this message translates to:
  /// **'Mouse Click'**
  String get settingsMouseClick;

  /// No description provided for @settingsChangeDirection.
  ///
  /// In en, this message translates to:
  /// **'Change direction'**
  String get settingsChangeDirection;

  /// No description provided for @settingsPauseResume.
  ///
  /// In en, this message translates to:
  /// **'Pause/Resume game'**
  String get settingsPauseResume;

  /// No description provided for @settingsTouchControlsIfAvailable.
  ///
  /// In en, this message translates to:
  /// **'Touch Controls (if available)'**
  String get settingsTouchControlsIfAvailable;

  /// No description provided for @settingsTouchControls.
  ///
  /// In en, this message translates to:
  /// **'Touch Controls'**
  String get settingsTouchControls;

  /// No description provided for @settingsSwipeGestures.
  ///
  /// In en, this message translates to:
  /// **'Swipe Gestures'**
  String get settingsSwipeGestures;

  /// No description provided for @settingsTapScreen.
  ///
  /// In en, this message translates to:
  /// **'Tap Screen'**
  String get settingsTapScreen;

  /// No description provided for @settingsSwipeUp.
  ///
  /// In en, this message translates to:
  /// **'Swipe Up ↑'**
  String get settingsSwipeUp;

  /// No description provided for @settingsSwipeDown.
  ///
  /// In en, this message translates to:
  /// **'Swipe Down ↓'**
  String get settingsSwipeDown;

  /// No description provided for @settingsSwipeLeft.
  ///
  /// In en, this message translates to:
  /// **'Swipe Left ←'**
  String get settingsSwipeLeft;

  /// No description provided for @settingsSwipeRight.
  ///
  /// In en, this message translates to:
  /// **'Swipe Right →'**
  String get settingsSwipeRight;

  /// No description provided for @settingsMoveSnakeUp.
  ///
  /// In en, this message translates to:
  /// **'Move snake up'**
  String get settingsMoveSnakeUp;

  /// No description provided for @settingsMoveSnakeDown.
  ///
  /// In en, this message translates to:
  /// **'Move snake down'**
  String get settingsMoveSnakeDown;

  /// No description provided for @settingsMoveSnakeLeft.
  ///
  /// In en, this message translates to:
  /// **'Move snake left'**
  String get settingsMoveSnakeLeft;

  /// No description provided for @settingsMoveSnakeRight.
  ///
  /// In en, this message translates to:
  /// **'Move snake right'**
  String get settingsMoveSnakeRight;

  /// No description provided for @settingsGameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get settingsGameMode;

  /// No description provided for @settingsGameModeLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete current game to change game mode'**
  String get settingsGameModeLocked;

  /// No description provided for @settingsDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get settingsDifficulty;

  /// No description provided for @settingsDifficultySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sets how fast the snake starts. Each mode still speeds up as you level.'**
  String get settingsDifficultySubtitle;

  /// No description provided for @settingsEasyNote.
  ///
  /// In en, this message translates to:
  /// **'Coins, XP and achievements still count on Easy — only high scores and leaderboards are paused.'**
  String get settingsEasyNote;

  /// No description provided for @settingsDifficultyLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish your current game to change difficulty.'**
  String get settingsDifficultyLocked;

  /// No description provided for @settingsCurrentSize.
  ///
  /// In en, this message translates to:
  /// **'Current Size'**
  String get settingsCurrentSize;

  /// No description provided for @settingsBoardSizeLocked.
  ///
  /// In en, this message translates to:
  /// **'Complete current game to change board size'**
  String get settingsBoardSizeLocked;

  /// No description provided for @settingsCurrentDuration.
  ///
  /// In en, this message translates to:
  /// **'Current Duration'**
  String get settingsCurrentDuration;

  /// No description provided for @settingsCrashFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How long to show crash explanation'**
  String get settingsCrashFeedbackSubtitle;

  /// No description provided for @settingsScreenShake.
  ///
  /// In en, this message translates to:
  /// **'Screen Shake'**
  String get settingsScreenShake;

  /// No description provided for @settingsScreenShakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shake the screen on collisions and game events'**
  String get settingsScreenShakeSubtitle;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on game events and button presses'**
  String get settingsVibrationSubtitle;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsBackgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get settingsBackgroundMusic;

  /// No description provided for @settingsCurrentTheme.
  ///
  /// In en, this message translates to:
  /// **'Current Theme'**
  String get settingsCurrentTheme;

  /// No description provided for @settingsBrowseThemes.
  ///
  /// In en, this message translates to:
  /// **'BROWSE THEMES'**
  String get settingsBrowseThemes;

  /// No description provided for @settingsSnakeTrail.
  ///
  /// In en, this message translates to:
  /// **'Snake Trail Effects'**
  String get settingsSnakeTrail;

  /// No description provided for @settingsSnakeTrailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable particle trails behind the snake'**
  String get settingsSnakeTrailSubtitle;

  /// No description provided for @settingsNotifDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get settingsNotifDailyReminder;

  /// No description provided for @settingsNotifTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament Alerts'**
  String get settingsNotifTournament;

  /// No description provided for @settingsNotifAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocks'**
  String get settingsNotifAchievement;

  /// No description provided for @settingsNotifSocial.
  ///
  /// In en, this message translates to:
  /// **'Social Updates'**
  String get settingsNotifSocial;

  /// No description provided for @settingsNotifSpecialEvents.
  ///
  /// In en, this message translates to:
  /// **'Special Events'**
  String get settingsNotifSpecialEvents;

  /// No description provided for @settingsNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsNotSet;

  /// No description provided for @settingsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get settingsUsername;

  /// No description provided for @settingsGuestAccount.
  ///
  /// In en, this message translates to:
  /// **'Guest Account'**
  String get settingsGuestAccount;

  /// No description provided for @settingsAuthenticatedAccount.
  ///
  /// In en, this message translates to:
  /// **'Authenticated Account'**
  String get settingsAuthenticatedAccount;

  /// No description provided for @settingsChangeUsername.
  ///
  /// In en, this message translates to:
  /// **'CHANGE USERNAME'**
  String get settingsChangeUsername;

  /// No description provided for @settingsGuestSignInHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your progress and play with friends'**
  String get settingsGuestSignInHint;

  /// No description provided for @settingsUsernameVisibleHint.
  ///
  /// In en, this message translates to:
  /// **'Your username is visible to friends and on leaderboards'**
  String get settingsUsernameVisibleHint;

  /// No description provided for @settingsReplayTutorial.
  ///
  /// In en, this message translates to:
  /// **'REPLAY TUTORIAL'**
  String get settingsReplayTutorial;

  /// No description provided for @settingsReplayTutorialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch the home tour or game tutorial again'**
  String get settingsReplayTutorialSubtitle;

  /// No description provided for @settingsAboutCredits.
  ///
  /// In en, this message translates to:
  /// **'ABOUT & CREDITS'**
  String get settingsAboutCredits;

  /// No description provided for @settingsAboutCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App version, credits, and links'**
  String get settingsAboutCreditsSubtitle;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'RATE SNAKE CLASSIC'**
  String get settingsRateApp;

  /// No description provided for @settingsRateAppSubtitleIos.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the game? Leave a review on the App Store'**
  String get settingsRateAppSubtitleIos;

  /// No description provided for @settingsRateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying the game? Leave us a review!'**
  String get settingsRateAppSubtitle;

  /// No description provided for @settingsAdPrivacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY & AD CHOICES'**
  String get settingsAdPrivacy;

  /// No description provided for @settingsAdPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage personalized ad consent'**
  String get settingsAdPrivacySubtitle;

  /// No description provided for @settingsAdPrivacyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy options aren\'t available right now.'**
  String get settingsAdPrivacyUnavailable;

  /// No description provided for @settingsReplayDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay Tutorial'**
  String get settingsReplayDialogTitle;

  /// No description provided for @settingsReplayDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Which tutorial would you like to replay?'**
  String get settingsReplayDialogBody;

  /// No description provided for @settingsHomeTour.
  ///
  /// In en, this message translates to:
  /// **'Home Tour'**
  String get settingsHomeTour;

  /// No description provided for @settingsGameTutorial.
  ///
  /// In en, this message translates to:
  /// **'Game Tutorial'**
  String get settingsGameTutorial;

  /// No description provided for @settingsPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicyTitle;

  /// No description provided for @settingsPrivacyPolicyButton.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY POLICY'**
  String get settingsPrivacyPolicyButton;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingsTermsTitle;

  /// No description provided for @settingsTermsButton.
  ///
  /// In en, this message translates to:
  /// **'TERMS OF USE'**
  String get settingsTermsButton;

  /// No description provided for @settingsChangeUsernameTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get settingsChangeUsernameTitle;

  /// No description provided for @settingsCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current:'**
  String get settingsCurrentLabel;

  /// No description provided for @settingsUsernameDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username that represents you in the game.'**
  String get settingsUsernameDialogBody;

  /// No description provided for @settingsEnterNewUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter new username'**
  String get settingsEnterNewUsername;

  /// No description provided for @settingsUsernameRules.
  ///
  /// In en, this message translates to:
  /// **'• 3-20 characters\n• Must start with a letter\n• Letters, numbers, and underscores only'**
  String get settingsUsernameRules;

  /// No description provided for @settingsUsernameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update username'**
  String get settingsUsernameUpdateFailed;

  /// No description provided for @settingsUsernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated to \"{name}\"'**
  String settingsUsernameUpdated(String name);

  /// No description provided for @settingsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settingsUpdate;

  /// No description provided for @settingsProTitle.
  ///
  /// In en, this message translates to:
  /// **'Snake Classic Pro'**
  String get settingsProTitle;

  /// No description provided for @settingsPremiumStatus.
  ///
  /// In en, this message translates to:
  /// **'Premium Status'**
  String get settingsPremiumStatus;

  /// No description provided for @settingsActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Active subscription'**
  String get settingsActiveSubscription;

  /// No description provided for @settingsUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium features'**
  String get settingsUnlockPremium;

  /// No description provided for @settingsRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String settingsRenews(String date);

  /// No description provided for @settingsProBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get settingsProBadge;

  /// No description provided for @settingsUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get settingsUpgradeToPro;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get settingsPurchaseHistory;

  /// No description provided for @settingsSnakeCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Snake Cosmetics'**
  String get settingsSnakeCosmetics;

  /// No description provided for @settingsBattlePass.
  ///
  /// In en, this message translates to:
  /// **'Battle Pass'**
  String get settingsBattlePass;

  /// No description provided for @settingsTier.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier}'**
  String settingsTier(int tier);

  /// No description provided for @settingsRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get settingsRestoring;

  /// No description provided for @settingsRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get settingsRestored;

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases. Please try again.'**
  String get settingsRestoreFailed;

  /// No description provided for @settingsNoPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases found'**
  String get settingsNoPurchases;

  /// No description provided for @settingsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get settingsUnknown;

  /// No description provided for @settingsStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String settingsStatusLine(String status);

  /// No description provided for @settingsDateLine.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String settingsDateLine(String date);

  /// No description provided for @settingsPurchaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Purchase #{number}'**
  String settingsPurchaseNumber(int number);

  /// No description provided for @settingsDataParseError.
  ///
  /// In en, this message translates to:
  /// **'Data parsing error'**
  String get settingsDataParseError;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load purchase history'**
  String get settingsHistoryLoadFailed;

  /// No description provided for @settingsUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get settingsUnknownDate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'pl',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
