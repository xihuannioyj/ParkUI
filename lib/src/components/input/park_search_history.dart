import 'dart:async';

import 'park_search_delegate.dart';

/// 搜索历史持久化存储接口。
///
/// [ParkStorageSearchHistory] 通过该接口读写持久化数据。
/// 应用可实现为 SharedPreferences、数据库或远程存储，
/// scope 与存储 key 的映射由实现方决定（如 `search_history_<scope>`）。
abstract class ParkSearchHistoryStorage {
  /// 读取指定 [scope] 的历史记录（按时间倒序，最近在前）。
  Future<List<String>> loadHistory(String scope);

  /// 保存指定 [scope] 的历史记录（按时间倒序，最近在前）。
  Future<void> saveHistory(String scope, List<String> keywords);
}

/// 内存版搜索历史实现（无持久化）。
///
/// 与 [ParkStorageSearchHistory] 相同的去重/前置/截断语义，
/// 数据仅保存在内存中，应用重启后丢失。
class ParkMemorySearchHistory implements ParkSearchHistory {
  final Map<String, List<String>> _store = {};

  /// 单 scope 最大条数（默认 10）。
  final int limit;

  ParkMemorySearchHistory({this.limit = 10});

  @override
  List<String> getHistory(String scope) =>
      List.unmodifiable(_store[scope] ?? const []);

  @override
  void addHistory(String scope, String keyword) {
    final kw = keyword.trim();
    if (kw.isEmpty) return;
    final list = _store.putIfAbsent(scope, () => []);
    list.remove(kw);
    list.insert(0, kw);
    if (list.length > limit) list.removeLast();
  }

  @override
  void removeHistory(String scope, String keyword) {
    _store[scope]?.remove(keyword.trim());
  }

  @override
  void clearHistory(String scope) {
    _store[scope] = [];
  }
}

/// 存储版搜索历史实现：桥接 [ParkSearchHistoryStorage] 持久化搜索历史。
///
/// 内部维护同步缓存，异步写入存储。首次同步访问时自动触发异步加载，
/// 也可通过 [preload] 在应用启动时预加载多个 scope。
class ParkStorageSearchHistory implements ParkSearchHistory {
  /// 创建存储版搜索历史。
  ///
  /// [storage] 持久化存储实现；[limit] 单 scope 最大条数（默认 10）。
  ParkStorageSearchHistory({
    required ParkSearchHistoryStorage storage,
    this.limit = 10,
  }) : _storage = storage;

  final ParkSearchHistoryStorage _storage;
  final int limit;
  final Map<String, List<String>> _cache = {};
  final Set<String> _loaded = {};

  /// 预加载所有历史到缓存（在 app 启动或首次使用前调用）。
  Future<void> preload(List<String> scopes) async {
    for (final scope in scopes) {
      final raw = await _storage.loadHistory(scope);
      _cache[scope] = raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      _loaded.add(scope);
    }
  }

  Future<void> _ensureLoaded(String scope) async {
    if (_loaded.contains(scope)) return;
    await preload([scope]);
  }

  @override
  List<String> getHistory(String scope) {
    // 首次同步访问时触发异步加载
    unawaited(_ensureLoaded(scope));
    return List.unmodifiable(_cache[scope] ?? const []);
  }

  @override
  void addHistory(String scope, String keyword) {
    final kw = keyword.trim();
    if (kw.isEmpty) return;
    final list = _cache.putIfAbsent(scope, () => []);
    list.remove(kw);
    list.insert(0, kw);
    if (list.length > limit) list.removeLast();
    // 异步持久化
    unawaited(_storage.saveHistory(scope, List.unmodifiable(list)));
  }

  @override
  void removeHistory(String scope, String keyword) {
    _cache[scope]?.remove(keyword.trim());
    final list = _cache[scope] ?? [];
    unawaited(_storage.saveHistory(scope, List.unmodifiable(list)));
  }

  @override
  void clearHistory(String scope) {
    _cache[scope] = [];
    unawaited(_storage.saveHistory(scope, const []));
  }
}
