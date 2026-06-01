import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:snake_classic/game/flame/components/board_component.dart';
import 'package:snake_classic/game/flame/components/entities_component.dart';
import 'package:snake_classic/game/flame/components/snake_component.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/presentation/bloc/game/game_state.dart';
import 'package:snake_classic/utils/constants.dart';

/// The Flame engine root for single-player gameplay.
///
/// This is a *renderer* skeleton (migration Phase 2): the [GameCubit] still
/// owns the tick loop and the [SnakeSimulation]; this game receives each
/// emitted [GameCubitState] via [syncState] and draws it, computing smooth
/// inter-tick movement natively in [update] instead of via a Flutter
/// `AnimationController`.
///
/// The world uses a fixed-resolution camera sized to the board grid, so every
/// component positions itself in **cell coordinates** (one grid cell == one
/// world unit) and Flame handles scaling to the available widget size.
class SnakeFlameGame extends FlameGame {
  SnakeFlameGame({
    required this.initialCubitState,
    required this.initialTheme,
  }) {
    final gs = initialCubitState.gameState;
    boardWidth = gs?.boardWidth ?? 20;
    boardHeight = gs?.boardHeight ?? 20;
    cubitState = initialCubitState;
    theme = initialTheme;
  }

  final GameCubitState initialCubitState;
  final GameTheme initialTheme;

  late int boardWidth;
  late int boardHeight;

  /// Latest synced cubit state. Components read [gameState] /
  /// [previousGameState] off this each frame.
  late GameCubitState cubitState;
  late GameTheme theme;

  model.GameState? get gameState => cubitState.gameState;
  model.GameState? get previousGameState => cubitState.previousGameState;

  /// Smooth 0..1 progress between [previousGameState] and [gameState], advanced
  /// in [update] by wall-clock dt and reset whenever a new tick arrives.
  double moveProgress = 0;
  double _elapsedSinceTick = 0;

  /// Identity of the last gameState we started interpolating from — used to
  /// detect a fresh tick (new state object) and restart the interpolation.
  model.GameState? _interpolatedFrom;

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: boardWidth.toDouble(),
      height: boardHeight.toDouble(),
    );
    // Place world cell (0,0) at the top-left of the visible area so component
    // cell coordinates map directly onto the grid.
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    await world.addAll([
      BoardComponent(),
      EntitiesComponent(),
      SnakeComponent(),
    ]);
  }

  /// Push the latest cubit state (and theme) into the game. Called from the
  /// hosting Flutter widget on each relevant rebuild. Detecting a new
  /// [model.GameState] object restarts the inter-tick interpolation clock.
  void syncState(GameCubitState newState, GameTheme newTheme) {
    theme = newTheme;
    final incoming = newState.gameState;
    if (!identical(incoming, _interpolatedFrom)) {
      _interpolatedFrom = incoming;
      _elapsedSinceTick = 0;
      moveProgress = 0;
    }
    cubitState = newState;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final gs = gameState;
    if (gs == null || gs.status != model.GameStatus.playing) {
      // Snap to the committed positions when not actively playing (paused,
      // crashed, game over) so nothing keeps drifting.
      moveProgress = gs?.status == model.GameStatus.crashed ? 1.0 : moveProgress;
      return;
    }
    // Tick duration in seconds for the current speed. gameSpeed is ms/tick.
    final tickSeconds = gs.gameSpeed / 1000.0;
    _elapsedSinceTick += dt;
    moveProgress =
        tickSeconds <= 0 ? 1.0 : (_elapsedSinceTick / tickSeconds).clamp(0.0, 1.0);
  }
}
