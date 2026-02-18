import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/models/game_replay.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/achievements_screen.dart';
import 'package:snake_classic/screens/battle_pass_screen.dart';
import 'package:snake_classic/screens/cosmetics_screen.dart';
import 'package:snake_classic/screens/daily_challenges_screen.dart';
import 'package:snake_classic/screens/first_time_auth_screen.dart';
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
import 'package:snake_classic/screens/premium_benefits_screen.dart';
import 'package:snake_classic/screens/profile_screen.dart';
import 'package:snake_classic/screens/replay_viewer_screen.dart';
import 'package:snake_classic/screens/replays_screen.dart';
import 'package:snake_classic/screens/settings_screen.dart';
import 'package:snake_classic/screens/statistics_screen.dart';
import 'package:snake_classic/screens/store_screen.dart';
import 'package:snake_classic/screens/theme_selector_screen.dart';
import 'package:snake_classic/screens/tournament_detail_screen.dart';
import 'package:snake_classic/screens/tournaments_screen.dart';

/// Zoom-in page transition (default for most routes)
CustomTransitionPage<void> _zoomPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// Scale page transition (dramatic reveal for game screen)
CustomTransitionPage<void> _scalePage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
      );
    },
  );
}

/// Global GoRouter instance for the application.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.loading,
  debugLogDiagnostics: true,
  routes: [
    // Core routes
    GoRoute(
      path: AppRoutes.loading,
      name: 'loading',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: AppRoutes.firstTimeAuth,
      name: 'firstTimeAuth',
      pageBuilder: (context, state) =>
          _zoomPage(state, const FirstTimeAuthScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => _zoomPage(state, const HomeScreen()),
    ),

    // Game flow
    GoRoute(
      path: AppRoutes.game,
      name: 'game',
      pageBuilder: (context, state) => _scalePage(state, const GameScreen()),
    ),
    GoRoute(
      path: AppRoutes.gameOver,
      name: 'gameOver',
      pageBuilder: (context, state) =>
          _zoomPage(state, const GameOverScreen()),
    ),

    // Profile & Stats
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      pageBuilder: (context, state) =>
          _zoomPage(state, const ProfileScreen()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      pageBuilder: (context, state) =>
          _zoomPage(state, const SettingsScreen()),
    ),
    GoRoute(
      path: AppRoutes.statistics,
      name: 'statistics',
      pageBuilder: (context, state) =>
          _zoomPage(state, const StatisticsScreen()),
    ),
    GoRoute(
      path: AppRoutes.achievements,
      name: 'achievements',
      pageBuilder: (context, state) =>
          _zoomPage(state, const AchievementsScreen()),
    ),

    // Social & Competitive
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      pageBuilder: (context, state) =>
          _zoomPage(state, const LeaderboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.friendsLeaderboard,
      name: 'friendsLeaderboard',
      pageBuilder: (context, state) =>
          _zoomPage(state, const FriendsLeaderboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.friends,
      name: 'friends',
      pageBuilder: (context, state) =>
          _zoomPage(state, const FriendsScreen()),
    ),
    GoRoute(
      path: AppRoutes.tournaments,
      name: 'tournaments',
      pageBuilder: (context, state) =>
          _zoomPage(state, const TournamentsScreen()),
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
        return _zoomPage(state, StoreScreen(initialTab: initialTab));
      },
    ),
    GoRoute(
      path: AppRoutes.premiumBenefits,
      name: 'premiumBenefits',
      pageBuilder: (context, state) =>
          _zoomPage(state, const PremiumBenefitsScreen()),
    ),
    GoRoute(
      path: AppRoutes.cosmetics,
      name: 'cosmetics',
      pageBuilder: (context, state) =>
          _zoomPage(state, const CosmeticsScreen()),
    ),
    GoRoute(
      path: AppRoutes.battlePass,
      name: 'battlePass',
      pageBuilder: (context, state) =>
          _zoomPage(state, const BattlePassScreen()),
    ),

    // Other features
    GoRoute(
      path: AppRoutes.dailyChallenges,
      name: 'dailyChallenges',
      pageBuilder: (context, state) =>
          _zoomPage(state, const DailyChallengesScreen()),
    ),
    GoRoute(
      path: AppRoutes.instructions,
      name: 'instructions',
      pageBuilder: (context, state) =>
          _zoomPage(state, const InstructionsScreen()),
    ),
    GoRoute(
      path: AppRoutes.themeSelector,
      name: 'themeSelector',
      pageBuilder: (context, state) =>
          _zoomPage(state, const ThemeSelectorScreen()),
    ),
    GoRoute(
      path: AppRoutes.replays,
      name: 'replays',
      pageBuilder: (context, state) =>
          _zoomPage(state, const ReplaysScreen()),
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
          state,
          ReplayViewerScreen(
            replayId: replayId,
            replay: replay,
          ),
        );
      },
    ),

    // Multiplayer — order matters: /multiplayer/game MUST come before
    // /multiplayer/:gameId, otherwise GoRouter matches "game" as a gameId.
    GoRoute(
      path: AppRoutes.multiplayerLobby,
      name: 'multiplayerLobby',
      pageBuilder: (context, state) =>
          _zoomPage(state, const MultiplayerLobbyScreen()),
    ),
    GoRoute(
      path: AppRoutes.multiplayerGame,
      name: 'multiplayerGame',
      pageBuilder: (context, state) =>
          _scalePage(state, const MultiplayerGameScreen()),
    ),
    GoRoute(
      path: AppRoutes.multiplayerLobbyWithId,
      name: 'multiplayerLobbyWithId',
      pageBuilder: (context, state) {
        final gameId = state.pathParameters['gameId'];
        return _zoomPage(state, MultiplayerLobbyScreen(gameId: gameId));
      },
    ),
  ],
);
