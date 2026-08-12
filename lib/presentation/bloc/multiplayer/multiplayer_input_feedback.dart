import 'dart:async';

import 'package:snake_classic/models/input_result.dart';
import 'package:snake_classic/services/haptic_service.dart';

/// Which cue, if any, one input earns.
///
/// Three results, three distinct outcomes, and no overlap between them. The
/// enum exists so "rejected must never look accepted" is something a test can
/// state rather than something a reader has to infer from two screens.
enum InputCue {
  /// Nothing at all. The match was never in a position to receive the input,
  /// so there is nothing to tell the player about.
  none,

  /// One light impact, plus the screen's directional echo.
  accepted,

  /// A double click and a red flash. Distinct in shape from accepted, so the
  /// two are distinguishable without looking at the screen.
  rejected,
}

/// The single owner of local input feedback in multiplayer.
///
/// Every haptic for a steering input goes through here. Not the swipe
/// detector, not the D-pad, not the screen's swipe handler — all three of
/// those used to fire their own, which is how an accepted turn came to buzz
/// twice while a refused one buzzed once and animated success.
class MultiplayerInputFeedback {
  const MultiplayerInputFeedback(this._haptics);

  final HapticService _haptics;

  /// Gap between the two clicks of a refusal. Long enough to be felt as two
  /// events rather than one longer buzz.
  static const Duration rejectionGap = Duration(milliseconds: 80);

  static InputCue cueFor(InputResult result) {
    switch (result) {
      case InputResult.accepted:
        return InputCue.accepted;
      case InputResult.rejected:
        return InputCue.rejected;
      case InputResult.ignored:
        return InputCue.none;
    }
  }

  /// Play the cue for [result]. Local and immediate — nothing here waits on
  /// the server, because nothing here is a claim about what the server did.
  void play(InputResult result) {
    switch (cueFor(result)) {
      case InputCue.none:
        return;
      case InputCue.accepted:
        _haptics.lightImpact();
      case InputCue.rejected:
        _haptics.selectionClick();
        Timer(rejectionGap, _haptics.selectionClick);
    }
  }
}
