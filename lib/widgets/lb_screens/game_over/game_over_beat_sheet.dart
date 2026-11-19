// Game over choreography: one controller, one table of beats.
//
// The whole reveal (headline, score count-up, best, run chart, coins, the
// action rows) runs off a single AnimationController so the timing reads as
// authored in one place, [_GameOverBeatSheetState]'s beat table. Pieces of
// the screen take their slice of the clock from [GameOverReveal] and wrap
// themselves in the small Beat* widgets below. Spec: docs/MOTION_SPEC.md.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';

/// Moments in the reveal that the screen reacts to (haptics).
enum GameOverBeat { scoreLanded, newBest }

/// Slices of the beat-sheet clock, one per piece of the screen. Every
/// animation sits at 1.0 in the end state (skipped, revisited, reduced
/// motion), so a piece built from them always rests where the static layout
/// would put it.
class GameOverReveal {
  GameOverReveal._({
    required this.clock,
    required this.actionsLive,
    required this.headline,
    required this.ribbon,
    required this.scoreLabel,
    required this.scoreCount,
    required this.best,
    required this.chartLabel,
    required this.chart,
    required this.chartCaption,
    required this.coins,
    required this.coinsCount,
    required this.actionSlices,
  });

  /// A reveal already at its end state, for widgets pumped on their own.
  static final GameOverReveal settled = () {
    const done = AlwaysStoppedAnimation<double>(1);
    return GameOverReveal._(
      clock: done,
      actionsLive: true,
      headline: done,
      ribbon: done,
      scoreLabel: done,
      scoreCount: done,
      best: done,
      chartLabel: done,
      chart: done,
      chartCaption: done,
      coins: done,
      coinsCount: done,
      actionSlices: const [done],
    );
  }();

  /// The raw 0→1 clock of the whole sheet.
  final Animation<double> clock;

  /// False until AGAIN has arrived. The action rows absorb taps until then,
  /// so the tap that skips the reveal never lands on a button the player
  /// could not see yet.
  final bool actionsLive;

  final Animation<double> headline;
  final Animation<double> ribbon;
  final Animation<double> scoreLabel;

  /// Eased 0→1 for the score count-up; 1 = the score has landed.
  final Animation<double> scoreCount;

  /// Springy for a new best, a plain fade otherwise.
  final Animation<double> best;
  final Animation<double> chartLabel;

  /// Left→right clip reveal of the run chart.
  final Animation<double> chart;
  final Animation<double> chartCaption;

  /// springPop for the coins block, and the eased tick of its number.
  final Animation<double> coins;
  final Animation<double> coinsCount;

  /// One slice per action row, [LBMotion.stagger] apart.
  final List<Animation<double>> actionSlices;

  /// The [i]th action row, staggered from AGAIN's beat.
  Animation<double> action(int i) =>
      actionSlices[math.min(i, actionSlices.length - 1)];
}

/// Owns the game over reveal clock. [builder] lays out the screen from the
/// [GameOverReveal] it is handed.
///
/// - A tap anywhere before the end jumps to the end state. The tapped button
///   does not fire if its row had not arrived yet ([GameOverReveal.actionsLive]).
/// - The same run is revealed once: coming back to it (from the replay
///   viewer, a rebuilt route) shows the end state.
/// - Reduce motion shows the end state on the first frame.
class GameOverBeatSheet extends StatefulWidget {
  const GameOverBeatSheet({
    super.key,
    required this.runKey,
    required this.builder,
    this.isNewBest = false,
    this.onBeat,
  });

  /// Identifies the run on screen; a run already revealed is not replayed.
  final Object runKey;
  final bool isNewBest;
  final Widget Function(BuildContext context, GameOverReveal reveal) builder;

  /// Fired as the reveal plays through [GameOverBeat]s; never for beats a
  /// skip jumped over, never for an end state shown outright.
  final ValueChanged<GameOverBeat>? onBeat;

  /// The last run revealed, across screen instances.
  static Object? _revealedRun;

  @visibleForTesting
  static void resetRevealedRun() => _revealedRun = null;

  @override
  State<GameOverBeatSheet> createState() => _GameOverBeatSheetState();
}

class _GameOverBeatSheetState extends State<GameOverBeatSheet>
    with SingleTickerProviderStateMixin {
  // ── Beat sheet ─────────────────────────────────────────────────────────
  // Milliseconds from the moment game over appears. Durations and curves
  // are LBMotion tokens only.
  static const int _headlineAt = 0; //        × YOU KISSED THE WALL… drops in
  static const int _ribbonAt = 90; //         tournament ribbon, if any
  static const int _scoreLabelAt = 250; //    SCORE
  static const int _scoreCountAt = 350; //    digits count 0 → score …
  static const Duration _scoreCountFor =
      LBMotion.lingering; // … landing at 1250
  static const int _bestAt = 1300; //         BEST fades in / NEW BEST pops
  static const int _chartLabelAt = 1450; //   YOUR RUN, UNCOILED
  static const int _chartAt = 1500; //        chart draws in left → right …
  static const Duration _chartFor = LBMotion.lingering; // … until 2400
  static const int _captionAt = 1950; //      chart caption
  static const int _coinsAt = 2200; //        +N¢ block pops, number ticks
  static const int _actionsAt = 2500; //      AGAIN / CONTINUE / rows rise in
  static const int _actionRows = 6; //        rows staggered by LBMotion.stagger
  static const int _actionsLiveAt = 2650; //  taps reach the rows from here

  static final int _totalMs =
      _actionsAt +
      LBMotion.stagger.inMilliseconds * (_actionRows - 1) +
      LBMotion.gentle.inMilliseconds;
  // ───────────────────────────────────────────────────────────────────────

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _totalMs),
  );
  late final GameOverReveal _base = _buildReveal();
  bool _actionsLive = false;
  bool _started = false;
  bool _scoreFired = false;
  bool _bestFired = false;

  Animation<double> _at(int startMs, Duration d, Curve curve) {
    final begin = startMs / _totalMs;
    final end = math.min(1.0, (startMs + d.inMilliseconds) / _totalMs);
    return CurvedAnimation(
      parent: _c,
      curve: Interval(begin, end, curve: curve),
    );
  }

  GameOverReveal _buildReveal() => GameOverReveal._(
    clock: _c,
    actionsLive: false,
    headline: _at(_headlineAt, LBMotion.gentle, LBMotion.dropIn),
    ribbon: _at(_ribbonAt, LBMotion.gentle, LBMotion.easeOutSoft),
    scoreLabel: _at(_scoreLabelAt, LBMotion.quick, LBMotion.easeOutSoft),
    scoreCount: _at(_scoreCountAt, _scoreCountFor, LBMotion.easeOutSoft),
    best: _at(
      _bestAt,
      widget.isNewBest ? LBMotion.slow : LBMotion.base,
      widget.isNewBest ? LBMotion.springPop : LBMotion.easeOutSoft,
    ),
    chartLabel: _at(_chartLabelAt, LBMotion.base, LBMotion.easeOutSoft),
    chart: _at(_chartAt, _chartFor, LBMotion.standard),
    chartCaption: _at(_captionAt, LBMotion.base, LBMotion.easeOutSoft),
    coins: _at(_coinsAt, LBMotion.slow, LBMotion.springPop),
    coinsCount: _at(_coinsAt, LBMotion.slow, LBMotion.easeOutSoft),
    actionSlices: [
      for (var i = 0; i < _actionRows; i++)
        _at(
          _actionsAt + LBMotion.stagger.inMilliseconds * i,
          LBMotion.gentle,
          LBMotion.easeOutSoft,
        ),
    ],
  );

  int get _elapsedMs => (_c.value * _totalMs).round();

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final seen = GameOverBeatSheet._revealedRun == widget.runKey;
    GameOverBeatSheet._revealedRun = widget.runKey;
    if (seen || LBMotion.reduced(context)) {
      _settle();
    } else {
      _c.forward();
    }
  }

  void _onTick() {
    final ms = _elapsedMs;
    if (!_scoreFired && ms >= _scoreCountAt + _scoreCountFor.inMilliseconds) {
      _scoreFired = true;
      widget.onBeat?.call(GameOverBeat.scoreLanded);
    }
    if (!_bestFired && widget.isNewBest && ms >= _bestAt) {
      _bestFired = true;
      widget.onBeat?.call(GameOverBeat.newBest);
    }
    if (!_actionsLive && ms >= _actionsLiveAt) {
      setState(() => _actionsLive = true);
    }
  }

  /// Jump to the end state without firing the beats on the way.
  void _settle() {
    _scoreFired = true;
    _bestFired = true;
    _actionsLive = true;
    _c.value = 1;
  }

  void _skip() {
    if (!_c.isAnimating) return;
    setState(_settle);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reveal = GameOverReveal._(
      clock: _base.clock,
      actionsLive: _actionsLive,
      headline: _base.headline,
      ribbon: _base.ribbon,
      scoreLabel: _base.scoreLabel,
      scoreCount: _base.scoreCount,
      best: _base.best,
      chartLabel: _base.chartLabel,
      chart: _base.chart,
      chartCaption: _base.chartCaption,
      coins: _base.coins,
      coinsCount: _base.coinsCount,
      actionSlices: _base.actionSlices,
    );
    // Translucent and on pointer-down: the skip never competes with the
    // scroll view or the buttons for the gesture.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _skip(),
      child: widget.builder(context, reveal),
    );
  }
}

/// Fades [child] in while it travels [rise] dp into place (positive: from
/// below, negative: dropping from above). Always the same widget shape, so
/// the child keeps its state for the whole reveal.
class BeatIn extends StatelessWidget {
  const BeatIn({
    super.key,
    required this.animation,
    required this.child,
    this.rise = 8,
  });

  final Animation<double> animation;
  final double rise;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final t = animation.value.clamp(0.0, 1.0);
      return Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, rise * (1 - t)),
          child: child,
        ),
      );
    },
  );
}

/// Pops [child] in from a smaller scale; give it a springPop slice so it
/// overshoots and settles.
class BeatPop extends StatelessWidget {
  const BeatPop({
    super.key,
    required this.animation,
    required this.child,
    this.from = .6,
    this.alignment = Alignment.center,
  });

  final Animation<double> animation;
  final double from;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final v = animation.value;
      return Opacity(
        opacity: (v * 2).clamp(0.0, 1.0),
        child: Transform.scale(
          scale: from + (1 - from) * v,
          alignment: alignment.resolve(Directionality.of(context)),
          child: child,
        ),
      );
    },
  );
}

/// Reveals [child] left→right by clipping it. The child paints once into
/// its own layer; only the clip moves.
class BeatClipReveal extends StatelessWidget {
  const BeatClipReveal({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = RepaintBoundary(child: child);
    return AnimatedBuilder(
      animation: animation,
      child: body,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return ClipRect(
          clipper: _RevealClipper(t),
          clipBehavior: t >= 1 ? Clip.none : Clip.hardEdge,
          child: child,
        );
      },
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper(this.t);
  final double t;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * t, size.height);

  @override
  bool shouldReclip(_RevealClipper old) => old.t != t;
}

/// Counts 0 → [value] along [animation] in at most [steps] visible steps, so
/// an expensive child (cell-drawn digits) rebuilds a dozen times, not every
/// frame. [builder] gets `landed` once the count reaches [value].
class BeatCount extends StatelessWidget {
  const BeatCount({
    super.key,
    required this.animation,
    required this.value,
    required this.builder,
    this.steps = 12,
  });

  final Animation<double> animation;
  final int value;
  final int steps;
  final Widget Function(BuildContext context, int shown, bool landed) builder;

  /// The number shown at [t] (0→1) for a count to [value] in [steps].
  @visibleForTesting
  static int shownAt(double t, int value, int steps) {
    if (t >= 1 || value <= 0) return math.max(0, value);
    final n = math.max(1, math.min(steps, value));
    final step = (t.clamp(0.0, 1.0) * n).floor();
    return (value * step / n).round();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final t = animation.value;
      return _Quantized(
        shown: shownAt(t, value, steps),
        landed: t >= 1,
        builder: builder,
      );
    },
  );
}

/// Rebuilds [builder] only when the shown number changes.
class _Quantized extends StatefulWidget {
  const _Quantized({
    required this.shown,
    required this.landed,
    required this.builder,
  });

  final int shown;
  final bool landed;
  final Widget Function(BuildContext context, int shown, bool landed) builder;

  @override
  State<_Quantized> createState() => _QuantizedState();
}

class _QuantizedState extends State<_Quantized> {
  Widget? _cached;
  int? _shown;
  bool? _landed;

  @override
  void didUpdateWidget(_Quantized old) {
    super.didUpdateWidget(old);
    // A new builder (the parent rebuilt: theme, colour, value) invalidates
    // the cached child; the animation ticking does not.
    if (!identical(old.builder, widget.builder)) _cached = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_cached == null || _shown != widget.shown || _landed != widget.landed) {
      _shown = widget.shown;
      _landed = widget.landed;
      _cached = widget.builder(context, widget.shown, widget.landed);
    }
    return _cached!;
  }
}
