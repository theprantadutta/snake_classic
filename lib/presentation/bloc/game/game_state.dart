import 'package:equatable/equatable.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/tournament.dart';

/// Game play status
enum GamePlayStatus { initial, ready, playing, paused, crashed, gameOver }

/// State class for GameCubit
/// This is a simplified view of the game state for UI consumption
class GameCubitState extends Equatable {
  final GamePlayStatus status;
  final model.GameState? gameState;
  final String? tournamentId;
  final TournamentGameMode? tournamentMode;
  final double moveProgress;
  final model.GameState? previousGameState;

  const GameCubitState({
    this.status = GamePlayStatus.initial,
    this.gameState,
    this.tournamentId,
    this.tournamentMode,
    this.moveProgress = 0.0,
    this.previousGameState,
  });

  /// Initial state
  factory GameCubitState.initial() => const GameCubitState();

  /// Create a copy with updated values
  GameCubitState copyWith({
    GamePlayStatus? status,
    model.GameState? gameState,
    String? tournamentId,
    TournamentGameMode? tournamentMode,
    double? moveProgress,
    model.GameState? previousGameState,
    bool clearTournament = false,
    bool clearPreviousGameState = false,
  }) {
    return GameCubitState(
      status: status ?? this.status,
      gameState: gameState ?? this.gameState,
      tournamentId: clearTournament
          ? null
          : (tournamentId ?? this.tournamentId),
      tournamentMode: clearTournament
          ? null
          : (tournamentMode ?? this.tournamentMode),
      moveProgress: moveProgress ?? this.moveProgress,
      previousGameState: clearPreviousGameState
          ? null
          : (previousGameState ?? this.previousGameState),
    );
  }

  /// Whether game is playing
  bool get isPlaying => status == GamePlayStatus.playing;

  /// Whether game is paused
  bool get isPaused => status == GamePlayStatus.paused;

  /// Whether game is over
  bool get isGameOver => status == GamePlayStatus.gameOver;

  /// Whether game is in crash feedback state
  bool get isCrashed => status == GamePlayStatus.crashed;

  /// Whether in tournament mode
  bool get isTournamentMode => tournamentId != null;

  /// Current score
  int get score => gameState?.score ?? 0;

  /// Current level
  int get level => gameState?.level ?? 1;

  /// Snake body positions
  List<Position> get snakeBody => gameState?.snake.body ?? [];

  /// Snake head position
  Position? get snakeHead => gameState?.snake.head;

  /// Current food
  Food? get food => gameState?.food;

  /// Current power-up on field
  PowerUp? get powerUp => gameState?.powerUp;

  /// Active power-ups
  List<ActivePowerUp> get activePowerUps => gameState?.activePowerUps ?? [];

  /// Current combo
  int get currentCombo => gameState?.currentCombo ?? 0;

  /// Combo multiplier
  double get comboMultiplier => gameState?.comboMultiplier ?? 1.0;

  /// Board width
  int get boardWidth => gameState?.boardWidth ?? 20;

  /// Board height
  int get boardHeight => gameState?.boardHeight ?? 20;

  /// High score
  int get highScore => gameState?.highScore ?? 0;

  /// Crash reason (if game over)
  model.CrashReason? get crashReason => gameState?.crashReason;

  /// Crash position (if game over)
  Position? get crashPosition => gameState?.crashPosition;

  @override
  List<Object?> get props => [
    status,
    gameState,
    tournamentId,
    tournamentMode,
    moveProgress,
    previousGameState,
  ];
}
