import 'package:shared_preferences/shared_preferences.dart';

/// Centralized legal-document version + acceptance tracking.
///
/// A SINGLE shared version ([currentLegalVersion]) covers BOTH the Privacy
/// Policy (`assets/legal/PRIVACY.md`) and the Terms of Use
/// (`assets/legal/TERMS.md`). Whenever EITHER document materially changes,
/// bump this constant AND the matching `**Legal Version:**` header in both
/// markdown files — keep all three in lockstep. On a bump, every user (new and
/// existing) is asked to review and re-accept: acceptance counts as current
/// only when the stored version exactly matches [currentLegalVersion].
class LegalAcceptance {
  LegalAcceptance._();

  /// Current unified legal version. Bump on every material change to EITHER
  /// PRIVACY.md or TERMS.md, and update the `**Legal Version:**` header in both
  /// files to match.
  static const String currentLegalVersion = '3.0';

  /// Stores the legal version the user last accepted.
  static const String _versionKey = 'legal_accepted_version';

  /// Legacy privacy-only keys (pre-unification). Recognized only so we don't
  /// break older installs; they are deliberately NOT grandfathered — the move
  /// to unified Privacy Policy + Terms of Use is material, so those users
  /// re-accept once.
  static const String _legacyVersionKey = 'privacy_policy_accepted_version';
  static const String _legacyBoolKey = 'privacy_policy_accepted';

  /// True only when the user has accepted the *current* legal version.
  static Future<bool> isCurrentVersionAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_versionKey) == currentLegalVersion;
    } catch (_) {
      // If prefs can't be read, fail safe by treating it as not accepted so
      // the user is shown the documents.
      return false;
    }
  }

  /// Record acceptance of the current legal version (Privacy Policy + Terms).
  static Future<void> recordAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_versionKey, currentLegalVersion);
      // Keep legacy keys set too, for any older code path still reading them.
      await prefs.setString(_legacyVersionKey, currentLegalVersion);
      await prefs.setBool(_legacyBoolKey, true);
    } catch (_) {
      // Non-critical — acceptance will simply be re-requested next launch.
    }
  }
}
