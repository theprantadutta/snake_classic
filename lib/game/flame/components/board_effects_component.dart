import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/game/effects/effect_curves.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/utils/constants.dart';

/// Short, draw-only motion effects on the board (docs/MOTION_SPEC.md "In
/// game"): the gold eat pop (a springPop ring plus a few LED spark cells),
/// the power-up pickup ring pulse, and the red flash ring at the crash cell.
///
/// Cheap by construction: a fixed pool of effect slots allocated once,
/// three reused [Paint]s, no blur, no saveLayer, and an early return when
/// nothing is running, so an idle board pays one comparison per frame.
/// Effects are timed from [SnakeFlameGame.fxClock], which stops with the
/// engine while paused. Events arrive from the game's tick-event handling
/// (never from state diffs); the crash ring reads the game's crash clock.
class BoardEffectsComponent extends Component
    with HasGameReference<SnakeFlameGame> {
  BoardEffectsComponent() : super(priority: 3);

  static const int _slots = 6;
  static const int _sparkCount = 6;

  static final double _popSeconds = _s(LBMotion.gentle);
  static final double _pickupSeconds = _s(LBMotion.slow);
  static final double _crashSeconds = _s(LBMotion.base);

  static double _s(Duration d) =>
      d.inMicroseconds / Duration.microsecondsPerSecond;

  final List<_Fx> _fx = List.generate(_slots, (_) => _Fx());
  int _next = 0;

  /// fxClock time at which the last running effect ends.
  double _busyUntil = -1;

  final Paint _ring = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _fill = Paint()..isAntiAlias = true;
  final Paint _cellFill = Paint()..isAntiAlias = false;

  static const double _cell = GameConstants.cellSize;

  /// Gold pop ring + spark cells at a just-eaten food cell (world pixels).
  void eatPop(Offset at, double now) =>
      _start(_FxKind.eat, at, LB.gold, now, _popSeconds);

  /// Ring pulse at a power-up pickup cell, in the power-up's colour.
  void pickupRing(Offset at, Color color, double now) =>
      _start(_FxKind.pickup, at, color, now, _pickupSeconds);

  void _start(_FxKind kind, Offset at, Color color, double now, double dur) {
    final fx = _fx[_next];
    _next = (_next + 1) % _slots;
    fx
      ..kind = kind
      ..x = at.dx
      ..y = at.dy
      ..color = color
      ..start = now
      ..duration = dur
      // Rotate each burst's spark pattern by the cell, so neighbouring
      // bites don't look stamped.
      ..spin = ((at.dx * 7 + at.dy * 13) % 60) / 60 * math.pi / 3;
    _busyUntil = math.max(_busyUntil, now + dur);
  }

  @override
  void render(Canvas canvas) {
    if (game.reducedMotion) return;
    final now = game.fxClock;
    if (now < _busyUntil) {
      for (final fx in _fx) {
        final t = (now - fx.start) / fx.duration;
        if (t < 0 || t >= 1) continue;
        switch (fx.kind) {
          case _FxKind.eat:
            _drawEat(canvas, fx, t);
          case _FxKind.pickup:
            _drawPickup(canvas, fx, t);
        }
      }
    }
    _drawCrashFlash(canvas);
  }

  void _drawEat(Canvas canvas, _Fx fx, double t) {
    final alpha = EffectCurves.fadeOut(t);
    final c = Offset(fx.x, fx.y);
    _ring
      ..strokeWidth = _cell * (.16 - .1 * t)
      ..color = fx.color.withValues(alpha: .85 * alpha);
    canvas.drawCircle(c, _cell * EffectCurves.popRingRadius(t), _ring);

    // LED spark cells: small squares flying out and shrinking.
    final d = _cell * EffectCurves.sparkDistance(t);
    final half = _cell * .11 * (1 - .5 * t);
    _cellFill.color = LB.goldHead.withValues(alpha: alpha);
    for (var i = 0; i < _sparkCount; i++) {
      final a = fx.spin + i * (math.pi * 2 / _sparkCount);
      final px = fx.x + math.cos(a) * d;
      final py = fx.y + math.sin(a) * d;
      canvas.drawRect(
          Rect.fromLTRB(px - half, py - half, px + half, py + half), _cellFill);
    }
  }

  void _drawPickup(Canvas canvas, _Fx fx, double t) {
    final c = Offset(fx.x, fx.y);
    // Two rings, the second trailing by a third of the effect.
    for (var k = 0; k < 2; k++) {
      final local = (t - k * .3) / .7;
      if (local <= 0 || local >= 1) continue;
      final r = _cell * (.5 + 1.3 * LBMotion.easeOutSoft.transform(local));
      _ring
        ..strokeWidth = _cell * (.14 - .09 * local)
        ..color = fx.color.withValues(alpha: .8 * EffectCurves.fadeOut(local));
      canvas.drawCircle(c, r, _ring);
    }
  }

  /// A quick red flash ring at the crash cell during the first
  /// [LBMotion.base] of the crash: a filled flash for the first beat, then a
  /// ring that bursts out and fades. Rides the death sequence's clock.
  void _drawCrashFlash(Canvas canvas) {
    final elapsed = game.crashElapsedOrNull;
    if (elapsed == null || elapsed >= _crashSeconds) return;
    final gs = game.gameState;
    final pos = gs?.crashPosition;
    if (gs == null || pos == null || gs.status != model.GameStatus.crashed) {
      return;
    }
    final t = elapsed / _crashSeconds;
    final c = Offset(pos.x * _cell + _cell / 2, pos.y * _cell + _cell / 2);
    final flash = 1 - t * 2.5;
    if (flash > 0) {
      _fill.color = LB.bonk.withValues(alpha: .55 * flash);
      canvas.drawCircle(c, _cell * .75, _fill);
    }
    _ring
      ..strokeWidth = _cell * (.22 - .16 * t)
      ..color = LB.bonk.withValues(alpha: .9 * EffectCurves.fadeOut(t));
    canvas.drawCircle(
        c, _cell * (.6 + 1.6 * LBMotion.easeOutSoft.transform(t)), _ring);
  }
}

enum _FxKind { eat, pickup }

class _Fx {
  _FxKind kind = _FxKind.eat;
  double x = 0;
  double y = 0;
  Color color = LB.gold;
  double start = -1e9;
  double duration = 1;
  double spin = 0;
}
