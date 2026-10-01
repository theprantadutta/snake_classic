import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/providers/tournaments_provider.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/lb_list_bits.dart';
import 'package:snake_classic/widgets/lb_screens/tournaments/tournament_widgets.dart';

/// Tournaments on the Living Board: ACTIVE / HISTORY / MY STATS as block
/// tabs over the offline-first lists from [tournamentsProvider].
class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref.read(tournamentsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the tournaments state from Riverpod
    final tournamentsState = ref.watch(tournamentsProvider);
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;

    return LBScaffold(
      title: l10n.tnTitle,
      subtitle: l10n.lbTournamentsLine,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, 0),
            child: LBTabBlocks(
              controller: _tabController,
              labels: [l10n.tnActive, l10n.tnHistory, l10n.tnMyStats],
            ),
          ),
          // "Updated X ago · REFRESH": Drift cache freshness for the active
          // tab, so a stale offline view is labelled, and the refresh action.
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) => _buildStalenessRow(tournamentsState),
          ),
          Expanded(
            child: tournamentsState.isLoading
                ? LBLoadingState(label: l10n.tnLoading)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveTournaments(tournamentsState.activeTournaments),
                      _buildTournamentHistory(tournamentsState.historyTournaments),
                      _buildUserStats(tournamentsState.userStats),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// The My Stats tab has no cache of its own — fall back to whichever list
  /// was most recently touched so the user still gets a signal.
  Widget _buildStalenessRow(TournamentsState state) {
    final DateTime? ts;
    switch (_tabController.index) {
      case 0:
        ts = state.activeLastRefreshedAt;
        break;
      case 1:
        ts = state.historyLastRefreshedAt;
        break;
      default:
        ts = state.activeLastRefreshedAt ?? state.historyLastRefreshedAt;
    }

    final l10n = AppLocalizations.of(context)!;
    final label = ts == null
        ? l10n.frNoCacheYet
        : l10n.frUpdatedAgo(lbRelativeAge(l10n, ts));
    final g = context.lbGutter;
    return Padding(
      padding: EdgeInsets.fromLTRB(g + 2, 2, g + 2, 2),
      child: LBStaleRow(label: label, onTap: _loadData),
    );
  }

  EdgeInsets _listPadding() {
    final g = context.lbGutter;
    return EdgeInsets.fromLTRB(g, 4, g, context.lbCell);
  }

  Widget _buildActiveTournaments(List<Tournament> activeTournaments) {
    final l10n = AppLocalizations.of(context)!;
    if (activeTournaments.isEmpty) {
      return LBEmptyState(
        icon: LBIcon.trophy,
        title: l10n.tnNoActive,
        line: l10n.tnNoActiveSub,
      );
    }

    return ListView.builder(
      padding: _listPadding(),
      itemCount: activeTournaments.length,
      itemBuilder: (context, index) {
        final tournament = activeTournaments[index];
        return TournamentCard(
          tournament: tournament,
          onTap: () => _openTournamentDetail(tournament),
        );
      },
    );
  }

  Widget _buildTournamentHistory(List<Tournament> historyTournaments) {
    final l10n = AppLocalizations.of(context)!;
    if (historyTournaments.isEmpty) {
      return LBEmptyState(
        icon: LBIcon.hourglass,
        title: l10n.tnNoHistory,
        line: l10n.tnNoHistorySub,
      );
    }

    return ListView.builder(
      padding: _listPadding(),
      itemCount: historyTournaments.length,
      itemBuilder: (context, index) {
        final tournament = historyTournaments[index];
        return TournamentCard(
          tournament: tournament,
          showResults: true,
          onTap: () => _openTournamentDetail(tournament),
        );
      },
    );
  }

  Widget _buildUserStats(Map<String, dynamic> userStats) {
    final l10n = AppLocalizations.of(context)!;
    if (userStats.isEmpty) {
      return LBEmptyState(
        icon: LBIcon.chart,
        title: l10n.tnNoStats,
        line: l10n.tnNoStatsSub,
      );
    }

    return ListView(
      padding: _listPadding(),
      children: [
        LBSectionLabel(l10n.tnOverviewCard),
        Row(
          children: [
            Expanded(
              child: TournamentStatTile(
                label: l10n.tnTitle,
                value: '${userStats['totalTournaments'] ?? 0}',
                icon: LBIcon.trophy,
              ),
            ),
            Expanded(
              child: TournamentStatTile(
                label: l10n.tnWins,
                value: '${userStats['wins'] ?? 0}',
                icon: LBIcon.crown,
                gold: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TournamentStatTile(
                label: l10n.tnTopThree,
                value: '${userStats['topThreeFinishes'] ?? 0}',
                icon: LBIcon.star,
              ),
            ),
            Expanded(
              child: TournamentStatTile(
                label: l10n.tnBestScore,
                value: '${userStats['bestScore'] ?? 0}',
                icon: LBIcon.target,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TournamentSection(
          title: l10n.tnDetailedStats,
          icon: LBIcon.chart,
          child: Column(
            children: [
              TournamentDetailLine(
                label: l10n.tnTotalAttempts,
                value: '${userStats['totalAttempts'] ?? 0}',
              ),
              TournamentDetailLine(
                label: l10n.tnWinRate,
                value: l10n.tnPercentValue('${userStats['winRate'] ?? 0}'),
              ),
              TournamentDetailLine(
                label: l10n.tnAvgPerformance,
                value: l10n.tnTopPercent('${100 - (userStats['winRate'] ?? 0)}'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openTournamentDetail(Tournament tournament) {
    // Always the Guid `id`, never the `tournamentId` slug.
    context.push(
      AppRoutes.tournamentDetailPath(tournament.id),
      extra: tournament,
    );
  }
}
