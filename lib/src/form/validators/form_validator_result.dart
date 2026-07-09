/// 表单校验结果。
class FormValidatorResult {
  /// 是否校验通过。
  final bool isValid;

  /// 错误信息。
  final String? message;

  /// 创建校验结果。
  const FormValidatorResult._({required this.isValid, this.message});

  /// 创建成功结果。
  factory FormValidatorResult.success() =>
      const FormValidatorResult._(isValid: true);

  /// 创建失败结果。
  ///
  /// [message] 失败原因。
  factory FormValidatorResult.error(String message) =>
      FormValidatorResult._(isValid: false, message: message);
}
