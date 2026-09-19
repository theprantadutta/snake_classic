#!/usr/bin/env bash
#
# Build the Play release bundle AND upload its debug symbols to Sentry.
#
# The two halves belong in one script because doing only the first half is
# silent. 6.6.0+56 shipped that way: built without --obfuscate and
# --split-debug-info, no `dart run sentry_dart_plugin` afterwards, and the
# first crash to arrive from Play (SNAKE-CLASSIC-FLUTTER-2, a SIGSEGV) had
# `<unknown>` where our frames should have been. Nothing failed, nothing
# warned — the build succeeded, the upload simply never happened, and the
# consequence only showed up once a crash needed reading.
#
# Usage:
#   export SENTRY_AUTH_TOKEN=...          # project:releases scope
#   ./tools/release_android.sh            # appbundle, the Play artifact
#   ./tools/release_android.sh apk        # apk, for sideload testing
#
# Symbols are matched to the build by the release identifier, which
# sentry_flutter derives from pubspec.yaml as
# com.pranta.snakeclassic@<version>+<build>. That is why nothing here sets
# `release` by hand, and why bumping the version AFTER building would break
# the match.

set -euo pipefail

cd "$(dirname "$0")/.."

TARGET="${1:-appbundle}"
case "$TARGET" in
  appbundle|apk) ;;
  *) echo "error: target must be 'appbundle' or 'apk', got '$TARGET'" >&2; exit 2 ;;
esac

VERSION="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"
echo "==> Building $TARGET for $VERSION"

# --obfuscate makes release Dart frames unreadable on purpose; the map that
# undoes it is what gets uploaded below. --split-debug-info writes the ELF
# debug data out of the binary (so the shipped app stays small) and into
# build/debug-info, which is the directory sentry_dart_plugin reads.
flutter build "$TARGET" \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json

if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  cat >&2 <<'MSG'

  ========================================================================
  BUILD OK, SYMBOLS NOT UPLOADED

  SENTRY_AUTH_TOKEN is not set, so `dart run sentry_dart_plugin` was
  skipped. The artifact is fine and installable, but every crash it
  reports will have unreadable frames.

  Do NOT upload this build to Play until you have run:

      export SENTRY_AUTH_TOKEN=...
      dart run sentry_dart_plugin

  from this directory, against THIS build output. Rebuilding later
  produces a different binary and the symbols will no longer match.
  ========================================================================

MSG
  exit 1
fi

echo "==> Uploading debug symbols for $VERSION"
dart run sentry_dart_plugin

echo
echo "==> Done. Artifact:"
if [[ "$TARGET" == "appbundle" ]]; then
  echo "    build/app/outputs/bundle/release/app-release.aab"
else
  echo "    build/app/outputs/flutter-apk/app-release.apk"
fi
echo
echo "    Symbols uploaded for release com.pranta.snakeclassic@$VERSION"
echo "    Verify at https://pranta-corp.sentry.io/settings/projects/snake-classic-flutter/debug-symbols/"
