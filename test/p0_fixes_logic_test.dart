import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 阶段 1 P0 修复定向测试（逻辑层）
///
/// T03：schema fromJson 健壮性（非 Map 元素不抛 CastError，跳过错项）。
/// T04：正则防护（非法 / 嵌套量词 / 超长正则降级为校验失败，不抛异常）。
void main() {
  group('T03 ParkFormSchema.fromJson 健壮性', () {
    test('fields 列表含非 Map 元素时不抛异常并跳过错项', () {
      final json = <String, dynamic>{
        'formKey': 'f1',
        'fields': <dynamic>[
          {
            'field_id': 'a',
            'field_type': 'text',
            'label_name': 'A',
            'field_name': 'a',
          },
          'not_a_map', // 非 Map → 跳过
          42, // 非 Map → 跳过
          {
            'field_id': 'b',
            'field_type': 'text',
            'label_name': 'B',
            'field_name': 'b',
          },
        ],
      };
      final ParkFormSchema schema = ParkFormSchema.fromJson(json);
      expect(schema.fields.length, 2);
      expect(schema.fields[0].fieldId, 'a');
      expect(schema.fields[1].fieldId, 'b');
    });

    test('字段 options 含非 Map 元素时跳过非法项', () {
      final json = <String, dynamic>{
        'formKey': 'f2',
        'fields': <dynamic>[
          {
            'field_id': 's',
            'field_type': 'select',
            'label_name': 'S',
            'field_name': 's',
            'options': <dynamic>[
              {'label': 'X', 'value': '1'},
              'bad', // 非 Map → 跳过
              123, // 非 Map → 跳过
              {'label': 'Y', 'value': '2'},
            ],
          },
        ],
      };
      final ParkFormSchema schema = ParkFormSchema.fromJson(json);
      expect(schema.fields.length, 1);
      expect(schema.fields[0].options.length, 2);
    });

    test('reactions 列表含非 Map 元素时跳过非法项', () {
      final json = <String, dynamic>{
        'formKey': 'f3',
        'fields': <dynamic>[],
        'reactions': <dynamic>[
          {'reaction_id': 'r1', 'trigger_field': 'a'},
          'bad', // 非 Map → 跳过
          {'reaction_id': 'r2', 'trigger_field': 'b'},
        ],
      };
      final ParkFormSchema schema = ParkFormSchema.fromJson(json);
      expect(schema.reactions.length, 2);
    });

    test('layout 为非 Map 时安全降级为 null', () {
      final json = <String, dynamic>{
        'formKey': 'f4',
        'fields': <dynamic>[],
        'layout': 'broken', // 非 Map
      };
      final ParkFormSchema schema = ParkFormSchema.fromJson(json);
      expect(schema.layout, isNull);
    });
  });

  group('T04 FormValidator 正则防护', () {
    ParkFormFieldSchema fieldWithPattern(String pattern) => ParkFormFieldSchema(
          fieldId: 'f',
          fieldType: ParkFieldType.text,
          labelName: 'F',
          fieldName: 'f',
          regexExpression: pattern,
        );

    test('非法正则 "(" 不抛异常且校验失败', () {
      final result = ParkFormValidators.regex('abc', fieldWithPattern('('));
      expect(result.isValid, isFalse);
    });

    test('嵌套量词正则 "(a+)+" 不抛异常且校验失败（防御 ReDoS）', () {
      final result = ParkFormValidators.regex('aaa', fieldWithPattern('(a+)+'));
      expect(result.isValid, isFalse);
    });

    test('超长正则 (>200) 不抛异常且校验失败', () {
      final longPattern = 'a' * 250;
      final result =
          ParkFormValidators.regex('aaa', fieldWithPattern(longPattern));
      expect(result.isValid, isFalse);
    });

    test('合法正则仍可正常校验（命中→通过，未命中→失败）', () {
      const pattern = r'^[0-9]+$';
      expect(
        ParkFormValidators.regex('123', fieldWithPattern(pattern)).isValid,
        isTrue,
      );
      expect(
        ParkFormValidators.regex('abc', fieldWithPattern(pattern)).isValid,
        isFalse,
      );
    });
  });
}
