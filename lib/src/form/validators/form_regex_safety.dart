/// 表单正则安全工具。
///
/// 统一处理正则表达式的安全性校验，避免灾难性回溯（ReDoS）：
/// - 超过最大长度限制的模式直接拒绝；
/// - 嵌套量词结构（如 `(a+)+`、`(a*)*`、`(a?){n,}`）直接拒绝；
/// - 非法正则语法直接拒绝。
///
/// 所有需要从 JSON schema 或组件外部接收正则的入口都应使用
/// [safeFormRegExp] 或 [trySafeFormRegExp]，而不是直接调用 `RegExp`。
library;

/// 正则最大长度阈值，超过直接视为潜在 ReDoS 风险并拒绝。
const int kParkMaxRegexLength = 200;

/// 危险正则结构：分组内含量词且整体再被量词修饰。
final RegExp _kNestedQuantifier = RegExp(r'\([^()]*[+*?]\)[+*{]');

/// 安全构造 [RegExp]。
///
/// 对危险结构、超长或非法 pattern 返回 null，由调用方降级为校验失败，
/// 避免正则灾难性回溯（ReDoS）导致的卡死或异常。
RegExp? trySafeFormRegExp(String pattern) {
  if (pattern.length > kParkMaxRegexLength) return null;
  if (_kNestedQuantifier.hasMatch(pattern)) return null;
  try {
    return RegExp(pattern);
  } catch (_) {
    return null;
  }
}

/// 安全构造 [RegExp]。
///
/// 与 [trySafeFormRegExp] 相同，但在 pattern 不安全时抛出
/// [ArgumentError]，适用于需要在注册阶段快速失败的场景（如自定义正则注册）。
RegExp safeFormRegExp(String pattern) {
  final RegExp? regExp = trySafeFormRegExp(pattern);
  if (regExp != null) return regExp;
  throw ArgumentError(
    'Potentially dangerous or invalid regex pattern rejected: "$pattern". '
    'Nested quantifiers (e.g. (a+)+) can cause catastrophic backtracking.',
  );
}
