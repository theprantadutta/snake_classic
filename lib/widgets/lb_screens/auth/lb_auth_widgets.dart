import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/lb/lb_markdown.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Living Board pieces shared by the account screens (first-time sign-in,
/// email, username, privacy re-consent) and the account sheets. Presentation
/// only: every callback is passed in by the screen that owns the behaviour.

/// Indeterminate "working" indicator: a short snake crawling along a row of
/// cells. Replaces the Material spinner on account surfaces.
class LBBusyCells extends StatefulWidget {
  const LBBusyCells({super.key, this.count = 8, this.cell = 10, this.color, this.semanticsLabel});

  final int count;
  final double cell;

  /// Body colour; the head is drawn a step lighter. Defaults to the palette.
  final Color? color;
  final String? semanticsLabel;

  @override
  State<LBBusyCells> createState() => _LBBusyCellsState();
}

class _LBBusyCellsState extends State<LBBusyCells> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 110 * (widget.count + 3)),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final body = widget.color ?? p.lime;
    final head = widget.color == null ? p.head : Color.lerp(widget.color, Colors.white, .3)!;
    return Semantics(
      label: widget.semanticsLabel,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size(widget.cell * widget.count, widget.cell),
            painter: _BusyPainter(
              count: widget.count,
              cell: widget.cell,
              // Head index runs off the end so the tail clears before looping.
              headAt: (_c.value * (widget.count + 3)).floor(),
              body: body,
              head: head,
              off: p.cellOff,
            ),
          ),
        ),
      ),
    );
  }
}

class _BusyPainter extends CustomPainter {
  _BusyPainter({
    required this.count,
    required this.cell,
    required this.headAt,
    required this.body,
    required this.head,
    required this.off,
  });

  final int count;
  final double cell;
  final int headAt;
  final Color body;
  final Color head;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < count; i++) {
      final d = headAt - i;
      final color = d == 0 ? head : (d > 0 && d < 3 ? body.withValues(alpha: 1 - d * .25) : off);
      canvas.drawRRect(lbCellRect(i * cell, 0, cell), Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_BusyPainter old) =>
      old.headAt != headAt ||
      old.body != body ||
      old.head != head ||
      old.off != off ||
      old.cell != cell;
}

/// The one loud action on an account screen: a lime fill block with an
/// uppercase label. Disabled (null [onTap]) renders muted and announces
/// itself as a disabled button. [busy] keeps the lime, swaps the label for
/// [LBBusyCells] and ignores taps — like a button disabled behind a spinner.
class LBPrimaryBlock extends StatelessWidget {
  const LBPrimaryBlock({
    super.key,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.icon,
    this.height = 54,
  });

  final String label;

  /// Null = disabled.
  final VoidCallback? onTap;
  final bool busy;
  final LBIcon? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final lit = onTap != null || busy;
    final interactive = onTap != null && !busy;
    final kind = lit ? LBBlockKind.fill : LBBlockKind.muted;
    final fg = LBBlock.foregroundOf(kind, p);
    final Widget child = busy
        ? LBBusyCells(count: 6, cell: 9, color: fg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                LBPixelIcon(icon!, cell: 3.4, color: fg),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: fg, size: 14),
                ),
              ),
            ],
          );
    // A minimum, not a fixed height: a long translated label wraps to a
    // second line and the block grows instead of clipping it.
    final block = LBBlock(
      kind: kind,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: interactive ? onTap : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height * context.uiScale - 22),
        child: Center(child: child),
      ),
    );
    if (interactive) return block;
    return Semantics(
      button: true,
      enabled: false,
      label: label,
      excludeSemantics: true,
      child: block,
    );
  }
}

/// A full-width sign-in option: provider mark + uppercase label, centred.
/// [accent] tints the outline (used for the Apple option, which keeps
/// Apple's black/white button colours).
class LBAuthOptionBlock extends StatelessWidget {
  const LBAuthOptionBlock({
    super.key,
    required this.label,
    required this.leading,
    required this.onTap,
    this.kind = LBBlockKind.outline,
    this.accent,
    this.foreground,
  });

  final String label;
  final Widget leading;
  final VoidCallback? onTap;
  final LBBlockKind kind;
  final Color? accent;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = foreground ?? LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      accent: accent,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      // Minimum height; long translations wrap and the block grows.
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 54 * context.uiScale - 22),
        child: Row(
          children: [
            SizedBox(width: 26, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LBText.button(p, color: fg, size: 13),
              ),
            ),
            LBPixelIcon(LBIcon.next, cell: 2.6, color: fg.withValues(alpha: .7)),
          ],
        ),
      ),
    );
  }
}

/// A checkbox drawn as a block: one cell that lights with a check, plus the
/// statement being agreed to. The whole block is the hit target.
class LBCheckBlock extends StatelessWidget {
  const LBCheckBlock({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final box = 22.0 * context.uiScale;
    return MergeSemantics(
      child: Semantics(
        checked: value,
        child: LBBlock(
          selected: value,
          onTap: () => onChanged(!value),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              SizedBox.square(
                dimension: box,
                child: CustomPaint(
                  painter: _CheckCellPainter(
                    fill: value ? p.lime : p.cellOff,
                    stroke: value ? p.lime : p.blockStroke,
                  ),
                  child: value
                      ? Center(
                          child: LBPixelIcon(LBIcon.check, cell: box / 7.5, color: p.onLime),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: LBText.body(p, color: p.ink, size: 12.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckCellPainter extends CustomPainter {
  _CheckCellPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = lbCellRect(0, 0, size.width);
    canvas.drawRRect(r, Paint()..color = fill);
    canvas.drawRRect(
      r.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = stroke,
    );
  }

  @override
  bool shouldRepaint(_CheckCellPainter old) => old.fill != fill || old.stroke != stroke;
}

/// Two side-by-side tab blocks driven by a [TabController]. The selected
/// tab is a full-stroke outline (the screen's fill is kept for its CTA).
class LBTabBlocks extends StatelessWidget {
  const LBTabBlocks({super.key, required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: controller.index == i,
                child: LBBlock(
                  selected: controller.index == i,
                  kind: controller.index == i ? LBBlockKind.outline : LBBlockKind.muted,
                  height: 46 * context.uiScale,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  onTap: () => controller.animateTo(i),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[i].toUpperCase(),
                      maxLines: 1,
                      style: LBText.button(
                        p,
                        color: controller.index == i ? p.head : p.inkMuted,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Privacy Policy + Terms of Use, swipeable, inside one outline block.
/// Shows [LBBusyCells] while [loading].
class LBLegalTabs extends StatefulWidget {
  const LBLegalTabs({
    super.key,
    required this.privacyLabel,
    required this.termsLabel,
    required this.privacy,
    required this.terms,
    this.loading = false,
  });

  final String privacyLabel;
  final String termsLabel;
  final String privacy;
  final String terms;
  final bool loading;

  @override
  State<LBLegalTabs> createState() => _LBLegalTabsState();
}

class _LBLegalTabsState extends State<LBLegalTabs> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Widget _doc(String content) => LBMarkdown(data: content);

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const LBBlock(alignment: Alignment.center, child: LBBusyCells());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LBTabBlocks(controller: _tabs, labels: [widget.privacyLabel, widget.termsLabel]),
        const SizedBox(height: 4),
        Expanded(
          child: LBBlock(
            padding: EdgeInsets.zero,
            child: TabBarView(
              controller: _tabs,
              children: [_doc(widget.privacy), _doc(widget.terms)],
            ),
          ),
        ),
      ],
    );
  }
}

/// Input decoration for account forms: an outline block look (6% fill,
/// 32% stroke, radius 6), lime when focused, bonk-red on error.
InputDecoration lbInputDecoration(
  BuildContext context, {
  required String label,
  String? helperText,
  String? errorText,
  Widget? suffixIcon,
}) {
  final p = context.lb;
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(LB.blockRadius),
    borderSide: BorderSide(color: c, width: w),
  );
  return InputDecoration(
    labelText: label.toUpperCase(),
    labelStyle: LBText.label(p).copyWith(fontSize: 11),
    floatingLabelStyle: LBText.label(p, color: p.lime).copyWith(fontSize: 11),
    helperText: helperText,
    helperStyle: LBText.body(p, color: p.inkDim, size: 11),
    errorText: errorText,
    errorStyle: LBText.body(p, color: LB.bonk, size: 11),
    errorMaxLines: 3,
    counterStyle: LBText.label(p, color: p.inkDim),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: p.blockFill,
    border: border(p.blockStroke),
    enabledBorder: border(p.blockStroke),
    disabledBorder: border(p.cellOff),
    focusedBorder: border(p.lime, 1.5),
    errorBorder: border(LB.bonkStroke),
    focusedErrorBorder: border(LB.bonk, 1.5),
  );
}

/// Text style typed into account form fields.
TextStyle lbInputStyle(BuildContext context) => LBText.value(context.lb, size: 15);

/// Eye toggle for password fields, with a proper accessibility label.
class LBPasswordEye extends StatelessWidget {
  const LBPasswordEye({
    super.key,
    required this.obscured,
    required this.onToggle,
    required this.showLabel,
    required this.hideLabel,
  });

  final bool obscured;
  final VoidCallback onToggle;
  final String showLabel;
  final String hideLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return IconButton(
      tooltip: obscured ? showLabel : hideLabel,
      onPressed: onToggle,
      icon: LBPixelIcon(LBIcon.eye, cell: 3.6, color: obscured ? p.inkMuted : p.lime),
    );
  }
}
