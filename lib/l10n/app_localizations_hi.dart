// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'भाषा';

  @override
  String get languageSystemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get languageSystemDefaultSubtitle =>
      'अपने डिवाइस की भाषा का पालन करें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get mpVictory => 'विजय!';

  @override
  String get mpDraw => 'बराबरी';

  @override
  String get mpDefeat => 'हार';

  @override
  String get mpYou => 'आप';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'प्रतिद्वंद्वी';

  @override
  String get mpBackToLobby => 'लॉबी में वापस';

  @override
  String get mpPlayAgain => 'फिर से खेलें';

  @override
  String get mpTimeUpDraw => 'समय समाप्त — बिल्कुल बराबर!';

  @override
  String get mpTimeUpYouWon => 'समय समाप्त — आपका स्कोर ज़्यादा था।';

  @override
  String get mpTimeUpYouLost =>
      'समय समाप्त — प्रतिद्वंद्वी का स्कोर ज़्यादा था।';

  @override
  String get mpMutualCrashDraw => 'दोनों साँप टकरा गए — बराबरी!';

  @override
  String get mpMutualCrashYouWon =>
      'दोनों साँप टकरा गए — आपके स्कोर ने फ़ैसला किया।';

  @override
  String get mpMutualCrashYouLost =>
      'दोनों साँप टकरा गए — प्रतिद्वंद्वी के स्कोर ने फ़ैसला किया।';

  @override
  String get mpMatchCancelled => 'मैच रद्द कर दिया गया।';

  @override
  String get mpLastSnakeStanding =>
      'प्रतिद्वंद्वी टकरा गया। आख़िरी साँप आप ही बचे!';

  @override
  String get mpDeathWall => 'आप दीवार से टकरा गए।';

  @override
  String get mpDeathSelf => 'आप खुद से टकरा गए।';

  @override
  String get mpDeathOpponent => 'आप प्रतिद्वंद्वी से टकरा गए।';

  @override
  String get mpDeathHeadOn => 'आमने-सामने की टक्कर!';

  @override
  String get mpDeathForfeit => 'बहुत देर तक डिस्कनेक्ट — मैच ज़ब्त।';

  @override
  String get mpBetterLuck => 'अगली बार बेहतर किस्मत!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count सिक्के',
      one: '+$count सिक्का',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'गेम छोड़ें?';

  @override
  String get mpLeaveGameBody =>
      'मैच सर्वर पर चलता रहेगा — छोड़ने पर हार मानी जाएगी।';

  @override
  String get mpLeave => 'छोड़ें';

  @override
  String get mpReconnecting => 'पुनः कनेक्ट हो रहा है…';

  @override
  String get mpReconnectingBody => 'मैच अभी भी सर्वर पर चल रहा है।';

  @override
  String get mpGetReady => 'तैयार हो जाइए';

  @override
  String get mpDroppingIntoArena => 'आपको मैदान में उतारा जा रहा है…';

  @override
  String get mpWaitingPlayer => 'प्रतीक्षा…';

  @override
  String get mpOut => 'बाहर';

  @override
  String get mpLength => 'लंबाई';

  @override
  String get mpSwipe => 'स्वाइप';

  @override
  String get mpReconnectingInline => 'पुनः कनेक्ट…';
}
