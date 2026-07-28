// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'LINGUA';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

  @override
  String get languageSystemDefaultSubtitle => 'Segui la lingua del dispositivo';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get mpVictory => 'VITTORIA!';

  @override
  String get mpDraw => 'PAREGGIO';

  @override
  String get mpDefeat => 'SCONFITTA';

  @override
  String get mpYou => 'Tu';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Avversario';

  @override
  String get mpBackToLobby => 'Torna alla lobby';

  @override
  String get mpPlayAgain => 'Gioca ancora';

  @override
  String get mpTimeUpDraw => 'Tempo scaduto — perfetta parità!';

  @override
  String get mpTimeUpYouWon => 'Tempo scaduto — avevi il punteggio più alto.';

  @override
  String get mpTimeUpYouLost =>
      'Tempo scaduto — il tuo avversario aveva il punteggio più alto.';

  @override
  String get mpMutualCrashDraw =>
      'Entrambi i serpenti si sono schiantati — pareggio!';

  @override
  String get mpMutualCrashYouWon =>
      'Entrambi i serpenti si sono schiantati — ha deciso il tuo punteggio.';

  @override
  String get mpMutualCrashYouLost =>
      'Entrambi i serpenti si sono schiantati — ha deciso il suo punteggio.';

  @override
  String get mpMatchCancelled => 'La partita è stata annullata.';

  @override
  String get mpLastSnakeStanding =>
      'Il tuo avversario si è schiantato. Ultimo serpente rimasto!';

  @override
  String get mpDeathWall => 'Ti sei schiantato contro il muro.';

  @override
  String get mpDeathSelf => 'Ti sei schiantato contro te stesso.';

  @override
  String get mpDeathOpponent => 'Ti sei schiantato contro il tuo avversario.';

  @override
  String get mpDeathHeadOn => 'Scontro frontale!';

  @override
  String get mpDeathForfeit =>
      'Disconnesso troppo a lungo — partita persa a tavolino.';

  @override
  String get mpBetterLuck => 'Andrà meglio la prossima volta!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count monete',
      one: '+$count moneta',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Uscire dalla partita?';

  @override
  String get mpLeaveGameBody =>
      'La partita continua sul server — uscire significa arrendersi.';

  @override
  String get mpLeave => 'Esci';

  @override
  String get mpReconnecting => 'RICONNESSIONE…';

  @override
  String get mpReconnectingBody => 'La partita è ancora in corso sul server.';

  @override
  String get mpGetReady => 'PREPARATI';

  @override
  String get mpDroppingIntoArena => 'Ti stiamo portando nell\'arena…';

  @override
  String get mpWaitingPlayer => 'In attesa…';

  @override
  String get mpOut => 'FUORI';

  @override
  String get mpLength => 'LUNGHEZZA';

  @override
  String get mpSwipe => 'Scorri';

  @override
  String get mpReconnectingInline => 'riconnessione…';
}
