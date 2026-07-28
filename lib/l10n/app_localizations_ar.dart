// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'اللغة';

  @override
  String get languageSystemDefault => 'إعداد النظام';

  @override
  String get languageSystemDefaultSubtitle => 'اتباع لغة الجهاز';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get mpVictory => 'انتصار!';

  @override
  String get mpDraw => 'تعادل';

  @override
  String get mpDefeat => 'هزيمة';

  @override
  String get mpYou => 'أنت';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'الخصم';

  @override
  String get mpBackToLobby => 'العودة إلى الردهة';

  @override
  String get mpPlayAgain => 'العب مجددًا';

  @override
  String get mpTimeUpDraw => 'انتهى الوقت — تعادل تام!';

  @override
  String get mpTimeUpYouWon => 'انتهى الوقت — كانت نتيجتك أعلى.';

  @override
  String get mpTimeUpYouLost => 'انتهى الوقت — كانت نتيجة خصمك أعلى.';

  @override
  String get mpMutualCrashDraw => 'اصطدم الثعبانان — تعادل!';

  @override
  String get mpMutualCrashYouWon => 'اصطدم الثعبانان — حسمت نتيجتك الأمر.';

  @override
  String get mpMutualCrashYouLost => 'اصطدم الثعبانان — حسمت نتيجة خصمك الأمر.';

  @override
  String get mpMatchCancelled => 'أُلغيت المباراة.';

  @override
  String get mpLastSnakeStanding => 'اصطدم خصمك. أنت الثعبان الأخير الصامد!';

  @override
  String get mpDeathWall => 'اصطدمت بالجدار.';

  @override
  String get mpDeathSelf => 'اصطدمت بنفسك.';

  @override
  String get mpDeathOpponent => 'اصطدمت بخصمك.';

  @override
  String get mpDeathHeadOn => 'تصادم وجهًا لوجه!';

  @override
  String get mpDeathForfeit => 'انقطع الاتصال طويلًا — خسرت المباراة.';

  @override
  String get mpBetterLuck => 'حظًا أوفر في المرة القادمة!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count عملة',
      many: '+$count عملة',
      few: '+$count عملات',
      two: '+عملتان',
      one: '+عملة واحدة',
      zero: '+$count عملة',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'مغادرة اللعبة؟';

  @override
  String get mpLeaveGameBody =>
      'تستمر المباراة على الخادم — المغادرة تعني الانسحاب.';

  @override
  String get mpLeave => 'مغادرة';

  @override
  String get mpReconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String get mpReconnectingBody => 'لا تزال المباراة جارية على الخادم.';

  @override
  String get mpGetReady => 'استعد';

  @override
  String get mpDroppingIntoArena => 'جارٍ إنزالك إلى الساحة…';

  @override
  String get mpWaitingPlayer => 'بانتظار…';

  @override
  String get mpOut => 'خرج';

  @override
  String get mpLength => 'الطول';

  @override
  String get mpSwipe => 'اسحب';

  @override
  String get mpReconnectingInline => 'إعادة اتصال…';
}
