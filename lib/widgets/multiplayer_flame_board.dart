import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/direction.dart';

/// Flame-backed drop-in replacement for [MultiplayerGameAdapter]. Same
/// constructor, swapped behind `FeatureFlags.useFlameBoard`. Reproduces the
/// adapter's purple/gold framed container and hosts a [MultiplayerFlameGame]
/// (grid + all snakes + food + particles) inside it.
class MultiplayerFlameBoard extends StatefulWidget {
  const MultiplayerFlameBoard({
    super.key,
    required this.game,
    required this.currentUserId,
    required this.localSnake,
    required this.localDirection,
    required this.localScore,
    required this.localIsAlive,
  });

  final MultiplayerGame game;
  final String currentUserId;
  final List<Position> localSnake;
  final Direction localDirection;
  final int localScore;
  final bool localIsAlive;

  @override
  State<MultiplayerFlameBoard> createState() => _MultiplayerFlameBoardState();
}

class _MultiplayerFlameBoardState extends State<MultiplayerFlameBoard> {
  late MultiplayerFlameGame _game;

  int get _boardSize => widget.game.gameSettings['boardSize'] ?? 20;

  @override
  void initState() {
    super.initState();
    _game = _createGame(context.read<ThemeCubit>().state.currentTheme);
  }

  MultiplayerFlameGame _createGame(theme) => MultiplayerFlameGame(
        game: widget.game,
        currentUserId: widget.currentUserId,
        localSnake: widget.localSnake,
        localDirection: widget.localDirection,
        localScore: widget.localScore,
        localIsAlive: widget.localIsAlive,
        theme: theme,
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;
        if (_boardSize != _game.boardSize) {
          _game = _createGame(theme);
        }
        _game.syncState(
          game: widget.game,
          currentUserId: widget.currentUserId,
          localSnake: widget.localSnake,
          localDirection: widget.localDirection,
          localScore: widget.localScore,
          localIsAlive: widget.localIsAlive,
          theme: theme,
        );

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
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
                color: Colors.purple.withValues(alpha: 0.7),
                width: 4.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.35),
                  blurRadius: 20,
                ),
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.25),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.backgroundColor.withValues(alpha: 0.95),
                      theme.backgroundColor.withValues(alpha: 0.98),
                      theme.accentColor.withValues(alpha: 0.05),
                      theme.foodColor.withValues(alpha: 0.02),
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GameWidget(
                      key: ValueKey('mp-$_boardSize'),
                      game: _game,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
