import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/tuning/game_tuning.dart';
import 'package:snake_classic/utils/logger.dart';

/// Fetches the tuning document. Returns the decoded JSON body, or null on any
/// failure (offline, timeout, server error).
typedef TuningFetcher = Future<Object?> Function();

/// Holds the game tuning the next run will use.
///
/// Three layers, so the game never waits on the network and never breaks
/// because of it:
///   1. the last document fetched from the backend, cached on the device;
///   2. failing that, the built-in defaults ([GameTuning.defaults]), which
///      are exactly how the game played before tuning existed;
///   3. every value clamped to a safe range by [GameTuning.fromValues], so a
///      bad dashboard edit cannot make the game unplayable.
///
/// Values are read at the start of each run ([current]), so a refresh never
/// changes a game in progress.
///
/// Experiment enrolment is device-local and sticky (SharedPreferences): once
/// an install is in a variant, or excluded from a new-players-only
/// experiment, it stays there even if the document is edited, so a player
/// never flips between groups.
class TuningService {
  TuningService._();

  static TuningService instance = TuningService._();

  /// Fresh instance for tests.
  static TuningService createForTest() => TuningService._();

  static const String _kCachedDoc = 'tuning_doc_v1';
  static const String _kEnrolPrefix = 'tuning_exp_';

  /// Stored for an install that saw a new-players-only experiment after it
  /// had already played: it keeps the base values.
  static const String _excluded = '-';

  SharedPreferences? _prefs;
  TuningDocument _doc = TuningDocument.empty;
  GameTuning _current = GameTuning.defaults;
  Map<String, String> _variants = const {};
  Future<void>? _refreshing;

  /// The tuning for the next run.
  GameTuning get current => _current;

  /// Version of the server document in use; 0 = built-in defaults.
  int get version => _doc.version;

  /// Experiment key -> variant name, for every experiment this install is in.
  Map<String, String> get variants => _variants;

  /// `assist_v1:assist,other:b`, or empty. Logged with each run and as a
  /// user property, so results can be split by group in GA4.
  String get variantLabel =>
      (_variants.entries.map((e) => '${e.key}:${e.value}').toList()..sort())
          .join(',');

  /// Loads the cached document and resolves the tuning. Never throws and
  /// never touches the network.
  Future<void> initialize({
    required String installId,
    required int gamesStarted,
    SharedPreferences? prefs,
  }) async {
    try {
      _prefs = prefs ?? await SharedPreferences.getInstance();
      _doc = TuningDocument.tryDecode(_prefs!.getString(_kCachedDoc)) ??
          TuningDocument.empty;
    } catch (e) {
      AppLogger.warning('Tuning cache unreadable, using defaults: $e');
      _doc = TuningDocument.empty;
    }
    _resolve(installId: installId, gamesStarted: gamesStarted);
  }

  /// Fetches the latest document and, if it parsed, caches it and resolves
  /// the tuning again. Any failure keeps what is already in use. Concurrent
  /// calls share one request.
  Future<void> refresh({
    required TuningFetcher fetch,
    required String installId,
    required int gamesStarted,
  }) {
    return _refreshing ??= _doRefresh(fetch, installId, gamesStarted)
        .whenComplete(() => _refreshing = null);
  }

  Future<void> _doRefresh(
      TuningFetcher fetch, String installId, int gamesStarted) async {
    try {
      final body = await fetch();
      if (body is! Map || body['config'] is! Map) return;
      final doc = TuningDocument.parse(body);
      _doc = doc;
      await _prefs?.setString(_kCachedDoc, jsonEncode(body));
      _resolve(installId: installId, gamesStarted: gamesStarted);
    } catch (e) {
      AppLogger.warning('Tuning refresh failed, keeping current: $e');
    }
  }

  void _resolve({required String installId, required int gamesStarted}) {
    final values = <String, Object?>{..._doc.values};
    final variants = <String, String>{};

    for (final experiment in _doc.experiments) {
      if (!experiment.enabled) continue;
      final variant = _variantFor(experiment, installId, gamesStarted);
      if (variant == null) continue;
      variants[experiment.key] = variant.name;
      values.addAll(variant.values);
    }

    _variants = Map.unmodifiable(variants);
    _current = GameTuning.fromValues(values);
  }

  TuningVariant? _variantFor(
      TuningExperiment experiment, String installId, int gamesStarted) {
    final prefs = _prefs;
    final key = '$_kEnrolPrefix${experiment.key}';
    final stored = prefs?.getString(key);

    if (stored == _excluded) return null;
    if (stored != null) {
      // Sticky: the variant this install was first given. If the operator
      // renamed or removed it, fall back to the base values rather than
      // silently re-rolling the player into another group.
      for (final v in experiment.variants) {
        if (v.name == stored) return v;
      }
      return null;
    }

    if (experiment.newPlayersOnly && gamesStarted > 0) {
      unawaited(prefs?.setString(key, _excluded));
      return null;
    }

    final variant = experiment.variantFor(installId);
    if (variant != null) unawaited(prefs?.setString(key, variant.name));
    return variant;
  }
}
