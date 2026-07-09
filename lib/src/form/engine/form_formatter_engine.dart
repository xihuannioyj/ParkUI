import '../models/form_formatter_schema.dart';

/// Formatter / displayTransform 运行时引擎。
///
/// 负责在运行时渲染阶段对字段值应用格式化、
/// 显示转换和后缀附加操作。
///
/// 消费 [ParkFormFieldFormatterSchema] 配置，
/// 将原始字段值转换为用户可读的展示文本。
class FormFormatterEngine {
  /// 创建格式化引擎。
  const FormFormatterEngine();

  /// 应用格式化转换。
  ///
  /// [formatterType] 格式化类型。
  /// [value] 原始值。
  /// [pattern] 格式化模式（如千分位分隔符、百分比精度）。
  /// 返回格式化后的文本。
  String applyFormatter(FormatterType formatterType, dynamic value, String pattern) {
    if (value == null) return '';
    final String rawValue = value.toString();

    switch (formatterType) {
      case FormatterType.percentage:
        return _formatPercentage(rawValue, pattern);
      case FormatterType.thousands:
      case FormatterType.thousandSeparator:
        return _formatThousands(rawValue);
      case FormatterType.none:
        return rawValue;
    }
  }

  /// 应用显示转换。
  ///
  /// [transformType] 显示转换类型。
  /// [value] 原始值。
  /// 返回转换后的文本。
  String applyDisplayTransform(DisplayTransformType transformType, dynamic value) {
    if (value == null) return '';
    final String rawValue = value.toString();

    switch (transformType) {
      case DisplayTransformType.chineseAmount:
        return _formatChineseAmount(rawValue);
      case DisplayTransformType.currencyFormat:
        return _formatCurrency(rawValue);
      case DisplayTransformType.none:
        return rawValue;
    }
  }

  /// 应用后缀/前缀附加。
  ///
  /// [suffixMode] 后缀模式。
  /// [value] 原始值。
  /// [suffixText] 后缀文本。
  /// 返回附加后的文本。
  String applySuffix(SuffixMode suffixMode, dynamic value, String suffixText) {
    if (value == null) return '';
    if (suffixText.isEmpty) return value.toString();

    switch (suffixMode) {
      case SuffixMode.append:
        return '${value}$suffixText';
      case SuffixMode.prepend:
        return '$suffixText$value';
      case SuffixMode.none:
        return value.toString();
    }
  }

  /// 综合格式化：按 formatterType → displayTransform → suffixMode 顺序应用。
  ///
  /// [config] 格式化配置。
  /// [value] 原始值。
  /// 返回最终展示文本。
  String applyAll(ParkFormFieldFormatterSchema config, dynamic value) {
    String result = applyFormatter(config.formatterType, value, config.formatterPattern);
    result = applyDisplayTransform(config.displayTransform, result);
    result = applySuffix(config.suffixMode, result, config.suffixText);
    return result;
  }

  /// 百分比格式化。
  ///
  /// [rawValue] 原始数字字符串。
  /// [pattern] 格式化模式（如 '2' 表示保留 2 位小数）。
  static String _formatPercentage(String rawValue, String pattern) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;
    final int precision = int.tryParse(pattern) ?? 0;
    final String formatted = numValue.toStringAsFixed(precision);
    return '$formatted%';
  }

  /// 千分位格式化。
  ///
  /// [rawValue] 原始数字字符串。
  static String _formatThousands(String rawValue) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;

    // 分离整数和小数部分
    final String intPart = numValue.truncate().toString();
    final String decPart = numValue.toString().contains('.')
        ? numValue.toString().split('.').last
        : '';

    // 整数部分添加千分位分隔符
    final StringBuffer buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      buffer.write(intPart[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }

    final String reversed = buffer.toString();
    final String intFormatted = reversed.split('').reversed.join();

    if (decPart.isNotEmpty) {
      return '$intFormatted.$decPart';
    }
    return intFormatted;
  }

  /// 金额大写转换。
  ///
  /// [rawValue] 原始数字字符串。
  static String _formatChineseAmount(String rawValue) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;

    const List<String> digits = <String>['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];
    const List<String> intUnits = <String>['', '拾', '佰', '仟', '万', '拾', '佰', '仟', '亿'];
    const List<String> decUnits = <String>['角', '分'];

    // 分离整数和小数部分
    final int intPart = numValue.truncate();
    final int decPart = ((numValue - intPart) * 100).round();

    final StringBuffer buffer = StringBuffer();

    // 整数部分转换
    if (intPart == 0) {
      buffer.write('零');
    } else {
      final String intStr = intPart.toString();
      for (int i = 0; i < intStr.length; i++) {
        final int digit = int.tryParse(intStr[i]) ?? 0;
        final int unitIndex = intStr.length - 1 - i;
        if (digit != 0) {
          buffer.write(digits[digit]);
          if (unitIndex < intUnits.length) {
            buffer.write(intUnits[unitIndex]);
          }
        } else {
          // 处理连续零
          if (buffer.isEmpty || !buffer.toString().endsWith('零')) {
            buffer.write('零');
          }
        }
      }
    }
    buffer.write('元');

    // 小数部分转换
    if (decPart == 0) {
      buffer.write('整');
    } else {
      final int jiao = decPart ~/ 10;
      final int fen = decPart % 10;
      if (jiao > 0) {
        buffer.write(digits[jiao.toInt()]);
        buffer.write(decUnits[0]);
      }
      if (fen > 0) {
        buffer.write(digits[fen]);
        buffer.write(decUnits[1]);
      }
    }

    return buffer.toString();
  }

  /// 货币格式化。
  ///
  /// [rawValue] 原始数字字符串。
  static String _formatCurrency(String rawValue) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;
    final String thousands = _formatThousands(numValue.toStringAsFixed(2));
    return '¥$thousands';
  }
}
