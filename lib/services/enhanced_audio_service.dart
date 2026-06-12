import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Low-overhead SFX pool used by GameCubit for event cues (game_start,
/// game_over, high_score, combo tiers...). The legacy [AudioService] owns
/// the persisted sound/music settings and fans the SFX flag into this
/// service — see AudioService.setSoundEnabled.
///
/// Every sound id maps 1:1 to a shipped asset: `assets/audio/<id>.wav`.
/// A bad id fails silently (the playback error is swallowed), so check the
/// asset exists before adding a new playSfx call site.
class EnhancedAudioService {
  static final EnhancedAudioService _instance =
      EnhancedAudioService._internal();
  factory EnhancedAudioService() => _instance;
  EnhancedAudioService._internal();

  // Small pool so overlapping cues (eat + milestone on one tick) don't cut
  // each other off.
  final Map<String, AudioPlayer> _sfxPlayers = {};

  static const double _sfxVolume = 1.0;
  static const double _masterVolume = 1.0;

  bool _sfxEnabled = true;

  bool get sfxEnabled => _sfxEnabled;

  Future<void> initialize() async {
    try {
      for (int i = 0; i < 5; i++) {
        _sfxPlayers['sfx_$i'] = AudioPlayer();
      }

      if (kDebugMode) {
        print('Enhanced Audio Service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Audio initialization error: $e');
      }
    }
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
    if (!enabled) {
      _stopAll();
    }
  }

  Future<void> _stopAll() async {
    for (final player in _sfxPlayers.values) {
      await player.stop();
    }
  }

  /// Play SFX - fire and forget, non-blocking
  void playSfx(String soundId, {double? volume}) {
    if (!_sfxEnabled) return;

    // Fire and forget - don't block game loop
    _playSfxAsync(soundId, volume: volume);
  }

  Future<void> _playSfxAsync(String soundId, {double? volume}) async {
    try {
      final player = _getAvailablePlayer();
      if (player == null) return;

      final effectiveVolume =
          ((volume ?? 1.0) * _sfxVolume * _masterVolume).clamp(0.0, 1.0);
      await player.setVolume(effectiveVolume);
      await player.play(AssetSource('audio/$soundId.wav'));
    } catch (e) {
      if (kDebugMode) print('SFX playback error: $e');
    }
  }

  AudioPlayer? _getAvailablePlayer() {
    if (_sfxPlayers.isEmpty) return null;
    for (final player in _sfxPlayers.values) {
      if (player.state != PlayerState.playing) {
        return player;
      }
    }
    return _sfxPlayers.values.first; // Fallback to first player
  }

  void dispose() {
    for (final player in _sfxPlayers.values) {
      player.dispose();
    }
    _sfxPlayers.clear();
  }
}
