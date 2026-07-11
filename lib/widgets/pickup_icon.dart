import 'package:flutter/material.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/power_up.dart';

/// Small square icon of a board pickup, rendered from the same generated
/// sprite art the board draws — so the HUD chips, power-up rings and the
/// pause-menu guide show exactly what the player sees on the playfield.
///
/// Falls back to the legacy emoji if the asset can't load, mirroring the
/// board painter's procedural fallback.
class PickupIcon extends StatelessWidget {
  PickupIcon.food(FoodType type, {super.key, required this.size})
      : assetPath = type.spriteAsset,
        fallbackEmoji = type.emoji;

  PickupIcon.powerUp(PowerUpType type, {super.key, required this.size})
      : assetPath = type.spriteAsset,
        fallbackEmoji = type.icon;

  final String assetPath;
  final String fallbackEmoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Text(
        fallbackEmoji,
        style: TextStyle(fontSize: size * 0.85, height: 1.0),
      ),
    );
  }
}
