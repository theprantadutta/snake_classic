import 'dart:async';

import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';

/// The single audio + haptic mapping for in-play simulation events.
///
/// GameCubit hands every tick's [TickEvent]s (and the post-tick active
/// power-up list) here instead of sprinkling playSound/haptic calls through
/// its event switch — so "what does eating feel like" is answered in exactly
/// one file. Visual feedback stays with its consumers (screen juice reads
/// the same events from GameCubitState.tickEvents; Flame reads them for
/// particles).
class GameFeedback {
  GameFeedback({
    required this._audioService,
    required this._hapticService,
  });

  final AudioService _audioService;
  final HapticService _hapticService;

  // Tracks the next integer-second boundary at which each active power-up
  // should fire its countdown haptic. Reset between games.
  final Map<PowerUpType, int> _powerUpCountdownLastSecond = {};

  /// Clear per-run state (countdown haptic buckets).
  void resetForNewRun() {
    _powerUpCountdownLastSecond.clear();
  }

  /// Audio/haptics for one tick's events.
  void onTickEvents(List<TickEvent> events) {
    var ateFood = false;
    var leveledUp = false;

    for (final event in events) {
      switch (event) {
        case FoodEatenEvent():
          ateFood = true;
          // Combo tier crossing — 1.0→1.5 at 5, 1.5→2.0 at 10, 2.0→3.0 at
          // 20. Each crossing earns a medium haptic; the 3.0 tier earns an
          // extra heavy on top. SFX reuses level_up at low volume so it
          // doesn't drown the food-eat sound (there is no
          // score_milestone.wav asset — the previous id failed silently).
          if (event.comboTierIncreased) {
            unawaited(_hapticService.mediumImpact());
            if (event.newMultiplier >= 3.0) {
              unawaited(_hapticService.heavyImpact());
            }
            _audioService.playSound('level_up', volume: 0.45);
          }
        case LeveledUpEvent():
          leveledUp = true;
          _audioService.playSound('level_up');
          unawaited(_hapticService.levelUp());
        case PowerUpCollectedEvent():
          _hapticService.powerUpCollected();
          _audioService.playSound('power_up');
        case ComboBrokenEvent():
          // Streak decayed to zero (comboDecayMs of game-time without a
          // bite). Subtle cue only — a light buzz; the HUD combo chip
          // resetting is the visual signal. No sound: a "loss" sting on
          // top of normal play would read as punishment.
          if (event.previousCombo >= 5) {
            unawaited(_hapticService.lightImpact());
          }
        case CrashEvent():
          break; // Crash feedback is owned by the crash/game-over flow.
      }
    }

    // Eat sound + haptic only when no level-up fired this tick (the
    // level-up cue takes precedence — mirrors the original eat-vs-levelup
    // branch).
    if (ateFood && !leveledUp) {
      _audioService.playSound('eat');
      unawaited(_hapticService.foodEaten());
    }
  }

  /// Power-up countdown haptic: fire once when each active power-up's
  /// remaining time first dips below 3s, 2s, and 1s. The visual flash
  /// already pulses in the last 3 seconds — this adds a felt cue for
  /// eyes-on-snake.
  void onActivePowerUps(List<ActivePowerUp> activePowerUps) {
    for (final p in activePowerUps) {
      final remainingMs = p.remainingTime.inMilliseconds;
      if (remainingMs <= 0 || remainingMs > 3000) continue;
      final bucket = (remainingMs + 999) ~/ 1000; // ceil → 3, 2, 1.
      final lastBucket = _powerUpCountdownLastSecond[p.type];
      if (lastBucket == null || lastBucket > bucket) {
        _powerUpCountdownLastSecond[p.type] = bucket;
        unawaited(_hapticService.scoreMilestone());
      }
    }
    // Drop entries for power-ups that have expired since the last tick so a
    // fresh future collection of the same type re-arms the countdown.
    if (_powerUpCountdownLastSecond.isNotEmpty) {
      final activeTypes = activePowerUps.map((p) => p.type).toSet();
      _powerUpCountdownLastSecond
          .removeWhere((type, _) => !activeTypes.contains(type));
    }
  }
}
