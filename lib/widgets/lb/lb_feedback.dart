import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';

/// UI tap/back feedback for Living Board controls (DESIGN_SPEC §6:
/// light haptic + `ui_tap` / `ui_back`). Both services honour the user's
/// haptics and sound settings, so callers never check them.
abstract class LBFeedback {
  static void tap() {
    HapticService().lightImpact();
    AudioService().playSound('ui_tap', volume: .5);
  }

  static void back() {
    HapticService().lightImpact();
    AudioService().playSound('ui_back', volume: .5);
  }
}
