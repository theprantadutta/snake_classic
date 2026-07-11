import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';

/// First-launch modal asking the player to pick gestures or the D-Pad.
/// Now called before [GameCubit.startGame], so the snake isn't already
/// moving behind the dialog — no pause/resume dance needed. Whatever
/// they choose is persisted via [GameSettingsCubit.updateDPadEnabled]
/// and surfaced with a "change this anytime in Settings → Controls"
/// footer.
Future<void> showControlChoiceDialog(BuildContext context) async {
  final settingsCubit = context.read<GameSettingsCubit>();
  final theme = context.read<ThemeCubit>().state.currentTheme;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: theme.accentColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How do you want to play?',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick one — you can change it anytime in Settings → Controls.',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildControlChoiceCard(
              dialogContext: dialogContext,
              theme: theme,
              icon: Icons.swipe_rounded,
              title: 'Swipe Gestures',
              subtitle: 'Swipe anywhere on the board to turn.',
              onTap: () async {
                await settingsCubit.updateDPadEnabled(false);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
            const SizedBox(height: 12),
            _buildControlChoiceCard(
              dialogContext: dialogContext,
              theme: theme,
              icon: Icons.gamepad_rounded,
              title: 'D-Pad Controls',
              subtitle: 'On-screen directional buttons.',
              onTap: () async {
                await settingsCubit.updateDPadEnabled(true);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildControlChoiceCard({
  required BuildContext dialogContext,
  required GameTheme theme,
  required IconData icon,
  required String title,
  required String subtitle,
  required Future<void> Function() onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.accentColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    ),
  );
}
