// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'LINGUA';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

  @override
  String get languageSystemDefaultSubtitle => 'Segui la lingua del dispositivo';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get mpVictory => 'VITTORIA!';

  @override
  String get mpDraw => 'PAREGGIO';

  @override
  String get mpDefeat => 'SCONFITTA';

  @override
  String get mpYou => 'Tu';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Avversario';

  @override
  String get mpBackToLobby => 'Torna alla lobby';

  @override
  String get mpPlayAgain => 'Gioca ancora';

  @override
  String get mpTimeUpDraw => 'Tempo scaduto — perfetta parità!';

  @override
  String get mpTimeUpYouWon => 'Tempo scaduto — avevi il punteggio più alto.';

  @override
  String get mpTimeUpYouLost =>
      'Tempo scaduto — il tuo avversario aveva il punteggio più alto.';

  @override
  String get mpMutualCrashDraw =>
      'Entrambi i serpenti si sono schiantati — pareggio!';

  @override
  String get mpMutualCrashYouWon =>
      'Entrambi i serpenti si sono schiantati — ha deciso il tuo punteggio.';

  @override
  String get mpMutualCrashYouLost =>
      'Entrambi i serpenti si sono schiantati — ha deciso il suo punteggio.';

  @override
  String get mpMatchCancelled => 'La partita è stata annullata.';

  @override
  String get mpLastSnakeStanding =>
      'Il tuo avversario si è schiantato. Ultimo serpente rimasto!';

  @override
  String get mpDeathWall => 'Ti sei schiantato contro il muro.';

  @override
  String get mpDeathSelf => 'Ti sei schiantato contro te stesso.';

  @override
  String get mpDeathOpponent => 'Ti sei schiantato contro il tuo avversario.';

  @override
  String get mpDeathHeadOn => 'Scontro frontale!';

  @override
  String get mpDeathForfeit =>
      'Disconnesso troppo a lungo — partita persa a tavolino.';

  @override
  String get mpBetterLuck => 'Andrà meglio la prossima volta!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count monete',
      one: '+$count moneta',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Uscire dalla partita?';

  @override
  String get mpLeaveGameBody =>
      'La partita continua sul server — uscire significa arrendersi.';

  @override
  String get mpLeave => 'Esci';

  @override
  String get mpReconnecting => 'RICONNESSIONE…';

  @override
  String get mpReconnectingBody => 'La partita è ancora in corso sul server.';

  @override
  String get mpGetReady => 'PREPARATI';

  @override
  String get mpDroppingIntoArena => 'Ti stiamo portando nell\'arena…';

  @override
  String get mpWaitingPlayer => 'In attesa…';

  @override
  String get mpOut => 'FUORI';

  @override
  String get mpLength => 'LUNGHEZZA';

  @override
  String get mpSwipe => 'Scorri';

  @override
  String get mpReconnectingInline => 'riconnessione…';

  @override
  String get homePlay => 'GIOCA';

  @override
  String get homeHighScore => 'RECORD';

  @override
  String homeArmedPowerUp(String name) {
    return 'Equipaggiato: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Equipaggiamento ($count)';
  }

  @override
  String get puSpeedBoost => 'Scatto di Velocità';

  @override
  String get puInvincibility => 'Invincibilità';

  @override
  String get puScoreMultiplier => 'Moltiplicatore Punti';

  @override
  String get puSlowMotion => 'Rallentatore';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'NEGOZIO';

  @override
  String get homeTileFree => 'GRATIS';

  @override
  String get homeTileDaily => 'SFIDE';

  @override
  String get homeTileBattle => 'BATTAGLIA';

  @override
  String get homeTileEvents => 'TORNEI';

  @override
  String get homeTileBoard => 'CLASSIFICA';

  @override
  String get homeTileFriends => 'AMICI';

  @override
  String get homeTileCosmetics => 'STILI';

  @override
  String get homeTileAwards => 'PREMI';

  @override
  String get homeTileVersus => 'VERSUS';

  @override
  String get homeNoAdReady =>
      'Nessun annuncio pronto — riprova tra qualche secondo.';

  @override
  String get homeFreeSpeedBoostTitle => 'Scatto di Velocità gratis';

  @override
  String get homeFreeSpeedBoostBody =>
      'Guarda un breve annuncio per aggiungere uno Scatto di Velocità gratis al tuo equipaggiamento. Si attiva 5 secondi dopo l\'inizio della prossima partita.';

  @override
  String get homeNotNow => 'Non ora';

  @override
  String get homeWatchAd => 'Guarda l\'annuncio';

  @override
  String get homeFreeSpeedBoostAdded =>
      'Scatto di Velocità gratis aggiunto al tuo equipaggiamento!';

  @override
  String get homeAdNotFinished =>
      'Annuncio non completato — guardalo per intero per ottenere la ricompensa.';

  @override
  String get homePickGameMode => 'Scegli una modalità di gioco';

  @override
  String get homePickGameModeSubtitle =>
      'Puoi cambiarla quando vuoi nelle Impostazioni';

  @override
  String get homeStartPlaying => 'INIZIA A GIOCARE';

  @override
  String get homeLoadoutTitle => 'Equipaggiamento power-up';

  @override
  String get homeLoadoutSubtitle =>
      'Precarica un power-up — si attiva 5 secondi dopo l\'inizio della prossima partita.';

  @override
  String get homeWatchAdFreeSpeedBoost =>
      'Guarda l\'annuncio — Scatto di Velocità gratis';

  @override
  String get homeNoPowerUps =>
      'Non hai power-up.\nVisita il negozio per comprarne!';

  @override
  String homeOwnedCount(int count) {
    return 'Posseduti: $count';
  }

  @override
  String get homeArmed => 'EQUIPAGGIATO';

  @override
  String get homeDone => 'FATTO';

  @override
  String get settingsTitle => 'IMPOSTAZIONI';

  @override
  String get settingsBackToGame => 'TORNA AL GIOCO';

  @override
  String get settingsSectionControls => 'CONTROLLI';

  @override
  String get settingsSectionGameplay => 'GIOCO';

  @override
  String get settingsSectionAudio => 'AUDIO';

  @override
  String get settingsSectionVisual => 'ASPETTO';

  @override
  String get settingsSectionNotifications => 'NOTIFICHE';

  @override
  String get settingsSectionUserProfile => 'PROFILO UTENTE';

  @override
  String get settingsSectionHelp => 'AIUTO E TUTORIAL';

  @override
  String get settingsSectionLegal => 'NOTE LEGALI';

  @override
  String get settingsSectionPremium => 'FUNZIONI PREMIUM';

  @override
  String get settingsDPadControls => 'Controlli D-Pad';

  @override
  String get settingsDPadSubtitle =>
      'Mostra i pulsanti direzionali sullo schermo durante il gioco';

  @override
  String get settingsDPadPosition => 'Posizione del D-Pad';

  @override
  String get settingsDesktopControls => 'Controlli desktop/web';

  @override
  String get settingsArrowKeys => 'Tasti freccia';

  @override
  String get settingsWasdKeys => 'Tasti WASD';

  @override
  String get settingsSpacebar => 'Barra spaziatrice';

  @override
  String get settingsMouseClick => 'Clic del mouse';

  @override
  String get settingsChangeDirection => 'Cambia direzione';

  @override
  String get settingsPauseResume => 'Pausa/Riprendi il gioco';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Controlli touch (se disponibili)';

  @override
  String get settingsTouchControls => 'Controlli touch';

  @override
  String get settingsSwipeGestures => 'Gesti di scorrimento';

  @override
  String get settingsTapScreen => 'Tocca lo schermo';

  @override
  String get settingsSwipeUp => 'Scorri in su ↑';

  @override
  String get settingsSwipeDown => 'Scorri in giù ↓';

  @override
  String get settingsSwipeLeft => 'Scorri a sinistra ←';

  @override
  String get settingsSwipeRight => 'Scorri a destra →';

  @override
  String get settingsMoveSnakeUp => 'Muovi il serpente in su';

  @override
  String get settingsMoveSnakeDown => 'Muovi il serpente in giù';

  @override
  String get settingsMoveSnakeLeft => 'Muovi il serpente a sinistra';

  @override
  String get settingsMoveSnakeRight => 'Muovi il serpente a destra';

  @override
  String get settingsGameMode => 'Modalità di gioco';

  @override
  String get settingsGameModeLocked =>
      'Completa la partita in corso per cambiare modalità';

  @override
  String get settingsDifficulty => 'Difficoltà';

  @override
  String get settingsDifficultySubtitle =>
      'Imposta la velocità iniziale del serpente. Ogni modalità accelera comunque con i livelli.';

  @override
  String get settingsEasyNote =>
      'Monete, XP e obiettivi contano anche in Facile — sono in pausa solo record e classifiche.';

  @override
  String get settingsDifficultyLocked =>
      'Termina la partita in corso per cambiare la difficoltà.';

  @override
  String get settingsCurrentSize => 'Dimensione attuale';

  @override
  String get settingsBoardSizeLocked =>
      'Completa la partita in corso per cambiare la dimensione';

  @override
  String get settingsCurrentDuration => 'Durata attuale';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Per quanto tempo mostrare la spiegazione dello schianto';

  @override
  String get settingsScreenShake => 'Vibrazione dello schermo';

  @override
  String get settingsScreenShakeSubtitle =>
      'Scuoti lo schermo per collisioni ed eventi di gioco';

  @override
  String get settingsVibration => 'Vibrazione';

  @override
  String get settingsVibrationSubtitle =>
      'Vibra per eventi di gioco e pressioni dei pulsanti';

  @override
  String get settingsSoundEffects => 'Effetti sonori';

  @override
  String get settingsBackgroundMusic => 'Musica di sottofondo';

  @override
  String get settingsCurrentTheme => 'Tema attuale';

  @override
  String get settingsBrowseThemes => 'SFOGLIA I TEMI';

  @override
  String get settingsSnakeTrail => 'Effetti scia del serpente';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Attiva scie di particelle dietro il serpente';

  @override
  String get settingsNotifDailyReminder => 'Promemoria giornaliero';

  @override
  String get settingsNotifTournament => 'Avvisi dei tornei';

  @override
  String get settingsNotifAchievement => 'Obiettivi sbloccati';

  @override
  String get settingsNotifSocial => 'Aggiornamenti social';

  @override
  String get settingsNotifSpecialEvents => 'Eventi speciali';

  @override
  String get settingsNotSet => 'Non impostato';

  @override
  String get settingsUsername => 'Nome utente';

  @override
  String get settingsGuestAccount => 'Account ospite';

  @override
  String get settingsAuthenticatedAccount => 'Account autenticato';

  @override
  String get settingsChangeUsername => 'CAMBIA NOME UTENTE';

  @override
  String get settingsGuestSignInHint =>
      'Accedi per conservare i tuoi progressi e giocare con gli amici';

  @override
  String get settingsUsernameVisibleHint =>
      'Il tuo nome utente è visibile agli amici e nelle classifiche';

  @override
  String get settingsReplayTutorial => 'RIVEDI IL TUTORIAL';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Rivedi il tour iniziale o il tutorial di gioco';

  @override
  String get settingsAboutCredits => 'INFO E CREDITI';

  @override
  String get settingsAboutCreditsSubtitle =>
      'Versione dell\'app, crediti e link';

  @override
  String get settingsRateApp => 'VALUTA SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'Ti piace il gioco? Lascia una recensione sull\'App Store';

  @override
  String get settingsRateAppSubtitle =>
      'Ti piace il gioco? Lasciaci una recensione!';

  @override
  String get settingsAdPrivacy => 'PRIVACY E ANNUNCI';

  @override
  String get settingsAdPrivacySubtitle =>
      'Gestisci il consenso agli annunci personalizzati';

  @override
  String get settingsAdPrivacyUnavailable =>
      'Le opzioni sulla privacy degli annunci non sono disponibili al momento.';

  @override
  String get settingsReplayDialogTitle => 'Rivedi il tutorial';

  @override
  String get settingsReplayDialogBody => 'Quale tutorial vuoi rivedere?';

  @override
  String get settingsHomeTour => 'Tour iniziale';

  @override
  String get settingsGameTutorial => 'Tutorial di gioco';

  @override
  String get settingsPrivacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get settingsPrivacyPolicyButton => 'INFORMATIVA SULLA PRIVACY';

  @override
  String get settingsTermsTitle => 'Termini di utilizzo';

  @override
  String get settingsTermsButton => 'TERMINI DI UTILIZZO';

  @override
  String get settingsChangeUsernameTitle => 'Cambia nome utente';

  @override
  String get settingsCurrentLabel => 'Attuale:';

  @override
  String get settingsUsernameDialogBody =>
      'Scegli un nome utente unico che ti rappresenti nel gioco.';

  @override
  String get settingsEnterNewUsername => 'Inserisci il nuovo nome utente';

  @override
  String get settingsUsernameRules =>
      '• 3-20 caratteri\n• Deve iniziare con una lettera\n• Solo lettere, numeri e trattini bassi';

  @override
  String get settingsUsernameUpdateFailed =>
      'Impossibile aggiornare il nome utente';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Nome utente cambiato in \"$name\"';
  }

  @override
  String get settingsUpdate => 'Aggiorna';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Stato premium';

  @override
  String get settingsActiveSubscription => 'Abbonamento attivo';

  @override
  String get settingsUnlockPremium => 'Sblocca le funzioni premium';

  @override
  String settingsRenews(String date) {
    return 'Si rinnova il $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Passa a Pro';

  @override
  String get settingsRestorePurchases => 'Ripristina acquisti';

  @override
  String get settingsPurchaseHistory => 'Cronologia acquisti';

  @override
  String get settingsSnakeCosmetics => 'Stili del serpente';

  @override
  String get settingsBattlePass => 'Pass Battaglia';

  @override
  String settingsTier(int tier) {
    return 'Livello $tier';
  }

  @override
  String get settingsRestoring => 'Ripristino degli acquisti...';

  @override
  String get settingsRestored => 'Acquisti ripristinati con successo!';

  @override
  String get settingsRestoreFailed =>
      'Impossibile ripristinare gli acquisti. Riprova.';

  @override
  String get settingsNoPurchases => 'Nessun acquisto trovato';

  @override
  String get settingsUnknown => 'Sconosciuto';

  @override
  String settingsStatusLine(String status) {
    return 'Stato: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'Data: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'Acquisto n. $number';
  }

  @override
  String get settingsDataParseError => 'Errore di lettura dei dati';

  @override
  String get settingsClose => 'Chiudi';

  @override
  String get settingsHistoryLoadFailed =>
      'Impossibile caricare la cronologia acquisti';

  @override
  String get settingsUnknownDate => 'Data sconosciuta';
}
