import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Pre-game power-up inventory state. Keys are snake_case identifiers
/// matching the JSON wire format (the backend ASP.NET pipeline applies
/// SnakeCaseLower to outgoing dictionary keys). The `armed` field holds
/// the inventory key the user has chosen to pre-load for their next
/// game — consumed automatically when GameCubit.startGame fires.
class PowerUpState extends Equatable {
  final Map<String, int> inventory;
  final String? armed;
  final bool loading;

  const PowerUpState({
    this.inventory = const {},
    this.armed,
    this.loading = false,
  });

  PowerUpState copyWith({
    Map<String, int>? inventory,
    String? armed,
    bool clearArmed = false,
    bool? loading,
  }) {
    return PowerUpState(
      inventory: inventory ?? this.inventory,
      armed: clearArmed ? null : (armed ?? this.armed),
      loading: loading ?? this.loading,
    );
  }

  int countFor(String type) => inventory[type] ?? 0;
  int get totalOwned =>
      inventory.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [inventory, armed, loading];
}

class PowerUpCubit extends Cubit<PowerUpState> {
  final ApiService _api;

  PowerUpCubit({ApiService? api})
      : _api = api ?? ApiService(),
        super(const PowerUpState());

  /// Pull the latest inventory from the backend. Called on app start and
  /// after every mutation so multiple devices stay in sync.
  Future<void> loadInventory() async {
    if (!_api.isAuthenticated) return;
    emit(state.copyWith(loading: true));
    try {
      final data = await _api.getPowerUpInventory();
      if (data == null) {
        emit(state.copyWith(loading: false));
        return;
      }
      emit(PowerUpState(
        inventory: _parseInventory(data['inventory']),
        loading: false,
      ));
    } catch (e) {
      AppLogger.error('Failed to load power-up inventory', e);
      emit(state.copyWith(loading: false));
    }
  }

  /// Buy one use of a power-up using coins. The backend authoritatively
  /// validates the cost and atomically debits the user's coin balance;
  /// on success we mirror the returned inventory locally and return the
  /// updated coin balance so the caller can refresh CoinsCubit.
  /// Returns null on failure (caller shows an error snackbar).
  Future<int?> purchaseWithCoins(String powerUpType, int coinCost) async {
    if (!_api.isAuthenticated) return null;
    try {
      final data = await _api.purchasePowerUp(powerUpType, coinCost);
      if (data == null) return null;
      emit(state.copyWith(
        inventory: _parseInventory(data['inventory']),
      ));
      return data['coin_balance'] as int?;
    } catch (e) {
      AppLogger.error('Failed to purchase power-up', e);
      return null;
    }
  }

  /// Consume one use of a power-up. Called by the pre-game activation
  /// flow at the moment the power-up activates in-game. Also clears the
  /// armed slot — once a power-up is used the user must re-arm if they
  /// want another one on their next game (matches the "single-use"
  /// expectation: you pay to use, you don't auto-rearm).
  Future<bool> consume(String powerUpType) async {
    if (!_api.isAuthenticated) return false;
    if (state.countFor(powerUpType) <= 0) return false;
    try {
      final data = await _api.consumePowerUp(powerUpType);
      if (data == null) return false;
      emit(state.copyWith(
        inventory: _parseInventory(data['inventory']),
        clearArmed: true,
      ));
      return true;
    } catch (e) {
      AppLogger.error('Failed to consume power-up', e);
      return false;
    }
  }

  /// Arm a power-up for the next game. Validates that the user has at
  /// least one in inventory — UI should already gate this, but defensive
  /// to prevent state corruption.
  void arm(String powerUpType) {
    if (state.countFor(powerUpType) <= 0) {
      AppLogger.warning('Attempted to arm power-up not in inventory: $powerUpType');
      return;
    }
    if (state.armed == powerUpType) return;
    emit(state.copyWith(armed: powerUpType));
  }

  /// Clear the armed slot without consuming inventory. Called by the
  /// loadout sheet "Unarm" action.
  void unarm() {
    if (state.armed == null) return;
    emit(state.copyWith(clearArmed: true));
  }

  /// Map the snake_case inventory key to the gameplay PowerUpType enum.
  /// Returns null for unknown keys so a corrupted server response or a
  /// future power-up type doesn't crash the engine.
  static PowerUpType? typeFromInventoryKey(String key) {
    switch (key) {
      case 'speed_boost':
        return PowerUpType.speedBoost;
      case 'invincibility':
        return PowerUpType.invincibility;
      case 'score_multiplier':
        return PowerUpType.scoreMultiplier;
      case 'slow_motion':
        return PowerUpType.slowMotion;
      default:
        return null;
    }
  }

  Map<String, int> _parseInventory(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, int>{};
    raw.forEach((key, value) {
      if (key is String && value is int && value > 0) {
        out[key] = value;
      }
    });
    return out;
  }
}
