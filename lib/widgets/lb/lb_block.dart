import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/widgets/lb/lb_glow_cache.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/design/scenes/scenes.dart';
import 'package:snake_classic/widgets/lb/lb_feedback.dart';
import 'package:snake_classic/widgets/lb/lb_pressable.dart';
import 'package:snake_classic/design/lb_motion.dart';

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
/// only surface. Tappable when [onTap] is set: it presses like every LB
/// surface ([LBPressable]: sinks to 0.97, springs back; filled kinds also dip
/// 2 dp) with a light haptic and the `ui_tap` sound. Tappable filled blocks
/// breathe their glow while idle (see [idleGlowPulse]).
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

  /// Master switch for the idle glow pulse of tappable filled blocks. The
  /// loop never settles, so widget tests turn it off
  /// (test/flutter_test_config.dart) to keep `pumpAndSettle` usable.
  static bool idleGlowPulse = true;

  /// One full breath (dim to bright and back).
  static const Duration glowPulsePeriod = Duration(milliseconds: 2400);
  static const double glowAlphaLow = .30;
  static const double glowAlphaHigh = .45;

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

class _LBBlockState extends State<LBBlock> with SingleTickerProviderStateMixin {
  /// Idle glow breathing for primary blocks; created on first need.
  AnimationController? _pulse;
  Animation<double>? _pulseCurve;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  bool get _filled => widget.kind == LBBlockKind.fill || widget.kind == LBBlockKind.goldFill;

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  /// Starts or stops the glow loop. The controller's vsync is this State, so
  /// TickerMode mutes it while the route is covered or off screen.
  bool _syncPulse(BuildContext context) {
    final want = LBBlock.idleGlowPulse &&
        _filled &&
        widget.onTap != null &&
        !LBMotion.reduced(context);
    if (want) {
      if (_pulse == null) {
        _pulse = AnimationController(vsync: this, duration: LBBlock.glowPulsePeriod ~/ 2);
        _pulseCurve = CurvedAnimation(parent: _pulse!, curve: LBMotion.standard);
      }
      if (!_pulse!.isAnimating) _pulse!.repeat(reverse: true);
    } else if (_pulse?.isAnimating ?? false) {
      _pulse!.stop();
    }
    return want;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(widget.kind, p);
    final r = BorderRadius.circular(widget.radius);
    final pulsing = _syncPulse(context);

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
        glow: !pulsing,
      ),
      child: ClipRRect(borderRadius: r, child: content),
    );

    // The breathing glow sits behind the block in its own layer, so a pulse
    // frame redraws one cached image and nothing else. The Stack is always
    // there (the glow slot is empty when not pulsing) so the block's subtree
    // keeps its state when the pulse turns on or off.
    content = Stack(
      // Passthrough: the block lays out exactly as it did without the Stack
      // (a loose fit would shrink stretched blocks to their content).
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: pulsing
              ? RepaintBoundary(
                  child: CustomPaint(
                    painter: _GlowPulsePainter(
                      pulse: _pulseCurve!,
                      color: widget.kind == LBBlockKind.fill ? (widget.accent ?? p.lime) : LB.gold,
                      radius: widget.radius,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        content,
      ],
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
      child: LBPressable(
        dip: _filled ? 2 : 0,
        minHitSize: widget.minHitSize,
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.feedback) LBFeedback.tap();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                if (widget.feedback) LBFeedback.tap();
                widget.onLongPress!();
              },
        child: content,
      ),
    );
  }
}

/// The idle glow of a primary block, breathing between alpha
/// [LBBlock.glowAlphaLow] and [LBBlock.glowAlphaHigh]. The glow image is
/// rasterized once at the high alpha (LBGlowCache); each frame only changes
/// the opacity it is drawn with.
class _GlowPulsePainter extends CustomPainter {
  _GlowPulsePainter({required this.pulse, required this.color, required this.radius})
      : super(repaint: pulse);

  final Animation<double> pulse;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha =
        LBBlock.glowAlphaLow + (LBBlock.glowAlphaHigh - LBBlock.glowAlphaLow) * pulse.value;
    LBGlowCache.drawRRectGlow(
      canvas,
      rrect: RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      color: color.withValues(alpha: LBBlock.glowAlphaHigh),
      sigma: 15,
      style: BlurStyle.outer,
      opacity: alpha / LBBlock.glowAlphaHigh,
    );
  }

  @override
  bool shouldRepaint(_GlowPulsePainter old) =>
      old.pulse != pulse || old.color != color || old.radius != radius;
}

class _BlockPainter extends CustomPainter {
  _BlockPainter({
    required this.kind,
    required this.palette,
    required this.radius,
    required this.selected,
    this.accent,
    this.glow = true,
  });

  final LBBlockKind kind;
  final LBPalette palette;
  final double radius;
  final bool selected;
  final Color? accent;

  /// Draw the static glow of filled kinds. Off while [_GlowPulsePainter]
  /// draws a breathing one instead.
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    // Inner stroke: deflate by half the stroke so it sits inside the bounds.
    final stroke = rr.deflate(.5);

    // Miami Nights paints a busy scene (palms, skyline, sun) behind every
    // screen. Outlined cards were see-through, so text sat on the city.
    // A dusk-violet base under the translucent kinds keeps the scene as
    // atmosphere around the cards instead of behind the words.
    final scene = ThemeScenes.ofPalette(p);
    if (scene != null &&
        kind != LBBlockKind.fill &&
        kind != LBBlockKind.goldFill &&
        kind != LBBlockKind.sheet) {
      canvas.drawRRect(rr, Paint()..color = scene.cardBase);
    }

    switch (kind) {
      case LBBlockKind.fill:
      case LBBlockKind.goldFill:
        final base = kind == LBBlockKind.fill ? (accent ?? p.lime) : LB.gold;
        // Cached: a fresh 15-sigma blur every frame was one of the largest
        // raster costs on Living Board screens (see LBGlowCache).
        if (glow) {
          LBGlowCache.drawRRectGlow(
            canvas,
            rrect: rr,
            color: base.withValues(alpha: .38),
            sigma: 15,
            style: BlurStyle.outer,
          );
        }
        // Themes with a scene may dress primary blocks in a gradient.
        final gradient = kind == LBBlockKind.fill && accent == null
            ? scene?.primaryGradient
            : null;
        canvas.drawRRect(
          rr,
          gradient != null
              ? (Paint()..shader = gradient.createShader(rect))
              : (Paint()..color = base),
        );
        _gridLines(canvas, rr, const Color(0x21000000));
      case LBBlockKind.gold:
        final c = accent ?? LB.gold;
        canvas.drawRRect(rr, Paint()..color = c.withValues(alpha: .12));
        _stroke(canvas, stroke, c.withValues(alpha: selected ? .9 : .6));
      case LBBlockKind.danger:
        canvas.drawRRect(rr, Paint()..color = LB.bonkFill);
        _stroke(canvas, stroke, LB.bonkStroke);
      case LBBlockKind.muted:
        canvas.drawRRect(rr, Paint()..color = p.lime.withValues(alpha: .05));
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
        canvas.drawRRect(rr, Paint()..color = c.withValues(alpha: selected ? .15 : .09));
        _stroke(canvas, stroke, c.withValues(alpha: selected ? .95 : .44));
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
      old.accent != accent ||
      old.glow != glow;
}
