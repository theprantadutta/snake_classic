import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';

/// The banner slot (DESIGN_SPEC §2, §8). A thin wrapper so screens read as
/// Living Board; all behaviour — reserved height from the first frame, zero
/// space for Pro, retry/backoff, preloading — stays in [SnakeBannerAd],
/// untouched.
///
/// [topGap] keeps the policy clearance from controls: 12 dp in gameplay
/// (where the banner sits at the TOP, [atTop], the gap is under it), 20 dp
/// on game over. See admob_ad_list.md.
class LBBannerSlot extends StatelessWidget {
  const LBBannerSlot({super.key, this.topGap = 0, this.atTop = false});

  final double topGap;
  final bool atTop;

  @override
  Widget build(BuildContext context) =>
      SnakeBannerAd(topGap: topGap, atTop: atTop);
}
