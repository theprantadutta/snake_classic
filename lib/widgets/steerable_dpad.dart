import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';

/// The D-pad as it appears in a control bar: sized, labelled, and honest
/// about whether it can be used.
///
/// [canSteer] is the whole point. Single-player already dimmed the control
/// when the game was not running; multiplayer rendered it fully interactive
/// to a dead or reconnecting player whose every press the cubit then dropped.
/// A control that reacts to input it will discard is worse than one that
/// plainly says it is unavailable, so the two states are bound together here:
/// dimmed, pointer-blind, and reported as disabled to assistive tech, all
/// from one flag, in the one widget both modes use.
class SteerableDPad extends StatelessWidget {
  const SteerableDPad({
    super.key,
    required this.onDirection,
    required this.theme,
    required this.size,
    required this.canSteer,
  });

  final void Function(Direction) onDirection;
  final GameTheme theme;
  final double size;
  final bool canSteer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: size,
        height: size,
        child: Opacity(
          opacity: canSteer ? 1.0 : 0.45,
          child: IgnorePointer(
            ignoring: !canSteer,
            child: Semantics(
              container: true,
              label: AppLocalizations.of(context)!.gameDirectionalPad,
              enabled: canSteer,
              child: DPadControls(
                onDirection: onDirection,
                theme: theme,
                opacity: 0.8,
                size: size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
