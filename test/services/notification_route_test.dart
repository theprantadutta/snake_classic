import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/navigation_service.dart';

/// Guards the notification deep-link contract.
///
/// Two of the backend's route values — `game` and `daily_challenge`, together
/// the bulk of everything the app sends — were never handled by
/// NavigationService. They fell through to `default`, which resolves to home,
/// so a tap opened the app and appeared to do nothing. Nothing failed loudly;
/// `default` looks exactly like success.
///
/// The list below is the contract with the server. Every value is one the
/// backend really emits (grep the backend for `["route"]`). If someone adds a
/// route there without adding it here, this file is where it should break.
void main() {
  String resolve(String route, [Map<String, dynamic>? params]) =>
      NavigationService.resolveRoutePath(route, params);

  group('routes the backend actually sends', () {
    // DailyChallengeJobService — streak_at_risk and high_score_nudge.
    test('game resolves to home, not straight into a live run', () {
      // Deliberately home: GameScreen self-starts a game in its post-frame
      // callback, so routing to /game would have the player steering before
      // they had looked at the screen.
      expect(resolve('game'), AppRoutes.home);
    });

    // DailyChallengeJobService — challenge variant + morning announcement.
    test('daily_challenge resolves to the challenges screen', () {
      expect(resolve('daily_challenge'), AppRoutes.dailyChallenges);
      expect(resolve('daily_challenges'), AppRoutes.dailyChallenges);
    });

    // DailyChallengeJobService — win-back.
    test('home resolves to home', () {
      expect(resolve('home'), AppRoutes.home);
    });

    // NotificationJobService — weekly leaderboard.
    test('leaderboard resolves to the leaderboard', () {
      expect(resolve('leaderboard'), AppRoutes.leaderboard);
    });

    // NotificationJobService + TournamentManagementJobService.
    test('tournament_detail uses the id when present', () {
      expect(
        resolve('tournament_detail', {'tournament_id': 'abc123'}),
        AppRoutes.tournamentDetailPath('abc123'),
      );
    });

    test('tournament_detail falls back to the list without an id', () {
      expect(resolve('tournament_detail'), AppRoutes.tournaments);
      expect(
        resolve('tournament_detail', {'tournament_id': ''}),
        AppRoutes.tournaments,
      );
    });

    // Social command handlers — friend request sent / accepted.
    test('friends_screen and social both resolve to friends', () {
      expect(resolve('friends_screen'), AppRoutes.friends);
      expect(resolve('social'), AppRoutes.friends);
    });

    // PingFriendForMatch.
    test('multiplayer uses the room code when present', () {
      expect(
        resolve('multiplayer', {'room_code': 'XYZ789'}),
        AppRoutes.multiplayerLobbyPath('XYZ789'),
      );
    });

    test('multiplayer falls back to the lobby without a room code', () {
      expect(resolve('multiplayer'), AppRoutes.multiplayerLobby);
      expect(
        resolve('multiplayer', {'room_code': ''}),
        AppRoutes.multiplayerLobby,
      );
    });
  });

  group('client-side local notification routes', () {
    test('achievements resolves to the achievements screen', () {
      expect(resolve('achievements'), AppRoutes.achievements);
    });

    test('tournaments resolves to the tournaments list', () {
      expect(resolve('tournaments'), AppRoutes.tournaments);
    });
  });

  group('deep-link key (the green-splash freeze)', () {
    String? deepLink(Map<String, dynamic> data) =>
        NavigationService.resolveDeepLinkRoute(data);

    // `route` is reserved on Android. FCM copies every data key onto the
    // notification's launch Intent as a String extra, and Flutter's
    // FlutterActivity.getInitialRoute() reads the extra named exactly `route`
    // and hands it to Dart as PlatformDispatcher.defaultRouteName. go_router
    // prefers a non-"/" platform default over its own initialLocation, so
    // `route=home` cold-started the router at a location called `home` — no
    // leading slash, matches nothing. No screen mounted, so LoadingScreen's
    // FlutterNativeSplash.remove() never ran and the app sat on the flat
    // #0F380F launch image forever. Reproduced with:
    //   adb shell am start -n com.pranta.snakeclassic/.MainActivity \
    //     --es route home
    // The extra alone is sufficient; no FCM keys or Intent flags needed.
    test('reads the current key, nav_route', () {
      expect(deepLink({'nav_route': 'daily_challenge'}), 'daily_challenge');
    });

    test('still reads legacy route, for a server not yet redeployed', () {
      // Safe to READ — it was only ever unsafe to SEND.
      expect(deepLink({'route': 'leaderboard'}), 'leaderboard');
    });

    test('nav_route wins when a payload carries both', () {
      expect(
        deepLink({'nav_route': 'tournaments', 'route': 'home'}),
        'tournaments',
      );
    });

    test('a push naming no destination yields null, not an empty route', () {
      expect(deepLink({}), isNull);
      expect(deepLink({'type': 'daily_reminder'}), isNull);
      expect(deepLink({'nav_route': ''}), isNull);
      expect(deepLink({'route': ''}), isNull);
      expect(deepLink({'nav_route': 42}), isNull);
    });

    test('every deep link the backend can send resolves to a real path', () {
      // The end-to-end contract: wire key → route value → concrete path.
      for (final route in const [
        'home', 'game', 'daily_challenge', 'leaderboard', 'tournament_detail',
        'friends_screen', 'multiplayer', 'store',
      ]) {
        final resolved = deepLink({'nav_route': route});
        expect(resolved, route);
        expect(NavigationService.resolveRoutePath(resolved!).startsWith('/'),
            isTrue);
      }
    });
  });

  group('robustness', () {
    test('route matching is case-insensitive', () {
      expect(resolve('GAME'), AppRoutes.home);
      expect(resolve('Daily_Challenge'), AppRoutes.dailyChallenges);
      expect(resolve('LeaderBoard'), AppRoutes.leaderboard);
    });

    test('an unknown route degrades to home rather than throwing', () {
      expect(resolve('something_we_never_shipped'), AppRoutes.home);
      expect(resolve(''), AppRoutes.home);
    });

    test('every resolved path is a real, non-empty absolute route', () {
      const everyRoute = [
        'home', 'game', 'daily_challenge', 'achievements', 'store',
        'battle_pass', 'weekly_quests', 'statistics', 'tournaments',
        'tournament_detail', 'friends_screen', 'social', 'multiplayer',
        'leaderboard', 'profile', 'settings',
      ];
      for (final route in everyRoute) {
        final path = resolve(route);
        expect(path, isNotEmpty, reason: '$route resolved to an empty path');
        expect(
          path.startsWith('/'),
          isTrue,
          reason: '$route resolved to "$path", which is not an absolute route',
        );
      }
    });
  });
}
