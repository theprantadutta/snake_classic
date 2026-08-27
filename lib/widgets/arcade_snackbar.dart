import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/screen_shell.dart';

/// What a snack bar is telling you, which is the only thing a caller should
/// have to decide. Everything else — colour, icon, contrast — follows.
///
/// Call sites used to pass `backgroundColor: Colors.red` or
/// `backgroundColor: theme.accentColor` by hand, eighty-odd times, which is
/// how "red means failure" turned into three different reds and a couple of
/// successes that were also red.
enum ArcadeSnackTone {
  /// Something happened. Neutral, themed.
  info,

  /// Something the player wanted, worked.
  success,

  /// Not broken, but not what they asked for either.
  warning,

  /// It failed.
  error,
}

extension _ToneStyle on ArcadeSnackTone {
  /// Only [info] is themed. The other three carry meaning, and meaning must
  /// not depend on which skin the player picked: `theme.snakeColor` made
  /// success and info the same green on Classic and Forest, so "claimed" and
  /// "working on it" were the same colour on the themes most people use.
  Color color(GameTheme theme) => switch (this) {
    ArcadeSnackTone.info => theme.accentColor,
    ArcadeSnackTone.success => const Color(0xFF4ADE80),
    ArcadeSnackTone.warning => kRewardGold,
    ArcadeSnackTone.error => const Color(0xFFFF5C5C),
  };

  IconData get icon => switch (this) {
    ArcadeSnackTone.info => Icons.info_outline_rounded,
    ArcadeSnackTone.success => Icons.check_rounded,
    ArcadeSnackTone.warning => Icons.warning_amber_rounded,
    ArcadeSnackTone.error => Icons.error_outline_rounded,
  };
}

/// A snack bar in the app's own language: bracketed corners, the top-lit
/// panel, Rajdhani body text.
///
/// Every other surface in this app is an instrument panel — see the notes at
/// the top of `screen_shell.dart`. Snack bars were the one thing that still
/// looked like stock Material: a grey slab with a system font, sliding in over
/// a bracketed arcade screen. They are also the most-seen widget in the app
/// after the HUD, which made them the loudest exception to the rule.
///
/// Returns the [SnackBar] rather than showing it, deliberately. Plenty of call
/// sites capture `ScaffoldMessenger.of(context)` *before* an await and show it
/// after — the correct pattern for not touching a `BuildContext` across an
/// async gap — and a `show...` helper that looked the messenger up itself
/// would quietly undo that at every one of them.
///
/// ```dart
/// ScaffoldMessenger.of(context).showSnackBar(
///   arcadeSnackBar(context, message: l10n.storePurchaseFailed,
///       tone: ArcadeSnackTone.error),
/// );
/// ```
SnackBar arcadeSnackBar(
  BuildContext context, {
  required String message,
  ArcadeSnackTone tone = ArcadeSnackTone.info,

  /// Overrides the tone's own icon. Pass null for the default; there is no way
  /// to ask for no icon, because the icon is what makes the tone readable at a
  /// glance and in a colour-blind palette.
  IconData? icon,

  /// An optional single action. The label is shown inside the panel; tapping
  /// it runs [onAction] and dismisses.
  String? actionLabel,
  VoidCallback? onAction,

  /// Defaults to Material's own 4 seconds, and 6 for [ArcadeSnackTone.error]
  /// — a failure is usually worth reading twice.
  Duration? duration,
}) => arcadeSnackBarFor(
  context.read<ThemeCubit>().state.currentTheme,
  message: message,
  tone: tone,
  icon: icon,
  actionLabel: actionLabel,
  onAction: onAction,
  duration: duration,
);

/// [arcadeSnackBar] for a theme you already hold.
///
/// Use this after an `await`. Several call sites capture
/// `ScaffoldMessenger.of(context)` before the gap and show afterwards, and
/// reaching back through the `BuildContext` at that point is the thing that
/// pattern exists to avoid — the analyzer says so, and this app has already
/// shipped one crash from a stale context. Capture the theme alongside the
/// messenger and hand it here instead.
///
/// ```dart
/// final messenger = ScaffoldMessenger.of(context);
/// final theme = context.read<ThemeCubit>().state.currentTheme;
/// final ok = await something();
/// messenger.showSnackBar(arcadeSnackBarFor(theme, message: ...));
/// ```
SnackBar arcadeSnackBarFor(
  GameTheme theme, {
  required String message,
  ArcadeSnackTone tone = ArcadeSnackTone.info,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  final accent = tone.color(theme);

  return SnackBar(
    // The panel below IS the snack bar's appearance, so Material must not
    // paint one of its own underneath it.
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    duration:
        duration ??
        (tone == ArcadeSnackTone.error
            ? const Duration(seconds: 6)
            : const Duration(seconds: 4)),
    content: _ArcadeSnackPanel(
      message: message,
      icon: icon ?? tone.icon,
      accent: accent,
      theme: theme,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

class _ArcadeSnackPanel extends StatelessWidget {
  const _ArcadeSnackPanel({
    required this.message,
    required this.icon,
    required this.accent,
    required this.theme,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final Color accent;
  final GameTheme theme;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        // An opaque floor under the panel. `arcadeSurface` is translucent by
        // design — it sits on a screen whose own background it is meant to
        // show through. A snack bar floats over the game board, a leaderboard,
        // anything; without this the message competes with whatever is behind
        // it and the failure case is an unreadable error.
        decoration: BoxDecoration(
          color: Color.lerp(theme.backgroundColor, Colors.black, 0.35)!,
          borderRadius: radius,
        ),
        child: Container(
          decoration: arcadeSurface(
            theme,
            tint: accent,
            borderRadius: radius,
            borderColor: accent.withValues(alpha: 0.55),
            baseAlpha: 0.95,
          ),
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          child: HudCorners(
            color: accent,
            inset: 5,
            arm: 11,
            // The panel is the thing being decorated, not resized — see the
            // note on HudCorners. Without passthrough the row shrink-wraps
            // into the corner.
            clipBehavior: Clip.none,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Icon(icon, size: 15, color: accent),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    message,
                    style: GameTypography.bodyMedium(
                      color: Colors.white.withValues(alpha: 0.92),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(width: 8),
                  // Builder so the dismiss below resolves the messenger from a
                  // context INSIDE it. Looking it up from the calling screen's
                  // context is the crash this app already shipped once: a
                  // snack bar outlives the screen that showed it, and by the
                  // time the button is tapped that element is defunct.
                  Builder(
                    builder: (inner) => TextButton(
                      // Caller's callback first, dismiss second — the order
                      // SnackBarAction uses. Dismissing first tears down the
                      // subtree this button lives in, and anything the
                      // callback wanted from it is gone by the time it runs.
                      onPressed: () {
                        onAction?.call();
                        ScaffoldMessenger.of(inner).hideCurrentSnackBar();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: accent.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: GameTypography.bodyMedium(color: accent)
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: context.letterSpacing(0.5),
                            ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
