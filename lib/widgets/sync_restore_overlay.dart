import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/sync/sync_engine.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/auth/lb_auth_widgets.dart';

/// Modal overlay shown during the first-sign-in flow. Subscribes to
/// [SyncEngine.firstSignInStateStream] and renders a full-screen
/// blocking sheet whenever the engine is in a non-idle, non-done state.
///
/// Hosted inside an [OverlayEntry] inserted by [SyncEngine] itself
/// (see [SyncEngine.attachNavigatorKey]). That makes it visible above
/// whatever screen the user happens to be on when sign-in fires —
/// FirstTimeAuthScreen, LoadingScreen, ProfileScreen's "Save your
/// progress" upgrade, anywhere — without putting any restore-related
/// code into the screens' widget trees. Once the engine emits `done`,
/// the OverlayEntry is removed and this widget never builds again until
/// the next first-sign-in flow (typically only on a fresh reinstall).
class SyncRestoreOverlay extends StatefulWidget {
  const SyncRestoreOverlay({super.key});

  @override
  State<SyncRestoreOverlay> createState() => _SyncRestoreOverlayState();
}

class _SyncRestoreOverlayState extends State<SyncRestoreOverlay> {
  FirstSignInState _state = SyncEngine().firstSignInState;
  StreamSubscription<FirstSignInState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = SyncEngine().firstSignInStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _shouldShow {
    switch (_state) {
      case FirstSignInState.welcoming:
      case FirstSignInState.pulling:
      case FirstSignInState.applying:
      case FirstSignInState.restored:
      case FirstSignInState.failed:
        return true;
      case FirstSignInState.idle:
      case FirstSignInState.done:
        return false;
    }
  }

  ({String title, String body, bool spinning, LBIcon? icon, Color? iconColor})
      _copyForState(AppLocalizations? l10n) {
    switch (_state) {
      case FirstSignInState.welcoming:
        return (
          title: l10n?.sroSettingUpTitle ?? 'Setting up your account…',
          body: l10n?.sroSettingUpBody ??
              'Getting things ready for your first session. This only happens once.',
          spinning: true,
          icon: null,
          iconColor: null,
        );
      case FirstSignInState.pulling:
        return (
          title: l10n?.sroLoadingTitle ?? 'Loading your previous data…',
          body: l10n?.sroLoadingBody ??
              'Fetching your stats, achievements, coins, and unlocks from the cloud.',
          spinning: true,
          icon: null,
          iconColor: null,
        );
      case FirstSignInState.applying:
        return (
          title: l10n?.sroRestoringTitle ?? 'Restoring your progress…',
          body: l10n?.sroRestoringBody ??
              "Applying everything to this device. Don't close the app.",
          spinning: true,
          icon: null,
          iconColor: null,
        );
      case FirstSignInState.restored:
        return (
          title: l10n?.sroDoneTitle ?? 'All set!',
          body: l10n?.sroDoneBody ?? 'Your progress has been restored.',
          spinning: false,
          icon: LBIcon.check,
          iconColor: null, // palette lime
        );
      case FirstSignInState.failed:
        return (
          title: l10n?.sroFailedTitle ?? "Couldn't restore your data",
          body: l10n?.sroFailedBody ??
              "We couldn't reach the cloud just now. Check your internet "
                  "connection and try again. You can also continue without "
                  "restoring — we'll retry the next time you open the app.",
          spinning: false,
          icon: LBIcon.x,
          iconColor: LB.bonk,
        );
      case FirstSignInState.idle:
      case FirstSignInState.done:
        return (title: '', body: '', spinning: false, icon: null, iconColor: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    // Read theme via BlocBuilder so the overlay can render inside any
    // OverlayEntry context (no constructor arg needed). ThemeCubit is
    // provided at the root in main.dart, above MaterialApp.router, so
    // it's reachable from inside the Navigator's Overlay.
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        // The palette comes from the cubit too, and is re-provided below so
        // the blocks inside paint the active theme even if this entry sits
        // outside the app Theme.
        final p = LBPalette.of(themeState.currentTheme);
        // Resolved inside build — this widget lives in an OverlayEntry, so
        // the lookup can miss if the entry sits above MaterialApp's
        // Localizations; the copy falls back to English in that case.
        final l10n = AppLocalizations.of(context);
        final copy = _copyForState(l10n);
        final isFailed = _state == FirstSignInState.failed;

        // Backdrop catches taps so they don't pass through to widgets
        // behind the overlay, but doesn't dismiss — only the explicit
        // buttons (in the failed state) can move past this screen.
        return Theme(
          data: Theme.of(context).copyWith(extensions: [p]),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                color: Colors.black.withValues(alpha: 0.78),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: LB.margin * 1.5),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: LBBlock(
                    kind: LBBlockKind.sheet,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: copy.spinning
                              ? LBBusyCells(semanticsLabel: copy.title)
                              : copy.icon != null
                                  ? LBPixelIcon(
                                      copy.icon!,
                                      cell: 8,
                                      color: copy.iconColor ?? p.lime,
                                    )
                                  : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 22),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            copy.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: LBText.button(
                              p,
                              color: isFailed ? LB.bonk : p.head,
                              size: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          copy.body,
                          textAlign: TextAlign.center,
                          style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
                        ),
                        if (isFailed) ...[
                          const SizedBox(height: 22),
                          LBPrimaryBlock(
                            label: l10n?.sroTryAgain ?? 'Try Again',
                            onTap: () => SyncEngine().retryFirstSignInPull(),
                            height: 50,
                          ),
                          LBBlock(
                            kind: LBBlockKind.muted,
                            height: 46,
                            alignment: Alignment.center,
                            onTap: () =>
                                SyncEngine().dismissFirstSignInOverlay(),
                            child: Text(
                              (l10n?.sroContinueAnyway ?? 'Continue Anyway')
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: LBText.button(p, color: p.inkMuted, size: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
