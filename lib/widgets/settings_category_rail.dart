import 'package:flutter/material.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';

/// One jump target on the rail.
class SettingsCategory {
  const SettingsCategory({
    required this.label,
    required this.icon,
    required this.key,
  });

  final String label;
  final IconData icon;

  /// Attached to the section this chip scrolls to. The section must be built
  /// — which it is, because the body is a [SingleChildScrollView] and builds
  /// every child regardless of whether it is on screen.
  final GlobalKey key;
}

/// The pinned category strip under the settings title.
///
/// Twelve sections in one scroll is a phone settings screen's problem, and
/// scrolling past eleven of them to reach the twelfth is the part that felt
/// least like a game. The rail turns the scroll into a menu: every category is
/// one tap away, and the chip for wherever you are stays lit.
///
/// It tracks [bodyController] rather than being told the active section, so
/// the highlight is correct whether you got there by tapping a chip or by
/// scrolling with your thumb.
class SettingsCategoryRail extends StatefulWidget {
  const SettingsCategoryRail({
    super.key,
    required this.categories,
    required this.bodyController,
    required this.theme,
  });

  final List<SettingsCategory> categories;
  final ScrollController bodyController;
  final GameTheme theme;

  @override
  State<SettingsCategoryRail> createState() => _SettingsCategoryRailState();
}

class _SettingsCategoryRailState extends State<SettingsCategoryRail> {
  final ScrollController _railController = ScrollController();

  /// Chip keys, so the rail can scroll the active chip into its own view.
  late List<GlobalKey> _chipKeys;

  int _active = 0;

  /// Set while a tap-driven scroll is animating. The body passes under every
  /// intervening section on the way, and without this the highlight would
  /// flicker through all of them before landing.
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _chipKeys = List.generate(widget.categories.length, (_) => GlobalKey());
    widget.bodyController.addListener(_onBodyScroll);
  }

  @override
  void dispose() {
    widget.bodyController.removeListener(_onBodyScroll);
    _railController.dispose();
    super.dispose();
  }

  void _onBodyScroll() {
    if (_jumping || !mounted) return;

    // The section whose header has most recently passed the top of the
    // viewport is the one you are "in". Measured against a band below the
    // rail rather than the very top, or a section counts as current while
    // it is still only one pixel on screen.
    final threshold = _railBottomGlobalY() + 24;
    int candidate = 0;

    for (var i = 0; i < widget.categories.length; i++) {
      final ctx = widget.categories[i].key.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= threshold) {
        candidate = i;
      }
    }

    if (candidate != _active) {
      setState(() => _active = candidate);
      _revealChip(candidate);
    }
  }

  double _railBottomGlobalY() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return 0;
    return box.localToGlobal(Offset.zero).dy + box.size.height;
  }

  void _revealChip(int index) {
    final ctx = _chipKeys[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      // Keeps the active chip off the very edge, so the neighbours stay
      // visible and the rail reads as a strip you can move along.
      alignment: 0.4,
    );
  }

  Future<void> _jumpTo(int index) async {
    final ctx = widget.categories[index].key.currentContext;
    if (ctx == null) return;

    HapticService().selectionClick();
    setState(() {
      _active = index;
      _jumping = true;
    });
    _revealChip(index);

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      // 0.0 puts the section header at the top of what is left of the
      // viewport, which is directly under this rail.
      alignment: 0.0,
    );

    if (mounted) setState(() => _jumping = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;
    final theme = widget.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          // Derived from the chip's own text rather than fixed. The root
          // MediaQuery multiplies a tablet's base bump by the OS
          // accessibility factor, which tops out around 1.42 on a large
          // tablet — a hard 38 would clip the label there.
          height:
              (26 + MediaQuery.textScalerOf(context).scale(11.5)) * scale,
          child: ListView.separated(
            controller: _railController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: widget.categories.length,
            separatorBuilder: (_, _) => SizedBox(width: 8 * scale),
            itemBuilder: (context, i) {
              final cat = widget.categories[i];
              final selected = i == _active;

              return Semantics(
                label: cat.label,
                button: true,
                selected: selected,
                onTap: () => _jumpTo(i),
                excludeSemantics: true,
                child: GestureDetector(
                  key: _chipKeys[i],
                  onTap: () => _jumpTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.accentColor.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.04),
                      border: Border.all(
                        color: selected
                            ? theme.accentColor
                            : theme.accentColor.withValues(alpha: 0.24),
                        width: selected ? 1.6 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: theme.accentColor
                                    .withValues(alpha: 0.30),
                                blurRadius: 12,
                                spreadRadius: -3,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 14 * scale,
                          color: selected
                              ? theme.accentColor
                              : Colors.white.withValues(alpha: 0.55),
                        ),
                        SizedBox(width: 6 * scale),
                        Text(
                          cat.label.toUpperCase(),
                          style: GameTypography.labelMedium(
                            color: selected
                                ? theme.accentColor
                                : Colors.white.withValues(alpha: 0.65),
                          ).copyWith(
                            fontSize: 11.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: context.letterSpacing(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10 * scale),
        // The rule that separates the fixed rail from the scrolling body, so
        // sections passing underneath have an edge to disappear behind.
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentColor.withValues(alpha: 0.05),
                theme.accentColor.withValues(alpha: 0.45),
                theme.accentColor.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
