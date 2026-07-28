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
}
