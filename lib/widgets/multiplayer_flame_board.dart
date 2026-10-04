import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/game/multiplayer/local_snake_predictor.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/board_frame.dart';

/// The multiplayer gameplay board, rendered with the Flame engine. Wears the
/// shared [BoardFrame] (the Living Board wall hairline) and hosts a
/// [MultiplayerFlameGame] (board + grid + both snakes as Living Board cells
/// + food + particles) inside it. Everything on the board comes
/// from the server's [MatchSnapshot] stream, plus the cubit's prediction
/// of the local snake — the widget just relays both into the running game.
///
/// Every snapshot is relayed the moment the cubit emits it, through a
/// listener, not just the ones a rebuild happens to see: two snapshots that
/// land within one frame are built once, and the game times its render
/// clocks off arrivals and plays the rival back from the full sequence.
class MultiplayerFlameBoard extends StatefulWidget {
  const MultiplayerFlameBoard({
    super.key,
    required this.snapshot,
    required this.boardSize,
    required this.currentUserId,
    this.prediction,
    this.onLocalFoodEaten,
  });

  final MatchSnapshot snapshot;
  final int boardSize;
  final String currentUserId;

  /// The local snake ahead of [snapshot] (purely visual).
  final LocalPrediction? prediction;

  /// One of your own bites has just been shown on the board — the moment
  /// for its chirp and juice (see [MultiplayerFlameGame.onLocalFoodEaten]).
  final VoidCallback? onLocalFoodEaten;

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
    prediction: widget.prediction,
    onLocalFoodEaten: widget.onLocalFoodEaten,
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
        _game.youLabel = AppLocalizations.of(context)!.lbYou;
        _game.onLocalFoodEaten = widget.onLocalFoodEaten;
        _game.syncState(
          snapshot: widget.snapshot,
          theme: theme,
          prediction: widget.prediction,
        );

        // Same frame as the single-player board. The screen hands us a
        // square (see the LayoutBuilder in MultiplayerGameScreen), so the
        // frame hugs the playfield with no slack above or below it.
        return BlocListener<MultiplayerCubit, MultiplayerState>(
          listenWhen: (prev, curr) =>
              !identical(prev.snapshot, curr.snapshot) ||
              !identical(prev.localPrediction, curr.localPrediction),
          listener: (context, state) {
            final snapshot = state.snapshot;
            if (snapshot == null) return;
            _game.syncState(
              snapshot: snapshot,
              theme: _game.theme,
              prediction: state.localPrediction,
            );
          },
          child: RepaintBoundary(
            child: BoardFrame(
              theme: theme,
              child: GameWidget(
                key: ValueKey('mp-${widget.boardSize}'),
                game: _game,
              ),
            ),
          ),
        );
      },
    );
  }
}
