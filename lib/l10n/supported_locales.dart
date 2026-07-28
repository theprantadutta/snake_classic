import 'dart:ui';

/// The app's launch locales. Order = display order in the settings picker.
///
/// Endonyms (each language's own name for itself) are deliberately NOT in
/// the ARB files: "Français" reads as "Français" to everyone, which is
/// exactly what a user hunting for their language needs.
class SupportedLocales {
  SupportedLocales._();

  static const List<Locale> locales = [
    Locale('en'),
    Locale('hi'),
    Locale('pt'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('pl'),
    Locale('ar'),
    Locale('it'),
  ];

  static const Map<String, String> endonyms = {
    'en': 'English',
    'hi': 'हिन्दी',
    'pt': 'Português',
    'es': 'Español',
    'fr': 'Français',
    'ru': 'Русский',
    'pl': 'Polski',
    'ar': 'العربية',
    'it': 'Italiano',
  };

  /// Resolve a stored language tag to a Locale, or null for "follow the
  /// device" (also the fallback for an unknown/stale stored tag).
  static Locale? fromCode(String? code) {
    if (code == null) return null;
    for (final locale in locales) {
      if (locale.languageCode == code) return locale;
    }
    return null;
  }
}
