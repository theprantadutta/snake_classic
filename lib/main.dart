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
import 'package:material_ui/material_ui.dart' as material_ui;
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
import 'package:snake_classic/presentation/bloc/display/display_cubit.dart';
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
import 'package:snake_classic/services/existing_install_probe.dart';
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
    // Only if the router exists. A timeout during dependency injection —
    // before appRouter was assigned — would otherwise trade a frozen splash
    // for a LateInitializationError on the first build, which is not an
    // improvement. In that case fall through to the recovery screen, which
    // depends on nothing and offers a retry.
    _initSucceeded = _routerReady;

    // Fatal only when the timeout actually cost the user the app. Most of
    // what the bootstrap does is optional at launch (ad SDK, update check,
    // sync engine, token registration), so a timeout that still produced a
    // router means a degraded app the player can use — worth reporting, but
    // not a crash.
    await _reportStartupFailure(
      error,
      stackTrace,
      reason: 'Startup exceeded ${_bootstrapBudget.inSeconds}s',
      fatal: !_initSucceeded,
    );
  } catch (error, stackTrace) {
    // The app cannot start. This IS the crash, so it is reported as one.
    await _reportStartupFailure(
      error,
      stackTrace,
      reason: 'Failed to initialize Snake Classic',
      fatal: true,
    );
  }

  _installGlobalErrorHandlers();

  if (_initSucceeded) {
    runApp(const riverpod.ProviderScope(child: SnakeClassicApp()));
  } else {
    // Drop the native splash FIRST — otherwise the recovery screen renders
    // underneath it and the user still just sees a frozen launch image.
    FlutterNativeSplash.remove();
    runApp(const _StartupFailureApp());
  }
}

/// Send a startup failure to Crashlytics.
///
/// Goes to Crashlytics DIRECTLY rather than through [AppLogger]. Every
/// AppLogger method is wrapped in `if (kDebugMode)`, so in a release build
/// those calls compile to nothing — which is why the "Snake Classic couldn't
/// start" screen could be reproduced on a real device with an empty logcat
/// AND an empty Crashlytics dashboard. A failure that stops the app from
/// starting is the single most important thing to hear about, and it was the
/// only class of failure reporting nothing at all.
///
/// [fatal] distinguishes "the player did not get an app" from "the player got
/// a degraded one". Only the former should move the crash-free rate.
///
/// Deliberately carries no user identifiers or custom keys: the error and its
/// stack are what diagnose this, and a startup path that runs before consent
/// is the last place to be attaching anything about a person.
Future<void> _reportStartupFailure(
  Object error,
  StackTrace stackTrace, {
  required String reason,
  required bool fatal,
}) async {
  // Still logged for anyone attached to a debug session.
  AppLogger.error(reason, error, stackTrace);

  try {
    // If Firebase itself never came up, Crashlytics cannot be reached and
    // this failure is genuinely unreportable from the device. Nothing to do
    // but avoid throwing a second exception on top of the first.
    if (Firebase.apps.isEmpty) return;

    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  } catch (_) {
    // Reporting a startup failure must never become one.
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
    SupportedLocales.locales.map(
      (l) => initializeDateFormatting(l.languageCode),
    ),
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

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
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      kReleaseMode,
    );
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

    // Classify installs that predate those preferences. Runs here because it
    // needs Drift (already up, two statements above) and must land before the
    // router builds, for the same reason initialize() must: every first-run
    // gate reads the synchronous getters. Stamps itself, so this is a single
    // indexed read on every launch after the first.
    //
    // The evidence is deliberately local and durable — a statistics row with
    // games in it, or a high score on this device. Not the network, not "is
    // signed in": a restored cloud profile proves someone played, not that
    // THIS device ever did, and first-run state describes the device.
    await FirstRunService().migrateExistingInstall(
      () => hasLocalGameplayEvidence(getIt<AppDatabase>()),
    );

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
        AppLogger.warning(
          'Audio service init timed out — continuing without audio',
        );
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

    // Register the FCM handlers — onMessageOpenedApp, onMessage, and the local
    // notification tap callback. `requestPermission: false` means this fires
    // NO OS dialog; the permission soft-ask is still deferred to home, after
    // the player's first game.
    //
    // This MUST NOT be gated on anything. It used to be step 3 of the home
    // screen's onboarding prompt queue, and when that queue was deferred until
    // after the first game the tap listener went with it — so a player who had
    // not yet played had no onMessageOpenedApp handler at all, and tapping a
    // notification opened the app to whatever was last on screen and did
    // nothing else. Registering handlers and asking for permission are
    // different concerns and are now wired separately.
    unawaited(
      NotificationService()
          .initialize(requestPermission: false)
          .catchError(
            (Object e) =>
                AppLogger.error('Notification handler init failed', e),
          ),
    );

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
/// Whether an error is something the app recovers from, and therefore must not
/// be filed as a CRASH.
///
/// Crashlytics showed "Fatal Exception … HttpException: Connection closed
/// before full header was received, uri = https://lh3.googleusercontent.com/…"
/// — a user's Google profile picture failing to download. The app does not die
/// from that; the avatar just falls back. But the error surfaces through
/// FlutterError.reportError, the handler above filed EVERYTHING as fatal, and
/// so a flaky connection while a leaderboard scrolled registered as a crash.
///
/// It is not merely cosmetic. Those reports suppress the crash-free rate that
/// Play Console ranks on, and they bury real crashes in the issue list — the
/// replay-viewer fatal was sitting underneath exactly this kind of noise.
///
/// Note that every avatar in the app ALREADY passes onBackgroundImageError or
/// errorBuilder. Flutter routes an image failure to those listeners only if a
/// listener is still attached when it lands; if the widget was disposed first
/// (scrolled away, navigated off — precisely when slow images fail) the error
/// falls through to FlutterError instead. Handling it at the widget is
/// necessary but cannot be sufficient, which is why this classifier exists.
///
/// Deliberately string-based rather than `is SocketException` etc.: `dart:io`
/// is not web-safe and this file is shared with the web build. Deliberately
/// narrow, too — anything not positively identified stays fatal, because a
/// misfiled crash is far worse than a misfiled non-crash.
bool _isRecoverableError(Object error, {bool silent = false}) {
  // The framework's own verdict. `silent` marks errors it considers expected
  // and does not even print in debug — image decode/resolve failures set it.
  if (silent) return true;

  final type = error.runtimeType.toString();
  const recoverableTypes = {
    'NetworkImageLoadException', // HTTP status != 200 for an image
    'SocketException', // connection reset / no route / abort
    'HttpException', // truncated response, bad headers
    'HandshakeException', // TLS negotiation failed
    'ClientException', // package:http transport failure
    'TimeoutException', // a bounded wait elapsed
  };
  if (recoverableTypes.contains(type)) return true;

  // Fallback for wrapped/renamed transport errors that still name the host or
  // the failure in their message.
  final message = error.toString();
  return message.contains('lh3.googleusercontent.com') ||
      message.contains('Connection closed before full header was received');
}

void _installGlobalErrorHandlers() {
  if (kReleaseMode) {
    // Flutter framework errors → Crashlytics, classified.
    FlutterError.onError = (details) {
      AppLogger.error('Flutter Error', details.exception, details.stack);
      if (_isRecoverableError(details.exception, silent: details.silent)) {
        // Still reported, so the volume stays visible — just not as a crash.
        FirebaseCrashlytics.instance.recordError(
          details.exception,
          details.stack,
          reason: 'recoverable: ${details.library ?? 'flutter'}',
          fatal: false,
        );
      } else {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };
    // Async errors thrown outside the Flutter framework (PlatformDispatcher).
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: !_isRecoverableError(error),
      );
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
      runApp(const riverpod.ProviderScope(child: SnakeClassicApp()));
      return;
    } catch (error, stackTrace) {
      // Non-fatal on purpose: the initial failure was already reported as
      // fatal for this session, and marking every retry fatal too would let
      // one stuck user tap the button repeatedly and bury the crash-free
      // rate. The separate reason keeps retries visible as their own signal —
      // "the retry never works" is a different bug from "startup failed once".
      await _reportStartupFailure(
        error,
        stackTrace,
        reason: 'Startup retry failed',
        fatal: false,
      );
    }
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Same reason as the main app below. The recovery screen is the one
      // surface that must never fail to render, so it does not get to skip
      // the delegates just because it is plain.
      localizationsDelegates: const [
        ...material_ui.GlobalMaterialLocalizations.delegates,
      ],
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
      // Android drops the window's preferred display mode when the app is
      // backgrounded, so re-assert it rather than silently sliding to 60 Hz
      // for the rest of the session.
      unawaited(getIt<DisplayCubit>().apply());
      // A silently-cancelled Play billing sheet emits no purchaseStream event,
      // so clear any stuck "Verifying…" state now that we're back in front.
      PurchaseService().notifyAppResumed();
      // Force the CANONICAL drain, then the legacy FCM queue.
      //
      // Resume used to call only DataSyncService, which no longer owns the
      // data anyone means by "sync" — so coming back to the app did not push
      // the outbox that actually held the player's scores and coins.
      unawaited(getIt<SyncEngine>().syncNow());
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
      unawaited(getIt<SyncEngine>().syncNow());
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
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
        // Display — reads the stored high-refresh-rate opt-in and asks the
        // platform for it. Provided app-wide (not just on the settings
        // screen) because the opt-in has to be applied at launch.
        BlocProvider<DisplayCubit>.value(
          value: getIt<DisplayCubit>()..initialize(),
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
      // Flutter's delegates, plus material_ui's own. go_router 18 has moved
      // to package:material_ui, whose MaterialLocalizations is a DIFFERENT
      // Dart type that flutter_localizations cannot satisfy — so both sets
      // have to be registered or any material_ui widget in the tree throws
      // "No MaterialLocalizations found" at runtime. Both coexist happily,
      // and material_ui ships 80 locales, so this costs no coverage.
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        ...material_ui.GlobalMaterialLocalizations.delegates,
      ],
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
        final osScale = mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.2);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(baseScale * osScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: themeState.currentTheme.backgroundColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false,
        // No ink ripples anywhere in the game.
        //
        // The expanding grey circle is an Android convention for
        // documents and settings, not for games — nothing in an
        // arcade splashes when you press it, and on a themed dark
        // surface it reads as a rendering artefact rather than as
        // feedback. Set here rather than on individual widgets so a
        // new button cannot reintroduce it by default.
        //
        // Buttons, tabs and icon buttons each resolve their own
        // overlay independently of splashFactory, so every one of
        // them has to be told as well.
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
        tabBarTheme: TabBarThemeData(
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
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
