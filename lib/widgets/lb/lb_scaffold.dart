import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_banner_slot.dart';
import 'package:snake_classic/widgets/lb/lb_grid_background.dart';
import 'package:snake_classic/widgets/lb/lb_header.dart';
import 'package:snake_classic/widgets/lb/lb_stagger_in.dart';

/// The page every Living Board screen uses (DESIGN_SPEC §2): the grid board,
/// the header (back block, cell-font title, optional action, subtitle), a
/// scrolling body padded to the content gutter, and the banner slot.
///
/// Pass [children] for a simple column, or [body] for full control (tabs,
/// custom scroll views). [children] scroll; [body] is placed as-is under the
/// header.
class LBScaffold extends StatelessWidget {
  const LBScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.children,
    this.body,
    this.bottom,
    this.banner = true,
    this.bannerTopGap = 0,
    this.onBack,
    this.showBack = true,
    this.spacing = 0,
  }) : assert(children != null || body != null);

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget>? children;
  final Widget? body;

  /// Pinned under the body, above the banner (sticky CTAs, footers).
  final Widget? bottom;
  final bool banner;
  final double bannerTopGap;
  final VoidCallback? onBack;
  final bool showBack;

  /// Vertical gap inserted between [children].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final g = context.lbGutter;
    Widget content;
    if (body != null) {
      content = body!;
    } else {
      // Screen-open choreography: rows fade + rise in, staggered, once.
      // The group's clock lives in this element, so rebuilds and rows that
      // scroll into view later don't replay it.
      final kids = <Widget>[];
      for (var i = 0; i < children!.length; i++) {
        if (i > 0 && spacing > 0) kids.add(SizedBox(height: spacing));
        final child = children![i];
        kids.add(LBStaggerIn(
          // Lift the row's key to the wrapper so keyed rows still keep their
          // state when the list reorders.
          key: child.key == null ? null : ValueKey(child.key),
          index: i,
          child: child,
        ));
      }
      content = LBStaggerGroup(
        child: ListView(
          padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell * 1.5),
          children: kids,
        ),
      );
    }
    return Scaffold(
      bottomNavigationBar: banner ? LBBannerSlot(topGap: bannerTopGap) : null,
      body: LBGridBackground(
        child: SafeArea(
          top: false,
          bottom: !banner,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PinnedHeaderBand(
                child: LBHeader(
                  title: title,
                  subtitle: subtitle,
                  trailing: trailing,
                  onBack: onBack,
                  showBack: showBack,
                ),
              ),
              // Content scrolling up under the header is clipped at the
              // band's edge and fades out over a short strip that starts
              // fully opaque, so nothing reads through under the subtitle.
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned.fill(child: content),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: context.lbCell * .85,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0, .3, 1],
                                colors: [
                                  context.lb.board,
                                  context.lb.board,
                                  context.lb.board.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// The pinned title/subtitle area, status-bar inset included, on an opaque
/// background so scrolled content never shows through it.
///
/// On a flat board that background is the board itself (grid and all,
/// painted by [LBGridBackground] behind it), so the band is left
/// transparent and the grid lines keep running through the header. On a
/// scene theme (Miami Nights) the scene is what would show, and the fade
/// strip under the band starts in the flat board colour, so the band is
/// painted solid board to match it and the two read as one surface.
class _PinnedHeaderBand extends StatelessWidget {
  const _PinnedHeaderBand({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: child,
    );
    if (!LBGridBackground.paintsScene(context)) return padded;
    return ColoredBox(color: context.lb.board, child: padded);
  }
}
