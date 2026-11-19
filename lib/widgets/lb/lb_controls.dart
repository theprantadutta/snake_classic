import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/widgets/lb/lb_feedback.dart';
import 'package:snake_classic/widgets/lb/lb_pixel_icon.dart';

/// Two-cell switch (DESIGN_SPEC §3): off = `[lit grey][off]`,
/// on = `[off][lit lime]`.
///
/// Switching (MOTION_SPEC "Toggle"): the lit cell slides across over
/// [LBMotion.base] with springSoft, and the two cells light in sequence: the
/// cell being left keeps a fading afterglow while the destination cell
/// starts lighting [LBMotion.cellStagger] later, before the lit cell lands.
/// Reduce motion: instant.
class LBToggle extends StatefulWidget {
  const LBToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.cell = 18,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double cell;
  final String? semanticLabel;

  @override
  State<LBToggle> createState() => _LBToggleState();
}

class _LBToggleState extends State<LBToggle> with SingleTickerProviderStateMixin {
  /// 0..1 through one switch; 1 = settled at [widget.value].
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: LBMotion.base + LBMotion.cellStagger,
    value: 1,
  );

  @override
  void didUpdateWidget(LBToggle old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    if (LBMotion.reduced(context)) {
      _c.value = 1;
    } else {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final cell = widget.cell;
    return Semantics(
      toggled: widget.value,
      enabled: widget.onChanged != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onChanged == null
            ? null
            : () {
                LBFeedback.tap();
                widget.onChanged!(!widget.value);
              },
        child: Padding(
          // Pad the hit target to 48 dp tall without growing the visual.
          padding: EdgeInsets.symmetric(vertical: (48 - cell) / 2),
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(cell * 2, cell),
              painter: _TogglePainter(
                clock: _c,
                value: widget.value,
                cell: cell,
                onColor: p.lime,
                offInk: p.inkDim,
                off: p.cellOff,
                enabled: widget.onChanged != null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TogglePainter extends CustomPainter {
  _TogglePainter({
    required this.clock,
    required this.value,
    required this.cell,
    required this.onColor,
    required this.offInk,
    required this.off,
    required this.enabled,
  }) : super(repaint: clock);

  final AnimationController clock;
  final bool value;
  final double cell;
  final Color onColor;
  final Color offInk;
  final Color off;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final totalUs = (LBMotion.base + LBMotion.cellStagger).inMicroseconds;
    final elapsedUs = clock.value * totalUs;
    final slideT = (elapsedUs / LBMotion.base.inMicroseconds).clamp(0.0, 1.0);
    // Destination cell lights one cellStagger after the origin lets go.
    final lightT =
        ((elapsedUs - LBMotion.cellStagger.inMicroseconds) / LBMotion.base.inMicroseconds)
            .clamp(0.0, 1.0);

    final to = value ? 1.0 : 0.0;
    final from = 1 - to;
    // springSoft overshoots a touch past the destination cell, then settles.
    final slide = LBMotion.springSoft.transform(slideT);
    final pos = (from + (to - from) * slide).clamp(-.08, 1.08);
    // Colour follows the destination: lime when switching on, grey when off.
    final colorT = value ? LBMotion.standard.transform(lightT) : 1 - LBMotion.standard.transform(lightT);
    final lit = Color.lerp(offInk, onColor, colorT)!;
    Color dim(Color c) => enabled ? c : c.withValues(alpha: c.a * .4);

    canvas.drawRRect(lbCellRect(0, 0, cell), Paint()..color = off);
    canvas.drawRRect(lbCellRect(cell, 0, cell), Paint()..color = off);
    if (slideT < 1) {
      // Afterglow on the cell being left, fading as the lit cell leaves it.
      final glow = (1 - slideT) * .5;
      canvas.drawRRect(
        lbCellRect(cell * from, 0, cell),
        Paint()..color = dim(lit.withValues(alpha: glow)),
      );
      // The destination cell starts lighting before the lit cell lands.
      canvas.drawRRect(
        lbCellRect(cell * to, 0, cell),
        Paint()..color = dim(lit.withValues(alpha: lightT * .5)),
      );
    }
    canvas.drawRRect(lbCellRect(cell * pos, 0, cell), Paint()..color = dim(lit));
  }

  @override
  bool shouldRepaint(_TogglePainter old) =>
      old.clock != clock ||
      old.value != value ||
      old.cell != cell ||
      old.onColor != onColor ||
      old.offInk != offInk ||
      old.off != off ||
      old.enabled != enabled;
}

enum LBChipKind { outline, gold, danger }

/// 22 dp pill-ish tag, radius 5 (DESIGN_SPEC §3). Combo, power-up and status
/// chips.
class LBChip extends StatelessWidget {
  const LBChip({
    super.key,
    required this.label,
    this.kind = LBChipKind.outline,
    this.icon,
    this.height = 22,
  });

  final String label;
  final LBChipKind kind;
  final LBIcon? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final (fg, fill, stroke) = switch (kind) {
      LBChipKind.gold => (LB.gold, LB.goldFill, LB.goldStroke),
      LBChipKind.danger => (LB.bonk, LB.bonkFill, LB.bonkStroke),
      LBChipKind.outline => (p.head, p.blockFill, p.blockStroke),
    };
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            LBPixelIcon(icon!, cell: (height - 8) / 5, color: fg),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.label(p, color: fg).copyWith(fontSize: 10, letterSpacing: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uppercase section label with an optional right-aligned aside, as used
/// above every block group (`MODE ……… 8 MODES · 0 PAYWALLS`).
class LBSectionLabel extends StatelessWidget {
  const LBSectionLabel(this.text, {super.key, this.trailing, this.color});

  final String text;
  final String? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LBText.label(p, color: color),
            ),
          ),
          if (trailing != null)
            Flexible(
              child: Text(
                trailing!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: LBText.label(p, color: p.inkDim),
              ),
            ),
        ],
      ),
    );
  }
}
