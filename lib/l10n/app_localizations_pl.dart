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
}
