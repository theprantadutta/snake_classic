import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/achievement_reveal_overlay.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/widgets/level_up_popup.dart';
import 'package:snake_classic/widgets/particle_effect.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _scoreController;
  late AnimationController _achievementController;

  final AchievementService _achievementService = AchievementService();
  final ProgressionService _progressionService = ProgressionService();
  final AudioService _audioService = AudioService();
  bool _levelUpShown = false;
  bool _doubledCoins = false; // once-per-run "watch to double coins" guard
  List<Achievement> _recentAchievements = [];
  List<Achievement> _progressAchievements = [];
  bool _achievementsLoaded = false;

  // Tracks the in-flight claim so we can show a per-card spinner without
  // disabling the rest of the section.
  final Set<String> _claimingIds = <String>{};
  bool _claimingAll = false;

  @override
  void initState() {
    super.initState();

    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _explosionController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _scoreController.forward();
    });

    _loadAchievements();

    // Re-load when the achievement service notifies. The post-game sync in
    // GameCubit._postGameSync fires server-confirmed unlocks asynchronously —
    // they show up in lastGameUnlocks ~300ms-1s after this screen first builds.
    _achievementService.addListener(_onAchievementsChanged);

    // Player XP is flushed during the same post-game sync, so a level-up
    // lands a beat after this screen mounts — listen, plus check once in
    // case it already landed.
    _progressionService.addListener(_maybeShowLevelUp);
    _maybeShowLevelUp();
  }

  void _onAchievementsChanged() {
    if (mounted) _loadAchievements();
  }

  /// Show the level-up celebration if the latest game crossed a threshold.
  /// Guarded so it fires at most once per game-over screen, and delayed so it
  /// lands after the score + achievement reveals rather than over them.
  void _maybeShowLevelUp() {
    if (_levelUpShown || !mounted) return;
    final level = _progressionService.pendingLevelUp;
    if (level == null) return;
    _levelUpShown = true;
    _progressionService.clearPendingLevelUp();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final theme = context.read<ThemeCubit>().state.currentTheme;
      LevelUpPopup.show(context: context, theme: theme, level: level);
    });
  }

  /// "Watch to double your coins" — rewarded ad, once per game-over screen.
  /// Self-hides for Pro / when no coins were earned / after it's been used.
  Widget _buildDoubleCoinsButton(GameTheme theme, int coins) {
    if (coins <= 0 || _doubledCoins) return const SizedBox.shrink();
    if (!getIt.isRegistered<AdService>() || !getIt<AdService>().adsEnabled) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: () async {
          final ads = getIt<AdService>();
          if (!ads.isRewardedReady) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No ad available right now, try again shortly'),
                ),
              );
            }
            return;
          }
          final coinsCubit = context.read<CoinsCubit>();
          // Capture before the ad — onReward fires after dismissal, an
          // async gap where reading context is unsafe.
          final messenger = ScaffoldMessenger.of(context);
          await ads.showRewarded(
            placement: 'double_coins',
            onReward: () {
              coinsCubit.earnCoins(
                CoinEarningSource.watchedAd,
                customAmount: coins,
                itemName: 'Game coins 2x',
                metadata: const {'doubled': true},
              );
              if (mounted) setState(() => _doubledCoins = true);
              showRewardToast(
                messenger,
                '🎉 Coins doubled — +$coins bonus coins!',
                icon: Icons.monetization_on,
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.amber.withValues(alpha: 0.20),
              Colors.orange.withValues(alpha: 0.12),
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.amber, size: 22),
              const SizedBox(width: 8),
              Text(
                'Watch to double your $coins coins',
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadAchievements() async {
    try {
      _recentAchievements = _achievementService.lastGameUnlocks;
      _progressAchievements = _achievementService.achievements
          .where((a) => !a.isUnlocked && a.currentProgress > 0)
          .take(3)
          .toList();

      setState(() => _achievementsLoaded = true);

      if (_recentAchievements.isNotEmpty ||
          _progressAchievements.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _achievementController.forward();
        });
      }

      _showUnlockToasts(_recentAchievements);
    } catch (_) {
      setState(() => _achievementsLoaded = true);
    }
  }

  // Deduplicates reveals across reloads — the achievement service can
  // fire a second time after the post-game sync confirms server-side
  // unlocks, and we don't want the same reveal queue twice. The overlay
  // itself also de-dupes against its in-flight queue, but tracking here
  // keeps the wait time before the first reveal predictable.
  final Set<String> _revealedIds = <String>{};

  void _showUnlockToasts(List<Achievement> unlocks) {
    final fresh =
        unlocks.where((a) => !_revealedIds.contains(a.id)).toList();
    if (fresh.isEmpty) return;
    _revealedIds.addAll(fresh.map((a) => a.id));
    // Wait until the game-over hero + score have landed before stealing
    // the screen — the trophy reveal should feel like the climax, not a
    // pop-up obscuring the result.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      AchievementRevealOverlay.show(context, fresh);
    });
  }

  Future<void> _claimReward(DailyChallenge challenge) async {
    if (_claimingIds.contains(challenge.id)) return;
    setState(() => _claimingIds.add(challenge.id));

    final success = await ref
        .read(dailyChallengesProvider.notifier)
        .claimReward(challenge.id);

    if (!mounted) return;
    setState(() => _claimingIds.remove(challenge.id));

    if (success) {
      getIt<AnalyticsFacade>().trackDailyChallengeRewardClaimed();
      if (!mounted) return;
      await context.read<CoinsCubit>().earnCoins(
        CoinEarningSource.dailyChallenge,
        customAmount: challenge.coinReward,
        itemName: challenge.title,
        metadata: {
          'challengeId': challenge.id,
          'xpReward': challenge.xpReward,
          'difficulty': challenge.difficulty.name,
          'source': 'gameOverScreen',
        },
      );

      HapticService().mediumImpact();
      _audioService.playSound('coin_collect');

      if (!mounted) return;
      _showClaimSnackbar(
        '+${challenge.coinReward} coins  •  +${challenge.xpReward} XP',
      );
    }
  }

  Future<void> _claimAllRewards(List<DailyChallenge> claimable) async {
    if (_claimingAll || claimable.isEmpty) return;
    setState(() => _claimingAll = true);

    final totalClaimed = await ref
        .read(dailyChallengesProvider.notifier)
        .claimAllRewards();

    if (!mounted) return;
    setState(() => _claimingAll = false);

    if (totalClaimed > 0) {
      if (!mounted) return;
      await context.read<CoinsCubit>().earnCoins(
        CoinEarningSource.dailyChallenge,
        customAmount: totalClaimed,
        itemName: 'Daily Challenges (game over)',
        metadata: {
          'bulkClaim': true,
          'count': claimable.length,
          'source': 'gameOverScreen',
        },
      );

      HapticService().heavyImpact();
      _audioService.playSound('coin_collect');

      if (!mounted) return;
      _showClaimSnackbar('Claimed $totalClaimed coins from daily challenges!');
    }
  }

  void _showClaimSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _achievementService.removeListener(_onAchievementsChanged);
    _progressionService.removeListener(_maybeShowLevelUp);
    _explosionController.dispose();
    _scoreController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocBuilder<GameCubit, GameCubitState>(
          builder: (context, gameCubitState) {
            final gameState = gameCubitState.gameState;
            if (gameState == null) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.accentColor),
                  ),
                ),
              );
            }

            final authState = context.watch<AuthCubit>().state;
            final displayHighScore = math.max(
              gameState.highScore,
              authState.highScore,
            );
            final isHighScore =
                gameState.score == displayHighScore && gameState.score > 0;

            // Daily challenges — only show the section when there's something
            // claimable. Watched here so the section reactively hides after
            // the last claim succeeds.
            final challenges = ref.watch(
              dailyChallengesProvider.select((s) => s.challenges),
            );
            final claimable =
                challenges.where((c) => c.canClaim).toList(growable: false);

            return Scaffold(
              bottomNavigationBar: const SnakeBannerAd(),
              body: AppBackground(
                theme: theme,
                child: SafeArea(
                  child: Stack(
                    children: [
                      if (isHighScore)
                        ParticleEffect(
                          controller: _explosionController,
                          color: Colors.amber,
                        ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxHeight < 700;
                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics:
                                      const BouncingScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    16,
                                    compact ? 8 : 16,
                                    16,
                                    8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _HeroHeader(
                                        theme: theme,
                                        isHighScore: isHighScore,
                                        compact: compact,
                                      ),
                                      SizedBox(height: compact ? 12 : 16),
                                      if (isHighScore)
                                        _OutcomeRibbon(
                                          icon: Icons.emoji_events,
                                          label: 'NEW HIGH SCORE!',
                                          colors: const [
                                            Colors.amber,
                                            Colors.orange,
                                          ],
                                          compact: compact,
                                          delayMs: 200,
                                          shimmerDelayMs: 600,
                                        ),
                                      if (gameCubitState.isTournamentMode &&
                                          gameCubitState.tournamentMode !=
                                              null) ...[
                                        if (isHighScore)
                                          const SizedBox(height: 8),
                                        _OutcomeRibbon(
                                          // Keyed so the ribbon re-animates
                                          // when the submission resolves.
                                          key: ValueKey(gameCubitState
                                              .tournamentScoreSubmission),
                                          icon: null,
                                          emoji: gameCubitState
                                              .tournamentMode!.emoji,
                                          label: switch (gameCubitState
                                              .tournamentScoreSubmission) {
                                            TournamentScoreSubmission
                                                  .submitted =>
                                              'TOURNAMENT SCORE SUBMITTED!',
                                            TournamentScoreSubmission
                                                  .failed =>
                                              'SCORE NOT SUBMITTED — CHECK CONNECTION',
                                            _ =>
                                              'SUBMITTING TOURNAMENT SCORE…',
                                          },
                                          colors: gameCubitState
                                                      .tournamentScoreSubmission ==
                                                  TournamentScoreSubmission
                                                      .failed
                                              ? const [
                                                  Colors.redAccent,
                                                  Colors.red,
                                                ]
                                              : const [
                                                  Colors.purple,
                                                  Colors.deepPurple,
                                                ],
                                          compact: compact,
                                          delayMs: 300,
                                          shimmerDelayMs: 800,
                                        ),
                                      ],
                                      SizedBox(height: compact ? 12 : 16),
                                      _ScoreCard(
                                        gameState: gameState,
                                        theme: theme,
                                        displayHighScore: displayHighScore,
                                        coinsEarned: gameCubitState
                                            .coinsEarnedThisGame,
                                        scoreController: _scoreController,
                                        compact: compact,
                                      ),
                                      _buildDoubleCoinsButton(
                                        theme,
                                        gameCubitState.coinsEarnedThisGame,
                                      ),
                                      if (claimable.isNotEmpty) ...[
                                        SizedBox(height: compact ? 10 : 14),
                                        _DailyRewardsCard(
                                          theme: theme,
                                          claimable: claimable,
                                          compact: compact,
                                          claimingIds: _claimingIds,
                                          claimingAll: _claimingAll,
                                          onClaim: _claimReward,
                                          onClaimAll: () =>
                                              _claimAllRewards(claimable),
                                        ),
                                      ],
                                      if (_achievementsLoaded &&
                                          (_recentAchievements.isNotEmpty ||
                                              _progressAchievements
                                                  .isNotEmpty)) ...[
                                        SizedBox(height: compact ? 10 : 14),
                                        _AchievementSection(
                                          theme: theme,
                                          recent: _recentAchievements,
                                          progress: _progressAchievements,
                                          controller: _achievementController,
                                          compact: compact,
                                        ),
                                      ],
                                      SizedBox(height: compact ? 8 : 12),
                                    ],
                                  ),
                                ),
                              ),
                              _BottomActionBar(theme: theme, compact: compact),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Hero header — animated outcome icon + bold "GAME OVER" / "VICTORY"
/// ─────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final GameTheme theme;
  final bool isHighScore;
  final bool compact;

  const _HeroHeader({
    required this.theme,
    required this.isHighScore,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHighScore ? Colors.amber : theme.foodColor;
    final title = isHighScore ? 'VICTORY!' : 'GAME OVER';
    final icon = isHighScore
        ? Icons.emoji_events_rounded
        : Icons.sentiment_very_dissatisfied_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glow ring with center icon.
        Container(
          width: compact ? 72 : 88,
          height: compact ? 72 : 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: compact ? 38 : 46),
        ).gamePop().gameBreathe(intensity: 1.05),

        SizedBox(height: compact ? 10 : 14),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 34 : 44,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 4,
            height: 1.0,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 8,
                color: color.withValues(alpha: 0.55),
              ),
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 2,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
        ).gameHero(),
      ],
    );
  }
}

/// Reusable badge ribbon (high score / tournament).
class _OutcomeRibbon extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String label;
  final List<Color> colors;
  final bool compact;
  final int delayMs;
  final int shimmerDelayMs;

  const _OutcomeRibbon({
    super.key,
    required this.icon,
    this.emoji,
    required this.label,
    required this.colors,
    required this.compact,
    required this.delayMs,
    required this.shimmerDelayMs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 7 : 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, color: Colors.white, size: compact ? 16 : 18)
                else if (emoji != null)
                  Text(
                    emoji!,
                    style: TextStyle(fontSize: compact ? 14 : 16),
                  ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 11 : 13,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          )
          .gamePop(delay: Duration(milliseconds: delayMs))
          .animate()
          .shimmer(delay: Duration(milliseconds: shimmerDelayMs)),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Score card with animated counters + coins-earned row
/// ─────────────────────────────────────────────────────────────────────
class _ScoreCard extends StatelessWidget {
  final GameState gameState;
  final GameTheme theme;
  final int displayHighScore;
  final int coinsEarned;
  final AnimationController scoreController;
  final bool compact;

  const _ScoreCard({
    required this.gameState,
    required this.theme,
    required this.displayHighScore,
    required this.coinsEarned,
    required this.scoreController,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.accentColor.withValues(alpha: 0.18),
            theme.backgroundColor.withValues(alpha: 0.35),
            theme.foodColor.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Score row — label left, big animated number right.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'FINAL SCORE',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.75),
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              AnimatedBuilder(
                animation: scoreController,
                builder: (context, _) {
                  final animatedScore =
                      (gameState.score * scoreController.value).round();
                  return Text(
                    '$animatedScore',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: compact ? 34 : 42,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: theme.accentColor.withValues(alpha: 0.6),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),

          // Stat strip — length, level, high score with subtle separators.
          Row(
            children: [
              _StatTile(
                label: 'LENGTH',
                value: gameState.snake.length,
                icon: Icons.straighten,
                theme: theme,
                delayMs: 150,
                compact: compact,
              ),
              _StatDivider(theme: theme),
              _StatTile(
                label: 'LEVEL',
                value: gameState.level,
                icon: Icons.trending_up,
                theme: theme,
                delayMs: 300,
                compact: compact,
              ),
              _StatDivider(theme: theme),
              _StatTile(
                label: 'BEST',
                value: displayHighScore,
                icon: Icons.emoji_events,
                theme: theme,
                delayMs: 450,
                compact: compact,
                highlight: true,
              ),
            ],
          ),

          if (coinsEarned > 0) ...[
            SizedBox(height: compact ? 12 : 14),
            _CoinsEarnedRow(coinsEarned: coinsEarned, theme: theme),
          ],
        ],
      ),
    ).gameEntrance(delay: 400.ms);
  }
}

class _StatDivider extends StatelessWidget {
  final GameTheme theme;
  const _StatDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: theme.accentColor.withValues(alpha: 0.18),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final GameTheme theme;
  final int delayMs;
  final bool compact;
  final bool highlight;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.theme,
    required this.delayMs,
    required this.compact,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? Colors.amber : theme.accentColor;
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + delayMs),
        curve: Interval(
          delayMs / (600 + delayMs),
          1.0,
          curve: Curves.easeOutCubic,
        ),
        builder: (context, t, _) {
          final shown = (value * t).round();
          return Column(
            children: [
              Icon(icon, color: color.withValues(alpha: 0.85), size: 16),
              const SizedBox(height: 4),
              Text(
                '$shown',
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 20 : 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoinsEarnedRow extends StatelessWidget {
  final int coinsEarned;
  final GameTheme theme;
  const _CoinsEarnedRow({required this.coinsEarned, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.25),
            Colors.orange.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 900),
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
        builder: (context, t, _) {
          final shown = (coinsEarned * t).round();
          return Row(
            children: [
              const Icon(Icons.monetization_on,
                  color: Colors.amber, size: 22),
              const SizedBox(width: 10),
              Text(
                'Coins Earned',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '+$shown',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Daily rewards card — only rendered when there's at least one claimable
/// reward. Mirrors the claim flow from DailyChallengesScreen.
/// ─────────────────────────────────────────────────────────────────────
class _DailyRewardsCard extends StatelessWidget {
  final GameTheme theme;
  final List<DailyChallenge> claimable;
  final bool compact;
  final Set<String> claimingIds;
  final bool claimingAll;
  final Future<void> Function(DailyChallenge) onClaim;
  final VoidCallback onClaimAll;

  const _DailyRewardsCard({
    required this.theme,
    required this.claimable,
    required this.compact,
    required this.claimingIds,
    required this.claimingAll,
    required this.onClaim,
    required this.onClaimAll,
  });

  @override
  Widget build(BuildContext context) {
    final totalCoins = claimable.fold<int>(0, (s, c) => s + c.coinReward);
    final totalXp = claimable.fold<int>(0, (s, c) => s + c.xpReward);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.18),
            Colors.orange.withValues(alpha: 0.12),
            theme.backgroundColor.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header — title, total rewards, claim-all CTA.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.redeem,
                    color: Colors.amber, size: 18),
              ).gameBreathe(intensity: 1.08),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY REWARDS READY',
                      style: TextStyle(
                        color: Colors.amber.shade300,
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${claimable.length} '
                      '${claimable.length == 1 ? 'reward' : 'rewards'}'
                      '  •  +$totalCoins coins  •  +$totalXp XP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (claimable.length > 1)
                _ClaimAllPill(
                  busy: claimingAll,
                  onTap: onClaimAll,
                ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),

          // Per-challenge rows.
          ...claimable.asMap().entries.map(
                (e) => Padding(
                  padding: EdgeInsets.only(
                    bottom: e.key == claimable.length - 1 ? 0 : 8,
                  ),
                  child: _ClaimableRow(
                    challenge: e.value,
                    theme: theme,
                    busy: claimingIds.contains(e.value.id) || claimingAll,
                    onClaim: () => onClaim(e.value),
                  ).gameListItem(e.key),
                ),
              ),
        ],
      ),
    ).gameZoomIn(delay: 500.ms);
  }
}

class _ClaimAllPill extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _ClaimAllPill({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: busy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'CLAIM ALL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1800.ms,
          delay: 600.ms,
          color: Colors.white.withValues(alpha: 0.45),
        );
  }
}

class _ClaimableRow extends StatelessWidget {
  final DailyChallenge challenge;
  final GameTheme theme;
  final bool busy;
  final VoidCallback onClaim;

  const _ClaimableRow({
    required this.challenge,
    required this.theme,
    required this.busy,
    required this.onClaim,
  });

  Color get _difficultyColor {
    switch (challenge.difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
    }
  }

  IconData get _typeIcon {
    switch (challenge.type) {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: busy ? null : onClaim,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _difficultyColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: _difficultyColor, width: 1.5),
                ),
                child: Icon(_typeIcon,
                    color: _difficultyColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${challenge.coinReward}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.star,
                            color: Colors.purpleAccent, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          '${challenge.xpReward} XP',
                          style: TextStyle(
                            color: Colors.purple.shade200,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: busy ? null : onClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.amber.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 0,
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.redeem, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Claim',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Achievements section (recent unlocks + in-progress)
/// ─────────────────────────────────────────────────────────────────────
class _AchievementSection extends StatelessWidget {
  final GameTheme theme;
  final List<Achievement> recent;
  final List<Achievement> progress;
  final AnimationController controller;
  final bool compact;

  const _AchievementSection({
    required this.theme,
    required this.recent,
    required this.progress,
    required this.controller,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Transform.scale(
        scale: 0.85 + controller.value * 0.15,
        child: Opacity(
          opacity: controller.value,
          child: Container(
            padding: EdgeInsets.all(compact ? 12 : 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.accentColor.withValues(alpha: 0.10),
                  theme.foodColor.withValues(alpha: 0.06),
                  theme.backgroundColor.withValues(alpha: 0.3),
                ],
              ),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.4),
                width: 1.4,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ACHIEVEMENTS',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 10),
                if (recent.isNotEmpty) ...[
                  _SubsectionLabel(
                    text: 'Recently Unlocked',
                    color: Colors.green,
                    compact: compact,
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  ...recent.take(compact ? 1 : 2).map(
                        (a) => _AchievementTile(
                          achievement: a,
                          theme: theme,
                          isUnlocked: true,
                          compact: compact,
                        ),
                      ),
                  if (progress.isNotEmpty)
                    SizedBox(height: compact ? 8 : 10),
                ],
                if (progress.isNotEmpty) ...[
                  _SubsectionLabel(
                    text: 'In Progress',
                    color: Colors.orange,
                    compact: compact,
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  ...progress.take(compact ? 1 : 2).map(
                        (a) => _AchievementTile(
                          achievement: a,
                          theme: theme,
                          isUnlocked: false,
                          compact: compact,
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  final bool compact;
  const _SubsectionLabel({
    required this.text,
    required this.color,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: compact ? 10 : 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final GameTheme theme;
  final bool isUnlocked;
  final bool compact;

  const _AchievementTile({
    required this.achievement,
    required this.theme,
    required this.isUnlocked,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 4 : 6),
      padding: EdgeInsets.all(compact ? 7 : 9),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.green.withValues(alpha: 0.1)
            : theme.backgroundColor.withValues(alpha: 0.4),
        border: Border.all(
          color: isUnlocked
              ? Colors.green.withValues(alpha: 0.4)
              : theme.accentColor.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 5 : 6),
            decoration: BoxDecoration(
              color: achievement.rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.rarityColor,
              size: compact ? 14 : 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: compact ? 11 : 12,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isUnlocked)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 14)
                    else
                      Text(
                        '${(achievement.progressPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progressPercentage,
                      backgroundColor:
                          theme.backgroundColor.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.orange),
                      minHeight: 3,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${achievement.points}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Sticky bottom action bar (Play Again / Menu).
/// Lives outside the scroll view so the CTAs are always reachable.
/// ─────────────────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final GameTheme theme;
  final bool compact;
  const _BottomActionBar({required this.theme, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, compact ? 10 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.backgroundColor.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              width: double.infinity,
              height: compact ? 50 : 56,
              onPressed: () async {
                // Frequency-capped + Pro/connectivity-gated inside AdService;
                // a no-op when an ad shouldn't show.
                await getIt<AdService>().maybeShowInterstitialOnGameOver();
                if (!context.mounted) return;
                context.read<GameCubit>().resetGame();
                context.go(AppRoutes.game);
              },
              text: 'PLAY AGAIN',
              primaryColor: theme.accentColor,
              secondaryColor: theme.foodColor,
              icon: Icons.refresh,
            ).gameZoomIn(delay: 600.ms),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GradientButton(
              width: double.infinity,
              height: compact ? 50 : 56,
              onPressed: () async {
                await getIt<AdService>().maybeShowInterstitialOnGameOver();
                if (!context.mounted) return;
                context.read<GameCubit>().backToMenu();
                context.go(AppRoutes.home);
              },
              text: 'MENU',
              primaryColor: theme.snakeColor.withValues(alpha: 0.85),
              secondaryColor: theme.snakeColor.withValues(alpha: 0.6),
              icon: Icons.home,
              outlined: true,
            ).gameZoomIn(delay: 700.ms),
          ),
        ],
      ),
    );
  }
}
