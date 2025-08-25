import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/food.dart';

void main() {
  group('Food', () {
    late Food food;

    setUp(() {
      food = Food(position: const Offset(10, 10));
    });

    test('Food initializes with correct position', () {
      expect(food.position, const Offset(10, 10));
    });

    test('Food detects consumption correctly', () {
      expect(food.isConsumed(const Offset(10, 10)), true);
      expect(food.isConsumed(const Offset(5, 5)), false);
    });

    test('Food generates new position not on snake body', () {
      final snakeBody = [
        const Offset(5, 5),
        const Offset(6, 5),
        const Offset(7, 5),
      ];
      
      food.generateNewPosition(snakeBody, 20);
      
      // Check that new position is not on snake body
      expect(snakeBody.contains(food.position), false);
      
      // Check that new position is within grid bounds
      expect(food.position.dx >= 0, true);
      expect(food.position.dx < 20, true);
      expect(food.position.dy >= 0, true);
      expect(food.position.dy < 20, true);
    });

    test('Food generates different positions', () {
      final snakeBody = [const Offset(5, 5)];
      final positions = <Offset>[];
      
      // Generate several positions
      for (int i = 0; i < 10; i++) {
        food.generateNewPosition(snakeBody, 20);
        positions.add(food.position);
      }
      
      // Check that we have some variety (not guaranteed but likely)
      final uniquePositions = positions.toSet();
      expect(uniquePositions.length > 1, true);
    });
  });
}