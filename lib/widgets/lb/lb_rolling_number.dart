import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_glyphs.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/widgets/lb/lb_glow_cache.dart';

/// One character of the new string that rolls, paired with the character it
/// replaces (null when the new string is longer and nothing was there).
@visibleForTesting
class LBRollSlot {
  const LBRollSlot(this.index, this.to, this.from, this.order);

  /// Index of the character in the new string (in characters, not code units).
  final int index;
  final String to;
  final String? from;

  /// Stagger order: 0 for the rightmost rolling character.
  final int order;

  @override
  String toString() => 'LBRollSlot($index, ${from ?? '∅'}→$to)';
}

/// The plan for one roll from [from] to [to]: which characters of the new
/// string roll, and which characters of the old string have no place in the
/// new one (they roll out and are gone).
@visibleForTesting
class LBRollPlan {
  LBRollPlan._(this.from, this.to, this.slots, this.dropped);

  final List<String> from;
  final List<String> to;
  final List<LBRollSlot> slots;

  /// Old characters with no counterpart, left to right.
  final List<String> dropped;

  bool get isEmpty => slots.isEmpty && dropped.isEmpty;

  /// The characters of [to] that roll, by index.
  Set<int> get rolling => {for (final s in slots) s.index};

  /// Digits are matched from the right (like an odometer, so 99 → 100 rolls
  /// every column and 1,234 → 1,240 rolls only the last two). A common
  /// suffix and then a common prefix are trimmed first, so text around a
  /// number ("2 OF 3 DONE") stays still when only the number changes width.
  factory LBRollPlan.of(String fromText, String toText) {
    final a = fromText.characters.toList();
    final b = toText.characters.toList();
    var s = 0;
    while (s < a.length &&
        s < b.length &&
        a[a.length - 1 - s] == b[b.length - 1 - s]) {
      s++;
    }
    var p = 0;
    while (p < a.length - s && p < b.length - s && a[p] == b[p]) {
      p++;
    }
    final aMid = a.sublist(p, a.length - s);
    final bMid = b.sublist(p, b.length - s);
    final shift = bMid.length - aMid.length;
    final raw = <(int, String, String?)>[];
    for (var j = 0; j < bMid.length; j++) {
      final k = j - shift;
      final old = k >= 0 && k < aMid.length ? aMid[k] : null;
      if (old != bMid[j]) raw.add((p + j, bMid[j], old));
    }
    final dropped = shift < 0 ? aMid.sublist(0, -shift) : const <String>[];
    final slots = [
      for (var i = 0; i < raw.length; i++)
        LBRollSlot(raw[i].$1, raw[i].$2, raw[i].$3, raw.length - 1 - i),
    ];
    return LBRollPlan._(a, b, slots, dropped);
  }
}

/// An odometer readout: when [value] changes, each changed character slides
/// out of its slot while the new one slides in, up when the value grows and
/// down when it shrinks (MOTION_SPEC: number change).
///
/// [format] turns the value into text (`context.formatInt` for grouping,
/// or a whole localised line such as "2 OF 3 DONE"); characters roll
/// individually, so grouping separators and surrounding words just sit still.
///
/// Two looks: [LBRollingNumber.new] in a [TextStyle] and
/// [LBRollingNumber.cells] in the dot-matrix cell font ([LBCellText]).
/// At rest both build exactly the widget they replace (a [Text] /
/// [LBCellText]); only during a roll does a small painter take over, driven
/// straight by the controller and isolated in a [RepaintBoundary].
///
/// Reduce motion: the new value appears at once.
class LBRollingNumber extends StatefulWidget {
  const LBRollingNumber(
    this.value, {
    super.key,
    this.format,
    this.style,
    this.textAlign,
    this.maxLines = 1,
    this.overflow,
    this.stagger = true,
    this.semanticsLabel,
  }) : cell = null,
       color = null,
       glow = false,
       offColor = null;

  /// The cell-font variant: same arguments as [LBCellText].
  const LBRollingNumber.cells(
    this.value, {
    super.key,
    this.format,
    double this.cell = 6,
    this.color,
    this.glow = false,
    this.offColor,
    this.stagger = true,
    this.semanticsLabel,
  }) : style = null,
       textAlign = null,
       maxLines = 1,
       overflow = null;

  final int value;

  /// Value → text. Defaults to the plain integer.
  final String Function(int value)? format;

  /// Rightmost characters move first, each [LBMotion.stagger] after the last.
  final bool stagger;

  final String? semanticsLabel;

  // Text variant.
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  // Cell variant.
  final double? cell;
  final Color? color;
  final bool glow;
  final Color? offColor;

  /// Total roll time for [rolling] characters.
  static Duration durationFor(int rolling, {bool stagger = true}) =>
      LBMotion.base +
      (stagger
          ? LBMotion.stagger * math.min(math.max(rolling - 1, 0), 3)
          : Duration.zero);

  @override
  State<LBRollingNumber> createState() => _LBRollingNumberState();
}

class _LBRollingNumberState extends State<LBRollingNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, value: 1)
    ..addStatusListener(_onStatus);

  /// The text currently shown (the target of the last roll).
  String? _text;
  LBRollPlan? _plan;
  int _dir = 1;

  String _format(int v) => widget.format?.call(v) ?? '$v';

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && mounted) setState(() => _plan = null);
  }

  @override
  void didUpdateWidget(LBRollingNumber old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    final from = _text ?? _format(old.value);
    final to = _format(widget.value);
    final plan = LBRollPlan.of(from, to);
    if (plan.isEmpty || LBMotion.reduced(context)) {
      _c.value = 1;
      _plan = null;
      return;
    }
    _plan = plan;
    _dir = widget.value > old.value ? 1 : -1;
    _c.duration = LBRollingNumber.durationFor(
      plan.slots.length,
      stagger: widget.stagger,
    );
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _format(widget.value);
    _text = text;
    final plan = _plan;
    final rolling = plan != null && _c.isAnimating && plan.to.join() == text;
    return widget.cell != null
        ? _buildCells(context, text, rolling ? plan : null)
        : _buildText(context, text, rolling ? plan : null);
  }

  _RollTiming get _timing =>
      _RollTiming(_c, _c.duration ?? LBMotion.base, widget.stagger);

  Widget _buildText(BuildContext context, String text, LBRollPlan? plan) {
    final label = Text(
      text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.maxLines != 1,
      semanticsLabel: widget.semanticsLabel,
    );
    if (plan == null) return label;
    final defaults = DefaultTextStyle.of(context);
    final style = defaults.style.merge(widget.style);
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        // Lays out (and announces) exactly like the resting Text, so the
        // roll never changes the widget's size or position.
        Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          maintainSemantics: true,
          child: label,
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _TextRollPainter(
                plan: plan,
                dir: _dir,
                timing: _timing,
                style: style,
                textAlign:
                    widget.textAlign ?? defaults.textAlign ?? TextAlign.start,
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: widget.maxLines,
                ellipsis: widget.overflow == TextOverflow.ellipsis ? '…' : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCells(BuildContext context, String text, LBRollPlan? plan) {
    final cell = widget.cell!;
    Widget rest() => LBCellText(
      text,
      cell: cell,
      color: widget.color,
      glow: widget.glow,
      offColor: widget.offColor,
      semanticsLabel: widget.semanticsLabel,
    );
    if (plan == null) return rest();
    final from = _CellRun.of(plan.from);
    final to = _CellRun.of(plan.to);
    // A character outside the cell font: LBCellText falls back to type,
    // which does not roll.
    if (from == null ||
        to == null ||
        plan.dropped.any((c) => !_CellRun.has(c))) {
      return rest();
    }
    return Semantics(
      label: widget.semanticsLabel ?? text,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(to.columns * cell, LBCellLayout.rows * cell),
            painter: _CellRollPainter(
              plan: plan,
              to: to,
              text: text,
              dir: _dir,
              timing: _timing,
              cell: cell,
              color: widget.color ?? context.lb.lime,
              glow: widget.glow,
              offColor: widget.offColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Maps the controller to each slot's eased 0→1 progress.
class _RollTiming {
  _RollTiming(this.animation, this.total, this.stagger);

  final Animation<double> animation;
  final Duration total;
  final bool stagger;

  double of(LBRollSlot s) => _at(stagger ? math.min(s.order, 3) : 0);

  /// Characters that leave without a replacement go with the leftmost slot.
  double dropped(int slotCount) =>
      _at(stagger ? math.min(math.max(slotCount - 1, 0), 3) : 0);

  double _at(int order) {
    final totalMs = total.inMicroseconds / 1000;
    final delay = LBMotion.stagger.inMicroseconds / 1000 * order;
    final base = LBMotion.base.inMicroseconds / 1000;
    final t = ((animation.value * totalMs - delay) / base).clamp(0.0, 1.0);
    return LBMotion.easeOutSoft.transform(t);
  }
}

// ---------------------------------------------------------------------------
// Text variant
// ---------------------------------------------------------------------------

class _TextRollPainter extends CustomPainter {
  _TextRollPainter({
    required this.plan,
    required this.dir,
    required this.timing,
    required this.style,
    required this.textAlign,
    required this.textDirection,
    required this.textScaler,
    required this.maxLines,
    required this.ellipsis,
  }) : super(repaint: timing.animation);

  final LBRollPlan plan;
  final int dir;
  final _RollTiming timing;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final int? maxLines;
  final String? ellipsis;

  // Laid out once per painter, reused every frame of the roll.
  TextPainter? _line;
  double? _lineWidth;
  final Map<String, TextPainter> _glyphs = {};

  TextPainter _glyph(String c) => _glyphs[c] ??= TextPainter(
    text: TextSpan(text: c, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (_line == null || _lineWidth != size.width) {
      // The static characters in the style's colour, the rolling ones
      // transparent: one paragraph with the exact metrics of the resting Text.
      final rolling = plan.rolling;
      final hidden = style.copyWith(color: const Color(0x00000000));
      _line?.dispose();
      _line = TextPainter(
        text: TextSpan(
          children: [
            for (var i = 0; i < plan.to.length; i++)
              TextSpan(
                text: plan.to[i],
                style: rolling.contains(i) ? hidden : style,
              ),
          ],
        ),
        textAlign: textAlign,
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: maxLines,
        ellipsis: ellipsis,
      )..layout(minWidth: size.width, maxWidth: size.width);
      _lineWidth = size.width;
    }
    final line = _line!;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    line.paint(canvas, Offset.zero);

    // Code-unit offset of each character, for selection boxes.
    final offsets = <int>[0];
    for (final c in plan.to) {
      offsets.add(offsets.last + c.length);
    }
    Rect? first;
    for (final slot in plan.slots) {
      final boxes = line.getBoxesForSelection(
        TextSelection(
          baseOffset: offsets[slot.index],
          extentOffset: offsets[slot.index + 1],
        ),
      );
      if (boxes.isEmpty) continue;
      final r = boxes.first.toRect();
      if (first == null || r.left < first.left) first = r;
      _roll(canvas, r, slot.from, slot.to, timing.of(slot));
    }
    if (plan.dropped.isNotEmpty && first != null) {
      final q = timing.dropped(plan.slots.length);
      var right = first.left;
      for (final c in plan.dropped.reversed) {
        final g = _glyph(c);
        final r = Rect.fromLTWH(
          right - g.width,
          first.top,
          g.width,
          first.height,
        );
        _roll(canvas, r, c, null, q);
        right -= g.width;
      }
    }
    canvas.restore();
  }

  void _roll(Canvas canvas, Rect r, String? from, String? to, double q) {
    final h = r.height;
    canvas.save();
    canvas.clipRect(
      r.inflate(r.width * .25).copyWith(top: r.top, bottom: r.bottom),
    );
    if (from != null && q < 1) {
      final g = _glyph(from);
      g.paint(canvas, Offset(r.center.dx - g.width / 2, r.top - dir * q * h));
    }
    if (to != null && q > 0) {
      final g = _glyph(to);
      g.paint(
        canvas,
        Offset(r.center.dx - g.width / 2, r.top + dir * (1 - q) * h),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TextRollPainter old) =>
      old.plan != plan ||
      old.dir != dir ||
      old.style != style ||
      old.textAlign != textAlign ||
      old.textDirection != textDirection ||
      old.textScaler != textScaler ||
      old.timing.animation != timing.animation;
}

extension on Rect {
  Rect copyWith({double? top, double? bottom}) =>
      Rect.fromLTRB(left, top ?? this.top, right, bottom ?? this.bottom);
}

// ---------------------------------------------------------------------------
// Cell variant
// ---------------------------------------------------------------------------

/// A string's glyphs on the cell grid, one column range per character.
class _CellRun {
  _CellRun._(this.glyphs, this.x, this.columns);

  final List<List<String>> glyphs;

  /// First column of each character.
  final List<int> x;
  final int columns;

  static bool has(String c) => lbCellGlyphs.containsKey(c.toUpperCase());

  static _CellRun? of(List<String> chars) {
    final glyphs = <List<String>>[];
    final x = <int>[];
    var col = 0;
    for (var i = 0; i < chars.length; i++) {
      final g = lbCellGlyphs[chars[i].toUpperCase()];
      if (g == null) return null;
      glyphs.add(g);
      x.add(col);
      col += g.first.length + (i == chars.length - 1 ? 0 : 1);
    }
    return _CellRun._(glyphs, x, col);
  }
}

class _CellRollPainter extends CustomPainter {
  _CellRollPainter({
    required this.plan,
    required this.to,
    required this.text,
    required this.dir,
    required this.timing,
    required this.cell,
    required this.color,
    required this.glow,
    required this.offColor,
  }) : super(repaint: timing.animation);

  final LBRollPlan plan;
  final _CellRun to;
  final String text;
  final int dir;
  final _RollTiming timing;
  final double cell;
  final Color color;
  final bool glow;
  final Color? offColor;

  static void _addGlyph(
    Path lit,
    Path? off,
    List<String> g,
    double left,
    double top,
    double cell,
    bool box,
  ) {
    final w = g.first.length;
    for (var r = 0; r < LBCellLayout.rows; r++) {
      for (var c = 0; c < w; c++) {
        final rect = lbCellRect(left + c * cell, top + r * cell, cell);
        if (g[r][c] == '1') {
          lit.addRRect(rect);
        } else if (box && off != null) {
          off.addRRect(rect);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final h = LBCellLayout.rows * cell;
    final rolling = {for (final s in plan.slots) s.index: s};
    final lit = Path();
    final off = offColor == null ? null : Path();
    for (var i = 0; i < plan.to.length; i++) {
      // Unlit cells stay put under a rolling glyph, like the board itself.
      final isSpace = plan.to[i] == ' ';
      if (rolling.containsKey(i)) {
        if (off != null && !isSpace) {
          _addGlyph(Path(), off, to.glyphs[i], to.x[i] * cell, 0, cell, true);
        }
      } else {
        _addGlyph(lit, off, to.glyphs[i], to.x[i] * cell, 0, cell, !isSpace);
      }
    }
    if (off != null) canvas.drawPath(off, Paint()..color = offColor!);

    if (glow) {
      // The resting glow, from the same cache entry LBCellText uses; drawing
      // a live blur under moving cells would cost a blur pass per frame.
      final layout = LBCellLayout.of(text);
      if (layout != null) {
        final path = Path();
        for (final (c, r) in layout.lit) {
          path.addRRect(lbCellRect(c * cell, r * cell, cell));
        }
        final glowColor = color.withValues(alpha: .5);
        final sigma = (cell * .9).clamp(2, 14).toDouble();
        LBGlowCache.drawPathGlow(
          canvas,
          key: (layout, cell, glowColor, sigma),
          path: path,
          color: glowColor,
          sigma: sigma,
        );
      }
    }

    final paint = Paint()..color = color;
    canvas.drawPath(lit, paint);

    int? firstX;
    for (final slot in plan.slots) {
      final g = to.glyphs[slot.index];
      final left = to.x[slot.index] * cell;
      firstX = firstX == null
          ? to.x[slot.index]
          : math.min(firstX, to.x[slot.index]);
      _roll(
        canvas,
        paint,
        left,
        g.first.length,
        slot.from,
        g,
        timing.of(slot),
        h,
      );
    }
    if (plan.dropped.isNotEmpty) {
      final q = timing.dropped(plan.slots.length);
      var right = (firstX ?? to.columns + 1) - 1;
      for (final c in plan.dropped.reversed) {
        final g = lbCellGlyphs[c.toUpperCase()]!;
        final w = g.first.length;
        _roll(canvas, paint, (right - w) * cell, w, c, null, q, h);
        right -= w + 1;
      }
    }
  }

  void _roll(
    Canvas canvas,
    Paint paint,
    double left,
    int width,
    String? from,
    List<String>? to,
    double q,
    double h,
  ) {
    final slot = Rect.fromLTWH(left, 0, width * cell, h);
    final path = Path();
    if (from != null && q < 1) {
      final g = lbCellGlyphs[from.toUpperCase()]!;
      final dx = (width - g.first.length) * cell / 2;
      _addGlyph(path, null, g, left + dx, -dir * q * h, cell, false);
    }
    if (to != null && q > 0) {
      _addGlyph(path, null, to, left, dir * (1 - q) * h, cell, false);
    }
    canvas.save();
    canvas.clipRect(slot.inflate(cell).copyWith(top: 0, bottom: h));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CellRollPainter old) =>
      old.plan != plan ||
      old.dir != dir ||
      old.cell != cell ||
      old.color != color ||
      old.glow != glow ||
      old.offColor != offColor ||
      old.timing.animation != timing.animation;
}
