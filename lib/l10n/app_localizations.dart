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

  /// No description provided for @mpLobbyNoFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends yet — add some from the Friends screen!'**
  String get mpLobbyNoFriends;

  /// No description provided for @mpLobbyInviteFriendTo.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend to room {code}'**
  String mpLobbyInviteFriendTo(Object code);

  /// No description provided for @mpLobbyInviteSent.
  ///
  /// In en, this message translates to:
  /// **'🎮 Invite sent to {name}!'**
  String mpLobbyInviteSent(Object name);

  /// No description provided for @mpLobbyInviteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the invite — try again'**
  String get mpLobbyInviteFailed;

  /// No description provided for @mpLobbyOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Multiplayer requires an internet connection.'**
  String get mpLobbyOffline;

  /// No description provided for @mpLobbyDismiss.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get mpLobbyDismiss;

  /// No description provided for @mpLobbyGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get mpLobbyGo;

  /// No description provided for @mpLobbyGetReady.
  ///
  /// In en, this message translates to:
  /// **'Get Ready!'**
  String get mpLobbyGetReady;

  /// No description provided for @mpLobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'MULTIPLAYER'**
  String get mpLobbyTitle;

  /// No description provided for @mpLobbySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play with friends online'**
  String get mpLobbySubtitle;

  /// No description provided for @mpLobbyRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Room: {code}'**
  String mpLobbyRoomCode(Object code);

  /// No description provided for @mpLobbyRoomCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Room code copied!'**
  String get mpLobbyRoomCodeCopied;

  /// No description provided for @mpLobbyQuickMatch.
  ///
  /// In en, this message translates to:
  /// **'QUICK MATCH'**
  String get mpLobbyQuickMatch;

  /// No description provided for @mpLobbyQuickMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1v1 Classic — find an opponent automatically'**
  String get mpLobbyQuickMatchSubtitle;

  /// No description provided for @mpLobbyFinding.
  ///
  /// In en, this message translates to:
  /// **'FINDING...'**
  String get mpLobbyFinding;

  /// No description provided for @mpLobbyFindMatch.
  ///
  /// In en, this message translates to:
  /// **'FIND MATCH'**
  String get mpLobbyFindMatch;

  /// No description provided for @mpLobbySeconds.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get mpLobbySeconds;

  /// No description provided for @mpLobbySearching.
  ///
  /// In en, this message translates to:
  /// **'SEARCHING FOR PLAYERS...'**
  String get mpLobbySearching;

  /// No description provided for @mpLobbyModePlayers.
  ///
  /// In en, this message translates to:
  /// **'{mode} • {count, plural, one{{count} Player} other{{count} Players}}'**
  String mpLobbyModePlayers(num count, Object mode);

  /// No description provided for @mpLobbyQueuePosition.
  ///
  /// In en, this message translates to:
  /// **'Queue Position: {position}'**
  String mpLobbyQueuePosition(Object position);

  /// No description provided for @mpLobbyCancelUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get mpLobbyCancelUpper;

  /// No description provided for @mpLobbyNoPlayersFound.
  ///
  /// In en, this message translates to:
  /// **'NO PLAYERS FOUND'**
  String get mpLobbyNoPlayersFound;

  /// No description provided for @mpLobbyNoPlayersBody.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we couldn\'t find any opponents.\nTry again or create your own room!'**
  String get mpLobbyNoPlayersBody;

  /// No description provided for @mpLobbyGoBack.
  ///
  /// In en, this message translates to:
  /// **'GO BACK'**
  String get mpLobbyGoBack;

  /// No description provided for @mpLobbyTryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get mpLobbyTryAgain;

  /// No description provided for @mpLobbyWinsChip.
  ///
  /// In en, this message translates to:
  /// **'{count} W'**
  String mpLobbyWinsChip(Object count);

  /// No description provided for @mpLobbyLossesChip.
  ///
  /// In en, this message translates to:
  /// **'{count} L'**
  String mpLobbyLossesChip(Object count);

  /// No description provided for @mpLobbyDrawsChip.
  ///
  /// In en, this message translates to:
  /// **'{count} D'**
  String mpLobbyDrawsChip(Object count);

  /// No description provided for @mpLobbyJoinRoom.
  ///
  /// In en, this message translates to:
  /// **'JOIN ROOM'**
  String get mpLobbyJoinRoom;

  /// No description provided for @mpLobbyJoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter room code to join'**
  String get mpLobbyJoinSubtitle;

  /// No description provided for @mpLobbyEnterRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Enter room code'**
  String get mpLobbyEnterRoomCode;

  /// No description provided for @mpLobbyCreateRoom.
  ///
  /// In en, this message translates to:
  /// **'CREATE ROOM'**
  String get mpLobbyCreateRoom;

  /// No description provided for @mpLobbyCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a 1v1 room and invite a friend'**
  String get mpLobbyCreateSubtitle;

  /// No description provided for @mpLobbyPlayersHeader.
  ///
  /// In en, this message translates to:
  /// **'PLAYERS ({current}/{max})'**
  String mpLobbyPlayersHeader(Object current, Object max);

  /// No description provided for @mpLobbyYouBadge.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get mpLobbyYouBadge;

  /// No description provided for @mpLobbyWaitingForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for player...'**
  String get mpLobbyWaitingForPlayer;

  /// No description provided for @mpLobbyStartGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get mpLobbyStartGame;

  /// No description provided for @mpLobbyWaitingForHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for host to start...'**
  String get mpLobbyWaitingForHost;

  /// No description provided for @mpLobbyLeave.
  ///
  /// In en, this message translates to:
  /// **'LEAVE'**
  String get mpLobbyLeave;

  /// No description provided for @mpLobbyReadyDone.
  ///
  /// In en, this message translates to:
  /// **'READY!'**
  String get mpLobbyReadyDone;

  /// No description provided for @mpLobbyReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get mpLobbyReady;

  /// No description provided for @mpModeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Traditional Snake battle'**
  String get mpModeClassicDesc;

  /// No description provided for @mpModeSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Speed increases over time'**
  String get mpModeSpeedDesc;

  /// No description provided for @mpModeSurvivalDesc.
  ///
  /// In en, this message translates to:
  /// **'Last snake standing wins'**
  String get mpModeSurvivalDesc;

  /// No description provided for @mpModePowerUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Power-ups everywhere!'**
  String get mpModePowerUpDesc;

  /// No description provided for @mpStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get mpStatusWaiting;

  /// No description provided for @mpStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get mpStatusReady;

  /// No description provided for @mpStatusPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get mpStatusPlaying;

  /// No description provided for @mpStatusCrashed.
  ///
  /// In en, this message translates to:
  /// **'Crashed'**
  String get mpStatusCrashed;

  /// No description provided for @mpStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get mpStatusDisconnected;

  /// No description provided for @goNoAdAvailable.
  ///
  /// In en, this message translates to:
  /// **'No ad available right now, try again shortly'**
  String get goNoAdAvailable;

  /// No description provided for @goCoinsDoubled.
  ///
  /// In en, this message translates to:
  /// **'🎉 Coins doubled — +{count} bonus coins!'**
  String goCoinsDoubled(Object count);

  /// No description provided for @goWatchToDouble.
  ///
  /// In en, this message translates to:
  /// **'Watch to double your {count} coins'**
  String goWatchToDouble(Object count);

  /// No description provided for @goRewardClaimLine.
  ///
  /// In en, this message translates to:
  /// **'+{coins} coins  •  +{xp} XP'**
  String goRewardClaimLine(Object coins, Object xp);

  /// No description provided for @goClaimedTotal.
  ///
  /// In en, this message translates to:
  /// **'Claimed {count} coins from daily challenges!'**
  String goClaimedTotal(Object count);

  /// No description provided for @goRibbonNewHighScore.
  ///
  /// In en, this message translates to:
  /// **'NEW HIGH SCORE!'**
  String get goRibbonNewHighScore;

  /// No description provided for @goRibbonTournamentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT SCORE SUBMITTED!'**
  String get goRibbonTournamentSubmitted;

  /// No description provided for @goRibbonTournamentFailed.
  ///
  /// In en, this message translates to:
  /// **'SCORE NOT SUBMITTED — CHECK CONNECTION'**
  String get goRibbonTournamentFailed;

  /// No description provided for @goRibbonTournamentSubmitting.
  ///
  /// In en, this message translates to:
  /// **'SUBMITTING TOURNAMENT SCORE…'**
  String get goRibbonTournamentSubmitting;

  /// No description provided for @goVictory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY!'**
  String get goVictory;

  /// No description provided for @goGameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get goGameOver;

  /// No description provided for @goFinalScore.
  ///
  /// In en, this message translates to:
  /// **'FINAL SCORE'**
  String get goFinalScore;

  /// No description provided for @goLevel.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get goLevel;

  /// No description provided for @goBest.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get goBest;

  /// No description provided for @goCoinsEarned.
  ///
  /// In en, this message translates to:
  /// **'Coins Earned'**
  String get goCoinsEarned;

  /// No description provided for @goDailyRewardsReady.
  ///
  /// In en, this message translates to:
  /// **'DAILY REWARDS READY'**
  String get goDailyRewardsReady;

  /// No description provided for @goRewardsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} reward} other{{count} rewards}}  •  +{coins} coins  •  +{xp} XP'**
  String goRewardsSummary(Object coins, num count, Object xp);

  /// No description provided for @goClaimAll.
  ///
  /// In en, this message translates to:
  /// **'CLAIM ALL'**
  String get goClaimAll;

  /// No description provided for @goXpAmount.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String goXpAmount(Object xp);

  /// No description provided for @goClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get goClaim;

  /// No description provided for @goAchievements.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENTS'**
  String get goAchievements;

  /// No description provided for @goRecentlyUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Recently Unlocked'**
  String get goRecentlyUnlocked;

  /// No description provided for @goInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get goInProgress;

  /// No description provided for @goPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get goPlayAgain;

  /// No description provided for @goMenu.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get goMenu;

  /// No description provided for @storeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snake Store'**
  String get storeTitle;

  /// No description provided for @storeTabPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get storeTabPro;

  /// No description provided for @storeTabCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get storeTabCoins;

  /// No description provided for @storeTabThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get storeTabThemes;

  /// No description provided for @storeTabSkins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get storeTabSkins;

  /// No description provided for @storeTabTrails.
  ///
  /// In en, this message translates to:
  /// **'Trails'**
  String get storeTabTrails;

  /// No description provided for @storeTabPowerUps.
  ///
  /// In en, this message translates to:
  /// **'Power-Ups'**
  String get storeTabPowerUps;

  /// No description provided for @storeYourCoins.
  ///
  /// In en, this message translates to:
  /// **'Your Snake Coins'**
  String get storeYourCoins;

  /// No description provided for @storeBonusMultiplier.
  ///
  /// In en, this message translates to:
  /// **'{multiplier}x BONUS'**
  String storeBonusMultiplier(Object multiplier);

  /// No description provided for @storeSubscribeBeforePromoEnds.
  ///
  /// In en, this message translates to:
  /// **'Subscribe before your free Pro ends'**
  String get storeSubscribeBeforePromoEnds;

  /// No description provided for @storeChooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get storeChooseYourPlan;

  /// No description provided for @storeWhatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get storeWhatYouGet;

  /// No description provided for @storeProHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All premium themes, skins & trails · big boards · 2× coins · premium power-ups · tournament entries · Battle Pass Premium'**
  String get storeProHeroSubtitle;

  /// No description provided for @storeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get storeMonthly;

  /// No description provided for @storeYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get storeYearly;

  /// No description provided for @storePerMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get storePerMonth;

  /// No description provided for @storePerYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get storePerYear;

  /// No description provided for @storeSave17.
  ///
  /// In en, this message translates to:
  /// **'Save 17%'**
  String get storeSave17;

  /// No description provided for @storePlanDisplayName.
  ///
  /// In en, this message translates to:
  /// **'{title} plan'**
  String storePlanDisplayName(Object title);

  /// No description provided for @storeVerifyingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get storeVerifyingEllipsis;

  /// No description provided for @storeSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get storeSubscribe;

  /// No description provided for @storeYoureOnFreePro.
  ///
  /// In en, this message translates to:
  /// **'You\'re on free Pro!'**
  String get storeYoureOnFreePro;

  /// No description provided for @storeYourePro.
  ///
  /// In en, this message translates to:
  /// **'You\'re Pro!'**
  String get storeYourePro;

  /// No description provided for @storeFreePro.
  ///
  /// In en, this message translates to:
  /// **'Free Pro'**
  String get storeFreePro;

  /// No description provided for @storeProMonthly.
  ///
  /// In en, this message translates to:
  /// **'Pro Monthly'**
  String get storeProMonthly;

  /// No description provided for @storeKeepPro.
  ///
  /// In en, this message translates to:
  /// **'Keep Pro — Subscribe'**
  String get storeKeepPro;

  /// No description provided for @storePromoBadge.
  ///
  /// In en, this message translates to:
  /// **'PROMO'**
  String get storePromoBadge;

  /// No description provided for @storeEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get storeEndingSoon;

  /// No description provided for @storeEndsInDh.
  ///
  /// In en, this message translates to:
  /// **'Ends in {days}d {hours}h'**
  String storeEndsInDh(Object days, Object hours);

  /// No description provided for @storeEndsInHm.
  ///
  /// In en, this message translates to:
  /// **'Ends in {hours}h {minutes}m'**
  String storeEndsInHm(Object hours, Object minutes);

  /// No description provided for @storeEndsInM.
  ///
  /// In en, this message translates to:
  /// **'Ends in {minutes}m'**
  String storeEndsInM(Object minutes);

  /// No description provided for @storeFeatureExtraLife.
  ///
  /// In en, this message translates to:
  /// **'Always-free extra life — revive every game, no ad, no coins'**
  String get storeFeatureExtraLife;

  /// No description provided for @storeFeatureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads — play completely ad-free'**
  String get storeFeatureNoAds;

  /// No description provided for @storeFeatureThemes.
  ///
  /// In en, this message translates to:
  /// **'All 6 premium themes'**
  String get storeFeatureThemes;

  /// No description provided for @storeFeatureSkins.
  ///
  /// In en, this message translates to:
  /// **'All 11 premium snake skins'**
  String get storeFeatureSkins;

  /// No description provided for @storeFeatureTrails.
  ///
  /// In en, this message translates to:
  /// **'All 11 premium trail effects'**
  String get storeFeatureTrails;

  /// No description provided for @storeFeatureBoards.
  ///
  /// In en, this message translates to:
  /// **'Premium board sizes (35×35, 40×40, 50×50)'**
  String get storeFeatureBoards;

  /// No description provided for @storeFeatureCoins.
  ///
  /// In en, this message translates to:
  /// **'2× coin earnings'**
  String get storeFeatureCoins;

  /// No description provided for @storeFeaturePowerUps.
  ///
  /// In en, this message translates to:
  /// **'5× premium power-ups every cycle'**
  String get storeFeaturePowerUps;

  /// No description provided for @storeFeatureTournaments.
  ///
  /// In en, this message translates to:
  /// **'Bronze + Silver + Gold tournament entries each cycle'**
  String get storeFeatureTournaments;

  /// No description provided for @storeFeatureBattlePass.
  ///
  /// In en, this message translates to:
  /// **'Battle Pass Premium track every season'**
  String get storeFeatureBattlePass;

  /// No description provided for @storeInitiatingPurchase.
  ///
  /// In en, this message translates to:
  /// **'Initiating {name} purchase...'**
  String storeInitiatingPurchase(Object name);

  /// No description provided for @storeSubNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Subscription not available. Please try again later.'**
  String get storeSubNotAvailable;

  /// No description provided for @storePurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get storePurchaseFailed;

  /// No description provided for @storeBuyCoins.
  ///
  /// In en, this message translates to:
  /// **'Buy Snake Coins'**
  String get storeBuyCoins;

  /// No description provided for @storeEarnFreeCoins.
  ///
  /// In en, this message translates to:
  /// **'Earn Free Coins'**
  String get storeEarnFreeCoins;

  /// No description provided for @storeEarnPlay.
  ///
  /// In en, this message translates to:
  /// **'Play a Game'**
  String get storeEarnPlay;

  /// No description provided for @storeEarnPlayReward.
  ///
  /// In en, this message translates to:
  /// **'5 coins per game'**
  String get storeEarnPlayReward;

  /// No description provided for @storeEarnDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Login'**
  String get storeEarnDaily;

  /// No description provided for @storeEarnDailyReward.
  ///
  /// In en, this message translates to:
  /// **'10-50 coins daily'**
  String get storeEarnDailyReward;

  /// No description provided for @storeEarnAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get storeEarnAchievements;

  /// No description provided for @storeEarnAchievementsReward.
  ///
  /// In en, this message translates to:
  /// **'25-100 coins'**
  String get storeEarnAchievementsReward;

  /// No description provided for @storeEarnTournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get storeEarnTournaments;

  /// No description provided for @storeEarnTournamentsReward.
  ///
  /// In en, this message translates to:
  /// **'100+ coins'**
  String get storeEarnTournamentsReward;

  /// No description provided for @storePopularBadge.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get storePopularBadge;

  /// No description provided for @storeBuyItem.
  ///
  /// In en, this message translates to:
  /// **'Buy {name}'**
  String storeBuyItem(Object name);

  /// No description provided for @storeBuyCoinsBody.
  ///
  /// In en, this message translates to:
  /// **'Purchase {coins} for {price}?'**
  String storeBuyCoinsBody(Object coins, Object price);

  /// No description provided for @storeBuyForPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy - {price}'**
  String storeBuyForPrice(Object price);

  /// No description provided for @storeInitiatingFor.
  ///
  /// In en, this message translates to:
  /// **'Initiating purchase for {name}...'**
  String storeInitiatingFor(Object name);

  /// No description provided for @storeProductNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Product not available. Please try again later.'**
  String get storeProductNotAvailable;

  /// No description provided for @storeUnlockedWithPro.
  ///
  /// In en, this message translates to:
  /// **'Unlocked with Pro'**
  String get storeUnlockedWithPro;

  /// No description provided for @storeIncludedWithPro.
  ///
  /// In en, this message translates to:
  /// **'Included with Snake Classic Pro'**
  String get storeIncludedWithPro;

  /// No description provided for @storeProBannerThemesOwned.
  ///
  /// In en, this message translates to:
  /// **'Every theme here is yours with your subscription.'**
  String get storeProBannerThemesOwned;

  /// No description provided for @storeProBannerThemesUpsell.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro to unlock every theme here — no separate purchase needed.'**
  String get storeProBannerThemesUpsell;

  /// No description provided for @storeProBannerSkinsOwned.
  ///
  /// In en, this message translates to:
  /// **'Every skin here is yours with your subscription.'**
  String get storeProBannerSkinsOwned;

  /// No description provided for @storeProBannerSkinsUpsell.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro to unlock every skin here — no separate purchase needed.'**
  String get storeProBannerSkinsUpsell;

  /// No description provided for @storeProBannerTrailsOwned.
  ///
  /// In en, this message translates to:
  /// **'Every trail here is yours with your subscription.'**
  String get storeProBannerTrailsOwned;

  /// No description provided for @storeProBannerTrailsUpsell.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro to unlock every trail here — no separate purchase needed.'**
  String get storeProBannerTrailsUpsell;

  /// No description provided for @storePremiumThemes.
  ///
  /// In en, this message translates to:
  /// **'Premium themes'**
  String get storePremiumThemes;

  /// No description provided for @storeFreeThemes.
  ///
  /// In en, this message translates to:
  /// **'Free themes'**
  String get storeFreeThemes;

  /// No description provided for @storeFreeThemesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always available — switch back any time.'**
  String get storeFreeThemesSubtitle;

  /// No description provided for @storeAllThemesBundle.
  ///
  /// In en, this message translates to:
  /// **'All Themes Bundle'**
  String get storeAllThemesBundle;

  /// No description provided for @storeAllThemesBundleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All 6 premium themes · save 33%'**
  String get storeAllThemesBundleSubtitle;

  /// No description provided for @storePillVerifying.
  ///
  /// In en, this message translates to:
  /// **'VERIFYING'**
  String get storePillVerifying;

  /// No description provided for @storePillOwned.
  ///
  /// In en, this message translates to:
  /// **'OWNED'**
  String get storePillOwned;

  /// No description provided for @storePillFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get storePillFree;

  /// No description provided for @storePillActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get storePillActive;

  /// No description provided for @storePillApply.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get storePillApply;

  /// No description provided for @storePillEquipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get storePillEquipped;

  /// No description provided for @storePillEquip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get storePillEquip;

  /// No description provided for @storeThemeDescClassic.
  ///
  /// In en, this message translates to:
  /// **'The original look'**
  String get storeThemeDescClassic;

  /// No description provided for @storeThemeDescModern.
  ///
  /// In en, this message translates to:
  /// **'Clean and minimal'**
  String get storeThemeDescModern;

  /// No description provided for @storeThemeDescNeon.
  ///
  /// In en, this message translates to:
  /// **'Glowing neon nights'**
  String get storeThemeDescNeon;

  /// No description provided for @storeThemeDescRetro.
  ///
  /// In en, this message translates to:
  /// **'80s neon arcade'**
  String get storeThemeDescRetro;

  /// No description provided for @storeThemeDescSpace.
  ///
  /// In en, this message translates to:
  /// **'Cosmic starfield'**
  String get storeThemeDescSpace;

  /// No description provided for @storeThemeDescOcean.
  ///
  /// In en, this message translates to:
  /// **'Deep-sea blues'**
  String get storeThemeDescOcean;

  /// No description provided for @storeThemeDescCyberpunk.
  ///
  /// In en, this message translates to:
  /// **'Electric cyan & pink'**
  String get storeThemeDescCyberpunk;

  /// No description provided for @storeThemeDescForest.
  ///
  /// In en, this message translates to:
  /// **'Vivid emerald jungle'**
  String get storeThemeDescForest;

  /// No description provided for @storeThemeDescDesert.
  ///
  /// In en, this message translates to:
  /// **'Canyon + cactus teal'**
  String get storeThemeDescDesert;

  /// No description provided for @storeThemeDescCrystal.
  ///
  /// In en, this message translates to:
  /// **'Icy crystalline blue'**
  String get storeThemeDescCrystal;

  /// No description provided for @storeUnlockFor.
  ///
  /// In en, this message translates to:
  /// **'Unlock {name} for {price}?'**
  String storeUnlockFor(Object name, Object price);

  /// No description provided for @storeVerifyingPurchase.
  ///
  /// In en, this message translates to:
  /// **'Verifying {name} purchase…'**
  String storeVerifyingPurchase(Object name);

  /// No description provided for @storeThemeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Theme not available. Please try again later.'**
  String get storeThemeNotAvailable;

  /// No description provided for @storeItemNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Item not available. Please try again later.'**
  String get storeItemNotAvailable;

  /// No description provided for @storeEquippedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} equipped'**
  String storeEquippedToast(Object name);

  /// No description provided for @storeFreeSpeedBoostInventory.
  ///
  /// In en, this message translates to:
  /// **'🎉 Free Speed Boost added to your inventory!'**
  String get storeFreeSpeedBoostInventory;

  /// No description provided for @storeWatchAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad — free Speed Boost'**
  String get storeWatchAdTitle;

  /// No description provided for @storeWatchAdReady.
  ///
  /// In en, this message translates to:
  /// **'Adds 1 Speed Boost to your loadout'**
  String get storeWatchAdReady;

  /// No description provided for @storeWatchAdNotReady.
  ///
  /// In en, this message translates to:
  /// **'No ad available right now'**
  String get storeWatchAdNotReady;

  /// No description provided for @puSpeedBoostDesc.
  ///
  /// In en, this message translates to:
  /// **'Increases snake speed for 7 seconds.'**
  String get puSpeedBoostDesc;

  /// No description provided for @puInvincibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Pass through walls and yourself for 6 seconds.'**
  String get puInvincibilityDesc;

  /// No description provided for @puScoreMultiplierDesc.
  ///
  /// In en, this message translates to:
  /// **'Double points for 10 seconds.'**
  String get puScoreMultiplierDesc;

  /// No description provided for @puSlowMotionDesc.
  ///
  /// In en, this message translates to:
  /// **'Slows the game for precision (8 seconds).'**
  String get puSlowMotionDesc;

  /// No description provided for @storePowerUpsInfo.
  ///
  /// In en, this message translates to:
  /// **'Buy with coins, then arm one from the home screen loadout chip — it activates 5s into your next game.'**
  String get storePowerUpsInfo;

  /// No description provided for @storePowerUps.
  ///
  /// In en, this message translates to:
  /// **'Power-Ups'**
  String get storePowerUps;

  /// No description provided for @storePowerUpBundles.
  ///
  /// In en, this message translates to:
  /// **'Power-Up Bundles'**
  String get storePowerUpBundles;

  /// No description provided for @storeBundlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock multiple power-up types at a discount.'**
  String get storeBundlesSubtitle;

  /// No description provided for @storeOwnedCountBadge.
  ///
  /// In en, this message translates to:
  /// **'x{count}'**
  String storeOwnedCountBadge(Object count);

  /// No description provided for @storeInsufficientCoins.
  ///
  /// In en, this message translates to:
  /// **'Insufficient coins!'**
  String get storeInsufficientCoins;

  /// No description provided for @storeBuyPowerUpBody.
  ///
  /// In en, this message translates to:
  /// **'Buy 1 {name} for {cost} coins?'**
  String storeBuyPowerUpBody(Object cost, Object name);

  /// No description provided for @storeBuyCostCoins.
  ///
  /// In en, this message translates to:
  /// **'Buy - {cost} coins'**
  String storeBuyCostCoins(Object cost);

  /// No description provided for @storePurchaseFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Try again.'**
  String get storePurchaseFailedRetry;

  /// No description provided for @storeAddedToLoadout.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your loadout!'**
  String storeAddedToLoadout(Object name);

  /// No description provided for @storeCoinsAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String storeCoinsAmount(Object count);

  /// No description provided for @storeBuyUpper.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get storeBuyUpper;

  /// No description provided for @storeNeedCoins.
  ///
  /// In en, this message translates to:
  /// **'NEED COINS'**
  String get storeNeedCoins;

  /// No description provided for @storeBundleUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} unlocked!'**
  String storeBundleUnlocked(Object name);

  /// No description provided for @modeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassic;

  /// No description provided for @modeZen.
  ///
  /// In en, this message translates to:
  /// **'Zen Mode'**
  String get modeZen;

  /// No description provided for @modeSpeedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Speed Challenge'**
  String get modeSpeedChallenge;

  /// No description provided for @modeMultiFood.
  ///
  /// In en, this message translates to:
  /// **'Multi-Food'**
  String get modeMultiFood;

  /// No description provided for @modeSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get modeSurvival;

  /// No description provided for @modeTimeAttack.
  ///
  /// In en, this message translates to:
  /// **'Time Attack'**
  String get modeTimeAttack;

  /// No description provided for @modePowerUpMadness.
  ///
  /// In en, this message translates to:
  /// **'Power-Up Madness'**
  String get modePowerUpMadness;

  /// No description provided for @modePerfectGame.
  ///
  /// In en, this message translates to:
  /// **'Perfect Game'**
  String get modePerfectGame;

  /// No description provided for @modeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The classic Snake game with walls'**
  String get modeClassicDesc;

  /// No description provided for @modeZenDesc.
  ///
  /// In en, this message translates to:
  /// **'No walls - snake wraps around the screen'**
  String get modeZenDesc;

  /// No description provided for @modeSpeedChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Speed increases rapidly for maximum challenge'**
  String get modeSpeedChallengeDesc;

  /// No description provided for @modeMultiFoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Multiple food items appear at once'**
  String get modeMultiFoodDesc;

  /// No description provided for @modeSurvivalDesc.
  ///
  /// In en, this message translates to:
  /// **'Survive as long as possible with limited lives'**
  String get modeSurvivalDesc;

  /// No description provided for @modeTimeAttackDesc.
  ///
  /// In en, this message translates to:
  /// **'Score as much as possible in limited time'**
  String get modeTimeAttackDesc;

  /// No description provided for @modePowerUpMadnessDesc.
  ///
  /// In en, this message translates to:
  /// **'Power-ups spawn far more often — embrace the chaos'**
  String get modePowerUpMadnessDesc;

  /// No description provided for @modePerfectGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Never cross your own trail. One step on a visited cell ends the run.'**
  String get modePerfectGameDesc;

  /// No description provided for @diffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get diffEasy;

  /// No description provided for @diffNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get diffNormal;

  /// No description provided for @diffHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diffHard;

  /// No description provided for @diffEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'A slower snake to start. Scores stay off the leaderboards.'**
  String get diffEasyDesc;

  /// No description provided for @diffNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'The original Snake Classic pace.'**
  String get diffNormalDesc;

  /// No description provided for @diffHardDesc.
  ///
  /// In en, this message translates to:
  /// **'Starts fast and only gets faster.'**
  String get diffHardDesc;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeClassic;

  /// No description provided for @themeModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get themeModern;

  /// No description provided for @themeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get themeNeon;

  /// No description provided for @themeRetro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get themeRetro;

  /// No description provided for @themeSpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get themeSpace;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeCyberpunk.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk'**
  String get themeCyberpunk;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themeDesert.
  ///
  /// In en, this message translates to:
  /// **'Desert'**
  String get themeDesert;

  /// No description provided for @themeCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal'**
  String get themeCrystal;

  /// No description provided for @dpadLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get dpadLeft;

  /// No description provided for @dpadCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get dpadCenter;

  /// No description provided for @dpadRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get dpadRight;

  /// No description provided for @mpModeClassicBattle.
  ///
  /// In en, this message translates to:
  /// **'Classic Battle'**
  String get mpModeClassicBattle;

  /// No description provided for @mpModeSpeedRun.
  ///
  /// In en, this message translates to:
  /// **'Speed Run'**
  String get mpModeSpeedRun;

  /// No description provided for @mpModeSurvivalMode.
  ///
  /// In en, this message translates to:
  /// **'Survival Mode'**
  String get mpModeSurvivalMode;

  /// No description provided for @mpModePowerUpMadnessName.
  ///
  /// In en, this message translates to:
  /// **'Power-up Madness'**
  String get mpModePowerUpMadnessName;
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
