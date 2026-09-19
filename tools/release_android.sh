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
# The auth token is read from .sentry-auth-token (gitignored, repo root), or
# from SENTRY_AUTH_TOKEN if it is already exported — CI can use either.
#
# Usage:
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

FORCE=0
TARGET="appbundle"
for arg in "$@"; do
  case "$arg" in
    --force)       FORCE=1 ;;
    appbundle|apk) TARGET="$arg" ;;
    *) echo "error: expected 'appbundle', 'apk' or --force, got '$arg'" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Refuse to build if the token is sitting in .env.
#
# .env is a bundled Flutter ASSET (see `- .env` under assets: in
# pubspec.yaml), so every key in it is packed into the APK/AAB and can be
# read by anyone who unzips the app off the Play Store. Verified: the shipped
# bundle contains base/assets/flutter_assets/.env. Public client ids there
# are fine; a Sentry write credential is not.
#
# This check exists because putting it there is an easy and completely silent
# mistake — the build would succeed and the upload would work.
# ---------------------------------------------------------------------------
if [[ -f .env ]] && grep -qE '^[[:space:]]*SENTRY_AUTH_TOKEN[[:space:]]*=[[:space:]]*[^[:space:]]' .env; then
  cat >&2 <<'MSG'

  ========================================================================
  REFUSING TO BUILD: SENTRY_AUTH_TOKEN is set in .env

  .env ships INSIDE the app bundle. Building now would publish your Sentry
  auth token to every player who installs Snake Classic.

  Move it:
      1. delete the SENTRY_AUTH_TOKEN line from .env
      2. put just the token value in .sentry-auth-token (gitignored)

  ========================================================================

MSG
  exit 1
fi

# Token: an already-exported variable wins (CI), else the local file.
TOKEN_FILE=".sentry-auth-token"
if [[ -z "${SENTRY_AUTH_TOKEN:-}" && -f "$TOKEN_FILE" ]]; then
  # Strip any trailing newline an editor may have added: a token carrying
  # a stray CR or LF fails auth with an unhelpful 401.
  SENTRY_AUTH_TOKEN="$(tr -d '\r\n' < "$TOKEN_FILE")"
  export SENTRY_AUTH_TOKEN
fi

VERSION="$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"

# ---------------------------------------------------------------------------
# Refuse to rebuild a version that has already gone out.
#
# Forgetting to bump pubspec.yaml costs a full build before Play rejects it
# with "version code N has already been used", and the symbols uploaded in
# the meantime attach to a version already in the wild.
#
# Two signals, because neither alone is enough:
#   - Sentry knows a release once events arrive from it, so it catches
#     "already in production" and survives a fresh clone. It does NOT know
#     about a version uploaded to Play an hour ago that nobody has run yet.
#   - .released-versions is a local ledger appended after each successful
#     upload, covering exactly that gap. Gitignored, so empty on a fresh
#     clone, which is why Sentry is checked too.
# ---------------------------------------------------------------------------
LEDGER=".released-versions"
ALREADY_LOCAL=0
[[ -f "$LEDGER" ]] && grep -qxF "$VERSION" "$LEDGER" && ALREADY_LOCAL=1

ALREADY_SENTRY=0
if [[ -n "${SENTRY_AUTH_TOKEN:-}" ]] && command -v curl >/dev/null 2>&1; then
  REL_ENC="com.pranta.snakeclassic%40${VERSION/+/%2B}"
  CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 20     -H "Authorization: Bearer $SENTRY_AUTH_TOKEN"     "https://sentry.io/api/0/organizations/pranta-corp/releases/$REL_ENC/" || echo 000)"
  # Only a definite 200 blocks. A 404 is the healthy answer, and anything
  # else (offline, token trouble) must not stop a release over a
  # convenience check.
  [[ "$CODE" == "200" ]] && ALREADY_SENTRY=1
  [[ "$CODE" == "200" || "$CODE" == "404" ]] || echo "  (version check skipped: HTTP $CODE)"
fi

# The two signals mean genuinely different things and deserve different
# advice. Sentry seeing events proves the version is on real devices; the
# local ledger only proves this machine built it and uploaded its symbols,
# which happens whether or not the artifact ever reached Play. Saying
# "already released" for the second case is simply wrong, and sends you off
# to bump a version that never shipped.
if [[ ( "$ALREADY_LOCAL" == "1" || "$ALREADY_SENTRY" == "1" ) && "$FORCE" != "1" ]]; then
  if [[ "$ALREADY_SENTRY" == "1" ]]; then
    cat >&2 <<MSG

  ======================================================================
  REFUSING TO BUILD: $VERSION is already in the wild

  Sentry has received events from this version, so real devices are
  running it. Bump 'version:' in pubspec.yaml. Play would reject the
  duplicate version code anyway, and symbols uploaded under a version
  already in use attach to the wrong binary.

  To build anyway: --force
  ======================================================================

MSG
  else
    cat >&2 <<MSG

  ======================================================================
  ALREADY BUILT: $VERSION was built and its symbols uploaded

  ...from this machine. Sentry has seen no events from it, so it may
  never have reached the Play Store. Two cases:

   - You already uploaded it to Play -> bump 'version:' and rebuild.

   - You did NOT upload it -> the artifact from that run is still at
     build/app/outputs/bundle/release/app-release.aab and its symbols
     already match it. Just upload that file; no rebuild needed.
     Only if it is gone (flutter clean, another build) rebuild with
     --force, which is safe because Play never saw this version code.

  To build anyway: --force
  ======================================================================

MSG
  fi
  exit 1
fi

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

  No auth token found. `dart run sentry_dart_plugin` was skipped, so the
  artifact is fine and installable, but every crash it reports will have
  unreadable frames.

  Put the token in .sentry-auth-token (gitignored, repo root) — NOT in
  .env, which ships inside the app. Create one at
  https://pranta-corp.sentry.io/settings/auth-tokens/ (scope: org:ci).

  Do NOT upload this build to Play until you have run:

      dart run sentry_dart_plugin

  from this directory, against THIS build output. Rebuilding later
  produces a different binary and the symbols will no longer match.
  ========================================================================

MSG
  exit 1
fi

echo "==> Uploading debug symbols for $VERSION"

# Pass 1: the plugin. Uploads the Android native libraries and wires up the
# release, and usually the Dart symbols too.
#
# Its exit code is NOT trusted, deliberately. On Windows it crashes with
# PathNotFoundException on a path ending in a literal `*` (it hands a glob to
# a directory listing, which Unix expands and Windows does not), and that
# happens AFTER the uploads succeed. Failing the release on it would report a
# broken build that is in fact fine. Pass 2 is what decides.
plugin_exit=0
dart run sentry_dart_plugin || plugin_exit=$?

# Pass 2: the Dart symbols, explicitly, and this one must succeed.
#
# build/debug-info holds exactly three ELF debug companions, one per shipped
# ABI, produced by --split-debug-info. They are what turn a release stack
# trace into file names and line numbers in OUR code.
#
# Not redundant with pass 1: on 6.6.1+57 the plugin crashed mid-walk having
# uploaded arm64 and x86_64 but not armeabi-v7a, so 32-bit devices would have
# reported unreadable traces with nothing indicating why.
CLI="$(dirname "$0")/../.dart_tool/pub/bin/sentry_dart_plugin/sentry-cli"
[[ -x "$CLI" ]] || CLI="$CLI.exe"
if [[ ! -x "$CLI" ]]; then
  echo "error: sentry-cli not found near $CLI" >&2
  echo "       The plugin downloads it on first run; missing means pass 1" >&2
  echo "       never got that far. The Dart symbols are unverified." >&2
  exit 1
fi

echo "==> Uploading Dart debug companions (build/debug-info)"
if ! "$CLI" debug-files upload --org pranta-corp --project snake-classic-flutter build/debug-info; then
  echo "error: Dart symbol upload FAILED - do not ship this build" >&2
  exit 1
fi

if [[ "$plugin_exit" -ne 0 ]]; then
  echo
  echo "  NOTE: sentry_dart_plugin exited $plugin_exit (the known directory-walk"
  echo "        crash). The Dart symbols above uploaded cleanly, so this"
  echo "        build is fine."
fi

# Record the release only now — after the upload that decides success. A
# version that failed to upload must stay buildable without --force.
grep -qxF "$VERSION" "$LEDGER" 2>/dev/null || echo "$VERSION" >> "$LEDGER"

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
