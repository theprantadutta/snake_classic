import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/preferences_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/widgets/animated_snake_logo.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';
import 'dart:math';

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
      _particles.add(LoadingParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.2 + _random.nextDouble() * 0.3,
        size: 2 + _random.nextDouble() * 4,
        opacity: 0.3 + _random.nextDouble() * 0.4,
      ));
    }
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize Core Services
      await _updateProgress(0.1, 'Initializing core systems...', 'Setting up Firebase connection');
      await _initializeCoreServices();
      
      // Step 2: Initialize User System
      await _updateProgress(0.25, 'Creating your player profile...', 'Generating unique username');
      await _initializeUserSystem();
      
      // Step 3: Load User Preferences
      await _updateProgress(0.4, 'Loading your preferences...', 'Syncing themes and settings');
      await _initializePreferences();
      
      // Step 4: Initialize Game Data
      await _updateProgress(0.55, 'Loading game statistics...', 'Calculating your progress');
      await _initializeStatistics();
      
      // Step 5: Initialize Achievement System
      await _updateProgress(0.7, 'Checking achievements...', 'Unlocking rewards');
      await _initializeAchievements();
      
      // Step 6: Initialize Audio System
      await _updateProgress(0.85, 'Configuring audio system...', 'Loading sound effects');
      await _initializeAudio();
      
      // Step 7: Final Sync
      await _updateProgress(0.95, 'Syncing with cloud...', 'Ensuring data is up to date');
      await _performFinalSync();
      
      // Step 8: Complete
      await _updateProgress(1.0, 'Ready to play!', 'Welcome to Snake Classic');
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Navigation to Home Screen with smooth transition
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
      // Initialize Firebase and core services here
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate work
    } catch (e) {
      AppLogger.error('Core services initialization warning', e);
    }
  }

  Future<void> _initializeUserSystem() async {
    try {
      AppLogger.lifecycle('Starting user system initialization...');
      final unifiedUserService = Provider.of<UnifiedUserService>(context, listen: false);
      
      await unifiedUserService.initialize();
      AppLogger.success('UnifiedUserService initialized');
      
      // Initialize UserProvider if we can get it safely
      if (mounted) {
        try {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.initialize(context);
          AppLogger.success('UserProvider initialized');
        } catch (e) {
          AppLogger.warning('UserProvider initialization warning: $e');
        }
      }
      
      AppLogger.success('User system initialization complete');
    } catch (e) {
      AppLogger.error('User system initialization error', e);
    }
  }

  Future<void> _initializePreferences() async {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final preferencesService = Provider.of<PreferencesService>(context, listen: false);
      
      await preferencesService.initialize();
      
      if (mounted) {
        await themeProvider.initialize(context);
      }
      
    } catch (e) {
      AppLogger.prefs('Preferences initialization warning', e);
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

  Future<void> _initializeAudio() async {
    try {
      AppLogger.audio('Initializing audio service');
      final audioService = AudioService();
      await audioService.initialize();
      AppLogger.success('Audio service initialized');
    } catch (e) {
      AppLogger.audio('Audio system initialization warning', e);
    }
  }

  Future<void> _performFinalSync() async {
    try {
      AppLogger.sync('Performing final sync operations');
      final syncService = Provider.of<DataSyncService>(context, listen: false);
      // Perform any pending sync operations
      await syncService.forceSyncNow();
      AppLogger.success('Final sync completed');
    } catch (e) {
      AppLogger.sync('Final sync warning', e);
    }
  }

  Future<void> _updateProgress(double progress, String message, String subMessage) async {
    if (!mounted) return;
    
    setState(() {
      _progress = progress;
      _currentTask = message;
      _subTask = subMessage;
    });
    
    _progressController.reset();
    _progressController.forward();
    
    // Add realistic delay for initialization steps
    await Future.delayed(const Duration(milliseconds: 400));
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
                  child: _hasError ? _buildErrorView(theme) : _buildLoadingView(theme),
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
          painter: ParticlePainter(_particles, _particleController.value, theme),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLoadingView(GameTheme theme) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Game-style header
            _buildGameHeader(theme),
            
            const SizedBox(height: 20),
            
            // Central loading area
            _buildLoadingArea(theme),
            
            const SizedBox(height: 40),
            
            // Progress section with game-like design
            _buildProgressSection(theme),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHeader(GameTheme theme) {
    return Column(
      children: [
        // Pulsing snake logo with glow effect
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale = 1.0 + (sin(_pulseController.value * 2 * pi) * 0.05);
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.3 + (sin(_pulseController.value * 2 * pi) * 0.2)),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: AnimatedSnakeLogo(
                  theme: theme,
                  controller: _logoController,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Game title with enhanced styling
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [theme.accentColor, theme.foodColor, theme.accentColor],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            'SNAKE CLASSIC',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.3),
        
        const SizedBox(height: 12),
        
        Text(
          'PREMIUM SNAKE EXPERIENCE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.accentColor.withValues(alpha: 0.7),
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildLoadingArea(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Task display with flexible height
          Container(
            constraints: const BoxConstraints(minHeight: 50, maxHeight: 80),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentTask,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (_subTask.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _subTask,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(GameTheme theme) {
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
          
          const SizedBox(height: 16),
          
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          child: const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
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
        
        if (_showRetryButton) ...[
          const SizedBox(height: 32),
          
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
          ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
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
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
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