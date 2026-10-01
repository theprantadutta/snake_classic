import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/screens/run_setup_screen.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

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
    barrierColor: Colors.black.withValues(alpha: .6),
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
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final modes = GameMode.values;
    return LBSheetBody(
      title: l10n.lbSetupMode,
      subtitle: l10n.lbSetupSubtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < modes.length; i += 2)
                    Row(
                      children: [
                        for (final mode in modes.skip(i).take(2))
                          Expanded(
                            child: LBChoiceBlock(
                              title: mode.localizedName(l10n),
                              line: RunSetupScreen.modeLine(l10n, mode),
                              selected: _selected == mode,
                              onTap: () => setState(() => _selected = mode),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          LBBlock(
            kind: LBBlockKind.fill,
            height: context.lbCell * 3,
            alignment: Alignment.center,
            onTap: () => Navigator.of(context).pop(_selected),
            child: Text(
              l10n.homeStartPlaying.toUpperCase(),
              style: LBText.button(p, color: p.onLime, size: 15).copyWith(letterSpacing: 3),
            ),
          ),
        ],
      ),
    );
  }
}
