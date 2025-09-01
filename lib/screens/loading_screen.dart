import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/services/guest_user_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/widgets/animated_snake_logo.dart';
import 'package:snake_classic/utils/constants.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  
  String _currentTask = 'Initializing Snake Classic...';
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _logoController.repeat();
    
    // Start the initialization process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      
      // Step 1: Initialize Guest User System
      await _updateProgress(0.1, 'Setting up user profile...');
      await _initializeGuestUser(userProvider);
      
      // Step 2: Initialize Theme System
      await _updateProgress(0.25, 'Loading visual themes...');
      await themeProvider.initialize();
      
      // Step 3: Initialize Statistics Service
      await _updateProgress(0.45, 'Loading game statistics...');
      await _initializeStatistics();
      
      // Step 4: Initialize Achievement System
      await _updateProgress(0.65, 'Checking achievements...');
      await _initializeAchievements();
      
      // Step 5: Initialize Audio System
      await _updateProgress(0.85, 'Configuring audio system...');
      await _initializeAudio();
      
      // Step 6: Final preparation
      await _updateProgress(1.0, 'Almost ready to play!');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigation to Home Screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
      
    } catch (error) {
      _handleError('Failed to initialize app: $error');
    }
  }

  Future<void> _initializeGuestUser(UserProvider userProvider) async {
    try {
      final guestService = GuestUserService();
      await guestService.initialize();
      
      // Check if we already have a user (guest or authenticated)
      if (!userProvider.isSignedIn) {
        // Create or load guest user
        final guestUser = await guestService.getOrCreateGuestUser();
        
        // Update UserProvider with guest user info
        await userProvider.setGuestUser(guestUser);
      }
    } catch (e) {
      // If guest user creation fails, we can continue with anonymous mode
      // This ensures the app doesn't break if there are storage issues
      print('Warning: Guest user initialization failed: $e');
    }
  }

  Future<void> _initializeStatistics() async {
    try {
      final statisticsService = StatisticsService();
      await statisticsService.initialize();
    } catch (e) {
      print('Warning: Statistics initialization failed: $e');
    }
  }

  Future<void> _initializeAchievements() async {
    try {
      final achievementService = AchievementService();
      await achievementService.initialize();
    } catch (e) {
      print('Warning: Achievement system initialization failed: $e');
    }
  }

  Future<void> _initializeAudio() async {
    try {
      final audioService = AudioService();
      await audioService.initialize();
    } catch (e) {
      print('Warning: Audio system initialization failed: $e');
    }
  }

  Future<void> _updateProgress(double progress, String message) async {
    if (!mounted) return;
    
    setState(() {
      _progress = progress;
      _currentTask = message;
    });
    
    _progressController.reset();
    _progressController.forward();
    
    // Add a small delay to make the progress feel natural
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _handleError(String error) {
    if (!mounted) return;
    
    setState(() {
      _hasError = true;
      _errorMessage = error;
    });
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _progress = 0.0;
      _currentTask = 'Retrying initialization...';
    });
    
    await _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  theme.accentColor.withValues(alpha: 0.15),
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.9),
                  Colors.black.withValues(alpha: 0.1),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
            child: SafeArea(
              child: _hasError ? _buildErrorView(theme) : _buildLoadingView(theme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingView(GameTheme theme) {
    return Column(
      children: [
        const Spacer(flex: 2),
        
        // Animated Logo Section
        SizedBox(
          width: 120,
          height: 120,
          child: AnimatedSnakeLogo(
            theme: theme,
            controller: _logoController,
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Title
        Text(
          'SNAKE CLASSIC',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: theme.accentColor,
            letterSpacing: 3,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
        
        const SizedBox(height: 8),
        
        Text(
          'Premium Snake Experience',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: theme.accentColor.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 700.ms),
        
        const Spacer(flex: 3),
        
        // Progress Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Progress Bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: theme.backgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Current Task
              Text(
                _currentTask,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Progress Percentage
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.accentColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5),
        
        const Spacer(flex: 2),
        
        // Loading Animation
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  shape: BoxShape.circle,
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).fadeIn(
                delay: Duration(milliseconds: index * 200),
                duration: 600.ms,
              ).then(
                delay: 200.ms,
              ).fadeOut(duration: 600.ms);
            }),
          ),
        ),
        
        const Spacer(),
      ],
    );
  }

  Widget _buildErrorView(GameTheme theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Error Title
        Text(
          'Initialization Failed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Error Message
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Retry Button
        ElevatedButton(
          onPressed: _retryInitialization,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh),
              const SizedBox(width: 8),
              Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}