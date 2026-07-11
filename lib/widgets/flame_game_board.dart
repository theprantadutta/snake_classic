import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';

/// The single-player gameplay board, rendered with the Flame engine.
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

  /// Boundary frame for the playfield. Deliberately light-handed: the board
  /// interior now continues the screen background's ambient gradient and
  /// grid, so the frame only needs to mark the wall line — a thin accent
  /// hairline and one soft glow — instead of the old heavy 3-4px border +
  /// four stacked shadows that made the playfield look like a separate,
  /// zoomed-in panel floating over the scene. Tournament mode keeps its
  /// purple/gold identity, similarly slimmed.
  BoxDecoration _boardFrameDecoration(GameTheme theme) {
    return BoxDecoration(
      border: Border.all(
        color: widget.isTournamentMode
            ? Colors.purple.withValues(alpha: 0.55)
            : theme.accentColor.withValues(alpha: 0.35),
        width: widget.isTournamentMode ? 2.0 : 1.5,
      ),
      borderRadius: BorderRadius.circular(0),
      boxShadow: widget.isTournamentMode
          ? [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ]
          : [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.16),
                blurRadius: 18,
                spreadRadius: -2,
                offset: const Offset(0, 0),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 14,
                spreadRadius: 0,
                offset: const Offset(0, 6),
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
                    // No extra margin: the game screen already pads the board
                    // slot; the old 8px on top of that shrank the playfield
                    // and deepened the floating-panel look.
                    margin: EdgeInsets.zero,
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
