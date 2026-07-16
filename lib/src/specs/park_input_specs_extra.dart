// Park 输入组件补充规格 — Batch 2（完善版）
//
// 覆盖：ParkSegmented / ParkCalendar / ParkDateRangePicker
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
final ParkSpacing _kSpacing = ParkSpacing.defaults();

// ---------------------------------------------------------------------------
// ParkFormItem
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkFormItemSpec = ParkComponentSpec(
  name: 'ParkFormItem',
  title: '表单项',
  category: 'input',
  description:
      '统一承载 label 标题、required 必填标记、extra 扩展区、helpText 帮助文本、'
      'errorText 错误提示与 child 内容区的表单项外壳。该组件不处理具体输入逻辑，'
      '只负责布局，是动态表单运行时与静态表单页的统一容器层。',
  icon: Icons.format_list_bulleted_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(name: 'label', type: 'String?', defaultVal: 'null', description: '标题文本。'),
    ParkPropertyDef(name: 'labelWidget', type: 'Widget?', defaultVal: 'null', description: '自定义标题 Widget，优先级高于 label。'),
    ParkPropertyDef(name: 'required', type: 'bool', defaultVal: 'false', description: '是否必填。'),
    ParkPropertyDef(name: 'extra', type: 'Widget?', defaultVal: 'null', description: '右侧扩展内容，如"可选""说明""操作按钮"。'),
    ParkPropertyDef(name: 'helpText', type: 'String?', defaultVal: 'null', description: '帮助文本，显示在内容区下方、错误提示上方。'),
    ParkPropertyDef(name: 'errorText', type: 'String?', defaultVal: 'null', description: '错误提示文本。'),
    ParkPropertyDef(name: 'showError', type: 'bool', defaultVal: 'true', description: '是否显示错误态。'),
    ParkPropertyDef(name: 'child', type: 'Widget', required: true, description: '内容区 Widget。'),
    ParkPropertyDef(name: 'margin', type: 'EdgeInsetsGeometry?', defaultVal: 'null', description: '外层边距。'),
    ParkPropertyDef(name: 'contentTopSpacing', type: 'double?', defaultVal: 'null', description: '内层内容区上边距。'),
    ParkPropertyDef(name: 'showRequiredMark', type: 'bool', defaultVal: 'true', description: '是否显示必填星号。'),
    ParkPropertyDef(name: 'name', type: 'String?', defaultVal: 'null', description: '字段名称，用于表单值收集与字段 key 注册。'),
    ParkPropertyDef(name: 'tooltip', type: 'String?', defaultVal: 'null', description: '标签旁的提示文本，hover 展示。'),
    ParkPropertyDef(name: 'labelCol', type: 'double?', defaultVal: 'null', description: '覆盖表单级 labelWidth 的单项标签宽度（horizontal 布局生效）。'),
    ParkPropertyDef(name: 'rules', type: 'List<ParkFormRule>?', defaultVal: 'null', description: '内联校验规则列表，用于 validateByRules。'),
    ParkPropertyDef(name: 'validator', type: 'String? Function(dynamic)?', defaultVal: 'null', description: '自定义校验函数（对齐 FormField.validator），与 rules 同时生效：先 validator 后 rules。供 ParkForm.validate 统一校验（B30）。'),
    ParkPropertyDef(name: 'bindKey', type: 'String?', defaultVal: 'null', description: '绑定键（点号分隔路径）。置于已注入绑定服务的 ParkForm 内可双向绑定字段值。不设时行为不变。'),
    ParkPropertyDef(name: 'colon', type: 'bool?', defaultVal: 'null', description: '覆盖表单级 colon 设置；null 时继承表单级。'),
    ParkPropertyDef(name: 'layout', type: 'ParkFormLayout?', defaultVal: 'null', description: '表单项布局；null 时继承 ParkForm / ParkFormScope。'),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkFormItem(
  label: '用户名',
  required: true,
  child: ParkInput(hintText: '请输入用户名'),
)
''',
  guide: '''
## 何时使用
- 构建静态或动态表单的每一个字段外壳
- 需要在 label 旁展示必填星号、帮助文本、错误提示或右侧操作

## 使用建议
- child 负责具体输入控件（ParkInput / ParkSelect 等），ParkFormItem 只管外壳
- 设置 name 后字段会自动注册到父级 ParkForm，便于值收集与滚动定位
- required + showRequiredMark 控制必填星号；errorText + showError 控制错误态
- layout 可单字段覆盖表单级 horizontal / vertical 布局
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础表单项',
      description: 'label + 必填星号 + 输入控件，演示最常见的字段外壳。',
      code: '''
ParkFormItem(
  label: '用户名',
  required: true,
  child: ParkInput(hintText: '请输入用户名'),
)''',
      builder: (BuildContext context) => ParkFormItem(
        label: '用户名',
        required: true,
        child: ParkInput(hintText: '请输入用户名'),
      ),
    ),
    ParkDemoScenario(
      title: '错误态',
      description: 'errorText 配合 required 展示校验失败提示。',
      code: '''
ParkFormItem(
  label: '密码',
  required: true,
  errorText: '密码长度不能少于 6 位',
  child: ParkInput(hintText: '请输入密码', obscureText: true),
)''',
      builder: (BuildContext context) => ParkFormItem(
        label: '密码',
        required: true,
        errorText: '密码长度不能少于 6 位',
        child: ParkInput(hintText: '请输入密码', obscureText: true),
      ),
    ),
    ParkDemoScenario(
      title: '横向布局 + 提示',
      description: 'layout 设为 horizontal，配合 tooltip 与 extra 右侧扩展。',
      code: '''
ParkFormItem(
  label: '邮箱',
  layout: ParkFormLayout.horizontal,
  tooltip: '我们不会公开你的邮箱',
  extra: Text('选填'),
  child: ParkInput(hintText: '请输入邮箱'),
)''',
      builder: (BuildContext context) => ParkFormItem(
        label: '邮箱',
        layout: ParkFormLayout.horizontal,
        tooltip: '我们不会公开你的邮箱',
        extra: const Text('选填'),
        child: ParkInput(hintText: '请输入邮箱'),
      ),
    ),
    ParkDemoScenario(
      title: '内联校验规则 (rules)',
      description: 'rules 配置必填与邮箱格式，ParkFormItem.validateByRules 按规则链返回首个错误。'
          ' 表单级统一校验需配合 ParkForm.validate / ParkDynamicForm 运行时生效（B30）。'
          ' / rules enforce required + email format; evaluated via validateByRules.',
      code: '''
ParkFormItem(
  label: '邮箱',
  required: true,
  rules: [
    ParkFormRule(required: true, message: '请输入邮箱'),
    ParkFormRule(type: ParkRuleType.email, message: '邮箱格式不正确'),
  ],
  child: ParkInput(hintText: '请输入邮箱'),
)''',
      builder: (BuildContext context) => ParkFormItem(
        label: '邮箱',
        required: true,
        rules: const <ParkFormRule>[
          ParkFormRule(required: true, message: '请输入邮箱'),
          ParkFormRule(type: ParkRuleType.email, message: '邮箱格式不正确'),
        ],
        child: ParkInput(hintText: '请输入邮箱'),
      ),
    ),
  ],
);

/// 输入类补充组件规格字典（6 个组件）。
Map<String, ParkComponentSpec> get parkInputSpecsExtra =>
    <String, ParkComponentSpec>{
      'ParkSegmented': _parkSegmentedSpec,
      'ParkCalendar': _parkCalendarSpec,
      'ParkDateRangePicker': _parkDateRangePickerSpec,
      'ParkFormItem': _parkFormItemSpec,
      'ParkMentions': _parkMentionsSpec,
      'ParkCheckboxGroup': _parkCheckboxGroupSpec,
    };

// ---------------------------------------------------------------------------
// ParkMentions
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkMentionsSpec = ParkComponentSpec(
  name: 'ParkMentions',
  title: '提及输入',
  category: 'input',
  description:
      '在文本中输入触发符弹出建议下拉面板的提及输入组件（对标 antd Mentions）。'
      '默认触发符为 @，可配置为 @ / # 等；选中后将标记语法（默认 @value）插入文本。'
      '支持受控 / 非受控、关键字过滤、键盘上下选择 + 回车确认、onSearch / onSelect 回调，'
      '以及自定义插入文本格式。下拉面板基于 park 令牌渲染，文案走 ParkLocalizations。',
  icon: Icons.alternate_email_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkMentionItem>',
      required: true,
      description: '建议数据源；每项含 value（插入值）/ label（展示名）/ avatar（可选）/ disabled（可选）。',
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'String?',
      defaultVal: 'null（非受控，内部维护文本）',
      description: '受控值；传入时为受控模式，由外部维护。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<String>?',
      defaultVal: 'null',
      description: '文本变更回调（输出含标记语法的文本）。',
    ),
    ParkPropertyDef(
      name: 'triggerChars',
      type: 'List<String>',
      defaultVal: "['@']",
      description: "触发符列表，可配置为 ['@'] 或 ['@', '#']。",
    ),
    ParkPropertyDef(
      name: 'placeholder',
      type: 'String?',
      defaultVal: 'null（回退 ParkLocalizations.inputPlaceholder）',
      description: '占位符；为空时走国际化默认文案。',
    ),
    ParkPropertyDef(
      name: 'enabled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用。',
    ),
    ParkPropertyDef(
      name: 'maxLines',
      type: 'int?',
      defaultVal: 'null',
      description: '最大行数（多行文本）。',
    ),
    ParkPropertyDef(
      name: 'minLines',
      type: 'int?',
      defaultVal: 'null',
      description: '最小行数（多行文本）。',
    ),
    ParkPropertyDef(
      name: 'onSearch',
      type: 'void Function(String query, String trigger)?',
      defaultVal: 'null',
      description: '命中触发符并输入查询时触发。',
    ),
    ParkPropertyDef(
      name: 'onSelect',
      type: 'void Function(ParkMentionItem, String trigger)?',
      defaultVal: 'null',
      description: '选中条目时触发。',
    ),
    ParkPropertyDef(
      name: 'filterOption',
      type: 'bool Function(String query, ParkMentionItem item)?',
      defaultVal: 'null（按 label/value 包含匹配，忽略大小写）',
      description: '自定义过滤逻辑。',
    ),
    ParkPropertyDef(
      name: 'mentionBuilder',
      type: 'String Function(ParkMentionItem, String trigger)?',
      defaultVal: "null（默认 '\$trigger\$value '）",
      description: '自定义插入文本；默认插入 @value 并在其后补一个空格。',
    ),
    ParkPropertyDef(
      name: 'popupMaxHeight',
      type: 'double',
      defaultVal: '240',
      description: '建议面板最大高度。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<String>?',
      description: '文本变更回调。',
    ),
    ParkEventDef(
      name: 'onSearch',
      signature: 'void Function(String query, String trigger)?',
      description: '命中触发符并输入查询时触发。',
    ),
    ParkEventDef(
      name: 'onSelect',
      signature: 'void Function(ParkMentionItem, String trigger)?',
      description: '选中条目时触发。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkMentions(
  items: [
    ParkMentionItem(value: 'alice', label: 'Alice'),
    ParkMentionItem(value: 'bob', label: 'Bob'),
  ],
  onChanged: (text) => print(text),
)
''',
  guide: '''
## 何时使用
- 评论、聊天、发布等需要 @ 某人 / # 某标签的场景
- 任何需要在文本内联引用实体并结构化输出的输入

## 使用建议
- 触发符通过 [triggerChars] 配置，默认 @；可传入 ['@', '#'] 同时支持提及与标签。
- 数据源为 [ParkMentionItem] 列表，label 用于下拉展示，value 为选中后写入文本的值。
- 输出格式由 [mentionBuilder] 决定，默认插入 `@value `（value 后带一个空格）；
  如需结构化（如 `@[Alice](alice)`），提供自定义 mentionBuilder 即可。
- 键盘上下键可在下拉中移动高亮项，回车确认选中。
- 受控模式：传入 [value] + [onChanged]，由父组件维护文本；非受控时不传 value。
- 占位符与空状态文案走 ParkLocalizations，无需硬编码。
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础 @ 提及',
      description: '输入 @ 触发用户名建议，选中后插入 @value。下方实时回显 onChanged 文本。',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String text = '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkMentions(
          items: [
            ParkMentionItem(value: 'alice', label: 'Alice'),
            ParkMentionItem(value: 'bob', label: 'Bob'),
            ParkMentionItem(value: 'carol', label: 'Carol'),
          ],
          onChanged: (v) => setState(() => text = v),
        ),
        SizedBox(height: 8),
        ParkText(text.isEmpty ? '输入 @ 试试' : text),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) {
          String text = '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ParkMentions(
                items: const <ParkMentionItem>[
                  ParkMentionItem(value: 'alice', label: 'Alice'),
                  ParkMentionItem(value: 'bob', label: 'Bob'),
                  ParkMentionItem(value: 'carol', label: 'Carol'),
                ],
                onChanged: (String v) => setState(() => text = v),
              ),
              const SizedBox(height: 8),
              ParkText(text.isEmpty ? '输入 @ 试试' : text,
                  preset: ParkTextPreset.bodySmall),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '# 标签',
      description: "配置 triggerChars 为 ['#']，输入 # 触发标签建议；支持异步数据源风格的自定义过滤。",
      code: '''
ParkMentions(
  triggerChars: ['#'],
  items: [
    ParkMentionItem(value: 'bug', label: 'Bug'),
    ParkMentionItem(value: 'feature', label: 'Feature'),
    ParkMentionItem(value: 'doc', label: 'Doc'),
  ],
  onChanged: (v) => print(v),
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) {
          String text = '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ParkMentions(
                triggerChars: const <String>['#'],
                items: const <ParkMentionItem>[
                  ParkMentionItem(value: 'bug', label: 'Bug'),
                  ParkMentionItem(value: 'feature', label: 'Feature'),
                  ParkMentionItem(value: 'doc', label: 'Doc'),
                ],
                onChanged: (String v) => setState(() => text = v),
              ),
              const SizedBox(height: 8),
              ParkText(text.isEmpty ? '输入 # 试试' : text,
                  preset: ParkTextPreset.bodySmall),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '受控 + onSelect 回显',
      description: '受控模式配合 onSelect，选中条目后在下方回显其 label 与触发符。',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String value = '';
    String selected = '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkMentions(
          value: value,
          items: [
            ParkMentionItem(value: 'alice', label: 'Alice'),
            ParkMentionItem(value: 'bob', label: 'Bob'),
          ],
          onChanged: (v) => setState(() => value = v),
          onSelect: (item, trigger) => setState(() => selected = '\$trigger\${item.label}'),
        ),
        SizedBox(height: 8),
        ParkText('已选: \$selected'),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) {
          String value = '';
          String selected = '-';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ParkMentions(
                value: value,
                items: const <ParkMentionItem>[
                  ParkMentionItem(value: 'alice', label: 'Alice'),
                  ParkMentionItem(value: 'bob', label: 'Bob'),
                ],
                onChanged: (String v) => setState(() => value = v),
                onSelect: (ParkMentionItem item, String trigger) =>
                    setState(() => selected = '$trigger${item.label}'),
              ),
              const SizedBox(height: 8),
              ParkText('已选: $selected', preset: ParkTextPreset.bodySmall),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkSegmented
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkSegmentedSpec = ParkComponentSpec(
  name: 'ParkSegmented',
  title: '分段控制器',
  category: 'input',
  description:
      '在一组互斥选项中切换的分段控制器，选中态带滑块动画过渡。支持图标+文字或纯文字模式，'
      '支持 block 撑满宽度与 multiSelect 多选模式，支持多选值（multiValues）与自定义选项渲染。',
  icon: Icons.linear_scale_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkSegmentedItem>',
      required: true,
      description: '分段选项列表，每项含 value / label / icon（Widget）/ disabled / badge。',
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'String?',
      defaultVal: 'null（非受控，内部维护选中态）',
      description: '当前选中值（单选模式）。为 null 时进入非受控模式，由组件内部维护选中态。',
    ),
    ParkPropertyDef(
      name: 'multiValues',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '当前多选值（多选模式）。',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<String>?',
      defaultVal: 'null',
      description: '选中值变更回调（单选模式）。',
    ),
    ParkPropertyDef(
      name: 'onMultiChanged',
      type: 'ValueChanged<List<String>>?',
      defaultVal: 'null',
      description: '多选模式下选中值变更回调。',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否整体禁用。',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkSegmentedSize',
      defaultVal: 'ParkSegmentedSize.medium',
      description: '控件尺寸：small / medium / large。',
    ),
    ParkPropertyDef(
      name: 'block',
      type: 'bool',
      defaultVal: 'false',
      description: '是否撑满父容器宽度。',
    ),
    ParkPropertyDef(
      name: 'multiSelect',
      type: 'bool',
      defaultVal: 'false',
      description: '是否允许多选。',
    ),
    ParkPropertyDef(
      name: 'optionBuilder',
      type: 'Widget Function(ParkSegmentedItem, bool)?',
      defaultVal: 'null',
      description: '自定义选项渲染器。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description: '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description: '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm/ParkDynamicForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<String>?',
      description: '单选模式下选中值变更回调。',
    ),
    ParkEventDef(
      name: 'onMultiChanged',
      signature: 'ValueChanged<List<String>>?',
      description: '多选模式下选中值变更回调。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSegmented(
  items: [
    ParkSegmentedItem(value: 'day', label: '日'),
    ParkSegmentedItem(value: 'week', label: '周'),
    ParkSegmentedItem(value: 'month', label: '月'),
  ],
  onChanged: (String v) {},
)
''',
  guide: '''
## 何时使用
- 在少量互斥选项间快速切换（如 日 / 周 / 月、列表 / 网格视图）
- 表单中的分段单选场景

## 使用建议
- 选项数量建议 2~5 个，过多时分段时间过窄不利点击
- block: true 可让分段器通栏展示
- 需要多选时开启 multiSelect，并监听 onMultiChanged
- 选项可配置自定义 Widget 图标（icon）与 badge 角标增强信息表达
- multiValues 配合 multiSelect 使用，支持外部控制多选状态
- optionBuilder 自定义每个选项的渲染 Widget
- disabled 整体禁用，item.disabled 禁用单个选项
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础分段',
      description: '日 / 周 / 月 三个选项的单选分段控制器。',
      code: '''
ParkSegmented(
  items: [
    ParkSegmentedItem(value: 'day', label: '日'),
    ParkSegmentedItem(value: 'week', label: '周'),
    ParkSegmentedItem(value: 'month', label: '月'),
  ],
  onChanged: (String v) {},
)''',
      builder: (BuildContext context) => ParkSegmented(
        items: const <ParkSegmentedItem>[
          ParkSegmentedItem(value: 'day', label: '日'),
          ParkSegmentedItem(value: 'week', label: '周'),
          ParkSegmentedItem(value: 'month', label: '月'),
        ],
        onChanged: (String v) {},
      ),
    ),
    ParkDemoScenario(
      title: '通栏与图标',
      description: 'block 撑满宽度，选项带图标与角标。',
      code: '''
ParkSegmented(
  block: true,
  items: [
    ParkSegmentedItem(value: 'list', label: '列表', icon: Icon(Icons.list)),
    ParkSegmentedItem(value: 'grid', label: '网格', icon: Icon(Icons.grid_view), badge: 3),
  ],
  onChanged: (String v) {},
)''',
      builder: (BuildContext context) => ParkSegmented(
        block: true,
        items: const <ParkSegmentedItem>[
          ParkSegmentedItem(value: 'list', label: '列表', icon: Icon(Icons.list)),
          ParkSegmentedItem(
            value: 'grid',
            label: '网格',
            icon: Icon(Icons.grid_view),
            badge: 3,
          ),
        ],
        onChanged: (String v) {},
      ),
    ),
    ParkDemoScenario(
      title: '多选模式',
      description: 'multiSelect 开启后支持多选，监听 onMultiChanged。',
      code: '''
ParkSegmented(
  multiSelect: true,
  items: [
    ParkSegmentedItem(value: 'a', label: '选项 A'),
    ParkSegmentedItem(value: 'b', label: '选项 B'),
    ParkSegmentedItem(value: 'c', label: '选项 C'),
  ],
  onMultiChanged: (List<String> v) {},
)''',
      builder: (BuildContext context) => ParkSegmented(
        multiSelect: true,
        items: const <ParkSegmentedItem>[
          ParkSegmentedItem(value: 'a', label: '选项 A'),
          ParkSegmentedItem(value: 'b', label: '选项 B'),
          ParkSegmentedItem(value: 'c', label: '选项 C'),
        ],
        onMultiChanged: (List<String> v) {},
      ),
    ),
    ParkDemoScenario(
      title: '受控模式',
      description: '外部通过 StatefulBuilder 维护 value，点击同步刷新选中态与滑块位置。',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String v = 'day';
    return ParkSegmented(
      value: v,
      items: [
        ParkSegmentedItem(value: 'day', label: '日'),
        ParkSegmentedItem(value: 'week', label: '周'),
        ParkSegmentedItem(value: 'month', label: '月'),
      ],
      onChanged: (val) => setState(() => v = val),
    );
  },
)
''',
      builder: (BuildContext context) {
        String v = 'day';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return ParkSegmented(
              value: v,
              items: const <ParkSegmentedItem>[
                ParkSegmentedItem(value: 'day', label: '日'),
                ParkSegmentedItem(value: 'week', label: '周'),
                ParkSegmentedItem(value: 'month', label: '月'),
              ],
              onChanged: (String val) => setState(() => v = val),
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '非受控模式',
      description: '不传 value 且 onChanged 为空，点击仍即时选中（内部维护选中态，无需父组件维护）。',
      code: '''
ParkSegmented(
  items: [
    ParkSegmentedItem(value: 'day', label: '日'),
    ParkSegmentedItem(value: 'week', label: '周'),
    ParkSegmentedItem(value: 'month', label: '月'),
  ],
)
''',
      builder: (BuildContext context) => ParkSegmented(
        items: const <ParkSegmentedItem>[
          ParkSegmentedItem(value: 'day', label: '日'),
          ParkSegmentedItem(value: 'week', label: '周'),
          ParkSegmentedItem(value: 'month', label: '月'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '禁用与单选项禁用',
      description: '整体禁用或通过 item.disabled 禁用单个选项。',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSegmented(
      disabled: true,
      items: [
        ParkSegmentedItem(value: 'a', label: '整体禁用'),
        ParkSegmentedItem(value: 'b', label: '不可操作'),
      ],
    ),
    SizedBox(height: _kSpacing.sm),
    ParkSegmented(
      items: [
        ParkSegmentedItem(value: 'a', label: '可用'),
        ParkSegmentedItem(value: 'b', label: '已禁用', disabled: true),
        ParkSegmentedItem(value: 'c', label: '可用'),
      ],
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkSegmented(
            disabled: true,
            items: const <ParkSegmentedItem>[
              ParkSegmentedItem(value: 'a', label: '整体禁用'),
              ParkSegmentedItem(value: 'b', label: '不可操作'),
            ],
          ),
          SizedBox(height: _kSpacing.sm),
          ParkSegmented(
            items: const <ParkSegmentedItem>[
              ParkSegmentedItem(value: 'a', label: '可用'),
              ParkSegmentedItem(value: 'b', label: '已禁用', disabled: true),
              ParkSegmentedItem(value: 'c', label: '可用'),
            ],
          ),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkCalendar
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkCalendarSpec = ParkComponentSpec(
  name: 'ParkCalendar',
  title: '日历',
  category: 'input',
  description:
      '日期选择日历，支持 single / range / multiple 三种选择模式，可限制可选区间、'
      '高亮今日、禁用指定日期，并提供自定义单元格渲染器、动态禁用日期回调、'
      '面板月份变更回调、首日设置等。',
  icon: Icons.calendar_month_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '当前选中日期（single 模式）。',
    ),
    ParkPropertyDef(
      name: 'rangeValue',
      type: 'DateTimeRange?',
      defaultVal: 'null',
      description: '当前选中范围（range 模式）。',
    ),
    ParkPropertyDef(
      name: 'multipleValues',
      type: 'List<DateTime>?',
      defaultVal: 'null',
      description: '当前多选日期（multiple 模式）。',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkCalendarMode',
      defaultVal: 'ParkCalendarMode.single',
      description: '选择模式：single / range / multiple。',
    ),
    ParkPropertyDef(
      name: 'minDate',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '最早可选日期。',
    ),
    ParkPropertyDef(
      name: 'maxDate',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '最晚可选日期。',
    ),
    ParkPropertyDef(
      name: 'showToday',
      type: 'bool',
      defaultVal: 'true',
      description: '是否高亮今日。',
    ),
    ParkPropertyDef(
      name: 'disabledDates',
      type: 'List<DateTime>?',
      defaultVal: 'null',
      description: '禁用的日期列表（静态列表）。',
    ),
    ParkPropertyDef(
      name: 'cellBuilder',
      type: 'Widget Function(DateTime, bool, bool, bool)?',
      defaultVal: 'null',
      description: '自定义日期单元格渲染器，替换默认的日期单元格 Widget。',
    ),
    ParkPropertyDef(
      name: 'disabledDate',
      type: 'bool Function(DateTime)?',
      defaultVal: 'null',
      description: '动态禁用日期回调，返回 true 的日期不可选（与静态 disabledDates 叠加生效）。',
    ),
    ParkPropertyDef(
      name: 'firstDayOfWeek',
      type: 'int',
      defaultVal: '1（周一）',
      description: '每周的第一天：0=周日, 1=周一, ..., 6=周六。',
    ),
    ParkPropertyDef(
      name: 'headerBuilder',
      type: 'Widget Function(DateTime, VoidCallback, VoidCallback)?',
      defaultVal: 'null',
      description: '自定义月份导航头部，替换默认的年月标题和前后箭头。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description: '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description: '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm/ParkDynamicForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<DateTime>?',
      description: '单日选择变更回调。',
    ),
    ParkEventDef(
      name: 'onRangeChanged',
      signature: 'ValueChanged<DateTimeRange>?',
      description: '范围选择变更回调。',
    ),
    ParkEventDef(
      name: 'onMultipleChanged',
      signature: 'ValueChanged<List<DateTime>>?',
      description: '多选变更回调。',
    ),
    ParkEventDef(
      name: 'onPanelChange',
      signature: 'ValueChanged<DateTime>?',
      description: '面板月份变更回调（翻页时触发）。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkCalendar(
  mode: ParkCalendarMode.single,
  onChanged: (DateTime date) {},
)
''',
  guide: '''
## 何时使用
- 需要用户选择日期 / 日期范围的场景（如生日、预约、报表区间）
- 表单中的日期字段

## 使用建议
- 单日选择用 single，区间选择用 range，多日期标记用 multiple
- 通过 minDate / maxDate 限制可选范围，避免无效输入
- 使用 disabledDates 或 disabledDate 动态禁用特定日期
- 需要高度定制单元格时提供 cellBuilder
- firstDayOfWeek 设置每周起始日（默认周一）
- headerBuilder 可替换月份导航为自定义结构
- onPanelChange 监听翻页动作，可用于加载远程数据
- multipleValues 配合 multiple 模式使用

## 搭配推荐
- 搭配 ParkDatePicker 做日期选择入口
- 搭配 ParkForm 做日期表单
- 搭配 ParkCell 做日期展示
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '单日选择',
      description: '默认 single 模式日历。',
      code: '''
ParkCalendar(
  mode: ParkCalendarMode.single,
  onChanged: (DateTime date) {},
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkCalendar(
          mode: ParkCalendarMode.single,
          onChanged: (DateTime date) {},
        ),
      ),
    ),
    ParkDemoScenario(
      title: '区间选择',
      description: 'range 模式可选择一个起止区间。',
      code: '''
ParkCalendar(
  mode: ParkCalendarMode.range,
  onRangeChanged: (DateTimeRange range) {},
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkCalendar(
          mode: ParkCalendarMode.range,
          onRangeChanged: (DateTimeRange range) {},
        ),
      ),
    ),
    ParkDemoScenario(
      title: '多选模式',
      description: 'multiple 模式可选择多个日期。',
      code: '''
ParkCalendar(
  mode: ParkCalendarMode.multiple,
  onMultipleChanged: (List<DateTime> dates) {},
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkCalendar(
          mode: ParkCalendarMode.multiple,
          onMultipleChanged: (List<DateTime> dates) {},
        ),
      ),
    ),
    ParkDemoScenario(
      title: '限制范围与禁用',
      description: 'minDate/maxDate 限制可选范围；disabledDates 禁用特定日期。',
      code: '''
ParkCalendar(
  mode: ParkCalendarMode.single,
  minDate: DateTime(2025, 6, 1),
  maxDate: DateTime(2025, 6, 30),
  disabledDates: [DateTime(2025, 6, 15), DateTime(2025, 6, 20)],
  onChanged: (DateTime date) {},
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkCalendar(
          mode: ParkCalendarMode.single,
          minDate: DateTime(2025, 6, 1),
          maxDate: DateTime(2025, 6, 30),
          disabledDates: <DateTime>[
            DateTime(2025, 6, 15),
            DateTime(2025, 6, 20),
          ],
          onChanged: (DateTime date) {},
        ),
      ),
    ),
    ParkDemoScenario(
      title: '自定义首日',
      description: 'firstDayOfWeek: 0 将周日设为每周第一天。',
      code: '''
ParkCalendar(
  mode: ParkCalendarMode.single,
  firstDayOfWeek: 0,
  onChanged: (DateTime date) {},
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkCalendar(
          mode: ParkCalendarMode.single,
          firstDayOfWeek: 0,
          onChanged: (DateTime date) {},
        ),
      ),
    ),
    ParkDemoScenario(
      title: '面板翻页回调',
      description: 'onPanelChange 在日历翻页（切换月份）时触发，可用于加载远程数据。'
          ' / onPanelChange fires when the visible month changes (e.g. for lazy-loading remote data).',
      code: '''
ParkCalendar(
  mode: ParkCalendarMode.single,
  onPanelChange: (DateTime visibleMonth) {},
  onChanged: (DateTime date) {},
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkCalendar(
          mode: ParkCalendarMode.single,
          onPanelChange: (DateTime visibleMonth) {},
          onChanged: (DateTime date) {},
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkDateRangePicker
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDateRangePickerSpec = ParkComponentSpec(
  name: 'ParkDateRangePicker',
  title: '日期范围筛选',
  category: 'input',
  description:
      '日期范围筛选组件，提供开始/结束日期选择、快捷预设与重置功能。'
      '可通过静态方法 show 弹出独立面板，也可实例化内嵌使用，'
      '还支持嵌入 ParkDropdownSheet 的 child 模式中作为自定义面板内容。',
  icon: Icons.date_range_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'startTime',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '起始日期。',
    ),
    ParkPropertyDef(
      name: 'endTime',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '结束日期。',
    ),
    ParkPropertyDef(
      name: 'firstDate',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '可选最早日期。',
    ),
    ParkPropertyDef(
      name: 'lastDate',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '可选最晚日期。',
    ),
    ParkPropertyDef(
      name: 'showShortcuts',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示快捷预设条。',
    ),
    ParkPropertyDef(
      name: 'shortcuts',
      type: 'List<ParkDateRangeShortcut>',
      defaultVal: '[today, last7Days, last30Days, thisMonth]',
      description: '快捷预设列表，可自定义传入。',
    ),
    ParkPropertyDef(
      name: 'showReset',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示重置按钮。',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '标签文字（内联模式）。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description: '绑定键（点号分隔路径）。不设时组件行为不变。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<ParkDateRange?>?',
      description: '日期范围变更回调（含取消时 null）。',
    ),
    ParkEventDef(
      name: 'onConfirm',
      signature: 'ValueChanged<ParkDateRange>?',
      description: '确认回调。',
    ),
    ParkEventDef(
      name: 'onCancel',
      signature: 'VoidCallback?',
      description: '取消回调。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkDateRangePicker.show',
      signature:
          'static Future<ParkDateRange?> show(BuildContext context, {DateTime? startTime, DateTime? endTime, ...})',
      description: '静态弹出日期范围选择面板，返回 ParkDateRange，取消时返回 null。',
    ),
  ],
  basicUsageCode: '''
// 静态弹出
final ParkDateRange? result = await ParkDateRangePicker.show(
  context,
  startTime: DateTime(2026, 1, 1),
  endTime: DateTime(2026, 1, 31),
);
if (result != null) {
  print('\${result.start} ~ \${result.end}');
}

// 内联使用
ParkDateRangePicker(
  startTime: startDate,
  endTime: endDate,
  onChanged: (range) => setState(() => _range = range),
)

// 嵌入 ParkDropdownSheet
ParkDropdownSheet.showCustom(
  context,
  title: '选择日期范围',
  child: ParkDateRangePicker(
    onChanged: (range) { /* 处理范围 */ },
  ),
  height: 360,
);
''',
  guide: '''
## 何时使用

- 需要用户选择一段日期区间进行筛选/过滤
- 报表、订单列表、数据统计等需要日期范围查询的场景
- 需要提供"近7天"、"近30天"等快捷预设的场景

## 使用建议

1. **快捷预设**：默认提供今天/近7天/近30天/本月，可通过 shortcuts 自定义
2. **无值状态**：支持空开始/空结束，适合"不限时间"场景
3. **组合使用**：ParkDateRangePicker 可以嵌入 ParkDropdownSheet 的 child 模式中，
   打造"点击 → 弹出日期范围选择"的完整交互
4. **绑定引擎**：设 bindKey 可联动表单
5. **重置按钮**：一键清空开始/结束日期

## 数据模型

ParkDateRange 包含 start 和 end 两个 DateTime 字段，已重写 == 和 hashCode 支持比较。
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '静态弹出',
      description: '使用 show 静态方法弹出日期范围选择面板。',
      code: '''
ParkDateRangePicker.show(
  context,
  startTime: DateTime(2026, 1, 1),
  endTime: DateTime(2026, 1, 31),
);
''',
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkDateRangePicker.show(
            context,
            startTime: DateTime(2026, 1, 1),
            endTime: DateTime(2026, 1, 31),
          );
        },
        child: const Text('弹出日期范围选择'),
      ),
    ),
    ParkDemoScenario(
      title: '内联使用',
      description: '实例化 ParkDateRangePicker 嵌入页面中使用。',
      code: '''
ParkDateRangePicker(
  startTime: DateTime(2026, 6, 1),
  endTime: DateTime(2026, 6, 30),
  label: '统计区间',
)
''',
      builder: (BuildContext context) => Column(
        children: [
          ParkDateRangePicker(
            startTime: DateTime(2026, 6, 1),
            endTime: DateTime(2026, 6, 30),
            label: '统计区间',
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '嵌入下拉面板',
      description: 'ParkDateRangePicker 嵌入 ParkDropdownSheet 的 child 模式。',
      code: '''
ParkDropdownSheet.showCustom(
  context,
  title: '选择日期范围',
  child: ParkDateRangePicker(
    onConfirm: (range) { /* 处理 */ },
  ),
  height: 360,
);
''',
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkDropdownSheet.showCustom(
            context,
            title: '选择日期范围',
            child: ParkDateRangePicker(
              onConfirm: (ParkDateRange range) {},
            ),
            height: 360,
          );
        },
        child: const Text('嵌入下拉面板'),
      ),
    ),
    ParkDemoScenario(
      title: '确认与取消回调',
      description: 'onConfirm 在用户确认范围时触发，onCancel 在取消时触发（show 静态方法取消返回 null）。'
          ' / onConfirm fires on confirm; onCancel fires on cancel (the show() static returns null on cancel).',
      code: '''
ParkDateRangePicker(
  onConfirm: (ParkDateRange range) {},
  onCancel: () {},
)''',
      builder: (BuildContext context) => Column(
        children: <Widget>[
          ParkDateRangePicker(
            onConfirm: (ParkDateRange range) {},
            onCancel: () {},
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互：范围变更回显 (onChanged)',
      description: '实时回显 ParkDateRangePicker 的 onChanged 回调——选择开始/结束日期、'
          '点击快捷预设或重置按钮均会触发。'
          ' / onChanged fires on every range change (select, shortcut, reset).',
      code: '''
ParkDateRangePicker(
  onChanged: (ParkDateRange? range) {
    print('range: \${range?.start} ~ \${range?.end}');
  },
)''',
      builder: (BuildContext context) {
        String log = '等待选择...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                const SizedBox(height: 12),
                ParkDateRangePicker(
                  onChanged: (ParkDateRange? range) {
                    setState(() {
                      log = range == null
                          ? '已重置（onChanged: null）'
                          : 'onChanged: ${range.start} ~ ${range.end}';
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    ),
    // ── ParkDateRangePicker: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description: '通过 bindKey + bindingService 实现双向绑定，日期范围变更实时同步到 model。'
          ' / ParkBindingService bindKey demo: date range syncs to model in real time.',
      code: '''
final service = ParkBindingService({
  'dateRange': ParkDateRange(
    start: DateTime(2026, 7, 1),
    end: DateTime(2026, 7, 15),
  ),
});

ParkDateRangePicker(
  label: '统计区间',
  bindKey: 'dateRange',
  bindingService: service,
)''',
      builder: (BuildContext context) => _DateRangePickerBindingDemo(),
    ),
    // ── ParkDateRangePicker: ParkDynamicForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkDynamicForm）',
      description: '在 ParkDynamicForm 中以 schema 配置 date 字段类型用作日期范围。'
          ' / ParkDynamicForm fieldType=date demo (range mode).',
      code: '''
ParkDynamicForm(
  schema: ParkFormSchema(
    formKey: 'drp_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_range',
        fieldType: ParkFieldType.date,
        labelName: '统计区间',
        fieldName: 'range',
        ext: {'mode': 'range'},
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkDynamicForm(
          schema: ParkFormSchema(
            formKey: 'drp_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_range',
                fieldType: ParkFieldType.date,
                labelName: '统计区间',
                fieldName: 'range',
                ext: <String, dynamic>{'mode': 'range'},
              ),
            ],
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`date`（日期选择），通过 `ext['mode'] = 'range'` 切换为日期范围模式。

### 适用场景
- 报表、订单列表、数据统计等需要日期范围查询的场景 / Reports, order lists, data statistics requiring date range queries.
- 需要提供"近7天"、"近30天"等快捷预设的场景 / Scenarios needing shortcut presets like "last 7 days", "last 30 days".

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `date` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认值（ISO 日期字符串） | 否 |
| `ext.mode` | `ext.mode` | 设为 `'range'` 启用范围模式 | 否 |
| `ext.firstDate` | `ext.firstDate` | 可选最早日期（ISO 字符串） | 否 |
| `ext.lastDate` | `ext.lastDate` | 可选最晚日期（ISO 字符串） | 否 |
| `ext.showShortcuts` | `ext.showShortcuts` | 是否显示快捷预设条 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_range',
  fieldType: ParkFieldType.date,
  labelName: '统计区间',
  fieldName: 'range',
  ext: <String, dynamic>{'mode': 'range'},
)
```

### 进阶技巧
- 快捷预设：`ext['shortcuts']` 可传入自定义快捷列表（如"本季度"、"本年度"）。
- 日期范围校验：用 `minLength` / `maxLength` 或自定义 `validatorMessage` 限制跨度。
- 联动：通过 `visibleRule` / `disabledRule` 依赖其它字段控制显隐。
- 提交值格式：默认提交为 `{"start": "ISO", "end": "ISO"}` 对象，可在 `ext['valueFormat']` 中自定义。
- 与 `\u{24}form.xxx` 联动：如 `\u{24}form.range.start` 可被其它字段 reaction 引用。''',
);

// ============================================================================
// ParkDateRangePicker: ParkBinding 示例
// ============================================================================

class _DateRangePickerBindingDemo extends StatefulWidget {
  @override
  State<_DateRangePickerBindingDemo> createState() =>
      _DateRangePickerBindingDemoState();
}

class _DateRangePickerBindingDemoState
    extends State<_DateRangePickerBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'dateRange': ParkDateRange(
        start: DateTime(2026, 7, 1),
        end: DateTime(2026, 7, 15),
      ),
    });
    _service.watchEffect(() {
      _service.getValue<ParkDateRange>('dateRange');
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'null';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ParkDateRange? range =
        _service.getValue<ParkDateRange>('dateRange');
    final String display = range == null
        ? 'null'
        : '${_formatDate(range.start)} ~ ${_formatDate(range.end)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkDateRangePicker(
          label: '统计区间',
          bindKey: 'dateRange',
          bindingService: _service,
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
                  'model: $display',
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

// ---------------------------------------------------------------------------
// ParkCheckboxGroup
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkCheckboxGroupSpec = ParkComponentSpec(
  name: 'ParkCheckboxGroup',
  title: '复选框组',
  category: 'input',
  description:
      '在一组选项中多选若干个的复选框组组件。支持垂直/水平布局、全选、'
      '禁用态与富模型选项（ParkCheckboxOption）。'
      ' / Checkbox group for multi-select from a set of options; supports vertical/horizontal layout, select-all, disabled state and rich ParkCheckboxOption model.',
  icon: Icons.check_box_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'options',
      type: 'List<ParkCheckboxOption>',
      defaultVal: 'const []',
      description: '选项列表 / Option list',
      required: true,
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'List<String>',
      defaultVal: 'const []',
      description: '已选中的值列表 / Selected values',
      required: false,
    ),
    ParkPropertyDef(
      name: 'layout',
      type: 'ParkCheckboxGroupLayout',
      defaultVal: 'vertical',
      description: '布局方式（vertical / horizontal / wrap）/ Layout direction',
      required: false,
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用整个组 / Disable entire group',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectAll',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在顶部显示全选复选框 / Show select-all checkbox',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'void Function(List<String> values, List<ParkCheckboxOption> selectedOptions)?',
      description: '选中值变化回调 / Fired when selection changes',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''ParkCheckboxGroup(
  options: [
    ParkCheckboxOption(value: 'a', label: '选项A'),
    ParkCheckboxOption(value: 'b', label: '选项B'),
    ParkCheckboxOption(value: 'c', label: '选项C'),
  ],
  value: ['a'],
  onChanged: (values, _) => print(values),
)''',
  guide: '''
## 何时使用
- 一组选项中需要多选 / Multi-select from a set of options
- 需要全选功能 / Need select-all functionality

## 使用建议
- options 使用 ParkCheckboxOption 富模型，支持 disabled 单项禁用
- layout 控制垂直/水平排列
- selectAll 开启后顶部显示全选复选框

## 搭配推荐
- 搭配 ParkForm / ParkDynamicForm 使用
- 搭配 ParkFormItem 包裹获得表单标签与校验
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础多选',
      description: '垂直布局的复选框组 / Vertical checkbox group',
      code: '''
ParkCheckboxGroup(
  options: [
    ParkCheckboxOption(value: 'a', label: '选项A'),
    ParkCheckboxOption(value: 'b', label: '选项B'),
    ParkCheckboxOption(value: 'c', label: '选项C'),
  ],
  value: ['a'],
  onChanged: (values, _) => print(values),
)''',
      builder: (BuildContext context) => _ParkCheckboxGroupDemo1(),
    ),
    ParkDemoScenario(
      title: '水平布局 + 全选',
      description: '水平排列并开启全选 / Horizontal with select-all',
      code: '''
ParkCheckboxGroup(
  options: [
    ParkCheckboxOption(value: 'x', label: '选项X'),
    ParkCheckboxOption(value: 'y', label: '选项Y'),
    ParkCheckboxOption(value: 'z', label: '选项Z'),
  ],
  layout: ParkCheckboxGroupLayout.horizontal,
  selectAll: true,
)''',
      builder: (BuildContext context) => _ParkCheckboxGroupDemo2(),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`checkbox`（多选组）。

### 适用场景
- 表单中从一组选项中多选若干个 / Multi-select from a set of options in forms.
- 如兴趣标签、权限选项、附加服务等场景。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `checkbox` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `options` | `options` | 选项列表（`{label, value}` 数组） | 是 |
| `defaultValue` | `default_value` | 默认已选值数组 | 否 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `ext.layout` | `ext.layout` | 布局方式 `'vertical'` / `'horizontal'` | 否 |
| `ext.selectAll` | `ext.selectAll` | 是否显示全选（bool） | 否 |
| `dataSourceType` | `data_source_type` | 选项数据来源类型 | 否 |
| `dataSourceKey` | `data_source_key` | 远程数据源键名 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_tags',
  fieldType: ParkFieldType.checkbox,
  labelName: '兴趣标签',
  fieldName: 'tags',
  options: <Map<String, dynamic>>[
    {'label': '科技', 'value': 'tech'},
    {'label': '体育', 'value': 'sports'},
    {'label': '音乐', 'value': 'music'},
  ],
)
```

### 进阶技巧
- 远程数据源：`dataSourceType: ParkDataSourceType.api` + `dataSourceKey: 'tagList'` 动态加载选项。
- 全选：`ext['selectAll'] = true` 开启全选复选框。
- 校验：`isRequired: true` 确保至少选择一项。
- 联动：`\u{24}form.tags` 可被其它字段 reaction 引用。''',
);

class _ParkCheckboxGroupDemo1 extends StatefulWidget {
  @override
  State<_ParkCheckboxGroupDemo1> createState() => _ParkCheckboxGroupDemo1State();
}

class _ParkCheckboxGroupDemo1State extends State<_ParkCheckboxGroupDemo1> {
  List<String> _values = <String>['a'];

  @override
  Widget build(BuildContext context) {
    return ParkCheckboxGroup(
      options: const <ParkCheckboxOption>[
        ParkCheckboxOption(value: 'a', label: '选项A'),
        ParkCheckboxOption(value: 'b', label: '选项B'),
        ParkCheckboxOption(value: 'c', label: '选项C'),
      ],
      value: _values,
      onChanged: (List<String> vals, _) => setState(() => _values = vals),
    );
  }
}

class _ParkCheckboxGroupDemo2 extends StatefulWidget {
  @override
  State<_ParkCheckboxGroupDemo2> createState() => _ParkCheckboxGroupDemo2State();
}

class _ParkCheckboxGroupDemo2State extends State<_ParkCheckboxGroupDemo2> {
  List<String> _values = <String>[];

  @override
  Widget build(BuildContext context) {
    return ParkCheckboxGroup(
      options: const <ParkCheckboxOption>[
        ParkCheckboxOption(value: 'x', label: '选项X'),
        ParkCheckboxOption(value: 'y', label: '选项Y'),
        ParkCheckboxOption(value: 'z', label: '选项Z'),
      ],
      value: _values,
      layout: ParkCheckboxGroupLayout.horizontal,
      selectAll: true,
      onChanged: (List<String> vals, _) => setState(() => _values = vals),
    );
  }
}
