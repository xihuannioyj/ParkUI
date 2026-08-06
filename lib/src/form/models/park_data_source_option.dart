/// 数据源选项强类型模型（B204）。
///
/// 为 `ParkDataSourceResolver` 的枚举 / 字典 / 缓存数据源提供类型安全的
/// 选项定义，替代裸 `Map<String, dynamic>`，避免运行时才发现
/// `label` / `value` 字段缺失或类型错误。
///
/// 用法：
/// ```dart
/// resolver.registerEnumTyped('status', [
///   ParkDataSourceOption(label: '启用', value: '1'),
///   ParkDataSourceOption(label: '禁用', value: '0', extra: {'color': 'red'}),
/// ]);
/// ```
///
/// 与旧 API 的关系：旧的 `registerEnum(key, List<Map<String, dynamic>>)`
/// 仍然可用（向后兼容）；新代码建议使用 [ParkDataSourceOption] +
/// `registerEnumTyped` 等类型化方法。
class ParkDataSourceOption {
  /// 选项显示文本。
  final String label;

  /// 选项值。
  final String value;

  /// 附加字段（可选）。
  ///
  /// 用于携带 label/value 之外的业务数据（如颜色、图标、禁用标记等），
  /// 序列化为 Map 时会展平到顶层。
  final Map<String, Object?> extra;

  /// 是否禁用该选项。
  final bool disabled;

  /// 创建数据源选项。
  const ParkDataSourceOption({
    required this.label,
    required this.value,
    this.extra = const <String, Object?>{},
    this.disabled = false,
  });

  /// 从 Map 构造（兼容旧数据格式）。
  ///
  /// [map] 需包含 `label` 与 `value` 键；其余键收入 [extra]。
  /// 若 `disabled` 键存在则读取为禁用标记。
  factory ParkDataSourceOption.fromMap(Map<String, dynamic> map) {
    final Map<String, Object?> extra = <String, Object?>{};
    map.forEach((String key, dynamic val) {
      if (key != 'label' && key != 'value' && key != 'disabled') {
        extra[key] = val;
      }
    });
    return ParkDataSourceOption(
      label: map['label']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      disabled: map['disabled'] == true,
      extra: extra,
    );
  }

  /// 序列化为 Map（供旧消费链路使用）。
  ///
  /// 输出 `{'label': ..., 'value': ..., 'disabled': ...}` 并展平 [extra]。
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> result = <String, dynamic>{
      'label': label,
      'value': value,
    };
    if (disabled) {
      result['disabled'] = true;
    }
    result.addAll(extra);
    return result;
  }

  /// 批量从 Map 列表转换。
  static List<ParkDataSourceOption> fromMapList(
    List<Map<String, dynamic>> maps,
  ) {
    return maps.map(ParkDataSourceOption.fromMap).toList();
  }

  /// 批量序列化为 Map 列表。
  static List<Map<String, dynamic>> toMapList(
    List<ParkDataSourceOption> options,
  ) {
    return options.map((ParkDataSourceOption o) => o.toMap()).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkDataSourceOption &&
        other.label == label &&
        other.value == value &&
        other.disabled == disabled;
  }

  @override
  int get hashCode => Object.hash(label, value, disabled);

  @override
  String toString() => 'ParkDataSourceOption($label: $value'
      '${disabled ? ', disabled' : ''})';
}
