import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:snake_classic/services/enhanced_audio_service.dart';
import 'package:snake_classic/services/storage_service.dart';

class AudioService {
  static AudioService? _instance;
  AudioPlayer? _musicPlayer;
  final StorageService _storageService = StorageService();

  // EnhancedAudioService keeps its own SFX-enabled flag and has no storage
  // access of its own — this service is the single owner of the persisted
  // sound/music settings and fans the sound flag out to it. Without the
  // fan-out, the half of the game's SFX routed through the enhanced
  // service ignores the user's "Sound Effects: off".
  final EnhancedAudioService _enhanced = EnhancedAudioService();

  // SoLoud for low-latency game sound effects
  final SoLoud _soloud = SoLoud.instance;
  final Map<String, AudioSource> _loadedSounds = {};

  // List of sounds to pre-load
  static const List<String> _soundsToPreload = [
    'eat',
    'level_up',
    'game_over',
    'game_start',
    'power_up',
    'button_click',
  ];

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  AudioService._internal();

  factory AudioService() {
    _instance ??= AudioService._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    _soundEnabled = await _storageService.isSoundEnabled();
    _musicEnabled = await _storageService.isMusicEnabled();
    _enhanced.setSfxEnabled(_soundEnabled);

    // Initialize SoLoud engine
    try {
      await _soloud.init();
      debugPrint('SoLoud engine initialized');

      // Pre-load all sounds
      await _preloadSounds();
    } catch (e) {
      debugPrint('Failed to initialize SoLoud: $e');
    }

    _initialized = true;
    debugPrint(
      'AudioService initialized with SoLoud - ${_loadedSounds.length} sounds loaded',
    );
  }

  /// Pre-load all sound effects into SoLoud
  Future<void> _preloadSounds() async {
    for (final soundName in _soundsToPreload) {
      try {
        final source = await _soloud.loadAsset('assets/audio/$soundName.wav');
        _loadedSounds[soundName] = source;
      } catch (e) {
        debugPrint('Failed to preload sound $soundName: $e');
      }
    }
  }

  /// Play a sound effect - instant, non-blocking
  void playSound(String soundName) {
    if (!_initialized || !_soundEnabled) return;

    final source = _loadedSounds[soundName];
    if (source != null) {
      // SoLoud.play() is non-blocking and low-latency
      _soloud.play(source);
    } else {
      // Fallback to system sound if not pre-loaded
      _playSystemSound(soundName);
    }
  }

  void _playSystemSound(String soundName) {
    switch (soundName) {
      case 'eat':
      case 'button_click':
        SystemSound.play(SystemSoundType.click);
        break;
      case 'game_over':
        SystemSound.play(SystemSoundType.alert);
        break;
      case 'level_up':
      case 'high_score':
      case 'game_start':
      case 'power_up':
        SystemSound.play(SystemSoundType.click);
        break;
    }
  }

  // True from game start until game over / quit-to-home. Music playback is
  // scoped to a run, but the setting can flip mid-run (settings screen or
  // pause menu) — this flag is what lets setMusicEnabled(true) start
  // playback immediately instead of waiting for the next game.
  bool _musicSessionActive = false;

  /// Start the looping background track for a game run. No-ops (but still
  /// marks the session active) when music is disabled, so enabling the
  /// setting mid-run picks the track up.
  Future<void> startGameplayMusic() async {
    _musicSessionActive = true;
    if (!_initialized || !_musicEnabled) return;

    _musicPlayer ??= AudioPlayer();

    try {
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.4);
      await _musicPlayer!.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      debugPrint('Background music not available: $e');
    }
  }

  /// Freeze music with the game (pause overlay up, app backgrounded).
  Future<void> pauseGameplayMusic() async {
    try {
      await _musicPlayer?.pause();
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  /// Undo [pauseGameplayMusic]. Falls back to a fresh start when there is
  /// nothing to resume — e.g. the user enabled music from the pause menu
  /// of a run that began with it disabled.
  Future<void> resumeGameplayMusic() async {
    if (!_musicSessionActive || !_musicEnabled) return;
    try {
      final player = _musicPlayer;
      if (player != null && player.state == PlayerState.paused) {
        await player.resume();
      } else if (player == null || player.state != PlayerState.playing) {
        await startGameplayMusic();
      }
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  /// End-of-run stop (game over, quit to home). Closes the music session.
  Future<void> stopGameplayMusic() async {
    _musicSessionActive = false;
    try {
      await _musicPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    _enhanced.setSfxEnabled(enabled);
    await _storageService.setSoundEnabled(enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _storageService.setMusicEnabled(enabled);

    if (!enabled) {
      // Silence immediately, but keep the session flag so re-enabling
      // during the same run brings the music back.
      try {
        await _musicPlayer?.stop();
      } catch (e) {
        debugPrint('Error stopping music: $e');
      }
    } else if (_musicSessionActive) {
      await startGameplayMusic();
    }
  }

  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;

  void dispose() {
    // Dispose all loaded sounds
    for (final source in _loadedSounds.values) {
      _soloud.disposeSource(source);
    }
    _loadedSounds.clear();

    _soloud.deinit();
    _musicPlayer?.dispose();
    _musicPlayer = null;
    _initialized = false;
  }
}
