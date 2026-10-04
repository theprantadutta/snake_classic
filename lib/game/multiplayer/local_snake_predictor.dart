import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

/// One steering input that has been sent and not yet seen applied.
class PendingInput {
  const PendingInput(this.direction, this.etaTick);

  final Direction direction;

  /// The first server tick this input is expected to arrive in time for.
  ///
  /// The server applies an input at the first tick that runs after it lands,
  /// so an input sent late in a tick misses the next one and is applied a tick
  /// later. Predicting it a tick early is the single most visible way to get
  /// prediction wrong: the snake turns, the next snapshot says it went
  /// straight, and it is yanked back a cell.
  final int etaTick;

  @override
  String toString() => 'PendingInput(${direction.name} @$etaTick)';
}

/// What a snapshot did to the prediction.
enum SnapshotFit {
  /// The first snapshot this predictor has seen (or the first after a reset).
  first,

  /// The tick right after the base — the normal case. Pending inputs were
  /// reconciled against the direction the server committed.
  advanced,

  /// The same tick again (a MatchResumed reply racing the broadcast). Nothing
  /// moved.
  duplicate,

  /// An older tick than the base. Ignored entirely: drawing it would run the
  /// snake backwards, and folding it in would undo inputs already confirmed.
  stale,

  /// A jump of more than one tick (reconnect). Too much happened in between
  /// to say which inputs the server applied, so the pending ones are dropped
  /// and the server's word is taken as it stands.
  resynced,

  /// The tick went backwards by more than any reordering could explain — a
  /// new match whose clock restarted. Treated like [first].
  reset,
}

/// The local snake as the board should draw it: gliding from the latest
/// authoritative body to where the server will put it at the next tick.
class LocalPrediction {
  const LocalPrediction({
    required this.baseTick,
    required this.from,
    required this.to,
    required this.heading,
    required this.facing,
    required this.stalled,
  });

  /// Tick of the authoritative snapshot [from] was taken from.
  final int baseTick;

  /// The local body exactly as the server last confirmed it, head first.
  final List<Position> from;

  /// The body predicted for `baseTick + 1`, head first. Equal to [from] when
  /// [stalled].
  final List<Position> to;

  /// Direction of the predicted step.
  final Direction heading;

  /// Where the head should look: the newest accepted input, even when the
  /// server will not act on it until the tick after next. This is what
  /// answers a swipe on the very frame it lands.
  final Direction facing;

  /// The predicted step would have killed the snake (wall, own body, the
  /// rival's body). Death is never predicted — the server decides it — so the
  /// snake holds at [from] until the snapshot says what happened.
  final bool stalled;
}

/// Client-side prediction for the LOCAL player's snake in an online match.
///
/// Matches are server-authoritative and the server is ~190ms away, so a turn
/// drawn only from snapshots appears a tick or two after the swipe. This
/// class predicts the local snake ONE tick ahead of the latest snapshot by
/// replaying the inputs the server has not yet applied through the server's
/// own rules (see `MatchRoom.AdvanceTick` / `QueueInput` in the backend):
///
/// * one buffered input is committed per tick; a reversal of the committed
///   direction is skipped and draining continues; a repeat of it stops the
///   drain; the buffer holds [serverBufferDepth] and drops the oldest;
/// * the head steps one cell; the tail is dropped unless the new head is on
///   the food.
///
/// It is purely visual. Nothing here touches scores, food or outcomes, the
/// rival is never predicted, and death is never predicted: a step into a
/// wall, the snake's own body or the rival's body holds the snake still
/// instead ([LocalPrediction.stalled]).
///
/// The protocol has no input acknowledgement, so which inputs the server has
/// applied is inferred from the direction each snapshot commits. That is
/// exact as long as every pending input is a real turn relative to the one
/// before it — which the client enforces by refusing repeats and reversals
/// against [lastPendingDirection] — because the server then commits the
/// first pending input on the first tick it has arrived for. Anything the
/// inference cannot explain drops the pending inputs and trusts the server.
///
/// Time is passed in, never read, so every behaviour is a deterministic
/// function of the inputs and snapshots a test feeds it.
class LocalSnakePredictor {
  LocalSnakePredictor({
    this.defaultRoundTrip = const Duration(milliseconds: 180),
  });

  /// Mirrors `MatchRoom.InputBufferDepth`.
  static const int serverBufferDepth = 2;

  /// Bound on how many unconfirmed inputs are remembered. Beyond the server's
  /// buffer only to tolerate a tick confirming an input while newer ones are
  /// already queued behind it.
  static const int maxPending = 4;

  /// An input still unconfirmed this many ticks after its expected tick is
  /// assumed lost (refused server-side, or never delivered) and forgotten, so
  /// it cannot hold the reversal reference hostage.
  static const int lateTicksBeforeExpiry = 3;

  /// A tick this far below the base is a new match, not a reordered packet.
  static const int resetTickGap = 20;

  /// Used for the arrival estimate until the first input has been timed.
  final Duration defaultRoundTrip;

  /// Weight of each new round-trip sample.
  static const double _rttSmoothing = 0.25;

  MatchSnapshot? _base;
  Duration _baseReceivedAt = Duration.zero;
  int _boardSize = 20;
  String _userId = '';
  final List<PendingInput> _pending = [];
  double? _rttMs;
  LocalPrediction? _prediction;

  int _checked = 0;
  int _mispredicted = 0;

  /// The latest authoritative snapshot the prediction is built on.
  MatchSnapshot? get base => _base;

  /// The local snake as it should be drawn, or null when there is nothing to
  /// predict (no snapshot yet, local player absent or dead).
  LocalPrediction? get prediction => _prediction;

  /// Inputs sent and not yet seen applied, oldest first.
  List<PendingInput> get pending => List.unmodifiable(_pending);

  /// The direction the snake will be heading once every pending input has
  /// applied — the reference a new input's repeat/reversal check must use,
  /// because it is what the server will validate it against.
  Direction? get lastPendingDirection =>
      _pending.isEmpty ? null : _pending.last.direction;

  /// Smoothed send-to-acknowledge time for a hub call.
  Duration get roundTrip => _rttMs == null
      ? defaultRoundTrip
      : Duration(microseconds: (_rttMs! * 1000).round());

  /// How many predictions have been compared with the snapshot they
  /// predicted, and how many of those were wrong. For the match-end log.
  int get predictionsChecked => _checked;
  int get mispredictions => _mispredicted;

  /// Forget everything. Called whenever a match starts or ends.
  void reset() {
    _base = null;
    _baseReceivedAt = Duration.zero;
    _pending.clear();
    _prediction = null;
    _checked = 0;
    _mispredicted = 0;
    // The round trip is a property of the connection, not of the match, so
    // it survives — the next match's first input benefits from it.
  }

  /// Fold in one measured round trip (send → server acknowledges).
  void recordRoundTrip(Duration sample) {
    final ms = sample.inMicroseconds / 1000.0;
    if (ms <= 0 || ms > 5000) return;
    _rttMs = _rttMs == null ? ms : _rttMs! + (ms - _rttMs!) * _rttSmoothing;
  }

  /// The first tick an input sent at [sentAt] can arrive in time for.
  ///
  /// The server ticks once per `tick_ms`, and snapshot N reaches us one
  /// downlink after tick N ran. An input sent `e` after that arrival lands an
  /// uplink later, so — with `R` the round trip — it is in time for tick N+j
  /// for the smallest j with `e + R < j·tick_ms`.
  int etaFor(Duration sentAt) {
    final base = _base;
    if (base == null) return 0;
    final tickMs = base.tickMs > 0 ? base.tickMs : 300;
    final sinceBaseMs = (sentAt - _baseReceivedAt).inMicroseconds / 1000.0;
    final elapsed = sinceBaseMs < 0 ? 0.0 : sinceBaseMs;
    final rttMs = roundTrip.inMicroseconds / 1000.0;
    return base.tick + ((elapsed + rttMs) / tickMs).floor() + 1;
  }

  /// Record an input the client accepted and sent at [sentAt].
  void recordInput(Direction direction, {required Duration sentAt}) {
    if (_base == null) return;
    if (_pending.length >= maxPending) _pending.removeAt(0);
    _pending.add(PendingInput(direction, etaFor(sentAt)));
    _repredict();
  }

  /// Fold in an authoritative snapshot received at [receivedAt].
  SnapshotFit onSnapshot(
    MatchSnapshot snapshot, {
    required String userId,
    required int boardSize,
    required Duration receivedAt,
  }) {
    _userId = userId;
    _boardSize = boardSize > 0 ? boardSize : _boardSize;

    final base = _base;
    final SnapshotFit fit;
    if (base == null) {
      fit = SnapshotFit.first;
      _pending.clear();
    } else if (snapshot.tick == base.tick) {
      fit = SnapshotFit.duplicate;
    } else if (snapshot.tick < base.tick - resetTickGap) {
      fit = SnapshotFit.reset;
      reset();
    } else if (snapshot.tick < base.tick) {
      return SnapshotFit.stale;
    } else if (snapshot.tick == base.tick + 1) {
      fit = SnapshotFit.advanced;
      _scorePrediction(snapshot);
      _reconcile(base, snapshot);
    } else {
      fit = SnapshotFit.resynced;
      _pending.clear();
    }

    if (fit != SnapshotFit.duplicate) _baseReceivedAt = receivedAt;
    _base = snapshot;
    _repredict();
    return fit;
  }

  /// Did the previous prediction say what this snapshot says?
  void _scorePrediction(MatchSnapshot snapshot) {
    final predicted = _prediction;
    if (predicted == null || predicted.stalled) return;
    if (predicted.baseTick != snapshot.tick - 1) return;
    final me = snapshot.playerByUserId(_userId);
    if (me == null || !me.alive) return;
    _checked++;
    if (!_sameBody(predicted.to, me.body)) _mispredicted++;
  }

  /// Work out which pending inputs the server applied between [before] and
  /// [after], one tick apart.
  void _reconcile(MatchSnapshot before, MatchSnapshot after) {
    final was = before.playerByUserId(_userId);
    final now = after.playerByUserId(_userId);
    if (was == null || now == null || !now.alive) {
      _pending.clear();
      return;
    }

    if (now.direction != was.direction) {
      // The server committed a turn. It can only be one we sent; everything
      // up to and including it has left the server's queue (anything before
      // it was dropped by the buffer or skipped as a reversal there).
      final applied = _pending.indexWhere((p) => p.direction == now.direction);
      if (applied < 0) {
        _pending.clear();
      } else {
        _pending.removeRange(0, applied + 1);
      }
    }
    // Same direction as before: with every pending input a real turn, the
    // first one would have committed had it arrived, so nothing arrived yet
    // and nothing is consumed.

    final expired = _pending.lastIndexWhere(
      (p) => p.etaTick + lateTicksBeforeExpiry < after.tick,
    );
    if (expired >= 0) _pending.removeRange(0, expired + 1);
  }

  void _repredict() {
    final base = _base;
    final me = base?.playerByUserId(_userId);
    if (base == null || me == null || !me.alive || me.body.isEmpty) {
      _prediction = null;
      return;
    }

    final nextTick = base.tick + 1;
    final arrived = [
      for (final p in _pending)
        if (p.etaTick <= nextTick) p.direction,
    ];
    final heading = commitDirection(me.direction, arrived);
    final step = stepBody(
      body: me.body,
      direction: heading,
      food: base.food,
      boardSize: _boardSize,
      rivals: [
        for (final p in base.players)
          if (p.userId != _userId && p.alive) p.body,
      ],
    );

    _prediction = LocalPrediction(
      baseTick: base.tick,
      from: me.body,
      to: step ?? me.body,
      heading: heading,
      facing: lastPendingDirection ?? heading,
      stalled: step == null,
    );
  }

  /// The direction the server commits at a tick, given its committed
  /// [current] direction and the inputs queued for that tick, oldest first.
  ///
  /// A straight transcription of `MatchRoom.QueueInput` (drop the oldest
  /// beyond the buffer depth) and the drain loop in `AdvanceTick`.
  static Direction commitDirection(Direction current, List<Direction> queued) {
    final buffer = queued.length > serverBufferDepth
        ? queued.sublist(queued.length - serverBufferDepth)
        : queued;
    for (final input in buffer) {
      if (input != current.opposite && input != current) return input;
      if (input == current) return current; // harmless no-op, stop draining
      // A reversal: skipped, keep draining.
    }
    return current;
  }

  /// The body after one step in [direction], or null when the step would be
  /// fatal by the server's rules — which this never predicts.
  ///
  /// Growth and self-collision follow `MatchRoom.AdvanceTick`: the tail is
  /// dropped before the self check, so stepping into the cell the tail is
  /// leaving is safe. A rival's body blocks except its tail, which is about
  /// to move; the rival's own next move is not guessed at.
  static List<Position>? stepBody({
    required List<Position> body,
    required Direction direction,
    required Position food,
    required int boardSize,
    List<List<Position>> rivals = const [],
  }) {
    if (body.isEmpty) return null;
    final head = body.first.move(direction);
    if (!head.isWithinBounds(boardSize, boardSize)) return null;

    final grows = head == food;
    final next = [head, ...(grows ? body : body.sublist(0, body.length - 1))];
    if (next.skip(1).contains(head)) return null;

    for (final rival in rivals) {
      if (rival.isEmpty) continue;
      final blocking = rival.sublist(0, rival.length - 1);
      if (blocking.contains(head)) return null;
    }
    return next;
  }

  static bool _sameBody(List<Position> a, List<Position> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
