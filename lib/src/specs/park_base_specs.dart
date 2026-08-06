// Park 基础组件规格 — Batch 1（完善版 / P2 B1）
//
// 覆盖：ParkButton / ParkText / ParkIcon / ParkDivider / ParkFab / ParkLink
// 约定：
//  - 每个组件的 properties 枚举其全部公开构造参数；
//  - 每个功能 / 形态 / 状态 / 变体均对应一个 demo（code 与 builder 完全一致）；
//  - 禁止裸字面量：颜色用 ParkColors.*，间距用 ParkSpacing.* / 具名常量，
//    粗细用具名常量，字号用 ParkTypography.*，杜绝魔法变量；
//  - 双语（中文为主、英文并列）：每条属性 / 事件 / 方法注释均为中英双语；
//  - 外部对标：每个组件 guide 内注明与 Ant Design NG（ng.ant.design）&
//    TDesign Flutter（tdesign.tencent.com/flutter）的功能 / 示例 / 属性差异。
//  - SDK 下限：与 pubspec 一致（sdk: ^3.11.5），不下调。
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

// ===========================================================================
// 命名令牌常量（对齐 ParkColors / ParkSpacing / ParkTypography 设计令牌，
// 杜绝裸字面量 / 魔法变量）
// ===========================================================================
final ParkColors _kColors = ParkColors.light();
final ParkSpacing _kSpacing = ParkSpacing.defaults();
final ParkTypography _kTypography = ParkTypography.defaults();

/// 分割线细 / 中 / 粗三种粗细（像素）。
const double _kThicknessThin = 1.0;
const double _kThicknessMedium = 2.0;
const double _kThicknessThick = 3.0;

/// 文本截断演示宽度。
const double _kTruncateWidth = 200.0;

/// 令牌展示辅助数据类。
class TokenItem {
  final String name;
  final double value;
  final String description;
  const TokenItem(this.name, this.value, this.description);
}

/// 令牌展示卡片构建器。
Widget _buildTokenCard({
  required String title,
  required List<TokenItem> items,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkText(title, preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.blue.shade700,
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
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        )),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// ParkButtonGroup
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkButtonGroupSpec = ParkComponentSpec(
  name: 'ParkButtonGroup',
  title: '按钮组 / Button Group',
  category: 'base',
  description:
      '将多个 ParkButton 组合为一个整体，支持 joined（紧密贴合，首尾保留圆角）'
      '与 equal（均分可用空间）两种模式，可水平或垂直排列。'
      ' / Groups multiple ParkButtons into one unit, with joined (tight, rounded ends) '
      'and equal (evenly split space) modes, in horizontal or vertical direction.',
  icon: Icons.dataset_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      required: true,
      description: '按钮列表 / The list of buttons',
    ),
    ParkPropertyDef(
      name: 'direction',
      type: 'Axis',
      defaultVal: 'Axis.horizontal',
      description: '排列方向：horizontal / vertical / Layout direction',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkButtonGroupMode',
      defaultVal: 'ParkButtonGroupMode.joined',
      description: '组模式：joined（贴合）/ equal（均分）/ Group mode',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkButtonGroup(
  children: [
    ParkButton(child: Text('左'), onPressed: () {}),
    ParkButton(child: Text('中'), onPressed: () {}),
    ParkButton(child: Text('右'), onPressed: () {}),
  ],
)
''',
  guide: '''
## 何时使用 / When to use
- 一组语义相关的操作按钮（如 通过 / 驳回 / 转办）/ A set of related actions
- 需要按钮在视觉上连成一体 / Buttons that should read as a single unit

## 使用建议 / Usage tips
- joined 模式按钮间无间隙，首尾保留圆角 / joined: no gap, rounded ends
- equal 模式用 Expanded 均分宽度，适合等宽操作栏 / equal: evenly split width
- 通过 direction 切换水平 / 垂直排列 / Switch direction for vertical stacking
- 外部对标：Ant Design 与 TDesign 的 Button.Group 均提供类似贴合 / 均分能力。
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '贴合模式（默认）',
      description: 'joined 模式：按钮紧密贴合，仅首尾保留圆角。 / joined: tight, rounded ends only.',
      code: '''
ParkButtonGroup(
  children: [
    ParkButton(child: Text('左'), onPressed: () {}),
    ParkButton(child: Text('中'), onPressed: () {}),
    ParkButton(child: Text('右'), onPressed: () {}),
  ],
)''',
      builder: (BuildContext context) => ParkButtonGroup(
        children: <Widget>[
          ParkButton(child: const Text('左'), onPressed: () {}),
          ParkButton(child: const Text('中'), onPressed: () {}),
          ParkButton(child: const Text('右'), onPressed: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '均分模式',
      description: 'equal 模式：三个按钮均分可用宽度。 / equal: three buttons split width evenly.',
      code: '''
ParkButtonGroup(
  mode: ParkButtonGroupMode.equal,
  children: [
    ParkButton(variant: ParkButtonVariant.primary, child: Text('通过')),
    ParkButton(child: Text('驳回')),
    ParkButton(child: Text('转办')),
  ],
)''',
      builder: (BuildContext context) => ParkButtonGroup(
        mode: ParkButtonGroupMode.equal,
        children: <Widget>[
          ParkButton(variant: ParkButtonVariant.primary, child: const Text('通过')),
          ParkButton(child: const Text('驳回')),
          ParkButton(child: const Text('转办')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '垂直排列',
      description: 'direction 设为 vertical，按钮垂直贴合。 / vertical direction stacks buttons.',
      code: '''
ParkButtonGroup(
  direction: Axis.vertical,
  children: [
    ParkButton(child: Text('上'), onPressed: () {}),
    ParkButton(child: Text('中'), onPressed: () {}),
    ParkButton(child: Text('下'), onPressed: () {}),
  ],
)''',
      builder: (BuildContext context) => ParkButtonGroup(
        direction: Axis.vertical,
        children: <Widget>[
          ParkButton(child: const Text('上'), onPressed: () {}),
          ParkButton(child: const Text('中'), onPressed: () {}),
          ParkButton(child: const Text('下'), onPressed: () {}),
        ],
      ),
    ),
  ],
);

/// 基础组件规格字典（11 个组件 / Base components (11)）。
Map<String, ParkComponentSpec> get parkBaseSpecs =>
    <String, ParkComponentSpec>{
      'ParkButton': _parkButtonSpec,
      'ParkText': _parkTextSpec,
      'ParkIcon': _parkIconSpec,
      'ParkDivider': _parkDividerSpec,
      'ParkFab': _parkFabSpec,
      'ParkLink': _parkLinkSpec,
      'ParkInkWell': _parkInkWellSpec,
      'ParkButtonGroup': _parkButtonGroupSpec,
      'ParkFloatButton': _parkFloatButtonSpec,
      'ParkTitle': _parkTitleSpec,
      'ParkParagraph': _parkParagraphSpec,
      'ParkTypography': _parkTypographySpec,
    };

// ---------------------------------------------------------------------------
// ParkButton
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkButtonSpec = ParkComponentSpec(
  name: 'ParkButton',
  title: '按钮 / Button',
  category: 'base',
  description:
      '支持 6 种变体（primary / secondary / text / link / ghost / danger）、'
      '3 种尺寸（small / medium / large）、loading 与 disabled 状态，'
      '并内置图标、角标、虚线边框、渐变、后缀、块级等扩展能力。'
      ' / Supports 6 variants (primary / secondary / text / link / ghost / danger), '
      '3 sizes (small / medium / large), loading & disabled states, plus icons, '
      'badges, dashed border, gradient, suffix and block layout extensions.',
  icon: Icons.smart_button_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'child',
      type: 'Widget?',
      defaultVal: 'null',
      description: '按钮内容，通常为 Text 组件 / Button content, usually a Text widget',
    ),
    ParkPropertyDef(
      name: 'variant',
      type: 'ParkButtonVariant',
      defaultVal: 'ParkButtonVariant.secondary',
      description:
          '按钮变体：primary / secondary / text / link / ghost / danger / Button variant',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkButtonSize',
      defaultVal: 'ParkButtonSize.medium',
      description: '按钮尺寸：small (28px) / medium (36px) / large (44px) / Button size',
    ),
    ParkPropertyDef(
      name: 'shape',
      type: 'ParkButtonShape',
      defaultVal: 'ParkButtonShape.rectangle',
      description:
          '按钮形状：rectangle / round（胶囊）/ circle（圆形） / Button shape: rectangle / round (pill) / circle',
    ),
    ParkPropertyDef(
      name: 'block',
      type: 'bool',
      defaultVal: 'false',
      description: '是否占满父容器宽度 / Whether to fill the parent width',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否处于 loading 状态（显示转圈指示器并禁点） / Whether in loading state (spinner + disabled tap)',
    ),
    ParkPropertyDef(
      name: 'debounceDuration',
      type: 'Duration?',
      defaultVal: 'null',
      description: '防抖间隔（防止重复点击） / Debounce interval (prevents repeated taps)',
    ),
    ParkPropertyDef(
      name: 'loadingIndicator',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '自定义 loading 指示器（默认显示转圈） / Custom loading indicator (default: spinner)',
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '前置图标 Widget / Leading icon widget',
    ),
    ParkPropertyDef(
      name: 'style',
      type: 'ParkButtonStyle?',
      defaultVal: 'null',
      description:
          '自定义样式，覆盖变体默认样式（颜色 / 字号 / 圆角 / 阴影等） / Custom style overriding variant defaults',
    ),
    ParkPropertyDef(
      name: 'iconPosition',
      type: 'ParkIconPosition',
      defaultVal: 'ParkIconPosition.start',
      description:
          '图标位置：start（文字前方）/ end（文字后方） / Icon position: start (before text) / end (after text)',
    ),
    ParkPropertyDef(
      name: 'dashed',
      type: 'bool',
      defaultVal: 'false',
      description: '是否使用虚线边框 / Whether to use a dashed border',
    ),
    ParkPropertyDef(
      name: 'gradient',
      type: 'Gradient?',
      defaultVal: 'null',
      description:
          '渐变背景（设置后覆盖变体背景色） / Gradient background (overrides variant bg when set)',
    ),
    ParkPropertyDef(
      name: 'badge',
      type: 'int?',
      defaultVal: 'null',
      description:
          '角标数字（显示在按钮右上角，> 99 显示 99+） / Badge count at top-right (> 99 shows 99+)',
    ),
    ParkPropertyDef(
      name: 'badgeDot',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否显示红点角标（优先级高于 badge 数字显示） / Red-dot badge (takes priority over numeric badge)',
    ),
    ParkPropertyDef(
      name: 'danger',
      type: 'bool',
      defaultVal: 'false',
      description:
          '危险模式修饰符：为任意变体应用危险色（等价于 variant: danger） / Danger modifier: applies danger color to any variant',
    ),
    ParkPropertyDef(
      name: 'href',
      type: 'String?',
      defaultVal: 'null',
      description:
          '链接地址，设置后按钮点击意图触发导航（通过 onPressed 回调处理） / Link URL; click triggers navigation intent (via onPressed)',
    ),
    ParkPropertyDef(
      name: 'htmlType',
      type: 'ParkButtonHtmlType',
      defaultVal: 'ParkButtonHtmlType.button',
      description:
          'HTML 按钮类型（主要用于 Web 表单语义，如 submit / reset / button） / HTML button type (web form semantics)',
    ),
    ParkPropertyDef(
      name: 'suffix',
      type: 'Widget?',
      defaultVal: 'null',
      description: '后置组件（显示在文字后方） / Trailing widget (after the text)',
    ),
    ParkPropertyDef(
      name: 'hoverColor',
      type: 'Color?',
      defaultVal: 'null',
      description:
          '自定义悬停颜色（覆盖默认悬停效果） / Custom hover color (overrides default hover)',
    ),
    ParkPropertyDef(
      name: 'cursor',
      type: 'MouseCursor?',
      defaultVal: 'null',
      description:
          '鼠标指针样式（启用时默认为 SystemMouseCursors.click） / Mouse cursor (defaults to click)',
    ),
    ParkPropertyDef(
      name: 'autoInsertSpace',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否对两字中文文本自动插入空格（符合中文排版规范） / Auto-insert space between two-char Chinese text',
    ),
    ParkPropertyDef(
      name: 'ghost',
      type: 'bool',
      defaultVal: 'false',
      description:
          '幽灵模式：透明背景 + 品牌色边框（等价于 variant: ghost 的快捷方式） / Ghost mode: transparent bg + brand border',
    ),
    ParkPropertyDef(
      name: 'iconOnly',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否为纯图标按钮（无文字），影响内边距与最小宽度 / Icon-only (no text); affects padding & min width',
    ),
    ParkPropertyDef(
      name: 'tooltip',
      type: 'String?',
      defaultVal: 'null',
      description:
          '工具提示文本（长按或悬停时显示） / Tooltip text (shown on long-press or hover)',
    ),
    ParkPropertyDef(
      name: 'height',
      type: 'double?',
      defaultVal: 'null',
      description:
          '自定义高度覆盖（px），覆盖由 size 推导的默认高度（small:28 / medium:36 / large:44），'
          '常用于与 ParkInputGroup 内其它控件严格等高 / Custom height override (px); useful for exact alignment in ParkInputGroup',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onPressed',
      signature: 'VoidCallback?',
      description:
          '点击回调，为 null 时按钮进入 disabled 状态 / Tap callback; null disables the button',
    ),
    ParkEventDef(
      name: 'asyncOnPressed',
      signature: 'Future<void> Function()?',
      description:
          '异步点击回调，执行时自动进入 loading 状态，完成后自动恢复 / Async tap; auto-enters loading while running',
    ),
    ParkEventDef(
      name: 'onLongPress',
      signature: 'VoidCallback?',
      description: '长按回调 / Long-press callback',
    ),
    ParkEventDef(
      name: 'onHover',
      signature: 'ValueChanged<bool>?',
      description:
          '悬停状态变化回调（参数为是否处于悬停态） / Hover change callback (bool isHovered)',
    ),
    ParkEventDef(
      name: 'onFocus',
      signature: 'VoidCallback?',
      description: '获取焦点回调 / Focus gained callback',
    ),
    ParkEventDef(
      name: 'onBlur',
      signature: 'VoidCallback?',
      description: '失去焦点回调 / Focus lost callback',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkButton.icon',
      signature:
          'factory ParkButton.icon({required IconData icon, required String label, VoidCallback? onPressed, VoidCallback? onLongPress, ParkButtonVariant variant, ParkButtonSize size, bool block, bool loading, ParkButtonStyle? style, ParkIconPosition iconPosition, bool dashed, Gradient? gradient, int? badge, bool badgeDot, bool danger})',
      description: '便捷工厂构造器：图标 + 文字按钮 / Convenience factory: icon + label button',
    ),
  ],
  basicUsageCode: '''
// 引入 / Import: import 'package:park_ui/park_ui.dart';
ParkButton(
  variant: ParkButtonVariant.primary,
  onPressed: () {},
  child: const Text('提交'),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要触发一个操作时（提交表单、打开弹窗、发起请求等） / Trigger an action (submit, open dialog, request)
- 页面中的主要交互入口 / Primary interaction entry on a page

## 使用建议 / Usage tips
- 主要操作用 primary 变体，次要操作用 secondary / Use primary for primary action, secondary for secondary
- 危险操作（删除等）用 danger 变体或 danger: true 修饰符 / Dangerous ops: danger variant or danger: true
- 同一区域按钮数量不宜超过 3 个，过多时考虑收入菜单 / Keep ≤ 3 buttons per area; else use a menu
- 表单提交按钮使用 block: true 通栏展示 / Form submit: block: true for full width
- 异步操作时设置 asyncOnPressed 或 loading: true 防止重复点击 / Async: asyncOnPressed / loading: true to prevent double-tap
- 需要轻量边框按钮用 ghost: true 或 variant: ghost / Light outline button: ghost: true

## 搭配推荐 / Compose with
- 搭配 ParkDialog 做确认弹窗 / Pair with ParkDialog for confirm
- 搭配 ParkForm 做表单提交 / Pair with ParkForm for submit
- 搭配 ParkLoading 做加载状态反馈 / Pair with ParkLoading for loading feedback

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Button：type(primary/default/dashed/link/text) + size(default/large/small) + loading/disabled/icon/block/ghost/danger + shape(circle/round)。
- TDesign Flutter Button：theme(primary/default/warning/danger) + variant(text/outline) + size + icon + loading + block + ghost。
- park Button 覆盖上述全部能力，并额外提供：badge / badgeDot 角标、gradient 渐变、asyncOnPressed 自动 loading、iconOnly、autoInsertSpace（中文排版自动空格）、debounceDuration 防抖。
### 示例 / Examples
- 对标 Ant `shape="round"` → park `shape: ParkButtonShape.round`；对标 Ant `danger` → park `variant: danger` 或 `danger: true`。
- 对标 TDesign `variant="outline"` → park `variant: ParkButtonVariant.secondary`（描边样式）。
### 属性 / Props
- 差异点：park 的 `asyncOnPressed`（自动 loading）与 `badge`/`badgeDot` 在 Ant NG / TDesign 中需自行包裹实现；park 的 `autoInsertSpace` 是中文场景独有。

## 设计令牌参考 / Design Token Reference
所有颜色、间距、圆角、阴影值均由 Park 设计令牌驱动，详见 `DESIGN_SYSTEM.md`。

| 令牌类别 | 调用方式 | 设计规范章节 |
|---------|---------|-------------|
| 色彩 | `colors.brand` / `colors.textPrimary` / `colors.surface` 等 | 2. 色彩体系 |
| 字体 | `typography.bodySmall` / `typography.weightMedium` 等 | 3. 字体层级 |
| 间距 | `spacing.base` / `spacing.sm` / `spacing.xl` 等 | 4. 间距规则 |
| 圆角 | `radius.sm` / `radius.full` / `radius.md` 等 | 5. 圆角体系 |
| 阴影 | `shadows.sm` / `shadows.md` / `shadows.lg` | 6. 阴影体系 |
| 动效 | `ParkMotion.quick` / `ParkMotion.standard` / `ParkMotion.defaultEasing` | 7. 动效规范 |

- ParkButton 默认高度：small=28px / medium=36px / large=44px
- ParkButton 默认内边距 (medium)：水平 24px、垂直 8px
- ParkButton 默认圆角：`radius.sm` (8px)，round 变体 `radius.full`
- ParkButton 阴影：悬浮时使用 `shadows.sm`

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`（或 pubspec.yaml 添加 `park_ui: ^0.1.0`）
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec environment 一致；正式版本号待维护者确认 / see pubspec `environment.sdk`）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '按钮变体',
      description: '展示 6 种不同 variant 的按钮样式 / 6 variants',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  runSpacing: _kSpacing.sm,
  children: [
    ParkButton(variant: ParkButtonVariant.primary, onPressed: () {}, child: const Text('主要')),
    ParkButton(variant: ParkButtonVariant.secondary, onPressed: () {}, child: const Text('默认')),
    ParkButton(variant: ParkButtonVariant.text, onPressed: () {}, child: const Text('文字')),
    ParkButton(variant: ParkButtonVariant.link, onPressed: () {}, child: const Text('链接')),
    ParkButton(variant: ParkButtonVariant.ghost, onPressed: () {}, child: const Text('幽灵')),
    ParkButton(variant: ParkButtonVariant.danger, onPressed: () {}, child: const Text('危险')),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        runSpacing: _kSpacing.sm,
        children: [
          ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('主要')),
          ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {},
              child: const Text('默认')),
          ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {},
              child: const Text('文字')),
          ParkButton(
              variant: ParkButtonVariant.link,
              onPressed: () {},
              child: const Text('链接')),
          ParkButton(
              variant: ParkButtonVariant.ghost,
              onPressed: () {},
              child: const Text('幽灵')),
          ParkButton(
              variant: ParkButtonVariant.danger,
              onPressed: () {},
              child: const Text('危险')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '按钮尺寸',
      description: '展示 small / medium / large 三种尺寸 / 3 sizes',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkButton(size: ParkButtonSize.small, variant: ParkButtonVariant.primary, onPressed: () {}, child: const Text('小号')),
    ParkButton(size: ParkButtonSize.medium, variant: ParkButtonVariant.primary, onPressed: () {}, child: const Text('中号')),
    ParkButton(size: ParkButtonSize.large, variant: ParkButtonVariant.primary, onPressed: () {}, child: const Text('大号')),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: [
          ParkButton(
              size: ParkButtonSize.small,
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('小号')),
          ParkButton(
              size: ParkButtonSize.medium,
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('中号')),
          ParkButton(
              size: ParkButtonSize.large,
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('大号')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '图标按钮',
      description: '使用 ParkButton.icon 工厂构造带图标的按钮 / icon factory',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkButton.icon(icon: Icons.add, label: '新建', variant: ParkButtonVariant.primary, onPressed: () {}),
    ParkButton.icon(icon: Icons.delete_outline, label: '删除', variant: ParkButtonVariant.danger, onPressed: () {}),
    ParkButton.icon(icon: Icons.edit_outlined, label: '编辑', variant: ParkButtonVariant.ghost, onPressed: () {}),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: [
          ParkButton.icon(
            icon: Icons.add,
            label: '新建',
            variant: ParkButtonVariant.primary,
            onPressed: () {},
          ),
          ParkButton.icon(
            icon: Icons.delete_outline,
            label: '删除',
            variant: ParkButtonVariant.danger,
            onPressed: () {},
          ),
          ParkButton.icon(
            icon: Icons.edit_outlined,
            label: '编辑',
            variant: ParkButtonVariant.ghost,
            onPressed: () {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '加载与禁用',
      description:
          '展示 loading 状态和 disabled 状态（onPressed 为 null） / loading & disabled',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkButton(variant: ParkButtonVariant.primary, loading: true, onPressed: () {}, child: const Text('加载中')),
    ParkButton(variant: ParkButtonVariant.primary, onPressed: null, child: const Text('禁用')),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: [
          ParkButton(
            variant: ParkButtonVariant.primary,
            loading: true,
            onPressed: () {},
            child: const Text('加载中'),
          ),
          ParkButton(
            variant: ParkButtonVariant.primary,
            onPressed: null,
            child: const Text('禁用'),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '通栏与形状',
      description: 'block 通栏、round 胶囊、circle 圆形 / block, round, circle',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkButton(block: true, variant: ParkButtonVariant.primary, onPressed: () {}, child: const Text('通栏按钮')),
    SizedBox(height: _kSpacing.sm),
    ParkButton(shape: ParkButtonShape.round, variant: ParkButtonVariant.primary, onPressed: () {}, child: const Text('胶囊按钮')),
    SizedBox(height: _kSpacing.sm),
    ParkButton(shape: ParkButtonShape.circle, variant: ParkButtonVariant.primary, onPressed: () {}, child: const Icon(Icons.favorite)),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkButton(
            block: true,
            variant: ParkButtonVariant.primary,
            onPressed: () {},
            child: const Text('通栏按钮'),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            shape: ParkButtonShape.round,
            variant: ParkButtonVariant.primary,
            onPressed: () {},
            child: const Text('胶囊按钮'),
          ),
          SizedBox(height: _kSpacing.sm),
          ParkButton(
            shape: ParkButtonShape.circle,
            variant: ParkButtonVariant.primary,
            onPressed: () {},
            child: const Icon(Icons.favorite),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '危险与虚线边框',
      description: 'danger 修饰符应用危险色；dashed 渲染虚线边框；ghost 幽灵按钮 / danger, dashed, ghost',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkButton(danger: true, onPressed: () {}, child: const Text('危险修饰')),
    ParkButton(variant: ParkButtonVariant.primary, dashed: true, onPressed: () {}, child: const Text('虚线边框')),
    ParkButton(ghost: true, onPressed: () {}, child: const Text('幽灵')),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: [
          ParkButton(
            danger: true,
            onPressed: () {},
            child: const Text('危险修饰'),
          ),
          ParkButton(
            variant: ParkButtonVariant.primary,
            dashed: true,
            onPressed: () {},
            child: const Text('虚线边框'),
          ),
          ParkButton(
            ghost: true,
            onPressed: () {},
            child: const Text('幽灵'),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '角标',
      description: 'badge 数字角标与 badgeDot 红点角标 / badge & badgeDot',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkButton(variant: ParkButtonVariant.primary, badge: 8, onPressed: () {}, child: const Text('消息')),
    ParkButton(variant: ParkButtonVariant.primary, badge: 99, onPressed: () {}, child: const Text('上限99+')),
    ParkButton(variant: ParkButtonVariant.primary, badgeDot: true, onPressed: () {}, child: const Text('红点')),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: [
          ParkButton(
            variant: ParkButtonVariant.primary,
            badge: 8,
            onPressed: () {},
            child: const Text('消息'),
          ),
          ParkButton(
            variant: ParkButtonVariant.primary,
            badge: 99,
            onPressed: () {},
            child: const Text('上限99+'),
          ),
          ParkButton(
            variant: ParkButtonVariant.primary,
            badgeDot: true,
            onPressed: () {},
            child: const Text('红点'),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '渐变与后缀',
      description: 'gradient 渐变背景；icon + suffix 组合并置后图标位置 / gradient & suffix',
      code: '''
Wrap(
  spacing: _kSpacing.sm,
  children: [
    ParkButton(
      variant: ParkButtonVariant.primary,
      gradient: LinearGradient(colors: [_kColors.brand, _kColors.brandDark]),
      onPressed: () {},
      child: const Text('渐变'),
    ),
    ParkButton(
      variant: ParkButtonVariant.primary,
      icon: Icon(Icons.download),
      suffix: const Icon(Icons.arrow_forward),
      iconPosition: ParkIconPosition.end,
      onPressed: () {},
      child: const Text('后缀图标'),
    ),
  ],
)
''',
      builder: (BuildContext context) => Wrap(
        spacing: _kSpacing.sm,
        children: [
          ParkButton(
            variant: ParkButtonVariant.primary,
            gradient: LinearGradient(
                colors: <Color>[_kColors.brand, _kColors.brandDark]),
            onPressed: () {},
            child: const Text('渐变'),
          ),
          ParkButton(
            variant: ParkButtonVariant.primary,
            icon: const Icon(Icons.download),
            suffix: const Icon(Icons.arrow_forward),
            iconPosition: ParkIconPosition.end,
            onPressed: () {},
            child: const Text('后缀图标'),
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '交互事件（完整事件演示）',
      description:
          '分别演示 onPressed / asyncOnPressed / onLongPress / onHover / onFocus / onBlur 六个回调 / all 6 events',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    String log = '等待交互';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkButton(
          onPressed: () {
            log = 'onPressed 触发';
            setState(() {});
          },
          child: const ParkText('点击 onPressed'),
        ),
        ParkButton(
          asyncOnPressed: () async {
            log = 'asyncOnPressed 执行中...';
            setState(() {});
            await Future<void>.delayed(const Duration(seconds: 1));
            log = 'asyncOnPressed 完成';
            setState(() {});
          },
          child: const ParkText('运行 asyncOnPressed'),
        ),
        ParkButton(
          onLongPress: () {
            log = 'onLongPress 触发';
            setState(() {});
          },
          child: const ParkText('长按 onLongPress'),
        ),
        ParkButton(
          onHover: (h) {
            log = h ? 'onHover 进入' : 'onHover 离开';
            setState(() {});
          },
          onFocus: () {
            log = 'onFocus 获取焦点';
            setState(() {});
          },
          onBlur: () {
            log = 'onBlur 失去焦点';
            setState(() {});
          },
          child: const ParkText('悬停 / 聚焦 我'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          String log = '等待交互';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText(log, preset: ParkTextPreset.bodySmall),
              ParkButton(
                onPressed: () {
                  log = 'onPressed 触发';
                  setState(() {});
                },
                child: const ParkText('点击 onPressed'),
              ),
              ParkButton(
                asyncOnPressed: () async {
                  log = 'asyncOnPressed 执行中...';
                  setState(() {});
                  await Future<void>.delayed(const Duration(seconds: 1));
                  log = 'asyncOnPressed 完成';
                  setState(() {});
                },
                child: const ParkText('运行 asyncOnPressed'),
              ),
              ParkButton(
                onLongPress: () {
                  log = 'onLongPress 触发';
                  setState(() {});
                },
                child: const ParkText('长按 onLongPress'),
              ),
              ParkButton(
                onHover: (bool h) {
                  log = h ? 'onHover 进入' : 'onHover 离开';
                  setState(() {});
                },
                onFocus: () {
                  log = 'onFocus 获取焦点';
                  setState(() {});
                },
                onBlur: () {
                  log = 'onBlur 失去焦点';
                  setState(() {});
                },
                child: const ParkText('悬停 / 聚焦 我'),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '📐 尺寸令牌参考 / Sizing Token Reference',
      description: 'ParkButton 的三档高度与水平内边距由 ParkSizing 令牌系统统一驱动，'
          '确保全局一致性 / Button sizes driven by ParkSizing tokens for global consistency.',
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
        ParkText('按钮尺寸令牌 / Button Sizing Tokens', preset: ParkTextPreset.h3),
        SizedBox(height: spacing.sm),
        ParkText('以下值来自 ParkSizing 令牌系统，修改后全局生效。', preset: ParkTextPreset.bodySmall),
        SizedBox(height: spacing.md),
        _buildTokenCard(
          title: '按钮高度 / Button Height',
          items: [
            TokenItem('buttonHeightSm', sizing.buttonHeightSm, 'small (28px)'),
            TokenItem('buttonHeightMd', sizing.buttonHeightMd, 'medium (36px)'),
            TokenItem('buttonHeightLg', sizing.buttonHeightLg, 'large (44px)'),
          ],
        ),
        SizedBox(height: spacing.md),
        _buildTokenCard(
          title: '按钮水平内边距 / Button Horizontal Padding',
          items: [
            TokenItem('buttonHorizontalPaddingMd', sizing.buttonHorizontalPaddingMd, 'medium (24px)'),
          ],
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) {
        final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        final sizing = park.sizing;
        final spacing = park.spacing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkText('按钮尺寸令牌 / Button Sizing Tokens', preset: ParkTextPreset.h3),
            SizedBox(height: spacing.sm),
            ParkText('以下值来自 ParkSizing 令牌系统，修改后全局生效。', preset: ParkTextPreset.bodySmall),
            SizedBox(height: spacing.md),
            _buildTokenCard(
              title: '按钮高度 / Button Height',
              items: [
                TokenItem('buttonHeightSm', sizing.buttonHeightSm, 'small (28px)'),
                TokenItem('buttonHeightMd', sizing.buttonHeightMd, 'medium (36px)'),
                TokenItem('buttonHeightLg', sizing.buttonHeightLg, 'large (44px)'),
              ],
            ),
            SizedBox(height: spacing.md),
            _buildTokenCard(
              title: '按钮水平内边距 / Button Horizontal Padding',
              items: [
                TokenItem('buttonHorizontalPaddingMd', sizing.buttonHorizontalPaddingMd, 'medium (24px)'),
              ],
            ),
          ],
        );
      },
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkText
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTextSpec = ParkComponentSpec(
  name: 'ParkText',
  title: '文本 / Text',
  category: 'base',
  description:
      '在 Flutter Text 基础上增加预设样式（display / h1 / h2 / h3 / body / bodySmall / caption / overline）、'
      '内置 maxLines + ellipsis 处理、主题色自动跟随，并提供 copyable / strikethrough / underline / highlight /'
      'code / richSpans / expandable / type 等富文本能力。'
      ' / Typography preset system (display / h1..overline) over Flutter Text, with ellipsis, '
      'theme-aware color, and rich features: copyable / strikethrough / underline / highlight / code / richSpans / expandable / type.',
  icon: Icons.text_fields,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'data',
      type: 'String',
      required: true,
      description: '文本内容 / Text content',
    ),
    ParkPropertyDef(
      name: 'preset',
      type: 'ParkTextPreset?',
      defaultVal: 'null（使用 body）',
      description:
          '预设样式：display / h1 / h2 / h3 / body / bodySmall / caption / overline / Preset style',
    ),
    ParkPropertyDef(
      name: 'style',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '自定义样式，完全覆盖预设 / Custom style overriding the preset',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null（主题 textPrimary）',
      description: '文字颜色，覆盖预设和主题默认色 / Text color overriding preset & theme',
    ),
    ParkPropertyDef(
      name: 'fontSize',
      type: 'double?',
      defaultVal: 'null',
      description: '文字大小，覆盖预设 / Font size overriding preset',
    ),
    ParkPropertyDef(
      name: 'fontWeight',
      type: 'FontWeight?',
      defaultVal: 'null',
      description: '字重，覆盖预设 / Font weight overriding preset',
    ),
    ParkPropertyDef(
      name: 'maxLines',
      type: 'int?',
      defaultVal: 'null',
      description: '最大行数，超出自动 ellipsis / Max lines; overflow becomes ellipsis',
    ),
    ParkPropertyDef(
      name: 'selectable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否可选中复制 / Whether the text is selectable & copyable',
    ),
    ParkPropertyDef(
      name: 'textAlign',
      type: 'TextAlign?',
      defaultVal: 'null',
      description: '文本对齐方式 / Text alignment',
    ),
    ParkPropertyDef(
      name: 'textDirection',
      type: 'TextDirection?',
      defaultVal: 'null',
      description: '文本方向 / Text direction',
    ),
    ParkPropertyDef(
      name: 'overflow',
      type: 'TextOverflow?',
      defaultVal: 'null（有 maxLines 时为 ellipsis）',
      description: '溢出方式 / Overflow behavior',
    ),
    ParkPropertyDef(
      name: 'semanticsLabel',
      type: 'String?',
      defaultVal: 'null',
      description: '语义标签（无障碍） / Semantics label (a11y)',
    ),
    ParkPropertyDef(
      name: 'copyable',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否可复制（显示复制图标，点击复制到剪贴板并显示"已复制"反馈） / Copyable with a copy icon & feedback',
    ),
    ParkPropertyDef(
      name: 'strikethrough',
      type: 'bool',
      defaultVal: 'false',
      description: '是否添加删除线 / Strikethrough',
    ),
    ParkPropertyDef(
      name: 'underline',
      type: 'bool',
      defaultVal: 'false',
      description: '是否添加下划线 / Underline',
    ),
    ParkPropertyDef(
      name: 'highlight',
      type: 'bool',
      defaultVal: 'false',
      description: '是否高亮背景（黄色高亮） / Highlight background (yellow)',
    ),
    ParkPropertyDef(
      name: 'richSpans',
      type: 'List<InlineSpan>?',
      defaultVal: 'null',
      description:
          '富文本 spans，提供后使用 RichText 渲染，允许混排粗体 / 彩色文本 / Rich spans (RichText)',
    ),
    ParkPropertyDef(
      name: 'expandable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否可展开 / 收起 / Whether the text can expand / collapse',
    ),
    ParkPropertyDef(
      name: 'maxLinesCollapsed',
      type: 'int',
      defaultVal: '2',
      description: '收起状态下的最大行数 / Max lines when collapsed',
    ),
    ParkPropertyDef(
      name: 'type',
      type: 'ParkTextType?',
      defaultVal: 'null',
      description:
          '语义类型：secondary / success / warning / danger，自动应用对应颜色 / Semantic type with auto color',
    ),
    ParkPropertyDef(
      name: 'code',
      type: 'bool',
      defaultVal: 'false',
      description: '是否使用等宽字体并添加代码块背景 / Monospace font + code background',
    ),
    ParkPropertyDef(
      name: 'italic',
      type: 'bool',
      defaultVal: 'false',
      description: '是否使用斜体 / Italic',
    ),
    ParkPropertyDef(
      name: 'strong',
      type: 'bool',
      defaultVal: 'false',
      description: '是否加粗（bold 快捷方式） / Bold (shortcut)',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用（灰色显示） / Disabled (greyed out)',
    ),
    ParkPropertyDef(
      name: 'markColor',
      type: 'Color?',
      defaultVal: 'null（默认黄色高亮）',
      description: '自定义高亮颜色（覆盖默认黄色高亮） / Custom highlight color',
    ),
    ParkPropertyDef(
      name: 'expandText',
      type: 'String?',
      defaultVal: 'null（默认"展开"）',
      description: '自定义展开按钮文字 / Custom expand button text',
    ),
    ParkPropertyDef(
      name: 'collapseText',
      type: 'String?',
      defaultVal: 'null（默认"收起"）',
      description: '自定义收起按钮文字 / Custom collapse button text',
    ),
    ParkPropertyDef(
      name: 'ellipsis',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否启用省略号（true 时自动设置 maxLines=1 + ellipsis） / Force ellipsis (maxLines=1)',
    ),
    ParkPropertyDef(
      name: 'wordBreak',
      type: 'ParkWordBreak',
      defaultVal: 'ParkWordBreak.normal',
      description:
          '文本断行方式：normal / breakAll（任意字符间断行）/ breakWord（单词边界断行） / Word break mode',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onClick',
      signature: 'VoidCallback?',
      description: '点击回调（需非 disabled 生效） / Tap callback (ignored when disabled)',
    ),
    ParkEventDef(
      name: 'onCopy',
      signature: 'VoidCallback?',
      description: '复制成功后的回调 / Callback after a successful copy',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
// 引入 / Import: import 'package:park_ui/park_ui.dart';
ParkText('标题文字', preset: ParkTextPreset.h1)
''',
  guide: '''
## 何时使用 / When to use
- 页面中需要展示文字内容时 / Display text content
- 需要统一的排版样式时 / Need consistent typography

## 使用建议 / Usage tips
- 优先使用 preset 预设样式（h1/h2/h3/body/caption）保持排版一致 / Prefer presets for consistency
- 长文本设置 maxLines 防止溢出，自动显示省略号 / Long text: maxLines + ellipsis
- 需要用户复制的内容设置 copyable: true / Copyable content: copyable: true
- 强调文本用 strong / italic，删除用 strikethrough，链接用 underline / Emphasis: strong/italic; delete: strikethrough; link: underline
- 状态文字用 type: ParkTextType.success / warning / danger 自动着色 / Status text: type for auto color
- 代码块用 code: true，长内容用 expandable: true 做展开收起 / Code: code: true; long: expandable: true
- 避免直接传 style 覆盖，优先通过 preset + color / fontSize 微调 / Prefer preset + color/fontSize over raw style

## 搭配推荐 / Compose with
- 搭配 ParkDivider 做内容分隔 / Pair with ParkDivider
- 搭配 ParkIcon 做图文混排 / Pair with ParkIcon
- 搭配 ParkEllipsis 处理超长文本 / Pair with ParkEllipsis

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Typography：提供 Title / Text / Paragraph，含 copyable、ellipsis（可展开）、type(secondary/success/warning/danger)、mark/code/underline/delete 装饰。
- TDesign Flutter Font：以 `Text` + `TextStyle` 为主，提供有限语义色，无内置 copyable / expandable。
- park Text 覆盖 Ant 的 copyable / ellipsis-expandable / type 语义色，并额外提供 preset 设计令牌体系、highlight / richSpans / wordBreak / autoInsertSpace 友好排版。
### 示例 / Examples
- 对标 Ant `<Text copyable />` → park `ParkText('...', copyable: true)`；对标 Ant `ellipsis={{ rows: 2, expandable: true }}` → park `ParkText('...', expandable: true, maxLinesCollapsed: 2)`。
### 属性 / Props
- 差异点：park 的 `preset` 是设计令牌驱动的语义标题（Ant 的 Title 用 `level`），park 的 `richSpans` 比 Ant `Text` 富文本更显式。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec environment 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '文字预设',
      description:
          '展示所有预设样式：display / h1 / h2 / h3 / body / bodySmall / caption / overline / All presets',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('Display 36px', preset: ParkTextPreset.display),
    ParkText('H1 28px', preset: ParkTextPreset.h1),
    ParkText('H2 22px', preset: ParkTextPreset.h2),
    ParkText('H3 18px', preset: ParkTextPreset.h3),
    ParkText('Body 14px', preset: ParkTextPreset.body),
    ParkText('BodySmall 12px', preset: ParkTextPreset.bodySmall),
    ParkText('Caption 12px', preset: ParkTextPreset.caption),
    ParkText('Overline 10px', preset: ParkTextPreset.overline),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('Display 36px', preset: ParkTextPreset.display),
          ParkText('H1 28px', preset: ParkTextPreset.h1),
          ParkText('H2 22px', preset: ParkTextPreset.h2),
          ParkText('H3 18px', preset: ParkTextPreset.h3),
          ParkText('Body 14px', preset: ParkTextPreset.body),
          ParkText('BodySmall 12px', preset: ParkTextPreset.bodySmall),
          ParkText('Caption 12px', preset: ParkTextPreset.caption),
          ParkText('Overline 10px', preset: ParkTextPreset.overline),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色与字重',
      description: '通过 color 和 fontWeight 覆盖预设默认值 / color & fontWeight',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('品牌色文字', preset: ParkTextPreset.h2, color: _kColors.brand),
    ParkText('加粗正文', preset: ParkTextPreset.body, fontWeight: FontWeight.bold),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('品牌色文字',
              preset: ParkTextPreset.h2, color: _kColors.brand),
          ParkText('加粗正文',
              preset: ParkTextPreset.body, fontWeight: FontWeight.bold),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '文本截断',
      description: '使用 maxLines 限制行数，超出自动显示省略号 / maxLines + ellipsis',
      code: '''
SizedBox(
  width: _kTruncateWidth,
  child: ParkText(
    '这是一段很长的文字，用来演示文本截断功能，最多显示两行，超出部分以省略号结尾。',
    preset: ParkTextPreset.body,
    maxLines: 2,
  ),
)
''',
      builder: (BuildContext context) => SizedBox(
        width: _kTruncateWidth,
        child: ParkText(
          '这是一段很长的文字，用来演示文本截断功能，最多显示两行，超出部分以省略号结尾。',
          preset: ParkTextPreset.body,
          maxLines: 2,
        ),
      ),
    ),
    ParkDemoScenario(
      title: '可选中文字',
      description: '设置 selectable: true 允许用户长按选中并复制文本 / selectable',
      code: '''
ParkText(
  '长按选中我试试',
  preset: ParkTextPreset.h3,
  selectable: true,
)
''',
      builder: (BuildContext context) => ParkText(
        '长按选中我试试',
        preset: ParkTextPreset.h3,
        selectable: true,
      ),
    ),
    ParkDemoScenario(
      title: '删除线与下划线',
      description: 'strikethrough 添加删除线；underline 添加下划线 / strikethrough & underline',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('已删除的内容', strikethrough: true),
    ParkText('带下划线的链接文字', underline: true, color: _kColors.brand),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('已删除的内容', strikethrough: true),
          ParkText('带下划线的链接文字',
              underline: true, color: _kColors.brand),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '高亮与代码块',
      description: 'highlight 黄色高亮背景；code 等宽字体 + 代码块背景 / highlight & code',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('这是一段高亮背景的文字', highlight: true),
    ParkText("final value = 'code';", code: true),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('这是一段高亮背景的文字', highlight: true),
          ParkText("final value = 'code';", code: true),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '语义类型',
      description:
          '通过 type 自动应用 secondary / success / warning / danger 颜色 / semantic type',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('次要文字', type: ParkTextType.secondary),
    ParkText('成功文字', type: ParkTextType.success),
    ParkText('警告文字', type: ParkTextType.warning),
    ParkText('危险文字', type: ParkTextType.danger),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('次要文字', type: ParkTextType.secondary),
          ParkText('成功文字', type: ParkTextType.success),
          ParkText('警告文字', type: ParkTextType.warning),
          ParkText('危险文字', type: ParkTextType.danger),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可复制与可展开',
      description: 'copyable 一键复制；expandable 展开 / 收起长文本 / copyable & expandable',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('点击右侧图标复制这段文字', copyable: true),
    ParkText(
      '这是一段可以展开收起的长文本内容，用于演示 ParkText 的展开收起功能，点击展开后会显示完整文本。',
      expandable: true,
      maxLinesCollapsed: 2,
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('点击右侧图标复制这段文字', copyable: true),
          ParkText(
            '这是一段可以展开收起的长文本内容，用于演示 ParkText 的展开收起功能，点击展开后会显示完整文本。',
            expandable: true,
            maxLinesCollapsed: 2,
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '富文本与强调',
      description: 'strong / italic 快捷强调；richSpans 富文本混排 / strong/italic & richSpans',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkText('普通加粗斜体混合', strong: true, italic: true),
    ParkText(
      '',
      richSpans: [
        TextSpan(text: '粗体', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: '和'),
        TextSpan(text: '彩色', style: TextStyle(color: _kColors.brand)),
      ],
    ),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('普通加粗斜体混合', strong: true, italic: true),
          ParkText(
            '',
            richSpans: <InlineSpan>[
              const TextSpan(
                  text: '粗体', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '和'),
              TextSpan(
                  text: '彩色', style: TextStyle(color: _kColors.brand)),
            ],
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互文本（用法演示）',
      description:
          '点击下方按钮切换加粗状态，演示 ParkText 的运行时用法（非纯预览） / Interactive: toggle bold at runtime',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool strong = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkText('点击按钮切换加粗', strong: strong),
        ParkButton(
          onPressed: () {
            strong = !strong;
            setState(() {});
          },
          child: const ParkText('切换加粗', preset: ParkTextPreset.bodySmall),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool strong = false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText('点击按钮切换加粗', strong: strong),
              ParkButton(
                onPressed: () {
                  strong = !strong;
                  setState(() {});
                },
                child: const ParkText('切换加粗', preset: ParkTextPreset.bodySmall),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '点击与复制回调',
      description:
          'onClick 点击回调更新状态；onCopy 复制成功后回调 / onClick & onCopy',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    String status = '等待交互';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkText(status, preset: ParkTextPreset.bodySmall),
        ParkText(
          '点击我触发 onClick',
          onClick: () {
            status = 'onClick 触发';
            setState(() {});
          },
        ),
        ParkText(
          '复制这段文字', copyable: true,
          onCopy: () {
            status = 'onCopy 触发（已复制到剪贴板）';
            setState(() {});
          },
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          String status = '等待交互';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText(status, preset: ParkTextPreset.bodySmall),
              ParkText(
                '点击我触发 onClick',
                onClick: () {
                  status = 'onClick 触发';
                  setState(() {});
                },
              ),
              ParkText(
                '复制这段文字',
                copyable: true,
                onCopy: () {
                  status = 'onCopy 触发（已复制到剪贴板）';
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkIcon
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkIconSpec = ParkComponentSpec(
  name: 'ParkIcon',
  title: '图标 / Icon',
  category: 'base',
  description:
      '对 Flutter Icon 的增强封装：预设尺寸（small / medium / large / xlarge）、'
      '可选容器背景（circle / rounded）、主题色自动跟随，并支持 spin 旋转、badge 角标、'
      'onClick 点击、tooltip 提示、rotate 旋转、mirror 翻转等扩展。'
      ' / Enhanced Flutter Icon: preset sizes (small/medium/large/xlarge), optional '
      'container (circle/rounded), theme-aware color, plus spin / badge / onClick / tooltip / rotate / mirror.',
  icon: Icons.star_outline,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'icon',
      type: 'IconData',
      required: true,
      description: '图标数据 / Icon data',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkIconSize',
      defaultVal: 'ParkIconSize.medium',
      description:
          '图标尺寸预设：small (16px) / medium (20px) / large (24px) / xlarge (32px) / Icon size preset',
    ),
    ParkPropertyDef(
      name: 'pixelSize',
      type: 'double?',
      defaultVal: 'null',
      description: '自定义像素尺寸，优先于 size / Custom pixel size (overrides size)',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null（主题 textPrimary）',
      description: '图标颜色 / Icon color',
    ),
    ParkPropertyDef(
      name: 'container',
      type: 'ParkIconContainer',
      defaultVal: 'ParkIconContainer.none',
      description: '容器类型：none / circle / rounded / Container type',
    ),
    ParkPropertyDef(
      name: 'containerColor',
      type: 'Color?',
      defaultVal: 'null（brand 10% 透明度）',
      description: '容器背景色 / Container background color',
    ),
    ParkPropertyDef(
      name: 'containerPadding',
      type: 'double?',
      defaultVal: 'null（自动计算）',
      description: '容器内边距 / Container padding',
    ),
    ParkPropertyDef(
      name: 'semanticLabel',
      type: 'String?',
      defaultVal: 'null',
      description: '语义标签（无障碍） / Semantic label (a11y)',
    ),
    ParkPropertyDef(
      name: 'spin',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用持续旋转动画（1.5s 周期匀速旋转） / Continuous spin animation (1.5s)',
    ),
    ParkPropertyDef(
      name: 'badge',
      type: 'int?',
      defaultVal: 'null',
      description: '右上角角标数字（> 99 显示 99+） / Top-right badge count (> 99 shows 99+)',
    ),
    ParkPropertyDef(
      name: 'tooltip',
      type: 'String?',
      defaultVal: 'null',
      description: '长按提示文本（包裹 Tooltip） / Long-press tooltip text',
    ),
    ParkPropertyDef(
      name: 'badgeDot',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示红点角标（简单红点，不显示数字） / Red-dot badge (no number)',
    ),
    ParkPropertyDef(
      name: 'spinDuration',
      type: 'Duration?',
      defaultVal: 'null（默认 1500ms）',
      description: '自定义旋转动画周期 / Custom spin duration',
    ),
    ParkPropertyDef(
      name: 'hoverColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '悬停状态颜色（仅 onClick 不为 null 时有效） / Hover color (needs onClick)',
    ),
    ParkPropertyDef(
      name: 'rotate',
      type: 'double?',
      defaultVal: 'null',
      description: '旋转角度（度数，如 45 / 90 / 180） / Rotation degrees (e.g. 45/90/180)',
    ),
    ParkPropertyDef(
      name: 'mirror',
      type: 'bool',
      defaultVal: 'false',
      description: '是否水平翻转 / Horizontal mirror',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onClick',
      signature: 'VoidCallback?',
      description:
          '点击回调（不为 null 时图标包裹 InkWell 提供涟漪反馈） / Tap callback (wraps InkWell when set)',
    ),
    ParkEventDef(
      name: 'onLongPress',
      signature: 'VoidCallback?',
      description: '长按回调 / Long-press callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
// 引入 / Import: import 'package:park_ui/park_ui.dart';
ParkIcon(Icons.home)
''',
  guide: '''
## 何时使用 / When to use
- 需要展示功能性图标时（导航、操作按钮、状态指示等） / Functional icons (nav, actions, status)
- 搭配其他组件作为视觉辅助 / Visual aid alongside other components

## 使用建议 / Usage tips
- 使用 size 预设（small/medium/large/xlarge）保持图标尺寸统一 / Use size presets for consistency
- 需要背景时使用 container 参数（circle 或 rounded） / Use container for background
- 容器场景通过 containerColor 自定义背景色（默认 brand 10% 透明度） / containerColor overrides default
- 状态指示用 spin 做加载旋转、badge / badgeDot 做角标 / Status: spin / badge
- 无障碍场景设置 semanticLabel 供屏幕阅读器识别 / Set semanticLabel for a11y
- 需精确尺寸时使用 pixelSize 覆盖预设 / Use pixelSize for exact size
- 可点击图标设置 onClick + tooltip 提升交互反馈 / Clickable: onClick + tooltip

## 搭配推荐 / Compose with
- 搭配 ParkButton 做图标按钮 / Pair with ParkButton
- 搭配 ParkBadge 做带角标的图标 / Pair with ParkBadge
- 搭配 ParkAvatar 做头像回退方案 / Pair with ParkAvatar

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Icon：基于 `@ant-design/icons`，支持 spin、旋转、双色图标、自定义尺寸；无内置 badge / 容器背景。
- TDesign Flutter Icon：基础 `Icon` + `TIcon`，支持 size / color / 少量变体，无 badge / 容器。
- park Icon 覆盖二者，并额外提供 container(circle/rounded) 背景、badge / badgeDot 角标、rotate / mirror、tooltip 与 onClick 涟漪。
### 示例 / Examples
- 对标 Ant `<LoadingOutlined spin />` → park `ParkIcon(Icons.refresh, spin: true)`；对标 Ant 带徽标需自行包裹 `Badge` → park 原生 `badge` 参数。
### 属性 / Props
- 差异点：park 的 `container` + `badge` / `badgeDot` 在 Ant / TDesign 中需额外组件包裹；park `preset size` 比裸 `size` 更语义化。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec environment 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '图标尺寸',
      description:
          '展示 small / medium / large / xlarge 四种预设尺寸 / 4 size presets',
      code: '''
Row(
  children: [
    ParkIcon(Icons.star, size: ParkIconSize.small, color: _kColors.warning),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.star, size: ParkIconSize.medium, color: _kColors.warning),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.star, size: ParkIconSize.large, color: _kColors.warning),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.star, size: ParkIconSize.xlarge, color: _kColors.warning),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.star,
              size: ParkIconSize.small, color: _kColors.warning),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.star,
              size: ParkIconSize.medium, color: _kColors.warning),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.star,
              size: ParkIconSize.large, color: _kColors.warning),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.star,
              size: ParkIconSize.xlarge, color: _kColors.warning),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description: '通过 color 参数设置图标颜色 / color',
      code: '''
Row(
  children: [
    ParkIcon(Icons.favorite, color: _kColors.error, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.check_circle, color: _kColors.success, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.info, color: _kColors.brand, size: ParkIconSize.large),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.favorite,
              color: _kColors.error, size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.check_circle,
              color: _kColors.success, size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.info,
              color: _kColors.brand, size: ParkIconSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '圆形容器',
      description: '使用 container: ParkIconContainer.circle 添加圆形背景 / circle container',
      code: '''
Row(
  children: [
    ParkIcon(Icons.add, container: ParkIconContainer.circle, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.search, container: ParkIconContainer.circle, size: ParkIconSize.large),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.add,
              container: ParkIconContainer.circle,
              size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.search,
              container: ParkIconContainer.circle,
              size: ParkIconSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '圆角方形容器',
      description:
          '使用 container: ParkIconContainer.rounded 添加圆角方形背景 / rounded container',
      code: '''
Row(
  children: [
    ParkIcon(Icons.settings, container: ParkIconContainer.rounded, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.person, container: ParkIconContainer.rounded, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.mail, container: ParkIconContainer.rounded, size: ParkIconSize.large, containerColor: _kColors.brand.withValues(alpha: 0.1)),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.settings,
              container: ParkIconContainer.rounded,
              size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.person,
              container: ParkIconContainer.rounded,
              size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.mail,
              container: ParkIconContainer.rounded,
              size: ParkIconSize.large,
              containerColor: _kColors.brand.withValues(alpha: 0.1)),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '旋转与角标',
      description: 'spin 持续旋转；badge 数字角标与 badgeDot 红点角标 / spin & badge',
      code: '''
Row(
  children: [
    ParkIcon(Icons.refresh, spin: true, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.notifications, badge: 5, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.mail, badgeDot: true, size: ParkIconSize.large),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.refresh, spin: true, size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.notifications, badge: 5, size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.mail, badgeDot: true, size: ParkIconSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可点击与提示',
      description: 'onClick 提供点击反馈；tooltip 提供长按提示 / onClick & tooltip',
      code: '''
Row(
  children: [
    ParkIcon(Icons.thumb_up, onClick: () {}, tooltip: '点赞', size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.share, onClick: () {}, tooltip: '分享', size: ParkIconSize.large),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.thumb_up,
              onClick: () {}, tooltip: '点赞', size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.share,
              onClick: () {}, tooltip: '分享', size: ParkIconSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '旋转角度与翻转',
      description: 'rotate 按度数静态旋转；mirror 水平翻转 / rotate & mirror',
      code: '''
Row(
  children: [
    ParkIcon(Icons.arrow_upward, rotate: 45, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.arrow_upward, rotate: 180, size: ParkIconSize.large),
    SizedBox(width: _kSpacing.md),
    ParkIcon(Icons.arrow_back, mirror: true, size: ParkIconSize.large),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkIcon(Icons.arrow_upward,
              rotate: 45, size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.arrow_upward,
              rotate: 180, size: ParkIconSize.large),
          SizedBox(width: _kSpacing.md),
          ParkIcon(Icons.arrow_back,
              mirror: true, size: ParkIconSize.large),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互图标（旋转开关）',
      description:
          '点击下方按钮切换旋转动画，演示 ParkIcon.spin 用法的交互式 demo / Interactive: toggle spin',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool spin = false;
    return Column(
      children: <Widget>[
        ParkIcon(Icons.refresh, spin: spin, size: ParkIconSize.large),
        ParkButton(
          onPressed: () {
            spin = !spin;
            setState(() {});
          },
          child: const ParkText('切换旋转'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool spin = false;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkIcon(Icons.refresh, spin: spin, size: ParkIconSize.large),
              ParkButton(
                onPressed: () {
                  spin = !spin;
                  setState(() {});
                },
                child: const ParkText('切换旋转'),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '点击与长按回调',
      description:
          'onClick 点击计数；onLongPress 长按触发动作 / onClick & onLongPress',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    int tap = 0;
    return Column(
      children: <Widget>[
        ParkText('点击 \$tap 次 / 长按右图 +10', preset: ParkTextPreset.bodySmall),
        Row(
          children: <Widget>[
            ParkIcon(Icons.thumb_up, onClick: () {
              tap++;
              setState(() {});
            }, tooltip: '点赞', size: ParkIconSize.large),
            SizedBox(width: _kSpacing.md),
            ParkIcon(Icons.delete_outline, onLongPress: () {
              tap += 10;
              setState(() {});
            }, tooltip: '长按删除', size: ParkIconSize.large),
          ],
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          int tap = 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText('点击 $tap 次 / 长按右图 +10',
                  preset: ParkTextPreset.bodySmall),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ParkIcon(
                    Icons.thumb_up,
                    onClick: () {
                      tap++;
                      setState(() {});
                    },
                    tooltip: '点赞',
                    size: ParkIconSize.large,
                  ),
                  SizedBox(width: _kSpacing.md),
                  ParkIcon(
                    Icons.delete_outline,
                    onLongPress: () {
                      tap += 10;
                      setState(() {});
                    },
                    tooltip: '长按删除',
                    size: ParkIconSize.large,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkDivider
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDividerSpec = ParkComponentSpec(
  name: 'ParkDivider',
  title: '分割线 / Divider',
  category: 'base',
  description:
      '支持水平 / 垂直方向、自定义颜色 / 粗细 / 缩进，以及带文字的水平分割线。'
      '可选虚线（dashed）与点线（dotted）渲染，withText 静态方法支持文字对齐与前置图标。'
      ' / Horizontal / vertical dividers with custom color / thickness / indent, plus a '
      'text divider. Supports dashed / dotted rendering; withText supports text alignment & leading icon.',
  icon: Icons.horizontal_rule,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'axis',
      type: 'ParkDividerAxis',
      defaultVal: 'ParkDividerAxis.horizontal',
      description: '分割线方向：horizontal / vertical / Divider direction',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null（主题 divider 色）',
      description: '分割线颜色 / Divider color',
    ),
    ParkPropertyDef(
      name: 'thickness',
      type: 'double',
      defaultVal: '0.5',
      description: '分割线粗细（像素） / Thickness (px)',
    ),
    ParkPropertyDef(
      name: 'indent',
      type: 'double',
      defaultVal: '0',
      description: '水平方向左侧缩进 / Horizontal left indent',
    ),
    ParkPropertyDef(
      name: 'endIndent',
      type: 'double',
      defaultVal: '0',
      description: '水平方向右侧缩进 / Horizontal right indent',
    ),
    ParkPropertyDef(
      name: 'verticalHeight',
      type: 'double?',
      defaultVal: 'null（默认 16px）',
      description: '垂直方向时的高度 / Height when vertical',
    ),
    ParkPropertyDef(
      name: 'dashed',
      type: 'bool',
      defaultVal: 'false',
      description: '是否渲染为虚线（CustomPaint 绘制） / Render as dashed line',
    ),
    ParkPropertyDef(
      name: 'dashWidth',
      type: 'double',
      defaultVal: '4.0',
      description: '虚线段长度（仅 dashed 为 true 时有效） / Dash segment length',
    ),
    ParkPropertyDef(
      name: 'dashGap',
      type: 'double',
      defaultVal: '3.0',
      description: '虚线间隔（仅 dashed 为 true 时有效） / Dash gap',
    ),
    ParkPropertyDef(
      name: 'dotted',
      type: 'bool',
      defaultVal: 'false',
      description: '是否渲染为点线（圆点样式，区别于 dashed 的短线段） / Render as dotted line',
    ),
    ParkPropertyDef(
      name: 'plain',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否以正文样式渲染分割线文字（不使用小号次要文字样式） / Render divider text in body style',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkDivider.withText',
      signature:
          'static Widget withText(String text, {Color? color, Color? textColor, double thickness, double indent, double endIndent, TextStyle? textStyle, ParkDividerTextAlign textAlign, IconData? icon, bool dashed, double dashWidth, double dashGap, bool dotted, bool plain})',
      description:
          '带文字的水平分割线（仅水平方向有效），支持文字对齐与前置图标 / Horizontal text divider with alignment & icon',
    ),
  ],
  basicUsageCode: '''
// 引入 / Import: import 'package:park_ui/park_ui.dart';
ParkDivider()
''',
  guide: '''
## 何时使用 / When to use
- 需要在内容之间添加视觉分隔时 / Add visual separation between content
- 列表项之间、区块之间的分隔 / Between list items or sections

## 使用建议 / Usage tips
- 默认水平分割线用于上下内容分隔 / Default horizontal for vertical spacing
- 行内元素分隔使用 axis: vertical 垂直分割线 / Inline separation: axis vertical
- 通过 indent / endIndent 设置缩进，避免分割线顶边 / indent / endIndent to avoid edge-to-edge
- 带文字分割线使用 ParkDivider.withText，适合"或"等分隔场景 / Text divider for "or" separators
- 粗细默认 0.5px，需要强调时可调整 thickness / Default 0.5px; raise thickness for emphasis
- 虚线 / 点线用 dashed / dotted 参数，适合次级分隔 / dashed / dotted for secondary splitting

## 搭配推荐 / Compose with
- 搭配 ParkCell 做列表项分隔 / Pair with ParkCell
- 搭配 ParkCollapse 做折叠面板分隔 / Pair with ParkCollapse
- 搭配 ParkFooter 做页脚分隔 / Pair with ParkFooter

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Divider：支持 horizontal / vertical、带文字（`orientation` 左/中/右）、`dashed`、自定义 `plain`。
- TDesign Flutter Divider：支持 horizontal / vertical、文字、`dashed`、content 槽。
- park Divider 覆盖二者：horizontal / vertical + withText（对齐 + 图标）+ dashed / dotted（点线，TDesign 无）+ indent / endIndent 缩进。
### 示例 / Examples
- 对标 Ant `<Divider orientation="left">OR</Divider>` → park `ParkDivider.withText('OR', textAlign: ParkDividerTextAlign.left)`；对标 Ant `dashed` → park `dashed: true`。
### 属性 / Props
- 差异点：park 的 `dotted`（点线）是 Ant / TDesign 没有的；park `indent` / `endIndent` 与 Ant `orientationMargin` 语义不同但目标一致。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec environment 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础分割线',
      description: '默认水平分割线 / default horizontal',
      code: '''
Column(
  children: [
    ParkText('上方内容', preset: ParkTextPreset.body),
    ParkDivider(),
    ParkText('下方内容', preset: ParkTextPreset.body),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParkText('上方内容', preset: ParkTextPreset.body),
          ParkDivider(),
          ParkText('下方内容', preset: ParkTextPreset.body),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色与粗细',
      description: '通过 color 和 thickness 自定义分割线外观 / color & thickness',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkDivider(color: _kColors.brand, thickness: _kThicknessThin),
    SizedBox(height: _kSpacing.sm),
    ParkDivider(color: _kColors.error, thickness: _kThicknessMedium),
    SizedBox(height: _kSpacing.sm),
    ParkDivider(color: _kColors.success, thickness: _kThicknessThick),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkDivider(color: _kColors.brand, thickness: _kThicknessThin),
          SizedBox(height: _kSpacing.sm),
          ParkDivider(color: _kColors.error, thickness: _kThicknessMedium),
          SizedBox(height: _kSpacing.sm),
          ParkDivider(color: _kColors.success, thickness: _kThicknessThick),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带缩进的分割线',
      description: '通过 indent 和 endIndent 设置左右缩进 / indent & endIndent',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkDivider(indent: _kSpacing.base, endIndent: _kSpacing.base),
    SizedBox(height: _kSpacing.sm),
    ParkDivider(indent: _kSpacing.page, endIndent: _kSpacing.page, color: _kColors.textSecondary),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkDivider(indent: _kSpacing.base, endIndent: _kSpacing.base),
          SizedBox(height: _kSpacing.sm),
          ParkDivider(
              indent: _kSpacing.page,
              endIndent: _kSpacing.page,
              color: _kColors.textSecondary),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带文字的分割线',
      description: '使用 ParkDivider.withText 在分割线中间插入文字 / withText',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkDivider.withText('或者'),
    SizedBox(height: _kSpacing.md),
    ParkDivider.withText('没有更多了', color: _kColors.textSecondary),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkDivider.withText('或者'),
          SizedBox(height: _kSpacing.md),
          ParkDivider.withText('没有更多了', color: _kColors.textSecondary),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '垂直分割线',
      description:
          '使用 axis: ParkDividerAxis.vertical 在行内放置垂直分割线 / vertical',
      code: '''
Row(
  children: [
    ParkText('左侧', preset: ParkTextPreset.body),
    SizedBox(width: _kSpacing.md),
    ParkDivider(axis: ParkDividerAxis.vertical, verticalHeight: _kSpacing.lg),
    SizedBox(width: _kSpacing.md),
    ParkText('右侧', preset: ParkTextPreset.body),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkText('左侧', preset: ParkTextPreset.body),
          SizedBox(width: _kSpacing.md),
          ParkDivider(
              axis: ParkDividerAxis.vertical, verticalHeight: _kSpacing.lg),
          SizedBox(width: _kSpacing.md),
          ParkText('右侧', preset: ParkTextPreset.body),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '虚线与点线',
      description: 'dashed 虚线、dotted 点线，以及带文字的虚线分割线 / dashed & dotted',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkDivider(dashed: true),
    SizedBox(height: _kSpacing.sm),
    ParkDivider(dotted: true),
    SizedBox(height: _kSpacing.sm),
    ParkDivider.withText('虚线文字', dashed: true),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkDivider(dashed: true),
          SizedBox(height: _kSpacing.sm),
          ParkDivider(dotted: true),
          SizedBox(height: _kSpacing.sm),
          ParkDivider.withText('虚线文字', dashed: true),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '文字对齐与图标',
      description:
          'withText 的 textAlign 控制文字对齐，icon 添加前置图标 / textAlign & icon',
      code: '''
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkDivider.withText('左对齐', textAlign: ParkDividerTextAlign.left, icon: Icons.star),
    SizedBox(height: _kSpacing.md),
    ParkDivider.withText('右对齐', textAlign: ParkDividerTextAlign.right, icon: Icons.settings),
  ],
)
''',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkDivider.withText('左对齐',
              textAlign: ParkDividerTextAlign.left, icon: Icons.star),
          SizedBox(height: _kSpacing.md),
          ParkDivider.withText('右对齐',
              textAlign: ParkDividerTextAlign.right, icon: Icons.settings),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互分割线（切换虚线）',
      description:
          '点击下方按钮切换虚线 / 实线，演示 ParkDivider.dashed 用法 / Interactive: toggle dashed',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool dashed = false;
    return Column(
      children: <Widget>[
        ParkDivider(dashed: dashed),
        ParkButton(
          onPressed: () {
            dashed = !dashed;
            setState(() {});
          },
          child: const ParkText('切换虚线'),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool dashed = false;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkDivider(dashed: dashed),
              ParkButton(
                onPressed: () {
                  dashed = !dashed;
                  setState(() {});
                },
                child: const ParkText('切换虚线'),
              ),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkFab
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkFabSpec = ParkComponentSpec(
  name: 'ParkFab',
  title: '悬浮按钮 / Fab',
  category: 'base',
  description:
      '悬浮操作按钮（FAB），用于页面主操作。支持 xsmall / small / mini / normal 四种尺寸、'
      'circle / rounded 两种形状，可选文字标签（extended FAB），并通过 themeVariant 提供'
      'primary / defaultTheme / light / danger 四种主题变体。'
      ' / Floating action button for primary page actions. 4 sizes (xsmall/small/mini/normal), '
      '2 shapes (circle/rounded), optional label (extended FAB), 4 theme variants.',
  icon: Icons.add_circle_outline,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'icon',
      type: 'IconData',
      required: true,
      description: '图标 / Icon',
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '可选文字标签，有标签时自动变为 extended FAB / Optional label (extended FAB)',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkFabSize',
      defaultVal: 'ParkFabSize.normal',
      description:
          '尺寸：xsmall (28px) / small (32px) / normal (56px) / mini (40px) / Size',
    ),
    ParkPropertyDef(
      name: 'shape',
      type: 'ParkFabShape',
      defaultVal: 'ParkFabShape.circle',
      description: '形状：circle / rounded / Shape',
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null（主题 brand 色）',
      description: '背景色 / Background color',
    ),
    ParkPropertyDef(
      name: 'foregroundColor',
      type: 'Color?',
      defaultVal: 'null（主题 textOnBrand 色）',
      description: '前景色（图标和文字） / Foreground color (icon & text)',
    ),
    ParkPropertyDef(
      name: 'elevation',
      type: 'List<BoxShadow>?',
      defaultVal: 'null（主题 shadows.md）',
      description: '自定义阴影 / Custom shadow',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于 loading 状态（显示圆形加载指示器） / Loading state (spinner)',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用 / Disabled',
    ),
    ParkPropertyDef(
      name: 'tooltip',
      type: 'String?',
      defaultVal: 'null',
      description: '长按提示文本（包裹 Tooltip） / Long-press tooltip',
    ),
    ParkPropertyDef(
      name: 'themeVariant',
      type: 'ParkFabTheme',
      defaultVal: 'ParkFabTheme.primary',
      description:
          '主题变体：primary / defaultTheme / light / danger / Theme variant',
    ),
    ParkPropertyDef(
      name: 'mini',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否为迷你尺寸（等价于 size: ParkFabSize.mini 的快捷方式） / Mini size shortcut',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onPressed',
      signature: 'VoidCallback?',
      description: '点击回调 / Tap callback',
    ),
    ParkEventDef(
      name: 'onLongPress',
      signature: 'VoidCallback?',
      description: '长按回调 / Long-press callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
// 引入 / Import: import 'package:park_ui/park_ui.dart';
ParkFab(
  icon: Icons.add,
  onPressed: () {},
)
''',
  guide: '''
## 何时使用 / When to use
- 页面有一个突出的主要操作时（新建、添加、编辑等） / One prominent primary action (create/add/edit)
- 需要吸引用户注意的核心操作入口 / Core action that needs attention

## 使用建议 / Usage tips
- 每个页面最多使用一个 FAB，避免多个 FAB 造成视觉混乱 / At most one FAB per page
- 使用 label 参数变为 extended FAB，文字说明更清晰 / Use label for extended FAB
- 小型页面或空间有限时使用 size: mini 或 mini: true / Small pages: mini
- 位置通常在页面右下角，配合 Stack 定位 / Usually bottom-right via Stack
- 通过 themeVariant 切换 primary / defaultTheme / light / danger 外观 / themeVariant for look
- 与底部导航搭配时注意不要遮挡 / Avoid overlapping bottom nav

## 搭配推荐 / Compose with
- 搭配 ParkTabBar 做底部导航 + 主操作 / Pair with ParkTabBar
- 搭配 ParkBackTop 在长页面中并存 / Pair with ParkBackTop
- 搭配 ParkPopup 做新建操作面板 / Pair with ParkPopup

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG FloatButton（FAB）：支持形状（circle/square）、菜单展开、badge、description、type(primary/default)。
- TDesign Flutter Fab：支持 `TExtendedFab`（带文字）、shape、主题色，无 menu 展开。
- park Fab 覆盖：4 尺寸 + 2 形状 + extended label + 4 主题变体 + loading/disabled/tooltip；菜单展开型对标 Ant 可用 ParkPopup 组合实现。
### 示例 / Examples
- 对标 Ant `<FloatButton />` → park `ParkFab(icon: Icons.add, onPressed: () {})`；对标 TDesign 带文字 `TExtendedFab` → park `ParkFab(icon: Icons.edit, label: '编辑', shape: ParkFabShape.rounded)`。
### 属性 / Props
- 差异点：park 的 `themeVariant`（primary/defaultTheme/light/danger）比 Ant `type` 多一个 light 变体；park 缺 Ant 的菜单展开，可用 Popup 补齐。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec environment 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础悬浮按钮',
      description: '默认圆形 56px 的悬浮按钮 / default 56px circle',
      code: '''
ParkFab(
  icon: Icons.add,
  onPressed: () {},
)
''',
      builder: (BuildContext context) => ParkFab(
        icon: Icons.add,
        onPressed: () {},
      ),
    ),
    ParkDemoScenario(
      title: 'Extended FAB',
      description: '带文字标签的扩展悬浮按钮 / extended with label',
      code: '''
ParkFab(
  icon: Icons.edit,
  label: '编辑',
  shape: ParkFabShape.rounded,
  onPressed: () {},
)
''',
      builder: (BuildContext context) => ParkFab(
        icon: Icons.edit,
        label: '编辑',
        shape: ParkFabShape.rounded,
        onPressed: () {},
      ),
    ),
    ParkDemoScenario(
      title: '迷你尺寸',
      description:
          '使用 ParkFabSize.mini（等价于 mini: true）展示 40px 小号悬浮按钮 / mini size',
      code: '''
Row(
  children: [
    ParkFab(icon: Icons.add, size: ParkFabSize.mini, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.search, mini: true, onPressed: () {}),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkFab(
              icon: Icons.add,
              size: ParkFabSize.mini,
              onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(
              icon: Icons.search, mini: true, onPressed: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description:
          '通过 backgroundColor 和 foregroundColor 自定义外观 / backgroundColor & foregroundColor',
      code: '''
Row(
  children: [
    ParkFab(icon: Icons.delete, backgroundColor: _kColors.error, foregroundColor: _kColors.textOnBrand, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.check, backgroundColor: _kColors.success, foregroundColor: _kColors.textOnBrand, onPressed: () {}),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkFab(
            icon: Icons.delete,
            backgroundColor: _kColors.error,
            foregroundColor: _kColors.textOnBrand,
            onPressed: () {},
          ),
          SizedBox(width: _kSpacing.md),
          ParkFab(
            icon: Icons.check,
            backgroundColor: _kColors.success,
            foregroundColor: _kColors.textOnBrand,
            onPressed: () {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '尺寸全览',
      description: '展示 xsmall / small / mini / normal 四种尺寸 / all 4 sizes',
      code: '''
Row(
  children: [
    ParkFab(icon: Icons.add, size: ParkFabSize.xsmall, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.add, size: ParkFabSize.small, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.add, size: ParkFabSize.mini, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.add, size: ParkFabSize.normal, onPressed: () {}),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkFab(icon: Icons.add, size: ParkFabSize.xsmall, onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(icon: Icons.add, size: ParkFabSize.small, onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(icon: Icons.add, size: ParkFabSize.mini, onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(icon: Icons.add, size: ParkFabSize.normal, onPressed: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '主题变体',
      description:
          '通过 themeVariant 切换 defaultTheme / light / danger 外观 / theme variants',
      code: '''
Row(
  children: [
    ParkFab(icon: Icons.add, themeVariant: ParkFabTheme.defaultTheme, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.favorite, themeVariant: ParkFabTheme.light, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.delete, themeVariant: ParkFabTheme.danger, onPressed: () {}),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkFab(
              icon: Icons.add,
              themeVariant: ParkFabTheme.defaultTheme,
              onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(
              icon: Icons.favorite,
              themeVariant: ParkFabTheme.light,
              onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(
              icon: Icons.delete,
              themeVariant: ParkFabTheme.danger,
              onPressed: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '加载、禁用与提示',
      description: 'loading 显示转圈；disabled 禁用；tooltip 提供提示 / loading/disabled/tooltip',
      code: '''
Row(
  children: [
    ParkFab(icon: Icons.download, loading: true, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.edit, disabled: true, onPressed: () {}),
    SizedBox(width: _kSpacing.md),
    ParkFab(icon: Icons.info, tooltip: '信息', onPressed: () {}),
  ],
)
''',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkFab(icon: Icons.download, loading: true, onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(icon: Icons.edit, disabled: true, onPressed: () {}),
          SizedBox(width: _kSpacing.md),
          ParkFab(icon: Icons.info, tooltip: '信息', onPressed: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互悬浮按钮（计数触发）',
      description:
          '点击 FAB 触发动作（计数器 +1），演示 ParkFab.onPressed 用法 / Interactive: onPressed increments',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    int count = 0;
    return Column(
      children: <Widget>[
        ParkText('已点击 \$count 次', preset: ParkTextPreset.body),
        ParkFab(
          icon: Icons.add,
          onPressed: () {
            count++;
            setState(() {});
          },
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          int count = 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText('已点击 $count 次', preset: ParkTextPreset.body),
              ParkFab(
                icon: Icons.add,
                onPressed: () {
                  count++;
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '长按回调',
      description:
          'onLongPress 长按触发动作（需同时提供 onPressed 以启用交互） / onLongPress',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    int tap = 0;
    int longCount = 0;
    return Column(
      children: <Widget>[
        ParkText('点击 \$tap 次 / 长按 \$longCount 次', preset: ParkTextPreset.body),
        ParkFab(
          icon: Icons.add,
          onPressed: () {
            tap++;
            setState(() {});
          },
          onLongPress: () {
            longCount++;
            setState(() {});
          },
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          int tap = 0;
          int longCount = 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText('点击 $tap 次 / 长按 $longCount 次',
                  preset: ParkTextPreset.body),
              ParkFab(
                icon: Icons.add,
                onPressed: () {
                  tap++;
                  setState(() {});
                },
                onLongPress: () {
                  longCount++;
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkLink
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkLinkSpec = ParkComponentSpec(
  name: 'ParkLink',
  title: '链接 / Link',
  category: 'base',
  description:
      '文字超链接组件，支持 defaultLink / underline 两种变体，normal / disabled / pressed 三种状态，'
      '可选前置和后置图标。通过 linkStyle 提供 primary / defaultStyle / danger / warning / success 语义样式，'
      '通过 linkSize 控制 small / medium / large 尺寸。'
      ' / Text hyperlink: defaultLink / underline variants, normal/disabled/pressed states, '
      'leading/trailing icons, semantic linkStyle, and small/medium/large sizes.',
  icon: Icons.link,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'text',
      type: 'String',
      required: true,
      description: '链接文字 / Link text',
    ),
    ParkPropertyDef(
      name: 'variant',
      type: 'ParkLinkVariant',
      defaultVal: 'ParkLinkVariant.defaultLink',
      description: '链接变体：defaultLink / underline / Link variant',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null（主题 brand 色）',
      description: '文字颜色，覆盖品牌色 / Text color overriding brand',
    ),
    ParkPropertyDef(
      name: 'fontSize',
      type: 'double?',
      defaultVal: 'null（主题 body 字号）',
      description: '文字大小 / Font size',
    ),
    ParkPropertyDef(
      name: 'style',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '自定义样式 / Custom style',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用 / Disabled',
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '前置图标 / Leading icon',
    ),
    ParkPropertyDef(
      name: 'trailingIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '后置图标 / Trailing icon',
    ),
    ParkPropertyDef(
      name: 'href',
      type: 'String?',
      defaultVal: 'null',
      description: '链接地址（URL） / Link URL',
    ),
    ParkPropertyDef(
      name: 'target',
      type: 'ParkLinkTarget',
      defaultVal: 'ParkLinkTarget.self',
      description: '打开方式：self（当前上下文）/ blank（新窗口） / Open target',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于 loading 状态（显示加载转圈） / Loading state (spinner)',
    ),
    ParkPropertyDef(
      name: 'visited',
      type: 'bool',
      defaultVal: 'false',
      description: '是否已访问（改变颜色表示已访问状态） / Visited state',
    ),
    ParkPropertyDef(
      name: 'linkStyle',
      type: 'ParkLinkStyle',
      defaultVal: 'ParkLinkStyle.defaultStyle',
      description:
          '语义样式：primary / defaultStyle / danger / warning / success / Semantic style',
    ),
    ParkPropertyDef(
      name: 'linkSize',
      type: 'ParkLinkSize',
      defaultVal: 'ParkLinkSize.medium',
      description: '链接尺寸：small (12px) / medium (14px) / large (16px) / Size',
    ),
    ParkPropertyDef(
      name: 'hoverColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '悬停颜色（覆盖默认悬停效果） / Hover color',
    ),
    ParkPropertyDef(
      name: 'visitedColor',
      type: 'Color?',
      defaultVal: 'null（默认紫色）',
      description: '已访问颜色 / Visited color',
    ),
    ParkPropertyDef(
      name: 'download',
      type: 'bool',
      defaultVal: 'false',
      description: '是否触发下载（Web 场景设置 download 属性） / Trigger download (web)',
    ),
    ParkPropertyDef(
      name: 'rel',
      type: 'String?',
      defaultVal: 'null',
      description: '链接 rel 属性（Web 语义，如 noopener / noreferrer） / Link rel attribute (web)',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'VoidCallback?',
      description: '点击回调 / Tap callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
// 引入 / Import: import 'package:park_ui/park_ui.dart';
ParkLink(
  '查看详情',
  onTap: () {},
)
''',
  guide: '''
## 何时使用 / When to use
- 文字中需要嵌入可点击的链接时 / Embed clickable links in text
- 页面跳转、协议说明、外部链接等场景 / Navigation, agreements, external links

## 使用建议 / Usage tips
- 与 ParkButton 的区别：链接更轻量，适合辅助操作 / Lighter than Button; for secondary actions
- 下划线变体（underline）更适合正文中的超链接 / underline variant for inline links
- 外部链接可添加 trailingIcon 提示用户 / External links: trailingIcon hint
- disabled 状态用于不可用的链接场景 / disabled for unavailable links
- 通过 linkStyle 表达 danger / warning / success 语义 / linkStyle for semantics
- 通过 linkSize 控制 small / medium / large 字号 / linkSize for font size
- 避免将链接用于主要操作按钮，主操作用 ParkButton / Don't use links for primary actions

## 搭配推荐 / Compose with
- 搭配 ParkText 在正文中嵌入链接 / Pair with ParkText
- 搭配 ParkFooter 做页脚导航链接 / Pair with ParkFooter
- 搭配 ParkDialog 做协议确认链接 / Pair with ParkDialog

## 外部对标 / Benchmark — Ant Design NG & TDesign Flutter
### 功能 / Features
- Ant NG Typography.Link：支持 `href`、disabled、underline、icon、target（新窗口）；语义通过 `type` 有限。
- TDesign Flutter：以 `Text` + `GestureDetector` 或 `TText` 实现，无独立 Link 组件，需自行封装。
- park Link 是独立组件：defaultLink / underline 变体 + linkStyle 语义色 + linkSize + leading/trailing icon + loading/visited/href/target，对标 Ant 且补齐 TDesign 缺失。
### 示例 / Examples
- 对标 Ant `<a disabled>...</a>` → park `ParkLink('...', disabled: true)`；对标 Ant `<a href target="_blank">` → park `ParkLink('...', href: url, target: ParkLinkTarget.blank)`。
### 属性 / Props
- 差异点：park 的 `linkStyle`（primary/danger/warning/success）直接对应语义色；park `visited` 状态在 Ant 中需自行实现。

## 快速上手 / Quick Start
- 安装 / Install：`flutter pub add park_ui`
- 引入 / Import：`import 'package:park_ui/park_ui.dart';`
- SDK：Flutter >= 3.11.5 / Dart >= 3.0（与 pubspec environment 一致）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础链接',
      description: '默认链接和带下划线的链接 / default & underline',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('默认链接', onTap: () {}),
    ParkLink('下划线链接', variant: ParkLinkVariant.underline, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink('默认链接', onTap: () {}),
          ParkLink('下划线链接',
              variant: ParkLinkVariant.underline, onTap: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: '设置 disabled: true 禁用链接交互 / disabled',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('正常链接', onTap: () {}),
    ParkLink('已禁用', disabled: true, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink('正常链接', onTap: () {}),
          ParkLink('已禁用', disabled: true, onTap: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带图标的链接',
      description: '使用 icon 和 trailingIcon 在文字前后添加图标 / leading & trailing icons',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('前置图标', icon: Icon(Icons.link), onTap: () {}),
    ParkLink('外部链接', trailingIcon: Icon(Icons.open_in_new, size: _kTypography.sizeBody), variant: ParkLinkVariant.underline, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink(
            '前置图标',
            icon: const Icon(Icons.link),
            onTap: () {},
          ),
          ParkLink(
            '外部链接',
            trailingIcon:
                Icon(Icons.open_in_new, size: _kTypography.sizeBody),
            variant: ParkLinkVariant.underline,
            onTap: () {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色与字号',
      description: '通过 color 和 fontSize 自定义链接外观 / color & fontSize',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('红色链接', color: _kColors.error, onTap: () {}),
    ParkLink('大号链接', fontSize: _kTypography.sizeH3, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink('红色链接', color: _kColors.error, onTap: () {}),
          ParkLink('大号链接',
              fontSize: _kTypography.sizeH3, onTap: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '语义样式',
      description: '通过 linkStyle 表达 danger / warning / success 语义 / semantic styles',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('危险链接', linkStyle: ParkLinkStyle.danger, onTap: () {}),
    ParkLink('警告链接', linkStyle: ParkLinkStyle.warning, onTap: () {}),
    ParkLink('成功链接', linkStyle: ParkLinkStyle.success, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink('危险链接',
              linkStyle: ParkLinkStyle.danger, onTap: () {}),
          ParkLink('警告链接',
              linkStyle: ParkLinkStyle.warning, onTap: () {}),
          ParkLink('成功链接',
              linkStyle: ParkLinkStyle.success, onTap: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '链接尺寸',
      description: '通过 linkSize 切换 small / medium / large / sizes',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('小号链接', linkSize: ParkLinkSize.small, onTap: () {}),
    ParkLink('中号链接', linkSize: ParkLinkSize.medium, onTap: () {}),
    ParkLink('大号链接', linkSize: ParkLinkSize.large, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink('小号链接',
              linkSize: ParkLinkSize.small, onTap: () {}),
          ParkLink('中号链接',
              linkSize: ParkLinkSize.medium, onTap: () {}),
          ParkLink('大号链接',
              linkSize: ParkLinkSize.large, onTap: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '加载与已访问',
      description: 'loading 显示转圈；visited 表示已访问状态（默认紫色） / loading & visited',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('加载中', loading: true, onTap: () {}),
    ParkLink('已访问链接', visited: true, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink('加载中', loading: true, onTap: () {}),
          ParkLink('已访问链接', visited: true, onTap: () {}),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '前置后置组合',
      description: 'icon + trailingIcon 组合，hoverColor 自定义悬停色 / icon combo & hoverColor',
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkLink('查看详情', icon: Icon(Icons.visibility), trailingIcon: Icon(Icons.arrow_forward), hoverColor: _kColors.brandDark, onTap: () {}),
    ParkLink('更多', icon: Icon(Icons.more_horiz), variant: ParkLinkVariant.underline, onTap: () {}),
  ],
)
''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkLink(
            '查看详情',
            icon: const Icon(Icons.visibility),
            trailingIcon: const Icon(Icons.arrow_forward),
            hoverColor: _kColors.brandDark,
            onTap: () {},
          ),
          ParkLink(
            '更多',
            icon: const Icon(Icons.more_horiz),
            variant: ParkLinkVariant.underline,
            onTap: () {},
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '可交互链接（点击反馈）',
      description:
          '点击链接触发动作并更新状态文本，演示 ParkLink.onTap 用法 / Interactive: onTap updates state',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    String status = '等待点击';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkText(status, preset: ParkTextPreset.body),
        ParkLink(
          '点击我',
          onTap: () {
            status = '已触发 onTap';
            setState(() {});
          },
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          String status = '等待点击';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText(status, preset: ParkTextPreset.body),
              ParkLink(
                '点击我',
                onTap: () {
                  status = '已触发 onTap';
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkInkWell
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkInkWellSpec = ParkComponentSpec(
  name: 'ParkInkWell',
  title: '交互容器',
  category: 'base',
  description: '轻量级点击容器。为任意 child Widget 添加 Park 主题一致的交互反馈。与 ParkButton 的区别：ParkInkWell 不添加视觉样式。',
  icon: Icons.touch_app_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(name: 'child', type: 'Widget', required: true, description: '被包裹的可点击内容'),
    ParkPropertyDef(name: 'onTap', type: 'VoidCallback?', defaultVal: 'null', description: '点击回调'),
    ParkPropertyDef(name: 'disabled', type: 'bool', defaultVal: 'false', description: '禁用交互'),
    ParkPropertyDef(name: 'borderRadius', type: 'BorderRadius?', defaultVal: 'null', description: '悬停高亮圆角'),
    ParkPropertyDef(name: 'pressedScale', type: 'double', defaultVal: '0.97', description: '按下缩放比例'),
    ParkPropertyDef(name: 'pressedOpacity', type: 'double', defaultVal: '0.85', description: '按下透明度'),
    ParkPropertyDef(name: 'showHoverHighlight', type: 'bool', defaultVal: 'true', description: '显示悬停高亮'),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(name: 'onTap', signature: 'VoidCallback?', description: '点击时触发'),
    ParkEventDef(name: 'onLongPress', signature: 'VoidCallback?', description: '长按时触发'),
    ParkEventDef(name: 'onHover', signature: 'ValueChanged<bool>?', description: '悬停状态变化时触发'),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''ParkInkWell(
  onTap: () => print('tapped'),
  child: Container(padding: EdgeInsets.all(16), child: Text('可点击区域')),
)''',
  guide: '''
## 何时使用
需要添加点击反馈但不想用 ParkButton 完整样式时。

## 与 ParkButton 的区别
- ParkButton：有视觉样式的按钮
- ParkInkWell：纯交互容器，适用于非按钮场景
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础点击',
      description: '包裹任意 Widget，点击有 scale + opacity 反馈',
      code: "ParkInkWell(onTap: () {}, child: Text('点击我'))",
      builder: (BuildContext context) => SizedBox(
        height: 48,
        child: ParkInkWell(
          onTap: () => ParkToast.show(context, '点击了'),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('点击我（有缩放反馈）'),
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: 'disabled 为 true 时无交互反馈',
      code: "ParkInkWell(disabled: true, child: Text('不可点击'))",
      builder: (BuildContext context) => const SizedBox(
        height: 48,
        child: ParkInkWell(
          disabled: true,
          child: Padding(padding: EdgeInsets.all(12), child: Text('不可点击')),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '三个事件回调演示',
      description: '分别演示 onTap / onLongPress / onHover 三个回调的实时触发',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    String log = '等待交互';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkText(log, preset: ParkTextPreset.bodySmall),
        ParkInkWell(
          onTap: () { log = 'onTap 触发'; setState(() {}); },
          onLongPress: () { log = 'onLongPress 触发'; setState(() {}); },
          onHover: (h) { log = h ? 'onHover 进入' : 'onHover 离开'; setState(() {}); },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('点击 / 长按 / 悬停我'),
          ),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          String log = '等待交互';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkText(log, preset: ParkTextPreset.bodySmall),
              ParkInkWell(
                onTap: () {
                  log = 'onTap 触发';
                  setState(() {});
                },
                onLongPress: () {
                  log = 'onLongPress 触发';
                  setState(() {});
                },
                onHover: (bool h) {
                  log = h ? 'onHover 进入' : 'onHover 离开';
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('点击 / 长按 / 悬停我'),
                ),
              ),
            ],
          );
        },
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkFloatButton
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkFloatButtonSpec = ParkComponentSpec(
  name: 'ParkFloatButton',
  title: '悬浮按钮 / Float Button',
  category: 'base',
  description:
      '悬浮在页面上的操作按钮，对标 Ant Design FloatButton。'
      '支持单按钮模式与菜单模式（传入 items 列表），'
      '可配置位置、尺寸、形状、角标等。'
      ' / Floating action button anchored to page corner, '
      'supporting single-button and menu modes with position, size, shape, and badge options.',
  icon: Icons.add_circle_outline,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(name: 'icon', type: 'IconData?', defaultVal: 'null', description: '按钮图标 / Button icon'),
    ParkPropertyDef(name: 'label', type: 'String?', defaultVal: 'null', description: '按钮文字（仅 rounded 形状时显示）/ Label text (rounded shape only)'),
    ParkPropertyDef(name: 'items', type: 'List<ParkFloatButtonItem>?', defaultVal: 'null', description: '菜单项列表（传入后进入菜单模式）/ Menu items (triggers menu mode)'),
    ParkPropertyDef(name: 'position', type: 'ParkFloatButtonPosition', defaultVal: 'bottomRight', description: '悬浮位置 / Float position'),
    ParkPropertyDef(name: 'size', type: 'ParkFloatButtonSize', defaultVal: 'normal', description: '按钮尺寸（small 40px / normal 56px）/ Button size'),
    ParkPropertyDef(name: 'type', type: 'ParkFloatButtonType', defaultVal: 'defaultType', description: '按钮类型（primary 品牌色 / defaultType 白底）/ Button type'),
    ParkPropertyDef(name: 'shape', type: 'ParkFloatButtonShape', defaultVal: 'circle', description: '按钮形状（circle / rounded）/ Button shape'),
    ParkPropertyDef(name: 'tooltip', type: 'String?', defaultVal: 'null', description: '工具提示文字 / Tooltip text'),
    ParkPropertyDef(name: 'badge', type: 'int?', defaultVal: 'null', description: '角标数字 / Badge number'),
    ParkPropertyDef(name: 'badgeDot', type: 'bool', defaultVal: 'false', description: '是否显示红点角标（优先于 badge）/ Red dot badge (overrides badge)'),
    ParkPropertyDef(name: 'bottom', type: 'double?', defaultVal: 'null', description: '距底部偏移量 / Bottom offset'),
    ParkPropertyDef(name: 'side', type: 'double?', defaultVal: 'null', description: '距侧边偏移量 / Side offset'),
    ParkPropertyDef(name: 'backgroundColor', type: 'Color?', defaultVal: 'null', description: '自定义背景色 / Custom background color'),
    ParkPropertyDef(name: 'iconColor', type: 'Color?', defaultVal: 'null', description: '自定义图标色 / Custom icon color'),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(name: 'onPressed', signature: 'VoidCallback?', description: '按钮点击回调（单按钮模式）/ Tap callback (single mode)'),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkFloatButton(
  icon: Icons.add,
  onPressed: () {},
)
''',
  guide: '''
## 何时使用 / When to use
- 页面上需要一个常驻的快捷操作入口 / Persistent quick-action entry on a page
- 对标 Ant Design FloatButton 的使用场景 / Same scenarios as Ant Design FloatButton

## 使用建议 / Usage tips
- 单按钮模式：不传 items，直接使用 onPressed / Single mode: omit items, use onPressed
- 菜单模式：传入 items 列表，点击主按钮展开子菜单 / Menu mode: pass items, tap trigger to expand
- position 控制悬浮在右下角或左下角 / position controls bottom-right or bottom-left
- badge / badgeDot 提供角标能力 / badge / badgeDot for badge display
- 外部对标：Ant Design FloatButton（ng.ant.design/components/float-button）
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础悬浮按钮 / Basic',
      description: '单按钮模式，默认白底圆形 / Single button, default white circle',
      code: '''
ParkFloatButton(
  icon: Icons.add,
  onPressed: () {},
)''',
      builder: (BuildContext context) => SizedBox(
        height: 80,
        child: Stack(
          children: [
            ParkFloatButton(
              icon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '主要类型 / Primary',
      description: '品牌色背景 / Brand color background',
      code: '''
ParkFloatButton(
  icon: Icons.add,
  type: ParkFloatButtonType.primary,
  onPressed: () {},
)''',
      builder: (BuildContext context) => SizedBox(
        height: 80,
        child: Stack(
          children: [
            ParkFloatButton(
              icon: Icons.add,
              type: ParkFloatButtonType.primary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '菜单模式 / Menu mode',
      description: '传入 items 展开子菜单 / Pass items to expand sub-menu',
      code: '''
ParkFloatButton(
  icon: Icons.more_horiz,
  items: [
    ParkFloatButtonItem(icon: Icons.edit, label: '编辑'),
    ParkFloatButtonItem(icon: Icons.delete, label: '删除'),
  ],
)''',
      builder: (BuildContext context) => SizedBox(
        height: 200,
        child: Stack(
          children: [
            ParkFloatButton(
              icon: Icons.more_horiz,
              items: const [
                ParkFloatButtonItem(icon: Icons.edit, label: '编辑'),
                ParkFloatButtonItem(icon: Icons.delete, label: '删除'),
              ],
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '角标 / Badge',
      description: '显示数字角标和红点角标 / Number badge and dot badge',
      code: '''
ParkFloatButton(
  icon: Icons.notifications,
  badge: 5,
  onPressed: () {},
)''',
      builder: (BuildContext context) => SizedBox(
        height: 80,
        child: Stack(
          children: [
            ParkFloatButton(
              icon: Icons.notifications,
              badge: 5,
              onPressed: () {},
            ),
          ],
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkTitle
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTitleSpec = ParkComponentSpec(
  name: 'ParkTitle',
  title: '标题 / Title',
  category: 'base',
  description:
      '语义化标题组件，对标 Ant Design Typography.Title。'
      '提供 1-5 级标题，可选副标题和复制功能。'
      ' / Semantic title component, mirroring Ant Design Typography.Title. '
      'Provides level 1-5 headings with optional subtitle and copy support.',
  icon: Icons.title,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(name: 'text', type: 'String', required: true, description: '标题文本 / Title text'),
    ParkPropertyDef(name: 'level', type: 'int', defaultVal: '1', description: '标题级别 1-5（1 最大）/ Heading level 1-5 (1 = largest)'),
    ParkPropertyDef(name: 'subtitle', type: 'String?', defaultVal: 'null', description: '副标题 / Subtitle'),
    ParkPropertyDef(name: 'copyable', type: 'bool', defaultVal: 'false', description: '是否可复制 / Copyable'),
    ParkPropertyDef(name: 'textAlign', type: 'TextAlign?', defaultVal: 'null', description: '文本对齐 / Text alignment'),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkTitle(text: '一级标题', level: 1)
''',
  guide: '''
## 何时使用 / When to use
- 需要语义化标题排版时 / When semantic heading layout is needed
- 对标 Ant Design Typography.Title 场景 / Same as Ant Design Typography.Title

## 使用建议 / Usage tips
- level 1-5 映射到 park.typography 的 display/h1-h3/bodySmall / level 1-5 maps to display/h1-h3/bodySmall
- copyable 显示复制图标，点击复制到剪贴板 / copyable shows copy icon, copies to clipboard
- subtitle 在标题下方显示辅助文字 / subtitle shows helper text below the title
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '标题级别 / Levels',
      description: 'level 1-5 不同字号 / Different font sizes for level 1-5',
      code: '''
Column(children: [
  ParkTitle(text: '一级标题 h1', level: 1),
  ParkTitle(text: '二级标题 h2', level: 2),
  ParkTitle(text: '三级标题 h3', level: 3),
  ParkTitle(text: '四级标题 h4', level: 4),
  ParkTitle(text: '五级标题 h5', level: 5),
])''',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParkTitle(text: '一级标题 h1', level: 1),
          ParkTitle(text: '二级标题 h2', level: 2),
          ParkTitle(text: '三级标题 h3', level: 3),
          ParkTitle(text: '四级标题 h4', level: 4),
          ParkTitle(text: '五级标题 h5', level: 5),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '副标题 / Subtitle',
      description: '标题 + 副标题组合 / Title with subtitle',
      code: '''
ParkTitle(text: '带副标题', level: 2, subtitle: '这是副标题说明文字')''',
      builder: (BuildContext context) => const ParkTitle(
        text: '带副标题',
        level: 2,
        subtitle: '这是副标题说明文字',
      ),
    ),
    ParkDemoScenario(
      title: '可复制 / Copyable',
      description: '点击复制图标复制到剪贴板 / Click copy icon to clipboard',
      code: '''
ParkTitle(text: '可复制标题', level: 3, copyable: true)''',
      builder: (BuildContext context) => const ParkTitle(
        text: '可复制标题',
        level: 3,
        copyable: true,
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkParagraph
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkParagraphSpec = ParkComponentSpec(
  name: 'ParkParagraph',
  title: '段落 / Paragraph',
  category: 'base',
  description:
      '段落排版组件，对标 Ant Design Typography.Paragraph。'
      '支持最大行数省略、展开/收起、复制和编辑功能。'
      ' / Paragraph typography component, mirroring Ant Design Typography.Paragraph. '
      'Supports maxLines ellipsis, expandable collapse, copy, and edit features.',
  icon: Icons.notes,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(name: 'text', type: 'String', required: true, description: '段落文本 / Paragraph text'),
    ParkPropertyDef(name: 'maxLines', type: 'int?', defaultVal: 'null', description: '最大行数（超出省略）/ Max lines (ellipsis on overflow)'),
    ParkPropertyDef(name: 'expandable', type: 'bool', defaultVal: 'false', description: '是否可展开/收起 / Expandable'),
    ParkPropertyDef(name: 'copyable', type: 'bool', defaultVal: 'false', description: '是否可复制 / Copyable'),
    ParkPropertyDef(name: 'editable', type: 'bool', defaultVal: 'false', description: '是否显示编辑图标 / Show edit icon'),
    ParkPropertyDef(name: 'textAlign', type: 'TextAlign?', defaultVal: 'null', description: '文本对齐 / Text alignment'),
    ParkPropertyDef(name: 'expandText', type: 'String?', defaultVal: 'null', description: '自定义展开按钮文字 / Custom expand label'),
    ParkPropertyDef(name: 'collapseText', type: 'String?', defaultVal: 'null', description: '自定义收起按钮文字 / Custom collapse label'),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(name: 'onEdit', signature: 'VoidCallback?', description: '编辑按钮点击回调 / Edit button tap callback'),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkParagraph(text: '这是一段文字...')
''',
  guide: '''
## 何时使用 / When to use
- 需要段落排版、文本省略展开、复制等能力时 / When paragraph layout, text truncation with expand, or copy is needed
- 对标 Ant Design Typography.Paragraph / Same as Ant Design Typography.Paragraph

## 使用建议 / Usage tips
- maxLines + expandable 实现省略后展开/收起 / maxLines + expandable for truncation with expand/collapse
- copyable 显示复制图标 / copyable shows copy icon
- editable 显示编辑图标，点击触发 onEdit / editable shows edit icon, triggers onEdit
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础段落 / Basic',
      description: '普通段落文本 / Plain paragraph text',
      code: '''
ParkParagraph(text: '这是一段普通的段落文本，用于展示 ParkParagraph 的基础用法。')''',
      builder: (BuildContext context) => const ParkParagraph(
        text: '这是一段普通的段落文本，用于展示 ParkParagraph 的基础用法。',
      ),
    ),
    ParkDemoScenario(
      title: '省略展开 / Expandable',
      description: 'maxLines 省略 + 展开/收起 / maxLines truncation with expand/collapse',
      code: '''
ParkParagraph(
  text: '这是一段较长的文本...' * 3,
  maxLines: 2,
  expandable: true,
)''',
      builder: (BuildContext context) => ParkParagraph(
        text: List.filled(6, '这是一段较长的文本，用于演示省略和展开功能。').join(''),
        maxLines: 2,
        expandable: true,
      ),
    ),
    ParkDemoScenario(
      title: '可复制 / Copyable',
      description: '显示复制图标 / Shows copy icon',
      code: '''
ParkParagraph(text: '可复制的段落', copyable: true)''',
      builder: (BuildContext context) => const ParkParagraph(
        text: '可复制的段落，点击右侧图标可复制到剪贴板。',
        copyable: true,
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkTypography
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTypographySpec = ParkComponentSpec(
  name: 'ParkTypography',
  title: '排版体系 / Typography',
  category: 'base',
  description:
      '全局排版设计令牌体系：display / h1 / h2 / h3 / body / bodySmall / caption / overline '
      '各级字号与字重预设，通过 ParkText / ParkTitle 等组件消费。'
      ' / Global typography design-token system: display / h1 / h2 / h3 / body / bodySmall / caption / overline '
      'size & weight presets, consumed by ParkText / ParkTitle and friends.',
  icon: Icons.format_size,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'sizeDisplay',
      type: 'double',
      defaultVal: '32',
      description: 'display 级字号（页面大标题）/ Display size',
    ),
    ParkPropertyDef(
      name: 'sizeH1',
      type: 'double',
      defaultVal: '24',
      description: 'h1 字号 / H1 size',
    ),
    ParkPropertyDef(
      name: 'sizeH2',
      type: 'double',
      defaultVal: '20',
      description: 'h2 字号 / H2 size',
    ),
    ParkPropertyDef(
      name: 'sizeH3',
      type: 'double',
      defaultVal: '17',
      description: 'h3 字号 / H3 size',
    ),
    ParkPropertyDef(
      name: 'sizeBody',
      type: 'double',
      defaultVal: '15',
      description: '正文字号 / Body size',
    ),
    ParkPropertyDef(
      name: 'sizeBodySmall',
      type: 'double',
      defaultVal: '13',
      description: '小号正文 / Small body size',
    ),
    ParkPropertyDef(
      name: 'sizeCaption',
      type: 'double',
      defaultVal: '12',
      description: '辅助说明字号 / Caption size',
    ),
    ParkPropertyDef(
      name: 'weightRegular',
      type: 'FontWeight',
      defaultVal: 'w400',
      description: '常规字重 / Regular weight',
    ),
    ParkPropertyDef(
      name: 'weightMedium',
      type: 'FontWeight',
      defaultVal: 'w500',
      description: '中等字重 / Medium weight',
    ),
    ParkPropertyDef(
      name: 'weightBold',
      type: 'FontWeight',
      defaultVal: 'w600',
      description: '加粗字重 / Bold weight',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
// 排版令牌通过主题注入，组件自动消费：
ParkText('标题', preset: ParkTextPreset.h2)
ParkText('正文', preset: ParkTextPreset.body)
ParkTitle('页面标题', level: 1)

// 直接读取令牌值：
final typography = ParkTheme.of(context).typography;
final h2Size = typography.sizeH2;
''',
  guide: '''
## 何时使用 / When to use
- 需要统一页面字阶时，使用排版预设而不是散落的魔法字号
- ParkText / ParkTitle / ParkParagraph 已内置预设消费

## 使用建议 / Usage tips
- 标题层级：display（营销大标题）> h1 > h2 > h3
- 正文：body / bodySmall；辅助信息：caption；标签徽标：overline
- 语义组件（按钮、输入框）字号由组件自身从令牌读取，无需手工设置
- 暗色主题下颜色自动切换，字号令牌保持不变
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '字号预设 / Preset sizes',
      description: 'display 到 overline 全字阶预览 / Full size scale preview',
      code: '''
ParkText('Display 32', preset: ParkTextPreset.display)
ParkText('H1 24', preset: ParkTextPreset.h1)
ParkText('H2 20', preset: ParkTextPreset.h2)
ParkText('H3 17', preset: ParkTextPreset.h3)
ParkText('Body 15', preset: ParkTextPreset.body)
ParkText('Caption 12', preset: ParkTextPreset.caption)
ParkText('OVERLINE', preset: ParkTextPreset.overline)''',
      builder: (BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          ParkText('Display 32', preset: ParkTextPreset.display),
          SizedBox(height: 4),
          ParkText('H1 24', preset: ParkTextPreset.h1),
          SizedBox(height: 4),
          ParkText('H2 20', preset: ParkTextPreset.h2),
          SizedBox(height: 4),
          ParkText('H3 17', preset: ParkTextPreset.h3),
          SizedBox(height: 4),
          ParkText('Body 15', preset: ParkTextPreset.body),
          SizedBox(height: 4),
          ParkText('Body Small 13', preset: ParkTextPreset.bodySmall),
          SizedBox(height: 4),
          ParkText('Caption 12', preset: ParkTextPreset.caption),
          SizedBox(height: 4),
          ParkText('OVERLINE 11', preset: ParkTextPreset.overline),
        ],
      ),
    ),
  ],
);
