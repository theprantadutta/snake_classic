import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final g = context.lbGutter;

    return Scaffold(
      body: LBGridBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: g, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: LBPixelIcon(LBIcon.target, cell: 9 * context.uiScale, color: p.lime)),
                    const SizedBox(height: 22),
                    Center(
                      child: Semantics(
                        header: true,
                        child: LBCellText(l10n.lbRouteErrorTitle, cell: 5 * context.uiScale, glow: true),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.lbRouteErrorBody,
                      textAlign: TextAlign.center,
                      style: LBText.body(p, color: p.ink.withValues(alpha: .75), size: 13),
                    ),
                    if (kDebugMode && error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                        style: LBText.body(p, color: p.inkDim, size: 10.5),
                      ),
                    ],
                    SizedBox(height: context.lbCell * 1.5),
                    LBBlock(
                      kind: LBBlockKind.fill,
                      height: context.lbCell * 3,
                      alignment: Alignment.center,
                      semanticLabel: l10n.lbRouteErrorHome,
                      // go(), not push(): the stack that got us here is the
                      // broken one, so replace it rather than sit on top.
                      onTap: () => context.go(AppRoutes.home),
                      child: Text(
                        l10n.lbRouteErrorHome,
                        style: LBText.button(p, color: p.onLime, size: 15).copyWith(letterSpacing: 3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
