import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/database/legacy_prefs_import.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/app_router.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/analytics_route_observer.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/auth_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/in_app_update_service.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/sync/sync_engine.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';
// import 'package:snake_classic/utils/performance_monitor.dart'; // temporarily disabled

import 'firebase_options.dart';

/// Whether critical init succeeded. If false, show an error screen.
bool _initSucceeded = false;

void main() async {
  // Ensure Flutter is initialized and preserve splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppLogger.lifecycle('Snake Classic starting up...');

  try {
    // Edge-to-edge mode for Android 15+ compliance. Content draws under the
    // (translucent) status + nav bars; SafeArea widgets on each screen handle
    // the inset padding. SystemUiMode.manual previously used here routed
    // through Flutter's deprecated setStatusBarColor / setNavigationBarColor
    // path which triggers Play Console's "deprecated APIs for edge-to-edge"
    // warning — see flutter/flutter#183372. The active game screen still
    // goes full-immersive via immersiveSticky (handled in GameScreen).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    // Load environment variables
    AppLogger.info('Loading environment variables...');
    await dotenv.load(fileName: '.env');
    AppLogger.success('Environment variables loaded');

    // Initialize Firebase
    AppLogger.firebase('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.success('Firebase initialized successfully');

    // Crashlytics: collect and upload crash reports in production builds only.
    // Gated on kReleaseMode so debug AND profile builds never send data to the
    // dashboard (keeps local crashes/errors out of production analytics).
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(kReleaseMode);
    AppLogger.success(
      'Crashlytics collection ${kReleaseMode ? 'enabled' : 'disabled (non-release build)'}',
    );

    // Set preferred orientations
    AppLogger.ui('Setting device orientation...');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize dependency injection
    AppLogger.info('Configuring dependencies...');
    await configureDependencies();
    AppLogger.success('Dependencies configured');

    // One-time SharedPrefs→Drift settings import (theme/trail/notification
    // opt-ins). Must run after the DB is up but before anything reads
    // settings — AudioService, ThemeCubit, and NotificationService all
    // hydrate from the Drift row this writes.
    await runLegacyPrefsImport(getIt<AppDatabase>());

    // Initialize router with analytics observer
    appRouter = createAppRouter(
      observers: [AnalyticsRouteObserver(getIt<AnalyticsFacade>())],
    );

    // Track app open (fire-and-forget)
    unawaited(getIt<AnalyticsFacade>().trackAppOpened());

    // Initialize independent services in parallel for faster startup
    // Note: PurchaseService.initialize() is NOT called here because
    // PremiumCubit.initialize() already calls it. Calling it twice would
    // double-subscribe to the purchase stream.
    AppLogger.info('Initializing services...');
    await AudioService().initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        AppLogger.warning('Audio service init timed out — continuing without audio');
      },
    );
    AppLogger.success('Audio service initialized');

    // NotificationService.initialize() is no longer called here — it
    // requests the OS notification permission as a side effect, and
    // showing that dialog before the user has seen the app would feel
    // intrusive. The call has moved to home_screen.dart's initState,
    // so the request only fires once the user has actually landed on
    // home and signed in (if applicable).
    //
    // The TOKEN, however, doesn't need any permission — so bootstrap it
    // here. Without this, token registration depended on the user
    // reaching home and keeping it mounted for 1.5s; a kill before that
    // meant the install stayed invisible to the backend for the whole
    // session. Fire-and-forget; the home-screen init repeats the fetch
    // idempotently if this loses a race.
    unawaited(NotificationService().bootstrapToken());

    InAppUpdateService().checkForUpdate().then((_) {
      AppLogger.success('In-app update check completed');
    });

    // Initialize ads (UMP consent + ATT + SDK). Fire-and-forget — the service
    // is mobile-only, Pro-gated, and self-disables on web/desktop or for Pro.
    unawaited(getIt<AdService>().initialize());

    AppLogger.success('All critical services initialized');

    // Wire up PurchaseService.setUserIdGetter so backend verification
    // includes the real user ID instead of 'anonymous_user'.
    PurchaseService().setUserIdGetter(() {
      return ApiService().currentUserId;
    });
    AppLogger.info('Purchase service user ID getter wired');

    // Wire ApiService.onUnauthorized to trigger re-authentication
    ApiService().onUnauthorized = () {
      AppLogger.warning('JWT expired — will re-authenticate on next API call');
      // AuthService.ensureBackendAuthentication() is called on app resume
      // and before critical API calls, so we just clear the token here.
    };

    // Boot the outbox drain engine. It owns the SyncQueue → backend
    // batch sync. Gated internally on auth + connectivity AND on the
    // first-sign-in restore having settled, so it's safe to fire
    // before sign-in completes — the drain stays asleep until
    // maybeRunFirstSignInPull arms it.
    unawaited(getIt<SyncEngine>().initialize(getIt<AppDatabase>()));

    // Hand the root navigator key to the engine so it can imperatively
    // insert the first-sign-in OverlayEntry above whatever route is
    // active when sign-in fires (could be a login screen, but could
    // also be ProfileScreen's "Save your progress" upgrade flow).
    getIt<SyncEngine>().attachNavigatorKey(rootNavigatorKey);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initSucceeded = true;
    AppLogger.success('Snake Classic ready to launch!');
  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize Snake Classic', error, stackTrace);
  }

  // Setup global error handling. In production (release) builds, fatal errors
  // are forwarded to Crashlytics; in debug/profile they only get logged (and
  // presented on the red screen) so nothing pollutes the production dashboard.
  if (kReleaseMode) {
    // Fatal Flutter framework errors → Crashlytics.
    FlutterError.onError = (details) {
      AppLogger.error('Flutter Error', details.exception, details.stack);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    // Async errors thrown outside the Flutter framework (PlatformDispatcher).
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    FlutterError.onError = (details) {
      AppLogger.error('Flutter Error', details.exception, details.stack);
      FlutterError.presentError(details);
    };
  }

  if (_initSucceeded) {
    runApp(
      const riverpod.ProviderScope(
        child: SnakeClassicApp(),
      ),
    );
  } else {
    // Critical init failed — show a minimal error screen instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to start Snake Classic',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the app. If this persists, try reinstalling.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SnakeClassicApp extends StatefulWidget {
  const SnakeClassicApp({super.key});

  @override
  State<SnakeClassicApp> createState() => _SnakeClassicAppState();
}

class _SnakeClassicAppState extends State<SnakeClassicApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setImmersiveMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-apply immersive mode when app resumes
    if (state == AppLifecycleState.resumed) {
      _setImmersiveMode();
      // A silently-cancelled Play billing sheet emits no purchaseStream event,
      // so clear any stuck "Verifying…" state now that we're back in front.
      PurchaseService().notifyAppResumed();
      // Trigger sync when app comes back to foreground
      DataSyncService().forceSyncNow();
      // Re-authenticate with backend if JWT expired and refresh premium state
      _refreshOnResume();
      // Show an App Open ad on a genuine return to the foreground. Self-gated:
      // skips cold start, active gameplay, purchase/consent returns, Pro, and
      // when another full-screen ad is up.
      unawaited(getIt<AdService>().maybeShowAppOpenOnResume());
    }

    // When app goes to background, attempt to sync pending data
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      DataSyncService().forceSyncNow();
      // Mark the background trip and warm up an App Open ad for the next resume.
      getIt<AdService>().markBackgrounded();
      getIt<AdService>().preloadAppOpen();
    }
  }

  /// Ensure backend auth is fresh and sync premium/subscription status.
  Future<void> _refreshOnResume() async {
    try {
      // Network-independent first: if the locally-stored (server-authoritative)
      // subscription expiry has already passed, drop to free right now —
      // don't wait on connectivity or a successful backend round-trip.
      await getIt<PremiumCubit>().recheckLocalExpiry();
      await AuthService().ensureBackendAuthentication();
      // Retry any pending offline purchases
      await PurchaseService().retryPendingVerifications();
      // Sync premium entitlements (catches subscription renewals/cancellations)
      getIt<PremiumCubit>().syncWithBackend();
    } catch (e) {
      AppLogger.error('Error refreshing on resume', e);
    }
  }

  void _setImmersiveMode() {
    // Re-apply the edge-to-edge defaults on app resume. Same rationale as
    // the bootstrap setup above — manual mode triggers the deprecated
    // setStatusBarColor path Play Console flags.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider for all Cubit-based state management
    return MultiBlocProvider(
      providers: [
        // Auth & User
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..initialize(),
        ),
        // Theme
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>()..initialize(),
        ),
        // Game Settings & Game
        BlocProvider<GameSettingsCubit>(
          create: (_) => getIt<GameSettingsCubit>()..initialize(),
        ),
        BlocProvider<GameCubit>(
          create: (_) => getIt<GameCubit>()..initialize(),
        ),
        // Coins
        BlocProvider<CoinsCubit>(
          create: (_) => getIt<CoinsCubit>()..initialize(),
        ),
        // Multiplayer
        BlocProvider<MultiplayerCubit>(
          create: (_) => getIt<MultiplayerCubit>(),
        ),
        // Premium & Battle Pass
        BlocProvider<PremiumCubit>.value(
          value: getIt<PremiumCubit>()..initialize(),
        ),
        BlocProvider<BattlePassCubit>.value(
          value: getIt<BattlePassCubit>()..initialize(),
        ),
        // Pre-game power-up inventory (coin-purchased, server-backed)
        BlocProvider<PowerUpCubit>.value(
          value: getIt<PowerUpCubit>()..loadInventory(),
        ),
      ],
      // MultiProvider for core services that are not Cubits
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UnifiedUserService(),
            lazy: false,
          ),
          ChangeNotifierProvider(create: (_) => DataSyncService(), lazy: false),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'Snake Classic',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              // Root text scaling. The app's typography uses fixed fontSize
              // values with no scaling of its own, so we adjust the effective
              // text scale here in one place:
              //  - Tablets get a modest base bump so text grows with the
              //    larger UI (phones use 1.0 → unchanged).
              //  - The OS accessibility factor is respected but clamped so an
              //    extreme system font setting can't break the fixed layout.
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final baseScale = context.responsive<double>(
                  phone: 1.0,
                  tablet: 1.12,
                  largeTablet: 1.18,
                );
                final osScale =
                    mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.2);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(baseScale * osScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              theme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor:
                    themeState.currentTheme.backgroundColor,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                useMaterial3: false,
                textTheme: GameTypography.createTextTheme(
                  color: themeState.currentTheme.accentColor,
                ),
              ),
              // The first-sign-in cloud-restore overlay is mounted on the
              // three screens the restore can possibly be active on
              // (LoadingScreen / FirstTimeAuthScreen / EmailAuthScreen),
              // not globally — once the user lands on home, restore is
              // already done and the home tree shouldn't carry the
              // subscription.
            );
          },
        ),
      ),
    );
  }
}
