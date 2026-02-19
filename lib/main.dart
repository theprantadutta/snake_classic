import 'package:firebase_core/firebase_core.dart';
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
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/app_router.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/auth_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/in_app_update_service.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/preferences_service.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/logger.dart';
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
    // Hide status bar but keep navigation area for back gesture
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

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

    // Fire-and-forget — don't block startup
    NotificationService().initialize().then((_) {
      AppLogger.success('Notification service initialized');
    }).catchError((e) {
      AppLogger.error('Notification service init failed', e);
    });

    InAppUpdateService().checkForUpdate().then((_) {
      AppLogger.success('In-app update check completed');
    });

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

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initSucceeded = true;
    AppLogger.success('Snake Classic ready to launch!');
  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize Snake Classic', error, stackTrace);
  }

  // Setup global error handling — always, not just in debug mode
  FlutterError.onError = (details) {
    AppLogger.error('Flutter Error', details.exception, details.stack);
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

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
      // Trigger sync when app comes back to foreground
      DataSyncService().forceSyncNow();
      // Re-authenticate with backend if JWT expired and refresh premium state
      _refreshOnResume();
    }

    // When app goes to background, attempt to sync pending data
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      DataSyncService().forceSyncNow();
    }
  }

  /// Ensure backend auth is fresh and sync premium/subscription status.
  Future<void> _refreshOnResume() async {
    try {
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
    // Hide status bar but keep navigation area accessible for back gesture
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
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
      ],
      // MultiProvider for core services that are not Cubits
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UnifiedUserService(),
            lazy: false,
          ),
          ChangeNotifierProvider(create: (_) => DataSyncService(), lazy: false),
          ChangeNotifierProvider(
            create: (_) => PreferencesService(),
            lazy: false,
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'Snake Classic',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
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
            );
          },
        ),
      ),
    );
  }
}
