import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/direction.dart';

/// One steering input as the player made it: which way, and whether the game
/// took it (a reversal into your own neck is refused).
@immutable
class LBSwipeCue {
  const LBSwipeCue(this.direction, {required this.rejected});

  final Direction direction;
  final bool rejected;
}

/// "Did my swipe land, and which way?" — a plus of cells under the board for
/// swipe players. The arm you swiped lights lime and fades; a refused swipe
/// flashes its arm red. It shows the last swipe only, then goes dark, so it
/// never points somewhere stale after a turn or a restart. Read-only: it is
/// an indicator, not a control.
class LBSwipeCompass extends StatefulWidget {
  const LBSwipeCompass({super.key, required this.cue, required this.size});

  /// A new value (even an equal one) is a new swipe.
  final ValueListenable<LBSwipeCue?> cue;
  final double size;

  @override
  State<LBSwipeCompass> createState() => _LBSwipeCompassState();
}

class _LBSwipeCompassState extends State<LBSwipeCompass> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    widget.cue.addListener(_onCue);
  }

  @override
  void didUpdateWidget(LBSwipeCompass old) {
    super.didUpdateWidget(old);
    if (old.cue != widget.cue) {
      old.cue.removeListener(_onCue);
      widget.cue.addListener(_onCue);
    }
  }

  @override
  void dispose() {
    widget.cue.removeListener(_onCue);
    _fade.dispose();
    super.dispose();
  }

  void _onCue() {
    if (widget.cue.value != null) _fade.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      label: AppLocalizations.of(context)!.compassSemantics,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _fade,
            builder: (context, _) => CustomPaint(
              size: Size.square(widget.size),
              painter: _CompassPainter(
                cue: widget.cue.value,
                t: _fade.value,
                off: p.cellOff,
                lit: p.lime,
                head: p.head,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.cue,
    required this.t,
    required this.off,
    required this.lit,
    required this.head,
  });

  final LBSwipeCue? cue;

  /// 0 at the swipe, 1 when the cue has faded out.
  final double t;
  final Color off;
  final Color lit;
  final Color head;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 3;
    const inset = 3.0;
    final r = Radius.circular(c * .18);
    void cell(int col, int row, Color color) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(col * c + inset, row * c + inset, c - inset * 2, c - inset * 2),
          r,
        ),
        Paint()..color = color,
      );
    }

    // Centre: the snake's head, always there, so the shape reads as "you".
    cell(1, 1, head.withValues(alpha: .55));

    final arms = <Direction, (int, int)>{
      Direction.up: (1, 0),
      Direction.right: (2, 1),
      Direction.down: (1, 2),
      Direction.left: (0, 1),
    };
    final fade = Curves.easeOut.transform(1 - t);
    for (final MapEntry(key: dir, value: (col, row)) in arms.entries) {
      var color = off;
      if (cue != null && cue!.direction == dir && fade > 0) {
        final accent = cue!.rejected ? LB.bonk : lit;
        color = Color.lerp(off, accent, fade)!;
      }
      cell(col, row, color);
    }
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.t != t || old.cue != cue || old.off != off || old.lit != lit || old.head != head;
}
