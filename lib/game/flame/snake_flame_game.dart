import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:snake_classic/game/flame/components/game_particles_component.dart';
import 'package:snake_classic/game/flame/components/legacy_board_component.dart';
import 'package:snake_classic/game/flame/components/snake_trail_component.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/presentation/bloc/game/game_state.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/game/flame/rendering/particles.dart'
    show ParticleConfig;

/// The Flame engine root for single-player gameplay.
///
/// The [GameCubit] still owns the tick loop and the [SnakeSimulation]; this
/// game receives each emitted [GameCubitState] via [syncState] and renders it.
/// Smooth inter-tick movement (and the crash death-lunge) are computed natively
/// in [update]. The component tree is: board (legacy painter reuse) → snake
/// trail → explosion particles, all in a fixed-resolution pixel-space camera
/// ([GameConstants.cellSize] px per cell) matching the legacy renderer.
class SnakeFlameGame extends FlameGame {
  SnakeFlameGame({
    required this.initialCubitState,
    required this.initialTheme,
    required this.initialPremiumState,
    this.initialTrailSystemEnabled = true,
  }) {
    final gs = initialCubitState.gameState;
    boardWidth = gs?.boardWidth ?? 20;
    boardHeight = gs?.boardHeight ?? 20;
    cubitState = initialCubitState;
    theme = initialTheme;
    premiumState = initialPremiumState;
    trailSystemEnabled = initialTrailSystemEnabled;
  }

  final GameCubitState initialCubitState;
  final GameTheme initialTheme;
  final PremiumState initialPremiumState;
  final bool initialTrailSystemEnabled;

  late int boardWidth;
  late int boardHeight;

  /// Latest synced state. Components read these each frame.
  late GameCubitState cubitState;
  late GameTheme theme;
  late PremiumState premiumState;
  late bool trailSystemEnabled;

  model.GameState? get gameState => cubitState.gameState;
  model.GameState? get previousGameState => cubitState.previousGameState;

  double get worldWidth => boardWidth * GameConstants.cellSize;
  double get worldHeight => boardHeight * GameConstants.cellSize;

  /// Smooth 0..1 progress between [previousGameState] and [gameState] for the
  /// current tick (or the eased death-lunge while crashed).
  double moveProgress = 0;
  double _elapsedSinceTick = 0;

  // Crash death-lunge clock (one-shot, ~200ms, matches the legacy lunge).
  // Keeps accumulating past the lunge — it doubles as the clock for the
  // rest of the in-world death sequence below.
  bool _lunging = false;
  double _lungeElapsed = 0;

  // ---- In-world death sequence -----------------------------------------
  // Timeline (seconds since crash): 0-0.2 lunge → 0.2-0.55 the body
  // blinks white three times → 0.55-1.5 segments disintegrate tail-to-
  // head, each emitting a small dust poof as it vanishes. The board
  // component reads [deathFlashAlpha] and [deathKeepCount] every frame;
  // the crash banner (chrome) only appears after this plays out.
  static const double _deathFlashStart = 0.2;
  static const double _deathFlashEnd = 0.55;
  static const double _deathDisintegrateEnd = 1.5;
  static const int _keepAll = 1 << 30;

  /// White-blink alpha over the snake body during the flash phase.
  double deathFlashAlpha = 0;

  /// How many leading segments (head first) of the fatal snake are still
  /// visible. [_keepAll] outside the disintegrate phase.
  int deathKeepCount = _keepAll;
  int _deathPoofEmitted = 0;

  // Last gameState processed for event detection (mirrors the legacy widget's
  // oldWidget.gameState comparison).
  model.GameState? _lastProcessed;

  GameParticlesComponent? _particles;

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

    _particles = GameParticlesComponent();
    await world.addAll([
      LegacyBoardComponent(),
      SnakeTrailComponent(),
      _particles!,
    ]);
  }

  /// Push the latest cubit state, theme and cosmetics into the game. A new
  /// [model.GameState] object restarts the inter-tick interpolation clock and
  /// triggers explosion/collection particle bursts.
  void syncState(
    GameCubitState newState,
    GameTheme newTheme,
    PremiumState newPremiumState, {
    required bool trailEnabled,
  }) {
    theme = newTheme;
    premiumState = newPremiumState;
    trailSystemEnabled = trailEnabled;

    final incoming = newState.gameState;
    if (!identical(incoming, _lastProcessed)) {
      _detectEvents(_lastProcessed, incoming);
      _lastProcessed = incoming;
      _interpolatedReset(incoming);
    }
    cubitState = newState;

    // Battery: while the game is paused the board is frozen behind the pause
    // overlay, so there's nothing to animate — stop the engine's update/render
    // loop entirely instead of redrawing the whole board at 60fps. The last
    // rendered frame stays on screen (the frozen board), and resuming to any
    // non-paused state restarts the loop. We don't pause on crashed/game-over
    // because the death-lunge and explosion particles still need to animate.
    final isPaused = incoming?.status == model.GameStatus.paused;
    if (isPaused && !paused) {
      pauseEngine();
    } else if (!isPaused && paused) {
      resumeEngine();
    }
  }

  model.GameState? _interpolatedFrom;
  void _interpolatedReset(model.GameState? incoming) {
    if (!identical(incoming, _interpolatedFrom)) {
      _interpolatedFrom = incoming;
      _elapsedSinceTick = 0;
    }
  }

  /// Emit particle bursts for food consumed / power-up collected / crash,
  /// comparing the previously-processed state against the new one. Ported from
  /// the legacy GameBoard `_checkForGameEvents`.
  void _detectEvents(model.GameState? previous, model.GameState? current) {
    final particles = _particles;
    if (particles == null || previous == null || current == null) return;

    // Food consumed: locate which food the head moved onto last frame so the
    // burst lands on the exact eaten cell (multi-food safe).
    if (current.score > previous.score) {
      final eatenCell = current.snake.head;
      Food? eaten;
      if (previous.food != null && previous.food!.position == eatenCell) {
        eaten = previous.food;
      } else {
        for (final f in previous.foods) {
          if (f.position == eatenCell) {
            eaten = f;
            break;
          }
        }
      }
      if (eaten != null) {
        particles.emitAt(_cellCenter(eaten.position.x, eaten.position.y),
            _foodConfig(eaten.type));
      }
    }

    // Power-up collected.
    if (previous.powerUp != null && current.powerUp == null) {
      final p = previous.powerUp!;
      particles.emitAt(_cellCenter(p.position.x, p.position.y),
          _powerUpConfig(p.type));
    }

    // Crash.
    if (current.status == model.GameStatus.crashed &&
        previous.status != model.GameStatus.crashed &&
        current.crashPosition != null) {
      final c = current.crashPosition!;
      particles.emitAt(_cellCenter(c.x, c.y), ParticleConfig.explosion);
    }
  }

  Offset _cellCenter(int x, int y) => Offset(
        x * GameConstants.cellSize + GameConstants.cellSize / 2,
        y * GameConstants.cellSize + GameConstants.cellSize / 2,
      );

  ParticleConfig _foodConfig(FoodType type) => switch (type) {
        FoodType.normal => ParticleConfig.appleFoodExplosion,
        FoodType.bonus => ParticleConfig.bonusFoodExplosion,
        FoodType.special => ParticleConfig.specialFoodExplosion,
      };

  ParticleConfig _powerUpConfig(PowerUpType type) => switch (type) {
        PowerUpType.speedBoost => ParticleConfig.speedBoostCollection,
        PowerUpType.invincibility => ParticleConfig.invincibilityCollection,
        PowerUpType.scoreMultiplier => ParticleConfig.scoreMultiplierCollection,
        PowerUpType.slowMotion => ParticleConfig.slowMotionCollection,
      };

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
        _deathPoofEmitted = gs.snake.length;
      }
      _lungeElapsed += dt;
      final lungeT = (_lungeElapsed / 0.2).clamp(0.0, 1.0);
      final target =
          gs.crashReason == model.CrashReason.wallCollision ? 0.5 : 1.0;
      moveProgress = Curves.easeOut.transform(lungeT) * target;
      _updateDeathSequence(gs);
      return;
    }
    _lunging = false;
    deathFlashAlpha = 0;
    deathKeepCount = _keepAll;

    if (gs.status != model.GameStatus.playing) {
      moveProgress = 0;
      return;
    }

    final tickSeconds = gs.gameSpeed / 1000.0;
    _elapsedSinceTick += dt;
    moveProgress = tickSeconds <= 0
        ? 1.0
        : (_elapsedSinceTick / tickSeconds).clamp(0.0, 1.0);
  }

  /// Advance the flash + disintegration phases of the death sequence.
  /// Revive rebuilds the snake from the pre-crash state, so everything
  /// here is render-only — nothing mutates the game state.
  void _updateDeathSequence(model.GameState gs) {
    final t = _lungeElapsed;

    if (t >= _deathFlashStart && t < _deathFlashEnd) {
      final p =
          (t - _deathFlashStart) / (_deathFlashEnd - _deathFlashStart);
      // Three cosine blinks across the window.
      deathFlashAlpha = 0.55 * (0.5 - 0.5 * math.cos(p * math.pi * 6));
    } else {
      deathFlashAlpha = 0;
    }

    final n = gs.snake.length;
    if (t < _deathFlashEnd || n <= 2) {
      deathKeepCount = _keepAll;
      return;
    }

    final p = ((t - _deathFlashEnd) /
            (_deathDisintegrateEnd - _deathFlashEnd))
        .clamp(0.0, 1.0);
    final eased = Curves.easeIn.transform(p);
    // Disintegrate down to head + neck; the final pair stays so the crash
    // pose (head pressed into whatever killed it) remains readable under
    // the banner and the revive offer.
    final keep = (n - (n - 2) * eased).round().clamp(2, n);

    // Dust poof for each segment at the moment it vanishes. Higher index
    // = closer to the tail, so removal walks tail-to-head.
    if (keep < _deathPoofEmitted) {
      for (var i = keep; i < _deathPoofEmitted && i < n; i++) {
        final c = gs.snake.body[i];
        _particles?.emitAt(
            _cellCenter(c.x, c.y), ParticleConfig.segmentPoof);
      }
      _deathPoofEmitted = keep;
    }
    deathKeepCount = keep;
  }
}
