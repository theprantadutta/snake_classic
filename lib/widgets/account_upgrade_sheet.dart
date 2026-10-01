import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/widgets/account_switch_confirmation.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// Bottom sheet shown when an anonymous (guest) user tries to make a
/// purchase. Offers two ways to upgrade the account in place — keeping
/// the same Firebase UID so existing game progress, coins, and cosmetics
/// stay attached.
///
/// Returns `true` from [showAccountUpgradeSheet] if the user successfully
/// linked an account (caller should re-check `isAnonymous` and proceed),
/// `false` if they dismissed or cancelled.
Future<bool> showAccountUpgradeSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showLBSheet<bool>(
    context: context,
    title: l10n.auTitle,
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
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.auBody,
            style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12.5),
          ),
          const SizedBox(height: 18),
          // Guideline 4.8: wherever a third-party login is offered on
          // an Apple platform, Sign in with Apple rides along — and the
          // HIG asks for equal-or-greater prominence, so it leads.
          //
          // This sheet was the one surface that still offered Google
          // alone. The sign-in screen and the profile screen already
          // paired them; the purchase-upgrade path did not, and it is
          // the path App Review walked.
          if (_isApplePlatform)
            _UpgradeOption(
              leading: const FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 22),
              title: l10n.auApple,
              subtitle: l10n.auAppleSub,
              // Apple's own colours (white on dark) rather than the lime.
              accent: Colors.white,
              titleColor: Colors.white,
              busy: _busy,
              onPressed: () => _connect(
                (cubit, confirm) =>
                    cubit.connectAccountWithApple(confirmAccountSwitch: confirm),
              ),
            ),
          _UpgradeOption(
            leading: FaIcon(FontAwesomeIcons.google, color: p.head, size: 20),
            title: l10n.auGoogle,
            subtitle: l10n.auGoogleSub,
            busy: _busy,
            onPressed: () => _connect(
              (cubit, confirm) =>
                  cubit.connectAccountWithGoogle(confirmAccountSwitch: confirm),
            ),
          ),
          _UpgradeOption(
            leading: LBPixelIcon(LBIcon.lock, cell: 3.6, color: p.head),
            title: l10n.auEmail,
            subtitle: l10n.auEmailSub,
            busy: _busy,
            onPressed: () {
              Navigator.of(context).pop(false);
              context.push('${AppRoutes.emailAuth}?link=1');
            },
          ),
          const SizedBox(height: 8),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: LBBusyCells()),
            )
          else
            LBBlock(
              kind: LBBlockKind.muted,
              height: 48,
              alignment: Alignment.center,
              onTap: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.auNotNow.toUpperCase(),
                style: LBText.button(p, color: p.inkMuted, size: 12),
              ),
            ),
        ],
      ),
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
  final Widget leading;
  final String title;
  final String subtitle;
  final Color? accent;
  final Color? titleColor;
  final bool busy;
  final VoidCallback onPressed;

  const _UpgradeOption({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.accent,
    this.titleColor,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = titleColor ?? p.head;
    // While a connect call is running every option is inert (the old
    // InkWell took a null handler); muted makes that visible.
    return LBBlock(
      kind: busy ? LBBlockKind.muted : LBBlockKind.outline,
      accent: busy ? null : accent,
      onTap: busy ? null : onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 26, child: Center(child: leading)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: busy ? p.inkDim : fg, size: 12.5),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: LBText.body(p, size: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          LBPixelIcon(LBIcon.next, cell: 2.6, color: (busy ? p.inkDim : fg).withValues(alpha: .7)),
        ],
      ),
    );
  }
}
