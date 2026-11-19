import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_motion.dart';

/// Screen-open choreography (MOTION_SPEC "Screen open"): the child fades in
/// and rises [rise] dp over [LBMotion.gentle] (easeOutSoft), starting
/// `index * LBMotion.stagger` after the entrance began. Indices past
/// [maxStaggered] - 1 enter with the last staggered item.
///
/// The entrance runs once per State: rebuilds (setState, new data) never
/// replay it. Inside an [LBStaggerGroup] every item shares the group's
/// clock, so an item built later (a list row scrolled into view after the
/// entrance) appears already in place instead of entering on its own.
///
/// Reduce motion: a plain [LBMotion.reducedFade] fade, no rise, no stagger.
class LBStaggerIn extends StatefulWidget {
  const LBStaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.rise = 8,
  });

  final int index;
  final Widget child;

  /// dp the child rises while it fades in.
  final double rise;

  /// Items staggered before the rest arrive together.
  static const int maxStaggered = 8;

  /// From the first item starting to the last staggered one landing.
  static Duration get totalDuration => LBMotion.stagger * (maxStaggered - 1) + LBMotion.gentle;

  @override
  State<LBStaggerIn> createState() => _LBStaggerInState();
}

class _LBStaggerInState extends State<LBStaggerIn> with SingleTickerProviderStateMixin {
  AnimationController? _own;
  Animation<double>? _clock;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clock != null) return; // entrance already set up: never again.
    final group = LBStaggerGroup._maybeOf(context);
    if (group != null) {
      _clock = group.clock;
      _reduced = group.reduced;
      return;
    }
    _reduced = LBMotion.reduced(context);
    _own = AnimationController(
      vsync: this,
      duration: _reduced ? LBMotion.reducedFade : LBStaggerIn.totalDuration,
    )..forward();
    _clock = _own;
  }

  CurvedAnimation? _curve;
  int? _curveIndex;

  /// This item's slice of the clock (cached: a CurvedAnimation listens to
  /// its parent until disposed).
  Animation<double> _slice() {
    final i = widget.index.clamp(0, LBStaggerIn.maxStaggered - 1);
    if (_curve != null && _curveIndex == i) return _curve!;
    _curve?.dispose();
    final total = LBStaggerIn.totalDuration.inMicroseconds;
    final start = (LBMotion.stagger * i).inMicroseconds / total;
    final end = (start + LBMotion.gentle.inMicroseconds / total).clamp(0.0, 1.0);
    _curveIndex = i;
    return _curve = CurvedAnimation(
      parent: _clock!,
      curve: Interval(start, end, curve: LBMotion.easeOutSoft),
    );
  }

  @override
  void dispose() {
    _curve?.dispose();
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduced) {
      return FadeTransition(opacity: _clock!, child: widget.child);
    }
    final t = _slice();
    return AnimatedBuilder(
      animation: t,
      child: widget.child,
      builder: (context, child) {
        final v = t.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, widget.rise * (1 - v)), child: child),
        );
      },
    );
  }
}

/// One shared entrance clock for a set of [LBStaggerIn] items (a screen's
/// list). Starts on the group's first build and runs once; LBScaffold puts
/// one around its children.
class LBStaggerGroup extends StatefulWidget {
  const LBStaggerGroup({super.key, required this.child});

  final Widget child;

  static _LBStaggerScope? _maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_LBStaggerScope>();

  @override
  State<LBStaggerGroup> createState() => _LBStaggerGroupState();
}

class _LBStaggerGroupState extends State<LBStaggerGroup> with SingleTickerProviderStateMixin {
  AnimationController? _clock;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_clock != null) return;
    _reduced = LBMotion.reduced(context);
    _clock = AnimationController(
      vsync: this,
      duration: _reduced ? LBMotion.reducedFade : LBStaggerIn.totalDuration,
    )..forward();
  }

  @override
  void dispose() {
    _clock?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _LBStaggerScope(clock: _clock!, reduced: _reduced, child: widget.child);
}

class _LBStaggerScope extends InheritedWidget {
  const _LBStaggerScope({required this.clock, required this.reduced, required super.child});

  final Animation<double> clock;
  final bool reduced;

  @override
  bool updateShouldNotify(_LBStaggerScope old) => false;
}
