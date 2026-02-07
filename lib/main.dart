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
import 'package:snake_classic/services/audio_service.dart';
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
    AppLogger.info('Initializing services in parallel...');
    await Future.wait([
      AudioService().initialize().then((_) {
        AppLogger.success('Audio service initialized');
      }),
      NotificationService().initialize().then((_) {
        AppLogger.success('Notification service initialized');
      }),
      PurchaseService().initialize().then((_) {
        AppLogger.success('Purchase service initialized');
      }),
      InAppUpdateService().checkForUpdate().then((_) {
        AppLogger.success('In-app update check completed');
      }),
    ]);
    AppLogger.success('All services initialized');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Start performance monitoring (temporarily disabled)
    // if (kDebugMode) {
    //   AppLogger.info('Starting performance monitoring...');
    //   PerformanceMonitor().startMonitoring();
    //   AppLogger.success('Performance monitoring started');
    // }

    AppLogger.success('Snake Classic ready to launch!');
  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize Snake Classic', error, stackTrace);
  }

  // Setup global error handling
  if (kDebugMode) {
    FlutterError.onError = (details) {
      AppLogger.error('Flutter Error', details.exception, details.stack);
      FlutterError.presentError(details);
    };
  }

  runApp(
    const riverpod.ProviderScope(
      child: SnakeClassicApp(),
    ),
  ); // .withPerformanceMonitoring() temporarily disabled
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
    }

    // When app goes to background, attempt to sync pending data
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      DataSyncService().forceSyncNow();
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
        BlocProvider<PremiumCubit>(
          create: (_) => getIt<PremiumCubit>()..initialize(),
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
