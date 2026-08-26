import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/typography.dart';
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
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: SafeArea(
          child: Center(
            child: Padding(
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
          const Positioned.fill(
            child: IgnorePointer(child: ColoredBox(color: Color(0x4D000000))),
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
                  child: _buildSwipeHint(l10n),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.foodColor.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.foodColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: HudCorners(
        color: theme.foodColor,
        inset: 8,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(step.icon ?? Icons.swipe, color: theme.foodColor, size: 28),
              const SizedBox(width: 12),
              Text(
                step.title,
                style: TextStyle(
                  color: theme.foodColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Direction arrow
          if (expectedDirection != null)
            _buildLargeDirectionArrow(context, l10n),
          const SizedBox(height: 12),
          // Skip button
          TextButton(
            onPressed: onSkip,
            child: Text(
              l10n.wtSkipTutorial,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildLargeDirectionArrow(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    IconData icon;
    String text;

    switch (expectedDirection) {
      case Direction.right:
        icon = Icons.arrow_forward_rounded;
        text = l10n.wtSwipeRightUpper;
        break;
      case Direction.left:
        icon = Icons.arrow_back_rounded;
        text = l10n.wtSwipeLeftUpper;
        break;
      case Direction.up:
        icon = Icons.arrow_upward_rounded;
        text = l10n.wtSwipeUpUpper;
        break;
      case Direction.down:
        icon = Icons.arrow_downward_rounded;
        text = l10n.wtSwipeDownUpper;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.foodColor, theme.accentColor]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: context.letterSpacing(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            color: theme.accentColor.withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.wtSwipeAnywhereScreen,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.backgroundColor,
            theme.backgroundColor.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),

          // Message
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              step.message,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Direction hint for interactive steps
          if (isAwaitingInput && expectedDirection != null)
            _buildDirectionHint(context, l10n),

          // Progress dots
          _buildProgressDots(),

          const SizedBox(height: 12),

          // Buttons
          _buildButtons(l10n),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.accentColor.withValues(alpha: 0.15),
            theme.accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (step.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, color: theme.accentColor, size: 24),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              step.title,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionHint(BuildContext context, AppLocalizations l10n) {
    final IconData directionIcon;
    final String directionText;

    switch (expectedDirection) {
      case Direction.up:
        directionIcon = Icons.arrow_upward;
        directionText = l10n.wtSwipeUpUpper;
        break;
      case Direction.down:
        directionIcon = Icons.arrow_downward;
        directionText = l10n.wtSwipeDownUpper;
        break;
      case Direction.left:
        directionIcon = Icons.arrow_back;
        directionText = l10n.wtSwipeLeftUpper;
        break;
      case Direction.right:
        directionIcon = Icons.arrow_forward;
        directionText = l10n.wtSwipeRightUpper;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: theme.foodColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.foodColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(directionIcon, color: theme.foodColor, size: 28),
            const SizedBox(width: 12),
            Text(
              directionText,
              style: TextStyle(
                color: theme.foodColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: context.letterSpacing(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStepIndex;
        final isPast = index < currentStepIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.accentColor
                : isPast
                ? theme.accentColor.withValues(alpha: 0.5)
                : theme.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Always show skip button (even for interactive steps)
          TextButton(
            onPressed: onSkip,
            child: Text(
              l10n.wtSkipTutorial,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          if (!isAwaitingInput)
            GestureDetector(
              onTap: onNext,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.accentColor, theme.foodColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  step.actionLabel ??
                      (currentStepIndex == totalSteps - 1
                          ? l10n.wtGotIt
                          : l10n.wtNext),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            // Show hint text for interactive steps
            Text(
              l10n.wtSwipeAnywhere,
              style: TextStyle(
                color: theme.foodColor.withValues(alpha: 0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
