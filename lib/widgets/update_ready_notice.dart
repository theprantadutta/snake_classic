import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/in_app_update_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// One-line strip above the banner on Home: a flexible update has finished
/// downloading and only needs a restart. Renders nothing until then, so it
/// costs the layout nothing on every other launch.
///
/// This is the whole "ask" for a routine update. Play already asked once,
/// quietly, to download; the restart is the player's call and it waits for
/// them, unlike the blocking flow this replaced.
class UpdateReadyNotice extends StatelessWidget {
  const UpdateReadyNotice({super.key, required this.theme});

  /// Kept for callers; the strip reads the Living Board palette from the
  /// context.
  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InAppUpdateService().updateReadyToInstall,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context)!;
        final p = context.lb;
        return ColoredBox(
          color: p.deep.withValues(alpha: .9),
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.lbGutter, 4, context.lbGutter - 4, 4),
            child: Row(
              children: [
                LBPixelIcon(LBIcon.next, cell: 3, color: p.lime),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.updateReadyTitle,
                    style: LBText.button(p, color: p.head, size: 12).copyWith(letterSpacing: .8),
                  ),
                ),
                LBBlock(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  onTap: () => InAppUpdateService().completeUpdate(),
                  child: Text(
                    l10n.updateReadyRestart.toUpperCase(),
                    style: LBText.button(p, color: p.lime, size: 11.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
