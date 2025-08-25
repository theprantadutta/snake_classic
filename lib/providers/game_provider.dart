import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/snake.dart';
import '../models/food.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../utils/direction.dart';
import '../utils/sound_manager.dart';

class GameProvider with ChangeNotifier {
  late Snake _snake;
  late Food _food;
  late GameState _gameState;
  final int _gridSize = GameConstants.gridSize;
  VoidCallback? onGameOver;
  final SoundManager _soundManager = SoundManager();

  GameProvider() {
    _initializeGame();
    _loadHighScore();
  }

  // Getters
  Snake get snake => _snake;
  Food get food => _food;
  GameState get gameState => _gameState;
  int get gridSize => _gridSize;

  void _initializeGame() {
    _snake = Snake();
    _food = Food(position: const Offset(10, 10));
    _gameState = GameState();

    // Generate initial food position
    _food.generateNewPosition(_snake.body, _gridSize);
  }

  void startGame() {
    _gameState.status = GameStatus.playing;
    _gameState.reset();
    _snake = Snake();
    _food.generateNewPosition(_snake.body, _gridSize);
    _soundManager.playBackgroundMusic();
    notifyListeners();
  }

  void pauseGame() {
    _gameState.status = GameStatus.paused;
    notifyListeners();
  }

  void resumeGame() {
    _gameState.status = GameStatus.playing;
    notifyListeners();
  }

  void gameOver() {
    _gameState.status = GameStatus.gameOver;
    _soundManager.playCrashSound();
    if (_gameState.score > _gameState.highScore) {
      _gameState.highScore = _gameState.score;
      _saveHighScore();
    }
    notifyListeners();

    // Call the game over callback if set
    if (onGameOver != null) {
      onGameOver!();
    }
  }

  void updateDirection(Direction direction) {
    if (_gameState.status == GameStatus.playing) {
      _snake.changeDirection(direction);
    }
  }

  void updateGame() {
    if (_gameState.status != GameStatus.playing) return;

    // Move snake
    _snake.move();

    // Check for wall collision
    if (_snake.checkWallCollision(_gridSize)) {
      gameOver();
      return;
    }

    // Check for self collision
    if (_snake.checkSelfCollision()) {
      gameOver();
      return;
    }

    // Check if food is consumed
    if (_food.isConsumed(_snake.body.first)) {
      // Grow snake
      _snake.grow();

      // Update score
      _gameState.updateScore(GameConstants.pointsPerFood);

      // Increase difficulty
      _gameState.increaseDifficulty();

      // Generate new food
      _food.generateNewPosition(_snake.body, _gridSize);

      // Play chomp sound
      _soundManager.playChompSound();
    }

    notifyListeners();
  }

  void restartGame() {
    _initializeGame();
    startGame();
  }

  // High score persistence
  Future<void> _loadHighScore() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int savedHighScore = prefs.getInt('highScore') ?? 0;
      _gameState.loadHighScore(savedHighScore);
      notifyListeners();
    } catch (e) {
      // Handle error
      debugPrint('Error loading high score: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _gameState.highScore);
    } catch (e) {
      // Handle error
      debugPrint('Error saving high score: $e');
    }
  }

  // Theme management
  void changeTheme(GameTheme theme) {
    _gameState.currentTheme = theme;
    notifyListeners();
  }

  // Control type management
  void changeControlType(ControlType controlType) {
    _gameState.controlType = controlType;
    notifyListeners();
  }

  // Difficulty management
  void changeDifficulty(Difficulty difficulty) {
    _gameState.difficulty = difficulty;
    // Reset game speed based on new difficulty
    _gameState.gameSpeed =
        (GameConstants.initialGameSpeed * difficulty.speedMultiplier).toInt();
    notifyListeners();
  }

  // Sound management
  void toggleSound() {
    _soundManager.toggleSound();
  }

  bool get soundEnabled => _soundManager.soundEnabled;

  // Set game over callback
  void setOnGameOver(VoidCallback callback) {
    onGameOver = callback;
  }
}
