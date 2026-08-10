/// What the client should do with one queue-status answer.
enum QueueOutcome {
  /// Still queued. Keep waiting — this includes the case where nobody else is
  /// in the queue at all, which is NOT a failure: the server seats a house
  /// opponent once the wait passes its deadline.
  keepWaiting,

  /// The server matched us. Hand off to the lobby.
  resolved,

  /// The server has no queue entry for us any more — cancelled from another
  /// device, or swept. Leave the searching UI without claiming an error.
  notQueued,

  /// The server could not be reached, repeatedly. The only outcome the player
  /// should see as an error.
  unreachable,
}

/// The rule for reading queue-status polls, kept away from the cubit so it can
/// be tested without a hub, an audio service or a socket.
///
/// It exists because the previous rule was a client-side stopwatch: after 60
/// seconds the app declared "NO PLAYERS FOUND" and left. That was wrong in
/// both directions. An empty queue is not a failure — quick match is
/// guaranteed to resolve, with a bot if it comes to that — and the client
/// cannot know when to give up anyway: a match created 34 seconds after
/// queueing was seen sitting in the database, matched, while the app timed
/// itself out and walked away from it.
///
/// So there is exactly one failure condition left, and it is about the
/// *transport*, not the queue: we asked the server several times in a row and
/// could not reach it.
class QueueResolution {
  QueueResolution({this.failuresBeforeUnreachable = 5})
    : assert(failuresBeforeUnreachable > 1,
          'one failed request is a blip, not an outage — erroring on it '
          'would be the old give-up-too-early bug in a new costume');

  /// Consecutive failed requests tolerated before reporting [QueueOutcome.unreachable].
  final int failuresBeforeUnreachable;

  int _consecutiveFailures = 0;

  int get consecutiveFailures => _consecutiveFailures;

  /// Feed one poll result. [status] is null when the request itself failed.
  QueueOutcome apply(Map<String, dynamic>? status) {
    if (status == null) {
      _consecutiveFailures++;
      return _consecutiveFailures >= failuresBeforeUnreachable
          ? QueueOutcome.unreachable
          : QueueOutcome.keepWaiting;
    }

    // Any answer at all proves the server is reachable, so a run of failures
    // that never reached the threshold is forgotten rather than accumulating
    // across an entire search.
    _consecutiveFailures = 0;

    switch (status['state']?.toString()) {
      case 'matched':
        // A matched state with no game is not usable — treat it as still
        // waiting rather than sending the player to a room that has no id.
        final gameId = status['gameId']?.toString();
        return (gameId == null || gameId.isEmpty)
            ? QueueOutcome.keepWaiting
            : QueueOutcome.resolved;
      case 'none':
        return QueueOutcome.notQueued;
      default:
        return QueueOutcome.keepWaiting;
    }
  }

  /// The server's promised deadline, when it sent one.
  static int? deadlineFrom(Map<String, dynamic>? status) =>
      (status?['resolvesWithinSeconds'] as num?)?.toInt();
}
