import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/services/audio_service.dart';

/// Full-screen cinematic achievement reveal — replaces the old top-banner
/// toast (`AchievementNotification`) with a real "you earned a trophy"
/// moment: dim scrim, rotating shine, radial light rays, particle burst,
/// rarity-themed medallion, and a queue indicator when multiple unlocks
/// landed from the same game.
///
/// Use [show] to push one or more unlocks into the overlay queue. Calling
/// [show] while another reveal is already on screen appends to that
/// queue rather than spawning a competing overlay.
class AchievementRevealOverlay {
  static OverlayEntry? _entry;
  static final List<Achievement> _queue = [];
  static _AchievementRevealStackState? _state;

  /// Push [unlocks] into the reveal queue. Duplicates (by id) already
  /// queued or currently showing are skipped so a re-trigger from the
  /// post-game sync diff doesn't double-reveal the same row.
  static void show(BuildContext context, List<Achievement> unlocks) {
    if (unlocks.isEmpty) return;

    final shownIds = {
      ..._queue.map((a) => a.id),
      if (_state?.current != null) _state!.current!.id,
    };
    final fresh = unlocks.where((a) => !shownIds.contains(a.id)).toList();
    if (fresh.isEmpty) return;

    _queue.addAll(fresh);

    if (_entry == null) {
      final overlay = Overlay.of(context, rootOverlay: true);
      _entry = OverlayEntry(
        builder: (_) => _AchievementRevealStack(
          onStateCreated: (s) => _state = s,
          onDismissed: _dispose,
          drainNext: _drainNext,
          remainingCount: _remainingCount,
          skipAll: _skipAll,
        ),
      );
      overlay.insert(_entry!);
    } else {
      _state?.refresh();
    }
  }

  static Achievement? _drainNext() {
    if (_queue.isEmpty) return null;
    return _queue.removeAt(0);
  }

  /// Items still waiting after the currently-revealed card. Used to
  /// label the skip button (e.g. "SKIP 3").
  static int _remainingCount() => _queue.length;

  /// Skip everything that's queued plus the card currently on screen.
  /// Clears the queue first so the current card's exit animation finds
  /// nothing to advance to and tears the overlay down.
  static void _skipAll() {
    _queue.clear();
    _state?.skipCurrent();
  }

  static void _dispose() {
    _entry?.remove();
    _entry = null;
    _state = null;
    _queue.clear();
  }
}

class _AchievementRevealStack extends StatefulWidget {
  final ValueChanged<_AchievementRevealStackState> onStateCreated;
  final VoidCallback onDismissed;
  final Achievement? Function() drainNext;
  final int Function() remainingCount;
  final VoidCallback skipAll;

  const _AchievementRevealStack({
    required this.onStateCreated,
    required this.onDismissed,
    required this.drainNext,
    required this.remainingCount,
    required this.skipAll,
  });

  @override
  State<_AchievementRevealStack> createState() =>
      _AchievementRevealStackState();
}

class _AchievementRevealStackState extends State<_AchievementRevealStack>
    with SingleTickerProviderStateMixin {
  Achievement? current;
  int _shownCount = 0;
  late final AudioService _audio = AudioService();

  /// Total reveals processed so far including [current], used to render
  /// "1 / N" position labels. Recalculated lazily because we don't know
  /// N in advance — new items can be enqueued mid-stream.
  int get position => _shownCount;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _advance());
  }

  void refresh() {
    // Caller appended to the queue while we were idle on the last card —
    // pick it up.
    if (current == null) _advance();
    if (mounted) setState(() {});
  }

  /// Called from the static [AchievementRevealOverlay._skipAll]. Tells
  /// the currently-mounted [_RevealCard] (via its GlobalKey) to start
  /// its dismiss animation; once that completes, the card's onDismiss
  /// callback drains the (already-cleared) queue, finds null, and
  /// closes the overlay.
  void skipCurrent() {
    _cardKey.currentState?.triggerDismiss();
  }

  final GlobalKey<_RevealCardState> _cardKey = GlobalKey<_RevealCardState>();

  void _advance() {
    final next = widget.drainNext();
    if (next == null) {
      widget.onDismissed();
      return;
    }
    HapticService().heavyImpact();
    _audio.playSound('high_score');
    setState(() {
      current = next;
      _shownCount++;
    });
  }

  void _onCardDismissed() {
    setState(() => current = null);
    // Brief gap between reveals lets the exit animation settle before the
    // next medallion scales in — feels less like a cross-fade and more
    // like trophies being placed one by one.
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      _advance();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Overlay entries don't inherit the app's Material ancestor, so raw
    // Text widgets render with yellow debug underlines. Wrap the whole
    // reveal stack in a transparent Material so DefaultTextStyle resolves
    // properly without painting an opaque surface over the scrim.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dim + blur the screen behind us. Tap-through is blocked because
          // a reveal is a focal moment — accidental taps on the game-over
          // buttons (RESTART, HOME) would feel terrible right when you're
          // celebrating a milestone.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // swallow background taps
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withValues(alpha: 0.72)),
              ),
            ),
          ),
          if (current != null)
            _RevealCard(
              key: _cardKey,
              achievement: current!,
              position: position,
              onDismiss: _onCardDismissed,
            ),
          // Skip button — top-right, sits above the card so it remains
          // tappable while the medallion is mid-animation. Labeled with
          // the count still queued behind the current card so the user
          // knows how many they're skipping.
          if (current != null)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _SkipButton(
                    remaining: widget.remainingCount(),
                    onTap: widget.skipAll,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RevealCard extends StatefulWidget {
  final Achievement achievement;
  final int position;
  final VoidCallback onDismiss;

  const _RevealCard({
    super.key,
    required this.achievement,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<_RevealCard>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _shineController;
  late final AnimationController _ringController;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    // Auto-advance after the medallion has settled and the user has had a
    // few beats to read the title. The user can dismiss earlier by tapping.
    Future.delayed(const Duration(milliseconds: 4200), () {
      if (!mounted || _dismissing) return;
      _triggerDismiss();
    });
  }

  void _triggerDismiss() {
    if (_dismissing) return;
    _dismissing = true;
    _entryController.reverse().whenComplete(() {
      if (!mounted) return;
      widget.onDismiss();
    });
  }

  /// Exposed for the parent's skipCurrent path — the static skip-all
  /// handler clears the queue then calls this to tear down the current
  /// card's animation, which then triggers the normal onDismiss → drain
  /// → onDismissed (now-null queue) → overlay teardown.
  void triggerDismiss() => _triggerDismiss();

  @override
  void dispose() {
    _entryController.dispose();
    _shineController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;
    final rarityColor = achievement.rarityColor;

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _triggerDismiss,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RaysAndMedallion(
                      achievement: achievement,
                      rarityColor: rarityColor,
                      ringController: _ringController,
                      shineController: _shineController,
                    ),
                    const SizedBox(height: 28),
                    // "ACHIEVEMENT UNLOCKED" eyebrow — slide-up + fade in.
                    Text(
                      'ACHIEVEMENT UNLOCKED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        shadows: [
                          Shadow(
                            color: rarityColor.withValues(alpha: 0.7),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.8,
                          end: 0.0,
                          duration: 500.ms,
                          delay: 350.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 400.ms, delay: 350.ms),
                    const SizedBox(height: 14),
                    Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.6,
                          end: 0.0,
                          duration: 550.ms,
                          delay: 500.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 450.ms, delay: 500.ms),
                    const SizedBox(height: 10),
                    Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    )
                        .animate()
                        .slideY(
                          begin: 0.5,
                          end: 0.0,
                          duration: 550.ms,
                          delay: 650.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 450.ms, delay: 650.ms),
                    const SizedBox(height: 22),
                    _RewardChips(
                      achievement: achievement,
                      rarityColor: rarityColor,
                    )
                        .animate()
                        .slideY(
                          begin: 0.5,
                          end: 0.0,
                          duration: 500.ms,
                          delay: 850.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 450.ms, delay: 850.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Tap to continue',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    )
                        .animate(
                          onPlay: (c) => c.repeat(reverse: true),
                        )
                        .fadeIn(duration: 700.ms, delay: 1500.ms)
                        .then()
                        .fade(begin: 0.45, end: 1.0, duration: 1200.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
          .animate(controller: _entryController, autoPlay: false)
          .fadeIn(duration: 280.ms, curve: Curves.easeOut),
    );
  }
}

/// The hero piece — light rays, halo ring, particle sparkles, and the
/// medallion with the achievement's icon framed by a rotating shine.
class _RaysAndMedallion extends StatelessWidget {
  final Achievement achievement;
  final Color rarityColor;
  final AnimationController ringController;
  final AnimationController shineController;

  const _RaysAndMedallion({
    required this.achievement,
    required this.rarityColor,
    required this.ringController,
    required this.shineController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial light rays — slowly rotating sunburst sitting behind
          // everything else. The ring controller drives the entry growth;
          // shineController drives a slow continuous spin.
          AnimatedBuilder(
            animation: Listenable.merge([ringController, shineController]),
            builder: (_, _) => Transform.rotate(
              angle: shineController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(280, 280),
                painter: _LightRaysPainter(
                  color: rarityColor,
                  progress: ringController.value,
                ),
              ),
            ),
          ),
          // Expanding halo ring — fires once on entry, fades as it
          // expands past the medallion.
          AnimatedBuilder(
            animation: ringController,
            builder: (_, _) => CustomPaint(
              size: const Size(280, 280),
              painter: _HaloRingPainter(
                color: rarityColor,
                progress: Curves.easeOutCubic.transform(ringController.value),
              ),
            ),
          ),
          // Confetti / sparkle burst — short-lived particles flying outward
          // from the medallion.
          AnimatedBuilder(
            animation: ringController,
            builder: (_, _) => CustomPaint(
              size: const Size(280, 280),
              painter: _SparkleBurstPainter(
                color: rarityColor,
                progress: ringController.value,
                seed: achievement.id.hashCode,
              ),
            ),
          ),
          // Rotating shine sweep behind the medallion glass.
          AnimatedBuilder(
            animation: shineController,
            builder: (_, child) => Transform.rotate(
              angle: shineController.value * 2 * math.pi,
              child: child,
            ),
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.12, 0.25, 1.0],
                ),
              ),
            ),
          ),
          // Medallion — the centerpiece.
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  rarityColor.withValues(alpha: 0.95),
                  rarityColor.withValues(alpha: 0.55),
                  rarityColor.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.65, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withValues(alpha: 0.75),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 3,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                achievement.icon,
                color: Colors.white,
                size: 72,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          )
              .animate()
              .scaleXY(
                begin: 0.2,
                end: 1.0,
                duration: 700.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 250.ms),

          // Rarity ribbon — sits at the bottom of the medallion area.
          Positioned(
            bottom: 6,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    rarityColor.withValues(alpha: 0.95),
                    rarityColor.withValues(alpha: 0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                achievement.rarityName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            )
                .animate()
                .slideY(
                  begin: 1.5,
                  end: 0.0,
                  duration: 500.ms,
                  delay: 700.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms, delay: 700.ms),
          ),
        ],
      ),
    );
  }
}

class _RewardChips extends StatelessWidget {
  final Achievement achievement;
  final Color rarityColor;

  const _RewardChips({
    required this.achievement,
    required this.rarityColor,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (achievement.xpReward > 0) {
      chips.add(_chip(
        icon: Icons.auto_awesome,
        label: '+${achievement.xpReward} XP',
        color: Colors.purpleAccent,
      ));
    }
    if (achievement.coinReward > 0) {
      chips.add(_chip(
        icon: Icons.monetization_on,
        label: '+${achievement.coinReward}',
        color: Colors.amber,
      ));
    }
    if (achievement.points > 0) {
      chips.add(_chip(
        icon: Icons.star,
        label: '${achievement.points} pts',
        color: rarityColor,
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LightRaysPainter extends CustomPainter {
  final Color color;
  final double progress;

  _LightRaysPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final rayCount = 14;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi;
      final innerRadius = 70.0;
      // Stagger ray growth so they feel like they're being painted out.
      final localProgress = (progress - (i % 3) * 0.05).clamp(0.0, 1.0);
      final outerRadius =
          innerRadius + (maxRadius - innerRadius) * localProgress;

      final p1 = Offset(
        center.dx + math.cos(angle - 0.04) * innerRadius,
        center.dy + math.sin(angle - 0.04) * innerRadius,
      );
      final p2 = Offset(
        center.dx + math.cos(angle + 0.04) * innerRadius,
        center.dy + math.sin(angle + 0.04) * innerRadius,
      );
      final p3 = Offset(
        center.dx + math.cos(angle + 0.005) * outerRadius,
        center.dy + math.sin(angle + 0.005) * outerRadius,
      );
      final p4 = Offset(
        center.dx + math.cos(angle - 0.005) * outerRadius,
        center.dy + math.sin(angle - 0.005) * outerRadius,
      );

      paint.shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.55 * localProgress),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromPoints(p1, p3));

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter old) =>
      old.progress != progress || old.color != color;
}

class _HaloRingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _HaloRingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final startRadius = 60.0;
    final endRadius = size.width / 2 - 4;
    final radius = startRadius + (endRadius - startRadius) * progress;
    // Fade as it expands outward — last 30% is mostly invisible.
    final alpha = (1.0 - progress).clamp(0.0, 1.0) * 0.85;
    if (alpha <= 0.01) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 + (1.0 - progress) * 4.0
      ..color = color.withValues(alpha: alpha);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _HaloRingPainter old) =>
      old.progress != progress || old.color != color;
}

class _SparkleBurstPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int seed;

  _SparkleBurstPainter({
    required this.color,
    required this.progress,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(seed);
    const sparkleCount = 18;
    for (int i = 0; i < sparkleCount; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final maxDistance = 70.0 + random.nextDouble() * 60.0;
      // Each sparkle has its own delay + duration so they don't all fire
      // in lockstep.
      final delay = random.nextDouble() * 0.25;
      final local = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final eased = Curves.easeOutCubic.transform(local);
      final distance = maxDistance * eased;
      final position = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      final radius = (1.0 - local) * 2.5 + 1.0;
      final alpha = (1.0 - local) * 0.95;
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, radius, paint);
      // White hot core
      canvas.drawCircle(
        position,
        radius * 0.5,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleBurstPainter old) =>
      old.progress != progress || old.color != color;
}

/// Tasteful skip pill in the top-right corner. Labels with "SKIP" when
/// the current card is the last one, "SKIP (3)" when 3 more are queued.
/// Fades in a beat after the medallion so it doesn't compete with the
/// reveal entrance, then stays put until the overlay tears down.
class _SkipButton extends StatelessWidget {
  final int remaining;
  final VoidCallback onTap;

  const _SkipButton({required this.remaining, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = remaining > 0 ? 'SKIP ($remaining)' : 'SKIP';
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          HapticService().selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.skip_next_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 1100.ms)
        .slideX(
          begin: 0.4,
          end: 0.0,
          duration: 400.ms,
          delay: 1100.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
