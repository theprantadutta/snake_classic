import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/first_time_auth_screen.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/preferences_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/animated_snake_logo.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  String _currentTask = 'Initializing Snake Classic...';
  String _subTask = '';
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showRetryButton = false;

  // Game-like loading elements
  final List<LoadingParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Start animations
    _logoController.repeat();
    _particleController.repeat();
    _pulseController.repeat();

    // Generate particles for game-like effect
    _generateParticles();

    // Start the initialization process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        LoadingParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.2 + _random.nextDouble() * 0.3,
          size: 2 + _random.nextDouble() * 4,
          opacity: 0.3 + _random.nextDouble() * 0.4,
        ),
      );
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize Core Services
      await _updateProgress(
        0.1,
        'Initializing core systems...',
        'Setting up Server connection',
      );
      await _initializeCoreServices();

      // Step 2: Initialize User System
      await _updateProgress(
        0.25,
        'Creating your player profile...',
        'Generating unique username',
      );
      await _initializeUserSystem();

      // Step 3: Load User Preferences
      await _updateProgress(
        0.4,
        'Loading your preferences...',
        'Syncing themes and settings',
      );
      await _initializePreferences();

      // Step 4: Initialize Game Data
      await _updateProgress(
        0.55,
        'Loading game statistics...',
        'Calculating your progress',
      );
      await _initializeStatistics();

      // Step 5: Initialize Achievement System
      await _updateProgress(
        0.7,
        'Checking achievements...',
        'Unlocking rewards',
      );
      await _initializeAchievements();

      // Step 6: Initialize Audio System
      await _updateProgress(
        0.85,
        'Configuring audio system...',
        'Loading sound effects',
      );
      await _initializeAudio();

      // Step 7: Final Sync
      await _updateProgress(
        0.95,
        'Syncing with cloud...',
        'Ensuring data is up to date',
      );
      await _performFinalSync();

      // Step 8: Check for first-time user
      await _updateProgress(0.98, 'Checking setup status...', 'Almost ready!');

      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final isFirstTime = await userProvider.isFirstTimeUser();

        if (isFirstTime) {
          await _updateProgress(1.0, 'Welcome!', 'Choose how to continue');
          await Future.delayed(const Duration(milliseconds: 800));

          // Navigate to first-time auth screen
          if (!mounted) {
            return;
          }
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const FirstTimeAuthScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
          return;
        }
      }

      // Step 9: Complete (for returning users)
      await _updateProgress(
        1.0,
        'Ready to play!',
        'Welcome back to Snake Classic',
      );
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigation to Home Screen with smooth transition (returning users)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (error) {
      _handleError('Initialization failed: $error');
    }
  }

  Future<void> _initializeCoreServices() async {
    try {
      AppLogger.lifecycle('Initializing core services');
      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          // Initialize Firebase and core services here
          await Future.delayed(
            const Duration(milliseconds: 300),
          ); // Simulate work
        }),
      ]);
    } catch (e) {
      AppLogger.error('Core services initialization warning', e);
    }
  }

  Future<void> _initializeUserSystem() async {
    try {
      AppLogger.lifecycle('Starting user system initialization...');

      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          if (!mounted) return;
          final unifiedUserService = Provider.of<UnifiedUserService>(
            context,
            listen: false,
          );

          await unifiedUserService.initialize();
          AppLogger.success('UnifiedUserService initialized');

          // Initialize UserProvider if we can get it safely
          if (mounted) {
            try {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              if (mounted) {
                userProvider.initialize(context);
                AppLogger.success('UserProvider initialized');
              }
            } catch (e) {
              AppLogger.warning('UserProvider initialization warning: $e');
            }
          }
        }),
      ]);

      AppLogger.success('User system initialization complete');
    } catch (e) {
      AppLogger.error('User system initialization error', e);
    }
  }

  Future<void> _initializePreferences() async {
    try {
      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          if (!mounted) return;
          final themeProvider = Provider.of<ThemeProvider>(
            context,
            listen: false,
          );
          final preferencesService = Provider.of<PreferencesService>(
            context,
            listen: false,
          );

          await preferencesService.initialize();

          if (mounted) {
            await themeProvider.initialize(context);
          }
        }),
      ]);
    } catch (e) {
      AppLogger.prefs('Preferences initialization warning', e);
    }
  }

  Future<void> _initializeStatistics() async {
    try {
      AppLogger.stats('Initializing statistics service');

      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          final statisticsService = StatisticsService();
          await statisticsService.initialize();
        }),
      ]);

      AppLogger.success('Statistics service initialized');
    } catch (e) {
      AppLogger.stats('Statistics initialization warning', e);
    }
  }

  Future<void> _initializeAchievements() async {
    try {
      AppLogger.achievement('Initializing achievement system');

      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          final achievementService = AchievementService();
          await achievementService.initialize();
        }),
      ]);

      AppLogger.success('Achievement system initialized');
    } catch (e) {
      AppLogger.achievement('Achievement system initialization warning', e);
    }
  }

  Future<void> _initializeAudio() async {
    try {
      AppLogger.audio('Initializing audio service');

      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          final audioService = AudioService();
          await audioService.initialize();
        }),
      ]);

      AppLogger.success('Audio service initialized');
    } catch (e) {
      AppLogger.audio('Audio system initialization warning', e);
    }
  }

  Future<void> _performFinalSync() async {
    try {
      AppLogger.sync('Performing final sync operations');

      // Run actual work and minimum delay concurrently
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)), // Minimum 2-second delay
        Future(() async {
          if (!mounted) return;
          final syncService = Provider.of<DataSyncService>(
            context,
            listen: false,
          );
          // Perform any pending sync operations
          await syncService.forceSyncNow();
        }),
      ]);

      AppLogger.success('Final sync completed');
    } catch (e) {
      AppLogger.sync('Final sync warning', e);
    }
  }

  Future<void> _updateProgress(
    double progress,
    String message,
    String subMessage,
  ) async {
    if (!mounted) return;

    setState(() {
      _progress = progress;
      _currentTask = message;
      _subTask = subMessage;
    });

    _progressController.reset();
    _progressController.forward();

    // Small delay for UI update
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _handleError(String error) {
    if (!mounted) return;

    setState(() {
      _hasError = true;
      _errorMessage = error;
      _showRetryButton = true;
    });
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _showRetryButton = false;
      _progress = 0.0;
      _currentTask = 'Retrying initialization...';
      _subTask = '';
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
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles background
                _buildParticleBackground(theme),

                SafeArea(
                  child: _hasError
                      ? _buildErrorView(theme)
                      : _buildLoadingView(theme),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleBackground(GameTheme theme) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            _particles,
            _particleController.value,
            theme,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLoadingView(GameTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 600;
        
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 8 : 16),

                  // Game-style header
                  _buildGameHeader(theme, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 12 : 20),

                  // Central loading area with enhanced content
                  _buildEnhancedLoadingArea(theme, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Progress section with game-like design
                  _buildProgressSection(theme, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 12 : 20),

                  // Game features preview
                  if (!isSmallScreen) _buildFeaturesPreview(theme),
                  if (!isSmallScreen) SizedBox(height: isSmallScreen ? 16 : 24),

                  // Branded footer
                  _buildBrandedFooter(theme, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 8 : 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameHeader(GameTheme theme, [bool isSmallScreen = false]) {
    return Column(
      children: [
        // Pulsing snake logo with glow effect
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale =
                1.0 + (sin(_pulseController.value * 2 * pi) * 0.05);
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: isSmallScreen ? 80 : 100,
                height: isSmallScreen ? 80 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(
                        alpha:
                            0.3 + (sin(_pulseController.value * 2 * pi) * 0.2),
                      ),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: AnimatedSnakeLogo(
                  theme: theme,
                  controller: _logoController,
                  useTextLogo: true, // Use the logo with text on loading screen
                ),
              ),
            );
          },
        ),

        SizedBox(height: isSmallScreen ? 16 : 24),

        Text(
          'PREMIUM SNAKE EXPERIENCE',
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.w600,
            color: theme.accentColor.withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildEnhancedLoadingArea(GameTheme theme, [bool isSmallScreen = false]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Loading status card with enhanced design and fixed height
          Container(
            height: isSmallScreen ? 80 : 100, // Responsive fixed height to prevent layout shifts
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24, vertical: isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.backgroundColor.withValues(alpha: 0.4),
                  theme.backgroundColor.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Current task with icon - fixed height area
                  SizedBox(
                    height: isSmallScreen ? 28 : 38, // Responsive fixed height for main task area
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.accentColor.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                            )
                            .then(delay: 200.ms)
                            .scale(
                              begin: const Offset(1.2, 1.2),
                              end: const Offset(0.8, 0.8),
                            ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            _currentTask,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subtask area - fixed height whether content exists or not
                  SizedBox(
                    height: isSmallScreen ? 16 : 20, // Responsive fixed height for subtask area
                    child: _subTask.isNotEmpty
                        ? Text(
                            _subTask,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 13,
                              color: theme.accentColor.withValues(alpha: 0.8),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox(), // Empty space when no subtask
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(GameTheme theme, [bool isSmallScreen = false]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Progress bar with game-like styling
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    color: theme.backgroundColor.withValues(alpha: 0.5),
                  ),

                  // Progress fill with animation
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.accentColor,
                                theme.foodColor,
                                theme.accentColor,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Shimmer effect
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_progressController.value * 200 - 50, 0),
                        child: Container(
                          width: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Progress percentage with enhanced styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOADING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5);
  }

  Widget _buildFeaturesPreview(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Features header
          Text(
            'GAME FEATURES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.accentColor.withValues(alpha: 0.8),
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 1200.ms),

          const SizedBox(height: 16),

          // Feature grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureItem(
                theme,
                Icons.speed_rounded,
                '60FPS',
                'Smooth Gameplay',
                1300.ms,
              ),
              _buildFeatureItem(
                theme,
                Icons.auto_awesome_rounded,
                'EFFECTS',
                'Visual Particles',
                1400.ms,
              ),
              _buildFeatureItem(
                theme,
                Icons.emoji_events_rounded,
                'LEVELS',
                'Progressive Fun',
                1500.ms,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureItem(
                theme,
                Icons.volume_up_rounded,
                'AUDIO',
                'Immersive Sound',
                1600.ms,
              ),
              _buildFeatureItem(
                theme,
                Icons.leaderboard_rounded,
                'SCORES',
                'Global Rankings',
                1700.ms,
              ),
              _buildFeatureItem(
                theme,
                Icons.palette_rounded,
                'THEMES',
                'Multiple Styles',
                1800.ms,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    GameTheme theme,
    IconData icon,
    String title,
    String subtitle,
    Duration delay,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.backgroundColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.accentColor.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: theme.primaryColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                color: theme.accentColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate().fadeIn(delay: delay).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildBrandedFooter(GameTheme theme, [bool isSmallScreen = false]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Decorative divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.accentColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate().fadeIn(delay: 2000.ms).scaleX(begin: 0),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Developer attribution
          Column(
            children: [
              Text(
                'DEVELOPED & MAINTAINED BY',
                style: TextStyle(
                  fontSize: isSmallScreen ? 8 : 10,
                  fontWeight: FontWeight.w600,
                  color: theme.accentColor.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 2200.ms),

              SizedBox(height: isSmallScreen ? 6 : 8),

              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.accentColor.withValues(alpha: 0.1),
                          theme.foodColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.code_rounded,
                          size: 18,
                          color: theme.accentColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pranta Dutta',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 2400.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

              SizedBox(height: isSmallScreen ? 8 : 12),

              // Tagline
              Text(
                'Crafting premium mobile experiences',
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 11,
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 2600.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(GameTheme theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon with animation
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
        ).animate().scale(delay: 200.ms).shake(),

        const SizedBox(height: 32),

        Text(
          'INITIALIZATION FAILED',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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

        if (_showRetryButton) ...[
          const SizedBox(height: 32),

          ElevatedButton(
                onPressed: _retryInitialization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 8),
                    const Text(
                      'RETRY',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        ],
      ],
    );
  }
}

// Helper classes for loading screen effects
class LoadingParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;

  LoadingParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<LoadingParticle> particles;
  final double animationValue;
  final GameTheme theme;

  ParticlePainter(this.particles, this.animationValue, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position
      particle.y -= particle.speed * 0.01;
      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = Random().nextDouble();
      }

      paint.color = theme.accentColor.withValues(alpha: particle.opacity * 0.6);

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
