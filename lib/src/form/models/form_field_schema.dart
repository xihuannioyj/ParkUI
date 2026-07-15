import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'form_formatter_schema.dart';
import 'form_layout_schema.dart';

/// 动态表单字段控件类型。
///
/// 决定渲染时使用哪种 Park UI 控件。
enum ParkFieldType {
  /// 单行文本。
  text,

  /// 多行文本。
  textarea,

  /// 数字输入。
  number,

  /// 下拉选择。
  select,

  /// 单选组。
  radio,

  /// 多选组。
  checkbox,

  /// 开关。
  toggle,

  /// 日期选择。
  date,

  /// 图片选择（含裁剪）。
  image,

  /// 扫码输入。
  scanner,

  /// 地区级联选择。
  region,

  /// 滑杆。
  slider,

  /// 步进器。
  stepper,

  /// 评分。
  rate,

  /// 级联选择。
  cascader,

  /// 树形选择。
  treeSelect,

  /// 选择器（底部弹出）。
  picker,

  /// 搜索框。
  search,

  /// 文件上传。
  upload,

  /// 富文本。
  richText,
}

/// 数据源类型。
///
/// 描述字段选项数据的来源方式。
enum ParkDataSourceType {
  /// 无外部数据源。
  none,

  /// 静态选项（直接写在 JSON 的 options 中）。
  staticOptions,

  /// 枚举类型（通过 data_source_key 映射到本地枚举）。
  enumSource,

  /// 字典类型（通过 data_source_key 映射到本地字典表）。
  dict,

  /// 异步接口请求（通过 data_source_key 映射到 API 地址）。
  api,

  /// 缓存数据（如缓存的用户列表、职位列表等）。
  cache,
}

/// reaction 触发事件类型。
///
/// 当前先支持字段值变更时触发，后续可继续扩展 blur、init 等事件。
enum ParkFormTriggerEvent {
  /// 字段值变化时触发。
  change,
}

/// reaction 动作类型。
///
/// 用于描述命中条件后要对目标字段执行的运行时动作。
enum ParkFormReactionActionType {
  /// 设置目标字段显示状态。
  setVisible,

  /// 设置目标字段禁用状态。
  setDisabled,

  /// 设置目标字段必填状态。
  setRequired,

  /// 为目标字段写入值。
  setValue,

  /// 清空目标字段值。
  clearValue,

  /// 重新加载目标字段选项。
  reloadOptions,
}

/// 字段 UI 配置。
///
/// 包含控件的视觉与交互细节，如前缀、后缀、行数、高度等。
class ParkFieldUiConfig extends Equatable {
  /// 输入框前缀文本。
  final String? prefix;

  /// 输入框后缀文本。
  final String? suffix;

  /// 多行文本行数（textarea / richText）。
  final int rows;

  /// 控件高度（像素），0 表示使用默认高度。
  final double height;

  /// 是否显示字数统计。
  final bool showCount;

  /// 是否附带操作按钮（如日期选择器的日历按钮）。
  final bool actionButton;

  /// 创建 UI 配置。
  const ParkFieldUiConfig({
    this.prefix,
    this.suffix,
    this.rows = 1,
    this.height = 0,
    this.showCount = false,
    this.actionButton = false,
  });

  /// 从 JSON 创建 UI 配置。
  ///
  /// [json] JSON 对象。
  factory ParkFieldUiConfig.fromJson(Map<String, dynamic> json) {
    return ParkFieldUiConfig(
      prefix: json['prefix'] as String?,
      suffix: json['suffix'] as String?,
      rows: (json['rows'] as int?) ?? (json['text_high'] as int?) ?? 1,
      height: ((json['height'] as num?) ?? 0).toDouble(),
      showCount: (json['show_count'] as bool?) ?? false,
      actionButton: (json['action_button'] as bool?) ??
          (json['button'] as bool?) ??
          false,
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prefix': prefix,
      'suffix': suffix,
      'rows': rows,
      'height': height,
      'show_count': showCount,
      'action_button': actionButton,
    };
  }

  /// 复制并覆盖部分属性。
  ///
  /// [prefix] 前缀文本。
  /// [suffix] 后缀文本。
  /// [rows] 行数。
  /// [height] 高度。
  /// [showCount] 是否显示字数。
  /// [actionButton] 是否显示按钮。
  ParkFieldUiConfig copyWith({
    String? prefix,
    String? suffix,
    int? rows,
    double? height,
    bool? showCount,
    bool? actionButton,
  }) {
    return ParkFieldUiConfig(
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      rows: rows ?? this.rows,
      height: height ?? this.height,
      showCount: showCount ?? this.showCount,
      actionButton: actionButton ?? this.actionButton,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    prefix,
    suffix,
    rows,
    height,
    showCount,
    actionButton,
  ];
}

/// 动态表单字段结构。
///
/// 描述单个表单字段的完整元信息，包括控件类型、校验规则、
/// 数据源、联动规则、UI 配置等。支持 JSON 序列化与反序列化。
///
/// JSON 协议同时兼容新版命名（如 `field_id`、`field_type`）
/// 与旧版命名（如 `key`、`type`）。
class ParkFormFieldSchema extends Equatable {
  /// 字段稳定唯一 ID（设计器拖拽、版本 diff 用）。
  final String fieldId;

  /// 字段控件类型。
  final ParkFieldType fieldType;

  /// 控件子类型（field_type 的精确变体）。
  ///
  /// 例如 input + password → 密码输入框，select + multi → 多选下拉。
  /// 映射关系见设计文档中 field_type → field_control 表。
  final String? fieldControl;

  /// 控件标签名称（显示给用户）。
  final String labelName;

  /// 字段名，对应提交数据的键。
  final String fieldName;

  /// 是否必填。
  final bool isRequired;

  /// 字段长度限制（0 表示不限制）。
  final int fieldLength;

  /// 最小长度（文本类）。
  final int? minLength;

  /// 最大长度（文本类）。
  final int? maxLength;

  /// 字段提示文本（placeholder）。
  final String fieldPrompt;

  /// 默认值。
  final dynamic defaultValue;

  /// 是否只读。
  final bool isReadonly;

  /// 是否隐藏（静态显隐，非联动）。
  final bool hidden;

  /// 帮助文本（显示在控件下方的小字提示）。
  final String? helpText;

  // ---- 正则与校验 ----

  /// 正则标签（如 "mobile"、"email"），加载时从注册表取对应正则。
  final String? regexTag;

  /// 直写正则表达式（优先级高于 regexTag）。
  final String? regexExpression;

  /// 校验失败时的自定义提示文本。
  final String? validatorMessage;

  /// 异步校验策略键。
  final String? asyncValidatorKey;

  // ---- 数据源 ----

  /// 数据源类型。
  final ParkDataSourceType dataSourceType;

  /// 数据源键（枚举名 / 字典键 / API 路径 / 缓存键）。
  final String? dataSourceKey;

  /// 数据源参数（如 API 的动态查询参数，值可为字段名引用）。
  final Map<String, dynamic> dataSourceParams;

  /// 静态选项列表。
  final List<Map<String, dynamic>> options;

  /// 选项中用作显示文本的键名（默认 "label"）。
  final String optionLabelKey;

  /// 选项中用作提交值的键名（默认 "value"）。
  final String optionValueKey;

  /// 选项中用作子节点列表的键名（默认 "children"）。
  final String optionChildrenKey;

  // ---- 联动规则 ----

  /// 显隐联动条件（支持 and/or/not/field+equals）。
  final Map<String, dynamic> visibleRule;

  /// 禁用联动条件（支持 and/or/not/field+equals）。
  final Map<String, dynamic> disabledRule;

  /// 动态必填规则（为空时退化为 isRequired 静态值）。
  final Map<String, dynamic> requiredRule;

  // ---- 布局与分组 ----

  /// 分组键（用于分组聚合）。
  final String? groupKey;

  /// 分组显示名称。
  final String? groupName;

  /// 排序权重（越小越靠前）。
  final int order;

  /// 布局占格（12 栅格）。
  final int span;

  /// 字段级标签布局覆盖（覆盖 ParkFormLayout.defaultLabelLayout）。
  final ParkLabelLayout? labelLayout;

  /// 该字段所属的分组标识（对应 ParkFormSectionConfig.key）。
  final String? sectionKey;

  // ---- UI 配置 ----

  /// 控件 UI 配置（前缀、后缀、行数、高度等）。
  final ParkFieldUiConfig uiConfig;

  /// 字段格式化配置。
  ///
  /// 配置了该属性时，展示文本会通过 [FormFormatterEngine.applyAll] 进行格式化。
  /// 若为 null 则表示不应用任何格式化。
  final ParkFormFieldFormatterSchema? format;

  // ---- 扩展 ----

  /// 扩展字段（业务自定义属性）。
  final Map<String, dynamic> ext;

  /// 创建字段结构。
  const ParkFormFieldSchema({
    required this.fieldId,
    required this.fieldType,
    required this.labelName,
    required this.fieldName,
    this.fieldControl,
    this.isRequired = false,
    this.fieldLength = 0,
    this.minLength,
    this.maxLength,
    this.fieldPrompt = '',
    this.defaultValue,
    this.isReadonly = false,
    this.hidden = false,
    this.helpText,
    this.regexTag,
    this.regexExpression,
    this.validatorMessage,
    this.asyncValidatorKey,
    this.dataSourceType = ParkDataSourceType.none,
    this.dataSourceKey,
    this.dataSourceParams = const <String, dynamic>{},
    this.options = const <Map<String, dynamic>>[],
    this.optionLabelKey = 'label',
    this.optionValueKey = 'value',
    this.optionChildrenKey = 'children',
    this.visibleRule = const <String, dynamic>{},
    this.disabledRule = const <String, dynamic>{},
    this.requiredRule = const <String, dynamic>{},
    this.groupKey,
    this.groupName,
    this.order = 0,
    this.span = 12,
    this.labelLayout,
    this.sectionKey,
    this.uiConfig = const ParkFieldUiConfig(),
    this.format,
    this.ext = const <String, dynamic>{},
  });

  /// 从 JSON 创建字段结构。
  ///
  /// 同时支持新版协议命名（field_id, field_type 等）
  /// 与旧版命名（key, type 等），优先读取新版键名。
  ///
  /// [json] JSON 对象。
  factory ParkFormFieldSchema.fromJson(Map<String, dynamic> json) {
    // 字段 ID：优先 field_id，退化 key，最终用 fieldName。
    final String id = (json['field_id'] as String?) ??
        (json['key'] as String?) ??
        (json['field_name'] as String?) ??
        '';

    // 字段名：优先 field_name，退化 key。
    final String name = (json['field_name'] as String?) ??
        (json['key'] as String?) ??
        id;

    // 标签：优先 label_name，退化 label。
    final String label = (json['label_name'] as String?) ??
        (json['label'] as String?) ??
        '';

    // 控件类型。
    final String typeStr = (json['field_type'] as String?) ??
        (json['type'] as String?) ??
        (json['col_type'] as String?) ??
        'text';

    // 提示文本。
    final String prompt = (json['field_prompt'] as String?) ??
        (json['placeholder'] as String?) ??
        '';

    // 控件子类型（field_control / fieldControl）。
    final String? fieldCtrl = (json['field_control'] as String?) ??
        (json['fieldControl'] as String?);

    // 必填。
    final bool required = (json['is_required'] as bool?) ??
        (json['required'] as bool?) ??
        false;

    // 只读。
    final bool readOnly = (json['is_read'] as bool?) ??
        (json['is_readonly'] as bool?) ??
        (json['readOnly'] as bool?) ??
        false;

    // 隐藏。
    final bool isHidden = (json['is_forbidden'] as bool?) ??
        (json['is_hidden'] as bool?) ??
        (json['hidden'] as bool?) ??
        false;

    // 正则。
    final String? regexTag = (json['regex_tag'] as String?) ??
        (json['field_reg'] as String?);
    final String? regexExpr = (json['regex_expression'] as String?) ??
        (json['reg_expression'] as String?) ??
        (json['regex'] as String?);

    // 长度。
    final int fieldLen = (json['field_length'] as int?) ??
        (json['field_leng'] as int?) ??
        0;
    final int? minLen = (json['min_length'] as int?) ??
        (json['minLength'] as int?);
    final int? maxLen = (json['max_length'] as int?) ??
        (json['maxLength'] as int?);

    // 校验提示。
    final String? valMsg = (json['validator_message'] as String?) ??
        (json['validatorMessage'] as String?);

    // 异步校验。
    final String? asyncKey = (json['async_validator_key'] as String?) ??
        (json['asyncValidatorKey'] as String?);

    // 数据源。
    final String dsTypeStr = (json['data_source_type'] as String?) ??
        (json['data_type'] as String?) ??
        'none';
    final String? dsKey = (json['data_source_key'] as String?) ??
        (json['data_key'] as String?);
    final Map<String, dynamic> dsParams = _parseMap(
      json['data_source_params'] ?? json['relevance_key'],
    );

    // 选项。
    final List<Map<String, dynamic>> opts = _parseOptions(
      json['options'],
    );

    // 选项映射键。
    final String optLabelKey = (json['option_label_key'] as String?) ??
        'label';
    final String optValueKey = (json['option_value_key'] as String?) ??
        'value';
    final String optChildrenKey = (json['option_children_key'] as String?) ??
        'children';

    // 联动规则（兼容旧版 visibleWhen/disabledWhen）。
    final Map<String, dynamic> visible = _parseMap(
      json['visible_rule'] ?? json['visibleWhen'],
    );
    final Map<String, dynamic> disabled = _parseMap(
      json['disabled_rule'] ?? json['disabledWhen'],
    );
    final Map<String, dynamic> requiredR = _parseMap(
      json['required_rule'],
    );

    // 分组。
    final String? gKey = (json['group_key'] as String?) ??
        (json['group'] as String?);
    final String? gName = (json['group_name'] as String?) ??
        gKey;

    // 标签布局与分组归属。
    final String? labelLayoutStr = (json['label_layout'] as String?) ??
        (json['labelLayout'] as String?);
    final String? secKey = (json['section_key'] as String?) ??
        (json['sectionKey'] as String?);

    // UI 配置。
    final Map<String, dynamic> uiJson = _parseMap(
      json['ui_config'] ?? json['config'],
    );

    // 扩展。
    final Map<String, dynamic> extData = _parseMap(json['ext']);

    // 格式化配置：优先从顶级 format 键读取，退化到 ext 中的旧字段。
    ParkFormFieldFormatterSchema? formatSchema;
    final dynamic formatJson = json['format'];
    if (formatJson is Map<String, dynamic>) {
      formatSchema = ParkFormFieldFormatterSchema.fromJson(formatJson);
    } else if (formatJson is Map) {
      formatSchema = ParkFormFieldFormatterSchema.fromJson(
        Map<String, dynamic>.from(formatJson),
      );
    } else if (extData.containsKey('formatterType')) {
      // 兼容旧版：从 ext 中读取格式化字段，构建临时 JSON 交由 fromJson 解析。
      final Map<String, dynamic> formatFromExt = <String, dynamic>{
        'formatterType': extData['formatterType']?.toString() ?? 'none',
        'formatterPattern': extData['formatterPattern']?.toString() ?? '',
        'suffixMode': extData['suffixMode']?.toString() ?? 'none',
        'suffixText': extData['suffixText']?.toString() ?? '',
        'displayTransform': extData['displayTransform']?.toString() ?? 'none',
      };
      formatSchema = ParkFormFieldFormatterSchema.fromJson(formatFromExt);
    }

    return ParkFormFieldSchema(
      fieldId: id,
      fieldType: _parseType(typeStr),
      fieldControl: fieldCtrl,
      labelName: label,
      fieldName: name,
      isRequired: required,
      fieldLength: fieldLen,
      minLength: minLen,
      maxLength: maxLen,
      fieldPrompt: prompt,
      defaultValue: json['default_value'] ?? json['defaultValue'],
      isReadonly: readOnly,
      hidden: isHidden,
      helpText: json['help_text'] as String?,
      regexTag: regexTag,
      regexExpression: regexExpr,
      validatorMessage: valMsg,
      asyncValidatorKey: asyncKey,
      dataSourceType: _parseDataSourceType(dsTypeStr),
      dataSourceKey: dsKey,
      dataSourceParams: dsParams,
      options: opts,
      optionLabelKey: optLabelKey,
      optionValueKey: optValueKey,
      optionChildrenKey: optChildrenKey,
      visibleRule: visible,
      disabledRule: disabled,
      requiredRule: requiredR,
      groupKey: gKey,
      groupName: gName,
      order: (json['order'] as int?) ?? (json['sort_order'] as int?) ?? 0,
      span: (json['span'] as int?) ?? 12,
      labelLayout: labelLayoutStr != null
          ? parseLabelLayout(labelLayoutStr)
          : null,
      sectionKey: secKey,
      uiConfig: ParkFieldUiConfig.fromJson(uiJson),
      format: formatSchema,
      ext: extData,
    );
  }

  /// 转为 JSON（输出新版协议格式）。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'field_id': fieldId,
      'field_type': fieldType.name,
      'field_control': fieldControl,
      'label_name': labelName,
      'field_name': fieldName,
      'is_required': isRequired,
      'field_length': fieldLength,
      'min_length': minLength,
      'max_length': maxLength,
      'field_prompt': fieldPrompt,
      'default_value': defaultValue,
      'is_read': isReadonly,
      'hidden': hidden,
      'help_text': helpText,
      'regex_tag': regexTag,
      'regex_expression': regexExpression,
      'validator_message': validatorMessage,
      'async_validator_key': asyncValidatorKey,
      'data_source_type': dataSourceType.name,
      'data_source_key': dataSourceKey,
      'data_source_params': dataSourceParams,
      'options': options,
      'option_label_key': optionLabelKey,
      'option_value_key': optionValueKey,
      'option_children_key': optionChildrenKey,
      'visible_rule': visibleRule,
      'disabled_rule': disabledRule,
      'required_rule': requiredRule,
      'group_key': groupKey,
      'group_name': groupName,
      'order': order,
      'span': span,
      'label_layout': labelLayout?.name,
      'section_key': sectionKey,
      'ui_config': uiConfig.toJson(),
      'format': format?.toJson(),
      'ext': ext,
    };
  }

  /// 复制并覆盖部分属性。
  ///
  /// 所有参数均为可选，传入则覆盖，不传则保留原值。
  ParkFormFieldSchema copyWith({
    String? fieldId,
    ParkFieldType? fieldType,
    String? fieldControl,
    String? labelName,
    String? fieldName,
    bool? isRequired,
    int? fieldLength,
    int? minLength,
    int? maxLength,
    String? fieldPrompt,
    dynamic defaultValue,
    bool? isReadonly,
    bool? hidden,
    String? helpText,
    String? regexTag,
    String? regexExpression,
    String? validatorMessage,
    String? asyncValidatorKey,
    ParkDataSourceType? dataSourceType,
    String? dataSourceKey,
    Map<String, dynamic>? dataSourceParams,
    List<Map<String, dynamic>>? options,
    String? optionLabelKey,
    String? optionValueKey,
    String? optionChildrenKey,
    Map<String, dynamic>? visibleRule,
    Map<String, dynamic>? disabledRule,
    Map<String, dynamic>? requiredRule,
    String? groupKey,
    String? groupName,
    int? order,
    int? span,
    ParkLabelLayout? labelLayout,
    String? sectionKey,
    ParkFieldUiConfig? uiConfig,
    ParkFormFieldFormatterSchema? format,
    Map<String, dynamic>? ext,
  }) {
    return ParkFormFieldSchema(
      fieldId: fieldId ?? this.fieldId,
      fieldType: fieldType ?? this.fieldType,
      fieldControl: fieldControl ?? this.fieldControl,
      labelName: labelName ?? this.labelName,
      fieldName: fieldName ?? this.fieldName,
      isRequired: isRequired ?? this.isRequired,
      fieldLength: fieldLength ?? this.fieldLength,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      fieldPrompt: fieldPrompt ?? this.fieldPrompt,
      defaultValue: defaultValue ?? this.defaultValue,
      isReadonly: isReadonly ?? this.isReadonly,
      hidden: hidden ?? this.hidden,
      helpText: helpText ?? this.helpText,
      regexTag: regexTag ?? this.regexTag,
      regexExpression: regexExpression ?? this.regexExpression,
      validatorMessage: validatorMessage ?? this.validatorMessage,
      asyncValidatorKey: asyncValidatorKey ?? this.asyncValidatorKey,
      dataSourceType: dataSourceType ?? this.dataSourceType,
      dataSourceKey: dataSourceKey ?? this.dataSourceKey,
      dataSourceParams: dataSourceParams ?? this.dataSourceParams,
      options: options ?? this.options,
      optionLabelKey: optionLabelKey ?? this.optionLabelKey,
      optionValueKey: optionValueKey ?? this.optionValueKey,
      optionChildrenKey: optionChildrenKey ?? this.optionChildrenKey,
      visibleRule: visibleRule ?? this.visibleRule,
      disabledRule: disabledRule ?? this.disabledRule,
      requiredRule: requiredRule ?? this.requiredRule,
      groupKey: groupKey ?? this.groupKey,
      groupName: groupName ?? this.groupName,
      order: order ?? this.order,
      span: span ?? this.span,
      labelLayout: labelLayout ?? this.labelLayout,
      sectionKey: sectionKey ?? this.sectionKey,
      uiConfig: uiConfig ?? this.uiConfig,
      format: format ?? this.format,
      ext: ext ?? this.ext,
    );
  }

  // ---- 旧属性兼容 Getter ----

  /// 兼容旧版 `key` 属性（等同于 [fieldName]）。
  String get key => fieldName;

  /// 兼容旧版 `label` 属性（等同于 [labelName]）。
  String get label => labelName;

  /// 兼容旧版 `type` 属性（等同于 [fieldType]）。
  ParkFieldType get type => fieldType;

  /// 兼容旧版 `placeholder` 属性（等同于 [fieldPrompt]）。
  String? get placeholder => fieldPrompt.isEmpty ? null : fieldPrompt;

  /// 兼容旧版 `required` 属性（等同于 [isRequired]）。
  bool get required => isRequired;

  /// 兼容旧版 `readOnly` 属性（等同于 [isReadonly]）。
  bool get readOnly => isReadonly;

  /// 兼容旧版 `regex` 属性（等同于 [regexExpression]）。
  String? get regex => regexExpression;

  /// 兼容旧版 `group` 属性（等同于 [groupName]）。
  String? get group => groupName;

  /// 兼容旧版 `visibleWhen` 属性（等同于 [visibleRule]）。
  Map<String, dynamic> get visibleWhen => visibleRule;

  /// 兼容旧版 `disabledWhen` 属性（等同于 [disabledRule]）。
  Map<String, dynamic> get disabledWhen => disabledRule;

  /// 兼容旧版 `config` 属性。
  ///
  /// 合并 [uiConfig] 与 [ext]，使旧代码 `field.config['allowSources']` 等仍然有效。
  Map<String, dynamic> get config => <String, dynamic>{
    ...uiConfig.toJson(),
    ...ext,
  };

  // ---- 私有工具方法 ----

  /// 解析控件类型字符串。
  ///
  /// [rawType] 原始类型字符串。
  static ParkFieldType _parseType(String rawType) {
    switch (rawType) {
      case 'textarea':
        return ParkFieldType.textarea;
      case 'number':
        return ParkFieldType.number;
      case 'select':
        return ParkFieldType.select;
      case 'radio':
        return ParkFieldType.radio;
      case 'checkbox':
        return ParkFieldType.checkbox;
      case 'toggle':
        return ParkFieldType.toggle;
      case 'date':
        return ParkFieldType.date;
      case 'image':
        return ParkFieldType.image;
      case 'scanner':
        return ParkFieldType.scanner;
      case 'region':
        return ParkFieldType.region;
      case 'slider':
        return ParkFieldType.slider;
      case 'stepper':
        return ParkFieldType.stepper;
      case 'rate':
        return ParkFieldType.rate;
      case 'cascader':
        return ParkFieldType.cascader;
      case 'treeSelect':
      case 'tree_select':
        return ParkFieldType.treeSelect;
      case 'picker':
        return ParkFieldType.picker;
      case 'search':
        return ParkFieldType.search;
      case 'upload':
        return ParkFieldType.upload;
      case 'richText':
      case 'rich_text':
        return ParkFieldType.richText;
      case 'text':
      default:
        return ParkFieldType.text;
    }
  }

  /// 解析数据源类型字符串。
  ///
  /// [raw] 原始字符串。
  static ParkDataSourceType _parseDataSourceType(String raw) {
    switch (raw) {
      case 'static':
      case 'staticOptions':
      case 'static_options':
        return ParkDataSourceType.staticOptions;
      case 'enum':
      case 'enumSource':
      case 'enum_source':
        return ParkDataSourceType.enumSource;
      case 'dict':
        return ParkDataSourceType.dict;
      case 'api':
        return ParkDataSourceType.api;
      case 'cache':
        return ParkDataSourceType.cache;
      case 'none':
      default:
        return ParkDataSourceType.none;
    }
  }

  /// 安全解析 Map。
  ///
  /// [source] 原始数据（可能是 Map 或 null）。
  static Map<String, dynamic> _parseMap(dynamic source) {
    if (source == null) return <String, dynamic>{};
    if (source is Map<String, dynamic>) return source;
    if (source is Map) return Map<String, dynamic>.from(source);
    return <String, dynamic>{};
  }

  /// 安全解析选项列表。
  ///
  /// [source] 原始数据。
  static List<Map<String, dynamic>> _parseOptions(dynamic source) {
    if (source == null) return <Map<String, dynamic>>[];
    if (source is List) {
      return source
          .whereType<Map>()
          .map((Map e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  @override
  List<Object?> get props => <Object?>[
    fieldId,
    fieldType,
    fieldControl,
    labelName,
    fieldName,
    isRequired,
    fieldLength,
    minLength,
    maxLength,
    fieldPrompt,
    defaultValue,
    isReadonly,
    hidden,
    helpText,
    regexTag,
    regexExpression,
    validatorMessage,
    asyncValidatorKey,
    dataSourceType,
    dataSourceKey,
    dataSourceParams,
    options,
    optionLabelKey,
    optionValueKey,
    optionChildrenKey,
    visibleRule,
    disabledRule,
    requiredRule,
    groupKey,
    groupName,
    order,
    span,
    labelLayout,
    sectionKey,
    uiConfig,
    format,
    ext,
  ];
}

/// reaction 动作结构。
///
/// 描述命中 reaction 后，需要对目标字段执行的单个动作。
class ParkFormReactionActionSchema extends Equatable {
  /// 动作类型。
  final ParkFormReactionActionType actionType;

  /// 目标字段名。
  final String targetField;

  /// 动作值。
  ///
  /// - `set_visible / set_disabled / set_required` 通常为 bool。
  /// - `set_value` 可为字面量，也可为 `$form.xxx` 引用。
  /// - `clear_value / reload_options` 可为空。
  final dynamic value;

  /// 创建 reaction 动作。
  const ParkFormReactionActionSchema({
    required this.actionType,
    required this.targetField,
    this.value,
  });

  /// 从 JSON 创建 reaction 动作。
  factory ParkFormReactionActionSchema.fromJson(Map<String, dynamic> json) {
    return ParkFormReactionActionSchema(
      actionType: _parseReactionActionType(
        (json['action_type'] as String?) ?? (json['type'] as String?) ?? '',
      ),
      targetField: (json['target_field'] as String?) ??
          (json['field'] as String?) ??
          '',
      value: json['value'],
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'action_type': _reactionActionTypeToJson(actionType),
      'target_field': targetField,
      'value': value,
    };
  }

  /// 复制并覆盖部分属性。
  ParkFormReactionActionSchema copyWith({
    ParkFormReactionActionType? actionType,
    String? targetField,
    Object? value = _copyWithSentinel,
  }) {
    return ParkFormReactionActionSchema(
      actionType: actionType ?? this.actionType,
      targetField: targetField ?? this.targetField,
      value: identical(value, _copyWithSentinel) ? this.value : value,
    );
  }

  @override
  List<Object?> get props => <Object?>[actionType, targetField, value];
}

/// reaction 结构。
///
/// 用于描述“某个字段值变化后，按条件执行一组动作”的规则。
class ParkFormReactionSchema extends Equatable {
  /// reaction 唯一标识。
  final String reactionId;

  /// 触发字段名。
  final String triggerField;

  /// 触发事件。
  final ParkFormTriggerEvent triggerEvent;

  /// 命中条件。
  ///
  /// 复用现有表单引擎的 conditions 语法。
  final Map<String, dynamic> conditions;

  /// 动作集合。
  final List<ParkFormReactionActionSchema> actions;

  /// 创建 reaction。
  const ParkFormReactionSchema({
    required this.reactionId,
    required this.triggerField,
    this.triggerEvent = ParkFormTriggerEvent.change,
    this.conditions = const <String, dynamic>{},
    this.actions = const <ParkFormReactionActionSchema>[],
  });

  /// 从 JSON 创建 reaction。
  factory ParkFormReactionSchema.fromJson(Map<String, dynamic> json) {
    return ParkFormReactionSchema(
      reactionId: (json['reaction_id'] as String?) ??
          (json['reactionId'] as String?) ??
          '',
      triggerField: (json['trigger_field'] as String?) ??
          (json['triggerField'] as String?) ??
          '',
      triggerEvent: _parseTriggerEvent(
        (json['trigger_event'] as String?) ??
            (json['triggerEvent'] as String?) ??
            'change',
      ),
      conditions: ParkFormFieldSchema._parseMap(json['conditions']),
      actions: _parseMapList(
        json['actions'],
        ParkFormReactionActionSchema.fromJson,
      ),
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reaction_id': reactionId,
      'trigger_field': triggerField,
      'trigger_event': triggerEvent.name,
      'conditions': conditions,
      'actions': actions
          .map((ParkFormReactionActionSchema action) => action.toJson())
          .toList(),
    };
  }

  /// 复制并覆盖部分属性。
  ParkFormReactionSchema copyWith({
    String? reactionId,
    String? triggerField,
    ParkFormTriggerEvent? triggerEvent,
    Map<String, dynamic>? conditions,
    List<ParkFormReactionActionSchema>? actions,
  }) {
    return ParkFormReactionSchema(
      reactionId: reactionId ?? this.reactionId,
      triggerField: triggerField ?? this.triggerField,
      triggerEvent: triggerEvent ?? this.triggerEvent,
      conditions: conditions ?? this.conditions,
      actions: actions ?? this.actions,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    reactionId,
    triggerField,
    triggerEvent,
    conditions,
    actions,
  ];
}

/// 动态表单整体结构。
///
/// 描述一个完整表单的元信息，包括唯一标识和字段列表。
class ParkFormSchema extends Equatable {
  /// 表单唯一标识。
  final String formKey;

  /// 字段集合。
  final List<ParkFormFieldSchema> fields;

  /// reaction 集合。
  ///
  /// 用于描述规则驱动的字段联动行为。
  final List<ParkFormReactionSchema> reactions;

  /// 表单布局配置（标签布局、分组卡片、间距等）。
  final ParkFormLayout? layout;

  /// 创建表单结构。
  const ParkFormSchema({
    required this.formKey,
    required this.fields,
    this.reactions = const <ParkFormReactionSchema>[],
    this.layout,
  });

  /// 从 JSON 创建表单结构。
  ///
  /// [json] JSON 对象。
  factory ParkFormSchema.fromJson(Map<String, dynamic> json) {
    return ParkFormSchema(
      formKey: json['formKey'] as String? ?? json['form_key'] as String? ?? '',
      fields: _parseMapList(json['fields'], ParkFormFieldSchema.fromJson),
      reactions: _parseMapList(json['reactions'], ParkFormReactionSchema.fromJson),
      layout: json['layout'] is Map
          ? ParkFormLayout.fromJson(_asStringMap(json['layout'])!)
          : null,
    );
  }

  /// 转为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formKey': formKey,
      'fields': fields
          .map((ParkFormFieldSchema field) => field.toJson())
          .toList(),
      'reactions': reactions
          .map((ParkFormReactionSchema reaction) => reaction.toJson())
          .toList(),
      'layout': layout?.toJson(),
    };
  }

  /// 复制并覆盖部分属性。
  ParkFormSchema copyWith({
    String? formKey,
    List<ParkFormFieldSchema>? fields,
    List<ParkFormReactionSchema>? reactions,
    ParkFormLayout? layout,
  }) {
    return ParkFormSchema(
      formKey: formKey ?? this.formKey,
      fields: fields ?? this.fields,
      reactions: reactions ?? this.reactions,
      layout: layout ?? this.layout,
    );
  }

  @override
  List<Object?> get props => <Object?>[formKey, fields, reactions, layout];
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

/// copyWith 的哨兵对象。
const Object _copyWithSentinel = Object();

/// 解析 reaction 触发事件。
ParkFormTriggerEvent _parseTriggerEvent(String raw) {
  switch (raw) {
    case 'change':
    default:
      return ParkFormTriggerEvent.change;
  }
}

/// 解析 reaction 动作类型。
ParkFormReactionActionType _parseReactionActionType(String raw) {
  switch (raw) {
    case 'set_visible':
      return ParkFormReactionActionType.setVisible;
    case 'set_disabled':
      return ParkFormReactionActionType.setDisabled;
    case 'set_required':
      return ParkFormReactionActionType.setRequired;
    case 'set_value':
      return ParkFormReactionActionType.setValue;
    case 'clear_value':
      return ParkFormReactionActionType.clearValue;
    case 'reload_options':
      return ParkFormReactionActionType.reloadOptions;
    default:
      return ParkFormReactionActionType.setValue;
  }
}

/// 将 reaction 动作类型转为协议字符串。
String _reactionActionTypeToJson(ParkFormReactionActionType type) {
  switch (type) {
    case ParkFormReactionActionType.setVisible:
      return 'set_visible';
    case ParkFormReactionActionType.setDisabled:
      return 'set_disabled';
    case ParkFormReactionActionType.setRequired:
      return 'set_required';
    case ParkFormReactionActionType.setValue:
      return 'set_value';
    case ParkFormReactionActionType.clearValue:
      return 'clear_value';
    case ParkFormReactionActionType.reloadOptions:
      return 'reload_options';
  }
}
