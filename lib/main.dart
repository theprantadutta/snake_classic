import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize audio service
  await AudioService().initialize();
  
  runApp(const SnakeClassicApp());
}

class SnakeClassicApp extends StatelessWidget {
  const SnakeClassicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Snake Classic',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: themeProvider.currentTheme.backgroundColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: false,
              fontFamily: 'monospace',
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
