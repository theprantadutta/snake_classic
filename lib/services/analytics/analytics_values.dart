/// Fixed property values for the onboarding/discovery events.
///
/// Analytics properties have to stay low-cardinality to be worth anything —
/// a free-form string per call site becomes a dimension nobody can group by.
/// These are the complete sets; anything not here is not a valid value.
abstract class TutorialEntryPoint {
  /// Opened from the pause menu mid-run — usually curiosity.
  static const String pause = 'pause';

  /// Opened from Settings → Replay Tutorial — a deliberate request to be
  /// taught, which is a different intent and worth separating.
  static const String settingsReplay = 'settings_replay';
}

abstract class LobbyEntryPoint {
  /// The new Home Versus call to action. Whether this is what brings people
  /// to multiplayer is the question the CTA exists to answer.
  static const String homeVersus = 'home_versus';

  /// The Versus tile in the Home nav grid, which was the only way in before.
  static const String navTile = 'nav_tile';
}

abstract class OnboardingStage {
  /// Still inside the first-run window (fewer than three games started).
  static const String onboarding = 'onboarding';

  /// Through it.
  static const String established = 'established';
}

/// Content version of the Home coach-mark tour.
///
/// Bumped when the steps change, so a re-cut tour's completion rate is not
/// silently compared against a different tour's. Version 2 is the three-step
/// cut (Versus, Daily Challenges, Help) that replaced the seven-step tour of
/// the whole metagame.
const int kHomeTourVersion = 2;
