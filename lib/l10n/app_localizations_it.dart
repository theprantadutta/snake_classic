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

  @override
  String get mpLobbyNoFriends =>
      'Ancora nessun amico — aggiungine dalla schermata Amici!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Invita un amico nella stanza $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 Invito inviato a $name!';
  }

  @override
  String get mpLobbyInviteFailed => 'Impossibile inviare l\'invito — riprova';

  @override
  String get mpLobbyOffline => 'Sei offline. Il multiplayer richiede internet.';

  @override
  String get mpLobbyDismiss => 'CHIUDI';

  @override
  String get mpLobbyGo => 'VIA!';

  @override
  String get mpLobbyGetReady => 'Preparati!';

  @override
  String get mpLobbyTitle => 'MULTIPLAYER';

  @override
  String get mpLobbySubtitle => 'Gioca online con gli amici';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Stanza: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'Codice stanza copiato!';

  @override
  String get mpLobbyQuickMatch => 'PARTITA RAPIDA';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      '1v1 Classico — trova un avversario automaticamente';

  @override
  String get mpLobbyFinding => 'RICERCA...';

  @override
  String get mpLobbyFindMatch => 'TROVA PARTITA';

  @override
  String get mpLobbySeconds => 'sec';

  @override
  String get mpLobbySearching => 'RICERCA GIOCATORI...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giocatori',
      one: '$count giocatore',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Posizione in coda: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'ANNULLA';

  @override
  String get mpLobbyNoPlayersFound => 'NESSUN GIOCATORE TROVATO';

  @override
  String get mpLobbyNoPlayersBody =>
      'Spiacenti, nessun avversario trovato.\nRiprova o crea la tua stanza!';

  @override
  String get mpLobbyGoBack => 'INDIETRO';

  @override
  String get mpLobbyTryAgain => 'RIPROVA';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count V';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count S';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count P';
  }

  @override
  String get mpLobbyJoinRoom => 'ENTRA IN STANZA';

  @override
  String get mpLobbyJoinSubtitle => 'Inserisci il codice stanza per entrare';

  @override
  String get mpLobbyEnterRoomCode => 'Inserisci il codice stanza';

  @override
  String get mpLobbyCreateRoom => 'CREA STANZA';

  @override
  String get mpLobbyCreateSubtitle => 'Crea una stanza 1v1 e invita un amico';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'GIOCATORI ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'TU';

  @override
  String get mpLobbyWaitingForPlayer => 'In attesa di un giocatore...';

  @override
  String get mpLobbyStartGame => 'AVVIA PARTITA';

  @override
  String get mpLobbyWaitingForHost => 'In attesa che l\'host avvii...';

  @override
  String get mpLobbyLeave => 'ESCI';

  @override
  String get mpLobbyReadyDone => 'PRONTO!';

  @override
  String get mpLobbyReady => 'PRONTO';

  @override
  String get mpModeClassicDesc => 'Battaglia di serpenti tradizionale';

  @override
  String get mpModeSpeedDesc => 'La velocità aumenta col tempo';

  @override
  String get mpModeSurvivalDesc => 'Vince l\'ultimo serpente rimasto';

  @override
  String get mpModePowerUpDesc => 'Power-up ovunque!';

  @override
  String get mpStatusWaiting => 'In attesa';

  @override
  String get mpStatusReady => 'Pronto';

  @override
  String get mpStatusPlaying => 'In gioco';

  @override
  String get mpStatusCrashed => 'Schiantato';

  @override
  String get mpStatusDisconnected => 'Disconnesso';

  @override
  String get goNoAdAvailable =>
      'Nessun annuncio disponibile ora, riprova a breve';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Monete raddoppiate — +$count monete bonus!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'Guarda un annuncio per raddoppiare le tue $count monete';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins monete  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'Hai riscosso $count monete dalle sfide giornaliere!';
  }

  @override
  String get goRibbonNewHighScore => 'NUOVO RECORD!';

  @override
  String get goRibbonTournamentSubmitted => 'PUNTEGGIO TORNEO INVIATO!';

  @override
  String get goRibbonTournamentFailed =>
      'PUNTEGGIO NON INVIATO — CONTROLLA LA CONNESSIONE';

  @override
  String get goRibbonTournamentSubmitting => 'INVIO PUNTEGGIO TORNEO…';

  @override
  String get goVictory => 'VITTORIA!';

  @override
  String get goGameOver => 'GAME OVER';

  @override
  String get goFinalScore => 'PUNTEGGIO FINALE';

  @override
  String get goLevel => 'LIVELLO';

  @override
  String get goBest => 'RECORD';

  @override
  String get goCoinsEarned => 'Monete guadagnate';

  @override
  String get goDailyRewardsReady => 'RICOMPENSE GIORNALIERE PRONTE';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricompense',
      one: '$count ricompensa',
    );
    return '$_temp0  •  +$coins monete  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'RISCUOTI TUTTO';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'Riscuoti';

  @override
  String get goAchievements => 'OBIETTIVI';

  @override
  String get goRecentlyUnlocked => 'Sbloccati di recente';

  @override
  String get goInProgress => 'In corso';

  @override
  String get goPlayAgain => 'GIOCA ANCORA';

  @override
  String get goMenu => 'MENU';

  @override
  String get storeTitle => 'Negozio Snake';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Monete';

  @override
  String get storeTabThemes => 'Temi';

  @override
  String get storeTabSkins => 'Skin';

  @override
  String get storeTabTrails => 'Scie';

  @override
  String get storeTabPowerUps => 'Power-Up';

  @override
  String get storeYourCoins => 'Le tue Monete Snake';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'BONUS ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Abbonati prima che finisca il tuo Pro gratuito';

  @override
  String get storeChooseYourPlan => 'Scegli il tuo piano';

  @override
  String get storeWhatYouGet => 'Cosa ottieni';

  @override
  String get storeProHeroSubtitle =>
      'Tutti i temi, le skin e le scie premium · tavole grandi · monete 2× · power-up premium · ingressi ai tornei · Pass Battaglia Premium';

  @override
  String get storeMonthly => 'Mensile';

  @override
  String get storeYearly => 'Annuale';

  @override
  String get storePerMonth => '/mese';

  @override
  String get storePerYear => '/anno';

  @override
  String get storeSave17 => 'Risparmia il 17%';

  @override
  String storePlanDisplayName(Object title) {
    return 'piano $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Verifica…';

  @override
  String get storeSubscribe => 'Abbonati';

  @override
  String get storeYoureOnFreePro => 'Hai il Pro gratuito!';

  @override
  String get storeYourePro => 'Sei Pro!';

  @override
  String get storeFreePro => 'Pro gratuito';

  @override
  String get storeProMonthly => 'Pro Mensile';

  @override
  String get storeKeepPro => 'Mantieni il Pro — Abbonati';

  @override
  String get storePromoBadge => 'PROMO';

  @override
  String get storeEndingSoon => 'Termina a breve';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Termina tra ${days}g ${hours}h';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Termina tra ${hours}h ${minutes}min';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Termina tra ${minutes}min';
  }

  @override
  String get storeFeatureExtraLife =>
      'Vita extra sempre gratis — rivivi in ogni partita, senza annunci né monete';

  @override
  String get storeFeatureNoAds =>
      'Niente pubblicità — gioca completamente senza annunci';

  @override
  String get storeFeatureThemes => 'Tutti i 6 temi premium';

  @override
  String get storeFeatureSkins => 'Tutte le 11 skin premium';

  @override
  String get storeFeatureTrails => 'Tutte le 11 scie premium';

  @override
  String get storeFeatureBoards => 'Tavole premium (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => 'Guadagno monete 2×';

  @override
  String get storeFeaturePowerUps => '5× power-up premium ogni ciclo';

  @override
  String get storeFeatureTournaments =>
      'Ingressi ai tornei Bronzo + Argento + Oro ogni ciclo';

  @override
  String get storeFeatureBattlePass =>
      'Percorso Premium del Pass Battaglia ogni stagione';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Avvio dell\'acquisto di $name...';
  }

  @override
  String get storeSubNotAvailable =>
      'Abbonamento non disponibile. Riprova più tardi.';

  @override
  String get storePurchaseFailed => 'Acquisto non riuscito. Riprova.';

  @override
  String get storeBuyCoins => 'Compra Monete Snake';

  @override
  String get storeEarnFreeCoins => 'Guadagna monete gratis';

  @override
  String get storeEarnPlay => 'Gioca una partita';

  @override
  String get storeEarnPlayReward => '5 monete a partita';

  @override
  String get storeEarnDaily => 'Accesso giornaliero';

  @override
  String get storeEarnDailyReward => '10-50 monete al giorno';

  @override
  String get storeEarnAchievements => 'Obiettivi';

  @override
  String get storeEarnAchievementsReward => '25-100 monete';

  @override
  String get storeEarnTournaments => 'Tornei';

  @override
  String get storeEarnTournamentsReward => 'Oltre 100 monete';

  @override
  String get storePopularBadge => 'POPOLARE';

  @override
  String storeBuyItem(Object name) {
    return 'Compra $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'Acquistare $coins per $price?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'Compra - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'Avvio dell\'acquisto di $name...';
  }

  @override
  String get storeProductNotAvailable =>
      'Prodotto non disponibile. Riprova più tardi.';

  @override
  String get storeUnlockedWithPro => 'Sbloccato con il Pro';

  @override
  String get storeIncludedWithPro => 'Incluso in Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned =>
      'Ogni tema qui è tuo con l\'abbonamento.';

  @override
  String get storeProBannerThemesUpsell =>
      'Abbonati a Pro per sbloccare ogni tema — nessun acquisto separato.';

  @override
  String get storeProBannerSkinsOwned =>
      'Ogni skin qui è tua con l\'abbonamento.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Abbonati a Pro per sbloccare ogni skin — nessun acquisto separato.';

  @override
  String get storeProBannerTrailsOwned =>
      'Ogni scia qui è tua con l\'abbonamento.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Abbonati a Pro per sbloccare ogni scia — nessun acquisto separato.';

  @override
  String get storePremiumThemes => 'Temi premium';

  @override
  String get storeFreeThemes => 'Temi gratuiti';

  @override
  String get storeFreeThemesSubtitle =>
      'Sempre disponibili — torna quando vuoi.';

  @override
  String get storeAllThemesBundle => 'Bundle Tutti i Temi';

  @override
  String get storeAllThemesBundleSubtitle =>
      'Tutti i 6 temi premium · risparmia il 33%';

  @override
  String get storePillVerifying => 'VERIFICA';

  @override
  String get storePillOwned => 'TUO';

  @override
  String get storePillFree => 'GRATIS';

  @override
  String get storePillActive => 'ATTIVO';

  @override
  String get storePillApply => 'APPLICA';

  @override
  String get storePillEquipped => 'EQUIPAGGIATO';

  @override
  String get storePillEquip => 'EQUIPAGGIA';

  @override
  String get storeThemeDescClassic => 'Il look originale';

  @override
  String get storeThemeDescModern => 'Pulito e minimale';

  @override
  String get storeThemeDescNeon => 'Notti al neon luminose';

  @override
  String get storeThemeDescRetro => 'Sala giochi neon anni \'80';

  @override
  String get storeThemeDescSpace => 'Campo stellare cosmico';

  @override
  String get storeThemeDescOcean => 'Blu degli abissi';

  @override
  String get storeThemeDescCyberpunk => 'Ciano elettrico e rosa';

  @override
  String get storeThemeDescForest => 'Giungla smeraldo vivida';

  @override
  String get storeThemeDescDesert => 'Canyon e cactus turchese';

  @override
  String get storeThemeDescCrystal => 'Blu cristallino ghiacciato';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'Sbloccare $name per $price?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Verifica dell\'acquisto di $name…';
  }

  @override
  String get storeThemeNotAvailable =>
      'Tema non disponibile. Riprova più tardi.';

  @override
  String get storeItemNotAvailable =>
      'Articolo non disponibile. Riprova più tardi.';

  @override
  String storeEquippedToast(Object name) {
    return '$name equipaggiato';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 Scatto di Velocità gratis aggiunto al tuo inventario!';

  @override
  String get storeWatchAdTitle =>
      'Guarda un annuncio — Scatto di Velocità gratis';

  @override
  String get storeWatchAdReady =>
      'Aggiunge 1 Scatto di Velocità al tuo equipaggiamento';

  @override
  String get storeWatchAdNotReady => 'Nessun annuncio disponibile ora';

  @override
  String get puSpeedBoostDesc =>
      'Aumenta la velocità del serpente per 7 secondi.';

  @override
  String get puInvincibilityDesc =>
      'Attraversa muri e te stesso per 6 secondi.';

  @override
  String get puScoreMultiplierDesc => 'Punti doppi per 10 secondi.';

  @override
  String get puSlowMotionDesc =>
      'Rallenta il gioco per maggiore precisione (8 secondi).';

  @override
  String get storePowerUpsInfo =>
      'Compra con le monete, poi preparane uno dal chip equipaggiamento nella schermata iniziale — si attiva 5 s dopo l\'inizio della prossima partita.';

  @override
  String get storePowerUps => 'Power-Up';

  @override
  String get storePowerUpBundles => 'Bundle di Power-Up';

  @override
  String get storeBundlesSubtitle =>
      'Sblocca più tipi di power-up con uno sconto.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'Monete insufficienti!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'Acquistare 1 $name per $cost monete?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Compra - $cost monete';
  }

  @override
  String get storePurchaseFailedRetry => 'Acquisto non riuscito. Riprova.';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name aggiunto al tuo equipaggiamento!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count monete';
  }

  @override
  String get storeBuyUpper => 'COMPRA';

  @override
  String get storeNeedCoins => 'SERVONO MONETE';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name sbloccato!';
  }

  @override
  String get modeClassic => 'Classico';

  @override
  String get modeZen => 'Modalità Zen';

  @override
  String get modeSpeedChallenge => 'Sfida di Velocità';

  @override
  String get modeMultiFood => 'Multi-cibo';

  @override
  String get modeSurvival => 'Sopravvivenza';

  @override
  String get modeTimeAttack => 'A tempo';

  @override
  String get modePowerUpMadness => 'Follia Power-Up';

  @override
  String get modePerfectGame => 'Partita Perfetta';

  @override
  String get modeClassicDesc => 'Il classico gioco del serpente con i muri';

  @override
  String get modeZenDesc => 'Niente muri - il serpente attraversa lo schermo';

  @override
  String get modeSpeedChallengeDesc =>
      'La velocità aumenta rapidamente per la sfida massima';

  @override
  String get modeMultiFoodDesc => 'Più cibi compaiono contemporaneamente';

  @override
  String get modeSurvivalDesc =>
      'Sopravvivi il più a lungo possibile con vite limitate';

  @override
  String get modeTimeAttackDesc => 'Totalizza il massimo in un tempo limitato';

  @override
  String get modePowerUpMadnessDesc =>
      'I power-up compaiono molto più spesso — abbraccia il caos';

  @override
  String get modePerfectGameDesc =>
      'Non incrociare mai la tua scia. Un passo su una cella visitata termina la partita.';

  @override
  String get diffEasy => 'Facile';

  @override
  String get diffNormal => 'Normale';

  @override
  String get diffHard => 'Difficile';

  @override
  String get diffEasyDesc =>
      'Un serpente più lento all\'inizio. I punteggi restano fuori dalle classifiche.';

  @override
  String get diffNormalDesc => 'Il ritmo originale di Snake Classic.';

  @override
  String get diffHardDesc => 'Parte veloce e accelera soltanto.';

  @override
  String get themeClassic => 'Classico';

  @override
  String get themeModern => 'Moderno';

  @override
  String get themeNeon => 'Neon';

  @override
  String get themeRetro => 'Retrò';

  @override
  String get themeSpace => 'Spazio';

  @override
  String get themeOcean => 'Oceano';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeForest => 'Foresta';

  @override
  String get themeDesert => 'Deserto';

  @override
  String get themeCrystal => 'Cristallo';

  @override
  String get dpadLeft => 'Sinistra';

  @override
  String get dpadCenter => 'Centro';

  @override
  String get dpadRight => 'Destra';

  @override
  String get mpModeClassicBattle => 'Battaglia Classica';

  @override
  String get mpModeSpeedRun => 'Corsa Veloce';

  @override
  String get mpModeSurvivalMode => 'Modalità Sopravvivenza';

  @override
  String get mpModePowerUpMadnessName => 'Follia Power-Up';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonViewAll => 'Vedi tutto';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get pfTitle => 'Profilo';

  @override
  String get pfSigningOut => 'Disconnessione...';

  @override
  String get pfGuestPlayer => 'Giocatore ospite';

  @override
  String get pfVerifiedAccount => 'Account verificato';

  @override
  String get pfStatistics => 'Statistiche';

  @override
  String get pfReplays => 'Replay';

  @override
  String get pfAchievements => 'Obiettivi';

  @override
  String get pfLoadingStats => 'Caricamento statistiche...';

  @override
  String get pfHighScore => 'Record';

  @override
  String get pfGamesPlayed => 'Partite giocate';

  @override
  String get pfPlayTime => 'Tempo di gioco';

  @override
  String get pfAverageScore => 'Punteggio medio';

  @override
  String get pfFoodConsumed => 'Cibo consumato';

  @override
  String get pfPowerUps => 'Power-up';

  @override
  String get pfUpgradeTitle => 'Passa a un account Google';

  @override
  String get pfUpgradeSubtitle =>
      'Salva i tuoi progressi e sincronizza tra dispositivi';

  @override
  String get pfBenefitSync => 'Sincronizza i progressi';

  @override
  String get pfBenefitSyncSub => 'tra dispositivi';

  @override
  String get pfBenefitLeaderboards => 'Classifiche globali';

  @override
  String get pfBenefitLeaderboardsSub => 'competi con tutto il mondo';

  @override
  String get pfBenefitSocial => 'Amici e social';

  @override
  String get pfBenefitSocialSub => 'connettiti con gli altri';

  @override
  String get pfSignInGoogle => 'Accedi con Google';

  @override
  String get pfSignInApple => 'Accedi con Apple';

  @override
  String get pfNoReplays => 'Ancora nessun replay. Gioca qualche partita!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replay salvati',
      one: '$count replay salvato',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Gestione account';

  @override
  String get pfSignOut => 'Esci';

  @override
  String get pfDeleteAccount => 'Elimina account';

  @override
  String get pfAppleUpgradeSuccess =>
      'Account aggiornato ad Apple con successo! 🎉';

  @override
  String get pfAppleIdInUse =>
      'Questo ID Apple ha già un account. Esci e accedi con Apple.';

  @override
  String get pfUpgradeFailed =>
      'Aggiornamento dell\'account non riuscito. Riprova.';

  @override
  String get pfUpgradeError =>
      'Si è verificato un errore durante l\'aggiornamento dell\'account.';

  @override
  String get pfGoogleUpgradeSuccess =>
      'Account aggiornato a Google con successo! 🎉';

  @override
  String get pfDeleteAccountTitle => 'Eliminare l\'account?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'Questo elimina definitivamente il tuo account e tutto ciò che vi è collegato:\n\n• Record e statistiche\n• Monete e articoli acquistati\n• Temi, skin, scie e power-up\n• Progressi del pass battaglia e delle sfide\n• Voci in classifica e amici\n\nNon può essere annullato. Gli abbonamenti attivi vanno disdetti separatamente nelle impostazioni di $storeName.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'store di app del dispositivo';

  @override
  String get pfAccountDeleted =>
      'Il tuo account è stato eliminato definitivamente.';

  @override
  String get pfDeleteFailed =>
      'Impossibile eliminare l\'account. Controlla la connessione e riprova.';

  @override
  String get pfDeleteForever => 'Elimina per sempre';

  @override
  String get pfSignOutBody =>
      'Vuoi davvero uscire?\n\nI tuoi progressi resteranno salvati se hai effettuato l\'accesso con Google.';

  @override
  String get pfSignedOut => 'Disconnessione riuscita 👋';

  @override
  String get stLoading => 'Caricamento statistiche...';

  @override
  String get stPerformanceOverview => 'Panoramica prestazioni';

  @override
  String get stTotalGames => 'Partite totali';

  @override
  String get stWinStreak => 'Serie di vittorie';

  @override
  String get stGameActivity => 'Attività di gioco';

  @override
  String get stLongestGame => 'Partita più lunga';

  @override
  String get stHighestLevel => 'Livello più alto';

  @override
  String get stPerfectGames => 'Partite perfette';

  @override
  String get stFoodPowerUps => 'Cibo e power-up';

  @override
  String get stPowerUpsUsed => 'Power-up usati';

  @override
  String get stFavoriteFood => 'Cibo preferito';

  @override
  String get stFavoritePowerUp => 'Power-up preferito';

  @override
  String get stPerformanceTrends => 'Tendenze delle prestazioni';

  @override
  String get stOverallTrend => 'Tendenza generale';

  @override
  String get stRecentAverage => 'Media recente';

  @override
  String get stBestRecent => 'Migliore recente';

  @override
  String get stConsistency => 'Costanza';

  @override
  String get stScores => 'Punteggi';

  @override
  String get stTrendLine => 'Linea di tendenza';

  @override
  String get stPlayPatterns => 'Abitudini di gioco (ultimi 7 giorni)';

  @override
  String get stWeeklyTime => 'Tempo settimanale';

  @override
  String get stMostActiveDay => 'Giorno più attivo';

  @override
  String get stDailyActivity => 'Attività giornaliera';

  @override
  String get stAchievementProgress => 'Progresso obiettivi';

  @override
  String get stViewAllAchievements => 'Vedi tutti gli obiettivi →';

  @override
  String get stViewAchievements => 'VEDI OBIETTIVI';

  @override
  String get stReplaysUpper => 'REPLAY';

  @override
  String get stResetStatistics => 'AZZERA STATISTICHE';

  @override
  String get stResetTitle => 'Azzerare le statistiche?';

  @override
  String get stResetBody =>
      'Questo eliminerà definitivamente tutte le tue statistiche di gioco. L\'azione non può essere annullata.';

  @override
  String get stReset => 'Azzera';

  @override
  String get stNA => 'N/D';

  @override
  String get stExcellent => 'Eccellente';

  @override
  String get stGood => 'Buono';

  @override
  String get stFair => 'Discreto';

  @override
  String get stPoor => 'Scarso';

  @override
  String get stNoData => 'Nessun dato';

  @override
  String get stNone => 'Nessuno';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite',
      one: '$count partita',
    );
    return 'Progresso (ultime $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent completato';
  }

  @override
  String get stInsights => 'Analisi delle prestazioni';

  @override
  String get stInsightPlayMore =>
      'Gioca più partite per ricevere analisi delle prestazioni!';

  @override
  String get stInsightImproving =>
      'Ottimo lavoro! Le tue prestazioni sono in crescita.';

  @override
  String get stInsightAboveAverage =>
      'Le tue partite recenti sono ben oltre la tua media.';

  @override
  String get stInsightDeclined =>
      'Le tue prestazioni sono calate di recente. Prova ad allenarti di più.';

  @override
  String get stInsightPractice =>
      'Concentrati sull\'evitare le collisioni e pianificare le mosse.';

  @override
  String get stInsightStable =>
      'Le tue prestazioni sono stabili. Sfida te stesso a migliorare!';

  @override
  String get stInsightPotential =>
      'Hai potenziale per grandi punteggi - lavora sulla costanza.';

  @override
  String get stInsightSolid =>
      'Mantieni prestazioni solide nelle partite recenti.';

  @override
  String get frTitle => 'Amici';

  @override
  String get frBlockedUsers => 'Utenti bloccati';

  @override
  String get frSearchHint => 'Cerca per nome o email...';

  @override
  String get frSearching => 'Ricerca...';

  @override
  String get frSearchTitle => 'Cerca amici';

  @override
  String get frSearchSubtitle =>
      'Inserisci un nome o un\'email per trovare amici';

  @override
  String get frNoUsersFound => 'Nessun utente trovato';

  @override
  String get frNoUsersFoundSub => 'Prova con un altro nome o un\'altra email';

  @override
  String get frRequests => 'Richieste';

  @override
  String get frSearch => 'Cerca';

  @override
  String get frNoCacheYet => 'Ancora nessuna cache';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Aggiornato $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · aggiornamento fallito, tocca per riprovare';
  }

  @override
  String get frJustNow => 'proprio ora';

  @override
  String frSecondsAgo(Object count) {
    return '${count}s fa';
  }

  @override
  String frMinutesAgo(Object count) {
    return '${count}min fa';
  }

  @override
  String frHoursAgo(Object count) {
    return '${count}h fa';
  }

  @override
  String frDaysAgo(Object count) {
    return '${count}g fa';
  }

  @override
  String get frLoadingFriends => 'Caricamento amici...';

  @override
  String get frNoFriendsYet => 'Ancora nessun amico';

  @override
  String get frNoFriendsSub => 'Cerca giocatori da aggiungere come amici!';

  @override
  String get frNoRequests => 'Nessuna richiesta di amicizia';

  @override
  String get frNoRequestsSub => 'Le richieste di amicizia appariranno qui';

  @override
  String get frChallengeMenu => 'Sfida a una partita';

  @override
  String get frViewProfile => 'Vedi profilo';

  @override
  String get frRemoveFriend => 'Rimuovi amico';

  @override
  String get frBlockUser => 'Blocca utente';

  @override
  String frReceivedHeader(Object count) {
    return 'Ricevute ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Inviate ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite',
      one: '$count partita',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'Inviata $date';
  }

  @override
  String get frPending => 'In attesa';

  @override
  String get frCancelRequest => 'Annulla richiesta';

  @override
  String get frReject => 'Rifiuta';

  @override
  String get frAccept => 'Accetta';

  @override
  String get frAlreadyFriends => '✓ Amici';

  @override
  String get frAddFriend => 'Aggiungi';

  @override
  String get frSendRequestFailed =>
      'Impossibile inviare la richiesta — controlla la connessione e riprova';

  @override
  String get frAcceptFailed =>
      'Impossibile accettare la richiesta — controlla la connessione e riprova';

  @override
  String get frRejectFailed =>
      'Impossibile rifiutare la richiesta — controlla la connessione e riprova';

  @override
  String get frCancelFailed =>
      'Impossibile annullare la richiesta — controlla la connessione e riprova';

  @override
  String get frBlockFailed =>
      'Impossibile bloccare l\'utente — controlla la connessione e riprova';

  @override
  String get frSignInSocial =>
      'Accedi per aggiungere amici e usare le funzioni social';

  @override
  String get frRequestSent => 'Richiesta di amicizia inviata!';

  @override
  String get frRequestAccepted => 'Richiesta di amicizia accettata!';

  @override
  String get frRequestRejected => 'Richiesta di amicizia rifiutata';

  @override
  String get frRequestCancelled => 'Richiesta di amicizia annullata';

  @override
  String frChallengeSent(Object name) {
    return '🎮 Sfida inviata a $name!';
  }

  @override
  String get frChallengeFailed => 'Impossibile inviare la sfida — riprova';

  @override
  String frBlocked(Object name) {
    return '$name bloccato';
  }

  @override
  String frUnblocked(Object name) {
    return '$name sbloccato';
  }

  @override
  String get frUnblockFailed => 'Impossibile sbloccare — riprova';

  @override
  String frRemoved(Object name) {
    return '$name rimosso dagli amici';
  }

  @override
  String frBlockTitle(Object name) {
    return 'Bloccare $name?';
  }

  @override
  String get frBlockBody =>
      'Verrà rimosso dai tuoi amici e non potrà più inviarti richieste di amicizia o sfide. Non riceverà alcuna notifica.';

  @override
  String get frBlock => 'Blocca';

  @override
  String get frNoBlocked => 'Non hai bloccato nessuno.';

  @override
  String get frUnblock => 'Sblocca';

  @override
  String frHighScoreLine(Object score) {
    return 'Record: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Partite totali: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Livello: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Stato: \"$status\"';
  }

  @override
  String frRemoveBody(Object name) {
    return 'Rimuovere $name dalla tua lista amici?';
  }

  @override
  String get frRemove => 'Rimuovi';

  @override
  String get frLeaderboardTitle => 'Classifica amici';

  @override
  String get frLeaderboardSubtitle => 'Competi con i tuoi amici';

  @override
  String get frLoadingLeaderboard => 'Caricamento classifica...';

  @override
  String frRankBadge(Object rank) {
    return 'n. $rank';
  }

  @override
  String get frYou => 'TU';

  @override
  String get frLeaderboardEmptySub =>
      'Aggiungi amici per vedere la tua classifica privata!';

  @override
  String get frAddFriends => 'Aggiungi amici';

  @override
  String get tnTitle => 'Tornei';

  @override
  String get tnActive => 'Attivi';

  @override
  String get tnHistory => 'Cronologia';

  @override
  String get tnMyStats => 'Le mie statistiche';

  @override
  String get tnLoading => 'Caricamento tornei...';

  @override
  String get tnNoActive => 'Nessun torneo attivo';

  @override
  String get tnNoActiveSub => 'Torna più tardi per nuovi tornei!';

  @override
  String get tnNoHistory => 'Nessuna cronologia tornei';

  @override
  String get tnNoHistorySub =>
      'Partecipa ai tornei per vedere la tua cronologia!';

  @override
  String get tnNoStats => 'Nessuna statistica tornei';

  @override
  String get tnNoStatsSub => 'Unisciti ai tornei per seguire i tuoi progressi!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max giocatori';
  }

  @override
  String get tnJoined => 'Iscritto';

  @override
  String tnBestScoreChip(Object score) {
    return 'Migliore: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Posizione n. $rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricompense disponibili',
      one: '$count ricompensa disponibile',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'Vedi dettagli →';

  @override
  String get tnOverviewCard => 'Panoramica tornei';

  @override
  String get tnWins => 'Vittorie';

  @override
  String get tnTopThree => 'Piazzamenti top 3';

  @override
  String get tnBestScore => 'Miglior punteggio';

  @override
  String get tnDetailedStats => 'Statistiche dettagliate';

  @override
  String get tnTotalAttempts => 'Tentativi totali';

  @override
  String get tnWinRate => 'Percentuale di vittorie';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'Prestazione media';

  @override
  String tnTopPercent(Object percent) {
    return 'Top $percent%';
  }

  @override
  String get tnNotFound => 'Torneo non trovato';

  @override
  String get tnLoadFailed => 'Impossibile caricare il torneo';

  @override
  String get tnLoadingTournament => 'Caricamento torneo...';

  @override
  String get tnGoBack => 'Indietro';

  @override
  String get tnParticipating => 'Stai partecipando!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Migliore: $score • Tentativi: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Posizione n. $rank';
  }

  @override
  String get tnOverview => 'Panoramica';

  @override
  String get tnLeaderboard => 'Classifica';

  @override
  String get tnRules => 'Regole';

  @override
  String get tnLeaderboardFailed => 'Impossibile caricare la classifica';

  @override
  String get tnCheckConnection => 'Controlla la connessione e riprova.';

  @override
  String get tnNoParticipants => 'Ancora nessun partecipante';

  @override
  String get tnBeFirst => 'Sii il primo a partecipare!';

  @override
  String get tnDescription => 'Descrizione';

  @override
  String get tnRewards => 'Ricompense';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativi',
      one: '$count tentativo',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Regole del torneo';

  @override
  String get tnScoringSystem => 'Sistema di punteggio';

  @override
  String get tnScoringBody =>
      'Il tuo punteggio più alto durante il periodo del torneo conterà per la classifica finale. Puoi giocare più volte per migliorarlo.';

  @override
  String get tnJoining => 'ISCRIZIONE…';

  @override
  String get tnJoin => 'PARTECIPA AL TORNEO';

  @override
  String get tnPlayNow => 'GIOCA ORA';

  @override
  String get tnProUnlimited => 'Pro · Ingressi illimitati';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Ingressi rimasti: $count';
  }

  @override
  String get tnNoEntries => 'Nessun ingresso — tocca PARTECIPA per comprarne';

  @override
  String tnStarts(Object time) {
    return 'Inizia $time';
  }

  @override
  String get tnRule1 =>
      'Gioca durante il periodo del torneo perché i tuoi punteggi contino';

  @override
  String get tnRule2 =>
      'Puoi giocare più volte - conta solo il punteggio più alto';

  @override
  String get tnRule3 => 'Devi aver effettuato l\'accesso per partecipare';

  @override
  String get tnRule4 =>
      'La classifica finale è determinata alla fine del torneo';

  @override
  String get tnRuleSpeed =>
      'La velocità di gioco aumenta rapidamente ogni 10 punti';

  @override
  String get tnRuleSurvival =>
      'Il punteggio si basa sul tempo di sopravvivenza, non sul cibo';

  @override
  String get tnRuleNoWalls =>
      'Il serpente attraversa i bordi dello schermo invece di urtare i muri';

  @override
  String get tnRulePowerUps => 'I power-up compaiono ogni 5 secondi';

  @override
  String get tnRulePerfect => 'Qualsiasi collisione termina subito la partita';

  @override
  String get tnRuleClassic => 'Valgono le regole classiche del serpente';

  @override
  String get tnJoinSuccess => 'Iscrizione al torneo riuscita!';

  @override
  String get tnJoinFailed => 'Impossibile iscriversi al torneo';

  @override
  String get tnJoinError => 'Errore durante l\'iscrizione al torneo';

  @override
  String get tnTierBronze => 'Bronzo';

  @override
  String get tnTierSilver => 'Argento';

  @override
  String get tnTierGold => 'Oro';

  @override
  String get tnEntryRequired => 'Ingresso richiesto';

  @override
  String tnEntryNeeded(Object tier) {
    return 'Ti serve un ingresso $tier per partecipare a questo torneo.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Ingressi $tier attuali: $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Gli abbonati Pro hanno accesso illimitato ai tornei.';

  @override
  String get tnFreeBronzeAdded => '🎉 Ingresso Bronzo gratuito aggiunto!';

  @override
  String get tnFreeEntryAd => 'Ingresso gratuito (annuncio)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Compra ingresso $tier - $price';
  }

  @override
  String get acAll => 'Tutti';

  @override
  String get acUnlocked => 'Sbloccati';

  @override
  String get acLocked => 'Bloccati';

  @override
  String get acTotalUpper => 'TOTALE';

  @override
  String get acUnlockedUpper => 'SBLOCCATI';

  @override
  String get acClaimedUpper => 'RISCOSSI';

  @override
  String get acPendingUpper => 'IN SOSPESO';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% completato';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% degli sbloccati';
  }

  @override
  String get acEmpty => 'Nessun obiettivo qui';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Sbloccato $date';
  }

  @override
  String get rpTitle => 'Replay delle partite';

  @override
  String get rpRecent => 'Recenti';

  @override
  String get rpBest => 'Migliori';

  @override
  String get rpCrashes => 'Schianti';

  @override
  String get rpLoading => 'Caricamento replay...';

  @override
  String get rpNoRecent => 'Nessun replay recente';

  @override
  String get rpNoBest => 'Nessun replay da record';

  @override
  String get rpNoCrashes => 'Nessun replay di schianti';

  @override
  String get rpEmptySub => 'Gioca qualche partita per generare replay!';

  @override
  String get rpScore => 'Punteggio';

  @override
  String get rpDuration => 'Durata';

  @override
  String get rpFood => 'Cibo';

  @override
  String get rpFrames => 'Fotogrammi';

  @override
  String get rpMaxLength => 'Lunghezza max';

  @override
  String get rpWatch => 'Guarda';

  @override
  String get rpYesterday => 'Ieri';

  @override
  String get rpDeleteTitle => 'Eliminare il replay';

  @override
  String rpDeleteBody(Object date) {
    return 'Eliminare il replay del $date?';
  }

  @override
  String get rpDelete => 'Elimina';

  @override
  String get rpDeleted => 'Replay eliminato';

  @override
  String get rpDeleteFailed => 'Impossibile eliminare il replay';

  @override
  String get lbTitle => 'Classifiche';

  @override
  String get lbGlobal => 'Globale';

  @override
  String get lbWeekly => 'Settimanale';

  @override
  String get lbWeeklySub =>
      'In base al tuo miglior punteggio della settimana (si azzera domenica)';

  @override
  String get lbGlobalSub => 'In base al tuo punteggio più alto di sempre';

  @override
  String lbScoreLine(Object score) {
    return 'Punteggio: $score';
  }

  @override
  String get lbLoadingGlobal => 'Caricamento classifica globale...';

  @override
  String get lbLoadingWeekly => 'Caricamento classifica settimanale...';

  @override
  String get lbNoScores => 'Ancora nessun punteggio';

  @override
  String get lbBeFirst => 'Sii il primo a stabilire un record!';

  @override
  String get lbNoWeekly => 'Nessun punteggio questa settimana';

  @override
  String get lbPlayThisWeek => 'Gioca questa settimana per comparire qui!';

  @override
  String get lbAnonymous => 'Anonimo';

  @override
  String get lbGuestBadge => 'OSPITE';

  @override
  String get lbPts => 'pt';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite giocate',
      one: '$count partita giocata',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '$name riscosso!';
  }

  @override
  String get bpTitle => 'Pass Battaglia';

  @override
  String get bpTitleUpper => 'PASS BATTAGLIA';

  @override
  String get bpLoading => 'Caricamento pass battaglia...';

  @override
  String get bpWatchAdXp => 'Guarda un annuncio — +50 XP del Pass';

  @override
  String get bpXpEarned => '+50 XP del Pass Battaglia!';

  @override
  String get bpSeasonEnded => 'Stagione terminata';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h rimaste';
  }

  @override
  String bpDaysLeft(Object days) {
    return '${days}g rimasti';
  }

  @override
  String get bpTierUpper => 'LIVELLO';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'Stagione completata';

  @override
  String get bpSeasonCompleteUpper => 'STAGIONE COMPLETATA';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next XP al livello $tier';
  }

  @override
  String get bpPremiumBadge => 'PREMIUM';

  @override
  String get bpUnlockedEverything =>
      'Hai sbloccato ogni livello di questa stagione.';

  @override
  String get bpComingNext => 'IN ARRIVO';

  @override
  String bpTierN(Object tier) {
    return 'Livello $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'a $count livelli',
      one: 'a $count livello',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'SBLOCCA CON PRO';

  @override
  String get bpAvailableNow => 'DISPONIBILE ORA';

  @override
  String bpTierAbbrev(Object tier) {
    return 'L$tier';
  }

  @override
  String get bpClaim => 'RISCUOTI';

  @override
  String get bpPremiumWaiting => 'Ricompense premium in attesa';

  @override
  String get bpSubscribeToClaim => 'Abbonati a Pro per riscuoterle.';

  @override
  String get bpHideTiers => 'Nascondi livelli';

  @override
  String bpViewAllTiers(Object count) {
    return 'Vedi tutti i $count livelli';
  }

  @override
  String get bpCollapse => 'COMPRIMI';

  @override
  String get bpExpand => 'ESPANDI';

  @override
  String get bpNow => 'ADESSO';

  @override
  String bpTierUpperN(Object tier) {
    return 'LIVELLO $tier';
  }

  @override
  String get bpUnlocked => 'Sbloccato';

  @override
  String bpReachTier(Object tier) {
    return 'Raggiungi il livello $tier per sbloccare';
  }

  @override
  String get bpBetweenSeasons => 'Tra una stagione e l\'altra';

  @override
  String get bpNoSeasonBody =>
      'Nessun Pass Battaglia in corso — la prossima stagione inizierà automaticamente. Torna presto.';

  @override
  String get bpCheckNewSeason => 'Controlla nuova stagione';

  @override
  String get pbActive => 'Premium attivo!';

  @override
  String get pbActiveSub => 'Hai accesso a tutte le funzioni premium';

  @override
  String get pbHeaderSub => 'Sblocca tutto ciò che il gioco offre';

  @override
  String get pbMonthlyPlan => 'Piano mensile';

  @override
  String get pbYearlyPlan => 'Piano annuale';

  @override
  String get pbSave33 => 'Risparmia il 33%';

  @override
  String get pbMostPopular => 'PIÙ POPOLARE';

  @override
  String get pbFeatExtraLife => 'Vita extra sempre gratis';

  @override
  String get pbFeatExtraLifeDesc =>
      'Schiantati e continua — i membri Pro rivivono all\'istante gratis, senza annunci né monete, una volta a partita';

  @override
  String get pbFeatNoAds => 'Rimuovi tutti gli annunci';

  @override
  String get pbFeatNoAdsDesc =>
      'Niente banner né interstitial — gioca completamente senza pubblicità, per sempre';

  @override
  String get pbFeatThemes => 'Tutti i temi premium';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'Tutte le skin premium';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice e altre 5';

  @override
  String get pbFeatTrails => 'Tutte le scie premium';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal e altre 5';

  @override
  String get pbFeatBoards => 'Tavole di gioco grandi';

  @override
  String get pbFeatBoardsDesc => 'Gioca su tavole 35x35, 40x40 e 50x50';

  @override
  String get pbFeatCoins => 'Ricompense monete 2x';

  @override
  String get pbFeatCoinsDesc => 'Il doppio delle Monete Snake da ogni partita';

  @override
  String get pbFeatLucky => 'Fortunato — più cibi speciali';

  @override
  String get pbFeatLuckyDesc =>
      '+50% di probabilità che compaia il raro cibo speciale da 50 punti in ogni partita';

  @override
  String get pbFeatPowerUps => 'Più power-up in gioco';

  @override
  String get pbFeatPowerUpsDesc =>
      '+30% di frequenza dei power-up sulla tavola';

  @override
  String get pbFeatBundle => 'Bundle di power-up premium';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield e Mega Invincibility a ogni ciclo di fatturazione';

  @override
  String get pbFeatTournament => 'Ingressi ai tornei';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronzo + 1× Argento + 1× Oro a ogni ciclo di fatturazione';

  @override
  String get pbIncludes => 'Premium include:';

  @override
  String get pbProPerk => 'VANTAGGIO PRO';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'Abbonati — $price$period';
  }

  @override
  String get pbReassurance =>
      'Nessun vincolo • Annulla quando vuoi • Pagamento sicuro';

  @override
  String get pbNotAvailable => 'Abbonamento premium non disponibile';

  @override
  String get eaTitleLink => 'Salva i tuoi progressi';

  @override
  String get eaTitleSignIn => 'Accesso con email';

  @override
  String get eaExplainer =>
      'Aggiungi email e password al tuo account per acquistare, ripristinare dopo la reinstallazione e accedere da qualsiasi dispositivo.';

  @override
  String get eaLinkExisting => 'Collega esistente';

  @override
  String get eaSignIn => 'Accedi';

  @override
  String get eaCreateAccount => 'Crea account';

  @override
  String get eaForgotPassword => 'Password dimenticata?';

  @override
  String get eaLinkToExisting => 'Collega ad account esistente';

  @override
  String get eaMinChars => 'Almeno 8 caratteri';

  @override
  String eaMinCharsN(Object count) {
    return 'Almeno $count caratteri';
  }

  @override
  String get eaCreateAndLink => 'Crea e collega account';

  @override
  String get eaEmail => 'Email';

  @override
  String get eaEmailRequired => 'L\'email è obbligatoria';

  @override
  String get eaEmailInvalid => 'Inserisci un\'email valida';

  @override
  String get eaPassword => 'Password';

  @override
  String get eaPasswordRequired => 'La password è obbligatoria';

  @override
  String get eaForgotFirst =>
      'Inserisci prima la tua email sopra, poi tocca Password dimenticata.';

  @override
  String eaResetSent(Object email) {
    return 'Email di reimpostazione inviata a $email.';
  }

  @override
  String get eaErrInvalidEmail => 'Questo indirizzo email non è valido.';

  @override
  String get eaErrDisabled => 'Questo account è stato disabilitato.';

  @override
  String get eaErrNoAccount => 'Nessun account trovato con questa email.';

  @override
  String get eaErrWrongCreds => 'Email o password errata.';

  @override
  String get eaErrEmailInUse =>
      'Esiste già un account con questa email. Prova ad accedere.';

  @override
  String get eaErrWeakPassword =>
      'La password è troppo debole. Usa almeno 8 caratteri.';

  @override
  String get eaErrNotEnabled =>
      'L\'accesso con email/password non è abilitato. Contatta l\'assistenza.';

  @override
  String get eaErrTooMany =>
      'Troppi tentativi. Attendi qualche minuto e riprova.';

  @override
  String get eaErrNetwork => 'Errore di rete. Controlla la connessione.';

  @override
  String get eaErrAlreadyLinked =>
      'Questo account è già collegato a email/password.';

  @override
  String get eaErrRecentLogin =>
      'Per sicurezza, accedi di nuovo prima di collegare.';

  @override
  String get eaErrGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get faWelcome => 'Benvenuto in\nSnake Classic!';

  @override
  String get faChooseHow => 'Scegli come vuoi giocare:';

  @override
  String get faSigningIn => 'Accesso in corso...';

  @override
  String get faSignInEmail => 'Accedi con email';

  @override
  String get faContinueGuest => 'Continua come ospite';

  @override
  String get faGuestNote =>
      'Gli ospiti possono giocare e salvare i progressi localmente, ma non acquistare. Accedi con Apple, Google o email quando vorrai abbonarti o comprare.';

  @override
  String get faPrivacyTerms => 'Privacy e termini';

  @override
  String get faReviewNote =>
      'Leggi la nostra Informativa sulla privacy e i Termini di utilizzo prima di continuare';

  @override
  String get faAgreeCheckbox =>
      'Ho letto e accetto l\'Informativa sulla privacy e i Termini di utilizzo';

  @override
  String get faContinueToSignIn => 'Continua all\'accesso';

  @override
  String get faHeadsUp => 'Attenzione';

  @override
  String get faGuestBullet1 =>
      'I dati ospite vengono eliminati automaticamente dai nostri server dopo 90 giorni di inattività.';

  @override
  String get faGuestBullet2 =>
      'Per salvare i progressi in modo permanente e giocare su più dispositivi, accedi con Apple, Google o email.';

  @override
  String get faGuestBullet3 =>
      'Gli account ospite non possono acquistare prodotti o abbonamenti. Accedi se vuoi passare a Pro o comprare cosmetici.';

  @override
  String get faChangedMind => 'Ho cambiato idea';

  @override
  String get faProceedAnyway => 'Continua comunque';

  @override
  String get faAppleFailed => 'Accesso con Apple non riuscito. Riprova.';

  @override
  String get faGoogleFailed => 'Accesso con Google non riuscito. Riprova.';

  @override
  String get faUnexpected => 'Si è verificato un errore imprevisto. Riprova.';

  @override
  String get faGuestFailed => 'Impossibile continuare come ospite. Riprova.';

  @override
  String get ldInitializing => 'Avvio di Snake Classic...';

  @override
  String get ldTip1 =>
      'Pensa due mosse avanti — la coda segue dove è appena passata la testa.';

  @override
  String get ldTip2 =>
      'Il cibo bonus vale più punti, ma sparisce in fretta. Prendilo al volo!';

  @override
  String get ldTip3 =>
      'Ti sei schiantato? Guarda un breve annuncio o spendi monete per rivivere e tenere il punteggio.';

  @override
  String get ldTip4 =>
      'Concatena il cibo senza pause per costruire un moltiplicatore combo.';

  @override
  String get ldTip5 =>
      'Bloccato in uno spazio stretto? Costeggia i muri per guadagnare un attimo.';

  @override
  String get ldTip6 =>
      'Le sfide giornaliere e le missioni settimanali accumulano monete in fretta.';

  @override
  String get ldTip7 =>
      'Snake Classic Pro sblocca tavole più grandi e rimuove tutti gli annunci.';

  @override
  String get ldTip8 =>
      'La modalità A tempo premia la velocità — e un annuncio vale +30 secondi.';

  @override
  String get ldTip9 =>
      'I power-up si sommano: arma uno scudo prima di un passaggio stretto.';

  @override
  String get ldTip10 =>
      'Cambia temi, skin e scie quando vuoi nel negozio per un look nuovo.';

  @override
  String get ldStepCore => 'Avvio dei sistemi principali...';

  @override
  String get ldStepCoreSub => 'Configurazione della connessione al server';

  @override
  String get ldStepProfile => 'Creazione del tuo profilo giocatore...';

  @override
  String get ldStepProfileSub => 'Generazione di un nome utente unico';

  @override
  String get ldStepPrefs => 'Caricamento delle tue preferenze...';

  @override
  String get ldStepPrefsSub => 'Sincronizzazione di temi e impostazioni';

  @override
  String get ldStepCloud => 'Sincronizzazione con il cloud...';

  @override
  String get ldStepCloudSub => 'Verifica dell\'aggiornamento dei dati';

  @override
  String get ldStepGameData => 'Caricamento dei dati di gioco...';

  @override
  String get ldStepGameDataSub => 'Recupero dei dati di gioco';

  @override
  String get ldStepAudio => 'Configurazione del sistema audio...';

  @override
  String get ldStepAudioSub => 'Caricamento degli effetti sonori';

  @override
  String get ldStepSetup => 'Verifica dello stato di configurazione...';

  @override
  String get ldStepSetupSub => 'Quasi pronto!';

  @override
  String get ldWelcome => 'Benvenuto!';

  @override
  String get ldWelcomeSub => 'Scegli come continuare';

  @override
  String get ldReady => 'Pronto a giocare!';

  @override
  String get ldReadySub => 'Bentornato in Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Avvio non riuscito: $error';
  }

  @override
  String get ldRetrying => 'Nuovo tentativo di avvio...';

  @override
  String get ldTagline => 'ESPERIENZA SNAKE PREMIUM';

  @override
  String get ldLoadingUpper => 'CARICAMENTO';

  @override
  String get ldDidYouKnow => 'LO SAPEVI?';

  @override
  String get ldGameFeatures => 'CARATTERISTICHE';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Gioco fluido';

  @override
  String get ldFeatEffects => 'EFFETTI';

  @override
  String get ldFeatEffectsSub => 'Particelle visive';

  @override
  String get ldFeatLevels => 'LIVELLI';

  @override
  String get ldFeatLevelsSub => 'Divertimento crescente';

  @override
  String get ldFeatAudio => 'AUDIO';

  @override
  String get ldFeatAudioSub => 'Suono immersivo';

  @override
  String get ldFeatScores => 'PUNTEGGI';

  @override
  String get ldFeatScoresSub => 'Classifiche globali';

  @override
  String get ldFeatThemes => 'TEMI';

  @override
  String get ldFeatThemesSub => 'Stili multipli';

  @override
  String get ldDevelopedBy => 'SVILUPPATO E MANTENUTO DA';

  @override
  String get ldDevTagline => 'Creiamo esperienze mobile premium';

  @override
  String get ldInitFailedUpper => 'AVVIO NON RIUSCITO';

  @override
  String get ldRetryUpper => 'RIPROVA';

  @override
  String get pgArena => 'Preparazione dell\'arena...';

  @override
  String get pgControls => 'Calibrazione dei controlli...';

  @override
  String get pgSnake => 'Evocazione del serpente...';

  @override
  String get pgFood => 'Posizionamento del cibo...';

  @override
  String get pgPowerUps => 'Ricarica dei power-up...';

  @override
  String get pgAlmost => 'Ci siamo quasi...';

  @override
  String get pgGo => 'Via!';

  @override
  String get pgTip1 =>
      'Mantieni una direzione più a lungo per costruire moltiplicatori combo.';

  @override
  String get pgTip2 => 'Il cibo bonus rende più punti ma svanisce in fretta.';

  @override
  String get pgTip3 => 'I power-up compaiono a caso — prendili finché puoi.';

  @override
  String get pgTip4 => 'Pensa due mosse avanti, non solo una.';

  @override
  String get pgTip5 =>
      'I serpenti lunghi girano più lentamente. Riserva le curve strette all\'inizio.';

  @override
  String get pgTip6 =>
      'Il Moltiplicatore Punti si somma alle combo per punteggi mostruosi.';

  @override
  String get pgTip7 =>
      'Il cibo speciale è raro — quando appare, dagli priorità.';

  @override
  String get pgTip8 => 'A tempo accelera in fretta. Dosa le tue curve.';

  @override
  String get pgTip9 =>
      'In Modalità Zen i muri si attraversano. Usalo per uscire dai guai.';

  @override
  String get pgTip10 =>
      'Partita Perfetta: non rientrare mai in una cella toccata dal tuo corpo.';

  @override
  String get pgTip11 =>
      'Il D-Pad dà curve precise; lo scorrimento è più veloce.';

  @override
  String get pgTip12 =>
      'Metti in pausa dall\'HUD quando vuoi — il timer ti aspetta.';

  @override
  String get pgPreparing => 'PREPARAZIONE ARENA';

  @override
  String get pgTournamentMode => 'MODALITÀ TORNEO';

  @override
  String get pgGameMode => 'MODALITÀ DI GIOCO';

  @override
  String get pgDPadControls => 'Controlli D-Pad';

  @override
  String get pgSwipeControls => 'Controlli a scorrimento';

  @override
  String get pgLevel => 'LIVELLO';

  @override
  String get pgBest => 'RECORD';

  @override
  String get pgGames => 'PARTITE';

  @override
  String get pgProTip => 'CONSIGLIO PRO';

  @override
  String get pgTapToStart => 'TOCCA OVUNQUE PER INIZIARE';

  @override
  String get wtWelcomeTitle => 'Benvenuto nel gioco!';

  @override
  String get wtWelcomeMsg =>
      'Impariamo a giocare a Snake Classic. Questo breve tutorial ti mostrerà le basi.';

  @override
  String get wtHudTitle => 'Info di gioco';

  @override
  String get wtHudMsg =>
      'La barra in alto mostra punteggio, livello e record. Segui i tuoi progressi mentre giochi!';

  @override
  String get wtControlsTitle => 'Scorri per muoverti';

  @override
  String get wtControlsMsg =>
      'Scorri in qualsiasi direzione per cambiare la rotta del serpente. Girerà seguendo il tuo gesto.';

  @override
  String get wtPracticeRightTitle => 'Provaci! Scorri a DESTRA';

  @override
  String get wtPracticeRightMsg =>
      'Scorri a DESTRA sullo schermo per continuare.';

  @override
  String get wtPracticeUpTitle => 'Ottimo! Ora scorri in SU';

  @override
  String get wtPracticeUpMsg => 'Scorri in SU sullo schermo per continuare.';

  @override
  String get wtFoodTitle => 'Mangia per crescere';

  @override
  String get wtFoodMsg =>
      'Guida il serpente a mangiare il cibo sulla tavola. Ogni cibo lo allunga!';

  @override
  String get wtComboTitle => 'Costruisci una combo';

  @override
  String get wtComboMsg =>
      'Mangia senza morire per costruire una combo. A 5 morsi ottieni 1,5×, a 10 ottieni 2×, a 20 ottieni 3×. Il chip di fuoco vicino al punteggio si scalda e pulsa mentre sali.';

  @override
  String get wtPowerUpsTitle => 'Power-up';

  @override
  String get wtPowerUpsMsg =>
      'Ogni tanto compaiono icone scintillanti — mangiane una per attivarla. L\'anello attorno all\'icona si svuota mentre l\'effetto finisce, e il timer si congela in pausa.';

  @override
  String get wtWallsTitle => 'Evita i muri!';

  @override
  String get wtWallsMsg =>
      'Non toccare i bordi della tavola - schiantarsi contro un muro significa game over!';

  @override
  String get wtSelfTitle => 'Non colpirti da solo!';

  @override
  String get wtSelfMsg =>
      'Quando il serpente si allunga, attento a non urtare il tuo stesso corpo!';

  @override
  String get wtPauseTitle => 'Pausa quando vuoi';

  @override
  String get wtPauseMsg =>
      'Tocca l\'icona pausa per congelare la partita. Da lì puoi riprendere, ricominciare, aprire la Guida, ripetere questo tutorial o attivare il D-Pad.';

  @override
  String get wtReadyTitle => 'Sei pronto!';

  @override
  String get wtReadyMsg =>
      'Buona fortuna! Apri la Guida dal menu pausa quando vuoi per leggere di combo, power-up, modalità e segnali di schianto. Guarda il tuo Profilo per vedere gli obiettivi sbloccarsi.';

  @override
  String get wtStartPlaying => 'Inizia a giocare!';

  @override
  String get wtSkipTutorial => 'Salta il tutorial';

  @override
  String get wtSwipeRightUpper => 'SCORRI A DESTRA';

  @override
  String get wtSwipeLeftUpper => 'SCORRI A SINISTRA';

  @override
  String get wtSwipeUpUpper => 'SCORRI IN SU';

  @override
  String get wtSwipeDownUpper => 'SCORRI IN GIÙ';

  @override
  String get wtSwipeAnywhereScreen => 'Scorri ovunque sullo schermo!';

  @override
  String get wtSwipeAnywhere => 'Scorri ovunque!';

  @override
  String get wtGotIt => 'Capito!';

  @override
  String get wtNext => 'Avanti';

  @override
  String get wtSkip => 'Salta';

  @override
  String get wtWaiting => 'In attesa...';

  @override
  String get hwPlayTitle => 'Benvenuto in Snake Classic!';

  @override
  String get hwPlayMsg =>
      'Tocca il pulsante GIOCA per iniziare. Scorri per guidare il serpente e mangia per crescere!';

  @override
  String get hwCoinsTitle => 'Le tue monete';

  @override
  String get hwCoinsMsg =>
      'Guadagna monete giocando, completando sfide e con i bonus giornalieri. Usale nel negozio!';

  @override
  String get hwDailyTitle => 'Sfide giornaliere';

  @override
  String get hwDailyMsg =>
      'Completa le sfide giornaliere per monete e ricompense bonus. Sfide nuove ogni giorno!';

  @override
  String get hwStoreTitle => 'Il negozio';

  @override
  String get hwStoreMsg =>
      'Compra temi, skin, scie e power-up con le tue monete. Sblocca Pro per tavole premium e cosmetici esclusivi.';

  @override
  String get hwCosmeticsTitle => 'Skin e scie';

  @override
  String get hwCosmeticsMsg =>
      'Personalizza qui il tuo serpente. Le skin cambiano il suo aspetto; le scie lasciano un bagliore dietro di lui. Guadagnale con le monete o sbloccale con Pro.';

  @override
  String get hwProfileTitle => 'Il tuo profilo';

  @override
  String get hwProfileMsg =>
      'Statistiche, obiettivi e record vivono qui. Gli obiettivi si sbloccano ai traguardi — alcuni richiedono una modalità precisa (Classico, Difficile, ecc.). Accedi per sincronizzare i dispositivi.';

  @override
  String get hwSettingsTitle => 'Impostazioni';

  @override
  String get hwSettingsMsg =>
      'Personalizza la tua esperienza - cambia temi, controlli, audio e altro!';

  @override
  String get hudScoreUpper => 'PUNTI';

  @override
  String hudScoreSemantics(Object value) {
    return 'Punteggio $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'LV$level';
  }

  @override
  String get hudTournamentBadge => 'TORNEO';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'IN PAUSA';

  @override
  String get poPremium => 'Premium';

  @override
  String get poStore => 'Negozio';

  @override
  String get poResume => 'RIPRENDI';

  @override
  String get poRestart => 'RICOMINCIA';

  @override
  String get poHome => 'MENU';

  @override
  String get poDPadOn => 'D-PAD: SÌ';

  @override
  String get poDPadOff => 'D-PAD: NO';

  @override
  String get poSound => 'SUONO';

  @override
  String get poMusic => 'MUSICA';

  @override
  String get poHowToPlay => 'COME GIOCARE';

  @override
  String get poGameGuide => 'GUIDA AL GIOCO';

  @override
  String get poFoodUpper => 'CIBO';

  @override
  String get poPts10 => '10 pt';

  @override
  String get poPts25 => '25 pt';

  @override
  String get poPts50 => '50 pt';

  @override
  String get poComboUpper => 'COMBO';

  @override
  String get poBites5 => '5 morsi';

  @override
  String get poBites10 => '10 morsi';

  @override
  String get poBites20 => '20 morsi';

  @override
  String get poComboHint =>
      'Il chip di fuoco vicino al punteggio si scalda e pulsa a ogni soglia superata.';

  @override
  String get poPowerUpsUpper => 'POWER-UP';

  @override
  String get poDur7s => '7 s';

  @override
  String get poDur6s => '6 s';

  @override
  String get poDur10s => '10 s';

  @override
  String get poDur8s => '8 s';

  @override
  String get poScore2x => 'Punti 2×';

  @override
  String get poPowerUpHint =>
      'L\'anello dell\'icona si svuota fino alla scadenza. Il timer si congela in pausa.';

  @override
  String get poCrashUpper => 'SCHIANTO';

  @override
  String get poCrashHint =>
      'Un\'onda rossa esplode sulla cella dove sei morto. La collisione con te stesso evidenzia in giallo anche il segmento colpito.';

  @override
  String get poModesUpper => 'MODALITÀ';

  @override
  String get poModeWallsOn => 'muri attivi';

  @override
  String get poModeWallsOff => 'senza muri';

  @override
  String get poModeFastTick => 'ritmo veloce';

  @override
  String get poModeThreeFoods => '3 cibi insieme';

  @override
  String get poModeThreeLives => '3 vite, accelera';

  @override
  String get poModeThreeMin => '3 min in totale';

  @override
  String get poModeFrequentPowerUps => 'power-up frequenti';

  @override
  String get poModeDontCross => 'non incrociare la scia';

  @override
  String get dcTitle => 'Sfide giornaliere';

  @override
  String get dcNoChallenges => 'Nessuna sfida disponibile';

  @override
  String get dcAllComplete => 'Tutto completato!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count bonus';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · build $build';
  }

  @override
  String get crTagline => 'Il classico gioco del serpente, reinventato.';

  @override
  String get crChipModes => 'Modalità';

  @override
  String get crChipAchievements => 'Obiettivi';

  @override
  String get crChipDaily => 'Giornaliero';

  @override
  String get crChipLeaderboards => 'Classifiche';

  @override
  String get crChipCosmetics => 'Cosmetici';

  @override
  String get crCraftedBy => 'Creato da';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · Tutti i diritti riservati';
  }

  @override
  String get gbSpeedNormal => 'Normale';

  @override
  String get gbSpeedFast => 'Veloce';

  @override
  String get gbSpeedFaster => 'Più veloce';

  @override
  String get gbSpeedBlazing => 'Rovente';

  @override
  String get gbSpeedInsane => 'Folle';

  @override
  String get gbSpeedMax => 'MAX';

  @override
  String get gbLength => 'Lunghezza';

  @override
  String get gbSpeed => 'Velocità';

  @override
  String get gbLevel => 'Livello';
}
