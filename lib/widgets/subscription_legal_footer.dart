import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/legal_urls.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Required disclosure block for auto-renewable subscriptions.
///
/// Apple Guideline 3.1.2(c) requires the purchase flow to disclose that the
/// subscription auto-renews and to expose **functional** links to the Privacy
/// Policy and the Terms of Use (EULA). This widget renders both so every
/// purchase surface (the dedicated Pro screen and the store's Pro tab) shows
/// identical, compliant copy.
class SubscriptionLegalFooter extends StatelessWidget {
  const SubscriptionLegalFooter({super.key, required this.theme});

  /// Kept for call-site compatibility; colours come from the Living Board
  /// palette (`context.lb`), which already follows the theme.
  final GameTheme theme;

  Future<void> _open(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.info('Could not launch legal URL: $url');
      }
    } catch (e) {
      AppLogger.info('Failed to launch legal URL $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final disclosureStyle = LBText.body(p, color: p.inkMuted, size: 11).copyWith(height: 1.4);

    // The disclosure has to name the store that actually takes the money and
    // where the user cancels — an Android buyer has no App Store account.
    // defaultTargetPlatform (not dart:io Platform) so this stays safe on web.
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isAndroid
              ? l10n.legalAutoRenewDisclosureGooglePlay
              : l10n.legalAutoRenewDisclosureAppStore,
          textAlign: TextAlign.center,
          style: disclosureStyle,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _LegalLink(
              label: l10n.settingsPrivacyPolicyTitle,
              onTap: () => _open(LegalUrls.privacyPolicy),
            ),
            Text('  ·  ', style: disclosureStyle),
            _LegalLink(
              // "(EULA)" is Apple's terminology — guideline 3.1.2(c) expects
              // the licence agreement identified as such on the purchase
              // surface. Play has no such expectation, so Android gets the
              // plain label rather than an acronym that means nothing there.
              label: isAndroid
                  ? l10n.settingsTermsTitle
                  : l10n.legalTermsEulaLink,
              onTap: () => _open(LegalUrls.termsOfUse),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        LBFeedback.tap();
        onTap();
      },
      child: Padding(
        // A finger-sized target around a small link.
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(
          label,
          style: LBText.button(p, color: p.lime, size: 11.5).copyWith(
            decoration: TextDecoration.underline,
            decorationColor: p.lime,
          ),
        ),
      ),
    );
  }
}
