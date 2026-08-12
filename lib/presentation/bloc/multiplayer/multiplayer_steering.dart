import 'package:snake_classic/models/input_result.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';
import 'package:snake_classic/utils/direction.dart';

/// Whether a multiplayer player may steer, and what becomes of one input.
///
/// This is the rule on its own, away from the streams and services: it is the
/// same answer the cubit gives `changeDirection` and the answer the D-pad
/// needs in order to decide whether to look usable at all. Those two used to
/// disagree — the cubit refused input from a dead or reconnecting player
/// while the control still lit up under their thumb and the screen played a
/// success cue — which is exactly the kind of divergence a shared predicate
/// prevents.
///
/// Everything here is a pure function of state the caller already holds, so
/// each branch can be tested without a hub connection.
class MultiplayerSteering {
  const MultiplayerSteering._();

  /// Can this player steer right now?
  ///
  /// Requires a live match, a snapshot to steer within, no error condition, a
  /// known local player, and that player still alive. A reconnecting client
  /// fails on the snapshot or the error; a dead one on [MatchPlayerState.alive].
  static bool canSteer({
    required MultiplayerStatus status,
    required MatchSnapshot? snapshot,
    required MultiplayerError? errorCode,
    required String? currentUserId,
  }) {
    if (status != MultiplayerStatus.playing) return false;
    if (snapshot == null) return false;
    if (errorCode != null) return false;
    if (currentUserId == null) return false;

    final me = snapshot.playerByUserId(currentUserId);
    return me != null && me.alive;
  }

  /// What happens to [requested].
  ///
  /// [intent] is the direction already sent and not yet reflected in a
  /// snapshot; [committed] is what the server last had this snake doing.
  /// Repeats and reversals are refused on their merits — the player did
  /// something and the game said no — while an input from someone who could
  /// not steer at all is [InputResult.ignored], because there is nothing to
  /// tell them about an input the match was never in a position to receive.
  static InputResult resolve({
    required bool canSteerNow,
    required Direction requested,
    required Direction? intent,
    required Direction committed,
  }) {
    if (!canSteerNow) return InputResult.ignored;

    // Repeated identical swipes and keyboard auto-repeat would each cost a
    // hub message for a no-op.
    if (requested == intent) return InputResult.rejected;

    // The server drops reversals anyway; measure against the intent when one
    // is outstanding, since that is the direction the snake is about to have.
    if (requested == (intent ?? committed).opposite) return InputResult.rejected;

    return InputResult.accepted;
  }
}
