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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FirstTimeAuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
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
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
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
    ),

    // Game flow
    GoRoute(
      path: AppRoutes.game,
      name: 'game',
      builder: (context, state) => const GameScreen(),
    ),
    GoRoute(
      path: AppRoutes.gameOver,
      name: 'gameOver',
      builder: (context, state) => const GameOverScreen(),
    ),

    // Profile & Stats
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.statistics,
      name: 'statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.achievements,
      name: 'achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),

    // Social & Competitive
    GoRoute(
      path: AppRoutes.leaderboard,
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.friendsLeaderboard,
      name: 'friendsLeaderboard',
      builder: (context, state) => const FriendsLeaderboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.friends,
      name: 'friends',
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: AppRoutes.tournaments,
      name: 'tournaments',
      builder: (context, state) => const TournamentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.tournamentDetail,
      name: 'tournamentDetail',
      builder: (context, state) {
        // Get tournament ID from path parameter
        final tournamentId = state.pathParameters['id'] ?? '';
        // Get tournament object from extra if available (for instant display)
        final tournament = state.extra as Tournament?;

        return TournamentDetailScreen(
          tournamentId: tournamentId,
          tournament: tournament,
        );
      },
    ),

    // Monetization
    GoRoute(
      path: AppRoutes.store,
      name: 'store',
      builder: (context, state) {
        // Get initial tab from query parameter
        final tabString = state.uri.queryParameters['tab'];
        final initialTab = tabString != null ? int.tryParse(tabString) ?? 0 : 0;
        return StoreScreen(initialTab: initialTab);
      },
    ),
    GoRoute(
      path: AppRoutes.premiumBenefits,
      name: 'premiumBenefits',
      builder: (context, state) => const PremiumBenefitsScreen(),
    ),
    GoRoute(
      path: AppRoutes.cosmetics,
      name: 'cosmetics',
      builder: (context, state) => const CosmeticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.battlePass,
      name: 'battlePass',
      builder: (context, state) => const BattlePassScreen(),
    ),

    // Other features
    GoRoute(
      path: AppRoutes.dailyChallenges,
      name: 'dailyChallenges',
      builder: (context, state) => const DailyChallengesScreen(),
    ),
    GoRoute(
      path: AppRoutes.instructions,
      name: 'instructions',
      builder: (context, state) => const InstructionsScreen(),
    ),
    GoRoute(
      path: AppRoutes.themeSelector,
      name: 'themeSelector',
      builder: (context, state) => const ThemeSelectorScreen(),
    ),
    GoRoute(
      path: AppRoutes.replays,
      name: 'replays',
      builder: (context, state) => const ReplaysScreen(),
    ),
    GoRoute(
      path: AppRoutes.replayViewer,
      name: 'replayViewer',
      builder: (context, state) {
        // Get replay ID from path parameter
        final replayId = state.pathParameters['id'] ?? '';
        // Get replay object from extra if available (for instant display)
        final replay = state.extra as GameReplay?;

        return ReplayViewerScreen(
          replayId: replayId,
          replay: replay,
        );
      },
    ),

    // Multiplayer
    GoRoute(
      path: AppRoutes.multiplayerLobby,
      name: 'multiplayerLobby',
      builder: (context, state) => const MultiplayerLobbyScreen(),
    ),
    GoRoute(
      path: AppRoutes.multiplayerLobbyWithId,
      name: 'multiplayerLobbyWithId',
      builder: (context, state) {
        final gameId = state.pathParameters['gameId'];
        return MultiplayerLobbyScreen(gameId: gameId);
      },
    ),
    GoRoute(
      path: AppRoutes.multiplayerGame,
      name: 'multiplayerGame',
      builder: (context, state) => const MultiplayerGameScreen(),
    ),
  ],
);
