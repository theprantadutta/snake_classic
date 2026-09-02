/// Why a quick-match search ended without a match.
enum MatchmakingFailure {
  /// The server could not be reached, repeatedly (see [QueueResolution]).
  unreachable,

  /// The device lost its connection while searching and did not get it back
  /// in time — or got it back and could not re-enter the queue.
  connectionLost,

  /// The server broke its own promise by a wide margin. It quotes a deadline
  /// (35s) by which it seats a house opponent; well past that, waiting longer
  /// is not going to help and the player deserves a way out that is not
  /// force-quitting the app.
  timedOut,
}

/// What the watch wants the cubit to do after one tick.
enum MatchmakingWatchVerdict { keepWaiting, timedOut, connectionLost }

/// The client-side safety net around the server's promise to resolve every
/// quick-match queue.
///
/// The server is the authority on WHEN a match happens: it prefers a human for
/// 30 seconds and then seats a house opponent, so the client deliberately does
/// not run a "no players found" stopwatch. What the client CAN judge is when
/// waiting has stopped being useful:
///
///  * the device has been offline for longer than a blip — the server deletes
///    the queue row the moment the socket drops, so there is nothing left to
///    wait for;
///  * the search has run far past the server's own deadline — either the
///    sweep is not running or its answer is never going to reach this client.
///
/// It also budgets the automatic re-queue: when the server says "you are not
/// in the queue" mid-search (socket dropped and reconnected, server restarted),
/// the cubit silently rejoins — but only a couple of times, so a server that
/// keeps forgetting us does not turn into a silent forever-loop either.
///
/// Pure: no timers, no sockets. Fed one tick at a time so it can be tested.
class MatchmakingWatch {
  MatchmakingWatch({
    this.hardDeadlineSeconds = 60,
    this.offlineGraceSeconds = 10,
    this.maxRequeues = 2,
  }) : assert(hardDeadlineSeconds > 35,
          'the hard deadline must sit well past the 35s the server promises, '
          'or the client is back to giving up on matches the server is '
          'about to create');

  /// Wall-clock seconds since the search started after which the client
  /// stops waiting regardless of what the server says. Wide on purpose: the
  /// server promises 35s, and the Hangfire scheduler behind that runs at 15s
  /// granularity, so anything under ~50s risks abandoning a match that is
  /// seconds from existing.
  final int hardDeadlineSeconds;

  /// How long the device may be offline before the search is declared lost.
  /// A Wi-Fi to mobile handover takes a second or two; ten is a real outage.
  final int offlineGraceSeconds;

  /// How many times the cubit may silently re-enter the queue after the
  /// server reports it has no entry for us.
  final int maxRequeues;

  int _requeues = 0;
  int? _offlineSinceSecond;

  int get requeuesUsed => _requeues;

  /// Whether the device is currently inside the offline grace window.
  bool get isOffline => _offlineSinceSecond != null;

  /// Feed one tick. [elapsedSeconds] is wall-clock time since the search
  /// began (NOT reset by a re-queue — the deadline is for the whole search).
  MatchmakingWatchVerdict onTick(int elapsedSeconds, {required bool online}) {
    if (online) {
      _offlineSinceSecond = null;
    } else {
      _offlineSinceSecond ??= elapsedSeconds;
      if (elapsedSeconds - _offlineSinceSecond! >= offlineGraceSeconds) {
        return MatchmakingWatchVerdict.connectionLost;
      }
    }

    if (elapsedSeconds >= hardDeadlineSeconds) {
      return MatchmakingWatchVerdict.timedOut;
    }
    return MatchmakingWatchVerdict.keepWaiting;
  }

  /// The server has no queue entry for us mid-search. Returns true if the
  /// cubit should rejoin (and records the attempt), false when the budget is
  /// spent and the search should be reported as lost instead.
  bool takeRequeue() {
    if (_requeues >= maxRequeues) return false;
    _requeues++;
    return true;
  }
}
