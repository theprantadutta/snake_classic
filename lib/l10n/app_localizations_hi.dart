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

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonViewAll => 'सभी देखें';

  @override
  String get commonRetry => 'फिर कोशिश करें';

  @override
  String get pfTitle => 'प्रोफ़ाइल';

  @override
  String get pfSigningOut => 'साइन आउट हो रहा है...';

  @override
  String get pfGuestPlayer => 'अतिथि खिलाड़ी';

  @override
  String get pfVerifiedAccount => 'सत्यापित खाता';

  @override
  String get pfStatistics => 'आँकड़े';

  @override
  String get pfReplays => 'रिप्ले';

  @override
  String get pfAchievements => 'उपलब्धियाँ';

  @override
  String get pfLoadingStats => 'आँकड़े लोड हो रहे हैं...';

  @override
  String get pfHighScore => 'उच्चतम स्कोर';

  @override
  String get pfGamesPlayed => 'खेले गए गेम';

  @override
  String get pfPlayTime => 'खेलने का समय';

  @override
  String get pfAverageScore => 'औसत स्कोर';

  @override
  String get pfFoodConsumed => 'खाया गया भोजन';

  @override
  String get pfPowerUps => 'पावर-अप';

  @override
  String get pfUpgradeTitle => 'Google खाते में अपग्रेड करें';

  @override
  String get pfUpgradeSubtitle =>
      'अपनी प्रगति सहेजें और सभी डिवाइस पर सिंक करें';

  @override
  String get pfBenefitSync => 'प्रगति सिंक';

  @override
  String get pfBenefitSyncSub => 'सभी डिवाइस पर';

  @override
  String get pfBenefitLeaderboards => 'वैश्विक लीडरबोर्ड';

  @override
  String get pfBenefitLeaderboardsSub => 'दुनिया भर से मुक़ाबला';

  @override
  String get pfBenefitSocial => 'दोस्त और सोशल';

  @override
  String get pfBenefitSocialSub => 'दूसरों से जुड़ें';

  @override
  String get pfSignInGoogle => 'Google से साइन इन करें';

  @override
  String get pfSignInApple => 'Apple से साइन इन करें';

  @override
  String get pfNoReplays => 'अभी कोई रिप्ले नहीं। कुछ गेम खेलें!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिप्ले सहेजे गए',
      one: '$count रिप्ले सहेजा गया',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'खाता प्रबंधन';

  @override
  String get pfSignOut => 'साइन आउट';

  @override
  String get pfDeleteAccount => 'खाता हटाएँ';

  @override
  String get pfAppleUpgradeSuccess => 'Apple खाते में सफलतापूर्वक अपग्रेड! 🎉';

  @override
  String get pfAppleIdInUse =>
      'उस Apple ID का पहले से खाता है। साइन आउट करके Apple से साइन इन करें।';

  @override
  String get pfUpgradeFailed =>
      'खाता अपग्रेड नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get pfUpgradeError => 'खाता अपग्रेड के दौरान त्रुटि हुई।';

  @override
  String get pfGoogleUpgradeSuccess =>
      'Google खाते में सफलतापूर्वक अपग्रेड! 🎉';

  @override
  String get pfDeleteAccountTitle => 'खाता हटाएँ?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'यह आपका खाता और उससे जुड़ी हर चीज़ स्थायी रूप से हटा देता है:\n\n• उच्चतम स्कोर और आँकड़े\n• सिक्के और खरीदी गई वस्तुएँ\n• थीम, स्किन, ट्रेल और पावर-अप\n• बैटल पास और चुनौती प्रगति\n• लीडरबोर्ड प्रविष्टियाँ और दोस्त\n\nइसे पूर्ववत नहीं किया जा सकता। सक्रिय सदस्यताएँ $storeName सेटिंग्स में अलग से रद्द करनी होंगी।';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'डिवाइस के ऐप स्टोर';

  @override
  String get pfAccountDeleted => 'आपका खाता स्थायी रूप से हटा दिया गया है।';

  @override
  String get pfDeleteFailed =>
      'खाता नहीं हटाया जा सका। कनेक्शन जाँचकर फिर कोशिश करें।';

  @override
  String get pfDeleteForever => 'हमेशा के लिए हटाएँ';

  @override
  String get pfSignOutBody =>
      'क्या आप वाकई साइन आउट करना चाहते हैं?\n\nGoogle से साइन इन होने पर आपकी प्रगति सहेजी रहेगी।';

  @override
  String get pfSignedOut => 'सफलतापूर्वक साइन आउट 👋';

  @override
  String get stLoading => 'आँकड़े लोड हो रहे हैं...';

  @override
  String get stPerformanceOverview => 'प्रदर्शन अवलोकन';

  @override
  String get stTotalGames => 'कुल गेम';

  @override
  String get stWinStreak => 'जीत की लड़ी';

  @override
  String get stGameActivity => 'गेम गतिविधि';

  @override
  String get stLongestGame => 'सबसे लंबा गेम';

  @override
  String get stHighestLevel => 'उच्चतम स्तर';

  @override
  String get stPerfectGames => 'परफ़ेक्ट गेम';

  @override
  String get stFoodPowerUps => 'भोजन और पावर-अप';

  @override
  String get stPowerUpsUsed => 'इस्तेमाल हुए पावर-अप';

  @override
  String get stFavoriteFood => 'पसंदीदा भोजन';

  @override
  String get stFavoritePowerUp => 'पसंदीदा पावर-अप';

  @override
  String get stPerformanceTrends => 'प्रदर्शन रुझान';

  @override
  String get stOverallTrend => 'समग्र रुझान';

  @override
  String get stRecentAverage => 'हाल का औसत';

  @override
  String get stBestRecent => 'हाल का सर्वश्रेष्ठ';

  @override
  String get stConsistency => 'स्थिरता';

  @override
  String get stScores => 'स्कोर';

  @override
  String get stTrendLine => 'रुझान रेखा';

  @override
  String get stPlayPatterns => 'खेल पैटर्न (पिछले 7 दिन)';

  @override
  String get stWeeklyTime => 'साप्ताहिक समय';

  @override
  String get stMostActiveDay => 'सबसे सक्रिय दिन';

  @override
  String get stDailyActivity => 'दैनिक गतिविधि';

  @override
  String get stAchievementProgress => 'उपलब्धि प्रगति';

  @override
  String get stViewAllAchievements => 'सभी उपलब्धियाँ देखें →';

  @override
  String get stViewAchievements => 'उपलब्धियाँ देखें';

  @override
  String get stReplaysUpper => 'रिप्ले';

  @override
  String get stResetStatistics => 'आँकड़े रीसेट करें';

  @override
  String get stResetTitle => 'आँकड़े रीसेट करें?';

  @override
  String get stResetBody =>
      'यह आपके सभी गेम आँकड़े स्थायी रूप से हटा देगा। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get stReset => 'रीसेट';

  @override
  String get stNA => 'लागू नहीं';

  @override
  String get stExcellent => 'उत्कृष्ट';

  @override
  String get stGood => 'अच्छा';

  @override
  String get stFair => 'ठीक-ठाक';

  @override
  String get stPoor => 'कमज़ोर';

  @override
  String get stNoData => 'कोई डेटा नहीं';

  @override
  String get stNone => 'कोई नहीं';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गेम',
      one: '$count गेम',
    );
    return 'प्रगति (पिछले $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent पूर्ण';
  }

  @override
  String get stInsights => 'प्रदर्शन अंतर्दृष्टि';

  @override
  String get stInsightPlayMore =>
      'प्रदर्शन अंतर्दृष्टि पाने के लिए और गेम खेलें!';

  @override
  String get stInsightImproving => 'शाबाश! आपका प्रदर्शन ऊपर की ओर जा रहा है।';

  @override
  String get stInsightAboveAverage =>
      'आपके हाल के गेम आपके औसत से काफ़ी ऊपर हैं।';

  @override
  String get stInsightDeclined =>
      'हाल में आपका प्रदर्शन गिरा है। और अभ्यास करें।';

  @override
  String get stInsightPractice =>
      'टक्करों से बचने और चालें पहले से सोचने पर ध्यान दें।';

  @override
  String get stInsightStable =>
      'आपका प्रदर्शन स्थिर है। खुद को बेहतर बनाने की चुनौती दें!';

  @override
  String get stInsightPotential =>
      'आपमें ऊँचे स्कोर की क्षमता है - स्थिरता पर काम करें।';

  @override
  String get stInsightSolid =>
      'आप हाल के गेम में लगातार अच्छा प्रदर्शन बनाए हुए हैं।';

  @override
  String get frTitle => 'दोस्त';

  @override
  String get frBlockedUsers => 'ब्लॉक किए गए उपयोगकर्ता';

  @override
  String get frSearchHint => 'नाम या ईमेल से खोजें...';

  @override
  String get frSearching => 'खोज रहे हैं...';

  @override
  String get frSearchTitle => 'दोस्त खोजें';

  @override
  String get frSearchSubtitle => 'दोस्त खोजने के लिए नाम या ईमेल दर्ज करें';

  @override
  String get frNoUsersFound => 'कोई उपयोगकर्ता नहीं मिला';

  @override
  String get frNoUsersFoundSub => 'किसी और नाम या ईमेल से खोजने की कोशिश करें';

  @override
  String get frRequests => 'अनुरोध';

  @override
  String get frSearch => 'खोज';

  @override
  String get frNoCacheYet => 'अभी कोई कैश नहीं';

  @override
  String frUpdatedAgo(Object ago) {
    return 'अपडेट $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · रीफ़्रेश विफल, फिर से आज़माने के लिए टैप करें';
  }

  @override
  String get frJustNow => 'अभी-अभी';

  @override
  String frSecondsAgo(Object count) {
    return '$count से. पहले';
  }

  @override
  String frMinutesAgo(Object count) {
    return '$count मि. पहले';
  }

  @override
  String frHoursAgo(Object count) {
    return '$count घं. पहले';
  }

  @override
  String frDaysAgo(Object count) {
    return '$count दिन पहले';
  }

  @override
  String get frLoadingFriends => 'दोस्त लोड हो रहे हैं...';

  @override
  String get frNoFriendsYet => 'अभी कोई दोस्त नहीं';

  @override
  String get frNoFriendsSub => 'दोस्त बनाने के लिए उपयोगकर्ता खोजें!';

  @override
  String get frNoRequests => 'कोई मित्र अनुरोध नहीं';

  @override
  String get frNoRequestsSub => 'मित्र अनुरोध यहाँ दिखेंगे';

  @override
  String get frChallengeMenu => 'मैच की चुनौती दें';

  @override
  String get frViewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get frRemoveFriend => 'दोस्त हटाएँ';

  @override
  String get frBlockUser => 'उपयोगकर्ता ब्लॉक करें';

  @override
  String frReceivedHeader(Object count) {
    return 'प्राप्त ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'भेजे गए ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गेम',
      one: '$count गेम',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'भेजा गया $date';
  }

  @override
  String get frPending => 'लंबित';

  @override
  String get frCancelRequest => 'अनुरोध रद्द करें';

  @override
  String get frReject => 'अस्वीकार';

  @override
  String get frAccept => 'स्वीकार';

  @override
  String get frAlreadyFriends => '✓ दोस्त';

  @override
  String get frAddFriend => 'दोस्त जोड़ें';

  @override
  String get frSendRequestFailed =>
      'मित्र अनुरोध नहीं भेजा जा सका — कनेक्शन जाँचकर फिर कोशिश करें';

  @override
  String get frAcceptFailed =>
      'अनुरोध स्वीकार नहीं हो सका — कनेक्शन जाँचकर फिर कोशिश करें';

  @override
  String get frRejectFailed =>
      'अनुरोध अस्वीकार नहीं हो सका — कनेक्शन जाँचकर फिर कोशिश करें';

  @override
  String get frCancelFailed =>
      'अनुरोध रद्द नहीं हो सका — कनेक्शन जाँचकर फिर कोशिश करें';

  @override
  String get frBlockFailed =>
      'उपयोगकर्ता ब्लॉक नहीं हो सका — कनेक्शन जाँचकर फिर कोशिश करें';

  @override
  String get frSignInSocial =>
      'दोस्त जोड़ने और सोशल सुविधाओं के लिए साइन इन करें';

  @override
  String get frRequestSent => 'मित्र अनुरोध भेजा गया!';

  @override
  String get frRequestAccepted => 'मित्र अनुरोध स्वीकार!';

  @override
  String get frRequestRejected => 'मित्र अनुरोध अस्वीकृत';

  @override
  String get frRequestCancelled => 'मित्र अनुरोध रद्द';

  @override
  String frChallengeSent(Object name) {
    return '🎮 $name को चुनौती भेजी गई!';
  }

  @override
  String get frChallengeFailed => 'चुनौती नहीं भेजी जा सकी — फिर कोशिश करें';

  @override
  String frBlocked(Object name) {
    return '$name ब्लॉक किया गया';
  }

  @override
  String frUnblocked(Object name) {
    return '$name अनब्लॉक किया गया';
  }

  @override
  String get frUnblockFailed => 'अनब्लॉक नहीं हो सका — फिर कोशिश करें';

  @override
  String frRemoved(Object name) {
    return '$name दोस्तों से हटाया गया';
  }

  @override
  String frBlockTitle(Object name) {
    return '$name को ब्लॉक करें?';
  }

  @override
  String get frBlockBody =>
      'वे आपके दोस्तों से हटा दिए जाएँगे और आपको मित्र अनुरोध या मैच चुनौती नहीं भेज पाएँगे। उन्हें सूचित नहीं किया जाएगा।';

  @override
  String get frBlock => 'ब्लॉक करें';

  @override
  String get frNoBlocked => 'आपने किसी को ब्लॉक नहीं किया है।';

  @override
  String get frUnblock => 'अनब्लॉक';

  @override
  String frHighScoreLine(Object score) {
    return 'उच्चतम स्कोर: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'कुल गेम: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'स्तर: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'स्थिति: \"$status\"';
  }

  @override
  String frRemoveBody(Object name) {
    return '$name को अपनी दोस्तों की सूची से हटाएँ?';
  }

  @override
  String get frRemove => 'हटाएँ';

  @override
  String get frLeaderboardTitle => 'दोस्तों का लीडरबोर्ड';

  @override
  String get frLeaderboardSubtitle => 'अपने दोस्तों से मुक़ाबला करें';

  @override
  String get frLoadingLeaderboard => 'लीडरबोर्ड लोड हो रहा है...';

  @override
  String frRankBadge(Object rank) {
    return '#$rank';
  }

  @override
  String get frYou => 'आप';

  @override
  String get frLeaderboardEmptySub =>
      'अपना निजी लीडरबोर्ड देखने के लिए दोस्त जोड़ें!';

  @override
  String get frAddFriends => 'दोस्त जोड़ें';

  @override
  String get tnTitle => 'टूर्नामेंट';

  @override
  String get tnActive => 'सक्रिय';

  @override
  String get tnHistory => 'इतिहास';

  @override
  String get tnMyStats => 'मेरे आँकड़े';

  @override
  String get tnLoading => 'टूर्नामेंट लोड हो रहे हैं...';

  @override
  String get tnNoActive => 'कोई सक्रिय टूर्नामेंट नहीं';

  @override
  String get tnNoActiveSub => 'नए टूर्नामेंट के लिए बाद में देखें!';

  @override
  String get tnNoHistory => 'कोई टूर्नामेंट इतिहास नहीं';

  @override
  String get tnNoHistorySub => 'इतिहास देखने के लिए टूर्नामेंट में भाग लें!';

  @override
  String get tnNoStats => 'कोई टूर्नामेंट आँकड़े नहीं';

  @override
  String get tnNoStatsSub => 'अपनी प्रगति देखने के लिए टूर्नामेंट जॉइन करें!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max खिलाड़ी';
  }

  @override
  String get tnJoined => 'शामिल';

  @override
  String tnBestScoreChip(Object score) {
    return 'सर्वश्रेष्ठ: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'रैंक #$rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count इनाम उपलब्ध',
      one: '$count इनाम उपलब्ध',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'विवरण देखें →';

  @override
  String get tnOverviewCard => 'टूर्नामेंट अवलोकन';

  @override
  String get tnWins => 'जीत';

  @override
  String get tnTopThree => 'शीर्ष 3 स्थान';

  @override
  String get tnBestScore => 'सर्वश्रेष्ठ स्कोर';

  @override
  String get tnDetailedStats => 'विस्तृत आँकड़े';

  @override
  String get tnTotalAttempts => 'कुल प्रयास';

  @override
  String get tnWinRate => 'जीत दर';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'औसत प्रदर्शन';

  @override
  String tnTopPercent(Object percent) {
    return 'शीर्ष $percent%';
  }

  @override
  String get tnNotFound => 'टूर्नामेंट नहीं मिला';

  @override
  String get tnLoadFailed => 'टूर्नामेंट लोड नहीं हो सका';

  @override
  String get tnLoadingTournament => 'टूर्नामेंट लोड हो रहा है...';

  @override
  String get tnGoBack => 'वापस जाएँ';

  @override
  String get tnParticipating => 'आप भाग ले रहे हैं!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'सर्वश्रेष्ठ स्कोर: $score • प्रयास: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'रैंक #$rank';
  }

  @override
  String get tnOverview => 'अवलोकन';

  @override
  String get tnLeaderboard => 'लीडरबोर्ड';

  @override
  String get tnRules => 'नियम';

  @override
  String get tnLeaderboardFailed => 'लीडरबोर्ड लोड नहीं हो सका';

  @override
  String get tnCheckConnection => 'कनेक्शन जाँचकर फिर कोशिश करें।';

  @override
  String get tnNoParticipants => 'अभी कोई प्रतिभागी नहीं';

  @override
  String get tnBeFirst => 'सबसे पहले जॉइन करें!';

  @override
  String get tnDescription => 'विवरण';

  @override
  String get tnRewards => 'इनाम';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रयास',
      one: '$count प्रयास',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'टूर्नामेंट नियम';

  @override
  String get tnScoringSystem => 'स्कोरिंग प्रणाली';

  @override
  String get tnScoringBody =>
      'टूर्नामेंट अवधि में आपका उच्चतम स्कोर अंतिम रैंकिंग में गिना जाएगा। स्कोर सुधारने के लिए आप कई बार खेल सकते हैं।';

  @override
  String get tnJoining => 'जॉइन हो रहा है…';

  @override
  String get tnJoin => 'टूर्नामेंट जॉइन करें';

  @override
  String get tnPlayNow => 'अभी खेलें';

  @override
  String get tnProUnlimited => 'प्रो · असीमित प्रविष्टियाँ';

  @override
  String tnEntriesRemaining(Object count) {
    return 'शेष प्रविष्टियाँ: $count';
  }

  @override
  String get tnNoEntries => 'कोई प्रविष्टि नहीं — खरीदने के लिए जॉइन दबाएँ';

  @override
  String tnStarts(Object time) {
    return 'शुरू $time';
  }

  @override
  String get tnRule1 => 'स्कोर गिने जाने के लिए टूर्नामेंट अवधि में खेलें';

  @override
  String get tnRule2 =>
      'आप कई बार खेल सकते हैं - केवल उच्चतम स्कोर गिना जाता है';

  @override
  String get tnRule3 => 'भाग लेने के लिए साइन इन ज़रूरी है';

  @override
  String get tnRule4 => 'अंतिम रैंकिंग टूर्नामेंट समाप्ति पर तय होती है';

  @override
  String get tnRuleSpeed => 'हर 10 अंक पर गेम की गति तेज़ी से बढ़ती है';

  @override
  String get tnRuleSurvival =>
      'स्कोर जीवित रहने के समय पर आधारित है, खाए भोजन पर नहीं';

  @override
  String get tnRuleNoWalls =>
      'साँप दीवारों से टकराने के बजाय स्क्रीन किनारों के आर-पार जाता है';

  @override
  String get tnRulePowerUps => 'हर 5 सेकंड में पावर-अप आते हैं';

  @override
  String get tnRulePerfect => 'कोई भी टक्कर तुरंत गेम समाप्त कर देती है';

  @override
  String get tnRuleClassic => 'मानक साँप नियम लागू';

  @override
  String get tnJoinSuccess => 'टूर्नामेंट में सफलतापूर्वक शामिल!';

  @override
  String get tnJoinFailed => 'टूर्नामेंट जॉइन नहीं हो सका';

  @override
  String get tnJoinError => 'टूर्नामेंट जॉइन करने में त्रुटि';

  @override
  String get tnTierBronze => 'कांस्य';

  @override
  String get tnTierSilver => 'रजत';

  @override
  String get tnTierGold => 'स्वर्ण';

  @override
  String get tnEntryRequired => 'प्रविष्टि आवश्यक';

  @override
  String tnEntryNeeded(Object tier) {
    return 'इस टूर्नामेंट में शामिल होने के लिए $tier प्रविष्टि चाहिए।';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'मौजूदा $tier प्रविष्टियाँ: $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'प्रो सदस्यों को असीमित टूर्नामेंट एक्सेस मिलती है।';

  @override
  String get tnFreeBronzeAdded =>
      '🎉 मुफ़्त कांस्य टूर्नामेंट प्रविष्टि जुड़ गई!';

  @override
  String get tnFreeEntryAd => 'मुफ़्त प्रविष्टि (विज्ञापन)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return '$tier प्रविष्टि खरीदें - $price';
  }

  @override
  String get acAll => 'सभी';

  @override
  String get acUnlocked => 'अनलॉक';

  @override
  String get acLocked => 'लॉक';

  @override
  String get acTotalUpper => 'कुल';

  @override
  String get acUnlockedUpper => 'अनलॉक';

  @override
  String get acClaimedUpper => 'प्राप्त';

  @override
  String get acPendingUpper => 'लंबित';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% पूर्ण';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return 'अनलॉक का $percent%';
  }

  @override
  String get acEmpty => 'यहाँ कोई उपलब्धि नहीं';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'अनलॉक $date';
  }

  @override
  String get rpTitle => 'गेम रिप्ले';

  @override
  String get rpRecent => 'हाल के';

  @override
  String get rpBest => 'सर्वश्रेष्ठ';

  @override
  String get rpCrashes => 'टक्करें';

  @override
  String get rpLoading => 'रिप्ले लोड हो रहे हैं...';

  @override
  String get rpNoRecent => 'कोई हालिया रिप्ले नहीं';

  @override
  String get rpNoBest => 'कोई हाई-स्कोर रिप्ले नहीं';

  @override
  String get rpNoCrashes => 'कोई क्रैश रिप्ले नहीं';

  @override
  String get rpEmptySub => 'रिप्ले बनाने के लिए कुछ गेम खेलें!';

  @override
  String get rpScore => 'स्कोर';

  @override
  String get rpDuration => 'अवधि';

  @override
  String get rpFood => 'भोजन';

  @override
  String get rpFrames => 'फ़्रेम';

  @override
  String get rpMaxLength => 'अधिकतम लंबाई';

  @override
  String get rpWatch => 'देखें';

  @override
  String get rpYesterday => 'कल';

  @override
  String get rpDeleteTitle => 'रिप्ले हटाएँ';

  @override
  String rpDeleteBody(Object date) {
    return '$date का रिप्ले हटाएँ?';
  }

  @override
  String get rpDelete => 'हटाएँ';

  @override
  String get rpDeleted => 'रिप्ले हटाया गया';

  @override
  String get rpDeleteFailed => 'रिप्ले नहीं हटाया जा सका';

  @override
  String get lbTitle => 'लीडरबोर्ड';

  @override
  String get lbGlobal => 'वैश्विक';

  @override
  String get lbWeekly => 'साप्ताहिक';

  @override
  String get lbWeeklySub =>
      'इस सप्ताह के आपके सर्वश्रेष्ठ एकल-गेम स्कोर से रैंक (रविवार को रीसेट)';

  @override
  String get lbGlobalSub => 'आपके अब तक के उच्चतम एकल-गेम स्कोर से रैंक';

  @override
  String lbScoreLine(Object score) {
    return 'स्कोर: $score';
  }

  @override
  String get lbLoadingGlobal => 'वैश्विक लीडरबोर्ड लोड हो रहा है...';

  @override
  String get lbLoadingWeekly => 'साप्ताहिक लीडरबोर्ड लोड हो रहा है...';

  @override
  String get lbNoScores => 'अभी कोई स्कोर नहीं';

  @override
  String get lbBeFirst => 'सबसे पहले हाई स्कोर बनाएँ!';

  @override
  String get lbNoWeekly => 'इस सप्ताह कोई स्कोर नहीं';

  @override
  String get lbPlayThisWeek => 'यहाँ दिखने के लिए इस सप्ताह खेलें!';

  @override
  String get lbAnonymous => 'अनाम';

  @override
  String get lbGuestBadge => 'अतिथि';

  @override
  String get lbPts => 'अंक';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count गेम खेले',
      one: '$count गेम खेला',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '$name प्राप्त!';
  }

  @override
  String get bpTitle => 'बैटल पास';

  @override
  String get bpTitleUpper => 'बैटल पास';

  @override
  String get bpLoading => 'बैटल पास लोड हो रहा है...';

  @override
  String get bpWatchAdXp => 'विज्ञापन देखें — +50 बैटल पास XP';

  @override
  String get bpXpEarned => '+50 बैटल पास XP मिला!';

  @override
  String get bpSeasonEnded => 'सीज़न समाप्त';

  @override
  String bpHoursLeft(Object hours) {
    return '$hoursघं शेष';
  }

  @override
  String bpDaysLeft(Object days) {
    return '$daysदि शेष';
  }

  @override
  String get bpTierUpper => 'टियर';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'सीज़न पूर्ण';

  @override
  String get bpSeasonCompleteUpper => 'सीज़न पूर्ण';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return 'टियर $tier के लिए $xp / $next XP';
  }

  @override
  String get bpPremiumBadge => 'प्रीमियम';

  @override
  String get bpUnlockedEverything =>
      'आपने इस सीज़न का हर टियर अनलॉक कर लिया है।';

  @override
  String get bpComingNext => 'आगे क्या';

  @override
  String bpTierN(Object tier) {
    return 'टियर $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टियर दूर',
      one: '$count टियर दूर',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'प्रो से अनलॉक करें';

  @override
  String get bpAvailableNow => 'अभी उपलब्ध';

  @override
  String bpTierAbbrev(Object tier) {
    return 'T$tier';
  }

  @override
  String get bpClaim => 'लें';

  @override
  String get bpPremiumWaiting => 'प्रीमियम इनाम प्रतीक्षा में';

  @override
  String get bpSubscribeToClaim => 'इन्हें पाने के लिए प्रो की सदस्यता लें।';

  @override
  String get bpHideTiers => 'टियर छिपाएँ';

  @override
  String bpViewAllTiers(Object count) {
    return 'सभी $count टियर देखें';
  }

  @override
  String get bpCollapse => 'समेटें';

  @override
  String get bpExpand => 'खोलें';

  @override
  String get bpNow => 'अभी';

  @override
  String bpTierUpperN(Object tier) {
    return 'टियर $tier';
  }

  @override
  String get bpUnlocked => 'अनलॉक';

  @override
  String bpReachTier(Object tier) {
    return 'अनलॉक करने के लिए टियर $tier तक पहुँचें';
  }

  @override
  String get bpBetweenSeasons => 'सीज़न के बीच';

  @override
  String get bpNoSeasonBody =>
      'अभी कोई बैटल पास नहीं चल रहा — अगला सीज़न अपने आप शुरू होगा। जल्द वापस देखें।';

  @override
  String get bpCheckNewSeason => 'नया सीज़न जाँचें';

  @override
  String get pbActive => 'प्रीमियम सक्रिय!';

  @override
  String get pbActiveSub => 'आपके पास सभी प्रीमियम सुविधाओं की पहुँच है';

  @override
  String get pbHeaderSub => 'गेम की हर चीज़ अनलॉक करें';

  @override
  String get pbMonthlyPlan => 'मासिक प्लान';

  @override
  String get pbYearlyPlan => 'वार्षिक प्लान';

  @override
  String get pbSave33 => '33% बचाएँ';

  @override
  String get pbMostPopular => 'सबसे लोकप्रिय';

  @override
  String get pbFeatExtraLife => 'हमेशा-मुफ़्त अतिरिक्त जीवन';

  @override
  String get pbFeatExtraLifeDesc =>
      'टकराएँ और खेलते रहें — प्रो सदस्य हर गेम में एक बार मुफ़्त तुरंत पुनर्जीवित होते हैं, न विज्ञापन न सिक्के';

  @override
  String get pbFeatNoAds => 'सभी विज्ञापन हटाएँ';

  @override
  String get pbFeatNoAdsDesc =>
      'न बैनर, न इंटरस्टीशियल — हमेशा के लिए विज्ञापन-मुक्त खेलें';

  @override
  String get pbFeatThemes => 'सभी प्रीमियम थीम';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'सभी प्रीमियम स्नेक स्किन';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice और 5 अन्य';

  @override
  String get pbFeatTrails => 'सभी प्रीमियम ट्रेल प्रभाव';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal और 5 अन्य';

  @override
  String get pbFeatBoards => 'बड़े गेम बोर्ड';

  @override
  String get pbFeatBoardsDesc => '35x35, 40x40 और 50x50 बोर्ड पर खेलें';

  @override
  String get pbFeatCoins => '2x सिक्का इनाम';

  @override
  String get pbFeatCoinsDesc => 'हर गेम से दोगुने स्नेक सिक्के';

  @override
  String get pbFeatLucky => 'लकी फ़ोरेजर — अधिक विशेष भोजन';

  @override
  String get pbFeatLuckyDesc =>
      'हर गेम में दुर्लभ 50-अंक विशेष भोजन आने की +50% संभावना';

  @override
  String get pbFeatPowerUps => 'अधिक इन-गेम पावर-अप';

  @override
  String get pbFeatPowerUpsDesc => 'गेमप्ले में बोर्ड पावर-अप की +30% दर';

  @override
  String get pbFeatBundle => 'प्रीमियम पावर-अप बंडल';

  @override
  String get pbFeatBundleDesc =>
      'हर बिलिंग चक्र में 5× Teleport, Ghost Mode, Magnetic Food, Score Shield और Mega Invincibility';

  @override
  String get pbFeatTournament => 'टूर्नामेंट प्रविष्टियाँ';

  @override
  String get pbFeatTournamentDesc =>
      'हर बिलिंग चक्र में 1× कांस्य + 1× रजत + 1× स्वर्ण टूर्नामेंट प्रविष्टि';

  @override
  String get pbIncludes => 'प्रीमियम में शामिल:';

  @override
  String get pbProPerk => 'प्रो सुविधा';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'सदस्यता लें — $price$period';
  }

  @override
  String get pbReassurance =>
      'कोई बाध्यता नहीं • कभी भी रद्द करें • सुरक्षित भुगतान';

  @override
  String get pbNotAvailable => 'प्रीमियम सदस्यता उपलब्ध नहीं';

  @override
  String get eaTitleLink => 'अपनी प्रगति सहेजें';

  @override
  String get eaTitleSignIn => 'ईमेल साइन-इन';

  @override
  String get eaExplainer =>
      'अपने खाते में ईमेल और पासवर्ड जोड़ें ताकि आप खरीदारी कर सकें, रीइंस्टॉल पर बहाल कर सकें और किसी भी डिवाइस से साइन इन कर सकें।';

  @override
  String get eaLinkExisting => 'मौजूदा से जोड़ें';

  @override
  String get eaSignIn => 'साइन इन';

  @override
  String get eaCreateAccount => 'खाता बनाएँ';

  @override
  String get eaForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get eaLinkToExisting => 'मौजूदा खाते से जोड़ें';

  @override
  String get eaMinChars => 'कम से कम 8 अक्षर';

  @override
  String eaMinCharsN(Object count) {
    return 'कम से कम $count अक्षर';
  }

  @override
  String get eaCreateAndLink => 'खाता बनाएँ और जोड़ें';

  @override
  String get eaEmail => 'ईमेल';

  @override
  String get eaEmailRequired => 'ईमेल आवश्यक है';

  @override
  String get eaEmailInvalid => 'मान्य ईमेल दर्ज करें';

  @override
  String get eaPassword => 'पासवर्ड';

  @override
  String get eaPasswordRequired => 'पासवर्ड आवश्यक है';

  @override
  String get eaForgotFirst =>
      'पहले ऊपर अपना ईमेल दर्ज करें, फिर पासवर्ड भूल गए दबाएँ।';

  @override
  String eaResetSent(Object email) {
    return 'पासवर्ड रीसेट ईमेल $email पर भेजा गया।';
  }

  @override
  String get eaErrInvalidEmail => 'यह ईमेल पता मान्य नहीं है।';

  @override
  String get eaErrDisabled => 'यह खाता अक्षम कर दिया गया है।';

  @override
  String get eaErrNoAccount => 'इस ईमेल से कोई खाता नहीं मिला।';

  @override
  String get eaErrWrongCreds => 'ईमेल या पासवर्ड गलत है।';

  @override
  String get eaErrEmailInUse =>
      'इस ईमेल से पहले से खाता है। साइन इन करके देखें।';

  @override
  String get eaErrWeakPassword =>
      'पासवर्ड बहुत कमज़ोर है। कम से कम 8 अक्षर रखें।';

  @override
  String get eaErrNotEnabled =>
      'ईमेल/पासवर्ड साइन-इन सक्षम नहीं है। सहायता से संपर्क करें।';

  @override
  String get eaErrTooMany => 'बहुत अधिक प्रयास। कुछ मिनट रुककर फिर कोशिश करें।';

  @override
  String get eaErrNetwork => 'नेटवर्क त्रुटि। कनेक्शन जाँचें।';

  @override
  String get eaErrAlreadyLinked => 'यह खाता पहले से ईमेल/पासवर्ड से जुड़ा है।';

  @override
  String get eaErrRecentLogin =>
      'सुरक्षा के लिए, जोड़ने से पहले फिर से साइन इन करें।';

  @override
  String get eaErrGeneric => 'कुछ गड़बड़ हुई। कृपया फिर कोशिश करें।';

  @override
  String get faWelcome => 'स्वागत है\nSnake Classic में!';

  @override
  String get faChooseHow => 'चुनें कि आप कैसे खेलना चाहेंगे:';

  @override
  String get faSigningIn => 'साइन इन हो रहा है...';

  @override
  String get faSignInEmail => 'ईमेल से साइन इन करें';

  @override
  String get faContinueGuest => 'अतिथि के रूप में जारी रखें';

  @override
  String get faGuestNote =>
      'अतिथि खेल सकते हैं और प्रगति स्थानीय रूप से सहेज सकते हैं, पर खरीदारी नहीं कर सकते। सदस्यता या खरीद के लिए तैयार हों तो Apple, Google या ईमेल से साइन इन करें।';

  @override
  String get faPrivacyTerms => 'गोपनीयता और शर्तें';

  @override
  String get faReviewNote =>
      'जारी रखने से पहले कृपया हमारी गोपनीयता नीति और उपयोग की शर्तें देखें';

  @override
  String get faAgreeCheckbox =>
      'मैंने गोपनीयता नीति और उपयोग की शर्तें पढ़ी हैं और सहमत हूँ';

  @override
  String get faContinueToSignIn => 'साइन इन जारी रखें';

  @override
  String get faHeadsUp => 'ध्यान दें';

  @override
  String get faGuestBullet1 =>
      'अतिथि डेटा 90 दिनों की निष्क्रियता के बाद हमारे सर्वर से अपने आप हट जाता है।';

  @override
  String get faGuestBullet2 =>
      'प्रगति स्थायी रूप से सहेजने और सभी डिवाइस पर खेलने के लिए Apple, Google या ईमेल से साइन इन करें।';

  @override
  String get faGuestBullet3 =>
      'अतिथि खाते उत्पाद या सदस्यता नहीं खरीद सकते। प्रो लेने या कॉस्मेटिक्स खरीदने के लिए साइन इन करें।';

  @override
  String get faChangedMind => 'मैंने विचार बदल लिया';

  @override
  String get faProceedAnyway => 'फिर भी जारी रखें';

  @override
  String get faAppleFailed =>
      'Apple से साइन इन नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get faGoogleFailed =>
      'Google से साइन इन नहीं हो सका। कृपया फिर कोशिश करें।';

  @override
  String get faUnexpected => 'अनपेक्षित त्रुटि हुई। कृपया फिर कोशिश करें।';

  @override
  String get faGuestFailed =>
      'अतिथि के रूप में जारी नहीं रखा जा सका। कृपया फिर कोशिश करें।';

  @override
  String get ldInitializing => 'Snake Classic शुरू हो रहा है...';

  @override
  String get ldTip1 =>
      'दो चालें आगे सोचें — पूँछ वहीं जाती है जहाँ सिर अभी गया था।';

  @override
  String get ldTip2 =>
      'बोनस भोजन ज़्यादा अंक देता है, पर जल्दी गायब हो जाता है। फटाफट लें!';

  @override
  String get ldTip3 =>
      'टकरा गए? छोटा विज्ञापन देखें या सिक्के खर्च कर पुनर्जीवित हों और स्कोर बचाएँ।';

  @override
  String get ldTip4 => 'बिना रुके भोजन की श्रृंखला बनाकर कॉम्बो गुणक बढ़ाएँ।';

  @override
  String get ldTip5 => 'तंग जगह फँसे हैं? दीवारों के सहारे चलकर समय पाएँ।';

  @override
  String get ldTip6 =>
      'दैनिक चुनौतियाँ और साप्ताहिक क्वेस्ट तेज़ी से सिक्के जोड़ते हैं।';

  @override
  String get ldTip7 =>
      'Snake Classic Pro बड़े बोर्ड खोलता है और सारे विज्ञापन हटाता है।';

  @override
  String get ldTip8 =>
      'टाइम अटैक गति का इनाम देता है — विज्ञापन देखकर +30 सेकंड भी पाएँ।';

  @override
  String get ldTip9 =>
      'पावर-अप जुड़ते हैं: तंग रास्ते से पहले शील्ड तैयार रखें।';

  @override
  String get ldTip10 =>
      'नए लुक के लिए स्टोर में कभी भी थीम, स्किन और ट्रेल बदलें।';

  @override
  String get ldStepCore => 'मुख्य सिस्टम शुरू हो रहे हैं...';

  @override
  String get ldStepCoreSub => 'सर्वर कनेक्शन सेट हो रहा है';

  @override
  String get ldStepProfile => 'आपकी खिलाड़ी प्रोफ़ाइल बन रही है...';

  @override
  String get ldStepProfileSub => 'अनोखा उपयोगकर्ता नाम बन रहा है';

  @override
  String get ldStepPrefs => 'आपकी प्राथमिकताएँ लोड हो रही हैं...';

  @override
  String get ldStepPrefsSub => 'थीम और सेटिंग्स सिंक हो रही हैं';

  @override
  String get ldStepCloud => 'क्लाउड से सिंक हो रहा है...';

  @override
  String get ldStepCloudSub => 'डेटा अद्यतन किया जा रहा है';

  @override
  String get ldStepGameData => 'गेम डेटा लोड हो रहा है...';

  @override
  String get ldStepGameDataSub => 'गेम डेटा लाया जा रहा है';

  @override
  String get ldStepAudio => 'ऑडियो सिस्टम सेट हो रहा है...';

  @override
  String get ldStepAudioSub => 'ध्वनि प्रभाव लोड हो रहे हैं';

  @override
  String get ldStepSetup => 'सेटअप स्थिति जाँची जा रही है...';

  @override
  String get ldStepSetupSub => 'बस तैयार!';

  @override
  String get ldWelcome => 'स्वागत है!';

  @override
  String get ldWelcomeSub => 'आगे बढ़ने का तरीका चुनें';

  @override
  String get ldReady => 'खेलने के लिए तैयार!';

  @override
  String get ldReadySub => 'Snake Classic में वापसी पर स्वागत है';

  @override
  String ldInitFailed(Object error) {
    return 'आरंभ विफल: $error';
  }

  @override
  String get ldRetrying => 'फिर से आरंभ हो रहा है...';

  @override
  String get ldTagline => 'प्रीमियम स्नेक अनुभव';

  @override
  String get ldLoadingUpper => 'लोड हो रहा है';

  @override
  String get ldDidYouKnow => 'क्या आप जानते हैं?';

  @override
  String get ldGameFeatures => 'गेम विशेषताएँ';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'स्मूद गेमप्ले';

  @override
  String get ldFeatEffects => 'प्रभाव';

  @override
  String get ldFeatEffectsSub => 'विज़ुअल कण';

  @override
  String get ldFeatLevels => 'स्तर';

  @override
  String get ldFeatLevelsSub => 'बढ़ता मज़ा';

  @override
  String get ldFeatAudio => 'ऑडियो';

  @override
  String get ldFeatAudioSub => 'डूब जाने वाली ध्वनि';

  @override
  String get ldFeatScores => 'स्कोर';

  @override
  String get ldFeatScoresSub => 'वैश्विक रैंकिंग';

  @override
  String get ldFeatThemes => 'थीम';

  @override
  String get ldFeatThemesSub => 'कई शैलियाँ';

  @override
  String get ldDevelopedBy => 'विकास और रखरखाव';

  @override
  String get ldDevTagline => 'प्रीमियम मोबाइल अनुभव गढ़ते हुए';

  @override
  String get ldInitFailedUpper => 'आरंभ विफल';

  @override
  String get ldRetryUpper => 'फिर कोशिश करें';

  @override
  String get pgArena => 'मैदान तैयार हो रहा है...';

  @override
  String get pgControls => 'नियंत्रण सेट हो रहे हैं...';

  @override
  String get pgSnake => 'साँप आ रहा है...';

  @override
  String get pgFood => 'भोजन रखा जा रहा है...';

  @override
  String get pgPowerUps => 'पावर-अप चार्ज हो रहे हैं...';

  @override
  String get pgAlmost => 'बस थोड़ा और...';

  @override
  String get pgGo => 'चलो!';

  @override
  String get pgTip1 => 'कॉम्बो गुणक बनाने के लिए दिशा को देर तक बनाए रखें।';

  @override
  String get pgTip2 => 'बोनस भोजन ज़्यादा अंक देता है पर जल्दी गायब होता है।';

  @override
  String get pgTip3 => 'पावर-अप कहीं भी आ सकते हैं — मौका मिलते ही लें।';

  @override
  String get pgTip4 => 'सिर्फ़ एक नहीं, दो चालें आगे सोचें।';

  @override
  String get pgTip5 =>
      'लंबे साँप धीरे मुड़ते हैं। तीखे मोड़ शुरुआत के लिए बचाएँ।';

  @override
  String get pgTip6 => 'स्कोर गुणक कॉम्बो के साथ मिलकर विशाल स्कोर देता है।';

  @override
  String get pgTip7 => 'विशेष भोजन दुर्लभ है — दिखे तो पहले उसे लें।';

  @override
  String get pgTip8 =>
      'टाइम अटैक तेज़ी से रफ़्तार पकड़ता है। मोड़ों की गति साधें।';

  @override
  String get pgTip9 =>
      'ज़ेन मोड में दीवारें आर-पार हैं। तंग जगह से बचने में इस्तेमाल करें।';

  @override
  String get pgTip10 => 'परफ़ेक्ट गेम: शरीर से छुई कोठरी में दोबारा न जाएँ।';

  @override
  String get pgTip11 => 'डी-पैड सटीक मोड़ देता है; स्वाइप तेज़ है।';

  @override
  String get pgTip12 => 'HUD से कभी भी रोकें — टाइमर आपके साथ रुकता है।';

  @override
  String get pgPreparing => 'मैदान तैयार हो रहा है';

  @override
  String get pgTournamentMode => 'टूर्नामेंट मोड';

  @override
  String get pgGameMode => 'गेम मोड';

  @override
  String get pgDPadControls => 'डी-पैड नियंत्रण';

  @override
  String get pgSwipeControls => 'स्वाइप नियंत्रण';

  @override
  String get pgLevel => 'स्तर';

  @override
  String get pgBest => 'सर्वश्रेष्ठ';

  @override
  String get pgGames => 'गेम';

  @override
  String get pgProTip => 'प्रो टिप';

  @override
  String get pgTapToStart => 'शुरू करने के लिए कहीं भी टैप करें';

  @override
  String get wtWelcomeTitle => 'गेम में स्वागत है!';

  @override
  String get wtWelcomeMsg =>
      'आइए Snake Classic खेलना सीखें। यह छोटा ट्यूटोरियल आपको मूल बातें दिखाएगा।';

  @override
  String get wtHudTitle => 'गेम जानकारी';

  @override
  String get wtHudMsg =>
      'ऊपर की पट्टी में आपका स्कोर, स्तर और उच्चतम स्कोर दिखता है। खेलते हुए अपनी प्रगति देखें!';

  @override
  String get wtControlsTitle => 'चलाने के लिए स्वाइप करें';

  @override
  String get wtControlsMsg =>
      'साँप की दिशा बदलने के लिए किसी भी दिशा में स्वाइप करें। साँप आपके स्वाइप के अनुसार मुड़ेगा।';

  @override
  String get wtPracticeRightTitle => 'आज़माएँ! दाएँ स्वाइप करें';

  @override
  String get wtPracticeRightMsg =>
      'आगे बढ़ने के लिए स्क्रीन पर दाएँ स्वाइप करें।';

  @override
  String get wtPracticeUpTitle => 'बढ़िया! अब ऊपर स्वाइप करें';

  @override
  String get wtPracticeUpMsg => 'आगे बढ़ने के लिए स्क्रीन पर ऊपर स्वाइप करें।';

  @override
  String get wtFoodTitle => 'खाकर बढ़ें';

  @override
  String get wtFoodMsg =>
      'बोर्ड पर आने वाला भोजन खाने के लिए साँप को ले जाएँ। हर भोजन साँप को लंबा करता है!';

  @override
  String get wtComboTitle => 'कॉम्बो बनाएँ';

  @override
  String get wtComboMsg =>
      'बिना मरे भोजन खाकर कॉम्बो बनाएँ। 5 बाइट पर 1.5×, 10 पर 2×, 20 पर 3× मिलता है। स्कोर के पास की आग की चिप चढ़ते हुए गर्म होकर धड़कती है।';

  @override
  String get wtPowerUpsTitle => 'पावर-अप';

  @override
  String get wtPowerUpsMsg =>
      'चमकीले आइकन कभी-कभी आते हैं — सक्रिय करने के लिए खाएँ। आइकन के चारों ओर की रिंग प्रभाव खत्म होते-होते घटती है, और रोकने पर टाइमर रुक जाता है।';

  @override
  String get wtWallsTitle => 'दीवारों से बचें!';

  @override
  String get wtWallsMsg =>
      'बोर्ड के किनारों से न टकराएँ - दीवार से टकराए तो गेम समाप्त!';

  @override
  String get wtSelfTitle => 'खुद से न टकराएँ!';

  @override
  String get wtSelfMsg => 'साँप लंबा होने पर अपने ही शरीर से टकराने से बचें!';

  @override
  String get wtPauseTitle => 'कभी भी रोकें';

  @override
  String get wtPauseMsg =>
      'रन रोकने के लिए पॉज़ आइकन दबाएँ। वहाँ से जारी रखें, पुनः शुरू करें, गेम गाइड खोलें, यह ट्यूटोरियल दोहराएँ या डी-पैड बदलें।';

  @override
  String get wtReadyTitle => 'आप तैयार हैं!';

  @override
  String get wtReadyMsg =>
      'शुभकामनाएँ! कॉम्बो, पावर-अप, मोड और क्रैश फ़ीडबैक पढ़ने के लिए पॉज़ मेनू की गेम गाइड कभी भी खोलें। लक्ष्य पूरे करने पर उपलब्धियाँ अनलॉक होते देखने के लिए प्रोफ़ाइल देखें।';

  @override
  String get wtStartPlaying => 'खेलना शुरू करें!';

  @override
  String get wtSkipTutorial => 'ट्यूटोरियल छोड़ें';

  @override
  String get wtSwipeRightUpper => 'दाएँ स्वाइप';

  @override
  String get wtSwipeLeftUpper => 'बाएँ स्वाइप';

  @override
  String get wtSwipeUpUpper => 'ऊपर स्वाइप';

  @override
  String get wtSwipeDownUpper => 'नीचे स्वाइप';

  @override
  String get wtSwipeAnywhereScreen => 'स्क्रीन पर कहीं भी स्वाइप करें!';

  @override
  String get wtSwipeAnywhere => 'कहीं भी स्वाइप करें!';

  @override
  String get wtGotIt => 'समझ गया!';

  @override
  String get wtNext => 'आगे';

  @override
  String get wtSkip => 'छोड़ें';

  @override
  String get wtWaiting => 'प्रतीक्षा...';

  @override
  String get hwPlayTitle => 'Snake Classic में स्वागत है!';

  @override
  String get hwPlayMsg =>
      'गेम शुरू करने के लिए खेलें बटन दबाएँ। साँप को स्वाइप से चलाएँ और बढ़ने के लिए भोजन खाएँ!';

  @override
  String get hwCoinsTitle => 'आपके सिक्के';

  @override
  String get hwCoinsMsg =>
      'गेम खेलकर, चुनौतियाँ पूरी करके और दैनिक बोनस से सिक्के कमाएँ। इन्हें स्टोर में खर्च करें!';

  @override
  String get hwDailyTitle => 'दैनिक चुनौतियाँ';

  @override
  String get hwDailyMsg =>
      'बोनस सिक्कों और इनामों के लिए दैनिक चुनौतियाँ पूरी करें। हर दिन नई चुनौतियाँ!';

  @override
  String get hwStoreTitle => 'स्टोर';

  @override
  String get hwStoreMsg =>
      'सिक्कों से थीम, स्किन, ट्रेल और पावर-अप खरीदें। प्रीमियम बोर्ड और खास कॉस्मेटिक्स के लिए प्रो लें।';

  @override
  String get hwCosmeticsTitle => 'स्किन और ट्रेल';

  @override
  String get hwCosmeticsMsg =>
      'यहाँ अपने साँप को सजाएँ। स्किन साँप का रूप बदलती हैं; ट्रेल पीछे चमक छोड़ती हैं। सिक्कों से पाएँ या प्रो से अनलॉक करें।';

  @override
  String get hwProfileTitle => 'आपकी प्रोफ़ाइल';

  @override
  String get hwProfileMsg =>
      'आँकड़े, उपलब्धियाँ और उच्चतम स्कोर यहाँ हैं। पड़ाव पार करने पर उपलब्धियाँ अनलॉक होती हैं — कुछ को खास मोड चाहिए (क्लासिक, कठिन आदि)। सभी डिवाइस पर सिंक के लिए साइन इन करें।';

  @override
  String get hwSettingsTitle => 'सेटिंग्स';

  @override
  String get hwSettingsMsg =>
      'अपना अनुभव सजाएँ - थीम, नियंत्रण, ऑडियो और बहुत कुछ बदलें!';

  @override
  String get hudScoreUpper => 'स्कोर';

  @override
  String hudScoreSemantics(Object value) {
    return 'स्कोर $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'स्तर$level';
  }

  @override
  String get hudTournamentBadge => 'टूर्नामेंट';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'रुका हुआ';

  @override
  String get poPremium => 'प्रीमियम';

  @override
  String get poStore => 'स्टोर';

  @override
  String get poResume => 'जारी रखें';

  @override
  String get poRestart => 'फिर शुरू करें';

  @override
  String get poHome => 'होम';

  @override
  String get poDPadOn => 'डी-पैड: चालू';

  @override
  String get poDPadOff => 'डी-पैड: बंद';

  @override
  String get poSound => 'ध्वनि';

  @override
  String get poMusic => 'संगीत';

  @override
  String get poHowToPlay => 'कैसे खेलें';

  @override
  String get poGameGuide => 'गेम गाइड';

  @override
  String get poFoodUpper => 'भोजन';

  @override
  String get poPts10 => '10 अंक';

  @override
  String get poPts25 => '25 अंक';

  @override
  String get poPts50 => '50 अंक';

  @override
  String get poComboUpper => 'कॉम्बो';

  @override
  String get poBites5 => '5 बाइट';

  @override
  String get poBites10 => '10 बाइट';

  @override
  String get poBites20 => '20 बाइट';

  @override
  String get poComboHint =>
      'स्कोर के पास की आग की चिप हर स्तर पार करने पर गर्म होकर धड़कती है।';

  @override
  String get poPowerUpsUpper => 'पावर-अप';

  @override
  String get poDur7s => '7 से.';

  @override
  String get poDur6s => '6 से.';

  @override
  String get poDur10s => '10 से.';

  @override
  String get poDur8s => '8 से.';

  @override
  String get poScore2x => 'स्कोर 2×';

  @override
  String get poPowerUpHint =>
      'आइकन की रिंग समाप्ति तक घटती है। रोकने पर टाइमर रुकता है।';

  @override
  String get poCrashUpper => 'टक्कर';

  @override
  String get poCrashHint =>
      'जिस कोठरी पर आप मरे वहाँ लाल झटका दिखता है। खुद से टकराने पर टकराया हिस्सा पीले रंग में दिखता है।';

  @override
  String get poModesUpper => 'मोड';

  @override
  String get poModeWallsOn => 'दीवारें चालू';

  @override
  String get poModeWallsOff => 'दीवारें बंद';

  @override
  String get poModeFastTick => 'तेज़ चाल';

  @override
  String get poModeThreeFoods => 'एक साथ 3 भोजन';

  @override
  String get poModeThreeLives => '3 जीवन, बढ़ती गति';

  @override
  String get poModeThreeMin => 'कुल 3 मिनट';

  @override
  String get poModeFrequentPowerUps => 'बार-बार पावर-अप';

  @override
  String get poModeDontCross => 'अपनी राह न काटें';

  @override
  String get dcTitle => 'दैनिक चुनौतियाँ';

  @override
  String get dcNoChallenges => 'कोई चुनौती उपलब्ध नहीं';

  @override
  String get dcAllComplete => 'सभी पूर्ण!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count बोनस';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · बिल्ड $build';
  }

  @override
  String get crTagline => 'क्लासिक साँप गेम, नए अंदाज़ में।';

  @override
  String get crChipModes => 'मोड';

  @override
  String get crChipAchievements => 'उपलब्धियाँ';

  @override
  String get crChipDaily => 'दैनिक';

  @override
  String get crChipLeaderboards => 'लीडरबोर्ड';

  @override
  String get crChipCosmetics => 'कॉस्मेटिक्स';

  @override
  String get crCraftedBy => 'निर्माता';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · सर्वाधिकार सुरक्षित';
  }

  @override
  String get gbSpeedNormal => 'सामान्य';

  @override
  String get gbSpeedFast => 'तेज़';

  @override
  String get gbSpeedFaster => 'और तेज़';

  @override
  String get gbSpeedBlazing => 'धधकती';

  @override
  String get gbSpeedInsane => 'पागल';

  @override
  String get gbSpeedMax => 'अधिकतम';

  @override
  String get gbLength => 'लंबाई';

  @override
  String get gbSpeed => 'गति';

  @override
  String get gbLevel => 'स्तर';

  @override
  String get rarityCommon => 'सामान्य';

  @override
  String get rarityRare => 'दुर्लभ';

  @override
  String get rarityEpic => 'महाकाव्य';

  @override
  String get rarityLegendary => 'पौराणिक';

  @override
  String get rarityDiamond => 'हीरा';

  @override
  String get achTitleFirstBite => 'पहला निवाला';

  @override
  String get achDescFirstBite => 'अपना पहला अंक बनाएँ';

  @override
  String get achTitleGettingStarted => 'शुरुआत';

  @override
  String get achDescGettingStarted => '100 अंक बनाएँ';

  @override
  String get achTitleHighScorer => 'हाई स्कोरर';

  @override
  String get achDescHighScorer => 'एक ही गेम में 500 अंक बनाएँ';

  @override
  String get achTitleMasterScorer => 'मास्टर स्कोरर';

  @override
  String get achDescMasterScorer => 'एक ही गेम में 1000 अंक बनाएँ';

  @override
  String get achTitleLegendaryScorer => 'पौराणिक स्कोरर';

  @override
  String get achDescLegendaryScorer => 'एक ही गेम में 2000 अंक बनाएँ';

  @override
  String get achTitleFirstGame => 'पहला गेम';

  @override
  String get achDescFirstGame => 'अपना पहला गेम खेलें';

  @override
  String get achTitleRegularPlayer => 'नियमित खिलाड़ी';

  @override
  String get achDescRegularPlayer => '10 गेम खेलें';

  @override
  String get achTitleDedicatedPlayer => 'समर्पित खिलाड़ी';

  @override
  String get achDescDedicatedPlayer => '50 गेम खेलें';

  @override
  String get achTitleSnakeEnthusiast => 'साँप प्रेमी';

  @override
  String get achDescSnakeEnthusiast => '100 गेम खेलें';

  @override
  String get achTitleSnakeAddict => 'साँप का दीवाना';

  @override
  String get achDescSnakeAddict => '500 गेम खेलें';

  @override
  String get achTitleSurvivor => 'उत्तरजीवी';

  @override
  String get achDescSurvivor => '60 सेकंड तक टिके रहें';

  @override
  String get achTitleEndurance => 'सहनशक्ति';

  @override
  String get achDescEndurance => '2 मिनट तक टिके रहें';

  @override
  String get achTitleMarathon => 'मैराथन';

  @override
  String get achDescMarathon => '5 मिनट तक टिके रहें';

  @override
  String get achTitleNoWalls => 'दीवारों से दूर';

  @override
  String get achDescNoWalls => 'दीवारों से टकराए बिना 5 गेम खेलें';

  @override
  String get achTitleSpeedster => 'रफ़्तार का बादशाह';

  @override
  String get achDescSpeedster => 'लेवल 10 तक पहुँचें (अधिकतम गति)';

  @override
  String get achTitlePerfectionist => 'पूर्णतावादी';

  @override
  String get achDescPerfectionist => 'खुद से टकराए बिना एक गेम पूरा करें';

  @override
  String get achTitleAllFoodTypes => 'पेटू';

  @override
  String get achDescAllFoodTypes => 'एक ही गेम में तीनों तरह का खाना खाएँ';

  @override
  String get achTitleHalfGrand => 'पाँच सौ पार';

  @override
  String get achDescHalfGrand => 'एक ही गेम में 5,000 अंक बनाएँ';

  @override
  String get achTitleScoreSniper => 'स्कोर स्नाइपर';

  @override
  String get achDescScoreSniper => 'एक ही गेम में 10,000 अंक बनाएँ';

  @override
  String get achTitleFiveDigitClub => 'पाँच-अंकों का क्लब';

  @override
  String get achDescFiveDigitClub => 'एक ही गेम में 25,000 अंक बनाएँ';

  @override
  String get achTitleScoreTycoon => 'स्कोर टाइकून';

  @override
  String get achDescScoreTycoon => 'एक ही गेम में 50,000 अंक बनाएँ';

  @override
  String get achTitleScoreGod => 'स्कोर के देवता';

  @override
  String get achDescScoreGod => 'एक ही गेम में 100,000 अंक बनाएँ';

  @override
  String get achTitlePointCollector => 'अंक संग्राहक';

  @override
  String get achDescPointCollector => 'कुल 10,000 अंक जमा करें';

  @override
  String get achTitlePointHoarder => 'अंकों का खज़ांची';

  @override
  String get achDescPointHoarder => 'कुल 100,000 अंक जमा करें';

  @override
  String get achTitleHalfMillionClub => 'पाँच लाख क्लब';

  @override
  String get achDescHalfMillionClub => 'कुल 500,000 अंक जमा करें';

  @override
  String get achTitlePointMillionaire => 'अंक करोड़पति';

  @override
  String get achDescPointMillionaire => 'कुल 1,000,000 अंक जमा करें';

  @override
  String get achTitleDecamillionaire => 'महा-करोड़पति';

  @override
  String get achDescDecamillionaire => 'कुल 10,000,000 अंक जमा करें';

  @override
  String get achTitleSnakeVeteran => 'साँप का अनुभवी';

  @override
  String get achDescSnakeVeteran => '1,000 गेम खेलें';

  @override
  String get achTitleSnakeLegend => 'साँप की किंवदंती';

  @override
  String get achDescSnakeLegend => '5,000 गेम खेलें';

  @override
  String get achTitleIronWill => 'फ़ौलादी इरादा';

  @override
  String get achDescIronWill => 'एक ही गेम में 10 मिनट टिके रहें';

  @override
  String get achTitleEternalSnake => 'अमर साँप';

  @override
  String get achDescEternalSnake => 'एक ही गेम में 20 मिनट टिके रहें';

  @override
  String get achTitleTimeLord => 'समय के स्वामी';

  @override
  String get achDescTimeLord => 'एक ही गेम में 30 मिनट टिके रहें';

  @override
  String get achTitleFirstBiteSnack => 'पहला नाश्ता';

  @override
  String get achDescFirstBiteSnack => 'एक गेम में 5 खाने खाएँ';

  @override
  String get achTitleHungrySnake => 'भूखा साँप';

  @override
  String get achDescHungrySnake => 'एक गेम में 20 खाने खाएँ';

  @override
  String get achTitleFamished => 'भूख से बेहाल';

  @override
  String get achDescFamished => 'एक गेम में 50 खाने खाएँ';

  @override
  String get achTitleRavenous => 'अतृप्त भूख';

  @override
  String get achDescRavenous => 'एक गेम में 100 खाने खाएँ';

  @override
  String get achTitleInsatiable => 'कभी न भरने वाला';

  @override
  String get achDescInsatiable => 'एक गेम में 200 खाने खाएँ';

  @override
  String get achTitleBlackHoleStomach => 'ब्लैक होल पेट';

  @override
  String get achDescBlackHoleStomach => 'एक गेम में 500 खाने खाएँ';

  @override
  String get achTitleFoodieApprentice => 'खाने का नौसिखिया';

  @override
  String get achDescFoodieApprentice => 'कुल 100 खाने खाएँ';

  @override
  String get achTitleFoodiePro => 'खाने का उस्ताद';

  @override
  String get achDescFoodiePro => 'कुल 1,000 खाने खाएँ';

  @override
  String get achTitleFoodieMaster => 'खाने का महारथी';

  @override
  String get achDescFoodieMaster => 'कुल 10,000 खाने खाएँ';

  @override
  String get achTitleFoodieGod => 'खाने के देवता';

  @override
  String get achDescFoodieGod => 'कुल 50,000 खाने खाएँ';

  @override
  String get achTitleQuickPlayer => 'फुर्तीला खिलाड़ी';

  @override
  String get achDescQuickPlayer => 'कुल 1 घंटा खेलें';

  @override
  String get achTitleEngagedPlayer => 'जुड़ा हुआ खिलाड़ी';

  @override
  String get achDescEngagedPlayer => 'कुल 10 घंटे खेलें';

  @override
  String get achTitleHardcorePlayer => 'कट्टर खिलाड़ी';

  @override
  String get achDescHardcorePlayer => 'कुल 50 घंटे खेलें';

  @override
  String get achTitleSnakeObsessed => 'साँप का जुनूनी';

  @override
  String get achDescSnakeObsessed => 'कुल 100 घंटे खेलें';

  @override
  String get achTitleTouchGrass => 'थोड़ी हवा खा लो';

  @override
  String get achDescTouchGrass => 'कुल 250 घंटे खेलें — शायद बाहर घूम आएँ?';

  @override
  String get achTitleLevel5 => 'शिष्य';

  @override
  String get achDescLevel5 => 'लेवल 5 तक पहुँचें';

  @override
  String get achTitleLevel10 => 'कारीगर';

  @override
  String get achDescLevel10 => 'लेवल 10 तक पहुँचें';

  @override
  String get achTitleLevel25 => 'विशेषज्ञ';

  @override
  String get achDescLevel25 => 'लेवल 25 तक पहुँचें';

  @override
  String get achTitleLevel50 => 'मास्टर';

  @override
  String get achDescLevel50 => 'लेवल 50 तक पहुँचें';

  @override
  String get achTitleLevel100 => 'ग्रैंडमास्टर';

  @override
  String get achDescLevel100 => 'लेवल 100 तक पहुँचें';

  @override
  String get achTitleClassicInitiate => 'क्लासिक शुरुआती';

  @override
  String get achDescClassicInitiate => 'क्लासिक मोड में 10 गेम पूरे करें';

  @override
  String get achTitleClassicVeteran => 'क्लासिक अनुभवी';

  @override
  String get achDescClassicVeteran => 'क्लासिक मोड में 100 गेम पूरे करें';

  @override
  String get achTitleClassic1000 => 'क्लासिक पारखी';

  @override
  String get achDescClassic1000 => 'क्लासिक मोड में 1,000 अंक बनाएँ';

  @override
  String get achTitleClassic5000 => 'क्लासिक उस्ताद';

  @override
  String get achDescClassic5000 => 'क्लासिक मोड में 5,000 अंक बनाएँ';

  @override
  String get achTitleZenInitiate => 'ज़ेन शुरुआती';

  @override
  String get achDescZenInitiate => '10 ज़ेन गेम पूरे करें';

  @override
  String get achTitleZenGarden => 'ज़ेन उद्यान';

  @override
  String get achDescZenGarden => 'ज़ेन मोड में 500 अंक बनाएँ';

  @override
  String get achTitleZenMaster => 'ज़ेन मास्टर';

  @override
  String get achDescZenMaster => 'ज़ेन मोड में 5,000 अंक बनाएँ';

  @override
  String get achTitleSpeedInitiate => 'रफ़्तार की चाहत';

  @override
  String get achDescSpeedInitiate => '10 स्पीड चैलेंज गेम पूरे करें';

  @override
  String get achTitleSpeedrunner => 'स्पीडरनर';

  @override
  String get achDescSpeedrunner => 'स्पीड चैलेंज में 500 अंक बनाएँ';

  @override
  String get achTitleLightning => 'बिजली';

  @override
  String get achDescLightning => 'स्पीड चैलेंज में 2,000 अंक बनाएँ';

  @override
  String get achTitleMultifoodInitiate => 'खाने की दुनिया';

  @override
  String get achDescMultifoodInitiate => '10 मल्टीफ़ूड गेम पूरे करें';

  @override
  String get achTitleBuffet => 'बुफ़े';

  @override
  String get achDescBuffet => 'मल्टीफ़ूड में 1,000 अंक बनाएँ';

  @override
  String get achTitleSmorgasbord => 'भोज';

  @override
  String get achDescSmorgasbord => 'मल्टीफ़ूड में 5,000 अंक बनाएँ';

  @override
  String get achTitleSurvivalInitiate => 'सर्वाइवल शुरुआती';

  @override
  String get achDescSurvivalInitiate => '10 सर्वाइवल गेम पूरे करें';

  @override
  String get achTitleSurvivalPro => 'सर्वाइवल प्रो';

  @override
  String get achDescSurvivalPro => 'सर्वाइवल मोड में 5 मिनट टिके रहें';

  @override
  String get achTitleLastSnakeStanding => 'आख़िरी साँप';

  @override
  String get achDescLastSnakeStanding => 'सर्वाइवल में 2,500 अंक बनाएँ';

  @override
  String get achTitleTimeattackInitiate => 'टाइम अटैकर';

  @override
  String get achDescTimeattackInitiate => '10 टाइमअटैक गेम पूरे करें';

  @override
  String get achTitleBeatTheClock => 'घड़ी को हराओ';

  @override
  String get achDescBeatTheClock => 'पूरे 3 मिनट का टाइमअटैक झेल जाएँ';

  @override
  String get achTitleTimeattackMaster => 'टाइमअटैक मास्टर';

  @override
  String get achDescTimeattackMaster => 'टाइमअटैक में 3,000 अंक बनाएँ';

  @override
  String get achTitleComboStarter => 'कॉम्बो शुरुआती';

  @override
  String get achDescComboStarter => 'एक ही गेम में 5x कॉम्बो लगाएँ';

  @override
  String get achTitleComboMaster => 'कॉम्बो मास्टर';

  @override
  String get achDescComboMaster => 'एक ही गेम में 10x कॉम्बो लगाएँ';

  @override
  String get achTitleComboPro => 'कॉम्बो प्रो';

  @override
  String get achDescComboPro => 'एक ही गेम में 20x कॉम्बो लगाएँ';

  @override
  String get achTitleComboGod => 'कॉम्बो के देवता';

  @override
  String get achDescComboGod => 'एक ही गेम में 50x कॉम्बो लगाएँ';

  @override
  String get achTitleComboLegend => 'कॉम्बो किंवदंती';

  @override
  String get achDescComboLegend => 'एक ही गेम में 100x कॉम्बो लगाएँ';

  @override
  String get achTitleGrowingSnake => 'बढ़ता साँप';

  @override
  String get achDescGrowingSnake => 'साँप को 20 लंबाई तक बढ़ाएँ';

  @override
  String get achTitleBigSnake => 'बड़ा साँप';

  @override
  String get achDescBigSnake => 'साँप को 50 लंबाई तक बढ़ाएँ';

  @override
  String get achTitleHugeSnake => 'विशाल साँप';

  @override
  String get achDescHugeSnake => 'साँप को 100 लंबाई तक बढ़ाएँ';

  @override
  String get achTitleMassiveSnake => 'महाकाय साँप';

  @override
  String get achDescMassiveSnake => 'साँप को 200 लंबाई तक बढ़ाएँ';

  @override
  String get achTitleAnaconda => 'एनाकोंडा';

  @override
  String get achDescAnaconda => 'साँप को 500 लंबाई तक बढ़ाएँ';

  @override
  String get achTitleFirstPowerUp => 'पावर अप!';

  @override
  String get achDescFirstPowerUp => 'अपना पहला पावर-अप इकट्ठा करें';

  @override
  String get achTitlePowerPlayer => 'पावर खिलाड़ी';

  @override
  String get achDescPowerPlayer => 'कुल 10 पावर-अप इकट्ठा करें';

  @override
  String get achTitlePowerHungry => 'पावर का भूखा';

  @override
  String get achDescPowerHungry => 'कुल 50 पावर-अप इकट्ठा करें';

  @override
  String get achTitlePowerAddict => 'पावर का दीवाना';

  @override
  String get achDescPowerAddict => 'कुल 200 पावर-अप इकट्ठा करें';

  @override
  String get achTitlePowerMaster => 'पावर मास्टर';

  @override
  String get achDescPowerMaster => 'कुल 1,000 पावर-अप इकट्ठा करें';

  @override
  String get achTitleVarietyPack => 'वैरायटी पैक';

  @override
  String get achDescVarietyPack =>
      'चारों तरह के पावर-अप कम से कम एक-एक बार इकट्ठा करें';

  @override
  String get achTitleSpeedDemon => 'रफ़्तार का दानव';

  @override
  String get achDescSpeedDemon => '25 स्पीड बूस्ट पावर-अप इकट्ठा करें';

  @override
  String get achTitleImmortalStreak => 'अमरता की लड़ी';

  @override
  String get achDescImmortalStreak => '25 अजेयता पावर-अप इकट्ठा करें';

  @override
  String get achTitleSpecialDiet => 'ख़ास खुराक';

  @override
  String get achDescSpecialDiet => 'कुल 50 ख़ास खाने खाएँ';

  @override
  String get achTitleBonusHunter => 'बोनस शिकारी';

  @override
  String get achDescBonusHunter => 'कुल 100 बोनस खाने खाएँ';

  @override
  String get achTitleUntouchable5 => 'अछूता';

  @override
  String get achDescUntouchable5 =>
      '5 परफ़ेक्ट गेम पूरे करें (बिना टकराए, 30 सेकंड+)';

  @override
  String get achTitleUntouchable20 => 'बेदाग़';

  @override
  String get achDescUntouchable20 => '20 परफ़ेक्ट गेम पूरे करें';

  @override
  String get achTitleUntouchable50 => 'अछूती किंवदंती';

  @override
  String get achDescUntouchable50 => '50 परफ़ेक्ट गेम पूरे करें';

  @override
  String get achTitleHotStreak => 'जोश की लड़ी';

  @override
  String get achDescHotStreak =>
      'लगातार 5 गेम में 0 से ज़्यादा अंक और 30 सेकंड+ टिकें';

  @override
  String get achTitleOnFire => 'आग लगा दी';

  @override
  String get achDescOnFire => '10 गेम की लड़ी (हर गेम 30 सेकंड+)';

  @override
  String get achTitleUnstoppable => 'अजेय';

  @override
  String get achDescUnstoppable => '25 गेम की लड़ी (हर गेम 30 सेकंड+)';

  @override
  String get achTitleDailyThree => 'रोज़ का खिलाड़ी';

  @override
  String get achDescDailyThree => 'लगातार 3 दिन खेलें';

  @override
  String get achTitleWeekWarrior => 'हफ़्ते का योद्धा';

  @override
  String get achDescWeekWarrior => 'लगातार 7 दिन खेलें';

  @override
  String get achTitleVelocity => 'वेग';

  @override
  String get achDescVelocity => 'एक गेम में इन-गेम लेवल 15 तक पहुँचें';

  @override
  String get achTitleMachSpeed => 'माक स्पीड';

  @override
  String get achDescMachSpeed => 'एक गेम में इन-गेम लेवल 20 तक पहुँचें';

  @override
  String get achTitleCosmicSnake => 'ब्रह्मांडीय साँप';

  @override
  String get achDescCosmicSnake => 'एक गेम में इन-गेम लेवल 25 तक पहुँचें';

  @override
  String get achTitleModeExplorer => 'मोड खोजी';

  @override
  String get achDescModeExplorer => '3 अलग-अलग मोड में कम से कम एक गेम खेलें';

  @override
  String get achTitleAllModePlayer => 'हर मोड का खिलाड़ी';

  @override
  String get achDescAllModePlayer => 'हर मोड में कम से कम एक गेम खेलें (8 मोड)';

  @override
  String get achTitleNightOwl => 'रात का उल्लू';

  @override
  String get achDescNightOwl => 'आधी रात से सुबह 5 बजे के बीच एक गेम पूरा करें';

  @override
  String get achTitleEarlyBird => 'सुबह का पंछी';

  @override
  String get achDescEarlyBird => 'सुबह 5 से 8 बजे के बीच एक गेम पूरा करें';

  @override
  String get achTitleWeekendWarrior => 'वीकेंड योद्धा';

  @override
  String get achDescWeekendWarrior => 'वीकेंड पर 10 गेम पूरे करें';

  @override
  String get ppuMegaSpeedBoost => 'मेगा स्पीड बूस्ट';

  @override
  String get ppuMegaInvincibility => 'मेगा अजेयता';

  @override
  String get ppuMegaScoreMultiplier => 'मेगा स्कोर गुणक';

  @override
  String get ppuMegaSlowMotion => 'मेगा स्लो मोशन';

  @override
  String get ppuTeleport => 'टेलीपोर्ट';

  @override
  String get ppuSizeReducer => 'आकार घटाने वाला';

  @override
  String get ppuScoreShield => 'स्कोर कवच';

  @override
  String get ppuComboMultiplier => 'कॉम्बो गुणक';

  @override
  String get ppuTimeWarp => 'टाइम वार्प';

  @override
  String get ppuMagneticFood => 'चुंबकीय खाना';

  @override
  String get ppuGhostMode => 'भूत मोड';

  @override
  String get ppuDoubleTrouble => 'दोहरी मुसीबत';

  @override
  String get ppuLuckyCharm => 'भाग्यशाली ताबीज़';

  @override
  String get ppuPowerSurge => 'पावर सर्ज';

  @override
  String get bundleMegaPack => 'मेगा पावर पैक';

  @override
  String get bundleMegaPackDesc => 'क्लासिक पावर-अप्स के उन्नत संस्करण';

  @override
  String get bundleTacticalPack => 'टैक्टिकल पावर पैक';

  @override
  String get bundleTacticalPackDesc => 'कुशल खिलाड़ियों के लिए रणनीतिक पावर-अप';

  @override
  String get bundleUltimatePack => 'अल्टीमेट पावर पैक';

  @override
  String get bundleUltimatePackDesc => 'हर प्रीमियम पावर-अप उपलब्ध';

  @override
  String get skinClassic => 'क्लासिक';

  @override
  String get skinGolden => 'सुनहरा साँप';

  @override
  String get skinRainbow => 'इंद्रधनुषी साँप';

  @override
  String get skinGalaxy => 'गैलेक्सी साँप';

  @override
  String get skinDragon => 'ड्रैगन साँप';

  @override
  String get skinElectric => 'बिजली साँप';

  @override
  String get skinFire => 'अग्नि साँप';

  @override
  String get skinIce => 'बर्फ़ीला साँप';

  @override
  String get skinShadow => 'छाया साँप';

  @override
  String get skinNeon => 'नियॉन साँप';

  @override
  String get skinCrystal => 'क्रिस्टल साँप';

  @override
  String get skinCosmic => 'ब्रह्मांडीय साँप';

  @override
  String get skinClassicDesc => 'साँप का मूल रूप';

  @override
  String get skinGoldenDesc => 'हर चाल में चमकता सुनहरा साँप';

  @override
  String get skinRainbowDesc => 'इंद्रधनुष के रंगों में बदलता रंगीन साँप';

  @override
  String get skinGalaxyDesc => 'तारों भरे पैटर्न वाला ब्रह्मांडीय साँप';

  @override
  String get skinDragonDesc => 'रहस्यमयी शक्तियों वाला ड्रैगन-शल्क साँप';

  @override
  String get skinElectricDesc => 'बिजली की ऊर्जा से कड़कता हुआ';

  @override
  String get skinFireDesc => 'आग के पैटर्न से दहकता हुआ';

  @override
  String get skinIceDesc => 'क्रिस्टल प्रभावों वाली जमी हुई सुंदरता';

  @override
  String get skinShadowDesc => 'गहरा और रहस्यमयी छाया साँप';

  @override
  String get skinNeonDesc => 'साइबरपंक नियॉन रोशनी से चमकता';

  @override
  String get skinCrystalDesc =>
      'प्रिज़्मी प्रभावों वाला पारदर्शी क्रिस्टल साँप';

  @override
  String get skinCosmicDesc => 'तारों की धूल से बना साँप';

  @override
  String get trailNone => 'कोई ट्रेल नहीं';

  @override
  String get trailParticle => 'कण ट्रेल';

  @override
  String get trailGlow => 'चमक ट्रेल';

  @override
  String get trailRainbow => 'इंद्रधनुष ट्रेल';

  @override
  String get trailFire => 'अग्नि ट्रेल';

  @override
  String get trailElectric => 'बिजली ट्रेल';

  @override
  String get trailStar => 'तारा ट्रेल';

  @override
  String get trailCosmic => 'ब्रह्मांडीय ट्रेल';

  @override
  String get trailNeon => 'नियॉन ट्रेल';

  @override
  String get trailShadow => 'छाया ट्रेल';

  @override
  String get trailCrystal => 'क्रिस्टल ट्रेल';

  @override
  String get trailDragon => 'ड्रैगन ट्रेल';

  @override
  String get trailNoneDesc => 'बिना किसी ट्रेल का साफ़ साँप';

  @override
  String get trailParticleDesc => 'चमकते कणों की लकीर छोड़ता है';

  @override
  String get trailGlowDesc => 'साँप के पीछे धीरे-धीरे मिटती चमक';

  @override
  String get trailRainbowDesc => 'रंग-बिरंगा इंद्रधनुषी ट्रेल प्रभाव';

  @override
  String get trailFireDesc => 'अंगारों वाली धधकती आग की लकीर';

  @override
  String get trailElectricDesc => 'बिजली के प्रभावों वाला कड़कता ट्रेल';

  @override
  String get trailStarDesc => 'साँप की राह में टिमटिमाते तारे';

  @override
  String get trailCosmicDesc => 'ब्रह्मांडीय धूल और नीहारिका प्रभाव';

  @override
  String get trailNeonDesc => 'साइबरपंक अंदाज़ में चमकीली नियॉन रोशनी';

  @override
  String get trailShadowDesc => 'धुएँदार प्रभावों वाला गहरा छाया ट्रेल';

  @override
  String get trailCrystalDesc => 'धीरे-धीरे मिटते क्रिस्टल के टुकड़े';

  @override
  String get trailDragonDesc => 'रहस्यमयी ड्रैगन की साँस का ट्रेल';

  @override
  String get coinPackSmall => 'स्टार्टर पैक';

  @override
  String get coinPackMedium => 'वैल्यू पैक';

  @override
  String get coinPackLarge => 'प्रीमियम पैक';

  @override
  String get coinPackMega => 'अल्टीमेट पैक';

  @override
  String coinsAmount(Object coins) {
    return '$coins सिक्के';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus बोनस';
  }

  @override
  String get boardSmall => 'छोटा';

  @override
  String get boardClassic => 'क्लासिक';

  @override
  String get boardLarge => 'बड़ा';

  @override
  String get boardHuge => 'विशाल';

  @override
  String get boardEpic => 'महाकाय';

  @override
  String get boardMassive => 'प्रचंड';

  @override
  String get boardUltimate => 'अल्टीमेट';

  @override
  String get boardSmallDesc => 'तेज़ गेम, तंग जगह';

  @override
  String get boardClassicDesc => 'असली स्नेक अनुभव';

  @override
  String get boardLargeDesc => 'बढ़ने के लिए ज़्यादा जगह';

  @override
  String get boardHugeDesc => 'अधिकतम चुनौती और जगह';

  @override
  String get boardEpicDesc => 'उन्नत खिलाड़ियों के लिए बड़ा बोर्ड';

  @override
  String get boardMassiveDesc => 'महाकाव्य गेम्स के लिए विराट बोर्ड';

  @override
  String get boardUltimateDesc => 'सबसे बड़ा संभव बोर्ड';

  @override
  String get crashLabelSkip => 'छोड़ें';

  @override
  String get crashLabelUntilTap => 'टैप होने तक';

  @override
  String get tgmClassic => 'क्लासिक';

  @override
  String get tgmSpeedRun => 'स्पीड रन';

  @override
  String get tgmSurvival => 'सर्वाइवल';

  @override
  String get tgmNoWalls => 'बिना दीवारें';

  @override
  String get tgmPowerUpMadness => 'पावर-अप धमाल';

  @override
  String get tgmPerfectGame => 'परफ़ेक्ट गेम';

  @override
  String get tgmClassicDesc => 'मानक स्नेक गेम नियम';

  @override
  String get tgmSpeedRunDesc => 'गेम की गति तेज़ी से बढ़ती है';

  @override
  String get tgmSurvivalDesc => 'जितना हो सके टिके रहें';

  @override
  String get tgmNoWallsDesc => 'साँप स्क्रीन के किनारों से पार निकल जाता है';

  @override
  String get tgmPowerUpMadnessDesc => 'बार-बार पावर-अप आते हैं';

  @override
  String get tgmPerfectGameDesc => 'कोई ग़लती नहीं - एक टक्कर से गेम ख़त्म';

  @override
  String get ttDaily => 'दैनिक चुनौती';

  @override
  String get ttWeekly => 'साप्ताहिक टूर्नामेंट';

  @override
  String get ttSpecial => 'विशेष इवेंट';

  @override
  String get tsUpcoming => 'आगामी';

  @override
  String get tsActive => 'सक्रिय';

  @override
  String get tsEnded => 'समाप्त';

  @override
  String get cdEasy => 'आसान';

  @override
  String get cdMedium => 'मध्यम';

  @override
  String get cdHard => 'कठिन';

  @override
  String get usOnline => 'ऑनलाइन';

  @override
  String get usOffline => 'ऑफ़लाइन';

  @override
  String get usPlaying => 'खेल रहे हैं';

  @override
  String get bprXpBoost => 'XP बूस्ट';

  @override
  String get bprCoins => 'सिक्के';

  @override
  String get bprTheme => 'थीम';

  @override
  String get bprSkin => 'साँप स्किन';

  @override
  String get bprTrail => 'ट्रेल इफ़ेक्ट';

  @override
  String get bprPowerUp => 'पावर-अप';

  @override
  String get bprTournamentEntry => 'टूर्नामेंट प्रवेश';

  @override
  String get bprTitle => 'खिलाड़ी उपाधि';

  @override
  String get bprAvatar => 'अवतार';

  @override
  String get bprSpecial => 'विशेष इनाम';

  @override
  String get bprFree => 'मुफ़्त';

  @override
  String get bprPremium => 'प्रीमियम';

  @override
  String get bprnStarDust => 'तारों की धूल';

  @override
  String get bprnEnergyPack => 'ऊर्जा पैक';

  @override
  String get bprnBronzeEntry => 'कांस्य प्रवेश';

  @override
  String get bprnSilverEntry => 'रजत प्रवेश';

  @override
  String get bprnStargazer => 'तारों का प्रेमी';

  @override
  String get bprnVoyager => 'यात्री';

  @override
  String get bprnNebulaTheme => 'नीहारिका थीम';

  @override
  String get bprnStardustTrail => 'तारों की धूल ट्रेल';

  @override
  String get bprnLegendaryCrate => 'पौराणिक संदूक';

  @override
  String get bprnMegaXp => 'मेगा XP';

  @override
  String get bprnCosmicCharge => 'ब्रह्मांडीय चार्ज';

  @override
  String get bprnNovaBurst => 'नोवा विस्फोट';

  @override
  String get bprnGalaxySkin => 'गैलेक्सी स्किन';

  @override
  String get bprnCrystalSerpent => 'क्रिस्टल सर्प';

  @override
  String get bprnPlasmaWake => 'प्लाज़्मा लहर';

  @override
  String get bprnCosmicAura => 'ब्रह्मांडीय आभा';

  @override
  String get bprnCyberpunkTheme => 'साइबरपंक थीम';

  @override
  String get bprnCrystalTheme => 'क्रिस्टल थीम';

  @override
  String get bprnSeasonTrophy => 'सीज़न ट्रॉफ़ी';

  @override
  String get bprnCosmicCrown => 'ब्रह्मांडीय मुकुट';

  @override
  String get bprnCosmicLegend => 'ब्रह्मांडीय किंवदंती';

  @override
  String get bprnStarCommander => 'स्टार कमांडर';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity सिक्के';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'मुफ़्त $type इनाम';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'विशेष प्रीमियम $type इनाम';
  }
}
