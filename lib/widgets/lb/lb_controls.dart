import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/widgets/lb/lb_feedback.dart';
import 'package:snake_classic/widgets/lb/lb_pixel_icon.dart';

/// Two-cell switch (DESIGN_SPEC §3): off = `[lit grey][off]`,
/// on = `[off][lit lime]`.
class LBToggle extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null
            ? null
            : () {
                LBFeedback.tap();
                onChanged!(!value);
              },
        child: Padding(
          // Pad the hit target to 48 dp tall without growing the visual.
          padding: EdgeInsets.symmetric(vertical: (48 - cell) / 2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value ? 1 : 0),
            duration: const Duration(milliseconds: 140),
            builder: (context, t, _) => CustomPaint(
              size: Size(cell * 2, cell),
              painter: _TogglePainter(
                t: t,
                cell: cell,
                on: Color.lerp(p.inkDim, p.lime, t)!,
                off: p.cellOff,
                enabled: onChanged != null,
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
    required this.t,
    required this.cell,
    required this.on,
    required this.off,
    required this.enabled,
  });

  final double t;
  final double cell;
  final Color on;
  final Color off;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(lbCellRect(0, 0, cell), Paint()..color = off);
    canvas.drawRRect(lbCellRect(cell, 0, cell), Paint()..color = off);
    final lit = Paint()..color = enabled ? on : on.withValues(alpha: .4);
    canvas.drawRRect(lbCellRect(cell * t, 0, cell), lit);
  }

  @override
  bool shouldRepaint(_TogglePainter old) =>
      old.t != t || old.on != on || old.off != off || old.enabled != enabled;
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
