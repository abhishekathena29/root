import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks per-app launch counts so themes can surface "most used" apps
/// (e.g. Typography's default favorites) without any manual curation.
class UsageTracker {
  UsageTracker._();

  static const _key = 'app_launch_counts';
  static Map<String, int>? _cache;

  static Future<Map<String, int>> _load() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _cache = {};
      return _cache!;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _cache = decoded.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      _cache = {};
    }
    return _cache!;
  }

  /// Increments the launch count for [packageName].
  static Future<void> recordLaunch(String packageName) async {
    final counts = await _load();
    counts[packageName] = (counts[packageName] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(counts));
  }

  /// Returns the launch count for [packageName], or 0 if never launched.
  static int countOf(String packageName) => _cache?[packageName] ?? 0;

  /// Loads counts into the in-memory cache so [countOf] can be used
  /// synchronously afterwards. Call once before reading counts in a build.
  static Future<Map<String, int>> preload() => _load();
}
