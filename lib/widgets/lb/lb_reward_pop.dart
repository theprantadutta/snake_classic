import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_glow_cache.dart';

/// Pops a reward block when it is claimed: scale 1 → 1.06 → 1 (springPop)
/// with a short gold glow flash behind it (MOTION_SPEC: reward / coins).
///
/// Plays whenever [claimed] turns true (never on first build, so opening a
/// screen full of claimed rewards stays still). The glow comes from
/// [LBGlowCache], drawn once and faded as an image: no live blur.
///
/// Reduce motion: no pop.
class LBClaimPop extends StatefulWidget {
  const LBClaimPop({
    super.key,
    required this.claimed,
    required this.child,
    this.radius = LB.blockRadius,
  });

  final bool claimed;
  final Widget child;

  /// Corner radius of the glow, matching the block it wraps.
  final double radius;

  @override
  State<LBClaimPop> createState() => _LBClaimPopState();
}

class _LBClaimPopState extends State<LBClaimPop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: LBMotion.slow,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.06,
      ).chain(CurveTween(curve: LBMotion.easeOutSoft)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.06,
        end: 1.0,
      ).chain(CurveTween(curve: LBMotion.springPop)),
      weight: 70,
    ),
  ]).animate(_c);

  @override
  void didUpdateWidget(LBClaimPop old) {
    super.didUpdateWidget(old);
    if (widget.claimed && !old.claimed && !LBMotion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _GlowFlashPainter(_c, widget.radius),
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}

class _GlowFlashPainter extends CustomPainter {
  _GlowFlashPainter(this.animation, this.radius) : super(repaint: animation);

  final Animation<double> animation;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t <= 0 || t >= 1 || animation.status == AnimationStatus.dismissed) {
      return;
    }
    // Snaps on in the first tenth, then fades out.
    final opacity = t < .1 ? t / .1 : math.pow(1 - (t - .1) / .9, 2).toDouble();
    LBGlowCache.drawRRectGlow(
      canvas,
      rrect: RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ),
      color: LB.gold.withValues(alpha: .55),
      sigma: 10,
      style: BlurStyle.outer,
      opacity: opacity,
    );
  }

  @override
  bool shouldRepaint(_GlowFlashPainter old) => old.radius != radius;
}
