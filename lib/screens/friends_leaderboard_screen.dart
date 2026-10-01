import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/lb_list_bits.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/ranks_widgets.dart';

/// The friends board on its own route. The same board is the FRIENDS tab of
/// the Ranks screen ([FriendsLeaderboardView]).
class FriendsLeaderboardScreen extends StatefulWidget {
  const FriendsLeaderboardScreen({super.key});

  @override
  State<FriendsLeaderboardScreen> createState() =>
      _FriendsLeaderboardScreenState();
}

class _FriendsLeaderboardScreenState extends State<FriendsLeaderboardScreen> {
  final GlobalKey<FriendsLeaderboardViewState> _view = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBScaffold(
      title: l10n.lbTabFriends,
      subtitle: l10n.frLeaderboardSubtitle,
      trailing: LBBlock(
        height: context.lbCell * 2 - LB.inset * 2,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        semanticLabel: l10n.lbRefresh,
        onTap: () => _view.currentState?.reload(),
        child: Text(l10n.lbRefresh, style: LBText.label(p, color: p.head)),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: context.lbCell * .7),
        child: FriendsLeaderboardView(key: _view),
      ),
    );
  }
}

/// The friends leaderboard body: podium + rows, offline-first from the
/// preloaded friends list, refreshed from [SocialService].
class FriendsLeaderboardView extends StatefulWidget {
  const FriendsLeaderboardView({super.key});

  @override
  State<FriendsLeaderboardView> createState() => FriendsLeaderboardViewState();
}

class FriendsLeaderboardViewState extends State<FriendsLeaderboardView> {
  final SocialService _socialService = SocialService();
  final AppDataCache _appCache = AppDataCache();
  List<UserProfile> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLeaderboard();
  }

  /// Forces a reload from the service (the header REFRESH action).
  Future<void> reload() => _loadLeaderboard();

  void _initializeLeaderboard() {
    // Check cache first - use preloaded friends list sorted by high score
    if (_appCache.isFullyLoaded &&
        _appCache.friendsList != null &&
        _appCache.friendsList!.isNotEmpty) {
      // Sort friends by high score for leaderboard display
      final sortedFriends = List<UserProfile>.from(_appCache.friendsList!);
      sortedFriends.sort((a, b) => b.highScore.compareTo(a.highScore));

      _leaderboard = sortedFriends;
      _isLoading = false;

      // Refresh in background for latest data
      _refreshInBackground();
    } else {
      // No cache - load normally
      _loadLeaderboard();
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final leaderboard = await _socialService.getFriendsLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
        });
      }
    } catch (_) {
      // Ignore errors in background refresh
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      final leaderboard = await _socialService.getFriendsLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.watch<AuthCubit>().state;
    final currentUid = authState.isSignedIn ? authState.userId : null;

    if (_isLoading) return LBLoadingState(label: l10n.frLoadingLeaderboard);

    if (_leaderboard.isEmpty) {
      return LBEmptyState(
        icon: LBIcon.friends,
        title: l10n.frNoFriendsYet,
        line: l10n.frLeaderboardEmptySub,
        actionLabel: l10n.frAddFriends,
        onAction: () => context.push(AppRoutes.friends),
      );
    }

    RanksEntry entryAt(int i) {
      final user = _leaderboard[i];
      return RanksEntry(
        rank: i + 1,
        name: user.publicLabel,
        score: user.highScore,
        line: l10n.lbRunsCount(user.totalGamesPlayed),
        isYou: currentUid != null && user.uid == currentUid,
      );
    }

    final g = context.lbGutter;
    final podiumCount = _leaderboard.length < 3 ? _leaderboard.length : 3;
    return LBRefresh(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(g, 4, g, context.lbCell),
        itemCount: 1 + (_leaderboard.length - podiumCount),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: RanksPodium(
                top: [for (var i = 0; i < podiumCount; i++) entryAt(i)],
              ),
            );
          }
          return RanksRow(entry: entryAt(index - 1 + podiumCount));
        },
      ),
    );
  }
}
