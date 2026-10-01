import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_step.dart';

/// Styled tooltip widget for walkthrough steps
class WalkthroughTooltip extends StatelessWidget {
  /// The current walkthrough step
  final WalkthroughStep step;

  /// Current theme for styling
  final GameTheme theme;

  /// Callback when Next is tapped
  final VoidCallback onNext;

  /// Callback when Skip is tapped
  final VoidCallback onSkip;

  /// Current step index (0-based)
  final int currentStepIndex;

  /// Total number of steps
  final int totalSteps;

  /// Whether this is the last step
  final bool isLastStep;

  /// Whether this step is waiting for user input
  final bool isAwaitingInput;

  const WalkthroughTooltip({
    super.key,
    required this.step,
    required this.theme,
    required this.onNext,
    required this.onSkip,
    required this.currentStepIndex,
    required this.totalSteps,
    this.isLastStep = false,
    this.isAwaitingInput = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.sheet,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with icon and title
          Row(
            children: [
              if (step.icon != null) ...[
                LBMappedIcon(step.icon!, cell: 4, color: p.lime),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  step.title.toUpperCase(),
                  style: LBText.button(p, color: p.head, size: 14).copyWith(letterSpacing: 1.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Message content
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              step.message,
              style: LBText.body(p, color: p.ink.withValues(alpha: .82), size: 12.5),
            ),
          ),
          const SizedBox(height: 14),

          // Progress cells
          Center(child: LBStepCells(total: totalSteps, index: currentStepIndex)),
          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: step.canSkip
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: onSkip,
                          style: lbTextButtonStyle(p),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.wtSkip.toUpperCase(), maxLines: 1),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Flexible(flex: 3, child: _buildPrimaryButton(context, l10n)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, AppLocalizations l10n) {
    final p = context.lb;
    // If awaiting input, show a "waiting" state
    if (isAwaitingInput) {
      return LBBlock(
        kind: LBBlockKind.gold,
        height: context.lbCell * 2.4,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LBCellSpinner(count: 3, cell: 6, color: LB.gold),
              const SizedBox(width: 10),
              Text(
                l10n.wtWaiting.toUpperCase(),
                style: LBText.button(p, color: LB.gold, size: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Normal next/done button
    final buttonText = step.actionLabel ?? (isLastStep ? l10n.wtGotIt : l10n.wtNext);

    return LBBlock(
      kind: LBBlockKind.fill,
      height: context.lbCell * 2.4,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      onTap: onNext,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              buttonText.toUpperCase(),
              style: LBText.button(p, color: p.onLime, size: 12.5).copyWith(letterSpacing: 1.8),
            ),
            if (!isLastStep) ...[
              const SizedBox(width: 10),
              LBPixelIcon(
                Directionality.of(context) == TextDirection.rtl ? LBIcon.back : LBIcon.next,
                cell: 2.6,
                color: p.onLime,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
