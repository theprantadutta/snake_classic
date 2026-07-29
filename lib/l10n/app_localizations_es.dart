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

  @override
  String get homePlay => 'JUGAR';

  @override
  String get homeHighScore => 'RÉCORD';

  @override
  String homeArmedPowerUp(String name) {
    return 'Equipado: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Equipamiento ($count)';
  }

  @override
  String get puSpeedBoost => 'Impulso de Velocidad';

  @override
  String get puInvincibility => 'Invencibilidad';

  @override
  String get puScoreMultiplier => 'Multiplicador de Puntos';

  @override
  String get puSlowMotion => 'Cámara Lenta';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'TIENDA';

  @override
  String get homeTileFree => 'GRATIS';

  @override
  String get homeTileDaily => 'DIARIO';

  @override
  String get homeTileBattle => 'BATALLA';

  @override
  String get homeTileEvents => 'EVENTOS';

  @override
  String get homeTileBoard => 'RANKING';

  @override
  String get homeTileFriends => 'AMIGOS';

  @override
  String get homeTileCosmetics => 'COSMÉTICOS';

  @override
  String get homeTileAwards => 'PREMIOS';

  @override
  String get homeTileVersus => 'VERSUS';

  @override
  String get homeNoAdReady =>
      'No hay anuncios listos — inténtalo de nuevo en unos segundos.';

  @override
  String get homeFreeSpeedBoostTitle => 'Impulso de Velocidad gratis';

  @override
  String get homeFreeSpeedBoostBody =>
      'Mira un anuncio corto para añadir un Impulso de Velocidad gratis a tu equipamiento. Se activa 5 segundos después de empezar tu próxima partida.';

  @override
  String get homeNotNow => 'Ahora no';

  @override
  String get homeWatchAd => 'Ver anuncio';

  @override
  String get homeFreeSpeedBoostAdded =>
      '¡Impulso de Velocidad gratis añadido a tu equipamiento!';

  @override
  String get homeAdNotFinished =>
      'Anuncio incompleto — míralo entero para ganar tu recompensa.';

  @override
  String get homePickGameMode => 'Elige un modo de juego';

  @override
  String get homePickGameModeSubtitle =>
      'Puedes cambiarlo en Ajustes cuando quieras';

  @override
  String get homeStartPlaying => 'EMPEZAR A JUGAR';

  @override
  String get homeLoadoutTitle => 'Equipamiento de potenciadores';

  @override
  String get homeLoadoutSubtitle =>
      'Precarga un potenciador — se activa 5 segundos después de empezar tu próxima partida.';

  @override
  String get homeWatchAdFreeSpeedBoost =>
      'Ver anuncio — Impulso de Velocidad gratis';

  @override
  String get homeNoPowerUps =>
      'No tienes potenciadores.\n¡Visita la tienda para comprar!';

  @override
  String homeOwnedCount(int count) {
    return 'Tienes: $count';
  }

  @override
  String get homeArmed => 'EQUIPADO';

  @override
  String get homeDone => 'LISTO';

  @override
  String get settingsTitle => 'AJUSTES';

  @override
  String get settingsBackToGame => 'VOLVER AL JUEGO';

  @override
  String get settingsSectionControls => 'CONTROLES';

  @override
  String get settingsSectionGameplay => 'JUGABILIDAD';

  @override
  String get settingsSectionAudio => 'AUDIO';

  @override
  String get settingsSectionVisual => 'VISUAL';

  @override
  String get settingsSectionNotifications => 'NOTIFICACIONES';

  @override
  String get settingsSectionUserProfile => 'PERFIL DE USUARIO';

  @override
  String get settingsSectionHelp => 'AYUDA Y TUTORIAL';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get settingsSectionPremium => 'FUNCIONES PREMIUM';

  @override
  String get settingsDPadControls => 'Controles de cruceta';

  @override
  String get settingsDPadSubtitle =>
      'Mostrar botones direccionales en pantalla durante el juego';

  @override
  String get settingsDPadPosition => 'Posición de la cruceta';

  @override
  String get settingsDesktopControls => 'Controles de escritorio/web';

  @override
  String get settingsArrowKeys => 'Teclas de flecha';

  @override
  String get settingsWasdKeys => 'Teclas WASD';

  @override
  String get settingsSpacebar => 'Barra espaciadora';

  @override
  String get settingsMouseClick => 'Clic del ratón';

  @override
  String get settingsChangeDirection => 'Cambiar dirección';

  @override
  String get settingsPauseResume => 'Pausar/Reanudar el juego';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Controles táctiles (si están disponibles)';

  @override
  String get settingsTouchControls => 'Controles táctiles';

  @override
  String get settingsSwipeGestures => 'Gestos de deslizamiento';

  @override
  String get settingsTapScreen => 'Tocar la pantalla';

  @override
  String get settingsSwipeUp => 'Deslizar arriba ↑';

  @override
  String get settingsSwipeDown => 'Deslizar abajo ↓';

  @override
  String get settingsSwipeLeft => 'Deslizar a la izquierda ←';

  @override
  String get settingsSwipeRight => 'Deslizar a la derecha →';

  @override
  String get settingsMoveSnakeUp => 'Mover la serpiente arriba';

  @override
  String get settingsMoveSnakeDown => 'Mover la serpiente abajo';

  @override
  String get settingsMoveSnakeLeft => 'Mover la serpiente a la izquierda';

  @override
  String get settingsMoveSnakeRight => 'Mover la serpiente a la derecha';

  @override
  String get settingsGameMode => 'Modo de juego';

  @override
  String get settingsGameModeLocked =>
      'Completa la partida actual para cambiar el modo';

  @override
  String get settingsDifficulty => 'Dificultad';

  @override
  String get settingsDifficultySubtitle =>
      'Define la velocidad inicial de la serpiente. Cada modo sigue acelerando al subir de nivel.';

  @override
  String get settingsEasyNote =>
      'Las monedas, XP y logros siguen contando en Fácil — solo se pausan los récords y clasificaciones.';

  @override
  String get settingsDifficultyLocked =>
      'Termina la partida actual para cambiar la dificultad.';

  @override
  String get settingsCurrentSize => 'Tamaño actual';

  @override
  String get settingsBoardSizeLocked =>
      'Completa la partida actual para cambiar el tamaño del tablero';

  @override
  String get settingsCurrentDuration => 'Duración actual';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Cuánto tiempo mostrar la explicación del choque';

  @override
  String get settingsScreenShake => 'Vibración de pantalla';

  @override
  String get settingsScreenShakeSubtitle =>
      'Sacudir la pantalla en choques y eventos del juego';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsVibrationSubtitle =>
      'Vibrar en eventos del juego y al pulsar botones';

  @override
  String get settingsSoundEffects => 'Efectos de sonido';

  @override
  String get settingsBackgroundMusic => 'Música de fondo';

  @override
  String get settingsCurrentTheme => 'Tema actual';

  @override
  String get settingsBrowseThemes => 'VER TEMAS';

  @override
  String get settingsSnakeTrail => 'Efectos de estela';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Activar estelas de partículas detrás de la serpiente';

  @override
  String get settingsNotifDailyReminder => 'Recordatorio diario';

  @override
  String get settingsNotifTournament => 'Alertas de torneo';

  @override
  String get settingsNotifAchievement => 'Logros desbloqueados';

  @override
  String get settingsNotifSocial => 'Novedades sociales';

  @override
  String get settingsNotifSpecialEvents => 'Eventos especiales';

  @override
  String get settingsNotSet => 'Sin definir';

  @override
  String get settingsUsername => 'Nombre de usuario';

  @override
  String get settingsGuestAccount => 'Cuenta de invitado';

  @override
  String get settingsAuthenticatedAccount => 'Cuenta autenticada';

  @override
  String get settingsChangeUsername => 'CAMBIAR NOMBRE DE USUARIO';

  @override
  String get settingsGuestSignInHint =>
      'Inicia sesión para conservar tu progreso y jugar con amigos';

  @override
  String get settingsUsernameVisibleHint =>
      'Tu nombre de usuario es visible para amigos y en las clasificaciones';

  @override
  String get settingsReplayTutorial => 'REPETIR TUTORIAL';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Vuelve a ver el tour de inicio o el tutorial del juego';

  @override
  String get settingsAboutCredits => 'ACERCA DE Y CRÉDITOS';

  @override
  String get settingsAboutCreditsSubtitle =>
      'Versión de la app, créditos y enlaces';

  @override
  String get settingsRateApp => 'VALORA SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      '¿Te gusta el juego? Deja una reseña en el App Store';

  @override
  String get settingsRateAppSubtitle =>
      '¿Te gusta el juego? ¡Déjanos una reseña!';

  @override
  String get settingsAdPrivacy => 'PRIVACIDAD Y ANUNCIOS';

  @override
  String get settingsAdPrivacySubtitle =>
      'Gestionar el consentimiento de anuncios personalizados';

  @override
  String get settingsAdPrivacyUnavailable =>
      'Las opciones de privacidad de anuncios no están disponibles ahora.';

  @override
  String get settingsReplayDialogTitle => 'Repetir tutorial';

  @override
  String get settingsReplayDialogBody => '¿Qué tutorial quieres repetir?';

  @override
  String get settingsHomeTour => 'Tour de inicio';

  @override
  String get settingsGameTutorial => 'Tutorial del juego';

  @override
  String get settingsPrivacyPolicyTitle => 'Política de Privacidad';

  @override
  String get settingsPrivacyPolicyButton => 'POLÍTICA DE PRIVACIDAD';

  @override
  String get settingsTermsTitle => 'Términos de Uso';

  @override
  String get settingsTermsButton => 'TÉRMINOS DE USO';

  @override
  String get settingsChangeUsernameTitle => 'Cambiar nombre de usuario';

  @override
  String get settingsCurrentLabel => 'Actual:';

  @override
  String get settingsUsernameDialogBody =>
      'Elige un nombre de usuario único que te represente en el juego.';

  @override
  String get settingsEnterNewUsername => 'Escribe el nuevo nombre de usuario';

  @override
  String get settingsUsernameRules =>
      '• 3-20 caracteres\n• Debe empezar con una letra\n• Solo letras, números y guiones bajos';

  @override
  String get settingsUsernameUpdateFailed =>
      'No se pudo actualizar el nombre de usuario';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Nombre de usuario cambiado a \"$name\"';
  }

  @override
  String get settingsUpdate => 'Actualizar';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Estado premium';

  @override
  String get settingsActiveSubscription => 'Suscripción activa';

  @override
  String get settingsUnlockPremium => 'Desbloquea funciones premium';

  @override
  String settingsRenews(String date) {
    return 'Se renueva el $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Pásate a Pro';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsPurchaseHistory => 'Historial de compras';

  @override
  String get settingsSnakeCosmetics => 'Cosméticos de serpiente';

  @override
  String get settingsBattlePass => 'Pase de Batalla';

  @override
  String settingsTier(int tier) {
    return 'Nivel $tier';
  }

  @override
  String get settingsRestoring => 'Restaurando compras...';

  @override
  String get settingsRestored => '¡Compras restauradas correctamente!';

  @override
  String get settingsRestoreFailed =>
      'No se pudieron restaurar las compras. Inténtalo de nuevo.';

  @override
  String get settingsNoPurchases => 'No se encontraron compras';

  @override
  String get settingsUnknown => 'Desconocido';

  @override
  String settingsStatusLine(String status) {
    return 'Estado: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'Fecha: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'Compra n.º $number';
  }

  @override
  String get settingsDataParseError => 'Error al leer los datos';

  @override
  String get settingsClose => 'Cerrar';

  @override
  String get settingsHistoryLoadFailed =>
      'No se pudo cargar el historial de compras';

  @override
  String get settingsUnknownDate => 'Fecha desconocida';

  @override
  String get mpLobbyNoFriends =>
      'Aún no tienes amigos — ¡añade algunos desde la pantalla de Amigos!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Invita a un amigo a la sala $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 ¡Invitación enviada a $name!';
  }

  @override
  String get mpLobbyInviteFailed =>
      'No se pudo enviar la invitación — inténtalo de nuevo';

  @override
  String get mpLobbyOffline =>
      'Estás sin conexión. El multijugador requiere internet.';

  @override
  String get mpLobbyDismiss => 'CERRAR';

  @override
  String get mpLobbyGo => '¡YA!';

  @override
  String get mpLobbyGetReady => '¡Prepárate!';

  @override
  String get mpLobbyTitle => 'MULTIJUGADOR';

  @override
  String get mpLobbySubtitle => 'Juega online con amigos';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Sala: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => '¡Código de sala copiado!';

  @override
  String get mpLobbyQuickMatch => 'PARTIDA RÁPIDA';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      '1v1 Clásico — encuentra un oponente automáticamente';

  @override
  String get mpLobbyFinding => 'BUSCANDO...';

  @override
  String get mpLobbyFindMatch => 'BUSCAR PARTIDA';

  @override
  String get mpLobbySeconds => 'seg';

  @override
  String get mpLobbySearching => 'BUSCANDO JUGADORES...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadores',
      one: '$count jugador',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Posición en la cola: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'CANCELAR';

  @override
  String get mpLobbyNoPlayersFound => 'NO SE ENCONTRARON JUGADORES';

  @override
  String get mpLobbyNoPlayersBody =>
      'Lo sentimos, no encontramos oponentes.\n¡Inténtalo de nuevo o crea tu propia sala!';

  @override
  String get mpLobbyGoBack => 'VOLVER';

  @override
  String get mpLobbyTryAgain => 'REINTENTAR';

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
  String get mpLobbyJoinRoom => 'UNIRSE A SALA';

  @override
  String get mpLobbyJoinSubtitle => 'Introduce el código de sala para unirte';

  @override
  String get mpLobbyEnterRoomCode => 'Introduce el código de sala';

  @override
  String get mpLobbyCreateRoom => 'CREAR SALA';

  @override
  String get mpLobbyCreateSubtitle => 'Crea una sala 1v1 e invita a un amigo';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'JUGADORES ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'TÚ';

  @override
  String get mpLobbyWaitingForPlayer => 'Esperando jugador...';

  @override
  String get mpLobbyStartGame => 'INICIAR PARTIDA';

  @override
  String get mpLobbyWaitingForHost => 'Esperando a que el anfitrión empiece...';

  @override
  String get mpLobbyLeave => 'SALIR';

  @override
  String get mpLobbyReadyDone => '¡LISTO!';

  @override
  String get mpLobbyReady => 'LISTO';

  @override
  String get mpModeClassicDesc => 'Batalla de serpientes tradicional';

  @override
  String get mpModeSpeedDesc => 'La velocidad aumenta con el tiempo';

  @override
  String get mpModeSurvivalDesc => 'Gana la última serpiente en pie';

  @override
  String get mpModePowerUpDesc => '¡Potenciadores por todas partes!';

  @override
  String get mpStatusWaiting => 'Esperando';

  @override
  String get mpStatusReady => 'Listo';

  @override
  String get mpStatusPlaying => 'Jugando';

  @override
  String get mpStatusCrashed => 'Chocó';

  @override
  String get mpStatusDisconnected => 'Desconectado';

  @override
  String get goNoAdAvailable =>
      'No hay anuncios disponibles ahora, inténtalo en un momento';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Monedas duplicadas — ¡+$count monedas extra!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'Mira un anuncio para duplicar tus $count monedas';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins monedas  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return '¡Reclamaste $count monedas de los desafíos diarios!';
  }

  @override
  String get goRibbonNewHighScore => '¡NUEVO RÉCORD!';

  @override
  String get goRibbonTournamentSubmitted => '¡PUNTUACIÓN DE TORNEO ENVIADA!';

  @override
  String get goRibbonTournamentFailed =>
      'PUNTUACIÓN NO ENVIADA — REVISA LA CONEXIÓN';

  @override
  String get goRibbonTournamentSubmitting => 'ENVIANDO PUNTUACIÓN DE TORNEO…';

  @override
  String get goVictory => '¡VICTORIA!';

  @override
  String get goGameOver => 'FIN DEL JUEGO';

  @override
  String get goFinalScore => 'PUNTUACIÓN FINAL';

  @override
  String get goLevel => 'NIVEL';

  @override
  String get goBest => 'RÉCORD';

  @override
  String get goCoinsEarned => 'Monedas ganadas';

  @override
  String get goDailyRewardsReady => 'RECOMPENSAS DIARIAS LISTAS';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recompensas',
      one: '$count recompensa',
    );
    return '$_temp0  •  +$coins monedas  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'RECLAMAR TODO';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'Reclamar';

  @override
  String get goAchievements => 'LOGROS';

  @override
  String get goRecentlyUnlocked => 'Desbloqueados recientemente';

  @override
  String get goInProgress => 'En progreso';

  @override
  String get goPlayAgain => 'JUGAR OTRA VEZ';

  @override
  String get goMenu => 'MENÚ';

  @override
  String get storeTitle => 'Tienda Snake';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Monedas';

  @override
  String get storeTabThemes => 'Temas';

  @override
  String get storeTabSkins => 'Aspectos';

  @override
  String get storeTabTrails => 'Estelas';

  @override
  String get storeTabPowerUps => 'Potenciadores';

  @override
  String get storeYourCoins => 'Tus Monedas Snake';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'BONO ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Suscríbete antes de que acabe tu Pro gratis';

  @override
  String get storeChooseYourPlan => 'Elige tu plan';

  @override
  String get storeWhatYouGet => 'Lo que obtienes';

  @override
  String get storeProHeroSubtitle =>
      'Todos los temas, aspectos y estelas premium · tableros grandes · 2× monedas · potenciadores premium · entradas de torneo · Pase de Batalla Premium';

  @override
  String get storeMonthly => 'Mensual';

  @override
  String get storeYearly => 'Anual';

  @override
  String get storePerMonth => '/mes';

  @override
  String get storePerYear => '/año';

  @override
  String get storeSave17 => 'Ahorra un 17%';

  @override
  String storePlanDisplayName(Object title) {
    return 'plan $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Verificando…';

  @override
  String get storeSubscribe => 'Suscribirse';

  @override
  String get storeYoureOnFreePro => '¡Tienes Pro gratis!';

  @override
  String get storeYourePro => '¡Eres Pro!';

  @override
  String get storeFreePro => 'Pro gratis';

  @override
  String get storeProMonthly => 'Pro Mensual';

  @override
  String get storeKeepPro => 'Mantener Pro — Suscribirse';

  @override
  String get storePromoBadge => 'PROMO';

  @override
  String get storeEndingSoon => 'Termina pronto';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Termina en ${days}d ${hours}h';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Termina en ${hours}h ${minutes}min';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Termina en ${minutes}min';
  }

  @override
  String get storeFeatureExtraLife =>
      'Vida extra siempre gratis — revive en cada partida, sin anuncio, sin monedas';

  @override
  String get storeFeatureNoAds =>
      'Sin anuncios — juega totalmente libre de publicidad';

  @override
  String get storeFeatureThemes => 'Los 6 temas premium';

  @override
  String get storeFeatureSkins => 'Los 11 aspectos premium';

  @override
  String get storeFeatureTrails => 'Las 11 estelas premium';

  @override
  String get storeFeatureBoards => 'Tableros premium (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => 'Ganancia de monedas 2×';

  @override
  String get storeFeaturePowerUps => '5× potenciadores premium por ciclo';

  @override
  String get storeFeatureTournaments =>
      'Entradas de torneo Bronce + Plata + Oro por ciclo';

  @override
  String get storeFeatureBattlePass =>
      'Vía Premium del Pase de Batalla cada temporada';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Iniciando compra de $name...';
  }

  @override
  String get storeSubNotAvailable =>
      'Suscripción no disponible. Inténtalo más tarde.';

  @override
  String get storePurchaseFailed => 'La compra falló. Inténtalo de nuevo.';

  @override
  String get storeBuyCoins => 'Comprar Monedas Snake';

  @override
  String get storeEarnFreeCoins => 'Gana monedas gratis';

  @override
  String get storeEarnPlay => 'Juega una partida';

  @override
  String get storeEarnPlayReward => '5 monedas por partida';

  @override
  String get storeEarnDaily => 'Inicio de sesión diario';

  @override
  String get storeEarnDailyReward => '10-50 monedas al día';

  @override
  String get storeEarnAchievements => 'Logros';

  @override
  String get storeEarnAchievementsReward => '25-100 monedas';

  @override
  String get storeEarnTournaments => 'Torneos';

  @override
  String get storeEarnTournamentsReward => 'Más de 100 monedas';

  @override
  String get storePopularBadge => 'POPULAR';

  @override
  String storeBuyItem(Object name) {
    return 'Comprar $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return '¿Comprar $coins por $price?';
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
      'Producto no disponible. Inténtalo más tarde.';

  @override
  String get storeUnlockedWithPro => 'Desbloqueado con Pro';

  @override
  String get storeIncludedWithPro => 'Incluido con Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned =>
      'Todos los temas de aquí son tuyos con tu suscripción.';

  @override
  String get storeProBannerThemesUpsell =>
      'Suscríbete a Pro para desbloquear todos los temas — sin compras separadas.';

  @override
  String get storeProBannerSkinsOwned =>
      'Todos los aspectos de aquí son tuyos con tu suscripción.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Suscríbete a Pro para desbloquear todos los aspectos — sin compras separadas.';

  @override
  String get storeProBannerTrailsOwned =>
      'Todas las estelas de aquí son tuyas con tu suscripción.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Suscríbete a Pro para desbloquear todas las estelas — sin compras separadas.';

  @override
  String get storePremiumThemes => 'Temas premium';

  @override
  String get storeFreeThemes => 'Temas gratis';

  @override
  String get storeFreeThemesSubtitle =>
      'Siempre disponibles — vuelve cuando quieras.';

  @override
  String get storeAllThemesBundle => 'Pack de Todos los Temas';

  @override
  String get storeAllThemesBundleSubtitle =>
      'Los 6 temas premium · ahorra un 33%';

  @override
  String get storePillVerifying => 'VERIFICANDO';

  @override
  String get storePillOwned => 'TUYO';

  @override
  String get storePillFree => 'GRATIS';

  @override
  String get storePillActive => 'ACTIVO';

  @override
  String get storePillApply => 'APLICAR';

  @override
  String get storePillEquipped => 'EQUIPADO';

  @override
  String get storePillEquip => 'EQUIPAR';

  @override
  String get storeThemeDescClassic => 'El aspecto original';

  @override
  String get storeThemeDescModern => 'Limpio y minimalista';

  @override
  String get storeThemeDescNeon => 'Noches de neón brillante';

  @override
  String get storeThemeDescRetro => 'Arcade ochentero de neón';

  @override
  String get storeThemeDescSpace => 'Campo de estrellas cósmico';

  @override
  String get storeThemeDescOcean => 'Azules de mar profundo';

  @override
  String get storeThemeDescCyberpunk => 'Cian eléctrico y rosa';

  @override
  String get storeThemeDescForest => 'Jungla esmeralda vívida';

  @override
  String get storeThemeDescDesert => 'Cañón y cactus turquesa';

  @override
  String get storeThemeDescCrystal => 'Azul cristalino helado';

  @override
  String storeUnlockFor(Object name, Object price) {
    return '¿Desbloquear $name por $price?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Verificando la compra de $name…';
  }

  @override
  String get storeThemeNotAvailable =>
      'Tema no disponible. Inténtalo más tarde.';

  @override
  String get storeItemNotAvailable =>
      'Artículo no disponible. Inténtalo más tarde.';

  @override
  String storeEquippedToast(Object name) {
    return '$name equipado';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 ¡Impulso de Velocidad gratis añadido a tu inventario!';

  @override
  String get storeWatchAdTitle =>
      'Ver un anuncio — Impulso de Velocidad gratis';

  @override
  String get storeWatchAdReady =>
      'Añade 1 Impulso de Velocidad a tu equipamiento';

  @override
  String get storeWatchAdNotReady => 'No hay anuncios disponibles ahora';

  @override
  String get puSpeedBoostDesc =>
      'Aumenta la velocidad de la serpiente durante 7 segundos.';

  @override
  String get puInvincibilityDesc =>
      'Atraviesa paredes y tu propio cuerpo durante 6 segundos.';

  @override
  String get puScoreMultiplierDesc => 'Puntos dobles durante 10 segundos.';

  @override
  String get puSlowMotionDesc =>
      'Ralentiza el juego para más precisión (8 segundos).';

  @override
  String get storePowerUpsInfo =>
      'Compra con monedas y luego arma uno desde el chip de equipamiento de la pantalla de inicio — se activa 5 s después de empezar tu próxima partida.';

  @override
  String get storePowerUps => 'Potenciadores';

  @override
  String get storePowerUpBundles => 'Packs de potenciadores';

  @override
  String get storeBundlesSubtitle =>
      'Desbloquea varios tipos de potenciador con descuento.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => '¡Monedas insuficientes!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return '¿Comprar 1 $name por $cost monedas?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Comprar - $cost monedas';
  }

  @override
  String get storePurchaseFailedRetry => 'La compra falló. Inténtalo de nuevo.';

  @override
  String storeAddedToLoadout(Object name) {
    return '¡$name añadido a tu equipamiento!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count monedas';
  }

  @override
  String get storeBuyUpper => 'COMPRAR';

  @override
  String get storeNeedCoins => 'FALTAN MONEDAS';

  @override
  String storeBundleUnlocked(Object name) {
    return '¡$name desbloqueado!';
  }

  @override
  String get modeClassic => 'Clásico';

  @override
  String get modeZen => 'Modo Zen';

  @override
  String get modeSpeedChallenge => 'Desafío de Velocidad';

  @override
  String get modeMultiFood => 'Multicomida';

  @override
  String get modeSurvival => 'Supervivencia';

  @override
  String get modeTimeAttack => 'Contrarreloj';

  @override
  String get modePowerUpMadness => 'Locura de Potenciadores';

  @override
  String get modePerfectGame => 'Partida Perfecta';

  @override
  String get modeClassicDesc => 'El clásico juego de la serpiente con paredes';

  @override
  String get modeZenDesc => 'Sin paredes - la serpiente atraviesa la pantalla';

  @override
  String get modeSpeedChallengeDesc =>
      'La velocidad aumenta rápidamente para el máximo desafío';

  @override
  String get modeMultiFoodDesc => 'Aparecen varias comidas a la vez';

  @override
  String get modeSurvivalDesc =>
      'Sobrevive todo lo posible con vidas limitadas';

  @override
  String get modeTimeAttackDesc => 'Puntúa todo lo posible en tiempo limitado';

  @override
  String get modePowerUpMadnessDesc =>
      'Los potenciadores aparecen mucho más a menudo — abraza el caos';

  @override
  String get modePerfectGameDesc =>
      'Nunca cruces tu propio rastro. Un paso sobre una celda visitada termina la partida.';

  @override
  String get diffEasy => 'Fácil';

  @override
  String get diffNormal => 'Normal';

  @override
  String get diffHard => 'Difícil';

  @override
  String get diffEasyDesc =>
      'Una serpiente más lenta al inicio. Las puntuaciones no van a las clasificaciones.';

  @override
  String get diffNormalDesc => 'El ritmo original de Snake Classic.';

  @override
  String get diffHardDesc => 'Empieza rápido y solo se acelera.';

  @override
  String get themeClassic => 'Clásico';

  @override
  String get themeModern => 'Moderno';

  @override
  String get themeNeon => 'Neón';

  @override
  String get themeRetro => 'Retro';

  @override
  String get themeSpace => 'Espacio';

  @override
  String get themeOcean => 'Océano';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeForest => 'Bosque';

  @override
  String get themeDesert => 'Desierto';

  @override
  String get themeCrystal => 'Cristal';

  @override
  String get dpadLeft => 'Izquierda';

  @override
  String get dpadCenter => 'Centro';

  @override
  String get dpadRight => 'Derecha';

  @override
  String get mpModeClassicBattle => 'Batalla Clásica';

  @override
  String get mpModeSpeedRun => 'Carrera Veloz';

  @override
  String get mpModeSurvivalMode => 'Modo Supervivencia';

  @override
  String get mpModePowerUpMadnessName => 'Locura de Potenciadores';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonViewAll => 'Ver todo';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get pfTitle => 'Perfil';

  @override
  String get pfSigningOut => 'Cerrando sesión...';

  @override
  String get pfGuestPlayer => 'Jugador invitado';

  @override
  String get pfVerifiedAccount => 'Cuenta verificada';

  @override
  String get pfStatistics => 'Estadísticas';

  @override
  String get pfReplays => 'Repeticiones';

  @override
  String get pfAchievements => 'Logros';

  @override
  String get pfLoadingStats => 'Cargando estadísticas...';

  @override
  String get pfHighScore => 'Récord';

  @override
  String get pfGamesPlayed => 'Partidas jugadas';

  @override
  String get pfPlayTime => 'Tiempo de juego';

  @override
  String get pfAverageScore => 'Puntuación media';

  @override
  String get pfFoodConsumed => 'Comida consumida';

  @override
  String get pfPowerUps => 'Potenciadores';

  @override
  String get pfUpgradeTitle => 'Pasar a cuenta de Google';

  @override
  String get pfUpgradeSubtitle =>
      'Guarda tu progreso y sincroniza entre dispositivos';

  @override
  String get pfBenefitSync => 'Sincronizar progreso';

  @override
  String get pfBenefitSyncSub => 'entre dispositivos';

  @override
  String get pfBenefitLeaderboards => 'Clasificaciones globales';

  @override
  String get pfBenefitLeaderboardsSub => 'compite con todo el mundo';

  @override
  String get pfBenefitSocial => 'Amigos y social';

  @override
  String get pfBenefitSocialSub => 'conecta con otros';

  @override
  String get pfSignInGoogle => 'Iniciar sesión con Google';

  @override
  String get pfSignInApple => 'Iniciar sesión con Apple';

  @override
  String get pfNoReplays => 'Aún no hay repeticiones. ¡Juega algunas partidas!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeticiones guardadas',
      one: '$count repetición guardada',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Gestión de la cuenta';

  @override
  String get pfSignOut => 'Cerrar sesión';

  @override
  String get pfDeleteAccount => 'Eliminar cuenta';

  @override
  String get pfAppleUpgradeSuccess =>
      '¡Cuenta actualizada a Apple con éxito! 🎉';

  @override
  String get pfAppleIdInUse =>
      'Ese ID de Apple ya tiene una cuenta. Cierra sesión y entra con Apple.';

  @override
  String get pfUpgradeFailed =>
      'No se pudo actualizar la cuenta. Inténtalo de nuevo.';

  @override
  String get pfUpgradeError => 'Ocurrió un error al actualizar la cuenta.';

  @override
  String get pfGoogleUpgradeSuccess =>
      '¡Cuenta actualizada a Google con éxito! 🎉';

  @override
  String get pfDeleteAccountTitle => '¿Eliminar cuenta?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'Esto elimina permanentemente tu cuenta y todo lo asociado:\n\n• Récords y estadísticas\n• Monedas y artículos comprados\n• Temas, aspectos, estelas y potenciadores\n• Progreso del pase de batalla y desafíos\n• Entradas de clasificación y amigos\n\nEsto no se puede deshacer. Las suscripciones activas deben cancelarse por separado en los ajustes de $storeName.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'la tienda de apps del dispositivo';

  @override
  String get pfAccountDeleted => 'Tu cuenta ha sido eliminada permanentemente.';

  @override
  String get pfDeleteFailed =>
      'No se pudo eliminar tu cuenta. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get pfDeleteForever => 'Eliminar para siempre';

  @override
  String get pfSignOutBody =>
      '¿Seguro que quieres cerrar sesión?\n\nTu progreso quedará guardado si has iniciado sesión con Google.';

  @override
  String get pfSignedOut => 'Sesión cerrada correctamente 👋';

  @override
  String get stLoading => 'Cargando estadísticas...';

  @override
  String get stPerformanceOverview => 'Resumen de rendimiento';

  @override
  String get stTotalGames => 'Partidas totales';

  @override
  String get stWinStreak => 'Racha de victorias';

  @override
  String get stGameActivity => 'Actividad de juego';

  @override
  String get stLongestGame => 'Partida más larga';

  @override
  String get stHighestLevel => 'Nivel más alto';

  @override
  String get stPerfectGames => 'Partidas perfectas';

  @override
  String get stFoodPowerUps => 'Comida y potenciadores';

  @override
  String get stPowerUpsUsed => 'Potenciadores usados';

  @override
  String get stFavoriteFood => 'Comida favorita';

  @override
  String get stFavoritePowerUp => 'Potenciador favorito';

  @override
  String get stPerformanceTrends => 'Tendencias de rendimiento';

  @override
  String get stOverallTrend => 'Tendencia general';

  @override
  String get stRecentAverage => 'Media reciente';

  @override
  String get stBestRecent => 'Mejor reciente';

  @override
  String get stConsistency => 'Consistencia';

  @override
  String get stScores => 'Puntuaciones';

  @override
  String get stTrendLine => 'Línea de tendencia';

  @override
  String get stPlayPatterns => 'Patrones de juego (últimos 7 días)';

  @override
  String get stWeeklyTime => 'Tiempo semanal';

  @override
  String get stMostActiveDay => 'Día más activo';

  @override
  String get stDailyActivity => 'Actividad diaria';

  @override
  String get stAchievementProgress => 'Progreso de logros';

  @override
  String get stViewAllAchievements => 'Ver todos los logros →';

  @override
  String get stViewAchievements => 'VER LOGROS';

  @override
  String get stReplaysUpper => 'REPETICIONES';

  @override
  String get stResetStatistics => 'RESTABLECER ESTADÍSTICAS';

  @override
  String get stResetTitle => '¿Restablecer estadísticas?';

  @override
  String get stResetBody =>
      'Esto eliminará permanentemente todas tus estadísticas de juego. Esta acción no se puede deshacer.';

  @override
  String get stReset => 'Restablecer';

  @override
  String get stNA => 'N/D';

  @override
  String get stExcellent => 'Excelente';

  @override
  String get stGood => 'Bueno';

  @override
  String get stFair => 'Aceptable';

  @override
  String get stPoor => 'Flojo';

  @override
  String get stNoData => 'Sin datos';

  @override
  String get stNone => 'Ninguno';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '$count partida',
    );
    return 'Progreso (últimas $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent completado';
  }

  @override
  String get stInsights => 'Análisis de rendimiento';

  @override
  String get stInsightPlayMore =>
      '¡Juega más partidas para recibir análisis de rendimiento!';

  @override
  String get stInsightImproving =>
      '¡Buen trabajo! Tu rendimiento va en ascenso.';

  @override
  String get stInsightAboveAverage =>
      'Tus partidas recientes están muy por encima de tu media.';

  @override
  String get stInsightDeclined =>
      'Tu rendimiento ha bajado últimamente. Considera practicar más.';

  @override
  String get stInsightPractice =>
      'Céntrate en evitar choques y planificar tus movimientos.';

  @override
  String get stInsightStable => 'Tu rendimiento es estable. ¡Rétate a mejorar!';

  @override
  String get stInsightPotential =>
      'Tienes potencial para récords - trabaja la consistencia.';

  @override
  String get stInsightSolid =>
      'Mantienes un rendimiento sólido en las partidas recientes.';

  @override
  String get frTitle => 'Amigos';

  @override
  String get frBlockedUsers => 'Usuarios bloqueados';

  @override
  String get frSearchHint => 'Buscar por nombre o correo...';

  @override
  String get frSearching => 'Buscando...';

  @override
  String get frSearchTitle => 'Buscar amigos';

  @override
  String get frSearchSubtitle =>
      'Escribe un nombre o correo para encontrar amigos';

  @override
  String get frNoUsersFound => 'No se encontraron usuarios';

  @override
  String get frNoUsersFoundSub => 'Prueba con otro nombre o correo';

  @override
  String get frRequests => 'Solicitudes';

  @override
  String get frSearch => 'Buscar';

  @override
  String get frNoCacheYet => 'Aún sin caché';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Actualizado $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · error al actualizar, toca para reintentar';
  }

  @override
  String get frJustNow => 'justo ahora';

  @override
  String frSecondsAgo(Object count) {
    return 'hace ${count}s';
  }

  @override
  String frMinutesAgo(Object count) {
    return 'hace ${count}min';
  }

  @override
  String frHoursAgo(Object count) {
    return 'hace ${count}h';
  }

  @override
  String frDaysAgo(Object count) {
    return 'hace ${count}d';
  }

  @override
  String get frLoadingFriends => 'Cargando amigos...';

  @override
  String get frNoFriendsYet => 'Aún sin amigos';

  @override
  String get frNoFriendsSub => '¡Busca usuarios para añadirlos como amigos!';

  @override
  String get frNoRequests => 'Sin solicitudes de amistad';

  @override
  String get frNoRequestsSub => 'Las solicitudes de amistad aparecerán aquí';

  @override
  String get frChallengeMenu => 'Desafiar a una partida';

  @override
  String get frViewProfile => 'Ver perfil';

  @override
  String get frRemoveFriend => 'Eliminar amigo';

  @override
  String get frBlockUser => 'Bloquear usuario';

  @override
  String frReceivedHeader(Object count) {
    return 'Recibidas ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Enviadas ($count)';
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
    return 'Enviada $date';
  }

  @override
  String get frPending => 'Pendiente';

  @override
  String get frCancelRequest => 'Cancelar solicitud';

  @override
  String get frReject => 'Rechazar';

  @override
  String get frAccept => 'Aceptar';

  @override
  String get frAlreadyFriends => '✓ Amigos';

  @override
  String get frAddFriend => 'Añadir';

  @override
  String get frSendRequestFailed =>
      'No se pudo enviar la solicitud — revisa tu conexión e inténtalo de nuevo';

  @override
  String get frAcceptFailed =>
      'No se pudo aceptar la solicitud — revisa tu conexión e inténtalo de nuevo';

  @override
  String get frRejectFailed =>
      'No se pudo rechazar la solicitud — revisa tu conexión e inténtalo de nuevo';

  @override
  String get frCancelFailed =>
      'No se pudo cancelar la solicitud — revisa tu conexión e inténtalo de nuevo';

  @override
  String get frBlockFailed =>
      'No se pudo bloquear al usuario — revisa tu conexión e inténtalo de nuevo';

  @override
  String get frSignInSocial =>
      'Inicia sesión para añadir amigos y usar las funciones sociales';

  @override
  String get frRequestSent => '¡Solicitud de amistad enviada!';

  @override
  String get frRequestAccepted => '¡Solicitud de amistad aceptada!';

  @override
  String get frRequestRejected => 'Solicitud de amistad rechazada';

  @override
  String get frRequestCancelled => 'Solicitud de amistad cancelada';

  @override
  String frChallengeSent(Object name) {
    return '🎮 ¡Desafío enviado a $name!';
  }

  @override
  String get frChallengeFailed =>
      'No se pudo enviar el desafío — inténtalo de nuevo';

  @override
  String frBlocked(Object name) {
    return '$name bloqueado';
  }

  @override
  String frUnblocked(Object name) {
    return '$name desbloqueado';
  }

  @override
  String get frUnblockFailed => 'No se pudo desbloquear — inténtalo de nuevo';

  @override
  String frRemoved(Object name) {
    return '$name eliminado de tus amigos';
  }

  @override
  String frBlockTitle(Object name) {
    return '¿Bloquear a $name?';
  }

  @override
  String get frBlockBody =>
      'Se eliminará de tus amigos y no podrá enviarte solicitudes de amistad ni desafíos. No recibirá ninguna notificación.';

  @override
  String get frBlock => 'Bloquear';

  @override
  String get frNoBlocked => 'No has bloqueado a nadie.';

  @override
  String get frUnblock => 'Desbloquear';

  @override
  String frHighScoreLine(Object score) {
    return 'Récord: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Partidas totales: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Nivel: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Estado: \"$status\"';
  }

  @override
  String frRemoveBody(Object name) {
    return '¿Eliminar a $name de tu lista de amigos?';
  }

  @override
  String get frRemove => 'Eliminar';

  @override
  String get frLeaderboardTitle => 'Clasificación de amigos';

  @override
  String get frLeaderboardSubtitle => 'Compite con tus amigos';

  @override
  String get frLoadingLeaderboard => 'Cargando clasificación...';

  @override
  String frRankBadge(Object rank) {
    return 'n.º $rank';
  }

  @override
  String get frYou => 'TÚ';

  @override
  String get frLeaderboardEmptySub =>
      '¡Añade amigos para ver tu clasificación privada!';

  @override
  String get frAddFriends => 'Añadir amigos';

  @override
  String get tnTitle => 'Torneos';

  @override
  String get tnActive => 'Activos';

  @override
  String get tnHistory => 'Historial';

  @override
  String get tnMyStats => 'Mis estadísticas';

  @override
  String get tnLoading => 'Cargando torneos...';

  @override
  String get tnNoActive => 'Sin torneos activos';

  @override
  String get tnNoActiveSub => '¡Vuelve más tarde para ver nuevos torneos!';

  @override
  String get tnNoHistory => 'Sin historial de torneos';

  @override
  String get tnNoHistorySub => '¡Participa en torneos para ver tu historial!';

  @override
  String get tnNoStats => 'Sin estadísticas de torneos';

  @override
  String get tnNoStatsSub => '¡Únete a torneos para seguir tu progreso!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max jugadores';
  }

  @override
  String get tnJoined => 'Inscrito';

  @override
  String tnBestScoreChip(Object score) {
    return 'Mejor: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Puesto n.º $rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recompensas disponibles',
      one: '$count recompensa disponible',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'Ver detalles →';

  @override
  String get tnOverviewCard => 'Resumen de torneos';

  @override
  String get tnWins => 'Victorias';

  @override
  String get tnTopThree => 'Top 3';

  @override
  String get tnBestScore => 'Mejor puntuación';

  @override
  String get tnDetailedStats => 'Estadísticas detalladas';

  @override
  String get tnTotalAttempts => 'Intentos totales';

  @override
  String get tnWinRate => 'Tasa de victorias';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'Rendimiento medio';

  @override
  String tnTopPercent(Object percent) {
    return 'Top $percent%';
  }

  @override
  String get tnNotFound => 'Torneo no encontrado';

  @override
  String get tnLoadFailed => 'No se pudo cargar el torneo';

  @override
  String get tnLoadingTournament => 'Cargando torneo...';

  @override
  String get tnGoBack => 'Volver';

  @override
  String get tnParticipating => '¡Estás participando!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Mejor: $score • Intentos: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Puesto n.º $rank';
  }

  @override
  String get tnOverview => 'Resumen';

  @override
  String get tnLeaderboard => 'Clasificación';

  @override
  String get tnRules => 'Reglas';

  @override
  String get tnLeaderboardFailed => 'No se pudo cargar la clasificación';

  @override
  String get tnCheckConnection => 'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get tnNoParticipants => 'Aún no hay participantes';

  @override
  String get tnBeFirst => '¡Sé el primero en unirte!';

  @override
  String get tnDescription => 'Descripción';

  @override
  String get tnRewards => 'Recompensas';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos',
      one: '$count intento',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Reglas del torneo';

  @override
  String get tnScoringSystem => 'Sistema de puntuación';

  @override
  String get tnScoringBody =>
      'Tu puntuación más alta durante el periodo del torneo contará para la clasificación final. Puedes jugar varias veces para mejorarla.';

  @override
  String get tnJoining => 'UNIÉNDOTE…';

  @override
  String get tnJoin => 'UNIRSE AL TORNEO';

  @override
  String get tnPlayNow => 'JUGAR AHORA';

  @override
  String get tnProUnlimited => 'Pro · Entradas ilimitadas';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Entradas restantes: $count';
  }

  @override
  String get tnNoEntries => 'Sin entradas — toca UNIRSE para comprar';

  @override
  String tnStarts(Object time) {
    return 'Empieza $time';
  }

  @override
  String get tnRule1 =>
      'Juega durante el periodo del torneo para que tus puntuaciones cuenten';

  @override
  String get tnRule2 =>
      'Puedes jugar varias veces - solo cuenta tu puntuación más alta';

  @override
  String get tnRule3 => 'Debes iniciar sesión para participar';

  @override
  String get tnRule4 =>
      'La clasificación final se determina al terminar el torneo';

  @override
  String get tnRuleSpeed =>
      'La velocidad del juego aumenta rápido cada 10 puntos';

  @override
  String get tnRuleSurvival =>
      'La puntuación se basa en el tiempo de supervivencia, no en la comida';

  @override
  String get tnRuleNoWalls =>
      'La serpiente atraviesa los bordes en lugar de chocar con las paredes';

  @override
  String get tnRulePowerUps => 'Los potenciadores aparecen cada 5 segundos';

  @override
  String get tnRulePerfect => 'Cualquier choque termina la partida al instante';

  @override
  String get tnRuleClassic => 'Se aplican las reglas clásicas de la serpiente';

  @override
  String get tnJoinSuccess => '¡Te has unido al torneo!';

  @override
  String get tnJoinFailed => 'No se pudo unir al torneo';

  @override
  String get tnJoinError => 'Error al unirse al torneo';

  @override
  String get tnTierBronze => 'Bronce';

  @override
  String get tnTierSilver => 'Plata';

  @override
  String get tnTierGold => 'Oro';

  @override
  String get tnEntryRequired => 'Entrada necesaria';

  @override
  String tnEntryNeeded(Object tier) {
    return 'Necesitas una entrada $tier para unirte a este torneo.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Entradas $tier actuales: $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Los suscriptores Pro tienen acceso ilimitado a los torneos.';

  @override
  String get tnFreeBronzeAdded => '🎉 ¡Entrada Bronce gratis añadida!';

  @override
  String get tnFreeEntryAd => 'Entrada gratis (anuncio)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Comprar entrada $tier - $price';
  }

  @override
  String get acAll => 'Todos';

  @override
  String get acUnlocked => 'Desbloqueados';

  @override
  String get acLocked => 'Bloqueados';

  @override
  String get acTotalUpper => 'TOTAL';

  @override
  String get acUnlockedUpper => 'DESBLOQUEADOS';

  @override
  String get acClaimedUpper => 'RECLAMADOS';

  @override
  String get acPendingUpper => 'PENDIENTES';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% completado';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% de los desbloqueados';
  }

  @override
  String get acEmpty => 'No hay logros aquí';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Desbloqueado $date';
  }

  @override
  String get rpTitle => 'Repeticiones';

  @override
  String get rpRecent => 'Recientes';

  @override
  String get rpBest => 'Mejores';

  @override
  String get rpCrashes => 'Choques';

  @override
  String get rpLoading => 'Cargando repeticiones...';

  @override
  String get rpNoRecent => 'Sin repeticiones recientes';

  @override
  String get rpNoBest => 'Sin repeticiones de récord';

  @override
  String get rpNoCrashes => 'Sin repeticiones de choques';

  @override
  String get rpEmptySub => '¡Juega algunas partidas para generar repeticiones!';

  @override
  String get rpScore => 'Puntos';

  @override
  String get rpDuration => 'Duración';

  @override
  String get rpFood => 'Comida';

  @override
  String get rpFrames => 'Fotogramas';

  @override
  String get rpMaxLength => 'Longitud máx.';

  @override
  String get rpWatch => 'Ver';

  @override
  String get rpYesterday => 'Ayer';

  @override
  String get rpDeleteTitle => 'Eliminar repetición';

  @override
  String rpDeleteBody(Object date) {
    return '¿Eliminar la repetición de $date?';
  }

  @override
  String get rpDelete => 'Eliminar';

  @override
  String get rpDeleted => 'Repetición eliminada';

  @override
  String get rpDeleteFailed => 'No se pudo eliminar la repetición';

  @override
  String get lbTitle => 'Clasificaciones';

  @override
  String get lbGlobal => 'Global';

  @override
  String get lbWeekly => 'Semanal';

  @override
  String get lbWeeklySub =>
      'Según tu mejor puntuación de la semana (se reinicia el domingo)';

  @override
  String get lbGlobalSub => 'Según tu puntuación más alta de todos los tiempos';

  @override
  String lbScoreLine(Object score) {
    return 'Puntos: $score';
  }

  @override
  String get lbLoadingGlobal => 'Cargando clasificación global...';

  @override
  String get lbLoadingWeekly => 'Cargando clasificación semanal...';

  @override
  String get lbNoScores => 'Aún no hay puntuaciones';

  @override
  String get lbBeFirst => '¡Sé el primero en marcar un récord!';

  @override
  String get lbNoWeekly => 'Sin puntuaciones esta semana';

  @override
  String get lbPlayThisWeek => '¡Juega esta semana para aparecer aquí!';

  @override
  String get lbAnonymous => 'Anónimo';

  @override
  String get lbGuestBadge => 'INVITADO';

  @override
  String get lbPts => 'pts';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas jugadas',
      one: '$count partida jugada',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '¡$name reclamado!';
  }

  @override
  String get bpTitle => 'Pase de Batalla';

  @override
  String get bpTitleUpper => 'PASE DE BATALLA';

  @override
  String get bpLoading => 'Cargando pase de batalla...';

  @override
  String get bpWatchAdXp => 'Ver anuncio — +50 XP del Pase';

  @override
  String get bpXpEarned => '¡+50 XP del Pase de Batalla!';

  @override
  String get bpSeasonEnded => 'Temporada terminada';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h restantes';
  }

  @override
  String bpDaysLeft(Object days) {
    return '${days}d restantes';
  }

  @override
  String get bpTierUpper => 'NIVEL';

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
    return '$xp / $next XP para el nivel $tier';
  }

  @override
  String get bpPremiumBadge => 'PREMIUM';

  @override
  String get bpUnlockedEverything =>
      'Has desbloqueado todos los niveles de esta temporada.';

  @override
  String get bpComingNext => 'A CONTINUACIÓN';

  @override
  String bpTierN(Object tier) {
    return 'Nivel $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a $count niveles',
      one: 'a $count nivel',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'DESBLOQUEA CON PRO';

  @override
  String get bpAvailableNow => 'DISPONIBLE AHORA';

  @override
  String bpTierAbbrev(Object tier) {
    return 'N$tier';
  }

  @override
  String get bpClaim => 'RECLAMAR';

  @override
  String get bpPremiumWaiting => 'Recompensas premium esperando';

  @override
  String get bpSubscribeToClaim => 'Suscríbete a Pro para reclamarlas.';

  @override
  String get bpHideTiers => 'Ocultar niveles';

  @override
  String bpViewAllTiers(Object count) {
    return 'Ver los $count niveles';
  }

  @override
  String get bpCollapse => 'CONTRAER';

  @override
  String get bpExpand => 'EXPANDIR';

  @override
  String get bpNow => 'AHORA';

  @override
  String bpTierUpperN(Object tier) {
    return 'NIVEL $tier';
  }

  @override
  String get bpUnlocked => 'Desbloqueado';

  @override
  String bpReachTier(Object tier) {
    return 'Alcanza el nivel $tier para desbloquear';
  }

  @override
  String get bpBetweenSeasons => 'Entre temporadas';

  @override
  String get bpNoSeasonBody =>
      'No hay ningún Pase de Batalla activo — la próxima temporada empezará automáticamente. Vuelve pronto.';

  @override
  String get bpCheckNewSeason => 'Buscar nueva temporada';

  @override
  String get pbActive => '¡Premium activo!';

  @override
  String get pbActiveSub => 'Tienes acceso a todas las funciones premium';

  @override
  String get pbHeaderSub => 'Desbloquea todo lo que ofrece el juego';

  @override
  String get pbMonthlyPlan => 'Plan mensual';

  @override
  String get pbYearlyPlan => 'Plan anual';

  @override
  String get pbSave33 => 'Ahorra un 33%';

  @override
  String get pbMostPopular => 'MÁS POPULAR';

  @override
  String get pbFeatExtraLife => 'Vida extra siempre gratis';

  @override
  String get pbFeatExtraLifeDesc =>
      'Choca y sigue — los miembros Pro reviven al instante gratis, sin anuncio y sin monedas, una vez por partida';

  @override
  String get pbFeatNoAds => 'Elimina todos los anuncios';

  @override
  String get pbFeatNoAdsDesc =>
      'Sin banners ni intersticiales — juega sin anuncios, para siempre';

  @override
  String get pbFeatThemes => 'Todos los temas premium';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'Todos los aspectos premium';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice y 5 más';

  @override
  String get pbFeatTrails => 'Todas las estelas premium';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal y 5 más';

  @override
  String get pbFeatBoards => 'Tableros grandes';

  @override
  String get pbFeatBoardsDesc => 'Juega en tableros de 35x35, 40x40 y 50x50';

  @override
  String get pbFeatCoins => 'Recompensas de monedas 2x';

  @override
  String get pbFeatCoinsDesc => 'El doble de Monedas Snake en cada partida';

  @override
  String get pbFeatLucky => 'Suerte — más comidas especiales';

  @override
  String get pbFeatLuckyDesc =>
      '+50% de probabilidad de que aparezca la rara comida especial de 50 puntos en cada partida';

  @override
  String get pbFeatPowerUps => 'Más potenciadores en el juego';

  @override
  String get pbFeatPowerUpsDesc =>
      '+30% de aparición de potenciadores en el tablero';

  @override
  String get pbFeatBundle => 'Pack de potenciadores premium';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield y Mega Invincibility por ciclo de facturación';

  @override
  String get pbFeatTournament => 'Entradas de torneo';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronce + 1× Plata + 1× Oro por ciclo de facturación';

  @override
  String get pbIncludes => 'Premium incluye:';

  @override
  String get pbProPerk => 'VENTAJA PRO';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'Suscribirse — $price$period';
  }

  @override
  String get pbReassurance =>
      'Sin compromiso • Cancela cuando quieras • Pago seguro';

  @override
  String get pbNotAvailable => 'Suscripción premium no disponible';

  @override
  String get eaTitleLink => 'Guarda tu progreso';

  @override
  String get eaTitleSignIn => 'Acceso con correo';

  @override
  String get eaExplainer =>
      'Añade un correo y una contraseña a tu cuenta para poder comprar, restaurar al reinstalar e iniciar sesión desde cualquier dispositivo.';

  @override
  String get eaLinkExisting => 'Vincular existente';

  @override
  String get eaSignIn => 'Iniciar sesión';

  @override
  String get eaCreateAccount => 'Crear cuenta';

  @override
  String get eaForgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get eaLinkToExisting => 'Vincular a cuenta existente';

  @override
  String get eaMinChars => 'Al menos 8 caracteres';

  @override
  String eaMinCharsN(Object count) {
    return 'Al menos $count caracteres';
  }

  @override
  String get eaCreateAndLink => 'Crear y vincular cuenta';

  @override
  String get eaEmail => 'Correo';

  @override
  String get eaEmailRequired => 'El correo es obligatorio';

  @override
  String get eaEmailInvalid => 'Introduce un correo válido';

  @override
  String get eaPassword => 'Contraseña';

  @override
  String get eaPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get eaForgotFirst =>
      'Escribe tu correo arriba primero y luego toca ¿Olvidaste la contraseña?';

  @override
  String eaResetSent(Object email) {
    return 'Correo de restablecimiento enviado a $email.';
  }

  @override
  String get eaErrInvalidEmail => 'Esa dirección de correo no es válida.';

  @override
  String get eaErrDisabled => 'Esta cuenta ha sido deshabilitada.';

  @override
  String get eaErrNoAccount => 'No hay ninguna cuenta con ese correo.';

  @override
  String get eaErrWrongCreds => 'Correo o contraseña incorrectos.';

  @override
  String get eaErrEmailInUse =>
      'Ya existe una cuenta con ese correo. Prueba a iniciar sesión.';

  @override
  String get eaErrWeakPassword =>
      'La contraseña es muy débil. Usa al menos 8 caracteres.';

  @override
  String get eaErrNotEnabled =>
      'El acceso con correo/contraseña no está habilitado. Contacta con soporte.';

  @override
  String get eaErrTooMany =>
      'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';

  @override
  String get eaErrNetwork => 'Error de red. Revisa tu conexión.';

  @override
  String get eaErrAlreadyLinked =>
      'Esta cuenta ya está vinculada a correo/contraseña.';

  @override
  String get eaErrRecentLogin =>
      'Por seguridad, vuelve a iniciar sesión antes de vincular.';

  @override
  String get eaErrGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get faWelcome => '¡Bienvenido a\nSnake Classic!';

  @override
  String get faChooseHow => 'Elige cómo quieres jugar:';

  @override
  String get faSigningIn => 'Iniciando sesión...';

  @override
  String get faSignInEmail => 'Iniciar sesión con correo';

  @override
  String get faContinueGuest => 'Continuar como invitado';

  @override
  String get faGuestNote =>
      'Los invitados pueden jugar y guardar el progreso localmente, pero no comprar. Inicia sesión con Apple, Google o correo cuando quieras suscribirte o comprar.';

  @override
  String get faPrivacyTerms => 'Privacidad y Términos';

  @override
  String get faReviewNote =>
      'Revisa nuestra Política de Privacidad y los Términos de Uso antes de continuar';

  @override
  String get faAgreeCheckbox =>
      'He leído y acepto la Política de Privacidad y los Términos de Uso';

  @override
  String get faContinueToSignIn => 'Continuar al inicio de sesión';

  @override
  String get faHeadsUp => 'Atención';

  @override
  String get faGuestBullet1 =>
      'Los datos de invitado se eliminan automáticamente de nuestros servidores tras 90 días de inactividad.';

  @override
  String get faGuestBullet2 =>
      'Para guardar tu progreso de forma permanente y jugar en varios dispositivos, inicia sesión con Apple, Google o correo.';

  @override
  String get faGuestBullet3 =>
      'Las cuentas de invitado no pueden comprar productos ni suscripciones. Inicia sesión si quieres pasarte a Pro o comprar cosméticos.';

  @override
  String get faChangedMind => 'He cambiado de opinión';

  @override
  String get faProceedAnyway => 'Continuar igualmente';

  @override
  String get faAppleFailed =>
      'No se pudo iniciar sesión con Apple. Inténtalo de nuevo.';

  @override
  String get faGoogleFailed =>
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get faUnexpected => 'Ocurrió un error inesperado. Inténtalo de nuevo.';

  @override
  String get faGuestFailed =>
      'No se pudo continuar como invitado. Inténtalo de nuevo.';

  @override
  String get ldInitializing => 'Inicializando Snake Classic...';

  @override
  String get ldTip1 =>
      'Planifica dos movimientos por delante — tu cola sigue por donde acaba de pasar la cabeza.';

  @override
  String get ldTip2 =>
      'La comida extra vale más puntos, pero desaparece rápido. ¡Cógela ya!';

  @override
  String get ldTip3 =>
      '¿Chocaste? Mira un anuncio rápido o gasta monedas para revivir y conservar tu puntuación.';

  @override
  String get ldTip4 =>
      'Encadena comidas sin pausa para construir un multiplicador de combo.';

  @override
  String get ldTip5 =>
      '¿Atascado en un hueco? Pégate a las paredes para ganar un instante.';

  @override
  String get ldTip6 =>
      'Los desafíos diarios y las misiones semanales acumulan monedas rápido.';

  @override
  String get ldTip7 =>
      'Snake Classic Pro desbloquea tableros más grandes y elimina todos los anuncios.';

  @override
  String get ldTip8 =>
      'El Contrarreloj premia la velocidad — y puedes ver un anuncio por +30 segundos.';

  @override
  String get ldTip9 =>
      'Los potenciadores se acumulan: arma un escudo antes de pasar por un hueco.';

  @override
  String get ldTip10 =>
      'Cambia temas, aspectos y estelas cuando quieras en la tienda para renovar el look.';

  @override
  String get ldStepCore => 'Inicializando sistemas principales...';

  @override
  String get ldStepCoreSub => 'Configurando conexión con el servidor';

  @override
  String get ldStepProfile => 'Creando tu perfil de jugador...';

  @override
  String get ldStepProfileSub => 'Generando nombre de usuario único';

  @override
  String get ldStepPrefs => 'Cargando tus preferencias...';

  @override
  String get ldStepPrefsSub => 'Sincronizando temas y ajustes';

  @override
  String get ldStepCloud => 'Sincronizando con la nube...';

  @override
  String get ldStepCloudSub => 'Comprobando que los datos estén al día';

  @override
  String get ldStepGameData => 'Cargando datos del juego...';

  @override
  String get ldStepGameDataSub => 'Obteniendo datos del juego';

  @override
  String get ldStepAudio => 'Configurando el sistema de audio...';

  @override
  String get ldStepAudioSub => 'Cargando efectos de sonido';

  @override
  String get ldStepSetup => 'Comprobando el estado de configuración...';

  @override
  String get ldStepSetupSub => '¡Casi listo!';

  @override
  String get ldWelcome => '¡Bienvenido!';

  @override
  String get ldWelcomeSub => 'Elige cómo continuar';

  @override
  String get ldReady => '¡Listo para jugar!';

  @override
  String get ldReadySub => 'Bienvenido de nuevo a Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Error de inicialización: $error';
  }

  @override
  String get ldRetrying => 'Reintentando la inicialización...';

  @override
  String get ldTagline => 'EXPERIENCIA SNAKE PREMIUM';

  @override
  String get ldLoadingUpper => 'CARGANDO';

  @override
  String get ldDidYouKnow => '¿SABÍAS QUE...?';

  @override
  String get ldGameFeatures => 'CARACTERÍSTICAS';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Juego fluido';

  @override
  String get ldFeatEffects => 'EFECTOS';

  @override
  String get ldFeatEffectsSub => 'Partículas visuales';

  @override
  String get ldFeatLevels => 'NIVELES';

  @override
  String get ldFeatLevelsSub => 'Diversión progresiva';

  @override
  String get ldFeatAudio => 'AUDIO';

  @override
  String get ldFeatAudioSub => 'Sonido envolvente';

  @override
  String get ldFeatScores => 'PUNTOS';

  @override
  String get ldFeatScoresSub => 'Rankings globales';

  @override
  String get ldFeatThemes => 'TEMAS';

  @override
  String get ldFeatThemesSub => 'Varios estilos';

  @override
  String get ldDevelopedBy => 'DESARROLLADO Y MANTENIDO POR';

  @override
  String get ldDevTagline => 'Creando experiencias móviles premium';

  @override
  String get ldInitFailedUpper => 'ERROR DE INICIALIZACIÓN';

  @override
  String get ldRetryUpper => 'REINTENTAR';

  @override
  String get pgArena => 'Inicializando la arena...';

  @override
  String get pgControls => 'Calibrando los controles...';

  @override
  String get pgSnake => 'Invocando la serpiente...';

  @override
  String get pgFood => 'Colocando la comida...';

  @override
  String get pgPowerUps => 'Cargando los potenciadores...';

  @override
  String get pgAlmost => 'Casi listo...';

  @override
  String get pgGo => '¡Ya!';

  @override
  String get pgTip1 =>
      'Mantén una dirección más tiempo para construir multiplicadores de combo.';

  @override
  String get pgTip2 => 'La comida extra da más puntos pero se esfuma rápido.';

  @override
  String get pgTip3 =>
      'Los potenciadores aparecen al azar — cógelos mientras puedas.';

  @override
  String get pgTip4 => 'Planifica dos movimientos por delante, no solo uno.';

  @override
  String get pgTip5 =>
      'Las serpientes largas giran más lento. Guarda las curvas cerradas para el inicio.';

  @override
  String get pgTip6 =>
      'El Multiplicador de Puntos se acumula con los combos para puntuaciones monstruosas.';

  @override
  String get pgTip7 =>
      'La comida especial es rara — cuando aparezca, dale prioridad.';

  @override
  String get pgTip8 => 'El Contrarreloj acelera rápido. Dosifica tus giros.';

  @override
  String get pgTip9 =>
      'En el Modo Zen las paredes se atraviesan. Úsalo para escapar de apuros.';

  @override
  String get pgTip10 =>
      'Partida Perfecta: nunca vuelvas a una celda que tu cuerpo haya tocado.';

  @override
  String get pgTip11 => 'La cruceta da giros precisos; deslizar es más rápido.';

  @override
  String get pgTip12 =>
      'Pausa cuando quieras desde el HUD — el cronómetro te espera.';

  @override
  String get pgPreparing => 'PREPARANDO LA ARENA';

  @override
  String get pgTournamentMode => 'MODO TORNEO';

  @override
  String get pgGameMode => 'MODO DE JUEGO';

  @override
  String get pgDPadControls => 'Controles de cruceta';

  @override
  String get pgSwipeControls => 'Controles de deslizamiento';

  @override
  String get pgLevel => 'NIVEL';

  @override
  String get pgBest => 'RÉCORD';

  @override
  String get pgGames => 'PARTIDAS';

  @override
  String get pgProTip => 'CONSEJO PRO';

  @override
  String get pgTapToStart => 'TOCA EN CUALQUIER LUGAR PARA EMPEZAR';

  @override
  String get wtWelcomeTitle => '¡Bienvenido al juego!';

  @override
  String get wtWelcomeMsg =>
      'Aprendamos a jugar a Snake Classic. Este tutorial rápido te mostrará lo básico.';

  @override
  String get wtHudTitle => 'Información del juego';

  @override
  String get wtHudMsg =>
      'La barra superior muestra tu puntuación, nivel y récord. ¡Sigue tu progreso mientras juegas!';

  @override
  String get wtControlsTitle => 'Desliza para moverte';

  @override
  String get wtControlsMsg =>
      'Desliza en cualquier dirección para cambiar el rumbo de la serpiente. Girará siguiendo tu gesto.';

  @override
  String get wtPracticeRightTitle => '¡Pruébalo! Desliza a la DERECHA';

  @override
  String get wtPracticeRightMsg =>
      'Desliza a la DERECHA en la pantalla para continuar.';

  @override
  String get wtPracticeUpTitle => '¡Genial! Ahora desliza hacia ARRIBA';

  @override
  String get wtPracticeUpMsg =>
      'Desliza hacia ARRIBA en la pantalla para continuar.';

  @override
  String get wtFoodTitle => 'Come para crecer';

  @override
  String get wtFoodMsg =>
      'Guía a la serpiente para comer la comida del tablero. ¡Cada comida la hace más larga!';

  @override
  String get wtComboTitle => 'Construye un combo';

  @override
  String get wtComboMsg =>
      'Come sin morir para construir un combo. Con 5 bocados logras 1,5×, con 10 logras 2×, con 20 logras 3×. El chip de fuego junto a tu puntuación se calienta y late al subir.';

  @override
  String get wtPowerUpsTitle => 'Potenciadores';

  @override
  String get wtPowerUpsMsg =>
      'De vez en cuando aparecen iconos brillantes — cómete uno para activarlo. El anillo del icono se vacía al agotarse el efecto, y el temporizador se congela si pausas.';

  @override
  String get wtWallsTitle => '¡Evita las paredes!';

  @override
  String get wtWallsMsg =>
      'No toques los bordes del tablero - ¡chocar contra una pared es fin de la partida!';

  @override
  String get wtSelfTitle => '¡No choques contigo!';

  @override
  String get wtSelfMsg =>
      'Cuando la serpiente crezca, ¡cuidado con chocar contra tu propio cuerpo!';

  @override
  String get wtPauseTitle => 'Pausa cuando quieras';

  @override
  String get wtPauseMsg =>
      'Toca el icono de pausa para congelar la partida. Desde ahí puedes reanudar, reiniciar, abrir la Guía del Juego, repetir este tutorial o alternar la cruceta.';

  @override
  String get wtReadyTitle => '¡Estás listo!';

  @override
  String get wtReadyMsg =>
      '¡Suerte! Abre la Guía del Juego en el menú de pausa cuando quieras para leer sobre combos, potenciadores, modos y avisos de choque. Mira tu Perfil para ver los logros desbloquearse.';

  @override
  String get wtStartPlaying => '¡Empezar a jugar!';

  @override
  String get wtSkipTutorial => 'Saltar tutorial';

  @override
  String get wtSwipeRightUpper => 'DESLIZA A LA DERECHA';

  @override
  String get wtSwipeLeftUpper => 'DESLIZA A LA IZQUIERDA';

  @override
  String get wtSwipeUpUpper => 'DESLIZA HACIA ARRIBA';

  @override
  String get wtSwipeDownUpper => 'DESLIZA HACIA ABAJO';

  @override
  String get wtSwipeAnywhereScreen =>
      '¡Desliza en cualquier parte de la pantalla!';

  @override
  String get wtSwipeAnywhere => '¡Desliza donde sea!';

  @override
  String get wtGotIt => '¡Entendido!';

  @override
  String get wtNext => 'Siguiente';

  @override
  String get wtSkip => 'Saltar';

  @override
  String get wtWaiting => 'Esperando...';

  @override
  String get hwPlayTitle => '¡Bienvenido a Snake Classic!';

  @override
  String get hwPlayMsg =>
      'Toca el botón JUGAR para empezar. ¡Desliza para controlar la serpiente y come para crecer!';

  @override
  String get hwCoinsTitle => 'Tus monedas';

  @override
  String get hwCoinsMsg =>
      'Gana monedas jugando, completando desafíos y con bonos diarios. ¡Úsalas en la tienda!';

  @override
  String get hwDailyTitle => 'Desafíos diarios';

  @override
  String get hwDailyMsg =>
      'Completa desafíos diarios para conseguir monedas y recompensas. ¡Desafíos nuevos cada día!';

  @override
  String get hwStoreTitle => 'La tienda';

  @override
  String get hwStoreMsg =>
      'Compra temas, aspectos, estelas y potenciadores con tus monedas. Desbloquea Pro para tableros premium y cosméticos exclusivos.';

  @override
  String get hwCosmeticsTitle => 'Aspectos y estelas';

  @override
  String get hwCosmeticsMsg =>
      'Personaliza tu serpiente aquí. Los aspectos cambian su look; las estelas dejan un brillo detrás. Consíguelos con monedas o desbloquéalos con Pro.';

  @override
  String get hwProfileTitle => 'Tu perfil';

  @override
  String get hwProfileMsg =>
      'Aquí viven tus estadísticas, logros y récords. Los logros se desbloquean al alcanzar hitos — algunos requieren un modo concreto (Clásico, Difícil, etc.). Inicia sesión para sincronizar entre dispositivos.';

  @override
  String get hwSettingsTitle => 'Ajustes';

  @override
  String get hwSettingsMsg =>
      'Personaliza tu experiencia - ¡cambia temas, controles, audio y más!';

  @override
  String get hudScoreUpper => 'PUNTOS';

  @override
  String hudScoreSemantics(Object value) {
    return 'Puntuación $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'NV$level';
  }

  @override
  String get hudTournamentBadge => 'TORNEO';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'EN PAUSA';

  @override
  String get poPremium => 'Premium';

  @override
  String get poStore => 'Tienda';

  @override
  String get poResume => 'REANUDAR';

  @override
  String get poRestart => 'REINICIAR';

  @override
  String get poHome => 'INICIO';

  @override
  String get poDPadOn => 'CRUCETA: SÍ';

  @override
  String get poDPadOff => 'CRUCETA: NO';

  @override
  String get poSound => 'SONIDO';

  @override
  String get poMusic => 'MÚSICA';

  @override
  String get poHowToPlay => 'CÓMO JUGAR';

  @override
  String get poGameGuide => 'GUÍA DEL JUEGO';

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
  String get poBites5 => '5 bocados';

  @override
  String get poBites10 => '10 bocados';

  @override
  String get poBites20 => '20 bocados';

  @override
  String get poComboHint =>
      'El chip de fuego junto a tu puntuación se calienta y late en cada nivel superado.';

  @override
  String get poPowerUpsUpper => 'POTENCIADORES';

  @override
  String get poDur7s => '7 s';

  @override
  String get poDur6s => '6 s';

  @override
  String get poDur10s => '10 s';

  @override
  String get poDur8s => '8 s';

  @override
  String get poScore2x => 'Puntos 2×';

  @override
  String get poPowerUpHint =>
      'El anillo del icono se vacía al expirar. El temporizador se congela en pausa.';

  @override
  String get poCrashUpper => 'CHOQUE';

  @override
  String get poCrashHint =>
      'Una onda roja estalla en la celda donde moriste. Al chocar contigo mismo también se resalta en amarillo el segmento golpeado.';

  @override
  String get poModesUpper => 'MODOS';

  @override
  String get poModeWallsOn => 'con paredes';

  @override
  String get poModeWallsOff => 'sin paredes';

  @override
  String get poModeFastTick => 'ritmo rápido';

  @override
  String get poModeThreeFoods => '3 comidas a la vez';

  @override
  String get poModeThreeLives => '3 vidas, acelera';

  @override
  String get poModeThreeMin => '3 min en total';

  @override
  String get poModeFrequentPowerUps => 'potenciadores frecuentes';

  @override
  String get poModeDontCross => 'no cruces tu estela';

  @override
  String get dcTitle => 'Desafíos diarios';

  @override
  String get dcNoChallenges => 'No hay desafíos disponibles';

  @override
  String get dcAllComplete => '¡Todo completo!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count de bono';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · build $build';
  }

  @override
  String get crTagline => 'El clásico juego de la serpiente, reinventado.';

  @override
  String get crChipModes => 'Modos';

  @override
  String get crChipAchievements => 'Logros';

  @override
  String get crChipDaily => 'Diario';

  @override
  String get crChipLeaderboards => 'Clasificaciones';

  @override
  String get crChipCosmetics => 'Cosméticos';

  @override
  String get crCraftedBy => 'Creado por';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · Todos los derechos reservados';
  }

  @override
  String get gbSpeedNormal => 'Normal';

  @override
  String get gbSpeedFast => 'Rápida';

  @override
  String get gbSpeedFaster => 'Más rápida';

  @override
  String get gbSpeedBlazing => 'Ardiente';

  @override
  String get gbSpeedInsane => 'Demencial';

  @override
  String get gbSpeedMax => 'MÁX';

  @override
  String get gbLength => 'Longitud';

  @override
  String get gbSpeed => 'Velocidad';

  @override
  String get gbLevel => 'Nivel';
}
