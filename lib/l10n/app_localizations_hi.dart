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

  @override
  String get homePlay => 'खेलें';

  @override
  String get homeHighScore => 'उच्चतम स्कोर';

  @override
  String homeArmedPowerUp(String name) {
    return 'तैयार: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'लोडआउट ($count)';
  }

  @override
  String get puSpeedBoost => 'स्पीड बूस्ट';

  @override
  String get puInvincibility => 'अजेयता';

  @override
  String get puScoreMultiplier => 'स्कोर गुणक';

  @override
  String get puSlowMotion => 'स्लो मोशन';

  @override
  String get homeTilePro => 'प्रो';

  @override
  String get homeTileStore => 'स्टोर';

  @override
  String get homeTileFree => 'मुफ़्त';

  @override
  String get homeTileDaily => 'दैनिक';

  @override
  String get homeTileBattle => 'बैटल';

  @override
  String get homeTileEvents => 'इवेंट्स';

  @override
  String get homeTileBoard => 'रैंकिंग';

  @override
  String get homeTileFriends => 'दोस्त';

  @override
  String get homeTileCosmetics => 'कॉस्मेटिक्स';

  @override
  String get homeTileAwards => 'पुरस्कार';

  @override
  String get homeTileVersus => 'मुक़ाबला';

  @override
  String get homeNoAdReady =>
      'अभी कोई विज्ञापन तैयार नहीं — कुछ सेकंड में फिर कोशिश करें।';

  @override
  String get homeFreeSpeedBoostTitle => 'मुफ़्त स्पीड बूस्ट';

  @override
  String get homeFreeSpeedBoostBody =>
      'एक छोटा विज्ञापन देखकर अपने लोडआउट में मुफ़्त स्पीड बूस्ट पाएँ। यह अगले गेम में 5 सेकंड बाद सक्रिय होगा।';

  @override
  String get homeNotNow => 'अभी नहीं';

  @override
  String get homeWatchAd => 'विज्ञापन देखें';

  @override
  String get homeFreeSpeedBoostAdded =>
      'मुफ़्त स्पीड बूस्ट आपके लोडआउट में जुड़ गया!';

  @override
  String get homeAdNotFinished =>
      'विज्ञापन पूरा नहीं हुआ — इनाम पाने के लिए पूरा विज्ञापन देखें।';

  @override
  String get homePickGameMode => 'गेम मोड चुनें';

  @override
  String get homePickGameModeSubtitle =>
      'आप इसे कभी भी सेटिंग्स में बदल सकते हैं';

  @override
  String get homeStartPlaying => 'खेलना शुरू करें';

  @override
  String get homeLoadoutTitle => 'पावर-अप लोडआउट';

  @override
  String get homeLoadoutSubtitle =>
      'एक पावर-अप पहले से लोड करें — यह अगले गेम में 5 सेकंड बाद सक्रिय होगा।';

  @override
  String get homeWatchAdFreeSpeedBoost => 'विज्ञापन देखें — मुफ़्त स्पीड बूस्ट';

  @override
  String get homeNoPowerUps =>
      'आपके पास कोई पावर-अप नहीं है।\nस्टोर से कुछ खरीदें!';

  @override
  String homeOwnedCount(int count) {
    return 'आपके पास: $count';
  }

  @override
  String get homeArmed => 'तैयार';

  @override
  String get homeDone => 'हो गया';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsBackToGame => 'गेम पर वापस';

  @override
  String get settingsSectionControls => 'नियंत्रण';

  @override
  String get settingsSectionGameplay => 'गेमप्ले';

  @override
  String get settingsSectionAudio => 'ऑडियो';

  @override
  String get settingsSectionVisual => 'दृश्य';

  @override
  String get settingsSectionNotifications => 'सूचनाएँ';

  @override
  String get settingsSectionUserProfile => 'उपयोगकर्ता प्रोफ़ाइल';

  @override
  String get settingsSectionHelp => 'मदद और ट्यूटोरियल';

  @override
  String get settingsSectionLegal => 'कानूनी';

  @override
  String get settingsSectionPremium => 'प्रीमियम सुविधाएँ';

  @override
  String get settingsDPadControls => 'डी-पैड नियंत्रण';

  @override
  String get settingsDPadSubtitle => 'गेम के दौरान स्क्रीन पर दिशा बटन दिखाएँ';

  @override
  String get settingsDPadPosition => 'डी-पैड स्थिति';

  @override
  String get settingsDesktopControls => 'डेस्कटॉप/वेब नियंत्रण';

  @override
  String get settingsArrowKeys => 'एरो कीज़';

  @override
  String get settingsWasdKeys => 'WASD कीज़';

  @override
  String get settingsSpacebar => 'स्पेसबार';

  @override
  String get settingsMouseClick => 'माउस क्लिक';

  @override
  String get settingsChangeDirection => 'दिशा बदलें';

  @override
  String get settingsPauseResume => 'गेम रोकें/जारी रखें';

  @override
  String get settingsTouchControlsIfAvailable => 'टच नियंत्रण (यदि उपलब्ध)';

  @override
  String get settingsTouchControls => 'टच नियंत्रण';

  @override
  String get settingsSwipeGestures => 'स्वाइप इशारे';

  @override
  String get settingsTapScreen => 'स्क्रीन टैप करें';

  @override
  String get settingsSwipeUp => 'ऊपर स्वाइप ↑';

  @override
  String get settingsSwipeDown => 'नीचे स्वाइप ↓';

  @override
  String get settingsSwipeLeft => 'बाएँ स्वाइप ←';

  @override
  String get settingsSwipeRight => 'दाएँ स्वाइप →';

  @override
  String get settingsMoveSnakeUp => 'साँप को ऊपर ले जाएँ';

  @override
  String get settingsMoveSnakeDown => 'साँप को नीचे ले जाएँ';

  @override
  String get settingsMoveSnakeLeft => 'साँप को बाएँ ले जाएँ';

  @override
  String get settingsMoveSnakeRight => 'साँप को दाएँ ले जाएँ';

  @override
  String get settingsGameMode => 'गेम मोड';

  @override
  String get settingsGameModeLocked =>
      'गेम मोड बदलने के लिए मौजूदा गेम पूरा करें';

  @override
  String get settingsDifficulty => 'कठिनाई';

  @override
  String get settingsDifficultySubtitle =>
      'तय करता है कि साँप कितनी तेज़ शुरू होता है। हर मोड लेवल के साथ तेज़ होता जाता है।';

  @override
  String get settingsEasyNote =>
      'आसान मोड में सिक्के, XP और उपलब्धियाँ मिलती रहती हैं — केवल हाई स्कोर और लीडरबोर्ड रुके रहते हैं।';

  @override
  String get settingsDifficultyLocked =>
      'कठिनाई बदलने के लिए मौजूदा गेम पूरा करें।';

  @override
  String get settingsCurrentSize => 'वर्तमान आकार';

  @override
  String get settingsBoardSizeLocked =>
      'बोर्ड आकार बदलने के लिए मौजूदा गेम पूरा करें';

  @override
  String get settingsCurrentDuration => 'वर्तमान अवधि';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'टक्कर की व्याख्या कितनी देर दिखे';

  @override
  String get settingsScreenShake => 'स्क्रीन कंपन';

  @override
  String get settingsScreenShakeSubtitle =>
      'टक्करों और गेम घटनाओं पर स्क्रीन हिलाएँ';

  @override
  String get settingsVibration => 'कंपन';

  @override
  String get settingsVibrationSubtitle => 'गेम घटनाओं और बटन दबाने पर कंपन';

  @override
  String get settingsSoundEffects => 'ध्वनि प्रभाव';

  @override
  String get settingsBackgroundMusic => 'पृष्ठभूमि संगीत';

  @override
  String get settingsCurrentTheme => 'वर्तमान थीम';

  @override
  String get settingsBrowseThemes => 'थीम देखें';

  @override
  String get settingsSnakeTrail => 'साँप ट्रेल प्रभाव';

  @override
  String get settingsSnakeTrailSubtitle => 'साँप के पीछे कण ट्रेल सक्षम करें';

  @override
  String get settingsNotifDailyReminder => 'दैनिक अनुस्मारक';

  @override
  String get settingsNotifTournament => 'टूर्नामेंट अलर्ट';

  @override
  String get settingsNotifAchievement => 'उपलब्धि अनलॉक';

  @override
  String get settingsNotifSocial => 'सामाजिक अपडेट';

  @override
  String get settingsNotifSpecialEvents => 'विशेष कार्यक्रम';

  @override
  String get settingsNotSet => 'सेट नहीं';

  @override
  String get settingsUsername => 'उपयोगकर्ता नाम';

  @override
  String get settingsGuestAccount => 'अतिथि खाता';

  @override
  String get settingsAuthenticatedAccount => 'प्रमाणित खाता';

  @override
  String get settingsChangeUsername => 'उपयोगकर्ता नाम बदलें';

  @override
  String get settingsGuestSignInHint =>
      'अपनी प्रगति सहेजने और दोस्तों के साथ खेलने के लिए साइन इन करें';

  @override
  String get settingsUsernameVisibleHint =>
      'आपका उपयोगकर्ता नाम दोस्तों और लीडरबोर्ड पर दिखता है';

  @override
  String get settingsReplayTutorial => 'ट्यूटोरियल दोहराएँ';

  @override
  String get settingsReplayTutorialSubtitle =>
      'होम टूर या गेम ट्यूटोरियल फिर से देखें';

  @override
  String get settingsAboutCredits => 'ऐप के बारे में और क्रेडिट';

  @override
  String get settingsAboutCreditsSubtitle => 'ऐप संस्करण, क्रेडिट और लिंक';

  @override
  String get settingsRateApp => 'SNAKE CLASSIC को रेट करें';

  @override
  String get settingsRateAppSubtitleIos =>
      'गेम पसंद आ रहा है? App Store पर समीक्षा छोड़ें';

  @override
  String get settingsRateAppSubtitle => 'गेम पसंद आ रहा है? हमें समीक्षा दें!';

  @override
  String get settingsAdPrivacy => 'गोपनीयता और विज्ञापन विकल्प';

  @override
  String get settingsAdPrivacySubtitle =>
      'वैयक्तिकृत विज्ञापन सहमति प्रबंधित करें';

  @override
  String get settingsAdPrivacyUnavailable =>
      'विज्ञापन गोपनीयता विकल्प अभी उपलब्ध नहीं हैं।';

  @override
  String get settingsReplayDialogTitle => 'ट्यूटोरियल दोहराएँ';

  @override
  String get settingsReplayDialogBody =>
      'आप कौन-सा ट्यूटोरियल दोहराना चाहेंगे?';

  @override
  String get settingsHomeTour => 'होम टूर';

  @override
  String get settingsGameTutorial => 'गेम ट्यूटोरियल';

  @override
  String get settingsPrivacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get settingsPrivacyPolicyButton => 'गोपनीयता नीति';

  @override
  String get settingsTermsTitle => 'उपयोग की शर्तें';

  @override
  String get settingsTermsButton => 'उपयोग की शर्तें';

  @override
  String get settingsChangeUsernameTitle => 'उपयोगकर्ता नाम बदलें';

  @override
  String get settingsCurrentLabel => 'वर्तमान:';

  @override
  String get settingsUsernameDialogBody =>
      'एक अनोखा उपयोगकर्ता नाम चुनें जो गेम में आपकी पहचान हो।';

  @override
  String get settingsEnterNewUsername => 'नया उपयोगकर्ता नाम दर्ज करें';

  @override
  String get settingsUsernameRules =>
      '• 3-20 अक्षर\n• अक्षर से शुरू होना चाहिए\n• केवल अक्षर, अंक और अंडरस्कोर';

  @override
  String get settingsUsernameUpdateFailed => 'उपयोगकर्ता नाम अपडेट नहीं हो सका';

  @override
  String settingsUsernameUpdated(String name) {
    return 'उपयोगकर्ता नाम बदलकर \"$name\" हो गया';
  }

  @override
  String get settingsUpdate => 'अपडेट करें';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'प्रीमियम स्थिति';

  @override
  String get settingsActiveSubscription => 'सक्रिय सदस्यता';

  @override
  String get settingsUnlockPremium => 'प्रीमियम सुविधाएँ अनलॉक करें';

  @override
  String settingsRenews(String date) {
    return 'नवीनीकरण $date';
  }

  @override
  String get settingsProBadge => 'प्रो';

  @override
  String get settingsUpgradeToPro => 'प्रो में अपग्रेड करें';

  @override
  String get settingsRestorePurchases => 'खरीदारी बहाल करें';

  @override
  String get settingsPurchaseHistory => 'खरीद इतिहास';

  @override
  String get settingsSnakeCosmetics => 'स्नेक कॉस्मेटिक्स';

  @override
  String get settingsBattlePass => 'बैटल पास';

  @override
  String settingsTier(int tier) {
    return 'टियर $tier';
  }

  @override
  String get settingsRestoring => 'खरीदारी बहाल हो रही है...';

  @override
  String get settingsRestored => 'खरीदारी सफलतापूर्वक बहाल!';

  @override
  String get settingsRestoreFailed =>
      'खरीदारी बहाल नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String get settingsNoPurchases => 'कोई खरीदारी नहीं मिली';

  @override
  String get settingsUnknown => 'अज्ञात';

  @override
  String settingsStatusLine(String status) {
    return 'स्थिति: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'तारीख़: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'खरीद #$number';
  }

  @override
  String get settingsDataParseError => 'डेटा पढ़ने में त्रुटि';

  @override
  String get settingsClose => 'बंद करें';

  @override
  String get settingsHistoryLoadFailed => 'खरीद इतिहास लोड नहीं हो सका';

  @override
  String get settingsUnknownDate => 'अज्ञात तिथि';
}
