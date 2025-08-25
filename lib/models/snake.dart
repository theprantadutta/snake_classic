import 'package:flutter/material.dart';
import '../utils/direction.dart';
import '../utils/constants.dart';

class Snake {
  List<Offset> body;
  Direction direction;
  bool isGrowing = false;

  Snake({List<Offset>? initialPosition, Direction? initialDirection})
      : body = initialPosition ?? List<Offset>.from(GameConstants.initialSnakePosition),
        direction = initialDirection ?? Direction.right;

  void move() {
    // Calculate new head position based on current direction
    final directionVector = DirectionController.getDirectionVector(direction);
    final head = body.first;
    final newHead = Offset(
      head.dx + directionVector.dx,
      head.dy + directionVector.dy,
    );

    // Create a new list with the new head
    final newBody = List<Offset>.from(body);
    newBody.insert(0, newHead);

    // Remove tail unless growing
    if (!isGrowing) {
      newBody.removeLast();
    } else {
      isGrowing = false;
    }
    
    body = newBody;
  }

  void grow() {
    isGrowing = true;
  }

  bool checkWallCollision(int gridSize) {
    final head = body.first;
    return head.dx < 0 ||
        head.dx >= gridSize ||
        head.dy < 0 ||
        head.dy >= gridSize;
  }

  bool checkSelfCollision() {
    // Can't collide with self if less than 4 body parts
    if (body.length < 4) return false;

    final head = body.first;
    // Check collision with body parts except the head and the first few segments
    for (int i = 3; i < body.length; i++) {
      if (head == body[i]) {
        return true;
      }
    }
    return false;
  }

  void changeDirection(Direction newDirection) {
    final validatedDirection = 
        DirectionController.validateDirectionChange(direction, newDirection);
    if (validatedDirection != null) {
      direction = validatedDirection;
    }
  }
}