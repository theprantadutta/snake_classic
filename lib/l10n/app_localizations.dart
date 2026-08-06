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

  /// Auto-renewable subscription disclosure shown on the purchase surfaces when running on iOS/macOS. Required by Apple guideline 3.1.2(c). Keep the 24-hour cancellation window and the 'same price and duration' wording — they are the legally load-bearing parts. 'App Store' is a brand name: do not translate it. See the GooglePlay variant for the Android copy; the two must stay in sync apart from the store name and where the user manages the subscription.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your App Store account at confirmation of purchase. The subscription automatically renews for the same price and duration unless it is cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your account settings after purchase.'**
  String get legalAutoRenewDisclosureAppStore;

  /// Android counterpart of legalAutoRenewDisclosureAppStore, shown when running on Android. Same legal content; differs only in the store name and the fact that subscriptions are managed in Google Play rather than the account settings. 'Google Play' is a brand name: do not translate it.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your Google Play account at confirmation of purchase. The subscription automatically renews for the same price and duration unless it is cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your Google Play subscription settings after purchase.'**
  String get legalAutoRenewDisclosureGooglePlay;

  /// Label for the Terms of Use link in the subscription legal footer. Distinct from settingsTermsTitle because Apple expects the EULA to be identified as such on the purchase surface. Leave '(EULA)' untranslated.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get legalTermsEulaLink;

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

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @pfTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pfTitle;

  /// No description provided for @pfSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get pfSigningOut;

  /// No description provided for @pfGuestPlayer.
  ///
  /// In en, this message translates to:
  /// **'Guest Player'**
  String get pfGuestPlayer;

  /// No description provided for @pfVerifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get pfVerifiedAccount;

  /// No description provided for @pfStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get pfStatistics;

  /// No description provided for @pfReplays.
  ///
  /// In en, this message translates to:
  /// **'Replays'**
  String get pfReplays;

  /// No description provided for @pfAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get pfAchievements;

  /// No description provided for @pfLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading stats...'**
  String get pfLoadingStats;

  /// No description provided for @pfHighScore.
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get pfHighScore;

  /// No description provided for @pfGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get pfGamesPlayed;

  /// No description provided for @pfPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Play Time'**
  String get pfPlayTime;

  /// No description provided for @pfAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get pfAverageScore;

  /// No description provided for @pfFoodConsumed.
  ///
  /// In en, this message translates to:
  /// **'Food Consumed'**
  String get pfFoodConsumed;

  /// No description provided for @pfPowerUps.
  ///
  /// In en, this message translates to:
  /// **'Power-ups'**
  String get pfPowerUps;

  /// No description provided for @pfUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Google Account'**
  String get pfUpgradeTitle;

  /// No description provided for @pfUpgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress and sync across devices'**
  String get pfUpgradeSubtitle;

  /// No description provided for @pfBenefitSync.
  ///
  /// In en, this message translates to:
  /// **'Sync Progress'**
  String get pfBenefitSync;

  /// No description provided for @pfBenefitSyncSub.
  ///
  /// In en, this message translates to:
  /// **'across devices'**
  String get pfBenefitSyncSub;

  /// No description provided for @pfBenefitLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Global Leaderboards'**
  String get pfBenefitLeaderboards;

  /// No description provided for @pfBenefitLeaderboardsSub.
  ///
  /// In en, this message translates to:
  /// **'compete worldwide'**
  String get pfBenefitLeaderboardsSub;

  /// No description provided for @pfBenefitSocial.
  ///
  /// In en, this message translates to:
  /// **'Friends & Social'**
  String get pfBenefitSocial;

  /// No description provided for @pfBenefitSocialSub.
  ///
  /// In en, this message translates to:
  /// **'connect with others'**
  String get pfBenefitSocialSub;

  /// No description provided for @pfSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get pfSignInGoogle;

  /// No description provided for @pfSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get pfSignInApple;

  /// No description provided for @pfNoReplays.
  ///
  /// In en, this message translates to:
  /// **'No replays yet. Play some games!'**
  String get pfNoReplays;

  /// No description provided for @pfReplaysSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} replay saved} other{{count} replays saved}}'**
  String pfReplaysSaved(num count);

  /// No description provided for @pfAccountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get pfAccountManagement;

  /// No description provided for @pfSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get pfSignOut;

  /// No description provided for @pfDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get pfDeleteAccount;

  /// No description provided for @pfAppleUpgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully upgraded to Apple account! 🎉'**
  String get pfAppleUpgradeSuccess;

  /// No description provided for @pfAppleIdInUse.
  ///
  /// In en, this message translates to:
  /// **'That Apple ID already has an account. Sign out, then sign in with Apple instead.'**
  String get pfAppleIdInUse;

  /// No description provided for @pfUpgradeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upgrade account. Please try again.'**
  String get pfUpgradeFailed;

  /// No description provided for @pfUpgradeError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during account upgrade.'**
  String get pfUpgradeError;

  /// No description provided for @pfGoogleUpgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully upgraded to Google account! 🎉'**
  String get pfGoogleUpgradeSuccess;

  /// No description provided for @pfDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get pfDeleteAccountTitle;

  /// No description provided for @pfDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and everything attached to it:\n\n• High scores and statistics\n• Coins and purchased items\n• Themes, skins, trails and power-ups\n• Battle pass and challenge progress\n• Leaderboard entries and friends\n\nThis cannot be undone. Active subscriptions must be cancelled separately in your {storeName} settings.'**
  String pfDeleteAccountBody(Object storeName);

  /// No description provided for @pfAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get pfAppStore;

  /// No description provided for @pfDeviceAppStore.
  ///
  /// In en, this message translates to:
  /// **'device\'s app store'**
  String get pfDeviceAppStore;

  /// No description provided for @pfAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been permanently deleted.'**
  String get pfAccountDeleted;

  /// No description provided for @pfDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Check your connection and try again.'**
  String get pfDeleteFailed;

  /// No description provided for @pfDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get pfDeleteForever;

  /// No description provided for @pfSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?\n\nYour progress will be saved if you\'re signed in with Google.'**
  String get pfSignOutBody;

  /// No description provided for @pfSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully 👋'**
  String get pfSignedOut;

  /// No description provided for @stLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Statistics...'**
  String get stLoading;

  /// No description provided for @stPerformanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get stPerformanceOverview;

  /// No description provided for @stTotalGames.
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get stTotalGames;

  /// No description provided for @stWinStreak.
  ///
  /// In en, this message translates to:
  /// **'Win Streak'**
  String get stWinStreak;

  /// No description provided for @stGameActivity.
  ///
  /// In en, this message translates to:
  /// **'Game Activity'**
  String get stGameActivity;

  /// No description provided for @stLongestGame.
  ///
  /// In en, this message translates to:
  /// **'Longest Game'**
  String get stLongestGame;

  /// No description provided for @stHighestLevel.
  ///
  /// In en, this message translates to:
  /// **'Highest Level'**
  String get stHighestLevel;

  /// No description provided for @stPerfectGames.
  ///
  /// In en, this message translates to:
  /// **'Perfect Games'**
  String get stPerfectGames;

  /// No description provided for @stFoodPowerUps.
  ///
  /// In en, this message translates to:
  /// **'Food & Power-ups'**
  String get stFoodPowerUps;

  /// No description provided for @stPowerUpsUsed.
  ///
  /// In en, this message translates to:
  /// **'Power-ups Used'**
  String get stPowerUpsUsed;

  /// No description provided for @stFavoriteFood.
  ///
  /// In en, this message translates to:
  /// **'Favorite Food'**
  String get stFavoriteFood;

  /// No description provided for @stFavoritePowerUp.
  ///
  /// In en, this message translates to:
  /// **'Favorite Power-up'**
  String get stFavoritePowerUp;

  /// No description provided for @stPerformanceTrends.
  ///
  /// In en, this message translates to:
  /// **'Performance Trends'**
  String get stPerformanceTrends;

  /// No description provided for @stOverallTrend.
  ///
  /// In en, this message translates to:
  /// **'Overall Trend'**
  String get stOverallTrend;

  /// No description provided for @stRecentAverage.
  ///
  /// In en, this message translates to:
  /// **'Recent Average'**
  String get stRecentAverage;

  /// No description provided for @stBestRecent.
  ///
  /// In en, this message translates to:
  /// **'Best Recent'**
  String get stBestRecent;

  /// No description provided for @stConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get stConsistency;

  /// No description provided for @stScores.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get stScores;

  /// No description provided for @stTrendLine.
  ///
  /// In en, this message translates to:
  /// **'Trend Line'**
  String get stTrendLine;

  /// No description provided for @stPlayPatterns.
  ///
  /// In en, this message translates to:
  /// **'Play Patterns (Last 7 Days)'**
  String get stPlayPatterns;

  /// No description provided for @stWeeklyTime.
  ///
  /// In en, this message translates to:
  /// **'Weekly Time'**
  String get stWeeklyTime;

  /// No description provided for @stMostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most Active Day'**
  String get stMostActiveDay;

  /// No description provided for @stDailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity'**
  String get stDailyActivity;

  /// No description provided for @stAchievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Achievement Progress'**
  String get stAchievementProgress;

  /// No description provided for @stViewAllAchievements.
  ///
  /// In en, this message translates to:
  /// **'View All Achievements →'**
  String get stViewAllAchievements;

  /// No description provided for @stViewAchievements.
  ///
  /// In en, this message translates to:
  /// **'VIEW ACHIEVEMENTS'**
  String get stViewAchievements;

  /// No description provided for @stReplaysUpper.
  ///
  /// In en, this message translates to:
  /// **'REPLAYS'**
  String get stReplaysUpper;

  /// No description provided for @stResetStatistics.
  ///
  /// In en, this message translates to:
  /// **'RESET STATISTICS'**
  String get stResetStatistics;

  /// No description provided for @stResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Statistics?'**
  String get stResetTitle;

  /// No description provided for @stResetBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your game statistics. This action cannot be undone.'**
  String get stResetBody;

  /// No description provided for @stReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get stReset;

  /// No description provided for @stNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get stNA;

  /// No description provided for @stExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get stExcellent;

  /// No description provided for @stGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get stGood;

  /// No description provided for @stFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get stFair;

  /// No description provided for @stPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get stPoor;

  /// No description provided for @stNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get stNoData;

  /// No description provided for @stNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get stNone;

  /// No description provided for @stProgressLastGames.
  ///
  /// In en, this message translates to:
  /// **'Progress (Last {count, plural, one{{count} Game} other{{count} Games}})'**
  String stProgressLastGames(num count);

  /// No description provided for @stPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent} Complete'**
  String stPercentComplete(Object percent);

  /// No description provided for @stInsights.
  ///
  /// In en, this message translates to:
  /// **'Performance Insights'**
  String get stInsights;

  /// No description provided for @stInsightPlayMore.
  ///
  /// In en, this message translates to:
  /// **'Play more games to get performance insights!'**
  String get stInsightPlayMore;

  /// No description provided for @stInsightImproving.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your performance is on an upward trend.'**
  String get stInsightImproving;

  /// No description provided for @stInsightAboveAverage.
  ///
  /// In en, this message translates to:
  /// **'Your recent games are significantly above your average.'**
  String get stInsightAboveAverage;

  /// No description provided for @stInsightDeclined.
  ///
  /// In en, this message translates to:
  /// **'Your performance has declined recently. Consider practicing more.'**
  String get stInsightDeclined;

  /// No description provided for @stInsightPractice.
  ///
  /// In en, this message translates to:
  /// **'Try focusing on avoiding collisions and planning your moves ahead.'**
  String get stInsightPractice;

  /// No description provided for @stInsightStable.
  ///
  /// In en, this message translates to:
  /// **'Your performance is stable. Challenge yourself to improve!'**
  String get stInsightStable;

  /// No description provided for @stInsightPotential.
  ///
  /// In en, this message translates to:
  /// **'You have potential for high scores - work on consistency.'**
  String get stInsightPotential;

  /// No description provided for @stInsightSolid.
  ///
  /// In en, this message translates to:
  /// **'You\'re maintaining solid performance across recent games.'**
  String get stInsightSolid;

  /// No description provided for @frTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get frTitle;

  /// No description provided for @frBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get frBlockedUsers;

  /// No description provided for @frSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get frSearchHint;

  /// No description provided for @frSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get frSearching;

  /// No description provided for @frSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for Friends'**
  String get frSearchTitle;

  /// No description provided for @frSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or email to find friends'**
  String get frSearchSubtitle;

  /// No description provided for @frNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No Users Found'**
  String get frNoUsersFound;

  /// No description provided for @frNoUsersFoundSub.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or email'**
  String get frNoUsersFoundSub;

  /// No description provided for @frRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get frRequests;

  /// No description provided for @frSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get frSearch;

  /// No description provided for @frNoCacheYet.
  ///
  /// In en, this message translates to:
  /// **'No cache yet'**
  String get frNoCacheYet;

  /// No description provided for @frUpdatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {ago}'**
  String frUpdatedAgo(Object ago);

  /// No description provided for @frRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'{base} · refresh failed, tap to retry'**
  String frRefreshFailed(Object base);

  /// No description provided for @frJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get frJustNow;

  /// No description provided for @frSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}s ago'**
  String frSecondsAgo(Object count);

  /// No description provided for @frMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String frMinutesAgo(Object count);

  /// No description provided for @frHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String frHoursAgo(Object count);

  /// No description provided for @frDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String frDaysAgo(Object count);

  /// No description provided for @frLoadingFriends.
  ///
  /// In en, this message translates to:
  /// **'Loading friends...'**
  String get frLoadingFriends;

  /// No description provided for @frNoFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No Friends Yet'**
  String get frNoFriendsYet;

  /// No description provided for @frNoFriendsSub.
  ///
  /// In en, this message translates to:
  /// **'Search for users to add as friends!'**
  String get frNoFriendsSub;

  /// No description provided for @frNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No Friend Requests'**
  String get frNoRequests;

  /// No description provided for @frNoRequestsSub.
  ///
  /// In en, this message translates to:
  /// **'Friend requests will appear here'**
  String get frNoRequestsSub;

  /// No description provided for @frChallengeMenu.
  ///
  /// In en, this message translates to:
  /// **'Challenge to a Match'**
  String get frChallengeMenu;

  /// No description provided for @frViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get frViewProfile;

  /// No description provided for @frRemoveFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get frRemoveFriend;

  /// No description provided for @frBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get frBlockUser;

  /// No description provided for @frReceivedHeader.
  ///
  /// In en, this message translates to:
  /// **'Received ({count})'**
  String frReceivedHeader(Object count);

  /// No description provided for @frSentHeader.
  ///
  /// In en, this message translates to:
  /// **'Sent ({count})'**
  String frSentHeader(Object count);

  /// No description provided for @frGamesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} game} other{{count} games}}'**
  String frGamesCount(num count);

  /// No description provided for @frSentDate.
  ///
  /// In en, this message translates to:
  /// **'Sent {date}'**
  String frSentDate(Object date);

  /// No description provided for @frPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get frPending;

  /// No description provided for @frCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get frCancelRequest;

  /// No description provided for @frReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get frReject;

  /// No description provided for @frAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get frAccept;

  /// No description provided for @frAlreadyFriends.
  ///
  /// In en, this message translates to:
  /// **'✓ Friends'**
  String get frAlreadyFriends;

  /// No description provided for @frAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get frAddFriend;

  /// No description provided for @frSendRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the friend request — check your connection and try again'**
  String get frSendRequestFailed;

  /// No description provided for @frAcceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not accept the request — check your connection and try again'**
  String get frAcceptFailed;

  /// No description provided for @frRejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the request — check your connection and try again'**
  String get frRejectFailed;

  /// No description provided for @frCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel the request — check your connection and try again'**
  String get frCancelFailed;

  /// No description provided for @frBlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not block this user — check your connection and try again'**
  String get frBlockFailed;

  /// No description provided for @frSignInSocial.
  ///
  /// In en, this message translates to:
  /// **'Sign in to add friends and use social features'**
  String get frSignInSocial;

  /// No description provided for @frRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent!'**
  String get frRequestSent;

  /// No description provided for @frRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted!'**
  String get frRequestAccepted;

  /// No description provided for @frRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected'**
  String get frRequestRejected;

  /// No description provided for @frRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Friend request cancelled'**
  String get frRequestCancelled;

  /// No description provided for @frChallengeSent.
  ///
  /// In en, this message translates to:
  /// **'🎮 Challenge sent to {name}!'**
  String frChallengeSent(Object name);

  /// No description provided for @frChallengeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the challenge — try again'**
  String get frChallengeFailed;

  /// No description provided for @frBlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} blocked'**
  String frBlocked(Object name);

  /// No description provided for @frUnblocked.
  ///
  /// In en, this message translates to:
  /// **'{name} unblocked'**
  String frUnblocked(Object name);

  /// No description provided for @frUnblockFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not unblock — try again'**
  String get frUnblockFailed;

  /// No description provided for @frRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from friends'**
  String frRemoved(Object name);

  /// No description provided for @frBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String frBlockTitle(Object name);

  /// No description provided for @frBlockBody.
  ///
  /// In en, this message translates to:
  /// **'They will be removed from your friends and unable to send you friend requests or match challenges. They will not be notified.'**
  String get frBlockBody;

  /// No description provided for @frBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get frBlock;

  /// No description provided for @frNoBlocked.
  ///
  /// In en, this message translates to:
  /// **'You have not blocked anyone.'**
  String get frNoBlocked;

  /// No description provided for @frUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get frUnblock;

  /// No description provided for @frHighScoreLine.
  ///
  /// In en, this message translates to:
  /// **'High Score: {score}'**
  String frHighScoreLine(Object score);

  /// No description provided for @frTotalGamesLine.
  ///
  /// In en, this message translates to:
  /// **'Total Games: {count}'**
  String frTotalGamesLine(Object count);

  /// No description provided for @frLevelLine.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String frLevelLine(Object level);

  /// No description provided for @frStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Status: \"{status}\"'**
  String frStatusLine(Object status);

  /// No description provided for @frRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from your friends list?'**
  String frRemoveBody(Object name);

  /// No description provided for @frRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get frRemove;

  /// No description provided for @frLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends Leaderboard'**
  String get frLeaderboardTitle;

  /// No description provided for @frLeaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete with your friends'**
  String get frLeaderboardSubtitle;

  /// No description provided for @frLoadingLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Loading leaderboard...'**
  String get frLoadingLeaderboard;

  /// No description provided for @frRankBadge.
  ///
  /// In en, this message translates to:
  /// **'#{rank}'**
  String frRankBadge(Object rank);

  /// No description provided for @frYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get frYou;

  /// No description provided for @frLeaderboardEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Add friends to see your private leaderboard!'**
  String get frLeaderboardEmptySub;

  /// No description provided for @frAddFriends.
  ///
  /// In en, this message translates to:
  /// **'Add Friends'**
  String get frAddFriends;

  /// No description provided for @tnTitle.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tnTitle;

  /// No description provided for @tnActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tnActive;

  /// No description provided for @tnHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tnHistory;

  /// No description provided for @tnMyStats.
  ///
  /// In en, this message translates to:
  /// **'My Stats'**
  String get tnMyStats;

  /// No description provided for @tnLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading tournaments...'**
  String get tnLoading;

  /// No description provided for @tnNoActive.
  ///
  /// In en, this message translates to:
  /// **'No Active Tournaments'**
  String get tnNoActive;

  /// No description provided for @tnNoActiveSub.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new tournaments!'**
  String get tnNoActiveSub;

  /// No description provided for @tnNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No Tournament History'**
  String get tnNoHistory;

  /// No description provided for @tnNoHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Participate in tournaments to see your history!'**
  String get tnNoHistorySub;

  /// No description provided for @tnNoStats.
  ///
  /// In en, this message translates to:
  /// **'No Tournament Stats'**
  String get tnNoStats;

  /// No description provided for @tnNoStatsSub.
  ///
  /// In en, this message translates to:
  /// **'Join tournaments to track your progress!'**
  String get tnNoStatsSub;

  /// No description provided for @tnPlayersCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} players'**
  String tnPlayersCount(Object current, Object max);

  /// No description provided for @tnJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get tnJoined;

  /// No description provided for @tnBestScoreChip.
  ///
  /// In en, this message translates to:
  /// **'Best: {score}'**
  String tnBestScoreChip(Object score);

  /// No description provided for @tnRankReward.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank} - {reward}'**
  String tnRankReward(Object rank, Object reward);

  /// No description provided for @tnRewardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} reward available} other{{count} rewards available}}'**
  String tnRewardsAvailable(num count);

  /// No description provided for @tnViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details →'**
  String get tnViewDetails;

  /// No description provided for @tnOverviewCard.
  ///
  /// In en, this message translates to:
  /// **'Tournament Overview'**
  String get tnOverviewCard;

  /// No description provided for @tnWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get tnWins;

  /// No description provided for @tnTopThree.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Finishes'**
  String get tnTopThree;

  /// No description provided for @tnBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get tnBestScore;

  /// No description provided for @tnDetailedStats.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get tnDetailedStats;

  /// No description provided for @tnTotalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total Attempts'**
  String get tnTotalAttempts;

  /// No description provided for @tnWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get tnWinRate;

  /// No description provided for @tnPercentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String tnPercentValue(Object value);

  /// No description provided for @tnAvgPerformance.
  ///
  /// In en, this message translates to:
  /// **'Average Performance'**
  String get tnAvgPerformance;

  /// No description provided for @tnTopPercent.
  ///
  /// In en, this message translates to:
  /// **'Top {percent}%'**
  String tnTopPercent(Object percent);

  /// No description provided for @tnNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tournament not found'**
  String get tnNotFound;

  /// No description provided for @tnLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tournament'**
  String get tnLoadFailed;

  /// No description provided for @tnLoadingTournament.
  ///
  /// In en, this message translates to:
  /// **'Loading tournament...'**
  String get tnLoadingTournament;

  /// No description provided for @tnGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get tnGoBack;

  /// No description provided for @tnParticipating.
  ///
  /// In en, this message translates to:
  /// **'You\'re participating!'**
  String get tnParticipating;

  /// No description provided for @tnBestAttempts.
  ///
  /// In en, this message translates to:
  /// **'Best Score: {score} • Attempts: {count}'**
  String tnBestAttempts(Object count, Object score);

  /// No description provided for @tnRankChip.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank}'**
  String tnRankChip(Object rank);

  /// No description provided for @tnOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tnOverview;

  /// No description provided for @tnLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get tnLeaderboard;

  /// No description provided for @tnRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get tnRules;

  /// No description provided for @tnLeaderboardFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the leaderboard'**
  String get tnLeaderboardFailed;

  /// No description provided for @tnCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get tnCheckConnection;

  /// No description provided for @tnNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants yet'**
  String get tnNoParticipants;

  /// No description provided for @tnBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to join!'**
  String get tnBeFirst;

  /// No description provided for @tnDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get tnDescription;

  /// No description provided for @tnRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get tnRewards;

  /// No description provided for @tnAttemptsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} attempt} other{{count} attempts}}'**
  String tnAttemptsCount(num count);

  /// No description provided for @tnRulesHeader.
  ///
  /// In en, this message translates to:
  /// **'Tournament Rules'**
  String get tnRulesHeader;

  /// No description provided for @tnScoringSystem.
  ///
  /// In en, this message translates to:
  /// **'Scoring System'**
  String get tnScoringSystem;

  /// No description provided for @tnScoringBody.
  ///
  /// In en, this message translates to:
  /// **'Your highest score during the tournament period will count towards the final ranking. You can play multiple times to improve your score.'**
  String get tnScoringBody;

  /// No description provided for @tnJoining.
  ///
  /// In en, this message translates to:
  /// **'JOINING…'**
  String get tnJoining;

  /// No description provided for @tnJoin.
  ///
  /// In en, this message translates to:
  /// **'JOIN TOURNAMENT'**
  String get tnJoin;

  /// No description provided for @tnPlayNow.
  ///
  /// In en, this message translates to:
  /// **'PLAY NOW'**
  String get tnPlayNow;

  /// No description provided for @tnProUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Pro · Unlimited entries'**
  String get tnProUnlimited;

  /// No description provided for @tnEntriesRemaining.
  ///
  /// In en, this message translates to:
  /// **'Entries remaining: {count}'**
  String tnEntriesRemaining(Object count);

  /// No description provided for @tnNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries — tap JOIN to buy'**
  String get tnNoEntries;

  /// No description provided for @tnStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts {time}'**
  String tnStarts(Object time);

  /// No description provided for @tnRule1.
  ///
  /// In en, this message translates to:
  /// **'Play during the tournament period to have your scores counted'**
  String get tnRule1;

  /// No description provided for @tnRule2.
  ///
  /// In en, this message translates to:
  /// **'You can play multiple times - only your highest score counts'**
  String get tnRule2;

  /// No description provided for @tnRule3.
  ///
  /// In en, this message translates to:
  /// **'Must be signed in to participate'**
  String get tnRule3;

  /// No description provided for @tnRule4.
  ///
  /// In en, this message translates to:
  /// **'Final rankings are determined at tournament end'**
  String get tnRule4;

  /// No description provided for @tnRuleSpeed.
  ///
  /// In en, this message translates to:
  /// **'Game speed increases rapidly every 10 points'**
  String get tnRuleSpeed;

  /// No description provided for @tnRuleSurvival.
  ///
  /// In en, this message translates to:
  /// **'Score is based on survival time, not food consumed'**
  String get tnRuleSurvival;

  /// No description provided for @tnRuleNoWalls.
  ///
  /// In en, this message translates to:
  /// **'Snake wraps around screen edges instead of hitting walls'**
  String get tnRuleNoWalls;

  /// No description provided for @tnRulePowerUps.
  ///
  /// In en, this message translates to:
  /// **'Power-ups spawn every 5 seconds'**
  String get tnRulePowerUps;

  /// No description provided for @tnRulePerfect.
  ///
  /// In en, this message translates to:
  /// **'Any collision immediately ends the game'**
  String get tnRulePerfect;

  /// No description provided for @tnRuleClassic.
  ///
  /// In en, this message translates to:
  /// **'Standard Snake rules apply'**
  String get tnRuleClassic;

  /// No description provided for @tnJoinSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined tournament!'**
  String get tnJoinSuccess;

  /// No description provided for @tnJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join tournament'**
  String get tnJoinFailed;

  /// No description provided for @tnJoinError.
  ///
  /// In en, this message translates to:
  /// **'Error joining tournament'**
  String get tnJoinError;

  /// No description provided for @tnTierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get tnTierBronze;

  /// No description provided for @tnTierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tnTierSilver;

  /// No description provided for @tnTierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tnTierGold;

  /// No description provided for @tnEntryRequired.
  ///
  /// In en, this message translates to:
  /// **'Entry Required'**
  String get tnEntryRequired;

  /// No description provided for @tnEntryNeeded.
  ///
  /// In en, this message translates to:
  /// **'You need a {tier} tournament entry to join this tournament.'**
  String tnEntryNeeded(Object tier);

  /// No description provided for @tnCurrentEntries.
  ///
  /// In en, this message translates to:
  /// **'Current {tier} entries: {count}'**
  String tnCurrentEntries(Object count, Object tier);

  /// No description provided for @tnProUnlimitedNote.
  ///
  /// In en, this message translates to:
  /// **'Pro subscribers get unlimited tournament access.'**
  String get tnProUnlimitedNote;

  /// No description provided for @tnFreeBronzeAdded.
  ///
  /// In en, this message translates to:
  /// **'🎉 Free Bronze tournament entry added!'**
  String get tnFreeBronzeAdded;

  /// No description provided for @tnFreeEntryAd.
  ///
  /// In en, this message translates to:
  /// **'Free entry (ad)'**
  String get tnFreeEntryAd;

  /// No description provided for @tnBuyEntry.
  ///
  /// In en, this message translates to:
  /// **'Buy {tier} Entry - {price}'**
  String tnBuyEntry(Object price, Object tier);

  /// No description provided for @acAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get acAll;

  /// No description provided for @acUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get acUnlocked;

  /// No description provided for @acLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get acLocked;

  /// No description provided for @acTotalUpper.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get acTotalUpper;

  /// No description provided for @acUnlockedUpper.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKED'**
  String get acUnlockedUpper;

  /// No description provided for @acClaimedUpper.
  ///
  /// In en, this message translates to:
  /// **'CLAIMED'**
  String get acClaimedUpper;

  /// No description provided for @acPendingUpper.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get acPendingUpper;

  /// No description provided for @acPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String acPercentComplete(Object percent);

  /// No description provided for @acPercentOfUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of unlocked'**
  String acPercentOfUnlocked(Object percent);

  /// No description provided for @acEmpty.
  ///
  /// In en, this message translates to:
  /// **'No achievements here'**
  String get acEmpty;

  /// No description provided for @acXpReward.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String acXpReward(Object xp);

  /// No description provided for @acUnlockedDate.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String acUnlockedDate(Object date);

  /// No description provided for @rpTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Replays'**
  String get rpTitle;

  /// No description provided for @rpRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get rpRecent;

  /// No description provided for @rpBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get rpBest;

  /// No description provided for @rpCrashes.
  ///
  /// In en, this message translates to:
  /// **'Crashes'**
  String get rpCrashes;

  /// No description provided for @rpLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading replays...'**
  String get rpLoading;

  /// No description provided for @rpNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No recent replays'**
  String get rpNoRecent;

  /// No description provided for @rpNoBest.
  ///
  /// In en, this message translates to:
  /// **'No high-score replays'**
  String get rpNoBest;

  /// No description provided for @rpNoCrashes.
  ///
  /// In en, this message translates to:
  /// **'No crash replays'**
  String get rpNoCrashes;

  /// No description provided for @rpEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Play some games to generate replays!'**
  String get rpEmptySub;

  /// No description provided for @rpScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get rpScore;

  /// No description provided for @rpDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get rpDuration;

  /// No description provided for @rpFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get rpFood;

  /// No description provided for @rpFrames.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get rpFrames;

  /// No description provided for @rpMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Max Length'**
  String get rpMaxLength;

  /// No description provided for @rpWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get rpWatch;

  /// No description provided for @rpYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rpYesterday;

  /// No description provided for @rpDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Replay'**
  String get rpDeleteTitle;

  /// No description provided for @rpDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete replay from {date}?'**
  String rpDeleteBody(Object date);

  /// No description provided for @rpDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get rpDelete;

  /// No description provided for @rpDeleted.
  ///
  /// In en, this message translates to:
  /// **'Replay deleted'**
  String get rpDeleted;

  /// No description provided for @rpDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete replay'**
  String get rpDeleteFailed;

  /// No description provided for @lbTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get lbTitle;

  /// No description provided for @lbGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get lbGlobal;

  /// No description provided for @lbWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get lbWeekly;

  /// No description provided for @lbWeeklySub.
  ///
  /// In en, this message translates to:
  /// **'Ranked by your best single-game score this week (resets Sunday)'**
  String get lbWeeklySub;

  /// No description provided for @lbGlobalSub.
  ///
  /// In en, this message translates to:
  /// **'Ranked by your highest single-game score ever'**
  String get lbGlobalSub;

  /// No description provided for @lbScoreLine.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String lbScoreLine(Object score);

  /// No description provided for @lbLoadingGlobal.
  ///
  /// In en, this message translates to:
  /// **'Loading global leaderboard...'**
  String get lbLoadingGlobal;

  /// No description provided for @lbLoadingWeekly.
  ///
  /// In en, this message translates to:
  /// **'Loading weekly leaderboard...'**
  String get lbLoadingWeekly;

  /// No description provided for @lbNoScores.
  ///
  /// In en, this message translates to:
  /// **'No scores yet'**
  String get lbNoScores;

  /// No description provided for @lbBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to set a high score!'**
  String get lbBeFirst;

  /// No description provided for @lbNoWeekly.
  ///
  /// In en, this message translates to:
  /// **'No weekly scores yet'**
  String get lbNoWeekly;

  /// No description provided for @lbPlayThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Play this week to appear here!'**
  String get lbPlayThisWeek;

  /// No description provided for @lbAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get lbAnonymous;

  /// No description provided for @lbGuestBadge.
  ///
  /// In en, this message translates to:
  /// **'GUEST'**
  String get lbGuestBadge;

  /// No description provided for @lbPts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get lbPts;

  /// No description provided for @lbGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} game played} other{{count} games played}}'**
  String lbGamesPlayed(num count);

  /// No description provided for @bpClaimedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} claimed!'**
  String bpClaimedToast(Object name);

  /// No description provided for @bpTitle.
  ///
  /// In en, this message translates to:
  /// **'Battle Pass'**
  String get bpTitle;

  /// No description provided for @bpTitleUpper.
  ///
  /// In en, this message translates to:
  /// **'BATTLE PASS'**
  String get bpTitleUpper;

  /// No description provided for @bpLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading battle pass...'**
  String get bpLoading;

  /// No description provided for @bpWatchAdXp.
  ///
  /// In en, this message translates to:
  /// **'Watch ad — +50 Battle Pass XP'**
  String get bpWatchAdXp;

  /// No description provided for @bpXpEarned.
  ///
  /// In en, this message translates to:
  /// **'+50 Battle Pass XP earned!'**
  String get bpXpEarned;

  /// No description provided for @bpSeasonEnded.
  ///
  /// In en, this message translates to:
  /// **'Season ended'**
  String get bpSeasonEnded;

  /// No description provided for @bpHoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{hours}h left'**
  String bpHoursLeft(Object hours);

  /// No description provided for @bpDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days}d left'**
  String bpDaysLeft(Object days);

  /// No description provided for @bpTierUpper.
  ///
  /// In en, this message translates to:
  /// **'TIER'**
  String get bpTierUpper;

  /// No description provided for @bpTierMax.
  ///
  /// In en, this message translates to:
  /// **' / {max}'**
  String bpTierMax(Object max);

  /// No description provided for @bpSeasonComplete.
  ///
  /// In en, this message translates to:
  /// **'Season complete'**
  String get bpSeasonComplete;

  /// No description provided for @bpSeasonCompleteUpper.
  ///
  /// In en, this message translates to:
  /// **'SEASON COMPLETE'**
  String get bpSeasonCompleteUpper;

  /// No description provided for @bpXpProgress.
  ///
  /// In en, this message translates to:
  /// **'{xp} / {next} XP to Tier {tier}'**
  String bpXpProgress(Object next, Object tier, Object xp);

  /// No description provided for @bpPremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get bpPremiumBadge;

  /// Name of the launch battle-pass season, shown as the screen's page title (uppercased at render). Keyed on the exact English season name because seasons can also arrive from the backend — an unrecognised server season falls through untranslated. Flavour text: translate for feel, not literally.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Serpent Season'**
  String get bpSeasonCosmicSerpent;

  /// No description provided for @bpUnlockedEverything.
  ///
  /// In en, this message translates to:
  /// **'You\'ve unlocked every tier in this season.'**
  String get bpUnlockedEverything;

  /// No description provided for @bpComingNext.
  ///
  /// In en, this message translates to:
  /// **'COMING NEXT'**
  String get bpComingNext;

  /// No description provided for @bpTierN.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier}'**
  String bpTierN(Object tier);

  /// No description provided for @bpTiersAway.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tier away} other{{count} tiers away}}'**
  String bpTiersAway(num count);

  /// No description provided for @bpUnlockWithPro.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK WITH PRO'**
  String get bpUnlockWithPro;

  /// No description provided for @bpAvailableNow.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE NOW'**
  String get bpAvailableNow;

  /// No description provided for @bpTierAbbrev.
  ///
  /// In en, this message translates to:
  /// **'T{tier}'**
  String bpTierAbbrev(Object tier);

  /// No description provided for @bpClaim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get bpClaim;

  /// No description provided for @bpPremiumWaiting.
  ///
  /// In en, this message translates to:
  /// **'Premium rewards waiting'**
  String get bpPremiumWaiting;

  /// No description provided for @bpSubscribeToClaim.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Pro to claim them.'**
  String get bpSubscribeToClaim;

  /// No description provided for @bpHideTiers.
  ///
  /// In en, this message translates to:
  /// **'Hide tiers'**
  String get bpHideTiers;

  /// No description provided for @bpViewAllTiers.
  ///
  /// In en, this message translates to:
  /// **'View all {count} tiers'**
  String bpViewAllTiers(Object count);

  /// No description provided for @bpCollapse.
  ///
  /// In en, this message translates to:
  /// **'COLLAPSE'**
  String get bpCollapse;

  /// No description provided for @bpExpand.
  ///
  /// In en, this message translates to:
  /// **'EXPAND'**
  String get bpExpand;

  /// No description provided for @bpNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get bpNow;

  /// No description provided for @bpTierUpperN.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier}'**
  String bpTierUpperN(Object tier);

  /// No description provided for @bpUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get bpUnlocked;

  /// No description provided for @bpReachTier.
  ///
  /// In en, this message translates to:
  /// **'Reach Tier {tier} to unlock'**
  String bpReachTier(Object tier);

  /// No description provided for @bpBetweenSeasons.
  ///
  /// In en, this message translates to:
  /// **'Between Seasons'**
  String get bpBetweenSeasons;

  /// No description provided for @bpNoSeasonBody.
  ///
  /// In en, this message translates to:
  /// **'No Battle Pass is running right now — the next season will start automatically. Check back soon.'**
  String get bpNoSeasonBody;

  /// No description provided for @bpCheckNewSeason.
  ///
  /// In en, this message translates to:
  /// **'Check for new season'**
  String get bpCheckNewSeason;

  /// No description provided for @pbActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active!'**
  String get pbActive;

  /// No description provided for @pbActiveSub.
  ///
  /// In en, this message translates to:
  /// **'You have access to all premium features'**
  String get pbActiveSub;

  /// No description provided for @pbHeaderSub.
  ///
  /// In en, this message translates to:
  /// **'Unlock everything the game has to offer'**
  String get pbHeaderSub;

  /// No description provided for @pbMonthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get pbMonthlyPlan;

  /// No description provided for @pbYearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get pbYearlyPlan;

  /// No description provided for @pbSave33.
  ///
  /// In en, this message translates to:
  /// **'Save 33%'**
  String get pbSave33;

  /// No description provided for @pbMostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get pbMostPopular;

  /// No description provided for @pbFeatExtraLife.
  ///
  /// In en, this message translates to:
  /// **'Always-Free Extra Life'**
  String get pbFeatExtraLife;

  /// No description provided for @pbFeatExtraLifeDesc.
  ///
  /// In en, this message translates to:
  /// **'Crash and keep going — Pro members revive instantly for free, no ad and no coins, once every game'**
  String get pbFeatExtraLifeDesc;

  /// No description provided for @pbFeatNoAds.
  ///
  /// In en, this message translates to:
  /// **'Remove All Ads'**
  String get pbFeatNoAds;

  /// No description provided for @pbFeatNoAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'No banners, no interstitials — play completely ad-free, forever'**
  String get pbFeatNoAdsDesc;

  /// No description provided for @pbFeatThemes.
  ///
  /// In en, this message translates to:
  /// **'All Premium Themes'**
  String get pbFeatThemes;

  /// No description provided for @pbFeatThemesDesc.
  ///
  /// In en, this message translates to:
  /// **'Crystal, Cyberpunk, Space, Ocean, Desert, Forest'**
  String get pbFeatThemesDesc;

  /// No description provided for @pbFeatSkins.
  ///
  /// In en, this message translates to:
  /// **'All Premium Snake Skins'**
  String get pbFeatSkins;

  /// No description provided for @pbFeatSkinsDesc.
  ///
  /// In en, this message translates to:
  /// **'Golden, Galaxy, Dragon, Electric, Fire, Ice & 5 more'**
  String get pbFeatSkinsDesc;

  /// No description provided for @pbFeatTrails.
  ///
  /// In en, this message translates to:
  /// **'All Premium Trail Effects'**
  String get pbFeatTrails;

  /// No description provided for @pbFeatTrailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Particle, Glow, Rainbow, Fire, Cosmic, Crystal & 5 more'**
  String get pbFeatTrailsDesc;

  /// No description provided for @pbFeatBoards.
  ///
  /// In en, this message translates to:
  /// **'Large Game Boards'**
  String get pbFeatBoards;

  /// No description provided for @pbFeatBoardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Play on 35x35, 40x40 & 50x50 boards'**
  String get pbFeatBoardsDesc;

  /// No description provided for @pbFeatCoins.
  ///
  /// In en, this message translates to:
  /// **'2x Coin Rewards'**
  String get pbFeatCoins;

  /// No description provided for @pbFeatCoinsDesc.
  ///
  /// In en, this message translates to:
  /// **'Double Snake Coins from every game'**
  String get pbFeatCoinsDesc;

  /// No description provided for @pbFeatLucky.
  ///
  /// In en, this message translates to:
  /// **'Lucky Forager — More Special Foods'**
  String get pbFeatLucky;

  /// No description provided for @pbFeatLuckyDesc.
  ///
  /// In en, this message translates to:
  /// **'+50% chance to spawn the rare 50-point special food in every game'**
  String get pbFeatLuckyDesc;

  /// No description provided for @pbFeatPowerUps.
  ///
  /// In en, this message translates to:
  /// **'More In-Game Power-ups'**
  String get pbFeatPowerUps;

  /// No description provided for @pbFeatPowerUpsDesc.
  ///
  /// In en, this message translates to:
  /// **'+30% spawn rate for on-board power-ups during gameplay'**
  String get pbFeatPowerUpsDesc;

  /// No description provided for @pbFeatBundle.
  ///
  /// In en, this message translates to:
  /// **'Premium Power-up Bundle'**
  String get pbFeatBundle;

  /// No description provided for @pbFeatBundleDesc.
  ///
  /// In en, this message translates to:
  /// **'5× Teleport, Ghost Mode, Magnetic Food, Score Shield & Mega Invincibility every billing cycle'**
  String get pbFeatBundleDesc;

  /// No description provided for @pbFeatTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament Entries'**
  String get pbFeatTournament;

  /// No description provided for @pbFeatTournamentDesc.
  ///
  /// In en, this message translates to:
  /// **'1× Bronze + 1× Silver + 1× Gold tournament entry every billing cycle'**
  String get pbFeatTournamentDesc;

  /// No description provided for @pbIncludes.
  ///
  /// In en, this message translates to:
  /// **'Premium Includes:'**
  String get pbIncludes;

  /// No description provided for @pbProPerk.
  ///
  /// In en, this message translates to:
  /// **'PRO PERK'**
  String get pbProPerk;

  /// No description provided for @pbSubscribeCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe — {price}{period}'**
  String pbSubscribeCta(Object period, Object price);

  /// No description provided for @pbReassurance.
  ///
  /// In en, this message translates to:
  /// **'No commitment • Cancel anytime • Secure payment'**
  String get pbReassurance;

  /// No description provided for @pbNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Premium subscription not available'**
  String get pbNotAvailable;

  /// No description provided for @eaTitleLink.
  ///
  /// In en, this message translates to:
  /// **'Save Your Progress'**
  String get eaTitleLink;

  /// No description provided for @eaTitleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Email Sign-In'**
  String get eaTitleSignIn;

  /// No description provided for @eaExplainer.
  ///
  /// In en, this message translates to:
  /// **'Add an email and password to your account so you can buy items, restore on reinstall, and sign in from any device.'**
  String get eaExplainer;

  /// No description provided for @eaLinkExisting.
  ///
  /// In en, this message translates to:
  /// **'Link Existing'**
  String get eaLinkExisting;

  /// No description provided for @eaSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get eaSignIn;

  /// No description provided for @eaCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get eaCreateAccount;

  /// No description provided for @eaForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get eaForgotPassword;

  /// No description provided for @eaLinkToExisting.
  ///
  /// In en, this message translates to:
  /// **'Link to Existing Account'**
  String get eaLinkToExisting;

  /// No description provided for @eaMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get eaMinChars;

  /// No description provided for @eaMinCharsN.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String eaMinCharsN(Object count);

  /// No description provided for @eaCreateAndLink.
  ///
  /// In en, this message translates to:
  /// **'Create & Link Account'**
  String get eaCreateAndLink;

  /// No description provided for @eaEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get eaEmail;

  /// No description provided for @eaEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get eaEmailRequired;

  /// No description provided for @eaEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get eaEmailInvalid;

  /// No description provided for @eaPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get eaPassword;

  /// No description provided for @eaPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get eaPasswordRequired;

  /// No description provided for @eaForgotFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above first, then tap Forgot password.'**
  String get eaForgotFirst;

  /// No description provided for @eaResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent to {email}.'**
  String eaResetSent(Object email);

  /// No description provided for @eaErrInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address is not valid.'**
  String get eaErrInvalidEmail;

  /// No description provided for @eaErrDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get eaErrDisabled;

  /// No description provided for @eaErrNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account found with that email.'**
  String get eaErrNoAccount;

  /// No description provided for @eaErrWrongCreds.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get eaErrWrongCreds;

  /// No description provided for @eaErrEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with that email already exists. Try signing in instead.'**
  String get eaErrEmailInUse;

  /// No description provided for @eaErrWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Use at least 8 characters.'**
  String get eaErrWeakPassword;

  /// No description provided for @eaErrNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-in is not enabled. Contact support.'**
  String get eaErrNotEnabled;

  /// No description provided for @eaErrTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes and try again.'**
  String get eaErrTooMany;

  /// No description provided for @eaErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get eaErrNetwork;

  /// No description provided for @eaErrAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This account is already linked to email/password.'**
  String get eaErrAlreadyLinked;

  /// No description provided for @eaErrRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, please sign in again before linking.'**
  String get eaErrRecentLogin;

  /// No description provided for @eaErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get eaErrGeneric;

  /// No description provided for @faWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nSnake Classic!'**
  String get faWelcome;

  /// No description provided for @faChooseHow.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to play:'**
  String get faChooseHow;

  /// No description provided for @faSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing you in...'**
  String get faSigningIn;

  /// No description provided for @faSignInEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get faSignInEmail;

  /// No description provided for @faContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get faContinueGuest;

  /// No description provided for @faGuestNote.
  ///
  /// In en, this message translates to:
  /// **'Guests can play and save progress locally, but cannot make purchases. Sign in with Apple, Google or Email when you are ready to subscribe or buy.'**
  String get faGuestNote;

  /// No description provided for @faPrivacyTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms'**
  String get faPrivacyTerms;

  /// No description provided for @faReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Please review our Privacy Policy and Terms of Use before continuing'**
  String get faReviewNote;

  /// No description provided for @faAgreeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Privacy Policy and Terms of Use'**
  String get faAgreeCheckbox;

  /// No description provided for @faContinueToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue to Sign In'**
  String get faContinueToSignIn;

  /// No description provided for @faHeadsUp.
  ///
  /// In en, this message translates to:
  /// **'Heads up'**
  String get faHeadsUp;

  /// No description provided for @faGuestBullet1.
  ///
  /// In en, this message translates to:
  /// **'Guest data is automatically deleted from our servers after 90 days of inactivity.'**
  String get faGuestBullet1;

  /// No description provided for @faGuestBullet2.
  ///
  /// In en, this message translates to:
  /// **'To save your progress permanently and play across devices, sign in with Apple, Google or Email instead.'**
  String get faGuestBullet2;

  /// No description provided for @faGuestBullet3.
  ///
  /// In en, this message translates to:
  /// **'Guest accounts cannot purchase products or subscriptions. Sign in if you want to upgrade to Pro or buy cosmetics.'**
  String get faGuestBullet3;

  /// No description provided for @faChangedMind.
  ///
  /// In en, this message translates to:
  /// **'I changed my mind'**
  String get faChangedMind;

  /// No description provided for @faProceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed anyway'**
  String get faProceedAnyway;

  /// No description provided for @faAppleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Apple. Please try again.'**
  String get faAppleFailed;

  /// No description provided for @faGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google. Please try again.'**
  String get faGoogleFailed;

  /// No description provided for @faUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get faUnexpected;

  /// No description provided for @faGuestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to continue as guest. Please try again.'**
  String get faGuestFailed;

  /// No description provided for @ldInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing Snake Classic...'**
  String get ldInitializing;

  /// No description provided for @ldTip1.
  ///
  /// In en, this message translates to:
  /// **'Plan two moves ahead — your tail follows wherever the head just went.'**
  String get ldTip1;

  /// No description provided for @ldTip2.
  ///
  /// In en, this message translates to:
  /// **'Bonus food is worth more points, but it disappears fast. Grab it quick!'**
  String get ldTip2;

  /// No description provided for @ldTip3.
  ///
  /// In en, this message translates to:
  /// **'Crashed? Watch a quick ad or spend coins to revive and keep your score.'**
  String get ldTip3;

  /// No description provided for @ldTip4.
  ///
  /// In en, this message translates to:
  /// **'Chain food without pausing to build a combo multiplier.'**
  String get ldTip4;

  /// No description provided for @ldTip5.
  ///
  /// In en, this message translates to:
  /// **'Stuck in a tight spot? Hug the walls to buy yourself a moment.'**
  String get ldTip5;

  /// No description provided for @ldTip6.
  ///
  /// In en, this message translates to:
  /// **'Daily challenges and weekly quests stack up coins fast.'**
  String get ldTip6;

  /// No description provided for @ldTip7.
  ///
  /// In en, this message translates to:
  /// **'Snake Classic Pro unlocks bigger boards and removes all ads.'**
  String get ldTip7;

  /// No description provided for @ldTip8.
  ///
  /// In en, this message translates to:
  /// **'Time Attack rewards speed — and you can watch an ad for +30 seconds.'**
  String get ldTip8;

  /// No description provided for @ldTip9.
  ///
  /// In en, this message translates to:
  /// **'Power-ups stack: arm a shield before squeezing through a gap.'**
  String get ldTip9;

  /// No description provided for @ldTip10.
  ///
  /// In en, this message translates to:
  /// **'Switch themes, skins, and trails anytime in the store for a fresh look.'**
  String get ldTip10;

  /// No description provided for @ldStepCore.
  ///
  /// In en, this message translates to:
  /// **'Initializing core systems...'**
  String get ldStepCore;

  /// No description provided for @ldStepCoreSub.
  ///
  /// In en, this message translates to:
  /// **'Setting up Server connection'**
  String get ldStepCoreSub;

  /// No description provided for @ldStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Creating your player profile...'**
  String get ldStepProfile;

  /// No description provided for @ldStepProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Generating unique username'**
  String get ldStepProfileSub;

  /// No description provided for @ldStepPrefs.
  ///
  /// In en, this message translates to:
  /// **'Loading your preferences...'**
  String get ldStepPrefs;

  /// No description provided for @ldStepPrefsSub.
  ///
  /// In en, this message translates to:
  /// **'Syncing themes and settings'**
  String get ldStepPrefsSub;

  /// No description provided for @ldStepCloud.
  ///
  /// In en, this message translates to:
  /// **'Syncing with cloud...'**
  String get ldStepCloud;

  /// No description provided for @ldStepCloudSub.
  ///
  /// In en, this message translates to:
  /// **'Ensuring data is up to date'**
  String get ldStepCloudSub;

  /// No description provided for @ldStepGameData.
  ///
  /// In en, this message translates to:
  /// **'Loading game data...'**
  String get ldStepGameData;

  /// No description provided for @ldStepGameDataSub.
  ///
  /// In en, this message translates to:
  /// **'Fetching Game Data'**
  String get ldStepGameDataSub;

  /// No description provided for @ldStepAudio.
  ///
  /// In en, this message translates to:
  /// **'Configuring audio system...'**
  String get ldStepAudio;

  /// No description provided for @ldStepAudioSub.
  ///
  /// In en, this message translates to:
  /// **'Loading sound effects'**
  String get ldStepAudioSub;

  /// No description provided for @ldStepSetup.
  ///
  /// In en, this message translates to:
  /// **'Checking setup status...'**
  String get ldStepSetup;

  /// No description provided for @ldStepSetupSub.
  ///
  /// In en, this message translates to:
  /// **'Almost ready!'**
  String get ldStepSetupSub;

  /// No description provided for @ldWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get ldWelcome;

  /// No description provided for @ldWelcomeSub.
  ///
  /// In en, this message translates to:
  /// **'Choose how to continue'**
  String get ldWelcomeSub;

  /// No description provided for @ldReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to play!'**
  String get ldReady;

  /// No description provided for @ldReadySub.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to Snake Classic'**
  String get ldReadySub;

  /// No description provided for @ldInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization failed: {error}'**
  String ldInitFailed(Object error);

  /// No description provided for @ldRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying initialization...'**
  String get ldRetrying;

  /// No description provided for @ldTagline.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM SNAKE EXPERIENCE'**
  String get ldTagline;

  /// No description provided for @ldLoadingUpper.
  ///
  /// In en, this message translates to:
  /// **'LOADING'**
  String get ldLoadingUpper;

  /// No description provided for @ldDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'DID YOU KNOW?'**
  String get ldDidYouKnow;

  /// No description provided for @ldGameFeatures.
  ///
  /// In en, this message translates to:
  /// **'GAME FEATURES'**
  String get ldGameFeatures;

  /// No description provided for @ldFeatFps.
  ///
  /// In en, this message translates to:
  /// **'60FPS'**
  String get ldFeatFps;

  /// No description provided for @ldFeatFpsSub.
  ///
  /// In en, this message translates to:
  /// **'Smooth Gameplay'**
  String get ldFeatFpsSub;

  /// No description provided for @ldFeatEffects.
  ///
  /// In en, this message translates to:
  /// **'EFFECTS'**
  String get ldFeatEffects;

  /// No description provided for @ldFeatEffectsSub.
  ///
  /// In en, this message translates to:
  /// **'Visual Particles'**
  String get ldFeatEffectsSub;

  /// No description provided for @ldFeatLevels.
  ///
  /// In en, this message translates to:
  /// **'LEVELS'**
  String get ldFeatLevels;

  /// No description provided for @ldFeatLevelsSub.
  ///
  /// In en, this message translates to:
  /// **'Progressive Fun'**
  String get ldFeatLevelsSub;

  /// No description provided for @ldFeatAudio.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get ldFeatAudio;

  /// No description provided for @ldFeatAudioSub.
  ///
  /// In en, this message translates to:
  /// **'Immersive Sound'**
  String get ldFeatAudioSub;

  /// No description provided for @ldFeatScores.
  ///
  /// In en, this message translates to:
  /// **'SCORES'**
  String get ldFeatScores;

  /// No description provided for @ldFeatScoresSub.
  ///
  /// In en, this message translates to:
  /// **'Global Rankings'**
  String get ldFeatScoresSub;

  /// No description provided for @ldFeatThemes.
  ///
  /// In en, this message translates to:
  /// **'THEMES'**
  String get ldFeatThemes;

  /// No description provided for @ldFeatThemesSub.
  ///
  /// In en, this message translates to:
  /// **'Multiple Styles'**
  String get ldFeatThemesSub;

  /// No description provided for @ldDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'DEVELOPED & MAINTAINED BY'**
  String get ldDevelopedBy;

  /// No description provided for @ldDevTagline.
  ///
  /// In en, this message translates to:
  /// **'Crafting premium mobile experiences'**
  String get ldDevTagline;

  /// No description provided for @ldInitFailedUpper.
  ///
  /// In en, this message translates to:
  /// **'INITIALIZATION FAILED'**
  String get ldInitFailedUpper;

  /// No description provided for @ldRetryUpper.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get ldRetryUpper;

  /// No description provided for @pgArena.
  ///
  /// In en, this message translates to:
  /// **'Initializing arena...'**
  String get pgArena;

  /// No description provided for @pgControls.
  ///
  /// In en, this message translates to:
  /// **'Calibrating controls...'**
  String get pgControls;

  /// No description provided for @pgSnake.
  ///
  /// In en, this message translates to:
  /// **'Spawning the snake...'**
  String get pgSnake;

  /// No description provided for @pgFood.
  ///
  /// In en, this message translates to:
  /// **'Placing the food...'**
  String get pgFood;

  /// No description provided for @pgPowerUps.
  ///
  /// In en, this message translates to:
  /// **'Charging power-ups...'**
  String get pgPowerUps;

  /// No description provided for @pgAlmost.
  ///
  /// In en, this message translates to:
  /// **'Almost there...'**
  String get pgAlmost;

  /// No description provided for @pgGo.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get pgGo;

  /// No description provided for @pgTip1.
  ///
  /// In en, this message translates to:
  /// **'Hold a direction longer to build combo multipliers.'**
  String get pgTip1;

  /// No description provided for @pgTip2.
  ///
  /// In en, this message translates to:
  /// **'Bonus food yields more points but vanishes quickly.'**
  String get pgTip2;

  /// No description provided for @pgTip3.
  ///
  /// In en, this message translates to:
  /// **'Power-ups spawn at random — grab them while you can.'**
  String get pgTip3;

  /// No description provided for @pgTip4.
  ///
  /// In en, this message translates to:
  /// **'Plan two moves ahead, not just one.'**
  String get pgTip4;

  /// No description provided for @pgTip5.
  ///
  /// In en, this message translates to:
  /// **'Long snakes turn slower. Save tight curves for the start.'**
  String get pgTip5;

  /// No description provided for @pgTip6.
  ///
  /// In en, this message translates to:
  /// **'Score Multiplier stacks with combos for monster scores.'**
  String get pgTip6;

  /// No description provided for @pgTip7.
  ///
  /// In en, this message translates to:
  /// **'Special food is rare — when it appears, prioritize it.'**
  String get pgTip7;

  /// No description provided for @pgTip8.
  ///
  /// In en, this message translates to:
  /// **'Time Attack speeds up fast. Pace your turns.'**
  String get pgTip8;

  /// No description provided for @pgTip9.
  ///
  /// In en, this message translates to:
  /// **'In Zen Mode, the walls wrap. Use it to escape tight spots.'**
  String get pgTip9;

  /// No description provided for @pgTip10.
  ///
  /// In en, this message translates to:
  /// **'Perfect Game: never re-enter a cell your body has touched.'**
  String get pgTip10;

  /// No description provided for @pgTip11.
  ///
  /// In en, this message translates to:
  /// **'The D-Pad gives precise turns; swipe is faster.'**
  String get pgTip11;

  /// No description provided for @pgTip12.
  ///
  /// In en, this message translates to:
  /// **'Pause anytime from the HUD — your timer holds with you.'**
  String get pgTip12;

  /// No description provided for @pgPreparing.
  ///
  /// In en, this message translates to:
  /// **'PREPARING ARENA'**
  String get pgPreparing;

  /// No description provided for @pgTournamentMode.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT MODE'**
  String get pgTournamentMode;

  /// No description provided for @pgGameMode.
  ///
  /// In en, this message translates to:
  /// **'GAME MODE'**
  String get pgGameMode;

  /// No description provided for @pgDPadControls.
  ///
  /// In en, this message translates to:
  /// **'D-Pad Controls'**
  String get pgDPadControls;

  /// No description provided for @pgSwipeControls.
  ///
  /// In en, this message translates to:
  /// **'Swipe Controls'**
  String get pgSwipeControls;

  /// No description provided for @pgLevel.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get pgLevel;

  /// No description provided for @pgBest.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get pgBest;

  /// No description provided for @pgGames.
  ///
  /// In en, this message translates to:
  /// **'GAMES'**
  String get pgGames;

  /// No description provided for @pgProTip.
  ///
  /// In en, this message translates to:
  /// **'PRO TIP'**
  String get pgProTip;

  /// No description provided for @pgTapToStart.
  ///
  /// In en, this message translates to:
  /// **'TAP ANYWHERE TO START'**
  String get pgTapToStart;

  /// No description provided for @wtWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Game!'**
  String get wtWelcomeTitle;

  /// No description provided for @wtWelcomeMsg.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn how to play Snake Classic. This quick tutorial will show you the basics.'**
  String get wtWelcomeMsg;

  /// No description provided for @wtHudTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Info'**
  String get wtHudTitle;

  /// No description provided for @wtHudMsg.
  ///
  /// In en, this message translates to:
  /// **'The top bar shows your score, level, and high score. Watch your progress as you play!'**
  String get wtHudMsg;

  /// No description provided for @wtControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe to Move'**
  String get wtControlsTitle;

  /// No description provided for @wtControlsMsg.
  ///
  /// In en, this message translates to:
  /// **'Swipe in any direction to change where your snake is heading. The snake will turn to follow your swipe.'**
  String get wtControlsMsg;

  /// No description provided for @wtPracticeRightTitle.
  ///
  /// In en, this message translates to:
  /// **'Try it! Swipe RIGHT'**
  String get wtPracticeRightTitle;

  /// No description provided for @wtPracticeRightMsg.
  ///
  /// In en, this message translates to:
  /// **'Swipe RIGHT on the screen to continue.'**
  String get wtPracticeRightMsg;

  /// No description provided for @wtPracticeUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Great! Now swipe UP'**
  String get wtPracticeUpTitle;

  /// No description provided for @wtPracticeUpMsg.
  ///
  /// In en, this message translates to:
  /// **'Swipe UP on the screen to continue.'**
  String get wtPracticeUpMsg;

  /// No description provided for @wtFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Eat to Grow'**
  String get wtFoodTitle;

  /// No description provided for @wtFoodMsg.
  ///
  /// In en, this message translates to:
  /// **'Guide your snake to eat the food that appears on the board. Each food item makes your snake longer!'**
  String get wtFoodMsg;

  /// No description provided for @wtComboTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a Combo'**
  String get wtComboTitle;

  /// No description provided for @wtComboMsg.
  ///
  /// In en, this message translates to:
  /// **'Eat food without dying to build a combo. At 5 bites you get 1.5×, at 10 you get 2×, at 20 you get 3×. The fire chip near your score heats up and pulses as you climb.'**
  String get wtComboMsg;

  /// No description provided for @wtPowerUpsTitle.
  ///
  /// In en, this message translates to:
  /// **'Power-ups'**
  String get wtPowerUpsTitle;

  /// No description provided for @wtPowerUpsMsg.
  ///
  /// In en, this message translates to:
  /// **'Sparkly icons spawn occasionally — eat one to activate it. The ring around its icon drains as the effect runs out, and the timer freezes if you pause the game.'**
  String get wtPowerUpsMsg;

  /// No description provided for @wtWallsTitle.
  ///
  /// In en, this message translates to:
  /// **'Avoid the Walls!'**
  String get wtWallsTitle;

  /// No description provided for @wtWallsMsg.
  ///
  /// In en, this message translates to:
  /// **'Don\'t hit the edges of the board - it\'s game over if you crash into a wall!'**
  String get wtWallsMsg;

  /// No description provided for @wtSelfTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Hit Yourself!'**
  String get wtSelfTitle;

  /// No description provided for @wtSelfMsg.
  ///
  /// In en, this message translates to:
  /// **'As your snake grows longer, be careful not to crash into your own body!'**
  String get wtSelfMsg;

  /// No description provided for @wtPauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause Anytime'**
  String get wtPauseTitle;

  /// No description provided for @wtPauseMsg.
  ///
  /// In en, this message translates to:
  /// **'Tap the pause icon to freeze the run. From there you can resume, restart, open the Game Guide, replay this tutorial, or toggle the D-Pad.'**
  String get wtPauseMsg;

  /// No description provided for @wtReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re Ready!'**
  String get wtReadyTitle;

  /// No description provided for @wtReadyMsg.
  ///
  /// In en, this message translates to:
  /// **'Good luck! Open the pause menu\'s Game Guide anytime to read up on combos, power-ups, modes, and crash feedback. Check your Profile to see achievements unlock as you hit goals.'**
  String get wtReadyMsg;

  /// No description provided for @wtStartPlaying.
  ///
  /// In en, this message translates to:
  /// **'Start Playing!'**
  String get wtStartPlaying;

  /// No description provided for @wtSkipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get wtSkipTutorial;

  /// No description provided for @wtSwipeRightUpper.
  ///
  /// In en, this message translates to:
  /// **'SWIPE RIGHT'**
  String get wtSwipeRightUpper;

  /// No description provided for @wtSwipeLeftUpper.
  ///
  /// In en, this message translates to:
  /// **'SWIPE LEFT'**
  String get wtSwipeLeftUpper;

  /// No description provided for @wtSwipeUpUpper.
  ///
  /// In en, this message translates to:
  /// **'SWIPE UP'**
  String get wtSwipeUpUpper;

  /// No description provided for @wtSwipeDownUpper.
  ///
  /// In en, this message translates to:
  /// **'SWIPE DOWN'**
  String get wtSwipeDownUpper;

  /// No description provided for @wtSwipeAnywhereScreen.
  ///
  /// In en, this message translates to:
  /// **'Swipe anywhere on screen!'**
  String get wtSwipeAnywhereScreen;

  /// No description provided for @wtSwipeAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Swipe anywhere!'**
  String get wtSwipeAnywhere;

  /// No description provided for @wtGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get wtGotIt;

  /// No description provided for @wtNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wtNext;

  /// No description provided for @wtSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get wtSkip;

  /// No description provided for @wtWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get wtWaiting;

  /// No description provided for @hwPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Snake Classic!'**
  String get hwPlayTitle;

  /// No description provided for @hwPlayMsg.
  ///
  /// In en, this message translates to:
  /// **'Tap the PLAY button to start a game. Swipe to control your snake and eat food to grow!'**
  String get hwPlayMsg;

  /// No description provided for @hwCoinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Coins'**
  String get hwCoinsTitle;

  /// No description provided for @hwCoinsMsg.
  ///
  /// In en, this message translates to:
  /// **'Earn coins by playing games, completing challenges, and daily bonuses. Use them in the store!'**
  String get hwCoinsMsg;

  /// No description provided for @hwDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenges'**
  String get hwDailyTitle;

  /// No description provided for @hwDailyMsg.
  ///
  /// In en, this message translates to:
  /// **'Complete daily challenges for bonus coins and rewards. New challenges every day!'**
  String get hwDailyMsg;

  /// No description provided for @hwStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'The Store'**
  String get hwStoreTitle;

  /// No description provided for @hwStoreMsg.
  ///
  /// In en, this message translates to:
  /// **'Buy themes, snake skins, trails, and power-ups with your coins. Unlock Pro for premium boards and exclusive cosmetics.'**
  String get hwStoreMsg;

  /// No description provided for @hwCosmeticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skins & Trails'**
  String get hwCosmeticsTitle;

  /// No description provided for @hwCosmeticsMsg.
  ///
  /// In en, this message translates to:
  /// **'Customize your snake here. Skins change how the snake itself looks; trails leave a glow behind it. Earn with coins or unlock with Pro.'**
  String get hwCosmeticsMsg;

  /// No description provided for @hwProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get hwProfileTitle;

  /// No description provided for @hwProfileMsg.
  ///
  /// In en, this message translates to:
  /// **'Stats, achievements, and high scores live here. Achievements unlock as you hit milestones — some require a specific mode (Classic, Hard, etc.). Sign in to sync across devices.'**
  String get hwProfileMsg;

  /// No description provided for @hwSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get hwSettingsTitle;

  /// No description provided for @hwSettingsMsg.
  ///
  /// In en, this message translates to:
  /// **'Customize your game experience - change themes, controls, audio, and more!'**
  String get hwSettingsMsg;

  /// No description provided for @hudScoreUpper.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get hudScoreUpper;

  /// No description provided for @hudScoreSemantics.
  ///
  /// In en, this message translates to:
  /// **'Score {value}'**
  String hudScoreSemantics(Object value);

  /// No description provided for @hudLevelBadge.
  ///
  /// In en, this message translates to:
  /// **'LV{level}'**
  String hudLevelBadge(Object level);

  /// No description provided for @hudTournamentBadge.
  ///
  /// In en, this message translates to:
  /// **'TOURNAMENT'**
  String get hudTournamentBadge;

  /// No description provided for @hudComboMultiplier.
  ///
  /// In en, this message translates to:
  /// **'{multiplier}x'**
  String hudComboMultiplier(Object multiplier);

  /// No description provided for @poPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get poPaused;

  /// No description provided for @poPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get poPremium;

  /// No description provided for @poStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get poStore;

  /// No description provided for @poResume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get poResume;

  /// No description provided for @poRestart.
  ///
  /// In en, this message translates to:
  /// **'RESTART'**
  String get poRestart;

  /// No description provided for @poHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get poHome;

  /// No description provided for @poDPadOn.
  ///
  /// In en, this message translates to:
  /// **'D-PAD: ON'**
  String get poDPadOn;

  /// No description provided for @poDPadOff.
  ///
  /// In en, this message translates to:
  /// **'D-PAD: OFF'**
  String get poDPadOff;

  /// No description provided for @poSound.
  ///
  /// In en, this message translates to:
  /// **'SOUND'**
  String get poSound;

  /// No description provided for @poMusic.
  ///
  /// In en, this message translates to:
  /// **'MUSIC'**
  String get poMusic;

  /// No description provided for @poHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get poHowToPlay;

  /// No description provided for @poGameGuide.
  ///
  /// In en, this message translates to:
  /// **'GAME GUIDE'**
  String get poGameGuide;

  /// No description provided for @poFoodUpper.
  ///
  /// In en, this message translates to:
  /// **'FOOD'**
  String get poFoodUpper;

  /// No description provided for @poPts10.
  ///
  /// In en, this message translates to:
  /// **'10 pts'**
  String get poPts10;

  /// No description provided for @poPts25.
  ///
  /// In en, this message translates to:
  /// **'25 pts'**
  String get poPts25;

  /// No description provided for @poPts50.
  ///
  /// In en, this message translates to:
  /// **'50 pts'**
  String get poPts50;

  /// No description provided for @poComboUpper.
  ///
  /// In en, this message translates to:
  /// **'COMBO'**
  String get poComboUpper;

  /// No description provided for @poBites5.
  ///
  /// In en, this message translates to:
  /// **'5 bites'**
  String get poBites5;

  /// No description provided for @poBites10.
  ///
  /// In en, this message translates to:
  /// **'10 bites'**
  String get poBites10;

  /// No description provided for @poBites20.
  ///
  /// In en, this message translates to:
  /// **'20 bites'**
  String get poBites20;

  /// No description provided for @poComboHint.
  ///
  /// In en, this message translates to:
  /// **'The fire chip near your score heats up and pulses on each tier crossing.'**
  String get poComboHint;

  /// No description provided for @poPowerUpsUpper.
  ///
  /// In en, this message translates to:
  /// **'POWER-UPS'**
  String get poPowerUpsUpper;

  /// No description provided for @poDur7s.
  ///
  /// In en, this message translates to:
  /// **'7s'**
  String get poDur7s;

  /// No description provided for @poDur6s.
  ///
  /// In en, this message translates to:
  /// **'6s'**
  String get poDur6s;

  /// No description provided for @poDur10s.
  ///
  /// In en, this message translates to:
  /// **'10s'**
  String get poDur10s;

  /// No description provided for @poDur8s.
  ///
  /// In en, this message translates to:
  /// **'8s'**
  String get poDur8s;

  /// No description provided for @poScore2x.
  ///
  /// In en, this message translates to:
  /// **'Score 2×'**
  String get poScore2x;

  /// No description provided for @poPowerUpHint.
  ///
  /// In en, this message translates to:
  /// **'The ring around the icon drains as it expires. Timer freezes on pause.'**
  String get poPowerUpHint;

  /// No description provided for @poCrashUpper.
  ///
  /// In en, this message translates to:
  /// **'CRASH'**
  String get poCrashUpper;

  /// No description provided for @poCrashHint.
  ///
  /// In en, this message translates to:
  /// **'A red shockwave fires at the cell you died on. Self-collision also highlights the body segment you hit in yellow.'**
  String get poCrashHint;

  /// No description provided for @poModesUpper.
  ///
  /// In en, this message translates to:
  /// **'MODES'**
  String get poModesUpper;

  /// No description provided for @poModeWallsOn.
  ///
  /// In en, this message translates to:
  /// **'walls on'**
  String get poModeWallsOn;

  /// No description provided for @poModeWallsOff.
  ///
  /// In en, this message translates to:
  /// **'walls off'**
  String get poModeWallsOff;

  /// No description provided for @poModeFastTick.
  ///
  /// In en, this message translates to:
  /// **'fast tick'**
  String get poModeFastTick;

  /// No description provided for @poModeThreeFoods.
  ///
  /// In en, this message translates to:
  /// **'3 foods at once'**
  String get poModeThreeFoods;

  /// No description provided for @poModeThreeLives.
  ///
  /// In en, this message translates to:
  /// **'3 lives, ramps up'**
  String get poModeThreeLives;

  /// No description provided for @poModeThreeMin.
  ///
  /// In en, this message translates to:
  /// **'3 min total'**
  String get poModeThreeMin;

  /// No description provided for @poModeFrequentPowerUps.
  ///
  /// In en, this message translates to:
  /// **'frequent power-ups'**
  String get poModeFrequentPowerUps;

  /// No description provided for @poModeDontCross.
  ///
  /// In en, this message translates to:
  /// **'don\'t cross your trail'**
  String get poModeDontCross;

  /// No description provided for @dcTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenges'**
  String get dcTitle;

  /// No description provided for @dcNoChallenges.
  ///
  /// In en, this message translates to:
  /// **'No challenges available'**
  String get dcNoChallenges;

  /// No description provided for @dcAllComplete.
  ///
  /// In en, this message translates to:
  /// **'All Complete!'**
  String get dcAllComplete;

  /// No description provided for @dcBonusCoins.
  ///
  /// In en, this message translates to:
  /// **'+{count} Bonus'**
  String dcBonusCoins(Object count);

  /// No description provided for @crVersionLine.
  ///
  /// In en, this message translates to:
  /// **'v{version} · build {build}'**
  String crVersionLine(Object build, Object version);

  /// No description provided for @crTagline.
  ///
  /// In en, this message translates to:
  /// **'The classic snake game, reimagined.'**
  String get crTagline;

  /// No description provided for @crChipModes.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get crChipModes;

  /// No description provided for @crChipAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get crChipAchievements;

  /// No description provided for @crChipDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get crChipDaily;

  /// No description provided for @crChipLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get crChipLeaderboards;

  /// No description provided for @crChipCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get crChipCosmetics;

  /// No description provided for @crCraftedBy.
  ///
  /// In en, this message translates to:
  /// **'Crafted by'**
  String get crCraftedBy;

  /// No description provided for @crCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Pranta Dutta · All rights reserved'**
  String crCopyright(Object year);

  /// No description provided for @gbSpeedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get gbSpeedNormal;

  /// No description provided for @gbSpeedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get gbSpeedFast;

  /// No description provided for @gbSpeedFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get gbSpeedFaster;

  /// No description provided for @gbSpeedBlazing.
  ///
  /// In en, this message translates to:
  /// **'Blazing'**
  String get gbSpeedBlazing;

  /// No description provided for @gbSpeedInsane.
  ///
  /// In en, this message translates to:
  /// **'Insane'**
  String get gbSpeedInsane;

  /// No description provided for @gbSpeedMax.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get gbSpeedMax;

  /// No description provided for @gbLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get gbLength;

  /// No description provided for @gbSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get gbSpeed;

  /// No description provided for @gbLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get gbLevel;

  /// No description provided for @rarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// No description provided for @rarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// No description provided for @rarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get rarityEpic;

  /// No description provided for @rarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get rarityLegendary;

  /// No description provided for @rarityDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get rarityDiamond;

  /// No description provided for @achTitleFirstBite.
  ///
  /// In en, this message translates to:
  /// **'First Bite'**
  String get achTitleFirstBite;

  /// No description provided for @achDescFirstBite.
  ///
  /// In en, this message translates to:
  /// **'Score your first point'**
  String get achDescFirstBite;

  /// No description provided for @achTitleGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achTitleGettingStarted;

  /// No description provided for @achDescGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Score 100 points'**
  String get achDescGettingStarted;

  /// No description provided for @achTitleHighScorer.
  ///
  /// In en, this message translates to:
  /// **'High Scorer'**
  String get achTitleHighScorer;

  /// No description provided for @achDescHighScorer.
  ///
  /// In en, this message translates to:
  /// **'Score 500 points in a single game'**
  String get achDescHighScorer;

  /// No description provided for @achTitleMasterScorer.
  ///
  /// In en, this message translates to:
  /// **'Master Scorer'**
  String get achTitleMasterScorer;

  /// No description provided for @achDescMasterScorer.
  ///
  /// In en, this message translates to:
  /// **'Score 1000 points in a single game'**
  String get achDescMasterScorer;

  /// No description provided for @achTitleLegendaryScorer.
  ///
  /// In en, this message translates to:
  /// **'Legendary Scorer'**
  String get achTitleLegendaryScorer;

  /// No description provided for @achDescLegendaryScorer.
  ///
  /// In en, this message translates to:
  /// **'Score 2000 points in a single game'**
  String get achDescLegendaryScorer;

  /// No description provided for @achTitleFirstGame.
  ///
  /// In en, this message translates to:
  /// **'First Game'**
  String get achTitleFirstGame;

  /// No description provided for @achDescFirstGame.
  ///
  /// In en, this message translates to:
  /// **'Play your first game'**
  String get achDescFirstGame;

  /// No description provided for @achTitleRegularPlayer.
  ///
  /// In en, this message translates to:
  /// **'Regular Player'**
  String get achTitleRegularPlayer;

  /// No description provided for @achDescRegularPlayer.
  ///
  /// In en, this message translates to:
  /// **'Play 10 games'**
  String get achDescRegularPlayer;

  /// No description provided for @achTitleDedicatedPlayer.
  ///
  /// In en, this message translates to:
  /// **'Dedicated Player'**
  String get achTitleDedicatedPlayer;

  /// No description provided for @achDescDedicatedPlayer.
  ///
  /// In en, this message translates to:
  /// **'Play 50 games'**
  String get achDescDedicatedPlayer;

  /// No description provided for @achTitleSnakeEnthusiast.
  ///
  /// In en, this message translates to:
  /// **'Snake Enthusiast'**
  String get achTitleSnakeEnthusiast;

  /// No description provided for @achDescSnakeEnthusiast.
  ///
  /// In en, this message translates to:
  /// **'Play 100 games'**
  String get achDescSnakeEnthusiast;

  /// No description provided for @achTitleSnakeAddict.
  ///
  /// In en, this message translates to:
  /// **'Snake Addict'**
  String get achTitleSnakeAddict;

  /// No description provided for @achDescSnakeAddict.
  ///
  /// In en, this message translates to:
  /// **'Play 500 games'**
  String get achDescSnakeAddict;

  /// No description provided for @achTitleSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Survivor'**
  String get achTitleSurvivor;

  /// No description provided for @achDescSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Survive for 60 seconds'**
  String get achDescSurvivor;

  /// No description provided for @achTitleEndurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get achTitleEndurance;

  /// No description provided for @achDescEndurance.
  ///
  /// In en, this message translates to:
  /// **'Survive for 2 minutes'**
  String get achDescEndurance;

  /// No description provided for @achTitleMarathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get achTitleMarathon;

  /// No description provided for @achDescMarathon.
  ///
  /// In en, this message translates to:
  /// **'Survive for 5 minutes'**
  String get achDescMarathon;

  /// No description provided for @achTitleNoWalls.
  ///
  /// In en, this message translates to:
  /// **'Wall Avoider'**
  String get achTitleNoWalls;

  /// No description provided for @achDescNoWalls.
  ///
  /// In en, this message translates to:
  /// **'Play 5 games without hitting walls'**
  String get achDescNoWalls;

  /// No description provided for @achTitleSpeedster.
  ///
  /// In en, this message translates to:
  /// **'Speedster'**
  String get achTitleSpeedster;

  /// No description provided for @achDescSpeedster.
  ///
  /// In en, this message translates to:
  /// **'Reach level 10 (max speed)'**
  String get achDescSpeedster;

  /// No description provided for @achTitlePerfectionist.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get achTitlePerfectionist;

  /// No description provided for @achDescPerfectionist.
  ///
  /// In en, this message translates to:
  /// **'Complete a game without hitting yourself'**
  String get achDescPerfectionist;

  /// No description provided for @achTitleAllFoodTypes.
  ///
  /// In en, this message translates to:
  /// **'Gourmet'**
  String get achTitleAllFoodTypes;

  /// No description provided for @achDescAllFoodTypes.
  ///
  /// In en, this message translates to:
  /// **'Eat all 3 types of food in a single game'**
  String get achDescAllFoodTypes;

  /// No description provided for @achTitleHalfGrand.
  ///
  /// In en, this message translates to:
  /// **'Half Grand'**
  String get achTitleHalfGrand;

  /// No description provided for @achDescHalfGrand.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in a single game'**
  String get achDescHalfGrand;

  /// No description provided for @achTitleScoreSniper.
  ///
  /// In en, this message translates to:
  /// **'Score Sniper'**
  String get achTitleScoreSniper;

  /// No description provided for @achDescScoreSniper.
  ///
  /// In en, this message translates to:
  /// **'Score 10,000 in a single game'**
  String get achDescScoreSniper;

  /// No description provided for @achTitleFiveDigitClub.
  ///
  /// In en, this message translates to:
  /// **'Five-Digit Club'**
  String get achTitleFiveDigitClub;

  /// No description provided for @achDescFiveDigitClub.
  ///
  /// In en, this message translates to:
  /// **'Score 25,000 in a single game'**
  String get achDescFiveDigitClub;

  /// No description provided for @achTitleScoreTycoon.
  ///
  /// In en, this message translates to:
  /// **'Score Tycoon'**
  String get achTitleScoreTycoon;

  /// No description provided for @achDescScoreTycoon.
  ///
  /// In en, this message translates to:
  /// **'Score 50,000 in a single game'**
  String get achDescScoreTycoon;

  /// No description provided for @achTitleScoreGod.
  ///
  /// In en, this message translates to:
  /// **'Score God'**
  String get achTitleScoreGod;

  /// No description provided for @achDescScoreGod.
  ///
  /// In en, this message translates to:
  /// **'Score 100,000 in a single game'**
  String get achDescScoreGod;

  /// No description provided for @achTitlePointCollector.
  ///
  /// In en, this message translates to:
  /// **'Point Collector'**
  String get achTitlePointCollector;

  /// No description provided for @achDescPointCollector.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 10,000 points lifetime'**
  String get achDescPointCollector;

  /// No description provided for @achTitlePointHoarder.
  ///
  /// In en, this message translates to:
  /// **'Point Hoarder'**
  String get achTitlePointHoarder;

  /// No description provided for @achDescPointHoarder.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 100,000 points lifetime'**
  String get achDescPointHoarder;

  /// No description provided for @achTitleHalfMillionClub.
  ///
  /// In en, this message translates to:
  /// **'Half Million Club'**
  String get achTitleHalfMillionClub;

  /// No description provided for @achDescHalfMillionClub.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 500,000 points lifetime'**
  String get achDescHalfMillionClub;

  /// No description provided for @achTitlePointMillionaire.
  ///
  /// In en, this message translates to:
  /// **'Point Millionaire'**
  String get achTitlePointMillionaire;

  /// No description provided for @achDescPointMillionaire.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 1,000,000 points lifetime'**
  String get achDescPointMillionaire;

  /// No description provided for @achTitleDecamillionaire.
  ///
  /// In en, this message translates to:
  /// **'Decamillionaire'**
  String get achTitleDecamillionaire;

  /// No description provided for @achDescDecamillionaire.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 10,000,000 points lifetime'**
  String get achDescDecamillionaire;

  /// No description provided for @achTitleSnakeVeteran.
  ///
  /// In en, this message translates to:
  /// **'Snake Veteran'**
  String get achTitleSnakeVeteran;

  /// No description provided for @achDescSnakeVeteran.
  ///
  /// In en, this message translates to:
  /// **'Play 1,000 games'**
  String get achDescSnakeVeteran;

  /// No description provided for @achTitleSnakeLegend.
  ///
  /// In en, this message translates to:
  /// **'Snake Legend'**
  String get achTitleSnakeLegend;

  /// No description provided for @achDescSnakeLegend.
  ///
  /// In en, this message translates to:
  /// **'Play 5,000 games'**
  String get achDescSnakeLegend;

  /// No description provided for @achTitleIronWill.
  ///
  /// In en, this message translates to:
  /// **'Iron Will'**
  String get achTitleIronWill;

  /// No description provided for @achDescIronWill.
  ///
  /// In en, this message translates to:
  /// **'Survive 10 minutes in a single game'**
  String get achDescIronWill;

  /// No description provided for @achTitleEternalSnake.
  ///
  /// In en, this message translates to:
  /// **'Eternal Snake'**
  String get achTitleEternalSnake;

  /// No description provided for @achDescEternalSnake.
  ///
  /// In en, this message translates to:
  /// **'Survive 20 minutes in a single game'**
  String get achDescEternalSnake;

  /// No description provided for @achTitleTimeLord.
  ///
  /// In en, this message translates to:
  /// **'Time Lord'**
  String get achTitleTimeLord;

  /// No description provided for @achDescTimeLord.
  ///
  /// In en, this message translates to:
  /// **'Survive 30 minutes in a single game'**
  String get achDescTimeLord;

  /// No description provided for @achTitleFirstBiteSnack.
  ///
  /// In en, this message translates to:
  /// **'First Bite Snack'**
  String get achTitleFirstBiteSnack;

  /// No description provided for @achDescFirstBiteSnack.
  ///
  /// In en, this message translates to:
  /// **'Eat 5 foods in one game'**
  String get achDescFirstBiteSnack;

  /// No description provided for @achTitleHungrySnake.
  ///
  /// In en, this message translates to:
  /// **'Hungry Snake'**
  String get achTitleHungrySnake;

  /// No description provided for @achDescHungrySnake.
  ///
  /// In en, this message translates to:
  /// **'Eat 20 foods in one game'**
  String get achDescHungrySnake;

  /// No description provided for @achTitleFamished.
  ///
  /// In en, this message translates to:
  /// **'Famished'**
  String get achTitleFamished;

  /// No description provided for @achDescFamished.
  ///
  /// In en, this message translates to:
  /// **'Eat 50 foods in one game'**
  String get achDescFamished;

  /// No description provided for @achTitleRavenous.
  ///
  /// In en, this message translates to:
  /// **'Ravenous'**
  String get achTitleRavenous;

  /// No description provided for @achDescRavenous.
  ///
  /// In en, this message translates to:
  /// **'Eat 100 foods in one game'**
  String get achDescRavenous;

  /// No description provided for @achTitleInsatiable.
  ///
  /// In en, this message translates to:
  /// **'Insatiable'**
  String get achTitleInsatiable;

  /// No description provided for @achDescInsatiable.
  ///
  /// In en, this message translates to:
  /// **'Eat 200 foods in one game'**
  String get achDescInsatiable;

  /// No description provided for @achTitleBlackHoleStomach.
  ///
  /// In en, this message translates to:
  /// **'Black Hole Stomach'**
  String get achTitleBlackHoleStomach;

  /// No description provided for @achDescBlackHoleStomach.
  ///
  /// In en, this message translates to:
  /// **'Eat 500 foods in one game'**
  String get achDescBlackHoleStomach;

  /// No description provided for @achTitleFoodieApprentice.
  ///
  /// In en, this message translates to:
  /// **'Foodie Apprentice'**
  String get achTitleFoodieApprentice;

  /// No description provided for @achDescFoodieApprentice.
  ///
  /// In en, this message translates to:
  /// **'Eat 100 foods lifetime'**
  String get achDescFoodieApprentice;

  /// No description provided for @achTitleFoodiePro.
  ///
  /// In en, this message translates to:
  /// **'Foodie Pro'**
  String get achTitleFoodiePro;

  /// No description provided for @achDescFoodiePro.
  ///
  /// In en, this message translates to:
  /// **'Eat 1,000 foods lifetime'**
  String get achDescFoodiePro;

  /// No description provided for @achTitleFoodieMaster.
  ///
  /// In en, this message translates to:
  /// **'Foodie Master'**
  String get achTitleFoodieMaster;

  /// No description provided for @achDescFoodieMaster.
  ///
  /// In en, this message translates to:
  /// **'Eat 10,000 foods lifetime'**
  String get achDescFoodieMaster;

  /// No description provided for @achTitleFoodieGod.
  ///
  /// In en, this message translates to:
  /// **'Foodie God'**
  String get achTitleFoodieGod;

  /// No description provided for @achDescFoodieGod.
  ///
  /// In en, this message translates to:
  /// **'Eat 50,000 foods lifetime'**
  String get achDescFoodieGod;

  /// No description provided for @achTitleQuickPlayer.
  ///
  /// In en, this message translates to:
  /// **'Quick Player'**
  String get achTitleQuickPlayer;

  /// No description provided for @achDescQuickPlayer.
  ///
  /// In en, this message translates to:
  /// **'Play for 1 hour total'**
  String get achDescQuickPlayer;

  /// No description provided for @achTitleEngagedPlayer.
  ///
  /// In en, this message translates to:
  /// **'Engaged Player'**
  String get achTitleEngagedPlayer;

  /// No description provided for @achDescEngagedPlayer.
  ///
  /// In en, this message translates to:
  /// **'Play for 10 hours total'**
  String get achDescEngagedPlayer;

  /// No description provided for @achTitleHardcorePlayer.
  ///
  /// In en, this message translates to:
  /// **'Hardcore Player'**
  String get achTitleHardcorePlayer;

  /// No description provided for @achDescHardcorePlayer.
  ///
  /// In en, this message translates to:
  /// **'Play for 50 hours total'**
  String get achDescHardcorePlayer;

  /// No description provided for @achTitleSnakeObsessed.
  ///
  /// In en, this message translates to:
  /// **'Snake Obsessed'**
  String get achTitleSnakeObsessed;

  /// No description provided for @achDescSnakeObsessed.
  ///
  /// In en, this message translates to:
  /// **'Play for 100 hours total'**
  String get achDescSnakeObsessed;

  /// No description provided for @achTitleTouchGrass.
  ///
  /// In en, this message translates to:
  /// **'Touch Grass'**
  String get achTitleTouchGrass;

  /// No description provided for @achDescTouchGrass.
  ///
  /// In en, this message translates to:
  /// **'Play for 250 hours total — maybe step outside?'**
  String get achDescTouchGrass;

  /// No description provided for @achTitleLevel5.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get achTitleLevel5;

  /// No description provided for @achDescLevel5.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 5'**
  String get achDescLevel5;

  /// No description provided for @achTitleLevel10.
  ///
  /// In en, this message translates to:
  /// **'Journeyman'**
  String get achTitleLevel10;

  /// No description provided for @achDescLevel10.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 10'**
  String get achDescLevel10;

  /// No description provided for @achTitleLevel25.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get achTitleLevel25;

  /// No description provided for @achDescLevel25.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 25'**
  String get achDescLevel25;

  /// No description provided for @achTitleLevel50.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get achTitleLevel50;

  /// No description provided for @achDescLevel50.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 50'**
  String get achDescLevel50;

  /// No description provided for @achTitleLevel100.
  ///
  /// In en, this message translates to:
  /// **'Grandmaster'**
  String get achTitleLevel100;

  /// No description provided for @achDescLevel100.
  ///
  /// In en, this message translates to:
  /// **'Reach Level 100'**
  String get achDescLevel100;

  /// No description provided for @achTitleClassicInitiate.
  ///
  /// In en, this message translates to:
  /// **'Classic Initiate'**
  String get achTitleClassicInitiate;

  /// No description provided for @achDescClassicInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 Classic-mode games'**
  String get achDescClassicInitiate;

  /// No description provided for @achTitleClassicVeteran.
  ///
  /// In en, this message translates to:
  /// **'Classic Veteran'**
  String get achTitleClassicVeteran;

  /// No description provided for @achDescClassicVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 Classic-mode games'**
  String get achDescClassicVeteran;

  /// No description provided for @achTitleClassic1000.
  ///
  /// In en, this message translates to:
  /// **'Classic Connoisseur'**
  String get achTitleClassic1000;

  /// No description provided for @achDescClassic1000.
  ///
  /// In en, this message translates to:
  /// **'Score 1,000 in Classic mode'**
  String get achDescClassic1000;

  /// No description provided for @achTitleClassic5000.
  ///
  /// In en, this message translates to:
  /// **'Classic Maestro'**
  String get achTitleClassic5000;

  /// No description provided for @achDescClassic5000.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in Classic mode'**
  String get achDescClassic5000;

  /// No description provided for @achTitleZenInitiate.
  ///
  /// In en, this message translates to:
  /// **'Zen Initiate'**
  String get achTitleZenInitiate;

  /// No description provided for @achDescZenInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 Zen games'**
  String get achDescZenInitiate;

  /// No description provided for @achTitleZenGarden.
  ///
  /// In en, this message translates to:
  /// **'Zen Garden'**
  String get achTitleZenGarden;

  /// No description provided for @achDescZenGarden.
  ///
  /// In en, this message translates to:
  /// **'Score 500 in Zen mode'**
  String get achDescZenGarden;

  /// No description provided for @achTitleZenMaster.
  ///
  /// In en, this message translates to:
  /// **'Zen Master'**
  String get achTitleZenMaster;

  /// No description provided for @achDescZenMaster.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in Zen mode'**
  String get achDescZenMaster;

  /// No description provided for @achTitleSpeedInitiate.
  ///
  /// In en, this message translates to:
  /// **'Need For Speed'**
  String get achTitleSpeedInitiate;

  /// No description provided for @achDescSpeedInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 Speed Challenge games'**
  String get achDescSpeedInitiate;

  /// No description provided for @achTitleSpeedrunner.
  ///
  /// In en, this message translates to:
  /// **'Speedrunner'**
  String get achTitleSpeedrunner;

  /// No description provided for @achDescSpeedrunner.
  ///
  /// In en, this message translates to:
  /// **'Score 500 in Speed Challenge'**
  String get achDescSpeedrunner;

  /// No description provided for @achTitleLightning.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get achTitleLightning;

  /// No description provided for @achDescLightning.
  ///
  /// In en, this message translates to:
  /// **'Score 2,000 in Speed Challenge'**
  String get achDescLightning;

  /// No description provided for @achTitleMultifoodInitiate.
  ///
  /// In en, this message translates to:
  /// **'Foodscape'**
  String get achTitleMultifoodInitiate;

  /// No description provided for @achDescMultifoodInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 MultiFood games'**
  String get achDescMultifoodInitiate;

  /// No description provided for @achTitleBuffet.
  ///
  /// In en, this message translates to:
  /// **'Buffet'**
  String get achTitleBuffet;

  /// No description provided for @achDescBuffet.
  ///
  /// In en, this message translates to:
  /// **'Score 1,000 in MultiFood'**
  String get achDescBuffet;

  /// No description provided for @achTitleSmorgasbord.
  ///
  /// In en, this message translates to:
  /// **'Smorgasbord'**
  String get achTitleSmorgasbord;

  /// No description provided for @achDescSmorgasbord.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in MultiFood'**
  String get achDescSmorgasbord;

  /// No description provided for @achTitleSurvivalInitiate.
  ///
  /// In en, this message translates to:
  /// **'Survival Initiate'**
  String get achTitleSurvivalInitiate;

  /// No description provided for @achDescSurvivalInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 Survival games'**
  String get achDescSurvivalInitiate;

  /// No description provided for @achTitleSurvivalPro.
  ///
  /// In en, this message translates to:
  /// **'Survival Pro'**
  String get achTitleSurvivalPro;

  /// No description provided for @achDescSurvivalPro.
  ///
  /// In en, this message translates to:
  /// **'Survive 5 minutes in Survival mode'**
  String get achDescSurvivalPro;

  /// No description provided for @achTitleLastSnakeStanding.
  ///
  /// In en, this message translates to:
  /// **'Last Snake Standing'**
  String get achTitleLastSnakeStanding;

  /// No description provided for @achDescLastSnakeStanding.
  ///
  /// In en, this message translates to:
  /// **'Score 2,500 in Survival'**
  String get achDescLastSnakeStanding;

  /// No description provided for @achTitleTimeattackInitiate.
  ///
  /// In en, this message translates to:
  /// **'Time Attacker'**
  String get achTitleTimeattackInitiate;

  /// No description provided for @achDescTimeattackInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 TimeAttack games'**
  String get achDescTimeattackInitiate;

  /// No description provided for @achTitleBeatTheClock.
  ///
  /// In en, this message translates to:
  /// **'Beat the Clock'**
  String get achTitleBeatTheClock;

  /// No description provided for @achDescBeatTheClock.
  ///
  /// In en, this message translates to:
  /// **'Survive the full 3-minute TimeAttack'**
  String get achDescBeatTheClock;

  /// No description provided for @achTitleTimeattackMaster.
  ///
  /// In en, this message translates to:
  /// **'TimeAttack Master'**
  String get achTitleTimeattackMaster;

  /// No description provided for @achDescTimeattackMaster.
  ///
  /// In en, this message translates to:
  /// **'Score 3,000 in TimeAttack'**
  String get achDescTimeattackMaster;

  /// No description provided for @achTitleComboStarter.
  ///
  /// In en, this message translates to:
  /// **'Combo Starter'**
  String get achTitleComboStarter;

  /// No description provided for @achDescComboStarter.
  ///
  /// In en, this message translates to:
  /// **'Hit a 5x combo in a single game'**
  String get achDescComboStarter;

  /// No description provided for @achTitleComboMaster.
  ///
  /// In en, this message translates to:
  /// **'Combo Master'**
  String get achTitleComboMaster;

  /// No description provided for @achDescComboMaster.
  ///
  /// In en, this message translates to:
  /// **'Hit a 10x combo in a single game'**
  String get achDescComboMaster;

  /// No description provided for @achTitleComboPro.
  ///
  /// In en, this message translates to:
  /// **'Combo Pro'**
  String get achTitleComboPro;

  /// No description provided for @achDescComboPro.
  ///
  /// In en, this message translates to:
  /// **'Hit a 20x combo in a single game'**
  String get achDescComboPro;

  /// No description provided for @achTitleComboGod.
  ///
  /// In en, this message translates to:
  /// **'Combo God'**
  String get achTitleComboGod;

  /// No description provided for @achDescComboGod.
  ///
  /// In en, this message translates to:
  /// **'Hit a 50x combo in a single game'**
  String get achDescComboGod;

  /// No description provided for @achTitleComboLegend.
  ///
  /// In en, this message translates to:
  /// **'Combo Legend'**
  String get achTitleComboLegend;

  /// No description provided for @achDescComboLegend.
  ///
  /// In en, this message translates to:
  /// **'Hit a 100x combo in a single game'**
  String get achDescComboLegend;

  /// No description provided for @achTitleGrowingSnake.
  ///
  /// In en, this message translates to:
  /// **'Growing Snake'**
  String get achTitleGrowingSnake;

  /// No description provided for @achDescGrowingSnake.
  ///
  /// In en, this message translates to:
  /// **'Grow snake to length 20'**
  String get achDescGrowingSnake;

  /// No description provided for @achTitleBigSnake.
  ///
  /// In en, this message translates to:
  /// **'Big Snake'**
  String get achTitleBigSnake;

  /// No description provided for @achDescBigSnake.
  ///
  /// In en, this message translates to:
  /// **'Grow snake to length 50'**
  String get achDescBigSnake;

  /// No description provided for @achTitleHugeSnake.
  ///
  /// In en, this message translates to:
  /// **'Huge Snake'**
  String get achTitleHugeSnake;

  /// No description provided for @achDescHugeSnake.
  ///
  /// In en, this message translates to:
  /// **'Grow snake to length 100'**
  String get achDescHugeSnake;

  /// No description provided for @achTitleMassiveSnake.
  ///
  /// In en, this message translates to:
  /// **'Massive Snake'**
  String get achTitleMassiveSnake;

  /// No description provided for @achDescMassiveSnake.
  ///
  /// In en, this message translates to:
  /// **'Grow snake to length 200'**
  String get achDescMassiveSnake;

  /// No description provided for @achTitleAnaconda.
  ///
  /// In en, this message translates to:
  /// **'Anaconda'**
  String get achTitleAnaconda;

  /// No description provided for @achDescAnaconda.
  ///
  /// In en, this message translates to:
  /// **'Grow snake to length 500'**
  String get achDescAnaconda;

  /// No description provided for @achTitleFirstPowerUp.
  ///
  /// In en, this message translates to:
  /// **'Power Up!'**
  String get achTitleFirstPowerUp;

  /// No description provided for @achDescFirstPowerUp.
  ///
  /// In en, this message translates to:
  /// **'Collect your first power-up'**
  String get achDescFirstPowerUp;

  /// No description provided for @achTitlePowerPlayer.
  ///
  /// In en, this message translates to:
  /// **'Power Player'**
  String get achTitlePowerPlayer;

  /// No description provided for @achDescPowerPlayer.
  ///
  /// In en, this message translates to:
  /// **'Collect 10 power-ups lifetime'**
  String get achDescPowerPlayer;

  /// No description provided for @achTitlePowerHungry.
  ///
  /// In en, this message translates to:
  /// **'Power Hungry'**
  String get achTitlePowerHungry;

  /// No description provided for @achDescPowerHungry.
  ///
  /// In en, this message translates to:
  /// **'Collect 50 power-ups lifetime'**
  String get achDescPowerHungry;

  /// No description provided for @achTitlePowerAddict.
  ///
  /// In en, this message translates to:
  /// **'Power Addict'**
  String get achTitlePowerAddict;

  /// No description provided for @achDescPowerAddict.
  ///
  /// In en, this message translates to:
  /// **'Collect 200 power-ups lifetime'**
  String get achDescPowerAddict;

  /// No description provided for @achTitlePowerMaster.
  ///
  /// In en, this message translates to:
  /// **'Power Master'**
  String get achTitlePowerMaster;

  /// No description provided for @achDescPowerMaster.
  ///
  /// In en, this message translates to:
  /// **'Collect 1,000 power-ups lifetime'**
  String get achDescPowerMaster;

  /// No description provided for @achTitleVarietyPack.
  ///
  /// In en, this message translates to:
  /// **'Variety Pack'**
  String get achTitleVarietyPack;

  /// No description provided for @achDescVarietyPack.
  ///
  /// In en, this message translates to:
  /// **'Collect each of the 4 power-up types at least once'**
  String get achDescVarietyPack;

  /// No description provided for @achTitleSpeedDemon.
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get achTitleSpeedDemon;

  /// No description provided for @achDescSpeedDemon.
  ///
  /// In en, this message translates to:
  /// **'Collect 25 Speed Boost power-ups'**
  String get achDescSpeedDemon;

  /// No description provided for @achTitleImmortalStreak.
  ///
  /// In en, this message translates to:
  /// **'Immortal Streak'**
  String get achTitleImmortalStreak;

  /// No description provided for @achDescImmortalStreak.
  ///
  /// In en, this message translates to:
  /// **'Collect 25 Invincibility power-ups'**
  String get achDescImmortalStreak;

  /// No description provided for @achTitleSpecialDiet.
  ///
  /// In en, this message translates to:
  /// **'Special Diet'**
  String get achTitleSpecialDiet;

  /// No description provided for @achDescSpecialDiet.
  ///
  /// In en, this message translates to:
  /// **'Eat 50 special foods lifetime'**
  String get achDescSpecialDiet;

  /// No description provided for @achTitleBonusHunter.
  ///
  /// In en, this message translates to:
  /// **'Bonus Hunter'**
  String get achTitleBonusHunter;

  /// No description provided for @achDescBonusHunter.
  ///
  /// In en, this message translates to:
  /// **'Eat 100 bonus foods lifetime'**
  String get achDescBonusHunter;

  /// No description provided for @achTitleUntouchable5.
  ///
  /// In en, this message translates to:
  /// **'Untouchable'**
  String get achTitleUntouchable5;

  /// No description provided for @achDescUntouchable5.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 perfect games (no hits, 30s+)'**
  String get achDescUntouchable5;

  /// No description provided for @achTitleUntouchable20.
  ///
  /// In en, this message translates to:
  /// **'Flawless'**
  String get achTitleUntouchable20;

  /// No description provided for @achDescUntouchable20.
  ///
  /// In en, this message translates to:
  /// **'Complete 20 perfect games'**
  String get achDescUntouchable20;

  /// No description provided for @achTitleUntouchable50.
  ///
  /// In en, this message translates to:
  /// **'Untouchable Legend'**
  String get achTitleUntouchable50;

  /// No description provided for @achDescUntouchable50.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 perfect games'**
  String get achDescUntouchable50;

  /// No description provided for @achTitleHotStreak.
  ///
  /// In en, this message translates to:
  /// **'Hot Streak'**
  String get achTitleHotStreak;

  /// No description provided for @achDescHotStreak.
  ///
  /// In en, this message translates to:
  /// **'5 consecutive games scoring >0 and lasting 30s+'**
  String get achDescHotStreak;

  /// No description provided for @achTitleOnFire.
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get achTitleOnFire;

  /// No description provided for @achDescOnFire.
  ///
  /// In en, this message translates to:
  /// **'10-game streak (30s+ each)'**
  String get achDescOnFire;

  /// No description provided for @achTitleUnstoppable.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get achTitleUnstoppable;

  /// No description provided for @achDescUnstoppable.
  ///
  /// In en, this message translates to:
  /// **'25-game streak (30s+ each)'**
  String get achDescUnstoppable;

  /// No description provided for @achTitleDailyThree.
  ///
  /// In en, this message translates to:
  /// **'Daily Player'**
  String get achTitleDailyThree;

  /// No description provided for @achDescDailyThree.
  ///
  /// In en, this message translates to:
  /// **'Play on 3 consecutive days'**
  String get achDescDailyThree;

  /// No description provided for @achTitleWeekWarrior.
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get achTitleWeekWarrior;

  /// No description provided for @achDescWeekWarrior.
  ///
  /// In en, this message translates to:
  /// **'Play on 7 consecutive days'**
  String get achDescWeekWarrior;

  /// No description provided for @achTitleVelocity.
  ///
  /// In en, this message translates to:
  /// **'Velocity'**
  String get achTitleVelocity;

  /// No description provided for @achDescVelocity.
  ///
  /// In en, this message translates to:
  /// **'Reach in-game level 15 in one game'**
  String get achDescVelocity;

  /// No description provided for @achTitleMachSpeed.
  ///
  /// In en, this message translates to:
  /// **'Mach Speed'**
  String get achTitleMachSpeed;

  /// No description provided for @achDescMachSpeed.
  ///
  /// In en, this message translates to:
  /// **'Reach in-game level 20 in one game'**
  String get achDescMachSpeed;

  /// No description provided for @achTitleCosmicSnake.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Snake'**
  String get achTitleCosmicSnake;

  /// No description provided for @achDescCosmicSnake.
  ///
  /// In en, this message translates to:
  /// **'Reach in-game level 25 in one game'**
  String get achDescCosmicSnake;

  /// No description provided for @achTitleModeExplorer.
  ///
  /// In en, this message translates to:
  /// **'Mode Explorer'**
  String get achTitleModeExplorer;

  /// No description provided for @achDescModeExplorer.
  ///
  /// In en, this message translates to:
  /// **'Play at least one game in 3 distinct modes'**
  String get achDescModeExplorer;

  /// No description provided for @achTitleAllModePlayer.
  ///
  /// In en, this message translates to:
  /// **'All-Mode Player'**
  String get achTitleAllModePlayer;

  /// No description provided for @achDescAllModePlayer.
  ///
  /// In en, this message translates to:
  /// **'Play at least one game in every mode (8 modes)'**
  String get achDescAllModePlayer;

  /// No description provided for @achTitleNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get achTitleNightOwl;

  /// No description provided for @achDescNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Finish a game between midnight and 5 AM'**
  String get achDescNightOwl;

  /// No description provided for @achTitleEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achTitleEarlyBird;

  /// No description provided for @achDescEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Finish a game between 5 and 8 AM'**
  String get achDescEarlyBird;

  /// No description provided for @achTitleWeekendWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get achTitleWeekendWarrior;

  /// No description provided for @achDescWeekendWarrior.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 games on weekends'**
  String get achDescWeekendWarrior;

  /// No description provided for @ppuMegaSpeedBoost.
  ///
  /// In en, this message translates to:
  /// **'Mega Speed Boost'**
  String get ppuMegaSpeedBoost;

  /// No description provided for @ppuMegaInvincibility.
  ///
  /// In en, this message translates to:
  /// **'Mega Invincibility'**
  String get ppuMegaInvincibility;

  /// No description provided for @ppuMegaScoreMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Mega Score Multiplier'**
  String get ppuMegaScoreMultiplier;

  /// No description provided for @ppuMegaSlowMotion.
  ///
  /// In en, this message translates to:
  /// **'Mega Slow Motion'**
  String get ppuMegaSlowMotion;

  /// No description provided for @ppuTeleport.
  ///
  /// In en, this message translates to:
  /// **'Teleport'**
  String get ppuTeleport;

  /// No description provided for @ppuSizeReducer.
  ///
  /// In en, this message translates to:
  /// **'Size Reducer'**
  String get ppuSizeReducer;

  /// No description provided for @ppuScoreShield.
  ///
  /// In en, this message translates to:
  /// **'Score Shield'**
  String get ppuScoreShield;

  /// No description provided for @ppuComboMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Combo Multiplier'**
  String get ppuComboMultiplier;

  /// No description provided for @ppuTimeWarp.
  ///
  /// In en, this message translates to:
  /// **'Time Warp'**
  String get ppuTimeWarp;

  /// No description provided for @ppuMagneticFood.
  ///
  /// In en, this message translates to:
  /// **'Magnetic Food'**
  String get ppuMagneticFood;

  /// No description provided for @ppuGhostMode.
  ///
  /// In en, this message translates to:
  /// **'Ghost Mode'**
  String get ppuGhostMode;

  /// No description provided for @ppuDoubleTrouble.
  ///
  /// In en, this message translates to:
  /// **'Double Trouble'**
  String get ppuDoubleTrouble;

  /// No description provided for @ppuLuckyCharm.
  ///
  /// In en, this message translates to:
  /// **'Lucky Charm'**
  String get ppuLuckyCharm;

  /// No description provided for @ppuPowerSurge.
  ///
  /// In en, this message translates to:
  /// **'Power Surge'**
  String get ppuPowerSurge;

  /// No description provided for @bundleMegaPack.
  ///
  /// In en, this message translates to:
  /// **'Mega Power Pack'**
  String get bundleMegaPack;

  /// No description provided for @bundleMegaPackDesc.
  ///
  /// In en, this message translates to:
  /// **'Enhanced versions of classic power-ups'**
  String get bundleMegaPackDesc;

  /// No description provided for @bundleTacticalPack.
  ///
  /// In en, this message translates to:
  /// **'Tactical Power Pack'**
  String get bundleTacticalPack;

  /// No description provided for @bundleTacticalPackDesc.
  ///
  /// In en, this message translates to:
  /// **'Strategic power-ups for skilled players'**
  String get bundleTacticalPackDesc;

  /// No description provided for @bundleUltimatePack.
  ///
  /// In en, this message translates to:
  /// **'Ultimate Power Pack'**
  String get bundleUltimatePack;

  /// No description provided for @bundleUltimatePackDesc.
  ///
  /// In en, this message translates to:
  /// **'Every premium power-up available'**
  String get bundleUltimatePackDesc;

  /// No description provided for @skinClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get skinClassic;

  /// No description provided for @skinGolden.
  ///
  /// In en, this message translates to:
  /// **'Golden Snake'**
  String get skinGolden;

  /// No description provided for @skinRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow Snake'**
  String get skinRainbow;

  /// No description provided for @skinGalaxy.
  ///
  /// In en, this message translates to:
  /// **'Galaxy Snake'**
  String get skinGalaxy;

  /// No description provided for @skinDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon Snake'**
  String get skinDragon;

  /// No description provided for @skinElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric Snake'**
  String get skinElectric;

  /// No description provided for @skinFire.
  ///
  /// In en, this message translates to:
  /// **'Fire Snake'**
  String get skinFire;

  /// No description provided for @skinIce.
  ///
  /// In en, this message translates to:
  /// **'Ice Snake'**
  String get skinIce;

  /// No description provided for @skinShadow.
  ///
  /// In en, this message translates to:
  /// **'Shadow Snake'**
  String get skinShadow;

  /// No description provided for @skinNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon Snake'**
  String get skinNeon;

  /// No description provided for @skinCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal Snake'**
  String get skinCrystal;

  /// No description provided for @skinCosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Snake'**
  String get skinCosmic;

  /// No description provided for @skinClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The original snake appearance'**
  String get skinClassicDesc;

  /// No description provided for @skinGoldenDesc.
  ///
  /// In en, this message translates to:
  /// **'Gleaming gold snake that shines with every move'**
  String get skinGoldenDesc;

  /// No description provided for @skinRainbowDesc.
  ///
  /// In en, this message translates to:
  /// **'A colorful snake that shifts through rainbow colors'**
  String get skinRainbowDesc;

  /// No description provided for @skinGalaxyDesc.
  ///
  /// In en, this message translates to:
  /// **'Cosmic snake with starry patterns'**
  String get skinGalaxyDesc;

  /// No description provided for @skinDragonDesc.
  ///
  /// In en, this message translates to:
  /// **'Fierce dragon-scaled snake with mystical powers'**
  String get skinDragonDesc;

  /// No description provided for @skinElectricDesc.
  ///
  /// In en, this message translates to:
  /// **'Crackling with electric energy'**
  String get skinElectricDesc;

  /// No description provided for @skinFireDesc.
  ///
  /// In en, this message translates to:
  /// **'Burning bright with fiery patterns'**
  String get skinFireDesc;

  /// No description provided for @skinIceDesc.
  ///
  /// In en, this message translates to:
  /// **'Frozen beauty with crystalline effects'**
  String get skinIceDesc;

  /// No description provided for @skinShadowDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark and mysterious shadow snake'**
  String get skinShadowDesc;

  /// No description provided for @skinNeonDesc.
  ///
  /// In en, this message translates to:
  /// **'Glowing with cyberpunk neon lights'**
  String get skinNeonDesc;

  /// No description provided for @skinCrystalDesc.
  ///
  /// In en, this message translates to:
  /// **'Translucent crystal snake with prismatic effects'**
  String get skinCrystalDesc;

  /// No description provided for @skinCosmicDesc.
  ///
  /// In en, this message translates to:
  /// **'Snake made of stardust and cosmic matter'**
  String get skinCosmicDesc;

  /// No description provided for @trailNone.
  ///
  /// In en, this message translates to:
  /// **'No Trail'**
  String get trailNone;

  /// No description provided for @trailParticle.
  ///
  /// In en, this message translates to:
  /// **'Particle Trail'**
  String get trailParticle;

  /// No description provided for @trailGlow.
  ///
  /// In en, this message translates to:
  /// **'Glow Trail'**
  String get trailGlow;

  /// No description provided for @trailRainbow.
  ///
  /// In en, this message translates to:
  /// **'Rainbow Trail'**
  String get trailRainbow;

  /// No description provided for @trailFire.
  ///
  /// In en, this message translates to:
  /// **'Fire Trail'**
  String get trailFire;

  /// No description provided for @trailElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric Trail'**
  String get trailElectric;

  /// No description provided for @trailStar.
  ///
  /// In en, this message translates to:
  /// **'Star Trail'**
  String get trailStar;

  /// No description provided for @trailCosmic.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Trail'**
  String get trailCosmic;

  /// No description provided for @trailNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon Trail'**
  String get trailNeon;

  /// No description provided for @trailShadow.
  ///
  /// In en, this message translates to:
  /// **'Shadow Trail'**
  String get trailShadow;

  /// No description provided for @trailCrystal.
  ///
  /// In en, this message translates to:
  /// **'Crystal Trail'**
  String get trailCrystal;

  /// No description provided for @trailDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon Trail'**
  String get trailDragon;

  /// No description provided for @trailNoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Clean snake with no trail effects'**
  String get trailNoneDesc;

  /// No description provided for @trailParticleDesc.
  ///
  /// In en, this message translates to:
  /// **'Leaves a trail of sparkling particles'**
  String get trailParticleDesc;

  /// No description provided for @trailGlowDesc.
  ///
  /// In en, this message translates to:
  /// **'Glowing trail that fades behind the snake'**
  String get trailGlowDesc;

  /// No description provided for @trailRainbowDesc.
  ///
  /// In en, this message translates to:
  /// **'Colorful rainbow trail effect'**
  String get trailRainbowDesc;

  /// No description provided for @trailFireDesc.
  ///
  /// In en, this message translates to:
  /// **'Blazing fire trail with ember particles'**
  String get trailFireDesc;

  /// No description provided for @trailElectricDesc.
  ///
  /// In en, this message translates to:
  /// **'Crackling electric trail with lightning effects'**
  String get trailElectricDesc;

  /// No description provided for @trailStarDesc.
  ///
  /// In en, this message translates to:
  /// **'Twinkling stars follow the snake\'s path'**
  String get trailStarDesc;

  /// No description provided for @trailCosmicDesc.
  ///
  /// In en, this message translates to:
  /// **'Cosmic dust and nebula effects'**
  String get trailCosmicDesc;

  /// No description provided for @trailNeonDesc.
  ///
  /// In en, this message translates to:
  /// **'Bright neon glow with cyberpunk style'**
  String get trailNeonDesc;

  /// No description provided for @trailShadowDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark shadow trail with smoky effects'**
  String get trailShadowDesc;

  /// No description provided for @trailCrystalDesc.
  ///
  /// In en, this message translates to:
  /// **'Crystalline shards that fade away'**
  String get trailCrystalDesc;

  /// No description provided for @trailDragonDesc.
  ///
  /// In en, this message translates to:
  /// **'Mystical dragon breath trail'**
  String get trailDragonDesc;

  /// No description provided for @coinPackSmall.
  ///
  /// In en, this message translates to:
  /// **'Starter Pack'**
  String get coinPackSmall;

  /// No description provided for @coinPackMedium.
  ///
  /// In en, this message translates to:
  /// **'Value Pack'**
  String get coinPackMedium;

  /// No description provided for @coinPackLarge.
  ///
  /// In en, this message translates to:
  /// **'Premium Pack'**
  String get coinPackLarge;

  /// No description provided for @coinPackMega.
  ///
  /// In en, this message translates to:
  /// **'Ultimate Pack'**
  String get coinPackMega;

  /// No description provided for @coinsAmount.
  ///
  /// In en, this message translates to:
  /// **'{coins} coins'**
  String coinsAmount(Object coins);

  /// No description provided for @coinsAmountBonus.
  ///
  /// In en, this message translates to:
  /// **'{coins} + {bonus} bonus'**
  String coinsAmountBonus(Object coins, Object bonus);

  /// No description provided for @boardSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get boardSmall;

  /// No description provided for @boardClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get boardClassic;

  /// No description provided for @boardLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get boardLarge;

  /// No description provided for @boardHuge.
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get boardHuge;

  /// No description provided for @boardEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get boardEpic;

  /// No description provided for @boardMassive.
  ///
  /// In en, this message translates to:
  /// **'Massive'**
  String get boardMassive;

  /// No description provided for @boardUltimate.
  ///
  /// In en, this message translates to:
  /// **'Ultimate'**
  String get boardUltimate;

  /// No description provided for @boardSmallDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick games, tight spaces'**
  String get boardSmallDesc;

  /// No description provided for @boardClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The original Snake experience'**
  String get boardClassicDesc;

  /// No description provided for @boardLargeDesc.
  ///
  /// In en, this message translates to:
  /// **'More room to grow'**
  String get boardLargeDesc;

  /// No description provided for @boardHugeDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum challenge and space'**
  String get boardHugeDesc;

  /// No description provided for @boardEpicDesc.
  ///
  /// In en, this message translates to:
  /// **'A big board for advanced players'**
  String get boardEpicDesc;

  /// No description provided for @boardMassiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Enormous board for epic games'**
  String get boardMassiveDesc;

  /// No description provided for @boardUltimateDesc.
  ///
  /// In en, this message translates to:
  /// **'The largest possible board'**
  String get boardUltimateDesc;

  /// No description provided for @crashLabelSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get crashLabelSkip;

  /// No description provided for @crashLabelUntilTap.
  ///
  /// In en, this message translates to:
  /// **'Until Tap'**
  String get crashLabelUntilTap;

  /// No description provided for @tgmClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get tgmClassic;

  /// No description provided for @tgmSpeedRun.
  ///
  /// In en, this message translates to:
  /// **'Speed Run'**
  String get tgmSpeedRun;

  /// No description provided for @tgmSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get tgmSurvival;

  /// No description provided for @tgmNoWalls.
  ///
  /// In en, this message translates to:
  /// **'No Walls'**
  String get tgmNoWalls;

  /// No description provided for @tgmPowerUpMadness.
  ///
  /// In en, this message translates to:
  /// **'Power-up Madness'**
  String get tgmPowerUpMadness;

  /// No description provided for @tgmPerfectGame.
  ///
  /// In en, this message translates to:
  /// **'Perfect Game'**
  String get tgmPerfectGame;

  /// No description provided for @tgmClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard Snake game rules'**
  String get tgmClassicDesc;

  /// No description provided for @tgmSpeedRunDesc.
  ///
  /// In en, this message translates to:
  /// **'Game speed increases rapidly'**
  String get tgmSpeedRunDesc;

  /// No description provided for @tgmSurvivalDesc.
  ///
  /// In en, this message translates to:
  /// **'Survive as long as possible'**
  String get tgmSurvivalDesc;

  /// No description provided for @tgmNoWallsDesc.
  ///
  /// In en, this message translates to:
  /// **'Snake wraps around screen edges'**
  String get tgmNoWallsDesc;

  /// No description provided for @tgmPowerUpMadnessDesc.
  ///
  /// In en, this message translates to:
  /// **'Frequent power-ups spawn'**
  String get tgmPowerUpMadnessDesc;

  /// No description provided for @tgmPerfectGameDesc.
  ///
  /// In en, this message translates to:
  /// **'No mistakes allowed - one hit ends game'**
  String get tgmPerfectGameDesc;

  /// No description provided for @ttDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get ttDaily;

  /// No description provided for @ttWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Tournament'**
  String get ttWeekly;

  /// No description provided for @ttSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special Event'**
  String get ttSpecial;

  /// No description provided for @tsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tsUpcoming;

  /// No description provided for @tsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tsActive;

  /// No description provided for @tsEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get tsEnded;

  /// No description provided for @cdEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get cdEasy;

  /// No description provided for @cdMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cdMedium;

  /// No description provided for @cdHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get cdHard;

  /// No description provided for @usOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get usOnline;

  /// No description provided for @usOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get usOffline;

  /// No description provided for @usPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get usPlaying;

  /// No description provided for @bprXpBoost.
  ///
  /// In en, this message translates to:
  /// **'XP Boost'**
  String get bprXpBoost;

  /// No description provided for @bprCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get bprCoins;

  /// No description provided for @bprTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get bprTheme;

  /// No description provided for @bprSkin.
  ///
  /// In en, this message translates to:
  /// **'Snake Skin'**
  String get bprSkin;

  /// No description provided for @bprTrail.
  ///
  /// In en, this message translates to:
  /// **'Trail Effect'**
  String get bprTrail;

  /// No description provided for @bprPowerUp.
  ///
  /// In en, this message translates to:
  /// **'Power-Up'**
  String get bprPowerUp;

  /// No description provided for @bprTournamentEntry.
  ///
  /// In en, this message translates to:
  /// **'Tournament Entry'**
  String get bprTournamentEntry;

  /// No description provided for @bprTitle.
  ///
  /// In en, this message translates to:
  /// **'Player Title'**
  String get bprTitle;

  /// No description provided for @bprAvatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get bprAvatar;

  /// No description provided for @bprSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special Reward'**
  String get bprSpecial;

  /// No description provided for @bprFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get bprFree;

  /// No description provided for @bprPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get bprPremium;

  /// No description provided for @bprnStarDust.
  ///
  /// In en, this message translates to:
  /// **'Star Dust'**
  String get bprnStarDust;

  /// No description provided for @bprnEnergyPack.
  ///
  /// In en, this message translates to:
  /// **'Energy Pack'**
  String get bprnEnergyPack;

  /// No description provided for @bprnBronzeEntry.
  ///
  /// In en, this message translates to:
  /// **'Bronze Entry'**
  String get bprnBronzeEntry;

  /// No description provided for @bprnSilverEntry.
  ///
  /// In en, this message translates to:
  /// **'Silver Entry'**
  String get bprnSilverEntry;

  /// No description provided for @bprnStargazer.
  ///
  /// In en, this message translates to:
  /// **'Stargazer'**
  String get bprnStargazer;

  /// No description provided for @bprnVoyager.
  ///
  /// In en, this message translates to:
  /// **'Voyager'**
  String get bprnVoyager;

  /// No description provided for @bprnNebulaTheme.
  ///
  /// In en, this message translates to:
  /// **'Nebula Theme'**
  String get bprnNebulaTheme;

  /// No description provided for @bprnStardustTrail.
  ///
  /// In en, this message translates to:
  /// **'Stardust Trail'**
  String get bprnStardustTrail;

  /// No description provided for @bprnLegendaryCrate.
  ///
  /// In en, this message translates to:
  /// **'Legendary Crate'**
  String get bprnLegendaryCrate;

  /// No description provided for @bprnMegaXp.
  ///
  /// In en, this message translates to:
  /// **'Mega XP'**
  String get bprnMegaXp;

  /// No description provided for @bprnCosmicCharge.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Charge'**
  String get bprnCosmicCharge;

  /// No description provided for @bprnNovaBurst.
  ///
  /// In en, this message translates to:
  /// **'Nova Burst'**
  String get bprnNovaBurst;

  /// No description provided for @bprnGalaxySkin.
  ///
  /// In en, this message translates to:
  /// **'Galaxy Skin'**
  String get bprnGalaxySkin;

  /// No description provided for @bprnCrystalSerpent.
  ///
  /// In en, this message translates to:
  /// **'Crystal Serpent'**
  String get bprnCrystalSerpent;

  /// No description provided for @bprnPlasmaWake.
  ///
  /// In en, this message translates to:
  /// **'Plasma Wake'**
  String get bprnPlasmaWake;

  /// No description provided for @bprnCosmicAura.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Aura'**
  String get bprnCosmicAura;

  /// No description provided for @bprnCyberpunkTheme.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk Theme'**
  String get bprnCyberpunkTheme;

  /// No description provided for @bprnCrystalTheme.
  ///
  /// In en, this message translates to:
  /// **'Crystal Theme'**
  String get bprnCrystalTheme;

  /// No description provided for @bprnSeasonTrophy.
  ///
  /// In en, this message translates to:
  /// **'Season Trophy'**
  String get bprnSeasonTrophy;

  /// No description provided for @bprnCosmicCrown.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Crown'**
  String get bprnCosmicCrown;

  /// No description provided for @bprnCosmicLegend.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Legend'**
  String get bprnCosmicLegend;

  /// No description provided for @bprnStarCommander.
  ///
  /// In en, this message translates to:
  /// **'Star Commander'**
  String get bprnStarCommander;

  /// No description provided for @bpRewardQtyCoins.
  ///
  /// In en, this message translates to:
  /// **'{quantity} Coins'**
  String bpRewardQtyCoins(Object quantity);

  /// No description provided for @bpRewardTypeQty.
  ///
  /// In en, this message translates to:
  /// **'{type} x{quantity}'**
  String bpRewardTypeQty(Object type, Object quantity);

  /// No description provided for @bpRewardDescFree.
  ///
  /// In en, this message translates to:
  /// **'Free {type} reward'**
  String bpRewardDescFree(Object type);

  /// No description provided for @bpRewardDescPremium.
  ///
  /// In en, this message translates to:
  /// **'Exclusive premium {type} reward'**
  String bpRewardDescPremium(Object type);

  /// No description provided for @insHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get insHowToPlay;

  /// No description provided for @insObjective.
  ///
  /// In en, this message translates to:
  /// **'OBJECTIVE'**
  String get insObjective;

  /// No description provided for @insObjectiveBody.
  ///
  /// In en, this message translates to:
  /// **'Control the snake to eat food and grow as long as possible without hitting walls or yourself!'**
  String get insObjectiveBody;

  /// No description provided for @insControls.
  ///
  /// In en, this message translates to:
  /// **'CONTROLS'**
  String get insControls;

  /// No description provided for @insSwipeUp.
  ///
  /// In en, this message translates to:
  /// **'Swipe Up ↑'**
  String get insSwipeUp;

  /// No description provided for @insSwipeUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Move snake up'**
  String get insSwipeUpDesc;

  /// No description provided for @insSwipeDown.
  ///
  /// In en, this message translates to:
  /// **'Swipe Down ↓'**
  String get insSwipeDown;

  /// No description provided for @insSwipeDownDesc.
  ///
  /// In en, this message translates to:
  /// **'Move snake down'**
  String get insSwipeDownDesc;

  /// No description provided for @insSwipeLeft.
  ///
  /// In en, this message translates to:
  /// **'Swipe Left ←'**
  String get insSwipeLeft;

  /// No description provided for @insSwipeLeftDesc.
  ///
  /// In en, this message translates to:
  /// **'Move snake left'**
  String get insSwipeLeftDesc;

  /// No description provided for @insSwipeRight.
  ///
  /// In en, this message translates to:
  /// **'Swipe Right →'**
  String get insSwipeRight;

  /// No description provided for @insSwipeRightDesc.
  ///
  /// In en, this message translates to:
  /// **'Move snake right'**
  String get insSwipeRightDesc;

  /// No description provided for @insTapScreen.
  ///
  /// In en, this message translates to:
  /// **'Tap Screen'**
  String get insTapScreen;

  /// No description provided for @insTapScreenDesc.
  ///
  /// In en, this message translates to:
  /// **'Pause/Resume game'**
  String get insTapScreenDesc;

  /// No description provided for @insArrowKeys.
  ///
  /// In en, this message translates to:
  /// **'Arrow Keys (Desktop)'**
  String get insArrowKeys;

  /// No description provided for @insArrowKeysDesc.
  ///
  /// In en, this message translates to:
  /// **'Change direction'**
  String get insArrowKeysDesc;

  /// No description provided for @insWasd.
  ///
  /// In en, this message translates to:
  /// **'WASD (Desktop)'**
  String get insWasd;

  /// No description provided for @insWasdDesc.
  ///
  /// In en, this message translates to:
  /// **'Change direction'**
  String get insWasdDesc;

  /// No description provided for @insSpacebar.
  ///
  /// In en, this message translates to:
  /// **'Spacebar (Desktop)'**
  String get insSpacebar;

  /// No description provided for @insSpacebarDesc.
  ///
  /// In en, this message translates to:
  /// **'Pause/Resume game'**
  String get insSpacebarDesc;

  /// No description provided for @insFoodTypes.
  ///
  /// In en, this message translates to:
  /// **'FOOD TYPES'**
  String get insFoodTypes;

  /// No description provided for @insNormalFood.
  ///
  /// In en, this message translates to:
  /// **'Normal Food'**
  String get insNormalFood;

  /// No description provided for @insBonusFood.
  ///
  /// In en, this message translates to:
  /// **'Bonus Food'**
  String get insBonusFood;

  /// No description provided for @insSpecialFood.
  ///
  /// In en, this message translates to:
  /// **'Special Food'**
  String get insSpecialFood;

  /// No description provided for @insRules.
  ///
  /// In en, this message translates to:
  /// **'RULES'**
  String get insRules;

  /// No description provided for @insRule1.
  ///
  /// In en, this message translates to:
  /// **'• Eat food to grow and increase score'**
  String get insRule1;

  /// No description provided for @insRule2.
  ///
  /// In en, this message translates to:
  /// **'• Snake speeds up as you level up'**
  String get insRule2;

  /// No description provided for @insRule3.
  ///
  /// In en, this message translates to:
  /// **'• Game ends if you hit walls or yourself'**
  String get insRule3;

  /// No description provided for @insRule4.
  ///
  /// In en, this message translates to:
  /// **'• Special food appears every 10 normal foods'**
  String get insRule4;

  /// No description provided for @insRule5.
  ///
  /// In en, this message translates to:
  /// **'• Bonus food expires after 15 seconds'**
  String get insRule5;

  /// No description provided for @insProTips.
  ///
  /// In en, this message translates to:
  /// **'PRO TIPS'**
  String get insProTips;

  /// No description provided for @insTip1.
  ///
  /// In en, this message translates to:
  /// **'Plan your moves ahead of time'**
  String get insTip1;

  /// No description provided for @insTip2.
  ///
  /// In en, this message translates to:
  /// **'Use edges to create safe spaces'**
  String get insTip2;

  /// No description provided for @insTip3.
  ///
  /// In en, this message translates to:
  /// **'Watch for visual swipe feedback'**
  String get insTip3;

  /// No description provided for @insTip4.
  ///
  /// In en, this message translates to:
  /// **'Practice different difficulty levels'**
  String get insTip4;

  /// No description provided for @insBackToGame.
  ///
  /// In en, this message translates to:
  /// **'BACK TO GAME'**
  String get insBackToGame;

  /// No description provided for @dchClaimedReward.
  ///
  /// In en, this message translates to:
  /// **'Claimed {coins} coins and {xp} XP!'**
  String dchClaimedReward(Object coins, Object xp);

  /// No description provided for @dchClaimedCoins.
  ///
  /// In en, this message translates to:
  /// **'Claimed {coins} coins!'**
  String dchClaimedCoins(Object coins);

  /// No description provided for @dchWatchTo2x.
  ///
  /// In en, this message translates to:
  /// **'WATCH TO 2×'**
  String get dchWatchTo2x;

  /// No description provided for @dchDoubledBonus.
  ///
  /// In en, this message translates to:
  /// **'🎉 Doubled! +{coins} bonus coins!'**
  String dchDoubledBonus(Object coins);

  /// No description provided for @dchClaimAll.
  ///
  /// In en, this message translates to:
  /// **'Claim All'**
  String get dchClaimAll;

  /// No description provided for @dchTodaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get dchTodaysProgress;

  /// No description provided for @dchClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get dchClaim;

  /// No description provided for @dchClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get dchClaimed;

  /// No description provided for @dchAllCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'All Challenges Complete!'**
  String get dchAllCompleteTitle;

  /// No description provided for @dchBonusClaimed.
  ///
  /// In en, this message translates to:
  /// **'Bonus reward claimed'**
  String get dchBonusClaimed;

  /// No description provided for @dchBonusPending.
  ///
  /// In en, this message translates to:
  /// **'Bonus reward pending — claim any challenge'**
  String get dchBonusPending;

  /// No description provided for @dchLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading challenges...'**
  String get dchLoading;

  /// No description provided for @dchCheckBack.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new daily challenges!'**
  String get dchCheckBack;

  /// No description provided for @dchAbout.
  ///
  /// In en, this message translates to:
  /// **'About Daily Challenges'**
  String get dchAbout;

  /// No description provided for @dchAbout1.
  ///
  /// In en, this message translates to:
  /// **'New challenges every day at midnight'**
  String get dchAbout1;

  /// No description provided for @dchAbout2.
  ///
  /// In en, this message translates to:
  /// **'Complete challenges to earn coins'**
  String get dchAbout2;

  /// No description provided for @dchAbout3.
  ///
  /// In en, this message translates to:
  /// **'Gain XP to level up your profile'**
  String get dchAbout3;

  /// No description provided for @dchAbout4.
  ///
  /// In en, this message translates to:
  /// **'Complete all 3 for a bonus reward!'**
  String get dchAbout4;

  /// No description provided for @dchAllBonusTitle.
  ///
  /// In en, this message translates to:
  /// **'All Challenges Bonus'**
  String get dchAllBonusTitle;

  /// No description provided for @dchAllBonusDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed every daily challenge today.'**
  String get dchAllBonusDesc;

  /// No description provided for @wqNoQuests.
  ///
  /// In en, this message translates to:
  /// **'No weekly quests yet — check back Monday'**
  String get wqNoQuests;

  /// No description provided for @wqTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Quests'**
  String get wqTitle;

  /// No description provided for @wqClaimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim Reward'**
  String get wqClaimReward;

  /// No description provided for @rvNotFound.
  ///
  /// In en, this message translates to:
  /// **'Replay not found'**
  String get rvNotFound;

  /// No description provided for @rvLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load replay'**
  String get rvLoadFailed;

  /// No description provided for @rvTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay: {name}'**
  String rvTitle(Object name);

  /// No description provided for @rvLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading Replay...'**
  String get rvLoadingTitle;

  /// No description provided for @rvLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading replay...'**
  String get rvLoading;

  /// No description provided for @rvGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get rvGoBack;

  /// No description provided for @rvScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get rvScore;

  /// No description provided for @rvLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get rvLevel;

  /// No description provided for @rvFrame.
  ///
  /// In en, this message translates to:
  /// **'Frame'**
  String get rvFrame;

  /// No description provided for @rvTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get rvTime;

  /// No description provided for @rvNoFrameData.
  ///
  /// In en, this message translates to:
  /// **'No frame data'**
  String get rvNoFrameData;

  /// No description provided for @rvSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed: '**
  String get rvSpeedLabel;

  /// No description provided for @rvAteFood.
  ///
  /// In en, this message translates to:
  /// **'🍎 Ate {type} food'**
  String rvAteFood(Object type);

  /// No description provided for @rvCollectedPowerUp.
  ///
  /// In en, this message translates to:
  /// **'⚡ Collected {type} power-up'**
  String rvCollectedPowerUp(Object type);

  /// No description provided for @unEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get unEmpty;

  /// No description provided for @unSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set username'**
  String get unSetFailed;

  /// No description provided for @unPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your username'**
  String get unPickTitle;

  /// No description provided for @unPickBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s how you\'ll show up on the leaderboard. We\'ve picked one for you — keep it or change it.'**
  String get unPickBody;

  /// No description provided for @unLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get unLabel;

  /// No description provided for @unSaving.
  ///
  /// In en, this message translates to:
  /// **'SAVING...'**
  String get unSaving;

  /// No description provided for @unContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get unContinue;

  /// No description provided for @unChangeAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get unChangeAnytime;

  /// No description provided for @unMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {min} characters long'**
  String unMinLength(Object min);

  /// No description provided for @unMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be no more than {max} characters long'**
  String unMaxLength(Object max);

  /// No description provided for @unPattern.
  ///
  /// In en, this message translates to:
  /// **'Username must start with a letter and contain only letters, numbers, and underscores'**
  String get unPattern;

  /// No description provided for @unReserved.
  ///
  /// In en, this message translates to:
  /// **'This username is reserved and cannot be used'**
  String get unReserved;

  /// No description provided for @unTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get unTaken;

  /// No description provided for @unUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update username'**
  String get unUpdateFailed;

  /// No description provided for @pcTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms Updated'**
  String get pcTitle;

  /// No description provided for @pcVersionLine.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · please review and accept to continue'**
  String pcVersionLine(Object version);

  /// No description provided for @pcTabPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get pcTabPrivacy;

  /// No description provided for @pcTabTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get pcTabTerms;

  /// No description provided for @pcAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the updated Privacy Policy and Terms of Use'**
  String get pcAgree;

  /// No description provided for @pcContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pcContinue;

  /// No description provided for @lgAvailableAt.
  ///
  /// In en, this message translates to:
  /// **'This document is available at {url}.'**
  String lgAvailableAt(Object url);

  /// No description provided for @lgUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This document is currently unavailable. Please try again later.'**
  String get lgUnavailable;

  /// No description provided for @auTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to make purchases'**
  String get auTitle;

  /// No description provided for @auBody.
  ///
  /// In en, this message translates to:
  /// **'Guest accounts can play and save progress locally, but cannot buy items or subscribe. Link a Google or email account to unlock purchases — your existing coins, cosmetics, and high scores stay attached.'**
  String get auBody;

  /// No description provided for @auGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auGoogle;

  /// No description provided for @auGoogleSub.
  ///
  /// In en, this message translates to:
  /// **'Fastest option. Sign in with your Google account.'**
  String get auGoogleSub;

  /// No description provided for @auLinked.
  ///
  /// In en, this message translates to:
  /// **'Account linked. You can now make purchases.'**
  String get auLinked;

  /// No description provided for @auEmail.
  ///
  /// In en, this message translates to:
  /// **'Create an Email Account'**
  String get auEmail;

  /// No description provided for @auEmailSub.
  ///
  /// In en, this message translates to:
  /// **'Use any email and a password you choose. Restore on any device.'**
  String get auEmailSub;

  /// No description provided for @auNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get auNotNow;

  /// No description provided for @auErrCredentialInUse.
  ///
  /// In en, this message translates to:
  /// **'That credential is already linked to another account. Try signing in with it instead.'**
  String get auErrCredentialInUse;

  /// No description provided for @auErrAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This account is already linked.'**
  String get auErrAlreadyLinked;

  /// No description provided for @auErrRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again before linking.'**
  String get auErrRequiresRecentLogin;

  /// No description provided for @auErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get auErrNetwork;

  /// No description provided for @auErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Linking failed. Please try again.'**
  String get auErrGeneric;

  /// No description provided for @sroSettingUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting up your account…'**
  String get sroSettingUpTitle;

  /// No description provided for @sroSettingUpBody.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready for your first session. This only happens once.'**
  String get sroSettingUpBody;

  /// No description provided for @sroLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your previous data…'**
  String get sroLoadingTitle;

  /// No description provided for @sroLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Fetching your stats, achievements, coins, and unlocks from the cloud.'**
  String get sroLoadingBody;

  /// No description provided for @sroRestoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoring your progress…'**
  String get sroRestoringTitle;

  /// No description provided for @sroRestoringBody.
  ///
  /// In en, this message translates to:
  /// **'Applying everything to this device. Don\'t close the app.'**
  String get sroRestoringBody;

  /// No description provided for @sroDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'All set!'**
  String get sroDoneTitle;

  /// No description provided for @sroDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress has been restored.'**
  String get sroDoneBody;

  /// No description provided for @sroFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore your data'**
  String get sroFailedTitle;

  /// No description provided for @sroFailedBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reach the cloud just now. Check your internet connection and try again. You can also continue without restoring — we\'ll retry the next time you open the app.'**
  String get sroFailedBody;

  /// No description provided for @sroTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get sroTryAgain;

  /// No description provided for @sroContinueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get sroContinueAnyway;

  /// No description provided for @ssiOfflinePending.
  ///
  /// In en, this message translates to:
  /// **'Offline - Changes will sync when connected'**
  String get ssiOfflinePending;

  /// No description provided for @ssiSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get ssiSyncing;

  /// No description provided for @ssiAllSynced.
  ///
  /// In en, this message translates to:
  /// **'All data synced'**
  String get ssiAllSynced;

  /// No description provided for @ssiFailedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item failed to sync} other{{count} items failed to sync}}'**
  String ssiFailedCount(num count);

  /// No description provided for @ssiPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item pending sync} other{{count} items pending sync}}'**
  String ssiPendingCount(num count);

  /// No description provided for @ssiOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get ssiOffline;

  /// No description provided for @rvoContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE?'**
  String get rvoContinue;

  /// No description provided for @rvoSubtitlePro.
  ///
  /// In en, this message translates to:
  /// **'Revive and keep your score · Free with Pro'**
  String get rvoSubtitlePro;

  /// No description provided for @rvoSubtitleTimer.
  ///
  /// In en, this message translates to:
  /// **'Revive and keep your score · {seconds}s'**
  String rvoSubtitleTimer(Object seconds);

  /// No description provided for @rvoGetLifePro.
  ///
  /// In en, this message translates to:
  /// **'Get Life · Free for Pro'**
  String get rvoGetLifePro;

  /// No description provided for @rvoWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad to revive'**
  String get rvoWatchAd;

  /// No description provided for @rvoUseCoins.
  ///
  /// In en, this message translates to:
  /// **'Use {coins} coins'**
  String rvoUseCoins(Object coins);

  /// No description provided for @rvoNoThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get rvoNoThanks;

  /// No description provided for @tbTimesUp.
  ///
  /// In en, this message translates to:
  /// **'TIME\'S UP!'**
  String get tbTimesUp;

  /// No description provided for @tbKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going · {seconds}s'**
  String tbKeepGoing(Object seconds);

  /// No description provided for @tbWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad — +{seconds}s'**
  String tbWatchAd(Object seconds);

  /// No description provided for @tbEndRun.
  ///
  /// In en, this message translates to:
  /// **'End run'**
  String get tbEndRun;

  /// No description provided for @dbTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Bonus'**
  String get dbTitle;

  /// No description provided for @dbClaimToday.
  ///
  /// In en, this message translates to:
  /// **'Claim your daily reward!'**
  String get dbClaimToday;

  /// No description provided for @dbComeBack.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow!'**
  String get dbComeBack;

  /// No description provided for @dbDayChip.
  ///
  /// In en, this message translates to:
  /// **'D{day}'**
  String dbDayChip(Object day);

  /// No description provided for @dbTodaysReward.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reward'**
  String get dbTodaysReward;

  /// No description provided for @dbAlreadyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Already claimed today'**
  String get dbAlreadyClaimed;

  /// No description provided for @dbClaim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM REWARD'**
  String get dbClaim;

  /// No description provided for @dbClaim2x.
  ///
  /// In en, this message translates to:
  /// **'CLAIM 2× — WATCH AD'**
  String get dbClaim2x;

  /// No description provided for @npPrimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out!'**
  String get npPrimerTitle;

  /// No description provided for @npPrimerBody.
  ///
  /// In en, this message translates to:
  /// **'We only send a couple of notifications a day — your daily challenge reminder and special events.\n\nNo spam, promise. 🐍'**
  String get npPrimerBody;

  /// No description provided for @npMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get npMaybeLater;

  /// No description provided for @npAllSet.
  ///
  /// In en, this message translates to:
  /// **'🎉 You\'re all set!'**
  String get npAllSet;

  /// No description provided for @npTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get npTurnOn;

  /// No description provided for @npSoftTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop?'**
  String get npSoftTitle;

  /// No description provided for @npSoftBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications and we\'ll remind you about your daily challenges and streaks — plus the big stuff like FREE Premium giveaways and special events.\n\nJust a couple a day, no spam. 🐍'**
  String get npSoftBody;

  /// No description provided for @npNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get npNotNow;

  /// No description provided for @npEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get npEnable;

  /// No description provided for @aroUnlocked.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT UNLOCKED'**
  String get aroUnlocked;

  /// No description provided for @aroTapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get aroTapToContinue;

  /// No description provided for @aroSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get aroSkip;

  /// No description provided for @aroSkipCount.
  ///
  /// In en, this message translates to:
  /// **'SKIP ({count})'**
  String aroSkipCount(Object count);

  /// No description provided for @luLevelUp.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get luLevelUp;

  /// No description provided for @luReached.
  ///
  /// In en, this message translates to:
  /// **'You reached Level {level}'**
  String luReached(Object level);

  /// No description provided for @luNice.
  ///
  /// In en, this message translates to:
  /// **'NICE'**
  String get luNice;

  /// No description provided for @cfTapContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to continue'**
  String get cfTapContinue;

  /// No description provided for @cfTapSkip.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to skip'**
  String get cfTapSkip;

  /// No description provided for @ppgLvShort.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String ppgLvShort(Object level);

  /// No description provided for @ppgLvUpper.
  ///
  /// In en, this message translates to:
  /// **'LV {level}'**
  String ppgLvUpper(Object level);

  /// No description provided for @ppgLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String ppgLevel(Object level);

  /// No description provided for @xgTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get xgTitle;

  /// No description provided for @xgBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your current progress will be lost.'**
  String get xgBody;

  /// No description provided for @xgExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get xgExit;

  /// No description provided for @ccTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to play?'**
  String get ccTitle;

  /// No description provided for @ccBody.
  ///
  /// In en, this message translates to:
  /// **'Pick one — you can change it anytime in Settings → Controls.'**
  String get ccBody;

  /// No description provided for @ccSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe Gestures'**
  String get ccSwipe;

  /// No description provided for @ccSwipeSub.
  ///
  /// In en, this message translates to:
  /// **'Swipe anywhere on the board to turn.'**
  String get ccSwipeSub;

  /// No description provided for @ccDpad.
  ///
  /// In en, this message translates to:
  /// **'D-Pad Controls'**
  String get ccDpad;

  /// No description provided for @ccDpadSub.
  ///
  /// In en, this message translates to:
  /// **'On-screen directional buttons.'**
  String get ccDpadSub;

  /// No description provided for @rcCoinsAdded.
  ///
  /// In en, this message translates to:
  /// **'🎉 +{coins} coins added to your wallet!'**
  String rcCoinsAdded(Object coins);

  /// No description provided for @rcWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad — +{coins} coins'**
  String rcWatchAd(Object coins);

  /// No description provided for @rcNoAd.
  ///
  /// In en, this message translates to:
  /// **'No ad available right now'**
  String get rcNoAd;

  /// No description provided for @raOptIn.
  ///
  /// In en, this message translates to:
  /// **'Opt-in — watch to earn'**
  String get raOptIn;

  /// No description provided for @compassSemantics.
  ///
  /// In en, this message translates to:
  /// **'Swipe direction indicator'**
  String get compassSemantics;

  /// No description provided for @homeBonusDoubled.
  ///
  /// In en, this message translates to:
  /// **'🎉 Daily bonus doubled — +{coins} bonus coins!'**
  String homeBonusDoubled(Object coins);

  /// No description provided for @nsNewNotification.
  ///
  /// In en, this message translates to:
  /// **'You have a new notification'**
  String get nsNewNotification;

  /// No description provided for @nsAchievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'🏆 Achievement Unlocked!'**
  String get nsAchievementUnlocked;

  /// No description provided for @nsDailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'🐍 Time to play Snake Classic!'**
  String get nsDailyReminderTitle;

  /// No description provided for @nsDailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your daily challenge and climb the leaderboard!'**
  String get nsDailyReminderBody;

  /// No description provided for @mpErrMatchmaking.
  ///
  /// In en, this message translates to:
  /// **'Matchmaking failed. Please try again.'**
  String get mpErrMatchmaking;

  /// No description provided for @mpErrCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create game'**
  String get mpErrCreateFailed;

  /// No description provided for @mpErrJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join game. Game might be full or not exist.'**
  String get mpErrJoinFailed;

  /// No description provided for @mpErrReadyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update ready status'**
  String get mpErrReadyFailed;

  /// No description provided for @mpErrStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start game'**
  String get mpErrStartFailed;

  /// No description provided for @mpErrStartTimeout.
  ///
  /// In en, this message translates to:
  /// **'Start game timed out. Please try again.'**
  String get mpErrStartTimeout;

  /// No description provided for @mpErrReconnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reconnect to the match.'**
  String get mpErrReconnectFailed;

  /// No description provided for @mpErrConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost — the match could not be resumed.'**
  String get mpErrConnectionLost;

  /// No description provided for @mpErrMatchEndedAway.
  ///
  /// In en, this message translates to:
  /// **'The match ended while you were away.'**
  String get mpErrMatchEndedAway;

  /// No description provided for @mpErrWaitingReady.
  ///
  /// In en, this message translates to:
  /// **'Waiting for all players to be ready'**
  String get mpErrWaitingReady;

  /// No description provided for @mpErrOnlyHost.
  ///
  /// In en, this message translates to:
  /// **'Only the host can start the game'**
  String get mpErrOnlyHost;

  /// No description provided for @mpErrSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Game session expired. Please create a new game'**
  String get mpErrSessionExpired;

  /// No description provided for @mpErrAlreadyStarted.
  ///
  /// In en, this message translates to:
  /// **'This game has already started'**
  String get mpErrAlreadyStarted;

  /// No description provided for @mpErrNeedTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'Matches need exactly 2 players'**
  String get mpErrNeedTwoPlayers;

  /// No description provided for @mpErrSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to play multiplayer'**
  String get mpErrSignIn;

  /// No description provided for @mpErrReconnectExpired.
  ///
  /// In en, this message translates to:
  /// **'Reconnection time expired'**
  String get mpErrReconnectExpired;

  /// No description provided for @mpErrCheckInternet.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Please check your internet'**
  String get mpErrCheckInternet;

  /// No description provided for @mpErrUnableJoin.
  ///
  /// In en, this message translates to:
  /// **'Unable to join room. Please try again'**
  String get mpErrUnableJoin;

  /// No description provided for @mpErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again'**
  String get mpErrGeneric;

  /// No description provided for @stDurSeconds.
  ///
  /// In en, this message translates to:
  /// **'{s}s'**
  String stDurSeconds(Object s);

  /// No description provided for @stDurMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String stDurMinutes(Object m);

  /// No description provided for @stDurHours.
  ///
  /// In en, this message translates to:
  /// **'{h}h'**
  String stDurHours(Object h);

  /// No description provided for @stDurMinSec.
  ///
  /// In en, this message translates to:
  /// **'{m}m {s}s'**
  String stDurMinSec(Object m, Object s);

  /// No description provided for @stDurHourMin.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String stDurHourMin(Object h, Object m);

  /// No description provided for @dchProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} challenges completed'**
  String dchProgressSummary(Object completed, Object total);

  /// No description provided for @wqProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} complete'**
  String wqProgressSummary(Object completed, Object total);

  /// No description provided for @wqClaimable.
  ///
  /// In en, this message translates to:
  /// **'{count} claimable'**
  String wqClaimable(Object count);

  /// No description provided for @wqClaimToast.
  ///
  /// In en, this message translates to:
  /// **'+{coins} coins, +{xp} BP XP'**
  String wqClaimToast(Object coins, Object xp);

  /// No description provided for @insPoints10.
  ///
  /// In en, this message translates to:
  /// **'10 points'**
  String get insPoints10;

  /// No description provided for @insPoints25.
  ///
  /// In en, this message translates to:
  /// **'25 points'**
  String get insPoints25;

  /// No description provided for @insPoints50.
  ///
  /// In en, this message translates to:
  /// **'50 points + Level Up'**
  String get insPoints50;

  /// No description provided for @unRules.
  ///
  /// In en, this message translates to:
  /// **'• 3-20 characters\n• Must start with a letter\n• Letters, numbers, and underscores only'**
  String get unRules;

  /// No description provided for @dcTitleScoreEasy.
  ///
  /// In en, this message translates to:
  /// **'Beginner Score'**
  String get dcTitleScoreEasy;

  /// No description provided for @dcTitleScoreMedium.
  ///
  /// In en, this message translates to:
  /// **'Skilled Player'**
  String get dcTitleScoreMedium;

  /// No description provided for @dcTitleScoreHard.
  ///
  /// In en, this message translates to:
  /// **'Score Master'**
  String get dcTitleScoreHard;

  /// No description provided for @dcTitleFoodEasy.
  ///
  /// In en, this message translates to:
  /// **'Hungry Snake'**
  String get dcTitleFoodEasy;

  /// No description provided for @dcTitleFoodMedium.
  ///
  /// In en, this message translates to:
  /// **'Feast Mode'**
  String get dcTitleFoodMedium;

  /// No description provided for @dcTitleFoodHard.
  ///
  /// In en, this message translates to:
  /// **'Insatiable'**
  String get dcTitleFoodHard;

  /// No description provided for @dcTitleSurvivalEasy.
  ///
  /// In en, this message translates to:
  /// **'Survivor'**
  String get dcTitleSurvivalEasy;

  /// No description provided for @dcTitleSurvivalMedium.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get dcTitleSurvivalMedium;

  /// No description provided for @dcTitleSurvivalHard.
  ///
  /// In en, this message translates to:
  /// **'Immortal'**
  String get dcTitleSurvivalHard;

  /// No description provided for @dcTitleGamesEasy.
  ///
  /// In en, this message translates to:
  /// **'Casual Player'**
  String get dcTitleGamesEasy;

  /// No description provided for @dcTitleGamesMedium.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get dcTitleGamesMedium;

  /// No description provided for @dcTitleGamesHard.
  ///
  /// In en, this message translates to:
  /// **'Snake Addict'**
  String get dcTitleGamesHard;

  /// No description provided for @dcTitleModeEasy.
  ///
  /// In en, this message translates to:
  /// **'Classic Lover'**
  String get dcTitleModeEasy;

  /// No description provided for @dcTitleModeMedium.
  ///
  /// In en, this message translates to:
  /// **'Zen Master'**
  String get dcTitleModeMedium;

  /// No description provided for @dcTitleModeHard.
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get dcTitleModeHard;

  /// No description provided for @dcDescScore.
  ///
  /// In en, this message translates to:
  /// **'Score at least {target} points in a single game'**
  String dcDescScore(Object target);

  /// No description provided for @dcDescFood.
  ///
  /// In en, this message translates to:
  /// **'Eat {target} foods today'**
  String dcDescFood(Object target);

  /// No description provided for @dcDescSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survive for {target} seconds in a single game'**
  String dcDescSurvival(Object target);

  /// No description provided for @dcDescGames.
  ///
  /// In en, this message translates to:
  /// **'{target, plural, one{Play 1 game today} other{Play {target} games today}}'**
  String dcDescGames(num target);

  /// No description provided for @dcDescMode.
  ///
  /// In en, this message translates to:
  /// **'{target, plural, one{Play 1 game in {mode} mode} other{Play {target} games in {mode} mode}}'**
  String dcDescMode(num target, Object mode);

  /// No description provided for @wqTitleScoreEasy.
  ///
  /// In en, this message translates to:
  /// **'Weekly Warmup'**
  String get wqTitleScoreEasy;

  /// No description provided for @wqTitleScoreMedium.
  ///
  /// In en, this message translates to:
  /// **'Sharper Reflexes'**
  String get wqTitleScoreMedium;

  /// No description provided for @wqTitleScoreHard.
  ///
  /// In en, this message translates to:
  /// **'Score Champion'**
  String get wqTitleScoreHard;

  /// No description provided for @wqTitleFoodEasy.
  ///
  /// In en, this message translates to:
  /// **'Weekly Snacker'**
  String get wqTitleFoodEasy;

  /// No description provided for @wqTitleFoodMedium.
  ///
  /// In en, this message translates to:
  /// **'Voracious'**
  String get wqTitleFoodMedium;

  /// No description provided for @wqTitleFoodHard.
  ///
  /// In en, this message translates to:
  /// **'Bottomless'**
  String get wqTitleFoodHard;

  /// No description provided for @wqTitleGamesEasy.
  ///
  /// In en, this message translates to:
  /// **'Five-a-Week'**
  String get wqTitleGamesEasy;

  /// No description provided for @wqTitleGamesMedium.
  ///
  /// In en, this message translates to:
  /// **'Routine Hatched'**
  String get wqTitleGamesMedium;

  /// No description provided for @wqTitleGamesHard.
  ///
  /// In en, this message translates to:
  /// **'Marathon Hatcher'**
  String get wqTitleGamesHard;

  /// No description provided for @wqTitleSurvivalEasy.
  ///
  /// In en, this message translates to:
  /// **'Two-Minute Slither'**
  String get wqTitleSurvivalEasy;

  /// No description provided for @wqTitleSurvivalMedium.
  ///
  /// In en, this message translates to:
  /// **'Five-Minute Slither'**
  String get wqTitleSurvivalMedium;

  /// No description provided for @wqTitleSurvivalHard.
  ///
  /// In en, this message translates to:
  /// **'Ten-Minute Slither'**
  String get wqTitleSurvivalHard;

  /// No description provided for @wqTitleTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament Regular'**
  String get wqTitleTournament;

  /// No description provided for @wqTitleDailyEasy.
  ///
  /// In en, this message translates to:
  /// **'Daily Doer'**
  String get wqTitleDailyEasy;

  /// No description provided for @wqTitleDailyMedium.
  ///
  /// In en, this message translates to:
  /// **'Daily Adept'**
  String get wqTitleDailyMedium;

  /// No description provided for @wqDescScore.
  ///
  /// In en, this message translates to:
  /// **'Score {target} in a single game'**
  String wqDescScore(Object target);

  /// No description provided for @wqDescFood.
  ///
  /// In en, this message translates to:
  /// **'Eat {target} foods this week'**
  String wqDescFood(Object target);

  /// No description provided for @wqDescGames.
  ///
  /// In en, this message translates to:
  /// **'Play {target} games this week'**
  String wqDescGames(Object target);

  /// No description provided for @wqDescSurvival.
  ///
  /// In en, this message translates to:
  /// **'Survive {target}s in a single game'**
  String wqDescSurvival(Object target);

  /// No description provided for @wqDescTournament.
  ///
  /// In en, this message translates to:
  /// **'{target, plural, one{Play 1 tournament game} other{Play {target} tournament games}}'**
  String wqDescTournament(num target);

  /// No description provided for @wqDescDaily.
  ///
  /// In en, this message translates to:
  /// **'Complete {target} daily challenges this week'**
  String wqDescDaily(Object target);

  /// No description provided for @tnNameDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge - {date}'**
  String tnNameDaily(Object date);

  /// No description provided for @tnNameWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Championship - Week {week}'**
  String tnNameWeekly(Object week);

  /// No description provided for @tnNameMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Grand Prix - {monthYear}'**
  String tnNameMonthly(Object monthYear);

  /// No description provided for @tnDescDaily.
  ///
  /// In en, this message translates to:
  /// **'Compete for the highest score in today\'s 24-hour challenge! Top players win coins and glory.'**
  String get tnDescDaily;

  /// No description provided for @tnDescWeekly.
  ///
  /// In en, this message translates to:
  /// **'The ultimate weekly showdown! Compete against the best players for massive rewards.'**
  String get tnDescWeekly;

  /// No description provided for @tnDescMonthly.
  ///
  /// In en, this message translates to:
  /// **'The biggest tournament of the month! Prove you\'re the ultimate Snake master.'**
  String get tnDescMonthly;

  /// No description provided for @tnRewardRank.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String tnRewardRank(Object rank);

  /// No description provided for @tnRewardCoinDesc.
  ///
  /// In en, this message translates to:
  /// **'Coin reward for rank {rank}'**
  String tnRewardCoinDesc(Object rank);

  /// No description provided for @achTitleScore1500.
  ///
  /// In en, this message translates to:
  /// **'Momentum'**
  String get achTitleScore1500;

  /// No description provided for @achDescScore1500.
  ///
  /// In en, this message translates to:
  /// **'Score 1,500 points in a single game'**
  String get achDescScore1500;

  /// No description provided for @achTitleScore3000.
  ///
  /// In en, this message translates to:
  /// **'On a Tear'**
  String get achTitleScore3000;

  /// No description provided for @achDescScore3000.
  ///
  /// In en, this message translates to:
  /// **'Score 3,000 points in a single game'**
  String get achDescScore3000;

  /// No description provided for @achTitleScore7500.
  ///
  /// In en, this message translates to:
  /// **'Unrelenting'**
  String get achTitleScore7500;

  /// No description provided for @achDescScore7500.
  ///
  /// In en, this message translates to:
  /// **'Score 7,500 points in a single game'**
  String get achDescScore7500;

  /// No description provided for @achTitleScore15000.
  ///
  /// In en, this message translates to:
  /// **'Apex Hunter'**
  String get achTitleScore15000;

  /// No description provided for @achDescScore15000.
  ///
  /// In en, this message translates to:
  /// **'Score 15,000 points in a single game'**
  String get achDescScore15000;

  /// No description provided for @achTitleScore35000.
  ///
  /// In en, this message translates to:
  /// **'Machine Mind'**
  String get achTitleScore35000;

  /// No description provided for @achDescScore35000.
  ///
  /// In en, this message translates to:
  /// **'Score 35,000 points in a single game'**
  String get achDescScore35000;

  /// No description provided for @achTitleScore75000.
  ///
  /// In en, this message translates to:
  /// **'Beyond Mortal'**
  String get achTitleScore75000;

  /// No description provided for @achDescScore75000.
  ///
  /// In en, this message translates to:
  /// **'Score 75,000 points in a single game'**
  String get achDescScore75000;

  /// No description provided for @achTitleScore250000.
  ///
  /// In en, this message translates to:
  /// **'Quarter Million'**
  String get achTitleScore250000;

  /// No description provided for @achDescScore250000.
  ///
  /// In en, this message translates to:
  /// **'Score 250,000 points in a single game'**
  String get achDescScore250000;

  /// No description provided for @achTitleBeyondTime.
  ///
  /// In en, this message translates to:
  /// **'Beyond Time'**
  String get achTitleBeyondTime;

  /// No description provided for @achDescBeyondTime.
  ///
  /// In en, this message translates to:
  /// **'Survive 45 minutes in a single game'**
  String get achDescBeyondTime;

  /// No description provided for @achTitleHourbound.
  ///
  /// In en, this message translates to:
  /// **'Hourbound'**
  String get achTitleHourbound;

  /// No description provided for @achDescHourbound.
  ///
  /// In en, this message translates to:
  /// **'Survive a full hour in a single game'**
  String get achDescHourbound;

  /// No description provided for @achTitleSnakeDevotee.
  ///
  /// In en, this message translates to:
  /// **'Snake Devotee'**
  String get achTitleSnakeDevotee;

  /// No description provided for @achDescSnakeDevotee.
  ///
  /// In en, this message translates to:
  /// **'Play 2,500 games'**
  String get achDescSnakeDevotee;

  /// No description provided for @achTitleTenThousandClub.
  ///
  /// In en, this message translates to:
  /// **'Ten Thousand Club'**
  String get achTitleTenThousandClub;

  /// No description provided for @achDescTenThousandClub.
  ///
  /// In en, this message translates to:
  /// **'Play 10,000 games'**
  String get achDescTenThousandClub;

  /// No description provided for @achTitleZenVeteran.
  ///
  /// In en, this message translates to:
  /// **'Zen Veteran'**
  String get achTitleZenVeteran;

  /// No description provided for @achDescZenVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 Zen games'**
  String get achDescZenVeteran;

  /// No description provided for @achTitleSpeedVeteran.
  ///
  /// In en, this message translates to:
  /// **'Speed Veteran'**
  String get achTitleSpeedVeteran;

  /// No description provided for @achDescSpeedVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 Speed Challenge games'**
  String get achDescSpeedVeteran;

  /// No description provided for @achTitleMultifoodVeteran.
  ///
  /// In en, this message translates to:
  /// **'MultiFood Veteran'**
  String get achTitleMultifoodVeteran;

  /// No description provided for @achDescMultifoodVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 MultiFood games'**
  String get achDescMultifoodVeteran;

  /// No description provided for @achTitleTimeattackVeteran.
  ///
  /// In en, this message translates to:
  /// **'TimeAttack Veteran'**
  String get achTitleTimeattackVeteran;

  /// No description provided for @achDescTimeattackVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 TimeAttack games'**
  String get achDescTimeattackVeteran;

  /// No description provided for @achTitleSurvivalVeteran.
  ///
  /// In en, this message translates to:
  /// **'Survival Veteran'**
  String get achTitleSurvivalVeteran;

  /// No description provided for @achDescSurvivalVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 Survival games'**
  String get achDescSurvivalVeteran;

  /// No description provided for @achTitlePumInitiate.
  ///
  /// In en, this message translates to:
  /// **'Madness Initiate'**
  String get achTitlePumInitiate;

  /// No description provided for @achDescPumInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 Power-Up Madness games'**
  String get achDescPumInitiate;

  /// No description provided for @achTitlePumVeteran.
  ///
  /// In en, this message translates to:
  /// **'Madness Veteran'**
  String get achTitlePumVeteran;

  /// No description provided for @achDescPumVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 Power-Up Madness games'**
  String get achDescPumVeteran;

  /// No description provided for @achTitlePerfectInitiate.
  ///
  /// In en, this message translates to:
  /// **'Purist'**
  String get achTitlePerfectInitiate;

  /// No description provided for @achDescPerfectInitiate.
  ///
  /// In en, this message translates to:
  /// **'Finish 10 Perfect Game runs'**
  String get achDescPerfectInitiate;

  /// No description provided for @achTitlePerfectVeteran.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get achTitlePerfectVeteran;

  /// No description provided for @achDescPerfectVeteran.
  ///
  /// In en, this message translates to:
  /// **'Finish 100 Perfect Game runs'**
  String get achDescPerfectVeteran;

  /// No description provided for @achTitleZen10000.
  ///
  /// In en, this message translates to:
  /// **'Zen Overflow'**
  String get achTitleZen10000;

  /// No description provided for @achDescZen10000.
  ///
  /// In en, this message translates to:
  /// **'Score 10,000 in Zen mode'**
  String get achDescZen10000;

  /// No description provided for @achTitleSpeed5000.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get achTitleSpeed5000;

  /// No description provided for @achDescSpeed5000.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in Speed Challenge'**
  String get achDescSpeed5000;

  /// No description provided for @achTitleMultifood10000.
  ///
  /// In en, this message translates to:
  /// **'Endless Buffet'**
  String get achTitleMultifood10000;

  /// No description provided for @achDescMultifood10000.
  ///
  /// In en, this message translates to:
  /// **'Score 10,000 in MultiFood'**
  String get achDescMultifood10000;

  /// No description provided for @achTitleTimeattack5000.
  ///
  /// In en, this message translates to:
  /// **'Race the Clock'**
  String get achTitleTimeattack5000;

  /// No description provided for @achDescTimeattack5000.
  ///
  /// In en, this message translates to:
  /// **'Score 5,000 in TimeAttack'**
  String get achDescTimeattack5000;

  /// No description provided for @achTitlePum2000.
  ///
  /// In en, this message translates to:
  /// **'Charged Up'**
  String get achTitlePum2000;

  /// No description provided for @achDescPum2000.
  ///
  /// In en, this message translates to:
  /// **'Score 2,000 in Power-Up Madness'**
  String get achDescPum2000;

  /// No description provided for @achTitlePerfect1000.
  ///
  /// In en, this message translates to:
  /// **'Flawless Run'**
  String get achTitlePerfect1000;

  /// No description provided for @achDescPerfect1000.
  ///
  /// In en, this message translates to:
  /// **'Score 1,000 in Perfect Game mode'**
  String get achDescPerfect1000;

  /// No description provided for @achTitleComboSingularity.
  ///
  /// In en, this message translates to:
  /// **'Combo Singularity'**
  String get achTitleComboSingularity;

  /// No description provided for @achDescComboSingularity.
  ///
  /// In en, this message translates to:
  /// **'Hit a 200x combo in a single game'**
  String get achDescComboSingularity;

  /// No description provided for @achTitleWorldSerpent.
  ///
  /// In en, this message translates to:
  /// **'World Serpent'**
  String get achTitleWorldSerpent;

  /// No description provided for @achDescWorldSerpent.
  ///
  /// In en, this message translates to:
  /// **'Grow snake to length 750'**
  String get achDescWorldSerpent;

  /// No description provided for @achTitleLightspeed.
  ///
  /// In en, this message translates to:
  /// **'Lightspeed'**
  String get achTitleLightspeed;

  /// No description provided for @achDescLightspeed.
  ///
  /// In en, this message translates to:
  /// **'Reach in-game level 30 in one game'**
  String get achDescLightspeed;

  /// No description provided for @achTitlePowerOverwhelming.
  ///
  /// In en, this message translates to:
  /// **'Power Overwhelming'**
  String get achTitlePowerOverwhelming;

  /// No description provided for @achDescPowerOverwhelming.
  ///
  /// In en, this message translates to:
  /// **'Collect 5,000 power-ups lifetime'**
  String get achDescPowerOverwhelming;

  /// No description provided for @achTitleGreedIsGood.
  ///
  /// In en, this message translates to:
  /// **'Greed Is Good'**
  String get achTitleGreedIsGood;

  /// No description provided for @achDescGreedIsGood.
  ///
  /// In en, this message translates to:
  /// **'Collect 25 Score Multiplier power-ups'**
  String get achDescGreedIsGood;

  /// No description provided for @achTitleTimeBender.
  ///
  /// In en, this message translates to:
  /// **'Time Bender'**
  String get achTitleTimeBender;

  /// No description provided for @achDescTimeBender.
  ///
  /// In en, this message translates to:
  /// **'Collect 25 Slow Motion power-ups'**
  String get achDescTimeBender;

  /// No description provided for @achTitleGastronome.
  ///
  /// In en, this message translates to:
  /// **'Gastronome'**
  String get achTitleGastronome;

  /// No description provided for @achDescGastronome.
  ///
  /// In en, this message translates to:
  /// **'Eat 100,000 foods lifetime'**
  String get achDescGastronome;

  /// No description provided for @achTitleLivingLegend.
  ///
  /// In en, this message translates to:
  /// **'Living Legend'**
  String get achTitleLivingLegend;

  /// No description provided for @achDescLivingLegend.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 50,000,000 points lifetime'**
  String get achDescLivingLegend;

  /// No description provided for @achTitlePerpetualMotion.
  ///
  /// In en, this message translates to:
  /// **'Perpetual Motion'**
  String get achTitlePerpetualMotion;

  /// No description provided for @achDescPerpetualMotion.
  ///
  /// In en, this message translates to:
  /// **'50-game streak (30s+ each)'**
  String get achDescPerpetualMotion;

  /// No description provided for @achTitleImmaculate.
  ///
  /// In en, this message translates to:
  /// **'Immaculate'**
  String get achTitleImmaculate;

  /// No description provided for @achDescImmaculate.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 perfect games'**
  String get achDescImmaculate;

  /// No description provided for @achTitleFortnightFaithful.
  ///
  /// In en, this message translates to:
  /// **'Fortnight Faithful'**
  String get achTitleFortnightFaithful;

  /// No description provided for @achDescFortnightFaithful.
  ///
  /// In en, this message translates to:
  /// **'Play on 14 consecutive days'**
  String get achDescFortnightFaithful;

  /// No description provided for @achTitleSteadySnake.
  ///
  /// In en, this message translates to:
  /// **'Steady Snake'**
  String get achTitleSteadySnake;

  /// No description provided for @achDescSteadySnake.
  ///
  /// In en, this message translates to:
  /// **'Survive 30+ seconds in 100 games'**
  String get achDescSteadySnake;

  /// No description provided for @achTitleMarathonMonth.
  ///
  /// In en, this message translates to:
  /// **'Marathon Spirit'**
  String get achTitleMarathonMonth;

  /// No description provided for @achDescMarathonMonth.
  ///
  /// In en, this message translates to:
  /// **'Survive 30+ seconds in 1,000 games'**
  String get achDescMarathonMonth;

  /// No description provided for @achTitleLunchtimeLegend.
  ///
  /// In en, this message translates to:
  /// **'Lunchtime Legend'**
  String get achTitleLunchtimeLegend;

  /// No description provided for @achDescLunchtimeLegend.
  ///
  /// In en, this message translates to:
  /// **'Finish a game between noon and 2 PM'**
  String get achDescLunchtimeLegend;

  /// Leading text of the non-blocking first-run legal strip on Home. Followed immediately by the Terms of Use link, so keep any trailing space.
  ///
  /// In en, this message translates to:
  /// **'By playing, you agree to our '**
  String get legalNoticePrefix;

  /// Conjunction between the Terms of Use and Privacy Policy links in the first-run legal strip. Keep surrounding spaces.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get legalNoticeAnd;

  /// Title of the one-shot local Day-1 comeback notification.
  ///
  /// In en, this message translates to:
  /// **'Your snake misses you 🐍'**
  String get dayOneReminderTitle;

  /// Body of the Day-1 comeback notification for a player who has a high score.
  ///
  /// In en, this message translates to:
  /// **'Your best is {score}. Think you can beat it?'**
  String dayOneReminderBodyScore(int score);

  /// Body of the Day-1 comeback notification for a player with no score yet.
  ///
  /// In en, this message translates to:
  /// **'One quick run? Your first high score is waiting.'**
  String get dayOneReminderBodyNoScore;

  /// Small uppercase label on the game-over card announcing tomorrow daily bonus.
  ///
  /// In en, this message translates to:
  /// **'COME BACK TOMORROW'**
  String get goTomorrowLabel;

  /// Body of the game-over card announcing the next daily login bonus.
  ///
  /// In en, this message translates to:
  /// **'Claim {coins} coins on day {day} of your streak'**
  String goTomorrowReward(int coins, int day);

  /// Replay event caption when the recorded food type is missing (older recordings stored null). Deliberately omits the type.
  ///
  /// In en, this message translates to:
  /// **'🍎 Ate food'**
  String get rvAteFoodUnknown;

  /// Replay event caption when the recorded power-up type is missing (older recordings stored null). Deliberately omits the type.
  ///
  /// In en, this message translates to:
  /// **'⚡ Collected a power-up'**
  String get rvCollectedPowerUpUnknown;
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
