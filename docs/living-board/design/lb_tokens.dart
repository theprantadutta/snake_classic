// Snake Classic — Living Board design tokens.
// Drop into lib/design/ (or merge into lib/utils/constants.dart). Pure data, no widgets.
import 'package:flutter/material.dart';

abstract class LB {
  // Grid
  static const double cell = 20.0;          // every layout dimension is a multiple of this
  static const double inset = 1.0;          // blocks sit 1px inside their cell bounds (2px visual gap)
  static const double blockRadius = 6.0;
  static const double snakeCellRadius = 3.0;
  static const double headRadius = 5.0;

  // Core colors
  static const Color board = Color(0xFF08160B);
  static const Color deep = Color(0xFF0C1F0F);
  static const Color lime = Color(0xFFAEDC10);
  static const Color head = Color(0xFFD4F25A);
  static const Color gold = Color(0xFFF5C518);
  static const Color bonk = Color(0xFFFF5A4E);
  static const Color ink = Color(0xFFE9F5C8);
  static const Color splash = Color(0xFF0F380F); // flutter_native_splash window colour — do not change

  // Alphas
  static const Color inkMuted = Color(0x99E9F5C8);   // 60%
  static const Color inkDim = Color(0x66E9F5C8);     // 40%
  static const Color gridLine = Color(0x12AEDC10);   // 7%
  static const Color blockFill = Color(0x0FAEDC10);  // 6%
  static const Color blockStroke = Color(0x52AEDC10);// 32%
  static const Color cellOff = Color(0x21AEDC10);    // 13%
  static const Color wall = Color(0x73AEDC10);       // 45%
  static const Color goldFill = Color(0x17F5C518);
  static const Color goldStroke = Color(0x80F5C518);
  static const Color bonkFill = Color(0x17FF5A4E);
  static const Color bonkStroke = Color(0x8CFF5A4E);

  // Food
  static const Color apple = Color(0xFFE8433A);
  static const Color appleHighlight = Color(0xFFFF9A8C);

  // Rarity (AchievementRarity)
  static const Color common = Color(0xFF9FB8A0);
  static const Color rare = Color(0xFF4FB8F0);
  static const Color epic = Color(0xFFB47CFF);
  static const Color legendary = Color(0xFFF5C518);
  static const Color diamond = Color(0xFF7FF3FF);

  // Versus
  static const Color rival = Color(0xFFFF5A4E);
  static const Color rivalHead = Color(0xFFFF8A7E);

  // Type — JetBrains Mono everywhere (assets/fonts/JetBrainsMono-*.ttf, OFL)
  static const String font = 'JetBrainsMono';
  static const TextStyle label = TextStyle(fontFamily: font, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2.2, color: inkMuted);
  static const TextStyle body = TextStyle(fontFamily: font, fontSize: 10.5, fontWeight: FontWeight.w500, letterSpacing: 0.2, color: inkMuted);
  static const TextStyle button = TextStyle(fontFamily: font, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: head);
  static const TextStyle value = TextStyle(fontFamily: font, fontSize: 20, fontWeight: FontWeight.w800, color: ink);

  // Motion
  static const Duration tap = Duration(milliseconds: 90);      // block press: scale 0.97 + fill flash
  static const Duration reveal = Duration(milliseconds: 220);  // cells light up left→right, 18ms stagger
  static const Duration tapArm = Duration(milliseconds: 600);  // TapArmGuard on revive / game-over / ad surfaces
}

/// Re-skins the Living Board for each of the 10 existing GameThemes.
/// Gold, bonk and rarity stay constant so rewards and danger always read the same.
class LBThemeTokens {
  final Color board, lime, head, food;
  const LBThemeTokens(this.board, this.lime, this.head, this.food);

  // factory LBThemeTokens.of(GameTheme t) => LBThemeTokens(
  //   Color.lerp(t.backgroundColor, Colors.black, .35)!,
  //   t.snakeColor,
  //   Color.lerp(t.snakeColor, Colors.white, .25)!,
  //   t.foodColor,
  // );
}
