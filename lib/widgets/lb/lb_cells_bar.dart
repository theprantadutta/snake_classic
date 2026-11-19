import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';

/// Progress drawn as a row of [count] cells (DESIGN_SPEC §3). Used for
/// level, XP, loading, countdowns, the momentum bar and sliders.
///
/// [value] is 0–1; partially lit cells round down so a bar never claims
/// progress the player hasn't made. With no [cell] it stretches to the
/// available width.
///
/// Motion (MOTION_SPEC "Progress bar"): on first build the lit cells light
/// left to right (at most [introCap] in all); when [value] grows, the new
/// cells light in order ([LBMotion.cellStagger] apart) and the last one pops
/// ([LBMotion.springPop] over [LBMotion.slow]). Drops are instant. A bar a
/// parent re-drives faster than [LBMotion.base] (loading sweeps, timers,
/// sliders) stops animating and just shows its value. [animate] false, or
/// reduce motion, shows every value instantly.
class LBCellsBar extends StatefulWidget {
  const LBCellsBar({
    super.key,
    required this.count,
    required this.value,
    this.cell,
    this.color,
    this.offColor,
    this.colorAt,
    this.semanticsLabel,
    this.animate = true,
  });

  final int count;
  final double value;

  /// dp per cell. Null = fill the width.
  final double? cell;
  final Color? color;
  final Color? offColor;

  /// Per-cell colour override for lit cells (gradients, sweeps).
  final Color Function(int index)? colorAt;
  final String? semanticsLabel;

  /// Light cells in sequence on first build and on increases.
  final bool animate;

  /// The first-build light-up never takes longer than this.
  static const Duration introCap = Duration(milliseconds: 400);

  int get litCount => (value.clamp(0.0, 1.0) * count + 1e-6).floor();

  @override
  State<LBCellsBar> createState() => _LBCellsBarState();
}

class _LBCellsBarState extends State<LBCellsBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);

  /// Cells lit before the running animation, and the target it lights to.
  int _from = 0;
  int _to = 0;

  /// Delay between consecutive cells of the running animation.
  Duration _step = LBMotion.cellStagger;

  /// Whether the last newly lit cell pops (increases, not the intro).
  bool _pop = false;

  /// Set once a parent drives the value faster than an animation can show.
  bool _driven = false;
  bool _started = false;

  /// Frame time of the last value change (frame clock, so tests can fake it).
  Duration? _lastChange;

  bool get _canAnimate => widget.animate && !_driven && !LBMotion.reduced(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return; // first build only
    _started = true;
    final lit = widget.litCount;
    _to = lit;
    if (lit == 0 || !_canAnimate) {
      _from = lit;
      return;
    }
    // Intro: left to right, the whole bar within introCap.
    final capPerCell = LBCellsBar.introCap.inMicroseconds ~/ lit;
    _step = Duration(microseconds: capPerCell.clamp(0, LBMotion.cellStagger.inMicroseconds));
    _from = 0;
    _pop = false;
    _run(_step * lit);
  }

  @override
  void didUpdateWidget(LBCellsBar old) {
    super.didUpdateWidget(old);
    final lit = widget.litCount;
    final shown = _shownTarget;
    if (lit == shown) return;
    final scheduler = SchedulerBinding.instance;
    // The frame clock is only set inside a frame; a build outside one
    // (rare) just doesn't count towards "driven".
    final now = scheduler.schedulerPhase == SchedulerPhase.idle
        ? null
        : scheduler.currentFrameTimeStamp;
    if (now != null && _lastChange != null && now - _lastChange! < LBMotion.base) {
      _driven = true;
    }
    _lastChange = now ?? _lastChange;
    if (lit < shown || !_canAnimate) {
      _c.stop();
      _from = _to = lit;
      return;
    }
    // Keep whatever is already lit, light the rest in order, pop the last.
    _from = _litNow();
    _to = lit;
    _step = LBMotion.cellStagger;
    _pop = true;
    _run(_step * (_to - _from - 1) + LBMotion.slow);
  }

  int get _shownTarget => _to;

  void _run(Duration total) {
    _c.duration = total;
    _c.forward(from: 0);
  }

  /// Cells lit at this moment of the running animation.
  int _litNow() {
    if (!_c.isAnimating || _to <= _from) return _to;
    final elapsed = _c.value * (_c.duration?.inMicroseconds ?? 0);
    final stepUs = _step.inMicroseconds;
    final n = stepUs == 0 ? _to - _from : elapsed ~/ stepUs + 1;
    return (_from + n).clamp(_from, _to);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final count = widget.count;
    final cell = widget.cell;
    final painter = _CellsBarPainter(
      count: count,
      lit: _to,
      cell: cell,
      color: widget.color ?? p.lime,
      off: widget.offColor ?? p.cellOff,
      colorAt: widget.colorAt,
      from: _from,
      step: _step,
      pop: _pop,
      clock: _c,
    );
    // Fill-the-width bars size through AspectRatio, not a LayoutBuilder: a
    // LayoutBuilder cannot report an intrinsic height, so a bar inside
    // SliverFillRemaining / IntrinsicHeight threw and blanked the whole
    // screen (Versus went empty the moment FIND MATCH showed its bar).
    // RepaintBoundary: a lighting animation repaints only the bar.
    final body = cell != null
        ? RepaintBoundary(
            child: CustomPaint(size: Size(cell * count, cell), painter: painter),
          )
        : AspectRatio(
            aspectRatio: count.toDouble(),
            child: RepaintBoundary(child: CustomPaint(painter: painter)),
          );
    return Semantics(
      label: widget.semanticsLabel,
      value: '${(widget.value.clamp(0.0, 1.0) * 100).round()}%',
      child: ExcludeSemantics(child: body),
    );
  }
}

class _CellsBarPainter extends CustomPainter {
  _CellsBarPainter({
    required this.count,
    required this.lit,
    required this.cell,
    required this.color,
    required this.off,
    required this.from,
    required this.step,
    required this.pop,
    required this.clock,
    this.colorAt,
  }) : super(repaint: clock);

  final int count;

  /// Cells lit once the animation ends.
  final int lit;

  /// dp per cell; null = the painted width split across [count].
  final double? cell;
  final Color color;
  final Color off;
  final Color Function(int index)? colorAt;

  /// Cells already lit when the animation started.
  final int from;

  /// Delay between consecutive newly lit cells.
  final Duration step;

  /// The last newly lit cell pops in.
  final bool pop;
  final AnimationController clock;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = this.cell ?? size.width / count;
    final animating = clock.isAnimating && lit > from;
    final elapsedUs = animating ? clock.value * (clock.duration?.inMicroseconds ?? 0) : 0.0;
    final stepUs = step.inMicroseconds;

    final offPath = Path();
    final litPath = Path();
    RRect? popped;
    var poppedScale = 1.0;
    for (var i = 0; i < count; i++) {
      final r = lbCellRect(i * cell, 0, cell);
      var on = i < lit;
      if (on && animating && i >= from) {
        // The k-th newly lit cell lights k steps after the start.
        final litAt = (i - from) * stepUs;
        on = elapsedUs >= litAt;
        if (on && pop && i == lit - 1) {
          final t = ((elapsedUs - litAt) / LBMotion.slow.inMicroseconds).clamp(0.0, 1.0);
          poppedScale = .4 + .6 * LBMotion.springPop.transform(t);
          popped = r;
          offPath.addRRect(r); // the cell's socket shows under the pop
          continue;
        }
      }
      if (on) {
        if (colorAt != null) {
          canvas.drawRRect(r, Paint()..color = colorAt!(i));
        } else {
          litPath.addRRect(r);
        }
      } else {
        offPath.addRRect(r);
      }
    }
    canvas.drawPath(offPath, Paint()..color = off);
    canvas.drawPath(litPath, Paint()..color = color);
    if (popped != null) {
      final c = popped.center;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(poppedScale);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawRRect(popped, Paint()..color = colorAt?.call(lit - 1) ?? color);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CellsBarPainter old) =>
      old.count != count ||
      old.lit != lit ||
      old.cell != cell ||
      old.color != color ||
      old.off != off ||
      old.colorAt != colorAt ||
      old.from != from ||
      old.step != step ||
      old.pop != pop ||
      old.clock != clock;
}
