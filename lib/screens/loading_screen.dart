import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/first_run_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {

  _InitStep _step = _InitStep.initializing;
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showRetryButton = false;

  /// One tip per launch (COPY.md: "rotate one per launch").
  final int _tipIndex = Random().nextInt(8);

  /// App version for the footer; filled in once PackageInfo resolves.
  String? _version;

  /// Backstop for a stalled init.
  ///
  /// Every step of [_initializeApp] is individually try/caught and treated as
  /// non-fatal — a failure logs a warning and the app carries on. What none of
  /// them survive is a call that neither completes nor throws, which leaves
  /// this screen showing a frozen progress bar with no error and no retry.
  /// Rather than trust that every current and future await is bounded, this
  /// timer guarantees the user reaches the game.
  Timer? _watchdogTimer;
  static const Duration _initWatchdog = Duration(seconds: 18);

  /// How long the loading screen is willing to hold for the FIRST rewarded ad
  /// to fill, measured from the start of init (the wait overlaps every other
  /// step, so it only extends the screen when the fill is slower than the
  /// rest of startup). Free users only — see [_beginRewardedAdWarmup].
  ///
  /// Was 8s. Holding a first-time player on a loading screen for up to 8
  /// seconds so an ad is ready is the wrong trade for an app whose biggest
  /// loss is players who leave before their first game, and the Free button
  /// no longer needs it: it goes through showRewardedOrWait, which waits for
  /// a fill on demand. 2s keeps the common case (fill lands during startup)
  /// without letting a slow fill hold the door.
  static const Duration _rewardedWarmupBudget = Duration(seconds: 2);

  /// Guards against a double navigation when the watchdog fires at the same
  /// moment init finishes.
  bool _navigated = false;

  /// Single exit point from this screen. First caller wins.
  void _leaveLoadingScreen(String route, {required String reason}) {
    if (_navigated || !mounted) return;
    _navigated = true;
    _watchdogTimer?.cancel();
    AppLogger.lifecycle('Leaving loading screen → $route ($reason)');
    context.go(route);
  }

  // Resolved at render time so the tips follow the ambient locale.
  List<String> _tips(AppLocalizations l10n) => [
        l10n.lbTip1,
        l10n.lbTip2,
        l10n.lbTip3,
        l10n.lbTip4,
        l10n.lbTip5,
        l10n.lbTip6,
        l10n.lbTip7,
        l10n.lbTip8,
      ];

  @override
  void initState() {
    super.initState();

    // Hide the Splash Screen after initialization
    FlutterNativeSplash.remove();

    unawaited(PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    }));

    // Arm the watchdog BEFORE init starts, so a step that hangs on its very
    // first await is still covered. Home is the right universal fallback:
    // under play-first it is where both new and returning users are headed
    // anyway. The one thing it can skip is the legal re-consent gate for an
    // existing user on a bumped policy version — they will simply be gated on
    // the next launch, which is a far better outcome than a frozen screen.
    _watchdogTimer = Timer(_initWatchdog, () {
      _leaveLoadingScreen(
        AppRoutes.home,
        reason: 'watchdog — init exceeded ${_initWatchdog.inSeconds}s',
      );
    });

    // Start the initialization process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize Core Services
      await _updateProgress(0.1, _InitStep.core);
      await _initializeCoreServices();

      // Start waiting for the first rewarded ad NOW so the wait overlaps
      // the profile / cloud / game-data steps below; it is awaited at the
      // dedicated ads step. Pro users and non-mobile resolve immediately.
      final rewardedWarmup = _beginRewardedAdWarmup();

      // Step 2: Initialize User System
      await _updateProgress(0.25, _InitStep.profile);
      await _initializeUserSystem();

      // Step 3: Preferences checkpoint. Theme/trail/settings now hydrate
      // from Drift inside their cubits (ThemeCubit/GameSettingsCubit are
      // initialized via MultiBlocProvider in main.dart) — nothing to load
      // here anymore.
      await _updateProgress(0.4, _InitStep.prefs);

      // Step 4a: Bootstrap DataSyncService — fast local op, needed before
      // preload because preload paths call into the sync service.
      await _updateProgress(0.50, _InitStep.cloud);
      await _initializeDataSyncService();

      // Step 4b + 5: Drain the outgoing sync queue AND fetch fresh data
      // concurrently. Previously the drain ran sequentially before the
      // preload, adding its full duration to the loading screen even
      // though the two operations don't depend on each other (drain is
      // POST-to-server, preload is GET-from-server).
      await _updateProgress(0.60, _InitStep.gameData);
      await Future.wait([
        _preloadAllDataConcurrently(),
        _drainSyncQueue(),
      ]);

      // Step 6: Free users — hold (bounded) for the first rewarded ad so
      // Home's Free button pops the ad instantly instead of "no ad ready".
      await _updateProgress(0.80, _InitStep.ads);
      await rewardedWarmup;

      // Step 7: Initialize Audio System
      await _updateProgress(0.90, _InitStep.audio);
      await _initializeAudio();

      // Step 8: Check for first-time user
      await _updateProgress(0.98, _InitStep.setup);

      if (mounted) {
        final authCubit = context.read<AuthCubit>();

        // Wait for local init only (fast, no network) with 2-second timeout
        // This uses the Completer instead of polling - more reliable and efficient
        try {
          await authCubit.waitForLocalInit().timeout(
            const Duration(seconds: 2),
          );
          AppLogger.info(
            'AuthCubit local init complete. isFirstTimeUser: ${authCubit.state.isFirstTimeUser}',
          );
        } catch (e) {
          // Timeout - fall back to checking SharedPreferences directly
          AppLogger.warning('AuthCubit local init timeout, checking prefs directly');
          try {
            final prefs = await SharedPreferences.getInstance();
            final isFirstTimeFromPrefs = !(prefs.getBool('first_time_setup_complete') ?? false);
            // Update state if needed (though authCubit should have it by now)
            if (authCubit.state.isFirstTimeUser != isFirstTimeFromPrefs) {
              AppLogger.info('Using direct prefs check: isFirstTime=$isFirstTimeFromPrefs');
            }
          } catch (_) {
            // Ignore - use whatever authCubit has
          }
        }

        final isFirstTime = authCubit.state.isFirstTimeUser;

        if (isFirstTime) {
          await _updateProgress(1.0, _InitStep.welcome);
          await Future.delayed(
            const Duration(milliseconds: 50),
          ); // Reduced from 100ms

          // PLAY FIRST. A brand-new install goes straight to Home — no legal
          // reader, no auth wall, no username picker. GA4 showed ~23% of
          // installs never got past that gauntlet and ~40% never started a
          // single game, while the players who DID reach gameplay averaged
          // 9m09s per session. The wall was filtering out people who wanted
          // to play. See RETENTION_PLAN.md.
          //
          // Safe because the identity already exists: UnifiedUserService
          // .initialize() creates a purely-local offline guest whenever there
          // is no Firebase user and no cached session, and the whole
          // Drift-first architecture is built to run without a backend
          // account. Nothing here is a downgrade — it is the capability that
          // was already shipped, finally reachable.
          //
          // Sign-in is not gone, it is MOVED: the deferred prompt fires once
          // the player has a score worth protecting (see
          // DeferredSignInPrompt), and Profile keeps its permanent entry
          // point. Progress survives the upgrade — a first sign-in that
          // registers a NEW backend account reports is_new_user, which makes
          // SyncEngine skip the cloud pull entirely and push local Drift up
          // instead of overwriting it.
          //
          // Legal consent is carried by the non-blocking FirstRunLegalNotice
          // strip on Home and recorded when the player taps Play.
          await authCubit.markFirstTimeSetupComplete();

          if (!mounted) {
            return;
          }
          getIt<AnalyticsFacade>().trackOnboardingStepCompleted('play_first');
          _leaveLoadingScreen(AppRoutes.home, reason: 'first launch');
          return;
        }
      }

      // Returning user: if the privacy policy has changed version since they
      // last accepted it, gate them through the re-consent screen first.
      // Deliberately still blocking for EXISTING users — a material change to
      // terms someone already agreed to warrants more than a footer, and this
      // path can only be reached by someone who has already played.
      final policyAccepted = await LegalAcceptance.isCurrentVersionAccepted();
      if (!policyAccepted) {
        if (!mounted) return;
        _leaveLoadingScreen(
          AppRoutes.privacyConsent,
          reason: 'legal version bumped',
        );
        return;
      }

      // Step 9: Complete (for returning users)
      await _updateProgress(1.0, _InitStep.ready);
      await Future.delayed(
        const Duration(milliseconds: 50),
      ); // Reduced from 100ms

      // Navigation to Home Screen with smooth transition (returning users)
      _leaveLoadingScreen(AppRoutes.home, reason: 'init complete');
    } catch (error) {
      // Store the raw error; the localized "Initialization failed: {error}"
      // string is resolved at render time in _buildErrorView.
      _handleError('$error');
    }
  }

  Future<void> _initializeCoreServices() async {
    try {
      AppLogger.lifecycle('Initializing core services');

      // Initialize connectivity service early so sync indicator works
      final connectivityService = ConnectivityService();
      await connectivityService.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () => AppLogger.warning(
          'ConnectivityService init timed out — assuming online',
        ),
      );
      AppLogger.success('ConnectivityService initialized');

      // Core services (Firebase, Audio, etc.) already initialized in main()
    } catch (e) {
      AppLogger.error('Core services initialization warning', e);
    }
  }

  Future<void> _initializeUserSystem() async {
    try {
      AppLogger.lifecycle('Starting user system initialization...');

      if (!mounted) return;
      final unifiedUserService = Provider.of<UnifiedUserService>(
        context,
        listen: false,
      );

      // Bounded: this reaches the network via ApiService.initialize and the
      // backend user handoff. A stalled socket here used to hold the whole
      // loading screen. On timeout the service is left with whatever identity
      // it managed to establish (cached session or offline guest), which is
      // enough to play.
      await unifiedUserService.initialize().timeout(
        const Duration(seconds: 8),
        onTimeout: () => AppLogger.warning(
          'UnifiedUserService init timed out — continuing with local identity',
        ),
      );
      AppLogger.success('UnifiedUserService initialized');

      // AuthCubit is already initialized via MultiBlocProvider in main.dart
      // PurchaseService is already initialized in main.dart
      AppLogger.info('PurchaseService ready');

      AppLogger.success('User system initialization complete');
    } catch (e) {
      AppLogger.error('User system initialization error', e);
    }
  }

  /// Load ALL data concurrently for maximum speed
  Future<void> _preloadAllDataConcurrently() async {
    try {
      AppLogger.lifecycle('Preloading all data concurrently');

      // All these run IN PARALLEL - much faster!
      await Future.wait([
        // Core services initialization
        _initializeStatistics(),
        _initializeAchievements(),

        // Preload ALL cached data (stats, settings, leaderboards, etc.)
        _preloadAppDataCache(),
      ]);

      AppLogger.success('All data preloaded concurrently');
    } catch (e) {
      AppLogger.error('Concurrent preload warning', e);
    }
  }

  Future<void> _preloadAppDataCache() async {
    try {
      final appCache = getIt<AppDataCache>();
      // A player who has never started a game has no leaderboard standing, no
      // tournament entries and no friends — and no JWT to fetch them with.
      // Skipping that group removes up to three 4-second timeouts from the
      // slowest, most churn-prone launch there is.
      await appCache.preloadAll(
        skipNetwork: FirstRunService().isFirstGame,
      );
      AppLogger.success('AppDataCache preloaded successfully');
    } catch (e) {
      AppLogger.error('AppDataCache preload warning', e);
    }
  }

  Future<void> _initializeStatistics() async {
    try {
      AppLogger.stats('Initializing statistics service');

      final statisticsService = StatisticsService();
      await statisticsService.initialize();

      AppLogger.success('Statistics service initialized');
    } catch (e) {
      AppLogger.stats('Statistics initialization warning', e);
    }
  }

  Future<void> _initializeAchievements() async {
    try {
      AppLogger.achievement('Initializing achievement system');

      final achievementService = AchievementService();
      await achievementService.initialize();

      AppLogger.success('Achievement system initialized');
    } catch (e) {
      AppLogger.achievement('Achievement system initialization warning', e);
    }
  }

  /// Kick off the bounded wait for a rewarded fill. Never throws and never
  /// blocks a Pro user, a desktop/web build, or an offline device — all of
  /// those resolve at once inside [AdService.waitForRewardedReady].
  Future<void> _beginRewardedAdWarmup() async {
    try {
      if (!getIt.isRegistered<AdService>()) return;
      final ready = await getIt<AdService>().waitForRewardedReady(
        timeout: _rewardedWarmupBudget,
      );
      if (ready) {
        AppLogger.success('Rewarded ad warmed up before Home');
      } else {
        AppLogger.info(
          'Rewarded ad not ready before Home — continuing (loads in background)',
        );
      }
    } catch (e) {
      AppLogger.warning('Rewarded ad warmup skipped: $e');
    }
  }

  Future<void> _initializeAudio() async {
    try {
      AppLogger.audio('Verifying audio service');
      // Audio already initialized in main() with sounds pre-loaded
      // Just access the singleton to verify it exists
      AudioService();
      AppLogger.success('Audio service verified - sounds pre-loaded and ready');
    } catch (e) {
      AppLogger.audio('Audio system verification warning', e);
    }
  }

  /// Fast, local-only initialization of DataSyncService. Must run before
  /// _preloadAllDataConcurrently because preload paths call into the sync
  /// service for cloud reads. This is just Drift bootstrap + connectivity
  /// listener wiring — typically <100ms.
  Future<void> _initializeDataSyncService() async {
    try {
      if (!mounted) return;

      final unifiedUserService = Provider.of<UnifiedUserService>(
        context,
        listen: false,
      );
      final userId = unifiedUserService.currentUser?.uid ?? 'local_pending';

      final syncService = Provider.of<DataSyncService>(
        context,
        listen: false,
      );

      await syncService.initialize(userId).timeout(
        const Duration(seconds: 5),
        onTimeout: () =>
            AppLogger.warning('DataSyncService init timed out — continuing'),
      );
      AppLogger.success('DataSyncService initialized with userId: $userId');
    } catch (e) {
      AppLogger.sync('DataSyncService init warning', e);
    }
  }

  /// Slow, network-bearing drain of the pending sync queue. Independent of
  /// the data preload, so it runs in parallel with _preloadAllDataConcurrently.
  /// Skips entirely for placeholder / offline users.
  Future<void> _drainSyncQueue() async {
    try {
      if (!mounted) return;

      final unifiedUserService = Provider.of<UnifiedUserService>(
        context,
        listen: false,
      );
      final userId = unifiedUserService.currentUser?.uid ?? 'local_pending';
      final isPlaceholder =
          userId.startsWith('local_') || userId.startsWith('offline_');

      if (isPlaceholder || unifiedUserService.currentUser == null) {
        AppLogger.info(
          'Skipping force sync — placeholder user or offline session',
        );
        return;
      }

      final syncService = Provider.of<DataSyncService>(
        context,
        listen: false,
      );
      // Pushing queued writes is never worth blocking launch for — the outbox
      // survives and the SyncEngine drains it in the background.
      await syncService.forceSyncNow().timeout(
        const Duration(seconds: 6),
        onTimeout: () => AppLogger.warning(
          'Force sync timed out — outbox will drain in the background',
        ),
      );
      AppLogger.success('Force sync completed');
    } catch (e) {
      AppLogger.sync('Force sync warning', e);
    }
  }

  Future<void> _updateProgress(double progress, _InitStep step) async {
    if (!mounted) return;

    setState(() {
      _progress = progress;
      _step = step;
    });

    // Minimal delay for UI update (reduced from 50ms)
    await Future.delayed(const Duration(milliseconds: 16)); // ~1 frame
  }

  void _handleError(String error) {
    if (!mounted) return;

    AppLogger.error('Loading screen init failed', error);

    setState(() {
      _hasError = true;
      _errorMessage = error;
      _showRetryButton = true;
    });

    // The error view must not be a dead end. Every step of _initializeApp is
    // already individually try/caught, so reaching here means something
    // unexpected went wrong AFTER main()'s bootstrap succeeded — which means
    // the app itself is up and home will work fine. Show the user what
    // happened, leave Retry available, but carry them into the game shortly
    // either way rather than parking them on a screen whose only other option
    // is to kill the app.
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(
      const Duration(seconds: 5),
      () => _leaveLoadingScreen(AppRoutes.home, reason: 'error fallback'),
    );
  }

  Future<void> _retryInitialization() async {
    // Retry replaces the error fallback with a fresh full-length watchdog, so
    // a retry that also stalls is still bounded.
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(
      _initWatchdog,
      () => _leaveLoadingScreen(
        AppRoutes.home,
        reason: 'watchdog — retry exceeded ${_initWatchdog.inSeconds}s',
      ),
    );

    setState(() {
      _hasError = false;
      _errorMessage = '';
      _showRetryButton = false;
      _progress = 0.0;
      _step = _InitStep.retrying;
    });

    await _initializeApp();
  }

  /// Localized title for the current init step, resolved at render time.
  String _stepTitle(AppLocalizations l10n) => switch (_step) {
        _InitStep.initializing => l10n.ldInitializing,
        _InitStep.core => l10n.ldStepCore,
        _InitStep.profile => l10n.ldStepProfile,
        _InitStep.prefs => l10n.ldStepPrefs,
        _InitStep.cloud => l10n.ldStepCloud,
        _InitStep.gameData => l10n.ldStepGameData,
        _InitStep.ads => l10n.ldStepAds,
        _InitStep.audio => l10n.ldStepAudio,
        _InitStep.setup => l10n.ldStepSetup,
        _InitStep.welcome => l10n.ldWelcome,
        _InitStep.ready => l10n.ldReady,
        _InitStep.retrying => l10n.ldRetrying,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LBGridBackground(
        child: SafeArea(
          child: _hasError ? _buildErrorView(context) : _buildLoadingView(context),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final s = context.uiScale;
    final pct = (_progress.clamp(0.0, 1.0) * 100).round();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Same never-scroll, never-overflow guarantee as before: on a very
        // short screen the whole column scales down instead.
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight < 560 ? 560 : constraints.maxHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  LBCellSMark(size: 146 * s),
                  SizedBox(height: 40 * s),
                  LBCellText('SNAKE', cell: 9 * s, glow: true, semanticsLabel: 'Snake Classic'),
                  SizedBox(height: 14 * s),
                  ExcludeSemantics(
                    child: Text(
                      'CLASSIC',
                      style: LBText.label(p, color: p.lime.withValues(alpha: .75))
                          .copyWith(fontSize: 13, letterSpacing: 13),
                    ),
                  ),
                  const Spacer(flex: 4),
                  SizedBox(
                    width: 144 * s,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: _progress),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, v, _) => LBCellsBar(
                        count: 12,
                        value: v,
                        semanticsLabel: _stepTitle(l10n),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.lbSplashStatus(context.formatInt(pct)),
                      style: LBText.label(p, color: p.inkDim).copyWith(fontSize: 10),
                    ),
                  ),
                  SizedBox(height: 40 * s),
                  LBBlock(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Row(
                      children: [
                        const LBPixelIcon(LBIcon.flame, cell: 3.4, color: LB.gold, accent: LB.bonk),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${l10n.lbTipLabel} · ',
                                  style: TextStyle(color: p.head, fontWeight: FontWeight.w800),
                                ),
                                TextSpan(text: _tips(l10n)[_tipIndex]),
                              ],
                            ),
                            style: LBText.body(p, color: p.ink, size: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  Text(
                    l10n.lbSplashFooter(_version ?? ''),
                    style: LBText.label(p, color: p.inkDim.withValues(alpha: .3)).copyWith(fontSize: 8.5),
                  ),
                  SizedBox(height: 20 * s),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.lbGutter, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LBCellText('BONK!', cell: 10, color: LB.bonk, glow: true),
            const SizedBox(height: 20),
            Text(
              l10n.ldInitFailedUpper,
              textAlign: TextAlign.center,
              style: LBText.button(p, color: LB.bonk, size: 13),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.ldInitFailed(_errorMessage),
              textAlign: TextAlign.center,
              style: LBText.body(p, size: 11),
            ),
            if (_showRetryButton) ...[
              const SizedBox(height: 28),
              LBBlock(
                kind: LBBlockKind.fill,
                height: 58,
                alignment: Alignment.center,
                onTap: _retryInitialization,
                child: Text(l10n.ldRetryUpper, style: LBText.button(p, color: p.onLime, size: 14)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Initialization phases shown on the loading screen. Stored as a code so the
/// visible strings resolve against the ambient locale at render time.
enum _InitStep {
  initializing,
  core,
  profile,
  prefs,
  cloud,
  gameData,
  ads,
  audio,
  setup,
  welcome,
  ready,
  retrying,
}
