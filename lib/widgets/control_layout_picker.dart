import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';

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
    final p = context.lb;
    final options = [
      (
        ControlLayout.dPad,
        const LBPixelIcon(LBIcon.plus, cell: 4) as Widget,
        l10n.settingsControlLayoutDPad,
        l10n.settingsControlLayoutDPadDesc,
      ),
      (
        ControlLayout.turnButtons,
        const LBTurnGlyph(left: true, cell: 4) as Widget,
        l10n.settingsControlLayoutTurn,
        l10n.settingsControlLayoutTurnDesc,
      ),
      (
        ControlLayout.joystick,
        const LBPixelIcon(LBIcon.target, cell: 4) as Widget,
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
            LBPixelIcon(LBIcon.grid, cell: 3, color: p.lime),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                l10n.settingsControlLayout.toUpperCase(),
                style: LBText.label(p, color: p.inkMuted).copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < options.length; i++)
          _OptionRow(
            layout: options[i].$1,
            icon: options[i].$2,
            title: options[i].$3,
            description: options[i].$4,
            isSelected: selected == options[i].$1,
            onSelect: onSelect,
          ),
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.layout,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onSelect,
  });

  final ControlLayout layout;
  final Widget icon;
  final String title;
  final String description;
  final bool isSelected;
  final ValueChanged<ControlLayout> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = isSelected ? p.head : p.ink;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(layout),
        child: LBBlock(
          selected: isSelected,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: isSelected ? p.lime : p.lime.withValues(alpha: .6)),
                    child: icon,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LBText.button(p, color: fg, size: 13).copyWith(letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 3),
                    Text(description, style: LBText.body(p, size: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Radio mark: one cell, lit when chosen.
              ExcludeSemantics(
                child: LBCellsBar(count: 1, value: isSelected ? 1 : 0, cell: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
