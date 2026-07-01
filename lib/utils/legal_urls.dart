/// Canonical links to the app's legal documents.
///
/// Apple Guideline 3.1.2(c) requires that the auto-renewable subscription
/// purchase flow surfaces **functional** links to both the Privacy Policy and
/// the Terms of Use (EULA). These are the single source of truth for those
/// URLs across every purchase surface (see [SubscriptionLegalFooter]).
class LegalUrls {
  LegalUrls._();

  /// Hosted privacy policy (also mirrored in the bundled `PRIVACY.md`).
  static const String privacyPolicy =
      'https://legal.pranta.dev/privacy?projectName=snake_classic';

  /// Hosted Terms of Use / EULA. This same URL must also be pasted into the
  /// App Store Connect "EULA" field (custom EULA) so the metadata matches.
  static const String termsOfUse =
      'https://legal.pranta.dev/terms?projectName=snake_classic';
}
