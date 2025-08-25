import 'dart:math';
import 'package:flutter/material.dart';

class Food {
  Offset position;

  Food({required this.position});

  void generateNewPosition(List<Offset> snakeBody, int gridSize) {
    Random random = Random();
    Offset newPosition;

    // Keep generating positions until we find one not on the snake
    do {
      newPosition = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    } while (snakeBody.contains(newPosition));

    position = newPosition;
  }

  bool isConsumed(Offset snakeHead) {
    return position == snakeHead;
  }
}