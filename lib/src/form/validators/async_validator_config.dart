/// 异步校验器配置与切换逻辑。
///
/// 提供 Mock/Real 双模式配置，控制异步校验器的行为：
/// - [useMockMode]：是否使用 Mock 模式（开发/测试用）
/// - [defaultTimeoutMs]：异步校验超时时间（毫秒）
/// - [debounceMs]：输入防抖延迟时间（毫秒）
class AsyncValidatorConfig {
  /// 是否使用 Mock 模式。
  ///
  /// Mock 模式下，校验器使用内置模拟数据验证，
  /// 适用于开发、测试和演示场景。
  /// Real 模式下，校验器调用真实后端 API。
  final bool useMockMode;

  /// 异步校验默认超时时间（毫秒）。
  ///
  /// 超过此时间未返回结果的校验将被取消，
  /// 并标记为超时错误。
  final int defaultTimeoutMs;

  /// 输入防抖延迟时间（毫秒）。
  ///
  /// 用户输入后等待此时间再触发校验，
  /// 避免频繁请求 API。
  final int debounceMs;

  /// 创建异步校验配置。
  const AsyncValidatorConfig({
    this.useMockMode = true,
    this.defaultTimeoutMs = 5000,
    this.debounceMs = 300,
  });

  /// 默认配置（Mock 模式，5s 超时，300ms 防抖）。
  static const AsyncValidatorConfig defaultConfig = AsyncValidatorConfig();

  /// Mock 模式配置（开发/测试用）。
  static const AsyncValidatorConfig mockConfig = AsyncValidatorConfig(
    useMockMode: true,
    defaultTimeoutMs: 5000,
    debounceMs: 300,
  );

  /// Real 模式配置（生产环境用）。
  static const AsyncValidatorConfig realConfig = AsyncValidatorConfig(
    useMockMode: false,
    defaultTimeoutMs: 5000,
    debounceMs: 300,
  );

  /// 切换到 Mock 模式。
  AsyncValidatorConfig toMockMode() {
    return AsyncValidatorConfig(
      useMockMode: true,
      defaultTimeoutMs: defaultTimeoutMs,
      debounceMs: debounceMs,
    );
  }

  /// 切换到 Real 模式。
  AsyncValidatorConfig toRealMode() {
    return AsyncValidatorConfig(
      useMockMode: false,
      defaultTimeoutMs: defaultTimeoutMs,
      debounceMs: debounceMs,
    );
  }

  /// 复制并替换字段。
  AsyncValidatorConfig copyWith({
    bool? useMockMode,
    int? defaultTimeoutMs,
    int? debounceMs,
  }) {
    return AsyncValidatorConfig(
      useMockMode: useMockMode ?? this.useMockMode,
      defaultTimeoutMs: defaultTimeoutMs ?? this.defaultTimeoutMs,
      debounceMs: debounceMs ?? this.debounceMs,
    );
  }

  @override
  String toString() {
    return 'AsyncValidatorConfig(mock: $useMockMode, '
        'timeout: ${defaultTimeoutMs}ms, debounce: ${debounceMs}ms)';
  }
}
