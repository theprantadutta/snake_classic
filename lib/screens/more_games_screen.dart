import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';
import 'package:snake_classic/services/cross_promo.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:url_launcher/url_launcher.dart';

/// "More from us": the owner's other games, one card each, opened from the
/// Home menu and from Settings. Only games with a listing on this platform's
/// store are shown (see [CrossPromo.forPlatform]).
///
/// Store-policy rules live on [PromotedGame]: no rewards for installing,
/// tap-only, each platform links to its own store. Analytics: `more_games`
/// (`stage`: `shown` per card when built, `tapped`, `open_failed`).
class MoreGamesScreen extends StatelessWidget {
  const MoreGamesScreen({super.key, this.platform, this.isWeb = kIsWeb});

  /// Overrides [defaultTargetPlatform] (tests).
  final TargetPlatform? platform;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LBScaffold(
      title: l10n.moreGamesTitle,
      subtitle: l10n.moreGamesSubtitle,
      body: MoreGamesList(platform: platform, isWeb: isWeb),
    );
  }
}

/// The screen's body: one [MoreGameCard] per game live on this platform.
class MoreGamesList extends StatelessWidget {
  const MoreGamesList({super.key, this.platform, this.isWeb = kIsWeb});

  final TargetPlatform? platform;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = platform ?? defaultTargetPlatform;
    final games = CrossPromo.forPlatform(p, isWeb: isWeb);
    final g = context.lbGutter;
    final side = context.sideInset();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        g + side,
        context.lbCell * .9,
        g + side,
        context.lbCell * 1.5,
      ),
      children: [
        for (final game in games) ...[
          MoreGameCard(
            game: game,
            url: game.urlFor(p, isWeb: isWeb)!,
            description: moreGameDescription(l10n, game.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// The translated one-liner for a promoted game, or null if it has none.
String? moreGameDescription(AppLocalizations l10n, String id) => switch (id) {
  'cosmo_strike' => l10n.moreGamesCosmoStrike,
  'sunstone' => l10n.moreGamesSunstone,
  'pourfect' => l10n.moreGamesPourfect,
  'screw_out' => l10n.moreGamesScrewOut,
  'gridwell' => l10n.moreGamesGridwell,
  'jadewell' => l10n.moreGamesJadewell,
  _ => null,
};

class MoreGameCard extends StatefulWidget {
  const MoreGameCard({
    super.key,
    required this.game,
    required this.url,
    required this.description,
  });

  final PromotedGame game;
  final String url;
  final String? description;

  @override
  State<MoreGameCard> createState() => _MoreGameCardState();
}

class _MoreGameCardState extends State<MoreGameCard> {
  AnalyticsFacade? get _analytics =>
      getIt.isRegistered<AnalyticsFacade>() ? getIt<AnalyticsFacade>() : null;

  @override
  void initState() {
    super.initState();
    // A ListView builds a card when it comes near the viewport: a fair
    // "seen" count without a visibility package.
    unawaited(_analytics?.trackMoreGames(stage: 'shown', game: widget.game.id));
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
  Widget build(BuildContext context) {
    final p = context.lb;
    final icon = 60 * context.uiScale;
    return LBBlock(
      onTap: _open,
      semanticLabel: widget.game.name,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(icon * .22),
            child: Image.asset(
              widget.game.iconAsset,
              width: icon,
              height: icon,
              filterQuality: FilterQuality.medium,
              // Never let a missing asset break the screen.
              errorBuilder: (_, _, _) => SizedBox(width: icon, height: icon),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.game.name.toUpperCase(),
                  style: LBText.button(
                    p,
                    color: p.head,
                    size: 14,
                  ).copyWith(letterSpacing: 1.8),
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.description!,
                    style: LBText.body(p, size: 11).copyWith(height: 1.3),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          LBPixelIcon(LBIcon.next, cell: 2.4, color: p.lime),
        ],
      ),
    );
  }
}
