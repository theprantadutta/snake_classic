import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart' show lbCellRect;

/// A coin counter that [LBCoinFly] can land on.
///
/// Wrap the readout in it and build the coin icon through the `icon` wrapper
/// the builder receives: coins fly to that icon, it pops when they land
/// (springPop), and the number holds its old value while they are in the
/// air, so it rolls up as they arrive instead of before they leave.
///
/// Every mounted target registers itself; [LBCoinFly.play] without an
/// explicit target lands on the most recently mounted one that is on screen
/// (Home's coin readout, the Store balance), or flies to the top-right
/// corner when none is.
class LBCoinTarget extends StatefulWidget {
  const LBCoinTarget({super.key, required this.value, required this.builder});

  /// The live balance.
  final int value;

  /// Builds the readout from the value to show (held during a flight) and a
  /// wrapper for the coin icon.
  final Widget Function(
    BuildContext context,
    int value,
    Widget Function(Widget icon) icon,
  )
  builder;

  @override
  State<LBCoinTarget> createState() => LBCoinTargetState();
}

class LBCoinTargetState extends State<LBCoinTarget>
    with SingleTickerProviderStateMixin {
  static final List<LBCoinTargetState> _mounted = [];

  /// The target a flight from [context] lands on when none is named: the
  /// newest one whose route is showing (an opaque route above a target
  /// turns its tickers off, so covered screens drop out).
  static LBCoinTargetState? visible() {
    for (final t in _mounted.reversed) {
      if (t.isOnScreen) return t;
    }
    return null;
  }

  final GlobalKey _iconKey = GlobalKey();
  late final AnimationController _bump = AnimationController(
    vsync: this,
    duration: LBMotion.slow,
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.3,
      ).chain(CurveTween(curve: LBMotion.easeOutSoft)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.3,
        end: 1.0,
      ).chain(CurveTween(curve: LBMotion.springPop)),
      weight: 70,
    ),
  ]).animate(_bump);

  late int _shown = widget.value;
  int _holds = 0;

  bool get isOnScreen {
    if (!mounted) return false;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    return TickerMode.getValuesNotifier(context).value.enabled;
  }

  /// Global rect of the coin icon (or the whole readout when the builder
  /// did not use the icon wrapper).
  Rect? get iconRect {
    final ctx = _iconKey.currentContext ?? (mounted ? context : null);
    final box = ctx?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Keeps showing the current number until [release].
  void hold() => _holds++;

  /// Lets the number catch up (it rolls) and pops the icon.
  void release({bool bump = true}) {
    if (_holds > 0) _holds--;
    if (!mounted) return;
    if (_holds == 0 && _shown != widget.value) {
      setState(() => _shown = widget.value);
    }
    if (bump && !LBMotion.reduced(context)) _bump.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _mounted.add(this);
  }

  @override
  void didUpdateWidget(LBCoinTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_holds == 0) _shown = widget.value;
  }

  @override
  void dispose() {
    _mounted.remove(this);
    _bump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _shown,
    (icon) => ScaleTransition(
      scale: _scale,
      child: KeyedSubtree(key: _iconKey, child: icon),
    ),
  );
}

/// Coins flying to a counter: the reward beat (MOTION_SPEC: reward / coins).
///
/// A handful of gold cells leave [from] on short curved paths and land on a
/// coin counter ([LBCoinTarget]); the counter then rolls up and its icon
/// pops. One overlay entry, one controller, one painter: no widget per coin.
abstract final class LBCoinFly {
  /// Identifies the overlay layer while a flight is on screen (tests).
  static const Key layerKey = ValueKey('lb-coin-fly');

  /// Flies [coins] coins from [from] (global coordinates) to [to] (an
  /// [LBCoinTarget]'s key, or any widget's key), else to the visible
  /// [LBCoinTarget], else to the top-right corner. Completes when the
  /// last coin has landed and the overlay is gone.
  ///
  /// Call it before crediting the coins: the target holds its number until
  /// the first coin lands, so the count rolls up on arrival.
  ///
  /// Reduce motion: no flight (the counter just updates).
  static Future<void> play(
    BuildContext context, {
    required Rect from,
    GlobalKey? to,
    int coins = 8,
  }) {
    if (LBMotion.reduced(context)) return Future.value();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final overlayBox = overlay?.context.findRenderObject();
    if (overlay == null || overlayBox is! RenderBox || !overlayBox.hasSize) {
      return Future.value();
    }

    LBCoinTargetState? target;
    Rect? dest;
    final named = to?.currentState;
    if (named is LBCoinTargetState) {
      target = named;
      dest = named.iconRect;
    } else if (to != null) {
      final box = to.currentContext?.findRenderObject();
      if (box is RenderBox && box.attached && box.hasSize) {
        dest = box.localToGlobal(Offset.zero) & box.size;
      }
    } else {
      target = LBCoinTargetState.visible();
      dest = target?.iconRect;
    }

    final size = overlayBox.size;
    final pad = MediaQuery.paddingOf(context);
    // Read everything from [context] now. The overlay rebuilds the entry
    // while the coins are in the air, and by then the caller (a sheet or
    // screen that claimed the reward) may already be gone: touching its
    // context inside the builder threw "Null check operator used on a null
    // value" from MediaQuery.of (SNAKE-CLASSIC-FLUTTER-20).
    final cell = 9 * context.uiScale;
    final end = dest != null
        ? overlayBox.globalToLocal(dest.center)
        : Offset(size.width - 36, pad.top + 28);
    final start = Rect.fromPoints(
      overlayBox.globalToLocal(from.topLeft),
      overlayBox.globalToLocal(from.bottomRight),
    );

    target?.hold();
    final done = Completer<void>();
    var released = false;
    void land() {
      if (released) return;
      released = true;
      target?.release();
    }

    var removed = false;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CoinFlyLayer(
        key: layerKey,
        start: start,
        end: end,
        coins: coins.clamp(1, 16),
        cell: cell,
        onFirstLanding: land,
        onDone: () {
          land();
          if (!removed) {
            removed = true;
            entry.remove();
            entry.dispose();
          }
          if (!done.isCompleted) done.complete();
        },
      ),
    );
    overlay.insert(entry);
    return done.future;
  }

  /// A sensible coin count for an amount: more coins for bigger rewards.
  static int coinsFor(int amount) => (amount / 5).round().clamp(5, 12);

  /// Global rect of the widget [key] is on, or null if it is not laid out.
  static Rect? rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

class _CoinFlyLayer extends StatefulWidget {
  const _CoinFlyLayer({
    super.key,
    required this.start,
    required this.end,
    required this.coins,
    required this.cell,
    required this.onFirstLanding,
    required this.onDone,
  });

  final Rect start;
  final Offset end;
  final int coins;
  final double cell;
  final VoidCallback onFirstLanding;
  final VoidCallback onDone;

  @override
  State<_CoinFlyLayer> createState() => _CoinFlyLayerState();
}

class _CoinFlyLayerState extends State<_CoinFlyLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: LBMotion.slow,
  );
  late final List<_Coin> _coins = _Coin.spread(
    widget.start,
    widget.end,
    widget.coins,
  );

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      if (_c.value >= 1 - _Coin.spreadFraction) widget.onFirstLanding();
    });
    _c.forward().whenCompleteOrCancel(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CoinFlyPainter(_c, _coins, widget.cell),
      ),
    ),
  );
}

/// One coin's path: a quadratic curve that bows out to one side.
class _Coin {
  _Coin(this.p0, this.p1, this.p2, this.delay);

  final Offset p0, p1, p2;

  /// Start, as a fraction of the flight.
  final double delay;

  /// How much of the flight the departures are spread over.
  static const double spreadFraction = .35;

  static List<_Coin> spread(Rect from, Offset to, int n) {
    final rnd = math.Random(n * 7919 + from.center.dx.round());
    return [
      for (var i = 0; i < n; i++)
        () {
          final p0 = Offset(
            from.left + from.width * (.2 + .6 * rnd.nextDouble()),
            from.top + from.height * (.25 + .5 * rnd.nextDouble()),
          );
          final d = to - p0;
          final normal = Offset(-d.dy, d.dx) / math.max(d.distance, 1);
          final bow =
              d.distance * (.18 + .17 * rnd.nextDouble()) * (i.isEven ? 1 : -1);
          // Bow sideways and lift a little, so the coins arc rather than slide.
          final p1 = p0 + d * .5 + normal * bow + Offset(0, -d.distance * .12);
          return _Coin(p0, p1, to, n == 1 ? 0 : spreadFraction * i / (n - 1));
        }(),
    ];
  }

  /// Eased 0→1 progress at flight time [t], or null before departure.
  double? progress(double t) {
    final local = (t - delay) / (1 - spreadFraction);
    if (local <= 0) return null;
    return LBMotion.travel.transform(local.clamp(0.0, 1.0));
  }

  Offset at(double q) {
    final u = 1 - q;
    return p0 * (u * u) + p1 * (2 * u * q) + p2 * (q * q);
  }
}

class _CoinFlyPainter extends CustomPainter {
  _CoinFlyPainter(this.animation, this.coins, this.cell)
    : super(repaint: animation);

  final Animation<double> animation;
  final List<_Coin> coins;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final gold = Paint()..color = LB.gold;
    final shine = Paint()..color = LB.goldHead;
    for (final coin in coins) {
      final q = coin.progress(t);
      if (q == null || q >= 1) continue;
      final p = coin.at(q);
      // Grow in over the first stretch, shrink into the counter at the end.
      final s =
          cell * (q < .15 ? .5 + q / .15 * .5 : 1 - .35 * ((q - .15) / .85));
      final rect = lbCellRect(p.dx - s / 2, p.dy - s / 2, s);
      canvas.drawRRect(rect, gold);
      // A lit corner, like the coin pixel icon.
      canvas.drawRRect(
        lbCellRect(p.dx - s / 2 + s * .14, p.dy - s / 2 + s * .14, s * .38),
        shine,
      );
    }
  }

  @override
  bool shouldRepaint(_CoinFlyPainter old) =>
      old.coins != coins || old.cell != cell;
}
