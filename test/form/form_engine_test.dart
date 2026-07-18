/// ParkFormEngine 核心测试
/// 测试 validateFormAsync、并行校验、mounted 守卫、序列号防竞态

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 辅助：构建测试用 ParkFormFieldSchema
ParkFormFieldSchema _field({
  required String name,
  bool required_ = false,
  String? asyncKey,
  bool hidden = false,
  Map<String, dynamic> visibleRule = const <String, dynamic>{},
}) {
  return ParkFormFieldSchema(
    fieldId: name,
    fieldType: ParkFieldType.text,
    labelName: name,
    fieldName: name,
    isRequired: required_,
    asyncValidatorKey: asyncKey,
    hidden: hidden,
    visibleRule: visibleRule,
  );
}

/// 辅助：构建测试用 ParkFormSchema
ParkFormSchema _schema(List<ParkFormFieldSchema> fields) {
  return ParkFormSchema(formKey: 'test_form', fields: fields);
}

void main() {
  late ParkFormEngine engine;

  setUp(() {
    engine = ParkFormEngine();
  });

  group('ParkFormEngine - buildInitialValues', () {
    test('根据 schema 生成初始值', () {
      final schema = _schema([
        _field(name: 'username'),
        _field(name: 'age'),
      ]);
      // 两个字段的 defaultValue 均为 null
      final values = engine.buildInitialValues(schema);
      expect(values.containsKey('username'), isTrue);
      expect(values.containsKey('age'), isTrue);
      expect(values['username'], isNull);
      expect(values['age'], isNull);
    });

    test('defaultValue 被正确填充', () {
      final schema = _schema([
        ParkFormFieldSchema(
          fieldId: 'status',
          fieldType: ParkFieldType.select,
          labelName: '状态',
          fieldName: 'status',
          defaultValue: 'active',
        ),
      ]);
      final values = engine.buildInitialValues(schema);
      expect(values['status'], 'active');
    });
  });

  group('ParkFormEngine - validateField', () {
    test('必填字段为空时返回错误', () {
      final field = _field(name: 'name', required_: true);
      final error = engine.validateField(field, null);
      expect(error, isNotNull);
      expect(error, isNotEmpty);
    });

    test('必填字段有值时通过', () {
      final field = _field(name: 'name', required_: true);
      final error = engine.validateField(field, 'hello');
      expect(error, isNull);
    });

    test('非必填字段为空时通过', () {
      final field = _field(name: 'name', required_: false);
      final error = engine.validateField(field, null);
      expect(error, isNull);
    });

    test('自定义 validatorMessage 覆盖默认提示', () {
      final field = ParkFormFieldSchema(
        fieldId: 'email',
        fieldType: ParkFieldType.text,
        labelName: '邮箱',
        fieldName: 'email',
        isRequired: true,
        validatorMessage: '请输入邮箱地址',
      );
      final error = engine.validateField(field, null);
      expect(error, '请输入邮箱地址');
    });
  });

  group('ParkFormEngine - validateForm', () {
    test('隐藏字段不参与校验', () {
      final schema = _schema([
        _field(name: 'visible_field', required_: true),
        _field(name: 'hidden_field', required_: true, hidden: true),
      ]);
      final errors = engine.validateForm(schema, {'visible_field': 'ok'});
      // hidden_field 被跳过，visible_field 有值通过
      expect(errors, isEmpty);
    });

    test('visibleRule 条件不满足时字段跳过校验', () {
      final schema = _schema([
        _field(
          name: 'conditional',
          required_: true,
          visibleRule: <String, dynamic>{
            'field': 'toggle',
            'equals': 'yes',
          },
        ),
      ]);
      final errors = engine.validateForm(
        schema,
        {'toggle': 'no'},
      );
      expect(errors, isEmpty);
    });

    test('多字段校验收集所有错误', () {
      final schema = _schema([
        _field(name: 'a', required_: true),
        _field(name: 'b', required_: true),
        _field(name: 'c', required_: false),
      ]);
      final errors = engine.validateForm(schema, {'a': null, 'b': null, 'c': null});
      expect(errors.length, 2);
      expect(errors.containsKey('a'), isTrue);
      expect(errors.containsKey('b'), isTrue);
    });
  });

  group('ParkFormEngine - validateFormAsync 序列号防竞态', () {
    test('快速连续调用时旧请求结果被丢弃', () async {
      final schema = _schema([
        _field(name: 'field1', asyncKey: 'slow'),
      ]);

      int callCount = 0;
      engine.registerAsyncValidator('slow', (field, value) async {
        callCount++;
        // 模拟慢请求
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return 'error_from_call_$callCount';
      });

      // 连续发起两次异步校验（debounceMs=0 加速测试）
      final future1 = engine.validateFormAsync(
        schema,
        {'field1': 'v1'},
        null,
        debounceMs: 0,
      );
      final future2 = engine.validateFormAsync(
        schema,
        {'field1': 'v2'},
        null,
        debounceMs: 0,
      );

      // 第一次调用应返回空（被竞态丢弃）
      final result1 = await future1;
      final result2 = await future2;

      // 第二次调用的结果应包含错误
      expect(result2!.containsKey('field1'), isTrue);
      // 第一次调用在防抖期间被序列号淘汰，返回 null
      expect(result1, isNull);
    });

    test('注册和移除异步校验策略', () {
      expect(engine.asyncValidatorCount, 0);
      engine.registerAsyncValidator('key1', (f, v) async => null);
      expect(engine.asyncValidatorCount, 1);
      engine.registerAsyncValidators({
        'key2': (f, v) async => null,
        'key3': (f, v) async => null,
      });
      expect(engine.asyncValidatorCount, 3);
      engine.unregisterAsyncValidator('key1');
      expect(engine.asyncValidatorCount, 2);
      engine.clearAsyncValidators();
      expect(engine.asyncValidatorCount, 0);
    });
  });

  group('ParkFormEngine - isFieldVisible / isFieldDisabled', () {
    test('静态 hidden=true 时字段不可见', () {
      final field = _field(name: 'x', hidden: true);
      expect(engine.isFieldVisible(field, {}), isFalse);
    });

    test('只读字段自动禁用', () {
      final field = ParkFormFieldSchema(
        fieldId: 'ro',
        fieldType: ParkFieldType.text,
        labelName: '只读',
        fieldName: 'ro',
        isReadonly: true,
      );
      expect(engine.isFieldDisabled(field, {}), isTrue);
    });

    test('disabledRule 条件匹配时字段禁用', () {
      final field = ParkFormFieldSchema(
        fieldId: 'dep',
        fieldType: ParkFieldType.text,
        labelName: '依赖',
        fieldName: 'dep',
        disabledRule: <String, dynamic>{'field': 'mode', 'equals': 'edit'},
      );
      expect(engine.isFieldDisabled(field, {'mode': 'edit'}), isTrue);
      expect(engine.isFieldDisabled(field, {'mode': 'view'}), isFalse);
    });
  });

  group('ParkFormEngine - exportValues / importValues', () {
    test('DateTime 导出为 ISO8601 字符串', () {
      final dt = DateTime(2024, 6, 15, 10, 30);
      final exported = engine.exportValues({'date': dt});
      expect(exported['date'], isA<String>());
      expect(exported['date'], dt.toIso8601String());
    });

    test('importValues 合并 JSON 到初始值', () {
      final schema = _schema([
        _field(name: 'a'),
        _field(name: 'b'),
      ]);
      final result = engine.importValues(schema, {'a': 'hello'});
      expect(result['a'], 'hello');
      expect(result.containsKey('b'), isTrue);
    });
  });

  group('ParkFormEngine - groupFields', () {
    test('按 groupKey 分组并排序', () {
      final fields = [
        _field(name: 'c'),
        _field(name: 'a'),
        _field(name: 'b'),
      ];
      // 默认 order 都是 0，分组 key 都是 null
      final grouped = engine.groupFields(fields);
      expect(grouped.containsKey(null), isTrue);
      expect(grouped[null]!.length, 3);
    });
  });
}
