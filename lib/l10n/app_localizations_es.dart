// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get mpOpponent => 'Oponente';

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
  String get mpRewardProcessing => 'Procesando recompensas…';

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
  String get mpReconnectingInline => 'reconectando…';

  @override
  String get puSpeedBoost => 'Impulso de Velocidad';

  @override
  String get puInvincibility => 'Invencibilidad';

  @override
  String get puScoreMultiplier => 'Multiplicador de Puntos';

  @override
  String get puSlowMotion => 'Cámara Lenta';

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
  String get homeStartPlaying => 'EMPEZAR A JUGAR';

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
  String get settingsSnapMovement => 'Movimiento por casillas';

  @override
  String get settingsSnapMovementSubtitle =>
      'Muévete casilla a casilla como en el original. Los giros ocurren al instante.';

  @override
  String get gameTurnLeft => 'Girar a la izquierda';

  @override
  String get gameTurnRight => 'Girar a la derecha';

  @override
  String get gameTurnControls => 'Botones de giro';

  @override
  String get gameJoystick => 'Joystick';

  @override
  String get gameJoystickHint => 'Empuja para girar';

  @override
  String get wtControlOptionsTitle => '¿No te va deslizar?';

  @override
  String get wtControlOptionsMsg =>
      '¿Prefieres botones? Pausa y elige una cruceta, dos botones grandes de giro o un joystick flotante. Activa Movimiento por casillas si quieres que cada giro ocurra al instante. Todo está también en Ajustes → Controles.';

  @override
  String get insTurnButtons => 'Botones de giro';

  @override
  String get insTurnButtonsDesc =>
      'Dos botones grandes, uno en cada esquina: girar a la izquierda, girar a la derecha. Nunca marcha atrás';

  @override
  String get insJoystick => 'Joystick';

  @override
  String get insJoystickDesc =>
      'Empuja en cualquier parte de la barra hacia donde quieras ir; mantén pulsado para seguir girando';

  @override
  String get insSnap => 'Movimiento por casillas';

  @override
  String get insSnapDesc =>
      'Muévete casilla a casilla como en el original, para que los giros ocurran al instante';

  @override
  String get settingsOnScreenControls => 'Controles en pantalla';

  @override
  String get settingsOnScreenControlsDesc =>
      'Cruceta, botones de giro o joystick — elige en Disposición de botones';

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
  String get settingsGameModeLocked =>
      'Completa la partida actual para cambiar el modo';

  @override
  String get settingsEasyNote =>
      'Las monedas, XP y logros siguen contando en Fácil — solo se pausan los récords y clasificaciones.';

  @override
  String get settingsDifficultyLocked =>
      'Termina la partida actual para cambiar la dificultad.';

  @override
  String get settingsBoardSizeLocked =>
      'Completa la partida actual para cambiar el tamaño del tablero';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Cuánto tiempo mostrar la explicación del choque';

  @override
  String get settingsScreenShake => 'Vibración de pantalla';

  @override
  String get settingsScreenShakeSubtitle =>
      'Sacudir la pantalla en choques y eventos del juego';

  @override
  String get settingsBrowseThemes => 'VER TEMAS';

  @override
  String get settingsSnakeTrail => 'Efectos de estela';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Activar estelas de partículas detrás de la serpiente';

  @override
  String get settingsSectionDisplay => 'PANTALLA';

  @override
  String get settingsDisplayHz => 'Hz';

  @override
  String settingsDisplayUpTo(String rate) {
    return 'hasta $rate Hz';
  }

  @override
  String get settingsDisplayReading => 'Leyendo tu pantalla…';

  @override
  String get settingsDisplayCurrentCaption =>
      'La frecuencia a la que se actualiza tu pantalla ahora mismo.';

  @override
  String get settingsDisplayBatteryNote =>
      'El ahorro de batería está activado, así que tu pantalla puede mantenerse en su frecuencia estándar hasta que lo desactives.';

  @override
  String get settingsDisplayThermalNote =>
      'Tu dispositivo está caliente. Puede mantener una frecuencia más baja durante un rato para enfriarse; es normal.';

  @override
  String get settingsDisplaySingleRateNote =>
      'Esta pantalla funciona a una sola frecuencia de actualización, así que aquí no hay nada que desbloquear. El juego ya es todo lo fluido que puede ser en este dispositivo.';

  @override
  String get settingsDisplayFooter =>
      'Las frecuencias de actualización más altas hacen que la serpiente y los menús se sientan más fluidos, y consumen algo más de batería. Snake Classic deja esto activado por defecto y nunca anula el ahorro de energía de tu dispositivo.';

  @override
  String get settingsDisplaySupportedTitle => 'ESTA PANTALLA';

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
  String get accountSwitchTitle => '¿Iniciar sesión en una cuenta existente?';

  @override
  String get accountSwitchBody =>
      'Si esta cuenta ya jugó a Snake Classic, se restaurará su progreso y será el que conserves. Las monedas, puntuaciones y estadísticas de este dispositivo no se transfieren.\n\nPara conservar el progreso de este dispositivo, usa una cuenta con la que no hayas jugado antes.';

  @override
  String get accountSwitchConfirm => 'Iniciar sesión igualmente';

  @override
  String get settingsAuthenticatedAccount => 'Cuenta autenticada';

  @override
  String get accountNotBackedUpTitle => 'Sin copia de seguridad';

  @override
  String get accountNotBackedUpBody =>
      'Este progreso está ligado a esta instalación. Inicia sesión para recuperarlo tras reinstalar o en un teléfono nuevo.';

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
  String get legalAutoRenewDisclosureAppStore =>
      'El pago se cargará a tu cuenta de App Store al confirmar la compra. La suscripción se renueva automáticamente por el mismo precio y la misma duración, salvo que se cancele al menos 24 horas antes de que termine el periodo actual. Gestiónala o cancélala cuando quieras en los ajustes de tu cuenta después de la compra.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'El pago se cargará a tu cuenta de Google Play al confirmar la compra. La suscripción se renueva automáticamente por el mismo precio y la misma duración, salvo que se cancele al menos 24 horas antes de que termine el periodo actual. Gestiónala o cancélala cuando quieras en los ajustes de suscripciones de Google Play después de la compra.';

  @override
  String get legalTermsEulaLink => 'Términos de Uso (EULA)';

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
  String get mpLobbyGo => '¡YA!';

  @override
  String get mpLobbyGetReady => '¡Prepárate!';

  @override
  String get mpLobbyRoomCodeCopied => '¡Código de sala copiado!';

  @override
  String get mpLobbyFinding => 'BUSCANDO...';

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
  String get mpLobbyConnectionLostTitle => 'CONEXIÓN PERDIDA';

  @override
  String get mpLobbyConnectionLostBody =>
      'Tu conexión se cortó mientras buscábamos.\nComprueba el Wi-Fi o los datos móviles e inténtalo de nuevo.';

  @override
  String get mpLobbyTimedOutTitle => 'AÚN SIN PARTIDA';

  @override
  String get mpLobbyTimedOutBody =>
      'Esta búsqueda tardó más de lo debido.\nInténtalo de nuevo — normalmente se encuentra partida en menos de un minuto.';

  @override
  String get mpLobbyWaitingForConnection =>
      'Conexión perdida — esperando reconexión…';

  @override
  String get mpLobbyUnreachableTitle => 'SIN CONEXIÓN CON EL EMPAREJAMIENTO';

  @override
  String get mpLobbyUnreachableBody =>
      'No pudimos contactar con el servidor.\nComprueba tu conexión e inténtalo de nuevo.';

  @override
  String get mpLobbyGoBack => 'VOLVER';

  @override
  String get mpLobbyTryAgain => 'REINTENTAR';

  @override
  String get mpLobbyJoinRoom => 'UNIRSE A SALA';

  @override
  String get mpLobbyEnterRoomCode => 'Introduce el código de sala';

  @override
  String get mpLobbyWaitingForPlayer => 'Esperando jugador...';

  @override
  String get mpLobbyStartGame => 'INICIAR PARTIDA';

  @override
  String get mpLobbyWaitingForHost => 'Esperando a que el anfitrión empiece...';

  @override
  String get mpLobbyReadyDone => '¡LISTO!';

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
  String goAdBonusCoins(Object count) {
    return '🎉 ¡+$count monedas de bonificación por ver!';
  }

  @override
  String goClaimedTotal(Object count) {
    return '¡Reclamaste $count monedas de los desafíos diarios!';
  }

  @override
  String get goRibbonTournamentSubmitted => '¡PUNTUACIÓN DE TORNEO ENVIADA!';

  @override
  String get goRibbonTournamentFailed =>
      'PUNTUACIÓN NO ENVIADA — REVISA LA CONEXIÓN';

  @override
  String get goRibbonTournamentSubmitting => 'ENVIANDO PUNTUACIÓN DE TORNEO…';

  @override
  String goAdNoticeRewarded(Object count) {
    return 'Anuncio breve a continuación · +$count monedas por verlo';
  }

  @override
  String get goAdNoticeInterstitial =>
      'A continuación se reproduce un anuncio breve';

  @override
  String get adBreakStarting => 'Empieza el anuncio…';

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
  String storeBonusMultiplier(Object multiplier) {
    return 'BONO ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Suscríbete antes de que acabe tu Pro gratis';

  @override
  String get storeMonthly => 'Mensual';

  @override
  String get storeYearly => 'Anual';

  @override
  String get storePerMonth => '/mes';

  @override
  String get storePerYear => '/año';

  @override
  String storeFreeTrialBadge(Object days) {
    return '$days días de prueba gratis';
  }

  @override
  String get storeStartFreeTrial => 'Iniciar prueba gratis';

  @override
  String storePlanDisplayName(Object title) {
    return 'plan $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Verificando…';

  @override
  String get storeYoureOnFreePro => '¡Tienes Pro gratis!';

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
  String storeInitiatingPurchase(Object name) {
    return 'Iniciando compra de $name...';
  }

  @override
  String get storeSubNotAvailable =>
      'Suscripción no disponible. Inténtalo más tarde.';

  @override
  String get storePurchaseFailed => 'La compra falló. Inténtalo de nuevo.';

  @override
  String get storePurchasePending =>
      'Pago pendiente. Tu compra se desbloqueará cuando la tienda la confirme.';

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
  String get commonRetry => 'Reintentar';

  @override
  String get pfSigningOut => 'Cerrando sesión...';

  @override
  String get pfStatistics => 'Estadísticas';

  @override
  String get pfReplays => 'Repeticiones';

  @override
  String get pfLoadingStats => 'Cargando estadísticas...';

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
  String get frLeaderboardSubtitle => 'Compite con tus amigos';

  @override
  String get frLoadingLeaderboard => 'Cargando clasificación...';

  @override
  String frRankBadge(Object rank) {
    return 'n.º $rank';
  }

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
  String get acLocked => 'Bloqueados';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% completado';
  }

  @override
  String get acEmpty => 'No hay logros aquí';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

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
  String get lbWeeklySub =>
      'Según tu mejor puntuación de la semana (se reinicia el domingo)';

  @override
  String get lbLoadingGlobal => 'Cargando clasificación global...';

  @override
  String get lbLoadingWeekly => 'Cargando clasificación semanal...';

  @override
  String get lbNoScores => 'Aún no hay puntuaciones';

  @override
  String get lbNoWeekly => 'Sin puntuaciones esta semana';

  @override
  String get lbPlayThisWeek => '¡Juega esta semana para aparecer aquí!';

  @override
  String get lbAnonymous => 'Anónimo';

  @override
  String get lbPts => 'pts';

  @override
  String bpClaimedToast(Object name) {
    return '¡$name reclamado!';
  }

  @override
  String get bpLoading => 'Cargando pase de batalla...';

  @override
  String get bpXpEarned => '¡+50 XP del Pase de Batalla!';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h restantes';
  }

  @override
  String get bpSeasonCompleteUpper => 'TEMPORADA COMPLETA';

  @override
  String get bpSeasonCosmicSerpent => 'Temporada Serpiente Cósmica';

  @override
  String get bpUnlockedEverything =>
      'Has desbloqueado todos los niveles de esta temporada.';

  @override
  String bpTierN(Object tier) {
    return 'Nivel $tier';
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
  String get pbActiveSub => 'Tienes acceso a todas las funciones premium';

  @override
  String get pbYourPlan => 'Tu plan';

  @override
  String get pbPlanMonthly => 'Mensual';

  @override
  String get pbPlanYearly => 'Anual';

  @override
  String pbRenewsOn(Object date) {
    return 'Se renueva el $date';
  }

  @override
  String get pbSwitchToYearly => 'Cambiar a anual';

  @override
  String get pbSwitchToMonthly => 'Cambiar a mensual';

  @override
  String get pbSwitchToYearlyBlurb =>
      'Empieza hoy. Se acredita el resto del mes y ahorras un 33% al ano.';

  @override
  String get pbSwitchToMonthlyBlurb =>
      'Empieza cuando termine tu ano pagado. Hoy no se cobra nada.';

  @override
  String get pbManageSubscription => 'Gestionar suscripcion';

  @override
  String get pbManageBlurb => 'Cancela o actualiza el pago en la tienda';

  @override
  String get pbSwitchedToYearly => 'Cambiado a anual';

  @override
  String get pbSwitchedToMonthly =>
      'El plan mensual empieza al terminar este periodo';

  @override
  String get pbAllUnlocked => 'Todo esto es tuyo';

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
  String get pbFeatTournament => 'Entradas de torneo';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronce + 1× Plata + 1× Oro por ciclo de facturación';

  @override
  String get pbNotAvailable => 'Suscripción premium no disponible';

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
  String get faChooseHow => 'Elige cómo quieres jugar:';

  @override
  String get faSigningIn => 'Iniciando sesión...';

  @override
  String get faSignInEmail => 'Iniciar sesión con correo';

  @override
  String get faContinueGuest => 'Continuar como invitado';

  @override
  String get faReviewNote =>
      'Revisa nuestra Política de Privacidad y los Términos de Uso antes de continuar';

  @override
  String get faAgreeCheckbox =>
      'He leído y acepto la Política de Privacidad y los Términos de Uso';

  @override
  String get faContinueToSignIn => 'Continuar al inicio de sesión';

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
  String get ldStepCore => 'Inicializando sistemas principales...';

  @override
  String get ldStepProfile => 'Creando tu perfil de jugador...';

  @override
  String get ldStepPrefs => 'Cargando tus preferencias...';

  @override
  String get ldStepCloud => 'Sincronizando con la nube...';

  @override
  String get ldStepGameData => 'Cargando datos del juego...';

  @override
  String get ldStepAudio => 'Configurando el sistema de audio...';

  @override
  String get ldStepAds => 'Preparando recompensas...';

  @override
  String get ldStepSetup => 'Comprobando el estado de configuración...';

  @override
  String get ldWelcome => '¡Bienvenido!';

  @override
  String get ldReady => '¡Listo para jugar!';

  @override
  String ldInitFailed(Object error) {
    return 'Error de inicialización: $error';
  }

  @override
  String get ldRetrying => 'Reintentando la inicialización...';

  @override
  String get ldInitFailedUpper => 'ERROR DE INICIALIZACIÓN';

  @override
  String get ldRetryUpper => 'REINTENTAR';

  @override
  String get pgPreparing => 'PREPARANDO LA ARENA';

  @override
  String get pgTournamentMode => 'MODO TORNEO';

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
  String get wtControlsTitle => 'Dirección';

  @override
  String get wtControlsMsg =>
      'Cambia de dirección deslizando en el tablero, con una cruceta, botones de giro o joystick en pantalla, o con las flechas del teclado. Elige tu estilo en Ajustes → Controles o desde el menú de pausa.';

  @override
  String get wtPracticeRightTitle => 'Pruébalo: gira a la DERECHA';

  @override
  String get wtPracticeRightMsg =>
      'Gira a la derecha para continuar. Deslizar, pad direccional o flechas: todo vale.';

  @override
  String get wtPracticeUpTitle => 'Bien: ahora gira hacia ARRIBA';

  @override
  String get wtPracticeUpMsg => 'Gira hacia arriba para continuar.';

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
      'Toca el icono de pausa para congelar la partida. Desde ahí puedes reanudar, reiniciar, abrir la Guía del juego, repetir este tutorial, cambiar de controles o activar el Movimiento por casillas.';

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
  String get wtSwipeRightUpper => 'GIRA A LA DERECHA';

  @override
  String get wtSwipeLeftUpper => 'GIRA A LA IZQUIERDA';

  @override
  String get wtSwipeUpUpper => 'GIRA HACIA ARRIBA';

  @override
  String get wtSwipeDownUpper => 'GIRA HACIA ABAJO';

  @override
  String get wtSwipeAnywhereScreen => 'Deslizar, pad direccional o flechas';

  @override
  String get wtSwipeAnywhere => '¡Te toca!';

  @override
  String get wtGotIt => '¡Entendido!';

  @override
  String get wtNext => 'Siguiente';

  @override
  String get wtSkip => 'Saltar';

  @override
  String get wtWaiting => 'Esperando...';

  @override
  String get hwDailyTitle => 'Desafíos diarios';

  @override
  String get hwDailyMsg =>
      'Completa desafíos diarios para conseguir monedas y recompensas. ¡Desafíos nuevos cada día!';

  @override
  String get hudTournamentBadge => 'TORNEO';

  @override
  String get poStore => 'Tienda';

  @override
  String get poSnapOn => 'CASILLAS: SÍ';

  @override
  String get poSnapOff => 'CASILLAS: NO';

  @override
  String get updateReadyTitle => 'Actualización lista';

  @override
  String get updateReadyRestart => 'Reiniciar';

  @override
  String get poUpdateReady => 'REINICIAR PARA ACTUALIZAR';

  @override
  String get poHowToPlay => 'CÓMO JUGAR';

  @override
  String get poGameGuide => 'GUÍA DEL JUEGO';

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
  String get rarityCommon => 'Común';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityEpic => 'Épico';

  @override
  String get rarityLegendary => 'Legendario';

  @override
  String get rarityDiamond => 'Diamante';

  @override
  String get achTitleFirstBite => 'Primer Bocado';

  @override
  String get achDescFirstBite => 'Anota tu primer punto';

  @override
  String get achTitleGettingStarted => 'Primeros Pasos';

  @override
  String get achDescGettingStarted => 'Anota 100 puntos';

  @override
  String get achTitleHighScorer => 'Buen Anotador';

  @override
  String get achDescHighScorer => 'Anota 500 puntos en una sola partida';

  @override
  String get achTitleMasterScorer => 'Anotador Maestro';

  @override
  String get achDescMasterScorer => 'Anota 1000 puntos en una sola partida';

  @override
  String get achTitleLegendaryScorer => 'Anotador Legendario';

  @override
  String get achDescLegendaryScorer => 'Anota 2000 puntos en una sola partida';

  @override
  String get achTitleFirstGame => 'Primera Partida';

  @override
  String get achDescFirstGame => 'Juega tu primera partida';

  @override
  String get achTitleRegularPlayer => 'Jugador Habitual';

  @override
  String get achDescRegularPlayer => 'Juega 10 partidas';

  @override
  String get achTitleDedicatedPlayer => 'Jugador Dedicado';

  @override
  String get achDescDedicatedPlayer => 'Juega 50 partidas';

  @override
  String get achTitleSnakeEnthusiast => 'Entusiasta de la Serpiente';

  @override
  String get achDescSnakeEnthusiast => 'Juega 100 partidas';

  @override
  String get achTitleSnakeAddict => 'Adicto a la Serpiente';

  @override
  String get achDescSnakeAddict => 'Juega 500 partidas';

  @override
  String get achTitleSurvivor => 'Superviviente';

  @override
  String get achDescSurvivor => 'Sobrevive 60 segundos';

  @override
  String get achTitleEndurance => 'Resistencia';

  @override
  String get achDescEndurance => 'Sobrevive 2 minutos';

  @override
  String get achTitleMarathon => 'Maratón';

  @override
  String get achDescMarathon => 'Sobrevive 5 minutos';

  @override
  String get achTitleNoWalls => 'Esquiva Muros';

  @override
  String get achDescNoWalls => 'Juega 5 partidas sin chocar con los muros';

  @override
  String get achTitleSpeedster => 'Velocista';

  @override
  String get achDescSpeedster => 'Alcanza el nivel 10 (velocidad máxima)';

  @override
  String get achTitlePerfectionist => 'Perfeccionista';

  @override
  String get achDescPerfectionist =>
      'Completa una partida sin chocar contigo mismo';

  @override
  String get achTitleAllFoodTypes => 'Gourmet';

  @override
  String get achDescAllFoodTypes =>
      'Come los 3 tipos de comida en una sola partida';

  @override
  String get achTitleHalfGrand => 'Medio Millar';

  @override
  String get achDescHalfGrand => 'Anota 5.000 en una sola partida';

  @override
  String get achTitleScoreSniper => 'Francotirador de Puntos';

  @override
  String get achDescScoreSniper => 'Anota 10.000 en una sola partida';

  @override
  String get achTitleFiveDigitClub => 'Club de las Cinco Cifras';

  @override
  String get achDescFiveDigitClub => 'Anota 25.000 en una sola partida';

  @override
  String get achTitleScoreTycoon => 'Magnate de los Puntos';

  @override
  String get achDescScoreTycoon => 'Anota 50.000 en una sola partida';

  @override
  String get achTitleScoreGod => 'Dios de los Puntos';

  @override
  String get achDescScoreGod => 'Anota 100.000 en una sola partida';

  @override
  String get achTitlePointCollector => 'Coleccionista de Puntos';

  @override
  String get achDescPointCollector => 'Acumula 10.000 puntos en total';

  @override
  String get achTitlePointHoarder => 'Acaparador de Puntos';

  @override
  String get achDescPointHoarder => 'Acumula 100.000 puntos en total';

  @override
  String get achTitleHalfMillionClub => 'Club del Medio Millón';

  @override
  String get achDescHalfMillionClub => 'Acumula 500.000 puntos en total';

  @override
  String get achTitlePointMillionaire => 'Millonario de Puntos';

  @override
  String get achDescPointMillionaire => 'Acumula 1.000.000 de puntos en total';

  @override
  String get achTitleDecamillionaire => 'Decamillonario';

  @override
  String get achDescDecamillionaire => 'Acumula 10.000.000 de puntos en total';

  @override
  String get achTitleSnakeVeteran => 'Veterano de la Serpiente';

  @override
  String get achDescSnakeVeteran => 'Juega 1.000 partidas';

  @override
  String get achTitleSnakeLegend => 'Leyenda de la Serpiente';

  @override
  String get achDescSnakeLegend => 'Juega 5.000 partidas';

  @override
  String get achTitleIronWill => 'Voluntad de Hierro';

  @override
  String get achDescIronWill => 'Sobrevive 10 minutos en una sola partida';

  @override
  String get achTitleEternalSnake => 'Serpiente Eterna';

  @override
  String get achDescEternalSnake => 'Sobrevive 20 minutos en una sola partida';

  @override
  String get achTitleTimeLord => 'Señor del Tiempo';

  @override
  String get achDescTimeLord => 'Sobrevive 30 minutos en una sola partida';

  @override
  String get achTitleFirstBiteSnack => 'Primer Tentempié';

  @override
  String get achDescFirstBiteSnack => 'Come 5 comidas en una partida';

  @override
  String get achTitleHungrySnake => 'Serpiente Hambrienta';

  @override
  String get achDescHungrySnake => 'Come 20 comidas en una partida';

  @override
  String get achTitleFamished => 'Famélico';

  @override
  String get achDescFamished => 'Come 50 comidas en una partida';

  @override
  String get achTitleRavenous => 'Voraz';

  @override
  String get achDescRavenous => 'Come 100 comidas en una partida';

  @override
  String get achTitleInsatiable => 'Insaciable';

  @override
  String get achDescInsatiable => 'Come 200 comidas en una partida';

  @override
  String get achTitleBlackHoleStomach => 'Estómago de Agujero Negro';

  @override
  String get achDescBlackHoleStomach => 'Come 500 comidas en una partida';

  @override
  String get achTitleFoodieApprentice => 'Aprendiz Gourmet';

  @override
  String get achDescFoodieApprentice => 'Come 100 comidas en total';

  @override
  String get achTitleFoodiePro => 'Gourmet Profesional';

  @override
  String get achDescFoodiePro => 'Come 1.000 comidas en total';

  @override
  String get achTitleFoodieMaster => 'Maestro Gourmet';

  @override
  String get achDescFoodieMaster => 'Come 10.000 comidas en total';

  @override
  String get achTitleFoodieGod => 'Dios Gourmet';

  @override
  String get achDescFoodieGod => 'Come 50.000 comidas en total';

  @override
  String get achTitleQuickPlayer => 'Jugador Veloz';

  @override
  String get achDescQuickPlayer => 'Juega 1 hora en total';

  @override
  String get achTitleEngagedPlayer => 'Jugador Comprometido';

  @override
  String get achDescEngagedPlayer => 'Juega 10 horas en total';

  @override
  String get achTitleHardcorePlayer => 'Jugador Hardcore';

  @override
  String get achDescHardcorePlayer => 'Juega 50 horas en total';

  @override
  String get achTitleSnakeObsessed => 'Obsesionado con la Serpiente';

  @override
  String get achDescSnakeObsessed => 'Juega 100 horas en total';

  @override
  String get achTitleTouchGrass => 'Toca el Césped';

  @override
  String get achDescTouchGrass =>
      'Juega 250 horas en total — ¿y si sales un rato?';

  @override
  String get achTitleLevel5 => 'Aprendiz';

  @override
  String get achDescLevel5 => 'Alcanza el Nivel 5';

  @override
  String get achTitleLevel10 => 'Oficial';

  @override
  String get achDescLevel10 => 'Alcanza el Nivel 10';

  @override
  String get achTitleLevel25 => 'Experto';

  @override
  String get achDescLevel25 => 'Alcanza el Nivel 25';

  @override
  String get achTitleLevel50 => 'Maestro';

  @override
  String get achDescLevel50 => 'Alcanza el Nivel 50';

  @override
  String get achTitleLevel100 => 'Gran Maestro';

  @override
  String get achDescLevel100 => 'Alcanza el Nivel 100';

  @override
  String get achTitleClassicInitiate => 'Iniciado en Clásico';

  @override
  String get achDescClassicInitiate => 'Termina 10 partidas en modo Clásico';

  @override
  String get achTitleClassicVeteran => 'Veterano del Clásico';

  @override
  String get achDescClassicVeteran => 'Termina 100 partidas en modo Clásico';

  @override
  String get achTitleClassic1000 => 'Experto del Clásico';

  @override
  String get achDescClassic1000 => 'Anota 1.000 en modo Clásico';

  @override
  String get achTitleClassic5000 => 'Maestro del Clásico';

  @override
  String get achDescClassic5000 => 'Anota 5.000 en modo Clásico';

  @override
  String get achTitleZenInitiate => 'Iniciado en Zen';

  @override
  String get achDescZenInitiate => 'Termina 10 partidas Zen';

  @override
  String get achTitleZenGarden => 'Jardín Zen';

  @override
  String get achDescZenGarden => 'Anota 500 en modo Zen';

  @override
  String get achTitleZenMaster => 'Maestro Zen';

  @override
  String get achDescZenMaster => 'Anota 5.000 en modo Zen';

  @override
  String get achTitleSpeedInitiate => 'Sed de Velocidad';

  @override
  String get achDescSpeedInitiate =>
      'Termina 10 partidas de Desafío de Velocidad';

  @override
  String get achTitleSpeedrunner => 'Speedrunner';

  @override
  String get achDescSpeedrunner => 'Anota 500 en Desafío de Velocidad';

  @override
  String get achTitleLightning => 'Relámpago';

  @override
  String get achDescLightning => 'Anota 2.000 en Desafío de Velocidad';

  @override
  String get achTitleMultifoodInitiate => 'Paisaje de Comida';

  @override
  String get achDescMultifoodInitiate => 'Termina 10 partidas de MultiComida';

  @override
  String get achTitleBuffet => 'Bufé';

  @override
  String get achDescBuffet => 'Anota 1.000 en MultiComida';

  @override
  String get achTitleSmorgasbord => 'Banquete';

  @override
  String get achDescSmorgasbord => 'Anota 5.000 en MultiComida';

  @override
  String get achTitleSurvivalInitiate => 'Iniciado en Supervivencia';

  @override
  String get achDescSurvivalInitiate => 'Termina 10 partidas de Supervivencia';

  @override
  String get achTitleSurvivalPro => 'Profesional de la Supervivencia';

  @override
  String get achDescSurvivalPro => 'Sobrevive 5 minutos en modo Supervivencia';

  @override
  String get achTitleLastSnakeStanding => 'Última Serpiente en Pie';

  @override
  String get achDescLastSnakeStanding => 'Anota 2.500 en Supervivencia';

  @override
  String get achTitleTimeattackInitiate => 'Atacante del Tiempo';

  @override
  String get achDescTimeattackInitiate => 'Termina 10 partidas de Contrarreloj';

  @override
  String get achTitleBeatTheClock => 'Vence al Reloj';

  @override
  String get achDescBeatTheClock =>
      'Sobrevive los 3 minutos completos de Contrarreloj';

  @override
  String get achTitleTimeattackMaster => 'Maestro de la Contrarreloj';

  @override
  String get achDescTimeattackMaster => 'Anota 3.000 en Contrarreloj';

  @override
  String get achTitleComboStarter => 'Iniciado en Combos';

  @override
  String get achDescComboStarter => 'Logra un combo de 5x en una sola partida';

  @override
  String get achTitleComboMaster => 'Maestro de Combos';

  @override
  String get achDescComboMaster => 'Logra un combo de 10x en una sola partida';

  @override
  String get achTitleComboPro => 'Profesional de Combos';

  @override
  String get achDescComboPro => 'Logra un combo de 20x en una sola partida';

  @override
  String get achTitleComboGod => 'Dios de los Combos';

  @override
  String get achDescComboGod => 'Logra un combo de 50x en una sola partida';

  @override
  String get achTitleComboLegend => 'Leyenda de los Combos';

  @override
  String get achDescComboLegend => 'Logra un combo de 100x en una sola partida';

  @override
  String get achTitleGrowingSnake => 'Serpiente Creciente';

  @override
  String get achDescGrowingSnake => 'Haz crecer la serpiente hasta longitud 20';

  @override
  String get achTitleBigSnake => 'Serpiente Grande';

  @override
  String get achDescBigSnake => 'Haz crecer la serpiente hasta longitud 50';

  @override
  String get achTitleHugeSnake => 'Serpiente Enorme';

  @override
  String get achDescHugeSnake => 'Haz crecer la serpiente hasta longitud 100';

  @override
  String get achTitleMassiveSnake => 'Serpiente Colosal';

  @override
  String get achDescMassiveSnake =>
      'Haz crecer la serpiente hasta longitud 200';

  @override
  String get achTitleAnaconda => 'Anaconda';

  @override
  String get achDescAnaconda => 'Haz crecer la serpiente hasta longitud 500';

  @override
  String get achTitleFirstPowerUp => '¡Potenciador!';

  @override
  String get achDescFirstPowerUp => 'Recoge tu primer potenciador';

  @override
  String get achTitlePowerPlayer => 'Jugador Potente';

  @override
  String get achDescPowerPlayer => 'Recoge 10 potenciadores en total';

  @override
  String get achTitlePowerHungry => 'Hambriento de Poder';

  @override
  String get achDescPowerHungry => 'Recoge 50 potenciadores en total';

  @override
  String get achTitlePowerAddict => 'Adicto al Poder';

  @override
  String get achDescPowerAddict => 'Recoge 200 potenciadores en total';

  @override
  String get achTitlePowerMaster => 'Maestro del Poder';

  @override
  String get achDescPowerMaster => 'Recoge 1.000 potenciadores en total';

  @override
  String get achTitleVarietyPack => 'Pack Variado';

  @override
  String get achDescVarietyPack =>
      'Recoge los 4 tipos de potenciador al menos una vez';

  @override
  String get achTitleSpeedDemon => 'Demonio de la Velocidad';

  @override
  String get achDescSpeedDemon => 'Recoge 25 potenciadores de Aceleración';

  @override
  String get achTitleImmortalStreak => 'Racha Inmortal';

  @override
  String get achDescImmortalStreak =>
      'Recoge 25 potenciadores de Invencibilidad';

  @override
  String get achTitleSpecialDiet => 'Dieta Especial';

  @override
  String get achDescSpecialDiet => 'Come 50 comidas especiales en total';

  @override
  String get achTitleBonusHunter => 'Cazador de Bonus';

  @override
  String get achDescBonusHunter => 'Come 100 comidas de bonus en total';

  @override
  String get achTitleUntouchable5 => 'Intocable';

  @override
  String get achDescUntouchable5 =>
      'Completa 5 partidas perfectas (sin choques, 30s+)';

  @override
  String get achTitleUntouchable20 => 'Impecable';

  @override
  String get achDescUntouchable20 => 'Completa 20 partidas perfectas';

  @override
  String get achTitleUntouchable50 => 'Leyenda Intocable';

  @override
  String get achDescUntouchable50 => 'Completa 50 partidas perfectas';

  @override
  String get achTitleHotStreak => 'Racha Caliente';

  @override
  String get achDescHotStreak =>
      '5 partidas seguidas anotando >0 y durando 30s+';

  @override
  String get achTitleOnFire => 'En Llamas';

  @override
  String get achDescOnFire => 'Racha de 10 partidas (30s+ cada una)';

  @override
  String get achTitleUnstoppable => 'Imparable';

  @override
  String get achDescUnstoppable => 'Racha de 25 partidas (30s+ cada una)';

  @override
  String get achTitleDailyThree => 'Jugador Diario';

  @override
  String get achDescDailyThree => 'Juega 3 días consecutivos';

  @override
  String get achTitleWeekWarrior => 'Guerrero Semanal';

  @override
  String get achDescWeekWarrior => 'Juega 7 días consecutivos';

  @override
  String get achTitleVelocity => 'Velocidad';

  @override
  String get achDescVelocity =>
      'Alcanza el nivel 15 de la partida en un solo juego';

  @override
  String get achTitleMachSpeed => 'Velocidad Mach';

  @override
  String get achDescMachSpeed =>
      'Alcanza el nivel 20 de la partida en un solo juego';

  @override
  String get achTitleCosmicSnake => 'Serpiente Cósmica';

  @override
  String get achDescCosmicSnake =>
      'Alcanza el nivel 25 de la partida en un solo juego';

  @override
  String get achTitleModeExplorer => 'Explorador de Modos';

  @override
  String get achDescModeExplorer =>
      'Juega al menos una partida en 3 modos distintos';

  @override
  String get achTitleAllModePlayer => 'Jugador de Todos los Modos';

  @override
  String get achDescAllModePlayer =>
      'Juega al menos una partida en cada modo (8 modos)';

  @override
  String get achTitleNightOwl => 'Búho Nocturno';

  @override
  String get achDescNightOwl =>
      'Termina una partida entre medianoche y las 5 AM';

  @override
  String get achTitleEarlyBird => 'Madrugador';

  @override
  String get achDescEarlyBird => 'Termina una partida entre las 5 y las 8 AM';

  @override
  String get achTitleWeekendWarrior => 'Guerrero del Fin de Semana';

  @override
  String get achDescWeekendWarrior => 'Termina 10 partidas en fin de semana';

  @override
  String get ppuMegaSpeedBoost => 'Mega Aceleración';

  @override
  String get ppuMegaInvincibility => 'Mega Invencibilidad';

  @override
  String get ppuMegaScoreMultiplier => 'Mega Multiplicador de Puntos';

  @override
  String get ppuMegaSlowMotion => 'Mega Cámara Lenta';

  @override
  String get ppuTeleport => 'Teletransporte';

  @override
  String get ppuSizeReducer => 'Reductor de Tamaño';

  @override
  String get ppuScoreShield => 'Escudo de Puntos';

  @override
  String get ppuComboMultiplier => 'Multiplicador de Combos';

  @override
  String get ppuTimeWarp => 'Distorsión Temporal';

  @override
  String get ppuMagneticFood => 'Comida Magnética';

  @override
  String get ppuGhostMode => 'Modo Fantasma';

  @override
  String get ppuDoubleTrouble => 'Doble Problema';

  @override
  String get ppuLuckyCharm => 'Amuleto de la Suerte';

  @override
  String get ppuPowerSurge => 'Oleada de Poder';

  @override
  String get bundleMegaPack => 'Pack Mega Poder';

  @override
  String get bundleMegaPackDesc =>
      'Versiones mejoradas de los potenciadores clásicos';

  @override
  String get skinClassic => 'Clásica';

  @override
  String get skinGolden => 'Serpiente Dorada';

  @override
  String get skinRainbow => 'Serpiente Arcoíris';

  @override
  String get skinGalaxy => 'Serpiente Galaxia';

  @override
  String get skinDragon => 'Serpiente Dragón';

  @override
  String get skinElectric => 'Serpiente Eléctrica';

  @override
  String get skinFire => 'Serpiente de Fuego';

  @override
  String get skinIce => 'Serpiente de Hielo';

  @override
  String get skinShadow => 'Serpiente Sombría';

  @override
  String get skinNeon => 'Serpiente Neón';

  @override
  String get skinCrystal => 'Serpiente de Cristal';

  @override
  String get skinCosmic => 'Serpiente Cósmica';

  @override
  String get skinClassicDesc => 'La apariencia original de la serpiente';

  @override
  String get skinGoldenDesc =>
      'Serpiente de oro reluciente que brilla con cada movimiento';

  @override
  String get skinRainbowDesc =>
      'Una serpiente colorida que cambia por los colores del arcoíris';

  @override
  String get skinGalaxyDesc => 'Serpiente cósmica con patrones estrellados';

  @override
  String get skinDragonDesc =>
      'Serpiente feroz con escamas de dragón y poderes místicos';

  @override
  String get skinElectricDesc => 'Crepitando con energía eléctrica';

  @override
  String get skinFireDesc => 'Ardiendo con patrones de fuego';

  @override
  String get skinIceDesc => 'Belleza congelada con efectos cristalinos';

  @override
  String get skinShadowDesc => 'Serpiente sombría, oscura y misteriosa';

  @override
  String get skinNeonDesc => 'Brillando con luces de neón cyberpunk';

  @override
  String get skinCrystalDesc =>
      'Serpiente de cristal translúcida con efectos prismáticos';

  @override
  String get skinCosmicDesc =>
      'Serpiente hecha de polvo de estrellas y materia cósmica';

  @override
  String get trailNone => 'Sin Estela';

  @override
  String get trailParticle => 'Estela de Partículas';

  @override
  String get trailGlow => 'Estela Brillante';

  @override
  String get trailRainbow => 'Estela Arcoíris';

  @override
  String get trailFire => 'Estela de Fuego';

  @override
  String get trailElectric => 'Estela Eléctrica';

  @override
  String get trailStar => 'Estela de Estrellas';

  @override
  String get trailCosmic => 'Estela Cósmica';

  @override
  String get trailNeon => 'Estela de Neón';

  @override
  String get trailShadow => 'Estela Sombría';

  @override
  String get trailCrystal => 'Estela de Cristal';

  @override
  String get trailDragon => 'Estela de Dragón';

  @override
  String get trailNoneDesc => 'Serpiente limpia, sin efectos de estela';

  @override
  String get trailParticleDesc => 'Deja una estela de partículas centelleantes';

  @override
  String get trailGlowDesc =>
      'Estela brillante que se desvanece tras la serpiente';

  @override
  String get trailRainbowDesc => 'Colorido efecto de estela arcoíris';

  @override
  String get trailFireDesc => 'Estela de fuego ardiente con brasas';

  @override
  String get trailElectricDesc =>
      'Estela eléctrica crepitante con efectos de rayos';

  @override
  String get trailStarDesc =>
      'Estrellas titilantes siguen el camino de la serpiente';

  @override
  String get trailCosmicDesc => 'Efectos de polvo cósmico y nebulosa';

  @override
  String get trailNeonDesc => 'Brillo de neón intenso con estilo cyberpunk';

  @override
  String get trailShadowDesc => 'Estela de sombras oscuras con efectos de humo';

  @override
  String get trailCrystalDesc => 'Fragmentos cristalinos que se desvanecen';

  @override
  String get trailDragonDesc => 'Estela mística de aliento de dragón';

  @override
  String get coinPackSmall => 'Pack Inicial';

  @override
  String get coinPackMedium => 'Pack de Valor';

  @override
  String get coinPackLarge => 'Pack Premium';

  @override
  String get coinPackMega => 'Pack Definitivo';

  @override
  String coinsAmount(Object coins) {
    return '$coins monedas';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus de bonus';
  }

  @override
  String get boardSmall => 'Pequeño';

  @override
  String get boardClassic => 'Clásico';

  @override
  String get boardLarge => 'Grande';

  @override
  String get boardHuge => 'Enorme';

  @override
  String get boardEpic => 'Épico';

  @override
  String get boardMassive => 'Colosal';

  @override
  String get boardUltimate => 'Definitivo';

  @override
  String get boardSmallDesc => 'Partidas rápidas, espacios ajustados';

  @override
  String get boardClassicDesc => 'La experiencia Snake original';

  @override
  String get boardLargeDesc => 'Más espacio para crecer';

  @override
  String get boardHugeDesc => 'Desafío y espacio máximos';

  @override
  String get boardEpicDesc => 'Un tablero grande para jugadores avanzados';

  @override
  String get boardMassiveDesc => 'Tablero gigantesco para partidas épicas';

  @override
  String get boardUltimateDesc => 'El tablero más grande posible';

  @override
  String get crashLabelSkip => 'Omitir';

  @override
  String get crashLabelUntilTap => 'Hasta Tocar';

  @override
  String get tgmClassic => 'Clásico';

  @override
  String get tgmSpeedRun => 'Carrera Veloz';

  @override
  String get tgmSurvival => 'Supervivencia';

  @override
  String get tgmNoWalls => 'Sin Muros';

  @override
  String get tgmPowerUpMadness => 'Locura de Potenciadores';

  @override
  String get tgmPerfectGame => 'Partida Perfecta';

  @override
  String get tgmClassicDesc => 'Reglas estándar del juego Snake';

  @override
  String get tgmSpeedRunDesc => 'La velocidad del juego aumenta rápidamente';

  @override
  String get tgmSurvivalDesc => 'Sobrevive el mayor tiempo posible';

  @override
  String get tgmNoWallsDesc =>
      'La serpiente atraviesa los bordes de la pantalla';

  @override
  String get tgmPowerUpMadnessDesc => 'Aparecen potenciadores con frecuencia';

  @override
  String get tgmPerfectGameDesc => 'Sin errores - un golpe termina la partida';

  @override
  String get ttDaily => 'Desafío Diario';

  @override
  String get ttWeekly => 'Torneo Semanal';

  @override
  String get ttSpecial => 'Evento Especial';

  @override
  String get tsUpcoming => 'Próximo';

  @override
  String get tsActive => 'Activo';

  @override
  String get tsEnded => 'Finalizado';

  @override
  String get cdEasy => 'Fácil';

  @override
  String get cdMedium => 'Medio';

  @override
  String get cdHard => 'Difícil';

  @override
  String get usOnline => 'En línea';

  @override
  String get usOffline => 'Desconectado';

  @override
  String get usPlaying => 'Jugando';

  @override
  String get bprXpBoost => 'Impulso de XP';

  @override
  String get bprCoins => 'Monedas';

  @override
  String get bprTheme => 'Tema';

  @override
  String get bprSkin => 'Skin de Serpiente';

  @override
  String get bprTrail => 'Efecto de Estela';

  @override
  String get bprPowerUp => 'Potenciador';

  @override
  String get bprTournamentEntry => 'Entrada a Torneo';

  @override
  String get bprTitle => 'Título de Jugador';

  @override
  String get bprAvatar => 'Avatar';

  @override
  String get bprSpecial => 'Recompensa Especial';

  @override
  String get bprnStarDust => 'Polvo de Estrellas';

  @override
  String get bprnEnergyPack => 'Pack de Energía';

  @override
  String get bprnBronzeEntry => 'Entrada Bronce';

  @override
  String get bprnSilverEntry => 'Entrada Plata';

  @override
  String get bprnStargazer => 'Observador de Estrellas';

  @override
  String get bprnVoyager => 'Viajero';

  @override
  String get bprnNebulaTheme => 'Tema Nebulosa';

  @override
  String get bprnStardustTrail => 'Estela de Polvo Estelar';

  @override
  String get bprnLegendaryCrate => 'Cofre Legendario';

  @override
  String get bprnMegaXp => 'Mega XP';

  @override
  String get bprnCosmicCharge => 'Carga Cósmica';

  @override
  String get bprnNovaBurst => 'Explosión de Nova';

  @override
  String get bprnGalaxySkin => 'Skin Galaxia';

  @override
  String get bprnCrystalSerpent => 'Sierpe de Cristal';

  @override
  String get bprnPlasmaWake => 'Estela de Plasma';

  @override
  String get bprnCosmicAura => 'Aura Cósmica';

  @override
  String get bprnCyberpunkTheme => 'Tema Cyberpunk';

  @override
  String get bprnCrystalTheme => 'Tema Cristal';

  @override
  String get bprnSeasonTrophy => 'Trofeo de Temporada';

  @override
  String get bprnCosmicCrown => 'Corona Cósmica';

  @override
  String get bprnCosmicLegend => 'Leyenda Cósmica';

  @override
  String get bprnStarCommander => 'Comandante Estelar';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity Monedas';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'Recompensa gratis: $type';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'Recompensa premium exclusiva: $type';
  }

  @override
  String get insHowToPlay => 'CÓMO JUGAR';

  @override
  String get insObjective => 'OBJETIVO';

  @override
  String get insObjectiveBody =>
      '¡Controla la serpiente para comer y crecer lo máximo posible sin chocar con los muros ni contigo mismo!';

  @override
  String get insControls => 'CONTROLES';

  @override
  String get insSwipeUp => 'Desliza Arriba ↑';

  @override
  String get insSwipeUpDesc => 'Mueve la serpiente hacia arriba';

  @override
  String get insSwipeDown => 'Desliza Abajo ↓';

  @override
  String get insSwipeDownDesc => 'Mueve la serpiente hacia abajo';

  @override
  String get insSwipeLeft => 'Desliza a la Izquierda ←';

  @override
  String get insSwipeLeftDesc => 'Mueve la serpiente a la izquierda';

  @override
  String get insSwipeRight => 'Desliza a la Derecha →';

  @override
  String get insSwipeRightDesc => 'Mueve la serpiente a la derecha';

  @override
  String get insArrowKeys => 'Teclas de flecha';

  @override
  String get insArrowKeysDesc => 'Cambiar dirección';

  @override
  String get insWasd => 'WASD';

  @override
  String get insWasdDesc => 'Cambiar dirección';

  @override
  String get insSpacebar => 'Barra espaciadora';

  @override
  String get insSpacebarDesc => 'Pausar/Reanudar la partida';

  @override
  String get insFoodTypes => 'TIPOS DE COMIDA';

  @override
  String get insNormalFood => 'Comida Normal';

  @override
  String get insBonusFood => 'Comida de Bonus';

  @override
  String get insSpecialFood => 'Comida Especial';

  @override
  String get insRules => 'REGLAS';

  @override
  String get insRule1 => 'Come para crecer y aumentar tu puntuación';

  @override
  String get insRule2 => 'La serpiente acelera al subir de nivel';

  @override
  String get insRule3 =>
      'La partida termina si chocas con muros o contigo mismo';

  @override
  String get insRule4 => 'La comida especial aparece cada 10 comidas normales';

  @override
  String get insRule5 => 'La comida de bonus caduca a los 15 segundos';

  @override
  String get insProTips => 'CONSEJOS PRO';

  @override
  String get insTip1 => 'Planifica tus movimientos con antelación';

  @override
  String get insTip2 => 'Usa los bordes para crear espacios seguros';

  @override
  String get insTip3 => 'Fíjate en las señales visuales de los deslizamientos';

  @override
  String get insTip4 => 'Practica en distintos niveles de dificultad';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return '¡Recibiste $coins monedas y $xp XP!';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return '¡Recibiste $coins monedas!';
  }

  @override
  String get dchWatchTo2x => 'MIRA PARA 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 ¡Duplicado! ¡+$coins monedas de bonus!';
  }

  @override
  String get dchAllCompleteTitle => '¡Todos los Desafíos Completados!';

  @override
  String get dchBonusClaimed => 'Recompensa de bonus reclamada';

  @override
  String get dchBonusPending => 'Bonus pendiente — reclama cualquier desafío';

  @override
  String get dchCheckBack => '¡Vuelve más tarde para nuevos desafíos diarios!';

  @override
  String get dchAbout => 'Acerca de los Desafíos Diarios';

  @override
  String get dchAbout1 => 'Nuevos desafíos cada día a medianoche';

  @override
  String get dchAbout2 => 'Completa desafíos para ganar monedas';

  @override
  String get dchAbout3 => 'Gana XP para subir de nivel tu perfil';

  @override
  String get dchAbout4 => '¡Completa los 3 para una recompensa de bonus!';

  @override
  String get dchAllBonusTitle => 'Bonus de Todos los Desafíos';

  @override
  String get dchAllBonusDesc =>
      'Completaste todos los desafíos diarios de hoy.';

  @override
  String get wqNoQuests => 'Aún no hay misiones semanales — vuelve el lunes';

  @override
  String get wqTitle => 'Misiones Semanales';

  @override
  String get rvNotFound => 'Repetición no encontrada';

  @override
  String get rvLoadFailed => 'Error al cargar la repetición';

  @override
  String get rvLoadingTitle => 'Cargando Repetición...';

  @override
  String get rvLoading => 'Cargando repetición...';

  @override
  String get rvGoBack => 'Volver';

  @override
  String get rvScore => 'Puntos';

  @override
  String get rvLevel => 'Nivel';

  @override
  String get rvFrame => 'Fotograma';

  @override
  String get rvTime => 'Tiempo';

  @override
  String get rvNoFrameData => 'Sin datos de fotogramas';

  @override
  String get rvSpeedLabel => 'Velocidad: ';

  @override
  String rvAteFood(Object type) {
    return '🍎 Comió comida $type';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ Recogió potenciador $type';
  }

  @override
  String get unEmpty => 'El nombre de usuario no puede estar vacío';

  @override
  String get unSetFailed => 'No se pudo establecer el nombre de usuario';

  @override
  String get unPickTitle => 'Elige tu nombre de usuario';

  @override
  String get unPickBody =>
      'Así aparecerás en la clasificación. Hemos elegido uno para ti — consérvalo o cámbialo.';

  @override
  String get unLabel => 'Nombre de usuario';

  @override
  String get unSaving => 'GUARDANDO...';

  @override
  String get unContinue => 'CONTINUAR';

  @override
  String get unChangeAnytime =>
      'Puedes cambiarlo en cualquier momento en Ajustes.';

  @override
  String unMinLength(Object min) {
    return 'El nombre de usuario debe tener al menos $min caracteres';
  }

  @override
  String unMaxLength(Object max) {
    return 'El nombre de usuario debe tener como máximo $max caracteres';
  }

  @override
  String get unPattern =>
      'El nombre de usuario debe empezar con una letra y contener solo letras, números y guiones bajos';

  @override
  String get unReserved =>
      'Este nombre de usuario está reservado y no puede usarse';

  @override
  String get unTaken => 'Este nombre de usuario ya está en uso';

  @override
  String get unUpdateFailed => 'No se pudo actualizar el nombre de usuario';

  @override
  String pcVersionLine(Object version) {
    return 'Versión $version · revisa y acepta para continuar';
  }

  @override
  String get pcTabPrivacy => 'Política de Privacidad';

  @override
  String get pcTabTerms => 'Términos de Uso';

  @override
  String get pcAgree =>
      'He leído y acepto la Política de Privacidad y los Términos de Uso actualizados';

  @override
  String get pcContinue => 'Continuar';

  @override
  String lgAvailableAt(Object url) {
    return 'Este documento está disponible en $url.';
  }

  @override
  String get lgUnavailable =>
      'Este documento no está disponible ahora mismo. Inténtalo de nuevo más tarde.';

  @override
  String get auTitle => 'Regístrate para hacer compras';

  @override
  String get auBody =>
      'Las cuentas de invitado pueden jugar y guardar el progreso localmente, pero no comprar artículos ni suscribirse. Vincula una cuenta para desbloquear las compras: tus monedas, cosméticos y récords actuales se mantienen.';

  @override
  String get auApple => 'Continuar con Apple';

  @override
  String get auAppleSub =>
      'Inicia sesión con tu Apple ID. Tu correo puede permanecer privado.';

  @override
  String get auGoogle => 'Continuar con Google';

  @override
  String get auGoogleSub =>
      'La opción más rápida. Inicia sesión con tu cuenta de Google.';

  @override
  String get auLinked => 'Cuenta vinculada. Ya puedes hacer compras.';

  @override
  String get auEmail => 'Crear una Cuenta de Correo';

  @override
  String get auEmailSub =>
      'Usa cualquier correo y una contraseña a tu elección. Restaura en cualquier dispositivo.';

  @override
  String get auNotNow => 'Ahora no';

  @override
  String get auErrCredentialInUse =>
      'Esa credencial ya está vinculada a otra cuenta. Prueba a iniciar sesión con ella.';

  @override
  String get auErrAlreadyLinked => 'Esta cuenta ya está vinculada.';

  @override
  String get auErrRequiresRecentLogin =>
      'Por seguridad, vuelve a iniciar sesión antes de vincular.';

  @override
  String get auErrNetwork => 'Error de red. Comprueba tu conexión.';

  @override
  String get auErrGeneric => 'No se pudo vincular. Inténtalo de nuevo.';

  @override
  String get sroSettingUpTitle => 'Configurando tu cuenta…';

  @override
  String get sroSettingUpBody =>
      'Preparando todo para tu primera sesión. Esto solo ocurre una vez.';

  @override
  String get sroLoadingTitle => 'Cargando tus datos anteriores…';

  @override
  String get sroLoadingBody =>
      'Obteniendo tus estadísticas, logros, monedas y desbloqueos de la nube.';

  @override
  String get sroRestoringTitle => 'Restaurando tu progreso…';

  @override
  String get sroRestoringBody =>
      'Aplicando todo a este dispositivo. No cierres la app.';

  @override
  String get sroDoneTitle => '¡Todo listo!';

  @override
  String get sroDoneBody => 'Tu progreso ha sido restaurado.';

  @override
  String get sroFailedTitle => 'No pudimos restaurar tus datos';

  @override
  String get sroFailedBody =>
      'No pudimos conectar con la nube ahora mismo. Comprueba tu conexión a internet e inténtalo de nuevo. También puedes continuar sin restaurar — lo reintentaremos la próxima vez que abras la app.';

  @override
  String get sroTryAgain => 'Reintentar';

  @override
  String get sroContinueAnyway => 'Continuar Igualmente';

  @override
  String get ssiOfflinePending =>
      'Sin conexión - Los cambios se sincronizarán al conectar';

  @override
  String get ssiSyncing => 'Sincronizando...';

  @override
  String get ssiAllSynced => 'Todos los datos sincronizados';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos no se pudieron sincronizar',
      one: '1 elemento no se pudo sincronizar',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos pendientes de sincronizar',
      one: '1 elemento pendiente de sincronizar',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'Sin conexión';

  @override
  String get rvoLoadingAd => 'Cargando anuncio…';

  @override
  String get tbTimesUp => '¡TIEMPO AGOTADO!';

  @override
  String tbKeepGoing(Object seconds) {
    return 'Sigue jugando · ${seconds}s';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'Ver anuncio — +${seconds}s';
  }

  @override
  String get tbEndRun => 'Terminar partida';

  @override
  String get dbTitle => 'Bonus Diario';

  @override
  String get dbClaimToday => '¡Reclama tu recompensa diaria!';

  @override
  String get dbComeBack => '¡Vuelve mañana!';

  @override
  String dbDayChip(Object day) {
    return 'D$day';
  }

  @override
  String get dbTodaysReward => 'Recompensa de Hoy';

  @override
  String get dbAlreadyClaimed => 'Ya reclamado hoy';

  @override
  String get dbClaim => 'RECLAMAR RECOMPENSA';

  @override
  String get dbClaim2x => 'RECLAMAR 2× — VER ANUNCIO';

  @override
  String get npPrimerTitle => '¡No te lo pierdas!';

  @override
  String get npPrimerBody =>
      'Solo enviamos un par de notificaciones al día — el recordatorio de tu desafío diario y eventos especiales.\n\nSin spam, prometido. 🐍';

  @override
  String get npMaybeLater => 'Quizás luego';

  @override
  String get npAllSet => '🎉 ¡Todo listo!';

  @override
  String get npTurnOn => 'Activar';

  @override
  String get npSoftTitle => '¿Quieres estar al tanto?';

  @override
  String get npSoftBody =>
      'Activa las notificaciones y te recordaremos tus desafíos diarios y rachas — además de lo importante, como sorteos de Premium GRATIS y eventos especiales.\n\nSolo un par al día, sin spam. 🐍';

  @override
  String get npNotNow => 'Ahora no';

  @override
  String get npEnable => 'Activar notificaciones';

  @override
  String get aroUnlocked => 'LOGRO DESBLOQUEADO';

  @override
  String get aroTapToContinue => 'Toca para continuar';

  @override
  String get aroSkip => 'SALTAR';

  @override
  String aroSkipCount(Object count) {
    return 'SALTAR ($count)';
  }

  @override
  String get luLevelUp => '¡SUBISTE DE NIVEL!';

  @override
  String luReached(Object level) {
    return 'Alcanzaste el Nivel $level';
  }

  @override
  String get luNice => 'GENIAL';

  @override
  String get cfTapContinue => 'Toca en cualquier parte para continuar';

  @override
  String get cfTapSkip => 'Toca en cualquier parte para saltar';

  @override
  String get xgTitle => '¿Salir del Juego?';

  @override
  String get xgBody =>
      '¿Seguro que quieres salir? Perderás tu progreso actual.';

  @override
  String get xgExit => 'Salir';

  @override
  String get ccTitle => '¿Cómo quieres jugar?';

  @override
  String get ccBody =>
      'Elige uno — puedes cambiarlo en cualquier momento en Ajustes → Controles.';

  @override
  String get ccSwipe => 'Gestos de Deslizamiento';

  @override
  String get ccSwipeSub => 'Desliza en cualquier parte del tablero para girar.';

  @override
  String get ccDpad => 'Controles D-Pad';

  @override
  String get ccDpadSub => 'Botones direccionales en pantalla.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 ¡+$coins monedas añadidas a tu cartera!';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'Ver un anuncio — +$coins monedas';
  }

  @override
  String get rcNoAd => 'No hay anuncios disponibles ahora';

  @override
  String get raOptIn => 'Participa — mira para ganar';

  @override
  String get compassSemantics => 'Indicador de dirección de deslizamiento';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 Bonus diario duplicado — ¡+$coins monedas de bonus!';
  }

  @override
  String get nsNewNotification => 'Tienes una notificación nueva';

  @override
  String get nsAchievementUnlocked => '🏆 ¡Logro Desbloqueado!';

  @override
  String get nsDailyReminderTitle => '🐍 ¡Hora de jugar Snake Classic!';

  @override
  String get nsDailyReminderBody =>
      '¡Completa tu desafío diario y sube en la clasificación!';

  @override
  String get mpErrMatchmaking => 'Falló el emparejamiento. Inténtalo de nuevo.';

  @override
  String get mpErrCreateFailed => 'No se pudo crear la partida';

  @override
  String get mpErrJoinFailed =>
      'No se pudo unir a la partida. Puede estar llena o no existir.';

  @override
  String get mpErrReadyFailed => 'No se pudo actualizar el estado de listo';

  @override
  String get mpErrStartFailed => 'No se pudo iniciar la partida';

  @override
  String get mpErrStartTimeout =>
      'Se agotó el tiempo al iniciar. Inténtalo de nuevo.';

  @override
  String get mpErrReconnectFailed => 'No se pudo reconectar a la partida.';

  @override
  String get mpErrConnectionLost =>
      'Conexión perdida — no se pudo reanudar la partida.';

  @override
  String get mpErrMatchEndedAway => 'La partida terminó mientras no estabas.';

  @override
  String get mpErrWaitingReady =>
      'Esperando a que todos los jugadores estén listos';

  @override
  String get mpErrOnlyHost => 'Solo el anfitrión puede iniciar la partida';

  @override
  String get mpErrSessionExpired =>
      'La sesión de juego caducó. Crea una partida nueva';

  @override
  String get mpErrAlreadyStarted => 'Esta partida ya ha comenzado';

  @override
  String get mpErrNeedTwoPlayers =>
      'Las partidas necesitan exactamente 2 jugadores';

  @override
  String get mpErrSignIn => 'Inicia sesión para jugar multijugador';

  @override
  String get mpErrReconnectExpired => 'El tiempo de reconexión expiró';

  @override
  String get mpErrCheckInternet => 'Conexión perdida. Comprueba tu internet';

  @override
  String get mpErrUnableJoin =>
      'No se pudo entrar a la sala. Inténtalo de nuevo';

  @override
  String get mpErrGeneric => 'Algo salió mal. Inténtalo de nuevo';

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
  String wqClaimable(Object count) {
    return '$count por reclamar';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins monedas, +$xp XP de pase';
  }

  @override
  String get insPoints10 => '10 puntos';

  @override
  String get insPoints25 => '25 puntos';

  @override
  String get insPoints50 => '50 puntos + Subes de Nivel';

  @override
  String get unRules =>
      '• 3-20 caracteres\n• Debe empezar con una letra\n• Solo letras, números y guiones bajos';

  @override
  String get dcTitleScoreEasy => 'Puntuación de Novato';

  @override
  String get dcTitleScoreMedium => 'Jugador Hábil';

  @override
  String get dcTitleScoreHard => 'Maestro de los Puntos';

  @override
  String get dcTitleFoodEasy => 'Serpiente Hambrienta';

  @override
  String get dcTitleFoodMedium => 'Modo Festín';

  @override
  String get dcTitleFoodHard => 'Insaciable';

  @override
  String get dcTitleSurvivalEasy => 'Superviviente';

  @override
  String get dcTitleSurvivalMedium => 'Resistencia';

  @override
  String get dcTitleSurvivalHard => 'Inmortal';

  @override
  String get dcTitleGamesEasy => 'Jugador Casual';

  @override
  String get dcTitleGamesMedium => 'Dedicado';

  @override
  String get dcTitleGamesHard => 'Adicto a la Serpiente';

  @override
  String get dcTitleModeEasy => 'Amante del Clásico';

  @override
  String get dcTitleModeMedium => 'Maestro Zen';

  @override
  String get dcTitleModeHard => 'Demonio de la Velocidad';

  @override
  String dcDescScore(Object target) {
    return 'Anota al menos $target puntos en una sola partida';
  }

  @override
  String dcDescFood(Object target) {
    return 'Come $target comidas hoy';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'Sobrevive $target segundos en una sola partida';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Juega $target partidas hoy',
      one: 'Juega 1 partida hoy',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Juega $target partidas en modo $mode',
      one: 'Juega 1 partida en modo $mode',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'Calentamiento Semanal';

  @override
  String get wqTitleScoreMedium => 'Reflejos Afilados';

  @override
  String get wqTitleScoreHard => 'Campeón de Puntos';

  @override
  String get wqTitleFoodEasy => 'Tentempié Semanal';

  @override
  String get wqTitleFoodMedium => 'Voraz';

  @override
  String get wqTitleFoodHard => 'Sin Fondo';

  @override
  String get wqTitleGamesEasy => 'Cinco por Semana';

  @override
  String get wqTitleGamesMedium => 'Rutina Creada';

  @override
  String get wqTitleGamesHard => 'Maratonista';

  @override
  String get wqTitleSurvivalEasy => 'Reptar de Dos Minutos';

  @override
  String get wqTitleSurvivalMedium => 'Reptar de Cinco Minutos';

  @override
  String get wqTitleSurvivalHard => 'Reptar de Diez Minutos';

  @override
  String get wqTitleTournament => 'Asiduo de Torneos';

  @override
  String get wqTitleDailyEasy => 'Cumplidor Diario';

  @override
  String get wqTitleDailyMedium => 'Experto Diario';

  @override
  String wqDescScore(Object target) {
    return 'Anota $target en una sola partida';
  }

  @override
  String wqDescFood(Object target) {
    return 'Come $target comidas esta semana';
  }

  @override
  String wqDescGames(Object target) {
    return 'Juega $target partidas esta semana';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'Sobrevive ${target}s en una sola partida';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Juega $target partidas de torneo',
      one: 'Juega 1 partida de torneo',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'Completa $target desafíos diarios esta semana';
  }

  @override
  String tnNameDaily(Object date) {
    return 'Desafío Diario - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'Campeonato Semanal - Semana $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'Gran Premio Mensual - $monthYear';
  }

  @override
  String get tnDescDaily =>
      '¡Compite por la puntuación más alta en el desafío de 24 horas de hoy! Los mejores ganan monedas y gloria.';

  @override
  String get tnDescWeekly =>
      '¡El duelo semanal definitivo! Compite contra los mejores por recompensas enormes.';

  @override
  String get tnDescMonthly =>
      '¡El torneo más grande del mes! Demuestra que eres el auténtico maestro de Snake.';

  @override
  String tnRewardRank(Object rank) {
    return 'Puesto $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'Recompensa en monedas para el puesto $rank';
  }

  @override
  String get achTitleScore1500 => 'Impulso';

  @override
  String get achDescScore1500 => 'Anota 1.500 puntos en una sola partida';

  @override
  String get achTitleScore3000 => 'En Racha';

  @override
  String get achDescScore3000 => 'Anota 3.000 puntos en una sola partida';

  @override
  String get achTitleScore7500 => 'Implacable';

  @override
  String get achDescScore7500 => 'Anota 7.500 puntos en una sola partida';

  @override
  String get achTitleScore15000 => 'Cazador Supremo';

  @override
  String get achDescScore15000 => 'Anota 15.000 puntos en una sola partida';

  @override
  String get achTitleScore35000 => 'Mente de Máquina';

  @override
  String get achDescScore35000 => 'Anota 35.000 puntos en una sola partida';

  @override
  String get achTitleScore75000 => 'Más Allá de lo Mortal';

  @override
  String get achDescScore75000 => 'Anota 75.000 puntos en una sola partida';

  @override
  String get achTitleScore250000 => 'Cuarto de Millón';

  @override
  String get achDescScore250000 => 'Anota 250.000 puntos en una sola partida';

  @override
  String get achTitleBeyondTime => 'Más Allá del Tiempo';

  @override
  String get achDescBeyondTime => 'Sobrevive 45 minutos en una sola partida';

  @override
  String get achTitleHourbound => 'Hora Completa';

  @override
  String get achDescHourbound =>
      'Sobrevive una hora entera en una sola partida';

  @override
  String get achTitleSnakeDevotee => 'Devoto de la Serpiente';

  @override
  String get achDescSnakeDevotee => 'Juega 2.500 partidas';

  @override
  String get achTitleTenThousandClub => 'Club de los Diez Mil';

  @override
  String get achDescTenThousandClub => 'Juega 10.000 partidas';

  @override
  String get achTitleZenVeteran => 'Veterano Zen';

  @override
  String get achDescZenVeteran => 'Termina 100 partidas Zen';

  @override
  String get achTitleSpeedVeteran => 'Veterano de la Velocidad';

  @override
  String get achDescSpeedVeteran =>
      'Termina 100 partidas de Desafío de Velocidad';

  @override
  String get achTitleMultifoodVeteran => 'Veterano del MultiComida';

  @override
  String get achDescMultifoodVeteran => 'Termina 100 partidas de MultiComida';

  @override
  String get achTitleTimeattackVeteran => 'Veterano de la Contrarreloj';

  @override
  String get achDescTimeattackVeteran => 'Termina 100 partidas de Contrarreloj';

  @override
  String get achTitleSurvivalVeteran => 'Veterano de la Supervivencia';

  @override
  String get achDescSurvivalVeteran => 'Termina 100 partidas de Supervivencia';

  @override
  String get achTitlePumInitiate => 'Iniciado en la Locura';

  @override
  String get achDescPumInitiate =>
      'Termina 10 partidas de Locura de Potenciadores';

  @override
  String get achTitlePumVeteran => 'Veterano de la Locura';

  @override
  String get achDescPumVeteran =>
      'Termina 100 partidas de Locura de Potenciadores';

  @override
  String get achTitlePerfectInitiate => 'Purista';

  @override
  String get achDescPerfectInitiate =>
      'Termina 10 partidas de Partida Perfecta';

  @override
  String get achTitlePerfectVeteran => 'Disciplina';

  @override
  String get achDescPerfectVeteran =>
      'Termina 100 partidas de Partida Perfecta';

  @override
  String get achTitleZen10000 => 'Desborde Zen';

  @override
  String get achDescZen10000 => 'Anota 10.000 en modo Zen';

  @override
  String get achTitleSpeed5000 => 'Borrón';

  @override
  String get achDescSpeed5000 => 'Anota 5.000 en Desafío de Velocidad';

  @override
  String get achTitleMultifood10000 => 'Bufé Sin Fin';

  @override
  String get achDescMultifood10000 => 'Anota 10.000 en MultiComida';

  @override
  String get achTitleTimeattack5000 => 'Carrera Contra el Reloj';

  @override
  String get achDescTimeattack5000 => 'Anota 5.000 en Contrarreloj';

  @override
  String get achTitlePum2000 => 'A Plena Carga';

  @override
  String get achDescPum2000 => 'Anota 2.000 en Locura de Potenciadores';

  @override
  String get achTitlePerfect1000 => 'Carrera Impecable';

  @override
  String get achDescPerfect1000 => 'Anota 1.000 en modo Partida Perfecta';

  @override
  String get achTitleComboSingularity => 'Singularidad de Combos';

  @override
  String get achDescComboSingularity =>
      'Logra un combo de 200x en una sola partida';

  @override
  String get achTitleWorldSerpent => 'Serpiente del Mundo';

  @override
  String get achDescWorldSerpent =>
      'Haz crecer la serpiente hasta longitud 750';

  @override
  String get achTitleLightspeed => 'Velocidad de la Luz';

  @override
  String get achDescLightspeed =>
      'Alcanza el nivel 30 de la partida en un solo juego';

  @override
  String get achTitlePowerOverwhelming => 'Poder Abrumador';

  @override
  String get achDescPowerOverwhelming => 'Recoge 5.000 potenciadores en total';

  @override
  String get achTitleGreedIsGood => 'La Codicia Es Buena';

  @override
  String get achDescGreedIsGood =>
      'Recoge 25 potenciadores de Multiplicador de Puntos';

  @override
  String get achTitleTimeBender => 'Doblador del Tiempo';

  @override
  String get achDescTimeBender => 'Recoge 25 potenciadores de Cámara Lenta';

  @override
  String get achTitleGastronome => 'Gastrónomo';

  @override
  String get achDescGastronome => 'Come 100.000 comidas en total';

  @override
  String get achTitleLivingLegend => 'Leyenda Viviente';

  @override
  String get achDescLivingLegend => 'Acumula 50.000.000 de puntos en total';

  @override
  String get achTitlePerpetualMotion => 'Movimiento Perpetuo';

  @override
  String get achDescPerpetualMotion => 'Racha de 50 partidas (30s+ cada una)';

  @override
  String get achTitleImmaculate => 'Inmaculado';

  @override
  String get achDescImmaculate => 'Completa 100 partidas perfectas';

  @override
  String get achTitleFortnightFaithful => 'Fiel Quincenal';

  @override
  String get achDescFortnightFaithful => 'Juega 14 días consecutivos';

  @override
  String get achTitleSteadySnake => 'Serpiente Constante';

  @override
  String get achDescSteadySnake => 'Sobrevive 30+ segundos en 100 partidas';

  @override
  String get achTitleMarathonMonth => 'Espíritu de Maratón';

  @override
  String get achDescMarathonMonth => 'Sobrevive 30+ segundos en 1.000 partidas';

  @override
  String get achTitleLunchtimeLegend => 'Leyenda del Almuerzo';

  @override
  String get achDescLunchtimeLegend =>
      'Termina una partida entre mediodía y las 2 PM';

  @override
  String get legalNoticePrefix => 'Al jugar, aceptas nuestros ';

  @override
  String get legalNoticeAnd => ' y ';

  @override
  String get dayOneReminderTitle => 'Tu serpiente te echa de menos 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'Tu récord es $score. ¿Crees que puedes superarlo?';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      '¿Una partida rápida? Tu primer récord te espera.';

  @override
  String get rvAteFoodUnknown => '🍎 Comió comida';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ Recogió un potenciador';

  @override
  String get boardTall => 'Alto';

  @override
  String get boardTallDesc =>
      'Llena la pantalla del móvil: más espacio para correr';

  @override
  String get boardTallPlus => 'Alto Plus';

  @override
  String get boardTallPlusDesc => 'Una arena más grande con forma de móvil';

  @override
  String get mpErrReadyTimeout =>
      'Los dos jugadores no estuvieron listos a tiempo. Buscando una nueva partida…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'Confirmación · ${seconds}s';
  }

  @override
  String get mpLobbyWaitingOpponentReady =>
      'Esperando a que tu rival esté listo…';

  @override
  String get gameDirectionalPad => 'Pad direccional';

  @override
  String get gamePauseGame => 'Pausar juego';

  @override
  String get gameResumeGame => 'Reanudar juego';

  @override
  String get gameLeaveMatch => 'Abandonar partida';

  @override
  String get gameSteerUp => 'Girar hacia arriba';

  @override
  String get gameSteerDown => 'Girar hacia abajo';

  @override
  String get gameSteerLeft => 'Girar a la izquierda';

  @override
  String get gameSteerRight => 'Girar a la derecha';

  @override
  String get mpTurnBlocked => 'Bloqueado';

  @override
  String get insHudPause => 'Botón de pausa';

  @override
  String get insHudPauseDesc =>
      'Pausa o reanuda: arriba a la derecha de la pantalla';

  @override
  String get insDpad => 'Pad direccional en pantalla';

  @override
  String get insDpadDesc =>
      'Botones opcionales de cuatro direcciones para girar, en lugar de deslizar';

  @override
  String get insControlsNote =>
      'Activa o desactiva los controles en pantalla, elige cruceta, botones de giro o joystick y ajusta el Movimiento por casillas en Ajustes → Controles, o desde el menú de pausa en plena partida.';

  @override
  String get insVersus => 'Versus';

  @override
  String get insVersusOnline => '1v1 en línea';

  @override
  String get insVersusOnlineDesc =>
      'Reglas clásicas, dos serpientes, un tablero, en tiempo real';

  @override
  String get insVersusQuick => 'Partida rápida';

  @override
  String get insVersusQuickDesc => 'Te busca un rival automáticamente';

  @override
  String get insVersusRoom => 'Sala privada';

  @override
  String get insVersusRoomDesc =>
      'Crea una sala y comparte el código, o únete a la de un amigo';

  @override
  String get homeVersusCta => 'VERSUS';

  @override
  String get homeVersusSubtitle =>
      '1v1 Clásico · Partida rápida o invita a un amigo';

  @override
  String get hwVersusTitle => 'Juega contra alguien';

  @override
  String get hwVersusMsg =>
      'Versus es 1v1 Clásico en línea. La partida rápida te busca rival, o crea una sala privada e invita a un amigo.';

  @override
  String get hwHelpTitle => '¿Algo más?';

  @override
  String get hwHelpMsg =>
      'Aquí se explican las reglas, los controles y Versus. Los ajustes están al lado.';

  @override
  String get insOnPhone => 'En el móvil';

  @override
  String get insOnKeyboard => 'Con teclado';

  @override
  String get settingsSectionYourGame => 'TU JUEGO';

  @override
  String get settingsStatisticsSubtitle => 'Todas tus partidas, sumadas';

  @override
  String get settingsReplaysSubtitle => 'Vuelve a ver tus partidas guardadas';

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String updateAvailableBody(String version) {
    return 'Snake Classic $version ya está en la App Store. Actualiza para tener las últimas novedades y correcciones.';
  }

  @override
  String get updateRequiredTitle => 'Actualización necesaria';

  @override
  String get updateRequiredBody =>
      'Esta versión de Snake Classic ya no es compatible. Actualiza desde la App Store para seguir jugando.';

  @override
  String get updateActionUpdate => 'Actualizar';

  @override
  String get updateActionLater => 'Más tarde';

  @override
  String get updateOpenStoreFailed => 'No se pudo abrir la App Store';

  @override
  String get lbHomeHint => 'GUÍA HACIA UN BLOQUE. O TÓCALO. NO JUZGAMOS.';

  @override
  String lbDailyNag(String done, String total) {
    return 'DIARIO $done/$total · OTRO BOCADO, PORFA';
  }

  @override
  String get lbDailyCheck => 'DIARIO · RETOS DE HOY';

  @override
  String get lbDailyAllFed => 'TODO COMIDO. VUELVE MAÑANA.';

  @override
  String lbModeRow(String index, String count, String mode) {
    return 'MODO $index/$count · $mode';
  }

  @override
  String get lbYourBest => 'TU RÉCORD';

  @override
  String get lbPlay => 'JUGAR';

  @override
  String lbModeBoard(String mode, String board) {
    return '$mode · $board';
  }

  @override
  String get lbHomeVersus => 'VERSUS';

  @override
  String lbHomeVersusSub(String rating) {
    return '1v1 · rating $rating';
  }

  @override
  String lbHomeDaily(String done, String total) {
    return 'DIARIO $done/$total';
  }

  @override
  String lbHomeDailySub(String time, String coins) {
    return 'se reinicia en $time · +$coins¢';
  }

  @override
  String get lbHomeSeason => 'TEMPORADA';

  @override
  String lbHomeSeasonSub(String tier, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'quedan $days días',
      one: 'queda 1 día',
    );
    return 'Nivel $tier · $_temp0';
  }

  @override
  String get lbHomeRanks => 'RANKING';

  @override
  String lbHomeRanksSub(String rank) {
    return '#$rank · subiendo';
  }

  @override
  String lbHomeRanksSubNone(String score) {
    return 'Mejor partida: $score';
  }

  @override
  String get lbHomeStore => 'TIENDA';

  @override
  String get lbHomeStoreSub => 'Aspectos, temas, estelas';

  @override
  String get lbHomeProfile => 'PERFIL';

  @override
  String lbHomeProfileSub(String level, String runs) {
    return 'NV $level · $runs partidas';
  }

  @override
  String get lbHomeMenu => 'MENÚ';

  @override
  String get lbFreePowerUp => 'POTENCIADOR GRATIS · ANUNCIO';

  @override
  String get lbTipLabel => 'CONSEJO';

  @override
  String get lbTip1 => 'La pared no se mueve. Tú sí.';

  @override
  String get lbTip2 => 'Los combos caducan a los 6 segundos. Sigue masticando.';

  @override
  String get lbTip3 => 'El modo Zen no tiene paredes. Pero te tiene a ti.';

  @override
  String get lbTip4 =>
      'Las partidas en Fácil no puntúan en la clasificación. Sin vergüenza.';

  @override
  String get lbTip5 =>
      'La comida bonus vale 25. La especial, 50. La avaricia es gratis.';

  @override
  String get lbTip6 =>
      'Desliza con antelación. La serpiente no hace giros bruscos.';

  @override
  String get lbTip7 =>
      'Partida Perfecta: nunca pises la misma casilla dos veces. Suerte.';

  @override
  String get lbTip8 => 'Con Pro revives gratis. Solo lo decimos.';

  @override
  String lbSplashStatus(String pct) {
    return 'CALENTANDO LAS MANZANAS… $pct%';
  }

  @override
  String lbSplashFooter(String version) {
    return 'v$version · NINGUNA SERPIENTE SUFRIÓ DAÑOS';
  }

  @override
  String get lbSetupTitle => 'PREPARACIÓN';

  @override
  String get lbSetupSubtitle =>
      'Elige tu veneno. Todos los modos son gratis. Para siempre.';

  @override
  String get lbSetupMode => 'MODO';

  @override
  String lbSetupModesAside(String count) {
    return '$count MODOS · 0 MUROS DE PAGO';
  }

  @override
  String get lbSetupBoard => 'TABLERO';

  @override
  String get lbSetupDifficulty => 'DIFICULTAD';

  @override
  String get lbSetupLoadout => 'EQUIPAMIENTO';

  @override
  String get lbSetupGet => 'CONSEGUIR';

  @override
  String get lbBoardTall => 'ALTO';

  @override
  String get lbModeLineClassic => 'Las paredes muerden.';

  @override
  String get lbModeLineZen => 'Sin paredes. Solo buen rollo.';

  @override
  String get lbModeLineSpeed => 'Rápido. Y luego más.';

  @override
  String get lbModeLineMultiFood => 'Barra libre de comida.';

  @override
  String get lbModeLineSurvival => '3 vidas. Gástalas bien.';

  @override
  String get lbModeLineTimeAttack => '3 minutos. Cómetelo todo.';

  @override
  String get lbModeLinePowerUp => 'Potenciadores. Muchísimos.';

  @override
  String get lbModeLinePerfect => 'Nunca pises dos veces.';

  @override
  String get lbDiffEasyLine => 'práctica · sin ranking';

  @override
  String get lbDiffNormalLine => 'el ritmo clásico';

  @override
  String get lbDiffHardLine => 'para fanfarrones';

  @override
  String lbComboWarm(String mult) {
    return '×$mult TIBIO';
  }

  @override
  String lbComboHot(String mult) {
    return '×$mult CALIENTE · SIGUE COMIENDO';
  }

  @override
  String lbComboFire(String mult) {
    return '×$mult EN LLAMAS';
  }

  @override
  String get lbComboDecay => 'COME ALGO. YA.';

  @override
  String get lbComboBroken => 'combo perdido. pasa.';

  @override
  String lbLevelUp(String level) {
    return 'NV $level · MÁS RÁPIDO';
  }

  @override
  String lbLevelShort(String level) {
    return 'NV $level';
  }

  @override
  String lbPowerInvincible(String secs) {
    return 'INVENCIBLE · ${secs}s';
  }

  @override
  String get lbPowerInvincibleLine => 'las paredes son más bien una sugerencia';

  @override
  String lbPowerSpeed(String secs) {
    return 'VELOCIDAD · ${secs}s';
  }

  @override
  String get lbPowerSpeedLine => 'agárrate';

  @override
  String lbPowerSlow(String secs) {
    return 'CÁMARA LENTA · ${secs}s';
  }

  @override
  String get lbPowerSlowLine => 'saboréalo';

  @override
  String lbPowerScore(String secs) {
    return '2× PUNTOS · ${secs}s';
  }

  @override
  String lbPowerEnding(String name, String secs) {
    return '$name ACABA · $secs';
  }

  @override
  String get lbTimeAttackPanic => '10 SEGUNDOS. ENTRA EN PÁNICO CON CABEZA.';

  @override
  String lbLifeLost(String left) {
    return '1 VIDA MENOS · QUEDAN $left';
  }

  @override
  String lbHudLen(String len) {
    return 'LARGO $len';
  }

  @override
  String get lbScoreLabel => 'PUNTOS';

  @override
  String get lbTurnLeft => 'GIRAR IZQ.';

  @override
  String get lbTurnRight => 'GIRAR DCHA.';

  @override
  String get lbSwipeToSteer => 'DESLIZA PARA GUIAR';

  @override
  String get lbPauseTitle => 'PAUSA';

  @override
  String get lbPauseLine => 'La manzana esperará. Seguramente.';

  @override
  String get lbResume => 'SEGUIR';

  @override
  String get lbResumeSub => '3 · 2 · 1, Y A JUGAR';

  @override
  String get lbRestart => 'REINICIAR';

  @override
  String get lbRestartSub => 'mismo modo';

  @override
  String get lbPauseSettings => 'AJUSTES';

  @override
  String get lbPauseSettingsSub => 'controles · sonido';

  @override
  String get lbQuit => 'SALIR AL MENÚ';

  @override
  String get lbQuitSub => 'la partida acaba aquí';

  @override
  String lbPauseSoFar(String score, String len, String time) {
    return 'DE MOMENTO · $score PTS · LARGO $len · $time';
  }

  @override
  String get lbCrashWallTitle => '¡PLAF!';

  @override
  String lbCrashWall1(String len) {
    return 'Besaste la pared con largo $len.';
  }

  @override
  String get lbCrashWall2 => 'La pared estaba primero.';

  @override
  String get lbCrashWall3 => 'Paredes: invictas desde siempre.';

  @override
  String get lbCrashWallScore => 'LA PARED: 1 · TÚ: 0';

  @override
  String get lbCrashSelfTitle => 'AY.';

  @override
  String get lbCrashSelf1 => 'Te mordiste a ti mismo. ¿Por qué?';

  @override
  String get lbCrashSelf2 => 'Cola: deliciosa, al parecer.';

  @override
  String get lbCrashSelf3 => 'Autobocado detectado.';

  @override
  String get lbCrashTimeTitle => '¡TIEMPO!';

  @override
  String get lbCrashTime1 => 'Se acabó el tiempo. Las manzanas escaparon.';

  @override
  String lbCrashTime2(String food) {
    return 'Tres minutos, $food manzanas. Respeto.';
  }

  @override
  String get lbCrashStepTitle => 'PISADO.';

  @override
  String get lbCrashStep1 =>
      'Pisaste tu propio camino. Partida Perfecta no perdona.';

  @override
  String get lbCrashQuitTitle => 'ABANDONO.';

  @override
  String get lbCrashQuit1 => 'Partida terminada por ti. No vimos nada.';

  @override
  String get lbCrashGeneric => 'Fin de la partida.';

  @override
  String lbGameOverHeadline(String line) {
    return '× $line';
  }

  @override
  String get lbReviveTitle => '¿SEGUNDA OPORTUNIDAD?';

  @override
  String lbSeconds(String secs) {
    return '${secs}s';
  }

  @override
  String lbReviveLine(String len, String score) {
    return 'Conserva el largo $len y los $score puntos.';
  }

  @override
  String get lbReviveWatch => 'VER ANUNCIO · GRATIS';

  @override
  String lbRevivePay(String cost) {
    return 'PAGAR $cost¢';
  }

  @override
  String lbReviveYouHave(String coins) {
    return 'tienes $coins';
  }

  @override
  String get lbReviveDecline => 'NAH, ENSÉÑAME MI PUNTUACIÓN';

  @override
  String get lbRevivePro => 'REVIVIR · GRATIS CON PRO';

  @override
  String get lbReviveProHint => 'Con Pro revives gratis. Solo lo decimos.';

  @override
  String get lbGoBest => 'RÉCORD';

  @override
  String lbGoBehind(String gap) {
    return '−$gap';
  }

  @override
  String get lbGoBehindLine => 'casi. (bueno, no.)';

  @override
  String get lbGoNewBest => '¡NUEVO RÉCORD!';

  @override
  String get lbGoNewBestLine => 'Esta, para enmarcar.';

  @override
  String lbGoRun(String run) {
    return 'PARTIDA $run';
  }

  @override
  String get lbGoChartTitle => 'TU PARTIDA, DESENROSCADA';

  @override
  String lbGoChartStats(String food, String combo) {
    return '$food COMIDAS · PICO ×$combo';
  }

  @override
  String get lbGoChartCaption => '1 COLUMNA = 1 COMIDA · MÁS ALTA = MÁS RICA';

  @override
  String get lbGoNoBites =>
      'Nada de comida esta partida. El gráfico empieza con el primer bocado.';

  @override
  String get lbAgain => 'OTRA VEZ';

  @override
  String get lbGoContinue => 'CONTINUAR';

  @override
  String lbGoContinueSub(String cost, String len) {
    return '$cost¢ o anuncio · conserva largo $len';
  }

  @override
  String lbGoContinueProSub(String len) {
    return 'gratis con Pro · conserva largo $len';
  }

  @override
  String lbGoEarned(String coins) {
    return '+$coins¢ GANADAS';
  }

  @override
  String lbGoRewardsLine(String ready, String coins, String xp) {
    return '$ready diarios listos · +$coins¢ · +$xp XP';
  }

  @override
  String get lbGoNothingToClaim => 'nada que reclamar aún · sigue jugando';

  @override
  String get lbClaim => 'RECLAMAR';

  @override
  String get lbGoDoubleCoins => '2× MONEDAS · ANUNCIO';

  @override
  String get lbGoWatchReplay => 'VER REPETICIÓN';

  @override
  String get lbHome => 'INICIO';

  @override
  String get lbDailyTitle => 'DIARIO';

  @override
  String get lbDailySubtitle => 'Tres bocados al día. Órdenes del médico.';

  @override
  String lbDailyProgress(String done, String total) {
    return '$done DE $total HECHOS';
  }

  @override
  String lbDailyStreak(int days, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'racha: $days días',
      one: 'racha: 1 día',
    );
    return '$_temp0 · se reinicia en $time';
  }

  @override
  String lbResetsIn(String time) {
    return 'se reinicia en $time';
  }

  @override
  String get lbClaimAll => 'RECLAMAR TODO';

  @override
  String get lbClaimAllDouble => 'RECLAMAR TODO ×2';

  @override
  String get lbClaimAllDoubleLine => 'un anuncio corto, botín doble';

  @override
  String lbWeeklyTeaser(String done, String total) {
    return 'MISIONES SEMANALES · $done/$total';
  }

  @override
  String get lbWeeklyTeaserLine => 'el gran botín llega el domingo';

  @override
  String get lbWeeklyTitle => 'SEMANAL';

  @override
  String get lbWeeklySubtitle =>
      'Bocados más grandes. Siete días para acabarlos.';

  @override
  String lbRewardCoinsXp(String coins, String xp) {
    return '$coins¢ · $xp XP';
  }

  @override
  String lbPlayMode(String mode) {
    return 'JUGAR $mode';
  }

  @override
  String get lbTrophiesTitle => 'TROFEOS';

  @override
  String lbTrophiesSubtitle(String unlocked, String total, String locked) {
    return '$unlocked de $total. Los otros $locked te juzgan.';
  }

  @override
  String get lbFilterAll => 'TODOS';

  @override
  String lbFilterUnlocked(String count) {
    return 'LOGRADOS $count';
  }

  @override
  String lbFilterLocked(String count) {
    return 'BLOQUEADOS $count';
  }

  @override
  String lbTrophiesSummary(String pct, String claimed, String waiting) {
    return '$pct% COMPLETO · $claimed RECLAMADOS · $waiting PENDIENTES';
  }

  @override
  String get lbClaimed => 'RECLAMADO';

  @override
  String lbCoinsReward(String coins) {
    return '+$coins¢';
  }

  @override
  String get lbSeasonTitle => 'TEMPORADA';

  @override
  String lbSeasonSubtitle(String season, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'quedan $days días',
      one: 'queda 1 día',
    );
    return '$season · $_temp0. Aprovéchalos.';
  }

  @override
  String lbSeasonEnded(String season) {
    return '$season · temporada terminada. Viene una nueva.';
  }

  @override
  String get lbTier => 'NIVEL';

  @override
  String lbTierOf(String max) {
    return '/ $max';
  }

  @override
  String get lbProTrack => 'PASE PRO';

  @override
  String lbXpToTier(String xp, String need, String tier) {
    return '$xp / $need XP PARA NIVEL $tier';
  }

  @override
  String lbNextUp(String tier, String track) {
    return 'SIGUIENTE · NIVEL $tier · $track';
  }

  @override
  String lbTiersAwayLine(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'A $n niveles. Come más rápido.',
      one: 'A 1 nivel. Come más rápido.',
    );
    return '$_temp0';
  }

  @override
  String lbTiersAway(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n NIVELES',
      one: '1 NIVEL',
    );
    return '$_temp0';
  }

  @override
  String lbXpAd(String xp) {
    return '+$xp XP · VER ANUNCIO';
  }

  @override
  String get lbYouAreHere => 'ESTÁS AQUÍ';

  @override
  String get lbFree => 'GRATIS';

  @override
  String get lbPro => 'PRO';

  @override
  String get lbRanksTitle => 'RANKING';

  @override
  String get lbRanksSubtitle => 'Según tu mejor partida. Sin presión.';

  @override
  String get lbTabGlobal => 'GLOBAL';

  @override
  String get lbTabWeekly => 'SEMANAL';

  @override
  String get lbTabFriends => 'AMIGOS';

  @override
  String lbRanksYouRow(String rank, String name) {
    return '#$rank · TÚ · $name';
  }

  @override
  String lbRanksYouUnranked(String name) {
    return 'TÚ · $name';
  }

  @override
  String lbRanksGap(String gap, String leader) {
    return 'A $gap de $leader. Come con más ganas.';
  }

  @override
  String get lbRanksLeader => 'Eres el #1. Todos van a por ti.';

  @override
  String get lbRanksEasyOnly => 'Fácil no puntúa. Normal te espera.';

  @override
  String get lbRanksOffline => 'El ranking necesita internet. Tu serpiente no.';

  @override
  String get lbRanksEmpty => 'Aún no hay nadie. Sé el primero.';

  @override
  String lbRunsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n partidas',
      one: '1 partida',
    );
    return '$_temp0';
  }

  @override
  String get lbProfileTitle => 'PERFIL';

  @override
  String get lbProfileSubtitle => 'Tu serpiente, en números.';

  @override
  String get lbFunFact => 'DATO CURIOSO';

  @override
  String lbFunApples(String apples, int pies) {
    String _temp0 = intl.Intl.pluralLogic(
      pies,
      locale: localeName,
      other: '$pies tartas',
      one: '1 tarta',
    );
    return '$apples manzanas comidas. Eso son unas $_temp0.';
  }

  @override
  String lbFunMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return '$_temp0 reptando. Bebe agua.';
  }

  @override
  String lbFunPowerups(int powerups) {
    String _temp0 = intl.Intl.pluralLogic(
      powerups,
      locale: localeName,
      other: '$powerups potenciadores atrapados',
      one: '1 potenciador atrapado',
    );
    return '$_temp0. Qué glotón, nos encanta.';
  }

  @override
  String get lbSynced => 'PROGRESO SINCRONIZADO';

  @override
  String get lbSyncedLine =>
      '¿Sin conexión? Juega igual. Ya nos pondremos al día.';

  @override
  String get lbSyncPending => 'SINCRO PENDIENTE';

  @override
  String get lbGuest => 'JUGANDO COMO INVITADO';

  @override
  String get lbGuestLine =>
      'Vincula una cuenta para conservar esta serpiente para siempre.';

  @override
  String lbSignedInWith(String provider) {
    return 'CONECTADO · $provider';
  }

  @override
  String get lbStatBest => 'RÉCORD';

  @override
  String get lbStatGames => 'PARTIDAS';

  @override
  String get lbStatPlayTime => 'TIEMPO JUGADO';

  @override
  String get lbStatAverage => 'MEDIA';

  @override
  String get lbStatFood => 'COMIDA';

  @override
  String get lbStatPowerups => 'POTENCIADORES';

  @override
  String get lbStats => 'ESTADÍSTICAS';

  @override
  String get lbReplays => 'REPETICIONES';

  @override
  String get lbFriends => 'AMIGOS';

  @override
  String get lbTrophies => 'TROFEOS';

  @override
  String lbFriendsOn(String count) {
    return '$count EN LÍNEA';
  }

  @override
  String get lbStoreTitle => 'TIENDA';

  @override
  String get lbStoreSubPro => 'Sin anuncios. Todo el estilo. Tú decides.';

  @override
  String get lbStoreSubCoins => 'Monedas para impacientes.';

  @override
  String get lbStoreSubThemes => 'Tablero nuevo, malos hábitos de siempre.';

  @override
  String get lbStoreSubSkins => 'La misma serpiente. Mucho más estilo.';

  @override
  String get lbStoreSubTrails => 'Deja huella.';

  @override
  String get lbStoreSubPowerups => 'Trampitas. Totalmente legales.';

  @override
  String get lbSnakeCoins => 'MONEDAS SNAKE';

  @override
  String lbFreeCoins(String coins) {
    return '+$coins¢ GRATIS';
  }

  @override
  String get lbFreeCoinsLine => 'mira un anuncio corto';

  @override
  String get lbProName => 'SNAKE CLASSIC PRO';

  @override
  String get lbProPerkNoAds => 'Sin anuncios. Ni uno. Nunca.';

  @override
  String get lbProPerkRevive => 'Una resurrección gratis en cada partida';

  @override
  String lbProPerkThemes(String count) {
    return 'Los $count temas premium';
  }

  @override
  String lbProPerkCosmetics(String skins, String trails) {
    return 'Los $skins aspectos + las $trails estelas';
  }

  @override
  String get lbProPerkCoins => '2× monedas en cada partida';

  @override
  String get lbMonthly => 'MENSUAL';

  @override
  String get lbYearly => 'ANUAL';

  @override
  String get lbPerMonth => 'al mes';

  @override
  String get lbGoPro => 'PÁSATE A PRO';

  @override
  String get lbProActive => 'PRO ACTIVO';

  @override
  String get lbProActiveLine => 'Gracias por apoyar a la serpiente.';

  @override
  String get lbStoreFooter =>
      'Precios de tu tienda de apps. Cancela cuando quieras.';

  @override
  String get lbRestorePurchases => 'RESTAURAR COMPRAS';

  @override
  String lbBuyPrice(String price) {
    return 'COMPRAR · $price';
  }

  @override
  String lbBuyCoins(String coins) {
    return 'COMPRAR · $coins¢';
  }

  @override
  String get lbOrFreeWithPro => 'o gratis con Pro';

  @override
  String get lbEquipped => 'EQUIPADO';

  @override
  String get lbEquip => 'EQUIPAR';

  @override
  String get lbSkinTagGolden => 'Rica. Famosa. Algo creída.';

  @override
  String get lbSkinTagFire => 'Quema al tacto.';

  @override
  String get lbSkinTagIce => 'Fría bajo presión.';

  @override
  String get lbSkinTagElectric => 'De una rapidez electrizante.';

  @override
  String get lbSkinTagRainbow => 'Todos. A la vez.';

  @override
  String get lbSkinTagNeon => 'Visible desde el espacio.';

  @override
  String get lbSkinTagShadow => 'Ahora la ves.';

  @override
  String get lbSkinTagGalaxy => 'Contiene multitudes.';

  @override
  String get lbSkinTagCrystal => 'Manéjese con cuidado.';

  @override
  String get lbSkinTagCosmic => 'Energía de universo grande.';

  @override
  String get lbSkinTagDragon => 'Legalmente, no es un dragón.';

  @override
  String get lbSettingsTitle => 'AJUSTES';

  @override
  String get lbSettingsSubtitle => 'Ajústalo hasta que se sienta bien.';

  @override
  String get lbControls => 'CONTROLES';

  @override
  String get lbCtrlSwipe => 'DESLIZAR';

  @override
  String get lbCtrlSwipeSub => 'donde sea';

  @override
  String get lbCtrlDpad => 'CRUCETA';

  @override
  String get lbCtrlDpadSub => '4 flechas';

  @override
  String get lbCtrlTurn => 'GIRAR';

  @override
  String get lbCtrlTurnSub => 'izq. · dcha.';

  @override
  String get lbCtrlStick => 'STICK';

  @override
  String get lbCtrlStickSub => 'flotante';

  @override
  String get lbGameplay => 'JUEGO';

  @override
  String get lbMode => 'MODO';

  @override
  String get lbBoard => 'TABLERO';

  @override
  String get lbDifficulty => 'DIFICULTAD';

  @override
  String get lbCrashReplay => 'REPETICIÓN DEL CHOQUE';

  @override
  String get lbCrashReplaySub => 'cuánto te lo restregamos';

  @override
  String get lbTheme => 'TEMA';

  @override
  String lbThemeAside(String theme, String free, String premium) {
    return '$theme · $free GRATIS · $premium PREMIUM';
  }

  @override
  String get lbSoundFeel => 'SONIDO Y TACTO';

  @override
  String get lbSoundFx => 'EFECTOS';

  @override
  String get lbSoundFxSub => 'crujientes, como debe ser';

  @override
  String get lbMusic => 'MÚSICA';

  @override
  String get lbHaptics => 'VIBRACIÓN';

  @override
  String get lbHapticsSub => 'un zumbidito en cada mordisco';

  @override
  String get lb120Hz => '120 HZ';

  @override
  String get lb120HzSub => 'suave como la seda (si tu móvil lo es)';

  @override
  String get lbReplayTutorial => 'REPETIR TUTORIAL';

  @override
  String get lbPrivacy => 'PRIVACIDAD';

  @override
  String get lbVersusTitle => 'VERSUS';

  @override
  String get lbVersusSubtitle => 'Gente real. Serpientes reales. Pique real.';

  @override
  String get lbWins => 'VICTORIAS';

  @override
  String get lbLosses => 'DERROTAS';

  @override
  String get lbDraws => 'EMPATES';

  @override
  String get lbRating => 'RATING';

  @override
  String get lbQuickMatch => 'PARTIDA RÁPIDA';

  @override
  String get lbQuickMatchLine => '1v1 Clásico. Te buscamos rival en segundos.';

  @override
  String get lbFindMatch => 'BUSCAR PARTIDA';

  @override
  String lbSearching(String secs) {
    return 'OLFATEANDO UN RIVAL… ${secs}s';
  }

  @override
  String get lbCancel => 'CANCELAR';

  @override
  String get lbGotCode => '¿TIENES CÓDIGO?';

  @override
  String get lbGotCodeLine =>
      'Seis letras. Mayúsculas, da igual. La amistad, quizá no.';

  @override
  String get lbCreateRoom => 'CREAR SALA';

  @override
  String get lbCreateRoomLine => 'Invita a un amigo. O a un amienemigo.';

  @override
  String get lbHouseSnake =>
      '¿Nadie valiente en línea? La serpiente de la casa entra a los 30s. No se burla de ti.';

  @override
  String get lbTournamentsLive => 'TORNEOS · EN VIVO';

  @override
  String get lbTournamentsLine => 'Bronce gratis · entradas de Plata y Oro';

  @override
  String get lbRoomTitle => 'SALA';

  @override
  String get lbRoomSubtitle => 'Comparte el código. Espera con nervios.';

  @override
  String lbPlayersCount(String count, String max) {
    return 'JUGADORES $count/$max';
  }

  @override
  String get lbYou => 'TÚ';

  @override
  String get lbRival => 'RIVAL';

  @override
  String get lbWaitingYou => 'ESPERANDO · pulsa listo, héroe';

  @override
  String get lbWaiting => 'ESPERANDO';

  @override
  String get lbReadyThem => 'LISTO · estirándose amenazante';

  @override
  String get lbReadyYou => 'LISTO · nervios de acero';

  @override
  String get lbReadyCheck => '¿LISTOS?';

  @override
  String get lbReady => 'LISTO';

  @override
  String get lbLeaveRoom => 'SALIR DE LA SALA';

  @override
  String get lbVs => 'VS';

  @override
  String get lbLive => 'EN VIVO';

  @override
  String lbMatchBehind(String rival, String gap) {
    return '$rival te saca $gap puntos. Qué grosero.';
  }

  @override
  String lbMatchAhead(String gap) {
    return 'Vas $gap por delante. No te confíes.';
  }

  @override
  String get lbMatchTied => 'Empate exacto. Come algo.';

  @override
  String get lbVictory => 'VICTORIA';

  @override
  String lbVictoryLine(String rival) {
    return 'Fuiste más serpiente que $rival.';
  }

  @override
  String get lbDefeat => 'DERROTA';

  @override
  String lbDefeatLine(String rival) {
    return '$rival se llevó esta.';
  }

  @override
  String get lbDefeatBothCrashed =>
      'Las dos serpientes chocaron. Decidió la puntuación.';

  @override
  String lbDefeatLine2(String rival) {
    return '$rival va a estar insoportable.';
  }

  @override
  String get lbDraw => 'EMPATE';

  @override
  String get lbDrawLine => 'Perfectamente equilibrado. ¿Revancha?';

  @override
  String get lbVersusFooter => 'Cada derrota es solo una revancha pendiente.';

  @override
  String get lbLength => 'LARGO';

  @override
  String get lbSurvived => 'AGUANTASTE';

  @override
  String get lbRematch => 'REVANCHA';

  @override
  String get lbBackToLobby => 'VOLVER AL LOBBY';

  @override
  String get lbAdBreak => 'PAUSA PUBLICITARIA';

  @override
  String lbAdBreakLine(String coins) {
    return 'Un anuncio corto. $coins monedas para ti.';
  }

  @override
  String get lbAdBreakLine2 => '¿Trato justo? Tú decides.';

  @override
  String lbAdStartsIn(String secs) {
    return 'EMPIEZA EN $secs · O SÁLTALO, SIN RENCORES';
  }

  @override
  String lbAdRewardWhenEnds(String coins) {
    return '+$coins¢ AL TERMINAR';
  }

  @override
  String get lbWatchNow => 'VER AHORA';

  @override
  String get lbNoThanks => 'NO, GRACIAS';

  @override
  String get lbAdBackHint =>
      'El gesto de volver también cuenta como no, gracias.';

  @override
  String get lbAdStarting => 'EMPIEZA EL ANUNCIO…';

  @override
  String get lbNoAdNow => 'No hay anuncio ahora. Prueba en un momento.';

  @override
  String get lbServerDown =>
      'Nuestros servidores se estrellaron. Tu progreso está a salvo en este móvil.';

  @override
  String get lbHomeVersusSubOffline => '1v1 · rivales reales';

  @override
  String get lbHomeSeasonSubNone => 'Gana XP en cada partida';

  @override
  String get lbMenuHowToPlay => 'CÓMO JUGAR';

  @override
  String get lbMenuTournaments => 'TORNEOS';

  @override
  String get lbMenuAbout => 'ACERCA DE';

  @override
  String get lbMenuHowToPlaySub => 'gestos, modos, potenciadores';

  @override
  String get lbMenuAboutSub => 'versión, créditos, legal';

  @override
  String get lbSetupLoadoutNone => 'TOCA UNO PARA ARMARLO';

  @override
  String lbSetupLoadoutArmedOne(String name) {
    return '$name ARMADO';
  }

  @override
  String lbOwnedCount(String count) {
    return '×$count';
  }

  @override
  String lbArmedChip(String name) {
    return 'ARMADO · $name';
  }

  @override
  String get lbGuestNoteApple =>
      'Los invitados pueden jugar y guardar el progreso en el dispositivo, pero no pueden hacer compras. Inicia sesión con Apple, Google o email cuando quieras suscribirte o comprar.';

  @override
  String get lbGuestNoteNoApple =>
      'Los invitados pueden jugar y guardar el progreso en el dispositivo, pero no pueden hacer compras. Inicia sesión con Google o email cuando quieras suscribirte o comprar.';

  @override
  String get lbAuthLegalTitle => 'PRIVACIDAD + TÉRMINOS';

  @override
  String get lbConsentTitle => 'TÉRMINOS ACTUALIZADOS';

  @override
  String get lbEmailTitle => 'EMAIL';

  @override
  String get lbEmailLinkTitle => 'GUARDAR PROGRESO';

  @override
  String get lbUsernameTitle => 'USUARIO';

  @override
  String get lbShowPassword => 'Mostrar contraseña';

  @override
  String get lbHidePassword => 'Ocultar contraseña';

  @override
  String get lbSignedIn => 'CONECTADO';

  @override
  String get lbProviderGoogle => 'GOOGLE';

  @override
  String get lbProviderApple => 'APPLE';

  @override
  String get lbProviderEmail => 'EMAIL';

  @override
  String get lbStatsSubtitle => 'Cada partida, contada. Hasta las malas.';

  @override
  String get lbTrendUp => 'SUBIENDO';

  @override
  String get lbTrendDown => 'BAJANDO';

  @override
  String get lbTrendFlat => 'ESTABLE';

  @override
  String get lbReplaysSubtitle => 'Guardadas en este móvil. Nunca se suben.';

  @override
  String get lbReplayTitle => 'REPETICIÓN';

  @override
  String get lbReplayEnded => 'TERMINADA';

  @override
  String lbSpeedX(String speed) {
    return '$speed×';
  }

  @override
  String get lbPause => 'PAUSA';

  @override
  String get lbReplayPrevFrame => 'FOTOGRAMA ANTERIOR';

  @override
  String get lbReplayNextFrame => 'FOTOGRAMA SIGUIENTE';

  @override
  String get lbFriendsSubtitle =>
      'Serpientes que conoces. Rivales a los que ganarás.';

  @override
  String lbDurDayHour(String d, String h) {
    return '${d}d ${h}h';
  }

  @override
  String lbBonusStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'RACHA DE $days DÍAS',
      one: 'RACHA DE 1 DÍA',
    );
    return '$_temp0';
  }

  @override
  String lbPoints(String points) {
    return '$points PTS';
  }

  @override
  String get lbRefresh => 'ACTUALIZAR';

  @override
  String get lbRouteErrorTitle => 'RASTRO PERDIDO';

  @override
  String get lbRouteErrorBody =>
      'Esa pantalla no existe en esta versión del juego.';

  @override
  String get lbRouteErrorHome => 'VOLVER AL INICIO';

  @override
  String lbVersionShort(String version) {
    return 'v$version';
  }

  @override
  String get lbCtrlReference => 'GESTOS Y TECLAS';

  @override
  String get lbCtrlReferenceSub => 'qué hace cada gesto y tecla';

  @override
  String lbThemeSwatchLocked(String theme) {
    return '$theme, bloqueado';
  }

  @override
  String get lbLanguageRow => 'IDIOMA DE LA APP';

  @override
  String get lbPerYearBestValue => 'al año · mejor precio';

  @override
  String get lbProAlsoIncluded => 'TAMBIÉN INCLUYE';

  @override
  String get lbFreeTrack => 'PASE GRATIS';

  @override
  String lbSeasonSubtitleSoon(String season, String left) {
    return '$season · $left. Aprovéchalo.';
  }

  @override
  String get lbEndsIn => 'TERMINA EN';

  @override
  String get lbStartsIn => 'EMPIEZA EN';
}
