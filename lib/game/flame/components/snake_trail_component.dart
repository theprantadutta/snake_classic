import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/snake_trail_system.dart'
    show SnakeTrailPainter, TrailSegment, TrailType;

/// Flame-native snake trail.
///
/// Replaces the legacy `SnakeTrailSystem` widget: the trail-segment
/// accumulation and lifetime are driven by the game loop ([update]) instead of
/// a Flutter `AnimationController`, and the component lives in the Flame render
/// tree. The 13 bespoke trail looks are reused via [SnakeTrailPainter]; the
/// effective trail type is resolved from the synced theme + premium cosmetics.
///
/// Coordinates are world pixel-space (cell * cellSize), matching the board.
class SnakeTrailComponent extends Component
    with HasGameReference<SnakeFlameGame> {
  SnakeTrailComponent() : super(priority: 1);

  final List<TrailSegment> _segments = [];
  double _elapsed = 0;

  double get _cellSize => GameConstants.cellSize;

  /// Animation phase 0..1 over a 2s period (matches the legacy 2s controller).
  double get _animValue => (_elapsed % 2.0) / 2.0;

  @override
  void update(double dt) {
    _elapsed += dt;

    final gs = game.gameState;
    final type = _resolveTrailType();
    final playing = gs?.status == model.GameStatus.playing;

    if (!playing || type == TrailType.none) {
      // Clear stale segments so they don't flash when play resumes.
      if (!playing && _segments.isNotEmpty) _segments.clear();
      return;
    }

    _addSegments(gs!.snake.body, type);
    _cleanupExpired(type);
  }

  @override
  void render(Canvas canvas) {
    final type = _resolveTrailType();
    if (type == TrailType.none || _segments.isEmpty) return;
    SnakeTrailPainter(
      segments: _segments,
      trailType: type,
      animationValue: _animValue,
      currentTimeSeconds: _elapsed,
    ).paint(canvas, Size(game.worldWidth, game.worldHeight));
  }

  // --- Segment accumulation (ported from _SnakeTrailSystemState) ---

  void _addSegments(List<Position> body, TrailType type) {
    if (body.isEmpty) return;
    for (var i = 0; i < body.length; i++) {
      final position = body[i];
      final intensity = (body.length - i) / body.length;
      final screenPosition = Offset(
        position.x * _cellSize + _cellSize / 2,
        position.y * _cellSize + _cellSize / 2,
      );
      final shouldAdd = _segments.isEmpty ||
          _segments.last.position.dx != screenPosition.dx ||
          _segments.last.position.dy != screenPosition.dy;
      if (shouldAdd) {
        _segments.add(TrailSegment(
          position: screenPosition,
          intensity: intensity,
          size: _getTrailSize(i, body.length, type),
          color: _getTrailColor(intensity, type),
          createdAtSeconds: _elapsed,
        ));
      }
    }
    const maxTrailSegments = 50;
    if (_segments.length > maxTrailSegments) {
      _segments.removeRange(0, _segments.length - maxTrailSegments);
    }
  }

  void _cleanupExpired(TrailType type) {
    final maxAge = _getTrailMaxAge(type);
    _segments.removeWhere((s) => s.isExpired(maxAge, _elapsed));
  }

  double _getTrailMaxAge(TrailType type) {
    switch (type) {
      case TrailType.basic:
        return 0.5;
      case TrailType.glow:
      case TrailType.particles:
        return 0.8;
      case TrailType.lightning:
      case TrailType.fire:
        return 0.6;
      case TrailType.rainbow:
      case TrailType.ice:
      case TrailType.star:
      case TrailType.shadow:
        return 1.0;
      case TrailType.cosmic:
        return 1.2;
      case TrailType.neon:
        return 0.7;
      case TrailType.dragon:
        return 0.8;
      case TrailType.none:
        return 0.0;
    }
  }

  double _getTrailSize(int bodyIndex, int bodyLength, TrailType type) {
    final baseSize = _cellSize * 0.3;
    final sizeFactor = 1.0 - (bodyIndex / bodyLength) * 0.5;
    switch (type) {
      case TrailType.glow:
      case TrailType.fire:
      case TrailType.cosmic:
        return baseSize * sizeFactor * 1.5;
      case TrailType.particles:
      case TrailType.star:
        return baseSize * sizeFactor * 0.8;
      case TrailType.lightning:
      case TrailType.neon:
        return baseSize * sizeFactor * 0.6;
      case TrailType.shadow:
        return baseSize * sizeFactor * 1.4;
      case TrailType.dragon:
        return baseSize * sizeFactor * 1.6;
      case TrailType.basic:
      case TrailType.rainbow:
      case TrailType.ice:
      case TrailType.none:
        return baseSize * sizeFactor;
    }
  }

  Color _getTrailColor(double intensity, TrailType type) {
    final baseColor = game.theme.snakeColor;
    final animValue = _animValue;
    switch (type) {
      case TrailType.basic:
        return baseColor.withValues(alpha: intensity * 0.6);
      case TrailType.glow:
        return baseColor.withValues(alpha: intensity * 0.8);
      case TrailType.particles:
        return baseColor.withValues(alpha: intensity * 0.7);
      case TrailType.lightning:
        return Colors.white.withValues(alpha: intensity * 0.9);
      case TrailType.rainbow:
        final hue = (animValue * 360 + intensity * 60) % 360;
        return HSVColor.fromAHSV(intensity * 0.8, hue, 1.0, 1.0).toColor();
      case TrailType.fire:
        final fireIntensity = intensity * 0.8;
        return Color.lerp(
          Colors.red,
          Colors.orange,
          math.sin(animValue * math.pi * 2) * 0.5 + 0.5,
        )!.withValues(alpha: fireIntensity);
      case TrailType.ice:
        return Color.lerp(
          Colors.cyan,
          Colors.lightBlueAccent,
          intensity,
        )!.withValues(alpha: intensity * 0.7);
      case TrailType.star:
        final twinkle = math.sin(animValue * math.pi * 8) * 0.3 + 0.7;
        return Color.lerp(
          Colors.white,
          const Color(0xFFFFD700),
          math.sin(animValue * math.pi * 4) * 0.5 + 0.5,
        )!.withValues(alpha: intensity * twinkle);
      case TrailType.cosmic:
        return Color.lerp(
          const Color(0xFF4B0082),
          const Color(0xFFDA70D6),
          math.sin(animValue * math.pi * 2) * 0.5 + 0.5,
        )!.withValues(alpha: intensity * 0.8);
      case TrailType.neon:
        final isEven = (intensity * 10).toInt() % 2 == 0;
        return (isEven ? const Color(0xFF39FF14) : const Color(0xFFFF1493))
            .withValues(alpha: intensity * 0.9);
      case TrailType.shadow:
        return Color.lerp(
          const Color(0xFF2F2F2F),
          Colors.black,
          intensity,
        )!.withValues(alpha: intensity * 0.8);
      case TrailType.dragon:
        final phase = (animValue * 4 + intensity * 2) % 4;
        Color dragonColor;
        if (phase < 1) {
          dragonColor = const Color(0xFF8B0000);
        } else if (phase < 2) {
          dragonColor = Colors.red[800]!;
        } else if (phase < 3) {
          dragonColor = Colors.orange;
        } else {
          dragonColor = const Color(0xFFFFD700);
        }
        return dragonColor.withValues(alpha: intensity * 0.85);
      case TrailType.none:
        return Colors.transparent;
    }
  }

  // --- Trail-type resolution (ported from game_board's helpers) ---

  TrailType _resolveTrailType() {
    final premium = game.premiumState;
    if (premium.selectedTrailId != 'none' &&
        premium.isTrailOwned(premium.selectedTrailId)) {
      return _trailTypeFromCosmetic(premium.selectedTrailId);
    }
    if (game.trailSystemEnabled) {
      return _trailTypeForTheme(game.theme);
    }
    return TrailType.none;
  }

  TrailType _trailTypeFromCosmetic(String trailId) {
    final effect = TrailEffectType.values.firstWhere(
      (t) => t.id == trailId,
      orElse: () => TrailEffectType.none,
    );
    switch (effect) {
      case TrailEffectType.none:
        return TrailType.none;
      case TrailEffectType.particle:
        return TrailType.particles;
      case TrailEffectType.glow:
        return TrailType.glow;
      case TrailEffectType.rainbow:
        return TrailType.rainbow;
      case TrailEffectType.fire:
        return TrailType.fire;
      case TrailEffectType.electric:
        return TrailType.lightning;
      case TrailEffectType.star:
        return TrailType.star;
      case TrailEffectType.cosmic:
        return TrailType.cosmic;
      case TrailEffectType.neon:
        return TrailType.neon;
      case TrailEffectType.shadow:
        return TrailType.shadow;
      case TrailEffectType.crystal:
        return TrailType.ice;
      case TrailEffectType.dragon:
        return TrailType.dragon;
    }
  }

  TrailType _trailTypeForTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.classic:
        return TrailType.basic;
      case GameTheme.modern:
        return TrailType.glow;
      case GameTheme.neon:
        return TrailType.glow;
      case GameTheme.retro:
        return TrailType.basic;
      case GameTheme.space:
        return TrailType.particles;
      case GameTheme.ocean:
        return TrailType.glow;
      case GameTheme.cyberpunk:
        return TrailType.lightning;
      case GameTheme.forest:
        return TrailType.particles;
      case GameTheme.desert:
        return TrailType.fire;
      case GameTheme.crystal:
        return TrailType.ice;
    }
  }
}
