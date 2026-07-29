// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'JĘZYK';

  @override
  String get languageSystemDefault => 'Domyślny systemowy';

  @override
  String get languageSystemDefaultSubtitle => 'Użyj języka urządzenia';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get mpVictory => 'ZWYCIĘSTWO!';

  @override
  String get mpDraw => 'REMIS';

  @override
  String get mpDefeat => 'PORAŻKA';

  @override
  String get mpYou => 'Ty';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Przeciwnik';

  @override
  String get mpBackToLobby => 'Wróć do poczekalni';

  @override
  String get mpPlayAgain => 'Zagraj ponownie';

  @override
  String get mpTimeUpDraw => 'Koniec czasu — idealny remis!';

  @override
  String get mpTimeUpYouWon => 'Koniec czasu — Twój wynik był wyższy.';

  @override
  String get mpTimeUpYouLost => 'Koniec czasu — przeciwnik miał wyższy wynik.';

  @override
  String get mpMutualCrashDraw => 'Oba węże się rozbiły — remis!';

  @override
  String get mpMutualCrashYouWon =>
      'Oba węże się rozbiły — zdecydował Twój wynik.';

  @override
  String get mpMutualCrashYouLost =>
      'Oba węże się rozbiły — zdecydował wynik przeciwnika.';

  @override
  String get mpMatchCancelled => 'Mecz został anulowany.';

  @override
  String get mpLastSnakeStanding =>
      'Przeciwnik się rozbił. Ostatni wąż na planszy!';

  @override
  String get mpDeathWall => 'Uderzyłeś w ścianę.';

  @override
  String get mpDeathSelf => 'Uderzyłeś w samego siebie.';

  @override
  String get mpDeathOpponent => 'Uderzyłeś w przeciwnika.';

  @override
  String get mpDeathHeadOn => 'Czołowe zderzenie!';

  @override
  String get mpDeathForfeit =>
      'Zbyt długo bez połączenia — mecz oddany walkowerem.';

  @override
  String get mpBetterLuck => 'Powodzenia następnym razem!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count monety',
      many: '+$count monet',
      few: '+$count monety',
      one: '+$count moneta',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Opuścić grę?';

  @override
  String get mpLeaveGameBody =>
      'Mecz trwa dalej na serwerze — wyjście oznacza poddanie.';

  @override
  String get mpLeave => 'Wyjdź';

  @override
  String get mpReconnecting => 'PONOWNE ŁĄCZENIE…';

  @override
  String get mpReconnectingBody => 'Mecz wciąż trwa na serwerze.';

  @override
  String get mpGetReady => 'PRZYGOTUJ SIĘ';

  @override
  String get mpDroppingIntoArena => 'Wrzucamy Cię na arenę…';

  @override
  String get mpWaitingPlayer => 'Oczekiwanie…';

  @override
  String get mpOut => 'ODPADŁ';

  @override
  String get mpLength => 'DŁUGOŚĆ';

  @override
  String get mpSwipe => 'Przesuń';

  @override
  String get mpReconnectingInline => 'łączenie…';

  @override
  String get homePlay => 'GRAJ';

  @override
  String get homeHighScore => 'REKORD';

  @override
  String homeArmedPowerUp(String name) {
    return 'Uzbrojone: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Ekwipunek ($count)';
  }

  @override
  String get puSpeedBoost => 'Przyspieszenie';

  @override
  String get puInvincibility => 'Nieśmiertelność';

  @override
  String get puScoreMultiplier => 'Mnożnik punktów';

  @override
  String get puSlowMotion => 'Spowolnienie';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'SKLEP';

  @override
  String get homeTileFree => 'GRATIS';

  @override
  String get homeTileDaily => 'WYZWANIA';

  @override
  String get homeTileBattle => 'BITWA';

  @override
  String get homeTileEvents => 'TURNIEJE';

  @override
  String get homeTileBoard => 'RANKING';

  @override
  String get homeTileFriends => 'ZNAJOMI';

  @override
  String get homeTileCosmetics => 'STYLE';

  @override
  String get homeTileAwards => 'NAGRODY';

  @override
  String get homeTileVersus => 'POJEDYNEK';

  @override
  String get homeNoAdReady =>
      'Reklama nie jest jeszcze gotowa — spróbuj za kilka sekund.';

  @override
  String get homeFreeSpeedBoostTitle => 'Darmowe przyspieszenie';

  @override
  String get homeFreeSpeedBoostBody =>
      'Obejrzyj krótką reklamę, aby dodać darmowe przyspieszenie do ekwipunku. Aktywuje się 5 sekund po rozpoczęciu następnej gry.';

  @override
  String get homeNotNow => 'Nie teraz';

  @override
  String get homeWatchAd => 'Obejrzyj reklamę';

  @override
  String get homeFreeSpeedBoostAdded =>
      'Darmowe przyspieszenie dodane do ekwipunku!';

  @override
  String get homeAdNotFinished =>
      'Reklama nieukończona — obejrzyj całą, aby odebrać nagrodę.';

  @override
  String get homePickGameMode => 'Wybierz tryb gry';

  @override
  String get homePickGameModeSubtitle =>
      'Możesz to zmienić w ustawieniach w każdej chwili';

  @override
  String get homeStartPlaying => 'ROZPOCZNIJ GRĘ';

  @override
  String get homeLoadoutTitle => 'Ekwipunek wzmocnień';

  @override
  String get homeLoadoutSubtitle =>
      'Załaduj jedno wzmocnienie — aktywuje się 5 sekund po rozpoczęciu następnej gry.';

  @override
  String get homeWatchAdFreeSpeedBoost =>
      'Obejrzyj reklamę — darmowe przyspieszenie';

  @override
  String get homeNoPowerUps =>
      'Nie masz żadnych wzmocnień.\nOdwiedź sklep, aby je kupić!';

  @override
  String homeOwnedCount(int count) {
    return 'Posiadane: $count';
  }

  @override
  String get homeArmed => 'UZBROJONE';

  @override
  String get homeDone => 'GOTOWE';

  @override
  String get settingsTitle => 'USTAWIENIA';

  @override
  String get settingsBackToGame => 'WRÓĆ DO GRY';

  @override
  String get settingsSectionControls => 'STEROWANIE';

  @override
  String get settingsSectionGameplay => 'ROZGRYWKA';

  @override
  String get settingsSectionAudio => 'DŹWIĘK';

  @override
  String get settingsSectionVisual => 'WYGLĄD';

  @override
  String get settingsSectionNotifications => 'POWIADOMIENIA';

  @override
  String get settingsSectionUserProfile => 'PROFIL UŻYTKOWNIKA';

  @override
  String get settingsSectionHelp => 'POMOC I SAMOUCZEK';

  @override
  String get settingsSectionLegal => 'INFORMACJE PRAWNE';

  @override
  String get settingsSectionPremium => 'FUNKCJE PREMIUM';

  @override
  String get settingsDPadControls => 'Sterowanie D-Pad';

  @override
  String get settingsDPadSubtitle =>
      'Pokazuj przyciski kierunkowe na ekranie podczas gry';

  @override
  String get settingsDPadPosition => 'Pozycja D-Pada';

  @override
  String get settingsDesktopControls => 'Sterowanie na komputerze';

  @override
  String get settingsArrowKeys => 'Strzałki';

  @override
  String get settingsWasdKeys => 'Klawisze WASD';

  @override
  String get settingsSpacebar => 'Spacja';

  @override
  String get settingsMouseClick => 'Kliknięcie myszą';

  @override
  String get settingsChangeDirection => 'Zmiana kierunku';

  @override
  String get settingsPauseResume => 'Pauza/wznowienie gry';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Sterowanie dotykowe (jeśli dostępne)';

  @override
  String get settingsTouchControls => 'Sterowanie dotykowe';

  @override
  String get settingsSwipeGestures => 'Gesty przesunięcia';

  @override
  String get settingsTapScreen => 'Dotknięcie ekranu';

  @override
  String get settingsSwipeUp => 'Przesuń w górę ↑';

  @override
  String get settingsSwipeDown => 'Przesuń w dół ↓';

  @override
  String get settingsSwipeLeft => 'Przesuń w lewo ←';

  @override
  String get settingsSwipeRight => 'Przesuń w prawo →';

  @override
  String get settingsMoveSnakeUp => 'Wąż w górę';

  @override
  String get settingsMoveSnakeDown => 'Wąż w dół';

  @override
  String get settingsMoveSnakeLeft => 'Wąż w lewo';

  @override
  String get settingsMoveSnakeRight => 'Wąż w prawo';

  @override
  String get settingsGameMode => 'Tryb gry';

  @override
  String get settingsGameModeLocked => 'Ukończ bieżącą grę, aby zmienić tryb';

  @override
  String get settingsDifficulty => 'Poziom trudności';

  @override
  String get settingsDifficultySubtitle =>
      'Określa początkową prędkość węża. Każdy tryb przyspiesza wraz z poziomami.';

  @override
  String get settingsEasyNote =>
      'Monety, PD i osiągnięcia liczą się także na łatwym — wstrzymane są tylko rekordy i rankingi.';

  @override
  String get settingsDifficultyLocked =>
      'Ukończ bieżącą grę, aby zmienić poziom trudności.';

  @override
  String get settingsCurrentSize => 'Obecny rozmiar';

  @override
  String get settingsBoardSizeLocked =>
      'Ukończ bieżącą grę, aby zmienić rozmiar planszy';

  @override
  String get settingsCurrentDuration => 'Obecny czas';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Jak długo pokazywać wyjaśnienie kolizji';

  @override
  String get settingsScreenShake => 'Wstrząsy ekranu';

  @override
  String get settingsScreenShakeSubtitle =>
      'Wstrząsaj ekranem przy kolizjach i wydarzeniach';

  @override
  String get settingsVibration => 'Wibracje';

  @override
  String get settingsVibrationSubtitle =>
      'Wibruj przy wydarzeniach w grze i naciśnięciach';

  @override
  String get settingsSoundEffects => 'Efekty dźwiękowe';

  @override
  String get settingsBackgroundMusic => 'Muzyka w tle';

  @override
  String get settingsCurrentTheme => 'Obecny motyw';

  @override
  String get settingsBrowseThemes => 'PRZEGLĄDAJ MOTYWY';

  @override
  String get settingsSnakeTrail => 'Efekty śladu węża';

  @override
  String get settingsSnakeTrailSubtitle => 'Włącz ślad cząsteczek za wężem';

  @override
  String get settingsNotifDailyReminder => 'Codzienne przypomnienie';

  @override
  String get settingsNotifTournament => 'Alerty turniejowe';

  @override
  String get settingsNotifAchievement => 'Odblokowane osiągnięcia';

  @override
  String get settingsNotifSocial => 'Aktualności społecznościowe';

  @override
  String get settingsNotifSpecialEvents => 'Wydarzenia specjalne';

  @override
  String get settingsNotSet => 'Nie ustawiono';

  @override
  String get settingsUsername => 'Nazwa użytkownika';

  @override
  String get settingsGuestAccount => 'Konto gościa';

  @override
  String get settingsAuthenticatedAccount => 'Konto uwierzytelnione';

  @override
  String get settingsChangeUsername => 'ZMIEŃ NAZWĘ';

  @override
  String get settingsGuestSignInHint =>
      'Zaloguj się, aby zachować postępy i grać ze znajomymi';

  @override
  String get settingsUsernameVisibleHint =>
      'Twoja nazwa jest widoczna dla znajomych i w rankingach';

  @override
  String get settingsReplayTutorial => 'POWTÓRZ SAMOUCZEK';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Obejrzyj ponownie przewodnik lub samouczek gry';

  @override
  String get settingsAboutCredits => 'O APLIKACJI';

  @override
  String get settingsAboutCreditsSubtitle => 'Wersja aplikacji, twórcy i linki';

  @override
  String get settingsRateApp => 'OCEŃ SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'Podoba ci się gra? Zostaw recenzję w App Store';

  @override
  String get settingsRateAppSubtitle => 'Podoba ci się gra? Zostaw recenzję!';

  @override
  String get settingsAdPrivacy => 'PRYWATNOŚĆ I REKLAMY';

  @override
  String get settingsAdPrivacySubtitle =>
      'Zarządzaj zgodą na spersonalizowane reklamy';

  @override
  String get settingsAdPrivacyUnavailable =>
      'Opcje prywatności reklam są teraz niedostępne.';

  @override
  String get settingsReplayDialogTitle => 'Powtórz samouczek';

  @override
  String get settingsReplayDialogBody => 'Który samouczek chcesz powtórzyć?';

  @override
  String get settingsHomeTour => 'Przewodnik po menu';

  @override
  String get settingsGameTutorial => 'Samouczek gry';

  @override
  String get settingsPrivacyPolicyTitle => 'Polityka prywatności';

  @override
  String get settingsPrivacyPolicyButton => 'POLITYKA PRYWATNOŚCI';

  @override
  String get settingsTermsTitle => 'Warunki użytkowania';

  @override
  String get settingsTermsButton => 'WARUNKI UŻYTKOWANIA';

  @override
  String get settingsChangeUsernameTitle => 'Zmień nazwę użytkownika';

  @override
  String get settingsCurrentLabel => 'Obecna:';

  @override
  String get settingsUsernameDialogBody =>
      'Wybierz unikalną nazwę, która będzie cię reprezentować w grze.';

  @override
  String get settingsEnterNewUsername => 'Wpisz nową nazwę użytkownika';

  @override
  String get settingsUsernameRules =>
      '• 3-20 znaków\n• Musi zaczynać się od litery\n• Tylko litery, cyfry i podkreślenia';

  @override
  String get settingsUsernameUpdateFailed => 'Nie udało się zmienić nazwy';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Nazwa zmieniona na „$name”';
  }

  @override
  String get settingsUpdate => 'Zaktualizuj';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Status premium';

  @override
  String get settingsActiveSubscription => 'Aktywna subskrypcja';

  @override
  String get settingsUnlockPremium => 'Odblokuj funkcje premium';

  @override
  String settingsRenews(String date) {
    return 'Odnawia się $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Przejdź na Pro';

  @override
  String get settingsRestorePurchases => 'Przywróć zakupy';

  @override
  String get settingsPurchaseHistory => 'Historia zakupów';

  @override
  String get settingsSnakeCosmetics => 'Style węża';

  @override
  String get settingsBattlePass => 'Przepustka bojowa';

  @override
  String settingsTier(int tier) {
    return 'Poziom $tier';
  }

  @override
  String get settingsRestoring => 'Przywracanie zakupów...';

  @override
  String get settingsRestored => 'Zakupy przywrócone pomyślnie!';

  @override
  String get settingsRestoreFailed =>
      'Nie udało się przywrócić zakupów. Spróbuj ponownie.';

  @override
  String get settingsNoPurchases => 'Nie znaleziono zakupów';

  @override
  String get settingsUnknown => 'Nieznane';

  @override
  String settingsStatusLine(String status) {
    return 'Status: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'Data: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'Zakup nr $number';
  }

  @override
  String get settingsDataParseError => 'Błąd odczytu danych';

  @override
  String get settingsClose => 'Zamknij';

  @override
  String get settingsHistoryLoadFailed =>
      'Nie udało się wczytać historii zakupów';

  @override
  String get settingsUnknownDate => 'Nieznana data';

  @override
  String get mpLobbyNoFriends =>
      'Nie masz jeszcze znajomych — dodaj ich na ekranie Znajomi!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Zaproś znajomego do pokoju $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 Zaproszenie wysłane do $name!';
  }

  @override
  String get mpLobbyInviteFailed =>
      'Nie udało się wysłać zaproszenia — spróbuj ponownie';

  @override
  String get mpLobbyOffline =>
      'Jesteś offline. Tryb wieloosobowy wymaga internetu.';

  @override
  String get mpLobbyDismiss => 'ZAMKNIJ';

  @override
  String get mpLobbyGo => 'START!';

  @override
  String get mpLobbyGetReady => 'Przygotuj się!';

  @override
  String get mpLobbyTitle => 'TRYB WIELOOSOBOWY';

  @override
  String get mpLobbySubtitle => 'Graj online ze znajomymi';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Pokój: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'Kod pokoju skopiowany!';

  @override
  String get mpLobbyQuickMatch => 'SZYBKI MECZ';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      'Klasyczne 1v1 — przeciwnik znajdzie się automatycznie';

  @override
  String get mpLobbyFinding => 'SZUKANIE...';

  @override
  String get mpLobbyFindMatch => 'ZNAJDŹ MECZ';

  @override
  String get mpLobbySeconds => 'sek';

  @override
  String get mpLobbySearching => 'SZUKANIE GRACZY...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gracza',
      many: '$count graczy',
      few: '$count graczy',
      one: '$count gracz',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Miejsce w kolejce: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'ANULUJ';

  @override
  String get mpLobbyNoPlayersFound => 'NIE ZNALEZIONO GRACZY';

  @override
  String get mpLobbyNoPlayersBody =>
      'Przykro nam, nie znaleźliśmy przeciwników.\nSpróbuj ponownie lub stwórz własny pokój!';

  @override
  String get mpLobbyGoBack => 'WRÓĆ';

  @override
  String get mpLobbyTryAgain => 'SPRÓBUJ PONOWNIE';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count W';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count P';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count R';
  }

  @override
  String get mpLobbyJoinRoom => 'DOŁĄCZ DO POKOJU';

  @override
  String get mpLobbyJoinSubtitle => 'Wpisz kod pokoju, aby dołączyć';

  @override
  String get mpLobbyEnterRoomCode => 'Wpisz kod pokoju';

  @override
  String get mpLobbyCreateRoom => 'STWÓRZ POKÓJ';

  @override
  String get mpLobbyCreateSubtitle => 'Stwórz pokój 1v1 i zaproś znajomego';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'GRACZE ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'TY';

  @override
  String get mpLobbyWaitingForPlayer => 'Oczekiwanie na gracza...';

  @override
  String get mpLobbyStartGame => 'ROZPOCZNIJ GRĘ';

  @override
  String get mpLobbyWaitingForHost => 'Oczekiwanie na start hosta...';

  @override
  String get mpLobbyLeave => 'WYJDŹ';

  @override
  String get mpLobbyReadyDone => 'GOTOWY!';

  @override
  String get mpLobbyReady => 'GOTOWY';

  @override
  String get mpModeClassicDesc => 'Tradycyjna bitwa węży';

  @override
  String get mpModeSpeedDesc => 'Prędkość rośnie z czasem';

  @override
  String get mpModeSurvivalDesc => 'Wygrywa ostatni wąż na planszy';

  @override
  String get mpModePowerUpDesc => 'Wzmocnienia wszędzie!';

  @override
  String get mpStatusWaiting => 'Oczekuje';

  @override
  String get mpStatusReady => 'Gotowy';

  @override
  String get mpStatusPlaying => 'Gra';

  @override
  String get mpStatusCrashed => 'Rozbity';

  @override
  String get mpStatusDisconnected => 'Rozłączony';

  @override
  String get goNoAdAvailable => 'Brak dostępnych reklam, spróbuj za chwilę';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Monety podwojone — +$count monet bonusowych!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'Obejrzyj reklamę, aby podwoić swoje $count monet';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins monet  •  +$xp PD';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'Odebrano $count monet z dziennych wyzwań!';
  }

  @override
  String get goRibbonNewHighScore => 'NOWY REKORD!';

  @override
  String get goRibbonTournamentSubmitted => 'WYNIK TURNIEJU WYSŁANY!';

  @override
  String get goRibbonTournamentFailed =>
      'WYNIK NIE WYSŁANY — SPRAWDŹ POŁĄCZENIE';

  @override
  String get goRibbonTournamentSubmitting => 'WYSYŁANIE WYNIKU TURNIEJU…';

  @override
  String get goVictory => 'ZWYCIĘSTWO!';

  @override
  String get goGameOver => 'KONIEC GRY';

  @override
  String get goFinalScore => 'WYNIK KOŃCOWY';

  @override
  String get goLevel => 'POZIOM';

  @override
  String get goBest => 'REKORD';

  @override
  String get goCoinsEarned => 'Zdobyte monety';

  @override
  String get goDailyRewardsReady => 'DZIENNE NAGRODY GOTOWE';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nagrody',
      many: '$count nagród',
      few: '$count nagrody',
      one: '$count nagroda',
    );
    return '$_temp0  •  +$coins monet  •  +$xp PD';
  }

  @override
  String get goClaimAll => 'ODBIERZ WSZYSTKO';

  @override
  String goXpAmount(Object xp) {
    return '$xp PD';
  }

  @override
  String get goClaim => 'Odbierz';

  @override
  String get goAchievements => 'OSIĄGNIĘCIA';

  @override
  String get goRecentlyUnlocked => 'Ostatnio odblokowane';

  @override
  String get goInProgress => 'W trakcie';

  @override
  String get goPlayAgain => 'ZAGRAJ PONOWNIE';

  @override
  String get goMenu => 'MENU';

  @override
  String get storeTitle => 'Sklep Snake';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Monety';

  @override
  String get storeTabThemes => 'Motywy';

  @override
  String get storeTabSkins => 'Skórki';

  @override
  String get storeTabTrails => 'Ślady';

  @override
  String get storeTabPowerUps => 'Wzmocnienia';

  @override
  String get storeYourCoins => 'Twoje monety Snake';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'BONUS ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Wykup subskrypcję, zanim skończy się darmowe Pro';

  @override
  String get storeChooseYourPlan => 'Wybierz swój plan';

  @override
  String get storeWhatYouGet => 'Co otrzymujesz';

  @override
  String get storeProHeroSubtitle =>
      'Wszystkie motywy, skórki i ślady premium · duże plansze · 2× monety · wzmocnienia premium · wejścia na turnieje · Przepustka bojowa Premium';

  @override
  String get storeMonthly => 'Miesięczny';

  @override
  String get storeYearly => 'Roczny';

  @override
  String get storePerMonth => '/mies.';

  @override
  String get storePerYear => '/rok';

  @override
  String get storeSave17 => 'Oszczędź 17%';

  @override
  String storePlanDisplayName(Object title) {
    return 'plan $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Weryfikacja…';

  @override
  String get storeSubscribe => 'Subskrybuj';

  @override
  String get storeYoureOnFreePro => 'Masz darmowe Pro!';

  @override
  String get storeYourePro => 'Jesteś Pro!';

  @override
  String get storeFreePro => 'Darmowe Pro';

  @override
  String get storeProMonthly => 'Pro Miesięczny';

  @override
  String get storeKeepPro => 'Zachowaj Pro — Subskrybuj';

  @override
  String get storePromoBadge => 'PROMOCJA';

  @override
  String get storeEndingSoon => 'Wkrótce się kończy';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Kończy się za ${days}d ${hours}g';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Kończy się za ${hours}g ${minutes}min';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Kończy się za ${minutes}min';
  }

  @override
  String get storeFeatureExtraLife =>
      'Zawsze darmowe dodatkowe życie — wskrzeszaj się w każdej grze, bez reklam i monet';

  @override
  String get storeFeatureNoAds => 'Brak reklam — graj całkowicie bez reklam';

  @override
  String get storeFeatureThemes => 'Wszystkie 6 motywów premium';

  @override
  String get storeFeatureSkins => 'Wszystkie 11 skórek premium';

  @override
  String get storeFeatureTrails => 'Wszystkie 11 śladów premium';

  @override
  String get storeFeatureBoards => 'Plansze premium (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => 'Zarobki monet 2×';

  @override
  String get storeFeaturePowerUps => '5× wzmocnień premium w każdym cyklu';

  @override
  String get storeFeatureTournaments =>
      'Wejścia na turnieje Brąz + Srebro + Złoto w każdym cyklu';

  @override
  String get storeFeatureBattlePass =>
      'Ścieżka Premium przepustki bojowej w każdym sezonie';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Rozpoczynanie zakupu $name...';
  }

  @override
  String get storeSubNotAvailable =>
      'Subskrypcja niedostępna. Spróbuj później.';

  @override
  String get storePurchaseFailed => 'Zakup nie powiódł się. Spróbuj ponownie.';

  @override
  String get storeBuyCoins => 'Kup monety Snake';

  @override
  String get storeEarnFreeCoins => 'Zdobywaj darmowe monety';

  @override
  String get storeEarnPlay => 'Zagraj grę';

  @override
  String get storeEarnPlayReward => '5 monet za grę';

  @override
  String get storeEarnDaily => 'Codzienne logowanie';

  @override
  String get storeEarnDailyReward => '10-50 monet dziennie';

  @override
  String get storeEarnAchievements => 'Osiągnięcia';

  @override
  String get storeEarnAchievementsReward => '25-100 monet';

  @override
  String get storeEarnTournaments => 'Turnieje';

  @override
  String get storeEarnTournamentsReward => 'Ponad 100 monet';

  @override
  String get storePopularBadge => 'POPULARNE';

  @override
  String storeBuyItem(Object name) {
    return 'Kup $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'Kupić $coins za $price?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'Kup - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'Rozpoczynanie zakupu $name...';
  }

  @override
  String get storeProductNotAvailable =>
      'Produkt niedostępny. Spróbuj później.';

  @override
  String get storeUnlockedWithPro => 'Odblokowane z Pro';

  @override
  String get storeIncludedWithPro => 'W zestawie ze Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned =>
      'Każdy motyw tutaj jest twój dzięki subskrypcji.';

  @override
  String get storeProBannerThemesUpsell =>
      'Wykup Pro, aby odblokować wszystkie motywy — bez osobnych zakupów.';

  @override
  String get storeProBannerSkinsOwned =>
      'Każda skórka tutaj jest twoja dzięki subskrypcji.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Wykup Pro, aby odblokować wszystkie skórki — bez osobnych zakupów.';

  @override
  String get storeProBannerTrailsOwned =>
      'Każdy ślad tutaj jest twój dzięki subskrypcji.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Wykup Pro, aby odblokować wszystkie ślady — bez osobnych zakupów.';

  @override
  String get storePremiumThemes => 'Motywy premium';

  @override
  String get storeFreeThemes => 'Darmowe motywy';

  @override
  String get storeFreeThemesSubtitle => 'Zawsze dostępne — wróć, kiedy chcesz.';

  @override
  String get storeAllThemesBundle => 'Pakiet wszystkich motywów';

  @override
  String get storeAllThemesBundleSubtitle =>
      'Wszystkie 6 motywów premium · oszczędź 33%';

  @override
  String get storePillVerifying => 'WERYFIKACJA';

  @override
  String get storePillOwned => 'POSIADANE';

  @override
  String get storePillFree => 'DARMOWE';

  @override
  String get storePillActive => 'AKTYWNY';

  @override
  String get storePillApply => 'ZASTOSUJ';

  @override
  String get storePillEquipped => 'ZAŁOŻONE';

  @override
  String get storePillEquip => 'ZAŁÓŻ';

  @override
  String get storeThemeDescClassic => 'Oryginalny wygląd';

  @override
  String get storeThemeDescModern => 'Czysty i minimalistyczny';

  @override
  String get storeThemeDescNeon => 'Świecące neonowe noce';

  @override
  String get storeThemeDescRetro => 'Neonowe arcade lat 80.';

  @override
  String get storeThemeDescSpace => 'Kosmiczne pole gwiazd';

  @override
  String get storeThemeDescOcean => 'Głębinowe błękity';

  @override
  String get storeThemeDescCyberpunk => 'Elektryczny cyjan i róż';

  @override
  String get storeThemeDescForest => 'Żywa szmaragdowa dżungla';

  @override
  String get storeThemeDescDesert => 'Kanion i kaktusowy turkus';

  @override
  String get storeThemeDescCrystal => 'Lodowy krystaliczny błękit';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'Odblokować $name za $price?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Weryfikacja zakupu $name…';
  }

  @override
  String get storeThemeNotAvailable => 'Motyw niedostępny. Spróbuj później.';

  @override
  String get storeItemNotAvailable => 'Przedmiot niedostępny. Spróbuj później.';

  @override
  String storeEquippedToast(Object name) {
    return '$name założone';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 Darmowe przyspieszenie dodane do ekwipunku!';

  @override
  String get storeWatchAdTitle => 'Obejrzyj reklamę — darmowe przyspieszenie';

  @override
  String get storeWatchAdReady => 'Dodaje 1 przyspieszenie do ekwipunku';

  @override
  String get storeWatchAdNotReady => 'Brak dostępnych reklam';

  @override
  String get puSpeedBoostDesc => 'Zwiększa prędkość węża na 7 sekund.';

  @override
  String get puInvincibilityDesc =>
      'Przenikaj przez ściany i samego siebie przez 6 sekund.';

  @override
  String get puScoreMultiplierDesc => 'Podwójne punkty przez 10 sekund.';

  @override
  String get puSlowMotionDesc =>
      'Spowalnia grę dla większej precyzji (8 sekund).';

  @override
  String get storePowerUpsInfo =>
      'Kup za monety, potem uzbrój jedno w chipie ekwipunku na ekranie głównym — aktywuje się 5 s po rozpoczęciu następnej gry.';

  @override
  String get storePowerUps => 'Wzmocnienia';

  @override
  String get storePowerUpBundles => 'Pakiety wzmocnień';

  @override
  String get storeBundlesSubtitle =>
      'Odblokuj kilka rodzajów wzmocnień taniej.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'Za mało monet!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'Kupić 1 $name za $cost monet?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Kup - $cost monet';
  }

  @override
  String get storePurchaseFailedRetry =>
      'Zakup nie powiódł się. Spróbuj ponownie.';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name dodane do ekwipunku!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count monet';
  }

  @override
  String get storeBuyUpper => 'KUP';

  @override
  String get storeNeedCoins => 'BRAK MONET';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name odblokowany!';
  }

  @override
  String get modeClassic => 'Klasyczny';

  @override
  String get modeZen => 'Tryb Zen';

  @override
  String get modeSpeedChallenge => 'Wyzwanie prędkości';

  @override
  String get modeMultiFood => 'Multi-jedzenie';

  @override
  String get modeSurvival => 'Przetrwanie';

  @override
  String get modeTimeAttack => 'Na czas';

  @override
  String get modePowerUpMadness => 'Szaleństwo wzmocnień';

  @override
  String get modePerfectGame => 'Perfekcyjna gra';

  @override
  String get modeClassicDesc => 'Klasyczny wąż ze ścianami';

  @override
  String get modeZenDesc => 'Bez ścian - wąż przechodzi przez krawędzie ekranu';

  @override
  String get modeSpeedChallengeDesc =>
      'Prędkość rośnie błyskawicznie — maksymalne wyzwanie';

  @override
  String get modeMultiFoodDesc => 'Kilka porcji jedzenia pojawia się naraz';

  @override
  String get modeSurvivalDesc =>
      'Przetrwaj jak najdłużej z ograniczonymi życiami';

  @override
  String get modeTimeAttackDesc =>
      'Zdobądź jak najwięcej punktów w ograniczonym czasie';

  @override
  String get modePowerUpMadnessDesc =>
      'Wzmocnienia pojawiają się znacznie częściej — zanurz się w chaosie';

  @override
  String get modePerfectGameDesc =>
      'Nigdy nie przecinaj własnego śladu. Jeden krok na odwiedzone pole kończy grę.';

  @override
  String get diffEasy => 'Łatwy';

  @override
  String get diffNormal => 'Normalny';

  @override
  String get diffHard => 'Trudny';

  @override
  String get diffEasyDesc =>
      'Wolniejszy wąż na start. Wyniki nie trafiają do rankingów.';

  @override
  String get diffNormalDesc => 'Oryginalne tempo Snake Classic.';

  @override
  String get diffHardDesc => 'Zaczyna szybko i tylko przyspiesza.';

  @override
  String get themeClassic => 'Klasyczny';

  @override
  String get themeModern => 'Nowoczesny';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeRetro => 'Retro';

  @override
  String get themeSpace => 'Kosmos';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeForest => 'Las';

  @override
  String get themeDesert => 'Pustynia';

  @override
  String get themeCrystal => 'Kryształ';

  @override
  String get dpadLeft => 'Po lewej';

  @override
  String get dpadCenter => 'Na środku';

  @override
  String get dpadRight => 'Po prawej';

  @override
  String get mpModeClassicBattle => 'Klasyczna bitwa';

  @override
  String get mpModeSpeedRun => 'Szybki wyścig';

  @override
  String get mpModeSurvivalMode => 'Tryb przetrwania';

  @override
  String get mpModePowerUpMadnessName => 'Szaleństwo wzmocnień';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonViewAll => 'Zobacz wszystko';

  @override
  String get commonRetry => 'Ponów';

  @override
  String get pfTitle => 'Profil';

  @override
  String get pfSigningOut => 'Wylogowywanie...';

  @override
  String get pfGuestPlayer => 'Gość';

  @override
  String get pfVerifiedAccount => 'Konto zweryfikowane';

  @override
  String get pfStatistics => 'Statystyki';

  @override
  String get pfReplays => 'Powtórki';

  @override
  String get pfAchievements => 'Osiągnięcia';

  @override
  String get pfLoadingStats => 'Wczytywanie statystyk...';

  @override
  String get pfHighScore => 'Rekord';

  @override
  String get pfGamesPlayed => 'Rozegrane gry';

  @override
  String get pfPlayTime => 'Czas gry';

  @override
  String get pfAverageScore => 'Średni wynik';

  @override
  String get pfFoodConsumed => 'Zjedzone jedzenie';

  @override
  String get pfPowerUps => 'Wzmocnienia';

  @override
  String get pfUpgradeTitle => 'Przejdź na konto Google';

  @override
  String get pfUpgradeSubtitle =>
      'Zapisz postępy i synchronizuj między urządzeniami';

  @override
  String get pfBenefitSync => 'Synchronizacja postępów';

  @override
  String get pfBenefitSyncSub => 'między urządzeniami';

  @override
  String get pfBenefitLeaderboards => 'Globalne rankingi';

  @override
  String get pfBenefitLeaderboardsSub => 'rywalizuj z całym światem';

  @override
  String get pfBenefitSocial => 'Znajomi i społeczność';

  @override
  String get pfBenefitSocialSub => 'łącz się z innymi';

  @override
  String get pfSignInGoogle => 'Zaloguj się przez Google';

  @override
  String get pfSignInApple => 'Zaloguj się przez Apple';

  @override
  String get pfNoReplays => 'Brak powtórek. Zagraj kilka gier!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zapisanej powtórki',
      many: '$count zapisanych powtórek',
      few: '$count zapisane powtórki',
      one: '$count zapisana powtórka',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Zarządzanie kontem';

  @override
  String get pfSignOut => 'Wyloguj się';

  @override
  String get pfDeleteAccount => 'Usuń konto';

  @override
  String get pfAppleUpgradeSuccess => 'Konto pomyślnie połączone z Apple! 🎉';

  @override
  String get pfAppleIdInUse =>
      'To Apple ID ma już konto. Wyloguj się i zaloguj przez Apple.';

  @override
  String get pfUpgradeFailed =>
      'Nie udało się zaktualizować konta. Spróbuj ponownie.';

  @override
  String get pfUpgradeError => 'Wystąpił błąd podczas aktualizacji konta.';

  @override
  String get pfGoogleUpgradeSuccess => 'Konto pomyślnie połączone z Google! 🎉';

  @override
  String get pfDeleteAccountTitle => 'Usunąć konto?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'To trwale usunie twoje konto i wszystko z nim związane:\n\n• Rekordy i statystyki\n• Monety i zakupione przedmioty\n• Motywy, skórki, ślady i wzmocnienia\n• Postępy przepustki bojowej i wyzwań\n• Wpisy w rankingach i znajomych\n\nTego nie można cofnąć. Aktywne subskrypcje trzeba anulować osobno w ustawieniach $storeName.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'sklepu z aplikacjami urządzenia';

  @override
  String get pfAccountDeleted => 'Twoje konto zostało trwale usunięte.';

  @override
  String get pfDeleteFailed =>
      'Nie udało się usunąć konta. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get pfDeleteForever => 'Usuń na zawsze';

  @override
  String get pfSignOutBody =>
      'Na pewno chcesz się wylogować?\n\nTwoje postępy zostaną zachowane, jeśli logujesz się przez Google.';

  @override
  String get pfSignedOut => 'Wylogowano pomyślnie 👋';

  @override
  String get stLoading => 'Wczytywanie statystyk...';

  @override
  String get stPerformanceOverview => 'Przegląd wyników';

  @override
  String get stTotalGames => 'Łącznie gier';

  @override
  String get stWinStreak => 'Seria zwycięstw';

  @override
  String get stGameActivity => 'Aktywność w grze';

  @override
  String get stLongestGame => 'Najdłuższa gra';

  @override
  String get stHighestLevel => 'Najwyższy poziom';

  @override
  String get stPerfectGames => 'Perfekcyjne gry';

  @override
  String get stFoodPowerUps => 'Jedzenie i wzmocnienia';

  @override
  String get stPowerUpsUsed => 'Użyte wzmocnienia';

  @override
  String get stFavoriteFood => 'Ulubione jedzenie';

  @override
  String get stFavoritePowerUp => 'Ulubione wzmocnienie';

  @override
  String get stPerformanceTrends => 'Trendy wyników';

  @override
  String get stOverallTrend => 'Ogólny trend';

  @override
  String get stRecentAverage => 'Ostatnia średnia';

  @override
  String get stBestRecent => 'Najlepszy ostatnio';

  @override
  String get stConsistency => 'Regularność';

  @override
  String get stScores => 'Wyniki';

  @override
  String get stTrendLine => 'Linia trendu';

  @override
  String get stPlayPatterns => 'Wzorce gry (ostatnie 7 dni)';

  @override
  String get stWeeklyTime => 'Czas w tygodniu';

  @override
  String get stMostActiveDay => 'Najaktywniejszy dzień';

  @override
  String get stDailyActivity => 'Aktywność dzienna';

  @override
  String get stAchievementProgress => 'Postęp osiągnięć';

  @override
  String get stViewAllAchievements => 'Zobacz wszystkie osiągnięcia →';

  @override
  String get stViewAchievements => 'ZOBACZ OSIĄGNIĘCIA';

  @override
  String get stReplaysUpper => 'POWTÓRKI';

  @override
  String get stResetStatistics => 'RESETUJ STATYSTYKI';

  @override
  String get stResetTitle => 'Zresetować statystyki?';

  @override
  String get stResetBody =>
      'To trwale usunie wszystkie twoje statystyki gry. Tej akcji nie można cofnąć.';

  @override
  String get stReset => 'Resetuj';

  @override
  String get stNA => 'B/D';

  @override
  String get stExcellent => 'Świetnie';

  @override
  String get stGood => 'Dobrze';

  @override
  String get stFair => 'Przeciętnie';

  @override
  String get stPoor => 'Słabo';

  @override
  String get stNoData => 'Brak danych';

  @override
  String get stNone => 'Brak';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gry',
      many: '$count gier',
      few: '$count gry',
      one: '$count gra',
    );
    return 'Postęp (ostatnie $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent ukończono';
  }

  @override
  String get stInsights => 'Analiza wyników';

  @override
  String get stInsightPlayMore =>
      'Zagraj więcej gier, aby otrzymać analizę wyników!';

  @override
  String get stInsightImproving => 'Świetna robota! Twoje wyniki idą w górę.';

  @override
  String get stInsightAboveAverage =>
      'Twoje ostatnie gry są wyraźnie powyżej średniej.';

  @override
  String get stInsightDeclined =>
      'Twoje wyniki ostatnio spadły. Rozważ więcej treningu.';

  @override
  String get stInsightPractice =>
      'Skup się na unikaniu kolizji i planowaniu ruchów.';

  @override
  String get stInsightStable =>
      'Twoje wyniki są stabilne. Rzuć sobie wyzwanie!';

  @override
  String get stInsightPotential =>
      'Masz potencjał na rekordy - popracuj nad regularnością.';

  @override
  String get stInsightSolid => 'Utrzymujesz solidne wyniki w ostatnich grach.';
}
