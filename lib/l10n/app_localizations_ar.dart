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

  @override
  String get homePlay => 'العب';

  @override
  String get homeHighScore => 'أعلى نتيجة';

  @override
  String homeArmedPowerUp(String name) {
    return 'جاهز: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'العتاد ($count)';
  }

  @override
  String get puSpeedBoost => 'تعزيز السرعة';

  @override
  String get puInvincibility => 'المناعة';

  @override
  String get puScoreMultiplier => 'مضاعف النقاط';

  @override
  String get puSlowMotion => 'الحركة البطيئة';

  @override
  String get homeTilePro => 'برو';

  @override
  String get homeTileStore => 'المتجر';

  @override
  String get homeTileFree => 'مجاني';

  @override
  String get homeTileDaily => 'يومي';

  @override
  String get homeTileBattle => 'المعركة';

  @override
  String get homeTileEvents => 'البطولات';

  @override
  String get homeTileBoard => 'الترتيب';

  @override
  String get homeTileFriends => 'الأصدقاء';

  @override
  String get homeTileCosmetics => 'المظاهر';

  @override
  String get homeTileAwards => 'الجوائز';

  @override
  String get homeTileVersus => 'تحدي';

  @override
  String get homeNoAdReady =>
      'لا يوجد إعلان جاهز الآن — حاول مجددًا بعد ثوانٍ.';

  @override
  String get homeFreeSpeedBoostTitle => 'تعزيز سرعة مجاني';

  @override
  String get homeFreeSpeedBoostBody =>
      'شاهد إعلانًا قصيرًا لإضافة تعزيز سرعة مجاني إلى عتادك. يُفعَّل بعد 5 ثوانٍ من بدء لعبتك التالية.';

  @override
  String get homeNotNow => 'ليس الآن';

  @override
  String get homeWatchAd => 'مشاهدة الإعلان';

  @override
  String get homeFreeSpeedBoostAdded => 'أُضيف تعزيز السرعة المجاني إلى عتادك!';

  @override
  String get homeAdNotFinished =>
      'لم يكتمل الإعلان — شاهده كاملًا للحصول على مكافأتك.';

  @override
  String get homePickGameMode => 'اختر نمط اللعب';

  @override
  String get homePickGameModeSubtitle => 'يمكنك تغييره في الإعدادات في أي وقت';

  @override
  String get homeStartPlaying => 'ابدأ اللعب';

  @override
  String get homeLoadoutTitle => 'عتاد التعزيزات';

  @override
  String get homeLoadoutSubtitle =>
      'جهّز تعزيزًا واحدًا — يُفعَّل بعد 5 ثوانٍ من بدء لعبتك التالية.';

  @override
  String get homeWatchAdFreeSpeedBoost => 'مشاهدة إعلان — تعزيز سرعة مجاني';

  @override
  String get homeNoPowerUps =>
      'ليس لديك أي تعزيزات.\nتفضل بزيارة المتجر لشراء بعضها!';

  @override
  String homeOwnedCount(int count) {
    return 'تملك: $count';
  }

  @override
  String get homeArmed => 'جاهز';

  @override
  String get homeDone => 'تم';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsBackToGame => 'العودة إلى اللعبة';

  @override
  String get settingsSectionControls => 'التحكم';

  @override
  String get settingsSectionGameplay => 'أسلوب اللعب';

  @override
  String get settingsSectionAudio => 'الصوت';

  @override
  String get settingsSectionVisual => 'المظهر';

  @override
  String get settingsSectionNotifications => 'الإشعارات';

  @override
  String get settingsSectionUserProfile => 'الملف الشخصي';

  @override
  String get settingsSectionHelp => 'المساعدة والتعليمات';

  @override
  String get settingsSectionLegal => 'الشؤون القانونية';

  @override
  String get settingsSectionPremium => 'ميزات بريميوم';

  @override
  String get settingsDPadControls => 'أزرار الاتجاهات';

  @override
  String get settingsDPadSubtitle =>
      'إظهار أزرار الاتجاهات على الشاشة أثناء اللعب';

  @override
  String get settingsDPadPosition => 'موضع أزرار الاتجاهات';

  @override
  String get settingsDesktopControls => 'تحكم سطح المكتب/الويب';

  @override
  String get settingsArrowKeys => 'مفاتيح الأسهم';

  @override
  String get settingsWasdKeys => 'مفاتيح WASD';

  @override
  String get settingsSpacebar => 'مفتاح المسافة';

  @override
  String get settingsMouseClick => 'نقرة الفأرة';

  @override
  String get settingsChangeDirection => 'تغيير الاتجاه';

  @override
  String get settingsPauseResume => 'إيقاف/استئناف اللعبة';

  @override
  String get settingsTouchControlsIfAvailable => 'التحكم باللمس (إن وُجد)';

  @override
  String get settingsTouchControls => 'التحكم باللمس';

  @override
  String get settingsSwipeGestures => 'إيماءات السحب';

  @override
  String get settingsTapScreen => 'لمس الشاشة';

  @override
  String get settingsSwipeUp => 'اسحب لأعلى ↑';

  @override
  String get settingsSwipeDown => 'اسحب لأسفل ↓';

  @override
  String get settingsSwipeLeft => 'اسحب لليسار ←';

  @override
  String get settingsSwipeRight => 'اسحب لليمين →';

  @override
  String get settingsMoveSnakeUp => 'تحريك الثعبان لأعلى';

  @override
  String get settingsMoveSnakeDown => 'تحريك الثعبان لأسفل';

  @override
  String get settingsMoveSnakeLeft => 'تحريك الثعبان لليسار';

  @override
  String get settingsMoveSnakeRight => 'تحريك الثعبان لليمين';

  @override
  String get settingsGameMode => 'نمط اللعب';

  @override
  String get settingsGameModeLocked => 'أكمل اللعبة الحالية لتغيير النمط';

  @override
  String get settingsDifficulty => 'الصعوبة';

  @override
  String get settingsDifficultySubtitle =>
      'تحدد سرعة بداية الثعبان. كل نمط يتسارع مع تقدم المستويات.';

  @override
  String get settingsEasyNote =>
      'العملات والخبرة والإنجازات تُحتسب في الوضع السهل — تتوقف الأرقام القياسية والتصنيفات فقط.';

  @override
  String get settingsDifficultyLocked => 'أنهِ اللعبة الحالية لتغيير الصعوبة.';

  @override
  String get settingsCurrentSize => 'الحجم الحالي';

  @override
  String get settingsBoardSizeLocked => 'أكمل اللعبة الحالية لتغيير حجم اللوحة';

  @override
  String get settingsCurrentDuration => 'المدة الحالية';

  @override
  String get settingsCrashFeedbackSubtitle => 'مدة عرض شرح الاصطدام';

  @override
  String get settingsScreenShake => 'اهتزاز الشاشة';

  @override
  String get settingsScreenShakeSubtitle =>
      'هزّ الشاشة عند الاصطدامات وأحداث اللعبة';

  @override
  String get settingsVibration => 'الاهتزاز';

  @override
  String get settingsVibrationSubtitle =>
      'الاهتزاز عند أحداث اللعبة وضغط الأزرار';

  @override
  String get settingsSoundEffects => 'المؤثرات الصوتية';

  @override
  String get settingsBackgroundMusic => 'موسيقى الخلفية';

  @override
  String get settingsCurrentTheme => 'السمة الحالية';

  @override
  String get settingsBrowseThemes => 'تصفح السمات';

  @override
  String get settingsSnakeTrail => 'مؤثرات أثر الثعبان';

  @override
  String get settingsSnakeTrailSubtitle => 'تفعيل أثر الجسيمات خلف الثعبان';

  @override
  String get settingsNotifDailyReminder => 'التذكير اليومي';

  @override
  String get settingsNotifTournament => 'تنبيهات البطولات';

  @override
  String get settingsNotifAchievement => 'فتح الإنجازات';

  @override
  String get settingsNotifSocial => 'التحديثات الاجتماعية';

  @override
  String get settingsNotifSpecialEvents => 'الفعاليات الخاصة';

  @override
  String get settingsNotSet => 'غير محدد';

  @override
  String get settingsUsername => 'اسم المستخدم';

  @override
  String get settingsGuestAccount => 'حساب ضيف';

  @override
  String get settingsAuthenticatedAccount => 'حساب موثّق';

  @override
  String get settingsChangeUsername => 'تغيير اسم المستخدم';

  @override
  String get settingsGuestSignInHint =>
      'سجّل الدخول للاحتفاظ بتقدمك واللعب مع الأصدقاء';

  @override
  String get settingsUsernameVisibleHint =>
      'اسم المستخدم مرئي للأصدقاء وفي التصنيفات';

  @override
  String get settingsReplayTutorial => 'إعادة التعليمات';

  @override
  String get settingsReplayTutorialSubtitle =>
      'شاهد جولة القائمة أو تعليمات اللعبة مجددًا';

  @override
  String get settingsAboutCredits => 'حول التطبيق';

  @override
  String get settingsAboutCreditsSubtitle =>
      'إصدار التطبيق والمساهمون والروابط';

  @override
  String get settingsRateApp => 'قيّم SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'أعجبتك اللعبة؟ اترك تقييمًا في App Store';

  @override
  String get settingsRateAppSubtitle => 'أعجبتك اللعبة؟ اترك لنا تقييمًا!';

  @override
  String get settingsAdPrivacy => 'الخصوصية وخيارات الإعلانات';

  @override
  String get settingsAdPrivacySubtitle =>
      'إدارة الموافقة على الإعلانات المخصصة';

  @override
  String get settingsAdPrivacyUnavailable =>
      'خيارات خصوصية الإعلانات غير متاحة حاليًا.';

  @override
  String get settingsReplayDialogTitle => 'إعادة التعليمات';

  @override
  String get settingsReplayDialogBody => 'أي تعليمات تريد إعادتها؟';

  @override
  String get settingsHomeTour => 'جولة القائمة';

  @override
  String get settingsGameTutorial => 'تعليمات اللعبة';

  @override
  String get settingsPrivacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyPolicyButton => 'سياسة الخصوصية';

  @override
  String get settingsTermsTitle => 'شروط الاستخدام';

  @override
  String get settingsTermsButton => 'شروط الاستخدام';

  @override
  String get settingsChangeUsernameTitle => 'تغيير اسم المستخدم';

  @override
  String get settingsCurrentLabel => 'الحالي:';

  @override
  String get settingsUsernameDialogBody =>
      'اختر اسم مستخدم فريدًا يمثلك في اللعبة.';

  @override
  String get settingsEnterNewUsername => 'أدخل اسم المستخدم الجديد';

  @override
  String get settingsUsernameRules =>
      '• 3-20 حرفًا\n• يجب أن يبدأ بحرف\n• أحرف وأرقام وشرطات سفلية فقط';

  @override
  String get settingsUsernameUpdateFailed => 'تعذر تحديث اسم المستخدم';

  @override
  String settingsUsernameUpdated(String name) {
    return 'تم تغيير اسم المستخدم إلى \"$name\"';
  }

  @override
  String get settingsUpdate => 'تحديث';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'حالة بريميوم';

  @override
  String get settingsActiveSubscription => 'اشتراك نشط';

  @override
  String get settingsUnlockPremium => 'افتح ميزات بريميوم';

  @override
  String settingsRenews(String date) {
    return 'يتجدد في $date';
  }

  @override
  String get settingsProBadge => 'برو';

  @override
  String get settingsUpgradeToPro => 'الترقية إلى برو';

  @override
  String get settingsRestorePurchases => 'استعادة المشتريات';

  @override
  String get settingsPurchaseHistory => 'سجل المشتريات';

  @override
  String get settingsSnakeCosmetics => 'مظاهر الثعبان';

  @override
  String get settingsBattlePass => 'تذكرة المعركة';

  @override
  String settingsTier(int tier) {
    return 'المستوى $tier';
  }

  @override
  String get settingsRestoring => 'جارٍ استعادة المشتريات...';

  @override
  String get settingsRestored => 'تمت استعادة المشتريات بنجاح!';

  @override
  String get settingsRestoreFailed => 'تعذرت استعادة المشتريات. حاول مرة أخرى.';

  @override
  String get settingsNoPurchases => 'لا توجد مشتريات';

  @override
  String get settingsUnknown => 'غير معروف';

  @override
  String settingsStatusLine(String status) {
    return 'الحالة: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'التاريخ: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'عملية شراء رقم $number';
  }

  @override
  String get settingsDataParseError => 'خطأ في قراءة البيانات';

  @override
  String get settingsClose => 'إغلاق';

  @override
  String get settingsHistoryLoadFailed => 'تعذر تحميل سجل المشتريات';

  @override
  String get settingsUnknownDate => 'تاريخ غير معروف';
}
