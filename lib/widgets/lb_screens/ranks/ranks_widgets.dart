import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// One leaderboard line, already resolved to display values so the global,
/// weekly and friends boards share the same podium and rows.
class RanksEntry {
  const RanksEntry({
    required this.rank,
    required this.name,
    required this.score,
    this.line,
    this.isYou = false,
  });

  final int rank;
  final String name;
  final int score;

  /// Secondary line ("23 runs", "23 runs · GUEST").
  final String? line;
  final bool isYou;
}

/// The top three as gold / silver / bronze blocks (Ranks mock 12), first in
/// the middle and tallest. Missing places render as dashed slots so a board
/// with one or two players still reads as a podium.
class RanksPodium extends StatelessWidget {
  const RanksPodium({super.key, required this.top});

  /// Up to three entries, first place first.
  final List<RanksEntry> top;

  @override
  Widget build(BuildContext context) {
    RanksEntry? at(int i) => i < top.length ? top[i] : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 5, child: _PodiumPlace(entry: at(1), place: 2)),
        Expanded(flex: 6, child: _PodiumPlace(entry: at(0), place: 1)),
        Expanded(flex: 5, child: _PodiumPlace(entry: at(2), place: 3)),
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({required this.entry, required this.place});

  final RanksEntry? entry;
  final int place;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    final cell = context.lbCell;
    final color = switch (place) {
      1 => LB.first,
      2 => LB.second,
      _ => LB.third,
    };
    // 6 / 5 / 4 cells on the 780 dp reference frame, growing a little on
    // taller phones and shrinking on short ones so the first screenful
    // keeps room for the rows under it.
    final heightScale =
        (MediaQuery.sizeOf(context).height / 780).clamp(.8, 1.25).toDouble();
    final height =
        cell * heightScale * switch (place) { 1 => 6.0, 2 => 5.0, _ => 4.0 };
    final e = entry;
    final dark = LBBlock.foregroundOf(LBBlockKind.fill, p);

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (e != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              e.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: LBText.button(p, color: p.ink, size: 10.5).copyWith(letterSpacing: .2),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            context.formatInt(e.score),
            style: LBText.value(p, color: color, size: 14),
          ),
          if (e.isYou) ...[
            const SizedBox(height: 3),
            LBChip(label: l10n.lbYou, height: 18),
          ],
          const SizedBox(height: 6),
        ],
        LBBlock(
          kind: e == null ? LBBlockKind.dashed : LBBlockKind.fill,
          accent: color,
          height: height,
          padding: EdgeInsets.only(top: cell * .6),
          alignment: Alignment.topCenter,
          child: e == null
              ? null
              : LBCellText('$place', cell: 6.5 * context.uiScale, color: dark),
        ),
      ],
    );

    if (e == null) return ExcludeSemantics(child: column);
    return Semantics(
      label: '${l10n.frRankBadge(place)}, ${e.name}, ${context.formatInt(e.score)}'
          '${e.isYou ? ', ${l10n.lbYou}' : ''}',
      excludeSemantics: true,
      child: column,
    );
  }
}

/// A plain leaderboard row: rank, name, secondary line, score.
class RanksRow extends StatelessWidget {
  const RanksRow({super.key, required this.entry});

  final RanksEntry entry;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final l10n = AppLocalizations.of(context)!;
    final e = entry;
    return Semantics(
      label: '${l10n.frRankBadge(e.rank)}, ${e.name}, ${context.formatInt(e.score)}'
          '${e.isYou ? ', ${l10n.lbYou}' : ''}',
      excludeSemantics: true,
      child: LBBlock(
        selected: e.isYou,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '${e.rank}',
                maxLines: 1,
                style: LBText.value(p, color: p.inkMuted, size: 13),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          e.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LBText.button(p, color: e.isYou ? p.head : p.ink, size: 12.5)
                              .copyWith(letterSpacing: .2),
                        ),
                      ),
                      if (e.isYou) ...[
                        const SizedBox(width: 8),
                        LBChip(label: l10n.lbYou, height: 18),
                      ],
                    ],
                  ),
                  if (e.line != null)
                    Text(
                      e.line!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LBText.body(p, color: p.inkDim, size: 11),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.formatInt(e.score),
              style: LBText.value(p, color: p.ink, size: 15),
            ),
          ],
        ),
      ),
    );
  }
}

/// The pinned lime "YOU" row at the bottom of the board.
class RanksYouRow extends StatelessWidget {
  const RanksYouRow({super.key, required this.title, this.score, this.line});

  /// "#2,481 · YOU · name" or "YOU · name".
  final String title;

  /// The player's own score for this board, when it is actually known.
  final int? score;

  /// Gap to #1, the leader line, or a state line (easy-only / offline).
  final String? line;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(LBBlockKind.fill, p);
    return Semantics(
      container: true,
      child: LBBlock(
        kind: LBBlockKind.fill,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.button(p, color: fg, size: 13).copyWith(letterSpacing: .6),
                  ),
                ),
                if (score != null) ...[
                  const SizedBox(width: 10),
                  Text(context.formatInt(score!), style: LBText.value(p, color: fg, size: 18)),
                ],
              ],
            ),
            if (line != null) ...[
              const SizedBox(height: 4),
              Text(
                line!,
                style: LBText.body(p, color: fg.withValues(alpha: .8), size: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
