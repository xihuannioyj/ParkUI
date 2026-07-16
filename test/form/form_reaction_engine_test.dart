/// ParkFormReactionEngine 测试
/// 测试级联重算、maxDepth 防环、snapshot 隔离

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 辅助：构建 reaction
ParkFormReactionSchema _reaction({
  required String triggerField,
  required List<ParkFormReactionActionSchema> actions,
  Map<String, dynamic> conditions = const <String, dynamic>{},
}) {
  return ParkFormReactionSchema(
    reactionId: 'r_$triggerField',
    triggerField: triggerField,
    triggerEvent: ParkFormTriggerEvent.change,
    conditions: conditions,
    actions: actions,
  );
}

/// 辅助：构建 action
ParkFormReactionActionSchema _action(
  ParkFormReactionActionType type,
  String targetField, {
  dynamic value,
}) {
  return ParkFormReactionActionSchema(
    actionType: type,
    targetField: targetField,
    value: value,
  );
}

void main() {
  late ParkFormReactionEngine engine;

  setUp(() {
    engine = const ParkFormReactionEngine();
  });

  group('ParkFormReactionEngine - 基本 setVisible', () {
    test('无条件 reaction 触发 setVisible', () {
      final schema = ParkFormSchema(
        formKey: 'test',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'a', fieldType: ParkFieldType.text,
            labelName: 'A', fieldName: 'a',
          ),
          ParkFormFieldSchema(
            fieldId: 'b', fieldType: ParkFieldType.text,
            labelName: 'B', fieldName: 'b',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'a',
            actions: [_action(ParkFormReactionActionType.setVisible, 'b', value: false)],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'a',
        values: {'a': 'hello', 'b': 'world'},
        overrides: const ParkFormRuntimeOverrides(),
      );

      expect(result.overrides.visibleOf('b'), isFalse);
      expect(result.affectedFields.contains('a'), isTrue);
      expect(result.affectedFields.contains('b'), isTrue);
    });
  });

  group('ParkFormReactionEngine - 条件匹配', () {
    test('条件满足时执行动作', () {
      final schema = ParkFormSchema(
        formKey: 'test',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'type', fieldType: ParkFieldType.select,
            labelName: '类型', fieldName: 'type',
          ),
          ParkFormFieldSchema(
            fieldId: 'detail', fieldType: ParkFieldType.text,
            labelName: '详情', fieldName: 'detail',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'type',
            conditions: <String, dynamic>{'field': 'type', 'equals': 'special'},
            actions: [_action(ParkFormReactionActionType.setVisible, 'detail', value: true)],
          ),
        ],
      );

      // 条件满足
      final result1 = engine.applyChange(
        schema: schema,
        triggerField: 'type',
        values: {'type': 'special', 'detail': null},
        overrides: const ParkFormRuntimeOverrides(),
      );
      expect(result1.overrides.visibleOf('detail'), isTrue);

      // 条件不满足
      final result2 = engine.applyChange(
        schema: schema,
        triggerField: 'type',
        values: {'type': 'normal', 'detail': null},
        overrides: const ParkFormRuntimeOverrides(),
      );
      expect(result2.overrides.visibleOf('detail'), isNull);
    });
  });

  group('ParkFormReactionEngine - setValue 级联重算 (B14)', () {
    test('A 变化 → 设置 B → B 的 reaction 继续触发设置 C', () {
      final schema = ParkFormSchema(
        formKey: 'cascade',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'a', fieldType: ParkFieldType.text,
            labelName: 'A', fieldName: 'a',
          ),
          ParkFormFieldSchema(
            fieldId: 'b', fieldType: ParkFieldType.text,
            labelName: 'B', fieldName: 'b',
          ),
          ParkFormFieldSchema(
            fieldId: 'c', fieldType: ParkFieldType.text,
            labelName: 'C', fieldName: 'c',
          ),
        ],
        reactions: [
          // A 变化 → 设置 B 的值
          _reaction(
            triggerField: 'a',
            actions: [_action(ParkFormReactionActionType.setValue, 'b', value: 'from_a')],
          ),
          // B 变化 → 设置 C 的值
          _reaction(
            triggerField: 'b',
            actions: [_action(ParkFormReactionActionType.setValue, 'c', value: 'from_b')],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'a',
        values: {'a': 'init', 'b': null, 'c': null},
        overrides: const ParkFormRuntimeOverrides(),
      );

      // 级联应传播到 C
      expect(result.values['b'], 'from_a');
      expect(result.values['c'], 'from_b');
      expect(result.affectedFields.contains('c'), isTrue);
    });
  });

  group('ParkFormReactionEngine - maxDepth 防环', () {
    test('循环 reaction 在 maxDepth 处终止', () {
      // A → 设置 B, B → 设置 A，形成循环
      final schema = ParkFormSchema(
        formKey: 'loop',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'a', fieldType: ParkFieldType.text,
            labelName: 'A', fieldName: 'a',
          ),
          ParkFormFieldSchema(
            fieldId: 'b', fieldType: ParkFieldType.text,
            labelName: 'B', fieldName: 'b',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'a',
            actions: [_action(ParkFormReactionActionType.setValue, 'b', value: 'loop_b')],
          ),
          _reaction(
            triggerField: 'b',
            actions: [_action(ParkFormReactionActionType.setValue, 'a', value: 'loop_a')],
          ),
        ],
      );

      // maxDepth=3 应能正常终止而不死循环
      final result = engine.applyChange(
        schema: schema,
        triggerField: 'a',
        values: {'a': 'start', 'b': null},
        overrides: const ParkFormRuntimeOverrides(),
        maxDepth: 3,
      );

      // 验证执行正常完成，没有抛异常
      expect(result, isNotNull);
      expect(result.values, isA<Map<String, dynamic>>());
    });

    test('maxFieldTriggers 限制单字段触发次数', () {
      final schema = ParkFormSchema(
        formKey: 'triggers',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'x', fieldType: ParkFieldType.text,
            labelName: 'X', fieldName: 'x',
          ),
          ParkFormFieldSchema(
            fieldId: 'y', fieldType: ParkFieldType.text,
            labelName: 'Y', fieldName: 'y',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'x',
            actions: [_action(ParkFormReactionActionType.setValue, 'y', value: 'v')],
          ),
          _reaction(
            triggerField: 'y',
            actions: [_action(ParkFormReactionActionType.setValue, 'x', value: 'v')],
          ),
        ],
      );

      // maxFieldTriggers=2 应限制单字段最多触发 2 次
      final result = engine.applyChange(
        schema: schema,
        triggerField: 'x',
        values: {'x': 'start', 'y': null},
        overrides: const ParkFormRuntimeOverrides(),
        maxDepth: 20,
        maxFieldTriggers: 2,
      );

      expect(result, isNotNull);
    });
  });

  group('ParkFormReactionEngine - snapshot 隔离 (B65-Fix1)', () {
    test('\$form.xxx 引用使用原始快照值而非中间态', () {
      final schema = ParkFormSchema(
        formKey: 'snapshot',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'source', fieldType: ParkFieldType.text,
            labelName: '源', fieldName: 'source',
          ),
          ParkFormFieldSchema(
            fieldId: 'target', fieldType: ParkFieldType.text,
            labelName: '目标', fieldName: 'target',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'source',
            actions: [
              // 使用 $form.source 引用原始值
              _action(ParkFormReactionActionType.setValue, 'target',
                  value: r'$form.source'),
            ],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'source',
        values: {'source': 'original_value', 'target': null},
        overrides: const ParkFormRuntimeOverrides(),
      );

      // target 应被设为 source 的原始快照值
      expect(result.values['target'], 'original_value');
    });
  });

  group('ParkFormReactionEngine - clearValue / reloadOptions', () {
    test('clearValue 将目标字段置 null', () {
      final schema = ParkFormSchema(
        formKey: 'clear',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'a', fieldType: ParkFieldType.text,
            labelName: 'A', fieldName: 'a',
          ),
          ParkFormFieldSchema(
            fieldId: 'b', fieldType: ParkFieldType.text,
            labelName: 'B', fieldName: 'b',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'a',
            actions: [_action(ParkFormReactionActionType.clearValue, 'b')],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'a',
        values: {'a': 'changed', 'b': 'old_value'},
        overrides: const ParkFormRuntimeOverrides(),
      );

      expect(result.values['b'], isNull);
    });

    test('reloadOptions 收集需要重载的字段', () {
      final schema = ParkFormSchema(
        formKey: 'reload',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'city', fieldType: ParkFieldType.select,
            labelName: '城市', fieldName: 'city',
          ),
          ParkFormFieldSchema(
            fieldId: 'district', fieldType: ParkFieldType.select,
            labelName: '区', fieldName: 'district',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'city',
            actions: [
              _action(ParkFormReactionActionType.clearValue, 'district'),
              _action(ParkFormReactionActionType.reloadOptions, 'district'),
            ],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'city',
        values: {'city': 'beijing', 'district': 'chaoyang'},
        overrides: const ParkFormRuntimeOverrides(),
      );

      expect(result.values['district'], isNull);
      expect(result.reloadFields.contains('district'), isTrue);
    });
  });

  group('ParkFormReactionEngine - setDisabled / setRequired', () {
    test('setDisabled 设置字段禁用覆盖', () {
      final schema = ParkFormSchema(
        formKey: 'disable',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'mode', fieldType: ParkFieldType.select,
            labelName: '模式', fieldName: 'mode',
          ),
          ParkFormFieldSchema(
            fieldId: 'input', fieldType: ParkFieldType.text,
            labelName: '输入', fieldName: 'input',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'mode',
            actions: [
              _action(ParkFormReactionActionType.setDisabled, 'input', value: true),
            ],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'mode',
        values: {'mode': 'readonly', 'input': 'data'},
        overrides: const ParkFormRuntimeOverrides(),
      );

      expect(result.overrides.disabledOf('input'), isTrue);
    });

    test('setRequired 设置字段必填覆盖', () {
      final schema = ParkFormSchema(
        formKey: 'required',
        fields: [
          ParkFormFieldSchema(
            fieldId: 'toggle', fieldType: ParkFieldType.toggle,
            labelName: '开关', fieldName: 'toggle',
          ),
          ParkFormFieldSchema(
            fieldId: 'reason', fieldType: ParkFieldType.text,
            labelName: '原因', fieldName: 'reason',
          ),
        ],
        reactions: [
          _reaction(
            triggerField: 'toggle',
            actions: [
              _action(ParkFormReactionActionType.setRequired, 'reason', value: true),
            ],
          ),
        ],
      );

      final result = engine.applyChange(
        schema: schema,
        triggerField: 'toggle',
        values: {'toggle': true, 'reason': null},
        overrides: const ParkFormRuntimeOverrides(),
      );

      expect(result.overrides.requiredOverrides['reason'], isTrue);
    });
  });
}
