import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Confirm before signing into an account that is not this device's identity.
///
/// Signing into an EXISTING account is a switch, not a migration: the cloud
/// progress on that account wins and this device's guest coins, scores and
/// stats stay behind. That is the deliberate ownership rule (progress belongs
/// to the identity that produced it, so unverified guest-side earnings cannot
/// inflate a real account) — but it is only defensible if the player is told
/// first and can back out.
///
/// Returns true if the player chose to continue.
///
/// **Defaults to cancel.** Cancel is the safe answer: it costs a tap, whereas
/// the other answer can cost a week of play. It is placed as the primary
/// action and is what dismissing the dialog returns.
///
/// Skipped entirely when there is nothing to lose. A guest who has not scored
/// yet loses nothing by signing in, and a dialog there would be pure friction
/// on the exact conversion step play-first onboarding exists to protect.
Future<bool> confirmAccountSwitch(BuildContext context) async {
  var hasProgressAtStake = true;
  try {
    hasProgressAtStake = await StorageService().getHighScore() > 0;
  } catch (e) {
    // Can't tell — warn rather than risk a silent loss.
    AppLogger.error('confirmAccountSwitch: could not read local progress', e);
  }

  if (!hasProgressAtStake) return true;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context)!;

  // showDialog (inside showLBDialog) pushes onto the ROOT navigator, so the
  // answers pop that one — the caller may be a sheet on a nested navigator.
  final navigator = Navigator.of(context, rootNavigator: true);
  final proceed = await showLBDialog<bool>(
    context: context,
    title: l10n.accountSwitchTitle,
    body: l10n.accountSwitchBody,
    // Cancel first and styled as the primary action — the destructive
    // choice should not be the one the thumb lands on.
    primaryLabel: l10n.commonCancel,
    onPrimary: () => navigator.pop(false),
    secondaryLabel: l10n.accountSwitchConfirm,
    onSecondary: () => navigator.pop(true),
    // Must be an explicit choice: tapping outside is not consent to losing
    // progress.
    barrierDismissible: false,
  );

  // A null result means the dialog went away without an answer. Treat that as
  // cancel, never as consent.
  return proceed ?? false;
}
