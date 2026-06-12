import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_state.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';

import 'theme_state.dart';

export 'theme_state.dart';

/// Cubit for managing app theme state.
///
/// Persists through StorageService → Drift GameSettings (themeIndex +
/// trailSystemEnabled), which the SyncEngine round-trips to the backend.
/// Previously this went through the SharedPreferences-based
/// PreferencesService, which meant the synced Drift columns were never
/// written (they pushed stale defaults) and the trail toggle never crossed
/// devices.
class ThemeCubit extends Cubit<ThemeState> {
  final StorageService _storageService;
  final AnalyticsFacade _analytics;

  // Keeps state in lock-step with DB writes that don't originate here —
  // most importantly the first-sign-in snapshot pull, where SyncEngine
  // applies the backend's settings row via applySettingsSnapshot. Emit-only
  // (never writes back), so it can't loop with the snapshot apply.
  StreamSubscription<GameSetting?>? _settingsSubscription;

  ThemeCubit(this._storageService, this._analytics)
      : super(ThemeState.initial());

  /// Initialize the theme cubit by loading saved preferences
  Future<void> initialize() async {
    if (state.status == ThemeStatus.ready) return;

    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      final savedTheme = await _storageService.getSelectedTheme();
      final trailEnabled = await _storageService.isTrailSystemEnabled();

      emit(
        state.copyWith(
          status: ThemeStatus.ready,
          currentTheme: savedTheme,
          trailSystemEnabled: trailEnabled,
        ),
      );

      _settingsSubscription = _storageService.watchSettings().listen((row) {
        if (row == null) return;
        final theme = GameTheme.values[
            row.themeIndex.clamp(0, GameTheme.values.length - 1)];
        if (theme != state.currentTheme ||
            row.trailSystemEnabled != state.trailSystemEnabled) {
          emit(state.copyWith(
            currentTheme: theme,
            trailSystemEnabled: row.trailSystemEnabled,
          ));
        }
      });
    } catch (e) {
      // On error, use defaults and mark as ready
      emit(state.copyWith(status: ThemeStatus.ready));
    }
  }

  /// Set the current theme
  Future<void> setTheme(GameTheme theme) async {
    if (state.currentTheme == theme) return;

    emit(state.copyWith(currentTheme: theme));
    await _storageService.saveSelectedTheme(theme);
    _analytics.trackThemeSelected(theme.name);

    // Push the choice to the backend so it survives reinstall/device-switch.
    // Premium themes are the typical case worth syncing, but we sync all
    // applied themes (including free ones) for simplicity — the value is
    // tiny and the API call is fire-and-forget.
    unawaited(ApiService().setEquippedCosmetics(themeId: theme.name));
  }

  /// Apply a theme from the backend ONLY if the local choice is still the
  /// default (classic). Called by PremiumCubit during sync to restore
  /// the equipped theme after reinstall/device-switch without overriding
  /// a deliberate local pick. No backend push — the value came FROM there.
  Future<void> applyEquippedThemeFromBackend(String themeName) async {
    if (state.currentTheme != GameTheme.classic) return;
    final target = GameTheme.values.where((t) => t.name == themeName).firstOrNull;
    if (target == null || target == GameTheme.classic) return;
    emit(state.copyWith(currentTheme: target));
    await _storageService.saveSelectedTheme(target);
  }

  /// Drop back to Classic if the currently-applied premium theme is no
  /// longer in the user's owned set (refund / chargeback / sub lapse).
  /// Pro subscribers get all premium themes implicitly, so this only
  /// fires for free-tier users with a previously-purchased theme that
  /// got revoked.
  Future<void> applyFallbackIfThemeRevoked(PremiumState premiumState) async {
    final current = state.currentTheme;
    if (!PremiumContent.isPremiumTheme(current)) return;
    if (premiumState.isThemeUnlocked(current)) return;
    emit(state.copyWith(currentTheme: GameTheme.classic));
    await _storageService.saveSelectedTheme(GameTheme.classic);
  }

  /// Cycle to the next theme (only free themes; premium themes require explicit selection)
  void cycleTheme() {
    final themes = GameTheme.values
        .where((t) => !PremiumContent.isPremiumTheme(t))
        .toList();
    if (themes.isEmpty) return;
    final currentIndex = themes.indexOf(state.currentTheme);
    final nextIndex = currentIndex == -1 ? 0 : (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  }

  /// Get the preferred transition type for a theme
  TransitionType getPreferredTransition(GameTheme theme) {
    return ThemeTransitionPresets.getPreferredTransition(theme);
  }

  /// Set trail system enabled/disabled
  Future<void> setTrailSystemEnabled(bool enabled) async {
    if (state.trailSystemEnabled == enabled) return;

    emit(state.copyWith(trailSystemEnabled: enabled));
    await _storageService.setTrailSystemEnabled(enabled);
  }

  /// Toggle trail system
  Future<void> toggleTrailSystem() async {
    await setTrailSystemEnabled(!state.trailSystemEnabled);
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
