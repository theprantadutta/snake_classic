import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/services/storage_service.dart';

class AudioService {
  static AudioService? _instance;
  final Map<String, AudioPlayer> _soundPlayers = {};
  AudioPlayer? _musicPlayer;
  final StorageService _storageService = StorageService();
  
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
    
    // Pre-load sound effects
    await _preloadSounds();
    
    _initialized = true;
  }

  Future<void> _preloadSounds() async {
    final soundEffects = [
      'eat',
      'game_over', 
      'game_start',
      'level_up',
      'high_score',
      'button_click',
    ];

    for (final sound in soundEffects) {
      final player = AudioPlayer();
      _soundPlayers[sound] = player;
      
      try {
        // Try to preload the asset - all files are now .wav
        await player.setSource(AssetSource('audio/$sound.wav'));
        await player.setVolume(0.7); // Set reasonable volume
        debugPrint('Successfully loaded: $sound.wav');
      } catch (e) {
        // If audio file doesn't exist, we'll use system sounds as fallback
        debugPrint('Audio file not found: $sound.wav - will use system sound fallback: $e');
      }
    }
  }

  Future<void> playSound(String soundName) async {
    if (!_initialized || !_soundEnabled) return;
    
    final player = _soundPlayers[soundName];
    if (player != null) {
      try {
        await player.stop(); // Stop any current playback
        await player.seek(Duration.zero); // Reset to beginning
        await player.resume(); // Start playing
        debugPrint('Playing sound: $soundName.wav');
      } catch (e) {
        // Fallback to system sounds if audio files aren't available
        await _playSystemSound(soundName);
        debugPrint('Audio error for $soundName, using system sound fallback: $e');
      }
    } else {
      await _playSystemSound(soundName);
      debugPrint('No player found for: $soundName, using system sound');
    }
  }

  Future<void> _playSystemSound(String soundName) async {
    // Fallback system sounds for different game events
    switch (soundName) {
      case 'eat':
      case 'button_click':
        await SystemSound.play(SystemSoundType.click);
        break;
      case 'game_over':
        await SystemSound.play(SystemSoundType.alert);
        break;
      case 'level_up':
      case 'high_score':
      case 'game_start':
        // Use click for positive feedback sounds
        await SystemSound.play(SystemSoundType.click);
        break;
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_initialized || !_musicEnabled) return;
    
    _musicPlayer ??= AudioPlayer();
    
    try {
      await _musicPlayer!.setSource(AssetSource('audio/background_music.mp3'));
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.4); // Lower volume for background music
      await _musicPlayer!.resume();
    } catch (e) {
      debugPrint('Background music not available: $e');
      // Continue without background music - game still playable
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_musicPlayer != null) {
      await _musicPlayer!.stop();
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storageService.setSoundEnabled(enabled);
    
    // Stop all current sounds if disabling
    if (!enabled) {
      for (final player in _soundPlayers.values) {
        await player.stop();
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
    for (final player in _soundPlayers.values) {
      player.dispose();
    }
    _musicPlayer?.dispose();
    _soundPlayers.clear();
    _musicPlayer = null;
    _initialized = false;
  }
}