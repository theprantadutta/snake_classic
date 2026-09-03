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
  String get mpRewardProcessing => 'Récompenses en cours…';

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
  String get settingsSnapMovement => 'Déplacement par cases';

  @override
  String get settingsSnapMovementSubtitle =>
      'Avance case par case comme l\'original. Les virages sont instantanés.';

  @override
  String get settingsControlLayout => 'Disposition des boutons';

  @override
  String get settingsControlLayoutDPad => 'D-Pad';

  @override
  String get settingsControlLayoutDPadDesc => 'Haut, bas, gauche, droite';

  @override
  String get settingsControlLayoutTurn => 'Boutons de virage';

  @override
  String get settingsControlLayoutTurnDesc =>
      'Tournez à gauche ou à droite depuis votre cap. Jamais de demi-tour.';

  @override
  String get gameTurnLeft => 'Tourner à gauche';

  @override
  String get gameTurnRight => 'Tourner à droite';

  @override
  String get gameTurnControls => 'Boutons de virage';

  @override
  String get settingsControlLayoutStick => 'Joystick';

  @override
  String get settingsControlLayoutStickDesc =>
      'Poussez n\'importe où dans la barre vers la direction voulue. Gardez le doigt appuyé pour continuer à diriger.';

  @override
  String get poLayoutStick => 'STICK';

  @override
  String get gameJoystick => 'Joystick';

  @override
  String get gameJoystickHint => 'Poussez pour diriger';

  @override
  String get wtControlOptionsTitle => 'Pas fan du glissement ?';

  @override
  String get wtControlOptionsMsg =>
      'Vous préférez des boutons ? Mettez en pause et choisissez un D-Pad, deux gros boutons de virage ou un joystick flottant. Activez Déplacement par cases pour que chaque virage soit instantané. Tout est aussi dans Réglages → Commandes.';

  @override
  String get insTurnButtons => 'Boutons de virage';

  @override
  String get insTurnButtonsDesc =>
      'Deux gros boutons, un par coin : tourner à gauche, tourner à droite. Jamais de demi-tour';

  @override
  String get insJoystick => 'Joystick';

  @override
  String get insJoystickDesc =>
      'Poussez n\'importe où dans la barre vers la direction voulue ; gardez le doigt appuyé pour continuer';

  @override
  String get insSnap => 'Déplacement par cases';

  @override
  String get insSnapDesc =>
      'Avance case par case comme l\'original, pour des virages instantanés';

  @override
  String get settingsOnScreenControls => 'Commandes à l\'écran';

  @override
  String get settingsOnScreenControlsDesc =>
      'D-Pad, boutons de virage ou joystick — au choix dans Disposition des boutons';

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
  String get settingsSectionDisplay => 'AFFICHAGE';

  @override
  String get settingsSmoothMotion => 'Mouvement fluide';

  @override
  String get settingsSmoothMotionSubtitle =>
      'Utiliser la fréquence d’affichage la plus élevée prise en charge par cet écran';

  @override
  String get settingsDisplayHz => 'Hz';

  @override
  String settingsDisplayUpTo(String rate) {
    return 'jusqu’à $rate Hz';
  }

  @override
  String get settingsDisplayReading => 'Lecture de votre écran…';

  @override
  String get settingsDisplayCurrentCaption =>
      'La fréquence à laquelle votre écran se rafraîchit en ce moment.';

  @override
  String get settingsDisplayBatteryNote =>
      'L’économiseur de batterie est activé, votre écran peut donc rester à sa fréquence standard jusqu’à ce que vous le désactiviez.';

  @override
  String get settingsDisplayThermalNote =>
      'Votre appareil est chaud. Il peut conserver une fréquence plus basse le temps de refroidir, c’est normal.';

  @override
  String get settingsDisplaySingleRateNote =>
      'Cet écran fonctionne à une seule fréquence d’affichage : il n’y a donc rien à débloquer ici. Le jeu est déjà aussi fluide que possible sur cet appareil.';

  @override
  String get settingsDisplayFooter =>
      'Des fréquences d’affichage plus élevées rendent le serpent et les menus plus fluides, et consomment un peu plus de batterie. Snake Classic laisse cette option activée par défaut et ne contourne jamais l’économie d’énergie de votre appareil.';

  @override
  String get settingsDisplaySupportedTitle => 'CET ÉCRAN';

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
  String get accountSwitchTitle => 'Se connecter à un compte existant ?';

  @override
  String get accountSwitchBody =>
      'Si ce compte a déjà joué à Snake Classic, sa progression est restaurée et devient celle que tu gardes. Les pièces, scores et statistiques de cet appareil ne sont pas transférés.\n\nPour conserver la progression de cet appareil, utilise un compte avec lequel tu n\'as jamais joué.';

  @override
  String get accountSwitchConfirm => 'Se connecter quand même';

  @override
  String get settingsAuthenticatedAccount => 'Compte authentifié';

  @override
  String get accountNotBackedUpTitle => 'Aucune sauvegarde';

  @override
  String get accountNotBackedUpBody =>
      'Cette progression est liée à cette installation. Connecte-toi pour la récupérer après une réinstallation ou sur un nouveau téléphone.';

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
  String get legalAutoRenewDisclosureAppStore =>
      'Le paiement est débité de votre compte App Store à la confirmation de l\'achat. L\'abonnement est renouvelé automatiquement au même tarif et pour la même durée, sauf s\'il est résilié au moins 24 heures avant la fin de la période en cours. Gérez-le ou résiliez-le à tout moment dans les réglages de votre compte après l\'achat.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'Le paiement est débité de votre compte Google Play à la confirmation de l\'achat. L\'abonnement est renouvelé automatiquement au même tarif et pour la même durée, sauf s\'il est résilié au moins 24 heures avant la fin de la période en cours. Gérez-le ou résiliez-le à tout moment dans les paramètres d\'abonnement Google Play après l\'achat.';

  @override
  String get legalTermsEulaLink => 'Conditions d\'utilisation (EULA)';

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
  String get mpLobbyConnectionLostTitle => 'CONNEXION PERDUE';

  @override
  String get mpLobbyConnectionLostBody =>
      'Votre connexion a été coupée pendant la recherche.\nVérifiez le Wi-Fi ou les données mobiles et réessayez.';

  @override
  String get mpLobbyTimedOutTitle => 'PAS ENCORE DE PARTIE';

  @override
  String get mpLobbyTimedOutBody =>
      'Cette recherche a duré plus longtemps que prévu.\nRéessayez — une partie est généralement trouvée en moins d\'une minute.';

  @override
  String get mpLobbyWaitingForConnection =>
      'Connexion perdue — reconnexion en attente…';

  @override
  String get mpLobbyUnreachableTitle => 'MATCHMAKING INJOIGNABLE';

  @override
  String get mpLobbyUnreachableBody =>
      'Impossible de contacter le serveur.\nVérifiez votre connexion et réessayez.';

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
  String get mpLobbyWinsLabel => 'Victoires';

  @override
  String get mpLobbyLossesLabel => 'Défaites';

  @override
  String get mpLobbyDrawsLabel => 'Nuls';

  @override
  String get mpLobbyRatingLabel => 'Points';

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
  String goAdBonusCoins(Object count) {
    return '🎉 +$count pièces bonus pour le visionnage !';
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
  String goAdNoticeRewarded(Object count) {
    return 'Courte pub ensuite · +$count pièces si vous la regardez';
  }

  @override
  String get goAdNoticeInterstitial => 'Une courte pub suit';

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
  String storeFreeTrialBadge(Object days) {
    return '$days jours d\'essai gratuit';
  }

  @override
  String get storeStartFreeTrial => 'Commencer l\'essai gratuit';

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
  String get bpSeasonCosmicSerpent => 'Saison Serpent Cosmique';

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
  String get pbYourPlan => 'Votre formule';

  @override
  String get pbPlanMonthly => 'Mensuel';

  @override
  String get pbPlanYearly => 'Annuel';

  @override
  String pbRenewsOn(Object date) {
    return 'Renouvellement le $date';
  }

  @override
  String get pbSwitchToYearly => 'Passer a l annuel';

  @override
  String get pbSwitchToMonthly => 'Passer au mensuel';

  @override
  String get pbSwitchToYearlyBlurb =>
      'Effectif aujourd hui. Le reste du mois est credite et vous economisez 33 % par an.';

  @override
  String get pbSwitchToMonthlyBlurb =>
      'Effectif a la fin de votre annee payee. Rien n est debite aujourd hui.';

  @override
  String get pbManageSubscription => 'Gerer l abonnement';

  @override
  String get pbManageBlurb =>
      'Annulez ou modifiez le paiement dans la boutique';

  @override
  String get pbSwitchedToYearly => 'Passe a l annuel';

  @override
  String get pbSwitchedToMonthly =>
      'Le mensuel demarrera a la fin de cette periode';

  @override
  String get pbAllUnlocked => 'Tout ceci est a vous';

  @override
  String get pbKeepProCta => 'Garder Pro';

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

  @override
  String get ldInitializing => 'Initialisation de Snake Classic...';

  @override
  String get ldTip1 =>
      'Prévoyez deux coups d\'avance — votre queue suit là où la tête vient de passer.';

  @override
  String get ldTip2 =>
      'La nourriture bonus vaut plus de points, mais disparaît vite. Attrapez-la vite !';

  @override
  String get ldTip3 =>
      'Crashé ? Regardez une courte pub ou dépensez des pièces pour revivre et garder votre score.';

  @override
  String get ldTip4 =>
      'Enchaînez la nourriture sans pause pour bâtir un multiplicateur de combo.';

  @override
  String get ldTip5 => 'Coincé ? Longez les murs pour gagner un instant.';

  @override
  String get ldTip6 =>
      'Les défis quotidiens et les quêtes hebdo font vite grimper les pièces.';

  @override
  String get ldTip7 =>
      'Snake Classic Pro débloque de plus grands plateaux et supprime toutes les pubs.';

  @override
  String get ldTip8 =>
      'Le Contre-la-montre récompense la vitesse — et une pub peut donner +30 secondes.';

  @override
  String get ldTip9 =>
      'Les power-ups se cumulent : armez un bouclier avant un passage serré.';

  @override
  String get ldTip10 =>
      'Changez de thème, skin ou traînée à tout moment dans la boutique.';

  @override
  String get ldStepCore => 'Initialisation des systèmes principaux...';

  @override
  String get ldStepCoreSub => 'Configuration de la connexion au serveur';

  @override
  String get ldStepProfile => 'Création de votre profil de joueur...';

  @override
  String get ldStepProfileSub => 'Génération d\'un nom d\'utilisateur unique';

  @override
  String get ldStepPrefs => 'Chargement de vos préférences...';

  @override
  String get ldStepPrefsSub => 'Synchronisation des thèmes et réglages';

  @override
  String get ldStepCloud => 'Synchronisation avec le cloud...';

  @override
  String get ldStepCloudSub => 'Vérification des données';

  @override
  String get ldStepGameData => 'Chargement des données de jeu...';

  @override
  String get ldStepGameDataSub => 'Récupération des données de jeu';

  @override
  String get ldStepAudio => 'Configuration du système audio...';

  @override
  String get ldStepAudioSub => 'Chargement des effets sonores';

  @override
  String get ldStepAds => 'Préparation des récompenses...';

  @override
  String get ldStepAdsSub => 'Préparation de votre pub bonus gratuit';

  @override
  String get ldStepSetup => 'Vérification de la configuration...';

  @override
  String get ldStepSetupSub => 'Presque prêt !';

  @override
  String get ldWelcome => 'Bienvenue !';

  @override
  String get ldWelcomeSub => 'Choisissez comment continuer';

  @override
  String get ldReady => 'Prêt à jouer !';

  @override
  String get ldReadySub => 'Bon retour sur Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Échec de l\'initialisation : $error';
  }

  @override
  String get ldRetrying => 'Nouvelle tentative d\'initialisation...';

  @override
  String get ldTagline => 'EXPÉRIENCE SNAKE PREMIUM';

  @override
  String get ldLoadingUpper => 'CHARGEMENT';

  @override
  String get ldDidYouKnow => 'LE SAVIEZ-VOUS ?';

  @override
  String get ldGameFeatures => 'ATOUTS DU JEU';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Jeu fluide';

  @override
  String get ldFeatEffects => 'EFFETS';

  @override
  String get ldFeatEffectsSub => 'Particules visuelles';

  @override
  String get ldFeatLevels => 'NIVEAUX';

  @override
  String get ldFeatLevelsSub => 'Plaisir progressif';

  @override
  String get ldFeatAudio => 'AUDIO';

  @override
  String get ldFeatAudioSub => 'Son immersif';

  @override
  String get ldFeatScores => 'SCORES';

  @override
  String get ldFeatScoresSub => 'Classements mondiaux';

  @override
  String get ldFeatThemes => 'THÈMES';

  @override
  String get ldFeatThemesSub => 'Styles multiples';

  @override
  String get ldDevelopedBy => 'DÉVELOPPÉ ET MAINTENU PAR';

  @override
  String get ldDevTagline => 'Des expériences mobiles premium';

  @override
  String get ldInitFailedUpper => 'ÉCHEC DE L\'INITIALISATION';

  @override
  String get ldRetryUpper => 'RÉESSAYER';

  @override
  String get pgArena => 'Initialisation de l\'arène...';

  @override
  String get pgControls => 'Calibrage des commandes...';

  @override
  String get pgSnake => 'Apparition du serpent...';

  @override
  String get pgFood => 'Placement de la nourriture...';

  @override
  String get pgPowerUps => 'Charge des power-ups...';

  @override
  String get pgAlmost => 'Presque prêt...';

  @override
  String get pgGo => 'Go !';

  @override
  String get pgTip1 =>
      'Maintenez une direction plus longtemps pour bâtir des multiplicateurs de combo.';

  @override
  String get pgTip2 => 'La nourriture bonus rapporte plus mais disparaît vite.';

  @override
  String get pgTip3 =>
      'Les power-ups apparaissent au hasard — attrapez-les tant que possible.';

  @override
  String get pgTip4 => 'Prévoyez deux coups d\'avance, pas un seul.';

  @override
  String get pgTip5 =>
      'Les longs serpents tournent plus lentement. Gardez les virages serrés pour le début.';

  @override
  String get pgTip6 =>
      'Le Multiplicateur de Score se cumule aux combos pour des scores monstrueux.';

  @override
  String get pgTip7 =>
      'La nourriture spéciale est rare — quand elle apparaît, priorisez-la.';

  @override
  String get pgTip8 => 'Le Contre-la-montre accélère vite. Dosez vos virages.';

  @override
  String get pgTip9 =>
      'En Mode Zen, les murs se traversent. Servez-vous-en pour fuir les pièges.';

  @override
  String get pgTip10 =>
      'Partie Parfaite : ne repassez jamais sur une case déjà touchée.';

  @override
  String get pgTip11 =>
      'Le D-Pad offre des virages précis ; le balayage est plus rapide.';

  @override
  String get pgTip12 =>
      'Mettez en pause depuis le HUD — le chrono vous attend.';

  @override
  String get pgPreparing => 'PRÉPARATION DE L\'ARÈNE';

  @override
  String get pgTournamentMode => 'MODE TOURNOI';

  @override
  String get pgGameMode => 'MODE DE JEU';

  @override
  String get pgDPadControls => 'Commandes D-Pad';

  @override
  String get pgSwipeControls => 'Commandes par balayage';

  @override
  String get pgLevel => 'NIVEAU';

  @override
  String get pgBest => 'RECORD';

  @override
  String get pgGames => 'PARTIES';

  @override
  String get pgProTip => 'ASTUCE PRO';

  @override
  String get pgTapToStart => 'TOUCHEZ N\'IMPORTE OÙ POUR COMMENCER';

  @override
  String get wtWelcomeTitle => 'Bienvenue dans le jeu !';

  @override
  String get wtWelcomeMsg =>
      'Apprenons à jouer à Snake Classic. Ce tutoriel rapide vous montrera les bases.';

  @override
  String get wtHudTitle => 'Infos de jeu';

  @override
  String get wtHudMsg =>
      'La barre du haut affiche votre score, niveau et record. Suivez votre progression en jouant !';

  @override
  String get wtControlsTitle => 'Direction';

  @override
  String get wtControlsMsg =>
      'Changez de direction en glissant sur le plateau, avec un D-Pad, des boutons de virage ou un joystick à l\'écran, ou avec les flèches du clavier. Choisissez votre style dans Réglages → Commandes ou depuis le menu pause.';

  @override
  String get wtPracticeRightTitle => 'Essaie — tourne à DROITE';

  @override
  String get wtPracticeRightMsg =>
      'Tourne à droite pour continuer. Balayage, croix directionnelle ou flèches, au choix.';

  @override
  String get wtPracticeUpTitle => 'Bien — maintenant vers le HAUT';

  @override
  String get wtPracticeUpMsg => 'Tourne vers le haut pour continuer.';

  @override
  String get wtFoodTitle => 'Mangez pour grandir';

  @override
  String get wtFoodMsg =>
      'Guidez le serpent vers la nourriture du plateau. Chaque aliment le rallonge !';

  @override
  String get wtComboTitle => 'Bâtissez un combo';

  @override
  String get wtComboMsg =>
      'Mangez sans mourir pour bâtir un combo. À 5 bouchées : 1,5×, à 10 : 2×, à 20 : 3×. La puce de feu près du score chauffe et pulse en montant.';

  @override
  String get wtPowerUpsTitle => 'Power-ups';

  @override
  String get wtPowerUpsMsg =>
      'Des icônes scintillantes apparaissent parfois — mangez-en une pour l\'activer. L\'anneau autour de l\'icône se vide quand l\'effet s\'épuise, et le chrono gèle en pause.';

  @override
  String get wtWallsTitle => 'Évitez les murs !';

  @override
  String get wtWallsMsg =>
      'Ne touchez pas les bords du plateau - percuter un mur, c\'est la fin de la partie !';

  @override
  String get wtSelfTitle => 'Ne vous percutez pas !';

  @override
  String get wtSelfMsg =>
      'Quand le serpent s\'allonge, attention à ne pas heurter votre propre corps !';

  @override
  String get wtPauseTitle => 'Pause à tout moment';

  @override
  String get wtPauseMsg =>
      'Touchez l\'icône pause pour figer la partie. De là, vous pouvez reprendre, recommencer, ouvrir le Guide du jeu, rejouer ce tutoriel, changer de commandes ou activer le Déplacement par cases.';

  @override
  String get wtReadyTitle => 'Vous êtes prêt !';

  @override
  String get wtReadyMsg =>
      'Bonne chance ! Ouvrez le Guide du jeu du menu pause pour tout savoir sur les combos, power-ups, modes et retours de crash. Consultez votre Profil pour voir les succès se débloquer.';

  @override
  String get wtStartPlaying => 'Commencer à jouer !';

  @override
  String get wtSkipTutorial => 'Passer le tutoriel';

  @override
  String get wtSwipeRightUpper => 'TOURNE À DROITE';

  @override
  String get wtSwipeLeftUpper => 'TOURNE À GAUCHE';

  @override
  String get wtSwipeUpUpper => 'TOURNE VERS LE HAUT';

  @override
  String get wtSwipeDownUpper => 'TOURNE VERS LE BAS';

  @override
  String get wtSwipeAnywhereScreen =>
      'Balayage, croix directionnelle ou flèches';

  @override
  String get wtSwipeAnywhere => 'À toi de jouer !';

  @override
  String get wtGotIt => 'Compris !';

  @override
  String get wtNext => 'Suivant';

  @override
  String get wtSkip => 'Passer';

  @override
  String get wtWaiting => 'En attente...';

  @override
  String get hwPlayTitle => 'Bienvenue dans Snake Classic !';

  @override
  String get hwPlayMsg =>
      'Touchez le bouton JOUER pour lancer une partie. Balayez pour diriger le serpent et mangez pour grandir !';

  @override
  String get hwCoinsTitle => 'Vos pièces';

  @override
  String get hwCoinsMsg =>
      'Gagnez des pièces en jouant, en relevant des défis et via les bonus quotidiens. Dépensez-les à la boutique !';

  @override
  String get hwDailyTitle => 'Défis quotidiens';

  @override
  String get hwDailyMsg =>
      'Relevez les défis quotidiens pour des pièces et récompenses bonus. Nouveaux défis chaque jour !';

  @override
  String get hwStoreTitle => 'La boutique';

  @override
  String get hwStoreMsg =>
      'Achetez thèmes, skins, traînées et power-ups avec vos pièces. Débloquez Pro pour les plateaux premium et les cosmétiques exclusifs.';

  @override
  String get hwCosmeticsTitle => 'Skins et traînées';

  @override
  String get hwCosmeticsMsg =>
      'Personnalisez votre serpent ici. Les skins changent son apparence ; les traînées laissent une lueur derrière lui. À gagner en pièces ou à débloquer avec Pro.';

  @override
  String get hwProfileTitle => 'Votre profil';

  @override
  String get hwProfileMsg =>
      'Stats, succès et records vivent ici. Les succès se débloquent au fil des jalons — certains exigent un mode précis (Classique, Difficile, etc.). Connectez-vous pour synchroniser vos appareils.';

  @override
  String get hwSettingsTitle => 'Réglages';

  @override
  String get hwSettingsMsg =>
      'Personnalisez votre expérience - thèmes, commandes, audio et plus encore !';

  @override
  String get hudScoreUpper => 'SCORE';

  @override
  String hudScoreSemantics(Object value) {
    return 'Score $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'NV$level';
  }

  @override
  String get hudTournamentBadge => 'TOURNOI';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'PAUSE';

  @override
  String get poPremium => 'Premium';

  @override
  String get poStore => 'Boutique';

  @override
  String get poResume => 'REPRENDRE';

  @override
  String get poRestart => 'RECOMMENCER';

  @override
  String get poHome => 'ACCUEIL';

  @override
  String get poDPadOn => 'D-PAD : OUI';

  @override
  String get poDPadOff => 'D-PAD : NON';

  @override
  String get poSnapOn => 'CASES : OUI';

  @override
  String get poSnapOff => 'CASES : NON';

  @override
  String get poLayoutDPad => 'D-PAD';

  @override
  String get poLayoutTurn => 'VIRAGE';

  @override
  String get poSound => 'SON';

  @override
  String get poMusic => 'MUSIQUE';

  @override
  String get poHowToPlay => 'COMMENT JOUER';

  @override
  String get poGameGuide => 'GUIDE DU JEU';

  @override
  String get poFoodUpper => 'NOURRITURE';

  @override
  String get poPts10 => '10 pts';

  @override
  String get poPts25 => '25 pts';

  @override
  String get poPts50 => '50 pts';

  @override
  String get poComboUpper => 'COMBO';

  @override
  String get poBites5 => '5 bouchées';

  @override
  String get poBites10 => '10 bouchées';

  @override
  String get poBites20 => '20 bouchées';

  @override
  String get poComboHint =>
      'La puce de feu près du score chauffe et pulse à chaque palier franchi.';

  @override
  String get poPowerUpsUpper => 'POWER-UPS';

  @override
  String get poDur7s => '7 s';

  @override
  String get poDur6s => '6 s';

  @override
  String get poDur10s => '10 s';

  @override
  String get poDur8s => '8 s';

  @override
  String get poScore2x => 'Score 2×';

  @override
  String get poPowerUpHint =>
      'L\'anneau de l\'icône se vide jusqu\'à expiration. Le chrono gèle en pause.';

  @override
  String get poCrashUpper => 'CRASH';

  @override
  String get poCrashHint =>
      'Une onde rouge éclate sur la case où vous êtes mort. L\'auto-collision surligne aussi en jaune le segment touché.';

  @override
  String get poModesUpper => 'MODES';

  @override
  String get poModeWallsOn => 'murs actifs';

  @override
  String get poModeWallsOff => 'sans murs';

  @override
  String get poModeFastTick => 'rythme rapide';

  @override
  String get poModeThreeFoods => '3 nourritures à la fois';

  @override
  String get poModeThreeLives => '3 vies, ça accélère';

  @override
  String get poModeThreeMin => '3 min au total';

  @override
  String get poModeFrequentPowerUps => 'power-ups fréquents';

  @override
  String get poModeDontCross => 'ne croisez pas votre trace';

  @override
  String get dcTitle => 'Défis quotidiens';

  @override
  String get dcNoChallenges => 'Aucun défi disponible';

  @override
  String get dcAllComplete => 'Tout est terminé !';

  @override
  String dcBonusCoins(Object count) {
    return '+$count bonus';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · build $build';
  }

  @override
  String get crTagline => 'Le jeu du serpent classique, réinventé.';

  @override
  String get crChipModes => 'Modes';

  @override
  String get crChipAchievements => 'Succès';

  @override
  String get crChipDaily => 'Quotidien';

  @override
  String get crChipLeaderboards => 'Classements';

  @override
  String get crChipCosmetics => 'Cosmétiques';

  @override
  String get crCraftedBy => 'Créé par';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · Tous droits réservés';
  }

  @override
  String get gbSpeedNormal => 'Normale';

  @override
  String get gbSpeedFast => 'Rapide';

  @override
  String get gbSpeedFaster => 'Plus rapide';

  @override
  String get gbSpeedBlazing => 'Fulgurante';

  @override
  String get gbSpeedInsane => 'Folle';

  @override
  String get gbSpeedMax => 'MAX';

  @override
  String get gbLength => 'Longueur';

  @override
  String get gbSpeed => 'Vitesse';

  @override
  String get gbLevel => 'Niveau';

  @override
  String get rarityCommon => 'Commun';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityEpic => 'Épique';

  @override
  String get rarityLegendary => 'Légendaire';

  @override
  String get rarityDiamond => 'Diamant';

  @override
  String get achTitleFirstBite => 'Première Bouchée';

  @override
  String get achDescFirstBite => 'Marquez votre premier point';

  @override
  String get achTitleGettingStarted => 'Premiers Pas';

  @override
  String get achDescGettingStarted => 'Marquez 100 points';

  @override
  String get achTitleHighScorer => 'Bon Marqueur';

  @override
  String get achDescHighScorer => 'Marquez 500 points en une seule partie';

  @override
  String get achTitleMasterScorer => 'Maître Marqueur';

  @override
  String get achDescMasterScorer => 'Marquez 1000 points en une seule partie';

  @override
  String get achTitleLegendaryScorer => 'Marqueur Légendaire';

  @override
  String get achDescLegendaryScorer =>
      'Marquez 2000 points en une seule partie';

  @override
  String get achTitleFirstGame => 'Première Partie';

  @override
  String get achDescFirstGame => 'Jouez votre première partie';

  @override
  String get achTitleRegularPlayer => 'Joueur Régulier';

  @override
  String get achDescRegularPlayer => 'Jouez 10 parties';

  @override
  String get achTitleDedicatedPlayer => 'Joueur Dévoué';

  @override
  String get achDescDedicatedPlayer => 'Jouez 50 parties';

  @override
  String get achTitleSnakeEnthusiast => 'Passionné du Serpent';

  @override
  String get achDescSnakeEnthusiast => 'Jouez 100 parties';

  @override
  String get achTitleSnakeAddict => 'Accro du Serpent';

  @override
  String get achDescSnakeAddict => 'Jouez 500 parties';

  @override
  String get achTitleSurvivor => 'Survivant';

  @override
  String get achDescSurvivor => 'Survivez 60 secondes';

  @override
  String get achTitleEndurance => 'Endurance';

  @override
  String get achDescEndurance => 'Survivez 2 minutes';

  @override
  String get achTitleMarathon => 'Marathon';

  @override
  String get achDescMarathon => 'Survivez 5 minutes';

  @override
  String get achTitleNoWalls => 'Éviteur de Murs';

  @override
  String get achDescNoWalls => 'Jouez 5 parties sans toucher les murs';

  @override
  String get achTitleSpeedster => 'Bolide';

  @override
  String get achDescSpeedster => 'Atteignez le niveau 10 (vitesse max)';

  @override
  String get achTitlePerfectionist => 'Perfectionniste';

  @override
  String get achDescPerfectionist => 'Terminez une partie sans vous toucher';

  @override
  String get achTitleAllFoodTypes => 'Gourmet';

  @override
  String get achDescAllFoodTypes =>
      'Mangez les 3 types de nourriture en une seule partie';

  @override
  String get achTitleHalfGrand => 'Demi-Millier';

  @override
  String get achDescHalfGrand => 'Marquez 5 000 en une seule partie';

  @override
  String get achTitleScoreSniper => 'Sniper du Score';

  @override
  String get achDescScoreSniper => 'Marquez 10 000 en une seule partie';

  @override
  String get achTitleFiveDigitClub => 'Club des Cinq Chiffres';

  @override
  String get achDescFiveDigitClub => 'Marquez 25 000 en une seule partie';

  @override
  String get achTitleScoreTycoon => 'Magnat du Score';

  @override
  String get achDescScoreTycoon => 'Marquez 50 000 en une seule partie';

  @override
  String get achTitleScoreGod => 'Dieu du Score';

  @override
  String get achDescScoreGod => 'Marquez 100 000 en une seule partie';

  @override
  String get achTitlePointCollector => 'Collectionneur de Points';

  @override
  String get achDescPointCollector => 'Cumulez 10 000 points au total';

  @override
  String get achTitlePointHoarder => 'Amasseur de Points';

  @override
  String get achDescPointHoarder => 'Cumulez 100 000 points au total';

  @override
  String get achTitleHalfMillionClub => 'Club du Demi-Million';

  @override
  String get achDescHalfMillionClub => 'Cumulez 500 000 points au total';

  @override
  String get achTitlePointMillionaire => 'Millionnaire des Points';

  @override
  String get achDescPointMillionaire => 'Cumulez 1 000 000 de points au total';

  @override
  String get achTitleDecamillionaire => 'Décamillionnaire';

  @override
  String get achDescDecamillionaire => 'Cumulez 10 000 000 de points au total';

  @override
  String get achTitleSnakeVeteran => 'Vétéran du Serpent';

  @override
  String get achDescSnakeVeteran => 'Jouez 1 000 parties';

  @override
  String get achTitleSnakeLegend => 'Légende du Serpent';

  @override
  String get achDescSnakeLegend => 'Jouez 5 000 parties';

  @override
  String get achTitleIronWill => 'Volonté de Fer';

  @override
  String get achDescIronWill => 'Survivez 10 minutes en une seule partie';

  @override
  String get achTitleEternalSnake => 'Serpent Éternel';

  @override
  String get achDescEternalSnake => 'Survivez 20 minutes en une seule partie';

  @override
  String get achTitleTimeLord => 'Seigneur du Temps';

  @override
  String get achDescTimeLord => 'Survivez 30 minutes en une seule partie';

  @override
  String get achTitleFirstBiteSnack => 'Premier En-cas';

  @override
  String get achDescFirstBiteSnack => 'Mangez 5 aliments en une partie';

  @override
  String get achTitleHungrySnake => 'Serpent Affamé';

  @override
  String get achDescHungrySnake => 'Mangez 20 aliments en une partie';

  @override
  String get achTitleFamished => 'Affamé';

  @override
  String get achDescFamished => 'Mangez 50 aliments en une partie';

  @override
  String get achTitleRavenous => 'Vorace';

  @override
  String get achDescRavenous => 'Mangez 100 aliments en une partie';

  @override
  String get achTitleInsatiable => 'Insatiable';

  @override
  String get achDescInsatiable => 'Mangez 200 aliments en une partie';

  @override
  String get achTitleBlackHoleStomach => 'Estomac Trou Noir';

  @override
  String get achDescBlackHoleStomach => 'Mangez 500 aliments en une partie';

  @override
  String get achTitleFoodieApprentice => 'Apprenti Gourmand';

  @override
  String get achDescFoodieApprentice => 'Mangez 100 aliments au total';

  @override
  String get achTitleFoodiePro => 'Gourmand Pro';

  @override
  String get achDescFoodiePro => 'Mangez 1 000 aliments au total';

  @override
  String get achTitleFoodieMaster => 'Maître Gourmand';

  @override
  String get achDescFoodieMaster => 'Mangez 10 000 aliments au total';

  @override
  String get achTitleFoodieGod => 'Dieu Gourmand';

  @override
  String get achDescFoodieGod => 'Mangez 50 000 aliments au total';

  @override
  String get achTitleQuickPlayer => 'Joueur Éclair';

  @override
  String get achDescQuickPlayer => 'Jouez 1 heure au total';

  @override
  String get achTitleEngagedPlayer => 'Joueur Engagé';

  @override
  String get achDescEngagedPlayer => 'Jouez 10 heures au total';

  @override
  String get achTitleHardcorePlayer => 'Joueur Hardcore';

  @override
  String get achDescHardcorePlayer => 'Jouez 50 heures au total';

  @override
  String get achTitleSnakeObsessed => 'Obsédé du Serpent';

  @override
  String get achDescSnakeObsessed => 'Jouez 100 heures au total';

  @override
  String get achTitleTouchGrass => 'Prendre l\'Air';

  @override
  String get achDescTouchGrass =>
      'Jouez 250 heures au total — et si vous sortiez un peu ?';

  @override
  String get achTitleLevel5 => 'Apprenti';

  @override
  String get achDescLevel5 => 'Atteignez le Niveau 5';

  @override
  String get achTitleLevel10 => 'Compagnon';

  @override
  String get achDescLevel10 => 'Atteignez le Niveau 10';

  @override
  String get achTitleLevel25 => 'Expert';

  @override
  String get achDescLevel25 => 'Atteignez le Niveau 25';

  @override
  String get achTitleLevel50 => 'Maître';

  @override
  String get achDescLevel50 => 'Atteignez le Niveau 50';

  @override
  String get achTitleLevel100 => 'Grand Maître';

  @override
  String get achDescLevel100 => 'Atteignez le Niveau 100';

  @override
  String get achTitleClassicInitiate => 'Initié du Classique';

  @override
  String get achDescClassicInitiate => 'Terminez 10 parties en mode Classique';

  @override
  String get achTitleClassicVeteran => 'Vétéran du Classique';

  @override
  String get achDescClassicVeteran => 'Terminez 100 parties en mode Classique';

  @override
  String get achTitleClassic1000 => 'Connaisseur du Classique';

  @override
  String get achDescClassic1000 => 'Marquez 1 000 en mode Classique';

  @override
  String get achTitleClassic5000 => 'Maestro du Classique';

  @override
  String get achDescClassic5000 => 'Marquez 5 000 en mode Classique';

  @override
  String get achTitleZenInitiate => 'Initié Zen';

  @override
  String get achDescZenInitiate => 'Terminez 10 parties Zen';

  @override
  String get achTitleZenGarden => 'Jardin Zen';

  @override
  String get achDescZenGarden => 'Marquez 500 en mode Zen';

  @override
  String get achTitleZenMaster => 'Maître Zen';

  @override
  String get achDescZenMaster => 'Marquez 5 000 en mode Zen';

  @override
  String get achTitleSpeedInitiate => 'Soif de Vitesse';

  @override
  String get achDescSpeedInitiate => 'Terminez 10 parties de Défi Vitesse';

  @override
  String get achTitleSpeedrunner => 'Speedrunner';

  @override
  String get achDescSpeedrunner => 'Marquez 500 en Défi Vitesse';

  @override
  String get achTitleLightning => 'Éclair';

  @override
  String get achDescLightning => 'Marquez 2 000 en Défi Vitesse';

  @override
  String get achTitleMultifoodInitiate => 'Paysage Gourmand';

  @override
  String get achDescMultifoodInitiate => 'Terminez 10 parties MultiNourriture';

  @override
  String get achTitleBuffet => 'Buffet';

  @override
  String get achDescBuffet => 'Marquez 1 000 en MultiNourriture';

  @override
  String get achTitleSmorgasbord => 'Festin';

  @override
  String get achDescSmorgasbord => 'Marquez 5 000 en MultiNourriture';

  @override
  String get achTitleSurvivalInitiate => 'Initié de la Survie';

  @override
  String get achDescSurvivalInitiate => 'Terminez 10 parties de Survie';

  @override
  String get achTitleSurvivalPro => 'Pro de la Survie';

  @override
  String get achDescSurvivalPro => 'Survivez 5 minutes en mode Survie';

  @override
  String get achTitleLastSnakeStanding => 'Dernier Serpent Debout';

  @override
  String get achDescLastSnakeStanding => 'Marquez 2 500 en Survie';

  @override
  String get achTitleTimeattackInitiate => 'Attaquant du Chrono';

  @override
  String get achDescTimeattackInitiate =>
      'Terminez 10 parties Contre-la-Montre';

  @override
  String get achTitleBeatTheClock => 'Battez le Chrono';

  @override
  String get achDescBeatTheClock =>
      'Survivez aux 3 minutes complètes du Contre-la-Montre';

  @override
  String get achTitleTimeattackMaster => 'Maître du Contre-la-Montre';

  @override
  String get achDescTimeattackMaster => 'Marquez 3 000 en Contre-la-Montre';

  @override
  String get achTitleComboStarter => 'Débutant des Combos';

  @override
  String get achDescComboStarter =>
      'Réussissez un combo 5x en une seule partie';

  @override
  String get achTitleComboMaster => 'Maître des Combos';

  @override
  String get achDescComboMaster =>
      'Réussissez un combo 10x en une seule partie';

  @override
  String get achTitleComboPro => 'Pro des Combos';

  @override
  String get achDescComboPro => 'Réussissez un combo 20x en une seule partie';

  @override
  String get achTitleComboGod => 'Dieu des Combos';

  @override
  String get achDescComboGod => 'Réussissez un combo 50x en une seule partie';

  @override
  String get achTitleComboLegend => 'Légende des Combos';

  @override
  String get achDescComboLegend =>
      'Réussissez un combo 100x en une seule partie';

  @override
  String get achTitleGrowingSnake => 'Serpent en Croissance';

  @override
  String get achDescGrowingSnake =>
      'Faites grandir le serpent jusqu\'à 20 de longueur';

  @override
  String get achTitleBigSnake => 'Grand Serpent';

  @override
  String get achDescBigSnake =>
      'Faites grandir le serpent jusqu\'à 50 de longueur';

  @override
  String get achTitleHugeSnake => 'Serpent Géant';

  @override
  String get achDescHugeSnake =>
      'Faites grandir le serpent jusqu\'à 100 de longueur';

  @override
  String get achTitleMassiveSnake => 'Serpent Colossal';

  @override
  String get achDescMassiveSnake =>
      'Faites grandir le serpent jusqu\'à 200 de longueur';

  @override
  String get achTitleAnaconda => 'Anaconda';

  @override
  String get achDescAnaconda =>
      'Faites grandir le serpent jusqu\'à 500 de longueur';

  @override
  String get achTitleFirstPowerUp => 'Power-Up !';

  @override
  String get achDescFirstPowerUp => 'Ramassez votre premier power-up';

  @override
  String get achTitlePowerPlayer => 'Joueur Puissant';

  @override
  String get achDescPowerPlayer => 'Ramassez 10 power-ups au total';

  @override
  String get achTitlePowerHungry => 'Assoiffé de Puissance';

  @override
  String get achDescPowerHungry => 'Ramassez 50 power-ups au total';

  @override
  String get achTitlePowerAddict => 'Accro à la Puissance';

  @override
  String get achDescPowerAddict => 'Ramassez 200 power-ups au total';

  @override
  String get achTitlePowerMaster => 'Maître de la Puissance';

  @override
  String get achDescPowerMaster => 'Ramassez 1 000 power-ups au total';

  @override
  String get achTitleVarietyPack => 'Pack Varié';

  @override
  String get achDescVarietyPack =>
      'Ramassez chacun des 4 types de power-up au moins une fois';

  @override
  String get achTitleSpeedDemon => 'Démon de la Vitesse';

  @override
  String get achDescSpeedDemon => 'Ramassez 25 power-ups Accélération';

  @override
  String get achTitleImmortalStreak => 'Série Immortelle';

  @override
  String get achDescImmortalStreak => 'Ramassez 25 power-ups Invincibilité';

  @override
  String get achTitleSpecialDiet => 'Régime Spécial';

  @override
  String get achDescSpecialDiet => 'Mangez 50 aliments spéciaux au total';

  @override
  String get achTitleBonusHunter => 'Chasseur de Bonus';

  @override
  String get achDescBonusHunter => 'Mangez 100 aliments bonus au total';

  @override
  String get achTitleUntouchable5 => 'Intouchable';

  @override
  String get achDescUntouchable5 =>
      'Réussissez 5 parties parfaites (aucun choc, 30 s+)';

  @override
  String get achTitleUntouchable20 => 'Impeccable';

  @override
  String get achDescUntouchable20 => 'Réussissez 20 parties parfaites';

  @override
  String get achTitleUntouchable50 => 'Légende Intouchable';

  @override
  String get achDescUntouchable50 => 'Réussissez 50 parties parfaites';

  @override
  String get achTitleHotStreak => 'Série Chaude';

  @override
  String get achDescHotStreak =>
      '5 parties d\'affilée avec score >0 et durée 30 s+';

  @override
  String get achTitleOnFire => 'En Feu';

  @override
  String get achDescOnFire => 'Série de 10 parties (30 s+ chacune)';

  @override
  String get achTitleUnstoppable => 'Inarrêtable';

  @override
  String get achDescUnstoppable => 'Série de 25 parties (30 s+ chacune)';

  @override
  String get achTitleDailyThree => 'Joueur Quotidien';

  @override
  String get achDescDailyThree => 'Jouez 3 jours consécutifs';

  @override
  String get achTitleWeekWarrior => 'Guerrier de la Semaine';

  @override
  String get achDescWeekWarrior => 'Jouez 7 jours consécutifs';

  @override
  String get achTitleVelocity => 'Vélocité';

  @override
  String get achDescVelocity =>
      'Atteignez le niveau 15 en jeu dans une même partie';

  @override
  String get achTitleMachSpeed => 'Vitesse Mach';

  @override
  String get achDescMachSpeed =>
      'Atteignez le niveau 20 en jeu dans une même partie';

  @override
  String get achTitleCosmicSnake => 'Serpent Cosmique';

  @override
  String get achDescCosmicSnake =>
      'Atteignez le niveau 25 en jeu dans une même partie';

  @override
  String get achTitleModeExplorer => 'Explorateur de Modes';

  @override
  String get achDescModeExplorer =>
      'Jouez au moins une partie dans 3 modes différents';

  @override
  String get achTitleAllModePlayer => 'Joueur Tous Modes';

  @override
  String get achDescAllModePlayer =>
      'Jouez au moins une partie dans chaque mode (8 modes)';

  @override
  String get achTitleNightOwl => 'Oiseau de Nuit';

  @override
  String get achDescNightOwl => 'Terminez une partie entre minuit et 5 h';

  @override
  String get achTitleEarlyBird => 'Lève-Tôt';

  @override
  String get achDescEarlyBird => 'Terminez une partie entre 5 h et 8 h';

  @override
  String get achTitleWeekendWarrior => 'Guerrier du Week-end';

  @override
  String get achDescWeekendWarrior => 'Terminez 10 parties le week-end';

  @override
  String get ppuMegaSpeedBoost => 'Méga Accélération';

  @override
  String get ppuMegaInvincibility => 'Méga Invincibilité';

  @override
  String get ppuMegaScoreMultiplier => 'Méga Multiplicateur de Score';

  @override
  String get ppuMegaSlowMotion => 'Méga Ralenti';

  @override
  String get ppuTeleport => 'Téléportation';

  @override
  String get ppuSizeReducer => 'Réducteur de Taille';

  @override
  String get ppuScoreShield => 'Bouclier de Score';

  @override
  String get ppuComboMultiplier => 'Multiplicateur de Combo';

  @override
  String get ppuTimeWarp => 'Distorsion Temporelle';

  @override
  String get ppuMagneticFood => 'Nourriture Magnétique';

  @override
  String get ppuGhostMode => 'Mode Fantôme';

  @override
  String get ppuDoubleTrouble => 'Double Ennui';

  @override
  String get ppuLuckyCharm => 'Porte-Bonheur';

  @override
  String get ppuPowerSurge => 'Surtension';

  @override
  String get bundleMegaPack => 'Pack Méga Puissance';

  @override
  String get bundleMegaPackDesc =>
      'Versions améliorées des power-ups classiques';

  @override
  String get bundleTacticalPack => 'Pack Tactique';

  @override
  String get bundleTacticalPackDesc =>
      'Power-ups stratégiques pour joueurs aguerris';

  @override
  String get bundleUltimatePack => 'Pack Ultime';

  @override
  String get bundleUltimatePackDesc => 'Tous les power-ups premium disponibles';

  @override
  String get skinClassic => 'Classique';

  @override
  String get skinGolden => 'Serpent Doré';

  @override
  String get skinRainbow => 'Serpent Arc-en-Ciel';

  @override
  String get skinGalaxy => 'Serpent Galaxie';

  @override
  String get skinDragon => 'Serpent Dragon';

  @override
  String get skinElectric => 'Serpent Électrique';

  @override
  String get skinFire => 'Serpent de Feu';

  @override
  String get skinIce => 'Serpent de Glace';

  @override
  String get skinShadow => 'Serpent d\'Ombre';

  @override
  String get skinNeon => 'Serpent Néon';

  @override
  String get skinCrystal => 'Serpent de Cristal';

  @override
  String get skinCosmic => 'Serpent Cosmique';

  @override
  String get skinClassicDesc => 'L\'apparence originale du serpent';

  @override
  String get skinGoldenDesc =>
      'Serpent d\'or étincelant qui brille à chaque mouvement';

  @override
  String get skinRainbowDesc =>
      'Un serpent coloré qui traverse les couleurs de l\'arc-en-ciel';

  @override
  String get skinGalaxyDesc => 'Serpent cosmique aux motifs étoilés';

  @override
  String get skinDragonDesc =>
      'Serpent féroce aux écailles de dragon et pouvoirs mystiques';

  @override
  String get skinElectricDesc => 'Crépitant d\'énergie électrique';

  @override
  String get skinFireDesc => 'Brûlant de motifs enflammés';

  @override
  String get skinIceDesc => 'Beauté glacée aux effets cristallins';

  @override
  String get skinShadowDesc => 'Serpent d\'ombre, sombre et mystérieux';

  @override
  String get skinNeonDesc => 'Brillant de néons cyberpunk';

  @override
  String get skinCrystalDesc =>
      'Serpent de cristal translucide aux effets prismatiques';

  @override
  String get skinCosmicDesc =>
      'Serpent fait de poussière d\'étoiles et de matière cosmique';

  @override
  String get trailNone => 'Sans Traînée';

  @override
  String get trailParticle => 'Traînée de Particules';

  @override
  String get trailGlow => 'Traînée Lumineuse';

  @override
  String get trailRainbow => 'Traînée Arc-en-Ciel';

  @override
  String get trailFire => 'Traînée de Feu';

  @override
  String get trailElectric => 'Traînée Électrique';

  @override
  String get trailStar => 'Traînée d\'Étoiles';

  @override
  String get trailCosmic => 'Traînée Cosmique';

  @override
  String get trailNeon => 'Traînée Néon';

  @override
  String get trailShadow => 'Traînée d\'Ombre';

  @override
  String get trailCrystal => 'Traînée de Cristal';

  @override
  String get trailDragon => 'Traînée de Dragon';

  @override
  String get trailNoneDesc => 'Serpent épuré, sans effet de traînée';

  @override
  String get trailParticleDesc =>
      'Laisse une traînée de particules scintillantes';

  @override
  String get trailGlowDesc =>
      'Traînée lumineuse qui s\'estompe derrière le serpent';

  @override
  String get trailRainbowDesc => 'Effet de traînée arc-en-ciel coloré';

  @override
  String get trailFireDesc => 'Traînée de feu ardente avec braises';

  @override
  String get trailElectricDesc =>
      'Traînée électrique crépitante avec effets d\'éclairs';

  @override
  String get trailStarDesc =>
      'Des étoiles scintillantes suivent le chemin du serpent';

  @override
  String get trailCosmicDesc => 'Effets de poussière cosmique et de nébuleuse';

  @override
  String get trailNeonDesc => 'Éclat néon vif au style cyberpunk';

  @override
  String get trailShadowDesc => 'Traînée d\'ombre sombre aux effets de fumée';

  @override
  String get trailCrystalDesc => 'Éclats cristallins qui s\'estompent';

  @override
  String get trailDragonDesc => 'Traînée mystique de souffle de dragon';

  @override
  String get coinPackSmall => 'Pack de Départ';

  @override
  String get coinPackMedium => 'Pack Avantageux';

  @override
  String get coinPackLarge => 'Pack Premium';

  @override
  String get coinPackMega => 'Pack Ultime';

  @override
  String coinsAmount(Object coins) {
    return '$coins pièces';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus en bonus';
  }

  @override
  String get boardSmall => 'Petit';

  @override
  String get boardClassic => 'Classique';

  @override
  String get boardLarge => 'Grand';

  @override
  String get boardHuge => 'Immense';

  @override
  String get boardEpic => 'Épique';

  @override
  String get boardMassive => 'Colossal';

  @override
  String get boardUltimate => 'Ultime';

  @override
  String get boardSmallDesc => 'Parties rapides, espaces réduits';

  @override
  String get boardClassicDesc => 'L\'expérience Snake originale';

  @override
  String get boardLargeDesc => 'Plus de place pour grandir';

  @override
  String get boardHugeDesc => 'Défi et espace maximum';

  @override
  String get boardEpicDesc => 'Un grand plateau pour joueurs avancés';

  @override
  String get boardMassiveDesc => 'Plateau gigantesque pour parties épiques';

  @override
  String get boardUltimateDesc => 'Le plus grand plateau possible';

  @override
  String get crashLabelSkip => 'Passer';

  @override
  String get crashLabelUntilTap => 'Jusqu\'au Toucher';

  @override
  String get tgmClassic => 'Classique';

  @override
  String get tgmSpeedRun => 'Course de Vitesse';

  @override
  String get tgmSurvival => 'Survie';

  @override
  String get tgmNoWalls => 'Sans Murs';

  @override
  String get tgmPowerUpMadness => 'Folie de Power-ups';

  @override
  String get tgmPerfectGame => 'Partie Parfaite';

  @override
  String get tgmClassicDesc => 'Règles standard du jeu Snake';

  @override
  String get tgmSpeedRunDesc => 'La vitesse du jeu augmente rapidement';

  @override
  String get tgmSurvivalDesc => 'Survivez le plus longtemps possible';

  @override
  String get tgmNoWallsDesc => 'Le serpent traverse les bords de l\'écran';

  @override
  String get tgmPowerUpMadnessDesc => 'Des power-ups apparaissent fréquemment';

  @override
  String get tgmPerfectGameDesc =>
      'Aucune erreur permise - un choc termine la partie';

  @override
  String get ttDaily => 'Défi Quotidien';

  @override
  String get ttWeekly => 'Tournoi Hebdomadaire';

  @override
  String get ttSpecial => 'Événement Spécial';

  @override
  String get tsUpcoming => 'À venir';

  @override
  String get tsActive => 'En cours';

  @override
  String get tsEnded => 'Terminé';

  @override
  String get cdEasy => 'Facile';

  @override
  String get cdMedium => 'Moyen';

  @override
  String get cdHard => 'Difficile';

  @override
  String get usOnline => 'En ligne';

  @override
  String get usOffline => 'Hors ligne';

  @override
  String get usPlaying => 'En jeu';

  @override
  String get bprXpBoost => 'Boost d\'XP';

  @override
  String get bprCoins => 'Pièces';

  @override
  String get bprTheme => 'Thème';

  @override
  String get bprSkin => 'Skin de Serpent';

  @override
  String get bprTrail => 'Effet de Traînée';

  @override
  String get bprPowerUp => 'Power-Up';

  @override
  String get bprTournamentEntry => 'Entrée de Tournoi';

  @override
  String get bprTitle => 'Titre de Joueur';

  @override
  String get bprAvatar => 'Avatar';

  @override
  String get bprSpecial => 'Récompense Spéciale';

  @override
  String get bprFree => 'Gratuit';

  @override
  String get bprPremium => 'Premium';

  @override
  String get bprnStarDust => 'Poussière d\'Étoiles';

  @override
  String get bprnEnergyPack => 'Pack d\'Énergie';

  @override
  String get bprnBronzeEntry => 'Entrée Bronze';

  @override
  String get bprnSilverEntry => 'Entrée Argent';

  @override
  String get bprnStargazer => 'Contemplateur d\'Étoiles';

  @override
  String get bprnVoyager => 'Voyageur';

  @override
  String get bprnNebulaTheme => 'Thème Nébuleuse';

  @override
  String get bprnStardustTrail => 'Traînée de Poussière d\'Étoiles';

  @override
  String get bprnLegendaryCrate => 'Coffre Légendaire';

  @override
  String get bprnMegaXp => 'Méga XP';

  @override
  String get bprnCosmicCharge => 'Charge Cosmique';

  @override
  String get bprnNovaBurst => 'Explosion de Nova';

  @override
  String get bprnGalaxySkin => 'Skin Galaxie';

  @override
  String get bprnCrystalSerpent => 'Serpent de Cristal';

  @override
  String get bprnPlasmaWake => 'Sillage de Plasma';

  @override
  String get bprnCosmicAura => 'Aura Cosmique';

  @override
  String get bprnCyberpunkTheme => 'Thème Cyberpunk';

  @override
  String get bprnCrystalTheme => 'Thème Cristal';

  @override
  String get bprnSeasonTrophy => 'Trophée de Saison';

  @override
  String get bprnCosmicCrown => 'Couronne Cosmique';

  @override
  String get bprnCosmicLegend => 'Légende Cosmique';

  @override
  String get bprnStarCommander => 'Commandant Stellaire';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity Pièces';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'Récompense gratuite : $type';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'Récompense premium exclusive : $type';
  }

  @override
  String get insHowToPlay => 'COMMENT JOUER';

  @override
  String get insObjective => 'OBJECTIF';

  @override
  String get insObjectiveBody =>
      'Contrôlez le serpent pour manger et grandir le plus possible sans toucher les murs ni vous-même !';

  @override
  String get insControls => 'COMMANDES';

  @override
  String get insSwipeUp => 'Glissez vers le Haut ↑';

  @override
  String get insSwipeUpDesc => 'Déplace le serpent vers le haut';

  @override
  String get insSwipeDown => 'Glissez vers le Bas ↓';

  @override
  String get insSwipeDownDesc => 'Déplace le serpent vers le bas';

  @override
  String get insSwipeLeft => 'Glissez à Gauche ←';

  @override
  String get insSwipeLeftDesc => 'Déplace le serpent à gauche';

  @override
  String get insSwipeRight => 'Glissez à Droite →';

  @override
  String get insSwipeRightDesc => 'Déplace le serpent à droite';

  @override
  String get insArrowKeys => 'Touches fléchées';

  @override
  String get insArrowKeysDesc => 'Changer de direction';

  @override
  String get insWasd => 'WASD';

  @override
  String get insWasdDesc => 'Changer de direction';

  @override
  String get insSpacebar => 'Barre d’espace';

  @override
  String get insSpacebarDesc => 'Pause/Reprise de la partie';

  @override
  String get insFoodTypes => 'TYPES DE NOURRITURE';

  @override
  String get insNormalFood => 'Nourriture Normale';

  @override
  String get insBonusFood => 'Nourriture Bonus';

  @override
  String get insSpecialFood => 'Nourriture Spéciale';

  @override
  String get insRules => 'RÈGLES';

  @override
  String get insRule1 => 'Mangez pour grandir et augmenter votre score';

  @override
  String get insRule2 => 'Le serpent accélère à chaque niveau';

  @override
  String get insRule3 =>
      'La partie se termine si vous touchez un mur ou vous-même';

  @override
  String get insRule4 =>
      'La nourriture spéciale apparaît toutes les 10 nourritures normales';

  @override
  String get insRule5 => 'La nourriture bonus expire après 15 secondes';

  @override
  String get insProTips => 'CONSEILS PRO';

  @override
  String get insTip1 => 'Planifiez vos mouvements à l\'avance';

  @override
  String get insTip2 => 'Utilisez les bords pour créer des espaces sûrs';

  @override
  String get insTip3 => 'Surveillez le retour visuel des glissements';

  @override
  String get insTip4 => 'Entraînez-vous à différents niveaux de difficulté';

  @override
  String get insBackToGame => 'RETOUR AU JEU';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return '$coins pièces et $xp XP récupérés !';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return '$coins pièces récupérées !';
  }

  @override
  String get dchWatchTo2x => 'REGARDER POUR 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 Doublé ! +$coins pièces bonus !';
  }

  @override
  String get dchClaimAll => 'Tout Récupérer';

  @override
  String get dchTodaysProgress => 'Progression du Jour';

  @override
  String get dchClaim => 'Récupérer';

  @override
  String get dchClaimed => 'Récupéré';

  @override
  String get dchAllCompleteTitle => 'Tous les Défis Terminés !';

  @override
  String get dchBonusClaimed => 'Récompense bonus récupérée';

  @override
  String get dchBonusPending =>
      'Bonus en attente — récupérez n\'importe quel défi';

  @override
  String get dchLoading => 'Chargement des défis...';

  @override
  String get dchCheckBack =>
      'Revenez plus tard pour de nouveaux défis quotidiens !';

  @override
  String get dchAbout => 'À propos des Défis Quotidiens';

  @override
  String get dchAbout1 => 'De nouveaux défis chaque jour à minuit';

  @override
  String get dchAbout2 => 'Terminez des défis pour gagner des pièces';

  @override
  String get dchAbout3 => 'Gagnez de l\'XP pour monter de niveau';

  @override
  String get dchAbout4 => 'Terminez les 3 pour une récompense bonus !';

  @override
  String get dchAllBonusTitle => 'Bonus Tous Défis';

  @override
  String get dchAllBonusDesc => 'Tous les défis quotidiens du jour terminés.';

  @override
  String get wqNoQuests => 'Pas encore de quêtes hebdomadaires — revenez lundi';

  @override
  String get wqTitle => 'Quêtes Hebdomadaires';

  @override
  String get wqClaimReward => 'Récupérer la Récompense';

  @override
  String get rvNotFound => 'Replay introuvable';

  @override
  String get rvLoadFailed => 'Échec du chargement du replay';

  @override
  String rvTitle(Object name) {
    return 'Replay : $name';
  }

  @override
  String get rvLoadingTitle => 'Chargement du Replay...';

  @override
  String get rvLoading => 'Chargement du replay...';

  @override
  String get rvGoBack => 'Retour';

  @override
  String get rvScore => 'Score';

  @override
  String get rvLevel => 'Niveau';

  @override
  String get rvFrame => 'Image';

  @override
  String get rvTime => 'Temps';

  @override
  String get rvNoFrameData => 'Aucune donnée d\'images';

  @override
  String get rvSpeedLabel => 'Vitesse : ';

  @override
  String rvAteFood(Object type) {
    return '🍎 A mangé une nourriture $type';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ A ramassé un power-up $type';
  }

  @override
  String get unEmpty => 'Le nom d\'utilisateur ne peut pas être vide';

  @override
  String get unSetFailed => 'Impossible de définir le nom d\'utilisateur';

  @override
  String get unPickTitle => 'Choisissez votre nom d\'utilisateur';

  @override
  String get unPickBody =>
      'C\'est ainsi que vous apparaîtrez au classement. Nous en avons choisi un pour vous — gardez-le ou changez-le.';

  @override
  String get unLabel => 'Nom d\'utilisateur';

  @override
  String get unSaving => 'ENREGISTREMENT...';

  @override
  String get unContinue => 'CONTINUER';

  @override
  String get unChangeAnytime =>
      'Vous pouvez le changer à tout moment dans les Réglages.';

  @override
  String unMinLength(Object min) {
    return 'Le nom d\'utilisateur doit contenir au moins $min caractères';
  }

  @override
  String unMaxLength(Object max) {
    return 'Le nom d\'utilisateur doit contenir au plus $max caractères';
  }

  @override
  String get unPattern =>
      'Le nom d\'utilisateur doit commencer par une lettre et ne contenir que des lettres, chiffres et tirets bas';

  @override
  String get unReserved =>
      'Ce nom d\'utilisateur est réservé et ne peut pas être utilisé';

  @override
  String get unTaken => 'Ce nom d\'utilisateur est déjà pris';

  @override
  String get unUpdateFailed =>
      'Impossible de mettre à jour le nom d\'utilisateur';

  @override
  String get pcTitle => 'Confidentialité et Conditions Mises à Jour';

  @override
  String pcVersionLine(Object version) {
    return 'Version $version · veuillez lire et accepter pour continuer';
  }

  @override
  String get pcTabPrivacy => 'Politique de Confidentialité';

  @override
  String get pcTabTerms => 'Conditions d\'Utilisation';

  @override
  String get pcAgree =>
      'J\'ai lu et j\'accepte la Politique de Confidentialité et les Conditions d\'Utilisation mises à jour';

  @override
  String get pcContinue => 'Continuer';

  @override
  String lgAvailableAt(Object url) {
    return 'Ce document est disponible sur $url.';
  }

  @override
  String get lgUnavailable =>
      'Ce document est indisponible pour le moment. Veuillez réessayer plus tard.';

  @override
  String get auTitle => 'Inscrivez-vous pour acheter';

  @override
  String get auBody =>
      'Les comptes invités peuvent jouer et sauvegarder localement, mais pas acheter ni s\'abonner. Liez un compte Google ou e-mail pour débloquer les achats — vos pièces, cosmétiques et records restent attachés.';

  @override
  String get auGoogle => 'Continuer avec Google';

  @override
  String get auGoogleSub =>
      'L\'option la plus rapide. Connectez-vous avec votre compte Google.';

  @override
  String get auLinked => 'Compte lié. Vous pouvez maintenant faire des achats.';

  @override
  String get auEmail => 'Créer un Compte E-mail';

  @override
  String get auEmailSub =>
      'Utilisez n\'importe quel e-mail et un mot de passe de votre choix. Restaurez sur n\'importe quel appareil.';

  @override
  String get auNotNow => 'Pas maintenant';

  @override
  String get auErrCredentialInUse =>
      'Cet identifiant est déjà lié à un autre compte. Essayez de vous connecter avec.';

  @override
  String get auErrAlreadyLinked => 'Ce compte est déjà lié.';

  @override
  String get auErrRequiresRecentLogin =>
      'Par sécurité, reconnectez-vous avant de lier.';

  @override
  String get auErrNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get auErrGeneric => 'Échec de la liaison. Veuillez réessayer.';

  @override
  String get sroSettingUpTitle => 'Configuration de votre compte…';

  @override
  String get sroSettingUpBody =>
      'Préparation de votre première session. Cela n\'arrive qu\'une fois.';

  @override
  String get sroLoadingTitle => 'Chargement de vos données précédentes…';

  @override
  String get sroLoadingBody =>
      'Récupération de vos statistiques, succès, pièces et déblocages depuis le cloud.';

  @override
  String get sroRestoringTitle => 'Restauration de votre progression…';

  @override
  String get sroRestoringBody =>
      'Application de tout sur cet appareil. Ne fermez pas l\'appli.';

  @override
  String get sroDoneTitle => 'C\'est prêt !';

  @override
  String get sroDoneBody => 'Votre progression a été restaurée.';

  @override
  String get sroFailedTitle => 'Impossible de restaurer vos données';

  @override
  String get sroFailedBody =>
      'Impossible de joindre le cloud pour l\'instant. Vérifiez votre connexion internet et réessayez. Vous pouvez aussi continuer sans restaurer — nous réessaierons à la prochaine ouverture de l\'appli.';

  @override
  String get sroTryAgain => 'Réessayer';

  @override
  String get sroContinueAnyway => 'Continuer Quand Même';

  @override
  String get ssiOfflinePending =>
      'Hors ligne - Les changements se synchroniseront à la connexion';

  @override
  String get ssiSyncing => 'Synchronisation...';

  @override
  String get ssiAllSynced => 'Toutes les données synchronisées';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments n\'ont pas pu se synchroniser',
      one: '1 élément n\'a pas pu se synchroniser',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments en attente de synchronisation',
      one: '1 élément en attente de synchronisation',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'Hors ligne';

  @override
  String get rvoContinue => 'CONTINUER ?';

  @override
  String get rvoSubtitlePro =>
      'Ressuscitez et gardez votre score · Gratuit avec Pro';

  @override
  String rvoSubtitleTimer(Object seconds) {
    return 'Ressuscitez et gardez votre score · ${seconds}s';
  }

  @override
  String get rvoGetLifePro => 'Obtenir une Vie · Gratuit pour Pro';

  @override
  String get rvoWatchAd => 'Regarder une pub pour revivre';

  @override
  String get rvoLoadingAd => 'Chargement de la pub…';

  @override
  String rvoUseCoins(Object coins) {
    return 'Utiliser $coins pièces';
  }

  @override
  String get rvoNoThanks => 'Non merci';

  @override
  String get tbTimesUp => 'TEMPS ÉCOULÉ !';

  @override
  String tbKeepGoing(Object seconds) {
    return 'Continuez · ${seconds}s';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'Regarder une pub — +${seconds}s';
  }

  @override
  String get tbEndRun => 'Terminer la partie';

  @override
  String get dbTitle => 'Bonus Quotidien';

  @override
  String get dbClaimToday => 'Récupérez votre récompense quotidienne !';

  @override
  String get dbComeBack => 'Revenez demain !';

  @override
  String dbDayChip(Object day) {
    return 'J$day';
  }

  @override
  String get dbTodaysReward => 'Récompense du Jour';

  @override
  String get dbAlreadyClaimed => 'Déjà récupéré aujourd\'hui';

  @override
  String get dbClaim => 'RÉCUPÉRER LA RÉCOMPENSE';

  @override
  String get dbClaim2x => 'RÉCUPÉRER 2× — VOIR UNE PUB';

  @override
  String get npPrimerTitle => 'Ne ratez rien !';

  @override
  String get npPrimerBody =>
      'Nous n\'envoyons que quelques notifications par jour — le rappel de votre défi quotidien et les événements spéciaux.\n\nPas de spam, promis. 🐍';

  @override
  String get npMaybeLater => 'Peut-être plus tard';

  @override
  String get npAllSet => '🎉 Tout est prêt !';

  @override
  String get npTurnOn => 'Activer';

  @override
  String get npSoftTitle => 'Envie de rester informé ?';

  @override
  String get npSoftBody =>
      'Activez les notifications et nous vous rappellerons vos défis quotidiens et vos séries — plus les grandes nouvelles comme les cadeaux Premium GRATUITS et les événements spéciaux.\n\nJuste quelques-unes par jour, pas de spam. 🐍';

  @override
  String get npNotNow => 'Pas maintenant';

  @override
  String get npEnable => 'Activer les notifications';

  @override
  String get aroUnlocked => 'SUCCÈS DÉBLOQUÉ';

  @override
  String get aroTapToContinue => 'Touchez pour continuer';

  @override
  String get aroSkip => 'PASSER';

  @override
  String aroSkipCount(Object count) {
    return 'PASSER ($count)';
  }

  @override
  String get luLevelUp => 'NIVEAU SUPÉRIEUR !';

  @override
  String luReached(Object level) {
    return 'Vous avez atteint le Niveau $level';
  }

  @override
  String get luNice => 'SUPER';

  @override
  String get cfTapContinue => 'Touchez n\'importe où pour continuer';

  @override
  String get cfTapSkip => 'Touchez n\'importe où pour passer';

  @override
  String ppgLvShort(Object level) {
    return 'Nv $level';
  }

  @override
  String ppgLvUpper(Object level) {
    return 'NV $level';
  }

  @override
  String ppgLevel(Object level) {
    return 'Niveau $level';
  }

  @override
  String get xgTitle => 'Quitter la Partie ?';

  @override
  String get xgBody =>
      'Voulez-vous vraiment quitter ? Votre progression actuelle sera perdue.';

  @override
  String get xgExit => 'Quitter';

  @override
  String get ccTitle => 'Comment voulez-vous jouer ?';

  @override
  String get ccBody =>
      'Choisissez-en un — modifiable à tout moment dans Réglages → Commandes.';

  @override
  String get ccSwipe => 'Gestes de Glissement';

  @override
  String get ccSwipeSub => 'Glissez n\'importe où sur le plateau pour tourner.';

  @override
  String get ccDpad => 'Commandes D-Pad';

  @override
  String get ccDpadSub => 'Boutons directionnels à l\'écran.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 +$coins pièces ajoutées à votre portefeuille !';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'Regarder une pub — +$coins pièces';
  }

  @override
  String get rcNoAd => 'Aucune pub disponible pour le moment';

  @override
  String get raOptIn => 'Participez — regardez pour gagner';

  @override
  String get compassSemantics => 'Indicateur de direction de glissement';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 Bonus quotidien doublé — +$coins pièces bonus !';
  }

  @override
  String get nsNewNotification => 'Vous avez une nouvelle notification';

  @override
  String get nsAchievementUnlocked => '🏆 Succès Débloqué !';

  @override
  String get nsDailyReminderTitle =>
      '🐍 C\'est l\'heure de jouer à Snake Classic !';

  @override
  String get nsDailyReminderBody =>
      'Terminez votre défi quotidien et grimpez au classement !';

  @override
  String get mpErrMatchmaking => 'Échec du matchmaking. Veuillez réessayer.';

  @override
  String get mpErrCreateFailed => 'Impossible de créer la partie';

  @override
  String get mpErrJoinFailed =>
      'Impossible de rejoindre la partie. Elle est peut-être pleine ou n\'existe pas.';

  @override
  String get mpErrReadyFailed => 'Impossible de mettre à jour le statut prêt';

  @override
  String get mpErrStartFailed => 'Impossible de démarrer la partie';

  @override
  String get mpErrStartTimeout =>
      'Délai de démarrage dépassé. Veuillez réessayer.';

  @override
  String get mpErrReconnectFailed => 'Impossible de se reconnecter au match.';

  @override
  String get mpErrConnectionLost =>
      'Connexion perdue — le match n\'a pas pu reprendre.';

  @override
  String get mpErrMatchEndedAway =>
      'Le match s\'est terminé pendant votre absence.';

  @override
  String get mpErrWaitingReady =>
      'En attente que tous les joueurs soient prêts';

  @override
  String get mpErrOnlyHost => 'Seul l\'hôte peut démarrer la partie';

  @override
  String get mpErrSessionExpired =>
      'Session de jeu expirée. Veuillez créer une nouvelle partie';

  @override
  String get mpErrAlreadyStarted => 'Cette partie a déjà commencé';

  @override
  String get mpErrNeedTwoPlayers =>
      'Les matchs nécessitent exactement 2 joueurs';

  @override
  String get mpErrSignIn => 'Connectez-vous pour jouer en multijoueur';

  @override
  String get mpErrReconnectExpired => 'Délai de reconnexion expiré';

  @override
  String get mpErrCheckInternet => 'Connexion perdue. Vérifiez votre internet';

  @override
  String get mpErrUnableJoin =>
      'Impossible de rejoindre le salon. Veuillez réessayer';

  @override
  String get mpErrGeneric => 'Un problème est survenu. Veuillez réessayer';

  @override
  String stDurSeconds(Object s) {
    return '$s s';
  }

  @override
  String stDurMinutes(Object m) {
    return '$m min';
  }

  @override
  String stDurHours(Object h) {
    return '$h h';
  }

  @override
  String stDurMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String stDurHourMin(Object h, Object m) {
    return '$h h $m min';
  }

  @override
  String dchProgressSummary(Object completed, Object total) {
    return '$completed défis terminés sur $total';
  }

  @override
  String wqProgressSummary(Object completed, Object total) {
    return '$completed / $total terminées';
  }

  @override
  String wqClaimable(Object count) {
    return '$count à récupérer';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins pièces, +$xp XP de passe';
  }

  @override
  String get insPoints10 => '10 points';

  @override
  String get insPoints25 => '25 points';

  @override
  String get insPoints50 => '50 points + Niveau Supérieur';

  @override
  String get unRules =>
      '• 3 à 20 caractères\n• Doit commencer par une lettre\n• Lettres, chiffres et tirets bas uniquement';

  @override
  String get dcTitleScoreEasy => 'Score de Débutant';

  @override
  String get dcTitleScoreMedium => 'Joueur Habile';

  @override
  String get dcTitleScoreHard => 'Maître du Score';

  @override
  String get dcTitleFoodEasy => 'Serpent Affamé';

  @override
  String get dcTitleFoodMedium => 'Mode Festin';

  @override
  String get dcTitleFoodHard => 'Insatiable';

  @override
  String get dcTitleSurvivalEasy => 'Survivant';

  @override
  String get dcTitleSurvivalMedium => 'Endurance';

  @override
  String get dcTitleSurvivalHard => 'Immortel';

  @override
  String get dcTitleGamesEasy => 'Joueur Occasionnel';

  @override
  String get dcTitleGamesMedium => 'Dévoué';

  @override
  String get dcTitleGamesHard => 'Accro du Serpent';

  @override
  String get dcTitleModeEasy => 'Amoureux du Classique';

  @override
  String get dcTitleModeMedium => 'Maître Zen';

  @override
  String get dcTitleModeHard => 'Démon de la Vitesse';

  @override
  String dcDescScore(Object target) {
    return 'Marquez au moins $target points en une seule partie';
  }

  @override
  String dcDescFood(Object target) {
    return 'Mangez $target aliments aujourd\'hui';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'Survivez $target secondes en une seule partie';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Jouez $target parties aujourd\'hui',
      one: 'Jouez 1 partie aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Jouez $target parties en mode $mode',
      one: 'Jouez 1 partie en mode $mode',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'Échauffement Hebdo';

  @override
  String get wqTitleScoreMedium => 'Réflexes Aiguisés';

  @override
  String get wqTitleScoreHard => 'Champion du Score';

  @override
  String get wqTitleFoodEasy => 'En-cas Hebdo';

  @override
  String get wqTitleFoodMedium => 'Vorace';

  @override
  String get wqTitleFoodHard => 'Sans Fond';

  @override
  String get wqTitleGamesEasy => 'Cinq par Semaine';

  @override
  String get wqTitleGamesMedium => 'Routine Installée';

  @override
  String get wqTitleGamesHard => 'Marathonien';

  @override
  String get wqTitleSurvivalEasy => 'Reptation de Deux Minutes';

  @override
  String get wqTitleSurvivalMedium => 'Reptation de Cinq Minutes';

  @override
  String get wqTitleSurvivalHard => 'Reptation de Dix Minutes';

  @override
  String get wqTitleTournament => 'Habitué des Tournois';

  @override
  String get wqTitleDailyEasy => 'Assidu du Quotidien';

  @override
  String get wqTitleDailyMedium => 'Expert du Quotidien';

  @override
  String wqDescScore(Object target) {
    return 'Marquez $target en une seule partie';
  }

  @override
  String wqDescFood(Object target) {
    return 'Mangez $target aliments cette semaine';
  }

  @override
  String wqDescGames(Object target) {
    return 'Jouez $target parties cette semaine';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'Survivez $target s en une seule partie';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Jouez $target parties de tournoi',
      one: 'Jouez 1 partie de tournoi',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'Terminez $target défis quotidiens cette semaine';
  }

  @override
  String tnNameDaily(Object date) {
    return 'Défi Quotidien - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'Championnat Hebdomadaire - Semaine $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'Grand Prix Mensuel - $monthYear';
  }

  @override
  String get tnDescDaily =>
      'Visez le meilleur score du défi de 24 heures du jour ! Les meilleurs gagnent pièces et gloire.';

  @override
  String get tnDescWeekly =>
      'L\'affrontement hebdomadaire ultime ! Défiez les meilleurs joueurs pour des récompenses massives.';

  @override
  String get tnDescMonthly =>
      'Le plus grand tournoi du mois ! Prouvez que vous êtes le vrai maître de Snake.';

  @override
  String tnRewardRank(Object rank) {
    return 'Rang $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'Récompense en pièces pour le rang $rank';
  }

  @override
  String get achTitleScore1500 => 'Élan';

  @override
  String get achDescScore1500 => 'Marquez 1 500 points en une seule partie';

  @override
  String get achTitleScore3000 => 'Sur la Lancée';

  @override
  String get achDescScore3000 => 'Marquez 3 000 points en une seule partie';

  @override
  String get achTitleScore7500 => 'Implacable';

  @override
  String get achDescScore7500 => 'Marquez 7 500 points en une seule partie';

  @override
  String get achTitleScore15000 => 'Chasseur Suprême';

  @override
  String get achDescScore15000 => 'Marquez 15 000 points en une seule partie';

  @override
  String get achTitleScore35000 => 'Esprit Machine';

  @override
  String get achDescScore35000 => 'Marquez 35 000 points en une seule partie';

  @override
  String get achTitleScore75000 => 'Au-delà du Mortel';

  @override
  String get achDescScore75000 => 'Marquez 75 000 points en une seule partie';

  @override
  String get achTitleScore250000 => 'Quart de Million';

  @override
  String get achDescScore250000 => 'Marquez 250 000 points en une seule partie';

  @override
  String get achTitleBeyondTime => 'Au-delà du Temps';

  @override
  String get achDescBeyondTime => 'Survivez 45 minutes en une seule partie';

  @override
  String get achTitleHourbound => 'Heure Pleine';

  @override
  String get achDescHourbound =>
      'Survivez une heure entière en une seule partie';

  @override
  String get achTitleSnakeDevotee => 'Dévot du Serpent';

  @override
  String get achDescSnakeDevotee => 'Jouez 2 500 parties';

  @override
  String get achTitleTenThousandClub => 'Club des Dix Mille';

  @override
  String get achDescTenThousandClub => 'Jouez 10 000 parties';

  @override
  String get achTitleZenVeteran => 'Vétéran Zen';

  @override
  String get achDescZenVeteran => 'Terminez 100 parties Zen';

  @override
  String get achTitleSpeedVeteran => 'Vétéran de la Vitesse';

  @override
  String get achDescSpeedVeteran => 'Terminez 100 parties de Défi Vitesse';

  @override
  String get achTitleMultifoodVeteran => 'Vétéran MultiNourriture';

  @override
  String get achDescMultifoodVeteran => 'Terminez 100 parties MultiNourriture';

  @override
  String get achTitleTimeattackVeteran => 'Vétéran du Contre-la-Montre';

  @override
  String get achDescTimeattackVeteran =>
      'Terminez 100 parties Contre-la-Montre';

  @override
  String get achTitleSurvivalVeteran => 'Vétéran de la Survie';

  @override
  String get achDescSurvivalVeteran => 'Terminez 100 parties de Survie';

  @override
  String get achTitlePumInitiate => 'Initié de la Folie';

  @override
  String get achDescPumInitiate => 'Terminez 10 parties de Folie de Power-ups';

  @override
  String get achTitlePumVeteran => 'Vétéran de la Folie';

  @override
  String get achDescPumVeteran => 'Terminez 100 parties de Folie de Power-ups';

  @override
  String get achTitlePerfectInitiate => 'Puriste';

  @override
  String get achDescPerfectInitiate => 'Terminez 10 parties en Partie Parfaite';

  @override
  String get achTitlePerfectVeteran => 'Discipline';

  @override
  String get achDescPerfectVeteran => 'Terminez 100 parties en Partie Parfaite';

  @override
  String get achTitleZen10000 => 'Débordement Zen';

  @override
  String get achDescZen10000 => 'Marquez 10 000 en mode Zen';

  @override
  String get achTitleSpeed5000 => 'Flou Total';

  @override
  String get achDescSpeed5000 => 'Marquez 5 000 en Défi Vitesse';

  @override
  String get achTitleMultifood10000 => 'Buffet Sans Fin';

  @override
  String get achDescMultifood10000 => 'Marquez 10 000 en MultiNourriture';

  @override
  String get achTitleTimeattack5000 => 'Course Contre la Montre';

  @override
  String get achDescTimeattack5000 => 'Marquez 5 000 en Contre-la-Montre';

  @override
  String get achTitlePum2000 => 'Sous Tension';

  @override
  String get achDescPum2000 => 'Marquez 2 000 en Folie de Power-ups';

  @override
  String get achTitlePerfect1000 => 'Course Impeccable';

  @override
  String get achDescPerfect1000 => 'Marquez 1 000 en mode Partie Parfaite';

  @override
  String get achTitleComboSingularity => 'Singularité de Combos';

  @override
  String get achDescComboSingularity =>
      'Réussissez un combo 200x en une seule partie';

  @override
  String get achTitleWorldSerpent => 'Serpent-Monde';

  @override
  String get achDescWorldSerpent =>
      'Faites grandir le serpent jusqu\'à 750 de longueur';

  @override
  String get achTitleLightspeed => 'Vitesse Lumière';

  @override
  String get achDescLightspeed =>
      'Atteignez le niveau 30 en jeu dans une même partie';

  @override
  String get achTitlePowerOverwhelming => 'Puissance Absolue';

  @override
  String get achDescPowerOverwhelming => 'Ramassez 5 000 power-ups au total';

  @override
  String get achTitleGreedIsGood => 'La Cupidité a du Bon';

  @override
  String get achDescGreedIsGood =>
      'Ramassez 25 power-ups Multiplicateur de Score';

  @override
  String get achTitleTimeBender => 'Maître du Ralenti';

  @override
  String get achDescTimeBender => 'Ramassez 25 power-ups Ralenti';

  @override
  String get achTitleGastronome => 'Gastronome';

  @override
  String get achDescGastronome => 'Mangez 100 000 aliments au total';

  @override
  String get achTitleLivingLegend => 'Légende Vivante';

  @override
  String get achDescLivingLegend => 'Cumulez 50 000 000 de points au total';

  @override
  String get achTitlePerpetualMotion => 'Mouvement Perpétuel';

  @override
  String get achDescPerpetualMotion => 'Série de 50 parties (30 s+ chacune)';

  @override
  String get achTitleImmaculate => 'Immaculé';

  @override
  String get achDescImmaculate => 'Réussissez 100 parties parfaites';

  @override
  String get achTitleFortnightFaithful => 'Fidèle Quinzaine';

  @override
  String get achDescFortnightFaithful => 'Jouez 14 jours consécutifs';

  @override
  String get achTitleSteadySnake => 'Serpent Constant';

  @override
  String get achDescSteadySnake => 'Survivez 30 s+ dans 100 parties';

  @override
  String get achTitleMarathonMonth => 'Esprit Marathon';

  @override
  String get achDescMarathonMonth => 'Survivez 30 s+ dans 1 000 parties';

  @override
  String get achTitleLunchtimeLegend => 'Légende du Déjeuner';

  @override
  String get achDescLunchtimeLegend => 'Terminez une partie entre midi et 14 h';

  @override
  String get legalNoticePrefix => 'En jouant, vous acceptez nos ';

  @override
  String get legalNoticeAnd => ' et ';

  @override
  String get dayOneReminderTitle => 'Ton serpent te réclame 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'Ton record est $score. Tu penses pouvoir le battre ?';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      'Une partie rapide ? Ton premier record t\'attend.';

  @override
  String get goTomorrowLabel => 'REVIENS DEMAIN';

  @override
  String goTomorrowReward(int coins, int day) {
    return 'Récupère $coins pièces au jour $day de ta série';
  }

  @override
  String get rvAteFoodUnknown => '🍎 A mangé de la nourriture';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ A ramassé un bonus';

  @override
  String get boardTall => 'Haut';

  @override
  String get boardTallDesc =>
      'Remplit l\'écran du téléphone — plus de place pour courir';

  @override
  String get boardTallPlus => 'Haut Plus';

  @override
  String get boardTallPlusDesc => 'Une arène plus grande au format téléphone';

  @override
  String get mpErrReadyTimeout =>
      'Les deux joueurs n\'étaient pas prêts à temps. Recherche d\'un nouveau match…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'Vérification · ${seconds}s';
  }

  @override
  String get mpLobbyWaitingOpponentReady =>
      'En attente que votre adversaire soit prêt…';

  @override
  String get gameDirectionalPad => 'Croix directionnelle';

  @override
  String get gameGoHome => 'Aller à l\'écran d\'accueil';

  @override
  String get gamePauseGame => 'Mettre en pause';

  @override
  String get gameResumeGame => 'Reprendre la partie';

  @override
  String get gameLeaveMatch => 'Quitter le match';

  @override
  String get gameSteerUp => 'Aller vers le haut';

  @override
  String get gameSteerDown => 'Aller vers le bas';

  @override
  String get gameSteerLeft => 'Aller à gauche';

  @override
  String get gameSteerRight => 'Aller à droite';

  @override
  String get mpTurnBlocked => 'Bloqué';

  @override
  String get insHudPause => 'Bouton pause';

  @override
  String get insHudPauseDesc =>
      'Pause ou reprise — en haut à droite de l’écran';

  @override
  String get insDpad => 'Croix directionnelle à l’écran';

  @override
  String get insDpadDesc =>
      'Boutons optionnels à quatre directions pour tourner, au lieu de glisser';

  @override
  String get insControlsNote =>
      'Activez ou désactivez les commandes à l\'écran, choisissez D-Pad, boutons de virage ou joystick et réglez le Déplacement par cases dans Réglages → Commandes — ou depuis le menu pause en pleine partie.';

  @override
  String get insVersus => 'Versus';

  @override
  String get insVersusOnline => '1c1 en ligne';

  @override
  String get insVersusOnlineDesc =>
      'Règles classiques, deux serpents, un plateau, en temps réel';

  @override
  String get insVersusQuick => 'Partie rapide';

  @override
  String get insVersusQuickDesc => 'Te trouve un adversaire automatiquement';

  @override
  String get insVersusRoom => 'Salon privé';

  @override
  String get insVersusRoomDesc =>
      'Crée un salon et partage le code, ou rejoins celui d’un ami';

  @override
  String get homeVersusCta => 'VERSUS';

  @override
  String get homeVersusSubtitle =>
      '1c1 Classique · Partie rapide ou invite un ami';

  @override
  String get hwVersusTitle => 'Affronte quelqu’un';

  @override
  String get hwVersusMsg =>
      'Versus, c’est du 1c1 Classique en ligne. La partie rapide te trouve un adversaire, ou crée un salon privé et invite un ami.';

  @override
  String get hwHelpTitle => 'Autre chose ?';

  @override
  String get hwHelpMsg =>
      'Règles, commandes et Versus sont expliqués ici. Les réglages sont juste à côté.';

  @override
  String get insOnPhone => 'Sur le téléphone';

  @override
  String get insOnKeyboard => 'Au clavier';

  @override
  String get settingsSectionYourGame => 'TON JEU';

  @override
  String get settingsStatisticsSubtitle => 'Toutes tes parties, comptées';

  @override
  String get settingsReplaysSubtitle => 'Revois tes parties enregistrées';

  @override
  String get homeTapToPlay => 'Touche pour jouer';

  @override
  String get homeTileMe => 'Moi';

  @override
  String get dchSectionChallenges => 'Défis';

  @override
  String dchRewardLine(int coins, int xp) {
    return '$coins pièces · $xp XP';
  }
}
