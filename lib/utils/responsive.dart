import 'package:flutter/widgets.dart';

/// Device size classes used to adapt the (phone-first) UI to tablets / iPads.
///
/// Classification uses [Size.shortestSide], the standard Flutter convention for
/// tablet detection. Because the app is portrait-locked, the shortest side is
/// effectively the device width:
///   * `< 600`  → phone
///   * `>= 600` → tablet (7" / small iPad)
///   * `>= 840` → large tablet (10"+ / iPad Pro)
enum DeviceSize { phone, tablet, largeTablet }

/// Shared content-width caps so every screen centers its body to the SAME
/// column width on tablets (no more 600/640/760 drift between sibling screens).
///   * [menuMaxWidth]  — default for menus, lists, settings, detail screens.
///   * [wideMaxWidth]  — for denser grid content (e.g. the store) that benefits
///     from a bit more room.
class ContentWidth {
  ContentWidth._();
  static const double menuMaxWidth = 640.0;
  static const double wideMaxWidth = 760.0;
}

/// Responsive helpers hung off [BuildContext]. This mirrors how the codebase
/// already reads `MediaQuery` inline, so no new dependency or InheritedWidget
/// is introduced.
///
/// The key invariant: **on phones everything here is a no-op** — [uiScale] is
/// exactly `1.0`, [isTablet] is `false`, and [contentMaxWidth] is unbounded.
/// So gating a size change on these keeps phone layouts byte-for-byte unchanged.
extension ResponsiveContext on BuildContext {
  DeviceSize get deviceSize {
    final shortestSide = MediaQuery.of(this).size.shortestSide;
    if (shortestSide >= 840) return DeviceSize.largeTablet;
    if (shortestSide >= 600) return DeviceSize.tablet;
    return DeviceSize.phone;
  }

  /// Whether the current device is a tablet-class device (any tablet tier).
  bool get isTablet => deviceSize != DeviceSize.phone;

  /// Multiplier applied to fixed pixel sizes (heights, paddings, icon sizes).
  /// Exactly `1.0` on phones so existing values are preserved.
  double get uiScale {
    switch (deviceSize) {
      case DeviceSize.phone:
        return 1.0;
      case DeviceSize.tablet:
        return 1.2;
      case DeviceSize.largeTablet:
        return 1.35;
    }
  }

  /// Scale an arbitrary pixel dimension for the current device class.
  double scaled(double value) => value * uiScale;

  /// Type/icon scale for dense glanceable readouts — the gameplay HUD.
  ///
  /// This is the one helper here that varies *within* the phone class, and it
  /// exists because [uiScale] deliberately does not. The gameplay HUD used to
  /// pick its font sizes from a `screenHeight < 700` flag, which is the wrong
  /// axis twice over:
  ///
  ///  * That height is the play area measured *after* the safe area and the
  ///    banner ad, so it lands around 678 on a 360x800 Android and around 721
  ///    on a 393x852 one. The threshold sits between the two most common phone
  ///    sizes and the ad's height decides which side you fall on — a *wider*
  ///    phone could end up with *smaller* type.
  ///  * Legibility is a function of width and viewing distance, not of how
  ///    much vertical room is left over.
  ///
  /// So: derived from the width, ramping from `1.0` at 360dp to `1.15` at
  /// 430dp, then handed to [uiScale] above the phone class. The invariant in
  /// this file's header still holds in the direction that matters — this is
  /// exactly `1.0` on the narrowest phones and only ever grows from there, so
  /// no existing phone layout shrinks.
  double get readoutScale {
    if (isTablet) return uiScale;
    final shortestSide = MediaQuery.of(this).size.shortestSide;
    final t = ((shortestSide - 360) / 70).clamp(0.0, 1.0);
    return 1.0 + 0.15 * t;
  }

  /// [readoutScale] applied to a base size, rounded to a half pixel so text
  /// does not land on awkward fractional font sizes.
  double readout(double value) => (value * readoutScale * 2).roundToDouble() / 2;

  /// Pick a value per device class. The [phone] value is always required and is
  /// used as the fallback for any tier not explicitly provided.
  T responsive<T>({required T phone, T? tablet, T? largeTablet}) {
    switch (deviceSize) {
      case DeviceSize.largeTablet:
        return largeTablet ?? tablet ?? phone;
      case DeviceSize.tablet:
        return tablet ?? phone;
      case DeviceSize.phone:
        return phone;
    }
  }

  /// Max width for centered menu / list bodies. Unbounded on phones (so content
  /// still fills the screen); capped on tablets so rows don't stretch edge-to-edge.
  double get contentMaxWidth =>
      isTablet ? ContentWidth.menuMaxWidth : double.infinity;

  /// Horizontal inset that visually caps content to [maxWidth] (defaulting to
  /// [contentMaxWidth]) by padding both sides equally. Returns `0` on phones or
  /// whenever the screen is already narrower than the cap.
  ///
  /// Prefer this over a centered `ConstrainedBox` when the child is a
  /// `TabBarView`, `ListView`, or anything with strict height constraints — a
  /// `Padding` preserves the incoming constraints (just narrower), so it can't
  /// trigger unbounded-size errors.
  double sideInset({double? maxWidth}) {
    final cap = maxWidth ?? contentMaxWidth;
    if (cap == double.infinity) return 0;
    final width = MediaQuery.of(this).size.width;
    return width > cap ? (width - cap) / 2 : 0;
  }
}

/// Centers and caps its child's width on tablets; a transparent pass-through on
/// phones. Use to wrap menu / settings / detail screen bodies so their content
/// forms a comfortable centered column on large screens instead of stretching.
///
/// Safe to place inside a scrolling parent — it only constrains horizontally.
class MaxWidthBody extends StatelessWidget {
  const MaxWidthBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;

  /// Overrides [ResponsiveContext.contentMaxWidth] when provided.
  final double? maxWidth;

  /// How the capped child is aligned within the extra space. Defaults to top-
  /// center so scrollable content starts at the top.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? context.contentMaxWidth;
    if (cap == double.infinity) return child;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
