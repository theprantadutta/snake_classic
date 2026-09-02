import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';

/// The one frame every playfield wears: a hairline in the theme accent, a
/// soft accent glow, and the HUD corner brackets the rest of the game's
/// chrome uses.
///
/// Single-player and multiplayer boards both go through here so they read as
/// the same object. The multiplayer board used to carry its own purple/gold
/// frame with a four-pixel border, which — next to the single-player board —
/// looked like a different app had wandered in. Tournament runs keep their
/// purple, deliberately: that is the one place the colour means something.
///
/// Sizes to its child. Hand it a square if the board is square — the frame
/// draws nothing of its own inside, so any slack becomes visible dead space.
class BoardFrame extends StatelessWidget {
  const BoardFrame({
    super.key,
    required this.theme,
    required this.child,
    this.tournament = false,
  });

  final GameTheme theme;
  final Widget child;

  /// Purple treatment for tournament play. Everything else gets the accent.
  final bool tournament;

  @override
  Widget build(BuildContext context) {
    final lineColor = tournament ? Colors.purple : theme.accentColor;
    return HudCorners(
      color: lineColor,
      inset: 4,
      arm: 16,
      clipBehavior: Clip.none,
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          border: Border.all(
            color: tournament
                ? Colors.purple.withValues(alpha: 0.55)
                : theme.accentColor.withValues(alpha: 0.35),
            width: tournament ? 2.0 : 1.5,
          ),
          borderRadius: BorderRadius.circular(0),
          boxShadow: tournament
              ? [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.22),
                    blurRadius: 18,
                  ),
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.12),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.16),
                    blurRadius: 18,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: child,
        ),
      ),
    );
  }
}
