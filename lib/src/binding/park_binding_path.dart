/// Park 双向绑定路径解析工具类。
///
/// 将点号分隔的路径字符串解析为嵌套 Map 的键链。
/// 支持不可变模式的设置（返回新 Map）。
///
/// ```dart
/// ParkBindingPath.split('user.address.city'); // ['user', 'address', 'city']
/// ParkBindingPath.resolve('a.b', {'a': {'b': 1}}); // 1
/// ```
class ParkBindingPath {
  /// 将点号分隔的路径字符串分割为键列表。
  ///
  /// `'user.address.city'` → `['user', 'address', 'city']`
  /// 空字符串 `''` 返回空列表。
  /// 根路径 `'/'` 返回空列表。
  static List<String> split(String path) {
    if (path.isEmpty || path == '/') return <String>[];
    return path.split('.');
  }

  /// 沿路径从 [data] 中解析值。
  ///
  /// 逐层从 Map 中取值，中间节点非 Map 时返回 `null`。
  /// 路径不存在时返回 `null`（不抛异常）。
  ///
  /// ```dart
  /// ParkBindingPath.resolve('a.b', {'a': {'b': 1}}); // 1
  /// ParkBindingPath.resolve('x.y', {'a': 1});        // null
  /// ```
  static dynamic resolve(String path, Map data) {
    final List<String> keys = split(path);
    if (keys.isEmpty) return data;
    return _resolveRecursive(keys, data, 0);
  }

  /// 递归沿键链取值。
  static dynamic _resolveRecursive(List<String> keys, dynamic data, int index) {
    if (data == null || data is! Map) return null;
    if (index >= keys.length) return data;

    final String key = keys[index];
    if (!data.containsKey(key)) return null;

    if (index == keys.length - 1) return data[key];
    return _resolveRecursive(keys, data[key], index + 1);
  }

  /// 沿路径在 [data] 中设置值（不可变式，返回新 Map）。
  ///
  /// 不修改原 [data]，沿途创建缺失的中间 Map 节点。
  ///
  /// ```dart
  /// final result = ParkBindingPath.set('a.b', {'a': {}}, 42);
  /// // result = {'a': {'b': 42}}
  /// ```
  static Map<String, dynamic> set(String path, Map data, dynamic value) {
    final List<String> keys = split(path);
    if (keys.isEmpty) {
      return Map<String, dynamic>.from(data);
    }
    return _setRecursive(keys, data, 0, value);
  }

  /// 递归沿键链设置值（不可变模式）。
  static Map<String, dynamic> _setRecursive(
    List<String> keys,
    dynamic current,
    int index,
    dynamic value,
  ) {
    if (current is! Map) {
      current = <String, dynamic>{};
    }
    final Map<String, dynamic> result = Map<String, dynamic>.from(current);

    final String key = keys[index];
    if (index == keys.length - 1) {
      if (value == null) {
        result.remove(key);
      } else {
        result[key] = value;
      }
      return result;
    }

    result[key] = _setRecursive(keys, current[key], index + 1, value);
    return result;
  }

  /// 判断路径在 [data] 中是否存在。
  ///
  /// ```dart
  /// ParkBindingPath.hasPath('a.b', {'a': {'b': 1}}); // true
  /// ParkBindingPath.hasPath('a.c', {'a': {'b': 1}}); // false
  /// ```
  static bool hasPath(String path, Map data) {
    final List<String> keys = split(path);
    if (keys.isEmpty) return true;

    dynamic current = data;
    for (int i = 0; i < keys.length; i++) {
      if (current is! Map) return false;
      if (!current.containsKey(keys[i])) return false;
      current = current[keys[i]];
    }
    return true;
  }
}
