import 'package:audioplayers/audioplayers.dart';
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
      
      // For now, we'll use a placeholder approach since we don't have audio files yet
      // In the actual implementation, you would load real audio files
      try {
        // await player.setSource(AssetSource('audio/$sound.wav'));
      } catch (e) {
        // Handle missing audio files gracefully
        print('Could not load sound: $sound');
      }
    }
  }

  Future<void> playSound(String soundName) async {
    if (!_initialized || !_soundEnabled) return;
    
    final player = _soundPlayers[soundName];
    if (player != null) {
      try {
        await player.stop();
        // await player.resume();
        // For now, just print the sound name since we don't have actual audio files
        print('Playing sound: $soundName');
      } catch (e) {
        print('Error playing sound $soundName: $e');
      }
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_initialized || !_musicEnabled) return;
    
    _musicPlayer ??= AudioPlayer();
    
    try {
      // await _musicPlayer!.setSource(AssetSource('audio/background_music.mp3'));
      // await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      // await _musicPlayer!.resume();
      print('Playing background music');
    } catch (e) {
      print('Error playing background music: $e');
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