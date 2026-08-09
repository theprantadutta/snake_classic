import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/account_upgrade_sheet.dart';

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

  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showAccountUpgradeSheet(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(14 * context.uiScale),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: Colors.orange,
                size: context.scaled(22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.accountNotBackedUpTitle,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.accountNotBackedUpBody,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.orange.withValues(alpha: 0.8),
                size: context.scaled(22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
