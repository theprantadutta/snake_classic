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
    // Commit the current direction for the next tick's validation
    _lastCommittedDirection = currentDirection;

    // Promote the second-buffered turn (if any) so it applies on the
    // NEXT tick; otherwise open the queue for fresh input.
    if (_pendingDirection != null) {
      currentDirection = _pendingDirection!;
      _pendingDirection = null;
      _hasQueuedDirection = true;
    } else {
      _hasQueuedDirection = false;
    }

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
  }

  /// Queues a direction change. Two turns can be buffered per tick: the
  /// first applies on the next move, the second on the move after that.
  /// Returns `true` when the input is accepted, `false` when rejected —
  /// either because both buffer slots are full or because the requested
  /// move would reverse the snake into itself. Callers use the return
  /// value to surface "denied" feedback (haptic + red flash on the
  /// gesture indicator).
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
    if (_pendingDirection != null) {
      return false; // both slots full
    }
    if (newDirection == currentDirection.opposite) {
      return false;
    }
    if (newDirection == currentDirection) {
      // Harmless no-op — the snake is already turning that way. Accept
      // without wasting the slot so a real turn can still be buffered.
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
