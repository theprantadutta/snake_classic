import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/premium_power_up.dart';
import 'package:snake_classic/utils/constants.dart';

enum GameStatus {
  playing,
  paused,
  crashed, // New state for showing crash feedback
  gameOver,
  menu;
}

enum CrashReason {
  wallCollision,
  selfCollision;
  
  String get message {
    switch (this) {
      case CrashReason.wallCollision:
        return 'You crashed into the wall!';
      case CrashReason.selfCollision:
        return 'You crashed into yourself!';
    }
  }
  
  String get icon {
    switch (this) {
      case CrashReason.wallCollision:
        return '🧱';
      case CrashReason.selfCollision:
        return '🐍';
    }
  }
}

class GameState {
  final Snake snake;
  final Food? food;
  final List<Food> foods;
  final PowerUp? powerUp;
  final List<ActivePowerUp> activePowerUps;
  final int score;
  final int highScore;
  final GameStatus status;
  final CrashReason? crashReason;
  final Position? crashPosition;
  final Position? collisionBodyPart; // For self-collision, shows which body part was hit
  final bool showCrashModal; // Whether to show the crash feedback modal
  final int level;
  final int boardWidth;
  final int boardHeight;
  final DateTime? lastMoveTime;
  final GameMode gameMode;

  const GameState({
    required this.snake,
    this.food,
    this.foods = const [],
    this.powerUp,
    this.activePowerUps = const [],
    this.score = 0,
    this.highScore = 0,
    this.status = GameStatus.menu,
    this.crashReason,
    this.crashPosition,
    this.collisionBodyPart,
    this.showCrashModal = false,
    this.level = 1,
    this.boardWidth = 20,
    this.boardHeight = 20,
    this.lastMoveTime,
    this.gameMode = GameMode.classic,
  });

  factory GameState.initial() {
    return GameState(
      snake: Snake.initial(),
      status: GameStatus.menu,
      crashReason: null,
      crashPosition: null,
      collisionBodyPart: null,
      showCrashModal: false,
      powerUp: null,
      activePowerUps: const [],
    );
  }

  int get gameSpeed {
    // Speed increases with level (lower milliseconds = faster)
    // Start at 300ms, decrease by game mode-specific amount per level
    final baseSpeed = 300;
    final speedDecrease = (level - 1) * gameMode.speedIncreaseRate;
    int speed = (baseSpeed - speedDecrease).clamp(50, 300);
    
    // Apply power-up effects
    final hasSpeedBoost = activePowerUps.any((p) => p.type == PowerUpType.speedBoost && !p.isExpired);
    final hasSlowMotion = activePowerUps.any((p) => p.type == PowerUpType.slowMotion && !p.isExpired);
    
    if (hasSpeedBoost) {
      speed = (speed * 0.5).round(); // 50% faster
    }
    if (hasSlowMotion) {
      speed = (speed * 1.5).round(); // 50% slower
    }
    
    return speed.clamp(50, 600);
  }

  int get targetScore => level * 100;

  bool get shouldLevelUp => score >= targetScore;

  // Additional power-up effect getters (hasInvincibility is defined later in file)
  bool get hasSpeedBoost => activePowerUps.any((p) => 
      (p.type == PowerUpType.speedBoost || _isPremiumSpeedBoost(p)) && !p.isExpired);
      
  bool get hasSlowMotion => activePowerUps.any((p) => 
      (p.type == PowerUpType.slowMotion || _isPremiumSlowMotion(p)) && !p.isExpired);
      
  bool get hasScoreMultiplier => activePowerUps.any((p) => 
      (p.type == PowerUpType.scoreMultiplier || _isPremiumScoreMultiplier(p)) && !p.isExpired);
      
  // Premium-specific power-up effects
  bool get hasGhostMode => activePowerUps.any((p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.ghostMode && !p.isExpired);
      
  bool get hasSizeReducer => activePowerUps.any((p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.sizeReducer && !p.isExpired);
      
  bool get hasScoreShield => activePowerUps.any((p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.scoreShield && !p.isExpired);
      
  bool get hasTimeWarp => activePowerUps.any((p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.timeWarp && !p.isExpired);
      
  bool get hasMagneticFood => activePowerUps.any((p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.magneticFood && !p.isExpired);
      
  bool get hasComboMultiplier => activePowerUps.any((p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.comboMultiplier && !p.isExpired);

  // Helper methods for checking premium variants of basic power-ups
  bool _isPremiumInvincibility(ActivePowerUp p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.megaInvincibility;
      
  bool _isPremiumSpeedBoost(ActivePowerUp p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.megaSpeedBoost;
      
  bool _isPremiumSlowMotion(ActivePowerUp p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.megaSlowMotion;
      
  bool _isPremiumScoreMultiplier(ActivePowerUp p) => 
      p is PremiumActivePowerUp && p.premiumType == PremiumPowerUpType.megaScoreMultiplier;

  GameState copyWith({
    Snake? snake,
    Food? food,
    List<Food>? foods,
    PowerUp? powerUp,
    List<ActivePowerUp>? activePowerUps,
    int? score,
    int? highScore,
    GameStatus? status,
    CrashReason? crashReason,
    Position? crashPosition,
    Position? collisionBodyPart,
    bool? showCrashModal,
    int? level,
    int? boardWidth,
    int? boardHeight,
    DateTime? lastMoveTime,
    GameMode? gameMode,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      foods: foods ?? this.foods,
      powerUp: powerUp ?? this.powerUp,
      activePowerUps: activePowerUps ?? this.activePowerUps,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      status: status ?? this.status,
      crashReason: crashReason ?? this.crashReason,
      crashPosition: crashPosition ?? this.crashPosition,
      collisionBodyPart: collisionBodyPart ?? this.collisionBodyPart,
      showCrashModal: showCrashModal ?? this.showCrashModal,
      level: level ?? this.level,
      boardWidth: boardWidth ?? this.boardWidth,
      boardHeight: boardHeight ?? this.boardHeight,
      lastMoveTime: lastMoveTime ?? this.lastMoveTime,
      gameMode: gameMode ?? this.gameMode,
    );
  }

  GameState clearFood() {
    return copyWith(food: null);
  }
  
  GameState clearPowerUp() {
    return copyWith(powerUp: null);
  }
  
  GameState addActivePowerUp(ActivePowerUp activePowerUp) {
    return copyWith(activePowerUps: [...activePowerUps, activePowerUp]);
  }
  
  GameState removeExpiredPowerUps() {
    final unexpiredPowerUps = activePowerUps.where((p) => !p.isExpired).toList();
    return copyWith(activePowerUps: unexpiredPowerUps);
  }
  
  bool get hasInvincibility {
    return activePowerUps.any((p) => 
      (p.type == PowerUpType.invincibility || _isPremiumInvincibility(p)) && !p.isExpired);
  }
  
  int get scoreMultiplier {
    final hasMultiplier = activePowerUps.any((p) => p.type == PowerUpType.scoreMultiplier && !p.isExpired);
    return hasMultiplier ? 2 : 1;
  }
}