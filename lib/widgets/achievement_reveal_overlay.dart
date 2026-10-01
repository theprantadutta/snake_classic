import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/l10n/achievement_l10n.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/daily/lb_daily_parts.dart';

/// Full-screen achievement reveal on the Living Board — a real "you earned a
/// trophy" moment: dimmed board, a square cell medallion in the rarity
/// colour with a stepping halo and a cell burst, the name in snake cells,
/// and a queue indicator when multiple unlocks landed from the same game.
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
                child: Container(color: context.lb.board.withValues(alpha: 0.86)),
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
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final rarityColor = lbRarityColor(achievement.rarity);

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _triggerDismiss,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CellMedallion(
                      achievement: achievement,
                      rarityColor: rarityColor,
                      ringController: _ringController,
                      shineController: _shineController,
                    ),
                    const SizedBox(height: 24),
                    // "ACHIEVEMENT UNLOCKED" eyebrow — slide-up + fade in.
                    Text(
                      l10n.aroUnlocked,
                      textAlign: TextAlign.center,
                      style: LBText.label(p, color: rarityColor).copyWith(
                        fontSize: 11,
                        letterSpacing: 3.6,
                        shadows: [Shadow(color: rarityColor.withValues(alpha: .6), blurRadius: 12)],
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
                    Center(
                      child: LBCellText(
                        achievement.localizedTitle(l10n),
                        cell: 5 * context.uiScale,
                        color: p.head,
                        glow: true,
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
                    const SizedBox(height: 12),
                    Text(
                      achievement.localizedDescription(l10n),
                      textAlign: TextAlign.center,
                      style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 13),
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
                    const SizedBox(height: 20),
                    _RewardChips(achievement: achievement)
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
                      l10n.aroTapToContinue.toUpperCase(),
                      style: LBText.label(p, color: p.inkDim),
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

/// The hero piece, on the grid: a square block with the trophy's pixel
/// icon in its rarity colour, a square halo that steps outward once, cells
/// bursting off the block, a slow scanning shine, and the rarity tag.
class _CellMedallion extends StatelessWidget {
  final Achievement achievement;
  final Color rarityColor;
  final AnimationController ringController;
  final AnimationController shineController;

  const _CellMedallion({
    required this.achievement,
    required this.rarityColor,
    required this.ringController,
    required this.shineController,
  });

  static const double _box = 260;
  static const double _medal = 128;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return SizedBox(
      width: _box,
      height: _box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo + cell burst — fire once on entry.
          AnimatedBuilder(
            animation: ringController,
            builder: (_, _) => CustomPaint(
              size: const Size(_box, _box),
              painter: _CellBurstPainter(
                color: rarityColor,
                progress: ringController.value,
                seed: achievement.id.hashCode,
                medal: _medal,
              ),
            ),
          ),
          // The medallion block.
          Container(
            width: _medal,
            height: _medal,
            decoration: BoxDecoration(
              color: Color.lerp(p.deep, rarityColor, .12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: rarityColor, width: 2),
              boxShadow: [
                BoxShadow(color: rarityColor.withValues(alpha: .45), blurRadius: 36, spreadRadius: 2),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // A shine band scanning down the block, cell row by row.
                  AnimatedBuilder(
                    animation: shineController,
                    builder: (_, _) => CustomPaint(
                      size: const Size(_medal, _medal),
                      painter: _ScanPainter(
                        progress: shineController.value,
                        color: rarityColor,
                      ),
                    ),
                  ),
                  LBPixelIcon(
                    lbTrophyIcon(achievement.type),
                    cell: 13,
                    color: rarityColor,
                    accent: LB.goldHead,
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

          // Rarity tag — under the medallion.
          Positioned(
            bottom: 18,
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [BoxShadow(color: rarityColor.withValues(alpha: .5), blurRadius: 12)],
              ),
              child: Text(
                achievement.localizedRarityName(l10n).toUpperCase(),
                style: LBText.label(p, color: const Color(0xFF0A0F06)).copyWith(fontSize: 10),
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

  const _RewardChips({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = <Widget>[
      if (achievement.coinReward > 0)
        LBChip(
          kind: LBChipKind.gold,
          icon: LBIcon.coin,
          height: 28,
          label: l10n.lbCoinsReward(context.formatInt(achievement.coinReward)),
        ),
      if (achievement.xpReward > 0)
        LBChip(
          icon: LBIcon.bolt,
          height: 28,
          label: l10n.acXpReward(context.formatInt(achievement.xpReward)),
        ),
      if (achievement.points > 0)
        LBChip(
          icon: LBIcon.star,
          height: 28,
          label: l10n.lbPoints(context.formatInt(achievement.points)),
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }
}

/// A square halo that steps outward from the medallion and fades, plus
/// cells thrown off the block along the grid.
class _CellBurstPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int seed;
  final double medal;

  _CellBurstPainter({
    required this.color,
    required this.progress,
    required this.seed,
    required this.medal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;
    final center = size.center(Offset.zero);

    // Halo: grows in whole 10 dp steps, so it snaps like the board does.
    final eased = Curves.easeOutCubic.transform(progress);
    final reach = (size.width - medal) / 2;
    final step = ((reach * eased) / 10).floor() * 10.0;
    final haloAlpha = (1 - progress).clamp(0.0, 1.0) * .8;
    if (haloAlpha > .01) {
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: medal + step * 2, height: medal + step * 2),
        const Radius.circular(14),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + (1 - progress) * 3
          ..color = color.withValues(alpha: haloAlpha),
      );
    }

    // Burst: cells leave the block in the four grid directions and the
    // diagonals, each on its own delay.
    final random = math.Random(seed);
    const count = 20;
    for (var i = 0; i < count; i++) {
      final dir = i % 8;
      final dx = const [1, -1, 0, 0, 1, -1, 1, -1][dir].toDouble();
      final dy = const [0, 0, 1, -1, 1, 1, -1, -1][dir].toDouble();
      final spread = (random.nextDouble() - .5) * medal * .8;
      final delay = random.nextDouble() * .25;
      final local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final t = Curves.easeOutCubic.transform(local);
      final dist = medal / 2 + (40 + random.nextDouble() * 50) * t;
      final pos = center +
          Offset(
            dx * dist + (dx == 0 ? spread : 0),
            dy * dist + (dy == 0 ? spread : 0),
          );
      final cell = 7 * (1 - local) + 3;
      final alpha = (1 - local) * .95;
      canvas.drawRRect(
        lbCellRect(pos.dx - cell / 2, pos.dy - cell / 2, cell),
        Paint()..color = (i.isEven ? color : LB.goldHead).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CellBurstPainter old) =>
      old.progress != progress || old.color != color;
}

/// A soft band of light passing down the medallion, row by row.
class _ScanPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 8;
    final rowH = size.height / rows;
    final head = (progress * (rows + 3)).floor() - 1;
    for (var r = 0; r < rows; r++) {
      final d = head - r;
      if (d < 0 || d > 2) continue;
      final a = const [.16, .08, .03][d];
      canvas.drawRect(
        Rect.fromLTWH(0, r * rowH, size.width, rowH),
        Paint()..color = color.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanPainter old) =>
      old.progress != progress || old.color != color;
}

/// The skip block in the top-right corner. Labels with "SKIP" when the
/// current card is the last one, "SKIP (3)" when 3 more are queued. Fades in
/// a beat after the medallion so it doesn't compete with the reveal
/// entrance, then stays put until the overlay tears down.
class _SkipButton extends StatelessWidget {
  final int remaining;
  final VoidCallback onTap;

  const _SkipButton({required this.remaining, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final label = remaining > 0 ? l10n.aroSkipCount(remaining) : l10n.aroSkip;
    return LBBlock(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      feedback: false,
      onTap: () {
        HapticService().selectionClick();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: LBText.button(p, color: p.head, size: 11.5)),
          const SizedBox(width: 8),
          LBPixelIcon(LBIcon.next, cell: 2.6, color: p.lime),
        ],
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
