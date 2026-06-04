/// Compile-time / static feature flags used to gate in-progress work.
///
/// These are intentionally simple `const` booleans (not remote config) so the
/// Dart compiler can tree-shake the disabled path out of release builds.
class FeatureFlags {
  FeatureFlags._();

  // Future feature flags can be added here.
}
