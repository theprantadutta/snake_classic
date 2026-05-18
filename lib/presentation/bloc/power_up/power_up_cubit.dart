import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Pre-game power-up inventory state. Keys are Flutter PowerUpType enum
/// names (speedBoost / invincibility / scoreMultiplier / slowMotion) and
/// values are remaining uses. The backend is the source of truth — local
/// state mirrors it after each round-trip.
class PowerUpState extends Equatable {
  final Map<String, int> inventory;
  final bool loading;

  const PowerUpState({this.inventory = const {}, this.loading = false});

  PowerUpState copyWith({Map<String, int>? inventory, bool? loading}) {
    return PowerUpState(
      inventory: inventory ?? this.inventory,
      loading: loading ?? this.loading,
    );
  }

  int countFor(String type) => inventory[type] ?? 0;
  int get totalOwned =>
      inventory.values.fold(0, (sum, count) => sum + count);

  @override
  List<Object?> get props => [inventory, loading];
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
  /// flow at the moment the power-up activates in-game.
  Future<bool> consume(String powerUpType) async {
    if (!_api.isAuthenticated) return false;
    if (state.countFor(powerUpType) <= 0) return false;
    try {
      final data = await _api.consumePowerUp(powerUpType);
      if (data == null) return false;
      emit(state.copyWith(
        inventory: _parseInventory(data['inventory']),
      ));
      return true;
    } catch (e) {
      AppLogger.error('Failed to consume power-up', e);
      return false;
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
