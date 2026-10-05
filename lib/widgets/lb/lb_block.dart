import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/lb/lb_glow_cache.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_feedback.dart';

/// Block kinds (DESIGN_SPEC §3). One [fill] per screen — "one loud thing".
enum LBBlockKind {
  /// 6% lime fill, 32% lime inner stroke. The default.
  outline,

  /// Solid lime with faint dark grid lines and a lime glow. Primary action.
  fill,

  /// Gold-tinted outline: rewards, coins, claims.
  gold,

  /// Solid gold. Reserved for the Pro purchase CTA.
  goldFill,

  /// Red-tinted outline: destructive or crash surfaces.
  danger,

  /// Quiet outline for disabled / secondary rows.
  muted,

  /// Dashed outline: empty slots, "get more" placeholders.
  dashed,

  /// Raised panel: deep fill, stroke and drop shadow (sheets, dialogs).
  sheet,
}

/// A rectangle snapped to the grid, inset 1 dp, radius 6 — the Living Board's
/// only surface. Tappable when [onTap] is set: it presses to 0.97 for 90 ms
/// with a light haptic and the `ui_tap` sound.
///
/// Children inherit a text colour that reads on the block ([foregroundOf]),
/// so labels inside a block rarely set colours themselves.
class LBBlock extends StatefulWidget {
  const LBBlock({
    super.key,
    this.kind = LBBlockKind.outline,
    this.child,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.alignment,
    this.radius = LB.blockRadius,
    this.selected = false,
    this.semanticLabel,
    this.feedback = true,
    this.accent,
    this.minHitSize,
  });

  final LBBlockKind kind;
  final Widget? child;
  final VoidCallback? onTap;

  /// Grows the tap (and screen-reader) target to at least this many dp
  /// square around the block without changing how it looks — for small
  /// controls that must still meet the 48 dp minimum. Needs the room.
  final double? minHitSize;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry? alignment;
  final double radius;

  /// For selectable outline blocks: draws the stroke at full lime.
  final bool selected;
  final String? semanticLabel;

  /// Play the tap haptic + sound. Off for blocks whose action has its own
  /// feedback (purchases, ad buttons).
  final bool feedback;

  /// Overrides the kind's base colour (rarity stripes, versus rival tint).
  final Color? accent;

  /// The text/icon colour that reads on [kind].
  static Color foregroundOf(LBBlockKind kind, LBPalette p) => switch (kind) {
        LBBlockKind.fill => p.onLime,
        LBBlockKind.goldFill => const Color(0xFF1E1600),
        LBBlockKind.gold => LB.gold,
        LBBlockKind.danger => LB.bonk,
        LBBlockKind.muted => p.inkDim,
        LBBlockKind.outline || LBBlockKind.dashed || LBBlockKind.sheet => p.head,
      };

  @override
  State<LBBlock> createState() => _LBBlockState();
}

class _LBBlockState extends State<LBBlock> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(widget.kind, p);
    final r = BorderRadius.circular(widget.radius);

    Widget content = DefaultTextStyle.merge(
      style: TextStyle(color: fg, fontFamily: LB.font, fontFamilyFallback: LB.fontFallback),
      child: IconTheme.merge(
        data: IconThemeData(color: fg, size: 18),
        child: Padding(
          padding: widget.padding,
          child: widget.alignment == null || widget.child == null
              ? widget.child
              : Align(alignment: widget.alignment!, child: widget.child),
        ),
      ),
    );

    content = CustomPaint(
      painter: _BlockPainter(
        kind: widget.kind,
        palette: p,
        radius: widget.radius,
        selected: widget.selected,
        accent: widget.accent,
      ),
      child: ClipRRect(borderRadius: r, child: content),
    );

    content = Padding(
      padding: const EdgeInsets.all(LB.inset),
      child: SizedBox(width: widget.width, height: widget.height, child: content),
    );

    if (!_interactive) {
      return widget.semanticLabel == null
          ? content
          : Semantics(label: widget.semanticLabel, child: content);
    }

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.feedback) LBFeedback.tap();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _setPressed(false);
                if (widget.feedback) LBFeedback.tap();
                widget.onLongPress!();
              },
        child: _hitArea(
          AnimatedScale(
            scale: _pressed ? .97 : 1,
            duration: LB.tap,
            curve: Curves.easeOut,
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _hitArea(Widget child) {
    final min = widget.minHitSize;
    if (min == null) return child;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: min, minHeight: min),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}

class _BlockPainter extends CustomPainter {
  _BlockPainter({
    required this.kind,
    required this.palette,
    required this.radius,
    required this.selected,
    this.accent,
  });

  final LBBlockKind kind;
  final LBPalette palette;
  final double radius;
  final bool selected;
  final Color? accent;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    // Inner stroke: deflate by half the stroke so it sits inside the bounds.
    final stroke = rr.deflate(.5);

    switch (kind) {
      case LBBlockKind.fill:
      case LBBlockKind.goldFill:
        final base = kind == LBBlockKind.fill ? (accent ?? p.lime) : LB.gold;
        // Cached: a fresh 15-sigma blur every frame was one of the largest
        // raster costs on Living Board screens (see LBGlowCache).
        LBGlowCache.drawRRectGlow(
          canvas,
          rrect: rr,
          color: base.withValues(alpha: .38),
          sigma: 15,
          style: BlurStyle.outer,
        );
        canvas.drawRRect(rr, Paint()..color = base);
        _gridLines(canvas, rr, const Color(0x21000000));
      case LBBlockKind.gold:
        final c = accent ?? LB.gold;
        canvas.drawRRect(rr, Paint()..color = c.withValues(alpha: .09));
        _stroke(canvas, stroke, c.withValues(alpha: selected ? .9 : .5));
      case LBBlockKind.danger:
        canvas.drawRRect(rr, Paint()..color = LB.bonkFill);
        _stroke(canvas, stroke, LB.bonkStroke);
      case LBBlockKind.muted:
        canvas.drawRRect(rr, Paint()..color = p.lime.withValues(alpha: .03));
        _stroke(canvas, stroke, p.cellOff);
      case LBBlockKind.dashed:
        _dashed(canvas, stroke, p.blockStroke);
      case LBBlockKind.sheet:
        canvas.drawRRect(
          rr.shift(const Offset(0, 6)),
          Paint()
            ..color = const Color(0x8C000000)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
        );
        canvas.drawRRect(rr, Paint()..color = p.deep);
        _stroke(canvas, stroke, p.blockStroke);
      case LBBlockKind.outline:
        final c = accent ?? p.lime;
        canvas.drawRRect(rr, Paint()..color = c.withValues(alpha: selected ? .12 : .06));
        _stroke(canvas, stroke, c.withValues(alpha: selected ? .95 : .32));
    }
  }

  void _stroke(Canvas canvas, RRect rr, Color c) => canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = c,
      );

  void _gridLines(Canvas canvas, RRect rr, Color c) {
    canvas.save();
    canvas.clipRRect(rr);
    final paint = Paint()
      ..color = c
      ..strokeWidth = 1;
    for (var x = LB.cell; x < rr.width; x += LB.cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, rr.height), paint);
    }
    for (var y = LB.cell; y < rr.height; y += LB.cell) {
      canvas.drawLine(Offset(0, y), Offset(rr.width, y), paint);
    }
    canvas.restore();
  }

  void _dashed(Canvas canvas, RRect rr, Color c) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = c;
    final path = Path()..addRRect(rr);
    for (final ui.PathMetric m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, (d + 5).clamp(0, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BlockPainter old) =>
      old.kind != kind ||
      old.palette != palette ||
      old.radius != radius ||
      old.selected != selected ||
      old.accent != accent;
}
