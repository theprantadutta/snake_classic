import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/versus/versus_widgets.dart';

/// Match HUD and result card for the Versus match (renders 19 and 20).

/// `m:ss` from milliseconds — the match clock and SURVIVED.
String versusClock(int ms) {
  final totalSeconds = ms ~/ 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// The top of the match (render 19): you on the left in lime cell digits,
/// the clock and a LIVE dot in the middle, the rival on the right in red.
class VersusMatchHeader extends StatelessWidget {
  const VersusMatchHeader({
    super.key,
    required this.me,
    required this.opponent,
    required this.elapsedGameMs,
    required this.onLeave,
  });

  final MatchPlayerState? me;
  final MatchPlayerState? opponent;
  final int elapsedGameMs;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    return Padding(
      padding: EdgeInsets.fromLTRB(context.lbGutter, cell * .5, context.lbGutter, cell * .6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Side(
              player: me,
              name: l10n.lbYou,
              color: p.lime,
              end: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: cell * .4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Leaving sits between the two players, not beside either:
                // both names get the full width of their side.
                LBIconBlock(
                  icon: LBIcon.back,
                  isBack: true,
                  size: cell * 2.4,
                  semanticLabel: l10n.gameLeaveMatch,
                  onTap: onLeave,
                ),
                const SizedBox(height: 6),
                Text(
                  versusClock(elapsedGameMs),
                  style: LBText.value(p, size: 19).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: LB.bonk,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: LB.bonk.withValues(alpha: .6), blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(l10n.lbLive, style: LBText.label(p, color: LB.bonk)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _Side(
              player: opponent,
              name: opponent?.username ?? l10n.mpWaitingPlayer,
              color: LB.rival,
              end: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.player, required this.name, required this.color, required this.end});

  final MatchPlayerState? player;
  final String name;
  final Color color;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final alive = player?.alive ?? true;
    final connected = player?.connected ?? true;
    final score = player?.score ?? 0;
    final c = alive ? color : color.withValues(alpha: .45);

    // Usernames run to 20 characters: shrink a long one to fit rather than
    // cut it, so the rival is always fully named.
    final label = Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: end ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          name.toUpperCase(),
          maxLines: 1,
          style: LBText.label(p, color: c).copyWith(fontSize: 10.5, letterSpacing: 1.2),
        ),
      ),
    );
    final cells = VersusPlayerCells(color: color, cell: 6, dim: !alive);

    final String? note = !alive ? l10n.mpOut : (!connected ? l10n.mpReconnectingInline : null);

    return Semantics(
      liveRegion: true,
      label: '$name ${context.formatInt(score)}${note == null ? '' : ', $note'}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: end ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: end
                ? [label, const SizedBox(width: 8), cells]
                : [cells, const SizedBox(width: 8), label],
          ),
          const SizedBox(height: 8),
          LBAnimatedCellText(
            '$score',
            cell: 6.5 * context.uiScale,
            color: c,
            glow: alive,
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note.toUpperCase(),
              style: LBText.label(p, color: !alive ? LB.bonk : LB.gold).copyWith(fontSize: 8.5),
            ),
          ],
        ],
      ),
    );
  }
}

/// The split progress row (render 19): one cell per board column, lime for
/// your share of the combined score, red for the rival's. The scores are on
/// screen as numbers too, so colour is never the only signal.
class VersusSplitBar extends StatelessWidget {
  const VersusSplitBar({super.key, required this.myScore, required this.rivalScore, this.count = 18});

  final int myScore;
  final int rivalScore;
  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final total = myScore + rivalScore;
    // Each side keeps at least one cell so neither ever reads as wiped out.
    final frac = total == 0
        ? .5
        : (myScore / total).clamp(1 / count, (count - 1) / count).toDouble();
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBCellsBar(
            count: count,
            value: frac + 1e-6,
            color: p.lime,
            offColor: LB.rival.withValues(alpha: .55),
          ),
          const SizedBox(height: 3),
          Container(height: 1, color: p.wall),
        ],
      ),
    );
  }
}

/// The settled reward under the result (server-decided, fetched).
///
/// Rewards are server-decided and fetched, so there is a real gap between the
/// result arriving and the coins existing. This shows "processing" across that
/// gap and the settled amount afterwards. It never shows a locally-invented
/// figure, and it never queues a local grant — if the fetch is failing the
/// service is retrying, and the honest answer is "not yet".
class VersusRewardLine extends StatelessWidget {
  const VersusRewardLine({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;

    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      buildWhen: (prev, curr) =>
          prev.settlementStatus != curr.settlementStatus ||
          prev.settlement != curr.settlement,
      builder: (context, state) {
        if (state.settlementStatus == SettlementStatus.none) {
          return const SizedBox.shrink();
        }

        final settled = state.settlement;
        final processing =
            state.settlementStatus != SettlementStatus.applied || settled == null;

        // Nothing was awarded (a loss, or a match the server never settled).
        if (!processing && settled.coinsAwarded <= 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Semantics(
            liveRegion: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (processing)
                  const VersusBusyCells(cell: 5, color: LB.gold)
                else
                  const LBPixelIcon(LBIcon.coin, cell: 3, color: LB.gold),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    processing
                        ? l10n.mpRewardProcessing
                        : l10n.mpCoinReward(settled.coinsAwarded),
                    style: LBText.button(p, color: LB.gold.withValues(alpha: processing ? .75 : 1), size: 12.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum VersusOutcome { victory, defeat, draw }

/// The match verdict (render 20), shown in a dialog over the frozen board.
class VersusResultCard extends StatelessWidget {
  const VersusResultCard({
    super.key,
    required this.outcome,
    required this.line,
    this.line2,
    required this.myScore,
    required this.rivalScore,
    this.lengths,
    this.survived,
    required this.onBackToLobby,
    this.onRematch,
  });

  final VersusOutcome outcome;
  final String line;
  final String? line2;
  final int myScore;
  final int rivalScore;

  /// `4 · 6` — null when no snapshot carried the bodies.
  final String? lengths;

  /// `0:29` — null when unknown.
  final String? survived;
  final VoidCallback onBackToLobby;

  /// Null = no rematch offered (friend rooms re-invite from the lobby).
  final VoidCallback? onRematch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final (String title, Color titleColor, Color stripe) = switch (outcome) {
      VersusOutcome.victory => (l10n.lbVictory, p.lime, p.lime),
      VersusOutcome.defeat => (l10n.lbDefeat, LB.bonk, LB.bonk.withValues(alpha: .7)),
      VersusOutcome.draw => (l10n.lbDraw, p.ink, p.inkDim),
    };
    final scoreCell = 10 * context.uiScale;

    Widget scoreColumn(String label, int score, Color color) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: LBText.label(p)),
            const SizedBox(height: 10),
            LBCellText(
              '$score',
              cell: scoreCell,
              color: color,
              glow: true,
              semanticsLabel: '$label ${context.formatInt(score)}',
            ),
          ],
        );

    Widget statRow(String label, String value) => LBBlock(
          height: cell * 2.4,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: LBText.label(p))),
              Text(
                value,
                style: LBText.button(p, color: p.ink, size: 13)
                    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        );

    return LBBlock(
      kind: LBBlockKind.sheet,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 5, color: stripe),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Semantics(
                    header: true,
                    child: LBCellText(title, cell: 7.5 * context.uiScale, color: titleColor, glow: true),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  line,
                  textAlign: TextAlign.center,
                  style: LBText.button(p, color: p.ink, size: 12.5).copyWith(letterSpacing: .3, height: 1.4),
                ),
                if (line2 != null) ...[
                  const SizedBox(height: 8),
                  Text(line2!, textAlign: TextAlign.center, style: LBText.body(p, size: 11.5)),
                ],
                SizedBox(height: cell),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: Center(child: scoreColumn(l10n.lbYou, myScore, p.lime))),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(l10n.lbVs, style: LBText.button(p, color: p.inkDim, size: 13)),
                    ),
                    Expanded(child: Center(child: scoreColumn(l10n.lbRival, rivalScore, LB.rival))),
                  ],
                ),
                SizedBox(height: cell),
                if (lengths != null) statRow(l10n.lbLength, lengths!),
                if (survived != null) statRow(l10n.lbSurvived, survived!),
                const VersusRewardLine(),
                SizedBox(height: cell * .7),
                if (onRematch != null)
                  LBBlock(
                    kind: LBBlockKind.fill,
                    height: cell * 3,
                    alignment: Alignment.center,
                    semanticLabel: l10n.lbRematch,
                    onTap: onRematch,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LBPixelIcon(LBIcon.swords, cell: 3.4, color: p.onLime, accent: LB.bonk),
                        const SizedBox(width: 12),
                        Text(
                          l10n.lbRematch,
                          style: LBText.button(p, color: p.onLime, size: 15).copyWith(letterSpacing: 3),
                        ),
                      ],
                    ),
                  ),
                LBBlock(
                  height: cell * 3,
                  alignment: Alignment.center,
                  semanticLabel: l10n.lbBackToLobby,
                  onTap: onBackToLobby,
                  child: Text(
                    l10n.lbBackToLobby,
                    style: LBText.button(p, color: p.head, size: 13.5).copyWith(letterSpacing: 2.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The result dialog chrome: the card, then the footer line under it.
Future<void> showVersusResultDialog({
  required BuildContext context,
  required Widget Function(BuildContext dialogContext) card,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .7),
    builder: (dialogContext) {
      final p = dialogContext.lb;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: math.max(dialogContext.lbGutter, LB.margin),
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                card(dialogContext),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(dialogContext)!.lbVersusFooter,
                  textAlign: TextAlign.center,
                  style: LBText.body(p, color: p.inkDim, size: 11),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
