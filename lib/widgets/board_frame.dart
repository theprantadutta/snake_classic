import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/utils/constants.dart';

/// The wall around the play area (Living Board, DESIGN_SPEC §5): a single
/// hairline in the palette's wall colour, gold in tournaments. The level
/// cells above the board (see the gameplay HUD) read as its top wall.
class BoardFrame extends StatelessWidget {
  const BoardFrame({
    super.key,
    required this.theme,
    required this.child,
    this.tournament = false,
  });

  final GameTheme theme;
  final Widget child;

  /// Tournament runs get a gold wall so ranked play is unmistakable.
  final bool tournament;

  @override
  Widget build(BuildContext context) {
    final palette = LBPalette.of(theme);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(
          color: tournament ? LB.goldStroke : palette.wall,
          width: 1,
        ),
      ),
      child: ClipRect(child: child),
    );
  }
}
