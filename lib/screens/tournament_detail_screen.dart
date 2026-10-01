import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/tournament_service.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/lb_list_bits.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/ranks_widgets.dart';
import 'package:snake_classic/widgets/lb_screens/tournaments/tournament_widgets.dart';

/// Tournament detail on the Living Board: the info block (status, mode,
/// countdown in the cell font, your rank in gold), OVERVIEW / LEADERBOARD /
/// RULES block tabs, and the JOIN / PLAY NOW bar. Entry, ad and purchase
/// flows are unchanged: bronze via rewarded ad or Pro, silver and gold via
/// the tournament_silver / tournament_gold products.
class TournamentDetailScreen extends StatefulWidget {
  /// The tournament ID for deep link support.
  final String tournamentId;

  /// Optional tournament object (for instant display when navigating with object).
  final Tournament? tournament;

  const TournamentDetailScreen({
    super.key,
    required this.tournamentId,
    this.tournament,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  final TournamentService _tournamentService = TournamentService();

  late TabController _tabController;
  Tournament? _tournament;
  List<TournamentParticipant> _leaderboard = [];
  // Server-authoritative rank for the current user — set from the
  // leaderboard response's current_user_rank. Preferred over the
  // local Tournament.userRank computation, which only sees the 50-item
  // slice and is wrong for users outside the top 50.
  int? _serverUserRank;
  bool _isLoading = false;
  // Distinguishes "leaderboard load actually failed" from "load returned
  // empty list" so the UI can show a retry button instead of pretending
  // the tournament has no participants.
  bool _leaderboardLoadFailed = false;
  bool _isLoadingTournament = false;
  bool _isJoining = false;
  // Error codes ('not_found' / 'load_failed') rather than user-facing
  // strings — resolved to localized text at render time in
  // _buildContent, where a BuildContext with AppLocalizations exists.
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
    _tabController = TabController(length: 3, vsync: this);

    if (_tournament != null) {
      // Tournament provided via navigation, load leaderboard
      _loadLeaderboard();
    } else {
      // Deep link: need to load tournament from service
      _loadTournamentFromId();
    }
  }

  Future<void> _loadTournamentFromId() async {
    setState(() {
      _isLoadingTournament = true;
      _loadError = null;
    });

    try {
      // Cache first, so a deep link opened from inside the app paints
      // instantly. Then the network on a miss — a deep link is precisely the
      // case where the cache is cold. A notification tap can be the first
      // tournament screen of the session, and the list that fills the cache
      // was never opened; reading only the cache reported "Tournament not
      // found" for a tournament that exists and is running right now.
      var tournament = await _tournamentService.getTournament(
        widget.tournamentId,
      );
      tournament ??= await _tournamentService.refreshTournament(
        widget.tournamentId,
      );
      if (mounted) {
        if (tournament != null) {
          setState(() {
            _tournament = tournament;
            _isLoadingTournament = false;
          });
          _loadLeaderboard();
        } else {
          setState(() {
            _loadError = 'not_found';
            _isLoadingTournament = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = 'load_failed';
          _isLoadingTournament = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    if (_tournament == null) return;

    setState(() {
      _isLoading = true;
      _leaderboardLoadFailed = false;
    });

    try {
      final result = await _tournamentService.getTournamentLeaderboard(
        _tournament!.id,
      );
      // The leaderboard fetch is a network round trip, so the user can
      // leave (or an interstitial can tear this route down) before it
      // returns. setState on a disposed State dereferences a null
      // _element and throws, which is fatal on the platform dispatcher.
      if (!mounted) return;
      // Detect "real failure" vs "actually empty": if the tournament
      // says it has participants but we got an empty list back, the
      // fetch must have failed silently in the service layer.
      final isLegitimatelyEmpty =
          result.entries.isEmpty && _tournament!.currentParticipants == 0;
      setState(() {
        _leaderboard = result.entries;
        _serverUserRank = result.userRank;
        _isLoading = false;
        _leaderboardLoadFailed = result.entries.isEmpty && !isLegitimatelyEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _leaderboardLoadFailed = true;
      });
    }
  }

  Future<void> _refreshTournament() async {
    final tournamentId = _tournament?.id ?? widget.tournamentId;
    final updatedTournament = await _tournamentService.getTournament(
      tournamentId,
    );
    if (updatedTournament != null && mounted) {
      setState(() {
        _tournament = updatedTournament;
      });
      _loadLeaderboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Show loading state when fetching tournament from deep link
    if (_isLoadingTournament) {
      return LBScaffold(
        title: l10n.tnTitle,
        body: LBLoadingState(label: l10n.tnLoadingTournament),
      );
    }

    // Show error state
    if (_loadError != null || _tournament == null) {
      return LBScaffold(
        title: l10n.tnTitle,
        onBack: () => Navigator.of(context).pop(),
        body: LBEmptyState(
          icon: LBIcon.x,
          title: _loadError == 'load_failed' ? l10n.tnLoadFailed : l10n.tnNotFound,
          actionLabel: l10n.tnGoBack,
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final tournament = _tournament!;
    final p = context.lb;
    final g = context.lbGutter;
    return LBScaffold(
      title: tournament.type.localizedName(l10n),
      subtitle: tournament.localizedName(l10n, Localizations.localeOf(context)),
      onBack: () => Navigator.of(context).pop(),
      trailing: LBBlock(
        height: context.lbCell * 2 - LB.inset * 2,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        semanticLabel: l10n.lbRefresh,
        onTap: _refreshTournament,
        child: Text(l10n.lbRefresh, style: LBText.label(p, color: p.head)),
      ),
      // The info block scrolls away with the tab content and the tabs pin
      // under the header, so short phones keep a usable tab body and tall
      // ones simply show more of it.
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, 0),
              child: _buildTournamentInfo(),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedTabs(
              extent: context.lbCell * 2.5 + LB.inset * 2 + 10,
              color: p.board,
              child: Padding(
                padding: EdgeInsets.fromLTRB(g, 6, g, 4),
                child: LBTabBlocks(
                  controller: _tabController,
                  labels: [l10n.tnOverview, l10n.tnLeaderboard, l10n.tnRules],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildLeaderboardTab(),
            _buildRulesTab(),
          ],
        ),
      ),
      bottom: tournament.status.canJoin || tournament.status.canSubmitScore
          ? _buildActionButtons()
          : null,
    );
  }

  Widget _buildTournamentInfo() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final tournament = _tournament!;
    // Prefer the server-authoritative rank when we have it; fall back to
    // the local heuristic only as a degraded mode (e.g. leaderboard wasn't
    // loaded yet).
    final showRank = (_serverUserRank ?? 0) > 0 || tournament.userRank > 0;
    return LBBlock(
      selected: tournament.status == TournamentStatus.active,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TournamentStatusChip(status: tournament.status),
              LBChip(label: tournament.gameMode.localizedName(l10n).toUpperCase()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TournamentCountdown(tournament: tournament, cell: 4.4),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LBPixelIcon(LBIcon.friends, cell: 2.6, color: p.inkMuted),
                  const SizedBox(width: 6),
                  Text(
                    l10n.tnPlayersCount(
                      tournament.currentParticipants,
                      tournament.maxParticipants,
                    ),
                    style: LBText.body(p, color: p.inkMuted, size: 11.5),
                  ),
                ],
              ),
            ],
          ),
          if (tournament.hasJoined) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                LBPixelIcon(LBIcon.check, cell: 3, color: p.lime),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tnParticipating.toUpperCase(),
                        style: LBText.button(p, color: p.lime, size: 11.5),
                      ),
                      if (tournament.userBestScore != null &&
                          tournament.userAttempts != null)
                        Text(
                          l10n.tnBestAttempts(
                            tournament.userAttempts!,
                            tournament.userBestScore!,
                          ),
                          style: LBText.body(p, size: 11),
                        ),
                    ],
                  ),
                ),
                if (showRank)
                  LBChip(
                    label: l10n.tnRankChip(_serverUserRank ?? tournament.userRank),
                    kind: LBChipKind.gold,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  EdgeInsets _tabPadding() {
    final g = context.lbGutter;
    return EdgeInsets.fromLTRB(g, 4, g, context.lbCell);
  }

  Widget _buildOverviewTab() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final tournament = _tournament!;
    return ListView(
      padding: _tabPadding(),
      children: [
        TournamentSection(
          title: l10n.tnDescription,
          icon: LBIcon.eye,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tournament.localizedDescription(l10n),
                style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  LBPixelIcon(LBIcon.calendar, cell: 2.6, color: p.inkMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.formatDateRange(
                        tournament.startDate,
                        tournament.endDate,
                      ),
                      style: LBText.body(p, size: 11.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (tournament.rewards.isNotEmpty)
          TournamentSection(
            title: l10n.tnRewards,
            icon: LBIcon.trophy,
            gold: true,
            child: Column(
              children: [
                for (final entry in tournament.rewards.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 46,
                          child: LBCellText(
                            l10n.frRankBadge(entry.key),
                            cell: 2.8 * context.uiScale,
                            color: tournamentRankColor(context, entry.key),
                            semanticsLabel: l10n.tnRewardRank(entry.key),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizedTournamentRewardName(entry.value.name, l10n)
                                    .toUpperCase(),
                                style: LBText.button(p, color: p.ink, size: 11.5),
                              ),
                              if (entry.value.coins > 0)
                                Text(
                                  l10n.mpCoinReward(entry.value.coins),
                                  style: LBText.body(p, color: LB.gold, size: 11),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        TournamentSection(
          title: tournament.gameMode.localizedName(l10n),
          icon: LBIcon.play,
          child: Text(
            tournament.gameMode.localizedDescription(l10n),
            style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return LBLoadingState(label: l10n.frLoadingLeaderboard);
    }

    // Explicit load-failure state. Distinguishes "fetch crashed" from
    // "genuinely empty tournament" so the user sees a retry button
    // instead of a misleading "no participants" screen.
    if (_leaderboardLoadFailed) {
      return LBEmptyState(
        icon: LBIcon.x,
        title: l10n.tnLeaderboardFailed,
        line: l10n.tnCheckConnection,
        actionLabel: l10n.commonRetry,
        onAction: _loadLeaderboard,
      );
    }

    if (_leaderboard.isEmpty) {
      return LBEmptyState(
        icon: LBIcon.chart,
        title: l10n.tnNoParticipants,
        line: l10n.tnBeFirst,
      );
    }

    // participant.userId is the BACKEND account id, which is what
    // AuthState.userId holds. The Firebase UID this used to compare against
    // never matched, so the player's own row was never highlighted.
    final currentUserId = context.read<AuthCubit>().state.userId;
    final entries = [
      for (var i = 0; i < _leaderboard.length; i++)
        RanksEntry(
          rank: i + 1,
          name: _leaderboard[i].displayName,
          score: _leaderboard[i].highScore,
          line: l10n.tnAttemptsCount(_leaderboard[i].attempts),
          isYou: currentUserId != null &&
              _leaderboard[i].userId == currentUserId,
        ),
    ];
    final podium = entries.length < 3 ? entries.length : 3;
    return ListView(
      padding: _tabPadding(),
      children: [
        RanksPodium(top: entries.sublist(0, podium)),
        for (final e in entries.skip(podium)) RanksRow(entry: e),
      ],
    );
  }

  Widget _buildRulesTab() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return ListView(
      padding: _tabPadding(),
      children: [
        TournamentSection(
          title: l10n.tnRulesHeader,
          icon: LBIcon.check,
          child: Column(
            children: [
              for (final rule in _getTournamentRules(l10n))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Directional: in Arabic the Row reverses, so the gap
                      // between the bullet and its rule text has to follow.
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5, end: 10),
                        child: LBCellsBar(count: 1, value: 1, cell: 7, color: p.lime),
                      ),
                      Expanded(
                        child: Text(
                          rule,
                          style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        TournamentSection(
          title: l10n.tnScoringSystem,
          icon: LBIcon.target,
          gold: true,
          child: Text(
            l10n.tnScoringBody,
            style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final tournament = _tournament!;
    final g = context.lbGutter;
    final fg = LBBlock.foregroundOf(LBBlockKind.fill, p);

    Widget cta({required LBIcon icon, required String label, VoidCallback? onTap}) => LBBlock(
          kind: LBBlockKind.fill,
          height: context.lbCell * 3,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          semanticLabel: label,
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LBPixelIcon(icon, cell: 3.4, color: fg),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: fg, size: 14).copyWith(letterSpacing: 2),
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(g, 6, g, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!tournament.hasJoined && tournament.status.canJoin)
            Opacity(
              opacity: _isJoining ? .6 : 1,
              child: cta(
                icon: LBIcon.plus,
                label: _isJoining ? l10n.tnJoining : l10n.tnJoin,
                onTap: _isJoining ? null : () => _joinTournament(),
              ),
            )
          else if (tournament.status.canSubmitScore)
            cta(icon: LBIcon.play, label: l10n.tnPlayNow, onTap: _playTournament),

          if (tournament.requiresEntry) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final premiumCubit = context.read<PremiumCubit>();
                if (premiumCubit.state.hasPremium) {
                  return Center(
                    child: LBChip(
                      label: l10n.tnProUnlimited,
                      kind: LBChipKind.gold,
                      icon: LBIcon.crown,
                    ),
                  );
                }
                final tier = _getTournamentTier(tournament.type);
                final count = premiumCubit.state.getTournamentEntryCount(tier);
                return Center(
                  child: count > 0
                      ? LBChip(
                          label: l10n.tnEntriesRemaining(count),
                          kind: LBChipKind.gold,
                          icon: LBIcon.trophy,
                        )
                      : LBChip(
                          label: l10n.tnNoEntries,
                          kind: LBChipKind.danger,
                          icon: LBIcon.x,
                        ),
                );
              },
            ),
          ],

          if (tournament.status == TournamentStatus.upcoming) ...[
            const SizedBox(height: 8),
            Center(
              child: LBChip(
                label: l10n.tnStarts(tournament.timeRemainingFormatted),
                icon: LBIcon.hourglass,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getTournamentRules(AppLocalizations l10n) {
    final tournament = _tournament!;
    final baseRules = [l10n.tnRule1, l10n.tnRule2, l10n.tnRule3, l10n.tnRule4];

    // Add game mode specific rules
    switch (tournament.gameMode) {
      case TournamentGameMode.speedRun:
        baseRules.add(l10n.tnRuleSpeed);
        break;
      case TournamentGameMode.survival:
        baseRules.add(l10n.tnRuleSurvival);
        break;
      case TournamentGameMode.noWalls:
        baseRules.add(l10n.tnRuleNoWalls);
        break;
      case TournamentGameMode.powerUpMadness:
        baseRules.add(l10n.tnRulePowerUps);
        break;
      case TournamentGameMode.perfectGame:
        baseRules.add(l10n.tnRulePerfect);
        break;
      case TournamentGameMode.classic:
        baseRules.add(l10n.tnRuleClassic);
        break;
    }

    return baseRules;
  }
  String _getTournamentTier(TournamentType type) {
    switch (type) {
      case TournamentType.daily:
        return 'bronze';
      case TournamentType.weekly:
        return 'silver';
      case TournamentType.special:
        return 'gold';
    }
  }

  Future<void> _joinTournament() async {
    // Captured before any await — the snackbar messages below fire after
    // async gaps where a fresh context lookup would be unsafe.
    final l10n = AppLocalizations.of(context)!;
    final tournament = _tournament!;
    final tier = _getTournamentTier(tournament.type);
    final entryCost = tournament.entryCost.clamp(1, 99);

    // Check entry requirement
    if (tournament.requiresEntry) {
      final premiumCubit = context.read<PremiumCubit>();

      // Premium users bypass entry requirement
      if (!premiumCubit.state.hasPremium) {
        final availableEntries = premiumCubit.state.getTournamentEntryCount(
          tier,
        );
        if (availableEntries < entryCost) {
          _showNoEntryDialog(tier);
          return;
        }
      }
    }

    setState(() => _isJoining = true);

    try {
      final success = await _tournamentService.joinTournament(
        tournament.id,
        entryTier: tier,
      );

      if (success && mounted) {
        // Optimistically mark the local tournament as joined so the
        // CTA button flips from JOIN → PLAY NOW immediately, before
        // the network refresh below completes. The backend's
        // TournamentDto.IsJoined will confirm it on the next fetch.
        setState(() {
          _tournament = _tournament!.copyWith(isJoinedServer: true);
        });

        // Consume entries AFTER backend confirms the join succeeded
        if (tournament.requiresEntry) {
          final premiumCubit = context.read<PremiumCubit>();
          if (!premiumCubit.state.hasPremium) {
            await premiumCubit.useTournamentEntry(tier, count: entryCost);
          }
        }

        getIt<AnalyticsFacade>().trackTournamentEntered(
          tournamentId: tournament.id,
          tier: tier,
        );

        // TournamentService.onTournamentJoined broadcast (subscribed by
        // TournamentsNotifier in its constructor) handles the list
        // refresh — no more brittle ProviderScope.containerOf dance.

        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(arcadeSnackBar(context, message: l10n.tnJoinSuccess));
        await _refreshTournament();
      } else if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(arcadeSnackBar(context, message: l10n.tnJoinFailed));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(arcadeSnackBar(context, message: l10n.tnJoinError));
      }
    }

    if (mounted) {
      setState(() => _isJoining = false);
    }
  }

  /// Localized display name for a tournament entry tier id.
  /// The tier ids themselves ('bronze'/'silver'/'gold') stay
  /// untranslated — they're control-flow/product keys, not UI text.
  String _tierDisplayName(AppLocalizations l10n, String tier) {
    switch (tier) {
      case 'silver':
        return l10n.tnTierSilver;
      case 'gold':
        return l10n.tnTierGold;
      default:
        return l10n.tnTierBronze;
    }
  }

  void _showNoEntryDialog(String tier) {
    final l10n = AppLocalizations.of(context)!;
    final premiumCubit = context.read<PremiumCubit>();
    final entryCount = premiumCubit.state.getTournamentEntryCount(tier);

    // Bronze (daily) entries are no longer sold — they're earned via the
    // rewarded-ad path below or granted to Pro subscribers. Only Silver and
    // Gold have a paid IAP, so productId stays null for bronze.
    String? productId;
    switch (tier) {
      case 'bronze':
        productId = null;
        break;
      case 'silver':
        productId = ProductIds.tournamentSilver;
        break;
      case 'gold':
        productId = ProductIds.tournamentGold;
        break;
      default:
        return;
    }

    final tierName = _tierDisplayName(l10n, tier);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .65),
      builder: (BuildContext context) {
        final p = context.lb;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: LBBlock(
              kind: LBBlockKind.sheet,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const LBPixelIcon(LBIcon.trophy, cell: 3.4, color: LB.gold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.tnEntryRequired.toUpperCase(),
                            style: LBText.button(p, color: LB.gold, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.tnEntryNeeded(tierName),
                      style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.tnCurrentEntries(entryCount, tierName),
                      style: LBText.button(
                        p,
                        color: entryCount > 0 ? p.lime : LB.bonk,
                        size: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.tnProUnlimitedNote,
                      style: LBText.body(p, color: p.inkDim, size: 11),
                    ),
                    const SizedBox(height: 18),
                    // Free Bronze entry via rewarded ad (free users only,
                    // bronze tier only — never devalue the paid Silver/Gold
                    // entries). Opt-in and uncapped — gated only on a loaded
                    // rewarded ad.
                    if (tier == 'bronze' &&
                        getIt.isRegistered<AdService>() &&
                        getIt<AdService>().adsEnabled &&
                        getIt<AdService>().isRewardedReady)
                      LBBlock(
                        kind: LBBlockKind.fill,
                        height: 50,
                        feedback: false,
                        alignment: Alignment.center,
                        semanticLabel: l10n.tnFreeEntryAd,
                        onTap: () {
                          // Capture before the pop + ad — onReward fires after the
                          // ad is dismissed, when this dialog's context is gone.
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.of(context).pop();
                          getIt<AdService>().showRewardedFor(
                            placement: AdService.placementTournamentEntry,
                            onReward: () {
                              premiumCubit.addTournamentEntry('bronze');
                              showRewardToast(
                                messenger,
                                l10n.tnFreeBronzeAdded,
                                icon: Icons.emoji_events,
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LBPixelIcon(
                              LBIcon.tv,
                              cell: 3.2,
                              color: LBBlock.foregroundOf(LBBlockKind.fill, p),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                l10n.tnFreeEntryAd.toUpperCase(),
                                style: LBText.button(
                                  p,
                                  color: LBBlock.foregroundOf(LBBlockKind.fill, p),
                                  size: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Paid entry IAP — Silver and Gold only (bronze has no productId).
                    if (productId != null)
                      LBBlock(
                        kind: LBBlockKind.gold,
                        height: 50,
                        feedback: false,
                        alignment: Alignment.center,
                        onTap: () {
                          Navigator.of(context).pop();
                          final purchaseService = PurchaseService();
                          final product = purchaseService.getProduct(productId!);
                          if (product != null) {
                            purchaseService.buyProduct(product);
                          }
                        },
                        child: Text(
                          l10n.tnBuyEntry(
                            PurchaseService().getStorePrice(productId) ??
                                _getDefaultPrice(tier),
                            tierName,
                          ),
                          textAlign: TextAlign.center,
                          style: LBText.button(p, color: LB.gold, size: 12.5),
                        ),
                      ),
                    LBBlock(
                      kind: LBBlockKind.muted,
                      height: 46,
                      alignment: Alignment.center,
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.commonCancel.toUpperCase(),
                        style: LBText.button(p, color: p.inkMuted, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDefaultPrice(String tier) {
    switch (tier) {
      case 'bronze':
        return '\$0.99';
      case 'silver':
        return '\$1.99';
      case 'gold':
        return '\$4.99';
      default:
        return '\$0.99';
    }
  }

  void _playTournament() {
    final tournament = _tournament!;
    final gameCubit = context.read<GameCubit>();

    // Set tournament mode in game cubit
    gameCubit.setTournamentMode(tournament.id, tournament.gameMode);

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const GameScreen()))
        .then((_) {
          // Refresh tournament data when returning from game
          _refreshTournament();
        });
  }
}

/// Keeps the OVERVIEW / LEADERBOARD / RULES blocks pinned while the info
/// block scrolls away.
class _PinnedTabs extends SliverPersistentHeaderDelegate {
  _PinnedTabs({required this.extent, required this.color, required this.child});

  final double extent;
  final Color color;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: color, child: child);

  @override
  bool shouldRebuild(_PinnedTabs old) =>
      old.extent != extent || old.color != color || old.child != child;
}
