import 'package:flutter/material.dart';
import 'package:snake_classic/router/app_router.dart';
import 'package:snake_classic/router/routes.dart';
import '../utils/logger.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  /// Get the root navigator context from GoRouter
  BuildContext? get _routerContext {
    return appRouter.routerDelegate.navigatorKey.currentContext;
  }

  /// The location the router is currently showing, e.g. `/home`.
  String? get _currentLocation {
    try {
      return appRouter.routerDelegate.currentConfiguration.uri.path;
    } catch (_) {
      // Router not built yet (cold start, before main() assigns appRouter).
      return null;
    }
  }

  /// Navigate to a screen based on route from notification.
  ///
  /// Every branch of the switch must map to a route that actually exists in
  /// [AppRoutes] — an unmapped value silently lands the user on home, which
  /// reads to them as "tapping the notification did nothing". Keep this in
  /// sync with the `["route"]` values the backend sends (grep the backend for
  /// `["route"]` — they are set in DailyChallengeJobService,
  /// NotificationJobService, TournamentManagementJobService, and the Social
  /// command handlers).
  /// Maps a notification's `route` string onto a concrete path in [AppRoutes].
  ///
  /// Pure and static so it can be unit-tested without a live router — the
  /// mapping being buried inside a method that needed an initialised GoRouter
  /// is why two unhandled routes (`game`, `daily_challenge`) shipped and stayed
  /// invisible: they fell through to `default`, and `default` looks like
  /// success.
  ///
  /// Keep in sync with the `["route"]` values the backend sends. Grep the
  /// backend for `["route"]` — they are set in DailyChallengeJobService,
  /// NotificationJobService, TournamentManagementJobService and the Social
  /// command handlers.
  /// The deep-link target carried by a notification's data map, or null when
  /// the push names no destination.
  ///
  /// The key is `nav_route`, NOT `route`. `route` is reserved on Android:
  /// FCM copies every data key onto the notification's launch Intent as a
  /// String extra, and Flutter's `FlutterActivity.getInitialRoute()` reads the
  /// extra named exactly `route` and feeds it to Dart as
  /// `PlatformDispatcher.defaultRouteName`. go_router prefers a non-`/`
  /// platform default over its own `initialLocation`, so a push carrying
  /// `route=home` cold-started the router at a location called `home` — which
  /// has no leading slash and matches nothing. The router settled on no route
  /// at all, LoadingScreen never mounted, and the
  /// `FlutterNativeSplash.remove()` that lives only in its initState never
  /// fired: the app sat on the flat #0F380F launch image forever, alive but
  /// with nothing to draw. Cold launches only — a warm tap is delivered to the
  /// running activity via onNewIntent, which never consults getInitialRoute.
  ///
  /// `MainActivity.getInitialRoute()` returns null as the permanent native
  /// guard, and the backend now emits `nav_route`. The `route` fallback here
  /// is for pushes from a server that has not been redeployed yet — it is
  /// safe to READ, it was only ever unsafe to send.
  ///
  /// Static and pure so the wire contract is unit-testable without a live
  /// router — the same reason [resolveRoutePath] is.
  static String? resolveDeepLinkRoute(Map<String, dynamic> data) {
    final route = data['nav_route'] ?? data['route'];
    return (route is String && route.isNotEmpty) ? route : null;
  }

  @visibleForTesting
  static String resolveRoutePath(String route, [Map<String, dynamic>? params]) {
    switch (route.toLowerCase()) {
      case 'home':
        return AppRoutes.home;

      // The daily reminder's streak_at_risk and high_score_nudge variants both
      // send route=game — by volume the most-sent notification in the app. It
      // was not handled here at all, so every one of those taps fell through
      // to `default`.
      //
      // Resolves to HOME rather than /game on purpose. GameScreen self-starts
      // a run in its post-frame callback, so routing there would drop a player
      // into a live snake the instant they tapped — steering before they had
      // even looked at the screen, and most likely dying immediately. Home
      // puts them one deliberate tap from playing, hero Play button already
      // under their thumb.
      case 'game':
        return AppRoutes.home;

      // Sent by the daily reminder's challenge variant and by the morning
      // challenge announcement. Also previously unhandled.
      case 'daily_challenge':
      case 'daily_challenges':
        return AppRoutes.dailyChallenges;

      case 'achievements':
        return AppRoutes.achievements;

      // Not currently sent by the backend, but cheap to accept so a new
      // server-side route does not silently degrade to home before anyone
      // notices.
      case 'store':
        return AppRoutes.store;

      case 'battle_pass':
        return AppRoutes.battlePass;

      case 'weekly_quests':
        return AppRoutes.weeklyQuests;

      case 'statistics':
        return AppRoutes.statistics;

      case 'tournament_detail':
        // With an id we can open the detail page; without one the list is the
        // honest fallback.
        final tournamentId = params?['tournament_id'] as String?;
        return (tournamentId != null && tournamentId.isNotEmpty)
            ? AppRoutes.tournamentDetailPath(tournamentId)
            : AppRoutes.tournaments;

      case 'tournaments':
        return AppRoutes.tournaments;

      case 'friends_screen':
      case 'social':
        return AppRoutes.friends;

      case 'multiplayer':
        // Match-ping deep link: a room code rides along when the friend pinged
        // from a lobby — land the user straight in that room.
        final roomCode = params?['room_code'] as String?;
        return (roomCode != null && roomCode.isNotEmpty)
            ? AppRoutes.multiplayerLobbyPath(roomCode)
            : AppRoutes.multiplayerLobby;

      case 'leaderboard':
        return AppRoutes.leaderboard;

      case 'profile':
        return AppRoutes.profile;

      case 'settings':
        return AppRoutes.settings;

      default:
        AppLogger.warning(
          'Unknown navigation route: $route, falling back to home',
        );
        return AppRoutes.home;
    }
  }

  Future<void> navigateFromNotification({
    required String route,
    Map<String, dynamic>? params,
    bool clearStack = false,
  }) async {
    try {
      AppLogger.info('Navigating from notification: $route');

      final routePath = resolveRoutePath(route, params);

      final current = _currentLocation;

      // Already showing the target. Pushing here is what made a notification
      // tap look like a freeze: the deep link is flushed from HomeScreen's own
      // initState (see NotificationService.markAppReady), so for any route
      // resolving to home the router was asked to push /home ON TOP of /home.
      // That builds a SECOND HomeScreen — a second set of repeating animation
      // controllers, particle painter, theme-transition widget, banner ad and
      // prompt queue — over the first. On a low-end device the resulting jank
      // reads as a hang, and because the new screen looks identical to the one
      // underneath it, it also reads as "nothing happened".
      if (current == routePath) {
        AppLogger.info('Already on $routePath — no navigation needed');
        return;
      }

      if (clearStack || routePath == AppRoutes.home) {
        // Home is the app's root. It must always REPLACE rather than stack,
        // otherwise back from a notification-opened home pops to another home.
        appRouter.go(routePath);
      } else {
        // Push, so the back stack reads home → target and Android back
        // returns to the app rather than exiting it.
        appRouter.push(routePath);
      }

      AppLogger.info('Navigation completed: $route → $routePath');
    } catch (e) {
      AppLogger.error('Failed to navigate from notification', e);

      // Fallback to home screen — but only if we are not already there, for
      // the same reason as above.
      if (_currentLocation != AppRoutes.home) {
        appRouter.go(AppRoutes.home);
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
    appRouter.push(AppRoutes.tournamentDetailPath(tournamentId));
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
    if (_currentLocation == AppRoutes.home) return;
    appRouter.go(AppRoutes.home);
  }

  /// Pop current screen if possible
  void goBack() {
    if (appRouter.canPop()) {
      appRouter.pop();
    }
  }

  /// Check if we can go back
  bool canGoBack() {
    return appRouter.canPop();
  }

  /// Get current route name if available
  String? getCurrentRouteName() {
    return appRouter.routerDelegate.currentConfiguration.last.matchedLocation;
  }

  /// Show a snackbar message
  void showSnackBar(String message, {bool isError = false}) {
    final context = _routerContext;
    if (context != null && context.mounted) {
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
    final context = _routerContext;
    if (context != null && context.mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions:
                actions ??
                [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
          );
        },
      );
    }
  }
}
