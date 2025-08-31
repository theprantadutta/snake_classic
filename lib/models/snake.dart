import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

class Snake {
  List<Position> body;
  Direction currentDirection;

  Snake({
    required this.body,
    this.currentDirection = Direction.right,
  });

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

  void move({required bool ateFood}) {
    final newHead = head.move(currentDirection);
    body.insert(0, newHead);

    if (!ateFood) {
      body.removeLast();
    }
  }

  void changeDirection(Direction newDirection) {
    if (newDirection != currentDirection.opposite) {
      currentDirection = newDirection;
    }
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
    return Snake(
      body: List<Position>.from(body),
      currentDirection: currentDirection,
    );
  }
}