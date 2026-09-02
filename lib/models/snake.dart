import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

class Snake {
  List<Position> body;
  Direction currentDirection;

  // Track the direction that was committed at the last move
  // This prevents false self-collision from rapid direction changes
  Direction _lastCommittedDirection;

  // Flag to track if a direction change has been queued this tick
  bool _hasQueuedDirection = false;

  // Second-depth input buffer: a turn queued BEHIND the pending one.
  // Lets a fast corner (e.g. down-then-right within one tick period)
  // land both turns on consecutive ticks instead of rejecting the
  // second input outright — at 150-300ms tick periods that rejection
  // was the single biggest input-feel complaint.
  Direction? _pendingDirection;

  Snake({required this.body, this.currentDirection = Direction.right})
    : _lastCommittedDirection = Direction.right;

  Position get head => body.first;
  Position get tail => body.last;
  int get length => body.length;

  /// Segments a run starts with.
  ///
  /// Named because gameSpeed measures growth against it. It was implicit in
  /// the three positions below, which is fine until something else needs to
  /// know the number.
  static const int initialLength = 3;

  factory Snake.initial() {
    return Snake(
      body: [
        const Position(4, 10),
        const Position(3, 10),
        const Position(2, 10),
      ],
      currentDirection: Direction.right,
    );
  }

  /// Creates a Snake from a list of positions and direction
  /// Used for converting multiplayer player data to single-player Snake model
  factory Snake.fromPositions(List<Position> positions, Direction direction) {
    if (positions.isEmpty) {
      return Snake.initial();
    }
    final snake = Snake(
      body: List<Position>.from(positions),
      currentDirection: direction,
    );
    snake._lastCommittedDirection = direction;
    return snake;
  }

  void move({
    required bool ateFood,
    int? boardWidth,
    int? boardHeight,
    bool wrapAround = false,
  }) {
    // Commit the direction we are about to travel in.
    _lastCommittedDirection = currentDirection;

    // Move FIRST, promote after. The promotion used to sit here, above this
    // line, which meant a second buffered turn overwrote the first before the
    // first had moved — so of two accepted turns only the second ever
    // happened. Its own comment said "so it applies on the NEXT tick"; it was
    // applying to this one.
    //
    // The player-visible half is that a swipe goes missing when you corner
    // faster than one tick. The dangerous half is that right-then-up-then-
    // left sent the head straight back down its own neck: two individually
    // legal turns, both accepted, instant self-collision.
    Position newHead = head.move(currentDirection);

    // Handle wrap-around for Zen mode
    if (wrapAround && boardWidth != null && boardHeight != null) {
      int x = newHead.x;
      int y = newHead.y;

      // Wrap horizontally
      if (x < 0) {
        x = boardWidth - 1;
      } else if (x >= boardWidth) {
        x = 0;
      }

      // Wrap vertically
      if (y < 0) {
        y = boardHeight - 1;
      } else if (y >= boardHeight) {
        y = 0;
      }

      newHead = Position(x, y);
    }

    body.insert(0, newHead);

    if (!ateFood) {
      body.removeLast();
    }

    // Now promote the second-buffered turn, so it applies on the next tick
    // and this tick's input slots reopen correctly: with a promoted turn
    // occupying slot one, fresh input goes to slot two.
    if (_pendingDirection != null) {
      currentDirection = _pendingDirection!;
      _pendingDirection = null;
      _hasQueuedDirection = true;
    } else {
      _hasQueuedDirection = false;
    }
  }

  /// The direction the snake will be travelling once every buffered turn
  /// has applied — the heading a relative "turn left / turn right" input
  /// must be measured against, so that two quick relative presses compose
  /// into a U-shaped corner instead of both resolving off the same heading.
  Direction get plannedDirection => _pendingDirection ?? currentDirection;

  /// How many turns are buffered ahead of the next move, 0 to 2. At 2 the
  /// buffer is full and a further input can only replace the second turn —
  /// or be refused if what it asks for would reverse the first.
  int get bufferedTurns =>
      (_hasQueuedDirection ? 1 : 0) + (_pendingDirection != null ? 1 : 0);

  /// Queues a direction change. Two turns can be buffered per tick: the
  /// first applies on the next move, the second on the move after that.
  /// Returns `true` when the input is accepted, `false` when rejected
  /// because the requested move would reverse the snake into itself.
  /// Callers use the return value to surface "denied" feedback (haptic +
  /// red flash on the gesture indicator).
  ///
  /// The buffer is LATEST WINS. It used to refuse a third input while both
  /// slots were full, which was correct in a narrow sense and wrong for the
  /// player: at the fast end of a run ticks are 50-100ms, a quick tapper
  /// fills both slots constantly, and the third press — the one that
  /// expresses where they actually want to go — got a red flash and a
  /// double buzz. Now the newest press replaces the pending second turn,
  /// and re-pressing the direction already queued first cancels the
  /// pending turn behind it. The only refusal left is the reversal.
  bool changeDirection(Direction newDirection) {
    if (!_hasQueuedDirection) {
      // First slot. Validate against the LAST COMMITTED direction (not
      // the pending currentDirection) so we can't reverse through a
      // sequence of perpendicular moves.
      if (newDirection == _lastCommittedDirection.opposite) {
        return false;
      }
      currentDirection = newDirection;
      _hasQueuedDirection = true;
      return true;
    }

    // Second slot: this turn executes AFTER currentDirection commits,
    // so validate against currentDirection.
    if (newDirection == currentDirection.opposite) {
      return false;
    }
    if (newDirection == currentDirection) {
      // The player's newest intent is the turn already queued first, so
      // whatever was buffered behind it is no longer wanted.
      _pendingDirection = null;
      return true;
    }
    _pendingDirection = newDirection;
    return true;
  }

  bool checkSelfCollision() {
    return body.skip(1).contains(head);
  }

  Position? getSelfCollisionBodyPart() {
    // Return the specific body part that the head collided with
    for (int i = 1; i < body.length; i++) {
      if (body[i] == head) {
        return body[i];
      }
    }
    return null;
  }

  bool checkWallCollision(int boardWidth, int boardHeight) {
    return !head.isWithinBounds(boardWidth, boardHeight);
  }

  bool occupiesPosition(Position position) {
    return body.contains(position);
  }

  Snake copy() {
    final copied = Snake(
      body: List<Position>.from(body),
      currentDirection: currentDirection,
    );
    // Preserve direction tracking state
    copied._lastCommittedDirection = _lastCommittedDirection;
    copied._hasQueuedDirection = _hasQueuedDirection;
    copied._pendingDirection = _pendingDirection;
    return copied;
  }
}
