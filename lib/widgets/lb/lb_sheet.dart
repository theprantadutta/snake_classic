import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/lb/lb_block.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/widgets/lb/lb_cells_bar.dart';

/// Opens a Living Board bottom sheet: a `sheet` block docked to the bottom,
/// a three-cell grab handle, an optional cell-font title and the body.
/// Width is capped on tablets (no-op on phones).
Future<T?> showLBSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  String? subtitle,
  bool isScrollControlled = true,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .6),
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (sheetContext) => LBSheetBody(
      title: title,
      subtitle: subtitle,
      child: Builder(builder: builder),
    ),
  );
}

/// The chrome of [showLBSheet], usable on its own for custom sheets.
class LBSheetBody extends StatelessWidget {
  const LBSheetBody({super.key, required this.child, this.title, this.subtitle});

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final maxH = MediaQuery.sizeOf(context).height * .88;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Container(
          decoration: BoxDecoration(
            color: p.deep,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(top: BorderSide(color: p.blockStroke)),
            boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 24)],
          ),
          padding: EdgeInsets.fromLTRB(
            LB.margin * context.uiScale,
            10,
            LB.margin * context.uiScale,
            16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: 30,
                  child: LBCellsBar(count: 3, value: 1, cell: 10, color: p.cellOff),
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 14),
                Semantics(header: true, child: LBCellText(title!, cell: 4, glow: true)),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!, style: LBText.body(p, size: 11.5)),
              ],
              const SizedBox(height: 14),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// A centred Living Board dialog with up to two actions. The [primary]
/// action gets the lime fill (one loud thing); [secondary] is an outline.
Future<T?> showLBDialog<T>({
  required BuildContext context,
  required String title,
  String? body,
  Widget? content,
  required String primaryLabel,
  required VoidCallback onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  LBBlockKind primaryKind = LBBlockKind.fill,
  bool barrierDismissible = true,
  Color? titleColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: .65),
    builder: (ctx) {
      final p = ctx.lb;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LBBlock(
            kind: LBBlockKind.sheet,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title.toUpperCase(),
                  style: LBText.button(p, color: titleColor ?? p.head, size: 14),
                ),
                if (body != null) ...[
                  const SizedBox(height: 10),
                  Text(body, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12)),
                ],
                if (content != null) ...[const SizedBox(height: 12), content],
                const SizedBox(height: 18),
                LBBlock(
                  kind: primaryKind,
                  height: 50,
                  alignment: Alignment.center,
                  onTap: onPrimary,
                  child: Text(
                    primaryLabel.toUpperCase(),
                    style: LBText.button(p, color: LBBlock.foregroundOf(primaryKind, p), size: 13),
                  ),
                ),
                if (secondaryLabel != null)
                  LBBlock(
                    kind: LBBlockKind.muted,
                    height: 46,
                    alignment: Alignment.center,
                    onTap: onSecondary ?? () => Navigator.of(ctx).pop(),
                    child: Text(
                      secondaryLabel.toUpperCase(),
                      style: LBText.button(p, color: p.inkMuted, size: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// A full-width row inside sheets and lists: icon, title, optional subline,
/// trailing widget. Tappable as one block.
class LBRow extends StatelessWidget {
  const LBRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.kind = LBBlockKind.outline,
    this.height,
    this.selected = false,
    this.titleColor,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final LBBlockKind kind;
  final double? height;
  final bool selected;
  final Color? titleColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = titleColor ?? LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      onTap: onTap,
      selected: selected,
      height: height,
      semanticLabel: semanticLabel,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: fg, size: 12.5),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: LBText.body(p, size: 11)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}
