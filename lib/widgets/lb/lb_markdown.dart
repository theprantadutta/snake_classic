import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';

/// The Markdown the legal documents use, drawn in the Living Board style.
///
/// `assets/legal/*.md` used to be shown with a plain [Text], so players read
/// the source — `#`, `**`, `>` and all — on the consent screen, the first
/// thing a new install shows. This covers exactly what those files use:
/// headings, paragraphs, block quotes, `-`/`*` and numbered lists (nested by
/// indentation), `---` rules, `**bold**`, `*italic*` and `[links](url)`
/// (shown as underlined text). Anything else renders as a plain paragraph.
///
/// Built lazily ([ListView.builder]): the privacy policy is ~360 lines.
class LBMarkdown extends StatelessWidget {
  const LBMarkdown({
    super.key,
    required this.data,
    this.size = 12,
    this.padding = const EdgeInsets.all(14),
  });

  final String data;

  /// Body text size; headings scale from it.
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final blocks = parseLBMarkdown(data);
    return ListView.builder(
      padding: padding,
      itemCount: blocks.length,
      itemBuilder: (context, i) => _BlockView(block: blocks[i], size: size),
    );
  }
}

enum LBMdKind { heading, paragraph, quote, bullet, numbered, rule }

/// One rendered block. [level] is the heading level, or the list nesting
/// depth; [marker] is a numbered item's number.
@immutable
class LBMdBlock {
  const LBMdBlock(this.kind, this.text, {this.level = 0, this.marker = ''});

  final LBMdKind kind;
  final String text;
  final int level;
  final String marker;
}

final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
final _bullet = RegExp(r'^(\s*)[-*+]\s+(.*)$');
final _numbered = RegExp(r'^(\s*)(\d+)[.)]\s+(.*)$');
final _rule = RegExp(r'^\s*(-{3,}|\*{3,}|_{3,})\s*$');

/// Splits [source] into blocks. Consecutive lines of a paragraph or quote
/// are joined (the files are hard-wrapped); a list item's continuation lines
/// join the item.
List<LBMdBlock> parseLBMarkdown(String source) {
  final out = <LBMdBlock>[];
  LBMdKind? open;
  final buf = StringBuffer();
  var openLevel = 0;
  var openMarker = '';

  void flush() {
    if (open != null && buf.isNotEmpty) {
      out.add(LBMdBlock(open!, buf.toString().trim(), level: openLevel, marker: openMarker));
    }
    buf.clear();
    open = null;
  }

  void start(LBMdKind kind, String text, {int level = 0, String marker = ''}) {
    flush();
    open = kind;
    openLevel = level;
    openMarker = marker;
    buf.write(text);
  }

  for (final raw in source.replaceAll('\r\n', '\n').split('\n')) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) {
      flush();
      continue;
    }
    if (_rule.hasMatch(line)) {
      flush();
      out.add(const LBMdBlock(LBMdKind.rule, ''));
      continue;
    }
    final h = _heading.firstMatch(line);
    if (h != null) {
      flush();
      out.add(LBMdBlock(LBMdKind.heading, h.group(2)!.trim(), level: h.group(1)!.length));
      continue;
    }
    if (line.trimLeft().startsWith('>')) {
      final text = line.trimLeft().substring(1).trim();
      if (open == LBMdKind.quote) {
        buf.write(' $text');
      } else {
        start(LBMdKind.quote, text);
      }
      continue;
    }
    final b = _bullet.firstMatch(line);
    if (b != null) {
      start(LBMdKind.bullet, b.group(2)!, level: b.group(1)!.length ~/ 2);
      continue;
    }
    final n = _numbered.firstMatch(line);
    if (n != null) {
      start(LBMdKind.numbered, n.group(3)!, level: n.group(1)!.length ~/ 2, marker: n.group(2)!);
      continue;
    }
    // A plain line: continues whatever is open (paragraph, list item,
    // quote), or starts a paragraph. A line that opens with a bold label
    // keeps its own line — the docs stack metadata that way
    // (**Policy Version:** … / **Effective Date:** …).
    if (open == null || open == LBMdKind.heading) {
      start(LBMdKind.paragraph, line.trim());
    } else {
      buf.write(line.trimLeft().startsWith('**') ? '\n${line.trim()}' : ' ${line.trim()}');
    }
  }
  flush();
  return out;
}

final _inline = RegExp(r'\*\*(.+?)\*\*|\*(?!\s)(.+?)\*|\[([^\]]+)\]\(([^)]+)\)');

/// `**bold**`, `*italic*` and `[text](url)` as spans over [base].
List<InlineSpan> lbMarkdownSpans(String text, TextStyle base, Color linkColor) {
  final spans = <InlineSpan>[];
  var at = 0;
  for (final m in _inline.allMatches(text)) {
    if (m.start > at) spans.add(TextSpan(text: text.substring(at, m.start)));
    if (m.group(1) != null) {
      spans.add(TextSpan(
        children: lbMarkdownSpans(m.group(1)!, base, linkColor),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ));
    } else if (m.group(2) != null) {
      spans.add(TextSpan(text: m.group(2), style: const TextStyle(fontStyle: FontStyle.italic)));
    } else {
      spans.add(TextSpan(
        text: m.group(3),
        style: TextStyle(color: linkColor, decoration: TextDecoration.underline, decorationColor: linkColor),
      ));
    }
    at = m.end;
  }
  if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
  return spans;
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.size});

  final LBMdBlock block;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final body = LBText.body(p, color: p.ink.withValues(alpha: .86), size: size).copyWith(height: 1.5);
    Widget rich(String text, TextStyle style) =>
        Text.rich(TextSpan(style: style, children: lbMarkdownSpans(text, style, p.lime)));

    switch (block.kind) {
      case LBMdKind.rule:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 1, color: p.blockStroke),
        );
      case LBMdKind.heading:
        final top = block.level == 1;
        final style = top
            ? LBText.value(p, color: p.lime, size: size + 5)
            : LBText.value(p, color: block.level == 2 ? p.lime : p.ink, size: size + (block.level == 2 ? 2.5 : 1))
                .copyWith(height: 1.3);
        return Padding(
          padding: EdgeInsets.only(top: top ? 2 : 14, bottom: 6),
          child: rich(block.text, style),
        );
      case LBMdKind.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
          decoration: BoxDecoration(
            color: p.lime.withValues(alpha: .05),
            border: Border(left: BorderSide(color: p.lime.withValues(alpha: .6), width: 2)),
          ),
          child: rich(block.text, body.copyWith(color: p.ink.withValues(alpha: .72))),
        );
      case LBMdKind.bullet:
      case LBMdKind.numbered:
        final marker = block.kind == LBMdKind.bullet ? '▪' : '${block.marker}.';
        return Padding(
          padding: EdgeInsetsDirectional.only(start: 4 + block.level * 14.0, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: block.kind == LBMdKind.bullet ? 14 : 22,
                child: Text(marker, style: body.copyWith(color: p.lime, fontWeight: FontWeight.w800)),
              ),
              Expanded(child: rich(block.text, body)),
            ],
          ),
        );
      case LBMdKind.paragraph:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: rich(block.text, body),
        );
    }
  }
}
