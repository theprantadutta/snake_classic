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
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/supported_locales.dart';
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
import 'package:snake_classic/services/first_run_service.dart';
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

/// Whether critical init succeeded. If false, show the recovery screen.
bool _initSucceeded = false;

/// Whether [appRouter] has been assigned. It is `late final`, so the real app
/// cannot be started before this is true without throwing
/// LateInitializationError on the very first build.
bool _routerReady = false;

/// Whether DI has been configured. get_it throws on re-registering an existing
/// singleton, so the retry path must not run [configureDependencies] twice.
bool _dependenciesReady = false;

/// Hard ceiling on startup.
///
/// Individual steps have their own timeouts, but a step that hangs WITHOUT
/// throwing — a socket that neither completes nor resets, a plugin that never
/// calls back, a platform channel that stalls — would otherwise block runApp
/// forever. This bounds the whole sequence so we always reach a rendered
/// frame. Generous on purpose: a slow cold start on a cheap device over 2G is
/// normal and should still complete properly. This is a backstop for
/// genuinely stuck, not merely slow.
const Duration _bootstrapBudget = Duration(seconds: 25);

void main() async {
  // Ensure Flutter is initialized and preserve splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // EVERY path out of main() must reach runApp().
  //
  // FlutterNativeSplash.preserve() above holds the NATIVE launch image on
  // screen until something explicitly removes it, and the only remove() call
  // is in LoadingScreen.initState. So if Dart-side startup throws or hangs
  // before that screen mounts, the launch image simply stays: no error, no
  // retry, no way out but a force stop — and no code running to report it.
  // That is the "stuck on the splash screen" report.
  //
  // Hence: the bootstrap is bounded by a timeout, every failure is caught,
  // and the app starts regardless of which of those happened.
  try {
    await _bootstrap().timeout(_bootstrapBudget);
    _initSucceeded = true;
    AppLogger.success('Snake Classic ready to launch!');
  } on TimeoutException catch (error, stackTrace) {
    // Deliberately NOT fatal. Most of what the bootstrap does is optional at
    // launch (ad SDK, update check, sync engine, token registration), and the
    // parts that are not have already thrown by now if they were going to.
    // A degraded app the user can play beats a frozen launch image.
    AppLogger.error(
      'Startup exceeded ${_bootstrapBudget.inSeconds}s — launching anyway',
      error,
      stackTrace,
    );
    // Only if the router exists. A timeout during dependency injection —
    // before appRouter was assigned — would otherwise trade a frozen splash
    // for a LateInitializationError on the first build, which is not an
    // improvement. In that case fall through to the recovery screen, which
    // depends on nothing and offers a retry.
    _initSucceeded = _routerReady;
  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize Snake Classic', error, stackTrace);
  }

  _installGlobalErrorHandlers();

  if (_initSucceeded) {
    runApp(
      const riverpod.ProviderScope(
        child: SnakeClassicApp(),
      ),
    );
  } else {
    // Drop the native splash FIRST — otherwise the recovery screen renders
    // underneath it and the user still just sees a frozen launch image.
    FlutterNativeSplash.remove();
    runApp(const _StartupFailureApp());
  }
}

/// Everything that must happen before the app can render.
///
/// Extracted from main() so the whole sequence can carry one timeout. The
/// locale date symbols now load in here too: they used to run OUTSIDE main()'s
/// try/catch, so a failure there killed startup before any handler could see
/// it — the frozen-splash case exactly.
Future<void> _bootstrap() async {
  // Date symbols for every supported locale, so DateFormat/NumberFormat in
  // lib/utils/formatting.dart work regardless of the user's language.
  await Future.wait(
    SupportedLocales.locales
        .map((l) => initializeDateFormatting(l.languageCode)),
  );

  // Orbitron + Rajdhani are bundled as assets (see assets/fonts/ and
  // pubspec.yaml). Disable runtime fetching so google_fonts NEVER reaches out
  // to fonts.gstatic.com — the app renders correctly fully offline, and we no
  // longer crash on "Connection closed before full header was received".
  GoogleFonts.config.allowRuntimeFetching = false;

  AppLogger.lifecycle('Snake Classic starting up...');

  {
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

    // Initialize Firebase. Guarded on Firebase.apps because _bootstrap can run
    // a SECOND time from the recovery screen's Try again — a repeat
    // initializeApp throws [core/duplicate-app], which would make the retry
    // button permanently useless for anyone whose first attempt got this far.
    AppLogger.firebase('Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.success('Firebase initialized successfully');
    } else {
      AppLogger.info('Firebase already initialized — reusing existing app');
    }

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

    // Register the bundled fonts' OFL licenses so they appear in
    // showLicensePage / AboutDialog. The .txt files shipped as assets
    // for a while with nothing reading them — this makes them count.
    LicenseRegistry.addLicense(() async* {
      for (final f in ['OFL-Orbitron.txt', 'OFL-Rajdhani.txt']) {
        final text = await rootBundle.loadString('assets/fonts/$f');
        yield LicenseEntryWithLineBreaks(['google_fonts'], text);
      }
    });

    // Initialize dependency injection. Also guarded for the retry path —
    // get_it throws on re-registering an existing singleton.
    if (!_dependenciesReady) {
      AppLogger.info('Configuring dependencies...');
      await configureDependencies();
      _dependenciesReady = true;
      AppLogger.success('Dependencies configured');
    } else {
      AppLogger.info('Dependencies already configured — skipping');
    }

    // One-time SharedPrefs→Drift settings import (theme/trail/notification
    // opt-ins). Must run after the DB is up but before anything reads
    // settings — AudioService, ThemeCubit, and NotificationService all
    // hydrate from the Drift row this writes.
    await runLegacyPrefsImport(getIt<AppDatabase>());

    // First-run state (install stamp + games-started count). Must be awaited
    // BEFORE the router is built: LoadingScreen's routing decision and every
    // first-run gate downstream read its synchronous getters, and those fail
    // safe to "fully onboarded" when uninitialized — so a late init would
    // silently show veteran UI to a brand-new player. Cheap: one prefs read.
    await FirstRunService().initialize();

    // Initialize router with analytics observer. `appRouter` is `late final`,
    // so this must run exactly once: SnakeClassicApp throws
    // LateInitializationError if it builds before the assignment, and the
    // assignment itself throws if repeated on a retry.
    if (!_routerReady) {
      appRouter = createAppRouter(
        observers: [AnalyticsRouteObserver(getIt<AnalyticsFacade>())],
      );
      _routerReady = true;
    }

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
  }
}

/// Global error handling. In production (release) builds, fatal errors are
/// forwarded to Crashlytics; in debug/profile they only get logged (and
/// presented on the red screen) so nothing pollutes the production dashboard.
///
/// Installed on every path, including a failed bootstrap — a build that could
/// not start is exactly the one whose errors we most want reported.
void _installGlobalErrorHandlers() {
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

}

/// Last-resort UI when [_bootstrap] failed outright.
///
/// Deliberately depends on NOTHING the bootstrap sets up — no DI, no router,
/// no theme, no localisations. If any of those were available the real app
/// would be running instead, and a fallback that needs the thing which just
/// broke is not a fallback.
///
/// It also offers a real way forward instead of telling the user to reinstall.
/// Most startup failures are transient (a cold database file, a Firebase
/// handshake over a flaky connection), so retrying in-process usually works —
/// and costs one tap rather than a reinstall and their entire local save.
class _StartupFailureApp extends StatefulWidget {
  const _StartupFailureApp();

  @override
  State<_StartupFailureApp> createState() => _StartupFailureAppState();
}

class _StartupFailureAppState extends State<_StartupFailureApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await _bootstrap().timeout(_bootstrapBudget);
      _initSucceeded = true;
      AppLogger.success('Startup retry succeeded — starting the app');
      // Swap the whole tree for the real app. runApp on an already-running
      // binding replaces the root widget, so this is a live recovery rather
      // than a restart and nothing stored locally is lost.
      runApp(
        const riverpod.ProviderScope(
          child: SnakeClassicApp(),
        ),
      );
      return;
    } catch (error, stackTrace) {
      AppLogger.error('Startup retry failed', error, stackTrace);
    }
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                  "Snake Classic couldn't start",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is usually temporary. Your saved games are safe.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 48,
                  child: _retrying
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                          ),
                        ),
                ),
              ],
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
      // The player came back on their own, so the pending Day-1 comeback nudge
      // has nothing left to do — firing it later would just be nagging someone
      // who already returned. Re-armed on the next game over.
      unawaited(NotificationService().cancelDayOneReminder());
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
            return BlocBuilder<GameSettingsCubit, GameSettingsState>(
              buildWhen: (prev, curr) => prev.localeCode != curr.localeCode,
              builder: (context, settingsState) {
                return _buildApp(context, themeState, settingsState);
              },
            );
          },
        ),
      ),
    );
  }

  /// The locale MaterialApp will settle on, computed before it exists.
  ///
  /// An explicit pick from settings wins; otherwise this runs the same
  /// device-language matching MaterialApp uses, so the theme's typography is
  /// built for the language the user is actually about to see.
  static Locale _resolvedLocale(String? localeCode) =>
      SupportedLocales.fromCode(localeCode) ??
      basicLocaleListResolution(
        WidgetsBinding.instance.platformDispatcher.locales,
        SupportedLocales.locales,
      );

  Widget _buildApp(
    BuildContext context,
    ThemeState themeState,
    GameSettingsState settingsState,
  ) {
    return MaterialApp.router(
              title: 'Snake Classic',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              // i18n: generated from lib/l10n/*.arb (see l10n.yaml). A null
              // locale follows the device language; unsupported device
              // languages resolve to English via the default resolution.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: SupportedLocales.locales,
              locale: SupportedLocales.fromCode(settingsState.localeCode),
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
                  // Devanagari and Arabic can't take the display letter
                  // spacing the Latin styles use — see letterSpacingFor.
                  // This builds the theme ABOVE MaterialApp, so there is no
                  // Localizations to read yet; mirror the same resolution
                  // MaterialApp is about to do so the theme and the widget
                  // tree agree on the language.
                  locale: _resolvedLocale(settingsState.localeCode),
                ),
              ),
              // The first-sign-in cloud-restore overlay is mounted on the
              // three screens the restore can possibly be active on
              // (LoadingScreen / FirstTimeAuthScreen / EmailAuthScreen),
              // not globally — once the user lands on home, restore is
              // already done and the home tree shouldn't carry the
              // subscription.
    );
  }
}
