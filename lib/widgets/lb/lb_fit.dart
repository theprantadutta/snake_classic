import 'package:material_ui/material_ui.dart';

/// Lays [child] out at the full available width and natural height, then
/// shrinks it uniformly if that height does not fit.
///
/// For text inside fixed-size grid blocks (Home tiles, PLAY, the CONTINUE
/// block): at ordinary text sizes it is a no-op, and at large accessibility
/// sizes the block's content gets smaller instead of overflowing the block.
/// Body copy in scrolling screens should wrap instead; use this only where
/// the block's size is fixed by the grid.
class LBFitHeight extends StatelessWidget {
  const LBFitHeight({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: SizedBox(
            width: box.maxWidth.isFinite ? box.maxWidth : null,
            child: child,
          ),
        ),
      );
}
