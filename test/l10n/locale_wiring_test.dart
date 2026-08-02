import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/supported_locales.dart';

/// Guards the wiring between the locale list the app advertises, the
/// generated delegates, and the picker in settings. Any of these drifting
/// apart shows up as a language that is either unreachable or unlabelled.
void main() {
  test('SupportedLocales matches the generated AppLocalizations set', () {
    final declared = SupportedLocales.locales.map((l) => l.languageCode).toSet();
    final generated =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();

    expect(declared.difference(generated), isEmpty,
        reason: 'SupportedLocales advertises a locale with no generated '
            'translations — MaterialApp would resolve it to English');
    expect(generated.difference(declared), isEmpty,
        reason: 'a translated locale is missing from SupportedLocales, so no '
            'user can select it and device-language matching skips it');
  });

  test('every supported locale has an endonym for the picker', () {
    for (final locale in SupportedLocales.locales) {
      final endonym = SupportedLocales.endonyms[locale.languageCode];
      expect(endonym, isNotNull,
          reason: '${locale.languageCode} would show its raw code in the '
              'language picker');
      expect(endonym, isNotEmpty);
    }
    expect(SupportedLocales.endonyms.keys.toSet(),
        SupportedLocales.locales.map((l) => l.languageCode).toSet(),
        reason: 'endonyms map has entries for locales that are not shipped');
  });

  test('every supported locale resolves to a loaded translation bundle', () {
    for (final locale in SupportedLocales.locales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.localeName, locale.languageCode);
      // A representative string from a screen the user always sees.
      expect(l10n.languageSystemDefault, isNotEmpty);
    }
  });

  test('both store disclosures exist and name the right store', () {
    // The purchase surface must tell the buyer which account is charged and
    // where to cancel; naming the wrong store is a compliance problem, not a
    // cosmetic one. Brand names stay untranslated, so this holds everywhere.
    for (final locale in SupportedLocales.locales) {
      final l10n = lookupAppLocalizations(locale);

      final appStore = l10n.legalAutoRenewDisclosureAppStore;
      expect(appStore, contains('App Store'),
          reason: '${locale.languageCode} iOS disclosure lost the store name');
      expect(appStore, isNot(contains('Google Play')),
          reason: '${locale.languageCode} iOS disclosure names Google Play');

      final play = l10n.legalAutoRenewDisclosureGooglePlay;
      expect(play, contains('Google Play'),
          reason: '${locale.languageCode} Android disclosure lost the store '
              'name');
      expect(play, isNot(contains('App Store')),
          reason: '${locale.languageCode} Android disclosure still says '
              'App Store');

      // Both must keep the cancellation window — the load-bearing clause.
      expect(appStore, contains('24'));
      expect(play, contains('24'));
    }
  });

  test('fromCode round-trips every locale and rejects unknown tags', () {
    for (final locale in SupportedLocales.locales) {
      expect(SupportedLocales.fromCode(locale.languageCode)?.languageCode,
          locale.languageCode);
    }
    // null = follow the device; a stale stored tag must degrade to that
    // rather than throwing on startup.
    expect(SupportedLocales.fromCode(null), isNull);
    expect(SupportedLocales.fromCode('zz'), isNull);
    expect(SupportedLocales.fromCode(''), isNull);
  });

  test('iOS declares every shipped locale in CFBundleLocalizations', () {
    // Without this iOS reports the bundle as English-only and hands Flutter
    // "en" regardless of the device language, so the translations are
    // unreachable on iOS even though everything else is wired correctly.
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final block = RegExp(
      r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);

    expect(block, isNotNull,
        reason: 'CFBundleLocalizations is missing from ios/Runner/Info.plist');

    final declared = RegExp(r'<string>([^<]+)</string>')
        .allMatches(block!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();

    expect(declared, SupportedLocales.locales.map((l) => l.languageCode).toSet(),
        reason: 'Info.plist CFBundleLocalizations is out of sync with '
            'SupportedLocales');
  });

  testWidgets('a right-to-left locale renders with RTL directionality',
      (tester) async {
    await tester.pumpWidget(
      const _LocaleProbe(Locale('ar')),
    );
    await tester.pumpAndSettle();

    final direction = Directionality.of(
      tester.element(find.byKey(const ValueKey('probe'))),
    );
    expect(direction, TextDirection.rtl,
        reason: 'Arabic must lay out right-to-left');
  });

  testWidgets('a left-to-right locale still renders LTR', (tester) async {
    await tester.pumpWidget(const _LocaleProbe(Locale('hi')));
    await tester.pumpAndSettle();

    final direction = Directionality.of(
      tester.element(find.byKey(const ValueKey('probe'))),
    );
    expect(direction, TextDirection.ltr);
  });
}

/// Minimal app shell that applies the real delegates for one locale.
class _LocaleProbe extends StatelessWidget {
  const _LocaleProbe(this.locale);

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF000000),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: SupportedLocales.locales,
      builder: (context, _) => const SizedBox(key: ValueKey('probe')),
    );
  }
}
