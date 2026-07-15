import 'async_validator_config.dart';
import '../models/form_field_schema.dart';

/// 用户名唯一性异步校验器。
///
/// key="username_unique"
/// Mock 模式：若值为 "admin" 或 "test_user" 返回"用户名已存在"，否则通过。
/// Real 模式：调用后端 API 校验用户名唯一性。
///
/// 注意（B19 / 开发文档.md §7.10）：[realValidate] 为占位实现，真实后端接入前
/// 不得静默通过。当前显式抛 [UnimplementedError]，强制调用方先完成后端对接，
/// 避免「未实现却返回通过」导致的隐蔽数据风险。
class UsernameUniqueValidator {
  /// 校验器注册键。
  static const String key = 'username_unique';

  /// 校验配置。
  final AsyncValidatorConfig config;

  /// 创建用户名唯一性校验器。
  UsernameUniqueValidator({AsyncValidatorConfig? config})
      : config = config ?? AsyncValidatorConfig.defaultConfig;

  /// 执行校验。
  ///
  /// [field] 字段定义。
  /// [value] 当前值。
  /// 根据 [config.useMockMode] 路由到 mock 或 real 校验。
  Future<String?> validate(ParkFormFieldSchema field, dynamic value) async {
    if (config.useMockMode) {
      return mockValidate(field, value);
    }
    return realValidate(field, value);
  }

  /// Mock 校验逻辑。
  ///
  /// 模拟已存在的用户名列表，返回校验结果。
  Future<String?> mockValidate(ParkFormFieldSchema field, dynamic value) async {
    // 模拟网络延迟
    await Future<void>.delayed(
      Duration(milliseconds: config.debounceMs),
    );

    if (value == null || value.toString().isEmpty) {
      return null;
    }

    final String username = value.toString().trim();
    const List<String> existingUsernames = <String>[
      'admin',
      'test_user',
      'root',
      'superadmin',
    ];

    if (existingUsernames.contains(username.toLowerCase())) {
      return '用户名已存在';
    }
    return null;
  }

  /// Real 校验逻辑。
  ///
  /// 调用后端 API 校验用户名唯一性。
  /// 占位实现：真实后端接入前显式抛 [UnimplementedError]，不静默通过
  /// （B19 / 开发文档.md §7.10）。
  Future<String?> realValidate(ParkFormFieldSchema field, dynamic value) async {
    // 占位实现：真实后端 API 接入前不得静默返回通过。
    // TODO: 接入真实 API 后替换为实际校验逻辑。
    throw UnimplementedError(
      'UsernameUniqueValidator.realValidate 尚未接入真实后端，'
      '请先实现用户名唯一性校验 API（config.useMockMode=false 时调用）。',
    );
  }
}

/// 邮箱唯一性异步校验器。
///
/// key="email_unique"
/// Mock 模式：若值为特定已注册邮箱返回"邮箱已注册"，否则通过。
/// Real 模式：调用后端 API 校验邮箱唯一性。
///
/// 注意（B19 / 开发文档.md §7.10）：[realValidate] 为占位实现，真实后端接入前
/// 不得静默通过。当前显式抛 [UnimplementedError]，强制调用方先完成后端对接。
class EmailUniqueValidator {
  /// 校验器注册键。
  static const String key = 'email_unique';

  /// 校验配置。
  final AsyncValidatorConfig config;

  /// 创建邮箱唯一性校验器。
  EmailUniqueValidator({AsyncValidatorConfig? config})
      : config = config ?? AsyncValidatorConfig.defaultConfig;

  /// 执行校验。
  Future<String?> validate(ParkFormFieldSchema field, dynamic value) async {
    if (config.useMockMode) {
      return mockValidate(field, value);
    }
    return realValidate(field, value);
  }

  /// Mock 校验逻辑。
  Future<String?> mockValidate(ParkFormFieldSchema field, dynamic value) async {
    await Future<void>.delayed(
      Duration(milliseconds: config.debounceMs),
    );

    if (value == null || value.toString().isEmpty) {
      return null;
    }

    final String email = value.toString().trim();
    const List<String> existingEmails = <String>[
      'admin@example.com',
      'test@example.com',
      'user@park.com',
    ];

    if (existingEmails.contains(email.toLowerCase())) {
      return '邮箱已注册';
    }
    return null;
  }

  /// Real 校验逻辑。
  ///
  /// 调用后端 API 校验邮箱唯一性。
  /// 占位实现：真实后端接入前显式抛 [UnimplementedError]，不静默通过
  /// （B19 / 开发文档.md §7.10）。
  Future<String?> realValidate(ParkFormFieldSchema field, dynamic value) async {
    // 占位实现：真实后端 API 接入前不得静默返回通过。
    // TODO: 接入真实 API 后替换为实际校验逻辑。
    throw UnimplementedError(
      'EmailUniqueValidator.realValidate 尚未接入真实后端，'
      '请先实现邮箱唯一性校验 API（config.useMockMode=false 时调用）。',
    );
  }
}

/// 身份证号格式异步校验器。
///
/// key="id_card_format"
/// Mock 模式：校验身份证号长度和基本格式，返回"身份证号格式错误"或 null。
/// Real 模式：调用后端 API 校验身份证号合法性。
///
/// 注意（B19 / 开发文档.md §7.10）：[realValidate] 为占位实现，真实后端接入前
/// 不得静默通过。当前显式抛 [UnimplementedError]，强制调用方先完成后端对接。
class IdCardFormatValidator {
  /// 校验器注册键。
  static const String key = 'id_card_format';

  /// 校验配置。
  final AsyncValidatorConfig config;

  /// 创建身份证号格式校验器。
  IdCardFormatValidator({AsyncValidatorConfig? config})
      : config = config ?? AsyncValidatorConfig.defaultConfig;

  /// 执行校验。
  Future<String?> validate(ParkFormFieldSchema field, dynamic value) async {
    if (config.useMockMode) {
      return mockValidate(field, value);
    }
    return realValidate(field, value);
  }

  /// Mock 校验逻辑。
  ///
  /// 校验身份证号格式：18 位，前 17 位为数字，第 18 位为数字或 X。
  Future<String?> mockValidate(ParkFormFieldSchema field, dynamic value) async {
    await Future<void>.delayed(
      Duration(milliseconds: config.debounceMs),
    );

    if (value == null || value.toString().isEmpty) {
      return null;
    }

    final String idCard = value.toString().trim();

    // 18 位身份证号格式校验
    if (idCard.length != 18) {
      return '身份证号格式错误（应为18位）';
    }

    // 前 17 位应为数字
    final String first17 = idCard.substring(0, 17);
    if (!RegExp(r'^\d{17}$').hasMatch(first17)) {
      return '身份证号格式错误（前17位应为数字）';
    }

    // 第 18 位应为数字或 X/x
    final String lastChar = idCard.substring(17);
    if (!RegExp(r'^[\dXx]$').hasMatch(lastChar)) {
      return '身份证号格式错误（第18位应为数字或X）';
    }

    return null;
  }

  /// Real 校验逻辑。
  ///
  /// 调用后端 API 校验身份证号合法性。
  /// 占位实现：真实后端接入前显式抛 [UnimplementedError]，不静默通过
  /// （B19 / 开发文档.md §7.10）。
  Future<String?> realValidate(ParkFormFieldSchema field, dynamic value) async {
    // 占位实现：真实后端 API 接入前不得静默返回通过。
    // TODO: 接入真实 API 后替换为实际校验逻辑。
    throw UnimplementedError(
      'IdCardFormatValidator.realValidate 尚未接入真实后端，'
      '请先实现身份证号合法性校验 API（config.useMockMode=false 时调用）。',
    );
  }
}
