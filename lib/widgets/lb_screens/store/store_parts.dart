import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/widgets/ads/rewarded_coins_button.dart'
    show watchAdForCoins;
import 'package:snake_classic/widgets/lb/lb.dart';

/// Living Board pieces for the store (screens 14/15). Presentation only:
/// every purchase, equip and restore decision stays in the screen that hosts
/// these widgets. The two rewarded-coin surfaces below are the exception —
/// they carry the SAME ad flow [RewardedCoinsPill] / [RewardedCoinsButton]
/// ran (same gating, same [watchAdForCoins] call, same placement labels).

/// Five swatch colours sampled from a cosmetic palette, as the grid blocks
/// show them. One colour alternates with a darker shade of itself, two
/// alternate, more are sampled evenly.
List<Color> storeSwatch(List<Color> palette, Color fallback, {int count = 5}) {
  if (palette.isEmpty) return List.filled(count, fallback);
  if (palette.length == 1) {
    final dark = Color.lerp(palette.first, Colors.black, .22)!;
    return [for (var i = 0; i < count; i++) i.isEven ? palette.first : dark];
  }
  if (palette.length == 2) {
    return [for (var i = 0; i < count; i++) palette[i % 2]];
  }
  return [
    for (var i = 0; i < count; i++)
      palette[((i * (palette.length - 1)) / (count - 1)).round()],
  ];
}

// ---------------------------------------------------------------------------
// Balance + free coins
// ---------------------------------------------------------------------------

/// The rewarded-coins plumbing shared by the balance block and the Coins tab
/// row. Mirrors [RewardedCoinsPill]: preload on mount, rebuild the moment an
/// ad becomes ready or ads are switched off (Pro), dim when nothing is
/// loaded, and grant through [watchAdForCoins].
mixin _RewardedCoinsAd<T extends StatefulWidget> on State<T> {
  /// Analytics label passed to [watchAdForCoins].
  String get placement;

  AdService? get ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    ads?.preloadRewarded();
    ads?.rewardedReadyListenable.addListener(_onReadyChanged);
    ads?.adsEnabledListenable.addListener(_onReadyChanged);
  }

  void _onReadyChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ads?.rewardedReadyListenable.removeListener(_onReadyChanged);
    ads?.adsEnabledListenable.removeListener(_onReadyChanged);
    super.dispose();
  }

  Future<void> watch() async {
    final a = ads;
    if (a == null) return;
    await watchAdForCoins(context, a, placement: placement);
    if (mounted) setState(() {});
  }

  /// False for Pro / web / no consent — the surface hides entirely.
  bool get adVisible {
    final a = ads;
    return a != null && a.adsEnabled;
  }

  bool get adReady => ads?.canShowFreeCoinAd ?? false;
}

/// Gold coin balance block plus the lime "+25¢ FREE · watch a short ad"
/// block (screen 14/15, top). The free block hides for Pro or when ads are
/// unavailable and the balance block takes the full row.
class StoreBalanceRow extends StatefulWidget {
  const StoreBalanceRow({super.key, required this.balance, this.bonusLabel});

  final int balance;

  /// "2x BONUS" chip for players with an earning multiplier.
  final String? bonusLabel;

  @override
  State<StoreBalanceRow> createState() => _StoreBalanceRowState();
}

class _StoreBalanceRowState extends State<StoreBalanceRow>
    with _RewardedCoinsAd<StoreBalanceRow> {
  @override
  String get placement => 'store_balance_pill';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final h = context.lbCell * 3;
    final showFree = adVisible;
    final ready = adReady;

    final balance = LBBlock(
      kind: LBBlockKind.gold,
      height: h,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          LBPixelIcon(LBIcon.coin, cell: 5 * context.uiScale, color: LB.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.formatInt(widget.balance),
                          maxLines: 1,
                          style: LBText.value(p, color: LB.gold, size: 24),
                        ),
                      ),
                    ),
                    if (widget.bonusLabel != null) ...[
                      const SizedBox(width: 8),
                      LBChip(
                        label: widget.bonusLabel!,
                        kind: LBChipKind.gold,
                        height: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.lbSnakeCoins,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.label(p).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!showFree) return balance;

    final fg = LBBlock.foregroundOf(LBBlockKind.fill, p);
    final free = Opacity(
      opacity: ready ? 1 : .5,
      child: LBBlock(
        kind: LBBlockKind.fill,
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        // The ad is its own feedback.
        feedback: false,
        onTap: ready ? watch : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.lbFreeCoins('${AdService.freeCoinsPerAd}'),
                maxLines: 1,
                style: LBText.button(p, color: fg, size: 13),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              ready ? l10n.lbFreeCoinsLine : l10n.rcNoAd,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: LBText.body(p, color: fg.withValues(alpha: .75), size: 10)
                  .copyWith(height: 1.2),
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        Expanded(flex: 5, child: balance),
        Expanded(flex: 3, child: free),
      ],
    );
  }
}

/// Full-width "watch an ad for coins" row on the Coins tab. Same flow as
/// [RewardedCoinsButton] (placement `store_free_coins`); hides for Pro.
class StoreRewardedCoinsRow extends StatefulWidget {
  const StoreRewardedCoinsRow({super.key});

  @override
  State<StoreRewardedCoinsRow> createState() => _StoreRewardedCoinsRowState();
}

class _StoreRewardedCoinsRowState extends State<StoreRewardedCoinsRow>
    with _RewardedCoinsAd<StoreRewardedCoinsRow> {
  @override
  String get placement => 'store_free_coins';

  @override
  Widget build(BuildContext context) {
    if (!adVisible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final ready = adReady;
    return Opacity(
      opacity: ready ? 1 : .5,
      child: LBBlock(
        kind: LBBlockKind.gold,
        feedback: false,
        onTap: ready ? watch : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            LBPixelIcon(LBIcon.tv, cell: 4, color: LB.gold),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.rcWatchAd(AdService.freeCoinsPerAd).toUpperCase(),
                    style: LBText.button(p, color: LB.gold, size: 12.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ready ? l10n.raOptIn : l10n.rcNoAd,
                    style: LBText.body(p, size: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabs
// ---------------------------------------------------------------------------

/// PRO · COINS · THEMES · SKINS · TRAILS · POWER-UPS as text tabs with a lime
/// underline (screen 14). Drives the screen's existing [TabController].
class StoreTabStrip extends StatelessWidget {
  const StoreTabStrip({
    super.key,
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final g = context.lbGutter;
    final style = LBText.button(p, size: 12.5).copyWith(letterSpacing: 1.2);
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsetsDirectional.only(start: g - 8, end: g - 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: p.lime, width: 3),
        borderRadius: BorderRadius.circular(2),
      ),
      dividerColor: Colors.transparent,
      labelColor: p.head,
      unselectedLabelColor: p.inkMuted,
      labelStyle: style,
      unselectedLabelStyle: style,
      overlayColor: WidgetStatePropertyAll(p.lime.withValues(alpha: .08)),
      splashBorderRadius: BorderRadius.circular(LB.blockRadius),
      tabs: [
        for (final l in labels) Tab(height: 48, text: l.toUpperCase()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Previews drawn in cells
// ---------------------------------------------------------------------------

/// The featured-card snake: 22 cells coiled into an S on an 8×5 grid, head
/// top-right (screen 15). [colors] is head-first and as long as [segments].
/// With [board] set it sits on a mini board in that palette with an apple —
/// the theme preview.
class StoreCellSnake extends StatelessWidget {
  const StoreCellSnake({
    super.key,
    required this.colors,
    this.cell = 11,
    this.board,
  });

  final List<Color> colors;
  final double cell;
  final LBPalette? board;

  /// Head first.
  static const List<(int, int)> _path = [
    (7, 0), (6, 0), (5, 0), (4, 0), (3, 0), (2, 0), (1, 0), //
    (1, 1),
    (1, 2), (2, 2), (3, 2), (4, 2), (5, 2), (6, 2), //
    (6, 3),
    (6, 4), (5, 4), (4, 4), (3, 4), (2, 4), (1, 4), (0, 4),
  ];

  static int get segments => _path.length;

  @override
  Widget build(BuildContext context) {
    final pad = board == null ? 0.0 : cell * .6;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(8 * cell + pad * 2, 5 * cell + pad * 2),
        painter: _CellSnakePainter(colors, cell, pad, board),
      ),
    );
  }
}

class _CellSnakePainter extends CustomPainter {
  _CellSnakePainter(this.colors, this.cell, this.pad, this.board);

  final List<Color> colors;
  final double cell;
  final double pad;
  final LBPalette? board;

  @override
  void paint(Canvas canvas, Size size) {
    final b = board;
    if (b != null) {
      final rr = RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(LB.blockRadius),
      );
      canvas.drawRRect(rr, Paint()..color = b.board);
      canvas.save();
      canvas.clipRRect(rr);
      final grid = Paint()
        ..color = b.lime.withValues(alpha: .12)
        ..strokeWidth = 1;
      for (var x = pad; x < size.width; x += cell) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      }
      for (var y = pad; y < size.height; y += cell) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
      canvas.restore();
      canvas.drawRRect(
        rr.deflate(.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = b.lime.withValues(alpha: .35),
      );
      // The apple, in the theme's food colour.
      canvas.drawRRect(
        lbCellRect(pad + 3 * cell, pad + 3 * cell, cell),
        Paint()..color = b.food,
      );
    }
    final path = StoreCellSnake._path;
    for (var i = 0; i < path.length && i < colors.length; i++) {
      final (c, r) = path[i];
      canvas.drawRRect(
        lbCellRect(pad + c * cell, pad + r * cell, cell),
        Paint()..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(_CellSnakePainter old) =>
      old.cell != cell ||
      old.pad != pad ||
      old.board != board ||
      !listEquals(old.colors, colors);
}

/// A row of five colour cells (grid-block swatch). Decorative.
class StoreSwatch extends StatelessWidget {
  const StoreSwatch({
    super.key,
    required this.colors,
    this.cell = 12,
    this.background,
  });

  final List<Color> colors;
  final double cell;

  /// Painted behind the cells (theme blocks show their board colour).
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final pad = background == null ? 0.0 : 3.0;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(colors.length * cell + pad * 2, cell + pad * 2),
        painter: _SwatchPainter(colors, cell, pad, background),
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.colors, this.cell, this.pad, this.background);

  final List<Color> colors;
  final double cell;
  final double pad;
  final Color? background;

  @override
  void paint(Canvas canvas, Size size) {
    if (background != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
        Paint()..color = background!,
      );
    }
    for (var i = 0; i < colors.length; i++) {
      canvas.drawRRect(
        lbCellRect(pad + i * cell, pad, cell),
        Paint()..color = colors[i],
      );
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter old) =>
      old.cell != cell ||
      old.pad != pad ||
      old.background != background ||
      !listEquals(old.colors, colors);
}

// ---------------------------------------------------------------------------
// Cards, blocks, buttons
// ---------------------------------------------------------------------------

/// Small indeterminate spinner for "verifying" states.
class StoreSpinner extends StatelessWidget {
  const StoreSpinner({super.key, required this.color, this.size = 12});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 1.6,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
}

/// A compact action block — `BUY · $1.99`, `EQUIP`, `APPLY`. Sizes to its
/// label; 48 dp tall with the inset. [busy] shows a spinner and disables it.
class StoreActionBlock extends StatelessWidget {
  const StoreActionBlock({
    super.key,
    required this.label,
    this.kind = LBBlockKind.outline,
    this.onTap,
    this.busy = false,
    this.feedback = true,
  });

  final String label;
  final LBBlockKind kind;
  final VoidCallback? onTap;
  final bool busy;
  final bool feedback;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = LBBlock.foregroundOf(kind, p);
    return LBBlock(
      kind: kind,
      height: 46,
      feedback: feedback,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      onTap: busy ? null : onTap,
      // A loose Flexible in a min Row: shrinks inside a bounded card column,
      // sizes to the label as a non-flex child of a Row.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            StoreSpinner(color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: LBText.button(p, color: fg, size: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The big card at the top of a catalogue tab (screen 15): a preview, the
/// item's name and line, its one action and an optional footnote.
class StoreFeaturedCard extends StatelessWidget {
  const StoreFeaturedCard({
    super.key,
    required this.preview,
    required this.title,
    required this.line,
    required this.action,
    this.titleColor,
    this.footnote,
    this.badge,
  });

  final Widget preview;
  final String title;
  final String line;
  final Widget action;
  final Color? titleColor;
  final String? footnote;

  /// Shown above the title (e.g. a POPULAR chip).
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Row(
        children: [
          preview,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[badge!, const SizedBox(height: 6)],
                Text(
                  title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: titleColor ?? p.head, size: 15)
                      .copyWith(letterSpacing: 1.6),
                ),
                const SizedBox(height: 5),
                Text(
                  line,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.body(p, size: 11.5),
                ),
                const SizedBox(height: 10),
                action,
                if (footnote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    footnote!,
                    style: LBText.body(p, color: p.inkDim, size: 10.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One block of a catalogue grid (screen 15): a five-cell swatch, the name
/// and a status line (price / EQUIPPED / EQUIP / VERIFYING). Lay these out
/// with [StoreCatalogGrid], which sizes the blocks to their content.
class StoreItemBlock extends StatelessWidget {
  const StoreItemBlock({
    super.key,
    required this.swatch,
    required this.name,
    required this.status,
    required this.statusColor,
    this.focused = false,
    this.active = false,
    this.busy = false,
    this.onTap,
    this.swatchBackground,
    this.nameLines = 1,
  });

  final List<Color> swatch;
  final String name;
  final String status;
  final Color statusColor;

  /// Shown in the featured card above — gold outline.
  final bool focused;

  /// Equipped / applied — full lime outline.
  final bool active;
  final bool busy;
  final VoidCallback? onTap;
  final Color? swatchBackground;

  /// Lines the name may wrap to (the grid picks 1 or 2 for the whole row set).
  final int nameLines;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(11, 11, 8, 9);
  static const double gap = 7;

  static TextStyle nameStyle(LBPalette p) =>
      LBText.button(p, color: p.ink, size: 11.5)
          .copyWith(letterSpacing: 1, height: 1.25);

  static TextStyle statusStyle(LBPalette p, Color c) =>
      LBText.button(p, color: c, size: 11.5)
          .copyWith(letterSpacing: .8, height: 1.25);

  static double swatchCell(BuildContext context) => 12 * context.uiScale;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return Semantics(
      selected: active,
      child: LBBlock(
        kind: focused ? LBBlockKind.gold : LBBlockKind.outline,
        selected: focused || active,
        onTap: onTap,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StoreSwatch(
              colors: swatch,
              cell: swatchCell(context),
              background: swatchBackground,
            ),
            Text(
              name.toUpperCase(),
              maxLines: nameLines,
              overflow: TextOverflow.ellipsis,
              style: nameStyle(p),
            ),
            Row(
              children: [
                if (busy) ...[
                  StoreSpinner(color: statusColor, size: 10),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      status,
                      maxLines: 1,
                      style: statusStyle(p, statusColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The catalogue grid: three columns on phones (360–430 dp), more on
/// tablets. Block height is measured, not fixed: names that need two lines
/// at this width get them (no truncation), and when every name fits on one
/// line the blocks stay short (no empty band inside each block).
class StoreCatalogGrid extends StatelessWidget {
  const StoreCatalogGrid({super.key, required this.items});

  final List<StoreItemBlock> items;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final scaler = MediaQuery.textScalerOf(context);
    final dir = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final cols = (c.maxWidth / (130 * context.uiScale)).ceil().clamp(3, 8);
        final cellW = c.maxWidth / cols;
        final pad = StoreItemBlock.padding;
        final inner = cellW - LB.inset * 2 - pad.horizontal;

        double measure(String text, TextStyle style, int maxLines) {
          final tp = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: dir,
            textScaler: scaler,
            maxLines: maxLines,
          )..layout(maxWidth: inner);
          final h = tp.height;
          tp.dispose();
          return h;
        }

        final nameStyle = StoreItemBlock.nameStyle(p);
        var lines = 1;
        for (final item in items) {
          final tp = TextPainter(
            text: TextSpan(text: item.name.toUpperCase(), style: nameStyle),
            textDirection: dir,
            textScaler: scaler,
          )..layout(maxWidth: inner);
          if (tp.computeLineMetrics().length > 1) lines = 2;
          tp.dispose();
        }
        final nameH = measure(List.filled(lines, 'W').join('\n'), nameStyle, lines);
        final statusH = measure('W', StoreItemBlock.statusStyle(p, p.ink), 1);
        final hasBg = items.any((i) => i.swatchBackground != null);
        final swatchH = StoreItemBlock.swatchCell(context) + (hasBg ? 6 : 0);
        final extent = LB.inset * 2 +
            pad.vertical +
            swatchH +
            StoreItemBlock.gap +
            nameH +
            StoreItemBlock.gap * .7 +
            statusH;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: extent.ceilToDouble(),
          ),
          children: [
            for (final item in items)
              StoreItemBlock(
                key: item.key,
                swatch: item.swatch,
                name: item.name,
                status: item.status,
                statusColor: item.statusColor,
                focused: item.focused,
                active: item.active,
                busy: item.busy,
                onTap: item.onTap,
                swatchBackground: item.swatchBackground,
                nameLines: lines,
              ),
          ],
        );
      },
    );
  }
}

/// A scrolling column that is at least as tall as the space it is given, so
/// children may use [Expanded] / [Spacer] to take up spare height on tall
/// phones instead of leaving an empty band under the content. On short
/// phones it simply scrolls.
class StoreFillScroll extends StatelessWidget {
  const StoreFillScroll({
    super.key,
    required this.children,
    required this.padding,
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (c.maxHeight - padding.vertical).clamp(0, double.infinity),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cell size for a featured-card preview: [base] on a 360 dp phone, growing
/// with the phone's width up to 20% so wider phones don't get a postage
/// stamp, and with uiScale on tablets.
double storePreviewCell(BuildContext context, double base) {
  final s = context.uiScale;
  if (s != 1) return base * s;
  final w = MediaQuery.sizeOf(context).width;
  return base * (w / 360).clamp(1.0, 1.2);
}
