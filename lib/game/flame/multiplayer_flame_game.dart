import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/game/flame/components/game_particles_component.dart';
import 'package:snake_classic/game/multiplayer/local_snake_predictor.dart';
import 'package:snake_classic/game/multiplayer/snake_glide.dart';
import 'package:snake_classic/game/multiplayer/snapshot_playout.dart';
import 'package:snake_classic/game/multiplayer/tick_clock.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/game/flame/rendering/particles.dart'
    show ParticleConfig;
import 'package:snake_classic/game/flame/rendering/multiplayer_board_painter.dart'
    show MultiplayerBoardPainter, MultiplayerGridBackgroundPainter;

/// Flame engine root for multiplayer gameplay (server-authoritative 1v1).
///
/// The board receives every authoritative [MatchSnapshot] through
/// [syncState] and draws it smoothly even though positions arrive only a few
/// times a second, and never at a steady rhythm. Nothing is simulated here.
///
/// Motion is driven by render clocks that advance on their own at the
/// server's tick rate ([TickClock]) — never by when packets land. Restarting
/// the glide on every arrival, as this used to, turned network jitter
/// straight into motion: an early snapshot cut the glide short (a skip), a
/// late one let it finish and sit (stop-and-go).
///
/// * Your own snake is drawn from the [prediction] at [localRenderTick]: a
///   clock phase-locked to the arrivals (the snapshot for tick N lands about
///   when the clock reads N), walking the confirmed-then-predicted path at
///   most [maxLocalLead] ticks past the newest snapshot. While a snapshot is
///   late it carries on into the predicted step after next rather than
///   stopping, and it slows into the end of the path instead of hitting it.
///   Whenever the path changes under the snake — a swipe re-aiming it, a
///   snapshot correcting a misprediction — [CorrectionBlend] eases the
///   difference out on top of the moving path.
/// * Every other snake (the rival) is played back from a [SnapshotPlayout]
///   buffer a little over a tick behind the newest snapshot, so it always
///   glides between two snapshots that have both arrived.
/// * The food and its burst follow the snake that ate it: a bite is shown,
///   and the food moves, when the eater's clock reaches the tick of the
///   snapshot that contains it — not when that snapshot arrives, which for
///   the rival is a tick before it gets there. Your own bites also call
///   [onLocalFoodEaten] at that moment, for the chirp and the screen juice.
class MultiplayerFlameGame extends FlameGame {
  MultiplayerFlameGame({
    required MatchSnapshot snapshot,
    required this.currentUserId,
    required this.boardSize,
    required this.theme,
    this.prediction,
    this.onLocalFoodEaten,
  }) : snapshot = snapshot,
       displayedFood = snapshot.food {
    _startMatch(snapshot);
    _rebuildLocalPath();
  }

  /// The newest snapshot received.
  MatchSnapshot snapshot;

  /// The predicted local snake for [snapshot]'s tick, or null to draw the
  /// local snake exactly as the snapshot has it (dead, absent, or no
  /// prediction yet).
  LocalPrediction? prediction;

  /// Called when one of your own bites is shown (see the class notes).
  VoidCallback? onLocalFoodEaten;

  /// What the local snake looks like this frame, in grid units (cell centres
  /// at +0.5), and where its head looks. Null when [prediction] is not in
  /// use and the painter draws the snapshot.
  List<Offset>? localCells;
  Direction? localFacing;

  /// How every other snake is drawn this frame, by player index.
  Map<int, SnakePose> remotePoses = const {};

  /// Where the food is drawn. Trails [snapshot] while the bite that moved
  /// it has not been shown yet.
  Position displayedFood;

  final String currentUserId;
  final int boardSize;
  GameTheme theme;

  /// Localized "You" label for the local snake's name tag. The painter has
  /// no BuildContext, so the hosting widget pushes the translation in on
  /// every build (see MultiplayerFlameBoard).
  String youLabel = 'You';

  /// The furthest the local snake is ever drawn past the newest snapshot,
  /// in ticks. It nominally peaks at one, just before the next snapshot
  /// lands; the rest is room for a late snapshot before the snake has to
  /// slow down for it.
  static const double maxLocalLead = 1.35;

  /// How many confirmed local bodies are kept, to draw from when the clock
  /// is a little behind the newest snapshot (after a burst).
  static const int _localHistoryTicks = 4;

  /// A snapshot tick this far below the newest one is a new match.
  static const int _resetTickGap = 20;

  /// Phase-locked to the arrivals with no lag: the snapshot for tick N
  /// lands about when it reads N. Up to two ticks behind (a long silence,
  /// then a burst) it catches up by running faster rather than jumping;
  /// the confirmed history covers that far back.
  final TickClock _localClock = TickClock(softZone: .3, resyncThreshold: 2);
  final SnapshotPlayout _playout = SnapshotPlayout();
  final Map<int, List<Position>> _localHistory = {};
  _LocalPath? _localPath;
  _LocalPath? _drawnLocalPath;
  int _seenResyncs = 0;
  final CorrectionBlend _localBlend = CorrectionBlend();
  final List<_FoodEvent> _foodEvents = [];

  double _elapsed = 0;

  GameParticlesComponent? _particles;

  /// Where your own snake is drawn on the server's tick axis.
  double get localRenderTick => _localClock.position;

  /// Where every other snake is drawn on the server's tick axis.
  double get remoteRenderTick => _playout.renderTick;

  /// How far behind the newest snapshot the rival is played back, in ticks.
  double get remoteDelay => _playout.delay;

  double get worldSize => boardSize * GameConstants.cellSize;

  /// Flame paints this behind the world before anything renders. The
  /// default is black, which is exactly the flat black board this used to
  /// show while the viewport was still settling. The Living Board colour,
  /// so the first frames match the board painted over it.
  @override
  Color backgroundColor() => LBPalette.of(theme).board;

  /// Pulse in [0.9, 1.1] over a 2s period (matches the legacy pulse tween).
  double get pulse {
    final p = (_elapsed % 2.0) / 2.0;
    return 0.9 + 0.2 * (1 - (2 * p - 1).abs());
  }

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: worldSize,
      height: worldSize,
    );
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    _particles = GameParticlesComponent();
    await world.addAll([_MultiplayerBoardComponent(), _particles!]);
  }

  /// Push a snapshot, the local prediction and the theme into the game.
  ///
  /// Call it for EVERY snapshot as it arrives — the render clocks are
  /// steered by arrival times and the rival is played back from the
  /// sequence, so a snapshot coalesced into the next rebuild is a hole in
  /// both. Repeating the current snapshot (a rebuild) is harmless.
  void syncState({
    required MatchSnapshot snapshot,
    required GameTheme theme,
    LocalPrediction? prediction,
  }) {
    this.theme = theme;
    final fresh = !identical(snapshot, this.snapshot);
    // A stale snapshot comes with a stale prediction: ignore both.
    if (fresh && !_ingest(snapshot)) return;
    // So does a prediction for a tick already superseded.
    if (prediction != null && prediction.baseTick < this.snapshot.tick) {
      prediction = this.prediction;
    }
    final predictionChanged = !identical(prediction, this.prediction);
    this.prediction = prediction;
    if (fresh || predictionChanged) _rebuildLocalPath();
  }

  /// Fold a newly received snapshot in. False when it was ignored.
  bool _ingest(MatchSnapshot next) {
    final newest = snapshot;
    if (next.tick == newest.tick) {
      // The same tick again (a resume reply racing the broadcast): same
      // picture, no new timing information.
      snapshot = next;
      _playout.push(next);
      _recordLocalBody(next);
      return true;
    }
    if (next.tick < newest.tick - _resetTickGap) {
      _startMatch(next); // the tick counter restarted: a new match
      return true;
    }
    if (next.tick < newest.tick) return false; // stale; shown past it already

    if (next.tick == newest.tick + 1) {
      _localClock.onArrival(next.tick, tickMs: next.tickMs);
      _noteFood(newest, next);
    } else {
      // A reconnect skipped ticks: what happened in between is not worth
      // animating. Take the server's word as it stands.
      _localClock.onArrival(next.tick, tickMs: next.tickMs, resync: true);
      _localHistory.clear();
      _foodEvents.clear();
      displayedFood = next.food;
      _localBlend.cancel();
    }
    snapshot = next;
    _playout.push(next);
    _recordLocalBody(next);
    return true;
  }

  void _startMatch(MatchSnapshot first) {
    snapshot = first;
    _localClock
      ..reset()
      ..onArrival(first.tick, tickMs: first.tickMs);
    _playout
      ..reset()
      ..push(first);
    _localHistory.clear();
    _foodEvents.clear();
    displayedFood = first.food;
    _localBlend.cancel();
    _drawnLocalPath = null;
    _seenResyncs = 0;
    _recordLocalBody(first);
  }

  void _recordLocalBody(MatchSnapshot s) {
    final me = s.playerByUserId(currentUserId);
    if (me == null || me.body.isEmpty) return;
    _localHistory[s.tick] = me.body;
    _localHistory.removeWhere((t, _) => t <= s.tick - _localHistoryTicks);
  }

  /// The food moved between two consecutive snapshots: someone ate it.
  void _noteFood(MatchSnapshot before, MatchSnapshot after) {
    if (before.food == after.food) return;
    final was = before.playerByUserId(currentUserId)?.score ?? 0;
    final now = after.playerByUserId(currentUserId)?.score ?? 0;
    _foodEvents.add(
      _FoodEvent(
        tick: after.tick,
        eatenAt: before.food,
        food: after.food,
        mine: now > was,
      ),
    );
  }

  /// The path the local clock walks: confirmed bodies up to the newest
  /// snapshot, then the predicted steps.
  void _rebuildLocalPath() {
    final path = prediction;
    final me = snapshot.playerByUserId(currentUserId);
    if (path == null ||
        me == null ||
        !me.alive ||
        path.baseTick != snapshot.tick) {
      _localPath = null;
      return;
    }
    final bodies = <int, List<Position>>{snapshot.tick: path.from};
    var first = snapshot.tick;
    while (_localHistory.containsKey(first - 1)) {
      first--;
      bodies[first] = _localHistory[first]!;
    }
    for (var i = 0; i < path.steps.length; i++) {
      bodies[snapshot.tick + 1 + i] = path.steps[i];
    }
    _localPath = _LocalPath(
      bodies,
      first: first,
      last: snapshot.tick + path.steps.length,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    _playout.advance(dt);
    _updateLocalSnake(dt);
    _updateRemoteSnakes();
    _releaseFoodEvents();
  }

  /// Walk the local snake along its path on the local clock, easing over
  /// any change of path.
  void _updateLocalSnake(double dt) {
    final path = _localPath;
    final lead = snapshot.tick + maxLocalLead;
    final limit = path == null ? lead : math.min(lead, path.last.toDouble());

    // The clock runs even while nothing is predicted, so it is still in
    // phase with the server when a prediction comes back.
    final before = _localClock.position;
    _localClock
      ..advance(dt, limit: limit)
      ..clampTo(limit);
    // The clock moved other than by running: it was pulled back to a path
    // that got shorter, or an arrival jumped it (a resync).
    final jumped =
        _localClock.position < before || _localClock.resyncs != _seenResyncs;
    _seenResyncs = _localClock.resyncs;

    if (path == null) {
      localCells = null;
      localFacing = null;
      _drawnLocalPath = null;
      _localBlend.cancel();
      return;
    }

    final tick = _localClock.position;
    final target = path.cellsAt(tick);
    final drawn = _drawnLocalPath;
    final shown = localCells;
    if (drawn != null && shown != null && !identical(drawn, path)) {
      // Ease from what the old path would have shown right now — or, when
      // the clock itself jumped, from the last frame.
      _localBlend.begin(
        jumped ? shown : _localBlend.apply(drawn.cellsAt(tick), 0),
        target,
      );
    }
    _drawnLocalPath = path;
    localCells = _localBlend.apply(target, dt);
    localFacing = prediction?.facing;
  }

  void _updateRemoteSnakes() {
    final poses = <int, SnakePose>{};
    for (final player in snapshot.players) {
      if (player.userId == currentUserId) continue;
      final pose = _playout.poseOf(player.playerIndex);
      if (pose != null) poses[player.playerIndex] = pose;
    }
    remotePoses = poses;
  }

  /// Show every bite whose snapshot the eater's clock has reached.
  void _releaseFoodEvents() {
    if (_foodEvents.isEmpty) return;
    var last = -1;
    for (var i = 0; i < _foodEvents.length; i++) {
      if (_isShown(_foodEvents[i])) last = i;
    }
    // Bites are shown in order: showing one releases any still waiting
    // before it.
    for (var i = 0; i <= last; i++) {
      _showBite(_foodEvents[i]);
    }
    if (last >= 0) _foodEvents.removeRange(0, last + 1);
  }

  bool _isShown(_FoodEvent bite) {
    const eps = 1e-6;
    // Never let a bite wait on a clock that has stopped for good.
    if (bite.tick <= snapshot.tick - 3) return true;
    if (bite.mine) {
      return localCells == null || _localClock.position + eps >= bite.tick;
    }
    return _playout.renderTick + eps >= bite.tick;
  }

  void _showBite(_FoodEvent bite) {
    displayedFood = bite.food;
    // Burst wherever the food was eaten, WHOEVER ate it. An opponent eating
    // silently reads as the game losing track of the apple rather than as
    // losing the race to it.
    _particles?.emitAt(
      Offset(
        bite.eatenAt.x * GameConstants.cellSize + GameConstants.cellSize / 2,
        bite.eatenAt.y * GameConstants.cellSize + GameConstants.cellSize / 2,
      ),
      // The opponent's is smaller and shorter: legible, but never louder
      // than the player's own pickup.
      bite.mine ? ParticleConfig.appleFoodExplosion : ParticleConfig.snakeTrail,
    );
    if (bite.mine) onLocalFoodEaten?.call();
  }

  /// Every snake's pose for the painter, by player index. A player without
  /// one is drawn exactly as [snapshot] has it.
  Map<int, SnakePose> get poses {
    final cells = localCells;
    final me = snapshot.playerByUserId(currentUserId);
    if (cells == null || cells.isEmpty || me == null) return remotePoses;
    return {
      ...remotePoses,
      me.playerIndex: SnakePose(
        cells: cells,
        facing: localFacing ?? me.direction,
        alive: true,
      ),
    };
  }
}

/// The local snake's bodies by tick: confirmed up to the newest snapshot,
/// predicted after it. Contiguous from [first] to [last].
class _LocalPath {
  _LocalPath(this._bodies, {required this.first, required this.last});

  final Map<int, List<Position>> _bodies;
  final int first;
  final int last;

  /// The body at a point on the tick axis, glided between whole ticks and
  /// held at either end.
  List<Offset> cellsAt(double tick) {
    if (tick <= first) return glideBody(_bodies[first]!, _bodies[first]!, 0);
    if (tick >= last) return glideBody(_bodies[last]!, _bodies[last]!, 0);
    final i = tick.floor();
    return glideBody(_bodies[i]!, _bodies[i + 1]!, tick - i);
  }
}

/// Someone ate the food in the snapshot for [tick].
class _FoodEvent {
  const _FoodEvent({
    required this.tick,
    required this.eatenAt,
    required this.food,
    required this.mine,
  });

  final int tick;
  final Position eatenAt;
  final Position food;
  final bool mine;
}

/// Renders the Living Board grid + both snakes + food by driving the
/// multiplayer painters in the Flame render pass (world pixel-space).
class _MultiplayerBoardComponent extends Component
    with HasGameReference<MultiplayerFlameGame> {
  _MultiplayerBoardComponent() : super(priority: 0);

  @override
  void render(Canvas canvas) {
    final size = Size(game.worldSize, game.worldSize);
    // Same world-to-screen hairline correction as the single-player board
    // (see LegacyBoardComponent.render) — without it the grid thickens on
    // bigger screens, since the stroke is measured in world units.
    final scale = game.size.x <= 0 || game.size.y <= 0
        ? 1.0
        : math.min(game.size.x / size.width, game.size.y / size.height);
    final hairline = scale <= 0 ? 0.5 : (1.0 / scale).clamp(0.5, 1.5);
    MultiplayerGridBackgroundPainter(
      game.theme,
      game.boardSize,
      lineWidth: hairline,
    ).paint(canvas, size);
    MultiplayerBoardPainter(
      snapshot: game.snapshot,
      currentUserId: game.currentUserId,
      theme: game.theme,
      pulseAnimation: AlwaysStoppedAnimation<double>(game.pulse),
      boardSize: game.boardSize,
      youLabel: game.youLabel,
      poses: game.poses,
      food: game.displayedFood,
    ).paint(canvas, size);
  }
}
