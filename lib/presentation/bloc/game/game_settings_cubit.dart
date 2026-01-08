import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/utils/logger.dart';

import 'game_settings_state.dart';

export 'game_settings_state.dart';

/// Cubit for managing game settings (D-pad, board size, etc.)
class GameSettingsCubit extends Cubit<GameSettingsState> {
  final StorageService _storageService;
  final StatisticsService _statisticsService = StatisticsService();

  GameSettingsCubit(this._storageService) : super(GameSettingsState.initial());

  /// Initialize settings from storage
  Future<void> initialize() async {
    if (state.status == GameSettingsStatus.ready) return;

    emit(state.copyWith(status: GameSettingsStatus.loading));

    try {
      // Initialize StatisticsService first to sync high scores between
      // the statistics object and the separate highScore key
      await _statisticsService.initialize();

      // Load saved settings (now synced)
      final highScore = await _storageService.getHighScore();
      final savedBoardSize = await _storageService.getBoardSize();
      final crashFeedbackDuration = await _storageService
          .getCrashFeedbackDuration();
      final dPadEnabled = await _storageService.isDPadEnabled();
      final dPadPosition = await _storageService.getDPadPosition();
      final screenShakeEnabled = await _storageService.isScreenShakeEnabled();

      // Convert saved board size to BoardSize object
      final boardSize = _convertToBoardSize(savedBoardSize);

      emit(
        state.copyWith(
          status: GameSettingsStatus.ready,
          highScore: highScore,
          boardSize: boardSize,
          crashFeedbackDuration: crashFeedbackDuration,
          dPadEnabled: dPadEnabled,
          dPadPosition: dPadPosition,
          screenShakeEnabled: screenShakeEnabled,
        ),
      );

      AppLogger.info('GameSettingsCubit initialized. High score: $highScore');
    } catch (e) {
      AppLogger.error('Error initializing GameSettingsCubit', e);
      emit(state.copyWith(status: GameSettingsStatus.ready));
    }
  }

  BoardSize _convertToBoardSize(dynamic savedSize) {
    if (savedSize == null) return BoardSize.classic;

    // Handle BoardSize object from storage
    if (savedSize is BoardSize) return savedSize;

    // Handle map from storage
    if (savedSize is Map || savedSize.width != null) {
      final width = savedSize.width ?? savedSize['width'] ?? 20;
      final height = savedSize.height ?? savedSize['height'] ?? 20;

      return BoardSize.all.firstWhere(
        (size) => size.width == width && size.height == height,
        orElse: () => BoardSize.classic,
      );
    }

    return BoardSize.classic;
  }

  /// Update D-Pad enabled setting
  Future<void> setDPadEnabled(bool enabled) async {
    if (state.dPadEnabled == enabled) return;

    emit(state.copyWith(dPadEnabled: enabled));
    await _storageService.setDPadEnabled(enabled);
  }

  /// Alias for setDPadEnabled
  Future<void> updateDPadEnabled(bool enabled) => setDPadEnabled(enabled);

  /// Toggle D-Pad
  Future<void> toggleDPad() async {
    await setDPadEnabled(!state.dPadEnabled);
  }

  /// Update D-Pad position
  Future<void> setDPadPosition(DPadPosition position) async {
    if (state.dPadPosition == position) return;

    emit(state.copyWith(dPadPosition: position));
    await _storageService.setDPadPosition(position);
  }

  /// Alias for setDPadPosition
  Future<void> updateDPadPosition(DPadPosition position) =>
      setDPadPosition(position);

  /// Update board size
  Future<void> setBoardSize(BoardSize size) async {
    if (state.boardSize == size) return;

    emit(state.copyWith(boardSize: size));
    await _storageService.saveBoardSize(size);
  }

  /// Alias for setBoardSize
  Future<void> updateBoardSize(BoardSize size) => setBoardSize(size);

  /// Update crash feedback duration
  Future<void> setCrashFeedbackDuration(Duration duration) async {
    if (state.crashFeedbackDuration == duration) return;

    emit(state.copyWith(crashFeedbackDuration: duration));
    await _storageService.saveCrashFeedbackDuration(duration);
  }

  /// Alias for setCrashFeedbackDuration
  Future<void> updateCrashFeedbackDuration(Duration duration) =>
      setCrashFeedbackDuration(duration);

  /// Update high score if new score is higher
  Future<bool> updateHighScore(int newScore) async {
    if (newScore <= state.highScore) return false;

    emit(state.copyWith(highScore: newScore));
    await _storageService.saveHighScore(newScore);
    AppLogger.info('New high score: $newScore');
    return true;
  }

  /// Reset high score (for debugging)
  Future<void> resetHighScore() async {
    emit(state.copyWith(highScore: 0));
    await _storageService.saveHighScore(0);
  }

  /// Update screen shake setting
  Future<void> setScreenShakeEnabled(bool enabled) async {
    if (state.screenShakeEnabled == enabled) return;

    emit(state.copyWith(screenShakeEnabled: enabled));
    await _storageService.setScreenShakeEnabled(enabled);
  }

  /// Toggle screen shake
  Future<void> toggleScreenShake() async {
    await setScreenShakeEnabled(!state.screenShakeEnabled);
  }
}
