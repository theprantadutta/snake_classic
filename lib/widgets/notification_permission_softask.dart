import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';

/// First-run pre-permission "soft ask" for notifications.
///
/// Instead of firing the OS permission prompt cold, we show this friendly,
/// on-brand modal FIRST to explain the value. Only if the user taps "Enable"
/// do we trigger the real OS prompt (via [NotificationService.requestPermissionFlow]).
/// If they tap "Not now", the OS prompt is never fired — which matters a lot on
/// iOS (Apple shows its system prompt only once, ever) and on Android 13+
/// (the one-shot POST_NOTIFICATIONS dialog). This is Apple's recommended
/// priming pattern and it materially lifts opt-in rates on both platforms.
///
/// Shown at most ONCE (tracked in SharedPreferences — device-only state, per
/// the storage rules). After this, the recurring [NotificationPermissionPrimer]
/// takes over as the periodic re-ask for users still opted out.
class NotificationPermissionSoftAsk {
  static const String _shownKey = 'notif_soft_ask_shown';

  /// Call from the home screen after notification init has settled (with the
  /// OS prompt deferred). No-ops if it has already been shown once, or — on
  /// Android — if notifications are already enabled.
  static Future<void> maybeShow(BuildContext context, GameTheme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_shownKey) ?? false) return;

      // On Android we can detect an already-granted state (e.g. a reinstall
      // that kept the permission) and skip straight to marking it done. iOS
      // reports enabled==true unconditionally here, so it always sees the
      // soft-ask once (the flag then prevents repeats).
      final alreadyEnabled =
          await NotificationService().areNotificationsEnabled();
      if (alreadyEnabled &&
          defaultTargetPlatform == TargetPlatform.android) {
        await prefs.setBool(_shownKey, true);
        return;
      }

      if (!context.mounted) return;
      final wantsEnable = await _showDialog(context, theme);

      // Mark shown regardless of choice so we never soft-ask twice.
      await prefs.setBool(_shownKey, true);

      if (wantsEnable != true) return;

      final messenger =
          context.mounted ? ScaffoldMessenger.maybeOf(context) : null;
      final granted = await NotificationService().requestPermissionFlow();
      if (granted) {
        messenger?.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text("🎉 You're all set!",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Notification soft-ask failed', e);
    }
  }

  /// Returns `true` if the user chose to enable, `false`/`null` otherwise.
  static Future<bool?> _showDialog(BuildContext context, GameTheme theme) {
    return showDialog<bool>(
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
                'Stay in the loop?',
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "Turn on notifications and we'll remind you about your daily "
          'challenges and streaks — plus the big stuff like FREE Premium '
          'giveaways and special events.\n\nJust a couple a day, no spam. 🐍',
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Not now',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
              ),
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
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Enable notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
