import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';
import 'package:snake_classic/services/cross_promo.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_rows.dart';

/// Settings → "More games from us": one row that opens the More games
/// screen. Hidden when no game has a store link on this platform (web,
/// desktop).
class MoreGamesSection extends StatelessWidget {
  const MoreGamesSection({super.key, this.platform, this.isWeb = kIsWeb});

  /// Overrides [defaultTargetPlatform] (tests).
  final TargetPlatform? platform;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final games = CrossPromo.forPlatform(
      platform ?? defaultTargetPlatform,
      isWeb: isWeb,
    );
    if (games.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return SettingsSection(
      label: l10n.settingsSectionMoreGames,
      children: [
        SettingsValueRow(
          title: l10n.moreGamesTitle,
          subtitle: games.map((g) => g.name).join(', '),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              games.first.iconAsset,
              width: 28,
              height: 28,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => const SizedBox(width: 28, height: 28),
            ),
          ),
          onTap: () => openMoreGames(context, source: 'settings'),
        ),
      ],
    );
  }
}

/// Opens the More games screen and logs where from (`menu` / `settings`).
void openMoreGames(BuildContext context, {required String source}) {
  if (getIt.isRegistered<AnalyticsFacade>()) {
    unawaited(
      getIt<AnalyticsFacade>().trackMoreGames(stage: 'opened', source: source),
    );
  }
  context.push(AppRoutes.moreGames);
}
