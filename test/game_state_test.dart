import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  group('GameState', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
    });

    test('GameState initializes with correct default values', () {
      expect(gameState.score, 0);
      expect(gameState.highScore, 0);
      expect(gameState.status, GameStatus.notStarted);
      expect(gameState.gameSpeed, GameConstants.initialGameSpeed);
      expect(gameState.currentTheme, GameTheme.retro);
      expect(gameState.controlType, ControlType.swipe);
    });

    test('GameState updates score correctly', () {
      gameState.updateScore(10);
      expect(gameState.score, 10);
      expect(gameState.highScore, 10);
      
      gameState.updateScore(5);
      expect(gameState.score, 15);
      expect(gameState.highScore, 15);
    });

    test('GameState does not decrease high score', () {
      gameState.updateScore(20);
      expect(gameState.highScore, 20);
      
      gameState.updateScore(-5);
      expect(gameState.score, 15);
      expect(gameState.highScore, 20); // Should remain at 20
    });

    test('GameState increases difficulty correctly', () {
      final initialSpeed = gameState.gameSpeed;
      gameState.increaseDifficulty();
      expect(gameState.gameSpeed, lessThan(initialSpeed));
    });

    test('GameState resets correctly', () {
      gameState.updateScore(100);
      gameState.status = GameStatus.playing;
      gameState.increaseDifficulty();
      gameState.increaseDifficulty();
      
      final speedBeforeReset = gameState.gameSpeed;
      gameState.reset();
      
      expect(gameState.score, 0);
      expect(gameState.status, GameStatus.notStarted);
      expect(gameState.gameSpeed, GameConstants.initialGameSpeed);
    });

    test('GameState loads high score correctly', () {
      gameState.loadHighScore(500);
      expect(gameState.highScore, 500);
    });
  });
}