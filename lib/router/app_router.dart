import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/screens/debug/lb_gallery_screen.dart';
import 'package:snake_classic/models/game_replay.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/achievements_screen.dart';
import 'package:snake_classic/screens/battle_pass_screen.dart';
import 'package:snake_classic/screens/daily_challenges_screen.dart';
import 'package:snake_classic/screens/weekly_quests_screen.dart';
import 'package:snake_classic/screens/email_auth_screen.dart';
import 'package:snake_classic/screens/first_time_auth_screen.dart';
import 'package:snake_classic/screens/privacy_consent_screen.dart';
import 'package:snake_classic/screens/username_setup_screen.dart';
import 'package:snake_classic/screens/friends_leaderboard_screen.dart';
import 'package:snake_classic/screens/friends_screen.dart';
import 'package:snake_classic/screens/game_over_screen.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/screens/home_screen.dart';
import 'package:snake_classic/screens/instructions_screen.dart';
import 'package:snake_classic/screens/leaderboard_screen.dart';
import 'package:snake_classic/screens/loading_screen.dart';
import 'package:snake_classic/screens/multiplayer_game_screen.dart';
import 'package:snake_classic/screens/multiplayer_lobby_screen.dart';
import 'package:snake_classic/screens/pre_game_loading_screen.dart';
import 'package:snake_classic/screens/premium_benefits_screen.dart';
import 'package:snake_classic/screens/profile_screen.dart';
import 'package:snake_classic/screens/replay_viewer_screen.dart';
import 'package:snake_classic/screens/replays_screen.dart';
import 'package:snake_classic/screens/run_setup_screen.dart';
import 'package:snake_classic/screens/route_error_screen.dart';
import 'package:snake_classic/screens/settings_screen.dart';
import 'package:snake_classic/screens/statistics_screen.dart';
import 'package:snake_classic/screens/store_screen.dart';
import 'package:snake_classic/screens/tournament_detail_screen.dart';
import 'package:snake_classic/screens/tournaments_screen.dart';

/// Default transition for pushed Living Board screens: a short fade with a
/// 2% scale-up and rise, [LBMotion.base], easeOutSoft in and [LBMotion.exit]
/// on the way out. The screen's own entrance choreography (LBStaggerIn) does
/// the rest. Reduce motion: a plain [LBMotion.reducedFade] fade.
CustomTransitionPage<void> _zoomPage(BuildContext context, GoRouterState state, Widget child) {
  if (LBMotion.reduced(context)) return _reducedPage(state, child);
  return CustomTransitionPage(
    key: state.pageKey,
    // The GoRoute name reaches NavigatorObservers as RouteSettings.name —
    // screen-view analytics and the menu-music observer both read it. It
    // was unset, so every observer saw null.
    name: state.name ?? state.matchedLocation,
    child: child,
    transitionDuration: LBMotion.base,
    reverseTransitionDuration: LBMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final move = CurvedAnimation(
        parent: animation,
        curve: LBMotion.easeOutSoft,
        reverseCurve: LBMotion.exit.flipped,
      );
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .02), end: Offset.zero).animate(move),
        child: ScaleTransition(
          scale: Tween<double>(begin: .98, end: 1).animate(move),
          // The page fades over a few frames at the start of the zoom (and the
          // end of the zoom out) instead of the whole transition. While its
          // opacity is below 1 the whole page — glows and all — is rendered
          // offscreen every frame, and on the A24's GPU (already drawing two
          // full screens during a transition) a long fade pushed half of all
          // screen-open frames past the 11 ms budget at 90 Hz. Profiled with
          // the fades interleaved in one build: 51% of opening frames over
          // budget with the long fade, 18% with this one, 19% with no fade.
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const _QuickFade(),
              reverseCurve: const _QuickFade(),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Opacity for the LB transitions: easeOutSoft, finished in the first 30%.
/// The same curve runs backwards on close, so the page stays opaque until
/// the last few frames.
class _QuickFade extends Curve {
  const _QuickFade();

  @override
  double transformInternal(double t) =>
      const Interval(0, .3, curve: LBMotion.easeOutSoft).transform(t);
}

/// Reveal for the game screens: a larger scale-up over [LBMotion.gentle],
/// easeOutSoft in, [LBMotion.exit] out. Reduce motion: plain fade.
CustomTransitionPage<void> _scalePage(BuildContext context, GoRouterState state, Widget child) {
  if (LBMotion.reduced(context)) return _reducedPage(state, child);
  return CustomTransitionPage(
    key: state.pageKey,
    // The GoRoute name reaches NavigatorObservers as RouteSettings.name —
    // screen-view analytics and the menu-music observer both read it. It
    // was unset, so every observer saw null.
    name: state.name ?? state.matchedLocation,
    child: child,
    transitionDuration: LBMotion.gentle,
    reverseTransitionDuration: LBMotion.base,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: LBMotion.easeOutSoft,
            reverseCurve: LBMotion.exit.flipped,
          ),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const _QuickFade(),
            reverseCurve: const _QuickFade(),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Reduce motion: every route is a plain [LBMotion.reducedFade] fade.
CustomTransitionPage<void> _reducedPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    name: state.name ?? state.matchedLocation,
    child: child,
    transitionDuration: LBMotion.reducedFade,
    reverseTransitionDuration: LBMotion.reducedFade,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Late-initialized global GoRouter instance.
late final GoRouter appRouter;

/// Global key on the root Navigator. SyncEngine uses it to insert the
/// first-sign-in OverlayEntry above whatever route the user is on when
/// sign-in fires (could be FirstTimeAuthScreen, LoadingScreen, or
/// ProfileScreen's "Save your progress" upgrade — anywhere).
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

/// Creates a [GoRouter] with optional [NavigatorObserver]s for analytics.
GoRouter createAppRouter({List<NavigatorObserver>? observers}) => GoRouter(
  initialLocation: AppRoutes.loading,
  navigatorKey: rootNavigatorKey,
  // Debug builds only — this was `true` unconditionally, spamming route
  // diagnostics in production logs.
  debugLogDiagnostics: kDebugMode,
  observers: observers ?? [],
  // Ours, not go_router's. Without this the no-match case falls to whichever
  // built-in error screen its app-type detection picks — and since 18.0 that
  // detection looks for material_ui's MaterialApp, so it always misses and
  // lands on the unstyled WidgetsApp one.
  errorBuilder: (context, state) => RouteErrorScreen(error: state.error),
  routes: [
    // Core routes
    GoRoute(
      path: AppRoutes.loading,
      name: 'loading',
      // Explicit page, like every other route here. `builder:` would leave the
      // page type up to go_router's _cacheAppType, which since 18.0 walks the
      // tree for material_ui's MaterialApp — a different type from the
      // package:flutter/material.dart one we actually use. It never matches,
      // so the app silently gets the WidgetsApp defaults. Naming the page
      // makes this route's behaviour ours rather than a side effect of that.
      //
      // No transition is right here regardless: this is the initial location,
      // handed over from the native splash, so there is nothing to animate
      // from. Leaving is animated by whatever page comes next.
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, name: state.name, child: const LoadingScreen()),
    ),
    GoRoute(
      path: AppRoutes.firstTimeAuth,
      name: 'firstTimeAuth',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const FirstTimeAuthScreen()),
    ),
    GoRoute(
      path: AppRoutes.privacyConsent,
      name: 'privacyConsent',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const PrivacyConsentScreen()),
    ),
    GoRoute(
      path: AppRoutes.emailAuth,
      name: 'emailAuth',
      pageBuilder: (context, state) {
        // `link` query flag distinguishes the upgrade-from-anonymous flow
        // from a fresh sign-in. Set when launching from the purchase-gate
        // bottom sheet.
        final isLink = state.uri.queryParameters['link'] == '1';
        return _zoomPage(context, state, EmailAuthScreen(linkFromAnonymous: isLink));
      },
    ),
    GoRoute(
      path: AppRoutes.usernameSetup,
      name: 'usernameSetup',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const UsernameSetupScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => _zoomPage(context, state, const HomeScreen()),
    ),

    // Game flow
    GoRoute(
      path: AppRoutes.playLoading,
      name: 'playLoading',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const PreGameLoadingScreen()),
    ),
    GoRoute(
      path: AppRoutes.game,
      name: 'game',
      pageBuilder: (context, state) => _scalePage(
        context,
        state,
        GameScreen(startTutorial: AppRoutes.wantsTutorial(state.uri)),
      ),
    ),
    GoRoute(
      path: AppRoutes.gameOver,
      name: 'gameOver',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const GameOverScreen()),
    ),

    // Profile & Stats
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const ProfileScreen()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.statistics,
      name: 'statistics',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const StatisticsScreen()),
    ),
    GoRoute(
      path: AppRoutes.achievements,
      name: 'achievements',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const AchievementsScreen()),
    ),

    // Social & Competitive
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const LeaderboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.friendsLeaderboard,
      name: 'friendsLeaderboard',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const FriendsLeaderboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.friends,
      name: 'friends',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const FriendsScreen()),
    ),
    GoRoute(
      path: AppRoutes.tournaments,
      name: 'tournaments',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const TournamentsScreen()),
    ),
    GoRoute(
      path: AppRoutes.tournamentDetail,
      name: 'tournamentDetail',
      pageBuilder: (context, state) {
        // Get tournament ID from path parameter
        final tournamentId = state.pathParameters['id'] ?? '';
        // Get tournament object from extra if available (for instant display)
        final tournament = state.extra as Tournament?;

        return _zoomPage(
          context,
          state,
          TournamentDetailScreen(
            tournamentId: tournamentId,
            tournament: tournament,
          ),
        );
      },
    ),

    // Monetization
    GoRoute(
      path: AppRoutes.store,
      name: 'store',
      pageBuilder: (context, state) {
        // Get initial tab from query parameter
        final tabString = state.uri.queryParameters['tab'];
        final initialTab = tabString != null ? int.tryParse(tabString) ?? 0 : 0;
        return _zoomPage(context, state, StoreScreen(initialTab: initialTab));
      },
    ),
    GoRoute(
      path: AppRoutes.premiumBenefits,
      name: 'premiumBenefits',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const PremiumBenefitsScreen()),
    ),
    // Cosmetics route is preserved as a redirect to the store's Skins tab.
    // The standalone CosmeticsScreen was removed when the store screen
    // inlined its content. Deep links from older builds (or in-game prompts)
    // still resolve cleanly through this redirect.
    GoRoute(
      path: AppRoutes.cosmetics,
      name: 'cosmetics',
      redirect: (context, state) => '${AppRoutes.store}?tab=3',
    ),
    GoRoute(
      path: AppRoutes.battlePass,
      name: 'battlePass',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const BattlePassScreen()),
    ),

    // Other features
    GoRoute(
      path: AppRoutes.dailyChallenges,
      name: 'dailyChallenges',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const DailyChallengesScreen()),
    ),
    GoRoute(
      path: AppRoutes.weeklyQuests,
      name: 'weeklyQuests',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const WeeklyQuestsScreen()),
    ),
    GoRoute(
      path: AppRoutes.instructions,
      name: 'instructions',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const InstructionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.replays,
      name: 'replays',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const ReplaysScreen()),
    ),
    GoRoute(
      path: AppRoutes.replayViewer,
      name: 'replayViewer',
      pageBuilder: (context, state) {
        // Get replay ID from path parameter
        final replayId = state.pathParameters['id'] ?? '';
        // Get replay object from extra if available (for instant display)
        final replay = state.extra as GameReplay?;

        return _zoomPage(
          context,
          state,
          ReplayViewerScreen(
            replayId: replayId,
            replay: replay,
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.runSetup,
      name: 'runSetup',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const RunSetupScreen()),
    ),
    if (kDebugMode)
      GoRoute(
        path: AppRoutes.lbGallery,
        name: 'lbGallery',
        pageBuilder: (context, state) =>
            _zoomPage(context, state, const LBGalleryScreen()),
      ),

    // Multiplayer — order matters: /multiplayer/game MUST come before
    // /multiplayer/:gameId, otherwise GoRouter matches "game" as a gameId.
    GoRoute(
      path: AppRoutes.multiplayerLobby,
      name: 'multiplayerLobby',
      pageBuilder: (context, state) =>
          _zoomPage(context, state, const MultiplayerLobbyScreen()),
    ),
    GoRoute(
      path: AppRoutes.multiplayerGame,
      name: 'multiplayerGame',
      pageBuilder: (context, state) =>
          _scalePage(context, state, const MultiplayerGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.multiplayerLobbyWithId,
      name: 'multiplayerLobbyWithId',
      pageBuilder: (context, state) {
        final gameId = state.pathParameters['gameId'];
        return _zoomPage(context, state, MultiplayerLobbyScreen(gameId: gameId));
      },
    ),
  ],
);
