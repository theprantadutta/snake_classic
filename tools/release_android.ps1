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

  Symbols are matched to the build by the release identifier, which
  sentry_flutter derives from pubspec.yaml as
  com.pranta.snakeclassic@<version>+<build>. That is why nothing here sets
  `release` by hand, and why bumping the version AFTER building breaks the
  match.

.PARAMETER Target
  'appbundle' (default, the Play artifact) or 'apk' (sideload testing).

.EXAMPLE
  $env:SENTRY_AUTH_TOKEN = '...'   # project:releases scope
  .\tools\release_android.ps1

.EXAMPLE
  .\tools\release_android.ps1 apk
#>

[CmdletBinding()]
param(
    [ValidateSet('appbundle', 'apk')]
    [string]$Target = 'appbundle'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Set-Location (Join-Path $PSScriptRoot '..')

$versionLine = Select-String -Path 'pubspec.yaml' -Pattern '^version:\s*(\S+)' |
    Select-Object -First 1
if (-not $versionLine) {
    Write-Error 'Could not read `version:` from pubspec.yaml'
}
$version = $versionLine.Matches[0].Groups[1].Value

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
    Write-Host '  SENTRY_AUTH_TOKEN is not set, so `dart run sentry_dart_plugin` was'
    Write-Host '  skipped. The artifact is fine and installable, but every crash it'
    Write-Host '  reports will have unreadable frames.'
    Write-Host ''
    Write-Host '  Do NOT upload this build to Play until you have run:'
    Write-Host ''
    Write-Host '      $env:SENTRY_AUTH_TOKEN = "..."'
    Write-Host '      dart run sentry_dart_plugin'
    Write-Host ''
    Write-Host '  from this directory, against THIS build output. Rebuilding later'
    Write-Host '  produces a different binary and the symbols will no longer match.'
    Write-Host '  ========================================================================'
    Write-Host ''
    exit 1
}

Write-Host "==> Uploading debug symbols for $version"
& dart run sentry_dart_plugin
if ($LASTEXITCODE -ne 0) {
    Write-Error "sentry_dart_plugin failed with exit code $LASTEXITCODE"
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
