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
}
