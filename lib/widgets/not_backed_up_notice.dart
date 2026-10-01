import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/account_upgrade_sheet.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Tells a player without a real account that their save lives on this phone
/// and nowhere else.
///
/// Under play-first onboarding nobody is asked to sign in, and the identity
/// they end up with — an offline guest, or the Firebase anonymous account the
/// FCM bootstrap silently creates for them — renders everywhere as a normal
/// signed-in user. So the app looked like it was backing progress up when it
/// was not, and the first time anyone found out was a reinstall.
///
/// Deliberately NOT shown on Home: the whole point of play-first is that the
/// route to the board is clear, and a warning banner over the play button is
/// exactly the friction that onboarding change removed. It belongs on the two
/// screens a player opens when they're actually thinking about their account.
///
/// Tapping opens the shared upgrade sheet, so the warning and the fix are one
/// gesture apart.
class NotBackedUpNotice extends StatelessWidget {
  const NotBackedUpNotice({super.key, required this.theme});

  /// Kept for the call sites; colours now come from the Living Board palette.
  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Red = danger on the board: this save can be lost. The title states it
    // in words too, so the colour is never the only signal.
    return LBRow(
      kind: LBBlockKind.danger,
      onTap: () => showAccountUpgradeSheet(context),
      leading: const LBPixelIcon(LBIcon.shield, cell: 3.6, color: LB.bonk),
      title: l10n.accountNotBackedUpTitle,
      subtitle: l10n.accountNotBackedUpBody,
      trailing: LBPixelIcon(LBIcon.next, cell: 2.6, color: LB.bonk.withValues(alpha: .8)),
    );
  }
}
