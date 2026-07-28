// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'LINGUA';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

  @override
  String get languageSystemDefaultSubtitle => 'Segui la lingua del dispositivo';
}
