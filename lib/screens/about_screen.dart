import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/screens/legal_document_screen.dart';
import 'package:snake_classic/services/cross_promo.dart';
import 'package:snake_classic/services/review_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_rows.dart';
import 'package:url_launcher/url_launcher.dart';

/// About: a full screen for the game and the person who makes it (owner,
/// Nov 2026: "a whole screen, dedicated to the game and me", replacing the
/// old credits dialog). Reached from the Home menu, the Home logo and
/// Settings → About.
///
/// Sections: the mark and tagline, what the game is, what's inside (each
/// chip opens that feature), the player's own story so far, the developer,
/// thanks, legal, and the version line.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, this.statistics, this.version});

  /// Overrides for tests: the player's stats and "version (build)".
  final GameStatistics? statistics;
  final (String, String)? version;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  (String, String)? _version;

  static final Uri _website = Uri.parse('https://pranta.dev');
  static final Uri _support = Uri.parse(
    'https://snakeclassic.pranta.dev/support',
  );

  @override
  void initState() {
    super.initState();
    _version = widget.version;
    if (_version == null) {
      PackageInfo.fromPlatform().then((info) {
        if (mounted) setState(() => _version = (info.version, info.buildNumber));
      }).catchError((_) {});
    }
  }

  GameStatistics get _stats =>
      widget.statistics ?? StatisticsService().statistics;

  Future<void> _open(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openLegal(String title, String asset, IconData icon, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: title,
          assetPath: asset,
          icon: icon,
          fallbackUrl: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LBScaffold(
      title: l10n.abTitle,
      subtitle: l10n.abSubtitle,
      children: [
        _hero(l10n),
        SettingsSection(label: l10n.abTheGame, children: [_story(l10n)]),
        SettingsSection(label: l10n.abInside, children: [_features(l10n)]),
        SettingsSection(label: l10n.abYourStory, children: [_yourStory(l10n)]),
        SettingsSection(label: l10n.abMadeBy, children: _maker(l10n)),
        SettingsSection(label: l10n.abThanks, children: [_thanks(l10n)]),
        SettingsSection(label: l10n.settingsSectionLegal, children: _legal(l10n)),
        _footer(l10n),
      ],
    );
  }

  Widget _hero(AppLocalizations l10n) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Column(
        children: [
          const LBCellSMark(size: 96),
          const SizedBox(height: 16),
          // The product name: a proper noun, not copy.
          Semantics(
            header: true,
            child: const LBCellText('Snake Classic', cell: 4.2, glow: true),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.crTagline,
            textAlign: TextAlign.center,
            style: LBText.body(p, size: 13, color: p.ink.withValues(alpha: .8)),
          ),
          if (_version != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.crVersionLine(_version!.$2, _version!.$1),
              style: LBText.body(p, size: 10.5, color: p.inkDim).copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _story(AppLocalizations l10n) {
    final p = context.lb;
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Text(l10n.abGameStory, style: LBText.body(p, size: 12.5)),
    );
  }

  Widget _features(AppLocalizations l10n) {
    Widget chip(String label, LBIcon icon, String route) => _FeatureChip(
      label: label,
      icon: icon,
      onTap: () => context.push(route),
    );
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        chip(l10n.crChipModes, LBIcon.grid, AppRoutes.runSetup),
        chip(l10n.crChipDaily, LBIcon.calendar, AppRoutes.dailyChallenges),
        chip(l10n.crChipAchievements, LBIcon.trophy, AppRoutes.achievements),
        chip(l10n.crChipLeaderboards, LBIcon.chart, AppRoutes.leaderboard),
        chip(l10n.crChipCosmetics, LBIcon.star, AppRoutes.store),
        chip(l10n.crChipHowToPlay, LBIcon.next, AppRoutes.instructions),
      ],
    );
  }

  Widget _yourStory(AppLocalizations l10n) {
    final p = context.lb;
    final s = _stats;
    if (s.totalGamesPlayed == 0) {
      return LBBlock(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.abNoGamesYet, style: LBText.body(p, size: 12.5)),
      );
    }
    final hours = s.totalGameTime ~/ 3600;
    final minutes = (s.totalGameTime % 3600) ~/ 60;
    final time = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    final since = s.firstPlayedDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _Stat(value: '${s.totalGamesPlayed}', label: l10n.abStatGames),
            const SizedBox(width: 6),
            _Stat(value: '${s.highScore}', label: l10n.abStatBest, gold: true),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _Stat(value: '${s.totalFoodConsumed}', label: l10n.abStatFood),
            const SizedBox(width: 6),
            _Stat(value: time, label: l10n.abStatTime),
          ],
        ),
        if (since != null) ...[
          const SizedBox(height: 10),
          Text(
            l10n.abPlayingSince(
              MaterialLocalizations.of(context).formatMediumDate(since),
            ),
            textAlign: TextAlign.center,
            style: LBText.body(p, size: 11, color: p.inkMuted),
          ),
        ],
      ],
    );
  }

  List<Widget> _maker(AppLocalizations l10n) {
    final p = context.lb;
    final hasMoreGames = CrossPromo.forPlatform(defaultTargetPlatform).isNotEmpty;
    return [
      LBBlock(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LBPixelIcon(LBIcon.heart, cell: 4, color: p.lime),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A person's name: not translated.
                      Text(
                        'Pranta Dutta',
                        style: LBText.button(p, size: 15).copyWith(letterSpacing: .6),
                      ),
                      const SizedBox(height: 2),
                      Text(l10n.abDevRole, style: LBText.label(p)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.abDevNote, style: LBText.body(p, size: 12.5)),
          ],
        ),
      ),
      const SizedBox(height: 6),
      SettingsValueRow(
        title: l10n.abWebsite,
        value: 'pranta.dev',
        leading: const LBPixelIcon(LBIcon.next, cell: 3.4),
        onTap: () => _open(_website),
      ),
      SettingsValueRow(
        title: l10n.abFeedback,
        subtitle: l10n.abFeedbackSub,
        leading: const LBPixelIcon(LBIcon.copy, cell: 3.4),
        onTap: () => _open(_support),
      ),
      SettingsValueRow(
        title: l10n.settingsRateApp,
        leading: const LBPixelIcon(LBIcon.star, cell: 3.4),
        onTap: () => getIt<ReviewService>().openStoreListing(),
      ),
      if (hasMoreGames)
        SettingsValueRow(
          title: l10n.moreGamesTitle,
          subtitle: l10n.moreGamesMenuSub,
          leading: const LBPixelIcon(LBIcon.play, cell: 3.4),
          onTap: () => context.push(AppRoutes.moreGames),
        ),
    ];
  }

  Widget _thanks(AppLocalizations l10n) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.gold,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Text(l10n.abThanksBody, style: LBText.body(p, size: 12.5)),
    );
  }

  List<Widget> _legal(AppLocalizations l10n) => [
    SettingsValueRow(
      title: l10n.settingsPrivacyPolicyButton,
      leading: const LBPixelIcon(LBIcon.shield, cell: 3.4),
      onTap: () => _openLegal(
        l10n.settingsPrivacyPolicyTitle,
        'assets/legal/PRIVACY.md',
        Icons.privacy_tip_outlined,
        'https://legal.pranta.dev/privacy?projectName=snake_classic',
      ),
    ),
    SettingsValueRow(
      title: l10n.settingsTermsButton,
      leading: const LBPixelIcon(LBIcon.copy, cell: 3.4),
      onTap: () => _openLegal(
        l10n.settingsTermsTitle,
        'assets/legal/TERMS.md',
        Icons.description_outlined,
        'https://legal.pranta.dev/terms?projectName=snake_classic',
      ),
    ),
    SettingsValueRow(
      title: l10n.abLicenses,
      leading: const LBPixelIcon(LBIcon.grid, cell: 3.4),
      onTap: () => showLicensePage(
        context: context,
        applicationName: 'Snake Classic',
        applicationVersion: _version?.$1,
      ),
    ),
  ];

  Widget _footer(AppLocalizations l10n) {
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
      child: Text(
        l10n.crCopyright(DateTime.now().year),
        textAlign: TextAlign.center,
        style: LBText.body(p, color: p.inkDim, size: 10),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.gold = false});

  final String value;
  final String label;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Expanded(
      child: LBBlock(
        kind: gold ? LBBlockKind.gold : LBBlockKind.outline,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: LBText.button(
                  p,
                  size: 22,
                  color: gold ? LB.gold : p.head,
                ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(height: 2),
            Text(label.toUpperCase(), style: LBText.label(p)),
          ],
        ),
      ),
    );
  }
}

/// A feature pill: drawn like a button, so it opens that feature's screen.
class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final LBIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          LBFeedback.tap();
          onTap();
        },
        child: LBChip(label: label, icon: icon, height: 36),
      ),
    );
  }
}
