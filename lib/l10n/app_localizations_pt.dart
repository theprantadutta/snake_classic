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

  @override
  String get homePlay => 'JOGAR';

  @override
  String get homeHighScore => 'RECORDE';

  @override
  String homeArmedPowerUp(String name) {
    return 'Equipado: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Equipamento ($count)';
  }

  @override
  String get puSpeedBoost => 'Impulso de Velocidade';

  @override
  String get puInvincibility => 'Invencibilidade';

  @override
  String get puScoreMultiplier => 'Multiplicador de Pontos';

  @override
  String get puSlowMotion => 'Câmera Lenta';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'LOJA';

  @override
  String get homeTileFree => 'GRÁTIS';

  @override
  String get homeTileDaily => 'DIÁRIO';

  @override
  String get homeTileBattle => 'BATALHA';

  @override
  String get homeTileEvents => 'EVENTOS';

  @override
  String get homeTileBoard => 'RANKING';

  @override
  String get homeTileFriends => 'AMIGOS';

  @override
  String get homeTileCosmetics => 'VISUAIS';

  @override
  String get homeTileAwards => 'PRÊMIOS';

  @override
  String get homeTileVersus => 'VERSUS';

  @override
  String get homeNoAdReady =>
      'Nenhum anúncio pronto ainda — tente de novo em alguns segundos.';

  @override
  String get homeFreeSpeedBoostTitle => 'Impulso de Velocidade grátis';

  @override
  String get homeFreeSpeedBoostBody =>
      'Assista a um anúncio curto para adicionar um Impulso de Velocidade grátis ao seu equipamento. Ele ativa 5 segundos após o início do próximo jogo.';

  @override
  String get homeNotNow => 'Agora não';

  @override
  String get homeWatchAd => 'Assistir anúncio';

  @override
  String get homeFreeSpeedBoostAdded =>
      'Impulso de Velocidade grátis adicionado ao seu equipamento!';

  @override
  String get homeAdNotFinished =>
      'Anúncio não concluído — assista até o fim para ganhar a recompensa.';

  @override
  String get homePickGameMode => 'Escolha um modo de jogo';

  @override
  String get homePickGameModeSubtitle =>
      'Você pode mudar isso a qualquer momento nas Configurações';

  @override
  String get homeStartPlaying => 'COMEÇAR A JOGAR';

  @override
  String get homeLoadoutTitle => 'Equipamento de Power-Ups';

  @override
  String get homeLoadoutSubtitle =>
      'Pré-carregue um power-up — ele ativa 5 segundos após o início do próximo jogo.';

  @override
  String get homeWatchAdFreeSpeedBoost =>
      'Assistir anúncio — Impulso de Velocidade grátis';

  @override
  String get homeNoPowerUps =>
      'Você não tem power-ups.\nVisite a loja para comprar!';

  @override
  String homeOwnedCount(int count) {
    return 'Possui: $count';
  }

  @override
  String get homeArmed => 'EQUIPADO';

  @override
  String get homeDone => 'PRONTO';

  @override
  String get settingsTitle => 'CONFIGURAÇÕES';

  @override
  String get settingsBackToGame => 'VOLTAR AO JOGO';

  @override
  String get settingsSectionControls => 'CONTROLES';

  @override
  String get settingsSectionGameplay => 'JOGABILIDADE';

  @override
  String get settingsSectionAudio => 'ÁUDIO';

  @override
  String get settingsSectionVisual => 'VISUAL';

  @override
  String get settingsSectionNotifications => 'NOTIFICAÇÕES';

  @override
  String get settingsSectionUserProfile => 'PERFIL DO USUÁRIO';

  @override
  String get settingsSectionHelp => 'AJUDA E TUTORIAL';

  @override
  String get settingsSectionLegal => 'JURÍDICO';

  @override
  String get settingsSectionPremium => 'RECURSOS PREMIUM';

  @override
  String get settingsDPadControls => 'Controles D-Pad';

  @override
  String get settingsDPadSubtitle =>
      'Mostrar botões direcionais na tela durante o jogo';

  @override
  String get settingsDPadPosition => 'Posição do D-Pad';

  @override
  String get settingsDesktopControls => 'Controles de Desktop/Web';

  @override
  String get settingsArrowKeys => 'Setas';

  @override
  String get settingsWasdKeys => 'Teclas WASD';

  @override
  String get settingsSpacebar => 'Barra de espaço';

  @override
  String get settingsMouseClick => 'Clique do mouse';

  @override
  String get settingsChangeDirection => 'Mudar direção';

  @override
  String get settingsPauseResume => 'Pausar/Retomar o jogo';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Controles de toque (se disponíveis)';

  @override
  String get settingsTouchControls => 'Controles de toque';

  @override
  String get settingsSwipeGestures => 'Gestos de deslizar';

  @override
  String get settingsTapScreen => 'Tocar na tela';

  @override
  String get settingsSwipeUp => 'Deslizar para cima ↑';

  @override
  String get settingsSwipeDown => 'Deslizar para baixo ↓';

  @override
  String get settingsSwipeLeft => 'Deslizar para a esquerda ←';

  @override
  String get settingsSwipeRight => 'Deslizar para a direita →';

  @override
  String get settingsMoveSnakeUp => 'Mover a cobra para cima';

  @override
  String get settingsMoveSnakeDown => 'Mover a cobra para baixo';

  @override
  String get settingsMoveSnakeLeft => 'Mover a cobra para a esquerda';

  @override
  String get settingsMoveSnakeRight => 'Mover a cobra para a direita';

  @override
  String get settingsGameMode => 'Modo de jogo';

  @override
  String get settingsGameModeLocked => 'Conclua o jogo atual para mudar o modo';

  @override
  String get settingsDifficulty => 'Dificuldade';

  @override
  String get settingsDifficultySubtitle =>
      'Define a velocidade inicial da cobra. Todo modo ainda acelera conforme você avança.';

  @override
  String get settingsEasyNote =>
      'Moedas, XP e conquistas continuam valendo no Fácil — só recordes e rankings ficam pausados.';

  @override
  String get settingsDifficultyLocked =>
      'Termine o jogo atual para mudar a dificuldade.';

  @override
  String get settingsCurrentSize => 'Tamanho atual';

  @override
  String get settingsBoardSizeLocked =>
      'Conclua o jogo atual para mudar o tamanho do tabuleiro';

  @override
  String get settingsCurrentDuration => 'Duração atual';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Por quanto tempo mostrar a explicação da colisão';

  @override
  String get settingsScreenShake => 'Tremor de tela';

  @override
  String get settingsScreenShakeSubtitle =>
      'Tremer a tela em colisões e eventos do jogo';

  @override
  String get settingsVibration => 'Vibração';

  @override
  String get settingsVibrationSubtitle =>
      'Vibrar em eventos do jogo e toques de botão';

  @override
  String get settingsSoundEffects => 'Efeitos sonoros';

  @override
  String get settingsBackgroundMusic => 'Música de fundo';

  @override
  String get settingsCurrentTheme => 'Tema atual';

  @override
  String get settingsBrowseThemes => 'VER TEMAS';

  @override
  String get settingsSnakeTrail => 'Efeitos de rastro da cobra';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Ativar rastros de partículas atrás da cobra';

  @override
  String get settingsNotifDailyReminder => 'Lembrete diário';

  @override
  String get settingsNotifTournament => 'Alertas de torneio';

  @override
  String get settingsNotifAchievement => 'Conquistas desbloqueadas';

  @override
  String get settingsNotifSocial => 'Atualizações sociais';

  @override
  String get settingsNotifSpecialEvents => 'Eventos especiais';

  @override
  String get settingsNotSet => 'Não definido';

  @override
  String get settingsUsername => 'Nome de usuário';

  @override
  String get settingsGuestAccount => 'Conta de convidado';

  @override
  String get settingsAuthenticatedAccount => 'Conta autenticada';

  @override
  String get settingsChangeUsername => 'MUDAR NOME DE USUÁRIO';

  @override
  String get settingsGuestSignInHint =>
      'Entre para manter seu progresso e jogar com amigos';

  @override
  String get settingsUsernameVisibleHint =>
      'Seu nome de usuário fica visível para amigos e nos rankings';

  @override
  String get settingsReplayTutorial => 'REPETIR TUTORIAL';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Assista de novo ao tour inicial ou ao tutorial do jogo';

  @override
  String get settingsAboutCredits => 'SOBRE E CRÉDITOS';

  @override
  String get settingsAboutCreditsSubtitle => 'Versão do app, créditos e links';

  @override
  String get settingsRateApp => 'AVALIE SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'Gostando do jogo? Deixe uma avaliação na App Store';

  @override
  String get settingsRateAppSubtitle =>
      'Gostando do jogo? Deixe sua avaliação!';

  @override
  String get settingsAdPrivacy => 'PRIVACIDADE E ANÚNCIOS';

  @override
  String get settingsAdPrivacySubtitle =>
      'Gerenciar consentimento de anúncios personalizados';

  @override
  String get settingsAdPrivacyUnavailable =>
      'As opções de privacidade de anúncios não estão disponíveis agora.';

  @override
  String get settingsReplayDialogTitle => 'Repetir tutorial';

  @override
  String get settingsReplayDialogBody => 'Qual tutorial você quer repetir?';

  @override
  String get settingsHomeTour => 'Tour inicial';

  @override
  String get settingsGameTutorial => 'Tutorial do jogo';

  @override
  String get settingsPrivacyPolicyTitle => 'Política de Privacidade';

  @override
  String get settingsPrivacyPolicyButton => 'POLÍTICA DE PRIVACIDADE';

  @override
  String get settingsTermsTitle => 'Termos de Uso';

  @override
  String get settingsTermsButton => 'TERMOS DE USO';

  @override
  String get settingsChangeUsernameTitle => 'Mudar nome de usuário';

  @override
  String get settingsCurrentLabel => 'Atual:';

  @override
  String get settingsUsernameDialogBody =>
      'Escolha um nome de usuário único que represente você no jogo.';

  @override
  String get settingsEnterNewUsername => 'Digite o novo nome de usuário';

  @override
  String get settingsUsernameRules =>
      '• 3-20 caracteres\n• Deve começar com uma letra\n• Apenas letras, números e sublinhados';

  @override
  String get settingsUsernameUpdateFailed =>
      'Falha ao atualizar o nome de usuário';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Nome de usuário alterado para \"$name\"';
  }

  @override
  String get settingsUpdate => 'Atualizar';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Status premium';

  @override
  String get settingsActiveSubscription => 'Assinatura ativa';

  @override
  String get settingsUnlockPremium => 'Desbloqueie recursos premium';

  @override
  String settingsRenews(String date) {
    return 'Renova em $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Assinar o Pro';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsPurchaseHistory => 'Histórico de compras';

  @override
  String get settingsSnakeCosmetics => 'Visuais da cobra';

  @override
  String get settingsBattlePass => 'Passe de Batalha';

  @override
  String settingsTier(int tier) {
    return 'Nível $tier';
  }

  @override
  String get settingsRestoring => 'Restaurando compras...';

  @override
  String get settingsRestored => 'Compras restauradas com sucesso!';

  @override
  String get settingsRestoreFailed =>
      'Falha ao restaurar compras. Tente novamente.';

  @override
  String get settingsNoPurchases => 'Nenhuma compra encontrada';

  @override
  String get settingsUnknown => 'Desconhecido';

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
    return 'Compra n° $number';
  }

  @override
  String get settingsDataParseError => 'Erro ao ler os dados';

  @override
  String get settingsClose => 'Fechar';

  @override
  String get settingsHistoryLoadFailed =>
      'Falha ao carregar o histórico de compras';

  @override
  String get settingsUnknownDate => 'Data desconhecida';
}
