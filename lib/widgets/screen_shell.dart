import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/app_background.dart';

/// The shape every screen in this app shares.
///
/// Settings and Profile settled it, How to Play, Daily Challenges and the
/// Battle Pass followed, and each one of those arrived at it by hand — the
/// same app bar, the same eyebrow, the same card, retyped with slightly
/// different numbers. That is how a design language stops being one: not by
/// anybody disagreeing, but by five copies drifting a pixel at a time.
///
/// So it lives here once. A screen that uses these is in the language by
/// construction, and changing the language means changing one file.
///
/// ## The language is an arcade HUD
///
/// This file used to say the opposite — no gradients, no glow, no entrance
/// animations, on the theory that restraint reads as quality. On a settings
/// list it read as a phone settings list, which is the one thing a game's
/// options screen should not look like. The rules now are:
///
///   * A section is a **panel**, not a list heading: an emblem, a tracked
///     Orbitron title, a rule running out to a terminator, and a card with
///     bracketed corners. The brackets are the signature — they are what say
///     "instrument panel" rather than "table cell".
///   * Cards carry a shallow vertical gradient and a low outer glow in the
///     theme accent. Both are deliberately weak: they have to survive ten
///     themes, four of which are already bright.
///   * Accent means progress, action, and the current selection.
///     [kRewardGold] means a reward. Everything else is white at some
///     opacity — 0.85 for what you read, 0.55 for what explains it, 0.45 for
///     what labels it.
///   * Entrance animation is opt-in per screen via `index`, because a
///     41-card store does not want 41 staggered fades.
///
/// ## Two rules that are not style
///
/// **Type goes through [GameTypography], never a raw `fontFamily`.** Those
/// helpers append the Devanagari/Arabic/Cyrillic fallbacks; a hand-rolled
/// `fontFamily: 'Orbitron'` renders Hindi and Arabic as boxes.
///
/// **Only bundled weights exist.** Runtime font fetching is off, so a weight
/// that is not in `assets/fonts/` hard-crashes the app offline. Orbitron ships
/// 400–900; **Rajdhani ships 300–700 only** — never ask it for w800 or w900.

/// Rewards are gold. The home screen's best-score medal, a claimable daily
/// challenge, a premium battle pass tier and a coin price are all the same
/// gold, because they are all the same idea.
const Color kRewardGold = Color(0xFFFFC53D);

/// The app bar every screen wears.
PreferredSizeWidget appScreenBar(
  BuildContext context,
  GameTheme theme,
  String title, {
  List<Widget>? actions,
  Widget? leading,
  /// A tab strip under the title. Screens with one used to hand-roll the
  /// whole bar just to get it, and lost the title treatment doing so.
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    // Orbitron is a much wider face than the Rajdhani these titles used to
    // inherit, so a title that fit before can run out of bar — "DAILY
    // CHALLENGES" did, and lost its last word. Scaling down beats
    // ellipsizing: a slightly smaller title still says what the screen is,
    // and with nine locales the longest translation is not the one anybody
    // tested.
    title: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
      title.toUpperCase(),
      // headlineSmall is Orbitron w500. These titles were FontWeight.bold
      // before they moved here, and w500 across every screen reads as the
      // chrome having gone quiet rather than as a choice. Orbitron-Bold is
      // bundled, so w700 is safe to ask for; anything above w900 is not.
      style: GameTypography.headlineSmall(color: theme.accentColor).copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: context.letterSpacing(2),
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.3),
          ),
          // The accent bloom is what separates a game title from a heading.
          // Kept at a low alpha so it reads as emission, not as a blur.
          Shadow(
            blurRadius: 18,
            color: theme.accentColor.withValues(alpha: 0.45),
          ),
        ],
      ),
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: theme.accentColor),
    leading: leading,
    actions: actions,
    bottom: bottom,
  );
}

/// The card a section's contents sit in.
BoxDecoration screenCardDecoration(GameTheme theme, {Color? borderColor}) {
  final accent = borderColor ?? theme.accentColor.withValues(alpha: 0.42);
  return BoxDecoration(
    // Top-lit, like a panel under a light. Two stops of the same colour at
    // different alpha, so it works on every theme background without any
    // per-theme tuning.
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        theme.backgroundColor.withValues(alpha: 0.46),
        theme.backgroundColor.withValues(alpha: 0.24),
      ],
    ),
    border: Border.all(color: accent),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: theme.accentColor.withValues(alpha: 0.10),
        blurRadius: 14,
        spreadRadius: -2,
      ),
    ],
  );
}

Widget screenCard(
  GameTheme theme, {
  required Widget child,
  Color? borderColor,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  /// Set false for a card that is already inside another bracketed card, so
  /// the corners do not stack into a moiré of little Ls.
  bool brackets = true,
}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: screenCardDecoration(theme, borderColor: borderColor),
    // Builder, not a context parameter: this is called from 41 places in the
    // store alone, and the brackets need `uiScale` to keep their weight on a
    // tablet. Reading it here changes no call site.
    child: brackets
        ? HudCorners(color: theme.accentColor, child: child)
        : child,
  );
}

/// The four corner brackets, over whatever you put under them.
///
/// The signature of the language: brackets say "framed panel" or "arena".
/// They need room to sit in — they are drawn from the content box OUTWARD,
/// so the surface they go on needs padding wider than [HudBracketPainter]'s
/// inset, or the arms land on the border instead of floating inside it. That
/// is why home's small chips take the gradient and glow but not these.
class HudCorners extends StatelessWidget {
  const HudCorners({
    super.key,
    required this.child,
    required this.color,
    this.inset,
    this.arm,
    this.clipBehavior = Clip.hardEdge,
  });

  final Widget child;
  final Color color;

  /// How far outside [child]'s box the corner sits. Defaults suit a card,
  /// where the brackets land inside the card's own padding.
  final double? inset;
  final double? arm;

  /// A card's brackets fall within its padding, so the default clip never
  /// touches them. A surface with no padding to spare — the arena frame —
  /// needs [Clip.none] or the arms are cut off at the edge they are drawn
  /// outside of.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // passthrough, NOT the default loose. A Stack normally hands its
      // non-positioned children loose constraints, so they shrink-wrap and
      // settle at top-start — which silently re-laid-out everything this
      // wrapped. The home bar's icon and label stopped being centred in
      // their chip and drifted to the corner, because the Column was no
      // longer being told to fill the height it used to.
      //
      // passthrough forwards the constraints this Stack was given straight
      // to the child, so wrapping a widget in brackets leaves its layout
      // exactly as it was. Decoration must never move the thing it
      // decorates.
      fit: StackFit.passthrough,
      clipBehavior: clipBehavior,
      children: [
        child,
        // Decoration only: it must never intercept a tap meant for the
        // control underneath it.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: HudBracketPainter(
                color: color,
                scale: context.uiScale,
                inset: inset,
                arm: arm,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The four corner brackets that make a card read as an instrument panel.
///
/// Drawn inside the card's padding rather than on its border, so they sit
/// clear of the hairline instead of doubling it. Painted from the content
/// box's corners outward by [_inset], which is why the arms appear to float
/// just inside the edge.
class HudBracketPainter extends CustomPainter {
  const HudBracketPainter({
    required this.color,
    this.scale = 1.0,
    double? inset,
    double? arm,
  }) : _insetOverride = inset,
       _armOverride = arm;

  final Color color;

  /// `context.uiScale`. The card grows on a tablet, so a bracket that did not
  /// would read as a thinner mark on a bigger panel rather than the same one.
  final double scale;

  /// How far outside the content box the corner sits. Kept below the smallest
  /// padding any caller passes even at the largest scale — 10 × 1.35 is 13.5,
  /// clear of the 20 default — so an arm never lands on the border.
  static const double _inset = 10;

  /// Arm length.
  static const double _arm = 13;

  final double? _insetOverride;
  final double? _armOverride;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = (_insetOverride ?? _inset) * scale;
    final arm = (_armOverride ?? _arm) * scale;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.6 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final l = -inset;
    final t = -inset;
    final r = size.width + inset;
    final b = size.height + inset;

    // Each corner is one path so the elbow joins cleanly instead of showing
    // two overlapping caps.
    void corner(double x, double y, double dx, double dy) {
      canvas.drawPath(
        Path()
          ..moveTo(x + dx * arm, y)
          ..lineTo(x, y)
          ..lineTo(x, y + dy * arm),
        paint,
      );
    }

    corner(l, t, 1, 1);
    corner(r, t, -1, 1);
    corner(l, b, 1, -1);
    corner(r, b, -1, -1);
  }

  @override
  bool shouldRepaint(HudBracketPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.scale != scale ||
      oldDelegate._insetOverride != _insetOverride ||
      oldDelegate._armOverride != _armOverride;
}

/// The panel material, for a surface that is not a section card.
///
/// Home's stat panels, the gameplay HUD chips and the arena frame all need to
/// be made of the same stuff as a panel without becoming one — they are a
/// menu, a readout and a playfield, not documents. This is the half of the
/// treatment that travels: the top-lit gradient and the low accent glow.
/// The brackets and the eyebrow stay with [screenCard], which is what keeps
/// "panel" meaning something.
///
/// [tint] overrides the accent for a surface that means something else — the
/// red of a countdown, the gold of a reward.
BoxDecoration arcadeSurface(
  GameTheme theme, {
  required BorderRadius borderRadius,
  Color? tint,
  Color? borderColor,
  double borderWidth = 1,
  double baseAlpha = 0.55,
  bool glow = true,
}) {
  final accent = tint ?? theme.accentColor;
  // Darkened before the alpha, the way home's chips already did it: against a
  // background that is itself the theme colour, a straight translucent fill
  // of that same colour reads as nothing at all.
  final base = Color.lerp(theme.backgroundColor, Colors.black, 0.25)!;

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        base.withValues(alpha: baseAlpha),
        base.withValues(alpha: (baseAlpha - 0.18).clamp(0.0, 1.0)),
      ],
    ),
    borderRadius: borderRadius,
    border: Border.all(
      color: borderColor ?? accent.withValues(alpha: 0.35),
      width: borderWidth,
    ),
    boxShadow: glow
        ? [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ]
        : null,
  );
}

/// The uppercase accent label that names a section.
///
/// [count] puts a number beside it in gold, for the sections where "how many
/// are waiting" is the reason to look — claimable rewards, pending requests.
///
/// [icon] fills the emblem to the left of the title. Sections that do not name
/// one get a plain accent square, so a screen that never passes an icon still
/// looks like it belongs to the same panel system.
Widget screenEyebrow(
  BuildContext context,
  GameTheme theme,
  String title, {
  int? count,
  IconData? icon,
  Widget? trailing,
}) {
  final scale = context.uiScale;
  final emblem = 26.0 * scale;

  // The title used to be a Flexible next to the rule's Expanded, which splits
  // the free space evenly — so any title needing more than half of it lost
  // words ("TODAY'S PROGRESS" became "TODAY'S PR…") while short ones left
  // their unused half as a gap the rule could not reach into. Flex cannot
  // express "take what you need, the rule gets the rest", so the width is
  // worked out here instead: the title is capped at whatever is left once
  // everything else has been reserved, and the rule takes exactly the
  // remainder. Nothing can overflow, because the cap already accounts for
  // every sibling.
  // A stub, not a proper rule. The rule is the most expendable thing in this
  // row: reserving 32 for it cost "PERFORMANCE OVERVIEW" its last word inside
  // a padded card. A title that long simply gets a shorter rule, and a title
  // longer still gets none — which is the right way round, because the words
  // carry the meaning and the line is decoration.
  const ruleMin = 8.0;
  final trailingReserve = trailing == null ? 8.0 * scale : 108.0;
  final countReserve = (count != null && count > 0) ? 30.0 : 0.0;

  return Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 12),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final maxTitle =
            (constraints.maxWidth -
                    (emblem +
                        10 * scale +
                        countReserve +
                        10 * scale +
                        ruleMin +
                        6 * scale +
                        trailingReserve))
                .clamp(0.0, double.infinity);

        return Row(
      children: [
        Container(
          width: emblem,
          height: emblem,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.16),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.55),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: icon == null
              ? Container(
                  width: 7 * scale,
                  height: 7 * scale,
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
              : Icon(icon, size: 15 * scale, color: theme.accentColor),
        ),
        SizedBox(width: 10 * scale),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTitle),
          // Shrink rather than truncate, like the app bar. This is the third
          // place the same thing has bitten: Orbitron is a wide face, and a
          // twenty-character title ("PERFORMANCE OVERVIEW") does not fit a
          // padded card at 15px however the row is divided up. Losing a word
          // is always worse than losing a point of type size, and with nine
          // locales the longest translation is never the one anybody tested.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GameTypography.headlineSmall(color: theme.accentColor)
                .copyWith(
              fontSize: 15,
              // Same reason as the app bar: bold is the weight this label has
              // always been, and headlineSmall's own w500 is not it.
              fontWeight: FontWeight.w700,
              letterSpacing: context.letterSpacing(1.5),
            ),
          ),
          ),
        ),
        if (count != null && count > 0) ...[
          SizedBox(width: 8 * scale),
          Text(
            '$count',
            style: const TextStyle(
              color: kRewardGold,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
        // The rule and its terminator. Runs to the edge so the eye is carried
        // across the panel rather than stopping at the title.
        SizedBox(width: 10 * scale),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accentColor.withValues(alpha: 0.45),
                  theme.accentColor.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 6 * scale),
        // The rule ends in a terminator, unless the section has a real action
        // to put there. A "view all" and a decorative diamond competing for
        // the same corner reads as two controls, one of which does nothing.
        // Bounded to what was reserved above, so a caller-supplied action
        // cannot push the row wider than the constraints allow.
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: trailingReserve),
          child:
              trailing ??
              Transform.rotate(
                angle: 0.785398, // 45°
                child: Container(
                  width: 5 * scale,
                  height: 5 * scale,
                  color: theme.accentColor.withValues(alpha: 0.7),
                ),
              ),
        ),
      ],
        );
      },
    ),
  );
}

/// Eyebrow plus card, which is what most of a screen is.
///
/// [index] opts this section into the staggered entrance. Screens with a
/// handful of sections should pass it; a long grid of cards should not.
Widget screenSection(
  BuildContext context,
  GameTheme theme,
  String title,
  Widget child, {
  int? count,
  Color? borderColor,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  IconData? icon,
  int? index,
  Widget? trailing,
}) {
  final section = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      screenEyebrow(
        context,
        theme,
        title,
        count: count,
        icon: icon,
        trailing: trailing,
      ),
      screenCard(
        theme,
        borderColor: borderColor,
        padding: padding,
        child: child,
      ),
    ],
  );

  return index == null ? section : section.gameListItem(index);
}

/// The body: themed background, safe area, and the column inset that caps
/// content to a readable width on tablets.
Widget screenBody({
  required BuildContext context,
  required GameTheme theme,
  required Widget child,
  double horizontal = 24,
  double vertical = 24,
}) {
  return AppBackground(
    theme: theme,
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal + context.sideInset(),
          vertical: vertical,
        ),
        child: child,
      ),
    ),
  );
}

/// One line of reference: the thing, and what it is.
///
/// Two flexible columns rather than a fixed-width label and a remainder — the
/// pattern the settings and help screens use for the same job, and the reason
/// a long localized label wraps instead of clipping.
Widget screenKeyValue(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: GameTypography.bodyMedium(color: Colors.white).copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GameTypography.bodySmall(
              color: valueColor ?? Colors.white.withValues(alpha: 0.64),
            ).copyWith(
              fontSize: 13,
              fontWeight: valueColor == null ? null : FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A quiet heading inside a card, for the halves of a longer table.
Widget screenGroupLabel(BuildContext context, String label) {
  return Text(
    label.toUpperCase(),
    style: GameTypography.labelSmall(
      color: Colors.white.withValues(alpha: 0.58),
    ).copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: context.letterSpacing(1),
    ),
  );
}

/// A progress bar, as an instrument rather than a Material widget.
///
/// LinearProgressIndicator is the same kind of tell the Material Switch was on
/// the settings screen: correct, legible, and unmistakably a phone app's. This
/// Written for the gameplay level bar; the loading screens and the arena
/// hand-rolled their own from a FractionallySizedBox, which is the same
/// bar drawn three ways. This is the same value read as a gauge — an inset track, a lit fill that carries
/// its own bloom, and segment ticks so a glance reads roughly how far along
/// the level is without parsing the number underneath.
///
/// Ticks are drawn OVER the fill in the track colour, so they read as notches
/// cut into the bar rather than as marks floating above it.
class HudGauge extends StatelessWidget {
  const HudGauge({
    super.key,
    required this.value,
    required this.fill,
    required this.track,
    required this.height,
  });

  final double value;
  final Color fill;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: track.withValues(alpha: 0.28), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            // The lit fill.
            FractionallySizedBox(
              widthFactor: v,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [fill.withValues(alpha: 0.75), fill],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fill.withValues(alpha: 0.55),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            // Segment notches.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GaugeTicks(color: track.withValues(alpha: 0.55)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeTicks extends CustomPainter {
  const _GaugeTicks({required this.color});

  final Color color;

  /// Five segments — enough to read position at a glance, few enough that the
  /// ticks do not turn a 6px bar into a dotted line.
  static const int _segments = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var i = 1; i < _segments; i++) {
      final x = size.width * i / _segments;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GaugeTicks oldDelegate) => oldDelegate.color != color;
}

/// A placeholder block that holds the space real content will occupy.
///
/// Every screen in this app that fetched something used to swap a centred
/// spinner for a list, which drops everything below it the moment the network
/// answers. A skeleton is the same height as the thing it stands in for, so
/// nothing moves.
class ScreenSkeleton extends StatelessWidget {
  const ScreenSkeleton({
    super.key,
    required this.theme,
    this.lines = 3,
    this.height = 92,
  });

  final GameTheme theme;
  final int lines;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget bone(double width, double barHeight) => Container(
      width: width,
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Column(
      children: [
        for (var i = 0; i < lines; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: screenCard(
              theme,
              child: SizedBox(
                height: height - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    bone(150, 13),
                    bone(220, 11),
                    bone(90, 11),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
