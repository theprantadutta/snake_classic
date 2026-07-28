// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'ЯЗЫК';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languageSystemDefaultSubtitle => 'Использовать язык устройства';
}
