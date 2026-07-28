// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'IDIOMA';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get languageSystemDefaultSubtitle =>
      'Seguir el idioma del dispositivo';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get mpVictory => '¡VICTORIA!';

  @override
  String get mpDraw => 'EMPATE';

  @override
  String get mpDefeat => 'DERROTA';

  @override
  String get mpYou => 'Tú';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Oponente';

  @override
  String get mpBackToLobby => 'Volver al lobby';

  @override
  String get mpPlayAgain => 'Jugar otra vez';

  @override
  String get mpTimeUpDraw => '¡Se acabó el tiempo — empate total!';

  @override
  String get mpTimeUpYouWon =>
      'Se acabó el tiempo — tenías la puntuación más alta.';

  @override
  String get mpTimeUpYouLost =>
      'Se acabó el tiempo — tu oponente tenía la puntuación más alta.';

  @override
  String get mpMutualCrashDraw => '¡Las dos serpientes chocaron — empate!';

  @override
  String get mpMutualCrashYouWon =>
      'Las dos serpientes chocaron — tu puntuación lo decidió.';

  @override
  String get mpMutualCrashYouLost =>
      'Las dos serpientes chocaron — su puntuación lo decidió.';

  @override
  String get mpMatchCancelled => 'La partida fue cancelada.';

  @override
  String get mpLastSnakeStanding =>
      'Tu oponente chocó. ¡La última serpiente en pie!';

  @override
  String get mpDeathWall => 'Chocaste contra la pared.';

  @override
  String get mpDeathSelf => 'Chocaste contigo mismo.';

  @override
  String get mpDeathOpponent => 'Chocaste contra tu oponente.';

  @override
  String get mpDeathHeadOn => '¡Choque frontal!';

  @override
  String get mpDeathForfeit =>
      'Desconectado demasiado tiempo — partida perdida.';

  @override
  String get mpBetterLuck => '¡Mejor suerte la próxima vez!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count monedas',
      one: '+$count moneda',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => '¿Salir de la partida?';

  @override
  String get mpLeaveGameBody =>
      'La partida sigue en el servidor — salir es rendirse.';

  @override
  String get mpLeave => 'Salir';

  @override
  String get mpReconnecting => 'RECONECTANDO…';

  @override
  String get mpReconnectingBody => 'La partida sigue en curso en el servidor.';

  @override
  String get mpGetReady => 'PREPÁRATE';

  @override
  String get mpDroppingIntoArena => 'Entrando a la arena…';

  @override
  String get mpWaitingPlayer => 'Esperando…';

  @override
  String get mpOut => 'FUERA';

  @override
  String get mpLength => 'LONGITUD';

  @override
  String get mpSwipe => 'Desliza';

  @override
  String get mpReconnectingInline => 'reconectando…';
}
