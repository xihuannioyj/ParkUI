/// 声明式字段联动的条件表达式求值器。
///
/// 支持简单的比较表达式，用于 [ParkFormFieldSchema.dependencies] 联动场景：
/// - `fieldName == 'value'`  等于
/// - `fieldName != 'value'`  不等于
/// - `fieldName > 5`         大于
/// - `fieldName < 5`         小于
/// - `fieldName >= 5`        大于等于
/// - `fieldName <= 5`        小于等于
/// - `fieldName contains 'x'`  包含
/// - `fieldName !contains 'x'` 不包含
///
/// 右侧值会自动推断类型：布尔值（true/false）、整数、双精度浮点数或字符串。
/// 字符串值可以用单引号或双引号包裹，也可以不加引号。
class ParkFormFieldExpressionEvaluator {
  ParkFormFieldExpressionEvaluator._();

  /// 计算条件表达式。
  ///
  /// [expression] 条件表达式字符串。为 null 或空时返回 null（表示无此条件约束）。
  /// [values] 当前表单所有字段的值。
  ///
  /// 返回 `true` / `false` 表示条件是否满足，
  /// 返回 `null` 表示表达式为空（无约束，应保持默认行为）。
  static bool? evaluate(String? expression, Map<String, dynamic> values) {
    if (expression == null || expression.trim().isEmpty) return null;

    final String expr = expression.trim();

    // 按运算符长度降序尝试匹配，避免 '>=' 被 '>' 抢先匹配。
    const List<String> operators = <String>[
      '!=', '==', '>=', '<=', '>', '<',
      '!contains', 'contains',
    ];

    for (final String op in operators) {
      final int idx = _findOperatorIndex(expr, op);
      if (idx == -1) continue;

      final String fieldName = expr.substring(0, idx).trim();
      final String rawValue = expr.substring(idx + op.length).trim();

      if (fieldName.isEmpty || rawValue.isEmpty) continue;

      final dynamic fieldValue = values[fieldName];
      final dynamic compareValue = _parseValue(rawValue);

      return _compare(fieldValue, op, compareValue);
    }

    // 无法解析的表达式默认 false。
    return false;
  }

  /// 在表达式中查找运算符的位置（跳过字段名中可能包含的字符）。
  ///
  /// 从右向左查找最后一次出现的位置，确保字段名中的运算符子串不会误匹配。
  /// 例如 `fieldName >= 5` 中查找 `>=` 应命中空格前的那个。
  static int _findOperatorIndex(String expr, String op) {
    // 对于 `!contains`，需要特殊处理空格。
    if (op == '!contains') {
      final int idx = expr.indexOf('!contains');
      return idx;
    }
    if (op == 'contains') {
      // 确保不是 `!contains` 的一部分。
      int searchFrom = 0;
      while (true) {
        final int idx = expr.indexOf('contains', searchFrom);
        if (idx == -1) return -1;
        if (idx == 0 || expr[idx - 1] != '!') return idx;
        searchFrom = idx + 1;
      }
    }
    return expr.lastIndexOf(op);
  }

  /// 解析字面量值为对应的 Dart 类型。
  static dynamic _parseValue(String raw) {
    final String v = raw.trim();

    // 布尔值。
    if (v == 'true') return true;
    if (v == 'false') return false;
    if (v == 'null') return null;

    // 引号包裹的字符串。
    if ((v.startsWith("'") && v.endsWith("'")) ||
        (v.startsWith('"') && v.endsWith('"'))) {
      return v.substring(1, v.length - 1);
    }

    // 整数。
    final int? intVal = int.tryParse(v);
    if (intVal != null) return intVal;

    // 双精度浮点数。
    final double? doubleVal = double.tryParse(v);
    if (doubleVal != null) return doubleVal;

    // 普通字符串。
    return v;
  }

  /// 根据运算符执行比较。
  static bool _compare(dynamic fieldValue, String op, dynamic compareValue) {
    switch (op) {
      case '==':
        return _looseEquals(fieldValue, compareValue);
      case '!=':
        return !_looseEquals(fieldValue, compareValue);
      case '>':
        return _numericCompare(fieldValue, compareValue) > 0;
      case '<':
        return _numericCompare(fieldValue, compareValue) < 0;
      case '>=':
        return _numericCompare(fieldValue, compareValue) >= 0;
      case '<=':
        return _numericCompare(fieldValue, compareValue) <= 0;
      case 'contains':
        return _contains(fieldValue, compareValue);
      case '!contains':
        return !_contains(fieldValue, compareValue);
      default:
        return false;
    }
  }

  /// 宽松相等比较（支持跨类型：num 与 num、String 与 String）。
  static bool _looseEquals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a is num && b is num) return a == b;
    // 字符串与数字的宽松比较。
    if (a is String && b is num) return double.tryParse(a) == b;
    if (a is num && b is String) return a == double.tryParse(b);
    return a.toString() == b.toString();
  }

  /// 数值比较（返回 -1 / 0 / 1）。
  static int _numericCompare(dynamic a, dynamic b) {
    if (a is num && b is num) return a.compareTo(b);
    if (a is num && b is String) {
      final double? bv = double.tryParse(b);
      return bv != null ? a.compareTo(bv) : -1;
    }
    if (a is String && b is num) {
      final double? av = double.tryParse(a);
      return av != null ? av.compareTo(b) : -1;
    }
    if (a is String && b is String) {
      final double? av = double.tryParse(a);
      final double? bv = double.tryParse(b);
      if (av != null && bv != null) return av.compareTo(bv);
    }
    return -1;
  }

  /// 包含检查（支持 String.contains 和 List.contains）。
  static bool _contains(dynamic fieldValue, dynamic compareValue) {
    if (fieldValue is String && compareValue is String) {
      return fieldValue.contains(compareValue);
    }
    if (fieldValue is List) {
      return fieldValue.contains(compareValue);
    }
    return false;
  }
}
