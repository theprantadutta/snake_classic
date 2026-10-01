import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// The THEME strip on Settings: one swatch per [GameTheme], each painted in
/// that theme's own Living Board palette (board colour + a lime bar), so the
/// strip previews exactly what picking it does. Locked premium themes carry
/// a lock pixel; the active one gets a full-lime frame.
class SettingsThemeStrip extends StatelessWidget {
  const SettingsThemeStrip({
    super.key,
    required this.current,
    required this.isUnlocked,
    required this.onTap,
  });

  final GameTheme current;
  final bool Function(GameTheme) isUnlocked;
  final ValueChanged<GameTheme> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final t in GameTheme.values)
          Expanded(
            child: _Swatch(
              theme: t,
              selected: t == current,
              locked: !isUnlocked(t),
              onTap: () => onTap(t),
            ),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.theme,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final GameTheme theme;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final active = context.lb;
    final own = LBPalette.of(theme);
    final name = theme.localizedName(l10n);
    return Semantics(
      button: true,
      selected: selected,
      label: locked ? l10n.lbThemeSwatchLocked(name) : name,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          LBFeedback.tap();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(LB.inset),
          child: SizedBox(
            // 48 dp tall whatever the width, so the strip stays a usable
            // hit target on the narrowest phones.
            height: 48 * context.uiScale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: own.board,
                borderRadius: BorderRadius.circular(LB.blockRadius),
                border: Border.all(
                  color: selected ? active.lime : own.lime.withValues(alpha: .32),
                  width: selected ? 2.5 : 1,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: active.lime.withValues(alpha: .35), blurRadius: 10)]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                child: Column(
                  children: [
                    Expanded(
                      child: locked
                          ? Center(
                              child: LBPixelIcon(
                                LBIcon.lock,
                                cell: 1.8,
                                color: own.ink.withValues(alpha: .75),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Container(
                      height: 9 * context.uiScale,
                      decoration: BoxDecoration(
                        color: own.lime,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
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
