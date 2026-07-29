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

  @override
  String get modeClassic => 'Classique';

  @override
  String get modeZen => 'Mode Zen';

  @override
  String get modeSpeedChallenge => 'Défi de Vitesse';

  @override
  String get modeMultiFood => 'Multi-nourriture';

  @override
  String get modeSurvival => 'Survie';

  @override
  String get modeTimeAttack => 'Contre-la-montre';

  @override
  String get modePowerUpMadness => 'Folie Power-Ups';

  @override
  String get modePerfectGame => 'Partie Parfaite';

  @override
  String get modeClassicDesc => 'Le jeu du serpent classique avec des murs';

  @override
  String get modeZenDesc => 'Pas de murs - le serpent traverse l\'écran';

  @override
  String get modeSpeedChallengeDesc =>
      'La vitesse augmente rapidement pour un défi maximal';

  @override
  String get modeMultiFoodDesc =>
      'Plusieurs nourritures apparaissent à la fois';

  @override
  String get modeSurvivalDesc =>
      'Survivez le plus longtemps possible avec des vies limitées';

  @override
  String get modeTimeAttackDesc =>
      'Marquez un maximum de points en temps limité';

  @override
  String get modePowerUpMadnessDesc =>
      'Les power-ups apparaissent bien plus souvent — embrassez le chaos';

  @override
  String get modePerfectGameDesc =>
      'Ne croisez jamais votre propre trace. Un pas sur une case visitée termine la partie.';

  @override
  String get diffEasy => 'Facile';

  @override
  String get diffNormal => 'Normal';

  @override
  String get diffHard => 'Difficile';

  @override
  String get diffEasyDesc =>
      'Un serpent plus lent au départ. Les scores restent hors des classements.';

  @override
  String get diffNormalDesc => 'Le rythme original de Snake Classic.';

  @override
  String get diffHardDesc => 'Commence vite et ne fait qu\'accélérer.';

  @override
  String get themeClassic => 'Classique';

  @override
  String get themeModern => 'Moderne';

  @override
  String get themeNeon => 'Néon';

  @override
  String get themeRetro => 'Rétro';

  @override
  String get themeSpace => 'Espace';

  @override
  String get themeOcean => 'Océan';

  @override
  String get themeCyberpunk => 'Cyberpunk';

  @override
  String get themeForest => 'Forêt';

  @override
  String get themeDesert => 'Désert';

  @override
  String get themeCrystal => 'Cristal';

  @override
  String get dpadLeft => 'Gauche';

  @override
  String get dpadCenter => 'Centre';

  @override
  String get dpadRight => 'Droite';

  @override
  String get mpModeClassicBattle => 'Bataille Classique';

  @override
  String get mpModeSpeedRun => 'Course de Vitesse';

  @override
  String get mpModeSurvivalMode => 'Mode Survie';

  @override
  String get mpModePowerUpMadnessName => 'Folie Power-Ups';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonViewAll => 'Tout voir';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get pfTitle => 'Profil';

  @override
  String get pfSigningOut => 'Déconnexion...';

  @override
  String get pfGuestPlayer => 'Joueur invité';

  @override
  String get pfVerifiedAccount => 'Compte vérifié';

  @override
  String get pfStatistics => 'Statistiques';

  @override
  String get pfReplays => 'Replays';

  @override
  String get pfAchievements => 'Succès';

  @override
  String get pfLoadingStats => 'Chargement des stats...';

  @override
  String get pfHighScore => 'Meilleur score';

  @override
  String get pfGamesPlayed => 'Parties jouées';

  @override
  String get pfPlayTime => 'Temps de jeu';

  @override
  String get pfAverageScore => 'Score moyen';

  @override
  String get pfFoodConsumed => 'Nourriture consommée';

  @override
  String get pfPowerUps => 'Power-ups';

  @override
  String get pfUpgradeTitle => 'Passer à un compte Google';

  @override
  String get pfUpgradeSubtitle =>
      'Sauvegardez votre progression et synchronisez entre appareils';

  @override
  String get pfBenefitSync => 'Synchroniser la progression';

  @override
  String get pfBenefitSyncSub => 'entre appareils';

  @override
  String get pfBenefitLeaderboards => 'Classements mondiaux';

  @override
  String get pfBenefitLeaderboardsSub => 'affrontez le monde entier';

  @override
  String get pfBenefitSocial => 'Amis et social';

  @override
  String get pfBenefitSocialSub => 'connectez-vous aux autres';

  @override
  String get pfSignInGoogle => 'Se connecter avec Google';

  @override
  String get pfSignInApple => 'Se connecter avec Apple';

  @override
  String get pfNoReplays =>
      'Aucun replay pour l\'instant. Jouez quelques parties !';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replays enregistrés',
      one: '$count replay enregistré',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Gestion du compte';

  @override
  String get pfSignOut => 'Se déconnecter';

  @override
  String get pfDeleteAccount => 'Supprimer le compte';

  @override
  String get pfAppleUpgradeSuccess =>
      'Compte migré vers Apple avec succès ! 🎉';

  @override
  String get pfAppleIdInUse =>
      'Cet identifiant Apple a déjà un compte. Déconnectez-vous puis connectez-vous avec Apple.';

  @override
  String get pfUpgradeFailed =>
      'Échec de la migration du compte. Veuillez réessayer.';

  @override
  String get pfUpgradeError =>
      'Une erreur est survenue pendant la migration du compte.';

  @override
  String get pfGoogleUpgradeSuccess =>
      'Compte migré vers Google avec succès ! 🎉';

  @override
  String get pfDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'Ceci supprime définitivement votre compte et tout ce qui y est rattaché :\n\n• Meilleurs scores et statistiques\n• Pièces et articles achetés\n• Thèmes, skins, traînées et power-ups\n• Progression du passe de combat et des défis\n• Entrées de classement et amis\n\nCette action est irréversible. Les abonnements actifs doivent être annulés séparément dans les réglages de $storeName.';
  }

  @override
  String get pfAppStore => 'l\'App Store';

  @override
  String get pfDeviceAppStore => 'la boutique d\'applications de l\'appareil';

  @override
  String get pfAccountDeleted => 'Votre compte a été définitivement supprimé.';

  @override
  String get pfDeleteFailed =>
      'Impossible de supprimer votre compte. Vérifiez votre connexion et réessayez.';

  @override
  String get pfDeleteForever => 'Supprimer définitivement';

  @override
  String get pfSignOutBody =>
      'Voulez-vous vraiment vous déconnecter ?\n\nVotre progression sera conservée si vous êtes connecté avec Google.';

  @override
  String get pfSignedOut => 'Déconnexion réussie 👋';

  @override
  String get stLoading => 'Chargement des statistiques...';

  @override
  String get stPerformanceOverview => 'Aperçu des performances';

  @override
  String get stTotalGames => 'Parties totales';

  @override
  String get stWinStreak => 'Série de victoires';

  @override
  String get stGameActivity => 'Activité de jeu';

  @override
  String get stLongestGame => 'Partie la plus longue';

  @override
  String get stHighestLevel => 'Niveau le plus haut';

  @override
  String get stPerfectGames => 'Parties parfaites';

  @override
  String get stFoodPowerUps => 'Nourriture et power-ups';

  @override
  String get stPowerUpsUsed => 'Power-ups utilisés';

  @override
  String get stFavoriteFood => 'Nourriture favorite';

  @override
  String get stFavoritePowerUp => 'Power-up favori';

  @override
  String get stPerformanceTrends => 'Tendances de performance';

  @override
  String get stOverallTrend => 'Tendance générale';

  @override
  String get stRecentAverage => 'Moyenne récente';

  @override
  String get stBestRecent => 'Meilleur récent';

  @override
  String get stConsistency => 'Régularité';

  @override
  String get stScores => 'Scores';

  @override
  String get stTrendLine => 'Ligne de tendance';

  @override
  String get stPlayPatterns => 'Habitudes de jeu (7 derniers jours)';

  @override
  String get stWeeklyTime => 'Temps hebdomadaire';

  @override
  String get stMostActiveDay => 'Jour le plus actif';

  @override
  String get stDailyActivity => 'Activité quotidienne';

  @override
  String get stAchievementProgress => 'Progression des succès';

  @override
  String get stViewAllAchievements => 'Voir tous les succès →';

  @override
  String get stViewAchievements => 'VOIR LES SUCCÈS';

  @override
  String get stReplaysUpper => 'REPLAYS';

  @override
  String get stResetStatistics => 'RÉINITIALISER LES STATS';

  @override
  String get stResetTitle => 'Réinitialiser les statistiques ?';

  @override
  String get stResetBody =>
      'Ceci supprimera définitivement toutes vos statistiques de jeu. Cette action est irréversible.';

  @override
  String get stReset => 'Réinitialiser';

  @override
  String get stNA => 'N/A';

  @override
  String get stExcellent => 'Excellent';

  @override
  String get stGood => 'Bon';

  @override
  String get stFair => 'Correct';

  @override
  String get stPoor => 'Faible';

  @override
  String get stNoData => 'Aucune donnée';

  @override
  String get stNone => 'Aucun';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dernières parties',
      one: 'dernière partie',
    );
    return 'Progression ($_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent terminé';
  }

  @override
  String get stInsights => 'Analyses de performance';

  @override
  String get stInsightPlayMore =>
      'Jouez plus de parties pour obtenir des analyses de performance !';

  @override
  String get stInsightImproving => 'Bravo ! Vos performances sont en hausse.';

  @override
  String get stInsightAboveAverage =>
      'Vos parties récentes sont bien au-dessus de votre moyenne.';

  @override
  String get stInsightDeclined =>
      'Vos performances ont baissé récemment. Pensez à vous entraîner davantage.';

  @override
  String get stInsightPractice =>
      'Concentrez-vous sur l\'évitement des collisions et l\'anticipation de vos mouvements.';

  @override
  String get stInsightStable =>
      'Vos performances sont stables. Mettez-vous au défi de progresser !';

  @override
  String get stInsightPotential =>
      'Vous avez un potentiel de gros scores - travaillez la régularité.';

  @override
  String get stInsightSolid =>
      'Vous maintenez de solides performances sur vos parties récentes.';

  @override
  String get frTitle => 'Amis';

  @override
  String get frBlockedUsers => 'Utilisateurs bloqués';

  @override
  String get frSearchHint => 'Rechercher par nom ou e-mail...';

  @override
  String get frSearching => 'Recherche...';

  @override
  String get frSearchTitle => 'Rechercher des amis';

  @override
  String get frSearchSubtitle =>
      'Saisissez un nom ou un e-mail pour trouver des amis';

  @override
  String get frNoUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get frNoUsersFoundSub => 'Essayez avec un autre nom ou e-mail';

  @override
  String get frRequests => 'Demandes';

  @override
  String get frSearch => 'Recherche';

  @override
  String get frNoCacheYet => 'Pas encore de cache';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Mis à jour $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · échec de l\'actualisation, touchez pour réessayer';
  }

  @override
  String get frJustNow => 'à l\'instant';

  @override
  String frSecondsAgo(Object count) {
    return 'il y a ${count}s';
  }

  @override
  String frMinutesAgo(Object count) {
    return 'il y a ${count}min';
  }

  @override
  String frHoursAgo(Object count) {
    return 'il y a ${count}h';
  }

  @override
  String frDaysAgo(Object count) {
    return 'il y a ${count}j';
  }

  @override
  String get frLoadingFriends => 'Chargement des amis...';

  @override
  String get frNoFriendsYet => 'Pas encore d\'amis';

  @override
  String get frNoFriendsSub => 'Recherchez des joueurs à ajouter en amis !';

  @override
  String get frNoRequests => 'Aucune demande d\'ami';

  @override
  String get frNoRequestsSub => 'Les demandes d\'ami apparaîtront ici';

  @override
  String get frChallengeMenu => 'Défier en match';

  @override
  String get frViewProfile => 'Voir le profil';

  @override
  String get frRemoveFriend => 'Retirer l\'ami';

  @override
  String get frBlockUser => 'Bloquer l\'utilisateur';

  @override
  String frReceivedHeader(Object count) {
    return 'Reçues ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Envoyées ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '$count partie',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'Envoyée $date';
  }

  @override
  String get frPending => 'En attente';

  @override
  String get frCancelRequest => 'Annuler la demande';

  @override
  String get frReject => 'Refuser';

  @override
  String get frAccept => 'Accepter';

  @override
  String get frAlreadyFriends => '✓ Amis';

  @override
  String get frAddFriend => 'Ajouter';

  @override
  String get frSendRequestFailed =>
      'Impossible d\'envoyer la demande — vérifiez votre connexion et réessayez';

  @override
  String get frAcceptFailed =>
      'Impossible d\'accepter la demande — vérifiez votre connexion et réessayez';

  @override
  String get frRejectFailed =>
      'Impossible de refuser la demande — vérifiez votre connexion et réessayez';

  @override
  String get frCancelFailed =>
      'Impossible d\'annuler la demande — vérifiez votre connexion et réessayez';

  @override
  String get frBlockFailed =>
      'Impossible de bloquer cet utilisateur — vérifiez votre connexion et réessayez';

  @override
  String get frSignInSocial =>
      'Connectez-vous pour ajouter des amis et utiliser les fonctions sociales';

  @override
  String get frRequestSent => 'Demande d\'ami envoyée !';

  @override
  String get frRequestAccepted => 'Demande d\'ami acceptée !';

  @override
  String get frRequestRejected => 'Demande d\'ami refusée';

  @override
  String get frRequestCancelled => 'Demande d\'ami annulée';

  @override
  String frChallengeSent(Object name) {
    return '🎮 Défi envoyé à $name !';
  }

  @override
  String get frChallengeFailed => 'Impossible d\'envoyer le défi — réessayez';

  @override
  String frBlocked(Object name) {
    return '$name bloqué';
  }

  @override
  String frUnblocked(Object name) {
    return '$name débloqué';
  }

  @override
  String get frUnblockFailed => 'Impossible de débloquer — réessayez';

  @override
  String frRemoved(Object name) {
    return '$name retiré de vos amis';
  }

  @override
  String frBlockTitle(Object name) {
    return 'Bloquer $name ?';
  }

  @override
  String get frBlockBody =>
      'Cette personne sera retirée de vos amis et ne pourra plus vous envoyer de demandes d\'ami ni de défis. Elle ne sera pas notifiée.';

  @override
  String get frBlock => 'Bloquer';

  @override
  String get frNoBlocked => 'Vous n\'avez bloqué personne.';

  @override
  String get frUnblock => 'Débloquer';

  @override
  String frHighScoreLine(Object score) {
    return 'Meilleur score : $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Parties totales : $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Niveau : $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Statut : « $status »';
  }

  @override
  String frRemoveBody(Object name) {
    return 'Retirer $name de votre liste d\'amis ?';
  }

  @override
  String get frRemove => 'Retirer';

  @override
  String get frLeaderboardTitle => 'Classement entre amis';

  @override
  String get frLeaderboardSubtitle => 'Affrontez vos amis';

  @override
  String get frLoadingLeaderboard => 'Chargement du classement...';

  @override
  String frRankBadge(Object rank) {
    return 'n° $rank';
  }

  @override
  String get frYou => 'VOUS';

  @override
  String get frLeaderboardEmptySub =>
      'Ajoutez des amis pour voir votre classement privé !';

  @override
  String get frAddFriends => 'Ajouter des amis';

  @override
  String get tnTitle => 'Tournois';

  @override
  String get tnActive => 'Actifs';

  @override
  String get tnHistory => 'Historique';

  @override
  String get tnMyStats => 'Mes stats';

  @override
  String get tnLoading => 'Chargement des tournois...';

  @override
  String get tnNoActive => 'Aucun tournoi actif';

  @override
  String get tnNoActiveSub => 'Revenez plus tard pour de nouveaux tournois !';

  @override
  String get tnNoHistory => 'Aucun historique de tournoi';

  @override
  String get tnNoHistorySub =>
      'Participez à des tournois pour voir votre historique !';

  @override
  String get tnNoStats => 'Aucune statistique de tournoi';

  @override
  String get tnNoStatsSub =>
      'Rejoignez des tournois pour suivre votre progression !';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max joueurs';
  }

  @override
  String get tnJoined => 'Inscrit';

  @override
  String tnBestScoreChip(Object score) {
    return 'Meilleur : $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Place n° $rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count récompenses disponibles',
      one: '$count récompense disponible',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'Voir les détails →';

  @override
  String get tnOverviewCard => 'Aperçu des tournois';

  @override
  String get tnWins => 'Victoires';

  @override
  String get tnTopThree => 'Top 3';

  @override
  String get tnBestScore => 'Meilleur score';

  @override
  String get tnDetailedStats => 'Statistiques détaillées';

  @override
  String get tnTotalAttempts => 'Tentatives totales';

  @override
  String get tnWinRate => 'Taux de victoire';

  @override
  String tnPercentValue(Object value) {
    return '$value %';
  }

  @override
  String get tnAvgPerformance => 'Performance moyenne';

  @override
  String tnTopPercent(Object percent) {
    return 'Top $percent %';
  }

  @override
  String get tnNotFound => 'Tournoi introuvable';

  @override
  String get tnLoadFailed => 'Échec du chargement du tournoi';

  @override
  String get tnLoadingTournament => 'Chargement du tournoi...';

  @override
  String get tnGoBack => 'Retour';

  @override
  String get tnParticipating => 'Vous participez !';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Meilleur : $score • Tentatives : $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Place n° $rank';
  }

  @override
  String get tnOverview => 'Aperçu';

  @override
  String get tnLeaderboard => 'Classement';

  @override
  String get tnRules => 'Règles';

  @override
  String get tnLeaderboardFailed => 'Impossible de charger le classement';

  @override
  String get tnCheckConnection => 'Vérifiez votre connexion et réessayez.';

  @override
  String get tnNoParticipants => 'Pas encore de participants';

  @override
  String get tnBeFirst => 'Soyez le premier à participer !';

  @override
  String get tnDescription => 'Description';

  @override
  String get tnRewards => 'Récompenses';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentatives',
      one: '$count tentative',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Règles du tournoi';

  @override
  String get tnScoringSystem => 'Système de points';

  @override
  String get tnScoringBody =>
      'Votre meilleur score pendant la période du tournoi comptera pour le classement final. Vous pouvez jouer plusieurs fois pour l\'améliorer.';

  @override
  String get tnJoining => 'INSCRIPTION…';

  @override
  String get tnJoin => 'REJOINDRE LE TOURNOI';

  @override
  String get tnPlayNow => 'JOUER MAINTENANT';

  @override
  String get tnProUnlimited => 'Pro · Entrées illimitées';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Entrées restantes : $count';
  }

  @override
  String get tnNoEntries => 'Aucune entrée — touchez REJOINDRE pour acheter';

  @override
  String tnStarts(Object time) {
    return 'Commence $time';
  }

  @override
  String get tnRule1 =>
      'Jouez pendant la période du tournoi pour que vos scores comptent';

  @override
  String get tnRule2 =>
      'Vous pouvez jouer plusieurs fois - seul votre meilleur score compte';

  @override
  String get tnRule3 => 'Connexion requise pour participer';

  @override
  String get tnRule4 => 'Le classement final est déterminé à la fin du tournoi';

  @override
  String get tnRuleSpeed =>
      'La vitesse du jeu augmente rapidement tous les 10 points';

  @override
  String get tnRuleSurvival =>
      'Le score se base sur le temps de survie, pas la nourriture';

  @override
  String get tnRuleNoWalls =>
      'Le serpent traverse les bords de l\'écran au lieu de heurter les murs';

  @override
  String get tnRulePowerUps =>
      'Les power-ups apparaissent toutes les 5 secondes';

  @override
  String get tnRulePerfect =>
      'Toute collision met immédiatement fin à la partie';

  @override
  String get tnRuleClassic => 'Les règles classiques du serpent s\'appliquent';

  @override
  String get tnJoinSuccess => 'Inscription au tournoi réussie !';

  @override
  String get tnJoinFailed => 'Échec de l\'inscription au tournoi';

  @override
  String get tnJoinError => 'Erreur lors de l\'inscription au tournoi';

  @override
  String get tnTierBronze => 'Bronze';

  @override
  String get tnTierSilver => 'Argent';

  @override
  String get tnTierGold => 'Or';

  @override
  String get tnEntryRequired => 'Entrée requise';

  @override
  String tnEntryNeeded(Object tier) {
    return 'Il vous faut une entrée $tier pour rejoindre ce tournoi.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Entrées $tier actuelles : $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Les abonnés Pro ont un accès illimité aux tournois.';

  @override
  String get tnFreeBronzeAdded => '🎉 Entrée Bronze gratuite ajoutée !';

  @override
  String get tnFreeEntryAd => 'Entrée gratuite (pub)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Acheter une entrée $tier - $price';
  }

  @override
  String get acAll => 'Tous';

  @override
  String get acUnlocked => 'Débloqués';

  @override
  String get acLocked => 'Verrouillés';

  @override
  String get acTotalUpper => 'TOTAL';

  @override
  String get acUnlockedUpper => 'DÉBLOQUÉS';

  @override
  String get acClaimedUpper => 'RÉCUPÉRÉS';

  @override
  String get acPendingUpper => 'EN ATTENTE';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% terminé';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% des débloqués';
  }

  @override
  String get acEmpty => 'Aucun succès ici';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Débloqué $date';
  }

  @override
  String get rpTitle => 'Replays de parties';

  @override
  String get rpRecent => 'Récents';

  @override
  String get rpBest => 'Meilleurs';

  @override
  String get rpCrashes => 'Crashs';

  @override
  String get rpLoading => 'Chargement des replays...';

  @override
  String get rpNoRecent => 'Aucun replay récent';

  @override
  String get rpNoBest => 'Aucun replay de record';

  @override
  String get rpNoCrashes => 'Aucun replay de crash';

  @override
  String get rpEmptySub => 'Jouez quelques parties pour générer des replays !';

  @override
  String get rpScore => 'Score';

  @override
  String get rpDuration => 'Durée';

  @override
  String get rpFood => 'Nourriture';

  @override
  String get rpFrames => 'Images';

  @override
  String get rpMaxLength => 'Longueur max';

  @override
  String get rpWatch => 'Regarder';

  @override
  String get rpYesterday => 'Hier';

  @override
  String get rpDeleteTitle => 'Supprimer le replay';

  @override
  String rpDeleteBody(Object date) {
    return 'Supprimer le replay du $date ?';
  }

  @override
  String get rpDelete => 'Supprimer';

  @override
  String get rpDeleted => 'Replay supprimé';

  @override
  String get rpDeleteFailed => 'Impossible de supprimer le replay';

  @override
  String get lbTitle => 'Classements';

  @override
  String get lbGlobal => 'Mondial';

  @override
  String get lbWeekly => 'Hebdo';

  @override
  String get lbWeeklySub =>
      'Classé selon votre meilleur score de la semaine (remise à zéro le dimanche)';

  @override
  String get lbGlobalSub =>
      'Classé selon votre meilleur score de tous les temps';

  @override
  String lbScoreLine(Object score) {
    return 'Score : $score';
  }

  @override
  String get lbLoadingGlobal => 'Chargement du classement mondial...';

  @override
  String get lbLoadingWeekly => 'Chargement du classement hebdo...';

  @override
  String get lbNoScores => 'Pas encore de scores';

  @override
  String get lbBeFirst => 'Soyez le premier à établir un record !';

  @override
  String get lbNoWeekly => 'Aucun score cette semaine';

  @override
  String get lbPlayThisWeek => 'Jouez cette semaine pour apparaître ici !';

  @override
  String get lbAnonymous => 'Anonyme';

  @override
  String get lbGuestBadge => 'INVITÉ';

  @override
  String get lbPts => 'pts';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties jouées',
      one: '$count partie jouée',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '$name récupéré !';
  }

  @override
  String get bpTitle => 'Passe de combat';

  @override
  String get bpTitleUpper => 'PASSE DE COMBAT';

  @override
  String get bpLoading => 'Chargement du passe de combat...';

  @override
  String get bpWatchAdXp => 'Voir une pub — +50 XP de passe';

  @override
  String get bpXpEarned => '+50 XP de passe de combat !';

  @override
  String get bpSeasonEnded => 'Saison terminée';

  @override
  String bpHoursLeft(Object hours) {
    return '${hours}h restantes';
  }

  @override
  String bpDaysLeft(Object days) {
    return '${days}j restants';
  }

  @override
  String get bpTierUpper => 'PALIER';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'Saison terminée';

  @override
  String get bpSeasonCompleteUpper => 'SAISON TERMINÉE';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next XP pour le palier $tier';
  }

  @override
  String get bpPremiumBadge => 'PREMIUM';

  @override
  String get bpUnlockedEverything =>
      'Vous avez débloqué tous les paliers de cette saison.';

  @override
  String get bpComingNext => 'À VENIR';

  @override
  String bpTierN(Object tier) {
    return 'Palier $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'à $count paliers',
      one: 'à $count palier',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'DÉBLOQUER AVEC PRO';

  @override
  String get bpAvailableNow => 'DISPONIBLE MAINTENANT';

  @override
  String bpTierAbbrev(Object tier) {
    return 'P$tier';
  }

  @override
  String get bpClaim => 'RÉCUPÉRER';

  @override
  String get bpPremiumWaiting => 'Des récompenses premium vous attendent';

  @override
  String get bpSubscribeToClaim => 'Abonnez-vous à Pro pour les récupérer.';

  @override
  String get bpHideTiers => 'Masquer les paliers';

  @override
  String bpViewAllTiers(Object count) {
    return 'Voir les $count paliers';
  }

  @override
  String get bpCollapse => 'RÉDUIRE';

  @override
  String get bpExpand => 'DÉVELOPPER';

  @override
  String get bpNow => 'ACTUEL';

  @override
  String bpTierUpperN(Object tier) {
    return 'PALIER $tier';
  }

  @override
  String get bpUnlocked => 'Débloqué';

  @override
  String bpReachTier(Object tier) {
    return 'Atteignez le palier $tier pour débloquer';
  }

  @override
  String get bpBetweenSeasons => 'Entre deux saisons';

  @override
  String get bpNoSeasonBody =>
      'Aucun passe de combat en cours — la prochaine saison démarrera automatiquement. Revenez bientôt.';

  @override
  String get bpCheckNewSeason => 'Vérifier la nouvelle saison';

  @override
  String get pbActive => 'Premium actif !';

  @override
  String get pbActiveSub =>
      'Vous avez accès à toutes les fonctionnalités premium';

  @override
  String get pbHeaderSub => 'Débloquez tout ce que le jeu peut offrir';

  @override
  String get pbMonthlyPlan => 'Formule mensuelle';

  @override
  String get pbYearlyPlan => 'Formule annuelle';

  @override
  String get pbSave33 => 'Économisez 33 %';

  @override
  String get pbMostPopular => 'LE PLUS POPULAIRE';

  @override
  String get pbFeatExtraLife => 'Vie supplémentaire toujours gratuite';

  @override
  String get pbFeatExtraLifeDesc =>
      'Crashez et continuez — les membres Pro reviennent instantanément gratuitement, sans pub ni pièces, une fois par partie';

  @override
  String get pbFeatNoAds => 'Supprimez toutes les pubs';

  @override
  String get pbFeatNoAdsDesc =>
      'Ni bannières ni interstitiels — jouez sans aucune pub, pour toujours';

  @override
  String get pbFeatThemes => 'Tous les thèmes premium';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'Toutes les skins premium';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice et 5 autres';

  @override
  String get pbFeatTrails => 'Toutes les traînées premium';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal et 5 autres';

  @override
  String get pbFeatBoards => 'Grands plateaux';

  @override
  String get pbFeatBoardsDesc => 'Jouez sur des plateaux 35x35, 40x40 et 50x50';

  @override
  String get pbFeatCoins => 'Récompenses de pièces 2x';

  @override
  String get pbFeatCoinsDesc =>
      'Deux fois plus de Pièces Snake à chaque partie';

  @override
  String get pbFeatLucky => 'Chanceux — plus de nourritures spéciales';

  @override
  String get pbFeatLuckyDesc =>
      '+50 % de chances de voir apparaître la rare nourriture spéciale à 50 points';

  @override
  String get pbFeatPowerUps => 'Plus de power-ups en jeu';

  @override
  String get pbFeatPowerUpsDesc =>
      '+30 % de taux d\'apparition des power-ups sur le plateau';

  @override
  String get pbFeatBundle => 'Pack de power-ups premium';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield et Mega Invincibility par cycle de facturation';

  @override
  String get pbFeatTournament => 'Entrées de tournoi';

  @override
  String get pbFeatTournamentDesc =>
      '1× Bronze + 1× Argent + 1× Or par cycle de facturation';

  @override
  String get pbIncludes => 'Premium inclut :';

  @override
  String get pbProPerk => 'AVANTAGE PRO';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'S\'abonner — $price$period';
  }

  @override
  String get pbReassurance =>
      'Sans engagement • Annulez à tout moment • Paiement sécurisé';

  @override
  String get pbNotAvailable => 'Abonnement premium indisponible';

  @override
  String get eaTitleLink => 'Sauvegardez votre progression';

  @override
  String get eaTitleSignIn => 'Connexion par e-mail';

  @override
  String get eaExplainer =>
      'Ajoutez un e-mail et un mot de passe à votre compte pour acheter des articles, restaurer après réinstallation et vous connecter depuis n\'importe quel appareil.';

  @override
  String get eaLinkExisting => 'Lier un compte';

  @override
  String get eaSignIn => 'Se connecter';

  @override
  String get eaCreateAccount => 'Créer un compte';

  @override
  String get eaForgotPassword => 'Mot de passe oublié ?';

  @override
  String get eaLinkToExisting => 'Lier au compte existant';

  @override
  String get eaMinChars => 'Au moins 8 caractères';

  @override
  String eaMinCharsN(Object count) {
    return 'Au moins $count caractères';
  }

  @override
  String get eaCreateAndLink => 'Créer et lier le compte';

  @override
  String get eaEmail => 'E-mail';

  @override
  String get eaEmailRequired => 'L\'e-mail est requis';

  @override
  String get eaEmailInvalid => 'Saisissez un e-mail valide';

  @override
  String get eaPassword => 'Mot de passe';

  @override
  String get eaPasswordRequired => 'Le mot de passe est requis';

  @override
  String get eaForgotFirst =>
      'Saisissez d\'abord votre e-mail ci-dessus, puis touchez Mot de passe oublié.';

  @override
  String eaResetSent(Object email) {
    return 'E-mail de réinitialisation envoyé à $email.';
  }

  @override
  String get eaErrInvalidEmail => 'Cette adresse e-mail n\'est pas valide.';

  @override
  String get eaErrDisabled => 'Ce compte a été désactivé.';

  @override
  String get eaErrNoAccount => 'Aucun compte trouvé avec cet e-mail.';

  @override
  String get eaErrWrongCreds => 'E-mail ou mot de passe incorrect.';

  @override
  String get eaErrEmailInUse =>
      'Un compte existe déjà avec cet e-mail. Essayez de vous connecter.';

  @override
  String get eaErrWeakPassword =>
      'Mot de passe trop faible. Utilisez au moins 8 caractères.';

  @override
  String get eaErrNotEnabled =>
      'La connexion e-mail/mot de passe n\'est pas activée. Contactez le support.';

  @override
  String get eaErrTooMany =>
      'Trop de tentatives. Attendez quelques minutes puis réessayez.';

  @override
  String get eaErrNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get eaErrAlreadyLinked =>
      'Ce compte est déjà lié à un e-mail/mot de passe.';

  @override
  String get eaErrRecentLogin =>
      'Par sécurité, reconnectez-vous avant de lier.';

  @override
  String get eaErrGeneric => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get faWelcome => 'Bienvenue dans\nSnake Classic !';

  @override
  String get faChooseHow => 'Choisissez comment vous voulez jouer :';

  @override
  String get faSigningIn => 'Connexion en cours...';

  @override
  String get faSignInEmail => 'Se connecter par e-mail';

  @override
  String get faContinueGuest => 'Continuer en invité';

  @override
  String get faGuestNote =>
      'Les invités peuvent jouer et sauvegarder localement, mais pas acheter. Connectez-vous avec Apple, Google ou e-mail quand vous voudrez vous abonner ou acheter.';

  @override
  String get faPrivacyTerms => 'Confidentialité et conditions';

  @override
  String get faReviewNote =>
      'Veuillez consulter notre politique de confidentialité et nos conditions d\'utilisation avant de continuer';

  @override
  String get faAgreeCheckbox =>
      'J\'ai lu et j\'accepte la politique de confidentialité et les conditions d\'utilisation';

  @override
  String get faContinueToSignIn => 'Continuer vers la connexion';

  @override
  String get faHeadsUp => 'Attention';

  @override
  String get faGuestBullet1 =>
      'Les données invité sont automatiquement supprimées de nos serveurs après 90 jours d\'inactivité.';

  @override
  String get faGuestBullet2 =>
      'Pour sauvegarder définitivement votre progression et jouer sur plusieurs appareils, connectez-vous avec Apple, Google ou e-mail.';

  @override
  String get faGuestBullet3 =>
      'Les comptes invités ne peuvent pas acheter de produits ni d\'abonnements. Connectez-vous pour passer à Pro ou acheter des cosmétiques.';

  @override
  String get faChangedMind => 'J\'ai changé d\'avis';

  @override
  String get faProceedAnyway => 'Continuer quand même';

  @override
  String get faAppleFailed =>
      'Échec de la connexion avec Apple. Veuillez réessayer.';

  @override
  String get faGoogleFailed =>
      'Échec de la connexion avec Google. Veuillez réessayer.';

  @override
  String get faUnexpected =>
      'Une erreur inattendue est survenue. Veuillez réessayer.';

  @override
  String get faGuestFailed =>
      'Impossible de continuer en invité. Veuillez réessayer.';
}
