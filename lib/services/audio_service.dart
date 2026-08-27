import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:snake_classic/services/storage_service.dart';

/// The app's single audio service. One engine: SoLoud, for both the preloaded
/// low-latency SFX and the looping background track.
///
/// The music used to run on a second engine (audioplayers) for one asset in
/// one method. Two native audio stacks meant two output streams open on the
/// same device, and Play Console vitals showed failures on both sides of that
/// split — a SoLoud mixer segfault, an `AudioTrack::setVolume` crash, and an
/// `audioplayers UrlSource.setForMediaPlayer` ANR. Cheap Android audio HALs
/// are exactly where two clients contending for one device goes wrong.
///
/// SoLoud does looping and streaming natively, so the second engine bought
/// nothing.
///
/// There used to be a second SFX engine (EnhancedAudioService, an
/// audioplayers pool with NO preloading) and the same game routed sounds
/// through both depending on call site — the same level_up.wav could play
/// through SoLoud in one branch and decode-from-bundle in another, and the
/// dual path caused real double-play bugs (see startGame's history note in
/// game_cubit). Everything now goes through here.
class AudioService {
  static AudioService? _instance;
  final StorageService _storageService = StorageService();

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
    // Ships as an asset but was missing from this list — playSound fell
    // through to a generic OS click on every high-score/achievement moment.
    'high_score',
  ];

  // Logical sound ids with no dedicated asset, mapped onto a shipped one.
  // 'coin_collect' is used by every coin-claim surface (game over, daily
  // challenges, weekly quests) but coin_collect.wav never shipped — the
  // fallback switch had no case for it either, so those moments were
  // completely silent.
  static const Map<String, String> _soundAliases = {
    'coin_collect': 'power_up',
  };

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

  /// Play a sound effect - instant, non-blocking. [volume] is 0.0–1.0;
  /// call sites hand-tune it per event so cues layer without drowning
  /// each other (there is no master mixer). [playbackRate] pitch-shifts
  /// the shipped asset (e.g. 0.85 gives game_over a duller "self
  /// collision" variant without a second wav).
  void playSound(String soundName, {double volume = 1.0, double playbackRate = 1.0}) {
    if (!_initialized || !_soundEnabled) return;

    final source = _loadedSounds[_soundAliases[soundName] ?? soundName];
    if (source != null) {
      if (playbackRate == 1.0) {
        // SoLoud.play() is non-blocking and low-latency
        _soloud.play(source, volume: volume);
      } else {
        _playAtRate(source, volume, playbackRate);
      }
    } else {
      // Fallback to system sound if not pre-loaded
      _playSystemSound(soundName);
    }
  }

  void _playAtRate(AudioSource source, double volume, double rate) {
    try {
      final handle = _soloud.play(source, volume: volume);
      // play() does NOT throw when the engine runs out of voices. SoLoud
      // treats maxActiveVoiceCountReached as a warning and hands back a
      // ZEROED handle instead (see _checkPlaybackResult in the plugin) —
      // "the sound did not play, but this is a warning, not a failure".
      //
      // setRelativePlaySpeed validates only that the engine is initialized
      // and then passes the handle straight to native FFI, so a zeroed
      // handle reached the C++ engine and corrupted voice state while the
      // mixer thread was running. The crash surfaced later and elsewhere:
      // on the AAudio callback thread, deep inside SoLoud's mix loop, at an
      // address belonging to no library.
      //
      // Voice exhaustion is not exotic here. This path is the rate-shifted
      // game_over cue, which fires at the exact moment the crash and
      // particle sounds are already playing.
      //
      // Checking the handle is the plugin's own idiom for this — see how it
      // guards stop(): "we should check if it is still valid".
      if (!_soloud.getIsValidVoiceHandle(handle)) return;
      _soloud.setRelativePlaySpeed(handle, rate);
    } catch (e) {
      debugPrint('Rate-shifted play failed: $e');
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

  /// The streamed background track, loaded once and reused.
  AudioSource? _musicSource;
  SoundHandle? _musicHandle;

  /// Volume of the background loop. Sits under the SFX so cues stay audible.
  static const double _musicVolume = 0.4;

  /// The music voice, or null if it is gone.
  ///
  /// Everything that touches the handle goes through here, because SoLoud
  /// recycles voices and NONE of setPause / setVolume / getPause validate the
  /// handle they are given — they check that the engine is initialized and
  /// then hand it straight to native FFI. That is the same door the
  /// setRelativePlaySpeed crash came through, so the music path is written to
  /// never open it.
  SoundHandle? get _liveMusicHandle {
    final handle = _musicHandle;
    if (handle == null) return null;
    if (!_soloud.getIsValidVoiceHandle(handle)) {
      _musicHandle = null;
      return null;
    }
    return handle;
  }

  /// Start the looping background track for a game run. No-ops (but still
  /// marks the session active) when music is disabled, so enabling the
  /// setting mid-run picks the track up.
  Future<void> startGameplayMusic() async {
    _musicSessionActive = true;
    if (!_initialized || !_musicEnabled) return;

    try {
      // LoadMode.disk streams the file instead of decompressing the whole
      // track into RAM. Right trade for a multi-minute loop; the SFX stay in
      // memory, where their latency matters.
      _musicSource ??= await _soloud.loadAsset(
        'assets/audio/background_music.mp3',
        mode: LoadMode.disk,
      );

      // Already running — don't stack a second voice on top of it.
      if (_liveMusicHandle != null) return;

      final handle = _soloud.play(
        _musicSource!,
        volume: _musicVolume,
        looping: true,
      );
      // play() returns a zeroed handle rather than throwing when the engine
      // is out of voices, so this is not paranoia.
      _musicHandle = _soloud.getIsValidVoiceHandle(handle) ? handle : null;
    } catch (e) {
      debugPrint('Background music not available: $e');
    }
  }

  /// Freeze music with the game (pause overlay up, app backgrounded).
  Future<void> pauseGameplayMusic() async {
    final handle = _liveMusicHandle;
    if (handle == null) return;
    try {
      _soloud.setPause(handle, true);
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  /// Undo [pauseGameplayMusic]. Falls back to a fresh start when there is
  /// nothing to resume — e.g. the user enabled music from the pause menu
  /// of a run that began with it disabled.
  Future<void> resumeGameplayMusic() async {
    if (!_musicSessionActive || !_musicEnabled) return;
    final handle = _liveMusicHandle;
    if (handle != null) {
      try {
        _soloud.setPause(handle, false);
        return;
      } catch (e) {
        debugPrint('Error resuming music: $e');
      }
    }
    // No voice to resume: the run started with music off, or the voice was
    // reclaimed. Start a fresh one.
    await startGameplayMusic();
  }

  /// End-of-run stop (game over, quit to home). Closes the music session.
  Future<void> stopGameplayMusic() async {
    _musicSessionActive = false;
    await _stopMusicVoice();
  }

  /// Stops the music voice, if there is one, and forgets it.
  Future<void> _stopMusicVoice() async {
    final handle = _liveMusicHandle;
    _musicHandle = null;
    if (handle == null) return;
    try {
      await _soloud.stop(handle);
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storageService.setSoundEnabled(enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _storageService.setMusicEnabled(enabled);

    if (!enabled) {
      // Silence immediately, but keep the session flag so re-enabling
      // during the same run brings the music back.
      await _stopMusicVoice();
    } else if (_musicSessionActive) {
      await startGameplayMusic();
    }
  }

  bool get isSoundEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;

  void dispose() {
    // deinit() first, and no disposeSource loop. Freeing sources while the
    // engine is still mixing is a use-after-free on the audio thread, and the
    // loop was redundant anyway: deinit() "stops the engine and disposes of
    // all resources, including sounds".
    //
    // Nothing calls this today, which is the only reason it never fired.
    _soloud.deinit();
    _loadedSounds.clear();
    _musicSource = null;
    _musicHandle = null;
    _initialized = false;
  }
}
