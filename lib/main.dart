import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/coins_provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/multiplayer_provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/loading_screen.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/navigation_service.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/preferences_service.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/logger.dart';
// import 'package:snake_classic/utils/performance_monitor.dart'; // temporarily disabled
import 'package:talker_flutter/talker_flutter.dart';

import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized and preserve splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  AppLogger.lifecycle('Snake Classic starting up...');

  try {
    // Initialize system UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

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

    // Initialize audio service
    AppLogger.audio('Initializing audio service...');
    await AudioService().initialize();
    AppLogger.success('Audio service initialized');

    // Initialize notification service
    AppLogger.info('Initializing notification service...');
    await NotificationService().initialize();
    AppLogger.success('Notification service initialized');

    // Initialize purchase service
    AppLogger.info('Initializing purchase service...');
    await PurchaseService().initialize();
    AppLogger.success('Purchase service initialized');

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

  runApp(const SnakeClassicApp()); // .withPerformanceMonitoring() temporarily disabled
}

class SnakeClassicApp extends StatelessWidget {
  const SnakeClassicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        ChangeNotifierProvider(
          create: (_) => UnifiedUserService(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => DataSyncService(), lazy: false),
        ChangeNotifierProvider(
          create: (_) => PreferencesService(),
          lazy: false,
        ),

        // UI Providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
        ChangeNotifierProvider(create: (_) => CoinsProvider()),
        ChangeNotifierProvider(
          create: (_) => PremiumProvider(PurchaseService()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Snake Classic',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            navigatorObservers: [
              if (kDebugMode) TalkerRouteObserver(AppLogger.instance),
            ],
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor:
                  themeProvider.currentTheme.backgroundColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: false,
              fontFamily: 'monospace',
            ),
            home: const LoadingScreen(),
          );
        },
      ),
    );
  }
}
