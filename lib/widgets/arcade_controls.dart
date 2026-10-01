import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';

/// The controls the options panels are built from.
///
/// Living Board versions of the settings controls: the two-cell switch, a
/// selectable outline block and a link row with a pixel icon. Same
/// semantics and hit targets as before; only the drawing changed.
///
/// Both route their feedback through [HapticService] rather than
/// `HapticFeedback` directly, so the app's vibration setting actually
/// silences them.

/// A labelled toggle: title, optional description, and a throw switch.
///
/// The whole row is the hit target, not just the switch — a 44pt square at the
/// end of a line is a worse target than the line itself, and on a settings
/// screen the label is what people aim at anyway.
class ArcadeSwitchTile extends StatelessWidget {
  const ArcadeSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.theme,
    this.description,
    this.enabled = true,
    this.icon,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final GameTheme theme;
  final String? description;

  /// False greys the row out and swallows taps — for a control the hardware
  /// cannot honour, where hiding it would be more confusing than showing it
  /// unavailable.
  final bool enabled;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    void toggle() {
      if (!enabled) return;
      HapticService().selectionClick();
      onChanged(!value);
    }

    // One semantics node for the whole row. Without excludeSemantics the
    // label, the description and the switch each announce separately, and the
    // switch announces without a name. `onTap` has to be here for the same
    // reason it does on GameCircleButton: excluding the subtree removes the
    // gesture's semantics with it, leaving a control assistive tech can see
    // but cannot press.
    return Semantics(
      label: description == null ? title : '$title. $description',
      toggled: value,
      enabled: enabled,
      onTap: enabled ? toggle : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? toggle : null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * scale, horizontal: 2),
            child: Builder(
              builder: (context) {
                final p = context.lb;
                return Row(
                  children: [
                    if (icon != null) ...[
                      LBMappedIcon(icon!, cell: 3.2 * scale, color: p.lime.withValues(alpha: .8)),
                      SizedBox(width: 12 * scale),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: LBText.button(p, color: p.head, size: 12.5),
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 3),
                            Text(description!, style: LBText.body(p, size: 11)),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    LBSwitchFace(value: value, cell: 16 * scale, enabled: enabled),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// One choice in a set of them — difficulty, board size, D-pad position.
///
/// Selected is not a colour change alone: the chip gains a bracket-weight
/// border, an accent wash and a glow, so which one is live survives being
/// looked at quickly on a bright theme.
class ArcadeOptionChip extends StatelessWidget {
  const ArcadeOptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.theme,
    this.onTap,
    this.sublabel,
    this.leading,
  });

  final String label;
  final bool selected;
  final GameTheme theme;

  /// Null disables the chip — used while a game is in progress and the
  /// setting cannot be changed underneath it.
  final VoidCallback? onTap;

  final String? sublabel;

  /// An emoji or glyph shown before the label. Several of these sets already
  /// carry one on the model (difficulty, game mode).
  final String? leading;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final disabled = onTap == null;

    return Semantics(
      label: sublabel == null ? label : '$label. $sublabel',
      selected: selected,
      button: true,
      enabled: !disabled,
      onTap: onTap,
      excludeSemantics: true,
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: GestureDetector(
          onTap: onTap == null
              ? null
              : () {
                  HapticService().selectionClick();
                  onTap!();
                },
          child: Builder(
            builder: (context) {
              final p = context.lb;
              return LBBlock(
                selected: selected,
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 10 * scale,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      leading == null ? label : '$leading $label',
                      textAlign: TextAlign.center,
                      style: LBText.button(p, color: selected ? p.head : p.ink.withValues(alpha: .82), size: 12.5),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        sublabel!,
                        textAlign: TextAlign.center,
                        style: LBText.body(p, color: p.inkDim, size: 10.5),
                      ),
                    ],
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

/// A row that opens something else: legal documents, the cosmetics picker,
/// purchase history. Icon chip, label, chevron.
class ArcadeLinkTile extends StatelessWidget {
  const ArcadeLinkTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.theme,
    this.description,
    this.tint,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final GameTheme theme;
  final String? description;

  /// Overrides the accent, for rows that mean something other than "go" —
  /// gold for rewards, red for destructive.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Semantics(
      label: description == null ? label : '$label. $description',
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticService().selectionClick();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9 * scale, horizontal: 2),
          child: Builder(
            builder: (context) {
              final p = context.lb;
              final color = tint ?? p.lime;
              return Row(
                children: [
                  Container(
                    width: 32 * scale,
                    height: 32 * scale,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(LB.blockRadius),
                    ),
                    child: LBMappedIcon(icon, cell: 3 * scale, color: color),
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: LBText.button(p, color: tint ?? p.head, size: 12.5),
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 3),
                          Text(description!, style: LBText.body(p, size: 11)),
                        ],
                      ],
                    ),
                  ),
                  // Chosen from the text direction: in Arabic the chevron
                  // must point the way you are going, not back.
                  LBPixelIcon(
                    Directionality.of(context) == TextDirection.rtl ? LBIcon.back : LBIcon.next,
                    cell: 2.6 * scale,
                    color: p.inkDim,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
