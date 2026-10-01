import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/overlays/lb_overlay_parts.dart';

/// A full-screen, tap-absorbing "Ad starting…" beat laid over everything
/// between the button press that triggers a full-screen ad and the moment the
/// ad is actually on screen.
///
/// Without it the ad opened in the same instant PLAY AGAIN registered, so the
/// second half of a double-tap — or the next tap of an impatient thumb —
/// landed on the ad and opened the advertiser's page. Google treats those as
/// accidental clicks. The curtain also tells the player, honestly, what is
/// about to happen.
///
/// Lives in the root overlay so it covers the whole app, and is taken down by
/// the caller (on the ad's "showed" callback, and again in a `finally` so it
/// can never be left behind).
class AdBreakCurtain {
  AdBreakCurtain._(this._entry);

  final OverlayEntry _entry;
  bool _removed = false;

  /// Inserts the curtain, or returns null when there is no overlay to put it
  /// in (the screen is already gone).
  static AdBreakCurtain? show(
    BuildContext context, {
    required GameTheme theme,
    required String label,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return null;
    final entry = OverlayEntry(
      builder: (_) => _CurtainView(theme: theme, label: label),
    );
    overlay.insert(entry);
    return AdBreakCurtain._(entry);
  }

  /// Idempotent — safe to call from both the ad callback and a `finally`.
  void dismiss() {
    if (_removed) return;
    _removed = true;
    _entry.remove();
  }
}

class _CurtainView extends StatelessWidget {
  const _CurtainView({required this.theme, required this.label});

  final GameTheme theme;

  /// The caller's label. Shown only if the Living Board copy is unavailable
  /// (no localizations above the root overlay).
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final text = AppLocalizations.of(context)?.lbAdStarting ?? label;
    return Positioned.fill(
      child: AbsorbPointer(
        child: Material(
          color: p.board.withValues(alpha: 0.86),
          child: Center(
            child: Semantics(
              liveRegion: true,
              label: text,
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LBCellSpinner(count: 5, cell: 10),
                    const SizedBox(height: 16),
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: LBText.button(p, color: p.ink, size: 13).copyWith(letterSpacing: 2.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
