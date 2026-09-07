import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/in_app_update_service.dart';
import 'package:snake_classic/utils/constants.dart';

/// One-line strip above the banner on Home: a flexible update has finished
/// downloading and only needs a restart. Renders nothing until then, so it
/// costs the layout nothing on every other launch.
///
/// This is the whole "ask" for a routine update. Play already asked once,
/// quietly, to download; the restart is the player's call and it waits for
/// them, unlike the blocking flow this replaced.
class UpdateReadyNotice extends StatelessWidget {
  const UpdateReadyNotice({super.key, required this.theme});

  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InAppUpdateService().updateReadyToInstall,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
          color: theme.backgroundColor.withValues(alpha: 0.55),
          child: Row(
            children: [
              Icon(
                Icons.system_update_rounded,
                size: 18,
                color: theme.accentColor.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.updateReadyTitle,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => InAppUpdateService().completeUpdate(),
                style: TextButton.styleFrom(
                  foregroundColor: theme.accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: Text(
                  l10n.updateReadyRestart.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
