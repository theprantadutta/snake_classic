enum Direction {
  up,
  down,
  left,
  right;

  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  /// A quarter turn counter-clockwise as the player sees it (screen y
  /// grows downward): up → left → down → right → up.
  Direction get rotatedLeft {
    switch (this) {
      case Direction.up:
        return Direction.left;
      case Direction.left:
        return Direction.down;
      case Direction.down:
        return Direction.right;
      case Direction.right:
        return Direction.up;
    }
  }

  /// A quarter turn clockwise as the player sees it:
  /// up → right → down → left → up.
  Direction get rotatedRight {
    switch (this) {
      case Direction.up:
        return Direction.right;
      case Direction.right:
        return Direction.down;
      case Direction.down:
        return Direction.left;
      case Direction.left:
        return Direction.up;
    }
  }

  bool get isHorizontal => this == Direction.left || this == Direction.right;
  bool get isVertical => this == Direction.up || this == Direction.down;
}

/// A steering input measured from the snake's heading rather than from
/// the screen. The two-button control layout speaks in these.
///
/// A relative turn is always perpendicular to the heading it is applied
/// to, so it can never be the one input the game must refuse — a
/// reversal into the snake's own neck.
enum RelativeTurn {
  left,
  right;

  /// The absolute direction this turn produces from [heading].
  Direction applyTo(Direction heading) =>
      this == RelativeTurn.left ? heading.rotatedLeft : heading.rotatedRight;
}
