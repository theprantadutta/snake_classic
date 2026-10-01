import 'package:flutter/material.dart';

/// Game typography: JetBrains Mono everywhere (Living Board — one grid, one
/// font). Bundled in assets/fonts/, declared in pubspec.yaml's `fonts:`.
///
/// Sizes sit a step below the old Orbitron/Rajdhani scale: a monospace face
/// is far wider than Rajdhani, and these styles still back screens that
/// were laid out for it. New Living Board UI uses [LBText] instead.
abstract class GameTypography {
  // Font family names
  static const String headlineFont = 'JetBrainsMono';
  static const String bodyFont = 'JetBrainsMono';

  /// Per-script fallbacks for the scripts JetBrains Mono doesn't cover.
  ///
  /// JetBrains Mono carries Latin, Latin Extended (pl) and Cyrillic (ru) but
  /// no Devanagari or Arabic. Without these the engine substitutes whatever
  /// the OS happens to have, which varies by device. Flutter walks this list
  /// per missing glyph, so Latin text still renders in JetBrains Mono and
  /// only the uncovered glyphs come from Noto.
  ///
  /// Families are declared in pubspec.yaml's `fonts:` section.
  static const List<String> scriptFallback = <String>[
    'NotoSans', // Cyrillic (ru) + Latin Extended-A (pl)
    'NotoSansDevanagari', // hi
    'NotoSansArabic', // ar
  ];

  /// Scripts where inter-glyph spacing damages the writing system.
  ///
  /// Latin and Cyrillic are alphabetic — prising the letters apart is a
  /// legitimate display effect, and the game's look leans on it. Devanagari
  /// and Arabic are not: Devanagari letters form conjunct clusters sitting
  /// under one shirorekha, and Arabic is cursive with letters joined along a
  /// baseline. Adding space between their glyphs doesn't look "tracked out",
  /// it looks like the word has been broken in half — Hindi "खेलें" renders
  /// as "खे लें".
  ///
  /// Returns 0 for those scripts — identical to leaving `letterSpacing`
  /// unset, but expressible. (It can't return null: `TextStyle.copyWith`
  /// treats a null argument as "leave unchanged", so a null here would
  /// silently keep the Latin spacing on the themed styles below.)
  static double letterSpacingFor(Locale locale, double value) =>
      switch (locale.languageCode) {
        'hi' || 'ar' => 0,
        _ => value,
      };

  static TextStyle _withScriptFallback(TextStyle style) =>
      style.copyWith(fontFamily: bodyFont, fontFamilyFallback: scriptFallback);

  // === Display Styles (Large headlines) ===

  /// Extra large display text
  /// Use for: Main titles, splash screens
  static TextStyle displayLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: color,
        ),
      );

  /// Large display text
  /// Use for: Screen titles, important headers
  static TextStyle displayMedium({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: color,
        ),
      );

  /// Small display text
  /// Use for: Section headers
  static TextStyle displaySmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: color,
        ),
      );

  // === Headline Styles ===

  /// Large headline
  /// Use for: Page titles, major section headers
  static TextStyle headlineLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: color,
        ),
      );

  /// Medium headline
  /// Use for: Card titles, dialog headers
  static TextStyle headlineMedium({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          color: color,
        ),
      );

  /// Small headline
  /// Use for: Subsection headers
  static TextStyle headlineSmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: color,
        ),
      );

  // === Title Styles ===

  /// Large title
  /// Use for: List item titles, prominent labels
  static TextStyle titleLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      );

  /// Medium title
  /// Use for: Card content titles
  static TextStyle titleMedium({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      );

  /// Small title
  /// Use for: Small card titles, list headers
  static TextStyle titleSmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      );

  // === Body Styles ===

  /// Large body text
  /// Use for: Primary content, descriptions
  static TextStyle bodyLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: color,
        ),
      );

  /// Medium body text
  /// Use for: Secondary content, details
  static TextStyle bodyMedium({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: color,
        ),
      );

  /// Small body text
  /// Use for: Captions, helper text
  static TextStyle bodySmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          height: 1.3,
          color: color,
        ),
      );

  // === Label Styles ===

  /// Large label
  /// Use for: Button text, prominent labels
  static TextStyle labelLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: color,
        ),
      );

  /// Medium label
  /// Use for: Chip text, tags
  static TextStyle labelMedium({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: color,
        ),
      );

  /// Small label
  /// Use for: Badges, small indicators
  static TextStyle labelSmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: color,
        ),
      );

  // === Special Game Styles ===

  /// Score display
  /// Use for: In-game score, high scores
  static TextStyle scoreDisplay({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: color,
        ),
      );

  /// Large score display
  /// Use for: Game over score, leaderboard top scores
  static TextStyle scoreLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: color,
        ),
      );

  /// Small score display
  /// Use for: Mini scores, stats
  static TextStyle scoreSmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      );

  /// Button text
  /// Use for: Primary buttons, CTAs
  static TextStyle buttonLarge({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: color,
        ),
      );

  /// Small button text
  /// Use for: Secondary buttons, small actions
  static TextStyle buttonMedium({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: color,
        ),
      );

  /// Tiny button text
  /// Use for: Compact buttons, icon buttons with labels
  static TextStyle buttonSmall({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: color,
        ),
      );

  /// Game title style
  /// Use for: "SNAKE CLASSIC" title, brand text
  static TextStyle gameTitle({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
          color: color,
        ),
      );

  /// Level indicator
  /// Use for: Level numbers, tier indicators
  static TextStyle levelIndicator({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      );

  /// Stats value
  /// Use for: Statistics numbers, counts
  static TextStyle statsValue({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      );

  /// Stats label
  /// Use for: Statistics labels
  static TextStyle statsLabel({Color? color}) => _withScriptFallback(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          color: color,
        ),
      );

  // === Helper to create TextTheme ===

  /// Creates a complete TextTheme using game typography.
  ///
  /// Pass [locale] so scripts that can't take letter spacing get it stripped
  /// (see [letterSpacingFor]); omitting it keeps the Latin spacing.
  static TextTheme createTextTheme({Color? color, Locale? locale}) {
    TextStyle fix(TextStyle s) => locale == null || s.letterSpacing == null
        ? s
        : s.copyWith(letterSpacing: letterSpacingFor(locale, s.letterSpacing!));

    return TextTheme(
      displayLarge: fix(displayLarge(color: color)),
      displayMedium: fix(displayMedium(color: color)),
      displaySmall: fix(displaySmall(color: color)),
      headlineLarge: fix(headlineLarge(color: color)),
      headlineMedium: fix(headlineMedium(color: color)),
      headlineSmall: fix(headlineSmall(color: color)),
      titleLarge: fix(titleLarge(color: color)),
      titleMedium: fix(titleMedium(color: color)),
      titleSmall: fix(titleSmall(color: color)),
      bodyLarge: fix(bodyLarge(color: color)),
      bodyMedium: fix(bodyMedium(color: color)),
      bodySmall: fix(bodySmall(color: color)),
      labelLarge: fix(labelLarge(color: color)),
      labelMedium: fix(labelMedium(color: color)),
      labelSmall: fix(labelSmall(color: color)),
    );
  }
}

/// Script-aware letter spacing at the widget layer.
///
/// The app builds most of its text styles inline rather than from the theme,
/// so a themed fix alone would miss them. Wrap every literal spacing value in
/// this: `letterSpacing: context.letterSpacing(2)`.
///
/// Follows the same BuildContext-extension idiom as `context.uiScale` and
/// `context.formatInt` — see lib/utils/responsive.dart.
extension TypographyX on BuildContext {
  /// The tracking to actually apply here, given the active language.
  double letterSpacing(double value) =>
      GameTypography.letterSpacingFor(Localizations.localeOf(this), value);
}
