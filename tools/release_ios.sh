#!/usr/bin/env bash
#
# Build the App Store IPA AND upload its debug symbols to Sentry.
#
# The iOS twin of tools/release_android.sh. Builds an obfuscated IPA, then
# uploads the Dart debug companions and the dSYMs for THAT build, so a crash
# from it reads as file names and line numbers in Sentry.
#
# Symbols only match the binary they came from: upload the IPA this run
# produced, not one from an earlier run of the same version.
#
# Usage:
#   ./tools/release_ios.sh              # build + upload symbols
#   ./tools/release_ios.sh --force      # rebuild an already-released version
#   ./tools/release_ios.sh --no-upload  # build only, skip Sentry (do not ship it)
#
# The auth token is read from .sentry-auth-token (gitignored, repo root), or
# from SENTRY_AUTH_TOKEN if already exported.

set -euo pipefail

cd "$(dirname "$0")/.."

FORCE=0
UPLOAD=1
for arg in "$@"; do
  case "$arg" in
    --force)     FORCE=1 ;;
    --no-upload) UPLOAD=0 ;;
    *) echo "error: expected --force or --no-upload, got '$arg'" >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: iOS builds require macOS with Xcode. This is $(uname -s)." >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Same .env guard as the Android script — see there for the full reasoning.
# Short version: .env is a bundled Flutter asset, so anything in it ships
# inside the IPA and can be read by anyone who unzips the app.
# ---------------------------------------------------------------------------
if [[ -f .env ]] && grep -qE '^[[:space:]]*SENTRY_AUTH_TOKEN[[:space:]]*=[[:space:]]*[^[:space:]]' .env; then
  echo >&2
  echo "  REFUSING TO BUILD: SENTRY_AUTH_TOKEN is set in .env" >&2
  echo "  .env ships inside the app. Move it to .sentry-auth-token." >&2
  echo >&2
  exit 1
fi

TOKEN_FILE=".sentry-auth-token"
if [[ -z "${SENTRY_AUTH_TOKEN:-}" && -f "$TOKEN_FILE" ]]; then
  SENTRY_AUTH_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
  export SENTRY_AUTH_TOKEN
fi

# Fail now, not after a five minute build: an IPA without its symbols must
# not ship, and rebuilding later would not produce matching ones.
if [[ "$UPLOAD" == "1" && -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  echo >&2
  echo "  REFUSING TO BUILD: no Sentry auth token." >&2
  echo "  Put it in .sentry-auth-token (gitignored), or pass --no-upload." >&2
  echo >&2
  exit 1
fi

VERSION="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"

# ---------------------------------------------------------------------------
# Already-released guard.
#
# NOTE the shared-version wrinkle, which has no Android equivalent: iOS and
# Android are built from the SAME pubspec version, and Sentry's release
# identifier (com.pranta.snakeclassic@<version>) does not distinguish them.
# So shipping Android 6.6.1+57 first makes this check fire for the iOS build
# of the same version, which is a false positive.
#
# Left as-is rather than guessed at, because the right answer depends on how
# you actually ship: if the two platforms go out together on one version,
# pass --force for whichever you build second. If they diverge, they need
# separate version streams and this guard needs revisiting.
# ---------------------------------------------------------------------------
LEDGER=".released-versions-ios"
ALREADY_LOCAL=0
[[ -f "$LEDGER" ]] && grep -qxF "$VERSION" "$LEDGER" && ALREADY_LOCAL=1

if [[ "$ALREADY_LOCAL" == "1" && "$FORCE" != "1" ]]; then
  echo >&2
  echo "  REFUSING TO BUILD: iOS $VERSION has already been released from this machine." >&2
  echo "  Bump 'version:' in pubspec.yaml, or pass --force." >&2
  echo >&2
  exit 1
fi

echo "==> Building IPA for $VERSION"

# Nothing from an earlier run may survive into this one: a stale IPA could be
# mistaken for this build, and stale dSYMs or symbols would be uploaded for a
# binary that no longer exists. Android's .symbols files stay; they are valid
# for the Android build they came from.
rm -rf build/ios/archive build/ios/ipa
rm -f build/debug-info/app.ios-*.symbols

# gen_snapshot writes the obfuscation map but does not create its folder. Only
# an Android build creates build/app, so a fresh Mac fails without this.
mkdir -p build/app build/debug-info

# Same flags as Android: --obfuscate needs --split-debug-info, and the
# obfuscation map is written out separately.
#
# build/debug-info is SHARED with the Android script. That is deliberate —
# the Dart debug companions are per-ABI and iOS emits its own (arm64), so
# they coexist rather than overwrite. But it does mean a stale Android
# .symbols file can sit alongside; harmless for upload (Sentry dedupes by
# debug id), worth knowing when reading the directory.
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json

# The IPA must say what pubspec.yaml says, or it is not the build being
# released.
ARCHIVE_PLIST="build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Info.plist"
BUILT="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ARCHIVE_PLIST")+$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$ARCHIVE_PLIST")"
if [[ "$BUILT" != "$VERSION" ]]; then
  echo "error: built $BUILT but pubspec.yaml says $VERSION" >&2
  exit 1
fi
if ! compgen -G "build/ios/ipa/*.ipa" >/dev/null; then
  echo "error: flutter build ipa produced no IPA in build/ios/ipa" >&2
  exit 1
fi

if [[ "$UPLOAD" != "1" ]]; then
  echo "==> --no-upload given; skipping Sentry. Symbols NOT uploaded."
  exit 0
fi

echo "==> Uploading debug symbols for $VERSION"

# Pass 1: the plugin. Wires up the release and usually uploads the symbols.
# Its exit code is tolerated as on Android; passes 2 and 3 are what decide.
plugin_exit=0
dart run sentry_dart_plugin || plugin_exit=$?

# Pass 2: the Dart debug companions, explicitly. This is what must succeed.
CLI=".dart_tool/pub/bin/sentry_dart_plugin/sentry-cli"
if [[ ! -x "$CLI" ]]; then
  echo "error: sentry-cli not found at $CLI" >&2
  echo "       The plugin downloads it on first run." >&2
  exit 1
fi

echo "==> Uploading Dart debug companions (build/debug-info)"
if ! "$CLI" debug-files upload --org pranta-corp --project snake-classic-flutter build/debug-info; then
  echo "error: Dart symbol upload FAILED - do not ship this build" >&2
  exit 1
fi

# Pass 3: the dSYMs, which have no Android counterpart. Without them a native
# crash (the Flutter engine, a plugin's Swift, a hard signal) symbolicates to
# hex addresses; the Dart companions above only cover libapp.
DSYMS="build/ios/archive/Runner.xcarchive/dSYMs"
if ! find "$DSYMS" -name '*.dSYM' -print -quit 2>/dev/null | grep -q .; then
  echo "error: no dSYMs in $DSYMS - do not ship this build" >&2
  exit 1
fi
echo "==> Uploading dSYMs from $DSYMS"
if ! "$CLI" debug-files upload --org pranta-corp --project snake-classic-flutter "$DSYMS"; then
  echo "error: dSYM upload FAILED - do not ship this build" >&2
  exit 1
fi

if [[ "$plugin_exit" -ne 0 ]]; then
  echo
  echo "  NOTE: sentry_dart_plugin exited $plugin_exit. The explicit uploads"
  echo "        above succeeded, so this build is fine."
fi

grep -qxF "$VERSION" "$LEDGER" 2>/dev/null || echo "$VERSION" >> "$LEDGER"

cat <<EOF

==> Done. Upload this exact file with Transporter:
    $(ls build/ios/ipa/*.ipa)

    Symbols uploaded for $VERSION. Verify at
    https://pranta-corp.sentry.io/settings/projects/snake-classic-flutter/debug-symbols/
EOF
