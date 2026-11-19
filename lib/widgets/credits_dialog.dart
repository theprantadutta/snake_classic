import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:url_launcher/url_launcher.dart';

/// "About / Credits" dialog for Snake Classic. Reached from Settings and the
/// Home logo/menu.
///
/// [theme] is kept for callers; the dialog reads the Living Board palette
/// from the context like every other surface.
Future<void> showCreditsDialog(BuildContext context, GameTheme theme) async {
  // Capture before the await — the context is used after it.
  final l10n = AppLocalizations.of(context)!;
  final currentYear = DateTime.now().year;
  final packageInfo = await PackageInfo.fromPlatform();
  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .65),
    builder: (BuildContext dialogContext) {
      final p = dialogContext.lb;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: LBBlock(
            kind: LBBlockKind.sheet,
            padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const LBCellSMark(size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // The product name: a proper noun, not copy.
                            Semantics(
                              header: true,
                              child: const LBCellText('Snake Classic', cell: 3.2, glow: true),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.crVersionLine(packageInfo.buildNumber, packageInfo.version),
                              style: LBText.body(p, size: 10.5).copyWith(
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      LBIconBlock(
                        icon: LBIcon.x,
                        size: 44,
                        semanticLabel: l10n.commonClose,
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      l10n.crTagline,
                      style: LBText.body(p, color: p.ink.withValues(alpha: .75), size: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _FeatureChip(label: l10n.crChipModes, icon: LBIcon.grid, route: AppRoutes.runSetup),
                      _FeatureChip(label: l10n.crChipAchievements, icon: LBIcon.trophy, route: AppRoutes.achievements),
                      _FeatureChip(label: l10n.crChipDaily, icon: LBIcon.calendar, route: AppRoutes.dailyChallenges),
                      _FeatureChip(label: l10n.crChipLeaderboards, icon: LBIcon.chart, route: AppRoutes.leaderboard),
                      _FeatureChip(label: l10n.crChipCosmetics, icon: LBIcon.star, route: AppRoutes.store),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: LBBlock(
                      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                      child: Row(
                        children: [
                          LBPixelIcon(LBIcon.heart, cell: 3.2, color: p.lime),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.crCraftedBy.toUpperCase(), style: LBText.label(p)),
                                const SizedBox(height: 2),
                                Text('Pranta Dutta', style: LBText.button(p, size: 13).copyWith(letterSpacing: .6)),
                              ],
                            ),
                          ),
                          LBBlock(
                            kind: LBBlockKind.outline,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            onTap: () async {
                              final url = Uri.parse('https://pranta.dev');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('pranta.dev', style: LBText.button(p, color: p.lime, size: 11).copyWith(letterSpacing: .4)),
                                const SizedBox(width: 6),
                                LBPixelIcon(LBIcon.next, cell: 2, color: p.lime),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.crCopyright(currentYear),
                    style: LBText.body(p, color: p.inkDim, size: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// A feature pill in the About dialog. It is drawn like a button, so it acts
/// like one: closes the dialog and opens that feature's screen.
class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label, required this.icon, required this.route});

  final String label;
  final LBIcon icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: () => _open(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: LBChip(label: label, icon: icon, height: 30),
      ),
    );
  }

  void _open(BuildContext context) {
    LBFeedback.tap();
    // Grab the router before the pop: this context goes with the dialog.
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(route);
  }
}
