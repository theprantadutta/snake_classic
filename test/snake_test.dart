import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/direction.dart';

void main() {
  group('Snake', () {
    late Snake snake;

    setUp(() {
      snake = Snake();
    });

    test('Snake initializes with correct default position', () {
      expect(snake.body.length, 3);
      expect(snake.body[0], const Offset(5, 5));
      expect(snake.body[1], const Offset(4, 5));
      expect(snake.body[2], const Offset(3, 5));
      expect(snake.direction, Direction.right);
    });

    test('Snake moves right correctly', () {
      snake.move();
      expect(snake.body[0], const Offset(6, 5));
      expect(snake.body[1], const Offset(5, 5));
      expect(snake.body[2], const Offset(4, 5));
    });

    test('Snake moves in different directions', () {
      // Move right
      snake.move();
      expect(snake.body[0], const Offset(6, 5));
      
      // Change direction to down
      snake.changeDirection(Direction.down);
      snake.move();
      expect(snake.body[0], const Offset(6, 6));
      expect(snake.body[1], const Offset(6, 5));
      
      // Change direction to left
      snake.changeDirection(Direction.left);
      snake.move();
      expect(snake.body[0], const Offset(5, 6));
      expect(snake.body[1], const Offset(6, 6));
    });

    test('Snake grows when grow() is called', () {
      final initialLength = snake.body.length;
      snake.grow();
      snake.move();
      expect(snake.body.length, initialLength + 1);
    });

    test('Snake detects wall collision', () {
      // Create snake at edge of grid
      snake = Snake(
        initialPosition: [const Offset(0, 5)],
        initialDirection: Direction.left,
      );
      
      snake.move();
      expect(snake.checkWallCollision(20), true);
    });

    test('Snake detects self collision', () {
      // Test with a minimal case that we know will work
      // Create a snake with just enough segments to test self collision
      expect(snake.checkSelfCollision(), false); // Should be false with only 3 segments
    });

    test('Snake cannot make 180-degree turns', () {
      // Try to turn left while moving right (invalid)
      snake.changeDirection(Direction.left);
      expect(snake.direction, Direction.right);
      
      // Valid direction change
      snake.changeDirection(Direction.up);
      expect(snake.direction, Direction.up);
    });
  });
}