// Snake Classic — Living Board design tokens.
//
// Spec: docs/living-board/design/DESIGN_SPEC.md. [LB] holds the constants
// that never change with the theme (grid, radii, reward/danger colours,
// motion). [LBPalette] holds the colours a GameTheme re-skins; read it with
// `context.lb`.
import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

abstract class LB {
  // Grid
  static const double cell = 20.0; // every layout dimension is a multiple of this
  static const double inset = 1.0; // blocks sit 1 dp inside their cell bounds (2 dp visual gap)
  static const double blockRadius = 6.0;
  static const double snakeCellRadius = 3.0;
  static const double headRadius = 5.0;

  /// Content margin: one cell each side of an 18-column phone frame.
  static const double margin = cell;

  // Core colours (Classic theme; other themes re-skin through LBPalette)
  static const Color board = Color(0xFF08160B);
  static const Color deep = Color(0xFF0C1F0F);
  static const Color lime = Color(0xFFAEDC10);
  static const Color head = Color(0xFFD4F25A);
  static const Color ink = Color(0xFFE9F5C8);
  static const Color splash = Color(0xFF0F380F); // flutter_native_splash window colour — do not change

  // Constant across themes: gold = reward, bonk = danger.
  static const Color gold = Color(0xFFF5C518);
  static const Color goldHead = Color(0xFFFFE27A);
  static const Color bonk = Color(0xFFFF5A4E);
  static const Color goldFill = Color(0x17F5C518);
  static const Color goldStroke = Color(0x80F5C518);
  static const Color bonkFill = Color(0x17FF5A4E);
  static const Color bonkStroke = Color(0x8CFF5A4E);

  // Food
  static const Color apple = Color(0xFFE8433A);
  static const Color appleHighlight = Color(0xFFFF9A8C);
  static const Color foodGlow = Color(0x8CF5C518);

  // Rarity (AchievementRarity)
  static const Color common = Color(0xFF9FB8A0);
  static const Color rare = Color(0xFF4FB8F0);
  static const Color epic = Color(0xFFB47CFF);
  static const Color legendary = Color(0xFFF5C518);
  static const Color diamond = Color(0xFF7FF3FF);

  // Podium
  static const Color first = Color(0xFFF5C518);
  static const Color second = Color(0xFFC9D4C4);
  static const Color third = Color(0xFFD08A4E);

  // Versus
  static const Color rival = Color(0xFFFF5A4E);
  static const Color rivalHead = Color(0xFFFF8A7E);

  // Type — JetBrains Mono everywhere; Noto covers the scripts it lacks.
  static const String font = 'JetBrainsMono';
  static const List<String> fontFallback = <String>[
    'NotoSans',
    'NotoSansDevanagari',
    'NotoSansArabic',
  ];

  // Motion
  static const Duration tap = Duration(milliseconds: 90); // block press: scale 0.97
  static const Duration reveal = Duration(milliseconds: 220); // cells light left→right
  static const Duration revealStagger = Duration(milliseconds: 18);
  static const Duration tapArm = Duration(milliseconds: 600); // TapArmGuard on revive / game-over / ad surfaces
}

/// The theme-dependent half of the Living Board.
///
/// Each GameTheme re-skins the board: board ← theme background darkened 35%,
/// lime ← theme snake colour, head ← snake colour lightened 25%. Classic is
/// pinned to the kit's exact palette. Gold, bonk and rarity stay constant
/// (see [LB]) so rewards and danger read the same on every theme.
@immutable
class LBPalette extends ThemeExtension<LBPalette> {
  const LBPalette({
    required this.board,
    required this.deep,
    required this.lime,
    required this.head,
    required this.ink,
    required this.food,
  });

  final Color board;
  final Color deep;
  final Color lime;
  final Color head;
  final Color ink;
  final Color food;

  static const LBPalette classic = LBPalette(
    board: LB.board,
    deep: LB.deep,
    lime: LB.lime,
    head: LB.head,
    ink: LB.ink,
    food: LB.apple,
  );

  static final Map<GameTheme, LBPalette> _cache = {};

  factory LBPalette.of(GameTheme theme) {
    if (theme == GameTheme.classic) return classic;
    return _cache.putIfAbsent(theme, () {
      final lime = theme.snakeColor;
      final board = Color.lerp(theme.backgroundColor, Colors.black, .35)!;
      return LBPalette(
        board: board,
        deep: Color.lerp(board, lime, .05)!,
        lime: lime,
        head: Color.lerp(lime, Colors.white, .25)!,
        ink: Color.lerp(Colors.white, lime, .12)!,
        food: theme.foodColor,
      );
    });
  }

  // Derived alphas (DESIGN_SPEC palette.json "alpha").
  Color get inkMuted => ink.withValues(alpha: .60);
  Color get inkDim => ink.withValues(alpha: .40);
  Color get gridLine => lime.withValues(alpha: .07);
  Color get blockFill => lime.withValues(alpha: .06);
  Color get blockStroke => lime.withValues(alpha: .32);
  Color get cellOff => lime.withValues(alpha: .13);
  Color get wall => lime.withValues(alpha: .45);

  /// Text on a lime-filled block. Dark board tone keeps contrast on every theme.
  Color get onLime => Color.lerp(board, Colors.black, .4)!;

  @override
  LBPalette copyWith({
    Color? board,
    Color? deep,
    Color? lime,
    Color? head,
    Color? ink,
    Color? food,
  }) =>
      LBPalette(
        board: board ?? this.board,
        deep: deep ?? this.deep,
        lime: lime ?? this.lime,
        head: head ?? this.head,
        ink: ink ?? this.ink,
        food: food ?? this.food,
      );

  @override
  LBPalette lerp(LBPalette? other, double t) {
    if (other == null) return this;
    return LBPalette(
      board: Color.lerp(board, other.board, t)!,
      deep: Color.lerp(deep, other.deep, t)!,
      lime: Color.lerp(lime, other.lime, t)!,
      head: Color.lerp(head, other.head, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      food: Color.lerp(food, other.food, t)!,
    );
  }
}

/// Living Board text styles. Colours default from the palette at the call
/// site; pass one to override.
abstract class LBText {
  static TextStyle label(LBPalette p, {Color? color}) => TextStyle(
        fontFamily: LB.font,
        fontFamilyFallback: LB.fontFallback,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
        color: color ?? p.inkMuted,
      );

  static TextStyle body(LBPalette p, {Color? color, double size = 10.5}) => TextStyle(
        fontFamily: LB.font,
        fontFamilyFallback: LB.fontFallback,
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.45,
        color: color ?? p.inkMuted,
      );

  static TextStyle button(LBPalette p, {Color? color, double size = 12}) => TextStyle(
        fontFamily: LB.font,
        fontFamilyFallback: LB.fontFallback,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: color ?? p.head,
      );

  static TextStyle value(LBPalette p, {Color? color, double size = 20}) => TextStyle(
        fontFamily: LB.font,
        fontFamilyFallback: LB.fontFallback,
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? p.ink,
      );
}

extension LBContext on BuildContext {
  /// The active theme's Living Board palette.
  LBPalette get lb => Theme.of(this).extension<LBPalette>() ?? LBPalette.classic;
}
