# Firebase Analytics — TEMPORARILY DISABLED

`firebase_analytics` has been removed from this project pending an upstream fix.
The `AnalyticsFacade` is still wired up and operational — it just falls back to
the `LoggerAnalyticsClient` (debug-console logging) so the rest of the app keeps
calling `analytics.trackX()` without modification.

**Nothing else changes.** Cubits, screens, and services all call the facade the
same way; only the underlying delivery to Firebase is paused.

---

## Why it's disabled

The latest `firebase_analytics` release has a known issue that blocks this
project. The package maintainers are tracking it; once a fixed version ships,
restore via the steps below.

When you come back to re-enable, first confirm the upstream issue is actually
resolved. Try the latest `firebase_analytics` version on pub.dev and skim the
package changelog / known-issues before restoring.

---

## Files touched when disabling (so you know what to revert)

1. **`pubspec.yaml`** — the `firebase_analytics: ^12.0.0` line is commented out.
2. **`analysis_options.yaml`** — `analyzer.exclude` was added to keep
   `lib/services/analytics/firebase_analytics_client.dart` out of `flutter
   analyze` while its import target is missing.
3. **`lib/core/di/injection.dart`** — the import of
   `firebase_analytics_client.dart` is commented out, and the `AnalyticsFacade`
   is registered with only `LoggerAnalyticsClient` (no `kDebugMode` gate while
   disabled).
4. **`lib/services/analytics/firebase_analytics_client.dart`** — left ENTIRELY
   UNTOUCHED on purpose. When the package returns, this file should compile
   as-is.

`pubspec.lock` and the generated `*PluginRegistrant.*` files regenerate on the
next `flutter pub get`, so no manual reverts there.

---

## Restoration steps

Do these in order. Run `flutter analyze` after step 5 to confirm clean.

### 1. `pubspec.yaml`

Replace the disabled block:

```yaml
  # TEMPORARILY DISABLED: firebase_analytics ^12.0.0 has an open upstream issue
  # blocking this project. Re-enable per ANALYTICS_DISABLED.md once fixed.
  # firebase_analytics: ^12.0.0
```

with the active line (bump to the latest fixed version — check pub.dev):

```yaml
  firebase_analytics: ^<latest-fixed-version>
```

### 2. `analysis_options.yaml`

Remove the entire `analyzer:` block that was added — it should look like:

```yaml
analyzer:
  exclude:
    # TEMPORARILY EXCLUDED: depends on firebase_analytics which is disabled
    # due to an upstream issue. See ANALYTICS_DISABLED.md for restoration.
    - lib/services/analytics/firebase_analytics_client.dart
```

Delete that whole block (lines added for this exclusion only). The
`include: package:flutter_lints/flutter.yaml` line above and the `linter:`
block below should remain.

### 3. `lib/core/di/injection.dart`

a) Uncomment the import at the top of the file:

```dart
import 'package:snake_classic/services/analytics/firebase_analytics_client.dart';
```

b) Re-add the `flutter/foundation.dart` import (needed for `kDebugMode`):

```dart
import 'package:flutter/foundation.dart';
```

c) Restore the original analytics registration so Firebase + (in debug)
the logger both run:

```dart
  // ==================== Analytics ====================
  getIt.registerLazySingleton<AnalyticsFacade>(() {
    return AnalyticsFacade([
      FirebaseAnalyticsClient(),
      if (kDebugMode) LoggerAnalyticsClient(),
    ]);
  });
```

Remove the "TEMPORARILY: only LoggerAnalyticsClient is wired in" comment.

### 4. Pull dependencies and regenerate plugin registrants

```bash
flutter pub get
```

This rewrites `pubspec.lock` and the `GeneratedPluginRegistrant.*` files for
each platform. Commit those alongside the source changes.

### 5. Verify

```bash
flutter analyze
```

Should report **no issues**. Then smoke-test the app and confirm analytics
events show up in the Firebase DebugView (Settings → Debug device required).

### 6. Delete this file

Once analytics is restored and verified, delete `ANALYTICS_DISABLED.md` —
it's only here to track the temporary state.

---

## Sanity checks while disabled

- `flutter analyze` should be clean. If you see errors about
  `firebase_analytics`, the exclude in `analysis_options.yaml` was either
  not applied or got reformatted.
- The app should build and run normally. Analytics-emitting code paths will
  just hit `LoggerAnalyticsClient.info(...)` lines in the debug console.
- No native code (Android `build.gradle*`, iOS `Podfile`, etc.) was touched
  by the disable. If a build error mentions Firebase Analytics native plugins,
  run `flutter clean && flutter pub get` to rebuild the generated registrants.
