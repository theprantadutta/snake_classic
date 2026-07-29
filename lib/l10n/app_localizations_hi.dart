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

  @override
  String get mpLobbyNoFriends =>
      'अभी कोई दोस्त नहीं — Friends स्क्रीन से जोड़ें!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'रूम $code में दोस्त को बुलाएँ';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 $name को निमंत्रण भेजा गया!';
  }

  @override
  String get mpLobbyInviteFailed =>
      'निमंत्रण नहीं भेजा जा सका — फिर कोशिश करें';

  @override
  String get mpLobbyOffline =>
      'आप ऑफ़लाइन हैं। मल्टीप्लेयर के लिए इंटरनेट ज़रूरी है।';

  @override
  String get mpLobbyDismiss => 'हटाएँ';

  @override
  String get mpLobbyGo => 'शुरू!';

  @override
  String get mpLobbyGetReady => 'तैयार हो जाइए!';

  @override
  String get mpLobbyTitle => 'मल्टीप्लेयर';

  @override
  String get mpLobbySubtitle => 'दोस्तों के साथ ऑनलाइन खेलें';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'रूम: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'रूम कोड कॉपी हो गया!';

  @override
  String get mpLobbyQuickMatch => 'क्विक मैच';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      '1v1 क्लासिक — अपने आप प्रतिद्वंद्वी खोजें';

  @override
  String get mpLobbyFinding => 'खोज रहे हैं...';

  @override
  String get mpLobbyFindMatch => 'मैच खोजें';

  @override
  String get mpLobbySeconds => 'सेकंड';

  @override
  String get mpLobbySearching => 'खिलाड़ी खोजे जा रहे हैं...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खिलाड़ी',
      one: '$count खिलाड़ी',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'कतार में स्थान: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'रद्द करें';

  @override
  String get mpLobbyNoPlayersFound => 'कोई खिलाड़ी नहीं मिला';

  @override
  String get mpLobbyNoPlayersBody =>
      'माफ़ कीजिए, कोई प्रतिद्वंद्वी नहीं मिला।\nफिर कोशिश करें या अपना रूम बनाएँ!';

  @override
  String get mpLobbyGoBack => 'वापस जाएँ';

  @override
  String get mpLobbyTryAgain => 'फिर कोशिश करें';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count जीत';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count हार';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count बराबरी';
  }

  @override
  String get mpLobbyJoinRoom => 'रूम जॉइन करें';

  @override
  String get mpLobbyJoinSubtitle => 'जॉइन करने के लिए रूम कोड डालें';

  @override
  String get mpLobbyEnterRoomCode => 'रूम कोड डालें';

  @override
  String get mpLobbyCreateRoom => 'रूम बनाएँ';

  @override
  String get mpLobbyCreateSubtitle => '1v1 रूम बनाकर दोस्त को बुलाएँ';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'खिलाड़ी ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'आप';

  @override
  String get mpLobbyWaitingForPlayer => 'खिलाड़ी की प्रतीक्षा...';

  @override
  String get mpLobbyStartGame => 'गेम शुरू करें';

  @override
  String get mpLobbyWaitingForHost => 'होस्ट के शुरू करने की प्रतीक्षा...';

  @override
  String get mpLobbyLeave => 'छोड़ें';

  @override
  String get mpLobbyReadyDone => 'तैयार!';

  @override
  String get mpLobbyReady => 'तैयार';

  @override
  String get mpModeClassicDesc => 'पारंपरिक साँप मुक़ाबला';

  @override
  String get mpModeSpeedDesc => 'समय के साथ गति बढ़ती है';

  @override
  String get mpModeSurvivalDesc => 'आख़िरी बचा साँप जीतता है';

  @override
  String get mpModePowerUpDesc => 'हर जगह पावर-अप!';

  @override
  String get mpStatusWaiting => 'प्रतीक्षा में';

  @override
  String get mpStatusReady => 'तैयार';

  @override
  String get mpStatusPlaying => 'खेल रहे';

  @override
  String get mpStatusCrashed => 'टकरा गए';

  @override
  String get mpStatusDisconnected => 'डिस्कनेक्ट';

  @override
  String get goNoAdAvailable =>
      'अभी कोई विज्ञापन उपलब्ध नहीं, थोड़ी देर में कोशिश करें';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 सिक्के दोगुने — +$count बोनस सिक्के!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'अपने $count सिक्के दोगुने करने के लिए विज्ञापन देखें';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins सिक्के  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'दैनिक चुनौतियों से $count सिक्के मिले!';
  }

  @override
  String get goRibbonNewHighScore => 'नया उच्चतम स्कोर!';

  @override
  String get goRibbonTournamentSubmitted => 'टूर्नामेंट स्कोर सबमिट हुआ!';

  @override
  String get goRibbonTournamentFailed =>
      'स्कोर सबमिट नहीं हुआ — कनेक्शन जाँचें';

  @override
  String get goRibbonTournamentSubmitting =>
      'टूर्नामेंट स्कोर सबमिट हो रहा है…';

  @override
  String get goVictory => 'विजय!';

  @override
  String get goGameOver => 'गेम समाप्त';

  @override
  String get goFinalScore => 'अंतिम स्कोर';

  @override
  String get goLevel => 'लेवल';

  @override
  String get goBest => 'सर्वश्रेष्ठ';

  @override
  String get goCoinsEarned => 'कमाए गए सिक्के';

  @override
  String get goDailyRewardsReady => 'दैनिक इनाम तैयार';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count इनाम',
      one: '$count इनाम',
    );
    return '$_temp0  •  +$coins सिक्के  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'सभी लें';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'लें';

  @override
  String get goAchievements => 'उपलब्धियाँ';

  @override
  String get goRecentlyUnlocked => 'हाल में अनलॉक';

  @override
  String get goInProgress => 'प्रगति में';

  @override
  String get goPlayAgain => 'फिर से खेलें';

  @override
  String get goMenu => 'मेनू';

  @override
  String get storeTitle => 'स्नेक स्टोर';

  @override
  String get storeTabPro => 'प्रो';

  @override
  String get storeTabCoins => 'सिक्के';

  @override
  String get storeTabThemes => 'थीम';

  @override
  String get storeTabSkins => 'स्किन';

  @override
  String get storeTabTrails => 'ट्रेल';

  @override
  String get storeTabPowerUps => 'पावर-अप';

  @override
  String get storeYourCoins => 'आपके स्नेक सिक्के';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return '${multiplier}x बोनस';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'मुफ़्त प्रो समाप्त होने से पहले सदस्यता लें';

  @override
  String get storeChooseYourPlan => 'अपना प्लान चुनें';

  @override
  String get storeWhatYouGet => 'आपको क्या मिलेगा';

  @override
  String get storeProHeroSubtitle =>
      'सभी प्रीमियम थीम, स्किन और ट्रेल · बड़े बोर्ड · 2× सिक्के · प्रीमियम पावर-अप · टूर्नामेंट एंट्री · बैटल पास प्रीमियम';

  @override
  String get storeMonthly => 'मासिक';

  @override
  String get storeYearly => 'वार्षिक';

  @override
  String get storePerMonth => '/माह';

  @override
  String get storePerYear => '/वर्ष';

  @override
  String get storeSave17 => '17% बचाएँ';

  @override
  String storePlanDisplayName(Object title) {
    return '$title प्लान';
  }

  @override
  String get storeVerifyingEllipsis => 'सत्यापन हो रहा है…';

  @override
  String get storeSubscribe => 'सदस्यता लें';

  @override
  String get storeYoureOnFreePro => 'आप मुफ़्त प्रो पर हैं!';

  @override
  String get storeYourePro => 'आप प्रो हैं!';

  @override
  String get storeFreePro => 'मुफ़्त प्रो';

  @override
  String get storeProMonthly => 'प्रो मासिक';

  @override
  String get storeKeepPro => 'प्रो बनाए रखें — सदस्यता लें';

  @override
  String get storePromoBadge => 'प्रोमो';

  @override
  String get storeEndingSoon => 'जल्द समाप्त';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return '$daysदि $hoursघं में समाप्त';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return '$hoursघं $minutesमि में समाप्त';
  }

  @override
  String storeEndsInM(Object minutes) {
    return '$minutesमि में समाप्त';
  }

  @override
  String get storeFeatureExtraLife =>
      'हमेशा मुफ़्त अतिरिक्त जीवन — हर गेम में पुनर्जीवित हों, न विज्ञापन, न सिक्के';

  @override
  String get storeFeatureNoAds =>
      'कोई विज्ञापन नहीं — पूरी तरह विज्ञापन-मुक्त खेलें';

  @override
  String get storeFeatureThemes => 'सभी 6 प्रीमियम थीम';

  @override
  String get storeFeatureSkins => 'सभी 11 प्रीमियम स्नेक स्किन';

  @override
  String get storeFeatureTrails => 'सभी 11 प्रीमियम ट्रेल प्रभाव';

  @override
  String get storeFeatureBoards => 'प्रीमियम बोर्ड आकार (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => '2× सिक्का कमाई';

  @override
  String get storeFeaturePowerUps => 'हर चक्र में 5× प्रीमियम पावर-अप';

  @override
  String get storeFeatureTournaments =>
      'हर चक्र में कांस्य + रजत + स्वर्ण टूर्नामेंट एंट्री';

  @override
  String get storeFeatureBattlePass => 'हर सीज़न बैटल पास प्रीमियम ट्रैक';

  @override
  String storeInitiatingPurchase(Object name) {
    return '$name खरीद शुरू हो रही है...';
  }

  @override
  String get storeSubNotAvailable =>
      'सदस्यता उपलब्ध नहीं है। बाद में कोशिश करें।';

  @override
  String get storePurchaseFailed => 'खरीद विफल रही। कृपया फिर कोशिश करें।';

  @override
  String get storeBuyCoins => 'स्नेक सिक्के खरीदें';

  @override
  String get storeEarnFreeCoins => 'मुफ़्त सिक्के कमाएँ';

  @override
  String get storeEarnPlay => 'एक गेम खेलें';

  @override
  String get storeEarnPlayReward => 'हर गेम पर 5 सिक्के';

  @override
  String get storeEarnDaily => 'दैनिक लॉगिन';

  @override
  String get storeEarnDailyReward => 'रोज़ 10-50 सिक्के';

  @override
  String get storeEarnAchievements => 'उपलब्धियाँ';

  @override
  String get storeEarnAchievementsReward => '25-100 सिक्के';

  @override
  String get storeEarnTournaments => 'टूर्नामेंट';

  @override
  String get storeEarnTournamentsReward => '100+ सिक्के';

  @override
  String get storePopularBadge => 'लोकप्रिय';

  @override
  String storeBuyItem(Object name) {
    return '$name खरीदें';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return '$price में $coins खरीदें?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'खरीदें - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return '$name की खरीद शुरू हो रही है...';
  }

  @override
  String get storeProductNotAvailable =>
      'उत्पाद उपलब्ध नहीं है। बाद में कोशिश करें।';

  @override
  String get storeUnlockedWithPro => 'प्रो के साथ अनलॉक';

  @override
  String get storeIncludedWithPro => 'Snake Classic Pro में शामिल';

  @override
  String get storeProBannerThemesOwned =>
      'यहाँ की हर थीम आपकी सदस्यता के साथ आपकी है।';

  @override
  String get storeProBannerThemesUpsell =>
      'यहाँ की हर थीम अनलॉक करने के लिए प्रो लें — अलग से खरीदना नहीं पड़ेगा।';

  @override
  String get storeProBannerSkinsOwned =>
      'यहाँ की हर स्किन आपकी सदस्यता के साथ आपकी है।';

  @override
  String get storeProBannerSkinsUpsell =>
      'यहाँ की हर स्किन अनलॉक करने के लिए प्रो लें — अलग से खरीदना नहीं पड़ेगा।';

  @override
  String get storeProBannerTrailsOwned =>
      'यहाँ का हर ट्रेल आपकी सदस्यता के साथ आपका है।';

  @override
  String get storeProBannerTrailsUpsell =>
      'यहाँ का हर ट्रेल अनलॉक करने के लिए प्रो लें — अलग से खरीदना नहीं पड़ेगा।';

  @override
  String get storePremiumThemes => 'प्रीमियम थीम';

  @override
  String get storeFreeThemes => 'मुफ़्त थीम';

  @override
  String get storeFreeThemesSubtitle => 'हमेशा उपलब्ध — कभी भी वापस बदलें।';

  @override
  String get storeAllThemesBundle => 'सभी थीम बंडल';

  @override
  String get storeAllThemesBundleSubtitle => 'सभी 6 प्रीमियम थीम · 33% बचत';

  @override
  String get storePillVerifying => 'सत्यापन';

  @override
  String get storePillOwned => 'आपके पास';

  @override
  String get storePillFree => 'मुफ़्त';

  @override
  String get storePillActive => 'सक्रिय';

  @override
  String get storePillApply => 'लागू करें';

  @override
  String get storePillEquipped => 'लगा हुआ';

  @override
  String get storePillEquip => 'लगाएँ';

  @override
  String get storeThemeDescClassic => 'असली पुराना लुक';

  @override
  String get storeThemeDescModern => 'साफ़ और सरल';

  @override
  String get storeThemeDescNeon => 'चमकती नियॉन रातें';

  @override
  String get storeThemeDescRetro => '80 के दशक का नियॉन आर्केड';

  @override
  String get storeThemeDescSpace => 'ब्रह्मांडीय तारों भरा आकाश';

  @override
  String get storeThemeDescOcean => 'गहरे समुद्र का नीलापन';

  @override
  String get storeThemeDescCyberpunk => 'इलेक्ट्रिक सियान और गुलाबी';

  @override
  String get storeThemeDescForest => 'चमकीला पन्ना जंगल';

  @override
  String get storeThemeDescDesert => 'घाटी और कैक्टस टील';

  @override
  String get storeThemeDescCrystal => 'बर्फ़ीला क्रिस्टल नीला';

  @override
  String storeUnlockFor(Object name, Object price) {
    return '$price में $name अनलॉक करें?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return '$name की खरीद सत्यापित हो रही है…';
  }

  @override
  String get storeThemeNotAvailable =>
      'थीम उपलब्ध नहीं है। बाद में कोशिश करें।';

  @override
  String get storeItemNotAvailable =>
      'आइटम उपलब्ध नहीं है। बाद में कोशिश करें।';

  @override
  String storeEquippedToast(Object name) {
    return '$name लगाया गया';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 मुफ़्त स्पीड बूस्ट आपकी इन्वेंटरी में जुड़ गया!';

  @override
  String get storeWatchAdTitle => 'विज्ञापन देखें — मुफ़्त स्पीड बूस्ट';

  @override
  String get storeWatchAdReady => 'आपके लोडआउट में 1 स्पीड बूस्ट जोड़ता है';

  @override
  String get storeWatchAdNotReady => 'अभी कोई विज्ञापन उपलब्ध नहीं';

  @override
  String get puSpeedBoostDesc => '7 सेकंड के लिए साँप की गति बढ़ाता है।';

  @override
  String get puInvincibilityDesc =>
      '6 सेकंड के लिए दीवारों और खुद से आर-पार निकलें।';

  @override
  String get puScoreMultiplierDesc => '10 सेकंड के लिए दोगुने अंक।';

  @override
  String get puSlowMotionDesc => 'सटीकता के लिए गेम धीमा करता है (8 सेकंड)।';

  @override
  String get storePowerUpsInfo =>
      'सिक्कों से खरीदें, फिर होम स्क्रीन के लोडआउट चिप से एक तैयार करें — यह अगले गेम में 5 सेकंड बाद सक्रिय होगा।';

  @override
  String get storePowerUps => 'पावर-अप';

  @override
  String get storePowerUpBundles => 'पावर-अप बंडल';

  @override
  String get storeBundlesSubtitle => 'छूट पर कई पावर-अप प्रकार अनलॉक करें।';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'सिक्के कम हैं!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return '$cost सिक्कों में 1 $name खरीदें?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'खरीदें - $cost सिक्के';
  }

  @override
  String get storePurchaseFailedRetry => 'खरीद विफल रही। फिर कोशिश करें।';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name आपके लोडआउट में जुड़ गया!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count सिक्के';
  }

  @override
  String get storeBuyUpper => 'खरीदें';

  @override
  String get storeNeedCoins => 'सिक्के चाहिए';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name अनलॉक हो गया!';
  }

  @override
  String get modeClassic => 'क्लासिक';

  @override
  String get modeZen => 'ज़ेन मोड';

  @override
  String get modeSpeedChallenge => 'स्पीड चैलेंज';

  @override
  String get modeMultiFood => 'मल्टी-फ़ूड';

  @override
  String get modeSurvival => 'सर्वाइवल';

  @override
  String get modeTimeAttack => 'टाइम अटैक';

  @override
  String get modePowerUpMadness => 'पावर-अप धमाल';

  @override
  String get modePerfectGame => 'परफ़ेक्ट गेम';

  @override
  String get modeClassicDesc => 'दीवारों वाला क्लासिक साँप गेम';

  @override
  String get modeZenDesc => 'कोई दीवार नहीं - साँप स्क्रीन के आर-पार निकलता है';

  @override
  String get modeSpeedChallengeDesc =>
      'अधिकतम चुनौती के लिए गति तेज़ी से बढ़ती है';

  @override
  String get modeMultiFoodDesc => 'एक साथ कई खाने की चीज़ें आती हैं';

  @override
  String get modeSurvivalDesc => 'सीमित जीवन के साथ जितना हो सके टिके रहें';

  @override
  String get modeTimeAttackDesc =>
      'सीमित समय में ज़्यादा से ज़्यादा स्कोर करें';

  @override
  String get modePowerUpMadnessDesc =>
      'पावर-अप कहीं ज़्यादा आते हैं — अराजकता का मज़ा लें';

  @override
  String get modePerfectGameDesc =>
      'अपनी ही राह कभी न काटें। एक बार छुए गए खाने पर कदम रखते ही खेल समाप्त।';

  @override
  String get diffEasy => 'आसान';

  @override
  String get diffNormal => 'सामान्य';

  @override
  String get diffHard => 'कठिन';

  @override
  String get diffEasyDesc =>
      'शुरुआत में धीमा साँप। स्कोर लीडरबोर्ड पर नहीं जाते।';

  @override
  String get diffNormalDesc => 'असली Snake Classic की रफ़्तार।';

  @override
  String get diffHardDesc => 'तेज़ शुरू होता है और और तेज़ ही होता जाता है।';

  @override
  String get themeClassic => 'क्लासिक';

  @override
  String get themeModern => 'मॉडर्न';

  @override
  String get themeNeon => 'नियॉन';

  @override
  String get themeRetro => 'रेट्रो';

  @override
  String get themeSpace => 'अंतरिक्ष';

  @override
  String get themeOcean => 'महासागर';

  @override
  String get themeCyberpunk => 'साइबरपंक';

  @override
  String get themeForest => 'जंगल';

  @override
  String get themeDesert => 'रेगिस्तान';

  @override
  String get themeCrystal => 'क्रिस्टल';

  @override
  String get dpadLeft => 'बाएँ';

  @override
  String get dpadCenter => 'बीच में';

  @override
  String get dpadRight => 'दाएँ';

  @override
  String get mpModeClassicBattle => 'क्लासिक मुक़ाबला';

  @override
  String get mpModeSpeedRun => 'स्पीड रन';

  @override
  String get mpModeSurvivalMode => 'सर्वाइवल मोड';

  @override
  String get mpModePowerUpMadnessName => 'पावर-अप धमाल';
}
