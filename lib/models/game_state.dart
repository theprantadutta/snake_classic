import '../utils/constants.dart';

class GameState {
  int score = 0;
  int highScore = 0;
  GameStatus status = GameStatus.notStarted;
  int gameSpeed = GameConstants.initialGameSpeed;
  GameTheme currentTheme = GameTheme.retro;
  ControlType controlType = ControlType.swipe;
  Difficulty difficulty = Difficulty.medium;

  void updateScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
    }
  }

  void increaseDifficulty() {
    // Increase speed (decrease milliseconds) as score increases
    // But don't go below 50ms
    final int minSpeed = (GameConstants.initialGameSpeed * difficulty.speedMultiplier * 0.25).toInt();
    final int speedDecrease = (GameConstants.speedIncreasePerFood * difficulty.speedMultiplier).toInt();
    
    if (gameSpeed > minSpeed) {
      gameSpeed -= speedDecrease;
    }
  }

  void reset() {
    score = 0;
    status = GameStatus.notStarted;
    gameSpeed = (GameConstants.initialGameSpeed * difficulty.speedMultiplier).toInt();
  }

  void loadHighScore(int savedHighScore) {
    highScore = savedHighScore;
  }

  void saveHighScore() {
    // This will be implemented with shared_preferences later
  }
}