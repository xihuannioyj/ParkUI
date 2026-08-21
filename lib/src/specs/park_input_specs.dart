// Park 输入组件规格 — Batch 2（完善版）
//
// 覆盖：ParkInput / ParkTextarea / ParkSearch / ParkSwitch / ParkCheckbox
//       ParkRadio / ParkSelect / ParkDatePicker
//
// 约定：
//  - 每个组件的 properties 枚举其全部公开构造参数；
//  - 每个功能 / 形态 / 状态 / 变体均对应一个 demo（code 与 builder 完全一致）；
//  - 禁止裸字面量：颜色用 ParkColors.*，间距用 ParkSpacing.* / 具名常量，
//    粗细用具名常量，字号用 ParkTypography.*，杜绝魔法变量。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
// Demo 使用内存缓存，避免引入 shared_preferences 依赖。
import 'park_component_spec.dart';

// ===========================================================================
// 命名令牌常量（对齐 ParkColors / ParkSpacing / ParkTypography 设计令牌，
// 杜绝裸字面量 / 魔法变量）
// ===========================================================================
final ParkColors _kColors = ParkColors.light();
final ParkSpacing _kSpacing = ParkSpacing.defaults();

/// 输入框令牌展示辅助数据类。
class _InputTokenItem {
  final String name;
  final double value;
  final String description;
  const _InputTokenItem(this.name, this.value, this.description);
}

/// 输入框令牌展示卡片构建器。
///
/// 修复：长令牌名（等宽字体）在窄屏下使 Row 溢出——名称改 Flexible 弹性收缩；
/// 颜色统一改用 Park 主题令牌（原硬编码 white/grey/blue，暗色主题不可读）。
Widget _buildInputTokenCard({
  required String title,
  required List<_InputTokenItem> items,
}) {
  return Builder(builder: (BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: park.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText(title, preset: ParkTextPreset.h3),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: park.colors.brand.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: park.colors.brand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${item.value.toInt()}px',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: park.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    });
}

/// 输入组件规格字典（8 个组件）。
Map<String, ParkComponentSpec> get parkInputSpecs =>
    <String, ParkComponentSpec>{
      'ParkInput': _parkInputSpec,
      'ParkTextarea': _parkTextareaSpec,
      'ParkSearch': _parkSearchSpec,
      'ParkSwitch': _parkSwitchSpec,
      'ParkCheckbox': _parkCheckboxSpec,
      'ParkRadio': _parkRadioSpec,
      'ParkSelect': _parkSelectSpec,
      'ParkDatePicker': _parkDatePickerSpec,
    };

// ---------------------------------------------------------------------------
// ParkInput
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkInputSpec = ParkComponentSpec(
  name: 'ParkInput',
  title: '输入框',
  category: 'input',
  description:
      '基于 FormField<String> 封装的文本输入框，支持表单校验、焦点管理、密码切换、'
      '字数统计、清除按钮、前后缀图标/组件、外置附件、搜索按钮等功能。',
  icon: Icons.input_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'controller',
      type: 'TextEditingController?',
      defaultVal: 'null',
      description:
          '文本控制器，外部控制输入内容 / Text controller for external value control',
    ),
    ParkPropertyDef(
      name: 'initialValue',
      type: 'String?',
      defaultVal: 'null',
      description:
          '初始值，与 controller 二选一 / Initial value (pick one of controller / initialValue)',
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String?',
      defaultVal: 'null',
      description: '占位提示文字 / Placeholder hint text',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '输入框上方标签文字 / Label shown above the field',
    ),
    ParkPropertyDef(
      name: 'prefixIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '前置图标 Widget / Leading icon widget',
    ),
    ParkPropertyDef(
      name: 'suffixIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '后置图标 Widget / Trailing icon widget',
    ),
    ParkPropertyDef(
      name: 'prefix',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '前置 Widget（优先级低于 prefixIcon，可放任意 Widget，如文字前缀） /'
          ' Leading widget (lower priority than prefixIcon; e.g. text prefix)',
    ),
    ParkPropertyDef(
      name: 'suffix',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '后置组件（优先级低于 suffixIcon，可放任意 Widget，如单位文字） /'
          ' Trailing widget (lower priority than suffixIcon; e.g. unit text)',
    ),
    ParkPropertyDef(
      name: 'addonBefore',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '外部前置附件（在边框之外左侧，如标签 / 按钮） /'
          ' Outer leading addon (outside the border, e.g. label / button)',
    ),
    ParkPropertyDef(
      name: 'addonAfter',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '外部后置附件（在边框之外右侧） / Outer trailing addon (right of the border)',
    ),
    ParkPropertyDef(
      name: 'showCount',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否显示字数统计（需配合 maxLength 生效） / Show character count (with maxLength)',
    ),
    ParkPropertyDef(
      name: 'status',
      type: 'ParkInputStatus?',
      defaultVal: 'null',
      description:
          '手动指定状态样式（error / warning / success），覆盖校验结果 /'
          ' Manual status style overriding validation result',
    ),
    ParkPropertyDef(
      name: 'searchButton',
      type: 'bool? / ParkInputSearchButtonConfig?',
      defaultVal: 'null',
      description:
          '搜索按钮：传 true 渲染默认「搜索」按钮；传 ParkInputSearchButtonConfig 可自定义文案 / 图标 / loading / 变体 /'
          ' Search button: true for default; config for text / icon / loading / variant',
    ),
    ParkPropertyDef(
      name: 'clearable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示清除按钮 / Show clear (clear-all) button',
    ),
    ParkPropertyDef(
      name: 'obscureText',
      type: 'bool',
      defaultVal: 'false',
      description: '是否密码模式（自动附带显隐切换按钮） / Password mode with show/hide toggle',
    ),
    ParkPropertyDef(
      name: 'maxLength',
      type: 'int?',
      defaultVal: 'null',
      description: '最大字符数，设置后显示字数统计 / Max characters (enables counter)',
    ),
    ParkPropertyDef(
      name: 'maxLines',
      type: 'int',
      defaultVal: '1',
      description: '最大行数 / Max visible lines',
    ),
    ParkPropertyDef(
      name: 'keyboardType',
      type: 'TextInputType?',
      defaultVal: 'null',
      description: '键盘类型 / Keyboard type',
    ),
    ParkPropertyDef(
      name: 'textInputAction',
      type: 'TextInputAction?',
      defaultVal: 'null',
      description: '键盘操作按钮类型 / Keyboard action button',
    ),
    ParkPropertyDef(
      name: 'focusNode',
      type: 'FocusNode?',
      defaultVal: 'null',
      description: '焦点节点 / Focus node',
    ),
    ParkPropertyDef(
      name: 'enabled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用 / Whether the field is enabled',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读 / Read-only (no editing)',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkInputSize',
      defaultVal: 'ParkInputSize.medium',
      description:
          '输入框尺寸：small (32px) / medium (48px) / large (56px)，控制高度、字号和内边距 /'
          ' Size: small/medium/large controls height, font & padding',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description:
          '是否显示边框（false 时移除边框和背景，仅聚焦时显示底部线条） /'
          ' Bordered; false removes border/bg, shows bottom line on focus',
    ),
    ParkPropertyDef(
      name: 'inputFormatters',
      type: 'List<TextInputFormatter>?',
      defaultVal: 'null',
      description:
          '输入格式化器列表，透传给底层 TextField / Input formatters passed to TextField',
    ),
    ParkPropertyDef(
      name: 'autofocus',
      type: 'bool',
      defaultVal: 'false',
      description: '是否自动获取焦点 / Auto-focus on mount',
    ),
    ParkPropertyDef(
      name: 'textAlign',
      type: 'TextAlign',
      defaultVal: 'TextAlign.start',
      description: '文本对齐方式 / Text alignment',
    ),
    ParkPropertyDef(
      name: 'labelWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '自定义标签 Widget，优先级高于 label 字符串 / Custom label widget (overrides label)',
    ),
    ParkPropertyDef(
      name: 'helperText',
      type: 'String?',
      defaultVal: 'null',
      description: '辅助文字，显示在输入框下方（与错误文字互斥） / Helper text below the field',
    ),
    ParkPropertyDef(
      name: 'required',
      type: 'bool',
      defaultVal: 'false',
      description: '是否为必填项（为 true 时在标签前显示红色星号） / Required; shows red asterisk',
    ),
    ParkPropertyDef(
      name: 'prefixText',
      type: 'String?',
      defaultVal: 'null',
      description: '前置文本（显示在输入框内部最前方，灰色小字） / Inline leading text (grey)',
    ),
    ParkPropertyDef(
      name: 'suffixText',
      type: 'String?',
      defaultVal: 'null',
      description: '后置文本（显示在输入框内部最后方，灰色小字） / Inline trailing text (grey)',
    ),
    ParkPropertyDef(
      name: 'borderless',
      type: 'bool',
      defaultVal: 'false',
      description:
          '无边框变体（完全去除边框和背景，比 bordered: false 更彻底） / Fully borderless variant',
    ),
    ParkPropertyDef(
      name: 'readonly',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否只读（readOnly 的别名，兼容 AntD 命名） / Alias of readOnly (AntD-compatible)',
    ),
    ParkPropertyDef(
      name: 'contentPadding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null',
      description: '输入框内容区内边距（透传给底层 TextField） / Content padding inside the input (passed to TextField)',
    ),
    ParkPropertyDef(
      name: 'style',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '输入文本样式（透传给底层 TextField） / Text style (passed to TextField)',
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
          ' Binding key (dot path, e.g. "user.name"); enables two-way binding via ParkBindingService.',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。 /'
          ' Binding service instance; auto-resolved from ParkBindingFormScope when inside a form.',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<String>?',
      description: '输入内容变化回调 / Called when the input value changes',
    ),
    ParkEventDef(
      name: 'onSubmitted',
      signature: 'ValueChanged<String>?',
      description: '提交回调（按下键盘确认键时触发） / Called on keyboard submit action',
    ),
    ParkEventDef(
      name: 'onSearch',
      signature: 'ValueChanged<String>?',
      description:
          '搜索回调（按下搜索键、回车或点击搜索按钮时触发，与 searchButton 配合使用） /'
          ' Search callback (with searchButton)',
    ),
    ParkEventDef(
      name: 'onFocus',
      signature: 'VoidCallback?',
      description: '输入框获取焦点时的回调 / Called when the field gains focus',
    ),
    ParkEventDef(
      name: 'onBlur',
      signature: 'VoidCallback?',
      description: '输入框失去焦点时的回调 / Called when the field loses focus',
    ),
    ParkEventDef(
      name: 'onEditingComplete',
      signature: 'VoidCallback?',
      description: '编辑完成时的回调（按下键盘完成按钮） / Called when editing completes',
    ),
    ParkEventDef(
      name: 'onTap',
      signature: 'VoidCallback?',
      description: '点击输入框时的回调 / Called when the field is tapped',
    ),
    ParkEventDef(
      name: 'onTapOutside',
      signature: 'VoidCallback?',
      description: '点击输入框外部时的回调 / Called when tapping outside the field',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<String>?',
      description: '表单校验器 / Form field validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<String>?',
      description: '表单保存回调 / Form field save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkInput(
  label: '用户名',
  hintText: '请输入用户名',
  clearable: true,
  suffixIcon: Icon(Icons.person),
  onChanged: (v) => print(v),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要用户输入短文本时（用户名、手机号、搜索词等） / Short text input (username, phone, keyword)
- 表单场景中的单行文本输入 / Single-line text in forms

## 使用建议 / Usage tips
- 始终使用 label 标注输入框用途 / Always label the field
- 密码输入设置 obscureText: true，自动附带显隐切换 / Password: obscureText adds show/hide toggle
- 设置 clearable: true 方便用户清除内容 / clearable shows a clear button
- 通过 validator 添加表单校验规则 / Add validation via validator
- 手机号、数字等场景设置 keyboardType 调出合适键盘 / Set keyboardType for phone/number

## 后缀与组合 / Affixes & composition
- suffixIcon / suffix 用于在输入框右侧展示图标或自定义组件（如单位「元」） / suffix for icon or widget (e.g. unit)
- addonBefore / addonAfter 在边框「之外」放置标签或按钮，适合前后缀固定文案 / addons sit outside the border
- 多控件紧凑成体请使用 ParkInputGroup（输入框 + 选择器 + 按钮一行成体） / Use ParkInputGroup for compact composites

## 搜索模式 / Search mode
- 传入 searchButton: true 即可在右侧渲染标准搜索按钮 / searchButton: true renders a search button
- 点击按钮或回车均触发 onSearch，loading 态显示 spinner 并禁点 / Click/Enter triggers onSearch; loading disables tap
- 需要自定义文案 / 图标 / 变体 / loading 时传入 ParkInputSearchButtonConfig / Customize via ParkInputSearchButtonConfig
- searchButton 与 suffixIcon / clearable / obscureText 可共存，互不冲突 / searchButton coexists with other props

## 状态样式 / Status styles
- 通过 status: ParkInputStatus.error / warning / success 手动指定边框与聚焦环颜色 / status overrides border & focus ring color
- status 优先级高于 validator 校验结果，适合服务端返回校验态的场景 / status beats validator (server-driven states)

## 搭配推荐 / Compose with
- 搭配 ParkForm 做表单提交与校验 / Pair with ParkForm
- 搭配 ParkButton 做提交操作 / Pair with ParkButton
- 搭配 ParkTextarea 处理多行文本输入 / Pair with ParkTextarea
- 搭配 ParkInputGroup 做紧凑组合输入 / Pair with ParkInputGroup

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Input：value / placeholder / prefix / suffix / addonBefore / addonAfter / allowClear / size / status / bordered / maxLength + showCount；密码用 `Password` 组件；搜索用 `Input.Search`。
- TDesign Flutter Input：基础 `TextFiled` 风格，支持 prefix / suffix / clearable / label / borderless，但无原生 `addonBefore/After` 与 `searchButton` 概念。
- park Input 覆盖二者全部能力，并额外提供：`searchButton`（含 `ParkInputSearchButtonConfig` 自定义文案/图标/loading）、`prefixText/suffixText` 内嵌文字、`borderless` 无边框变体、`bindKey` 双向绑定、前后置附件与 `ParkInputGroup` 组合。
### 示例 / Examples
- 对标 Ant `<Input allowClear />` → park `ParkInput(clearable: true)`；对标 Ant `<Input.Search />` → park `ParkInput(searchButton: true)`。
- 对标 Ant `addonBefore={<span>https://</span>}` → park `ParkInput(addonBefore: Text('https://'))`。
- 对标 TDesign `clearable` → park `clearable: true`；对标 `borderless` → park `borderless: true`。
### 属性 / Props
- 差异点：park 的 `searchButton` 与 `addonBefore/After` 在 Ant/TDesign 中需自行包裹或拆分组件；park `bindKey` 是表单绑定独有；park `size` 用 small/medium/large 语义枚举（Ant 用 default/large，TDesign 用 small/medium/large）。

## 设计令牌参考 / Design Token Reference
- 高度：small=32px / medium=48px / large=56px；字号：small=14px / medium=16px / large=18px
- 圆角：radius.sm (8px)；边框色解析链：status > 错误 > 聚焦(brand) > 悬浮 > 默认
- 详见 DESIGN_SYSTEM.md

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`（或 pubspec.yaml 添加 `park_ui: ^0.1.0`）
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致；正式版本号待维护者确认 / see pubspec）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础输入框',
      description: '带标签和占位提示的基础文本输入',
      code: '''
ParkInput(
  label: '用户名',
  hintText: '请输入用户名',
)
''',
      builder: (BuildContext context) =>
          ParkInput(label: '用户名', hintText: '请输入用户名'),
    ),
    ParkDemoScenario(
      title: '可清除与前置图标',
      description: '使用 clearable 显示清除按钮，prefixIcon 添加前置图标',
      code: '''
ParkInput(
  hintText: '请输入手机号',
  clearable: true,
  prefixIcon: Icon(Icons.phone),
  keyboardType: TextInputType.phone,
)
''',
      builder: (BuildContext context) => ParkInput(
        hintText: '请输入手机号',
        clearable: true,
        prefixIcon: const Icon(Icons.phone),
        keyboardType: TextInputType.phone,
      ),
    ),
    ParkDemoScenario(
      title: '可交互：清除与搜索图标',
      description:
          '通过 StatefulBuilder 演示 clearable + prefixIcon 真实交互：'
          '输入文本后显示清除按钮，点击清除按钮清空内容。'
          ' / StatefulBuilder demonstrates clearable + prefixIcon: '
          'clear button appears on input; tapping clears the field.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    var controller = TextEditingController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkInput(
          hintText: '搜索...',
          prefixIcon: Icon(Icons.search),
          clearable: true,
          controller: controller,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('当前内容：' + controller.text, preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkInput(
                  hintText: '搜索...',
                  prefixIcon: const Icon(Icons.search),
                  clearable: true,
                  controller: controller,
                  onChanged: (String _) => setState(() {}),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText(
                  '当前内容：${controller.text}',
                  preset: ParkTextPreset.bodySmall,
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '密码输入',
      description: '设置 obscureText: true 启用密码模式，自动附带显隐切换',
      code: '''
ParkInput(
  label: '密码',
  hintText: '请输入密码',
  obscureText: true,
)
''',
      builder: (BuildContext context) =>
          ParkInput(label: '密码', hintText: '请输入密码', obscureText: true),
    ),
    ParkDemoScenario(
      title: '密码框组合：clearable + 前缀图标 + 显隐切换',
      description:
          '演示 clearable、prefixIcon（锁图标）、obscureText 与右侧眼睛图标的组合使用，'
          '通过 StatefulBuilder 实现密码显隐切换。'
          ' / Combines clearable, prefixIcon (lock), obscureText and visibility toggle via StatefulBuilder.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    bool isObscured = true;
    return ParkInput(
      hintText: '请输入密码',
      prefixIcon: Icon(Icons.lock),
      obscureText: isObscured,
      suffixIcon: IconButton(
        icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => isObscured = !isObscured),
      ),
      clearable: true,
    );
  },
)''',
      builder: (BuildContext context) {
        bool isObscured = true;
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return ParkInput(
              hintText: '请输入密码',
              prefixIcon: const Icon(Icons.lock),
              obscureText: isObscured,
              suffixIcon: IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => isObscured = !isObscured),
              ),
              clearable: true,
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '字数限制',
      description: '使用 maxLength 限制输入字符数并显示字数统计',
      code: '''
ParkInput(
  label: '昵称',
  hintText: '请输入昵称',
  maxLength: 20,
  clearable: true,
)
''',
      builder: (BuildContext context) => ParkInput(
        label: '昵称',
        hintText: '请输入昵称',
        maxLength: 20,
        clearable: true,
      ),
    ),
    ParkDemoScenario(
      title: '禁用与只读',
      description: '通过 enabled: false 或 readOnly: true 限制交互',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkInput(
      initialValue: '已禁用的输入框',
      enabled: false,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkInput(
      initialValue: '只读内容',
      readOnly: true,
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkInput(initialValue: '已禁用的输入框', enabled: false),
          SizedBox(height: _kSpacing.sm),
          ParkInput(initialValue: '只读内容', readOnly: true),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '后置图标与后置组件',
      description: 'suffixIcon 显示后置图标，suffix 可放置任意组件（如单位文字）',
      code: '''
ParkInput(
  hintText: '请输入金额',
  suffixIcon: Icon(Icons.attach_money),
  suffix: Text('元'),
)
''',
      builder: (BuildContext context) => ParkInput(
        hintText: '请输入金额',
        suffixIcon: const Icon(Icons.attach_money),
        suffix: const Text('元'),
      ),
    ),
    ParkDemoScenario(
      title: '搜索按钮',
      description: 'searchButton: true 在右侧渲染搜索按钮，点击或回车触发 onSearch',
      code: '''
ParkInput(
  hintText: '搜索关键词',
  searchButton: true,
  onSearch: (v) => print('search: \$v'),
)
''',
      builder: (BuildContext context) => ParkInput(
        hintText: '搜索关键词',
        searchButton: true,
        onSearch: (String v) {},
      ),
    ),
    ParkDemoScenario(
      title: '状态样式',
      description: '通过 status 手动指定 error / warning / success 边框样式',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkInput(hintText: '错误状态', status: ParkInputStatus.error),
    SizedBox(height: _kSpacing.sm),
    ParkInput(hintText: '警告状态', status: ParkInputStatus.warning),
    SizedBox(height: _kSpacing.sm),
    ParkInput(hintText: '成功状态', status: ParkInputStatus.success),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(hintText: '错误状态', status: ParkInputStatus.error),
          SizedBox(height: _kSpacing.sm),
          ParkInput(hintText: '警告状态', status: ParkInputStatus.warning),
          SizedBox(height: _kSpacing.sm),
          ParkInput(hintText: '成功状态', status: ParkInputStatus.success),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '字数统计',
      description: 'maxLength 配合 showCount 实时显示「已输入 / 上限」',
      code: '''
ParkInput(
  hintText: '最多 20 字',
  maxLength: 20,
  showCount: true,
)
''',
      builder: (BuildContext context) =>
          ParkInput(hintText: '最多 20 字', maxLength: 20, showCount: true),
    ),
    ParkDemoScenario(
      title: '前后置附件',
      description: 'addonBefore / addonAfter 在边框之外放置标签或按钮',
      code: '''
ParkInput(
  hintText: '网址',
  addonBefore: Text('https://'),
  addonAfter: ParkButton(height: 48, child: Text('Go')),
)
''',
      builder: (BuildContext context) => ParkInput(
        hintText: '网址',
        addonBefore: const Text('https://'),
        addonAfter: const ParkButton(height: 48, child: Text('Go')),
      ),
    ),
    ParkDemoScenario(
      title: '输入框尺寸',
      description: '通过 size 切换 small / medium / large 三种高度',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkInput(hintText: '小尺寸', size: ParkInputSize.small),
    SizedBox(height: _kSpacing.sm),
    ParkInput(hintText: '中尺寸', size: ParkInputSize.medium),
    SizedBox(height: _kSpacing.sm),
    ParkInput(hintText: '大尺寸', size: ParkInputSize.large),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(hintText: '小尺寸', size: ParkInputSize.small),
          SizedBox(height: _kSpacing.sm),
          ParkInput(hintText: '中尺寸', size: ParkInputSize.medium),
          SizedBox(height: _kSpacing.sm),
          ParkInput(hintText: '大尺寸', size: ParkInputSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '前置文本与前置组件',
      description: 'prefixText 显示灰色前置文字；prefix 放置前置 Widget',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkInput(
      hintText: '手机号',
      prefixText: '+86 ',
    ),
    SizedBox(height: _kSpacing.sm),
    ParkInput(
      hintText: '搜索',
      prefix: Icon(Icons.search, color: _kColors.textSecondary),
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(hintText: '手机号', prefixText: '+86 '),
          SizedBox(height: _kSpacing.sm),
          ParkInput(
            hintText: '搜索',
            prefix: Icon(Icons.search, color: _kColors.textSecondary),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '必填标识与辅助文字',
      description: 'required 显示红色星号；helperText 显示辅助说明',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkInput(
      label: '姓名',
      hintText: '请输入姓名',
      required: true,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkInput(
      label: '邮箱',
      hintText: '请输入邮箱',
      helperText: '用于接收通知邮件',
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(label: '姓名', hintText: '请输入姓名', required: true),
          SizedBox(height: _kSpacing.sm),
          ParkInput(label: '邮箱', hintText: '请输入邮箱', helperText: '用于接收通知邮件'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义搜索按钮配置',
      description: '通过 ParkInputSearchButtonConfig 自定义搜索按钮文案与变体',
      code: '''
ParkInput(
  hintText: '搜索用户',
  searchButton: ParkInputSearchButtonConfig(
    text: '查找',
    variant: ParkButtonVariant.danger,
  ),
  onSearch: (v) => print('search: \$v'),
)
''',
      builder: (BuildContext context) => ParkInput(
        hintText: '搜索用户',
        searchButton: const ParkInputSearchButtonConfig(
          text: '查找',
          variant: ParkButtonVariant.danger,
        ),
        onSearch: (String v) {},
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显输入',
      description:
          '通过 StatefulBuilder + onChanged 实时回显输入内容，演示 ParkInput 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the typed text live, demonstrating ParkInput.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String text = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkInput(
          hintText: '输入点什么',
          onChanged: (v) => setState(() => text = v),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('已输入：\$text', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String text = '';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkInput(
                  hintText: '输入点什么',
                  onChanged: (String v) => setState(() => text = v),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('已输入：$text', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '📐 尺寸令牌参考 / Sizing Token Reference',
      description:
          'ParkInput 的三档高度由 ParkSizing 令牌系统统一驱动 / Input sizes driven by ParkSizing tokens.',
      code: '''
Builder(
  builder: (context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final sizing = park.sizing;
    final spacing = park.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkText('输入框尺寸令牌 / Input Sizing Tokens', preset: ParkTextPreset.h3),
        SizedBox(height: spacing.sm),
        ParkText('以下值来自 ParkSizing 令牌系统，修改后全局生效。', preset: ParkTextPreset.bodySmall),
        SizedBox(height: spacing.md),
        _buildInputTokenCard(
          title: '输入框高度 / Input Height',
          items: [
            _InputTokenItem('inputHeightSm', sizing.inputHeightSm, 'small (32px)'),
            _InputTokenItem('inputHeightMd', sizing.inputHeightMd, 'medium (48px)'),
            _InputTokenItem('inputHeightLg', sizing.inputHeightLg, 'large (56px)'),
          ],
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ??
            ParkThemeData.light();
        final sizing = park.sizing;
        final spacing = park.spacing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkText(
              '输入框尺寸令牌 / Input Sizing Tokens',
              preset: ParkTextPreset.h3,
            ),
            SizedBox(height: spacing.sm),
            ParkText(
              '以下值来自 ParkSizing 令牌系统，修改后全局生效。',
              preset: ParkTextPreset.bodySmall,
            ),
            SizedBox(height: spacing.md),
            _buildInputTokenCard(
              title: '输入框高度 / Input Height',
              items: [
                _InputTokenItem(
                  'inputHeightSm',
                  sizing.inputHeightSm,
                  'small (32px)',
                ),
                _InputTokenItem(
                  'inputHeightMd',
                  sizing.inputHeightMd,
                  'medium (48px)',
                ),
                _InputTokenItem(
                  'inputHeightLg',
                  sizing.inputHeightLg,
                  'large (56px)',
                ),
              ],
            ),
          ],
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：完整事件演示',
      description:
          '通过 StatefulBuilder 实时回显 ParkInput 的 onFocus / onBlur / onSubmitted /'
          ' onEditingComplete / onTap / onTapOutside 六个回调。'
          ' / StatefulBuilder echoes all six callbacks: onFocus, onBlur, onSubmitted,'
          ' onEditingComplete, onTap, onTapOutside.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String log = '等待交互...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkInput(
          hintText: '点击 / 输入 / 回车 / 点外部',
          onFocus: () => setState(() => log = 'onFocus'),
          onBlur: () => setState(() => log = 'onBlur'),
          onTap: () => setState(() => log = 'onTap'),
          onTapOutside: () => setState(() => log = 'onTapOutside'),
          onEditingComplete: () => setState(() => log = 'onEditingComplete'),
          onSubmitted: (v) => setState(() => log = 'onSubmitted: \$v'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String log = '等待交互...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkInput(
                  hintText: '点击 / 输入 / 回车 / 点外部',
                  onFocus: () => setState(() => log = 'onFocus'),
                  onBlur: () => setState(() => log = 'onBlur'),
                  onTap: () => setState(() => log = 'onTap'),
                  onTapOutside: () => setState(() => log = 'onTapOutside'),
                  onEditingComplete: () =>
                      setState(() => log = 'onEditingComplete'),
                  onSubmitted: (String v) =>
                      setState(() => log = 'onSubmitted: \$v'),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：实时回显输入',
      description:
          '通过 StatefulBuilder 实时回显 ParkInput 的 onChanged 回调。'
          ' / StatefulBuilder echoes onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String log = '等待输入...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkInput(
          hintText: '输入内容试试',
          onChanged: (v) => setState(() => log = 'onChanged: ' + v),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String log = '等待输入...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkInput(
                  hintText: '输入内容试试',
                  onChanged: (String v) =>
                      setState(() => log = 'onChanged: ' + v),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkInput 的 validator / onSaved 回调，'
          '点击提交触发校验并保存输入值。'
          ' / Form + GlobalKey demonstrates ParkInput.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(
            label: '用户名',
            hintText: '请输入用户名',
            validator: (String? v) => (v == null || v.isEmpty) ? '用户名不能为空' : null,
            onSaved: (String? v) => _saved = v,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkInputFormDemo(),
    ),
    // ── ParkInput: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，输入内容实时同步到 model。'
          ' / ParkBindingService bindKey demo: input syncs to model in real time.',
      code: '''
final service = ParkBindingService({'name': '张三'});

ParkInput(
  label: '姓名',
  bindKey: 'name',
  bindingService: service,
  hintText: '输入后下方实时显示',
)''',
      builder: (BuildContext context) => _ParkInputBindingDemo(),
    ),
    // ── ParkInput: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用，展示表单自动渲染与提交。'
          ' / ParkForm schema usage demonstration.',
      code: '''
final schema = ParkFormSchema(formKey: 'park_input_username_demo', fields: [
  ParkFormFieldSchema(
    fieldId: 'f_username',
    fieldType: ParkFieldType.text,
    labelName: '用户名',
    fieldName: 'username',
    isRequired: true,
    fieldPrompt: '请输入用户名',
  ),
]);

Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkForm(schema: schema, onSubmit: (values) {}),
    SizedBox(height: 12),
    ParkButton(
      child: Text('提交'),
      onPressed: () {},
    ),
  ],
)''',
      builder: (BuildContext context) {
        final schema = ParkFormSchema(
          formKey: 'park_input_username_demo_inline',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_username',
              fieldType: ParkFieldType.text,
              labelName: '用户名',
              fieldName: 'username',
              isRequired: true,
              fieldPrompt: '请输入用户名',
            ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkForm(schema: schema, onSubmit: (values) {}),
            const SizedBox(height: 12),
            ParkButton(child: const Text('提交'), onPressed: () {}),
          ],
        );
      },
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`text`（单行文本）、`number`（数字输入）。同一组件对应两种 fieldType，UI 均为 ParkInput。

### 适用场景
- 表单中采集姓名、手机号、金额等短文本或数值字段。
- 数字场景启用步进按钮、范围限制与格式化。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `text` 或 `number` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `fieldPrompt` | `field_prompt` / `placeholder` | 占位提示 | 否 |
| `fieldLength` | `field_length` | 最大长度（字符数，0 不限制） | 否 |
| `minLength` / `maxLength` | `min_length` / `max_length` | 文本长度区间 | 否 |
| `defaultValue` | `default_value` | 默认值 | 否 |
| `uiConfig` | `ui_config` / `config` | 前缀/后缀/字数统计等 | 否 |
| `ext` | `ext` | 业务扩展（number 的 min/max/步进常经此承载） | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_username',
  fieldType: ParkFieldType.text,
  labelName: '用户名',
  fieldName: 'username',
  isRequired: true,
  fieldPrompt: '请输入用户名',
)
```

### 进阶技巧
- `number` 的数值范围与步进：当前 `ParkFormFieldSchema` 无独立 `min`/`max`/`step` 字段，一般经 `uiConfig` 或 `ext` 承载（如 `ext['min']`、`ext['step']`）。
- `fieldControl` 子类型：`input + password` → 密码框。
- `uiConfig.prefix` / `uiConfig.suffix` 显示前后缀文本；`showCount` 显示字数统计。
- 校验：用 `regexTag`（如 'mobile'）或 `regexExpression` 做格式校验，`validatorMessage` 自定义提示。
- 联动：`visibleRule` / `disabledRule` 控制显隐与禁用。''',
);

class _ParkInputFormDemo extends StatefulWidget {
  @override
  State<_ParkInputFormDemo> createState() => _ParkInputFormDemoState();
}

class _ParkInputFormDemoState extends State<_ParkInputFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkInput(
            label: '用户名',
            hintText: '请输入用户名',
            validator: (String? v) =>
                (v == null || v.isEmpty) ? '用户名不能为空' : null,
            onSaved: (String? v) => _saved = v,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ParkInput: ParkBinding 示例
// ============================================================================

class _ParkInputBindingDemo extends StatefulWidget {
  @override
  State<_ParkInputBindingDemo> createState() => _ParkInputBindingDemoState();
}

class _ParkInputBindingDemoState extends State<_ParkInputBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'name': '张三'});
    _service.watchEffect(() {
      _service.getValue<String>('name');
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
        ParkInput(
          label: '姓名',
          bindKey: 'name',
          bindingService: _service,
          hintText: '输入后下方实时显示',
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

// ---------------------------------------------------------------------------
// ParkTextarea
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTextareaSpec = ParkComponentSpec(
  name: 'ParkTextarea',
  title: '多行输入框',
  category: 'input',
  description:
      '基于 FormField<String> 封装的多行文本输入框，支持自动扩展高度、字数统计、'
      '清除按钮、状态样式等功能，适用于备注、评论等长文本输入场景。',
  icon: Icons.notes_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'controller',
      type: 'TextEditingController?',
      defaultVal: 'null',
      description: '文本控制器 / Text controller',
    ),
    ParkPropertyDef(
      name: 'initialValue',
      type: 'String?',
      defaultVal: 'null',
      description: '初始值 / Initial value',
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String?',
      defaultVal: 'null',
      description: '占位提示文字 / Placeholder hint text',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '输入框上方标签文字 / Label above the field',
    ),
    ParkPropertyDef(
      name: 'maxLength',
      type: 'int?',
      defaultVal: 'null',
      description: '最大字符数，设置后显示字数统计 / Max characters (enables counter)',
    ),
    ParkPropertyDef(
      name: 'minLines',
      type: 'int',
      defaultVal: '3',
      description: '最小行数 / Min lines',
    ),
    ParkPropertyDef(
      name: 'maxLines',
      type: 'int',
      defaultVal: '6',
      description: '最大行数 / Max lines',
    ),
    ParkPropertyDef(
      name: 'focusNode',
      type: 'FocusNode?',
      defaultVal: 'null',
      description: '焦点节点 / Focus node',
    ),
    ParkPropertyDef(
      name: 'enabled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用 / Whether enabled',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读 / Read-only',
    ),
    ParkPropertyDef(
      name: 'autoSize',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否自适应高度（为 true 时文本框随内容增长/收缩，不显示滚动条） /'
          ' Auto-grow height with content (no scrollbar)',
    ),
    ParkPropertyDef(
      name: 'clearable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示清除按钮（右下角） / Show clear button (bottom-right)',
    ),
    ParkPropertyDef(
      name: 'showCount',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示字数统计 / Show character count',
    ),
    ParkPropertyDef(
      name: 'status',
      type: 'ParkInputStatus?',
      defaultVal: 'null',
      description:
          '手动指定状态样式（error / warning / success），覆盖校验结果 /'
          ' Manual status style overriding validation',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示边框（false 时移除边框） / Bordered',
    ),
    ParkPropertyDef(
      name: 'autofocus',
      type: 'bool',
      defaultVal: 'false',
      description: '是否自动获取焦点 / Auto-focus',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkInputSize?',
      defaultVal: 'null',
      description: '输入框尺寸（null 时不额外控制尺寸） / Size (null = default)',
    ),
    ParkPropertyDef(
      name: 'textAlign',
      type: 'TextAlign',
      defaultVal: 'TextAlign.start',
      description: '文本对齐方式 / Text alignment',
    ),
    ParkPropertyDef(
      name: 'helperText',
      type: 'String?',
      defaultVal: 'null',
      description: '辅助文字，显示在输入框下方（与错误文字互斥） / Helper text below the field',
    ),
    ParkPropertyDef(
      name: 'required',
      type: 'bool',
      defaultVal: 'false',
      description: '是否为必填项（为 true 时在标签前显示红色星号） / Required; red asterisk',
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
      name: 'onChanged',
      signature: 'ValueChanged<String>?',
      description: '输入内容变化回调 / Called when value changes',
    ),
    ParkEventDef(
      name: 'onFocus',
      signature: 'VoidCallback?',
      description: '输入框获取焦点时的回调 / Called on focus',
    ),
    ParkEventDef(
      name: 'onBlur',
      signature: 'VoidCallback?',
      description: '输入框失去焦点时的回调 / Called on blur',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<String>?',
      description: '表单校验器 / Form validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<String>?',
      description: '表单保存回调 / Form save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkTextarea(
  hintText: '请输入备注',
  maxLength: 200,
  onChanged: (v) => print(v),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要用户输入较长文本时（备注、评论、个人简介等） / Long text (remarks, comments, bio)
- 多行文本输入场景 / Multi-line text input

## 使用建议 / Usage tips
- 设置 maxLength 限制字数并显示字数统计 / maxLength + counter
- 通过 minLines/maxLines 控制高度范围，避免占用过多空间 / Bound height with min/maxLines
- 评论类场景建议 minLines: 3, maxLines: 6 / Comments: min 3, max 6
- 搭配 validator 做必填校验 / Required validation via validator
- 自适应高度场景使用 autoSize: true（如评论输入框） / autoSize for auto-grow (comments)
- clearable 在右下角显示清除按钮 / clearable shows button bottom-right

## 搭配推荐 / Compose with
- 搭配 ParkForm 做表单提交 / Pair with ParkForm
- 搭配 ParkInput 处理单行文本输入 / Pair with ParkInput
- 搭配 ParkButton 做提交/取消操作 / Pair with ParkButton

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Input.TextArea：value / placeholder / rows(maxRows/minRows) / showCount / allowClear / autoSize / status / bordered / maxLength；对标 `autoSize` 即 park `autoSize`。
- TDesign Flutter TextArea：label / value / maxLines / minLines / counter / clearable / borderless，无原生 `autoSize` 自适应高度。
- park Textarea 覆盖二者：autoSize 自适应高度、`showCount`/`maxLength` 字数统计、`clearable` 右下角清除、`status` 状态样式、`bindKey` 双向绑定。
### 示例 / Examples
- 对标 Ant `<Input.TextArea autoSize />` → park `ParkTextarea(autoSize: true)`；对标 Ant `showCount` → park `showCount: true`。
- 对标 TDesign `counter` → park `showCount: true`；对标 `clearable` → park `clearable: true`。
### 属性 / Props
- 差异点：park `autoSize` 与 Ant 同名；park 无 Ant 的 `rows` 单独属性，改用 `minLines/maxLines` 语义枚举；park `bindKey` 是表单绑定独有。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础多行输入',
      description: '带标签和占位提示的多行文本输入',
      code: '''
ParkTextarea(
  label: '备注',
  hintText: '请输入备注信息',
)
''',
      builder: (BuildContext context) =>
          ParkTextarea(label: '备注', hintText: '请输入备注信息'),
    ),
    ParkDemoScenario(
      title: '字数限制',
      description: '使用 maxLength 限制字符数并显示字数统计',
      code: '''
ParkTextarea(
  label: '个人简介',
  hintText: '介绍一下自己',
  maxLength: 200,
)
''',
      builder: (BuildContext context) =>
          ParkTextarea(label: '个人简介', hintText: '介绍一下自己', maxLength: 200),
    ),
    ParkDemoScenario(
      title: '自定义行数',
      description: '通过 minLines 和 maxLines 控制高度范围',
      code: '''
ParkTextarea(
  hintText: '最少 2 行，最多 10 行',
  minLines: 2,
  maxLines: 10,
)
''',
      builder: (BuildContext context) =>
          ParkTextarea(hintText: '最少 2 行，最多 10 行', minLines: 2, maxLines: 10),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: '设置 enabled: false 禁用输入',
      code: '''
ParkTextarea(
  initialValue: '这是一段只读的多行文本内容，不允许编辑。',
  enabled: false,
)
''',
      builder: (BuildContext context) =>
          ParkTextarea(initialValue: '这是一段只读的多行文本内容，不允许编辑。', enabled: false),
    ),
    ParkDemoScenario(
      title: '自适应高度',
      description: 'autoSize: true 时文本框随内容自动扩展高度',
      code: '''
ParkTextarea(
  hintText: '输入文字试试，高度会自动增长',
  autoSize: true,
  minLines: 2,
)
''',
      builder: (BuildContext context) =>
          ParkTextarea(hintText: '输入文字试试，高度会自动增长', autoSize: true, minLines: 2),
    ),
    ParkDemoScenario(
      title: '可清除与字数统计',
      description: 'clearable 显示清除按钮；showCount 显示字数统计',
      code: '''
ParkTextarea(
  label: '评价',
  hintText: '请输入评价内容',
  maxLength: 500,
  clearable: true,
  showCount: true,
)
''',
      builder: (BuildContext context) => ParkTextarea(
        label: '评价',
        hintText: '请输入评价内容',
        maxLength: 500,
        clearable: true,
        showCount: true,
      ),
    ),
    ParkDemoScenario(
      title: '状态样式',
      description: '通过 status 手动指定 error / warning / success 边框样式',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkTextarea(hintText: '错误状态', status: ParkInputStatus.error),
    SizedBox(height: _kSpacing.sm),
    ParkTextarea(hintText: '警告状态', status: ParkInputStatus.warning),
    SizedBox(height: _kSpacing.sm),
    ParkTextarea(hintText: '成功状态', status: ParkInputStatus.success),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkTextarea(hintText: '错误状态', status: ParkInputStatus.error),
          SizedBox(height: _kSpacing.sm),
          ParkTextarea(hintText: '警告状态', status: ParkInputStatus.warning),
          SizedBox(height: _kSpacing.sm),
          ParkTextarea(hintText: '成功状态', status: ParkInputStatus.success),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '必填与辅助文字',
      description: 'required 必填标识；helperText 辅助说明',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkTextarea(
      label: '简介',
      hintText: '请输入简介',
      required: true,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkTextarea(
      label: '备注',
      hintText: '选填',
      helperText: '补充说明，不超过 200 字',
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkTextarea(label: '简介', hintText: '请输入简介', required: true),
          SizedBox(height: _kSpacing.sm),
          ParkTextarea(
            label: '备注',
            hintText: '选填',
            helperText: '补充说明，不超过 200 字',
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显多行输入',
      description:
          '通过 StatefulBuilder + onChanged 实时回显多行输入内容，演示 ParkTextarea 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the typed text live, demonstrating ParkTextarea.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    int len = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkTextarea(
          hintText: '输入点什么',
          onChanged: (v) => setState(() => len = v.length),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('已输入字符数：\$len', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        int len = 0;
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkTextarea(
                  hintText: '输入点什么',
                  onChanged: (String v) => setState(() => len = v.length),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('已输入字符数：$len', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：焦点事件演示',
      description:
          '通过 StatefulBuilder 实时回显 ParkTextarea 的 onFocus / onBlur 回调。'
          ' / StatefulBuilder echoes onFocus and onBlur.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String log = '等待交互...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkTextarea(
          hintText: '点击获取焦点，点外部触发 onBlur',
          onFocus: () => setState(() => log = 'onFocus'),
          onBlur: () => setState(() => log = 'onBlur'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String log = '等待交互...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkTextarea(
                  hintText: '点击获取焦点，点外部触发 onBlur',
                  onFocus: () => setState(() => log = 'onFocus'),
                  onBlur: () => setState(() => log = 'onBlur'),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：实时回显输入',
      description:
          '通过 StatefulBuilder 实时回显 ParkTextarea 的 onChanged 回调。'
          ' / StatefulBuilder echoes onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String log = '等待输入...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkTextarea(
          hintText: '输入内容试试',
          onChanged: (v) => setState(() => log = 'onChanged: ' + v),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String log = '等待输入...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkTextarea(
                  hintText: '输入内容试试',
                  onChanged: (String v) =>
                      setState(() => log = 'onChanged: ' + v),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkTextarea 的 validator / onSaved 回调，'
          '点击提交触发校验并保存多行文本。'
          ' / Form + GlobalKey demonstrates ParkTextarea.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkTextarea(
            label: '备注',
            hintText: '请输入备注',
            validator: (String? v) => (v == null || v.isEmpty) ? '备注不能为空' : null,
            onSaved: (String? v) => _saved = v,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkTextareaFormDemo(),
    ),
    // ── ParkTextarea: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，输入内容实时同步到 model。'
          ' / ParkBindingService bindKey demo: textarea content syncs to model in real time.',
      code: '''
final service = ParkBindingService({'bio': 'Flutter 开发者'});

ParkTextarea(
  label: '简介',
  bindKey: 'bio',
  bindingService: service,
  hintText: '输入后下方实时显示',
)''',
      builder: (BuildContext context) => _ParkTextareaBindingDemo(),
    ),
    // ── ParkTextarea: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用，展示多行文本表单自动渲染与提交。'
          ' / ParkForm schema usage demonstration for textarea.',
      code: '''
final schema = ParkFormSchema(formKey: 'park_textarea_remark_demo', fields: [
  ParkFormFieldSchema(
    fieldId: 'f_remark',
    fieldType: ParkFieldType.textarea,
    labelName: '备注',
    fieldName: 'remark',
    fieldPrompt: '请输入备注',
    fieldLength: 200,
  ),
]);

Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkForm(schema: schema, onSubmit: (values) {}),
    SizedBox(height: 12),
    ParkButton(
      child: Text('提交'),
      onPressed: () {},
    ),
  ],
)''',
      builder: (BuildContext context) {
        final schema = ParkFormSchema(
          formKey: 'park_textarea_remark_demo_inline',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_remark',
              fieldType: ParkFieldType.textarea,
              labelName: '备注',
              fieldName: 'remark',
              fieldPrompt: '请输入备注',
              fieldLength: 200,
            ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkForm(schema: schema, onSubmit: (values) {}),
            const SizedBox(height: 12),
            ParkButton(child: const Text('提交'), onPressed: () {}),
          ],
        );
      },
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`textarea`（多行文本）。

### 适用场景
- 备注、评论、个人简介等较长文本采集。
- 需要字数统计或自适应高度的多行输入。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `textarea` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `fieldPrompt` | `field_prompt` / `placeholder` | 占位提示 | 否 |
| `fieldLength` | `field_length` | 最大长度 | 否 |
| `minLength` / `maxLength` | `min_length` / `max_length` | 文本长度区间 | 否 |
| `uiConfig` | `ui_config` / `config` | `rows` 控制行数、`showCount` 字数统计 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_remark',
  fieldType: ParkFieldType.textarea,
  labelName: '备注',
  fieldName: 'remark',
  fieldPrompt: '补充说明（选填）',
  fieldLength: 200,
)
```

### 进阶技巧
- `uiConfig.rows` 设置默认可见行数；`showCount` 开启字数统计。
- 文本校验：用 `regexExpression` 或 `regexTag` 限制格式，`validatorMessage` 自定义错误提示。
- `helpText` 在控件下方显示辅助说明。
- 联动：`visibleRule` / `disabledRule` 实现显隐与禁用。''',
);

class _ParkTextareaFormDemo extends StatefulWidget {
  @override
  State<_ParkTextareaFormDemo> createState() => _ParkTextareaFormDemoState();
}

class _ParkTextareaFormDemoState extends State<_ParkTextareaFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkTextarea(
            label: '备注',
            hintText: '请输入备注',
            validator: (String? v) =>
                (v == null || v.isEmpty) ? '备注不能为空' : null,
            onSaved: (String? v) => _saved = v,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ParkTextarea: ParkBinding 示例
// ============================================================================

class _ParkTextareaBindingDemo extends StatefulWidget {
  @override
  State<_ParkTextareaBindingDemo> createState() =>
      _ParkTextareaBindingDemoState();
}

class _ParkTextareaBindingDemoState extends State<_ParkTextareaBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'bio': 'Flutter 开发者'});
    _service.watchEffect(() {
      _service.getValue<String>('bio');
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
        ParkTextarea(
          label: '简介',
          bindKey: 'bio',
          bindingService: _service,
          hintText: '输入后下方实时显示',
          minLines: 2,
          maxLines: 4,
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

// ---------------------------------------------------------------------------
// ParkSearch
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkSearchSpec = ParkComponentSpec(
  name: 'ParkSearch',
  title: '搜索框',
  category: 'input',
  description:
      '胶囊形搜索输入框，支持搜索图标前缀、清除按钮、取消按钮等功能。'
      '常用于页面顶部的搜索场景。',
  icon: Icons.search_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'controller',
      type: 'TextEditingController?',
      defaultVal: 'null',
      description: '文本控制器 / Text controller',
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String',
      defaultVal: "'搜索'",
      description: '占位提示文字 / Placeholder hint text',
    ),
    ParkPropertyDef(
      name: 'autofocus',
      type: 'bool',
      defaultVal: 'false',
      description: '是否自动获取焦点 / Auto-focus',
    ),
    ParkPropertyDef(
      name: 'showCancel',
      type: 'bool',
      defaultVal: 'false',
      description: '聚焦时是否显示取消按钮 / Show cancel button on focus',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否处于加载状态（搜索图标替换为加载指示器） / Loading state (spinner replaces icon)',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用（渲染禁用样式，不可交互） / Disabled (no interaction)',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkSearchSize',
      defaultVal: 'ParkSearchSize.medium',
      description: '搜索框尺寸：small (32px) / medium (40px) / large (48px) / Size',
    ),
    ParkPropertyDef(
      name: 'shape',
      type: 'ParkSearchShape',
      defaultVal: 'ParkSearchShape.capsule',
      description:
          '搜索框形状：capsule（胶囊形）/ square（方形小圆角） / Shape: capsule / square',
    ),
    ParkPropertyDef(
      name: 'actionText',
      type: 'String?',
      defaultVal: 'null',
      description: '搜索按钮自定义文字，设置后在搜索框右侧显示文字按钮 / Custom action text button',
    ),
    ParkPropertyDef(
      name: 'maxLength',
      type: 'int?',
      defaultVal: 'null',
      description: '最大输入长度 / Max input length',
    ),
    ParkPropertyDef(
      name: 'clearable',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示清除按钮 / Show clear button',
    ),
    ParkPropertyDef(
      name: 'cacheService',
      type: 'ParkSearchCache?',
      defaultVal: 'null',
      description: '搜索缓存服务（实现 ParkSearchCache 接口），设置后自动加载/保存搜索历史并显示建议面板 / Search cache service for history persistence and suggestion panel',
    ),
    ParkPropertyDef(
      name: 'cacheScope',
      type: 'String',
      defaultVal: "'default'",
      description: '缓存作用域（用于隔离不同搜索场景的历史记录） / Cache scope for isolating search history across different contexts',
    ),
    ParkPropertyDef(
      name: 'suggestionBuilder',
      type: 'Widget Function(BuildContext, List<String>, String, ValueChanged<String>)?',
      defaultVal: 'null',
      description: '自定义建议面板构建器（覆盖默认的历史面板 UI） / Custom suggestion panel builder (overrides default history UI)',
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
      name: 'onChanged',
      signature: 'ValueChanged<String>?',
      description: '输入内容变化回调 / Called on input change',
    ),
    ParkEventDef(
      name: 'onSubmitted',
      signature: 'ValueChanged<String>?',
      description: '提交回调（按下键盘回车键时触发） / Called on keyboard submit',
    ),
    ParkEventDef(
      name: 'onClear',
      signature: 'VoidCallback?',
      description: '清除内容回调 / Called on clear',
    ),
    ParkEventDef(
      name: 'onSearch',
      signature: 'ValueChanged<String>?',
      description:
          '搜索回调（与 onSubmitted 等价，兼容 AntD 命名） / Search callback (AntD alias)',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSearch(
  hintText: '搜索',
  onChanged: (v) => print(v),
)
''',
  guide: '''
## 何时使用 / When to use
- 页面顶部需要搜索功能时 / Search entry at page top
- 商品、文章、联系人等列表的搜索入口 / List search (goods/articles/contacts)

## 使用建议 / Usage tips
- 实时搜索场景使用 onChanged 监听输入变化 / onChanged for live search
- 提交搜索场景使用 onSubmitted 监听回车确认 / onSubmitted on Enter
- 设置 showCancel: true 在聚焦时显示取消按钮 / showCancel on focus
- 页面跳转搜索场景可配合 autofocus: true 自动聚焦 / autofocus for jump-in search
- 清除后通过 onClear 重置搜索结果 / onClear resets results
- loading: true 替换搜索图标为加载指示器 / loading shows spinner
- 通过 size 控制搜索框高度（small/medium/large） / size controls height
- actionText 在右侧显示文字搜索按钮 / actionText shows a text button

## 搭配推荐 / Compose with
- 搭配 ParkList 做搜索结果展示 / Pair with ParkList
- 搭配 ParkEmpty 做无搜索结果提示 / Pair with ParkEmpty
- 搭配 ParkTabs 做分类筛选 + 搜索 / Pair with ParkTabs

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Input.Search：内置搜索按钮 + `enterButton` 自定义、loading、allowClear、占位；对标 `searchButton` 即 park `actionText`/`onSearch`。
- TDesign Flutter Search：基础搜索条，支持 `value`/`placeholder`/`clearable`/`action`，无原生 `showCancel`/`loading` 图标替换。
- park Search 覆盖二者：胶囊/方形 `shape`、`showCancel` 聚焦取消、`loading` 图标替换、`actionText` 文字按钮、`size` 三档高度、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<Input.Search enterButton="搜索" />` → park `ParkSearch(actionText: '搜索', onSubmitted: ...)`。
- 对标 TDesign `clearable` → park `clearable: true`（park 默认 true）。
### 属性 / Props
- 差异点：park `actionText` 等价于 Ant `enterButton`；park `showCancel` 是移动端聚焦取消独有；park `shape: capsule/square` 比 Ant 的 `Input.Search` 更语义化。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础搜索框',
      description: '默认胶囊形搜索框，自带搜索图标',
      code: '''
ParkSearch(
  hintText: '搜索商品',
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) =>
          ParkSearch(hintText: '搜索商品', onChanged: (v) {}),
    ),
    ParkDemoScenario(
      title: '带取消按钮',
      description: '设置 showCancel: true，聚焦时右侧出现取消按钮',
      code: '''
ParkSearch(
  hintText: '搜索',
  showCancel: true,
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) =>
          ParkSearch(hintText: '搜索', showCancel: true, onChanged: (v) {}),
    ),
    ParkDemoScenario(
      title: '加载与禁用',
      description: 'loading 显示加载指示器；disabled 禁用交互',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkSearch(
      hintText: '加载中',
      loading: true,
    ),
    ParkSearch(
      hintText: '已禁用',
      disabled: true,
    ),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: <Widget>[
          ParkSearch(hintText: '加载中', loading: true),
          ParkSearch(hintText: '已禁用', disabled: true),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '搜索框尺寸',
      description: '通过 size 切换 small / medium / large 高度',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSearch(hintText: '小尺寸', size: ParkSearchSize.small),
    SizedBox(height: _kSpacing.sm),
    ParkSearch(hintText: '中尺寸', size: ParkSearchSize.medium),
    SizedBox(height: _kSpacing.sm),
    ParkSearch(hintText: '大尺寸', size: ParkSearchSize.large),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkSearch(hintText: '小尺寸', size: ParkSearchSize.small),
          SizedBox(height: _kSpacing.sm),
          ParkSearch(hintText: '中尺寸', size: ParkSearchSize.medium),
          SizedBox(height: _kSpacing.sm),
          ParkSearch(hintText: '大尺寸', size: ParkSearchSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '方形搜索框',
      description: '设置 shape: ParkSearchShape.square 切换为方形圆角',
      code: '''
ParkSearch(
  hintText: '方形搜索框',
  shape: ParkSearchShape.square,
  onChanged: (v) {},
)
''',
      builder: (BuildContext context) => ParkSearch(
        hintText: '方形搜索框',
        shape: ParkSearchShape.square,
        onChanged: (v) {},
      ),
    ),
    ParkDemoScenario(
      title: '右侧操作按钮',
      description: '通过 actionText 在右侧显示文字按钮',
      code: '''
ParkSearch(
  hintText: '输入关键词',
  actionText: '搜索',
  onSubmitted: (v) => print('搜索: \$v'),
)
''',
      builder: (BuildContext context) =>
          ParkSearch(hintText: '输入关键词', actionText: '搜索', onSubmitted: (v) {}),
    ),
    ParkDemoScenario(
      title: '可交互：实时搜索回显',
      description:
          '通过 StatefulBuilder + onChanged 实时回显搜索词，演示 ParkSearch 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the query live, demonstrating ParkSearch.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String q = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkSearch(
          hintText: '输入搜索词',
          onChanged: (v) => setState(() => q = v),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('搜索词：\$q', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String q = '';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkSearch(
                  hintText: '输入搜索词',
                  onChanged: (String v) => setState(() => q = v),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('搜索词：$q', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    // ── ParkSearch: cacheService 示例 ──
    ParkDemoScenario(
      title: 'ParkSearch — cacheService 搜索历史缓存',
      description:
          '实现 ParkSearchCache 接口，用 SharedPreferences 存储搜索历史，\n'
          '注入 cacheService 后自动显示历史建议面板。',
      code: '''// 1. 实现 ParkSearchCache 接口（用 SharedPreferences）
class _DemoSearchCache implements ParkSearchCache {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<String>> loadHistory(String scope) async {
    final prefs = await _prefs;
    return prefs.getStringList('search_history_\u0024scope') ?? [];
  }

  Future<void> saveHistory(String scope, String keyword) async {
    final prefs = await _prefs;
    final list = (prefs.getStringList('search_history_\u0024scope') ?? []);
    list.remove(keyword);
    list.insert(0, keyword);
    await prefs.setStringList('search_history_\u0024scope', list.take(20).toList());
  }

  Future<void> removeHistory(String scope, String keyword) async {
    final prefs = await _prefs;
    final list = (prefs.getStringList('search_history_\u0024scope') ?? []);
    list.remove(keyword);
    await prefs.setStringList('search_history_\u0024scope', list);
  }

  Future<void> clearHistory(String scope) async {
    final prefs = await _prefs;
    await prefs.remove('search_history_\u0024scope');
  }
}

// 2. 使用
ParkSearch(
  hintText: '输入搜索词',
  cacheService: _DemoSearchCache(),
  cacheScope: 'demo',
  showCancel: true,
)''',
      builder: (BuildContext context) => _ParkSearchCacheDemo(),
    ),
    ParkDemoScenario(
      title: '可交互：清除与搜索事件演示',
      description:
          '通过 StatefulBuilder 实时回显 ParkSearch 的 onClear / onSearch 回调。'
          ' / StatefulBuilder echoes onClear and onSearch.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String log = '等待交互...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkSearch(
          hintText: '输入后回车或清除',
          clearable: true,
          onClear: () => setState(() => log = 'onClear'),
          onSearch: (v) => setState(() => log = 'onSearch: \$v'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String log = '等待交互...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkSearch(
                  hintText: '输入后回车或清除',
                  clearable: true,
                  onClear: () => setState(() => log = 'onClear'),
                  onSearch: (String v) => setState(() => log = 'onSearch: \$v'),
                ),
              ],
            );
          },
        );
      },
    ),
    // ── ParkSearch: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，搜索词实时同步到 model。'
          ' / ParkBindingService bindKey demo: search text syncs to model in real time.',
      code: '''
final service = ParkBindingService({'keyword': ''});

ParkSearch(
  hintText: '输入搜索词',
  bindKey: 'keyword',
  bindingService: service,
)''',
      builder: (BuildContext context) => _ParkSearchBindingDemo(),
    ),
    // ── ParkSearch: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用，展示搜索框表单自动渲染与提交。'
          ' / ParkForm schema usage demonstration for search.',
      code: '''
final schema = ParkFormSchema(formKey: 'park_search_keyword_demo', fields: [
  ParkFormFieldSchema(
    fieldId: 'f_keyword',
    fieldType: ParkFieldType.search,
    labelName: '搜索',
    fieldName: 'keyword',
    fieldPrompt: '搜索关键词',
  ),
]);

Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkForm(schema: schema, onSubmit: (values) {}),
    SizedBox(height: 12),
    ParkButton(
      child: Text('提交'),
      onPressed: () {},
    ),
  ],
)''',
      builder: (BuildContext context) {
        final schema = ParkFormSchema(
          formKey: 'park_search_keyword_demo_inline',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_keyword',
              fieldType: ParkFieldType.search,
              labelName: '搜索',
              fieldName: 'keyword',
              fieldPrompt: '搜索关键词',
            ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkForm(schema: schema, onSubmit: (values) {}),
            const SizedBox(height: 12),
            ParkButton(child: const Text('提交'), onPressed: () {}),
          ],
        );
      },
    ),
    // ── ParkSearch: 验证码按钮 ──
    ParkDemoScenario(
      title: '验证码按钮',
      description:
          '通过 actionText 实现「获取验证码」功能：点击后加载 3s，随后进入 60s 倒计时，'
          '结束后可重新获取。'
          ' / SMS verification code button with 60s countdown.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String btnText = '获取验证码';
    bool isLoading = false;
    int countdown = 0;

    void startCountdown() {
      countdown = 60;
      btnText = '60s';
      Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          countdown--;
          btnText = countdown <= 0 ? '重新获取' : '\${countdown}s';
          if (countdown <= 0) {
            t.cancel();
          }
        });
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkSearch(
          hintText: '请输入手机号',
          actionText: btnText,
          loading: isLoading,
          onSubmitted: (v) {
            if (isLoading || countdown > 0) return;
            setState(() {
              isLoading = true;
              btnText = '发送中...';
            });
            Future.delayed(const Duration(seconds: 3), () {
              setState(() => isLoading = false);
              startCountdown();
            });
          },
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String btnText = '获取验证码';
        bool isLoading = false;
        int countdown = 0;

        void startCountdown(StateSetter setState) {
          countdown = 60;
          btnText = '60s';
          Timer.periodic(const Duration(seconds: 1), (t) {
            setState(() {
              countdown--;
              if (countdown <= 0) {
                t.cancel();
                btnText = '重新获取';
              } else {
                btnText = '${countdown}s';
              }
            });
          });
        }

        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkSearch(
                  hintText: '请输入手机号',
                  actionText: btnText,
                  loading: isLoading,
                  onSubmitted: (String v) {
                    if (isLoading || countdown > 0) return;
                    setState(() {
                      isLoading = true;
                      btnText = '发送中...';
                    });
                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() => isLoading = false);
                      startCountdown(setState);
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`search`（搜索框）。

### 适用场景
- 列表页顶部搜索入口、关键词过滤。
- 配置化搜索字段，提交时回传关键词。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `search` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `fieldPrompt` | `field_prompt` / `placeholder` | 占位提示 | 否 |
| `defaultValue` | `default_value` | 初始搜索词 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_keyword',
  fieldType: ParkFieldType.search,
  labelName: '搜索',
  fieldName: 'keyword',
  fieldPrompt: '搜索关键词',
)
```

### 进阶技巧
- 搜索结果常依赖其它字段（如分类），可在 `ext` 中记录关联键，运行时以 `\u{24}form.xxx` 方式引用。
- 配合 `dataSourceType` 做远程建议；用 `regexTag` 限制输入格式。
- 联动：`disabledRule` 在依赖未选时禁用搜索框。''',
);

// ============================================================================
// ParkSearch: ParkBinding 示例
// ============================================================================

class _ParkSearchBindingDemo extends StatefulWidget {
  @override
  State<_ParkSearchBindingDemo> createState() => _ParkSearchBindingDemoState();
}

class _ParkSearchBindingDemoState extends State<_ParkSearchBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'keyword': ''});
    _service.watchEffect(() {
      _service.getValue<String>('keyword');
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
        ParkSearch(
          hintText: '输入搜索词',
          bindKey: 'keyword',
          bindingService: _service,
          clearable: true,
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

// ---------------------------------------------------------------------------
// ParkSwitch
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkSwitchSpec = ParkComponentSpec(
  name: 'ParkSwitch',
  title: '开关',
  category: 'input',
  description:
      '基于 FormField<bool> 封装的拨动开关，支持动画过渡、加载中状态、'
      '自定义激活/非激活颜色、开关内容、前置确认拦截等。',
  icon: Icons.toggle_on_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'dynamic',
      defaultVal: 'false',
      description:
          '当前开关状态（支持泛型，通过 checkedValue/uncheckedValue 映射） /'
          ' Current state (generic via checked/uncheckedValue)',
    ),
    ParkPropertyDef(
      name: 'activeColor',
      type: 'Color?',
      defaultVal: 'null（主题 brand 色）',
      description: '激活状态颜色 / Active color',
    ),
    ParkPropertyDef(
      name: 'inactiveColor',
      type: 'Color?',
      defaultVal: 'null（主题 border 色）',
      description: '非激活状态颜色 / Inactive color',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkSwitchSize',
      defaultVal: 'ParkSwitchSize.medium',
      description: '开关尺寸：small (36x20) / medium (44x24) / large (52x28) / Size',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用 / Disabled',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于加载中状态 / Loading state',
    ),
    ParkPropertyDef(
      name: 'checkedContent',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '开启状态下拇指上的内容（如对勾图标） / Thumb content when on (e.g. check icon)',
    ),
    ParkPropertyDef(
      name: 'uncheckedContent',
      type: 'Widget?',
      defaultVal: 'null',
      description: '关闭状态下拇指上的内容 / Thumb content when off',
    ),
    ParkPropertyDef(
      name: 'checkedValue',
      type: 'dynamic',
      defaultVal: 'true',
      description: '表示「开启」状态的值 / Value representing "on"',
    ),
    ParkPropertyDef(
      name: 'uncheckedValue',
      type: 'dynamic',
      defaultVal: 'false',
      description: '表示「关闭」状态的值 / Value representing "off"',
    ),
    ParkPropertyDef(
      name: 'beforeChange',
      type: 'Future<bool> Function()?',
      defaultVal: 'null',
      description:
          '切换前的异步拦截回调，返回 false 阻止切换（可用于异步确认弹窗） /'
          ' Async guard before toggle; false blocks (e.g. confirm dialog)',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '开关文字标签，显示在开关旁边 / Text label beside the switch',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读（外观正常但不可交互） / Read-only (no interaction)',
    ),
    ParkPropertyDef(
      name: 'thumbIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义拇指图标 / Custom thumb icon',
    ),
    ParkPropertyDef(
      name: 'checkedChild',
      type: 'Widget?',
      defaultVal: 'null',
      description: '选中状态下在滑块（thumb）上显示的自定义元素 / Custom child on thumb when checked',
    ),
    ParkPropertyDef(
      name: 'uncheckedChild',
      type: 'Widget?',
      defaultVal: 'null',
      description: '未选中状态下在滑块（thumb）上显示的自定义元素 / Custom child on thumb when unchecked',
    ),
    ParkPropertyDef(
      name: 'checkedLabel',
      type: 'String?',
      defaultVal: 'null',
      description: '选中状态的语义标签，用于无障碍（Semantics） / Semantic label when checked (for Semantics)',
    ),
    ParkPropertyDef(
      name: 'uncheckedLabel',
      type: 'String?',
      defaultVal: 'null',
      description: '未选中状态的语义标签，用于无障碍（Semantics） / Semantic label when unchecked (for Semantics)',
    ),
    ParkPropertyDef(
      name: 'tooltip',
      type: 'String?',
      defaultVal: 'null',
      description: '长按提示文本 / Long-press tooltip',
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
      name: 'onChanged',
      signature: 'ValueChanged<dynamic>?',
      description:
          '开关状态变化回调，参数为 checkedValue 或 uncheckedValue /'
          ' Called on toggle (checked/uncheckedValue)',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<dynamic>?',
      description: '表单校验器 / Form validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<dynamic>?',
      description: '表单保存回调 / Form save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSwitch(
  value: true,
  onChanged: (v) => print(v),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要在两种状态之间即时切换时（开/关、启用/禁用） / Instant on/off toggle
- 设置项中的开关控制 / Settings toggles

## 使用建议 / Usage tips
- 与 ParkCheckbox 的区别：开关即时生效，复选框需提交 / Switch = instant; Checkbox = on submit
- 异步操作时设置 loading: true 显示加载状态 / loading shows spinner during async
- 通过 activeColor/inactiveColor 自定义颜色区分状态 / Custom colors per state
- 搭配 label 文字说明开关含义 / label explains the meaning
- 设置项列表中使用 small 尺寸更紧凑 / small size for compact lists
- beforeChange 可实现异步确认拦截（如「确定要关闭吗？」） / beforeChange for async confirm
- checkedContent/uncheckedContent 在拇指上显示图标 / Thumb icons via checked/uncheckedContent

## 搭配推荐 / Compose with
- 搭配 ParkCell 做设置列表项 / Pair with ParkCell
- 搭配 ParkForm 做设置表单 / Pair with ParkForm
- 搭配 ParkToast 做操作反馈 / Pair with ParkToast

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Switch：checked / loading / disabled / size(default/small) / activeChildren/inactiveChildren / onChange；对标 `checkedContent` 即 park `checkedContent`。
- TDesign Flutter Switch：value / label / activeColor / inactiveColor / size / loading / enable，无原生 `beforeChange` 异步拦截与 `thumbIcon`。
- park Switch 覆盖二者：checkedValue/uncheckedValue 泛型值映射、`beforeChange` 异步拦截（Ant 需外层包裹）、`checkedContent/uncheckedContent` 拇指图标、`readOnly`、`tooltip`、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<Switch defaultChecked onChange={...} />` → park `ParkSwitch(value: true, onChanged: (v) {})`。
- 对标 Ant `loading` / `disabled` → park `loading: true` / `disabled: true`。
- 异步确认：park `beforeChange: () async { return await showConfirm(); }`。
### 属性 / Props
- 差异点：park `beforeChange` 是 Ant/TDesign 缺失的异步拦截能力；park `checkedValue/uncheckedValue` 支持非布尔值（如 'Y'/'N'），比 Ant 的布尔 `checked` 更灵活。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础开关',
      description: '默认 medium 尺寸的拨动开关',
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSwitch(value: false, onChanged: (v) {}),
    SizedBox(width: _kSpacing.md),
    ParkSwitch(value: true, onChanged: (v) {}),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkSwitch(value: false, onChanged: (v) {}),
          SizedBox(width: _kSpacing.md),
          ParkSwitch(value: true, onChanged: (v) {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '开关尺寸',
      description: '展示 small / medium / large 三种尺寸',
      code: '''
Wrap(
  spacing: _kSpacing.md,
  children: [
    ParkSwitch(value: true, size: ParkSwitchSize.small, onChanged: (v) {}),
    ParkSwitch(value: true, size: ParkSwitchSize.medium, onChanged: (v) {}),
    ParkSwitch(value: true, size: ParkSwitchSize.large, onChanged: (v) {}),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.md,
        children: [
          ParkSwitch(
            value: true,
            size: ParkSwitchSize.small,
            onChanged: (v) {},
          ),
          ParkSwitch(
            value: true,
            size: ParkSwitchSize.medium,
            onChanged: (v) {},
          ),
          ParkSwitch(
            value: true,
            size: ParkSwitchSize.large,
            onChanged: (v) {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description: '通过 activeColor 和 inactiveColor 自定义外观',
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSwitch(
      value: true,
      activeColor: _kColors.success,
      onChanged: (v) {},
    ),
    SizedBox(width: _kSpacing.md),
    ParkSwitch(
      value: true,
      activeColor: _kColors.brand,
      onChanged: (v) {},
    ),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkSwitch(
            value: true,
            activeColor: _kColors.success,
            onChanged: (v) {},
          ),
          SizedBox(width: _kSpacing.md),
          ParkSwitch(
            value: true,
            activeColor: _kColors.brand,
            onChanged: (v) {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '加载与禁用',
      description: '展示 loading 和 disabled 状态',
      code: '''
Wrap(
  spacing: _kSpacing.md,
  children: [
    ParkSwitch(value: true, loading: true, onChanged: (v) {}),
    ParkSwitch(value: true, disabled: true, onChanged: (v) {}),
    ParkSwitch(value: false, disabled: true, onChanged: (v) {}),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.md,
        children: [
          ParkSwitch(value: true, loading: true, onChanged: (v) {}),
          ParkSwitch(value: true, disabled: true, onChanged: (v) {}),
          ParkSwitch(value: false, disabled: true, onChanged: (v) {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带内容的开关',
      description: 'checkedContent 和 uncheckedContent 在拇指上显示图标',
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSwitch(
      value: true,
      checkedContent: Icon(Icons.check, size: 14, color: _kColors.success),
      onChanged: (v) {},
    ),
    SizedBox(width: _kSpacing.md),
    ParkSwitch(
      value: false,
      uncheckedContent: Icon(Icons.close, size: 14, color: _kColors.error),
      onChanged: (v) {},
    ),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkSwitch(
            value: true,
            checkedContent: Icon(
              Icons.check,
              size: 14,
              color: _kColors.success,
            ),
            onChanged: (v) {},
          ),
          SizedBox(width: _kSpacing.md),
          ParkSwitch(
            value: false,
            uncheckedContent: Icon(
              Icons.close,
              size: 14,
              color: _kColors.error,
            ),
            onChanged: (v) {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带标签的开关',
      description: '通过 label 参数在开关旁边显示文字标签',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSwitch(
      value: true,
      label: const Text('启用通知'),
      onChanged: (v) {},
    ),
    SizedBox(height: _kSpacing.sm),
    ParkSwitch(
      value: false,
      label: const Text('深色模式'),
      onChanged: (v) {},
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParkSwitch(value: true, label: '启用通知', onChanged: (v) {}),
          SizedBox(height: _kSpacing.sm),
          ParkSwitch(value: false, label: '深色模式', onChanged: (v) {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显开关状态',
      description:
          '通过 StatefulBuilder + onChanged 实时回显开关状态，演示 ParkSwitch 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the toggle state live, demonstrating ParkSwitch.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    bool on = false;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkSwitch(
          value: on,
          onChanged: (v) => setState(() => on = v == true),
        ),
        SizedBox(width: _kSpacing.md),
        ParkText('状态：\$on', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        bool on = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkSwitch(
                  value: on,
                  onChanged: (dynamic v) => setState(() => on = v == true),
                ),
                SizedBox(width: _kSpacing.md),
                ParkText('状态：$on', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkSwitch 的 validator / onSaved 回调，'
          '点击提交校验开关是否开启并保存布尔值。'
          ' / Form + GlobalKey demonstrates ParkSwitch.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agree = false;
  bool? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkSwitch(
            value: _agree,
            label: '同意用户协议',
            validator: (v) => (v == null || v == false) ? '请先同意用户协议' : null,
            onSaved: (v) => _saved = v as bool?,
            onChanged: (v) => setState(() => _agree = v as bool),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!.toString(), preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkSwitchFormDemo(),
    ),
    // -----------------------------------------------------------------------
    // ParkSwitch Binding Demo
    // -----------------------------------------------------------------------
    ParkDemoScenario(
      title: '绑定演示',
      description:
          '通过 bindKey + bindingService 实现双向绑定，开关状态实时同步到模型。'
          ' / bindKey + bindingService for two-way binding, toggle state synced to model.',
      code: '''
final service = ParkBindingService({'enabled': true});

ParkSwitch(
  label: '接收通知',
  value: true,
  bindKey: 'enabled',
  bindingService: service,
)''',
      builder: (BuildContext context) => _SwitchBindingDemo(),
    ),
    // ── ParkSwitch: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用，展示开关表单自动渲染与提交。'
          ' / ParkForm schema usage demonstration for switch/toggle.',
      code: '''
final schema = ParkFormSchema(formKey: 'park_switch_member_demo', fields: [
  ParkFormFieldSchema(
    fieldId: 'f_member',
    fieldType: ParkFieldType.toggle,
    labelName: '是否会员',
    fieldName: 'member',
    defaultValue: false,
  ),
]);

Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkForm(schema: schema, onSubmit: (values) {}),
    SizedBox(height: 12),
    ParkButton(
      child: Text('提交'),
      onPressed: () {},
    ),
  ],
)''',
      builder: (BuildContext context) {
        final schema = ParkFormSchema(
          formKey: 'park_switch_member_demo_inline',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_member',
              fieldType: ParkFieldType.toggle,
              labelName: '是否会员',
              fieldName: 'member',
              defaultValue: false,
            ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkForm(schema: schema, onSubmit: (values) {}),
            const SizedBox(height: 12),
            ParkButton(child: const Text('提交'), onPressed: () {}),
          ],
        );
      },
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`toggle`（开关）。

### 适用场景
- 启用/禁用、是否会员等二元状态字段。
- 即时生效的布尔开关（区别于提交时才收集的复选框）。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `toggle` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认开关状态（true/false） | 否 |
| `helpText` | `help_text` | 辅助说明 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_member',
  fieldType: ParkFieldType.toggle,
  labelName: '是否会员',
  fieldName: 'member',
  defaultValue: false,
)
```

### 进阶技巧
- `defaultValue` 直接给布尔值，提交时写入 true/false。
- 开关状态联动其它字段：用 `reaction` 的 `setVisible` / `setDisabled`，命中条件可引用 `\u{24}form.xxx`。
- `helpText` 说明开关含义。''',
);

class _ParkSwitchFormDemo extends StatefulWidget {
  @override
  State<_ParkSwitchFormDemo> createState() => _ParkSwitchFormDemoState();
}

class _ParkSwitchFormDemoState extends State<_ParkSwitchFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agree = false;
  bool? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkSwitch(
            value: _agree,
            label: '同意用户协议',
            validator: (v) => (v == null || v == false) ? '请先同意用户协议' : null,
            onSaved: (v) => _saved = v as bool?,
            onChanged: (v) => setState(() => _agree = v as bool),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText(
              '已保存: ' + _saved!.toString(),
              preset: ParkTextPreset.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ParkSwitch Binding Demo
// ============================================================================

class _SwitchBindingDemo extends StatefulWidget {
  @override
  State<_SwitchBindingDemo> createState() => _SwitchBindingDemoState();
}

class _SwitchBindingDemoState extends State<_SwitchBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'enabled': true});
    _service.watchEffect(() {
      _service.getValue<bool>('enabled');
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
          ParkSwitch(
            label: '接收通知',
            value: true,
            bindKey: 'enabled',
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

// ---------------------------------------------------------------------------
// ParkCheckbox
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkCheckboxSpec = ParkComponentSpec(
  name: 'ParkCheckbox',
  title: '复选框',
  category: 'input',
  description:
      '基于 FormField<bool> 封装的复选框，支持选中、未选中、半选（indeterminate）'
      '三种状态，支持方形/圆形外观、只读模式。附带 ParkCheckboxGroup 组合组件。',
  icon: Icons.check_box_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'bool',
      defaultVal: 'false',
      description: '当前选中状态 / Current checked state',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'Widget?',
      defaultVal: 'null',
      description: '复选框标签，通常为 Text 组件 / Label widget (usually Text)',
    ),
    ParkPropertyDef(
      name: 'shape',
      type: 'ParkCheckboxShape',
      defaultVal: 'ParkCheckboxShape.square',
      description: '复选框形状：square / circle / Shape: square / circle',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'double',
      defaultVal: '20',
      description: '复选框尺寸（像素） / Size in px',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用 / Disabled',
    ),
    ParkPropertyDef(
      name: 'indeterminate',
      type: 'bool',
      defaultVal: 'false',
      description: '是否半选状态（显示横线图标） / Indeterminate (dash icon)',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读（外观正常但不可交互） / Read-only',
    ),
    ParkPropertyDef(
      name: 'autoFocus',
      type: 'bool',
      defaultVal: 'false',
      description: '是否自动获取焦点 / Auto-focus',
    ),
    ParkPropertyDef(
      name: 'onFocus',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '获取焦点回调 / Called on focus',
    ),
    ParkPropertyDef(
      name: 'onBlur',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '失去焦点回调 / Called on blur',
    ),
    ParkPropertyDef(
      name: 'formValue',
      type: 'dynamic',
      defaultVal: 'null',
      description: '表单值（用于 FormField 集成的显式值标识） / Explicit form value',
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
      name: 'onChanged',
      signature: 'ValueChanged<bool>?',
      description: '选中状态变化回调 / Called on checked change',
    ),
    ParkEventDef(
      name: 'onFocus',
      signature: 'VoidCallback?',
      description: '获取焦点回调 / Called on focus',
    ),
    ParkEventDef(
      name: 'onBlur',
      signature: 'VoidCallback?',
      description: '失去焦点回调 / Called on blur',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<bool>?',
      description: '表单校验器 / Form validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<bool>?',
      description: '表单保存回调 / Form save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkCheckbox(
  value: true,
  label: Text('同意协议'),
  onChanged: (v) => print(v),
)
''',
  guide: '''
## 何时使用 / When to use
- 多选场景中让用户选择一个或多个选项 / Multi-select one or more options
- 协议同意、权限选择等场景 / Agreement / permission selection

## 使用建议 / Usage tips
- 与 ParkSwitch 的区别：复选框用于表单提交，开关用于即时切换 / Checkbox = submit; Switch = instant
- 使用 ParkCheckboxGroup 管理多选组合 / Use ParkCheckboxGroup for groups
- 全选场景使用 indeterminate: true 显示半选状态 / indeterminate for "select all" partial
- 选项少于 3 个时考虑用 ParkRadio 替代 / <3 options: prefer ParkRadio
- 通过 shape 切换方形/圆形外观 / shape: square / circle
- readOnly 用于展示已保存的协议同意状态 / readOnly shows saved agreement

## 搭配推荐 / Compose with
- 搭配 ParkForm 做表单多选提交 / Pair with ParkForm
- 搭配 ParkButton 做确认操作 / Pair with ParkButton
- 搭配 ParkTag 做已选标签展示 / Pair with ParkTag

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Checkbox：value / label / disabled / indeterminate / onChange；`Checkbox.Group` 管理组合；对标 `indeterminate` 即 park `indeterminate`。
- TDesign Flutter CheckBox：value / label / disabled / size / shape(square/circle) / indeterminate / onChange；有 `CheckBoxGroup`。
- park Checkbox 覆盖二者：`shape` square/circle、`indeterminate` 半选、`ParkCheckboxGroup` 组合（vertical/horizontal/wrap）、`readOnly` 展示态、`formValue` 显式值、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<Checkbox indeterminate />` → park `ParkCheckbox(indeterminate: true, ...)`。
- 对标 TDesign `shape="circle"` → park `shape: ParkCheckboxShape.circle`。
- 组合：park `ParkCheckboxGroup(options: [...], value: [...], layout: ParkCheckboxGroupLayout.wrap, onChanged: ...)`.
### 属性 / Props
- 差异点：park `ParkCheckboxGroup.layout` 的 wrap 是移动端紧凑排布独有；park `readOnly` 是展示已保存态的便捷属性；park `bindKey` 是表单绑定独有。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础复选框',
      description: '带标签文字的方形复选框',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkCheckbox(value: false, label: Text('未选中'), onChanged: (v) {}),
    SizedBox(height: _kSpacing.sm),
    ParkCheckbox(value: true, label: Text('已选中'), onChanged: (v) {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkCheckbox(
            value: false,
            label: const Text('未选中'),
            onChanged: (v) {},
          ),
          SizedBox(height: _kSpacing.sm),
          ParkCheckbox(
            value: true,
            label: const Text('已选中'),
            onChanged: (v) {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '半选状态',
      description: '使用 indeterminate: true 展示半选（横线图标）效果',
      code: '''
ParkCheckbox(
  value: false,
  indeterminate: true,
  label: Text('半选（全选部分子项）'),
  onChanged: (v) {},
)
''',
      builder: (BuildContext context) => ParkCheckbox(
        value: false,
        indeterminate: true,
        label: const Text('半选（全选部分子项）'),
        onChanged: (v) {},
      ),
    ),
    ParkDemoScenario(
      title: '圆形外观',
      description: '使用 shape: ParkCheckboxShape.circle 切换为圆形',
      code: '''
ParkCheckbox(
  value: true,
  shape: ParkCheckboxShape.circle,
  label: Text('圆形复选框'),
  onChanged: (v) {},
)
''',
      builder: (BuildContext context) => ParkCheckbox(
        value: true,
        shape: ParkCheckboxShape.circle,
        label: const Text('圆形复选框'),
        onChanged: (v) {},
      ),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: '设置 disabled: true 禁止交互',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkCheckbox(value: true, disabled: true, label: Text('已选-禁用'), onChanged: (v) {}),
    SizedBox(height: _kSpacing.sm),
    ParkCheckbox(value: false, disabled: true, label: Text('未选-禁用'), onChanged: (v) {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkCheckbox(
            value: true,
            disabled: true,
            label: const Text('已选-禁用'),
            onChanged: (v) {},
          ),
          SizedBox(height: _kSpacing.sm),
          ParkCheckbox(
            value: false,
            disabled: true,
            label: const Text('未选-禁用'),
            onChanged: (v) {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '复选框组',
      description:
          '使用 ParkCheckboxGroup 组合多个选项，支持 vertical / horizontal / wrap 布局',
      code: '''
ParkCheckboxGroup(
  options: [
    ParkCheckboxOption(label: 'Flutter', value: 'Flutter'),
    ParkCheckboxOption(label: 'React Native', value: 'React Native'),
    ParkCheckboxOption(label: 'SwiftUI', value: 'SwiftUI'),
    ParkCheckboxOption(label: 'Jetpack Compose', value: 'Jetpack Compose'),
  ],
  value: ['Flutter'],
  layout: ParkCheckboxGroupLayout.vertical,
  onChanged: (selected, options) => print(selected),
)
''',
      builder: (BuildContext context) => ParkCheckboxGroup(
        options: const <ParkCheckboxOption>[
          ParkCheckboxOption(label: 'Flutter', value: 'Flutter'),
          ParkCheckboxOption(label: 'React Native', value: 'React Native'),
          ParkCheckboxOption(label: 'SwiftUI', value: 'SwiftUI'),
          ParkCheckboxOption(
            label: 'Jetpack Compose',
            value: 'Jetpack Compose',
          ),
        ],
        value: const <String>['Flutter'],
        layout: ParkCheckboxGroupLayout.vertical,
        onChanged: (List<String> selected, List<ParkCheckboxOption> options) {},
      ),
    ),
    ParkDemoScenario(
      title: '只读模式',
      description: 'readOnly: true 时外观正常但不可交互',
      code: '''
ParkCheckbox(
  value: true,
  readOnly: true,
  label: Text('已同意服务条款（只读）'),
)
''',
      builder: (BuildContext context) => ParkCheckbox(
        value: true,
        readOnly: true,
        label: const Text('已同意服务条款（只读）'),
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显选中状态',
      description:
          '通过 StatefulBuilder + onChanged 实时回显选中状态，演示 ParkCheckbox 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the checked state live, demonstrating ParkCheckbox.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    bool checked = false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkCheckbox(
          value: checked,
          label: Text('同意服务条款'),
          onChanged: (v) => setState(() => checked = v),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('已同意：\$checked', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        bool checked = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkCheckbox(
                  value: checked,
                  label: const Text('同意服务条款'),
                  onChanged: (bool v) => setState(() => checked = v),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('已同意：$checked', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkCheckbox 的 validator / onSaved 回调，'
          '点击提交校验是否勾选并保存布尔值。'
          ' / Form + GlobalKey demonstrates ParkCheckbox.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agree = false;
  bool? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkCheckbox(
            value: _agree,
            label: const Text('我已阅读并同意条款'),
            validator: (bool? v) => (v == null || !v) ? '请先勾选同意条款' : null,
            onSaved: (bool? v) => _saved = v,
            onChanged: (bool v) => setState(() => _agree = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!.toString(), preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkCheckboxFormDemo(),
    ),
    // ── ParkCheckbox: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用，展示复选框表单自动渲染与提交。'
          ' / ParkForm schema usage demonstration for checkbox.',
      code: '''
final schema = ParkFormSchema(formKey: 'park_checkbox_hobby_demo', fields: [
  ParkFormFieldSchema(
    fieldId: 'f_hobby',
    fieldType: ParkFieldType.checkbox,
    labelName: '兴趣爱好',
    fieldName: 'hobby',
    options: [
      {'label': '运动', 'value': 'sport'},
      {'label': '音乐', 'value': 'music'},
      {'label': '阅读', 'value': 'reading'},
    ],
  ),
]);

Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkForm(schema: schema, onSubmit: (values) {}),
    SizedBox(height: 12),
    ParkButton(
      child: Text('提交'),
      onPressed: () {},
    ),
  ],
)''',
      builder: (BuildContext context) {
        final schema = ParkFormSchema(
          formKey: 'park_checkbox_hobby_demo_inline',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_hobby',
              fieldType: ParkFieldType.checkbox,
              labelName: '兴趣爱好',
              fieldName: 'hobby',
              options: const [
                {'label': '运动', 'value': 'sport'},
                {'label': '音乐', 'value': 'music'},
                {'label': '阅读', 'value': 'reading'},
              ],
            ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkForm(schema: schema, onSubmit: (values) {}),
            const SizedBox(height: 12),
            ParkButton(child: const Text('提交'), onPressed: () {}),
          ],
        );
      },
    ),
    // ── ParkCheckbox: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '绑定演示',
      description:
          '通过 bindKey + bindingService 实现双向绑定，复选框状态实时同步到 model。'
          ' / ParkBindingService bindKey demo: checkbox state syncs to model in real time.',
      code: '''
final service = ParkBindingService({'agree': true});

ParkCheckbox(
  label: Text('同意协议'),
  bindKey: 'agree',
  bindingService: service,
)''',
      builder: (BuildContext context) => _ParkCheckboxBindingDemo(),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`checkbox`（多选组）。

### 适用场景
- 兴趣爱好、权限勾选等可多选的字段。
- 协议同意等需提交时收集的多选场景。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `checkbox` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 至少选一项时可设必填 | 否 |
| `dataSourceType` | `data_source_type` | 选项来源：staticOptions/enumSource/dict/api | 否 |
| `dataSourceKey` | `data_source_key` | 数据源键 | 否 |
| `options` | `options` | 静态选项列表（{label,value}） | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_hobby',
  fieldType: ParkFieldType.checkbox,
  labelName: '兴趣爱好',
  fieldName: 'hobby',
  options: [
    {'label': '运动', 'value': 'sport'},
    {'label': '音乐', 'value': 'music'},
  ],
)
```

### 进阶技巧
- 选项优先用 `dataSourceType + dataSourceKey` 从枚举/字典/接口加载；静态场景直接给 `options`。
- 多选值以列表提交，`isRequired` 控制是否至少选一项。
- 联动：`reloadOptions` 动作可在依赖字段变化后刷新选项。''',
);

class _ParkCheckboxFormDemo extends StatefulWidget {
  @override
  State<_ParkCheckboxFormDemo> createState() => _ParkCheckboxFormDemoState();
}

class _ParkCheckboxFormDemoState extends State<_ParkCheckboxFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agree = false;
  bool? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkCheckbox(
            value: _agree,
            label: const Text('我已阅读并同意条款'),
            validator: (bool? v) => (v == null || !v) ? '请先勾选同意条款' : null,
            onSaved: (bool? v) => _saved = v,
            onChanged: (bool v) => setState(() => _agree = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText(
              '已保存: ' + _saved!.toString(),
              preset: ParkTextPreset.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ParkCheckbox: ParkBinding 示例
// ============================================================================

class _ParkCheckboxBindingDemo extends StatefulWidget {
  @override
  State<_ParkCheckboxBindingDemo> createState() =>
      _ParkCheckboxBindingDemoState();
}

class _ParkCheckboxBindingDemoState extends State<_ParkCheckboxBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'agree': true});
    _service.watchEffect(() {
      _service.getValue<bool>('agree');
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
        ParkCheckbox(
          label: const Text('同意协议'),
          bindKey: 'agree',
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

// ---------------------------------------------------------------------------
// ParkRadio
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkRadioSpec = ParkComponentSpec(
  name: 'ParkRadio',
  title: '单选框',
  category: 'input',
  description:
      '基于 FormField<String> 封装的单选框组，支持水平/垂直/自动换行布局，'
      '带动画选中过渡效果。支持 dot（默认圆形）/ button（分段器风格）两种外观样式，'
      '以及 small / medium / large 三种尺寸。可直接嵌入 Form 使用。',
  icon: Icons.radio_button_checked_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'String?',
      defaultVal: 'null',
      description: '当前选中的值 / Currently selected value',
    ),
    ParkPropertyDef(
      name: 'options',
      type: 'List<ParkRadioOption>',
      required: true,
      description:
          '选项列表，每项含 label / value / disabled / Option list (label/value/disabled)',
    ),
    ParkPropertyDef(
      name: 'layout',
      type: 'ParkRadioLayout',
      defaultVal: 'ParkRadioLayout.vertical',
      description:
          '布局方式：horizontal / vertical / wrap / Layout: horizontal / vertical / wrap',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否整体禁用 / Disable the whole group',
    ),
    ParkPropertyDef(
      name: 'radioStyle',
      type: 'ParkRadioStyle',
      defaultVal: 'ParkRadioStyle.dot',
      description: '外观样式：dot（默认圆形指示器）/ button（分段器风格） / Style: dot / button',
    ),
    ParkPropertyDef(
      name: 'card',
      type: 'bool',
      defaultVal: 'false',
      description:
          '卡片模式：每个选项渲染为一个带内边距的卡片容器。 / Card mode: each option is a padded card',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description: '卡片模式时控制卡片是否显示边框。 / Card border toggle in card mode',
    ),
    ParkPropertyDef(
      name: 'radioSize',
      type: 'ParkRadioSize',
      defaultVal: 'ParkRadioSize.medium',
      description: '单选框尺寸：small (16px) / medium (20px) / large (24px) / Size',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读（外观正常但不可交互） / Read-only',
    ),
    ParkPropertyDef(
      name: 'autoFocus',
      type: 'bool',
      defaultVal: 'false',
      description: '是否自动获取焦点 / Auto-focus',
    ),
    ParkPropertyDef(
      name: 'onFocus',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '获取焦点回调 / Called on focus',
    ),
    ParkPropertyDef(
      name: 'onBlur',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '失去焦点回调 / Called on blur',
    ),
    ParkPropertyDef(
      name: 'optionBuilder',
      type: 'Widget Function(ParkRadioOption, bool, VoidCallback?)?',
      defaultVal: 'null',
      description: '自定义选项渲染回调（覆盖默认选项渲染） / Custom option renderer',
    ),
    ParkPropertyDef(
      name: 'buttonJoin',
      type: 'bool',
      defaultVal: 'false',
      description: '按钮式模式下选项紧密拼接（去除间隙、合并边框） / Button-join: tight-pack options in button mode',
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
      name: 'onChanged',
      signature: 'ValueChanged<String?>?',
      description: '选中值变化回调 / Called when selection changes',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<String>?',
      description: '表单校验器 / Form validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<String>?',
      description: '表单保存回调 / Form save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkRadio(
  options: [
    ParkRadioOption(label: '选项 A', value: 'a'),
    ParkRadioOption(label: '选项 B', value: 'b'),
  ],
  value: 'a',
  onChanged: (v) => print('选中: \$v'),
)
''',
  guide: '''
## 何时使用 / When to use
- 单选场景中从多个选项中选择一个 / Pick exactly one from several options
- 性别选择、支付方式、评价等级等 / Gender, payment, rating

## 使用建议 / Usage tips
- 选项少（2-5 个）时优先使用单选框，一目了然 / Few options: prefer radio
- 选项多时使用 ParkSelect 节省空间 / Many options: use ParkSelect
- 水平布局（horizontal）适合少量选项，垂直布局适合较多选项 / horizontal for few; vertical for many
- 通过 ParkRadioOption.disabled 禁用特定选项 / Disable specific option via ParkRadioOption.disabled
- 搭配 ParkForm 使用可自动收集表单值 / Auto-collect with ParkForm
- radioStyle: button 切换为按钮式风格 / radioStyle: button for segmented look

## 搭配推荐 / Compose with
- 搭配 ParkForm 做单选表单 / Pair with ParkForm
- 搭配 ParkButton 做提交操作 / Pair with ParkButton
- 搭配 ParkDivider 做选项分隔 / Pair with ParkDivider

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Radio / Radio.Group：value / options / disabled / optionType(default/button) / size / onChange；对标 `radioStyle` 即 park `radioStyle`，`optionType: button` 即 park `button`。
- TDesign Flutter RadioGroup：value / options / disabled / size / variant(plain/outline/default) / direction(horizontal/vertical)；有紧凑 `variant=default` 分段样式。
- park Radio 覆盖二者：dot/button 外观、vertical/horizontal/wrap 布局、card 卡片模式、small/medium/large 尺寸、`readOnly`、`optionBuilder` 自定义、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<Radio.Group optionType="button" />` → park `ParkRadio(options: [...], radioStyle: ParkRadioStyle.button, layout: ParkRadioLayout.horizontal)`。
- 对标 TDesign `direction="vertical"` → park `layout: ParkRadioLayout.vertical`。
### 属性 / Props
- 差异点：park `wrap` 布局是移动端自动换行独有；park `card` 卡片模式在 Ant/TDesign 需外层包裹；park `bindKey` 是表单绑定独有；park `radioSize` 用语义枚举（Ant 用 default/large）。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础单选框',
      description: '垂直排列的单选框组',
      code: '''
ParkRadio(
  options: [
    ParkRadioOption(label: '选项 A', value: 'a'),
    ParkRadioOption(label: '选项 B', value: 'b'),
    ParkRadioOption(label: '选项 C', value: 'c'),
  ],
  value: 'a',
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkRadio(
        options: const <ParkRadioOption>[
          ParkRadioOption(label: '选项 A', value: 'a'),
          ParkRadioOption(label: '选项 B', value: 'b'),
          ParkRadioOption(label: '选项 C', value: 'c'),
        ],
        value: 'a',
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '水平布局',
      description: '使用 layout: ParkRadioLayout.horizontal 水平排列',
      code: '''
ParkRadio(
  options: [
    ParkRadioOption(label: '男', value: 'male'),
    ParkRadioOption(label: '女', value: 'female'),
  ],
  value: 'male',
  layout: ParkRadioLayout.horizontal,
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkRadio(
        options: const <ParkRadioOption>[
          ParkRadioOption(label: '男', value: 'male'),
          ParkRadioOption(label: '女', value: 'female'),
        ],
        value: 'male',
        layout: ParkRadioLayout.horizontal,
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '自动换行布局',
      description: '使用 layout: ParkRadioLayout.wrap 自动换行',
      code: '''
ParkRadio(
  options: [
    ParkRadioOption(label: '北京', value: 'bj'),
    ParkRadioOption(label: '上海', value: 'sh'),
    ParkRadioOption(label: '广州', value: 'gz'),
    ParkRadioOption(label: '深圳', value: 'sz'),
  ],
  value: 'bj',
  layout: ParkRadioLayout.wrap,
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkRadio(
        options: const <ParkRadioOption>[
          ParkRadioOption(label: '北京', value: 'bj'),
          ParkRadioOption(label: '上海', value: 'sh'),
          ParkRadioOption(label: '广州', value: 'gz'),
          ParkRadioOption(label: '深圳', value: 'sz'),
        ],
        value: 'bj',
        layout: ParkRadioLayout.wrap,
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '单项禁用',
      description: '通过 ParkRadioOption.disabled 禁用特定选项',
      code: '''
ParkRadio(
  options: [
    ParkRadioOption(label: '可用选项', value: 'a'),
    ParkRadioOption(label: '已禁用', value: 'b', disabled: true),
    ParkRadioOption(label: '另一个可用', value: 'c'),
  ],
  value: 'a',
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkRadio(
        options: const <ParkRadioOption>[
          ParkRadioOption(label: '可用选项', value: 'a'),
          ParkRadioOption(label: '已禁用', value: 'b', disabled: true),
          ParkRadioOption(label: '另一个可用', value: 'c'),
        ],
        value: 'a',
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '单选框尺寸',
      description: '展示 small / medium / large 三种尺寸',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkRadio(
      options: [ParkRadioOption(label: '小尺寸', value: 's')],
      value: 's',
      radioSize: ParkRadioSize.small,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkRadio(
      options: [ParkRadioOption(label: '中尺寸', value: 'm')],
      value: 'm',
      radioSize: ParkRadioSize.medium,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkRadio(
      options: [ParkRadioOption(label: '大尺寸', value: 'l')],
      value: 'l',
      radioSize: ParkRadioSize.large,
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ParkRadio(
            options: const [ParkRadioOption(label: '小尺寸', value: 's')],
            value: 's',
            radioSize: ParkRadioSize.small,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkRadio(
            options: const [ParkRadioOption(label: '中尺寸', value: 'm')],
            value: 'm',
            radioSize: ParkRadioSize.medium,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkRadio(
            options: const [ParkRadioOption(label: '大尺寸', value: 'l')],
            value: 'l',
            radioSize: ParkRadioSize.large,
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '按钮式风格',
      description: 'radioStyle: ParkRadioStyle.button 切换为分段器风格',
      code: '''
ParkRadio(
  options: [
    ParkRadioOption(label: '日', value: 'day'),
    ParkRadioOption(label: '周', value: 'week'),
    ParkRadioOption(label: '月', value: 'month'),
  ],
  value: 'day',
  layout: ParkRadioLayout.horizontal,
  radioStyle: ParkRadioStyle.button,
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkRadio(
        options: const <ParkRadioOption>[
          ParkRadioOption(label: '日', value: 'day'),
          ParkRadioOption(label: '周', value: 'week'),
          ParkRadioOption(label: '月', value: 'month'),
        ],
        value: 'day',
        layout: ParkRadioLayout.horizontal,
        radioStyle: ParkRadioStyle.button,
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显选中值',
      description:
          '通过 StatefulBuilder + onChanged 实时回显选中值，演示 ParkRadio 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the selected value live, demonstrating ParkRadio.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String v = 'a';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkRadio(
          options: [
            ParkRadioOption(label: '选项 A', value: 'a'),
            ParkRadioOption(label: '选项 B', value: 'b'),
          ],
          value: v,
          onChanged: (val) => setState(() => v = val ?? ''),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('选中：\$v', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String v = 'a';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkRadio(
                  options: const <ParkRadioOption>[
                    ParkRadioOption(label: '选项 A', value: 'a'),
                    ParkRadioOption(label: '选项 B', value: 'b'),
                  ],
                  value: v,
                  onChanged: (String? val) => setState(() => v = val ?? ''),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('选中：$v', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkRadio 的 validator / onSaved 回调，'
          '点击提交校验是否选择并保存选中的字符串值。'
          ' / Form + GlobalKey demonstrates ParkRadio.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _value;
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkRadio(
            options: const <ParkRadioOption>[
              ParkRadioOption(label: '男', value: 'male'),
              ParkRadioOption(label: '女', value: 'female'),
            ],
            value: _value,
            validator: (String? v) => (v == null || v.isEmpty) ? '请选择性别' : null,
            onSaved: (String? v) => _saved = v,
            onChanged: (String? v) => setState(() => _value = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkRadioFormDemo(),
    ),
    // ── ParkRadio: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用，展示单选框表单自动渲染与提交。'
          ' / ParkForm schema usage demonstration for radio.',
      code: '''
final schema = ParkFormSchema(formKey: 'park_radio_gender_demo', fields: [
  ParkFormFieldSchema(
    fieldId: 'f_gender',
    fieldType: ParkFieldType.radio,
    labelName: '性别',
    fieldName: 'gender',
    isRequired: true,
    options: [
      {'label': '男', 'value': 'male'},
      {'label': '女', 'value': 'female'},
    ],
  ),
]);

Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkForm(schema: schema, onSubmit: (values) {}),
    SizedBox(height: 12),
    ParkButton(
      child: Text('提交'),
      onPressed: () {},
    ),
  ],
)''',
      builder: (BuildContext context) {
        final schema = ParkFormSchema(
          formKey: 'park_radio_gender_demo_inline',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_gender',
              fieldType: ParkFieldType.radio,
              labelName: '性别',
              fieldName: 'gender',
              isRequired: true,
              options: const [
                {'label': '男', 'value': 'male'},
                {'label': '女', 'value': 'female'},
              ],
            ),
          ],
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkForm(schema: schema, onSubmit: (values) {}),
            const SizedBox(height: 12),
            ParkButton(child: const Text('提交'), onPressed: () {}),
          ],
        );
      },
    ),
    // ── ParkRadio: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '绑定演示',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选择选项实时同步到 model。'
          ' / ParkBindingService bindKey demo: radio selection syncs to model in real time.',
      code: '''
final service = ParkBindingService({'gender': 'male'});

ParkRadio(
  bindKey: 'gender',
  bindingService: service,
  options: [
    ParkRadioOption(label: '男', value: 'male'),
    ParkRadioOption(label: '女', value: 'female'),
  ],
)''',
      builder: (BuildContext context) => _ParkRadioBindingDemo(),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`radio`（单选组）。

### 适用场景
- 性别、支付方式等互斥的单选字段。
- 选项少（2-5 个）时优先用单选框。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `radio` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `dataSourceType` | `data_source_type` | 选项来源 | 否 |
| `options` | `options` | 静态选项列表 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_gender',
  fieldType: ParkFieldType.radio,
  labelName: '性别',
  fieldName: 'gender',
  isRequired: true,
  options: [
    {'label': '男', 'value': 'male'},
    {'label': '女', 'value': 'female'},
  ],
)
```

### 进阶技巧
- 选项来源同 `checkbox`：`dataSourceType + dataSourceKey` 或 `options`。
- 选项多时建议改用 `select` 节省空间。
- 联动：`visibleRule` 控制整组显隐；`setValue` 动作可按条件写入默认值。''',
);

class _ParkRadioFormDemo extends StatefulWidget {
  @override
  State<_ParkRadioFormDemo> createState() => _ParkRadioFormDemoState();
}

class _ParkRadioFormDemoState extends State<_ParkRadioFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _value;
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkRadio(
            options: const <ParkRadioOption>[
              ParkRadioOption(label: '男', value: 'male'),
              ParkRadioOption(label: '女', value: 'female'),
            ],
            value: _value,
            validator: (String? v) => (v == null || v.isEmpty) ? '请选择性别' : null,
            onSaved: (String? v) => _saved = v,
            onChanged: (String? v) => setState(() => _value = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ParkRadio: ParkBinding 示例
// ============================================================================

class _ParkRadioBindingDemo extends StatefulWidget {
  @override
  State<_ParkRadioBindingDemo> createState() => _ParkRadioBindingDemoState();
}

class _ParkRadioBindingDemoState extends State<_ParkRadioBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{'gender': 'male'});
    _service.watchEffect(() {
      _service.getValue<String>('gender');
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
        ParkRadio(
          bindKey: 'gender',
          bindingService: _service,
          options: const <ParkRadioOption>[
            ParkRadioOption(label: '男', value: 'male'),
            ParkRadioOption(label: '女', value: 'female'),
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

// ---------------------------------------------------------------------------
// ParkSelect
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkSelectSpec = ParkComponentSpec(
  name: 'ParkSelect',
  title: '下拉选择器',
  category: 'input',
  description:
      '基于 FormField<String> 封装的下拉选择器，支持单选/多选模式，'
      '支持分组、搜索过滤、远程搜索、标签模式、虚拟滚动、自定义渲染等。'
      '点击输入框弹出底部面板展示选项列表，多选模式显示 Chips。',
  icon: Icons.arrow_drop_down_circle_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkSelectOption>',
      required: true,
      description:
          '选项列表，每项含 label / value / disabled / group / Option list (label/value/disabled/group)',
    ),
    ParkPropertyDef(
      name: 'value',
      type: 'String?',
      defaultVal: 'null',
      description:
          '当前选中值（单选为 value，多选为逗号分隔 values） / Current value (single) or comma-joined (multiple)',
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<String?>?',
      defaultVal: 'null',
      description: '选中值变更回调 / Called on selection change',
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String?',
      defaultVal: 'null',
      description: '占位提示文字 / Placeholder hint',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '输入框上方标签文字 / Label above field',
    ),
    ParkPropertyDef(
      name: 'multiple',
      type: 'bool',
      defaultVal: 'false',
      description: '是否多选模式 / Multiple selection mode',
    ),
    ParkPropertyDef(
      name: 'clearable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否可清除选中值 / Allow clearing selection',
    ),
    ParkPropertyDef(
      name: 'enabled',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用 / Enabled',
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读 / Read-only',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于加载中 / Loading state',
    ),
    ParkPropertyDef(
      name: 'loadingText',
      type: 'String',
      defaultVal: "'加载中…'",
      description: '加载文案 / Loading text',
    ),
    ParkPropertyDef(
      name: 'emptyText',
      type: 'String',
      defaultVal: "'暂无选项'",
      description: '空态文案 / Empty-state text',
    ),
    ParkPropertyDef(
      name: 'searchable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用搜索过滤 / Enable search filter',
    ),
    ParkPropertyDef(
      name: 'searching',
      type: 'bool',
      defaultVal: 'false',
      description: '远程搜索中状态 / Remote-searching state',
    ),
    ParkPropertyDef(
      name: 'searchErrorText',
      type: 'String?',
      defaultVal: 'null',
      description: '搜索错误文案 / Search error text',
    ),
    ParkPropertyDef(
      name: 'grouped',
      type: 'bool',
      defaultVal: 'true',
      description: '是否按 group 渲染分组标题 / Render group titles',
    ),
    ParkPropertyDef(
      name: 'maxTagCount',
      type: 'int?',
      defaultVal: 'null',
      description: '多选模式下可见 chip 的最大数量，超出显示 +N / Max visible chips (multiple)',
    ),
    ParkPropertyDef(
      name: 'status',
      type: 'ParkSelectStatus?',
      defaultVal: 'null',
      description:
          '选择器状态（error / warning），影响边框颜色 / Status (error/warning) affects border',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkSelectSize',
      defaultVal: 'ParkSelectSize.medium',
      description: '选择器尺寸：small / medium / large / Size',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示边框 / Bordered',
    ),
    ParkPropertyDef(
      name: 'notFoundContent',
      type: 'Widget?',
      defaultVal: 'null',
      description: '无匹配选项时的自定义空态 widget / Custom empty widget',
    ),
    ParkPropertyDef(
      name: 'allowCreate',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否允许用户创建新选项（tag 模式，需 searchable 为 true） / Allow creating new option (tag mode)',
    ),
    ParkPropertyDef(
      name: 'suffixIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义后缀图标（替换默认箭头） / Custom suffix icon',
    ),
    ParkPropertyDef(
      name: 'maxSelection',
      type: 'int?',
      defaultVal: 'null',
      description:
          '多选模式下最大可选数量，null 时不限制 / Max selections (multiple); null = unlimited',
    ),
    ParkPropertyDef(
      name: 'prefixIcon',
      type: 'IconData?',
      defaultVal: 'null',
      description: '前置图标（显示在输入框内容之前） / Leading icon',
    ),
    ParkPropertyDef(
      name: 'filterOption',
      type: 'dynamic',
      defaultVal: 'null',
      description:
          '是否启用选项过滤（true 使用内置过滤，Function 自定义过滤逻辑） / Option filter (true or custom fn)',
    ),
    ParkPropertyDef(
      name: 'optionRender',
      type: 'Widget Function(ParkSelectOption, bool)?',
      defaultVal: 'null',
      description: '自定义选项渲染回调 / Custom option renderer',
    ),
    ParkPropertyDef(
      name: 'virtual',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用虚拟滚动（大量选项时的性能优化） / Virtual scrolling for large lists',
    ),
    ParkPropertyDef(
      name: 'popupMatchSelectWidth',
      type: 'bool',
      defaultVal: 'true',
      description: '下拉面板宽度是否与选择器宽度一致 / Popup matches select width',
    ),
    ParkPropertyDef(
      name: 'dropdownRender',
      type: 'Widget Function(Widget)?',
      defaultVal: 'null',
      description: '下拉面板自定义渲染（包裹在选项列表外部） / Custom dropdown panel wrapper',
    ),
    ParkPropertyDef(
      name: 'onSearchAsync',
      type: 'Future<List<ParkSelectOption>> Function(String)?',
      defaultVal: 'null',
      description: '异步远程搜索回调（输入关键词后防抖调用，返回匹配选项列表）/ Async remote search callback',
    ),
    ParkPropertyDef(
      name: 'searchDebounce',
      type: 'Duration',
      defaultVal: 'const Duration(milliseconds: 300)',
      description: '搜索防抖延迟（配合 onSearchAsync 使用）/ Search debounce duration',
    ),
    ParkPropertyDef(
      name: 'searchLoadingText',
      type: 'String?',
      defaultVal: 'null',
      description: '远程搜索加载中的提示文案（为 null 时使用默认 loadingText）/ Search loading text',
    ),
    ParkPropertyDef(
      name: 'virtualize',
      type: 'bool?',
      defaultVal: 'null',
      description: '是否强制虚拟滚动渲染（大量选项时的性能优化，null 时自动判断）/ Force virtualized rendering',
    ),
    ParkPropertyDef(
      name: 'groupedOptions',
      type: 'List<ParkSelectGroupOption>?',
      defaultVal: 'null',
      description: '分组选项列表（与 items 二选一，优先级高于 items）/ Grouped option list (mutually exclusive with items)',
    ),
    ParkPropertyDef(
      name: 'showArrow',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示下拉箭头图标 / Show dropdown arrow icon',
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
      name: 'onChanged',
      signature: 'ValueChanged<String?>?',
      description: '选中值变化回调 / Called on selection change',
    ),
    ParkEventDef(
      name: 'onSearchChanged',
      signature: 'ValueChanged<String>?',
      description: '搜索输入变化回调 / Called on search input change',
    ),
    ParkEventDef(
      name: 'onSearch',
      signature: 'ValueChanged<String>?',
      description:
          '搜索回调（与 onSearchChanged 等价，兼容 AntD 命名） / Search callback (AntD alias)',
    ),
    ParkEventDef(
      name: 'onClear',
      signature: 'VoidCallback?',
      description: '清除按钮点击时的额外回调 / Extra callback on clear',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<String>?',
      description: '表单校验器 / Form validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<String>?',
      description: '表单保存回调 / Form save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSelect(
  label: '城市',
  items: [
    ParkSelectOption(label: '北京', value: 'beijing'),
    ParkSelectOption(label: '上海', value: 'shanghai'),
  ],
  value: 'beijing',
  onChanged: (v) => print(v),
)
''',
  guide: '''
## 何时使用 / When to use
- 选项较多（5 个以上）需要从列表中选择时 / Choose from many options (5+)
- 城市选择、分类筛选、技术栈选择等 / City, category, tech-stack

## 使用建议 / Usage tips
- 与 ParkRadio 的区别：选择器节省空间，适合选项多的场景 / Select saves space (many options)
- 多选模式设置 multiple: true，选中值以 Chips 展示 / multiple: true shows chips
- 设置 clearable: true 允许清除选中值 / clearable: true to clear
- 通过 ParkSelectOption.disabled 禁用特定选项 / Disable option via ParkSelectOption.disabled
- 搭配 ParkForm 使用可自动收集表单值 / Auto-collect with ParkForm
- searchable: true 开启搜索过滤，适合大量选项 / searchable for large lists
- grouped: true 按 group 字段渲染分组标题 / grouped renders group titles

## 搭配推荐 / Compose with
- 搭配 ParkForm 做下拉选择表单 / Pair with ParkForm
- 搭配 ParkCascader 做多级联动选择 / Pair with ParkCascader
- 搭配 ParkInput 做混合表单 / Pair with ParkInput

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Select：value / options / mode(multiple/tags) / showSearch / allowClear / maxTagCount / size / status / filterOption / optionRender / virtual；对标 `showSearch` 即 park `searchable`，`allowClear` 即 `clearable`，`mode="multiple"` 即 `multiple`。
- TDesign Flutter Select：value / options / multiple / clearable / searchable / size / popupWidth / filterable；有 `SelectInput` + `Select` 拆分。
- park Select 覆盖二者：单选/多选 Chips、`searchable` 过滤、`allowCreate` 标签创建、`grouped` 分组、`virtual` 虚拟滚动、`maxSelection` 多选上限、`dropdownRender` 面板定制、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<Select mode="multiple" allowClear showSearch />` → park `ParkSelect(multiple: true, clearable: true, searchable: true)`。
- 对标 Ant `maxTagCount={2}` → park `maxTagCount: 2`。
- 远程搜索：park `searching: true` + `onSearch` 拉取数据；对标 Ant `onSearch`。
### 属性 / Props
- 差异点：park `allowCreate`（tag 创建新值）是 Ant `mode="tags"` 的等效能力；park `maxSelection` 多选上限为独有；park `bindKey` 是表单绑定独有；park `popupMatchSelectWidth` 对标 Ant `dropdownMatchSelectWidth`。

## 设计令牌参考 / Design Token Reference
- 高度：48px (medium)，与 ParkInput 一致；圆角：radius.sm (8px)
- 内边距：12px 16px；弹出层阴影：shadows.md，弹出层圆角：radius.sm (8px)
- 选项项高度：36px，选项项内边距：8px 16px
- 详见 DESIGN_SYSTEM.md

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础单选',
      description: '点击弹出底部面板选择单个选项',
      code: '''
ParkSelect(
  label: '城市',
  hintText: '请选择城市',
  items: [
    ParkSelectOption(label: '北京', value: 'beijing'),
    ParkSelectOption(label: '上海', value: 'shanghai'),
    ParkSelectOption(label: '广州', value: 'guangzhou'),
    ParkSelectOption(label: '深圳', value: 'shenzhen'),
  ],
  value: 'beijing',
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkSelect(
        label: '城市',
        hintText: '请选择城市',
        items: const <ParkSelectOption>[
          ParkSelectOption(label: '北京', value: 'beijing'),
          ParkSelectOption(label: '上海', value: 'shanghai'),
          ParkSelectOption(label: '广州', value: 'guangzhou'),
          ParkSelectOption(label: '深圳', value: 'shenzhen'),
        ],
        value: 'beijing',
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '多选模式',
      description: '设置 multiple: true，选中值以 Chips 形式展示',
      code: '''
ParkSelect(
  label: '技术栈',
  hintText: '请选择技术栈',
  multiple: true,
  items: [
    ParkSelectOption(label: 'Flutter', value: 'flutter'),
    ParkSelectOption(label: 'React', value: 'react'),
    ParkSelectOption(label: 'Vue', value: 'vue'),
    ParkSelectOption(label: 'Swift', value: 'swift'),
  ],
  value: 'flutter,react',
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkSelect(
        label: '技术栈',
        hintText: '请选择技术栈',
        multiple: true,
        items: const <ParkSelectOption>[
          ParkSelectOption(label: 'Flutter', value: 'flutter'),
          ParkSelectOption(label: 'React', value: 'react'),
          ParkSelectOption(label: 'Vue', value: 'vue'),
          ParkSelectOption(label: 'Swift', value: 'swift'),
        ],
        value: 'flutter,react',
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '可清除',
      description: '设置 clearable: true 显示清除按钮',
      code: '''
ParkSelect(
  label: '分类',
  hintText: '请选择分类',
  clearable: true,
  items: [
    ParkSelectOption(label: '技术', value: 'tech'),
    ParkSelectOption(label: '设计', value: 'design'),
    ParkSelectOption(label: '产品', value: 'product'),
  ],
  value: 'tech',
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkSelect(
        label: '分类',
        hintText: '请选择分类',
        clearable: true,
        items: const <ParkSelectOption>[
          ParkSelectOption(label: '技术', value: 'tech'),
          ParkSelectOption(label: '设计', value: 'design'),
          ParkSelectOption(label: '产品', value: 'product'),
        ],
        value: 'tech',
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '单项禁用',
      description: '通过 ParkSelectOption.disabled 禁用特定选项',
      code: '''
ParkSelect(
  label: '语言',
  hintText: '请选择',
  items: [
    ParkSelectOption(label: '中文', value: 'zh'),
    ParkSelectOption(label: '英文', value: 'en'),
    ParkSelectOption(label: '日文（暂不可选）', value: 'ja', disabled: true),
  ],
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkSelect(
        label: '语言',
        hintText: '请选择',
        items: const <ParkSelectOption>[
          ParkSelectOption(label: '中文', value: 'zh'),
          ParkSelectOption(label: '英文', value: 'en'),
          ParkSelectOption(label: '日文（暂不可选）', value: 'ja', disabled: true),
        ],
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '搜索过滤',
      description: 'searchable: true 开启搜索过滤，快速定位选项',
      code: '''
ParkSelect(
  label: '城市',
  hintText: '搜索城市',
  searchable: true,
  items: [
    ParkSelectOption(label: '北京', value: 'beijing'),
    ParkSelectOption(label: '上海', value: 'shanghai'),
    ParkSelectOption(label: '广州', value: 'guangzhou'),
    ParkSelectOption(label: '深圳', value: 'shenzhen'),
    ParkSelectOption(label: '杭州', value: 'hangzhou'),
  ],
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkSelect(
        label: '城市',
        hintText: '搜索城市',
        searchable: true,
        items: const <ParkSelectOption>[
          ParkSelectOption(label: '北京', value: 'beijing'),
          ParkSelectOption(label: '上海', value: 'shanghai'),
          ParkSelectOption(label: '广州', value: 'guangzhou'),
          ParkSelectOption(label: '深圳', value: 'shenzhen'),
          ParkSelectOption(label: '杭州', value: 'hangzhou'),
        ],
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '分组选项',
      description: '通过 ParkSelectOption.group 对选项进行分组展示',
      code: '''
ParkSelect(
  label: '技术栈',
  hintText: '请选择',
  items: [
    ParkSelectOption(label: 'Flutter', value: 'flutter', group: '前端'),
    ParkSelectOption(label: 'React', value: 'react', group: '前端'),
    ParkSelectOption(label: 'Python', value: 'python', group: '后端'),
    ParkSelectOption(label: 'Go', value: 'go', group: '后端'),
  ],
  grouped: true,
  onChanged: (v) => print(v),
)
''',
      builder: (BuildContext context) => ParkSelect(
        label: '技术栈',
        hintText: '请选择',
        items: const <ParkSelectOption>[
          ParkSelectOption(label: 'Flutter', value: 'flutter', group: '前端'),
          ParkSelectOption(label: 'React', value: 'react', group: '前端'),
          ParkSelectOption(label: 'Python', value: 'python', group: '后端'),
          ParkSelectOption(label: 'Go', value: 'go', group: '后端'),
        ],
        grouped: true,
        onChanged: (String? v) {},
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显选中值',
      description:
          '通过 StatefulBuilder + onChanged 实时回显选中值，演示 ParkSelect 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the selected value live, demonstrating ParkSelect.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String v = 'beijing';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkSelect(
          items: [
            ParkSelectOption(label: '北京', value: 'beijing'),
            ParkSelectOption(label: '上海', value: 'shanghai'),
          ],
          value: v,
          onChanged: (val) => setState(() => v = val ?? ''),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('选中：\$v', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String v = 'beijing';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkSelect(
                  items: const <ParkSelectOption>[
                    ParkSelectOption(label: '北京', value: 'beijing'),
                    ParkSelectOption(label: '上海', value: 'shanghai'),
                    ParkSelectOption(label: '广州', value: 'guangzhou'),
                  ],
                  value: v,
                  onChanged: (String? val) => setState(() => v = val ?? ''),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('选中：$v', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：远程搜索回显',
      description:
          'searchable 配合 onSearchChanged 监听搜索词（远程搜索模式），演示 ParkSelect 的 onSearchChanged 事件。'
          ' / searchable + onSearchChanged listens to the query (remote-search pattern), demonstrating ParkSelect.onSearchChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String q = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkSelect(
          searchable: true,
          items: [
            ParkSelectOption(label: '北京', value: 'beijing'),
            ParkSelectOption(label: '上海', value: 'shanghai'),
          ],
          onSearchChanged: (val) => setState(() => q = val),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('搜索词：\$q', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String q = '';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkSelect(
                  searchable: true,
                  items: const <ParkSelectOption>[
                    ParkSelectOption(label: '北京', value: 'beijing'),
                    ParkSelectOption(label: '上海', value: 'shanghai'),
                    ParkSelectOption(label: '广州', value: 'guangzhou'),
                  ],
                  onSearchChanged: (String val) => setState(() => q = val),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('搜索词：$q', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '可交互：清除与搜索事件演示',
      description:
          'searchable + onSearch 监听搜索词，clearable + onClear 监听清除，'
          '演示 ParkSelect 的 onSearch / onClear 回调。'
          ' / searchable + onSearch + clearable + onClear (onSearch is the AntD alias of onSearchChanged).',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    String log = '等待交互...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkSelect(
          searchable: true,
          clearable: true,
          items: [
            ParkSelectOption(label: '北京', value: 'beijing'),
            ParkSelectOption(label: '上海', value: 'shanghai'),
          ],
          onSearch: (v) => setState(() => log = 'onSearch: \$v'),
          onClear: () => setState(() => log = 'onClear'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        String log = '等待交互...';
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkSelect(
                  searchable: true,
                  clearable: true,
                  items: const <ParkSelectOption>[
                    ParkSelectOption(label: '北京', value: 'beijing'),
                    ParkSelectOption(label: '上海', value: 'shanghai'),
                    ParkSelectOption(label: '广州', value: 'guangzhou'),
                  ],
                  onSearch: (String v) => setState(() => log = 'onSearch: \$v'),
                  onClear: () => setState(() => log = 'onClear'),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkSelect 的 validator / onSaved 回调，'
          '点击提交校验是否选择并保存选中的字符串值。'
          ' / Form + GlobalKey demonstrates ParkSelect.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _value;
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkSelect(
            label: '城市',
            hintText: '请选择城市',
            items: const <ParkSelectOption>[
              ParkSelectOption(label: '北京', value: 'beijing'),
              ParkSelectOption(label: '上海', value: 'shanghai'),
              ParkSelectOption(label: '广州', value: 'guangzhou'),
            ],
            value: _value,
            validator: (String? v) => (v == null || v.isEmpty) ? '请选择城市' : null,
            onSaved: (String? v) => _saved = v,
            onChanged: (String? v) => setState(() => _value = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkSelectFormDemo(),
    ),
    // ── ParkSelect: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中值实时同步到 model。'
          ' / ParkBindingService bindKey demo: selection syncs to model in real time.',
      code: '''
final service = ParkBindingService({'city': 'beijing'});

ParkSelect(
  label: '城市',
  bindKey: 'city',
  bindingService: service,
  items: [
    ParkSelectOption(label: '北京', value: 'beijing'),
    ParkSelectOption(label: '上海', value: 'shanghai'),
    ParkSelectOption(label: '广州', value: 'guangzhou'),
  ],
)''',
      builder: (BuildContext context) => _ParkSelectBindingDemo(),
    ),
    // ── ParkSelect: ParkForm 示例 ──
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
      fieldType: ParkFieldType.select,
      labelName: '城市',
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
          formKey: 'park_select_dynamic_form_demo',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_city',
              fieldType: ParkFieldType.select,
              labelName: '城市',
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
`select`（下拉选择，支持单选/多选）。

### 适用场景
- 城市、分类等选项较多的选择字段。
- 远程搜索、分组、多选（fieldControl=multi）等复杂选择。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `select` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `fieldControl` | `field_control` | 子类型：`multi` 多选，默认单选 | 否 |
| `dataSourceType` | `data_source_type` | 选项来源：staticOptions/enumSource/dict/api | 否 |
| `dataSourceKey` | `data_source_key` | 数据源键 | 否 |
| `dataSourceParams` | `data_source_params` | 数据源参数，可引用其他字段（\u{24}form.xxx） | 否 |
| `options` | `options` | 静态选项列表 | 否 |

### 最小可用示例
```dart
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
```

### 进阶技巧
- 多选：将 `fieldControl` 设为 `multi`，提交值为逗号分隔或列表。
- 远程选项：`dataSourceType: api` + `dataSourceKey` 指向接口；依赖字段变化时用 `dataSourceParams` 传参（值可写 `\u{24}form.xxx` 引用父字段）。
- 联动：`reloadOptions` 动作在依赖变化后刷新选项列表。''',
);

class _ParkSelectFormDemo extends StatefulWidget {
  @override
  State<_ParkSelectFormDemo> createState() => _ParkSelectFormDemoState();
}

class _ParkSelectFormDemoState extends State<_ParkSelectFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _value;
  String? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkSelect(
            label: '城市',
            hintText: '请选择城市',
            items: const <ParkSelectOption>[
              ParkSelectOption(label: '北京', value: 'beijing'),
              ParkSelectOption(label: '上海', value: 'shanghai'),
              ParkSelectOption(label: '广州', value: 'guangzhou'),
            ],
            value: _value,
            validator: (String? v) => (v == null || v.isEmpty) ? '请选择城市' : null,
            onSaved: (String? v) => _saved = v,
            onChanged: (String? v) => setState(() => _value = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText('已保存: ' + _saved!, preset: ParkTextPreset.bodySmall),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ParkDatePicker
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDatePickerSpec = ParkComponentSpec(
  name: 'ParkDatePicker',
  title: '日期选择器',
  category: 'input',
  description:
      '基于 FormField<DateTime> 封装的日期选择器，点击输入框弹出底部面板，'
      '使用 CupertinoDatePicker 进行日期/时间选择。支持 date / time / dateTime / yearMonth 四种模式，'
      '支持快捷选项、自定义格式、动态禁用日期、尺寸切换等。',
  icon: Icons.calendar_month_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '当前选中日期 / Currently selected date',
    ),
    ParkPropertyDef(
      name: 'firstDate',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '可选最早日期 / Earliest selectable date',
    ),
    ParkPropertyDef(
      name: 'lastDate',
      type: 'DateTime?',
      defaultVal: 'null',
      description: '可选最晚日期 / Latest selectable date',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkDatePickerMode',
      defaultVal: 'ParkDatePickerMode.date',
      description: '选择器模式：date / time / dateTime / yearMonth / Mode',
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String?',
      defaultVal: 'null',
      description: '占位提示文字 / Placeholder hint',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '输入框上方标签文字 / Label above field',
    ),
    ParkPropertyDef(
      name: 'shortcuts',
      type: 'List<ParkDatePickerShortcut>?',
      defaultVal: 'null',
      description:
          '快捷选项列表（如「今天」「近 7 天」等） / Quick-pick shortcuts (today, last 7 days)',
    ),
    ParkPropertyDef(
      name: 'format',
      type: 'String?',
      defaultVal: 'null',
      description:
          '自定义日期格式字符串（如 yyyy/MM/dd），支持 yyyy/MM/dd/HH/mm/ss 占位符 / Custom date format string',
    ),
    ParkPropertyDef(
      name: 'disabledDate',
      type: 'bool Function(DateTime)?',
      defaultVal: 'null',
      description:
          '动态禁用日期回调，返回 true 的日期不可选 / Disable specific dates dynamically',
    ),
    ParkPropertyDef(
      name: 'clearable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示清除按钮 / Show clear button',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkDatePickerSize',
      defaultVal: 'ParkDatePickerSize.medium',
      description: '选择器尺寸：small / medium / large / Size',
    ),
    ParkPropertyDef(
      name: 'status',
      type: 'ParkInputStatus?',
      defaultVal: 'null',
      description:
          '输入框状态（error / warning / success） / Field status (error/warning/success)',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示边框 / Bordered',
    ),
    ParkPropertyDef(
      name: 'suffixIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义后缀图标，替换默认日历图标 / Custom suffix icon',
    ),
    ParkPropertyDef(
      name: 'allowEmpty',
      type: 'bool',
      defaultVal: 'false',
      description: '是否允许清空日期为 null / Allow clearing to null',
    ),
    ParkPropertyDef(
      name: 'locale',
      type: 'Locale?',
      defaultVal: 'null',
      description: '本地化设置（影响日期选择器的语言和格式） / Localization (language/format)',
    ),
    ParkPropertyDef(
      name: 'showTime',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否显示时间选择面板（dateTime 模式的快捷方式） / Show time panel (dateTime shortcut)',
    ),
    ParkPropertyDef(
      name: 'presets',
      type: 'Map<String, DateTime>?',
      defaultVal: 'null',
      description: '预设快捷日期（key 为显示文字，value 为日期值） / Preset quick dates',
    ),
    ParkPropertyDef(
      name: 'presetItems',
      type: 'List<ParkDatePreset>?',
      defaultVal: 'null',
      description: '预设快捷项列表（使用 ParkDatePreset 构建，支持回调闭包） / Preset items (supports closures)',
    ),
    ParkPropertyDef(
      name: 'renderExtraFooter',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义底部 footer 组件，渲染在日期选择面板确认按钮下方 / Custom extra footer widget below the confirm button',
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
      name: 'onChanged',
      signature: 'ValueChanged<DateTime?>?',
      description: '日期变更回调（清除时传入 null） / Called on date change (null on clear)',
    ),
    ParkEventDef(
      name: 'onClear',
      signature: 'VoidCallback?',
      description: '清除日期时的回调 / Called on clear',
    ),
    ParkEventDef(
      name: 'validator',
      signature: 'FormFieldValidator<DateTime>?',
      description: '表单校验器 / Form validator',
    ),
    ParkEventDef(
      name: 'onSaved',
      signature: 'FormFieldSetter<DateTime>?',
      description: '表单保存回调 / Form save callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkDatePicker(
  label: '出生日期',
  hintText: '请选择日期',
  mode: ParkDatePickerMode.date,
  onChanged: (dt) => print(dt),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要用户选择日期或时间时 / Pick a date or time
- 生日、预约日期、会议时间等场景 / Birthday, booking, meeting

## 使用建议 / Usage tips
- date 模式选择年月日，time 模式选择时分 / date = y/m/d; time = h/m
- dateTime 模式同时选择日期和时间 / dateTime combines both
- yearMonth 模式仅选择年月（入职月份、账单周期等） / yearMonth for month-only
- 通过 firstDate/lastDate 限制可选日期范围 / Constrain range with first/lastDate
- 搭配 ParkForm 使用可自动收集日期值 / Auto-collect with ParkForm
- shortcuts 提供快捷选项（今天、近 7 天等） / Quick-pick shortcuts
- clearable + allowEmpty 允许清空日期 / clearable + allowEmpty to reset

## 搭配推荐 / Compose with
- 搭配 ParkForm 做日期表单 / Pair with ParkForm
- 搭配 ParkCalendar 做日程展示 / Pair with ParkCalendar
- 搭配 ParkInput 做混合表单 / Pair with ParkInput

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG DatePicker / RangePicker：value / format / disabledDate / allowClear / showTime / presets / picker(year/month/date) / onChange；对标 `showTime` 即 park `showTime`，`disabledDate` 同名，`presets` 即 park `presets`。
- TDesign Flutter DatePicker：value / mode / format / enablePreviousDate / onConfirm；移动端用底部弹层，无原生 `presets`/`shortcuts`。
- park DatePicker 覆盖二者：date/time/dateTime/yearMonth 四模式、`shortcuts` 快捷项、`format` 自定义、`disabledDate` 动态禁用、`clearable`+`allowEmpty` 清空、`size` 三档、`bindKey` 绑定。
### 示例 / Examples
- 对标 Ant `<DatePicker showTime format="YYYY-MM-DD HH:mm" />` → park `ParkDatePicker(mode: ParkDatePickerMode.dateTime, format: 'yyyy/MM/dd HH:mm')`。
- 对标 Ant `disabledDate={(d)=>...}` → park `disabledDate: (d) => ...`。
- 范围选择：Ant `RangePicker` ≈ park `ParkCalendar(mode: range)` 或组合两个 `ParkDatePicker`。
### 属性 / Props
- 差异点：park `shortcuts` 是 Ant `presets` 的等效移动端快捷能力；park `yearMonth` 模式对标 Ant `picker="month"`；park `bindKey` 是表单绑定独有。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec `environment.sdk` 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '日期选择',
      description: '默认 date 模式，选择年月日',
      code: '''
ParkDatePicker(
  label: '出生日期',
  hintText: '请选择日期',
  mode: ParkDatePickerMode.date,
  onChanged: (dt) => print(dt),
)
''',
      builder: (BuildContext context) => ParkDatePicker(
        label: '出生日期',
        hintText: '请选择日期',
        mode: ParkDatePickerMode.date,
        onChanged: (DateTime? dt) {},
      ),
    ),
    ParkDemoScenario(
      title: '时间选择',
      description: '使用 time 模式选择时分',
      code: '''
ParkDatePicker(
  label: '会议时间',
  hintText: '请选择时间',
  mode: ParkDatePickerMode.time,
  value: DateTime(2025, 1, 1, 14, 30),
  onChanged: (dt) => print(dt),
)
''',
      builder: (BuildContext context) => ParkDatePicker(
        label: '会议时间',
        hintText: '请选择时间',
        mode: ParkDatePickerMode.time,
        value: DateTime(2025, 1, 1, 14, 30),
        onChanged: (DateTime? dt) {},
      ),
    ),
    ParkDemoScenario(
      title: '日期+时间',
      description: '使用 dateTime 模式同时选择日期和时间',
      code: '''
ParkDatePicker(
  label: '出发时间',
  hintText: '请选择日期和时间',
  mode: ParkDatePickerMode.dateTime,
  onChanged: (dt) => print(dt),
)
''',
      builder: (BuildContext context) => ParkDatePicker(
        label: '出发时间',
        hintText: '请选择日期和时间',
        mode: ParkDatePickerMode.dateTime,
        onChanged: (DateTime? dt) {},
      ),
    ),
    ParkDemoScenario(
      title: '年月选择',
      description: '使用 yearMonth 模式仅选择年月',
      code: '''
ParkDatePicker(
  label: '入职月份',
  hintText: '请选择年月',
  mode: ParkDatePickerMode.yearMonth,
  value: DateTime(2024, 6),
  onChanged: (dt) => print(dt),
)
''',
      builder: (BuildContext context) => ParkDatePicker(
        label: '入职月份',
        hintText: '请选择年月',
        mode: ParkDatePickerMode.yearMonth,
        value: DateTime(2024, 6),
        onChanged: (DateTime? dt) {},
      ),
    ),
    ParkDemoScenario(
      title: '限制日期范围',
      description: '通过 firstDate 和 lastDate 限制可选范围',
      code: '''
ParkDatePicker(
  label: '预约日期',
  hintText: '请选择（限近 30 天）',
  mode: ParkDatePickerMode.date,
  firstDate: DateTime(2025, 1, 1),
  lastDate: DateTime(2025, 12, 31),
  onChanged: (dt) => print(dt),
)
''',
      builder: (BuildContext context) => ParkDatePicker(
        label: '预约日期',
        hintText: '请选择（限近 30 天）',
        mode: ParkDatePickerMode.date,
        firstDate: DateTime(2025, 1, 1),
        lastDate: DateTime(2025, 12, 31),
        onChanged: (DateTime? dt) {},
      ),
    ),
    ParkDemoScenario(
      title: '可清除和尺寸',
      description: 'clearable 显示清除按钮；size 切换选择器尺寸',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkDatePicker(
      label: '可清除',
      hintText: '选择后可清除',
      clearable: true,
      allowEmpty: true,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkDatePicker(
      label: '小尺寸',
      hintText: 'small',
      size: ParkDatePickerSize.small,
    ),
    SizedBox(height: _kSpacing.sm),
    ParkDatePicker(
      label: '大尺寸',
      hintText: 'large',
      size: ParkDatePickerSize.large,
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkDatePicker(
            label: '可清除',
            hintText: '选择后可清除',
            clearable: true,
            allowEmpty: true,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkDatePicker(
            label: '小尺寸',
            hintText: 'small',
            size: ParkDatePickerSize.small,
          ),
          SizedBox(height: _kSpacing.sm),
          ParkDatePicker(
            label: '大尺寸',
            hintText: 'large',
            size: ParkDatePickerSize.large,
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互：实时回显选中日期',
      description:
          '通过 StatefulBuilder + onChanged 实时回显选中日期，演示 ParkDatePicker 的 onChanged 事件。'
          ' / StatefulBuilder + onChanged echoes the selected date live, demonstrating ParkDatePicker.onChanged.',
      code: '''
StatefulBuilder(
  builder: (ctx, setState) {
    DateTime? d;
    final label = d == null ? '未选择' : '\${d.year}-\${d.month}-\${d.day}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkDatePicker(
          hintText: '请选择日期',
          onChanged: (dt) => setState(() => d = dt),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('已选：\$label', preset: ParkTextPreset.bodySmall),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        DateTime? d;
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            final String label = d == null
                ? '未选择'
                : '${d!.year}-${d!.month}-${d!.day}';
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkDatePicker(
                  hintText: '请选择日期',
                  onChanged: (DateTime? dt) => setState(() => d = dt),
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('已选：$label', preset: ParkTextPreset.bodySmall),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '表单：校验与保存',
      description:
          '通过 Form + GlobalKey 演示 ParkDatePicker 的 validator / onSaved 回调，'
          '点击提交校验是否选择日期并保存 DateTime 值。'
          ' / Form + GlobalKey demonstrates ParkDatePicker.validator and onSaved.',
      code: '''
class _Demo extends StatefulWidget {
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _value;
  DateTime? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkDatePicker(
            label: '出生日期',
            hintText: '请选择日期',
            mode: ParkDatePickerMode.date,
            value: _value,
            validator: (DateTime? v) => (v == null) ? '请选择日期' : null,
            onSaved: (DateTime? v) => _saved = v,
            onChanged: (DateTime? v) => setState(() => _value = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null)
            ...<Widget>[
              SizedBox(height: _kSpacing.sm),
              ParkText('已保存: ' + _saved!.toString(), preset: ParkTextPreset.bodySmall),
            ],
        ],
      ),
    );
  }
}''',
      builder: (BuildContext context) => _ParkDatePickerFormDemo(),
    ),
    // ── ParkDatePicker: ParkBinding 示例 ──
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description:
          '通过 bindKey + bindingService 实现双向绑定，选中日期实时同步到 model。'
          ' / ParkBindingService bindKey demo: selected date syncs to model in real time.',
      code: '''
final service = ParkBindingService({'birthday': DateTime(2000, 1, 1)});

ParkDatePicker(
  label: '出生日期',
  bindKey: 'birthday',
  bindingService: service,
  mode: ParkDatePickerMode.date,
)''',
      builder: (BuildContext context) => _ParkDatePickerBindingDemo(),
    ),
    // ── ParkDatePicker: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm Schema 模式）',
      description:
          '在 ParkForm 中以 schema 配置使用。'
          ' / ParkForm schema usage.',
      code: '''
ParkForm(
  schemas: [
    ParkFormFieldSchema(
      fieldId: 'f_birthday',
      fieldType: ParkFieldType.date,
      labelName: '出生日期',
      fieldName: 'birthday',
      isRequired: true,
      fieldPrompt: '请选择日期',
    ),
  ],
  onSubmit: (values) => print(values),
)
''',
      builder: (BuildContext context) => ParkForm(
        schema: const ParkFormSchema(
          formKey: 'park_date_picker_dynamic_form_demo',
          fields: [
            ParkFormFieldSchema(
              fieldId: 'f_birthday',
              fieldType: ParkFieldType.date,
              labelName: '出生日期',
              fieldName: 'birthday',
              isRequired: true,
              fieldPrompt: '请选择日期',
            ),
          ],
        ),
        onSubmit: (Map<String, dynamic> values) {},
      ),
    ),
  ],
  dynamicFormSchemaDoc: '''### 对应字段类型
`date`（日期选择）。

### 适用场景
- 生日、预约日期、账单周期等日期/时间字段。
- 支持 date / time / dateTime / 区间等模式。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `date` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认日期（字符串或时间戳） | 否 |
| `ext` | `ext` | 业务扩展：日期格式 `format`、模式 `mode`、范围 `firstDate/lastDate` 等 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_birth',
  fieldType: ParkFieldType.date,
  labelName: '出生日期',
  fieldName: 'birthday',
  isRequired: true,
  ext: {'mode': 'date'},
)
```

### 进阶技巧
- 模式与格式经 `ext` 承载：如 `ext['mode']='dateTime'`、`ext['format']='yyyy/MM/dd'`。
- 范围限制：`ext['firstDate']` / `ext['lastDate']`。
- 联动：`disabledRule` 在未满足前置条件时禁用日期选择。''',
);

class _ParkDatePickerFormDemo extends StatefulWidget {
  @override
  State<_ParkDatePickerFormDemo> createState() =>
      _ParkDatePickerFormDemoState();
}

class _ParkDatePickerFormDemoState extends State<_ParkDatePickerFormDemo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _value;
  DateTime? _saved;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ParkDatePicker(
            label: '出生日期',
            hintText: '请选择日期',
            mode: ParkDatePickerMode.date,
            value: _value,
            validator: (DateTime? v) => (v == null) ? '请选择日期' : null,
            onSaved: (DateTime? v) => _saved = v,
            onChanged: (DateTime? v) => setState(() => _value = v),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                setState(() {});
              }
            },
            child: const ParkText('提交'),
          ),
          if (_saved != null) ...<Widget>[
            SizedBox(height: _kSpacing.sm),
            ParkText(
              '已保存: ' + _saved!.toString(),
              preset: ParkTextPreset.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Demo 辅助 Widget — ParkSearch cacheService 示例
// =============================================================================

/// ParkSearchCache 的内存实现（demo 用，避免 shared_preferences 依赖）
class _DemoSearchCache implements ParkSearchCache {
  final Map<String, List<String>> _store = <String, List<String>>{};

  @override
  Future<List<String>> loadHistory(String scope) async {
    return List<String>.from(_store[scope] ?? []);
  }

  @override
  Future<void> saveHistory(String scope, String keyword) async {
    final list = List<String>.from(_store[scope] ?? []);
    list.remove(keyword);
    list.insert(0, keyword);
    _store[scope] = list.take(20).toList();
  }

  @override
  Future<void> removeHistory(String scope, String keyword) async {
    final list = List<String>.from(_store[scope] ?? []);
    list.remove(keyword);
    _store[scope] = list;
  }

  @override
  Future<void> clearHistory(String scope) async {
    _store.remove(scope);
  }
}

/// ParkSearch cacheService demo 页面
class _ParkSearchCacheDemo extends StatefulWidget {
  @override
  State<_ParkSearchCacheDemo> createState() => _ParkSearchCacheDemoState();
}

class _ParkSearchCacheDemoState extends State<_ParkSearchCacheDemo> {
  final _DemoSearchCache _cache = _DemoSearchCache();
  String _lastSearch = '';

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParkSearch(
          hintText: '输入搜索词',
          cacheService: _cache,
          cacheScope: 'demo',
          showCancel: true,
          onSubmitted: (v) => setState(() => _lastSearch = v),
        ),
        SizedBox(height: park.spacing.sm),
        ParkTag(text: '最近搜索: ${_lastSearch.isEmpty ? "无" : _lastSearch}'),
        SizedBox(height: park.spacing.sm),
        ParkText(
          '提示：输入内容后按搜索/回车，再次聚焦搜索框可见历史建议面板。\n'
          '搜索历史保存在内存缓存中（demo 演示用）。',
          preset: ParkTextPreset.caption,
        ),
      ],
    );
  }
}

// ============================================================================
// ParkSelect: ParkBinding 示例
// ============================================================================

class _ParkSelectBindingDemo extends StatefulWidget {
  @override
  State<_ParkSelectBindingDemo> createState() => _ParkSelectBindingDemoState();
}

class _ParkSelectBindingDemoState extends State<_ParkSelectBindingDemo> {
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
        ParkSelect(
          label: '城市',
          bindKey: 'city',
          bindingService: _service,
          items: const <ParkSelectOption>[
            ParkSelectOption(label: '北京', value: 'beijing'),
            ParkSelectOption(label: '上海', value: 'shanghai'),
            ParkSelectOption(label: '广州', value: 'guangzhou'),
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
// ParkDatePicker: ParkBinding 示例
// ============================================================================

class _ParkDatePickerBindingDemo extends StatefulWidget {
  @override
  State<_ParkDatePickerBindingDemo> createState() =>
      _ParkDatePickerBindingDemoState();
}

class _ParkDatePickerBindingDemoState
    extends State<_ParkDatePickerBindingDemo> {
  late final ParkBindingService _service;

  @override
  void initState() {
    super.initState();
    _service = ParkBindingService(<String, dynamic>{
      'birthday': DateTime(2000, 1, 1),
    });
    _service.watchEffect(() {
      _service.getValue<DateTime>('birthday');
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
        ParkDatePicker(
          label: '出生日期',
          bindKey: 'birthday',
          bindingService: _service,
          mode: ParkDatePickerMode.date,
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
