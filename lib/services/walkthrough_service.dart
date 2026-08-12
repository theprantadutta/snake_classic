import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing walkthrough/tutorial completion state
/// Uses SharedPreferences to persist walkthrough completion status
class WalkthroughService {
  static WalkthroughService? _instance;
  SharedPreferences? _prefs;

  WalkthroughService._internal();

  factory WalkthroughService() {
    _instance ??= WalkthroughService._internal();
    return _instance!;
  }

  /// Initialize the service with SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if SharedPreferences is initialized
  bool get isInitialized => _prefs != null;

  /// Check if a specific walkthrough has been completed
  bool isComplete(String id) {
    return _prefs?.getBool('${id}_walkthrough_complete') ?? false;
  }

  /// Mark a walkthrough as completed
  Future<void> markComplete(String id) async {
    await _prefs?.setBool('${id}_walkthrough_complete', true);
  }

  /// Reset a walkthrough to show again
  Future<void> reset(String id) async {
    await _prefs?.setBool('${id}_walkthrough_complete', false);
  }

  /// Reset all walkthroughs
  Future<void> resetAll() async {
    await reset(homeWalkthroughId);
    await reset(gameTutorialId);
  }

  // ==================== Walkthrough IDs ====================

  /// Home screen walkthrough ID
  static const String homeWalkthroughId = 'home';

  /// Game tutorial walkthrough ID
  static const String gameTutorialId = 'game_tutorial';

  // There was a third id here — 'control_choice' — describing a D-pad
  // versus gestures modal shown before the tutorial. That modal was removed
  // when the play-first path landed; the id was read by nothing and the
  // comment described a flow that no longer existed, which is worse than
  // no comment. Controls default to swipe and live in Settings → Controls.
}
