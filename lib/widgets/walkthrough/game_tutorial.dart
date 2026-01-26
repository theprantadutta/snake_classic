import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/walkthrough/walkthrough_step.dart';

/// Controller for the interactive game tutorial
class GameTutorialController extends ChangeNotifier {
  int _currentStep = 0;
  bool _awaitingInput = false;
  Direction? _expectedDirection;
  bool _isComplete = false;
  VoidCallback? _onComplete;

  /// Current step index
  int get currentStep => _currentStep;

  /// Whether the tutorial is waiting for user input
  bool get awaitingInput => _awaitingInput;

  /// The direction the user should swipe (for practice steps)
  Direction? get expectedDirection => _expectedDirection;

  /// Whether the tutorial has been completed
  bool get isComplete => _isComplete;

  /// Set the completion callback
  set onComplete(VoidCallback? callback) {
    _onComplete = callback;
  }

  /// Get all tutorial steps
  List<WalkthroughStep> get steps => _tutorialSteps;

  /// Get the current step data
  WalkthroughStep? get currentStepData {
    if (_currentStep >= _tutorialSteps.length) return null;
    return _tutorialSteps[_currentStep];
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
    if (_currentStep < _tutorialSteps.length - 1) {
      _currentStep++;
      _checkForInteractiveStep();
      notifyListeners();
    } else {
      // Tutorial complete
      complete();
    }
  }

  /// Skip the tutorial
  void skip() {
    complete();
  }

  /// Mark the tutorial as complete
  void complete() {
    _isComplete = true;
    _awaitingInput = false;
    _expectedDirection = null;
    _onComplete?.call();
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
    _onComplete = null;
    super.dispose();
  }
}

/// GlobalKeys for game tutorial targets
class GameTutorialKeys {
  static final hudKey = GlobalKey();
  static final scoreKey = GlobalKey();
  static final levelKey = GlobalKey();
  static final gameBoardKey = GlobalKey();
}

/// Tutorial steps for the game screen
final List<WalkthroughStep> _tutorialSteps = [
  // Step 1: Welcome
  const WalkthroughStep(
    id: 'tutorial_welcome',
    title: 'Welcome to the Game!',
    message: "Let's learn how to play Snake Classic. This quick tutorial will show you the basics.",
    position: TooltipPosition.center,
    icon: Icons.school,
    canSkip: true,
  ),

  // Step 2: HUD overview
  WalkthroughStep(
    id: 'tutorial_hud',
    title: 'Game Info',
    message: 'The top bar shows your score, level, and high score. Watch your progress as you play!',
    targetKey: GameTutorialKeys.hudKey,
    position: TooltipPosition.below,
    icon: Icons.dashboard,
  ),

  // Step 3: Controls intro
  const WalkthroughStep(
    id: 'tutorial_controls',
    title: 'Swipe to Move',
    message: 'Swipe in any direction to change where your snake is heading. The snake will turn to follow your swipe.',
    position: TooltipPosition.center,
    icon: Icons.swipe,
  ),

  // Step 4: Practice - Swipe Right (Interactive)
  const WalkthroughStep(
    id: 'tutorial_practice_right',
    title: 'Try it! Swipe RIGHT',
    message: 'Swipe RIGHT on the screen to continue.',
    position: TooltipPosition.center,
    icon: Icons.arrow_forward,
    isInteractive: true,
    canSkip: false,
  ),

  // Step 5: Practice - Swipe Up (Interactive)
  const WalkthroughStep(
    id: 'tutorial_practice_up',
    title: 'Great! Now swipe UP',
    message: 'Swipe UP on the screen to continue.',
    position: TooltipPosition.center,
    icon: Icons.arrow_upward,
    isInteractive: true,
    canSkip: false,
  ),

  // Step 6: Food explanation
  const WalkthroughStep(
    id: 'tutorial_food',
    title: 'Eat to Grow',
    message: 'Guide your snake to eat the food that appears on the board. Each food item makes your snake longer!',
    position: TooltipPosition.center,
    icon: Icons.restaurant,
  ),

  // Step 7: Food types
  const WalkthroughStep(
    id: 'tutorial_food_types',
    title: 'Food Types',
    message: 'Regular food: +10 points\nBonus food (golden): +25 points\nSpecial food (purple): +50 points',
    position: TooltipPosition.center,
    icon: Icons.star,
  ),

  // Step 8: Avoid walls
  const WalkthroughStep(
    id: 'tutorial_walls',
    title: 'Avoid the Walls!',
    message: "Don't hit the edges of the board - it's game over if you crash into a wall!",
    position: TooltipPosition.center,
    icon: Icons.warning_amber,
  ),

  // Step 9: Don't hit yourself
  const WalkthroughStep(
    id: 'tutorial_self',
    title: "Don't Hit Yourself!",
    message: 'As your snake grows longer, be careful not to crash into your own body!',
    position: TooltipPosition.center,
    icon: Icons.do_not_disturb_on,
  ),

  // Step 10: Complete
  const WalkthroughStep(
    id: 'tutorial_complete',
    title: "You're Ready!",
    message: 'Good luck! Try to beat your high score and unlock achievements along the way.',
    position: TooltipPosition.center,
    icon: Icons.celebration,
    actionLabel: 'Start Playing!',
  ),
];

/// Overlay widget for the game tutorial
class GameTutorialOverlay extends StatelessWidget {
  final GameTutorialController controller;
  final GameTheme theme;
  final VoidCallback onSkip;

  const GameTutorialOverlay({
    super.key,
    required this.controller,
    required this.theme,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
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
          onSkip: () {
            controller.skip();
            onSkip();
          },
          onSwipe: controller.onSwipeDetected,
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
  final Function(Direction)? onSwipe;

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
    this.onSwipe,
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

  /// Build a minimal floating overlay for interactive swipe steps
  Widget _buildInteractiveOverlay(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && onSwipe != null) {
            if (details.primaryVelocity! > 100) {
              onSwipe!(Direction.right);
            } else if (details.primaryVelocity! < -100) {
              onSwipe!(Direction.left);
            }
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && onSwipe != null) {
            if (details.primaryVelocity! > 100) {
              onSwipe!(Direction.down);
            } else if (details.primaryVelocity! < -100) {
              onSwipe!(Direction.up);
            }
          }
        },
        // Light overlay so game board is visible
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80), // Space for HUD
                // Floating instruction card at top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildInteractiveCard(),
                ),
                const Spacer(),
                // Bottom hint
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: _buildSwipeHint(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCard() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                step.icon ?? Icons.swipe,
                color: theme.foodColor,
                size: 28,
              ),
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
          if (expectedDirection != null) _buildLargeDirectionArrow(),
          const SizedBox(height: 12),
          // Skip button
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip Tutorial',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeDirectionArrow() {
    IconData icon;
    String text;

    switch (expectedDirection) {
      case Direction.right:
        icon = Icons.arrow_forward_rounded;
        text = 'SWIPE RIGHT';
        break;
      case Direction.left:
        icon = Icons.arrow_back_rounded;
        text = 'SWIPE LEFT';
        break;
      case Direction.up:
        icon = Icons.arrow_upward_rounded;
        text = 'SWIPE UP';
        break;
      case Direction.down:
        icon = Icons.arrow_downward_rounded;
        text = 'SWIPE DOWN';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.foodColor, theme.accentColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
        ),
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
            'Swipe anywhere on screen!',
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
            _buildDirectionHint(),

          // Progress dots
          _buildProgressDots(),

          const SizedBox(height: 12),

          // Buttons
          _buildButtons(),

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

  Widget _buildDirectionHint() {
    final IconData directionIcon;
    final String directionText;

    switch (expectedDirection) {
      case Direction.up:
        directionIcon = Icons.arrow_upward;
        directionText = 'SWIPE UP';
        break;
      case Direction.down:
        directionIcon = Icons.arrow_downward;
        directionText = 'SWIPE DOWN';
        break;
      case Direction.left:
        directionIcon = Icons.arrow_back;
        directionText = 'SWIPE LEFT';
        break;
      case Direction.right:
        directionIcon = Icons.arrow_forward;
        directionText = 'SWIPE RIGHT';
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
                letterSpacing: 1,
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

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Always show skip button (even for interactive steps)
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip Tutorial',
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
                      (currentStepIndex == totalSteps - 1 ? 'Got it!' : 'Next'),
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
              'Swipe anywhere!',
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
