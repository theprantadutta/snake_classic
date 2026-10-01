import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/username_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// First-time username confirmation screen.
///
/// Shown immediately after a brand-new backend account is created (the
/// `IsNewUser` flag from the AuthResponse). Pre-fills the input with the
/// auto-generated username from the server so the user can keep it with
/// a single tap, or type something custom before continuing.
///
/// Continue is the only exit — there's no Skip button. Once the user
/// proceeds, `clearNeedsUsernameSetup` is called and routing falls
/// through to /home for all subsequent app launches.
class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final TextEditingController _controller = TextEditingController();
  final UsernameService _usernameService = UsernameService();
  String? _errorMessage;
  bool _isLoading = false;
  String _initialUsername = '';

  @override
  void initState() {
    super.initState();
    // Pre-fill with the backend-assigned username so users who don't care
    // can just tap Continue. The auto-generated names are intentionally
    // game-on-brand (Swift_Snake_4231 etc.) so they're acceptable defaults.
    final authState = context.read<AuthCubit>().state;
    _initialUsername = authState.user?.username ?? '';
    _controller.text = _initialUsername;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Maps a stable [UsernameError] code to the localized message.
  String _usernameErrorText(UsernameError code, AppLocalizations l10n) {
    switch (code) {
      case UsernameError.empty:
        return l10n.unEmpty;
      case UsernameError.tooShort:
        return l10n.unMinLength(UsernameService.minLength);
      case UsernameError.tooLong:
        return l10n.unMaxLength(UsernameService.maxLength);
      case UsernameError.invalidFormat:
        return l10n.unPattern;
      case UsernameError.reserved:
        return l10n.unReserved;
      case UsernameError.taken:
        return l10n.unTaken;
      case UsernameError.updateFailed:
        return l10n.unUpdateFailed;
    }
  }

  Future<void> _onContinue() async {
    // Capture before the awaits below — used after async gaps.
    final l10n = AppLocalizations.of(context)!;
    final newUsername = _controller.text.trim();
    if (newUsername.isEmpty) {
      setState(() => _errorMessage = l10n.unEmpty);
      return;
    }

    // If they kept the pre-filled name as-is, the server already has it —
    // no need for an extra round trip. Just clear the flag and proceed.
    if (newUsername == _initialUsername) {
      _finish();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authCubit = context.read<AuthCubit>();
    // Ask the Firebase session (through the cubit), not state.isGuestUser:
    // the cached UnifiedUser can briefly be the offline-guest stub
    // mid-handoff and would route us into updateGuestUsername — a local-only
    // mutation that gets overwritten the moment the backend sync settles.
    final isAuthenticated = authCubit.hasRealCredential;
    final success = isAuthenticated
        ? await authCubit.updateAuthenticatedUsername(newUsername)
        : await authCubit.updateGuestUsername(newUsername);

    if (!mounted) return;

    if (success) {
      _finish();
    } else {
      final validation = await _usernameService.validateUsernameComplete(
        newUsername,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = validation.errorCode != null
            ? _usernameErrorText(validation.errorCode!, l10n)
            : l10n.unSetFailed;
      });
    }
  }

  void _finish() {
    context.read<AuthCubit>().clearNeedsUsernameSetup();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final g = context.lbGutter;
    return LBScaffold(
      title: l10n.lbUsernameTitle,
      subtitle: l10n.unPickTitle,
      // Continue is the only exit — no back block, no Skip.
      showBack: false,
      banner: false,
      // Spare height is split around the field instead of pooling under
      // it; scrolls so the keyboard opening (autofocused field) on a short
      // screen doesn't overflow.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - context.lbCell * 1.9).clamp(0, double.infinity),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.unPickBody,
                    style: LBText.body(p, color: p.ink, size: 12.5),
                  ),
                  const SizedBox(height: 18),
                  const Spacer(),
                  TextField(
                    controller: _controller,
                    enabled: !_isLoading,
                    autofocus: true,
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9_]'),
                      ),
                      LengthLimitingTextInputFormatter(20),
                    ],
                    decoration: lbInputDecoration(
                      context,
                      label: l10n.unLabel,
                      errorText: _errorMessage,
                    ),
                    style: lbInputStyle(context),
                    cursorColor: p.lime,
                    maxLength: 20,
                  ),
                  const SizedBox(height: 8),
                  LBBlock(
                    kind: LBBlockKind.dashed,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Text(
                      l10n.unRules,
                      style: LBText.body(p, color: p.inkMuted, size: 11.5),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(g, 4, g, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LBPrimaryBlock(
              label: _isLoading ? l10n.unSaving : l10n.unContinue,
              icon: _isLoading ? null : LBIcon.next,
              onTap: _isLoading ? null : _onContinue,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.unChangeAnytime,
              style: LBText.body(p, color: p.inkDim, size: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
