import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';

/// The controls the options panels are built from.
///
/// A Material [Switch] and a plain bordered box are what made the settings
/// screen read as a phone settings screen. These are the same two controls
/// with the same semantics and a different physical metaphor: a switch you
/// can see the throw of, and a selection that lights up.
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
        child: InkWell(
          onTap: enabled ? toggle : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 9 * scale, horizontal: 2),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 17 * scale,
                    color: theme.accentColor.withValues(alpha: 0.75),
                  ),
                  SizedBox(width: 10 * scale),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GameTypography.bodyLarge(color: Colors.white)
                            .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          description!,
                          style: GameTypography.bodySmall(
                            color: Colors.white.withValues(alpha: 0.55),
                          ).copyWith(fontSize: 12.5, height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 12 * scale),
                _ThrowSwitch(value: value, theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The switch itself. Chunky, with a lit track and a knob that carries a core.
class _ThrowSwitch extends StatelessWidget {
  const _ThrowSwitch({required this.value, required this.theme});

  final bool value;
  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final w = 52.0 * scale;
    final h = 28.0 * scale;
    final knob = h - 8;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: w,
      height: h,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value
            ? theme.accentColor.withValues(alpha: 0.28)
            : Colors.black.withValues(alpha: 0.34),
        border: Border.all(
          color: value
              ? theme.accentColor
              : Colors.white.withValues(alpha: 0.22),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(h / 2),
        boxShadow: value
            ? [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        // Directional, so the throw runs label-to-edge in Arabic too.
        alignment: value
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: knob,
          height: knob,
          decoration: BoxDecoration(
            color: value
                ? theme.accentColor
                : Colors.white.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: knob * 0.34,
              height: knob * 0.34,
              decoration: BoxDecoration(
                // A darker core rather than a lighter one: on the bright
                // themes (crystal, desert) a white pip on a white knob
                // disappears entirely.
                color: Colors.black.withValues(alpha: value ? 0.45 : 0.28),
                shape: BoxShape.circle,
              ),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 10 * scale,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? theme.accentColor.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: selected
                    ? theme.accentColor
                    : theme.accentColor.withValues(alpha: 0.28),
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.30),
                        blurRadius: 12,
                        spreadRadius: -3,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  leading == null ? label : '$leading $label',
                  textAlign: TextAlign.center,
                  style: GameTypography.bodyMedium(
                    color: selected
                        ? theme.accentColor
                        : Colors.white.withValues(alpha: 0.82),
                  ).copyWith(
                    fontSize: 13.5,
                    // Rajdhani ships no weight above 700. w700 is the ceiling
                    // here, not a preference.
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel!,
                    textAlign: TextAlign.center,
                    style: GameTypography.labelSmall(
                      color: Colors.white.withValues(alpha: 0.5),
                    ).copyWith(fontSize: 10.5),
                  ),
                ],
              ],
            ),
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
    final color = tint ?? theme.accentColor;

    return Semantics(
      label: description == null ? label : '$label. $description',
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          HapticService().selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9 * scale, horizontal: 2),
          child: Row(
            children: [
              Container(
                width: 32 * scale,
                height: 32 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16 * scale, color: color),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GameTypography.bodyLarge(color: Colors.white)
                          .copyWith(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: GameTypography.bodySmall(
                          color: Colors.white.withValues(alpha: 0.5),
                        ).copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                // Chosen from the text direction rather than left to the
                // Icon widget: Material's chevrons are not among the icons
                // Flutter auto-mirrors, so in Arabic the default would point
                // back the way you came.
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 20 * scale,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
