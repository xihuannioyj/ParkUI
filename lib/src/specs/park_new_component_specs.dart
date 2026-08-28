import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

// 命名间距令牌（避免魔法数字 / Avoid magic numbers）
const double _kGapSm = 8;

/// 设计令牌常量（与 park_base_specs.dart 保持一致，供 demo 复用，禁止裸色）。
final ParkColors _kColors = ParkColors.light();
final ParkSpacing _kSpacing = ParkSpacing.defaults();

// Countdown 数字块 — Controller demo code.
const String _kCDControllerCode = r'''
ParkCountdownController _controller = ParkCountdownController(
  remaining: Duration(seconds: 30),
);
ParkCountdown(
  remaining: Duration(seconds: 30),
  controller: _controller,
)
''';

// Alert 可关闭 demo 的展示代码。
const String _kAlertOnCloseCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    bool visible = true;
    return visible
        ? ParkAlert(
            type: ParkAlertType.info,
            message: '点击右上角关闭',
            closable: true,
            onClose: () => setState(() => visible = false),
          )
        : const Text('已关闭', style: TextStyle(fontSize: 14, color: _kColors.textSecondary));
  },
)''';

// Layout demo 的展示代码。
const String _kLayoutStdCode = r'''
SizedBox(
  height: 260,
  child: ParkLayout(
    header: Container(height: 44, color: _kColors.surface, child: const Center(child: Text('顶栏'))),
    sidebar: Container(width: 110, color: _kColors.background, child: const Center(child: Text('侧边栏'))),
    body: const Center(child: Text('内容区域')),
    footer: Container(height: 32, color: _kColors.surface, child: const Center(child: Text('页脚'))),
  ),
)''';
const String _kLayoutRightCode = r'''
SizedBox(
  height: 260,
  child: ParkLayout(
    sidebarLeft: false,
    header: Container(height: 44, color: _kColors.surface, child: const Center(child: Text('顶栏'))),
    sidebar: Container(width: 110, color: _kColors.background, child: const Center(child: Text('侧边栏'))),
    body: const Center(child: Text('内容区域')),
    footer: Container(height: 32, color: _kColors.surface, child: const Center(child: Text('页脚'))),
  ),
)''';
const String _kLayoutNoDividerCode = r'''
SizedBox(
  height: 260,
  child: ParkLayout(
    showSidebarDivider: false,
    header: Container(height: 44, color: _kColors.surface, child: const Center(child: Text('顶栏'))),
    sidebar: Container(width: 110, color: _kColors.background, child: const Center(child: Text('侧边栏'))),
    body: const Center(child: Text('内容区域')),
  ),
)''';
const String _kLayoutHeaderOnlyCode = r'''
SizedBox(
  height: 200,
  child: ParkLayout(
    header: Container(height: 44, color: _kColors.surface, child: const Center(child: Text('顶栏'))),
    body: const Center(child: Text('仅内容区域')),
  ),
)''';

// Anchor 交互 demo 的展示代码。
const String _kAnchorOnChangedCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    String selected = 'a';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkAnchor(
          items: const [
            ParkAnchorItem(key: 'a', label: '第一部分'),
            ParkAnchorItem(key: 'b', label: '第二部分'),
          ],
          onChanged: (key) => setState(() => selected = key),
        ),
        SizedBox(height: _kSpacing.sm),
        Text('当前选中：$selected', style: TextStyle(fontSize: 13, color: _kColors.textSecondary)),
      ],
    );
  },
)''';

// ParkAnchor 滚动演示代码。
const String _kAnchorScrollCode = r'''
ParkAnchor(
  scrollController: _scrollController,
  items: const [
    ParkAnchorItem(key: 'section1', label: '基础信息'),
    ParkAnchorItem(key: 'section2', label: '详细信息'),
    ParkAnchorItem(key: 'section3', label: '设置'),
  ],
  onChanged: (key) => print('选中: $key'),
)''';

// Menu demo 的展示代码。
const String _kMenuMultiCode = r'''
ParkMenu(items: const [
  ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
  ParkMenuItem(key: '2', label: '设置', icon: Icons.settings, children: [
    ParkMenuItem(key: '2-1', label: '个人资料'),
  ]),
])''';
const String _kMenuSelectedCode = r'''
ParkMenu(selectedKey: '1', items: const [
  ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
  ParkMenuItem(key: '2', label: '设置', icon: Icons.settings, children: [
    ParkMenuItem(key: '2-1', label: '个人资料'),
  ]),
])''';
const String _kMenuExpandedCode = r'''
ParkMenu(defaultExpandedKeys: {'2'}, items: const [
  ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
  ParkMenuItem(key: '2', label: '设置', icon: Icons.settings, children: [
    ParkMenuItem(key: '2-1', label: '个人资料'),
  ]),
])''';
const String _kMenuLightCode = r'''
ParkMenu(light: true, items: const [
  ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
  ParkMenuItem(key: '2', label: '设置', icon: Icons.settings, children: [
    ParkMenuItem(key: '2-1', label: '个人资料'),
  ]),
])''';
const String _kMenuOnSelectCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    String selected = '-';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkMenu(
          items: const [
            ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
            ParkMenuItem(key: '2', label: '设置', icon: Icons.settings, children: [
              ParkMenuItem(key: '2-1', label: '个人资料'),
            ]),
          ],
          onSelect: (key) => setState(() => selected = key),
        ),
        SizedBox(height: _kSpacing.sm),
        Text('当前选中：$selected', style: TextStyle(fontSize: 13, color: _kColors.textSecondary)),
      ],
    );
  },
)''';

// ColorPicker 交互 demo 的展示代码。
const String _kCPOnChangedCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    Color color = _kColors.brand;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkColorPicker(
          value: color,
          onChanged: (c) => setState(() => color = c),
        ),
        SizedBox(height: _kSpacing.sm),
        Text('当前：#${color.toARGB32().toRadixString(16).padLeft(8, '0')}', style: TextStyle(fontSize: 13, color: _kColors.textSecondary)),
      ],
    );
  },
)''';

// AutoComplete demo 的展示代码。
const String _kACOnSelectedCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    String selected = '-';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkAutoComplete(
          options: const ['apple', 'banana', 'cherry', 'date'],
          onSelected: (v) => setState(() => selected = v),
        ),
        SizedBox(height: _kSpacing.sm),
        Text('已选中：$selected', style: TextStyle(fontSize: 13, color: _kColors.textSecondary)),
      ],
    );
  },
)''';
const String _kACOnChangedCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    String text = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkAutoComplete(
          options: const ['apple', 'banana', 'cherry', 'date'],
          onChanged: (v) => setState(() => text = v),
        ),
        SizedBox(height: _kSpacing.sm),
        Text('输入：$text', style: TextStyle(fontSize: 13, color: _kColors.textSecondary)),
      ],
    );
  },
)''';
const String _kACFilterCode = r'''
ParkAutoComplete(
  filterFn: (input, option) => option.toLowerCase().startsWith(input.toLowerCase()),
  options: const ['apple', 'banana', 'cherry', 'date'],
)''';

// InputNumber 交互 demo 的展示代码。
const String _kINOnChangedCode = r'''
StatefulBuilder(
  builder: (context, setState) {
    double value = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkInputNumber(
          min: 0,
          max: 100,
          step: 5,
          onChanged: (v) => setState(() => value = v),
        ),
        SizedBox(height: _kSpacing.sm),
        Text('当前值：${value.toInt()}', style: TextStyle(fontSize: 13, color: _kColors.textSecondary)),
      ],
    );
  },
)''';

/// 新增组件规格（本轮新增的 15 个组件）。
Map<String, ParkComponentSpec> get parkNewComponentSpecs =>
    <String, ParkComponentSpec>{
      'ParkCountdown': _parkCountdownSpec,
      'ParkQRCode': _parkQRCodeSpec,
      'ParkSpace': _parkSpaceSpec,
      'ParkPopconfirm': _parkPopconfirmSpec,
      'ParkAlert': _parkAlertSpec,
      'ParkLayout': _parkLayoutSpec,
      'ParkAnchor': _parkAnchorSpec,
      'ParkMenu': _parkMenuSpec,
      'ParkTimePicker': _parkTimePickerSpec,
      'ParkColorPicker': _parkColorPickerSpec,
      'ParkAutoComplete': _parkAutoCompleteSpec,
      'ParkInputNumber': _parkInputNumberSpec,
      'ParkWatermark': _parkWatermarkSpec,
      'ParkNotification': _parkNotificationSpec,
      'ParkTransfer': _parkTransferSpec,
      'ParkTree': _parkTreeSpec,
      'ParkApp': _parkAppSpec,
      'ParkMap': _parkMapSpec,
    };

// ────────────────────────────────────────────────────────────────────────────
// Base
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkSpaceSpec = ParkComponentSpec(
  name: 'ParkSpace',
  title: '间距组件',
  category: 'base',
  description: '统一控制子元素之间的间距，替代手动添加 SizedBox。支持水平、垂直和自动换行三种模式。',
  icon: Icons.space_bar,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      defaultVal: '—',
      description: '子元素列表 / Child widgets',
      required: true,
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'double',
      defaultVal: '8',
      description: '间距大小 / Spacing size (px)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'direction',
      type: 'Axis',
      defaultVal: 'horizontal',
      description: '排列方向 / Layout direction',
      required: false,
    ),
    ParkPropertyDef(
      name: 'wrap',
      type: 'bool',
      defaultVal: 'false',
      description: '是否自动换行（仅水平有效）/ Wrap children',
      required: false,
    ),
    ParkPropertyDef(
      name: 'mainAxisAlignment',
      type: 'MainAxisAlignment',
      defaultVal: 'start',
      description: '主轴对齐方式 / Main axis alignment',
      required: false,
    ),
    ParkPropertyDef(
      name: 'crossAxisAlignment',
      type: 'CrossAxisAlignment',
      defaultVal: 'center',
      description: '交叉轴对齐方式 / Cross axis alignment',
      required: false,
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkSpace.xs(...)',
      signature: 'ParkSpace',
      description: '水平 4px 间距工厂 / 4px horizontal preset',
    ),
    ParkMethodDef(
      name: 'ParkSpace.sm(...)',
      signature: 'ParkSpace',
      description: '水平 8px 间距工厂 / 8px horizontal preset',
    ),
    ParkMethodDef(
      name: 'ParkSpace.md(...)',
      signature: 'ParkSpace',
      description: '水平 16px 间距工厂 / 16px horizontal preset',
    ),
    ParkMethodDef(
      name: 'ParkSpace.lg(...)',
      signature: 'ParkSpace',
      description: '水平 24px 间距工厂 / 24px horizontal preset',
    ),
    ParkMethodDef(
      name: 'ParkSpace.xl(...)',
      signature: 'ParkSpace',
      description: '水平 32px 间距工厂 / 32px horizontal preset',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '水平间距',
      description: '默认水平 8px 间距 / Default 8px horizontal',
      code: 'ParkSpace(size: 8, children: [Text("A"), Text("B")])',
      builder: _buildSpaceHDemo,
    ),
    ParkDemoScenario(
      title: '垂直间距',
      description: '垂直排列 / Vertical layout',
      code: 'ParkSpace(size: 12, direction: Axis.vertical, children: [...])',
      builder: _buildSpaceVDemo,
    ),
    ParkDemoScenario(
      title: '自动换行',
      description: '水平自动换行 / Auto wrap',
      code: 'ParkSpace(wrap: true, size: 8, children: [...])',
      builder: _buildSpaceWrapDemo,
    ),
    ParkDemoScenario(
      title: '预设间距工厂',
      description: 'xs/sm/md/lg/xl 五级预设 / xs–xl presets',
      code: 'ParkSpace.md(children: [a, b, c])',
      builder: _buildSpacePresetDemo,
    ),
    ParkDemoScenario(
      title: '主轴对齐',
      description: 'spaceBetween 两端对齐 / Justify content',
      code:
          'ParkSpace(size: 8, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [...])',
      builder: _buildSpaceAlignDemo,
    ),
  ],
  basicUsageCode: '''ParkSpace(
  size: 16,
  children: [Text('A'), Text('B'), Text('C')],
)''',
  guide: '''
## 何时使用 / When to use
- 替代手动在 children 之间逐个插入 SizedBox / Padding，统一管理一组元素间的水平或垂直间距 / Replacing manual SizedBox/Padding between children
- 水平排列一组按钮、标签、图标等内联元素，如操作区、导航条目 / Horizontally arranging buttons, tags or icons (action areas, nav items)
- 垂直堆叠表单字段、列表条目等区块，保证间距一致 / Vertically stacking form fields or list rows with consistent gaps
- 需要自动换行的流式布局，如标签云、筛选条件组 / Flow layouts that auto-wrap, e.g. tag clouds, filter groups

## 使用建议 / Usage tips
- size 默认 8px；优先使用 xs(4)/sm(8)/md(16)/lg(24)/xl(32) 预设工厂，保证间距体系与设计令牌一致 / Prefer the xs–xl preset factories over raw sizes
- wrap 仅在水平方向生效：为 true 时改用 Wrap 布局，换行间距 runSpacing 与 spacing 同值；垂直方向请使用多个 ParkSpace 或外层容器 / wrap applies to horizontal direction only
- children 为空时组件渲染为 SizedBox.shrink()，不会产生额外占位，可安全用于动态列表 / Empty children render as zero-size, safe for dynamic lists
- 水平/垂直模式通过在 children 之间插入 SizedBox 实现间距，不要再给每个 child 重复加 margin，避免间距翻倍 / Don't double-pad children with extra margins
- mainAxisAlignment / crossAxisAlignment 直接透传给 Row/Column/Wrap，可用 spaceBetween / spaceEvenly 实现两端对齐或均分布局 / Alignment params pass through to the underlying layout
- 自定义 size 建议取 4 的倍数，与 4px 基准间距体系保持像素对齐 / Keep custom sizes multiples of 4 for pixel alignment

## 搭配推荐 / Compose with
- 搭配 ParkTag / ParkBadge 组合标签云或状态徽标行 / ParkTag or ParkBadge for tag clouds and status rows
- 搭配 ParkButtonGroup 或 ParkButton 组合「确定 / 取消」等操作区 / ParkButtonGroup or ParkButton for action areas
- 搭配 ParkFormRow / ParkFormSection 垂直排布表单字段 / ParkFormRow and ParkFormSection for vertical form layouts

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.*（不消费） | 纯布局组件，不渲染色彩令牌，背景与分隔线由外层容器决定 |
| 字体 | typography.*（不消费） | 不渲染文字，不消费字体令牌 |
| 间距 | spacing.xs / sm / base / xl / xxl | 预设工厂 4/8/16/24/32 与 spacing 令牌数值对齐（md=16 对应 base，lg=24 对应 xl，xl=32 对应 xxl） |
''',
);

// ────────────────────────────────────────────────────────────────────────────
// Display
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkCountdownSpec = ParkComponentSpec(
  name: 'ParkCountdown',
  title: '倒计时数字块',
  category: 'display',
  description:
      '倒计时数字块组件，显示 HH:MM:SS 格式的数字方块与冒号分隔符，支持多种尺寸和主题风格。基于 Timer 驱动，零三方依赖。',
  icon: Icons.timer,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'remaining',
      type: 'Duration',
      defaultVal: '—',
      description: '剩余时间 / Remaining duration',
      required: true,
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkCountdownSize',
      defaultVal: 'medium',
      description: '尺寸（small/medium/large）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'theme',
      type: 'ParkCountdownTheme',
      defaultVal: 'defaultStyle',
      description: '主题风格（defaultStyle/round/square）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'controller',
      type: 'ParkCountdownController?',
      defaultVal: 'null',
      description: '外部控制器，调用 start/pause/reset',
      required: false,
    ),
    ParkPropertyDef(
      name: 'formatter',
      type: 'String Function(int)?',
      defaultVal: 'null',
      description: '自定义数字格式化回调',
      required: false,
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '骨架屏加载态（shimmer 动画）',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onFinish',
      signature: 'VoidCallback?',
      description: '倒计时结束回调',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'controller.start()',
      signature: 'void',
      description: '开始倒计时',
    ),
    ParkMethodDef(
      name: 'controller.pause()',
      signature: 'void',
      description: '暂停倒计时',
    ),
    ParkMethodDef(
      name: 'controller.reset()',
      signature: 'void',
      description: '重置倒计时到初始时间',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础倒计时',
      description: '倒计时 5 分钟',
      code: "const ParkCountdown(remaining: Duration(minutes: 5))",
      builder: _buildCDDemo1,
    ),
    ParkDemoScenario(
      title: '小尺寸',
      description: 'small 尺寸',
      code:
          "const ParkCountdown(remaining: Duration(hours: 1), size: ParkCountdownSize.small)",
      builder: _buildCDDemo2,
    ),
    ParkDemoScenario(
      title: '中尺寸',
      description: 'medium 尺寸',
      code:
          "const ParkCountdown(remaining: Duration(hours: 1), size: ParkCountdownSize.medium)",
      builder: _buildCDDemo3,
    ),
    ParkDemoScenario(
      title: '大尺寸',
      description: 'large 尺寸',
      code:
          "const ParkCountdown(remaining: Duration(hours: 1), size: ParkCountdownSize.large)",
      builder: _buildCDDemo4,
    ),
    ParkDemoScenario(
      title: '圆形主题',
      description: 'round 风格',
      code:
          "const ParkCountdown(remaining: Duration(minutes: 10), theme: ParkCountdownTheme.round)",
      builder: _buildCDDemo5,
    ),
    ParkDemoScenario(
      title: '直角主题',
      description: 'square 风格',
      code:
          "const ParkCountdown(remaining: Duration(minutes: 10), theme: ParkCountdownTheme.square)",
      builder: _buildCDDemo6,
    ),
    ParkDemoScenario(
      title: '加载态',
      description: 'shimmer 骨架屏',
      code:
          "const ParkCountdown(remaining: Duration(minutes: 3), loading: true)",
      builder: _buildCDDemo7,
    ),
    ParkDemoScenario(
      title: '控制器',
      description: 'Controller start/pause/reset',
      code: _kCDControllerCode,
      builder: _buildCDController,
    ),
  ],
  basicUsageCode: '''ParkCountdown(
  remaining: Duration(minutes: 5),
  onFinish: () => print('结束'),
)''',
  guide: '''
## 使用指南
显示 HH:MM:SS 数字方块。支持三种尺寸（small/medium/large）和三种主题（defaultStyle/round/square）。
通过 ParkCountdownController 实现 start/pause/reset 控制。可设置 formatter 自定义数字格式，loading 显示骨架屏。
''',
);

final ParkComponentSpec _parkQRCodeSpec = ParkComponentSpec(
  name: 'ParkQRCode',
  title: '二维码',
  category: 'display',
  description:
      '二维码生成组件，基于 qr_flutter 生成真实可扫描二维码（最小三方依赖）。支持纠错等级（L/M/Q/H）与 Logo 嵌入。',
  icon: Icons.qr_code,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'data',
      type: 'String',
      defaultVal: '—',
      description: '二维码内容（URL/文本）/ Content',
      required: true,
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'double',
      defaultVal: '200',
      description: '二维码尺寸 / Size (px)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'foregroundColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '前景色（默认黑）/ Foreground color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '背景色（默认白）/ Background color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'errorCorrectionLevel',
      type: 'ParkQRErrorCorrectionLevel',
      defaultVal: 'medium',
      description: '纠错等级 L/M/Q/H / EC level',
      required: false,
    ),
    ParkPropertyDef(
      name: 'logo',
      type: 'Widget?',
      defaultVal: 'null',
      description: '嵌入的 Logo / Center logo',
      required: false,
    ),
    ParkPropertyDef(
      name: 'logoSize',
      type: 'double?',
      defaultVal: 'null',
      description: 'Logo 尺寸（默认 size*0.25）/ Logo size',
      required: false,
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础二维码',
      description: '生成 URL 二维码 / Basic QR',
      code: 'ParkQRCode(data: "https://flutter.dev")',
      builder: _buildQRDemo1,
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description: '前景色 + 背景色 / Custom colors',
      code:
          'ParkQRCode(data: "PARK", foregroundColor: Colors.teal, backgroundColor: Colors.amber)',
      builder: _buildQRDemo2,
    ),
    ParkDemoScenario(
      title: '嵌入 Logo',
      description: '中心 Logo 嵌入 / Center logo',
      code:
          'ParkQRCode(data: "LOGO", logo: Icon(Icons.flutter_dash), logoSize: 48)',
      builder: _buildQRDemo3,
    ),
    ParkDemoScenario(
      title: '高纠错等级',
      description: 'H 级纠错 / High EC level',
      code:
          'ParkQRCode(data: "https://park.dev", errorCorrectionLevel: ParkQRErrorCorrectionLevel.high)',
      builder: _buildQRDemo4,
    ),
  ],
  basicUsageCode: '''ParkQRCode(data: 'https://example.com', size: 200)''',
  guide: '''
## 何时使用 / When to use
- 需要展示可被标准扫码器识别、可正常跳转的真实二维码（支付、加好友、下载链接等）/ Displaying real scannable QR codes for payment, contacts, deep links
- 需要嵌入中心 Logo 的品牌化二维码 / Branded QR codes with a center logo
- 需要跟随主题定制前景/背景配色的二维码（浅色卡片、暗色模式）/ QR codes color-matched to light/dark themes

## 使用建议 / Usage tips
- data 为必填参数，内容为空或纯空白时组件回退为纯色占位块而非二维码，业务侧应先校验数据 / data is required; empty input renders a plain placeholder
- 嵌入 logo 会遮挡部分码面，建议同时把 errorCorrectionLevel 提升到 quartile 或 high，弥补纠错能力损失 / Raise the EC level to Q/H when embedding a logo
- logoSize 默认等于 size * 0.25，logo 过大会显著降低识别成功率，尽量不超过二维码面积的 1/4 / Keep the logo around 25% of the QR area
- 前景色与背景色需保持足够对比度（默认 textPrimary 前景 / surface 背景），低对比度组合可能导致扫码失败 / Keep foreground/background contrast high
- 数据越长二维码矩阵越密集（版本自动选择），长 URL 建议先用短链服务压缩后再编码 / Longer data means a denser matrix; shorten long URLs first
- size 为固定像素尺寸，请按扫码距离与容器宽度选取，避免过小导致无法识别 / size is fixed px — choose it for the actual scan distance

## 搭配推荐 / Compose with
- 搭配 ParkCard 承载二维码，适合支付、分享等卡片化展示场景 / ParkCard as a container
- 搭配 ParkButton 提供「保存 / 分享」等操作入口 / ParkButton for actions
- 搭配 ParkTooltip 在悬停或长按时提示 data 内容 / ParkTooltip to reveal the encoded data

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.surface / colors.textPrimary | 未显式传 backgroundColor / foregroundColor 时作为默认底色与前景色 |
| 字体 | typography.* | 二维码为矩阵图形，组件不渲染文字，不消费字体令牌 |
| 间距 | spacing.* | QrImageView 内边距为 0，周边留白由外层容器（如 ParkCard 内边距）控制 |
''',
);

final ParkComponentSpec _parkWatermarkSpec = ParkComponentSpec(
  name: 'ParkWatermark',
  title: '水印',
  category: 'display',
  description: '在内容区域叠加半透明水印，支持文字旋转和间距配置。',
  icon: Icons.water,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'text',
      type: 'String?',
      defaultVal: 'null',
      description: '水印文字（与 image 二选一）/ Text',
      required: false,
    ),
    ParkPropertyDef(
      name: 'image',
      type: 'Widget?',
      defaultVal: 'null',
      description: '水印图片（与 text 二选一）/ Image',
      required: false,
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null',
      description: '水印颜色（默认文字色 0.1 透明）/ Color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'fontSize',
      type: 'double',
      defaultVal: '14',
      description: '水印字号 / Font size',
      required: false,
    ),
    ParkPropertyDef(
      name: 'rotate',
      type: 'double',
      defaultVal: '-25',
      description: '旋转角度（度）/ Rotation (deg)',
      required: false,
    ),
    ParkPropertyDef(
      name: 'gapX',
      type: 'double',
      defaultVal: '120',
      description: '横向间距 / Horizontal gap',
      required: false,
    ),
    ParkPropertyDef(
      name: 'gapY',
      type: 'double',
      defaultVal: '100',
      description: '纵向间距 / Vertical gap',
      required: false,
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      defaultVal: '—',
      description: '被包裹的内容 / Wrapped content',
      required: true,
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '文字水印',
      description: '叠加「机密」水印 / Text watermark',
      code: 'ParkWatermark(text: "机密", child: content)',
      builder: _buildWMDemo1,
    ),
    ParkDemoScenario(
      title: '图片水印',
      description: 'Icon 作为水印 / Image watermark',
      code:
          'ParkWatermark(image: Icon(Icons.verified), gapX: 90, gapY: 70, child: content)',
      builder: _buildWMDemo2,
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description: '品牌色半透明水印 / Brand color',
      code: 'ParkWatermark(text: "DRAFT", color: warningColor, child: content)',
      builder: _buildWMDemo3,
    ),
    ParkDemoScenario(
      title: '间距与旋转',
      description: '调整 gap / rotate / Spacing & rotation',
      code:
          'ParkWatermark(text: "PARK", rotate: -15, gapX: 80, gapY: 80, child: content)',
      builder: _buildWMDemo4,
    ),
  ],
  basicUsageCode: '''ParkWatermark(text: '机密文件', child: myContent)''',
  guide: '''
## 何时使用 / When to use
- 为机密文件、草稿、审批单据等敏感内容叠加版权或状态标识 / Adding copyright or status marks to confidential content
- 在表单、表格、图片等防截屏扩散场景中做视觉威慑 / Deterring screenshot leaks over forms, tables and images
- 需要品牌水印（图片模式）铺满内容区域的场景 / Branding content with a tiled image watermark

## 使用建议 / Usage tips
- text 与 image 必须二选一（构造器断言强制），同时传入时 image 优先渲染 / Either text or image is required; image wins when both are set
- 水印层由 IgnorePointer 包裹，默认不阻挡内容的点击、滚动等交互 / The overlay never blocks interaction
- 默认颜色为 textPrimary 的 10% 透明度，需要更醒目或更淡时可显式传入 color / Default color is textPrimary at 10% alpha
- gapX / gapY 小于等于 0 时内部会钳制到最小间距，避免平铺循环死循环卡死 UI / Gaps are clamped to avoid an infinite paint loop
- image 模式通过 RenderRepaintBoundary.toImage 捕获一次并缓存，图片 widget 引用不变时不会重复捕获；超大图片水印注意内存与首帧开销 / Image is captured once and cached; watch memory for huge images
- 文字水印的 color / fontSize / rotate / gapX / gapY 任一变化都会触发重绘，动态切换参数时注意性能 / Any param change triggers repaint

## 搭配推荐 / Compose with
- 包裹 ParkTable、ParkCard、ParkResult 等承载敏感数据的容器做版权标识 / Wrap sensitive containers like ParkTable or ParkCard
- 在 ParkSheetScaffold、ParkDrawer 等弹层内容上叠加水印（如审批预览）/ Overlay on sheets and drawers
- 搭配 ParkButton 提供「预览水印 / 移除水印」等切换操作（条件渲染被包裹内容）/ Toggle the watermark with a ParkButton

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.textPrimary | 默认水印色为 textPrimary.withAlpha(26)，即 10% 透明度 |
| 字体 | typography.sizeBodySmall | 组件不直接消费令牌，默认 fontSize 14 与该值（14px）同值，可作自定义参考 |
| 间距 | spacing.* | 平铺间距由 gapX / gapY 控制，不消费令牌；需要 8px 倍数对齐时可参考 spacing 体系 |
''',
);

final ParkComponentSpec _parkTreeSpec = ParkComponentSpec(
  name: 'ParkTree',
  title: '树形控件',
  category: 'display',
  description: '递归树形控件，支持展开/折叠、选中/多选、图标和异步加载。',
  icon: Icons.account_tree,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'data',
      type: 'List<ParkTreeNode>',
      defaultVal: '—',
      description: '树节点数据 / Tree data',
      required: true,
    ),
    ParkPropertyDef(
      name: 'onSelect',
      type: 'void Function(String key)?',
      defaultVal: 'null',
      description: '节点选中回调 / Select callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onMultiSelect',
      type: 'void Function(List<String>)?',
      defaultVal: 'null',
      description: '多选回调（仅 multiSelect）/ Multi-select callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'multiSelect',
      type: 'bool',
      defaultVal: 'false',
      description: '是否多选 / Multi-select mode',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedKeys',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '受控选中 key / Controlled selected keys',
      required: false,
    ),
    ParkPropertyDef(
      name: 'defaultExpandedKeys',
      type: 'Set<String>?',
      defaultVal: 'null',
      description: '默认展开 key / Default expanded keys',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showLine',
      type: 'bool',
      defaultVal: 'false',
      description: '显示连线 / Show guide lines',
      required: false,
    ),
    ParkPropertyDef(
      name: 'nodeIcon',
      type: 'IconData?',
      defaultVal: 'null',
      description: '自定义节点图标 / Custom node icon',
      required: false,
    ),
    ParkPropertyDef(
      name: 'expandIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义展开图标 / Custom expand icon',
      required: false,
    ),
    ParkPropertyDef(
      name: 'expandRotate',
      type: 'double',
      defaultVal: '90',
      description: '展开图标旋转角度 / Expand icon rotate',
      required: false,
    ),
    ParkPropertyDef(
      name: 'loadChildren',
      type: 'Future<List<ParkTreeNode>> Function(ParkTreeNode)?',
      defaultVal: 'null',
      description: '异步加载子节点 / Async load children',
      required: false,
    ),
    ParkPropertyDef(
      name: 'draggable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用节点拖拽排序 / Enable drag-and-drop reordering',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onDragReorder',
      type: 'void Function(int, int)?',
      defaultVal: 'null',
      description: '拖拽排序回调（oldIndex, newIndex 为同级节点中的索引）/ Drag reorder callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'searchQuery',
      type: 'String?',
      defaultVal: 'null',
      description: '搜索关键词，不为 null 时高亮匹配文字并展开包含匹配的父节点 / Search query for highlight & expand',
      required: false,
    ),
    ParkPropertyDef(
      name: 'checkStrictly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否严格勾选（父子节点勾选独立）/ Strict check mode (parent-child independent)',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSelect',
      signature: 'void Function(String key)?',
      description: '点击节点（非多选）触发 / Fired on node tap',
    ),
    ParkEventDef(
      name: 'onMultiSelect',
      signature: 'void Function(List<String> selectedKeys)?',
      description: '多选变化触发 / Fired when multi-selection changes',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础树',
      description: '两级目录结构 / Basic tree',
      code:
          'ParkTree(data: [ParkTreeNode(key: "1", label: "根节点", children: [...])])',
      builder: _buildTreeDemo1,
    ),
    ParkDemoScenario(
      title: '多选树',
      description: '带 checkbox 的多选 / Multi-select',
      code: 'ParkTree(multiSelect: true, ...)',
      builder: _buildTreeDemo2,
    ),
    ParkDemoScenario(
      title: '选中回调',
      description: 'onSelect 实时回显 / onSelect callback',
      code:
          'StatefulBuilder(builder: (ctx, setState) {\n  String? sel;\n  return ParkTree(data: [...], selectedKeys: sel != null ? [sel!] : null, onSelect: (k) { sel = k; setState(() {}); });\n})',
      builder: _buildTreeSelectDemo,
    ),
    ParkDemoScenario(
      title: '显示连线',
      description: 'showLine 引导线 / Guide lines',
      code: 'ParkTree(showLine: true, data: [...])',
      builder: _buildTreeLineDemo,
    ),
    ParkDemoScenario(
      title: '节点图标',
      description: 'nodeIcon 统一图标 / Node icons',
      code: 'ParkTree(nodeIcon: Icons.folder, data: [...])',
      builder: _buildTreeIconDemo,
    ),
    ParkDemoScenario(
      title: '多选回调 onMultiSelect',
      description:
          'multiSelect 模式下 onMultiSelect 实时回显已选 key 列表 / onMultiSelect callback',
      code: '''StatefulBuilder(
  builder: (context, setState) {
    List<String> selected = <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('已选: \${selected.join(", ")}'),
        SizedBox(height: 8),
        ParkTree(
          multiSelect: true,
          data: <ParkTreeNode>[
            ParkTreeNode(key: '1', label: '根节点', children: <ParkTreeNode>[
              ParkTreeNode(key: '1-1', label: '子节点A'),
              ParkTreeNode(key: '1-2', label: '子节点B'),
            ]),
            ParkTreeNode(key: '2', label: '节点二'),
          ],
          onMultiSelect: (keys) { selected = keys; setState(() {}); },
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          List<String> selected = <String>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('已选: ${selected.join(", ")}'),
              const SizedBox(height: 8),
              ParkTree(
                multiSelect: true,
                data: <ParkTreeNode>[
                  const ParkTreeNode(
                    key: '1',
                    label: '根节点',
                    children: <ParkTreeNode>[
                      ParkTreeNode(key: '1-1', label: '子节点A'),
                      ParkTreeNode(key: '1-2', label: '子节点B'),
                    ],
                  ),
                  const ParkTreeNode(key: '2', label: '节点二'),
                ],
                onMultiSelect: (List<String> keys) {
                  selected = keys;
                  setState(() {});
                },
              ),
            ],
          );
        },
      ),
    ),
  ],
  basicUsageCode: '''ParkTree(
  data: [
    ParkTreeNode(key: '1', label: '根节点', children: [
      ParkTreeNode(key: '1-1', label: '子节点'),
    ]),
  ],
)''',
  guide: '''
## 何时使用 / When to use
- 组织架构、目录、分类等层级数据的浏览与选择 / Browsing and selecting hierarchical data (org charts, directories, categories)
- 需要多选勾选的授权、角色分配等场景（multiSelect）/ Multi-select assignments such as roles or permissions
- 大型树按需展开的异步懒加载（loadChildren）/ Lazy loading large trees on demand
- 需要对节点进行同级顺序调整的树形列表（draggable）/ Reordering siblings in a tree list

## 使用建议 / Usage tips
- ParkTreeNode 的 key 必须全局唯一，展开、选中、拖拽与搜索定位都依赖它 / key must be unique across the whole tree
- 单选监听 onSelect；多选开启 multiSelect 并监听 onMultiSelect（返回已选 key 列表）；受控时传 selectedKeys，外部变化会自动同步（忽略顺序）/ Single vs multi selection; controlled via selectedKeys
- checkStrictly 默认 false 时父子级联勾选（勾选父节点联动子孙、取消子节点自动取消祖先）；需要父子独立时置 true / Cascade checking by default; set checkStrictly to decouple parents and children
- loadChildren 对叶子节点按需加载，结果缓存并优先展示；data 引用变化时缓存清空，加载中显示 spinner，异常被捕获不影响 UI；超大节点数也建议用它分层加载控制递归构建开销 / Async loading is cached per node and cleared when data changes; errors are swallowed; use it to keep very large trees responsive
- draggable 启用长按拖拽，仅允许同级节点间重排，onDragReorder(oldIndex, newIndex) 回传同级索引；disabled 节点不可拖拽 / Long-press drag reorders siblings only; disabled nodes are excluded
- searchQuery 非空时对节点文字做大小写不敏感高亮，并自动展开所有包含匹配的父节点 / searchQuery highlights matches case-insensitively and auto-expands parent nodes

## 搭配推荐 / Compose with
- 放入 ParkCard，或作为 ParkLayout 侧边栏中的目录、导航树 / Put inside a ParkCard or a sidebar layout
- 与 ParkInput 组合：输入内容实时驱动 searchQuery 做树内搜索 / Pair with ParkInput to drive searchQuery
- 多选结果经 onMultiSelect 回传后，用 ParkDescriptions 等展示已选节点 / Show selected keys via ParkDescriptions after onMultiSelect

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.brand | 选中文字、勾选图标、加载 spinner 与拖拽指示线；选中行背景为 brand.withAlpha(20) |
| 色彩 | colors.warning | 搜索高亮背景（warning.withAlpha(60)） |
| 色彩 | colors.textPrimary / colors.textSecondary | 节点文字与箭头、图标颜色 |
| 字体 | typography.sizeBodySmall | 节点文字字号；高亮文字额外使用 typography.weightMedium |
| 间距 | spacing.base / spacing.lg | 节点缩进 = spacing.base + 深度 × spacing.lg |
| 间距 | spacing.xs | 节点行内边距与拖拽指示区高度 |
''',
);

// ────────────────────────────────────────────────────────────────────────────
// Navigation
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkLayoutSpec = ParkComponentSpec(
  name: 'ParkLayout',
  title: '页面布局',
  category: 'nav',
  description: 'Header + Sidebar + Content + Footer 四区域标准页面布局，支持侧边栏位置与分割线配置。',
  icon: Icons.view_agenda,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'header',
      type: 'Widget?',
      defaultVal: 'null',
      description: '顶栏',
      required: false,
    ),
    ParkPropertyDef(
      name: 'sidebar',
      type: 'Widget?',
      defaultVal: 'null',
      description: '侧边栏',
      required: false,
    ),
    ParkPropertyDef(
      name: 'body',
      type: 'Widget',
      defaultVal: '—',
      description: '主体内容',
      required: true,
    ),
    ParkPropertyDef(
      name: 'footer',
      type: 'Widget?',
      defaultVal: 'null',
      description: '页脚',
      required: false,
    ),
    ParkPropertyDef(
      name: 'sidebarWidth',
      type: 'double',
      defaultVal: '240',
      description: '侧边栏宽度',
      required: false,
    ),
    ParkPropertyDef(
      name: 'sidebarLeft',
      type: 'bool',
      defaultVal: 'true',
      description: '侧边栏是否在左（false 在右）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showSidebarDivider',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示侧边栏分割线',
      required: false,
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '标准布局',
      description: '顶栏+侧边栏+内容+页脚',
      code: _kLayoutStdCode,
      builder: _buildLayoutDemo1,
    ),
    ParkDemoScenario(
      title: '侧边栏在右',
      description: 'sidebarLeft: false',
      code: _kLayoutRightCode,
      builder: _buildLayoutRight,
    ),
    ParkDemoScenario(
      title: '隐藏分割线',
      description: 'showSidebarDivider: false',
      code: _kLayoutNoDividerCode,
      builder: _buildLayoutNoDivider,
    ),
    ParkDemoScenario(
      title: '仅顶栏+内容',
      description: '不含侧边栏与页脚',
      code: _kLayoutHeaderOnlyCode,
      builder: _buildLayoutHeaderOnly,
    ),
  ],
  basicUsageCode: '''ParkLayout(
  header: ParkNavBar(title: '管理系统'),
  sidebar: ParkMenu(items: [...]),
  body: Center(child: Text('内容')),
)''',
  guide: '''
## 何时使用 / When to use
- 管理后台、控制台类应用的标准页面骨架，需要「顶栏 + 侧边栏 + 内容 + 页脚」四区域布局 / Standard admin/console page shell with header, sidebar, content and footer
- 需要统一全局导航与版权页脚，同时让内容区自适应占满剩余空间的场景 / Consistent global nav and footer while the content area fills remaining space
- 侧边栏需要灵活放左 / 放右，并可按需显示或隐藏分割线的布局场景 / Layouts needing the sidebar on either side with an optional divider

## 使用建议 / Usage tips
- body 为必填参数；header、sidebar、footer 均可省略，缺省时对应区域自动不渲染，仅保留内容区 / body is required; header, sidebar and footer are all optional
- sidebarWidth 控制侧边栏宽度（默认 240），窄屏或紧凑布局可适当调小 / sidebarWidth (default 240) controls the sidebar width
- sidebarLeft: false 将侧边栏置于右侧，分割线会自动跟随切换位置 / sidebarLeft: false moves the sidebar to the right and the divider follows
- showSidebarDivider: false 隐藏 1px 分割线（使用 colors.borderLight），适合需要与内容视觉融合的侧边栏 / Set false to hide the 1px divider for a seamless look
- 内部使用 Column + Expanded + Row（crossAxisAlignment: stretch），侧边栏与内容区自动撑满可用高度，无需手动设置高度 / Height is filled automatically via Expanded + stretch
- 侧边栏外层包了 Semantics（文案来自 ParkLocalizations.layoutLabel），无障碍场景下会被识别为独立区域 / The sidebar is wrapped in Semantics for accessibility

## 搭配推荐 / Compose with
- header 搭配 ParkNavBar，sidebar 搭配 ParkMenu / ParkSideBar 构建完整后台导航 / ParkNavBar in header, ParkMenu or ParkSideBar in sidebar
- body 内放置 ParkCard、ParkTable、ParkAnchor 等业务内容，组织页面主体 / ParkCard, ParkTable or ParkAnchor inside body
- footer 搭配 ParkFooter 展示版权与快捷链接 / ParkFooter for copyright and quick links

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.surface | 侧边栏背景色 |
| 色彩 | colors.borderLight | 侧边栏与内容区之间的分割线颜色（1px VerticalDivider） |
| 字体 | — | 布局本身不渲染文字，字体令牌由传入的 header / sidebar / footer 组件消费 |
| 间距 | — | 侧边栏宽度由独立参数 sidebarWidth 控制（默认 240），不消费 spacing 令牌 |
''',
);

final ParkComponentSpec _parkAnchorSpec = ParkComponentSpec(
  name: 'ParkAnchor',
  title: '锚点',
  category: 'nav',
  description: '页面滚动导航，点击锚点项平滑跳转到对应区域，自动高亮当前区域。',
  icon: Icons.link,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkAnchorItem>',
      defaultVal: '—',
      description: '锚点项列表',
      required: true,
    ),
    ParkPropertyDef(
      name: 'scrollController',
      type: 'ScrollController?',
      defaultVal: 'null',
      description: '关联的滚动控制器',
      required: false,
    ),
    ParkPropertyDef(
      name: 'offset',
      type: 'double',
      defaultVal: '80',
      description: '滚动偏移量',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'void Function(String key)?',
      description: '点击锚点项时的选中变化回调',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础锚点',
      description: '页内锚点导航',
      code:
          "ParkAnchor(items: const [ParkAnchorItem(key: 'a', label: '第一部分'), ParkAnchorItem(key: 'b', label: '第二部分')])",
      builder: _buildAnchorDemo1,
    ),
    ParkDemoScenario(
      title: '偏移量',
      description: 'offset: 40',
      code:
          "ParkAnchor(offset: 40, items: const [ParkAnchorItem(key: 'a', label: '第一部分'), ParkAnchorItem(key: 'b', label: '第二部分')])",
      builder: _buildAnchorOffset,
    ),
    ParkDemoScenario(
      title: 'onChanged 事件',
      description: '点击高亮并回传 key',
      code: _kAnchorOnChangedCode,
      builder: _buildAnchorOnChanged,
    ),
    ParkDemoScenario(
      title: '滚动锚点',
      description: 'scrollController 联动滚动跳转',
      code: _kAnchorScrollCode,
      builder: _buildAnchorScroll,
    ),
  ],
  basicUsageCode: '''ParkAnchor(
  items: [
    ParkAnchorItem(key: 'section1', label: '第一部分'),
    ParkAnchorItem(key: 'section2', label: '第二部分'),
  ],
  onChanged: (key) => print('选中: \$key'),
)''',
  guide: '''
## 何时使用 / When to use
- 长页面文档、帮助中心等需要「目录 + 内容」联动定位的场景 / Docs and help-center pages with a linked table of contents
- 表单、设置页等分区较多的页面，点击锚点快速跳转到对应区域 / Jumping to sections in long forms or settings pages
- 需要随滚动自动高亮当前阅读区域的侧边导航 / Sidebar nav that highlights the section being read

## 使用建议 / Usage tips
- 建议为每个目标分区挂 GlobalKey 并填入 ParkAnchorItem.sectionKey，点击跳转与高亮定位最精确；不填时降级为 Key 匹配或滚动换算 / Prefer GlobalKeys via sectionKey for precise positioning
- 传入 scrollController 才能启用滚动联动高亮与回退跳转；不传时仅支持点击跳转（依赖 sectionKey）/ scrollController enables scroll-linked highlight
- item.key 应与目标 widget 的 Key 保持一致，作为 element 树回退定位的匹配依据 / Keep item.key consistent with the target widget key
- offset（默认 80）是「视口顶部 + offset」的高亮激活阈值，用于考虑顶栏高度；scrollOffset 额外补偿点击跳转时 AppBar 等固定元素，两者叠加使用 / offset vs scrollOffset
- 高亮采用「最后一个越过阈值的分区」规则，滚动到顶部时保持当前高亮；items 变化会自动清空 RenderBox 缓存并同步高亮到首项，缓存使滚动监听开销为 O(1) / Active rule and O(1) cached lookups
- 点击跳转使用 300ms easeInOut 平滑滚动，目标偏移会 clamp 到滚动范围之内 / Smooth 300ms easeInOut scroll, clamped to range

## 搭配推荐 / Compose with
- 搭配 ParkLayout 的侧边栏区域放置锚点，配合 ParkCard 组织各分区内容 / ParkLayout sidebar + ParkCard sections
- 搭配 ParkBackTop 为长页面提供回到顶部入口 / ParkBackTop for long pages
- 搭配 ParkSticky 让锚点吸顶，长页面滚动时始终可见 / ParkSticky to keep the anchor visible

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.brand / colors.textSecondary | 激活项左侧 3px 边框与文字用 brand，未激活项文字用 textSecondary |
| 字体 | typography.sizeCaption | 锚点项文字字号（13px），激活项加粗 w600、未激活项 w400 |
| 间距 | spacing.base / spacing.sm | 锚点项水平内边距 base（16px）、垂直内边距 sm（8px） |
''',
);

final ParkComponentSpec _parkMenuSpec = ParkComponentSpec(
  name: 'ParkMenu',
  title: '导航菜单',
  category: 'nav',
  description: '多级导航菜单，支持展开/折叠、选中高亮、图标、禁用状态与浅色模式。',
  icon: Icons.menu,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkMenuItem>',
      defaultVal: '—',
      description: '菜单项列表',
      required: true,
    ),
    ParkPropertyDef(
      name: 'selectedKey',
      type: 'String?',
      defaultVal: 'null',
      description: '当前选中项 key',
      required: false,
    ),
    ParkPropertyDef(
      name: 'defaultExpandedKeys',
      type: 'Set<String>?',
      defaultVal: 'null',
      description: '默认展开的父菜单 key',
      required: false,
    ),
    ParkPropertyDef(
      name: 'light',
      type: 'bool',
      defaultVal: 'false',
      description: '浅色模式（默认暗色）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkMenuSize',
      defaultVal: 'ParkMenuSize.medium',
      description: '菜单尺寸：small（紧凑）/ medium（默认）/ large（宽松），控制内边距、字号与图标大小',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSelect',
      signature: 'void Function(String key)?',
      description: '选中菜单项回调',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '多级菜单',
      description: '两级导航菜单',
      code: _kMenuMultiCode,
      builder: _buildMenuDemo1,
    ),
    ParkDemoScenario(
      title: '默认选中',
      description: 'selectedKey: dashboard',
      code: _kMenuSelectedCode,
      builder: _buildMenuSelected,
    ),
    ParkDemoScenario(
      title: '默认展开',
      description: 'defaultExpandedKeys',
      code: _kMenuExpandedCode,
      builder: _buildMenuExpanded,
    ),
    ParkDemoScenario(
      title: '浅色模式',
      description: 'light: true',
      code: _kMenuLightCode,
      builder: _buildMenuLight,
    ),
    ParkDemoScenario(
      title: 'onSelect 事件',
      description: '点击回传选中 key',
      code: _kMenuOnSelectCode,
      builder: _buildMenuOnSelect,
    ),
  ],
  basicUsageCode: '''ParkMenu(
  items: [
    ParkMenuItem(key: 'dashboard', label: '仪表盘', icon: Icons.dashboard),
    ParkMenuItem(key: 'settings', label: '设置', children: [
      ParkMenuItem(key: 'profile', label: '个人资料'),
    ]),
  ],
  onSelect: (key) => print('选中: \$key'),
)''',
  guide: '''
## 使用指南
ParkMenuItem 支持递归 children 实现多级菜单。selectedKey 控制高亮，defaultExpandedKeys 控制展开；
themeMode 切换主题模式（system / light / dark），mode 控制菜单模式（vertical / horizontal / inline），
inlineCollapsed 折叠为纯图标栏（宽 collapsedWidth）。
''',
);

// ────────────────────────────────────────────────────────────────────────────
// Input
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkTimePickerSpec = ParkComponentSpec(
  name: 'ParkTimePicker',
  title: '时间选择器',
  category: 'input',
  description: '独立的时间选择组件，支持 HH:mm 和 HH:mm:ss 格式。',
  icon: Icons.access_time,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'TimeOfDay?',
      defaultVal: 'null',
      description: '当前选中时间 / Selected time',
      required: false,
    ),
    ParkPropertyDef(
      name: 'placeholder',
      type: 'String?',
      defaultVal: '请选择时间',
      description: '占位文字 / Placeholder',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onChanged',
      type: 'ValueChanged<TimeOfDay>?',
      defaultVal: 'null',
      description: '时间变化回调 / Change callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showSeconds',
      type: 'bool',
      defaultVal: 'false',
      description: '显示秒 / Show seconds',
      required: false,
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用 / Disabled',
      required: false,
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '标签文字 / Label',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<TimeOfDay>?',
      description: '选择时间后触发 / Fired after picking a time',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础时间选择',
      description: '选择时分 / Pick HH:mm',
      code: 'ParkTimePicker()',
      builder: _buildTPDemo1,
    ),
    ParkDemoScenario(
      title: '选中回调',
      description: 'onChanged 实时回显 / onChanged',
      code:
          'StatefulBuilder(builder: (ctx, setState) {\n  TimeOfDay? t;\n  return ParkTimePicker(value: t, onChanged: (v) { t = v; setState(() {}); });\n})',
      builder: _buildTPDemo2,
    ),
    ParkDemoScenario(
      title: '带标签',
      description: 'label 标签 + 秒 / With label',
      code: 'ParkTimePicker(label: "开始时间", showSeconds: true)',
      builder: _buildTPDemo3,
    ),
    ParkDemoScenario(
      title: '禁用状态',
      description: 'disabled 禁用 / Disabled',
      code: 'ParkTimePicker(disabled: true)',
      builder: _buildTPDemo4,
    ),
  ],
  basicUsageCode: '''ParkTimePicker(
  value: TimeOfDay(hour: 9, minute: 30),
  onChanged: (time) => print(time.format(context)),
)''',
  guide: '''
## 何时使用 / When to use
- 表单中采集时间字段（开始/结束时间、营业时间等），输出 HH:mm / Collecting time fields (start/end time, business hours) in forms
- 需要精确到秒的时间（日志、预约时段、倒计时配置），开启 showSeconds 输出 HH:mm:ss / Precise-to-second values via showSeconds
- 与日期选择器配合完成日期 + 时间的完整采集 / Paired with a date picker for full datetime input
- 通过 bindKey 接入 ParkBindingService 表单绑定，实现 model ↔ UI 双向同步 / Two-way binding with ParkBindingService via bindKey

## 使用建议 / Usage tips
- value 类型为 TimeOfDay（不含秒）；showSeconds 为 true 时秒值由组件内部状态维护，外部传入新 value 会重置秒为 0 / Seconds live in internal state; external value changes reset them
- onChanged 仅在用户点击弹窗确认后触发，实时预览发生在对话框内部；需要即时响应请在页面内自行监听 / onChanged fires after confirm, not on every wheel tick
- showSeconds 为 false 时使用原生 Material showTimePicker；为 true 时改用 CupertinoTimerPicker（hms 模式）自绘对话框，两种交互请分别体验确认 / Two picker implementations depending on showSeconds
- disabled 为 true 时点击无响应，背景切换为 disabledBg，右侧下拉箭头隐藏 / disabled blocks taps and swaps to disabledBg styling
- 12/24 小时制跟随系统 MediaQuery.alwaysUse24HourFormatOf，秒格式下自动切换 HH:mm:ss 与 h:mm:ss AM/PM / Follows the system 24-hour format setting
- bindKey 绑定后双向同步：model → UI 通过监听器刷新，UI → model 在选择后写回；绑定服务优先取构造参数 bindingService，其次 ParkBindingFormScope.of(context) / Binding service resolution: constructor param first, then form scope

## 搭配推荐 / Compose with
- 搭配 ParkDatePicker 组合「日期 + 时间」完整采集场景 / ParkDatePicker for datetime pairs
- 搭配 ParkForm / ParkFormItem（schema 中 ext.control='timePicker'）用于 schema 驱动表单渲染 / ParkForm schema-driven forms
- 搭配 ParkFormRow 组织标签与选择器布局 / ParkFormRow for label + picker layout

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.border / textPrimary / textSecondary / textPlaceholder / disabledBg | 边框、选中值、图标、占位文字与禁用态背景 |
| 字体 | typography.sizeBodySmall | 选中值字号 14px；label 文字固定 13px |
| 间距 | spacing.md / spacing.hSm | 容器内边距 12px；图标与文本间距 8px；圆角 radius.brSm (8px) |
''',
  dynamicFormSchemaDoc: '''### 对应字段类型
`text`（文本），通过 `ext['control'] = 'timePicker'` 指定渲染为时间选择器。当前 `ParkFieldType` 无独立 `time` 枚举值，时间字段以 `text` 类型承载，值为 `HH:mm` 或 `HH:mm:ss` 格式字符串。

### 适用场景
- 表单中采集开始时间、结束时间、营业时间等时间字段 / Collecting start time, end time, business hours in forms.
- 配合日期字段实现完整的日期时间采集。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `text` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `ext.control` | `ext.control` | 设为 `'timePicker'` 渲染为时间选择器 | 是 |
| `ext.showSeconds` | `ext.showSeconds` | 是否显示秒（bool） | 否 |
| `fieldPrompt` | `field_prompt` / `placeholder` | 占位提示，如"请选择时间" | 否 |
| `defaultValue` | `default_value` | 默认时间字符串（如 `'09:30'`） | 否 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_startTime',
  fieldType: ParkFieldType.text,
  labelName: '开始时间',
  fieldName: 'startTime',
  fieldPrompt: '请选择时间',
  ext: <String, dynamic>{'control': 'timePicker'},
)
```

### 进阶技巧
- 秒精度：`ext['showSeconds'] = true` 启用 `HH:mm:ss` 格式。
- 校验：用 `regexExpression` 限制格式，如 `'^\\d{2}:\\d{2}(:\\d{2})?\u{24}'`。
- 联动：`\u{24}form.startTime` 可被其它字段 reaction 引用，如"结束时间必须晚于开始时间"。
- 双向绑定：在 `ParkForm` / `ParkForm` 内使用 `ParkTimePicker(bindKey: 'startTime')` 即可联动模型字段。''',
);

final ParkComponentSpec _parkColorPickerSpec = ParkComponentSpec(
  name: 'ParkColorPicker',
  title: '颜色选择器',
  category: 'input',
  description: '预设色块选择 + 自定义面板，支持预设色列表与当前色展示。',
  icon: Icons.palette,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'Color?',
      defaultVal: 'null',
      description: '当前选中颜色',
      required: false,
    ),
    ParkPropertyDef(
      name: 'presetColors',
      type: 'List<Color>?',
      defaultVal: 'null',
      description: '预设色列表（默认 20 色环）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'enableCustom',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用自定义',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<Color>?',
      description: '选中颜色变化回调',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础选择',
      description: '默认 20 色环',
      code: 'ParkColorPicker()',
      builder: _buildCPDemo1,
    ),
    ParkDemoScenario(
      title: '指定当前色',
      description: 'value: _kColors.brand',
      code: 'ParkColorPicker(value: _kColors.brand)',
      builder: _buildCPValue,
    ),
    ParkDemoScenario(
      title: '自定义预设',
      description: 'presetColors',
      code:
          'ParkColorPicker(presetColors: [_kColors.brand, _kColors.success, _kColors.warning, _kColors.error])',
      builder: _buildCPPresets,
    ),
    ParkDemoScenario(
      title: 'onChanged 事件',
      description: '点击色块回传颜色',
      code: _kCPOnChangedCode,
      builder: _buildCPOnChanged,
    ),
  ],
  basicUsageCode: '''ParkColorPicker(
  value: _kColors.brand,
  onChanged: (color) => print(color),
)''',
  guide: '''
## 何时使用 / When to use
- 表单中需要可视化选色，如主题色、品牌色、标签配色 / Visual color picking in forms (theme, brand, tag colors)
- 既有品牌预设色、又允许自由取色的配置面板 / Panels combining brand presets with free custom picking
- 需要以 HEX / RGB / HSB 展示颜色值或切换展示格式的场景 / Displaying color values with format switching

## 使用建议 / Usage tips
- value 配合 onChanged 使用；value 更新时组件会自动同步内部状态与 HSV 面板 / value + onChanged; widget updates sync the internal HSV state
- presetColors 语义：null 且未开 showFormatSwitch 时使用内置 20 色环；传空列表 [] 隐藏预设区；传自定义列表限定可选色；注意 presetColors 为 null 且 showFormatSwitch 为 true 时预设区同样不渲染 / null → built-in 20-color ring (skipped when showFormatSwitch is on); [] hides presets; a custom list limits the choices
- enableCustom 默认开启 HSV 取色面板（饱和度/明度方形面板 + 色相条），仅需预设选择时可置 false 压缩高度；面板高度为宽度正方形但上限 200px / enableCustom toggles the HSV panel; the SV panel is square up to 200px
- showFormatSwitch 开启后在底部提供 HEX / RGB / HSB 切换，当前展示格式由 format 控制 / showFormatSwitch enables HEX/RGB/HSB switching controlled by format
- 表单联动：传入 bindKey（配合 bindingService 或外层 ParkBindingFormScope）可与模型字段双向绑定，模型变化自动回写 UI / Pass bindKey to two-way bind with the form model
- 性能：HSV 面板拖动会连续触发 onChanged，高频回调中避免重逻辑 / Dragging the HSV panel fires onChanged continuously; keep callbacks light

## 搭配推荐 / Compose with
- 在 ParkForm（含动态表单 colorPicker 控件）中采集颜色字段，配合 bindKey 联动模型 / Collect color fields in ParkForm with bindKey
- 与 ParkSheetScaffold、ParkDialog 组合，把选择器放入弹层作为「选择颜色」面板 / Put the picker inside a sheet or dialog as a color panel
- 与 ParkButton 组合提供「重置为默认色」等快捷操作（外部维护 value）/ Combine with ParkButton for quick actions like resetting to default

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.brand | 选中色块边框、勾选图标与格式切换激活态 |
| 色彩 | colors.textOnBrand / colors.textSecondary | 激活格式按钮文字色 / 颜色值文字色 |
| 色彩 | colors.border | 预览条、色块与 SV 面板描边 |
| 字体 | typography.sizeCaption | 格式切换标签字号 |
| 字体 | typography.bodySmall | 颜色值文本样式（配合 monospace 字体族） |
| 间距 | spacing.vSm / spacing.vXs | 预设区、取色面板、格式区之间的纵向间距 |
''',
  dynamicFormSchemaDoc: '''### 对应字段类型
`text`（文本），通过 `ext['control'] = 'colorPicker'` 指定渲染为颜色选择器。颜色值以 HEX 字符串（如 `'#1677FF'`）存储与提交。

### 适用场景
- 表单中采集主题色、品牌色、自定义配色等颜色字段 / Collecting theme color, brand color, custom palette in forms.
- 后台装修、活动配置等需要可视化选色的场景。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `text` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `ext.control` | `ext.control` | 设为 `'colorPicker'` 渲染为颜色选择器 | 是 |
| `ext.presetColors` | `ext.presetColors` | 自定义预设色列表（HEX 字符串数组） | 否 |
| `ext.enableCustom` | `ext.enableCustom` | 是否启用自定义面板（bool） | 否 |
| `defaultValue` | `default_value` | 默认颜色 HEX 字符串 | 否 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_themeColor',
  fieldType: ParkFieldType.text,
  labelName: '主题色',
  fieldName: 'themeColor',
  defaultValue: '#1677FF',
  ext: <String, dynamic>{'control': 'colorPicker'},
)
```

### 进阶技巧
- 自定义预设：`ext['presetColors'] = ['#1677FF', '#52C41A', '#FAAD14']` 限制可选色。
- 校验：用 `regexExpression` 限制 HEX 格式，如 `'^#[0-9A-Fa-f]{6}\u{24}'`。
- 联动：`\u{24}form.themeColor` 可被预览区域 reaction 引用，实时预览配色效果。
- 双向绑定：在 `ParkForm` / `ParkForm` 内使用 `ParkColorPicker(bindKey: 'themeColor')` 即可联动模型字段。''',
);

final ParkComponentSpec _parkAutoCompleteSpec = ParkComponentSpec(
  name: 'ParkAutoComplete',
  title: '自动完成',
  category: 'input',
  description: '输入时弹出建议列表，支持自定义过滤函数、输入回调与占位文字。',
  icon: Icons.auto_fix_high,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'options',
      type: 'List<String>',
      defaultVal: '—',
      description: '候选建议列表',
      required: true,
    ),
    ParkPropertyDef(
      name: 'maxSuggestions',
      type: 'int',
      defaultVal: '6',
      description: '最大显示建议数',
      required: false,
    ),
    ParkPropertyDef(
      name: 'hintText',
      type: 'String?',
      defaultVal: 'null',
      description: '占位文字',
      required: false,
    ),
    ParkPropertyDef(
      name: 'filterFn',
      type: 'bool Function(String input, String option)?',
      defaultVal: 'null',
      description: '自定义过滤函数（默认包含匹配）',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSelected',
      signature: 'ValueChanged<String>?',
      description: '从建议列表选中某项的回调',
    ),
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<String>?',
      description: '输入框文字变化回调',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础自动完成',
      description: '输入过滤建议',
      code:
          "ParkAutoComplete(options: const ['apple', 'banana', 'cherry', 'date'])",
      builder: _buildACDemo1,
    ),
    ParkDemoScenario(
      title: 'onSelected 事件',
      description: '选中回传建议值',
      code: _kACOnSelectedCode,
      builder: _buildACOnSelected,
    ),
    ParkDemoScenario(
      title: 'onChanged 事件',
      description: '输入实时回传',
      code: _kACOnChangedCode,
      builder: _buildACOnChanged,
    ),
    ParkDemoScenario(
      title: '限制建议数',
      description: 'maxSuggestions: 3',
      code:
          "ParkAutoComplete(maxSuggestions: 3, options: const ['apple', 'banana', 'cherry', 'date', 'elderberry'])",
      builder: _buildACMax,
    ),
    ParkDemoScenario(
      title: '占位文字',
      description: 'hintText',
      code:
          "ParkAutoComplete(hintText: '搜索水果', options: const ['apple', 'banana', 'cherry'])",
      builder: _buildACHint,
    ),
    ParkDemoScenario(
      title: '自定义过滤',
      description: 'filterFn 前缀匹配',
      code: _kACFilterCode,
      builder: _buildACFilter,
    ),
  ],
  basicUsageCode: '''ParkAutoComplete(
  options: ['apple', 'banana', 'cherry'],
  onSelected: (v) => print('选中: \$v'),
)''',
  guide: '''
## 何时使用 / When to use
- 需要从固定候选集中快速输入或选择的场景，如标签、城市、商品名补全 / Fast entry or selection from a fixed option set (tags, cities, product names)
- 输入即联想、默认按「包含匹配」过滤候选的搜索建议场景 / Suggest-as-you-type with default contains matching
- 表单中需要自动补全的文本字段，配合 ParkForm 渲染为 autoComplete 控件 / Auto-suggest text fields in forms (ext.control = 'autoComplete')

## 使用建议 / Usage tips
- options 为必填的静态候选列表；候选量大时应先按需截断或服务端过滤后再传入，避免全量下发与前端过滤开销 / options is required; pre-filter large sets to avoid filtering cost
- 默认 filterFn 为大小写不敏感的包含匹配；需要前缀匹配、拼音或模糊匹配时传入自定义 filterFn / Customize filterFn for prefix, pinyin or fuzzy matching
- 输入自带 300ms 防抖后再过滤并弹层，高频输入无需自行节流；清空输入会自动收起建议 / Built-in 300ms debounce; empty input hides the overlay
- 建议列表最多展示 maxSuggestions 条（默认 6），超出部分被截断，需要更多展示可调大该值 / maxSuggestions (default 6) caps the visible list
- 选中项会 trim 后回填输入框并触发 onSelected（提交语义）；onChanged 在每次文字变化时触发（含清空），适合受控联动 / onSelected fires on pick (trimmed); onChanged fires on every text change
- 有输入时后缀显示清空按钮（无障碍 label 来自 ParkLocalizations.clearText），点击即清空并收起弹层 / A clear suffix button appears while the input is non-empty

## 搭配推荐 / Compose with
- 在 ParkForm 中使用，通过 ParkFormFieldSchema 的 ext['control'] = 'autoComplete' 渲染为自动补全字段 / Use inside ParkForm via ext.control
- 选中结果经 onSelected 回传后，用 ParkTag 展示已选标签或回填到其他表单字段 / Show picks with ParkTag or feed them into other fields
- 与 ParkSearch 互补：需要受控候选集补全用 ParkAutoComplete，自由关键词搜索用 ParkSearch / Complements ParkSearch for free-text search

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.surface | 建议下拉面板背景色 |
| 色彩 | colors.textPrimary / colors.textPlaceholder | 建议项文字与占位提示颜色 |
| 色彩 | colors.border | 输入框与下拉面板边框颜色 |
| 字体 | typography.sizeBodySmall | 建议项与占位提示的字号 |
| 间距 | spacing.md / spacing.sm | 建议项与输入框内边距（水平 md、垂直 sm+2） |
''',
  dynamicFormSchemaDoc: '''### 对应字段类型
`text`（单行文本），通过 `ext['control'] = 'autoComplete'` 指定渲染为自动完成控件。也可配合 `dataSourceType` 提供远程建议数据。

### 适用场景
- 表单中采集需要自动补全的文本字段，如地址、商品名、标签等 / Collecting text fields with auto-suggestions, e.g. address, product name, tags.
- 选项量大时通过远程搜索动态加载建议列表。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `text` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `ext.control` | `ext.control` | 设为 `'autoComplete'` 渲染为自动完成 | 否 |
| `ext.options` | `ext.options` | 静态建议列表（字符串数组） | 否 |
| `ext.maxSuggestions` | `ext.maxSuggestions` | 最大显示建议数 | 否 |
| `dataSourceType` | `data_source_type` | 设为 `'api'` 启用远程建议 | 否 |
| `dataSourceKey` | `data_source_key` | 远程数据源键名 | 否 |
| `fieldPrompt` | `field_prompt` / `placeholder` | 占位提示 | 否 |
| `defaultValue` | `default_value` | 默认值 | 否 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_city',
  fieldType: ParkFieldType.text,
  labelName: '城市',
  fieldName: 'city',
  fieldPrompt: '输入城市名',
  ext: <String, dynamic>{
    'control': 'autoComplete',
    'options': ['北京', '上海', '广州', '深圳', '杭州'],
  },
)
```

### 进阶技巧
- 远程建议：`dataSourceType: ParkDataSourceType.api` + `dataSourceKey: 'citySearch'` 实现远程搜索。
- 自定义过滤：`ext['filterFn']` 可指定过滤逻辑（如前缀匹配、模糊匹配）。
- 校验：用 `regexTag` 或 `regexExpression` 限制输入格式。
- 联动：`\u{24}form.city` 可被其它字段 reaction 引用，如根据城市联动区县选择。''',
);

final ParkComponentSpec _parkInputNumberSpec = ParkComponentSpec(
  name: 'ParkInputNumber',
  title: '数字输入框',
  category: 'input',
  description: '带 +/- 按钮的数字输入框，支持步进、范围限制、精度控制与禁用/只读。',
  icon: Icons.exposure,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'double?',
      defaultVal: '0',
      description: '当前值',
      required: false,
    ),
    ParkPropertyDef(
      name: 'min',
      type: 'double',
      defaultVal: '-∞',
      description: '最小值',
      required: false,
    ),
    ParkPropertyDef(
      name: 'max',
      type: 'double',
      defaultVal: '∞',
      description: '最大值',
      required: false,
    ),
    ParkPropertyDef(
      name: 'step',
      type: 'double',
      defaultVal: '1',
      description: '步进值',
      required: false,
    ),
    ParkPropertyDef(
      name: 'precision',
      type: 'int?',
      defaultVal: 'null',
      description: '小数精度',
      required: false,
    ),
    ParkPropertyDef(
      name: 'label',
      type: 'String?',
      defaultVal: 'null',
      description: '上方标签文字',
      required: false,
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用',
      required: false,
    ),
    ParkPropertyDef(
      name: 'readOnly',
      type: 'bool',
      defaultVal: 'false',
      description: '是否只读',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description:
          '绑定键（点号分隔路径，如 "user.age"）。设此参数后进入双向绑定模式，值变化自动同步到 ParkBindingService。不设时行为不变（零侵入）。',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description:
          '绑定服务实例。传入后通过 bindKey 自动双向绑定；位于已注入绑定服务的 ParkForm 内时可省略（自动从 ParkBindingFormScope 获取）。',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChanged',
      signature: 'ValueChanged<double>?',
      description: '值变化回调',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础数字输入',
      description: '0-100 步进 5',
      code: 'ParkInputNumber(min: 0, max: 100, step: 5)',
      builder: _buildINDemo1,
    ),
    ParkDemoScenario(
      title: 'onChanged 事件',
      description: '步进/输入回传值',
      code: _kINOnChangedCode,
      builder: _buildINOnChanged,
    ),
    ParkDemoScenario(
      title: '小数精度',
      description: 'precision: 2',
      code: 'ParkInputNumber(min: 0, max: 1, step: 0.1, precision: 2)',
      builder: _buildINPrecision,
    ),
    ParkDemoScenario(
      title: '带标签',
      description: 'label',
      code: "ParkInputNumber(label: '数量', min: 0, max: 10)",
      builder: _buildINLabel,
    ),
    ParkDemoScenario(
      title: '禁用',
      description: 'disabled: true',
      code: 'ParkInputNumber(disabled: true, value: 5)',
      builder: _buildINDisabled,
    ),
    ParkDemoScenario(
      title: '只读',
      description: 'readOnly: true',
      code: 'ParkInputNumber(readOnly: true, value: 42)',
      builder: _buildINReadOnly,
    ),
    ParkDemoScenario(
      title: '双向绑定（ParkBinding）',
      description: 'bindKey + bindingService 双向绑定，值变化实时同步到 model。',
      code: '''
final service = ParkBindingService({'age': 18});

ParkInputNumber(
  label: '年龄',
  bindKey: 'age',
  bindingService: service,
  min: 0,
  max: 150,
)''',
      builder: _buildINBinding,
    ),
    // ── ParkInputNumber: ParkForm 示例 ──
    ParkDemoScenario(
      title: '动态表单（ParkForm）',
      description:
          '在 ParkForm 中以 schema 配置使用 number 字段类型。'
          ' / ParkForm fieldType=number demo.',
      code: '''
ParkForm(
  schema: ParkFormSchema(
    formKey: 'in_demo',
    fields: [
      ParkFormFieldSchema(
        fieldId: 'f_age',
        fieldType: ParkFieldType.number,
        labelName: '年龄',
        fieldName: 'age',
        isRequired: true,
        defaultValue: 18,
        ext: {'min': 0, 'max': 150, 'step': 1},
      ),
    ],
  ),
  onSubmit: (values) => print(values),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: ParkForm(
          schema: ParkFormSchema(
            formKey: 'in_demo',
            fields: <ParkFormFieldSchema>[
              ParkFormFieldSchema(
                fieldId: 'f_age',
                fieldType: ParkFieldType.number,
                labelName: '年龄',
                fieldName: 'age',
                isRequired: true,
                defaultValue: 18,
                ext: <String, dynamic>{'min': 0, 'max': 150, 'step': 1},
              ),
            ],
          ),
          onSubmit: (_) {},
        ),
      ),
    ),
  ],
  basicUsageCode: '''ParkInputNumber(
  value: 10,
  min: 0,
  max: 100,
  step: 1,
  onChanged: (v) => print(v),
)''',
  guide: '''
## 使用指南
支持键盘直接输入和 +/- 按钮点击。precision 控制小数位数，min/max 自动钳制。disabled/readOnly 控制可编辑性。设 bindKey 后可接入 ParkForm 双向绑定。
''',
  dynamicFormSchemaDoc: '''### 对应字段类型
`number`（数字输入）。ParkInputNumber 是 number 类型的表单输入控件。

### 适用场景
- 表单中采集数量、年龄、金额等数值字段，需要步进按钮与范围限制。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `number` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `defaultValue` | `default_value` | 默认值（数值） | 否 |
| `ext` | `ext` | 业务扩展，常经此承载 `min` / `max` / `step` / `precision` | 否 |
| `uiConfig` | `ui_config` / `config` | 占位/前后缀等 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_age',
  fieldType: ParkFieldType.number,
  labelName: '年龄',
  fieldName: 'age',
  isRequired: true,
  defaultValue: 18,
  ext: <String, dynamic>{'min': 0, 'max': 120, 'step': 1},
)
```

### 进阶技巧
- 数值范围与步进：当前 `ParkFormFieldSchema` 无独立 `min`/`max`/`step` 字段，一般经 `ext` 承载（如 `ext['min']`、`ext['step']`）。
- 双向绑定：在 `ParkForm` / `ParkForm` 内使用 `ParkInputNumber(bindKey: 'age')` 即可联动模型字段。
- 校验：用 `validatorMessage` 自定义提示，结合 `isRequired` 控制必填。
- 联动：`visibleRule` / `disabledRule` 控制显隐与禁用。''',
);

final ParkComponentSpec _parkTransferSpec = ParkComponentSpec(
  name: 'ParkTransfer',
  title: '穿梭框',
  category: 'input',
  description: '双栏列表选择，支持搜索、全选和方向按钮移动。',
  icon: Icons.swap_horiz,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'dataSource',
      type: 'List<ParkTransferItem>',
      defaultVal: '—',
      description: '全部可选项 / All options',
      required: true,
    ),
    ParkPropertyDef(
      name: 'targetKeys',
      type: 'List<String>?',
      defaultVal: 'null',
      description: '已选 key 列表 / Selected keys',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onChange',
      type: 'void Function(List<String>, TransferDirection)?',
      defaultVal: 'null',
      description: '选择变更回调 / Change callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showSearch',
      type: 'bool',
      defaultVal: 'false',
      description: '显示搜索框 / Show search',
      required: false,
    ),
    ParkPropertyDef(
      name: 'leftTitle',
      type: 'String?',
      defaultVal: '待选',
      description: '左侧标题 / Left title',
      required: false,
    ),
    ParkPropertyDef(
      name: 'rightTitle',
      type: 'String?',
      defaultVal: '已选',
      description: '右侧标题 / Right title',
      required: false,
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用 / Disabled',
      required: false,
    ),
    ParkPropertyDef(
      name: 'renderItem',
      type: 'Widget Function(ParkTransferItem, bool)?',
      defaultVal: 'null',
      description: '自定义渲染项 / Custom item renderer',
      required: false,
    ),
    ParkPropertyDef(
      name: 'oneWay',
      type: 'bool',
      defaultVal: 'false',
      description: '单向模式（只允许从左到右移动）/ One-way mode',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description: '绑定键（点号分隔的路径）。设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。',
      required: false,
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description: '绑定服务实例。不设时尝试从 ParkBindingFormScope 获取。',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChange',
      signature:
          'void Function(List<String> targetKeys, TransferDirection direction)?',
      description: '移动条目后触发 / Fired after transfer',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '穿梭框',
      description: '双栏选择 / Dual list',
      code: 'ParkTransfer(dataSource: [...])',
      builder: _buildTransferDemo1,
    ),
    ParkDemoScenario(
      title: '变更回调',
      description: 'onChange 回显方向 / onChange',
      code:
          'StatefulBuilder(builder: (ctx, setState) {\n  List<String> keys = [];\n  TransferDirection? dir;\n  return ParkTransfer(dataSource: [...], onChange: (k, d) { keys = k; dir = d; setState(() {}); });\n})',
      builder: _buildTransferDemo2,
    ),
    ParkDemoScenario(
      title: '带搜索',
      description: 'showSearch 过滤 / Searchable',
      code: 'ParkTransfer(showSearch: true, dataSource: [...])',
      builder: _buildTransferDemo3,
    ),
  ],
  basicUsageCode: '''ParkTransfer(
  dataSource: [
    ParkTransferItem(key: '1', title: '权限A'),
    ParkTransferItem(key: '2', title: '权限B'),
  ],
  targetKeys: ['1'],
  onChange: (keys, dir) => print(keys),
)''',
  guide: '''
## 使用指南
dataSource 定义全部项目，targetKeys 控制已选，onChange 回调 (keys, direction)。
支持搜索过滤（showSearch）和全选；oneWay 限制为单向移动；disabled 禁用全部交互；
bindKey + bindingService 支持 ParkBinding 双向绑定。
''',
  dynamicFormSchemaDoc: '''### 对应字段类型
`checkbox`（多选组），通过 `ext['control'] = 'transfer'` 指定渲染为穿梭框样式。提交值为已选 key 的字符串数组。

### 适用场景
- 表单中需要从大量选项中多选一组值，如权限分配、标签选择等 / Selecting multiple values from a large option set, e.g. permission assignment, tag selection.
- 双栏布局比下拉多选更直观，适合选项较多（>10）的场景。

### 关键 schema 属性
| 属性(Dart) | JSON 键 | 说明 | 必填 |
|------------|---------|------|------|
| `fieldType` | `field_type` / `type` | 固定为 `checkbox` | 是 |
| `fieldName` | `field_name` / `key` | 提交数据键名 | 是 |
| `labelName` | `label_name` / `label` | 标签 | 是 |
| `ext.control` | `ext.control` | 设为 `'transfer'` 渲染为穿梭框 | 否 |
| `ext.leftTitle` | `ext.leftTitle` | 左侧标题 | 否 |
| `ext.rightTitle` | `ext.rightTitle` | 右侧标题 | 否 |
| `ext.showSearch` | `ext.showSearch` | 是否显示搜索框（bool） | 否 |
| `options` | `options` | 选项列表（`{label, value}` 数组） | 是 |
| `defaultValue` | `default_value` | 默认已选 key 数组 | 否 |
| `isRequired` | `is_required` / `required` | 是否必填 | 否 |
| `dataSourceType` | `data_source_type` | 选项数据来源类型 | 否 |
| `dataSourceKey` | `data_source_key` | 远程数据源键名 | 否 |

### 最小可用示例
```dart
ParkFormFieldSchema(
  fieldId: 'f_permissions',
  fieldType: ParkFieldType.checkbox,
  labelName: '权限分配',
  fieldName: 'permissions',
  options: <Map<String, dynamic>>[
    {'label': '权限A', 'value': 'a'},
    {'label': '权限B', 'value': 'b'},
    {'label': '权限C', 'value': 'c'},
  ],
  ext: <String, dynamic>{'control': 'transfer'},
)
```

### 进阶技巧
- 远程数据源：`dataSourceType: ParkDataSourceType.api` + `dataSourceKey: 'permList'` 动态加载选项。
- 搜索过滤：`ext['showSearch'] = true` 启用双栏搜索。
- 校验：`isRequired: true` 确保至少选择一项；或自定义 `validatorMessage`。
- 联动：`\u{24}form.permissions` 可被其它字段 reaction 引用，如根据权限联动可见菜单。''',
);

// ────────────────────────────────────────────────────────────────────────────
// Feedback
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkPopconfirmSpec = ParkComponentSpec(
  name: 'ParkPopconfirm',
  title: '气泡确认框',
  category: 'feedback',
  description: '点击触发元素弹出确认对话框，支持危险操作和 loading 状态。',
  icon: Icons.help_outline,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      defaultVal: 'null',
      description: '确认框标题 / Title',
      required: false,
    ),
    ParkPropertyDef(
      name: 'description',
      type: 'String?',
      defaultVal: 'null',
      description: '描述文字 / Description',
      required: false,
    ),
    ParkPropertyDef(
      name: 'titleWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义标题（优先 title）/ Custom title widget',
      required: false,
    ),
    ParkPropertyDef(
      name: 'descriptionWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义描述（优先 description）/ Custom description widget',
      required: false,
    ),
    ParkPropertyDef(
      name: 'confirmText',
      type: 'String',
      defaultVal: '确定',
      description: '确认按钮文字 / Confirm label',
      required: false,
    ),
    ParkPropertyDef(
      name: 'cancelText',
      type: 'String',
      defaultVal: '取消',
      description: '取消按钮文字 / Cancel label',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onConfirm',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '确认回调 / Confirm callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onCancel',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '取消回调 / Cancel callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'autoCloseAfterConfirm',
      type: 'bool',
      defaultVal: 'true',
      description: '确认后自动关闭 / Auto-close after confirm',
      required: false,
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'IconData?',
      defaultVal: 'null',
      description: '提示图标 / Icon',
      required: false,
    ),
    ParkPropertyDef(
      name: 'danger',
      type: 'bool',
      defaultVal: 'false',
      description: '危险操作（红色确认）/ Danger mode',
      required: false,
    ),
    ParkPropertyDef(
      name: 'confirmLoading',
      type: 'bool',
      defaultVal: 'false',
      description: '确认按钮 loading / Confirm loading',
      required: false,
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      defaultVal: '—',
      description: '触发元素 / Trigger',
      required: true,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onConfirm',
      signature: 'VoidCallback?',
      description: '点击确认按钮触发 / Fired on confirm',
    ),
    ParkEventDef(
      name: 'onCancel',
      signature: 'VoidCallback?',
      description: '点击取消或遮罩触发 / Fired on cancel',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础确认',
      description: '删除确认 / Basic confirm',
      code: 'ParkPopconfirm(title: "确认删除？", child: ParkButton(text: "删除"))',
      builder: _buildPCDemo1,
    ),
    ParkDemoScenario(
      title: '确认/取消回调',
      description: 'onConfirm + onCancel 回显 / Callbacks',
      code:
          'StatefulBuilder(builder: (ctx, setState) {\n  String s = "";\n  return Column(children: [ParkPopconfirm(title: "?", onConfirm: () { s = "确认"; setState(() {}); }, onCancel: () { s = "取消"; setState(() {}); }, child: ParkButton(child: Text("操作"))), Text(s)]);\n})',
      builder: _buildPCDemo2,
    ),
    ParkDemoScenario(
      title: '危险操作',
      description: 'danger 红色确认 / Danger',
      code:
          'ParkPopconfirm(title: "删除全部？", danger: true, child: ParkButton(text: "删除"))',
      builder: _buildPCDemo3,
    ),
    ParkDemoScenario(
      title: '加载状态',
      description: 'confirmLoading / Loading',
      code:
          'ParkPopconfirm(title: "提交？", confirmLoading: true, child: ParkButton(text: "提交"))',
      builder: _buildPCDemo4,
    ),
    ParkDemoScenario(
      title: '自定义按钮文字',
      description: 'confirmText / cancelText / Custom labels',
      code:
          'ParkPopconfirm(title: "继续？", confirmText: "是的", cancelText: "不了", child: ParkButton(text: "下一步"))',
      builder: _buildPCDemo5,
    ),
  ],
  basicUsageCode: '''ParkPopconfirm(
  title: '确认删除？',
  onConfirm: () => print('已确认'),
  child: ParkButton(child: Text('删除')),
)''',
  guide: '''
## 何时使用 / When to use
- 删除、清空、提交等不可逆或高风险操作，需要用户二次确认 / Irreversible or high-risk actions (delete, clear, submit) that need a second confirmation
- 希望在触发元素附近就地确认，避免整页对话框打断操作流 / In-place confirmation near the trigger instead of a full-screen dialog
- 需要确认后继续异步任务（如先提交请求再关闭）的流程 / Async workflows that continue after confirm (submit then close)

## 使用建议 / Usage tips
- child 为必填触发元素，点击后通过 Overlay 在下方弹出气泡；底部空间不足时自动翻转到上方并钳制水平边界，气泡最大宽度 280 / child is required; the bubble renders below the trigger and auto-flips or clamps to stay inside the viewport, max width 280
- titleWidget / descriptionWidget 优先于 title / description，需要富文本或自定义布局时使用 widget 版本 / Widget variants win over string variants for rich content
- confirmText / cancelText 为空时回退到本地化的「确定 / 取消」，需要自定义文案时显式传入 / Falls back to localized 确定/取消 when left empty
- danger 会将确认按钮切换为 danger 变体，同时把 icon 渲染为错误色；删除等高风险操作建议开启 / danger turns the confirm button red and tints the icon
- 异步确认推荐组合 confirmLoading + autoCloseAfterConfirm: false：先发起请求，成功后由业务代码关闭或重置 / For async confirm, set confirmLoading and keep autoCloseAfterConfirm: false, then close programmatically on success
- 弹层生命周期：点击气泡外遮罩等同取消并触发 onCancel；组件销毁时自动清理 Overlay；触发元素首帧尚未完成布局时点击会被安全忽略 / Tapping the mask cancels; the overlay is auto-cleaned on dispose; taps before the trigger's first layout are safely ignored

## 搭配推荐 / Compose with
- 用 ParkButton 作为触发元素（普通操作 primary，危险操作 danger 变体）/ Use ParkButton as the trigger
- 在 ParkTable、ParkCard 等容器内对行级删除、停用等操作加二次确认 / Add confirmations to row-level destructive actions inside ParkTable or ParkCard
- 配合 ParkMessage / ParkToast 在 onConfirm 后提示操作结果 / Show the operation result via ParkMessage or ParkToast after confirm

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.surface | 气泡背景色；阴影基于 colors.overlay 10% 透明度 |
| 色彩 | colors.brand / colors.error | 普通 / 危险确认按钮与标题图标颜色 |
| 色彩 | colors.textPrimary / colors.textSecondary | 标题与描述文字颜色 |
| 字体 | typography.sizeBody / typography.sizeCaption | 标题（w600）与描述文字字号 |
| 间距 | spacing.base / spacing.sm | 气泡内边距与按钮间距 |
''',
);

final ParkComponentSpec _parkAlertSpec = ParkComponentSpec(
  name: 'ParkAlert',
  title: '警告提示',
  category: 'feedback',
  description:
      '静态提示组件，支持 success/warning/error/info 四种类型，可带描述、图标、关闭按钮与 banner 风格。',
  icon: Icons.warning_amber,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'type',
      type: 'ParkAlertType',
      defaultVal: 'info',
      description: '提示类型',
      required: false,
    ),
    ParkPropertyDef(
      name: 'message',
      type: 'String',
      defaultVal: '—',
      description: '提示标题',
      required: true,
    ),
    ParkPropertyDef(
      name: 'description',
      type: 'String?',
      defaultVal: 'null',
      description: '详细描述',
      required: false,
    ),
    ParkPropertyDef(
      name: 'messageWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义标题 widget（优先 message）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'descriptionWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义描述 widget（优先 description）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义图标（覆盖类型默认图标）',
      required: false,
    ),
    ParkPropertyDef(
      name: 'closable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否可关闭',
      required: false,
    ),
    ParkPropertyDef(
      name: 'showIcon',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示图标',
      required: false,
    ),
    ParkPropertyDef(
      name: 'banner',
      type: 'bool',
      defaultVal: 'false',
      description: '是否 banner 通栏风格',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: '点击关闭按钮回调',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '信息提示',
      description: 'info 类型',
      code: "ParkAlert(type: ParkAlertType.info, message: '这是一条信息提示')",
      builder: _buildAlertInfo,
    ),
    ParkDemoScenario(
      title: '成功提示',
      description: 'success 类型',
      code: "ParkAlert(type: ParkAlertType.success, message: '操作成功完成')",
      builder: _buildAlertSuccess,
    ),
    ParkDemoScenario(
      title: '警告提示',
      description: 'warning 类型',
      code: "ParkAlert(type: ParkAlertType.warning, message: '请注意磁盘空间不足')",
      builder: _buildAlertWarning,
    ),
    ParkDemoScenario(
      title: '错误提示',
      description: 'error 类型',
      code: "ParkAlert(type: ParkAlertType.error, message: '提交失败，请重试')",
      builder: _buildAlertError,
    ),
    ParkDemoScenario(
      title: '带描述',
      description: 'message + description',
      code:
          "ParkAlert(type: ParkAlertType.info, message: '系统通知', description: '今晚 23:00 将进行维护，预计 2 小时')",
      builder: _buildAlertDesc,
    ),
    ParkDemoScenario(
      title: '可关闭 + onClose',
      description: '点击关闭按钮触发回调',
      code: _kAlertOnCloseCode,
      builder: _buildAlertClosable,
    ),
    ParkDemoScenario(
      title: 'Banner 风格',
      description: '无边框通栏样式',
      code:
          "ParkAlert(type: ParkAlertType.warning, message: '横幅提示：请尽快处理', banner: true)",
      builder: _buildAlertBanner,
    ),
    ParkDemoScenario(
      title: '自定义图标',
      description: '覆盖默认类型图标',
      code:
          "ParkAlert(type: ParkAlertType.info, message: '自定义图标提示', icon: Icon(Icons.lightbulb_outline))",
      builder: _buildAlertIcon,
    ),
    ParkDemoScenario(
      title: '隐藏图标',
      description: 'showIcon: false',
      code:
          "ParkAlert(type: ParkAlertType.info, message: '不显示图标', showIcon: false)",
      builder: _buildAlertNoIcon,
    ),
  ],
  basicUsageCode: '''ParkAlert(
  type: ParkAlertType.warning,
  message: '系统维护通知',
  description: '今晚 23:00 维护 2 小时',
  closable: true,
  onClose: () => print('closed'),
)''',
  guide: '''
## 使用指南
四种类型对应不同颜色。banner 模式为无边框通栏样式。closable 显示关闭按钮并触发 onClose。
可通过 messageWidget/descriptionWidget/icon 自定义内容，showIcon 控制图标显隐。

## 设计令牌参考 / Design Token Reference
- 圆角：radius.sm (8px)；内边距：12px 16px；字号：typography.sizeBodySmall (14px)
- 类型色：success/warning/error/info 对应功能色，浅色底对应 *Light 色
- 图标与文字间距：spacing.sm (8px)
- 详见 DESIGN_SYSTEM.md
''',
);

final ParkComponentSpec _parkNotificationSpec = ParkComponentSpec(
  name: 'ParkNotification',
  title: '通知提醒框',
  category: 'feedback',
  description: '从屏幕右上角弹出的全局通知提醒，支持自动关闭和四种类型。',
  icon: Icons.notifications_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String',
      defaultVal: '—',
      description: '通知标题 / Title',
      required: true,
    ),
    ParkPropertyDef(
      name: 'description',
      type: 'String?',
      defaultVal: 'null',
      description: '通知详情 / Description',
      required: false,
    ),
    ParkPropertyDef(
      name: 'type',
      type: 'ParkNotificationType',
      defaultVal: 'info',
      description: '通知类型 success/error/warning/info',
      required: false,
    ),
    ParkPropertyDef(
      name: 'duration',
      type: 'Duration',
      defaultVal: '3s',
      description: '自动关闭时长 / Auto-close duration',
      required: false,
    ),
    ParkPropertyDef(
      name: 'onClose',
      type: 'VoidCallback?',
      defaultVal: 'null',
      description: '关闭回调 / Close callback',
      required: false,
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义图标 / Custom icon',
      required: false,
    ),
    ParkPropertyDef(
      name: 'closable',
      type: 'bool',
      defaultVal: 'true',
      description: '是否可手动关闭 / Closable',
      required: false,
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkNotificationSize',
      defaultVal: 'ParkNotificationSize.medium',
      description: '通知尺寸：small（紧凑）/ medium（默认）/ large（宽松），控制内边距、字号与图标大小',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: '通知关闭（自动或手动）触发 / Fired on close',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkNotification.show(context, ...)',
      signature: 'void',
      description: '弹出全局通知（右上角）/ Show a notification',
    ),
    ParkMethodDef(
      name: 'ParkNotification.hide()',
      signature: 'void',
      description: '隐藏当前通知 / Hide current notification',
    ),
  ],
  demos: const <ParkDemoScenario>[
    ParkDemoScenario(
      title: '成功通知',
      description: '右上角弹出 success / Success',
      code:
          'ParkNotification.show(context, type: ParkNotificationType.success, title: "成功", description: "数据已保存")',
      builder: _buildNotifyDemo1,
    ),
    ParkDemoScenario(
      title: '错误通知',
      description: 'error 类型 / Error',
      code:
          'ParkNotification.show(context, type: ParkNotificationType.error, title: "保存失败")',
      builder: _buildNotifyDemo2,
    ),
    ParkDemoScenario(
      title: '警告通知',
      description: 'warning 类型 / Warning',
      code:
          'ParkNotification.show(context, type: ParkNotificationType.warning, title: "注意")',
      builder: _buildNotifyDemo3,
    ),
    ParkDemoScenario(
      title: '信息通知',
      description: 'info 类型 / Info',
      code:
          'ParkNotification.show(context, type: ParkNotificationType.info, title: "提示")',
      builder: _buildNotifyDemo4,
    ),
    ParkDemoScenario(
      title: '关闭回调',
      description: 'onClose 触发 / onClose',
      code:
          'StatefulBuilder(builder: (ctx, setState) {\n  bool closed = false;\n  return Column(children: [ParkButton(onPressed: () => ParkNotification.show(ctx, title: "X", onClose: () { closed = true; setState(() {}); }), child: Text("显示")), Text(closed ? "已关闭" : "显示中")]);\n})',
      builder: _buildNotifyDemo5,
    ),
    ParkDemoScenario(
      title: '手动隐藏',
      description: 'hide() 关闭 / hide()',
      code: 'ParkNotification.hide()',
      builder: _buildNotifyDemo6,
    ),
  ],
  basicUsageCode: '''ParkNotification.show(context,
  type: ParkNotificationType.success,
  title: '操作成功',
  description: '数据已保存',
)''',
  guide: '''
## 何时使用 / When to use
- 全局操作结果的轻量反馈（成功 / 失败 / 警告 / 提示），不打断用户当前操作流 / Non-blocking global feedback for operation results
- 表单提交、保存、删除等异步操作完成后的即时通知 / Instant results for async actions (submit, save, delete)
- 与 ParkDialog 等模态提示相比，适合无需用户确认、可自动消失的短消息 / Short auto-dismissing messages where confirmation is unnecessary

## 使用建议 / Usage tips
- show 为静态方法，需传入可用的 BuildContext（内部挂到 Overlay.of(context, rootOverlay: true)），务必在 MaterialApp 之下调用 / Requires a context below MaterialApp for overlay insertion
- duration 默认 3 秒自动关闭；传 Duration.zero 可禁用自动关闭，此时配合 closable 手动关闭 / Duration.zero disables auto-close; keep closable for manual dismissal
- 同一时刻最多显示 5 条（_maxCount），超出时自动顶掉最早的通知；批量操作建议合并提示或调用 hide() 统一清理 / Max 5 concurrent, oldest evicted; hide() clears all
- 连续弹出时通知按固定槽位（100px）自上而下堆叠，顶部偏移随数量递增，不会互相遮挡 / Notifications stack downward in fixed 100px slots
- type 决定左侧图标与描边色（success/error/warning/info），可传 icon 完全自定义图标；closable=false 隐藏关闭按钮 / type drives icon + accent border; icon fully customizes it
- onClose 在通知真正关闭（自动或手动，含退出动画完成后）触发，适合埋点或联动后续操作 / onClose fires after the exit animation completes

## 搭配推荐 / Compose with
- 搭配 ParkButton 触发操作后弹出结果通知，形成「操作 → 反馈」闭环 / ParkButton to trigger actions and show results
- 搭配 ParkDialog 做分级提示：需要用户确认的重型操作用对话框，轻量结果用通知 / ParkDialog for confirmations, notification for lightweight results
- 表单提交场景搭配 ParkForm 校验，提交失败时用 error 类型通知反馈 / ParkForm submit failure surfaced as error notifications

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.success / error / warning / info | 类型色：左侧图标 + 描边色 |
| 色彩 | colors.surface / textPrimary / textSecondary | 通知底色、标题与描述文字 |
| 字体 | typography.sizeBodySmall / sizeCaption / weightBold | 标题 14px 加粗、描述 13px；圆角 radius.brMd (12px)、阴影 shadows.md |
| 间距 | spacing.base / md / xs | 内边距与屏幕右边距 16px、图标间距 12px、标题与描述间距 4px |
''',
);

// ========================================================================
// Demo builders
// ========================================================================

Widget _buildSpaceHDemo(BuildContext context) {
  return ParkSpace(
    size: 12,
    children: [_chip(context, 'A'), _chip(context, 'B'), _chip(context, 'C')],
  );
}

Widget _buildSpaceVDemo(BuildContext context) {
  return ParkSpace(
    size: 8,
    direction: Axis.vertical,
    children: [_chip(context, '1'), _chip(context, '2'), _chip(context, '3')],
  );
}

Widget _buildSpaceWrapDemo(BuildContext context) {
  return ParkSpace(
    wrap: true,
    size: 8,
    children: List.generate(12, (i) => _chip(context, 'Tag $i')),
  );
}

Widget _chip(BuildContext c, String t) => Container(
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Theme.of(c).extension<ParkThemeData>()?.colors.brandLight,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(t, style: const TextStyle(fontSize: 12)),
);

Widget _buildCDDemo1(BuildContext c) =>
    const ParkCountdown(remaining: Duration(minutes: 5));
Widget _buildCDDemo2(BuildContext c) => const ParkCountdown(
  remaining: Duration(hours: 1),
  size: ParkCountdownSize.small,
);
Widget _buildCDDemo3(BuildContext c) => const ParkCountdown(
  remaining: Duration(hours: 1),
  size: ParkCountdownSize.medium,
);
Widget _buildCDDemo4(BuildContext c) => const ParkCountdown(
  remaining: Duration(hours: 1),
  size: ParkCountdownSize.large,
);
Widget _buildCDDemo5(BuildContext c) => const ParkCountdown(
  remaining: Duration(minutes: 10),
  theme: ParkCountdownTheme.round,
);
Widget _buildCDDemo6(BuildContext c) => const ParkCountdown(
  remaining: Duration(minutes: 10),
  theme: ParkCountdownTheme.square,
);
Widget _buildCDDemo7(BuildContext c) =>
    const ParkCountdown(remaining: Duration(minutes: 3), loading: true);
Widget _buildCDController(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    bool _started = false;
    final controller = ParkCountdownController(
      remaining: const Duration(seconds: 30),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkCountdown(
          remaining: const Duration(seconds: 30),
          controller: controller,
        ),
        SizedBox(height: _kSpacing.sm),
        Wrap(
          spacing: _kSpacing.xs,
          children: <Widget>[
            ParkButton(
              child: const Text('开始'),
              onPressed: _started
                  // ignore: dead_code
                  ? null
                  : () {
                      controller.start(null);
                      setState(() => _started = true);
                    },
            ),
            ParkButton(
              child: const Text('暂停'),
              onPressed: () => controller.pause(),
            ),
            ParkButton(
              child: const Text('重置'),
              onPressed: () {
                controller.reset();
                setState(() => _started = false);
              },
            ),
          ],
        ),
      ],
    );
  },
);

Widget _buildQRDemo1(BuildContext c) =>
    const ParkQRCode(data: 'https://flutter.dev', size: 180);
Widget _buildWMDemo1(BuildContext c) => ParkWatermark(
  text: '机密',
  child: Container(
    height: 100,
    color: Theme.of(c).extension<ParkThemeData>()?.colors.background,
    child: const Center(child: Text('受保护的内容')),
  ),
);
Widget _buildLayoutDemo1(BuildContext c) => SizedBox(
  height: 260,
  child: ParkLayout(
    header: Container(
      height: 44,
      color: _kColors.surface,
      child: const Center(child: Text('顶栏')),
    ),
    sidebar: Container(
      width: 110,
      color: _kColors.background,
      child: const Center(child: Text('侧边栏')),
    ),
    body: const Center(child: Text('内容区域')),
    footer: Container(
      height: 32,
      color: _kColors.surface,
      child: const Center(child: Text('页脚')),
    ),
  ),
);
Widget _buildLayoutRight(BuildContext c) => SizedBox(
  height: 260,
  child: ParkLayout(
    sidebarLeft: false,
    header: Container(
      height: 44,
      color: _kColors.surface,
      child: const Center(child: Text('顶栏')),
    ),
    sidebar: Container(
      width: 110,
      color: _kColors.background,
      child: const Center(child: Text('侧边栏')),
    ),
    body: const Center(child: Text('内容区域')),
    footer: Container(
      height: 32,
      color: _kColors.surface,
      child: const Center(child: Text('页脚')),
    ),
  ),
);
Widget _buildLayoutNoDivider(BuildContext c) => SizedBox(
  height: 260,
  child: ParkLayout(
    showSidebarDivider: false,
    header: Container(
      height: 44,
      color: _kColors.surface,
      child: const Center(child: Text('顶栏')),
    ),
    sidebar: Container(
      width: 110,
      color: _kColors.background,
      child: const Center(child: Text('侧边栏')),
    ),
    body: const Center(child: Text('内容区域')),
  ),
);
Widget _buildLayoutHeaderOnly(BuildContext c) => SizedBox(
  height: 200,
  child: ParkLayout(
    header: Container(
      height: 44,
      color: _kColors.surface,
      child: const Center(child: Text('顶栏')),
    ),
    body: const Center(child: Text('仅内容区域')),
  ),
);
Widget _buildAnchorDemo1(BuildContext c) => ParkAnchor(
  items: const [
    ParkAnchorItem(key: 'a', label: '第一部分'),
    ParkAnchorItem(key: 'b', label: '第二部分'),
  ],
);
Widget _buildAnchorOffset(BuildContext c) => ParkAnchor(
  offset: 40,
  items: const [
    ParkAnchorItem(key: 'a', label: '第一部分'),
    ParkAnchorItem(key: 'b', label: '第二部分'),
  ],
);
Widget _buildAnchorOnChanged(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    String selected = 'a';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkAnchor(
          items: const [
            ParkAnchorItem(key: 'a', label: '第一部分'),
            ParkAnchorItem(key: 'b', label: '第二部分'),
          ],
          onChanged: (key) => setState(() => selected = key),
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前选中：$selected',
          style: TextStyle(fontSize: 13, color: _kColors.textSecondary),
        ),
      ],
    );
  },
);
Widget _buildAnchorScroll(BuildContext context) {
  final ScrollController scrollController = ScrollController();
  return StatefulBuilder(
    builder: (BuildContext ctx, void Function(void Function()) setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ParkAnchor(
              scrollController: scrollController,
              items: const [
                ParkAnchorItem(key: 'section1', label: '基础信息'),
                ParkAnchorItem(key: 'section2', label: '详细信息'),
                ParkAnchorItem(key: 'section3', label: '设置'),
              ],
              onChanged: (key) {},
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView(
              controller: scrollController,
              children: const [
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: KeyedSubtree(
                    key: Key('section1'),
                    child: Column(
                      children: [
                        Text(
                          '基础信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('这是基础信息区域的内容，点击锚点可跳转到这里。'),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: KeyedSubtree(
                    key: Key('section2'),
                    child: Column(
                      children: [
                        Text(
                          '详细信息',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('这是详细信息区域的内容，点击锚点可跳转到这里。'),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: KeyedSubtree(
                    key: Key('section3'),
                    child: Column(
                      children: [
                        Text(
                          '设置',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('这是设置区域的内容，点击锚点可跳转到这里。'),
                      ],
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
}

Widget _buildMenuDemo1(BuildContext c) => ParkMenu(
  items: const [
    ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
    ParkMenuItem(
      key: '2',
      label: '设置',
      icon: Icons.settings,
      children: [ParkMenuItem(key: '2-1', label: '个人资料')],
    ),
  ],
);
Widget _buildMenuSelected(BuildContext c) => ParkMenu(
  selectedKey: '1',
  items: const [
    ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
    ParkMenuItem(
      key: '2',
      label: '设置',
      icon: Icons.settings,
      children: [ParkMenuItem(key: '2-1', label: '个人资料')],
    ),
  ],
);
Widget _buildMenuExpanded(BuildContext c) => ParkMenu(
  defaultExpandedKeys: const {'2'},
  items: const [
    ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
    ParkMenuItem(
      key: '2',
      label: '设置',
      icon: Icons.settings,
      children: [ParkMenuItem(key: '2-1', label: '个人资料')],
    ),
  ],
);
Widget _buildMenuLight(BuildContext c) => ParkMenu(
  themeMode: ParkMenuThemeMode.light,
  items: const [
    ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
    ParkMenuItem(
      key: '2',
      label: '设置',
      icon: Icons.settings,
      children: [ParkMenuItem(key: '2-1', label: '个人资料')],
    ),
  ],
);
Widget _buildMenuOnSelect(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    String selected = '-';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkMenu(
          items: const [
            ParkMenuItem(key: '1', label: '首页', icon: Icons.home),
            ParkMenuItem(
              key: '2',
              label: '设置',
              icon: Icons.settings,
              children: [ParkMenuItem(key: '2-1', label: '个人资料')],
            ),
          ],
          onSelect: (key) => setState(() => selected = key),
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前选中：$selected',
          style: TextStyle(fontSize: 13, color: _kColors.textSecondary),
        ),
      ],
    );
  },
);
Widget _buildTPDemo1(BuildContext c) => ParkTimePicker();
Widget _buildCPDemo1(BuildContext c) => ParkColorPicker();
Widget _buildCPValue(BuildContext c) => ParkColorPicker(value: _kColors.brand);
Widget _buildCPPresets(BuildContext c) => ParkColorPicker(
  presetColors: [
    _kColors.brand,
    _kColors.success,
    _kColors.warning,
    _kColors.error,
  ],
);
Widget _buildCPOnChanged(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    Color color = _kColors.brand;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkColorPicker(
          value: color,
          onChanged: (c) => setState(() => color = c),
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前：#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
          style: TextStyle(fontSize: 13, color: _kColors.textSecondary),
        ),
      ],
    );
  },
);
Widget _buildACDemo1(BuildContext c) =>
    ParkAutoComplete(options: const ['apple', 'banana', 'cherry', 'date']);
Widget _buildACOnSelected(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    String selected = '-';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkAutoComplete(
          options: const ['apple', 'banana', 'cherry', 'date'],
          onSelected: (v) => setState(() => selected = v),
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '已选中：$selected',
          style: TextStyle(fontSize: 13, color: _kColors.textSecondary),
        ),
      ],
    );
  },
);
Widget _buildACOnChanged(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    String text = '';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkAutoComplete(
          options: const ['apple', 'banana', 'cherry', 'date'],
          onChanged: (v) => setState(() => text = v),
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '输入：$text',
          style: TextStyle(fontSize: 13, color: _kColors.textSecondary),
        ),
      ],
    );
  },
);
Widget _buildACMax(BuildContext c) => ParkAutoComplete(
  maxSuggestions: 3,
  options: const ['apple', 'banana', 'cherry', 'date', 'elderberry'],
);
Widget _buildACHint(BuildContext c) => ParkAutoComplete(
  hintText: '搜索水果',
  options: const ['apple', 'banana', 'cherry'],
);
Widget _buildACFilter(BuildContext c) => ParkAutoComplete(
  filterFn: (input, option) =>
      option.toLowerCase().startsWith(input.toLowerCase()),
  options: const ['apple', 'banana', 'cherry', 'date'],
);
Widget _buildINDemo1(BuildContext c) =>
    ParkInputNumber(min: 0, max: 100, step: 5);
Widget _buildINOnChanged(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    double value = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkInputNumber(
          min: 0,
          max: 100,
          step: 5,
          onChanged: (v) => setState(() => value = v),
        ),
        SizedBox(height: _kSpacing.sm),
        Text(
          '当前值：${value.toInt()}',
          style: TextStyle(fontSize: 13, color: _kColors.textSecondary),
        ),
      ],
    );
  },
);
Widget _buildINPrecision(BuildContext c) =>
    ParkInputNumber(min: 0, max: 1, step: 0.1, precision: 2);
Widget _buildINLabel(BuildContext c) =>
    ParkInputNumber(label: '数量', min: 0, max: 10);
Widget _buildINDisabled(BuildContext c) =>
    ParkInputNumber(disabled: true, value: 5);
Widget _buildINReadOnly(BuildContext c) =>
    ParkInputNumber(readOnly: true, value: 42);
Widget _buildINBinding(BuildContext context) {
  final service = ParkBindingService(<String, dynamic>{'age': 18});
  final modelNotifier = ValueNotifier<int>(0);
  service.watchEffect(() {
    service.getValue<num>('age');
    modelNotifier.value++;
  });
  return ValueListenableBuilder<int>(
    valueListenable: modelNotifier,
    builder: (BuildContext ctx, int _, Widget? __) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ParkInputNumber(
            label: '年龄',
            bindKey: 'age',
            bindingService: service,
            min: 0,
            max: 150,
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
                    'model: ${service.model.toString()}',
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
    },
  );
}

Widget _buildPCDemo1(BuildContext c) => ParkPopconfirm(
  title: '确认删除？',
  child: ParkButton(child: const Text('删除')),
);
Widget _buildAlertInfo(BuildContext c) =>
    ParkAlert(type: ParkAlertType.info, message: '这是一条信息提示');
Widget _buildAlertSuccess(BuildContext c) =>
    ParkAlert(type: ParkAlertType.success, message: '操作成功完成');
Widget _buildAlertWarning(BuildContext c) =>
    ParkAlert(type: ParkAlertType.warning, message: '请注意磁盘空间不足');
Widget _buildAlertError(BuildContext c) =>
    ParkAlert(type: ParkAlertType.error, message: '提交失败，请重试');
Widget _buildAlertDesc(BuildContext c) => ParkAlert(
  type: ParkAlertType.info,
  message: '系统通知',
  description: '今晚 23:00 将进行维护，预计 2 小时',
);
Widget _buildAlertClosable(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    bool visible = true;
    return visible
        ? ParkAlert(
            type: ParkAlertType.info,
            message: '点击右上角关闭',
            closable: true,
            onClose: () => setState(() => visible = false),
          )
        // ignore: dead_code
        : Text(
            '已关闭',
            style: TextStyle(fontSize: 14, color: _kColors.textSecondary),
          );
  },
);
Widget _buildAlertBanner(BuildContext c) =>
    ParkAlert(type: ParkAlertType.warning, message: '横幅提示：请尽快处理', banner: true);
Widget _buildAlertIcon(BuildContext c) => ParkAlert(
  type: ParkAlertType.info,
  message: '自定义图标提示',
  icon: const Icon(Icons.lightbulb_outline),
);
Widget _buildAlertNoIcon(BuildContext c) =>
    ParkAlert(type: ParkAlertType.info, message: '不显示图标', showIcon: false);
Widget _buildNotifyDemo1(BuildContext context) => ParkButton(
  child: const Text('显示通知'),
  onPressed: () => ParkNotification.show(
    context,
    type: ParkNotificationType.success,
    title: '操作成功',
    description: '数据已保存',
  ),
);
Widget _buildTransferDemo1(BuildContext c) => ParkTransfer(
  dataSource: const [
    ParkTransferItem(key: '1', title: '权限A'),
    ParkTransferItem(key: '2', title: '权限B'),
    ParkTransferItem(key: '3', title: '权限C'),
  ],
);
Widget _buildTreeDemo1(BuildContext c) => ParkTree(
  data: const [
    ParkTreeNode(
      key: '1',
      label: '根节点',
      children: [
        ParkTreeNode(key: '1-1', label: '子节点A'),
        ParkTreeNode(key: '1-2', label: '子节点B'),
      ],
    ),
    ParkTreeNode(key: '2', label: '独立节点'),
  ],
);
Widget _buildTreeDemo2(BuildContext c) => ParkTree(
  multiSelect: true,
  data: const [
    ParkTreeNode(key: 'a', label: '选项A'),
    ParkTreeNode(key: 'b', label: '选项B'),
    ParkTreeNode(key: 'c', label: '选项C'),
  ],
);

// ── ParkSpace 新增 demos ────────────────────────────────────────────────
Widget _buildSpacePresetDemo(BuildContext context) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkSpace.sm(
      children: [
        _chip(context, 'sm 8'),
        _chip(context, 'sm 8'),
        _chip(context, 'sm 8'),
      ],
    ),
    const SizedBox(height: _kGapSm),
    ParkSpace.md(
      children: [
        _chip(context, 'md 16'),
        _chip(context, 'md 16'),
        _chip(context, 'md 16'),
      ],
    ),
    const SizedBox(height: _kGapSm),
    ParkSpace.lg(
      children: [
        _chip(context, 'lg 24'),
        _chip(context, 'lg 24'),
        _chip(context, 'lg 24'),
      ],
    ),
  ],
);
Widget _buildSpaceAlignDemo(BuildContext context) => SizedBox(
  width: 280,
  child: ParkSpace(
    size: _kGapSm,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _chip(context, '左 / L'),
      _chip(context, '中 / M'),
      _chip(context, '右 / R'),
    ],
  ),
);

// ── ParkQRCode 新增 demos ──────────────────────────────────────────────
Widget _buildQRDemo2(BuildContext c) {
  final park = Theme.of(c).extension<ParkThemeData>() ?? ParkThemeData.light();
  return ParkQRCode(
    data: 'PARK UI',
    size: 160,
    foregroundColor: park.colors.brand,
    backgroundColor: park.colors.surface,
  );
}

Widget _buildQRDemo3(BuildContext c) {
  final park = Theme.of(c).extension<ParkThemeData>() ?? ParkThemeData.light();
  return ParkQRCode(
    data: 'LOGO',
    size: 160,
    foregroundColor: park.colors.textPrimary,
    logo: Icon(Icons.flutter_dash, color: park.colors.brand, size: 32),
    logoSize: 44,
  );
}

Widget _buildQRDemo4(BuildContext c) => const ParkQRCode(
  data: 'https://park.dev',
  size: 160,
  errorCorrectionLevel: ParkQRErrorCorrectionLevel.high,
);

// ── ParkWatermark 新增 demos ───────────────────────────────────────────
Widget _wmDemoContent(BuildContext c, String text) {
  final park = Theme.of(c).extension<ParkThemeData>() ?? ParkThemeData.light();
  return Container(
    color: park.colors.background,
    height: 100,
    child: Center(child: Text(text)),
  );
}

Widget _buildWMDemo2(BuildContext c) {
  final park = Theme.of(c).extension<ParkThemeData>() ?? ParkThemeData.light();
  return ParkWatermark(
    image: Icon(Icons.verified, color: park.colors.brand, size: 20),
    gapX: 90,
    gapY: 70,
    child: _wmDemoContent(c, '受保护的内容'),
  );
}

Widget _buildWMDemo3(BuildContext c) {
  final park = Theme.of(c).extension<ParkThemeData>() ?? ParkThemeData.light();
  return ParkWatermark(
    text: 'DRAFT',
    color: park.colors.warning.withAlpha(80),
    child: _wmDemoContent(c, '草稿文档'),
  );
}

Widget _buildWMDemo4(BuildContext c) {
  final park = Theme.of(c).extension<ParkThemeData>() ?? ParkThemeData.light();
  return ParkWatermark(
    text: 'PARK',
    rotate: -15,
    gapX: 80,
    gapY: 80,
    color: park.colors.textSecondary,
    child: _wmDemoContent(c, '受保护的内容'),
  );
}

// ── ParkTree 新增 demos ────────────────────────────────────────────────
Widget _buildTreeSelectDemo(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    String selected = '';
    return ParkTree(
      data: const [
        ParkTreeNode(key: 's1', label: '项目 A'),
        ParkTreeNode(key: 's2', label: '项目 B'),
        ParkTreeNode(key: 's3', label: '项目 C'),
      ],
      selectedKeys: selected.isEmpty ? null : [selected],
      onSelect: (k) {
        selected = k;
        setState(() {});
      },
    );
  },
);
Widget _buildTreeLineDemo(BuildContext c) => ParkTree(
  showLine: true,
  data: const [
    ParkTreeNode(
      key: '1',
      label: '根节点',
      children: [
        ParkTreeNode(key: '1-1', label: '子节点A'),
        ParkTreeNode(key: '1-2', label: '子节点B'),
      ],
    ),
    ParkTreeNode(key: '2', label: '独立节点'),
  ],
);
Widget _buildTreeIconDemo(BuildContext c) => ParkTree(
  nodeIcon: Icons.folder,
  showLine: true,
  data: const [
    ParkTreeNode(
      key: '1',
      label: '资料',
      children: [
        ParkTreeNode(key: '1-1', label: '图片'),
        ParkTreeNode(key: '1-2', label: '文档'),
      ],
    ),
    ParkTreeNode(key: '2', label: '设置'),
  ],
);

// ── ParkTimePicker 新增 demos ──────────────────────────────────────────
Widget _buildTPDemo2(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    TimeOfDay? picked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkTimePicker(
          value: picked,
          onChanged: (v) {
            picked = v;
            setState(() {});
          },
        ),
        const SizedBox(height: _kGapSm),
        Text(
          picked != null
              ? '已选 / Selected: ${picked!.format(ctx)}'
              : '未选择 / Not selected',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  },
);
Widget _buildTPDemo3(BuildContext c) =>
    ParkTimePicker(label: '开始时间 / Start', showSeconds: true);
Widget _buildTPDemo4(BuildContext c) =>
    ParkTimePicker(disabled: true, placeholder: '不可编辑 / Disabled');

// ── ParkTransfer 新增 demos ────────────────────────────────────────────
Widget _buildTransferDemo2(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    List<String> keys = [];
    TransferDirection? dir;
    const data = [
      ParkTransferItem(key: '1', title: '权限A'),
      ParkTransferItem(key: '2', title: '权限B'),
      ParkTransferItem(key: '3', title: '权限C'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 340,
          child: ParkTransfer(
            dataSource: data,
            onChange: (k, d) {
              keys = k;
              dir = d;
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: _kGapSm),
        Text(
          '已选 keys: ${keys.join(",")} | 方向 / dir: ${dir?.name ?? "-"}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  },
);
Widget _buildTransferDemo3(BuildContext c) => SizedBox(
  height: 340,
  child: ParkTransfer(
    showSearch: true,
    dataSource: const [
      ParkTransferItem(key: '1', title: '选项 A'),
      ParkTransferItem(key: '2', title: '选项 B'),
      ParkTransferItem(key: '3', title: '选项 C'),
      ParkTransferItem(key: '4', title: '选项 D'),
    ],
    leftTitle: const Text('候选 / Cand'),
    rightTitle: const Text('已选 / Sel'),
  ),
);

// ── ParkNotification 新增 demos ────────────────────────────────────────
Widget _buildNotifyDemo2(BuildContext context) => ParkButton(
  child: const Text('错误通知 / Error'),
  onPressed: () => ParkNotification.show(
    context,
    type: ParkNotificationType.error,
    title: '保存失败',
    description: '网络异常，请稍后重试',
  ),
);
Widget _buildNotifyDemo3(BuildContext context) => ParkButton(
  child: const Text('警告通知 / Warning'),
  onPressed: () => ParkNotification.show(
    context,
    type: ParkNotificationType.warning,
    title: '注意',
    description: '当前为只读模式',
  ),
);
Widget _buildNotifyDemo4(BuildContext context) => ParkButton(
  child: const Text('信息通知 / Info'),
  onPressed: () => ParkNotification.show(
    context,
    type: ParkNotificationType.info,
    title: '提示',
    description: '有新版本可用',
  ),
);
Widget _buildNotifyDemo5(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    bool closed = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkButton(
          child: const Text('显示通知 / Show'),
          onPressed: () => ParkNotification.show(
            ctx,
            type: ParkNotificationType.info,
            title: '操作完成',
            description: '关闭后触发 onClose',
            onClose: () {
              closed = true;
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: _kGapSm),
        Text(
          closed ? '已关闭 onClose / closed' : '显示中 / showing',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  },
);
Widget _buildNotifyDemo6(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkButton(
            child: const Text('显示 / Show'),
            onPressed: () => ParkNotification.show(
              ctx,
              type: ParkNotificationType.success,
              title: '通知',
              duration: const Duration(seconds: 60),
            ),
          ),
          const SizedBox(height: _kGapSm),
          ParkButton(
            child: const Text('隐藏 hide()'),
            onPressed: () => ParkNotification.hide(),
          ),
        ],
      ),
);

// ── ParkPopconfirm 新增 demos ──────────────────────────────────────────
Widget _buildPCDemo2(BuildContext context) => StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    String result = '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkPopconfirm(
          title: '确认提交？',
          description: '点击确认或取消查看回调',
          onConfirm: () {
            result = '已确认 / confirmed';
            setState(() {});
          },
          onCancel: () {
            result = '已取消 / cancelled';
            setState(() {});
          },
          child: const ParkButton(child: Text('操作 / Action')),
        ),
        const SizedBox(height: _kGapSm),
        Text('结果 / result: $result', style: const TextStyle(fontSize: 13)),
      ],
    );
  },
);
Widget _buildPCDemo3(BuildContext c) => ParkPopconfirm(
  title: '删除全部数据？',
  description: '此操作不可恢复',
  danger: true,
  child: const ParkButton(child: Text('删除')),
);
Widget _buildPCDemo4(BuildContext c) => ParkPopconfirm(
  title: '提交订单？',
  confirmLoading: true,
  child: const ParkButton(child: Text('提交')),
);
Widget _buildPCDemo5(BuildContext c) => ParkPopconfirm(
  title: '继续下一步？',
  confirmText: '是的',
  cancelText: '不了',
  child: const ParkButton(child: Text('下一步')),
);

// ---------------------------------------------------------------------------
// ParkApp
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkAppSpec = ParkComponentSpec(
  name: 'ParkApp',
  title: '全局配置 / App Shell',
  category: 'base',
  description:
      '全局配置包装器，对标 Ant Design ConfigProvider。'
      '封装 MaterialApp + ParkConfigProvider + ParkLocalizationsWidget，'
      '统一注入主题、本地化和 Overlay context。'
      ' / Global configuration wrapper, mirroring Ant Design ConfigProvider. '
      'Wraps MaterialApp with Park theme, localizations, and Overlay context injection.',
  icon: Icons.app_settings_alt_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(name: 'title', type: 'String', defaultVal: "'Park App'", description: '应用标题（透传 MaterialApp.title）/ App title'),
    ParkPropertyDef(name: 'parkTheme', type: 'ParkThemeData?', defaultVal: 'null', description: 'Park 亮色主题（null 时使用 ParkThemeData.light()）/ Light theme'),
    ParkPropertyDef(name: 'parkDarkTheme', type: 'ParkThemeData?', defaultVal: 'null', description: 'Park 暗色主题（null 时使用 ParkThemeData.dark()）/ Dark theme'),
    ParkPropertyDef(name: 'themeMode', type: 'ThemeMode', defaultVal: 'ThemeMode.system', description: '主题模式（亮色/暗色/跟随系统）/ Theme mode'),
    ParkPropertyDef(name: 'locale', type: 'ParkLocale', defaultVal: 'ParkLocale.zh', description: '当前语言环境 / Current locale'),
    ParkPropertyDef(name: 'home', type: 'Widget?', defaultVal: 'null', description: '应用首页页面 / Home page'),
    ParkPropertyDef(name: 'child', type: 'Widget?', defaultVal: 'null', description: '自定义子组件（优先级高于 home）/ Custom child (overrides home)'),
    ParkPropertyDef(name: 'initialRoute', type: 'String?', defaultVal: 'null', description: '初始路由 / Initial route'),
    ParkPropertyDef(name: 'onGenerateRoute', type: 'RouteFactory?', defaultVal: 'null', description: '路由生成器 / Route generator'),
    ParkPropertyDef(name: 'routes', type: 'Map<String, WidgetBuilder>?', defaultVal: 'null', description: '路由表 / Route table'),
    ParkPropertyDef(name: 'builder', type: 'TransitionBuilder?', defaultVal: 'null', description: '全局 builder / Global builder'),
    ParkPropertyDef(name: 'darkTheme', type: 'ThemeData?', defaultVal: 'null', description: 'Flutter 暗色 ThemeData / Flutter dark ThemeData'),
    ParkPropertyDef(name: 'theme', type: 'ThemeData?', defaultVal: 'null', description: 'Flutter 亮色 ThemeData / Flutter light ThemeData'),
    ParkPropertyDef(name: 'debugShowCheckedModeBanner', type: 'bool', defaultVal: 'false', description: '是否显示调试标记 / Debug banner'),
    ParkPropertyDef(name: 'navigatorObservers', type: 'List<NavigatorObserver>?', defaultVal: 'null', description: '导航观察者 / Navigator observers'),
    ParkPropertyDef(name: 'additionalExtensions', type: 'List<ThemeExtension<dynamic>>?', defaultVal: 'null', description: '额外 ThemeExtension 列表 / Additional theme extensions'),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkApp(
  title: 'My App',
  parkTheme: ParkThemeData.light(),
  locale: ParkLocale.zh,
  home: MyHomePage(),
)
''',
  guide: '''
## 何时使用 / When to use
- 作为 Park UI 应用的根组件 / As the root widget of a Park UI application
- 替代直接使用 MaterialApp，自动注入 Park 主题和本地化 / Replaces MaterialApp, auto-injects Park theme and localizations

## 使用建议 / Usage tips
- 使用 ParkApp 替代 MaterialApp 可自动完成 ParkThemeData 注入、ParkLocalizations 注入、ParkConfigProvider 注入
- parkTheme / parkDarkTheme 为 null 时自动使用 light() / dark() 预设
- locale 支持 zh / en / ja / ko / es / fr 六种语言
- child 优先级高于 home；设置 routes 时 home 自动置 null
- additionalExtensions 可追加自定义 ThemeExtension
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础用法 / Basic',
      description: '使用 ParkApp 包裹首页 / Wrap home page with ParkApp',
      code: '''
ParkApp(
  title: 'Demo App',
  locale: ParkLocale.zh,
  home: Scaffold(
    body: Center(child: Text('Hello Park')),
  ),
)''',
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ParkApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('ParkApp 是应用根组件，通常不在组件展示页内渲染。', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('用法：替代 MaterialApp 作为应用入口。', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    ),
  ],
);

// ────────────────────────────────────────────────────────────────────────────
// ParkMap — 地图（flutter_map + 天地图 WMTS）
// ────────────────────────────────────────────────────────────────────────────

final ParkComponentSpec _parkMapSpec = ParkComponentSpec(
  name: 'ParkMap',
  title: '地图',
  category: 'display',
  description:
      '基于 flutter_map 的跨平台地图组件（Android/iOS 纯 Dart 渲染），内置天地图 WMTS 底图，'
      '支持标记点、标记聚合、地图选点、距离圈与列表联动。天地图 key 通过构造参数注入，组件库不内置业务凭据。',
  icon: Icons.map,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'tiandituKey',
      type: 'String',
      defaultVal: '—',
      description: '天地图服务 key（必填，官网申请）/ Tianditu service key (required)',
      required: true,
    ),
    ParkPropertyDef(
      name: 'initialCenter',
      type: 'LatLng',
      defaultVal: 'LatLng(39.9042, 116.4074)',
      description: '初始中心点 / Initial center',
      required: false,
    ),
    ParkPropertyDef(
      name: 'initialZoom',
      type: 'double',
      defaultVal: '11',
      description: '初始缩放级别 / Initial zoom level',
      required: false,
    ),
    ParkPropertyDef(
      name: 'markers',
      type: 'List<ParkMapMarker>',
      defaultVal: '[]',
      description: '标记点列表 / Markers',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedMarkerId',
      type: 'String?',
      defaultVal: 'null',
      description: '受控选中的标记点 id（外部联动高亮）/ Controlled selected marker id',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectionEnabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否开启选点模式（点击地图回调 onMapTap）/ Enable pick-point mode',
      required: false,
    ),
    ParkPropertyDef(
      name: 'circleCenter',
      type: 'LatLng?',
      defaultVal: 'null',
      description: '距离圈中心（为空不绘制）/ Circle center',
      required: false,
    ),
    ParkPropertyDef(
      name: 'circleRadiusMeters',
      type: 'double',
      defaultVal: '1000',
      description: '距离圈半径（米，如 1000/3000）/ Circle radius in meters',
      required: false,
    ),
    ParkPropertyDef(
      name: 'enableClustering',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用标记聚合（标记数 >1 时生效）/ Enable marker clustering',
      required: false,
    ),
    ParkPropertyDef(
      name: 'clusterBuilder',
      type: 'ParkMapClusterBuilder?',
      defaultVal: 'null',
      description: '聚合节点构建器（默认数量徽标，可定制如「12 套」）/ Cluster widget builder',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onMarkerTap',
      signature: 'ValueChanged<ParkMapMarker>?',
      description: '标记点点击回调（供列表联动）/ Marker tap callback',
    ),
    ParkEventDef(
      name: 'onMapTap',
      signature: 'ValueChanged<LatLng>?',
      description: '选点模式开启时点击地图回调坐标 / Map tap callback (pick-point mode)',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础地图与标记',
      description: '天地图底图 + 自定义标记点 / Base map with markers',
      code: '''
ParkMap(
  tiandituKey: 'your_key',
  initialCenter: const LatLng(39.9042, 116.4074),
  initialZoom: 11,
  markers: [
    ParkMapMarker(id: '1', point: const LatLng(39.9042, 116.4074), child: Icon(Icons.home)),
  ],
  onMarkerTap: (m) => print('选中: \${m.id}'),
)''',
      builder: _buildMapDemoBase,
    ),
    ParkDemoScenario(
      title: '标记聚合',
      description: '启用聚合，自定义「N 套」聚合节点 / Clustering with custom label',
      code: '''
ParkMap(
  tiandituKey: 'your_key',
  initialCenter: const LatLng(39.9042, 116.4074),
  markers: [/* 多个标记点 */],
  clusterBuilder: (context, count) => Text('\$count 套'),
)''',
      builder: _buildMapDemoCluster,
    ),
    ParkDemoScenario(
      title: '选点与距离圈',
      description: '选点模式回调坐标 + 1km 距离圈 / Pick-point & radius circle',
      code: '''
ParkMap(
  tiandituKey: 'your_key',
  selectionEnabled: true,
  circleCenter: const LatLng(39.9042, 116.4074),
  circleRadiusMeters: 1000,
  onMapTap: (latLng) => print('选点: \${latLng.latitude}, \${latLng.longitude}'),
)''',
      builder: _buildMapDemoPick,
    ),
  ],
  basicUsageCode: '''ParkMap(
  tiandituKey: 'your_tianditu_key',
  initialCenter: const LatLng(39.9042, 116.4074),
  initialZoom: 12,
  markers: [
    ParkMapMarker(
      id: '1',
      point: const LatLng(39.9042, 116.4074),
      child: Icon(Icons.location_on, color: Colors.red),
    ),
  ],
  onMarkerTap: (marker) => print('选中标记: \${marker.id}'),
)''',
  guide: '''
## 何时使用 / When to use
- 「地图找房 / 找租客 / 发布选点」等需要地图底图 + 业务标记点联动的场景（livehome 地图能力 B 方案）/ Map-based browsing, listing, and point-picking scenarios (livehome Map Plan B)
- 需要按区域聚合展示大量标记点（如「12 套」房源聚合），避免标记重叠 / Aggregating dense markers (e.g. "12 listings") to avoid overlap
- 需要地图选点获取经纬度（如发布房源时选择位置）、或按距离圈筛选周边资源 / Picking coordinates on the map (listing location) or filtering nearby resources by radius
- 需要地图与外部列表双向联动：点击标记高亮列表项、点击列表项高亮标记 / Two-way map↔list linkage: tapping a marker highlights a list row, and vice versa

## 使用建议 / Usage tips
- tiandituKey 为必填参数，请到天地图官网申请；组件库不内置任何业务凭据，key 应由调用方注入 / tiandituKey is required; obtain one from Tianditu; the library never embeds credentials
- 标记点通过 markers 传入 [ParkMapMarker]（id + point + 自定义 child）；点击回调 onMarkerTap 返回对应标记，供列表联动 / Pass [ParkMapMarker]s (id + point + custom child); onMarkerTap returns the tapped marker for list linkage
- 列表 → 地图联动：外部维护 selectedMarkerId，匹配的标记会渲染其 selectedChild（未提供时复用 child）/ External selectedMarkerId drives the highlighted marker's selectedChild
- 选点：selectionEnabled 为 true 时点击地图触发 onMapTap 并回传 LatLng；关闭时点击仅用于平移 / Turn on selectionEnabled to receive LatLng on map taps; keep it off for pure panning
- 距离圈：传 circleCenter + circleRadiusMeters（米）即可绘制 CircleLayer 半径圈（如 1000=1km、3000=3km）/ Set circleCenter and circleRadiusMeters (meters) to draw a radius circle
- 聚合：enableClustering 默认开启（标记数 >1 时生效），clusterBuilder 可自定义聚合节点文案（如「12 套」）；聚合点击默认放大到聚合范围 / Clustering is on by default; customize the cluster label via clusterBuilder; tapping a cluster zooms to its bounds
- 平台：flutter_map 纯 Dart 渲染，Android / iOS 开箱即用，无需原生地图 SDK / Pure-Dart rendering: works on Android and iOS without native map SDKs

## 搭配推荐 / Compose with
- 与 ParkCard / ParkList 组合：地图在上、结果列表在下，onMarkerTap 与 selectedMarkerId 双向联动 / Pair with ParkCard or ParkList for a map-above, list-below layout with two-way linkage
- 与 ParkTag 组合展示距离圈内的统计信息（如「3km 内 12 套」）/ Use ParkTag to summarize radius stats (e.g. "12 listings within 3km")
- 与 ParkSearch 组合实现「搜索 → 地图定位 + 标记」的找房流程 / Combine with ParkSearch for a search → map-locate flow

## 设计令牌参考 / Design Token Reference
| 令牌类别 | 调用方式 | 说明 |
|---------|---------|------|
| 色彩 | colors.brand | 默认聚合节点背景、距离圈边框与填充色（brand 8% 透明度）|
| 色彩 | colors.surface | 聚合节点描边（白色描边提升可读性）|
| 色彩 | colors.textOnBrand | 聚合节点数量文字颜色 |
| 字体 | typography.sizeBodySmall / weightBold | 聚合节点数量字号与字重 |
| 间距 | — | 地图为容器组件，内边距由外层（如 ParkCard）控制 |
''',
);

Widget _buildMapDemoBase(BuildContext context) {
  return SizedBox(
    height: 260,
    child: ParkMap(
      tiandituKey: 'demo_key_placeholder',
      initialCenter: const LatLng(39.9042, 116.4074),
      initialZoom: 11,
      markers: <ParkMapMarker>[
        ParkMapMarker(
          id: '1',
          point: const LatLng(39.9042, 116.4074),
          child: const Icon(Icons.location_on, color: Colors.red, size: 30),
        ),
        ParkMapMarker(
          id: '2',
          point: const LatLng(39.9142, 116.4174),
          child: const Icon(Icons.home, color: Colors.blue, size: 30),
        ),
      ],
      onMarkerTap: (m) {},
    ),
  );
}

Widget _buildMapDemoCluster(BuildContext context) {
  final park = Theme.of(context).extension<ParkThemeData>() ??
      ParkThemeData.light();
  return SizedBox(
    height: 260,
    child: ParkMap(
      tiandituKey: 'demo_key_placeholder',
      initialCenter: const LatLng(39.9042, 116.4074),
      initialZoom: 11,
      markers: List<ParkMapMarker>.generate(12, (int i) {
        final double dLat = (i % 4) * 0.008 - 0.012;
        final double dLng = (i ~/ 4) * 0.008 - 0.012;
        return ParkMapMarker(
          id: '$i',
          point: LatLng(39.9042 + dLat, 116.4074 + dLng),
          child: Icon(Icons.location_on, color: park.colors.brand, size: 30),
        );
      }),
      clusterBuilder: (BuildContext ctx, int count) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: park.colors.brand,
          shape: BoxShape.circle,
          border: Border.all(color: park.colors.surface, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          '$count 套',
          style: TextStyle(
            color: park.colors.textOnBrand,
            fontSize: park.typography.sizeCaption,
            fontWeight: park.typography.weightBold,
          ),
        ),
      ),
      onMarkerTap: (m) {},
    ),
  );
}

Widget _buildMapDemoPick(BuildContext context) {
  return SizedBox(
    height: 260,
    child: ParkMap(
      tiandituKey: 'demo_key_placeholder',
      initialCenter: const LatLng(39.9042, 116.4074),
      initialZoom: 11,
      selectionEnabled: true,
      circleCenter: const LatLng(39.9042, 116.4074),
      circleRadiusMeters: 1000,
      onMapTap: (LatLng latLng) {},
    ),
  );
}
