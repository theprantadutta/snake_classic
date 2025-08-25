import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class DirectionController {
  static Direction? validateDirectionChange(Direction current, Direction next) {
    // Prevent 180-degree turns which would cause immediate self-collision
    if ((current == Direction.up && next == Direction.down) ||
        (current == Direction.down && next == Direction.up) ||
        (current == Direction.left && next == Direction.right) ||
        (current == Direction.right && next == Direction.left)) {
      return null; // Invalid direction change
    }
    return next;
  }

  static Offset getDirectionVector(Direction direction) {
    switch (direction) {
      case Direction.up:
        return const Offset(0, -1);
      case Direction.down:
        return const Offset(0, 1);
      case Direction.left:
        return const Offset(-1, 0);
      case Direction.right:
        return const Offset(1, 0);
    }
  }
}