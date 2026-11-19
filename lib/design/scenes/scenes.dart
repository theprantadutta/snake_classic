// Registers every theme scene. Each theme's art lives in its own file here.
import 'package:snake_classic/design/scenes/crystal.dart';
import 'package:snake_classic/design/scenes/cyberpunk.dart';
import 'package:snake_classic/design/scenes/miami_nights.dart';
import 'package:snake_classic/design/scenes/neon.dart';
import 'package:snake_classic/design/scenes/space.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

export 'theme_scene.dart';

bool _registered = false;

void registerThemeScenes() {
  if (_registered) return;
  _registered = true;
  ThemeScenes.register(GameTheme.miamiNights, const MiamiNightsThemeScene());
  ThemeScenes.register(GameTheme.neon, const NeonThemeScene());
  ThemeScenes.register(GameTheme.cyberpunk, const CyberpunkThemeScene());
  ThemeScenes.register(GameTheme.space, const SpaceThemeScene());
  ThemeScenes.register(GameTheme.crystal, const CrystalThemeScene());
}
