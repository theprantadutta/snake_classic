import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Small Living Board pieces shared by the list screens (Ranks, Season,
/// Tournaments): block tabs, a loading state, an empty state and the
/// "Updated X ago" refresh line.

/// Tabs drawn as a row of blocks; the selected one is lime-filled. Driven
/// by a [TabController] so a [TabBarView] underneath keeps its swipe, and a
/// tap goes through [TabController.animateTo] exactly like a [TabBar] tap.
class LBTabBlocks extends StatelessWidget {
  const LBTabBlocks({super.key, required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: controller.index == i,
                child: LBBlock(
                  kind: controller.index == i ? LBBlockKind.fill : LBBlockKind.outline,
                  height: context.lbCell * 2.5,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  onTap: () => controller.animateTo(i),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[i].toUpperCase(),
                      maxLines: 1,
                      style: LBText.button(
                        p,
                        color: LBBlock.foregroundOf(
                          controller.index == i ? LBBlockKind.fill : LBBlockKind.outline,
                          p,
                        ),
                        size: 12,
                      ).copyWith(letterSpacing: 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A row of cells sweeping left→right over a label: the Living Board
/// spinner.
class LBLoadingState extends StatefulWidget {
  const LBLoadingState({super.key, required this.label});

  final String label;

  @override
  State<LBLoadingState> createState() => _LBLoadingStateState();
}

class _LBLoadingStateState extends State<LBLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) => LBCellsBar(
                count: 8,
                value: (_c.value * 9).floor() / 8,
                cell: 14,
                semanticsLabel: widget.label,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: LBText.body(p, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon, plain title, a secondary line and an optional action block.
class LBEmptyState extends StatelessWidget {
  const LBEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.line,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  final LBIcon icon;
  final String title;
  final String? line;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.lbGutter, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LBPixelIcon(icon, cell: 9, color: iconColor ?? p.cellOff),
            const SizedBox(height: 18),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: LBText.button(p, size: 14),
            ),
            if (line != null) ...[
              const SizedBox(height: 8),
              Text(line!, textAlign: TextAlign.center, style: LBText.body(p, size: 12)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              LBBlock(
                height: context.lbCell * 2.5,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                alignment: Alignment.center,
                onTap: onAction,
                child: Text(actionLabel!.toUpperCase(), style: LBText.button(p, size: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Updated 3m ago · REFRESH": cache freshness for an offline-first list,
/// tappable to force a refresh. [trailingNote] adds a line under it (the
/// offline notice, for instance).
class LBStaleRow extends StatelessWidget {
  const LBStaleRow({super.key, required this.label, required this.onTap, this.note});

  final String label;
  final VoidCallback onTap;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: '$label. ${l10n.lbRefresh}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          LBFeedback.tap();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.body(p, color: p.inkDim, size: 11),
                      ),
                    ),
                    Text(l10n.lbRefresh, style: LBText.label(p, color: p.lime)),
                  ],
                ),
                if (note != null)
                  Text(note!, style: LBText.body(p, color: p.inkMuted, size: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "just now" / "3m ago" … for the freshness line.
String lbRelativeAge(AppLocalizations l10n, DateTime ts) {
  final diff = DateTime.now().difference(ts);
  if (diff.inSeconds < 5) return l10n.frJustNow;
  if (diff.inSeconds < 60) return l10n.frSecondsAgo(diff.inSeconds);
  if (diff.inMinutes < 60) return l10n.frMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.frHoursAgo(diff.inHours);
  return l10n.frDaysAgo(diff.inDays);
}

/// Pull-to-refresh in board colours.
class LBRefresh extends StatelessWidget {
  const LBRefresh({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: p.onLime,
      backgroundColor: p.lime,
      child: child,
    );
  }
}
