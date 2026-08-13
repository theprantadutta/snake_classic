import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/app_background.dart';

class DailyChallengesScreen extends ConsumerStatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  ConsumerState<DailyChallengesScreen> createState() =>
      _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends ConsumerState<DailyChallengesScreen> {
  final AudioService _audioService = AudioService();

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
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.dchClaimedReward(challenge.coinReward, challenge.xpReward),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _claimAllRewards() async {
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
        // Offer a rewarded "2×" on the claimed total when an ad is available.
        final ads = getIt.isRegistered<AdService>() ? getIt<AdService>() : null;
        final canDouble = ads != null && ads.adsEnabled && ads.isRewardedReady;
        final coins = context.read<CoinsCubit>();
        // Capture before the ad — onReward fires after dismissal, an async
        // gap where reading context is unsafe.
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.amber),
                const SizedBox(width: 8),
                Text(l10n.dchClaimedCoins(totalClaimed)),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: Duration(seconds: canDouble ? 6 : 2),
            action: canDouble
                ? SnackBarAction(
                    label: l10n.dchWatchTo2x,
                    textColor: Colors.amber,
                    onPressed: () => ads.showRewarded(
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
                    ),
                  )
                : null,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    // Watch the daily challenges state from Riverpod
    final challengesState = ref.watch(dailyChallengesProvider);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;
        return _buildContent(context, theme, challengesState);
      },
    );
  }

  /// The screen, in the language Settings and Profile settled on: an
  /// uppercase accent eyebrow over a hairline-bordered translucent card, one
  /// column, monochrome against the active theme.
  ///
  /// It had drifted a long way from that. The summary was a primary-to-accent
  /// gradient; every challenge card changed its own fill AND its border colour
  /// with state (green when done, amber when claimable, primary otherwise);
  /// difficulty was a red, orange or green pill; the two rewards were an amber
  /// chip and a purple chip; the all-complete banner was an amber-to-orange
  /// gradient with a shimmer running across it. Six palettes and four entrance
  /// animations on one screen, which leaves nothing for the one thing that
  /// actually needs attention — the challenge you can claim right now.
  ///
  /// Now colour means one thing here: gold is a reward, the theme's accent is
  /// progress and action, and everything else is white at some opacity. State
  /// is carried by the status glyph and the claim button, not by repainting
  /// the whole row.
  Widget _buildContent(
    BuildContext context,
    GameTheme theme,
    DailyChallengesState challengesState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isRefreshing = challengesState.isLoading;
    final challenges = challengesState.challenges;
    final hasUnclaimedRewards = challengesState.hasUnclaimedRewards;
    final allCompleted = challengesState.allCompleted;

    return Scaffold(
      bottomNavigationBar: const SnakeBannerAd(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.dcTitle.toUpperCase(),
          style: TextStyle(
            color: theme.accentColor,
            fontWeight: FontWeight.bold,
            letterSpacing: context.letterSpacing(2),
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.accentColor),
        actions: [
          if (hasUnclaimedRewards)
            TextButton(
              onPressed: _claimAllRewards,
              child: Text(
                l10n.dchClaimAll.toUpperCase(),
                style: TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: context.letterSpacing(1),
                ),
              ),
            ),
          IconButton(
            tooltip: l10n.dchLoading,
            icon: isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(theme.accentColor),
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.refresh, color: theme.accentColor),
            onPressed: isRefreshing ? null : _refreshChallenges,
          ),
        ],
      ),
      body: AppBackground(
        theme: theme,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshChallenges,
            color: theme.accentColor,
            backgroundColor: theme.backgroundColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 24 + context.sideInset(),
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    theme,
                    l10n.dchTodaysProgress,
                    _buildProgressSummary(theme, challengesState),
                  ),
                  const SizedBox(height: 32),

                  _sectionHeader(theme, l10n.dchSectionChallenges),
                  if (isRefreshing && challenges.isEmpty)
                    // Skeleton rows rather than a spinner: the list that
                    // arrives is this tall, so nothing below it moves when it
                    // does.
                    ...List.generate(3, (_) => _skeletonCard(theme))
                  else if (challenges.isEmpty)
                    _buildEmptyState(theme)
                  else
                    ...challenges.map((c) => _buildChallengeCard(c, theme)),

                  if (allCompleted) ...[
                    const SizedBox(height: 8),
                    _buildAllCompleteBonusCard(theme, challengesState),
                  ],

                  const SizedBox(height: 32),

                  _section(theme, l10n.dchAbout, _buildInfoList(l10n)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Shared shapes ====================

  /// Gold means a reward, here and on the home screen's best-score medal. It
  /// is the only colour on this screen that is not the theme's own.
  static const Color _gold = Color(0xFFFFC53D);

  Widget _sectionHeader(GameTheme theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.accentColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: context.letterSpacing(1.5),
        ),
      ),
    );
  }

  Widget _card(GameTheme theme, {required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(
          color: borderColor ?? theme.accentColor.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _section(GameTheme theme, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(theme, title),
        _card(theme, child: child),
      ],
    );
  }

  /// A progress bar in the theme's accent. One shape for every bar on the
  /// screen, so a full one and a half-full one are the same object.
  Widget _bar(GameTheme theme, double value, {double height = 6}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        valueColor: AlwaysStoppedAnimation(theme.accentColor),
        minHeight: height,
      ),
    );
  }

  // ==================== Sections ====================

  Widget _buildProgressSummary(
    GameTheme theme,
    DailyChallengesState challengesState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final completed = challengesState.completedCount;
    final total = challengesState.totalCount;
    final progress = total > 0 ? completed / total : 0.0;

    // One statement of progress, not three. It used to say the same thing as
    // a sentence, a ring and a bar, all at once.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                l10n.dchProgressSummary(completed, total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _bar(theme, progress, height: 8),
      ],
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = challenge.isCompleted;
    final canClaim = challenge.canClaim;
    final claimed = challenge.claimedReward;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        theme,
        // The one thing on this screen that wants attention is a reward you
        // can take. That — and only that — gets the gold edge.
        borderColor: canClaim ? _gold.withValues(alpha: 0.65) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status, in one glyph. The card used to repaint its fill and
                // its border to say the same thing.
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    claimed
                        ? Icons.check_circle
                        : isCompleted
                        ? Icons.check_circle_outline
                        : _challengeTypeIcon(challenge.type),
                    color: claimed
                        ? Colors.white.withValues(alpha: 0.45)
                        : isCompleted
                        ? _gold
                        : theme.accentColor.withValues(alpha: 0.85),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _localizedChallengeTitle(challenge, l10n),
                        style: TextStyle(
                          color: claimed
                              ? Colors.white.withValues(alpha: 0.55)
                              : Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _localizedChallengeDescription(challenge, l10n),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Difficulty as a word, not a red/orange/green pill. A hard
                // challenge is a description, not a warning.
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    challenge.difficulty.localizedName(l10n).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: context.letterSpacing(1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _bar(theme, challenge.progressPercentage)),
                const SizedBox(width: 12),
                Text(
                  '${challenge.currentProgress}/${challenge.targetValue}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.monetization_on, color: _gold, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.dchRewardLine(
                      challenge.coinReward,
                      challenge.xpReward,
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canClaim)
                  GradientButton(
                    onPressed: () => _claimReward(challenge),
                    text: l10n.dchClaim,
                    primaryColor: _gold,
                    secondaryColor: theme.accentColor,
                    icon: Icons.redeem,
                    width: 132,
                    height: 40,
                  )
                else if (claimed)
                  Text(
                    l10n.dchClaimed.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: context.letterSpacing(1),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCompleteBonusCard(
    GameTheme theme,
    DailyChallengesState challengesState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final claimed = challengesState.isBonusClaimed;

    return _card(
      theme,
      borderColor: claimed ? null : _gold.withValues(alpha: 0.65),
      child: Row(
        children: [
          Icon(
            claimed ? Icons.check_circle : Icons.celebration,
            color: claimed ? Colors.white.withValues(alpha: 0.45) : _gold,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dchAllCompleteTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  claimed ? l10n.dchBonusClaimed : l10n.dchBonusPending,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '+${challengesState.bonusCoins}',
            style: TextStyle(
              color: claimed ? Colors.white.withValues(alpha: 0.45) : _gold,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  /// A challenge-shaped placeholder. The list used to be replaced by a
  /// centred spinner, so everything below it jumped when the challenges
  /// arrived.
  Widget _skeletonCard(GameTheme theme) {
    Widget bone(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _card(
            theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    bone(22, 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bone(140, 14),
                          const SizedBox(height: 8),
                          bone(200, 11),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                bone(double.infinity, 6),
                const SizedBox(height: 16),
                bone(110, 12),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(begin: 0.55, end: 1.0, duration: 800.ms);
  }

  Widget _buildEmptyState(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return _card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dcNoChallenges,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.dchCheckBack,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoItem(l10n.dchAbout1),
        _buildInfoItem(l10n.dchAbout2),
        _buildInfoItem(l10n.dchAbout3),
        _buildInfoItem(l10n.dchAbout4),
      ],
    );
  }

  /// A hanging bullet, so a wrapped line aligns with the text above it rather
  /// than sliding back under the marker.
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _challengeTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.score:
        return Icons.stars;
      case ChallengeType.foodEaten:
        return Icons.restaurant;
      case ChallengeType.gameMode:
        return Icons.games;
      case ChallengeType.survival:
        return Icons.timer;
      case ChallengeType.gamesPlayed:
        return Icons.play_circle_outline;
    }
  }
}
