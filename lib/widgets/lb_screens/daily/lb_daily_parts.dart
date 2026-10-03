import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/models/daily_challenge.dart' show ChallengeDifficulty;
import 'package:snake_classic/widgets/lb/lb.dart';

/// Shared Living Board pieces for the Daily (09), Weekly and Trophies (10)
/// screens and their popups. Private to those surfaces — the general
/// components live in `lib/widgets/lb/`.

/// "6h 12m" / "12m" / "3d 4h" for a reset countdown. Never negative.
String lbResetCountdown(AppLocalizations l10n, Duration d) {
  final left = d.isNegative ? Duration.zero : d;
  if (left.inDays >= 1) {
    return l10n.lbDurDayHour('${left.inDays}', '${left.inHours % 24}');
  }
  if (left.inHours >= 1) return l10n.stDurHourMin(left.inHours, left.inMinutes % 60);
  return l10n.stDurMinutes(left.inMinutes < 1 ? 1 : left.inMinutes);
}

/// Time until the next local midnight — when daily challenges roll over
/// (DailyChallengeService anchors each day's rows to local start-of-day).
Duration lbUntilLocalMidnight() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1).difference(now);
}

/// A 5×5 glyph in the pixel-icon format ('x' lit, '.' off) for the one
/// icon this screen needs that the kit's set does not have.
class LBGlyph extends StatelessWidget {
  const LBGlyph(this.rows, {super.key, this.cell = 3, this.color});

  final List<String> rows;
  final double cell;
  final Color? color;

  /// A circular arrow.
  static const refresh = ['.##.x', 'x..xx', 'x....', 'x...x', '.###.'];

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? context.lb.lime;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(cell * rows.first.length, cell * rows.length),
        painter: _GlyphPainter(rows, cell, c),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.rows, this.cell, this.color);

  final List<String> rows;
  final double cell;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        if (rows[r][c] != '.') path.addRRect(lbCellRect(c * cell, r * cell, cell));
      }
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.rows != rows || old.cell != cell || old.color != color;
}

/// The 2×2 header refresh block. Shows an hourglass while a refresh runs.
class LBRefreshBlock extends StatelessWidget {
  const LBRefreshBlock({super.key, required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.lbCell * 2;
    final p = context.lb;
    return LBBlock(
      width: s - LB.inset * 2,
      height: s - LB.inset * 2,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      semanticLabel: AppLocalizations.of(context)!.lbRefresh,
      onTap: busy ? null : onTap,
      child: busy
          ? LBPixelIcon(LBIcon.hourglass, cell: s / 12.5, color: p.inkDim)
          : LBGlyph(LBGlyph.refresh, cell: s / 12.5, color: p.lime),
    );
  }
}

/// Difficulty as a coloured word. The word carries the meaning; the colour
/// (lime / gold / bonk) only reinforces it.
class LBDifficultyLabel extends StatelessWidget {
  const LBDifficultyLabel(this.difficulty, {super.key});

  final ChallengeDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final color = switch (difficulty) {
      ChallengeDifficulty.easy => p.lime,
      ChallengeDifficulty.medium => LB.gold,
      ChallengeDifficulty.hard => LB.bonk,
    };
    return Text(
      difficulty.localizedName(AppLocalizations.of(context)!).toUpperCase(),
      style: LBText.label(p, color: color).copyWith(fontSize: 9.5),
    );
  }
}

/// The trailing action of a quest block.
sealed class LBQuestAction {
  const LBQuestAction();
}

class LBQuestClaim extends LBQuestAction {
  const LBQuestClaim(this.onClaim);
  final VoidCallback onClaim;
}

class LBQuestClaimed extends LBQuestAction {
  const LBQuestClaimed();
}

class LBQuestPlay extends LBQuestAction {
  const LBQuestPlay(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
}

/// One daily challenge or weekly quest (screen 09): icon, title,
/// difficulty, the server's description, a cells progress bar with the
/// count, the reward line and CLAIM / CLAIMED / PLAY {MODE}.
class LBQuestBlock extends StatelessWidget {
  const LBQuestBlock({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.current,
    required this.target,
    required this.progress,
    required this.completed,
    required this.rewardLine,
    this.action,
  });

  final LBIcon icon;
  final String title;
  final String description;
  final ChallengeDifficulty? difficulty;
  final int current;
  final int target;
  final double progress;
  final bool completed;
  final String rewardLine;
  final LBQuestAction? action;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    final act = action;
    final claimable = act is LBQuestClaim;
    final claimed = act is LBQuestClaimed;
    final kind = claimable
        ? LBBlockKind.gold
        : claimed
            ? LBBlockKind.muted
            : LBBlockKind.outline;
    final titleColor = claimed ? p.inkMuted : p.ink;
    final barColor = completed ? LB.gold : p.lime;

    return LBBlock(
      kind: kind,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LBPixelIcon(
                claimed ? LBIcon.check : icon,
                cell: 3.2,
                color: claimed ? p.inkDim : (completed ? LB.gold : p.lime),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: titleColor, size: 13.5).copyWith(letterSpacing: 1.6),
                ),
              ),
              if (difficulty != null) ...[
                const SizedBox(width: 8),
                LBDifficultyLabel(difficulty!),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: LBText.body(p, color: p.ink.withValues(alpha: claimed ? .45 : .72), size: 11.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: LBCellsBar(
                  count: 15,
                  value: progress,
                  color: barColor,
                  semanticsLabel: title,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 3,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${context.formatInt(current)}/${context.formatInt(target)}',
                      maxLines: 1,
                      style: LBText.button(p, color: completed ? LB.gold : p.ink, size: 12.5)
                          .copyWith(letterSpacing: .4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                LBPixelIcon(LBIcon.coin, cell: 2.8, color: claimed ? p.inkDim : LB.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rewardLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.button(p, color: claimed ? p.inkDim : p.inkMuted, size: 11.5)
                        .copyWith(letterSpacing: .6),
                  ),
                ),
                switch (act) {
                  LBQuestClaim(:final onClaim) => LBBlock(
                      kind: LBBlockKind.goldFill,
                      width: context.lbCell * 4.5,
                      height: 44,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      onTap: onClaim,
                      child: Text(
                        l10n.lbClaim,
                        style: LBText.button(
                          p,
                          color: LBBlock.foregroundOf(LBBlockKind.goldFill, p),
                          size: 12.5,
                        ).copyWith(letterSpacing: 2),
                      ),
                    ),
                  LBQuestClaimed() => Text(l10n.lbClaimed, style: LBText.label(p, color: p.inkDim)),
                  LBQuestPlay(:final label, :final onTap) => _PlayLink(label: label, onTap: onTap),
                  null => const SizedBox.shrink(),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayLink extends StatelessWidget {
  const _PlayLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          LBFeedback.tap();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            widthFactor: 1,
            child: Text(
              '${label.toUpperCase()} →',
              style: LBText.button(p, color: p.lime, size: 12.5).copyWith(letterSpacing: 1.8),
            ),
          ),
        ),
      ),
    );
  }
}

/// "2 OF 3 DONE" with one cell per item and a subline (streak / reset).
class LBDailyProgressBlock extends StatelessWidget {
  const LBDailyProgressBlock({
    super.key,
    required this.done,
    required this.total,
    required this.subline,
    this.icon = LBIcon.gift,
  });

  final int done;
  final int total;
  final String? subline;
  final LBIcon icon;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    final count = total.clamp(1, 10);
    final cell = total <= 4 ? 22.0 : 14.0;
    return LBBlock(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          LBCellsBar(
            count: count,
            value: total == 0 ? 0 : done / total,
            cell: cell,
            color: LB.gold,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.lbDailyProgress(context.formatInt(done), context.formatInt(total)),
                  style: LBText.button(p, color: p.ink, size: 13.5).copyWith(letterSpacing: 2),
                ),
                if (subline != null) ...[
                  const SizedBox(height: 3),
                  Text(subline!, style: LBText.body(p, size: 11)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          LBPixelIcon(icon, cell: 3.6, color: LB.gold),
        ],
      ),
    );
  }
}

/// A quest-shaped placeholder while the list loads, so nothing below it
/// jumps when the real rows arrive.
class LBQuestSkeleton extends StatelessWidget {
  const LBQuestSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    Widget bone(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(color: p.cellOff, borderRadius: BorderRadius.circular(3)),
        );
    return LBBlock(
      kind: LBBlockKind.muted,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bone(150, 13),
          const SizedBox(height: 10),
          bone(220, 10),
          const SizedBox(height: 14),
          LBCellsBar(count: 15, value: 0, offColor: p.cellOff),
          const SizedBox(height: 14),
          bone(110, 11),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(begin: .55, end: 1, duration: 800.ms);
  }
}

/// A one-line muted block for empty states.
class LBEmptyBlock extends StatelessWidget {
  const LBEmptyBlock({
    super.key,
    required this.title,
    this.line,
    this.icon,
    this.action,
    this.expanded = false,
  });

  final String title;
  final String? line;
  final LBIcon? icon;

  /// A button under the line (e.g. TRY AGAIN).
  final Widget? action;

  /// Centred and stacked, for an empty state that fills the space a list
  /// would have taken instead of leaving a dead band under a short row.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    if (expanded) {
      return LBBlock(
        kind: LBBlockKind.muted,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              LBPixelIcon(icon!, cell: 6, color: p.inkDim),
              const SizedBox(height: 16),
            ],
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: LBText.button(p, color: p.inkMuted, size: 14).copyWith(letterSpacing: 2),
            ),
            if (line != null) ...[
              const SizedBox(height: 8),
              Text(line!, textAlign: TextAlign.center, style: LBText.body(p, size: 12)),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      );
    }
    return LBBlock(
      kind: LBBlockKind.muted,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          if (icon != null) ...[
            LBPixelIcon(icon!, cell: 3.4, color: p.inkDim),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title.toUpperCase(), style: LBText.button(p, color: p.inkMuted, size: 12.5)),
                if (line != null) ...[
                  const SizedBox(height: 4),
                  Text(line!, style: LBText.body(p, size: 11)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Trophies ====================

/// Rarity colour from the Living Board constants (DESIGN_SPEC: rarity
/// stripe), not the model's legacy Material colour.
Color lbRarityColor(AchievementRarity r) => switch (r) {
      AchievementRarity.common => LB.common,
      AchievementRarity.rare => LB.rare,
      AchievementRarity.epic => LB.epic,
      AchievementRarity.legendary => LB.legendary,
      AchievementRarity.diamond => LB.diamond,
    };

/// A pixel icon for an achievement, by its category.
LBIcon lbTrophyIcon(AchievementType t) => switch (t) {
      AchievementType.score => LBIcon.star,
      AchievementType.games => LBIcon.play,
      AchievementType.streak => LBIcon.flame,
      AchievementType.survival => LBIcon.hourglass,
      AchievementType.special => LBIcon.crown,
      AchievementType.general => LBIcon.trophy,
    };
