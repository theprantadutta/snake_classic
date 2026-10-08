import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, WidgetsBinding;
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

  // SoLoud for low-latency game sound effects.
  //
  // A getter, not a field. `SoLoud.instance` opens
  // flutter_soloud_plugin.dll / .so on first access, so holding it in a
  // field initializer meant merely CONSTRUCTING this service loaded the
  // native audio library — including in callers that only wanted to read or
  // flip a persisted flag, and including unit tests, where it fails outright
  // with "Failed to load dynamic library". SoLoud.instance is itself a
  // singleton, so resolving it per use costs nothing; it just happens at the
  // first real audio call instead of at construction.
  SoLoud get _soloud => SoLoud.instance;
  final Map<String, AudioSource> _loadedSounds = {};

  // The Living Board sound set (assets/audio/lb/sfx/, DESIGN_SPEC §6). The
  // file names are the contract: a final mix can replace any of them
  // without touching code.
  static const List<String> _soundsToPreload = [
    'eat',
    'eat_bonus',
    'eat_special',
    'combo_up',
    'combo_break',
    'level_up',
    'power_up',
    'power_down',
    'crash_wall',
    'crash_self',
    'revive',
    'game_over',
    'new_best',
    'coin',
    'claim',
    'ad_reward',
    'ui_tap',
    'ui_back',
    'countdown_tick',
    'countdown_go',
    'match_found',
    'victory',
    'defeat',
    'turn',
  ];

  // Older logical ids still used by call sites, mapped onto the set above.
  static const Map<String, String> _soundAliases = {
    'button_click': 'ui_tap',
    'game_start': 'countdown_go',
    'high_score': 'new_best',
    'coin_collect': 'claim',
  };

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  AudioService._internal();

  factory AudioService() {
    _instance ??= AudioService._internal();
    return _instance!;
  }

  // The engine is released while the app is in the background and brought
  // back on resume.
  //
  // Left running, SoLoud's mixer thread and its AAudio/AudioTrack stream
  // outlive the Flutter engine. When Android destroys the activity (back out
  // of the app, or the OS reclaiming a backgrounded process) the isolate goes
  // away but the mixer does not, and the next voice-ended callback it fires
  // lands on a NativeCallable whose isolate is gone. The Dart VM aborts in
  // DLRT_GetFfiCallbackMetadata — Sentry SNAKE-CLASSIC-FLUTTER-3, a SIGABRT
  // minutes to an hour after the app was backgrounded. The same open stream
  // is behind the SIGABRT on android::Thread::_threadLoop
  // (SNAKE-CLASSIC-FLUTTER-4): an audio callback thread asserting in the
  // background under low memory. The plugin's 4.1.0 shutdown fix only covers
  // an explicit deinit(), which nothing ever called.
  //
  // Nothing plays in the background anyway — gameplay pauses with the app —
  // so there is no stream worth keeping open. Re-initialising costs ~100 ms
  // (engine + the seven preloaded SFX) on the way back in.
  AppLifecycleListener? _lifecycleListener;
  bool _suspended = false;

  /// Serialises init / suspend / resume. A quick background-foreground flip
  /// must not start init() while deinitAsync() is still joining the audio
  /// thread, nor preload into an engine that is being torn down.
  Future<void> _engineOps = Future.value();

  Future<void> _enqueue(Future<void> Function() op) {
    final next = _engineOps.then((_) => op());
    // Never let one failed step wedge every later one.
    _engineOps = next.catchError((Object _) {});
    return next;
  }

  Future<void> initialize() => _enqueue(_initialize);

  Future<void> _initialize() async {
    if (_initialized || _suspended) return;

    // Registered before the first await: a cold start can be backgrounded
    // while the engine is still coming up. The queued suspend then runs as
    // soon as this finishes, instead of leaving the engine open until the
    // next pause.
    _lifecycleListener ??= AppLifecycleListener(
      onPause: () => unawaited(_enqueue(_suspend)),
      onDetach: () => unawaited(_enqueue(_suspend)),
      onResume: () => unawaited(_enqueue(_resume)),
    );

    _soundEnabled = await _storageService.isSoundEnabled();
    _musicEnabled = await _storageService.isMusicEnabled();

    await _startEngine();

    _initialized = true;
    debugPrint(
      'AudioService initialized with SoLoud - ${_loadedSounds.length} sounds loaded',
    );
    _syncMenuMusic();

    // Already in the background before the listener existed (it reports
    // transitions, not the current state).
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await _suspend();
    }
  }

  Future<void> _startEngine() async {
    try {
      await _soloud.init();
      // flutter_soloud 5 stops the output device after 500 ms of silence,
      // so the next sound (a bite after a quiet stretch) would wait for the
      // device to start again. Keep it running while the engine is up, as 4.x
      // did; _suspend() still releases it whenever the app is backgrounded.
      _soloud.setAudioDeviceIdleTimeout(null);
      debugPrint('SoLoud engine initialized');

      // Pre-load all sounds
      await _preloadSounds();
    } catch (e) {
      debugPrint('Failed to initialize SoLoud: $e');
    }
  }

  /// Release the engine for the background. See [_lifecycleListener].
  Future<void> _suspend() async {
    if (!_initialized || _suspended) return;
    _suspended = true;
    _engineGeneration++;
    // Gate every playback path first, so nothing reaches FFI mid-teardown.
    _initialized = false;
    // deinit() disposes every source and voice, so these references die
    // with it. The music session flag survives: resumeGameplayMusic starts
    // a fresh voice when the player unpauses.
    _loadedSounds.clear();
    _musicSource = null;
    _musicHandle = null;
    _menuSource = null;
    _menuHandle = null;
    try {
      // The async variant stops the device without blocking the UI isolate
      // while the audio thread is joined — this runs on the way into the
      // background, exactly where a blocked main thread becomes an ANR.
      await _soloud.deinitAsync();
    } catch (e) {
      debugPrint('SoLoud suspend failed: $e');
    }
  }

  Future<void> _resume() async {
    if (!_suspended) return;
    _suspended = false;
    await _startEngine();
    _initialized = true;
    // A revive after a rewarded ad calls resumeGameplayMusic the moment the
    // ad closes — usually before this re-init has finished, when the call
    // can only record the intent. Honour it now, or the rest of the run
    // plays in silence.
    if (_musicSessionActive && _musicWanted) {
      await startGameplayMusic();
    }
    _syncMenuMusic();
  }

  /// Pre-load all sound effects into SoLoud
  Future<void> _preloadSounds() async {
    for (final soundName in _soundsToPreload) {
      try {
        final source = await _soloud.loadAsset('assets/audio/lb/sfx/$soundName.wav');
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

  /// Whether the game currently wants the music AUDIBLE (started or resumed,
  /// and not paused or stopped since). Kept apart from the voice handle
  /// because the handle dies with the engine on every trip to the
  /// background — including every full-screen ad — and a start or resume
  /// that lands while the engine is still coming back must not be lost.
  bool _musicWanted = false;

  /// The start in progress, so concurrent callers share it instead of each
  /// loading the track and starting a second looping voice.
  Future<void>? _musicStart;

  /// Bumped on every suspend. A source loaded across one belongs to an
  /// engine that no longer exists and must not be cached or played.
  int _engineGeneration = 0;

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
  Future<void> startGameplayMusic() {
    _musicSessionActive = true;
    _musicWanted = true;
    _syncMenuMusic();
    if (!_initialized || !_musicEnabled) return Future.value();
    return _musicStart ??= _startMusicVoice().whenComplete(() {
      _musicStart = null;
    });
  }

  Future<void> _startMusicVoice() async {
    try {
      // LoadMode.disk streams the file instead of decompressing the whole
      // track into RAM. Right trade for a multi-minute loop; the SFX stay in
      // memory, where their latency matters.
      final generation = _engineGeneration;
      final source = _musicSource ??
          await _soloud.loadAsset(
            'assets/audio/lb/music/run_loop_140bpm.wav',
            mode: LoadMode.disk,
          );
      if (generation != _engineGeneration) return;
      _musicSource = source;

      // Already running — don't stack a second voice on top of it.
      if (_liveMusicHandle != null) return;
      // Paused, stopped or backgrounded while the track was loading.
      if (!_initialized || !_musicWanted || !_musicEnabled) return;

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
    _musicWanted = false;
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
    _musicWanted = true;
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
    _musicWanted = false;
    await _stopMusicVoice();
    _syncMenuMusic();
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
    _syncMenuMusic();
  }

  /// Apply audio flags that were changed in storage by someone else,
  /// WITHOUT writing them back.
  ///
  /// The case this exists for is the first-sign-in cloud restore: it writes
  /// the restored account's settings straight into the Drift row, so
  /// GameSettingsCubit's watchSettings stream sees the change and the UI
  /// updates — but this service's in-memory flags would stay on the old
  /// device's values, and the playback gates read those. The result was a
  /// Settings screen reading "music off" while the music kept playing.
  ///
  /// Deliberately not [setSoundEnabled]/[setMusicEnabled]: those persist,
  /// and persisting a value we just read back out of storage would write on
  /// every restore and enqueue a pointless sync-outbox row each time.
  Future<void> applyPersistedFlags({
    required bool sound,
    required bool music,
  }) async {
    _soundEnabled = sound;

    if (_musicEnabled == music) return;
    _musicEnabled = music;

    // Music, unlike sound, has to act on the change: the currently playing
    // voice keeps going otherwise.
    if (!music) {
      await _stopMusicVoice();
    } else if (_musicSessionActive) {
      await startGameplayMusic();
    }
    _syncMenuMusic();
  }

  // ---- Menu loop -----------------------------------------------------------
  //
  // DESIGN_SPEC §6: `menu_loop_118bpm` on menus, `run_loop_140bpm` in runs.
  // The menu loop plays whenever music is on and no run owns the music
  // session, except on routes that are gameplay surfaces (the board before
  // the first move, a live Versus match) — see [setMenuMusicRouteAllowed].
  // Full-screen ads need no handling: they background the activity, which
  // suspends the whole engine, exactly as for the run loop.

  AudioSource? _menuSource;
  SoundHandle? _menuHandle;
  Future<void>? _menuStart;
  bool _menuRouteAllowed = true;

  /// Quieter than the run loop: it sits under browsing, not play.
  static const double _menuVolume = 0.28;
  static const Duration _menuFadeIn = Duration(milliseconds: 900);
  static const Duration _menuFadeOut = Duration(milliseconds: 350);

  SoundHandle? get _liveMenuHandle {
    final handle = _menuHandle;
    if (handle == null) return null;
    if (!_soloud.getIsValidVoiceHandle(handle)) {
      _menuHandle = null;
      return null;
    }
    return handle;
  }

  /// Called by the route observer: false on gameplay routes.
  void setMenuMusicRouteAllowed(bool allowed) {
    if (_menuRouteAllowed == allowed) return;
    _menuRouteAllowed = allowed;
    _syncMenuMusic();
  }

  bool get _menuMusicWanted =>
      _initialized && !_suspended && _musicEnabled && !_musicSessionActive && _menuRouteAllowed;

  /// Start or fade out the menu loop to match the current state.
  void _syncMenuMusic() {
    if (_menuMusicWanted) {
      if (_liveMenuHandle == null) {
        _menuStart ??= _startMenuVoice().whenComplete(() => _menuStart = null);
      }
      return;
    }
    final handle = _liveMenuHandle;
    _menuHandle = null;
    if (handle == null || !_initialized) return;
    try {
      _soloud.fadeVolume(handle, 0, _menuFadeOut);
      _soloud.scheduleStop(handle, _menuFadeOut);
    } catch (e) {
      debugPrint('Error stopping menu music: $e');
    }
  }

  Future<void> _startMenuVoice() async {
    try {
      final generation = _engineGeneration;
      final source = _menuSource ??
          await _soloud.loadAsset(
            'assets/audio/lb/music/menu_loop_118bpm.wav',
            mode: LoadMode.disk,
          );
      if (generation != _engineGeneration) return;
      _menuSource = source;
      if (_liveMenuHandle != null || !_menuMusicWanted) return;
      final handle = _soloud.play(source, volume: 0, looping: true);
      if (!_soloud.getIsValidVoiceHandle(handle)) return;
      _menuHandle = handle;
      _soloud.fadeVolume(handle, _menuVolume, _menuFadeIn);
    } catch (e) {
      debugPrint('Menu music not available: $e');
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
    // Nothing calls this today; the background release above is what
    // actually stops the engine.
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _soloud.deinit();
    _loadedSounds.clear();
    _musicSource = null;
    _musicHandle = null;
    _initialized = false;
  }
}
