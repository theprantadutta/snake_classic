import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_row_layout.dart';
import 'package:snake_classic/widgets/joystick_controls.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/steerable_dpad.dart';
import 'package:snake_classic/widgets/turn_buttons.dart';

/// The control zone under the board: the same rectangle for every control
/// layout, so the board never moves when the player switches controls.
/// What fills it changes with the layout, and each fills it its own way:
///
///   - swipe       → [swipeZone], a second swipe surface with the compass.
///   - d-pad       → the pad, as large as the zone allows (capped), placed
///                   left / centre / right by [dPadPosition].
///   - turn        → both buttons, as tall as the zone allows (capped).
///   - joystick    → the whole zone is the stick: the thumb lands anywhere.
///
/// The read-outs (length, speed) live in the info row under the board for
/// every layout, so the zone carries controls only.
///
/// The zone's [height] is fixed for a run (the layout is a setting and cannot
/// change mid-game), so the board never reflows while the player steers.
/// Without a [height] the zone falls back to the old fixed bar size.
class GameBottomBar extends StatelessWidget {
  const GameBottomBar({
    super.key,
    this.gameState,
    required this.theme,
    required this.isSmallScreen,
    required this.dPadEnabled,
    required this.onDirection,
    this.dPadPosition = DPadPosition.bottomCenter,
    this.controlLayout = ControlLayout.dPad,
    this.onRelativeTurn,
    this.canSteerOverride,
    this.height,
    this.swipeZone,
  });

  /// Decides whether the control is live (it is while playing). Versus has
  /// no solo game state and passes [canSteerOverride] instead.
  final GameState? gameState;
  final GameTheme theme;
  final bool isSmallScreen;
  final bool dPadEnabled;
  final void Function(Direction) onDirection;

  /// Forces the d-pad's usable state instead of deriving it from the game
  /// status. Only the game tutorial sets it: it pauses the game and then asks
  /// for a turn, so the control has to work while the status says paused.
  /// Null everywhere else, which keeps the ordinary rule.
  final bool? canSteerOverride;

  /// Where the player asked for the d-pad, from settings.
  final DPadPosition dPadPosition;

  /// Which on-screen control [dPadEnabled] draws. Turn buttons need
  /// [onRelativeTurn]; without it the zone falls back to the d-pad.
  final ControlLayout controlLayout;
  final void Function(RelativeTurn)? onRelativeTurn;

  /// The zone's full height. Null keeps the old fixed bar size.
  final double? height;

  /// What a swipe player gets in the zone (when [dPadEnabled] is false).
  final Widget? swipeZone;

  /// The old fixed bar: the d-pad footprint plus its padding.
  static double legacyHeight(BuildContext context, bool isSmallScreen) {
    final scale = context.uiScale;
    return (isSmallScreen ? 120.0 : 135.0) * scale +
        2 * (isSmallScreen ? 8.0 : 12.0) * scale;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final zone = height ?? legacyHeight(context, isSmallScreen);
    final pad = 10 * scale;
    final inner = math.max(0.0, zone - pad * 2 - 8 * scale);
    // Normally "you may steer" means "the game is running". The tutorial is
    // the one exception: it deliberately pauses the game and then asks the
    // player to turn, so it passes true and the control stays live.
    final isInteractive =
        canSteerOverride ?? gameState?.status == GameStatus.playing;

    final Widget control;
    if (!dPadEnabled) {
      control = swipeZone ?? const SizedBox.shrink();
    } else if (controlLayout == ControlLayout.turnButtons &&
        onRelativeTurn != null) {
      // Taller is easier to hit blind, up to a point: past ~1.5 d-pads a
      // button stops being a target and becomes a wall.
      control = Center(
        child: SteerableTurnButtons(
          onTurn: onRelativeTurn!,
          theme: theme,
          height: math.min(inner, 220 * scale),
          canSteer: isInteractive,
        ),
      );
    } else if (controlLayout == ControlLayout.joystick) {
      // The stick floats: wherever the thumb lands is the centre, so every
      // spare dp of the zone is usable surface.
      control = SteerableJoystick(
        onDirection: onDirection,
        theme: theme,
        height: inner,
        canSteer: isInteractive,
      );
    } else {
      // Grows with the zone, capped so a thumb can still cross it.
      final size = math.min(inner, 190 * scale);
      control = Center(
        child: SizedBox(
          height: size,
          child: DPadRowLayout.build(
            position: dPadPosition,
            dPad: SteerableDPad(
              onDirection: onDirection,
              theme: theme,
              size: size,
              canSteer: isInteractive,
            ),
            leading: (_) => const SizedBox.shrink(),
            trailing: (_) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    return SizedBox(
      height: zone,
      child: Padding(
        // A little extra air at the foot, so the control is not pressed
        // against the system gesture bar.
        padding: EdgeInsets.fromLTRB(
          12 * scale,
          pad,
          12 * scale,
          pad + 8 * scale,
        ),
        child: control,
      ),
    );
  }
}
