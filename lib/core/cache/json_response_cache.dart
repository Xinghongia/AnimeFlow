import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

/// 公开资料的持久化缓存：有效期内复用，过期后刷新，失败时保留旧数据。
class JsonResponseCache {
  static const defaultMaxAge = Duration(hours: 12);

  static Future<T> get<T>(
    Box<String> box,
    String key, {
    required Future<T> Function() load,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    CancelToken? cancelToken,
    bool forceRefresh = false,
    Duration maxAge = defaultMaxAge,
    int maxEntries = 100,
    // A caller may invalidate a group of pages while a request is in flight.
    bool Function()? shouldCache,
  }) async {
    if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;
    T? cached;
    try {
      final raw = box.get(key);
      if (raw != null) {
        final entry = jsonDecode(raw) as Map<String, dynamic>;
        final data = fromJson(entry['data'] as Map<String, dynamic>);
        final cachedAt = entry['cachedAt'] as int;
        cached = data;
        final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
        if (!forceRefresh && age >= 0 && age < maxAge.inMilliseconds) {
          return data;
        }
      }
    } catch (error) {
      debugPrint('Failed to read response cache: $error');
    }

    final T result;
    try {
      result = await load();
    } catch (error) {
      if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;
      if (cached == null) rethrow;
      debugPrint('Failed to refresh response cache: $error');
      return cached;
    }
    if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;
    if (shouldCache != null && !shouldCache()) return result;
    try {
      await box.put(
          key,
          jsonEncode({
            'cachedAt': DateTime.now().millisecondsSinceEpoch,
            'data': toJson(result),
          }));
      if (box.length > maxEntries) {
        final entries = box.toMap().entries.toList()
          ..sort((a, b) => _cachedAt(a.value).compareTo(_cachedAt(b.value)));
        await box.deleteAll(
          entries.take(box.length - maxEntries).map((entry) => entry.key),
        );
      }
    } catch (error) {
      debugPrint('Failed to write response cache: $error');
    }
    return result;
  }

  static int _cachedAt(String raw) {
    try {
      return (jsonDecode(raw) as Map<String, dynamic>)['cachedAt'] as int;
    } catch (_) {
      return 0;
    }
  }
}
