#!/usr/bin/env bash
#
# Build the App Store IPA AND upload its debug symbols to Sentry.
#
# ############################################################################
# #                                                                          #
# #  UNVERIFIED. This script has never been run.                             #
# #                                                                          #
# #  It was written on a Windows machine with no macOS and no Xcode, by      #
# #  translating tools/release_android.sh and applying the documented iOS    #
# #  differences. Every Android step in it is battle-tested; every iOS-      #
# #  specific step is reasoned-about, not observed.                          #
# #                                                                          #
# #  Treat the first run as a test of THIS SCRIPT, not of your release.      #
# #  What to check is listed under "FIRST RUN CHECKLIST" at the bottom.      #
# #                                                                          #
# ############################################################################
#
# Usage:
#   ./tools/release_ios.sh              # build + upload symbols
#   ./tools/release_ios.sh --force      # rebuild an already-released version
#   ./tools/release_ios.sh --no-upload  # build only, skip Sentry
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

if [[ "$UPLOAD" != "1" ]]; then
  echo "==> --no-upload given; skipping Sentry. Symbols NOT uploaded."
  exit 0
fi

if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  echo >&2
  echo "  BUILD OK, SYMBOLS NOT UPLOADED - no auth token found." >&2
  echo "  Put it in .sentry-auth-token, then run: dart run sentry_dart_plugin" >&2
  echo >&2
  exit 1
fi

echo "==> Uploading debug symbols for $VERSION"

# Pass 1: the plugin. On iOS it is also responsible for finding the dSYMs in
# the Xcode archive, which is the part with no Android equivalent.
#
# Its exit code is tolerated for the same reason as on Android — it crashed
# there AFTER a successful upload. Whether it does so on macOS is unknown;
# the crash looked Windows-specific (a literal '*' handed to a directory
# listing, which a Unix shell would have expanded). If it exits 0 on macOS,
# nothing here changes.
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
"$CLI" debug-files upload --org pranta-corp --project snake-classic-flutter build/debug-info

# Pass 3: the dSYMs. THIS HAS NO ANDROID COUNTERPART and is the step most
# likely to need correcting on the first real run.
#
# Without dSYMs, a native iOS crash (the Flutter engine, a plugin's
# Objective-C/Swift, a hard signal) symbolicates to hex addresses. The Dart
# companions above do not cover that — they only cover libapp.
#
# Flutter writes the archive under build/ios/archive. The dSYM location has
# moved between Xcode versions, so several candidates are tried and each is
# uploaded if present, rather than assuming one layout.
DSYM_FOUND=0
for d in \
  build/ios/archive/Runner.xcarchive/dSYMs \
  build/ios/Release-iphoneos \
  build/ios/iphoneos
do
  if [[ -d "$d" ]] && find "$d" -name '*.dSYM' -print -quit | grep -q .; then
    echo "==> Uploading dSYMs from $d"
    "$CLI" debug-files upload --org pranta-corp --project snake-classic-flutter "$d"
    DSYM_FOUND=1
  fi
done

if [[ "$DSYM_FOUND" != "1" ]]; then
  echo >&2
  echo "  WARNING: no dSYMs found in any known location." >&2
  echo "  Native iOS crashes will symbolicate to hex addresses." >&2
  echo "  Find them with:  find build/ios -name '*.dSYM'" >&2
  echo "  then add that path to the loop above." >&2
  echo >&2
fi

if [[ "$plugin_exit" -ne 0 ]]; then
  echo
  echo "  NOTE: sentry_dart_plugin exited $plugin_exit. The explicit uploads"
  echo "        above succeeded, so this build is fine — but on macOS this"
  echo "        is NOT the known Windows crash, so it is worth reading the"
  echo "        output once to see what it actually was."
fi

grep -qxF "$VERSION" "$LEDGER" 2>/dev/null || echo "$VERSION" >> "$LEDGER"

cat <<EOF

==> Done.
    Artifact: build/ios/ipa/*.ipa
    Upload it with Xcode Organizer or:
        xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios \\
          -u <apple-id> -p <app-specific-password>

    Verify symbols:
    https://pranta-corp.sentry.io/settings/projects/snake-classic-flutter/debug-symbols/

# ---------------------------------------------------------------------------
# FIRST RUN CHECKLIST (this script is unverified)
#
#  1. Did 'flutter build ipa' accept the flags? Android takes all four; if
#     iOS rejects one, the build fails immediately and loudly.
#  2. Did pass 2 upload an arm64 debug companion? iOS ships arm64 only.
#  3. Did pass 3 find dSYMs at all? If it printed the WARNING, run
#     'find build/ios -name "*.dSYM"' and add the real path to the loop.
#  4. Did the plugin exit 0 on macOS? If so, the tolerance in pass 1 is
#     unnecessary here and can be tightened.
#  5. THE ACTUAL TEST: ship it, force a crash on a real device, and confirm
#     the Sentry issue shows your Dart file and line rather than hex. That
#     is the only thing that proves any of this.
# ---------------------------------------------------------------------------
EOF
