import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/widgets/lb/lb_markdown.dart';

/// The legal documents were shown as raw Markdown on the consent screen.
/// These pin the parts of the syntax those files actually use.
void main() {
  test('blocks: heading, joined paragraph, quote, lists, rule', () {
    final blocks = parseLBMarkdown('''
# Title

A hard-wrapped
paragraph.

> quoted
> across lines

- one
  - nested
1. first
---
''');
    expect(blocks.map((b) => b.kind), [
      LBMdKind.heading,
      LBMdKind.paragraph,
      LBMdKind.quote,
      LBMdKind.bullet,
      LBMdKind.bullet,
      LBMdKind.numbered,
      LBMdKind.rule,
    ]);
    expect(blocks[0].level, 1);
    expect(blocks[1].text, 'A hard-wrapped paragraph.');
    expect(blocks[2].text, 'quoted across lines');
    expect(blocks[4].level, 1);
    expect(blocks[5].marker, '1');
  });

  test('a line opening with a bold label keeps its own line', () {
    final blocks = parseLBMarkdown('**Version: 2.1**\n**Effective: July 1**');
    expect(blocks.single.text, '**Version: 2.1**\n**Effective: July 1**');
  });

  test('inline: bold, italic and link spans; no markers left', () {
    const base = TextStyle();
    final spans = lbMarkdownSpans('a **b** *c* [d](https://x)', base, const Color(0xFF00FF00));
    final text = spans.map((s) => s.toPlainText()).join();
    expect(text, 'a b c d');
  });

  test('the shipped legal documents render no raw markers', () {
    for (final f in ['assets/legal/PRIVACY.md', 'assets/legal/TERMS.md']) {
      for (final b in parseLBMarkdown(File(f).readAsStringSync())) {
        final plain = lbMarkdownSpans(b.text, const TextStyle(), const Color(0xFF000000))
            .map((s) => s.toPlainText())
            .join();
        expect(plain.contains('**'), isFalse, reason: '$f: $plain');
        expect(plain.startsWith('#'), isFalse, reason: '$f: $plain');
        expect(plain.startsWith('>'), isFalse, reason: '$f: $plain');
      }
    }
  });
}
