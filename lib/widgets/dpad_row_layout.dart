import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// Places the D-pad within the lower control row according to the player's
/// saved [DPadPosition].
///
/// Both gameplay screens had the same three-slot row — a D-pad flanked by two
/// readouts — and both ignored the setting in the same way. Doing the reorder
/// in one place means the two modes cannot drift apart again, and it gives the
/// placement rule somewhere to be tested without standing up a whole screen.
///
/// The D-pad keeps its intrinsic width in every arrangement and the flanking
/// slots expand, so moving it left or right reorders the row without resizing
/// the control or disturbing the board above.
class DPadRowLayout {
  const DPadRowLayout._();

  /// Build the row.
  ///
  /// [leading] and [trailing] receive the alignment their slot should use:
  /// the readouts are pushed away from the D-pad, so a left-hand D-pad gets
  /// both of them right-aligned and a centred one gets them at the outer
  /// edges. That keeps the control's neighbours from crowding it.
  static Widget build({
    required DPadPosition position,
    required Widget dPad,
    required Widget Function(Alignment alignment) leading,
    required Widget Function(Alignment alignment) trailing,
  }) {
    switch (position) {
      case DPadPosition.bottomLeft:
        return _row([
          dPad,
          Expanded(child: leading(Alignment.centerRight)),
          Expanded(child: trailing(Alignment.centerRight)),
        ]);
      case DPadPosition.bottomRight:
        return _row([
          Expanded(child: leading(Alignment.centerLeft)),
          Expanded(child: trailing(Alignment.centerLeft)),
          dPad,
        ]);
      case DPadPosition.bottomCenter:
        return _row([
          Expanded(child: leading(Alignment.centerLeft)),
          dPad,
          Expanded(child: trailing(Alignment.centerRight)),
        ]);
    }
  }

  static Widget _row(List<Widget> children) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: children,
  );
}
