import 'package:equatable/equatable.dart';

/// 表单字段运行时覆盖状态。
///
/// 用于承载 reaction 在运行阶段对字段显隐、禁用、必填的覆盖结果。
/// 当某个字段不存在覆盖值时，应退回静态 schema 规则计算。
class ParkFormRuntimeOverrides extends Equatable {
  /// 字段显示覆盖状态。
  final Map<String, bool> visibleOverrides;

  /// 字段禁用覆盖状态。
  final Map<String, bool> disabledOverrides;

  /// 字段必填覆盖状态。
  final Map<String, bool> requiredOverrides;

  /// 创建运行时覆盖状态。
  const ParkFormRuntimeOverrides({
    this.visibleOverrides = const <String, bool>{},
    this.disabledOverrides = const <String, bool>{},
    this.requiredOverrides = const <String, bool>{},
  });

  /// 读取字段显示覆盖值。
  bool? visibleOf(String fieldName) => visibleOverrides[fieldName];

  /// 读取字段禁用覆盖值。
  bool? disabledOf(String fieldName) => disabledOverrides[fieldName];

  /// 读取字段必填覆盖值。
  bool? requiredOf(String fieldName) => requiredOverrides[fieldName];

  /// 判断是否不存在任何覆盖。
  bool get isEmpty =>
      visibleOverrides.isEmpty &&
      disabledOverrides.isEmpty &&
      requiredOverrides.isEmpty;

  /// 复制并覆盖部分属性。
  ParkFormRuntimeOverrides copyWith({
    Map<String, bool>? visibleOverrides,
    Map<String, bool>? disabledOverrides,
    Map<String, bool>? requiredOverrides,
  }) {
    return ParkFormRuntimeOverrides(
      visibleOverrides: visibleOverrides ?? this.visibleOverrides,
      disabledOverrides: disabledOverrides ?? this.disabledOverrides,
      requiredOverrides: requiredOverrides ?? this.requiredOverrides,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    visibleOverrides,
    disabledOverrides,
    requiredOverrides,
  ];
}

/// reaction 执行结果。
///
/// 包含执行后得到的最新表单值、运行时覆盖状态，以及需要重载选项的目标字段。
class ParkFormReactionExecutionResult extends Equatable {
  /// 执行后的表单值。
  final Map<String, dynamic> values;

  /// 执行后的运行时覆盖状态。
  final ParkFormRuntimeOverrides overrides;

  /// 本轮受影响的字段。
  ///
  /// 包含初始触发字段，以及被 set_value / clear_value 级联改动的字段。
  final Set<String> affectedFields;

  /// 需要重新加载选项的字段。
  final Set<String> reloadFields;

  /// 创建 reaction 执行结果。
  const ParkFormReactionExecutionResult({
    required this.values,
    required this.overrides,
    this.affectedFields = const <String>{},
    this.reloadFields = const <String>{},
  });

  @override
  List<Object?> get props => <Object?>[
    values,
    overrides,
    affectedFields,
    reloadFields,
  ];
}
