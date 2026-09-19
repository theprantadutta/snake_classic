<#
.SYNOPSIS
  Build the Play release bundle AND upload its debug symbols to Sentry.

.DESCRIPTION
  PowerShell twin of tools/release_android.sh, for releasing from Windows
  without Git Bash. Keep the two in step — if you change one, change the other.

  The two halves belong in one script because doing only the first half is
  silent. 6.6.0+56 shipped that way: built without --obfuscate and
  --split-debug-info, no `dart run sentry_dart_plugin` afterwards, and the
  first crash to arrive from Play (SNAKE-CLASSIC-FLUTTER-2, a SIGSEGV) had
  <unknown> where our frames should have been. Nothing failed, nothing warned —
  the build succeeded, the upload simply never happened, and the consequence
  only showed up once a crash needed reading.

  The auth token is read from .sentry-auth-token (gitignored, repo root), or
  from $env:SENTRY_AUTH_TOKEN if it is already set — CI can use either. It is
  deliberately NOT read from .env; see the guard below for why.

  Symbols are matched to the build by the release identifier, which
  sentry_flutter derives from pubspec.yaml as
  com.pranta.snakeclassic@<version>+<build>. That is why nothing here sets
  `release` by hand, and why bumping the version AFTER building breaks the
  match.

.PARAMETER Target
  'appbundle' (default, the Play artifact) or 'apk' (sideload testing).

.EXAMPLE
  .\tools\release_android.ps1

.EXAMPLE
  .\tools\release_android.ps1 apk
#>

[CmdletBinding()]
param(
    [ValidateSet('appbundle', 'apk')]
    [string]$Target = 'appbundle',

    # Rebuild a version that has already been released. Only for redoing a
    # release you deliberately want to redo.
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Set-Location (Join-Path $PSScriptRoot '..')

# ---------------------------------------------------------------------------
# Refuse to build if the token is sitting in .env.
#
# .env is a bundled Flutter ASSET (see `- .env` under assets: in
# pubspec.yaml), so every key in it is packed into the APK/AAB and is
# readable by anyone who unzips the app off the Play Store. Verified against
# a real build: the bundle contains base/assets/flutter_assets/.env. Public
# client ids there are fine; a Sentry write credential is not.
#
# This guard exists because putting it there is an easy and completely silent
# mistake — the build would succeed and the upload would work.
# ---------------------------------------------------------------------------
if ((Test-Path '.env') -and
    (Select-String -Path '.env' -Pattern '^\s*SENTRY_AUTH_TOKEN\s*=\s*\S' -Quiet)) {
    Write-Host ''
    Write-Host '  ======================================================================'
    Write-Host '  REFUSING TO BUILD: SENTRY_AUTH_TOKEN is set in .env'
    Write-Host ''
    Write-Host '  .env ships INSIDE the app bundle. Building now would publish your'
    Write-Host '  Sentry auth token to every player who installs Snake Classic.'
    Write-Host ''
    Write-Host '  Move it:'
    Write-Host '      1. delete the SENTRY_AUTH_TOKEN line from .env'
    Write-Host '      2. put just the token value in .sentry-auth-token (gitignored)'
    Write-Host '  ======================================================================'
    Write-Host ''
    exit 1
}

# Token: an already-set variable wins (CI), else the local file.
$tokenFile = '.sentry-auth-token'
if ([string]::IsNullOrWhiteSpace($env:SENTRY_AUTH_TOKEN) -and (Test-Path $tokenFile)) {
    # -Raw then Trim(): without -Raw, Get-Content returns an array of lines,
    # and a token carrying a stray CR or LF fails auth with an unhelpful 401.
    $env:SENTRY_AUTH_TOKEN = (Get-Content -Raw -LiteralPath $tokenFile).Trim()
}

$versionLine = Select-String -Path 'pubspec.yaml' -Pattern '^version:\s*(\S+)' |
    Select-Object -First 1
if (-not $versionLine) {
    Write-Error 'Could not read `version:` from pubspec.yaml'
}
$version = $versionLine.Matches[0].Groups[1].Value

# ---------------------------------------------------------------------------
# Refuse to rebuild a version that has already gone out.
#
# Forgetting to bump pubspec.yaml costs a full build before Play rejects it
# with "version code N has already been used", and the symbols uploaded in
# the meantime attach to a version already in the wild. Two seconds of
# checking here beats five minutes of building.
#
# Two signals, because neither alone is enough:
#   - Sentry knows a release once events arrive from it, so it catches
#     "already in production" and survives a fresh clone. It does NOT know
#     about a version built and uploaded to Play an hour ago that nobody has
#     run yet.
#   - .released-versions is a local ledger appended after each successful
#     upload, which covers exactly that gap. It is gitignored and therefore
#     empty on a fresh clone, which is why Sentry is checked too.
# ---------------------------------------------------------------------------
$ledger = '.released-versions'
$alreadyLocal = (Test-Path $ledger) -and
                (Get-Content $ledger | Where-Object { $_.Trim() -eq $version })

$alreadyInSentry = $false
try {
    $rel = [uri]::EscapeDataString("com.pranta.snakeclassic@$version")
    $null = Invoke-RestMethod -TimeoutSec 20 `
        -Uri "https://sentry.io/api/0/organizations/pranta-corp/releases/$rel/" `
        -Headers @{ Authorization = "Bearer $env:SENTRY_AUTH_TOKEN" } -ErrorAction Stop
    $alreadyInSentry = $true
} catch {
    # 404 is the expected, healthy answer. Anything else (offline, token
    # trouble) must not block a release over a convenience check.
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -ne 404) {
        Write-Host "  (version check skipped: $($_.Exception.Message))"
    }
}

if (($alreadyLocal -or $alreadyInSentry) -and -not $Force) {
    # The two signals mean genuinely different things and deserve different
    # advice. Sentry seeing events proves the version is on real devices;
    # the local ledger only proves this machine built it and uploaded its
    # symbols, which happens whether or not the artifact ever reached Play.
    # Saying "already released" for the second case is simply wrong, and
    # sends you off to bump a version that never shipped.
    Write-Host ''
    Write-Host '  ======================================================================'
    if ($alreadyInSentry) {
        Write-Host "  REFUSING TO BUILD: $version is already in the wild"
        Write-Host ''
        Write-Host '  Sentry has received events from this version, so real devices are'
        Write-Host '  running it. Bump `version:` in pubspec.yaml. Play would reject the'
        Write-Host '  duplicate version code anyway, and symbols uploaded under a version'
        Write-Host '  already in use attach to the wrong binary.'
    }
    else {
        Write-Host "  ALREADY BUILT: $version was built and its symbols uploaded"
        Write-Host ''
        Write-Host '  ...from this machine. Sentry has seen no events from it, so it may'
        Write-Host '  never have reached the Play Store. Two cases:'
        Write-Host ''
        Write-Host '   - You already uploaded it to Play -> bump `version:` and rebuild.'
        Write-Host ''
        Write-Host '   - You did NOT upload it -> the artifact from that run is still at'
        Write-Host '     build/app/outputs/bundle/release/app-release.aab and its symbols'
        Write-Host '     already match it. Just upload that file; no rebuild needed.'
        Write-Host '     Only if it is gone (flutter clean, another build) rebuild with'
        Write-Host '     -Force, which is safe because Play never saw this version code.'
    }
    Write-Host ''
    Write-Host '  To build anyway: -Force'
    Write-Host '  ======================================================================'
    Write-Host ''
    exit 1
}

Write-Host "==> Building $Target for $version"

# Passed as an array so PowerShell hands each argument to flutter verbatim.
# Building one long string instead lets PowerShell's parser get involved with
# the `--extra-gen-snapshot-options=--save-obfuscation-map=...` argument, which
# it can split on the inner `=` and silently mangle.
#
# --obfuscate makes release Dart frames unreadable on purpose; the map that
# undoes it is what gets uploaded below. --split-debug-info writes the ELF
# debug data out of the binary (so the shipped app stays small) and into
# build/debug-info, which is the directory sentry_dart_plugin reads.
$buildArgs = @(
    'build', $Target,
    '--release',
    '--obfuscate',
    '--split-debug-info=build/debug-info',
    '--extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json'
)

& flutter @buildArgs
if ($LASTEXITCODE -ne 0) {
    # $ErrorActionPreference does not apply to native exit codes, so this has
    # to be checked by hand or a failed build would fall through to "Done".
    Write-Error "flutter build failed with exit code $LASTEXITCODE"
}

if ([string]::IsNullOrWhiteSpace($env:SENTRY_AUTH_TOKEN)) {
    Write-Host ''
    Write-Host '  ========================================================================'
    Write-Host '  BUILD OK, SYMBOLS NOT UPLOADED'
    Write-Host ''
    Write-Host '  No auth token found. `dart run sentry_dart_plugin` was skipped, so'
    Write-Host '  the artifact is fine and installable, but every crash it reports'
    Write-Host '  will have unreadable frames.'
    Write-Host ''
    Write-Host '  Put the token in .sentry-auth-token (gitignored, repo root) - NOT'
    Write-Host '  in .env, which ships inside the app. Create one at'
    Write-Host '  https://pranta-corp.sentry.io/settings/auth-tokens/ (scope: org:ci).'
    Write-Host ''
    Write-Host '  Do NOT upload this build to Play until you have run:'
    Write-Host ''
    Write-Host '      dart run sentry_dart_plugin'
    Write-Host ''
    Write-Host '  from this directory, against THIS build output. Rebuilding later'
    Write-Host '  produces a different binary and the symbols will no longer match.'
    Write-Host '  ========================================================================'
    Write-Host ''
    exit 1
}

Write-Host "==> Uploading debug symbols for $version"

# Pass 1: the plugin. It uploads the Android native libraries and wires up
# the release, and usually does the Dart symbols too.
#
# Its exit code is NOT trusted, deliberately. On Windows the plugin crashes
# with PathNotFoundException on a path ending in a literal `*` — it hands a
# glob to a directory listing, which Unix expands and Windows does not — and
# that happens AFTER the uploads succeed. Failing the release on it would
# mean reporting a broken build that is in fact fine. Pass 2 below is what
# actually decides.
& dart run sentry_dart_plugin
$pluginExit = $LASTEXITCODE

# Pass 2: the Dart symbols, explicitly, and this one must succeed.
#
# build/debug-info holds exactly three ELF debug companions — one per shipped
# ABI — produced by --split-debug-info. They are what turn a release stack
# trace into file names and line numbers in YOUR code, and they are the one
# thing worth failing the release over.
#
# This is not redundant with pass 1: on 6.6.1+57 the plugin crashed mid-walk
# having uploaded arm64 and x86_64 but not armeabi-v7a, so 32-bit devices
# would have reported unreadable traces with nothing indicating why.
$cli = Join-Path $PSScriptRoot '..\.dart_tool\pub\bin\sentry_dart_plugin\sentry-cli.exe'
if (-not (Test-Path $cli)) {
    Write-Error @"
sentry-cli not found at $cli
The plugin downloads it on first run; that it is missing means pass 1 never
got far enough. Fix that before shipping - the Dart symbols are unverified.
"@
}

Write-Host '==> Uploading Dart debug companions (build/debug-info)'
& $cli debug-files upload --org pranta-corp --project snake-classic-flutter build/debug-info
if ($LASTEXITCODE -ne 0) {
    Write-Error "Dart symbol upload FAILED (exit $LASTEXITCODE) - do not ship this build"
}

if ($pluginExit -ne 0) {
    Write-Host ''
    Write-Host "  NOTE: sentry_dart_plugin exited $pluginExit (the known Windows"
    Write-Host '        directory-walk crash). The Dart symbols above uploaded'
    Write-Host '        cleanly, so this build is fine.'
}

# Record the release only now — after the upload that decides success. A
# version that failed to upload must stay buildable without -Force.
if (-not ((Test-Path $ledger) -and (Get-Content $ledger | Where-Object { $_.Trim() -eq $version }))) {
    Add-Content -LiteralPath $ledger -Value $version
}

$artifact = if ($Target -eq 'appbundle') {
    'build/app/outputs/bundle/release/app-release.aab'
} else {
    'build/app/outputs/flutter-apk/app-release.apk'
}

Write-Host ''
Write-Host '==> Done. Artifact:'
Write-Host "    $artifact"
Write-Host ''
Write-Host "    Symbols uploaded for release com.pranta.snakeclassic@$version"
Write-Host '    Verify at https://pranta-corp.sentry.io/settings/projects/snake-classic-flutter/debug-symbols/'
