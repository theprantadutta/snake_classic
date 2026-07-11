import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';

/// Brief red ring flashed at screen center when the cubit denies a direction
/// change. Subscribes only to `lastRejectedInputAt` so it doesn't drag the
/// game screen into per-tick rebuilds.
class RejectedInputFlash extends StatelessWidget {
  const RejectedInputFlash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GameCubit, GameCubitState, DateTime?>(
      selector: (state) => state.lastRejectedInputAt,
      builder: (context, stamp) {
        if (stamp == null) return const SizedBox.shrink();
        final age = DateTime.now().difference(stamp).inMilliseconds;
        if (age > 250) return const SizedBox.shrink();
        // Fade out over the 250ms window. The starting opacity is high so
        // the flash registers even on a fast glance.
        final t = (age.clamp(0, 250)) / 250.0;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return IgnorePointer(
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: opacity * 0.25),
                border: Border.all(
                  color: Colors.red.withValues(alpha: opacity * 0.85),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.do_disturb_alt_rounded,
                color: Colors.white.withValues(alpha: opacity * 0.85),
                size: 36,
              ),
            ),
          ),
        );
      },
    );
  }
}
