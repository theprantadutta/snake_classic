import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/services/storage_service.dart';

class AudioService {
  static AudioService? _instance;
  AudioPlayer? _musicPlayer;
  final StorageService _storageService = StorageService();

  // Pool of players for concurrent sound effects
  final List<AudioPlayer> _playerPool = [];
  static const int _maxPoolSize = 5;

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

    // Pre-create player pool
    for (int i = 0; i < _maxPoolSize; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _playerPool.add(player);
    }

    _initialized = true;
    debugPrint('AudioService initialized with $_maxPoolSize players');
  }

  /// Get an available player from the pool
  AudioPlayer? _getAvailablePlayer() {
    for (final player in _playerPool) {
      if (player.state == PlayerState.stopped ||
          player.state == PlayerState.completed) {
        return player;
      }
    }
    // If all players are busy, return the first one (will interrupt it)
    return _playerPool.isNotEmpty ? _playerPool.first : null;
  }

  /// Play a sound effect - fire and forget, non-blocking
  void playSound(String soundName) {
    if (!_initialized || !_soundEnabled) return;

    // Fire and forget - don't block game loop
    _playSoundAsync(soundName);
  }

  Future<void> _playSoundAsync(String soundName) async {
    try {
      final player = _getAvailablePlayer();
      if (player == null) {
        _playSystemSoundSync(soundName);
        return;
      }

      // Use play() directly with source - simpler and more reliable
      await player.setVolume(0.7);
      await player.play(
        AssetSource('audio/$soundName.wav'),
      ).timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {
          debugPrint('Audio play timeout for $soundName, using system sound');
          _playSystemSoundSync(soundName);
        },
      );
    } catch (e) {
      debugPrint('Audio error for $soundName: $e');
      _playSystemSoundSync(soundName);
    }
  }

  void _playSystemSoundSync(String soundName) {
    // Fire and forget system sounds
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

  Future<void> playBackgroundMusic() async {
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

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer?.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storageService.setSoundEnabled(enabled);

    if (!enabled) {
      // Stop all pool players
      for (final player in _playerPool) {
        try {
          await player.stop();
        } catch (_) {}
      }
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _storageService.setMusicEnabled(enabled);

    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;

  void dispose() {
    for (final player in _playerPool) {
      player.dispose();
    }
    _playerPool.clear();
    _musicPlayer?.dispose();
    _musicPlayer = null;
    _initialized = false;
  }
}
