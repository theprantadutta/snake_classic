import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Small Living Board pieces shared by the profile family of screens
/// (profile, statistics, replays, replay viewer, friends). Kept out of
/// `lib/widgets/lb/` on purpose: they are screen-level compositions of the
/// kit, not kit components.

/// Localized duration for stat values. The stats services return raw
/// seconds; the stDur* ARB keys carry the per-locale unit letters.
String lbDuration(AppLocalizations l10n, int seconds) {
  if (seconds < 60) return l10n.stDurSeconds(seconds);
  if (seconds < 3600) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? l10n.stDurMinutes(m) : l10n.stDurMinSec(m, s);
  }
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  return m == 0 ? l10n.stDurHours(h) : l10n.stDurHourMin(h, m);
}

/// The first visible character of [name], upper-cased, for avatars.
String lbInitialOf(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  return t.characters.first.toUpperCase();
}

/// One stat: an uppercase label over a loud number (Living Board screen 13).
class LBStatTile extends StatelessWidget {
  const LBStatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.kind = LBBlockKind.outline,
    this.height,
    this.onTap,
    this.footer,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final LBBlockKind kind;
  final double? height;
  final VoidCallback? onTap;

  /// Optional line under the value (a breakdown, a hint).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      kind: kind,
      height: height ?? context.lbCell * 4 - LB.inset * 2,
      onTap: onTap,
      semanticLabel: '$label $value',
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scales down rather than truncating long translated labels.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(label.toUpperCase(), maxLines: 1, style: LBText.label(p)),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: LBText.value(p, color: valueColor ?? p.ink, size: 22),
              ),
            ),
            if (footer != null) ...[const SizedBox(height: 6), footer!],
          ],
        ),
      ),
    );
  }
}

/// Lays [children] out two to a row, each row the same height.
class LBTwoColumns extends StatelessWidget {
  const LBTwoColumns({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// A two-cell-tall navigation block: pixel icon, label, and either a short
/// trailing aside (a count) or a pixel arrow.
class LBLinkBlock extends StatelessWidget {
  const LBLinkBlock({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.kind = LBBlockKind.outline,
  });

  final LBIcon icon;
  final String label;
  final VoidCallback? onTap;
  final String? trailing;
  final LBBlockKind kind;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = onTap == null ? p.inkDim : LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: onTap == null ? LBBlockKind.muted : kind,
      height: context.lbCell * 2.5 - LB.inset * 2,
      onTap: onTap,
      semanticLabel: trailing == null ? label : '$label, $trailing',
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ExcludeSemantics(
        child: Row(
          children: [
            LBPixelIcon(icon, cell: 3, color: onTap == null ? p.inkDim : p.lime),
            const SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: LBText.button(p, color: fg, size: 12.5).copyWith(letterSpacing: 1.8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (trailing != null)
              Text(trailing!, style: LBText.button(p, color: p.inkMuted, size: 11))
            else
              LBPixelIcon(LBIcon.next, cell: 1.8, color: p.lime),
          ],
        ),
      ),
    );
  }
}

/// A row of selectable blocks standing in for a Material TabBar. [counts]
/// adds a small number after a label (null or 0 hides it); [alertAt] marks
/// a count that wants attention (incoming requests) in the danger colour —
/// the number itself still carries the information.
class LBTabStrip extends StatelessWidget {
  const LBTabStrip({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.counts,
    this.alertAt,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final List<int?>? counts;
  final int? alertAt;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Semantics(
              selected: i == index,
              child: LBBlock(
                selected: i == index,
                height: context.lbCell * 2 - LB.inset * 2,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                onTap: i == index ? null : () => onChanged(i),
                semanticLabel: _semantic(i),
                child: ExcludeSemantics(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labels[i].toUpperCase(),
                          style: LBText.button(
                            p,
                            color: i == index ? p.head : p.inkMuted,
                            size: 11.5,
                          ),
                        ),
                        if ((counts?[i] ?? 0) > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            context.formatInt(counts![i]!),
                            style: LBText.button(
                              p,
                              color: i == alertAt ? LB.bonk : LB.gold,
                              size: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _semantic(int i) {
    final c = counts?[i] ?? 0;
    return c > 0 ? '${labels[i]}, $c' : labels[i];
  }
}

/// Empty state: a dashed block with an icon, a plain title and a line.
class LBEmptyBlock extends StatelessWidget {
  const LBEmptyBlock({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final LBIcon icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.dashed,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 5, color: p.inkDim),
          const SizedBox(height: 14),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: LBText.button(p, color: p.head, size: 13),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, textAlign: TextAlign.center, style: LBText.body(p, size: 11.5)),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// A scrollable that centres [child] in whatever height it is given, so an
/// empty state sits in the middle of the free space on any phone instead of
/// leaving a dead band under it. Always scrollable, so it works under a
/// RefreshIndicator.
class LBCenteredScroll extends StatelessWidget {
  const LBCenteredScroll({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final g = context.lbGutter;
    final pad = padding ?? EdgeInsets.fromLTRB(g, context.lbCell * .6, g, context.lbCell);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: pad,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: math.max(0, c.maxHeight - pad.vertical)),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Loading state: a row of cells lighting left → right, with a label.
class LBLoadingCells extends StatefulWidget {
  const LBLoadingCells({super.key, this.label});

  final String? label;

  @override
  State<LBLoadingCells> createState() => _LBLoadingCellsState();
}

class _LBLoadingCellsState extends State<LBLoadingCells> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 8 * 14,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => LBCellsBar(
                    count: 8,
                    value: reduce ? .5 : _c.value,
                    cell: 14,
                  ),
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 14),
                Text(widget.label!.toUpperCase(), style: LBText.label(p)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A square block holding a player's initial in the cell font.
class LBInitialAvatar extends StatelessWidget {
  const LBInitialAvatar({super.key, required this.name, required this.size, this.dim = false});

  final String name;
  final double size;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final initial = lbInitialOf(name);
    return ExcludeSemantics(
      child: LBBlock(
        kind: dim ? LBBlockKind.muted : LBBlockKind.outline,
        width: size - LB.inset * 2,
        height: size - LB.inset * 2,
        padding: EdgeInsets.all(size * .14),
        alignment: Alignment.center,
        child: LBCellText(
          initial,
          // 5 rows tall inside the block, leaving a margin.
          cell: size * .68 / 5,
          glow: !dim,
          color: dim ? p.inkMuted : p.lime,
        ),
      ),
    );
  }
}

/// A column-per-value bar chart drawn in cells. Each column is [rows] cells
/// tall; lit cells scale with the value against the largest one. Decorative:
/// callers put the same facts in text nearby.
class LBCellColumns extends StatelessWidget {
  const LBCellColumns({
    super.key,
    required this.values,
    this.rows = 6,
    this.labels,
    this.colorAt,
    this.minLit = 1,
  });

  final List<int> values;
  final int rows;

  /// One short label under each column (weekday names).
  final List<String>? labels;
  final Color Function(int index)? colorAt;

  /// Cells lit for any non-zero value, so a small one still shows.
  final int minLit;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, c) {
          final n = math.max(1, values.length);
          final cell = math.min(context.lbCell * .8, c.maxWidth / n);
          final maxV = values.isEmpty ? 0 : values.reduce(math.max);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: c.maxWidth,
                height: cell * rows,
                child: CustomPaint(
                  painter: _ColumnsPainter(
                    values: values,
                    rows: rows,
                    cell: cell,
                    maxV: maxV,
                    minLit: minLit,
                    lit: p.lime,
                    off: p.cellOff,
                    colorAt: colorAt,
                  ),
                ),
              ),
              if (labels != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final l in labels!)
                      Expanded(
                        child: Text(
                          l.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: LBText.label(p).copyWith(fontSize: 8, letterSpacing: .6),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ColumnsPainter extends CustomPainter {
  _ColumnsPainter({
    required this.values,
    required this.rows,
    required this.cell,
    required this.maxV,
    required this.minLit,
    required this.lit,
    required this.off,
    this.colorAt,
  });

  final List<int> values;
  final int rows;
  final double cell;
  final int maxV;
  final int minLit;
  final Color lit;
  final Color off;
  final Color Function(int index)? colorAt;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final slot = size.width / values.length;
    final offPaint = Paint()..color = off;
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      var n = maxV <= 0 ? 0 : (v / maxV * rows).round();
      if (v > 0 && n < minLit) n = minLit;
      final x = i * slot + (slot - cell) / 2;
      final litPaint = Paint()..color = colorAt?.call(i) ?? lit;
      for (var r = 0; r < rows; r++) {
        final y = size.height - (r + 1) * cell;
        canvas.drawRRect(lbCellRect(x, y, cell), r < n ? litPaint : offPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ColumnsPainter old) =>
      old.values != values ||
      old.rows != rows ||
      old.cell != cell ||
      old.maxV != maxV ||
      old.lit != lit ||
      old.off != off;
}
