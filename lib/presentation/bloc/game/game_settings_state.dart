import 'package:equatable/equatable.dart';
import 'package:snake_classic/utils/constants.dart';

// Re-export DPadPosition, BoardSize, and GameMode from constants
export 'package:snake_classic/utils/constants.dart'
    show DPadPosition, BoardSize, GameMode;

/// Status of the game settings cubit
enum GameSettingsStatus { initial, loading, ready }

/// State class for GameSettingsCubit
class GameSettingsState extends Equatable {
  final GameSettingsStatus status;
  final bool dPadEnabled;
  final DPadPosition dPadPosition;

  /// Which on-screen control [dPadEnabled] shows. Device-local.
  final ControlLayout controlLayout;

  /// Render cell-by-cell instead of gliding between cells. Device-local.
  final bool snapMovementEnabled;
  final BoardSize boardSize;
  final Difficulty difficulty;
  final GameMode gameMode;
  final bool gameModeFirstLaunchPrompted;
  final Duration crashFeedbackDuration;
  final int highScore;
  final bool screenShakeEnabled;
  final bool hapticsEnabled;

  /// BCP-47 tag of the user's app-language override ('en', 'hi', 'pt', …).
  /// Null = follow the device locale.
  final String? localeCode;

  const GameSettingsState({
    this.status = GameSettingsStatus.initial,
    this.dPadEnabled = false,
    this.dPadPosition = DPadPosition.bottomCenter,
    this.controlLayout = ControlLayout.dPad,
    this.snapMovementEnabled = false,
    this.boardSize = BoardSize.classic,
    this.difficulty = Difficulty.normal,
    this.gameMode = GameMode.classic,
    this.gameModeFirstLaunchPrompted = false,
    this.crashFeedbackDuration = GameConstants.defaultCrashFeedbackDuration,
    this.highScore = 0,
    this.screenShakeEnabled = false, // Disabled by default
    this.hapticsEnabled = true,
    this.localeCode,
  });

  /// Initial state
  factory GameSettingsState.initial() => const GameSettingsState();

  /// Create a copy with updated values
  GameSettingsState copyWith({
    GameSettingsStatus? status,
    bool? dPadEnabled,
    DPadPosition? dPadPosition,
    ControlLayout? controlLayout,
    bool? snapMovementEnabled,
    BoardSize? boardSize,
    Difficulty? difficulty,
    GameMode? gameMode,
    bool? gameModeFirstLaunchPrompted,
    Duration? crashFeedbackDuration,
    int? highScore,
    bool? screenShakeEnabled,
    bool? hapticsEnabled,
    String? localeCode,
    bool clearLocaleCode = false,
  }) {
    return GameSettingsState(
      status: status ?? this.status,
      dPadEnabled: dPadEnabled ?? this.dPadEnabled,
      dPadPosition: dPadPosition ?? this.dPadPosition,
      controlLayout: controlLayout ?? this.controlLayout,
      snapMovementEnabled: snapMovementEnabled ?? this.snapMovementEnabled,
      boardSize: boardSize ?? this.boardSize,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      gameModeFirstLaunchPrompted:
          gameModeFirstLaunchPrompted ?? this.gameModeFirstLaunchPrompted,
      crashFeedbackDuration:
          crashFeedbackDuration ?? this.crashFeedbackDuration,
      highScore: highScore ?? this.highScore,
      screenShakeEnabled: screenShakeEnabled ?? this.screenShakeEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      localeCode:
          clearLocaleCode ? null : (localeCode ?? this.localeCode),
    );
  }

  /// Whether settings are loaded and ready
  bool get isReady => status == GameSettingsStatus.ready;

  @override
  List<Object?> get props => [
    status,
    dPadEnabled,
    dPadPosition,
    controlLayout,
    snapMovementEnabled,
    boardSize,
    difficulty,
    gameMode,
    gameModeFirstLaunchPrompted,
    crashFeedbackDuration,
    highScore,
    screenShakeEnabled,
    hapticsEnabled,
    localeCode,
  ];
}
