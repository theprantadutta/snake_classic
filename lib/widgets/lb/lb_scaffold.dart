import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/lb/lb_banner_slot.dart';
import 'package:snake_classic/widgets/lb/lb_grid_background.dart';
import 'package:snake_classic/widgets/lb/lb_header.dart';

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
      final kids = <Widget>[];
      for (var i = 0; i < children!.length; i++) {
        if (i > 0 && spacing > 0) kids.add(SizedBox(height: spacing));
        kids.add(children![i]);
      }
      content = ListView(
        padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell * 1.5),
        children: kids,
      );
    }
    return Scaffold(
      bottomNavigationBar: banner ? LBBannerSlot(topGap: bannerTopGap) : null,
      body: LBGridBackground(
        child: SafeArea(
          bottom: !banner,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LBHeader(
                title: title,
                subtitle: subtitle,
                trailing: trailing,
                onBack: onBack,
                showBack: showBack,
              ),
              Expanded(child: content),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}
