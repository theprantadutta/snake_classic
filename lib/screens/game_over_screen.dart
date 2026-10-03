import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb/lb_crash_copy.dart';
import 'package:snake_classic/widgets/game_over_continue_sheet.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/widgets/game_mode_picker_sheet.dart';
import 'package:snake_classic/widgets/ads/ad_break_curtain.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/widgets/ads/rewarded_interstitial_intro.dart';
import 'package:snake_classic/widgets/tap_arm_guard.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/achievement_l10n.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
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
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/ads/game_over_ad_gate.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/achievement_reveal_overlay.dart';
import 'package:snake_classic/widgets/deferred_sign_in_prompt.dart';
import 'package:snake_classic/widgets/level_up_popup.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  /// Seeds the crash line so it stays the same across rebuilds.
  final int _seed = DateTime.now().millisecondsSinceEpoch;

  final AchievementService _achievementService = AchievementService();
  final ProgressionService _progressionService = ProgressionService();
  final AudioService _audioService = AudioService();
  bool _levelUpShown = false;
  bool _doubledCoins = false; // once-per-run "watch to double coins" guard

  // Spare height goes to the run chart: lay out once with the base 9 rows,
  // measure what is left under the last block, then grow the chart by that
  // many rows. Measured, not intrinsic — the chart sizes itself with a
  // LayoutBuilder, which cannot report an intrinsic height.
  static const int _baseChartRows = 9;
  static const int _maxChartRows = 18;
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _chartKey = GlobalKey();
  double _viewportHeight = 0;
  int _extraChartRows = 0;
  bool _chartFitted = false;

  void _fitChart() {
    if (_chartFitted || !mounted) return;
    final content = _contentKey.currentContext?.size;
    final chart = _chartKey.currentContext?.size;
    if (content == null || chart == null || _viewportHeight <= 0) return;
    _chartFitted = true;
    final cellH = chart.height / _baseChartRows;
    if (cellH <= 0) return;
    final spare = _viewportHeight - content.height;
    final extra = (spare / cellH).floor().clamp(
      0,
      _maxChartRows - _baseChartRows,
    );
    if (extra > 0) setState(() => _extraChartRows = extra);
  }

  List<Achievement> _recentAchievements = [];
  bool _achievementsLoaded = false;

  bool _claimingAll = false;

  /// One-shot guard for the deferred sign-in ask. build() runs on every cubit
  /// emission (achievements and XP land asynchronously after this screen
  /// mounts), so without this the prompt would be scheduled several times per
  /// game over.
  bool _signInPromptChecked = false;

  /// One-shot guard for the Day-1 reminder, for the same reason as
  /// [_signInPromptChecked] — build() runs repeatedly per game over.
  bool _dayOneReminderArmed = false;

  @override
  void initState() {
    super.initState();

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

  /// Arms the one-shot Day-1 comeback notification, once per game-over screen.
  ///
  /// Re-armed on every game over rather than only the first, so the reminder
  /// always points ~20h past the player's most recent session instead of
  /// ~20h past a first game they may have followed with ten more. The fixed
  /// notification id in NotificationService makes re-arming a replace, never
  /// a stack.
  void _armDayOneReminder(int highScore, AppLocalizations l10n) {
    if (_dayOneReminderArmed) return;
    _dayOneReminderArmed = true;
    unawaited(
      NotificationService().scheduleDayOneReminder(
        highScore: highScore,
        l10n: l10n,
      ),
    );
  }

  /// Schedules the "save your progress" ask for a guest who just set a
  /// personal best. Every other gate (guest status, first-run window, ask
  /// budget, cooldown) lives in [DeferredSignInPrompt.maybeShow]; this only
  /// decides WHEN to offer it the chance.
  ///
  /// The delay puts it after the score reveal (500ms) and the level-up popup
  /// (1400ms) so the three never stack — the stacking of first-launch prompts
  /// on top of each other is exactly the pattern this whole effort is undoing.
  void _scheduleDeferredSignIn({
    required bool isHighScore,
    required bool isSignedIn,
    required GameTheme theme,
  }) {
    if (_signInPromptChecked) return;
    _signInPromptChecked = true;

    if (!isHighScore || isSignedIn) return;

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      DeferredSignInPrompt.maybeShow(
        context,
        isSignedIn: isSignedIn,
        isNewHighScore: isHighScore,
        theme: theme,
      );
    });
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

  Future<void> _loadAchievements() async {
    try {
      _recentAchievements = _achievementService.lastGameUnlocks;

      setState(() => _achievementsLoaded = true);

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
    final fresh = unlocks.where((a) => !_revealedIds.contains(a.id)).toList();
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

  Future<void> _claimAllRewards(List<DailyChallenge> claimable) async {
    if (_claimingAll || claimable.isEmpty) return;
    setState(() => _claimingAll = true);

    final totalClaimed = await ref
        .read(dailyChallengesProvider.notifier)
        .claimAllRewards();

    if (!mounted) return;
    setState(() => _claimingAll = false);

    if (totalClaimed > 0) {
      // Same as the single claim: claimAllRewards already credited the total.
      if (!mounted) return;
      HapticService().heavyImpact();
      _audioService.playSound('coin_collect');

      if (!mounted) return;
      _showClaimSnackbar(
        AppLocalizations.of(context)!.goClaimedTotal(totalClaimed),
      );
    }
  }

  void _showClaimSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: message,
        tone: ArcadeSnackTone.success,
        icon: Icons.monetization_on,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _achievementService.removeListener(_onAchievementsChanged);
    _progressionService.removeListener(_maybeShowLevelUp);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameCubitState = context.watch<GameCubit>().state;
    final theme = context.watch<ThemeCubit>().state.currentTheme;
    final gameState = gameCubitState.gameState;
    if (gameState == null) {
      return Scaffold(
        body: LBGridBackground(
          child: Center(
            child: LBCellsBar(
              count: 6,
              value: .5,
              cell: 14,
              color: context.lb.lime,
            ),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final authState = context.watch<AuthCubit>().state;
    final displayHighScore = math.max(gameState.highScore, authState.highScore);
    final isHighScore =
        gameState.score == displayHighScore && gameState.score > 0;

    // Guests who just beat their own record get the sign-in offer here —
    // the moment their progress is demonstrably worth keeping.
    _scheduleDeferredSignIn(
      isHighScore: isHighScore,
      isSignedIn: authState.isSignedIn && !authState.isGuestUser,
      theme: theme,
    );

    // Arm the Day-1 comeback nudge with the score they just posted.
    _armDayOneReminder(displayHighScore, l10n);

    final challenges = ref.watch(
      dailyChallengesProvider.select((s) => s.challenges),
    );
    final claimable = challenges
        .where((c) => c.canClaim)
        .toList(growable: false);

    final cubit = context.read<GameCubit>();
    final bites = cubit.bitesThisGame;
    final reason = LBCrashCopy.reasonOf(gameState);
    final crashCopy = LBCrashCopy.of(
      l10n,
      reason,
      length: gameState.snake.length,
      food: bites.length,
      seed: _seed,
    );
    final cell = context.lbCell;
    final g = context.lbGutter;

    return Scaffold(
      // Separated from AGAIN / HOME, which sit above it. Google's placement
      // policy calls out ads next to play and navigation buttons by name.
      bottomNavigationBar: const LBBannerSlot(topGap: 20),
      body: LBGridBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, viewport) {
              _viewportHeight = viewport.maxHeight;
              if (!_chartFitted) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _fitChart(),
                );
              }
              return SingleChildScrollView(
                child: Padding(
                  key: _contentKey,
                  padding: EdgeInsets.fromLTRB(g, cell * .6, g, cell),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // × YOU BIT YOURSELF. WHY?            RUN 412
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.lbGameOverHeadline(
                                crashCopy.line.toUpperCase(),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: LBText.button(
                                p,
                                color: LB.bonk,
                                size: 12.5,
                              ).copyWith(letterSpacing: 1.6),
                            ),
                          ),
                          if (cubit.runNumber > 0) ...[
                            const SizedBox(width: 10),
                            Text(
                              l10n.lbGoRun(context.formatInt(cubit.runNumber)),
                              style: LBText.label(
                                p,
                                color: p.inkDim,
                              ).copyWith(fontSize: 10.5),
                            ),
                          ],
                        ],
                      ),
                      if (gameCubitState.isTournamentMode &&
                          gameCubitState.tournamentMode != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: LBChip(
                            icon: LBIcon.trophy,
                            height: 26,
                            kind:
                                gameCubitState.tournamentScoreSubmission ==
                                    TournamentScoreSubmission.failed
                                ? LBChipKind.danger
                                : LBChipKind.gold,
                            label: switch (gameCubitState
                                .tournamentScoreSubmission) {
                              TournamentScoreSubmission.submitted =>
                                l10n.goRibbonTournamentSubmitted,
                              TournamentScoreSubmission.failed =>
                                l10n.goRibbonTournamentFailed,
                              _ => l10n.goRibbonTournamentSubmitting,
                            }.toUpperCase(),
                          ),
                        ),
                      ],
                      SizedBox(height: cell),
                      _ScoreRow(
                        score: gameState.score,
                        best: displayHighScore,
                        isNewBest: isHighScore,
                      ),
                      SizedBox(height: cell * 1.2),
                      LBSectionLabel(
                        l10n.lbGoChartTitle,
                        color: p.lime,
                        trailing: l10n.lbGoChartStats(
                          context.formatInt(bites.length),
                          '${gameState.maxCombo}',
                        ),
                      ),
                      const SizedBox(height: 6),
                      KeyedSubtree(
                        key: _chartKey,
                        child: bites.isEmpty
                            // No food: an empty grid with a lone crash mark reads as
                            // broken. Same footprint, said in words.
                            ? LBBlock(
                                kind: LBBlockKind.muted,
                                height:
                                    cell * (_baseChartRows + _extraChartRows) -
                                    LB.inset * 2,
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.lbGoNoBites,
                                  textAlign: TextAlign.center,
                                  style: LBText.body(
                                    p,
                                    color: p.inkMuted,
                                    size: 12,
                                  ),
                                ),
                              )
                            : LBRunChart(
                                bites: bites,
                                rows: _baseChartRows + _extraChartRows,
                                crashed:
                                    reason == LBEndReason.wall ||
                                    reason == LBEndReason.self ||
                                    reason == LBEndReason.stepped,
                              ),
                      ),
                      if (bites.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.lbGoChartCaption,
                          style: LBText.label(
                            p,
                            color: p.inkDim,
                          ).copyWith(fontSize: 9),
                        ),
                      ],
                      SizedBox(height: cell * .8),
                      _GameOverActions(
                        theme: theme,
                        gameState: gameState,
                        coinsEarned:
                            gameCubitState.coinsEarnedThisGame *
                            (_doubledCoins ? 2 : 1),
                        claimable: claimable,
                        claimingAll: _claimingAll,
                        onClaimAll: () => _claimAllRewards(claimable),
                        doubleCoins: _doubleCoinsAction(
                          gameCubitState.coinsEarnedThisGame,
                        ),
                      ),
                      if (_achievementsLoaded &&
                          _recentAchievements.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        LBRow(
                          kind: LBBlockKind.gold,
                          leading: const LBPixelIcon(
                            LBIcon.trophy,
                            cell: 3.4,
                            color: LB.gold,
                          ),
                          title:
                              '${l10n.lbTrophies} · ${_recentAchievements.length}',
                          subtitle: _recentAchievements
                              .map((a) => a.localizedTitle(l10n))
                              .join(' · '),
                          trailing: Text(
                            '→',
                            style: LBText.button(p, color: LB.gold),
                          ),
                          onTap: () => context.push(AppRoutes.achievements),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// "Watch to double your coins" — rewarded ad, once per game-over screen.
  /// Null (hidden) for Pro, when no coins were earned, or once used.
  VoidCallback? _doubleCoinsAction(int coins) {
    if (coins <= 0 || _doubledCoins) return null;
    if (!getIt.isRegistered<AdService>() || !getIt<AdService>().adsEnabled) {
      return null;
    }
    return () async {
      final l10n = AppLocalizations.of(context)!;
      final ads = getIt<AdService>();
      if (!ads.isRewardedReady) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(arcadeSnackBar(context, message: l10n.goNoAdAvailable));
        return;
      }
      final coinsCubit = context.read<CoinsCubit>();
      // Capture before the ad — onReward fires after dismissal, an async gap
      // where reading context is unsafe.
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
            l10n.goCoinsDoubled(coins),
            icon: Icons.monetization_on,
          );
        },
      );
    };
  }
}

/// SCORE in big snake cells; BEST and the gap (or NEW BEST) beside it.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.score,
    required this.best,
    required this.isNewBest,
  });

  final int score;
  final int best;
  final bool isNewBest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.lbScoreLabel,
                style: LBText.label(p).copyWith(fontSize: 10.5),
              ),
              const SizedBox(height: 4),
              Semantics(
                label: '${l10n.lbScoreLabel} $score',
                excludeSemantics: true,
                child: LBAnimatedCellText(
                  '$score',
                  cell: cell * .9,
                  glow: true,
                  color: isNewBest ? LB.gold : p.lime,
                  duration: const Duration(milliseconds: 420),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Text(
                isNewBest ? l10n.lbGoNewBest : l10n.lbGoBest,
                style: LBText.label(
                  p,
                  color: isNewBest ? LB.gold : p.inkMuted,
                ).copyWith(fontSize: 10.5),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.formatInt(best),
                  style: LBText.value(p, color: LB.gold, size: 28),
                ),
              ),
              const SizedBox(height: 4),
              if (isNewBest)
                Text(l10n.lbGoNewBestLine, style: LBText.body(p, size: 11.5))
              else if (best > score) ...[
                Text(
                  l10n.lbGoBehind(context.formatInt(best - score)),
                  style: LBText.body(
                    p,
                    color: p.inkMuted,
                    size: 12,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                Text(l10n.lbGoBehindLine, style: LBText.body(p, size: 11)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// AGAIN / CONTINUE, rewards, 2× coins, replay and HOME. Owns the game-over
/// ad slot exactly as before: AGAIN and HOME both run it, one press at a
/// time, announced above the buttons, behind a 900 ms tap-arm guard.
class _GameOverActions extends StatefulWidget {
  const _GameOverActions({
    required this.theme,
    required this.gameState,
    required this.coinsEarned,
    required this.claimable,
    required this.claimingAll,
    required this.onClaimAll,
    required this.doubleCoins,
  });

  final GameTheme theme;
  final GameState gameState;
  final int coinsEarned;
  final List<DailyChallenge> claimable;
  final bool claimingAll;
  final VoidCallback onClaimAll;
  final VoidCallback? doubleCoins;

  @override
  State<_GameOverActions> createState() => _GameOverActionsState();
}

class _GameOverActionsState extends State<_GameOverActions> {
  GameTheme get theme => widget.theme;

  // One press at a time. A double-tap on AGAIN used to start the ad slot
  // twice. Deliberately not state: nothing is drawn from it.
  bool _busy = false;

  Timer? _continueTicker;

  /// Latched once CONTINUE has been shown. When the offer closes the block
  /// stays where it was, inert, rather than AGAIN widening into the space
  /// under a thumb that was reaching for CONTINUE — AGAIN runs the ad slot.
  bool _continueOffered = false;

  @override
  void initState() {
    super.initState();
    // Repaint the continue countdown each second while the offer is open.
    _continueTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _continueTicker?.cancel();
    super.dispose();
  }

  Future<void> _press(Future<void> Function() action) async {
    if (_busy) return;
    _busy = true;
    try {
      await action();
    } finally {
      _busy = false;
    }
  }

  /// Run the game-over ad slot. AdService picks the format: a rewarded
  /// interstitial when one is loaded (the player earns coins for sitting
  /// through it), otherwise the plain interstitial, otherwise nothing.
  ///
  /// Everything the reward callback touches is captured BEFORE the await —
  /// onReward fires after the ad is dismissed, across an async gap where this
  /// context may already be gone. [announced] is what this bar told the
  /// player when it built; the slot honours it, so the notice is never a lie.
  /// Before anything plays, the confirm step puts up either the rewarded
  /// interstitial's intro screen (Google-required, with a real skip) or a
  /// short tap-absorbing "Ad starting…" curtain.
  Future<void> _showGameOverAd(
    BuildContext context, {
    required GameOverAdFormat announced,
  }) async {
    final coins = context.read<CoinsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    AdBreakCurtain? curtain;
    try {
      await getIt<AdService>().maybeShowGameOverAd(
        announced: announced,
        confirm: (format) async {
          if (!context.mounted) return false;
          if (format == GameOverAdFormat.rewarded) {
            final watch = await showRewardedInterstitialIntro(
              context,
              theme: theme,
              coins: AdService.freeCoinsPerAd,
            );
            if (!watch || !context.mounted) return false;
            curtain = AdBreakCurtain.show(
              context,
              theme: theme,
              label: l10n.adBreakStarting,
            );
            return true;
          }
          curtain = AdBreakCurtain.show(
            context,
            theme: theme,
            label: l10n.adBreakStarting,
          );
          await Future<void>.delayed(const Duration(milliseconds: 700));
          return true;
        },
        onAdShowing: () => curtain?.dismiss(),
        onReward: () {
          coins.earnCoins(
            CoinEarningSource.watchedAd,
            customAmount: AdService.freeCoinsPerAd,
            itemName: 'Game over bonus',
          );
          showRewardToast(
            messenger,
            l10n.goAdBonusCoins(AdService.freeCoinsPerAd),
            icon: Icons.monetization_on,
          );
        },
      );
    } finally {
      curtain?.dismiss();
    }
  }

  Future<void> _again(BuildContext context, GameOverAdFormat announced) =>
      _press(() async {
        final cubit = context.read<GameCubit>();
        await cubit.finalizeGameOver();
        if (!context.mounted) return;
        // Frequency-capped + Pro/connectivity-gated inside AdService; a no-op
        // when an ad shouldn't show.
        await _showGameOverAd(context, announced: announced);
        if (!context.mounted) return;
        // Strictly AFTER the ad — the picker is a modal sheet and would
        // otherwise be raced by (or buried under) a full-screen ad.
        await maybeShowGameModePicker(context);
        if (!context.mounted) return;
        context.read<GameCubit>().resetGame();
        context.go(AppRoutes.game);
      });

  Future<void> _home(BuildContext context, GameOverAdFormat announced) =>
      _press(() async {
        await context.read<GameCubit>().finalizeGameOver();
        if (!context.mounted) return;
        await _showGameOverAd(context, announced: announced);
        if (!context.mounted) return;
        // Offered on this path too: a player heading back to the menu after
        // one game is exactly the churn-risk cohort this picker exists to
        // reach.
        await maybeShowGameModePicker(context);
        if (!context.mounted) return;
        context.read<GameCubit>().backToMenu();
        context.go(AppRoutes.home);
      });

  Future<void> _replay(BuildContext context) => _press(() async {
    final cubit = context.read<GameCubit>();
    await cubit.finalizeGameOver();
    if (!context.mounted) return;
    final id = cubit.lastReplayId;
    context.push(
      id == null ? AppRoutes.replays : AppRoutes.replayViewerPath(id),
    );
  });

  /// CONTINUE: hold the window, then let the player pay with an ad, coins
  /// or (Pro) nothing at all.
  Future<void> _continue(BuildContext context) => _press(() async {
    final cubit = context.read<GameCubit>();
    if (!cubit.canContinueFromGameOver) return;
    cubit.holdGameOverContinue();
    final resumed = await showGameOverContinueSheet(context, theme: theme);
    if (!context.mounted) return;
    if (resumed) {
      context.go(AppRoutes.game);
    } else {
      // Declined: the run is over.
      await cubit.finalizeGameOver();
      if (mounted) setState(() {});
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final settings = context.read<GameSettingsCubit>().state;
    final cubit = context.read<GameCubit>();
    // Decided once per build and captured by both buttons, so the notice and
    // the press agree even if an ad fills in between.
    final announced = getIt<AdService>().peekGameOverAd();
    final deadline = cubit.gameOverContinueDeadline;
    final secsLeft = deadline == null
        ? 0
        : deadline.difference(DateTime.now()).inMilliseconds / 1000;
    final canContinue = cubit.canContinueFromGameOver && secsLeft > 0;
    if (canContinue) _continueOffered = true;
    final isPro = context.read<PremiumCubit>().state.hasPremium;

    final claimCoins = widget.claimable.fold<int>(
      0,
      (s, c) => s + c.coinReward,
    );
    final claimXp = widget.claimable.fold<int>(0, (s, c) => s + c.xpReward);

    final again = LBBlock(
      kind: LBBlockKind.fill,
      height: cell * 5,
      alignment: Alignment.center,
      semanticLabel: l10n.lbAgain,
      onTap: () => _again(context, announced),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBCellText(
            l10n.lbAgain,
            cell: 6.5 * context.uiScale,
            color: p.onLime,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.lbModeBoard(
              widget.gameState.gameMode.localizedName(l10n).toUpperCase(),
              settings.boardSize.id.replaceAll('x', '×'),
            ),
            style: LBText.label(p, color: p.onLime.withValues(alpha: .7)),
          ),
        ],
      ),
    );

    return TapArmGuard(
      // Not live until the buttons have finished arriving: this screen
      // appears the moment a run ends, often under a thumb that was still
      // steering, and a stray tap here can start an ad.
      delay: const Duration(milliseconds: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Say so BEFORE the press. A rewarded ad is a bonus and reads as
          // one; a plain one is a toll the player at least agreed to.
          if (announced != GameOverAdFormat.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Semantics(
                liveRegion: true,
                child: Row(
                  children: [
                    LBPixelIcon(
                      announced == GameOverAdFormat.rewarded
                          ? LBIcon.coin
                          : LBIcon.tv,
                      cell: 2.6,
                      color: announced == GameOverAdFormat.rewarded
                          ? LB.gold
                          : p.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        announced == GameOverAdFormat.rewarded
                            ? l10n.goAdNoticeRewarded(AdService.freeCoinsPerAd)
                            : l10n.goAdNoticeInterstitial,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.body(
                          p,
                          color: announced == GameOverAdFormat.rewarded
                              ? LB.gold
                              : p.inkMuted,
                          size: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_continueOffered)
            Row(
              children: [
                Expanded(flex: 5, child: again),
                Expanded(
                  flex: 3,
                  child: LBBlock(
                    kind: canContinue ? LBBlockKind.gold : LBBlockKind.muted,
                    height: cell * 5,
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    semanticLabel: l10n.lbGoContinue,
                    onTap: canContinue ? () => _continue(context) : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  l10n.lbGoContinue,
                                  style: LBText.button(
                                    p,
                                    color: LB.gold,
                                    size: 13,
                                  ),
                                ),
                              ),
                            ),
                            if (canContinue)
                              Text(
                                '${secsLeft.ceil()}',
                                style: LBText.value(
                                  p,
                                  color: LB.gold,
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          isPro
                              ? l10n.lbGoContinueProSub(
                                  '${widget.gameState.snake.length}',
                                )
                              : l10n.lbGoContinueSub(
                                  context.formatInt(
                                    cubit.currentReviveCoinCost,
                                  ),
                                  '${widget.gameState.snake.length}',
                                ),
                          maxLines: 3,
                          style: LBText.body(
                            p,
                            color: LB.gold.withValues(alpha: .75),
                            size: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            again,
          LBBlock(
            kind: LBBlockKind.outline,
            onTap: widget.claimable.isEmpty || widget.claimingAll
                ? null
                : widget.onClaimAll,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.lbGoEarned(context.formatInt(widget.coinsEarned)),
                        style: LBText.button(
                          p,
                          color: p.head,
                          size: 15,
                        ).copyWith(letterSpacing: 1.8),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.claimable.isEmpty
                            ? l10n.lbGoNothingToClaim
                            : l10n.lbGoRewardsLine(
                                '${widget.claimable.length}',
                                context.formatInt(claimCoins),
                                context.formatInt(claimXp),
                              ),
                        style: LBText.body(p, size: 11.5),
                      ),
                    ],
                  ),
                ),
                if (widget.claimable.isNotEmpty)
                  Text(
                    '${l10n.lbClaim} →',
                    style: LBText.button(p, color: LB.gold, size: 13),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              if (widget.doubleCoins != null)
                Expanded(
                  child: _SmallAction(
                    kind: LBBlockKind.gold,
                    icon: LBIcon.coin,
                    label: l10n.lbGoDoubleCoins,
                    onTap: widget.doubleCoins!,
                  ),
                ),
              Expanded(
                child: _SmallAction(
                  kind: LBBlockKind.outline,
                  icon: LBIcon.film,
                  label: l10n.lbGoWatchReplay,
                  onTap: () => _replay(context),
                ),
              ),
            ],
          ),
          _SmallAction(
            kind: LBBlockKind.outline,
            icon: LBIcon.back,
            label: l10n.lbHome,
            onTap: () => _home(context, announced),
            feedback: true,
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.kind,
    required this.icon,
    required this.label,
    required this.onTap,
    this.feedback = false,
  });

  final LBBlockKind kind;
  final LBIcon icon;
  final String label;
  final VoidCallback onTap;
  final bool feedback;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      height: context.lbCell * 2.8,
      alignment: Alignment.center,
      feedback: feedback,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBPixelIcon(icon, cell: 3, color: fg),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: LBText.button(
                  p,
                  color: fg,
                  size: 12.5,
                ).copyWith(letterSpacing: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
