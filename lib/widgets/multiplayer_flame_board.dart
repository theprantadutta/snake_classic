import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';

/// The multiplayer gameplay board, rendered with the Flame engine. Draws the
/// purple/gold framed container and hosts a [MultiplayerFlameGame] (grid +
/// both snakes + food + particles) inside it. Everything on the board comes
/// from the server's [MatchSnapshot] stream — the widget just relays the
/// latest snapshot into the running game for interpolation.
class MultiplayerFlameBoard extends StatefulWidget {
  const MultiplayerFlameBoard({
    super.key,
    required this.snapshot,
    required this.boardSize,
    required this.currentUserId,
  });

  final MatchSnapshot snapshot;
  final int boardSize;
  final String currentUserId;

  @override
  State<MultiplayerFlameBoard> createState() => _MultiplayerFlameBoardState();
}

class _MultiplayerFlameBoardState extends State<MultiplayerFlameBoard> {
  late MultiplayerFlameGame _game;

  @override
  void initState() {
    super.initState();
    _game = _createGame(context.read<ThemeCubit>().state.currentTheme);
  }

  MultiplayerFlameGame _createGame(GameTheme theme) => MultiplayerFlameGame(
        snapshot: widget.snapshot,
        currentUserId: widget.currentUserId,
        boardSize: widget.boardSize,
        theme: theme,
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;
        if (widget.boardSize != _game.boardSize) {
          _game = _createGame(theme);
        }
        _game.syncState(snapshot: widget.snapshot, theme: theme);

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
                      key: ValueKey('mp-${widget.boardSize}'),
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
