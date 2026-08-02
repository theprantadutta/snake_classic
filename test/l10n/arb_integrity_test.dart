import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Structural guards on the ARB catalogs.
///
/// These are the failures that don't show up as compile errors: a key added
/// to the English template and forgotten in the other eight, a duplicate key
/// silently shadowing an earlier one, or a translation that drops a
/// placeholder and blows up only when that screen is opened in that language.
void main() {
  const templateLocale = 'en';
  final localeCodes = <String>[
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

  File arbFile(String code) => File('lib/l10n/app_$code.arb');

  Map<String, dynamic> readArb(String code) =>
      jsonDecode(arbFile(code).readAsStringSync()) as Map<String, dynamic>;

  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  test('every declared locale has an ARB file', () {
    for (final code in localeCodes) {
      expect(arbFile(code).existsSync(), isTrue,
          reason: 'missing lib/l10n/app_$code.arb');
    }
  });

  test('no ARB file declares the same key twice', () {
    // jsonDecode keeps only the last occurrence, so a duplicate is invisible
    // to every other check here — it has to be caught on the raw text.
    final keyLine = RegExp(r'^\s{2}"([^"]+)"\s*:', multiLine: true);
    for (final code in localeCodes) {
      final counts = <String, int>{};
      for (final m in keyLine.allMatches(arbFile(code).readAsStringSync())) {
        final key = m.group(1)!;
        counts[key] = (counts[key] ?? 0) + 1;
      }
      final dupes = counts.entries.where((e) => e.value > 1).map((e) => e.key);
      expect(dupes, isEmpty, reason: 'duplicate keys in app_$code.arb');
    }
  });

  test('every locale defines exactly the template key set', () {
    final template = messageKeys(readArb(templateLocale));
    expect(template, isNotEmpty);

    for (final code in localeCodes.where((c) => c != templateLocale)) {
      final keys = messageKeys(readArb(code));
      expect(template.difference(keys), isEmpty,
          reason: 'app_$code.arb is missing keys present in the template');
      expect(keys.difference(template), isEmpty,
          reason: 'app_$code.arb has keys the template does not declare');
    }
  });

  test('every locale declares its own @@locale', () {
    for (final code in localeCodes) {
      expect(readArb(code)['@@locale'], code,
          reason: 'app_$code.arb has the wrong @@locale');
    }
  });

  test('translations keep every placeholder the template uses', () {
    final template = readArb(templateLocale);

    // ICU placeholder extraction. A brace can open either an argument
    // (`{count}`, `{count, plural, ...}`) or a plural/select branch body
    // (`other{Play {target} games}`) — only the first form is a placeholder,
    // so a bare `{Word}` is only treated as one when the message has no
    // plural/select wrapper to make it ambiguous.
    Set<String> placeholders(String message, Set<String> declared) {
      final result = <String>{};
      final simple = !message.contains(RegExp(r',\s*(plural|select)\s*,'));
      final arg = RegExp(r'\{\s*([a-zA-Z][a-zA-Z0-9_]*)\s*([,}])');
      for (final m in arg.allMatches(message)) {
        final name = m.group(1)!;
        final isControlArg = m.group(2) == ',';
        if (isControlArg || simple || declared.contains(name)) {
          result.add(name);
        }
      }
      return result;
    }

    for (final key in messageKeys(template)) {
      final meta = template['@$key'];
      final declared = <String>{
        if (meta is Map && meta['placeholders'] is Map)
          ...(meta['placeholders'] as Map).keys.cast<String>(),
      };
      final expected =
          placeholders(template[key] as String, declared)..addAll(declared);
      if (expected.isEmpty) continue;

      for (final code in localeCodes.where((c) => c != templateLocale)) {
        final translated =
            placeholders(readArb(code)[key] as String, declared);
        expect(expected.difference(translated), isEmpty,
            reason: '"$key" in app_$code.arb drops placeholder(s) that the '
                'English template uses — this throws at render time');
      }
    }
  });

  test('no translation is left as an untranslated copy of the template', () {
    // Brand names and symbols legitimately match English, so this only
    // guards against a locale being wholesale unstranslated rather than
    // asserting per-key difference.
    final template = readArb(templateLocale);
    final keys = messageKeys(template);

    for (final code in localeCodes.where((c) => c != templateLocale)) {
      final arb = readArb(code);
      final identical =
          keys.where((k) => arb[k] == template[k]).length / keys.length;
      expect(identical, lessThan(0.10),
          reason: '${(identical * 100).toStringAsFixed(1)}% of app_$code.arb '
              'is identical to English — it looks untranslated');
    }
  });
}
