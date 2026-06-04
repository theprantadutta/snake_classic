import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:snake_classic/game/flame/components/game_particles_component.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/game/flame/rendering/particles.dart'
    show ParticleConfig;
import 'package:snake_classic/game/flame/rendering/multiplayer_board_painter.dart'
    show MultiplayerBoardPainter, MultiplayerGridBackgroundPainter;

/// Flame engine root for multiplayer gameplay (2–4 snakes).
///
/// `MultiplayerGameScreen` still owns the local tick loop + SignalR sync; this
/// game receives the latest server [MultiplayerGame] plus the local player's
/// snake via [syncState] and renders all players. It reuses the multiplayer
/// painters for parity, drives the food pulse from the game clock, and emits a
/// Flame-native food burst when the local score rises.
class MultiplayerFlameGame extends FlameGame {
  MultiplayerFlameGame({
    required this.game,
    required this.currentUserId,
    required this.localSnake,
    required this.localDirection,
    required this.localScore,
    required this.localIsAlive,
    required this.theme,
  }) {
    boardSize = game.gameSettings['boardSize'] ?? 20;
    _lastScore = localScore;
  }

  MultiplayerGame game;
  String currentUserId;
  List<Position> localSnake;
  Direction localDirection;
  int localScore;
  bool localIsAlive;
  GameTheme theme;

  late int boardSize;
  late int _lastScore;

  double _elapsed = 0;
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

  void syncState({
    required MultiplayerGame game,
    required String currentUserId,
    required List<Position> localSnake,
    required Direction localDirection,
    required int localScore,
    required bool localIsAlive,
    required GameTheme theme,
  }) {
    this.game = game;
    this.currentUserId = currentUserId;
    this.localDirection = localDirection;
    this.localIsAlive = localIsAlive;
    this.theme = theme;

    // Food burst when the local score rises — emit at the cell the head just
    // moved onto (where the food was).
    if (localScore > _lastScore && localSnake.isNotEmpty) {
      final head = localSnake.first;
      _particles?.emitAt(
        Offset(
          head.x * GameConstants.cellSize + GameConstants.cellSize / 2,
          head.y * GameConstants.cellSize + GameConstants.cellSize / 2,
        ),
        ParticleConfig.appleFoodExplosion,
      );
    }
    _lastScore = localScore;
    this.localScore = localScore;
    this.localSnake = localSnake;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
  }
}

/// Renders the multiplayer grid + all snakes + food by driving the reused
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
      game: game.game,
      currentUserId: game.currentUserId,
      localSnake: game.localSnake,
      localDirection: game.localDirection,
      localIsAlive: game.localIsAlive,
      theme: game.theme,
      pulseAnimation: AlwaysStoppedAnimation<double>(game.pulse),
      moveProgress: 0,
      boardSize: game.boardSize,
    ).paint(canvas, size);
  }
}
