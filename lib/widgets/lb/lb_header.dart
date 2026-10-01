import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_block.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/widgets/lb/lb_feedback.dart';
import 'package:snake_classic/widgets/lb/lb_grid_background.dart';
import 'package:snake_classic/widgets/lb/lb_pixel_icon.dart';

/// Screen header (DESIGN_SPEC §2): a 2×2-cell back block, the title in the
/// cell font (cell 6), an optional right action, and a subtitle line.
class LBHeader extends StatelessWidget {
  const LBHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;

  /// Right-aligned action (usually a 2×2 [LBIconBlock]).
  final Widget? trailing;

  /// Defaults to popping the route.
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final cell = context.lbCell;
    return Padding(
      padding: EdgeInsets.fromLTRB(context.lbGutter, cell * .5, context.lbGutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: cell * 2,
            child: Row(
              children: [
                if (showBack) ...[
                  LBIconBlock(
                    icon: LBIcon.back,
                    semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                    isBack: true,
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(width: cell * .5),
                ],
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Semantics(
                      header: true,
                      child: LBCellText(title, cell: 6 * context.lbCell / LB.cell, glow: true),
                    ),
                  ),
                ),
                if (trailing != null) ...[SizedBox(width: cell * .5), trailing!],
              ],
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: cell * .9),
              child: Text(subtitle!, style: LBText.body(p, size: 12)),
            ),
        ],
      ),
    );
  }
}

/// A square 2×2-cell block holding one pixel icon — back buttons, header
/// actions, the home menu block.
class LBIconBlock extends StatelessWidget {
  const LBIconBlock({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.kind = LBBlockKind.outline,
    this.size,
    this.isBack = false,
    this.color,
  });

  final LBIcon icon;
  final VoidCallback? onTap;
  final String semanticLabel;
  final LBBlockKind kind;

  /// Outer size in dp; defaults to 2 cells.
  final double? size;
  final bool isBack;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = size ?? context.lbCell * 2;
    return LBBlock(
      kind: kind,
      width: s - LB.inset * 2,
      height: s - LB.inset * 2,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      semanticLabel: semanticLabel,
      feedback: !isBack,
      onTap: onTap == null
          ? null
          : () {
              if (isBack) LBFeedback.back();
              onTap!();
            },
      child: LBPixelIcon(icon, cell: s / 12.5, color: color),
    );
  }
}
