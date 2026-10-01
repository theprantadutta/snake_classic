import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// First-launch modal asking the player to pick gestures or the D-Pad.
/// Now called before [GameCubit.startGame], so the snake isn't already
/// moving behind the dialog — no pause/resume dance needed. Whatever
/// they choose is persisted via [GameSettingsCubit.updateDPadEnabled]
/// and surfaced with a "change this anytime in Settings → Controls"
/// footer.
Future<void> showControlChoiceDialog(BuildContext context) async {
  final settingsCubit = context.read<GameSettingsCubit>();
  final l10n = AppLocalizations.of(context)!;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .65),
    builder: (dialogContext) {
      final p = dialogContext.lb;
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: LB.margin * 1.5, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: LBBlock(
              kind: LBBlockKind.sheet,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.ccTitle.toUpperCase(),
                      style: LBText.button(p, color: p.head, size: 15).copyWith(letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.ccBody, style: LBText.body(p, size: 12)),
                  const SizedBox(height: 14),
                  _ControlChoiceRow(
                    icon: LBIcon.next,
                    title: l10n.ccSwipe,
                    subtitle: l10n.ccSwipeSub,
                    onTap: () async {
                      await settingsCubit.updateDPadEnabled(false);
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    },
                  ),
                  _ControlChoiceRow(
                    icon: LBIcon.plus,
                    title: l10n.ccDpad,
                    subtitle: l10n.ccDpadSub,
                    onTap: () async {
                      await settingsCubit.updateDPadEnabled(true);
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ControlChoiceRow extends StatelessWidget {
  const _ControlChoiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final LBIcon icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final next = Directionality.of(context) == TextDirection.rtl ? LBIcon.back : LBIcon.next;
    return LBRow(
      title: title,
      subtitle: subtitle,
      leading: LBPixelIcon(icon, cell: 4.4, color: p.lime),
      trailing: LBPixelIcon(next, cell: 2.6, color: p.inkDim),
      onTap: onTap,
    );
  }
}
