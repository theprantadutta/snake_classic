import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';

/// D-Pad / Turn Buttons / Joystick, as a short list of selectable rows.
///
/// Rows, not columns. Three side-by-side cards on a phone leave each one
/// ~90dp wide, the descriptions wrap to five or six lines of differing
/// length, and the selected card towers over its neighbours — it read as
/// three unrelated boxes. A row gives every option the full width: icon,
/// title and a description that fits on one or two lines, with the choice
/// marked at the trailing edge like a radio group. It is also the shape the
/// switch tiles above and below it already have.
///
/// Lives in its own widget so it can be tested where it is used: inside a
/// scroll view, with no bounded height (the 6.4.0 layout failure).
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
    final options = [
      (
        ControlLayout.dPad,
        Icons.gamepad_outlined,
        l10n.settingsControlLayoutDPad,
        l10n.settingsControlLayoutDPadDesc,
      ),
      (
        ControlLayout.turnButtons,
        Icons.turn_left_rounded,
        l10n.settingsControlLayoutTurn,
        l10n.settingsControlLayoutTurnDesc,
      ),
      (
        ControlLayout.joystick,
        Icons.control_camera_rounded,
        l10n.settingsControlLayoutStick,
        l10n.settingsControlLayoutStickDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Same header treatment as the D-Pad Position block beneath it.
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
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _OptionRow(
            theme: theme,
            layout: options[i].$1,
            icon: options[i].$2,
            title: options[i].$3,
            description: options[i].$4,
            isSelected: selected == options[i].$1,
            onSelect: onSelect,
          ),
        ],
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.theme,
    required this.layout,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onSelect,
  });

  final GameTheme theme;
  final ControlLayout layout;
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final ValueChanged<ControlLayout> onSelect;

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(layout),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.14)
                : theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accent.withValues(alpha: isSelected ? 0.9 : 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon tile, same treatment as the section header's badge.
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isSelected ? 0.22 : 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: accent.withValues(alpha: isSelected ? 1.0 : 0.75),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? accent : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Radio mark: a ring, filled when chosen.
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: isSelected ? 1.0 : 0.4),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
