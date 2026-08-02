import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/supported_locales.dart';
import 'package:snake_classic/utils/typography.dart';

/// Every character the UI can render must exist in a font we actually ship.
///
/// Runtime font fetching is disabled (see main.dart), so a glyph missing from
/// the whole bundle is silently substituted by whatever the OS happens to
/// have — different on every device, and mixed mid-word. Orbitron alone
/// covers no Cyrillic, Devanagari, Arabic or Polish diacritics, which is
/// exactly the gap GameTypography.scriptFallback exists to close; this test
/// fails if a new language (or a new string) reintroduces one.
void main() {
  const fontFiles = <String>[
    'assets/fonts/Orbitron-Regular.ttf',
    'assets/fonts/Rajdhani-Regular.ttf',
    'assets/fonts/NotoSans-Regular.ttf',
    'assets/fonts/NotoSansDevanagari-Regular.ttf',
    'assets/fonts/NotoSansArabic-Regular.ttf',
  ];

  const localeCodes = <String>[
    'en',
    'hi',
    'pt',
    'es',
    'fr',
    'ru',
    'pl',
    'ar',
    'it',
  ];

  /// Codepoints that are never drawn from a text font: whitespace, bidi and
  /// joining controls, variation selectors, private use, and the emoji /
  /// pictograph blocks the UI uses as icons (those come from the platform
  /// emoji font on every OS).
  bool isNonGlyph(int cp) =>
      cp <= 0x20 ||
      cp == 0x7F ||
      (cp >= 0x200B && cp <= 0x200F) || // zero-width + bidi marks
      (cp >= 0x202A && cp <= 0x202E) || // bidi embedding
      (cp >= 0x2066 && cp <= 0x2069) || // bidi isolates
      (cp >= 0xFE00 && cp <= 0xFE0F) || // variation selectors
      (cp >= 0xE000 && cp <= 0xF8FF) || // private use
      (cp >= 0x2190 && cp <= 0x2BFF) || // arrows, symbols, dingbats
      (cp >= 0x1F000 && cp <= 0x1FAFF) || // emoji & pictographs
      (cp >= 0x1F1E6 && cp <= 0x1F1FF); // regional indicators

  test('bundled fonts cover every character used in every ARB', () {
    final covered = <int>{};
    for (final path in fontFiles) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'missing font asset: $path');
      covered.addAll(_cmapCodepoints(file.readAsBytesSync()));
    }
    expect(covered, isNotEmpty);

    final failures = <String, Set<String>>{};
    for (final code in localeCodes) {
      final arb = jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
      for (final entry in arb.entries) {
        if (entry.key.startsWith('@')) continue;
        for (final cp in (entry.value as String).runes) {
          if (isNonGlyph(cp) || covered.contains(cp)) continue;
          failures
              .putIfAbsent(code, () => <String>{})
              .add('U+${cp.toRadixString(16).toUpperCase().padLeft(4, '0')} '
                  '(${String.fromCharCode(cp)})');
        }
      }
    }

    expect(failures, isEmpty,
        reason: 'characters with no glyph in any bundled font — the OS would '
            'substitute an arbitrary fallback: $failures');
  });

  test('each script has a dedicated fallback family, not just the OS', () {
    // Spot-check the specific gaps that motivated the fallback chain, so a
    // future "let's drop a font to save space" change fails loudly.
    final samples = <String, String>{
      'Polish diacritics': 'łąężśćźń',
      'Cyrillic': 'Русский',
      'Devanagari': 'हिन्दी',
      'Arabic': 'العربية',
    };

    final covered = <int>{};
    for (final path in fontFiles) {
      covered.addAll(_cmapCodepoints(File(path).readAsBytesSync()));
    }

    samples.forEach((label, text) {
      final missing = text.runes.where((cp) => !covered.contains(cp));
      expect(missing, isEmpty, reason: '$label is not covered by any bundled '
          'font — pl/ru/hi/ar would render in an OS substitute');
    });
  });

  group('script-aware letter spacing', () {
    test('is stripped for Devanagari and Arabic, kept elsewhere', () {
      // Spacing between glyphs breaks Devanagari conjuncts and Arabic
      // cursive joins — "खेलें" renders as "खे लें". Latin and Cyrillic are
      // alphabetic and keep the game's tracked-out display look.
      for (final locale in SupportedLocales.locales) {
        final spacing = GameTypography.letterSpacingFor(locale, 2);
        if (locale.languageCode == 'hi' || locale.languageCode == 'ar') {
          expect(spacing, 0,
              reason: '${locale.languageCode} must not get letter spacing');
        } else {
          expect(spacing, 2,
              reason: '${locale.languageCode} should keep its tracking');
        }
      }
    });

    test('the theme text styles follow the same rule', () {
      final hindi = GameTypography.createTextTheme(locale: const Locale('hi'));
      expect(hindi.displayLarge?.letterSpacing, 0);
      expect(hindi.labelLarge?.letterSpacing, 0);

      final polish = GameTypography.createTextTheme(locale: const Locale('pl'));
      expect(polish.displayLarge?.letterSpacing, greaterThan(0));
    });

    testWidgets('context.letterSpacing resolves from the active locale',
        (tester) async {
      Future<double?> spacingFor(Locale locale) async {
        double? seen;
        await tester.pumpWidget(WidgetsApp(
          color: const Color(0xFF000000),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: SupportedLocales.locales,
          builder: (context, _) {
            seen = context.letterSpacing(2);
            return const SizedBox();
          },
        ));
        await tester.pumpAndSettle();
        return seen;
      }

      expect(await spacingFor(const Locale('ar')), 0);
      expect(await spacingFor(const Locale('hi')), 0);
      expect(await spacingFor(const Locale('ru')), 2);
      expect(await spacingFor(const Locale('en')), 2);
    });
  });
}

/// Codepoints present in a TrueType font's Unicode `cmap`.
///
/// Handles the two subtable formats shipped by the fonts we bundle: format 4
/// (BMP) and format 12 (full range).
Set<int> _cmapCodepoints(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final numTables = data.getUint16(4);

  int? cmapOffset;
  for (var i = 0; i < numTables; i++) {
    final record = 12 + 16 * i;
    final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
    if (tag == 'cmap') cmapOffset = data.getUint32(record + 8);
  }
  if (cmapOffset == null) return <int>{};

  // Prefer the widest Unicode subtable available.
  const preferred = <List<int>>[
    [3, 10],
    [3, 1],
    [0, 6],
    [0, 4],
    [0, 3],
  ];
  int? best;
  var bestRank = preferred.length;
  final subtableCount = data.getUint16(cmapOffset + 2);
  for (var i = 0; i < subtableCount; i++) {
    final record = cmapOffset + 4 + 8 * i;
    final platform = data.getUint16(record);
    final encoding = data.getUint16(record + 2);
    final rank = preferred
        .indexWhere((p) => p[0] == platform && p[1] == encoding);
    if (rank != -1 && rank < bestRank) {
      bestRank = rank;
      best = cmapOffset + data.getUint32(record + 4);
    }
  }
  if (best == null) return <int>{};

  final result = <int>{};
  switch (data.getUint16(best)) {
    case 4:
      final segCount = data.getUint16(best + 6) ~/ 2;
      for (var s = 0; s < segCount; s++) {
        final end = data.getUint16(best + 14 + s * 2);
        final start = data.getUint16(best + 16 + segCount * 2 + s * 2);
        if (end == 0xFFFF) continue;
        for (var cp = start; cp <= end; cp++) {
          result.add(cp);
        }
      }
    case 12:
      final groups = data.getUint32(best + 12);
      for (var g = 0; g < groups; g++) {
        final record = best + 16 + 12 * g;
        final start = data.getUint32(record);
        final end = data.getUint32(record + 4);
        for (var cp = start; cp <= end && cp <= 0x2FFFF; cp++) {
          result.add(cp);
        }
      }
  }
  return result;
}
