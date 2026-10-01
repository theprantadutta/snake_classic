import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// Re-consent gate shown to EXISTING (already-onboarded) users when the shared
/// legal version has changed since they last accepted it — i.e. whenever the
/// Privacy Policy OR the Terms of Use is updated. New users accept both inside
/// [FirstTimeAuthScreen]; this screen handles the "documents updated, please
/// review again" case for returning users and then sends them home. Back
/// navigation is blocked so acceptance can't be skipped.
class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  String _privacy = '';
  String _terms = '';
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    _privacy = await _load('assets/legal/PRIVACY.md',
        'We have updated our Privacy Policy. By continuing you accept the '
        'updated policy.');
    _terms = await _load('assets/legal/TERMS.md',
        'We have updated our Terms of Use. By continuing you accept the '
        'updated terms.');
    if (mounted) setState(() {});
  }

  Future<String> _load(String assetPath, String fallback) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _accept() async {
    await LegalAcceptance.recordAccepted();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;

    return PopScope(
      // Block back-out — the user must accept the updated policy to proceed.
      canPop: false,
      child: LBScaffold(
        title: l10n.lbConsentTitle,
        subtitle: l10n.pcVersionLine(LegalAcceptance.currentLegalVersion),
        // No back block: acceptance can't be skipped.
        showBack: false,
        banner: false,
        body: Padding(
          padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, 0),
          // Privacy Policy + Terms of Use — swipeable tabs.
          child: LBLegalTabs(
            privacyLabel: l10n.pcTabPrivacy,
            termsLabel: l10n.pcTabTerms,
            privacy: _privacy,
            terms: _terms,
            loading: _privacy.isEmpty && _terms.isEmpty,
          ),
        ),
        bottom: Padding(
          padding: EdgeInsets.fromLTRB(g, 4, g, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Acceptance checkbox
              LBCheckBlock(
                value: _accepted,
                label: l10n.pcAgree,
                onChanged: (v) => setState(() => _accepted = v),
              ),
              const SizedBox(height: 6),
              // Continue button
              LBPrimaryBlock(
                label: l10n.pcContinue,
                icon: LBIcon.check,
                onTap: _accepted ? _accept : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
