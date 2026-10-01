import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Living Board pieces shared by the tournament list and detail screens.

LBIcon tournamentTypeIcon(TournamentType type) => switch (type) {
      TournamentType.daily => LBIcon.calendar,
      TournamentType.weekly => LBIcon.star,
      TournamentType.special => LBIcon.crown,
    };

/// Special tournaments carry gold; the rest the board colour.
Color tournamentTypeColor(BuildContext context, TournamentType type) =>
    type == TournamentType.special ? LB.gold : context.lb.lime;

/// Gold / silver / bronze for the top three, the board colour after.
Color tournamentRankColor(BuildContext context, int rank) => switch (rank) {
      1 => LB.first,
      2 => LB.second,
      3 => LB.third,
      _ => context.lb.lime,
    };

class TournamentStatusChip extends StatelessWidget {
  const TournamentStatusChip({super.key, required this.status});

  final TournamentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LBChip(
      label: status.localizedName(l10n).toUpperCase(),
      icon: status == TournamentStatus.active ? LBIcon.play : null,
    );
  }
}

/// ENDS IN / STARTS IN over the time left in the cell font. Nothing once
/// the tournament has ended (the status chip already says so).
class TournamentCountdown extends StatelessWidget {
  const TournamentCountdown({super.key, required this.tournament, this.cell = 3.4});

  final Tournament tournament;
  final double cell;

  @override
  Widget build(BuildContext context) {
    if (tournament.status == TournamentStatus.ended) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final label = tournament.status == TournamentStatus.upcoming
        ? l10n.lbStartsIn
        : l10n.lbEndsIn;
    final time = tournament.timeRemainingFormatted;
    return Semantics(
      label: '$label $time',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: LBText.label(p)),
          const SizedBox(height: 6),
          LBCellText(time.toUpperCase(), cell: cell * context.uiScale),
        ],
      ),
    );
  }
}

/// One tournament in the ACTIVE / HISTORY lists.
class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onTap,
    this.showResults = false,
  });

  final Tournament tournament;
  final VoidCallback onTap;
  final bool showResults;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final t = tournament;
    final typeColor = tournamentTypeColor(context, t.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: LBBlock(
        selected: t.status == TournamentStatus.active,
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: LBPixelIcon(tournamentTypeIcon(t.type), cell: 4, color: typeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.localizedName(l10n, Localizations.localeOf(context)).toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.button(p, color: p.ink, size: 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t.type.localizedName(l10n).toUpperCase(),
                        style: LBText.label(
                          p,
                          color: t.type == TournamentType.special ? LB.gold : p.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TournamentStatusChip(status: t.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              t.localizedDescription(l10n),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: LBText.body(p, size: 11.5),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: TournamentCountdown(tournament: t)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LBChip(label: t.gameMode.localizedName(l10n).toUpperCase()),
                    const SizedBox(height: 6),
                    Text(
                      l10n.tnPlayersCount(t.currentParticipants, t.maxParticipants),
                      style: LBText.body(p, color: p.inkMuted, size: 11),
                    ),
                  ],
                ),
              ],
            ),
            if (t.hasJoined) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  LBChip(label: l10n.tnJoined.toUpperCase(), icon: LBIcon.check),
                  const Spacer(),
                  if (t.userBestScore != null)
                    Semantics(
                      label: l10n.tnBestScoreChip(t.userBestScore!),
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.lbYourBest, style: LBText.label(p, color: LB.gold)),
                          const SizedBox(width: 8),
                          LBCellText(
                            '${t.userBestScore}',
                            cell: 3 * context.uiScale,
                            color: LB.gold,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            if (showResults && t.userReward != null) ...[
              const SizedBox(height: 10),
              LBBlock(
                kind: LBBlockKind.gold,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const LBPixelIcon(LBIcon.trophy, cell: 3.4, color: LB.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tnRankReward(
                              t.userRank,
                              localizedTournamentRewardName(t.userReward!.name, l10n),
                            ),
                            style: LBText.button(p, color: LB.gold, size: 12),
                          ),
                          if (t.userReward!.coins > 0)
                            Text(
                              l10n.mpCoinReward(t.userReward!.coins),
                              style: LBText.body(p, size: 11),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!showResults && t.rewards.isNotEmpty) ...[
              const SizedBox(height: 10),
              LBBlock(
                kind: LBBlockKind.gold,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const LBPixelIcon(LBIcon.gift, cell: 3, color: LB.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.tnRewardsAvailable(t.rewards.length).toUpperCase(),
                        style: LBText.button(p, color: LB.gold, size: 11),
                      ),
                    ),
                    Text(l10n.tnViewDetails, style: LBText.body(p, color: p.inkMuted, size: 10.5)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A big number in the cell font over its label (MY STATS tiles).
class TournamentStatTile extends StatelessWidget {
  const TournamentStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.gold = false,
  });

  final String label;
  final String value;
  final LBIcon icon;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final color = gold ? LB.gold : p.lime;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: LBBlock(
        kind: gold ? LBBlockKind.gold : LBBlockKind.outline,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LBPixelIcon(icon, cell: 2.6, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 2,
                    style: LBText.label(p, color: gold ? LB.gold : p.inkMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LBCellText(value, cell: 5 * context.uiScale, color: color),
          ],
        ),
      ),
    );
  }
}

/// A section block: an uppercase label line over its content.
class TournamentSection extends StatelessWidget {
  const TournamentSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.gold = false,
  });

  final String title;
  final Widget child;
  final LBIcon? icon;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final color = gold ? LB.gold : p.head;
    return LBBlock(
      kind: gold ? LBBlockKind.gold : LBBlockKind.outline,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                if (icon != null) ...[
                  LBPixelIcon(icon!, cell: 3, color: color),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(title.toUpperCase(), style: LBText.button(p, color: color, size: 12.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Label on the left, value on the right.
class TournamentDetailLine extends StatelessWidget {
  const TournamentDetailLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: LBText.body(p, size: 12))),
          const SizedBox(width: 8),
          Text(value, style: LBText.button(p, color: p.ink, size: 12.5)),
        ],
      ),
    );
  }
}
