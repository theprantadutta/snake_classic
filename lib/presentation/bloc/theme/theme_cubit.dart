import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_state.dart';
import 'package:snake_classic/services/preferences_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';

import 'theme_state.dart';

export 'theme_state.dart';

/// Cubit for managing app theme state
class ThemeCubit extends Cubit<ThemeState> {
  final PreferencesService _preferencesService;

  ThemeCubit(this._preferencesService) : super(ThemeState.initial());

  /// Initialize the theme cubit by loading saved preferences
  Future<void> initialize() async {
    if (state.status == ThemeStatus.ready) return;

    emit(state.copyWith(status: ThemeStatus.loading));

    try {
      await _preferencesService.initialize();

      final savedTheme = _preferencesService.selectedTheme;
      final trailEnabled = _preferencesService.trailSystemEnabled;

      emit(
        state.copyWith(
          status: ThemeStatus.ready,
          currentTheme: savedTheme,
          trailSystemEnabled: trailEnabled,
        ),
      );
    } catch (e) {
      // On error, use defaults and mark as ready
      emit(state.copyWith(status: ThemeStatus.ready));
    }
  }

  /// Set the current theme
  Future<void> setTheme(GameTheme theme) async {
    if (state.currentTheme == theme) return;

    emit(state.copyWith(currentTheme: theme));
    await _preferencesService.setTheme(theme);
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
    await _preferencesService.setTrailSystemEnabled(enabled);
  }

  /// Toggle trail system
  Future<void> toggleTrailSystem() async {
    await setTrailSystemEnabled(!state.trailSystemEnabled);
  }
}
