// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'IDIOMA';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languageSystemDefaultSubtitle => 'Seguir o idioma do dispositivo';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get mpVictory => 'VITÓRIA!';

  @override
  String get mpDraw => 'EMPATE';

  @override
  String get mpDefeat => 'DERROTA';

  @override
  String get mpYou => 'Você';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Adversário';

  @override
  String get mpBackToLobby => 'Voltar ao lobby';

  @override
  String get mpPlayAgain => 'Jogar de novo';

  @override
  String get mpTimeUpDraw => 'Tempo esgotado — empate total!';

  @override
  String get mpTimeUpYouWon => 'Tempo esgotado — você tinha a maior pontuação.';

  @override
  String get mpTimeUpYouLost =>
      'Tempo esgotado — seu adversário tinha a maior pontuação.';

  @override
  String get mpMutualCrashDraw => 'As duas cobras bateram — empate!';

  @override
  String get mpMutualCrashYouWon =>
      'As duas cobras bateram — sua pontuação decidiu.';

  @override
  String get mpMutualCrashYouLost =>
      'As duas cobras bateram — a pontuação dele decidiu.';

  @override
  String get mpMatchCancelled => 'A partida foi cancelada.';

  @override
  String get mpLastSnakeStanding => 'Seu adversário bateu. Última cobra de pé!';

  @override
  String get mpDeathWall => 'Você bateu na parede.';

  @override
  String get mpDeathSelf => 'Você bateu em si mesmo.';

  @override
  String get mpDeathOpponent => 'Você bateu no adversário.';

  @override
  String get mpDeathHeadOn => 'Colisão frontal!';

  @override
  String get mpDeathForfeit =>
      'Desconectado por muito tempo — partida perdida.';

  @override
  String get mpBetterLuck => 'Mais sorte na próxima!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count moedas',
      one: '+$count moeda',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Sair da partida?';

  @override
  String get mpLeaveGameBody =>
      'A partida continua no servidor — sair é desistir.';

  @override
  String get mpLeave => 'Sair';

  @override
  String get mpReconnecting => 'RECONECTANDO…';

  @override
  String get mpReconnectingBody =>
      'A partida ainda está em andamento no servidor.';

  @override
  String get mpGetReady => 'PREPARE-SE';

  @override
  String get mpDroppingIntoArena => 'Levando você para a arena…';

  @override
  String get mpWaitingPlayer => 'Aguardando…';

  @override
  String get mpOut => 'FORA';

  @override
  String get mpLength => 'TAMANHO';

  @override
  String get mpSwipe => 'Deslize';

  @override
  String get mpReconnectingInline => 'reconectando…';
}
