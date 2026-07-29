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

  @override
  String get modeClassic => 'كلاسيكي';

  @override
  String get modeZen => 'وضع الاسترخاء';

  @override
  String get modeSpeedChallenge => 'تحدي السرعة';

  @override
  String get modeMultiFood => 'طعام متعدد';

  @override
  String get modeSurvival => 'البقاء';

  @override
  String get modeTimeAttack => 'ضد الوقت';

  @override
  String get modePowerUpMadness => 'جنون التعزيزات';

  @override
  String get modePerfectGame => 'اللعبة المثالية';

  @override
  String get modeClassicDesc => 'لعبة الثعبان الكلاسيكية مع الجدران';

  @override
  String get modeZenDesc => 'بلا جدران - يعبر الثعبان حواف الشاشة';

  @override
  String get modeSpeedChallengeDesc => 'تزداد السرعة بسرعة لأقصى تحدٍ';

  @override
  String get modeMultiFoodDesc => 'تظهر عدة قطع طعام في آن واحد';

  @override
  String get modeSurvivalDesc => 'اصمد أطول فترة ممكنة بأرواح محدودة';

  @override
  String get modeTimeAttackDesc => 'سجّل أكبر عدد من النقاط في وقت محدود';

  @override
  String get modePowerUpMadnessDesc =>
      'تظهر التعزيزات أكثر بكثير — استمتع بالفوضى';

  @override
  String get modePerfectGameDesc =>
      'لا تقطع أثرك أبدًا. خطوة واحدة على خلية مزارة تنهي الجولة.';

  @override
  String get diffEasy => 'سهل';

  @override
  String get diffNormal => 'عادي';

  @override
  String get diffHard => 'صعب';

  @override
  String get diffEasyDesc =>
      'ثعبان أبطأ في البداية. النتائج لا تدخل التصنيفات.';

  @override
  String get diffNormalDesc => 'إيقاع Snake Classic الأصلي.';

  @override
  String get diffHardDesc => 'يبدأ سريعًا ولا يزداد إلا سرعة.';

  @override
  String get themeClassic => 'كلاسيكي';

  @override
  String get themeModern => 'عصري';

  @override
  String get themeNeon => 'نيون';

  @override
  String get themeRetro => 'قديم';

  @override
  String get themeSpace => 'الفضاء';

  @override
  String get themeOcean => 'المحيط';

  @override
  String get themeCyberpunk => 'سايبربانك';

  @override
  String get themeForest => 'الغابة';

  @override
  String get themeDesert => 'الصحراء';

  @override
  String get themeCrystal => 'الكريستال';

  @override
  String get dpadLeft => 'يسار';

  @override
  String get dpadCenter => 'الوسط';

  @override
  String get dpadRight => 'يمين';

  @override
  String get mpModeClassicBattle => 'معركة كلاسيكية';

  @override
  String get mpModeSpeedRun => 'سباق سريع';

  @override
  String get mpModeSurvivalMode => 'وضع البقاء';

  @override
  String get mpModePowerUpMadnessName => 'جنون التعزيزات';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonViewAll => 'عرض الكل';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get pfTitle => 'الملف الشخصي';

  @override
  String get pfSigningOut => 'جارٍ تسجيل الخروج...';

  @override
  String get pfGuestPlayer => 'لاعب ضيف';

  @override
  String get pfVerifiedAccount => 'حساب موثّق';

  @override
  String get pfStatistics => 'الإحصائيات';

  @override
  String get pfReplays => 'الإعادات';

  @override
  String get pfAchievements => 'الإنجازات';

  @override
  String get pfLoadingStats => 'جارٍ تحميل الإحصائيات...';

  @override
  String get pfHighScore => 'أعلى نتيجة';

  @override
  String get pfGamesPlayed => 'الجولات الملعوبة';

  @override
  String get pfPlayTime => 'وقت اللعب';

  @override
  String get pfAverageScore => 'متوسط النتيجة';

  @override
  String get pfFoodConsumed => 'الطعام المستهلَك';

  @override
  String get pfPowerUps => 'التعزيزات';

  @override
  String get pfUpgradeTitle => 'الترقية إلى حساب Google';

  @override
  String get pfUpgradeSubtitle => 'احفظ تقدمك وزامنه بين الأجهزة';

  @override
  String get pfBenefitSync => 'مزامنة التقدم';

  @override
  String get pfBenefitSyncSub => 'بين الأجهزة';

  @override
  String get pfBenefitLeaderboards => 'تصنيفات عالمية';

  @override
  String get pfBenefitLeaderboardsSub => 'نافس العالم كله';

  @override
  String get pfBenefitSocial => 'الأصدقاء والتواصل';

  @override
  String get pfBenefitSocialSub => 'تواصل مع الآخرين';

  @override
  String get pfSignInGoogle => 'تسجيل الدخول عبر Google';

  @override
  String get pfSignInApple => 'تسجيل الدخول عبر Apple';

  @override
  String get pfNoReplays => 'لا إعادات بعد. العب بعض الجولات!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعادة محفوظة',
      many: '$count إعادة محفوظة',
      few: '$count إعادات محفوظة',
      two: 'إعادتان محفوظتان',
      one: 'إعادة واحدة محفوظة',
      zero: 'لا إعادات محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'إدارة الحساب';

  @override
  String get pfSignOut => 'تسجيل الخروج';

  @override
  String get pfDeleteAccount => 'حذف الحساب';

  @override
  String get pfAppleUpgradeSuccess => 'تمت الترقية إلى حساب Apple بنجاح! 🎉';

  @override
  String get pfAppleIdInUse =>
      'معرّف Apple هذا لديه حساب بالفعل. سجّل الخروج ثم ادخل عبر Apple.';

  @override
  String get pfUpgradeFailed => 'فشلت ترقية الحساب. حاول مرة أخرى.';

  @override
  String get pfUpgradeError => 'حدث خطأ أثناء ترقية الحساب.';

  @override
  String get pfGoogleUpgradeSuccess => 'تمت الترقية إلى حساب Google بنجاح! 🎉';

  @override
  String get pfDeleteAccountTitle => 'حذف الحساب؟';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'هذا يحذف حسابك وكل ما يرتبط به نهائيًا:\n\n• النتائج والإحصائيات\n• العملات والمشتريات\n• السمات والمظاهر والآثار والتعزيزات\n• تقدم تذكرة المعركة والتحديات\n• سجلات التصنيف والأصدقاء\n\nلا يمكن التراجع عن هذا. يجب إلغاء الاشتراكات النشطة بشكل منفصل في إعدادات $storeName.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'متجر تطبيقات الجهاز';

  @override
  String get pfAccountDeleted => 'تم حذف حسابك نهائيًا.';

  @override
  String get pfDeleteFailed => 'تعذر حذف الحساب. تحقق من الاتصال وحاول مجددًا.';

  @override
  String get pfDeleteForever => 'احذف نهائيًا';

  @override
  String get pfSignOutBody =>
      'هل تريد تسجيل الخروج فعلًا؟\n\nسيبقى تقدمك محفوظًا إذا كنت مسجلًا عبر Google.';

  @override
  String get pfSignedOut => 'تم تسجيل الخروج بنجاح 👋';

  @override
  String get stLoading => 'جارٍ تحميل الإحصائيات...';

  @override
  String get stPerformanceOverview => 'نظرة عامة على الأداء';

  @override
  String get stTotalGames => 'إجمالي الجولات';

  @override
  String get stWinStreak => 'سلسلة الانتصارات';

  @override
  String get stGameActivity => 'نشاط اللعب';

  @override
  String get stLongestGame => 'أطول جولة';

  @override
  String get stHighestLevel => 'أعلى مستوى';

  @override
  String get stPerfectGames => 'جولات مثالية';

  @override
  String get stFoodPowerUps => 'الطعام والتعزيزات';

  @override
  String get stPowerUpsUsed => 'التعزيزات المستخدمة';

  @override
  String get stFavoriteFood => 'الطعام المفضل';

  @override
  String get stFavoritePowerUp => 'التعزيز المفضل';

  @override
  String get stPerformanceTrends => 'اتجاهات الأداء';

  @override
  String get stOverallTrend => 'الاتجاه العام';

  @override
  String get stRecentAverage => 'المتوسط الأخير';

  @override
  String get stBestRecent => 'الأفضل مؤخرًا';

  @override
  String get stConsistency => 'الثبات';

  @override
  String get stScores => 'النتائج';

  @override
  String get stTrendLine => 'خط الاتجاه';

  @override
  String get stPlayPatterns => 'أنماط اللعب (آخر 7 أيام)';

  @override
  String get stWeeklyTime => 'الوقت الأسبوعي';

  @override
  String get stMostActiveDay => 'اليوم الأكثر نشاطًا';

  @override
  String get stDailyActivity => 'النشاط اليومي';

  @override
  String get stAchievementProgress => 'تقدم الإنجازات';

  @override
  String get stViewAllAchievements => 'عرض كل الإنجازات ←';

  @override
  String get stViewAchievements => 'عرض الإنجازات';

  @override
  String get stReplaysUpper => 'الإعادات';

  @override
  String get stResetStatistics => 'إعادة تعيين الإحصائيات';

  @override
  String get stResetTitle => 'إعادة تعيين الإحصائيات؟';

  @override
  String get stResetBody =>
      'سيؤدي هذا إلى حذف كل إحصائيات لعبك نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get stReset => 'إعادة تعيين';

  @override
  String get stNA => 'غير متاح';

  @override
  String get stExcellent => 'ممتاز';

  @override
  String get stGood => 'جيد';

  @override
  String get stFair => 'مقبول';

  @override
  String get stPoor => 'ضعيف';

  @override
  String get stNoData => 'لا بيانات';

  @override
  String get stNone => 'لا شيء';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولة',
      many: '$count جولة',
      few: '$count جولات',
      two: 'جولتين',
      one: 'جولة واحدة',
    );
    return 'التقدم (آخر $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent مكتمل';
  }

  @override
  String get stInsights => 'تحليلات الأداء';

  @override
  String get stInsightPlayMore =>
      'العب المزيد من الجولات للحصول على تحليلات الأداء!';

  @override
  String get stInsightImproving => 'أحسنت! أداؤك في تحسّن مستمر.';

  @override
  String get stInsightAboveAverage => 'جولاتك الأخيرة أعلى بكثير من متوسطك.';

  @override
  String get stInsightDeclined =>
      'تراجع أداؤك مؤخرًا. فكّر في مزيد من التدريب.';

  @override
  String get stInsightPractice =>
      'ركّز على تجنب الاصطدامات والتخطيط لحركاتك مسبقًا.';

  @override
  String get stInsightStable => 'أداؤك مستقر. تحدَّ نفسك للتحسن!';

  @override
  String get stInsightPotential =>
      'لديك إمكانية لنتائج عالية - اعمل على الثبات.';

  @override
  String get stInsightSolid => 'تحافظ على أداء قوي في جولاتك الأخيرة.';

  @override
  String get frTitle => 'الأصدقاء';

  @override
  String get frBlockedUsers => 'المستخدمون المحظورون';

  @override
  String get frSearchHint => 'ابحث بالاسم أو البريد...';

  @override
  String get frSearching => 'جارٍ البحث...';

  @override
  String get frSearchTitle => 'ابحث عن أصدقاء';

  @override
  String get frSearchSubtitle => 'أدخل اسمًا أو بريدًا للعثور على أصدقاء';

  @override
  String get frNoUsersFound => 'لم يُعثر على مستخدمين';

  @override
  String get frNoUsersFoundSub => 'جرّب البحث باسم أو بريد مختلف';

  @override
  String get frRequests => 'الطلبات';

  @override
  String get frSearch => 'بحث';

  @override
  String get frNoCacheYet => 'لا توجد بيانات مؤقتة';

  @override
  String frUpdatedAgo(Object ago) {
    return 'تم التحديث $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · فشل التحديث، انقر لإعادة المحاولة';
  }

  @override
  String get frJustNow => 'الآن';

  @override
  String frSecondsAgo(Object count) {
    return 'قبل $count ث';
  }

  @override
  String frMinutesAgo(Object count) {
    return 'قبل $count د';
  }

  @override
  String frHoursAgo(Object count) {
    return 'قبل $count س';
  }

  @override
  String frDaysAgo(Object count) {
    return 'قبل $count ي';
  }

  @override
  String get frLoadingFriends => 'جارٍ تحميل الأصدقاء...';

  @override
  String get frNoFriendsYet => 'لا أصدقاء بعد';

  @override
  String get frNoFriendsSub => 'ابحث عن لاعبين وأضفهم كأصدقاء!';

  @override
  String get frNoRequests => 'لا طلبات صداقة';

  @override
  String get frNoRequestsSub => 'ستظهر طلبات الصداقة هنا';

  @override
  String get frChallengeMenu => 'تحدَّ في مباراة';

  @override
  String get frViewProfile => 'عرض الملف الشخصي';

  @override
  String get frRemoveFriend => 'إزالة الصديق';

  @override
  String get frBlockUser => 'حظر المستخدم';

  @override
  String frReceivedHeader(Object count) {
    return 'الواردة ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'المرسلة ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جولة',
      many: '$count جولة',
      few: '$count جولات',
      two: 'جولتان',
      one: 'جولة واحدة',
      zero: 'لا جولات',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'أُرسل $date';
  }

  @override
  String get frPending => 'قيد الانتظار';

  @override
  String get frCancelRequest => 'إلغاء الطلب';

  @override
  String get frReject => 'رفض';

  @override
  String get frAccept => 'قبول';

  @override
  String get frAlreadyFriends => '✓ أصدقاء';

  @override
  String get frAddFriend => 'إضافة';

  @override
  String get frSendRequestFailed =>
      'تعذر إرسال الطلب — تحقق من الاتصال وحاول مجددًا';

  @override
  String get frAcceptFailed => 'تعذر قبول الطلب — تحقق من الاتصال وحاول مجددًا';

  @override
  String get frRejectFailed => 'تعذر رفض الطلب — تحقق من الاتصال وحاول مجددًا';

  @override
  String get frCancelFailed =>
      'تعذر إلغاء الطلب — تحقق من الاتصال وحاول مجددًا';

  @override
  String get frBlockFailed =>
      'تعذر حظر المستخدم — تحقق من الاتصال وحاول مجددًا';

  @override
  String get frSignInSocial =>
      'سجّل الدخول لإضافة أصدقاء واستخدام الميزات الاجتماعية';

  @override
  String get frRequestSent => 'أُرسل طلب الصداقة!';

  @override
  String get frRequestAccepted => 'قُبل طلب الصداقة!';

  @override
  String get frRequestRejected => 'رُفض طلب الصداقة';

  @override
  String get frRequestCancelled => 'أُلغي طلب الصداقة';

  @override
  String frChallengeSent(Object name) {
    return '🎮 أُرسل التحدي إلى $name!';
  }

  @override
  String get frChallengeFailed => 'تعذر إرسال التحدي — حاول مجددًا';

  @override
  String frBlocked(Object name) {
    return 'تم حظر $name';
  }

  @override
  String frUnblocked(Object name) {
    return 'أُلغي حظر $name';
  }

  @override
  String get frUnblockFailed => 'تعذر إلغاء الحظر — حاول مجددًا';

  @override
  String frRemoved(Object name) {
    return 'أُزيل $name من الأصدقاء';
  }

  @override
  String frBlockTitle(Object name) {
    return 'حظر $name؟';
  }

  @override
  String get frBlockBody =>
      'سيُزال من أصدقائك ولن يستطيع إرسال طلبات صداقة أو تحديات إليك. لن يتم إخطاره.';

  @override
  String get frBlock => 'حظر';

  @override
  String get frNoBlocked => 'لم تحظر أحدًا.';

  @override
  String get frUnblock => 'إلغاء الحظر';

  @override
  String frHighScoreLine(Object score) {
    return 'أعلى نتيجة: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'إجمالي الجولات: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'المستوى: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'الحالة: \"$status\"';
  }

  @override
  String frRemoveBody(Object name) {
    return 'إزالة $name من قائمة أصدقائك؟';
  }

  @override
  String get frRemove => 'إزالة';

  @override
  String get frLeaderboardTitle => 'ترتيب الأصدقاء';

  @override
  String get frLeaderboardSubtitle => 'نافس أصدقاءك';

  @override
  String get frLoadingLeaderboard => 'جارٍ تحميل الترتيب...';

  @override
  String frRankBadge(Object rank) {
    return '#$rank';
  }

  @override
  String get frYou => 'أنت';

  @override
  String get frLeaderboardEmptySub => 'أضف أصدقاء لرؤية ترتيبك الخاص!';

  @override
  String get frAddFriends => 'أضف أصدقاء';

  @override
  String get tnTitle => 'البطولات';

  @override
  String get tnActive => 'النشطة';

  @override
  String get tnHistory => 'السجل';

  @override
  String get tnMyStats => 'إحصائياتي';

  @override
  String get tnLoading => 'جارٍ تحميل البطولات...';

  @override
  String get tnNoActive => 'لا بطولات نشطة';

  @override
  String get tnNoActiveSub => 'عُد لاحقًا لبطولات جديدة!';

  @override
  String get tnNoHistory => 'لا سجل بطولات';

  @override
  String get tnNoHistorySub => 'شارك في البطولات لرؤية سجلك!';

  @override
  String get tnNoStats => 'لا إحصائيات بطولات';

  @override
  String get tnNoStatsSub => 'انضم إلى البطولات لتتبع تقدمك!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max لاعبًا';
  }

  @override
  String get tnJoined => 'منضم';

  @override
  String tnBestScoreChip(Object score) {
    return 'الأفضل: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'المركز #$rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكافأة متاحة',
      many: '$count مكافأة متاحة',
      few: '$count مكافآت متاحة',
      two: 'مكافأتان متاحتان',
      one: 'مكافأة واحدة متاحة',
      zero: 'لا مكافآت متاحة',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'عرض التفاصيل ←';

  @override
  String get tnOverviewCard => 'نظرة عامة على البطولات';

  @override
  String get tnWins => 'الانتصارات';

  @override
  String get tnTopThree => 'مراكز ضمن الثلاثة الأوائل';

  @override
  String get tnBestScore => 'أفضل نتيجة';

  @override
  String get tnDetailedStats => 'إحصائيات مفصلة';

  @override
  String get tnTotalAttempts => 'إجمالي المحاولات';

  @override
  String get tnWinRate => 'نسبة الفوز';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'الأداء المتوسط';

  @override
  String tnTopPercent(Object percent) {
    return 'أفضل $percent%';
  }

  @override
  String get tnNotFound => 'البطولة غير موجودة';

  @override
  String get tnLoadFailed => 'تعذر تحميل البطولة';

  @override
  String get tnLoadingTournament => 'جارٍ تحميل البطولة...';

  @override
  String get tnGoBack => 'رجوع';

  @override
  String get tnParticipating => 'أنت مشارك!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'الأفضل: $score • المحاولات: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'المركز #$rank';
  }

  @override
  String get tnOverview => 'نظرة عامة';

  @override
  String get tnLeaderboard => 'الترتيب';

  @override
  String get tnRules => 'القواعد';

  @override
  String get tnLeaderboardFailed => 'تعذر تحميل الترتيب';

  @override
  String get tnCheckConnection => 'تحقق من الاتصال وحاول مجددًا.';

  @override
  String get tnNoParticipants => 'لا مشاركين بعد';

  @override
  String get tnBeFirst => 'كن أول المنضمين!';

  @override
  String get tnDescription => 'الوصف';

  @override
  String get tnRewards => 'المكافآت';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محاولة',
      many: '$count محاولة',
      few: '$count محاولات',
      two: 'محاولتان',
      one: 'محاولة واحدة',
      zero: 'لا محاولات',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'قواعد البطولة';

  @override
  String get tnScoringSystem => 'نظام النقاط';

  @override
  String get tnScoringBody =>
      'تُحتسب أعلى نتيجة لك خلال فترة البطولة في الترتيب النهائي. يمكنك اللعب عدة مرات لتحسين نتيجتك.';

  @override
  String get tnJoining => 'جارٍ الانضمام…';

  @override
  String get tnJoin => 'انضم إلى البطولة';

  @override
  String get tnPlayNow => 'العب الآن';

  @override
  String get tnProUnlimited => 'برو · دخول غير محدود';

  @override
  String tnEntriesRemaining(Object count) {
    return 'الدخول المتبقي: $count';
  }

  @override
  String get tnNoEntries => 'لا دخول — انقر انضم للشراء';

  @override
  String tnStarts(Object time) {
    return 'تبدأ $time';
  }

  @override
  String get tnRule1 => 'العب خلال فترة البطولة لتُحتسب نتائجك';

  @override
  String get tnRule2 => 'يمكنك اللعب عدة مرات - تُحتسب أعلى نتيجة فقط';

  @override
  String get tnRule3 => 'يجب تسجيل الدخول للمشاركة';

  @override
  String get tnRule4 => 'يُحدد الترتيب النهائي عند انتهاء البطولة';

  @override
  String get tnRuleSpeed => 'تزداد سرعة اللعبة بسرعة كل 10 نقاط';

  @override
  String get tnRuleSurvival => 'النتيجة تعتمد على وقت البقاء لا الطعام';

  @override
  String get tnRuleNoWalls =>
      'يعبر الثعبان حواف الشاشة بدلًا من الاصطدام بالجدران';

  @override
  String get tnRulePowerUps => 'تظهر التعزيزات كل 5 ثوانٍ';

  @override
  String get tnRulePerfect => 'أي اصطدام ينهي اللعبة فورًا';

  @override
  String get tnRuleClassic => 'تنطبق قواعد الثعبان الكلاسيكية';

  @override
  String get tnJoinSuccess => 'انضممت إلى البطولة بنجاح!';

  @override
  String get tnJoinFailed => 'تعذر الانضمام إلى البطولة';

  @override
  String get tnJoinError => 'خطأ أثناء الانضمام إلى البطولة';

  @override
  String get tnTierBronze => 'برونزي';

  @override
  String get tnTierSilver => 'فضي';

  @override
  String get tnTierGold => 'ذهبي';

  @override
  String get tnEntryRequired => 'الدخول مطلوب';

  @override
  String tnEntryNeeded(Object tier) {
    return 'تحتاج إلى دخول $tier للانضمام إلى هذه البطولة.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'دخولك ($tier): $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'مشتركو برو يحصلون على دخول غير محدود للبطولات.';

  @override
  String get tnFreeBronzeAdded => '🎉 أُضيف دخول برونزي مجاني!';

  @override
  String get tnFreeEntryAd => 'دخول مجاني (إعلان)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'اشترِ دخول $tier - $price';
  }

  @override
  String get acAll => 'الكل';

  @override
  String get acUnlocked => 'المفتوحة';

  @override
  String get acLocked => 'المقفلة';

  @override
  String get acTotalUpper => 'الإجمالي';

  @override
  String get acUnlockedUpper => 'مفتوحة';

  @override
  String get acClaimedUpper => 'مستلمة';

  @override
  String get acPendingUpper => 'معلّقة';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% من المفتوحة';
  }

  @override
  String get acEmpty => 'لا إنجازات هنا';

  @override
  String acXpReward(Object xp) {
    return '+$xp خبرة';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'فُتح $date';
  }

  @override
  String get rpTitle => 'إعادات الجولات';

  @override
  String get rpRecent => 'الأحدث';

  @override
  String get rpBest => 'الأفضل';

  @override
  String get rpCrashes => 'الاصطدامات';

  @override
  String get rpLoading => 'جارٍ تحميل الإعادات...';

  @override
  String get rpNoRecent => 'لا إعادات حديثة';

  @override
  String get rpNoBest => 'لا إعادات أرقام قياسية';

  @override
  String get rpNoCrashes => 'لا إعادات اصطدام';

  @override
  String get rpEmptySub => 'العب بعض الجولات لإنشاء إعادات!';

  @override
  String get rpScore => 'النتيجة';

  @override
  String get rpDuration => 'المدة';

  @override
  String get rpFood => 'الطعام';

  @override
  String get rpFrames => 'الإطارات';

  @override
  String get rpMaxLength => 'أقصى طول';

  @override
  String get rpWatch => 'مشاهدة';

  @override
  String get rpYesterday => 'أمس';

  @override
  String get rpDeleteTitle => 'حذف الإعادة';

  @override
  String rpDeleteBody(Object date) {
    return 'حذف إعادة $date؟';
  }

  @override
  String get rpDelete => 'حذف';

  @override
  String get rpDeleted => 'حُذفت الإعادة';

  @override
  String get rpDeleteFailed => 'تعذر حذف الإعادة';

  @override
  String get lbTitle => 'التصنيفات';

  @override
  String get lbGlobal => 'عالمي';

  @override
  String get lbWeekly => 'أسبوعي';

  @override
  String get lbWeeklySub =>
      'مرتب حسب أفضل نتيجة لك هذا الأسبوع (يُعاد الضبط يوم الأحد)';

  @override
  String get lbGlobalSub => 'مرتب حسب أعلى نتيجة لك على الإطلاق';

  @override
  String lbScoreLine(Object score) {
    return 'النتيجة: $score';
  }

  @override
  String get lbLoadingGlobal => 'جارٍ تحميل التصنيف العالمي...';

  @override
  String get lbLoadingWeekly => 'جارٍ تحميل التصنيف الأسبوعي...';

  @override
  String get lbNoScores => 'لا نتائج بعد';

  @override
  String get lbBeFirst => 'كن أول من يسجل رقمًا قياسيًا!';

  @override
  String get lbNoWeekly => 'لا نتائج هذا الأسبوع';

  @override
  String get lbPlayThisWeek => 'العب هذا الأسبوع لتظهر هنا!';

  @override
  String get lbAnonymous => 'مجهول';

  @override
  String get lbGuestBadge => 'ضيف';

  @override
  String get lbPts => 'نقطة';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'لُعبت $count جولة',
      many: 'لُعبت $count جولة',
      few: 'لُعبت $count جولات',
      two: 'لُعبت جولتان',
      one: 'لُعبت جولة واحدة',
      zero: 'لم تُلعب جولات',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return 'تم استلام $name!';
  }

  @override
  String get bpTitle => 'تذكرة المعركة';

  @override
  String get bpTitleUpper => 'تذكرة المعركة';

  @override
  String get bpLoading => 'جارٍ تحميل تذكرة المعركة...';

  @override
  String get bpWatchAdXp => 'شاهد إعلانًا — +50 خبرة للتذكرة';

  @override
  String get bpXpEarned => '+50 خبرة لتذكرة المعركة!';

  @override
  String get bpSeasonEnded => 'انتهى الموسم';

  @override
  String bpHoursLeft(Object hours) {
    return 'بقي $hours س';
  }

  @override
  String bpDaysLeft(Object days) {
    return 'بقي $days ي';
  }

  @override
  String get bpTierUpper => 'المستوى';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'اكتمل الموسم';

  @override
  String get bpSeasonCompleteUpper => 'اكتمل الموسم';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next خبرة للمستوى $tier';
  }

  @override
  String get bpPremiumBadge => 'مميز';

  @override
  String get bpUnlockedEverything => 'فتحت كل مستويات هذا الموسم.';

  @override
  String get bpComingNext => 'القادم';

  @override
  String bpTierN(Object tier) {
    return 'المستوى $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'على بُعد $count مستوى',
      many: 'على بُعد $count مستوى',
      few: 'على بُعد $count مستويات',
      two: 'على بُعد مستويين',
      one: 'على بُعد مستوى واحد',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'افتح مع برو';

  @override
  String get bpAvailableNow => 'متاح الآن';

  @override
  String bpTierAbbrev(Object tier) {
    return 'م$tier';
  }

  @override
  String get bpClaim => 'استلم';

  @override
  String get bpPremiumWaiting => 'مكافآت مميزة بانتظارك';

  @override
  String get bpSubscribeToClaim => 'اشترك في برو لاستلامها.';

  @override
  String get bpHideTiers => 'إخفاء المستويات';

  @override
  String bpViewAllTiers(Object count) {
    return 'عرض كل المستويات ($count)';
  }

  @override
  String get bpCollapse => 'طيّ';

  @override
  String get bpExpand => 'توسيع';

  @override
  String get bpNow => 'الحالي';

  @override
  String bpTierUpperN(Object tier) {
    return 'المستوى $tier';
  }

  @override
  String get bpUnlocked => 'مفتوح';

  @override
  String bpReachTier(Object tier) {
    return 'صِل إلى المستوى $tier للفتح';
  }

  @override
  String get bpBetweenSeasons => 'بين المواسم';

  @override
  String get bpNoSeasonBody =>
      'لا تذكرة معركة نشطة الآن — سيبدأ الموسم التالي تلقائيًا. عُد قريبًا.';

  @override
  String get bpCheckNewSeason => 'التحقق من موسم جديد';

  @override
  String get pbActive => 'بريميوم نشط!';

  @override
  String get pbActiveSub => 'لديك وصول إلى كل ميزات بريميوم';

  @override
  String get pbHeaderSub => 'افتح كل ما تقدمه اللعبة';

  @override
  String get pbMonthlyPlan => 'الخطة الشهرية';

  @override
  String get pbYearlyPlan => 'الخطة السنوية';

  @override
  String get pbSave33 => 'وفّر 33%';

  @override
  String get pbMostPopular => 'الأكثر شيوعًا';

  @override
  String get pbFeatExtraLife => 'حياة إضافية مجانية دائمًا';

  @override
  String get pbFeatExtraLifeDesc =>
      'اصطدم وواصل — أعضاء برو يعودون فورًا مجانًا، بلا إعلان وبلا عملات، مرة في كل جولة';

  @override
  String get pbFeatNoAds => 'أزل كل الإعلانات';

  @override
  String get pbFeatNoAdsDesc =>
      'بلا لافتات ولا إعلانات بينية — العب من دون إعلانات، للأبد';

  @override
  String get pbFeatThemes => 'كل السمات المميزة';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'كل مظاهر الثعبان المميزة';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice و5 أخرى';

  @override
  String get pbFeatTrails => 'كل الآثار المميزة';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal و5 أخرى';

  @override
  String get pbFeatBoards => 'لوحات لعب كبيرة';

  @override
  String get pbFeatBoardsDesc => 'العب على لوحات 35x35 و40x40 و50x50';

  @override
  String get pbFeatCoins => 'مكافآت عملات 2x';

  @override
  String get pbFeatCoinsDesc => 'ضعف عملات Snake من كل جولة';

  @override
  String get pbFeatLucky => 'محظوظ — طعام خاص أكثر';

  @override
  String get pbFeatLuckyDesc =>
      '+50% فرصة ظهور الطعام الخاص النادر بقيمة 50 نقطة في كل جولة';

  @override
  String get pbFeatPowerUps => 'تعزيزات أكثر داخل اللعبة';

  @override
  String get pbFeatPowerUpsDesc => '+30% لمعدل ظهور التعزيزات على اللوحة';

  @override
  String get pbFeatBundle => 'حزمة تعزيزات مميزة';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport وGhost Mode وMagnetic Food وScore Shield وMega Invincibility في كل دورة فوترة';

  @override
  String get pbFeatTournament => 'دخول البطولات';

  @override
  String get pbFeatTournamentDesc =>
      '1× برونزي + 1× فضي + 1× ذهبي في كل دورة فوترة';

  @override
  String get pbIncludes => 'يشمل بريميوم:';

  @override
  String get pbProPerk => 'ميزة برو';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'اشترك — $price$period';
  }

  @override
  String get pbReassurance => 'بلا التزام • ألغِ في أي وقت • دفع آمن';

  @override
  String get pbNotAvailable => 'اشتراك بريميوم غير متاح';

  @override
  String get eaTitleLink => 'احفظ تقدمك';

  @override
  String get eaTitleSignIn => 'الدخول بالبريد';

  @override
  String get eaExplainer =>
      'أضف بريدًا وكلمة مرور إلى حسابك لتتمكن من الشراء والاستعادة بعد إعادة التثبيت والدخول من أي جهاز.';

  @override
  String get eaLinkExisting => 'ربط حساب موجود';

  @override
  String get eaSignIn => 'تسجيل الدخول';

  @override
  String get eaCreateAccount => 'إنشاء حساب';

  @override
  String get eaForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get eaLinkToExisting => 'الربط بحساب موجود';

  @override
  String get eaMinChars => '8 أحرف على الأقل';

  @override
  String eaMinCharsN(Object count) {
    return '$count أحرف على الأقل';
  }

  @override
  String get eaCreateAndLink => 'إنشاء الحساب وربطه';

  @override
  String get eaEmail => 'البريد الإلكتروني';

  @override
  String get eaEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get eaEmailInvalid => 'أدخل بريدًا صالحًا';

  @override
  String get eaPassword => 'كلمة المرور';

  @override
  String get eaPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get eaForgotFirst =>
      'أدخل بريدك أعلاه أولًا، ثم انقر نسيت كلمة المرور.';

  @override
  String eaResetSent(Object email) {
    return 'أُرسل بريد إعادة تعيين كلمة المرور إلى $email.';
  }

  @override
  String get eaErrInvalidEmail => 'عنوان البريد هذا غير صالح.';

  @override
  String get eaErrDisabled => 'هذا الحساب معطّل.';

  @override
  String get eaErrNoAccount => 'لا يوجد حساب بهذا البريد.';

  @override
  String get eaErrWrongCreds => 'البريد أو كلمة المرور غير صحيحة.';

  @override
  String get eaErrEmailInUse =>
      'يوجد حساب بهذا البريد بالفعل. جرّب تسجيل الدخول.';

  @override
  String get eaErrWeakPassword =>
      'كلمة المرور ضعيفة جدًا. استخدم 8 أحرف على الأقل.';

  @override
  String get eaErrNotEnabled =>
      'الدخول بالبريد/كلمة المرور غير مفعّل. تواصل مع الدعم.';

  @override
  String get eaErrTooMany => 'محاولات كثيرة. انتظر بضع دقائق ثم حاول مجددًا.';

  @override
  String get eaErrNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get eaErrAlreadyLinked => 'هذا الحساب مرتبط بالفعل ببريد/كلمة مرور.';

  @override
  String get eaErrRecentLogin => 'لأسباب أمنية، سجّل الدخول مجددًا قبل الربط.';

  @override
  String get eaErrGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get faWelcome => 'مرحبًا بك في\nSnake Classic!';

  @override
  String get faChooseHow => 'اختر طريقة اللعب:';

  @override
  String get faSigningIn => 'جارٍ تسجيل دخولك...';

  @override
  String get faSignInEmail => 'تسجيل الدخول بالبريد';

  @override
  String get faContinueGuest => 'المتابعة كضيف';

  @override
  String get faGuestNote =>
      'يمكن للضيوف اللعب وحفظ التقدم محليًا، لكن لا يمكنهم الشراء. سجّل الدخول عبر Apple أو Google أو البريد عندما تريد الاشتراك أو الشراء.';

  @override
  String get faPrivacyTerms => 'الخصوصية والشروط';

  @override
  String get faReviewNote =>
      'يرجى مراجعة سياسة الخصوصية وشروط الاستخدام قبل المتابعة';

  @override
  String get faAgreeCheckbox =>
      'قرأت سياسة الخصوصية وشروط الاستخدام وأوافق عليهما';

  @override
  String get faContinueToSignIn => 'المتابعة إلى تسجيل الدخول';

  @override
  String get faHeadsUp => 'تنبيه';

  @override
  String get faGuestBullet1 =>
      'تُحذف بيانات الضيف تلقائيًا من خوادمنا بعد 90 يومًا من عدم النشاط.';

  @override
  String get faGuestBullet2 =>
      'لحفظ تقدمك بشكل دائم واللعب عبر الأجهزة، سجّل الدخول عبر Apple أو Google أو البريد.';

  @override
  String get faGuestBullet3 =>
      'لا يمكن لحسابات الضيوف شراء المنتجات أو الاشتراكات. سجّل الدخول إذا أردت الترقية إلى برو أو شراء المظاهر.';

  @override
  String get faChangedMind => 'غيّرت رأيي';

  @override
  String get faProceedAnyway => 'المتابعة على أي حال';

  @override
  String get faAppleFailed => 'تعذر تسجيل الدخول عبر Apple. حاول مرة أخرى.';

  @override
  String get faGoogleFailed => 'تعذر تسجيل الدخول عبر Google. حاول مرة أخرى.';

  @override
  String get faUnexpected => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get faGuestFailed => 'تعذرت المتابعة كضيف. حاول مرة أخرى.';

  @override
  String get ldInitializing => 'جارٍ تشغيل Snake Classic...';

  @override
  String get ldTip1 =>
      'خطط لحركتين مقدمًا — ذيلك يتبع المكان الذي مرّ به الرأس للتو.';

  @override
  String get ldTip2 =>
      'الطعام الإضافي يمنح نقاطًا أكثر لكنه يختفي سريعًا. التقطه بسرعة!';

  @override
  String get ldTip3 =>
      'اصطدمت؟ شاهد إعلانًا قصيرًا أو أنفق عملات لتعود وتحافظ على نتيجتك.';

  @override
  String get ldTip4 => 'سلسل الطعام دون توقف لبناء مضاعف السلسلة.';

  @override
  String get ldTip5 => 'عالق في مكان ضيق؟ التصق بالجدران لتكسب لحظة.';

  @override
  String get ldTip6 =>
      'التحديات اليومية والمهام الأسبوعية تكدّس العملات بسرعة.';

  @override
  String get ldTip7 => 'Snake Classic Pro يفتح لوحات أكبر ويزيل كل الإعلانات.';

  @override
  String get ldTip8 =>
      'وضع ضد الوقت يكافئ السرعة — ويمكنك مشاهدة إعلان مقابل +30 ثانية.';

  @override
  String get ldTip9 => 'التعزيزات تتراكم: جهّز درعًا قبل المرور من فجوة ضيقة.';

  @override
  String get ldTip10 =>
      'بدّل السمات والمظاهر والآثار في المتجر متى شئت لمظهر جديد.';

  @override
  String get ldStepCore => 'تشغيل الأنظمة الأساسية...';

  @override
  String get ldStepCoreSub => 'إعداد الاتصال بالخادم';

  @override
  String get ldStepProfile => 'إنشاء ملفك الشخصي...';

  @override
  String get ldStepProfileSub => 'توليد اسم مستخدم فريد';

  @override
  String get ldStepPrefs => 'تحميل تفضيلاتك...';

  @override
  String get ldStepPrefsSub => 'مزامنة السمات والإعدادات';

  @override
  String get ldStepCloud => 'المزامنة مع السحابة...';

  @override
  String get ldStepCloudSub => 'التأكد من تحديث البيانات';

  @override
  String get ldStepGameData => 'تحميل بيانات اللعبة...';

  @override
  String get ldStepGameDataSub => 'جلب بيانات اللعبة';

  @override
  String get ldStepAudio => 'إعداد نظام الصوت...';

  @override
  String get ldStepAudioSub => 'تحميل المؤثرات الصوتية';

  @override
  String get ldStepSetup => 'التحقق من حالة الإعداد...';

  @override
  String get ldStepSetupSub => 'شارفنا على الانتهاء!';

  @override
  String get ldWelcome => 'مرحبًا!';

  @override
  String get ldWelcomeSub => 'اختر كيفية المتابعة';

  @override
  String get ldReady => 'جاهز للعب!';

  @override
  String get ldReadySub => 'مرحبًا بعودتك إلى Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'فشل التشغيل: $error';
  }

  @override
  String get ldRetrying => 'إعادة محاولة التشغيل...';

  @override
  String get ldTagline => 'تجربة ثعبان مميزة';

  @override
  String get ldLoadingUpper => 'جارٍ التحميل';

  @override
  String get ldDidYouKnow => 'هل كنت تعلم؟';

  @override
  String get ldGameFeatures => 'مزايا اللعبة';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'لعب سلس';

  @override
  String get ldFeatEffects => 'مؤثرات';

  @override
  String get ldFeatEffectsSub => 'جسيمات بصرية';

  @override
  String get ldFeatLevels => 'مستويات';

  @override
  String get ldFeatLevelsSub => 'متعة متصاعدة';

  @override
  String get ldFeatAudio => 'صوت';

  @override
  String get ldFeatAudioSub => 'صوت غامر';

  @override
  String get ldFeatScores => 'نتائج';

  @override
  String get ldFeatScoresSub => 'تصنيفات عالمية';

  @override
  String get ldFeatThemes => 'سمات';

  @override
  String get ldFeatThemesSub => 'أنماط متعددة';

  @override
  String get ldDevelopedBy => 'تطوير وصيانة';

  @override
  String get ldDevTagline => 'نصنع تجارب جوال مميزة';

  @override
  String get ldInitFailedUpper => 'فشل التشغيل';

  @override
  String get ldRetryUpper => 'إعادة المحاولة';

  @override
  String get pgArena => 'تجهيز الساحة...';

  @override
  String get pgControls => 'معايرة التحكم...';

  @override
  String get pgSnake => 'استدعاء الثعبان...';

  @override
  String get pgFood => 'وضع الطعام...';

  @override
  String get pgPowerUps => 'شحن التعزيزات...';

  @override
  String get pgAlmost => 'أوشكنا...';

  @override
  String get pgGo => 'انطلق!';

  @override
  String get pgTip1 => 'أبقِ اتجاهًا لفترة أطول لبناء مضاعفات السلسلة.';

  @override
  String get pgTip2 => 'الطعام الإضافي يمنح نقاطًا أكثر لكنه يختفي بسرعة.';

  @override
  String get pgTip3 => 'تظهر التعزيزات عشوائيًا — التقطها ما دمت تستطيع.';

  @override
  String get pgTip4 => 'خطط لحركتين مقدمًا لا لواحدة.';

  @override
  String get pgTip5 =>
      'الثعابين الطويلة تنعطف أبطأ. وفّر المنعطفات الحادة للبداية.';

  @override
  String get pgTip6 => 'مضاعف النقاط يتراكم مع السلاسل لنتائج هائلة.';

  @override
  String get pgTip7 => 'الطعام الخاص نادر — إن ظهر فاجعله أولويتك.';

  @override
  String get pgTip8 => 'وضع ضد الوقت يتسارع بسرعة. وازن انعطافاتك.';

  @override
  String get pgTip9 =>
      'في وضع الاسترخاء تعبر الجدران. استخدم ذلك للهروب من المآزق.';

  @override
  String get pgTip10 => 'اللعبة المثالية: لا تدخل مجددًا خلية لمسها جسدك.';

  @override
  String get pgTip11 => 'أزرار الاتجاهات تمنح انعطافات دقيقة؛ السحب أسرع.';

  @override
  String get pgTip12 => 'أوقف اللعب من الواجهة متى شئت — المؤقت ينتظرك.';

  @override
  String get pgPreparing => 'تجهيز الساحة';

  @override
  String get pgTournamentMode => 'وضع البطولة';

  @override
  String get pgGameMode => 'نمط اللعب';

  @override
  String get pgDPadControls => 'أزرار الاتجاهات';

  @override
  String get pgSwipeControls => 'تحكم بالسحب';

  @override
  String get pgLevel => 'المستوى';

  @override
  String get pgBest => 'الأفضل';

  @override
  String get pgGames => 'الجولات';

  @override
  String get pgProTip => 'نصيحة محترف';

  @override
  String get pgTapToStart => 'انقر في أي مكان للبدء';

  @override
  String get wtWelcomeTitle => 'مرحبًا بك في اللعبة!';

  @override
  String get wtWelcomeMsg =>
      'لنتعلم لعب Snake Classic. سيعرض هذا الدرس السريع الأساسيات.';

  @override
  String get wtHudTitle => 'معلومات اللعبة';

  @override
  String get wtHudMsg =>
      'الشريط العلوي يعرض نتيجتك ومستواك وأعلى نتيجة. راقب تقدمك أثناء اللعب!';

  @override
  String get wtControlsTitle => 'اسحب للتحرك';

  @override
  String get wtControlsMsg =>
      'اسحب في أي اتجاه لتغيير وجهة الثعبان. سينعطف الثعبان تبعًا لسحبك.';

  @override
  String get wtPracticeRightTitle => 'جرّب! اسحب لليمين';

  @override
  String get wtPracticeRightMsg => 'اسحب لليمين على الشاشة للمتابعة.';

  @override
  String get wtPracticeUpTitle => 'رائع! الآن اسحب لأعلى';

  @override
  String get wtPracticeUpMsg => 'اسحب لأعلى على الشاشة للمتابعة.';

  @override
  String get wtFoodTitle => 'كُل لتكبر';

  @override
  String get wtFoodMsg =>
      'قد الثعبان ليأكل الطعام الظاهر على اللوحة. كل قطعة تزيد طوله!';

  @override
  String get wtComboTitle => 'ابنِ سلسلة';

  @override
  String get wtComboMsg =>
      'كُل دون أن تموت لبناء سلسلة. عند 5 قضمات تحصل على 1.5×، وعند 10 على 2×، وعند 20 على 3×. شريحة النار قرب نتيجتك تسخن وتنبض كلما ارتفعت.';

  @override
  String get wtPowerUpsTitle => 'التعزيزات';

  @override
  String get wtPowerUpsMsg =>
      'تظهر أيقونات لامعة أحيانًا — كُل واحدة لتفعيلها. تنفد الحلقة حول الأيقونة مع انتهاء التأثير، ويتجمد المؤقت عند الإيقاف.';

  @override
  String get wtWallsTitle => 'تجنب الجدران!';

  @override
  String get wtWallsMsg =>
      'لا تلمس حواف اللوحة - الاصطدام بالجدار يعني نهاية اللعبة!';

  @override
  String get wtSelfTitle => 'لا تصطدم بنفسك!';

  @override
  String get wtSelfMsg => 'كلما طال ثعبانك، احذر الاصطدام بجسدك!';

  @override
  String get wtPauseTitle => 'أوقف متى شئت';

  @override
  String get wtPauseMsg =>
      'انقر أيقونة الإيقاف لتجميد الجولة. من هناك يمكنك المتابعة أو البدء من جديد أو فتح دليل اللعبة أو إعادة هذا الدرس أو تبديل أزرار الاتجاهات.';

  @override
  String get wtReadyTitle => 'أنت جاهز!';

  @override
  String get wtReadyMsg =>
      'حظًا موفقًا! افتح دليل اللعبة من قائمة الإيقاف متى شئت لقراءة السلاسل والتعزيزات والأنماط وتنبيهات الاصطدام. تفقد ملفك لترى الإنجازات تُفتح مع تحقيق الأهداف.';

  @override
  String get wtStartPlaying => 'ابدأ اللعب!';

  @override
  String get wtSkipTutorial => 'تخطي الدرس';

  @override
  String get wtSwipeRightUpper => 'اسحب لليمين';

  @override
  String get wtSwipeLeftUpper => 'اسحب لليسار';

  @override
  String get wtSwipeUpUpper => 'اسحب لأعلى';

  @override
  String get wtSwipeDownUpper => 'اسحب لأسفل';

  @override
  String get wtSwipeAnywhereScreen => 'اسحب في أي مكان على الشاشة!';

  @override
  String get wtSwipeAnywhere => 'اسحب في أي مكان!';

  @override
  String get wtGotIt => 'فهمت!';

  @override
  String get wtNext => 'التالي';

  @override
  String get wtSkip => 'تخطي';

  @override
  String get wtWaiting => 'بانتظارك...';

  @override
  String get hwPlayTitle => 'مرحبًا بك في Snake Classic!';

  @override
  String get hwPlayMsg =>
      'انقر زر العب لبدء جولة. اسحب لقيادة الثعبان وكُل الطعام لتكبر!';

  @override
  String get hwCoinsTitle => 'عملاتك';

  @override
  String get hwCoinsMsg =>
      'اكسب العملات باللعب وإكمال التحديات والمكافآت اليومية. أنفقها في المتجر!';

  @override
  String get hwDailyTitle => 'التحديات اليومية';

  @override
  String get hwDailyMsg =>
      'أكمل التحديات اليومية لعملات ومكافآت إضافية. تحديات جديدة كل يوم!';

  @override
  String get hwStoreTitle => 'المتجر';

  @override
  String get hwStoreMsg =>
      'اشترِ السمات والمظاهر والآثار والتعزيزات بعملاتك. افتح برو للوحات المميزة والمظاهر الحصرية.';

  @override
  String get hwCosmeticsTitle => 'المظاهر والآثار';

  @override
  String get hwCosmeticsMsg =>
      'خصص ثعبانك هنا. المظاهر تغيّر شكل الثعبان؛ والآثار تترك وهجًا خلفه. اكسبها بالعملات أو افتحها مع برو.';

  @override
  String get hwProfileTitle => 'ملفك الشخصي';

  @override
  String get hwProfileMsg =>
      'هنا الإحصائيات والإنجازات وأعلى النتائج. تُفتح الإنجازات مع بلوغ المحطات — بعضها يتطلب نمطًا محددًا (كلاسيكي، صعب، إلخ). سجّل الدخول للمزامنة بين الأجهزة.';

  @override
  String get hwSettingsTitle => 'الإعدادات';

  @override
  String get hwSettingsMsg =>
      'خصص تجربتك - غيّر السمات والتحكم والصوت والمزيد!';

  @override
  String get hudScoreUpper => 'النتيجة';

  @override
  String hudScoreSemantics(Object value) {
    return 'النتيجة $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'مس$level';
  }

  @override
  String get hudTournamentBadge => 'بطولة';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'متوقف';

  @override
  String get poPremium => 'بريميوم';

  @override
  String get poStore => 'المتجر';

  @override
  String get poResume => 'متابعة';

  @override
  String get poRestart => 'من جديد';

  @override
  String get poHome => 'الرئيسية';

  @override
  String get poDPadOn => 'الأزرار: تعمل';

  @override
  String get poDPadOff => 'الأزرار: متوقفة';

  @override
  String get poSound => 'الصوت';

  @override
  String get poMusic => 'الموسيقى';

  @override
  String get poHowToPlay => 'طريقة اللعب';

  @override
  String get poGameGuide => 'دليل اللعبة';

  @override
  String get poFoodUpper => 'الطعام';

  @override
  String get poPts10 => '10 نقاط';

  @override
  String get poPts25 => '25 نقطة';

  @override
  String get poPts50 => '50 نقطة';

  @override
  String get poComboUpper => 'السلسلة';

  @override
  String get poBites5 => '5 قضمات';

  @override
  String get poBites10 => '10 قضمات';

  @override
  String get poBites20 => '20 قضمة';

  @override
  String get poComboHint => 'شريحة النار قرب النتيجة تسخن وتنبض عند كل عتبة.';

  @override
  String get poPowerUpsUpper => 'التعزيزات';

  @override
  String get poDur7s => '7 ث';

  @override
  String get poDur6s => '6 ث';

  @override
  String get poDur10s => '10 ث';

  @override
  String get poDur8s => '8 ث';

  @override
  String get poScore2x => 'النقاط 2×';

  @override
  String get poPowerUpHint =>
      'حلقة الأيقونة تنفد حتى الانتهاء. المؤقت يتجمد عند الإيقاف.';

  @override
  String get poCrashUpper => 'الاصطدام';

  @override
  String get poCrashHint =>
      'موجة حمراء تنفجر في الخلية التي متّ فيها. الاصطدام بالنفس يُبرز أيضًا الجزء المصاب بالأصفر.';

  @override
  String get poModesUpper => 'الأنماط';

  @override
  String get poModeWallsOn => 'بجدران';

  @override
  String get poModeWallsOff => 'بلا جدران';

  @override
  String get poModeFastTick => 'إيقاع سريع';

  @override
  String get poModeThreeFoods => '3 أطعمة معًا';

  @override
  String get poModeThreeLives => '3 أرواح وتتسارع';

  @override
  String get poModeThreeMin => '3 دقائق إجمالًا';

  @override
  String get poModeFrequentPowerUps => 'تعزيزات متكررة';

  @override
  String get poModeDontCross => 'لا تقطع أثرك';

  @override
  String get dcTitle => 'التحديات اليومية';

  @override
  String get dcNoChallenges => 'لا تحديات متاحة';

  @override
  String get dcAllComplete => 'اكتمل كل شيء!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count مكافأة';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'الإصدار $version · البنية $build';
  }

  @override
  String get crTagline => 'لعبة الثعبان الكلاسيكية بحلة جديدة.';

  @override
  String get crChipModes => 'الأنماط';

  @override
  String get crChipAchievements => 'الإنجازات';

  @override
  String get crChipDaily => 'يومي';

  @override
  String get crChipLeaderboards => 'التصنيفات';

  @override
  String get crChipCosmetics => 'المظاهر';

  @override
  String get crCraftedBy => 'من صنع';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · جميع الحقوق محفوظة';
  }

  @override
  String get gbSpeedNormal => 'عادية';

  @override
  String get gbSpeedFast => 'سريعة';

  @override
  String get gbSpeedFaster => 'أسرع';

  @override
  String get gbSpeedBlazing => 'ملتهبة';

  @override
  String get gbSpeedInsane => 'جنونية';

  @override
  String get gbSpeedMax => 'القصوى';

  @override
  String get gbLength => 'الطول';

  @override
  String get gbSpeed => 'السرعة';

  @override
  String get gbLevel => 'المستوى';

  @override
  String get rarityCommon => 'شائع';

  @override
  String get rarityRare => 'نادر';

  @override
  String get rarityEpic => 'ملحمي';

  @override
  String get rarityLegendary => 'أسطوري';

  @override
  String get rarityDiamond => 'ماسي';

  @override
  String get achTitleFirstBite => 'القضمة الأولى';

  @override
  String get achDescFirstBite => 'سجّل نقطتك الأولى';

  @override
  String get achTitleGettingStarted => 'البداية';

  @override
  String get achDescGettingStarted => 'سجّل 100 نقطة';

  @override
  String get achTitleHighScorer => 'هدّاف بارع';

  @override
  String get achDescHighScorer => 'سجّل 500 نقطة في لعبة واحدة';

  @override
  String get achTitleMasterScorer => 'هدّاف محترف';

  @override
  String get achDescMasterScorer => 'سجّل 1000 نقطة في لعبة واحدة';

  @override
  String get achTitleLegendaryScorer => 'هدّاف أسطوري';

  @override
  String get achDescLegendaryScorer => 'سجّل 2000 نقطة في لعبة واحدة';

  @override
  String get achTitleFirstGame => 'اللعبة الأولى';

  @override
  String get achDescFirstGame => 'العب أول لعبة لك';

  @override
  String get achTitleRegularPlayer => 'لاعب منتظم';

  @override
  String get achDescRegularPlayer => 'العب 10 ألعاب';

  @override
  String get achTitleDedicatedPlayer => 'لاعب مخلص';

  @override
  String get achDescDedicatedPlayer => 'العب 50 لعبة';

  @override
  String get achTitleSnakeEnthusiast => 'عاشق الثعبان';

  @override
  String get achDescSnakeEnthusiast => 'العب 100 لعبة';

  @override
  String get achTitleSnakeAddict => 'مدمن الثعبان';

  @override
  String get achDescSnakeAddict => 'العب 500 لعبة';

  @override
  String get achTitleSurvivor => 'الناجي';

  @override
  String get achDescSurvivor => 'اصمد لمدة 60 ثانية';

  @override
  String get achTitleEndurance => 'التحمّل';

  @override
  String get achDescEndurance => 'اصمد لمدة دقيقتين';

  @override
  String get achTitleMarathon => 'الماراثون';

  @override
  String get achDescMarathon => 'اصمد لمدة 5 دقائق';

  @override
  String get achTitleNoWalls => 'متجنّب الجدران';

  @override
  String get achDescNoWalls => 'العب 5 ألعاب دون الاصطدام بالجدران';

  @override
  String get achTitleSpeedster => 'السريع';

  @override
  String get achDescSpeedster => 'صِل إلى المستوى 10 (السرعة القصوى)';

  @override
  String get achTitlePerfectionist => 'الساعي للكمال';

  @override
  String get achDescPerfectionist => 'أكمل لعبة دون الاصطدام بنفسك';

  @override
  String get achTitleAllFoodTypes => 'الذوّاق';

  @override
  String get achDescAllFoodTypes => 'كُل أنواع الطعام الثلاثة في لعبة واحدة';

  @override
  String get achTitleHalfGrand => 'خمسة آلاف';

  @override
  String get achDescHalfGrand => 'سجّل 5,000 في لعبة واحدة';

  @override
  String get achTitleScoreSniper => 'قنّاص النقاط';

  @override
  String get achDescScoreSniper => 'سجّل 10,000 في لعبة واحدة';

  @override
  String get achTitleFiveDigitClub => 'نادي الخمس خانات';

  @override
  String get achDescFiveDigitClub => 'سجّل 25,000 في لعبة واحدة';

  @override
  String get achTitleScoreTycoon => 'قطب النقاط';

  @override
  String get achDescScoreTycoon => 'سجّل 50,000 في لعبة واحدة';

  @override
  String get achTitleScoreGod => 'إله النقاط';

  @override
  String get achDescScoreGod => 'سجّل 100,000 في لعبة واحدة';

  @override
  String get achTitlePointCollector => 'جامع النقاط';

  @override
  String get achDescPointCollector => 'اجمع 10,000 نقطة إجمالًا';

  @override
  String get achTitlePointHoarder => 'مكتنز النقاط';

  @override
  String get achDescPointHoarder => 'اجمع 100,000 نقطة إجمالًا';

  @override
  String get achTitleHalfMillionClub => 'نادي نصف المليون';

  @override
  String get achDescHalfMillionClub => 'اجمع 500,000 نقطة إجمالًا';

  @override
  String get achTitlePointMillionaire => 'مليونير النقاط';

  @override
  String get achDescPointMillionaire => 'اجمع 1,000,000 نقطة إجمالًا';

  @override
  String get achTitleDecamillionaire => 'صاحب العشرة ملايين';

  @override
  String get achDescDecamillionaire => 'اجمع 10,000,000 نقطة إجمالًا';

  @override
  String get achTitleSnakeVeteran => 'محارب الثعبان القديم';

  @override
  String get achDescSnakeVeteran => 'العب 1,000 لعبة';

  @override
  String get achTitleSnakeLegend => 'أسطورة الثعبان';

  @override
  String get achDescSnakeLegend => 'العب 5,000 لعبة';

  @override
  String get achTitleIronWill => 'إرادة حديدية';

  @override
  String get achDescIronWill => 'اصمد 10 دقائق في لعبة واحدة';

  @override
  String get achTitleEternalSnake => 'الثعبان الخالد';

  @override
  String get achDescEternalSnake => 'اصمد 20 دقيقة في لعبة واحدة';

  @override
  String get achTitleTimeLord => 'سيد الزمن';

  @override
  String get achDescTimeLord => 'اصمد 30 دقيقة في لعبة واحدة';

  @override
  String get achTitleFirstBiteSnack => 'الوجبة الخفيفة الأولى';

  @override
  String get achDescFirstBiteSnack => 'كُل 5 وحدات طعام في لعبة واحدة';

  @override
  String get achTitleHungrySnake => 'الثعبان الجائع';

  @override
  String get achDescHungrySnake => 'كُل 20 وحدة طعام في لعبة واحدة';

  @override
  String get achTitleFamished => 'الجوعان';

  @override
  String get achDescFamished => 'كُل 50 وحدة طعام في لعبة واحدة';

  @override
  String get achTitleRavenous => 'النهم';

  @override
  String get achDescRavenous => 'كُل 100 وحدة طعام في لعبة واحدة';

  @override
  String get achTitleInsatiable => 'الذي لا يشبع';

  @override
  String get achDescInsatiable => 'كُل 200 وحدة طعام في لعبة واحدة';

  @override
  String get achTitleBlackHoleStomach => 'معدة الثقب الأسود';

  @override
  String get achDescBlackHoleStomach => 'كُل 500 وحدة طعام في لعبة واحدة';

  @override
  String get achTitleFoodieApprentice => 'ذوّاق مبتدئ';

  @override
  String get achDescFoodieApprentice => 'كُل 100 وحدة طعام إجمالًا';

  @override
  String get achTitleFoodiePro => 'ذوّاق محترف';

  @override
  String get achDescFoodiePro => 'كُل 1,000 وحدة طعام إجمالًا';

  @override
  String get achTitleFoodieMaster => 'سيد الذوّاقين';

  @override
  String get achDescFoodieMaster => 'كُل 10,000 وحدة طعام إجمالًا';

  @override
  String get achTitleFoodieGod => 'إله الذوّاقين';

  @override
  String get achDescFoodieGod => 'كُل 50,000 وحدة طعام إجمالًا';

  @override
  String get achTitleQuickPlayer => 'اللاعب السريع';

  @override
  String get achDescQuickPlayer => 'العب ساعة واحدة إجمالًا';

  @override
  String get achTitleEngagedPlayer => 'اللاعب المتفاعل';

  @override
  String get achDescEngagedPlayer => 'العب 10 ساعات إجمالًا';

  @override
  String get achTitleHardcorePlayer => 'اللاعب المتفاني';

  @override
  String get achDescHardcorePlayer => 'العب 50 ساعة إجمالًا';

  @override
  String get achTitleSnakeObsessed => 'مهووس الثعبان';

  @override
  String get achDescSnakeObsessed => 'العب 100 ساعة إجمالًا';

  @override
  String get achTitleTouchGrass => 'المس العشب';

  @override
  String get achDescTouchGrass =>
      'العب 250 ساعة إجمالًا — ربما حان وقت الخروج؟';

  @override
  String get achTitleLevel5 => 'المبتدئ';

  @override
  String get achDescLevel5 => 'صِل إلى المستوى 5';

  @override
  String get achTitleLevel10 => 'المتمرّس';

  @override
  String get achDescLevel10 => 'صِل إلى المستوى 10';

  @override
  String get achTitleLevel25 => 'الخبير';

  @override
  String get achDescLevel25 => 'صِل إلى المستوى 25';

  @override
  String get achTitleLevel50 => 'الماهر';

  @override
  String get achDescLevel50 => 'صِل إلى المستوى 50';

  @override
  String get achTitleLevel100 => 'الأستاذ الكبير';

  @override
  String get achDescLevel100 => 'صِل إلى المستوى 100';

  @override
  String get achTitleClassicInitiate => 'مبتدئ الكلاسيكي';

  @override
  String get achDescClassicInitiate => 'أنهِ 10 ألعاب في الوضع الكلاسيكي';

  @override
  String get achTitleClassicVeteran => 'محارب الكلاسيكي';

  @override
  String get achDescClassicVeteran => 'أنهِ 100 لعبة في الوضع الكلاسيكي';

  @override
  String get achTitleClassic1000 => 'خبير الكلاسيكي';

  @override
  String get achDescClassic1000 => 'سجّل 1,000 في الوضع الكلاسيكي';

  @override
  String get achTitleClassic5000 => 'أستاذ الكلاسيكي';

  @override
  String get achDescClassic5000 => 'سجّل 5,000 في الوضع الكلاسيكي';

  @override
  String get achTitleZenInitiate => 'مبتدئ الاسترخاء';

  @override
  String get achDescZenInitiate => 'أنهِ 10 ألعاب في وضع الاسترخاء';

  @override
  String get achTitleZenGarden => 'حديقة الاسترخاء';

  @override
  String get achDescZenGarden => 'سجّل 500 في وضع الاسترخاء';

  @override
  String get achTitleZenMaster => 'سيد الاسترخاء';

  @override
  String get achDescZenMaster => 'سجّل 5,000 في وضع الاسترخاء';

  @override
  String get achTitleSpeedInitiate => 'شغف السرعة';

  @override
  String get achDescSpeedInitiate => 'أنهِ 10 ألعاب في تحدي السرعة';

  @override
  String get achTitleSpeedrunner => 'عدّاء السرعة';

  @override
  String get achDescSpeedrunner => 'سجّل 500 في تحدي السرعة';

  @override
  String get achTitleLightning => 'البرق';

  @override
  String get achDescLightning => 'سجّل 2,000 في تحدي السرعة';

  @override
  String get achTitleMultifoodInitiate => 'عالم الطعام';

  @override
  String get achDescMultifoodInitiate => 'أنهِ 10 ألعاب في وضع الطعام المتعدد';

  @override
  String get achTitleBuffet => 'البوفيه';

  @override
  String get achDescBuffet => 'سجّل 1,000 في وضع الطعام المتعدد';

  @override
  String get achTitleSmorgasbord => 'الوليمة';

  @override
  String get achDescSmorgasbord => 'سجّل 5,000 في وضع الطعام المتعدد';

  @override
  String get achTitleSurvivalInitiate => 'مبتدئ البقاء';

  @override
  String get achDescSurvivalInitiate => 'أنهِ 10 ألعاب في وضع البقاء';

  @override
  String get achTitleSurvivalPro => 'محترف البقاء';

  @override
  String get achDescSurvivalPro => 'اصمد 5 دقائق في وضع البقاء';

  @override
  String get achTitleLastSnakeStanding => 'آخر ثعبان صامد';

  @override
  String get achDescLastSnakeStanding => 'سجّل 2,500 في وضع البقاء';

  @override
  String get achTitleTimeattackInitiate => 'مهاجم الوقت';

  @override
  String get achDescTimeattackInitiate => 'أنهِ 10 ألعاب في وضع سباق الزمن';

  @override
  String get achTitleBeatTheClock => 'اهزم الساعة';

  @override
  String get achDescBeatTheClock => 'اصمد طوال الدقائق الثلاث في سباق الزمن';

  @override
  String get achTitleTimeattackMaster => 'سيد سباق الزمن';

  @override
  String get achDescTimeattackMaster => 'سجّل 3,000 في سباق الزمن';

  @override
  String get achTitleComboStarter => 'مبتدئ السلاسل';

  @override
  String get achDescComboStarter => 'حقق سلسلة 5x في لعبة واحدة';

  @override
  String get achTitleComboMaster => 'سيد السلاسل';

  @override
  String get achDescComboMaster => 'حقق سلسلة 10x في لعبة واحدة';

  @override
  String get achTitleComboPro => 'محترف السلاسل';

  @override
  String get achDescComboPro => 'حقق سلسلة 20x في لعبة واحدة';

  @override
  String get achTitleComboGod => 'إله السلاسل';

  @override
  String get achDescComboGod => 'حقق سلسلة 50x في لعبة واحدة';

  @override
  String get achTitleComboLegend => 'أسطورة السلاسل';

  @override
  String get achDescComboLegend => 'حقق سلسلة 100x في لعبة واحدة';

  @override
  String get achTitleGrowingSnake => 'الثعبان النامي';

  @override
  String get achDescGrowingSnake => 'نمِّ الثعبان حتى طول 20';

  @override
  String get achTitleBigSnake => 'الثعبان الكبير';

  @override
  String get achDescBigSnake => 'نمِّ الثعبان حتى طول 50';

  @override
  String get achTitleHugeSnake => 'الثعبان الضخم';

  @override
  String get achDescHugeSnake => 'نمِّ الثعبان حتى طول 100';

  @override
  String get achTitleMassiveSnake => 'الثعبان الهائل';

  @override
  String get achDescMassiveSnake => 'نمِّ الثعبان حتى طول 200';

  @override
  String get achTitleAnaconda => 'الأناكوندا';

  @override
  String get achDescAnaconda => 'نمِّ الثعبان حتى طول 500';

  @override
  String get achTitleFirstPowerUp => 'تعزيز!';

  @override
  String get achDescFirstPowerUp => 'اجمع أول تعزيز لك';

  @override
  String get achTitlePowerPlayer => 'لاعب القوة';

  @override
  String get achDescPowerPlayer => 'اجمع 10 تعزيزات إجمالًا';

  @override
  String get achTitlePowerHungry => 'المتعطش للقوة';

  @override
  String get achDescPowerHungry => 'اجمع 50 تعزيزًا إجمالًا';

  @override
  String get achTitlePowerAddict => 'مدمن القوة';

  @override
  String get achDescPowerAddict => 'اجمع 200 تعزيز إجمالًا';

  @override
  String get achTitlePowerMaster => 'سيد القوة';

  @override
  String get achDescPowerMaster => 'اجمع 1,000 تعزيز إجمالًا';

  @override
  String get achTitleVarietyPack => 'التشكيلة الكاملة';

  @override
  String get achDescVarietyPack =>
      'اجمع كل نوع من أنواع التعزيزات الأربعة مرة على الأقل';

  @override
  String get achTitleSpeedDemon => 'شيطان السرعة';

  @override
  String get achDescSpeedDemon => 'اجمع 25 تعزيز تسريع';

  @override
  String get achTitleImmortalStreak => 'سلسلة الخلود';

  @override
  String get achDescImmortalStreak => 'اجمع 25 تعزيز حصانة';

  @override
  String get achTitleSpecialDiet => 'حمية خاصة';

  @override
  String get achDescSpecialDiet => 'كُل 50 وحدة طعام خاص إجمالًا';

  @override
  String get achTitleBonusHunter => 'صائد المكافآت';

  @override
  String get achDescBonusHunter => 'كُل 100 وحدة طعام مكافأة إجمالًا';

  @override
  String get achTitleUntouchable5 => 'من لا يُمَس';

  @override
  String get achDescUntouchable5 =>
      'أكمل 5 ألعاب مثالية (دون اصطدام، 30 ثانية+)';

  @override
  String get achTitleUntouchable20 => 'بلا عيوب';

  @override
  String get achDescUntouchable20 => 'أكمل 20 لعبة مثالية';

  @override
  String get achTitleUntouchable50 => 'الأسطورة التي لا تُمَس';

  @override
  String get achDescUntouchable50 => 'أكمل 50 لعبة مثالية';

  @override
  String get achTitleHotStreak => 'سلسلة ملتهبة';

  @override
  String get achDescHotStreak =>
      '5 ألعاب متتالية بنقاط أكبر من 0 ومدة 30 ثانية+';

  @override
  String get achTitleOnFire => 'مشتعل';

  @override
  String get achDescOnFire => 'سلسلة من 10 ألعاب (كل منها 30 ثانية+)';

  @override
  String get achTitleUnstoppable => 'لا يُوقَف';

  @override
  String get achDescUnstoppable => 'سلسلة من 25 لعبة (كل منها 30 ثانية+)';

  @override
  String get achTitleDailyThree => 'اللاعب اليومي';

  @override
  String get achDescDailyThree => 'العب 3 أيام متتالية';

  @override
  String get achTitleWeekWarrior => 'محارب الأسبوع';

  @override
  String get achDescWeekWarrior => 'العب 7 أيام متتالية';

  @override
  String get achTitleVelocity => 'الانطلاقة';

  @override
  String get achDescVelocity => 'صِل إلى المستوى 15 داخل اللعبة في جولة واحدة';

  @override
  String get achTitleMachSpeed => 'سرعة ماخ';

  @override
  String get achDescMachSpeed => 'صِل إلى المستوى 20 داخل اللعبة في جولة واحدة';

  @override
  String get achTitleCosmicSnake => 'الثعبان الكوني';

  @override
  String get achDescCosmicSnake =>
      'صِل إلى المستوى 25 داخل اللعبة في جولة واحدة';

  @override
  String get achTitleModeExplorer => 'مستكشف الأوضاع';

  @override
  String get achDescModeExplorer =>
      'العب لعبة واحدة على الأقل في 3 أوضاع مختلفة';

  @override
  String get achTitleAllModePlayer => 'لاعب كل الأوضاع';

  @override
  String get achDescAllModePlayer =>
      'العب لعبة واحدة على الأقل في كل وضع (8 أوضاع)';

  @override
  String get achTitleNightOwl => 'بومة الليل';

  @override
  String get achDescNightOwl => 'أنهِ لعبة بين منتصف الليل والخامسة فجرًا';

  @override
  String get achTitleEarlyBird => 'الطائر المبكر';

  @override
  String get achDescEarlyBird => 'أنهِ لعبة بين الخامسة والثامنة صباحًا';

  @override
  String get achTitleWeekendWarrior => 'محارب عطلة الأسبوع';

  @override
  String get achDescWeekendWarrior => 'أنهِ 10 ألعاب في عطلات نهاية الأسبوع';

  @override
  String get ppuMegaSpeedBoost => 'تسريع خارق';

  @override
  String get ppuMegaInvincibility => 'حصانة خارقة';

  @override
  String get ppuMegaScoreMultiplier => 'مضاعف نقاط خارق';

  @override
  String get ppuMegaSlowMotion => 'تبطيء خارق';

  @override
  String get ppuTeleport => 'انتقال فوري';

  @override
  String get ppuSizeReducer => 'مقلّص الحجم';

  @override
  String get ppuScoreShield => 'درع النقاط';

  @override
  String get ppuComboMultiplier => 'مضاعف السلاسل';

  @override
  String get ppuTimeWarp => 'تشويه الزمن';

  @override
  String get ppuMagneticFood => 'طعام مغناطيسي';

  @override
  String get ppuGhostMode => 'وضع الشبح';

  @override
  String get ppuDoubleTrouble => 'مشكلة مزدوجة';

  @override
  String get ppuLuckyCharm => 'تميمة الحظ';

  @override
  String get ppuPowerSurge => 'دفقة القوة';

  @override
  String get bundleMegaPack => 'حزمة القوة الخارقة';

  @override
  String get bundleMegaPackDesc => 'نسخ محسّنة من التعزيزات الكلاسيكية';

  @override
  String get bundleTacticalPack => 'الحزمة التكتيكية';

  @override
  String get bundleTacticalPackDesc => 'تعزيزات استراتيجية للاعبين المهرة';

  @override
  String get bundleUltimatePack => 'الحزمة المطلقة';

  @override
  String get bundleUltimatePackDesc => 'كل التعزيزات المميزة المتاحة';

  @override
  String get skinClassic => 'كلاسيكي';

  @override
  String get skinGolden => 'الثعبان الذهبي';

  @override
  String get skinRainbow => 'ثعبان قوس قزح';

  @override
  String get skinGalaxy => 'ثعبان المجرة';

  @override
  String get skinDragon => 'ثعبان التنين';

  @override
  String get skinElectric => 'الثعبان الكهربائي';

  @override
  String get skinFire => 'ثعبان النار';

  @override
  String get skinIce => 'ثعبان الجليد';

  @override
  String get skinShadow => 'ثعبان الظل';

  @override
  String get skinNeon => 'ثعبان النيون';

  @override
  String get skinCrystal => 'الثعبان البلوري';

  @override
  String get skinCosmic => 'الثعبان الكوني';

  @override
  String get skinClassicDesc => 'المظهر الأصلي للثعبان';

  @override
  String get skinGoldenDesc => 'ثعبان ذهبي لامع يتألق مع كل حركة';

  @override
  String get skinRainbowDesc => 'ثعبان ملوّن يتنقل بين ألوان قوس قزح';

  @override
  String get skinGalaxyDesc => 'ثعبان كوني بنقوش نجمية';

  @override
  String get skinDragonDesc => 'ثعبان شرس بحراشف تنين وقوى غامضة';

  @override
  String get skinElectricDesc => 'يتطاير منه شرر الطاقة الكهربائية';

  @override
  String get skinFireDesc => 'يتوهج بنقوش نارية';

  @override
  String get skinIceDesc => 'جمال متجمد بتأثيرات بلورية';

  @override
  String get skinShadowDesc => 'ثعبان ظل داكن وغامض';

  @override
  String get skinNeonDesc => 'يتوهج بأضواء نيون بأسلوب السايبربانك';

  @override
  String get skinCrystalDesc => 'ثعبان بلوري شفاف بتأثيرات منشورية';

  @override
  String get skinCosmicDesc => 'ثعبان من غبار النجوم والمادة الكونية';

  @override
  String get trailNone => 'بدون أثر';

  @override
  String get trailParticle => 'أثر الجسيمات';

  @override
  String get trailGlow => 'أثر متوهج';

  @override
  String get trailRainbow => 'أثر قوس قزح';

  @override
  String get trailFire => 'أثر ناري';

  @override
  String get trailElectric => 'أثر كهربائي';

  @override
  String get trailStar => 'أثر النجوم';

  @override
  String get trailCosmic => 'أثر كوني';

  @override
  String get trailNeon => 'أثر النيون';

  @override
  String get trailShadow => 'أثر الظل';

  @override
  String get trailCrystal => 'أثر بلوري';

  @override
  String get trailDragon => 'أثر التنين';

  @override
  String get trailNoneDesc => 'ثعبان نظيف بدون تأثيرات أثر';

  @override
  String get trailParticleDesc => 'يترك أثرًا من الجسيمات المتلألئة';

  @override
  String get trailGlowDesc => 'أثر متوهج يتلاشى خلف الثعبان';

  @override
  String get trailRainbowDesc => 'تأثير أثر ملوّن بألوان قوس قزح';

  @override
  String get trailFireDesc => 'أثر ناري متّقد مع جمرات';

  @override
  String get trailElectricDesc => 'أثر كهربائي متطاير مع تأثيرات البرق';

  @override
  String get trailStarDesc => 'نجوم متلألئة تتبع مسار الثعبان';

  @override
  String get trailCosmicDesc => 'تأثيرات الغبار الكوني والسديم';

  @override
  String get trailNeonDesc => 'توهج نيون ساطع بأسلوب السايبربانك';

  @override
  String get trailShadowDesc => 'أثر ظل داكن بتأثيرات دخانية';

  @override
  String get trailCrystalDesc => 'شظايا بلورية تتلاشى';

  @override
  String get trailDragonDesc => 'أثر غامض من نفَس التنين';

  @override
  String get coinPackSmall => 'حزمة البداية';

  @override
  String get coinPackMedium => 'حزمة القيمة';

  @override
  String get coinPackLarge => 'الحزمة المميزة';

  @override
  String get coinPackMega => 'الحزمة المطلقة';

  @override
  String coinsAmount(Object coins) {
    return '$coins عملة';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus مكافأة';
  }

  @override
  String get boardSmall => 'صغيرة';

  @override
  String get boardClassic => 'كلاسيكية';

  @override
  String get boardLarge => 'كبيرة';

  @override
  String get boardHuge => 'ضخمة';

  @override
  String get boardEpic => 'ملحمية';

  @override
  String get boardMassive => 'هائلة';

  @override
  String get boardUltimate => 'المطلقة';

  @override
  String get boardSmallDesc => 'ألعاب سريعة ومساحات ضيقة';

  @override
  String get boardClassicDesc => 'تجربة الثعبان الأصلية';

  @override
  String get boardLargeDesc => 'مساحة أكبر للنمو';

  @override
  String get boardHugeDesc => 'أقصى تحدٍ وأكبر مساحة';

  @override
  String get boardEpicDesc => 'لوحة كبيرة للاعبين المتقدمين';

  @override
  String get boardMassiveDesc => 'لوحة عملاقة لألعاب ملحمية';

  @override
  String get boardUltimateDesc => 'أكبر لوحة ممكنة';

  @override
  String get crashLabelSkip => 'تخطٍ';

  @override
  String get crashLabelUntilTap => 'حتى اللمس';

  @override
  String get tgmClassic => 'كلاسيكي';

  @override
  String get tgmSpeedRun => 'سباق السرعة';

  @override
  String get tgmSurvival => 'البقاء';

  @override
  String get tgmNoWalls => 'بدون جدران';

  @override
  String get tgmPowerUpMadness => 'جنون التعزيزات';

  @override
  String get tgmPerfectGame => 'لعبة مثالية';

  @override
  String get tgmClassicDesc => 'قواعد لعبة الثعبان القياسية';

  @override
  String get tgmSpeedRunDesc => 'سرعة اللعبة تزداد بسرعة';

  @override
  String get tgmSurvivalDesc => 'اصمد أطول فترة ممكنة';

  @override
  String get tgmNoWallsDesc => 'الثعبان يعبر من حواف الشاشة';

  @override
  String get tgmPowerUpMadnessDesc => 'التعزيزات تظهر كثيرًا';

  @override
  String get tgmPerfectGameDesc => 'لا مجال للخطأ - اصطدام واحد ينهي اللعبة';

  @override
  String get ttDaily => 'التحدي اليومي';

  @override
  String get ttWeekly => 'البطولة الأسبوعية';

  @override
  String get ttSpecial => 'حدث خاص';

  @override
  String get tsUpcoming => 'قادمة';

  @override
  String get tsActive => 'جارية';

  @override
  String get tsEnded => 'منتهية';

  @override
  String get cdEasy => 'سهل';

  @override
  String get cdMedium => 'متوسط';

  @override
  String get cdHard => 'صعب';

  @override
  String get usOnline => 'متصل';

  @override
  String get usOffline => 'غير متصل';

  @override
  String get usPlaying => 'يلعب';

  @override
  String get bprXpBoost => 'دفعة خبرة';

  @override
  String get bprCoins => 'عملات';

  @override
  String get bprTheme => 'سمة';

  @override
  String get bprSkin => 'مظهر ثعبان';

  @override
  String get bprTrail => 'تأثير أثر';

  @override
  String get bprPowerUp => 'تعزيز';

  @override
  String get bprTournamentEntry => 'دخول بطولة';

  @override
  String get bprTitle => 'لقب لاعب';

  @override
  String get bprAvatar => 'صورة رمزية';

  @override
  String get bprSpecial => 'مكافأة خاصة';

  @override
  String get bprFree => 'مجاني';

  @override
  String get bprPremium => 'مميز';

  @override
  String get bprnStarDust => 'غبار النجوم';

  @override
  String get bprnEnergyPack => 'حزمة الطاقة';

  @override
  String get bprnBronzeEntry => 'دخول برونزي';

  @override
  String get bprnSilverEntry => 'دخول فضي';

  @override
  String get bprnStargazer => 'راصد النجوم';

  @override
  String get bprnVoyager => 'الرحّالة';

  @override
  String get bprnNebulaTheme => 'سمة السديم';

  @override
  String get bprnStardustTrail => 'أثر غبار النجوم';

  @override
  String get bprnLegendaryCrate => 'صندوق أسطوري';

  @override
  String get bprnMegaXp => 'خبرة خارقة';

  @override
  String get bprnCosmicCharge => 'شحنة كونية';

  @override
  String get bprnNovaBurst => 'انفجار المستعر';

  @override
  String get bprnGalaxySkin => 'مظهر المجرة';

  @override
  String get bprnCrystalSerpent => 'الأفعوان البلوري';

  @override
  String get bprnPlasmaWake => 'موجة البلازما';

  @override
  String get bprnCosmicAura => 'هالة كونية';

  @override
  String get bprnCyberpunkTheme => 'سمة السايبربانك';

  @override
  String get bprnCrystalTheme => 'سمة البلور';

  @override
  String get bprnSeasonTrophy => 'كأس الموسم';

  @override
  String get bprnCosmicCrown => 'التاج الكوني';

  @override
  String get bprnCosmicLegend => 'الأسطورة الكونية';

  @override
  String get bprnStarCommander => 'قائد النجوم';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity عملة';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type ×$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'مكافأة مجانية: $type';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'مكافأة مميزة حصرية: $type';
  }
}
