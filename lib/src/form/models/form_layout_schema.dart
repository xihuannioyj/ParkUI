import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// 单个字段的标签布局方式。
enum ParkLabelLayout {
  /// label 和控件并排同行。
  inline,

  /// label 在上，控件在下（分行）。
  stacked,
}

/// 解析标签布局字符串。
///
/// [raw] 原始字符串，支持 inline / stacked。
ParkLabelLayout parseLabelLayout(String raw) {
  switch (raw) {
    case 'inline':
      return ParkLabelLayout.inline;
    case 'stacked':
    default:
      return ParkLabelLayout.stacked;
  }
}

/// 表单整体布局配置。
///
/// 控制表单的标签布局方式、间距、分组卡片等展示行为。
/// 每个字段可通过 [ParkFormFieldSchema.labelLayout] 单独覆盖默认行为。
class ParkFormLayout extends Equatable {
  /// 默认标签布局（每个字段可单独覆盖）。
  final ParkLabelLayout defaultLabelLayout;

  /// label 列宽度（inline 模式下生效，默认 80px）。
  final double? labelWidth;

  /// 控件间距（默认 16px）。
  final double gutter;

  /// 表单分组列表。
  final List<ParkFormSectionConfig> sections;

  /// 创建表单布局配置。
  const ParkFormLayout({
    this.defaultLabelLayout = ParkLabelLayout.stacked,
    this.labelWidth,
    this.gutter = 16.0,
    this.sections = const <ParkFormSectionConfig>[],
  });

  /// 从 JSON 创建表单布局配置。
  ///
  /// [json] JSON 对象。
  factory ParkFormLayout.fromJson(Map<String, dynamic> json) {
    final String layoutStr = (json['default_label_layout'] as String?) ??
        (json['defaultLabelLayout'] as String?) ??
        'stacked';
    return ParkFormLayout(
      defaultLabelLayout: parseLabelLayout(layoutStr),
      labelWidth: ((json['label_width'] as num?) ??
              (json['labelWidth'] as num?))
          ?.toDouble(),
      gutter: ((json['gutter'] as num?) ?? 16.0).toDouble(),
      sections: _parseMapList(json['sections'], ParkFormSectionConfig.fromJson),
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'default_label_layout': defaultLabelLayout.name,
      'label_width': labelWidth,
      'gutter': gutter,
      'sections': sections
          .map((ParkFormSectionConfig s) => s.toJson())
          .toList(),
    };
  }

  /// 复制并覆盖部分属性。
  ParkFormLayout copyWith({
    ParkLabelLayout? defaultLabelLayout,
    double? labelWidth,
    double? gutter,
    List<ParkFormSectionConfig>? sections,
  }) {
    return ParkFormLayout(
      defaultLabelLayout: defaultLabelLayout ?? this.defaultLabelLayout,
      labelWidth: labelWidth ?? this.labelWidth,
      gutter: gutter ?? this.gutter,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    defaultLabelLayout,
    labelWidth,
    gutter,
    sections,
  ];
}

/// 表单分组配置（卡片模块）。
///
/// 描述表单中一组字段的容器行为：标题、是否卡片包裹、是否可折叠等。
/// 通过 [fieldIds] 指定该分组包含哪些字段。
class ParkFormSectionConfig extends Equatable {
  /// 分组唯一标识。
  final String key;

  /// 分组标题。
  final String title;

  /// 是否用 Card 包裹。
  final bool card;

  /// 是否可折叠。
  final bool collapsible;

  /// 是否默认折叠。
  final bool defaultCollapsed;

  /// 包含的字段 ID 列表。
  final List<String> fieldIds;

  /// 扩展 UI 配置。
  final Map<String, dynamic>? uiConfig;

  /// 创建分组配置。
  const ParkFormSectionConfig({
    required this.key,
    required this.title,
    this.card = false,
    this.collapsible = false,
    this.defaultCollapsed = false,
    this.fieldIds = const <String>[],
    this.uiConfig,
  });

  /// 从 JSON 创建分组配置。
  ///
  /// [json] JSON 对象。
  factory ParkFormSectionConfig.fromJson(Map<String, dynamic> json) {
    return ParkFormSectionConfig(
      key: (json['key'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      card: (json['card'] as bool?) ?? false,
      collapsible: (json['collapsible'] as bool?) ?? false,
      defaultCollapsed: (json['default_collapsed'] as bool?) ??
          (json['defaultCollapsed'] as bool?) ??
          false,
      fieldIds: (json['field_ids'] as List<dynamic>? ??
              (json['fieldIds'] as List<dynamic>?))
          ?.map((dynamic e) => e.toString())
          .toList() ??
          <String>[],
      uiConfig: _asStringMap(json['ui_config']) ??
          _asStringMap(json['uiConfig']),
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'title': title,
      'card': card,
      'collapsible': collapsible,
      'default_collapsed': defaultCollapsed,
      'field_ids': fieldIds,
      'ui_config': uiConfig,
    };
  }

  /// 复制并覆盖部分属性。
  ParkFormSectionConfig copyWith({
    String? key,
    String? title,
    bool? card,
    bool? collapsible,
    bool? defaultCollapsed,
    List<String>? fieldIds,
    Map<String, dynamic>? uiConfig,
  }) {
    return ParkFormSectionConfig(
      key: key ?? this.key,
      title: title ?? this.title,
      card: card ?? this.card,
      collapsible: collapsible ?? this.collapsible,
      defaultCollapsed: defaultCollapsed ?? this.defaultCollapsed,
      fieldIds: fieldIds ?? this.fieldIds,
      uiConfig: uiConfig ?? this.uiConfig,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    key,
    title,
    card,
    collapsible,
    defaultCollapsed,
    fieldIds,
    uiConfig,
  ];
}

/// 将动态列表安全转为 [T] 列表。
///
/// [list] 非 List 或元素非 Map 时静默跳过（用于 schema fromJson 健壮性守卫）。
List<T> _parseMapList<T>(
  dynamic list,
  T Function(Map<String, dynamic>) f,
) {
  if (list is! List) return <T>[];
  final List<T> result = <T>[];
  for (final dynamic e in list) {
    if (e is Map) {
      result.add(f(Map<String, dynamic>.from(e)));
    } else {
      assert(() {
        debugPrint('[ParkFormSchema] 跳过非 Map 元素: $e');
        return true;
      }());
    }
  }
  return result;
}

/// 将动态值安全转为 String Map，非 Map 返回 null。
Map<String, dynamic>? _asStringMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;
