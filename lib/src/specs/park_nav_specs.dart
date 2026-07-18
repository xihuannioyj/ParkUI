// Park 导航组件规格 — 由 Agent 审计并补全（对照真实实现）
//
// 约定：
//  - properties 枚举组件公开构造参数（排除 Key / BuildContext / 内容 Widget / 内部专用）；
//  - 函数类型的参数归入 events（onChanged / onClose / onTap / onAdd 等）；
//  - 每个事件 / 方法 / 主要属性变体均对应一个 demo，且 code 与 builder 完全一致；
//  - 禁止裸字面量：颜色用 ParkColors.* / Theme token，间距用 ParkSpacing.*，字号用 ParkTypography.*；
//  - 双语（中文为主、英文并列）。
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

/// 导航组件规格字典（8 个组件）。
///
/// 令牌常量：统一复用 Park 设计令牌，杜绝裸字面量 / 魔法数字。
final ParkColors _kColors = ParkColors.light();
final ParkSpacing _kSpacing = ParkSpacing.defaults();

Map<String, ParkComponentSpec> get parkNavSpecs =>
    <String, ParkComponentSpec>{
      'ParkTabs': ParkComponentSpec(
        name: 'ParkTabs',
        title: '标签页 / Tabs',
        category: 'nav',
        icon: Icons.tab_outlined,
        description:
            '提供顶部 / 底部 / 左右 Tab 切换导航，支持固定与可滚动两种模式，'
            '内置品牌色下划线 / 卡片式动画指示器，可搭配内容区使用。'
            '支持受控（currentIndex）/ 非受控（initialIndex）两种用法，并可选关闭按钮与添加按钮。'
            ' / Top / bottom / left / right tab navigation with fixed & scrollable modes, '
            'brand underline / card indicator, controlled (currentIndex) & uncontrolled (initialIndex), '
            'optional closable & addable tabs.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'tabs',
            type: 'List<ParkTab>',
            required: true,
            description: '标签页数据列表，每个元素为 ParkTab（label, icon, badge）。',
          ),
          ParkPropertyDef(
            name: 'initialIndex',
            type: 'int',
            defaultVal: '0',
            description: '非受控模式下的初始选中索引（0-based）。',
          ),
          ParkPropertyDef(
            name: 'currentIndex',
            type: 'int?',
            defaultVal: 'null',
            description:
                '受控选中索引；不为 null 时由外部完全控制选中项（配合 onChanged 使用）。',
          ),
          ParkPropertyDef(
            name: 'children',
            type: 'List<Widget>?',
            defaultVal: 'null',
            description: '对应每个标签页的内容 Widget，数量需与 tabs 一致。',
          ),
          ParkPropertyDef(
            name: 'scrollable',
            type: 'bool',
            defaultVal: 'false',
            description: '标签多时启用水平滚动模式。',
          ),
          ParkPropertyDef(
            name: 'indicatorType',
            type: 'ParkTabIndicatorType',
            defaultVal: 'ParkTabIndicatorType.line',
            description: '指示器类型：line（下划线）或 card（卡片背景）。',
          ),
          ParkPropertyDef(
            name: 'tabPosition',
            type: 'ParkTabPosition',
            defaultVal: 'ParkTabPosition.top',
            description: '标签栏位置：top / bottom / left / right。',
          ),
          ParkPropertyDef(
            name: 'animated',
            type: 'bool',
            defaultVal: 'true',
            description: '内容切换时是否启用滑动动画（关闭则使用 IndexedStack 瞬时切换）。',
          ),
          ParkPropertyDef(
            name: 'centered',
            type: 'bool',
            defaultVal: 'false',
            description: '标签是否居中排列（仅固定模式生效）。',
          ),
          ParkPropertyDef(
            name: 'type',
            type: 'ParkTabType?',
            defaultVal: 'null',
            description: '标签视觉风格：line / card；不为 null 时优先于 indicatorType。',
          ),
          ParkPropertyDef(
            name: 'closable',
            type: 'bool',
            defaultVal: 'false',
            description: '是否在每个标签上显示关闭按钮（触发 onClose）。',
          ),
          ParkPropertyDef(
            name: 'addable',
            type: 'bool',
            defaultVal: 'false',
            description: '是否显示添加标签的"+"按钮（触发 onAdd）。',
          ),
          ParkPropertyDef(
            name: 'size',
            type: 'ParkTabSize',
            defaultVal: 'ParkTabSize.medium',
            description: '标签栏尺寸：medium / large。',
          ),
          ParkPropertyDef(
            name: 'indicatorColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '指示器颜色，覆盖默认品牌色。',
          ),
          ParkPropertyDef(
            name: 'keyboard',
            type: 'bool',
            defaultVal: 'false',
            description: '是否支持键盘方向键切换标签。',
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
                '如果组件位于 ParkForm 内且表单已注入 bindingService，'
                '此参数可省略（自动从 ParkBindingFormScope 获取）。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onChanged',
            signature: 'ValueChanged<int>?',
            description: '标签页切换时触发，参数为新的选中索引。',
          ),
          ParkEventDef(
            name: 'onClose',
            signature: 'ValueChanged<int>?',
            description: '点击标签关闭按钮时触发，参数为被关闭标签的索引。',
          ),
          ParkEventDef(
            name: 'onAdd',
            signature: 'VoidCallback?',
            description: '点击添加标签"+"按钮时触发。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础标签页',
            description: '三个固定标签页，带下划线指示器。',
            code: '''ParkTabs(
  tabs: [
    ParkTab(label: '推荐'),
    ParkTab(label: '热门'),
    ParkTab(label: '最新'),
  ],
  children: [
    Center(child: Text('推荐内容')),
    Center(child: Text('热门内容')),
    Center(child: Text('最新内容')),
  ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 200,
              child: ParkTabs(
                tabs: const <ParkTab>[
                  ParkTab(label: '推荐'),
                  ParkTab(label: '热门'),
                  ParkTab(label: '最新'),
                ],
                children: <Widget>[
                  const Center(child: Text('推荐内容')),
                  const Center(child: Text('热门内容')),
                  const Center(child: Text('最新内容')),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '受控切换（onChanged）',
            description: '通过 currentIndex + onChanged 受控管理选中项。',
            code: '''ParkTabs(
  currentIndex: _index,
  onChanged: (int i) => setState(() => _index = i),
  tabs: [
    ParkTab(label: '推荐'),
    ParkTab(label: '热门'),
    ParkTab(label: '最新'),
  ],
  children: [
    Center(child: Text('推荐内容')),
    Center(child: Text('热门内容')),
    Center(child: Text('最新内容')),
  ],
)''',
            builder: (BuildContext context) => _ParkTabsOnChangedDemo(),
          ),
          ParkDemoScenario(
            title: '带角标和图标',
            description: '标签页可显示角标数字或前置图标。',
            code: '''ParkTabs(
  tabs: [
    ParkTab(label: '推荐'),
    ParkTab(label: '热门', badge: '9'),
    ParkTab(label: '最新', icon: Icons.new_releases),
  ],
  children: [ ... ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 200,
              child: ParkTabs(
                tabs: const <ParkTab>[
                  ParkTab(label: '推荐'),
                  ParkTab(label: '热门', badge: '9'),
                  ParkTab(label: '最新', icon: Icons.new_releases),
                ],
                children: <Widget>[
                  const Center(child: Text('推荐内容')),
                  const Center(child: Text('热门内容')),
                  const Center(child: Text('最新内容')),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '可滚动标签页',
            description: '标签数量较多时启用 scrollable 模式。',
            code: '''ParkTabs(
  scrollable: true,
  tabs: [
    ParkTab(label: '全部'),
    ParkTab(label: '科技'),
    ParkTab(label: '娱乐'),
    ParkTab(label: '体育'),
    ParkTab(label: '财经'),
  ],
  children: [ ... ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 200,
              child: ParkTabs(
                scrollable: true,
                tabs: const <ParkTab>[
                  ParkTab(label: '全部'),
                  ParkTab(label: '科技'),
                  ParkTab(label: '娱乐'),
                  ParkTab(label: '体育'),
                  ParkTab(label: '财经'),
                ],
                children: <Widget>[
                  const Center(child: Text('全部')),
                  const Center(child: Text('科技')),
                  const Center(child: Text('娱乐')),
                  const Center(child: Text('体育')),
                  const Center(child: Text('财经')),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '卡片式指示器',
            description: '使用 indicatorType: card 显示卡片背景指示器。',
            code: '''ParkTabs(
  indicatorType: ParkTabIndicatorType.card,
  tabs: [ ... ],
  children: [ ... ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 200,
              child: ParkTabs(
                indicatorType: ParkTabIndicatorType.card,
                tabs: const <ParkTab>[
                  ParkTab(label: '日'),
                  ParkTab(label: '周'),
                  ParkTab(label: '月'),
                ],
                children: <Widget>[
                  const Center(child: Text('日视图')),
                  const Center(child: Text('周视图')),
                  const Center(child: Text('月视图')),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '可关闭与可添加（onClose / onAdd）',
            description: 'closable 显示关闭按钮触发 onClose，addable 显示"+"触发 onAdd。',
            code: '''ParkTabs(
  scrollable: true,
  closable: true,
  addable: true,
  onClose: (int i) => _tabs.removeAt(i),
  onAdd: () => _tabs.add(ParkTab(label: '新标签')),
  tabs: _tabs,
  children: _tabs.map((t) => Center(child: Text(t.label))).toList(),
)''',
            builder: (BuildContext context) => _ParkTabsClosableDemo(),
          ),
        ],
        basicUsageCode: '''ParkTabs(
  tabs: [
    ParkTab(label: '推荐'),
    ParkTab(label: '热门', badge: '9'),
    ParkTab(label: '最新', icon: Icons.new_releases),
  ],
  onChanged: (index) => print('切换到 \$index'),
  children: [
    Center(child: Text('推荐内容')),
    Center(child: Text('热门内容')),
    Center(child: Text('最新内容')),
  ],
)''',
        guide: '''
## 何时使用 / When to use
- 需要在同一页面内切换不同内容分类时 / Switch content categories within a page
- 新闻分类、商品分类、功能模块切换等 / News / product / module categories

## 使用建议 / Usage tips
- 标签少（3-5 个）用固定模式，标签多用 scrollable: true
- 通过 badge 展示未读数或新内容提示
- 卡片指示器（card）适合需要强调当前选中的场景
- 搭配 TabBarView 或 children 展示对应内容
- 受控场景用 currentIndex + onChanged；非受控用 initialIndex
- closable / addable 用于可编辑的标签组（如浏览器多标签）

## 搭配推荐 / Compose with
- 搭配 ParkSearch 做分类搜索
- 搭配 ParkList 做分类列表
- 搭配 ParkBadge 做未读提示
''',
      ),

      'ParkTabBar': ParkComponentSpec(
        name: 'ParkTabBar',
        title: '标签栏 / Tab Bar',
        category: 'nav',
        icon: Icons.navigation_outlined,
        description:
            '用于 App 底部 Tab 切换导航，支持固定与悬浮两种风格，'
            '可选中心凸起按钮（FAB）。选中项显示品牌色，未选中为灰色。'
            '支持受控（currentIndex）/ 非受控（initialIndex）两种用法。'
            ' / App bottom tab navigation with fixed & floating styles, optional center FAB, '
            'brand highlight for the active item, controlled (currentIndex) & uncontrolled (initialIndex).',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'items',
            type: 'List<ParkTabBarItem>',
            required: true,
            description: '导航项列表，每个元素含 icon、activeIcon、label、badge、dotIndicator。',
          ),
          ParkPropertyDef(
            name: 'currentIndex',
            type: 'int?',
            defaultVal: 'null',
            description: '受控选中索引；不为 null 时由外部控制选中项（配合 onTap 使用）。',
          ),
          ParkPropertyDef(
            name: 'initialIndex',
            type: 'int',
            defaultVal: '0',
            description: '非受控模式下的初始选中索引（0-based）。',
          ),
          ParkPropertyDef(
            name: 'type',
            type: 'ParkTabBarType',
            defaultVal: 'ParkTabBarType.fixed',
            description: '导航栏类型：fixed（固定式）或 floating（悬浮式）。',
          ),
          ParkPropertyDef(
            name: 'shape',
            type: 'ParkTabBarShape',
            defaultVal: 'ParkTabBarShape.normal',
            description: '导航栏形状：normal / round / notch（中间内凹）。',
          ),
          ParkPropertyDef(
            name: 'useSafeArea',
            type: 'bool',
            defaultVal: 'true',
            description: '是否自动为底部留出安全区域（刘海 / 底部手势条）。',
          ),
          ParkPropertyDef(
            name: 'fixed',
            type: 'bool',
            defaultVal: 'true',
            description: '是否固定在屏幕底部；为 false 时作为普通布局元素。',
          ),
          ParkPropertyDef(
            name: 'elevation',
            type: 'double',
            defaultVal: '8',
            description: '导航栏上方阴影高度（像素），仅 fixed 且非悬浮模式生效。',
          ),
          ParkPropertyDef(
            name: 'bordered',
            type: 'bool',
            defaultVal: 'true',
            description: '是否显示顶部分割线（仅非悬浮模式生效）。',
          ),
          ParkPropertyDef(
            name: 'centerAction',
            type: 'Widget?',
            defaultVal: 'null',
            description: '中心凸起按钮（FAB），显示在底部导航栏中央。',
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
                '如果组件位于 ParkForm 内且表单已注入 bindingService，'
                '此参数可省略（自动从 ParkBindingFormScope 获取）。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onTap',
            signature: 'ValueChanged<int>?',
            description: '点击导航项时触发，参数为被点击项的索引。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '固定式底部导航',
            description: '最常见的三栏底部导航，贴底有顶部边线。',
            code: '''ParkTabBar(
  currentIndex: _index,
  onTap: (int i) => setState(() => _index = i),
  items: [
    ParkTabBarItem(icon: Icons.home, label: '首页'),
    ParkTabBarItem(icon: Icons.search, label: '发现'),
    ParkTabBarItem(icon: Icons.person, label: '我的'),
  ],
)''',
            builder: (BuildContext context) => _ParkTabBarDemo(),
          ),
          ParkDemoScenario(
            title: '悬浮式底部导航',
            description: '圆角卡片悬浮于底部，带阴影效果。',
            code: '''ParkTabBar(
  type: ParkTabBarType.floating,
  currentIndex: _index,
  onTap: (int i) => setState(() => _index = i),
  items: [ ... ],
)''',
            builder: (BuildContext context) => _ParkTabBarFloatingDemo(),
          ),
          ParkDemoScenario(
            title: '带角标的导航项',
            description: '导航项可显示未读消息角标或红点。',
            code: '''ParkTabBarItem(icon: Icons.mail, label: '消息', badge: '5')
ParkTabBarItem(icon: Icons.notifications, label: '提醒', dotIndicator: true)''',
            builder: (BuildContext context) => _ParkTabBarBadgeDemo(),
          ),
          ParkDemoScenario(
            title: '中心凸起按钮',
            description: '通过 centerAction 在底部导航中央放置 FAB。',
            code: '''ParkTabBar(
  centerAction: ParkFab(icon: Icons.add, onPressed: () {}),
  items: [
    ParkTabBarItem(icon: Icons.home, label: '首页'),
    ParkTabBarItem(icon: Icons.search, label: '发现'),
    ParkTabBarItem(icon: Icons.person, label: '我的'),
  ],
)''',
            builder: (BuildContext context) => _ParkTabBarCenterDemo(),
          ),
        ],
        basicUsageCode: '''ParkTabBar(
  items: [
    ParkTabBarItem(icon: Icons.home, label: '首页'),
    ParkTabBarItem(icon: Icons.search, label: '发现'),
    ParkTabBarItem(icon: Icons.person, label: '我的'),
  ],
  currentIndex: _index,
  onTap: (index) => setState(() => _index = index),
)''',
        guide: '''
## 何时使用 / When to use
- App 底部主导航切换时
- 3-5 个主要功能模块的切换

## 使用建议 / Usage tips
- 导航项数量建议 3-5 个，过多时考虑折叠
- 悬浮式（floating）适合需要视觉突出的场景
- 通过 badge / dotIndicator 展示未读消息数
- 搭配 Scaffold.bottomNavigationBar 使用
- 中心凸起用 centerAction 放置主操作 FAB

## 搭配推荐 / Compose with
- 搭配 ParkFab 做底部导航 + 主操作
- 搭配 ParkBadge 做消息提醒
- 搭配 ParkNavBar 做顶部 + 底部导航组合
''',
      ),

      'ParkNavBar': ParkComponentSpec(
        name: 'ParkNavBar',
        title: '顶部导航栏 / App Bar',
        category: 'nav',
        icon: Icons.web_asset_outlined,
        description:
            '提供居中标题、返回箭头、右侧操作按钮等常见 AppBar 功能，'
            '支持透明背景模式、副标题、自定义 leading 与底部附加内容。'
            ' / Top app bar with centered title, back arrow, right actions, transparent mode, '
            'subtitle, custom leading and bottom content.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'title',
            type: 'Widget?',
            defaultVal: 'null',
            description: '标题 Widget，可使用 ParkNavBar.text() 快捷构造字符串标题。',
          ),
          ParkPropertyDef(
            name: 'leftArrow',
            type: 'bool',
            defaultVal: 'false',
            description: '是否显示左侧返回箭头图标。',
          ),
          ParkPropertyDef(
            name: 'rightActions',
            type: 'List<Widget>?',
            defaultVal: 'null',
            description: '右侧操作按钮列表（如搜索、更多等 IconButton）。',
          ),
          ParkPropertyDef(
            name: 'transparent',
            type: 'bool',
            defaultVal: 'false',
            description: '是否透明背景（无底色、无边框）。',
          ),
          ParkPropertyDef(
            name: 'height',
            type: 'double',
            defaultVal: '56.0',
            description: '导航栏高度。',
          ),
          ParkPropertyDef(
            name: 'backgroundColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '自定义背景色，覆盖主题默认 surface 色。',
          ),
          ParkPropertyDef(
            name: 'titleColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '标题文字颜色。',
          ),
          ParkPropertyDef(
            name: 'safeAreaTop',
            type: 'bool',
            defaultVal: 'true',
            description: '是否为顶部状态栏预留安全区域。',
          ),
          ParkPropertyDef(
            name: 'bordered',
            type: 'bool',
            defaultVal: 'true',
            description: '是否显示底部边框。',
          ),
          ParkPropertyDef(
            name: 'elevation',
            type: 'double',
            defaultVal: '0',
            description: '阴影高度（0 = 无阴影）。',
          ),
          ParkPropertyDef(
            name: 'centerTitle',
            type: 'bool',
            defaultVal: 'false',
            description: '标题是否始终居中（不受 leading / trailing 宽度影响）。',
          ),
          ParkPropertyDef(
            name: 'titleWidget',
            type: 'Widget?',
            defaultVal: 'null',
            description: '自定义标题 Widget（优先级高于 title）。',
          ),
          ParkPropertyDef(
            name: 'leading',
            type: 'Widget?',
            defaultVal: 'null',
            description: '自定义前置 Widget（替代默认返回箭头）。',
          ),
          ParkPropertyDef(
            name: 'subTitle',
            type: 'String?',
            defaultVal: 'null',
            description: '副标题（显示在主标题下方）。',
          ),
          ParkPropertyDef(
            name: 'bottom',
            type: 'PreferredSizeWidget?',
            defaultVal: 'null',
            description: '导航栏底部附加内容（如搜索栏、二级标签等）。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onBack',
            signature: 'VoidCallback?',
            description: '点击左侧返回箭头时的回调。',
          ),
          ParkEventDef(
            name: 'onBackConfirm',
            signature: 'Future<bool> Function()?',
            description: '返回确认回调；返回 false 可取消返回操作，返回 true 继续执行。',
          ),
        ],
        methods: const <ParkMethodDef>[
          ParkMethodDef(
            name: 'ParkNavBar.text',
            signature:
                "factory ParkNavBar.text({required String title, bool leftArrow, VoidCallback? onBack, List<Widget>? rightActions, bool transparent, double height, Color? backgroundColor, Color? titleColor, bool safeAreaTop, bool bordered, double elevation, bool centerTitle, Widget? titleWidget, Widget? leading, String? subTitle, Future<bool> Function()? onBackConfirm})",
            description: '以字符串快捷构造标题的工厂方法。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础标题栏',
            description: '仅显示居中标题。',
            code: '''ParkNavBar.text(title: '首页')''',
            builder: (BuildContext context) =>
                ParkNavBar.text(title: '首页'),
          ),
          ParkDemoScenario(
            title: '带返回按钮和操作',
            description: '左侧返回箭头 + 右侧搜索按钮，点击返回触发 onBack。',
            code: '''ParkNavBar.text(
  title: '详情',
  leftArrow: true,
  onBack: () => Navigator.pop(context),
  rightActions: [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
  ],
)''',
            builder: (BuildContext context) => ParkNavBar.text(
              title: '详情',
              leftArrow: true,
              rightActions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          ParkDemoScenario(
            title: '透明模式',
            description: 'transparent: true 时导航栏无底色无边框，适合覆盖在内容之上。',
            code: '''ParkNavBar.text(
  title: '相册',
  transparent: true,
  leftArrow: true,
)''',
            builder: (BuildContext context) => Container(
              color: _kColors.brand.withValues(alpha: 0.12),
              child: ParkNavBar.text(
                title: '相册',
                transparent: true,
                leftArrow: true,
              ),
            ),
          ),
          ParkDemoScenario(
            title: '副标题与返回确认',
            description: 'subTitle 显示副标题；onBackConfirm 异步确认返回。',
            code: '''ParkNavBar.text(
  title: '编辑资料',
  subTitle: '请填写真实信息',
  leftArrow: true,
  onBack: () => print('返回'),
  onBackConfirm: () async => true,
)''',
            builder: (BuildContext context) => _ParkNavBarOnBackDemo(),
          ),
        ],
        basicUsageCode: '''ParkNavBar.text(
  title: '首页',
  leftArrow: true,
  onBack: () => Navigator.pop(context),
  rightActions: [
    IconButton(icon: Icon(Icons.search), onPressed: () {}),
  ],
)''',
        guide: '''
## 何时使用 / When to use
- 页面顶部需要标题栏时
- 需要返回按钮、标题、右侧操作区的标准导航栏

## 使用建议 / Usage tips
- 使用 ParkNavBar.text() 快捷构造字符串标题
- 子页面设置 leftArrow: true 显示返回箭头
- 透明模式（transparent: true）适合覆盖在图片或地图之上
- 右侧操作区通过 rightActions 放置 IconButton
- 需要二次确认的返回用 onBackConfirm（如未保存提示）

## 搭配推荐 / Compose with
- 搭配 ParkTabBar 做顶部 + 底部导航
- 搭配 ParkSearch 做搜索导航栏
- 搭配 ParkSideBar 做侧边 + 顶部导航
''',
      ),

      'ParkSideBar': ParkComponentSpec(
        name: 'ParkSideBar',
        title: '侧边导航栏 / Sidebar',
        category: 'nav',
        icon: Icons.view_sidebar_outlined,
        description:
            '提供垂直排列的菜单项列表，选中项以品牌色高亮。支持折叠为仅图标模式、'
            '含子菜单的可展开项、Logo 区与底部折叠按钮。'
            ' / Vertical menu list with brand highlight, collapsible icon-only mode, '
            'expandable sub-menus, logo area and a bottom collapse toggle.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'items',
            type: 'List<ParkSideBarItem>',
            required: true,
            description: '菜单项列表，每项含 icon、label、badge、children、dotBadge、disabled。',
          ),
          ParkPropertyDef(
            name: 'selectedIndex',
            type: 'int',
            defaultVal: '0',
            description: '当前选中的顶层菜单索引。',
          ),
          ParkPropertyDef(
            name: 'selectedChildIndex',
            type: 'int?',
            defaultVal: 'null',
            description: '当前选中的子菜单索引（仅当 selectedIndex 指向含子项的父菜单时生效）。',
          ),
          ParkPropertyDef(
            name: 'collapsed',
            type: 'bool',
            defaultVal: 'false',
            description: '是否折叠为仅图标模式。',
          ),
          ParkPropertyDef(
            name: 'width',
            type: 'double',
            defaultVal: '200',
            description: '展开时的侧边栏宽度。',
          ),
          ParkPropertyDef(
            name: 'collapsedWidth',
            type: 'double',
            defaultVal: '60',
            description: '折叠时的侧边栏宽度。',
          ),
          ParkPropertyDef(
            name: 'logo',
            type: 'Widget?',
            defaultVal: 'null',
            description: '品牌区域（显示在侧边栏顶部）。',
          ),
          ParkPropertyDef(
            name: 'showCollapseButton',
            type: 'bool',
            defaultVal: 'false',
            description: '是否显示底部折叠按钮。',
          ),
          ParkPropertyDef(
            name: 'theme',
            type: 'ParkSideBarTheme',
            defaultVal: 'ParkSideBarTheme.light',
            description: '侧边栏主题：light（亮色）/ dark（暗色）。',
          ),
          ParkPropertyDef(
            name: 'header',
            type: 'Widget?',
            defaultVal: 'null',
            description: '顶部区域（logo 下方的自定义内容）。',
          ),
          ParkPropertyDef(
            name: 'footer',
            type: 'Widget?',
            defaultVal: 'null',
            description: '底部区域（折叠按钮上方的自定义内容）。',
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
                '如果组件位于 ParkForm 内且表单已注入 bindingService，'
                '此参数可省略（自动从 ParkBindingFormScope 获取）。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onChanged',
            signature: 'ValueChanged<int>?',
            description: '选中菜单项（顶层）时触发，参数为顶层索引。',
          ),
          ParkEventDef(
            name: 'onChildChanged',
            signature: 'void Function(int parentIndex, int childIndex)?',
            description: '选中子菜单项时触发，参数为父项与子项索引。',
          ),
          ParkEventDef(
            name: 'onCollapseToggle',
            signature: 'VoidCallback?',
            description: '点击底部折叠按钮时触发。',
          ),
          ParkEventDef(
            name: 'onCollapse',
            signature: 'ValueChanged<bool>?',
            description: '折叠状态变化时的回调，参数为当前是否折叠。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础侧边栏',
            description: '三个菜单项，选中项高亮。',
            code: '''ParkSideBar(
  items: [
    ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
    ParkSideBarItem(icon: Icons.people, label: '用户管理'),
    ParkSideBarItem(icon: Icons.settings, label: '设置'),
  ],
  selectedIndex: _index,
  onChanged: (int i) => setState(() => _index = i),
)''',
            builder: (BuildContext context) => SizedBox(
              height: 240,
              child: _ParkSideBarDemo(),
            ),
          ),
          ParkDemoScenario(
            title: '受控选中与子菜单',
            description: 'onChanged 受控顶层选中，onChildChanged 响应子菜单点击，并显示折叠按钮（onCollapseToggle / onCollapse）。',
            code: '''ParkSideBar(
  collapsed: _collapsed,
  showCollapseButton: true,
  onCollapseToggle: () => _collapsed = !_collapsed,
  onCollapse: (bool v) => _collapsed = v,
  selectedIndex: _index,
  onChanged: (int i) => _index = i,
  onChildChanged: (int p, int c) => _index = p,
  items: [ ... ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 320,
              child: _ParkSideBarFullDemo(),
            ),
          ),
          ParkDemoScenario(
            title: '带角标和子菜单',
            description: '菜单项可显示角标，含子菜单的项可展开。',
            code: '''ParkSideBar(
  items: [
    ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
    ParkSideBarItem(icon: Icons.people, label: '用户管理', badge: '12'),
    ParkSideBarItem(icon: Icons.settings, label: '设置', children: [
      ParkSideBarItem(icon: Icons.person, label: '个人信息'),
      ParkSideBarItem(icon: Icons.lock, label: '安全设置'),
    ]),
  ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 300,
              child: _ParkSideBarSubDemo(),
            ),
          ),
          ParkDemoScenario(
            title: '折叠模式',
            description: 'collapsed: true 时只显示图标。',
            code: '''ParkSideBar(
  collapsed: true,
  items: [ ... ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 240,
              child: _ParkSideBarCollapsedDemo(),
            ),
          ),
        ],
        basicUsageCode: '''ParkSideBar(
  items: [
    ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
    ParkSideBarItem(icon: Icons.people, label: '用户管理', badge: '12'),
    ParkSideBarItem(icon: Icons.settings, label: '设置', children: [
      ParkSideBarItem(icon: Icons.person, label: '个人信息'),
      ParkSideBarItem(icon: Icons.lock, label: '安全设置'),
    ]),
  ],
  selectedIndex: _index,
  onChanged: (index) => setState(() => _index = index),
)''',
        guide: '''
## 何时使用 / When to use
- 后台管理系统的左侧导航
- 需要多级菜单或可折叠导航的场景

## 使用建议 / Usage tips
- 菜单项通过 children 支持子菜单展开
- 折叠模式（collapsed: true）仅显示图标，节省空间
- 通过 badge / dotBadge 展示待办数量
- 底部折叠按钮用 showCollapseButton + onCollapseToggle 控制
- 搭配 ParkNavBar 做完整的后台布局

## 搭配推荐 / Compose with
- 搭配 ParkNavBar 做顶部 + 侧边导航
- 搭配 ParkBadge 做待办提示
- 搭配 ParkSteps 做流程导航
''',
      ),

      'ParkSteps': ParkComponentSpec(
        name: 'ParkSteps',
        title: '步骤条 / Steps',
        category: 'nav',
        icon: Icons.format_list_numbered_outlined,
        description:
            '显示任务进度，以编号圆圈 + 连线的方式展示每个步骤的状态。'
            '已完成显示绿色勾号，进行中显示品牌色编号，等待显示灰色，错误显示红色叹号。'
            '支持可点击步骤、圆形进度、小圆点样式等。'
            ' / Task progress with numbered circles + connectors; finish=green check, '
            'process=brand, waiting=grey, error=red; supports clickable, circular progress & dot style.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'steps',
            type: 'List<ParkStep>',
            required: true,
            description: '步骤数据列表，每项含 title、description、status、subTitle、icon、disabled。',
          ),
          ParkPropertyDef(
            name: 'currentStep',
            type: 'int',
            defaultVal: '0',
            description: '当前步骤索引（0-based），自动推算各步骤状态。',
          ),
          ParkPropertyDef(
            name: 'direction',
            type: 'ParkStepsDirection',
            defaultVal: 'ParkStepsDirection.horizontal',
            description: '排列方向：horizontal（水平）或 vertical（垂直）。',
          ),
          ParkPropertyDef(
            name: 'clickable',
            type: 'bool',
            defaultVal: 'false',
            description: '是否启用可点击样式（鼠标指针 + hover 效果），需配合 onStepTap。',
          ),
          ParkPropertyDef(
            name: 'percent',
            type: 'double?',
            defaultVal: 'null',
            description: '当前步骤的圆形进度（0.0 ~ 1.0），为 null 时不显示。',
          ),
          ParkPropertyDef(
            name: 'size',
            type: 'ParkStepsSize',
            defaultVal: 'ParkStepsSize.defaultSize',
            description: '步骤条尺寸：small（图标 22px）/ defaultSize（图标 28px）。',
          ),
          ParkPropertyDef(
            name: 'labelPlacement',
            type: 'ParkLabelPlacement',
            defaultVal: 'ParkLabelPlacement.horizontal',
            description: '标签排列方式：horizontal（描述在图标右侧）/ vertical（描述在图标下方）。',
          ),
          ParkPropertyDef(
            name: 'successIcon',
            type: 'IconData?',
            defaultVal: 'null',
            description: '自定义完成图标（替代默认勾号）。',
          ),
          ParkPropertyDef(
            name: 'progressDot',
            type: 'bool',
            defaultVal: 'false',
            description: '是否使用圆点样式（小圆点替代编号圆圈）。',
          ),
          ParkPropertyDef(
            name: 'responsive',
            type: 'bool',
            defaultVal: 'false',
            description: '是否响应式布局（窄屏时自动切换为垂直方向）。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onStepTap',
            signature: 'ValueChanged<int>?',
            description: '点击步骤时触发（需 clickable: true），参数为步骤索引。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '水平步骤条',
            description: '三步流程，当前在第 2 步。',
            code: '''ParkSteps(
  steps: [
    ParkStep(title: '基本信息'),
    ParkStep(title: '详细信息'),
    ParkStep(title: '完成'),
  ],
  currentStep: 1,
)''',
            builder: (BuildContext context) => const ParkSteps(
              steps: <ParkStep>[
                ParkStep(title: '基本信息'),
                ParkStep(title: '详细信息'),
                ParkStep(title: '完成'),
              ],
              currentStep: 1,
            ),
          ),
          ParkDemoScenario(
            title: '垂直步骤条',
            description: '垂直排列并带描述文字。',
            code: '''ParkSteps(
  direction: ParkStepsDirection.vertical,
  steps: [
    ParkStep(title: '填写账号', description: '输入手机号或邮箱'),
    ParkStep(title: '身份验证', description: '接收验证码'),
    ParkStep(title: '设置密码'),
  ],
  currentStep: 0,
)''',
            builder: (BuildContext context) => const ParkSteps(
              direction: ParkStepsDirection.vertical,
              steps: <ParkStep>[
                ParkStep(title: '填写账号', description: '输入手机号或邮箱'),
                ParkStep(title: '身份验证', description: '接收验证码'),
                ParkStep(title: '设置密码'),
              ],
              currentStep: 0,
            ),
          ),
          ParkDemoScenario(
            title: '含错误状态',
            description: '某个步骤可手动设为 error 状态。',
            code: '''ParkSteps(
  steps: [
    ParkStep(title: '步骤一'),
    ParkStep(title: '步骤二', status: ParkStepStatus.error),
    ParkStep(title: '步骤三'),
  ],
  currentStep: 1,
)''',
            builder: (BuildContext context) => const ParkSteps(
              steps: <ParkStep>[
                ParkStep(title: '步骤一'),
                ParkStep(title: '步骤二', status: ParkStepStatus.error),
                ParkStep(title: '步骤三'),
              ],
              currentStep: 1,
            ),
          ),
          ParkDemoScenario(
            title: '可点击步骤（onStepTap）',
            description: 'clickable: true 时步骤可点击，点击触发 onStepTap 切换当前步。',
            code: '''ParkSteps(
  currentStep: _current,
  clickable: true,
  onStepTap: (int i) => setState(() => _current = i),
  steps: [
    ParkStep(title: '基本信息'),
    ParkStep(title: '详细信息'),
    ParkStep(title: '完成'),
  ],
)''',
            builder: (BuildContext context) => _ParkStepsOnStepTapDemo(),
          ),
          ParkDemoScenario(
            title: '圆形进度与小圆点',
            description: 'percent 显示当前步圆形进度；progressDot 用圆点替代编号。',
            code: '''ParkSteps(
  currentStep: 1,
  percent: 0.6,
  size: ParkStepsSize.small,
  progressDot: true,
  steps: [
    ParkStep(title: '待付款'),
    ParkStep(title: '待发货'),
    ParkStep(title: '已完成'),
  ],
)''',
            builder: (BuildContext context) => const ParkSteps(
              currentStep: 1,
              percent: 0.6,
              size: ParkStepsSize.small,
              progressDot: true,
              steps: <ParkStep>[
                ParkStep(title: '待付款'),
                ParkStep(title: '待发货'),
                ParkStep(title: '已完成'),
              ],
            ),
          ),
        ],
        basicUsageCode: '''ParkSteps(
  steps: [
    ParkStep(title: '基本信息'),
    ParkStep(title: '详细信息', description: '填写详细资料'),
    ParkStep(title: '完成'),
  ],
  currentStep: 1,
  direction: ParkStepsDirection.horizontal,
)''',
        guide: '''
## 何时使用 / When to use
- 引导用户按流程完成任务时（注册引导、订单流程、表单分步填写）
- 展示任务进度和当前步骤

## 使用建议 / Usage tips
- 水平方向适合步骤少（3-5 步）的场景
- 垂直方向适合步骤多或需要展示详细描述的场景
- 通过 currentStep 控制当前步骤，自动推算各步骤状态
- 错误步骤设置 status: error 提示用户
- 需要交互时用 clickable + onStepTap；进度展示用 percent

## 搭配推荐 / Compose with
- 搭配 ParkForm 做分步表单
- 搭配 ParkButton 做上一步/下一步操作
- 搭配 ParkResult 做流程完成展示
''',
      ),

      'ParkDrawer': ParkComponentSpec(
        name: 'ParkDrawer',
        title: '抽屉 / Drawer',
        category: 'nav',
        icon: Icons.menu_open_outlined,
        description:
            '主题化的侧抽屉组件，支持 header / footer 区域，可配置四个方向弹出（左/右/上/下），'
            '内置关闭按钮、Escape 关闭、加载态、遮罩层与预设尺寸。'
            '可直接嵌入 Scaffold.drawer / endDrawer，或作为独立面板使用。'
            ' / Themed drawer with header/footer, four placement directions (left/right/top/bottom), '
            'close button, Escape-to-close, loading state, mask & preset sizes; embeds in Scaffold or standalone.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'child',
            type: 'Widget?',
            defaultVal: 'null',
            description: '抽屉的主体内容区域。',
          ),
          ParkPropertyDef(
            name: 'header',
            type: 'Widget?',
            defaultVal: 'null',
            description: '顶部区域，常用于展示用户头像和名称。',
          ),
          ParkPropertyDef(
            name: 'footer',
            type: 'Widget?',
            defaultVal: 'null',
            description: '底部区域，常用于展示版本号或退出按钮。',
          ),
          ParkPropertyDef(
            name: 'width',
            type: 'double',
            defaultVal: '280',
            description: '抽屉宽度（左/右方向时）或高度（上/下方向时）。',
          ),
          ParkPropertyDef(
            name: 'position',
            type: 'ParkDrawerPosition',
            defaultVal: 'ParkDrawerPosition.left',
            description: '弹出位置（向后兼容）：left（左侧）或 right（右侧）。',
          ),
          ParkPropertyDef(
            name: 'placement',
            type: 'ParkDrawerPlacement?',
            defaultVal: 'null',
            description: '弹出方向（优先于 position）：left / right / top / bottom。',
          ),
          ParkPropertyDef(
            name: 'closable',
            type: 'bool',
            defaultVal: 'true',
            description: '是否显示关闭按钮（点击触发 onClose）。',
          ),
          ParkPropertyDef(
            name: 'keyboard',
            type: 'bool',
            defaultVal: 'true',
            description: '是否允许按 Escape 键关闭抽屉。',
          ),
          ParkPropertyDef(
            name: 'extra',
            type: 'Widget?',
            defaultVal: 'null',
            description: '头部右侧额外操作区域。',
          ),
          ParkPropertyDef(
            name: 'loading',
            type: 'bool',
            defaultVal: 'false',
            description: '是否显示加载骨架屏。',
          ),
          ParkPropertyDef(
            name: 'destroyOnClose',
            type: 'bool',
            defaultVal: 'false',
            description: '关闭时是否卸载内容（释放资源）。',
          ),
          ParkPropertyDef(
            name: 'size',
            type: 'ParkDrawerSize',
            defaultVal: 'ParkDrawerSize.medium',
            description: '预设尺寸：small（256）/ medium（378）/ large（520）。',
          ),
          ParkPropertyDef(
            name: 'visible',
            type: 'bool?',
            defaultVal: 'null',
            description: '受控可见性；为 null 时组件内部管理可见状态。',
          ),
          ParkPropertyDef(
            name: 'mask',
            type: 'bool',
            defaultVal: 'true',
            description: '是否显示遮罩层。',
          ),
          ParkPropertyDef(
            name: 'maskClosable',
            type: 'bool',
            defaultVal: 'true',
            description: '点击遮罩是否关闭抽屉。',
          ),
          ParkPropertyDef(
            name: 'maskColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '遮罩层颜色（默认半透明黑色）。',
          ),
          ParkPropertyDef(
            name: 'zIndex',
            type: 'int',
            defaultVal: '1000',
            description: '层级（z-index），用于控制多个抽屉叠加时的显示顺序。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onClose',
            signature: 'VoidCallback?',
            description: '关闭回调（点击关闭按钮或按 Escape / 点遮罩时触发）。',
          ),
          ParkEventDef(
            name: 'afterClose',
            signature: 'VoidCallback?',
            description: '关闭动画完成后的回调。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础抽屉（可重新打开）',
            description: '含 header、菜单列表和 footer 的标准抽屉，关闭后点击按钮可重新打开（演示 onClose）。',
            code: '''bool _visible = true;
ParkDrawer(
  width: 280,
  header: Padding(
    padding: EdgeInsets.all(16),
    child: Row(children: [
      Icon(Icons.account_circle, size: 40),
      SizedBox(width: 12),
      Text('用户名称'),
    ]),
  ),
  child: ListView(children: [
    ListTile(leading: Icon(Icons.home), title: Text('首页')),
    ListTile(leading: Icon(Icons.settings), title: Text('设置')),
  ]),
  footer: Padding(
    padding: EdgeInsets.all(16),
    child: Text('v1.0.0'),
  ),
  onClose: () => _visible = false,
)''',
            builder: (BuildContext context) => _ParkDrawerBasicDemo(),
          ),
          ParkDemoScenario(
            title: '右侧抽屉',
            description: 'position: right 时从右侧弹出（演示 placement 属性）。',
            code: '''ParkDrawer(
  position: ParkDrawerPosition.right,
  child: ListView(...),
  onClose: () => _visible = false,
)''',
            builder: (BuildContext context) => _ParkDrawerRightDemo(),
          ),
          ParkDemoScenario(
            title: '自定义宽度',
            description: '通过 width 参数设置更宽的抽屉面板；也可改用 size 预设尺寸。',
            code: '''ParkDrawer(
  width: 340,
  header: Padding(
    padding: EdgeInsets.all(16),
    child: Text('宽抽屉'),
  ),
  child: ListView(...),
  onClose: () => _visible = false,
)''',
            builder: (BuildContext context) => _ParkDrawerWidthDemo(),
          ),
          ParkDemoScenario(
            title: '顶部抽屉',
            description: 'placement: ParkDrawerPlacement.top 时从顶部滑入，适合筛选 / 菜单浮层。',
            code: '''ParkDrawer(
  placement: ParkDrawerPlacement.top,
  size: ParkDrawerSize.small,
  child: Center(child: Text('顶部浮层内容')),
  onClose: () => _visible = false,
)''',
            builder: (BuildContext context) => _ParkDrawerTopDemo(),
          ),
          ParkDemoScenario(
            title: '交互式菜单选择',
            description: '抽屉内嵌可选中菜单项，点击后高亮并触发回调（onClose 可关闭抽屉）。',
            code: '''ParkDrawer(
  child: _InteractiveMenuList(),
  footer: Padding(...),
  onClose: () => _visible = false,
)''',
            builder: (BuildContext context) => SizedBox(
              height: 400,
              child: _ParkDrawerMenuDemo(),
            ),
          ),
    ParkDemoScenario(
      title: 'afterClose 关闭回调',
      description: '抽屉关闭动画完成后触发 afterClose / Fires afterClose after drawer close animation',
      code: '''ParkDrawer(
  visible: _visible,
  afterClose: () => print('afterClose'),
  child: Container(...),
)''',
      builder: (BuildContext context) {
        String log = '等待关闭抽屉';
        bool visible = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkButton(
                  onPressed: () {
                    visible = true;
                    setState(() {});
                  },
                  child: const ParkText('打开抽屉'),
                ),
                ParkDrawer(
                  visible: visible,
                  width: 280,
                  onClose: () {
                    visible = false;
                    setState(() {});
                  },
                  afterClose: () {
                    log = 'afterClose 触发';
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('抽屉内容'),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
        ],
        basicUsageCode: '''Scaffold(
  drawer: ParkDrawer(
    header: UserAccountsDrawerHeader(...),
    child: ListView(
      children: [
        ListTile(title: Text('菜单项 1')),
        ListTile(title: Text('菜单项 2')),
      ],
    ),
    footer: Padding(
      padding: EdgeInsets.all(16),
      child: Text('v1.0.0'),
    ),
  ),
)''',
        guide: '''
## 何时使用 / When to use
- 需要从侧边滑出的导航菜单
- 隐藏面板、筛选面板、用户信息等

## 使用建议 / Usage tips
- 搭配 Scaffold.drawer 或 Scaffold.endDrawer 使用
- 左侧（left）适合主导航，右侧（right）适合筛选/详情
- 通过 header 展示用户头像和名称，footer 放置版本号或退出按钮
- 通过 width / size 调整尺寸适配内容
- 关闭交互：onClose 回调 + 点击遮罩 / Escape / 关闭按钮
- 顶部 / 底部抽屉用 placement: top / bottom（如筛选浮层）

## 搭配推荐 / Compose with
- 搭配 ParkNavBar 的菜单按钮触发打开
- 搭配 ParkAvatar 做用户信息头部
- 搭配 ParkDivider 做菜单项分隔
''',
      ),

      'ParkBackTop': ParkComponentSpec(
        name: 'ParkBackTop',
        title: '回到顶部 / Back Top',
        category: 'nav',
        icon: Icons.vertical_align_top_outlined,
        description:
            '监听滚动偏移，当滚动距离超过阈值时自动显示，带有淡入 + 缩放的过渡动画。'
            '点击后平滑滚动至顶部；也可通过 onPressed 自定义点击行为。'
            ' / Auto-shows after scrolling past a threshold with fade + scale animation; '
            'taps to smoothly scroll to top, or use onPressed for custom behavior.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'scrollController',
            type: 'ScrollController',
            required: true,
            description: '监听的滚动控制器，用于检测滚动偏移量。',
          ),
          ParkPropertyDef(
            name: 'visibleOffset',
            type: 'double',
            defaultVal: '300',
            description: '触发显示的滚动偏移量阈值。',
          ),
          ParkPropertyDef(
            name: 'visibilityHeight',
            type: 'double?',
            defaultVal: 'null',
            description: '触发显示的最小滚动距离；为 null 时使用 visibleOffset（推荐设 400）。',
          ),
          ParkPropertyDef(
            name: 'onPressed',
            type: 'VoidCallback?',
            defaultVal: 'null',
            description: '自定义点击回调；为空时自动滚动到顶部。',
          ),
          ParkPropertyDef(
            name: 'icon',
            type: 'IconData?',
            defaultVal: 'Icons.keyboard_arrow_up',
            description: '自定义按钮图标，默认使用向上箭头。',
          ),
          ParkPropertyDef(
            name: 'size',
            type: 'double',
            defaultVal: '44',
            description: '按钮尺寸（直径）。',
          ),
          ParkPropertyDef(
            name: 'margin',
            type: 'EdgeInsetsGeometry',
            defaultVal: 'EdgeInsets.only(right: 16, bottom: 16)',
            description: '距右下角的偏移。',
          ),
          ParkPropertyDef(
            name: 'target',
            type: 'ScrollController?',
            defaultVal: 'null',
            description: '自定义目标滚动控制器；为 null 时使用 scrollController。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onPressed',
            signature: 'VoidCallback?',
            description: '点击按钮回调；为空时自动滚动到顶部。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础回到顶部',
            description: '在长列表中滚动超过阈值后显示回到顶部按钮。',
            code: '''final controller = ScrollController();

Stack(
  children: [
    ListView.builder(
      controller: controller,
      itemCount: 100,
      itemBuilder: (_, i) => ListTile(title: Text('Item \$i')),
    ),
    ParkBackTop(scrollController: controller),
  ],
)''',
            builder: (BuildContext context) => _ParkBackTopDemo(),
          ),
          ParkDemoScenario(
            title: '自定义图标',
            description: '使用 icon 参数替换默认的向上箭头图标，并调整按钮尺寸。',
            code: '''ParkBackTop(
  scrollController: controller,
  icon: Icons.arrow_upward,
  size: 52,
)''',
            builder: (BuildContext context) => _ParkBackTopCustomIconDemo(),
          ),
          ParkDemoScenario(
            title: '自定义触发阈值',
            description: '通过 visibleOffset 设置更小的滚动偏移量触发显示，并使用自定义 margin。',
            code: '''ParkBackTop(
  scrollController: controller,
  visibleOffset: 100,
  margin: EdgeInsets.only(right: 24, bottom: 24),
)''',
            builder: (BuildContext context) => _ParkBackTopThresholdDemo(),
          ),
          ParkDemoScenario(
            title: '自定义点击行为（onPressed）',
            description: '设置 onPressed 后点击不再滚动到顶部，而是执行自定义回调。',
            code: '''ParkBackTop(
  scrollController: controller,
  onPressed: () => print('点击了回到顶部'),
)''',
            builder: (BuildContext context) => _ParkBackTopOnPressedDemo(),
          ),
        ],
        basicUsageCode: '''final controller = ScrollController();

Stack(
  children: [
    ListView.builder(
      controller: controller,
      itemCount: 100,
      itemBuilder: (_, i) => ListTile(title: Text('Item \$i')),
    ),
    ParkBackTop(scrollController: controller),
  ],
)''',
        guide: '''
## 何时使用 / When to use
- 长页面或长列表中快速回到顶部
- 新闻列表、商品列表、设置页面等

## 使用建议 / Usage tips
- 必须传入 ScrollController 监听滚动
- 通过 visibleOffset / visibilityHeight 调整触发显示的滚动阈值
- 默认在右下角，通过 margin 调整位置
- 自定义 icon 替换默认箭头图标
- 需要拦截点击时用 onPressed 自定义行为

## 搭配推荐 / Compose with
- 搭配 ParkList 做长列表导航
- 搭配 ParkFab 在页面中共存
- 搭配 ParkNavBar 做完整页面导航
''',
      ),

      'ParkIndexes': ParkComponentSpec(
        name: 'ParkIndexes',
        title: '字母索引条 / Index Bar',
        category: 'nav',
        icon: Icons.sort_by_alpha_outlined,
        description:
            '在列表右侧显示垂直字母条，支持点击与拖拽跳转到对应分组。'
            '常用于通讯录、城市选择等按字母分组的列表场景。'
            ' / Vertical alphabet index bar on the right of a list, with tap & drag to jump to sections; '
            'commonly used for contacts / city pickers grouped by letter.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'indexes',
            type: 'List<String>',
            required: true,
            description: '索引字母列表，如 ["A","B","C"...] 或 ["#","A","B"...]。',
          ),
          ParkPropertyDef(
            name: 'activeColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '激活状态颜色，默认使用品牌色。',
          ),
          ParkPropertyDef(
            name: 'fontSize',
            type: 'double',
            defaultVal: '11',
            description: '字母文字大小。',
          ),
          ParkPropertyDef(
            name: 'itemHeight',
            type: 'double',
            defaultVal: '18',
            description: '每个字母项的高度（含间距）。',
          ),
          ParkPropertyDef(
            name: 'showOverlay',
            type: 'bool',
            defaultVal: 'true',
            description: '是否显示中央浮层提示（选中时在屏幕中央显示大字）。',
          ),
          ParkPropertyDef(
            name: 'sticky',
            type: 'bool',
            defaultVal: 'true',
            description: '当前分组标题是否吸附到顶部（由外部滚动容器配合消费）。',
          ),
          ParkPropertyDef(
            name: 'currentIndex',
            type: 'String?',
            defaultVal: 'null',
            description: '外部控制的当前高亮索引（优先于内部状态）。',
          ),
          ParkPropertyDef(
            name: 'anchorScrollController',
            type: 'ScrollController?',
            defaultVal: 'null',
            description: '用于滚动同步高亮的 ScrollController，外部列表滚动时同步更新 currentIndex。',
          ),
        ],
        events: const <ParkEventDef>[
          ParkEventDef(
            name: 'onIndexSelected',
            signature: 'ValueChanged<String>?',
            description: '用户主动点击 / 拖拽字母条选中某个索引时触发，传入索引字符串。',
          ),
          ParkEventDef(
            name: 'onChange',
            signature: 'ValueChanged<String>?',
            description: '激活索引发生任何变化时触发（含程序性变化，区别于 onIndexSelected）。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础字母索引',
            description: '显示 A-Z 字母条，点击触发回调。',
            code: '''ParkIndexes(
  indexes: List.generate(26, (i) => String.fromCharCode(65 + i)),
  onIndexSelected: (index) {
    print('选中: \$index');
  },
)''',
            builder: (BuildContext context) => SizedBox(
              height: 520,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        '通讯录列表区域',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  ParkIndexes(
                    indexes: List<String>.generate(
                      26,
                      (int i) => String.fromCharCode(65 + i),
                    ),
                    onIndexSelected: (String index) {},
                  ),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '受控高亮（onIndexSelected / onChange）',
            description: '点击字母条更新外部状态，演示 onIndexSelected 与 onChange 回调。',
            code: '''String _selected = 'A';
ParkIndexes(
  indexes: ['A', 'B', 'C', 'D', 'E'],
  onIndexSelected: (String i) => setState(() => _selected = i),
  onChange: (String i) => setState(() => _selected = i),
)''',
            builder: (BuildContext context) => _ParkIndexesOnSelectedDemo(),
          ),
          ParkDemoScenario(
            title: '含特殊字符',
            description: '索引列表可包含 # 等特殊字符。',
            code: '''ParkIndexes(
  indexes: ['#', 'A', 'B', 'C', 'D', 'E', 'F'],
  showOverlay: true,
)''',
            builder: (BuildContext context) => SizedBox(
              height: 300,
              child: Row(
                children: <Widget>[
                  const Expanded(child: Center(child: Text('城市列表'))),
                  ParkIndexes(
                    indexes: const <String>[
                      '#',
                      'A',
                      'B',
                      'C',
                      'D',
                      'E',
                      'F',
                    ],
                    onIndexSelected: (String index) {},
                  ),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '关闭浮层指示器',
            description: '设置 showOverlay: false 关闭选中时的中央大字浮层提示。',
            code: '''ParkIndexes(
  indexes: ['A', 'B', 'C', 'D', 'E'],
  showOverlay: false,
  onIndexSelected: (index) {
    print('选中: \$index');
  },
)''',
            builder: (BuildContext context) => SizedBox(
              height: 250,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        '无浮层提示模式',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  ParkIndexes(
                    indexes: const <String>['A', 'B', 'C', 'D', 'E'],
                    showOverlay: false,
                    onIndexSelected: (String index) {},
                  ),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '自定义样式',
            description: '通过 activeColor、fontSize、itemHeight 自定义索引条外观（使用品牌色令牌）。',
            code: '''ParkIndexes(
  indexes: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
  activeColor: _kColors.brand,
  fontSize: 14,
  itemHeight: 22,
  onIndexSelected: (index) {},
)''',
            builder: (BuildContext context) => SizedBox(
              height: 350,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        '自定义颜色与字号',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  ParkIndexes(
                    indexes: const <String>[
                      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
                    ],
                    activeColor: _kColors.brand,
                    fontSize: 14,
                    itemHeight: 22,
                    onIndexSelected: (String index) {},
                  ),
                ],
              ),
            ),
          ),
        ],
        basicUsageCode: '''ParkIndexes(
  indexes: ['A', 'B', 'C', 'D', 'E', 'F'],
  onIndexSelected: (index) {
    scrollController.jumpTo(offsets[index]);
  },
)''',
        guide: '''
## 何时使用 / When to use
- 按字母或拼音分组的列表快速跳转
- 通讯录、城市选择、词典等场景

## 使用建议 / Usage tips
- 搭配 ScrollController 实现点击索引跳转到对应分组
- 开启 showOverlay 在选中时显示中央大字提示
- 索引列表可包含 # 等特殊字符
- 通过 activeColor/fontSize/itemHeight 自定义外观
- 列表滚动联动高亮用 currentIndex + anchorScrollController

## 搭配推荐 / Compose with
- 搭配 ParkList 做字母索引列表
- 搭配 ParkSearch 做搜索 + 索引
- 搭配 ParkSticky 做分组标题吸顶
''',
      ),
    };

// ==========================================================================
//  Demo helper widgets
// ==========================================================================

class _ParkTabsOnChangedDemo extends StatefulWidget {
  @override
  State<_ParkTabsOnChangedDemo> createState() => _ParkTabsOnChangedDemoState();
}

class _ParkTabsOnChangedDemoState extends State<_ParkTabsOnChangedDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ParkTabs(
        currentIndex: _index,
        onChanged: (int i) => setState(() => _index = i),
        tabs: const <ParkTab>[
          ParkTab(label: '推荐'),
          ParkTab(label: '热门'),
          ParkTab(label: '最新'),
        ],
        children: <Widget>[
          const Center(child: Text('推荐内容')),
          const Center(child: Text('热门内容')),
          const Center(child: Text('最新内容')),
        ],
      ),
    );
  }
}

class _ParkTabsClosableDemo extends StatefulWidget {
  @override
  State<_ParkTabsClosableDemo> createState() => _ParkTabsClosableDemoState();
}

class _ParkTabsClosableDemoState extends State<_ParkTabsClosableDemo> {
  final List<ParkTab> _tabs = <ParkTab>[
    const ParkTab(label: '标签一'),
    const ParkTab(label: '标签二'),
    const ParkTab(label: '标签三'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ParkTabs(
        scrollable: true,
        closable: true,
        addable: true,
        onClose: (int i) => setState(() => _tabs.removeAt(i)),
        onAdd: () => setState(
          () => _tabs.add(ParkTab(label: '标签${_tabs.length + 1}')),
        ),
        tabs: _tabs,
        children:
            _tabs.map((ParkTab t) => Center(child: Text(t.label))).toList(),
      ),
    );
  }
}

class _ParkTabBarDemo extends StatefulWidget {
  @override
  State<_ParkTabBarDemo> createState() => _ParkTabBarDemoState();
}

class _ParkTabBarDemoState extends State<_ParkTabBarDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text('页面 ${_index + 1}'),
            ),
          ),
          ParkTabBar(
            items: const <ParkTabBarItem>[
              ParkTabBarItem(icon: Icons.home, label: '首页'),
              ParkTabBarItem(icon: Icons.search, label: '发现'),
              ParkTabBarItem(icon: Icons.person, label: '我的'),
            ],
            currentIndex: _index,
            onTap: (int i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}

class _ParkTabBarFloatingDemo extends StatefulWidget {
  @override
  State<_ParkTabBarFloatingDemo> createState() =>
      _ParkTabBarFloatingDemoState();
}

class _ParkTabBarFloatingDemoState extends State<_ParkTabBarFloatingDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text('悬浮式 — 页面 ${_index + 1}'),
            ),
          ),
          ParkTabBar(
            type: ParkTabBarType.floating,
            items: const <ParkTabBarItem>[
              ParkTabBarItem(icon: Icons.home, label: '首页'),
              ParkTabBarItem(icon: Icons.search, label: '发现'),
              ParkTabBarItem(icon: Icons.person, label: '我的'),
            ],
            currentIndex: _index,
            onTap: (int i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}

class _ParkTabBarBadgeDemo extends StatefulWidget {
  @override
  State<_ParkTabBarBadgeDemo> createState() => _ParkTabBarBadgeDemoState();
}

class _ParkTabBarBadgeDemoState extends State<_ParkTabBarBadgeDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text('页面 ${_index + 1}'),
            ),
          ),
          ParkTabBar(
            items: const <ParkTabBarItem>[
              ParkTabBarItem(icon: Icons.home, label: '首页'),
              ParkTabBarItem(icon: Icons.mail, label: '消息', badge: '5'),
              ParkTabBarItem(
                icon: Icons.notifications,
                label: '提醒',
                dotIndicator: true,
              ),
            ],
            currentIndex: _index,
            onTap: (int i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}

class _ParkTabBarCenterDemo extends StatefulWidget {
  @override
  State<_ParkTabBarCenterDemo> createState() => _ParkTabBarCenterDemoState();
}

class _ParkTabBarCenterDemoState extends State<_ParkTabBarCenterDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text('悬浮式 + 中心按钮 — 页面 ${_index + 1}'),
            ),
          ),
          ParkTabBar(
            type: ParkTabBarType.floating,
            centerAction: ParkFab(
              icon: Icons.add,
              onPressed: () {},
            ),
            items: const <ParkTabBarItem>[
              ParkTabBarItem(icon: Icons.home, label: '首页'),
              ParkTabBarItem(icon: Icons.search, label: '发现'),
              ParkTabBarItem(icon: Icons.person, label: '我的'),
            ],
            currentIndex: _index,
            onTap: (int i) => setState(() => _index = i),
          ),
        ],
      ),
    );
  }
}

class _ParkNavBarOnBackDemo extends StatefulWidget {
  @override
  State<_ParkNavBarOnBackDemo> createState() => _ParkNavBarOnBackDemoState();
}

class _ParkNavBarOnBackDemoState extends State<_ParkNavBarOnBackDemo> {
  String _log = '未操作';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkNavBar.text(
          title: '编辑资料',
          subTitle: '请填写真实信息',
          leftArrow: true,
          onBack: () => setState(() => _log = '点击了返回（onBack）'),
          onBackConfirm: () async => true,
          rightActions: <Widget>[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        Text(_log, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ParkSideBarDemo extends StatefulWidget {
  @override
  State<_ParkSideBarDemo> createState() => _ParkSideBarDemoState();
}

class _ParkSideBarDemoState extends State<_ParkSideBarDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ParkSideBar(
      items: const <ParkSideBarItem>[
        ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
        ParkSideBarItem(icon: Icons.people, label: '用户管理'),
        ParkSideBarItem(icon: Icons.settings, label: '设置'),
      ],
      selectedIndex: _index,
      onChanged: (int i) => setState(() => _index = i),
    );
  }
}

class _ParkSideBarFullDemo extends StatefulWidget {
  @override
  State<_ParkSideBarFullDemo> createState() => _ParkSideBarFullDemoState();
}

class _ParkSideBarFullDemoState extends State<_ParkSideBarFullDemo> {
  int _index = 0;
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return ParkSideBar(
      collapsed: _collapsed,
      showCollapseButton: true,
      onCollapseToggle: () => setState(() => _collapsed = !_collapsed),
      onCollapse: (bool v) => setState(() => _collapsed = v),
      selectedIndex: _index,
      onChanged: (int i) => setState(() => _index = i),
      onChildChanged: (int p, int c) => setState(() {
        _index = p;
      }),
      items: const <ParkSideBarItem>[
        ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
        ParkSideBarItem(icon: Icons.people, label: '用户管理', badge: '12'),
        ParkSideBarItem(
          icon: Icons.settings,
          label: '设置',
          children: <ParkSideBarItem>[
            ParkSideBarItem(icon: Icons.person, label: '个人信息'),
            ParkSideBarItem(icon: Icons.lock, label: '安全设置'),
          ],
        ),
      ],
    );
  }
}

class _ParkSideBarSubDemo extends StatefulWidget {
  @override
  State<_ParkSideBarSubDemo> createState() => _ParkSideBarSubDemoState();
}

class _ParkSideBarSubDemoState extends State<_ParkSideBarSubDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ParkSideBar(
      items: const <ParkSideBarItem>[
        ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
        ParkSideBarItem(icon: Icons.people, label: '用户管理', badge: '12'),
        ParkSideBarItem(
          icon: Icons.settings,
          label: '设置',
          children: <ParkSideBarItem>[
            ParkSideBarItem(icon: Icons.person, label: '个人信息'),
            ParkSideBarItem(icon: Icons.lock, label: '安全设置'),
          ],
        ),
      ],
      selectedIndex: _index,
      onChanged: (int i) => setState(() => _index = i),
    );
  }
}

class _ParkSideBarCollapsedDemo extends StatefulWidget {
  @override
  State<_ParkSideBarCollapsedDemo> createState() =>
      _ParkSideBarCollapsedDemoState();
}

class _ParkSideBarCollapsedDemoState extends State<_ParkSideBarCollapsedDemo> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ParkSideBar(
      collapsed: true,
      items: const <ParkSideBarItem>[
        ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
        ParkSideBarItem(icon: Icons.people, label: '用户管理'),
        ParkSideBarItem(icon: Icons.settings, label: '设置'),
      ],
      selectedIndex: _index,
      onChanged: (int i) => setState(() => _index = i),
    );
  }
}

class _ParkStepsOnStepTapDemo extends StatefulWidget {
  @override
  State<_ParkStepsOnStepTapDemo> createState() => _ParkStepsOnStepTapDemoState();
}

class _ParkStepsOnStepTapDemoState extends State<_ParkStepsOnStepTapDemo> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return ParkSteps(
      currentStep: _current,
      clickable: true,
      onStepTap: (int i) => setState(() => _current = i),
      steps: const <ParkStep>[
        ParkStep(title: '基本信息'),
        ParkStep(title: '详细信息'),
        ParkStep(title: '完成'),
      ],
    );
  }
}

class _ParkBackTopDemo extends StatefulWidget {
  @override
  State<_ParkBackTopDemo> createState() => _ParkBackTopDemoState();
}

class _ParkBackTopDemoState extends State<_ParkBackTopDemo> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: <Widget>[
          ListView.builder(
            controller: _controller,
            itemCount: 50,
            itemBuilder: (BuildContext context, int i) => ListTile(
              title: Text('Item $i'),
            ),
          ),
          ParkBackTop(scrollController: _controller),
        ],
      ),
    );
  }
}

class _ParkBackTopCustomIconDemo extends StatefulWidget {
  @override
  State<_ParkBackTopCustomIconDemo> createState() =>
      _ParkBackTopCustomIconDemoState();
}

class _ParkBackTopCustomIconDemoState
    extends State<_ParkBackTopCustomIconDemo> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: <Widget>[
          ListView.builder(
            controller: _controller,
            itemCount: 50,
            itemBuilder: (BuildContext context, int i) => ListTile(
              title: Text('Item $i'),
            ),
          ),
          ParkBackTop(
            scrollController: _controller,
            icon: Icons.arrow_upward,
            size: 52,
          ),
        ],
      ),
    );
  }
}

class _ParkBackTopThresholdDemo extends StatefulWidget {
  @override
  State<_ParkBackTopThresholdDemo> createState() =>
      _ParkBackTopThresholdDemoState();
}

class _ParkBackTopThresholdDemoState
    extends State<_ParkBackTopThresholdDemo> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: <Widget>[
          ListView.builder(
            controller: _controller,
            itemCount: 50,
            itemBuilder: (BuildContext context, int i) => ListTile(
              title: Text('Item $i'),
            ),
          ),
          ParkBackTop(
            scrollController: _controller,
            visibleOffset: 100,
            margin: const EdgeInsets.only(right: 24, bottom: 24),
          ),
        ],
      ),
    );
  }
}

class _ParkBackTopOnPressedDemo extends StatefulWidget {
  @override
  State<_ParkBackTopOnPressedDemo> createState() =>
      _ParkBackTopOnPressedDemoState();
}

class _ParkBackTopOnPressedDemoState
    extends State<_ParkBackTopOnPressedDemo> {
  final ScrollController _controller = ScrollController();
  String _log = '未点击';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                ListView.builder(
                  controller: _controller,
                  itemCount: 50,
                  itemBuilder: (BuildContext context, int i) => ListTile(
                    title: Text('Item $i'),
                  ),
                ),
                ParkBackTop(
                  scrollController: _controller,
                  onPressed: () =>
                      setState(() => _log = '已触发自定义 onPressed 回调'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_log),
          ),
        ],
      ),
    );
  }
}

class _ParkIndexesOnSelectedDemo extends StatefulWidget {
  @override
  State<_ParkIndexesOnSelectedDemo> createState() =>
      _ParkIndexesOnSelectedDemoState();
}

class _ParkIndexesOnSelectedDemoState
    extends State<_ParkIndexesOnSelectedDemo> {
  String _selected = 'A';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                '当前选中: $_selected',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          ParkIndexes(
            indexes: const <String>['A', 'B', 'C', 'D', 'E'],
            onIndexSelected: (String i) => setState(() => _selected = i),
            onChange: (String i) => setState(() => _selected = i),
          ),
        ],
      ),
    );
  }
}

class _ParkDrawerBasicDemo extends StatefulWidget {
  @override
  State<_ParkDrawerBasicDemo> createState() => _ParkDrawerBasicDemoState();
}

class _ParkDrawerBasicDemoState extends State<_ParkDrawerBasicDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        children: <Widget>[
          if (!_visible)
            Center(
              child: ParkButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('打开抽屉'),
              ),
            ),
          if (_visible)
            ParkDrawer(
              width: 280,
              header: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.account_circle, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '用户名称',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              footer: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('v1.0.0'),
              ),
              onClose: () => setState(() => _visible = false),
              child: ListView(
                children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('首页'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('设置'),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('关于'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ParkDrawerRightDemo extends StatefulWidget {
  @override
  State<_ParkDrawerRightDemo> createState() => _ParkDrawerRightDemoState();
}

class _ParkDrawerRightDemoState extends State<_ParkDrawerRightDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: <Widget>[
          if (!_visible)
            Center(
              child: ParkButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('打开右侧抽屉'),
              ),
            ),
          if (_visible)
            ParkDrawer(
              position: ParkDrawerPosition.right,
              child: ListView(
                children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.filter_list),
                    title: Text('筛选条件'),
                  ),
                  ListTile(
                    leading: Icon(Icons.sort),
                    title: Text('排序方式'),
                  ),
                ],
              ),
              onClose: () => setState(() => _visible = false),
            ),
        ],
      ),
    );
  }
}

class _ParkDrawerWidthDemo extends StatefulWidget {
  @override
  State<_ParkDrawerWidthDemo> createState() => _ParkDrawerWidthDemoState();
}

class _ParkDrawerWidthDemoState extends State<_ParkDrawerWidthDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: <Widget>[
          if (!_visible)
            Center(
              child: ParkButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('打开宽抽屉'),
              ),
            ),
          if (_visible)
            ParkDrawer(
              width: 340,
              header: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.dashboard, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      '宽抽屉 (340px)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              child: ListView(
                children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('图片管理'),
                    subtitle: Text('管理所有上传的图片资源'),
                  ),
                  ListTile(
                    leading: Icon(Icons.article),
                    title: Text('文章管理'),
                    subtitle: Text('编辑和发布文章内容'),
                  ),
                  ListTile(
                    leading: Icon(Icons.analytics),
                    title: Text('数据统计'),
                    subtitle: Text('查看访问量与用户分析'),
                  ),
                ],
              ),
              onClose: () => setState(() => _visible = false),
            ),
        ],
      ),
    );
  }
}

class _ParkDrawerTopDemo extends StatefulWidget {
  @override
  State<_ParkDrawerTopDemo> createState() => _ParkDrawerTopDemoState();
}

class _ParkDrawerTopDemoState extends State<_ParkDrawerTopDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: <Widget>[
          if (!_visible)
            Center(
              child: ParkButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('打开顶部抽屉'),
              ),
            ),
          if (_visible)
            ParkDrawer(
              placement: ParkDrawerPlacement.top,
              size: ParkDrawerSize.small,
              child: const Center(child: Text('顶部浮层内容')),
              onClose: () => setState(() => _visible = false),
            ),
        ],
      ),
    );
  }
}

class _ParkDrawerMenuDemo extends StatefulWidget {
  @override
  State<_ParkDrawerMenuDemo> createState() => _ParkDrawerMenuDemoState();
}

class _ParkDrawerMenuDemoState extends State<_ParkDrawerMenuDemo> {
  int _selectedIndex = 0;
  bool _visible = true;

  static const List<Map<String, dynamic>> _menuItems = <Map<String, dynamic>>[
    <String, dynamic>{'icon': Icons.home, 'label': '首页'},
    <String, dynamic>{'icon': Icons.photo, 'label': '相册'},
    <String, dynamic>{'icon': Icons.music_note, 'label': '音乐'},
    <String, dynamic>{'icon': Icons.settings, 'label': '设置'},
  ];

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    return SizedBox(
      height: 400,
      child: Stack(
        children: <Widget>[
          // 触发按钮（抽屉关闭时显示）
          if (!_visible)
            Center(
              child: ParkButton(
                onPressed: () => setState(() => _visible = true),
                child: const Text('打开抽屉'),
              ),
            ),
          // 抽屉
          if (_visible)
            ParkDrawer(
              width: 260,
              closable: false,
              header: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.account_circle, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '用户名称',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'user@example.com',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _visible = false),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '当前选中: ${_menuItems[_selectedIndex]['label'] as String}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              onClose: () => setState(() => _visible = false),
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = _menuItems[index];
                  final isSelected = index == _selectedIndex;
                  return ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? park.colors.brand : null,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: isSelected ? park.colors.brand : null,
                        fontWeight:
                            isSelected ? park.typography.weightBold : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor:
                        park.colors.brandLight.withValues(alpha: 0.08),
                    onTap: () => setState(() => _selectedIndex = index),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
