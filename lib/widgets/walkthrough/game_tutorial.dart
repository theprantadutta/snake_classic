import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_step.dart';

/// How a tutorial run ended.
///
/// Both endings resume the game and mark the tutorial seen; only the
/// analytics differ, and that difference is the whole measurement.
enum TutorialOutcome { finished, skipped }

/// Controller for the interactive game tutorial
class GameTutorialController extends ChangeNotifier {
  /// Localized step list. Supplied/refreshed by [GameTutorialOverlay]'s
  /// build (which has access to the ambient [AppLocalizations]) via
  /// [updateSteps]. Structural fields (ids, order, isInteractive, keys)
  /// are identical across locales, so swapping the list mid-tutorial is
  /// safe — only the display text changes.
  List<WalkthroughStep> _steps = const [];

  int _currentStep = 0;
  bool _awaitingInput = false;
  Direction? _expectedDirection;
  bool _isComplete = false;
  ValueChanged<TutorialOutcome>? _onFinished;

  /// Current step index
  int get currentStep => _currentStep;

  /// Whether the tutorial is waiting for user input
  bool get awaitingInput => _awaitingInput;

  /// The direction the user should swipe (for practice steps)
  Direction? get expectedDirection => _expectedDirection;

  /// Whether the tutorial has been completed
  bool get isComplete => _isComplete;

  /// The single owner of "the tutorial is over".
  ///
  /// Called exactly once per run, from [complete], with how it ended. The
  /// overlay used to call [skip] AND a separate onSkip callback that ran the
  /// screen's completion handler a second time — two resumes, and a setState
  /// against a controller the first pass had disposed.
  set onFinished(ValueChanged<TutorialOutcome>? callback) {
    _onFinished = callback;
  }

  /// Get all tutorial steps
  List<WalkthroughStep> get steps => _steps;

  /// Provide/refresh the localized steps. Called from the overlay's build;
  /// intentionally does NOT notify listeners (it runs during build).
  void updateSteps(List<WalkthroughStep> steps) {
    _steps = steps;
  }

  /// Get the current step data
  WalkthroughStep? get currentStepData {
    if (_currentStep >= _steps.length) return null;
    return _steps[_currentStep];
  }

  /// Start the tutorial
  void start() {
    _currentStep = 0;
    _isComplete = false;
    _checkForInteractiveStep();
    notifyListeners();
  }

  /// Handle swipe input during tutorial
  /// Returns true if the input was consumed by the tutorial
  bool onSwipeDetected(Direction direction) {
    if (!_awaitingInput || _expectedDirection == null) return false;

    if (direction == _expectedDirection) {
      // Correct swipe! Advance to next step
      _awaitingInput = false;
      _expectedDirection = null;
      advance();
      return true;
    }

    // Wrong direction - notify but don't advance
    notifyListeners();
    return true; // Still consume the input
  }

  /// Advance to the next step
  void advance() {
    if (_currentStep < _steps.length - 1) {
      _currentStep++;
      _checkForInteractiveStep();
      notifyListeners();
    } else {
      // Tutorial complete
      complete();
    }
  }

  /// Skip the tutorial
  void skip() => _finish(TutorialOutcome.skipped);

  /// Mark the tutorial as complete
  void complete() => _finish(TutorialOutcome.finished);

  void _finish(TutorialOutcome outcome) {
    if (_isComplete) return;
    _isComplete = true;
    _awaitingInput = false;
    _expectedDirection = null;
    _onFinished?.call(outcome);
    notifyListeners();
  }

  /// Check if the current step is interactive and set up accordingly
  void _checkForInteractiveStep() {
    final step = currentStepData;
    if (step == null) return;

    if (step.isInteractive) {
      _awaitingInput = true;
      // Set expected direction based on step ID
      _expectedDirection = _getExpectedDirection(step.id);
    } else {
      _awaitingInput = false;
      _expectedDirection = null;
    }
  }

  Direction? _getExpectedDirection(String stepId) {
    switch (stepId) {
      case 'tutorial_practice_right':
        return Direction.right;
      case 'tutorial_practice_up':
        return Direction.up;
      default:
        return null;
    }
  }

  /// Reset the controller
  void reset() {
    _currentStep = 0;
    _awaitingInput = false;
    _expectedDirection = null;
    _isComplete = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _onFinished = null;
    super.dispose();
  }
}

/// GlobalKeys for game tutorial targets
class GameTutorialKeys {
  static final hudKey = GlobalKey();

  /// Spotlight target for the tutorial_pause step — the pause icon in
  /// the HUD's top-right. Wired via GameHUD(pauseButtonKey: ...).
  static final pauseButtonKey = GlobalKey();
  static final scoreKey = GlobalKey();
  static final levelKey = GlobalKey();
  static final gameBoardKey = GlobalKey();
}

/// Tutorial steps for the game screen (localized)
List<WalkthroughStep> _buildTutorialSteps(AppLocalizations l10n) => [
  // Step 1: Welcome
  WalkthroughStep(
    id: 'tutorial_welcome',
    title: l10n.wtWelcomeTitle,
    message: l10n.wtWelcomeMsg,
    position: TooltipPosition.center,
    icon: Icons.school,
    canSkip: true,
  ),

  // Step 2: HUD overview
  WalkthroughStep(
    id: 'tutorial_hud',
    title: l10n.wtHudTitle,
    message: l10n.wtHudMsg,
    targetKey: GameTutorialKeys.hudKey,
    position: TooltipPosition.below,
    icon: Icons.dashboard,
  ),

  // Step 3: Controls intro
  WalkthroughStep(
    id: 'tutorial_controls',
    title: l10n.wtControlsTitle,
    message: l10n.wtControlsMsg,
    position: TooltipPosition.center,
    icon: Icons.swipe,
  ),

  // Step 4: Practice - Swipe Right (Interactive)
  WalkthroughStep(
    id: 'tutorial_practice_right',
    title: l10n.wtPracticeRightTitle,
    message: l10n.wtPracticeRightMsg,
    position: TooltipPosition.center,
    icon: Icons.arrow_forward,
    isInteractive: true,
    canSkip: false,
  ),

  // Step 5: Practice - Swipe Up (Interactive)
  WalkthroughStep(
    id: 'tutorial_practice_up',
    title: l10n.wtPracticeUpTitle,
    message: l10n.wtPracticeUpMsg,
    position: TooltipPosition.center,
    icon: Icons.arrow_upward,
    isInteractive: true,
    canSkip: false,
  ),

  // Step 5b: Control options. Taught right after the player has steered
  // once, so 'prefer buttons?' lands on someone who now knows what
  // swiping feels like. Everything named here is one pause away.
  WalkthroughStep(
    id: 'tutorial_control_options',
    title: l10n.wtControlOptionsTitle,
    message: l10n.wtControlOptionsMsg,
    position: TooltipPosition.center,
    icon: Icons.gamepad,
  ),
  // Step 6: Food explanation. Food TYPES + point values are intentionally
  // not taught here — the pause menu's Game Guide carries that reference
  // (and the food chip on the HUD shows the current type's value live).
  WalkthroughStep(
    id: 'tutorial_food',
    title: l10n.wtFoodTitle,
    message: l10n.wtFoodMsg,
    position: TooltipPosition.center,
    icon: Icons.restaurant,
  ),

  // Step 7: Combo system.
  WalkthroughStep(
    id: 'tutorial_combo',
    title: l10n.wtComboTitle,
    message: l10n.wtComboMsg,
    position: TooltipPosition.center,
    icon: Icons.local_fire_department,
  ),

  // Step 8: Power-ups.
  WalkthroughStep(
    id: 'tutorial_powerups',
    title: l10n.wtPowerUpsTitle,
    message: l10n.wtPowerUpsMsg,
    position: TooltipPosition.center,
    icon: Icons.bolt,
  ),

  // Step 9: Avoid walls
  WalkthroughStep(
    id: 'tutorial_walls',
    title: l10n.wtWallsTitle,
    message: l10n.wtWallsMsg,
    position: TooltipPosition.center,
    icon: Icons.warning_amber,
  ),

  // Step 10: Don't hit yourself
  WalkthroughStep(
    id: 'tutorial_self',
    title: l10n.wtSelfTitle,
    message: l10n.wtSelfMsg,
    position: TooltipPosition.center,
    icon: Icons.do_not_disturb_on,
  ),

  // Step 11: Pause menu. Spotlights the pause icon in the HUD's top-right.
  WalkthroughStep(
    id: 'tutorial_pause',
    title: l10n.wtPauseTitle,
    message: l10n.wtPauseMsg,
    targetKey: GameTutorialKeys.pauseButtonKey,
    position: TooltipPosition.below,
    icon: Icons.pause_circle_outline,
    spotlightPadding: 6,
    spotlightBorderRadius: 14,
  ),

  // Step 12: Complete
  WalkthroughStep(
    id: 'tutorial_complete',
    title: l10n.wtReadyTitle,
    message: l10n.wtReadyMsg,
    position: TooltipPosition.center,
    icon: Icons.celebration,
    actionLabel: l10n.wtStartPlaying,
  ),
];

/// Overlay widget for the game tutorial
class GameTutorialOverlay extends StatelessWidget {
  final GameTutorialController controller;
  final GameTheme theme;

  const GameTutorialOverlay({
    super.key,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Supply/refresh the localized steps before reading step data so
        // the controller always renders in the ambient locale.
        controller.updateSteps(
          _buildTutorialSteps(AppLocalizations.of(context)!),
        );
        final step = controller.currentStepData;
        if (step == null || controller.isComplete) {
          return const SizedBox.shrink();
        }

        return WalkthroughOverlayWidget(
          step: step,
          theme: theme,
          currentStepIndex: controller.currentStep,
          totalSteps: controller.steps.length,
          isAwaitingInput: controller.awaitingInput,
          expectedDirection: controller.expectedDirection,
          onNext: controller.advance,
          onSkip: controller.skip,
        );
      },
    );
  }
}

/// Simple overlay widget for game tutorial (without the full walkthrough system)
class WalkthroughOverlayWidget extends StatelessWidget {
  final WalkthroughStep step;
  final GameTheme theme;
  final int currentStepIndex;
  final int totalSteps;
  final bool isAwaitingInput;
  final Direction? expectedDirection;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const WalkthroughOverlayWidget({
    super.key,
    required this.step,
    required this.theme,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.isAwaitingInput,
    this.expectedDirection,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    // For interactive steps, show a floating card at the top instead of full overlay
    if (isAwaitingInput) {
      return _buildInteractiveOverlay(context);
    }

    // For non-interactive steps, show the normal centered modal
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: context.lb.board.withValues(alpha: 0.86),
        child: SafeArea(
          child: Center(
            // Scrolls only when a long step meets a short phone or large text.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildTooltip(context),
            ),
          ),
        ),
      ),
    );
  }

  /// The practice steps, laid over a live board.
  ///
  /// Everything here except the skip button is pointer-transparent, and that
  /// is the fix: this used to be one full-screen GestureDetector with its own
  /// horizontal/vertical drag handlers, so it swallowed every touch before
  /// the board or the D-pad could see it. A player with the D-pad enabled
  /// could see their control, press it, and have nothing happen — the
  /// tutorial demanded a swipe from someone who had chosen not to swipe.
  ///
  /// Now the real controls deliver the input. The board's SwipeDetector and
  /// the D-pad both call the screen's direction handler, which routes to this
  /// tutorial while it is running, so all three input methods work and the
  /// practice step is practising the controls the player actually uses.
  Widget _buildInteractiveOverlay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Dim, so the instruction reads over a busy board. Non-interactive.
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: context.lb.board.withValues(alpha: .3)),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                child: _buildInteractiveCard(context, l10n),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: _buildSwipeHint(context, l10n),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCard(BuildContext context, AppLocalizations l10n) {
    final p = context.lb;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: LBBlock(
        kind: LBBlockKind.sheet,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (step.icon != null)
                  LBMappedIcon(step.icon!, cell: 4, color: LB.gold)
                else
                  const LBPixelIcon(LBIcon.next, cell: 4, color: LB.gold),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    step.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: LBText.button(p, color: LB.gold, size: 15).copyWith(letterSpacing: 1.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Direction arrow
            if (expectedDirection != null) _buildLargeDirectionArrow(context, l10n),
            const SizedBox(height: 4),
            // Skip button
            TextButton(
              onPressed: onSkip,
              style: lbTextButtonStyle(p),
              child: Text(l10n.wtSkipTutorial.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }

  String? _directionText(AppLocalizations l10n) => switch (expectedDirection) {
    Direction.right => l10n.wtSwipeRightUpper,
    Direction.left => l10n.wtSwipeLeftUpper,
    Direction.up => l10n.wtSwipeUpUpper,
    Direction.down => l10n.wtSwipeDownUpper,
    null => null,
  };

  Widget _buildLargeDirectionArrow(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final direction = expectedDirection;
    final text = _directionText(l10n);
    if (direction == null || text == null) return const SizedBox.shrink();
    final p = context.lb;

    return LBBlock(
      kind: LBBlockKind.fill,
      height: context.lbCell * 3,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LBArrowIcon(direction: direction, cell: 6, color: p.onLime),
            const SizedBox(width: 14),
            Text(
              text,
              style: LBText.button(p, color: p.onLime, size: 17).copyWith(letterSpacing: 2.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeHint(BuildContext context, AppLocalizations l10n) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.sheet,
      height: context.lbCell * 2.2,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LBPixelIcon(LBIcon.plus, cell: 3, color: p.lime),
            const SizedBox(width: 10),
            Text(
              l10n.wtSwipeAnywhereScreen,
              style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: LBBlock(
        kind: LBBlockKind.sheet,
        padding: const EdgeInsets.fromLTRB(18, 20, 14, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            if (step.icon != null) ...[
              LBMappedIcon(step.icon!, cell: 5, color: p.lime),
              const SizedBox(height: 12),
            ],
            Text(
              step.title.toUpperCase(),
              style: LBText.button(p, color: p.head, size: 15).copyWith(letterSpacing: 1.8),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Message
            Text(
              step.message,
              style: LBText.body(p, color: p.ink.withValues(alpha: .82), size: 12.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Direction hint for interactive steps
            if (isAwaitingInput && expectedDirection != null) _buildDirectionHint(context, l10n),

            // Progress cells
            LBStepCells(total: totalSteps, index: currentStepIndex),
            const SizedBox(height: 8),

            // Buttons
            _buildButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionHint(BuildContext context, AppLocalizations l10n) {
    final direction = expectedDirection;
    final text = _directionText(l10n);
    if (direction == null || text == null) return const SizedBox.shrink();
    final p = context.lb;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LBBlock(
        kind: LBBlockKind.gold,
        height: context.lbCell * 2.4,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LBArrowIcon(direction: direction, cell: 4.4, color: LB.gold),
              const SizedBox(width: 12),
              Text(
                text,
                style: LBText.button(p, color: LB.gold, size: 14).copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, AppLocalizations l10n) {
    final p = context.lb;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Always show skip button (even for interactive steps)
        Flexible(
          child: TextButton(
            onPressed: onSkip,
            style: lbTextButtonStyle(p),
            child: Text(
              l10n.wtSkipTutorial.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (!isAwaitingInput)
          Flexible(
            child: LBBlock(
              kind: LBBlockKind.fill,
              height: context.lbCell * 2.4,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              onTap: onNext,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (step.actionLabel ??
                          (currentStepIndex == totalSteps - 1 ? l10n.wtGotIt : l10n.wtNext))
                      .toUpperCase(),
                  maxLines: 1,
                  style: LBText.button(p, color: p.onLime, size: 12.5).copyWith(letterSpacing: 1.8),
                ),
              ),
            ),
          )
        else
          // Show hint text for interactive steps
          Flexible(
            child: Text(
              l10n.wtSwipeAnywhere,
              textAlign: TextAlign.end,
              style: LBText.body(p, color: LB.gold, size: 12),
            ),
          ),
      ],
    );
  }
}
