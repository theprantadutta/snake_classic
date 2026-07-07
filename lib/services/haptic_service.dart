import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Haptic feedback for game + UI events, gated on the user's
/// hapticsEnabled setting (wired from GameSettingsCubit.setEnabled).
///
/// Kept intentionally lean: only events with real call sites live here.
/// An earlier build carried ~175 lines of speculative API (per-theme
/// effect patterns, crescendo/pulse/chain sequences, a custom-intensity
/// dispatcher) that nothing ever called — deleted, not wired up.
class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Basic feedback for button taps and selections
  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) print('Haptic feedback error: $e');
    }
  }

  /// Light impact feedback for subtle interactions
  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) print('Haptic feedback error: $e');
    }
  }

  /// Medium impact feedback for standard interactions
  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) print('Haptic feedback error: $e');
    }
  }

  /// Heavy impact feedback for significant interactions
  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) print('Haptic feedback error: $e');
    }
  }

  /// Game-specific haptic feedback methods

  /// Feedback for food consumption
  Future<void> foodEaten() async {
    await mediumImpact();
  }

  /// Feedback for power-up collection
  Future<void> powerUpCollected() async {
    await _successPattern();
  }

  /// Feedback for level up
  Future<void> levelUp() async {
    await _levelUpPattern();
  }

  /// Feedback for game over
  Future<void> gameOver() async {
    await _gameOverPattern();
  }

  /// Feedback for wall collision
  Future<void> wallHit() async {
    await _errorPattern();
  }

  /// Feedback for self collision
  Future<void> selfCollision() async {
    await _warningPattern();
  }

  /// Feedback for score milestone
  Future<void> scoreMilestone() async {
    await _scoreMilestonePattern();
  }

  /// Private helper methods for complex patterns

  Future<void> _successPattern() async {
    if (!_isEnabled) return;
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 30));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 30));
    await heavyImpact();
  }

  Future<void> _warningPattern() async {
    if (!_isEnabled) return;
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await heavyImpact();
  }

  Future<void> _errorPattern() async {
    if (!_isEnabled) return;
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await heavyImpact();
  }

  Future<void> _levelUpPattern() async {
    if (!_isEnabled) return;
    // Ascending intensity pattern
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 40));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 40));
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await lightImpact();
  }

  Future<void> _gameOverPattern() async {
    if (!_isEnabled) return;
    // Dramatic descending pattern
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    await lightImpact();
  }

  Future<void> _scoreMilestonePattern() async {
    if (!_isEnabled) return;
    // Quick celebratory double tap
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await heavyImpact();
  }
}
