/// What happened to one steering input, locally.
///
/// Swipe, D-pad and keyboard all go through one method that returns this, so
/// the three entry points cannot drift into three different ideas of what
/// "worked" means — which is exactly what had happened: multiplayer gave an
/// accepted input two haptics (one from the cubit, one from the screen) while
/// a rejected or ignored one still got a positive click and a success
/// animation.
///
/// The domain layer owns haptics. The screen reads the result and animates the
/// matching cue, and nothing else.
///
/// "Locally" is the operative word for multiplayer. Acceptance here means the
/// input passed the client's own rules and was sent; it is not a claim that
/// the server has acted on it. Waiting for a round trip before acknowledging a
/// turn would make the controls feel broken on any real connection, and the
/// authoritative snapshot remains the only thing that draws the game.
enum InputResult {
  /// Taken and acted on: queued locally, or sent to the server.
  accepted,

  /// Understood and refused — a reversal into your own neck, or a repeat of
  /// the direction already queued. The player did something; the game said no.
  /// Worth a distinct cue, because silence reads as dropped input.
  rejected,

  /// Not applicable at all: the game is not running, the player is dead, the
  /// match is reconnecting, or there is no snapshot yet. No cue of any kind —
  /// there is nothing to tell the player about an input the game was never in
  /// a position to receive.
  ignored,
}

extension InputResultX on InputResult {
  bool get isAccepted => this == InputResult.accepted;
  bool get isRejected => this == InputResult.rejected;

  /// Whether the screen should show any visual cue at all. An ignored input
  /// gets nothing: showing the "accepted" swipe indicator to a dead player was
  /// one of the reported defects.
  bool get hasFeedback => this != InputResult.ignored;
}
