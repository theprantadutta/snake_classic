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
}
