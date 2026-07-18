// Park 表单组件规格 — 由 Agent 填充
// （ParkForm Schema 模式）
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

/// 表单类组件规格字典（1 个组件）。
Map<String, ParkComponentSpec> get parkFormSpecs =>
    <String, ParkComponentSpec>{
      'ParkForm': _parkDynamicFormSpec,
      'ParkFormSection': _parkFormSectionSpec,
    };

/// 示例 schema，用于演示与 spec demo 区块渲染。
final ParkFormSchema _sampleFormSchema = ParkFormSchema(
  formKey: 'demo_contact',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'f_name',
      fieldType: ParkFieldType.text,
      labelName: '姓名',
      fieldName: 'name',
      isRequired: true,
      fieldPrompt: '请输入姓名',
      fieldLength: 20,
    ),
    ParkFormFieldSchema(
      fieldId: 'f_city',
      fieldType: ParkFieldType.select,
      labelName: '城市',
      fieldName: 'city',
      fieldPrompt: '请选择城市',
      options: <Map<String, dynamic>>[
        <String, dynamic>{'label': '北京', 'value': 'bj'},
        <String, dynamic>{'label': '上海', 'value': 'sh'},
        <String, dynamic>{'label': '广州', 'value': 'gz'},
        <String, dynamic>{'label': '深圳', 'value': 'sz'},
      ],
    ),
    ParkFormFieldSchema(
      fieldId: 'f_member',
      fieldType: ParkFieldType.toggle,
      labelName: '是否会员',
      fieldName: 'member',
      defaultValue: false,
    ),
    ParkFormFieldSchema(
      fieldId: 'f_remark',
      fieldType: ParkFieldType.textarea,
      labelName: '备注',
      fieldName: 'remark',
      fieldPrompt: '补充说明（选填）',
      fieldLength: 200,
    ),
  ],
);

/// 联动 demo 的 schema：账户类型联动「企业名称」显隐/必填，发票开关联动「税号」禁用。
final ParkFormSchema _reactionDemoSchema = ParkFormSchema(
  formKey: 'reaction_demo',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'f_type',
      fieldType: ParkFieldType.select,
      labelName: '账户类型',
      fieldName: 'type',
      isRequired: true,
      options: <Map<String, dynamic>>[
        <String, dynamic>{'label': '个人', 'value': 'person'},
        <String, dynamic>{'label': '企业', 'value': 'company'},
      ],
    ),
    ParkFormFieldSchema(
      fieldId: 'f_company',
      fieldType: ParkFieldType.text,
      labelName: '企业名称',
      fieldName: 'company',
      fieldPrompt: '仅企业账户需要填写',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_invoice',
      fieldType: ParkFieldType.toggle,
      labelName: '需要发票',
      fieldName: 'needInvoice',
      defaultValue: false,
    ),
    ParkFormFieldSchema(
      fieldId: 'f_taxno',
      fieldType: ParkFieldType.text,
      labelName: '税号',
      fieldName: 'taxNo',
      fieldPrompt: '开票时必填',
    ),
  ],
  reactions: <ParkFormReactionSchema>[
    ParkFormReactionSchema(
      reactionId: 'r_company_show',
      triggerField: 'type',
      conditions: <String, dynamic>{'field': 'type', 'equals': 'company'},
      actions: <ParkFormReactionActionSchema>[
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setVisible,
          targetField: 'company',
          value: true,
        ),
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setRequired,
          targetField: 'company',
          value: true,
        ),
      ],
    ),
    ParkFormReactionSchema(
      reactionId: 'r_company_hide',
      triggerField: 'type',
      conditions: <String, dynamic>{'field': 'type', 'equals': 'person'},
      actions: <ParkFormReactionActionSchema>[
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setVisible,
          targetField: 'company',
          value: false,
        ),
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setRequired,
          targetField: 'company',
          value: false,
        ),
      ],
    ),
    ParkFormReactionSchema(
      reactionId: 'r_tax_disable',
      triggerField: 'needInvoice',
      conditions: <String, dynamic>{'field': 'needInvoice', 'equals': false},
      actions: <ParkFormReactionActionSchema>[
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setDisabled,
          targetField: 'taxNo',
          value: true,
        ),
      ],
    ),
    ParkFormReactionSchema(
      reactionId: 'r_tax_enable',
      triggerField: 'needInvoice',
      conditions: <String, dynamic>{'field': 'needInvoice', 'equals': true},
      actions: <ParkFormReactionActionSchema>[
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setDisabled,
          targetField: 'taxNo',
          value: false,
        ),
      ],
    ),
  ],
);

/// 异步校验 demo：在 demo 内自建最小 AsyncValidator，不依赖真实后端。
final AsyncValidatorRegistry _asyncDemoRegistry = <String, AsyncFieldValidator>{
  'checkUsername': (ParkFormFieldSchema field, dynamic value) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String v = (value ?? '').toString();
    if (v.isEmpty) return null;
    return v.toLowerCase() == 'admin' ? '用户名 $v 已被占用' : null;
  },
};

final ParkFormSchema _asyncDemoSchema = ParkFormSchema(
  formKey: 'async_demo',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'f_user',
      fieldType: ParkFieldType.text,
      labelName: '用户名',
      fieldName: 'username',
      isRequired: true,
      asyncValidatorKey: 'checkUsername',
      fieldPrompt: '试试输入 admin',
    ),
  ],
);

/// 分组 demo：同一 groupKey / groupName 的字段聚合为一个分组卡片。
final ParkFormSchema _groupDemoSchema = ParkFormSchema(
  formKey: 'group_demo',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'f_name',
      fieldType: ParkFieldType.text,
      labelName: '姓名',
      fieldName: 'name',
      groupKey: 'g_basic',
      groupName: '基本信息',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_phone',
      fieldType: ParkFieldType.text,
      labelName: '手机号',
      fieldName: 'phone',
      groupKey: 'g_basic',
      groupName: '基本信息',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_remark',
      fieldType: ParkFieldType.textarea,
      labelName: '备注',
      fieldName: 'remark',
      groupKey: 'g_ext',
      groupName: '扩展信息',
    ),
  ],
);

/// 字段扩展能力 demo：子类型(password) / 字数统计(showCount) / 帮助文本(helpText) / 只读(isReadonly)。
final ParkFormSchema _extendDemoSchema = ParkFormSchema(
  formKey: 'extend_demo',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'f_pwd',
      fieldType: ParkFieldType.text,
      labelName: '密码',
      fieldName: 'password',
      fieldControl: 'password',
      fieldPrompt: '请输入密码',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_bio',
      fieldType: ParkFieldType.textarea,
      labelName: '个人简介',
      fieldName: 'bio',
      fieldLength: 50,
      uiConfig: const ParkFieldUiConfig(showCount: true, rows: 3),
      helpText: '最多 50 字，超出无法输入',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_sn',
      fieldType: ParkFieldType.text,
      labelName: '流水号（只读）',
      fieldName: 'sn',
      isReadonly: true,
      defaultValue: 'SN-2024-0001',
    ),
  ],
);

/// 数据源 demo：staticOptions 直接内联选项（enumSource / dict / api 见代码注释）。
final ParkFormSchema _dataSourceDemoSchema = ParkFormSchema(
  formKey: 'ds_demo',
  fields: <ParkFormFieldSchema>[
    ParkFormFieldSchema(
      fieldId: 'f_city',
      fieldType: ParkFieldType.select,
      labelName: '城市',
      fieldName: 'city',
      dataSourceType: ParkDataSourceType.staticOptions,
      options: <Map<String, dynamic>>[
        <String, dynamic>{'label': '北京', 'value': 'bj'},
        <String, dynamic>{'label': '上海', 'value': 'sh'},
        <String, dynamic>{'label': '广州', 'value': 'gz'},
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkForm
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDynamicFormSpec = ParkComponentSpec(
  name: 'ParkForm',
  title: '动态表单',
  category: 'form',
  description:
      '基于 schema 动态渲染的表单容器。传入 [ParkFormSchema] 即可自动生成'
      '文本、选择、开关、多行等字段，内置必填/正则校验、分组布局、'
      '显隐/禁用/必填联动（reaction）与提交回调，无需手写每个表单项。',
  icon: Icons.dynamic_form_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'schema',
      type: 'ParkFormSchema',
      required: true,
      description: '表单结构定义（字段列表、联动规则与布局）。',
    ),
    ParkPropertyDef(
      name: 'onSubmit',
      type: 'ValueChanged<Map<String, dynamic>>',
      required: true,
      description: '提交回调，参数为校验通过后的字段值集合。',
    ),
    ParkPropertyDef(
      name: 'submitLabel',
      type: 'String',
      defaultVal: "'提交'",
      description: '提交按钮文案。',
    ),
    ParkPropertyDef(
      name: 'resetLabel',
      type: 'String',
      defaultVal: "'重置'",
      description: '重置按钮文案。',
    ),
    ParkPropertyDef(
      name: 'showReset',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示重置按钮。',
    ),
    ParkPropertyDef(
      name: 'asyncValidatorRegistry',
      type: 'AsyncValidatorRegistry',
      defaultVal: '{}',
      description: '异步校验注册表（按 asyncValidatorKey 映射）。',
    ),
    ParkPropertyDef(
      name: 'configureEngine',
      type: 'void Function(ParkFormEngine)?',
      description: '引擎配置回调，用于注入数据源解析器等。',
    ),
    ParkPropertyDef(
      name: 'asyncValidator',
      type: 'ParkAsyncValidator?',
      description: '异步校验器，接收完整 formData 返回 Map<String, String?> 错误。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      description: '外部绑定服务注入。',
    ),
    ParkPropertyDef(
      name: 'formGroup',
      type: 'ParkFormGroup?',
      defaultVal: 'null',
      description: '表单分组对象（优先级高于 model / bindingService，支持值访问、校验、批量赋值）/ Form group object',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSubmit',
      signature: 'ValueChanged<Map<String, dynamic>>',
      description: '表单校验通过后触发，回传字段值集合。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'contact',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_name',
        fieldType: ParkFieldType.text,
        labelName: '姓名',
        fieldName: 'name',
        isRequired: true,
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
  guide: '''
## 何时使用
- 配置化表单：字段由后端 schema 驱动，前端无需逐字段硬编码
- 低代码 / 表单设计器产出的运行时渲染
- 需要联动显隐、动态必填、异步校验的复杂表单

## 使用建议
- 优先通过 [ParkFormSchema.fromJson] 从接口/模板加载结构
- 用 [ParkFormFieldSchema.groupKey] / section 组织字段分组
- 联动规则用 reaction（setVisible / setDisabled / setRequired / reloadOptions）
- 原生图片/扫码能力通过 ParkFormImageService 注入，保证跨平台编译

---

  ''',
  schemaDoc: '''
# ParkFormFieldSchema 字段结构完整属性文档

> ParkFormFieldSchema 是组成 schema.fields 的每个字段的描述对象。
> 下面按分组列出全部属性的详细说明（按真实 `ParkFormFieldSchema` 公共字段逐一列出），含类型、必填、JSON 键名映射。

## 1. 基础属性

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `fieldId` | `String` | 是 | `field_id` / `key` | 字段稳定唯一 ID。设计器拖拽、版本 diff 用。JSON 兼容：field_id（新版）→ key（旧版）→ field_name。 |
| `fieldType` | `ParkFieldType` | 是 | `field_type` / `type` | 字段控件类型枚举：text / textarea / number / select / radio / checkbox / toggle / date / image / scanner / region / slider / stepper / rate / cascader / treeSelect / picker / search / upload / richText。 |
| `fieldControl` | `String?` | 否 | `field_control` | 控件子类型（field_type 的精确变体），例如 input+password → 密码框。 |
| `labelName` | `String` | 是 | `label_name` / `label` | 控件标签名称，显示给用户。 |
| `fieldName` | `String` | 是 | `field_name` / `key` | 字段名，对应提交数据的键名。 |
| `isRequired` | `bool` | 否 | `is_required` / `required` | 是否必填，默认 false。 |
| `fieldPrompt` | `String` | 否 | `field_prompt` / `placeholder` | 占位提示文本。 |
| `defaultValue` | `dynamic` | 否 | `default_value` | 默认值，类型由 fieldType 决定。 |
| `isReadonly` | `bool` | 否 | `is_readonly` / `readOnly` | 是否只读，默认 false。 |
| `hidden` | `bool` | 否 | `hidden` / `is_hidden` | 是否静态隐藏（非联动），默认 false。隐藏字段不渲染但值仍会提交。 |
| `helpText` | `String?` | 否 | `help_text` | 帮助提示文本，显示在控件下方。 |

## 2. 校验属性

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `fieldLength` | `int` | 否 | `field_length` | 字段长度限制（0 表示不限制）。 |
| `minLength` | `int?` | 否 | `min_length` | 最小长度（文本类）。 |
| `maxLength` | `int?` | 否 | `max_length` | 最大长度（文本类）。 |
| `regexTag` | `String?` | 否 | `regex_tag` / `field_reg` | 正则标签，如 "mobile"、"email"，从 ParkRegexRegistry 取对应正则。 |
| `regexExpression` | `String?` | 否 | `regex_expression` / `regex` | 直写正则表达式，优先级高于 regexTag。 |
| `validatorMessage` | `String?` | 否 | `validator_message` | 校验失败时的自定义提示文本。 |
| `asyncValidatorKey` | `String?` | 否 | `async_validator_key` | 异步校验策略键，引用 ParkForm.asyncValidatorRegistry 中注册的校验器。 |

## 3. 数据源属性

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `dataSourceType` | `ParkDataSourceType` | 否 | `data_source_type` | 选项数据源类型：none / staticOptions / enumSource / dict / api / cache。 |
| `dataSourceKey` | `String?` | 否 | `data_source_key` | 数据源键，用于从注册表取具体数据源。 |
| `dataSourceParams` | `Map<String, dynamic>` | 否 | `data_source_params` | 数据源参数。值可引用其他字段（\u{24}form.xxx）。 |
| `options` | `List<Map<String, dynamic>>` | 否 | `options` | 静态选项列表。每个元素为 {label, value, children} 格式。 |
| `optionLabelKey` | `String` | 否 | `option_label_key` | 选项中用作显示文本的键名，默认 "label"。 |
| `optionValueKey` | `String` | 否 | `option_value_key` | 选项中用作提交值的键名，默认 "value"。 |
| `optionChildrenKey` | `String` | 否 | `option_children_key` | 选项中用作子节点列表的键名（级联/树形），默认 "children"。 |

## 4. 联动属性

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `visibleRule` | `Map<String, dynamic>` | 否 | `visible_rule` / `visibleWhen` | 显隐联动条件。支持 and/or/not/field+equals 语法。 |
| `disabledRule` | `Map<String, dynamic>` | 否 | `disabled_rule` / `disabledWhen` | 禁用联动条件。 |
| `requiredRule` | `Map<String, dynamic>` | 否 | `required_rule` | 动态必填规则。为空时退化为 isRequired 静态值。 |

## 5. 布局属性

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `groupKey` | `String?` | 否 | `group_key` / `group` | 分组键。同 groupKey 的字段会聚合在同一个 ExpansionTile 分组中。 |
| `groupName` | `String?` | 否 | `group_name` | 分组显示名称。为 null 时退化为 groupKey。 |
| `order` | `int` | 否 | `order` / `sort_order` | 排序权重，越小越靠前（升序），默认 0。 |
| `span` | `int` | 否 | `span` | 布局占格（12 栅格），默认 12 占满一行。设为 6 占半行。 |
| `labelLayout` | `ParkLabelLayout?` | 否 | `label_layout` | 字段级标签布局覆盖：left（默认）/ top（标签在上）/ none。 |
| `sectionKey` | `String?` | 否 | `section_key` | 字段所属的分区标识。对应 ParkFormSectionConfig.key。 |

## 6. UI 配置

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `uiConfig` | `ParkFieldUiConfig` | 否 | `ui_config` / `config` | 控件 UI 配置。含 prefix（前缀）、suffix（后缀）、rows（行数）、height（高度）、showCount（字数统计）、actionButton（操作按钮）。 |

## 7. 扩展属性

| 属性 | 类型 | 必填 | JSON 键 | 说明 |
|------|------|------|---------|------|
| `ext` | `Map<String, dynamic>` | 否 | `ext` | 扩展字段。用于存放业务自定义属性（权限标识、UI 覆盖等）。 |

---

# ParkFieldType 字段控件类型

| 枚举值 | 控件 | 说明 |
|--------|------|------|
| `text` | 单行文本 | 普通输入框，支持文本/数字/密码。 |
| `textarea` | 多行文本 | 多行文本输入框。 |
| `number` | 数字输入 | 数字输入框，支持加减按钮。 |
| `select` | 下拉选择 | 单选下拉选择器。 |
| `radio` | 单选组 | 单选按钮组。 |
| `checkbox` | 多选组 | 复选框组，支持多选。 |
| `toggle` | 开关 | 开关切换控件。 |
| `date` | 日期选择 | 日期选择器（支持日期范围）。 |
| `image` | 图片选择 | 图片选择（含裁剪功能）。 |
| `scanner` | 扫码输入 | 扫码输入框。 |
| `region` | 地区级联 | 地区级联选择器（省/市/区）。 |
| `slider` | 滑杆 | 滑块滑动选择。 |
| `stepper` | 步进器 | 数值步进器（增减按钮）。 |
| `rate` | 评分 | 星级评分组件。 |
| `cascader` | 级联选择 | 多级级联选择器。 |
| `treeSelect` | 树形选择 | 树形结构选择器。 |
| `picker` | 底部弹出 | 底部弹出选择器。 |
| `search` | 搜索框 | 搜索输入框。 |
| `upload` | 文件上传 | 文件上传控件。 |
| `richText` | 富文本 | 富文本编辑器。 |

---

# Reaction 联动系统

> 通过 ParkFormReactionSchema 描述"当 X 字段变化时，按条件对 Y 字段执行某个动作"。

## ParkFormReactionSchema 字段

| 属性 | 类型 | 说明 |
|------|------|------|
| `reactionId` | `String` | 联动规则唯一标识。 |
| `triggerField` | `String` | 触发字段的 fieldName。 |
| `triggerEvent` | `ParkFormTriggerEvent` | 触发事件（当前支持 change）。 |
| `conditions` | `Map<String, dynamic>` | 命中条件。语法：`{"field": "x", "equals": "y"}` / `{"and": [...]}` / `{"or": [...]}` / `{"not": 条件}`。 |
| `actions` | `List<ParkFormReactionActionSchema>` | 动作列表（按顺序执行）。 |

## ParkFormReactionActionType 动作类型

| 动作 | 说明 |
|------|------|
| `setVisible` | 设置目标字段显示状态（true/false）。 |
| `setDisabled` | 设置目标字段禁用状态（true/false）。 |
| `setRequired` | 设置目标字段必填状态（true/false）。 |
| `setValue` | 为目标字段写入值（可引用 `\u{24}form.xxx`）。 |
| `clearValue` | 清空目标字段值。 |
| `reloadOptions` | 重新加载目标字段选项。 |

## 内联渲染字段类型（image / scanner / region / richText）

> 以下四类无独立组件展示页，其配置统一在此说明：它们都作为 `ParkFormFieldSchema` 的一个字段，由 `ParkForm` 在运行时内联渲染。

### image

- **对应字段类型**：`ParkFieldType.image`（图片选择，含裁剪）。
- **适用场景**：头像、证件照、商品图等图片上传与预览。
- **关键 schema 属性**：
  | 属性(Dart) | JSON 键 | 说明 | 必填 |
  |------------|---------|------|------|
  | `fieldType` | `field_type` / `type` | 固定为 `image` | 是 |
  | `fieldName` | `field_name` / `key` | 提交键名 | 是 |
  | `labelName` | `label_name` / `label` | 标签 | 是 |
  | `isRequired` | `is_required` / `required` | 是否必填 | 否 |
  | `ext` | `ext` | 业务扩展：`maxCount`（数量）、`aspectRatio`（裁剪比例） | 否 |
- **最小可用示例**：
  ```dart
  ParkFormFieldSchema(
    fieldId: 'f_avatar',
    fieldType: ParkFieldType.image,
    labelName: '头像',
    fieldName: 'avatar',
    isRequired: true,
    ext: {'maxCount': 1},
  )
  ```
- **进阶技巧**：裁剪比例、数量限制经 `ext` 承载；`defaultValue` 预填已上传图片地址。

### scanner

- **对应字段类型**：`ParkFieldType.scanner`（扫码输入）。
- **适用场景**：扫码录入商品条码、快递单号等。
- **关键 schema 属性**：
  | 属性(Dart) | JSON 键 | 说明 | 必填 |
  |------------|---------|------|------|
  | `fieldType` | `field_type` / `type` | 固定为 `scanner` | 是 |
  | `fieldName` | `field_name` / `key` | 提交键名 | 是 |
  | `labelName` | `label_name` / `label` | 标签 | 是 |
  | `isRequired` | `is_required` / `required` | 是否必填 | 否 |
  | `ext` | `ext` | 扫码类型（如 `qr` / `bar`）、业务扩展 | 否 |
- **最小可用示例**：
  ```dart
  ParkFormFieldSchema(
    fieldId: 'f_code',
    fieldType: ParkFieldType.scanner,
    labelName: '扫码录入',
    fieldName: 'code',
    ext: {'scanType': 'qr'},
  )
  ```
- **进阶技巧**：扫码结果直接写入字段值；原生扫码能力经 `ParkFormImageService` 注入以保证跨平台编译。

### region

- **对应字段类型**：`ParkFieldType.region`（地区级联选择）。
- **适用场景**：省/市/区三级联动选择。
- **关键 schema 属性**：
  | 属性(Dart) | JSON 键 | 说明 | 必填 |
  |------------|---------|------|------|
  | `fieldType` | `field_type` / `type` | 固定为 `region` | 是 |
  | `fieldName` | `field_name` / `key` | 提交键名 | 是 |
  | `labelName` | `label_name` / `label` | 标签 | 是 |
  | `isRequired` | `is_required` / `required` | 是否必填 | 否 |
  | `dataSourceType` | `data_source_type` | 地区数据来源（通常 dict/api） | 否 |
  | `dataSourceKey` | `data_source_key` | 数据源键 | 否 |
- **最小可用示例**：
  ```dart
  ParkFormFieldSchema(
    fieldId: 'f_region',
    fieldType: ParkFieldType.region,
    labelName: '所在地区',
    fieldName: 'region',
    isRequired: true,
    dataSourceType: ParkDataSourceType.dict,
    dataSourceKey: 'china_region',
  )
  ```
- **进阶技巧**：地区树经 `dataSourceType + dataSourceKey` 加载；`dataSourceParams` 可引用其它字段（\u{24}form.xxx）；联动 `reloadOptions` 刷新下级。

### richText

- **对应字段类型**：`ParkFieldType.richText`（富文本编辑器）。
- **适用场景**：图文混排的富文本内容采集（公告、商品详情等）。
- **关键 schema 属性**：
  | 属性(Dart) | JSON 键 | 说明 | 必填 |
  |------------|---------|------|------|
  | `fieldType` | `field_type` / `type` | 固定为 `richText` | 是 |
  | `fieldName` | `field_name` / `key` | 提交键名 | 是 |
  | `labelName` | `label_name` / `label` | 标签 | 是 |
  | `isRequired` | `is_required` / `required` | 是否必填 | 否 |
  | `uiConfig` | `ui_config` / `config` | `rows` 控制默认高度 | 否 |
  | `ext` | `ext` | 业务扩展：工具栏配置、占位提示等 | 否 |
- **最小可用示例**：
  ```dart
  ParkFormFieldSchema(
    fieldId: 'f_detail',
    fieldType: ParkFieldType.richText,
    labelName: '商品详情',
    fieldName: 'detail',
    uiConfig: ParkFieldUiConfig(rows: 6),
  )
  ```
- **进阶技巧**：默认高度经 `uiConfig.rows` 控制；富文本 HTML 存入 `defaultValue` / 提交值。

''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础动态表单',
      description: '文本、下拉、开关、多行四类字段，提交后回传值集合。',
      code: '''
ParkForm(
  schema: schema,
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => ParkForm(
        schema: _sampleFormSchema,
        onSubmit: (_) {},
      ),
    ),
    ParkDemoScenario(
      title: '联动：显隐 / 禁用 / 必填',
      description:
          '选择「企业」时显示并必填「企业名称」；关闭「需要发票」时禁用「税号」。',
      code: '''
ParkFormSchema(
  formKey: 'reaction_demo',
  fields: [
    ParkFormFieldSchema(
      fieldId: 'f_type',
      fieldType: ParkFieldType.select,
      labelName: '账户类型',
      fieldName: 'type',
      isRequired: true,
      options: [
        {'label': '个人', 'value': 'person'},
        {'label': '企业', 'value': 'company'},
      ],
    ),
    ParkFormFieldSchema(
      fieldId: 'f_company',
      fieldType: ParkFieldType.text,
      labelName: '企业名称',
      fieldName: 'company',
      fieldPrompt: '仅企业账户需要填写',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_invoice',
      fieldType: ParkFieldType.toggle,
      labelName: '需要发票',
      fieldName: 'needInvoice',
      defaultValue: false,
    ),
    ParkFormFieldSchema(
      fieldId: 'f_taxno',
      fieldType: ParkFieldType.text,
      labelName: '税号',
      fieldName: 'taxNo',
      fieldPrompt: '开票时必填',
    ),
  ],
  reactions: [
    ParkFormReactionSchema(
      reactionId: 'r_company_show',
      triggerField: 'type',
      conditions: {'field': 'type', 'equals': 'company'},
      actions: [
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setVisible,
          targetField: 'company',
          value: true,
        ),
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setRequired,
          targetField: 'company',
          value: true,
        ),
      ],
    ),
    ParkFormReactionSchema(
      reactionId: 'r_company_hide',
      triggerField: 'type',
      conditions: {'field': 'type', 'equals': 'person'},
      actions: [
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setVisible,
          targetField: 'company',
          value: false,
        ),
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setRequired,
          targetField: 'company',
          value: false,
        ),
      ],
    ),
    ParkFormReactionSchema(
      reactionId: 'r_tax_disable',
      triggerField: 'needInvoice',
      conditions: {'field': 'needInvoice', 'equals': false},
      actions: [
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setDisabled,
          targetField: 'taxNo',
          value: true,
        ),
      ],
    ),
    ParkFormReactionSchema(
      reactionId: 'r_tax_enable',
      triggerField: 'needInvoice',
      conditions: {'field': 'needInvoice', 'equals': true},
      actions: [
        ParkFormReactionActionSchema(
          actionType: ParkFormReactionActionType.setDisabled,
          targetField: 'taxNo',
          value: false,
        ),
      ],
    ),
  ],
)

ParkForm(schema: schema, onSubmit: (values) => print(values))''',
      builder: (BuildContext context) => ParkForm(
        schema: _reactionDemoSchema,
        onSubmit: (_) {},
      ),
    ),
    ParkDemoScenario(
      title: '异步校验（自建最小 AsyncValidator）',
      description:
          '通过 asyncValidatorKey 关联注册表中的异步校验器；demo 内自建校验器，输入 admin 会提示已被占用。',
      code: '''
// 在 demo 内自建最小 AsyncValidator，不依赖真实后端
final AsyncValidatorRegistry registry = <String, AsyncFieldValidator>{
  'checkUsername': (ParkFormFieldSchema field, dynamic value) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String v = (value ?? '').toString();
    if (v.isEmpty) return null;
    return v.toLowerCase() == 'admin' ? '用户名 \${v} 已被占用' : null;
  },
};

ParkFormSchema(
  formKey: 'async_demo',
  fields: [
    ParkFormFieldSchema(
      fieldId: 'f_user',
      fieldType: ParkFieldType.text,
      labelName: '用户名',
      fieldName: 'username',
      isRequired: true,
      asyncValidatorKey: 'checkUsername',
      fieldPrompt: '试试输入 admin',
    ),
  ],
)

ParkForm(
  schema: schema,
  asyncValidatorRegistry: registry,
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => ParkForm(
        schema: _asyncDemoSchema,
        asyncValidatorRegistry: _asyncDemoRegistry,
        onSubmit: (_) {},
      ),
    ),
    ParkDemoScenario(
      title: '分组（groupKey 聚合）',
      description:
          '相同 groupKey / groupName 的字段会自动聚合为一个分组卡片，便于长表单分区管理。',
      code: '''
ParkFormSchema(
  formKey: 'group_demo',
  fields: [
    ParkFormFieldSchema(
      fieldId: 'f_name',
      fieldType: ParkFieldType.text,
      labelName: '姓名',
      fieldName: 'name',
      groupKey: 'g_basic',
      groupName: '基本信息',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_phone',
      fieldType: ParkFieldType.text,
      labelName: '手机号',
      fieldName: 'phone',
      groupKey: 'g_basic',
      groupName: '基本信息',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_remark',
      fieldType: ParkFieldType.textarea,
      labelName: '备注',
      fieldName: 'remark',
      groupKey: 'g_ext',
      groupName: '扩展信息',
    ),
  ],
)

ParkForm(schema: schema, onSubmit: (values) => print(values))''',
      builder: (BuildContext context) => ParkForm(
        schema: _groupDemoSchema,
        onSubmit: (_) {},
      ),
    ),
    ParkDemoScenario(
      title: '字段扩展能力（子类型 / 字数统计 / 帮助文本 / 只读）',
      description:
          'fieldControl 切换控件子类型（password 密码框）；uiConfig.showCount 显示字数统计；helpText 显示帮助；isReadonly 只读。',
      code: '''
ParkFormSchema(
  formKey: 'extend_demo',
  fields: [
    ParkFormFieldSchema(
      fieldId: 'f_pwd',
      fieldType: ParkFieldType.text,
      labelName: '密码',
      fieldName: 'password',
      fieldControl: 'password', // 子类型：密码框
      fieldPrompt: '请输入密码',
    ),
    ParkFormFieldSchema(
      fieldId: 'f_bio',
      fieldType: ParkFieldType.textarea,
      labelName: '个人简介',
      fieldName: 'bio',
      fieldLength: 50,
      uiConfig: ParkFieldUiConfig(showCount: true, rows: 3), // 字数统计
      helpText: '最多 50 字，超出无法输入',                   // 帮助文本
    ),
    ParkFormFieldSchema(
      fieldId: 'f_sn',
      fieldType: ParkFieldType.text,
      labelName: '流水号（只读）',
      fieldName: 'sn',
      isReadonly: true, // 只读字段
      defaultValue: 'SN-2024-0001',
    ),
  ],
)

ParkForm(schema: schema, onSubmit: (values) => print(values))''',
      builder: (BuildContext context) => ParkForm(
        schema: _extendDemoSchema,
        onSubmit: (_) {},
      ),
    ),
    ParkDemoScenario(
      title: '数据源（staticOptions / enumSource / api）',
      description:
          'staticOptions 直接内联选项；enumSource / dict / api 通过 dataSourceKey 加载；api 的 dataSourceParams 可引用其它字段（运行期写作 \$form.province）。',
      code: '''
// staticOptions：直接内联选项，无需后端
ParkFormFieldSchema(
  fieldId: 'f_city',
  fieldType: ParkFieldType.select,
  labelName: '城市',
  fieldName: 'city',
  dataSourceType: ParkDataSourceType.staticOptions,
  options: [
    {'label': '北京', 'value': 'bj'},
    {'label': '上海', 'value': 'sh'},
  ],
)

// enumSource / dict：通过 dataSourceKey 引用本地枚举或字典
// api：dataSourceParams 可引用其它字段（运行期写作 \$form.province）
//   ParkFormFieldSchema(
//     fieldType: ParkFieldType.select,
//     dataSourceType: ParkDataSourceType.api,
//     dataSourceKey: 'city_by_province',
//     dataSourceParams: {'province': '\$form.province'},
//   )

ParkForm(schema: schema, onSubmit: (values) => print(values))''',
      builder: (BuildContext context) => ParkForm(
        schema: _dataSourceDemoSchema,
        onSubmit: (_) {},
      ),
    ),
    ParkDemoScenario(
      title: 'schema 驱动 + 提交回显',
      description:
          '传入 ParkFormSchema 自动渲染字段，点击提交触发 onSubmit 并回显提交值集合。',
      code: '''
ParkForm(
  schema: schema,
  onSubmit: (values) => print(values),
)
''',
      builder: (BuildContext context) => _DynamicFormSubmitDemo(),
    ),
    // ── ParkFormItem 横纵布局演示 ──
    ParkDemoScenario(
      title: 'ParkFormItem — 横纵布局',
      description: 'ParkFormItem 的 layout 属性支持 vertical（纵向：标签在上）'
          ' / horizontal（横向：标签在左）。可通过 ParkForm 全局控制，'
          '也可在 ParkFormItem 上行级覆盖。',
      code: '''
// 全局水平布局
ParkForm(
  layout: ParkFormLayout.horizontal,
  children: [
    ParkFormItem(label: '姓名', child: ParkInput(hintText: '请输入姓名')),
    ParkFormItem(
      label: '年龄',
      child: ParkInputNumber(),
    ),
    // 单项覆盖为纵向
    ParkFormItem(
      label: '备注',
      layout: ParkFormLayout.vertical,
      child: ParkInput(hintText: '请输入备注', maxLines: 2),
    ),
  ],
)''',
      builder: (BuildContext context) => _FormLayoutDemo(),
    ),
    // ── ParkForm 包裹 ParkCard 组合演示 ──
    ParkDemoScenario(
      title: '表单包裹卡片组合',
      description: 'ParkForm 包裹 ParkCard 作为表单容器，卡片内嵌输入字段',
      code: '''
ParkForm(
  model: {'name': '张三', 'email': 'zhangsan@example.com'},
  onSubmit: (values) => print(values),
  children: [
    ParkCard(
      titleText: '联系信息',
      child: Column(
        children: [
          ParkFormItem(
            label: '姓名',
            child: ParkInput(
              bindKey: 'name',
              hintText: '请输入姓名',
            ),
          ),
          ParkFormItem(
            label: '邮箱',
            child: ParkInput(
              bindKey: 'email',
              hintText: '请输入邮箱',
            ),
          ),
        ],
      ),
    ),
  ],
)''',
      builder: (BuildContext context) => _FormCardDemo(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkFormSection
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkFormSectionSpec = ParkComponentSpec(
  name: 'ParkFormSection',
  title: '表单分区',
  category: 'form',
  description:
      '表单分区组件，用于将表单字段分组展示。支持标题（title）、'
      '描述（description）、右侧操作区（trailing）、可折叠收起/展开、'
      '子项间距、底部分割线等能力，适合长表单分区管理。',
  icon: Icons.folder_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String',
      required: true,
      description: '分区标题。',
    ),
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: '子内容列表。',
    ),
    ParkPropertyDef(
      name: 'description',
      type: 'String?',
      description: '分区描述文本。',
    ),
    ParkPropertyDef(
      name: 'trailing',
      type: 'Widget?',
      description: '右侧扩展区域。',
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double?',
      description: '组内子项间距，默认使用主题 spacing.base。',
    ),
    ParkPropertyDef(
      name: 'padding',
      type: 'EdgeInsetsGeometry?',
      description: '外层内边距。',
    ),
    ParkPropertyDef(
      name: 'showHeader',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示顶部标题区。',
    ),
    ParkPropertyDef(
      name: 'collapsible',
      type: 'bool',
      defaultVal: 'false',
      description: '是否可折叠。为 true 时在标题区显示展开/收起箭头。',
    ),
    ParkPropertyDef(
      name: 'defaultCollapsed',
      type: 'bool',
      defaultVal: 'false',
      description: '初始折叠状态（仅当 collapsible 为 true 时生效）。',
    ),
    ParkPropertyDef(
      name: 'onCollapseChanged',
      type: 'ValueChanged<bool>?',
      description: '折叠状态变更回调。',
    ),
    ParkPropertyDef(
      name: 'divider',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在分组底部显示分割线。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onCollapseChanged',
      signature: 'ValueChanged<bool>?',
      description: '折叠状态变更时触发，回传当前折叠状态。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkFormSection(
  title: '基本信息',
  description: '请填写以下基本信息',
  children: [
    ParkFormItem(
      label: '姓名',
      child: ParkInput(hintText: '请输入姓名'),
    ),
    ParkFormItem(
      label: '手机号',
      child: ParkInput(hintText: '请输入手机号'),
    ),
  ],
)''',
  guide: '''
## 何时使用
- 长表单需要按语义分区展示时
- 需要可折叠/展开的分组容器
- 表单设计器需要分组布局能力

## 使用建议
- 与 ParkForm / ParkFormItem 配合使用
- collapsible 配合 defaultCollapsed 实现默认折叠
- 通过 onCollapseChanged 监听折叠状态变化
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '可折叠表单分区',
      description:
          '点击标题区域可展开/收起子内容，展示 collapsible 与 defaultCollapsed 效果。',
      code: '''
ParkFormSection(
  title: '高级设置',
  description: '点击标题可展开/收起',
  collapsible: true,
  children: [
    ParkFormItem(
      label: '主题色',
      child: ParkInput(hintText: '请输入主题色'),
    ),
    ParkFormItem(
      label: '字体大小',
      child: ParkInputNumber(value: 14),
    ),
  ],
)''',
      builder: (BuildContext context) => _FormSectionCollapseDemo(),
    ),
  ],
);

// =====================================================================
// 新增 demo 组件（ParkForm / ParkFormSection）
// =====================================================================

class _DynamicFormSubmitDemo extends StatefulWidget {
  @override
  State<_DynamicFormSubmitDemo> createState() => _DynamicFormSubmitDemoState();
}

class _DynamicFormSubmitDemoState extends State<_DynamicFormSubmitDemo> {
  Map<String, dynamic> _result = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkForm(
          schema: _sampleFormSchema,
          onSubmit: (values) => setState(() => _result = values),
        ),
        if (_result.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: park.spacing.sm),
            child: Text('提交值: $_result',
                style: TextStyle(
                    fontSize: park.typography.sizeBodySmall,
                    color: park.colors.textSecondary)),
          ),
      ],
    );
  }
}

// =====================================================================
// ParkFormItem 横纵布局演示
// =====================================================================

class _FormLayoutDemo extends StatefulWidget {
  @override
  State<_FormLayoutDemo> createState() => _FormLayoutDemoState();
}

class _FormLayoutDemoState extends State<_FormLayoutDemo> {
  ParkFormLayout _layout = ParkFormLayout.horizontal;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 切换按钮（ParkSegmented 使用 String 值）
        Row(
          children: [
            ParkText('布局：', preset: ParkTextPreset.bodySmall),
            ParkSegmented(
              value: _layout == ParkFormLayout.horizontal ? 'horizontal' : 'vertical',
              items: [
                ParkSegmentedItem(value: 'horizontal', label: '水平'),
                ParkSegmentedItem(value: 'vertical', label: '纵向'),
              ],
              onChanged: (String v) {
                setState(() {
                  _layout = v == 'horizontal'
                      ? ParkFormLayout.horizontal
                      : ParkFormLayout.vertical;
                });
              },
            ),
          ],
        ),
        SizedBox(height: park.spacing.md),
        // 表单演示
        ParkForm(
          layout: _layout,
          children: [
            ParkFormItem(
              label: '姓名',
              child: ParkInput(hintText: '请输入姓名'),
            ),
            ParkFormItem(
              label: '年龄',
              child: ParkInputNumber(),
            ),
            ParkFormItem(
              label: '备注',
              layout: ParkFormLayout.vertical,  // 始终纵向
              child: ParkInput(hintText: '此项始终纵向', maxLines: 2),
            ),
          ],
        ),
        SizedBox(height: park.spacing.sm),
        ParkText(
          '备注项使用了 layout: ParkFormLayout.vertical，不受全局切换影响。',
          preset: ParkTextPreset.caption,
        ),
      ],
    );
  }
}

// =====================================================================
// ParkForm 包裹 ParkCard 组合演示
// =====================================================================

class _FormCardDemo extends StatefulWidget {
  @override
  State<_FormCardDemo> createState() => _FormCardDemoState();
}

class _FormCardDemoState extends State<_FormCardDemo> {
  Map<String, dynamic>? _result;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkForm(
          model: <String, dynamic>{'name': '张三', 'email': 'zhangsan@example.com'},
          onSubmit: (values) {
            setState(() => _result = values);
          },
          children: <Widget>[
            ParkCard(
              titleText: '联系信息',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ParkFormItem(
                    label: '姓名',
                    child: ParkInput(
                      bindKey: 'name',
                      hintText: '请输入姓名',
                    ),
                  ),
                  ParkFormItem(
                    label: '邮箱',
                    child: ParkInput(
                      bindKey: 'email',
                      hintText: '请输入邮箱',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_result != null)
          Padding(
            padding: EdgeInsets.only(top: park.spacing.sm),
            child: ParkText(
              '提交值: $_result',
              preset: ParkTextPreset.caption,
            ),
          ),
      ],
    );
  }
}

// =====================================================================
// ParkFormSection 可折叠演示
// =====================================================================

class _FormSectionCollapseDemo extends StatefulWidget {
  @override
  State<_FormSectionCollapseDemo> createState() =>
      _FormSectionCollapseDemoState();
}

class _FormSectionCollapseDemoState extends State<_FormSectionCollapseDemo> {
  bool _collapsed1 = false;
  bool _collapsed2 = true;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkText(
          '展开状态（点击折叠）',
          preset: ParkTextPreset.bodySmall,
          color: park.colors.textSecondary,
        ),
        SizedBox(height: park.spacing.sm),
        ParkFormSection(
          title: '基本配置',
          description: '此处展示基础配置项',
          collapsible: true,
          defaultCollapsed: _collapsed1,
          onCollapseChanged: (v) => setState(() => _collapsed1 = v),
          children: <Widget>[
            ParkFormItem(
              label: '项目名称',
              child: ParkInput(hintText: '请输入项目名称'),
            ),
            ParkFormItem(
              label: '项目描述',
              child: ParkInput(hintText: '请输入项目描述', maxLines: 2),
            ),
          ],
        ),
        SizedBox(height: park.spacing.lg),
        ParkText(
          '默认收起（点击展开）',
          preset: ParkTextPreset.bodySmall,
          color: park.colors.textSecondary,
        ),
        SizedBox(height: park.spacing.sm),
        ParkFormSection(
          title: '高级设置',
          description: '点击标题展开高级选项',
          collapsible: true,
          defaultCollapsed: _collapsed2,
          onCollapseChanged: (v) => setState(() => _collapsed2 = v),
          children: <Widget>[
            ParkFormItem(
              label: '缓存策略',
              child: ParkSelect(
                items: const <ParkSelectOption>[
                  ParkSelectOption(label: 'LRU', value: 'lru'),
                  ParkSelectOption(label: 'FIFO', value: 'fifo'),
                ],
              ),
            ),
            ParkFormItem(
              label: '超时时间（秒）',
              child: ParkInputNumber(value: 30),
            ),
          ],
        ),
      ],
    );
  }
}
