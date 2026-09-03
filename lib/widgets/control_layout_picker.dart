import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';

/// D-Pad / Turn Buttons / Joystick, as three equal cards in a row.
///
/// Lives in its own widget so it can be tested where it is actually used:
/// inside a scroll view, with no bounded height. That is the case that
/// broke in 6.4.0 — the option row asked its children to stretch on the
/// cross axis, which inside a scroll view means "to infinity", and the
/// whole settings screen failed to lay out. Equal card heights now come
/// from [IntrinsicHeight], which measures rather than assumes.
class ControlLayoutPicker extends StatelessWidget {
  const ControlLayoutPicker({
    super.key,
    required this.theme,
    required this.selected,
    required this.onSelect,
  });

  final GameTheme theme;
  final ControlLayout selected;
  final ValueChanged<ControlLayout> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.videogame_asset_outlined,
              color: theme.accentColor.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.settingsControlLayout,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
          ),
          // IntrinsicHeight gives the three cards one height without asking
          // the parent for one — safe inside an unbounded scroll view.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Option(
                  theme: theme,
                  layout: ControlLayout.dPad,
                  isSelected: selected == ControlLayout.dPad,
                  icon: Icons.gamepad_outlined,
                  title: l10n.settingsControlLayoutDPad,
                  description: l10n.settingsControlLayoutDPadDesc,
                  onSelect: onSelect,
                ),
                _Option(
                  theme: theme,
                  layout: ControlLayout.turnButtons,
                  isSelected: selected == ControlLayout.turnButtons,
                  icon: Icons.turn_left_rounded,
                  title: l10n.settingsControlLayoutTurn,
                  description: l10n.settingsControlLayoutTurnDesc,
                  onSelect: onSelect,
                ),
                _Option(
                  theme: theme,
                  layout: ControlLayout.joystick,
                  isSelected: selected == ControlLayout.joystick,
                  icon: Icons.control_camera_rounded,
                  title: l10n.settingsControlLayoutStick,
                  description: l10n.settingsControlLayoutStickDesc,
                  onSelect: onSelect,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.theme,
    required this.layout,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onSelect,
  });

  final GameTheme theme;
  final ControlLayout layout;
  final bool isSelected;
  final IconData icon;
  final String title;
  final String description;
  final ValueChanged<ControlLayout> onSelect;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: title,
        child: GestureDetector(
          onTap: () => onSelect(layout),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.accentColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: theme.accentColor, width: 1.5)
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: theme.accentColor.withValues(
                    alpha: isSelected ? 1.0 : 0.7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.accentColor.withValues(
                      alpha: isSelected ? 1.0 : 0.8,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
