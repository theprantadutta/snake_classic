import 'package:flutter/material.dart';

/// Available transition types for page navigation
enum AppTransitionType {
  /// Fade + slight horizontal slide - default for most screens
  fadeSlide,

  /// Zoom in with fade - for game screen entry
  zoomIn,

  /// Slide up with fade - for modal-like screens
  slideUp,

  /// Slide from right - for lateral navigation
  slideLeft,

  /// Scale up with fade - for dramatic reveals
  scale,

  /// No animation - instant transition
  none,
}

/// Custom page route with predefined transitions
class AppPageRoute<T> extends PageRouteBuilder<T> {
  /// The page widget to navigate to
  final Widget page;

  /// The type of transition animation
  final AppTransitionType transitionType;

  /// Optional custom duration (overrides default)
  final Duration? customDuration;

  AppPageRoute({
    required this.page,
    this.transitionType = AppTransitionType.fadeSlide,
    this.customDuration,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration:
              customDuration ?? _getDuration(transitionType),
          reverseTransitionDuration:
              customDuration ?? _getDuration(transitionType),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              transitionType,
              animation,
              secondaryAnimation,
              child,
            );
          },
        );

  /// Get default duration for each transition type
  static Duration _getDuration(AppTransitionType type) {
    switch (type) {
      case AppTransitionType.fadeSlide:
        return const Duration(milliseconds: 350);
      case AppTransitionType.zoomIn:
        return const Duration(milliseconds: 400);
      case AppTransitionType.slideUp:
        return const Duration(milliseconds: 300);
      case AppTransitionType.slideLeft:
        return const Duration(milliseconds: 300);
      case AppTransitionType.scale:
        return const Duration(milliseconds: 450);
      case AppTransitionType.none:
        return Duration.zero;
    }
  }

  /// Build the transition animation widget
  static Widget _buildTransition(
    AppTransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case AppTransitionType.fadeSlide:
        return _FadeSlideTransition(animation: animation, child: child);

      case AppTransitionType.zoomIn:
        return _ZoomInTransition(animation: animation, child: child);

      case AppTransitionType.slideUp:
        return _SlideUpTransition(animation: animation, child: child);

      case AppTransitionType.slideLeft:
        return _SlideLeftTransition(animation: animation, child: child);

      case AppTransitionType.scale:
        return _ScaleTransition(animation: animation, child: child);

      case AppTransitionType.none:
        return child;
    }
  }
}

/// Fade + slight horizontal slide transition
class _FadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeSlideTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}

/// Zoom in with fade transition - for game entry
class _ZoomInTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ZoomInTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.92,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      ),
    );
  }
}

/// Slide up with fade transition - for modals
class _SlideUpTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _SlideUpTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      ),
    );
  }
}

/// Slide from right transition - for lateral navigation
class _SlideLeftTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _SlideLeftTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}

/// Scale up with fade transition - for dramatic reveals
class _ScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ScaleTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
        child: child,
      ),
    );
  }
}

/// Extension on NavigatorState for convenient transition navigation
extension NavigatorTransitionExtensions on NavigatorState {
  /// Push a page with specified transition type
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    AppTransitionType type = AppTransitionType.fadeSlide,
    RouteSettings? settings,
  }) {
    return push(AppPageRoute<T>(
      page: page,
      transitionType: type,
      settings: settings,
    ));
  }

  /// Push replacement with specified transition type
  Future<T?> pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    AppTransitionType type = AppTransitionType.fadeSlide,
    TO? result,
    RouteSettings? settings,
  }) {
    return pushReplacement(
      AppPageRoute<T>(
        page: page,
        transitionType: type,
        settings: settings,
      ),
      result: result,
    );
  }

  /// Push and remove until with specified transition type
  Future<T?> pushAndRemoveUntilWithTransition<T extends Object?>(
    Widget page,
    RoutePredicate predicate, {
    AppTransitionType type = AppTransitionType.fadeSlide,
    RouteSettings? settings,
  }) {
    return pushAndRemoveUntil(
      AppPageRoute<T>(
        page: page,
        transitionType: type,
        settings: settings,
      ),
      predicate,
    );
  }
}

/// Helper function to create an AppPageRoute
/// Usage: Navigator.of(context).push(appRoute(MyScreen(), type: AppTransitionType.zoomIn))
Route<T> appRoute<T>(
  Widget page, {
  AppTransitionType type = AppTransitionType.fadeSlide,
  RouteSettings? settings,
}) {
  return AppPageRoute<T>(
    page: page,
    transitionType: type,
    settings: settings,
  );
}
