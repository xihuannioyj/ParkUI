import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../binding/park_binding_path.dart';
import '../models/form_field_schema.dart';

/// 数据源解析回调。
///
/// [field] 字段定义。
/// [params] 解析后的参数。
/// 返回选项列表。
typedef ParkDataSourceFetcher =
    Future<List<Map<String, dynamic>>> Function(
  ParkFormFieldSchema field,
  Map<String, dynamic> params,
);

/// 数据源解析器。
///
/// 负责根据字段的 [ParkDataSourceType] 解析选项数据。
/// 支持静态选项、枚举映射、字典映射、异步接口、缓存等多种数据源。
///
/// 用法：
/// ```dart
/// final resolver = ParkDataSourceResolver();
/// resolver.registerFetcher('user_list', (field, params) async {
///   return await api.fetchUsers(params);
/// });
/// final options = await resolver.resolve(field, currentValues);
/// ```
class ParkDataSourceResolver {
  /// 异步数据源获取器注册表（按 data_source_key 注册）。
  final Map<String, ParkDataSourceFetcher> _fetchers =
      <String, ParkDataSourceFetcher>{};

  /// 枚举数据源注册表（按 data_source_key 注册）。
  final Map<String, List<Map<String, dynamic>>> _enumSources =
      <String, List<Map<String, dynamic>>>{};

  /// 字典数据源注册表（按 data_source_key 注册）。
  final Map<String, List<Map<String, dynamic>>> _dictSources =
      <String, List<Map<String, dynamic>>>{};

  /// 缓存数据源注册表（按 data_source_key 注册）。
  final Map<String, List<Map<String, dynamic>>> _cacheSources =
      <String, List<Map<String, dynamic>>>{};

  /// 缓存值存储（用于 `$cache.xxx` 参数引用解析）。
  ///
  /// 存储外部注入的缓存键值对，在异步接口数据源参数解析时，
  /// `$cache.xxx` 语法将从此存储中取值。
  final Map<String, dynamic> _cacheStore = <String, dynamic>{};

  /// 可选的错误回调钩子。
  ///
  /// 当异步数据源获取器抛出异常时调用，传入异常对象和堆栈信息。
  /// 用于外部接入错误上报系统（如 Sentry、Crashlytics）。
  void Function(Object error, StackTrace stack)? onError;

  /// 注册异步数据源获取器。
  ///
  /// [key] 数据源键（对应字段的 data_source_key）。
  /// [fetcher] 异步获取函数。
  void registerFetcher(String key, ParkDataSourceFetcher fetcher) {
    _fetchers[key] = fetcher;
  }

  /// 批量注册异步数据源获取器。
  ///
  /// [fetchers] 获取器集合。
  void registerFetchers(Map<String, ParkDataSourceFetcher> fetchers) {
    _fetchers.addAll(fetchers);
  }

  /// 注册枚举数据源。
  ///
  /// [key] 枚举键。
  /// [options] 选项列表，每项需包含 label 和 value。
  void registerEnum(String key, List<Map<String, dynamic>> options) {
    _enumSources[key] = options;
  }

  /// 注册字典数据源。
  ///
  /// [key] 字典键。
  /// [options] 选项列表。
  void registerDict(String key, List<Map<String, dynamic>> options) {
    _dictSources[key] = options;
  }

  /// 注册缓存数据源。
  ///
  /// [key] 缓存键。
  /// [options] 选项列表。
  void registerCache(String key, List<Map<String, dynamic>> options) {
    _cacheSources[key] = options;
  }

  /// 注册单个缓存值（用于 `$cache.xxx` 参数引用）。
  ///
  /// [key] 缓存键名（对应 `$cache.key` 中的 `key`）。
  /// [value] 缓存值。
  void registerCacheValue(String key, dynamic value) {
    _cacheStore[key] = value;
  }

  /// 批量注册缓存值（用于 `$cache.xxx` 参数引用）。
  ///
  /// [values] 缓存键值对集合。
  void registerCacheValues(Map<String, dynamic> values) {
    _cacheStore.addAll(values);
  }

  /// 移除异步数据源获取器。
  ///
  /// [key] 数据源键。
  void removeFetcher(String key) {
    _fetchers.remove(key);
  }

  /// 解析字段的选项数据。
  ///
  /// 根据字段的 [ParkDataSourceType] 自动选择对应的解析策略。
  /// 对于异步数据源，[currentValues] 用于解析动态参数引用。
  ///
  /// [field] 字段定义。
  /// [currentValues] 当前表单值（用于解析参数中的字段引用）。
  /// 返回选项列表，若无法解析则返回空列表。
  Future<List<Map<String, dynamic>>> resolve(
    ParkFormFieldSchema field, {
    Map<String, dynamic> currentValues = const <String, dynamic>{},
  }) async {
    switch (field.dataSourceType) {
      case ParkDataSourceType.none:
        return field.options;

      case ParkDataSourceType.staticOptions:
        return field.options;

      case ParkDataSourceType.enumSource:
        return _resolveEnum(field);

      case ParkDataSourceType.dict:
        return _resolveDict(field);

      case ParkDataSourceType.cache:
        return _resolveCache(field);

      case ParkDataSourceType.api:
        return _resolveApi(field, currentValues);
    }
  }

  /// 解析枚举数据源。
  ///
  /// [field] 字段定义。
  List<Map<String, dynamic>> _resolveEnum(ParkFormFieldSchema field) {
    final String? dsKey = field.dataSourceKey;
    if (dsKey == null || dsKey.isEmpty) return field.options;
    return _enumSources[dsKey] ?? field.options;
  }

  /// 解析字典数据源。
  ///
  /// [field] 字段定义。
  List<Map<String, dynamic>> _resolveDict(ParkFormFieldSchema field) {
    final String? dsKey = field.dataSourceKey;
    if (dsKey == null || dsKey.isEmpty) return field.options;
    return _dictSources[dsKey] ?? field.options;
  }

  /// 解析缓存数据源。
  ///
  /// [field] 字段定义。
  List<Map<String, dynamic>> _resolveCache(ParkFormFieldSchema field) {
    final String? dsKey = field.dataSourceKey;
    if (dsKey == null || dsKey.isEmpty) return field.options;
    return _cacheSources[dsKey] ?? field.options;
  }

  /// 解析异步接口数据源。
  ///
  /// 支持三种参数引用语法：
  /// - `$form.xxx`：从当前表单值 [currentValues] 中取 `xxx` 字段的值。
  /// - `$cache.xxx`：从缓存存储 [_cacheStore] 中取 `xxx` 键的值。
  /// - 普通字段名：若参数值是已注册的字段名，替换为对应表单值。
  ///
  /// [field] 字段定义。
  /// [currentValues] 当前表单值（用于解析参数引用）。
  Future<List<Map<String, dynamic>>> _resolveApi(
    ParkFormFieldSchema field,
    Map<String, dynamic> currentValues,
  ) async {
    final String? dsKey = field.dataSourceKey;
    if (dsKey == null || dsKey.isEmpty) return field.options;

    final ParkDataSourceFetcher? fetcher = _fetchers[dsKey];
    if (fetcher == null) return field.options;

    // 解析动态参数：仅支持 $form.xxx / $cache.xxx 点号路径引用。
    final Map<String, dynamic> resolvedParams = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in field.dataSourceParams.entries) {
      resolvedParams[entry.key] = _resolveParamValue(entry.value, currentValues);
    }

    // fetcher 抛错时回退空列表，避免传递到 build 导致 UI 崩溃（B20）。
    try {
      return await fetcher(field, resolvedParams);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[ParkDataSourceResolver] _resolveApi 失败，回退空列表: $e\n$stack');
      }
      // 在所有模式（含 release）下上报错误，避免静默吞异常（B76）。
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: stack,
        library: 'park_ui',
        context: ErrorDescription(
          'ParkDataSourceResolver._resolveApi failed for key "$dsKey"',
        ),
      ));
      onError?.call(e, stack);
      return <Map<String, dynamic>>[];
    }
  }

  /// 解析单个参数值。
  ///
  /// 按优先级依次尝试以下解析策略：
  /// 1. `$form.xxx` 前缀 → 沿点号路径从 [currentValues] 中取 `xxx`（支持嵌套 `a.b`）。
  /// 2. `$cache.xxx` 前缀 → 沿点号路径从 [_cacheStore] 中取 `xxx`（支持嵌套 `a.b`）。
  /// 3. 其他情况 → 原样返回。
  ///
  /// 注意：不再把普通字段名（如 `{'type':'status'}`）当作字段引用替换成字段值，
  /// 避免隐式替换带来的意外行为（B20）。
  ///
  /// [val] 原始参数值。
  /// [currentValues] 当前表单值。
  dynamic _resolveParamValue(dynamic val, Map<String, dynamic> currentValues) {
    if (val is! String) return val;

    // 解析 $form.xxx 前缀：沿点号路径从表单当前值中取字段值。
    if (val.startsWith(r'$form.')) {
      final String path = val.substring(6);
      return ParkBindingPath.resolve(path, currentValues);
    }

    // 解析 $cache.xxx 前缀：沿点号路径从缓存存储中取键值。
    if (val.startsWith(r'$cache.')) {
      final String path = val.substring(7);
      return ParkBindingPath.resolve(path, _cacheStore);
    }

    // 普通字段名不再隐式替换，原样返回。
    return val;
  }

  /// 清空所有注册的数据源及缓存值。
  void clear() {
    _fetchers.clear();
    _enumSources.clear();
    _dictSources.clear();
    _cacheSources.clear();
    _cacheStore.clear();
  }
}
