import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_glyphs.dart';
import 'package:snake_classic/design/lb_tokens.dart';

/// One glyph run laid out on the 3x5 cell grid.
///
/// Built once per string and cached: titles and scores repaint far more often
/// than their text changes, and parsing the glyph rows is the only non-trivial
/// work in painting them.
class LBCellLayout {
  LBCellLayout._(this.columns, this.lit, this.off);

  /// Total width in cells (glyph columns plus one-column separators).
  final int columns;

  /// Lit cells as (column, row), in left→right column order.
  final List<(int, int)> lit;

  /// Unlit cells inside each glyph's box — drawn only when an off colour is set.
  final List<(int, int)> off;

  static const int rows = 5;
  static final Map<String, LBCellLayout?> _cache = {};

  /// Whether every character of [text] has a cell glyph.
  static bool supports(String text) => of(text) != null;

  /// The layout for [text] (upper-cased), or null if a character has no glyph —
  /// the caller then falls back to plain type (translated titles in hi/ar/ru).
  static LBCellLayout? of(String text) {
    final key = text.toUpperCase();
    if (_cache.containsKey(key)) return _cache[key];
    if (_cache.length > 512) _cache.clear();
    return _cache[key] = _build(key);
  }

  static LBCellLayout? _build(String text) {
    final lit = <(int, int)>[];
    final off = <(int, int)>[];
    var x = 0;
    final chars = text.characters.toList();
    for (var i = 0; i < chars.length; i++) {
      final glyph = lbCellGlyphs[chars[i]];
      if (glyph == null) return null;
      final w = glyph.first.length;
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < w; c++) {
          if (glyph[r][c] == '1') {
            lit.add((x + c, r));
          } else if (chars[i] != ' ') {
            off.add((x + c, r));
          }
        }
      }
      x += w + (i == chars.length - 1 ? 0 : 1);
    }
    lit.sort((a, b) => a.$1.compareTo(b.$1));
    return LBCellLayout._(x, lit, off);
  }
}

/// Paints one rounded cell at grid position ([col], [row]) — the shared
/// primitive behind the cell font, pixel icons, bars and the logo.
RRect lbCellRect(double left, double top, double cell) {
  final g = cell * .12 / 2;
  return RRect.fromLTRBR(
    left + g,
    top + g,
    left + cell - g,
    top + cell - g,
    Radius.circular(cell * .22),
  );
}

/// A string drawn in snake cells (DESIGN_SPEC §1.2). Used for screen titles
/// (cell 6), hero numbers (cell 20) and PLAY/AGAIN (cell 7).
///
/// Characters outside the cell font (most non-Latin scripts) fall back to
/// heavy JetBrains Mono at the same cap height, so a translated title still
/// fits the slot. Long text scales down to fit its width instead of
/// overflowing.
class LBCellText extends StatelessWidget {
  const LBCellText(
    this.text, {
    super.key,
    this.cell = 6,
    this.color,
    this.glow = false,
    this.offColor,
    this.progress = 1,
    this.semanticsLabel,
  });

  final String text;

  /// Size of one cell in dp.
  final double cell;

  /// Lit cell colour; defaults to the palette lime.
  final Color? color;

  /// Soft halo in the cell colour behind the glyphs.
  final bool glow;

  /// When set, the unlit cells of each glyph box are drawn in this colour.
  final Color? offColor;

  /// 0→1 reveal: columns light left→right. 1 = fully lit.
  final double progress;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.lb.lime;
    final layout = LBCellLayout.of(text);
    final Widget body;
    if (layout == null) {
      body = Text(
        text.toUpperCase(),
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontFamily: LB.font,
          fontFamilyFallback: LB.fontFallback,
          fontSize: cell * 4.6,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: c,
          shadows: glow ? [Shadow(color: c.withValues(alpha: .55), blurRadius: cell * 2)] : null,
        ),
      );
    } else {
      body = CustomPaint(
        size: Size(layout.columns * cell, LBCellLayout.rows * cell),
        painter: _CellTextPainter(layout, cell, c, glow, offColor, progress),
      );
    }
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: body,
      ),
    );
  }
}

class _CellTextPainter extends CustomPainter {
  _CellTextPainter(this.layout, this.cell, this.color, this.glow, this.offColor, this.progress);

  final LBCellLayout layout;
  final double cell;
  final Color color;
  final bool glow;
  final Color? offColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final litCols = (layout.columns * progress).ceil();
    final lit = Path();
    final dim = Path();
    for (final (c, r) in layout.lit) {
      (c < litCols ? lit : dim).addRRect(lbCellRect(c * cell, r * cell, cell));
    }
    if (offColor != null) {
      for (final (c, r) in layout.off) {
        dim.addRRect(lbCellRect(c * cell, r * cell, cell));
      }
      canvas.drawPath(dim, Paint()..color = offColor!);
    } else if (progress < 1) {
      canvas.drawPath(dim, Paint()..color = color.withValues(alpha: .18));
    }
    if (glow) {
      canvas.drawPath(
        lit,
        Paint()
          ..color = color.withValues(alpha: .5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, (cell * .9).clamp(2, 14)),
      );
    }
    canvas.drawPath(lit, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CellTextPainter old) =>
      old.layout != layout ||
      old.cell != cell ||
      old.color != color ||
      old.glow != glow ||
      old.offColor != offColor ||
      old.progress != progress;
}

/// [LBCellText] that re-lights its cells left→right whenever [text] changes
/// (DESIGN_SPEC §5: score ghost digits, §6: countdown swaps).
class LBAnimatedCellText extends StatefulWidget {
  const LBAnimatedCellText(
    this.text, {
    super.key,
    this.cell = 6,
    this.color,
    this.glow = false,
    this.offColor,
    this.duration = LB.reveal,
    this.semanticsLabel,
  });

  final String text;
  final double cell;
  final Color? color;
  final bool glow;
  final Color? offColor;
  final Duration duration;
  final String? semanticsLabel;

  @override
  State<LBAnimatedCellText> createState() => _LBAnimatedCellTextState();
}

class _LBAnimatedCellTextState extends State<LBAnimatedCellText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  @override
  void didUpdateWidget(LBAnimatedCellText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => LBCellText(
          widget.text,
          cell: widget.cell,
          color: widget.color,
          glow: widget.glow,
          offColor: widget.offColor,
          progress: _c.value,
          semanticsLabel: widget.semanticsLabel,
        ),
      );
}
