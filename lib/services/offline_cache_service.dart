import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache entry with metadata for TTL management
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  CacheEntry({required this.data, required this.cachedAt, required this.ttl});

  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));

  Duration get remainingTtl {
    final expiresAt = cachedAt.add(ttl);
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Map<String, dynamic> toJson(Object Function(T) dataEncoder) => {
    'data': dataEncoder(data),
    'cachedAt': cachedAt.toIso8601String(),
    'ttlMillis': ttl.inMilliseconds,
  };

  static CacheEntry<T>? fromJson<T>(
    Map<String, dynamic> json,
    T Function(Object) dataDecoder,
  ) {
    try {
      return CacheEntry<T>(
        data: dataDecoder(json['data']),
        cachedAt: DateTime.parse(json['cachedAt']),
        ttl: Duration(milliseconds: json['ttlMillis']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to parse cache entry: $e');
      }
      return null;
    }
  }
}

/// Centralized cache management service with TTL-based freshness
class OfflineCacheService extends ChangeNotifier {
  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  SharedPreferences? _prefs;
  static const String _cachePrefix = 'cache_';
  static const String _cacheMetaPrefix = 'cache_meta_';

  /// Cache configurations with TTL for each data type
  static const Map<String, Duration> cacheConfigs = {
    // Leaderboards - shorter TTL as they change frequently
    'leaderboard_global': Duration(minutes: 5),
    'leaderboard_weekly': Duration(minutes: 5),
    'leaderboard_daily': Duration(minutes: 2),
    'leaderboard_friends': Duration(minutes: 3),

    // Tournaments - moderate TTL
    'tournaments_active': Duration(minutes: 10),
    'tournaments_upcoming': Duration(minutes: 15),
    'tournament_details': Duration(minutes: 5),

    // Social - moderate TTL
    'friends_list': Duration(minutes: 5),
    'friend_requests': Duration(minutes: 3),

    // Static/semi-static data - longer TTL
    'achievements_metadata': Duration(hours: 24),
    'user_achievements': Duration(minutes: 1),
    'battle_pass_progress': Duration(minutes: 5),
    'shop_items': Duration(hours: 1),

    // User data - short TTL for freshness
    'user_profile': Duration(minutes: 2),
    'user_statistics': Duration(minutes: 1),
  };

  /// Initialize the cache service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Clean expired cache entries on startup
    await _cleanExpiredCache();

    if (kDebugMode) {
      print('OfflineCacheService initialized');
    }
  }

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get cached data if available and not expired
  Future<T?> getCached<T>(String key, T Function(Object) decoder) async {
    await _ensureInitialized();

    final metaKey = '$_cacheMetaPrefix$key';
    final dataKey = '$_cachePrefix$key';

    final metaJson = _prefs?.getString(metaKey);
    final dataJson = _prefs?.getString(dataKey);

    if (metaJson == null || dataJson == null) {
      return null;
    }

    try {
      final meta = json.decode(metaJson) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(meta['cachedAt']);
      final ttlMillis = meta['ttlMillis'] as int;
      final ttl = Duration(milliseconds: ttlMillis);

      // Check if expired
      if (DateTime.now().isAfter(cachedAt.add(ttl))) {
        if (kDebugMode) {
          print('Cache expired for key: $key');
        }
        return null;
      }

      final data = json.decode(dataJson);
      return decoder(data);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get cache for $key: $e');
      }
      return null;
    }
  }

  /// Get cached data even if expired (for offline fallback)
  Future<T?> getCachedFallback<T>(
    String key,
    T Function(Object) decoder,
  ) async {
    await _ensureInitialized();

    final dataKey = '$_cachePrefix$key';
    final dataJson = _prefs?.getString(dataKey);

    if (dataJson == null) {
      return null;
    }

    try {
      final data = json.decode(dataJson);
      return decoder(data);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get fallback cache for $key: $e');
      }
      return null;
    }
  }

  /// Store data in cache with TTL
  Future<void> setCache<T>(
    String key,
    T data,
    Object Function(T) encoder, {
    Duration? customTtl,
  }) async {
    await _ensureInitialized();

    final ttl = customTtl ?? cacheConfigs[key] ?? const Duration(minutes: 5);
    final now = DateTime.now();

    final metaKey = '$_cacheMetaPrefix$key';
    final dataKey = '$_cachePrefix$key';

    final meta = {
      'cachedAt': now.toIso8601String(),
      'ttlMillis': ttl.inMilliseconds,
    };

    try {
      final encodedData = encoder(data);
      await _prefs?.setString(metaKey, json.encode(meta));
      await _prefs?.setString(dataKey, json.encode(encodedData));

      if (kDebugMode) {
        print('Cached data for key: $key (TTL: ${ttl.inMinutes}min)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cache data for $key: $e');
      }
    }
  }

  /// Check if cache is fresh (not expired)
  Future<bool> isCacheFresh(String key) async {
    await _ensureInitialized();

    final metaKey = '$_cacheMetaPrefix$key';
    final metaJson = _prefs?.getString(metaKey);

    if (metaJson == null) {
      return false;
    }

    try {
      final meta = json.decode(metaJson) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(meta['cachedAt']);
      final ttlMillis = meta['ttlMillis'] as int;
      final ttl = Duration(milliseconds: ttlMillis);

      return DateTime.now().isBefore(cachedAt.add(ttl));
    } catch (e) {
      return false;
    }
  }

  /// Check if any cached data exists (regardless of freshness)
  Future<bool> hasCachedData(String key) async {
    await _ensureInitialized();
    final dataKey = '$_cachePrefix$key';
    return _prefs?.getString(dataKey) != null;
  }

  /// Get cache metadata (for debugging/status display)
  Future<Map<String, dynamic>?> getCacheInfo(String key) async {
    await _ensureInitialized();

    final metaKey = '$_cacheMetaPrefix$key';
    final metaJson = _prefs?.getString(metaKey);

    if (metaJson == null) {
      return null;
    }

    try {
      final meta = json.decode(metaJson) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(meta['cachedAt']);
      final ttlMillis = meta['ttlMillis'] as int;
      final ttl = Duration(milliseconds: ttlMillis);
      final expiresAt = cachedAt.add(ttl);
      final isExpired = DateTime.now().isAfter(expiresAt);

      return {
        'cachedAt': cachedAt,
        'ttl': ttl,
        'expiresAt': expiresAt,
        'isExpired': isExpired,
        'remainingSeconds': isExpired
            ? 0
            : expiresAt.difference(DateTime.now()).inSeconds,
      };
    } catch (e) {
      return null;
    }
  }

  /// Invalidate specific cache entry
  Future<void> invalidateCache(String key) async {
    await _ensureInitialized();

    final metaKey = '$_cacheMetaPrefix$key';
    final dataKey = '$_cachePrefix$key';

    await _prefs?.remove(metaKey);
    await _prefs?.remove(dataKey);

    if (kDebugMode) {
      print('Invalidated cache for key: $key');
    }
  }

  /// Invalidate all cache entries matching a pattern
  Future<void> invalidateCachePattern(String pattern) async {
    await _ensureInitialized();

    final keys = _prefs?.getKeys() ?? <String>{};
    final keysToRemove = keys
        .where((k) => k.startsWith(_cachePrefix) && k.contains(pattern))
        .toList();

    for (final key in keysToRemove) {
      await _prefs?.remove(key);
      // Also remove meta key
      final metaKey = key.replaceFirst(_cachePrefix, _cacheMetaPrefix);
      await _prefs?.remove(metaKey);
    }

    if (kDebugMode) {
      print(
        'Invalidated ${keysToRemove.length} cache entries matching: $pattern',
      );
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _ensureInitialized();

    final keys = _prefs?.getKeys() ?? <String>{};
    final cacheKeys = keys
        .where(
          (k) => k.startsWith(_cachePrefix) || k.startsWith(_cacheMetaPrefix),
        )
        .toList();

    for (final key in cacheKeys) {
      await _prefs?.remove(key);
    }

    if (kDebugMode) {
      print('Cleared all cache (${cacheKeys.length} entries)');
    }

    notifyListeners();
  }

  /// Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    await _ensureInitialized();

    final keys = _prefs?.getKeys() ?? <String>{};
    final metaKeys = keys.where((k) => k.startsWith(_cacheMetaPrefix)).toList();

    int cleanedCount = 0;

    for (final metaKey in metaKeys) {
      final metaJson = _prefs?.getString(metaKey);
      if (metaJson == null) continue;

      try {
        final meta = json.decode(metaJson) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(meta['cachedAt']);
        final ttlMillis = meta['ttlMillis'] as int;
        final ttl = Duration(milliseconds: ttlMillis);

        // Only clean very old expired cache (e.g., > 24 hours past expiry)
        final gracePeriod = const Duration(hours: 24);
        if (DateTime.now().isAfter(cachedAt.add(ttl).add(gracePeriod))) {
          final dataKey = metaKey.replaceFirst(_cacheMetaPrefix, _cachePrefix);
          await _prefs?.remove(metaKey);
          await _prefs?.remove(dataKey);
          cleanedCount++;
        }
      } catch (e) {
        // Invalid meta, remove both keys
        final dataKey = metaKey.replaceFirst(_cacheMetaPrefix, _cachePrefix);
        await _prefs?.remove(metaKey);
        await _prefs?.remove(dataKey);
        cleanedCount++;
      }
    }

    if (kDebugMode && cleanedCount > 0) {
      print('Cleaned $cleanedCount expired cache entries');
    }
  }

  /// Get statistics about cache usage
  Future<Map<String, dynamic>> getCacheStatistics() async {
    await _ensureInitialized();

    final keys = _prefs?.getKeys() ?? <String>{};
    final cacheDataKeys = keys
        .where((k) => k.startsWith(_cachePrefix))
        .toList();
    final cacheMetaKeys = keys
        .where((k) => k.startsWith(_cacheMetaPrefix))
        .toList();

    int totalSize = 0;
    int freshCount = 0;
    int expiredCount = 0;

    for (final metaKey in cacheMetaKeys) {
      final metaJson = _prefs?.getString(metaKey);
      if (metaJson == null) continue;

      totalSize += metaJson.length;

      try {
        final meta = json.decode(metaJson) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(meta['cachedAt']);
        final ttlMillis = meta['ttlMillis'] as int;
        final ttl = Duration(milliseconds: ttlMillis);

        if (DateTime.now().isBefore(cachedAt.add(ttl))) {
          freshCount++;
        } else {
          expiredCount++;
        }
      } catch (_) {
        expiredCount++;
      }
    }

    for (final dataKey in cacheDataKeys) {
      final dataJson = _prefs?.getString(dataKey);
      if (dataJson != null) {
        totalSize += dataJson.length;
      }
    }

    return {
      'totalEntries': cacheDataKeys.length,
      'freshEntries': freshCount,
      'expiredEntries': expiredCount,
      'totalSizeBytes': totalSize,
      'totalSizeKB': (totalSize / 1024).toStringAsFixed(2),
    };
  }
}
