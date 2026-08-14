import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
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
/// The rules it encodes:
///   * The title is the theme's accent, uppercase, tracked, over a
///     transparent bar with the background showing through.
///   * A section is an uppercase accent eyebrow over a hairline-bordered
///     translucent card. One column.
///   * Accent means progress and action. [kRewardGold] means a reward.
///     Everything else is white at some opacity — 0.85 for what you read,
///     0.55 for what explains it, 0.45 for what labels it.
///   * No gradients on cards, no glow shadows, no entrance animations, and no
///     coloured pill for a state that a word would carry.

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
}) {
  return AppBar(
    title: Text(
      title.toUpperCase(),
      style: TextStyle(
        color: theme.accentColor,
        fontWeight: FontWeight.bold,
        letterSpacing: context.letterSpacing(2),
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: theme.accentColor),
    leading: leading,
    actions: actions,
  );
}

/// The card a section's contents sit in.
BoxDecoration screenCardDecoration(GameTheme theme, {Color? borderColor}) {
  return BoxDecoration(
    color: theme.backgroundColor.withValues(alpha: 0.3),
    // 0.3 was chosen when the art on these screens was as restrained as the
    // chrome. Against the current logo a hairline that faint reads as a
    // smudge rather than an edge.
    border: Border.all(
      color: borderColor ?? theme.accentColor.withValues(alpha: 0.42),
    ),
    borderRadius: BorderRadius.circular(16),
  );
}

Widget screenCard(
  GameTheme theme, {
  required Widget child,
  Color? borderColor,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: screenCardDecoration(theme, borderColor: borderColor),
    child: child,
  );
}

/// The uppercase accent label that names a section.
///
/// [count] puts a number beside it in gold, for the sections where "how many
/// are waiting" is the reason to look — claimable rewards, pending requests.
Widget screenEyebrow(
  BuildContext context,
  GameTheme theme,
  String title, {
  int? count,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Row(
      children: [
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: context.letterSpacing(1.5),
            ),
          ),
        ),
        if (count != null && count > 0) ...[
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: kRewardGold,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Eyebrow plus card, which is what most of a screen is.
Widget screenSection(
  BuildContext context,
  GameTheme theme,
  String title,
  Widget child, {
  int? count,
  Color? borderColor,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      screenEyebrow(context, theme, title, count: count),
      screenCard(
        theme,
        borderColor: borderColor,
        padding: padding,
        child: child,
      ),
    ],
  );
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
            style: const TextStyle(
              color: Colors.white,
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
            style: TextStyle(
              color: valueColor ?? Colors.white.withValues(alpha: 0.64),
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
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.58),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: context.letterSpacing(1),
    ),
  );
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
