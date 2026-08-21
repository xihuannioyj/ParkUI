// Park 输入组件规格 Part 2 — Batch 2（完善版）
//
// 覆盖：ParkPicker / ParkCascader / ParkTreeSelect / ParkSlider
//       ParkStepper / ParkRate / ParkUpload / ParkForm
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
final ParkSpacing _kSpacing = ParkSpacing.defaults();
final ParkTypography _kTypography = ParkTypography.defaults();

/// 输入组件规格字典 Part 2（8 个组件）。
Map<String, ParkComponentSpec> get parkInputSpecsPart2 =>
    <String, ParkComponentSpec>{
      'ParkPicker': _parkPicker,
      'ParkCascader': _parkCascader,
      'ParkTreeSelect': _parkTreeSelect,
      'ParkSlider': _parkSlider,
      'ParkStepper': _parkStepper,
      'ParkRate': _parkRate,
      'ParkUpload': _parkUpload,
      'ParkForm': _parkForm,
    };

// =====================================================================
// ParkPicker
// =====================================================================

final ParkComponentSpec _parkPicker = ParkComponentSpec(
  name: 'ParkPicker',
  title: '滚轮选择器',
  category: 'input',
  description:
      '底部弹出模态面板，使用 CupertinoPicker 滚轮交互，顶部带取消 / 确认操作栏。'
      '通过 ParkPicker.show() 静态方法弹出，返回用户确认选中的 value。'
      '支持搜索过滤、多列选择、自定义选项渲染。',
  icon: Icons.keyboard_alt_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      defaultVal: 'null',
      description: '面板标题，显示在顶部操作栏中间。 / Panel title (top bar center)',
    ),
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkPickerItem>',
      required: true,
      description: '选项列表，每项包含 label 和 value。 / Option list (label + value)',
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'String?',
      defaultVal: 'null',
      description: '当前选中值，用于定位滚轮初始位置。 / Current value (initial wheel position)',
    ),
    ParkPropertyDef(
      name: 'onConfirm',
      type: 'ValueChanged<String>?',
      defaultVal: 'null',
      description: '确认回调，返回选中的 value。 / Confirm callback (selected value)',
    ),
    ParkPropertyDef(
      name: 'searchable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用搜索过滤。 / Enable search filter',
    ),
    ParkPropertyDef(
      name: 'searchHintText',
      type: 'String',
      defaultVal: "'搜索选项'",
      description: '搜索框占位文案。 / Search box placeholder',
    ),
    ParkPropertyDef(
      name: 'multiColumn',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否为多列模式（使用 columns 数据展示多个并排滚轮）。 / Multi-column mode (side-by-side wheels)',
    ),
    ParkPropertyDef(
      name: 'columns',
      type: 'List<List<ParkPickerItem>>?',
      defaultVal: 'null',
      description:
          '多列模式下的列数据（仅 multiColumn 为 true 时有效）。 / Column data (when multiColumn)',
    ),
    ParkPropertyDef(
      name: 'onMultiConfirm',
      type: 'ValueChanged<List<String>>?',
      defaultVal: 'null',
      description: '多列模式下的确认回调，返回每列选中值的列表。 / Multi-column confirm callback',
    ),
    ParkPropertyDef(
      name: 'values',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '多列模式下的当前选中值列表。 / Current multi-column values',
    ),
    ParkPropertyDef(
      name: 'confirmText',
      type: 'String?',
      defaultVal: 'null（默认"确认"）',
      description: '确认按钮文字。 / Confirm button text',
    ),
    ParkPropertyDef(
      name: 'cancelText',
      type: 'String?',
      defaultVal: 'null（默认"取消"）',
      description: '取消按钮文字。 / Cancel button text',
    ),
    ParkPropertyDef(
      name: 'itemBuilder',
      type: 'ParkPickerItemBuilder?',
      defaultVal: 'null',
      description:
          '自定义选项渲染器（Widget Function(ParkPickerItem, bool)）。 / Custom item renderer',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。 /'
          ' Binding key (dot path); enables two-way binding via ParkBindingService.',
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
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onConfirm',
      signature: 'ValueChanged<String>',
      description:
          '用户点击确认时触发，参数为选中的 value。 / Fired on confirm (selected value)',
    ),
    ParkEventDef(
      name: 'onMultiConfirm',
      signature: 'ValueChanged<List<String>>',
      description: '多列模式确认时触发，参数为每列选中值的列表。 / Fired on multi-column confirm',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'show',
      signature:
          'static Future<String?> show(BuildContext context, {String? title, required List<ParkPickerItem> items, String? value, ValueChanged<String>? onConfirm, bool searchable, String searchHintText, String? confirmText, String? cancelText, ParkPickerItemBuilder? itemBuilder})',
      description:
          '弹出选择器底部面板。返回用户确认选中的 value，取消时返回 null。 / Show bottom picker panel; returns confirmed value or null on cancel.',
    ),
    ParkMethodDef(
      name: 'showMultiColumn',
      signature:
          'static Future<List<String>?> showMultiColumn(BuildContext context, {String? title, required List<List<ParkPickerItem>> columns, List<String>? values, ValueChanged<List<String>>? onConfirm, String? confirmText, String? cancelText, ParkPickerItemBuilder? itemBuilder})',
      description:
          '弹出多列选择器面板。返回用户确认选中的各列 value 列表，取消时返回 null。 / Show multi-column picker; returns list of column values or null.',
    ),
  ],
  basicUsageCode: '''
final result = await ParkPicker.show(
  context: context,
  title: '选择城市',
  items: [
    ParkPickerItem(label: '北京', value: 'beijing'),
    ParkPickerItem(label: '上海', value: 'shanghai'),
    ParkPickerItem(label: '广州', value: 'guangzhou'),
    ParkPickerItem(label: '深圳', value: 'shenzhen'),
  ],
  value: 'beijing',
);
if (result != null) {
  print('选中: \$result');
}
''',
  guide: '''
## 何时使用 / When to use
- 移动端底部弹出滚轮选择场景 / Bottom-sheet wheel picker (mobile)
- 城市、语言、数量等单列选择 / City, language, quantity (single column)
- 内联模式：将选择器嵌入页面内容，搭配 ParkCell 等组件作为触发器 / Inline mode: embed picker in page with ParkCell as trigger

## 使用建议 / Usage tips
- 通过 ParkPicker.show() 静态方法弹出，返回选中值 / Pop via ParkPicker.show(); returns value
- 设置 value 参数定位滚轮初始位置 / value sets initial wheel position
- 选项不宜过多，建议控制在 20 个以内 / Keep options <= 20
- 多级选择场景使用 ParkCascader 替代 / Use ParkCascader for multi-level
- 取消时返回 null，需做判空处理 / Cancel returns null; handle null
- searchable: true 启用搜索过滤 / searchable enables filter
- multiColumn 模式使用 columns 配置多列并排滚轮 / multiColumn for side-by-side wheels
- 多列确认监听 onMultiConfirm / Listen onMultiConfirm for multi-column

## 内联模式 / Inline Mode（§7.18）
- ParkPicker 可直接嵌入 Widget 树（不调用 `show()` 静态方法），以内联滚轮形式展示
- 内联模式下不会弹出底部面板路由，不操作导航栈，选中后不 pop 宿主页面
- 内联 `_dismiss()` 方法自动检测路由类型：仅 `PopupRoute` 时弹出导航栈，内联 `PageRoute` 下无操作
- 适合需要将选择器嵌入页面内容、而非弹出层展示的场景

## 搭配推荐 / Compose with
- 搭配 ParkCell 做列表项触发器：ParkCell 展示当前选择值，点击展开内联 ParkPicker
- 搭配 ParkInput 做表单中的选择字段 / Pair with ParkInput
- 搭配 ParkForm 做完整表单 / Pair with ParkForm
- 搭配 ParkCascader 做多级联动选择 / Pair with ParkCascader

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG 无独立 Picker，常用 `DatePicker` / `TimePicker` / 自定义 `Picker`（rc-picker 滚轮）。TDesign Flutter 有 `Picker`：底部弹层 + 单列/多列滚轮，支持 `title` / `confirmBtn` / `cancelBtn` / `pickers`（多列）。
- park Picker 覆盖 TDesign 能力：`show()` / `showMultiColumn()` 静态方法、`searchable` 过滤、`multiColumn` + `columns` 多列、`confirmText` / `cancelText` 文案、`itemBuilder` 自定义、`bindKey` 绑定。
### 示例 / Examples
- 对标 TDesign `Picker(pickers: [col1, col2])` → park `ParkPicker(multiColumn: true, columns: [col1, col2])` 或 `ParkPicker.showMultiColumn(columns: ...)`。
- 对标 TDesign `confirmBtn="确定"` → park `confirmText: '确定'`。
### 属性 / Props
- 差异点：park 以 `ParkPicker.show()` 命令式弹出（Ant/TDesign 多为声明式组件）；park `searchable` 在 TDesign Picker 中无原生等价；park `bindKey` 是表单绑定独有。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础选择器',
      description: '弹出底部滚轮选择器，选择城市。',
      code: '''
ParkPicker(
  title: '选择城市',
  items: [
    ParkPickerItem(label: '北京', value: 'beijing'),
    ParkPickerItem(label: '上海', value: 'shanghai'),
    ParkPickerItem(label: '广州', value: 'guangzhou'),
  ],
  onConfirm: (v) => setState(() => _selected = v),
)
''',
      builder: (context) => _PickerBasicDemo(),
    ),
    ParkDemoScenario(
      title: '带默认值',
      description: '预设选中值，滚轮自动定位到对应选项。',
      code: '''
ParkPicker(
  title: '选择语言',
  items: [
    ParkPickerItem(label: '中文', value: 'zh'),
    ParkPickerItem(label: 'English', value: 'en'),
    ParkPickerItem(label: '日本語', value: 'ja'),
  ],
  value: 'en',
  onConfirm: (v) => setState(() => _lang = v),
)
''',
      builder: (context) => _PickerDefaultValueDemo(),
    ),
    ParkDemoScenario(
      title: '通过 show 静态方法弹出',
      description: '点击按钮通过 ParkPicker.show() 弹出选择面板。',
      code: '''
GestureDetector(
  onTap: () async {
    final result = await ParkPicker.show(
      context: context,
      title: '选择数量',
      items: List.generate(10, (i) =>
        ParkPickerItem(label: '\${i + 1} 个', value: '\${i + 1}')),
    );
  },
  child: Text('点击弹出选择器'),
)
''',
      builder: (context) => _PickerShowDemo(),
    ),
    ParkDemoScenario(
      title: '多列选择器',
      description: 'multiColumn 模式使用 columns 配置多列并排滚轮，onMultiConfirm 回传各列值。',
      code: '''
ParkPicker(
  title: '选择省/市',
  items: const <ParkPickerItem>[],
  multiColumn: true,
  columns: const [
    [ParkPickerItem(label: '浙江', value: 'zj'), ParkPickerItem(label: '江苏', value: 'js')],
    [ParkPickerItem(label: '杭州', value: 'hz'), ParkPickerItem(label: '南京', value: 'nj')],
  ],
  values: const ['zj', 'hz'],
  onMultiConfirm: (vals) => setState(() => _cols = vals),
)
''',
      builder: (context) => _PickerMultiColumnDemo(),
    ),
    ParkDemoScenario(
      title: '内联模式与 ParkCell 搭配',
      description:
          'ParkCell 作为触发器展示当前选择值，点击展开内联 ParkPicker，'
          '选中后不 pop 宿主页面。',
      code: '''
ParkCell(
  titleText: '选择城市',
  note: _selectedLabel,
  arrow: true,
  onPressed: () => setState(() => _expanded = !_expanded),
)
if (_expanded)
  SizedBox(
    height: 220,
    child: ParkPicker(
      title: '选择城市',
      items: cityItems,
      value: _selected,
      onConfirm: (v) => setState(() {
        _selected = v;
        _expanded = false;
      }),
    ),
  )
''',
      builder: (context) => _PickerInlineCellDemo(),
    ),
    // ── ParkPicker: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中值实时同步到 model。'
          ' / ParkBindingService bindKey demo: picker selection syncs to model in real time.',
      code: '''
final service = ParkBindingService({'city': 'beijing'});

ParkPicker(
  title: '选择城市',
  bindKey: 'city',
  bindingService: service,
  items: [
    ParkPickerItem(label: '北京', value: 'beijing'),
    ParkPickerItem(label: '上海', value: 'shanghai'),
    ParkPickerItem(label: '广州', value: 'guangzhou'),
  ],
  onConfirm: (v) => service.setValue('city', v),
)''',
      builder: (context) => _PickerBindingDemo(),
    ),
    // ── ParkPicker: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用。'
          ' / ParkForm schema usage.',
      code: '''
ParkForm(
  schemas: [
    ParkFormFieldSchema(
      fieldId: 'f_city',
      fieldType: ParkFieldType.picker,
      labelName: '选择城市',
      fieldName: 'city',
      isRequired: true,
      fieldPrompt: '请选择城市',
      options: [
        {'label': '北京', 'value': 'beijing'},
        {'label': '上海', 'value': 'shanghai'},
        {'label': '广州', 'value': 'guangzhou'},
      ],
    ),
  ],
  onSubmit: (values) => print(values),
)
''',
      builder: (BuildContext context) => ParkForm(
        schema: const ParkFormSchema(
          formKey: 'park_picker_dynamic_form_demo',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_city',
              fieldType: ParkFieldType.picker,
              labelName: '选择城市',
              fieldName: 'city',
              isRequired: true,
              fieldPrompt: '请选择城市',
              options: [
                {'label': '北京', 'value': 'beijing'},
                {'label': '上海', 'value': 'shanghai'},
                {'label': '广州', 'value': 'guangzhou'},
              ],
            ),
          ],
        ),
        onSubmit: (Map<String, dynamic> values) {},
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`picker`（底部弹出滚轮选择器）。

### 适用场景
- 单/多列、无搜索框的滚轮选择（如省市简选、数量档位）。
- 选项较少且希望底部弹窗交互的字段。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `picker` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `dataSourceType` | `data_source_type` | 选项来源 | 否 |
| `options` | `options` | 静态选项列表 | 否 |
| `ext` | `ext` | 多列 / 搜索等业务扩展 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_level',
  fieldType: ParkFieldType.picker,
  labelName: '会员等级',
  fieldName: 'level',
  options: [
    {'label': '普通', 'value': 'normal'},
    {'label': 'VIP', 'value': 'vip'},
  ],
)
```

### 进阶技巧
- 选项来源同 `select`：`dataSourceType + dataSourceKey` 或 `options`。
- 多列场景经 `ext` 配置列数据；`fieldControl` 可标记子类型。
- 联动：`setValue` 动作按条件写入默认值。''',
);

class _PickerBasicDemo extends StatefulWidget {
  @override
  State<_PickerBasicDemo> createState() => _PickerBasicDemoState();
}

class _PickerBasicDemoState extends State<_PickerBasicDemo> {
  String _selected = 'beijing';

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前选择: $_selected',
          style: TextStyle(
            fontSize: park.typography.sizeBody,
            color: park.colors.textPrimary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        SizedBox(
          height: 260,
          child: ParkPicker(
            title: '选择城市',
            items: const [
              ParkPickerItem(label: '北京', value: 'beijing'),
              ParkPickerItem(label: '上海', value: 'shanghai'),
              ParkPickerItem(label: '广州', value: 'guangzhou'),
              ParkPickerItem(label: '深圳', value: 'shenzhen'),
              ParkPickerItem(label: '杭州', value: 'hangzhou'),
            ],
            value: _selected,
            onConfirm: (v) => setState(() => _selected = v),
          ),
        ),
      ],
    );
  }
}

class _PickerDefaultValueDemo extends StatefulWidget {
  @override
  State<_PickerDefaultValueDemo> createState() =>
      _PickerDefaultValueDemoState();
}

class _PickerDefaultValueDemoState extends State<_PickerDefaultValueDemo> {
  String _lang = 'en';

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前语言: $_lang',
          style: TextStyle(
            fontSize: park.typography.sizeBody,
            color: park.colors.textPrimary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        SizedBox(
          height: 260,
          child: ParkPicker(
            title: '选择语言',
            items: const [
              ParkPickerItem(label: '中文', value: 'zh'),
              ParkPickerItem(label: 'English', value: 'en'),
              ParkPickerItem(label: '日本語', value: 'ja'),
              ParkPickerItem(label: '한국어', value: 'ko'),
            ],
            value: _lang,
            onConfirm: (v) => setState(() => _lang = v),
          ),
        ),
      ],
    );
  }
}

class _PickerShowDemo extends StatefulWidget {
  @override
  State<_PickerShowDemo> createState() => _PickerShowDemoState();
}

class _PickerShowDemoState extends State<_PickerShowDemo> {
  String _result = '未选择';

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '结果: $_result',
          style: TextStyle(
            fontSize: park.typography.sizeBody,
            color: park.colors.textPrimary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        Container(
          padding: EdgeInsets.all(_kSpacing.md),
          decoration: BoxDecoration(
            color: park.colors.brand.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(park.radius.md),
          ),
          child: GestureDetector(
            onTap: () async {
              final r = await ParkPicker.show(
                context,
                title: '选择数量',
                items: List.generate(
                  10,
                  (i) => ParkPickerItem(label: '${i + 1} 个', value: '${i + 1}'),
                ),
              );
              if (r != null) setState(() => _result = '$r 个');
            },
            child: Text(
              '点击弹出选择器',
              style: TextStyle(
                fontSize: park.typography.sizeBody,
                color: park.colors.brand,
                fontWeight: park.typography.weightMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// ParkCascader
// =====================================================================

final ParkComponentSpec _parkCascader = ParkComponentSpec(
  name: 'ParkCascader',
  title: '级联选择器',
  category: 'input',
  description:
      '继承 FormField，支持多级级联选择。点击输入框弹出底部面板，'
      '面板内按层级展示列导航，面包屑标签页切换层级。'
      '支持搜索过滤、changeOnSelect（非叶子节点选择）、displayRender 自定义显示。',
  icon: Icons.account_tree_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'options',
      type: 'List<ParkCascaderOption>',
      required: true,
      description:
          '级联选项树，每个节点包含 label、value 和可选 children。 / Cascading option tree (label/value/children)',
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'List<String>?',
      defaultVal: 'null',
      description:
          '当前选中路径（值为各级 value 的列表）。 / Selected path (list of values per level)',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<List<String>?>?',
      defaultVal: 'null',
      description: '选中路径变更回调，参数为各级 value 组成的列表。 / Called on path change',
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String?',
      defaultVal: "'请选择'",
      description: '输入框占位文字。 / Placeholder text',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '输入框标签，显示在输入框上方。 / Label above field',
    ),
    ParkPropertyDef(
      name: 'enabled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用（false 时禁用输入框）。 / Enabled',
    ),
    ParkPropertyDef(
      name: 'emptyText',
      type: 'String',
      defaultVal: "'暂无数据'",
      description: '空态文案。 / Empty-state text',
    ),
    ParkPropertyDef(
      name: 'searchable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用搜索（跨层级模糊搜索）。 / Enable cross-level fuzzy search',
    ),
    ParkPropertyDef(
      name: 'changeOnSelect',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否允许选择非叶子节点（为 true 时选择中间层级也会触发确认）。 / Allow selecting non-leaf nodes',
    ),
    ParkPropertyDef(
      name: 'displayRender',
      type: 'String Function(List<String>)?',
      defaultVal: 'null',
      description:
          '自定义显示文字格式化函数。入参为已选各级 label 列表，返回显示文字。 / Custom display formatter (labels -> text)',
    ),
    ParkPropertyDef(
      name: 'expandTrigger',
      type: 'ParkCascaderExpandTrigger',
      defaultVal: 'ParkCascaderExpandTrigger.click',
      description:
          '展开子级触发方式：click（点击展开）/ hover（悬停展开，仅桌面端）。 / Expand trigger: click / hover',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。 /'
          ' Binding key (dot path); enables two-way binding via ParkBindingService.',
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
    ),
    ParkPropertyDef(
      name: 'showSearch',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在弹出面板顶部显示搜索输入框，实时过滤级联选项（按 label 匹配）。 / Show search input in panel',
    ),
    ParkPropertyDef(
      name: 'multiple',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用多选模式。为 true 时每个选项前显示复选框，父节点选中联动子节点。 / Enable multi-select mode',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkCascaderSize',
      defaultVal: 'ParkCascaderSize.medium',
      description: '级联选择器尺寸：small（紧凑）/ medium（默认）/ large（宽松），控制内边距、字号与图标大小。 / Size: small / medium / large',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<List<String>?>',
      description: '选中路径变更时触发，参数为各级 value 的列表。 / Fired on path change',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<List<String>>',
      description: '表单保存回调（继承自 FormField）。 / Form save callback',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<List<String>>',
      description: '表单校验器（继承自 FormField）。 / Form validator',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkCascader(
  label: '地区',
  hintText: '请选择省/市/区',
  options: [
    ParkCascaderOption(
      label: '浙江省', value: 'zj',
      children: [
        ParkCascaderOption(label: '杭州市', value: 'hz'),
        ParkCascaderOption(label: '宁波市', value: 'nb'),
      ],
    ),
    ParkCascaderOption(
      label: '江苏省', value: 'js',
      children: [
        ParkCascaderOption(label: '南京市', value: 'nj'),
        ParkCascaderOption(label: '苏州市', value: 'sz'),
      ],
    ),
  ],
  onChanged: (path) => print('选中路径: \$path'),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要从层级数据中选择时（省市区、部门-团队、分类-子分类） / Choose from hierarchical data
- 多级联动选择场景 / Multi-level linked selection

## 使用建议 / Usage tips
- 数据结构通过 ParkCascaderOption.children 嵌套 / Nest via ParkCascaderOption.children
- 选中结果为路径列表（如 ['zj', 'hz']），表示各级 value / Result is path list of values
- 通过 value 预设选中路径 / Preset path via value
- 层级不宜超过 3 层，过多时考虑分步选择 / Keep <= 3 levels
- 搭配 validator 做必填校验 / Required validation via validator
- searchable: true 启用跨层级搜索 / searchable for cross-level search
- changeOnSelect: true 允许选择非叶子节点（如全部分类） / changeOnSelect allows non-leaf
- displayRender 自定义选中文字的显示格式 / displayRender formats the display text

## 搭配推荐 / Compose with
- 搭配 ParkForm 做级联表单 / Pair with ParkForm
- 搭配 ParkSelect 做平级下拉 / Pair with ParkSelect
- 搭配 ParkInput 做混合表单 / Pair with ParkInput

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Cascader：options / value / onChange / changeOnSelect / expandTrigger / showSearch / displayRender / popupVisible；对标 `changeOnSelect`、`expandTrigger`、`displayRender` 同名；`showSearch` 即 park `searchable`。
- TDesign Flutter Cascader：value / options / title / subtitle / theme(step/tab) / checkStrictly / onPick / onChange；移动端用「步骤/标签页」切换层级（tab 主题对标面包屑）。
- park Cascader 覆盖二者：ParkCascaderOption 树、`value` 路径列表、`searchable` 跨层级搜索、`changeOnSelect` 非叶子选择、`displayRender` 自定义、`expandTrigger` click/hover、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<Cascader changeOnSelect showSearch />` → park `ParkCascader(changeOnSelect: true, searchable: true)`。
- 对标 Ant `expandTrigger="hover"` → park `expandTrigger: ParkCascaderExpandTrigger.hover`。
- 对标 TDesign `checkStrictly` → park `changeOnSelect: true`。
### 属性 / Props
- 差异点：park `displayRender` 是 Ant 同名能力的等效；park `expandTrigger: hover` 是桌面端悬停展开独有；park `bindKey` 是表单绑定独有；park 无 Ant 的 `popupVisible` 受控展开（由内部面板管理）。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础级联选择',
      description: '两级级联，选择省市。',
      code: '''
ParkCascader(
  label: '地区',
  hintText: '请选择省/市',
  options: _demoCascaderOptions,
  onChanged: (path) => setState(() => _path = path),
)
''',
      builder: (context) => _CascaderBasicDemo(),
    ),
    ParkDemoScenario(
      title: '带默认值',
      description: '预设选中路径，输入框显示已选值。',
      code: '''
ParkCascader(
  label: '地区',
  value: ['zj', 'hz'],
  options: _demoCascaderOptions,
  onChanged: (path) => setState(() => _path = path),
)
''',
      builder: (context) => _CascaderDefaultValueDemo(),
    ),
    ParkDemoScenario(
      title: '带表单校验',
      description: '使用 validator 校验是否已选择。',
      code: '''
ParkCascader(
  label: '地区',
  hintText: '请选择地区',
  options: _demoCascaderOptions,
  validator: (v) => (v == null || v.isEmpty) ? '请选择地区' : null,
)
''',
      builder: (context) => _CascaderValidationDemo(),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: '设置 enabled: false 禁用选择器。',
      code: '''
ParkCascader(
  label: '地区（已禁用）',
  value: ['zj', 'hz'],
  options: _demoCascaderOptions,
  enabled: false,
)
''',
      builder: (context) => Padding(
        padding: const EdgeInsets.only(right: 0),
        child: ParkCascader(
          label: '地区（已禁用）',
          value: ['zj', 'hz'],
          options: _demoCascaderOptions,
          enabled: false,
        ),
      ),
    ),
    // ── ParkCascader: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中值实时同步到 model。'
          ' / ParkBindingService bindKey demo: cascader selection syncs to model in real time.',
      code: '''
final service = ParkBindingService({'region': ['zj', 'hz']});

ParkCascader(
  label: '地区',
  bindKey: 'region',
  bindingService: service,
  options: _demoCascaderOptions,
)''',
      builder: (BuildContext context) => _CascaderBindingDemo(),
    ),
    ParkDemoScenario(
      title: '保存回调 onSaved',
      description: '通过 Form.save() 触发 ParkCascader 的 onSaved 回调，捕获所选路径。',
      code: '''
Form(
  key: _cascaderFormKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      ParkCascader(
        label: '地区',
        hintText: '请选择地区',
        options: _demoCascaderOptions,
        onSaved: (path) => setState(() => _saved = path),
      ),
      SizedBox(height: _kSpacing.sm),
      ParkButton(
        onPressed: () => _cascaderFormKey.currentState?.save(),
        child: const ParkText('保存'),
      ),
      if (_saved != null)
        Text('已保存: \${_saved!.join(" / ")}',
            style: TextStyle(fontSize: _kTypography.sizeBodySmall, color: _kColors.textSecondary)),
    ],
  ),
)
''',
      builder: (context) => _CascaderSavedDemo(),
    ),
    // ── ParkCascader: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用 cascader 字段类型。'
          ' / ParkForm fieldType=cascader demo.',
      code: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'cascader_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_region',
        fieldType: ParkFieldType.cascader,
        labelName: '地区',
        fieldName: 'region',
        isRequired: true,
        options: [
          {'label': '浙江省', 'value': 'zj', 'children': [
            {'label': '杭州市', 'value': 'hz'},
            {'label': '宁波市', 'value': 'nb'},
          ]},
          {'label': '江苏省', 'value': 'js', 'children': [
            {'label': '南京市', 'value': 'nj'},
            {'label': '苏州市', 'value': 'sz'},
          ]},
        ],
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkForm(
          schema: ParkFormSchema(
            formKey: 'cascader_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_region',
                fieldType: ParkFieldType.cascader,
                labelName: '地区',
                fieldName: 'region',
                isRequired: true,
                options: <Map<String, dynamic>>[
                  <String, dynamic>{
                    'label': '浙江省',
                    'value': 'zj',
                    'children': <Map<String, dynamic>>[
                      <String, dynamic>{'label': '杭州市', 'value': 'hz'},
                      <String, dynamic>{'label': '宁波市', 'value': 'nb'},
                    ],
                  },
                  <String, dynamic>{
                    'label': '江苏省',
                    'value': 'js',
                    'children': <Map<String, dynamic>>[
                      <String, dynamic>{'label': '南京市', 'value': 'nj'},
                      <String, dynamic>{'label': '苏州市', 'value': 'sz'},
                    ],
                  },
                ],
              ),
            ],
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`cascader`（多级级联选择）。

### 适用场景
- 省市区、类目树等多级联动选择。
- 选项呈父子层级、需逐级展开。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `cascader` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `dataSourceType` | `data_source_type` | 选项来源（通常 api/dict 返回树） | 否 |
| `options` | `options` | 静态树（含 `children`） | 否 |
| `optionChildrenKey` | `option_children_key` | 子节点键名（默认 `children`） | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_region',
  fieldType: ParkFieldType.cascader,
  labelName: '地区',
  fieldName: 'region',
  isRequired: true,
  options: [
    {
      'label': '广东',
      'value': 'gd',
      'children': [
        {'label': '深圳', 'value': 'sz'},
      ],
    },
  ],
)
```

### 进阶技巧
- 树形选项：`options` 中每项的 `children` 为下一级（键名可用 `optionChildrenKey` 覆盖）。
- 远程树：`dataSourceType: api` + `dataSourceKey`；`dataSourceParams` 可引用其它字段（\u{24}form.xxx）。
- 联动：`reloadOptions` 在父级变化后刷新子树。''',
);

const _demoCascaderOptions = <ParkCascaderOption>[
  ParkCascaderOption(
    label: '浙江省',
    value: 'zj',
    children: [
      ParkCascaderOption(label: '杭州市', value: 'hz'),
      ParkCascaderOption(label: '宁波市', value: 'nb'),
      ParkCascaderOption(label: '温州市', value: 'wz'),
    ],
  ),
  ParkCascaderOption(
    label: '江苏省',
    value: 'js',
    children: [
      ParkCascaderOption(label: '南京市', value: 'nj'),
      ParkCascaderOption(label: '苏州市', value: 'sz'),
      ParkCascaderOption(label: '无锡市', value: 'wx'),
    ],
  ),
  ParkCascaderOption(
    label: '广东省',
    value: 'gd',
    children: [
      ParkCascaderOption(label: '广州市', value: 'gz'),
      ParkCascaderOption(label: '深圳市', value: 'sz2'),
    ],
  ),
];

class _CascaderBasicDemo extends StatefulWidget {
  @override
  State<_CascaderBasicDemo> createState() => _CascaderBasicDemoState();
}

class _CascaderBasicDemoState extends State<_CascaderBasicDemo> {
  List<String>? _path;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkCascader(
          label: '地区',
          hintText: '请选择省/市',
          options: _demoCascaderOptions,
          onChanged: (path) => setState(() => _path = path),
        ),
        if (_path != null) ...[
          SizedBox(height: _kSpacing.sm),
          Text(
            '选中路径: ${_path!.join(" / ")}',
            style: TextStyle(
              fontSize: park.typography.sizeBodySmall,
              color: park.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _CascaderDefaultValueDemo extends StatefulWidget {
  @override
  State<_CascaderDefaultValueDemo> createState() =>
      _CascaderDefaultValueDemoState();
}

class _CascaderDefaultValueDemoState extends State<_CascaderDefaultValueDemo> {
  List<String>? _path = ['zj', 'hz'];

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkCascader(
          label: '地区',
          value: _path,
          options: _demoCascaderOptions,
          onChanged: (path) => setState(() => _path = path),
        ),
        if (_path != null) ...[
          SizedBox(height: _kSpacing.sm),
          Text(
            '选中路径: ${_path!.join(" / ")}',
            style: TextStyle(
              fontSize: park.typography.sizeBodySmall,
              color: park.colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _CascaderValidationDemo extends StatefulWidget {
  @override
  State<_CascaderValidationDemo> createState() =>
      _CascaderValidationDemoState();
}

class _CascaderValidationDemoState extends State<_CascaderValidationDemo> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParkCascader(
            label: '地区',
            hintText: '请选择地区',
            options: _demoCascaderOptions,
            validator: (v) => (v == null || v.isEmpty) ? '请选择地区' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          SizedBox(height: _kSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _kSpacing.lg,
              vertical: _kSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: park.colors.brand,
              borderRadius: BorderRadius.circular(park.radius.md),
            ),
            child: GestureDetector(
              onTap: () => _formKey.currentState?.validate(),
              child: Text(
                '校验',
                style: TextStyle(
                  color: park.colors.textOnBrand,
                  fontSize: park.typography.sizeBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ParkTreeSelect
// =====================================================================

final ParkComponentSpec _parkTreeSelect = ParkComponentSpec(
  name: 'ParkTreeSelect',
  title: '树选择器',
  category: 'input',
  description:
      '可展开的树结构，支持单选 / 多选、复选框联动（父子关联）。'
      '自动展开有选中子节点的父级，支持 indeterminate 半选状态。'
      '支持搜索过滤、严格模式、全展开、连接线、自定义展开图标、maxTagCount。',
  icon: Icons.filter_alt_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'nodes',
      type: 'List<ParkTreeNode>',
      required: true,
      description: '树节点列表。每个 ParkTreeNode 包含 key、label、可选 children 和 disabled。',
    ),
    ParkPropertyDef(
      name: 'selectedKeys',
      type: 'Set<String>',
      defaultVal: 'const {}',
      description: '已选中的节点 key 集合。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<Set<String>>?',
      defaultVal: 'null',
      description: '选中状态变更回调，参数为更新后的 key 集合。',
    ),
    ParkPropertyDef(
      name: 'multiple',
      type: 'bool',
      defaultVal: 'false',
      description: '是否多选模式。false 时为单选。',
    ),
    ParkPropertyDef(
      name: 'checkable',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示复选框。',
    ),
    ParkPropertyDef(
      name: 'searchable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用搜索过滤。',
    ),
    ParkPropertyDef(
      name: 'searchHintText',
      type: 'String',
      defaultVal: "'搜索节点'",
      description: '搜索框占位文案。',
    ),
    ParkPropertyDef(
      name: 'treeCheckStrictly',
      type: 'bool',
      defaultVal: 'false',
      description: '父子节点选中状态是否严格独立（true 时父节点选中不影响子节点）。',
    ),
    ParkPropertyDef(
      name: 'treeDefaultExpandAll',
      type: 'bool',
      defaultVal: 'false',
      description: '初始化时是否展开所有节点。',
    ),
    ParkPropertyDef(
      name: 'treeLine',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示树形连接线。',
    ),
    ParkPropertyDef(
      name: 'switcherIcon',
      type: 'ParkTreeSwitcherIconBuilder?',
      defaultVal: 'null',
      description: '自定义展开/折叠图标构建器（Widget Function(bool isExpanded)）。',
    ),
    ParkPropertyDef(
      name: 'maxTagCount',
      type: 'int?',
      defaultVal: 'null',
      description: '多选模式下可见选中标签的最大数量，超出部分以 "+N" 显示。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
    ParkPropertyDef(
      name: 'treeCheckable',
      type: 'bool',
      defaultVal: 'false',
      description: '启用树复选框模式。为 true 时每个树节点前显示复选框，支持多选、父子联动半选。',
    ),
    ParkPropertyDef(
      name: 'showSearch',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在弹出面板顶部显示搜索输入框，输入实时过滤树节点。',
    ),
    ParkPropertyDef(
      name: 'checkedKeys',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '受控选中节点 key 列表（配合 treeCheckable 使用）。非 null 时组件使用此值作为受控选中项。',
    ),
    ParkPropertyDef(
      name: 'defaultCheckedKeys',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '非受控初始选中 keys（配合 treeCheckable 使用）。仅在初始化时生效。',
    ),
    ParkPropertyDef(
      name: 'checkStrictly',
      type: 'bool',
      defaultVal: 'false',
      description: '父子节点选中是否严格独立。为 true 时子节点选中不影响父节点状态。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<Set<String>>',
      description: '选中状态变更时触发，参数为更新后的 key 集合。',
    ),
    ParkEventDef(
      name: 'onCheck',
      signature: 'void Function(List<String>, String?)?',
      description: '选中项变化回调（配合 treeCheckable 使用）。checkedKeys 为当前所有选中叶子节点的 key 列表，halfCheckedKey 为当前处于半选状态的父节点 key。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkTreeSelect(
  nodes: [
    ParkTreeNode(
      key: 'dept1',
      label: '研发部',
      children: [
        ParkTreeNode(key: 'team1', label: '前端组'),
        ParkTreeNode(key: 'team2', label: '后端组'),
      ],
    ),
    ParkTreeNode(
      key: 'dept2',
      label: '设计部',
      children: [
        ParkTreeNode(key: 'team3', label: 'UI 组'),
        ParkTreeNode(key: 'team4', label: 'UX 组'),
      ],
    ),
  ],
  selectedKeys: {'team1'},
  multiple: true,
  checkable: true,
  onChanged: (keys) => print('选中: \$keys'),
)
''',
  guide: '''
## 何时使用
- 需要从树形结构数据中选择时（组织架构、文件目录、分类树）
- 权限分配、部门选择等场景

## 使用建议
- 单选模式设置 checkable: false，点击叶子节点选中
- 多选模式开启 checkable: true，支持父子联动
- 通过 ParkTreeNode.disabled 禁用特定节点
- 自动展开有选中子节点的父级
- 数据层级建议不超过 4 层
- searchable: true 启用搜索过滤
- treeCheckStrictly: true 使父子选择独立
- treeDefaultExpandAll: true 初始化展开全部节点
- treeLine: true 显示连接线

## 搭配推荐
- 搭配 ParkForm 做树形选择表单
- 搭配 ParkTag 展示已选节点
- 搭配 ParkSearch 做树节点搜索过滤
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '单选模式',
      description: '单选树，不带复选框，点击叶子节点选中。',
      code: '''
ParkTreeSelect(
  nodes: _demoTreeNodes,
  selectedKeys: _selected,
  checkable: false,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectSingleDemo(),
    ),
    ParkDemoScenario(
      title: '多选模式',
      description: '多选树，带复选框，支持父子联动。',
      code: '''
ParkTreeSelect(
  nodes: _demoTreeNodes,
  selectedKeys: _selected,
  multiple: true,
  checkable: true,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectMultipleDemo(),
    ),
    ParkDemoScenario(
      title: '含禁用节点',
      description: '部分节点设置 disabled，不可选中。',
      code: '''
ParkTreeSelect(
  nodes: [
    ParkTreeNode(key: 'a', label: '可用节点 A'),
    ParkTreeNode(key: 'b', label: '禁用节点 B', disabled: true),
    ParkTreeNode(key: 'c', label: '可用节点 C'),
  ],
  selectedKeys: _selected,
  checkable: true,
  multiple: true,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectDisabledDemo(),
    ),
    ParkDemoScenario(
      title: '搜索过滤',
      description: 'searchable: true 启用搜索过滤。',
      code: '''
ParkTreeSelect(
  nodes: _demoTreeNodes,
  selectedKeys: _selected,
  multiple: true,
  searchable: true,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectSearchableDemo(),
    ),
    ParkDemoScenario(
      title: '连接线',
      description: 'treeLine: true 显示树形连接线。',
      code: '''
ParkTreeSelect(
  nodes: _demoTreeNodes,
  selectedKeys: _selected,
  multiple: true,
  treeLine: true,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectLineDemo(),
    ),
    ParkDemoScenario(
      title: '默认展开全部',
      description: 'treeDefaultExpandAll: true 初始化时展开所有节点。',
      code: '''
ParkTreeSelect(
  nodes: _demoTreeNodes,
  selectedKeys: _selected,
  multiple: true,
  treeDefaultExpandAll: true,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectExpandAllDemo(),
    ),
    ParkDemoScenario(
      title: '限制标签数量',
      description: 'maxTagCount 控制多选模式下可见标签数量，超出以 +N 显示。',
      code: '''
ParkTreeSelect(
  nodes: _demoTreeNodes,
  selectedKeys: _selected,
  multiple: true,
  maxTagCount: 2,
  onChanged: (keys) => setState(() => _selected = keys),
)
''',
      builder: (context) => _TreeSelectMaxTagDemo(),
    ),
    // ── ParkTreeSelect: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中节点实时同步到 model。'
          ' / ParkBindingService bindKey demo: tree selection syncs to model in real time.',
      code: '''
final service = ParkBindingService({'department': <String>{'team1'}});

ParkTreeSelect(
  nodes: _demoTreeNodes,
  bindKey: 'department',
  bindingService: service,
  multiple: true,
  checkable: true,
)''',
      builder: (BuildContext context) => _TreeSelectBindingDemo(),
    ),
    // ── ParkTreeSelect: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用 treeSelect 字段类型。'
          ' / ParkForm fieldType=treeSelect demo.',
      code: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'tree_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_org',
        fieldType: ParkFieldType.treeSelect,
        labelName: '所属部门',
        fieldName: 'org',
        isRequired: true,
        options: [
          {'label': '研发部', 'value': 'dept1', 'children': [
            {'label': '前端组', 'value': 'team1'},
            {'label': '后端组', 'value': 'team2'},
          ]},
          {'label': '设计部', 'value': 'dept2', 'children': [
            {'label': 'UI 组', 'value': 'team3'},
          ]},
        ],
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkForm(
          schema: ParkFormSchema(
            formKey: 'tree_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_org',
                fieldType: ParkFieldType.treeSelect,
                labelName: '所属部门',
                fieldName: 'org',
                isRequired: true,
                options: <Map<String, dynamic>>[
                  <String, dynamic>{
                    'label': '研发部',
                    'value': 'dept1',
                    'children': <Map<String, dynamic>>[
                      <String, dynamic>{'label': '前端组', 'value': 'team1'},
                      <String, dynamic>{'label': '后端组', 'value': 'team2'},
                    ],
                  },
                  <String, dynamic>{
                    'label': '设计部',
                    'value': 'dept2',
                    'children': <Map<String, dynamic>>[
                      <String, dynamic>{'label': 'UI 组', 'value': 'team3'},
                    ],
                  },
                ],
              ),
            ],
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`treeSelect`（树形选择）。

### 适用场景
- 组织架构、商品分类等树状结构单选/多选。
- 需要展开/折叠且支持搜索过滤的字段。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `treeSelect` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `dataSourceType` | `data_source_type` | 选项来源 | 否 |
| `options` | `options` | 静态树（含 `children`） | 否 |
| `fieldControl` | `field_control` | 子类型：`multi` 多选 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_org',
  fieldType: ParkFieldType.treeSelect,
  labelName: '所属部门',
  fieldName: 'org',
  options: [
    {
      'label': '技术中心',
      'value': 'tech',
      'children': [
        {'label': '前端组', 'value': 'fe'},
      ],
    },
  ],
)
```

### 进阶技巧
- 多选：将 `fieldControl` 设为 `multi`，提交值为节点列表。
- 树数据与 `cascader` 类似（`children` 键名可用 `optionChildrenKey` 覆盖）。
- 联动：`disabledRule` 在未选父节点时禁用。''',
);

const _demoTreeNodes = <ParkTreeNode>[
  ParkTreeNode(
    key: 'dept1',
    label: '研发部',
    children: [
      ParkTreeNode(key: 'team1', label: '前端组'),
      ParkTreeNode(key: 'team2', label: '后端组'),
      ParkTreeNode(key: 'team3', label: '移动端组'),
    ],
  ),
  ParkTreeNode(
    key: 'dept2',
    label: '设计部',
    children: [
      ParkTreeNode(key: 'team4', label: 'UI 组'),
      ParkTreeNode(key: 'team5', label: 'UX 组'),
    ],
  ),
  ParkTreeNode(
    key: 'dept3',
    label: '产品部',
    children: [
      ParkTreeNode(key: 'team6', label: '策略组'),
      ParkTreeNode(key: 'team7', label: '运营组'),
    ],
  ),
];

class _TreeSelectSingleDemo extends StatefulWidget {
  @override
  State<_TreeSelectSingleDemo> createState() => _TreeSelectSingleDemoState();
}

class _TreeSelectSingleDemoState extends State<_TreeSelectSingleDemo> {
  Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选中: ${_selected.isEmpty ? '无' : _selected.join(", ")}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkTreeSelect(
          nodes: _demoTreeNodes,
          selectedKeys: _selected,
          checkable: false,
          onChanged: (keys) => setState(() => _selected = keys),
        ),
      ],
    );
  }
}

class _TreeSelectMultipleDemo extends StatefulWidget {
  @override
  State<_TreeSelectMultipleDemo> createState() =>
      _TreeSelectMultipleDemoState();
}

class _TreeSelectMultipleDemoState extends State<_TreeSelectMultipleDemo> {
  Set<String> _selected = {'team1'};

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选中: ${_selected.isEmpty ? '无' : _selected.join(", ")}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkTreeSelect(
          nodes: _demoTreeNodes,
          selectedKeys: _selected,
          multiple: true,
          checkable: true,
          onChanged: (keys) => setState(() => _selected = keys),
        ),
      ],
    );
  }
}

class _TreeSelectDisabledDemo extends StatefulWidget {
  @override
  State<_TreeSelectDisabledDemo> createState() =>
      _TreeSelectDisabledDemoState();
}

class _TreeSelectDisabledDemoState extends State<_TreeSelectDisabledDemo> {
  Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return ParkTreeSelect(
      nodes: const [
        ParkTreeNode(key: 'a', label: '可用节点 A'),
        ParkTreeNode(key: 'b', label: '禁用节点 B', disabled: true),
        ParkTreeNode(key: 'c', label: '可用节点 C'),
        ParkTreeNode(key: 'd', label: '可用节点 D'),
      ],
      selectedKeys: _selected,
      checkable: true,
      multiple: true,
      onChanged: (keys) => setState(() => _selected = keys),
    );
  }
}

class _TreeSelectSearchableDemo extends StatefulWidget {
  @override
  State<_TreeSelectSearchableDemo> createState() =>
      _TreeSelectSearchableDemoState();
}

class _TreeSelectSearchableDemoState extends State<_TreeSelectSearchableDemo> {
  Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return ParkTreeSelect(
      nodes: _demoTreeNodes,
      selectedKeys: _selected,
      multiple: true,
      searchable: true,
      onChanged: (keys) => setState(() => _selected = keys),
    );
  }
}

// =====================================================================
// ParkSlider
// =====================================================================

final ParkComponentSpec _parkSlider = ParkComponentSpec(
  name: 'ParkSlider',
  title: '滑块',
  category: 'input',
  description:
      '基于 FormField<double> 封装，支持连续/离散滑动、数值显示、'
      '自定义激活色、范围选择（双滑块）、刻度标记、垂直方向等高级功能。'
      '使用 CustomPainter 绘制自定义拇指样式。',
  icon: Icons.tune_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'double',
      defaultVal: '0',
      description: '当前滑块值。',
    ),
    ParkPropertyDef(
      name: 'min',
      type: 'double',
      defaultVal: '0',
      description: '最小值。',
    ),
    ParkPropertyDef(
      name: 'max',
      type: 'double',
      defaultVal: '100',
      description: '最大值。',
    ),
    ParkPropertyDef(
      name: 'divisions',
      type: 'int?',
      defaultVal: 'null',
      description: '离散分段数。为 null 时连续滑动。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<double>?',
      defaultVal: 'null',
      description: '值变更回调。',
    ),
    ParkPropertyDef(
      name: 'onChangeEnd',
      type: 'ValueChanged<double>?',
      defaultVal: 'null',
      description: '滑动结束回调（用户松手时触发）。',
    ),
    ParkPropertyDef(
      name: 'activeColor',
      type: 'Color?',
      defaultVal: 'null（使用 brand 色）',
      description: '激活轨道和拇指颜色。',
    ),
    ParkPropertyDef(
      name: 'showValue',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在滑块上方显示当前数值。',
    ),
    ParkPropertyDef(
      name: 'range',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用范围选择模式（双滑块）。',
    ),
    ParkPropertyDef(
      name: 'rangeStart',
      type: 'double?',
      defaultVal: 'null',
      description: '范围选择起始值。',
    ),
    ParkPropertyDef(
      name: 'rangeEnd',
      type: 'double?',
      defaultVal: 'null',
      description: '范围选择结束值。',
    ),
    ParkPropertyDef(
      name: 'onRangeChanged',
      type: 'void Function(double, double)?',
      defaultVal: 'null',
      description: '范围变更回调。',
    ),
    ParkPropertyDef(
      name: 'marks',
      type: 'List<double>?',
      defaultVal: 'null',
      description: '刻度标记位置列表（与 min/max 同量纲的绝对值），滑块自动吸附到最近刻度。',
    ),
    ParkPropertyDef(
      name: 'showTooltip',
      type: 'bool',
      defaultVal: 'true',
      description: '拖动时是否显示 Tooltip。',
    ),
    ParkPropertyDef(
      name: 'tooltipBuilder',
      type: 'String Function(double)?',
      defaultVal: 'null',
      description: '自定义 Tooltip 文字格式化回调（参数为当前值）。',
    ),
    ParkPropertyDef(
      name: 'vertical',
      type: 'bool',
      defaultVal: 'false',
      description: '是否垂直方向。',
    ),
    ParkPropertyDef(
      name: 'step',
      type: 'double?',
      defaultVal: 'null',
      description: '自定义步长。',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用。',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读。',
    ),
    ParkPropertyDef(
      name: 'reverse',
      type: 'bool',
      defaultVal: 'false',
      description: '是否反向渲染。',
    ),
    ParkPropertyDef(
      name: 'dots',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示间断点（需配合 divisions 使用）。',
    ),
    ParkPropertyDef(
      name: 'onChangeStart',
      type: 'ValueChanged<double>?',
      defaultVal: 'null',
      description: '拖动开始回调（用户开始滑动时触发）。',
    ),
    ParkPropertyDef(
      name: 'inactiveColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '非激活轨道颜色。',
    ),
    ParkPropertyDef(
      name: 'thumbIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义拇指图标。',
    ),
    ParkPropertyDef(
      name: 'included',
      type: 'bool',
      defaultVal: 'true',
      description: '是否高亮已选中轨道区域。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<double>',
      description: '滑块值变更时持续触发。',
    ),
    ParkEventDef(
      name: 'onChangeEnd',
      signature: 'ValueChanged<double>',
      description: '用户松手结束滑动时触发。',
    ),
    ParkEventDef(
      name: 'onRangeChanged',
      signature: 'void Function(double, double)',
      description: '范围模式时值变更回调。',
    ),
    ParkEventDef(
      name: 'onChangeStart',
      signature: 'ValueChanged<double>',
      description: '开始滑动时触发。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSlider(
  value: 50,
  min: 0,
  max: 100,
  divisions: 10,
  showValue: true,
  onChanged: (v) => print('当前值: \$v'),
)
''',
  guide: '''
## 何时使用
- 需要在连续数值范围内选择时（音量、亮度、价格区间等）
- 数值调节类交互场景

## 使用建议
- 连续滑动不设置 divisions，离散选择设置 divisions 分段
- 开启 showValue 在滑块上方显示当前数值
- 通过 onChangeEnd 获取用户松手后的最终值，避免频繁触发
- 搭配 ParkForm 使用可自动收集数值
- 音量、亮度等场景配合图标展示更直观
- range 模式启用双滑块范围选择
- vertical: true 垂直方向滑动

## 搭配推荐
- 搭配 ParkIcon 做音量/亮度控制
- 搭配 ParkStepper 做精确数值输入
- 搭配 ParkForm 做数值表单
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础滑块',
      description: '连续滑动，显示当前值。',
      code: '''
ParkSlider(
  value: _value,
  showValue: true,
  onChanged: (v) => setState(() => _value = v),
)
''',
      builder: (context) => _SliderBasicDemo(),
    ),
    ParkDemoScenario(
      title: '离散分段',
      description: '设置 divisions 实现离散分段滑动。',
      code: '''
ParkSlider(
  value: _value,
  min: 0,
  max: 100,
  divisions: 5,
  showValue: true,
  onChanged: (v) => setState(() => _value = v),
)
''',
      builder: (context) => _SliderDivisionsDemo(),
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description: '通过 activeColor 设置激活色。',
      code: '''
ParkSlider(
  value: _value,
  activeColor: _kColors.brand,
  showValue: true,
  onChanged: (v) => setState(() => _value = v),
)
''',
      builder: (context) => _SliderColorDemo(),
    ),
    ParkDemoScenario(
      title: '音量控制',
      description: '模拟音量控制场景，0-100 范围。',
      code: '''
ParkSlider(
  value: _volume,
  min: 0,
  max: 100,
  divisions: 100,
  showValue: true,
  onChangeEnd: (v) => print('音量确认: \$v'),
  onChanged: (v) => setState(() => _volume = v),
)
''',
      builder: (context) => _SliderVolumeDemo(),
    ),
    ParkDemoScenario(
      title: '范围选择（双滑块）',
      description: 'range 模式启用双滑块，onRangeChanged 回传起止值。',
      code: '''
ParkSlider(
  range: true,
  rangeStart: _rangeStart,
  rangeEnd: _rangeEnd,
  min: 0,
  max: 100,
  onRangeChanged: (s, e) {
    setState(() {
      _rangeStart = s;
      _rangeEnd = e;
    });
  },
)
''',
      builder: (context) => _SliderRangeDemo(),
    ),
    ParkDemoScenario(
      title: '滑动起止回调',
      description: 'onChangeStart 在按下时、onChangeEnd 在松手时触发。',
      code: '''
ParkSlider(
  value: _value,
  min: 0,
  max: 100,
  showValue: true,
  onChangeStart: (v) => setState(() => _start = v),
  onChangeEnd: (v) => setState(() => _end = v),
  onChanged: (v) => setState(() => _value = v),
)
''',
      builder: (context) => _SliderStartEndDemo(),
    ),
    ParkDemoScenario(
      title: '刻度与自定义提示',
      description: 'marks 显示刻度文字，tooltipBuilder 自定义 Tooltip 内容。',
      code: '''
ParkSlider(
  value: _value,
  min: 0,
  max: 100,
  divisions: 10,
  showValue: true,
  marks: <double>[0, 50, 100],
  tooltipBuilder: (v) => v.toInt().toString(),
  onChanged: (v) => setState(() => _value = v),
)
''',
      builder: (context) => _SliderMarksDemo(),
    ),
    // ── ParkSlider: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，滑块值实时同步到 model。'
          ' / ParkBindingService bindKey demo: slider value syncs to model in real time.',
      code: '''
final service = ParkBindingService({'volume': 50});

ParkSlider(
  bindKey: 'volume',
  bindingService: service,
  min: 0,
  max: 100,
  showValue: true,
)''',
      builder: (context) => _SliderBindingDemo(),
    ),
    // ── ParkSlider: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用。'
          ' / ParkForm schema usage.',
      code: '''
ParkForm(
  schemas: [
    ParkFormFieldSchema(
      fieldId: 'f_volume',
      fieldType: ParkFieldType.slider,
      labelName: '音量',
      fieldName: 'volume',
      defaultValue: 50,
      ext: {'min': 0, 'max': 100, 'step': 1},
    ),
  ],
  onSubmit: (values) => print(values),
)
''',
      builder: (BuildContext context) => ParkForm(
        schema: const ParkFormSchema(
          formKey: 'park_slider_dynamic_form_demo',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_volume',
              fieldType: ParkFieldType.slider,
              labelName: '音量',
              fieldName: 'volume',
              defaultValue: 50,
              ext: {'min': 0, 'max': 100, 'step': 1},
            ),
          ],
        ),
        onSubmit: (Map<String, dynamic> values) {},
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`slider`（滑杆）。

### 适用场景
- 价格区间、音量、评分阈值等连续数值调节。
- 需要直观拖拽取值的字段。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `slider` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认值（数值） | 否 |
| `ext` | `ext` | 范围与步进：`min` / `max` / `step` / `divisions` | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_price',
  fieldType: ParkFieldType.slider,
  labelName: '价格上限',
  fieldName: 'price',
  defaultValue: 50,
  ext: {'min': 0, 'max': 100, 'step': 1},
)
```

### 进阶技巧
- 数值范围与步进经 `ext` 承载：`ext['min']` / `ext['max']` / `ext['step']`（当前 `ParkFormFieldSchema` 无独立 min/max 字段）。
- `defaultValue` 给初始位置（数值）。
- 联动：`reaction` 的 `setValue` 按条件写入数值。''',
);

class _SliderBasicDemo extends StatefulWidget {
  @override
  State<_SliderBasicDemo> createState() => _SliderBasicDemoState();
}

class _SliderBasicDemoState extends State<_SliderBasicDemo> {
  double _value = 50;

  @override
  Widget build(BuildContext context) {
    return ParkSlider(
      value: _value,
      showValue: true,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class _SliderDivisionsDemo extends StatefulWidget {
  @override
  State<_SliderDivisionsDemo> createState() => _SliderDivisionsDemoState();
}

class _SliderDivisionsDemoState extends State<_SliderDivisionsDemo> {
  double _value = 40;

  @override
  Widget build(BuildContext context) {
    return ParkSlider(
      value: _value,
      min: 0,
      max: 100,
      divisions: 5,
      showValue: true,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class _SliderColorDemo extends StatefulWidget {
  @override
  State<_SliderColorDemo> createState() => _SliderColorDemoState();
}

class _SliderColorDemoState extends State<_SliderColorDemo> {
  double _value = 60;

  @override
  Widget build(BuildContext context) {
    return ParkSlider(
      value: _value,
      activeColor: _kColors.brand,
      showValue: true,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class _SliderVolumeDemo extends StatefulWidget {
  @override
  State<_SliderVolumeDemo> createState() => _SliderVolumeDemoState();
}

class _SliderVolumeDemoState extends State<_SliderVolumeDemo> {
  double _volume = 30;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.volume_up, size: 20, color: park.colors.textSecondary),
            SizedBox(width: _kSpacing.sm),
            Text(
              '音量: ${_volume.toInt()}%',
              style: TextStyle(
                fontSize: park.typography.sizeBodySmall,
                color: park.colors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        ParkSlider(
          value: _volume,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (v) => setState(() => _volume = v),
        ),
      ],
    );
  }
}

// =====================================================================
// ParkStepper
// =====================================================================

final ParkComponentSpec _parkStepper = ParkComponentSpec(
  name: 'ParkStepper',
  title: '步进器',
  category: 'input',
  description:
      '基于 FormField<int> 封装的数量选择器，提供 [-] [value] [+] 样式的数值调节控件，'
      '支持最小/最大值限制、步长、禁用、输入模式、长按递增、前缀/后缀、尺寸/主题等。',
  icon: Icons.exposure_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'int',
      defaultVal: '0',
      description: '当前数值。',
    ),
    ParkPropertyDef(
      name: 'min',
      type: 'int?',
      defaultVal: 'null',
      description: '最小值限制。为 null 时无下限。',
    ),
    ParkPropertyDef(
      name: 'max',
      type: 'int?',
      defaultVal: 'null',
      description: '最大值限制。为 null 时无上限。',
    ),
    ParkPropertyDef(
      name: 'step',
      type: 'int',
      defaultVal: '1',
      description: '每次增减的步长。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<int>?',
      defaultVal: 'null',
      description: '值变更回调。',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用。禁用时按钮不可点击且样式变灰。',
    ),
    ParkPropertyDef(
      name: 'inputMode',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示可编辑的文本框替代纯文字显示。',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkStepperSize',
      defaultVal: 'ParkStepperSize.medium',
      description: '步进器尺寸：small / medium / large。',
    ),
    ParkPropertyDef(
      name: 'longPressIncrement',
      type: 'bool',
      defaultVal: 'true',
      description: '长按 +/- 按钮是否持续递增/递减。',
    ),
    ParkPropertyDef(
      name: 'formatter',
      type: 'String Function(int)?',
      defaultVal: 'null',
      description: '自定义显示格式化回调。',
    ),
    ParkPropertyDef(
      name: 'theme',
      type: 'ParkStepperTheme',
      defaultVal: 'ParkStepperTheme.filled',
      description: '步进器主题：filled（填充）/ outline（描边）。',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读。',
    ),
    ParkPropertyDef(
      name: 'prefix',
      type: 'Widget?',
      defaultVal: 'null',
      description: '数值前缀 Widget（如 Text("¥")）。',
    ),
    ParkPropertyDef(
      name: 'suffix',
      type: 'Widget?',
      defaultVal: 'null',
      description: '数值后缀 Widget（如 Text("件")）。',
    ),
    ParkPropertyDef(
      name: 'placeholder',
      type: 'String?',
      defaultVal: 'null',
      description: '空值占位文字。',
    ),
    ParkPropertyDef(
      name: 'precision',
      type: 'int?',
      defaultVal: 'null',
      description: '小数位数精度；为 null 时使用整数模式。',
    ),
    ParkPropertyDef(
      name: 'inputReadOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '输入模式下文本框是否只读（禁止手动输入，仅 +/- 按钮可改）。',
    ),
    ParkPropertyDef(
      name: 'stringMode',
      type: 'bool',
      defaultVal: 'false',
      description: '字符串模式（使用字符串存储大数值，避免 int 溢出）。',
    ),
    ParkPropertyDef(
      name: 'onOverLimit',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '达到限制时的回调。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<int>',
      description: '数值变更时触发，参数为新的整数值。',
    ),
    ParkEventDef(
      name: 'onOverLimit',
      signature: 'VoidCallback',
      description: '达到最小/最大限制时触发。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkStepper(
  value: 1,
  min: 0,
  max: 99,
  step: 1,
  onChanged: (v) => print('数量: \$v'),
)
''',
  guide: '''
## 何时使用
- 需要微调数值时（商品数量、人数、份数等）
- 小范围整数选择场景

## 使用建议
- 设置 min/max 限制数值范围，到达边界时按钮自动禁用
- 通过 step 设置步长（如步长 5 适合价格调整）
- 与 ParkSlider 的区别：步进器适合精确小数值，滑块适合大范围
- 搭配 ParkForm 使用可自动收集数值
- inputMode: true 开启可编辑文本框
- formatter 自定义显示格式（如 "¥100"）
- theme: outline 切换描边风格
- suffix 添加单位文字

## 搭配推荐
- 搭配 ParkList 做购物车数量选择
- 搭配 ParkForm 做数量表单
- 搭配 ParkCell 做设置项中的数值调节
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础步进器',
      description: '默认步长为 1，无限制范围。',
      code: '''
ParkStepper(
  value: _count,
  onChanged: (v) => setState(() => _count = v),
)
''',
      builder: (context) => _StepperBasicDemo(),
    ),
    ParkDemoScenario(
      title: '带范围限制',
      description: '设置 min 和 max，到达边界时按钮自动禁用。',
      code: '''
ParkStepper(
  value: _count,
  min: 1,
  max: 10,
  onChanged: (v) => setState(() => _count = v),
)
''',
      builder: (context) => _StepperRangeDemo(),
    ),
    ParkDemoScenario(
      title: '自定义步长',
      description: '设置 step 为 5，每次增减 5。',
      code: '''
ParkStepper(
  value: _count,
  min: 0,
  max: 100,
  step: 5,
  onChanged: (v) => setState(() => _count = v),
)
''',
      builder: (context) => _StepperStepDemo(),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: '设置 disabled 为 true，整个控件不可操作。',
      code: '''
ParkStepper(
  value: 3,
  disabled: true,
)
''',
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'disabled: true',
            style: TextStyle(
              fontSize: _kTypography.sizeBodySmall,
              color: _kColors.textSecondary,
            ),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkStepper(value: 3, disabled: true),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带单位后缀',
      description: '通过 suffix 添加单位文字。',
      code: '''
ParkStepper(
  value: _count,
  min: 0,
  max: 99,
  suffix: '件',
  onChanged: (v) => setState(() => _count = v),
)
''',
      builder: (context) => _StepperSuffixDemo(),
    ),
    ParkDemoScenario(
      title: '超出限制回调',
      description: '到达 min/max 边界时触发 onOverLimit 回调。',
      code: '''
ParkStepper(
  value: _count,
  min: 0,
  max: 5,
  onChanged: (v) => setState(() => _count = v),
  onOverLimit: () => setState(() => _over = true),
)
''',
      builder: (context) => _StepperLimitDemo(),
    ),
    ParkDemoScenario(
      title: '小数精度与格式化',
      description: 'precision 控制小数位数，formatter 自定义显示文字。',
      code: '''
ParkStepper(
  value: _price,
  min: 0,
  max: 10,
  precision: 1,
  formatter: (v) => '\$' + v.toStringAsFixed(1),
  onChanged: (v) => setState(() => _price = v),
)
''',
      builder: (context) => _StepperPrecisionDemo(),
    ),
    ParkDemoScenario(
      title: '描边风格',
      description: 'theme: ParkStepperTheme.outline 切换描边风格。',
      code: '''
ParkStepper(
  value: _count,
  min: 0,
  max: 99,
  theme: ParkStepperTheme.outline,
  suffix: const Text('件'),
  onChanged: (v) => setState(() => _count = v),
)
''',
      builder: (context) => _StepperOutlineDemo(),
    ),
    // -----------------------------------------------------------------------
    // ParkStepper Binding Demo
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，下方实时回显绑定模型值。'
          ' / bindKey + bindingService for two-way binding, model values shown below.',
      code: '''
final service = ParkBindingService({'count': 5});

ParkStepper(
  value: 5,
  min: 0,
  max: 99,
  bindKey: 'count',
  bindingService: service,
)''',
      builder: (context) => _StepperBindingDemo(),
    ),
    // ── ParkStepper: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用。'
          ' / ParkForm schema usage.',
      code: '''
ParkForm(
  schemas: [
    ParkFormFieldSchema(
      fieldId: 'f_count',
      fieldType: ParkFieldType.number,
      labelName: '购买数量',
      fieldName: 'count',
      defaultValue: 1,
      fieldControl: 'stepper',
      ext: {'min': 1, 'max': 99, 'step': 1},
    ),
  ],
  onSubmit: (values) => print(values),
)
''',
      builder: (BuildContext context) => ParkForm(
        schema: const ParkFormSchema(
          formKey: 'park_stepper_dynamic_form_demo',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_count',
              fieldType: ParkFieldType.number,
              labelName: '购买数量',
              fieldName: 'count',
              defaultValue: 1,
              fieldControl: 'stepper',
              ext: {'min': 1, 'max': 99, 'step': 1},
            ),
          ],
        ),
        onSubmit: (Map<String, dynamic> values) {},
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`stepper`（步进器）。

### 适用场景
- 数量、年龄等整数增减字段。
- 需要精确 +/- 控制的数值输入。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `stepper` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认值（数值） | 否 |
| `ext` | `ext` | 范围与步进：`min` / `max` / `step` | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_count',
  fieldType: ParkFieldType.stepper,
  labelName: '购买数量',
  fieldName: 'count',
  defaultValue: 1,
  ext: {'min': 1, 'max': 99, 'step': 1},
)
```

### 进阶技巧
- 范围与步进经 `ext` 承载：`ext['min']` / `ext['max']` / `ext['step']`。
- `defaultValue` 给初始数值。
- 联动：`disabledRule` 在库存为 0 时禁用。''',
);

class _StepperBasicDemo extends StatefulWidget {
  @override
  State<_StepperBasicDemo> createState() => _StepperBasicDemoState();
}

class _StepperBasicDemoState extends State<_StepperBasicDemo> {
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    return ParkStepper(
      value: _count,
      onChanged: (v) => setState(() => _count = v),
    );
  }
}

class _StepperRangeDemo extends StatefulWidget {
  @override
  State<_StepperRangeDemo> createState() => _StepperRangeDemoState();
}

class _StepperRangeDemoState extends State<_StepperRangeDemo> {
  int _count = 5;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '范围: 1 ~ 10',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkStepper(
          value: _count,
          min: 1,
          max: 10,
          onChanged: (v) => setState(() => _count = v),
        ),
      ],
    );
  }
}

class _StepperStepDemo extends StatefulWidget {
  @override
  State<_StepperStepDemo> createState() => _StepperStepDemoState();
}

class _StepperStepDemoState extends State<_StepperStepDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '步长: 5, 范围: 0 ~ 100',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkStepper(
          value: _count,
          min: 0,
          max: 100,
          step: 5,
          onChanged: (v) => setState(() => _count = v),
        ),
      ],
    );
  }
}

class _StepperSuffixDemo extends StatefulWidget {
  @override
  State<_StepperSuffixDemo> createState() => _StepperSuffixDemoState();
}

class _StepperSuffixDemoState extends State<_StepperSuffixDemo> {
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return ParkStepper(
      value: _count,
      min: 0,
      max: 99,
      suffix: const Text('件'),
      onChanged: (v) => setState(() => _count = v),
    );
  }
}

// ============================================================================
// ParkStepper Binding Demo
// ============================================================================

class _StepperBindingDemo extends StatefulWidget {
  @override
  State<_StepperBindingDemo> createState() => _StepperBindingDemoState();
}

class _StepperBindingDemoState extends State<_StepperBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'count': 5});
    _service.watchEffect(() {
      _service.getValue<int>('count');
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkStepper(
            value: 5,
            min: 0,
            max: 99,
            bindKey: 'count',
            bindingService: _service,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.sync, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '实时值: ${_service.model}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ParkRate
// =====================================================================

final ParkComponentSpec _parkRate = ParkComponentSpec(
  name: 'ParkRate',
  title: '评分',
  category: 'input',
  description:
      '基于 FormField<double> 封装的星级评分控件，支持整星和半星评分、'
      '只读模式、自定义星星数量和尺寸、自定义图标和字符、显示评分数值等。'
      '使用 ClipRect 实现半星裁剪。',
  icon: Icons.star_outline,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'double',
      defaultVal: '0',
      description: '当前评分值。',
    ),
    ParkPropertyDef(
      name: 'count',
      type: 'int',
      defaultVal: '5',
      description: '星星总数。',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'double',
      defaultVal: '24',
      description: '星星尺寸（逻辑像素）。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<double>?',
      defaultVal: 'null',
      description: '评分变更回调。',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读模式。只读时不可交互。',
    ),
    ParkPropertyDef(
      name: 'allowHalf',
      type: 'bool',
      defaultVal: 'false',
      description: '是否支持半星评分。',
    ),
    ParkPropertyDef(
      name: 'activeColor',
      type: 'Color?',
      defaultVal: 'Color(0xFFFADB14)',
      description: '激活（已填充）星星颜色。',
    ),
    ParkPropertyDef(
      name: 'inactiveColor',
      type: 'Color?',
      defaultVal: 'null（使用 border 色）',
      description: '未激活星星颜色。',
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'IconData?',
      defaultVal: 'null',
      description: '自定义图标（替代默认星形）。',
    ),
    ParkPropertyDef(
      name: 'character',
      type: 'Widget?',
      defaultVal: 'null',
      description: '完全自定义的评分项 widget（覆盖 icon）。',
    ),
    ParkPropertyDef(
      name: 'characters',
      type: 'List<Widget>?',
      defaultVal: 'null',
      description: '每个评分项的独立自定义字符列表（数量需与 count 匹配，优先级高于 character）。',
    ),
    ParkPropertyDef(
      name: 'tooltips',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '每个评分项的 tooltip 文字。',
    ),
    ParkPropertyDef(
      name: 'showText',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在星星右侧显示 "value / count" 文字。',
    ),
    ParkPropertyDef(
      name: 'textBuilder',
      type: 'String Function(double, int)?',
      defaultVal: 'null',
      description: '自定义文字格式化回调。',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用（灰显且不可交互）。',
    ),
    ParkPropertyDef(
      name: 'gap',
      type: 'double?',
      defaultVal: 'null（使用默认间距）',
      description: '星星之间的间距。',
    ),
    ParkPropertyDef(
      name: 'allowClear',
      type: 'bool',
      defaultVal: 'true',
      description: '是否允许点击已选星星来清除评分。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<double>',
      description: '评分值变更时触发，参数为新的评分值。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkRate(
  value: 3.5,
  count: 5,
  allowHalf: true,
  onChanged: (v) => print('评分: \$v'),
)
''',
  guide: '''
## 何时使用
- 用户评价、打分场景（商品评价、服务评分、内容评级）
- 展示平均评分时

## 使用建议
- 默认 5 颗星，可通过 count 自定义数量
- 开启 allowHalf 支持半星评分，更精细
- 展示评分时设置 readOnly: true 禁止交互
- 通过 size 调整星星大小，适配不同布局
- 搭配 ParkForm 收集评价数据
- icon 替换默认星形图标（如心形、拇指）
- character 完全自定义评分项
- showText 显示评分数字

## 搭配推荐
- 搭配 ParkTextarea 做评价表单（评分 + 文字评论）
- 搭配 ParkCard 做商品评价展示
- 搭配 ParkTag 做评价标签
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础评分',
      description: '默认 5 颗星，整星评分。',
      code: '''
ParkRate(
  value: _rating,
  onChanged: (v) => setState(() => _rating = v),
)
''',
      builder: (context) => _RateBasicDemo(),
    ),
    ParkDemoScenario(
      title: '半星评分',
      description: '开启 allowHalf，支持 0.5 步进。',
      code: '''
ParkRate(
  value: _rating,
  allowHalf: true,
  onChanged: (v) => setState(() => _rating = v),
)
''',
      builder: (context) => _RateHalfDemo(),
    ),
    ParkDemoScenario(
      title: '只读模式',
      description: '设置 readOnly 为 true，仅展示不可交互。',
      code: '''
ParkRate(
  value: 4,
  readOnly: true,
)
''',
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParkRate(value: 4, readOnly: true),
          SizedBox(height: _kSpacing.xs),
          Text(
            '只读: 4 / 5 星',
            style: TextStyle(
              fontSize: _kTypography.sizeBodySmall,
              color: _kColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义星星数量和尺寸',
      description: '设置 count 和 size 自定义外观。',
      code: '''
ParkRate(
  value: _rating,
  count: 10,
  size: 20,
  activeColor: _kColors.warning,
  onChanged: (v) => setState(() => _rating = v),
)
''',
      builder: (context) => _RateCustomDemo(),
    ),
    ParkDemoScenario(
      title: '自定义图标',
      description: '使用 icon 参数替换默认星形为心形图标。',
      code: '''
ParkRate(
  value: _rating,
  icon: Icons.favorite,
  activeColor: _kColors.error,
  onChanged: (v) => setState(() => _rating = v),
)
''',
      builder: (context) => _RateIconDemo(),
    ),
    ParkDemoScenario(
      title: '显示评分文字与提示',
      description: 'showText 显示 "value / count" 文字，tooltips 设置每项提示。',
      code: '''
ParkRate(
  value: _rating,
  showText: true,
  tooltips: const <String>['很差', '较差', '一般', '较好', '很好'],
  onChanged: (v) => setState(() => _rating = v),
)
''',
      builder: (context) => _RateTextDemo(),
    ),
    // -----------------------------------------------------------------------
    // ParkRate Binding Demo
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，下方实时回显绑定模型值。'
          ' / bindKey + bindingService for two-way binding, model values shown below.',
      code: '''
final service = ParkBindingService({'score': 3.0});

ParkRate(
  value: 3.0,
  count: 5,
  allowHalf: true,
  bindKey: 'score',
  bindingService: service,
)''',
      builder: (context) => _RateBindingDemo(),
    ),
    // ── ParkRate: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用。'
          ' / ParkForm schema usage.',
      code: '''
ParkForm(
  schemas: [
    ParkFormFieldSchema(
      fieldId: 'f_rating',
      fieldType: ParkFieldType.rate,
      labelName: '满意度',
      fieldName: 'rating',
      isRequired: true,
      defaultValue: 4.0,
      ext: {'count': 5, 'allowHalf': true},
    ),
  ],
  onSubmit: (values) => print(values),
)
''',
      builder: (BuildContext context) => ParkForm(
        schema: const ParkFormSchema(
          formKey: 'park_rate_dynamic_form_demo',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_rating',
              fieldType: ParkFieldType.rate,
              labelName: '满意度',
              fieldName: 'rating',
              isRequired: true,
              defaultValue: 4.0,
              ext: {'count': 5, 'allowHalf': true},
            ),
          ],
        ),
        onSubmit: (Map<String, dynamic> values) {},
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`rate`（评分）。

### 适用场景
- 满意度、星级评分等整数/半星评价字段。
- 需要可视化打分的交互。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `rate` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认评分（数值） | 否 |
| `ext` | `ext` | 星星数量 `count`、是否半星 `allowHalf` 等 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_score',
  fieldType: ParkFieldType.rate,
  labelName: '满意度',
  fieldName: 'score',
  isRequired: true,
  ext: {'count': 5, 'allowHalf': true},
)
```

### 进阶技巧
- 星星数与半星经 `ext` 承载：`ext['count']`（星数）、`ext['allowHalf']`（是否允许半星）。
- `defaultValue` 给初始评分（数值）。
- 联动：`visibleRule` 在显示评分前先选分类。''',
);

class _RateBasicDemo extends StatefulWidget {
  @override
  State<_RateBasicDemo> createState() => _RateBasicDemoState();
}

class _RateBasicDemoState extends State<_RateBasicDemo> {
  double _rating = 3;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkRate(value: _rating, onChanged: (v) => setState(() => _rating = v)),
        SizedBox(height: _kSpacing.xs),
        Text(
          '评分: ${_rating.toInt()}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RateHalfDemo extends StatefulWidget {
  @override
  State<_RateHalfDemo> createState() => _RateHalfDemoState();
}

class _RateHalfDemoState extends State<_RateHalfDemo> {
  double _rating = 3.5;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkRate(
          value: _rating,
          allowHalf: true,
          onChanged: (v) => setState(() => _rating = v),
        ),
        SizedBox(height: _kSpacing.xs),
        Text(
          '评分: $_rating',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RateCustomDemo extends StatefulWidget {
  @override
  State<_RateCustomDemo> createState() => _RateCustomDemoState();
}

class _RateCustomDemoState extends State<_RateCustomDemo> {
  double _rating = 7;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkRate(
          value: _rating,
          count: 10,
          size: 20,
          activeColor: _kColors.warning,
          onChanged: (v) => setState(() => _rating = v),
        ),
        SizedBox(height: _kSpacing.xs),
        Text(
          '评分: ${_rating.toInt()} / 10',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RateIconDemo extends StatefulWidget {
  @override
  State<_RateIconDemo> createState() => _RateIconDemoState();
}

class _RateIconDemoState extends State<_RateIconDemo> {
  double _rating = 3;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkRate(
          value: _rating,
          icon: Icons.favorite,
          activeColor: _kColors.error,
          onChanged: (v) => setState(() => _rating = v),
        ),
        SizedBox(height: _kSpacing.xs),
        Text(
          '评分: ${_rating.toInt()}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ParkRate Binding Demo
// ============================================================================

class _RateBindingDemo extends StatefulWidget {
  @override
  State<_RateBindingDemo> createState() => _RateBindingDemoState();
}

class _RateBindingDemoState extends State<_RateBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'score': 3.0});
    _service.watchEffect(() {
      _service.getValue<double>('score');
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkRate(
            value: 3.0,
            count: 5,
            allowHalf: true,
            bindKey: 'score',
            bindingService: _service,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.sync, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '实时值: ${_service.model}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ParkUpload
// =====================================================================

final ParkComponentSpec _parkUpload = ParkComponentSpec(
  name: 'ParkUpload',
  title: '文件上传',
  category: 'input',
  description:
      '网格/列表布局展示已选文件缩略图和添加按钮，支持删除、预览、上传进度覆盖层。'
      '仅提供 UI 壳，不内置文件选择逻辑，通过 onAdd 回调由外部注入文件选择器。'
      '支持 imageGrid / fileList / mixed 三种展示模式与 text / picture / pictureCard 列表类型。',
  icon: Icons.cloud_upload_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'files',
      type: 'List<ParkUploadFile>',
      required: true,
      description:
          '已选文件列表，每项包含 path、url、thumbnailPath、status、progress、sizeBytes。',
    ),
    ParkPropertyDef(
      name: 'maxCount',
      type: 'int',
      defaultVal: '9',
      description: '最大文件数量。达到上限后隐藏添加按钮。',
    ),
    ParkPropertyDef(
      name: 'onAdd',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '点击添加按钮的回调，由外部触发文件选择器。',
    ),
    ParkPropertyDef(
      name: 'onRemove',
      type: 'ValueChanged<ParkUploadFile>?',
      defaultVal: 'null',
      description: '移除文件回调，参数为被移除的文件。',
    ),
    ParkPropertyDef(
      name: 'onPreview',
      type: 'ValueChanged<ParkUploadFile>?',
      defaultVal: 'null',
      description: '预览文件回调，参数为被点击的文件。',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkUploadMode',
      defaultVal: 'ParkUploadMode.imageGrid',
      description: '展示模式：imageGrid（图片网格） / fileList（文件列表） / mixed（混合）。',
    ),
    ParkPropertyDef(
      name: 'listType',
      type: 'ParkUploadListType',
      defaultVal: 'ParkUploadListType.pictureCard',
      description:
          '文件列表展示类型：text（文本+进度条） / picture（缩略图+文件名） / pictureCard（卡片网格）。',
    ),
    ParkPropertyDef(
      name: 'accept',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '接受的文件类型列表（如 ["image/*", ".pdf"]），仅用于约束提示文案。',
    ),
    ParkPropertyDef(
      name: 'maxSizeMB',
      type: 'double?',
      defaultVal: '50',
      description: '单个文件大小上限（MB），超出时显示约束提示。',
    ),
    ParkPropertyDef(
      name: 'imageOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否仅允许图片（影响默认 listType 推断）。',
    ),
    ParkPropertyDef(
      name: 'removable',
      type: 'bool',
      defaultVal: 'true',
      description: '是否允许删除已选文件。',
    ),
    ParkPropertyDef(
      name: 'previewable',
      type: 'bool',
      defaultVal: 'true',
      description: '是否允许点击预览文件。',
    ),
    ParkPropertyDef(
      name: 'draggable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否允许拖拽文件到组件区域（触发 onDropFiles）。',
    ),
    ParkPropertyDef(
      name: 'multiple',
      type: 'bool',
      defaultVal: 'false',
      description: '是否允许多文件选择（约束提示）。',
    ),
    ParkPropertyDef(
      name: 'beforeAddValidator',
      type: 'String? Function(ParkUploadFile)?',
      defaultVal: 'null',
      description: '添加前的校验回调，返回 null 表示通过，返回字符串表示错误信息。',
    ),
    ParkPropertyDef(
      name: 'customRequest',
      type: 'Future<bool> Function(ParkUploadFile)?',
      defaultVal: 'null',
      description: '自定义上传请求（替代默认上传逻辑），返回 true 表示上传成功。',
    ),
    ParkPropertyDef(
      name: 'dragEnabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用拖拽上传。为 true 时整个上传区域接受拖放文件。与 draggable 作用相同，新代码优先使用此参数。',
    ),
    ParkPropertyDef(
      name: 'onRetry',
      type: 'ValueChanged<ParkUploadFile>?',
      defaultVal: 'null',
      description: '上传失败重试回调。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<List<ParkUploadFile>>?',
      defaultVal: 'null',
      description: '文件列表变化回调（内部文件选择 / 上传完成时触发）。',
    ),
    ParkPropertyDef(
      name: 'onDropFiles',
      type: 'void Function(List<Object?>)?',
      defaultVal: 'null',
      description: '拖拽文件放下时的回调。仅在 draggable 为 true 时有效。',
    ),
    ParkPropertyDef(
      name: 'onFileDrop',
      type: 'void Function(List<ParkDropFile>)?',
      defaultVal: 'null',
      description: '拖拽文件放下时的回调。仅在 dragEnabled 为 true 时有效。接收 ParkDropFile 列表，跨平台兼容。',
    ),
    ParkPropertyDef(
      name: 'chunked',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用分片上传。为 true 且文件大小超过 chunkSize 时自动分片。 / Enable chunked upload',
    ),
    ParkPropertyDef(
      name: 'chunkSize',
      type: 'int',
      defaultVal: '1048576',
      description: '分片大小（字节）。默认 1MB (1048576 字节)。 / Chunk size in bytes',
    ),
    ParkPropertyDef(
      name: 'onChunkUpload',
      type: 'Future<void> Function(String, List<int>, int, int, void Function(double))?',
      defaultVal: 'null',
      description: '分片上传回调。每个分片调用一次，由调用方实现实际上传逻辑。 / Chunked upload callback',
    ),
    ParkPropertyDef(
      name: 'croppable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用上传前图片裁剪。为 true 且文件为图片时，上传前弹出裁剪界面。 / Enable image cropping before upload',
    ),
    ParkPropertyDef(
      name: 'cropAspectRatio',
      type: 'double?',
      defaultVal: 'null',
      description: '裁剪比例（宽/高）。为 null 时自由裁剪。 / Crop aspect ratio (width/height)',
    ),
    ParkPropertyDef(
      name: 'cropMaxWidth',
      type: 'int?',
      defaultVal: 'null',
      description: '裁剪输出最大宽度（像素）。为 null 时不限制。 / Max output width after cropping',
    ),
    ParkPropertyDef(
      name: 'cropMaxHeight',
      type: 'int?',
      defaultVal: 'null',
      description: '裁剪输出最大高度（像素）。为 null 时不限制。 / Max output height after cropping',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onAdd',
      signature: 'VoidCallback',
      description: '点击添加按钮时触发。',
    ),
    ParkEventDef(
      name: 'onRemove',
      signature: 'ValueChanged<ParkUploadFile>',
      description: '点击删除按钮时触发，参数为被移除的文件。',
    ),
    ParkEventDef(
      name: 'onPreview',
      signature: 'ValueChanged<ParkUploadFile>',
      description: '点击文件缩略图时触发，参数为被预览的文件。',
    ),
    ParkEventDef(
      name: 'onRetry',
      signature: 'ValueChanged<ParkUploadFile>',
      description: '点击失败文件重试按钮时触发，参数为被重试的文件。',
    ),
    ParkEventDef(
      name: 'onDropFiles',
      signature: 'ValueChanged<List<Object?>>',
      description: '拖拽文件到组件区域时触发，参数为被拖入的文件数据列表。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkUpload(
  files: _files,
  maxCount: 9,
  onAdd: () {
    // 外部选择文件后追加到 _files
    setState(() {
      _files.add(ParkUploadFile(path: '/path/to/file.jpg'));
    });
  },
  onRemove: (file) {
    setState(() => _files.remove(file));
  },
)
''',
  guide: '''
## 何时使用
- 需要上传文件或图片时（头像上传、附件上传、相册管理）
- 多文件上传场景

## 使用建议
- 组件仅提供 UI 壳，文件选择逻辑通过 onAdd 由外部注入
- 网格布局（grid: true）适合图片上传，列表布局适合文件上传
- 通过 maxCount 限制最大上传数量
- 通过 ParkUploadFile.status 展示上传中/成功/失败状态
- 搭配 ParkImageViewer 做图片预览
- mode 切换 imageGrid / fileList / mixed 展示模式
- listType 切换 text / picture / pictureCard 列表样式

## 搭配推荐
- 搭配 ParkForm 做上传表单
- 搭配 ParkImageViewer 做图片预览
- 搭配 ParkProgress 展示上传进度
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '网格布局上传',
      description: '默认网格布局，展示文件缩略图和添加按钮。',
      code: '''
ParkUpload(
  files: _files,
  maxCount: 9,
  onAdd: () => setState(() => _files.add(...)),
  onRemove: (file) => setState(() => _files.remove(file)),
)
''',
      builder: (context) => _UploadGridDemo(),
    ),
    ParkDemoScenario(
      title: '列表布局上传',
      description: '设置 mode 为 fileList，使用列表布局。',
      code: '''
ParkUpload(
  files: _files,
  maxCount: 5,
  mode: ParkUploadMode.fileList,
  onAdd: () => setState(() => _files.add(...)),
  onRemove: (file) => setState(() => _files.remove(file)),
)
''',
      builder: (context) => _UploadListDemo(),
    ),
    ParkDemoScenario(
      title: '含上传进度',
      description: '展示上传中和失败状态的文件。',
      code: '''
ParkUpload(
  files: [
    ParkUploadFile(path: 'a.pdf', status: ParkUploadFileStatus.done),
    ParkUploadFile(
      path: 'b.pdf',
      status: ParkUploadFileStatus.uploading,
      progress: 0.6,
    ),
    ParkUploadFile(path: 'c.pdf', status: ParkUploadFileStatus.error),
  ],
)
''',
      builder: (context) => const ParkUpload(
        files: [
          ParkUploadFile(path: 'doc1.pdf', status: ParkUploadFileStatus.done),
          ParkUploadFile(
            path: 'doc2.pdf',
            status: ParkUploadFileStatus.uploading,
            progress: 0.6,
          ),
          ParkUploadFile(path: 'doc3.pdf', status: ParkUploadFileStatus.error),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '失败与重试',
      description: '失败状态的文件显示重试按钮，点击触发 onRetry 回调。',
      code: '''
ParkUpload(
  files: _files,
  onAdd: () {},
  onRemove: (f) => setState(() => _files.remove(f)),
  onRetry: (f) => setState(() {
    final i = _files.indexOf(f);
    if (i != -1) {
      _files[i] = f.copyWith(
        status: ParkUploadFileStatus.uploading,
        progress: 0.5,
      );
    }
  }),
)
''',
      builder: (context) => _UploadRetryDemo(),
    ),
    ParkDemoScenario(
      title: '拖拽上传',
      description: 'draggable: true 允许拖入文件，触发 onDropFiles 回调。',
      code: '''
ParkUpload(
  files: _files,
  draggable: true,
  onAdd: () => setState(() => _files.add(
    ParkUploadFile(path: 'file\${_files.length}.png', status: ParkUploadFileStatus.done),
  )),
  onDropFiles: (data) => setState(() => _files.add(
    ParkUploadFile(path: 'dropped.png', status: ParkUploadFileStatus.done),
  )),
  onRemove: (f) => setState(() => _files.remove(f)),
)
''',
      builder: (context) => _UploadDragDemo(),
    ),
    ParkDemoScenario(
      title: '预览回调 (onPreview)',
      description:
          '点击已上传文件缩略图触发 onPreview 回调，参数为被预览的文件。'
          ' / Tapping a file thumbnail fires onPreview with the file.',
      code: '''
ParkUpload(
  files: _files,
  previewable: true,
  onPreview: (file) => print('preview: \${file.path}'),
  onRemove: (f) => setState(() => _files.remove(f)),
)''',
      builder: (context) => _UploadPreviewDemo(),
    ),
    ParkDemoScenario(
      title: '上传 + 绑定示例',
      description:
          '通过 ParkBindingService 管理文件选择状态，演示上传前（空列表）和上传后（文件名回显）两种状态。'
          '使用 StatefulBuilder 管理文件列表，移除文件时同步更新绑定服务。',
      code: '''
final service = ParkBindingService({'fileNames': <String>[], 'fileCount': 0});
final files = <ParkUploadFile>[];

StatefulBuilder(
  builder: (context, setState) => Column(
    children: [
      ParkUpload(
        files: files,
        maxCount: 5,
        mode: ParkUploadMode.fileList,
        onAdd: () {
          files.add(ParkUploadFile(
            path: 'file_\${files.length + 1}.pdf',
            status: ParkUploadFileStatus.done,
          ));
          service.setValue('fileNames', files.map((f) => f.path).toList());
          service.setValue('fileCount', files.length);
          setState(() {});
        },
        onRemove: (file) {
          files.remove(file);
          service.setValue('fileNames', files.map((f) => f.path).toList());
          service.setValue('fileCount', files.length);
          setState(() {});
        },
      ),
      SizedBox(height: 16),
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0x1400A86B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0x3300A86B)),
        ),
        child: Text('绑定状态: 共 \$count 个文件'),
      ),
    ],
  ),
)
''',
      builder: (BuildContext context) {
        final ParkBindingService service = ParkBindingService(<String, dynamic>{
          'fileNames': <String>[],
          'fileCount': 0,
        });
        final List<ParkUploadFile> files = <ParkUploadFile>[];
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            final List<dynamic> names =
                service.getValue<List<dynamic>>('fileNames') ?? <dynamic>[];
            final int count = service.getValue<int>('fileCount') ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkUpload(
                  files: files,
                  maxCount: 5,
                  mode: ParkUploadMode.fileList,
                  onAdd: () {
                    final int idx = files.length + 1;
                    files.add(
                      ParkUploadFile(
                        path: 'file_$idx.pdf',
                        status: ParkUploadFileStatus.done,
                      ),
                    );
                    service.setValue<List<dynamic>>(
                      'fileNames',
                      files.map((ParkUploadFile f) => f.path).toList(),
                    );
                    service.setValue<int>('fileCount', files.length);
                    setState(() {});
                  },
                  onRemove: (ParkUploadFile file) {
                    files.remove(file);
                    service.setValue<List<dynamic>>(
                      'fileNames',
                      files.map((ParkUploadFile f) => f.path).toList(),
                    );
                    service.setValue<int>('fileCount', files.length);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kColors.brand.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _kColors.brand.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.sync, size: 16, color: _kColors.brand),
                          const SizedBox(width: 8),
                          Text(
                            '绑定状态: 共 $count 个文件',
                            style: TextStyle(
                              fontSize: 14,
                              color: _kColors.brand,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (names.isEmpty)
                        Text(
                          '（暂未选择文件 — 上传前状态）',
                          style: TextStyle(
                            fontSize: 13,
                            color: _kColors.textPlaceholder,
                          ),
                        )
                      else
                        ...names.map(
                          (dynamic name) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '  • $name',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
    // -----------------------------------------------------------------------
    // ParkUpload Binding Demo
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，文件列表与绑定模型实时同步。'
          ' / ParkBindingService bindKey demo: upload files list syncs to model in real time.',
      code: '''
final service = ParkBindingService({'fileNames': <String>[], 'fileCount': 0});
ParkUpload(
  files: _files,
  maxCount: 5,
  mode: ParkUploadMode.fileList,
  onAdd: () => setState(() => _files.add(ParkUploadFile(
    path: 'file_\${_files.length + 1}.pdf',
    status: ParkUploadFileStatus.done,
  ))),
  onRemove: (f) => setState(() => _files.remove(f)),
)''',
      builder: (context) => _UploadBindingDemo(),
    ),
    // ── ParkUpload: bindKey 自动绑定 ──
    ParkDemoScenario(
      title: '绑定演示',
      description:
          'ParkBindingService 持有文件列表模型，ParkUpload 通过 bindKey 自动绑定，'
          '文件变化实时同步到 model。 / ParkBindingService bindKey auto-binding demo:'
          ' upload model syncs automatically via bindKey.',
      code: '''
final service = ParkBindingService({'files': <String>[]});

ParkUpload(
  files: _files,
  bindKey: 'files',
  bindingService: service,
  mode: ParkUploadMode.fileList,
  onAdd: () => setState(() => _files.add(ParkUploadFile(
    path: 'file_\${_files.length + 1}.pdf',
    status: ParkUploadFileStatus.done,
  ))),
  onRemove: (f) => setState(() => _files.remove(f)),
)''',
      builder: (context) => _UploadBindKeyDemo(),
    ),
    // ── ParkUpload: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用 upload 字段类型。'
          ' / ParkForm fieldType=upload demo.',
      code: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'upload_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_avatar',
        fieldType: ParkFieldType.upload,
        labelName: '头像',
        fieldName: 'avatar',
        isRequired: true,
        ext: {'maxCount': 1, 'accept': 'image/*'},
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkForm(
          schema: ParkFormSchema(
            formKey: 'upload_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_avatar',
                fieldType: ParkFieldType.upload,
                labelName: '头像',
                fieldName: 'avatar',
                isRequired: true,
                ext: <String, dynamic>{'maxCount': 1, 'accept': 'image/*'},
              ),
            ],
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`upload`（文件上传）。

### 适用场景
- 头像、附件、图片等文件上传字段。
- 需要选文件并提交文件地址/元数据的场景。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `upload` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `ext` | `ext` | 业务扩展：`maxCount`（数量）、`accept`（类型）、`multiple`（多文件） | 否 |
| `defaultValue` | `default_value` | 已上传文件地址列表 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_avatar',
  fieldType: ParkFieldType.upload,
  labelName: '头像',
  fieldName: 'avatar',
  isRequired: true,
  ext: {'maxCount': 1, 'accept': 'image/*'},
)
```

### 进阶技巧
- 上传约束经 `ext` 承载：`ext['maxCount']`（最大数量）、`ext['accept']`（文件类型）、`ext['multiple']`（是否多文件）。
- `defaultValue` 可预填已上传文件地址。
- 联动：`disabledRule` 在条件不满足时禁止上传。''',
);

class _UploadGridDemo extends StatefulWidget {
  @override
  State<_UploadGridDemo> createState() => _UploadGridDemoState();
}

class _UploadGridDemoState extends State<_UploadGridDemo> {
  final List<ParkUploadFile> _files = [
    const ParkUploadFile(path: 'photo1.jpg', status: ParkUploadFileStatus.done),
    const ParkUploadFile(path: 'photo2.jpg', status: ParkUploadFileStatus.done),
  ];

  @override
  Widget build(BuildContext context) {
    return ParkUpload(
      files: _files,
      maxCount: 9,
      onAdd: () {
        setState(() {
          _files.add(
            ParkUploadFile(
              path: 'photo${_files.length + 1}.jpg',
              status: ParkUploadFileStatus.done,
            ),
          );
        });
      },
      onRemove: (file) => setState(() => _files.remove(file)),
    );
  }
}

class _UploadListDemo extends StatefulWidget {
  @override
  State<_UploadListDemo> createState() => _UploadListDemoState();
}

class _UploadListDemoState extends State<_UploadListDemo> {
  final List<ParkUploadFile> _files = [
    const ParkUploadFile(path: 'report.pdf', status: ParkUploadFileStatus.done),
    const ParkUploadFile(path: 'data.xlsx', status: ParkUploadFileStatus.done),
  ];

  @override
  Widget build(BuildContext context) {
    return ParkUpload(
      files: _files,
      maxCount: 5,
      mode: ParkUploadMode.fileList,
      onAdd: () {
        setState(() {
          _files.add(
            ParkUploadFile(
              path: 'file${_files.length + 1}.doc',
              status: ParkUploadFileStatus.done,
            ),
          );
        });
      },
      onRemove: (file) => setState(() => _files.remove(file)),
    );
  }
}

class _UploadPreviewDemo extends StatefulWidget {
  @override
  State<_UploadPreviewDemo> createState() => _UploadPreviewDemoState();
}

class _UploadPreviewDemoState extends State<_UploadPreviewDemo> {
  final List<ParkUploadFile> _files = <ParkUploadFile>[
    const ParkUploadFile(path: 'photo1.jpg', status: ParkUploadFileStatus.done),
    const ParkUploadFile(path: 'photo2.jpg', status: ParkUploadFileStatus.done),
  ];
  String _log = '点击缩略图触发 onPreview';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(_log, preset: ParkTextPreset.bodySmall),
        const SizedBox(height: 12),
        ParkUpload(
          files: _files,
          previewable: true,
          onPreview: (ParkUploadFile file) {
            setState(() => _log = 'onPreview: ${file.path}');
          },
          onRemove: (file) => setState(() => _files.remove(file)),
        ),
      ],
    );
  }
}

// ============================================================================
// ParkUpload Binding Demo
// ============================================================================

class _UploadBindingDemo extends StatefulWidget {
  @override
  State<_UploadBindingDemo> createState() => _UploadBindingDemoState();
}

class _UploadBindingDemoState extends State<_UploadBindingDemo> {
  late final ParkBindingService _service;
  final List<ParkUploadFile> _files = <ParkUploadFile>[];

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'fileNames': <String>[],
      'fileCount': 0,
    });
    _service.watchEffect(() {
      _service.getValue<List<dynamic>>('fileNames');
      _service.getValue<int>('fileCount');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _syncFilesToBinding() {
    _service.setValue<List<dynamic>>(
      'fileNames',
      _files.map((ParkUploadFile f) => f.path).toList(),
    );
    _service.setValue<int>('fileCount', _files.length);
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> names =
        _service.getValue<List<dynamic>>('fileNames') ?? <dynamic>[];
    final int count = _service.getValue<int>('fileCount') ?? 0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkUpload(
            files: _files,
            maxCount: 5,
            mode: ParkUploadMode.fileList,
            onAdd: () {
              final int idx = _files.length + 1;
              _files.add(
                ParkUploadFile(
                  path: 'file_$idx.pdf',
                  status: ParkUploadFileStatus.done,
                ),
              );
              _syncFilesToBinding();
              setState(() {});
            },
            onRemove: (ParkUploadFile file) {
              _files.remove(file);
              _syncFilesToBinding();
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kColors.brand.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.sync, size: 16, color: _kColors.brand),
                    const SizedBox(width: 8),
                    Text(
                      '绑定状态: 共 $count 个文件',
                      style: TextStyle(
                        fontSize: 14,
                        color: _kColors.brand,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (names.isEmpty)
                  Text(
                    '（暂未选择文件 — 上传前状态）',
                    style: TextStyle(
                      fontSize: 13,
                      color: _kColors.textPlaceholder,
                    ),
                  )
                else
                  ...names.map(
                    (dynamic name) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '  • $name',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ParkUpload bindKey 自动绑定演示
// ============================================================================

class _UploadBindKeyDemo extends StatefulWidget {
  @override
  State<_UploadBindKeyDemo> createState() => _UploadBindKeyDemoState();
}

class _UploadBindKeyDemoState extends State<_UploadBindKeyDemo> {
  late final ParkBindingService _service;
  final List<ParkUploadFile> _files = <ParkUploadFile>[];

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'files': <String>[]});
    _service.watchEffect(() {
      _service.getValue<List<dynamic>>('files');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _syncToBinding() {
    _service.setValue<List<dynamic>>(
      'files',
      _files.map((ParkUploadFile f) => f.path).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> filePaths =
        _service.getValue<List<dynamic>>('files') ?? <dynamic>[];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkUpload(
            files: _files,
            maxCount: 5,
            mode: ParkUploadMode.fileList,
            onAdd: () {
              final int idx = _files.length + 1;
              _files.add(
                ParkUploadFile(
                  path: 'file_$idx.pdf',
                  status: ParkUploadFileStatus.done,
                ),
              );
              _syncToBinding();
              setState(() {});
            },
            onRemove: (ParkUploadFile file) {
              _files.remove(file);
              _syncToBinding();
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kColors.brand.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.sync, size: 16, color: _kColors.brand),
                    const SizedBox(width: 8),
                    // Flexible：窄屏下长文案不溢出
                    Expanded(
                      child: Text(
                        'model JSON — 共 ${filePaths.length} 个文件',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: _kColors.brand,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '{\n  "files": ${filePaths.isEmpty ? '<String>[]' : filePaths.toString()}\n}',
                  style: TextStyle(
                    fontSize: 13,
                    color: _kColors.textSecondary,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ParkForm
// =====================================================================
final ParkComponentSpec _parkForm = ParkComponentSpec(
  name: 'ParkForm',
  title: '表单容器（统一入口）',
  category: 'input',
  description:
      '统一表单入口，支持两种模式：'
      '1) 手动模式（children）：包裹 Flutter 原生 Form，提供 GlobalKey<FormState> 管理，'
      '内置提交 / 重置按钮，收集子表单字段值。'
      '2) Schema 驱动模式（schema）：传入 ParkFormSchema 自动渲染字段、处理联动、校验和数据源加载。'
      '通过 ParkForm.of(context) 可在子组件中访问表单状态。',
  icon: Icons.dynamic_form_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'onSubmit',
      type: 'ValueChanged<Map<String, dynamic>>?',
      defaultVal: 'null',
      description: '提交回调，参数为表单字段值的集合。',
    ),
    ParkPropertyDef(
      name: 'onReset',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '重置回调。',
    ),
    ParkPropertyDef(
      name: 'submitLabel',
      type: 'String',
      defaultVal: "'提交'",
      description: '提交按钮文字。',
    ),
    ParkPropertyDef(
      name: 'resetLabel',
      type: 'String',
      defaultVal: "'重置'",
      description: '重置按钮文字。',
    ),
    ParkPropertyDef(
      name: 'showReset',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示重置按钮。',
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double?',
      defaultVal: 'null（使用 park.spacing.base）',
      description: '子组件间距。为 null 时使用主题默认间距。',
    ),
    ParkPropertyDef(
      name: 'padding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null（EdgeInsets.zero）',
      description: '表单内边距。',
    ),
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: '子组件列表（表单字段）。',
    ),
    ParkPropertyDef(
      name: 'layout',
      type: 'ParkFormLayout',
      defaultVal: 'ParkFormLayout.vertical',
      description: '表单布局方式：vertical（标签在上）/ horizontal（标签在左）/ inline（内联）。',
    ),
    ParkPropertyDef(
      name: 'labelWidth',
      type: 'double',
      defaultVal: '100',
      description: '标签固定宽度（horizontal 布局时生效）。',
    ),
    ParkPropertyDef(
      name: 'colon',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在标签后显示冒号。',
    ),
    ParkPropertyDef(
      name: 'requiredMark',
      type: 'ParkRequiredMark',
      defaultVal: 'ParkRequiredMark.asterisk',
      description: '必填标记样式：asterisk（星号）/ optional（可选标记）/ none（不显示）。',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkFormSize?',
      defaultVal: 'null',
      description: '表单尺寸（传递给子组件输入控件）。',
    ),
    ParkPropertyDef(
      name: 'submitting',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于提交中状态（提交按钮转圈、禁用）。',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于整体加载态（显示加载占位）。',
    ),
    ParkPropertyDef(
      name: 'footer',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义底部区域（替换默认按钮区）。',
    ),
    ParkPropertyDef(
      name: 'showDefaultActions',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示默认提交/重置按钮区。',
    ),
    ParkPropertyDef(
      name: 'initialValues',
      type: 'Map<String, dynamic>?',
      defaultVal: 'null',
      description: '初始值集合，在 initState 时逐项填充字段值。',
    ),
    ParkPropertyDef(
      name: 'scrollToFirstError',
      type: 'bool',
      defaultVal: 'false',
      description: '校验失败时是否自动滚动到第一个错误字段。',
    ),
    ParkPropertyDef(
      name: 'onValuesChange',
      type: 'ParkFormValuesChangeCallback?',
      defaultVal: 'null',
      description: '任意字段值变更时的回调（参数为 changedValues 与 allValues）。',
    ),
    ParkPropertyDef(
      name: 'model',
      type: 'Map<String, dynamic>?',
      defaultVal: 'null',
      description: '绑定模型数据；传入后自动创建 ParkBindingService 实现双向绑定。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description: '外部绑定服务；优先级高于 model，注入子组件树供双向绑定。',
    ),
    // ── Schema 驱动模式参数 ──
    ParkPropertyDef(
      name: 'schema',
      type: 'ParkFormSchema?',
      defaultVal: 'null',
      description: 'Schema 驱动模式：表单结构定义。传入后自动渲染字段、处理联动与校验。与 children 二选一。',
    ),
    ParkPropertyDef(
      name: 'onSchemaSubmit',
      type: 'ValueChanged<Map<String, dynamic>>?',
      defaultVal: 'null',
      description: 'Schema 模式：提交回调（校验通过后触发）。',
    ),
    ParkPropertyDef(
      name: 'asyncValidator',
      type: 'AsyncFieldValidator?',
      defaultVal: 'null',
      description: 'Schema 模式：异步校验回调。',
    ),
    ParkPropertyDef(
      name: 'asyncValidatorRegistry',
      type: 'Map<String, AsyncFieldValidator>',
      defaultVal: '{}',
      description: 'Schema 模式：异步校验注册表（按 asyncValidatorKey 映射）。',
    ),
    ParkPropertyDef(
      name: 'configureEngine',
      type: 'void Function(ParkFormEngine)?',
      defaultVal: 'null',
      description: 'Schema 模式：引擎配置回调，用于注入数据源解析器等。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSubmit',
      signature: 'ValueChanged<Map<String, dynamic>>',
      description: '点击提交按钮且校验通过后触发，参数为收集到的表单字段值。',
    ),
    ParkEventDef(
      name: 'onReset',
      signature: 'VoidCallback',
      description: '点击重置按钮后触发。',
    ),
    ParkEventDef(
      name: 'onValuesChange',
      signature: 'ParkFormValuesChangeCallback',
      description: '表单值变化回调（参数为 changedValues 和 allValues）。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'of',
      signature: 'static ParkFormState? of(BuildContext context)',
      description: '获取最近的 ParkFormState。子组件可通过此方法访问表单状态，执行提交 / 重置 / 校验等操作。',
    ),
    ParkMethodDef(
      name: 'submit',
      signature: 'bool submit()',
      description: '提交表单。先校验，校验通过后保存并触发 onSubmit 回调。返回是否提交成功。',
    ),
    ParkMethodDef(
      name: 'reset',
      signature: 'void reset()',
      description: '重置表单，清空所有字段值和收集的值，并触发 onReset 回调。',
    ),
    ParkMethodDef(
      name: 'validate',
      signature: 'bool validate()',
      description: '校验表单（不触发 save）。返回是否校验通过。',
    ),
    ParkMethodDef(
      name: 'setValue',
      signature: 'void setValue(String key, dynamic value)',
      description: '设置表单字段值（供子组件调用）。',
    ),
    ParkMethodDef(
      name: 'removeValue',
      signature: 'void removeValue(String key)',
      description: '移除表单字段值。',
    ),
  ],
  basicUsageCode: '''
final formValues = <String, dynamic>{};

ParkForm(
  onSubmit: (values) => print('提交: \$values'),
  submitLabel: '提交',
  showReset: true,
  resetLabel: '重置',
  children: [
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    ParkInput(label: '邮箱', hintText: '请输入邮箱'),
  ],
)
''',
  guide: '''
## 何时使用
- 需要收集用户输入的表单数据时
- 注册、登录、配置等表单场景

## 使用建议
- 通过 ParkForm.of(context) 在子组件中访问表单状态
- 使用 onSubmit 获取所有字段值的集合
- showReset: true 显示重置按钮
- layout 切换 vertical / horizontal / inline 布局
- requiredMark 控制必填标记样式
- 表单字段建议使用 ParkInput / ParkSelect / ParkDatePicker 等 Park 组件，支持自动收集

## 搭配推荐
- 搭配 ParkInput 做文本输入
- 搭配 ParkSelect 做下拉选择
- 搭配 ParkButton 做提交操作
- 传入 schema 参数即可切换为 Schema 驱动模式（原 ParkForm 能力）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础表单',
      description: '包含姓名和邮箱的简单表单，带提交和重置按钮。',
      code: '''
ParkForm(
  onSubmit: (values) => print('提交: \$values'),
  submitLabel: '提交',
  showReset: true,
  resetLabel: '重置',
  children: [
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    SizedBox(height: _kSpacing.sm),
    ParkInput(label: '邮箱', hintText: '请输入邮箱'),
  ],
)
''',
      builder: (context) => ParkForm(
        onSubmit: (_) {},
        submitLabel: '提交',
        showReset: true,
        resetLabel: '重置',
        children: <Widget>[
          ParkInput(label: '姓名', hintText: '请输入姓名'),
          SizedBox(height: _kSpacing.sm),
          ParkInput(label: '邮箱', hintText: '请输入邮箱'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带校验的表单',
      description: '使用 validator 做必填校验和格式校验。',
      code: '''
ParkForm(
  onSubmit: (values) => print('提交: \$values'),
  children: [
    ParkInput(
      label: '姓名',
      hintText: '请输入姓名',
      validator: (v) => (v == null || v.isEmpty) ? '请输入姓名' : null,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkInput(
      label: '邮箱',
      hintText: '请输入邮箱',
      validator: (v) {
        if (v == null || v.isEmpty) return '请输入邮箱';
        if (!v.contains('@')) return '邮箱格式不正确';
        return null;
      },
    ),
  ],
)
''',
      builder: (context) => ParkForm(
        onSubmit: (_) {},
        children: <Widget>[
          ParkInput(
            label: '姓名',
            hintText: '请输入姓名',
            validator: (v) => (v == null || v.isEmpty) ? '请输入姓名' : null,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkInput(
            label: '邮箱',
            hintText: '请输入邮箱',
            validator: (v) {
              if (v == null || v.isEmpty) return '请输入邮箱';
              if (!v.contains('@')) return '邮箱格式不正确';
              return null;
            },
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '方法：校验 / 提交 / 重置',
      description:
          '通过 GlobalKey<ParkFormState> 调用 validate() / submit() / reset() 方法，并展示结果。',
      code: '''
final _formKey = GlobalKey<ParkFormState>();

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    ParkForm(
      key: _formKey,
      onSubmit: (values) => setState(() => _result = '提交: \$values'),
      children: <Widget>[
        ParkInput(
          label: '姓名',
          hintText: '请输入姓名',
          validator: (v) => (v == null || v.isEmpty) ? '请输入姓名' : null,
        ),
      ],
    ),
    SizedBox(height: _kSpacing.sm),
    Text('结果: \$_result',
        style: TextStyle(fontSize: _kTypography.sizeBodySmall, color: _kColors.textSecondary)),
    SizedBox(height: _kSpacing.sm),
    Row(
      children: <Widget>[
        Expanded(child: ParkButton(onPressed: () => _formKey.currentState?.validate(), child: const ParkText('校验'))),
        SizedBox(width: _kSpacing.sm),
        Expanded(child: ParkButton(onPressed: () => _formKey.currentState?.submit(), child: const ParkText('提交'))),
        SizedBox(width: _kSpacing.sm),
        Expanded(child: ParkButton(onPressed: () => _formKey.currentState?.reset(), child: const ParkText('重置'))),
      ],
    ),
  ],
)
''',
      builder: (context) => _FormMethodDemo(),
    ),
    ParkDemoScenario(
      title: '值变更回调 onValuesChange',
      description: '任意字段值变化时触发 onValuesChange，实时回传全部字段值。',
      code: '''
ParkForm(
  onValuesChange: (changed, all) => setState(() => _all = all),
  children: <Widget>[
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    SizedBox(height: _kSpacing.sm),
    ParkInput(label: '邮箱', hintText: '请输入邮箱'),
  ],
)
''',
      builder: (context) => _FormValuesChangeDemo(),
    ),
    ParkDemoScenario(
      title: '水平布局',
      description: 'layout: ParkFormLayout.horizontal 标签在左、字段在右。',
      code: '''
ParkForm(
  layout: ParkFormLayout.horizontal,
  labelWidth: 80,
  onSubmit: (_) {},
  children: <Widget>[
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    SizedBox(height: _kSpacing.sm),
    ParkInput(label: '邮箱', hintText: '请输入邮箱'),
  ],
)
''',
      builder: (context) => ParkForm(
        layout: ParkFormLayout.horizontal,
        labelWidth: 80,
        onSubmit: (_) {},
        children: <Widget>[
          ParkInput(label: '姓名', hintText: '请输入姓名'),
          SizedBox(height: _kSpacing.sm),
          ParkInput(label: '邮箱', hintText: '请输入邮箱'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '重置回调 onReset',
      description: '点击重置按钮后触发 onReset 回调，回显提示 / onReset fires on reset',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    String msg = '未重置';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkForm(
          showReset: true,
          onReset: () { msg = '已重置'; setState(() {}); },
          onSubmit: (_) {},
          children: <Widget>[
            ParkInput(label: '姓名', hintText: '请输入姓名'),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText(msg),
      ],
    );
  },
)''',
      builder: (context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          String msg = '未重置';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkForm(
                showReset: true,
                onReset: () {
                  msg = '已重置';
                  setState(() {});
                },
                onSubmit: (_) {},
                children: <Widget>[ParkInput(label: '姓名', hintText: '请输入姓名')],
              ),
              SizedBox(height: _kSpacing.sm),
              ParkText(msg),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '方法：setValue',
      description:
          '通过 GlobalKey<ParkFormState> 调用 setValue 以编程方式写入字段值 / setValue via key',
      code: '''
final _formKey = GlobalKey<ParkFormState>();

ParkForm(
  key: _formKey,
  onSubmit: (_) {},
  children: <Widget>[
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    SizedBox(height: _kSpacing.sm),
    ParkButton(
      onPressed: () => _formKey.currentState?.setValue('name', '张三'),
      child: const ParkText('setValue 姓名=张三'),
    ),
  ],
)''',
      builder: (context) => _FormSetValueDemo(),
    ),
    ParkDemoScenario(
      title: '方法：removeValue',
      description:
          '通过 GlobalKey<ParkFormState> 调用 removeValue 移除字段值 / removeValue via key',
      code: '''
final _formKey = GlobalKey<ParkFormState>();

ParkForm(
  key: _formKey,
  initialValues: <String, dynamic>{'name': '张三'},
  onSubmit: (_) {},
  children: <Widget>[
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    SizedBox(height: _kSpacing.sm),
    ParkButton(
      onPressed: () => _formKey.currentState?.removeValue('name'),
      child: const ParkText('removeValue 姓名'),
    ),
  ],
)''',
      builder: (context) => _FormRemoveValueDemo(),
    ),
    // ── ParkForm: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 model / bindingService 实现表单字段的双向绑定，'
          '值变化自动同步到 model。'
          ' / ParkBindingService bindKey demo: form values sync to model in real time.',
      code: '''
final service = ParkBindingService({'name': '张三', 'email': 'zhangsan@example.com'});

ParkForm(
  bindingService: service,
  onSubmit: (values) => print(values),
  children: [
    ParkInput(label: '姓名', hintText: '请输入姓名', bindKey: 'name'),
    SizedBox(height: 8),
    ParkInput(label: '邮箱', hintText: '请输入邮箱', bindKey: 'email'),
  ],
)''',
      builder: (BuildContext context) => _FormBindingDemo(),
    ),
    // ── ParkForm: Schema 驱动模式示例 ──
    ParkDemoScenario(
      title: 'Schema 驱动模式（统一入口）',
      description:
          '使用 ParkForm 的 schema 参数，以配置方式渲染表单字段。'
          '效果等同于原 ParkForm，现在统一使用 ParkForm。'
          ' / ParkForm schema-driven mode: same as former ParkForm.',
      code: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'form_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_name',
        fieldType: ParkFieldType.text,
        labelName: '姓名',
        fieldName: 'name',
        isRequired: true,
        fieldPrompt: '请输入姓名',
      ),
      ParkFormFieldSchema(
        fieldId: 'f_email',
        fieldType: ParkFieldType.text,
        labelName: '邮箱',
        fieldName: 'email',
        fieldPrompt: '请输入邮箱',
      ),
    ],
  ),
  onSchemaSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkForm(
          schema: ParkFormSchema(
            formKey: 'form_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_name',
                fieldType: ParkFieldType.text,
                labelName: '姓名',
                fieldName: 'name',
                isRequired: true,
                fieldPrompt: '请输入姓名',
              ),
              ParkFormFieldSchema(
                fieldId: 'f_email',
                fieldType: ParkFieldType.text,
                labelName: '邮箱',
                fieldName: 'email',
                fieldPrompt: '请输入邮箱',
              ),
            ],
          ),
          onSchemaSubmit: (_) {},
        ),
      ),
    ),
    // ── ParkForm: ParkBinding 示例（全局 model）──
    ParkDemoScenario(
      title: '绑定演示（ParkForm + 全局 model）',
      description:
          '通过 ParkForm + ParkBindingService 实现全局 model 双向绑定，'
          '下方实时回显 model JSON。使用 ParkFormItem 包裹表单项，ElevatedButton 触发提交。'
          ' / ParkForm + ParkBindingService global model demo.',
      code: '''
class _FormBindingV2Demo extends StatefulWidget {
  @override
  State<_FormBindingV2Demo> createState() => _FormBindingV2DemoState();
}

class _FormBindingV2DemoState extends State<_FormBindingV2Demo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService({'name': '', 'email': ''});
    _service.watchEffect(() {
      _service.getValue<String>('name');
      _service.getValue<String>('email');
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
    final name = _service.getValue<String>('name') ?? '';
    final email = _service.getValue<String>('email') ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkForm(
          bindingService: _service,
          children: [
            ParkFormItem(
              bindKey: 'name',
              label: '姓名',
              child: ParkInput(hintText: '请输入姓名'),
            ),
            SizedBox(height: 8),
            ParkFormItem(
              bindKey: 'email',
              label: '邮箱',
              child: ParkInput(hintText: '请输入邮箱'),
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => print(_service.model),
          child: const Text('提交'),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Text(
            'model: {name: \$name, email: \$email}',
            style: const TextStyle(fontSize: 13, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}''',
      builder: (BuildContext context) => _FormBindingV2Demo(),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`ParkForm` 本身不对应某个 `ParkFieldType` 枚举值，它是**手动（非 schema 驱动）**的表单容器：在其 `children` 中直接放置 `ParkInput` / `ParkSwitch` / `ParkSelect` 等输入控件，每个控件在动态表单体系里对应一种 `fieldType`（text / number / select / toggle / date …）。

### 适用场景
- 结构固定、需精细控制布局（vertical / horizontal / inline）与交互的页面表单。
- 需要手写 `validator` 校验、`onSubmit` 提交与 `showReset` 重置的表单。
- 当字段由后端 schema 驱动、需要自动渲染与联动时，改用 `ParkForm` + `ParkFormSchema`。

### 关键 schema 属性
下面这些 `ParkFormFieldSchema` 属性与 `ParkForm` 子控件的概念等价参数一一对应，便于从手动表单迁移到 schema 表单：

| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldName` | `field_name` / `key` | 对应子控件的收集键（bindKey / name） | 是 |
| `labelName` | `label_name` / `label` | 对应子控件的 `label` | 是 |
| `fieldPrompt` | `field_prompt` / `placeholder` | 对应子控件的 `hintText` | 否 |
| `isRequired` | `is_required` / `required` | 对应子控件的 `validator` 必填校验 | 否 |
| `fieldLength` | `field_length` | 对应文本控件的 `maxLength` | 否 |
| `regexTag` / `regexExpression` | `regex_tag` / `regex` | 对应 `validator` 内的正则校验 | 否 |

### 最小可用示例
```dart
ParkForm(
  onSubmit: (values) => print(values),
  children: <Widget>[
    ParkInput(label: '姓名', hintText: '请输入姓名'),
    ParkSelect(
      label: '城市',
      items: const <ParkSelectOption>[
        ParkSelectOption(label: '北京', value: 'bj'),
        ParkSelectOption(label: '上海', value: 'sh'),
      ],
    ),
  ],
)
```

### 进阶技巧
- 用 `ParkForm.of(context)` 在子组件中访问 / 写入表单值。
- `layout` 切换 `vertical` / `horizontal` / `inline`；`requiredMark` 控制必填星标样式。
- 与 `ParkBinding` / `ParkBindingEngine` 集成，实现表单值 ↔ 业务模型双向绑定。
- 需要显隐联动 / 异步校验 / 分组布局时，迁移到 `ParkForm`。''',
);

// =====================================================================
// 新增 demo 组件（ParkSlider / ParkStepper / ParkRate / ParkTreeSelect /
// ParkPicker / ParkCascader / ParkUpload / ParkForm）
// =====================================================================

class _SliderRangeDemo extends StatefulWidget {
  @override
  State<_SliderRangeDemo> createState() => _SliderRangeDemoState();
}

class _SliderRangeDemoState extends State<_SliderRangeDemo> {
  double _rangeStart = 20;
  double _rangeEnd = 80;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '范围: ${_rangeStart.toInt()} ~ ${_rangeEnd.toInt()}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkSlider(
          range: true,
          rangeStart: _rangeStart,
          rangeEnd: _rangeEnd,
          min: 0,
          max: 100,
          onRangeChanged: (s, e) {
            setState(() {
              _rangeStart = s;
              _rangeEnd = e;
            });
          },
        ),
      ],
    );
  }
}

class _SliderStartEndDemo extends StatefulWidget {
  @override
  State<_SliderStartEndDemo> createState() => _SliderStartEndDemoState();
}

class _SliderStartEndDemoState extends State<_SliderStartEndDemo> {
  double _value = 50;
  double _start = 0;
  double _end = 100;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'start: ${_start.toInt()}  end: ${_end.toInt()}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkSlider(
          value: _value,
          min: 0,
          max: 100,
          showValue: true,
          onChangeStart: (v) => setState(() => _start = v),
          onChangeEnd: (v) => setState(() => _end = v),
          onChanged: (v) => setState(() => _value = v),
        ),
      ],
    );
  }
}

class _SliderMarksDemo extends StatefulWidget {
  @override
  State<_SliderMarksDemo> createState() => _SliderMarksDemoState();
}

class _SliderMarksDemoState extends State<_SliderMarksDemo> {
  double _value = 50;

  @override
  Widget build(BuildContext context) {
    return ParkSlider(
      value: _value,
      min: 0,
      max: 100,
      divisions: 10,
      showValue: true,
      marks: const <double>[0, 50, 100],
      tooltipBuilder: (v) => v.toInt().toString(),
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class _StepperLimitDemo extends StatefulWidget {
  @override
  State<_StepperLimitDemo> createState() => _StepperLimitDemoState();
}

class _StepperLimitDemoState extends State<_StepperLimitDemo> {
  int _count = 5;
  bool _over = false;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkStepper(
          value: _count,
          min: 0,
          max: 5,
          onChanged: (v) => setState(() {
            _count = v;
            _over = false;
          }),
          onOverLimit: () => setState(() => _over = true),
        ),
        if (_over)
          Padding(
            padding: EdgeInsets.only(top: _kSpacing.xs),
            child: Text(
              '已达边界',
              style: TextStyle(
                fontSize: park.typography.sizeBodySmall,
                color: park.colors.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _StepperPrecisionDemo extends StatefulWidget {
  @override
  State<_StepperPrecisionDemo> createState() => _StepperPrecisionDemoState();
}

class _StepperPrecisionDemoState extends State<_StepperPrecisionDemo> {
  int _price = 5;

  @override
  Widget build(BuildContext context) {
    return ParkStepper(
      value: _price,
      min: 0,
      max: 10,
      precision: 1,
      formatter: (v) => '\$${v.toStringAsFixed(1)}',
      onChanged: (v) => setState(() => _price = v),
    );
  }
}

class _StepperOutlineDemo extends StatefulWidget {
  @override
  State<_StepperOutlineDemo> createState() => _StepperOutlineDemoState();
}

class _StepperOutlineDemoState extends State<_StepperOutlineDemo> {
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return ParkStepper(
      value: _count,
      min: 0,
      max: 99,
      theme: ParkStepperTheme.outline,
      suffix: const Text('件'),
      onChanged: (v) => setState(() => _count = v),
    );
  }
}

class _RateTextDemo extends StatefulWidget {
  @override
  State<_RateTextDemo> createState() => _RateTextDemoState();
}

class _RateTextDemoState extends State<_RateTextDemo> {
  double _rating = 3;

  @override
  Widget build(BuildContext context) {
    return ParkRate(
      value: _rating,
      showText: true,
      tooltips: const <String>['很差', '较差', '一般', '较好', '很好'],
      onChanged: (v) => setState(() => _rating = v),
    );
  }
}

class _TreeSelectLineDemo extends StatefulWidget {
  @override
  State<_TreeSelectLineDemo> createState() => _TreeSelectLineDemoState();
}

class _TreeSelectLineDemoState extends State<_TreeSelectLineDemo> {
  Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return ParkTreeSelect(
      nodes: _demoTreeNodes,
      selectedKeys: _selected,
      multiple: true,
      treeLine: true,
      onChanged: (keys) => setState(() => _selected = keys),
    );
  }
}

class _TreeSelectExpandAllDemo extends StatefulWidget {
  @override
  State<_TreeSelectExpandAllDemo> createState() =>
      _TreeSelectExpandAllDemoState();
}

class _TreeSelectExpandAllDemoState extends State<_TreeSelectExpandAllDemo> {
  Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return ParkTreeSelect(
      nodes: _demoTreeNodes,
      selectedKeys: _selected,
      multiple: true,
      treeDefaultExpandAll: true,
      onChanged: (keys) => setState(() => _selected = keys),
    );
  }
}

class _TreeSelectMaxTagDemo extends StatefulWidget {
  @override
  State<_TreeSelectMaxTagDemo> createState() => _TreeSelectMaxTagDemoState();
}

class _TreeSelectMaxTagDemoState extends State<_TreeSelectMaxTagDemo> {
  Set<String> _selected = {'team1', 'team2', 'team4'};

  @override
  Widget build(BuildContext context) {
    return ParkTreeSelect(
      nodes: _demoTreeNodes,
      selectedKeys: _selected,
      multiple: true,
      maxTagCount: 2,
      onChanged: (keys) => setState(() => _selected = keys),
    );
  }
}

// ============================================================================
// ParkTreeSelect: ParkBinding 示例
// ============================================================================

class _TreeSelectBindingDemo extends StatefulWidget {
  @override
  State<_TreeSelectBindingDemo> createState() => _TreeSelectBindingDemoState();
}

class _TreeSelectBindingDemoState extends State<_TreeSelectBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'department': <String>{'team1'},
    });
    _service.watchEffect(() {
      _service.getValue<Set<String>>('department');
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
    final Set<String> dept = _service.getValue<Set<String>>('department') ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkTreeSelect(
          nodes: _demoTreeNodes,
          bindKey: 'department',
          bindingService: _service,
          multiple: true,
          checkable: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sync, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: ${dept.isEmpty ? "{}" : dept.toString()}',
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
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

class _PickerMultiColumnDemo extends StatefulWidget {
  @override
  State<_PickerMultiColumnDemo> createState() => _PickerMultiColumnDemoState();
}

class _PickerMultiColumnDemoState extends State<_PickerMultiColumnDemo> {
  List<String> _cols = ['zj', 'hz'];

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '已选: ${_cols.join(" / ")}',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        SizedBox(
          height: 260,
          child: ParkPicker(
            title: '选择省/市',
            items: const <ParkPickerItem>[],
            multiColumn: true,
            columns: const [
              [
                ParkPickerItem(label: '浙江', value: 'zj'),
                ParkPickerItem(label: '江苏', value: 'js'),
              ],
              [
                ParkPickerItem(label: '杭州', value: 'hz'),
                ParkPickerItem(label: '南京', value: 'nj'),
              ],
            ],
            values: _cols,
            onMultiConfirm: (vals) => setState(() => _cols = vals),
          ),
        ),
      ],
    );
  }
}

class _PickerInlineCellDemo extends StatefulWidget {
  @override
  State<_PickerInlineCellDemo> createState() => _PickerInlineCellDemoState();
}

class _PickerInlineCellDemoState extends State<_PickerInlineCellDemo> {
  String _selected = '';
  bool _expanded = false;

  static const List<ParkPickerItem> _cityItems = [
    ParkPickerItem(label: '北京', value: 'beijing'),
    ParkPickerItem(label: '上海', value: 'shanghai'),
    ParkPickerItem(label: '广州', value: 'guangzhou'),
    ParkPickerItem(label: '深圳', value: 'shenzhen'),
    ParkPickerItem(label: '杭州', value: 'hangzhou'),
    ParkPickerItem(label: '成都', value: 'chengdu'),
    ParkPickerItem(label: '武汉', value: 'wuhan'),
  ];

  String get _selectedLabel {
    if (_selected.isEmpty) return '请选择';
    final idx = _cityItems.indexWhere((i) => i.value == _selected);
    return idx >= 0 ? _cityItems[idx].label : _selected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkCell(
          titleText: '选择城市',
          note: _selectedLabel,
          arrow: true,
          onPressed: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          SizedBox(
            height: 220,
            child: ParkPicker(
              title: '选择城市',
              items: _cityItems,
              value: _selected.isEmpty ? null : _selected,
              onConfirm: (v) => setState(() {
                _selected = v;
                _expanded = false;
              }),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// ParkCascader: ParkBinding 示例
// ============================================================================

class _CascaderBindingDemo extends StatefulWidget {
  @override
  State<_CascaderBindingDemo> createState() => _CascaderBindingDemoState();
}

class _CascaderBindingDemoState extends State<_CascaderBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'region': ['zj', 'hz'],
    });
    _service.watchEffect(() {
      _service.getValue<List<String>>('region');
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
        ParkCascader(
          label: '地区',
          bindKey: 'region',
          bindingService: _service,
          options: _demoCascaderOptions,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sync, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: ${_service.model.toString()}',
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
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

class _CascaderSavedDemo extends StatefulWidget {
  @override
  State<_CascaderSavedDemo> createState() => _CascaderSavedDemoState();
}

class _CascaderSavedDemoState extends State<_CascaderSavedDemo> {
  final GlobalKey<FormState> _cascaderFormKey = GlobalKey<FormState>();
  List<String>? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _cascaderFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ParkCascader(
            label: '地区',
            hintText: '请选择地区',
            options: _demoCascaderOptions,
            onSaved: (path) => setState(() => _saved = path),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () => _cascaderFormKey.currentState?.save(),
            child: const ParkText('保存'),
          ),
          if (_saved != null)
            Text(
              '已保存: ${_saved!.join(" / ")}',
              style: TextStyle(
                fontSize: _kTypography.sizeBodySmall,
                color: _kColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadRetryDemo extends StatefulWidget {
  @override
  State<_UploadRetryDemo> createState() => _UploadRetryDemoState();
}

class _UploadRetryDemoState extends State<_UploadRetryDemo> {
  final List<ParkUploadFile> _files = <ParkUploadFile>[
    const ParkUploadFile(path: 'doc1.pdf', status: ParkUploadFileStatus.done),
    const ParkUploadFile(path: 'doc2.pdf', status: ParkUploadFileStatus.error),
  ];

  @override
  Widget build(BuildContext context) {
    return ParkUpload(
      files: _files,
      onAdd: () {},
      onRemove: (f) => setState(() => _files.remove(f)),
      onRetry: (f) => setState(() {
        final i = _files.indexOf(f);
        if (i != -1) {
          _files[i] = f.copyWith(
            status: ParkUploadFileStatus.uploading,
            progress: 0.5,
          );
        }
      }),
    );
  }
}

class _UploadDragDemo extends StatefulWidget {
  @override
  State<_UploadDragDemo> createState() => _UploadDragDemoState();
}

class _UploadDragDemoState extends State<_UploadDragDemo> {
  final List<ParkUploadFile> _files = <ParkUploadFile>[
    const ParkUploadFile(path: 'photo1.jpg', status: ParkUploadFileStatus.done),
  ];

  @override
  Widget build(BuildContext context) {
    return ParkUpload(
      files: _files,
      draggable: true,
      onAdd: () => setState(
        () => _files.add(
          ParkUploadFile(
            path: 'file${_files.length}.png',
            status: ParkUploadFileStatus.done,
          ),
        ),
      ),
      onDropFiles: (data) => setState(
        () => _files.add(
          const ParkUploadFile(
            path: 'dropped.png',
            status: ParkUploadFileStatus.done,
          ),
        ),
      ),
      onRemove: (f) => setState(() => _files.remove(f)),
    );
  }
}

class _FormMethodDemo extends StatefulWidget {
  @override
  State<_FormMethodDemo> createState() => _FormMethodDemoState();
}

class _FormMethodDemoState extends State<_FormMethodDemo> {
  final GlobalKey<ParkFormState> _formKey = GlobalKey<ParkFormState>();
  String _result = '未提交';

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkForm(
          key: _formKey,
          onSubmit: (values) => setState(() => _result = '提交: $values'),
          children: <Widget>[
            ParkInput(
              label: '姓名',
              hintText: '请输入姓名',
              validator: (v) => (v == null || v.isEmpty) ? '请输入姓名' : null,
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '结果: $_result',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
        SizedBox(height: _kSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: ParkButton(
                onPressed: () => _formKey.currentState?.validate(),
                child: const ParkText('校验'),
              ),
            ),
            SizedBox(width: _kSpacing.sm),
            Expanded(
              child: ParkButton(
                onPressed: () => _formKey.currentState?.submit(),
                child: const ParkText('提交'),
              ),
            ),
            SizedBox(width: _kSpacing.sm),
            Expanded(
              child: ParkButton(
                onPressed: () => _formKey.currentState?.reset(),
                child: const ParkText('重置'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormValuesChangeDemo extends StatefulWidget {
  @override
  State<_FormValuesChangeDemo> createState() => _FormValuesChangeDemoState();
}

class _FormValuesChangeDemoState extends State<_FormValuesChangeDemo> {
  Map<String, dynamic> _all = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkForm(
          onValuesChange: (changed, all) => setState(() => _all = all),
          children: <Widget>[
            ParkInput(label: '姓名', hintText: '请输入姓名'),
            SizedBox(height: _kSpacing.sm),
            ParkInput(label: '邮箱', hintText: '请输入邮箱'),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前值: $_all',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FormSetValueDemo extends StatefulWidget {
  @override
  State<_FormSetValueDemo> createState() => _FormSetValueDemoState();
}

class _FormSetValueDemoState extends State<_FormSetValueDemo> {
  final GlobalKey<ParkFormState> _formKey = GlobalKey<ParkFormState>();
  Map<String, dynamic> _values = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkForm(
          key: _formKey,
          onSubmit: (_) {},
          onValuesChange: (changed, all) => setState(() => _values = all),
          children: <Widget>[
            ParkInput(label: '姓名', hintText: '请输入姓名'),
            SizedBox(height: _kSpacing.sm),
            ParkButton(
              onPressed: () {
                _formKey.currentState?.setValue('name', '张三');
                setState(
                  () => _values =
                      _formKey.currentState?.values ?? <String, dynamic>{},
                );
              },
              child: const ParkText('setValue 姓名=张三'),
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前值: $_values',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FormRemoveValueDemo extends StatefulWidget {
  @override
  State<_FormRemoveValueDemo> createState() => _FormRemoveValueDemoState();
}

class _FormRemoveValueDemoState extends State<_FormRemoveValueDemo> {
  final GlobalKey<ParkFormState> _formKey = GlobalKey<ParkFormState>();
  Map<String, dynamic> _values = <String, dynamic>{'name': '张三'};

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkForm(
          key: _formKey,
          initialValues: <String, dynamic>{'name': '张三'},
          onSubmit: (_) {},
          onValuesChange: (changed, all) => setState(() => _values = all),
          children: <Widget>[
            ParkInput(label: '姓名', hintText: '请输入姓名'),
            SizedBox(height: _kSpacing.sm),
            ParkButton(
              onPressed: () {
                _formKey.currentState?.removeValue('name');
                setState(
                  () => _values =
                      _formKey.currentState?.values ?? <String, dynamic>{},
                );
              },
              child: const ParkText('removeValue 姓名'),
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前值: $_values',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ParkPicker: ParkBinding 示例
// ============================================================================

class _PickerBindingDemo extends StatefulWidget {
  @override
  State<_PickerBindingDemo> createState() => _PickerBindingDemoState();
}

class _PickerBindingDemoState extends State<_PickerBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'city': 'beijing'});
    _service.watchEffect(() {
      _service.getValue<String>('city');
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
        SizedBox(
          height: 260,
          child: ParkPicker(
            title: '选择城市',
            bindKey: 'city',
            bindingService: _service,
            items: const [
              ParkPickerItem(label: '北京', value: 'beijing'),
              ParkPickerItem(label: '上海', value: 'shanghai'),
              ParkPickerItem(label: '广州', value: 'guangzhou'),
            ],
            onConfirm: (v) => _service.setValue('city', v),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sync, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: ${_service.model.toString()}',
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
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
// ParkSlider: ParkBinding 示例
// ============================================================================

class _SliderBindingDemo extends StatefulWidget {
  @override
  State<_SliderBindingDemo> createState() => _SliderBindingDemoState();
}

class _SliderBindingDemoState extends State<_SliderBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'volume': 50});
    _service.watchEffect(() {
      _service.getValue<double>('volume');
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
        ParkSlider(
          bindKey: 'volume',
          bindingService: _service,
          min: 0,
          max: 100,
          showValue: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sync, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: ${_service.model.toString()}',
                  style: const TextStyle(fontSize: 13, color: Colors.blue),
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
// ParkForm: ParkBinding 示例
// ============================================================================

class _FormBindingDemo extends StatefulWidget {
  @override
  State<_FormBindingDemo> createState() => _FormBindingDemoState();
}

class _FormBindingDemoState extends State<_FormBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'name': '张三',
      'email': 'zhangsan@example.com',
    });
    _service.watchEffect(() {
      _service.getValue<dynamic>('name');
      _service.getValue<dynamic>('email');
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
    final String name = _service.getValue<String>('name') ?? '';
    final String email = _service.getValue<String>('email') ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkForm(
          bindingService: _service,
          onSubmit: (_) {},
          children: <Widget>[
            ParkInput(label: '姓名', hintText: '请输入姓名', bindKey: 'name'),
            SizedBox(height: _kSpacing.sm),
            ParkInput(label: '邮箱', hintText: '请输入邮箱', bindKey: 'email'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sync, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'model: {name: $name, email: $email}',
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
// ParkForm: ParkBinding 示例（全局 model + ParkFormItem + ElevatedButton）
// ============================================================================

class _FormBindingV2Demo extends StatefulWidget {
  @override
  State<_FormBindingV2Demo> createState() => _FormBindingV2DemoState();
}

class _FormBindingV2DemoState extends State<_FormBindingV2Demo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'name': '', 'email': ''});
    _service.watchEffect(() {
      _service.getValue<String>('name');
      _service.getValue<String>('email');
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
    final String name = _service.getValue<String>('name') ?? '';
    final String email = _service.getValue<String>('email') ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkForm(
          bindingService: _service,
          children: <Widget>[
            ParkFormItem(
              bindKey: 'name',
              label: '姓名',
              child: ParkInput(hintText: '请输入姓名'),
            ),
            const SizedBox(height: 8),
            ParkFormItem(
              bindKey: 'email',
              label: '邮箱',
              child: ParkInput(hintText: '请输入邮箱'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => print(_service.model),
          child: const Text('提交'),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Text(
            'model: {name: $name, email: $email}',
            style: const TextStyle(fontSize: 13, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
