import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';

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
  /// error it expires the local input echo: each tick commits at most one
  /// input, so the committed direction in the snapshot is now the reversal
  /// reference, and a dropped input must not leave an intent behind that
  /// blocks its opposite forever.
  static MultiplayerState afterSnapshot(
    MultiplayerState current, {
    required MatchSnapshot snapshot,
    required int boardSize,
  }) {
    return current.copyWith(
      status: MultiplayerStatus.playing,
      snapshot: snapshot,
      boardSize: boardSize,
      isLoading: false,
      clearIntentDirection: true,
      clearRejectedInput: true,
      clearError: true,
    );
  }
}
