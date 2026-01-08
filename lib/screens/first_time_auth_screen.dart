import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
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
  bool _showPrivacyPolicy = true;
  bool _privacyAccepted = false;
  String _privacyPolicyContent = '';

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
    _checkPreviousPrivacyAcceptance();
  }

  Future<void> _checkPreviousPrivacyAcceptance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyAccepted = prefs.getBool('privacy_policy_accepted') ?? false;
      if (alreadyAccepted && mounted) {
        setState(() {
          _showPrivacyPolicy = false;
          _privacyAccepted = true;
        });
      }
    } catch (e) {
      // If there's an error reading preferences, show the privacy policy
    }
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      final content = await rootBundle.loadString('PRIVACY.md');
      setState(() {
        _privacyPolicyContent = content;
      });
    } catch (e) {
      // Fallback if file can't be loaded
      setState(() {
        _privacyPolicyContent = '''# Privacy Policy for Snake Classic

**Effective Date: January 17, 2025**

## Introduction
Snake Classic respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

## Information We Collect
We collect various types of information to provide and improve our services, including:
- Authentication data when you sign in with Google
- Game data such as scores, achievements, and progress
- Device information for app functionality
- Usage analytics to improve the game experience

## How We Use Your Information
Your information is used to:
- Provide core game functionality
- Save your progress and achievements
- Enable social features and leaderboards
- Improve app performance and user experience

## Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

## Your Rights
You have the right to access, update, or delete your personal information. Contact us for any privacy-related requests.

## Contact Information
For questions about this Privacy Policy, please contact us at: privacy@snakeclassic.game

By using Snake Classic, you acknowledge that you have read, understood, and agree to this Privacy Policy.
''';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final authCubit = context.read<AuthCubit>();
    final theme = themeState.currentTheme;

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

              if (_showPrivacyPolicy) {
                return _buildPrivacyPolicyView(
                  theme,
                  screenHeight,
                  screenWidth,
                  isSmallScreen,
                  isNarrowScreen,
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrowScreen ? 16.0 : 24.0,
                ),
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
                                    color: theme.accentColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: isSmallScreen ? 30 : 40,
                                    spreadRadius: isSmallScreen ? 5 : 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.videogame_asset_rounded,
                                size: isSmallScreen
                                    ? screenHeight * 0.08
                                    : screenHeight * 0.12,
                                color: theme.primaryColor,
                              ),
                            )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(),

                        SizedBox(
                          height: isSmallScreen
                              ? screenHeight * 0.02
                              : screenHeight * 0.04,
                        ),

                        // Welcome Text Container
                        Container(
                              padding: EdgeInsets.all(
                                isSmallScreen
                                    ? screenHeight * 0.02
                                    : screenHeight * 0.035,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.backgroundColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    theme.backgroundColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    theme.accentColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.accentColor.withValues(
                                    alpha: 0.3,
                                  ),
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
                                      colors: [
                                        theme.primaryColor,
                                        theme.accentColor,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Welcome to\nSnake Classic!',
                                      style: TextStyle(
                                        fontSize: isSmallScreen
                                            ? screenHeight * 0.03
                                            : screenHeight * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: isSmallScreen
                                        ? screenHeight * 0.015
                                        : screenHeight * 0.025,
                                  ),

                                  // Feature highlights
                                  Text(
                                    'Choose how you\'d like to play:',
                                    style: TextStyle(
                                      fontSize: isSmallScreen
                                          ? screenHeight * 0.018
                                          : screenHeight * 0.022,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: isSmallScreen
                                        ? screenHeight * 0.015
                                        : screenHeight * 0.02,
                                  ),

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

                        SizedBox(
                          height: isSmallScreen
                              ? screenHeight * 0.03
                              : screenHeight * 0.05,
                        ),

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
                                    () => _handleGoogleSignIn(authCubit),
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
                                      theme.primaryColor,
                                    ],
                                    () => _handleGuestLogin(authCubit),
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

  Widget _buildPrivacyPolicyView(
    GameTheme theme,
    double screenHeight,
    double screenWidth,
    bool isSmallScreen,
    bool isNarrowScreen,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isNarrowScreen ? 16.0 : 24.0),
      child: Column(
        children: [
          // Header
          Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.accentColor.withValues(alpha: 0.2),
                      theme.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.privacy_tip_outlined,
                        color: theme.accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: theme.accentColor,
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Please review our privacy policy before continuing',
                            style: TextStyle(
                              color: theme.accentColor.withValues(alpha: 0.7),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(),

          const SizedBox(height: 16),

          // Privacy Policy Content
          Expanded(
            child:
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.backgroundColor.withValues(alpha: 0.4),
                            theme.backgroundColor.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _privacyPolicyContent,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isSmallScreen ? 12 : 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                    .animate(delay: 300.ms)
                    .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOut)
                    .fadeIn(),
          ),

          const SizedBox(height: 16),

          // Acceptance Checkbox
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.accentColor.withValues(alpha: 0.15),
                      theme.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _privacyAccepted,
                        onChanged: (value) async {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                          // Save privacy acceptance immediately when checked
                          if (_privacyAccepted) {
                            try {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool(
                                'privacy_policy_accepted',
                                true,
                              );
                            } catch (e) {
                              // Ignore errors - not critical
                            }
                          }
                        },
                        activeColor: theme.accentColor,
                        checkColor: Colors.white,
                        side: BorderSide(
                          color: theme.accentColor.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'I have read and agree to the Privacy Policy and Terms of Service',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: 600.ms)
              .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOut)
              .fadeIn(),

          const SizedBox(height: 20),

          // Continue Button
          Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _privacyAccepted
                        ? [theme.primaryColor, theme.accentColor]
                        : [Colors.grey.shade600, Colors.grey.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _privacyAccepted
                      ? [
                          BoxShadow(
                            color: theme.accentColor.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _privacyAccepted
                        ? () {
                            setState(() {
                              _showPrivacyPolicy = false;
                            });
                          }
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: _privacyAccepted
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue to Sign In',
                          style: TextStyle(
                            color: _privacyAccepted
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate(delay: 800.ms)
              .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOut)
              .fadeIn(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureList(
    GameTheme theme, [
    bool isSmallScreen = false,
  ]) {
    final features = [
      {
        'icon': Icons.cloud_sync_rounded,
        'title': 'Google Sign-In',
        'subtitle': 'Save progress • Sync across devices • Global leaderboards',
      },
      {
        'icon': Icons.person_rounded,
        'title': 'Guest Mode',
        'subtitle': 'Play instantly • Local progress • Upgrade to Google later',
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

  Future<void> _handleGoogleSignIn(AuthCubit authCubit) async {
    setState(() => _isLoading = true);

    try {
      final success = await authCubit.signInWithGoogle();

      if (success && mounted) {
        // Mark first-time setup as complete
        await authCubit.markFirstTimeSetupComplete();

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

  Future<void> _handleGuestLogin(AuthCubit authCubit) async {
    setState(() => _isLoading = true);

    try {
      await authCubit.signInAnonymously();

      // Mark first-time setup as complete
      await authCubit.markFirstTimeSetupComplete();

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
              child: Text(message, style: const TextStyle(fontSize: 16)),
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
