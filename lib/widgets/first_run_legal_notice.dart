import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/screens/legal_document_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';

/// Slim, non-blocking "by playing you agree" strip shown on Home until the
/// player has accepted the current legal version.
///
/// Replaces the full-screen Privacy Policy + Terms markdown reader that used
/// to be the FIRST thing a brand-new install saw — a tabbed document viewer
/// with a mandatory checkbox and a "Continue to Sign In" button, standing
/// between the user and any gameplay. ~23% of installs never made it past that
/// screen and the auth wall behind it (see RETENTION_PLAN.md).
///
/// Play Store policy requires a privacy policy that is linked in the store
/// listing and reachable from inside the app — it does not require a blocking
/// in-app consent gate. Both documents remain fully readable at any time from
/// Settings; this strip carries the notice and the links, and acceptance is
/// recorded by [LegalAcceptance.recordAccepted] on the player's first
/// affirmative act (tapping Play), which is the standard notice-and-continue
/// pattern.
///
/// Renders nothing once acceptance is on file, so it costs veterans a single
/// prefs read and zero pixels. A legal-version bump in [LegalAcceptance]
/// brings it back for everyone — existing users additionally still get the
/// full-screen re-consent flow via LoadingScreen's returning-user branch,
/// because a material change to terms someone already agreed to warrants more
/// than a footer.
class FirstRunLegalNotice extends StatefulWidget {
  const FirstRunLegalNotice({super.key, required this.theme});

  final GameTheme theme;

  @override
  State<FirstRunLegalNotice> createState() => _FirstRunLegalNoticeState();
}

class _FirstRunLegalNoticeState extends State<FirstRunLegalNotice> {
  /// null while the prefs read is in flight. Rendering nothing until the
  /// answer is known avoids a flash of the strip for users who have already
  /// accepted — far more common than the first-run case this exists for.
  bool? _accepted;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final accepted = await LegalAcceptance.isCurrentVersionAccepted();
    if (mounted) setState(() => _accepted = accepted);
  }

  /// Same MaterialPageRoute push the Settings screen uses for these documents —
  /// they are deliberately NOT GoRouter routes, so this mirrors the existing
  /// call site rather than inventing a second way to open the same screen.
  void _openDoc({
    required String title,
    required String assetPath,
    required IconData icon,
    required String fallbackUrl,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: title,
          assetPath: assetPath,
          icon: icon,
          fallbackUrl: fallbackUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted != false) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = widget.theme;

    final bodyStyle = TextStyle(
      fontSize: 11,
      height: 1.35,
      color: theme.accentColor.withValues(alpha: 0.7),
    );
    final linkStyle = bodyStyle.copyWith(
      color: theme.accentColor,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: theme.accentColor.withValues(alpha: 0.6),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      color: theme.backgroundColor.withValues(alpha: 0.55),
      child: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            TextSpan(text: l10n.legalNoticePrefix),
            TextSpan(
              text: l10n.settingsTermsTitle,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openDoc(
                      title: l10n.settingsTermsTitle,
                      assetPath: 'assets/legal/TERMS.md',
                      icon: Icons.gavel_outlined,
                      fallbackUrl:
                          'https://legal.pranta.dev/terms?projectName=snake_classic',
                    ),
            ),
            TextSpan(text: l10n.legalNoticeAnd),
            TextSpan(
              text: l10n.settingsPrivacyPolicyTitle,
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openDoc(
                      title: l10n.settingsPrivacyPolicyTitle,
                      assetPath: 'assets/legal/PRIVACY.md',
                      icon: Icons.privacy_tip_outlined,
                      fallbackUrl:
                          'https://legal.pranta.dev/privacy?projectName=snake_classic',
                    ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
