import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/game_button.dart';

/// Shown when the router is handed a location that matches no route.
///
/// go_router has its own fallback for this, but which one you get depends on
/// its app-type detection — and since 18.0 that looks for material_ui's
/// MaterialApp, which this app does not use. The miss lands us on the bare
/// WidgetsApp `ErrorScreen`: unstyled grey, a raw exception string, no way
/// back. Supplying `errorBuilder` takes that decision away from the
/// dependency and keeps a dead link looking like part of the game.
///
/// Reachable in practice from a malformed deep link or a push payload naming
/// a route this build does not have — an older client can be sent a link to a
/// screen that only exists in a newer one.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, this.error});

  /// The router's own description of what went wrong. Shown only in debug —
  /// a player has no use for a GoException, and it would be the only
  /// untranslated string on the screen.
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state.currentTheme;

    return Scaffold(
      body: AppBackground(
        theme: theme,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wrong_location_rounded,
                    size: 56,
                    color: theme.accentColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'LOST THE TRAIL',
                    textAlign: TextAlign.center,
                    style: GameTypography.headlineMedium(
                      color: theme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'That screen does not exist in this version of the game.',
                    textAlign: TextAlign.center,
                    style: GameTypography.bodyMedium(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (kDebugMode && error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: GameTypography.bodySmall(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  GameButton(
                    text: 'BACK TO HOME',
                    theme: theme,
                    icon: Icons.home_rounded,
                    // go(), not push(): the stack that got us here is the
                    // broken one, so replace it rather than sit on top of it.
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
