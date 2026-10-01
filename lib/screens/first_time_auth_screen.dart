import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/legal_acceptance.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

class FirstTimeAuthScreen extends StatefulWidget {
  const FirstTimeAuthScreen({super.key});

  @override
  State<FirstTimeAuthScreen> createState() => _FirstTimeAuthScreenState();
}

class _FirstTimeAuthScreenState extends State<FirstTimeAuthScreen> {
  bool _isLoading = false;
  bool _showPrivacyPolicy = true;
  bool _privacyAccepted = false;
  String _privacyPolicyContent = '';
  String _termsContent = '';

  @override
  void initState() {
    super.initState();
    _loadLegalDocuments();
    _checkPreviousPrivacyAcceptance();
  }

  Future<void> _checkPreviousPrivacyAcceptance() async {
    // Accepted only when it's the CURRENT policy version — a version bump in
    // PRIVACY.md re-shows the policy here.
    final alreadyAccepted = await LegalAcceptance.isCurrentVersionAccepted();
    if (alreadyAccepted && mounted) {
      setState(() {
        _showPrivacyPolicy = false;
        _privacyAccepted = true;
      });
    }
  }

  Future<void> _loadLegalDocuments() async {
    await _loadPrivacyPolicy();
    await _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final content = await rootBundle.loadString('assets/legal/TERMS.md');
      if (mounted) setState(() => _termsContent = content);
    } catch (e) {
      if (mounted) {
        setState(
          () => _termsContent =
              'Our Terms of Use are available at '
              'https://legal.pranta.dev/terms?projectName=snake_classic. '
              'By continuing you agree to those terms.',
        );
      }
    }
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      final content = await rootBundle.loadString('assets/legal/PRIVACY.md');
      if (!mounted) return;
      setState(() {
        _privacyPolicyContent = content;
      });
    } catch (e) {
      if (!mounted) return;
      // Fallback if file can't be loaded
      setState(() {
        _privacyPolicyContent = '''# Privacy Policy for Snake Classic

**Effective Date: January 17, 2025**

## Introduction
Snake Classic respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

## Information We Collect
We collect various types of information to provide and improve our services, including:
- Authentication data when you sign in with Apple or Google
- Game data such as scores, achievements, and progress
- Device information for app functionality
- Usage analytics to improve the game experience

## How We Use Your Information
Your information is used to:
- Provide core game functionality
- Save your progress and achievements
- Enable social features and leaderboards
- Improve app performance and user experience

## Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

## Your Rights
You have the right to access, update, or delete your personal information. Contact us for any privacy-related requests.

## Contact Information
For questions about this Privacy Policy, please contact Pranta Dutta at: prantadutta1997@gmail.com

By using Snake Classic, you acknowledge that you have read, understood, and agree to this Privacy Policy.
''';
      });
    }
  }

  /// Sign in with Apple is offered on Apple platforms only — there is no
  /// Apple ID to sign in with on Android. The guest note below the buttons
  /// reads the same condition so it never names a button that isn't there.
  static bool get _showAppleSignIn =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    if (_showPrivacyPolicy) {
      return _buildPrivacyPolicyView();
    }

    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final s = context.uiScale;

    return Scaffold(
      body: LBGridBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Fills whatever height the phone has: the logo group takes
              // the upper space and the sign-in blocks sit in the thumb
              // zone. Spacers absorb the difference between a 640 dp and a
              // 900 dp phone; on a short screen (or large text) it scrolls
              // instead of overflowing. No back block: first screen.
              final h = context.isTablet ? 760.0 : constraints.maxHeight;
              final mark = (h * .15).clamp(76.0, 136.0) * s;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: context.lbCell),
                      const Spacer(flex: 3),
                      Center(child: LBCellSMark(size: mark)),
                      SizedBox(height: mark * .24),
                      Center(
                        child: LBCellText(
                          'SNAKE',
                          cell: mark / 14,
                          glow: true,
                          semanticsLabel: 'Snake Classic',
                        ),
                      ),
                      SizedBox(height: 12 * s),
                      Center(
                        child: ExcludeSemantics(
                          child: Text(
                            'CLASSIC',
                            style: LBText.label(p, color: p.lime.withValues(alpha: .75))
                                .copyWith(fontSize: 12, letterSpacing: 12),
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      SizedBox(height: context.lbCell),
                      Text(
                        l10n.faChooseHow,
                        textAlign: TextAlign.center,
                        style: LBText.body(p, color: p.ink, size: 13),
                      ),
                      SizedBox(height: 18 * s),

                      // Auth buttons
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LBBusyCells(semanticsLabel: l10n.faSigningIn),
                              const SizedBox(height: 16),
                              Text(
                                l10n.faSigningIn,
                                textAlign: TextAlign.center,
                                style: LBText.body(p, color: p.ink, size: 13),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Sign in with Apple — listed first on Apple
                        // platforms: Guideline 4.8 requires it next to
                        // third-party logins, and the HIG asks for
                        // equal-or-greater prominence than the others. It
                        // keeps Apple's own colours (white mark and label on
                        // a white outline) rather than the board's lime.
                        if (_showAppleSignIn)
                          LBAuthOptionBlock(
                            label: l10n.pfSignInApple,
                            leading: const FaIcon(
                              FontAwesomeIcons.apple,
                              color: Colors.white,
                              size: 22,
                            ),
                            accent: Colors.white,
                            foreground: Colors.white,
                            onTap: () => _handleAppleSignIn(authCubit),
                          ),

                        // Google Sign-In Button
                        LBAuthOptionBlock(
                          label: l10n.pfSignInGoogle,
                          leading: FaIcon(
                            FontAwesomeIcons.google,
                            color: p.head,
                            size: 20,
                          ),
                          onTap: () => _handleGoogleSignIn(authCubit),
                        ),

                        // Email Sign-In Button
                        LBAuthOptionBlock(
                          label: l10n.faSignInEmail,
                          leading: LBPixelIcon(LBIcon.lock, cell: 3.6, color: p.head),
                          onTap: () => context.push(AppRoutes.emailAuth),
                        ),

                        SizedBox(height: context.lbCell * .5),

                        // Guest Button — goes straight through. The
                        // confirm modal that used to sit here spelled
                        // out three downsides ("deleted in 90 days",
                        // "no cloud sync", "you can't buy anything")
                        // and demanded a "Proceed Anyway" tap, on the
                        // path the majority of players actually take.
                        // Arguing against our own product at the moment
                        // someone is deciding whether to bother is not
                        // a warning, it is a churn funnel. The tradeoffs
                        // are still stated in the subtitle below, and
                        // Profile offers the upgrade whenever they want
                        // it.
                        LBPrimaryBlock(
                          label: l10n.faContinueGuest,
                          icon: LBIcon.play,
                          onTap: () => _handleGuestLogin(authCubit),
                        ),

                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _showAppleSignIn
                                ? l10n.lbGuestNoteApple
                                : l10n.lbGuestNoteNoApple,
                            textAlign: TextAlign.center,
                            style: LBText.body(p, color: p.inkMuted, size: 11.5),
                          ),
                        ),
                      ],

                      const Spacer(),
                      SizedBox(height: context.lbCell),
                    ],
                  ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyView() {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;
    return LBScaffold(
      title: l10n.lbAuthLegalTitle,
      subtitle: l10n.faReviewNote,
      // First screen of the flow: nothing to go back to.
      showBack: false,
      banner: false,
      body: Padding(
        padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, 0),
        // Privacy Policy + Terms of Use — swipeable tabs.
        child: LBLegalTabs(
          privacyLabel: l10n.settingsPrivacyPolicyTitle,
          termsLabel: l10n.settingsTermsTitle,
          privacy: _privacyPolicyContent,
          terms: _termsContent,
        ),
      ),
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(g, 4, g, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Acceptance Checkbox
            LBCheckBlock(
              value: _privacyAccepted,
              label: l10n.faAgreeCheckbox,
              onChanged: (value) async {
                setState(() {
                  _privacyAccepted = value;
                });
                // Save privacy acceptance (by version) when checked.
                if (_privacyAccepted) {
                  await LegalAcceptance.recordAccepted();
                }
              },
            ),
            const SizedBox(height: 6),
            // Continue Button
            LBPrimaryBlock(
              label: l10n.faContinueToSignIn,
              icon: LBIcon.check,
              onTap: _privacyAccepted
                  ? () {
                      setState(() {
                        _showPrivacyPolicy = false;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAppleSignIn(AuthCubit authCubit) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final success = await authCubit.signInWithApple();

      if (success && mounted) {
        await authCubit.markFirstTimeSetupComplete();

        // Same routing as Google: new accounts divert through
        // username-setup unless a username is already on file.
        if (mounted) {
          final existingUsername = authCubit.state.user?.username.trim() ?? '';
          final showSetup =
              authCubit.state.needsUsernameSetup && existingUsername.isEmpty;
          final route = showSetup ? AppRoutes.usernameSetup : AppRoutes.home;
          context.go(route);
        }
      } else if (mounted) {
        _showError(l10n.faAppleFailed);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n.faUnexpected);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthCubit authCubit) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final success = await authCubit.signInWithGoogle();

      if (success && mounted) {
        // Mark first-time setup as complete
        await authCubit.markFirstTimeSetupComplete();

        // If the backend just created a fresh account, divert through the
        // username-setup screen so the user can keep or edit the
        // auto-generated name before landing on home. For returning users
        // (cross-device Google login etc.), needsUsernameSetup is false
        // and we go straight home.
        //
        // Second gate: never show the setup screen to a user that already
        // has a non-empty username on file. The backend's username
        // generator (AuthenticateWithFirebaseCommandHandler) always
        // assigns one for new accounts, so this is mostly defense-in-
        // depth — but if needsUsernameSetup ever drifts true for someone
        // with an established name (e.g. a stale flag from a prior
        // session), we don't make them re-pick a name they already have.
        if (mounted) {
          final existingUsername = authCubit.state.user?.username.trim() ?? '';
          final showSetup =
              authCubit.state.needsUsernameSetup && existingUsername.isEmpty;
          final route = showSetup ? AppRoutes.usernameSetup : AppRoutes.home;
          context.go(route);
        }
      } else if (mounted) {
        _showError(l10n.faGoogleFailed);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n.faUnexpected);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin(AuthCubit authCubit) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      await authCubit.signInAnonymously();

      // Mark first-time setup as complete
      await authCubit.markFirstTimeSetupComplete();

      if (mounted) {
        // Same username-setup divert applies to anonymous sign-ins —
        // anonymous users get a generated username server-side too and
        // benefit from picking their own. Same second-gate as the Google
        // path: never show setup to someone with an established username.
        final existingUsername = authCubit.state.user?.username.trim() ?? '';
        final showSetup =
            authCubit.state.needsUsernameSetup && existingUsername.isEmpty;
        final route = showSetup ? AppRoutes.usernameSetup : AppRoutes.home;
        context.go(route);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n.faGuestFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(context, message: message, tone: ArcadeSnackTone.error),
    );
  }
}
