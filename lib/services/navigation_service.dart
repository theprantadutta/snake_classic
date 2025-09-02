import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../screens/home_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/tournaments_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Global navigator key for programmatic navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a screen based on route from notification
  Future<void> navigateFromNotification({
    required String route,
    Map<String, dynamic>? params,
    bool clearStack = false,
  }) async {
    try {
      AppLogger.info('🧭 Navigating from notification: $route');
      
      final context = navigatorKey.currentContext;
      if (context == null) {
        AppLogger.warning('Navigation context not available');
        return;
      }

      Widget destination;
      
      switch (route.toLowerCase()) {
        case 'home':
          destination = const HomeScreen();
          break;
          
        case 'achievements':
          destination = const AchievementsScreen();
          break;
          
        case 'tournament_detail':
        case 'tournaments':
          destination = const TournamentsScreen(); // Simplified for now
          break;
          
        case 'friends_screen':
        case 'social':
          destination = const FriendsScreen();
          break;
          
        case 'leaderboard':
          destination = const LeaderboardScreen();
          break;
          
        case 'profile':
          destination = const ProfileScreen();
          break;
          
        case 'settings':
          destination = const SettingsScreen();
          break;
          
        default:
          AppLogger.warning('Unknown navigation route: $route, falling back to home');
          destination = const HomeScreen();
      }

      if (clearStack) {
        // Replace entire navigation stack
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => destination),
          (Route<dynamic> route) => false,
        );
      } else {
        // Push new screen
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => destination),
        );
      }
        
      AppLogger.info('✅ Navigation completed: $route');
      
    } catch (e) {
      AppLogger.error('Failed to navigate from notification', e);
      
      // Fallback to home screen
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  /// Navigate to achievement detail with achievement ID
  Future<void> navigateToAchievement(String achievementId) async {
    await navigateFromNotification(
      route: 'achievements',
      params: {'achievement_id': achievementId},
    );
  }

  /// Navigate to tournament detail
  Future<void> navigateToTournament(String tournamentId) async {
    await navigateFromNotification(
      route: 'tournament_detail',
      params: {'tournament_id': tournamentId},
    );
  }

  /// Navigate to user profile or friends screen
  Future<void> navigateToSocial({String? userId}) async {
    await navigateFromNotification(
      route: 'friends_screen',
      params: userId != null ? {'user_id': userId} : null,
    );
  }

  /// Navigate to leaderboard with specific filters
  Future<void> navigateToLeaderboard({String? filter}) async {
    await navigateFromNotification(
      route: 'leaderboard',
      params: filter != null ? {'filter': filter} : null,
    );
  }

  /// Navigate to home screen (clear stack)
  Future<void> navigateToHome() async {
    await navigateFromNotification(
      route: 'home',
      clearStack: true,
    );
  }

  /// Pop current screen if possible
  void goBack() {
    final context = navigatorKey.currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Check if we can go back
  bool canGoBack() {
    final context = navigatorKey.currentContext;
    return context != null && Navigator.canPop(context);
  }

  /// Get current route name if available
  String? getCurrentRouteName() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final route = ModalRoute.of(context);
      return route?.settings.name;
    }
    return null;
  }

  /// Show a snackbar message
  void showSnackBar(String message, {bool isError = false}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show a dialog
  Future<void> showAppDialog({
    required String title,
    required String message,
    List<Widget>? actions,
  }) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: actions ?? [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }
}