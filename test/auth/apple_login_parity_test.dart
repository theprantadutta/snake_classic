import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// App Store Guideline 4.8: an app offering a third-party login must offer a
/// privacy-preserving equivalent alongside it. Sign in with Apple is the one
/// Apple names.
///
/// This is a structural guard, not a rendering one. The failure it exists for
/// is not "Apple sign-in is broken" — that would show up the moment anyone
/// tried it — but "a NEW login surface was added and Apple was forgotten on
/// that one". Version 6.4.3 was rejected for exactly that: the sign-in screen
/// and the profile screen both paired Google with Apple, and the
/// purchase-upgrade sheet, added later, offered Google alone. That sheet was
/// the path App Review walked.
///
/// So the rule is per-file: any widget or screen that reaches for a Google
/// auth method must reach for the Apple one too.
void main() {
  // Where both providers are DEFINED rather than offered. These name Google
  // without owing Apple anything at the same call site.
  const definitionLayer = {
    'lib/presentation/bloc/auth/auth_cubit.dart',
    'lib/services/unified_user_service.dart',
    'lib/services/auth_service.dart',
  };

  const googleCalls = ['signInWithGoogle', 'connectAccountWithGoogle', 'linkAnonymousToGoogle'];
  const appleCalls = ['signInWithApple', 'connectAccountWithApple', 'linkAnonymousToApple'];

  /// Source with `//` comments stripped, so prose mentioning a method by name
  /// is not mistaken for a call to it.
  String codeOf(File f) => f
      .readAsLinesSync()
      .map((l) {
        final i = l.indexOf('//');
        return i == -1 ? l : l.substring(0, i);
      })
      .join('\n');

  bool callsAny(String code, List<String> names) =>
      names.any((n) => code.contains('$n('));

  test('every surface offering Google also offers Sign in with Apple', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (definitionLayer.contains(entity.path)) continue;

      final code = codeOf(entity);
      if (!callsAny(code, googleCalls)) continue;
      if (!callsAny(code, appleCalls)) offenders.add(entity.path);
    }

    expect(
      offenders,
      isEmpty,
      reason: 'These offer a Google login with no Sign in with Apple beside '
          'it, which is what Guideline 4.8 rejects:\n'
          '  ${offenders.join('\n  ')}',
    );
  });

  test('the purchase-upgrade sheet gates Apple on the platform, not on nothing',
      () {
    // Apple's button must not render on Android, where there is no Apple ID
    // to sign in with. The check is that the option sits behind a platform
    // condition at all — the exact form is free to change.
    final code = codeOf(File('lib/widgets/account_upgrade_sheet.dart'));
    expect(code, contains('connectAccountWithApple('));
    expect(
      code,
      contains('TargetPlatform.iOS'),
      reason: 'the Apple option must be gated to Apple platforms',
    );
  });

  test('the Sign in with Apple entitlement is present', () {
    // Without this the capability is absent from the signed build and every
    // Apple sign-in fails at runtime with a 1000 error — an app that looks
    // compliant in source and is not on device.
    final entitlements =
        File('ios/Runner/Runner.entitlements').readAsStringSync();
    expect(
      entitlements,
      contains('com.apple.developer.applesignin'),
      reason: 'ios/Runner/Runner.entitlements must declare the capability',
    );
  });
}
