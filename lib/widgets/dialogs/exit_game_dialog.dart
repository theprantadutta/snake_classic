import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// The exit-confirmation dialog UI. Pure presentation: resolves with `true`
/// when the player confirms Exit, `false` on Cancel, and `null` if the route
/// is popped some other way (e.g. system back). The caller (game screen)
/// owns the pause-on-open, resume-on-cancel and navigation side effects.
Future<bool?> showExitGameDialog(BuildContext context, GameTheme theme) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .65),
    builder: (dialogContext) {
      final p = dialogContext.lb;
      final cell = dialogContext.lbCell;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LBBlock(
            kind: LBBlockKind.sheet,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.xgTitle.toUpperCase(),
                    style: LBText.button(p, color: p.head, size: 15).copyWith(letterSpacing: 2.2),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.xgBody,
                  style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12.5),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: LBBlock(
                        height: cell * 2.5,
                        alignment: Alignment.center,
                        onTap: () => Navigator.of(dialogContext).pop(false),
                        child: Text(
                          l10n.lbCancel,
                          style: LBText.button(p, size: 13).copyWith(letterSpacing: 2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LBBlock(
                        kind: LBBlockKind.danger,
                        height: cell * 2.5,
                        alignment: Alignment.center,
                        onTap: () => Navigator.of(dialogContext).pop(true),
                        child: Text(
                          l10n.xgExit.toUpperCase(),
                          style: LBText.button(p, color: LB.bonk, size: 13).copyWith(letterSpacing: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
