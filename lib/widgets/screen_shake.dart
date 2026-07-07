import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ShakeIntensity { light, medium, heavy, extreme }

/// Holds the parameters of the current shake request. Pure state — the
/// frame loop lives in [ScreenShakeWidget], which drives a vsync
/// [Ticker] only while a shake is active. (Previously the controller
/// self-scheduled via recursive `Future.delayed(16ms)`, which wasn't
/// vsync-aligned and kept running even when nothing rendered it.)
class ScreenShakeController extends ChangeNotifier {
  bool _isShaking = false;
  double _intensity = 0.0;
  Duration _duration = Duration.zero;
  int _shakeSeq = 0;

  bool get isShaking => _isShaking;
  double get intensity => _intensity;
  Duration get duration => _duration;

  /// Monotonic counter bumped per shake() so the widget can restart its
  /// ticker when a new shake lands mid-shake.
  int get shakeSeq => _shakeSeq;

  void shake({
    ShakeIntensity intensity = ShakeIntensity.medium,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _intensity = _getIntensityValue(intensity);
    _duration = duration;
    _isShaking = true;
    _shakeSeq++;
    notifyListeners();
  }

  double _getIntensityValue(ShakeIntensity intensity) {
    switch (intensity) {
      case ShakeIntensity.light:
        return 2.0;
      case ShakeIntensity.medium:
        return 4.0;
      case ShakeIntensity.heavy:
        return 8.0;
      case ShakeIntensity.extreme:
        return 12.0;
    }
  }

  void stopShake() {
    if (!_isShaking) return;
    _isShaking = false;
    _intensity = 0.0;
    notifyListeners();
  }
}

class ScreenShakeWidget extends StatefulWidget {
  final Widget child;
  final ScreenShakeController controller;

  const ScreenShakeWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ScreenShakeWidget> createState() => _ScreenShakeWidgetState();
}

class _ScreenShakeWidgetState extends State<ScreenShakeWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final math.Random _random = math.Random();
  Offset _offset = Offset.zero;
  int _runningSeq = -1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(ScreenShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _ticker.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final c = widget.controller;
    if (c.isShaking) {
      // (Re)start on every new shake so a fresh request mid-shake gets
      // its full duration — Ticker elapsed resets on start().
      if (c.shakeSeq != _runningSeq) {
        _runningSeq = c.shakeSeq;
        _ticker.stop();
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
      setState(() => _offset = Offset.zero);
    }
  }

  void _onTick(Duration elapsed) {
    final c = widget.controller;
    if (elapsed >= c.duration) {
      _ticker.stop();
      setState(() => _offset = Offset.zero);
      c.stopShake();
      return;
    }
    final progress = elapsed.inMilliseconds / c.duration.inMilliseconds;
    final dampening = 1.0 - progress; // fade out over time
    final currentIntensity = c.intensity * dampening;
    setState(() {
      _offset = Offset(
        (_random.nextDouble() - 0.5) * 2 * currentIntensity,
        (_random.nextDouble() - 0.5) * 2 * currentIntensity,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(offset: _offset, child: widget.child);
  }
}

/// Game juice effects controller — maps game events onto shakes.
///
/// The old "scale punch" system was deleted outright: both game screens
/// mounted GameJuiceWidget with `applyScale: false`, so its 60fps
/// notifier loop ran on every food eaten while rendering NOTHING.
class GameJuiceController extends ChangeNotifier {
  final ScreenShakeController shakeController = ScreenShakeController();

  // Whether juice effects are enabled (controlled by settings)
  bool _shakeEnabled = true;
  bool get shakeEnabled => _shakeEnabled;
  set shakeEnabled(bool value) {
    _shakeEnabled = value;
    if (!value) {
      shakeController.stopShake(); // Stop any running shake
    }
  }

  // Screen shake for impacts
  void shakeScreen({
    ShakeIntensity intensity = ShakeIntensity.medium,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (!_shakeEnabled) return;
    shakeController.shake(intensity: intensity, duration: duration);
  }

  // Specific game event effects
  void foodEaten() {
    shakeScreen(
      intensity: ShakeIntensity.light,
      duration: const Duration(milliseconds: 100),
    );
  }

  void bonusFoodEaten() {
    shakeScreen(
      intensity: ShakeIntensity.medium,
      duration: const Duration(milliseconds: 200),
    );
  }

  void specialFoodEaten() {
    shakeScreen(
      intensity: ShakeIntensity.heavy,
      duration: const Duration(milliseconds: 300),
    );
  }

  void powerUpCollected() {
    shakeScreen(
      intensity: ShakeIntensity.medium,
      duration: const Duration(milliseconds: 250),
    );
  }

  void gameOver() {
    shakeScreen(
      intensity: ShakeIntensity.extreme,
      duration: const Duration(milliseconds: 500),
    );
  }

  void levelUp() {
    shakeScreen(
      intensity: ShakeIntensity.light,
      duration: const Duration(milliseconds: 150),
    );
  }

  void wallHit() {
    shakeScreen(
      intensity: ShakeIntensity.heavy,
      duration: const Duration(milliseconds: 400),
    );
  }

  void selfCollision() {
    shakeScreen(
      intensity: ShakeIntensity.heavy,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }
}

/// Shake wrapper for the game board area. Mount it around the BOARD, not
/// the Scaffold — shaking the whole screen dragged the banner ad along
/// with it, which looked cheap and is ad-policy-adjacent.
class GameJuiceWidget extends StatelessWidget {
  final Widget child;
  final GameJuiceController controller;
  final bool applyShake;

  const GameJuiceWidget({
    super.key,
    required this.child,
    required this.controller,
    this.applyShake = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!applyShake) return child;
    return ScreenShakeWidget(
      controller: controller.shakeController,
      child: child,
    );
  }
}
