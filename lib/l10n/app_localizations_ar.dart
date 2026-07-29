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

  @override
  String get mpLobbyNoFriends => 'لا أصدقاء بعد — أضف بعضهم من شاشة الأصدقاء!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'ادعُ صديقًا إلى الغرفة $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 أُرسلت الدعوة إلى $name!';
  }

  @override
  String get mpLobbyInviteFailed => 'تعذر إرسال الدعوة — حاول مجددًا';

  @override
  String get mpLobbyOffline =>
      'أنت غير متصل. يتطلب اللعب الجماعي اتصالًا بالإنترنت.';

  @override
  String get mpLobbyDismiss => 'إغلاق';

  @override
  String get mpLobbyGo => 'انطلق!';

  @override
  String get mpLobbyGetReady => 'استعد!';

  @override
  String get mpLobbyTitle => 'لعب جماعي';

  @override
  String get mpLobbySubtitle => 'العب مع الأصدقاء عبر الإنترنت';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'الغرفة: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'تم نسخ رمز الغرفة!';

  @override
  String get mpLobbyQuickMatch => 'مباراة سريعة';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      'كلاسيكي 1 ضد 1 — يُعثر على خصم تلقائيًا';

  @override
  String get mpLobbyFinding => 'جارٍ البحث...';

  @override
  String get mpLobbyFindMatch => 'ابحث عن مباراة';

  @override
  String get mpLobbySeconds => 'ثانية';

  @override
  String get mpLobbySearching => 'جارٍ البحث عن لاعبين...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لاعب',
      many: '$count لاعبًا',
      few: '$count لاعبين',
      two: 'لاعبان',
      one: 'لاعب واحد',
      zero: 'لا لاعبين',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'موقعك في الطابور: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'إلغاء';

  @override
  String get mpLobbyNoPlayersFound => 'لم يُعثر على لاعبين';

  @override
  String get mpLobbyNoPlayersBody =>
      'عذرًا، لم نجد أي خصوم.\nحاول مجددًا أو أنشئ غرفتك الخاصة!';

  @override
  String get mpLobbyGoBack => 'رجوع';

  @override
  String get mpLobbyTryAgain => 'حاول مجددًا';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count ف';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count خ';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count ت';
  }

  @override
  String get mpLobbyJoinRoom => 'انضم إلى غرفة';

  @override
  String get mpLobbyJoinSubtitle => 'أدخل رمز الغرفة للانضمام';

  @override
  String get mpLobbyEnterRoomCode => 'أدخل رمز الغرفة';

  @override
  String get mpLobbyCreateRoom => 'أنشئ غرفة';

  @override
  String get mpLobbyCreateSubtitle => 'أنشئ غرفة 1 ضد 1 وادعُ صديقًا';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'اللاعبون ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'أنت';

  @override
  String get mpLobbyWaitingForPlayer => 'بانتظار لاعب...';

  @override
  String get mpLobbyStartGame => 'ابدأ اللعبة';

  @override
  String get mpLobbyWaitingForHost => 'بانتظار أن يبدأ المضيف...';

  @override
  String get mpLobbyLeave => 'غادر';

  @override
  String get mpLobbyReadyDone => 'جاهز!';

  @override
  String get mpLobbyReady => 'جاهز';

  @override
  String get mpModeClassicDesc => 'معركة ثعابين تقليدية';

  @override
  String get mpModeSpeedDesc => 'تزداد السرعة مع الوقت';

  @override
  String get mpModeSurvivalDesc => 'يفوز آخر ثعبان صامد';

  @override
  String get mpModePowerUpDesc => 'تعزيزات في كل مكان!';

  @override
  String get mpStatusWaiting => 'ينتظر';

  @override
  String get mpStatusReady => 'جاهز';

  @override
  String get mpStatusPlaying => 'يلعب';

  @override
  String get mpStatusCrashed => 'اصطدم';

  @override
  String get mpStatusDisconnected => 'انقطع';

  @override
  String get goNoAdAvailable => 'لا يوجد إعلان متاح الآن، حاول بعد قليل';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 تضاعفت العملات — +$count عملة إضافية!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'شاهد إعلانًا لمضاعفة عملاتك ($count)';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins عملة  •  +$xp خبرة';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'حصلت على $count عملة من التحديات اليومية!';
  }

  @override
  String get goRibbonNewHighScore => 'رقم قياسي جديد!';

  @override
  String get goRibbonTournamentSubmitted => 'أُرسلت نتيجة البطولة!';

  @override
  String get goRibbonTournamentFailed => 'لم تُرسل النتيجة — تحقق من الاتصال';

  @override
  String get goRibbonTournamentSubmitting => 'جارٍ إرسال نتيجة البطولة…';

  @override
  String get goVictory => 'انتصار!';

  @override
  String get goGameOver => 'انتهت اللعبة';

  @override
  String get goFinalScore => 'النتيجة النهائية';

  @override
  String get goLevel => 'المستوى';

  @override
  String get goBest => 'الأفضل';

  @override
  String get goCoinsEarned => 'العملات المكتسبة';

  @override
  String get goDailyRewardsReady => 'المكافآت اليومية جاهزة';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكافأة',
      many: '$count مكافأة',
      few: '$count مكافآت',
      two: 'مكافأتان',
      one: 'مكافأة واحدة',
      zero: 'لا مكافآت',
    );
    return '$_temp0  •  +$coins عملة  •  +$xp خبرة';
  }

  @override
  String get goClaimAll => 'استلم الكل';

  @override
  String goXpAmount(Object xp) {
    return '$xp خبرة';
  }

  @override
  String get goClaim => 'استلم';

  @override
  String get goAchievements => 'الإنجازات';

  @override
  String get goRecentlyUnlocked => 'فُتحت مؤخرًا';

  @override
  String get goInProgress => 'قيد التقدم';

  @override
  String get goPlayAgain => 'العب مجددًا';

  @override
  String get goMenu => 'القائمة';

  @override
  String get storeTitle => 'متجر Snake';

  @override
  String get storeTabPro => 'برو';

  @override
  String get storeTabCoins => 'العملات';

  @override
  String get storeTabThemes => 'السمات';

  @override
  String get storeTabSkins => 'المظاهر';

  @override
  String get storeTabTrails => 'الآثار';

  @override
  String get storeTabPowerUps => 'التعزيزات';

  @override
  String get storeYourCoins => 'عملات Snake الخاصة بك';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'مكافأة ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds => 'اشترك قبل انتهاء برو المجاني';

  @override
  String get storeChooseYourPlan => 'اختر خطتك';

  @override
  String get storeWhatYouGet => 'ما الذي تحصل عليه';

  @override
  String get storeProHeroSubtitle =>
      'كل السمات والمظاهر والآثار المميزة · لوحات كبيرة · عملات 2× · تعزيزات مميزة · دخول البطولات · تذكرة المعركة المميزة';

  @override
  String get storeMonthly => 'شهري';

  @override
  String get storeYearly => 'سنوي';

  @override
  String get storePerMonth => '/شهر';

  @override
  String get storePerYear => '/سنة';

  @override
  String get storeSave17 => 'وفّر 17%';

  @override
  String storePlanDisplayName(Object title) {
    return 'خطة $title';
  }

  @override
  String get storeVerifyingEllipsis => 'جارٍ التحقق…';

  @override
  String get storeSubscribe => 'اشترك';

  @override
  String get storeYoureOnFreePro => 'لديك برو مجاني!';

  @override
  String get storeYourePro => 'أنت مشترك برو!';

  @override
  String get storeFreePro => 'برو مجاني';

  @override
  String get storeProMonthly => 'برو شهري';

  @override
  String get storeKeepPro => 'احتفظ ببرو — اشترك';

  @override
  String get storePromoBadge => 'عرض';

  @override
  String get storeEndingSoon => 'ينتهي قريبًا';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'ينتهي بعد $daysي $hoursس';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'ينتهي بعد $hoursس $minutesد';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'ينتهي بعد $minutesد';
  }

  @override
  String get storeFeatureExtraLife =>
      'حياة إضافية مجانية دائمًا — عُد للحياة في كل لعبة، بلا إعلان وبلا عملات';

  @override
  String get storeFeatureNoAds => 'بدون إعلانات — العب من دون أي إعلانات';

  @override
  String get storeFeatureThemes => 'كل السمات المميزة الست';

  @override
  String get storeFeatureSkins => 'كل المظاهر المميزة الأحد عشر';

  @override
  String get storeFeatureTrails => 'كل الآثار المميزة الأحد عشر';

  @override
  String get storeFeatureBoards => 'لوحات مميزة (35×35، 40×40، 50×50)';

  @override
  String get storeFeatureCoins => 'مضاعفة كسب العملات 2×';

  @override
  String get storeFeaturePowerUps => '5× تعزيزات مميزة كل دورة';

  @override
  String get storeFeatureTournaments =>
      'دخول بطولات البرونز + الفضة + الذهب كل دورة';

  @override
  String get storeFeatureBattlePass => 'مسار تذكرة المعركة المميز كل موسم';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'جارٍ بدء شراء $name...';
  }

  @override
  String get storeSubNotAvailable => 'الاشتراك غير متاح. حاول لاحقًا.';

  @override
  String get storePurchaseFailed => 'فشل الشراء. حاول مرة أخرى.';

  @override
  String get storeBuyCoins => 'اشترِ عملات Snake';

  @override
  String get storeEarnFreeCoins => 'اكسب عملات مجانية';

  @override
  String get storeEarnPlay => 'العب جولة';

  @override
  String get storeEarnPlayReward => '5 عملات لكل جولة';

  @override
  String get storeEarnDaily => 'تسجيل الدخول اليومي';

  @override
  String get storeEarnDailyReward => '10-50 عملة يوميًا';

  @override
  String get storeEarnAchievements => 'الإنجازات';

  @override
  String get storeEarnAchievementsReward => '25-100 عملة';

  @override
  String get storeEarnTournaments => 'البطولات';

  @override
  String get storeEarnTournamentsReward => 'أكثر من 100 عملة';

  @override
  String get storePopularBadge => 'الأكثر رواجًا';

  @override
  String storeBuyItem(Object name) {
    return 'اشترِ $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'شراء $coins مقابل $price؟';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'اشترِ - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'جارٍ بدء شراء $name...';
  }

  @override
  String get storeProductNotAvailable => 'المنتج غير متاح. حاول لاحقًا.';

  @override
  String get storeUnlockedWithPro => 'مفتوح مع برو';

  @override
  String get storeIncludedWithPro => 'مشمول مع Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned => 'كل سمة هنا ملكك مع اشتراكك.';

  @override
  String get storeProBannerThemesUpsell =>
      'اشترك في برو لفتح كل السمات هنا — بلا شراء منفصل.';

  @override
  String get storeProBannerSkinsOwned => 'كل مظهر هنا ملكك مع اشتراكك.';

  @override
  String get storeProBannerSkinsUpsell =>
      'اشترك في برو لفتح كل المظاهر هنا — بلا شراء منفصل.';

  @override
  String get storeProBannerTrailsOwned => 'كل أثر هنا ملكك مع اشتراكك.';

  @override
  String get storeProBannerTrailsUpsell =>
      'اشترك في برو لفتح كل الآثار هنا — بلا شراء منفصل.';

  @override
  String get storePremiumThemes => 'سمات مميزة';

  @override
  String get storeFreeThemes => 'سمات مجانية';

  @override
  String get storeFreeThemesSubtitle => 'متاحة دائمًا — عُد إليها متى شئت.';

  @override
  String get storeAllThemesBundle => 'حزمة كل السمات';

  @override
  String get storeAllThemesBundleSubtitle =>
      'كل السمات المميزة الست · وفّر 33%';

  @override
  String get storePillVerifying => 'تحقق';

  @override
  String get storePillOwned => 'مملوك';

  @override
  String get storePillFree => 'مجاني';

  @override
  String get storePillActive => 'نشط';

  @override
  String get storePillApply => 'تطبيق';

  @override
  String get storePillEquipped => 'مُجهّز';

  @override
  String get storePillEquip => 'جهّز';

  @override
  String get storeThemeDescClassic => 'المظهر الأصلي';

  @override
  String get storeThemeDescModern => 'نظيف وبسيط';

  @override
  String get storeThemeDescNeon => 'ليالي نيون متوهجة';

  @override
  String get storeThemeDescRetro => 'أركيد نيون الثمانينات';

  @override
  String get storeThemeDescSpace => 'حقل نجوم كوني';

  @override
  String get storeThemeDescOcean => 'زرقة أعماق البحار';

  @override
  String get storeThemeDescCyberpunk => 'سماوي كهربائي ووردي';

  @override
  String get storeThemeDescForest => 'أدغال زمردية نابضة';

  @override
  String get storeThemeDescDesert => 'وادٍ وصبّار فيروزي';

  @override
  String get storeThemeDescCrystal => 'أزرق بلوري جليدي';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'فتح $name مقابل $price؟';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'جارٍ التحقق من شراء $name…';
  }

  @override
  String get storeThemeNotAvailable => 'السمة غير متاحة. حاول لاحقًا.';

  @override
  String get storeItemNotAvailable => 'العنصر غير متاح. حاول لاحقًا.';

  @override
  String storeEquippedToast(Object name) {
    return 'تم تجهيز $name';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 أُضيف تعزيز السرعة المجاني إلى مخزونك!';

  @override
  String get storeWatchAdTitle => 'شاهد إعلانًا — تعزيز سرعة مجاني';

  @override
  String get storeWatchAdReady => 'يضيف تعزيز سرعة واحدًا إلى عتادك';

  @override
  String get storeWatchAdNotReady => 'لا يوجد إعلان متاح الآن';

  @override
  String get puSpeedBoostDesc => 'يزيد سرعة الثعبان لمدة 7 ثوانٍ.';

  @override
  String get puInvincibilityDesc => 'اعبر الجدران وجسدك لمدة 6 ثوانٍ.';

  @override
  String get puScoreMultiplierDesc => 'نقاط مضاعفة لمدة 10 ثوانٍ.';

  @override
  String get puSlowMotionDesc => 'يبطئ اللعبة لدقة أكبر (8 ثوانٍ).';

  @override
  String get storePowerUpsInfo =>
      'اشترِ بالعملات ثم جهّز واحدًا من شريحة العتاد في الشاشة الرئيسية — يُفعَّل بعد 5 ثوانٍ من بدء لعبتك التالية.';

  @override
  String get storePowerUps => 'التعزيزات';

  @override
  String get storePowerUpBundles => 'حزم التعزيزات';

  @override
  String get storeBundlesSubtitle => 'افتح عدة أنواع من التعزيزات بخصم.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'العملات غير كافية!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'شراء 1 $name مقابل $cost عملة؟';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'اشترِ - $cost عملة';
  }

  @override
  String get storePurchaseFailedRetry => 'فشل الشراء. حاول مجددًا.';

  @override
  String storeAddedToLoadout(Object name) {
    return 'أُضيف $name إلى عتادك!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count عملة';
  }

  @override
  String get storeBuyUpper => 'اشترِ';

  @override
  String get storeNeedCoins => 'تحتاج عملات';

  @override
  String storeBundleUnlocked(Object name) {
    return 'فُتح $name!';
  }
}
