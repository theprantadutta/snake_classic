import 'package:equatable/equatable.dart';
import 'package:snake_classic/utils/constants.dart';

// Re-export DPadPosition and BoardSize from constants
export 'package:snake_classic/utils/constants.dart'
    show DPadPosition, BoardSize;

/// Status of the game settings cubit
enum GameSettingsStatus { initial, loading, ready }

/// State class for GameSettingsCubit
class GameSettingsState extends Equatable {
  final GameSettingsStatus status;
  final bool dPadEnabled;
  final DPadPosition dPadPosition;
  final BoardSize boardSize;
  final Duration crashFeedbackDuration;
  final int highScore;
  final bool screenShakeEnabled;

  const GameSettingsState({
    this.status = GameSettingsStatus.initial,
    this.dPadEnabled = false,
    this.dPadPosition = DPadPosition.bottomCenter,
    this.boardSize = BoardSize.classic,
    this.crashFeedbackDuration = GameConstants.defaultCrashFeedbackDuration,
    this.highScore = 0,
    this.screenShakeEnabled = false, // Disabled by default
  });

  /// Initial state
  factory GameSettingsState.initial() => const GameSettingsState();

  /// Create a copy with updated values
  GameSettingsState copyWith({
    GameSettingsStatus? status,
    bool? dPadEnabled,
    DPadPosition? dPadPosition,
    BoardSize? boardSize,
    Duration? crashFeedbackDuration,
    int? highScore,
    bool? screenShakeEnabled,
  }) {
    return GameSettingsState(
      status: status ?? this.status,
      dPadEnabled: dPadEnabled ?? this.dPadEnabled,
      dPadPosition: dPadPosition ?? this.dPadPosition,
      boardSize: boardSize ?? this.boardSize,
      crashFeedbackDuration:
          crashFeedbackDuration ?? this.crashFeedbackDuration,
      highScore: highScore ?? this.highScore,
      screenShakeEnabled: screenShakeEnabled ?? this.screenShakeEnabled,
    );
  }

  /// Whether settings are loaded and ready
  bool get isReady => status == GameSettingsStatus.ready;

  @override
  List<Object?> get props => [
    status,
    dPadEnabled,
    dPadPosition,
    boardSize,
    crashFeedbackDuration,
    highScore,
    screenShakeEnabled,
  ];
}
