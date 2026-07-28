// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'LANGUAGE';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageSystemDefaultSubtitle => 'Follow your device language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get mpVictory => 'VICTORY!';

  @override
  String get mpDraw => 'DRAW';

  @override
  String get mpDefeat => 'DEFEAT';

  @override
  String get mpYou => 'You';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Opponent';

  @override
  String get mpBackToLobby => 'Back to Lobby';

  @override
  String get mpPlayAgain => 'Play Again';

  @override
  String get mpTimeUpDraw => 'Time\'s up — dead even!';

  @override
  String get mpTimeUpYouWon => 'Time\'s up — you had the higher score.';

  @override
  String get mpTimeUpYouLost =>
      'Time\'s up — your opponent had the higher score.';

  @override
  String get mpMutualCrashDraw => 'Both snakes crashed — it\'s a tie!';

  @override
  String get mpMutualCrashYouWon =>
      'Both snakes crashed — your score decided it.';

  @override
  String get mpMutualCrashYouLost =>
      'Both snakes crashed — their score decided it.';

  @override
  String get mpMatchCancelled => 'The match was cancelled.';

  @override
  String get mpLastSnakeStanding =>
      'Your opponent crashed. Last snake standing!';

  @override
  String get mpDeathWall => 'You crashed into the wall.';

  @override
  String get mpDeathSelf => 'You crashed into yourself.';

  @override
  String get mpDeathOpponent => 'You crashed into your opponent.';

  @override
  String get mpDeathHeadOn => 'Head-on collision!';

  @override
  String get mpDeathForfeit => 'Disconnected too long — match forfeited.';

  @override
  String get mpBetterLuck => 'Better luck next time!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count coins',
      one: '+$count coin',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Leave Game?';

  @override
  String get mpLeaveGameBody =>
      'The match keeps running on the server — leaving forfeits it.';

  @override
  String get mpLeave => 'Leave';

  @override
  String get mpReconnecting => 'RECONNECTING…';

  @override
  String get mpReconnectingBody => 'The match is still running on the server.';

  @override
  String get mpGetReady => 'GET READY';

  @override
  String get mpDroppingIntoArena => 'Dropping you into the arena…';

  @override
  String get mpWaitingPlayer => 'Waiting…';

  @override
  String get mpOut => 'OUT';

  @override
  String get mpLength => 'LENGTH';

  @override
  String get mpSwipe => 'Swipe';

  @override
  String get mpReconnectingInline => 'reconnecting…';
}
