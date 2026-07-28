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
