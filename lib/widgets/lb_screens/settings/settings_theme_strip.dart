import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// The THEME strip on Settings: one swatch per [GameTheme], each painted in
/// that theme's own Living Board palette (board colour + a lime bar), so the
/// strip previews exactly what picking it does. Locked premium themes carry
/// a lock pixel; the active one gets a full-lime frame.
///
/// Every swatch is at least 48×48 dp. Eleven of them do not fit across a
/// phone at that size (squeezed into one row they were ~29 dp wide), so the
/// strip scrolls sideways and opens with the active theme in view. Where
/// they all fit (tablets) they share the width and nothing scrolls.
class SettingsThemeStrip extends StatefulWidget {
  const SettingsThemeStrip({
    super.key,
    required this.current,
    required this.isUnlocked,
    required this.onTap,
  });

  final GameTheme current;
  final bool Function(GameTheme) isUnlocked;
  final ValueChanged<GameTheme> onTap;

  /// Smallest swatch box, before [uiScale]; the outer slot adds the inset.
  static const double minSwatch = 48;

  @override
  State<SettingsThemeStrip> createState() => _SettingsThemeStripState();
}

class _SettingsThemeStripState extends State<SettingsThemeStrip> {
  final ScrollController _scroll = ScrollController();
  bool _revealed = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Centre the active swatch once, after the first layout.
  void _revealCurrent(double itemWidth) {
    if (_revealed) return;
    _revealed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final pos = _scroll.position;
      final index = GameTheme.values.indexOf(widget.current);
      final target =
          index * itemWidth - (pos.viewportDimension - itemWidth) / 2;
      _scroll.jumpTo(target.clamp(pos.minScrollExtent, pos.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    final themes = GameTheme.values;
    final scale = context.uiScale;
    final swatch = SettingsThemeStrip.minSwatch * scale;
    return LayoutBuilder(
      builder: (context, box) {
        // Slot = swatch + the inset on both sides, or an equal share of the
        // row when that is bigger.
        final itemWidth = math.max(
          swatch + LB.inset * 2 + 4,
          box.maxWidth / themes.length,
        );
        _revealCurrent(itemWidth);
        // Room above and below for the selected frame's glow, which the
        // scroll view would otherwise clip flat.
        const glow = 6.0;
        return SizedBox(
          height: swatch + LB.inset * 2 + glow * 2,
          child: ListView.builder(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            itemExtent: itemWidth,
            itemCount: themes.length,
            itemBuilder: (context, i) {
              final t = themes[i];
              return Center(
                child: _Swatch(
                  theme: t,
                  selected: t == widget.current,
                  locked: !widget.isUnlocked(t),
                  height: swatch,
                  onTap: () => widget.onTap(t),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.theme,
    required this.selected,
    required this.locked,
    required this.height,
    required this.onTap,
  });

  final GameTheme theme;
  final bool selected;
  final bool locked;
  final double height;
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
            width: double.infinity,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: own.board,
                borderRadius: BorderRadius.circular(LB.blockRadius),
                border: Border.all(
                  color: selected
                      ? active.lime
                      : own.lime.withValues(alpha: .32),
                  width: selected ? 2.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: active.lime.withValues(alpha: .35),
                          blurRadius: 10,
                        ),
                      ]
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
