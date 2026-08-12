import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';

/// A round icon control on a gameplay surface, labelled and big enough to hit.
///
/// The multiplayer exit was an 18dp icon in 8dp of padding: about a 34dp
/// target, unlabelled, on the one button that abandons a live match. The
/// drawn circle keeps that size — it is deliberately unobtrusive next to the
/// board — while the pressable and screen-reader-focusable area is at least
/// 48dp.
class GameCircleButton extends StatelessWidget {
  const GameCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.theme,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final GameTheme theme;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    // The action has to sit on this node. excludeSemantics removes the
    // InkWell's semantics along with the rest of the subtree, so a label and
    // a button role without onTap describe a control assistive tech cannot
    // press — on the button that leaves a live match.
    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: theme.backgroundColor.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: context.scaled(48),
              minHeight: context.scaled(48),
            ),
            child: Center(
              child: Icon(
                icon,
                color: theme.accentColor,
                size: context.scaled(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
