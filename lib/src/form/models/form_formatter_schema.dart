/// Formatter 类型枚举。
///
/// 定义运行时可应用的格式化转换类型。
enum FormatterType {
  /// 百分比格式化：12 → 12%。
  percentage,

  /// 千分位格式化：1234567 → 1,234,567。
  thousands,

  /// 千分位分隔符（同 thousands，别名）。
  thousandSeparator,

  /// 无格式化。
  none,
}

/// 显示转换类型枚举。
///
/// 定义运行时可应用的显示转换规则。
enum DisplayTransformType {
  /// 金额大写：数字 → 中文金额大写（如 1234.56 → 壹仟贰佰叁拾肆元伍角陆分）。
  chineseAmount,

  /// 货币格式化：数字 → 货币格式（如 ¥1,234.56）。
  currencyFormat,

  /// 无转换。
  none,
}

/// 后缀模式枚举。
///
/// 定义后缀文本的附加方式。
enum SuffixMode {
  /// 不附加后缀。
  none,

  /// 在值后追加后缀文本。
  append,

  /// 在值前插入前缀文本。
  prepend,
}

/// 字段格式化配置模型。
///
/// 描述字段的 Formatter、后缀和显示转换配置，
/// 用于运行时渲染引擎消费。
class ParkFormFieldFormatterSchema {
  /// 格式化类型。
  final FormatterType formatterType;

  /// 格式化模式（如千分位分隔符、百分比精度）。
  final String formatterPattern;

  /// 后缀模式。
  final SuffixMode suffixMode;

  /// 后缀/前缀文本。
  final String suffixText;

  /// 显示转换类型。
  final DisplayTransformType displayTransform;

  /// 创建字段格式化配置。
  const ParkFormFieldFormatterSchema({
    this.formatterType = FormatterType.none,
    this.formatterPattern = '',
    this.suffixMode = SuffixMode.none,
    this.suffixText = '',
    this.displayTransform = DisplayTransformType.none,
  });

  /// 从 JSON 创建格式化配置。
  factory ParkFormFieldFormatterSchema.fromJson(Map<String, dynamic> json) {
    return ParkFormFieldFormatterSchema(
      formatterType: _parseFormatterType(
        json['formatterType'] as String? ?? 'none',
      ),
      formatterPattern: json['formatterPattern'] as String? ?? '',
      suffixMode: _parseSuffixMode(json['suffixMode'] as String? ?? 'none'),
      suffixText: json['suffixText'] as String? ?? '',
      displayTransform: _parseDisplayTransformType(
        json['displayTransform'] as String? ?? 'none',
      ),
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formatterType': formatterType.name,
      'formatterPattern': formatterPattern,
      'suffixMode': suffixMode.name,
      'suffixText': suffixText,
      'displayTransform': displayTransform.name,
    };
  }

  /// 复制并覆盖部分属性。
  ParkFormFieldFormatterSchema copyWith({
    FormatterType? formatterType,
    String? formatterPattern,
    SuffixMode? suffixMode,
    String? suffixText,
    DisplayTransformType? displayTransform,
  }) {
    return ParkFormFieldFormatterSchema(
      formatterType: formatterType ?? this.formatterType,
      formatterPattern: formatterPattern ?? this.formatterPattern,
      suffixMode: suffixMode ?? this.suffixMode,
      suffixText: suffixText ?? this.suffixText,
      displayTransform: displayTransform ?? this.displayTransform,
    );
  }

  @override
  String toString() {
    return 'ParkFormFieldFormatterSchema(type: $formatterType, '
        'pattern: $formatterPattern, suffix: $suffixMode/$suffixText, '
        'display: $displayTransform)';
  }
}

/// 解析 FormatterType 字符串。
FormatterType _parseFormatterType(String raw) {
  switch (raw) {
    case 'percentage':
      return FormatterType.percentage;
    case 'thousands':
      return FormatterType.thousands;
    case 'thousandSeparator':
    case 'thousand_separator':
      return FormatterType.thousandSeparator;
    case 'none':
    default:
      return FormatterType.none;
  }
}

/// 解析 SuffixMode 字符串。
SuffixMode _parseSuffixMode(String raw) {
  switch (raw) {
    case 'append':
      return SuffixMode.append;
    case 'prepend':
      return SuffixMode.prepend;
    case 'none':
    default:
      return SuffixMode.none;
  }
}

/// 解析 DisplayTransformType 字符串。
DisplayTransformType _parseDisplayTransformType(String raw) {
  switch (raw) {
    case 'chineseAmount':
    case 'chinese_amount':
      return DisplayTransformType.chineseAmount;
    case 'currencyFormat':
    case 'currency_format':
      return DisplayTransformType.currencyFormat;
    case 'none':
    default:
      return DisplayTransformType.none;
  }
}
