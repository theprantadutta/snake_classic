import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/utils/typography.dart';

/// One-shot "which mode do you want to play?" sheet.
///
/// Deliberately NOT shown before a player's first game — someone who has never
/// seen the board cannot choose between Classic, Zen and Survival. It used to
/// be deferred to their *second* tap of Play, which meant the ~41% of players
/// who never start a second game were never offered any mode but Classic at
/// all. It is now offered at the first game-over instead, where the player has
/// seen the board and the choice means something, with the Play button acting
/// as a fallback for anyone who gets past a game without passing game-over.
///
/// Shown at most once ever, tracked by [GameSettingsCubit]'s
/// `gameModeFirstLaunchPrompted` flag.
Future<void> maybeShowGameModePicker(BuildContext context) async {
  final settingsCubit = context.read<GameSettingsCubit>();

  // Read the flag with a short hydration window. If the cubit is already ready
  // (overwhelmingly the common case) this returns immediately. Falls back to
  // direct storage on a timeout so we never nag a user who already chose.
  bool alreadyPrompted;
  if (settingsCubit.state.isReady) {
    alreadyPrompted = settingsCubit.state.gameModeFirstLaunchPrompted;
  } else {
    try {
      final ready = await settingsCubit.stream
          .firstWhere((s) => s.isReady)
          .timeout(const Duration(seconds: 2));
      alreadyPrompted = ready.gameModeFirstLaunchPrompted;
    } catch (_) {
      alreadyPrompted = await getIt<StorageService>().hasGameModeBeenPrompted();
    }
  }

  if (!context.mounted) return;
  if (alreadyPrompted) return;

  final selected = await showModalBottomSheet<GameMode>(
    context: context,
    // Dismissible: a player who wants to keep playing wants to keep playing,
    // and trapping them in a modal until they commit to a mode they have not
    // tried yet is friction with no upside. Dismissing keeps their current
    // mode and still marks the picker as shown, so it asks once and never nags.
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Cap width so the sheet centers on tablets instead of spanning the full
    // width (no-op on phones narrower than 640).
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (sheetContext) =>
        GameModePickerSheet(initialMode: settingsCubit.state.gameMode),
  );

  if (selected != null) {
    await settingsCubit.setGameMode(selected);
  }
  await settingsCubit.markGameModePrompted();
}

class GameModePickerSheet extends StatefulWidget {
  const GameModePickerSheet({super.key, required this.initialMode});

  final GameMode initialMode;

  @override
  State<GameModePickerSheet> createState() => GameModePickerSheetState();
}

class GameModePickerSheetState extends State<GameModePickerSheet> {
  late GameMode _selected = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.backgroundColor.withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.homePickGameMode,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: context.letterSpacing(1.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homePickGameModeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ...GameMode.values.map((mode) {
              final isSelected = _selected == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selected = mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.accentColor.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: isSelected
                            ? theme.accentColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(mode.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.localizedName(l10n),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mode.localizedDescription(l10n),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: theme.accentColor,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: theme.backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(_selected),
                child: Text(
                  l10n.homeStartPlaying,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: context.letterSpacing(1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
