import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/widgets/design_feedback_sheet.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/home/lb_home_snake.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/leaderboard_service.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/data/daos/leaderboard_dao.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/providers/walkthrough_provider.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/analytics/analytics_values.dart';
import 'package:snake_classic/services/walkthrough_service.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/widgets/app_update_dialog.dart';
import 'package:snake_classic/widgets/game_mode_picker_sheet.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/services/first_run_service.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';
import 'package:snake_classic/widgets/credits_dialog.dart';
import 'package:snake_classic/widgets/daily_bonus_popup.dart';
import 'package:snake_classic/widgets/first_run_legal_notice.dart';
import 'package:snake_classic/widgets/notification_permission_primer.dart';
import 'package:snake_classic/widgets/notification_permission_softask.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/widgets/walkthrough/home_walkthrough.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_overlay.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/services/in_app_update_service.dart';
import 'package:snake_classic/services/app_release_policy.dart';
import 'package:snake_classic/services/app_release_service.dart';
import 'package:snake_classic/widgets/update_ready_notice.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      // Play update check: once per session, after first frame, so it
      // never competes with the bootstrap. Flexible by default — the
      // download runs while they play and the strip below the rail
      // offers the restart when it lands.
      unawaited(InAppUpdateService().checkForUpdate());
      // The iOS half of the same job. The App Store has no in-app update
      // API, so the version to compare against comes from our backend and
      // the outcome is a dialog rather than a Play-owned download. Runs on
      // Android too and returns immediately there.
      unawaited(_checkIosAppRelease());
      unawaited(_loadHomeReadouts());
      _maybeOpenDebugRoute();
    });
  }

  /// Debug builds only: `--dart-define=LB_DEBUG_ROUTE=/settings` opens that
  /// route once Home is up, so a screen can be checked on a device without
  /// walking to it. Fires once per process.
  static bool _debugRouteOpened = false;
  void _maybeOpenDebugRoute() {
    const route = String.fromEnvironment('LB_DEBUG_ROUTE');
    if (!kDebugMode || route.isEmpty || _debugRouteOpened) return;
    _debugRouteOpened = true;
    context.push(route);
  }

  /// Ask the backend whether this iOS build is behind the store, and show
  /// the matching dialog. No-ops on Android, in debug, after the first
  /// check of the session, and whenever anything at all is unclear — see
  /// [AppReleasePolicy].
  Future<void> _checkIosAppRelease() async {
    final prompt = await AppReleaseService().check();
    if (prompt == UpdatePrompt.none) return;
    if (!mounted) return;
    await showAppUpdateDialog(context, prompt);
  }

  /// Runs the first-launch prompts strictly one at a time, in priority
  /// order: home walkthrough → daily bonus → design feedback → notification
  /// soft-ask/primer.
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

    // 3. "How's the game feeling?" — once, after five finished runs and two
    //    days installed (DesignFeedbackPolicy). Home rather than game over,
    //    so it can never land on a run or on top of its rewards. When it
    //    shows, that is the visit's interruption: the notification ask
    //    self-gates and waits for the next one.
    if (await maybeShowDesignFeedback(context)) return;
    if (!mounted) return;

    // 4. Notification init + soft-ask → primer chain.
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

  /// Fallback entry point for the mode picker.
  ///
  /// The picker's real home is the first game-over (see
  /// [maybeShowGameModePicker]) — that reaches every player who finishes a
  /// game, not just the minority who return for a second one. This call keeps
  /// the Play button as a safety net for anyone who somehow gets past a game
  /// without passing through game-over. It is a no-op once the picker has been
  /// shown, so the two paths cannot double-prompt.
  Future<void> _maybeShowGameModePrompt() async {
    if (!mounted) return;
    await maybeShowGameModePicker(context);
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
                    // From the streak, like the reward itself: the stored
                    // per-day flag outlives a broken streak, which drew D1
                    // as claimed on the very day D1 was being offered.
                    claimed: b.day < localBonus.day,
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
          final snackTheme = context.read<ThemeCubit>().state.currentTheme;
          final success = await context.read<CoinsCubit>().collectDailyBonus();
          if (success) {
            getIt<AnalyticsFacade>().trackDailyBonusCollected();
          } else {
            // The Drift gate refused — the bonus was already claimed today
            // and no coins were granted. Say so. The popup closes on tap
            // either way, so without this the refusal was invisible and a
            // failed claim was indistinguishable from a paid one.
            messenger.showSnackBar(
              arcadeSnackBarFor(
                snackTheme,
                message: claimL10n.dbAlreadyClaimed,
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

  /// Global rank from the Drift leaderboard cache (offline-first; refreshed
  /// by the leaderboard screen and sync). Null until a ranked run is cached.
  int? _globalRank;

  /// Versus rating, fetched once per session; null = unknown/offline.
  static int? _versusRating;
  static bool _versusRatingRequested = false;

  Future<void> _loadHomeReadouts() async {
    try {
      final info = await LeaderboardService().getCacheInfo(
        LeaderboardBoardType.global,
      );
      final rank = info?['currentUserRank'] as int?;
      if (mounted && rank != _globalRank) setState(() => _globalRank = rank);
    } catch (e) {
      AppLogger.warning('Home rank readout unavailable: $e');
    }
    if (_versusRatingRequested) return;
    _versusRatingRequested = true;
    try {
      final record = await ApiService().getMultiplayerRecord();
      final rating = (record?['rating'] as num?)?.toInt();
      if (rating != null) {
        _versusRating = rating;
        if (mounted) setState(() {});
      }
    } catch (_) {
      // Offline or signed out: the block falls back to its plain subtitle.
    }
  }

  final _snakeKey = GlobalKey<LBHomeSnakeState>();
  Offset _panDelta = Offset.zero;
  bool _panSteered = false;

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

    final theme = context.watch<ThemeCubit>().state.currentTheme;

    return Stack(
      children: [
        Scaffold(
          // The legal strip rides above the banner ad rather than inside the
          // board: it must stay visible without the user hunting for it.
          // Renders nothing once acceptance is on file.
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UpdateReadyNotice(theme: theme),
              FirstRunLegalNotice(theme: theme),
              const LBBannerSlot(),
            ],
          ),
          body: LBGridBackground(
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildBoard(context, constraints),
            ),
          ),
        ),
        if (walkthroughState.isActive && walkthroughState.currentStep != null)
          WalkthroughOverlay(
            step: walkthroughState.currentStep!,
            theme: theme,
            currentStepIndex: walkthroughState.currentStepIndex,
            totalSteps: walkthroughState.steps.length,
            onNext: () => ref.read(walkthroughProvider.notifier).next(),
            onSkip: () => ref.read(walkthroughProvider.notifier).skip(),
          ),
      ],
    );
  }

  /// The home board (Living Board screen 02). Everything is placed on whole
  /// grid cells in the body's own coordinates, so blocks line up with the
  /// background grid and the snake can be steered into them cell by cell.
  Widget _buildBoard(BuildContext context, BoxConstraints constraints) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final cell = context.lbCell;
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final cols = (w / cell).floor();
    final rows = (h / cell).floor();
    final x0 = (w - cols * cell) / 2;

    // Content columns: one cell of margin each side, capped to a centred
    // column on tablets (no-op on phones).
    final maxCols = context.isTablet
        ? (ContentWidth.menuMaxWidth * context.uiScale / cell).floor()
        : cols - 2;
    final contentCols = math.min(cols - 2, maxCols);
    final c0 = (cols - contentCols) ~/ 2;
    Rect r(num col, num row, num cw, num ch) =>
        Rect.fromLTWH(x0 + col * cell, row * cell, cw * cell, ch * cell);

    // ── Vertical plan ─────────────────────────────────────────────────────
    //
    // The kit draws Home for a 360x780 frame; real phones are taller,
    // shorter and wider. Lay out the minimum on whole grid rows, then spend
    // the rows that are left — taller destination tiles first, then a
    // bigger PLAY, then breathing room between the groups — so no phone
    // gets a cramped board or a dead band.
    final top = ((MediaQuery.paddingOf(context).top + 6) / cell).ceil();
    // One clear row between YOUR BEST and the snake's ring around PLAY.
    const scoreGap = 1;
    var bestRows = 5, playH = 4, tileH = 3;
    var showHint = true;
    int fixedRows() =>
        2 + 1 + bestRows + scoreGap + 1 + playH + 1 + 1 + 1 + tileH * 3 + (showHint ? 1 : 0);
    final available = rows - 1 - top;
    var spare = available - fixedRows();
    if (spare < 0) {
      bestRows = 3;
      spare = available - fixedRows();
    }
    if (spare < 0) {
      showHint = false;
      spare = available - fixedRows();
    }
    // PLAY is the one loud thing: it grows first (two more rows), then the
    // destination tiles.
    if (spare >= 2) {
      playH = 6;
      spare -= 2;
    } else if (spare >= 1) {
      playH = 5;
      spare -= 1;
    }
    if (spare >= 4) {
      tileH = 4;
      spare -= 3;
    }
    // Whatever is left becomes even gaps: above the tiles, under the
    // header, and between the mode row and the chips.
    final gaps = [0, 0, 0];
    for (var k = 0; spare > 0; k = (k + 1) % gaps.length, spare--) {
      gaps[k]++;
    }

    final headerRow = top;
    final bestLabelRow = headerRow + 2 + gaps[1] + 1;
    final bestRow = bestLabelRow + 1;
    final gapRow = bestRow + bestRows;
    // As wide as the ring allows: three columns each side for the snake's
    // loop and the food, capped so it stays a button on wide screens, and
    // the same parity as the content so it centres on the grid.
    var playW = math.min(contentCols - 6, 12);
    if ((contentCols - playW).isOdd) playW -= 1;
    final playC0 = c0 + (contentCols - playW) ~/ 2;
    final playR0 = gapRow + scoreGap + 1;
    final modeBarRow = playR0 + playH + 1;
    final modeRow = modeBarRow + 1;
    final tilesTop = modeRow + 1 + gaps[2] + gaps[0];
    final hintRow = tilesTop + tileH * 3;

    final settings = context.watch<GameSettingsCubit>().state;
    final modes = GameMode.values;
    final modeIndex = modes.indexOf(settings.gameMode);

    // ── Snake: loop one cell outside PLAY, clockwise from the top-left ──
    final ringL = playC0 - 1,
        ringR = playC0 + playW,
        ringT = playR0 - 1,
        ringB = playR0 + playH;
    final loop = <HomeCell>[
      for (var x = ringL; x <= ringR; x++) (x, ringT),
      for (var y = ringT + 1; y <= ringB; y++) (ringR, y),
      for (var x = ringR - 1; x >= ringL; x--) (x, ringB),
      for (var y = ringB - 1; y > ringT; y--) (ringL, y),
    ];
    final half = contentCols / 2;
    final tiles = <String>[
      'versus',
      'daily',
      'season',
      'ranks',
      'store',
      'powerup',
    ];
    Rect tileRect(int i) {
      final col = i % 2, row = i ~/ 2;
      return r(
        c0 + (col == 0 ? 0 : half),
        tilesTop + row * tileH,
        col == 0 ? half : contentCols - half,
        tileH,
      );
    }

    final targets = <HomeSnakeTarget>[
      HomeSnakeTarget('play', playC0, playR0, playC0 + playW, playR0 + playH),
      HomeSnakeTarget(
        'best',
        c0,
        bestLabelRow,
        c0 + contentCols,
        bestRow + bestRows,
      ),
      HomeSnakeTarget(
        'menu',
        c0 + contentCols - 2,
        headerRow,
        c0 + contentCols,
        headerRow + 2,
      ),
      HomeSnakeTarget('setup', c0, modeBarRow, c0 + contentCols, modeRow + 1),
      for (var i = 0; i < tiles.length; i++)
        HomeSnakeTarget(
          tiles[i],
          c0 + (i.isEven ? 0 : half.floor()),
          tilesTop + (i ~/ 2) * tileH,
          i.isEven ? c0 + half.ceil() : c0 + contentCols,
          tilesTop + (i ~/ 2) * tileH + tileH,
        ),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) {
        _panDelta = Offset.zero;
        _panSteered = false;
      },
      onPanUpdate: (d) {
        if (_panSteered) return;
        _panDelta += d.delta;
        if (_panDelta.distance < 18) return;
        _panSteered = true;
        final dir = _panDelta.dx.abs() > _panDelta.dy.abs()
            ? (_panDelta.dx > 0 ? AxisDirection.right : AxisDirection.left)
            : (_panDelta.dy > 0 ? AxisDirection.down : AxisDirection.up);
        _snakeKey.currentState?.steer(dir);
      },
      child: Stack(
        children: [
          // Header: mark + name + greeting, menu block on the right.
          Positioned.fromRect(
            rect: r(c0, headerRow, contentCols - 2, 2),
            child: _HomeHeader(
              player: context.watch<AuthCubit>().state.publicLabel,
              photoUrl: context.watch<AuthCubit>().state.photoURL,
              onAvatar: () => _enter(context, 'profile'),
            ),
          ),
          Positioned.fromRect(
            rect: r(c0 + contentCols - 2, headerRow, 2, 2),
            child: LBIconBlock(
              key: HomeWalkthrough.helpKey,
              icon: LBIcon.grid,
              semanticLabel: l10n.lbHomeMenu,
              onTap: () => _openMenu(context),
            ),
          ),

          // Best score in snake cells, coins on the right.
          Positioned.fromRect(
            rect: r(c0, bestLabelRow, contentCols, 1),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.lbYourBest,
                    style: LBText.label(
                      p,
                      color: LB.gold.withValues(alpha: .8),
                    ).copyWith(fontSize: 10.5),
                  ),
                ),
                BlocBuilder<CoinsCubit, CoinsState>(
                  builder: (context, coins) => _CoinReadout(
                    key: HomeWalkthrough.coinsKey,
                    value: context.formatInt(coins.total),
                    onTap: () => context.push(AppRoutes.store),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fromRect(
            rect: r(c0, bestRow, contentCols, bestRows),
            child: Semantics(
              button: true,
              label: '${l10n.lbYourBest} ${settings.highScore}',
              child: GestureDetector(
                onTap: () {
                  LBFeedback.tap();
                  context.push(AppRoutes.statistics);
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: LBAnimatedCellText(
                    '${settings.highScore}',
                    cell: bestRows * cell / 5,
                    color: LB.gold.withValues(alpha: .34),
                  ),
                ),
              ),
            ),
          ),

          // PLAY — the one loud thing.
          Positioned.fromRect(
            rect: r(playC0, playR0, playW, playH),
            child: LBBlock(
              key: HomeWalkthrough.playButtonKey,
              kind: LBBlockKind.fill,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              semanticLabel:
                  '${l10n.lbPlay}, ${settings.gameMode.localizedName(l10n)}',
              onTap: () => _startGame(context),
              onLongPress: () => context.push(AppRoutes.runSetup),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LBCellText(
                    l10n.lbPlay,
                    cell: (7 + (playH - 4) * 1.5) * context.uiScale,
                    color: p.onLime,
                  ),
                  SizedBox(height: 8 * context.uiScale),
                  Text(
                    l10n.lbModeBoard(
                      settings.gameMode.localizedName(l10n).toUpperCase(),
                      settings.boardSize.id.replaceAll('x', '×'),
                    ),
                    style: LBText.label(
                      p,
                      color: p.onLime.withValues(alpha: .7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mode indicator cells + cycler.
          Positioned.fromRect(
            rect: r(playC0 + (playW - 8) / 2, modeBarRow, 8, 1),
            child: LBCellsBar(
              count: modes.length,
              value: 1,
              cell: cell,
              colorAt: (i) => i == modeIndex ? p.lime : p.cellOff,
            ),
          ),
          Positioned.fromRect(
            rect: r(c0, modeRow, contentCols, 1).inflate(6),
            child: _ModeCycler(
              label: l10n.lbModeRow(
                '${modeIndex + 1}',
                '${modes.length}',
                settings.gameMode.localizedName(l10n).toUpperCase(),
              ),
              onPrev: () => context.read<GameSettingsCubit>().setGameMode(
                modes[(modeIndex - 1 + modes.length) % modes.length],
              ),
              onNext: () => context.read<GameSettingsCubit>().setGameMode(
                modes[(modeIndex + 1) % modes.length],
              ),
              onOpen: () => context.push(AppRoutes.runSetup),
            ),
          ),

          // Destinations.
          for (var i = 0; i < tiles.length; i++)
            Positioned.fromRect(
              rect: tileRect(i),
              child: _tile(context, tiles[i], tall: tileH > 3),
            ),

          if (showHint)
            Positioned.fromRect(
              rect: r(c0, hintRow, contentCols, 1),
              child: Center(
                child: Text(
                  l10n.lbHomeHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.label(
                    p,
                    color: p.inkDim,
                  ).copyWith(fontSize: 8.5),
                ),
              ),
            ),

          Positioned.fill(
            child: LBHomeSnake(
              key: _snakeKey,
              cell: cell,
              originX: x0,
              loop: loop,
              targets: targets,
              columns: cols,
              rows: rows,
              onEnter: (id) => _enter(context, id),
            ),
          ),
        ],
      ),
    );
  }

  /// A destination reached by steering the snake into it (or tapping it).
  void _enter(BuildContext context, String id) {
    HapticService().selectionClick();
    switch (id) {
      case 'play':
        _startGame(context);
      case 'daily':
        context.push(AppRoutes.dailyChallenges);
      case 'best':
        context.push(AppRoutes.statistics);
      case 'menu':
        _openMenu(context);
      case 'setup':
        context.push(AppRoutes.runSetup);
      case 'versus':
        _openVersusLobby(context);
      case 'season':
        context.push(AppRoutes.battlePass);
      case 'ranks':
        context.push(AppRoutes.leaderboard);
      case 'store':
        context.push(AppRoutes.store);
      case 'profile':
        context.push(AppRoutes.profile);
      case 'powerup':
        // Free players watch for one; Pro (no ads) arms what they own.
        if (getIt.isRegistered<AdService>() && getIt<AdService>().adsEnabled) {
          _watchForFreePowerUp(context);
        } else {
          context.push(AppRoutes.runSetup);
        }
    }
  }

  Widget _tile(BuildContext context, String id, {bool tall = false}) {
    final l10n = AppLocalizations.of(context)!;
    void go() => _enter(context, id);
    switch (id) {
      case 'versus':
        return _HomeTile(
          tall: tall,
          key: HomeWalkthrough.versusKey,
          icon: LBIcon.swords,
          title: l10n.lbHomeVersus,
          subtitle: _versusRating != null
              ? l10n.lbHomeVersusSub(context.formatInt(_versusRating!))
              : l10n.lbHomeVersusSubOffline,
          onTap: go,
        );
      case 'daily':
        final daily = ref.watch(dailyChallengesProvider);
        final claimable = ref.watch(unclaimedRewardsCountProvider) > 0;
        final coinsLeft = daily.challenges
            .where((c) => !c.claimedReward)
            .fold<int>(0, (sum, c) => sum + c.coinReward);
        final now = DateTime.now();
        final reset = DateTime(
          now.year,
          now.month,
          now.day + 1,
        ).difference(now);
        return _HomeTile(
          tall: tall,
          key: HomeWalkthrough.dailyChallengesKey,
          icon: LBIcon.calendar,
          title: daily.totalCount == 0
              ? l10n.lbDailyTitle
              : l10n.lbHomeDaily(
                  '${daily.completedCount}',
                  '${daily.totalCount}',
                ),
          subtitle: coinsLeft > 0
              ? l10n.lbHomeDailySub(_hm(reset), context.formatInt(coinsLeft))
              : l10n.lbResetsIn(_hm(reset)),
          kind: claimable ? LBBlockKind.gold : LBBlockKind.outline,
          onTap: go,
        );
      case 'season':
        final bp = context.watch<BattlePassCubit>().state;
        final end = bp.season?.endDate ?? bp.expiryDate;
        final daysLeft = end?.difference(DateTime.now()).inDays;
        return _HomeTile(
          tall: tall,
          icon: LBIcon.star,
          title: l10n.lbHomeSeason,
          subtitle: bp.isActive && daysLeft != null && daysLeft >= 0
              ? l10n.lbHomeSeasonSub('${bp.currentTier}', daysLeft)
              : l10n.lbHomeSeasonSubNone,
          onTap: go,
        );
      case 'ranks':
        final best = context.watch<GameSettingsCubit>().state.highScore;
        return _HomeTile(
          tall: tall,
          icon: LBIcon.trophy,
          title: l10n.lbHomeRanks,
          subtitle: _globalRank != null
              ? l10n.lbHomeRanksSub(context.formatInt(_globalRank!))
              : l10n.lbHomeRanksSubNone(context.formatInt(best)),
          onTap: go,
        );
      case 'store':
        return _HomeTile(
          tall: tall,
          key: HomeWalkthrough.storeKey,
          icon: LBIcon.coin,
          title: l10n.lbHomeStore,
          subtitle: l10n.lbHomeStoreSub,
          onTap: go,
        );
      default:
        // Power-ups: the free (rewarded) one for players who see ads, the
        // owned stock for Pro; the armed one, if any, in the subtitle.
        final adsOn = getIt.isRegistered<AdService>() && getIt<AdService>().adsEnabled;
        return BlocBuilder<PowerUpCubit, PowerUpState>(
          builder: (context, state) {
            final armed = state.armed;
            final owned = state.inventory.values.fold<int>(0, (a, b) => a + b);
            return _HomeTile(
              tall: tall,
              icon: adsOn ? LBIcon.tv : LBIcon.bolt,
              title: adsOn ? l10n.lbHomeFreePowerUp : l10n.lbHomePowerUps,
              subtitle: armed != null
                  ? l10n.lbArmedChip(loadoutLabelFor(l10n, armed).toUpperCase())
                  : adsOn
                      ? l10n.lbHomeFreePowerUpSub
                      : l10n.lbHomePowerUpsSub(context.formatInt(owned)),
              kind: adsOn ? LBBlockKind.gold : LBBlockKind.outline,
              onTap: go,
            );
          },
        );
    }
  }

  static String _hm(Duration d) =>
      '${d.inHours}h ${d.inMinutes.remainder(60)}m';

  void _openMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.read<ThemeCubit>().state.currentTheme;
    showLBSheet<void>(
      context: context,
      title: l10n.lbHomeMenu,
      builder: (sheetContext) {
        void go(String route) {
          Navigator.of(sheetContext).pop();
          context.push(route);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LBRow(
                title: l10n.lbSettingsTitle,
                subtitle: l10n.lbPauseSettingsSub,
                leading: const LBPixelIcon(LBIcon.gear, cell: 4),
                onTap: () => go(AppRoutes.settings),
              ),
              LBRow(
                title: l10n.lbMenuHowToPlay,
                subtitle: l10n.lbMenuHowToPlaySub,
                leading: const LBPixelIcon(LBIcon.eye, cell: 4),
                onTap: () => go(AppRoutes.instructions),
              ),
              LBRow(
                title: l10n.lbMenuTournaments,
                subtitle: l10n.lbTournamentsLine,
                leading: const LBPixelIcon(LBIcon.crown, cell: 4),
                onTap: () => go(AppRoutes.tournaments),
              ),
              LBRow(
                title: l10n.lbFriends,
                leading: const LBPixelIcon(LBIcon.friends, cell: 4),
                onTap: () => go(AppRoutes.friends),
              ),
              LBRow(
                title: l10n.lbTrophies,
                leading: const LBPixelIcon(LBIcon.trophy, cell: 4),
                onTap: () => go(AppRoutes.achievements),
              ),
              LBRow(
                title: l10n.lbReplays,
                leading: const LBPixelIcon(LBIcon.film, cell: 4),
                onTap: () => go(AppRoutes.replays),
              ),
              LBRow(
                title: l10n.lbMenuAbout,
                subtitle: l10n.lbMenuAboutSub,
                leading: const LBPixelIcon(LBIcon.star, cell: 4),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showCreditsDialog(context, theme);
                },
              ),
            ],
          ),
        );
      },
    );
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

  /// Start a game — PLAY's action.
  ///
  /// Includes the first-run skip of the mode picker: a player who has never
  /// seen the board cannot choose between Classic, Zen, Survival and Time
  /// Attack, so they get Classic and the picker on their second tap.
  Future<void> _startGame(BuildContext context) async {
    unawaited(LegalAcceptance.recordAccepted());
    HapticService().mediumImpact();

    if (!FirstRunService().isFirstGame) {
      await _maybeShowGameModePrompt();
      if (!context.mounted) return;
    }
    context.push(AppRoutes.playLoading);
  }

  /// Opt-in rewarded watch for a free Speed Boost. Tells the user up front
  /// exactly what they'll get, then confirms the grant with a toast. Grants
  /// no coins, so the economy stays safe. Opt-in and uncapped.
  Future<void> _watchForFreePowerUp(BuildContext context) async {
    final ads = getIt<AdService>();
    final messenger = ScaffoldMessenger.of(context);
    final powerUps = context.read<PowerUpCubit>();
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final l10n = AppLocalizations.of(context)!;

    // Deliberately NOT gated on isRewardedReady. The loading screen warms a
    // rewarded ad for free users, so the pool is normally full here; on the
    // rare miss, showRewardedOrWait triggers the load and waits it out, and
    // only THEN reports "no ad" — instead of turning the tap away up front.
    if (!ads.adsEnabled) {
      messenger.showSnackBar(
        arcadeSnackBar(context, message: l10n.homeNoAdReady),
      );
      return;
    }

    // Tell the user what they're opting into BEFORE the ad plays.
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.homeFreeSpeedBoostTitle,
      body: l10n.homeFreeSpeedBoostBody,
      primaryLabel: l10n.homeWatchAd,
      onPrimary: () => Navigator.of(context).pop(true),
      secondaryLabel: l10n.homeNotNow,
      onSecondary: () => Navigator.of(context).pop(false),
    );
    if (confirmed != true) return;

    final outcome = await ads.showRewardedOrWait(
      placement: AdService.placementFreePowerUp,
      onReward: powerUps.grantFreePowerUp,
      onWaitStart: () => messenger.showSnackBar(
        arcadeSnackBarFor(theme, message: l10n.rvoLoadingAd),
      ),
    );

    // Confirm the reward (fires after the ad is dismissed). If the user closed
    // the ad early, tell them no reward was given rather than leaving them
    // guessing; if no ad could be fetched at all, say that instead.
    if (outcome == RewardedOutcome.unavailable) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        arcadeSnackBarFor(theme, message: l10n.homeNoAdReady),
      );
    } else if (outcome == RewardedOutcome.rewarded) {
      showRewardToast(
        messenger,
        l10n.homeFreeSpeedBoostAdded,
        icon: Icons.bolt,
      );
    } else {
      messenger.showSnackBar(
        arcadeSnackBarFor(theme, message: l10n.homeAdNotFinished),
      );
    }
  }
}

/// Mark, name and greeting. Tapping the mark opens About.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.player, required this.photoUrl, required this.onAvatar});

  /// Who is playing — the signed-in name, or the guest label.
  final String player;

  /// Account photo (Google sign-in), if any.
  final String? photoUrl;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final s = context.lbCell * 2;
    return Row(
      children: [
        _HomeAvatar(
          key: HomeWalkthrough.profileKey,
          size: s,
          initial: player.trim().isEmpty ? '?' : player.trim()[0].toUpperCase(),
          photoUrl: photoUrl,
          onTap: onAvatar,
        ),
        const SizedBox(width: 12),
        Expanded(
          // Two rows of grid, so the type is fixed rather than scaled.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SNAKE CLASSIC',
                  maxLines: 1,
                  style: LBText.button(
                    p,
                    color: p.lime,
                    size: 12.5,
                  ).copyWith(letterSpacing: 3, height: 1.15),
                ),
                const SizedBox(height: 2),
                Text(
                  player,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.body(
                    p,
                    color: p.ink.withValues(alpha: .8),
                    size: 12,
                  ).copyWith(height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CoinReadout extends StatelessWidget {
  const _CoinReadout({super.key, required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      button: true,
      label: '${AppLocalizations.of(context)!.lbSnakeCoins} $value',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          LBFeedback.tap();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LBPixelIcon(LBIcon.coin, cell: 3, color: LB.gold),
              const SizedBox(width: 7),
              Text(value, style: LBText.value(p, color: LB.gold, size: 15)),
            ],
          ),
        ),
      ),
    );
  }
}

/// `‹ MODE 1/8 · CLASSIC ›` — arrows cycle the mode, the label opens setup.
class _ModeCycler extends StatelessWidget {
  const _ModeCycler({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onOpen,
  });

  final String label;
  final VoidCallback onPrev, onNext, onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final style = LBText.label(p, color: p.inkMuted).copyWith(fontSize: 10.5);
    Widget arrow(String glyph, VoidCallback onTap, String semantic) =>
        Semantics(
          button: true,
          label: semantic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              LBFeedback.tap();
              onTap();
            },
            child: SizedBox(
              width: 44,
              child: Center(
                child: Text(glyph, style: style.copyWith(fontSize: 14)),
              ),
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        arrow(
          '‹',
          onPrev,
          MaterialLocalizations.of(context).previousPageTooltip,
        ),
        Flexible(
          child: Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                LBFeedback.tap();
                onOpen();
              },
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
        ),
        arrow('›', onNext, MaterialLocalizations.of(context).nextPageTooltip),
      ],
    );
  }
}


/// One destination block: icon + title, subtitle beneath.
class _HomeTile extends StatelessWidget {
  const _HomeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.kind = LBBlockKind.outline,
    this.tall = false,
  });

  /// Four grid rows instead of three: bigger type to fill the block.
  final bool tall;
  final LBIcon icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final LBBlockKind kind;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = kind == LBBlockKind.gold ? LB.gold : p.head;
    return LBBlock(
      kind: kind,
      onTap: onTap,
      semanticLabel: '$title, $subtitle',
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LBPixelIcon(icon, cell: tall ? 3.8 : 3.2, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(
                    p,
                    color: fg,
                    size: 14,
                  ).copyWith(letterSpacing: 2),
                ),
              ),
            ],
          ),
          SizedBox(height: tall ? 9 : 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LBText.body(
              p,
              color: p.ink.withValues(alpha: .62),
              size: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Localized name of a loadout inventory key. Shared with the run setup
/// screen.
String loadoutLabelFor(AppLocalizations l10n, String inventoryKey) =>
    switch (inventoryKey) {
      'speed_boost' => l10n.puSpeedBoost,
      'invincibility' => l10n.puInvincibility,
      'score_multiplier' => l10n.puScoreMultiplier,
      'slow_motion' => l10n.puSlowMotion,
      _ => inventoryKey,
    };

/// The player's avatar in the top bar: their account photo, else the pixel
/// figure, with the level on a gold tab. Opens Profile.
class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({
    super.key,
    required this.size,
    required this.initial,
    required this.photoUrl,
    required this.onTap,
  });

  final double size;

  /// The player's first letter, drawn in cells like Profile's hero.
  final String initial;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final figure = Center(
      child: LBCellText(initial, cell: size / 9, glow: true, color: p.lime),
    );
    return ListenableBuilder(
      listenable: ProgressionService(),
      builder: (context, _) {
        final level = l10n.lbLevelShort('${ProgressionService().level}');
        return Semantics(
          button: true,
          label: '${l10n.lbHomeProfile}, $level',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              LBFeedback.tap();
              onTap();
            },
            child: SizedBox.square(
              dimension: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: LBBlock(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(LB.blockRadius - 1),
                        child: photoUrl == null || photoUrl!.isEmpty
                            ? figure
                            : Image.network(
                                photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => figure,
                              ),
                      ),
                    ),
                  ),
                  // The level tab hangs off the bottom edge, like the old
                  // avatar's badge.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -7,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: LB.gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          child: MediaQuery.withNoTextScaling(
                            child: Text(
                              level,
                              maxLines: 1,
                              style: LBText.label(p, color: p.board).copyWith(
                                fontSize: 8.5,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
