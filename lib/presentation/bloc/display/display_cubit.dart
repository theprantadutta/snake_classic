import 'dart:async';

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

  /// Read the stored preference and push it to the platform.
  ///
  /// Safe to call more than once; the second call is a no-op.
  Future<void> initialize() async {
    if (state.loaded) return;

    bool enabled = true;
    try {
      enabled = await _storageService.isHighRefreshRateEnabled();
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
    try {
      if (state.highRefreshRateEnabled) {
        RefreshRate.enable();
        RefreshRate.preferMax();
      } else {
        RefreshRate.disable();
      }
    } catch (e, s) {
      // An unsupported device is not a failure worth bothering anyone about.
      AppLogger.error('Could not set the refresh rate', e, s);
    }
    await refreshInfo();
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
