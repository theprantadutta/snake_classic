import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';

/// Flame-backed drop-in replacement for the legacy `GameBoard` widget. Shares
/// the same public constructor so it can be swapped behind
/// `FeatureFlags.useFlameBoard` without touching the call site's layout.
///
/// It hosts a single [SnakeFlameGame] instance and forwards each relevant
/// [GameCubitState] / theme change into it via [SnakeFlameGame.syncState]. The
/// game reads that state every frame and renders it; smooth movement is
/// computed inside the game, not here.
class FlameGameBoard extends StatefulWidget {
  const FlameGameBoard({
    super.key,
    required this.gameState,
    this.cellSize = GameConstants.cellSize,
    this.isTournamentMode = false,
  });

  final GameState gameState;
  final double cellSize;
  final bool isTournamentMode;

  @override
  State<FlameGameBoard> createState() => _FlameGameBoardState();
}

class _FlameGameBoardState extends State<FlameGameBoard> {
  late SnakeFlameGame _game;

  @override
  void initState() {
    super.initState();
    final themeState = context.read<ThemeCubit>().state;
    _game = SnakeFlameGame(
      initialCubitState: context.read<GameCubit>().state,
      initialTheme: themeState.currentTheme,
      initialPremiumState: context.read<PremiumCubit>().state,
      initialTrailSystemEnabled: themeState.isTrailSystemEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<PremiumCubit, PremiumState>(
          // Only re-sync on cosmetic changes that affect rendering.
          buildWhen: (prev, next) =>
              prev.selectedSkinId != next.selectedSkinId ||
              prev.selectedTrailId != next.selectedTrailId ||
              prev.ownedSkins != next.ownedSkins ||
              prev.ownedTrails != next.ownedTrails,
          builder: (context, premiumState) {
            return BlocBuilder<GameCubit, GameCubitState>(
              // Rebuild only when the committed tick state changes (not on the
              // intra-tick interpolation, which the game advances itself).
              buildWhen: (prev, next) =>
                  !identical(prev.gameState, next.gameState) ||
                  !identical(prev.previousGameState, next.previousGameState),
              builder: (context, cubitState) {
                final gs = cubitState.gameState;
                // Board dimensions can change between runs (settings); the
                // fixed-resolution camera is baked at construction, so rebuild
                // the game when they differ.
                if (gs != null &&
                    (gs.boardWidth != _game.boardWidth ||
                        gs.boardHeight != _game.boardHeight)) {
                  _game = SnakeFlameGame(
                    initialCubitState: cubitState,
                    initialTheme: themeState.currentTheme,
                    initialPremiumState: premiumState,
                    initialTrailSystemEnabled: themeState.isTrailSystemEnabled,
                  );
                }
                _game.syncState(
                  cubitState,
                  themeState.currentTheme,
                  premiumState,
                  trailEnabled: themeState.isTrailSystemEnabled,
                );
                return GameWidget(
                  key: ValueKey(
                    gs == null ? 'none' : '${gs.boardWidth}x${gs.boardHeight}',
                  ),
                  game: _game,
                );
              },
            );
          },
        );
      },
    );
  }
}
