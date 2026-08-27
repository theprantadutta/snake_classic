import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';

/// Gentle, recurring re-ask for users whose notifications are OFF.
///
/// Why this exists: token registration is permission-independent, so a
/// user who missed or denied the OS prompt is fully registered on the
/// backend yet sees NOTHING — every send to them is a silent no-op. The
/// OS prompt itself can only be shown once or twice ever (Android 13+),
/// so this primer is the recurring nudge: friendly copy explaining how
/// little we send, an Enable button that re-fires the prompt (or deep
/// links to system settings once hard-denied), and a "Maybe later".
///
/// Cadence: at most once every [_reaskInterval]. The very first time we
/// detect notifications-off we DON'T show the dialog — the OS prompt the
/// user just dismissed counts as ask #1; nagging immediately after a
/// deny is how apps get uninstalled. Timestamps in SharedPreferences
/// (device-only state, per the storage rules).
class NotificationPermissionPrimer {
  static const String _lastShownKey = 'notif_primer_last_shown_ms';
  static const Duration _reaskInterval = Duration(days: 7);

  /// Call from the home screen after notification init has settled.
  /// No-ops unless: Android, notifications disabled, and the re-ask
  /// interval has elapsed.
  static Future<void> maybeShow(BuildContext context, GameTheme theme) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final enabled = await NotificationService().areNotificationsEnabled();
      if (enabled) return;

      final prefs = await SharedPreferences.getInstance();
      final lastShownMs = prefs.getInt(_lastShownKey);
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      if (lastShownMs == null) {
        // First detection: the OS prompt (fired during notification init)
        // was ask #1. Start the clock; primer appears next week if the
        // user still has notifications off.
        await prefs.setInt(_lastShownKey, nowMs);
        return;
      }

      if (nowMs - lastShownMs < _reaskInterval.inMilliseconds) return;

      await prefs.setInt(_lastShownKey, nowMs);
      if (!context.mounted) return;
      await _showDialog(context, theme);
    } catch (e) {
      AppLogger.error('Notification primer check failed', e);
    }
  }

  static Future<void> _showDialog(BuildContext context, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            const Text('🔔', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.npPrimerTitle,
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.npPrimerBody,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.npMaybeLater,
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              foregroundColor: theme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              // Capture before the async gap — the dialog closes first.
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(dialogContext).pop();

              final service = NotificationService();
              final granted = await service.requestNotificationsPermission();
              if (granted) {
                messenger.showSnackBar(
                  arcadeSnackBarFor(
                    theme,
                    message: l10n.npAllSet,
                    tone: ArcadeSnackTone.success,
                    icon: Icons.notifications_active,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                // Hard-denied: the OS won't show its prompt again, so the
                // settings page is the only path left.
                await service.openSystemNotificationSettings();
              }
            },
            child: Text(
              l10n.npTurnOn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
