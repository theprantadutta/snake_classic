import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/providers/walkthrough_provider.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/analytics/analytics_values.dart';
import 'package:snake_classic/services/walkthrough_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/formatting.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/widgets/ads/rewarded_action_button.dart';
import 'package:snake_classic/services/first_run_service.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/credits_dialog.dart';
import 'package:snake_classic/widgets/daily_bonus_popup.dart';
import 'package:snake_classic/widgets/first_run_legal_notice.dart';
import 'package:snake_classic/widgets/notification_permission_primer.dart';
import 'package:snake_classic/widgets/notification_permission_softask.dart';
import 'package:snake_classic/widgets/player_progression.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/widgets/home/attract_board.dart';
import 'package:snake_classic/widgets/home/home_arcade_bar.dart';
import 'package:snake_classic/widgets/home/home_arcade_widgets.dart';
import 'package:snake_classic/widgets/walkthrough/home_walkthrough.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _playButtonPulseController;
  late Animation<double> _playButtonPulseAnimation;
  bool _dailyBonusChecked = false;
  bool _walkthroughChecked = false;

  /// One-shot guard for the onboarding prompt queue. The queue is attempted
  /// from initState and re-attempted from build (see
  /// [_maybeRunOnboardingPromptQueue]); this keeps it to a single dispatch per
  /// Home instance rather than one per frame.
  bool _promptQueueDispatched = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Reduced duration
      vsync: this,
    );

    // Play button pulse animation - calm breathing
    _playButtonPulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _playButtonPulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _playButtonPulseController,
        curve: Curves.easeInOut,
      ),
    );
    _playButtonPulseController.repeat(reverse: true);

    // Theme transitions are handled by ThemeTransitionWidget directly

    // Start logo animation with a slight delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _logoController.forward();
      }
    });

    // First-launch prompts (walkthrough, daily bonus, notification
    // soft-ask/primer) used to fire on independent timers and could
    // stack on top of each other on a cold first launch. Run them
    // through a sequential queue instead — each step still self-gates
    // on whether to show at all, the queue only enforces order and
    // one-prompt-at-a-time. No-ops until the player's first game is done.
    _maybeRunOnboardingPromptQueue();

    // Home is mounted and the router is on a real route — flush any deep
    // link captured during the cold-start window (terminated-state
    // notification tap). Post-frame so the first build completes before we
    // push the target screen on top. This is what un-sticks the
    // launch-from-notification splash hang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().markAppReady();
    });
  }

  /// Runs the first-launch prompts strictly one at a time, in priority
  /// order: home walkthrough → daily bonus → notification soft-ask/primer.
  /// Each step awaits the previous prompt's dismissal before it is even
  /// considered; every step keeps its own has-shown / cadence gating, so
  /// the queue only decides ORDER, not WHETHER anything shows.
  /// Gate + one-shot dispatcher for [_runOnboardingPromptQueue].
  ///
  /// NOTHING in that queue may precede the player's first game. On a fresh
  /// install all three prompts used to fire before the snake had ever moved:
  /// a seven-step coach-mark tour of Coins / Store / Cosmetics / Battle Pass /
  /// Profile / Settings, then a daily-bonus popup, then a notification
  /// permission ask. Every one describes a metagame the player has no stake in
  /// yet, and asking for the notification permission before delivering any
  /// value is both the lowest-converting moment to ask and a bad signal to
  /// someone still deciding whether to keep the app.
  ///
  /// Called from [initState] AND from a post-frame hook in [build], because
  /// the two ways back from a game differ: "Home" on the game-over screen does
  /// a `go` (fresh Home, initState runs), while Android back pops to the
  /// existing Home instance (no initState). The build-side re-entry is what
  /// stops the back path from stranding the queue until the next cold start.
  void _maybeRunOnboardingPromptQueue() {
    if (_promptQueueDispatched) return;
    // After the three-game onboarding window, not after a single START.
    // `isFirstGame` flips the moment somebody taps Play — including a player
    // who quit two seconds in — so the whole queue could fire at a player who
    // had seen the board once. Three games is the window every other first-run
    // gate already uses, and the one FirstRunService documents.
    if (!FirstRunService().hasCompletedOnboarding) return;
    _promptQueueDispatched = true;
    unawaited(_runOnboardingPromptQueue());
  }

  Future<void> _runOnboardingPromptQueue() async {
    // Let the home screen settle (first frame + entrance animations)
    // before anything pops over it.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // 1. Home walkthrough — resolves once completed or skipped (or
    //    immediately if it was already seen).
    final tourRan = await _checkWalkthrough();
    if (!mounted) return;

    // If the player just sat through (or dismissed) the tour, that is enough
    // for one visit. A coach-mark tour followed immediately by a bonus dialog
    // followed immediately by an OS permission prompt is three interruptions
    // deep, and asking for notifications at the end of that queue is both the
    // worst-converting moment to ask and a poor thing to do to someone still
    // deciding about the app. Nothing is lost: the daily badge stays on
    // screen, and the remaining prompts self-gate and run on the next visit.
    if (tourRan) return;

    // 2. Daily bonus popup — resolves when the dialog is dismissed.
    await _checkDailyBonus();
    if (!mounted) return;

    // 3. Notification init + soft-ask → primer chain.
    await _maybeInitNotifications();
  }

  /// The notification PERMISSION ask. Handler registration is not done here —
  /// it happens unconditionally in main()'s bootstrap, because gating the
  /// onMessageOpenedApp listener behind this deferred queue silently killed
  /// notification taps for anyone who had not yet played a game.
  ///
  /// The service still needs to be up before we can ask, but by this point
  /// bootstrap has long since initialized it; the guard below only covers the
  /// case where that init failed or is still in flight.
  Future<void> _maybeInitNotifications() async {
    if (!NotificationService().initialized) {
      // Bootstrap's init failed or hasn't landed. Try once more — without the
      // OS prompt, which the soft-ask below owns.
      try {
        await NotificationService().initialize(requestPermission: false);
      } catch (e) {
        AppLogger.error('Notification service init failed', e);
        return;
      }
      if (!mounted) return;
    }
    await _maybeShowNotificationSoftAsk();
  }

  /// First-run: show the pre-permission soft-ask (self-gates to once ever).
  /// Whatever the user chooses, then hand off to the recurring re-ask primer
  /// (which self-gates on its own 7-day cadence, so no double dialog).
  /// maybeShow awaits both its dialog and the OS prompt flow, so the primer
  /// can't stack on top of either.
  Future<void> _maybeShowNotificationSoftAsk() async {
    if (!mounted) return;
    final theme = context.read<ThemeCubit>().state.currentTheme;
    await NotificationPermissionSoftAsk.maybeShow(context, theme);
    if (!mounted) return;
    await _maybeShowNotificationPrimer();
  }

  /// Recurring "turn notifications on" nudge for users who denied/missed
  /// the OS prompt — they're token-registered on the backend but every
  /// push to them displays nothing. Primer self-gates (Android-only,
  /// notifications off, ≥7 days since last ask), so calling it freely
  /// from here is safe.
  Future<void> _maybeShowNotificationPrimer() async {
    if (!mounted) return;
    final theme = context.read<ThemeCubit>().state.currentTheme;
    await NotificationPermissionPrimer.maybeShow(context, theme);
  }

  /// Shows the first-launch game-mode picker if it hasn't been shown
  /// before. Returns once the sheet is dismissed (or immediately if the
  /// user has already seen it). Triggered from the Play button so it
  /// only appears in the path where the choice actually matters.
  Future<void> _maybeShowGameModePrompt() async {
    if (!mounted) return;
    final settingsCubit = context.read<GameSettingsCubit>();

    // Read the flag with a short hydration window. If the cubit is
    // already ready (overwhelmingly the case by the time the user taps
    // Play), this returns immediately. Falls back to direct storage on
    // a timeout so we never nag a user who already chose.
    bool alreadyPrompted;
    if (settingsCubit.state.isReady) {
      alreadyPrompted = settingsCubit.state.gameModeFirstLaunchPrompted;
    } else {
      try {
        final ready = await settingsCubit.stream
            .firstWhere((s) => s.isReady)
            .timeout(const Duration(seconds: 2));
        alreadyPrompted = ready.gameModeFirstLaunchPrompted;
      } catch (_) {
        alreadyPrompted = await getIt<StorageService>()
            .hasGameModeBeenPrompted();
      }
    }

    if (!mounted) return;
    if (alreadyPrompted) return;

    final selected = await showModalBottomSheet<GameMode>(
      context: context,
      // Dismissible: a player who taps Play wants to play, and trapping them
      // in a modal until they commit to a mode they have not tried yet is
      // friction with no upside. Dismissing keeps their current mode (the
      // `selected == null` path below) and still marks the picker as shown,
      // so it asks once and never nags.
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Cap width so the sheet centers on tablets instead of spanning the
      // full width (no-op on phones narrower than 640).
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) =>
          _GameModeFirstLaunchSheet(initialMode: settingsCubit.state.gameMode),
    );

    if (!mounted) return;
    if (selected != null) {
      await settingsCubit.setGameMode(selected);
    }
    await settingsCubit.markGameModePrompted();
  }

  /// Check if home walkthrough should be shown. Resolves once the
  /// walkthrough is completed or skipped (or immediately if it doesn't
  /// need to run), so later onboarding prompts can queue behind it.
  Future<bool> _checkWalkthrough() async {
    if (_walkthroughChecked) return false;

    _walkthroughChecked = true;

    final walkthroughNotifier = ref.read(walkthroughProvider.notifier);
    final isComplete = await walkthroughNotifier.isWalkthroughComplete(
      WalkthroughService.homeWalkthroughId,
    );

    if (!isComplete && mounted) {
      getIt<AnalyticsFacade>().trackHomeTourStarted(version: kHomeTourVersion);
      final done = Completer<void>();
      await walkthroughNotifier.start(
        walkthroughId: WalkthroughService.homeWalkthroughId,
        steps: HomeWalkthrough.getSteps(AppLocalizations.of(context)!),
        onComplete: (outcome) {
          // `tutorial_complete` had never fired in production: the facade
          // method existed but nothing called it, so GA4 showed 3.5k
          // tutorial_begin against zero completions and we could not tell
          // abandonment from a missing event. Fires on both the finished and
          // skipped paths — walkthroughNotifier resolves onComplete for
          // either, which is the honest signal ("the walkthrough is no longer
          // in the player's way"), and the two are separable by whether the
          // user reached the last step in the walkthrough state.
          if (!done.isCompleted) {
            final analytics = getIt<AnalyticsFacade>();
            switch (outcome) {
              case WalkthroughOutcome.finished:
                analytics.trackHomeTourFinished(version: kHomeTourVersion);
              case WalkthroughOutcome.skipped:
                analytics.trackHomeTourSkipped(version: kHomeTourVersion);
            }
            done.complete();
          }
        },
      );
      if (!mounted) return false;
      // start() no-ops if the walkthrough raced to a completed state,
      // in which case onComplete never fires — don't hang the queue.
      final started = ref.read(walkthroughProvider).isActive;
      if (!started && !done.isCompleted) {
        done.complete();
      }
      await done.future;
      return started;
    }
    return false;
  }

  /// Check and show daily bonus popup if available.
  /// Offline-first: reads CoinsCubit's local state. No network call.
  Future<void> _checkDailyBonus() async {
    if (_dailyBonusChecked) return;
    _dailyBonusChecked = true;

    if (!mounted) return;

    // Wait for CoinsCubit to have read Drift before trusting its answer.
    //
    // This gate asks "was the bonus already claimed today?", and the answer
    // lives in state.dailyBonusLastClaimUtcMs, which is null until
    // _loadFromDrift lands. The cubit is created with a fire-and-forget
    // `..initialize()` in main.dart, and on a cold start that can finish
    // well AFTER this queue runs — measured at 14s on a device where the
    // backend was timing out, against a popup that fires ~700ms after home
    // settles. So the gate read "never claimed" for a player who had
    // claimed hours earlier, and the popup came back every single launch.
    //
    // The claim itself was never actually granted twice — StoreDao's
    // transaction refuses a second claim in the same local day, and the coin
    // ledger confirms one grant. But the popup closed on tap either way, so
    // it looked exactly like a successful claim, every time.
    //
    // initialize() coalesces onto the in-flight future and returns
    // immediately once ready, so this is a no-op on a warm start.
    final coinsCubit = context.read<CoinsCubit>();
    await coinsCubit.initialize();
    if (!mounted) return;

    // Frontend gate: already claimed today, skip everything
    if (coinsCubit.wasDailyBonusClaimedToday) return;

    try {
      DailyBonusStatus? status;

      if (coinsCubit.state.canCollectDailyBonus) {
        final localBonus = coinsCubit.state.availableDailyBonus;
        if (localBonus != null) {
          status = DailyBonusStatus(
            canClaim: true,
            currentStreak: localBonus.day,
            todayReward: DailyBonusReward(
              day: localBonus.day,
              coins: localBonus.coins,
              bonusItem: localBonus.bonusItem,
            ),
            weekRewards: coinsCubit.state.dailyBonuses
                .map(
                  (b) => DailyBonusReward(
                    day: b.day,
                    coins: b.coins,
                    bonusItem: b.bonusItem,
                    claimed: b.isCollected,
                  ),
                )
                .toList(),
          );
        }
      }

      if (status == null || !status.canClaim || !mounted) return;

      final theme = context.read<ThemeCubit>().state.currentTheme;

      // Offer a "claim 2×" via rewarded ad when one is available (free users).
      final bonusCoins = status.todayReward?.coins ?? 0;
      final ads = getIt.isRegistered<AdService>() ? getIt<AdService>() : null;
      final canDouble = ads != null && ads.adsEnabled && ads.isRewardedReady;

      await DailyBonusPopup.show(
        context: context,
        theme: theme,
        status: status,
        onClaim: () async {
          if (!mounted) return false;
          // Capture before the await — the popup pops on return, so reading
          // context afterwards is unsafe.
          final messenger = ScaffoldMessenger.of(context);
          final claimL10n = AppLocalizations.of(context)!;
          final success = await context.read<CoinsCubit>().collectDailyBonus();
          if (success) {
            getIt<AnalyticsFacade>().trackDailyBonusCollected();
          } else {
            // The Drift gate refused — the bonus was already claimed today
            // and no coins were granted. Say so. The popup closes on tap
            // either way, so without this the refusal was invisible and a
            // failed claim was indistinguishable from a paid one.
            messenger.showSnackBar(
              SnackBar(
                content: Text(claimL10n.dbAlreadyClaimed),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return success;
        },
        onClaimDoubled: canDouble
            ? () async {
                if (!mounted) return;
                final coins = context.read<CoinsCubit>();
                // Capture before the ad — onReward fires after dismissal,
                // an async gap where reading context is unsafe.
                final messenger = ScaffoldMessenger.of(context);
                final l10n = AppLocalizations.of(context)!;
                final ok = await coins.collectDailyBonus();
                if (!ok) return;
                getIt<AnalyticsFacade>().trackDailyBonusCollected();
                // Grant the same amount again on ad completion → 2× total.
                await ads.showRewarded(
                  placement: 'daily_bonus_2x',
                  onReward: () {
                    coins.earnCoins(
                      CoinEarningSource.dailyLogin,
                      customAmount: bonusCoins,
                      itemName: 'Daily bonus 2x',
                    );
                    showRewardToast(
                      messenger,
                      l10n.homeBonusDoubled(bonusCoins),
                    );
                  },
                );
              }
            : null,
      );
    } catch (e) {
      AppLogger.error('Error checking daily bonus', e);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _playButtonPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walkthroughState = ref.watch(walkthroughProvider);

    // Re-entry for the deferred onboarding prompts: this Home instance may
    // have been created before the player's first game, in which case
    // initState's attempt no-opped. Returning here by Android back reuses that
    // instance, so build is the only hook left. Self-guarded — after the first
    // successful dispatch this is a single bool read per frame.
    if (!_promptQueueDispatched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeRunOnboardingPromptQueue();
      });
    }

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<GameCubit, GameCubitState>(
              builder: (context, gameState) {
                return Stack(
                  children: [
                    ThemeTransitionWidget(
                      controller: ThemeTransitionController(vsync: this),
                      currentTheme: theme,
                      child: Scaffold(
                        // The legal strip rides above the banner ad rather
                        // than inside the scrolling body: it must stay visible
                        // without the user hunting for it, and anchoring it
                        // here keeps it out of the height math the play area
                        // and nav grid do against `constraints`. Renders
                        // nothing once acceptance is on file.
                        bottomNavigationBar: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FirstRunLegalNotice(theme: theme),
                            const SnakeBannerAd(),
                          ],
                        ),
                        body: AppBackground(
                          theme: theme,
                          child: SafeArea(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final screenHeight = constraints.maxHeight;

                                // Cap the home hub's content width on tablets
                                // so it forms a centered column instead of
                                // stretching edge-to-edge. Unbounded on phones,
                                // so all the screenWidth-based math below is
                                // unchanged there.
                                final maxContentWidth = context
                                    .responsive<double>(
                                      phone: double.infinity,
                                      tablet: ContentWidth.menuMaxWidth,
                                      largeTablet: ContentWidth.menuMaxWidth,
                                    );
                                final screenWidth =
                                    constraints.maxWidth > maxContentWidth
                                    ? maxContentWidth
                                    : constraints.maxWidth;

                                // Enhanced screen size detection with more granular breakpoints
                                final isVerySmallScreen =
                                    screenHeight < 600 || screenWidth < 350;

                                // Use a simple Column with proper constraints for better stability
                                return _buildArcadeBody(
                                  context: context,
                                  authState: authState,
                                  theme: theme,
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  isVerySmallScreen: isVerySmallScreen,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Walkthrough overlay
                    if (walkthroughState.isActive &&
                        walkthroughState.currentStep != null)
                      WalkthroughOverlay(
                        step: walkthroughState.currentStep!,
                        theme: theme,
                        currentStepIndex: walkthroughState.currentStepIndex,
                        totalSteps: walkthroughState.steps.length,
                        onNext: () =>
                            ref.read(walkthroughProvider.notifier).next(),
                        onSkip: () =>
                            ref.read(walkthroughProvider.notifier).skip(),
                      ),

                    // Sync restore overlay is mounted globally in
                    // SnakeClassicApp.builder so it appears regardless
                    // of which screen is active during the pull.
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// The arcade home: a live board you tap to play, two rails of context, and
  /// four destinations across the bottom.
  ///
  /// The old hub was a stack of five bands — title, hero button, versus pill,
  /// three action buttons, eight nav tiles — each competing for the same eye.
  /// This borrows the shape the endless runners settled on, because it solves
  /// exactly that: the middle of the screen IS the game and IS the button, the
  /// things you might want are pinned to the edges where they can be ignored,
  /// and the four destinations worth a permanent slot sit under the thumb.
  Widget _buildArcadeBody({
    required BuildContext context,
    required AuthState authState,
    required GameTheme theme,
    required double screenWidth,
    required double screenHeight,
    required bool isVerySmallScreen,
  }) {
    final horizontal = screenWidth * 0.04;

    return Center(
      child: SizedBox(
        width: screenWidth,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: isVerySmallScreen ? 4 : 8,
              ),
              child: _buildTopNavigation(
                context,
                authState,
                theme,
                isVerySmallScreen,
              ),
            ),

            // Everything between the bars is one tap target.
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: _buildArcadeStage(context, theme, isVerySmallScreen),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                isVerySmallScreen ? 4 : 8,
                horizontal,
                isVerySmallScreen ? 6 : 10,
              ),
              child: HomeArcadeBar(
                theme: theme,
                compact: isVerySmallScreen,
                destinations: _arcadeDestinations(context, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The stage: demo board at the back, the tap layer over it, rails on top.
  ///
  /// Order matters for hit testing — Stack tests its children back to front,
  /// so the rails and their buttons take a tap before the play layer sees it.
  Widget _buildArcadeStage(
    BuildContext context,
    GameTheme theme,
    bool isCompact,
  ) {
    return Stack(
      children: [
        Positioned.fill(child: AttractBoard(theme: theme)),
        Positioned.fill(child: _buildTapToPlay(context, theme, isCompact)),
        Positioned(
          left: 0,
          top: 0,
          child: _buildLeftRail(context, theme, isCompact),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: _buildRightRail(context, theme, isCompact),
        ),
      ],
    );
  }

  /// The whole middle, and the only thing on this screen that starts a game.
  ///
  /// There is no button because there does not need to be one: a player who
  /// opens a game wants to play it, and asking them to find a 300px circle
  /// first is ceremony. The caption is the affordance; the target is the
  /// screen.
  Widget _buildTapToPlay(
    BuildContext context,
    GameTheme theme,
    bool isCompact,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // The middle of this screen is mostly air, so the brand takes it. The
    // logo and wordmark are the only things up here competing for attention
    // and they are supposed to win.
    final logoSize = isCompact ? 132.0 : 196.0;

    return Semantics(
      button: true,
      label: l10n.homePlay,
      onTap: () => _startGame(context),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _startGame(context),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Weighted rather than equal: the brand block sits below the
            // optical centre, which leaves the rails at the top their own
            // clear band and drops the logo nearer the thumb.
            const Spacer(flex: 5),
            ScaleTransition(
              scale: _playButtonPulseAnimation,
              child:
                  Image.asset(
                        'assets/images/snake_classic_transparent.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.games,
                          size: logoSize * 0.5,
                          color: theme.accentColor,
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .shimmer(
                        duration: 2500.ms,
                        color: theme.accentColor.withValues(alpha: 0.25),
                      ),
            ),
            SizedBox(height: isCompact ? 6 : 10),
            // Scales down rather than clipping when a locale spells the
            // title long or the screen is narrow — softWrap is off so the
            // lines stay exactly two.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.primaryColor, theme.accentColor],
                ).createShader(bounds),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final line in _appTitleLines(l10n))
                      Text(
                        line,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isCompact ? 38 : 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // base for ShaderMask
                          height: 1.02,
                          letterSpacing: context.letterSpacing(1.5),
                          shadows: [
                            Shadow(
                              color: theme.accentColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
            // The armed power-up, still the last thing seen before the tap.
            _buildPowerUpLoadoutChip(theme),
            SizedBox(height: isCompact ? 6 : 10),
            // The caption breathes so it reads as an invitation rather than a
            // label, and sits low where a thumb already is.
            Padding(
              padding: EdgeInsets.only(bottom: isCompact ? 10 : 18),
              child:
                  Text(
                        l10n.homeTapToPlay.toUpperCase(),
                        style: TextStyle(
                          // The theme's own accent, not white — it is the
                          // game's voice asking, and every other piece of
                          // type on this screen already speaks in it.
                          color: theme.accentColor,
                          fontSize: isCompact ? 16 : 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: context.letterSpacing(3),
                          shadows: [
                            // A dark shadow for legibility over the board,
                            // and a little of the accent bleeding out so it
                            // glows rather than sits.
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                            Shadow(
                              color: theme.accentColor.withValues(alpha: 0.45),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .fadeIn(duration: 900.ms)
                      .then()
                      // Floor raised from 0.45: white survived that, but the
                      // accent is green on a green board and disappeared at
                      // the bottom of the pulse.
                      .fade(end: 0.72, duration: 900.ms),
            ),
          ],
        ),
      ),
    );
  }

  /// Left rail: who you are and what you have done.
  Widget _buildLeftRail(BuildContext context, GameTheme theme, bool isCompact) {
    final l10n = AppLocalizations.of(context)!;
    final highScore = context.watch<GameSettingsCubit>().state.highScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeStatPanel(
          theme: theme,
          icon: Icons.emoji_events,
          iconColor: const Color(0xFFFFC53D),
          label: l10n.homeHighScore,
          value: context.formatInt(highScore),
          compact: isCompact,
          onTap: () => context.push(AppRoutes.statistics),
        ),
        SizedBox(height: isCompact ? 6 : 8),
        BlocBuilder<CoinsCubit, CoinsState>(
          builder: (context, coinsState) => HomeStatPanel(
            theme: theme,
            icon: Icons.monetization_on,
            iconColor: Colors.amber,
            // The balance, labelled as the balance. It read "STORE 0" before,
            // which says the store is empty rather than the wallet is.
            label: l10n.storeTabCoins,
            value: context.formatCompact(coinsState.total),
            compact: isCompact,
            onTap: () => context.push(AppRoutes.store),
          ),
        ),
        SizedBox(height: isCompact ? 6 : 8),
        // Two readouts, then two places to go. Both are about you rather than
        // about the game, which is why they are on this side and the offers
        // are on the other.
        HomeRailButton(
          theme: theme,
          icon: Icons.people_alt_outlined,
          label: l10n.homeTileFriends,
          onTap: () => context.push(AppRoutes.friends),
        ),
        SizedBox(height: isCompact ? 6 : 8),
        HomeRailButton(
          theme: theme,
          icon: Icons.military_tech_outlined,
          label: l10n.homeTileAwards,
          onTap: () => context.push(AppRoutes.achievements),
        ),
      ],
    );
  }

  /// Right rail: what is waiting for you.
  Widget _buildRightRail(
    BuildContext context,
    GameTheme theme,
    bool isCompact,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final adsOn =
        getIt.isRegistered<AdService>() && getIt<AdService>().adsEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        HomeRailButton(
          theme: theme,
          icon: Icons.timeline_rounded,
          label: l10n.homeTileBattle,
          onTap: () => context.push(AppRoutes.battlePass),
        ),
        SizedBox(height: isCompact ? 6 : 8),
        HomeRailButton(
          theme: theme,
          icon: Icons.emoji_events_outlined,
          label: l10n.homeTileEvents,
          tint: Colors.deepOrange,
          onTap: () => context.push(AppRoutes.tournaments),
        ),
        SizedBox(height: isCompact ? 6 : 8),
        // Versus gets a rail slot as well as its bottom-bar destination. Two
        // ways in is not clutter for the one mode nobody discovers on their
        // own — it was the eighth tile of a nav grid for most of this app's
        // life — and the subtitle says what it actually is.
        HomeRailButton(
          theme: theme,
          icon: Icons.sports_esports,
          label: l10n.homeTileVersus,
          subtitle: l10n.insVersusOnline,
          onTap: () => _openVersusLobby(context),
        ),
        // The free reward sits at the bottom of the rail, nearest the thumb.
        if (adsOn) ...[
          SizedBox(height: isCompact ? 6 : 8),
          HomeRailButton(
            theme: theme,
            icon: Icons.bolt,
            label: l10n.homeTileFree,
            tint: const Color(0xFF2FBF71),
            highlight: true,
            onTap: () => _watchForFreePowerUp(context),
          ),
        ],
      ],
    );
  }

  /// The four that earn a permanent slot.
  ///
  /// Missions carries the badge because it is the only one with something
  /// waiting in it — an unclaimed daily reward is the reason to come back
  /// tomorrow, and a number on a button is how that gets noticed.
  List<ArcadeDestination> _arcadeDestinations(
    BuildContext context,
    GameTheme theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return [
      ArcadeDestination(
        icon: Icons.checklist_rounded,
        label: l10n.homeTileDaily,
        badgeCount: _getDailyChallengesBadge() ?? 0,
        widgetKey: HomeWalkthrough.dailyChallengesKey,
        onTap: () => context.push(AppRoutes.dailyChallenges),
      ),
      // Profile is not homeless: the avatar in the top bar has always opened
      // it, and it is the more natural place to tap your own face. The slot
      // goes to the leaderboard, which had no entry point at all once the
      // eight-tile grid went.
      ArcadeDestination(
        icon: Icons.leaderboard_rounded,
        label: l10n.homeTileBoard,
        onTap: () => context.push(AppRoutes.leaderboard),
      ),
      ArcadeDestination(
        icon: Icons.store_rounded,
        label: l10n.homeTileStore,
        widgetKey: HomeWalkthrough.storeKey,
        onTap: () => context.push(AppRoutes.store),
      ),
      ArcadeDestination(
        icon: Icons.sports_esports_rounded,
        label: l10n.homeTileVersus,
        widgetKey: HomeWalkthrough.versusKey,
        onTap: () => _openVersusLobby(context),
      ),
    ];
  }

  /// Open the lobby, and say where the player came from.
  ///
  /// The entry point is the measurement the Versus button exists for: whether
  /// it is what brings people to multiplayer.
  void _openVersusLobby(BuildContext context) {
    final analytics = getIt<AnalyticsFacade>();
    analytics.trackHomeVersusCtaTapped(
      onboardingStage: FirstRunService().hasCompletedOnboarding
          ? OnboardingStage.established
          : OnboardingStage.onboarding,
    );
    analytics.trackMultiplayerLobbyOpened(
      entryPoint: LobbyEntryPoint.homeVersus,
    );
    context.push(AppRoutes.multiplayerLobby);
  }

  /// Start a game — the one action the middle of this screen performs.
  ///
  /// Same path the old hero button took, including the first-run skip of the
  /// mode picker: a player who has never seen the board cannot choose between
  /// Classic, Zen, Survival and Time Attack, so they get Classic and the
  /// picker on their second tap.
  Future<void> _startGame(BuildContext context) async {
    unawaited(LegalAcceptance.recordAccepted());
    HapticService().mediumImpact();

    if (!FirstRunService().isFirstGame) {
      await _maybeShowGameModePrompt();
      if (!context.mounted) return;
    }
    context.push(AppRoutes.playLoading);
  }

  Widget _buildTopNavigation(
    BuildContext context,
    AuthState authState,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        // Left: player identity (profile) + About — two tools, mirroring the
        // settings + how-to-play pair on the right.
        PlayerIdentityBadge(
          key: HomeWalkthrough.profileKey,
          theme: theme,
          isSmallScreen: isSmallScreen,
          photoUrl: authState.isSignedIn ? authState.photoURL : null,
          onTap: () => context.push(AppRoutes.profile),
        ),

        SizedBox(width: isSmallScreen ? 8 : 12),

        // About & credits (app version, credits, links).
        GestureDetector(
          onTap: () => showCreditsDialog(context, theme),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.info_outline,
              color: theme.accentColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ),

        // Center: coins pill → store.
        Expanded(
          child: Center(
            child: BlocBuilder<CoinsCubit, CoinsState>(
              builder: (context, coinsState) {
                return GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.store);
                  },
                  child: Container(
                    key: HomeWalkthrough.coinsKey,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 14,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withValues(alpha: 0.15),
                          Colors.orange.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        isSmallScreen ? 16 : 20,
                      ),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: isSmallScreen ? 18 : 22,
                        ),
                        SizedBox(width: isSmallScreen ? 4 : 6),
                        Text(
                          context.formatCompact(coinsState.total),
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Right: tools — settings + how-to-play.
        Row(
          children: [
            // Settings
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.settings);
              },
              child: Container(
                key: HomeWalkthrough.settingsKey,
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: theme.accentColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ),

            SizedBox(width: isSmallScreen ? 8 : 12),

            // How to play
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.instructions);
              },
              child: Container(
                key: HomeWalkthrough.helpKey,
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: theme.foodColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  border: Border.all(
                    color: theme.foodColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: theme.foodColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// "Snake" over "Classic".
  ///
  /// Split on whitespace, so a locale that writes the title as a single word
  /// keeps it on one line rather than being broken at an arbitrary point.
  List<String> _appTitleLines(AppLocalizations l10n) {
    final title = l10n.appTitle.trim();
    final words = title.split(RegExp(r'\s+'));
    if (words.length < 2) return [title];
    if (words.length == 2) return words;
    return [words.first, words.skip(1).join(' ')];
  }

  Widget _buildPowerUpLoadoutChip(GameTheme theme) {
    return BlocBuilder<PowerUpCubit, PowerUpState>(
      builder: (context, powerUpState) {
        // Hide entirely when the user has no inventory — keeps the home
        // screen uncluttered for free users / users who haven't bought
        // power-ups yet.
        if (powerUpState.totalOwned == 0) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context)!;
        final armed = powerUpState.armed;
        final armedLabel = armed == null
            ? null
            : _loadoutLabelFor(context, armed);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _openLoadoutSheet(theme, powerUpState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: armed != null
                    ? theme.accentColor.withValues(alpha: 0.18)
                    : theme.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: armed != null
                      ? theme.accentColor
                      : theme.accentColor.withValues(alpha: 0.25),
                  width: armed != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    armed != null ? Icons.flash_on : Icons.flash_on_outlined,
                    color: armed != null ? Colors.amber : theme.accentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    armed != null
                        ? l10n.homeArmedPowerUp(armedLabel!)
                        : l10n.homeLoadoutCount(powerUpState.totalOwned),
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.accentColor.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _loadoutLabelFor(BuildContext context, String inventoryKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (inventoryKey) {
      case 'speed_boost':
        return l10n.puSpeedBoost;
      case 'invincibility':
        return l10n.puInvincibility;
      case 'score_multiplier':
        return l10n.puScoreMultiplier;
      case 'slow_motion':
        return l10n.puSlowMotion;
      default:
        return inventoryKey;
    }
  }

  IconData _loadoutIconFor(String inventoryKey) {
    switch (inventoryKey) {
      case 'speed_boost':
        return Icons.speed;
      case 'invincibility':
        return Icons.shield;
      case 'score_multiplier':
        return Icons.star;
      case 'slow_motion':
        return Icons.slow_motion_video;
      default:
        return Icons.flash_on;
    }
  }

  void _openLoadoutSheet(GameTheme theme, PowerUpState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // Cap width so the sheet centers on tablets (no-op on phones).
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) {
        return _LoadoutBottomSheet(
          theme: theme,
          labelFor: _loadoutLabelFor,
          iconFor: _loadoutIconFor,
        );
      },
    );
  }

  /// Opt-in rewarded watch from the home action row. Tells the user up front
  /// exactly what they'll get (a free Speed Boost power-up), then confirms the
  /// grant with a toast. Grants no coins, so the economy stays safe. Opt-in and
  /// uncapped — only gated on a loaded ad.
  Future<void> _watchForFreePowerUp(BuildContext context) async {
    final ads = getIt<AdService>();
    final messenger = ScaffoldMessenger.of(context);
    final powerUps = context.read<PowerUpCubit>();
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final l10n = AppLocalizations.of(context)!;

    // No ad loaded → explain why, don't just do nothing.
    if (!ads.canShowCapped(AdService.capFreePowerUp)) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Text(l10n.homeNoAdReady),
        ),
      );
      return;
    }

    // Tell the user what they're opting into BEFORE the ad plays.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            Icon(Icons.bolt, color: theme.foodColor),
            const SizedBox(width: 8),
            Text(
              l10n.homeFreeSpeedBoostTitle,
              style: TextStyle(color: theme.primaryColor),
            ),
          ],
        ),
        content: Text(
          l10n.homeFreeSpeedBoostBody,
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.85)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.homeNotNow,
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: theme.accentColor),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text(l10n.homeWatchAd),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final granted = await ads.showRewardedCapped(
      capKey: AdService.capFreePowerUp,
      onReward: powerUps.grantFreePowerUp,
    );

    // Confirm the reward (fires after the ad is dismissed). If the user closed
    // the ad early, tell them no reward was given rather than leaving them
    // guessing.
    if (granted) {
      showRewardToast(
        messenger,
        l10n.homeFreeSpeedBoostAdded,
        icon: Icons.bolt,
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Text(l10n.homeAdNotFinished),
        ),
      );
    }
  }

  int? _getDailyChallengesBadge() {
    final count = ref.watch(unclaimedRewardsCountProvider);
    return count > 0 ? count : null;
  }
}

class _GameModeFirstLaunchSheet extends StatefulWidget {
  const _GameModeFirstLaunchSheet({required this.initialMode});

  final GameMode initialMode;

  @override
  State<_GameModeFirstLaunchSheet> createState() =>
      _GameModeFirstLaunchSheetState();
}

class _GameModeFirstLaunchSheetState extends State<_GameModeFirstLaunchSheet> {
  late GameMode _selected = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.backgroundColor.withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.homePickGameMode,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: context.letterSpacing(1.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homePickGameModeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ...GameMode.values.map((mode) {
              final isSelected = _selected == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selected = mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.accentColor.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: isSelected
                            ? theme.accentColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(mode.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.localizedName(l10n),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mode.localizedDescription(l10n),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: theme.accentColor,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: theme.backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text(
                  l10n.homeStartPlaying,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: context.letterSpacing(1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-game power-up loadout sheet. Lists every type the user owns,
/// highlights the currently armed one, and lets them switch / unarm.
/// Closing the sheet without picking leaves the previous selection
/// intact — the sheet is a passive viewer/editor, not a wizard.
class _LoadoutBottomSheet extends StatelessWidget {
  final GameTheme theme;
  final String Function(BuildContext context, String key) labelFor;
  final IconData Function(String key) iconFor;

  const _LoadoutBottomSheet({
    required this.theme,
    required this.labelFor,
    required this.iconFor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerUpCubit, PowerUpState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final entries = state.inventory.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.flash_on, color: theme.accentColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      l10n.homeLoadoutTitle,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeLoadoutSubtitle,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                // Rewarded — grab a free Speed Boost without spending coins.
                RewardedActionButton(
                  theme: theme,
                  icon: Icons.bolt,
                  label: l10n.homeWatchAdFreeSpeedBoost,
                  capKey: AdService.capFreePowerUp,
                  onWatch: () async {
                    final powerUps = context.read<PowerUpCubit>();
                    // Capture before the ad — onReward fires after dismissal,
                    // an async gap where reading context is unsafe.
                    final messenger = ScaffoldMessenger.of(context);
                    await getIt<AdService>().showRewardedCapped(
                      capKey: AdService.capFreePowerUp,
                      onReward: () {
                        powerUps.grantFreePowerUp();
                        showRewardToast(
                          messenger,
                          '🎉 ${l10n.homeFreeSpeedBoostAdded}',
                          icon: Icons.flash_on,
                        );
                      },
                    );
                  },
                ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        l10n.homeNoPowerUps,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                else
                  ...entries.map((e) {
                    final key = e.key;
                    final count = e.value;
                    final isArmed = state.armed == key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (isArmed) {
                            context.read<PowerUpCubit>().unarm();
                          } else {
                            context.read<PowerUpCubit>().arm(key);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isArmed
                                ? theme.accentColor.withValues(alpha: 0.20)
                                : Colors.white.withValues(alpha: 0.04),
                            border: Border.all(
                              color: isArmed
                                  ? theme.accentColor
                                  : Colors.white.withValues(alpha: 0.10),
                              width: isArmed ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.accentColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconFor(key),
                                  color: theme.accentColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      labelFor(context, key),
                                      style: TextStyle(
                                        color: theme.accentColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      l10n.homeOwnedCount(count),
                                      style: TextStyle(
                                        color: theme.accentColor.withValues(
                                          alpha: 0.65,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isArmed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.accentColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    l10n.homeArmed,
                                    style: TextStyle(
                                      color: theme.backgroundColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.add_circle_outline,
                                  color: theme.accentColor.withValues(
                                    alpha: 0.7,
                                  ),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: theme.backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.homeDone,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: context.letterSpacing(1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
