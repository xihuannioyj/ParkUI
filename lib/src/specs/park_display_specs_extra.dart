// Park 展示组件补充规格 — 由 Agent 填充
// （ParkCard / ParkGrid / ParkList / ParkEllipsis / ParkTimeline / ParkTooltip /
//  ParkSticky / ParkDescriptions)
//
// 约定：
//  - 每个组件的 properties 枚举其全部公开构造参数；
//  - 每个事件 / 方法 / 关键形态变体均对应一个 demo（code 与 builder 完全一致）；
//  - 禁止裸字面量：颜色用 ParkColors.*，间距用 ParkSpacing.*，字号用 ParkTypography.*，
//    杜绝魔法变量；
//  - 双语（中文为主、英文并列）：每条属性 / 事件 / 方法注释均为中英双语；
//  - 交互回调（onPressed / onTap / onOpenChange / onStickyChanged 等）一律用
//    StatefulBuilder + setState 演示。
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

// ---------------------------------------------------------------------------
// ParkAvatarGroup
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkAvatarGroupSpec = ParkComponentSpec(
  name: 'ParkAvatarGroup',
  title: '头像组 / Avatar Group',
  category: 'display',
  description:
      '将多个头像重叠显示，超出 maxCount 的部分以 +N 计数呈现，'
      '常用于成员列表、协作者等场景。'
      ' / Overlaps multiple avatars and shows a +N counter when exceeding maxCount, '
      'ideal for member or collaborator lists.',
  icon: Icons.group_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'avatars',
      type: 'List<ParkAvatar>',
      required: true,
      description: '头像列表 / The list of avatars',
    ),
    ParkPropertyDef(
      name: 'maxCount',
      type: 'int',
      defaultVal: '5',
      description: '最大显示数量，超出显示 +N / Max visible count before +N',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkAvatarSize',
      defaultVal: 'ParkAvatarSize.small',
      description: '头像尺寸：small / medium / large / xlarge / Avatar size',
    ),
    ParkPropertyDef(
      name: 'overlap',
      type: 'double',
      defaultVal: '8',
      description: '头像重叠间距 / Overlap spacing between avatars',
    ),
    ParkPropertyDef(
      name: 'count',
      type: 'int?',
      defaultVal: 'null',
      description:
          '最大可见数，优先级高于 maxCount / Max visible count, overrides maxCount',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkAvatarGroup(
  avatars: [
    ParkAvatar(text: '张'),
    ParkAvatar(text: '李'),
    ParkAvatar(text: '王'),
  ],
  maxCount: 3,
  size: ParkAvatarSize.small,
)
''',
  guide: '''
## 何时使用 / When to use
- 展示一组成员 / 协作者头像 / Show a group of member or collaborator avatars
- 头像较多时折叠为 +N / Collapse overflow into a +N counter

## 使用建议 / Usage tips
- maxCount 控制最多展示的头像数，超出部分用 +N 表示 / maxCount limits visible avatars
- count 可强制覆盖可见数量，便于外部控制 / count overrides maxCount
- overlap 调整重叠间距，size 选择头像尺寸 / Tune overlap and size
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础头像组',
      description: '三个文字头像重叠展示。 / Three text avatars overlapped.',
      code: '''
ParkAvatarGroup(
  avatars: [
    ParkAvatar(text: '张'),
    ParkAvatar(text: '李'),
    ParkAvatar(text: '王'),
  ],
)''',
      builder: (BuildContext context) => ParkAvatarGroup(
        avatars: <ParkAvatar>[
          const ParkAvatar(text: '张'),
          const ParkAvatar(text: '李'),
          const ParkAvatar(text: '王'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '超出计数',
      description:
          '5 个头像但 maxCount 为 3，展示 +2。 / 5 avatars with maxCount 3 shows +2.',
      code: '''
ParkAvatarGroup(
  avatars: [
    ParkAvatar(text: '张'),
    ParkAvatar(text: '李'),
    ParkAvatar(text: '王'),
    ParkAvatar(text: '赵'),
    ParkAvatar(text: '钱'),
  ],
  maxCount: 3,
)''',
      builder: (BuildContext context) => ParkAvatarGroup(
        avatars: <ParkAvatar>[
          const ParkAvatar(text: '张'),
          const ParkAvatar(text: '李'),
          const ParkAvatar(text: '王'),
          const ParkAvatar(text: '赵'),
          const ParkAvatar(text: '钱'),
        ],
        maxCount: 3,
      ),
    ),
    ParkDemoScenario(
      title: '大尺寸',
      description: 'size 设为 large 放大头像。 / size large enlarges avatars.',
      code: '''
ParkAvatarGroup(
  size: ParkAvatarSize.large,
  avatars: [
    ParkAvatar(text: 'A'),
    ParkAvatar(text: 'B'),
    ParkAvatar(text: 'C'),
    ParkAvatar(text: 'D'),
  ],
)''',
      builder: (BuildContext context) => ParkAvatarGroup(
        size: ParkAvatarSize.large,
        avatars: <ParkAvatar>[
          const ParkAvatar(text: 'A'),
          const ParkAvatar(text: 'B'),
          const ParkAvatar(text: 'C'),
          const ParkAvatar(text: 'D'),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkMasonry
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkMasonrySpec = ParkComponentSpec(
  name: 'ParkMasonry',
  title: '瀑布流 / Masonry',
  category: 'display',
  description:
      '瀑布流布局组件，以"最短列优先"算法将列表项分配到多列中，形成高度参差的 Pinterest 风格布局。'
      '支持固定列数或根据 minColumnWidth 自动响应式计算列数，可配置间距、空状态、'
      '无限滚动懒加载（onLoadMore）。零第三方依赖，使用 Flutter 原生 CustomScrollView + SliverList。'
      ' / Masonry (waterfall) layout that distributes items across columns using a shortest-column-first '
      'algorithm, forming a Pinterest-style staggered grid. Supports fixed columns or responsive '
      'minColumnWidth, configurable spacing, empty state, and infinite scroll via onLoadMore. '
      'Zero third-party dependencies.',
  icon: Icons.grid_view_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<T>',
      required: true,
      description: '列表数据源 / List data source',
    ),
    ParkPropertyDef(
      name: 'itemBuilder',
      type: 'Widget Function(BuildContext, T, int)',
      required: true,
      description: '列表项构建器，泛型 T 约束数据类型 / Item builder with generics',
    ),
    ParkPropertyDef(
      name: 'columns',
      type: 'int',
      defaultVal: '2',
      description:
          '固定列数（优先级高于 minColumnWidth，必须 > 0）/ Fixed column count (overrides minColumnWidth, must be > 0)',
    ),
    ParkPropertyDef(
      name: 'minColumnWidth',
      type: 'double?',
      defaultVal: 'null',
      description:
          '最小列宽（响应式模式，根据容器宽度自动计算列数）/ Minimum column width for responsive column count',
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double',
      defaultVal: '8.0 (park.spacing.sm)',
      description: '卡片间统一间距（同时设置行间距和列间距）/ Unified gap between items',
    ),
    ParkPropertyDef(
      name: 'columnSpacing',
      type: 'double?',
      defaultVal: 'null (= spacing)',
      description:
          '列间距（设置后 spacing 仅用于行间距）/ Column gap (overrides spacing for columns)',
    ),
    ParkPropertyDef(
      name: 'emptyBuilder',
      type: 'Widget Function(BuildContext)?',
      defaultVal: 'null（显示"暂无数据"）/ null shows default empty state（）',
      description: '空状态构建器（items 为空时显示） / Empty-state builder',
    ),
    ParkPropertyDef(
      name: 'itemCount',
      type: 'int?',
      defaultVal: 'null (= items.length)',
      description:
          '懒加载项目总数（用于无限滚动判断是否加载全部）/ Total item count for infinite scroll',
    ),
    ParkPropertyDef(
      name: 'onLoadMore',
      type: 'Future<void> Function()?',
      defaultVal: 'null',
      description:
          '懒加载回调：滚动接近底部时触发 / Load-more callback fired near scroll bottom',
    ),
    ParkPropertyDef(
      name: 'loadingMore',
      type: 'bool',
      defaultVal: 'false',
      description: '是否正在加载更多（显示底部加载指示器）/ Whether loading more items',
    ),
    ParkPropertyDef(
      name: 'noMore',
      type: 'bool',
      defaultVal: 'false',
      description: '是否已无更多数据（显示"没有更多"）/ Whether all data has been loaded',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onLoadMore',
      signature: 'Future<void> Function()?',
      description:
          '滚动接近底部时触发，用于加载更多数据 / Fired when scrolling near the bottom for lazy loading',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkMasonry<String>(
  items: <String>['卡片 A', '卡片 B', '卡片 C', '卡片 D'],
  itemBuilder: (ctx, item, index) => Container(
    height: 80.0 + (index % 4) * 40.0,
    color: _kColors.surface,
    child: Center(child: Text(item)),
  ),
  columns: 2,
  spacing: 12,
)
''',
  guide: '''
## 何时使用 / When to use
- Pinterest 风格瀑布流、图片墙、商品卡片列表等高度不固定的多列布局 / Pinterest-style waterfall, image wall, product cards
- 需要将不同高度的内容块紧凑排列，最大化空间利用率 / Pack variable-height content blocks compactly

## 使用建议 / Usage tips
- 使用 columns 固定列数，或 minColumnWidth 让组件自动响应容器宽度 / Use columns for fixed count, or minColumnWidth for responsive
- itemBuilder 返回的 Widget 高度应自然由内容撑起，避免硬编码固定高度 / Let itemBuilder widgets size naturally
- spacing 控制卡间间距，columnSpacing 可独立控制列间距 / spacing for unified gap; columnSpacing for column-only gap
- 结合 itemCount + onLoadMore 实现无限滚动 / Pair itemCount + onLoadMore for infinite scroll
- 所有颜色/间距/圆角使用 park.* 设计令牌，禁止魔数 / Use park.* design tokens for colors/spacing/radius
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础瀑布流',
      description:
          '3 列固定列数，每项不同高度展示瀑布流效果 / 3 columns with varying item heights.',
      code: '''
ParkMasonry<String>(
  items: <String>['短内容', '中等长度内容展示', '较长一些的内容卡片', '短', '更长的内容展示区域', '中等'],
  itemBuilder: (ctx, item, index) => Container(
    height: 60.0 + (index % 3) * 40.0,
    decoration: BoxDecoration(
      color: _kColors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _kColors.border, width: 0.5),
    ),
    padding: EdgeInsets.all(12),
    alignment: Alignment.center,
    child: Text(item, style: TextStyle(fontSize: 14, color: _kColors.textPrimary)),
  ),
  columns: 3,
  spacing: 12,
)''',
      builder: (BuildContext context) => ParkMasonry<String>(
        items: const <String>[
          '短内容',
          '中等长度内容展示',
          '较长一些的内容卡片',
          '短',
          '更长的内容展示区域',
          '中等',
        ],
        itemBuilder: (BuildContext ctx, String item, int index) => Container(
          height: 60.0 + (index % 3) * 40.0,
          decoration: BoxDecoration(
            color: _kColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kColors.border, width: 0.5),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Text(
            item,
            style: TextStyle(fontSize: 14, color: _kColors.textPrimary),
          ),
        ),
        columns: 3,
        spacing: 12,
      ),
    ),
    ParkDemoScenario(
      title: '响应式列数 + 无限滚动',
      description:
          'minColumnWidth=180 自动计算列数，onLoadMore 懒加载模拟 / Responsive columns via minColumnWidth=180, onLoadMore lazy load demo.',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    final List<String> data = <String>['项 1', '项 2', '项 3', '项 4', '项 5', '项 6'];
    return SizedBox(
      height: 360,
      child: ParkMasonry<String>(
        items: data,
        minColumnWidth: 180,
        spacing: 10,
        noMore: data.length >= 12,
        onLoadMore: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          data.add('项 \${data.length + 1}');
          setState(() {});
        },
        itemBuilder: (ctx, item, index) => Container(
          height: 80.0 + (index % 4) * 30.0,
          decoration: BoxDecoration(
            color: _kColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kColors.brandLight, width: 0.5),
          ),
          padding: EdgeInsets.all(12),
          alignment: Alignment.center,
          child: Text(item, style: TextStyle(color: _kColors.textPrimary)),
        ),
      ),
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          final List<String> data = <String>[
            '项 1',
            '项 2',
            '项 3',
            '项 4',
            '项 5',
            '项 6',
          ];
          return SizedBox(
            height: 360,
            child: ParkMasonry<String>(
              items: data,
              minColumnWidth: 180,
              spacing: 10,
              noMore: data.length >= 12,
              onLoadMore: () async {
                await Future<void>.delayed(const Duration(milliseconds: 500));
                data.add('项 ${data.length + 1}');
                setState(() {});
              },
              itemBuilder: (BuildContext c, String item, int index) =>
                  Container(
                    height: 80.0 + (index % 4) * 30.0,
                    decoration: BoxDecoration(
                      color: _kColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _kColors.brandLight,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    child: Text(
                      item,
                      style: TextStyle(color: _kColors.textPrimary),
                    ),
                  ),
            ),
          );
        },
      ),
    ),
  ],
);

/// 展示类补充组件规格字典（12 个组件）。
Map<String, ParkComponentSpec> get parkDisplaySpecsExtra =>
    <String, ParkComponentSpec>{
      'ParkCard': _parkCardSpec,
      'ParkGrid': _parkGridSpec,
      'ParkList': _parkListSpec,
      'ParkMasonry': _parkMasonrySpec,
      'ParkEllipsis': _parkEllipsisSpec,
      'ParkTimeline': _parkTimelineSpec,
      'ParkTooltip': _parkTooltipSpec,
      'ParkSticky': _parkStickySpec,
      'ParkDescriptions': _parkDescriptionsSpec,
      'ParkAvatarGroup': _parkAvatarGroupSpec,
      'ParkStatistic': _parkStatisticSpec,
      'ParkSplitter': _parkSplitterSpec,
      'ParkFlex': _parkFlexSpec,
      'ParkGridRow': _parkGridRowSpec,
      'ParkGridCol': _parkGridColSpec,
    };

// ---------------------------------------------------------------------------
// ParkCard
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkCardSpec = ParkComponentSpec(
  name: 'ParkCard',
  title: '卡片 / Card',
  category: 'display',
  description:
      '通用内容卡片容器，支持标题区（title / titleText / extra）、自定义内容、封面、'
      '操作区、加载骨架屏与多种变体，可选 hoverable 浮起、可折叠与可点击 onPressed。'
      ' / Generic content card container supporting header (title / titleText / extra), '
      'custom content, cover, action bar, loading skeleton and variants, with optional '
      'hoverable elevation, collapsible and tappable onPressed.',
  icon: Icons.crop_square_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'Widget?',
      description:
          '自定义标题 Widget（优先级高于 titleText）/ Custom title widget (higher priority than titleText)',
    ),
    ParkPropertyDef(
      name: 'titleText',
      type: 'String?',
      description: '标题文字（当 title 为空时使用）/ Title text (used when title is null)',
    ),
    ParkPropertyDef(
      name: 'extra',
      type: 'Widget?',
      description: '标题栏右上角操作区 / Header trailing action area',
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '卡片内容 / Card body content',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示边框 / Whether to show a border',
    ),
    ParkPropertyDef(
      name: 'elevation',
      type: 'double?',
      defaultVal: 'null',
      description: '阴影高度（null 使用主题默认值）/ Elevation (null = theme default)',
    ),
    ParkPropertyDef(
      name: 'padding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null',
      description:
          '内容区内边距（null 使用尺寸预设默认值）/ Content padding (null = size preset default)',
    ),
    ParkPropertyDef(
      name: 'borderRadius',
      type: 'BorderRadius?',
      defaultVal: 'null',
      description: '圆角（null 使用主题默认值）/ Corner radius (null = theme default)',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null',
      description: '背景色（null 使用主题默认值）/ Background color (null = theme default)',
    ),
    ParkPropertyDef(
      name: 'hoverable',
      type: 'bool',
      defaultVal: 'false',
      description: '鼠标悬浮时是否浮起 / Whether to lift on hover',
    ),
    ParkPropertyDef(
      name: 'onPressed',
      type: 'VoidCallback?',
      description:
          '点击回调（不为 null 时卡片可点击）/ Tap callback (card is tappable when non-null)',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于加载状态（显示骨架屏）/ Whether to show a loading skeleton',
    ),
    ParkPropertyDef(
      name: 'actions',
      type: 'List<Widget>?',
      defaultVal: 'null',
      description:
          '底部操作栏（均匀分布的按钮，间以分割线）/ Bottom action bar (evenly spaced buttons split by dividers)',
    ),
    ParkPropertyDef(
      name: 'cover',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '封面图 / Widget（显示在标题之上）/ Cover image/widget shown above the header',
    ),
    ParkPropertyDef(
      name: 'variant',
      type: 'ParkCardVariant',
      defaultVal: 'ParkCardVariant.outlined',
      description: '卡片样式变体：outlined / ghost / inner / Card variant',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkCardSize',
      defaultVal: 'ParkCardSize.defaultSize',
      description: '卡片尺寸预设：small / defaultSize / Card size preset',
    ),
    ParkPropertyDef(
      name: 'headStyle',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在头部与内容之间显示分割线 / Show a divider between header and body',
    ),
    ParkPropertyDef(
      name: 'collapsible',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否可折叠（点击头部切换展开/收起）/ Whether the card is collapsible (tap header to toggle)',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onPressed',
      signature: 'VoidCallback?',
      description: '卡片点击回调 / Card tap callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkCard(
  titleText: '卡片标题',
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('卡片内容区域'),
  ),
)
''',
  guide: '''
## 设计令牌参考 / Design Token Reference
- 默认圆角：`radius.md` (12px)，详见 DESIGN_SYSTEM.md 5.1
- 默认内边距：`spacing.base` (16px)；small 变体：`spacing.sm` (8px)
- 默认阴影：`shadows.sm`；hover 时提升至 `shadows.md`
- 默认边框：`colors.border` 1px
- 表面风格由主题 `surfaceStyle` 控制（stripe/flat/glass/neo/neon）

## 何时使用 / When to use
- 聚合一组相关信息为独立卡片（如商品、文章、设置区块）/ Group related info into a standalone card
- 作为列表项或网格项的容器 / As a container for list or grid items

## 使用建议 / Usage tips
- 使用 titleText / extra 组织标题栏操作 / Use titleText / extra for header actions
- hoverable 用于可交互卡片提升反馈 / hoverable adds feedback for interactive cards
- collapsible 适合内容较长的可折叠区块 / collapsible suits long expandable sections
- 搭配 ParkDivider 分隔卡片内多个区块 / Pair with ParkDivider to separate sections
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础卡片',
      description: '带标题与内容的简单卡片 / Simple card with title and body.',
      code: '''
ParkCard(
  titleText: '卡片标题',
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('卡片内容区域'),
  ),
)''',
      builder: (BuildContext context) => ParkCard(
        titleText: '卡片标题',
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('卡片内容区域'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '带操作区',
      description:
          '标题栏右侧放置 extra 操作按钮 / Place an extra action button at the header trailing.',
      code: '''
ParkCard(
  titleText: '订单信息',
  extra: ParkButton(
    variant: ParkButtonVariant.text,
    size: ParkButtonSize.small,
    onPressed: () {},
    child: Text('查看'),
  ),
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('共 3 件商品，合计 ¥199.00'),
  ),
)''',
      builder: (BuildContext context) => ParkCard(
        titleText: '订单信息',
        extra: ParkButton(
          variant: ParkButtonVariant.text,
          size: ParkButtonSize.small,
          onPressed: () {},
          child: const Text('查看'),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('共 3 件商品，合计 ¥199.00'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '悬浮浮起',
      description: 'hoverable 卡片在鼠标悬浮时浮起 / hoverable lifts the card on hover.',
      code: '''
ParkCard(
  hoverable: true,
  titleText: '可悬浮卡片',
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('将鼠标移到卡片上查看浮起效果'),
  ),
)''',
      builder: (BuildContext context) => ParkCard(
        hoverable: true,
        titleText: '可悬浮卡片',
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('将鼠标移到卡片上查看浮起效果'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '可点击 onPressed',
      description:
          '点击卡片触发 onPressed 回调（StatefulBuilder 计数）/ Tapping fires onPressed (StatefulBuilder counter).',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    int count = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('点击次数：\$count'),
        SizedBox(height: _kSpacing.sm),
        ParkCard(
          hoverable: true,
          titleText: '可点击卡片',
          onPressed: () {
            count++;
            setState(() {});
          },
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text('点击我，标题栏会出现指针反馈'),
          ),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          int count = 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('点击次数：$count'),
              SizedBox(height: _kSpacing.sm),
              ParkCard(
                hoverable: true,
                titleText: '可点击卡片',
                onPressed: () {
                  count++;
                  setState(() {});
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('点击我，标题栏会出现指针反馈'),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '加载骨架屏',
      description:
          'loading: true 时显示骨架占位 / loading shows a skeleton placeholder.',
      code: '''
ParkCard(
  loading: true,
  titleText: '加载中',
  child: const Text('占位内容'),
)''',
      builder: (BuildContext context) =>
          ParkCard(loading: true, titleText: '加载中', child: const Text('占位内容')),
    ),
    ParkDemoScenario(
      title: '封面卡片',
      description: 'cover 在标题之上展示封面区域 / cover renders above the header.',
      code: '''
ParkCard(
  titleText: '封面卡片',
  cover: Container(
    height: 96,
    color: _kColors.brand,
    alignment: Alignment.center,
    child: Text('封面区域', style: TextStyle(color: _kColors.textOnBrand)),
  ),
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('封面下方的卡片内容'),
  ),
)''',
      builder: (BuildContext context) => ParkCard(
        titleText: '封面卡片',
        cover: Container(
          height: 96,
          color: _kColors.brand,
          alignment: Alignment.center,
          child: Text('封面区域', style: TextStyle(color: _kColors.textOnBrand)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('封面下方的卡片内容'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '可折叠卡片',
      description:
          'collapsible + ghost 变体，点击头部展开/收起 / collapsible ghost card toggles on header tap.',
      code: '''
ParkCard(
  collapsible: true,
  variant: ParkCardVariant.ghost,
  titleText: '可折叠区块',
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('点击标题栏可展开或收起这段内容'),
  ),
)''',
      builder: (BuildContext context) => ParkCard(
        collapsible: true,
        variant: ParkCardVariant.ghost,
        titleText: '可折叠区块',
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('点击标题栏可展开或收起这段内容'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '底部操作栏',
      description:
          'actions 渲染底部均匀分布的按钮操作区 / actions renders an even bottom action bar.',
      code: '''
ParkCard(
  titleText: '操作卡片',
  actions: <Widget>[
    ParkButton(
      variant: ParkButtonVariant.text,
      onPressed: () {},
      child: Text('确定'),
    ),
    ParkButton(
      variant: ParkButtonVariant.text,
      onPressed: () {},
      child: Text('取消'),
    ),
  ],
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Text('卡片内容，底部为操作栏'),
  ),
)''',
      builder: (BuildContext context) => ParkCard(
        titleText: '操作卡片',
        actions: <Widget>[
          ParkButton(
            variant: ParkButtonVariant.text,
            onPressed: () {},
            child: const Text('确定'),
          ),
          ParkButton(
            variant: ParkButtonVariant.text,
            onPressed: () {},
            child: const Text('取消'),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('卡片内容，底部为操作栏'),
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkGrid
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkGridSpec = ParkComponentSpec(
  name: 'ParkGrid',
  title: '宫格 / Grid',
  category: 'display',
  description:
      '网格布局组件，支持等分（equal）与自适应（auto）两种模式，可配置列数、间距、边框与分割线，'
      '每项可带图标 / 文字 / 角标，点击触发 onTap（参数为索引）。'
      ' / Grid layout with equal / auto modes, configurable columns, spacing, border and dividers; '
      'each item supports icon / label / badge and fires onTap(index).',
  icon: Icons.grid_view_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'columnCount',
      type: 'int',
      required: true,
      description: '列数（必须大于 0）/ Number of columns (must be > 0)',
    ),
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkGridItem>',
      required: true,
      description: '网格项列表 / Grid item list',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkGridMode',
      defaultVal: 'ParkGridMode.equal',
      description:
          '布局模式：equal（等分）/ auto（按 flex 自适应）/ Layout mode: equal / auto',
    ),
    ParkPropertyDef(
      name: 'onTap',
      type: 'ValueChanged<int>?',
      description: '点击某项的回调，参数为索引 / Tap callback, arg is item index',
    ),
    ParkPropertyDef(
      name: 'rowSpacing',
      type: 'double?',
      defaultVal: 'null',
      description: '行间距（null 时使用 spacing）/ Row spacing (falls back to spacing)',
    ),
    ParkPropertyDef(
      name: 'columnSpacing',
      type: 'double?',
      defaultVal: 'null',
      description:
          '列间距（null 时使用 spacing）/ Column spacing (falls back to spacing)',
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double?',
      defaultVal: 'null',
      description: '统一间距（同时设置行与列）/ Unified spacing for rows and columns',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示外边框 / Whether to show an outer border',
    ),
    ParkPropertyDef(
      name: 'divider',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示分割线 / Whether to show dividers',
    ),
    ParkPropertyDef(
      name: 'itemHeight',
      type: 'double?',
      defaultVal: 'null',
      description: '每个格子的高度（默认 56）/ Cell height (default 56)',
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null',
      description:
          '背景色（null 使用主题 surface）/ Background color (null = theme surface)',
    ),
    ParkPropertyDef(
      name: 'align',
      type: 'ParkGridAlign',
      defaultVal: 'ParkGridAlign.start',
      description:
          '格内子项垂直对齐：start / center / end / stretch / Cell vertical alignment',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'ValueChanged<int>?',
      description: '点击网格项的回调，参数为索引 / Tap callback for grid items, arg is index',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkGrid(
  columnCount: 4,
  items: [
    ParkGridItem(icon: Icons.home, label: '首页'),
    ParkGridItem(icon: Icons.person, label: '我的'),
  ],
)
''',
  guide: '''
## 何时使用 / When to use
- 功能入口宫格（如 首页九宫格、设置分类）/ Function-entry grids (home 9-grid, settings)
- 等宽或多列内容平铺 / Even or multi-column content tiling

## 使用建议 / Usage tips
- columnCount 根据内容密度调整（常用 3 / 4 / 5）/ Pick columnCount by density (3/4/5)
- auto 模式按每项 flex 分配宽度，适合不等宽场景 / auto mode shares width by flex
- 需要边框分隔时使用 bordered + divider / Use bordered + divider for separation
- 角标用 ParkGridItem.badge，禁用项用 disabled / Use badge for marks, disabled to gray out
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '等分宫格',
      description: '4 列等分宫格，每项带图标与文字 / 4-column equal grid with icon + label.',
      code: '''
ParkGrid(
  columnCount: 4,
  items: [
    ParkGridItem(icon: Icons.home, label: '首页'),
    ParkGridItem(icon: Icons.person, label: '我的'),
    ParkGridItem(icon: Icons.settings, label: '设置'),
    ParkGridItem(icon: Icons.star, label: '收藏'),
  ],
)''',
      builder: (BuildContext context) => ParkGrid(
        columnCount: 4,
        items: const <ParkGridItem>[
          ParkGridItem(icon: Icons.home, label: '首页'),
          ParkGridItem(icon: Icons.person, label: '我的'),
          ParkGridItem(icon: Icons.settings, label: '设置'),
          ParkGridItem(icon: Icons.star, label: '收藏'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带边框与分割线',
      description:
          'bordered + divider 的八宫格 / 8-cell grid with border + dividers.',
      code: '''
ParkGrid(
  columnCount: 4,
  bordered: true,
  divider: true,
  items: [
    ParkGridItem(icon: Icons.home, label: '首页'),
    ParkGridItem(icon: Icons.search, label: '搜索'),
    ParkGridItem(icon: Icons.favorite, label: '喜欢'),
    ParkGridItem(icon: Icons.share, label: '分享'),
    ParkGridItem(icon: Icons.message, label: '消息'),
    ParkGridItem(icon: Icons.camera, label: '相机'),
    ParkGridItem(icon: Icons.map, label: '地图'),
    ParkGridItem(icon: Icons.more_horiz, label: '更多'),
  ],
)''',
      builder: (BuildContext context) => ParkGrid(
        columnCount: 4,
        bordered: true,
        divider: true,
        items: const <ParkGridItem>[
          ParkGridItem(icon: Icons.home, label: '首页'),
          ParkGridItem(icon: Icons.search, label: '搜索'),
          ParkGridItem(icon: Icons.favorite, label: '喜欢'),
          ParkGridItem(icon: Icons.share, label: '分享'),
          ParkGridItem(icon: Icons.message, label: '消息'),
          ParkGridItem(icon: Icons.camera, label: '相机'),
          ParkGridItem(icon: Icons.map, label: '地图'),
          ParkGridItem(icon: Icons.more_horiz, label: '更多'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '点击 onTap',
      description:
          '点击宫格触发 onTap，回显所选索引（StatefulBuilder）/ Tapping fires onTap, echoes selected index.',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    int? selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(selected == null ? '未选择' : '已选择索引：\$selected'),
        SizedBox(height: _kSpacing.sm),
        ParkGrid(
          columnCount: 3,
          onTap: (i) {
            selected = i;
            setState(() {});
          },
          items: [
            ParkGridItem(icon: Icons.call, label: '通话'),
            ParkGridItem(icon: Icons.chat, label: '聊天'),
            ParkGridItem(icon: Icons.contacts, label: '通讯录'),
          ],
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          int? selected;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('已选择索引：${selected ?? "未选择"}'),
              SizedBox(height: _kSpacing.sm),
              ParkGrid(
                columnCount: 3,
                onTap: (int i) {
                  selected = i;
                  setState(() {});
                },
                items: const <ParkGridItem>[
                  ParkGridItem(icon: Icons.call, label: '通话'),
                  ParkGridItem(icon: Icons.chat, label: '聊天'),
                  ParkGridItem(icon: Icons.contacts, label: '通讯录'),
                ],
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '自适应 + flex',
      description: 'auto 模式按每项 flex 分配宽度 / auto mode shares width by flex.',
      code: '''
ParkGrid(
  mode: ParkGridMode.auto,
  columnCount: 3,
  items: [
    ParkGridItem(icon: Icons.star, label: '推荐', flex: 2),
    ParkGridItem(icon: Icons.history, label: '历史'),
    ParkGridItem(icon: Icons.bookmark, label: '收藏'),
  ],
)''',
      builder: (BuildContext context) => ParkGrid(
        mode: ParkGridMode.auto,
        columnCount: 3,
        items: const <ParkGridItem>[
          ParkGridItem(icon: Icons.star, label: '推荐', flex: 2),
          ParkGridItem(icon: Icons.history, label: '历史'),
          ParkGridItem(icon: Icons.bookmark, label: '收藏'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '角标与禁用',
      description:
          'badge 显示角标，disabled 置灰不可点 / badge shows a mark; disabled grays out.',
      code: '''
ParkGrid(
  columnCount: 4,
  items: [
    ParkGridItem(icon: Icons.email, label: '邮件', badge: '9'),
    ParkGridItem(icon: Icons.notifications, label: '通知', badge: '99+'),
    ParkGridItem(icon: Icons.cloud, label: '云盘'),
    ParkGridItem(icon: Icons.block, label: '已禁用', disabled: true),
  ],
)''',
      builder: (BuildContext context) => ParkGrid(
        columnCount: 4,
        items: const <ParkGridItem>[
          ParkGridItem(icon: Icons.email, label: '邮件', badge: '9'),
          ParkGridItem(icon: Icons.notifications, label: '通知', badge: '99+'),
          ParkGridItem(icon: Icons.cloud, label: '云盘'),
          ParkGridItem(icon: Icons.block, label: '已禁用', disabled: true),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '居中对齐',
      description:
          'align: center 让格内图标文字垂直居中 / align center vertically centers cell content.',
      code: '''
ParkGrid(
  align: ParkGridAlign.center,
  itemHeight: 72,
  columnCount: 3,
  items: [
    ParkGridItem(icon: Icons.thumb_up, label: '点赞'),
    ParkGridItem(icon: Icons.thumb_down, label: '踩'),
    ParkGridItem(icon: Icons.share, label: '分享'),
  ],
)''',
      builder: (BuildContext context) => ParkGrid(
        align: ParkGridAlign.center,
        itemHeight: 72,
        columnCount: 3,
        items: const <ParkGridItem>[
          ParkGridItem(icon: Icons.thumb_up, label: '点赞'),
          ParkGridItem(icon: Icons.thumb_down, label: '踩'),
          ParkGridItem(icon: Icons.share, label: '分享'),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkList
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkListSpec = ParkComponentSpec(
  name: 'ParkList',
  title: '列表 / List',
  category: 'display',
  description:
      '通用列表组件，支持泛型数据、自定义项构建器、分割线、头部 / 底部、空状态与加载更多，'
      '大数据量时可开启 itemExtent 虚拟化，滚动到底部触发 onLoadMore。'
      ' / Generic list with typed data, custom item builder, dividers, header / footer, '
      'empty state and load-more; virtualize with itemExtent and fire onLoadMore at bottom.',
  icon: Icons.list_alt_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<T>',
      required: true,
      description: '列表数据 / List data',
    ),
    ParkPropertyDef(
      name: 'itemBuilder',
      type: 'Widget Function(BuildContext, T, int)',
      required: true,
      description: '列表项构建器 / Item builder',
    ),
    ParkPropertyDef(
      name: 'divided',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示分割线 / Whether to show dividers',
    ),
    ParkPropertyDef(
      name: 'split',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示分割线（与 divided 等效）/ Divider toggle (same as divided)',
    ),
    ParkPropertyDef(
      name: 'padding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null',
      description: '列表内边距（null 为零）/ List padding (null = zero)',
    ),
    ParkPropertyDef(
      name: 'header',
      type: 'Widget?',
      defaultVal: 'null',
      description: '列表头部 Widget / List header widget',
    ),
    ParkPropertyDef(
      name: 'footer',
      type: 'Widget?',
      defaultVal: 'null',
      description: '列表底部 Widget / List footer widget',
    ),
    ParkPropertyDef(
      name: 'emptyWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '空状态 Widget（items 为空时显示）/ Empty-state widget (shown when items is empty)',
    ),
    ParkPropertyDef(
      name: 'itemExtent',
      type: 'double?',
      defaultVal: 'null',
      description: '固定行高（开启虚拟化）/ Fixed row height (enables virtualization)',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'false',
      description: '是否处于加载状态（显示骨架屏占位项）/ Show skeleton placeholders',
    ),
    ParkPropertyDef(
      name: 'loadingItemCount',
      type: 'int',
      defaultVal: '3',
      description:
          'loading 时骨架占位项数量 / Skeleton placeholder count while loading',
    ),
    ParkPropertyDef(
      name: 'loadMore',
      type: 'Widget?',
      defaultVal: 'null',
      description: '底部"加载更多"Widget 插槽 / Bottom "load more" widget slot',
    ),
    ParkPropertyDef(
      name: 'itemLayout',
      type: 'ParkListItemLayout',
      defaultVal: 'ParkListItemLayout.horizontal',
      description:
          '列表项布局方向：horizontal / vertical / Item layout: horizontal / vertical',
    ),
    ParkPropertyDef(
      name: 'onLoadMore',
      type: 'Future<void> Function()?',
      defaultVal: 'null',
      description:
          '上拉加载更多回调（滚动到底部触发）/ Load-more callback fired when scrolled to bottom',
    ),
    ParkPropertyDef(
      name: 'loadingMore',
      type: 'bool',
      defaultVal: 'false',
      description: '是否正在加载更多（显示底部指示器）/ Whether loading more (bottom indicator)',
    ),
    ParkPropertyDef(
      name: 'noMore',
      type: 'bool',
      defaultVal: 'false',
      description: '是否已无更多数据（显示"已加载全部"）/ No more data (shows "all loaded")',
    ),
    ParkPropertyDef(
      name: 'reverse',
      type: 'bool',
      defaultVal: 'false',
      description: '是否反向排列 / Whether to reverse the list',
    ),
    ParkPropertyDef(
      name: 'scrollDirection',
      type: 'Axis',
      defaultVal: 'Axis.vertical',
      description: '滚动方向 / Scroll direction',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onLoadMore',
      signature: 'Future<void> Function()?',
      description:
          '上拉加载更多回调，滚动到底部时触发 / Load-more callback fired at scroll bottom',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkList<String>(
  items: ['项目一', '项目二', '项目三'],
  itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
)
''',
  guide: '''
## 何时使用 / When to use
- 展示一组同构数据（消息、商品、设置项）/ Show homogeneous data (messages, goods, settings)
- 需要分割线 / 空状态 / 加载更多的列表 / Lists needing dividers / empty / load-more

## 使用建议 / Usage tips
- 用泛型约束数据类型，itemBuilder 负责渲染 / Type the data; itemBuilder renders it
- divided / split 控制是否显示分割线 / divided / split control dividers
- 数据量大且行高固定时设置 itemExtent 提升性能 / Set itemExtent for fixed rows at scale
- 结合 onLoadMore 实现无限滚动 / Pair with onLoadMore for infinite scroll
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础列表',
      description: '字符串列表配合 ListTile 渲染 / String list rendered with ListTile.',
      code: '''
ParkList<String>(
  items: ['项目一', '项目二', '项目三'],
  itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 200,
        child: ParkList<String>(
          items: const <String>['项目一', '项目二', '项目三', '项目四'],
          itemBuilder: (BuildContext ctx, String item, int i) =>
              ListTile(title: Text(item)),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '带分割线',
      description: 'divided: true 显示列表项分割线 / divided shows item dividers.',
      code: '''
ParkList<String>(
  divided: true,
  items: ['收件箱', '已发送', '草稿箱'],
  itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 200,
        child: ParkList<String>(
          divided: true,
          items: const <String>['收件箱', '已发送', '草稿箱', '垃圾箱'],
          itemBuilder: (BuildContext ctx, String item, int i) =>
              ListTile(title: Text(item)),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '加载更多 onLoadMore',
      description:
          '滚动或到底部触发 onLoadMore 追加数据（StatefulBuilder，最多 6 条）/ onLoadMore appends data (capped at 6).',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    final List<String> data = <String>['项目一', '项目二'];
    return SizedBox(
      height: 200,
      child: ParkList<String>(
        items: data,
        noMore: data.length >= 6,
        onLoadMore: () async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          data.add('项目\${data.length + 1}');
          setState(() {});
        },
        itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
      ),
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          final List<String> data = <String>['项目一', '项目二'];
          return SizedBox(
            height: 200,
            child: ParkList<String>(
              items: data,
              noMore: data.length >= 6,
              onLoadMore: () async {
                await Future<void>.delayed(const Duration(milliseconds: 300));
                data.add('项目${data.length + 1}');
                setState(() {});
              },
              itemBuilder: (BuildContext c, String item, int i) =>
                  ListTile(title: Text(item)),
            ),
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '加载骨架屏',
      description:
          'loading: true 显示骨架占位项 / loading shows skeleton placeholders.',
      code: '''
SizedBox(
  height: 200,
  child: ParkList<String>(
    loading: true,
    items: const <String>[],
    itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 200,
        child: ParkList<String>(
          loading: true,
          items: const <String>[],
          itemBuilder: (BuildContext ctx, String item, int i) =>
              ListTile(title: Text(item)),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '空状态',
      description: 'items 为空时显示 emptyWidget / Empty items show emptyWidget.',
      code: '''
SizedBox(
  height: 160,
  child: ParkList<String>(
    emptyWidget: Center(child: Text('暂无数据')),
    items: const <String>[],
    itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 160,
        child: ParkList<String>(
          emptyWidget: const Center(child: Text('暂无数据')),
          items: const <String>[],
          itemBuilder: (BuildContext ctx, String item, int i) =>
              ListTile(title: Text(item)),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '头部与底部',
      description:
          'header / footer 渲染列表头尾 / header / footer render at list ends.',
      code: '''
SizedBox(
  height: 220,
  child: ParkList<String>(
    header: Padding(
      padding: EdgeInsets.all(8),
      child: Text('列表头部'),
    ),
    footer: Padding(
      padding: EdgeInsets.all(8),
      child: Text('列表底部'),
    ),
    items: ['A', 'B', 'C'],
    itemBuilder: (ctx, item, i) => ListTile(title: Text(item)),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 220,
        child: ParkList<String>(
          header: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('列表头部'),
          ),
          footer: const Padding(
            padding: EdgeInsets.all(8),
            child: Text('列表底部'),
          ),
          items: const <String>['A', 'B', 'C', 'D'],
          itemBuilder: (BuildContext ctx, String item, int i) =>
              ListTile(title: Text(item)),
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkEllipsis
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkEllipsisSpec = ParkComponentSpec(
  name: 'ParkEllipsis',
  title: '文本省略 / Ellipsis',
  category: 'display',
  description:
      '长文本省略组件，超出指定行数自动截断并显示省略号，可选 tooltip 悬浮/长按展示全文、'
      '展开/收起切换（expandable）或自定义后缀（suffix）。无回调事件。'
      ' / Long-text ellipsis that truncates beyond maxLines with optional tooltip, '
      'expand/collapse (expandable) or custom suffix. No callbacks.',
  icon: Icons.short_text_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'text',
      type: 'String',
      required: true,
      description: '完整文本内容 / Full text content',
    ),
    ParkPropertyDef(
      name: 'maxLines',
      type: 'int',
      defaultVal: '1',
      description: '最大显示行数 / Maximum visible lines',
    ),
    ParkPropertyDef(
      name: 'style',
      type: 'TextStyle?',
      defaultVal: 'null',
      description: '文本样式（null 使用主题 body）/ Text style (null = theme body)',
    ),
    ParkPropertyDef(
      name: 'tooltip',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用 tooltip 显示完整文本 / Show tooltip with full text',
    ),
    ParkPropertyDef(
      name: 'tooltipText',
      type: 'String?',
      defaultVal: 'null',
      description:
          '自定义 tooltip 文字（默认使用 text）/ Custom tooltip text (defaults to text)',
    ),
    ParkPropertyDef(
      name: 'textAlign',
      type: 'TextAlign?',
      defaultVal: 'null',
      description: '文本对齐方式 / Text alignment',
    ),
    ParkPropertyDef(
      name: 'expandable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示"展开/收起"切换按钮 / Show expand/collapse toggle',
    ),
    ParkPropertyDef(
      name: 'suffix',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '省略文本后的后缀组件（如"阅读更多"链接）/ Widget after the text (e.g. "read more")',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkEllipsis(
  text: '这是一段很长的文本，超出两行后会被省略……',
  maxLines: 2,
)
''',
  guide: '''
## 何时使用 / When to use
- 列表项、卡片描述等空间受限的长文本 / Long text in space-constrained areas
- 需要截断但又希望用户能查看全文 / Truncated yet peekable text

## 使用建议 / Usage tips
- maxLines 控制截断行数，配合 tooltip 查看全文 / maxLines + tooltip to peek full text
- expandable 适合需要内联展开的场景 / expandable for inline expansion
- suffix 可放置"阅读更多"等交互链接 / suffix for "read more" links
- 容器内宽度决定何时触发省略，注意父级约束 / Parent width controls when ellipsis kicks in
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '单行省略',
      description:
          '默认 maxLines: 1，超出显示省略号 / Single line, ellipsis when overflow.',
      code: '''
SizedBox(
  width: 220,
  child: ParkEllipsis(
    text: '这是一段很长的文本内容，超出一行后会被自动截断并以省略号结尾。',
    maxLines: 1,
  ),
)''',
      builder: (BuildContext context) => const SizedBox(
        width: 220,
        child: ParkEllipsis(
          text: '这是一段很长的文本内容，超出一行后会被自动截断并以省略号结尾。',
          maxLines: 1,
        ),
      ),
    ),
    ParkDemoScenario(
      title: '多行省略',
      description: 'maxLines: 2 限制为两行 / Limit to two lines.',
      code: '''
SizedBox(
  width: 220,
  child: ParkEllipsis(
    text: '这是一段很长的文本内容，用于演示多行省略。当文本超过两行时会自动折叠，用户可以悬停查看完整内容。',
    maxLines: 2,
  ),
)''',
      builder: (BuildContext context) => const SizedBox(
        width: 220,
        child: ParkEllipsis(
          text: '这是一段很长的文本内容，用于演示多行省略。当文本超过两行时会自动折叠，用户可以悬停查看完整内容。',
          maxLines: 2,
        ),
      ),
    ),
    ParkDemoScenario(
      title: '展开/收起',
      description:
          'expandable: true 显示"展开/收起"按钮内联切换 / expandable toggles inline.',
      code: '''
SizedBox(
  width: 240,
  child: ParkEllipsis(
    expandable: true,
    maxLines: 2,
    text: '这是一段较长的文本内容，用于演示展开与收起。点击"展开"后可查看完整内容，'
        '再次点击"收起"恢复截断状态。适合在卡片或列表项内联展示长描述。',
  ),
)''',
      builder: (BuildContext context) => const SizedBox(
        width: 240,
        child: ParkEllipsis(
          expandable: true,
          maxLines: 2,
          text:
              '这是一段较长的文本内容，用于演示展开与收起。点击"展开"后可查看完整内容，'
              '再次点击"收起"恢复截断状态。适合在卡片或列表项内联展示长描述。',
        ),
      ),
    ),
    ParkDemoScenario(
      title: '自定义后缀',
      description:
          'suffix 在省略文本后放置"阅读更多"链接 / suffix places a "read more" link.',
      code: '''
SizedBox(
  width: 240,
  child: ParkEllipsis(
    maxLines: 1,
    suffix: Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text('阅读更多', style: TextStyle(color: _kColors.brand)),
    ),
    text: '这是一段很长的文本内容，超出一行后会被自动截断并显示省略号。',
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        width: 240,
        child: ParkEllipsis(
          maxLines: 1,
          suffix: Padding(
            padding: EdgeInsets.only(left: _kSpacing.xs),
            child: Text('阅读更多', style: TextStyle(color: _kColors.brand)),
          ),
          text: '这是一段很长的文本内容，超出一行后会被自动截断并显示省略号。',
        ),
      ),
    ),
    ParkDemoScenario(
      title: '自定义提示文字',
      description:
          'tooltipText 自定义悬浮提示内容 / tooltipText customizes the hover tip.',
      code: '''
SizedBox(
  width: 220,
  child: ParkEllipsis(
    tooltipText: '完整提示：这是自定义 tooltip 文本',
    text: '单行文本，悬浮查看自定义提示。',
    maxLines: 1,
  ),
)''',
      builder: (BuildContext context) => const SizedBox(
        width: 220,
        child: ParkEllipsis(
          tooltipText: '完整提示：这是自定义 tooltip 文本',
          text: '单行文本，悬浮查看自定义提示。',
          maxLines: 1,
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkTimeline
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTimelineSpec = ParkComponentSpec(
  name: 'ParkTimeline',
  title: '时间轴 / Timeline',
  category: 'display',
  description:
      '垂直时间轴组件，用于按时间顺序展示事件流，支持自定义节点图标 / 颜色、pending 加载态、'
      '左右交替布局与自定义节点。无回调事件。'
      ' / Vertical timeline for chronological event flows, with custom node icons / colors, '
      'pending state, left/right/alternate layout and custom dots. No callbacks.',
  icon: Icons.timeline_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkTimelineItem>',
      required: true,
      description: '时间轴项列表 / Timeline items',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkTimelineMode',
      defaultVal: 'ParkTimelineMode.right',
      description:
          '内容相对轴线的位置：left / right / alternate / Content side: left / right / alternate',
    ),
    ParkPropertyDef(
      name: 'pending',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在末尾显示加载指示器 / Show a pending loader at the end',
    ),
    ParkPropertyDef(
      name: 'pendingLabel',
      type: 'String',
      defaultVal: "'Loading...'",
      description: 'pending 时显示的文本 / Text shown with the pending indicator',
    ),
    ParkPropertyDef(
      name: 'reverse',
      type: 'bool',
      defaultVal: 'false',
      description: '是否倒序（第一项在底部）/ Reverse order (first item at bottom)',
    ),
    ParkPropertyDef(
      name: 'dotSize',
      type: 'double',
      defaultVal: '12.0',
      description: '节点圆点直径 / Dot diameter',
    ),
    ParkPropertyDef(
      name: 'lineWidth',
      type: 'double',
      defaultVal: '2.0',
      description: '连接线宽度 / Connecting line width',
    ),
    ParkPropertyDef(
      name: 'itemSpacing',
      type: 'double',
      defaultVal: '24.0',
      description: '相邻项垂直间距 / Vertical gap between items',
    ),
    ParkPropertyDef(
      name: 'animationDuration',
      type: 'Duration',
      defaultVal: '400ms',
      description: '每项淡入动画时长 / Per-item fade-in duration',
    ),
    ParkPropertyDef(
      name: 'animationDelay',
      type: 'Duration',
      defaultVal: '80ms',
      description: '相邻项动画间隔 / Delay between successive item animations',
    ),
    ParkPropertyDef(
      name: 'labelPlacement',
      type: 'ParkTimelineLabelPlacement',
      defaultVal: 'ParkTimelineLabelPlacement.sameSide',
      description:
          '时间标签相对节点的位置：sameSide / opposite / Label placement: sameSide / opposite',
    ),
    ParkPropertyDef(
      name: 'pendingDot',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义 pending 节点 Widget / Custom pending dot widget',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkTimeline(
  items: [
    ParkTimelineItem(title: '已下单', description: '订单创建成功'),
    ParkTimelineItem(title: '运输中', description: '包裹已发出'),
    ParkTimelineItem(title: '已签收', description: '完成配送'),
  ],
)
''',
  guide: '''
## 何时使用 / When to use
- 订单流转、审批流程、活动记录等步骤展示 / Order flow, approval, activity log
- 需要强调时间顺序的信息流 / Time-ordered information streams

## 使用建议 / Usage tips
- 用 title / description / time 组织每项信息 / Use title / description / time per item
- 通过 icon 与 color 突出关键节点 / Highlight nodes with icon and color
- 异步加载更多时开启 pending 显示加载态 / Enable pending for async loading
- ParkTimelineItem 支持 dotWidget 完全自定义节点 / dotWidget fully customizes a node
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础时间轴',
      description: '右侧内容布局的订单流转时间轴 / Right-aligned order timeline.',
      code: '''
ParkTimeline(
  items: [
    ParkTimelineItem(title: '已下单', description: '订单创建成功'),
    ParkTimelineItem(title: '运输中', description: '包裹已发出'),
    ParkTimelineItem(title: '已签收', description: '完成配送'),
  ],
)''',
      builder: (BuildContext context) => ParkTimeline(
        items: <ParkTimelineItem>[
          ParkTimelineItem(title: '已下单', description: '订单创建成功'),
          ParkTimelineItem(title: '运输中', description: '包裹已发出'),
          ParkTimelineItem(title: '已签收', description: '完成配送'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '带图标节点',
      description: '为节点配置 icon 与自定义颜色（使用设计令牌）/ icon + token colors per node.',
      code: '''
ParkTimeline(
  items: [
    ParkTimelineItem(title: '提交', icon: Icons.edit, color: _kColors.brand),
    ParkTimelineItem(title: '审核', icon: Icons.verified, color: _kColors.success),
    ParkTimelineItem(title: '发布', icon: Icons.publish, color: _kColors.warning),
  ],
)''',
      builder: (BuildContext context) => ParkTimeline(
        items: <ParkTimelineItem>[
          ParkTimelineItem(
            title: '提交',
            icon: Icons.edit,
            color: _kColors.brand,
          ),
          ParkTimelineItem(
            title: '审核',
            icon: Icons.verified,
            color: _kColors.success,
          ),
          ParkTimelineItem(
            title: '发布',
            icon: Icons.publish,
            color: _kColors.warning,
          ),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '加载态',
      description:
          'pending: true 在末尾显示加载指示器 / pending shows a loader at the end.',
      code: '''
ParkTimeline(
  pending: true,
  pendingLabel: '加载更多记录…',
  items: [
    ParkTimelineItem(title: '第一步', description: '已完成'),
    ParkTimelineItem(title: '第二步', description: '进行中'),
  ],
)''',
      builder: (BuildContext context) => ParkTimeline(
        pending: true,
        pendingLabel: '加载更多记录…',
        items: <ParkTimelineItem>[
          ParkTimelineItem(title: '第一步', description: '已完成'),
          ParkTimelineItem(title: '第二步', description: '进行中'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '交替布局',
      description:
          'mode: alternate 在宽屏左右交替排布 / alternate layout on wide screens.',
      code: '''
ParkTimeline(
  mode: ParkTimelineMode.alternate,
  items: [
    ParkTimelineItem(title: '设计', description: 'UI 稿评审'),
    ParkTimelineItem(title: '开发', description: '功能实现'),
    ParkTimelineItem(title: '测试', description: '回归验证'),
    ParkTimelineItem(title: '上线', description: '发布生产'),
  ],
)''',
      builder: (BuildContext context) => ParkTimeline(
        mode: ParkTimelineMode.alternate,
        items: <ParkTimelineItem>[
          ParkTimelineItem(title: '设计', description: 'UI 稿评审'),
          ParkTimelineItem(title: '开发', description: '功能实现'),
          ParkTimelineItem(title: '测试', description: '回归验证'),
          ParkTimelineItem(title: '上线', description: '发布生产'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '倒序排列',
      description:
          'reverse: true 让第一项显示在底部 / reverse puts the first item at the bottom.',
      code: '''
ParkTimeline(
  reverse: true,
  items: [
    ParkTimelineItem(title: '最新动态', time: '10:30', description: '刚刚更新'),
    ParkTimelineItem(title: '稍早', time: '09:00', description: '上午记录'),
    ParkTimelineItem(title: '最早', time: '08:00', description: '开始'),
  ],
)''',
      builder: (BuildContext context) => ParkTimeline(
        reverse: true,
        items: <ParkTimelineItem>[
          ParkTimelineItem(title: '最新动态', time: '10:30', description: '刚刚更新'),
          ParkTimelineItem(title: '稍早', time: '09:00', description: '上午记录'),
          ParkTimelineItem(title: '最早', time: '08:00', description: '开始'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义节点',
      description:
          'dotWidget 替换默认圆点为自定义 Widget / dotWidget replaces the default dot.',
      code: '''
ParkTimeline(
  items: [
    ParkTimelineItem(
      title: '里程碑',
      description: '自定义节点图标',
      dotWidget: Icon(Icons.flag, color: _kColors.textOnBrand),
    ),
    ParkTimelineItem(title: '进行中', description: '常规节点'),
  ],
)''',
      builder: (BuildContext context) => ParkTimeline(
        items: <ParkTimelineItem>[
          ParkTimelineItem(
            title: '里程碑',
            description: '自定义节点图标',
            dotWidget: Icon(Icons.flag, color: _kColors.textOnBrand),
          ),
          ParkTimelineItem(title: '进行中', description: '常规节点'),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkTooltip
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTooltipSpec = ParkComponentSpec(
  name: 'ParkTooltip',
  title: '文字提示 / Tooltip',
  category: 'display',
  description:
      '轻量文字提示气泡，支持 hover / tap 触发，可配置 8 方位、箭头、延时、最大宽度与颜色，'
      '并提供显隐状态变化回调 onOpenChange。'
      ' / Lightweight tooltip bubble with hover / tap triggers, 8 placements, arrow, delay, '
      'max width and color, plus onOpenChange callback.',
  icon: Icons.chat_bubble_outline_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '触发提示的子组件 / Child that triggers the tooltip',
    ),
    ParkPropertyDef(
      name: 'message',
      type: 'String?',
      description:
          '提示文字内容（与 richMessage 二选一）/ Plain text (mutually exclusive with richMessage)',
    ),
    ParkPropertyDef(
      name: 'richMessage',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '富文本提示内容（优先级高于 message）/ Rich widget content (higher priority)',
    ),
    ParkPropertyDef(
      name: 'placement',
      type: 'ParkTooltipPlacement',
      defaultVal: 'ParkTooltipPlacement.top',
      description:
          '提示出现方位（top/bottom/left/right 及组合）/ Placement (top/bottom/left/right + combos)',
    ),
    ParkPropertyDef(
      name: 'trigger',
      type: 'ParkTooltipTrigger',
      defaultVal: 'ParkTooltipTrigger.hover',
      description: '触发方式：hover / tap / Trigger: hover / tap',
    ),
    ParkPropertyDef(
      name: 'arrow',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示箭头 / Whether to show the arrow',
    ),
    ParkPropertyDef(
      name: 'visible',
      type: 'bool?',
      defaultVal: 'null',
      description:
          '受控显隐（非 null 时忽略指针事件）/ Controlled visibility (ignores pointer when set)',
    ),
    ParkPropertyDef(
      name: 'onOpenChange',
      type: 'ValueChanged<bool>?',
      description: '提示显隐状态变化回调 / Visibility change callback',
    ),
    ParkPropertyDef(
      name: 'delay',
      type: 'Duration',
      defaultVal: '100ms',
      description: '出现前的延时（hover 触发）/ Delay before showing (hover)',
    ),
    ParkPropertyDef(
      name: 'duration',
      type: 'Duration?',
      defaultVal: 'null',
      description: '自动隐藏时长（null 不自动隐藏）/ Auto-hide duration (null = sticky)',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null',
      description: '提示背景色（默认深色）/ Bubble background (default dark)',
    ),
    ParkPropertyDef(
      name: 'textColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '提示文字颜色（默认白色）/ Bubble text color (default white)',
    ),
    ParkPropertyDef(
      name: 'maxWidth',
      type: 'double',
      defaultVal: '250.0',
      description: '提示最大宽度 / Maximum bubble width',
    ),
    ParkPropertyDef(
      name: 'padding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null',
      description: '气泡内边距 / Bubble inner padding',
    ),
    ParkPropertyDef(
      name: 'borderRadius',
      type: 'BorderRadius?',
      defaultVal: 'null',
      description: '气泡圆角 / Bubble corner radius',
    ),
    ParkPropertyDef(
      name: 'gap',
      type: 'double',
      defaultVal: '4.0',
      description: '子组件与气泡之间的间距 / Gap between child and bubble',
    ),
    ParkPropertyDef(
      name: 'mouseEnterDelay',
      type: 'Duration',
      defaultVal: 'Duration.zero',
      description: '鼠标进入后的出现延时 / Delay after mouse enter',
    ),
    ParkPropertyDef(
      name: 'mouseLeaveDelay',
      type: 'Duration',
      defaultVal: '100ms',
      description: '鼠标离开后的隐藏延时 / Delay after mouse leave',
    ),
    ParkPropertyDef(
      name: 'destroyTooltipOnHide',
      type: 'bool',
      defaultVal: 'false',
      description: '隐藏时是否销毁气泡以节省内存 / Destroy overlay on hide (saves memory)',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onOpenChange',
      signature: 'ValueChanged<bool>?',
      description: '提示显隐状态变化回调 / Visibility change callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkTooltip(
  message: '提示文字',
  child: ParkText('悬停查看提示'),
)
''',
  guide: '''
## 何时使用 / When to use
- 为图标、按钮等提供补充说明 / Add context to icons / buttons
- 解释性文字不便常驻展示时 / Explanatory text that shouldn't always show

## 使用建议 / Usage tips
- 优先 hover 触发，移动端可用 tap / Prefer hover; use tap on mobile
- 控制 maxWidth 避免提示过长 / Cap maxWidth to avoid over-long tips
- 提示内容应简洁，必要时用 richMessage 富文本 / Keep concise; use richMessage when needed
- open + onOpenChange 可实现受控提示 / open + onOpenChange for controlled tips
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础提示',
      description: 'hover 触发、顶部出现的文字提示 / Hover-triggered top tooltip.',
      code: '''
ParkTooltip(
  message: '提示文字',
  child: ParkText('悬停查看提示'),
)''',
      builder: (BuildContext context) =>
          ParkTooltip(message: '提示文字', child: const ParkText('悬停查看提示')),
    ),
    ParkDemoScenario(
      title: '图标提示',
      description: '为图标按钮添加底部提示 / Bottom tooltip on an icon.',
      code: '''
ParkTooltip(
  message: '设置',
  placement: ParkTooltipPlacement.bottom,
  child: Icon(Icons.settings),
)''',
      builder: (BuildContext context) => ParkTooltip(
        message: '设置',
        placement: ParkTooltipPlacement.bottom,
        child: const Icon(Icons.settings),
      ),
    ),
    ParkDemoScenario(
      title: '显隐回调',
      description:
          'onOpenChange 回显当前显隐状态（StatefulBuilder）/ onOpenChange echoes visibility.',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool visible = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('提示可见：\${visible ? "是" : "否"}'),
        SizedBox(height: _kSpacing.sm),
        ParkTooltip(
          message: '悬停或点击查看',
          onOpenChange: (v) {
            visible = v;
            setState(() {});
          },
          child: const Icon(Icons.info),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool visible = false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('提示可见：$visible'),
              SizedBox(height: _kSpacing.sm),
              ParkTooltip(
                message: '悬停或点击查看',
                onOpenChange: (bool v) {
                  visible = v;
                  setState(() {});
                },
                child: const Icon(Icons.info),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '点击触发',
      description: 'trigger: tap 适合移动端 / tap trigger suits mobile.',
      code: '''
ParkTooltip(
  message: '点击触发显示',
  trigger: ParkTooltipTrigger.tap,
  child: const Icon(Icons.touch_app),
)''',
      builder: (BuildContext context) => ParkTooltip(
        message: '点击触发显示',
        trigger: ParkTooltipTrigger.tap,
        child: const Icon(Icons.touch_app),
      ),
    ),
    ParkDemoScenario(
      title: '富文本提示',
      description:
          'richMessage 支持多行/多组件内容 / richMessage supports multi-line content.',
      code: '''
ParkTooltip(
  richMessage: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('富文本标题', style: TextStyle(fontWeight: _kTypography.weightBold)),
      Text('可放置多行说明文字'),
    ],
  ),
  child: const Icon(Icons.menu_book),
)''',
      builder: (BuildContext context) => ParkTooltip(
        richMessage: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '富文本标题',
              style: TextStyle(fontWeight: _kTypography.weightBold),
            ),
            Text('可放置多行说明文字'),
          ],
        ),
        child: const Icon(Icons.menu_book),
      ),
    ),
    ParkDemoScenario(
      title: '受控显隐',
      description: 'visible + 按钮控制提示显隐 / visible + button controls the tip.',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool visible = false;
    return Column(
      children: <Widget>[
        ParkButton(
          onPressed: () {
            visible = !visible;
            setState(() {});
          },
          child: const Text('切换提示显隐'),
        ),
        SizedBox(height: _kSpacing.sm),
        ParkTooltip(
          message: '受控显示的提示',
          open: visible,
          child: const Icon(Icons.help),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool visible = false;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkButton(
                onPressed: () {
                  visible = !visible;
                  setState(() {});
                },
                child: const Text('切换提示显隐'),
              ),
              SizedBox(height: _kSpacing.sm),
              ParkTooltip(
                message: '受控显示的提示',
                open: visible,
                child: const Icon(Icons.help),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '自定义颜色',
      description:
          'color / textColor 自定义气泡配色 / color / textColor customize the bubble.',
      code: '''
ParkTooltip(
  message: '品牌色提示',
  color: _kColors.brand,
  textColor: _kColors.textOnBrand,
  child: ParkText('悬停'),
)''',
      builder: (BuildContext context) => ParkTooltip(
        message: '品牌色提示',
        color: _kColors.brand,
        textColor: _kColors.textOnBrand,
        child: const ParkText('悬停'),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkSticky
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkStickySpec = ParkComponentSpec(
  name: 'ParkSticky',
  title: '吸顶 / Sticky',
  category: 'display',
  description:
      '粘性定位组件，滚动到阈值后子组件吸顶固定，可配置吸顶偏移、阴影与背景色，'
      '并提供吸顶状态变化回调 onStickyChanged / onChange。'
      ' / Sticky component that pins its child after scrolling past a threshold, with offset, '
      'shadow and background, firing onStickyChanged / onChange.',
  icon: Icons.vertical_align_top_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '需要吸顶的子组件 / Child to pin',
    ),
    ParkPropertyDef(
      name: 'stickyOffset',
      type: 'double',
      defaultVal: '0',
      description: '吸顶时距离顶部的偏移量（像素）/ Top offset while sticky (px)',
    ),
    ParkPropertyDef(
      name: 'offset',
      type: 'double',
      defaultVal: '0',
      description: '等同于 stickyOffset 的别名 / Alias of stickyOffset',
    ),
    ParkPropertyDef(
      name: 'showShadow',
      type: 'bool',
      defaultVal: 'true',
      description: '吸顶时是否显示阴影 / Show shadow while sticky',
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null',
      description:
          '吸顶时的背景色（null 使用主题 surface）/ Background while sticky (null = surface)',
    ),
    ParkPropertyDef(
      name: 'onStickyChanged',
      type: 'ValueChanged<bool>?',
      description: '吸顶状态变化回调 / Sticky state change callback',
    ),
    ParkPropertyDef(
      name: 'onChange',
      type: 'ValueChanged<bool>?',
      description: '吸顶状态变化回调（等同于 onStickyChanged）/ Alias of onStickyChanged',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onStickyChanged',
      signature: 'ValueChanged<bool>?',
      description: '吸顶状态变化回调 / Sticky state change callback',
    ),
    ParkEventDef(
      name: 'onChange',
      signature: 'ValueChanged<bool>?',
      description: '吸顶状态变化回调（等同于 onStickyChanged）/ Alias of onStickyChanged',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSticky(
  child: Container(
    height: 48,
    color: _kColors.brand,
    child: Center(child: Text('吸顶内容', style: TextStyle(color: _kColors.textOnBrand))),
  ),
)
''',
  guide: '''
## 何时使用 / When to use
- 列表 / 长页面的标题栏、操作栏吸顶 / Pin headers / action bars on long pages
- 需要常驻可见的筛选 / 操作区域 / Keep filters / actions always visible

## 使用建议 / Usage tips
- 需要位于可滚动容器中才会生效 / Only works inside a scrollable container
- 通过 stickyOffset 避开顶部固定栏（如 AppBar）/ Use stickyOffset to clear a fixed AppBar
- 吸顶后可用 backgroundColor / showShadow 突出层级 / Use backgroundColor / showShadow when sticky
- onStickyChanged / onChange 可联动其他 UI / Sync other UI via onStickyChanged / onChange
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '吸顶内容',
      description:
          '滚动时该区域会吸顶固定（需在滚动容器内）/ Pins while scrolling (needs a scroll container).',
      code: '''
SizedBox(
  height: 200,
  child: SingleChildScrollView(
    child: Column(
      children: <Widget>[
        ParkSticky(
          child: Container(
            height: 48,
            color: _kColors.brand,
            child: Center(
              child: Text('吸顶内容', style: TextStyle(color: _kColors.textOnBrand)),
            ),
          ),
        ),
        SizedBox(height: 400, child: Center(child: Text('向下滚动查看吸顶效果'))),
      ],
    ),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ParkSticky(
                child: Container(
                  height: 48,
                  color: _kColors.brand,
                  child: Center(
                    child: Text(
                      '吸顶内容',
                      style: TextStyle(color: _kColors.textOnBrand),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 400,
                child: Center(child: Text('向下滚动查看吸顶效果')),
              ),
            ],
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '吸顶状态回调',
      description:
          'onStickyChanged 回显当前吸顶状态（StatefulBuilder，需滚动）/ onStickyChanged echoes state (scroll to see).',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool stuck = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('吸顶状态：\${stuck ? "已吸顶" : "未吸顶"}'),
        SizedBox(height: _kSpacing.sm),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ParkSticky(
                  onStickyChanged: (v) {
                    stuck = v;
                    setState(() {});
                  },
                  child: Container(
                    height: 48,
                    color: _kColors.brand,
                    child: Center(
                      child: Text('吸顶标题', style: TextStyle(color: _kColors.textOnBrand)),
                    ),
                  ),
                ),
                SizedBox(height: 400, child: Center(child: Text('滚动以触发吸顶'))),
              ],
            ),
          ),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool stuck = false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('吸顶状态：$stuck'),
              SizedBox(height: _kSpacing.sm),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ParkSticky(
                        onStickyChanged: (bool v) {
                          stuck = v;
                          setState(() {});
                        },
                        child: Container(
                          height: 48,
                          color: _kColors.brand,
                          child: Center(
                            child: Text(
                              '吸顶标题',
                              style: TextStyle(color: _kColors.textOnBrand),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 400,
                        child: Center(child: Text('滚动以触发吸顶')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '吸顶偏移与样式',
      description:
          'stickyOffset 控制吸顶后距顶偏移，backgroundColor 与 showShadow 自定义外观（按钮切换偏移演示）/ stickyOffset + backgroundColor + showShadow (toggle offset).',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    double offset = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkButton(
          onPressed: () {
            offset = offset == 0 ? 24 : 0;
            setState(() {});
          },
          child: Text('切换吸顶偏移（当前 \${offset.toStringAsFixed(0)}）'),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ParkSticky(
                  stickyOffset: offset,
                  backgroundColor: _kColors.surface,
                  showShadow: true,
                  child: Container(
                    height: 48,
                    color: _kColors.brand,
                    child: Center(
                      child: Text('吸顶标题', style: TextStyle(color: _kColors.textOnBrand)),
                    ),
                  ),
                ),
                SizedBox(height: 400, child: Center(child: Text('滚动查看偏移效果'))),
              ],
            ),
          ),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          double offset = 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkButton(
                onPressed: () {
                  offset = offset == 0 ? 24 : 0;
                  setState(() {});
                },
                child: Text('切换吸顶偏移（当前 ${offset.toStringAsFixed(0)}）'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ParkSticky(
                        stickyOffset: offset,
                        backgroundColor: _kColors.surface,
                        showShadow: true,
                        child: Container(
                          height: 48,
                          color: _kColors.brand,
                          child: Center(
                            child: Text(
                              '吸顶标题',
                              style: TextStyle(color: _kColors.textOnBrand),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 400,
                        child: Center(child: Text('滚动查看偏移效果')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '综合变更回调 onChange',
      description:
          'onChange 与 onStickyChanged 等效，回显吸顶状态（StatefulBuilder，需滚动）/ onChange mirrors onStickyChanged (scroll to see).',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    bool stuck = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('吸顶状态：\${stuck ? "已吸顶" : "未吸顶"}'),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ParkSticky(
                  onChange: (v) {
                    stuck = v;
                    setState(() {});
                  },
                  child: Container(
                    height: 48,
                    color: _kColors.brand,
                    child: Center(
                      child: Text('吸顶标题', style: TextStyle(color: _kColors.textOnBrand)),
                    ),
                  ),
                ),
                SizedBox(height: 400, child: Center(child: Text('滚动以触发吸顶'))),
              ],
            ),
          ),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool stuck = false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('吸顶状态：$stuck'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ParkSticky(
                        onStickyChanged: (bool v) {
                          stuck = v;
                          setState(() {});
                        },
                        child: Container(
                          height: 48,
                          color: _kColors.brand,
                          child: Center(
                            child: Text(
                              '吸顶标题',
                              style: TextStyle(color: _kColors.textOnBrand),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 400,
                        child: Center(child: Text('滚动以触发吸顶')),
                      ),
                    ],
                  ),
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
// ParkDescriptions
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDescriptionsSpec = ParkComponentSpec(
  name: 'ParkDescriptions',
  title: '描述列表 / Descriptions',
  category: 'display',
  description:
      '只读详情页数据展示组件，支持表格风格（bordered）与简洁分隔线风格两种模式，'
      '可配置列数、标题、label 宽度、空值占位符与标题栏右侧操作，支持 span 跨列与自定义值 Widget。无回调事件。'
      ' / Read-only detail data display with bordered (table) and borderless styles, configurable '
      'columns, title, label width, empty placeholder and header action; span and custom value widget. No callbacks.',
  icon: Icons.view_list_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      description:
          '标题（可选）。设置后显示顶部标题栏 / Optional title; shows a header bar when set',
    ),
    ParkPropertyDef(
      name: 'column',
      type: 'int',
      defaultVal: '2',
      description: '列数（1/2/3），控制每行显示的 label-value 对数 / Columns (1/2/3)',
    ),
    ParkPropertyDef(
      name: 'bordered',
      type: 'bool',
      defaultVal: 'true',
      description:
          '是否显示边框。true=表格风格 label 灰底，false=简洁分隔线风格 / Bordered table vs borderless',
    ),
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkDescriptionItem>',
      required: true,
      description:
          '数据项列表（每项含 label / value / valueWidget / span）/ Data items (label / value / valueWidget / span)',
    ),
    ParkPropertyDef(
      name: 'labelWidth',
      type: 'double?',
      defaultVal: 'null',
      description: 'label 固定宽度。null=使用默认宽度 100 / Label width (null = 100)',
    ),
    ParkPropertyDef(
      name: 'emptyText',
      type: 'String',
      defaultVal: '—',
      description: '空值占位符文本 / Placeholder for empty values',
    ),
    ParkPropertyDef(
      name: 'action',
      type: 'Widget?',
      defaultVal: 'null',
      description:
          '标题栏右侧操作 Widget（如编辑按钮）/ Header trailing action (e.g. edit button)',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkDescriptions(
  title: '订单详情',
  column: 2,
  bordered: true,
  items: [
    ParkDescriptionItem(label: '订单号', value: 'DD20260701001'),
    ParkDescriptionItem(label: '状态', value: '已支付'),
    ParkDescriptionItem(label: '收货地址', value: '北京市朝阳区', span: 2),
  ],
)
''',
  guide: '''
## 何时使用 / When to use
- 详情页只读数据展示（订单详情、用户信息、合同信息）/ Read-only detail pages
- 需要以表格或分隔线形式展示 label-value 对 / label-value pairs in table / divider form

## 使用建议 / Usage tips
- bordered=true 适合结构化数据表格展示 / bordered suits structured tables
- bordered=false 适合更轻量的信息展示 / borderless for lighter info
- 使用 span 让长内容跨列显示 / span lets long content cross columns
- labelWidth 控制标签列宽度，保证多行对齐 / labelWidth aligns label columns
- emptyText 自定义空值占位符 / Customize empty placeholder via emptyText
- valueWidget 渲染自定义值（如标签、头像）/ valueWidget renders custom values
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '表格风格',
      description: 'bordered 2列，订单详情 / Bordered 2-column order details.',
      code: '''
ParkDescriptions(
  title: '订单详情',
  column: 2,
  bordered: true,
  items: [
    ParkDescriptionItem(label: '订单号', value: 'DD20260701001'),
    ParkDescriptionItem(label: '下单时间', value: '2026-07-01 09:30'),
    ParkDescriptionItem(label: '支付方式', value: '微信支付'),
    ParkDescriptionItem(label: '订单状态', value: '已支付'),
    ParkDescriptionItem(label: '收货地址', value: '北京市朝阳区建国路 88 号', span: 2),
  ],
)''',
      builder: (BuildContext context) => ParkDescriptions(
        title: '订单详情',
        column: 2,
        bordered: true,
        items: <ParkDescriptionItem>[
          ParkDescriptionItem(label: '订单号', value: 'DD20260701001'),
          ParkDescriptionItem(label: '下单时间', value: '2026-07-01 09:30'),
          ParkDescriptionItem(label: '支付方式', value: '微信支付'),
          ParkDescriptionItem(label: '订单状态', value: '已支付'),
          ParkDescriptionItem(label: '收货地址', value: '北京市朝阳区建国路 88 号', span: 2),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '分隔线风格',
      description: 'borderless 2列，用户信息 / Borderless 2-column user info.',
      code: '''
ParkDescriptions(
  title: '用户信息',
  column: 2,
  bordered: false,
  items: [
    ParkDescriptionItem(label: '姓名', value: '张三'),
    ParkDescriptionItem(label: '手机号', value: '138****8888'),
    ParkDescriptionItem(label: '邮箱', value: 'zhangsan@example.com'),
    ParkDescriptionItem(label: '部门', value: '技术部'),
  ],
)''',
      builder: (BuildContext context) => ParkDescriptions(
        title: '用户信息',
        column: 2,
        bordered: false,
        items: <ParkDescriptionItem>[
          ParkDescriptionItem(label: '姓名', value: '张三'),
          ParkDescriptionItem(label: '手机号', value: '138****8888'),
          ParkDescriptionItem(label: '邮箱', value: 'zhangsan@example.com'),
          ParkDescriptionItem(label: '部门', value: '技术部'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '单列 + span 跨行',
      description: 'column=1 配合 span 展示合同信息 / single column with span.',
      code: '''
ParkDescriptions(
  title: '合同信息',
  column: 1,
  bordered: true,
  items: [
    ParkDescriptionItem(label: '合同编号', value: 'HT-2026-007'),
    ParkDescriptionItem(label: '甲方', value: '北京科技有限公司'),
    ParkDescriptionItem(label: '乙方', value: '上海设计工作室'),
    ParkDescriptionItem(label: '合同金额', value: '¥128,000.00'),
    ParkDescriptionItem(
      label: '备注',
      value: '本合同自双方签字盖章之日起生效，有效期一年。',
    ),
  ],
)''',
      builder: (BuildContext context) => ParkDescriptions(
        title: '合同信息',
        column: 1,
        bordered: true,
        items: <ParkDescriptionItem>[
          ParkDescriptionItem(label: '合同编号', value: 'HT-2026-007'),
          ParkDescriptionItem(label: '甲方', value: '北京科技有限公司'),
          ParkDescriptionItem(label: '乙方', value: '上海设计工作室'),
          ParkDescriptionItem(label: '合同金额', value: '¥128,000.00'),
          ParkDescriptionItem(label: '备注', value: '本合同自双方签字盖章之日起生效，有效期一年。'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '标题栏操作',
      description:
          'action 在标题栏右侧放置编辑按钮 / action puts an edit button at the header.',
      code: '''
ParkDescriptions(
  title: '账户信息',
  column: 2,
  bordered: true,
  action: ParkButton(
    variant: ParkButtonVariant.text,
    size: ParkButtonSize.small,
    onPressed: () {},
    child: Text('编辑'),
  ),
  items: [
    ParkDescriptionItem(label: '昵称', value: 'ParkUser'),
    ParkDescriptionItem(label: '等级', value: 'VIP3'),
  ],
)''',
      builder: (BuildContext context) => ParkDescriptions(
        title: '账户信息',
        column: 2,
        bordered: true,
        action: ParkButton(
          variant: ParkButtonVariant.text,
          size: ParkButtonSize.small,
          onPressed: () {},
          child: const Text('编辑'),
        ),
        items: <ParkDescriptionItem>[
          ParkDescriptionItem(label: '昵称', value: 'ParkUser'),
          ParkDescriptionItem(label: '等级', value: 'VIP3'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '自定义值 Widget',
      description:
          'valueWidget 渲染标签等自定义值 / valueWidget renders custom values like tags.',
      code: '''
ParkDescriptions(
  title: '商品标签',
  column: 2,
  bordered: true,
  items: [
    ParkDescriptionItem(label: '名称', value: '机械键盘'),
    ParkDescriptionItem(
      label: '标签',
      valueWidget: Wrap(
        spacing: 6,
        children: <Widget>[
          Chip(label: Text('热销')),
          Chip(label: Text('包邮')),
        ],
      ),
    ),
    ParkDescriptionItem(label: '库存', value: '128 件'),
  ],
)''',
      builder: (BuildContext context) => ParkDescriptions(
        title: '商品标签',
        column: 2,
        bordered: true,
        items: <ParkDescriptionItem>[
          ParkDescriptionItem(label: '名称', value: '机械键盘'),
          ParkDescriptionItem(
            label: '标签',
            valueWidget: Wrap(
              spacing: 6,
              children: <Widget>[
                Chip(label: Text('热销')),
                Chip(label: Text('包邮')),
              ],
            ),
          ),
          ParkDescriptionItem(label: '库存', value: '128 件'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '空值占位',
      description:
          '空值使用 emptyText 占位符显示 / Empty values show the emptyText placeholder.',
      code: '''
ParkDescriptions(
  title: '资料 completeness',
  column: 2,
  bordered: false,
  emptyText: '待补充',
  items: [
    ParkDescriptionItem(label: '手机号', value: '138****8888'),
    ParkDescriptionItem(label: '邮箱', value: ''),
    ParkDescriptionItem(label: '公司', value: null),
    ParkDescriptionItem(label: '职位', value: '工程师'),
  ],
)''',
      builder: (BuildContext context) => ParkDescriptions(
        title: '资料 completeness',
        column: 2,
        bordered: false,
        emptyText: '待补充',
        items: <ParkDescriptionItem>[
          ParkDescriptionItem(label: '手机号', value: '138****8888'),
          ParkDescriptionItem(label: '邮箱', value: ''),
          ParkDescriptionItem(label: '公司', value: null),
          ParkDescriptionItem(label: '职位', value: '工程师'),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkStatistic
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkStatisticSpec = ParkComponentSpec(
  name: 'ParkStatistic',
  title: '统计数值 / Statistic',
  category: 'display',
  description:
      '以醒目大字展示一个数值，借鉴 Ant Design React Statistic。支持从 0 动画增长到目标值、'
      '小数精度（precision）与千分位分组（groupSeparator）、前缀（prefix）/ 后缀（suffix）装饰、'
      '标题（title，由构造函数参数暴露）、数值样式走 park.typography 令牌，并以 Semantics 包裹便于无障碍读取。'
      ' / Large numeric display with count-up animation, precision, thousands grouping, prefix/suffix, '
      'title and park.typography tokens, wrapped in Semantics. Zero third-party deps.',
  icon: Icons.tag_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'value',
      type: 'num',
      required: true,
      description: '目标数值（int / double 均可）/ Target value',
    ),
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      defaultVal: 'null',
      description: '标题文案（展示在数值上方），由构造函数参数暴露，组件内不硬编码 / Title above value',
    ),
    ParkPropertyDef(
      name: 'prefix',
      type: 'Widget?',
      defaultVal: 'null',
      description: '前缀装饰，如图标或货币符号 / Prefix (icon, symbol)',
    ),
    ParkPropertyDef(
      name: 'suffix',
      type: 'Widget?',
      defaultVal: 'null',
      description: '后缀装饰，如单位「人」「%」/ Suffix (unit)',
    ),
    ParkPropertyDef(
      name: 'precision',
      type: 'int?',
      defaultVal: 'null',
      description: '小数精度（固定小数位数）；为 null 时按数值实际精度展示 / Decimal places',
    ),
    ParkPropertyDef(
      name: 'groupSeparator',
      type: 'String?',
      defaultVal: "\",\"",
      description: '千分位分组符；传空字符串可关闭分组 / Thousands separator (empty = off)',
    ),
    ParkPropertyDef(
      name: 'decimalSeparator',
      type: 'String',
      defaultVal: "'.'",
      description: '小数点符号 / Decimal separator',
    ),
    ParkPropertyDef(
      name: 'valueStyle',
      type: 'TextStyle?',
      defaultVal: 'park.typography.h2',
      description:
          '数值文本样式；为 null 时取 park.typography.h2 令牌 / Value style (defaults to token)',
    ),
    ParkPropertyDef(
      name: 'titleStyle',
      type: 'TextStyle?',
      defaultVal: 'park.typography.caption',
      description:
          '标题文本样式；为 null 时取 park.typography.caption 令牌 / Title style (defaults to token)',
    ),
    ParkPropertyDef(
      name: 'animate',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用从 0 到 value 的动画增长 / Count-up animation',
    ),
    ParkPropertyDef(
      name: 'duration',
      type: 'Duration',
      defaultVal: '800ms',
      description: '动画时长 / Animation duration',
    ),
    ParkPropertyDef(
      name: 'curve',
      type: 'Curve',
      defaultVal: 'Curves.easeOutCubic',
      description: '动画曲线 / Animation curve',
    ),
    ParkPropertyDef(
      name: 'textAlign',
      type: 'TextAlign',
      defaultVal: 'TextAlign.start',
      description: '数值文本对齐 / Value text align',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础统计',
      description: '标题 + 数值，从 0 动画增长 / Title + value with count-up',
      code: "ParkStatistic(title: '活跃用户', value: 112893)",
      builder: (BuildContext context) =>
          ParkStatistic(title: '活跃用户', value: 112893),
    ),
    ParkDemoScenario(
      title: '千分位分组',
      description: 'groupSeparator 默认按千分位分组 / Thousands grouping',
      code:
          "ParkStatistic(title: '总销售额', value: 1234567.89, prefix: Text('¥'))",
      builder: (BuildContext context) => ParkStatistic(
        title: '总销售额',
        value: 1234567.89,
        prefix: const Text('¥'),
      ),
    ),
    ParkDemoScenario(
      title: '精度与后缀',
      description: 'precision 固定小数位，suffix 展示单位 / Precision + suffix unit',
      code:
          "ParkStatistic(title: '完成率', value: 87.345, precision: 2, suffix: Text('%'))",
      builder: (BuildContext context) => ParkStatistic(
        title: '完成率',
        value: 87.345,
        precision: 2,
        suffix: const Text('%'),
      ),
    ),
    ParkDemoScenario(
      title: '前缀图标',
      description: 'prefix 放置图标装饰 / Icon prefix',
      code:
          "ParkStatistic(title: '在线设备', value: 42, prefix: Icon(Icons.devices), suffix: Text('台'))",
      builder: (BuildContext context) => ParkStatistic(
        title: '在线设备',
        value: 42,
        prefix: const Icon(Icons.devices),
        suffix: const Text('台'),
      ),
    ),
    ParkDemoScenario(
      title: '关闭动画',
      description: 'animate: false 直接展示目标值 / No animation',
      code: "ParkStatistic(title: '库存', value: 318, animate: false)",
      builder: (BuildContext context) =>
          ParkStatistic(title: '库存', value: 318, animate: false),
    ),
  ],
  basicUsageCode: '''ParkStatistic(
  title: '活跃用户',
  value: 112893,
  prefix: Icon(Icons.people),
  suffix: Text('人'),
)''',
  guide: '''
## 何时使用
- 仪表盘、报表、概览页中突出展示关键指标（KPI）。
- 需要数值「跳动增长」的视觉反馈时开启 animate。

## 使用建议
- value 接受 int / double；precision 控制小数位，groupSeparator 控制千分位。
- prefix / suffix 适合放图标或单位，title 放指标名称（均通过构造函数参数暴露）。
- valueStyle / titleStyle 默认走 park.typography 令牌，按需覆盖即可。
- 无障碍：组件以 Semantics 包裹，screen reader 会朗读标题与最终数值。
''',
);

// ---------------------------------------------------------------------------
// ParkSplitter
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkSplitterSpec = ParkComponentSpec(
  name: 'ParkSplitter',
  title: '分隔面板 / Splitter',
  category: 'display',
  description:
      '可拖拽分隔面板组件，支持水平/垂直两个方向，对标 antd Splitter。'
      '提供最小/最大比例约束、受控比例、折叠按钮、双击复位与无障碍语义。'
      '所有视觉元素使用 park.* 设计令牌，零第三方依赖。'
      ' / Draggable split panel container supporting horizontal/vertical layouts, '
      'inspired by antd Splitter. Supports min/max ratio constraints, controlled mode, '
      'collapse buttons, double-tap reset and Semantics accessibility.',
  icon: Icons.horizontal_split_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'axis',
      type: 'Axis',
      defaultVal: 'Axis.horizontal',
      description:
          '布局方向：horizontal（左右分栏）/ vertical（上下分栏）/ Layout direction: horizontal / vertical',
    ),
    ParkPropertyDef(
      name: 'first',
      type: 'Widget',
      required: true,
      description: '左侧/上方面板内容 / First (left/top) panel content',
    ),
    ParkPropertyDef(
      name: 'second',
      type: 'Widget',
      required: true,
      description: '右侧/下方面板内容 / Second (right/bottom) panel content',
    ),
    ParkPropertyDef(
      name: 'defaultRatio',
      type: 'double',
      defaultVal: '0.5',
      description: '默认比例（0.0 ~ 1.0）/ Default split ratio (0.0 ~ 1.0)',
    ),
    ParkPropertyDef(
      name: 'minRatio',
      type: 'double?',
      defaultVal: 'null (0.0)',
      description: '面板最小比例，null 不限制 / Minimum panel ratio; null = no limit',
    ),
    ParkPropertyDef(
      name: 'maxRatio',
      type: 'double?',
      defaultVal: 'null (1.0)',
      description: '面板最大比例，null 不限制 / Maximum panel ratio; null = no limit',
    ),
    ParkPropertyDef(
      name: 'ratio',
      type: 'double?',
      defaultVal: 'null',
      description:
          '受控比例（非 null 时接管内部状态）/ Controlled ratio (overrides internal state when non-null)',
    ),
    ParkPropertyDef(
      name: 'onRatioChanged',
      type: 'ValueChanged<double>?',
      defaultVal: 'null',
      description: '比例变化回调 / Ratio change callback',
    ),
    ParkPropertyDef(
      name: 'dividerThickness',
      type: 'double?',
      defaultVal: 'park.spacing.xxs (2px)',
      description: '分隔条宽度 / Divider bar thickness',
    ),
    ParkPropertyDef(
      name: 'dividerColor',
      type: 'Color?',
      defaultVal: 'park.colors.divider',
      description: '分隔条颜色 / Divider bar color',
    ),
    ParkPropertyDef(
      name: 'dividerDragColor',
      type: 'Color?',
      defaultVal: 'park.colors.brand',
      description: '拖拽态分隔条颜色 / Divider bar color while dragging',
    ),
    ParkPropertyDef(
      name: 'collapsible',
      type: 'bool',
      defaultVal: 'false',
      description:
          '是否显示折叠按钮（点击折叠一侧面板）/ Show collapse arrow buttons on the divider',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onRatioChanged',
      signature: 'ValueChanged<double>?',
      description:
          '比例变化时触发（受控/非受控均触发）/ Fires when ratio changes (both controlled & uncontrolled)',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkSplitter(
  axis: Axis.horizontal,
  first: Padding(
    padding: EdgeInsets.all(_kSpacing.base),
    child: Center(child: Text('左侧面板')),
  ),
  second: Padding(
    padding: EdgeInsets.all(_kSpacing.base),
    child: Center(child: Text('右侧面板')),
  ),
)
''',
  guide: '''
## 何时使用 / When to use
- 需要用户自由拖拽调整两个面板的大小比例 / Let users freely resize two panels
- 代码编辑器主/侧栏、仪表盘左右布局、设置面板拆分 / Editor sidebar, dashboard layouts, settings panels

## 使用建议 / Usage tips
- minRatio / maxRatio 限制拖拽范围，防止面板过小 / Constrain resize range with minRatio / maxRatio
- 折叠后比例仍受 minRatio 约束，不会完全消失 / Collapsed ratio respects minRatio
- 双击分隔条可恢复到 defaultRatio / Double-tap the divider to reset to defaultRatio
- collapsible 开启后在分隔条上显示折叠箭头按钮 / collapsible shows arrow buttons on the divider
- ratio + onRatioChanged 实现受控模式（外部保存比例状态）/ ratio + onRatioChanged for controlled mode
- Semantics 包裹确保屏幕阅读器可识别为滑块 / Semantics wraps the divider as an adjustable slider
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础左右分割',
      description:
          '水平方向、默认比例 0.5 的左右分栏 / Horizontal split with default 0.5 ratio.',
      code: '''
ParkSplitter(
  axis: Axis.horizontal,
  first: Container(
    color: _kColors.surface,
    child: Center(child: Text('左侧面板')),
  ),
  second: Container(
    color: _kColors.background,
    child: Center(child: Text('右侧面板')),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 200,
        child: ParkSplitter(
          axis: Axis.horizontal,
          first: Container(
            color: _kColors.surface,
            child: const Center(child: Text('左侧面板')),
          ),
          second: Container(
            color: _kColors.background,
            child: const Center(child: Text('右侧面板')),
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '上下分割',
      description: '垂直方向、顶部/底部面板 / Vertical split with top/bottom panels.',
      code: '''
ParkSplitter(
  axis: Axis.vertical,
  first: Container(
    color: _kColors.surface,
    child: Center(child: Text('上方面板')),
  ),
  second: Container(
    color: _kColors.background,
    child: Center(child: Text('下方面板')),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 300,
        child: ParkSplitter(
          axis: Axis.vertical,
          first: Container(
            color: _kColors.surface,
            child: const Center(child: Text('上方面板')),
          ),
          second: Container(
            color: _kColors.background,
            child: const Center(child: Text('下方面板')),
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '嵌套分割 + 折叠按钮',
      description:
          '水平嵌套垂直分割，开启折叠按钮 / Horizontal wrapping a vertical split, both with collapsible buttons.',
      code: '''
ParkSplitter(
  axis: Axis.horizontal,
  collapsible: true,
  first: Container(
    color: _kColors.surface,
    child: Center(child: Text('左侧面板')),
  ),
  second: ParkSplitter(
    axis: Axis.vertical,
    collapsible: true,
    first: Container(
      color: _kColors.brandLight,
      child: Center(child: Text('右上')),
    ),
    second: Container(
      color: _kColors.surface,
      child: Center(child: Text('右下')),
    ),
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 300,
        child: ParkSplitter(
          axis: Axis.horizontal,
          collapsible: true,
          first: Container(
            color: _kColors.surface,
            child: const Center(child: Text('左侧面板')),
          ),
          second: ParkSplitter(
            axis: Axis.vertical,
            collapsible: true,
            first: Container(
              color: _kColors.brandLight,
              child: const Center(child: Text('右上')),
            ),
            second: Container(
              color: _kColors.surface,
              child: const Center(child: Text('右下')),
            ),
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '受控比例',
      description:
          '通过按钮切换比例，展示受控模式 / Controlled ratio via external button (StatefulBuilder).',
      code: '''
StatefulBuilder(
  builder: (context, setState) {
    double ratio = 0.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkButton(
          onPressed: () {
            ratio = ratio == 0.5 ? 0.3 : 0.5;
            setState(() {});
          },
          child: Text('切换比例（当前 \${(ratio * 100).toInt()}%）'),
        ),
        SizedBox(height: _kSpacing.sm),
        SizedBox(
          height: 150,
          child: ParkSplitter(
            axis: Axis.horizontal,
            ratio: ratio,
            onRatioChanged: (v) {
              ratio = v;
              setState(() {});
            },
            first: Container(
              color: _kColors.surface,
              child: Center(child: Text('左')),
            ),
            second: Container(
              color: _kColors.background,
              child: Center(child: Text('右')),
            ),
          ),
        ),
      ],
    );
  },
)''',
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          double ratio = 0.5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkButton(
                onPressed: () {
                  ratio = ratio == 0.5 ? 0.3 : 0.5;
                  setState(() {});
                },
                child: Text('切换比例（当前 ${(ratio * 100).toInt()}%）'),
              ),
              SizedBox(height: _kSpacing.sm),
              SizedBox(
                height: 150,
                child: ParkSplitter(
                  axis: Axis.horizontal,
                  ratio: ratio,
                  onRatioChanged: (double v) {
                    ratio = v;
                    setState(() {});
                  },
                  first: Container(
                    color: _kColors.surface,
                    child: const Center(child: Text('左')),
                  ),
                  second: Container(
                    color: _kColors.background,
                    child: const Center(child: Text('右')),
                  ),
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
// ParkFlex
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkFlexSpec = ParkComponentSpec(
  name: 'ParkFlex',
  title: '弹性布局 / Flex',
  category: 'display',
  description:
      '弹性布局组件，对标 Ant Design Flex。根据 direction 选择 Row / Column，'
      '支持 gap 子组件间距、wrap 换行模式（使用 Wrap）、flexValues 控制各子组件 flex 比例。'
      ' / Flex layout component mirroring Ant Design Flex. '
      'Switches between Row / Column by direction, supports gap spacing, wrap mode (Wrap widget), '
      'and flexValues for proportional sizing.',
  icon: Icons.view_stream_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'direction',
      type: 'ParkFlexDirection',
      defaultVal: 'ParkFlexDirection.row',
      description: '布局方向：row / rowReverse / column / columnReverse / Layout direction',
    ),
    ParkPropertyDef(
      name: 'justify',
      type: 'MainAxisAlignment',
      defaultVal: 'MainAxisAlignment.start',
      description: '主轴对齐方式 / Main axis alignment',
    ),
    ParkPropertyDef(
      name: 'align',
      type: 'CrossAxisAlignment',
      defaultVal: 'CrossAxisAlignment.center',
      description: '交叉轴对齐方式 / Cross axis alignment',
    ),
    ParkPropertyDef(
      name: 'wrap',
      type: 'bool',
      defaultVal: 'false',
      description: '是否换行（为 true 时使用 Wrap 替代 Row/Column）/ Wrap children',
    ),
    ParkPropertyDef(
      name: 'gap',
      type: 'double',
      defaultVal: '0',
      description: '子组件之间的间距 / Gap between children',
    ),
    ParkPropertyDef(
      name: 'flexValues',
      type: 'List<int>?',
      defaultVal: 'null',
      description: '每个子组件的 flex 值（长度须与 children 一致）；wrap 模式下无效 / Per-child flex values',
    ),
    ParkPropertyDef(
      name: 'runGap',
      type: 'double?',
      defaultVal: 'null',
      description: '换行时的行间距（仅 wrap 模式有效）/ Run gap in wrap mode',
    ),
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      defaultVal: 'const []',
      description: '子组件列表 / Children widgets',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkFlex(
  direction: ParkFlexDirection.row,
  gap: 16,
  children: [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)

// Wrap mode
ParkFlex(
  wrap: true,
  gap: 12,
  children: [chip1, chip2, chip3, chip4],
)

// Flex proportional
ParkFlex(
  flexValues: [1, 2, 1],
  children: [Widget1(), Widget2(), Widget3()],
)
''',
  guide: '''
## 何时使用
- 需要水平或垂直排列一组子组件时
- 需要等间距排列（gap）而非手动 SizedBox
- 需要换行排列（wrap 模式）
- 需要按比例分配空间（flexValues）

## 使用建议
- direction 为 row/column 系列，决定主轴方向
- gap 替代手动插入 SizedBox，更简洁
- wrap 为 true 时自动切换到 Wrap 组件，flexValues 失效
- flexValues 长度必须与 children 一致，每个 child 被包裹在 Expanded 中
- 便捷构造：ParkFlex.row() / ParkFlex.column() 可省略 direction
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '水平布局 + gap',
      description: 'row 方向，子组件间 16px 间距。',
      code: '''
ParkFlex(
  direction: ParkFlexDirection.row,
  gap: 16,
  children: [
    Container(width: 60, height: 40, color: Colors.blue, child: Text('A')),
    Container(width: 60, height: 40, color: Colors.green, child: Text('B')),
    Container(width: 60, height: 40, color: Colors.orange, child: Text('C')),
  ],
)''',
      builder: (BuildContext context) => ParkFlex(
        direction: ParkFlexDirection.row,
        gap: 16,
        children: <Widget>[
          Container(width: 60, height: 40, color: _kColors.brand, child: const Text('A')),
          Container(width: 60, height: 40, color: _kColors.success, child: const Text('B')),
          Container(width: 60, height: 40, color: _kColors.warning, child: const Text('C')),
        ],
      ),
    ),
    ParkDemoScenario(
      title: 'Flex 比例分配',
      description: 'flexValues [1, 2, 1] 按比例分配宽度。',
      code: '''
ParkFlex(
  flexValues: [1, 2, 1],
  gap: 8,
  children: [
    Container(height: 40, color: Colors.blue, child: Text('1')),
    Container(height: 40, color: Colors.green, child: Text('2')),
    Container(height: 40, color: Colors.orange, child: Text('1')),
  ],
)''',
      builder: (BuildContext context) => ParkFlex(
        flexValues: <int>[1, 2, 1],
        gap: 8,
        children: <Widget>[
          Container(height: 40, color: _kColors.brand, child: const Text('1')),
          Container(height: 40, color: _kColors.success, child: const Text('2')),
          Container(height: 40, color: _kColors.warning, child: const Text('1')),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkGridRow
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkGridRowSpec = ParkComponentSpec(
  name: 'ParkGridRow',
  title: '栅格行 / Grid Row',
  category: 'display',
  description:
      '24 格响应式栅格系统的行容器。使用 LayoutBuilder 获取父容器宽度，'
      '根据断点（xs/sm/md/lg/xl/xxl）自动计算每个 ParkGridCol 的实际 span，'
      '支持水平 gutter、垂直行间距 vGutter、对齐与排列。'
      ' / Row container for the 24-column responsive grid system. '
      'Uses LayoutBuilder to measure parent width, resolves each ParkGridCol span per breakpoint, '
      'supports horizontal gutter, vertical gutter, alignment and justification.',
  icon: Icons.view_column_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'gutter',
      type: 'double',
      defaultVal: '0',
      description: '列间距（水平 gutter，单位 px）/ Horizontal gutter between columns',
    ),
    ParkPropertyDef(
      name: 'vGutter',
      type: 'double',
      defaultVal: '0',
      description: '行间距（垂直 gutter，单位 px）/ Vertical gutter between rows',
    ),
    ParkPropertyDef(
      name: 'align',
      type: 'ParkGridRowAlign',
      defaultVal: 'ParkGridRowAlign.start',
      description: '垂直对齐方式：start / center / end / stretch / baseline / Cross-axis alignment',
    ),
    ParkPropertyDef(
      name: 'justify',
      type: 'ParkGridJustify',
      defaultVal: 'ParkGridJustify.start',
      description: '水平排列方式：start / center / end / spaceBetween / spaceAround / spaceEvenly / Main-axis justification',
    ),
    ParkPropertyDef(
      name: 'children',
      type: 'List<Widget>',
      defaultVal: 'const []',
      description: '子组件列表（通常为 ParkGridCol）/ Children (typically ParkGridCol)',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkGridRow(
  gutter: 16,
  children: [
    ParkGridCol(span: 8, child: Text('A')),
    ParkGridCol(span: 8, child: Text('B')),
    ParkGridCol(span: 8, child: Text('C')),
  ],
)
''',
  guide: '''
## 何时使用
- 需要响应式栅格布局（24 格系统）
- 不同屏幕尺寸下需要自动调整列宽
- 对标 Ant Design Row/Col 栅格系统

## 使用建议
- 配合 ParkGridCol 使用，每个 Col 指定 span（0-24）
- gutter 控制列间距，vGutter 控制换行后的行间距
- ParkGridCol 可通过 responsive 为不同断点设置不同 span
- 断点定义：xs(<576) / sm(>=576) / md(>=768) / lg(>=992) / xl(>=1200) / xxl(>=1600)
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础三列',
      description: '三等分栅格布局，gutter 16px。',
      code: '''
ParkGridRow(
  gutter: 16,
  children: [
    ParkGridCol(span: 8, child: Container(height: 60, color: Colors.blue, child: Text('8'))),
    ParkGridCol(span: 8, child: Container(height: 60, color: Colors.green, child: Text('8'))),
    ParkGridCol(span: 8, child: Container(height: 60, color: Colors.orange, child: Text('8'))),
  ],
)''',
      builder: (BuildContext context) => ParkGridRow(
        gutter: 16,
        children: <Widget>[
          ParkGridCol(span: 8, child: Container(height: 60, color: _kColors.brand, child: const Text('8'))),
          ParkGridCol(span: 8, child: Container(height: 60, color: _kColors.success, child: const Text('8'))),
          ParkGridCol(span: 8, child: Container(height: 60, color: _kColors.warning, child: const Text('8'))),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkGridCol
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkGridColSpec = ParkComponentSpec(
  name: 'ParkGridCol',
  title: '栅格列 / Grid Col',
  category: 'display',
  description:
      '24 格响应式栅格系统的列单元。指定 span（0-24）控制占格宽度，'
      '支持 offset 左偏移、order 排序、responsive 为不同断点配置不同 span。'
      ' / Column unit of the 24-column responsive grid. '
      'span (0-24) controls width, with offset, order, and per-breakpoint responsive span.',
  icon: Icons.view_column_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'span',
      type: 'int',
      defaultVal: '24',
      description: '占格数（总共 24 格，0-24）/ Column span (out of 24)',
    ),
    ParkPropertyDef(
      name: 'offset',
      type: 'int',
      defaultVal: '0',
      description: '左侧偏移格数 / Left offset in grid units',
    ),
    ParkPropertyDef(
      name: 'order',
      type: 'int',
      defaultVal: '0',
      description: '排序值（越小越靠前）/ Sort order (ascending)',
    ),
    ParkPropertyDef(
      name: 'responsive',
      type: 'ParkGridResponsive?',
      defaultVal: 'null',
      description: '响应式配置，为不同断点指定不同 span / Responsive span per breakpoint',
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget?',
      defaultVal: 'null',
      description: '子组件 / Child widget',
    ),
  ],
  events: const <ParkEventDef>[],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkGridCol(
  span: 12,
  child: Text('半宽'),
)

// 响应式
ParkGridCol(
  span: 24,
  responsive: ParkGridResponsive(
    sm: 12,
    md: 8,
    lg: 6,
  ),
  child: Text('响应式'),
)
''',
  guide: '''
## 何时使用
- 作为 ParkGridRow 的子组件，指定占格宽度
- 需要响应式布局时配合 responsive 为不同断点设置不同 span

## 使用建议
- span 范围 0-24，24 为满行
- responsive 优先级高于 span，断点匹配时覆盖默认 span
- offset 可产生左侧空白偏移效果
- order 控制排列顺序
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '响应式列',
      description: '默认满行，sm 半行，md 三分之一，lg 四分之一。',
      code: '''
ParkGridRow(
  gutter: 16,
  children: [
    ParkGridCol(
      span: 24,
      responsive: ParkGridResponsive(sm: 12, md: 8, lg: 6),
      child: Container(height: 60, color: Colors.blue, child: Text('响应式')),
    ),
  ],
)''',
      builder: (BuildContext context) => ParkGridRow(
        gutter: 16,
        children: <Widget>[
          ParkGridCol(
            span: 24,
            responsive: const ParkGridResponsive(sm: 12, md: 8, lg: 6),
            child: Container(height: 60, color: _kColors.brand, child: const Text('响应式')),
          ),
        ],
      ),
    ),
  ],
);
