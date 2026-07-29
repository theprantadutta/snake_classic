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
  String get mpLobbyNoPlayersFound => 'NENHUM JOGADOR ENCONTRADO';

  @override
  String get mpLobbyNoPlayersBody =>
      'Desculpe, não encontramos adversários.\nTente de novo ou crie sua própria sala!';

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
}
