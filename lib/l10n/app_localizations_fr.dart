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
}
