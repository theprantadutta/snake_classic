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

  /// Boundary frame for the playfield — glowing border plus the multi-layer
  /// ambient/depth shadows. Ported verbatim from the legacy `GameBoard`
  /// decoration (tournament mode swaps in the purple/gold glow) so the Flame
  /// board frames the playfield identically to the Flutter one.
  BoxDecoration _boardFrameDecoration(GameTheme theme) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: [
          theme.accentColor.withValues(alpha: 0.12),
          theme.backgroundColor.withValues(alpha: 0.98),
          theme.backgroundColor,
          Colors.black.withValues(alpha: 0.08),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ),
      border: Border.all(
        color: widget.isTournamentMode
            ? Colors.purple.withValues(alpha: 0.7)
            : theme.accentColor.withValues(alpha: 0.5),
        width: widget.isTournamentMode ? 4.0 : 3.0,
      ),
      borderRadius: BorderRadius.circular(0),
      boxShadow: widget.isTournamentMode
          ? [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.25),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.2),
                blurRadius: 48,
                spreadRadius: -4,
                offset: const Offset(0, 0),
              ),
            ]
          : [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: -1,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: -4,
                offset: const Offset(0, -4),
              ),
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.15),
                blurRadius: 48,
                spreadRadius: -8,
                offset: const Offset(0, 0),
              ),
            ],
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
                // The boundary frame (glowing border + ambient shadow) lives at
                // the Flutter layer in the legacy GameBoard, not in the shared
                // painters — so the Flame board must reproduce it here, else the
                // playfield has no visible edge. Mirrors GameBoard's decorated
                // Container so both renderers frame the board identically.
                return RepaintBoundary(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: _boardFrameDecoration(themeState.currentTheme),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: GameWidget(
                        key: ValueKey(
                          gs == null
                              ? 'none'
                              : '${gs.boardWidth}x${gs.boardHeight}',
                        ),
                        game: _game,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
