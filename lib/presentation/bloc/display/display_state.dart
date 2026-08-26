import 'package:equatable/equatable.dart';
import 'package:refresh_rate/refresh_rate.dart';

/// State for [DisplayCubit] — the stored preference plus whatever the panel
/// is actually doing right now.
class DisplayState extends Equatable {
  const DisplayState({
    this.loaded = false,
    this.highRefreshRateEnabled = true,
    this.info,
  });

  /// False until the stored preference has been read off disk. The UI uses
  /// this to avoid telling someone their 120 Hz screen is single-rate before
  /// we have actually asked it.
  final bool loaded;

  /// The user's choice, as persisted in the device-local Drift row.
  final bool highRefreshRateEnabled;

  /// Last snapshot read back from the platform. Null until the first
  /// successful query — on an unsupported platform it stays null forever.
  final DisplayInfo? info;

  /// A display that can only do one rate has nothing to offer here, so the
  /// toggle is shown disabled rather than pretending it does something.
  ///
  /// `maxRate > 61` rather than `> 60` because panels report awkward real
  /// numbers (59.94, 60.000004) and a strict comparison flags those as high
  /// refresh.
  bool get deviceSupportsHighRate {
    final i = info;
    if (i == null) return false;
    return i.maxRate > 61 || i.supportedRates.length > 1;
  }

  /// The platform throttles the display in battery saver whatever we ask for.
  /// Worth saying out loud rather than looking broken.
  bool get throttledByBattery => info?.isLowPowerMode ?? false;

  /// Likewise when the device is hot: the OS clamps the rate to cool down.
  bool get throttledByHeat {
    final i = info;
    if (i == null) return false;
    return i.thermalState != ThermalState.nominal &&
        i.thermalState != ThermalState.unknown;
  }

  /// Whether the big number is currently the result of our own request, as
  /// opposed to the platform default we never overrode.
  bool get isLive =>
      info != null && highRefreshRateEnabled && deviceSupportsHighRate;

  DisplayState copyWith({
    bool? loaded,
    bool? highRefreshRateEnabled,
    DisplayInfo? info,
  }) {
    return DisplayState(
      loaded: loaded ?? this.loaded,
      highRefreshRateEnabled:
          highRefreshRateEnabled ?? this.highRefreshRateEnabled,
      info: info ?? this.info,
    );
  }

  @override
  List<Object?> get props => [
        loaded,
        highRefreshRateEnabled,
        // DisplayInfo is a plain model without value equality, so compare the
        // fields the UI actually renders. Without this the cubit would emit
        // an "identical" state on every refresh and the readout would freeze.
        info?.currentRate,
        info?.maxRate,
        info?.supportedRates,
        info?.isLowPowerMode,
        info?.thermalState,
      ];
}
