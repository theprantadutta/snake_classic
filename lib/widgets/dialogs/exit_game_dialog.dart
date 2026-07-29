import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';

/// The exit-confirmation dialog UI. Pure presentation: resolves with `true`
/// when the player confirms Exit, `false` on Cancel, and `null` if the route
/// is popped some other way (e.g. system back). The caller (game screen)
/// owns the pause-on-open, resume-on-cancel and navigation side effects.
Future<bool?> showExitGameDialog(BuildContext context, GameTheme theme) {
  final l10n = AppLocalizations.of(context)!;
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
        l10n.xgTitle,
        style: TextStyle(
          color: theme.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        l10n.xgBody,
        style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            l10n.commonCancel,
            style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.xgExit, style: TextStyle(color: theme.foodColor)),
        ),
      ],
    ),
  );
}
