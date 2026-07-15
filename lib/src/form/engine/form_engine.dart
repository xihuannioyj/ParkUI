import 'dart:async';

import 'form_engine_io_stub.dart'
    if (dart.library.io) 'form_engine_io_native.dart'
    if (dart.library.html) 'form_engine_io_web.dart';

import '../data_source/park_data_source_resolver.dart';
import 'form_reaction_engine.dart';
import 'form_runtime_state.dart';
import '../models/form_field_schema.dart';
import '../regex/park_regex_registry.dart';
import '../validators/form_validator.dart';

/// 异步字段校验回调。
///
/// [field] 字段定义。
/// [value] 当前值。
/// 返回 null 表示通过，返回文本表示失败原因。
typedef AsyncFieldValidator =
    Future<String?> Function(ParkFormFieldSchema field, dynamic value);

/// 异步校验注册表。
typedef AsyncValidatorRegistry = Map<String, AsyncFieldValidator>;

/// 动态表单引擎。
///
/// 负责表单初始值生成、字段校验（同步 + 异步）、
/// 联动条件判断（显隐 / 禁用 / 动态必填）、数据源解析、
/// 导入导出等核心逻辑。
///
/// 内置 [ParkRegexRegistry] 支持正则标签，
/// 内置 [ParkDataSourceResolver] 支持多种数据源类型。
class ParkFormEngine {
  /// 异步校验策略注册表。
  final AsyncValidatorRegistry _asyncValidatorRegistry =
      <String, AsyncFieldValidator>{};

  /// 数据源解析器。
  final ParkDataSourceResolver dataSourceResolver =
      ParkDataSourceResolver();

  /// 校验请求序列号（B13）。
  ///
  /// 每次 [validateFormAsync] 启动时递增，异步回调返回时与当前序列号比较，
  /// 防止慢请求覆盖快请求的结果。
  int _validationSequence = 0;

  /// 注册异步校验策略。
  ///
  /// [key] 策略键，通常与字段的 asyncValidatorKey 对应。
  /// [validator] 异步校验回调。
  void registerAsyncValidator(String key, AsyncFieldValidator validator) {
    _asyncValidatorRegistry[key] = validator;
  }

  /// 批量注册异步校验策略。
  ///
  /// [registry] 策略集合。
  void registerAsyncValidators(AsyncValidatorRegistry registry) {
    _asyncValidatorRegistry.addAll(registry);
  }

  /// 移除异步校验策略。
  ///
  /// [key] 策略键。
  void unregisterAsyncValidator(String key) {
    _asyncValidatorRegistry.remove(key);
  }

  /// 清空异步校验策略。
  void clearAsyncValidators() {
    _asyncValidatorRegistry.clear();
  }

  /// 获取当前异步策略数量。
  int get asyncValidatorCount => _asyncValidatorRegistry.length;

  /// 根据表单结构生成初始值。
  ///
  /// [schema] 表单结构。
  Map<String, dynamic> buildInitialValues(ParkFormSchema schema) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final ParkFormFieldSchema field in schema.fields) {
      result[field.fieldName] = field.defaultValue;
    }
    return result;
  }

  /// 解析字段的有效正则表达式。
  ///
  /// 优先使用 [ParkFormFieldSchema.regexExpression]（直写正则），
  /// 其次从 [ParkRegexRegistry] 按 [ParkFormFieldSchema.regexTag] 查找。
  ///
  /// [field] 字段定义。
  /// 返回正则字符串或 null。
  String? resolveRegex(ParkFormFieldSchema field) {
    // 直写正则优先。
    if (field.regexExpression != null && field.regexExpression!.isNotEmpty) {
      return field.regexExpression;
    }
    // 正则标签查找。
    if (field.regexTag != null && field.regexTag!.isNotEmpty) {
      return ParkRegexRegistry.get(field.regexTag!);
    }
    return null;
  }

  /// 解析字段的动态必填状态。
  ///
  /// 如果字段配置了 [ParkFormFieldSchema.requiredRule]，
  /// 则根据当前值动态判断是否必填；否则退化为 [ParkFormFieldSchema.isRequired]。
  ///
  /// [field] 字段定义。
  /// [values] 当前表单值。
  bool isFieldRequired(
    ParkFormFieldSchema field,
    Map<String, dynamic> values, {
    ParkFormRuntimeOverrides? overrides,
  }) {
    final bool? overrideRequired = overrides?.requiredOf(field.fieldName);
    if (overrideRequired != null) {
      return overrideRequired;
    }
    if (field.requiredRule.isNotEmpty) {
      return ParkFormConditionMatcher.match(field.requiredRule, values);
    }
    return field.isRequired;
  }

  /// 校验单个字段。
  ///
  /// [field] 字段结构。
  /// [value] 字段值。
  /// [values] 当前表单全部值（用于动态必填判断）。
  String? validateField(
    ParkFormFieldSchema field,
    dynamic value, {
    Map<String, dynamic>? values,
    ParkFormRuntimeOverrides? overrides,
  }) {
    // 构造临时字段（注入动态必填状态）。
    final bool effectiveRequired = isFieldRequired(
      field,
      values ?? <String, dynamic>{},
      overrides: overrides,
    );
    final ParkFormFieldSchema effectiveField = effectiveRequired != field.isRequired
        ? field.copyWith(isRequired: effectiveRequired)
        : field;

    // 解析有效正则。
    final String? effectiveRegex = resolveRegex(effectiveField);
    final ParkFormFieldSchema regexField = effectiveRegex != null &&
            effectiveRegex != effectiveField.regexExpression
        ? effectiveField.copyWith(regexExpression: effectiveRegex)
        : effectiveField;

    final List<String? Function()> validators = <String? Function()>[
      () {
        final result = ParkFormValidators.required(value, regexField);
        return result.isValid ? null : result.message;
      },
      () {
        final result = ParkFormValidators.length(value, regexField);
        return result.isValid ? null : result.message;
      },
      () {
        final result = ParkFormValidators.regex(value, regexField);
        return result.isValid ? null : result.message;
      },
    ];

    for (final String? Function() run in validators) {
      final String? message = run();
      if (message != null) {
        // 如果字段配置了自定义校验提示，优先使用。
        return field.validatorMessage ?? message;
      }
    }
    return null;
  }

  /// 校验整个表单（同步）。
  ///
  /// [schema] 表单结构。
  /// [values] 当前值。
  Map<String, String> validateForm(
    ParkFormSchema schema,
    Map<String, dynamic> values,
    {
    ParkFormRuntimeOverrides? overrides,
    }
  ) {
    final Map<String, String> errors = <String, String>{};
    for (final ParkFormFieldSchema field in schema.fields) {
      if (!isFieldVisible(field, values, overrides: overrides)) {
        continue;
      }
      final String? error = validateField(
        field,
        values[field.fieldName],
        values: values,
        overrides: overrides,
      );
      if (error != null) {
        errors[field.fieldName] = error;
      }
    }
    return errors;
  }

  /// 异步校验整个表单。
  ///
  /// [schema] 表单结构。
  /// [values] 当前值。
  /// [validator] 外部异步校验实现（可选，作为兜底）。
  /// [timeoutMs] 单字段异步校验超时时间（毫秒），默认 5000。
  /// [debounceMs] 校验前防抖延迟（毫秒），默认 300。
  ///
  /// 超时机制：单字段校验超过 [timeoutMs] 未返回结果时，
  /// 标记为超时错误并继续校验其他字段。
  /// 防抖机制：校验前等待 [debounceMs] 毫秒，
  /// 避免频繁触发异步校验请求。
  Future<Map<String, String>> validateFormAsync(
    ParkFormSchema schema,
    Map<String, dynamic> values,
    AsyncFieldValidator? validator,
    {
    ParkFormRuntimeOverrides? overrides,
    int timeoutMs = 5000,
    int debounceMs = 300,
    }
  ) async {
    // 递增序列号并记录当前序号（B13）。
    _validationSequence++;
    final int seq = _validationSequence;

    // 防抖延迟
    await Future<void>.delayed(Duration(milliseconds: debounceMs));

    // 防抖期间如果新请求已启动，丢弃本次结果。
    if (_validationSequence != seq) return <String, String>{};

    final Map<String, String> errors = <String, String>{};
    for (final ParkFormFieldSchema field in schema.fields) {
      if (!isFieldVisible(field, values, overrides: overrides)) {
        continue;
      }
      if (field.asyncValidatorKey == null || field.asyncValidatorKey!.isEmpty) {
        continue;
      }

      final AsyncFieldValidator? resolved =
          _asyncValidatorRegistry[field.asyncValidatorKey!] ?? validator;
      if (resolved == null) {
        continue;
      }

      // 带超时的异步校验
      try {
        final String? error = await resolved(field, values[field.fieldName])
            .timeout(Duration(milliseconds: timeoutMs));
        // 校验完成后检查序列号，防止慢请求覆盖快请求（B13）。
        if (_validationSequence != seq) return errors;
        if (error != null && error.isNotEmpty) {
          errors[field.fieldName] = error;
        }
      } on TimeoutException {
        if (_validationSequence != seq) return errors;
        errors[field.fieldName] = '校验超时，请稍后重试';
      }
    }
    return errors;
  }

  /// 判断字段是否可见。
  ///
  /// [field] 字段定义。
  /// [values] 当前值。
  bool isFieldVisible(
    ParkFormFieldSchema field,
    Map<String, dynamic> values, {
    ParkFormRuntimeOverrides? overrides,
  }) {
    // 静态隐藏。
    if (field.hidden) return false;

    final bool? overrideVisible = overrides?.visibleOf(field.fieldName);
    if (overrideVisible != null) {
      return overrideVisible;
    }

    if (field.visibleRule.isEmpty) {
      return true;
    }
    return ParkFormConditionMatcher.match(field.visibleRule, values);
  }

  /// 判断字段是否禁用。
  ///
  /// [field] 字段定义。
  /// [values] 当前值。
  bool isFieldDisabled(
    ParkFormFieldSchema field,
    Map<String, dynamic> values, {
    ParkFormRuntimeOverrides? overrides,
  }) {
    if (field.isReadonly) {
      return true;
    }
    final bool? overrideDisabled = overrides?.disabledOf(field.fieldName);
    if (overrideDisabled != null) {
      return overrideDisabled;
    }
    if (field.disabledRule.isEmpty) {
      return false;
    }
    return ParkFormConditionMatcher.match(field.disabledRule, values);
  }

  /// 导出表单值到 JSON。
  ///
  /// 自动转换特殊类型：DateTime → ISO8601，File → path。
  ///
  /// [values] 当前值。
  Map<String, dynamic> exportValues(Map<String, dynamic> values) {
    final Map<String, dynamic> exported = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in values.entries) {
      final dynamic v = entry.value;
      if (v is DateTime) {
        exported[entry.key] = v.toIso8601String();
      } else {
        final String? filePath = trySerializeFilePath(v);
        exported[entry.key] = filePath ?? v;
      }
    }
    return exported;
  }

  /// 从 JSON 导入表单值。
  ///
  /// [schema] 表单结构。
  /// [json] JSON 数据。
  Map<String, dynamic> importValues(
    ParkFormSchema schema,
    Map<String, dynamic> json,
  ) {
    final Map<String, dynamic> result = buildInitialValues(schema);
    for (final ParkFormFieldSchema field in schema.fields) {
      if (json.containsKey(field.fieldName)) {
        result[field.fieldName] = json[field.fieldName];
      }
    }
    return result;
  }

  /// 获取字段的有序分组列表。
  ///
  /// 按 [ParkFormFieldSchema.order] 排序后，
  /// 按 [ParkFormFieldSchema.groupKey] 聚合。
  /// 返回 Map 的 key 为 groupKey（null 表示无分组），
  /// value 为该组的字段列表。
  ///
  /// [fields] 字段列表。
  Map<String?, List<ParkFormFieldSchema>> groupFields(
    List<ParkFormFieldSchema> fields,
  ) {
    final List<ParkFormFieldSchema> sorted = List<ParkFormFieldSchema>.from(fields)
      ..sort((ParkFormFieldSchema a, ParkFormFieldSchema b) =>
          a.order.compareTo(b.order));

    final Map<String?, List<ParkFormFieldSchema>> grouped =
        <String?, List<ParkFormFieldSchema>>{};

    for (final ParkFormFieldSchema field in sorted) {
      final String? gk = field.groupKey;
      grouped.putIfAbsent(gk, () => <ParkFormFieldSchema>[]);
      grouped[gk]!.add(field);
    }

    return grouped;
  }

}
