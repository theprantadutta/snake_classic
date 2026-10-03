import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/weekly_quest_service.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/daily/lb_daily_parts.dart';

/// Daily (Living Board screen 09): progress with streak and reset, one block
/// per challenge, CLAIM ALL ×2 (the existing `challenge_2x` rewarded double)
/// and the weekly-quests teaser.
class DailyChallengesScreen extends ConsumerStatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  ConsumerState<DailyChallengesScreen> createState() =>
      _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends ConsumerState<DailyChallengesScreen> {
  final AudioService _audioService = AudioService();
  final WeeklyQuestService _weekly = WeeklyQuestService();

  /// Re-renders the "resets in" countdown once a minute.
  Timer? _clock;
  bool _claimingAll = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    // For the weekly teaser's count. No-op when already hydrated.
    WidgetsBinding.instance.addPostFrameCallback((_) => _weekly.initialize());
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _refreshChallenges() async {
    await ref.read(dailyChallengesProvider.notifier).refresh();
  }

  Future<void> _claimReward(DailyChallenge challenge) async {
    final success = await ref
        .read(dailyChallengesProvider.notifier)
        .claimReward(challenge.id);
    if (success) {
      getIt<AnalyticsFacade>().trackDailyChallengeRewardClaimed();
      // The coins are NOT granted here. DailyChallengeService.claimReward
      // already credited them, from the amount on the persisted row, after
      // the Drift gate settled the claim. This screen used to credit them a
      // second time — one tap, two transactions — which stayed invisible
      // only because the screen was empty whenever the backend was down.
      HapticService().mediumImpact();
      _audioService.playSound('coin_collect');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: AppLocalizations.of(context)!
                .dchClaimedReward(challenge.coinReward, challenge.xpReward),
            tone: ArcadeSnackTone.success,
            icon: Icons.monetization_on,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Whether the rewarded "2×" on a claim-all is offered. Deliberately NOT
  /// gated on isRewardedReady. Rewarded is the highest-eCPM format in the
  /// app and the pool is empty a large share of the time, so requiring a
  /// loaded ad meant the "2×" offer silently vanished exactly when it was
  /// worth the most — and the tap that would have triggered the load never
  /// happened. showRewardedOrWait waits out a short load window and reports
  /// failure to the user instead.
  bool get _canDouble {
    final ads = getIt.isRegistered<AdService>() ? getIt<AdService>() : null;
    return ads != null && ads.adsEnabled;
  }

  /// Claims every completed challenge. With [watchAdToDouble] (the CLAIM
  /// ALL ×2 block) the `challenge_2x` rewarded ad runs straight after the
  /// claim; otherwise the claimed snackbar offers it, as before.
  Future<void> _claimAllRewards({bool watchAdToDouble = false}) async {
    if (_claimingAll) return;
    setState(() => _claimingAll = true);
    try {
      final totalClaimed = await ref
          .read(dailyChallengesProvider.notifier)
          .claimAllRewards();
      if (totalClaimed > 0) {
        // Same as _claimReward: claimAllRewards already credited the total.
        // The 2x rewarded-ad grant further down IS a separate, additional
        // reward and stays.
        HapticService().heavyImpact();
        _audioService.playSound('coin_collect');
        if (mounted) {
          // Offer a rewarded "2×" on the claimed total (see [_canDouble]).
          final ads = getIt.isRegistered<AdService>() ? getIt<AdService>() : null;
          final canDouble = ads != null && ads.adsEnabled;
          final coins = context.read<CoinsCubit>();
          // Capture before the ad — onReward fires after dismissal, an async
          // gap where reading context is unsafe.
          final messenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context)!;
          final snackTheme = context.read<ThemeCubit>().state.currentTheme;

          Future<void> doubleIt() async {
            final outcome = await ads!.showRewardedOrWait(
              placement: 'challenge_2x',
              onReward: () {
                coins.earnCoins(
                  CoinEarningSource.dailyChallenge,
                  customAmount: totalClaimed,
                  itemName: 'Daily Challenges 2x',
                  metadata: const {'doubled': true},
                );
                showRewardToast(
                  messenger,
                  l10n.dchDoubledBonus(totalClaimed),
                  icon: Icons.monetization_on,
                );
              },
            );
            if (outcome == RewardedOutcome.unavailable) {
              messenger.showSnackBar(
                arcadeSnackBarFor(
                  snackTheme,
                  message: l10n.goNoAdAvailable,
                  icon: Icons.hourglass_empty,
                ),
              );
            }
          }

          final runAdNow = watchAdToDouble && canDouble;
          messenger.showSnackBar(
            arcadeSnackBarFor(
              snackTheme,
              message: l10n.dchClaimedCoins(totalClaimed),
              tone: ArcadeSnackTone.success,
              icon: Icons.celebration,
              duration: Duration(seconds: canDouble && !runAdNow ? 6 : 2),
              actionLabel: canDouble && !runAdNow ? l10n.dchWatchTo2x : null,
              onAction: canDouble && !runAdNow ? doubleIt : null,
            ),
          );
          if (runAdNow) await doubleIt();
        }
      }
    } finally {
      if (mounted) setState(() => _claimingAll = false);
    }
  }

  /// Maps the locally-generated "all challenges" bonus row's English title
  /// to its localized string at render time; server-provided titles pass
  /// through untouched (the Drift row stays English).
  String _localizedChallengeTitle(
    DailyChallenge challenge,
    AppLocalizations l10n,
  ) {
    if (challenge.title == 'All Challenges Bonus') return l10n.dchAllBonusTitle;
    return challenge.localizedTitle(l10n);
  }

  /// Same render-time mapping for the bonus row's description.
  String _localizedChallengeDescription(
    DailyChallenge challenge,
    AppLocalizations l10n,
  ) {
    if (challenge.description == 'Completed every daily challenge today.') {
      return l10n.dchAllBonusDesc;
    }
    return challenge.localizedDescription(l10n);
  }

  /// The daily-bonus login streak, only while it is alive (claimed today or
  /// yesterday). It comes straight from the Drift-backed CoinsCubit state;
  /// 0 means "no streak to show" and the line omits it.
  static int _liveStreak(CoinsState s) {
    final ms = s.dailyBonusLastClaimUtcMs;
    if (ms == null || s.dailyBonusCurrentStreak <= 0) return 0;
    if (s.wasDailyBonusClaimedToday) return s.dailyBonusCurrentStreak;
    final last = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)
        .add(Duration(minutes: s.dailyBonusLastClaimTzOffsetMinutes ?? 0));
    final now = DateTime.now();
    final lastDay = DateTime.utc(last.year, last.month, last.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    return today.difference(lastDay).inDays == 1 ? s.dailyBonusCurrentStreak : 0;
  }

  /// The mode a "play N games of X" challenge asks for, if it maps to one.
  static GameMode? _modeFor(DailyChallenge c) {
    final raw = c.requiredGameMode;
    if (c.type != ChallengeType.gameMode || raw == null) return null;
    final key = raw.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final m in GameMode.values) {
      if (m.wireName.toLowerCase() == key ||
          m.name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '') == key) {
        return m;
      }
    }
    return null;
  }

  static LBIcon _challengeIcon(ChallengeType type) => switch (type) {
        ChallengeType.score => LBIcon.star,
        ChallengeType.foodEaten => LBIcon.apple,
        ChallengeType.gameMode => LBIcon.grid,
        ChallengeType.survival => LBIcon.hourglass,
        ChallengeType.gamesPlayed => LBIcon.play,
      };

  @override
  Widget build(BuildContext context) {
    final challengesState = ref.watch(dailyChallengesProvider);
    // Rebuild on theme changes (the palette re-skins through context.lb).
    context.watch<ThemeCubit>();
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;

    final isRefreshing = challengesState.isLoading;
    final challenges = challengesState.challenges;
    final claimable = challenges.where((c) => c.canClaim).toList();
    final claimableCoins = claimable.fold<int>(0, (s, c) => s + c.coinReward);
    final allClaimed = challenges.isNotEmpty &&
        challenges.every((c) => c.claimedReward) &&
        (!challengesState.allCompleted || challengesState.isBonusClaimed);

    final streak = _liveStreak(context.watch<CoinsCubit>().state);
    final resets = lbResetCountdown(l10n, lbUntilLocalMidnight());

    return LBScaffold(
      title: l10n.lbDailyTitle,
      subtitle: l10n.lbDailySubtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (challengesState.hasUnclaimedRewards)
            LBBlock(
              kind: LBBlockKind.gold,
              height: context.lbCell * 2 - LB.inset * 2,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              onTap: _claimingAll ? null : _claimAllRewards,
              child: Text(
                l10n.lbClaimAll,
                style: LBText.button(p, color: LB.gold, size: 11.5).copyWith(letterSpacing: 1.8),
              ),
            ),
          LBRefreshBlock(busy: isRefreshing, onTap: _refreshChallenges),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshChallenges,
        color: p.lime,
        backgroundColor: p.deep,
        child: _body(
          context,
          l10n,
          challengesState: challengesState,
          streak: streak,
          resets: resets,
          claimable: claimable,
          claimableCoins: claimableCoins,
          allClaimed: allClaimed,
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n, {
    required DailyChallengesState challengesState,
    required int streak,
    required String resets,
    required List<DailyChallenge> claimable,
    required int claimableCoins,
    required bool allClaimed,
  }) {
    final p = context.lb;
    final g = context.lbGutter;
    final challenges = challengesState.challenges;
    final isRefreshing = challengesState.isLoading;
    final empty = challenges.isEmpty && !isRefreshing;
    final subline = streak > 0 ? l10n.lbDailyStreak(streak, resets) : l10n.lbResetsIn(resets);

    final top = <Widget>[
      // No "0 OF 0 DONE" before today's board exists; the streak and the
      // reset clock move into the empty state instead.
      if (!empty)
        LBDailyProgressBlock(
          done: challengesState.completedCount,
          total: challengesState.totalCount,
          subline: subline,
        ),
      if (isRefreshing && challenges.isEmpty)
        // Skeleton rows rather than a spinner: the list that arrives is
        // this tall, so nothing below it moves when it does.
        ...List.generate(3, (_) => const LBQuestSkeleton())
      else
        for (final c in challenges) _challengeBlock(context, l10n, c),
      if (challengesState.allCompleted) _bonusBlock(context, l10n, challengesState),
      if (allClaimed) LBEmptyBlock(icon: LBIcon.check, title: l10n.lbDailyAllFed),
      if (claimable.isNotEmpty && _canDouble)
        LBRow(
          kind: LBBlockKind.gold,
          height: context.lbCell * 3.5,
          leading: const LBPixelIcon(LBIcon.tv, cell: 4, color: LB.gold),
          title: l10n.lbClaimAllDouble,
          subtitle: l10n.lbClaimAllDoubleLine,
          titleColor: LB.gold,
          onTap: _claimingAll ? null : () => _claimAllRewards(watchAdToDouble: true),
          trailing: Text(
            l10n.lbCoinsReward(context.formatInt(claimableCoins * 2)),
            style: LBText.value(p, color: LB.gold, size: 17),
          ),
        ),
    ];

    final bottom = <Widget>[
      ListenableBuilder(
        listenable: _weekly,
        builder: (context, _) {
          final quests = _weekly.quests;
          return LBRow(
            height: context.lbCell * 3.5,
            leading: LBPixelIcon(LBIcon.calendar, cell: 4, color: p.lime),
            title: quests.isEmpty
                ? l10n.wqTitle
                : l10n.lbWeeklyTeaser(
                    context.formatInt(_weekly.completedCount),
                    context.formatInt(quests.length),
                  ),
            titleColor: p.head,
            subtitle: l10n.lbWeeklyTeaserLine,
            trailing: Text('→', style: LBText.button(p, color: p.lime, size: 14)),
            onTap: () => context.push(AppRoutes.weeklyQuests),
          );
        },
      ),
      SizedBox(height: context.lbCell),
      LBSectionLabel(l10n.dchAbout),
      for (final line in [l10n.dchAbout1, l10n.dchAbout2, l10n.dchAbout3, l10n.dchAbout4])
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: LBCellsBar(count: 1, value: 1, cell: 6, color: p.inkDim),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(line, style: LBText.body(p, size: 11))),
            ],
          ),
        ),
    ];

    final padding = EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell * 1.5);
    if (!empty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [...top, ...bottom],
      );
    }

    // Empty: the empty state takes whatever height the list would have, so
    // the weekly row and the notes sit at the bottom instead of floating
    // over a dead band.
    final failed = challengesState.error != null;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...top,
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: context.lbCell * 8),
                    child: LBEmptyBlock(
                      expanded: true,
                      icon: LBIcon.calendar,
                      title: l10n.dcNoChallenges,
                      line: '${failed ? l10n.lbServerDown : l10n.dchCheckBack}\n$subline',
                      action: failed
                          ? LBBlock(
                              kind: LBBlockKind.outline,
                              height: context.lbCell * 2.2,
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              alignment: Alignment.center,
                              onTap: isRefreshing ? null : _refreshChallenges,
                              child: Text(
                                l10n.mpLobbyTryAgain,
                                style: LBText.button(p, color: p.lime, size: 12.5)
                                    .copyWith(letterSpacing: 1.8),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                ...bottom,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _challengeBlock(BuildContext context, AppLocalizations l10n, DailyChallenge c) {
    final mode = _modeFor(c);
    final LBQuestAction? action;
    if (c.canClaim) {
      action = LBQuestClaim(() => _claimReward(c));
    } else if (c.claimedReward) {
      action = const LBQuestClaimed();
    } else if (mode != null && !c.isCompleted) {
      action = LBQuestPlay(
        l10n.lbPlayMode(mode.localizedName(l10n).toUpperCase()),
        () {
          context.read<GameSettingsCubit>().setGameMode(mode);
          context.push(AppRoutes.runSetup);
        },
      );
    } else {
      action = null;
    }
    return LBQuestBlock(
      icon: _challengeIcon(c.type),
      title: _localizedChallengeTitle(c, l10n),
      description: _localizedChallengeDescription(c, l10n),
      difficulty: c.difficulty,
      current: c.currentProgress,
      target: c.targetValue,
      progress: c.progressPercentage,
      completed: c.isCompleted,
      rewardLine: l10n.lbRewardCoinsXp(
        context.formatInt(c.coinReward),
        context.formatInt(c.xpReward),
      ),
      action: action,
    );
  }

  Widget _bonusBlock(BuildContext context, AppLocalizations l10n, DailyChallengesState s) {
    final p = context.lb;
    final claimed = s.isBonusClaimed;
    return LBRow(
      kind: claimed ? LBBlockKind.muted : LBBlockKind.gold,
      leading: LBPixelIcon(
        claimed ? LBIcon.check : LBIcon.gift,
        cell: 4,
        color: claimed ? p.inkDim : LB.gold,
      ),
      title: l10n.dchAllCompleteTitle,
      titleColor: claimed ? p.inkMuted : LB.gold,
      subtitle: claimed ? l10n.dchBonusClaimed : l10n.dchBonusPending,
      trailing: Text(
        l10n.lbCoinsReward(context.formatInt(s.bonusCoins)),
        style: LBText.value(p, color: claimed ? p.inkDim : LB.gold, size: 17),
      ),
    );
  }
}
