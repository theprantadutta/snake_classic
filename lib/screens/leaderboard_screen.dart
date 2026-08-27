import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/providers/leaderboard_provider.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/formatting.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Calculate user rank once data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateUserRank();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
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

  Future<void> _loadGlobalLeaderboard() async {
    await ref.read(combinedLeaderboardProvider.notifier).refresh();
    _calculateUserRank();
  }

  Future<void> _loadWeeklyLeaderboard() async {
    await ref.read(combinedLeaderboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the leaderboard state from Riverpod
    final leaderboardState = ref.watch(combinedLeaderboardProvider);
    final themeState = context.watch<ThemeCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final theme = themeState.currentTheme;

    // Update user rank when global leaderboard loads
    ref.listen<CombinedLeaderboardState>(combinedLeaderboardProvider, (
      prev,
      next,
    ) {
      if (prev?.isLoadingGlobal == true && next.isLoadingGlobal == false) {
        _calculateUserRank();
      }
    });

    return Scaffold(
      bottomNavigationBar: const SnakeBannerAd(),
      extendBodyBehindAppBar: true,
      appBar: appScreenBar(
        context,
        theme,
        AppLocalizations.of(context)!.lbTitle,
      ),
      body: AppBackground(
        theme: theme,
        child: SafeArea(
          child: Column(
            children: [
              // Tab Bar
              _buildTabBar(theme),

              // Subtitle explaining what the active tab ranks by — without
              // this, "Global vs Weekly" doesn't tell players whether the
              // metric is score / coins / XP / something else.
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) => _buildSubtitle(theme),
              ),

              // Cache freshness chip — surfaces when the Drift cache for
              // the active board was last refreshed from the server so
              // the user knows if they're looking at stale data (offline,
              // or a recent disconnect).
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) =>
                    _buildStalenessChip(theme, leaderboardState),
              ),

              // User Rank Card
              if (authState.isSignedIn && leaderboardState.userRank != null)
                _buildUserRankCard(
                  authState,
                  theme,
                  leaderboardState.userRank!,
                ),

              // Leaderboard Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGlobalLeaderboard(theme, authState, leaderboardState),
                    _buildWeeklyLeaderboard(theme, authState, leaderboardState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Themed loading state matching the other data screens — a centered
  /// spinner over a 'Loading…' label so users perceive the network fetch
  /// as work-in-progress rather than an empty/broken screen.
  Widget _buildLoadingState(GameTheme theme, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 + context.sideInset()),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.accentColor,
        labelColor: theme.accentColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabs: [
          Tab(text: l10n.lbGlobal),
          Tab(text: l10n.lbWeekly),
        ],
      ),
    );
  }

  /// Tells the player exactly what metric the active tab is ranking on,
  /// so "Global vs Weekly" isn't ambiguous between high score / coins / XP.
  /// Mirrors what the backend handlers do: GetGlobalLeaderboardQueryHandler
  /// orders by aggregated max(Score.ScoreValue) lifetime; the weekly one
  /// scopes scores to `CreatedAt >= startOfWeek` (Sunday).
  Widget _buildSubtitle(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final isWeekly = _tabController.index == 1;
    final icon = isWeekly ? Icons.calendar_today : Icons.public;
    final text = isWeekly ? l10n.lbWeeklySub : l10n.lbGlobalSub;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 + context.sideInset(),
        8,
        16 + context.sideInset(),
        0,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.accentColor.withValues(alpha: 0.75),
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tiny inline chip reading "Updated 3m ago · tap to refresh" for the
  /// active board. The Drift cache survives offline launches, so this
  /// is the user's signal for "is what I'm looking at stale?". Tap
  /// triggers a forced refresh.
  Widget _buildStalenessChip(GameTheme theme, CombinedLeaderboardState state) {
    final isWeekly = _tabController.index == 1;
    final ts = isWeekly
        ? state.weeklyLastRefreshedAt
        : state.globalLastRefreshedAt;
    final hasData = isWeekly
        ? state.weeklyEntries.isNotEmpty
        : state.globalEntries.isNotEmpty;
    // No chip until the cache has at least once been populated. A
    // brand-new install hitting an offline state would just look
    // confusing with a "Never updated" label.
    if (ts == null && !hasData) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final label = ts == null
        ? l10n.frNoCacheYet
        : l10n.frUpdatedAgo(_relativeAge(l10n, ts));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 + context.sideInset(),
        6,
        16 + context.sideInset(),
        0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => ref.read(combinedLeaderboardProvider.notifier).refresh(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            // No box. Padding keeps the tap target without drawing one.
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeAge(AppLocalizations l10n, DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 5) return l10n.frJustNow;
    if (diff.inSeconds < 60) return l10n.frSecondsAgo(diff.inSeconds);
    if (diff.inMinutes < 60) return l10n.frMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.frHoursAgo(diff.inHours);
    return l10n.frDaysAgo(diff.inDays);
  }

  Widget _buildUserRankCard(
    AuthState authState,
    GameTheme theme,
    Map<String, dynamic> userRank,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16 + context.sideInset(),
        vertical: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: authState.photoURL != null
                ? NetworkImage(authState.photoURL!)
                : null,
            onBackgroundImageError: authState.photoURL != null
                ? (e, s) {}
                : null,
            backgroundColor: theme.primaryColor,
            child: authState.photoURL == null
                ? Icon(Icons.person, color: theme.backgroundColor)
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.publicLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  l10n.lbScoreLine(authState.highScore),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, color: theme.accentColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    l10n.frRankBadge(userRank['rank'] as Object),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.tnTopPercent('${userRank['percentile']}'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard(
    GameTheme theme,
    AuthState authState,
    CombinedLeaderboardState leaderboardState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (leaderboardState.isLoadingGlobal) {
      return _buildLoadingState(theme, l10n.lbLoadingGlobal);
    }

    if (leaderboardState.globalError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              leaderboardState.globalError!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadGlobalLeaderboard,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    if (leaderboardState.globalEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbNoScores,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.lbBeFirst,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGlobalLeaderboard,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 16 + context.sideInset(),
          vertical: 16,
        ),
        itemCount: leaderboardState.globalEntries.length,
        itemBuilder: (context, index) {
          final player = leaderboardState.globalEntries[index];
          final isCurrentUser =
              authState.isSignedIn &&
              authState.userId != null &&
              player['uid'] == authState.userId;

          return _buildLeaderboardItem(index + 1, player, theme, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildWeeklyLeaderboard(
    GameTheme theme,
    AuthState authState,
    CombinedLeaderboardState leaderboardState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (leaderboardState.isLoadingWeekly) {
      return _buildLoadingState(theme, l10n.lbLoadingWeekly);
    }

    if (leaderboardState.weeklyError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              leaderboardState.weeklyError!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWeeklyLeaderboard,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    if (leaderboardState.weeklyEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbNoWeekly,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.lbPlayThisWeek,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWeeklyLeaderboard,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 16 + context.sideInset(),
          vertical: 16,
        ),
        itemCount: leaderboardState.weeklyEntries.length,
        itemBuilder: (context, index) {
          final player = leaderboardState.weeklyEntries[index];
          final isCurrentUser =
              authState.isSignedIn &&
              authState.userId != null &&
              player['uid'] == authState.userId;

          return _buildLeaderboardItem(index + 1, player, theme, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    Map<String, dynamic> player,
    GameTheme theme,
    bool isCurrentUser,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Top-3 podium styling. Each gets its own metallic tint plus a faint
    // background gradient so the eye lands there first. Beyond rank 3 the
    // entries use the neutral theme treatment.
    final podium = _podiumStyle(rank);
    final isPodium = podium != null;

    final score = (player['highScore'] ?? 0) as int;
    final gamesPlayed = (player['totalGamesPlayed'] ?? 0) as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      // One card shape for every row; the border says which row is which.
      //
      // It used to be three gradients and two glows: the signed-in player's
      // row in a three-stop accent gradient with a fourteen-pixel glow, the
      // top three in metallic gradients with glows of their own, everyone
      // else flat. On a board where the first four rows all glow, none of
      // them stands out — and the one the player is actually looking for is
      // their own.
      // The panel material, but no brackets: a leaderboard is a list of rows,
      // not twenty framed panels stacked on each other. The border keeps
      // doing the work of saying which row is which.
      decoration: arcadeSurface(
        theme,
        tint: isCurrentUser
            ? theme.accentColor
            : isPodium
            ? podium.color
            : theme.accentColor,
        borderRadius: BorderRadius.circular(12),
        borderColor: isCurrentUser
            ? theme.accentColor
            : isPodium
            ? podium.color.withValues(alpha: 0.5)
            : theme.accentColor.withValues(alpha: 0.18),
        borderWidth: isCurrentUser ? 1.5 : 1,
        baseAlpha: isCurrentUser ? 0.55 : 0.42,
        // Only the row you are looking for glows. Twenty glowing rows is the
        // same as none glowing.
        glow: isCurrentUser,
      ),
      child: Row(
        children: [
          // Rank chip — medal for top 3, pill with "#N" for the rest.
          _buildRankWidget(rank, podium, theme),

          const SizedBox(width: 10),

          // Avatar with subtle metallic ring for podium positions.
          Container(
            padding: isPodium ? const EdgeInsets.all(2) : EdgeInsets.zero,
            decoration: isPodium
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: podium.color.withValues(alpha: 0.75),
                      width: 2,
                    ),
                  )
                : null,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: player['photoURL'] != null
                  ? NetworkImage(player['photoURL']!)
                  : null,
              onBackgroundImageError: player['photoURL'] != null
                  ? (e, s) {}
                  : null,
              backgroundColor: theme.primaryColor,
              child: player['photoURL'] == null
                  ? Icon(Icons.person, color: theme.backgroundColor, size: 20)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Name and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      // Prefer the stable username (now backfilled for
                      // every user post-Phase-1) over the display name,
                      // which can be null/missing for anonymous users
                      // and changes when the user updates their Google
                      // profile.
                      player['username'] ??
                          player['displayName'] ??
                          l10n.lbAnonymous,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? theme.accentColor : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (player['isAnonymous'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kRewardGold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.lbGuestBadge,
                          style: const TextStyle(
                            color: kRewardGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor,
                              theme.accentColor.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accentColor.withValues(alpha: 0.55),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_pin,
                              color: theme.backgroundColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.frYou,
                              style: TextStyle(
                                color: theme.backgroundColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: context.letterSpacing(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _formatGamesPlayed(l10n, gamesPlayed),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),

          // Score — right-aligned, thousands-separated. Podium uses a
          // gradient text effect via ShaderMask for a "scoreboard" feel.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScoreText(score, podium, isCurrentUser, theme),
              const SizedBox(height: 2),
              Text(
                l10n.lbPts,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: context.letterSpacing(1.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Leaderboard row helpers
  // ---------------------------------------------------------------------------

  /// Returns gold / silver / bronze styling for the top 3, or null for the rest.
  _PodiumStyle? _podiumStyle(int rank) {
    switch (rank) {
      case 1:
        return const _PodiumStyle(color: kRewardGold, icon: Icons.emoji_events);
      case 2:
        return _PodiumStyle(
          color: Colors.grey.shade400, // silver
          icon: Icons.workspace_premium,
        );
      case 3:
        return _PodiumStyle(
          color: const Color(0xFFCD7F32), // bronze
          icon: Icons.workspace_premium,
        );
      default:
        return null;
    }
  }

  /// Rank widget — medal disc for top 3, pill chip with "#N" for the rest.
  Widget _buildRankWidget(int rank, _PodiumStyle? podium, GameTheme theme) {
    if (podium != null) {
      // A medal, drawn flat. Gold, silver and bronze stay — they are what
      // first, second and third mean everywhere — but they no longer come
      // with a gradient and a glow each.
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: podium.color.withValues(alpha: 0.18),
          border: Border.all(color: podium.color.withValues(alpha: 0.7)),
        ),
        child: Icon(podium.icon, color: podium.color, size: 19),
      );
    }
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor.withValues(alpha: 0.18),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: theme.accentColor,
        ),
      ),
    );
  }

  /// Score text with thousands separator. Podium positions get a gradient
  /// ShaderMask in their medal color; the current user gets the accent
  /// color; everyone else is plain white.
  Widget _buildScoreText(
    int score,
    _PodiumStyle? podium,
    bool isCurrentUser,
    GameTheme theme,
  ) {
    final formatted = context.formatInt(score);
    if (podium != null && !isCurrentUser) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [Colors.white, podium.color],
        ).createShader(bounds),
        child: Text(
          formatted,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: context.letterSpacing(-0.5),
          ),
        ),
      );
    }
    return Text(
      formatted,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: isCurrentUser ? theme.accentColor : Colors.white,
        letterSpacing: context.letterSpacing(-0.5),
      ),
    );
  }

  /// "1 game played" / "12 games played" via the localized ICU plural.
  /// The count is intentionally passed raw (no thousands separator): the
  /// ICU plural needs the num to pick the right form per locale.
  String _formatGamesPlayed(AppLocalizations l10n, int count) {
    return l10n.lbGamesPlayed(count);
  }
}

class _PodiumStyle {
  final Color color;
  final IconData icon;
  const _PodiumStyle({required this.color, required this.icon});
}
