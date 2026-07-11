import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';

/// Debug-build-only gameplay performance overlay.
///
/// Shows, live, the three numbers that matter when the game "feels laggy":
///  - **tick**: the scheduled tick duration vs the measured gap between
///    state emits (a widening gap = the logic tick is being delayed);
///  - **frame**: the worst raster+build frame time over the last second
///    (spikes past ~16.7ms are visible jank);
///  - **events**: the most recent simulation events, so you can see whether
///    a hitch lines up with an eat / level-up / power-up.
///
/// Renders nothing in release/profile builds. Wrap in an `if (kDebugMode)`
/// at the call site anyway so the subtree isn't even built.
class DebugPerfOverlay extends StatefulWidget {
  const DebugPerfOverlay({super.key});

  @override
  State<DebugPerfOverlay> createState() => _DebugPerfOverlayState();
}

class _DebugPerfOverlayState extends State<DebugPerfOverlay> {
  StreamSubscription<GameCubitState>? _sub;
  TimingsCallback? _timingsCallback;

  DateTime? _lastTickAt;
  int _measuredGapMs = 0;
  int _scheduledTickMs = 0;
  int _worstFrameMs = 0;
  final Queue<String> _recentEvents = Queue();

  // Frame timings accumulate between repaints; keep the worst in a 1s window.
  final Queue<(DateTime, int)> _frameWindow = Queue();

  Timer? _repaintTimer;

  @override
  void initState() {
    super.initState();
    if (!kDebugMode) return;

    final cubit = context.read<GameCubit>();
    var lastGameState = cubit.state.gameState;
    _sub = cubit.stream.listen((state) {
      if (identical(state.gameState, lastGameState)) return;
      lastGameState = state.gameState;
      final now = DateTime.now();
      if (_lastTickAt != null) {
        _measuredGapMs = now.difference(_lastTickAt!).inMilliseconds;
      }
      _lastTickAt = now;
      _scheduledTickMs = state.tickDurationMs ?? 0;
      for (final e in state.tickEvents) {
        _recentEvents.addFirst(_eventLabel(e));
        while (_recentEvents.length > 4) {
          _recentEvents.removeLast();
        }
      }
    });

    _timingsCallback = (timings) {
      final now = DateTime.now();
      for (final t in timings) {
        _frameWindow.add((now, t.totalSpan.inMilliseconds));
      }
      final cutoff = now.subtract(const Duration(seconds: 1));
      while (_frameWindow.isNotEmpty && _frameWindow.first.$1.isBefore(cutoff)) {
        _frameWindow.removeFirst();
      }
      var worst = 0;
      for (final (_, ms) in _frameWindow) {
        if (ms > worst) worst = ms;
      }
      _worstFrameMs = worst;
    };
    SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);

    // Repaint the panel at 4Hz — cheap, and fast enough to read live.
    _repaintTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  String _eventLabel(TickEvent e) => switch (e) {
        FoodEatenEvent() =>
          'eat ${e.food.type.name} +${e.awardedPoints}',
        LeveledUpEvent() => 'level ${e.fromLevel}→${e.toLevel}',
        PowerUpCollectedEvent() => 'pickup ${e.powerUp.type.name}',
        ComboBrokenEvent() => 'combo broken (${e.previousCombo})',
        CrashEvent() => 'CRASH ${e.reason.name}',
      };

  @override
  void dispose() {
    _sub?.cancel();
    _repaintTimer?.cancel();
    if (_timingsCallback != null) {
      SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final tickHealthy = _scheduledTickMs == 0 ||
        _measuredGapMs <= _scheduledTickMs + 25;
    final frameHealthy = _worstFrameMs <= 17;

    TextStyle line(bool healthy) => TextStyle(
          color: healthy ? const Color(0xFF7CFC7C) : const Color(0xFFFF6B6B),
          fontSize: 10,
          height: 1.3,
          fontFamily: 'monospace',
        );

    return IgnorePointer(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.only(left: 4, top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'tick ${_measuredGapMs}ms / ${_scheduledTickMs}ms',
                style: line(tickHealthy),
              ),
              Text(
                'frame worst ${_worstFrameMs}ms',
                style: line(frameHealthy),
              ),
              for (final e in _recentEvents)
                Text(
                  e,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    height: 1.25,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
