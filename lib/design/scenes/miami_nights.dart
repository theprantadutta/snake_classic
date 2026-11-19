import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/miami_nights_scene.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Miami Nights on the scene framework (the art lives in MiamiNightsScene).
class MiamiNightsThemeScene extends ThemeScene {
  const MiamiNightsThemeScene();

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) => menu
      ? MiamiNightsScene.paint(canvas, size,
          dim: .5, lines: .4, sun: .55, horizonVeil: .45)
      : MiamiNightsScene.paint(canvas, size, dim: .38, animatedFloor: true);

  @override
  bool get hasMotion => true;

  @override
  void paintMotion(Canvas canvas, Size size, double seconds) =>
      MiamiNightsScene.paintFloorMotion(canvas, size, seconds, dim: .38);

  @override
  Color get cardBase => const Color(0xB8180629);

  @override
  Color get headerBand => const Color(0xFF1F0A33);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF4FA3), Color(0xFFFF7A59), Color(0xFFFFB347)],
        stops: [0.0, 0.7, 1.0],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [
          GameConstants.miamiNightsSnake,
          GameConstants.miamiNightsAccent,
        ],
        edge: GameConstants.miamiNightsFood,
        shine: .22,
        tailFade: .25,
      );

  @override
  Color get foodRing => GameConstants.miamiNightsFood;
}
