import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';

/// Shared "you got your reward" snackbar for every rewarded-ad placement,
/// styled to match the battle-pass XP toast (the one placement that already
/// confirmed its grant). Takes a [ScaffoldMessengerState] rather than a
/// [BuildContext] because reward grants fire AFTER the ad is dismissed —
/// an async gap where reading the original context is unsafe; callers
/// capture the messenger before showing the ad.
void showRewardToast(
  ScaffoldMessengerState messenger,
  String message, {
  IconData icon = Icons.celebration,
}) {
  messenger.showSnackBar(
    arcadeSnackBarFor(
      // No BuildContext here on purpose — see the note above. ThemeCubit is a
      // get_it singleton and is already read this way from off the widget tree
      // (see PremiumCubit), so the toast can still be painted in the player's
      // theme.
      getIt<ThemeCubit>().state.currentTheme,
      message: message,
      tone: ArcadeSnackTone.success,
      icon: icon,
      duration: const Duration(seconds: 2),
    ),
  );
}
