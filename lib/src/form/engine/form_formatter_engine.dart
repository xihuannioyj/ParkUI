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
  ///
  /// 流水线字符串接力修复（B18a）：
  /// displayTransform 接收原始值（而非上一步格式化结果），
  /// 避免因千分位逗号等符号导致 [double.tryParse] 失败。
  String applyAll(ParkFormFieldFormatterSchema config, dynamic value) {
    if (value == null) return '';
    final String rawStr = value.toString();

    // Step 1: 格式化（千分位、百分比等）。
    final String formatted =
        applyFormatter(config.formatterType, value, config.formatterPattern);

    // Step 2: 显示转换（中文金额、货币）。
    // 使用原始字符串而非格式化后的文本，确保数字解析不受干扰（B18a）。
    final String displayText = config.displayTransform != DisplayTransformType.none
        ? applyDisplayTransform(config.displayTransform, rawStr)
        : formatted;

    // Step 3: 后缀/前缀附加。
    final String result =
        applySuffix(config.suffixMode, displayText, config.suffixText);

    return result;
  }

  /// 百分比格式化。
  ///
  /// [rawValue] 原始数字字符串。
  /// [pattern] 格式化模式（如 '2' 表示保留 2 位小数）。
  static String _formatPercentage(String rawValue, String pattern) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;
    // B125: NaN/Infinity 保护，double.tryParse("NaN") 会成功但后续操作会抛异常。
    if (!numValue.isFinite) return rawValue;
    final int precision = int.tryParse(pattern) ?? 0;
    final String formatted = numValue.toStringAsFixed(precision);
    return '$formatted%';
  }

  /// 千分位格式化。
  ///
  /// [rawValue] 原始数字字符串。
  ///
  /// 修复（B65-Fix3）：先分离符号和绝对值，再分离整数和小数部分。
  /// 小数部分为空或为 "0" 时不追加，避免 `-1234.0` 的小数部分得 `"0"`。
  static String _formatThousands(String rawValue) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;
    // B125: NaN/Infinity 保护。
    if (!numValue.isFinite) return rawValue;
    // 科学计数法保护：极大/极小值的 toString() 会产生 "1.0e-7" 等形式，
    // 后续 split('.') 会将其拆乱，直接返回原始字符串。
    if (rawValue.contains('e') || rawValue.contains('E')) return rawValue;

    // 分离符号和绝对值（B65-Fix3）。
    final bool isNegative = numValue < 0;
    final double absValue = numValue.abs();
    final String absStr = absValue.toString();
    final List<String> parts = absStr.split('.');
    final String intPart = parts[0];
    final String? decPart =
        parts.length > 1 && parts[1] != '0' ? parts[1] : null;

    // 整数部分添加千分位分隔符。
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

    // 拼接符号、整数和小数部分。
    final String sign = isNegative ? '-' : '';
    if (decPart != null && decPart.isNotEmpty) {
      return '$sign$intFormatted.$decPart';
    }
    return '$sign$intFormatted';
  }

  /// 金额大写转换。
  ///
  /// [rawValue] 原始数字字符串。
  ///
  /// 修复（B18b）：
  /// - 负数：先取绝对值转换，再补「负」前缀。
  /// - 超 1 亿丢数位：扩展单位表到万亿级。
  /// - 0 → "零元整"（已有正确处理，此处增强健壮性）。
  static String _formatChineseAmount(String rawValue) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;
    // B125: NaN/Infinity 保护，Infinity.truncate() 会抛 UnsupportedError。
    if (!numValue.isFinite) return rawValue;

    // 负数处理：记录符号，取绝对值格式化（B18b）。
    final bool isNegative = numValue < 0;
    final double absValue = numValue.abs();

    const List<String> digits = <String>[
      '零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖',
    ];
    // 扩展单位表至万亿级（B18b）：
    // 索引 0-3:  个十百千
    // 索引 4:    万
    // 索引 5-7:  十万/百万/千万
    // 索引 8:    亿
    // 索引 9-11: 十亿/百亿/千亿
    // 索引 12:   万亿
    // 索引 13-15: 十万亿/百万亿/千万亿
    const List<String> intUnits = <String>[
      '', '拾', '佰', '仟', '万', '拾', '佰', '仟', '亿',
      '拾', '佰', '仟', '万亿', '拾', '佰', '仟',
    ];
    const List<String> decUnits = <String>['角', '分'];

    // 分离整数和小数部分
    final int intPart = absValue.truncate();
    final int decPart = ((absValue - intPart) * 100).round();

    final StringBuffer buffer = StringBuffer();

    // === 整数部分转换 ===
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
          // 处理连续零：只在遇到非零段之前写一个「零」。
          if (buffer.isNotEmpty && !buffer.toString().endsWith('零')) {
            buffer.write('零');
          }
        }
      }
    }

    // 去除整数部分末尾多余的「零」（如 100000000 → "壹亿零" → "壹亿"）。
    // 仅在 intPart > 0 时进行，否则 intPart == 0 的 "零" 会被清空。
    if (intPart > 0) {
      String intText = buffer.toString();
      while (intText.endsWith('零')) {
        intText = intText.substring(0, intText.length - 1);
      }
      buffer.clear();
      buffer.write(intText);
    }

    // === "元" 单位 ===
    buffer.write('元');

    // === 小数部分转换 ===
    if (decPart == 0) {
      buffer.write('整');
    } else {
      final int jiao = decPart ~/ 10;
      final int fen = decPart % 10;
      if (jiao > 0) {
        buffer.write(digits[jiao]);
        buffer.write(decUnits[0]);
      }
      if (fen > 0) {
        buffer.write(digits[fen]);
        buffer.write(decUnits[1]);
      }
    }

    // 负数补前缀（B18b）。
    String result = buffer.toString();
    if (isNegative) {
      result = '负$result';
    }

    return result;
  }

  /// 货币格式化。
  ///
  /// [rawValue] 原始数字字符串。
  static String _formatCurrency(String rawValue) {
    final double? numValue = double.tryParse(rawValue);
    if (numValue == null) return rawValue;
    // B125: NaN/Infinity 保护。
    if (!numValue.isFinite) return rawValue;
    final String thousands = _formatThousands(numValue.toStringAsFixed(2));
    return '¥$thousands';
  }
}
