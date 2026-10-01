import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:snake_classic/design/lb_tokens.dart';

/// A grid cell on the home board, in whole cells from the board origin.
typedef HomeCell = (int, int);

/// A block the home snake can be steered into. [cells] is the block's cell
/// bounds (inclusive-exclusive), in the same grid as the snake.
class HomeSnakeTarget {
  const HomeSnakeTarget(this.id, this.left, this.top, this.right, this.bottom);

  final String id;
  final int left, top, right, bottom;

  bool contains(HomeCell c) => c.$1 >= left && c.$1 < right && c.$2 >= top && c.$2 < bottom;
}

/// The Living Board home snake (DESIGN_SPEC §4, screen 02): it idles on a
/// loop around the PLAY block, eating apples along the way. A swipe steers it
/// off the loop; steering it into a block calls [onEnter] with that block's
/// id. Tapping the blocks is unaffected — this is a second way in, never the
/// only one.
///
/// Driven by a [Ticker], so it stops whenever Home is covered by another
/// route (TickerMode) and costs nothing off-screen. With "reduce motion" on,
/// the snake rests on the loop without moving.
class LBHomeSnake extends StatefulWidget {
  const LBHomeSnake({
    super.key,
    required this.cell,
    required this.originX,
    required this.loop,
    required this.targets,
    required this.columns,
    required this.rows,
    required this.onEnter,
  });

  /// Cell size in dp and the x of column 0 (the board grid's offset).
  final double cell;
  final double originX;

  /// The idle path, in order. The snake walks it forever.
  final List<HomeCell> loop;
  final List<HomeSnakeTarget> targets;
  final int columns, rows;
  final ValueChanged<String> onEnter;

  @override
  LBHomeSnakeState createState() => LBHomeSnakeState();
}

class LBHomeSnakeState extends State<LBHomeSnake> with SingleTickerProviderStateMixin {
  static const int _length = 11;
  static const Duration _idleStep = Duration(milliseconds: 150);
  static const Duration _steerStep = Duration(milliseconds: 55);

  late final Ticker _ticker = createTicker(_onTick);
  final _repaint = ValueNotifier<int>(0);
  final _rng = math.Random();

  /// Body, head first.
  List<HomeCell> _body = [];
  int _loopIndex = 0;
  int _appleIndex = 0;
  HomeCell? _apple;

  /// Set while steered off the loop.
  AxisDirection? _steer;
  int _freeSteps = 0;
  AxisDirection _heading = AxisDirection.right;
  Duration _last = Duration.zero;
  Duration _eatFlashUntil = Duration.zero;
  Duration _now = Duration.zero;

  @override
  void initState() {
    super.initState();
    _resetToLoop();
    _ticker.start();
  }

  @override
  void didUpdateWidget(LBHomeSnake oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget;
    if (old.loop.length != widget.loop.length ||
        (old.loop.isNotEmpty && widget.loop.isNotEmpty && old.loop.first != widget.loop.first) ||
        old.cell != widget.cell) {
      _resetToLoop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _resetToLoop() {
    _steer = null;
    _freeSteps = 0;
    final loop = widget.loop;
    if (loop.isEmpty) {
      _body = [];
      return;
    }
    // Head at the top-left-ish corner of the ring, body trailing behind it.
    _loopIndex = math.min(_length, loop.length - 1);
    _body = [for (var i = 0; i < _length; i++) loop[(_loopIndex - i) % loop.length]];
    _placeApple();
    _repaint.value++;
  }

  void _placeApple() {
    final loop = widget.loop;
    if (loop.isEmpty) return;
    _appleIndex = (_loopIndex + 6 + _rng.nextInt(8)) % loop.length;
    _apple = loop[_appleIndex];
  }

  /// Steer off the loop. Reversing straight into the body is ignored.
  void steer(AxisDirection d) {
    if (widget.loop.isEmpty) return;
    if (_isOpposite(d, _heading)) return;
    _steer = d;
    _freeSteps = 0;
    _last = Duration.zero; // move on the very next frame
  }

  static bool _isOpposite(AxisDirection a, AxisDirection b) =>
      (a == AxisDirection.left && b == AxisDirection.right) ||
      (a == AxisDirection.right && b == AxisDirection.left) ||
      (a == AxisDirection.up && b == AxisDirection.down) ||
      (a == AxisDirection.down && b == AxisDirection.up);

  void _onTick(Duration elapsed) {
    _now = elapsed;
    if (_body.isEmpty) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    final step = _steer != null ? _steerStep : _idleStep;
    if (_last != Duration.zero && elapsed - _last < step) return;
    _last = elapsed;

    if (_steer != null) {
      _stepFree();
    } else {
      _stepLoop();
    }
    _repaint.value++;
  }

  void _stepLoop() {
    final loop = widget.loop;
    _loopIndex = (_loopIndex + 1) % loop.length;
    final next = loop[_loopIndex];
    _heading = _directionBetween(_body.first, next) ?? _heading;
    _body = [next, ..._body.take(_length - 1)];
    if (_loopIndex == _appleIndex) {
      _eatFlashUntil = _now + const Duration(milliseconds: 80);
      _placeApple();
    }
  }

  void _stepFree() {
    final d = _steer!;
    _heading = d;
    final (x, y) = _body.first;
    final next = switch (d) {
      AxisDirection.up => (x, y - 1),
      AxisDirection.down => (x, y + 1),
      AxisDirection.left => (x - 1, y),
      AxisDirection.right => (x + 1, y),
    };
    _body = [next, ..._body.take(_length - 1)];
    _freeSteps++;
    for (final t in widget.targets) {
      if (t.contains(next)) {
        _eatFlashUntil = _now + const Duration(milliseconds: 120);
        widget.onEnter(t.id);
        // Settle back on the loop once the destination has opened (or on
        // return, if it pushed a route and paused this ticker).
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _resetToLoop();
        });
        _steer = null;
        return;
      }
    }
    final out = next.$1 < 0 || next.$2 < 0 || next.$1 >= widget.columns || next.$2 >= widget.rows;
    if (out || _freeSteps > 40) _resetToLoop();
  }

  static AxisDirection? _directionBetween(HomeCell a, HomeCell b) {
    if (b.$1 > a.$1) return AxisDirection.right;
    if (b.$1 < a.$1) return AxisDirection.left;
    if (b.$2 > a.$2) return AxisDirection.down;
    if (b.$2 < a.$2) return AxisDirection.up;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _HomeSnakePainter(
            state: this,
            palette: p,
            repaint: _repaint,
          ),
        ),
      ),
    );
  }
}

class _HomeSnakePainter extends CustomPainter {
  _HomeSnakePainter({required this.state, required this.palette, required Listenable repaint})
      : super(repaint: repaint);

  final LBHomeSnakeState state;
  final LBPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = state.widget;
    final cell = w.cell;
    Rect at(HomeCell c) => Rect.fromLTWH(w.originX + c.$1 * cell, c.$2 * cell, cell, cell);

    final apple = state._apple;
    if (apple != null && state._steer == null) {
      final c = at(apple).center;
      canvas.drawCircle(
        c,
        cell * .42,
        Paint()
          ..color = LB.foodGlow
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .3),
      );
      canvas.drawCircle(
        c,
        cell * .32,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-.4, -.45),
            colors: [LB.appleHighlight, LB.apple],
          ).createShader(Rect.fromCircle(center: c, radius: cell * .32)),
      );
    }

    final body = state._body;
    for (var i = body.length - 1; i >= 1; i--) {
      // 100% at the head ramping to 45% at the tail (DESIGN_SPEC §5).
      final t = i / (body.length - 1);
      final paint = Paint()..color = palette.lime.withValues(alpha: 1 - .55 * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(at(body[i]).deflate(1), const Radius.circular(LB.snakeCellRadius)),
        paint,
      );
    }
    if (body.isEmpty) return;

    final head = at(body.first).deflate(1);
    final flashing = state._now < state._eatFlashUntil;
    final headColor = flashing ? Color.lerp(palette.head, Colors.white, .55)! : palette.head;
    canvas.drawRRect(
      RRect.fromRectAndRadius(head.inflate(2), const Radius.circular(LB.headRadius)),
      Paint()
        ..color = palette.head.withValues(alpha: .45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(head, const Radius.circular(LB.headRadius)),
      Paint()..color = headColor,
    );
    _eyes(canvas, head, state._heading, palette.onLime);
  }

  static void _eyes(Canvas canvas, Rect head, AxisDirection d, Color color) {
    final paint = Paint()..color = color;
    final r = head.width * .09;
    final f = head.width * .2; // forward offset from centre
    final s = head.width * .19; // spread
    final c = head.center;
    final (Offset a, Offset b) = switch (d) {
      AxisDirection.right => (c + Offset(f, -s), c + Offset(f, s)),
      AxisDirection.left => (c + Offset(-f, -s), c + Offset(-f, s)),
      AxisDirection.up => (c + Offset(-s, -f), c + Offset(s, -f)),
      AxisDirection.down => (c + Offset(-s, f), c + Offset(s, f)),
    };
    canvas.drawCircle(a, r, paint);
    canvas.drawCircle(b, r, paint);
  }

  @override
  bool shouldRepaint(_HomeSnakePainter old) => old.palette != palette || old.state != state;
}
