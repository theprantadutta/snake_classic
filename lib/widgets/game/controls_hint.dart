import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// "Swipe to turn" over the board during a player's first games, until
/// their first accepted turn (retention plan 2026-11, B4). The only cue
/// before was the small compass under the board, so a new player who
/// expected taps or arrows died with no idea why.
///
/// Purely visual: it ignores pointers, so the swipe that answers it reaches
/// the board. The caller decides when it shows ([GameCubit.showControlsHint]).
class ControlsHint extends StatefulWidget {
  const ControlsHint({super.key, required this.controlScheme});

  /// `swipe`, `dpad`, `turn_buttons` or `joystick`.
  final String controlScheme;

  @override
  State<ControlsHint> createState() => _ControlsHintState();
}

class _ControlsHintState extends State<ControlsHint>
    with SingleTickerProviderStateMixin {
  // A gentle pulse so it reads as an instruction, not a static label.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final text = switch (widget.controlScheme) {
      'swipe' => l10n.controlsHintSwipe,
      'turn_buttons' => l10n.controlsHintTurn,
      _ => l10n.controlsHintButtons,
    };
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -.25),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 320),
          builder: (context, appear, child) =>
              Opacity(opacity: appear, child: child),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Opacity(
              opacity: reduceMotion ? 1 : .72 + .28 * _pulse.value,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: p.blockFill.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: p.lime.withValues(alpha: .55)),
              ),
              child: Text(
                text.toUpperCase(),
                textAlign: TextAlign.center,
                style: LBText.button(p, color: p.lime, size: 13)
                    .copyWith(letterSpacing: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
