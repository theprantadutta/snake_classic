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
  String get mpRewardProcessing => 'Processando recompensas…';

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
  String get accountSwitchTitle => 'Entrar em uma conta existente?';

  @override
  String get accountSwitchBody =>
      'Se esta conta já jogou Snake Classic, o progresso dela será restaurado e passará a ser o seu. Moedas, pontuações e estatísticas deste aparelho não são transferidas.\n\nPara manter o progresso deste aparelho, use uma conta com a qual você ainda não jogou.';

  @override
  String get accountSwitchConfirm => 'Entrar mesmo assim';

  @override
  String get settingsAuthenticatedAccount => 'Conta autenticada';

  @override
  String get accountNotBackedUpTitle => 'Sem backup';

  @override
  String get accountNotBackedUpBody =>
      'Este progresso está vinculado a esta instalação. Faça login para recuperá-lo após reinstalar ou em um celular novo.';

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
  String get legalAutoRenewDisclosureAppStore =>
      'O pagamento é cobrado na sua conta da App Store no momento da confirmação da compra. A assinatura é renovada automaticamente pelo mesmo preço e pelo mesmo período, a menos que seja cancelada pelo menos 24 horas antes do fim do período atual. Gerencie ou cancele quando quiser nas configurações da sua conta após a compra.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'O pagamento é cobrado na sua conta do Google Play no momento da confirmação da compra. A assinatura é renovada automaticamente pelo mesmo preço e pelo mesmo período, a menos que seja cancelada pelo menos 24 horas antes do fim do período atual. Gerencie ou cancele quando quiser nas configurações de assinaturas do Google Play após a compra.';

  @override
  String get legalTermsEulaLink => 'Termos de Uso (EULA)';

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

  @override
  String get mpLobbyNoFriends =>
      'Ainda sem amigos — adicione alguns na tela de Amigos!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Convide um amigo para a sala $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 Convite enviado para $name!';
  }

  @override
  String get mpLobbyInviteFailed =>
      'Não foi possível enviar o convite — tente de novo';

  @override
  String get mpLobbyOffline =>
      'Você está offline. O multijogador precisa de internet.';

  @override
  String get mpLobbyDismiss => 'FECHAR';

  @override
  String get mpLobbyGo => 'VAI!';

  @override
  String get mpLobbyGetReady => 'Prepare-se!';

  @override
  String get mpLobbyTitle => 'MULTIJOGADOR';

  @override
  String get mpLobbySubtitle => 'Jogue online com amigos';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Sala: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'Código da sala copiado!';

  @override
  String get mpLobbyQuickMatch => 'PARTIDA RÁPIDA';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      '1v1 Clássico — encontre um adversário automaticamente';

  @override
  String get mpLobbyFinding => 'BUSCANDO...';

  @override
  String get mpLobbyFindMatch => 'BUSCAR PARTIDA';

  @override
  String get mpLobbySeconds => 'seg';

  @override
  String get mpLobbySearching => 'PROCURANDO JOGADORES...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogadores',
      one: '$count jogador',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Posição na fila: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'CANCELAR';

  @override
  String get mpLobbyUnreachableTitle => 'SEM LIGAÇÃO AO MATCHMAKING';

  @override
  String get mpLobbyUnreachableBody =>
      'Não conseguimos contactar o servidor.\nVerifique sua conexão e tente de novo.';

  @override
  String get mpLobbyGoBack => 'VOLTAR';

  @override
  String get mpLobbyTryAgain => 'TENTAR DE NOVO';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count V';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count D';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count E';
  }

  @override
  String get mpLobbyWinsLabel => 'Vitórias';

  @override
  String get mpLobbyLossesLabel => 'Derrotas';

  @override
  String get mpLobbyDrawsLabel => 'Empates';

  @override
  String get mpLobbyRatingLabel => 'Pontos';

  @override
  String get mpLobbyJoinRoom => 'ENTRAR NA SALA';

  @override
  String get mpLobbyJoinSubtitle => 'Digite o código da sala para entrar';

  @override
  String get mpLobbyEnterRoomCode => 'Digite o código da sala';

  @override
  String get mpLobbyCreateRoom => 'CRIAR SALA';

  @override
  String get mpLobbyCreateSubtitle => 'Crie uma sala 1v1 e convide um amigo';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'JOGADORES ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'VOCÊ';

  @override
  String get mpLobbyWaitingForPlayer => 'Aguardando jogador...';

  @override
  String get mpLobbyStartGame => 'INICIAR PARTIDA';

  @override
  String get mpLobbyWaitingForHost => 'Aguardando o anfitrião iniciar...';

  @override
  String get mpLobbyLeave => 'SAIR';

  @override
  String get mpLobbyReadyDone => 'PRONTO!';

  @override
  String get mpLobbyReady => 'PRONTO';

  @override
  String get mpModeClassicDesc => 'Batalha de cobras tradicional';

  @override
  String get mpModeSpeedDesc => 'A velocidade aumenta com o tempo';

  @override
  String get mpModeSurvivalDesc => 'A última cobra de pé vence';

  @override
  String get mpModePowerUpDesc => 'Power-ups por toda parte!';

  @override
  String get mpStatusWaiting => 'Aguardando';

  @override
  String get mpStatusReady => 'Pronto';

  @override
  String get mpStatusPlaying => 'Jogando';

  @override
  String get mpStatusCrashed => 'Bateu';

  @override
  String get mpStatusDisconnected => 'Desconectado';

  @override
  String get goNoAdAvailable =>
      'Nenhum anúncio disponível agora, tente em instantes';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Moedas dobradas — +$count moedas de bônus!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'Assista para dobrar suas $count moedas';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins moedas  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'Você resgatou $count moedas dos desafios diários!';
  }

  @override
  String get goRibbonNewHighScore => 'NOVO RECORDE!';

  @override
  String get goRibbonTournamentSubmitted => 'PONTUAÇÃO DO TORNEIO ENVIADA!';

  @override
  String get goRibbonTournamentFailed =>
      'PONTUAÇÃO NÃO ENVIADA — VERIFIQUE A CONEXÃO';

  @override
  String get goRibbonTournamentSubmitting => 'ENVIANDO PONTUAÇÃO DO TORNEIO…';

  @override
  String get goVictory => 'VITÓRIA!';

  @override
  String get goGameOver => 'FIM DE JOGO';

  @override
  String get goFinalScore => 'PONTUAÇÃO FINAL';

  @override
  String get goLevel => 'NÍVEL';

  @override
  String get goBest => 'RECORDE';

  @override
  String get goCoinsEarned => 'Moedas ganhas';

  @override
  String get goDailyRewardsReady => 'RECOMPENSAS DIÁRIAS PRONTAS';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recompensas',
      one: '$count recompensa',
    );
    return '$_temp0  •  +$coins moedas  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'RESGATAR TUDO';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'Resgatar';

  @override
  String get goAchievements => 'CONQUISTAS';

  @override
  String get goRecentlyUnlocked => 'Desbloqueadas recentemente';

  @override
  String get goInProgress => 'Em andamento';

  @override
  String get goPlayAgain => 'JOGAR DE NOVO';

  @override
  String get goMenu => 'MENU';

  @override
  String get storeTitle => 'Loja Snake';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Moedas';

  @override
  String get storeTabThemes => 'Temas';

  @override
  String get storeTabSkins => 'Skins';

  @override
  String get storeTabTrails => 'Rastros';

  @override
  String get storeTabPowerUps => 'Power-Ups';

  @override
  String get storeYourCoins => 'Suas Moedas Snake';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'BÔNUS ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Assine antes do seu Pro grátis acabar';

  @override
  String get storeChooseYourPlan => 'Escolha seu plano';

  @override
  String get storeWhatYouGet => 'O que você recebe';

  @override
  String get storeProHeroSubtitle =>
      'Todos os temas, skins e rastros premium · tabuleiros grandes · 2× moedas · power-ups premium · entradas de torneio · Passe de Batalha Premium';

  @override
  String get storeMonthly => 'Mensal';

  @override
  String get storeYearly => 'Anual';

  @override
  String get storePerMonth => '/mês';

  @override
  String get storePerYear => '/ano';

  @override
  String get storeSave17 => 'Economize 17%';

  @override
  String storePlanDisplayName(Object title) {
    return 'plano $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Verificando…';

  @override
  String get storeSubscribe => 'Assinar';

  @override
  String get storeYoureOnFreePro => 'Você está no Pro grátis!';

  @override
  String get storeYourePro => 'Você é Pro!';

  @override
  String get storeFreePro => 'Pro grátis';

  @override
  String get storeProMonthly => 'Pro Mensal';

  @override
  String get storeKeepPro => 'Manter o Pro — Assinar';

  @override
  String get storePromoBadge => 'PROMO';

  @override
  String get storeEndingSoon => 'Acabando em breve';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Acaba em ${days}d ${hours}h';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Acaba em ${hours}h ${minutes}min';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Acaba em ${minutes}min';
  }

  @override
  String get storeFeatureExtraLife =>
      'Vida extra sempre grátis — reviva em toda partida, sem anúncio, sem moedas';

  @override
  String get storeFeatureNoAds =>
      'Sem anúncios — jogue totalmente livre de anúncios';

  @override
  String get storeFeatureThemes => 'Todos os 6 temas premium';

  @override
  String get storeFeatureSkins => 'Todas as 11 skins premium';

  @override
  String get storeFeatureTrails => 'Todos os 11 rastros premium';

  @override
  String get storeFeatureBoards => 'Tabuleiros premium (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => 'Ganho de moedas 2×';

  @override
  String get storeFeaturePowerUps => '5× power-ups premium por ciclo';

  @override
  String get storeFeatureTournaments =>
      'Entradas de torneio Bronze + Prata + Ouro por ciclo';

  @override
  String get storeFeatureBattlePass =>
      'Trilha Premium do Passe de Batalha em toda temporada';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Iniciando compra de $name...';
  }

  @override
  String get storeSubNotAvailable =>
      'Assinatura indisponível. Tente novamente mais tarde.';

  @override
  String get storePurchaseFailed => 'Compra falhou. Tente novamente.';

  @override
  String get storeBuyCoins => 'Comprar Moedas Snake';

  @override
  String get storeEarnFreeCoins => 'Ganhe moedas grátis';

  @override
  String get storeEarnPlay => 'Jogue uma partida';

  @override
  String get storeEarnPlayReward => '5 moedas por partida';

  @override
  String get storeEarnDaily => 'Login diário';

  @override
  String get storeEarnDailyReward => '10-50 moedas por dia';

  @override
  String get storeEarnAchievements => 'Conquistas';

  @override
  String get storeEarnAchievementsReward => '25-100 moedas';

  @override
  String get storeEarnTournaments => 'Torneios';

  @override
  String get storeEarnTournamentsReward => '100+ moedas';

  @override
  String get storePopularBadge => 'POPULAR';

  @override
  String storeBuyItem(Object name) {
    return 'Comprar $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'Comprar $coins por $price?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'Comprar - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'Iniciando compra de $name...';
  }

  @override
  String get storeProductNotAvailable =>
      'Produto indisponível. Tente novamente mais tarde.';

  @override
  String get storeUnlockedWithPro => 'Desbloqueado com o Pro';

  @override
  String get storeIncludedWithPro => 'Incluído no Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned =>
      'Todos os temas daqui são seus com a assinatura.';

  @override
  String get storeProBannerThemesUpsell =>
      'Assine o Pro para desbloquear todos os temas daqui — sem compra separada.';

  @override
  String get storeProBannerSkinsOwned =>
      'Todas as skins daqui são suas com a assinatura.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Assine o Pro para desbloquear todas as skins daqui — sem compra separada.';

  @override
  String get storeProBannerTrailsOwned =>
      'Todos os rastros daqui são seus com a assinatura.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Assine o Pro para desbloquear todos os rastros daqui — sem compra separada.';

  @override
  String get storePremiumThemes => 'Temas premium';

  @override
  String get storeFreeThemes => 'Temas grátis';

  @override
  String get storeFreeThemesSubtitle =>
      'Sempre disponíveis — volte quando quiser.';

  @override
  String get storeAllThemesBundle => 'Pacote de Todos os Temas';

  @override
  String get storeAllThemesBundleSubtitle =>
      'Todos os 6 temas premium · economize 33%';

  @override
  String get storePillVerifying => 'VERIFICANDO';

  @override
  String get storePillOwned => 'SEU';

  @override
  String get storePillFree => 'GRÁTIS';

  @override
  String get storePillActive => 'ATIVO';

  @override
  String get storePillApply => 'APLICAR';

  @override
  String get storePillEquipped => 'EQUIPADO';

  @override
  String get storePillEquip => 'EQUIPAR';

  @override
  String get storeThemeDescClassic => 'O visual original';

  @override
  String get storeThemeDescModern => 'Limpo e minimalista';

  @override
  String get storeThemeDescNeon => 'Noites de néon brilhante';

  @override
  String get storeThemeDescRetro => 'Fliperama néon anos 80';

  @override
  String get storeThemeDescSpace => 'Campo de estrelas cósmico';

  @override
  String get storeThemeDescOcean => 'Azuis do fundo do mar';

  @override
  String get storeThemeDescCyberpunk => 'Ciano elétrico e rosa';

  @override
  String get storeThemeDescForest => 'Selva esmeralda vívida';

  @override
  String get storeThemeDescDesert => 'Cânion e cacto turquesa';

  @override
  String get storeThemeDescCrystal => 'Azul cristalino gelado';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'Desbloquear $name por $price?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Verificando compra de $name…';
  }

  @override
  String get storeThemeNotAvailable =>
      'Tema indisponível. Tente novamente mais tarde.';

  @override
  String get storeItemNotAvailable =>
      'Item indisponível. Tente novamente mais tarde.';

  @override
  String storeEquippedToast(Object name) {
    return '$name equipado';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 Impulso de Velocidade grátis adicionado ao seu inventário!';

  @override
  String get storeWatchAdTitle =>
      'Assista a um anúncio — Impulso de Velocidade grátis';

  @override
  String get storeWatchAdReady =>
      'Adiciona 1 Impulso de Velocidade ao seu equipamento';

  @override
  String get storeWatchAdNotReady => 'Nenhum anúncio disponível agora';

  @override
  String get puSpeedBoostDesc =>
      'Aumenta a velocidade da cobra por 7 segundos.';

  @override
  String get puInvincibilityDesc =>
      'Atravesse paredes e você mesmo por 6 segundos.';

  @override
  String get puScoreMultiplierDesc => 'Pontos em dobro por 10 segundos.';

  @override
  String get puSlowMotionDesc =>
      'Deixa o jogo lento para mais precisão (8 segundos).';

  @override
  String get storePowerUpsInfo =>
      'Compre com moedas e depois equipe um no chip de equipamento da tela inicial — ele ativa 5s após o início do próximo jogo.';

  @override
  String get storePowerUps => 'Power-Ups';

  @override
  String get storePowerUpBundles => 'Pacotes de Power-Ups';

  @override
  String get storeBundlesSubtitle =>
      'Desbloqueie vários tipos de power-up com desconto.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'Moedas insuficientes!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'Comprar 1 $name por $cost moedas?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Comprar - $cost moedas';
  }

  @override
  String get storePurchaseFailedRetry => 'Compra falhou. Tente de novo.';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name adicionado ao seu equipamento!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count moedas';
  }

  @override
  String get storeBuyUpper => 'COMPRAR';

  @override
  String get storeNeedCoins => 'FALTAM MOEDAS';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name desbloqueado!';
  }

  @override
  String get modeClassic => 'Clássico';

  @override
  String get modeZen => 'Modo Zen';

  @override
  String get modeSpeedChallenge => 'Desafio de Velocidade';

  @override
  String get modeMultiFood => 'Multi-Comida';

  @override
  String get modeSurvival => 'Sobrevivência';

  @override
  String get modeTimeAttack => 'Contra o Tempo';

  @override
  String get modePowerUpMadness => 'Loucura de Power-Ups';

  @override
  String get modePerfectGame => 'Jogo Perfeito';

  @override
  String get modeClassicDesc => 'O clássico jogo da cobra com paredes';

  @override
  String get modeZenDesc => 'Sem paredes - a cobra atravessa a tela';

  @override
  String get modeSpeedChallengeDesc =>
      'A velocidade aumenta rápido para o desafio máximo';

  @override
  String get modeMultiFoodDesc => 'Várias comidas aparecem ao mesmo tempo';

  @override
  String get modeSurvivalDesc =>
      'Sobreviva o máximo possível com vidas limitadas';

  @override
  String get modeTimeAttackDesc => 'Pontue o máximo possível em tempo limitado';

  @override
  String get modePowerUpMadnessDesc =>
      'Power-ups surgem com muito mais frequência — abrace o caos';

  @override
  String get modePerfectGameDesc =>
      'Nunca cruze seu próprio rastro. Um passo numa célula visitada encerra a partida.';

  @override
  String get diffEasy => 'Fácil';

  @override
  String get diffNormal => 'Normal';

  @override
  String get diffHard => 'Difícil';

  @override
  String get diffEasyDesc =>
      'Uma cobra mais lenta no início. Pontuações ficam fora dos rankings.';

  @override
  String get diffNormalDesc => 'O ritmo original do Snake Classic.';

  @override
  String get diffHardDesc => 'Começa rápido e só acelera.';

  @override
  String get themeClassic => 'Clássico';

  @override
  String get themeModern => 'Moderno';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeRetro => 'Retrô';

  @override
  String get themeSpace => 'Espaço';

  @override
  String get themeOcean => 'Oceano';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeForest => 'Floresta';

  @override
  String get themeDesert => 'Deserto';

  @override
  String get themeCrystal => 'Cristal';

  @override
  String get dpadLeft => 'Esquerda';

  @override
  String get dpadCenter => 'Centro';

  @override
  String get dpadRight => 'Direita';

  @override
  String get mpModeClassicBattle => 'Batalha Clássica';

  @override
  String get mpModeSpeedRun => 'Corrida Veloz';

  @override
  String get mpModeSurvivalMode => 'Modo Sobrevivência';

  @override
  String get mpModePowerUpMadnessName => 'Loucura de Power-Ups';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonViewAll => 'Ver tudo';

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get pfTitle => 'Perfil';

  @override
  String get pfSigningOut => 'Saindo...';

  @override
  String get pfGuestPlayer => 'Jogador convidado';

  @override
  String get pfVerifiedAccount => 'Conta verificada';

  @override
  String get pfStatistics => 'Estatísticas';

  @override
  String get pfReplays => 'Replays';

  @override
  String get pfAchievements => 'Conquistas';

  @override
  String get pfLoadingStats => 'Carregando estatísticas...';

  @override
  String get pfHighScore => 'Recorde';

  @override
  String get pfGamesPlayed => 'Partidas jogadas';

  @override
  String get pfPlayTime => 'Tempo de jogo';

  @override
  String get pfAverageScore => 'Pontuação média';

  @override
  String get pfFoodConsumed => 'Comida consumida';

  @override
  String get pfPowerUps => 'Power-ups';

  @override
  String get pfUpgradeTitle => 'Migrar para conta Google';

  @override
  String get pfUpgradeSubtitle =>
      'Salve seu progresso e sincronize entre dispositivos';

  @override
  String get pfBenefitSync => 'Sincronizar progresso';

  @override
  String get pfBenefitSyncSub => 'entre dispositivos';

  @override
  String get pfBenefitLeaderboards => 'Rankings globais';

  @override
  String get pfBenefitLeaderboardsSub => 'dispute com o mundo todo';

  @override
  String get pfBenefitSocial => 'Amigos e social';

  @override
  String get pfBenefitSocialSub => 'conecte-se com outros';

  @override
  String get pfSignInGoogle => 'Entrar com o Google';

  @override
  String get pfSignInApple => 'Entrar com a Apple';

  @override
  String get pfNoReplays => 'Nenhum replay ainda. Jogue algumas partidas!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replays salvos',
      one: '$count replay salvo',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Gerenciamento da conta';

  @override
  String get pfSignOut => 'Sair';

  @override
  String get pfDeleteAccount => 'Excluir conta';

  @override
  String get pfAppleUpgradeSuccess =>
      'Conta migrada para a Apple com sucesso! 🎉';

  @override
  String get pfAppleIdInUse =>
      'Esse ID Apple já tem uma conta. Saia e entre com a Apple.';

  @override
  String get pfUpgradeFailed => 'Falha ao migrar a conta. Tente novamente.';

  @override
  String get pfUpgradeError => 'Ocorreu um erro durante a migração da conta.';

  @override
  String get pfGoogleUpgradeSuccess =>
      'Conta migrada para o Google com sucesso! 🎉';

  @override
  String get pfDeleteAccountTitle => 'Excluir conta?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'Isto exclui permanentemente sua conta e tudo ligado a ela:\n\n• Recordes e estatísticas\n• Moedas e itens comprados\n• Temas, skins, rastros e power-ups\n• Progresso do passe de batalha e desafios\n• Entradas de ranking e amigos\n\nIsto não pode ser desfeito. Assinaturas ativas devem ser canceladas separadamente nas configurações da $storeName.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'loja de apps do dispositivo';

  @override
  String get pfAccountDeleted => 'Sua conta foi excluída permanentemente.';

  @override
  String get pfDeleteFailed =>
      'Não foi possível excluir sua conta. Verifique a conexão e tente de novo.';

  @override
  String get pfDeleteForever => 'Excluir para sempre';

  @override
  String get pfSignOutBody =>
      'Tem certeza de que quer sair?\n\nSeu progresso ficará salvo se você estiver com uma conta Google.';

  @override
  String get pfSignedOut => 'Você saiu com sucesso 👋';

  @override
  String get stLoading => 'Carregando estatísticas...';

  @override
  String get stPerformanceOverview => 'Visão geral de desempenho';

  @override
  String get stTotalGames => 'Total de partidas';

  @override
  String get stWinStreak => 'Sequência de vitórias';

  @override
  String get stGameActivity => 'Atividade de jogo';

  @override
  String get stLongestGame => 'Partida mais longa';

  @override
  String get stHighestLevel => 'Nível mais alto';

  @override
  String get stPerfectGames => 'Partidas perfeitas';

  @override
  String get stFoodPowerUps => 'Comida e power-ups';

  @override
  String get stPowerUpsUsed => 'Power-ups usados';

  @override
  String get stFavoriteFood => 'Comida favorita';

  @override
  String get stFavoritePowerUp => 'Power-up favorito';

  @override
  String get stPerformanceTrends => 'Tendências de desempenho';

  @override
  String get stOverallTrend => 'Tendência geral';

  @override
  String get stRecentAverage => 'Média recente';

  @override
  String get stBestRecent => 'Melhor recente';

  @override
  String get stConsistency => 'Consistência';

  @override
  String get stScores => 'Pontuações';

  @override
  String get stTrendLine => 'Linha de tendência';

  @override
  String get stPlayPatterns => 'Padrões de jogo (últimos 7 dias)';

  @override
  String get stWeeklyTime => 'Tempo semanal';

  @override
  String get stMostActiveDay => 'Dia mais ativo';

  @override
  String get stDailyActivity => 'Atividade diária';

  @override
  String get stAchievementProgress => 'Progresso de conquistas';

  @override
  String get stViewAllAchievements => 'Ver todas as conquistas →';

  @override
  String get stViewAchievements => 'VER CONQUISTAS';

  @override
  String get stReplaysUpper => 'REPLAYS';

  @override
  String get stResetStatistics => 'REDEFINIR ESTATÍSTICAS';

  @override
  String get stResetTitle => 'Redefinir estatísticas?';

  @override
  String get stResetBody =>
      'Isto excluirá permanentemente todas as suas estatísticas de jogo. Esta ação não pode ser desfeita.';

  @override
  String get stReset => 'Redefinir';

  @override
  String get stNA => 'N/D';

  @override
  String get stExcellent => 'Excelente';

  @override
  String get stGood => 'Bom';

  @override
  String get stFair => 'Razoável';

  @override
  String get stPoor => 'Fraco';

  @override
  String get stNoData => 'Sem dados';

  @override
  String get stNone => 'Nenhum';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '$count partida',
    );
    return 'Progresso (últimas $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent concluído';
  }

  @override
  String get stInsights => 'Insights de desempenho';

  @override
  String get stInsightPlayMore =>
      'Jogue mais partidas para receber insights de desempenho!';

  @override
  String get stInsightImproving =>
      'Ótimo trabalho! Seu desempenho está em alta.';

  @override
  String get stInsightAboveAverage =>
      'Suas partidas recentes estão bem acima da sua média.';

  @override
  String get stInsightDeclined =>
      'Seu desempenho caiu recentemente. Considere praticar mais.';

  @override
  String get stInsightPractice =>
      'Concentre-se em evitar colisões e planejar seus movimentos.';

  @override
  String get stInsightStable =>
      'Seu desempenho está estável. Desafie-se a melhorar!';

  @override
  String get stInsightPotential =>
      'Você tem potencial para recordes - trabalhe a consistência.';

  @override
  String get stInsightSolid =>
      'Você mantém um desempenho sólido nas partidas recentes.';

  @override
  String get frTitle => 'Amigos';

  @override
  String get frBlockedUsers => 'Usuários bloqueados';

  @override
  String get frSearchHint => 'Buscar por nome ou e-mail...';

  @override
  String get frSearching => 'Buscando...';

  @override
  String get frSearchTitle => 'Buscar amigos';

  @override
  String get frSearchSubtitle =>
      'Digite um nome ou e-mail para encontrar amigos';

  @override
  String get frNoUsersFound => 'Nenhum usuário encontrado';

  @override
  String get frNoUsersFoundSub => 'Tente buscar com outro nome ou e-mail';

  @override
  String get frRequests => 'Pedidos';

  @override
  String get frSearch => 'Buscar';

  @override
  String get frNoCacheYet => 'Sem cache ainda';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Atualizado $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · falha ao atualizar, toque para tentar de novo';
  }

  @override
  String get frJustNow => 'agora mesmo';

  @override
  String frSecondsAgo(Object count) {
    return 'há ${count}s';
  }

  @override
  String frMinutesAgo(Object count) {
    return 'há ${count}min';
  }

  @override
  String frHoursAgo(Object count) {
    return 'há ${count}h';
  }

  @override
  String frDaysAgo(Object count) {
    return 'há ${count}d';
  }

  @override
  String get frLoadingFriends => 'Carregando amigos...';

  @override
  String get frNoFriendsYet => 'Nenhum amigo ainda';

  @override
  String get frNoFriendsSub => 'Busque usuários para adicionar como amigos!';

  @override
  String get frNoRequests => 'Nenhum pedido de amizade';

  @override
  String get frNoRequestsSub => 'Pedidos de amizade aparecerão aqui';

  @override
  String get frChallengeMenu => 'Desafiar para uma partida';

  @override
  String get frViewProfile => 'Ver perfil';

  @override
  String get frRemoveFriend => 'Remover amigo';

  @override
  String get frBlockUser => 'Bloquear usuário';

  @override
  String frReceivedHeader(Object count) {
    return 'Recebidos ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Enviados ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '$count partida',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'Enviado $date';
  }

  @override
  String get frPending => 'Pendente';

  @override
  String get frCancelRequest => 'Cancelar pedido';

  @override
  String get frReject => 'Recusar';

  @override
  String get frAccept => 'Aceitar';

  @override
  String get frAlreadyFriends => '✓ Amigos';

  @override
  String get frAddFriend => 'Adicionar';

  @override
  String get frSendRequestFailed =>
      'Não foi possível enviar o pedido — verifique a conexão e tente de novo';

  @override
  String get frAcceptFailed =>
      'Não foi possível aceitar o pedido — verifique a conexão e tente de novo';

  @override
  String get frRejectFailed =>
      'Não foi possível recusar o pedido — verifique a conexão e tente de novo';

  @override
  String get frCancelFailed =>
      'Não foi possível cancelar o pedido — verifique a conexão e tente de novo';

  @override
  String get frBlockFailed =>
      'Não foi possível bloquear o usuário — verifique a conexão e tente de novo';

  @override
  String get frSignInSocial =>
      'Entre para adicionar amigos e usar os recursos sociais';

  @override
  String get frRequestSent => 'Pedido de amizade enviado!';

  @override
  String get frRequestAccepted => 'Pedido de amizade aceito!';

  @override
  String get frRequestRejected => 'Pedido de amizade recusado';

  @override
  String get frRequestCancelled => 'Pedido de amizade cancelado';

  @override
  String frChallengeSent(Object name) {
    return '🎮 Desafio enviado para $name!';
  }

  @override
  String get frChallengeFailed =>
      'Não foi possível enviar o desafio — tente de novo';

  @override
  String frBlocked(Object name) {
    return '$name bloqueado';
  }

  @override
  String frUnblocked(Object name) {
    return '$name desbloqueado';
  }

  @override
  String get frUnblockFailed => 'Não foi possível desbloquear — tente de novo';

  @override
  String frRemoved(Object name) {
    return '$name removido dos amigos';
  }

  @override
  String frBlockTitle(Object name) {
    return 'Bloquear $name?';
  }

  @override
  String get frBlockBody =>
      'A pessoa será removida dos seus amigos e não poderá enviar pedidos de amizade nem desafios. Ela não será notificada.';

  @override
  String get frBlock => 'Bloquear';

  @override
  String get frNoBlocked => 'Você não bloqueou ninguém.';

  @override
  String get frUnblock => 'Desbloquear';

  @override
  String frHighScoreLine(Object score) {
    return 'Recorde: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Total de partidas: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Nível: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Status: \"$status\"';
  }

  @override
  String frRemoveBody(Object name) {
    return 'Remover $name da sua lista de amigos?';
  }

  @override
  String get frRemove => 'Remover';

  @override
  String get frLeaderboardTitle => 'Ranking de amigos';

  @override
  String get frLeaderboardSubtitle => 'Dispute com seus amigos';

  @override
  String get frLoadingLeaderboard => 'Carregando ranking...';

  @override
  String frRankBadge(Object rank) {
    return 'nº $rank';
  }

  @override
  String get frYou => 'VOCÊ';

  @override
  String get frLeaderboardEmptySub =>
      'Adicione amigos para ver seu ranking privado!';

  @override
  String get frAddFriends => 'Adicionar amigos';

  @override
  String get tnTitle => 'Torneios';

  @override
  String get tnActive => 'Ativos';

  @override
  String get tnHistory => 'Histórico';

  @override
  String get tnMyStats => 'Minhas estatísticas';

  @override
  String get tnLoading => 'Carregando torneios...';

  @override
  String get tnNoActive => 'Nenhum torneio ativo';

  @override
  String get tnNoActiveSub => 'Volte mais tarde para novos torneios!';

  @override
  String get tnNoHistory => 'Sem histórico de torneios';

  @override
  String get tnNoHistorySub => 'Participe de torneios para ver seu histórico!';

  @override
  String get tnNoStats => 'Sem estatísticas de torneio';

  @override
  String get tnNoStatsSub =>
      'Participe de torneios para acompanhar seu progresso!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max jogadores';
  }

  @override
  String get tnJoined => 'Inscrito';

  @override
  String tnBestScoreChip(Object score) {
    return 'Melhor: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Posição nº $rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recompensas disponíveis',
      one: '$count recompensa disponível',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'Ver detalhes →';

  @override
  String get tnOverviewCard => 'Visão geral de torneios';

  @override
  String get tnWins => 'Vitórias';

  @override
  String get tnTopThree => 'Top 3';

  @override
  String get tnBestScore => 'Melhor pontuação';

  @override
  String get tnDetailedStats => 'Estatísticas detalhadas';

  @override
  String get tnTotalAttempts => 'Tentativas totais';

  @override
  String get tnWinRate => 'Taxa de vitórias';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'Desempenho médio';

  @override
  String tnTopPercent(Object percent) {
    return 'Top $percent%';
  }

  @override
  String get tnNotFound => 'Torneio não encontrado';

  @override
  String get tnLoadFailed => 'Falha ao carregar o torneio';

  @override
  String get tnLoadingTournament => 'Carregando torneio...';

  @override
  String get tnGoBack => 'Voltar';

  @override
  String get tnParticipating => 'Você está participando!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Melhor: $score • Tentativas: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Posição nº $rank';
  }

  @override
  String get tnOverview => 'Visão geral';

  @override
  String get tnLeaderboard => 'Ranking';

  @override
  String get tnRules => 'Regras';

  @override
  String get tnLeaderboardFailed => 'Não foi possível carregar o ranking';

  @override
  String get tnCheckConnection => 'Verifique a conexão e tente de novo.';

  @override
  String get tnNoParticipants => 'Nenhum participante ainda';

  @override
  String get tnBeFirst => 'Seja o primeiro a entrar!';

  @override
  String get tnDescription => 'Descrição';

  @override
  String get tnRewards => 'Recompensas';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativas',
      one: '$count tentativa',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Regras do torneio';

  @override
  String get tnScoringSystem => 'Sistema de pontuação';

  @override
  String get tnScoringBody =>
      'Sua maior pontuação durante o período do torneio contará para a classificação final. Você pode jogar várias vezes para melhorar sua pontuação.';

  @override
  String get tnJoining => 'ENTRANDO…';

  @override
  String get tnJoin => 'ENTRAR NO TORNEIO';

  @override
  String get tnPlayNow => 'JOGAR AGORA';

  @override
  String get tnProUnlimited => 'Pro · Entradas ilimitadas';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Entradas restantes: $count';
  }

  @override
  String get tnNoEntries => 'Sem entradas — toque em ENTRAR para comprar';

  @override
  String tnStarts(Object time) {
    return 'Começa $time';
  }

  @override
  String get tnRule1 =>
      'Jogue durante o período do torneio para que suas pontuações contem';

  @override
  String get tnRule2 =>
      'Você pode jogar várias vezes - só a maior pontuação conta';

  @override
  String get tnRule3 => 'É preciso estar conectado para participar';

  @override
  String get tnRule4 =>
      'A classificação final é definida ao término do torneio';

  @override
  String get tnRuleSpeed =>
      'A velocidade do jogo aumenta rápido a cada 10 pontos';

  @override
  String get tnRuleSurvival =>
      'A pontuação é baseada no tempo de sobrevivência, não na comida';

  @override
  String get tnRuleNoWalls =>
      'A cobra atravessa as bordas da tela em vez de bater nas paredes';

  @override
  String get tnRulePowerUps => 'Power-ups surgem a cada 5 segundos';

  @override
  String get tnRulePerfect => 'Qualquer colisão encerra o jogo imediatamente';

  @override
  String get tnRuleClassic => 'Valem as regras clássicas do jogo da cobra';

  @override
  String get tnJoinSuccess => 'Inscrição no torneio concluída!';

  @override
  String get tnJoinFailed => 'Falha ao entrar no torneio';

  @override
  String get tnJoinError => 'Erro ao entrar no torneio';

  @override
  String get tnTierBronze => 'Bronze';

  @override
  String get tnTierSilver => 'Prata';

  @override
  String get tnTierGold => 'Ouro';

  @override
  String get tnEntryRequired => 'Entrada necessária';

  @override
  String tnEntryNeeded(Object tier) {
    return 'Você precisa de uma entrada $tier para participar deste torneio.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Entradas $tier atuais: $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Assinantes Pro têm acesso ilimitado aos torneios.';

  @override
  String get tnFreeBronzeAdded => '🎉 Entrada Bronze grátis adicionada!';

  @override
  String get tnFreeEntryAd => 'Entrada grátis (anúncio)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Comprar entrada $tier - $price';
  }

  @override
  String get acAll => 'Todas';

  @override
  String get acUnlocked => 'Desbloqueadas';

  @override
  String get acLocked => 'Bloqueadas';

  @override
  String get acTotalUpper => 'TOTAL';

  @override
  String get acUnlockedUpper => 'DESBLOQUEADAS';

  @override
  String get acClaimedUpper => 'RESGATADAS';

  @override
  String get acPendingUpper => 'PENDENTES';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% concluído';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% das desbloqueadas';
  }

  @override
  String get acEmpty => 'Nenhuma conquista aqui';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Desbloqueada $date';
  }

  @override
  String get rpTitle => 'Replays de partidas';

  @override
  String get rpRecent => 'Recentes';

  @override
  String get rpBest => 'Melhores';

  @override
  String get rpCrashes => 'Colisões';

  @override
  String get rpLoading => 'Carregando replays...';

  @override
  String get rpNoRecent => 'Nenhum replay recente';

  @override
  String get rpNoBest => 'Nenhum replay de recorde';

  @override
  String get rpNoCrashes => 'Nenhum replay de colisão';

  @override
  String get rpEmptySub => 'Jogue algumas partidas para gerar replays!';

  @override
  String get rpScore => 'Pontos';

  @override
  String get rpDuration => 'Duração';

  @override
  String get rpFood => 'Comida';

  @override
  String get rpFrames => 'Quadros';

  @override
  String get rpMaxLength => 'Comprimento máx.';

  @override
  String get rpWatch => 'Assistir';

  @override
  String get rpYesterday => 'Ontem';

  @override
  String get rpDeleteTitle => 'Excluir replay';

  @override
  String rpDeleteBody(Object date) {
    return 'Excluir o replay de $date?';
  }

  @override
  String get rpDelete => 'Excluir';

  @override
  String get rpDeleted => 'Replay excluído';

  @override
  String get rpDeleteFailed => 'Falha ao excluir o replay';

  @override
  String get lbTitle => 'Rankings';

  @override
  String get lbGlobal => 'Global';

  @override
  String get lbWeekly => 'Semanal';

  @override
  String get lbWeeklySub =>
      'Classificado pela sua melhor pontuação da semana (reinicia domingo)';

  @override
  String get lbGlobalSub =>
      'Classificado pela sua maior pontuação de todos os tempos';

  @override
  String lbScoreLine(Object score) {
    return 'Pontos: $score';
  }

  @override
  String get lbLoadingGlobal => 'Carregando ranking global...';

  @override
  String get lbLoadingWeekly => 'Carregando ranking semanal...';

  @override
  String get lbNoScores => 'Nenhuma pontuação ainda';

  @override
  String get lbBeFirst => 'Seja o primeiro a marcar um recorde!';

  @override
  String get lbNoWeekly => 'Nenhuma pontuação esta semana';

  @override
  String get lbPlayThisWeek => 'Jogue esta semana para aparecer aqui!';

  @override
  String get lbAnonymous => 'Anônimo';

  @override
  String get lbGuestBadge => 'CONVIDADO';

  @override
  String get lbPts => 'pts';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas jogadas',
      one: '$count partida jogada',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '$name resgatado!';
  }

  @override
  String get bpTitle => 'Passe de Batalha';

  @override
  String get bpTitleUpper => 'PASSE DE BATALHA';

  @override
  String get bpLoading => 'Carregando passe de batalha...';

  @override
  String get bpWatchAdXp => 'Assistir anúncio — +50 XP do Passe';

  @override
  String get bpXpEarned => '+50 XP do Passe de Batalha!';

  @override
  String get bpSeasonEnded => 'Temporada encerrada';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h restantes';
  }

  @override
  String bpDaysLeft(Object days) {
    return '${days}d restantes';
  }

  @override
  String get bpTierUpper => 'NÍVEL';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'Temporada completa';

  @override
  String get bpSeasonCompleteUpper => 'TEMPORADA COMPLETA';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next XP para o nível $tier';
  }

  @override
  String get bpPremiumBadge => 'PREMIUM';

  @override
  String get bpSeasonCosmicSerpent => 'Temporada Serpente Cósmica';

  @override
  String get bpUnlockedEverything =>
      'Você desbloqueou todos os níveis desta temporada.';

  @override
  String get bpComingNext => 'A SEGUIR';

  @override
  String bpTierN(Object tier) {
    return 'Nível $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count níveis de distância',
      one: '$count nível de distância',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'DESBLOQUEIE COM O PRO';

  @override
  String get bpAvailableNow => 'DISPONÍVEL AGORA';

  @override
  String bpTierAbbrev(Object tier) {
    return 'N$tier';
  }

  @override
  String get bpClaim => 'RESGATAR';

  @override
  String get bpPremiumWaiting => 'Recompensas premium esperando';

  @override
  String get bpSubscribeToClaim => 'Assine o Pro para resgatá-las.';

  @override
  String get bpHideTiers => 'Ocultar níveis';

  @override
  String bpViewAllTiers(Object count) {
    return 'Ver todos os $count níveis';
  }

  @override
  String get bpCollapse => 'RECOLHER';

  @override
  String get bpExpand => 'EXPANDIR';

  @override
  String get bpNow => 'AGORA';

  @override
  String bpTierUpperN(Object tier) {
    return 'NÍVEL $tier';
  }

  @override
  String get bpUnlocked => 'Desbloqueada';

  @override
  String bpReachTier(Object tier) {
    return 'Alcance o nível $tier para desbloquear';
  }

  @override
  String get bpBetweenSeasons => 'Entre temporadas';

  @override
  String get bpNoSeasonBody =>
      'Nenhum Passe de Batalha em andamento — a próxima temporada começará automaticamente. Volte em breve.';

  @override
  String get bpCheckNewSeason => 'Verificar nova temporada';

  @override
  String get pbActive => 'Premium ativo!';

  @override
  String get pbActiveSub => 'Você tem acesso a todos os recursos premium';

  @override
  String get pbHeaderSub => 'Desbloqueie tudo o que o jogo oferece';

  @override
  String get pbMonthlyPlan => 'Plano mensal';

  @override
  String get pbYearlyPlan => 'Plano anual';

  @override
  String get pbSave33 => 'Economize 33%';

  @override
  String get pbMostPopular => 'MAIS POPULAR';

  @override
  String get pbFeatExtraLife => 'Vida extra sempre grátis';

  @override
  String get pbFeatExtraLifeDesc =>
      'Bateu? Continue — membros Pro revivem na hora de graça, sem anúncio e sem moedas, uma vez por partida';

  @override
  String get pbFeatNoAds => 'Remova todos os anúncios';

  @override
  String get pbFeatNoAdsDesc =>
      'Sem banners, sem intersticiais — jogue totalmente sem anúncios, para sempre';

  @override
  String get pbFeatThemes => 'Todos os temas premium';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'Todas as skins premium';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice e mais 5';

  @override
  String get pbFeatTrails => 'Todos os rastros premium';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal e mais 5';

  @override
  String get pbFeatBoards => 'Tabuleiros grandes';

  @override
  String get pbFeatBoardsDesc => 'Jogue em tabuleiros 35x35, 40x40 e 50x50';

  @override
  String get pbFeatCoins => 'Recompensas de moedas 2x';

  @override
  String get pbFeatCoinsDesc => 'O dobro de Moedas Snake em cada partida';

  @override
  String get pbFeatLucky => 'Sortudo — mais comidas especiais';

  @override
  String get pbFeatLuckyDesc =>
      '+50% de chance de surgir a rara comida especial de 50 pontos em cada partida';

  @override
  String get pbFeatPowerUps => 'Mais power-ups no jogo';

  @override
  String get pbFeatPowerUpsDesc =>
      '+30% de taxa de surgimento de power-ups no tabuleiro';

  @override
  String get pbFeatBundle => 'Pacote de power-ups premium';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield e Mega Invincibility por ciclo de cobrança';

  @override
  String get pbFeatTournament => 'Entradas de torneio';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronze + 1× Prata + 1× Ouro por ciclo de cobrança';

  @override
  String get pbIncludes => 'O Premium inclui:';

  @override
  String get pbProPerk => 'VANTAGEM PRO';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'Assinar — $price$period';
  }

  @override
  String get pbReassurance =>
      'Sem compromisso • Cancele quando quiser • Pagamento seguro';

  @override
  String get pbNotAvailable => 'Assinatura premium indisponível';

  @override
  String get eaTitleLink => 'Salve seu progresso';

  @override
  String get eaTitleSignIn => 'Entrar com e-mail';

  @override
  String get eaExplainer =>
      'Adicione um e-mail e uma senha à sua conta para comprar itens, restaurar ao reinstalar e entrar de qualquer dispositivo.';

  @override
  String get eaLinkExisting => 'Vincular existente';

  @override
  String get eaSignIn => 'Entrar';

  @override
  String get eaCreateAccount => 'Criar conta';

  @override
  String get eaForgotPassword => 'Esqueceu a senha?';

  @override
  String get eaLinkToExisting => 'Vincular a conta existente';

  @override
  String get eaMinChars => 'Pelo menos 8 caracteres';

  @override
  String eaMinCharsN(Object count) {
    return 'Pelo menos $count caracteres';
  }

  @override
  String get eaCreateAndLink => 'Criar e vincular conta';

  @override
  String get eaEmail => 'E-mail';

  @override
  String get eaEmailRequired => 'O e-mail é obrigatório';

  @override
  String get eaEmailInvalid => 'Digite um e-mail válido';

  @override
  String get eaPassword => 'Senha';

  @override
  String get eaPasswordRequired => 'A senha é obrigatória';

  @override
  String get eaForgotFirst =>
      'Digite seu e-mail acima primeiro e depois toque em Esqueceu a senha.';

  @override
  String eaResetSent(Object email) {
    return 'E-mail de redefinição de senha enviado para $email.';
  }

  @override
  String get eaErrInvalidEmail => 'Esse endereço de e-mail não é válido.';

  @override
  String get eaErrDisabled => 'Esta conta foi desativada.';

  @override
  String get eaErrNoAccount => 'Nenhuma conta encontrada com esse e-mail.';

  @override
  String get eaErrWrongCreds => 'E-mail ou senha incorretos.';

  @override
  String get eaErrEmailInUse =>
      'Já existe uma conta com esse e-mail. Tente entrar.';

  @override
  String get eaErrWeakPassword =>
      'A senha é muito fraca. Use pelo menos 8 caracteres.';

  @override
  String get eaErrNotEnabled =>
      'O login por e-mail/senha não está habilitado. Contate o suporte.';

  @override
  String get eaErrTooMany =>
      'Muitas tentativas. Aguarde alguns minutos e tente de novo.';

  @override
  String get eaErrNetwork => 'Erro de rede. Verifique sua conexão.';

  @override
  String get eaErrAlreadyLinked =>
      'Esta conta já está vinculada a e-mail/senha.';

  @override
  String get eaErrRecentLogin =>
      'Por segurança, entre novamente antes de vincular.';

  @override
  String get eaErrGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get faWelcome => 'Bem-vindo ao\nSnake Classic!';

  @override
  String get faChooseHow => 'Escolha como você quer jogar:';

  @override
  String get faSigningIn => 'Entrando...';

  @override
  String get faSignInEmail => 'Entrar com e-mail';

  @override
  String get faContinueGuest => 'Continuar como convidado';

  @override
  String get faGuestNote =>
      'Convidados podem jogar e salvar o progresso localmente, mas não podem fazer compras. Entre com Apple, Google ou e-mail quando quiser assinar ou comprar.';

  @override
  String get faPrivacyTerms => 'Privacidade e Termos';

  @override
  String get faReviewNote =>
      'Revise nossa Política de Privacidade e os Termos de Uso antes de continuar';

  @override
  String get faAgreeCheckbox =>
      'Li e concordo com a Política de Privacidade e os Termos de Uso';

  @override
  String get faContinueToSignIn => 'Continuar para o login';

  @override
  String get faHeadsUp => 'Atenção';

  @override
  String get faGuestBullet1 =>
      'Dados de convidado são excluídos automaticamente dos nossos servidores após 90 dias de inatividade.';

  @override
  String get faGuestBullet2 =>
      'Para salvar seu progresso permanentemente e jogar em vários dispositivos, entre com Apple, Google ou e-mail.';

  @override
  String get faGuestBullet3 =>
      'Contas de convidado não podem comprar produtos ou assinaturas. Entre se quiser assinar o Pro ou comprar cosméticos.';

  @override
  String get faChangedMind => 'Mudei de ideia';

  @override
  String get faProceedAnyway => 'Continuar assim mesmo';

  @override
  String get faAppleFailed => 'Falha ao entrar com a Apple. Tente novamente.';

  @override
  String get faGoogleFailed => 'Falha ao entrar com o Google. Tente novamente.';

  @override
  String get faUnexpected => 'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get faGuestFailed =>
      'Falha ao continuar como convidado. Tente novamente.';

  @override
  String get ldInitializing => 'Inicializando Snake Classic...';

  @override
  String get ldTip1 =>
      'Planeje duas jogadas à frente — sua cauda segue por onde a cabeça acabou de passar.';

  @override
  String get ldTip2 =>
      'A comida bônus vale mais pontos, mas some rápido. Pegue logo!';

  @override
  String get ldTip3 =>
      'Bateu? Assista a um anúncio rápido ou gaste moedas para reviver e manter sua pontuação.';

  @override
  String get ldTip4 =>
      'Encadeie comidas sem pausar para construir um multiplicador de combo.';

  @override
  String get ldTip5 =>
      'Preso num canto? Cole nas paredes para ganhar um instante.';

  @override
  String get ldTip6 =>
      'Desafios diários e missões semanais acumulam moedas rapidinho.';

  @override
  String get ldTip7 =>
      'O Snake Classic Pro libera tabuleiros maiores e remove todos os anúncios.';

  @override
  String get ldTip8 =>
      'O Contra o Tempo premia a velocidade — e você pode assistir a um anúncio por +30 segundos.';

  @override
  String get ldTip9 =>
      'Power-ups se acumulam: arme um escudo antes de passar por um vão apertado.';

  @override
  String get ldTip10 =>
      'Troque temas, skins e rastros a qualquer momento na loja para um visual novo.';

  @override
  String get ldStepCore => 'Inicializando sistemas principais...';

  @override
  String get ldStepCoreSub => 'Configurando conexão com o servidor';

  @override
  String get ldStepProfile => 'Criando seu perfil de jogador...';

  @override
  String get ldStepProfileSub => 'Gerando nome de usuário único';

  @override
  String get ldStepPrefs => 'Carregando suas preferências...';

  @override
  String get ldStepPrefsSub => 'Sincronizando temas e configurações';

  @override
  String get ldStepCloud => 'Sincronizando com a nuvem...';

  @override
  String get ldStepCloudSub => 'Garantindo que os dados estejam atualizados';

  @override
  String get ldStepGameData => 'Carregando dados do jogo...';

  @override
  String get ldStepGameDataSub => 'Buscando dados do jogo';

  @override
  String get ldStepAudio => 'Configurando sistema de áudio...';

  @override
  String get ldStepAudioSub => 'Carregando efeitos sonoros';

  @override
  String get ldStepSetup => 'Verificando status da configuração...';

  @override
  String get ldStepSetupSub => 'Quase pronto!';

  @override
  String get ldWelcome => 'Bem-vindo!';

  @override
  String get ldWelcomeSub => 'Escolha como continuar';

  @override
  String get ldReady => 'Pronto para jogar!';

  @override
  String get ldReadySub => 'Bem-vindo de volta ao Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Falha na inicialização: $error';
  }

  @override
  String get ldRetrying => 'Tentando inicializar de novo...';

  @override
  String get ldTagline => 'EXPERIÊNCIA SNAKE PREMIUM';

  @override
  String get ldLoadingUpper => 'CARREGANDO';

  @override
  String get ldDidYouKnow => 'VOCÊ SABIA?';

  @override
  String get ldGameFeatures => 'RECURSOS DO JOGO';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Jogabilidade fluida';

  @override
  String get ldFeatEffects => 'EFEITOS';

  @override
  String get ldFeatEffectsSub => 'Partículas visuais';

  @override
  String get ldFeatLevels => 'NÍVEIS';

  @override
  String get ldFeatLevelsSub => 'Diversão progressiva';

  @override
  String get ldFeatAudio => 'ÁUDIO';

  @override
  String get ldFeatAudioSub => 'Som imersivo';

  @override
  String get ldFeatScores => 'PONTOS';

  @override
  String get ldFeatScoresSub => 'Rankings globais';

  @override
  String get ldFeatThemes => 'TEMAS';

  @override
  String get ldFeatThemesSub => 'Vários estilos';

  @override
  String get ldDevelopedBy => 'DESENVOLVIDO E MANTIDO POR';

  @override
  String get ldDevTagline => 'Criando experiências mobile premium';

  @override
  String get ldInitFailedUpper => 'FALHA NA INICIALIZAÇÃO';

  @override
  String get ldRetryUpper => 'TENTAR DE NOVO';

  @override
  String get pgArena => 'Inicializando a arena...';

  @override
  String get pgControls => 'Calibrando os controles...';

  @override
  String get pgSnake => 'Invocando a cobra...';

  @override
  String get pgFood => 'Posicionando a comida...';

  @override
  String get pgPowerUps => 'Carregando os power-ups...';

  @override
  String get pgAlmost => 'Quase lá...';

  @override
  String get pgGo => 'Vai!';

  @override
  String get pgTip1 =>
      'Mantenha uma direção por mais tempo para construir multiplicadores de combo.';

  @override
  String get pgTip2 => 'A comida bônus rende mais pontos, mas some rápido.';

  @override
  String get pgTip3 => 'Power-ups surgem ao acaso — pegue enquanto pode.';

  @override
  String get pgTip4 => 'Planeje duas jogadas à frente, não só uma.';

  @override
  String get pgTip5 =>
      'Cobras longas viram mais devagar. Guarde as curvas fechadas para o início.';

  @override
  String get pgTip6 =>
      'O Multiplicador de Pontos soma com combos para pontuações monstruosas.';

  @override
  String get pgTip7 => 'Comida especial é rara — quando aparecer, priorize-a.';

  @override
  String get pgTip8 => 'O Contra o Tempo acelera rápido. Dose suas curvas.';

  @override
  String get pgTip9 =>
      'No Modo Zen, as paredes dão a volta. Use para escapar de apertos.';

  @override
  String get pgTip10 =>
      'Jogo Perfeito: nunca reentre numa célula que seu corpo tocou.';

  @override
  String get pgTip11 => 'O D-Pad dá curvas precisas; o deslize é mais rápido.';

  @override
  String get pgTip12 =>
      'Pause a qualquer momento pelo HUD — o cronômetro espera por você.';

  @override
  String get pgPreparing => 'PREPARANDO A ARENA';

  @override
  String get pgTournamentMode => 'MODO TORNEIO';

  @override
  String get pgGameMode => 'MODO DE JOGO';

  @override
  String get pgDPadControls => 'Controles D-Pad';

  @override
  String get pgSwipeControls => 'Controles de deslize';

  @override
  String get pgLevel => 'NÍVEL';

  @override
  String get pgBest => 'RECORDE';

  @override
  String get pgGames => 'PARTIDAS';

  @override
  String get pgProTip => 'DICA PRO';

  @override
  String get pgTapToStart => 'TOQUE EM QUALQUER LUGAR PARA COMEÇAR';

  @override
  String get wtWelcomeTitle => 'Bem-vindo ao jogo!';

  @override
  String get wtWelcomeMsg =>
      'Vamos aprender a jogar Snake Classic. Este tutorial rápido mostrará o básico.';

  @override
  String get wtHudTitle => 'Informações do jogo';

  @override
  String get wtHudMsg =>
      'A barra superior mostra sua pontuação, nível e recorde. Acompanhe seu progresso enquanto joga!';

  @override
  String get wtControlsTitle => 'Direção';

  @override
  String get wtControlsMsg =>
      'Muda de direção deslizando no tabuleiro, com o botão direcional no ecrã ou com as setas. Escolhe o teu estilo em Definições → Controlos.';

  @override
  String get wtPracticeRightTitle => 'Experimenta — vira à DIREITA';

  @override
  String get wtPracticeRightMsg =>
      'Vira à direita para continuar. Deslizar, botão direcional ou setas — tudo funciona.';

  @override
  String get wtPracticeUpTitle => 'Boa — agora vira para CIMA';

  @override
  String get wtPracticeUpMsg => 'Vira para cima para continuar.';

  @override
  String get wtFoodTitle => 'Coma para crescer';

  @override
  String get wtFoodMsg =>
      'Guie a cobra para comer a comida que aparece no tabuleiro. Cada comida deixa a cobra mais longa!';

  @override
  String get wtComboTitle => 'Construa um combo';

  @override
  String get wtComboMsg =>
      'Coma sem morrer para construir um combo. Com 5 mordidas você ganha 1,5×, com 10 ganha 2×, com 20 ganha 3×. O chip de fogo perto da pontuação esquenta e pulsa conforme você sobe.';

  @override
  String get wtPowerUpsTitle => 'Power-ups';

  @override
  String get wtPowerUpsMsg =>
      'Ícones brilhantes surgem de vez em quando — coma um para ativá-lo. O anel ao redor do ícone esvazia conforme o efeito acaba, e o cronômetro congela se você pausar.';

  @override
  String get wtWallsTitle => 'Evite as paredes!';

  @override
  String get wtWallsMsg =>
      'Não bata nas bordas do tabuleiro - é fim de jogo se você colidir com uma parede!';

  @override
  String get wtSelfTitle => 'Não bata em você mesmo!';

  @override
  String get wtSelfMsg =>
      'Conforme a cobra cresce, cuidado para não colidir com o próprio corpo!';

  @override
  String get wtPauseTitle => 'Pause quando quiser';

  @override
  String get wtPauseMsg =>
      'Toque no ícone de pausa para congelar a partida. De lá você pode retomar, reiniciar, abrir o Guia do Jogo, repetir este tutorial ou alternar o D-Pad.';

  @override
  String get wtReadyTitle => 'Você está pronto!';

  @override
  String get wtReadyMsg =>
      'Boa sorte! Abra o Guia do Jogo no menu de pausa quando quiser para ler sobre combos, power-ups, modos e feedback de colisão. Veja seu Perfil para acompanhar as conquistas desbloqueando.';

  @override
  String get wtStartPlaying => 'Começar a jogar!';

  @override
  String get wtSkipTutorial => 'Pular tutorial';

  @override
  String get wtSwipeRightUpper => 'VIRAR À DIREITA';

  @override
  String get wtSwipeLeftUpper => 'VIRAR À ESQUERDA';

  @override
  String get wtSwipeUpUpper => 'VIRAR PARA CIMA';

  @override
  String get wtSwipeDownUpper => 'VIRAR PARA BAIXO';

  @override
  String get wtSwipeAnywhereScreen => 'Deslizar, botão direcional ou setas';

  @override
  String get wtSwipeAnywhere => 'É contigo!';

  @override
  String get wtGotIt => 'Entendi!';

  @override
  String get wtNext => 'Próximo';

  @override
  String get wtSkip => 'Pular';

  @override
  String get wtWaiting => 'Aguardando...';

  @override
  String get hwPlayTitle => 'Bem-vindo ao Snake Classic!';

  @override
  String get hwPlayMsg =>
      'Toque no botão JOGAR para começar. Deslize para controlar a cobra e coma para crescer!';

  @override
  String get hwCoinsTitle => 'Suas moedas';

  @override
  String get hwCoinsMsg =>
      'Ganhe moedas jogando, completando desafios e com bônus diários. Use-as na loja!';

  @override
  String get hwDailyTitle => 'Desafios diários';

  @override
  String get hwDailyMsg =>
      'Complete desafios diários para ganhar moedas e recompensas. Desafios novos todo dia!';

  @override
  String get hwStoreTitle => 'A loja';

  @override
  String get hwStoreMsg =>
      'Compre temas, skins, rastros e power-ups com suas moedas. Desbloqueie o Pro para tabuleiros premium e cosméticos exclusivos.';

  @override
  String get hwCosmeticsTitle => 'Skins e rastros';

  @override
  String get hwCosmeticsMsg =>
      'Personalize sua cobra aqui. Skins mudam o visual da cobra; rastros deixam um brilho atrás dela. Ganhe com moedas ou desbloqueie com o Pro.';

  @override
  String get hwProfileTitle => 'Seu perfil';

  @override
  String get hwProfileMsg =>
      'Estatísticas, conquistas e recordes moram aqui. Conquistas desbloqueiam conforme você atinge marcos — algumas exigem um modo específico (Clássico, Difícil etc.). Entre para sincronizar entre dispositivos.';

  @override
  String get hwSettingsTitle => 'Configurações';

  @override
  String get hwSettingsMsg =>
      'Personalize sua experiência - mude temas, controles, áudio e muito mais!';

  @override
  String get hudScoreUpper => 'PONTOS';

  @override
  String hudScoreSemantics(Object value) {
    return 'Pontuação $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'NV$level';
  }

  @override
  String get hudTournamentBadge => 'TORNEIO';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'PAUSADO';

  @override
  String get poPremium => 'Premium';

  @override
  String get poStore => 'Loja';

  @override
  String get poResume => 'RETOMAR';

  @override
  String get poRestart => 'REINICIAR';

  @override
  String get poHome => 'INÍCIO';

  @override
  String get poDPadOn => 'D-PAD: ATIVO';

  @override
  String get poDPadOff => 'D-PAD: INATIVO';

  @override
  String get poSound => 'SOM';

  @override
  String get poMusic => 'MÚSICA';

  @override
  String get poHowToPlay => 'COMO JOGAR';

  @override
  String get poGameGuide => 'GUIA DO JOGO';

  @override
  String get poFoodUpper => 'COMIDA';

  @override
  String get poPts10 => '10 pts';

  @override
  String get poPts25 => '25 pts';

  @override
  String get poPts50 => '50 pts';

  @override
  String get poComboUpper => 'COMBO';

  @override
  String get poBites5 => '5 mordidas';

  @override
  String get poBites10 => '10 mordidas';

  @override
  String get poBites20 => '20 mordidas';

  @override
  String get poComboHint =>
      'O chip de fogo perto da pontuação esquenta e pulsa a cada nível ultrapassado.';

  @override
  String get poPowerUpsUpper => 'POWER-UPS';

  @override
  String get poDur7s => '7s';

  @override
  String get poDur6s => '6s';

  @override
  String get poDur10s => '10s';

  @override
  String get poDur8s => '8s';

  @override
  String get poScore2x => 'Pontos 2×';

  @override
  String get poPowerUpHint =>
      'O anel do ícone esvazia até expirar. O cronômetro congela na pausa.';

  @override
  String get poCrashUpper => 'COLISÃO';

  @override
  String get poCrashHint =>
      'Uma onda vermelha dispara na célula onde você morreu. Colisão consigo mesmo também destaca em amarelo o segmento atingido.';

  @override
  String get poModesUpper => 'MODOS';

  @override
  String get poModeWallsOn => 'paredes ativas';

  @override
  String get poModeWallsOff => 'sem paredes';

  @override
  String get poModeFastTick => 'ritmo rápido';

  @override
  String get poModeThreeFoods => '3 comidas de uma vez';

  @override
  String get poModeThreeLives => '3 vidas, acelera';

  @override
  String get poModeThreeMin => '3 min no total';

  @override
  String get poModeFrequentPowerUps => 'power-ups frequentes';

  @override
  String get poModeDontCross => 'não cruze seu rastro';

  @override
  String get dcTitle => 'Desafios diários';

  @override
  String get dcNoChallenges => 'Nenhum desafio disponível';

  @override
  String get dcAllComplete => 'Tudo completo!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count de bônus';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · build $build';
  }

  @override
  String get crTagline => 'O clássico jogo da cobra, reimaginado.';

  @override
  String get crChipModes => 'Modos';

  @override
  String get crChipAchievements => 'Conquistas';

  @override
  String get crChipDaily => 'Diário';

  @override
  String get crChipLeaderboards => 'Rankings';

  @override
  String get crChipCosmetics => 'Cosméticos';

  @override
  String get crCraftedBy => 'Criado por';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · Todos os direitos reservados';
  }

  @override
  String get gbSpeedNormal => 'Normal';

  @override
  String get gbSpeedFast => 'Rápida';

  @override
  String get gbSpeedFaster => 'Mais rápida';

  @override
  String get gbSpeedBlazing => 'Ardente';

  @override
  String get gbSpeedInsane => 'Insana';

  @override
  String get gbSpeedMax => 'MÁX';

  @override
  String get gbLength => 'Tamanho';

  @override
  String get gbSpeed => 'Velocidade';

  @override
  String get gbLevel => 'Nível';

  @override
  String get rarityCommon => 'Comum';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityEpic => 'Épico';

  @override
  String get rarityLegendary => 'Lendário';

  @override
  String get rarityDiamond => 'Diamante';

  @override
  String get achTitleFirstBite => 'Primeira Mordida';

  @override
  String get achDescFirstBite => 'Marque seu primeiro ponto';

  @override
  String get achTitleGettingStarted => 'Começando';

  @override
  String get achDescGettingStarted => 'Marque 100 pontos';

  @override
  String get achTitleHighScorer => 'Bom de Pontos';

  @override
  String get achDescHighScorer => 'Marque 500 pontos em uma única partida';

  @override
  String get achTitleMasterScorer => 'Mestre dos Pontos';

  @override
  String get achDescMasterScorer => 'Marque 1000 pontos em uma única partida';

  @override
  String get achTitleLegendaryScorer => 'Pontuador Lendário';

  @override
  String get achDescLegendaryScorer =>
      'Marque 2000 pontos em uma única partida';

  @override
  String get achTitleFirstGame => 'Primeira Partida';

  @override
  String get achDescFirstGame => 'Jogue sua primeira partida';

  @override
  String get achTitleRegularPlayer => 'Jogador Regular';

  @override
  String get achDescRegularPlayer => 'Jogue 10 partidas';

  @override
  String get achTitleDedicatedPlayer => 'Jogador Dedicado';

  @override
  String get achDescDedicatedPlayer => 'Jogue 50 partidas';

  @override
  String get achTitleSnakeEnthusiast => 'Entusiasta da Cobra';

  @override
  String get achDescSnakeEnthusiast => 'Jogue 100 partidas';

  @override
  String get achTitleSnakeAddict => 'Viciado em Cobra';

  @override
  String get achDescSnakeAddict => 'Jogue 500 partidas';

  @override
  String get achTitleSurvivor => 'Sobrevivente';

  @override
  String get achDescSurvivor => 'Sobreviva por 60 segundos';

  @override
  String get achTitleEndurance => 'Resistência';

  @override
  String get achDescEndurance => 'Sobreviva por 2 minutos';

  @override
  String get achTitleMarathon => 'Maratona';

  @override
  String get achDescMarathon => 'Sobreviva por 5 minutos';

  @override
  String get achTitleNoWalls => 'Longe das Paredes';

  @override
  String get achDescNoWalls => 'Jogue 5 partidas sem bater nas paredes';

  @override
  String get achTitleSpeedster => 'Velocista';

  @override
  String get achDescSpeedster => 'Alcance o nível 10 (velocidade máxima)';

  @override
  String get achTitlePerfectionist => 'Perfeccionista';

  @override
  String get achDescPerfectionist =>
      'Complete uma partida sem bater em si mesmo';

  @override
  String get achTitleAllFoodTypes => 'Gourmet';

  @override
  String get achDescAllFoodTypes =>
      'Coma os 3 tipos de comida em uma única partida';

  @override
  String get achTitleHalfGrand => 'Meio Milhar';

  @override
  String get achDescHalfGrand => 'Marque 5.000 em uma única partida';

  @override
  String get achTitleScoreSniper => 'Franco-Atirador de Pontos';

  @override
  String get achDescScoreSniper => 'Marque 10.000 em uma única partida';

  @override
  String get achTitleFiveDigitClub => 'Clube dos Cinco Dígitos';

  @override
  String get achDescFiveDigitClub => 'Marque 25.000 em uma única partida';

  @override
  String get achTitleScoreTycoon => 'Magnata dos Pontos';

  @override
  String get achDescScoreTycoon => 'Marque 50.000 em uma única partida';

  @override
  String get achTitleScoreGod => 'Deus dos Pontos';

  @override
  String get achDescScoreGod => 'Marque 100.000 em uma única partida';

  @override
  String get achTitlePointCollector => 'Colecionador de Pontos';

  @override
  String get achDescPointCollector => 'Acumule 10.000 pontos no total';

  @override
  String get achTitlePointHoarder => 'Acumulador de Pontos';

  @override
  String get achDescPointHoarder => 'Acumule 100.000 pontos no total';

  @override
  String get achTitleHalfMillionClub => 'Clube do Meio Milhão';

  @override
  String get achDescHalfMillionClub => 'Acumule 500.000 pontos no total';

  @override
  String get achTitlePointMillionaire => 'Milionário de Pontos';

  @override
  String get achDescPointMillionaire => 'Acumule 1.000.000 de pontos no total';

  @override
  String get achTitleDecamillionaire => 'Decamilionário';

  @override
  String get achDescDecamillionaire => 'Acumule 10.000.000 de pontos no total';

  @override
  String get achTitleSnakeVeteran => 'Veterano da Cobra';

  @override
  String get achDescSnakeVeteran => 'Jogue 1.000 partidas';

  @override
  String get achTitleSnakeLegend => 'Lenda da Cobra';

  @override
  String get achDescSnakeLegend => 'Jogue 5.000 partidas';

  @override
  String get achTitleIronWill => 'Vontade de Ferro';

  @override
  String get achDescIronWill => 'Sobreviva 10 minutos em uma única partida';

  @override
  String get achTitleEternalSnake => 'Cobra Eterna';

  @override
  String get achDescEternalSnake => 'Sobreviva 20 minutos em uma única partida';

  @override
  String get achTitleTimeLord => 'Senhor do Tempo';

  @override
  String get achDescTimeLord => 'Sobreviva 30 minutos em uma única partida';

  @override
  String get achTitleFirstBiteSnack => 'Primeiro Lanche';

  @override
  String get achDescFirstBiteSnack => 'Coma 5 comidas em uma partida';

  @override
  String get achTitleHungrySnake => 'Cobra Faminta';

  @override
  String get achDescHungrySnake => 'Coma 20 comidas em uma partida';

  @override
  String get achTitleFamished => 'Esfomeado';

  @override
  String get achDescFamished => 'Coma 50 comidas em uma partida';

  @override
  String get achTitleRavenous => 'Voraz';

  @override
  String get achDescRavenous => 'Coma 100 comidas em uma partida';

  @override
  String get achTitleInsatiable => 'Insaciável';

  @override
  String get achDescInsatiable => 'Coma 200 comidas em uma partida';

  @override
  String get achTitleBlackHoleStomach => 'Estômago de Buraco Negro';

  @override
  String get achDescBlackHoleStomach => 'Coma 500 comidas em uma partida';

  @override
  String get achTitleFoodieApprentice => 'Aprendiz Gourmet';

  @override
  String get achDescFoodieApprentice => 'Coma 100 comidas no total';

  @override
  String get achTitleFoodiePro => 'Gourmet Profissional';

  @override
  String get achDescFoodiePro => 'Coma 1.000 comidas no total';

  @override
  String get achTitleFoodieMaster => 'Mestre Gourmet';

  @override
  String get achDescFoodieMaster => 'Coma 10.000 comidas no total';

  @override
  String get achTitleFoodieGod => 'Deus Gourmet';

  @override
  String get achDescFoodieGod => 'Coma 50.000 comidas no total';

  @override
  String get achTitleQuickPlayer => 'Jogador Rápido';

  @override
  String get achDescQuickPlayer => 'Jogue por 1 hora no total';

  @override
  String get achTitleEngagedPlayer => 'Jogador Engajado';

  @override
  String get achDescEngagedPlayer => 'Jogue por 10 horas no total';

  @override
  String get achTitleHardcorePlayer => 'Jogador Hardcore';

  @override
  String get achDescHardcorePlayer => 'Jogue por 50 horas no total';

  @override
  String get achTitleSnakeObsessed => 'Obcecado pela Cobra';

  @override
  String get achDescSnakeObsessed => 'Jogue por 100 horas no total';

  @override
  String get achTitleTouchGrass => 'Vai Tomar um Ar';

  @override
  String get achDescTouchGrass =>
      'Jogue por 250 horas no total — que tal sair um pouco?';

  @override
  String get achTitleLevel5 => 'Aprendiz';

  @override
  String get achDescLevel5 => 'Alcance o Nível 5';

  @override
  String get achTitleLevel10 => 'Oficial';

  @override
  String get achDescLevel10 => 'Alcance o Nível 10';

  @override
  String get achTitleLevel25 => 'Especialista';

  @override
  String get achDescLevel25 => 'Alcance o Nível 25';

  @override
  String get achTitleLevel50 => 'Mestre';

  @override
  String get achDescLevel50 => 'Alcance o Nível 50';

  @override
  String get achTitleLevel100 => 'Grão-Mestre';

  @override
  String get achDescLevel100 => 'Alcance o Nível 100';

  @override
  String get achTitleClassicInitiate => 'Iniciado no Clássico';

  @override
  String get achDescClassicInitiate => 'Termine 10 partidas no modo Clássico';

  @override
  String get achTitleClassicVeteran => 'Veterano do Clássico';

  @override
  String get achDescClassicVeteran => 'Termine 100 partidas no modo Clássico';

  @override
  String get achTitleClassic1000 => 'Conhecedor do Clássico';

  @override
  String get achDescClassic1000 => 'Marque 1.000 no modo Clássico';

  @override
  String get achTitleClassic5000 => 'Maestro do Clássico';

  @override
  String get achDescClassic5000 => 'Marque 5.000 no modo Clássico';

  @override
  String get achTitleZenInitiate => 'Iniciado no Zen';

  @override
  String get achDescZenInitiate => 'Termine 10 partidas Zen';

  @override
  String get achTitleZenGarden => 'Jardim Zen';

  @override
  String get achDescZenGarden => 'Marque 500 no modo Zen';

  @override
  String get achTitleZenMaster => 'Mestre Zen';

  @override
  String get achDescZenMaster => 'Marque 5.000 no modo Zen';

  @override
  String get achTitleSpeedInitiate => 'Sede de Velocidade';

  @override
  String get achDescSpeedInitiate =>
      'Termine 10 partidas de Desafio de Velocidade';

  @override
  String get achTitleSpeedrunner => 'Speedrunner';

  @override
  String get achDescSpeedrunner => 'Marque 500 no Desafio de Velocidade';

  @override
  String get achTitleLightning => 'Relâmpago';

  @override
  String get achDescLightning => 'Marque 2.000 no Desafio de Velocidade';

  @override
  String get achTitleMultifoodInitiate => 'Paisagem de Comida';

  @override
  String get achDescMultifoodInitiate => 'Termine 10 partidas de MultiComida';

  @override
  String get achTitleBuffet => 'Bufê';

  @override
  String get achDescBuffet => 'Marque 1.000 no MultiComida';

  @override
  String get achTitleSmorgasbord => 'Banquete';

  @override
  String get achDescSmorgasbord => 'Marque 5.000 no MultiComida';

  @override
  String get achTitleSurvivalInitiate => 'Iniciado na Sobrevivência';

  @override
  String get achDescSurvivalInitiate => 'Termine 10 partidas de Sobrevivência';

  @override
  String get achTitleSurvivalPro => 'Profissional da Sobrevivência';

  @override
  String get achDescSurvivalPro => 'Sobreviva 5 minutos no modo Sobrevivência';

  @override
  String get achTitleLastSnakeStanding => 'Última Cobra de Pé';

  @override
  String get achDescLastSnakeStanding => 'Marque 2.500 na Sobrevivência';

  @override
  String get achTitleTimeattackInitiate => 'Atacante do Tempo';

  @override
  String get achDescTimeattackInitiate =>
      'Termine 10 partidas de Contra o Tempo';

  @override
  String get achTitleBeatTheClock => 'Vença o Relógio';

  @override
  String get achDescBeatTheClock =>
      'Sobreviva aos 3 minutos completos do Contra o Tempo';

  @override
  String get achTitleTimeattackMaster => 'Mestre do Contra o Tempo';

  @override
  String get achDescTimeattackMaster => 'Marque 3.000 no Contra o Tempo';

  @override
  String get achTitleComboStarter => 'Iniciante em Combos';

  @override
  String get achDescComboStarter => 'Faça um combo de 5x em uma única partida';

  @override
  String get achTitleComboMaster => 'Mestre dos Combos';

  @override
  String get achDescComboMaster => 'Faça um combo de 10x em uma única partida';

  @override
  String get achTitleComboPro => 'Profissional dos Combos';

  @override
  String get achDescComboPro => 'Faça um combo de 20x em uma única partida';

  @override
  String get achTitleComboGod => 'Deus dos Combos';

  @override
  String get achDescComboGod => 'Faça um combo de 50x em uma única partida';

  @override
  String get achTitleComboLegend => 'Lenda dos Combos';

  @override
  String get achDescComboLegend => 'Faça um combo de 100x em uma única partida';

  @override
  String get achTitleGrowingSnake => 'Cobra em Crescimento';

  @override
  String get achDescGrowingSnake => 'Cresça a cobra até o comprimento 20';

  @override
  String get achTitleBigSnake => 'Cobra Grande';

  @override
  String get achDescBigSnake => 'Cresça a cobra até o comprimento 50';

  @override
  String get achTitleHugeSnake => 'Cobra Enorme';

  @override
  String get achDescHugeSnake => 'Cresça a cobra até o comprimento 100';

  @override
  String get achTitleMassiveSnake => 'Cobra Colossal';

  @override
  String get achDescMassiveSnake => 'Cresça a cobra até o comprimento 200';

  @override
  String get achTitleAnaconda => 'Anaconda';

  @override
  String get achDescAnaconda => 'Cresça a cobra até o comprimento 500';

  @override
  String get achTitleFirstPowerUp => 'Power-Up!';

  @override
  String get achDescFirstPowerUp => 'Colete seu primeiro power-up';

  @override
  String get achTitlePowerPlayer => 'Jogador Poderoso';

  @override
  String get achDescPowerPlayer => 'Colete 10 power-ups no total';

  @override
  String get achTitlePowerHungry => 'Faminto por Poder';

  @override
  String get achDescPowerHungry => 'Colete 50 power-ups no total';

  @override
  String get achTitlePowerAddict => 'Viciado em Poder';

  @override
  String get achDescPowerAddict => 'Colete 200 power-ups no total';

  @override
  String get achTitlePowerMaster => 'Mestre do Poder';

  @override
  String get achDescPowerMaster => 'Colete 1.000 power-ups no total';

  @override
  String get achTitleVarietyPack => 'Pacote Variado';

  @override
  String get achDescVarietyPack =>
      'Colete cada um dos 4 tipos de power-up pelo menos uma vez';

  @override
  String get achTitleSpeedDemon => 'Demônio da Velocidade';

  @override
  String get achDescSpeedDemon => 'Colete 25 power-ups de Aceleração';

  @override
  String get achTitleImmortalStreak => 'Sequência Imortal';

  @override
  String get achDescImmortalStreak => 'Colete 25 power-ups de Invencibilidade';

  @override
  String get achTitleSpecialDiet => 'Dieta Especial';

  @override
  String get achDescSpecialDiet => 'Coma 50 comidas especiais no total';

  @override
  String get achTitleBonusHunter => 'Caçador de Bônus';

  @override
  String get achDescBonusHunter => 'Coma 100 comidas bônus no total';

  @override
  String get achTitleUntouchable5 => 'Intocável';

  @override
  String get achDescUntouchable5 =>
      'Complete 5 partidas perfeitas (sem colisões, 30s+)';

  @override
  String get achTitleUntouchable20 => 'Impecável';

  @override
  String get achDescUntouchable20 => 'Complete 20 partidas perfeitas';

  @override
  String get achTitleUntouchable50 => 'Lenda Intocável';

  @override
  String get achDescUntouchable50 => 'Complete 50 partidas perfeitas';

  @override
  String get achTitleHotStreak => 'Sequência Quente';

  @override
  String get achDescHotStreak =>
      '5 partidas seguidas pontuando >0 e durando 30s+';

  @override
  String get achTitleOnFire => 'Pegando Fogo';

  @override
  String get achDescOnFire => 'Sequência de 10 partidas (30s+ cada)';

  @override
  String get achTitleUnstoppable => 'Imparável';

  @override
  String get achDescUnstoppable => 'Sequência de 25 partidas (30s+ cada)';

  @override
  String get achTitleDailyThree => 'Jogador Diário';

  @override
  String get achDescDailyThree => 'Jogue em 3 dias consecutivos';

  @override
  String get achTitleWeekWarrior => 'Guerreiro da Semana';

  @override
  String get achDescWeekWarrior => 'Jogue em 7 dias consecutivos';

  @override
  String get achTitleVelocity => 'Velocidade';

  @override
  String get achDescVelocity =>
      'Alcance o nível 15 da partida em um único jogo';

  @override
  String get achTitleMachSpeed => 'Velocidade Mach';

  @override
  String get achDescMachSpeed =>
      'Alcance o nível 20 da partida em um único jogo';

  @override
  String get achTitleCosmicSnake => 'Cobra Cósmica';

  @override
  String get achDescCosmicSnake =>
      'Alcance o nível 25 da partida em um único jogo';

  @override
  String get achTitleModeExplorer => 'Explorador de Modos';

  @override
  String get achDescModeExplorer =>
      'Jogue pelo menos uma partida em 3 modos diferentes';

  @override
  String get achTitleAllModePlayer => 'Jogador de Todos os Modos';

  @override
  String get achDescAllModePlayer =>
      'Jogue pelo menos uma partida em cada modo (8 modos)';

  @override
  String get achTitleNightOwl => 'Coruja Noturna';

  @override
  String get achDescNightOwl => 'Termine uma partida entre meia-noite e 5h';

  @override
  String get achTitleEarlyBird => 'Madrugador';

  @override
  String get achDescEarlyBird => 'Termine uma partida entre 5h e 8h';

  @override
  String get achTitleWeekendWarrior => 'Guerreiro de Fim de Semana';

  @override
  String get achDescWeekendWarrior => 'Termine 10 partidas nos fins de semana';

  @override
  String get ppuMegaSpeedBoost => 'Mega Aceleração';

  @override
  String get ppuMegaInvincibility => 'Mega Invencibilidade';

  @override
  String get ppuMegaScoreMultiplier => 'Mega Multiplicador de Pontos';

  @override
  String get ppuMegaSlowMotion => 'Mega Câmera Lenta';

  @override
  String get ppuTeleport => 'Teletransporte';

  @override
  String get ppuSizeReducer => 'Redutor de Tamanho';

  @override
  String get ppuScoreShield => 'Escudo de Pontos';

  @override
  String get ppuComboMultiplier => 'Multiplicador de Combo';

  @override
  String get ppuTimeWarp => 'Distorção do Tempo';

  @override
  String get ppuMagneticFood => 'Comida Magnética';

  @override
  String get ppuGhostMode => 'Modo Fantasma';

  @override
  String get ppuDoubleTrouble => 'Dose Dupla';

  @override
  String get ppuLuckyCharm => 'Amuleto da Sorte';

  @override
  String get ppuPowerSurge => 'Onda de Poder';

  @override
  String get bundleMegaPack => 'Pacote Mega Poder';

  @override
  String get bundleMegaPackDesc =>
      'Versões aprimoradas dos power-ups clássicos';

  @override
  String get bundleTacticalPack => 'Pacote Tático';

  @override
  String get bundleTacticalPackDesc =>
      'Power-ups estratégicos para jogadores habilidosos';

  @override
  String get bundleUltimatePack => 'Pacote Supremo';

  @override
  String get bundleUltimatePackDesc => 'Todos os power-ups premium disponíveis';

  @override
  String get skinClassic => 'Clássica';

  @override
  String get skinGolden => 'Cobra Dourada';

  @override
  String get skinRainbow => 'Cobra Arco-Íris';

  @override
  String get skinGalaxy => 'Cobra Galáxia';

  @override
  String get skinDragon => 'Cobra Dragão';

  @override
  String get skinElectric => 'Cobra Elétrica';

  @override
  String get skinFire => 'Cobra de Fogo';

  @override
  String get skinIce => 'Cobra de Gelo';

  @override
  String get skinShadow => 'Cobra Sombria';

  @override
  String get skinNeon => 'Cobra Neon';

  @override
  String get skinCrystal => 'Cobra de Cristal';

  @override
  String get skinCosmic => 'Cobra Cósmica';

  @override
  String get skinClassicDesc => 'A aparência original da cobra';

  @override
  String get skinGoldenDesc =>
      'Cobra de ouro reluzente que brilha a cada movimento';

  @override
  String get skinRainbowDesc =>
      'Uma cobra colorida que muda pelas cores do arco-íris';

  @override
  String get skinGalaxyDesc => 'Cobra cósmica com padrões estrelados';

  @override
  String get skinDragonDesc =>
      'Cobra feroz com escamas de dragão e poderes místicos';

  @override
  String get skinElectricDesc => 'Crepitando com energia elétrica';

  @override
  String get skinFireDesc => 'Ardendo intensamente com padrões de fogo';

  @override
  String get skinIceDesc => 'Beleza congelada com efeitos cristalinos';

  @override
  String get skinShadowDesc => 'Cobra sombria, escura e misteriosa';

  @override
  String get skinNeonDesc => 'Brilhando com luzes neon cyberpunk';

  @override
  String get skinCrystalDesc =>
      'Cobra de cristal translúcida com efeitos prismáticos';

  @override
  String get skinCosmicDesc =>
      'Cobra feita de poeira estelar e matéria cósmica';

  @override
  String get trailNone => 'Sem Rastro';

  @override
  String get trailParticle => 'Rastro de Partículas';

  @override
  String get trailGlow => 'Rastro Brilhante';

  @override
  String get trailRainbow => 'Rastro Arco-Íris';

  @override
  String get trailFire => 'Rastro de Fogo';

  @override
  String get trailElectric => 'Rastro Elétrico';

  @override
  String get trailStar => 'Rastro de Estrelas';

  @override
  String get trailCosmic => 'Rastro Cósmico';

  @override
  String get trailNeon => 'Rastro Neon';

  @override
  String get trailShadow => 'Rastro Sombrio';

  @override
  String get trailCrystal => 'Rastro de Cristal';

  @override
  String get trailDragon => 'Rastro de Dragão';

  @override
  String get trailNoneDesc => 'Cobra limpa, sem efeitos de rastro';

  @override
  String get trailParticleDesc => 'Deixa um rastro de partículas cintilantes';

  @override
  String get trailGlowDesc => 'Rastro brilhante que se desfaz atrás da cobra';

  @override
  String get trailRainbowDesc => 'Efeito colorido de rastro arco-íris';

  @override
  String get trailFireDesc => 'Rastro de fogo ardente com brasas';

  @override
  String get trailElectricDesc =>
      'Rastro elétrico crepitante com efeitos de raios';

  @override
  String get trailStarDesc => 'Estrelas cintilantes seguem o caminho da cobra';

  @override
  String get trailCosmicDesc => 'Efeitos de poeira cósmica e nebulosa';

  @override
  String get trailNeonDesc => 'Brilho neon intenso com estilo cyberpunk';

  @override
  String get trailShadowDesc =>
      'Rastro de sombras escuras com efeitos de fumaça';

  @override
  String get trailCrystalDesc => 'Fragmentos cristalinos que se desfazem';

  @override
  String get trailDragonDesc => 'Rastro místico de hálito de dragão';

  @override
  String get coinPackSmall => 'Pacote Inicial';

  @override
  String get coinPackMedium => 'Pacote Vantajoso';

  @override
  String get coinPackLarge => 'Pacote Premium';

  @override
  String get coinPackMega => 'Pacote Supremo';

  @override
  String coinsAmount(Object coins) {
    return '$coins moedas';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus de bônus';
  }

  @override
  String get boardSmall => 'Pequeno';

  @override
  String get boardClassic => 'Clássico';

  @override
  String get boardLarge => 'Grande';

  @override
  String get boardHuge => 'Enorme';

  @override
  String get boardEpic => 'Épico';

  @override
  String get boardMassive => 'Colossal';

  @override
  String get boardUltimate => 'Supremo';

  @override
  String get boardSmallDesc => 'Partidas rápidas, espaços apertados';

  @override
  String get boardClassicDesc => 'A experiência original do Snake';

  @override
  String get boardLargeDesc => 'Mais espaço para crescer';

  @override
  String get boardHugeDesc => 'Desafio e espaço máximos';

  @override
  String get boardEpicDesc => 'Um tabuleiro grande para jogadores avançados';

  @override
  String get boardMassiveDesc => 'Tabuleiro gigantesco para partidas épicas';

  @override
  String get boardUltimateDesc => 'O maior tabuleiro possível';

  @override
  String get crashLabelSkip => 'Pular';

  @override
  String get crashLabelUntilTap => 'Até Tocar';

  @override
  String get tgmClassic => 'Clássico';

  @override
  String get tgmSpeedRun => 'Corrida Veloz';

  @override
  String get tgmSurvival => 'Sobrevivência';

  @override
  String get tgmNoWalls => 'Sem Paredes';

  @override
  String get tgmPowerUpMadness => 'Loucura de Power-ups';

  @override
  String get tgmPerfectGame => 'Partida Perfeita';

  @override
  String get tgmClassicDesc => 'Regras padrão do jogo Snake';

  @override
  String get tgmSpeedRunDesc => 'A velocidade do jogo aumenta rapidamente';

  @override
  String get tgmSurvivalDesc => 'Sobreviva o máximo possível';

  @override
  String get tgmNoWallsDesc => 'A cobra atravessa as bordas da tela';

  @override
  String get tgmPowerUpMadnessDesc => 'Power-ups surgem com frequência';

  @override
  String get tgmPerfectGameDesc =>
      'Nenhum erro permitido - um toque encerra o jogo';

  @override
  String get ttDaily => 'Desafio Diário';

  @override
  String get ttWeekly => 'Torneio Semanal';

  @override
  String get ttSpecial => 'Evento Especial';

  @override
  String get tsUpcoming => 'Em Breve';

  @override
  String get tsActive => 'Ativo';

  @override
  String get tsEnded => 'Encerrado';

  @override
  String get cdEasy => 'Fácil';

  @override
  String get cdMedium => 'Médio';

  @override
  String get cdHard => 'Difícil';

  @override
  String get usOnline => 'Online';

  @override
  String get usOffline => 'Offline';

  @override
  String get usPlaying => 'Jogando';

  @override
  String get bprXpBoost => 'Impulso de XP';

  @override
  String get bprCoins => 'Moedas';

  @override
  String get bprTheme => 'Tema';

  @override
  String get bprSkin => 'Skin de Cobra';

  @override
  String get bprTrail => 'Efeito de Rastro';

  @override
  String get bprPowerUp => 'Power-Up';

  @override
  String get bprTournamentEntry => 'Entrada de Torneio';

  @override
  String get bprTitle => 'Título de Jogador';

  @override
  String get bprAvatar => 'Avatar';

  @override
  String get bprSpecial => 'Recompensa Especial';

  @override
  String get bprFree => 'Grátis';

  @override
  String get bprPremium => 'Premium';

  @override
  String get bprnStarDust => 'Poeira Estelar';

  @override
  String get bprnEnergyPack => 'Pacote de Energia';

  @override
  String get bprnBronzeEntry => 'Entrada Bronze';

  @override
  String get bprnSilverEntry => 'Entrada Prata';

  @override
  String get bprnStargazer => 'Observador de Estrelas';

  @override
  String get bprnVoyager => 'Viajante';

  @override
  String get bprnNebulaTheme => 'Tema Nebulosa';

  @override
  String get bprnStardustTrail => 'Rastro de Poeira Estelar';

  @override
  String get bprnLegendaryCrate => 'Baú Lendário';

  @override
  String get bprnMegaXp => 'Mega XP';

  @override
  String get bprnCosmicCharge => 'Carga Cósmica';

  @override
  String get bprnNovaBurst => 'Explosão de Nova';

  @override
  String get bprnGalaxySkin => 'Skin Galáxia';

  @override
  String get bprnCrystalSerpent => 'Serpente de Cristal';

  @override
  String get bprnPlasmaWake => 'Esteira de Plasma';

  @override
  String get bprnCosmicAura => 'Aura Cósmica';

  @override
  String get bprnCyberpunkTheme => 'Tema Cyberpunk';

  @override
  String get bprnCrystalTheme => 'Tema Cristal';

  @override
  String get bprnSeasonTrophy => 'Troféu da Temporada';

  @override
  String get bprnCosmicCrown => 'Coroa Cósmica';

  @override
  String get bprnCosmicLegend => 'Lenda Cósmica';

  @override
  String get bprnStarCommander => 'Comandante Estelar';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity Moedas';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'Recompensa grátis: $type';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'Recompensa premium exclusiva: $type';
  }

  @override
  String get insHowToPlay => 'COMO JOGAR';

  @override
  String get insObjective => 'OBJETIVO';

  @override
  String get insObjectiveBody =>
      'Controle a cobra para comer e crescer o máximo possível sem bater nas paredes ou em si mesma!';

  @override
  String get insControls => 'CONTROLES';

  @override
  String get insSwipeUp => 'Deslize para Cima ↑';

  @override
  String get insSwipeUpDesc => 'Move a cobra para cima';

  @override
  String get insSwipeDown => 'Deslize para Baixo ↓';

  @override
  String get insSwipeDownDesc => 'Move a cobra para baixo';

  @override
  String get insSwipeLeft => 'Deslize para a Esquerda ←';

  @override
  String get insSwipeLeftDesc => 'Move a cobra para a esquerda';

  @override
  String get insSwipeRight => 'Deslize para a Direita →';

  @override
  String get insSwipeRightDesc => 'Move a cobra para a direita';

  @override
  String get insArrowKeys => 'Teclas de setas';

  @override
  String get insArrowKeysDesc => 'Mudar direção';

  @override
  String get insWasd => 'WASD';

  @override
  String get insWasdDesc => 'Mudar direção';

  @override
  String get insSpacebar => 'Barra de espaços';

  @override
  String get insSpacebarDesc => 'Pausar/Retomar o jogo';

  @override
  String get insFoodTypes => 'TIPOS DE COMIDA';

  @override
  String get insNormalFood => 'Comida Normal';

  @override
  String get insBonusFood => 'Comida Bônus';

  @override
  String get insSpecialFood => 'Comida Especial';

  @override
  String get insRules => 'REGRAS';

  @override
  String get insRule1 => 'Coma para crescer e aumentar a pontuação';

  @override
  String get insRule2 => 'A cobra acelera conforme você sobe de nível';

  @override
  String get insRule3 =>
      'O jogo termina se você bater nas paredes ou em si mesmo';

  @override
  String get insRule4 => 'Comida especial aparece a cada 10 comidas normais';

  @override
  String get insRule5 => 'Comida bônus expira após 15 segundos';

  @override
  String get insProTips => 'DICAS PRO';

  @override
  String get insTip1 => 'Planeje seus movimentos com antecedência';

  @override
  String get insTip2 => 'Use as bordas para criar espaços seguros';

  @override
  String get insTip3 => 'Observe o retorno visual dos deslizes';

  @override
  String get insTip4 => 'Pratique em diferentes níveis de dificuldade';

  @override
  String get insBackToGame => 'VOLTAR AO JOGO';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return 'Você recebeu $coins moedas e $xp XP!';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return 'Você recebeu $coins moedas!';
  }

  @override
  String get dchWatchTo2x => 'ASSISTA PARA 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 Dobrado! +$coins moedas de bônus!';
  }

  @override
  String get dchClaimAll => 'Resgatar Tudo';

  @override
  String get dchTodaysProgress => 'Progresso de Hoje';

  @override
  String get dchClaim => 'Resgatar';

  @override
  String get dchClaimed => 'Resgatado';

  @override
  String get dchAllCompleteTitle => 'Todos os Desafios Completos!';

  @override
  String get dchBonusClaimed => 'Recompensa bônus resgatada';

  @override
  String get dchBonusPending => 'Bônus pendente — resgate qualquer desafio';

  @override
  String get dchLoading => 'Carregando desafios...';

  @override
  String get dchCheckBack => 'Volte mais tarde para novos desafios diários!';

  @override
  String get dchAbout => 'Sobre os Desafios Diários';

  @override
  String get dchAbout1 => 'Novos desafios todo dia à meia-noite';

  @override
  String get dchAbout2 => 'Complete desafios para ganhar moedas';

  @override
  String get dchAbout3 => 'Ganhe XP para subir de nível no perfil';

  @override
  String get dchAbout4 => 'Complete os 3 para uma recompensa bônus!';

  @override
  String get dchAllBonusTitle => 'Bônus de Todos os Desafios';

  @override
  String get dchAllBonusDesc => 'Completou todos os desafios diários de hoje.';

  @override
  String get wqNoQuests => 'Nenhuma missão semanal ainda — volte na segunda';

  @override
  String get wqTitle => 'Missões Semanais';

  @override
  String get wqClaimReward => 'Resgatar Recompensa';

  @override
  String get rvNotFound => 'Replay não encontrado';

  @override
  String get rvLoadFailed => 'Falha ao carregar o replay';

  @override
  String rvTitle(Object name) {
    return 'Replay: $name';
  }

  @override
  String get rvLoadingTitle => 'Carregando Replay...';

  @override
  String get rvLoading => 'Carregando replay...';

  @override
  String get rvGoBack => 'Voltar';

  @override
  String get rvScore => 'Pontos';

  @override
  String get rvLevel => 'Nível';

  @override
  String get rvFrame => 'Quadro';

  @override
  String get rvTime => 'Tempo';

  @override
  String get rvNoFrameData => 'Sem dados de quadros';

  @override
  String get rvSpeedLabel => 'Velocidade: ';

  @override
  String rvAteFood(Object type) {
    return '🍎 Comeu comida $type';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ Coletou power-up $type';
  }

  @override
  String get unEmpty => 'O nome de usuário não pode ficar vazio';

  @override
  String get unSetFailed => 'Falha ao definir o nome de usuário';

  @override
  String get unPickTitle => 'Escolha seu nome de usuário';

  @override
  String get unPickBody =>
      'É assim que você aparecerá no placar. Escolhemos um para você — mantenha ou troque.';

  @override
  String get unLabel => 'Nome de usuário';

  @override
  String get unSaving => 'SALVANDO...';

  @override
  String get unContinue => 'CONTINUAR';

  @override
  String get unChangeAnytime =>
      'Você pode mudar isso a qualquer momento nas Configurações.';

  @override
  String unMinLength(Object min) {
    return 'O nome de usuário deve ter pelo menos $min caracteres';
  }

  @override
  String unMaxLength(Object max) {
    return 'O nome de usuário deve ter no máximo $max caracteres';
  }

  @override
  String get unPattern =>
      'O nome de usuário deve começar com uma letra e conter apenas letras, números e sublinhados';

  @override
  String get unReserved =>
      'Este nome de usuário é reservado e não pode ser usado';

  @override
  String get unTaken => 'Este nome de usuário já está em uso';

  @override
  String get unUpdateFailed => 'Falha ao atualizar o nome de usuário';

  @override
  String get pcTitle => 'Privacidade e Termos Atualizados';

  @override
  String pcVersionLine(Object version) {
    return 'Versão $version · revise e aceite para continuar';
  }

  @override
  String get pcTabPrivacy => 'Política de Privacidade';

  @override
  String get pcTabTerms => 'Termos de Uso';

  @override
  String get pcAgree =>
      'Li e concordo com a Política de Privacidade e os Termos de Uso atualizados';

  @override
  String get pcContinue => 'Continuar';

  @override
  String lgAvailableAt(Object url) {
    return 'Este documento está disponível em $url.';
  }

  @override
  String get lgUnavailable =>
      'Este documento está indisponível no momento. Tente novamente mais tarde.';

  @override
  String get auTitle => 'Cadastre-se para fazer compras';

  @override
  String get auBody =>
      'Contas de convidado podem jogar e salvar o progresso localmente, mas não podem comprar itens nem assinar. Vincule uma conta Google ou de e-mail para desbloquear compras — suas moedas, cosméticos e recordes continuam com você.';

  @override
  String get auGoogle => 'Continuar com o Google';

  @override
  String get auGoogleSub => 'A opção mais rápida. Entre com sua conta Google.';

  @override
  String get auLinked => 'Conta vinculada. Agora você pode fazer compras.';

  @override
  String get auEmail => 'Criar uma Conta de E-mail';

  @override
  String get auEmailSub =>
      'Use qualquer e-mail e uma senha à sua escolha. Restaure em qualquer aparelho.';

  @override
  String get auNotNow => 'Agora não';

  @override
  String get auErrCredentialInUse =>
      'Essa credencial já está vinculada a outra conta. Tente entrar com ela.';

  @override
  String get auErrAlreadyLinked => 'Esta conta já está vinculada.';

  @override
  String get auErrRequiresRecentLogin =>
      'Por segurança, entre novamente antes de vincular.';

  @override
  String get auErrNetwork => 'Erro de rede. Verifique sua conexão.';

  @override
  String get auErrGeneric => 'Falha ao vincular. Tente novamente.';

  @override
  String get sroSettingUpTitle => 'Configurando sua conta…';

  @override
  String get sroSettingUpBody =>
      'Preparando tudo para sua primeira sessão. Isso só acontece uma vez.';

  @override
  String get sroLoadingTitle => 'Carregando seus dados anteriores…';

  @override
  String get sroLoadingBody =>
      'Buscando suas estatísticas, conquistas, moedas e desbloqueios na nuvem.';

  @override
  String get sroRestoringTitle => 'Restaurando seu progresso…';

  @override
  String get sroRestoringBody =>
      'Aplicando tudo neste aparelho. Não feche o app.';

  @override
  String get sroDoneTitle => 'Tudo pronto!';

  @override
  String get sroDoneBody => 'Seu progresso foi restaurado.';

  @override
  String get sroFailedTitle => 'Não foi possível restaurar seus dados';

  @override
  String get sroFailedBody =>
      'Não conseguimos acessar a nuvem agora. Verifique sua conexão e tente de novo. Você também pode continuar sem restaurar — tentaremos novamente na próxima vez que abrir o app.';

  @override
  String get sroTryAgain => 'Tentar Novamente';

  @override
  String get sroContinueAnyway => 'Continuar Mesmo Assim';

  @override
  String get ssiOfflinePending =>
      'Offline - As mudanças sincronizarão quando conectar';

  @override
  String get ssiSyncing => 'Sincronizando...';

  @override
  String get ssiAllSynced => 'Todos os dados sincronizados';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens falharam ao sincronizar',
      one: '1 item falhou ao sincronizar',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens aguardando sincronização',
      one: '1 item aguardando sincronização',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'Offline';

  @override
  String get rvoContinue => 'CONTINUAR?';

  @override
  String get rvoSubtitlePro =>
      'Reviva e mantenha seus pontos · Grátis com o Pro';

  @override
  String rvoSubtitleTimer(Object seconds) {
    return 'Reviva e mantenha seus pontos · ${seconds}s';
  }

  @override
  String get rvoGetLifePro => 'Ganhar Vida · Grátis para Pro';

  @override
  String get rvoWatchAd => 'Assistir anúncio para reviver';

  @override
  String rvoUseCoins(Object coins) {
    return 'Usar $coins moedas';
  }

  @override
  String get rvoNoThanks => 'Não, obrigado';

  @override
  String get tbTimesUp => 'TEMPO ESGOTADO!';

  @override
  String tbKeepGoing(Object seconds) {
    return 'Continue · ${seconds}s';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'Assistir anúncio — +${seconds}s';
  }

  @override
  String get tbEndRun => 'Encerrar partida';

  @override
  String get dbTitle => 'Bônus Diário';

  @override
  String get dbClaimToday => 'Resgate sua recompensa diária!';

  @override
  String get dbComeBack => 'Volte amanhã!';

  @override
  String dbDayChip(Object day) {
    return 'D$day';
  }

  @override
  String get dbTodaysReward => 'Recompensa de Hoje';

  @override
  String get dbAlreadyClaimed => 'Já resgatado hoje';

  @override
  String get dbClaim => 'RESGATAR RECOMPENSA';

  @override
  String get dbClaim2x => 'RESGATAR 2× — VER ANÚNCIO';

  @override
  String get npPrimerTitle => 'Não perca nada!';

  @override
  String get npPrimerBody =>
      'Enviamos só algumas notificações por dia — o lembrete do desafio diário e eventos especiais.\n\nSem spam, prometemos. 🐍';

  @override
  String get npMaybeLater => 'Talvez depois';

  @override
  String get npAllSet => '🎉 Tudo pronto!';

  @override
  String get npTurnOn => 'Ativar';

  @override
  String get npSoftTitle => 'Quer ficar por dentro?';

  @override
  String get npSoftBody =>
      'Ative as notificações e lembraremos você dos desafios diários e sequências — além das novidades grandes, como sorteios de Premium GRÁTIS e eventos especiais.\n\nSó algumas por dia, sem spam. 🐍';

  @override
  String get npNotNow => 'Agora não';

  @override
  String get npEnable => 'Ativar notificações';

  @override
  String get aroUnlocked => 'CONQUISTA DESBLOQUEADA';

  @override
  String get aroTapToContinue => 'Toque para continuar';

  @override
  String get aroSkip => 'PULAR';

  @override
  String aroSkipCount(Object count) {
    return 'PULAR ($count)';
  }

  @override
  String get luLevelUp => 'SUBIU DE NÍVEL!';

  @override
  String luReached(Object level) {
    return 'Você alcançou o Nível $level';
  }

  @override
  String get luNice => 'BOA';

  @override
  String get cfTapContinue => 'Toque em qualquer lugar para continuar';

  @override
  String get cfTapSkip => 'Toque em qualquer lugar para pular';

  @override
  String ppgLvShort(Object level) {
    return 'Nv $level';
  }

  @override
  String ppgLvUpper(Object level) {
    return 'NV $level';
  }

  @override
  String ppgLevel(Object level) {
    return 'Nível $level';
  }

  @override
  String get xgTitle => 'Sair do Jogo?';

  @override
  String get xgBody =>
      'Tem certeza de que quer sair? Seu progresso atual será perdido.';

  @override
  String get xgExit => 'Sair';

  @override
  String get ccTitle => 'Como você quer jogar?';

  @override
  String get ccBody =>
      'Escolha um — você pode mudar a qualquer momento em Configurações → Controles.';

  @override
  String get ccSwipe => 'Gestos de Deslize';

  @override
  String get ccSwipeSub => 'Deslize em qualquer lugar do tabuleiro para virar.';

  @override
  String get ccDpad => 'Controles D-Pad';

  @override
  String get ccDpadSub => 'Botões direcionais na tela.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 +$coins moedas adicionadas à sua carteira!';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'Assistir um anúncio — +$coins moedas';
  }

  @override
  String get rcNoAd => 'Nenhum anúncio disponível agora';

  @override
  String get raOptIn => 'Participe — assista para ganhar';

  @override
  String get compassSemantics => 'Indicador de direção do deslize';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 Bônus diário dobrado — +$coins moedas de bônus!';
  }

  @override
  String get nsNewNotification => 'Você tem uma nova notificação';

  @override
  String get nsAchievementUnlocked => '🏆 Conquista Desbloqueada!';

  @override
  String get nsDailyReminderTitle => '🐍 Hora de jogar Snake Classic!';

  @override
  String get nsDailyReminderBody =>
      'Complete seu desafio diário e suba no placar!';

  @override
  String get mpErrMatchmaking => 'Falha na busca de partida. Tente novamente.';

  @override
  String get mpErrCreateFailed => 'Falha ao criar o jogo';

  @override
  String get mpErrJoinFailed =>
      'Falha ao entrar no jogo. Ele pode estar cheio ou não existir.';

  @override
  String get mpErrReadyFailed => 'Falha ao atualizar o status de pronto';

  @override
  String get mpErrStartFailed => 'Falha ao iniciar o jogo';

  @override
  String get mpErrStartTimeout =>
      'Tempo esgotado ao iniciar o jogo. Tente novamente.';

  @override
  String get mpErrReconnectFailed => 'Não foi possível reconectar à partida.';

  @override
  String get mpErrConnectionLost =>
      'Conexão perdida — não foi possível retomar a partida.';

  @override
  String get mpErrMatchEndedAway =>
      'A partida terminou enquanto você estava fora.';

  @override
  String get mpErrWaitingReady =>
      'Aguardando todos os jogadores ficarem prontos';

  @override
  String get mpErrOnlyHost => 'Só o anfitrião pode iniciar o jogo';

  @override
  String get mpErrSessionExpired =>
      'Sessão de jogo expirada. Crie um novo jogo';

  @override
  String get mpErrAlreadyStarted => 'Este jogo já começou';

  @override
  String get mpErrNeedTwoPlayers =>
      'Partidas precisam de exatamente 2 jogadores';

  @override
  String get mpErrSignIn => 'Entre na sua conta para jogar multijogador';

  @override
  String get mpErrReconnectExpired => 'Tempo de reconexão expirado';

  @override
  String get mpErrCheckInternet => 'Conexão perdida. Verifique sua internet';

  @override
  String get mpErrUnableJoin =>
      'Não foi possível entrar na sala. Tente novamente';

  @override
  String get mpErrGeneric => 'Algo deu errado. Tente novamente';

  @override
  String stDurSeconds(Object s) {
    return '${s}s';
  }

  @override
  String stDurMinutes(Object m) {
    return '${m}min';
  }

  @override
  String stDurHours(Object h) {
    return '${h}h';
  }

  @override
  String stDurMinSec(Object m, Object s) {
    return '${m}min ${s}s';
  }

  @override
  String stDurHourMin(Object h, Object m) {
    return '${h}h ${m}min';
  }

  @override
  String dchProgressSummary(Object completed, Object total) {
    return '$completed de $total desafios concluídos';
  }

  @override
  String wqProgressSummary(Object completed, Object total) {
    return '$completed / $total concluídas';
  }

  @override
  String wqClaimable(Object count) {
    return '$count para resgatar';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins moedas, +$xp XP de passe';
  }

  @override
  String get insPoints10 => '10 pontos';

  @override
  String get insPoints25 => '25 pontos';

  @override
  String get insPoints50 => '50 pontos + Sobe de Nível';

  @override
  String get unRules =>
      '• 3-20 caracteres\n• Deve começar com uma letra\n• Apenas letras, números e sublinhados';

  @override
  String get dcTitleScoreEasy => 'Pontuação Iniciante';

  @override
  String get dcTitleScoreMedium => 'Jogador Habilidoso';

  @override
  String get dcTitleScoreHard => 'Mestre dos Pontos';

  @override
  String get dcTitleFoodEasy => 'Cobra Faminta';

  @override
  String get dcTitleFoodMedium => 'Modo Banquete';

  @override
  String get dcTitleFoodHard => 'Insaciável';

  @override
  String get dcTitleSurvivalEasy => 'Sobrevivente';

  @override
  String get dcTitleSurvivalMedium => 'Resistência';

  @override
  String get dcTitleSurvivalHard => 'Imortal';

  @override
  String get dcTitleGamesEasy => 'Jogador Casual';

  @override
  String get dcTitleGamesMedium => 'Dedicado';

  @override
  String get dcTitleGamesHard => 'Viciado em Cobra';

  @override
  String get dcTitleModeEasy => 'Amante do Clássico';

  @override
  String get dcTitleModeMedium => 'Mestre Zen';

  @override
  String get dcTitleModeHard => 'Demônio da Velocidade';

  @override
  String dcDescScore(Object target) {
    return 'Marque pelo menos $target pontos em uma única partida';
  }

  @override
  String dcDescFood(Object target) {
    return 'Coma $target comidas hoje';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'Sobreviva $target segundos em uma única partida';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Jogue $target partidas hoje',
      one: 'Jogue 1 partida hoje',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Jogue $target partidas no modo $mode',
      one: 'Jogue 1 partida no modo $mode',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'Aquecimento Semanal';

  @override
  String get wqTitleScoreMedium => 'Reflexos Afiados';

  @override
  String get wqTitleScoreHard => 'Campeão de Pontos';

  @override
  String get wqTitleFoodEasy => 'Lanchinho Semanal';

  @override
  String get wqTitleFoodMedium => 'Voraz';

  @override
  String get wqTitleFoodHard => 'Sem Fundo';

  @override
  String get wqTitleGamesEasy => 'Cinco por Semana';

  @override
  String get wqTitleGamesMedium => 'Rotina Criada';

  @override
  String get wqTitleGamesHard => 'Maratonista';

  @override
  String get wqTitleSurvivalEasy => 'Rastejo de Dois Minutos';

  @override
  String get wqTitleSurvivalMedium => 'Rastejo de Cinco Minutos';

  @override
  String get wqTitleSurvivalHard => 'Rastejo de Dez Minutos';

  @override
  String get wqTitleTournament => 'Frequentador de Torneios';

  @override
  String get wqTitleDailyEasy => 'Cumpridor Diário';

  @override
  String get wqTitleDailyMedium => 'Mestre do Diário';

  @override
  String wqDescScore(Object target) {
    return 'Marque $target em uma única partida';
  }

  @override
  String wqDescFood(Object target) {
    return 'Coma $target comidas esta semana';
  }

  @override
  String wqDescGames(Object target) {
    return 'Jogue $target partidas esta semana';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'Sobreviva ${target}s em uma única partida';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Jogue $target partidas de torneio',
      one: 'Jogue 1 partida de torneio',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'Complete $target desafios diários esta semana';
  }

  @override
  String tnNameDaily(Object date) {
    return 'Desafio Diário - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'Campeonato Semanal - Semana $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'Grande Prêmio Mensal - $monthYear';
  }

  @override
  String get tnDescDaily =>
      'Dispute a maior pontuação no desafio de 24 horas de hoje! Os melhores ganham moedas e glória.';

  @override
  String get tnDescWeekly =>
      'O confronto semanal definitivo! Enfrente os melhores jogadores por recompensas gigantes.';

  @override
  String get tnDescMonthly =>
      'O maior torneio do mês! Prove que você é o verdadeiro mestre do Snake.';

  @override
  String tnRewardRank(Object rank) {
    return 'Posição $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'Recompensa em moedas para a posição $rank';
  }

  @override
  String get achTitleScore1500 => 'Embalo';

  @override
  String get achDescScore1500 => 'Marque 1.500 pontos em uma única partida';

  @override
  String get achTitleScore3000 => 'Em Chamas';

  @override
  String get achDescScore3000 => 'Marque 3.000 pontos em uma única partida';

  @override
  String get achTitleScore7500 => 'Implacável';

  @override
  String get achDescScore7500 => 'Marque 7.500 pontos em uma única partida';

  @override
  String get achTitleScore15000 => 'Caçador Supremo';

  @override
  String get achDescScore15000 => 'Marque 15.000 pontos em uma única partida';

  @override
  String get achTitleScore35000 => 'Mente de Máquina';

  @override
  String get achDescScore35000 => 'Marque 35.000 pontos em uma única partida';

  @override
  String get achTitleScore75000 => 'Além do Mortal';

  @override
  String get achDescScore75000 => 'Marque 75.000 pontos em uma única partida';

  @override
  String get achTitleScore250000 => 'Um Quarto de Milhão';

  @override
  String get achDescScore250000 => 'Marque 250.000 pontos em uma única partida';

  @override
  String get achTitleBeyondTime => 'Além do Tempo';

  @override
  String get achDescBeyondTime => 'Sobreviva 45 minutos em uma única partida';

  @override
  String get achTitleHourbound => 'Hora Cheia';

  @override
  String get achDescHourbound =>
      'Sobreviva uma hora inteira em uma única partida';

  @override
  String get achTitleSnakeDevotee => 'Devoto da Cobra';

  @override
  String get achDescSnakeDevotee => 'Jogue 2.500 partidas';

  @override
  String get achTitleTenThousandClub => 'Clube dos Dez Mil';

  @override
  String get achDescTenThousandClub => 'Jogue 10.000 partidas';

  @override
  String get achTitleZenVeteran => 'Veterano Zen';

  @override
  String get achDescZenVeteran => 'Termine 100 partidas Zen';

  @override
  String get achTitleSpeedVeteran => 'Veterano da Velocidade';

  @override
  String get achDescSpeedVeteran =>
      'Termine 100 partidas de Desafio de Velocidade';

  @override
  String get achTitleMultifoodVeteran => 'Veterano do MultiComida';

  @override
  String get achDescMultifoodVeteran => 'Termine 100 partidas de MultiComida';

  @override
  String get achTitleTimeattackVeteran => 'Veterano do Contra o Tempo';

  @override
  String get achDescTimeattackVeteran =>
      'Termine 100 partidas de Contra o Tempo';

  @override
  String get achTitleSurvivalVeteran => 'Veterano da Sobrevivência';

  @override
  String get achDescSurvivalVeteran => 'Termine 100 partidas de Sobrevivência';

  @override
  String get achTitlePumInitiate => 'Iniciado na Loucura';

  @override
  String get achDescPumInitiate =>
      'Termine 10 partidas de Loucura de Power-ups';

  @override
  String get achTitlePumVeteran => 'Veterano da Loucura';

  @override
  String get achDescPumVeteran =>
      'Termine 100 partidas de Loucura de Power-ups';

  @override
  String get achTitlePerfectInitiate => 'Purista';

  @override
  String get achDescPerfectInitiate =>
      'Termine 10 partidas de Partida Perfeita';

  @override
  String get achTitlePerfectVeteran => 'Disciplina';

  @override
  String get achDescPerfectVeteran =>
      'Termine 100 partidas de Partida Perfeita';

  @override
  String get achTitleZen10000 => 'Transbordo Zen';

  @override
  String get achDescZen10000 => 'Marque 10.000 no modo Zen';

  @override
  String get achTitleSpeed5000 => 'Borrão';

  @override
  String get achDescSpeed5000 => 'Marque 5.000 no Desafio de Velocidade';

  @override
  String get achTitleMultifood10000 => 'Bufê Sem Fim';

  @override
  String get achDescMultifood10000 => 'Marque 10.000 no MultiComida';

  @override
  String get achTitleTimeattack5000 => 'Corrida Contra o Relógio';

  @override
  String get achDescTimeattack5000 => 'Marque 5.000 no Contra o Tempo';

  @override
  String get achTitlePum2000 => 'Energizado';

  @override
  String get achDescPum2000 => 'Marque 2.000 na Loucura de Power-ups';

  @override
  String get achTitlePerfect1000 => 'Corrida Impecável';

  @override
  String get achDescPerfect1000 => 'Marque 1.000 no modo Partida Perfeita';

  @override
  String get achTitleComboSingularity => 'Singularidade de Combos';

  @override
  String get achDescComboSingularity =>
      'Faça um combo de 200x em uma única partida';

  @override
  String get achTitleWorldSerpent => 'Serpente do Mundo';

  @override
  String get achDescWorldSerpent => 'Cresça a cobra até o comprimento 750';

  @override
  String get achTitleLightspeed => 'Velocidade da Luz';

  @override
  String get achDescLightspeed =>
      'Alcance o nível 30 da partida em um único jogo';

  @override
  String get achTitlePowerOverwhelming => 'Poder Avassalador';

  @override
  String get achDescPowerOverwhelming => 'Colete 5.000 power-ups no total';

  @override
  String get achTitleGreedIsGood => 'A Ganância É Boa';

  @override
  String get achDescGreedIsGood =>
      'Colete 25 power-ups de Multiplicador de Pontos';

  @override
  String get achTitleTimeBender => 'Dobrador do Tempo';

  @override
  String get achDescTimeBender => 'Colete 25 power-ups de Câmera Lenta';

  @override
  String get achTitleGastronome => 'Gastrônomo';

  @override
  String get achDescGastronome => 'Coma 100.000 comidas no total';

  @override
  String get achTitleLivingLegend => 'Lenda Viva';

  @override
  String get achDescLivingLegend => 'Acumule 50.000.000 de pontos no total';

  @override
  String get achTitlePerpetualMotion => 'Movimento Perpétuo';

  @override
  String get achDescPerpetualMotion => 'Sequência de 50 partidas (30s+ cada)';

  @override
  String get achTitleImmaculate => 'Imaculado';

  @override
  String get achDescImmaculate => 'Complete 100 partidas perfeitas';

  @override
  String get achTitleFortnightFaithful => 'Fiel por Quinze Dias';

  @override
  String get achDescFortnightFaithful => 'Jogue em 14 dias consecutivos';

  @override
  String get achTitleSteadySnake => 'Cobra Constante';

  @override
  String get achDescSteadySnake => 'Sobreviva 30+ segundos em 100 partidas';

  @override
  String get achTitleMarathonMonth => 'Espírito de Maratona';

  @override
  String get achDescMarathonMonth => 'Sobreviva 30+ segundos em 1.000 partidas';

  @override
  String get achTitleLunchtimeLegend => 'Lenda do Almoço';

  @override
  String get achDescLunchtimeLegend =>
      'Termine uma partida entre meio-dia e 14h';

  @override
  String get legalNoticePrefix => 'Ao jogar, você concorda com nossos ';

  @override
  String get legalNoticeAnd => ' e ';

  @override
  String get dayOneReminderTitle => 'Sua cobra sente sua falta 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'Seu recorde é $score. Acha que consegue superar?';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      'Uma partida rápida? Seu primeiro recorde te espera.';

  @override
  String get goTomorrowLabel => 'VOLTE AMANHÃ';

  @override
  String goTomorrowReward(int coins, int day) {
    return 'Resgate $coins moedas no dia $day da sua sequência';
  }

  @override
  String get rvAteFoodUnknown => '🍎 Comeu comida';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ Pegou um power-up';

  @override
  String get boardTall => 'Alto';

  @override
  String get boardTallDesc =>
      'Preenche a tela do celular — mais espaço para correr';

  @override
  String get boardTallPlus => 'Alto Plus';

  @override
  String get boardTallPlusDesc => 'Uma arena maior no formato do celular';

  @override
  String get mpErrReadyTimeout =>
      'Os dois jogadores não ficaram prontos a tempo. Procurando uma nova partida…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'Confirmação · ${seconds}s';
  }

  @override
  String get mpLobbyWaitingOpponentReady =>
      'Aguardando seu adversário ficar pronto…';

  @override
  String get gameDirectionalPad => 'Botão direcional';

  @override
  String get gameGoHome => 'Ir para o ecrã inicial';

  @override
  String get gamePauseGame => 'Pausar jogo';

  @override
  String get gameResumeGame => 'Retomar jogo';

  @override
  String get gameLeaveMatch => 'Sair da partida';

  @override
  String get gameSteerUp => 'Virar para cima';

  @override
  String get gameSteerDown => 'Virar para baixo';

  @override
  String get gameSteerLeft => 'Virar à esquerda';

  @override
  String get gameSteerRight => 'Virar à direita';

  @override
  String get mpTurnBlocked => 'Bloqueado';

  @override
  String get insHudPause => 'Botão de pausa';

  @override
  String get insHudPauseDesc =>
      'Pausar ou retomar — canto superior direito do jogo';

  @override
  String get insDpad => 'Botão direcional no ecrã';

  @override
  String get insDpadDesc => 'Botões opcionais para virar, em vez de deslizar';

  @override
  String get insControlsNote =>
      'Ativa ou desativa o botão direcional — e escolhe onde fica — em Definições → Controlos.';

  @override
  String get insVersus => 'Versus';

  @override
  String get insVersusOnline => '1v1 online';

  @override
  String get insVersusOnlineDesc =>
      'Regras clássicas, duas cobras, um tabuleiro, em tempo real';

  @override
  String get insVersusQuick => 'Partida rápida';

  @override
  String get insVersusQuickDesc => 'Encontra-te um adversário automaticamente';

  @override
  String get insVersusRoom => 'Sala privada';

  @override
  String get insVersusRoomDesc =>
      'Cria uma sala e partilha o código, ou entra na de um amigo';

  @override
  String get homeVersusCta => 'VERSUS';

  @override
  String get homeVersusSubtitle =>
      '1v1 Clássico · Partida rápida ou convida um amigo';

  @override
  String get hwVersusTitle => 'Joga contra alguém';

  @override
  String get hwVersusMsg =>
      'Versus é 1v1 Clássico online. A partida rápida encontra-te um adversário, ou cria uma sala privada e convida um amigo.';

  @override
  String get hwHelpTitle => 'Mais alguma coisa?';

  @override
  String get hwHelpMsg =>
      'Regras, controlos e Versus estão explicados aqui. As definições estão mesmo ao lado.';

  @override
  String get insOnPhone => 'No telemóvel';

  @override
  String get insOnKeyboard => 'Com teclado';

  @override
  String get settingsSectionYourGame => 'O TEU JOGO';

  @override
  String get settingsStatisticsSubtitle =>
      'Todas as partidas que jogaste, somadas';

  @override
  String get settingsReplaysSubtitle => 'Revê as partidas guardadas';

  @override
  String get homeTapToPlay => 'Toca para jogar';

  @override
  String get homeTileMe => 'Eu';

  @override
  String get dchSectionChallenges => 'Desafios';

  @override
  String dchRewardLine(int coins, int xp) {
    return '$coins moedas · $xp XP';
  }
}
