import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';

/// The Living Board press: the surface sinks to [LBMotion.pressScale] in
/// [LBMotion.pressDown] (easeOutSoft) and springs back in
/// [LBMotion.pressRelease] (springSoft, a small overshoot). [dip] also moves
/// it down that many dp while held (filled primary blocks).
///
/// [LBBlock] uses this for every tappable block; surfaces that are not an
/// LBBlock (theme swatches, custom tiles) wrap themselves in it to press the
/// same way. It handles only the gesture and the motion: haptics, sound and
/// semantics stay with the caller. Reduce motion: no scale, no dip.
class LBPressable extends StatefulWidget {
  const LBPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.dip = 0,
    this.minHitSize,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// dp the surface moves down while pressed.
  final double dip;

  /// Grows the tap target to at least this many dp square around [child]
  /// without changing how it looks.
  final double? minHitSize;
  final HitTestBehavior behavior;

  @override
  State<LBPressable> createState() => _LBPressableState();
}

class _LBPressableState extends State<LBPressable> with SingleTickerProviderStateMixin {
  // Unbounded: springSoft overshoots, so the release dips just below 0
  // (scale a hair above 1) before settling.
  late final AnimationController _press = AnimationController.unbounded(vsync: this);
  bool _down = false;
  bool _releaseAfterDown = false;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _pressDown() {
    if (LBMotion.reduced(context)) return;
    _down = true;
    _releaseAfterDown = false;
    _press
        .animateTo(1, duration: LBMotion.pressDown, curve: LBMotion.easeOutSoft)
        .then((_) {
      if (_releaseAfterDown && mounted) _release();
    });
  }

  void _pressUp() {
    if (!_down) return;
    _down = false;
    // A quick tap (down and up in the same frame, as inside a scroll view)
    // would otherwise show no press at all: let the sink finish first.
    if (_press.isAnimating && _press.value < 1) {
      _releaseAfterDown = true;
      return;
    }
    _release();
  }

  void _release() {
    _releaseAfterDown = false;
    _press.animateTo(0, duration: LBMotion.pressRelease, curve: LBMotion.springSoft);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
      animation: _press,
      child: widget.child,
      builder: (context, child) {
        final v = _press.value;
        if (v == 0) return Transform.scale(scale: 1, child: child);
        return Transform.scale(
          scale: 1 - (1 - LBMotion.pressScale) * v,
          child: Transform.translate(
            offset: Offset(0, widget.dip * v.clamp(0.0, 1.0)),
            child: child,
          ),
        );
      },
    );
    final min = widget.minHitSize;
    if (min != null) {
      child = ConstrainedBox(
        constraints: BoxConstraints(minWidth: min, minHeight: min),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      );
    }
    final interactive = widget.onTap != null || widget.onLongPress != null;
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: interactive ? (_) => _pressDown() : null,
      onTapUp: interactive ? (_) => _pressUp() : null,
      onTapCancel: interactive ? _pressUp : null,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              _pressUp();
              widget.onLongPress!();
            },
      child: child,
    );
  }
}
