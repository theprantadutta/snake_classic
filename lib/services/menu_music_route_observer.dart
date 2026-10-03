import 'package:flutter/widgets.dart';
import 'package:snake_classic/services/audio_service.dart';

/// Tells [AudioService] whether the screen on top is a menu (menu loop may
/// play) or a gameplay surface (it may not). The run loop itself is driven
/// by the game's music session; this only keeps the menu loop off the board
/// before the first move and out of live Versus matches.
class MenuMusicRouteObserver extends NavigatorObserver {
  MenuMusicRouteObserver(this._audio);

  final AudioService _audio;

  /// GoRoute names of gameplay surfaces.
  static const Set<String> quietRoutes = {'game', 'multiplayerGame'};

  void _apply(Route<dynamic>? top) {
    // Sheets and dialogs sit over a page without changing what it is: a
    // pause sheet over the board is still the board.
    if (top == null || top is PopupRoute) return;
    final name = top.settings.name;
    _audio.setMenuMusicRouteAllowed(!quietRoutes.contains(name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _apply(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _apply(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _apply(newRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _apply(previousRoute);
}
