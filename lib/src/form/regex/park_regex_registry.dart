/// 正则标签注册表。
///
/// 将常用正则表达式按标签名注册，表单字段通过 [regexTag] 引用，
/// 避免在 JSON 配置中硬编码复杂正则字符串。
///
/// 用法：
/// ```dart
/// final pattern = ParkRegexRegistry.get('mobile');
/// ```
class ParkRegexRegistry {
  /// 内置正则标签表。
  static final Map<String, _RegexEntry> _registry = <String, _RegexEntry>{
    'mobile': _RegexEntry(
      pattern: r'^1[3-9]\d{9}$',
      description: '中国大陆手机号',
    ),
    'email': _RegexEntry(
      pattern: r'^[\w.+-]+@[\w-]+\.[\w.]+$',
      description: '电子邮箱',
    ),
    'id_card': _RegexEntry(
      pattern: r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])'
          r'(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
      description: '中国身份证号（18位）',
    ),
    'cn_name': _RegexEntry(
      pattern: r'^[\u4e00-\u9fa5]{2,20}$',
      description: '中文姓名（2-20字）',
    ),
    'url': _RegexEntry(
      pattern: r'^https?://[\w\-]+(\.[\w\-]+)+([\w.,@?^=%&:/~+#\-]*'
          r'[\w@?^=%&/~+#\-])?$',
      description: 'HTTP/HTTPS 链接',
    ),
    'ipv4': _RegexEntry(
      pattern: r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}'
          r'(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
      description: 'IPv4 地址',
    ),
    'postal_code': _RegexEntry(
      pattern: r'^[1-9]\d{5}$',
      description: '中国邮政编码',
    ),
    'bank_card': _RegexEntry(
      pattern: r'^[1-9]\d{15,18}$',
      description: '银行卡号（16-19位）',
    ),
    'username': _RegexEntry(
      pattern: r'^[a-zA-Z]\w{5,19}$',
      description: '用户名（字母开头，6-20位字母数字下划线）',
    ),
    'password': _RegexEntry(
      pattern: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[\s\S]{8,}$',
      description: '密码（至少8位，含大小写字母和数字）',
    ),
    'number': _RegexEntry(
      pattern: r'^-?\d+(\.\d+)?$',
      description: '整数或小数',
    ),
    'integer': _RegexEntry(
      pattern: r'^-?\d+$',
      description: '整数',
    ),
    'positive_int': _RegexEntry(
      pattern: r'^[1-9]\d*$',
      description: '正整数',
    ),
    'amount': _RegexEntry(
      pattern: r'^(0|[1-9]\d*)(\.\d{1,2})?$',
      description: '金额（最多两位小数）',
    ),
    'date': _RegexEntry(
      pattern: r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
      description: '日期（YYYY-MM-DD）',
    ),
    'time': _RegexEntry(
      pattern: r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$',
      description: '时间（HH:mm 或 HH:mm:ss）',
    ),
    'chinese': _RegexEntry(
      pattern: r'^[\u4e00-\u9fa5]+$',
      description: '纯中文字符',
    ),
    'qq': _RegexEntry(
      pattern: r'^[1-9]\d{4,10}$',
      description: 'QQ 号（5-11位）',
    ),
    'wechat': _RegexEntry(
      pattern: r'^[a-zA-Z][\w\-]{5,19}$',
      description: '微信号',
    ),
    'plate_number': _RegexEntry(
      pattern: r'^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤'
          r'川青藏琼宁][A-Z][A-HJ-NP-Z0-9]{4,5}[A-HJ-NP-Z0-9挂学警港澳]$',
      description: '中国车牌号',
    ),
    'unified_credit_code': _RegexEntry(
      pattern: r'^[0-9A-HJ-NPQRTUWXY]{2}\d{6}[0-9A-HJ-NPQRTUWXY]{10}$',
      description: '统一社会信用代码（18位）',
    ),
  };

  /// 获取标签对应的正则表达式字符串。
  ///
  /// [tag] 正则标签名。
  /// 返回 null 表示标签不存在。
  static String? get(String tag) {
    return _registry[tag]?.pattern;
  }

  /// 获取标签对应的描述文本。
  ///
  /// [tag] 正则标签名。
  /// 返回 null 表示标签不存在。
  static String? getDescription(String tag) {
    return _registry[tag]?.description;
  }

  /// 检查标签是否已注册。
  ///
  /// [tag] 正则标签名。
  static bool has(String tag) {
    return _registry.containsKey(tag);
  }

  /// 注册自定义正则标签。
  ///
  /// [tag] 标签名。
  /// [pattern] 正则表达式字符串。
  /// [description] 标签描述。
  static void register(String tag, String pattern, {String? description}) {
    _registry[tag] = _RegexEntry(
      pattern: pattern,
      description: description ?? tag,
    );
  }

  /// 移除已注册的正则标签。
  ///
  /// [tag] 标签名。
  static void unregister(String tag) {
    _registry.remove(tag);
  }

  /// 获取所有已注册标签名。
  static List<String> get allTags => _registry.keys.toList();

  /// 获取所有标签及其描述。
  static Map<String, String> get tagDescriptions {
    return _registry.map(
      (String key, _RegexEntry entry) =>
          MapEntry<String, String>(key, entry.description),
    );
  }
}

/// 正则条目（内部类）。
class _RegexEntry {
  /// 正则表达式字符串。
  final String pattern;

  /// 标签描述。
  final String description;

  /// 创建正则条目。
  const _RegexEntry({required this.pattern, required this.description});
}
