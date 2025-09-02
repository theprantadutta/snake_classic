import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class FirstTimeAuthScreen extends StatefulWidget {
  const FirstTimeAuthScreen({super.key});

  @override
  State<FirstTimeAuthScreen> createState() => _FirstTimeAuthScreenState();
}

class _FirstTimeAuthScreenState extends State<FirstTimeAuthScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      body: AnimatedAppBackground(
        theme: theme,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;
              final isSmallScreen = screenHeight < 600;
              final isNarrowScreen = screenWidth < 400;
              
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isNarrowScreen ? 16.0 : 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Add some top padding for small screens
                        SizedBox(height: isSmallScreen ? 20 : 40),
                // Welcome Header
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.accentColor.withValues(alpha: 0.3),
                        theme.accentColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.4),
                        blurRadius: isSmallScreen ? 30 : 40,
                        spreadRadius: isSmallScreen ? 5 : 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.videogame_asset_rounded,
                    size: isSmallScreen ? screenHeight * 0.08 : screenHeight * 0.12,
                    color: theme.primaryColor,
                  ),
                )
                    .animate()
                    .scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),
                
                SizedBox(height: isSmallScreen ? screenHeight * 0.02 : screenHeight * 0.04),

                // Welcome Text Container
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? screenHeight * 0.02 : screenHeight * 0.035),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.backgroundColor.withValues(alpha: 0.4),
                        theme.backgroundColor.withValues(alpha: 0.2),
                        theme.accentColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Title with gradient effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [theme.primaryColor, theme.accentColor],
                        ).createShader(bounds),
                        child: Text(
                          'Welcome to\nSnake Classic!',
                          style: TextStyle(
                            fontSize: isSmallScreen ? screenHeight * 0.03 : screenHeight * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? screenHeight * 0.015 : screenHeight * 0.025),

                      // Feature highlights
                      Text(
                        'Choose how you\'d like to play:',
                        style: TextStyle(
                          fontSize: isSmallScreen ? screenHeight * 0.018 : screenHeight * 0.022,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? screenHeight * 0.015 : screenHeight * 0.02),

                      // Feature list
                      ..._buildFeatureList(theme, isSmallScreen),
                    ],
                  ),
                )
                    .animate(delay: 300.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(),

                SizedBox(height: isSmallScreen ? screenHeight * 0.03 : screenHeight * 0.05),

                // Auth buttons
                if (_isLoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: theme.accentColor,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Signing you in...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      // Google Sign-In Button
                      _buildAuthButton(
                        context,
                        'Sign in with Google',
                        FontAwesomeIcons.google,
                        [Colors.red.shade600, Colors.red.shade700],
                        () => _handleGoogleSignIn(userProvider),
                      )
                          .animate(delay: 600.ms)
                          .slideX(
                            begin: -0.5,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(),

                      const SizedBox(height: 16),

                      // Guest Button
                      _buildAuthButton(
                        context,
                        'Continue as Guest',
                        Icons.person_outline_rounded,
                        [
                          theme.primaryColor.withValues(alpha: 0.8),
                          theme.primaryColor
                        ],
                        () => _handleGuestLogin(userProvider),
                      )
                          .animate(delay: 800.ms)
                          .slideX(
                            begin: 0.5,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(),
                    ],
                  ),

                SizedBox(height: isSmallScreen ? screenHeight * 0.02 : screenHeight * 0.03),

                // Privacy note
                Text(
                  'Your data is secure and your privacy is protected',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 800.ms),
                    
                // Bottom padding for small screens
                SizedBox(height: isSmallScreen ? 20 : 40),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList(GameTheme theme, [bool isSmallScreen = false]) {
    final features = [
      {
        'icon': Icons.cloud_sync_rounded,
        'title': 'Google Sign-In',
        'subtitle': 'Save progress • Sync across devices • Global leaderboards'
      },
      {
        'icon': Icons.person_rounded,
        'title': 'Guest Mode',
        'subtitle': 'Play instantly • Local progress • Upgrade to Google later'
      },
    ];

    return features
        .map(
          (feature) => Padding(
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6.0 : 8.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: theme.accentColor,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        feature['subtitle'] as String,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildAuthButton(
    BuildContext context,
    String text,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(UserProvider userProvider) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await userProvider.signInWithGoogle();
      
      if (success && mounted) {
        // Mark first-time setup as complete
        await userProvider.markFirstTimeSetupComplete();
        
        // Navigate directly to home screen
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
      } else if (mounted) {
        _showError('Failed to sign in with Google. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin(UserProvider userProvider) async {
    setState(() => _isLoading = true);
    
    try {
      await userProvider.signInAnonymously();
      
      // Mark first-time setup as complete
      await userProvider.markFirstTimeSetupComplete();
      
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
    } catch (e) {
      if (mounted) {
        _showError('Failed to continue as guest. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}