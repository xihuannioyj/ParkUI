/// FormFormatterEngine 测试
/// 测试数值格式化、负数处理、中文金额

import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  late FormFormatterEngine engine;

  setUp(() {
    engine = const FormFormatterEngine();
  });

  group('FormFormatterEngine - 百分比格式化', () {
    test('整数百分比格式化', () {
      expect(engine.applyFormatter(FormatterType.percentage, 12, '0'), '12%');
    });

    test('小数百分比保留指定精度', () {
      expect(engine.applyFormatter(FormatterType.percentage, 12.345, '2'), '12.35%');
    });

    test('非数字字符串原样返回', () {
      expect(engine.applyFormatter(FormatterType.percentage, 'abc', '2'), 'abc');
    });

    test('null 值返回空字符串', () {
      expect(engine.applyFormatter(FormatterType.percentage, null, '2'), '');
    });
  });

  group('FormFormatterEngine - 千分位格式化', () {
    test('大数字千分位分隔', () {
      expect(engine.applyFormatter(FormatterType.thousands, 1234567, ''), '1,234,567');
    });

    test('小数字不添加分隔符', () {
      expect(engine.applyFormatter(FormatterType.thousands, 999, ''), '999');
    });

    test('负数千分位格式化', () {
      expect(engine.applyFormatter(FormatterType.thousands, -1234567, ''), '-1,234,567');
    });

    test('带小数的千分位格式化', () {
      final result = engine.applyFormatter(FormatterType.thousands, 1234567.89, '');
      expect(result, contains('1,234,567'));
      expect(result, contains('.89'));
    });

    test('thousandSeparator 别名与 thousands 行为一致', () {
      expect(
        engine.applyFormatter(FormatterType.thousandSeparator, 1234567, ''),
        engine.applyFormatter(FormatterType.thousands, 1234567, ''),
      );
    });

    test('none 类型原样返回', () {
      expect(engine.applyFormatter(FormatterType.none, 12345, ''), '12345');
    });
  });

  group('FormFormatterEngine - 中文金额转换', () {
    test('零元整', () {
      expect(
        engine.applyDisplayTransform(DisplayTransformType.chineseAmount, 0),
        '零元整',
      );
    });

    test('整数金额', () {
      final result = engine.applyDisplayTransform(DisplayTransformType.chineseAmount, 100);
      expect(result, contains('元'));
      expect(result, contains('整'));
      expect(result, contains('壹'));
    });

    test('带小数金额（角分）', () {
      final result = engine.applyDisplayTransform(DisplayTransformType.chineseAmount, 1234.56);
      expect(result, contains('元'));
      expect(result, contains('伍'));
      expect(result, contains('陆'));
    });

    test('负数金额添加「负」前缀', () {
      final result = engine.applyDisplayTransform(DisplayTransformType.chineseAmount, -100);
      expect(result, startsWith('负'));
      expect(result, contains('元'));
    });

    test('非数字字符串原样返回', () {
      expect(
        engine.applyDisplayTransform(DisplayTransformType.chineseAmount, 'abc'),
        'abc',
      );
    });
  });

  group('FormFormatterEngine - 货币格式化', () {
    test('货币格式添加 ¥ 前缀和千分位', () {
      final result = engine.applyDisplayTransform(DisplayTransformType.currencyFormat, 1234567.89);
      expect(result, startsWith('¥'));
      expect(result, contains(','));
    });

    test('none 转换原样返回', () {
      expect(
        engine.applyDisplayTransform(DisplayTransformType.none, 12345),
        '12345',
      );
    });
  });

  group('FormFormatterEngine - 后缀/前缀附加', () {
    test('append 模式在值后追加', () {
      expect(engine.applySuffix(SuffixMode.append, 100, '%'), '100%');
    });

    test('prepend 模式在值前插入', () {
      expect(engine.applySuffix(SuffixMode.prepend, 100, '¥'), '¥100');
    });

    test('none 模式不附加', () {
      expect(engine.applySuffix(SuffixMode.none, 100, '%'), '100');
    });

    test('空后缀文本直接返回值', () {
      expect(engine.applySuffix(SuffixMode.append, 100, ''), '100');
    });

    test('null 值返回空字符串', () {
      expect(engine.applySuffix(SuffixMode.append, null, '%'), '');
    });
  });

  group('FormFormatterEngine - applyAll 综合流水线', () {
    test('千分位 + 后缀', () {
      final config = ParkFormFieldFormatterSchema(
        formatterType: FormatterType.thousands,
        suffixMode: SuffixMode.append,
        suffixText: ' 元',
      );
      final result = engine.applyAll(config, 1234567);
      expect(result, contains('1,234,567'));
      expect(result, endsWith(' 元'));
    });

    test('displayTransform 使用原始值而非格式化结果 (B18a)', () {
      final config = ParkFormFieldFormatterSchema(
        formatterType: FormatterType.thousands,
        displayTransform: DisplayTransformType.chineseAmount,
      );
      // displayTransform 应接收原始值 "1234"，而非 "1,234"
      final result = engine.applyAll(config, 1234);
      expect(result, contains('元'));
      expect(result, contains('壹'));
    });

    test('null 值返回空字符串', () {
      final config = ParkFormFieldFormatterSchema(
        formatterType: FormatterType.thousands,
      );
      expect(engine.applyAll(config, null), '');
    });
  });
}
