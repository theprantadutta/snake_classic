import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/services/sync/sync_engine.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';

/// Modal overlay shown during the first-sign-in flow. Subscribes to
/// [SyncEngine.firstSignInStateStream] and renders a full-screen
/// blocking sheet whenever the engine is in a non-idle, non-done
/// state. Mounted globally via `MaterialApp.builder` in `main.dart`
/// so it covers every screen the auth flow might be on (loading,
/// first-time-auth, email-auth, …).
class SyncRestoreOverlay extends StatefulWidget {
  final GameTheme theme;

  const SyncRestoreOverlay({super.key, required this.theme});

  @override
  State<SyncRestoreOverlay> createState() => _SyncRestoreOverlayState();
}

class _SyncRestoreOverlayState extends State<SyncRestoreOverlay> {
  FirstSignInState _state = SyncEngine().firstSignInState;
  StreamSubscription<FirstSignInState>? _sub;

  @override
  void initState() {
    super.initState();
    AppLogger.network(
      'SyncRestoreOverlay mounted (initial state: ${_state.name})',
    );
    _sub = SyncEngine().firstSignInStateStream.listen((s) {
      AppLogger.network(
        'SyncRestoreOverlay received state: ${s.name}',
      );
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

  ({String title, String body, bool spinning, IconData? icon, Color? iconColor})
      _copyForState() {
    switch (_state) {
      case FirstSignInState.welcoming:
        return (
          title: 'Setting up your account…',
          body:
              'Getting things ready for your first session. This only happens once.',
          spinning: true,
          icon: null,
          iconColor: null,
        );
      case FirstSignInState.pulling:
        return (
          title: 'Loading your previous data…',
          body:
              'Fetching your stats, achievements, coins, and unlocks from the cloud.',
          spinning: true,
          icon: null,
          iconColor: null,
        );
      case FirstSignInState.applying:
        return (
          title: 'Restoring your progress…',
          body: "Applying everything to this device. Don't close the app.",
          spinning: true,
          icon: null,
          iconColor: null,
        );
      case FirstSignInState.restored:
        return (
          title: 'All set!',
          body: 'Your progress has been restored.',
          spinning: false,
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.greenAccent,
        );
      case FirstSignInState.failed:
        return (
          title: "Couldn't restore right now",
          body: "We'll try again the next time you open the app.",
          spinning: false,
          icon: Icons.cloud_off_rounded,
          iconColor: Colors.orangeAccent,
        );
      case FirstSignInState.idle:
      case FirstSignInState.done:
        return (title: '', body: '', spinning: false, icon: null, iconColor: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) return const SizedBox.shrink();

    final theme = widget.theme;
    final copy = _copyForState();

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: AbsorbPointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.78),
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (copy.spinning)
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.accentColor),
                      ),
                    )
                  else if (copy.icon != null)
                    Icon(
                      copy.icon,
                      size: 64,
                      color: copy.iconColor ?? theme.accentColor,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    copy.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    copy.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.75),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
