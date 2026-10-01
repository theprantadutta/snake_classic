import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb/lb_crash_copy.dart';

/// Post-crash chrome. The death itself plays IN-WORLD on the Flame board
/// (lunge → shake → white flash → tail-to-head disintegration); this widget
/// is only the slim bottom block that names the crash (BONK! / OUCH.) and
/// owns the continue countdown / tap-to-continue affordance.
///
/// No scrim: the player should watch their death, not a dialog. A
/// transparent full-area tap target keeps "tap anywhere to continue" working.
class CrashFeedbackOverlay extends StatefulWidget {
  final CrashReason crashReason;
  final GameTheme theme;
  final VoidCallback onSkip;
  final Duration duration;

  /// The crashed run, for the length in the wall line.
  final GameState? gameState;

  const CrashFeedbackOverlay({
    super.key,
    required this.crashReason,
    required this.theme,
    required this.onSkip,
    required this.duration,
    this.gameState,
  });

  @override
  State<CrashFeedbackOverlay> createState() => _CrashFeedbackOverlayState();
}

class _CrashFeedbackOverlayState extends State<CrashFeedbackOverlay> {
  final int _seed = DateTime.now().millisecondsSinceEpoch;

  bool get _untilTap => widget.duration.inSeconds == GameConstants.crashFeedbackUntilTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final gs = widget.gameState;
    final reason = gs != null
        ? LBCrashCopy.reasonOf(gs)
        : (widget.crashReason == CrashReason.wallCollision ? LBEndReason.wall : LBEndReason.self);
    final copy = LBCrashCopy.of(l10n, reason, length: gs?.snake.length ?? 0, food: 0, seed: _seed);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onSkip,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(context.lbGutter, 0, context.lbGutter, context.lbCell),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, (1 - t) * 30), child: child),
              ),
              child: LBBlock(
                kind: LBBlockKind.sheet,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    LBCellText(copy.title, cell: 4.2, color: LB.bonk, glow: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.line,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: LBText.body(p, color: p.ink, size: 12).copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _untilTap ? l10n.cfTapContinue : l10n.cfTapSkip,
                            style: LBText.body(p, size: 10.5),
                          ),
                        ],
                      ),
                    ),
                    if (!_untilTap) ...[
                      const SizedBox(width: 10),
                      _Countdown(duration: widget.duration),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draining cells + seconds for the auto-continue countdown. The cubit owns
/// the real game-over timer — this is display only.
class _Countdown extends StatelessWidget {
  const _Countdown({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final total = duration.inMilliseconds.toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      builder: (context, v, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(v * total / 1000).ceil()}',
            style: LBText.button(context.lb, color: LB.bonk, size: 14),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 30,
            child: LBCellsBar(
              count: 3,
              value: v,
              color: LB.bonk,
              offColor: LB.bonk.withValues(alpha: .15),
            ),
          ),
        ],
      ),
    );
  }
}
