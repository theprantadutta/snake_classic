import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_replay.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/profile/lb_profile_parts.dart';

/// Replays on the Living Board. Replays are phone-only: they live in the
/// Drift `replays` table and never leave the device.
class ReplaysScreen extends StatefulWidget {
  const ReplaysScreen({super.key});

  @override
  State<ReplaysScreen> createState() => _ReplaysScreenState();
}

class _ReplaysScreenState extends State<ReplaysScreen> {
  final StorageService _storageService = StorageService();
  List<GameReplay> _replays = [];
  bool _isLoading = true;
  int _tab = 0;
  StreamSubscription<List<GameReplay>>? _replaysSub;

  @override
  void initState() {
    super.initState();
    _subscribeToReplays();
  }

  @override
  void dispose() {
    _replaysSub?.cancel();
    super.dispose();
  }

  /// Subscribe to Drift's reactive replay stream. Every save (from the
  /// game-over flow) and every delete (from sanitize / the delete block)
  /// emits a new list, so the screen is always live — no manual refresh
  /// needed.
  void _subscribeToReplays() {
    _replaysSub = _storageService.watchReplays().listen(
      (replays) {
        if (!mounted) return;
        // Sanitize empty-frame rows in the background — they shouldn't
        // exist in the fresh write path, but a historical bug let them
        // accumulate. Schedule deletes off the stream callback so the
        // delete-then-watch-re-emits loop is well-behaved.
        final bad = replays
            .where((r) => r.frames.isEmpty || r.totalFrames == 0)
            .map((r) => r.id)
            .toList();
        // Purge the bad rows in the background, but DON'T skip the render —
        // show the valid replays immediately. If a delete ever fails the
        // bad rows would re-emit forever, and the old early-return left the
        // screen stuck on the loading spinner.
        for (final id in bad) {
          unawaited(_storageService.deleteReplay(id));
        }
        final sorted = [
          for (final r in replays)
            if (r.frames.isNotEmpty && r.totalFrames != 0) r,
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _replays = sorted;
          _isLoading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );
  }

  // No .take() cap because GameDao's saveReplay retention already caps
  // storage at top-10-by-score + 10-most-recent (~20 rows), so a manual cap
  // here would just hide rows the user actually has.
  List<GameReplay> get _recentReplays => _replays;

  List<GameReplay> get _highScoreReplays {
    final sorted = [..._replays];
    sorted.sort((a, b) => b.finalScore.compareTo(a.finalScore));
    return sorted;
  }

  List<GameReplay> get _crashReplays => _replays.where((r) => r.crashReason != null).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;
    final cell = context.lbCell;

    final (list, empty) = switch (_tab) {
      1 => (_highScoreReplays, l10n.rpNoBest),
      2 => (_crashReplays, l10n.rpNoCrashes),
      _ => (_recentReplays, l10n.rpNoRecent),
    };

    return LBScaffold(
      title: l10n.lbReplays,
      subtitle: l10n.lbReplaysSubtitle,
      trailing: !_isLoading && _replays.isNotEmpty
          ? Semantics(
              label: l10n.pfReplaysSaved(_replays.length),
              excludeSemantics: true,
              child: LBChip(label: context.formatInt(_replays.length), icon: LBIcon.film),
            )
          : null,
      body: _isLoading
          ? LBLoadingCells(label: l10n.rpLoading)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(g, cell * .9, g, 0),
                  child: LBTabStrip(
                    labels: [l10n.rpRecent, l10n.rpBest, l10n.rpCrashes],
                    index: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? LBCenteredScroll(
                          child: LBEmptyBlock(
                            icon: LBIcon.film,
                            title: empty,
                            subtitle: l10n.rpEmptySub,
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(g, cell * .6, g, cell * 1.5),
                          itemCount: list.length,
                          itemBuilder: (context, index) => _ReplayCard(
                            replay: list[index],
                            date: _formatDate(l10n, list[index].createdAt),
                            onOpen: () {
                              getIt<AnalyticsFacade>().trackReplayViewed();
                              context.push(
                                AppRoutes.replayViewerPath(list[index].id),
                                extra: list[index],
                              );
                            },
                            onWatch: () => context.push(
                              AppRoutes.replayViewerPath(list[index].id),
                              extra: list[index],
                            ),
                            onDelete: () => _deleteReplay(list[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return l10n.frMinutesAgo(diff.inMinutes);
      }
      return l10n.frHoursAgo(diff.inHours);
    } else if (diff.inDays == 1) {
      return l10n.rpYesterday;
    } else if (diff.inDays < 7) {
      return l10n.frDaysAgo(diff.inDays);
    } else {
      return context.formatDate(date);
    }
  }

  Future<void> _deleteReplay(GameReplay replay) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.rpDeleteTitle,
      body: l10n.rpDeleteBody(_formatDate(l10n, replay.createdAt)),
      primaryLabel: l10n.rpDelete,
      primaryKind: LBBlockKind.danger,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirmed == true) {
      try {
        // Drift watch re-emits automatically — no manual reload.
        await _storageService.deleteReplay(replay.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.rpDeleted));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(arcadeSnackBar(context, message: l10n.rpDeleteFailed));
        }
      }
    }
  }
}

/// One replay: when, how it ended, the score in snake cells, the run's
/// numbers, then WATCH and delete.
class _ReplayCard extends StatelessWidget {
  const _ReplayCard({
    required this.replay,
    required this.date,
    required this.onOpen,
    required this.onWatch,
    required this.onDelete,
  });

  final GameReplay replay;
  final String date;
  final VoidCallback onOpen;
  final VoidCallback onWatch;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final summary = replay.getSummary();
    final crashed = replay.crashReason != null;
    final outcome = switch (replay.crashReason) {
      'wall' => l10n.lbCrashWallTitle,
      'self' => l10n.lbCrashSelfTitle,
      null => l10n.lbReplayEnded,
      _ => l10n.lbCrashGeneric,
    };

    Widget stat(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: LBText.label(p).copyWith(fontSize: 8, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, style: LBText.value(p, size: 13)),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: LBBlock(
        onTap: onOpen,
        semanticLabel: '${l10n.rpScore} ${replay.finalScore}, $outcome, $date',
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        replay.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.button(p, color: p.ink, size: 12.5),
                      ),
                      const SizedBox(height: 2),
                      Text(date, style: LBText.body(p, size: 10.5)),
                    ],
                  ),
                ),
                LBChip(
                  label: outcome,
                  kind: crashed ? LBChipKind.danger : LBChipKind.outline,
                  icon: crashed ? LBIcon.x : LBIcon.check,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ExcludeSemantics(
                  child: LBCellText('${replay.finalScore}', cell: cell * .3, color: LB.gold, glow: true),
                ),
                const SizedBox(width: 8),
                Text(l10n.rpScore.toUpperCase(), style: LBText.label(p)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                stat(l10n.rpDuration, lbDuration(l10n, replay.gameTimeSeconds)),
                stat(l10n.rpFood, context.formatInt(summary['foodConsumed'] as int)),
                stat(l10n.rpMaxLength, context.formatInt(summary['maxLength'] as int)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                stat(l10n.rpFrames, context.formatInt(replay.totalFrames)),
                stat(l10n.pfPowerUps, context.formatInt(summary['powerUpsCollected'] as int)),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LBBlock(
                    selected: true,
                    height: cell * 2.4 - LB.inset * 2,
                    alignment: Alignment.center,
                    semanticLabel: l10n.rpWatch,
                    onTap: onWatch,
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LBPixelIcon(LBIcon.play, cell: 2.6, color: p.lime),
                          const SizedBox(width: 10),
                          Text(l10n.rpWatch.toUpperCase(), style: LBText.button(p, size: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                LBIconBlock(
                  icon: LBIcon.x,
                  kind: LBBlockKind.danger,
                  color: LB.bonk,
                  size: cell * 2.4,
                  semanticLabel: l10n.rpDelete,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
