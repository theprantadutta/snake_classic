// Registers every theme scene. Each theme's art lives in its own file here.
import 'package:snake_classic/design/scenes/desert.dart';
import 'package:snake_classic/design/scenes/forest.dart';
import 'package:snake_classic/design/scenes/miami_nights.dart';
import 'package:snake_classic/design/scenes/ocean.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

export 'theme_scene.dart';

bool _registered = false;

void registerThemeScenes() {
  if (_registered) return;
  _registered = true;
  ThemeScenes.register(GameTheme.miamiNights, const MiamiNightsThemeScene());
  ThemeScenes.register(GameTheme.ocean, const OceanThemeScene());
  ThemeScenes.register(GameTheme.forest, const ForestThemeScene());
  ThemeScenes.register(GameTheme.desert, const DesertThemeScene());
}
