import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:snake_classic/game/flame/components/legacy_board_component.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/presentation/bloc/game/game_state.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/utils/constants.dart';

/// The Flame engine root for single-player gameplay.
///
/// The [GameCubit] still owns the tick loop and the [SnakeSimulation]; this
/// game receives each emitted [GameCubitState] via [syncState] and renders it.
/// Smooth inter-tick movement (and the crash death-lunge) are computed natively
/// in [update] — the Flame replacement for the legacy widget's
/// `AnimationController`s.
///
/// The world uses a fixed-resolution camera in **pixel space** ([GameConstants.cellSize]
/// pixels per cell), matching the legacy `CustomPainter`'s coordinate system so
/// the per-theme / per-skin art ports over pixel-for-pixel. Flame scales the
/// fixed resolution to whatever size the hosting widget gives it.
class SnakeFlameGame extends FlameGame {
  SnakeFlameGame({
    required this.initialCubitState,
    required this.initialTheme,
    required this.initialPremiumState,
  }) {
    final gs = initialCubitState.gameState;
    boardWidth = gs?.boardWidth ?? 20;
    boardHeight = gs?.boardHeight ?? 20;
    cubitState = initialCubitState;
    theme = initialTheme;
    premiumState = initialPremiumState;
  }

  final GameCubitState initialCubitState;
  final GameTheme initialTheme;
  final PremiumState initialPremiumState;

  late int boardWidth;
  late int boardHeight;

  /// Latest synced state. Components read these each frame.
  late GameCubitState cubitState;
  late GameTheme theme;
  late PremiumState premiumState;

  model.GameState? get gameState => cubitState.gameState;
  model.GameState? get previousGameState => cubitState.previousGameState;

  double get worldWidth => boardWidth * GameConstants.cellSize;
  double get worldHeight => boardHeight * GameConstants.cellSize;

  /// Smooth 0..1 progress between [previousGameState] and [gameState] for the
  /// current tick (or the eased death-lunge while crashed).
  double moveProgress = 0;
  double _elapsedSinceTick = 0;

  // Crash death-lunge clock (one-shot, ~200ms, matches the legacy lunge).
  bool _lunging = false;
  double _lungeElapsed = 0;

  model.GameState? _interpolatedFrom;

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: worldWidth,
      height: worldHeight,
    );
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    await world.add(LegacyBoardComponent());
  }

  /// Push the latest cubit state, theme and premium cosmetics into the game.
  /// A new [model.GameState] object restarts the inter-tick interpolation clock.
  void syncState(
    GameCubitState newState,
    GameTheme newTheme,
    PremiumState newPremiumState,
  ) {
    theme = newTheme;
    premiumState = newPremiumState;
    final incoming = newState.gameState;
    if (!identical(incoming, _interpolatedFrom)) {
      _interpolatedFrom = incoming;
      _elapsedSinceTick = 0;
    }
    cubitState = newState;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final gs = gameState;
    if (gs == null) return;

    // Crashed: run the eased death-lunge once. Wall deaths lunge only partway
    // so the head presses into the wall instead of being clipped away.
    if (gs.status == model.GameStatus.crashed) {
      if (!_lunging) {
        _lunging = true;
        _lungeElapsed = 0;
      }
      _lungeElapsed += dt;
      final lungeT = (_lungeElapsed / 0.2).clamp(0.0, 1.0);
      final target =
          gs.crashReason == model.CrashReason.wallCollision ? 0.5 : 1.0;
      moveProgress = Curves.easeOut.transform(lungeT) * target;
      return;
    }
    _lunging = false;

    if (gs.status != model.GameStatus.playing) {
      moveProgress = 0;
      return;
    }

    // gameSpeed is ms/tick; advance interpolation by wall-clock dt.
    final tickSeconds = gs.gameSpeed / 1000.0;
    _elapsedSinceTick += dt;
    moveProgress = tickSeconds <= 0
        ? 1.0
        : (_elapsedSinceTick / tickSeconds).clamp(0.0, 1.0);
  }
}
