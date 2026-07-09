import '../models/form_field_schema.dart';
import 'form_runtime_state.dart';

/// reaction 运行时引擎。
///
/// 负责在字段值变化时，根据 schema 中声明的 reactions 计算运行时覆盖状态、
/// 字段值联动以及选项重载目标列表。
class ParkFormReactionEngine {
  /// 创建 reaction 运行时引擎。
  const ParkFormReactionEngine();

  /// 执行指定触发字段的 change reactions。
  ///
  /// [schema] 表单 schema。
  /// [triggerField] 触发字段名。
  /// [values] 当前表单值。
  /// [overrides] 当前运行时覆盖状态。
  ParkFormReactionExecutionResult applyChange({
    required ParkFormSchema schema,
    required String triggerField,
    required Map<String, dynamic> values,
    required ParkFormRuntimeOverrides overrides,
  }) {
    final Map<String, dynamic> nextValues = Map<String, dynamic>.from(values);
    final Map<String, bool> visibleOverrides =
        Map<String, bool>.from(overrides.visibleOverrides);
    final Map<String, bool> disabledOverrides =
        Map<String, bool>.from(overrides.disabledOverrides);
    final Map<String, bool> requiredOverrides =
        Map<String, bool>.from(overrides.requiredOverrides);
    final Set<String> affectedFields = <String>{triggerField};
    final Set<String> reloadFields = <String>{};

    final Iterable<ParkFormReactionSchema> matchedReactions = schema.reactions
        .where(
          (ParkFormReactionSchema reaction) =>
              reaction.triggerEvent == ParkFormTriggerEvent.change &&
              reaction.triggerField == triggerField,
        );

    for (final ParkFormReactionSchema reaction in matchedReactions) {
      final bool hit = reaction.conditions.isEmpty
          ? true
          : ParkFormConditionMatcher.match(reaction.conditions, nextValues);
      if (!hit) {
        continue;
      }

      for (final ParkFormReactionActionSchema action in reaction.actions) {
        switch (action.actionType) {
          case ParkFormReactionActionType.setVisible:
            final bool resolved = _toBool(action.value);
            visibleOverrides[action.targetField] = resolved;
            affectedFields.add(action.targetField);
            break;
          case ParkFormReactionActionType.setDisabled:
            final bool resolved = _toBool(action.value);
            disabledOverrides[action.targetField] = resolved;
            affectedFields.add(action.targetField);
            break;
          case ParkFormReactionActionType.setRequired:
            final bool resolved = _toBool(action.value);
            requiredOverrides[action.targetField] = resolved;
            affectedFields.add(action.targetField);
            break;
          case ParkFormReactionActionType.setValue:
            nextValues[action.targetField] = _resolveActionValue(
              action.value,
              nextValues,
            );
            affectedFields.add(action.targetField);
            break;
          case ParkFormReactionActionType.clearValue:
            nextValues[action.targetField] = null;
            affectedFields.add(action.targetField);
            break;
          case ParkFormReactionActionType.reloadOptions:
            reloadFields.add(action.targetField);
            break;
        }
      }
    }

    return ParkFormReactionExecutionResult(
      values: nextValues,
      overrides: ParkFormRuntimeOverrides(
        visibleOverrides: visibleOverrides,
        disabledOverrides: disabledOverrides,
        requiredOverrides: requiredOverrides,
      ),
      affectedFields: affectedFields,
      reloadFields: reloadFields,
    );
  }

  /// 将动作值解析为最终值。
  ///
  /// 当前支持 `$form.xxx` 语法引用其他字段当前值。
  dynamic _resolveActionValue(
    dynamic rawValue,
    Map<String, dynamic> values,
  ) {
    if (rawValue is String && rawValue.startsWith(r'$form.')) {
      final String fieldName = rawValue.substring(6);
      return values[fieldName];
    }
    return rawValue;
  }

  /// 将动作值解析为布尔值。
  bool _toBool(dynamic rawValue) {
    if (rawValue is bool) {
      return rawValue;
    }
    if (rawValue is String) {
      return rawValue.toLowerCase() == 'true';
    }
    if (rawValue is num) {
      return rawValue != 0;
    }
    return false;
  }
}

/// conditions 匹配器。
///
/// 从原表单引擎中抽离为独立工具，供静态规则与 reactions 共同复用。
class ParkFormConditionMatcher {
  /// 使用现有 conditions 语法判断是否命中。
  static bool match(
    Map<String, dynamic> conditions,
    Map<String, dynamic> values,
  ) {
    if (conditions.containsKey('and')) {
      final dynamic list = conditions['and'];
      if (list is List) {
        return list.every((dynamic c) {
          if (c is Map<String, dynamic>) {
            return match(c, values);
          }
          if (c is Map) {
            return match(Map<String, dynamic>.from(c), values);
          }
          return false;
        });
      }
      return false;
    }

    if (conditions.containsKey('or')) {
      final dynamic list = conditions['or'];
      if (list is List) {
        return list.any((dynamic c) {
          if (c is Map<String, dynamic>) {
            return match(c, values);
          }
          if (c is Map) {
            return match(Map<String, dynamic>.from(c), values);
          }
          return false;
        });
      }
      return false;
    }

    if (conditions.containsKey('not')) {
      final dynamic sub = conditions['not'];
      if (sub is Map<String, dynamic>) {
        return !match(sub, values);
      }
      if (sub is Map) {
        return !match(Map<String, dynamic>.from(sub), values);
      }
      return false;
    }

    if (conditions.containsKey('field') && conditions.containsKey('equals')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic expected = conditions['equals'];
      return values[fieldKey] == expected;
    }

    if (conditions.containsKey('field') && conditions.containsKey('not_empty')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic fieldValue = values[fieldKey];
      if (fieldValue == null) return false;
      if (fieldValue is String && fieldValue.isEmpty) return false;
      if (fieldValue is List && fieldValue.isEmpty) return false;
      return true;
    }

    if (conditions.containsKey('field') && conditions.containsKey('contains')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic target = conditions['contains'];
      final dynamic fieldValue = values[fieldKey];
      if (fieldValue is List) return fieldValue.contains(target);
      if (fieldValue is String && target is String) {
        return fieldValue.contains(target);
      }
      return false;
    }

    if (conditions.containsKey('field') && conditions.containsKey('gt')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic fieldValue = values[fieldKey];
      final dynamic threshold = conditions['gt'];
      if (fieldValue == null || threshold == null) return false;
      if (fieldValue is num && threshold is num) return fieldValue > threshold;
      return false;
    }

    if (conditions.containsKey('field') && conditions.containsKey('lt')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic fieldValue = values[fieldKey];
      final dynamic threshold = conditions['lt'];
      if (fieldValue == null || threshold == null) return false;
      if (fieldValue is num && threshold is num) return fieldValue < threshold;
      return false;
    }

    if (conditions.containsKey('field') && conditions.containsKey('gte')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic fieldValue = values[fieldKey];
      final dynamic threshold = conditions['gte'];
      if (fieldValue == null || threshold == null) return false;
      if (fieldValue is num && threshold is num) {
        return fieldValue >= threshold;
      }
      return false;
    }

    if (conditions.containsKey('field') && conditions.containsKey('lte')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic fieldValue = values[fieldKey];
      final dynamic threshold = conditions['lte'];
      if (fieldValue == null || threshold == null) return false;
      if (fieldValue is num && threshold is num) {
        return fieldValue <= threshold;
      }
      return false;
    }

    if (conditions.containsKey('field') && conditions.containsKey('in')) {
      final String fieldKey = conditions['field'].toString();
      final dynamic list = conditions['in'];
      final dynamic fieldValue = values[fieldKey];
      if (list is List) return list.contains(fieldValue);
      return false;
    }

    for (final MapEntry<String, dynamic> entry in conditions.entries) {
      if (values[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
