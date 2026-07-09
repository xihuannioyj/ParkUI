import 'form_validator_result.dart';
import '../models/form_field_schema.dart';

/// 正则最大长度阈值，超过直接视为潜在 ReDoS 风险并拒绝。
const int _kMaxRegexLength = 200;

/// 危险正则结构：分组内含量词且整体再被量词修饰
/// （如 `(a+)+`、`(a*)*`、`(a?)+`、`(.+){n,}` 等）。
final RegExp _kNestedQuantifier = RegExp(r'\([^()]*[+*?]\)[+*{]');

/// 安全构造 [RegExp]。
///
/// 对危险结构、超长或非法 pattern 返回 null，由调用方降级为校验失败，
/// 避免正则灾难性回溯（ReDoS）导致的卡死或异常。
RegExp? _safeRegExp(String pattern) {
  if (pattern.length > _kMaxRegexLength) return null;
  if (_kNestedQuantifier.hasMatch(pattern)) return null;
  try {
    return RegExp(pattern);
  } catch (_) {
    return null;
  }
}

/// 表单校验器集合。
///
/// 提供必填、长度、正则三个同步校验器，
/// 每个校验器返回 [FormValidatorResult]。
class ParkFormValidators {
  /// 必填校验。
  ///
  /// [value] 当前值。
  /// [field] 字段定义。
  static FormValidatorResult required(
    dynamic value,
    ParkFormFieldSchema field,
  ) {
    if (!field.isRequired) {
      return FormValidatorResult.success();
    }

    if (value == null) {
      return FormValidatorResult.error(
        field.validatorMessage ?? '${field.labelName}不能为空',
      );
    }

    if (value is String && value.trim().isEmpty) {
      return FormValidatorResult.error(
        field.validatorMessage ?? '${field.labelName}不能为空',
      );
    }

    if (value is List<dynamic> && value.isEmpty) {
      return FormValidatorResult.error(
        field.validatorMessage ?? '${field.labelName}不能为空',
      );
    }

    return FormValidatorResult.success();
  }

  /// 文本长度校验。
  ///
  /// [value] 当前值。
  /// [field] 字段定义。
  static FormValidatorResult length(dynamic value, ParkFormFieldSchema field) {
    if (value == null || value is! String || value.isEmpty) {
      return FormValidatorResult.success();
    }

    final int length = value.length;

    // field_length 视为 maxLength 的快捷写法。
    final int? effectiveMax = field.maxLength ??
        (field.fieldLength > 0 ? field.fieldLength : null);

    if (field.minLength != null && length < field.minLength!) {
      return FormValidatorResult.error(
        '${field.labelName}长度不能小于${field.minLength}',
      );
    }
    if (effectiveMax != null && length > effectiveMax) {
      return FormValidatorResult.error(
        '${field.labelName}长度不能大于$effectiveMax',
      );
    }
    return FormValidatorResult.success();
  }

  /// 正则校验。
  ///
  /// [value] 当前值。
  /// [field] 字段定义（需已注入 resolved regex）。
  static FormValidatorResult regex(dynamic value, ParkFormFieldSchema field) {
    final String? pattern = field.regexExpression;
    if (pattern == null || pattern.isEmpty) {
      return FormValidatorResult.success();
    }
    if (value == null || value is! String || value.isEmpty) {
      return FormValidatorResult.success();
    }

    final RegExp? regExp = _safeRegExp(pattern);
    if (regExp == null) {
      return FormValidatorResult.error('格式校验规则无效');
    }
    if (!regExp.hasMatch(value)) {
      return FormValidatorResult.error(
        field.validatorMessage ?? '${field.labelName}格式不正确',
      );
    }
    return FormValidatorResult.success();
  }
}
