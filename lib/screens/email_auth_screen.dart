import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/widgets/account_switch_confirmation.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// Email/password sign-in, account-creation, and anonymous-account link
/// screen. Tab switcher between Sign In and Create Account.
///
/// When invoked with [linkFromAnonymous] = true, the action buttons call
/// the link* variants on AuthCubit instead of the standalone sign-in /
/// create methods — keeping the same Firebase UID so backend progress
/// (coins, cosmetics, scores) is preserved.
class EmailAuthScreen extends StatefulWidget {
  final bool linkFromAnonymous;

  const EmailAuthScreen({super.key, this.linkFromAnonymous = false});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _signInFormKey = GlobalKey<FormState>();
  final _createFormKey = GlobalKey<FormState>();
  final _signInEmail = TextEditingController();
  final _signInPassword = TextEditingController();
  final _createEmail = TextEditingController();
  final _createPassword = TextEditingController();
  bool _busy = false;
  bool _showSignInPassword = false;
  bool _showCreatePassword = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _signInEmail.dispose();
    _signInPassword.dispose();
    _createEmail.dispose();
    _createPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;

    return LBScaffold(
      title: widget.linkFromAnonymous ? l10n.lbEmailLinkTitle : l10n.lbEmailTitle,
      subtitle: widget.linkFromAnonymous ? l10n.eaExplainer : l10n.eaTitleSignIn,
      banner: false,
      // The form area takes whatever height is left under the tabs (no
      // fixed form height): each tab pins its action to the bottom and
      // scrolls when the keyboard or large text needs more room.
      body: Padding(
        padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LBTabBlocks(
              controller: _tabs,
              labels: [
                widget.linkFromAnonymous ? l10n.eaLinkExisting : l10n.eaSignIn,
                l10n.eaCreateAccount,
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildSignInForm(),
                  _buildCreateForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One tab's form: fields at the top, the action at the bottom of the
  /// available height; scrolls instead of overflowing when space runs out.
  Widget _formPage(List<Widget> fields, Widget action) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.only(top: 4, bottom: context.lbCell * .6),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 4 - context.lbCell * .6).clamp(0, double.infinity),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...fields,
                const Spacer(),
                const SizedBox(height: 20),
                action,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return Form(
      key: _signInFormKey,
      child: _formPage(
        [
          _emailField(_signInEmail),
          const SizedBox(height: 16),
          _passwordField(
            controller: _signInPassword,
            obscure: !_showSignInPassword,
            onToggle: () =>
                setState(() => _showSignInPassword = !_showSignInPassword),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _busy ? null : _onForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: p.lime,
                disabledForegroundColor: p.inkDim,
                minimumSize: const Size(48, 48),
              ),
              child: Text(
                l10n.eaForgotPassword,
                style: LBText.body(p, color: _busy ? p.inkDim : p.lime, size: 12).copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: p.lime.withValues(alpha: .5),
                ),
              ),
            ),
          ),
        ],
        _primaryButton(
          label: widget.linkFromAnonymous
              ? l10n.eaLinkToExisting
              : l10n.eaSignIn,
          onPressed: _busy ? null : _onSignInOrLink,
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _createFormKey,
      child: _formPage(
        [
          _emailField(_createEmail),
          const SizedBox(height: 16),
          _passwordField(
            controller: _createPassword,
            obscure: !_showCreatePassword,
            onToggle: () =>
                setState(() => _showCreatePassword = !_showCreatePassword),
            minLength: 8,
            helper: l10n.eaMinChars,
          ),
        ],
        _primaryButton(
          label: widget.linkFromAnonymous
              ? l10n.eaCreateAndLink
              : l10n.eaCreateAccount,
          onPressed: _busy ? null : _onCreateOrLink,
        ),
      ),
    );
  }

  Widget _emailField(TextEditingController controller) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      style: lbInputStyle(context),
      cursorColor: context.lb.lime,
      decoration: lbInputDecoration(context, label: l10n.eaEmail),
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) return l10n.eaEmailRequired;
        final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!re.hasMatch(s)) return l10n.eaEmailInvalid;
        return null;
      },
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    int minLength = 1,
    String? helper,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: lbInputStyle(context),
      cursorColor: context.lb.lime,
      decoration: lbInputDecoration(
        context,
        label: l10n.eaPassword,
        helperText: helper,
        suffixIcon: LBPasswordEye(
          obscured: obscure,
          onToggle: onToggle,
          showLabel: l10n.lbShowPassword,
          hideLabel: l10n.lbHidePassword,
        ),
      ),
      validator: (v) {
        final s = v ?? '';
        if (s.isEmpty) return l10n.eaPasswordRequired;
        if (s.length < minLength) return l10n.eaMinCharsN(minLength);
        return null;
      },
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return LBPrimaryBlock(
      label: label,
      busy: _busy,
      onTap: onPressed,
      height: 52,
    );
  }

  Future<void> _onSignInOrLink() async {
    if (!_signInFormKey.currentState!.validate()) return;
    final email = _signInEmail.text.trim();
    final password = _signInPassword.text;
    final cubit = context.read<AuthCubit>();
    final l10n = AppLocalizations.of(context)!;

    setState(() => _busy = true);
    // connectAccountWithEmailPassword picks link-vs-sign-in from the actual
    // session state instead of from how this screen was opened, and falls
    // back to a sign-in when the address already has an account. The
    // linkFromAnonymous flag now only drives copy and post-success routing.
    final ok = widget.linkFromAnonymous
        ? await cubit.connectAccountWithEmailPassword(
            email: email,
            password: password,
            confirmAccountSwitch: () => confirmAccountSwitch(context),
          )
        : await cubit.signInWithEmailPassword(email: email, password: password);
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      await _routeAfterSuccess(cubit);
    } else {
      _showError(_friendlyError(l10n, cubit.state.errorMessage));
    }
  }

  Future<void> _onCreateOrLink() async {
    if (!_createFormKey.currentState!.validate()) return;
    final email = _createEmail.text.trim();
    final password = _createPassword.text;
    final cubit = context.read<AuthCubit>();
    final l10n = AppLocalizations.of(context)!;

    setState(() => _busy = true);
    final ok = widget.linkFromAnonymous
        ? await cubit.connectAccountCreateWithEmailPassword(
            email: email,
            password: password,
          )
        : await cubit.createAccountWithEmailPassword(
            email: email,
            password: password,
          );
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      await _routeAfterSuccess(cubit);
    } else {
      _showError(_friendlyError(l10n, cubit.state.errorMessage));
    }
  }

  Future<void> _onForgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _signInEmail.text.trim();
    if (email.isEmpty) {
      _showError(l10n.eaForgotFirst);
      return;
    }
    final cubit = context.read<AuthCubit>();
    setState(() => _busy = true);
    final ok = await cubit.sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      _showInfo(l10n.eaResetSent(email));
    } else {
      _showError(_friendlyError(l10n, cubit.state.errorMessage));
    }
  }

  Future<void> _routeAfterSuccess(AuthCubit cubit) async {
    if (widget.linkFromAnonymous) {
      // Link path keeps the existing user and username intact — pop back
      // to whichever screen triggered the upgrade (typically the store).
      if (mounted) context.pop();
      return;
    }

    await cubit.markFirstTimeSetupComplete();
    if (!mounted) return;

    final existingUsername = cubit.state.user?.username.trim() ?? '';
    final showSetup =
        cubit.state.needsUsernameSetup && existingUsername.isEmpty;
    context.go(showSetup ? AppRoutes.usernameSetup : AppRoutes.home);
  }

  // Maps Firebase Auth error codes to user-facing strings. Anything we don't
  // recognise falls through with the raw code so we still surface something.
  String _friendlyError(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'invalid-email':
        return l10n.eaErrInvalidEmail;
      case 'user-disabled':
        return l10n.eaErrDisabled;
      case 'user-not-found':
        return l10n.eaErrNoAccount;
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.eaErrWrongCreds;
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return l10n.eaErrEmailInUse;
      case 'weak-password':
        return l10n.eaErrWeakPassword;
      case 'operation-not-allowed':
        return l10n.eaErrNotEnabled;
      case 'too-many-requests':
        return l10n.eaErrTooMany;
      case 'network-request-failed':
        return l10n.eaErrNetwork;
      case 'provider-already-linked':
        return l10n.eaErrAlreadyLinked;
      case 'requires-recent-login':
        return l10n.eaErrRecentLogin;
      case null:
      case '':
      default:
        // Unknown codes used to render raw ("sign-in failed", a Firebase
        // slug, or exception text) — always show the localized generic.
        return l10n.eaErrGeneric;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(context, message: message, tone: ArcadeSnackTone.error),
    );
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(context, message: message, tone: ArcadeSnackTone.success),
    );
  }
}
