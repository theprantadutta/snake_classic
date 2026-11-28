import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/control_layout_preview.dart';
import 'package:snake_classic/widgets/control_tuning.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/pause_overlay.dart' show LBControlChoice;

/// "Pick your controls": the four control styles side by side with live
/// previews, the tuning for the chosen one, and a note that all of it can be
/// changed later. Shown once per install (owner, Nov 2026: controls were the
/// biggest complaint and most players never found the other layouts).
///
/// When: before a player's SECOND game, not the first. Play-first is what
/// took install → first game from ~55% to 94% (Aug 2026), and a modal in
/// front of game one was one of the walls removed then. By game two the
/// player has steered once and knows what they would change. Existing
/// players (games started > 0) get it once on their next game after the
/// update.
class ControlsIntro {
  const ControlsIntro._();

  static const prefsKey = 'controls_intro_seen_v1';

  /// Whether to show it before the game that is about to start.
  static Future<bool> shouldShow({required int gamesStarted}) async {
    if (gamesStarted < 1) return false;
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(prefsKey) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }
}

/// Shows the intro and resolves when the player taps PLAY. Marks it seen as
/// soon as it opens, so a kill mid-sheet can't show it twice.
Future<void> showControlsIntroSheet(BuildContext context) async {
  await ControlsIntro.markSeen();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .7),
    builder: (_) => const PopScope(canPop: false, child: ControlsIntroDialog()),
  );
}

class ControlsIntroDialog extends StatelessWidget {
  const ControlsIntroDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final theme = context.read<ThemeCubit>().state.currentTheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: LB.margin,
        vertical: 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: LBBlock(
          kind: LBBlockKind.sheet,
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
          child: BlocBuilder<GameSettingsCubit, GameSettingsState>(
            builder: (context, s) {
              final cubit = context.read<GameSettingsCubit>();
              Widget choice(
                String title,
                String sub,
                bool onScreen,
                ControlLayout layout,
              ) => Expanded(
                child: LBControlChoice(
                  title: title,
                  subtitle: sub,
                  selected: onScreen
                      ? s.dPadEnabled && s.controlLayout == layout
                      : !s.dPadEnabled,
                  onTap: () {
                    cubit.setDPadEnabled(onScreen);
                    if (onScreen) cubit.setControlLayout(layout);
                  },
                  preview: ControlLayoutPreview(
                    dPadEnabled: onScreen,
                    layout: layout,
                    dPadPosition: s.dPadPosition,
                    controlSize: s.controlSize,
                    theme: theme,
                  ),
                ),
              );
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.ctrlIntroTitle.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: LBText.button(
                          p,
                          color: p.head,
                          size: 15,
                        ).copyWith(letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.ctrlIntroBody,
                      textAlign: TextAlign.center,
                      style: LBText.body(p, size: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        choice(
                          l10n.lbCtrlSwipe,
                          l10n.lbCtrlSwipeSub,
                          false,
                          ControlLayout.dPad,
                        ),
                        const SizedBox(width: 6),
                        choice(
                          l10n.lbCtrlDpad,
                          l10n.lbCtrlDpadSub,
                          true,
                          ControlLayout.dPad,
                        ),
                        const SizedBox(width: 6),
                        choice(
                          l10n.lbCtrlTurn,
                          l10n.lbCtrlTurnSub,
                          true,
                          ControlLayout.turnButtons,
                        ),
                        const SizedBox(width: 6),
                        choice(
                          l10n.lbCtrlStick,
                          l10n.lbCtrlStickSub,
                          true,
                          ControlLayout.joystick,
                        ),
                      ],
                    ),
                    ControlTuning(settings: s),
                    const SizedBox(height: 6),
                    Text(
                      l10n.ctrlIntroTune,
                      textAlign: TextAlign.center,
                      style: LBText.body(p, size: 11, color: p.inkMuted),
                    ),
                    const SizedBox(height: 14),
                    LBBlock(
                      kind: LBBlockKind.fill,
                      height: 50,
                      alignment: Alignment.center,
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.ctrlIntroPlay.toUpperCase(),
                        style: LBText.button(p, color: p.onLime, size: 13),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
