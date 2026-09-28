import 'dart:async';

import 'package:flutter/widgets.dart';

/// Swallows every tap on [child] for [delay] after it first appears.
///
/// For buttons that pop up under a thumb that was already moving: the revive
/// offer lands mid-swipe, the game over bar lands while the player is still
/// steering, the ad intro lands on the second half of a double-tap. Without
/// this a tap aimed at the board or the previous button is taken as a choice —
/// and when that choice is "watch an ad", Google counts what follows as an
/// accidental click. The September 2026 AdMob audit found interstitial CTR at
/// 53% in August, which is that failure at scale.
///
/// Absorbs rather than ignores, so the stray tap doesn't fall through to
/// whatever is underneath either.
class TapArmGuard extends StatefulWidget {
  const TapArmGuard({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration delay;

  @override
  State<TapArmGuard> createState() => _TapArmGuardState();
}

class _TapArmGuardState extends State<TapArmGuard> {
  bool _armed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _armed = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AbsorbPointer(absorbing: !_armed, child: widget.child);
}
