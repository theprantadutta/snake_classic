import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';

/// Post-crash chrome. The death itself plays IN-WORLD on the Flame board
/// (lunge → white body flash → tail-to-head disintegration with dust
/// poofs — see SnakeFlameGame's death sequence); this widget is only the
/// slim bottom banner that names the crash cause and owns the continue
/// countdown / tap-to-continue affordance.
///
/// It deliberately has NO dark barrier: the previous incarnation was a
/// full-screen "OOPS!" modal over an 80%-black scrim that hid the board
/// at the exact moment the death animation plays. The player should watch
/// their death, not a dialog. A transparent full-area tap target keeps
/// "tap anywhere to continue" working.
class CrashFeedbackOverlay extends StatelessWidget {
  final CrashReason crashReason;
  final GameTheme theme;
  final VoidCallback onSkip;
  final Duration duration;

  const CrashFeedbackOverlay({
    super.key,
    required this.crashReason,
    required this.theme,
    required this.onSkip,
    required this.duration,
  });

  bool get _untilTap =>
      duration.inSeconds == GameConstants.crashFeedbackUntilTap;

  @override
  Widget build(BuildContext context) {
    final s = context.uiScale;
    return Stack(
      children: [
        // Invisible full-area tap target — no scrim, the board stays
        // fully visible behind the banner.
        Positioned.fill(
          child: GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.fromLTRB(16 * s, 0, 16 * s, 20 * s),
            padding: EdgeInsets.symmetric(
              horizontal: 16 * s,
              vertical: 12 * s,
            ),
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.foodColor.withValues(alpha: 0.55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  crashReason.icon,
                  // Decorative glyph — scales with the card, not textScaler.
                  style: TextStyle(fontSize: 26 * s),
                ),
                SizedBox(width: 12 * s),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crashReason.message,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _untilTap
                            ? 'Tap anywhere to continue'
                            : 'Tap anywhere to skip',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.accentColor.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14 * s),
                if (_untilTap)
                  Icon(
                    Icons.touch_app_rounded,
                    size: 26 * s,
                    color: theme.accentColor.withValues(alpha: 0.8),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        duration: 700.ms,
                        begin: const Offset(1, 1),
                        end: const Offset(1.15, 1.15),
                      )
                else
                  _CountdownRing(theme: theme, duration: duration, scale: s),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.5, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }
}

/// Shrinking ring + seconds counter for the auto-continue countdown. The
/// cubit owns the actual game-over timer — this is display only.
class _CountdownRing extends StatelessWidget {
  final GameTheme theme;
  final Duration duration;
  final double scale;

  const _CountdownRing({
    required this.theme,
    required this.duration,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds = duration.inSeconds.toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: totalSeconds, end: 0.0),
      duration: duration,
      builder: (context, value, child) {
        return SizedBox(
          width: 36 * scale,
          height: 36 * scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: totalSeconds <= 0 ? 0 : value / totalSeconds,
                  strokeWidth: 3,
                  backgroundColor:
                      theme.accentColor.withValues(alpha: 0.15),
                  valueColor:
                      AlwaysStoppedAnimation(theme.foodColor),
                ),
              ),
              Text(
                '${value.ceil()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.foodColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
