import 'package:flutter/material.dart';

/// Shared "you got your reward" snackbar for every rewarded-ad placement,
/// styled to match the battle-pass XP toast (the one placement that already
/// confirmed its grant). Takes a [ScaffoldMessengerState] rather than a
/// [BuildContext] because reward grants fire AFTER the ad is dismissed —
/// an async gap where reading the original context is unsafe; callers
/// capture the messenger before showing the ad.
void showRewardToast(
  ScaffoldMessengerState messenger,
  String message, {
  IconData icon = Icons.celebration,
}) {
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
