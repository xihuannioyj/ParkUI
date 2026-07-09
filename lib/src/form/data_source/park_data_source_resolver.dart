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

    // 解析动态参数：支持 $form.xxx、$cache.xxx 及普通字段名引用。
    final Map<String, dynamic> resolvedParams = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in field.dataSourceParams.entries) {
      resolvedParams[entry.key] = _resolveParamValue(entry.value, currentValues);
    }

    return fetcher(field, resolvedParams);
  }

  /// 解析单个参数值。
  ///
  /// 按优先级依次尝试以下解析策略：
  /// 1. `$form.xxx` 前缀 → 从 [currentValues] 中取 `xxx`。
  /// 2. `$cache.xxx` 前缀 → 从 [_cacheStore] 中取 `xxx`。
  /// 3. 普通字符串且匹配已有表单字段 → 从 [currentValues] 中取值。
  /// 4. 其他情况 → 原样返回。
  ///
  /// [val] 原始参数值。
  /// [currentValues] 当前表单值。
  dynamic _resolveParamValue(dynamic val, Map<String, dynamic> currentValues) {
    if (val is! String) return val;

    // 解析 $form.xxx 前缀：从表单当前值中取字段值。
    if (val.startsWith(r'$form.')) {
      final String fieldName = val.substring(6);
      return currentValues[fieldName];
    }

    // 解析 $cache.xxx 前缀：从缓存存储中取键值。
    if (val.startsWith(r'$cache.')) {
      final String cacheKey = val.substring(7);
      return _cacheStore[cacheKey];
    }

    // 兼容旧逻辑：若参数值是已有字段名，替换为该字段的当前值。
    if (currentValues.containsKey(val)) {
      return currentValues[val];
    }

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
