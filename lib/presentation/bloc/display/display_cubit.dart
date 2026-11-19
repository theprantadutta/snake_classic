import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:refresh_rate/refresh_rate.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';

import 'display_state.dart';

export 'display_state.dart';

/// Owns the app's high-refresh-rate opt-in.
///
/// Flutter's engine never calls the platform's rate-setting APIs, so a 120 Hz
/// phone renders Snake at 60 Hz unless we ask for more. Every moving thing in
/// the game — the snake itself, the trail, the crash shake, the menu
/// animations — is smoother when we do.
///
/// The preference is persisted per DEVICE (Drift `device_preferences`), not
/// per account, and is deliberately absent from the sync payload: whether
/// smooth motion is worth the battery depends on the hardware in your hand.
class DisplayCubit extends Cubit<DisplayState> {
  DisplayCubit(this._storageService) : super(const DisplayState());

  final StorageService _storageService;

  /// The platform pushes a new snapshot when the display configuration
  /// changes underneath us — battery saver toggled from the shade, thermal
  /// throttling kicking in, an external display attached.
  StreamSubscription<DisplayInfo>? _infoSubscription;

  static const String _optInMigratedKey = 'high_refresh_opt_in_v1';

  /// Read the stored preference and push it to the platform.
  ///
  /// Safe to call more than once; the second call is a no-op.
  Future<void> initialize() async {
    if (state.loaded) return;

    bool enabled = false;
    try {
      enabled = await _storageService.isHighRefreshRateEnabled();
      // 120 Hz used to be ON by default, so every high-refresh phone was
      // pushed to its top rate — on a Realme RMX3771 that halved the frame
      // budget to 8.3 ms and Living Board screens missed it. It is now an
      // opt-in, and installs that only had it because of the old default
      // are switched off once. Nobody could have chosen it deliberately:
      // it was already on. Turning it back on afterwards sticks.
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(_optInMigratedKey) ?? false)) {
        if (enabled) await _storageService.setHighRefreshRateEnabled(false);
        enabled = false;
        await prefs.setBool(_optInMigratedKey, true);
      }
    } catch (e, s) {
      AppLogger.error('Could not read the refresh-rate preference', e, s);
    }
    emit(state.copyWith(loaded: true, highRefreshRateEnabled: enabled));

    _watchPlatformChanges();
    await apply();
  }

  void _watchPlatformChanges() {
    if (_infoSubscription != null) return;
    try {
      _infoSubscription = RefreshRate.onChanged.listen(
        (info) {
          if (isClosed) return;
          emit(state.copyWith(info: info));
        },
        onError: (Object e, StackTrace s) {
          AppLogger.error('Display info stream failed', e, s);
        },
      );
    } catch (e, s) {
      // Platforms without an implementation never wire the channel up.
      AppLogger.error('Could not watch display changes', e, s);
    }
  }

  /// Push the current preference to the platform and re-read what it did.
  ///
  /// Worth calling on resume: Android drops the window's preferred display
  /// mode when the app is backgrounded, so without this the game quietly
  /// falls back to 60 Hz after a task switch.
  Future<void> apply() async {
    final high = state.highRefreshRateEnabled;
    // The 60 Hz cap goes first and does not wait on the plugin: on the A24
    // the plugin's disable() future never completed, so a cap queued after
    // it never ran and the game stayed on the system's 90 Hz.
    if (!high) await _cap60(true);
    try {
      // Awaited (with a timeout): since refresh_rate 2.0 these return
      // futures, and a failure left unawaited would escape this try.
      const limit = Duration(seconds: 2);
      if (high) {
        await _cap60(false);
        await RefreshRate.enable().timeout(limit);
        await RefreshRate.preferMax().timeout(limit);
      } else {
        await RefreshRate.disable().timeout(limit);
      }
    } catch (e, s) {
      // An unsupported device is not a failure worth bothering anyone about.
      AppLogger.error('Could not set the refresh rate', e, s);
    }
    // Again afterwards, in case the plugin's release rewrote the window's
    // preferred mode.
    if (!high) await _cap60(true);
    await refreshInfo();
  }

  static const _displayChannel = MethodChannel('snake_classic/display');

  /// Android only (MainActivity): prefer the 60 Hz display mode, or release
  /// that preference. Other platforms have no handler, which is fine.
  Future<void> _cap60(bool cap) async {
    if (!Platform.isAndroid) return;
    try {
      await _displayChannel.invokeMethod<double>('cap60', cap);
    } on MissingPluginException {
      // Older embedding / tests: nothing to do.
    } catch (e, s) {
      AppLogger.error('Could not cap the display at 60 Hz', e, s);
    }
  }

  /// Re-read what the display is actually doing right now.
  Future<void> refreshInfo() async {
    try {
      final info = await RefreshRate.refresh();
      if (isClosed) return;
      emit(state.copyWith(info: info));
    } catch (e, s) {
      AppLogger.error('Could not read display info', e, s);
    }
  }

  /// Persist and apply a new choice. No-op when nothing changed, so the
  /// switch can be driven from a rebuild without churning the database.
  Future<void> setHighRefreshRateEnabled(bool value) async {
    if (state.highRefreshRateEnabled == value) return;

    emit(state.copyWith(highRefreshRateEnabled: value));
    try {
      await _storageService.setHighRefreshRateEnabled(value);
    } catch (e, s) {
      AppLogger.error('Could not save the refresh-rate preference', e, s);
    }
    await apply();
  }

  @override
  Future<void> close() {
    _infoSubscription?.cancel();
    return super.close();
  }
}
