import '../models/form_field_schema.dart';
import 'form_runtime_state.dart';

/// reaction 运行时引擎。
///
/// 负责在字段值变化时，根据 schema 中声明的 reactions 计算运行时覆盖状态、
/// 字段值联动以及选项重载目标列表。
///
/// 支持级联重算（B14）：当 reaction 的目标字段自身也有 reaction 配置时，
/// 会自动继续执行下一趟，直到无新变化或达到 [maxDepth] / [maxFieldTriggers] 限制。
class ParkFormReactionEngine {
  /// 创建 reaction 运行时引擎。
  const ParkFormReactionEngine();

  /// 执行指定触发字段的 change reactions（支持级联重算）。
  ///
  /// [schema] 表单 schema。
  /// [triggerField] 触发字段名。
  /// [values] 当前表单值。
  /// [overrides] 当前运行时覆盖状态。
  /// [maxDepth] 级联最大深度（默认 10），防止无穷递归。
  /// [maxFieldTriggers] 单字段最大触发次数（默认 5），用于死循环检测。
  ParkFormReactionExecutionResult applyChange({
    required ParkFormSchema schema,
    required String triggerField,
    required Map<String, dynamic> values,
    required ParkFormRuntimeOverrides overrides,
    int maxDepth = 10,
    int maxFieldTriggers = 5,
  }) {
    Map<String, dynamic> nextValues = Map<String, dynamic>.from(values);
    Map<String, bool> visibleOverrides =
        Map<String, bool>.from(overrides.visibleOverrides);
    Map<String, bool> disabledOverrides =
        Map<String, bool>.from(overrides.disabledOverrides);
    Map<String, bool> requiredOverrides =
        Map<String, bool>.from(overrides.requiredOverrides);
    final Set<String> allAffectedFields = <String>{triggerField};
    final Set<String> allReloadFields = <String>{};
    final Map<String, int> fieldTriggerCount = <String, int>{};

    // 快照原始值，供 _resolveActionValue 读取 $form.xxx 引用（B65-Fix1）。
    // 避免级联过程中 nextValues 的中间态污染引用解析。
    final Map<String, dynamic> snapshotValues =
        Map<String, dynamic>.from(values);

    // 级联重算：从 triggerField 出发，逐趟执行 reactions，
    // 被 setValue 或 clearValue 影响的字段如果有自己的 reaction 则继续执行（B14）。
    Set<String> currentTriggerFields = <String>{triggerField};

    for (int depth = 0; depth < maxDepth; depth++) {
      final Set<String> nextTriggerFields = <String>{};

      for (final String trigger in currentTriggerFields) {
        // 死循环检测：同一字段在单次级联中触发次数不超过限制。
        fieldTriggerCount[trigger] =
            (fieldTriggerCount[trigger] ?? 0) + 1;
        if (fieldTriggerCount[trigger]! > maxFieldTriggers) {
          continue;
        }

        final Iterable<ParkFormReactionSchema> matchedReactions =
            schema.reactions.where(
          (ParkFormReactionSchema reaction) =>
              reaction.triggerEvent == ParkFormTriggerEvent.change &&
              reaction.triggerField == trigger,
        );

        for (final ParkFormReactionSchema reaction in matchedReactions) {
          final bool hit = reaction.conditions.isEmpty
              ? true
              : ParkFormConditionMatcher
                  .match(reaction.conditions, nextValues);
          if (!hit) {
            continue;
          }

          for (final ParkFormReactionActionSchema action in reaction.actions) {
            switch (action.actionType) {
              case ParkFormReactionActionType.setVisible:
                final bool resolved = _toBool(action.value);
                visibleOverrides[action.targetField] = resolved;
                allAffectedFields.add(action.targetField);
                break;
              case ParkFormReactionActionType.setDisabled:
                final bool resolved = _toBool(action.value);
                disabledOverrides[action.targetField] = resolved;
                allAffectedFields.add(action.targetField);
                break;
              case ParkFormReactionActionType.setRequired:
                final bool resolved = _toBool(action.value);
                requiredOverrides[action.targetField] = resolved;
                allAffectedFields.add(action.targetField);
                break;
              case ParkFormReactionActionType.setValue:
                nextValues[action.targetField] = _resolveActionValue(
                  action.value,
                  snapshotValues,
                );
                allAffectedFields.add(action.targetField);
                // 值变化的目标字段可能触发下一趟 reaction。
                if (action.targetField != trigger) {
                  nextTriggerFields.add(action.targetField);
                }
                break;
              case ParkFormReactionActionType.clearValue:
                nextValues[action.targetField] = null;
                allAffectedFields.add(action.targetField);
                if (action.targetField != trigger) {
                  nextTriggerFields.add(action.targetField);
                }
                break;
              case ParkFormReactionActionType.reloadOptions:
                allReloadFields.add(action.targetField);
                break;
            }
          }
        }
      }

      // 无新触发字段时结束级联。
      if (nextTriggerFields.isEmpty) break;
      currentTriggerFields = nextTriggerFields;
    }

    return ParkFormReactionExecutionResult(
      values: nextValues,
      overrides: ParkFormRuntimeOverrides(
        visibleOverrides: visibleOverrides,
        disabledOverrides: disabledOverrides,
        requiredOverrides: requiredOverrides,
      ),
      affectedFields: allAffectedFields,
      reloadFields: allReloadFields,
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
