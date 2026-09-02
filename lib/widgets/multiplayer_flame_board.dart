import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/board_frame.dart';

/// The multiplayer gameplay board, rendered with the Flame engine. Wears the
/// shared [BoardFrame] and hosts a [MultiplayerFlameGame] (fill + grid +
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
        // Thread the localized "You" label into the (context-less) Flame
        // painter layer. Cheap plain-field write, safe to do every build.
        _game.youLabel = AppLocalizations.of(context)!.mpYou;
        _game.syncState(snapshot: widget.snapshot, theme: theme);

        // Same frame as the single-player board. The screen hands us a
        // square (see the LayoutBuilder in MultiplayerGameScreen), so the
        // frame hugs the playfield with no slack above or below it.
        return RepaintBoundary(
          child: BoardFrame(
            theme: theme,
            child: GameWidget(
              key: ValueKey('mp-${widget.boardSize}'),
              game: _game,
            ),
          ),
        );
      },
    );
  }
}
