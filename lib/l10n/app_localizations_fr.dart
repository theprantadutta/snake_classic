// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'LANGUE';

  @override
  String get languageSystemDefault => 'Par défaut du système';

  @override
  String get languageSystemDefaultSubtitle => 'Suivre la langue de l\'appareil';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get mpVictory => 'VICTOIRE !';

  @override
  String get mpDraw => 'ÉGALITÉ';

  @override
  String get mpDefeat => 'DÉFAITE';

  @override
  String get mpYou => 'Vous';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Adversaire';

  @override
  String get mpBackToLobby => 'Retour au salon';

  @override
  String get mpPlayAgain => 'Rejouer';

  @override
  String get mpTimeUpDraw => 'Temps écoulé — égalité parfaite !';

  @override
  String get mpTimeUpYouWon => 'Temps écoulé — vous aviez le meilleur score.';

  @override
  String get mpTimeUpYouLost =>
      'Temps écoulé — votre adversaire avait le meilleur score.';

  @override
  String get mpMutualCrashDraw =>
      'Les deux serpents se sont écrasés — égalité !';

  @override
  String get mpMutualCrashYouWon =>
      'Les deux serpents se sont écrasés — votre score a fait la différence.';

  @override
  String get mpMutualCrashYouLost =>
      'Les deux serpents se sont écrasés — son score a fait la différence.';

  @override
  String get mpMatchCancelled => 'Le match a été annulé.';

  @override
  String get mpLastSnakeStanding =>
      'Votre adversaire s\'est écrasé. Dernier serpent en lice !';

  @override
  String get mpDeathWall => 'Vous avez percuté le mur.';

  @override
  String get mpDeathSelf => 'Vous vous êtes percuté vous-même.';

  @override
  String get mpDeathOpponent => 'Vous avez percuté votre adversaire.';

  @override
  String get mpDeathHeadOn => 'Collision frontale !';

  @override
  String get mpDeathForfeit =>
      'Déconnecté trop longtemps — match perdu par forfait.';

  @override
  String get mpBetterLuck => 'Plus de chance la prochaine fois !';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count pièces',
      one: '+$count pièce',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Quitter la partie ?';

  @override
  String get mpLeaveGameBody =>
      'Le match continue sur le serveur — quitter vaut forfait.';

  @override
  String get mpLeave => 'Quitter';

  @override
  String get mpReconnecting => 'RECONNEXION…';

  @override
  String get mpReconnectingBody => 'Le match continue sur le serveur.';

  @override
  String get mpGetReady => 'PRÉPAREZ-VOUS';

  @override
  String get mpDroppingIntoArena => 'Entrée dans l\'arène…';

  @override
  String get mpWaitingPlayer => 'En attente…';

  @override
  String get mpOut => 'OUT';

  @override
  String get mpLength => 'LONGUEUR';

  @override
  String get mpSwipe => 'Glisser';

  @override
  String get mpReconnectingInline => 'reconnexion…';

  @override
  String get homePlay => 'JOUER';

  @override
  String get homeHighScore => 'MEILLEUR SCORE';

  @override
  String homeArmedPowerUp(String name) {
    return 'Équipé : $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Équipement ($count)';
  }

  @override
  String get puSpeedBoost => 'Boost de Vitesse';

  @override
  String get puInvincibility => 'Invincibilité';

  @override
  String get puScoreMultiplier => 'Multiplicateur de Score';

  @override
  String get puSlowMotion => 'Ralenti';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'BOUTIQUE';

  @override
  String get homeTileFree => 'GRATUIT';

  @override
  String get homeTileDaily => 'DÉFIS';

  @override
  String get homeTileBattle => 'BATAILLE';

  @override
  String get homeTileEvents => 'TOURNOIS';

  @override
  String get homeTileBoard => 'CLASSEMENT';

  @override
  String get homeTileFriends => 'AMIS';

  @override
  String get homeTileCosmetics => 'STYLES';

  @override
  String get homeTileAwards => 'TROPHÉES';

  @override
  String get homeTileVersus => 'VERSUS';

  @override
  String get homeNoAdReady =>
      'Aucune pub prête pour l\'instant — réessayez dans quelques secondes.';

  @override
  String get homeFreeSpeedBoostTitle => 'Boost de Vitesse gratuit';

  @override
  String get homeFreeSpeedBoostBody =>
      'Regardez une courte pub pour ajouter un Boost de Vitesse gratuit à votre équipement. Il s\'active 5 secondes après le début de votre prochaine partie.';

  @override
  String get homeNotNow => 'Plus tard';

  @override
  String get homeWatchAd => 'Voir la pub';

  @override
  String get homeFreeSpeedBoostAdded =>
      'Boost de Vitesse gratuit ajouté à votre équipement !';

  @override
  String get homeAdNotFinished =>
      'Pub non terminée — regardez-la en entier pour obtenir votre récompense.';

  @override
  String get homePickGameMode => 'Choisissez un mode de jeu';

  @override
  String get homePickGameModeSubtitle =>
      'Modifiable à tout moment dans les Réglages';

  @override
  String get homeStartPlaying => 'COMMENCER À JOUER';

  @override
  String get homeLoadoutTitle => 'Équipement de power-ups';

  @override
  String get homeLoadoutSubtitle =>
      'Préchargez un power-up — il s\'active 5 secondes après le début de votre prochaine partie.';

  @override
  String get homeWatchAdFreeSpeedBoost =>
      'Voir la pub — Boost de Vitesse gratuit';

  @override
  String get homeNoPowerUps =>
      'Vous n\'avez aucun power-up.\nPassez à la boutique pour en acheter !';

  @override
  String homeOwnedCount(int count) {
    return 'Possédés : $count';
  }

  @override
  String get homeArmed => 'ÉQUIPÉ';

  @override
  String get homeDone => 'TERMINÉ';

  @override
  String get settingsTitle => 'RÉGLAGES';

  @override
  String get settingsBackToGame => 'RETOUR AU JEU';

  @override
  String get settingsSectionControls => 'COMMANDES';

  @override
  String get settingsSectionGameplay => 'GAMEPLAY';

  @override
  String get settingsSectionAudio => 'AUDIO';

  @override
  String get settingsSectionVisual => 'VISUEL';

  @override
  String get settingsSectionNotifications => 'NOTIFICATIONS';

  @override
  String get settingsSectionUserProfile => 'PROFIL UTILISATEUR';

  @override
  String get settingsSectionHelp => 'AIDE ET TUTORIEL';

  @override
  String get settingsSectionLegal => 'MENTIONS LÉGALES';

  @override
  String get settingsSectionPremium => 'FONCTIONNALITÉS PREMIUM';

  @override
  String get settingsDPadControls => 'Commandes D-Pad';

  @override
  String get settingsDPadSubtitle =>
      'Afficher les boutons directionnels à l\'écran pendant le jeu';

  @override
  String get settingsDPadPosition => 'Position du D-Pad';

  @override
  String get settingsDesktopControls => 'Commandes bureau/web';

  @override
  String get settingsArrowKeys => 'Touches fléchées';

  @override
  String get settingsWasdKeys => 'Touches WASD';

  @override
  String get settingsSpacebar => 'Barre d\'espace';

  @override
  String get settingsMouseClick => 'Clic de souris';

  @override
  String get settingsChangeDirection => 'Changer de direction';

  @override
  String get settingsPauseResume => 'Pause/Reprise du jeu';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Commandes tactiles (si disponibles)';

  @override
  String get settingsTouchControls => 'Commandes tactiles';

  @override
  String get settingsSwipeGestures => 'Gestes de balayage';

  @override
  String get settingsTapScreen => 'Toucher l\'écran';

  @override
  String get settingsSwipeUp => 'Balayer vers le haut ↑';

  @override
  String get settingsSwipeDown => 'Balayer vers le bas ↓';

  @override
  String get settingsSwipeLeft => 'Balayer vers la gauche ←';

  @override
  String get settingsSwipeRight => 'Balayer vers la droite →';

  @override
  String get settingsMoveSnakeUp => 'Déplacer le serpent vers le haut';

  @override
  String get settingsMoveSnakeDown => 'Déplacer le serpent vers le bas';

  @override
  String get settingsMoveSnakeLeft => 'Déplacer le serpent vers la gauche';

  @override
  String get settingsMoveSnakeRight => 'Déplacer le serpent vers la droite';

  @override
  String get settingsGameMode => 'Mode de jeu';

  @override
  String get settingsGameModeLocked =>
      'Terminez la partie en cours pour changer de mode';

  @override
  String get settingsDifficulty => 'Difficulté';

  @override
  String get settingsDifficultySubtitle =>
      'Définit la vitesse de départ du serpent. Chaque mode accélère au fil des niveaux.';

  @override
  String get settingsEasyNote =>
      'Pièces, XP et succès comptent toujours en Facile — seuls les records et classements sont en pause.';

  @override
  String get settingsDifficultyLocked =>
      'Terminez la partie en cours pour changer la difficulté.';

  @override
  String get settingsCurrentSize => 'Taille actuelle';

  @override
  String get settingsBoardSizeLocked =>
      'Terminez la partie en cours pour changer la taille du plateau';

  @override
  String get settingsCurrentDuration => 'Durée actuelle';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Durée d\'affichage de l\'explication du crash';

  @override
  String get settingsScreenShake => 'Secousse d\'écran';

  @override
  String get settingsScreenShakeSubtitle =>
      'Secouer l\'écran lors des collisions et événements';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationSubtitle =>
      'Vibrer lors des événements du jeu et des appuis';

  @override
  String get settingsSoundEffects => 'Effets sonores';

  @override
  String get settingsBackgroundMusic => 'Musique de fond';

  @override
  String get settingsCurrentTheme => 'Thème actuel';

  @override
  String get settingsBrowseThemes => 'PARCOURIR LES THÈMES';

  @override
  String get settingsSnakeTrail => 'Effets de traînée';

  @override
  String get settingsSnakeTrailSubtitle =>
      'Activer les traînées de particules derrière le serpent';

  @override
  String get settingsNotifDailyReminder => 'Rappel quotidien';

  @override
  String get settingsNotifTournament => 'Alertes de tournoi';

  @override
  String get settingsNotifAchievement => 'Succès débloqués';

  @override
  String get settingsNotifSocial => 'Actualités sociales';

  @override
  String get settingsNotifSpecialEvents => 'Événements spéciaux';

  @override
  String get settingsNotSet => 'Non défini';

  @override
  String get settingsUsername => 'Nom d\'utilisateur';

  @override
  String get settingsGuestAccount => 'Compte invité';

  @override
  String get settingsAuthenticatedAccount => 'Compte authentifié';

  @override
  String get settingsChangeUsername => 'CHANGER DE NOM D\'UTILISATEUR';

  @override
  String get settingsGuestSignInHint =>
      'Connectez-vous pour garder votre progression et jouer avec des amis';

  @override
  String get settingsUsernameVisibleHint =>
      'Votre nom d\'utilisateur est visible par vos amis et dans les classements';

  @override
  String get settingsReplayTutorial => 'REVOIR LE TUTORIEL';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Revoir la visite d\'accueil ou le tutoriel du jeu';

  @override
  String get settingsAboutCredits => 'À PROPOS ET CRÉDITS';

  @override
  String get settingsAboutCreditsSubtitle =>
      'Version de l\'app, crédits et liens';

  @override
  String get settingsRateApp => 'NOTER SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'Le jeu vous plaît ? Laissez un avis sur l\'App Store';

  @override
  String get settingsRateAppSubtitle =>
      'Le jeu vous plaît ? Laissez-nous un avis !';

  @override
  String get settingsAdPrivacy => 'CONFIDENTIALITÉ ET PUBLICITÉS';

  @override
  String get settingsAdPrivacySubtitle =>
      'Gérer le consentement aux publicités personnalisées';

  @override
  String get settingsAdPrivacyUnavailable =>
      'Les options de confidentialité publicitaire sont indisponibles pour le moment.';

  @override
  String get settingsReplayDialogTitle => 'Revoir le tutoriel';

  @override
  String get settingsReplayDialogBody =>
      'Quel tutoriel souhaitez-vous revoir ?';

  @override
  String get settingsHomeTour => 'Visite d\'accueil';

  @override
  String get settingsGameTutorial => 'Tutoriel du jeu';

  @override
  String get settingsPrivacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get settingsPrivacyPolicyButton => 'POLITIQUE DE CONFIDENTIALITÉ';

  @override
  String get settingsTermsTitle => 'Conditions d\'utilisation';

  @override
  String get settingsTermsButton => 'CONDITIONS D\'UTILISATION';

  @override
  String get settingsChangeUsernameTitle => 'Changer de nom d\'utilisateur';

  @override
  String get settingsCurrentLabel => 'Actuel :';

  @override
  String get settingsUsernameDialogBody =>
      'Choisissez un nom d\'utilisateur unique qui vous représente dans le jeu.';

  @override
  String get settingsEnterNewUsername =>
      'Saisissez le nouveau nom d\'utilisateur';

  @override
  String get settingsUsernameRules =>
      '• 3-20 caractères\n• Doit commencer par une lettre\n• Lettres, chiffres et tirets bas uniquement';

  @override
  String get settingsUsernameUpdateFailed =>
      'Échec de la mise à jour du nom d\'utilisateur';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Nom d\'utilisateur remplacé par « $name »';
  }

  @override
  String get settingsUpdate => 'Mettre à jour';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Statut premium';

  @override
  String get settingsActiveSubscription => 'Abonnement actif';

  @override
  String get settingsUnlockPremium => 'Débloquez les fonctionnalités premium';

  @override
  String settingsRenews(String date) {
    return 'Renouvellement le $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Passer à Pro';

  @override
  String get settingsRestorePurchases => 'Restaurer les achats';

  @override
  String get settingsPurchaseHistory => 'Historique d\'achats';

  @override
  String get settingsSnakeCosmetics => 'Styles de serpent';

  @override
  String get settingsBattlePass => 'Passe de combat';

  @override
  String settingsTier(int tier) {
    return 'Palier $tier';
  }

  @override
  String get settingsRestoring => 'Restauration des achats...';

  @override
  String get settingsRestored => 'Achats restaurés avec succès !';

  @override
  String get settingsRestoreFailed =>
      'Échec de la restauration des achats. Veuillez réessayer.';

  @override
  String get settingsNoPurchases => 'Aucun achat trouvé';

  @override
  String get settingsUnknown => 'Inconnu';

  @override
  String settingsStatusLine(String status) {
    return 'Statut : $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'Date : $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'Achat n° $number';
  }

  @override
  String get settingsDataParseError => 'Erreur de lecture des données';

  @override
  String get settingsClose => 'Fermer';

  @override
  String get settingsHistoryLoadFailed =>
      'Impossible de charger l\'historique d\'achats';

  @override
  String get settingsUnknownDate => 'Date inconnue';

  @override
  String get mpLobbyNoFriends =>
      'Pas encore d\'amis — ajoutez-en depuis l\'écran Amis !';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Invitez un ami dans le salon $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 Invitation envoyée à $name !';
  }

  @override
  String get mpLobbyInviteFailed =>
      'Impossible d\'envoyer l\'invitation — réessayez';

  @override
  String get mpLobbyOffline =>
      'Vous êtes hors ligne. Le multijoueur nécessite Internet.';

  @override
  String get mpLobbyDismiss => 'FERMER';

  @override
  String get mpLobbyGo => 'GO !';

  @override
  String get mpLobbyGetReady => 'Préparez-vous !';

  @override
  String get mpLobbyTitle => 'MULTIJOUEUR';

  @override
  String get mpLobbySubtitle => 'Jouez en ligne avec des amis';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Salon : $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'Code du salon copié !';

  @override
  String get mpLobbyQuickMatch => 'PARTIE RAPIDE';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      '1v1 Classique — trouvez un adversaire automatiquement';

  @override
  String get mpLobbyFinding => 'RECHERCHE...';

  @override
  String get mpLobbyFindMatch => 'TROUVER UN MATCH';

  @override
  String get mpLobbySeconds => 'sec';

  @override
  String get mpLobbySearching => 'RECHERCHE DE JOUEURS...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs',
      one: '$count joueur',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Position dans la file : $position';
  }

  @override
  String get mpLobbyCancelUpper => 'ANNULER';

  @override
  String get mpLobbyNoPlayersFound => 'AUCUN JOUEUR TROUVÉ';

  @override
  String get mpLobbyNoPlayersBody =>
      'Désolé, aucun adversaire trouvé.\nRéessayez ou créez votre propre salon !';

  @override
  String get mpLobbyGoBack => 'RETOUR';

  @override
  String get mpLobbyTryAgain => 'RÉESSAYER';

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
    return '$count N';
  }

  @override
  String get mpLobbyJoinRoom => 'REJOINDRE UN SALON';

  @override
  String get mpLobbyJoinSubtitle => 'Saisissez le code du salon pour rejoindre';

  @override
  String get mpLobbyEnterRoomCode => 'Saisissez le code du salon';

  @override
  String get mpLobbyCreateRoom => 'CRÉER UN SALON';

  @override
  String get mpLobbyCreateSubtitle => 'Créez un salon 1v1 et invitez un ami';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'JOUEURS ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'VOUS';

  @override
  String get mpLobbyWaitingForPlayer => 'En attente d\'un joueur...';

  @override
  String get mpLobbyStartGame => 'LANCER LA PARTIE';

  @override
  String get mpLobbyWaitingForHost => 'En attente du lancement par l\'hôte...';

  @override
  String get mpLobbyLeave => 'QUITTER';

  @override
  String get mpLobbyReadyDone => 'PRÊT !';

  @override
  String get mpLobbyReady => 'PRÊT';

  @override
  String get mpModeClassicDesc => 'Bataille de serpents traditionnelle';

  @override
  String get mpModeSpeedDesc => 'La vitesse augmente avec le temps';

  @override
  String get mpModeSurvivalDesc => 'Le dernier serpent en vie gagne';

  @override
  String get mpModePowerUpDesc => 'Des power-ups partout !';

  @override
  String get mpStatusWaiting => 'En attente';

  @override
  String get mpStatusReady => 'Prêt';

  @override
  String get mpStatusPlaying => 'En jeu';

  @override
  String get mpStatusCrashed => 'Écrasé';

  @override
  String get mpStatusDisconnected => 'Déconnecté';

  @override
  String get goNoAdAvailable =>
      'Aucune pub disponible pour l\'instant, réessayez bientôt';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Pièces doublées — +$count pièces bonus !';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'Regardez une pub pour doubler vos $count pièces';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins pièces  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return '$count pièces récupérées des défis quotidiens !';
  }

  @override
  String get goRibbonNewHighScore => 'NOUVEAU RECORD !';

  @override
  String get goRibbonTournamentSubmitted => 'SCORE DE TOURNOI ENVOYÉ !';

  @override
  String get goRibbonTournamentFailed =>
      'SCORE NON ENVOYÉ — VÉRIFIEZ LA CONNEXION';

  @override
  String get goRibbonTournamentSubmitting => 'ENVOI DU SCORE DE TOURNOI…';

  @override
  String get goVictory => 'VICTOIRE !';

  @override
  String get goGameOver => 'PARTIE TERMINÉE';

  @override
  String get goFinalScore => 'SCORE FINAL';

  @override
  String get goLevel => 'NIVEAU';

  @override
  String get goBest => 'RECORD';

  @override
  String get goCoinsEarned => 'Pièces gagnées';

  @override
  String get goDailyRewardsReady => 'RÉCOMPENSES QUOTIDIENNES PRÊTES';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count récompenses',
      one: '$count récompense',
    );
    return '$_temp0  •  +$coins pièces  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'TOUT RÉCUPÉRER';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'Récupérer';

  @override
  String get goAchievements => 'SUCCÈS';

  @override
  String get goRecentlyUnlocked => 'Débloqués récemment';

  @override
  String get goInProgress => 'En cours';

  @override
  String get goPlayAgain => 'REJOUER';

  @override
  String get goMenu => 'MENU';

  @override
  String get storeTitle => 'Boutique Snake';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Pièces';

  @override
  String get storeTabThemes => 'Thèmes';

  @override
  String get storeTabSkins => 'Skins';

  @override
  String get storeTabTrails => 'Traînées';

  @override
  String get storeTabPowerUps => 'Power-Ups';

  @override
  String get storeYourCoins => 'Vos Pièces Snake';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'BONUS ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Abonnez-vous avant la fin de votre Pro gratuit';

  @override
  String get storeChooseYourPlan => 'Choisissez votre formule';

  @override
  String get storeWhatYouGet => 'Ce que vous obtenez';

  @override
  String get storeProHeroSubtitle =>
      'Tous les thèmes, skins et traînées premium · grands plateaux · 2× pièces · power-ups premium · entrées de tournoi · Passe de combat Premium';

  @override
  String get storeMonthly => 'Mensuel';

  @override
  String get storeYearly => 'Annuel';

  @override
  String get storePerMonth => '/mois';

  @override
  String get storePerYear => '/an';

  @override
  String get storeSave17 => 'Économisez 17 %';

  @override
  String storePlanDisplayName(Object title) {
    return 'formule $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Vérification…';

  @override
  String get storeSubscribe => 'S\'abonner';

  @override
  String get storeYoureOnFreePro => 'Vous avez le Pro gratuit !';

  @override
  String get storeYourePro => 'Vous êtes Pro !';

  @override
  String get storeFreePro => 'Pro gratuit';

  @override
  String get storeProMonthly => 'Pro Mensuel';

  @override
  String get storeKeepPro => 'Garder le Pro — S\'abonner';

  @override
  String get storePromoBadge => 'PROMO';

  @override
  String get storeEndingSoon => 'Se termine bientôt';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Se termine dans ${days}j ${hours}h';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Se termine dans ${hours}h ${minutes}min';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Se termine dans ${minutes}min';
  }

  @override
  String get storeFeatureExtraLife =>
      'Vie supplémentaire toujours gratuite — revivez à chaque partie, sans pub, sans pièces';

  @override
  String get storeFeatureNoAds => 'Aucune publicité — jouez sans aucune pub';

  @override
  String get storeFeatureThemes => 'Les 6 thèmes premium';

  @override
  String get storeFeatureSkins => 'Les 11 skins premium';

  @override
  String get storeFeatureTrails => 'Les 11 traînées premium';

  @override
  String get storeFeatureBoards => 'Plateaux premium (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => 'Gains de pièces 2×';

  @override
  String get storeFeaturePowerUps => '5× power-ups premium par cycle';

  @override
  String get storeFeatureTournaments =>
      'Entrées de tournoi Bronze + Argent + Or à chaque cycle';

  @override
  String get storeFeatureBattlePass =>
      'Voie Premium du Passe de combat chaque saison';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Achat de $name en cours...';
  }

  @override
  String get storeSubNotAvailable =>
      'Abonnement indisponible. Réessayez plus tard.';

  @override
  String get storePurchaseFailed => 'Achat échoué. Veuillez réessayer.';

  @override
  String get storeBuyCoins => 'Acheter des Pièces Snake';

  @override
  String get storeEarnFreeCoins => 'Gagner des pièces gratuites';

  @override
  String get storeEarnPlay => 'Jouer une partie';

  @override
  String get storeEarnPlayReward => '5 pièces par partie';

  @override
  String get storeEarnDaily => 'Connexion quotidienne';

  @override
  String get storeEarnDailyReward => '10-50 pièces par jour';

  @override
  String get storeEarnAchievements => 'Succès';

  @override
  String get storeEarnAchievementsReward => '25-100 pièces';

  @override
  String get storeEarnTournaments => 'Tournois';

  @override
  String get storeEarnTournamentsReward => '100+ pièces';

  @override
  String get storePopularBadge => 'POPULAIRE';

  @override
  String storeBuyItem(Object name) {
    return 'Acheter $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'Acheter $coins pour $price ?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'Acheter - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'Achat de $name en cours...';
  }

  @override
  String get storeProductNotAvailable =>
      'Produit indisponible. Réessayez plus tard.';

  @override
  String get storeUnlockedWithPro => 'Débloqué avec Pro';

  @override
  String get storeIncludedWithPro => 'Inclus avec Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned =>
      'Tous les thèmes ici sont à vous avec votre abonnement.';

  @override
  String get storeProBannerThemesUpsell =>
      'Abonnez-vous à Pro pour débloquer tous les thèmes — aucun achat séparé.';

  @override
  String get storeProBannerSkinsOwned =>
      'Toutes les skins ici sont à vous avec votre abonnement.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Abonnez-vous à Pro pour débloquer toutes les skins — aucun achat séparé.';

  @override
  String get storeProBannerTrailsOwned =>
      'Toutes les traînées ici sont à vous avec votre abonnement.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Abonnez-vous à Pro pour débloquer toutes les traînées — aucun achat séparé.';

  @override
  String get storePremiumThemes => 'Thèmes premium';

  @override
  String get storeFreeThemes => 'Thèmes gratuits';

  @override
  String get storeFreeThemesSubtitle =>
      'Toujours disponibles — revenez-y quand vous voulez.';

  @override
  String get storeAllThemesBundle => 'Pack Tous les Thèmes';

  @override
  String get storeAllThemesBundleSubtitle =>
      'Les 6 thèmes premium · économisez 33 %';

  @override
  String get storePillVerifying => 'VÉRIFICATION';

  @override
  String get storePillOwned => 'ACQUIS';

  @override
  String get storePillFree => 'GRATUIT';

  @override
  String get storePillActive => 'ACTIF';

  @override
  String get storePillApply => 'APPLIQUER';

  @override
  String get storePillEquipped => 'ÉQUIPÉ';

  @override
  String get storePillEquip => 'ÉQUIPER';

  @override
  String get storeThemeDescClassic => 'Le look d\'origine';

  @override
  String get storeThemeDescModern => 'Épuré et minimaliste';

  @override
  String get storeThemeDescNeon => 'Nuits de néon lumineuses';

  @override
  String get storeThemeDescRetro => 'Arcade néon années 80';

  @override
  String get storeThemeDescSpace => 'Champ d\'étoiles cosmique';

  @override
  String get storeThemeDescOcean => 'Bleus des profondeurs';

  @override
  String get storeThemeDescCyberpunk => 'Cyan électrique et rose';

  @override
  String get storeThemeDescForest => 'Jungle émeraude éclatante';

  @override
  String get storeThemeDescDesert => 'Canyon et cactus turquoise';

  @override
  String get storeThemeDescCrystal => 'Bleu cristallin glacé';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'Débloquer $name pour $price ?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Vérification de l\'achat de $name…';
  }

  @override
  String get storeThemeNotAvailable =>
      'Thème indisponible. Réessayez plus tard.';

  @override
  String get storeItemNotAvailable =>
      'Article indisponible. Réessayez plus tard.';

  @override
  String storeEquippedToast(Object name) {
    return '$name équipé';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 Boost de Vitesse gratuit ajouté à votre inventaire !';

  @override
  String get storeWatchAdTitle => 'Regarder une pub — Boost de Vitesse gratuit';

  @override
  String get storeWatchAdReady =>
      'Ajoute 1 Boost de Vitesse à votre équipement';

  @override
  String get storeWatchAdNotReady => 'Aucune pub disponible pour l\'instant';

  @override
  String get puSpeedBoostDesc =>
      'Augmente la vitesse du serpent pendant 7 secondes.';

  @override
  String get puInvincibilityDesc =>
      'Traversez les murs et vous-même pendant 6 secondes.';

  @override
  String get puScoreMultiplierDesc => 'Points doublés pendant 10 secondes.';

  @override
  String get puSlowMotionDesc =>
      'Ralentit le jeu pour plus de précision (8 secondes).';

  @override
  String get storePowerUpsInfo =>
      'Achetez avec des pièces, puis armez-en un depuis la puce d\'équipement de l\'accueil — il s\'active 5 s après le début de votre prochaine partie.';

  @override
  String get storePowerUps => 'Power-Ups';

  @override
  String get storePowerUpBundles => 'Packs de power-ups';

  @override
  String get storeBundlesSubtitle =>
      'Débloquez plusieurs types de power-ups à prix réduit.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'Pièces insuffisantes !';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'Acheter 1 $name pour $cost pièces ?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Acheter - $cost pièces';
  }

  @override
  String get storePurchaseFailedRetry => 'Achat échoué. Réessayez.';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name ajouté à votre équipement !';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count pièces';
  }

  @override
  String get storeBuyUpper => 'ACHETER';

  @override
  String get storeNeedCoins => 'PIÈCES REQUISES';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name débloqué !';
  }
}
