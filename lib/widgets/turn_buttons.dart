import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';

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
            label: l10n.gameTurnLeft,
            caption: l10n.lbTurnLeft,
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
            label: l10n.gameTurnRight,
            caption: l10n.lbTurnRight,
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
    required this.label,
    required this.caption,
    required this.theme,
    required this.height,
    required this.opacity,
    required this.onTurn,
  });

  final RelativeTurn turn;

  /// What assistive tech hears ("Turn left").
  final String label;

  /// What the button shows (TURN LEFT).
  final String caption;
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
    final p = context.lb;
    // Ink strength follows the bar's opacity; a press always lights fully.
    final strength = _pressed ? 1.0 : (0.55 + 0.45 * widget.opacity).clamp(0.0, 1.0);
    final fg = p.lime.withValues(alpha: strength);
    return Semantics(
      button: true,
      label: widget.label,
      onTap: () => widget.onTurn(widget.turn),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerUp: _end,
        onPointerCancel: _end,
        child: ExcludeSemantics(
          child: AnimatedScale(
            scale: _pressed ? .97 : 1,
            duration: LB.tap,
            curve: Curves.easeOut,
            // An outline block that lights to the selected stroke while held.
            // Visual only: the Listener above owns every press.
            child: LBBlock(
              height: widget.height - LB.inset * 2,
              selected: _pressed,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LBTurnGlyph(
                      left: widget.turn == RelativeTurn.left,
                      cell: (widget.height * .075).clamp(3.0, 6.0),
                      color: fg,
                    ),
                    SizedBox(height: (widget.height * .1).clamp(6.0, 14.0)),
                    Text(
                      widget.caption,
                      maxLines: 1,
                      style: LBText.button(p, color: p.head.withValues(alpha: strength), size: 12)
                          .copyWith(letterSpacing: 2.6),
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
