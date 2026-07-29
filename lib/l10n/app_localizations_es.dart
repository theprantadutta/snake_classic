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
}
