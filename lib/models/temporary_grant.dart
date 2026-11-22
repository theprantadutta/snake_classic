import 'dart:convert';

import 'package:snake_classic/utils/constants.dart';

/// What a [TemporaryGrant] unlocks.
enum TemporaryGrantKind { theme, skin, trail, xpBoost }

/// Where a [TemporaryGrant] came from.
enum TemporaryGrantSource {
  /// Day 5 (2x Season XP) and day 7 (premium theme for a day) of the daily
  /// login bonus.
  dailyBonus,

  /// "Try it for a day": two rewarded ads watched in the store.
  adTrial,
}

/// Something the player has until [expiresAt], and then not.
///
/// Temporary grants are DEVICE-LOCAL by design and never touch the owned
/// sets in PremiumState, the UnlockedItems table or the sync outbox: a
/// grant that reached the backend would come back as permanent ownership.
/// They live in SharedPreferences (CLAUDE.md: device-only state that never
/// travels), see TemporaryGrantsService.
class TemporaryGrant {
  const TemporaryGrant({
    required this.kind,
    required this.id,
    required this.expiresAt,
    required this.source,
    this.previousId,
  });

  final TemporaryGrantKind kind;

  /// Skin id (`golden`), trail id (`trail_glow`), theme enum identifier
  /// ([themeGrantId]) or [xpBoostId].
  final String id;
  final DateTime expiresAt;
  final TemporaryGrantSource source;

  /// What was equipped when the grant equipped itself. Restored on expiry
  /// if the player still has it; otherwise the default is.
  final String? previousId;

  /// The only XP boost there is: Season (battle pass) XP doubled.
  static const String xpBoostId = 'season_xp_2x';

  /// How long every grant lasts.
  static const Duration duration = Duration(hours: 24);

  /// Stable id for a theme. `GameTheme.name` is overridden with the display
  /// name ("Crystal"), so use the enum identifier ("crystal") instead.
  static String themeGrantId(GameTheme theme) => EnumName(theme).name;

  static GameTheme? themeFromGrantId(String id) {
    for (final t in GameTheme.values) {
      if (EnumName(t).name == id) return t;
    }
    return null;
  }

  static String keyFor(TemporaryGrantKind kind, String id) =>
      '${kind.name}:$id';

  String get key => keyFor(kind, id);

  bool get isCosmetic => kind != TemporaryGrantKind.xpBoost;

  bool isActiveAt(DateTime now) => now.isBefore(expiresAt);

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'id': id,
    'expires_at': expiresAt.toUtc().toIso8601String(),
    'source': source.name,
    if (previousId != null) 'previous_id': previousId,
  };

  /// Null for anything malformed or from an unknown future kind, so a bad
  /// row is dropped instead of breaking the whole ledger.
  static TemporaryGrant? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final kind = TemporaryGrantKind.values
        .where((k) => k.name == raw['kind'])
        .firstOrNull;
    final source = TemporaryGrantSource.values
        .where((s) => s.name == raw['source'])
        .firstOrNull;
    final id = raw['id'];
    final expires = raw['expires_at'] is String
        ? DateTime.tryParse(raw['expires_at'] as String)
        : null;
    if (kind == null || source == null || id is! String || id.isEmpty) {
      return null;
    }
    if (expires == null) return null;
    final previous = raw['previous_id'];
    return TemporaryGrant(
      kind: kind,
      id: id,
      expiresAt: expires,
      source: source,
      previousId: previous is String ? previous : null,
    );
  }

  @override
  String toString() => 'TemporaryGrant($key, ${source.name}, until $expiresAt)';
}

/// An immutable set of [TemporaryGrant]s, at most one per [TemporaryGrant.key].
/// All of the expiry rules live here so they can be tested without a clock
/// or storage.
class TemporaryGrantLedger {
  const TemporaryGrantLedger([this.grants = const []]);

  static const TemporaryGrantLedger empty = TemporaryGrantLedger();

  final List<TemporaryGrant> grants;

  bool get isEmpty => grants.isEmpty;

  TemporaryGrant? find(TemporaryGrantKind kind, String id) {
    final key = TemporaryGrant.keyFor(kind, id);
    return grants.where((g) => g.key == key).firstOrNull;
  }

  bool isActive(TemporaryGrantKind kind, String id, DateTime now) =>
      find(kind, id)?.isActiveAt(now) ?? false;

  /// Adds [grant], replacing any grant with the same key. A grant never
  /// shortens one already running (claiming the XP boost again while it is
  /// on extends it, it does not cut it), and the original [previousId] is
  /// kept so expiry still restores what the player had before the first.
  TemporaryGrantLedger upsert(TemporaryGrant grant) {
    final existing = find(grant.kind, grant.id);
    var next = grant;
    if (existing != null) {
      next = TemporaryGrant(
        kind: grant.kind,
        id: grant.id,
        source: grant.source,
        expiresAt: existing.expiresAt.isAfter(grant.expiresAt)
            ? existing.expiresAt
            : grant.expiresAt,
        previousId: existing.previousId ?? grant.previousId,
      );
    }
    return TemporaryGrantLedger([
      for (final g in grants)
        if (g.key != grant.key) g,
      next,
    ]);
  }

  /// Splits the ledger at [now]: what is still running, and what ran out.
  ({TemporaryGrantLedger active, List<TemporaryGrant> expired}) prune(
    DateTime now,
  ) {
    final active = <TemporaryGrant>[];
    final expired = <TemporaryGrant>[];
    for (final g in grants) {
      (g.isActiveAt(now) ? active : expired).add(g);
    }
    return (active: TemporaryGrantLedger(active), expired: expired);
  }

  /// The earliest expiry, to arm one timer for.
  DateTime? get nextExpiry {
    DateTime? next;
    for (final g in grants) {
      if (next == null || g.expiresAt.isBefore(next)) next = g.expiresAt;
    }
    return next;
  }

  /// Season XP multiplier at [now]: 2 while the daily-bonus XP boost runs.
  int seasonXpMultiplier(DateTime now) =>
      isActive(TemporaryGrantKind.xpBoost, TemporaryGrant.xpBoostId, now)
      ? 2
      : 1;

  /// The ad trial running at [now], if any. One at a time.
  TemporaryGrant? activeAdTrial(DateTime now) => grants
      .where(
        (g) => g.source == TemporaryGrantSource.adTrial && g.isActiveAt(now),
      )
      .firstOrNull;

  /// Active cosmetic grants as `key -> expiry`, the shape PremiumState holds.
  Map<String, DateTime> cosmeticUnlocks(DateTime now) => {
    for (final g in grants)
      if (g.isCosmetic && g.isActiveAt(now)) g.key: g.expiresAt,
  };

  String encode() => jsonEncode([for (final g in grants) g.toJson()]);

  static TemporaryGrantLedger decode(String? raw) {
    if (raw == null || raw.isEmpty) return empty;
    try {
      final list = jsonDecode(raw);
      if (list is! List) return empty;
      var ledger = empty;
      for (final item in list) {
        final g = TemporaryGrant.tryParse(item);
        if (g != null) ledger = ledger.upsert(g);
      }
      return ledger;
    } catch (_) {
      return empty;
    }
  }
}

/// How far a player is through "watch 2 ads, wear it for a day". Progress
/// is for ONE item on ONE local day: watching an ad for another item, or on
/// another day, starts again from zero.
class CosmeticTrialProgress {
  const CosmeticTrialProgress({
    required this.key,
    required this.adsWatched,
    required this.day,
  });

  /// Ads needed for a trial.
  static const int adsRequired = 2;

  /// [TemporaryGrant.keyFor] of the item.
  final String key;
  final int adsWatched;

  /// Local calendar day, `yyyy-mm-dd`.
  final String day;

  static String dayOf(DateTime now) {
    final d = now.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  /// Ads already watched for [itemKey] today.
  static int watchedFor(
    CosmeticTrialProgress? progress,
    String itemKey,
    DateTime now,
  ) {
    if (progress == null) return 0;
    if (progress.key != itemKey || progress.day != dayOf(now)) return 0;
    return progress.adsWatched;
  }

  /// Progress after one more completed ad for [itemKey].
  static CosmeticTrialProgress afterAd(
    CosmeticTrialProgress? progress,
    String itemKey,
    DateTime now,
  ) => CosmeticTrialProgress(
    key: itemKey,
    adsWatched: watchedFor(progress, itemKey, now) + 1,
    day: dayOf(now),
  );

  String encode() =>
      jsonEncode({'key': key, 'ads_watched': adsWatched, 'day': day});

  static CosmeticTrialProgress? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw);
      if (m is! Map) return null;
      final key = m['key'];
      final watched = m['ads_watched'];
      final day = m['day'];
      if (key is! String || watched is! int || day is! String) return null;
      return CosmeticTrialProgress(key: key, adsWatched: watched, day: day);
    } catch (_) {
      return null;
    }
  }
}
