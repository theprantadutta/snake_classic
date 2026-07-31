import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware number/date formatting helpers.
///
/// Always format through these (or the [FormatX] context extension) instead
/// of hand-rolling separators — hardcoded ',' / '$' / 'M/D/Y' shapes are
/// wrong for most of our 9 locales. Date symbols for every supported locale
/// are initialized once in main.dart via initializeDateFormatting.
class AppFormats {
  AppFormats._();

  static String _tag(Locale locale) => Intl.canonicalizedLocale(
        locale.countryCode == null || locale.countryCode!.isEmpty
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}',
      );

  /// 1234567 -> "1,234,567" / "1 234 567" / "12,34,567" depending on locale.
  static String decimal(num n, Locale locale) =>
      NumberFormat.decimalPattern(_tag(locale)).format(n);

  /// 1234 -> "1.2K" (en) / "1,2 тыс." (ru) etc.
  static String compact(num n, Locale locale) =>
      NumberFormat.compact(locale: _tag(locale)).format(n);

  /// Takes a 0..1 fraction: 0.42 -> "42%" (en) / "42 %" (fr) / "٤٢٪" (ar).
  static String percent(double fraction, Locale locale) =>
      NumberFormat.percentPattern(_tag(locale)).format(fraction);

  /// USD fallback price when the store SDK hasn't supplied a localized one.
  static String usd(double amount, Locale locale) =>
      NumberFormat.simpleCurrency(locale: _tag(locale), name: 'USD')
          .format(amount);

  /// 2026-07-30 -> "7/30/2026" (en) / "30/07/2026" (fr) / "30.07.2026" (ru).
  static String date(DateTime d, Locale locale) =>
      DateFormat.yMd(_tag(locale)).format(d);

  /// Month + day, no year: "Jul 30" / "30 juil." — used for renewal dates.
  static String monthDay(DateTime d, Locale locale) =>
      DateFormat.MMMd(_tag(locale)).format(d);

  /// Abbreviated weekday: "Wed" / "mer." / "ср".
  static String weekdayShort(DateTime d, Locale locale) =>
      DateFormat.E(_tag(locale)).format(d);

  /// Localizes the English weekday abbreviations the statistics service
  /// uses as map keys ('Sun'..'Sat'). Unknown input falls through.
  static String weekdayShortFromEn(String en, Locale locale) {
    const anchors = {
      // 2026-07-05 was a Sunday; add offsets for a stable reference week.
      'Sun': 0, 'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6,
    };
    final offset = anchors[en];
    if (offset == null) return en;
    return weekdayShort(DateTime(2026, 7, 5 + offset), locale);
  }

  /// Tournament-style date range. Same day collapses to a single date.
  static String dateRange(DateTime start, DateTime end, Locale locale) {
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (sameDay) return date(start, locale);
    return '${date(start, locale)} – ${date(end, locale)}';
  }
}

/// Context sugar mirroring the lib/utils/responsive.dart extension style.
extension FormatX on BuildContext {
  Locale get _locale => Localizations.localeOf(this);

  String formatInt(num n) => AppFormats.decimal(n, _locale);
  String formatCompact(num n) => AppFormats.compact(n, _locale);
  String formatPercent(double fraction) => AppFormats.percent(fraction, _locale);
  String formatDate(DateTime d) => AppFormats.date(d, _locale);
  String formatMonthDay(DateTime d) => AppFormats.monthDay(d, _locale);
  String formatDateRange(DateTime start, DateTime end) =>
      AppFormats.dateRange(start, end, _locale);
  String formatUsd(double amount) => AppFormats.usd(amount, _locale);
}
