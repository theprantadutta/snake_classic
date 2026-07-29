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
}
