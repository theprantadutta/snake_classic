import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/legal_urls.dart';
import 'package:snake_classic/utils/logger.dart';

/// Required disclosure block for auto-renewable subscriptions.
///
/// Apple Guideline 3.1.2(c) requires the purchase flow to disclose that the
/// subscription auto-renews and to expose **functional** links to the Privacy
/// Policy and the Terms of Use (EULA). This widget renders both so every
/// purchase surface (the dedicated Pro screen and the store's Pro tab) shows
/// identical, compliant copy.
class SubscriptionLegalFooter extends StatelessWidget {
  const SubscriptionLegalFooter({super.key, required this.theme});

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
    final mutedColor = theme.accentColor.withValues(alpha: 0.6);
    final disclosureStyle = TextStyle(color: mutedColor, fontSize: 11, height: 1.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Payment is charged to your App Store account at confirmation of '
          'purchase. The subscription automatically renews for the same price '
          'and duration unless it is cancelled at least 24 hours before the end '
          'of the current period. Manage or cancel anytime in your account '
          'settings after purchase.',
          textAlign: TextAlign.center,
          style: disclosureStyle,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _LegalLink(
              label: 'Privacy Policy',
              color: theme.accentColor,
              onTap: () => _open(LegalUrls.privacyPolicy),
            ),
            Text('  •  ', style: TextStyle(color: mutedColor, fontSize: 11)),
            _LegalLink(
              label: 'Terms of Use (EULA)',
              color: theme.accentColor,
              onTap: () => _open(LegalUrls.termsOfUse),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}
