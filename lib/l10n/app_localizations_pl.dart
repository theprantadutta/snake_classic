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
  String get mpRewardProcessing => 'Przetwarzanie nagród…';

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
  String get accountSwitchTitle => 'Zalogować się na istniejące konto?';

  @override
  String get accountSwitchBody =>
      'Jeśli z tego konta grano już w Snake Classic, zostanie przywrócony jego postęp i to on pozostanie Twój. Monety, wyniki i statystyki z tego urządzenia nie zostaną przeniesione.\n\nAby zachować postęp z tego urządzenia, użyj konta, na którym jeszcze nie grano.';

  @override
  String get accountSwitchConfirm => 'Zaloguj mimo to';

  @override
  String get settingsAuthenticatedAccount => 'Konto uwierzytelnione';

  @override
  String get accountNotBackedUpTitle => 'Brak kopii zapasowej';

  @override
  String get accountNotBackedUpBody =>
      'Te postępy są powiązane z tą instalacją. Zaloguj się, aby odzyskać je po ponownej instalacji lub na nowym telefonie.';

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
  String get legalAutoRenewDisclosureAppStore =>
      'Płatność zostanie pobrana z Twojego konta App Store w chwili potwierdzenia zakupu. Subskrypcja odnawia się automatycznie w tej samej cenie i na ten sam okres, o ile nie zostanie anulowana co najmniej 24 godziny przed końcem bieżącego okresu. Po zakupie możesz nią zarządzać lub anulować ją w dowolnym momencie w ustawieniach konta.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'Płatność zostanie pobrana z Twojego konta Google Play w chwili potwierdzenia zakupu. Subskrypcja odnawia się automatycznie w tej samej cenie i na ten sam okres, o ile nie zostanie anulowana co najmniej 24 godziny przed końcem bieżącego okresu. Po zakupie możesz nią zarządzać lub anulować ją w dowolnym momencie w ustawieniach subskrypcji Google Play.';

  @override
  String get legalTermsEulaLink => 'Warunki użytkowania (EULA)';

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
  String get mpLobbyWinsLabel => 'Wygrane';

  @override
  String get mpLobbyLossesLabel => 'Przegrane';

  @override
  String get mpLobbyDrawsLabel => 'Remisy';

  @override
  String get mpLobbyRatingLabel => 'Ranking';

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

  @override
  String get frTitle => 'Znajomi';

  @override
  String get frBlockedUsers => 'Zablokowani użytkownicy';

  @override
  String get frSearchHint => 'Szukaj po nazwie lub e-mailu...';

  @override
  String get frSearching => 'Szukanie...';

  @override
  String get frSearchTitle => 'Szukaj znajomych';

  @override
  String get frSearchSubtitle =>
      'Wpisz nazwę lub e-mail, aby znaleźć znajomych';

  @override
  String get frNoUsersFound => 'Nie znaleziono użytkowników';

  @override
  String get frNoUsersFoundSub => 'Spróbuj innej nazwy lub e-maila';

  @override
  String get frRequests => 'Zaproszenia';

  @override
  String get frSearch => 'Szukaj';

  @override
  String get frNoCacheYet => 'Brak pamięci podręcznej';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Zaktualizowano $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · odświeżenie nieudane, dotknij, aby ponowić';
  }

  @override
  String get frJustNow => 'przed chwilą';

  @override
  String frSecondsAgo(Object count) {
    return '$count s temu';
  }

  @override
  String frMinutesAgo(Object count) {
    return '$count min temu';
  }

  @override
  String frHoursAgo(Object count) {
    return '$count godz. temu';
  }

  @override
  String frDaysAgo(Object count) {
    return '$count dni temu';
  }

  @override
  String get frLoadingFriends => 'Wczytywanie znajomych...';

  @override
  String get frNoFriendsYet => 'Brak znajomych';

  @override
  String get frNoFriendsSub => 'Wyszukaj graczy i dodaj ich do znajomych!';

  @override
  String get frNoRequests => 'Brak zaproszeń';

  @override
  String get frNoRequestsSub => 'Zaproszenia do znajomych pojawią się tutaj';

  @override
  String get frChallengeMenu => 'Wyzwij na mecz';

  @override
  String get frViewProfile => 'Zobacz profil';

  @override
  String get frRemoveFriend => 'Usuń znajomego';

  @override
  String get frBlockUser => 'Zablokuj użytkownika';

  @override
  String frReceivedHeader(Object count) {
    return 'Otrzymane ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Wysłane ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gry',
      many: '$count gier',
      few: '$count gry',
      one: '$count gra',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'Wysłano $date';
  }

  @override
  String get frPending => 'Oczekuje';

  @override
  String get frCancelRequest => 'Anuluj zaproszenie';

  @override
  String get frReject => 'Odrzuć';

  @override
  String get frAccept => 'Przyjmij';

  @override
  String get frAlreadyFriends => '✓ Znajomi';

  @override
  String get frAddFriend => 'Dodaj';

  @override
  String get frSendRequestFailed =>
      'Nie udało się wysłać zaproszenia — sprawdź połączenie i spróbuj ponownie';

  @override
  String get frAcceptFailed =>
      'Nie udało się przyjąć zaproszenia — sprawdź połączenie i spróbuj ponownie';

  @override
  String get frRejectFailed =>
      'Nie udało się odrzucić zaproszenia — sprawdź połączenie i spróbuj ponownie';

  @override
  String get frCancelFailed =>
      'Nie udało się anulować zaproszenia — sprawdź połączenie i spróbuj ponownie';

  @override
  String get frBlockFailed =>
      'Nie udało się zablokować użytkownika — sprawdź połączenie i spróbuj ponownie';

  @override
  String get frSignInSocial =>
      'Zaloguj się, aby dodawać znajomych i korzystać z funkcji społecznościowych';

  @override
  String get frRequestSent => 'Zaproszenie wysłane!';

  @override
  String get frRequestAccepted => 'Zaproszenie przyjęte!';

  @override
  String get frRequestRejected => 'Zaproszenie odrzucone';

  @override
  String get frRequestCancelled => 'Zaproszenie anulowane';

  @override
  String frChallengeSent(Object name) {
    return '🎮 Wyzwanie wysłane do $name!';
  }

  @override
  String get frChallengeFailed =>
      'Nie udało się wysłać wyzwania — spróbuj ponownie';

  @override
  String frBlocked(Object name) {
    return '$name zablokowany';
  }

  @override
  String frUnblocked(Object name) {
    return '$name odblokowany';
  }

  @override
  String get frUnblockFailed => 'Nie udało się odblokować — spróbuj ponownie';

  @override
  String frRemoved(Object name) {
    return '$name usunięty ze znajomych';
  }

  @override
  String frBlockTitle(Object name) {
    return 'Zablokować $name?';
  }

  @override
  String get frBlockBody =>
      'Ta osoba zostanie usunięta ze znajomych i nie będzie mogła wysyłać ci zaproszeń ani wyzwań. Nie zostanie o tym powiadomiona.';

  @override
  String get frBlock => 'Zablokuj';

  @override
  String get frNoBlocked => 'Nikogo nie zablokowano.';

  @override
  String get frUnblock => 'Odblokuj';

  @override
  String frHighScoreLine(Object score) {
    return 'Rekord: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Łącznie gier: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Poziom: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Status: „$status”';
  }

  @override
  String frRemoveBody(Object name) {
    return 'Usunąć $name z listy znajomych?';
  }

  @override
  String get frRemove => 'Usuń';

  @override
  String get frLeaderboardTitle => 'Ranking znajomych';

  @override
  String get frLeaderboardSubtitle => 'Rywalizuj ze znajomymi';

  @override
  String get frLoadingLeaderboard => 'Wczytywanie rankingu...';

  @override
  String frRankBadge(Object rank) {
    return 'nr $rank';
  }

  @override
  String get frYou => 'TY';

  @override
  String get frLeaderboardEmptySub =>
      'Dodaj znajomych, aby zobaczyć swój prywatny ranking!';

  @override
  String get frAddFriends => 'Dodaj znajomych';

  @override
  String get tnTitle => 'Turnieje';

  @override
  String get tnActive => 'Aktywne';

  @override
  String get tnHistory => 'Historia';

  @override
  String get tnMyStats => 'Moje statystyki';

  @override
  String get tnLoading => 'Wczytywanie turniejów...';

  @override
  String get tnNoActive => 'Brak aktywnych turniejów';

  @override
  String get tnNoActiveSub => 'Wróć później po nowe turnieje!';

  @override
  String get tnNoHistory => 'Brak historii turniejów';

  @override
  String get tnNoHistorySub =>
      'Weź udział w turniejach, aby zobaczyć historię!';

  @override
  String get tnNoStats => 'Brak statystyk turniejowych';

  @override
  String get tnNoStatsSub => 'Dołącz do turniejów, aby śledzić postępy!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max graczy';
  }

  @override
  String get tnJoined => 'Dołączono';

  @override
  String tnBestScoreChip(Object score) {
    return 'Najlepszy: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Miejsce nr $rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dostępne $count nagrody',
      many: 'dostępnych $count nagród',
      few: 'dostępne $count nagrody',
      one: 'dostępna $count nagroda',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'Zobacz szczegóły →';

  @override
  String get tnOverviewCard => 'Przegląd turniejów';

  @override
  String get tnWins => 'Zwycięstwa';

  @override
  String get tnTopThree => 'Miejsca w top 3';

  @override
  String get tnBestScore => 'Najlepszy wynik';

  @override
  String get tnDetailedStats => 'Szczegółowe statystyki';

  @override
  String get tnTotalAttempts => 'Łącznie prób';

  @override
  String get tnWinRate => 'Odsetek zwycięstw';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'Średni wynik';

  @override
  String tnTopPercent(Object percent) {
    return 'Top $percent%';
  }

  @override
  String get tnNotFound => 'Nie znaleziono turnieju';

  @override
  String get tnLoadFailed => 'Nie udało się wczytać turnieju';

  @override
  String get tnLoadingTournament => 'Wczytywanie turnieju...';

  @override
  String get tnGoBack => 'Wróć';

  @override
  String get tnParticipating => 'Bierzesz udział!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Najlepszy: $score • Próby: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Miejsce nr $rank';
  }

  @override
  String get tnOverview => 'Przegląd';

  @override
  String get tnLeaderboard => 'Ranking';

  @override
  String get tnRules => 'Zasady';

  @override
  String get tnLeaderboardFailed => 'Nie udało się wczytać rankingu';

  @override
  String get tnCheckConnection => 'Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get tnNoParticipants => 'Brak uczestników';

  @override
  String get tnBeFirst => 'Dołącz jako pierwszy!';

  @override
  String get tnDescription => 'Opis';

  @override
  String get tnRewards => 'Nagrody';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count próby',
      many: '$count prób',
      few: '$count próby',
      one: '$count próba',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Zasady turnieju';

  @override
  String get tnScoringSystem => 'System punktacji';

  @override
  String get tnScoringBody =>
      'Do końcowej klasyfikacji liczy się twój najwyższy wynik z okresu turnieju. Możesz grać wiele razy, aby go poprawić.';

  @override
  String get tnJoining => 'DOŁĄCZANIE…';

  @override
  String get tnJoin => 'DOŁĄCZ DO TURNIEJU';

  @override
  String get tnPlayNow => 'GRAJ TERAZ';

  @override
  String get tnProUnlimited => 'Pro · Nielimitowane wejścia';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Pozostałe wejścia: $count';
  }

  @override
  String get tnNoEntries => 'Brak wejść — dotknij DOŁĄCZ, aby kupić';

  @override
  String tnStarts(Object time) {
    return 'Start $time';
  }

  @override
  String get tnRule1 => 'Graj w trakcie turnieju, aby twoje wyniki się liczyły';

  @override
  String get tnRule2 =>
      'Możesz grać wiele razy - liczy się tylko najwyższy wynik';

  @override
  String get tnRule3 => 'Do udziału wymagane jest zalogowanie';

  @override
  String get tnRule4 =>
      'Końcowa klasyfikacja ustalana jest po zakończeniu turnieju';

  @override
  String get tnRuleSpeed => 'Prędkość gry szybko rośnie co 10 punktów';

  @override
  String get tnRuleSurvival =>
      'Wynik zależy od czasu przetrwania, nie od jedzenia';

  @override
  String get tnRuleNoWalls =>
      'Wąż przechodzi przez krawędzie ekranu zamiast uderzać w ściany';

  @override
  String get tnRulePowerUps => 'Wzmocnienia pojawiają się co 5 sekund';

  @override
  String get tnRulePerfect => 'Każda kolizja natychmiast kończy grę';

  @override
  String get tnRuleClassic => 'Obowiązują klasyczne zasady węża';

  @override
  String get tnJoinSuccess => 'Dołączono do turnieju!';

  @override
  String get tnJoinFailed => 'Nie udało się dołączyć do turnieju';

  @override
  String get tnJoinError => 'Błąd podczas dołączania do turnieju';

  @override
  String get tnTierBronze => 'Brązowe';

  @override
  String get tnTierSilver => 'Srebrne';

  @override
  String get tnTierGold => 'Złote';

  @override
  String get tnEntryRequired => 'Wymagane wejście';

  @override
  String tnEntryNeeded(Object tier) {
    return 'Potrzebujesz wejścia ($tier), aby dołączyć do tego turnieju.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Obecne wejścia ($tier): $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Subskrybenci Pro mają nielimitowany dostęp do turniejów.';

  @override
  String get tnFreeBronzeAdded => '🎉 Dodano darmowe brązowe wejście!';

  @override
  String get tnFreeEntryAd => 'Darmowe wejście (reklama)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Kup wejście ($tier) - $price';
  }

  @override
  String get acAll => 'Wszystkie';

  @override
  String get acUnlocked => 'Odblokowane';

  @override
  String get acLocked => 'Zablokowane';

  @override
  String get acTotalUpper => 'ŁĄCZNIE';

  @override
  String get acUnlockedUpper => 'ODBLOKOWANE';

  @override
  String get acClaimedUpper => 'ODEBRANE';

  @override
  String get acPendingUpper => 'OCZEKUJĄCE';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% ukończono';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% odblokowanych';
  }

  @override
  String get acEmpty => 'Brak osiągnięć tutaj';

  @override
  String acXpReward(Object xp) {
    return '+$xp PD';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Odblokowano $date';
  }

  @override
  String get rpTitle => 'Powtórki gier';

  @override
  String get rpRecent => 'Ostatnie';

  @override
  String get rpBest => 'Najlepsze';

  @override
  String get rpCrashes => 'Kolizje';

  @override
  String get rpLoading => 'Wczytywanie powtórek...';

  @override
  String get rpNoRecent => 'Brak ostatnich powtórek';

  @override
  String get rpNoBest => 'Brak powtórek z rekordami';

  @override
  String get rpNoCrashes => 'Brak powtórek kolizji';

  @override
  String get rpEmptySub => 'Zagraj kilka gier, aby powstały powtórki!';

  @override
  String get rpScore => 'Wynik';

  @override
  String get rpDuration => 'Czas';

  @override
  String get rpFood => 'Jedzenie';

  @override
  String get rpFrames => 'Klatki';

  @override
  String get rpMaxLength => 'Maks. długość';

  @override
  String get rpWatch => 'Obejrzyj';

  @override
  String get rpYesterday => 'Wczoraj';

  @override
  String get rpDeleteTitle => 'Usunąć powtórkę';

  @override
  String rpDeleteBody(Object date) {
    return 'Usunąć powtórkę z $date?';
  }

  @override
  String get rpDelete => 'Usuń';

  @override
  String get rpDeleted => 'Powtórka usunięta';

  @override
  String get rpDeleteFailed => 'Nie udało się usunąć powtórki';

  @override
  String get lbTitle => 'Rankingi';

  @override
  String get lbGlobal => 'Globalny';

  @override
  String get lbWeekly => 'Tygodniowy';

  @override
  String get lbWeeklySub =>
      'Według najlepszego wyniku w tym tygodniu (reset w niedzielę)';

  @override
  String get lbGlobalSub => 'Według najwyższego wyniku w historii';

  @override
  String lbScoreLine(Object score) {
    return 'Wynik: $score';
  }

  @override
  String get lbLoadingGlobal => 'Wczytywanie rankingu globalnego...';

  @override
  String get lbLoadingWeekly => 'Wczytywanie rankingu tygodniowego...';

  @override
  String get lbNoScores => 'Brak wyników';

  @override
  String get lbBeFirst => 'Ustanów pierwszy rekord!';

  @override
  String get lbNoWeekly => 'Brak wyników w tym tygodniu';

  @override
  String get lbPlayThisWeek => 'Zagraj w tym tygodniu, aby się tu pojawić!';

  @override
  String get lbAnonymous => 'Anonim';

  @override
  String get lbGuestBadge => 'GOŚĆ';

  @override
  String get lbPts => 'pkt';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rozegranej $count gry',
      many: 'rozegranych $count gier',
      few: 'rozegrane $count gry',
      one: 'rozegrana $count gra',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return 'Odebrano: $name!';
  }

  @override
  String get bpTitle => 'Przepustka bojowa';

  @override
  String get bpTitleUpper => 'PRZEPUSTKA BOJOWA';

  @override
  String get bpLoading => 'Wczytywanie przepustki bojowej...';

  @override
  String get bpWatchAdXp => 'Obejrzyj reklamę — +50 PD przepustki';

  @override
  String get bpXpEarned => '+50 PD przepustki bojowej!';

  @override
  String get bpSeasonEnded => 'Sezon zakończony';

  @override
  String bpHoursLeft(Object hours) {
    return 'pozostało $hours godz.';
  }

  @override
  String bpDaysLeft(Object days) {
    return 'pozostało $days dni';
  }

  @override
  String get bpTierUpper => 'POZIOM';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'Sezon ukończony';

  @override
  String get bpSeasonCompleteUpper => 'SEZON UKOŃCZONY';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next PD do poziomu $tier';
  }

  @override
  String get bpPremiumBadge => 'PREMIUM';

  @override
  String get bpSeasonCosmicSerpent => 'Sezon Kosmicznego Węża';

  @override
  String get bpUnlockedEverything => 'Odblokowano każdy poziom tego sezonu.';

  @override
  String get bpComingNext => 'NASTĘPNE';

  @override
  String bpTierN(Object tier) {
    return 'Poziom $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'za $count poziomu',
      many: 'za $count poziomów',
      few: 'za $count poziomy',
      one: 'za $count poziom',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'ODBLOKUJ Z PRO';

  @override
  String get bpAvailableNow => 'DOSTĘPNE TERAZ';

  @override
  String bpTierAbbrev(Object tier) {
    return 'P$tier';
  }

  @override
  String get bpClaim => 'ODBIERZ';

  @override
  String get bpPremiumWaiting => 'Nagrody premium czekają';

  @override
  String get bpSubscribeToClaim => 'Wykup Pro, aby je odebrać.';

  @override
  String get bpHideTiers => 'Ukryj poziomy';

  @override
  String bpViewAllTiers(Object count) {
    return 'Zobacz wszystkie $count poziomów';
  }

  @override
  String get bpCollapse => 'ZWIŃ';

  @override
  String get bpExpand => 'ROZWIŃ';

  @override
  String get bpNow => 'TERAZ';

  @override
  String bpTierUpperN(Object tier) {
    return 'POZIOM $tier';
  }

  @override
  String get bpUnlocked => 'Odblokowane';

  @override
  String bpReachTier(Object tier) {
    return 'Osiągnij poziom $tier, aby odblokować';
  }

  @override
  String get bpBetweenSeasons => 'Między sezonami';

  @override
  String get bpNoSeasonBody =>
      'Żadna przepustka bojowa nie trwa — następny sezon rozpocznie się automatycznie. Zajrzyj wkrótce.';

  @override
  String get bpCheckNewSeason => 'Sprawdź nowy sezon';

  @override
  String get pbActive => 'Premium aktywne!';

  @override
  String get pbActiveSub => 'Masz dostęp do wszystkich funkcji premium';

  @override
  String get pbHeaderSub => 'Odblokuj wszystko, co oferuje gra';

  @override
  String get pbMonthlyPlan => 'Plan miesięczny';

  @override
  String get pbYearlyPlan => 'Plan roczny';

  @override
  String get pbSave33 => 'Oszczędź 33%';

  @override
  String get pbMostPopular => 'NAJPOPULARNIEJSZY';

  @override
  String get pbFeatExtraLife => 'Zawsze darmowe dodatkowe życie';

  @override
  String get pbFeatExtraLifeDesc =>
      'Rozbij się i graj dalej — członkowie Pro odradzają się natychmiast za darmo, bez reklamy i monet, raz na grę';

  @override
  String get pbFeatNoAds => 'Usuń wszystkie reklamy';

  @override
  String get pbFeatNoAdsDesc =>
      'Bez banerów i przerywników — graj zupełnie bez reklam, na zawsze';

  @override
  String get pbFeatThemes => 'Wszystkie motywy premium';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'Wszystkie skórki premium';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice i 5 innych';

  @override
  String get pbFeatTrails => 'Wszystkie ślady premium';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal i 5 innych';

  @override
  String get pbFeatBoards => 'Duże plansze';

  @override
  String get pbFeatBoardsDesc => 'Graj na planszach 35x35, 40x40 i 50x50';

  @override
  String get pbFeatCoins => 'Nagrody monet 2x';

  @override
  String get pbFeatCoinsDesc => 'Podwójne monety Snake z każdej gry';

  @override
  String get pbFeatLucky => 'Szczęściarz — więcej specjalnego jedzenia';

  @override
  String get pbFeatLuckyDesc =>
      '+50% szansy na rzadkie jedzenie specjalne za 50 punktów w każdej grze';

  @override
  String get pbFeatPowerUps => 'Więcej wzmocnień w grze';

  @override
  String get pbFeatPowerUpsDesc =>
      '+30% częstości pojawiania się wzmocnień na planszy';

  @override
  String get pbFeatBundle => 'Pakiet wzmocnień premium';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield i Mega Invincibility w każdym cyklu rozliczeniowym';

  @override
  String get pbFeatTournament => 'Wejścia na turnieje';

  @override
  String get pbFeatTournamentDesc =>
      '1× brązowe + 1× srebrne + 1× złote wejście w każdym cyklu rozliczeniowym';

  @override
  String get pbIncludes => 'Premium obejmuje:';

  @override
  String get pbProPerk => 'BONUS PRO';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'Subskrybuj — $price$period';
  }

  @override
  String get pbReassurance =>
      'Bez zobowiązań • Anuluj w każdej chwili • Bezpieczna płatność';

  @override
  String get pbNotAvailable => 'Subskrypcja premium niedostępna';

  @override
  String get eaTitleLink => 'Zapisz swoje postępy';

  @override
  String get eaTitleSignIn => 'Logowanie e-mailem';

  @override
  String get eaExplainer =>
      'Dodaj e-mail i hasło do konta, aby kupować, przywracać po reinstalacji i logować się z dowolnego urządzenia.';

  @override
  String get eaLinkExisting => 'Połącz istniejące';

  @override
  String get eaSignIn => 'Zaloguj się';

  @override
  String get eaCreateAccount => 'Utwórz konto';

  @override
  String get eaForgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get eaLinkToExisting => 'Połącz z istniejącym kontem';

  @override
  String get eaMinChars => 'Co najmniej 8 znaków';

  @override
  String eaMinCharsN(Object count) {
    return 'Co najmniej $count znaków';
  }

  @override
  String get eaCreateAndLink => 'Utwórz i połącz konto';

  @override
  String get eaEmail => 'E-mail';

  @override
  String get eaEmailRequired => 'E-mail jest wymagany';

  @override
  String get eaEmailInvalid => 'Wpisz poprawny e-mail';

  @override
  String get eaPassword => 'Hasło';

  @override
  String get eaPasswordRequired => 'Hasło jest wymagane';

  @override
  String get eaForgotFirst =>
      'Najpierw wpisz e-mail powyżej, potem dotknij Nie pamiętasz hasła.';

  @override
  String eaResetSent(Object email) {
    return 'Wysłano e-mail resetujący hasło na $email.';
  }

  @override
  String get eaErrInvalidEmail => 'Ten adres e-mail jest nieprawidłowy.';

  @override
  String get eaErrDisabled => 'To konto zostało wyłączone.';

  @override
  String get eaErrNoAccount => 'Nie znaleziono konta z tym e-mailem.';

  @override
  String get eaErrWrongCreds => 'Błędny e-mail lub hasło.';

  @override
  String get eaErrEmailInUse =>
      'Konto z tym e-mailem już istnieje. Spróbuj się zalogować.';

  @override
  String get eaErrWeakPassword =>
      'Hasło jest za słabe. Użyj co najmniej 8 znaków.';

  @override
  String get eaErrNotEnabled =>
      'Logowanie e-mail/hasło jest wyłączone. Skontaktuj się z pomocą.';

  @override
  String get eaErrTooMany =>
      'Za dużo prób. Poczekaj kilka minut i spróbuj ponownie.';

  @override
  String get eaErrNetwork => 'Błąd sieci. Sprawdź połączenie.';

  @override
  String get eaErrAlreadyLinked =>
      'To konto jest już połączone z e-mailem/hasłem.';

  @override
  String get eaErrRecentLogin =>
      'Ze względów bezpieczeństwa zaloguj się ponownie przed połączeniem.';

  @override
  String get eaErrGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get faWelcome => 'Witaj w\nSnake Classic!';

  @override
  String get faChooseHow => 'Wybierz, jak chcesz grać:';

  @override
  String get faSigningIn => 'Logowanie...';

  @override
  String get faSignInEmail => 'Zaloguj się e-mailem';

  @override
  String get faContinueGuest => 'Kontynuuj jako gość';

  @override
  String get faGuestNote =>
      'Goście mogą grać i zapisywać postępy lokalnie, ale nie mogą kupować. Zaloguj się przez Apple, Google lub e-mail, gdy zechcesz subskrybować lub kupować.';

  @override
  String get faPrivacyTerms => 'Prywatność i warunki';

  @override
  String get faReviewNote =>
      'Przed kontynuacją zapoznaj się z Polityką prywatności i Warunkami użytkowania';

  @override
  String get faAgreeCheckbox =>
      'Przeczytałem(-am) i akceptuję Politykę prywatności oraz Warunki użytkowania';

  @override
  String get faContinueToSignIn => 'Przejdź do logowania';

  @override
  String get faHeadsUp => 'Uwaga';

  @override
  String get faGuestBullet1 =>
      'Dane gościa są automatycznie usuwane z naszych serwerów po 90 dniach nieaktywności.';

  @override
  String get faGuestBullet2 =>
      'Aby trwale zapisać postępy i grać na wielu urządzeniach, zaloguj się przez Apple, Google lub e-mail.';

  @override
  String get faGuestBullet3 =>
      'Konta gości nie mogą kupować produktów ani subskrypcji. Zaloguj się, jeśli chcesz przejść na Pro lub kupić kosmetyki.';

  @override
  String get faChangedMind => 'Zmieniłem(-am) zdanie';

  @override
  String get faProceedAnyway => 'Mimo to kontynuuj';

  @override
  String get faAppleFailed =>
      'Nie udało się zalogować przez Apple. Spróbuj ponownie.';

  @override
  String get faGoogleFailed =>
      'Nie udało się zalogować przez Google. Spróbuj ponownie.';

  @override
  String get faUnexpected => 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';

  @override
  String get faGuestFailed =>
      'Nie udało się kontynuować jako gość. Spróbuj ponownie.';

  @override
  String get ldInitializing => 'Uruchamianie Snake Classic...';

  @override
  String get ldTip1 =>
      'Planuj dwa ruchy do przodu — ogon podąża tam, gdzie właśnie była głowa.';

  @override
  String get ldTip2 =>
      'Jedzenie bonusowe daje więcej punktów, ale szybko znika. Łap je od razu!';

  @override
  String get ldTip3 =>
      'Rozbiłeś się? Obejrzyj krótką reklamę lub wydaj monety, aby ożyć i zachować wynik.';

  @override
  String get ldTip4 => 'Jedz bez przerw, aby budować mnożnik combo.';

  @override
  String get ldTip5 =>
      'Utknąłeś w ciasnym miejscu? Trzymaj się ścian, aby zyskać chwilę.';

  @override
  String get ldTip6 =>
      'Dzienne wyzwania i tygodniowe misje szybko zbierają monety.';

  @override
  String get ldTip7 =>
      'Snake Classic Pro odblokowuje większe plansze i usuwa wszystkie reklamy.';

  @override
  String get ldTip8 =>
      'Tryb na czas nagradza szybkość — a za reklamę dostaniesz +30 sekund.';

  @override
  String get ldTip9 =>
      'Wzmocnienia się sumują: uzbrój tarczę przed ciasnym przejściem.';

  @override
  String get ldTip10 =>
      'Zmieniaj motywy, skórki i ślady w sklepie, kiedy chcesz.';

  @override
  String get ldStepCore => 'Uruchamianie głównych systemów...';

  @override
  String get ldStepCoreSub => 'Konfigurowanie połączenia z serwerem';

  @override
  String get ldStepProfile => 'Tworzenie profilu gracza...';

  @override
  String get ldStepProfileSub => 'Generowanie unikalnej nazwy';

  @override
  String get ldStepPrefs => 'Wczytywanie preferencji...';

  @override
  String get ldStepPrefsSub => 'Synchronizacja motywów i ustawień';

  @override
  String get ldStepCloud => 'Synchronizacja z chmurą...';

  @override
  String get ldStepCloudSub => 'Sprawdzanie aktualności danych';

  @override
  String get ldStepGameData => 'Wczytywanie danych gry...';

  @override
  String get ldStepGameDataSub => 'Pobieranie danych gry';

  @override
  String get ldStepAudio => 'Konfigurowanie systemu audio...';

  @override
  String get ldStepAudioSub => 'Wczytywanie efektów dźwiękowych';

  @override
  String get ldStepSetup => 'Sprawdzanie stanu konfiguracji...';

  @override
  String get ldStepSetupSub => 'Prawie gotowe!';

  @override
  String get ldWelcome => 'Witaj!';

  @override
  String get ldWelcomeSub => 'Wybierz, jak kontynuować';

  @override
  String get ldReady => 'Gotowe do gry!';

  @override
  String get ldReadySub => 'Witaj z powrotem w Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Błąd uruchamiania: $error';
  }

  @override
  String get ldRetrying => 'Ponowne uruchamianie...';

  @override
  String get ldTagline => 'WĄŻ W WERSJI PREMIUM';

  @override
  String get ldLoadingUpper => 'WCZYTYWANIE';

  @override
  String get ldDidYouKnow => 'CZY WIESZ, ŻE...?';

  @override
  String get ldGameFeatures => 'CECHY GRY';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Płynna rozgrywka';

  @override
  String get ldFeatEffects => 'EFEKTY';

  @override
  String get ldFeatEffectsSub => 'Wizualne cząsteczki';

  @override
  String get ldFeatLevels => 'POZIOMY';

  @override
  String get ldFeatLevelsSub => 'Rosnąca frajda';

  @override
  String get ldFeatAudio => 'DŹWIĘK';

  @override
  String get ldFeatAudioSub => 'Wciągające audio';

  @override
  String get ldFeatScores => 'WYNIKI';

  @override
  String get ldFeatScoresSub => 'Globalne rankingi';

  @override
  String get ldFeatThemes => 'MOTYWY';

  @override
  String get ldFeatThemesSub => 'Wiele stylów';

  @override
  String get ldDevelopedBy => 'TWORZONE I UTRZYMYWANE PRZEZ';

  @override
  String get ldDevTagline => 'Tworzymy mobilne doświadczenia premium';

  @override
  String get ldInitFailedUpper => 'BŁĄD URUCHAMIANIA';

  @override
  String get ldRetryUpper => 'PONÓW';

  @override
  String get pgArena => 'Przygotowywanie areny...';

  @override
  String get pgControls => 'Kalibrowanie sterowania...';

  @override
  String get pgSnake => 'Przyzywanie węża...';

  @override
  String get pgFood => 'Rozmieszczanie jedzenia...';

  @override
  String get pgPowerUps => 'Ładowanie wzmocnień...';

  @override
  String get pgAlmost => 'Prawie gotowe...';

  @override
  String get pgGo => 'Start!';

  @override
  String get pgTip1 => 'Trzymaj kierunek dłużej, aby budować mnożniki combo.';

  @override
  String get pgTip2 =>
      'Jedzenie bonusowe daje więcej punktów, ale szybko znika.';

  @override
  String get pgTip3 =>
      'Wzmocnienia pojawiają się losowo — łap je, póki możesz.';

  @override
  String get pgTip4 => 'Planuj dwa ruchy do przodu, nie tylko jeden.';

  @override
  String get pgTip5 =>
      'Długie węże skręcają wolniej. Ostre zakręty zostaw na początek.';

  @override
  String get pgTip6 =>
      'Mnożnik punktów łączy się z combo — wyniki rosną lawinowo.';

  @override
  String get pgTip7 =>
      'Jedzenie specjalne jest rzadkie — gdy się pojawi, bierz je najpierw.';

  @override
  String get pgTip8 => 'Tryb na czas szybko przyspiesza. Wyważ swoje zakręty.';

  @override
  String get pgTip9 =>
      'W trybie Zen ściany przepuszczają. Uciekaj tak z pułapek.';

  @override
  String get pgTip10 =>
      'Perfekcyjna gra: nie wracaj na pole, którego dotknęło twoje ciało.';

  @override
  String get pgTip11 =>
      'D-Pad daje precyzyjne skręty; przesuwanie jest szybsze.';

  @override
  String get pgTip12 =>
      'Pauzuj z HUD w każdej chwili — licznik na ciebie poczeka.';

  @override
  String get pgPreparing => 'PRZYGOTOWYWANIE ARENY';

  @override
  String get pgTournamentMode => 'TRYB TURNIEJOWY';

  @override
  String get pgGameMode => 'TRYB GRY';

  @override
  String get pgDPadControls => 'Sterowanie D-Pad';

  @override
  String get pgSwipeControls => 'Sterowanie przesuwaniem';

  @override
  String get pgLevel => 'POZIOM';

  @override
  String get pgBest => 'REKORD';

  @override
  String get pgGames => 'GRY';

  @override
  String get pgProTip => 'PORADA PRO';

  @override
  String get pgTapToStart => 'DOTKNIJ GDZIEKOLWIEK, ABY ZACZĄĆ';

  @override
  String get wtWelcomeTitle => 'Witaj w grze!';

  @override
  String get wtWelcomeMsg =>
      'Nauczmy się grać w Snake Classic. Ten krótki samouczek pokaże podstawy.';

  @override
  String get wtHudTitle => 'Informacje o grze';

  @override
  String get wtHudMsg =>
      'Górny pasek pokazuje wynik, poziom i rekord. Śledź swoje postępy w trakcie gry!';

  @override
  String get wtControlsTitle => 'Przesuń, aby się ruszać';

  @override
  String get wtControlsMsg =>
      'Przesuń w dowolnym kierunku, aby zmienić kurs węża. Wąż skręci za twoim gestem.';

  @override
  String get wtPracticeRightTitle => 'Spróbuj! Przesuń w PRAWO';

  @override
  String get wtPracticeRightMsg =>
      'Przesuń w PRAWO po ekranie, aby kontynuować.';

  @override
  String get wtPracticeUpTitle => 'Świetnie! Teraz przesuń w GÓRĘ';

  @override
  String get wtPracticeUpMsg => 'Przesuń w GÓRĘ po ekranie, aby kontynuować.';

  @override
  String get wtFoodTitle => 'Jedz, aby rosnąć';

  @override
  String get wtFoodMsg =>
      'Prowadź węża do jedzenia na planszy. Każdy kęs wydłuża węża!';

  @override
  String get wtComboTitle => 'Buduj combo';

  @override
  String get wtComboMsg =>
      'Jedz bez umierania, aby budować combo. Przy 5 kęsach masz 1,5×, przy 10 masz 2×, przy 20 masz 3×. Ognisty chip przy wyniku rozgrzewa się i pulsuje, gdy rośniesz.';

  @override
  String get wtPowerUpsTitle => 'Wzmocnienia';

  @override
  String get wtPowerUpsMsg =>
      'Czasem pojawiają się błyszczące ikony — zjedz jedną, aby ją aktywować. Pierścień wokół ikony opróżnia się wraz z końcem efektu, a licznik zamarza podczas pauzy.';

  @override
  String get wtWallsTitle => 'Unikaj ścian!';

  @override
  String get wtWallsMsg =>
      'Nie dotykaj krawędzi planszy - zderzenie ze ścianą to koniec gry!';

  @override
  String get wtSelfTitle => 'Nie uderz w siebie!';

  @override
  String get wtSelfMsg =>
      'Gdy wąż rośnie, uważaj, by nie zderzyć się z własnym ciałem!';

  @override
  String get wtPauseTitle => 'Pauza w każdej chwili';

  @override
  String get wtPauseMsg =>
      'Dotknij ikony pauzy, aby zamrozić grę. Stamtąd możesz wznowić, zacząć od nowa, otworzyć Przewodnik, powtórzyć ten samouczek lub przełączyć D-Pad.';

  @override
  String get wtReadyTitle => 'Jesteś gotowy!';

  @override
  String get wtReadyMsg =>
      'Powodzenia! Otwieraj Przewodnik z menu pauzy, aby czytać o combo, wzmocnieniach, trybach i wskazówkach po kolizjach. Zaglądaj do Profilu, aby widzieć odblokowywane osiągnięcia.';

  @override
  String get wtStartPlaying => 'Zacznij grać!';

  @override
  String get wtSkipTutorial => 'Pomiń samouczek';

  @override
  String get wtSwipeRightUpper => 'PRZESUŃ W PRAWO';

  @override
  String get wtSwipeLeftUpper => 'PRZESUŃ W LEWO';

  @override
  String get wtSwipeUpUpper => 'PRZESUŃ W GÓRĘ';

  @override
  String get wtSwipeDownUpper => 'PRZESUŃ W DÓŁ';

  @override
  String get wtSwipeAnywhereScreen => 'Przesuń gdziekolwiek na ekranie!';

  @override
  String get wtSwipeAnywhere => 'Przesuń gdziekolwiek!';

  @override
  String get wtGotIt => 'Rozumiem!';

  @override
  String get wtNext => 'Dalej';

  @override
  String get wtSkip => 'Pomiń';

  @override
  String get wtWaiting => 'Oczekiwanie...';

  @override
  String get hwPlayTitle => 'Witaj w Snake Classic!';

  @override
  String get hwPlayMsg =>
      'Dotknij przycisku GRAJ, aby zacząć. Przesuwaj, aby sterować wężem, i jedz, aby rosnąć!';

  @override
  String get hwCoinsTitle => 'Twoje monety';

  @override
  String get hwCoinsMsg =>
      'Zdobywaj monety grając, wykonując wyzwania i odbierając dzienne bonusy. Wydawaj je w sklepie!';

  @override
  String get hwDailyTitle => 'Dzienne wyzwania';

  @override
  String get hwDailyMsg =>
      'Wykonuj dzienne wyzwania po bonusowe monety i nagrody. Codziennie nowe wyzwania!';

  @override
  String get hwStoreTitle => 'Sklep';

  @override
  String get hwStoreMsg =>
      'Kupuj motywy, skórki, ślady i wzmocnienia za monety. Odblokuj Pro dla plansz premium i wyjątkowych kosmetyków.';

  @override
  String get hwCosmeticsTitle => 'Skórki i ślady';

  @override
  String get hwCosmeticsMsg =>
      'Tutaj personalizujesz węża. Skórki zmieniają jego wygląd; ślady zostawiają za nim poświatę. Zdobywaj za monety lub odblokuj z Pro.';

  @override
  String get hwProfileTitle => 'Twój profil';

  @override
  String get hwProfileMsg =>
      'Tu mieszkają statystyki, osiągnięcia i rekordy. Osiągnięcia odblokowują się wraz z kamieniami milowymi — niektóre wymagają konkretnego trybu (Klasyczny, Trudny itd.). Zaloguj się, aby synchronizować między urządzeniami.';

  @override
  String get hwSettingsTitle => 'Ustawienia';

  @override
  String get hwSettingsMsg =>
      'Dostosuj grę do siebie - zmieniaj motywy, sterowanie, dźwięk i więcej!';

  @override
  String get hudScoreUpper => 'WYNIK';

  @override
  String hudScoreSemantics(Object value) {
    return 'Wynik $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'PZ$level';
  }

  @override
  String get hudTournamentBadge => 'TURNIEJ';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'PAUZA';

  @override
  String get poPremium => 'Premium';

  @override
  String get poStore => 'Sklep';

  @override
  String get poResume => 'WZNÓW';

  @override
  String get poRestart => 'OD NOWA';

  @override
  String get poHome => 'MENU';

  @override
  String get poDPadOn => 'D-PAD: WŁ.';

  @override
  String get poDPadOff => 'D-PAD: WYŁ.';

  @override
  String get poSound => 'DŹWIĘK';

  @override
  String get poMusic => 'MUZYKA';

  @override
  String get poHowToPlay => 'JAK GRAĆ';

  @override
  String get poGameGuide => 'PRZEWODNIK';

  @override
  String get poFoodUpper => 'JEDZENIE';

  @override
  String get poPts10 => '10 pkt';

  @override
  String get poPts25 => '25 pkt';

  @override
  String get poPts50 => '50 pkt';

  @override
  String get poComboUpper => 'COMBO';

  @override
  String get poBites5 => '5 kęsów';

  @override
  String get poBites10 => '10 kęsów';

  @override
  String get poBites20 => '20 kęsów';

  @override
  String get poComboHint =>
      'Ognisty chip przy wyniku rozgrzewa się i pulsuje przy każdym progu.';

  @override
  String get poPowerUpsUpper => 'WZMOCNIENIA';

  @override
  String get poDur7s => '7 s';

  @override
  String get poDur6s => '6 s';

  @override
  String get poDur10s => '10 s';

  @override
  String get poDur8s => '8 s';

  @override
  String get poScore2x => 'Punkty 2×';

  @override
  String get poPowerUpHint =>
      'Pierścień ikony opróżnia się do wygaśnięcia. Licznik zamarza w pauzie.';

  @override
  String get poCrashUpper => 'KOLIZJA';

  @override
  String get poCrashHint =>
      'Czerwona fala uderza w pole, na którym zginąłeś. Kolizja z sobą podświetla też na żółto trafiony segment.';

  @override
  String get poModesUpper => 'TRYBY';

  @override
  String get poModeWallsOn => 'ze ścianami';

  @override
  String get poModeWallsOff => 'bez ścian';

  @override
  String get poModeFastTick => 'szybkie tempo';

  @override
  String get poModeThreeFoods => '3 porcje naraz';

  @override
  String get poModeThreeLives => '3 życia, przyspiesza';

  @override
  String get poModeThreeMin => 'łącznie 3 min';

  @override
  String get poModeFrequentPowerUps => 'częste wzmocnienia';

  @override
  String get poModeDontCross => 'nie przecinaj śladu';

  @override
  String get dcTitle => 'Dzienne wyzwania';

  @override
  String get dcNoChallenges => 'Brak dostępnych wyzwań';

  @override
  String get dcAllComplete => 'Wszystko ukończone!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count bonusu';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · kompilacja $build';
  }

  @override
  String get crTagline => 'Klasyczna gra w węża na nowo.';

  @override
  String get crChipModes => 'Tryby';

  @override
  String get crChipAchievements => 'Osiągnięcia';

  @override
  String get crChipDaily => 'Codziennie';

  @override
  String get crChipLeaderboards => 'Rankingi';

  @override
  String get crChipCosmetics => 'Kosmetyki';

  @override
  String get crCraftedBy => 'Stworzone przez';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · Wszelkie prawa zastrzeżone';
  }

  @override
  String get gbSpeedNormal => 'Normalna';

  @override
  String get gbSpeedFast => 'Szybka';

  @override
  String get gbSpeedFaster => 'Szybsza';

  @override
  String get gbSpeedBlazing => 'Piekielna';

  @override
  String get gbSpeedInsane => 'Szalona';

  @override
  String get gbSpeedMax => 'MAKS';

  @override
  String get gbLength => 'Długość';

  @override
  String get gbSpeed => 'Prędkość';

  @override
  String get gbLevel => 'Poziom';

  @override
  String get rarityCommon => 'Pospolite';

  @override
  String get rarityRare => 'Rzadkie';

  @override
  String get rarityEpic => 'Epickie';

  @override
  String get rarityLegendary => 'Legendarne';

  @override
  String get rarityDiamond => 'Diamentowe';

  @override
  String get achTitleFirstBite => 'Pierwszy Kęs';

  @override
  String get achDescFirstBite => 'Zdobądź swój pierwszy punkt';

  @override
  String get achTitleGettingStarted => 'Pierwsze Kroki';

  @override
  String get achDescGettingStarted => 'Zdobądź 100 punktów';

  @override
  String get achTitleHighScorer => 'Dobry Strzelec';

  @override
  String get achDescHighScorer => 'Zdobądź 500 punktów w jednej grze';

  @override
  String get achTitleMasterScorer => 'Mistrz Punktów';

  @override
  String get achDescMasterScorer => 'Zdobądź 1000 punktów w jednej grze';

  @override
  String get achTitleLegendaryScorer => 'Legendarny Strzelec';

  @override
  String get achDescLegendaryScorer => 'Zdobądź 2000 punktów w jednej grze';

  @override
  String get achTitleFirstGame => 'Pierwsza Gra';

  @override
  String get achDescFirstGame => 'Zagraj swoją pierwszą grę';

  @override
  String get achTitleRegularPlayer => 'Stały Gracz';

  @override
  String get achDescRegularPlayer => 'Zagraj 10 gier';

  @override
  String get achTitleDedicatedPlayer => 'Oddany Gracz';

  @override
  String get achDescDedicatedPlayer => 'Zagraj 50 gier';

  @override
  String get achTitleSnakeEnthusiast => 'Entuzjasta Węża';

  @override
  String get achDescSnakeEnthusiast => 'Zagraj 100 gier';

  @override
  String get achTitleSnakeAddict => 'Uzależniony od Węża';

  @override
  String get achDescSnakeAddict => 'Zagraj 500 gier';

  @override
  String get achTitleSurvivor => 'Ocalały';

  @override
  String get achDescSurvivor => 'Przetrwaj 60 sekund';

  @override
  String get achTitleEndurance => 'Wytrzymałość';

  @override
  String get achDescEndurance => 'Przetrwaj 2 minuty';

  @override
  String get achTitleMarathon => 'Maraton';

  @override
  String get achDescMarathon => 'Przetrwaj 5 minut';

  @override
  String get achTitleNoWalls => 'Unikacz Ścian';

  @override
  String get achDescNoWalls => 'Zagraj 5 gier bez uderzenia w ścianę';

  @override
  String get achTitleSpeedster => 'Szybki jak Błyskawica';

  @override
  String get achDescSpeedster => 'Osiągnij poziom 10 (maksymalna prędkość)';

  @override
  String get achTitlePerfectionist => 'Perfekcjonista';

  @override
  String get achDescPerfectionist => 'Ukończ grę bez uderzenia w siebie';

  @override
  String get achTitleAllFoodTypes => 'Smakosz';

  @override
  String get achDescAllFoodTypes =>
      'Zjedz wszystkie 3 rodzaje jedzenia w jednej grze';

  @override
  String get achTitleHalfGrand => 'Pięć Tysięcy';

  @override
  String get achDescHalfGrand => 'Zdobądź 5 000 w jednej grze';

  @override
  String get achTitleScoreSniper => 'Snajper Punktów';

  @override
  String get achDescScoreSniper => 'Zdobądź 10 000 w jednej grze';

  @override
  String get achTitleFiveDigitClub => 'Klub Pięciu Cyfr';

  @override
  String get achDescFiveDigitClub => 'Zdobądź 25 000 w jednej grze';

  @override
  String get achTitleScoreTycoon => 'Potentat Punktów';

  @override
  String get achDescScoreTycoon => 'Zdobądź 50 000 w jednej grze';

  @override
  String get achTitleScoreGod => 'Bóg Punktów';

  @override
  String get achDescScoreGod => 'Zdobądź 100 000 w jednej grze';

  @override
  String get achTitlePointCollector => 'Kolekcjoner Punktów';

  @override
  String get achDescPointCollector => 'Zgromadź łącznie 10 000 punktów';

  @override
  String get achTitlePointHoarder => 'Zbieracz Punktów';

  @override
  String get achDescPointHoarder => 'Zgromadź łącznie 100 000 punktów';

  @override
  String get achTitleHalfMillionClub => 'Klub Pół Miliona';

  @override
  String get achDescHalfMillionClub => 'Zgromadź łącznie 500 000 punktów';

  @override
  String get achTitlePointMillionaire => 'Punktowy Milioner';

  @override
  String get achDescPointMillionaire => 'Zgromadź łącznie 1 000 000 punktów';

  @override
  String get achTitleDecamillionaire => 'Dekamilioner';

  @override
  String get achDescDecamillionaire => 'Zgromadź łącznie 10 000 000 punktów';

  @override
  String get achTitleSnakeVeteran => 'Weteran Węża';

  @override
  String get achDescSnakeVeteran => 'Zagraj 1 000 gier';

  @override
  String get achTitleSnakeLegend => 'Legenda Węża';

  @override
  String get achDescSnakeLegend => 'Zagraj 5 000 gier';

  @override
  String get achTitleIronWill => 'Żelazna Wola';

  @override
  String get achDescIronWill => 'Przetrwaj 10 minut w jednej grze';

  @override
  String get achTitleEternalSnake => 'Wieczny Wąż';

  @override
  String get achDescEternalSnake => 'Przetrwaj 20 minut w jednej grze';

  @override
  String get achTitleTimeLord => 'Władca Czasu';

  @override
  String get achDescTimeLord => 'Przetrwaj 30 minut w jednej grze';

  @override
  String get achTitleFirstBiteSnack => 'Pierwsza Przekąska';

  @override
  String get achDescFirstBiteSnack => 'Zjedz 5 porcji jedzenia w jednej grze';

  @override
  String get achTitleHungrySnake => 'Głodny Wąż';

  @override
  String get achDescHungrySnake => 'Zjedz 20 porcji jedzenia w jednej grze';

  @override
  String get achTitleFamished => 'Wygłodniały';

  @override
  String get achDescFamished => 'Zjedz 50 porcji jedzenia w jednej grze';

  @override
  String get achTitleRavenous => 'Żarłoczny';

  @override
  String get achDescRavenous => 'Zjedz 100 porcji jedzenia w jednej grze';

  @override
  String get achTitleInsatiable => 'Nienasycony';

  @override
  String get achDescInsatiable => 'Zjedz 200 porcji jedzenia w jednej grze';

  @override
  String get achTitleBlackHoleStomach => 'Żołądek jak Czarna Dziura';

  @override
  String get achDescBlackHoleStomach =>
      'Zjedz 500 porcji jedzenia w jednej grze';

  @override
  String get achTitleFoodieApprentice => 'Uczeń Smakosza';

  @override
  String get achDescFoodieApprentice => 'Zjedz łącznie 100 porcji jedzenia';

  @override
  String get achTitleFoodiePro => 'Zawodowy Smakosz';

  @override
  String get achDescFoodiePro => 'Zjedz łącznie 1 000 porcji jedzenia';

  @override
  String get achTitleFoodieMaster => 'Mistrz Smakoszy';

  @override
  String get achDescFoodieMaster => 'Zjedz łącznie 10 000 porcji jedzenia';

  @override
  String get achTitleFoodieGod => 'Bóg Smakoszy';

  @override
  String get achDescFoodieGod => 'Zjedz łącznie 50 000 porcji jedzenia';

  @override
  String get achTitleQuickPlayer => 'Szybki Gracz';

  @override
  String get achDescQuickPlayer => 'Graj łącznie 1 godzinę';

  @override
  String get achTitleEngagedPlayer => 'Zaangażowany Gracz';

  @override
  String get achDescEngagedPlayer => 'Graj łącznie 10 godzin';

  @override
  String get achTitleHardcorePlayer => 'Hardkorowy Gracz';

  @override
  String get achDescHardcorePlayer => 'Graj łącznie 50 godzin';

  @override
  String get achTitleSnakeObsessed => 'Owładnięty Wężem';

  @override
  String get achDescSnakeObsessed => 'Graj łącznie 100 godzin';

  @override
  String get achTitleTouchGrass => 'Dotknij Trawy';

  @override
  String get achDescTouchGrass =>
      'Graj łącznie 250 godzin — może czas wyjść na dwór?';

  @override
  String get achTitleLevel5 => 'Uczeń';

  @override
  String get achDescLevel5 => 'Osiągnij Poziom 5';

  @override
  String get achTitleLevel10 => 'Czeladnik';

  @override
  String get achDescLevel10 => 'Osiągnij Poziom 10';

  @override
  String get achTitleLevel25 => 'Ekspert';

  @override
  String get achDescLevel25 => 'Osiągnij Poziom 25';

  @override
  String get achTitleLevel50 => 'Mistrz';

  @override
  String get achDescLevel50 => 'Osiągnij Poziom 50';

  @override
  String get achTitleLevel100 => 'Arcymistrz';

  @override
  String get achDescLevel100 => 'Osiągnij Poziom 100';

  @override
  String get achTitleClassicInitiate => 'Adept Klasyki';

  @override
  String get achDescClassicInitiate => 'Ukończ 10 gier w trybie klasycznym';

  @override
  String get achTitleClassicVeteran => 'Weteran Klasyki';

  @override
  String get achDescClassicVeteran => 'Ukończ 100 gier w trybie klasycznym';

  @override
  String get achTitleClassic1000 => 'Koneser Klasyki';

  @override
  String get achDescClassic1000 => 'Zdobądź 1 000 w trybie klasycznym';

  @override
  String get achTitleClassic5000 => 'Maestro Klasyki';

  @override
  String get achDescClassic5000 => 'Zdobądź 5 000 w trybie klasycznym';

  @override
  String get achTitleZenInitiate => 'Adept Zen';

  @override
  String get achDescZenInitiate => 'Ukończ 10 gier Zen';

  @override
  String get achTitleZenGarden => 'Ogród Zen';

  @override
  String get achDescZenGarden => 'Zdobądź 500 w trybie Zen';

  @override
  String get achTitleZenMaster => 'Mistrz Zen';

  @override
  String get achDescZenMaster => 'Zdobądź 5 000 w trybie Zen';

  @override
  String get achTitleSpeedInitiate => 'Żądza Prędkości';

  @override
  String get achDescSpeedInitiate => 'Ukończ 10 gier Wyzwania Prędkości';

  @override
  String get achTitleSpeedrunner => 'Speedrunner';

  @override
  String get achDescSpeedrunner => 'Zdobądź 500 w Wyzwaniu Prędkości';

  @override
  String get achTitleLightning => 'Błyskawica';

  @override
  String get achDescLightning => 'Zdobądź 2 000 w Wyzwaniu Prędkości';

  @override
  String get achTitleMultifoodInitiate => 'Kraina Jedzenia';

  @override
  String get achDescMultifoodInitiate => 'Ukończ 10 gier MultiJedzenia';

  @override
  String get achTitleBuffet => 'Bufet';

  @override
  String get achDescBuffet => 'Zdobądź 1 000 w MultiJedzeniu';

  @override
  String get achTitleSmorgasbord => 'Uczta';

  @override
  String get achDescSmorgasbord => 'Zdobądź 5 000 w MultiJedzeniu';

  @override
  String get achTitleSurvivalInitiate => 'Adept Przetrwania';

  @override
  String get achDescSurvivalInitiate => 'Ukończ 10 gier Przetrwania';

  @override
  String get achTitleSurvivalPro => 'Zawodowiec Przetrwania';

  @override
  String get achDescSurvivalPro => 'Przetrwaj 5 minut w trybie Przetrwania';

  @override
  String get achTitleLastSnakeStanding => 'Ostatni Wąż na Placu Boju';

  @override
  String get achDescLastSnakeStanding => 'Zdobądź 2 500 w Przetrwaniu';

  @override
  String get achTitleTimeattackInitiate => 'Atakujący Czas';

  @override
  String get achDescTimeattackInitiate => 'Ukończ 10 gier Na Czas';

  @override
  String get achTitleBeatTheClock => 'Pokonaj Zegar';

  @override
  String get achDescBeatTheClock => 'Przetrwaj pełne 3 minuty trybu Na Czas';

  @override
  String get achTitleTimeattackMaster => 'Mistrz Gry Na Czas';

  @override
  String get achDescTimeattackMaster => 'Zdobądź 3 000 w trybie Na Czas';

  @override
  String get achTitleComboStarter => 'Początkujący Combo';

  @override
  String get achDescComboStarter => 'Zalicz combo 5x w jednej grze';

  @override
  String get achTitleComboMaster => 'Mistrz Combo';

  @override
  String get achDescComboMaster => 'Zalicz combo 10x w jednej grze';

  @override
  String get achTitleComboPro => 'Zawodowiec Combo';

  @override
  String get achDescComboPro => 'Zalicz combo 20x w jednej grze';

  @override
  String get achTitleComboGod => 'Bóg Combo';

  @override
  String get achDescComboGod => 'Zalicz combo 50x w jednej grze';

  @override
  String get achTitleComboLegend => 'Legenda Combo';

  @override
  String get achDescComboLegend => 'Zalicz combo 100x w jednej grze';

  @override
  String get achTitleGrowingSnake => 'Rosnący Wąż';

  @override
  String get achDescGrowingSnake => 'Wyhoduj węża do długości 20';

  @override
  String get achTitleBigSnake => 'Duży Wąż';

  @override
  String get achDescBigSnake => 'Wyhoduj węża do długości 50';

  @override
  String get achTitleHugeSnake => 'Ogromny Wąż';

  @override
  String get achDescHugeSnake => 'Wyhoduj węża do długości 100';

  @override
  String get achTitleMassiveSnake => 'Gigantyczny Wąż';

  @override
  String get achDescMassiveSnake => 'Wyhoduj węża do długości 200';

  @override
  String get achTitleAnaconda => 'Anakonda';

  @override
  String get achDescAnaconda => 'Wyhoduj węża do długości 500';

  @override
  String get achTitleFirstPowerUp => 'Wzmocnienie!';

  @override
  String get achDescFirstPowerUp => 'Zbierz swoje pierwsze wzmocnienie';

  @override
  String get achTitlePowerPlayer => 'Gracz Mocy';

  @override
  String get achDescPowerPlayer => 'Zbierz łącznie 10 wzmocnień';

  @override
  String get achTitlePowerHungry => 'Głodny Mocy';

  @override
  String get achDescPowerHungry => 'Zbierz łącznie 50 wzmocnień';

  @override
  String get achTitlePowerAddict => 'Uzależniony od Mocy';

  @override
  String get achDescPowerAddict => 'Zbierz łącznie 200 wzmocnień';

  @override
  String get achTitlePowerMaster => 'Mistrz Mocy';

  @override
  String get achDescPowerMaster => 'Zbierz łącznie 1 000 wzmocnień';

  @override
  String get achTitleVarietyPack => 'Pełen Zestaw';

  @override
  String get achDescVarietyPack =>
      'Zbierz każdy z 4 rodzajów wzmocnień co najmniej raz';

  @override
  String get achTitleSpeedDemon => 'Demon Prędkości';

  @override
  String get achDescSpeedDemon => 'Zbierz 25 wzmocnień Przyspieszenia';

  @override
  String get achTitleImmortalStreak => 'Nieśmiertelna Seria';

  @override
  String get achDescImmortalStreak => 'Zbierz 25 wzmocnień Niezniszczalności';

  @override
  String get achTitleSpecialDiet => 'Specjalna Dieta';

  @override
  String get achDescSpecialDiet =>
      'Zjedz łącznie 50 specjalnych porcji jedzenia';

  @override
  String get achTitleBonusHunter => 'Łowca Bonusów';

  @override
  String get achDescBonusHunter =>
      'Zjedz łącznie 100 bonusowych porcji jedzenia';

  @override
  String get achTitleUntouchable5 => 'Nietykalny';

  @override
  String get achDescUntouchable5 =>
      'Ukończ 5 perfekcyjnych gier (bez kolizji, 30 s+)';

  @override
  String get achTitleUntouchable20 => 'Nieskazitelny';

  @override
  String get achDescUntouchable20 => 'Ukończ 20 perfekcyjnych gier';

  @override
  String get achTitleUntouchable50 => 'Nietykalna Legenda';

  @override
  String get achDescUntouchable50 => 'Ukończ 50 perfekcyjnych gier';

  @override
  String get achTitleHotStreak => 'Gorąca Seria';

  @override
  String get achDescHotStreak => '5 gier z rzędu z wynikiem >0 i czasem 30 s+';

  @override
  String get achTitleOnFire => 'W Ogniu';

  @override
  String get achDescOnFire => 'Seria 10 gier (każda 30 s+)';

  @override
  String get achTitleUnstoppable => 'Nie do Zatrzymania';

  @override
  String get achDescUnstoppable => 'Seria 25 gier (każda 30 s+)';

  @override
  String get achTitleDailyThree => 'Codzienny Gracz';

  @override
  String get achDescDailyThree => 'Graj przez 3 dni z rzędu';

  @override
  String get achTitleWeekWarrior => 'Wojownik Tygodnia';

  @override
  String get achDescWeekWarrior => 'Graj przez 7 dni z rzędu';

  @override
  String get achTitleVelocity => 'Prędkość';

  @override
  String get achDescVelocity => 'Osiągnij 15. poziom rozgrywki w jednej grze';

  @override
  String get achTitleMachSpeed => 'Prędkość Mach';

  @override
  String get achDescMachSpeed => 'Osiągnij 20. poziom rozgrywki w jednej grze';

  @override
  String get achTitleCosmicSnake => 'Kosmiczny Wąż';

  @override
  String get achDescCosmicSnake =>
      'Osiągnij 25. poziom rozgrywki w jednej grze';

  @override
  String get achTitleModeExplorer => 'Odkrywca Trybów';

  @override
  String get achDescModeExplorer =>
      'Zagraj co najmniej jedną grę w 3 różnych trybach';

  @override
  String get achTitleAllModePlayer => 'Gracz Wszystkich Trybów';

  @override
  String get achDescAllModePlayer =>
      'Zagraj co najmniej jedną grę w każdym trybie (8 trybów)';

  @override
  String get achTitleNightOwl => 'Nocny Marek';

  @override
  String get achDescNightOwl => 'Ukończ grę między północą a 5 rano';

  @override
  String get achTitleEarlyBird => 'Ranny Ptaszek';

  @override
  String get achDescEarlyBird => 'Ukończ grę między 5 a 8 rano';

  @override
  String get achTitleWeekendWarrior => 'Weekendowy Wojownik';

  @override
  String get achDescWeekendWarrior => 'Ukończ 10 gier w weekendy';

  @override
  String get ppuMegaSpeedBoost => 'Mega Przyspieszenie';

  @override
  String get ppuMegaInvincibility => 'Mega Niezniszczalność';

  @override
  String get ppuMegaScoreMultiplier => 'Mega Mnożnik Punktów';

  @override
  String get ppuMegaSlowMotion => 'Mega Spowolnienie';

  @override
  String get ppuTeleport => 'Teleport';

  @override
  String get ppuSizeReducer => 'Reduktor Rozmiaru';

  @override
  String get ppuScoreShield => 'Tarcza Punktów';

  @override
  String get ppuComboMultiplier => 'Mnożnik Combo';

  @override
  String get ppuTimeWarp => 'Zakrzywienie Czasu';

  @override
  String get ppuMagneticFood => 'Magnetyczne Jedzenie';

  @override
  String get ppuGhostMode => 'Tryb Ducha';

  @override
  String get ppuDoubleTrouble => 'Podwójny Kłopot';

  @override
  String get ppuLuckyCharm => 'Szczęśliwy Amulet';

  @override
  String get ppuPowerSurge => 'Przypływ Mocy';

  @override
  String get bundleMegaPack => 'Mega Pakiet Mocy';

  @override
  String get bundleMegaPackDesc => 'Ulepszone wersje klasycznych wzmocnień';

  @override
  String get bundleTacticalPack => 'Pakiet Taktyczny';

  @override
  String get bundleTacticalPackDesc =>
      'Strategiczne wzmocnienia dla wprawnych graczy';

  @override
  String get bundleUltimatePack => 'Pakiet Ostateczny';

  @override
  String get bundleUltimatePackDesc => 'Wszystkie wzmocnienia premium w jednym';

  @override
  String get skinClassic => 'Klasyczna';

  @override
  String get skinGolden => 'Złoty Wąż';

  @override
  String get skinRainbow => 'Tęczowy Wąż';

  @override
  String get skinGalaxy => 'Galaktyczny Wąż';

  @override
  String get skinDragon => 'Smoczy Wąż';

  @override
  String get skinElectric => 'Elektryczny Wąż';

  @override
  String get skinFire => 'Ognisty Wąż';

  @override
  String get skinIce => 'Lodowy Wąż';

  @override
  String get skinShadow => 'Cienisty Wąż';

  @override
  String get skinNeon => 'Neonowy Wąż';

  @override
  String get skinCrystal => 'Kryształowy Wąż';

  @override
  String get skinCosmic => 'Kosmiczny Wąż';

  @override
  String get skinClassicDesc => 'Oryginalny wygląd węża';

  @override
  String get skinGoldenDesc => 'Lśniący złoty wąż błyszczący przy każdym ruchu';

  @override
  String get skinRainbowDesc => 'Kolorowy wąż mieniący się barwami tęczy';

  @override
  String get skinGalaxyDesc => 'Kosmiczny wąż w gwiezdne wzory';

  @override
  String get skinDragonDesc => 'Groźny wąż w smoczych łuskach z mistyczną mocą';

  @override
  String get skinElectricDesc => 'Trzeszczy elektryczną energią';

  @override
  String get skinFireDesc => 'Płonie ognistymi wzorami';

  @override
  String get skinIceDesc => 'Zamrożone piękno z krystalicznymi efektami';

  @override
  String get skinShadowDesc => 'Mroczny i tajemniczy wąż cienia';

  @override
  String get skinNeonDesc => 'Świeci neonowymi światłami w stylu cyberpunk';

  @override
  String get skinCrystalDesc =>
      'Półprzezroczysty kryształowy wąż z pryzmatycznymi efektami';

  @override
  String get skinCosmicDesc => 'Wąż z gwiezdnego pyłu i kosmicznej materii';

  @override
  String get trailNone => 'Bez Śladu';

  @override
  String get trailParticle => 'Ślad Cząsteczek';

  @override
  String get trailGlow => 'Świetlisty Ślad';

  @override
  String get trailRainbow => 'Tęczowy Ślad';

  @override
  String get trailFire => 'Ognisty Ślad';

  @override
  String get trailElectric => 'Elektryczny Ślad';

  @override
  String get trailStar => 'Gwiezdny Ślad';

  @override
  String get trailCosmic => 'Kosmiczny Ślad';

  @override
  String get trailNeon => 'Neonowy Ślad';

  @override
  String get trailShadow => 'Cienisty Ślad';

  @override
  String get trailCrystal => 'Kryształowy Ślad';

  @override
  String get trailDragon => 'Smoczy Ślad';

  @override
  String get trailNoneDesc => 'Czysty wąż bez efektów śladu';

  @override
  String get trailParticleDesc => 'Zostawia ślad błyszczących cząsteczek';

  @override
  String get trailGlowDesc => 'Świetlisty ślad gasnący za wężem';

  @override
  String get trailRainbowDesc => 'Kolorowy efekt tęczowego śladu';

  @override
  String get trailFireDesc => 'Płonący ognisty ślad z żarem';

  @override
  String get trailElectricDesc => 'Trzeszczący elektryczny ślad z błyskawicami';

  @override
  String get trailStarDesc => 'Migoczące gwiazdy podążają za wężem';

  @override
  String get trailCosmicDesc => 'Efekty kosmicznego pyłu i mgławic';

  @override
  String get trailNeonDesc => 'Jaskrawy neonowy blask w stylu cyberpunk';

  @override
  String get trailShadowDesc => 'Mroczny ślad cienia z dymnymi efektami';

  @override
  String get trailCrystalDesc => 'Krystaliczne odłamki, które znikają';

  @override
  String get trailDragonDesc => 'Mistyczny ślad smoczego oddechu';

  @override
  String get coinPackSmall => 'Pakiet Startowy';

  @override
  String get coinPackMedium => 'Pakiet Korzystny';

  @override
  String get coinPackLarge => 'Pakiet Premium';

  @override
  String get coinPackMega => 'Pakiet Ostateczny';

  @override
  String coinsAmount(Object coins) {
    return '$coins monet';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus bonusu';
  }

  @override
  String get boardSmall => 'Mała';

  @override
  String get boardClassic => 'Klasyczna';

  @override
  String get boardLarge => 'Duża';

  @override
  String get boardHuge => 'Ogromna';

  @override
  String get boardEpic => 'Epicka';

  @override
  String get boardMassive => 'Gigantyczna';

  @override
  String get boardUltimate => 'Ostateczna';

  @override
  String get boardSmallDesc => 'Szybkie gry, ciasne przestrzenie';

  @override
  String get boardClassicDesc => 'Oryginalne doświadczenie Snake\'a';

  @override
  String get boardLargeDesc => 'Więcej miejsca na wzrost';

  @override
  String get boardHugeDesc => 'Maksimum wyzwania i przestrzeni';

  @override
  String get boardEpicDesc => 'Duża plansza dla zaawansowanych graczy';

  @override
  String get boardMassiveDesc => 'Olbrzymia plansza do epickich gier';

  @override
  String get boardUltimateDesc => 'Największa możliwa plansza';

  @override
  String get crashLabelSkip => 'Pomiń';

  @override
  String get crashLabelUntilTap => 'Do Dotknięcia';

  @override
  String get tgmClassic => 'Klasyczny';

  @override
  String get tgmSpeedRun => 'Wyścig Prędkości';

  @override
  String get tgmSurvival => 'Przetrwanie';

  @override
  String get tgmNoWalls => 'Bez Ścian';

  @override
  String get tgmPowerUpMadness => 'Szaleństwo Wzmocnień';

  @override
  String get tgmPerfectGame => 'Perfekcyjna Gra';

  @override
  String get tgmClassicDesc => 'Standardowe zasady gry Snake';

  @override
  String get tgmSpeedRunDesc => 'Prędkość gry szybko rośnie';

  @override
  String get tgmSurvivalDesc => 'Przetrwaj jak najdłużej';

  @override
  String get tgmNoWallsDesc => 'Wąż przechodzi przez krawędzie ekranu';

  @override
  String get tgmPowerUpMadnessDesc => 'Wzmocnienia pojawiają się często';

  @override
  String get tgmPerfectGameDesc => 'Zero błędów - jedno uderzenie kończy grę';

  @override
  String get ttDaily => 'Dzienne Wyzwanie';

  @override
  String get ttWeekly => 'Tygodniowy Turniej';

  @override
  String get ttSpecial => 'Wydarzenie Specjalne';

  @override
  String get tsUpcoming => 'Nadchodzący';

  @override
  String get tsActive => 'Aktywny';

  @override
  String get tsEnded => 'Zakończony';

  @override
  String get cdEasy => 'Łatwy';

  @override
  String get cdMedium => 'Średni';

  @override
  String get cdHard => 'Trudny';

  @override
  String get usOnline => 'Online';

  @override
  String get usOffline => 'Offline';

  @override
  String get usPlaying => 'W grze';

  @override
  String get bprXpBoost => 'Zastrzyk XP';

  @override
  String get bprCoins => 'Monety';

  @override
  String get bprTheme => 'Motyw';

  @override
  String get bprSkin => 'Skórka Węża';

  @override
  String get bprTrail => 'Efekt Śladu';

  @override
  String get bprPowerUp => 'Wzmocnienie';

  @override
  String get bprTournamentEntry => 'Wejściówka na Turniej';

  @override
  String get bprTitle => 'Tytuł Gracza';

  @override
  String get bprAvatar => 'Awatar';

  @override
  String get bprSpecial => 'Nagroda Specjalna';

  @override
  String get bprFree => 'Darmowa';

  @override
  String get bprPremium => 'Premium';

  @override
  String get bprnStarDust => 'Gwiezdny Pył';

  @override
  String get bprnEnergyPack => 'Pakiet Energii';

  @override
  String get bprnBronzeEntry => 'Brązowa Wejściówka';

  @override
  String get bprnSilverEntry => 'Srebrna Wejściówka';

  @override
  String get bprnStargazer => 'Obserwator Gwiazd';

  @override
  String get bprnVoyager => 'Podróżnik';

  @override
  String get bprnNebulaTheme => 'Motyw Mgławica';

  @override
  String get bprnStardustTrail => 'Ślad Gwiezdnego Pyłu';

  @override
  String get bprnLegendaryCrate => 'Legendarna Skrzynia';

  @override
  String get bprnMegaXp => 'Mega XP';

  @override
  String get bprnCosmicCharge => 'Kosmiczny Ładunek';

  @override
  String get bprnNovaBurst => 'Wybuch Nowej';

  @override
  String get bprnGalaxySkin => 'Skórka Galaktyka';

  @override
  String get bprnCrystalSerpent => 'Kryształowy Wąż';

  @override
  String get bprnPlasmaWake => 'Smuga Plazmy';

  @override
  String get bprnCosmicAura => 'Kosmiczna Aura';

  @override
  String get bprnCyberpunkTheme => 'Motyw Cyberpunk';

  @override
  String get bprnCrystalTheme => 'Motyw Kryształ';

  @override
  String get bprnSeasonTrophy => 'Trofeum Sezonu';

  @override
  String get bprnCosmicCrown => 'Kosmiczna Korona';

  @override
  String get bprnCosmicLegend => 'Kosmiczna Legenda';

  @override
  String get bprnStarCommander => 'Gwiezdny Dowódca';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity Monet';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'Darmowa nagroda: $type';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'Ekskluzywna nagroda premium: $type';
  }

  @override
  String get insHowToPlay => 'JAK GRAĆ';

  @override
  String get insObjective => 'CEL';

  @override
  String get insObjectiveBody =>
      'Steruj wężem, jedz i rośnij jak najdłuższy, nie uderzając w ściany ani w siebie!';

  @override
  String get insControls => 'STEROWANIE';

  @override
  String get insSwipeUp => 'Przesuń w Górę ↑';

  @override
  String get insSwipeUpDesc => 'Przesuwa węża w górę';

  @override
  String get insSwipeDown => 'Przesuń w Dół ↓';

  @override
  String get insSwipeDownDesc => 'Przesuwa węża w dół';

  @override
  String get insSwipeLeft => 'Przesuń w Lewo ←';

  @override
  String get insSwipeLeftDesc => 'Przesuwa węża w lewo';

  @override
  String get insSwipeRight => 'Przesuń w Prawo →';

  @override
  String get insSwipeRightDesc => 'Przesuwa węża w prawo';

  @override
  String get insTapScreen => 'Dotknij Ekranu';

  @override
  String get insTapScreenDesc => 'Pauza/wznowienie gry';

  @override
  String get insArrowKeys => 'Strzałki (Komputer)';

  @override
  String get insArrowKeysDesc => 'Zmiana kierunku';

  @override
  String get insWasd => 'WASD (Komputer)';

  @override
  String get insWasdDesc => 'Zmiana kierunku';

  @override
  String get insSpacebar => 'Spacja (Komputer)';

  @override
  String get insSpacebarDesc => 'Pauza/wznowienie gry';

  @override
  String get insFoodTypes => 'RODZAJE JEDZENIA';

  @override
  String get insNormalFood => 'Zwykłe Jedzenie';

  @override
  String get insBonusFood => 'Jedzenie Bonusowe';

  @override
  String get insSpecialFood => 'Jedzenie Specjalne';

  @override
  String get insRules => 'ZASADY';

  @override
  String get insRule1 => '• Jedz, aby rosnąć i zdobywać punkty';

  @override
  String get insRule2 => '• Wąż przyspiesza z każdym poziomem';

  @override
  String get insRule3 => '• Gra kończy się po uderzeniu w ścianę lub w siebie';

  @override
  String get insRule4 => '• Jedzenie specjalne pojawia się co 10 zwykłych';

  @override
  String get insRule5 => '• Jedzenie bonusowe znika po 15 sekundach';

  @override
  String get insProTips => 'PORADY PRO';

  @override
  String get insTip1 => 'Planuj ruchy z wyprzedzeniem';

  @override
  String get insTip2 => 'Wykorzystuj krawędzie do tworzenia bezpiecznych stref';

  @override
  String get insTip3 => 'Obserwuj wizualne potwierdzenia przesunięć';

  @override
  String get insTip4 => 'Ćwicz na różnych poziomach trudności';

  @override
  String get insBackToGame => 'POWRÓT DO GRY';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return 'Odebrano $coins monet i $xp XP!';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return 'Odebrano $coins monet!';
  }

  @override
  String get dchWatchTo2x => 'OBEJRZYJ ZA 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 Podwojono! +$coins monet bonusu!';
  }

  @override
  String get dchClaimAll => 'Odbierz Wszystko';

  @override
  String get dchTodaysProgress => 'Dzisiejszy Postęp';

  @override
  String get dchClaim => 'Odbierz';

  @override
  String get dchClaimed => 'Odebrano';

  @override
  String get dchAllCompleteTitle => 'Wszystkie Wyzwania Ukończone!';

  @override
  String get dchBonusClaimed => 'Nagroda bonusowa odebrana';

  @override
  String get dchBonusPending => 'Bonus czeka — odbierz dowolne wyzwanie';

  @override
  String get dchLoading => 'Wczytywanie wyzwań...';

  @override
  String get dchCheckBack => 'Wróć później po nowe dzienne wyzwania!';

  @override
  String get dchAbout => 'O Dziennych Wyzwaniach';

  @override
  String get dchAbout1 => 'Nowe wyzwania codziennie o północy';

  @override
  String get dchAbout2 => 'Ukończ wyzwania, aby zdobyć monety';

  @override
  String get dchAbout3 => 'Zdobywaj XP i awansuj swój profil';

  @override
  String get dchAbout4 => 'Ukończ wszystkie 3 po nagrodę bonusową!';

  @override
  String get dchAllBonusTitle => 'Bonus za Wszystkie Wyzwania';

  @override
  String get dchAllBonusDesc => 'Ukończono dziś wszystkie dzienne wyzwania.';

  @override
  String get wqNoQuests => 'Brak zadań tygodniowych — wróć w poniedziałek';

  @override
  String get wqTitle => 'Zadania Tygodniowe';

  @override
  String get wqClaimReward => 'Odbierz Nagrodę';

  @override
  String get rvNotFound => 'Nie znaleziono powtórki';

  @override
  String get rvLoadFailed => 'Nie udało się wczytać powtórki';

  @override
  String rvTitle(Object name) {
    return 'Powtórka: $name';
  }

  @override
  String get rvLoadingTitle => 'Wczytywanie Powtórki...';

  @override
  String get rvLoading => 'Wczytywanie powtórki...';

  @override
  String get rvGoBack => 'Wróć';

  @override
  String get rvScore => 'Punkty';

  @override
  String get rvLevel => 'Poziom';

  @override
  String get rvFrame => 'Klatka';

  @override
  String get rvTime => 'Czas';

  @override
  String get rvNoFrameData => 'Brak danych klatek';

  @override
  String get rvSpeedLabel => 'Prędkość: ';

  @override
  String rvAteFood(Object type) {
    return '🍎 Zjedzono jedzenie: $type';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ Zebrano wzmocnienie: $type';
  }

  @override
  String get unEmpty => 'Nazwa użytkownika nie może być pusta';

  @override
  String get unSetFailed => 'Nie udało się ustawić nazwy użytkownika';

  @override
  String get unPickTitle => 'Wybierz swoją nazwę użytkownika';

  @override
  String get unPickBody =>
      'Tak będziesz widoczny w rankingu. Wybraliśmy jedną dla ciebie — zostaw ją lub zmień.';

  @override
  String get unLabel => 'Nazwa użytkownika';

  @override
  String get unSaving => 'ZAPISYWANIE...';

  @override
  String get unContinue => 'DALEJ';

  @override
  String get unChangeAnytime =>
      'Możesz ją zmienić w każdej chwili w Ustawieniach.';

  @override
  String unMinLength(Object min) {
    return 'Nazwa użytkownika musi mieć co najmniej $min znaków';
  }

  @override
  String unMaxLength(Object max) {
    return 'Nazwa użytkownika może mieć najwyżej $max znaków';
  }

  @override
  String get unPattern =>
      'Nazwa musi zaczynać się literą i zawierać tylko litery, cyfry i podkreślenia';

  @override
  String get unReserved =>
      'Ta nazwa użytkownika jest zastrzeżona i nie może być użyta';

  @override
  String get unTaken => 'Ta nazwa użytkownika jest już zajęta';

  @override
  String get unUpdateFailed => 'Nie udało się zaktualizować nazwy użytkownika';

  @override
  String get pcTitle => 'Zaktualizowano Prywatność i Warunki';

  @override
  String pcVersionLine(Object version) {
    return 'Wersja $version · zapoznaj się i zaakceptuj, aby kontynuować';
  }

  @override
  String get pcTabPrivacy => 'Polityka Prywatności';

  @override
  String get pcTabTerms => 'Warunki Użytkowania';

  @override
  String get pcAgree =>
      'Przeczytałem(-am) i akceptuję zaktualizowaną Politykę Prywatności oraz Warunki Użytkowania';

  @override
  String get pcContinue => 'Kontynuuj';

  @override
  String lgAvailableAt(Object url) {
    return 'Ten dokument jest dostępny pod adresem $url.';
  }

  @override
  String get lgUnavailable =>
      'Dokument jest obecnie niedostępny. Spróbuj ponownie później.';

  @override
  String get auTitle => 'Zarejestruj się, aby kupować';

  @override
  String get auBody =>
      'Konta gości mogą grać i zapisywać postęp lokalnie, ale nie mogą kupować ani subskrybować. Połącz konto Google lub e-mail, aby odblokować zakupy — twoje monety, kosmetyki i rekordy zostaną zachowane.';

  @override
  String get auGoogle => 'Kontynuuj z Google';

  @override
  String get auGoogleSub => 'Najszybsza opcja. Zaloguj się kontem Google.';

  @override
  String get auLinked => 'Konto połączone. Możesz teraz robić zakupy.';

  @override
  String get auEmail => 'Utwórz Konto E-mail';

  @override
  String get auEmailSub =>
      'Użyj dowolnego e-maila i wybranego hasła. Przywróć na dowolnym urządzeniu.';

  @override
  String get auNotNow => 'Nie teraz';

  @override
  String get auErrCredentialInUse =>
      'Te dane logowania są już połączone z innym kontem. Spróbuj się nimi zalogować.';

  @override
  String get auErrAlreadyLinked => 'To konto jest już połączone.';

  @override
  String get auErrRequiresRecentLogin =>
      'Ze względów bezpieczeństwa zaloguj się ponownie przed połączeniem.';

  @override
  String get auErrNetwork => 'Błąd sieci. Sprawdź połączenie.';

  @override
  String get auErrGeneric => 'Łączenie nie powiodło się. Spróbuj ponownie.';

  @override
  String get sroSettingUpTitle => 'Konfigurowanie konta…';

  @override
  String get sroSettingUpBody =>
      'Przygotowujemy wszystko na twoją pierwszą sesję. To zdarza się tylko raz.';

  @override
  String get sroLoadingTitle => 'Wczytywanie poprzednich danych…';

  @override
  String get sroLoadingBody =>
      'Pobieramy z chmury twoje statystyki, osiągnięcia, monety i odblokowania.';

  @override
  String get sroRestoringTitle => 'Przywracanie postępu…';

  @override
  String get sroRestoringBody =>
      'Stosujemy wszystko na tym urządzeniu. Nie zamykaj aplikacji.';

  @override
  String get sroDoneTitle => 'Gotowe!';

  @override
  String get sroDoneBody => 'Twój postęp został przywrócony.';

  @override
  String get sroFailedTitle => 'Nie udało się przywrócić danych';

  @override
  String get sroFailedBody =>
      'Nie mogliśmy teraz połączyć się z chmurą. Sprawdź internet i spróbuj ponownie. Możesz też kontynuować bez przywracania — spróbujemy przy następnym uruchomieniu aplikacji.';

  @override
  String get sroTryAgain => 'Spróbuj Ponownie';

  @override
  String get sroContinueAnyway => 'Kontynuuj Mimo To';

  @override
  String get ssiOfflinePending =>
      'Offline - zmiany zsynchronizują się po połączeniu';

  @override
  String get ssiSyncing => 'Synchronizacja...';

  @override
  String get ssiAllSynced => 'Wszystkie dane zsynchronizowane';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu nie zostało zsynchronizowane',
      many: '$count elementów nie zostało zsynchronizowanych',
      few: '$count elementy nie zostały zsynchronizowane',
      one: '$count element nie został zsynchronizowany',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu czeka na synchronizację',
      many: '$count elementów czeka na synchronizację',
      few: '$count elementy czekają na synchronizację',
      one: '$count element czeka na synchronizację',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'Offline';

  @override
  String get rvoContinue => 'KONTYNUOWAĆ?';

  @override
  String get rvoSubtitlePro => 'Odrodź się i zachowaj wynik · Za darmo z Pro';

  @override
  String rvoSubtitleTimer(Object seconds) {
    return 'Odrodź się i zachowaj wynik · $seconds s';
  }

  @override
  String get rvoGetLifePro => 'Zdobądź Życie · Darmowe dla Pro';

  @override
  String get rvoWatchAd => 'Obejrzyj reklamę, aby się odrodzić';

  @override
  String rvoUseCoins(Object coins) {
    return 'Użyj $coins monet';
  }

  @override
  String get rvoNoThanks => 'Nie, dziękuję';

  @override
  String get tbTimesUp => 'CZAS MINĄŁ!';

  @override
  String tbKeepGoing(Object seconds) {
    return 'Graj dalej · $seconds s';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'Obejrzyj reklamę — +$seconds s';
  }

  @override
  String get tbEndRun => 'Zakończ grę';

  @override
  String get dbTitle => 'Dzienny Bonus';

  @override
  String get dbClaimToday => 'Odbierz dzienną nagrodę!';

  @override
  String get dbComeBack => 'Wróć jutro!';

  @override
  String dbDayChip(Object day) {
    return 'D$day';
  }

  @override
  String get dbTodaysReward => 'Dzisiejsza Nagroda';

  @override
  String get dbAlreadyClaimed => 'Dziś już odebrano';

  @override
  String get dbClaim => 'ODBIERZ NAGRODĘ';

  @override
  String get dbClaim2x => 'ODBIERZ 2× — OBEJRZYJ REKLAMĘ';

  @override
  String get npPrimerTitle => 'Nie przegap!';

  @override
  String get npPrimerBody =>
      'Wysyłamy tylko kilka powiadomień dziennie — przypomnienie o dziennym wyzwaniu i wydarzenia specjalne.\n\nBez spamu, obiecujemy. 🐍';

  @override
  String get npMaybeLater => 'Może później';

  @override
  String get npAllSet => '🎉 Wszystko gotowe!';

  @override
  String get npTurnOn => 'Włącz';

  @override
  String get npSoftTitle => 'Chcesz być na bieżąco?';

  @override
  String get npSoftBody =>
      'Włącz powiadomienia, a przypomnimy o dziennych wyzwaniach i seriach — plus ważne rzeczy, jak DARMOWE rozdania Premium i wydarzenia specjalne.\n\nTylko kilka dziennie, zero spamu. 🐍';

  @override
  String get npNotNow => 'Nie teraz';

  @override
  String get npEnable => 'Włącz powiadomienia';

  @override
  String get aroUnlocked => 'OSIĄGNIĘCIE ODBLOKOWANE';

  @override
  String get aroTapToContinue => 'Dotknij, aby kontynuować';

  @override
  String get aroSkip => 'POMIŃ';

  @override
  String aroSkipCount(Object count) {
    return 'POMIŃ ($count)';
  }

  @override
  String get luLevelUp => 'NOWY POZIOM!';

  @override
  String luReached(Object level) {
    return 'Osiągnięto Poziom $level';
  }

  @override
  String get luNice => 'SUPER';

  @override
  String get cfTapContinue => 'Dotknij gdziekolwiek, aby kontynuować';

  @override
  String get cfTapSkip => 'Dotknij gdziekolwiek, aby pominąć';

  @override
  String ppgLvShort(Object level) {
    return 'Poz. $level';
  }

  @override
  String ppgLvUpper(Object level) {
    return 'POZ. $level';
  }

  @override
  String ppgLevel(Object level) {
    return 'Poziom $level';
  }

  @override
  String get xgTitle => 'Wyjść z Gry?';

  @override
  String get xgBody =>
      'Na pewno chcesz wyjść? Obecny postęp zostanie utracony.';

  @override
  String get xgExit => 'Wyjdź';

  @override
  String get ccTitle => 'Jak chcesz grać?';

  @override
  String get ccBody =>
      'Wybierz — możesz to zmienić w każdej chwili w Ustawienia → Sterowanie.';

  @override
  String get ccSwipe => 'Gesty Przesunięć';

  @override
  String get ccSwipeSub =>
      'Przesuń palcem gdziekolwiek na planszy, aby skręcić.';

  @override
  String get ccDpad => 'Sterowanie D-Pad';

  @override
  String get ccDpadSub => 'Ekranowe przyciski kierunkowe.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 +$coins monet dodano do portfela!';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'Obejrzyj reklamę — +$coins monet';
  }

  @override
  String get rcNoAd => 'Brak dostępnych reklam';

  @override
  String get raOptIn => 'Dobrowolnie — obejrzyj i zarabiaj';

  @override
  String get compassSemantics => 'Wskaźnik kierunku przesunięcia';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 Dzienny bonus podwojony — +$coins monet bonusu!';
  }

  @override
  String get nsNewNotification => 'Masz nowe powiadomienie';

  @override
  String get nsAchievementUnlocked => '🏆 Osiągnięcie Odblokowane!';

  @override
  String get nsDailyReminderTitle => '🐍 Czas zagrać w Snake Classic!';

  @override
  String get nsDailyReminderBody =>
      'Ukończ dzienne wyzwanie i wspinaj się w rankingu!';

  @override
  String get mpErrMatchmaking =>
      'Dobieranie graczy nie powiodło się. Spróbuj ponownie.';

  @override
  String get mpErrCreateFailed => 'Nie udało się utworzyć gry';

  @override
  String get mpErrJoinFailed =>
      'Nie udało się dołączyć. Gra może być pełna lub nie istnieć.';

  @override
  String get mpErrReadyFailed => 'Nie udało się zmienić statusu gotowości';

  @override
  String get mpErrStartFailed => 'Nie udało się rozpocząć gry';

  @override
  String get mpErrStartTimeout =>
      'Upłynął limit czasu startu. Spróbuj ponownie.';

  @override
  String get mpErrReconnectFailed =>
      'Nie udało się ponownie połączyć z meczem.';

  @override
  String get mpErrConnectionLost =>
      'Utracono połączenie — nie udało się wznowić meczu.';

  @override
  String get mpErrMatchEndedAway => 'Mecz zakończył się pod twoją nieobecność.';

  @override
  String get mpErrWaitingReady => 'Czekamy, aż wszyscy gracze będą gotowi';

  @override
  String get mpErrOnlyHost => 'Tylko gospodarz może rozpocząć grę';

  @override
  String get mpErrSessionExpired => 'Sesja gry wygasła. Utwórz nową grę';

  @override
  String get mpErrAlreadyStarted => 'Ta gra już się rozpoczęła';

  @override
  String get mpErrNeedTwoPlayers => 'Mecze wymagają dokładnie 2 graczy';

  @override
  String get mpErrSignIn => 'Zaloguj się, aby grać w trybie wieloosobowym';

  @override
  String get mpErrReconnectExpired => 'Czas na ponowne połączenie minął';

  @override
  String get mpErrCheckInternet => 'Utracono połączenie. Sprawdź internet';

  @override
  String get mpErrUnableJoin =>
      'Nie udało się dołączyć do pokoju. Spróbuj ponownie';

  @override
  String get mpErrGeneric => 'Coś poszło nie tak. Spróbuj ponownie';

  @override
  String stDurSeconds(Object s) {
    return '$s s';
  }

  @override
  String stDurMinutes(Object m) {
    return '$m min';
  }

  @override
  String stDurHours(Object h) {
    return '$h godz.';
  }

  @override
  String stDurMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String stDurHourMin(Object h, Object m) {
    return '$h godz. $m min';
  }

  @override
  String dchProgressSummary(Object completed, Object total) {
    return 'Ukończono $completed z $total wyzwań';
  }

  @override
  String wqProgressSummary(Object completed, Object total) {
    return '$completed / $total ukończono';
  }

  @override
  String wqClaimable(Object count) {
    return '$count do odebrania';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins monet, +$xp XP przepustki';
  }

  @override
  String get insPoints10 => '10 punktów';

  @override
  String get insPoints25 => '25 punktów';

  @override
  String get insPoints50 => '50 punktów + Nowy Poziom';

  @override
  String get unRules =>
      '• 3-20 znaków\n• Musi zaczynać się literą\n• Tylko litery, cyfry i podkreślenia';

  @override
  String get dcTitleScoreEasy => 'Wynik Początkującego';

  @override
  String get dcTitleScoreMedium => 'Wprawny Gracz';

  @override
  String get dcTitleScoreHard => 'Mistrz Punktów';

  @override
  String get dcTitleFoodEasy => 'Głodny Wąż';

  @override
  String get dcTitleFoodMedium => 'Tryb Uczty';

  @override
  String get dcTitleFoodHard => 'Nienasycony';

  @override
  String get dcTitleSurvivalEasy => 'Ocalały';

  @override
  String get dcTitleSurvivalMedium => 'Wytrzymałość';

  @override
  String get dcTitleSurvivalHard => 'Nieśmiertelny';

  @override
  String get dcTitleGamesEasy => 'Gracz Okazjonalny';

  @override
  String get dcTitleGamesMedium => 'Oddany';

  @override
  String get dcTitleGamesHard => 'Uzależniony od Węża';

  @override
  String get dcTitleModeEasy => 'Miłośnik Klasyki';

  @override
  String get dcTitleModeMedium => 'Mistrz Zen';

  @override
  String get dcTitleModeHard => 'Demon Prędkości';

  @override
  String dcDescScore(Object target) {
    return 'Zdobądź co najmniej $target punktów w jednej grze';
  }

  @override
  String dcDescFood(Object target) {
    return 'Zjedz dziś $target porcji jedzenia';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'Przetrwaj $target sekund w jednej grze';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Zagraj dziś $target gry',
      many: 'Zagraj dziś $target gier',
      few: 'Zagraj dziś $target gry',
      one: 'Zagraj dziś $target grę',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Zagraj $target gry w trybie $mode',
      many: 'Zagraj $target gier w trybie $mode',
      few: 'Zagraj $target gry w trybie $mode',
      one: 'Zagraj $target grę w trybie $mode',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'Tygodniowa Rozgrzewka';

  @override
  String get wqTitleScoreMedium => 'Wyostrzony Refleks';

  @override
  String get wqTitleScoreHard => 'Mistrz Wyniku';

  @override
  String get wqTitleFoodEasy => 'Tygodniowa Przekąska';

  @override
  String get wqTitleFoodMedium => 'Żarłoczny';

  @override
  String get wqTitleFoodHard => 'Bez Dna';

  @override
  String get wqTitleGamesEasy => 'Pięć na Tydzień';

  @override
  String get wqTitleGamesMedium => 'Wyrobiona Rutyna';

  @override
  String get wqTitleGamesHard => 'Maratończyk';

  @override
  String get wqTitleSurvivalEasy => 'Dwuminutowy Pełzacz';

  @override
  String get wqTitleSurvivalMedium => 'Pięciominutowy Pełzacz';

  @override
  String get wqTitleSurvivalHard => 'Dziesięciominutowy Pełzacz';

  @override
  String get wqTitleTournament => 'Bywalec Turniejów';

  @override
  String get wqTitleDailyEasy => 'Codzienny Wykonawca';

  @override
  String get wqTitleDailyMedium => 'Codzienny Spec';

  @override
  String wqDescScore(Object target) {
    return 'Zdobądź $target w jednej grze';
  }

  @override
  String wqDescFood(Object target) {
    return 'Zjedz $target porcji jedzenia w tym tygodniu';
  }

  @override
  String wqDescGames(Object target) {
    return 'Zagraj $target gier w tym tygodniu';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'Przetrwaj $target s w jednej grze';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Zagraj $target gry turniejowej',
      many: 'Zagraj $target gier turniejowych',
      few: 'Zagraj $target gry turniejowe',
      one: 'Zagraj $target grę turniejową',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'Ukończ $target dziennych wyzwań w tym tygodniu';
  }

  @override
  String tnNameDaily(Object date) {
    return 'Dzienne Wyzwanie - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'Tygodniowe Mistrzostwa - Tydzień $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'Miesięczne Grand Prix - $monthYear';
  }

  @override
  String get tnDescDaily =>
      'Walcz o najwyższy wynik w dzisiejszym 24-godzinnym wyzwaniu! Najlepsi zdobywają monety i chwałę.';

  @override
  String get tnDescWeekly =>
      'Ostateczne tygodniowe starcie! Rywalizuj z najlepszymi o ogromne nagrody.';

  @override
  String get tnDescMonthly =>
      'Największy turniej miesiąca! Udowodnij, że to ty jesteś prawdziwym mistrzem Snake\'a.';

  @override
  String tnRewardRank(Object rank) {
    return 'Miejsce $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'Nagroda w monetach za miejsce $rank';
  }

  @override
  String get achTitleScore1500 => 'Rozpęd';

  @override
  String get achDescScore1500 => 'Zdobądź 1 500 punktów w jednej grze';

  @override
  String get achTitleScore3000 => 'W Natarciu';

  @override
  String get achDescScore3000 => 'Zdobądź 3 000 punktów w jednej grze';

  @override
  String get achTitleScore7500 => 'Nieustępliwy';

  @override
  String get achDescScore7500 => 'Zdobądź 7 500 punktów w jednej grze';

  @override
  String get achTitleScore15000 => 'Łowca Doskonały';

  @override
  String get achDescScore15000 => 'Zdobądź 15 000 punktów w jednej grze';

  @override
  String get achTitleScore35000 => 'Umysł Maszyny';

  @override
  String get achDescScore35000 => 'Zdobądź 35 000 punktów w jednej grze';

  @override
  String get achTitleScore75000 => 'Ponad Śmiertelników';

  @override
  String get achDescScore75000 => 'Zdobądź 75 000 punktów w jednej grze';

  @override
  String get achTitleScore250000 => 'Ćwierć Miliona';

  @override
  String get achDescScore250000 => 'Zdobądź 250 000 punktów w jednej grze';

  @override
  String get achTitleBeyondTime => 'Poza Czasem';

  @override
  String get achDescBeyondTime => 'Przetrwaj 45 minut w jednej grze';

  @override
  String get achTitleHourbound => 'Pełna Godzina';

  @override
  String get achDescHourbound => 'Przetrwaj całą godzinę w jednej grze';

  @override
  String get achTitleSnakeDevotee => 'Oddany Wężowi';

  @override
  String get achDescSnakeDevotee => 'Zagraj 2 500 gier';

  @override
  String get achTitleTenThousandClub => 'Klub Dziesięciu Tysięcy';

  @override
  String get achDescTenThousandClub => 'Zagraj 10 000 gier';

  @override
  String get achTitleZenVeteran => 'Weteran Zen';

  @override
  String get achDescZenVeteran => 'Ukończ 100 gier Zen';

  @override
  String get achTitleSpeedVeteran => 'Weteran Prędkości';

  @override
  String get achDescSpeedVeteran => 'Ukończ 100 gier Wyzwania Prędkości';

  @override
  String get achTitleMultifoodVeteran => 'Weteran MultiJedzenia';

  @override
  String get achDescMultifoodVeteran => 'Ukończ 100 gier MultiJedzenia';

  @override
  String get achTitleTimeattackVeteran => 'Weteran Gry Na Czas';

  @override
  String get achDescTimeattackVeteran => 'Ukończ 100 gier Na Czas';

  @override
  String get achTitleSurvivalVeteran => 'Weteran Przetrwania';

  @override
  String get achDescSurvivalVeteran => 'Ukończ 100 gier Przetrwania';

  @override
  String get achTitlePumInitiate => 'Adept Szaleństwa';

  @override
  String get achDescPumInitiate => 'Ukończ 10 gier Szaleństwa Wzmocnień';

  @override
  String get achTitlePumVeteran => 'Weteran Szaleństwa';

  @override
  String get achDescPumVeteran => 'Ukończ 100 gier Szaleństwa Wzmocnień';

  @override
  String get achTitlePerfectInitiate => 'Purysta';

  @override
  String get achDescPerfectInitiate => 'Ukończ 10 Perfekcyjnych Gier';

  @override
  String get achTitlePerfectVeteran => 'Dyscyplina';

  @override
  String get achDescPerfectVeteran => 'Ukończ 100 Perfekcyjnych Gier';

  @override
  String get achTitleZen10000 => 'Przepełniony Zen';

  @override
  String get achDescZen10000 => 'Zdobądź 10 000 w trybie Zen';

  @override
  String get achTitleSpeed5000 => 'Rozmycie';

  @override
  String get achDescSpeed5000 => 'Zdobądź 5 000 w Wyzwaniu Prędkości';

  @override
  String get achTitleMultifood10000 => 'Bufet Bez Końca';

  @override
  String get achDescMultifood10000 => 'Zdobądź 10 000 w MultiJedzeniu';

  @override
  String get achTitleTimeattack5000 => 'Wyścig z Zegarem';

  @override
  String get achDescTimeattack5000 => 'Zdobądź 5 000 w trybie Na Czas';

  @override
  String get achTitlePum2000 => 'Naładowany';

  @override
  String get achDescPum2000 => 'Zdobądź 2 000 w Szaleństwie Wzmocnień';

  @override
  String get achTitlePerfect1000 => 'Nieskazitelny Bieg';

  @override
  String get achDescPerfect1000 => 'Zdobądź 1 000 w Perfekcyjnej Grze';

  @override
  String get achTitleComboSingularity => 'Osobliwość Combo';

  @override
  String get achDescComboSingularity => 'Zalicz combo 200x w jednej grze';

  @override
  String get achTitleWorldSerpent => 'Wąż Świata';

  @override
  String get achDescWorldSerpent => 'Wyhoduj węża do długości 750';

  @override
  String get achTitleLightspeed => 'Prędkość Światła';

  @override
  String get achDescLightspeed => 'Osiągnij 30. poziom rozgrywki w jednej grze';

  @override
  String get achTitlePowerOverwhelming => 'Przytłaczająca Moc';

  @override
  String get achDescPowerOverwhelming => 'Zbierz łącznie 5 000 wzmocnień';

  @override
  String get achTitleGreedIsGood => 'Chciwość Jest Dobra';

  @override
  String get achDescGreedIsGood => 'Zbierz 25 wzmocnień Mnożnika Punktów';

  @override
  String get achTitleTimeBender => 'Naginacz Czasu';

  @override
  String get achDescTimeBender => 'Zbierz 25 wzmocnień Spowolnienia';

  @override
  String get achTitleGastronome => 'Gastronom';

  @override
  String get achDescGastronome => 'Zjedz łącznie 100 000 porcji jedzenia';

  @override
  String get achTitleLivingLegend => 'Żywa Legenda';

  @override
  String get achDescLivingLegend => 'Zgromadź łącznie 50 000 000 punktów';

  @override
  String get achTitlePerpetualMotion => 'Perpetuum Mobile';

  @override
  String get achDescPerpetualMotion => 'Seria 50 gier (każda 30 s+)';

  @override
  String get achTitleImmaculate => 'Nieskazitelny';

  @override
  String get achDescImmaculate => 'Ukończ 100 perfekcyjnych gier';

  @override
  String get achTitleFortnightFaithful => 'Wierny Dwa Tygodnie';

  @override
  String get achDescFortnightFaithful => 'Graj przez 14 dni z rzędu';

  @override
  String get achTitleSteadySnake => 'Niezawodny Wąż';

  @override
  String get achDescSteadySnake => 'Przetrwaj 30+ sekund w 100 grach';

  @override
  String get achTitleMarathonMonth => 'Duch Maratonu';

  @override
  String get achDescMarathonMonth => 'Przetrwaj 30+ sekund w 1 000 gier';

  @override
  String get achTitleLunchtimeLegend => 'Legenda Pory Obiadu';

  @override
  String get achDescLunchtimeLegend => 'Ukończ grę między 12:00 a 14:00';

  @override
  String get legalNoticePrefix => 'Grając, akceptujesz nasze ';

  @override
  String get legalNoticeAnd => ' i ';

  @override
  String get dayOneReminderTitle => 'Twój wąż tęskni 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'Twój rekord to $score. Pobijesz go?';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      'Szybka gra? Twój pierwszy rekord czeka.';

  @override
  String get goTomorrowLabel => 'WRÓĆ JUTRO';

  @override
  String goTomorrowReward(int coins, int day) {
    return 'Odbierz $coins monet w dniu $day swojej serii';
  }

  @override
  String get rvAteFoodUnknown => '🍎 Zjadł jedzenie';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ Zebrał ulepszenie';

  @override
  String get boardTall => 'Wysoka';

  @override
  String get boardTallDesc =>
      'Wypełnia ekran telefonu — więcej miejsca na ruch';

  @override
  String get boardTallPlus => 'Wysoka plus';

  @override
  String get boardTallPlusDesc => 'Większa arena w formacie telefonu';

  @override
  String get mpErrReadyTimeout =>
      'Obaj gracze nie zdążyli się przygotować. Szukamy nowego meczu…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'Potwierdzenie · ${seconds}s';
  }

  @override
  String get mpLobbyWaitingOpponentReady =>
      'Czekamy, aż przeciwnik będzie gotowy…';
}
