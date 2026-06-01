/// Compile-time / static feature flags used to gate in-progress work.
///
/// These are intentionally simple `const` booleans (not remote config) so the
/// Dart compiler can tree-shake the disabled path out of release builds.
class FeatureFlags {
  FeatureFlags._();

  /// Renders gameplay (single-player + multiplayer) with the Flame engine
  /// instead of the legacy `CustomPainter` widgets ([GameBoard] /
  /// [MultiplayerGameAdapter]).
  ///
  /// Now defaults to **Flame**. The legacy renderer is intentionally retained
  /// behind this flag as a production rollback path: the Flame board reuses the
  /// legacy painters for pixel-parity, so flipping this to `false` instantly
  /// restores the previous renderer if a regression surfaces in the field.
  /// Once the Flame path has been validated on-device across the QA matrix,
  /// the legacy widget call sites can be removed and this flag retired.
  ///
  /// Kept non-`const` so both render paths stay reachable for the fallback.
  static bool useFlameBoard = true;
}
