import 'package:flutter/material.dart';

/// Park 组件属性定义。
class ParkPropertyDef {
  /// 属性名称。
  final String name;

  /// 属性类型（如 'String'、'bool'、'VoidCallback?'）。
  final String type;

  /// 默认值文本。
  final String defaultVal;

  /// 属性说明。
  final String description;

  /// 是否为必填参数。
  final bool required;

  /// 创建属性定义。
  const ParkPropertyDef({
    required this.name,
    required this.type,
    this.defaultVal = '-',
    this.description = '',
    this.required = false,
  });
}

/// Park 组件事件/回调定义。
class ParkEventDef {
  /// 事件名称。
  final String name;

  /// 事件签名（如 'ValueChanged<String>'）。
  final String signature;

  /// 事件说明。
  final String description;

  /// 创建事件定义。
  const ParkEventDef({
    required this.name,
    required this.signature,
    this.description = '',
  });
}

/// Park 组件方法定义。
class ParkMethodDef {
  /// 方法名称。
  final String name;

  /// 方法签名。
  final String signature;

  /// 方法说明。
  final String description;

  /// 创建方法定义。
  const ParkMethodDef({
    required this.name,
    required this.signature,
    this.description = '',
  });
}

/// Park 组件交互案例。
class ParkDemoScenario {
  /// 案例标题。
  final String title;

  /// 案例描述。
  final String description;

  /// 案例代码文本。
  final String code;

  /// 案例渲染器。
  final Widget Function(BuildContext context) builder;

  /// 创建交互案例。
  const ParkDemoScenario({
    required this.title,
    required this.description,
    required this.code,
    required this.builder,
  });
}

/// Park 组件完整规格。
class ParkComponentSpec {
  /// 组件类名（如 'ParkButton'）。
  final String name;

  /// 中文标题（如 '按钮'）。
  final String title;

  /// 所属分类：base / input / nav / display / feedback / form。
  final String category;

  /// 功能描述。
  final String description;

  /// 图标。
  final IconData icon;

  /// 构造器属性列表。
  final List<ParkPropertyDef> properties;

  /// 事件/回调列表。
  final List<ParkEventDef> events;

  /// 静态方法列表。
  final List<ParkMethodDef> methods;

  /// 交互案例列表。
  final List<ParkDemoScenario> demos;

  /// 基础用法代码片段。
  final String basicUsageCode;

  /// 使用指南（Markdown 格式文本）。
  final String guide;

  /// Schema 属性详解（Markdown 格式，支持表格；渲染于 API Tab）。
  final String schemaDoc;

  /// 动态表单 Schema 属性详解（Markdown，按组件视角；仅非空时渲染于 API Tab「方法」之后）。
  final String dynamicFormSchemaDoc;

  /// 创建组件规格。
  const ParkComponentSpec({
    required this.name,
    required this.title,
    required this.category,
    required this.description,
    this.icon = Icons.widgets_outlined,
    this.properties = const <ParkPropertyDef>[],
    this.events = const <ParkEventDef>[],
    this.methods = const <ParkMethodDef>[],
    this.demos = const <ParkDemoScenario>[],
    this.basicUsageCode = '',
    this.guide = '',
    this.schemaDoc = '',
    this.dynamicFormSchemaDoc = '',
  });
}
