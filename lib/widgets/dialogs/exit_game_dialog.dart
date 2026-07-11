import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// The exit-confirmation dialog UI. Pure presentation: resolves with `true`
/// when the player confirms Exit, `false` on Cancel, and `null` if the route
/// is popped some other way (e.g. system back). The caller (game screen)
/// owns the pause-on-open, resume-on-cancel and navigation side effects.
Future<bool?> showExitGameDialog(BuildContext context, GameTheme theme) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
      ),
      title: Text(
        'Exit Game?',
        style: TextStyle(
          color: theme.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Are you sure you want to exit? Your current progress will be lost.',
        style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Exit', style: TextStyle(color: theme.foodColor)),
        ),
      ],
    ),
  );
}
