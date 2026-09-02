import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/board_frame.dart';

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
                  // Frame + corner brackets live in BoardFrame, shared
                  // with the multiplayer board so both read as the same
                  // object. See that widget for the reasoning behind the
                  // inset/arm values.
                  child: BoardFrame(
                    theme: themeState.currentTheme,
                    tournament: widget.isTournamentMode,
                    child: GameWidget(
                      key: ValueKey(
                        gs == null
                            ? 'none'
                            : '${gs.boardWidth}x${gs.boardHeight}',
                      ),
                      game: _game,
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
