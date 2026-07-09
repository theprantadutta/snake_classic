import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:snake_classic/game/flame/components/game_particles_component.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/game/flame/rendering/particles.dart'
    show ParticleConfig;
import 'package:snake_classic/game/flame/rendering/multiplayer_board_painter.dart'
    show MultiplayerBoardPainter, MultiplayerGridBackgroundPainter;

/// Flame engine root for multiplayer gameplay (server-authoritative 1v1).
///
/// The screen pushes each authoritative [MatchSnapshot] in via
/// [syncState]; this game keeps the previous tick alongside the current
/// one and interpolates between them with a dt-driven clock over the
/// server's `tick_ms` window (same approach as the single-player
/// `SnakeFlameGame`), so both snakes glide even though positions only
/// arrive a few times per second. Nothing is simulated here — the board
/// painter draws the snapshots verbatim. Food-burst particles fire when
/// the local player's score rises between ticks.
class MultiplayerFlameGame extends FlameGame {
  MultiplayerFlameGame({
    required this.snapshot,
    required this.currentUserId,
    required this.boardSize,
    required this.theme,
  }) : _lastMyScore = snapshot.playerByUserId(currentUserId)?.score ?? 0;

  MatchSnapshot snapshot;

  /// The tick before [snapshot] — the interpolation origin. Null until
  /// the second tick arrives (first frame renders statically).
  MatchSnapshot? previousSnapshot;

  final String currentUserId;
  final int boardSize;
  GameTheme theme;

  int _lastMyScore;

  double _elapsed = 0;

  /// Smooth 0..1 progress between [previousSnapshot] and [snapshot] for
  /// the current server tick.
  double moveProgress = 0;
  double _elapsedSinceTick = 0;

  GameParticlesComponent? _particles;

  double get worldSize => boardSize * GameConstants.cellSize;

  /// Pulse in [0.9, 1.1] over a 2s period (matches the legacy pulse tween).
  double get pulse {
    final p = (_elapsed % 2.0) / 2.0;
    return 0.9 + 0.2 * (1 - (2 * p - 1).abs());
  }

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: worldSize,
      height: worldSize,
    );
    camera.viewfinder
      ..anchor = Anchor.topLeft
      ..position = Vector2.zero();

    _particles = GameParticlesComponent();
    await world.addAll([_MultiplayerBoardComponent(), _particles!]);
  }

  /// Push the latest server snapshot + theme into the game. A new tick
  /// shifts the current snapshot into [previousSnapshot] and restarts
  /// the inter-tick interpolation clock.
  void syncState({required MatchSnapshot snapshot, required GameTheme theme}) {
    this.theme = theme;
    if (identical(snapshot, this.snapshot)) return;

    if (snapshot.tick != this.snapshot.tick) {
      previousSnapshot = this.snapshot;
      _elapsedSinceTick = 0;
    }

    // Food burst when the local score rises — emit at the head cell the
    // snake just moved onto (where the food was).
    final me = snapshot.playerByUserId(currentUserId);
    final head = me?.head;
    if (me != null && head != null && me.score > _lastMyScore) {
      _particles?.emitAt(
        Offset(
          head.x * GameConstants.cellSize + GameConstants.cellSize / 2,
          head.y * GameConstants.cellSize + GameConstants.cellSize / 2,
        ),
        ParticleConfig.appleFoodExplosion,
      );
    }
    _lastMyScore = me?.score ?? _lastMyScore;

    this.snapshot = snapshot;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    final tickSeconds = snapshot.tickMs / 1000.0;
    _elapsedSinceTick += dt;
    moveProgress = tickSeconds <= 0
        ? 1.0
        : (_elapsedSinceTick / tickSeconds).clamp(0.0, 1.0);
  }
}

/// Renders the multiplayer grid + both snakes + food by driving the reused
/// multiplayer painters in the Flame render pass (world pixel-space).
class _MultiplayerBoardComponent extends Component
    with HasGameReference<MultiplayerFlameGame> {
  _MultiplayerBoardComponent() : super(priority: 0);

  @override
  void render(Canvas canvas) {
    final size = Size(game.worldSize, game.worldSize);
    MultiplayerGridBackgroundPainter(game.theme, game.boardSize)
        .paint(canvas, size);
    MultiplayerBoardPainter(
      snapshot: game.snapshot,
      previousSnapshot: game.previousSnapshot,
      currentUserId: game.currentUserId,
      theme: game.theme,
      pulseAnimation: AlwaysStoppedAnimation<double>(game.pulse),
      moveProgress: game.moveProgress,
      boardSize: game.boardSize,
    ).paint(canvas, size);
  }
}
