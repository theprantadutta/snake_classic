import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// A snake playing itself behind the home screen.
///
/// The arcade layout this belongs to takes its cue from the endless runners:
/// the middle of the screen is the game, not a panel about the game, and the
/// whole thing is the play button. Those games can put a rendered character
/// there. We have something better and cheaper — the game itself. This runs a
/// slow demo game on a loop: a snake finds food, eats it, grows, and starts
/// over when it runs out of room.
///
/// Deliberately quiet. Everything is drawn at low alpha in the active theme's
/// colours, because a title and a call to action sit on top of it and have to
/// stay readable. It is wallpaper that happens to be alive.
///
/// Cheap by construction: one timer at [tickInterval], no widget rebuilds
/// (the painter repaints off a [ValueNotifier]), integer grid maths only, and
/// it stops itself when the app is not in the foreground.
class AttractBoard extends StatefulWidget {
  const AttractBoard({
    super.key,
    required this.theme,
    this.cellSize = 28,
    this.tickInterval = const Duration(milliseconds: 200),
  });

  final GameTheme theme;

  /// Target size of one grid cell. The grid fits as many as the box allows.
  final double cellSize;

  final Duration tickInterval;

  @override
  State<AttractBoard> createState() => _AttractBoardState();
}

class _AttractBoardState extends State<AttractBoard>
    with WidgetsBindingObserver {
  final _frame = ValueNotifier<int>(0);
  Timer? _timer;
  _DemoGame? _game;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No point animating wallpaper nobody is looking at.
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.tickInterval, (_) {
      _game?.step();
      _frame.value++;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _lastSize || _game == null) {
          _lastSize = size;
          final columns = max(6, (size.width / widget.cellSize).floor());
          final rows = max(6, (size.height / widget.cellSize).floor());
          _game = _DemoGame(columns: columns, rows: rows);
        }

        return IgnorePointer(
          child: CustomPaint(
            painter: _AttractPainter(
              repaint: _frame,
              game: _game!,
              theme: widget.theme,
            ),
            size: size,
          ),
        );
      },
    );
  }
}

/// The demo itself: a grid, a snake, one piece of food, and a greedy walker.
///
/// Not the real engine. The real engine carries scoring, power-ups, combos,
/// modes and a settlement pipeline, none of which mean anything to wallpaper —
/// and running it here would put a second game loop in the app for decoration.
/// This is forty lines of pathfinding that looks exactly like Snake.
class _DemoGame {
  _DemoGame({required this.columns, required this.rows}) {
    _reset();
  }

  final int columns;
  final int rows;
  final _random = Random(7); // Fixed seed: the attract loop is not a lottery.

  late List<Point<int>> snake;
  late Point<int> food;
  Point<int> _heading = const Point(1, 0);

  void _reset() {
    final midY = rows ~/ 2;
    final startX = columns ~/ 3;
    snake = [
      Point(startX, midY),
      Point(startX - 1, midY),
      Point(startX - 2, midY),
    ];
    _heading = const Point(1, 0);
    _placeFood();
  }

  void _placeFood() {
    // Bounded attempts, then give up and take the first free cell — a full
    // board is possible in principle and must not spin here.
    for (var i = 0; i < 60; i++) {
      final candidate = Point(_random.nextInt(columns), _random.nextInt(rows));
      if (!snake.contains(candidate)) {
        food = candidate;
        return;
      }
    }
    for (var x = 0; x < columns; x++) {
      for (var y = 0; y < rows; y++) {
        final candidate = Point(x, y);
        if (!snake.contains(candidate)) {
          food = candidate;
          return;
        }
      }
    }
    _reset();
  }

  void step() {
    final head = snake.first;
    final next = _chooseMove(head);
    if (next == null) {
      // Boxed in. Start again rather than freezing mid-loop.
      _reset();
      return;
    }

    _heading = Point(next.x - head.x, next.y - head.y);
    snake.insert(0, next);
    if (next == food) {
      _placeFood();
      // Cap the length so the demo never fills the screen with snake.
      if (snake.length > 18) snake.removeLast();
    } else {
      snake.removeLast();
    }
  }

  /// Greedy with a fallback: close the larger axis gap first, and if that is
  /// blocked try every other direction before declaring the run over.
  Point<int>? _chooseMove(Point<int> head) {
    final dx = food.x - head.x;
    final dy = food.y - head.y;

    // Momentum first: a snake that changes axis every tick reads as a
    // staircase of loose blocks. Carrying on straight while that still closes
    // the gap gives it long runs and corners, which is what Snake looks like.
    final straight = Point(head.x + _heading.x, head.y + _heading.y);
    final keepsClosing =
        (_heading.x != 0 && _heading.x.sign == dx.sign) ||
        (_heading.y != 0 && _heading.y.sign == dy.sign);

    final preferred = <Point<int>>[
      if (keepsClosing) straight,
      if (dx.abs() >= dy.abs()) ...[
        Point(head.x + dx.sign, head.y),
        Point(head.x, head.y + dy.sign),
      ] else ...[
        Point(head.x, head.y + dy.sign),
        Point(head.x + dx.sign, head.y),
      ],
      Point(head.x + 1, head.y),
      Point(head.x - 1, head.y),
      Point(head.x, head.y + 1),
      Point(head.x, head.y - 1),
    ];

    for (final candidate in preferred) {
      if (candidate == head) continue;
      if (_isSafe(candidate)) return candidate;
    }
    return null;
  }

  bool _isSafe(Point<int> cell) {
    if (cell.x < 0 || cell.y < 0 || cell.x >= columns || cell.y >= rows) {
      return false;
    }
    // The tail moves out of the way this tick, so it is not an obstacle.
    for (var i = 0; i < snake.length - 1; i++) {
      if (snake[i] == cell) return false;
    }
    return true;
  }
}

class _AttractPainter extends CustomPainter {
  _AttractPainter({
    required Listenable repaint,
    required this.game,
    required this.theme,
  }) : super(repaint: repaint);

  final _DemoGame game;
  final GameTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / game.columns;
    final cellH = size.height / game.rows;
    final cell = min(cellW, cellH);
    // Centre the grid in whatever box we were given.
    final originX = (size.width - cell * game.columns) / 2;
    final originY = (size.height - cell * game.rows) / 2;

    Offset centreOf(Point<int> p) =>
        Offset(originX + (p.x + 0.5) * cell, originY + (p.y + 0.5) * cell);

    // Grid dots — just enough texture to read as a board.
    final dot = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    for (var x = 0; x < game.columns; x++) {
      for (var y = 0; y < game.rows; y++) {
        canvas.drawCircle(centreOf(Point(x, y)), cell * 0.055, dot);
      }
    }

    // Food, with a soft halo so the eye finds it the way it does in game.
    final foodCentre = centreOf(game.food);
    canvas.drawCircle(
      foodCentre,
      cell * 0.42,
      Paint()..color = theme.foodColor.withValues(alpha: 0.10),
    );
    canvas.drawCircle(
      foodCentre,
      cell * 0.22,
      Paint()..color = theme.foodColor.withValues(alpha: 0.30),
    );

    // The snake, fading toward the tail so it reads as motion in a still
    // frame — the head is where the eye should land.
    for (var i = 0; i < game.snake.length; i++) {
      final t = i / game.snake.length;
      final alpha = (0.26 - t * 0.18).clamp(0.06, 0.26);
      // Barely inset, so consecutive cells touch and the body reads as one
      // continuous snake rather than a row of tiles.
      final inset = cell * (0.05 + t * 0.03);
      final centre = centreOf(game.snake[i]);
      final rect = Rect.fromCenter(
        center: centre,
        width: cell - inset * 2,
        height: cell - inset * 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.22)),
        Paint()..color = theme.snakeColor.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AttractPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.game != game;
}
