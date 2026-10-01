import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/data/daos/leaderboard_dao.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/providers/providers.dart';
import 'package:snake_classic/screens/friends_leaderboard_screen.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/leaderboard_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/lb_list_bits.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/ranks_widgets.dart';

/// Ranks (Living Board screen 12): GLOBAL / WEEKLY / FRIENDS as block tabs,
/// a gold/silver/bronze podium, rows, and the player's own row pinned at
/// the bottom. Offline-first: everything paints from the Drift cache via
/// [combinedLeaderboardProvider]; the player's server rank comes from the
/// cached board metadata ([LeaderboardService.getCacheInfo]).
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Server-reported rank for the signed-in player, per board, from the
  /// Drift `leaderboard_meta` row. Null when the server didn't send one.
  int? _globalServerRank;
  int? _weeklyServerRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Calculate user rank once data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateUserRank();
      _loadRankInfo();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    // Only the two boards this screen always had are tracked; the FRIENDS
    // tab is the friends leaderboard embedded here.
    if (_tabController.index > 1) return;
    final type = _tabController.index == 0 ? 'global' : 'weekly';
    getIt<AnalyticsFacade>().trackLeaderboardViewed(type);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _calculateUserRank() {
    // Every caller can reach here after this State is gone: the initState
    // post-frame callback fires a frame later, and _loadGlobalLeaderboard
    // resumes after an await that the user can leave the screen during.
    //
    // Crashlytics caught the second one — pull to refresh, then navigate away
    // before it lands. `context` on a disposed State is `_element!`, so the
    // crash surfaced as a bare "Null check operator used on a null value"
    // inside the framework with no hint that a dead widget was the cause.
    if (!mounted) return;
    final authState = context.read<AuthCubit>().state;
    if (!authState.isSignedIn || authState.userId == null) return;
    ref
        .read(combinedLeaderboardProvider.notifier)
        .calculateUserRankFor(authState.userId);
  }

  /// Reads the player's server rank for both boards from the cache meta.
  /// Re-run whenever a board's refresh timestamp moves.
  Future<void> _loadRankInfo() async {
    if (!mounted) return;
    try {
      final service = LeaderboardService();
      final global = await service.getCacheInfo(LeaderboardBoardType.global);
      final weekly = await service.getCacheInfo(LeaderboardBoardType.weekly);
      if (!mounted) return;
      setState(() {
        _globalServerRank = global?['currentUserRank'] as int?;
        _weeklyServerRank = weekly?['currentUserRank'] as int?;
      });
    } catch (_) {
      // Non-fatal: the pinned row falls back to the cached entries.
    }
  }

  Future<void> _loadGlobalLeaderboard() async {
    await ref.read(combinedLeaderboardProvider.notifier).refresh();
    _calculateUserRank();
  }

  Future<void> _loadWeeklyLeaderboard() async {
    await ref.read(combinedLeaderboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leaderboardState = ref.watch(combinedLeaderboardProvider);
    final authState = context.watch<AuthCubit>().state;
    final settings = context.watch<GameSettingsCubit>().state;
    final bool online =
        ref.watch(isOnlineProvider).value ?? ref.read(isOnlineSyncProvider) ?? true;

    // Update user rank when global leaderboard loads
    ref.listen<CombinedLeaderboardState>(combinedLeaderboardProvider, (
      prev,
      next,
    ) {
      if (prev?.isLoadingGlobal == true && next.isLoadingGlobal == false) {
        _calculateUserRank();
      }
      if (prev?.globalLastRefreshedAt != next.globalLastRefreshedAt ||
          prev?.weeklyLastRefreshedAt != next.weeklyLastRefreshedAt) {
        _loadRankInfo();
      }
    });

    final g = context.lbGutter;
    return LBScaffold(
      title: l10n.lbRanksTitle,
      subtitle: l10n.lbRanksSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, 0),
            child: LBTabBlocks(
              controller: _tabController,
              labels: [l10n.lbTabGlobal, l10n.lbTabWeekly, l10n.lbTabFriends],
            ),
          ),
          // Cache freshness for the active board: the Drift cache survives
          // offline launches, so this says whether the board is stale.
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) =>
                _buildStalenessRow(l10n, leaderboardState, online),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBoard(l10n, leaderboardState, online, weekly: false),
                _buildBoard(l10n, leaderboardState, online, weekly: true),
                const FriendsLeaderboardView(),
              ],
            ),
          ),
        ],
      ),
      bottom: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) =>
            _buildPinnedYou(l10n, leaderboardState, authState, settings),
      ),
    );
  }

  Widget _buildStalenessRow(
    AppLocalizations l10n,
    CombinedLeaderboardState state,
    bool online,
  ) {
    final index = _tabController.index;
    if (index > 1) return const SizedBox(height: 6);
    final isWeekly = index == 1;
    final ts = isWeekly
        ? state.weeklyLastRefreshedAt
        : state.globalLastRefreshedAt;
    final hasData = isWeekly
        ? state.weeklyEntries.isNotEmpty
        : state.globalEntries.isNotEmpty;
    // No line until the cache has at least once been populated. A
    // brand-new install hitting an offline state would just look
    // confusing with a "Never updated" label.
    if (ts == null && !hasData) return const SizedBox(height: 6);

    final label = ts == null
        ? l10n.frNoCacheYet
        : l10n.frUpdatedAgo(lbRelativeAge(l10n, ts));
    final g = context.lbGutter;
    return Padding(
      padding: EdgeInsets.fromLTRB(g + 2, 2, g + 2, 2),
      child: LBStaleRow(
        label: label,
        note: online ? null : l10n.lbRanksOffline,
        onTap: () => ref.read(combinedLeaderboardProvider.notifier).refresh(),
      ),
    );
  }

  List<RanksEntry> _entries(
    AppLocalizations l10n,
    List<Map<String, dynamic>> players,
  ) {
    final authState = context.read<AuthCubit>().state;
    return [
      for (var i = 0; i < players.length; i++)
        RanksEntry(
          rank: i + 1,
          // Prefer the stable username (backfilled for every user) over the
          // display name, which can be missing for anonymous users and
          // changes with the Google profile.
          name: (players[i]['username'] ??
                  players[i]['displayName'] ??
                  l10n.lbAnonymous)
              .toString(),
          score: (players[i]['highScore'] ?? 0) as int,
          line: l10n.lbRunsCount((players[i]['totalGamesPlayed'] ?? 0) as int),
          isYou: authState.isSignedIn &&
              authState.userId != null &&
              players[i]['uid'] == authState.userId,
        ),
    ];
  }

  Widget _buildBoard(
    AppLocalizations l10n,
    CombinedLeaderboardState state,
    bool online, {
    required bool weekly,
  }) {
    final isLoading = weekly ? state.isLoadingWeekly : state.isLoadingGlobal;
    final error = weekly ? state.weeklyError : state.globalError;
    final players = weekly ? state.weeklyEntries : state.globalEntries;
    final reload = weekly ? _loadWeeklyLeaderboard : _loadGlobalLeaderboard;

    if (isLoading) {
      return LBLoadingState(
        label: weekly ? l10n.lbLoadingWeekly : l10n.lbLoadingGlobal,
      );
    }

    if (error != null) {
      return LBEmptyState(
        icon: LBIcon.x,
        title: l10n.tnLeaderboardFailed,
        line: online ? l10n.lbServerDown : l10n.lbRanksOffline,
        actionLabel: l10n.commonRetry,
        onAction: reload,
      );
    }

    if (players.isEmpty) {
      return weekly
          ? LBEmptyState(
              icon: LBIcon.calendar,
              title: l10n.lbNoWeekly,
              line: l10n.lbPlayThisWeek,
            )
          : LBEmptyState(
              icon: LBIcon.trophy,
              title: l10n.lbNoScores,
              line: l10n.lbRanksEmpty,
            );
    }

    final entries = _entries(l10n, players);
    final podium = entries.length < 3 ? entries.length : 3;
    final p = context.lb;
    final g = context.lbGutter;
    return LBRefresh(
      onRefresh: reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(g, 4, g, context.lbCell * .5),
        children: [
          if (weekly)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
              child: Text(
                l10n.lbWeeklySub,
                style: LBText.body(p, color: p.inkDim, size: 11),
              ),
            ),
          RanksPodium(top: entries.sublist(0, podium)),
          for (final e in entries.skip(podium)) RanksRow(entry: e),
        ],
      ),
    );
  }

  /// The pinned "#rank · YOU · name" row. Rank comes from the server's
  /// current_user_rank when it sent one, else from the cached entries. The
  /// gap to #1 is shown only when the player's own score for this board is
  /// actually known: the local best for GLOBAL, the cached entry for WEEKLY.
  Widget _buildPinnedYou(
    AppLocalizations l10n,
    CombinedLeaderboardState state,
    AuthState authState,
    GameSettingsState settings,
  ) {
    final index = _tabController.index;
    if (index > 1 || !authState.isSignedIn) return const SizedBox.shrink();

    final isWeekly = index == 1;
    final players = isWeekly ? state.weeklyEntries : state.globalEntries;
    final uid = authState.userId;
    final myIndex = uid == null
        ? -1
        : players.indexWhere((e) => e['uid'] == uid);

    final int? rank = (isWeekly ? _weeklyServerRank : _globalServerRank) ??
        (isWeekly ? null : state.userRank?['rank'] as int?) ??
        (myIndex >= 0 ? myIndex + 1 : null);

    final int? entryScore =
        myIndex >= 0 ? (players[myIndex]['highScore'] ?? 0) as int : null;
    final int? myScore = isWeekly
        ? entryScore
        : (settings.highScore > 0 ? settings.highScore : entryScore);

    final name = authState.publicLabel;
    String? line;
    if (rank == null) {
      // The high score only counts Normal and Hard runs; a player who has
      // played but has no ranked best has only played Easy.
      final easyOnly = settings.highScore == 0 &&
          StatisticsService().statistics.totalGamesPlayed > 0;
      if (easyOnly) line = l10n.lbRanksEasyOnly;
    } else if (rank == 1) {
      line = l10n.lbRanksLeader;
    } else if (myScore != null && players.isNotEmpty) {
      final leader = players.first;
      final gap = ((leader['highScore'] ?? 0) as int) - myScore;
      if (gap > 0) {
        final leaderName = (leader['username'] ??
                leader['displayName'] ??
                l10n.lbAnonymous)
            .toString();
        line = l10n.lbRanksGap(context.formatInt(gap), leaderName);
      }
    }

    final g = context.lbGutter;
    return Padding(
      padding: EdgeInsets.fromLTRB(g, 4, g, 8),
      child: RanksYouRow(
        title: rank != null
            ? l10n.lbRanksYouRow(context.formatInt(rank), name)
            : l10n.lbRanksYouUnranked(name),
        score: myScore,
        line: line,
      ),
    );
  }
}
