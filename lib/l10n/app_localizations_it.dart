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
}
