import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/widgets/account_switch_confirmation.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';

/// Bottom sheet shown when an anonymous (guest) user tries to make a
/// purchase. Offers two ways to upgrade the account in place — keeping
/// the same Firebase UID so existing game progress, coins, and cosmetics
/// stay attached.
///
/// Returns `true` from [showAccountUpgradeSheet] if the user successfully
/// linked an account (caller should re-check `isAnonymous` and proceed),
/// `false` if they dismissed or cancelled.
Future<bool> showAccountUpgradeSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AccountUpgradeSheet(),
  );
  return result ?? false;
}

class _AccountUpgradeSheet extends StatefulWidget {
  const _AccountUpgradeSheet();

  @override
  State<_AccountUpgradeSheet> createState() => _AccountUpgradeSheetState();
}

class _AccountUpgradeSheetState extends State<_AccountUpgradeSheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeCubit>().state.currentTheme;
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1F),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      color: theme.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.auTitle,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.auBody,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Guideline 4.8: wherever a third-party login is offered on
              // an Apple platform, Sign in with Apple rides along — and the
              // HIG asks for equal-or-greater prominence, so it leads.
              //
              // This sheet was the one surface that still offered Google
              // alone. The sign-in screen and the profile screen already
              // paired them; the purchase-upgrade path did not, and it is
              // the path App Review walked.
              if (_isApplePlatform) ...[
                _UpgradeOption(
                  icon: Icons.apple,
                  title: l10n.auApple,
                  subtitle: l10n.auAppleSub,
                  color: Colors.black,
                  busy: _busy,
                  onPressed: () => _connect(
                    (cubit, confirm) =>
                        cubit.connectAccountWithApple(confirmAccountSwitch: confirm),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _UpgradeOption(
                icon: Icons.g_mobiledata_outlined,
                title: l10n.auGoogle,
                subtitle: l10n.auGoogleSub,
                color: Colors.red.shade700,
                busy: _busy,
                onPressed: () => _connect(
                  (cubit, confirm) =>
                      cubit.connectAccountWithGoogle(confirmAccountSwitch: confirm),
                ),
              ),
              const SizedBox(height: 12),
              _UpgradeOption(
                icon: Icons.email_outlined,
                title: l10n.auEmail,
                subtitle: l10n.auEmailSub,
                color: theme.accentColor,
                busy: _busy,
                onPressed: () {
                  Navigator.of(context).pop(false);
                  context.push('${AppRoutes.emailAuth}?link=1');
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.auNotNow,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Run one provider's connect call and report the outcome.
  ///
  /// Shared by both providers rather than duplicated per button: the part
  /// that differs is one method call, and everything around it — capturing
  /// context handles before the await, the busy flag, pop-on-success, the
  /// error mapping — is the part that is easy to get subtly wrong twice.
  Future<void> _connect(
    Future<bool> Function(AuthCubit, Future<bool> Function()) connect,
  ) async {
    // Captured before the await so the sheet can be dismissed and feedback
    // shown safely afterwards.
    final cubit = context.read<AuthCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final snackTheme = context.read<ThemeCubit>().state.currentTheme;

    setState(() => _busy = true);
    // Branches to link-vs-sign-in internally. Offline guests have no
    // Firebase user to link against and used to fail here with a bare
    // "link failed".
    final ok = await connect(cubit, () => confirmAccountSwitch(context));
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      navigator.pop(true);
      messenger.showSnackBar(
        arcadeSnackBarFor(
          snackTheme,
          message: l10n.auLinked,
          tone: ArcadeSnackTone.success,
        ),
      );
      return;
    }

    final code = cubit.state.errorMessage ?? '';
    if (code.isNotEmpty && code != 'link failed') {
      messenger.showSnackBar(
        arcadeSnackBarFor(
          snackTheme,
          message: _linkError(l10n, code),
          tone: ArcadeSnackTone.error,
        ),
      );
    }
  }

  String _linkError(AppLocalizations l10n, String code) {
    switch (code) {
      case 'credential-already-in-use':
      case 'email-already-in-use':
        return l10n.auErrCredentialInUse;
      case 'provider-already-linked':
        return l10n.auErrAlreadyLinked;
      case 'requires-recent-login':
        return l10n.auErrRequiresRecentLogin;
      case 'network-request-failed':
        return l10n.auErrNetwork;
      default:
        return l10n.auErrGeneric;
    }
  }
}

class _UpgradeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool busy;
  final VoidCallback onPressed;

  const _UpgradeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
