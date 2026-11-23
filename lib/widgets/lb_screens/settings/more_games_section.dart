import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';
import 'package:snake_classic/services/cross_promo.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_rows.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings → "More games from us": one plain row per game in
/// [CrossPromo.games] that has a store link on this platform. Hidden when
/// there is none (web, desktop).
///
/// The policy rules live on [PromotedGame]: no install rewards, tap-only,
/// platform-correct store links. Analytics: `more_games` (`stage`: `shown`
/// once per Settings visit when the row is built, i.e. scrolled near;
/// `tapped`; `open_failed`), `game` = the game's id.
class MoreGamesSection extends StatelessWidget {
  const MoreGamesSection({super.key, this.platform, this.isWeb = kIsWeb});

  /// Overrides [defaultTargetPlatform] (tests).
  final TargetPlatform? platform;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final p = platform ?? defaultTargetPlatform;
    final games = CrossPromo.forPlatform(p, isWeb: isWeb);
    if (games.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return SettingsSection(
      label: l10n.settingsSectionMoreGames,
      children: [
        for (final g in games)
          _MoreGameRow(
            game: g,
            url: g.urlFor(p, isWeb: isWeb)!,
            subtitle: switch (g.id) {
              'cosmo_strike' => l10n.moreGamesCosmoStrike,
              _ => null,
            },
          ),
      ],
    );
  }
}

class _MoreGameRow extends StatefulWidget {
  const _MoreGameRow({
    required this.game,
    required this.url,
    required this.subtitle,
  });

  final PromotedGame game;
  final String url;
  final String? subtitle;

  @override
  State<_MoreGameRow> createState() => _MoreGameRowState();
}

class _MoreGameRowState extends State<_MoreGameRow> {
  AnalyticsFacade? get _analytics => getIt.isRegistered<AnalyticsFacade>()
      ? getIt<AnalyticsFacade>()
      : null;

  @override
  void initState() {
    super.initState();
    // Settings is a ListView, so this state is created when the row comes
    // near the viewport: a fair "seen" count without a visibility package.
    unawaited(
      _analytics?.trackMoreGames(stage: 'shown', game: widget.game.id),
    );
  }

  Future<void> _open() async {
    final analytics = _analytics;
    unawaited(analytics?.trackMoreGames(stage: 'tapped', game: widget.game.id));
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      unawaited(
        analytics?.trackMoreGames(stage: 'open_failed', game: widget.game.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SettingsValueRow(
    title: widget.game.name,
    subtitle: widget.subtitle,
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        widget.game.iconAsset,
        width: 28,
        height: 28,
        filterQuality: FilterQuality.medium,
        // Never let a missing asset break Settings.
        errorBuilder: (_, _, _) => const SizedBox(width: 28, height: 28),
      ),
    ),
    onTap: _open,
  );
}
