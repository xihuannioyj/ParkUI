// Park 补充组件规格 — Gap Batch
//
// 覆盖：ParkFormRow / ParkChoiceGroup / ParkSheetScaffold / ParkChipGridPicker / ParkSearchDelegate
//
// 约定：
//  - 每个组件的 properties 枚举其全部公开构造参数；
//  - 每个功能 / 形态 / 状态 / 变体均对应一个 demo（code 与 builder 完全一致）；
//  - 禁止裸字面量：颜色用 ParkColors.*，间距用 ParkSpacing.* / 具名常量，
//    粗细用具名常量，字号用 ParkTypography.*，杜绝魔法变量。
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

// ===========================================================================
// 命名令牌常量
// ===========================================================================
final ParkColors _kColors = ParkColors.light();

// ===========================================================================
// 导出 Map
// ===========================================================================
Map<String, ParkComponentSpec> get parkGapSpecs => <String, ParkComponentSpec>{
      'ParkFormRow': _parkFormRowSpec,
      'ParkChoiceGroup': _parkChoiceGroupSpec,
      'ParkSheetScaffold': _parkSheetScaffoldSpec,
      'ParkChipGridPicker': _parkChipGridPickerSpec,
      'ParkSearchDelegate': _parkSearchDelegateSpec,
    };

// ────────────────────────────────────────────────────────────────────────────
// ParkFormRow
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkFormRowSpec = ParkComponentSpec(
  name: 'ParkFormRow',
  title: '表单行',
  category: 'input',
  description:
      '水平 label + field 行布局组件。提供统一的表单行模式：右侧对齐标签 + 圆角填充字段区域。'
      'child 可以是任意 Widget（ParkInput、ParkSwitch、Text、Picker 触发器等）。'
      ' / Horizontal label + field row layout. Provides the consistent form-row pattern '
      'with right-aligned label and filled rounded field area.',
  icon: Icons.view_stream_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'label',
      type: 'String',
      defaultVal: '—',
      description: '左侧标签文本 / Label text on the left',
      required: true,
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      defaultVal: '—',
      description: '右侧字段组件 / Field widget on the right',
      required: true,
    ),
    ParkPropertyDef(
      name: 'labelWidth',
      type: 'double',
      defaultVal: '86',
      description: '标签区域宽度 / Width of the label area',
      required: false,
    ),
    ParkPropertyDef(
      name: 'labelGap',
      type: 'double',
      defaultVal: '8',
      description: '标签与字段间距 / Gap between label and field',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showColon',
      type: 'bool',
      defaultVal: 'true',
      description: '标签后是否追加全角冒号 / Append fullwidth colon after label',
      required: false,
    ),
    ParkPropertyDef(
      name: 'required',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示必填标记 * / Show required mark *',
      required: false,
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读模式（影响填充透明度）/ Read-only mode',
      required: false,
    ),
    ParkPropertyDef(
      name: 'suffixText',
      type: 'String?',
      defaultVal: 'null',
      description: '后缀文本（如单位 元、㎡）/ Suffix text (e.g. unit)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'suffixWidth',
      type: 'double',
      defaultVal: '56',
      description: '后缀文本预留宽度 / Width reserved for suffix',
      required: false,
    ),
    ParkPropertyDef(
      name: 'helperText',
      type: 'String?',
      defaultVal: 'null',
      description: '字段下方帮助文本 / Helper text below the field',
      required: false,
    ),
    ParkPropertyDef(
      name: 'fieldColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '自定义字段背景色 / Custom field background color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'fieldBorderRadius',
      type: 'double',
      defaultVal: '16',
      description: '字段背景圆角 / Border radius of the field',
      required: false,
    ),
    ParkPropertyDef(
      name: 'fieldPadding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null',
      description: '字段内部自定义 padding / Custom padding inside field',
      required: false,
    ),
    ParkPropertyDef(
      name: 'verticalMargin',
      type: 'double',
      defaultVal: '10',
      description: '行垂直外边距 / Vertical margin around the row',
      required: false,
    ),
    ParkPropertyDef(
      name: 'crossAxisAlignment',
      type: 'CrossAxisAlignment',
      defaultVal: 'center',
      description: '交叉轴对齐方式 / Cross-axis alignment',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showFieldBackground',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示字段背景 / Show filled background behind field',
      required: false,
    ),
    ParkPropertyDef(
      name: 'labelStyle',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '自定义标签文字样式 / Custom label text style',
      required: false,
    ),
    ParkPropertyDef(
      name: 'suffixStyle',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '自定义后缀文字样式 / Custom suffix text style',
      required: false,
    ),
    ParkPropertyDef(
      name: 'helperStyle',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '自定义辅助文字样式 / Custom helper text style',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'VoidCallback?',
      description: '字段区域点击回调（适用于 Picker 触发）/ Tap handler for the field area',
    ),
  ],
  methods: const <ParkMethodDef>[],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础表单行',
      description: '标签 + 输入框 / Label + input field',
      code: '''ParkFormRow(
  label: '姓名',
  required: true,
  child: Text('张三', style: TextStyle(fontSize: 14, color: _kColors.textPrimary)),
)''',
      builder: _buildFormRowBasic,
    ),
    ParkDemoScenario(
      title: '带后缀单位',
      description: 'suffixText 显示单位 / Suffix unit text',
      code: '''ParkFormRow(
  label: '面积',
  suffixText: '㎡',
  readOnly: true,
  child: Text('85.5', style: TextStyle(fontSize: 14, color: _kColors.textPrimary)),
)''',
      builder: _buildFormRowSuffix,
    ),
    ParkDemoScenario(
      title: '帮助文本',
      description: 'helperText 显示提示 / Helper text below field',
      code: '''ParkFormRow(
  label: '手机号',
  helperText: '请输入 11 位手机号码',
  child: Text('138****8888', style: TextStyle(fontSize: 14, color: _kColors.textPrimary)),
)''',
      builder: _buildFormRowHelper,
    ),
    ParkDemoScenario(
      title: '可点击触发',
      description: 'onTap 触发选择器 / onTap picker trigger',
      code: '''ParkFormRow(
  label: '城市',
  onTap: () {},
  child: Text('请选择', style: TextStyle(fontSize: 14, color: _kColors.textPlaceholder)),
)''',
      builder: _buildFormRowTap,
    ),
    ParkDemoScenario(
      title: '无背景模式',
      description: 'showFieldBackground: false / Transparent field area',
      code: '''ParkFormRow(
  label: '备注',
  showFieldBackground: false,
  child: Text('无背景字段区域', style: TextStyle(fontSize: 14, color: _kColors.textSecondary)),
)''',
      builder: _buildFormRowNoBg,
    ),
  ],
  basicUsageCode: '''ParkFormRow(
  label: '姓名',
  required: true,
  child: ParkInput(controller: nameCtrl),
)''',
  guide: '''
## 使用指南 / Usage Guide
ParkFormRow 提供统一的水平 label + field 行布局，替代手动 Row + SizedBox 组合。

- label 右对齐，自动追加全角冒号（showColon 控制）
- required 为 true 时标签前显示 * 并变为错误色
- readOnly 降低字段背景透明度
- suffixText 适合显示单位（元、㎡、%）
- onTap 使整个字段区域可点击，适合 Picker 触发
- showFieldBackground: false 可去除字段背景，用于纯展示场景

## When to use
Use ParkFormRow for consistent form layouts with right-aligned labels and filled field areas.
''',
);

// ────────────────────────────────────────────────────────────────────────────
// ParkChoiceGroup
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkChoiceGroupSpec = ParkComponentSpec(
  name: 'ParkChoiceGroup',
  title: '选项组',
  category: 'input',
  description:
      '按钮式单选组。将选项渲染为可选中的带边框胶囊按钮，支持自动换行、'
      'join 模式（合并边框类似 SegmentControl）和 leading 图标。'
      ' / Button-style single-choice group with auto-wrap, join mode, and leading widgets.',
  icon: Icons.toggle_on_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkChoiceItem>',
      defaultVal: '—',
      description: '选项列表 / Available options',
      required: true,
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<String>',
      defaultVal: '—',
      description: '选中回调 / Called when user selects an option',
      required: true,
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'String?',
      defaultVal: 'null',
      description: '当前选中值 / Currently selected value',
      required: false,
    ),
    ParkPropertyDef(
      name: 'enabled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用整组 / Whether the group is enabled',
      required: false,
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读（无交互）/ Read-only (no interaction)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'direction',
      type: 'Axis',
      defaultVal: 'horizontal',
      description: '排列方向（水平自动换行）/ Layout direction',
      required: false,
    ),
    ParkPropertyDef(
      name: 'join',
      type: 'bool',
      defaultVal: 'false',
      description: '是否合并边框（SegmentControl 风格）/ Merge borders (segment style)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double',
      defaultVal: '8',
      description: '水平间距（非 join 模式）/ Horizontal spacing (non-join)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'runSpacing',
      type: 'double',
      defaultVal: '8',
      description: '行间距（水平换行模式）/ Vertical spacing between rows',
      required: false,
    ),
    ParkPropertyDef(
      name: 'padding',
      type: 'EdgeInsetsGeometry',
      defaultVal: 'symmetric(h:12, v:6)',
      description: '按钮内部 padding / Padding inside each button',
      required: false,
    ),
    ParkPropertyDef(
      name: 'borderRadius',
      type: 'double',
      defaultVal: '8',
      description: '按钮圆角（非 join 模式）/ Border radius (non-join)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '选中按钮背景色 / Selected button background',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedBorderColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '选中按钮边框色 / Selected button border color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'unselectedColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '未选中按钮背景色 / Unselected button background',
      required: false,
    ),
    ParkPropertyDef(
      name: 'unselectedBorderColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '未选中按钮边框色 / Unselected button border color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'textStyle',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '未选中选项文字样式 / Unselected item text style',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedTextStyle',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '选中选项文字样式 / Selected item text style',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "choice"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。 /'
          ' Binding key (dot path); enables two-way binding via ParkBindingService.',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。 /'
          ' Binding service; auto-resolved from ParkBindingFormScope inside a form.',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<String>',
      description: '选中值变化回调 / Called with the selected value',
    ),
  ],
  methods: const <ParkMethodDef>[],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础单选组',
      description: '水平排列自动换行 / Horizontal with auto-wrap',
      code: '''ParkChoiceGroup(
  items: [
    ParkChoiceItem(value: '1', label: '整租'),
    ParkChoiceItem(value: '2', label: '合租'),
    ParkChoiceItem(value: '3', label: '短租'),
  ],
  value: '1',
  onChanged: (v) {},
)''',
      builder: _buildChoiceGroupBasic,
    ),
    ParkDemoScenario(
      title: 'Join 模式',
      description: '合并边框 SegmentControl 风格 / Merged borders',
      code: '''ParkChoiceGroup(
  items: [
    ParkChoiceItem(value: 'day', label: '日'),
    ParkChoiceItem(value: 'week', label: '周'),
    ParkChoiceItem(value: 'month', label: '月'),
  ],
  value: 'week',
  join: true,
  onChanged: (v) {},
)''',
      builder: _buildChoiceGroupJoin,
    ),
    ParkDemoScenario(
      title: '垂直排列',
      description: 'direction: Axis.vertical / Vertical layout',
      code: '''ParkChoiceGroup(
  items: [
    ParkChoiceItem(value: 'a', label: '选项 A'),
    ParkChoiceItem(value: 'b', label: '选项 B'),
    ParkChoiceItem(value: 'c', label: '选项 C'),
  ],
  value: 'a',
  direction: Axis.vertical,
  onChanged: (v) {},
)''',
      builder: _buildChoiceGroupVertical,
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: '部分选项禁用 / Partially disabled items',
      code: '''ParkChoiceGroup(
  items: [
    ParkChoiceItem(value: '1', label: '可选'),
    ParkChoiceItem(value: '2', label: '禁用', enabled: false),
    ParkChoiceItem(value: '3', label: '可选'),
  ],
  value: '1',
  onChanged: (v) {},
)''',
      builder: _buildChoiceGroupDisabled,
    ),
    // ── ParkChoiceGroup: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中值实时同步到 model。'
          ' / ParkBindingService bindKey demo: selected value syncs to model in real time.',
      code: '''
final service = ParkBindingService({'choice': 'a'});

ParkChoiceGroup(
  items: [
    ParkChoiceItem(value: 'a', label: '选项 A'),
    ParkChoiceItem(value: 'b', label: '选项 B'),
    ParkChoiceItem(value: 'c', label: '选项 C'),
  ],
  bindKey: 'choice',
  bindingService: service,
  onChanged: (v) {},
)''',
      builder: (context) => _ChoiceGroupBindingDemo(),
    ),
    // ── ParkChoiceGroup: ParkDynamicForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkDynamicForm）',
      description:
          '通过 ParkFormSchema.fromJson 驱动 ParkDynamicForm 渲染按钮式单选字段。'
          ' / Schema-driven ParkDynamicForm rendering a choice-group field.',
      code: '''
final schema = ParkFormSchema.fromJson({
  'formKey': 'choice_group_dynamic_form_demo',
  'fields': [
    {
      'field_name': 'rentType',
      'label': '租房方式',
      // NOTE: ParkFieldType 暂无 choiceGroup 类型，回退为 radio（单选组）承载。
      'type': 'radio',
      'options': [
        {'label': '整租', 'value': '1'},
        {'label': '合租', 'value': '2'},
      ],
    },
  ],
});

ParkDynamicForm(
  schema: schema,
  onSubmit: (values) => debugPrint('submit: \$values'),
)''',
      builder: (context) => _ChoiceGroupDynamicFormDemo(),
    ),
  ],
  basicUsageCode: '''ParkChoiceGroup(
  items: [
    ParkChoiceItem(value: '1', label: '整租'),
    ParkChoiceItem(value: '2', label: '合租'),
  ],
  value: selected,
  onChanged: (v) => setState(() => selected = v),
)''',
  guide: '''
## 使用指南 / Usage Guide
ParkChoiceGroup 是按钮式单选组，适合少量选项（2~8 个）的单选场景。

- items 中每个 ParkChoiceItem 包含 value、label、leading、enabled
- join: true 时合并相邻按钮边框，呈现 SegmentControl 风格
- direction: Axis.vertical 垂直排列
- 水平模式自动换行，通过 spacing / runSpacing 控制间距
- 整组禁用用 enabled: false，单项禁用用 ParkChoiceItem.enabled: false

## ParkChoiceItem
| 属性 | 类型 | 说明 |
|------|------|------|
| value | String | 唯一标识 |
| label | String? | 显示文本 |
| leading | Widget? | 前置图标（20x20）|
| enabled | bool | 是否可选 |
''',
);

// ────────────────────────────────────────────────────────────────────────────
// ParkSheetScaffold
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkSheetScaffoldSpec = ParkComponentSpec(
  name: 'ParkSheetScaffold',
  title: '底部弹出脚手架',
  category: 'feedback',
  description:
      '标准化底部弹出面板脚手架，提供统一的 取消/标题/确认 头部结构。'
      '用作 Picker 面板、筛选面板等模态弹窗的基础结构。'
      ' / Standardized bottom-sheet scaffold with cancel / title / confirm header.',
  icon: Icons.vertical_align_bottom_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String',
      defaultVal: '—',
      description: '头部居中标题 / Title displayed centered in header',
      required: true,
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      defaultVal: '—',
      description: '主体内容 / Body content below the header',
      required: true,
    ),
    ParkPropertyDef(
      name: 'onCancel',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '取消按钮回调（null 时直接 pop）/ Cancel callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onConfirm',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '确认按钮回调（null 时按钮禁用）/ Confirm callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'cancelText',
      type: 'String?',
      defaultVal: 'null',
      description: '自定义取消文本 / Custom cancel text',
      required: false,
    ),
    ParkPropertyDef(
      name: 'confirmText',
      type: 'String?',
      defaultVal: 'null',
      description: '自定义确认文本 / Custom confirm text',
      required: false,
    ),
    ParkPropertyDef(
      name: 'confirmEnabled',
      type: 'bool',
      defaultVal: 'true',
      description: '确认按钮是否可用 / Whether confirm is enabled',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bodyHeight',
      type: 'double?',
      defaultVal: 'null',
      description: '主体固定高度（null 自适应）/ Fixed body height',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showDragHandle',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示拖拽指示条 / Show drag handle pill',
      required: false,
    ),
    ParkPropertyDef(
      name: 'header',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义头部（替换默认 cancel/title/confirm）/ Custom header widget',
      required: false,
    ),
    ParkPropertyDef(
      name: 'isScrollControlled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否允许弹窗内容超出屏幕高度 / Allow content to exceed screen height',
      required: false,
    ),
    ParkPropertyDef(
      name: 'useSafeArea',
      type: 'bool',
      defaultVal: 'true',
      description: '是否使用安全区域 / Use safe area',
      required: false,
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '弹窗背景色 / Sheet background color',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onCancel',
      signature: 'VoidCallback?',
      description: '取消回调 / Cancel tap callback',
    ),
    ParkEventDef(
      name: 'onConfirm',
      signature: 'VoidCallback?',
      description: '确认回调 / Confirm tap callback',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkSheetScaffold.show()',
      signature: 'Future<bool?> Function({required BuildContext context, required String title, required Widget child, ...})',
      description:
          '以模态底部面板形式展示，返回 true=确认 / false=取消 / null=关闭 / Show as modal bottom sheet',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础弹出面板',
      description: '点击按钮弹出 Sheet / Tap to show sheet',
      code: '''ParkSheetScaffold.show(
  context: context,
  title: '选择城市',
  bodyHeight: 200,
  child: Center(child: Text('面板内容')),
)''',
      builder: _buildSheetBasic,
    ),
    ParkDemoScenario(
      title: '禁用确认',
      description: 'confirmEnabled: false / Disabled confirm',
      code: '''ParkSheetScaffold.show(
  context: context,
  title: '选择日期',
  confirmEnabled: false,
  bodyHeight: 160,
  child: Center(child: Text('请先选择')),
)''',
      builder: _buildSheetDisabled,
    ),
    ParkDemoScenario(
      title: '自定义按钮文本',
      description: 'cancelText / confirmText / Custom button texts',
      code: '''ParkSheetScaffold.show(
  context: context,
  title: '筛选条件',
  cancelText: '重置',
  confirmText: '应用',
  bodyHeight: 160,
  child: Center(child: Text('筛选内容')),
)''',
      builder: _buildSheetCustomText,
    ),
  ],
  basicUsageCode: '''ParkSheetScaffold.show(
  context: context,
  title: '选择城市',
  onConfirm: () { /* handle confirm */ },
  child: MyPickerContent(),
);''',
  guide: '''
## 使用指南 / Usage Guide
ParkSheetScaffold 是标准化底部弹出面板的基础脚手架。

- 通过静态方法 ParkSheetScaffold.show() 以模态方式弹出
- 返回 Future<bool?>：true=确认，false=取消，null=外部关闭
- 提供统一的 取消/标题/确认 头部，也可通过 header 完全自定义
- bodyHeight 为 null 时主体自适应高度
- showDragHandle 控制顶部拖拽指示条

## When to use
- 选择器面板（城市、日期、级联）
- 筛选面板
- 任何需要统一头部的模态底部弹窗
''',
);

// ────────────────────────────────────────────────────────────────────────────
// ParkChipGridPicker
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkChipGridPickerSpec = ParkComponentSpec(
  name: 'ParkChipGridPicker',
  title: '分类网格选择器',
  category: 'input',
  description:
      '两级选择器：水平分类 Tab + 子选项网格。支持多选/单选模式，'
      '适用于户型、朝向、标签等多分类筛选场景。'
      ' / Two-level picker: horizontal category tabs + grid of child options.',
  icon: Icons.grid_view_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'categories',
      type: 'List<ParkChipGridCategory>',
      defaultVal: '—',
      description: '分类数据 / Category data',
      required: true,
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<Set<String>>',
      defaultVal: '—',
      description: '选中值变化回调 / Called when selection changes',
      required: true,
    ),
    ParkPropertyDef(
      name: 'selectedValues',
      type: 'Set<String>',
      defaultVal: '{}',
      description: '当前选中值集合 / Currently selected values',
      required: false,
    ),
    ParkPropertyDef(
      name: 'multiSelect',
      type: 'bool',
      defaultVal: 'true',
      description: '是否多选 / Whether multiple selection allowed',
      required: false,
    ),
    ParkPropertyDef(
      name: 'columns',
      type: 'int',
      defaultVal: '4',
      description: '网格列数 / Number of grid columns',
      required: false,
    ),
    ParkPropertyDef(
      name: 'categorySpacing',
      type: 'double',
      defaultVal: '8',
      description: '分类 Tab 水平间距 / Spacing between category tabs',
      required: false,
    ),
    ParkPropertyDef(
      name: 'optionSpacing',
      type: 'double',
      defaultVal: '8',
      description: '选项水平间距 / Horizontal spacing between options',
      required: false,
    ),
    ParkPropertyDef(
      name: 'optionRunSpacing',
      type: 'double',
      defaultVal: '8',
      description: '选项行间距 / Vertical spacing between option rows',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '选中选项背景色 / Selected option background',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedBorderColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '选中选项边框色 / Selected option border color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'unselectedColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '未选中选项背景色 / Unselected option background',
      required: false,
    ),
    ParkPropertyDef(
      name: 'unselectedBorderColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '未选中选项边框色 / Unselected option border color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "tags"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。 /'
          ' Binding key (dot path); enables two-way binding via ParkBindingService.',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。 /'
          ' Binding service; auto-resolved from ParkBindingFormScope inside a form.',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<Set<String>>',
      description: '选中值集合变化回调 / Called with updated selection set',
    ),
  ],
  methods: const <ParkMethodDef>[],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '多选网格',
      description: '默认多选模式 / Default multi-select',
      code: '''ParkChipGridPicker(
  categories: [
    ParkChipGridCategory(label: '户型', children: [
      ParkChipGridOption(value: '1', label: '一室'),
      ParkChipGridOption(value: '2', label: '二室'),
      ParkChipGridOption(value: '3', label: '三室'),
      ParkChipGridOption(value: '4', label: '四室'),
    ]),
  ],
  selectedValues: {'1'},
  onChanged: (v) {},
)''',
      builder: _buildChipGridMulti,
    ),
    ParkDemoScenario(
      title: '单选模式',
      description: 'multiSelect: false / Single select',
      code: '''ParkChipGridPicker(
  categories: [
    ParkChipGridCategory(label: '朝向', children: [
      ParkChipGridOption(value: 'south', label: '朝南'),
      ParkChipGridOption(value: 'north', label: '朝北'),
      ParkChipGridOption(value: 'east', label: '朝东'),
      ParkChipGridOption(value: 'west', label: '朝西'),
    ]),
  ],
  selectedValues: {'south'},
  multiSelect: false,
  onChanged: (v) {},
)''',
      builder: _buildChipGridSingle,
    ),
    ParkDemoScenario(
      title: '多分类 Tab',
      description: '多个分类切换 / Multiple category tabs',
      code: '''ParkChipGridPicker(
  categories: [
    ParkChipGridCategory(label: '户型', children: [...]),
    ParkChipGridCategory(label: '朝向', children: [...]),
  ],
  selectedValues: {},
  onChanged: (v) {},
)''',
      builder: _buildChipGridMultiCat,
    ),
    // ── ParkChipGridPicker: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中集合实时同步到 model。'
          ' / ParkBindingService bindKey demo: selection set syncs to model in real time.',
      code: '''
final service = ParkBindingService({'tags': <String>{'x'}});

ParkChipGridPicker(
  categories: [
    ParkChipGridCategory(label: '标签', children: [
      ParkChipGridOption(value: 'x', label: '标签 X'),
      ParkChipGridOption(value: 'y', label: '标签 Y'),
      ParkChipGridOption(value: 'z', label: '标签 Z'),
    ]),
  ],
  bindKey: 'tags',
  bindingService: service,
  onChanged: (v) {},
)''',
      builder: (context) => _ChipGridPickerBindingDemo(),
    ),
    // ── ParkChipGridPicker: ParkDynamicForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkDynamicForm）',
      description:
          '通过 ParkFormSchema.fromJson 驱动 ParkDynamicForm 渲染两级筛选字段。'
          ' / Schema-driven ParkDynamicForm rendering a chip-grid picker field.',
      code: '''
final schema = ParkFormSchema.fromJson({
  'formKey': 'chip_grid_picker_dynamic_form_demo',
  'fields': [
    {
      'field_name': 'tags',
      'label': '筛选标签',
      // NOTE: ParkFieldType 暂无 chipGrid 类型，回退为 checkbox（多选组）承载。
      'type': 'checkbox',
      'options': [
        {'label': '标签 X', 'value': 'x'},
        {'label': '标签 Y', 'value': 'y'},
        {'label': '标签 Z', 'value': 'z'},
      ],
    },
  ],
});

ParkDynamicForm(
  schema: schema,
  onSubmit: (values) => debugPrint('submit: \$values'),
)''',
      builder: (context) => _ChipGridPickerDynamicFormDemo(),
    ),
  ],
  basicUsageCode: '''ParkChipGridPicker(
  categories: [
    ParkChipGridCategory(label: '户型', children: [
      ParkChipGridOption(value: '1', label: '一室'),
      ParkChipGridOption(value: '2', label: '二室'),
    ]),
  ],
  selectedValues: selected,
  onChanged: (values) => setState(() => selected = values),
)''',
  guide: '''
## 使用指南 / Usage Guide
ParkChipGridPicker 是两级选择器，适合多分类 + 多选项的筛选场景。

- categories 定义分类 Tab 及其子选项
- selectedValues 是全局选中集合（跨分类）
- multiSelect: false 时为单选模式（新选替换旧选）
- columns 控制网格列数（默认 4）
- 每个 ParkChipGridOption 可通过 enabled: false 单独禁用

## 数据模型 / Data Model
| 类 | 属性 | 说明 |
|------|------|------|
| ParkChipGridCategory | label | 分类 Tab 文本 |
| ParkChipGridCategory | children | 子选项列表 |
| ParkChipGridOption | value | 唯一值 |
| ParkChipGridOption | label | 显示文本 |
| ParkChipGridOption | enabled | 是否可选 |
''',
);

// ────────────────────────────────────────────────────────────────────────────
// ParkSearchDelegate (showParkSearch)
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkSearchDelegateSpec = ParkComponentSpec(
  name: 'ParkSearchDelegate',
  title: '全屏搜索',
  category: 'input',
  description:
      '全屏搜索页面。通过 showParkSearch<T>() 函数调用，提供搜索输入、历史记录、'
      '联想建议和结果展示的完整搜索体验。支持自定义 ParkSearchHistory 持久化。'
      ' / Full-screen search page via showParkSearch<T>() with history, suggestions, and results.',
  icon: Icons.search_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'context',
      type: 'BuildContext',
      defaultVal: '—',
      description: '上下文（用于 Navigator.push）/ Context for navigation',
      required: true,
    ),
    ParkPropertyDef(
      name: 'hint',
      type: 'String?',
      defaultVal: 'null',
      description: '搜索框占位文本 / Search input hint text',
      required: false,
    ),
    ParkPropertyDef(
      name: 'historyScope',
      type: 'String',
      defaultVal: "'default'",
      description: '历史记录作用域 / History storage scope',
      required: false,
    ),
    ParkPropertyDef(
      name: 'history',
      type: 'ParkSearchHistory?',
      defaultVal: 'null',
      description: '自定义历史持久化实现 / Custom history persistence',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onSearch',
      type: 'Future<List<T>> Function(String)?',
      defaultVal: 'null',
      description: '搜索回调（异步返回结果列表）/ Async search callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'suggestionBuilder',
      type: 'List<String> Function(String)?',
      defaultVal: 'null',
      description: '联想建议生成器 / Suggestion builder for keyword',
      required: false,
    ),
    ParkPropertyDef(
      name: 'resultBuilder',
      type: 'Widget Function(BuildContext, String, List<T>)?',
      defaultVal: 'null',
      description: '结果列表构建器 / Result list builder',
      required: false,
    ),
    ParkPropertyDef(
      name: 'emptyBuilder',
      type: 'Widget Function(BuildContext, String)?',
      defaultVal: 'null',
      description: '空结果构建器 / Empty result builder',
      required: false,
    ),
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      defaultVal: 'null',
      description: '页面标题 / Page title',
      required: false,
    ),
    ParkPropertyDef(
      name: 'autofocus',
      type: 'bool',
      defaultVal: 'true',
      description: '是否自动聚焦搜索框 / Auto-focus search input',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSearch',
      signature: 'Future<List<T>> Function(String keyword)?',
      description: '搜索执行回调 / Async search execution callback',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'showParkSearch<T>()',
      signature: 'Future<T?> Function({required BuildContext context, ...})',
      description: '打开全屏搜索页面，返回选中结果或 null / Open full-screen search, returns selected result or null',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础搜索',
      description: '点击按钮打开搜索页 / Tap to open search page',
      code: '''showParkSearch<String>(
  context: context,
  hint: '搜索房源',
  historyScope: 'housing',
  onSearch: (kw) async => ['结果1', '结果2'],
  resultBuilder: (ctx, kw, results) => ListView(
    children: results.map((r) => ListTile(title: Text(r))).toList(),
  ),
)''',
      builder: _buildSearchBasic,
    ),
    ParkDemoScenario(
      title: '带联想建议',
      description: 'suggestionBuilder 联想 / With suggestions',
      code: '''showParkSearch<String>(
  context: context,
  hint: '搜索小区',
  suggestionBuilder: (kw) => ['联想词1', '联想词2'],
  onSearch: (kw) async => [],
)''',
      builder: _buildSearchSuggestion,
    ),
  ],
  basicUsageCode: '''final result = await showParkSearch<String>(
  context: context,
  hint: '搜索房源',
  historyScope: 'housing',
  onSearch: (keyword) async {
    return await api.searchHousing(keyword);
  },
  resultBuilder: (context, keyword, results) {
    return ListView(
      children: results.map((r) => ListTile(title: Text(r))).toList(),
    );
  },
);''',
  guide: '''
## 使用指南 / Usage Guide
showParkSearch<T>() 打开全屏搜索页面，提供完整的搜索体验。

- 自动管理搜索历史（默认内存实现 ParkInMemorySearchHistory）
- 实现 ParkSearchHistory 接口可自定义持久化（SharedPreferences、SQLite 等）
- historyScope 隔离不同业务场景的历史记录
- suggestionBuilder 在输入时提供联想建议
- onSearch 异步执行搜索，resultBuilder 渲染结果
- emptyBuilder 自定义空结果页面
- 返回 Future<T?>：用户选中结果或 null（取消）

## ParkSearchHistory 接口 / Interface
| 方法 | 说明 |
|------|------|
| getHistory(scope) | 获取历史列表 |
| addHistory(scope, keyword) | 添加历史记录 |
| removeHistory(scope, keyword) | 删除单条历史 |
| clearHistory(scope) | 清空历史 |
''',
);

// ===========================================================================
// Demo Builder 函数
// ===========================================================================

// ── ParkFormRow builders ──

Widget _buildFormRowBasic(BuildContext context) {
  return ParkFormRow(
    label: '姓名',
    required: true,
    child: Text(
      '张三',
      style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
    ),
  );
}

Widget _buildFormRowSuffix(BuildContext context) {
  return ParkFormRow(
    label: '面积',
    suffixText: '㎡',
    readOnly: true,
    child: Text(
      '85.5',
      style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
    ),
  );
}

Widget _buildFormRowHelper(BuildContext context) {
  return ParkFormRow(
    label: '手机号',
    helperText: '请输入 11 位手机号码',
    child: Text(
      '138****8888',
      style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
    ),
  );
}

Widget _buildFormRowTap(BuildContext context) {
  return ParkFormRow(
    label: '城市',
    onTap: () {},
    child: Text(
      '请选择',
      style: TextStyle(fontSize: 14, color: _kColors.textPlaceholder),
    ),
  );
}

Widget _buildFormRowNoBg(BuildContext context) {
  return ParkFormRow(
    label: '备注',
    showFieldBackground: false,
    child: Text(
      '无背景字段区域',
      style: TextStyle(fontSize: 14, color: _kColors.textSecondary),
    ),
  );
}

// ── ParkChoiceGroup builders ──

Widget _buildChoiceGroupBasic(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      String value = '1';
      return ParkChoiceGroup(
        items: const [
          ParkChoiceItem(value: '1', label: '整租'),
          ParkChoiceItem(value: '2', label: '合租'),
          ParkChoiceItem(value: '3', label: '短租'),
        ],
        value: value,
        onChanged: (v) => setState(() => value = v),
      );
    },
  );
}

Widget _buildChoiceGroupJoin(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      String value = 'week';
      return ParkChoiceGroup(
        items: const [
          ParkChoiceItem(value: 'day', label: '日'),
          ParkChoiceItem(value: 'week', label: '周'),
          ParkChoiceItem(value: 'month', label: '月'),
        ],
        value: value,
        join: true,
        onChanged: (v) => setState(() => value = v),
      );
    },
  );
}

Widget _buildChoiceGroupVertical(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      String value = 'a';
      return ParkChoiceGroup(
        items: const [
          ParkChoiceItem(value: 'a', label: '选项 A'),
          ParkChoiceItem(value: 'b', label: '选项 B'),
          ParkChoiceItem(value: 'c', label: '选项 C'),
        ],
        value: value,
        direction: Axis.vertical,
        onChanged: (v) => setState(() => value = v),
      );
    },
  );
}

Widget _buildChoiceGroupDisabled(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      String value = '1';
      return ParkChoiceGroup(
        items: const [
          ParkChoiceItem(value: '1', label: '可选'),
          ParkChoiceItem(value: '2', label: '禁用', enabled: false),
          ParkChoiceItem(value: '3', label: '可选'),
        ],
        value: value,
        onChanged: (v) => setState(() => value = v),
      );
    },
  );
}

// ── ParkSheetScaffold builders ──

Widget _buildSheetBasic(BuildContext context) {
  return Builder(
    builder: (ctx) => ElevatedButton(
      onPressed: () {
        ParkSheetScaffold.show(
          context: ctx,
          title: '选择城市',
          bodyHeight: 200,
          child: Center(
            child: Text(
              '面板内容',
              style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
            ),
          ),
        );
      },
      child: const Text('打开面板'),
    ),
  );
}

Widget _buildSheetDisabled(BuildContext context) {
  return Builder(
    builder: (ctx) => ElevatedButton(
      onPressed: () {
        ParkSheetScaffold.show(
          context: ctx,
          title: '选择日期',
          confirmEnabled: false,
          bodyHeight: 160,
          child: Center(
            child: Text(
              '请先选择',
              style: TextStyle(fontSize: 14, color: _kColors.textSecondary),
            ),
          ),
        );
      },
      child: const Text('禁用确认'),
    ),
  );
}

Widget _buildSheetCustomText(BuildContext context) {
  return Builder(
    builder: (ctx) => ElevatedButton(
      onPressed: () {
        ParkSheetScaffold.show(
          context: ctx,
          title: '筛选条件',
          cancelText: '重置',
          confirmText: '应用',
          bodyHeight: 160,
          child: Center(
            child: Text(
              '筛选内容',
              style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
            ),
          ),
        );
      },
      child: const Text('自定义按钮'),
    ),
  );
}

// ── ParkChipGridPicker builders ──

Widget _buildChipGridMulti(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      Set<String> selected = {'1'};
      return ParkChipGridPicker(
        categories: const [
          ParkChipGridCategory(label: '户型', children: [
            ParkChipGridOption(value: '1', label: '一室'),
            ParkChipGridOption(value: '2', label: '二室'),
            ParkChipGridOption(value: '3', label: '三室'),
            ParkChipGridOption(value: '4', label: '四室'),
          ]),
        ],
        selectedValues: selected,
        onChanged: (v) => setState(() => selected = v),
      );
    },
  );
}

Widget _buildChipGridSingle(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      Set<String> selected = {'south'};
      return ParkChipGridPicker(
        categories: const [
          ParkChipGridCategory(label: '朝向', children: [
            ParkChipGridOption(value: 'south', label: '朝南'),
            ParkChipGridOption(value: 'north', label: '朝北'),
            ParkChipGridOption(value: 'east', label: '朝东'),
            ParkChipGridOption(value: 'west', label: '朝西'),
          ]),
        ],
        selectedValues: selected,
        multiSelect: false,
        onChanged: (v) => setState(() => selected = v),
      );
    },
  );
}

Widget _buildChipGridMultiCat(BuildContext context) {
  return StatefulBuilder(
    builder: (context, setState) {
      Set<String> selected = {};
      return ParkChipGridPicker(
        categories: const [
          ParkChipGridCategory(label: '户型', children: [
            ParkChipGridOption(value: '1', label: '一室'),
            ParkChipGridOption(value: '2', label: '二室'),
            ParkChipGridOption(value: '3', label: '三室'),
            ParkChipGridOption(value: '4', label: '四室'),
          ]),
          ParkChipGridCategory(label: '朝向', children: [
            ParkChipGridOption(value: 'south', label: '朝南'),
            ParkChipGridOption(value: 'north', label: '朝北'),
            ParkChipGridOption(value: 'east', label: '朝东'),
            ParkChipGridOption(value: 'west', label: '朝西'),
          ]),
        ],
        selectedValues: selected,
        onChanged: (v) => setState(() => selected = v),
      );
    },
  );
}

// ── ParkSearchDelegate builders ──

Widget _buildSearchBasic(BuildContext context) {
  return Builder(
    builder: (ctx) => ElevatedButton(
      onPressed: () {
        showParkSearch<String>(
          context: ctx,
          hint: '搜索房源',
          historyScope: 'housing',
          onSearch: (kw) async => ['结果1: $kw', '结果2: $kw'],
          resultBuilder: (ctx2, kw, results) => ListView(
            children: results
                .map((r) => ListTile(
                      title: Text(
                        r,
                        style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
                      ),
                    ))
                .toList(),
          ),
        );
      },
      child: const Text('打开搜索'),
    ),
  );
}

Widget _buildSearchSuggestion(BuildContext context) {
  return Builder(
    builder: (ctx) => ElevatedButton(
      onPressed: () {
        showParkSearch<String>(
          context: ctx,
          hint: '搜索小区',
          suggestionBuilder: (kw) => ['$kw 联想词1', '$kw 联想词2'],
          onSearch: (kw) async => <String>[],
        );
      },
      child: const Text('带联想搜索'),
    ),
  );
}

// ============================================================================
// ParkChoiceGroup: ParkBinding 示例
// ============================================================================

class _ChoiceGroupBindingDemo extends StatefulWidget {
  @override
  State<_ChoiceGroupBindingDemo> createState() =>
      _ChoiceGroupBindingDemoState();
}

class _ChoiceGroupBindingDemoState extends State<_ChoiceGroupBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'choice': 'a'});
    _service.watchEffect(() {
      _service.getValue<String>('choice');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkChoiceGroup(
          items: const [
            ParkChoiceItem(value: 'a', label: '选项 A'),
            ParkChoiceItem(value: 'b', label: '选项 B'),
            ParkChoiceItem(value: 'c', label: '选项 C'),
          ],
          bindKey: 'choice',
          bindingService: _service,
          onChanged: (v) {},
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kColors.brand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kColors.brand.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.sync, size: 16, color: _kColors.brand),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: ${_service.model.toString()}',
                  style: TextStyle(fontSize: 13, color: _kColors.brand),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ParkChipGridPicker: ParkBinding 示例
// ============================================================================

class _ChipGridPickerBindingDemo extends StatefulWidget {
  @override
  State<_ChipGridPickerBindingDemo> createState() =>
      _ChipGridPickerBindingDemoState();
}

class _ChipGridPickerBindingDemoState extends State<_ChipGridPickerBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'tags': <String>{'x'},
    });
    _service.watchEffect(() {
      _service.getValue<Set<String>>('tags');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkChipGridPicker(
          categories: const [
            ParkChipGridCategory(label: '标签', children: [
              ParkChipGridOption(value: 'x', label: '标签 X'),
              ParkChipGridOption(value: 'y', label: '标签 Y'),
              ParkChipGridOption(value: 'z', label: '标签 Z'),
            ]),
          ],
          bindKey: 'tags',
          bindingService: _service,
          onChanged: (v) {},
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kColors.brand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kColors.brand.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.sync, size: 16, color: _kColors.brand),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: ${_service.model.toString()}',
                  style: TextStyle(fontSize: 13, color: _kColors.brand),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ParkChoiceGroup: ParkDynamicForm 示例
// ============================================================================

class _ChoiceGroupDynamicFormDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ParkFormSchema schema = ParkFormSchema.fromJson(<String, dynamic>{
      'formKey': 'choice_group_dynamic_form_demo',
      'fields': <Map<String, dynamic>>[
        <String, dynamic>{
          'field_name': 'rentType',
          'label': '租房方式',
          // NOTE: ParkFieldType 暂无 choiceGroup 类型，回退为 radio（单选组）承载。
          'type': 'radio',
          'options': <Map<String, dynamic>>[
            <String, dynamic>{'label': '整租', 'value': '1'},
            <String, dynamic>{'label': '合租', 'value': '2'},
          ],
        },
      ],
    });
    return ParkDynamicForm(
      schema: schema,
      onSubmit: (Map<String, dynamic> values) => debugPrint('submit: $values'),
    );
  }
}

// ============================================================================
// ParkChipGridPicker: ParkDynamicForm 示例
// ============================================================================

class _ChipGridPickerDynamicFormDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ParkFormSchema schema = ParkFormSchema.fromJson(<String, dynamic>{
      'formKey': 'chip_grid_picker_dynamic_form_demo',
      'fields': <Map<String, dynamic>>[
        <String, dynamic>{
          'field_name': 'tags',
          'label': '筛选标签',
          // NOTE: ParkFieldType 暂无 chipGrid 类型，回退为 checkbox（多选组）承载。
          'type': 'checkbox',
          'options': <Map<String, dynamic>>[
            <String, dynamic>{'label': '标签 X', 'value': 'x'},
            <String, dynamic>{'label': '标签 Y', 'value': 'y'},
            <String, dynamic>{'label': '标签 Z', 'value': 'z'},
          ],
        },
      ],
    });
    return ParkDynamicForm(
      schema: schema,
      onSubmit: (Map<String, dynamic> values) => debugPrint('submit: $values'),
    );
  }
}
