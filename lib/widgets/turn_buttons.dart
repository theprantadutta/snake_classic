import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// Two-button relative steering: TURN LEFT in the bottom-left corner, TURN
/// RIGHT in the bottom-right, each measured from where the snake is heading.
///
/// This exists because the four-way pad asks a lot of a thumb on a tall
/// phone: reach to the middle of the screen, aim at one of four arms, all
/// while looking somewhere else. Two corners is where both thumbs already
/// rest, the targets are the size of the corners themselves, and there is
/// nothing to aim — you press the side you want to turn toward. Relative
/// turns also cannot be reversals, so the one input the game has to refuse
/// on the pad (straight back into your own neck) simply cannot be made here.
///
/// Presses go through a raw [Listener] for the same reason the d-pad's do:
/// a GestureDetector holds a tap back until the gesture arena settles, and
/// a steering control cannot afford that.
class TurnButtons extends StatelessWidget {
  const TurnButtons({
    super.key,
    required this.onTurn,
    required this.theme,
    required this.height,
    this.centre,
    this.opacity = 0.8,
  });

  final void Function(RelativeTurn) onTurn;
  final GameTheme theme;

  /// Height of both buttons — the control bar's full height, so the target
  /// is as tall as the bar.
  final double height;

  /// Whatever the bar wants between the buttons (the readouts).
  final Widget? centre;

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _TurnButton(
            turn: RelativeTurn.left,
            icon: Icons.turn_left_rounded,
            label: l10n.gameTurnLeft,
            theme: theme,
            height: height,
            opacity: opacity,
            onTurn: onTurn,
          ),
        ),
        if (centre != null)
          Expanded(flex: 3, child: Center(child: centre))
        else
          const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: _TurnButton(
            turn: RelativeTurn.right,
            icon: Icons.turn_right_rounded,
            label: l10n.gameTurnRight,
            theme: theme,
            height: height,
            opacity: opacity,
            onTurn: onTurn,
          ),
        ),
      ],
    );
  }
}

class _TurnButton extends StatefulWidget {
  const _TurnButton({
    required this.turn,
    required this.icon,
    required this.label,
    required this.theme,
    required this.height,
    required this.opacity,
    required this.onTurn,
  });

  final RelativeTurn turn;
  final IconData icon;
  final String label;
  final GameTheme theme;
  final double height;
  final double opacity;
  final void Function(RelativeTurn) onTurn;

  @override
  State<_TurnButton> createState() => _TurnButtonState();
}

class _TurnButtonState extends State<_TurnButton> {
  bool _pressed = false;
  int? _activePointer;

  void _down(PointerDownEvent event) {
    // A second finger on the same button while the first is held is not a
    // second turn — the button is already down. Latest pointer owns the
    // release so lifting the first finger does not un-press it.
    final firstPress = _activePointer == null;
    _activePointer = event.pointer;
    if (!_pressed) setState(() => _pressed = true);
    if (firstPress) widget.onTurn(widget.turn);
  }

  void _end(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    _activePointer = null;
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final opacity = widget.opacity;
    return Semantics(
      button: true,
      label: widget.label,
      onTap: () => widget.onTurn(widget.turn),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerUp: _end,
        onPointerCancel: _end,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: widget.height,
          decoration: BoxDecoration(
            color: _pressed
                ? theme.accentColor.withValues(alpha: opacity * 0.5)
                : theme.accentColor.withValues(alpha: opacity * 0.16),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.accentColor.withValues(
                alpha: _pressed ? opacity * 0.9 : opacity * 0.45,
              ),
              width: _pressed ? 2 : 1.2,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: widget.height * 0.42,
                      color: theme.accentColor.withValues(
                        alpha: _pressed ? opacity : opacity * 0.85,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        color: theme.accentColor.withValues(
                          alpha: opacity * 0.85,
                        ),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [TurnButtons] as they appear in a control bar: honest about whether they
/// can be used, the same contract as SteerableDPad. Dimmed, pointer-blind
/// and reported disabled to assistive tech, all from one flag.
class SteerableTurnButtons extends StatelessWidget {
  const SteerableTurnButtons({
    super.key,
    required this.onTurn,
    required this.theme,
    required this.height,
    required this.canSteer,
    this.centre,
  });

  final void Function(RelativeTurn) onTurn;
  final GameTheme theme;
  final double height;
  final bool canSteer;
  final Widget? centre;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: canSteer ? 1.0 : 0.45,
      child: IgnorePointer(
        ignoring: !canSteer,
        child: Semantics(
          container: true,
          label: AppLocalizations.of(context)!.gameTurnControls,
          enabled: canSteer,
          child: TurnButtons(
            onTurn: onTurn,
            theme: theme,
            height: height,
            centre: centre,
          ),
        ),
      ),
    );
  }
}
