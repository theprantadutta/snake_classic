// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settingsSectionLanguage => 'اللغة';

  @override
  String get languageSystemDefault => 'إعداد النظام';

  @override
  String get languageSystemDefaultSubtitle => 'اتباع لغة الجهاز';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get mpOpponent => 'الخصم';

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
  String get mpRewardProcessing => 'جارٍ معالجة المكافآت…';

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
  String get mpReconnectingInline => 'إعادة اتصال…';

  @override
  String get puSpeedBoost => 'تعزيز السرعة';

  @override
  String get puInvincibility => 'المناعة';

  @override
  String get puScoreMultiplier => 'مضاعف النقاط';

  @override
  String get puSlowMotion => 'الحركة البطيئة';

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
  String get homeStartPlaying => 'ابدأ اللعب';

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
  String get settingsSnapMovement => 'حركة متقطعة';

  @override
  String get settingsSnapMovementSubtitle =>
      'التحرك خلية بخلية كما في اللعبة الأصلية. تُنفَّذ الانعطافات فور الضغط.';

  @override
  String get settingsControlLayout => 'تخطيط الأزرار';

  @override
  String get settingsControlLayoutDPad => 'أزرار الاتجاهات';

  @override
  String get settingsControlLayoutDPadDesc => 'أعلى، أسفل، يسار، يمين';

  @override
  String get settingsControlLayoutTurn => 'أزرار الانعطاف';

  @override
  String get settingsControlLayoutTurnDesc =>
      'انعطف يسارًا أو يمينًا من اتجاهك الحالي. لا رجوع للخلف أبدًا.';

  @override
  String get gameTurnLeft => 'انعطاف يسارًا';

  @override
  String get gameTurnRight => 'انعطاف يمينًا';

  @override
  String get gameTurnControls => 'أزرار الانعطاف';

  @override
  String get settingsControlLayoutStick => 'عصا التحكم';

  @override
  String get settingsControlLayoutStickDesc =>
      'ادفع في أي مكان بالشريط نحو الاتجاه المطلوب. استمر بالضغط للاستمرار في التوجيه.';

  @override
  String get gameJoystick => 'عصا التحكم';

  @override
  String get gameJoystickHint => 'ادفع للتوجيه';

  @override
  String get wtControlOptionsTitle => 'لا تحب السحب؟';

  @override
  String get wtControlOptionsMsg =>
      'تفضّل الأزرار؟ أوقف اللعبة مؤقتًا واختر أزرار الاتجاهات، أو زرّي انعطاف كبيرين، أو عصا تحكم عائمة. فعّل الحركة المتقطعة إذا أردت أن يُنفَّذ كل انعطاف فور الضغط. كل هذا موجود أيضًا في الإعدادات ← التحكم.';

  @override
  String get insTurnButtons => 'أزرار الانعطاف';

  @override
  String get insTurnButtonsDesc =>
      'زران كبيران، واحد في كل زاوية: انعطاف يسارًا، انعطاف يمينًا. لا رجوع للخلف أبدًا';

  @override
  String get insJoystick => 'عصا التحكم';

  @override
  String get insJoystickDesc =>
      'ادفع في أي مكان بالشريط نحو الاتجاه المطلوب؛ استمر بالضغط للاستمرار في التوجيه';

  @override
  String get insSnap => 'حركة متقطعة';

  @override
  String get insSnapDesc =>
      'التحرك خلية بخلية كما في اللعبة الأصلية، لتُنفَّذ الانعطافات فور الضغط';

  @override
  String get settingsOnScreenControls => 'أزرار الشاشة';

  @override
  String get settingsOnScreenControlsDesc =>
      'أزرار الاتجاهات أو أزرار الانعطاف أو عصا التحكم — اختر من تخطيط الأزرار';

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
  String get settingsGameModeLocked => 'أكمل اللعبة الحالية لتغيير النمط';

  @override
  String get settingsEasyNote =>
      'العملات والخبرة والإنجازات تُحتسب في الوضع السهل — تتوقف الأرقام القياسية والتصنيفات فقط.';

  @override
  String get settingsDifficultyLocked => 'أنهِ اللعبة الحالية لتغيير الصعوبة.';

  @override
  String get settingsBoardSizeLocked => 'أكمل اللعبة الحالية لتغيير حجم اللوحة';

  @override
  String get settingsCrashFeedbackSubtitle => 'مدة عرض شرح الاصطدام';

  @override
  String get settingsScreenShake => 'اهتزاز الشاشة';

  @override
  String get settingsScreenShakeSubtitle =>
      'هزّ الشاشة عند الاصطدامات وأحداث اللعبة';

  @override
  String get settingsBrowseThemes => 'تصفح السمات';

  @override
  String get settingsSnakeTrail => 'مؤثرات أثر الثعبان';

  @override
  String get settingsSnakeTrailSubtitle => 'تفعيل أثر الجسيمات خلف الثعبان';

  @override
  String get settingsSectionDisplay => 'العرض';

  @override
  String get settingsDisplayHz => 'هرتز';

  @override
  String settingsDisplayUpTo(String rate) {
    return 'حتى $rate هرتز';
  }

  @override
  String get settingsDisplayReading => 'جارٍ قراءة شاشتك…';

  @override
  String get settingsDisplayCurrentCaption =>
      'معدل تحديث شاشتك في الوقت الحالي.';

  @override
  String get settingsDisplayBatteryNote =>
      'وضع توفير البطارية مفعّل، لذا قد تبقى شاشتك على المعدل القياسي حتى تُوقفه.';

  @override
  String get settingsDisplayThermalNote =>
      'جهازك دافئ. قد يبقى على معدل أقل لبعض الوقت حتى يبرد، وهذا أمر طبيعي.';

  @override
  String get settingsDisplaySingleRateNote =>
      'تعمل هذه الشاشة بمعدل تحديث واحد فقط، لذا لا يوجد ما يمكن تفعيله هنا. اللعبة سلسة بالفعل بأقصى ما يتيحه هذا الجهاز.';

  @override
  String get settingsDisplayFooter =>
      'معدلات التحديث الأعلى تجعل الثعبان والقوائم أكثر سلاسة، وتستهلك قدرًا أكبر قليلًا من البطارية. يُبقي Snake Classic هذا الخيار مفعّلًا افتراضيًا ولا يتجاوز إعدادات توفير الطاقة في جهازك.';

  @override
  String get settingsDisplaySupportedTitle => 'هذه الشاشة';

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
  String get accountSwitchTitle => 'تسجيل الدخول إلى حساب موجود؟';

  @override
  String get accountSwitchBody =>
      'إذا سبق اللعب بـ Snake Classic على هذا الحساب، فسيُستعاد تقدّمه ويصبح هو تقدّمك. العملات والنتائج والإحصائيات الموجودة على هذا الجهاز لن تُنقل.\n\nللاحتفاظ بتقدّم هذا الجهاز، استخدم حسابًا لم تلعب به من قبل.';

  @override
  String get accountSwitchConfirm => 'تسجيل الدخول على أي حال';

  @override
  String get settingsAuthenticatedAccount => 'حساب موثّق';

  @override
  String get accountNotBackedUpTitle => 'لا توجد نسخة احتياطية';

  @override
  String get accountNotBackedUpBody =>
      'هذا التقدّم مرتبط بهذا التثبيت. سجّل الدخول لتتمكّن من استعادته بعد إعادة التثبيت أو على هاتف جديد.';

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
  String get legalAutoRenewDisclosureAppStore =>
      'يُخصم المبلغ من حساب App Store الخاص بك عند تأكيد الشراء. يتجدد الاشتراك تلقائيًا بالسعر نفسه وللمدة نفسها ما لم يتم إلغاؤه قبل 24 ساعة على الأقل من نهاية الفترة الحالية. يمكنك إدارة الاشتراك أو إلغاؤه في أي وقت من إعدادات حسابك بعد الشراء.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'يُخصم المبلغ من حساب Google Play الخاص بك عند تأكيد الشراء. يتجدد الاشتراك تلقائيًا بالسعر نفسه وللمدة نفسها ما لم يتم إلغاؤه قبل 24 ساعة على الأقل من نهاية الفترة الحالية. يمكنك إدارة الاشتراك أو إلغاؤه في أي وقت من إعدادات اشتراكات Google Play بعد الشراء.';

  @override
  String get legalTermsEulaLink => 'شروط الاستخدام (EULA)';

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
  String get mpLobbyGo => 'انطلق!';

  @override
  String get mpLobbyGetReady => 'استعد!';

  @override
  String get mpLobbyRoomCodeCopied => 'تم نسخ رمز الغرفة!';

  @override
  String get mpLobbyFinding => 'جارٍ البحث...';

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
  String get mpLobbyConnectionLostTitle => 'انقطع الاتصال';

  @override
  String get mpLobbyConnectionLostBody =>
      'انقطع اتصالك أثناء البحث.\nتحقق من الواي فاي أو بيانات الهاتف وحاول مرة أخرى.';

  @override
  String get mpLobbyTimedOutTitle => 'لا توجد مباراة بعد';

  @override
  String get mpLobbyTimedOutBody =>
      'استغرق هذا البحث وقتًا أطول مما ينبغي.\nحاول مرة أخرى — عادةً ما يُعثر على مباراة في أقل من دقيقة.';

  @override
  String get mpLobbyWaitingForConnection =>
      'انقطع الاتصال — بانتظار إعادة الاتصال…';

  @override
  String get mpLobbyUnreachableTitle => 'تعذّر الوصول إلى المطابقة';

  @override
  String get mpLobbyUnreachableBody =>
      'لم نتمكن من الوصول إلى الخادم.\nتحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get mpLobbyGoBack => 'رجوع';

  @override
  String get mpLobbyTryAgain => 'حاول مجددًا';

  @override
  String get mpLobbyJoinRoom => 'انضم إلى غرفة';

  @override
  String get mpLobbyEnterRoomCode => 'أدخل رمز الغرفة';

  @override
  String get mpLobbyWaitingForPlayer => 'بانتظار لاعب...';

  @override
  String get mpLobbyStartGame => 'ابدأ اللعبة';

  @override
  String get mpLobbyWaitingForHost => 'بانتظار أن يبدأ المضيف...';

  @override
  String get mpLobbyReadyDone => 'جاهز!';

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
  String goAdBonusCoins(Object count) {
    return '🎉 +$count عملة إضافية للمشاهدة!';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'حصلت على $count عملة من التحديات اليومية!';
  }

  @override
  String get goRibbonTournamentSubmitted => 'أُرسلت نتيجة البطولة!';

  @override
  String get goRibbonTournamentFailed => 'لم تُرسل النتيجة — تحقق من الاتصال';

  @override
  String get goRibbonTournamentSubmitting => 'جارٍ إرسال نتيجة البطولة…';

  @override
  String goAdNoticeRewarded(Object count) {
    return 'إعلان قصير بعد ذلك · +$count عملة مقابل المشاهدة';
  }

  @override
  String get goAdNoticeInterstitial => 'سيُعرض إعلان قصير بعد ذلك';

  @override
  String get adBreakStarting => 'جارٍ بدء الإعلان…';

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
  String storeBonusMultiplier(Object multiplier) {
    return 'مكافأة ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds => 'اشترك قبل انتهاء برو المجاني';

  @override
  String get storeMonthly => 'شهري';

  @override
  String get storeYearly => 'سنوي';

  @override
  String get storePerMonth => '/شهر';

  @override
  String get storePerYear => '/سنة';

  @override
  String storeFreeTrialBadge(Object days) {
    return 'تجربة مجانية لمدة $days أيام';
  }

  @override
  String get storeStartFreeTrial => 'ابدأ التجربة المجانية';

  @override
  String storePlanDisplayName(Object title) {
    return 'خطة $title';
  }

  @override
  String get storeVerifyingEllipsis => 'جارٍ التحقق…';

  @override
  String get storeYoureOnFreePro => 'لديك برو مجاني!';

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
  String storeInitiatingPurchase(Object name) {
    return 'جارٍ بدء شراء $name...';
  }

  @override
  String get storeSubNotAvailable => 'الاشتراك غير متاح. حاول لاحقًا.';

  @override
  String get storePurchaseFailed => 'فشل الشراء. حاول مرة أخرى.';

  @override
  String get storePurchasePending =>
      'الدفع قيد الانتظار. سيتم فتح مشترياتك بمجرد تأكيد المتجر لها.';

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
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get pfSigningOut => 'جارٍ تسجيل الخروج...';

  @override
  String get pfStatistics => 'الإحصائيات';

  @override
  String get pfReplays => 'الإعادات';

  @override
  String get pfLoadingStats => 'جارٍ تحميل الإحصائيات...';

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
  String get frLeaderboardSubtitle => 'نافس أصدقاءك';

  @override
  String get frLoadingLeaderboard => 'جارٍ تحميل الترتيب...';

  @override
  String frRankBadge(Object rank) {
    return '#$rank';
  }

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
  String get acLocked => 'المقفلة';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String get acEmpty => 'لا إنجازات هنا';

  @override
  String acXpReward(Object xp) {
    return '+$xp خبرة';
  }

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
  String get lbWeeklySub =>
      'مرتب حسب أفضل نتيجة لك هذا الأسبوع (يُعاد الضبط يوم الأحد)';

  @override
  String get lbLoadingGlobal => 'جارٍ تحميل التصنيف العالمي...';

  @override
  String get lbLoadingWeekly => 'جارٍ تحميل التصنيف الأسبوعي...';

  @override
  String get lbNoScores => 'لا نتائج بعد';

  @override
  String get lbNoWeekly => 'لا نتائج هذا الأسبوع';

  @override
  String get lbPlayThisWeek => 'العب هذا الأسبوع لتظهر هنا!';

  @override
  String get lbAnonymous => 'مجهول';

  @override
  String get lbPts => 'نقطة';

  @override
  String bpClaimedToast(Object name) {
    return 'تم استلام $name!';
  }

  @override
  String get bpLoading => 'جارٍ تحميل تذكرة المعركة...';

  @override
  String get bpXpEarned => '+50 خبرة لتذكرة المعركة!';

  @override
  String bpHoursLeft(Object hours) {
    return 'بقي $hours س';
  }

  @override
  String get bpSeasonCompleteUpper => 'اكتمل الموسم';

  @override
  String get bpSeasonCosmicSerpent => 'موسم الأفعى الكونية';

  @override
  String get bpUnlockedEverything => 'فتحت كل مستويات هذا الموسم.';

  @override
  String bpTierN(Object tier) {
    return 'المستوى $tier';
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
  String get pbActiveSub => 'لديك وصول إلى كل ميزات بريميوم';

  @override
  String get pbYourPlan => 'خطتك';

  @override
  String get pbPlanMonthly => 'شهري';

  @override
  String get pbPlanYearly => 'سنوي';

  @override
  String pbRenewsOn(Object date) {
    return 'يتجدد في $date';
  }

  @override
  String get pbSwitchToYearly => 'التبديل إلى السنوي';

  @override
  String get pbSwitchToMonthly => 'التبديل إلى الشهري';

  @override
  String get pbSwitchToYearlyBlurb =>
      'يبدأ اليوم. يُحتسب باقي الشهر، وتوفّر 33% سنويًا.';

  @override
  String get pbSwitchToMonthlyBlurb =>
      'يبدأ عند انتهاء سنتك المدفوعة. لا يوجد خصم اليوم.';

  @override
  String get pbManageSubscription => 'إدارة الاشتراك';

  @override
  String get pbManageBlurb => 'ألغِ أو حدّث الدفع من المتجر';

  @override
  String get pbSwitchedToYearly => 'تم التبديل إلى السنوي';

  @override
  String get pbSwitchedToMonthly => 'يبدأ الشهري بعد انتهاء هذه الفترة';

  @override
  String get pbAllUnlocked => 'كل هذا لك';

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
  String get pbFeatTournament => 'دخول البطولات';

  @override
  String get pbFeatTournamentDesc =>
      '1× برونزي + 1× فضي + 1× ذهبي في كل دورة فوترة';

  @override
  String get pbNotAvailable => 'اشتراك بريميوم غير متاح';

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
  String get faChooseHow => 'اختر طريقة اللعب:';

  @override
  String get faSigningIn => 'جارٍ تسجيل دخولك...';

  @override
  String get faSignInEmail => 'تسجيل الدخول بالبريد';

  @override
  String get faContinueGuest => 'المتابعة كضيف';

  @override
  String get faReviewNote =>
      'يرجى مراجعة سياسة الخصوصية وشروط الاستخدام قبل المتابعة';

  @override
  String get faAgreeCheckbox =>
      'قرأت سياسة الخصوصية وشروط الاستخدام وأوافق عليهما';

  @override
  String get faContinueToSignIn => 'المتابعة إلى تسجيل الدخول';

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
  String get ldStepCore => 'تشغيل الأنظمة الأساسية...';

  @override
  String get ldStepProfile => 'إنشاء ملفك الشخصي...';

  @override
  String get ldStepPrefs => 'تحميل تفضيلاتك...';

  @override
  String get ldStepCloud => 'المزامنة مع السحابة...';

  @override
  String get ldStepGameData => 'تحميل بيانات اللعبة...';

  @override
  String get ldStepAudio => 'إعداد نظام الصوت...';

  @override
  String get ldStepAds => 'تجهيز المكافآت...';

  @override
  String get ldStepSetup => 'التحقق من حالة الإعداد...';

  @override
  String get ldWelcome => 'مرحبًا!';

  @override
  String get ldReady => 'جاهز للعب!';

  @override
  String ldInitFailed(Object error) {
    return 'فشل التشغيل: $error';
  }

  @override
  String get ldRetrying => 'إعادة محاولة التشغيل...';

  @override
  String get ldInitFailedUpper => 'فشل التشغيل';

  @override
  String get ldRetryUpper => 'إعادة المحاولة';

  @override
  String get pgPreparing => 'تجهيز الساحة';

  @override
  String get pgTournamentMode => 'وضع البطولة';

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
  String get wtControlsTitle => 'التوجيه';

  @override
  String get wtControlsMsg =>
      'غيّر الاتجاه بالسحب على اللوحة، أو بأزرار الاتجاهات أو أزرار الانعطاف أو عصا التحكم على الشاشة، أو بمفاتيح الأسهم. اختر أسلوبك من الإعدادات ← التحكم أو من قائمة الإيقاف المؤقت.';

  @override
  String get wtPracticeRightTitle => 'جرّب — اتجه يمينًا';

  @override
  String get wtPracticeRightMsg =>
      'اتجه يمينًا للمتابعة. يمكنك استخدام السحب أو لوحة الاتجاهات أو مفاتيح الأسهم.';

  @override
  String get wtPracticeUpTitle => 'ممتاز — الآن اتجه لأعلى';

  @override
  String get wtPracticeUpMsg => 'اتجه لأعلى للمتابعة.';

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
      'اضغط أيقونة الإيقاف المؤقت لتجميد الجولة. من هناك يمكنك المتابعة أو إعادة البدء أو فتح دليل اللعبة أو إعادة هذا الدرس أو تبديل أسلوب التحكم أو تفعيل الحركة المتقطعة.';

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
  String get wtSwipeRightUpper => 'يمينًا';

  @override
  String get wtSwipeLeftUpper => 'يسارًا';

  @override
  String get wtSwipeUpUpper => 'لأعلى';

  @override
  String get wtSwipeDownUpper => 'لأسفل';

  @override
  String get wtSwipeAnywhereScreen => 'السحب أو لوحة الاتجاهات أو الأسهم';

  @override
  String get wtSwipeAnywhere => 'دورك!';

  @override
  String get wtGotIt => 'فهمت!';

  @override
  String get wtNext => 'التالي';

  @override
  String get wtSkip => 'تخطي';

  @override
  String get wtWaiting => 'بانتظارك...';

  @override
  String get hwDailyTitle => 'التحديات اليومية';

  @override
  String get hwDailyMsg =>
      'أكمل التحديات اليومية لعملات ومكافآت إضافية. تحديات جديدة كل يوم!';

  @override
  String get hudScoreUpper => 'النتيجة';

  @override
  String hudScoreSemantics(Object value) {
    return 'النتيجة $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'مستوى $level';
  }

  @override
  String get hudTournamentBadge => 'بطولة';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poStore => 'المتجر';

  @override
  String get poSnapOn => 'التقطيع: يعمل';

  @override
  String get poSnapOff => 'التقطيع: متوقف';

  @override
  String get updateReadyTitle => 'التحديث جاهز';

  @override
  String get updateReadyRestart => 'إعادة التشغيل';

  @override
  String get poUpdateReady => 'أعد التشغيل للتحديث';

  @override
  String get poHowToPlay => 'طريقة اللعب';

  @override
  String get poGameGuide => 'دليل اللعبة';

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

  @override
  String get insHowToPlay => 'طريقة اللعب';

  @override
  String get insObjective => 'الهدف';

  @override
  String get insObjectiveBody =>
      'تحكم في الثعبان ليأكل الطعام ويكبر قدر الإمكان دون الاصطدام بالجدران أو بنفسه!';

  @override
  String get insControls => 'التحكم';

  @override
  String get insSwipeUp => 'اسحب لأعلى ↑';

  @override
  String get insSwipeUpDesc => 'يحرّك الثعبان لأعلى';

  @override
  String get insSwipeDown => 'اسحب لأسفل ↓';

  @override
  String get insSwipeDownDesc => 'يحرّك الثعبان لأسفل';

  @override
  String get insSwipeLeft => 'اسحب لليسار ←';

  @override
  String get insSwipeLeftDesc => 'يحرّك الثعبان لليسار';

  @override
  String get insSwipeRight => 'اسحب لليمين →';

  @override
  String get insSwipeRightDesc => 'يحرّك الثعبان لليمين';

  @override
  String get insArrowKeys => 'مفاتيح الأسهم';

  @override
  String get insArrowKeysDesc => 'تغيير الاتجاه';

  @override
  String get insWasd => 'WASD';

  @override
  String get insWasdDesc => 'تغيير الاتجاه';

  @override
  String get insSpacebar => 'مسطرة المسافة';

  @override
  String get insSpacebarDesc => 'إيقاف/استئناف اللعبة';

  @override
  String get insFoodTypes => 'أنواع الطعام';

  @override
  String get insNormalFood => 'طعام عادي';

  @override
  String get insBonusFood => 'طعام مكافأة';

  @override
  String get insSpecialFood => 'طعام خاص';

  @override
  String get insRules => 'القواعد';

  @override
  String get insRule1 => 'كُل الطعام لتكبر وتزيد نقاطك';

  @override
  String get insRule2 => 'يتسارع الثعبان كلما ارتفع مستواك';

  @override
  String get insRule3 => 'تنتهي اللعبة إذا اصطدمت بجدار أو بنفسك';

  @override
  String get insRule4 => 'يظهر الطعام الخاص كل 10 وجبات عادية';

  @override
  String get insRule5 => 'يختفي طعام المكافأة بعد 15 ثانية';

  @override
  String get insProTips => 'نصائح احترافية';

  @override
  String get insTip1 => 'خطط لحركاتك مسبقًا';

  @override
  String get insTip2 => 'استخدم الحواف لإنشاء مساحات آمنة';

  @override
  String get insTip3 => 'انتبه لمؤشرات السحب المرئية';

  @override
  String get insTip4 => 'تدرّب على مستويات صعوبة مختلفة';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return 'حصلت على $coins عملة و$xp خبرة!';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return 'حصلت على $coins عملة!';
  }

  @override
  String get dchWatchTo2x => 'شاهد لمضاعفة 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 تضاعفت! +$coins عملة مكافأة!';
  }

  @override
  String get dchAllCompleteTitle => 'اكتملت كل التحديات!';

  @override
  String get dchBonusClaimed => 'تم استلام مكافأة الإكمال';

  @override
  String get dchBonusPending => 'المكافأة بانتظارك — استلم أي تحدٍ';

  @override
  String get dchCheckBack => 'عُد لاحقًا لتحديات يومية جديدة!';

  @override
  String get dchAbout => 'عن التحديات اليومية';

  @override
  String get dchAbout1 => 'تحديات جديدة كل يوم عند منتصف الليل';

  @override
  String get dchAbout2 => 'أكمل التحديات لتكسب العملات';

  @override
  String get dchAbout3 => 'اكسب الخبرة لترفع مستوى ملفك';

  @override
  String get dchAbout4 => 'أكمل الثلاثة كلها لمكافأة إضافية!';

  @override
  String get dchAllBonusTitle => 'مكافأة كل التحديات';

  @override
  String get dchAllBonusDesc => 'أكملت كل تحديات اليوم.';

  @override
  String get wqNoQuests => 'لا مهام أسبوعية بعد — عُد يوم الاثنين';

  @override
  String get wqTitle => 'المهام الأسبوعية';

  @override
  String get rvNotFound => 'الإعادة غير موجودة';

  @override
  String get rvLoadFailed => 'تعذّر تحميل الإعادة';

  @override
  String get rvLoadingTitle => 'جارٍ تحميل الإعادة...';

  @override
  String get rvLoading => 'جارٍ تحميل الإعادة...';

  @override
  String get rvGoBack => 'رجوع';

  @override
  String get rvScore => 'النقاط';

  @override
  String get rvLevel => 'المستوى';

  @override
  String get rvFrame => 'الإطار';

  @override
  String get rvTime => 'الوقت';

  @override
  String get rvNoFrameData => 'لا بيانات إطارات';

  @override
  String get rvSpeedLabel => 'السرعة: ';

  @override
  String rvAteFood(Object type) {
    return '🍎 أكل طعام $type';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ جمع تعزيز $type';
  }

  @override
  String get unEmpty => 'اسم المستخدم لا يمكن أن يكون فارغًا';

  @override
  String get unSetFailed => 'تعذّر تعيين اسم المستخدم';

  @override
  String get unPickTitle => 'اختر اسم المستخدم';

  @override
  String get unPickBody =>
      'هكذا ستظهر في لوحة الصدارة. اخترنا لك اسمًا — احتفظ به أو غيّره.';

  @override
  String get unLabel => 'اسم المستخدم';

  @override
  String get unSaving => 'جارٍ الحفظ...';

  @override
  String get unContinue => 'متابعة';

  @override
  String get unChangeAnytime => 'يمكنك تغييره في أي وقت من الإعدادات.';

  @override
  String unMinLength(Object min) {
    return 'يجب ألا يقل اسم المستخدم عن $min حرفًا';
  }

  @override
  String unMaxLength(Object max) {
    return 'يجب ألا يزيد اسم المستخدم عن $max حرفًا';
  }

  @override
  String get unPattern =>
      'يجب أن يبدأ الاسم بحرف وأن يحتوي على حروف وأرقام وشرطات سفلية فقط';

  @override
  String get unReserved => 'اسم المستخدم هذا محجوز ولا يمكن استخدامه';

  @override
  String get unTaken => 'اسم المستخدم هذا مستخدم بالفعل';

  @override
  String get unUpdateFailed => 'تعذّر تحديث اسم المستخدم';

  @override
  String pcVersionLine(Object version) {
    return 'الإصدار $version · يُرجى المراجعة والموافقة للمتابعة';
  }

  @override
  String get pcTabPrivacy => 'سياسة الخصوصية';

  @override
  String get pcTabTerms => 'شروط الاستخدام';

  @override
  String get pcAgree =>
      'قرأت سياسة الخصوصية وشروط الاستخدام المحدّثتين وأوافق عليهما';

  @override
  String get pcContinue => 'متابعة';

  @override
  String lgAvailableAt(Object url) {
    return 'هذا المستند متاح على $url.';
  }

  @override
  String get lgUnavailable =>
      'هذا المستند غير متاح حاليًا. حاول مرة أخرى لاحقًا.';

  @override
  String get auTitle => 'سجّل لإتمام المشتريات';

  @override
  String get auBody =>
      'يمكن لحسابات الضيف اللعب وحفظ التقدم محليًا، لكن لا يمكنها شراء العناصر أو الاشتراك. اربط حسابًا لفتح المشتريات — وستبقى عملاتك وأزياؤك وأعلى نتائجك مرتبطة بك.';

  @override
  String get auApple => 'المتابعة باستخدام Apple';

  @override
  String get auAppleSub =>
      'سجّل الدخول بحساب Apple ID. يمكن أن يبقى بريدك الإلكتروني خاصًا.';

  @override
  String get auGoogle => 'المتابعة عبر Google';

  @override
  String get auGoogleSub => 'الخيار الأسرع. سجّل الدخول بحساب Google.';

  @override
  String get auLinked => 'تم ربط الحساب. يمكنك الآن الشراء.';

  @override
  String get auEmail => 'إنشاء حساب بريد إلكتروني';

  @override
  String get auEmailSub =>
      'استخدم أي بريد وكلمة مرور تختارها. استعد بياناتك على أي جهاز.';

  @override
  String get auNotNow => 'ليس الآن';

  @override
  String get auErrCredentialInUse =>
      'بيانات الاعتماد هذه مرتبطة بحساب آخر. جرّب تسجيل الدخول بها.';

  @override
  String get auErrAlreadyLinked => 'هذا الحساب مرتبط بالفعل.';

  @override
  String get auErrRequiresRecentLogin =>
      'لأمانك، سجّل الدخول مجددًا قبل الربط.';

  @override
  String get auErrNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get auErrGeneric => 'فشل الربط. حاول مرة أخرى.';

  @override
  String get sroSettingUpTitle => 'جارٍ إعداد حسابك…';

  @override
  String get sroSettingUpBody =>
      'نجهّز كل شيء لجلستك الأولى. يحدث هذا مرة واحدة فقط.';

  @override
  String get sroLoadingTitle => 'جارٍ تحميل بياناتك السابقة…';

  @override
  String get sroLoadingBody =>
      'نجلب إحصاءاتك وإنجازاتك وعملاتك ومفتوحاتك من السحابة.';

  @override
  String get sroRestoringTitle => 'جارٍ استعادة تقدمك…';

  @override
  String get sroRestoringBody =>
      'نطبّق كل شيء على هذا الجهاز. لا تغلق التطبيق.';

  @override
  String get sroDoneTitle => 'كل شيء جاهز!';

  @override
  String get sroDoneBody => 'تمت استعادة تقدمك.';

  @override
  String get sroFailedTitle => 'تعذّرت استعادة بياناتك';

  @override
  String get sroFailedBody =>
      'لم نتمكن من الوصول إلى السحابة الآن. تحقق من الإنترنت وحاول مجددًا. يمكنك أيضًا المتابعة دون استعادة — سنحاول مرة أخرى عند فتح التطبيق تاليًا.';

  @override
  String get sroTryAgain => 'حاول مرة أخرى';

  @override
  String get sroContinueAnyway => 'متابعة على أي حال';

  @override
  String get ssiOfflinePending => 'غير متصل - ستتزامن التغييرات عند الاتصال';

  @override
  String get ssiSyncing => 'جارٍ المزامنة...';

  @override
  String get ssiAllSynced => 'تمت مزامنة كل البيانات';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فشل $count عنصر في المزامنة',
      many: 'فشل $count عنصرًا في المزامنة',
      few: 'فشلت $count عناصر في المزامنة',
      two: 'فشل عنصران في المزامنة',
      one: 'فشل عنصر واحد في المزامنة',
      zero: 'لا عناصر فشلت في المزامنة',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر بانتظار المزامنة',
      many: '$count عنصرًا بانتظار المزامنة',
      few: '$count عناصر بانتظار المزامنة',
      two: 'عنصران بانتظار المزامنة',
      one: 'عنصر واحد بانتظار المزامنة',
      zero: 'لا عناصر بانتظار المزامنة',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'غير متصل';

  @override
  String get rvoLoadingAd => 'جارٍ تحميل الإعلان…';

  @override
  String get tbTimesUp => 'انتهى الوقت!';

  @override
  String tbKeepGoing(Object seconds) {
    return 'واصل اللعب · $seconds ث';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'شاهد إعلانًا — +$seconds ث';
  }

  @override
  String get tbEndRun => 'إنهاء الجولة';

  @override
  String get dbTitle => 'المكافأة اليومية';

  @override
  String get dbClaimToday => 'استلم مكافأتك اليومية!';

  @override
  String get dbComeBack => 'عُد غدًا!';

  @override
  String dbDayChip(Object day) {
    return 'يوم $day';
  }

  @override
  String get dbTodaysReward => 'مكافأة اليوم';

  @override
  String get dbAlreadyClaimed => 'تم الاستلام اليوم';

  @override
  String get dbClaim => 'استلام المكافأة';

  @override
  String get dbClaim2x => 'استلام 2× — شاهد إعلانًا';

  @override
  String get npPrimerTitle => 'لا يفوتك شيء!';

  @override
  String get npPrimerBody =>
      'نرسل إشعارين أو ثلاثة في اليوم فقط — تذكير تحدّيك اليومي والأحداث الخاصة.\n\nبلا إزعاج، وعدٌ منا. 🐍';

  @override
  String get npMaybeLater => 'ربما لاحقًا';

  @override
  String get npAllSet => '🎉 كل شيء جاهز!';

  @override
  String get npTurnOn => 'تفعيل';

  @override
  String get npSoftTitle => 'تريد البقاء على اطلاع؟';

  @override
  String get npSoftBody =>
      'فعّل الإشعارات وسنذكّرك بتحدياتك اليومية وسلاسلك — إضافة إلى الأخبار الكبيرة مثل هدايا Premium المجانية والأحداث الخاصة.\n\nإشعاران في اليوم فقط، بلا إزعاج. 🐍';

  @override
  String get npNotNow => 'ليس الآن';

  @override
  String get npEnable => 'تفعيل الإشعارات';

  @override
  String get aroUnlocked => 'إنجاز جديد';

  @override
  String get aroTapToContinue => 'المس للمتابعة';

  @override
  String get aroSkip => 'تخطٍ';

  @override
  String aroSkipCount(Object count) {
    return 'تخطٍ ($count)';
  }

  @override
  String get luLevelUp => 'مستوى جديد!';

  @override
  String luReached(Object level) {
    return 'وصلت إلى المستوى $level';
  }

  @override
  String get luNice => 'رائع';

  @override
  String get cfTapContinue => 'المس أي مكان للمتابعة';

  @override
  String get cfTapSkip => 'المس أي مكان للتخطي';

  @override
  String ppgLvShort(Object level) {
    return 'مستوى $level';
  }

  @override
  String ppgLvUpper(Object level) {
    return 'مستوى $level';
  }

  @override
  String ppgLevel(Object level) {
    return 'المستوى $level';
  }

  @override
  String get xgTitle => 'الخروج من اللعبة؟';

  @override
  String get xgBody => 'هل تريد الخروج فعلًا؟ سيضيع تقدمك الحالي.';

  @override
  String get xgExit => 'خروج';

  @override
  String get ccTitle => 'كيف تريد اللعب؟';

  @override
  String get ccBody =>
      'اختر واحدة — يمكنك تغييرها في أي وقت من الإعدادات ← التحكم.';

  @override
  String get ccSwipe => 'إيماءات السحب';

  @override
  String get ccSwipeSub => 'اسحب في أي مكان على اللوحة للانعطاف.';

  @override
  String get ccDpad => 'أزرار D-Pad';

  @override
  String get ccDpadSub => 'أزرار اتجاهات على الشاشة.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 أُضيفت +$coins عملة إلى محفظتك!';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'شاهد إعلانًا — +$coins عملة';
  }

  @override
  String get rcNoAd => 'لا إعلانات متاحة الآن';

  @override
  String get raOptIn => 'اختياري — شاهد واكسب';

  @override
  String get compassSemantics => 'مؤشر اتجاه السحب';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 تضاعفت المكافأة اليومية — +$coins عملة مكافأة!';
  }

  @override
  String get nsNewNotification => 'لديك إشعار جديد';

  @override
  String get nsAchievementUnlocked => '🏆 إنجاز جديد!';

  @override
  String get nsDailyReminderTitle => '🐍 حان وقت لعب Snake Classic!';

  @override
  String get nsDailyReminderBody => 'أكمل تحدّيك اليومي وتسلّق لوحة الصدارة!';

  @override
  String get mpErrMatchmaking => 'فشل البحث عن مباراة. حاول مرة أخرى.';

  @override
  String get mpErrCreateFailed => 'تعذّر إنشاء اللعبة';

  @override
  String get mpErrJoinFailed =>
      'تعذّر الانضمام. قد تكون اللعبة ممتلئة أو غير موجودة.';

  @override
  String get mpErrReadyFailed => 'تعذّر تحديث حالة الاستعداد';

  @override
  String get mpErrStartFailed => 'تعذّر بدء اللعبة';

  @override
  String get mpErrStartTimeout => 'انتهت مهلة بدء اللعبة. حاول مرة أخرى.';

  @override
  String get mpErrReconnectFailed => 'تعذّر إعادة الاتصال بالمباراة.';

  @override
  String get mpErrConnectionLost => 'انقطع الاتصال — تعذّر استئناف المباراة.';

  @override
  String get mpErrMatchEndedAway => 'انتهت المباراة أثناء غيابك.';

  @override
  String get mpErrWaitingReady => 'بانتظار استعداد جميع اللاعبين';

  @override
  String get mpErrOnlyHost => 'المضيف فقط يمكنه بدء اللعبة';

  @override
  String get mpErrSessionExpired => 'انتهت جلسة اللعبة. أنشئ لعبة جديدة';

  @override
  String get mpErrAlreadyStarted => 'هذه اللعبة بدأت بالفعل';

  @override
  String get mpErrNeedTwoPlayers => 'تتطلب المباريات لاعبَين اثنين بالضبط';

  @override
  String get mpErrSignIn => 'سجّل الدخول للعب أونلاين';

  @override
  String get mpErrReconnectExpired => 'انتهت مهلة إعادة الاتصال';

  @override
  String get mpErrCheckInternet => 'انقطع الاتصال. تحقق من الإنترنت';

  @override
  String get mpErrUnableJoin => 'تعذّر دخول الغرفة. حاول مرة أخرى';

  @override
  String get mpErrGeneric => 'حدث خطأ ما. حاول مرة أخرى';

  @override
  String stDurSeconds(Object s) {
    return '$s ث';
  }

  @override
  String stDurMinutes(Object m) {
    return '$m د';
  }

  @override
  String stDurHours(Object h) {
    return '$h س';
  }

  @override
  String stDurMinSec(Object m, Object s) {
    return '$m د $s ث';
  }

  @override
  String stDurHourMin(Object h, Object m) {
    return '$h س $m د';
  }

  @override
  String wqClaimable(Object count) {
    return '$count جاهزة للاستلام';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins عملة، +$xp خبرة تذكرة';
  }

  @override
  String get insPoints10 => '10 نقاط';

  @override
  String get insPoints25 => '25 نقطة';

  @override
  String get insPoints50 => '50 نقطة + مستوى جديد';

  @override
  String get unRules =>
      '• من 3 إلى 20 حرفًا\n• يجب أن يبدأ بحرف\n• حروف وأرقام وشرطات سفلية فقط';

  @override
  String get dcTitleScoreEasy => 'نقاط المبتدئ';

  @override
  String get dcTitleScoreMedium => 'لاعب ماهر';

  @override
  String get dcTitleScoreHard => 'سيد النقاط';

  @override
  String get dcTitleFoodEasy => 'الثعبان الجائع';

  @override
  String get dcTitleFoodMedium => 'وضع الوليمة';

  @override
  String get dcTitleFoodHard => 'الذي لا يشبع';

  @override
  String get dcTitleSurvivalEasy => 'الناجي';

  @override
  String get dcTitleSurvivalMedium => 'التحمّل';

  @override
  String get dcTitleSurvivalHard => 'الخالد';

  @override
  String get dcTitleGamesEasy => 'لاعب عابر';

  @override
  String get dcTitleGamesMedium => 'مخلص';

  @override
  String get dcTitleGamesHard => 'مدمن الثعبان';

  @override
  String get dcTitleModeEasy => 'عاشق الكلاسيكي';

  @override
  String get dcTitleModeMedium => 'سيد الاسترخاء';

  @override
  String get dcTitleModeHard => 'شيطان السرعة';

  @override
  String dcDescScore(Object target) {
    return 'سجّل ما لا يقل عن $target نقطة في لعبة واحدة';
  }

  @override
  String dcDescFood(Object target) {
    return 'كُل اليوم $target وحدة طعام';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'اصمد $target ثانية في لعبة واحدة';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'العب $target لعبة اليوم',
      many: 'العب $target لعبة اليوم',
      few: 'العب $target ألعاب اليوم',
      two: 'العب لعبتين اليوم',
      one: 'العب لعبة واحدة اليوم',
      zero: 'لا تلعب اليوم',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'العب $target لعبة في وضع $mode',
      many: 'العب $target لعبة في وضع $mode',
      few: 'العب $target ألعاب في وضع $mode',
      two: 'العب لعبتين في وضع $mode',
      one: 'العب لعبة واحدة في وضع $mode',
      zero: 'لا ألعاب في وضع $mode',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'إحماء الأسبوع';

  @override
  String get wqTitleScoreMedium => 'ردود فعل أدق';

  @override
  String get wqTitleScoreHard => 'بطل النقاط';

  @override
  String get wqTitleFoodEasy => 'وجبة الأسبوع الخفيفة';

  @override
  String get wqTitleFoodMedium => 'النهم';

  @override
  String get wqTitleFoodHard => 'بلا قاع';

  @override
  String get wqTitleGamesEasy => 'خمس في الأسبوع';

  @override
  String get wqTitleGamesMedium => 'عادة راسخة';

  @override
  String get wqTitleGamesHard => 'عدّاء الماراثون';

  @override
  String get wqTitleSurvivalEasy => 'زحف الدقيقتين';

  @override
  String get wqTitleSurvivalMedium => 'زحف الخمس دقائق';

  @override
  String get wqTitleSurvivalHard => 'زحف العشر دقائق';

  @override
  String get wqTitleTournament => 'رائد البطولات';

  @override
  String get wqTitleDailyEasy => 'منجز يومي';

  @override
  String get wqTitleDailyMedium => 'خبير يومي';

  @override
  String wqDescScore(Object target) {
    return 'سجّل $target في لعبة واحدة';
  }

  @override
  String wqDescFood(Object target) {
    return 'كُل $target وحدة طعام هذا الأسبوع';
  }

  @override
  String wqDescGames(Object target) {
    return 'العب $target لعبة هذا الأسبوع';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'اصمد $target ث في لعبة واحدة';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'العب $target لعبة بطولة',
      many: 'العب $target لعبة بطولة',
      few: 'العب $target ألعاب بطولة',
      two: 'العب لعبتي بطولة',
      one: 'العب لعبة بطولة واحدة',
      zero: 'لا ألعاب بطولة',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'أكمل $target تحديات يومية هذا الأسبوع';
  }

  @override
  String tnNameDaily(Object date) {
    return 'التحدي اليومي - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'البطولة الأسبوعية - الأسبوع $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'الجائزة الكبرى الشهرية - $monthYear';
  }

  @override
  String get tnDescDaily =>
      'نافس على أعلى النقاط في تحدي اليوم على مدار 24 ساعة! أفضل اللاعبين يفوزون بالعملات والمجد.';

  @override
  String get tnDescWeekly =>
      'المواجهة الأسبوعية الحاسمة! نافس أفضل اللاعبين على جوائز ضخمة.';

  @override
  String get tnDescMonthly =>
      'أكبر بطولة في الشهر! أثبت أنك سيد الثعبان الحقيقي.';

  @override
  String tnRewardRank(Object rank) {
    return 'المركز $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'مكافأة عملات للمركز $rank';
  }

  @override
  String get achTitleScore1500 => 'الزخم';

  @override
  String get achDescScore1500 => 'سجّل 1,500 نقطة في لعبة واحدة';

  @override
  String get achTitleScore3000 => 'في أوج الحماس';

  @override
  String get achDescScore3000 => 'سجّل 3,000 نقطة في لعبة واحدة';

  @override
  String get achTitleScore7500 => 'بلا هوادة';

  @override
  String get achDescScore7500 => 'سجّل 7,500 نقطة في لعبة واحدة';

  @override
  String get achTitleScore15000 => 'صياد القمة';

  @override
  String get achDescScore15000 => 'سجّل 15,000 نقطة في لعبة واحدة';

  @override
  String get achTitleScore35000 => 'عقل آلي';

  @override
  String get achDescScore35000 => 'سجّل 35,000 نقطة في لعبة واحدة';

  @override
  String get achTitleScore75000 => 'فوق طاقة البشر';

  @override
  String get achDescScore75000 => 'سجّل 75,000 نقطة في لعبة واحدة';

  @override
  String get achTitleScore250000 => 'ربع مليون';

  @override
  String get achDescScore250000 => 'سجّل 250,000 نقطة في لعبة واحدة';

  @override
  String get achTitleBeyondTime => 'خارج الزمن';

  @override
  String get achDescBeyondTime => 'اصمد 45 دقيقة في لعبة واحدة';

  @override
  String get achTitleHourbound => 'ساعة كاملة';

  @override
  String get achDescHourbound => 'اصمد ساعة كاملة في لعبة واحدة';

  @override
  String get achTitleSnakeDevotee => 'مريد الثعبان';

  @override
  String get achDescSnakeDevotee => 'العب 2,500 لعبة';

  @override
  String get achTitleTenThousandClub => 'نادي العشرة آلاف';

  @override
  String get achDescTenThousandClub => 'العب 10,000 لعبة';

  @override
  String get achTitleZenVeteran => 'محارب الاسترخاء';

  @override
  String get achDescZenVeteran => 'أنهِ 100 لعبة في وضع الاسترخاء';

  @override
  String get achTitleSpeedVeteran => 'محارب السرعة';

  @override
  String get achDescSpeedVeteran => 'أنهِ 100 لعبة في تحدي السرعة';

  @override
  String get achTitleMultifoodVeteran => 'محارب الطعام المتعدد';

  @override
  String get achDescMultifoodVeteran => 'أنهِ 100 لعبة في وضع الطعام المتعدد';

  @override
  String get achTitleTimeattackVeteran => 'محارب سباق الزمن';

  @override
  String get achDescTimeattackVeteran => 'أنهِ 100 لعبة في سباق الزمن';

  @override
  String get achTitleSurvivalVeteran => 'محارب البقاء';

  @override
  String get achDescSurvivalVeteran => 'أنهِ 100 لعبة في وضع البقاء';

  @override
  String get achTitlePumInitiate => 'مبتدئ الجنون';

  @override
  String get achDescPumInitiate => 'أنهِ 10 ألعاب في جنون التعزيزات';

  @override
  String get achTitlePumVeteran => 'محارب الجنون';

  @override
  String get achDescPumVeteran => 'أنهِ 100 لعبة في جنون التعزيزات';

  @override
  String get achTitlePerfectInitiate => 'التقي';

  @override
  String get achDescPerfectInitiate => 'أنهِ 10 جولات في اللعبة المثالية';

  @override
  String get achTitlePerfectVeteran => 'الانضباط';

  @override
  String get achDescPerfectVeteran => 'أنهِ 100 جولة في اللعبة المثالية';

  @override
  String get achTitleZen10000 => 'فيض الاسترخاء';

  @override
  String get achDescZen10000 => 'سجّل 10,000 في وضع الاسترخاء';

  @override
  String get achTitleSpeed5000 => 'الوميض';

  @override
  String get achDescSpeed5000 => 'سجّل 5,000 في تحدي السرعة';

  @override
  String get achTitleMultifood10000 => 'بوفيه بلا نهاية';

  @override
  String get achDescMultifood10000 => 'سجّل 10,000 في وضع الطعام المتعدد';

  @override
  String get achTitleTimeattack5000 => 'سباق مع الساعة';

  @override
  String get achDescTimeattack5000 => 'سجّل 5,000 في سباق الزمن';

  @override
  String get achTitlePum2000 => 'مشحون بالكامل';

  @override
  String get achDescPum2000 => 'سجّل 2,000 في جنون التعزيزات';

  @override
  String get achTitlePerfect1000 => 'جولة بلا أخطاء';

  @override
  String get achDescPerfect1000 => 'سجّل 1,000 في وضع اللعبة المثالية';

  @override
  String get achTitleComboSingularity => 'تفرد السلاسل';

  @override
  String get achDescComboSingularity => 'حقق سلسلة 200x في لعبة واحدة';

  @override
  String get achTitleWorldSerpent => 'ثعبان العالم';

  @override
  String get achDescWorldSerpent => 'نمِّ الثعبان حتى طول 750';

  @override
  String get achTitleLightspeed => 'سرعة الضوء';

  @override
  String get achDescLightspeed =>
      'صِل إلى المستوى 30 داخل اللعبة في جولة واحدة';

  @override
  String get achTitlePowerOverwhelming => 'قوة ساحقة';

  @override
  String get achDescPowerOverwhelming => 'اجمع 5,000 تعزيز إجمالًا';

  @override
  String get achTitleGreedIsGood => 'الطمع مفيد';

  @override
  String get achDescGreedIsGood => 'اجمع 25 تعزيز مضاعف النقاط';

  @override
  String get achTitleTimeBender => 'مطوّع الزمن';

  @override
  String get achDescTimeBender => 'اجمع 25 تعزيز التبطيء';

  @override
  String get achTitleGastronome => 'خبير المأكولات';

  @override
  String get achDescGastronome => 'كُل 100,000 وحدة طعام إجمالًا';

  @override
  String get achTitleLivingLegend => 'أسطورة حية';

  @override
  String get achDescLivingLegend => 'اجمع 50,000,000 نقطة إجمالًا';

  @override
  String get achTitlePerpetualMotion => 'الحركة الدائمة';

  @override
  String get achDescPerpetualMotion => 'سلسلة من 50 لعبة (كل منها 30 ثانية+)';

  @override
  String get achTitleImmaculate => 'بلا شائبة';

  @override
  String get achDescImmaculate => 'أكمل 100 لعبة مثالية';

  @override
  String get achTitleFortnightFaithful => 'وفيّ لأسبوعين';

  @override
  String get achDescFortnightFaithful => 'العب 14 يومًا متتاليًا';

  @override
  String get achTitleSteadySnake => 'الثعبان الثابت';

  @override
  String get achDescSteadySnake => 'اصمد 30+ ثانية في 100 لعبة';

  @override
  String get achTitleMarathonMonth => 'روح الماراثون';

  @override
  String get achDescMarathonMonth => 'اصمد 30+ ثانية في 1,000 لعبة';

  @override
  String get achTitleLunchtimeLegend => 'أسطورة الغداء';

  @override
  String get achDescLunchtimeLegend => 'أنهِ لعبة بين الظهر والثانية ظهرًا';

  @override
  String get legalNoticePrefix => 'باللعب، فإنك توافق على ';

  @override
  String get legalNoticeAnd => ' و ';

  @override
  String get dayOneReminderTitle => 'ثعبانك يفتقدك 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'أفضل نتيجة لك $score. هل يمكنك تجاوزها؟';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      'جولة سريعة؟ أول نتيجة قياسية بانتظارك.';

  @override
  String get goTomorrowLabel => 'عُد غدًا';

  @override
  String goTomorrowReward(int coins, int day) {
    return 'احصل على $coins عملة في اليوم $day من سلسلتك';
  }

  @override
  String get rvAteFoodUnknown => '🍎 أكل طعامًا';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ التقط تعزيزًا';

  @override
  String get boardTall => 'طويلة';

  @override
  String get boardTallDesc => 'تملأ شاشة الهاتف — مساحة أكبر للحركة';

  @override
  String get boardTallPlus => 'طويلة بلس';

  @override
  String get boardTallPlusDesc => 'ساحة أكبر بشكل الهاتف';

  @override
  String get mpErrReadyTimeout =>
      'لم يستعدّ اللاعبان في الوقت المحدد. نبحث عن مباراة جديدة…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'تأكيد الجاهزية · $secondsث';
  }

  @override
  String get mpLobbyWaitingOpponentReady => 'بانتظار جاهزية خصمك…';

  @override
  String get gameDirectionalPad => 'لوحة الاتجاهات';

  @override
  String get gameGoHome => 'الانتقال إلى الشاشة الرئيسية';

  @override
  String get gamePauseGame => 'إيقاف اللعبة مؤقتًا';

  @override
  String get gameResumeGame => 'متابعة اللعبة';

  @override
  String get gameLeaveMatch => 'مغادرة المباراة';

  @override
  String get gameSteerUp => 'الاتجاه لأعلى';

  @override
  String get gameSteerDown => 'الاتجاه لأسفل';

  @override
  String get gameSteerLeft => 'الاتجاه يسارًا';

  @override
  String get gameSteerRight => 'الاتجاه يمينًا';

  @override
  String get mpTurnBlocked => 'محظور';

  @override
  String get insHudPause => 'زر الإيقاف المؤقت';

  @override
  String get insHudPauseDesc => 'إيقاف مؤقت أو متابعة — أعلى يمين شاشة اللعبة';

  @override
  String get insDpad => 'لوحة اتجاهات على الشاشة';

  @override
  String get insDpadDesc =>
      'أزرار اختيارية بأربعة اتجاهات للانعطاف بدلًا من السحب';

  @override
  String get insControlsNote =>
      'فعّل أزرار الشاشة أو عطّلها، واختر أزرار الاتجاهات أو أزرار الانعطاف أو عصا التحكم، واضبط الحركة المتقطعة من الإعدادات ← التحكم — أو من قائمة الإيقاف المؤقت أثناء اللعب.';

  @override
  String get insVersus => 'مواجهة';

  @override
  String get insVersusOnline => 'مواجهة فردية عبر الإنترنت';

  @override
  String get insVersusOnlineDesc =>
      'قواعد كلاسيكية، أفعيان، لوحة واحدة، في الوقت الفعلي';

  @override
  String get insVersusQuick => 'مباراة سريعة';

  @override
  String get insVersusQuickDesc => 'يجد لك خصمًا تلقائيًا';

  @override
  String get insVersusRoom => 'غرفة خاصة';

  @override
  String get insVersusRoomDesc =>
      'أنشئ غرفة وشارك الرمز، أو انضم إلى غرفة صديق';

  @override
  String get homeVersusCta => 'مواجهة';

  @override
  String get homeVersusSubtitle =>
      'مواجهة فردية كلاسيكية · مباراة سريعة أو ادعُ صديقًا';

  @override
  String get hwVersusTitle => 'العب ضد شخص آخر';

  @override
  String get hwVersusMsg =>
      'المواجهة هي لعب فردي كلاسيكي عبر الإنترنت. المباراة السريعة تجد لك خصمًا، أو أنشئ غرفة خاصة وادعُ صديقًا.';

  @override
  String get hwHelpTitle => 'أي شيء آخر؟';

  @override
  String get hwHelpMsg =>
      'القواعد والتحكم والمواجهة كلها موضحة هنا، والإعدادات بجوارها.';

  @override
  String get insOnPhone => 'على الهاتف';

  @override
  String get insOnKeyboard => 'على لوحة المفاتيح';

  @override
  String get settingsSectionYourGame => 'لعبتك';

  @override
  String get settingsStatisticsSubtitle => 'كل جولاتك مجموعة';

  @override
  String get settingsReplaysSubtitle => 'شاهد جولاتك المحفوظة';

  @override
  String get updateAvailableTitle => 'يتوفر تحديث';

  @override
  String updateAvailableBody(String version) {
    return 'إصدار Snake Classic ‏$version متاح الآن على App Store. حدِّث للحصول على أحدث الميزات والإصلاحات.';
  }

  @override
  String get updateRequiredTitle => 'التحديث مطلوب';

  @override
  String get updateRequiredBody =>
      'لم يعد هذا الإصدار من Snake Classic مدعومًا. حدِّث من App Store لمواصلة اللعب.';

  @override
  String get updateActionUpdate => 'تحديث';

  @override
  String get updateActionLater => 'لاحقًا';

  @override
  String get updateOpenStoreFailed => 'تعذّر فتح App Store';

  @override
  String get lbHomeHint => 'وجّه الثعبان نحو مربع. أو انقر. لن نحكم عليك.';

  @override
  String lbDailyNag(String done, String total) {
    return 'اليومية $done/$total · وجبة أخرى من فضلك';
  }

  @override
  String get lbDailyCheck => 'تحديات اليوم';

  @override
  String get lbDailyAllFed => 'شبعنا. عُد غدًا.';

  @override
  String lbModeRow(String index, String count, String mode) {
    return 'الوضع $index/$count · $mode';
  }

  @override
  String get lbYourBest => 'أفضل نتيجة لك';

  @override
  String get lbPlay => 'العب';

  @override
  String lbModeBoard(String mode, String board) {
    return '$mode · $board';
  }

  @override
  String get lbHomeVersus => 'مواجهة';

  @override
  String lbHomeVersusSub(String rating) {
    return '1 ضد 1 · التقييم $rating';
  }

  @override
  String lbHomeDaily(String done, String total) {
    return 'اليومية $done/$total';
  }

  @override
  String lbHomeDailySub(String time, String coins) {
    return 'تتجدد خلال $time · +$coins¢';
  }

  @override
  String get lbHomeSeason => 'الموسم';

  @override
  String lbHomeSeasonSub(String tier, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بقي $days يوم',
      many: 'بقي $days يومًا',
      few: 'بقيت $days أيام',
      two: 'بقي يومان',
      one: 'بقي يوم واحد',
      zero: 'ينتهي اليوم',
    );
    return 'المستوى $tier · $_temp0';
  }

  @override
  String get lbHomeRanks => 'الترتيب';

  @override
  String lbHomeRanksSub(String rank) {
    return '#$rank · في صعود';
  }

  @override
  String lbHomeRanksSubNone(String score) {
    return 'أفضل جولة: $score';
  }

  @override
  String get lbHomeStore => 'المتجر';

  @override
  String get lbHomeStoreSub => 'مظاهر، سمات، آثار';

  @override
  String get lbHomeProfile => 'الملف';

  @override
  String lbHomeProfileSub(String level, String runs) {
    return 'مستوى $level · الجولات: $runs';
  }

  @override
  String get lbHomeMenu => 'القائمة';

  @override
  String get lbFreePowerUp => 'تعزيز مجاني · إعلان';

  @override
  String get lbTipLabel => 'نصيحة';

  @override
  String get lbTip1 => 'الجدار لا يتحرك. أنت من يتحرك.';

  @override
  String get lbTip2 => 'السلاسل تتلاشى بعد 6 ثوانٍ. واصل المضغ.';

  @override
  String get lbTip3 => 'وضع الاسترخاء بلا جدران. العقبة الوحيدة هي أنت.';

  @override
  String get lbTip4 => 'الجولات السهلة لا تدخل التصنيف. لا عيب في ذلك.';

  @override
  String get lbTip5 => 'الطعام الإضافي بـ 25. والخاص بـ 50. والطمع مجاني.';

  @override
  String get lbTip6 => 'اسحب مبكرًا. الثعبان لا يحب المفاجآت.';

  @override
  String get lbTip7 => 'اللعبة المثالية: لا تطأ الخلية نفسها مرتين. بالتوفيق.';

  @override
  String get lbTip8 => 'إحياء مجاني للاعبي Pro. مجرد ملاحظة.';

  @override
  String lbSplashStatus(String pct) {
    return 'نُسخّن التفاح… $pct%';
  }

  @override
  String lbSplashFooter(String version) {
    return 'v$version · لم يُصب أي ثعبان بأذى';
  }

  @override
  String get lbSetupTitle => 'التجهيز';

  @override
  String get lbSetupSubtitle => 'اختر سُمّك. كل الأوضاع مجانية. للأبد.';

  @override
  String get lbSetupMode => 'الوضع';

  @override
  String lbSetupModesAside(String count) {
    return 'الأوضاع: $count · بلا أي دفع';
  }

  @override
  String get lbSetupBoard => 'اللوحة';

  @override
  String get lbSetupDifficulty => 'الصعوبة';

  @override
  String get lbSetupLoadout => 'العتاد';

  @override
  String get lbSetupGet => 'احصل';

  @override
  String get lbBoardTall => 'طولية';

  @override
  String get lbModeLineClassic => 'الجدران تعضّ.';

  @override
  String get lbModeLineZen => 'بلا جدران. استرخِ فقط.';

  @override
  String get lbModeLineSpeed => 'سريع. ثم أسرع.';

  @override
  String get lbModeLineMultiFood => 'البوفيه مفتوح.';

  @override
  String get lbModeLineSurvival => '3 أرواح. أنفقها بحكمة.';

  @override
  String get lbModeLineTimeAttack => '3 دقائق. كُل كل شيء.';

  @override
  String get lbModeLinePowerUp => 'تعزيزات. كثيرة جدًا.';

  @override
  String get lbModeLinePerfect => 'لا تخطُ مرتين.';

  @override
  String get lbDiffEasyLine => 'تدريب · بلا تصنيف';

  @override
  String get lbDiffNormalLine => 'الإيقاع الكلاسيكي';

  @override
  String get lbDiffHardLine => 'للمستعرضين';

  @override
  String lbComboWarm(String mult) {
    return '×$mult دافئ';
  }

  @override
  String lbComboHot(String mult) {
    return '×$mult ساخن · واصل الأكل';
  }

  @override
  String lbComboFire(String mult) {
    return '×$mult مشتعل';
  }

  @override
  String get lbComboDecay => 'كُل شيئًا. الآن.';

  @override
  String get lbComboBroken => 'انكسرت السلسلة. يحدث.';

  @override
  String lbLevelUp(String level) {
    return 'مستوى $level · أسرع الآن';
  }

  @override
  String lbLevelShort(String level) {
    return 'مستوى $level';
  }

  @override
  String lbPowerInvincible(String secs) {
    return 'مناعة · $secsث';
  }

  @override
  String get lbPowerInvincibleLine => 'الجدران مجرد اقتراح';

  @override
  String lbPowerSpeed(String secs) {
    return 'سرعة · $secsث';
  }

  @override
  String get lbPowerSpeedLine => 'تمسّك جيدًا';

  @override
  String lbPowerSlow(String secs) {
    return 'حركة بطيئة · $secsث';
  }

  @override
  String get lbPowerSlowLine => 'تذوّق اللحظة';

  @override
  String lbPowerScore(String secs) {
    return '2× نقاط · $secsث';
  }

  @override
  String lbPowerEnding(String name, String secs) {
    return '$name ينتهي · $secs';
  }

  @override
  String get lbTimeAttackPanic => '10 ثوانٍ. اذعر بمسؤولية.';

  @override
  String lbLifeLost(String left) {
    return 'خسرت روحًا · المتبقي $left';
  }

  @override
  String lbHudLen(String len) {
    return 'الطول $len';
  }

  @override
  String get lbScoreLabel => 'النقاط';

  @override
  String get lbTurnLeft => 'انعطف يسارًا';

  @override
  String get lbTurnRight => 'انعطف يمينًا';

  @override
  String get lbSwipeToSteer => 'اسحب للتوجيه';

  @override
  String get lbPauseTitle => 'إيقاف مؤقت';

  @override
  String get lbPauseLine => 'التفاحة ستنتظر. على الأرجح.';

  @override
  String get lbResume => 'استئناف';

  @override
  String get lbResumeSub => '3 · 2 · 1، ثم انطلق';

  @override
  String get lbRestart => 'إعادة البدء';

  @override
  String get lbRestartSub => 'الوضع نفسه';

  @override
  String get lbPauseSettings => 'الإعدادات';

  @override
  String get lbPauseSettingsSub => 'التحكم · الصوت';

  @override
  String get lbQuit => 'الخروج للقائمة';

  @override
  String get lbQuitSub => 'تنتهي الجولة هنا';

  @override
  String lbPauseSoFar(String score, String len, String time) {
    return 'حتى الآن · $score نقطة · الطول $len · $time';
  }

  @override
  String get lbCrashWallTitle => 'طاخ!';

  @override
  String lbCrashWall1(String len) {
    return 'قبّلت الجدار عند الطول $len.';
  }

  @override
  String get lbCrashWall2 => 'الجدار كان هنا قبلك.';

  @override
  String get lbCrashWall3 => 'الجدران: لم تُهزم منذ الأزل.';

  @override
  String get lbCrashWallScore => 'الجدار: 1 · أنت: 0';

  @override
  String get lbCrashSelfTitle => 'آخ.';

  @override
  String get lbCrashSelf1 => 'عضضت نفسك. لماذا؟';

  @override
  String get lbCrashSelf2 => 'الذيل: لذيذ على ما يبدو.';

  @override
  String get lbCrashSelf3 => 'رُصدت وجبة ذاتية.';

  @override
  String get lbCrashTimeTitle => 'انتهى الوقت!';

  @override
  String get lbCrashTime1 => 'نفد الوقت. هرب التفاح.';

  @override
  String lbCrashTime2(String food) {
    return 'ثلاث دقائق. التفاح: $food. احترامي.';
  }

  @override
  String get lbCrashStepTitle => 'خطوة مكررة.';

  @override
  String get lbCrashStep1 => 'مشيت على أثرك. اللعبة المثالية لا تسامح.';

  @override
  String get lbCrashQuitTitle => 'انسحاب.';

  @override
  String get lbCrashQuit1 => 'أنهيت الجولة بنفسك. لم نرَ شيئًا.';

  @override
  String get lbCrashGeneric => 'انتهت اللعبة.';

  @override
  String lbGameOverHeadline(String line) {
    return '× $line';
  }

  @override
  String get lbReviveTitle => 'فرصة ثانية؟';

  @override
  String lbSeconds(String secs) {
    return '$secsث';
  }

  @override
  String lbReviveLine(String len, String score) {
    return 'احتفظ بالطول $len وبكل النقاط ($score).';
  }

  @override
  String get lbReviveWatch => 'شاهد إعلانًا · مجانًا';

  @override
  String lbRevivePay(String cost) {
    return 'ادفع $cost¢';
  }

  @override
  String lbReviveYouHave(String coins) {
    return 'لديك $coins';
  }

  @override
  String get lbReviveDecline => 'لا، أرني نتيجتي';

  @override
  String get lbRevivePro => 'إحياء · مجاني مع Pro';

  @override
  String get lbReviveProHint => 'إحياء مجاني للاعبي Pro. مجرد ملاحظة.';

  @override
  String get lbGoBest => 'الأفضل';

  @override
  String lbGoBehind(String gap) {
    return '−$gap';
  }

  @override
  String get lbGoBehindLine => 'قريب جدًا. (ليس فعلًا.)';

  @override
  String get lbGoNewBest => 'رقم قياسي جديد!';

  @override
  String get lbGoNewBestLine => 'علّق هذه في إطار.';

  @override
  String lbGoRun(String run) {
    return 'الجولة $run';
  }

  @override
  String get lbGoChartTitle => 'جولتك، مفرودة';

  @override
  String lbGoChartStats(String food, String combo) {
    return 'الطعام $food · الذروة ×$combo';
  }

  @override
  String get lbGoChartCaption => 'عمود = وجبة · الأطول = الألذ';

  @override
  String get lbAgain => 'مجددًا';

  @override
  String get lbGoContinue => 'متابعة';

  @override
  String lbGoContinueSub(String cost, String len) {
    return '$cost¢ أو إعلان · احتفظ بالطول $len';
  }

  @override
  String lbGoContinueProSub(String len) {
    return 'مجانًا مع Pro · احتفظ بالطول $len';
  }

  @override
  String lbGoEarned(String coins) {
    return '+$coins¢ مكتسبة';
  }

  @override
  String lbGoRewardsLine(String ready, String coins, String xp) {
    return 'يومية جاهزة: $ready · +$coins¢ · +$xp خبرة';
  }

  @override
  String get lbGoNothingToClaim => 'لا شيء للاستلام بعد · واصل اللعب';

  @override
  String get lbClaim => 'استلم';

  @override
  String get lbGoDoubleCoins => '2× عملات · إعلان';

  @override
  String get lbGoWatchReplay => 'شاهد الإعادة';

  @override
  String get lbHome => 'الرئيسية';

  @override
  String get lbDailyTitle => 'اليومية';

  @override
  String get lbDailySubtitle => 'ثلاث وجبات يوميًا. أوامر الطبيب.';

  @override
  String lbDailyProgress(String done, String total) {
    return 'أُنجز $done من $total';
  }

  @override
  String lbDailyStreak(int days, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'السلسلة: $days يوم',
      many: 'السلسلة: $days يومًا',
      few: 'السلسلة: $days أيام',
      two: 'السلسلة: يومان',
      one: 'السلسلة: يوم واحد',
      zero: 'السلسلة: 0',
    );
    return '$_temp0 · تتجدد خلال $time';
  }

  @override
  String lbResetsIn(String time) {
    return 'تتجدد خلال $time';
  }

  @override
  String get lbClaimAll => 'استلم الكل';

  @override
  String get lbClaimAllDouble => 'استلم الكل ×2';

  @override
  String get lbClaimAllDoubleLine => 'إعلان قصير، غنائم مضاعفة';

  @override
  String lbWeeklyTeaser(String done, String total) {
    return 'المهام الأسبوعية · $done/$total';
  }

  @override
  String get lbWeeklyTeaserLine => 'الغنائم الكبرى يوم الأحد';

  @override
  String get lbWeeklyTitle => 'الأسبوعية';

  @override
  String get lbWeeklySubtitle => 'وجبات أكبر. سبعة أيام لإنهائها.';

  @override
  String lbRewardCoinsXp(String coins, String xp) {
    return '$coins¢ · $xp خبرة';
  }

  @override
  String lbPlayMode(String mode) {
    return 'العب $mode';
  }

  @override
  String get lbTrophiesTitle => 'الكؤوس';

  @override
  String lbTrophiesSubtitle(String unlocked, String total, String locked) {
    return '$unlocked من $total. والبقية ($locked) تحكم عليك.';
  }

  @override
  String get lbFilterAll => 'الكل';

  @override
  String lbFilterUnlocked(String count) {
    return 'المفتوحة $count';
  }

  @override
  String lbFilterLocked(String count) {
    return 'المقفلة $count';
  }

  @override
  String lbTrophiesSummary(String pct, String claimed, String waiting) {
    return '$pct% مكتمل · المستلمة $claimed · المنتظرة $waiting';
  }

  @override
  String get lbClaimed => 'تم الاستلام';

  @override
  String lbCoinsReward(String coins) {
    return '+$coins¢';
  }

  @override
  String get lbSeasonTitle => 'الموسم';

  @override
  String lbSeasonSubtitle(String season, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بقي $days يوم',
      many: 'بقي $days يومًا',
      few: 'بقيت $days أيام',
      two: 'بقي يومان',
      one: 'بقي يوم واحد',
      zero: 'ينتهي اليوم',
    );
    return '$season · $_temp0. لا تضيّع الوقت.';
  }

  @override
  String lbSeasonEnded(String season) {
    return '$season · انتهى الموسم. موسم جديد في الطريق.';
  }

  @override
  String get lbTier => 'المستوى';

  @override
  String lbTierOf(String max) {
    return '/ $max';
  }

  @override
  String get lbProTrack => 'مسار Pro';

  @override
  String lbXpToTier(String xp, String need, String tier) {
    return '$xp / $need خبرة للمستوى $tier';
  }

  @override
  String lbNextUp(String tier, String track) {
    return 'التالي · المستوى $tier · $track';
  }

  @override
  String lbTiersAwayLine(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'يفصلك $n مستوى. كُل أسرع.',
      many: 'يفصلك $n مستوى. كُل أسرع.',
      few: 'يفصلك $n مستويات. كُل أسرع.',
      two: 'يفصلك مستويان. كُل أسرع.',
      one: 'يفصلك مستوى واحد. كُل أسرع.',
      zero: 'يفصلك $n مستوى. كُل أسرع.',
    );
    return '$_temp0';
  }

  @override
  String lbTiersAway(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مستوى',
      many: '$n مستوى',
      few: '$n مستويات',
      two: 'مستويان',
      one: 'مستوى واحد',
      zero: '$n مستوى',
    );
    return '$_temp0';
  }

  @override
  String lbXpAd(String xp) {
    return '+$xp خبرة · شاهد إعلانًا';
  }

  @override
  String get lbYouAreHere => 'أنت هنا';

  @override
  String get lbFree => 'مجاني';

  @override
  String get lbPro => 'Pro';

  @override
  String get lbRanksTitle => 'الترتيب';

  @override
  String get lbRanksSubtitle => 'حسب أفضل جولة لك. بلا ضغط.';

  @override
  String get lbTabGlobal => 'عالمي';

  @override
  String get lbTabWeekly => 'أسبوعي';

  @override
  String get lbTabFriends => 'الأصدقاء';

  @override
  String lbRanksYouRow(String rank, String name) {
    return '#$rank · أنت · $name';
  }

  @override
  String lbRanksYouUnranked(String name) {
    return 'أنت · $name';
  }

  @override
  String lbRanksGap(String gap, String leader) {
    return 'متأخر بفارق $gap عن $leader. كُل بقوة أكبر.';
  }

  @override
  String get lbRanksLeader => 'أنت رقم 1. الجميع يطاردك.';

  @override
  String get lbRanksEasyOnly =>
      'الجولات السهلة لا تُصنَّف. الوضع العادي بانتظارك.';

  @override
  String get lbRanksOffline => 'الترتيب يحتاج إلى الإنترنت. ثعبانك لا يحتاج.';

  @override
  String get lbRanksEmpty => 'لا أحد هنا بعد. كن الأول.';

  @override
  String lbRunsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n جولة',
      many: '$n جولة',
      few: '$n جولات',
      two: 'جولتان',
      one: 'جولة واحدة',
      zero: 'لا جولات',
    );
    return '$_temp0';
  }

  @override
  String get lbProfileTitle => 'الملف الشخصي';

  @override
  String get lbProfileSubtitle => 'ثعبانك بالأرقام.';

  @override
  String get lbFunFact => 'معلومة طريفة';

  @override
  String lbFunApples(String apples, int pies) {
    String _temp0 = intl.Intl.pluralLogic(
      pies,
      locale: localeName,
      other: '$pies فطيرة',
      many: '$pies فطيرة',
      few: '$pies فطائر',
      two: 'فطيرتين',
      one: 'فطيرة واحدة',
      zero: '$pies فطيرة',
    );
    return 'التفاح المأكول: $apples. أي نحو $_temp0.';
  }

  @override
  String lbFunMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes دقيقة',
      many: '$minutes دقيقة',
      few: '$minutes دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
      zero: '$minutes دقيقة',
    );
    return '$_temp0 من الزحف. اشرب ماءً.';
  }

  @override
  String lbFunPowerups(int powerups) {
    String _temp0 = intl.Intl.pluralLogic(
      powerups,
      locale: localeName,
      other: '$powerups تعزيز',
      many: '$powerups تعزيزًا',
      few: '$powerups تعزيزات',
      two: 'تعزيزين',
      one: 'تعزيزًا واحدًا',
      zero: '$powerups تعزيز',
    );
    return 'التقطت $_temp0. طمّاع، ونحب ذلك.';
  }

  @override
  String get lbSynced => 'التقدّم متزامن';

  @override
  String get lbSyncedLine => 'بلا اتصال؟ العب على أي حال. سنلحق لاحقًا.';

  @override
  String get lbSyncPending => 'المزامنة معلّقة';

  @override
  String get lbGuest => 'تلعب كضيف';

  @override
  String get lbGuestLine => 'اربط حسابًا لتحتفظ بهذا الثعبان للأبد.';

  @override
  String lbSignedInWith(String provider) {
    return 'مسجّل الدخول · $provider';
  }

  @override
  String get lbStatBest => 'الأفضل';

  @override
  String get lbStatGames => 'الألعاب';

  @override
  String get lbStatPlayTime => 'وقت اللعب';

  @override
  String get lbStatAverage => 'المتوسط';

  @override
  String get lbStatFood => 'الطعام المأكول';

  @override
  String get lbStatPowerups => 'التعزيزات';

  @override
  String get lbStats => 'الإحصائيات';

  @override
  String get lbReplays => 'الإعادات';

  @override
  String get lbFriends => 'الأصدقاء';

  @override
  String get lbTrophies => 'الكؤوس';

  @override
  String lbFriendsOn(String count) {
    return 'متصل: $count';
  }

  @override
  String get lbStoreTitle => 'المتجر';

  @override
  String get lbStoreSubPro => 'بلا إعلانات. كل الأناقة. القرار لك.';

  @override
  String get lbStoreSubCoins => 'عملات لمن لا يطيق الانتظار.';

  @override
  String get lbStoreSubThemes => 'لوحة جديدة، والعادات السيئة نفسها.';

  @override
  String get lbStoreSubSkins => 'الثعبان نفسه. أناقة أكثر بكثير.';

  @override
  String get lbStoreSubTrails => 'اترك بصمتك.';

  @override
  String get lbStoreSubPowerups => 'غشّ صغير. قانوني تمامًا.';

  @override
  String get lbSnakeCoins => 'عملات Snake';

  @override
  String lbFreeCoins(String coins) {
    return '+$coins¢ مجانًا';
  }

  @override
  String get lbFreeCoinsLine => 'شاهد إعلانًا قصيرًا';

  @override
  String get lbProName => 'Snake Classic Pro';

  @override
  String get lbProPerkNoAds => 'بلا إعلانات. ولا واحد. أبدًا.';

  @override
  String get lbProPerkRevive => 'إحياء مجاني في كل جولة';

  @override
  String lbProPerkThemes(String count) {
    return 'كل السمات المميزة ($count)';
  }

  @override
  String lbProPerkCosmetics(String skins, String trails) {
    return 'كل المظاهر ($skins) + كل الآثار ($trails)';
  }

  @override
  String get lbProPerkCoins => '2× عملات من كل جولة';

  @override
  String get lbMonthly => 'شهري';

  @override
  String get lbYearly => 'سنوي';

  @override
  String get lbPerMonth => 'شهريًا';

  @override
  String get lbGoPro => 'احصل على Pro';

  @override
  String get lbProActive => 'Pro مفعّل';

  @override
  String get lbProActiveLine => 'شكرًا لدعمك الثعبان.';

  @override
  String get lbStoreFooter => 'الأسعار من متجر التطبيقات لديك. ألغِ في أي وقت.';

  @override
  String get lbRestorePurchases => 'استعادة المشتريات';

  @override
  String lbBuyPrice(String price) {
    return 'شراء · $price';
  }

  @override
  String lbBuyCoins(String coins) {
    return 'شراء · $coins¢';
  }

  @override
  String get lbOrFreeWithPro => 'أو مجانًا مع Pro';

  @override
  String get lbEquipped => 'مُجهَّز';

  @override
  String get lbEquip => 'جهّز';

  @override
  String get lbSkinTagGolden => 'ثري. مشهور. مغرور قليلًا.';

  @override
  String get lbSkinTagFire => 'ساخن عند اللمس.';

  @override
  String get lbSkinTagIce => 'أعصاب من جليد.';

  @override
  String get lbSkinTagElectric => 'سرعة صاعقة.';

  @override
  String get lbSkinTagRainbow => 'كل الألوان. دفعة واحدة.';

  @override
  String get lbSkinTagNeon => 'يُرى من الفضاء.';

  @override
  String get lbSkinTagShadow => 'الآن تراه.';

  @override
  String get lbSkinTagGalaxy => 'يحوي عوالم.';

  @override
  String get lbSkinTagCrystal => 'تعامل معه بحذر.';

  @override
  String get lbSkinTagCosmic => 'طاقة كونية هائلة.';

  @override
  String get lbSkinTagDragon => 'قانونيًا، ليس تنينًا.';

  @override
  String get lbSettingsTitle => 'الإعدادات';

  @override
  String get lbSettingsSubtitle => 'عدّلها حتى تبدو مناسبة.';

  @override
  String get lbControls => 'التحكم';

  @override
  String get lbCtrlSwipe => 'سحب';

  @override
  String get lbCtrlSwipeSub => 'في أي مكان';

  @override
  String get lbCtrlDpad => 'اتجاهات';

  @override
  String get lbCtrlDpadSub => '4 أسهم';

  @override
  String get lbCtrlTurn => 'انعطاف';

  @override
  String get lbCtrlTurnSub => 'يسار · يمين';

  @override
  String get lbCtrlStick => 'عصا';

  @override
  String get lbCtrlStickSub => 'عائمة';

  @override
  String get lbGameplay => 'اللعب';

  @override
  String get lbMode => 'الوضع';

  @override
  String get lbBoard => 'اللوحة';

  @override
  String get lbDifficulty => 'الصعوبة';

  @override
  String get lbCrashReplay => 'إعادة الاصطدام';

  @override
  String get lbCrashReplaySub => 'كم نُطيل الشماتة';

  @override
  String get lbTheme => 'السمة';

  @override
  String lbThemeAside(String theme, String free, String premium) {
    return '$theme · مجانية $free · مميزة $premium';
  }

  @override
  String get lbSoundFeel => 'الصوت والإحساس';

  @override
  String get lbSoundFx => 'المؤثرات الصوتية';

  @override
  String get lbSoundFxSub => 'مقرمشة، كما يجب';

  @override
  String get lbMusic => 'الموسيقى';

  @override
  String get lbHaptics => 'الاهتزاز';

  @override
  String get lbHapticsSub => 'اهتزازة صغيرة مع كل قضمة';

  @override
  String get lb120Hz => '120 هرتز';

  @override
  String get lb120HzSub => 'سلس كالزبدة (إن كان هاتفك كذلك)';

  @override
  String get lbReplayTutorial => 'إعادة التعليمات';

  @override
  String get lbPrivacy => 'الخصوصية';

  @override
  String get lbVersusTitle => 'مواجهة';

  @override
  String get lbVersusSubtitle => 'أشخاص حقيقيون. ثعابين حقيقية. عداوة حقيقية.';

  @override
  String get lbWins => 'انتصارات';

  @override
  String get lbLosses => 'هزائم';

  @override
  String get lbDraws => 'تعادلات';

  @override
  String get lbRating => 'التقييم';

  @override
  String get lbQuickMatch => 'مباراة سريعة';

  @override
  String get lbQuickMatchLine => '1 ضد 1 كلاسيكي. نجد لك خصمًا في ثوانٍ.';

  @override
  String get lbFindMatch => 'ابحث عن مباراة';

  @override
  String lbSearching(String secs) {
    return 'نتشمّم خصمًا… $secsث';
  }

  @override
  String get lbCancel => 'إلغاء';

  @override
  String get lbGotCode => 'لديك رمز؟';

  @override
  String get lbGotCodeLine =>
      'ستة أحرف. لا يهم كبيرها من صغيرها. الصداقة قد تهم.';

  @override
  String get lbCreateRoom => 'أنشئ غرفة';

  @override
  String get lbCreateRoomLine => 'ادعُ صديقًا. أو صديقًا لدودًا.';

  @override
  String get lbHouseSnake =>
      'لا أحد شجاع متصل؟ ثعبان الدار ينضم بعد 30 ثانية. ولا يتفوّه بالإهانات.';

  @override
  String get lbTournamentsLive => 'البطولات · مباشر';

  @override
  String get lbTournamentsLine =>
      'البرونزية مجانية · الفضية والذهبية بتذاكر دخول';

  @override
  String get lbRoomTitle => 'الغرفة';

  @override
  String get lbRoomSubtitle => 'شارك الرمز. وانتظر بتوتر.';

  @override
  String lbPlayersCount(String count, String max) {
    return 'اللاعبون $count/$max';
  }

  @override
  String get lbYou => 'أنت';

  @override
  String get lbRival => 'الخصم';

  @override
  String get lbWaitingYou => 'بانتظارك · انقر جاهز يا بطل';

  @override
  String get lbWaiting => 'بالانتظار';

  @override
  String get lbReadyThem => 'جاهز · يتمطّى بتهديد';

  @override
  String get lbReadyYou => 'جاهز · أعصاب من فولاذ';

  @override
  String get lbReadyCheck => 'التحقق من الجاهزية';

  @override
  String get lbReady => 'جاهز';

  @override
  String get lbLeaveRoom => 'غادر الغرفة';

  @override
  String get lbVs => 'ضد';

  @override
  String get lbLive => 'مباشر';

  @override
  String lbMatchBehind(String rival, String gap) {
    return '$rival متقدّم عليك بفارق $gap. وقاحة.';
  }

  @override
  String lbMatchAhead(String gap) {
    return 'أنت متقدّم بفارق $gap. لا تغترّ.';
  }

  @override
  String get lbMatchTied => 'تعادل تام. كُل شيئًا.';

  @override
  String get lbVictory => 'فوز';

  @override
  String lbVictoryLine(String rival) {
    return 'تفوّقت على $rival.';
  }

  @override
  String get lbDefeat => 'هزيمة';

  @override
  String lbDefeatLine(String rival) {
    return '$rival حسم هذه الجولة.';
  }

  @override
  String get lbDefeatBothCrashed => 'اصطدم الثعبانان. حسمت نتيجة خصمك الأمر.';

  @override
  String lbDefeatLine2(String rival) {
    return '$rival سيصبح لا يُطاق الآن.';
  }

  @override
  String get lbDraw => 'تعادل';

  @override
  String get lbDrawLine => 'توازن مثالي. مباراة ثأر؟';

  @override
  String get lbVersusFooter => 'كل خسارة مجرد مباراة ثأر تنتظر.';

  @override
  String get lbLength => 'الطول';

  @override
  String get lbSurvived => 'الصمود';

  @override
  String get lbRematch => 'مباراة ثأر';

  @override
  String get lbBackToLobby => 'العودة للردهة';

  @override
  String get lbAdBreak => 'استراحة إعلانية';

  @override
  String lbAdBreakLine(String coins) {
    return 'إعلان قصير. $coins عملة لك.';
  }

  @override
  String get lbAdBreakLine2 => 'صفقة عادلة؟ القرار لك في الحالتين.';

  @override
  String lbAdStartsIn(String secs) {
    return 'يبدأ خلال $secs · أو تخطَّه، بلا زعل';
  }

  @override
  String lbAdRewardWhenEnds(String coins) {
    return '+$coins¢ عند انتهائه';
  }

  @override
  String get lbWatchNow => 'شاهد الآن';

  @override
  String get lbNoThanks => 'لا شكرًا';

  @override
  String get lbAdBackHint => 'إيماءة الرجوع تُعدّ «لا شكرًا» أيضًا.';

  @override
  String get lbAdStarting => 'الإعلان يبدأ…';

  @override
  String get lbNoAdNow => 'لا يوجد إعلان الآن. حاول بعد قليل.';

  @override
  String get lbServerDown => 'خوادمنا اصطدمت. تقدّمك محفوظ على هذا الهاتف.';

  @override
  String get lbHomeVersusSubOffline => '1 ضد 1 · خصوم حقيقيون';

  @override
  String get lbHomeSeasonSubNone => 'اكسب خبرة في كل جولة';

  @override
  String get lbMenuHowToPlay => 'طريقة اللعب';

  @override
  String get lbMenuTournaments => 'البطولات';

  @override
  String get lbMenuAbout => 'حول';

  @override
  String get lbMenuHowToPlaySub => 'السحب، الأوضاع، التعزيزات';

  @override
  String get lbMenuAboutSub => 'الإصدار، الفريق، الشروط';

  @override
  String get lbSetupLoadoutNone => 'انقر واحدًا لتجهيزه';

  @override
  String lbSetupLoadoutArmedOne(String name) {
    return '$name مُجهَّز';
  }

  @override
  String lbOwnedCount(String count) {
    return '×$count';
  }

  @override
  String lbArmedChip(String name) {
    return 'مُجهَّز · $name';
  }

  @override
  String get lbGuestNoteApple =>
      'يمكن للضيوف اللعب وحفظ التقدّم محليًا، لكن لا يمكنهم الشراء. سجّل الدخول عبر Apple أو Google أو البريد الإلكتروني عندما تكون جاهزًا للاشتراك أو الشراء.';

  @override
  String get lbGuestNoteNoApple =>
      'يمكن للضيوف اللعب وحفظ التقدّم محليًا، لكن لا يمكنهم الشراء. سجّل الدخول عبر Google أو البريد الإلكتروني عندما تكون جاهزًا للاشتراك أو الشراء.';

  @override
  String get lbAuthLegalTitle => 'الخصوصية + الشروط';

  @override
  String get lbConsentTitle => 'تحديث الشروط';

  @override
  String get lbEmailTitle => 'البريد الإلكتروني';

  @override
  String get lbEmailLinkTitle => 'احفظ التقدّم';

  @override
  String get lbUsernameTitle => 'اسم المستخدم';

  @override
  String get lbShowPassword => 'إظهار كلمة المرور';

  @override
  String get lbHidePassword => 'إخفاء كلمة المرور';

  @override
  String get lbSignedIn => 'مسجّل الدخول';

  @override
  String get lbProviderGoogle => 'Google';

  @override
  String get lbProviderApple => 'Apple';

  @override
  String get lbProviderEmail => 'البريد';

  @override
  String get lbStatsSubtitle => 'كل جولة محسوبة. حتى السيئة.';

  @override
  String get lbTrendUp => 'في صعود';

  @override
  String get lbTrendDown => 'في تراجع';

  @override
  String get lbTrendFlat => 'ثابت';

  @override
  String get lbReplaysSubtitle => 'محفوظة على هذا الهاتف. لا تُرفع أبدًا.';

  @override
  String get lbReplayTitle => 'إعادة';

  @override
  String get lbReplayEnded => 'انتهت';

  @override
  String lbSpeedX(String speed) {
    return '$speed×';
  }

  @override
  String get lbPause => 'إيقاف مؤقت';

  @override
  String get lbReplayPrevFrame => 'الإطار السابق';

  @override
  String get lbReplayNextFrame => 'الإطار التالي';

  @override
  String get lbFriendsSubtitle => 'ثعابين تعرفها. خصوم ستهزمهم.';

  @override
  String lbDurDayHour(String d, String h) {
    return '$dي $hس';
  }

  @override
  String lbBonusStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'سلسلة $days يوم',
      many: 'سلسلة $days يومًا',
      few: 'سلسلة $days أيام',
      two: 'سلسلة يومين',
      one: 'سلسلة يوم واحد',
      zero: 'سلسلة $days يوم',
    );
    return '$_temp0';
  }

  @override
  String lbPoints(String points) {
    return '$points نقطة';
  }

  @override
  String get lbRefresh => 'تحديث';

  @override
  String get lbRouteErrorTitle => 'ضاع الأثر';

  @override
  String get lbRouteErrorBody =>
      'هذه الشاشة غير موجودة في هذا الإصدار من اللعبة.';

  @override
  String get lbRouteErrorHome => 'العودة للرئيسية';

  @override
  String lbVersionShort(String version) {
    return 'v$version';
  }

  @override
  String get lbCtrlReference => 'الإيماءات والمفاتيح';

  @override
  String get lbCtrlReferenceSub => 'ماذا تفعل كل إيماءة وكل مفتاح';

  @override
  String lbThemeSwatchLocked(String theme) {
    return '$theme، مقفلة';
  }

  @override
  String get lbLanguageRow => 'لغة التطبيق';

  @override
  String get lbPerYearBestValue => 'سنويًا · أفضل قيمة';

  @override
  String get lbProAlsoIncluded => 'مشمول أيضًا';

  @override
  String get lbFreeTrack => 'المسار المجاني';

  @override
  String lbSeasonSubtitleSoon(String season, String left) {
    return '$season · $left. لا تضيّع الوقت.';
  }

  @override
  String get lbEndsIn => 'ينتهي خلال';

  @override
  String get lbStartsIn => 'يبدأ خلال';
}
