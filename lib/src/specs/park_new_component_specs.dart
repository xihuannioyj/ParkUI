import 'package:flutter/material.dart';
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
## 使用指南
ParkSpace 替代手动在 children 间加 SizedBox。预设工厂：xs(4)/sm(8)/md(16)/lg(24)/xl(32)。
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
## 使用指南
支持 L/M/Q/H 四个纠错等级。可传入 logo widget 嵌入中心。
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
## 使用指南
通过 CustomPainter 叠加旋转文字水印。IgnorePointer 确保不阻挡内容交互。
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
## 使用指南
ParkTreeNode 支持递归 children。multiSelect 启用 checkbox 多选。loadChildren 实现异步加载。
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
## 使用指南
基于 Scaffold+Column+Row 实现。sidebarLeft 控制侧边栏左右位置，showSidebarDivider 控制分割线。
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
## 使用指南
ParkAnchorItem 包含 key 和 label。通过 ScrollController 联动滚动位置，offset 控制跳转偏移。
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
ParkMenuItem 支持递归 children 实现多级。selectedKey 控制高亮，defaultExpandedKeys 控制展开，light 切换浅色。
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
## 使用指南
基于 Flutter showTimePicker 封装。showSeconds 控制是否显示秒。
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
## 使用指南
默认 20 色环预设。可自定义 presetColors。选中项用 check 图标标记。onChanged 在选择色块时触发。
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
## 使用指南
基于 TextField + Overlay 实现。onSelected 选中建议、onChanged 监听输入。filterFn 可自定义过滤逻辑。
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
dataSource 定义全部项目，targetKeys 控制已选。支持搜索过滤和全选。
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
## 使用指南
基于 Overlay 弹出。danger 模式使用红色确认按钮。autoCloseAfterConfirm 控制点击后是否自动关闭。
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
## 使用指南
通过 ParkNotification.show(context, ...) 静态方法调用。支持 success/error/warning/info 四种类型。
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
  width: 240,
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
