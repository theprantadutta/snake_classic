import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/settings/settings_rows.dart';

/// The fine-tuning under the control picker, for whichever control is chosen:
///
///   - swipe       → swipe sensitivity
///   - d-pad       → button size + position (left / centre / right)
///   - turn        → button size
///   - stick       → nothing (it already floats under the thumb)
///
/// One widget for Settings → Controls and the Pause sheet, so the two can't
/// drift. Controls were the most common review complaint (Nov 2026: d-pad too
/// small, swipes "laggy"); this is where a player fixes their own.
class ControlTuning extends StatelessWidget {
  const ControlTuning({super.key, required this.settings, this.onChanged});

  final GameSettingsState settings;

  /// Analytics hook: (setting, value).
  final void Function(String setting, Object value)? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<GameSettingsCubit>();
    final s = settings;
    final onScreen = s.dPadEnabled;
    final dPad = onScreen && s.controlLayout == ControlLayout.dPad;
    final turn = onScreen && s.controlLayout == ControlLayout.turnButtons;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
      child: LBSectionLabel(text),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!onScreen) ...[
          label(l10n.ctrlSwipeSensitivity),
          SettingsOptionStrip<SwipeSensitivity>(
            options: SwipeSensitivity.values,
            selected: s.swipeSensitivity,
            labelOf: (v) => v.localizedName(l10n),
            onSelect: (v) {
              cubit.setSwipeSensitivity(v);
              onChanged?.call('swipe_sensitivity', v.name);
            },
          ),
        ],
        if (dPad || turn) ...[
          label(l10n.ctrlButtonSize),
          SettingsOptionStrip<ControlSize>(
            options: ControlSize.values,
            selected: s.controlSize,
            labelOf: (v) => v.localizedName(l10n),
            onSelect: (v) {
              cubit.setControlSize(v);
              onChanged?.call('control_size', v.name);
            },
          ),
        ],
        // Position only applies to the four-way pad; the turn buttons hold
        // both corners by design and the stick floats.
        if (dPad) ...[
          label(l10n.settingsDPadPosition),
          SettingsOptionStrip<DPadPosition>(
            options: DPadPosition.values,
            selected: s.dPadPosition,
            labelOf: (pos) => pos.localizedName(l10n),
            onSelect: (pos) {
              cubit.updateDPadPosition(pos);
              onChanged?.call('dpad_position', pos.name);
            },
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }
}
