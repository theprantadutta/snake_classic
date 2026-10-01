import 'package:flutter/material.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';

/// The bottom banner slot (DESIGN_SPEC §2, §8). A thin wrapper so screens
/// read as Living Board; all behaviour — reserved height from the first
/// frame, zero space for Pro, retry/backoff, preloading — stays in
/// [SnakeBannerAd], untouched.
///
/// [topGap] keeps the policy clearance from controls: 12 dp in gameplay
/// (swipe players only), 20 dp on game over. See admob_ad_list.md.
class LBBannerSlot extends StatelessWidget {
  const LBBannerSlot({super.key, this.topGap = 0});

  final double topGap;

  @override
  Widget build(BuildContext context) => SnakeBannerAd(topGap: topGap);
}
