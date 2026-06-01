/// Compile-time / static feature flags used to gate in-progress work.
///
/// These are intentionally simple `const` booleans (not remote config) so the
/// Dart compiler can tree-shake the disabled path out of release builds.
class FeatureFlags {
  FeatureFlags._();

  /// Renders the gameplay board with the new Flame engine instead of the
  /// legacy `CustomPainter`-based [GameBoard]. Kept `false` while the Flame
  /// migration is reaching visual/behavioural parity; flipped on once the
  /// Flame board matches the legacy renderer across every theme/skin/trail.
  ///
  /// See the migration plan: extract pure simulation -> FlameGame skeleton ->
  /// port visuals -> wire input/overlays -> multiplayer -> delete legacy.
  ///
  /// Non-`const` during the migration so both render paths stay reachable (a
  /// `const false` would make the Flame branch dead code). Flip to a `const`
  /// in the final phase once the legacy renderer is deleted, restoring
  /// tree-shaking of the unused path.
  static bool useFlameBoard = false;
}
