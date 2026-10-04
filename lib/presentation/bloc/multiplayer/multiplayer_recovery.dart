import 'package:snake_classic/game/multiplayer/local_snake_predictor.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';
import 'package:snake_classic/utils/direction.dart';

/// What the server telling us the match is alive does to a stale error.
///
/// [MultiplayerState.errorCode] survives `copyWith` unless something asks for
/// it to be cleared, and the two paths that put the client back into
/// `playing` — a fresh engine snapshot and a game update whose status is
/// playing — did not ask. So an error raised during a dropped connection
/// outlived the recovery it described, and because steering refuses on any
/// error, the player watched a match run that they could no longer steer in.
///
/// The rule is narrow on purpose. Only proof that the match is CURRENTLY
/// running clears the error. A lobby, a countdown, a finish, a reconnect in
/// progress, or an idle client proves nothing about a failure that is still
/// outstanding, and must leave it exactly where it is.
class MultiplayerRecovery {
  const MultiplayerRecovery._();

  /// Does this game status prove the match is live right now?
  static bool provesMatchLive(MultiplayerGameStatus status) =>
      status == MultiplayerGameStatus.playing;

  /// The state after an authoritative engine tick.
  ///
  /// A snapshot is the strongest proof there is — the server is simulating
  /// this match and just sent us a frame of it. Alongside clearing the stale
  /// error it replaces the local input echo with [intentDirection]: the
  /// newest input the predictor still has in flight after reconciling this
  /// snapshot, or null when every input has applied.
  ///
  /// The echo used to be cleared outright on every snapshot. At a ~190ms
  /// round trip an input is usually still in flight when the next snapshot
  /// lands, so the reversal reference fell back to a heading the snake was
  /// about to leave: the second half of a quick corner was refused, while a
  /// reversal of the pending turn was sent and silently dropped. The
  /// predictor keeps the guarantee that motivated the reset — an input the
  /// server never applies expires after a few ticks, so it cannot block its
  /// opposite forever.
  static MultiplayerState afterSnapshot(
    MultiplayerState current, {
    required MatchSnapshot snapshot,
    required int boardSize,
    Direction? intentDirection,
    LocalPrediction? localPrediction,
  }) {
    return current.copyWith(
      status: MultiplayerStatus.playing,
      snapshot: snapshot,
      boardSize: boardSize,
      isLoading: false,
      intentDirection: intentDirection,
      clearIntentDirection: intentDirection == null,
      localPrediction: localPrediction,
      clearLocalPrediction: localPrediction == null,
      clearRejectedInput: true,
      clearError: true,
    );
  }
}
