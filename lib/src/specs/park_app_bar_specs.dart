// ParkAppBar / ParkSliverAppBar 组件规格（B273：ylzj 原生 AppBar 回流 park_ui）
//
// 约定：
//  - properties 枚举组件公开构造参数（排除 Key / BuildContext / 内部专用）；
//  - 每个主要属性变体均对应一个 demo，且 code 与 builder 完全一致；
//  - 禁止裸字面量：颜色用 ParkColors.* / Theme token，间距用 ParkSpacing.*，字号用 ParkTypography.*；
//  - 双语（中文为主、英文并列）。
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

/// AppBar 组件规格字典（2 个组件：ParkAppBar / ParkSliverAppBar）。
Map<String, ParkComponentSpec> get parkAppBarSpecs =>
    <String, ParkComponentSpec>{
      'ParkAppBar': ParkComponentSpec(
        name: 'ParkAppBar',
        title: '应用栏 / App Bar',
        category: 'nav',
        icon: Icons.web_asset_outlined,
        relatedComponents: const <String>['ParkNavBar', 'ParkSliverAppBar'],
        description:
            '顶部应用栏，对齐 Flutter 原生 AppBar 的参数面（title / leading / actions / '
            'centerTitle / bottom / elevation 等），默认值全部走 ParkTheme 设计令牌'
            '（背景 park.colors.surface、标题 park.typography.h3），支持暗色模式。'
            '可弹出路由自动显示品牌返回按钮（Semantics 标签走 ParkLocalizations）。'
            ' / Top app bar mirroring the native AppBar parameter surface with ParkTheme '
            'token defaults (surface background, h3 title) and dark-mode support; '
            'auto brand back button on poppable routes.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'title',
            type: 'Object? (String | Widget)',
            defaultVal: 'null',
            description:
                '标题：String 走 Park 排版令牌（h3）；Widget 合并默认文字样式后渲染。',
          ),
          ParkPropertyDef(
            name: 'subtitle',
            type: 'String?',
            defaultVal: 'null',
            description:
                '副标题：显示在标题下方，走 Park 排版令牌 bodySmall（14px，65% 透明度）。',
          ),
          ParkPropertyDef(
            name: 'leading',
            type: 'Widget?',
            defaultVal: 'null',
            description: '自定义前置 Widget（替代默认返回按钮）。',
          ),
          ParkPropertyDef(
            name: 'automaticallyImplyLeading',
            type: 'bool',
            defaultVal: 'true',
            description:
                '未提供 leading 时是否自动推断前置控件：可弹出路由显示 Park 返回按钮，'
                '有抽屉时交还原生抽屉按钮逻辑。',
          ),
          ParkPropertyDef(
            name: 'actions',
            type: 'List<Widget>?',
            defaultVal: 'null',
            description: '右侧操作按钮列表。',
          ),
          ParkPropertyDef(
            name: 'centerTitle',
            type: 'bool?',
            defaultVal: 'null',
            description: '标题是否居中；null 时跟随平台默认行为。',
          ),
          ParkPropertyDef(
            name: 'backgroundColor',
            type: 'Color?',
            defaultVal: 'park.colors.surface',
            description: '背景色，默认走 ParkTheme surface 令牌（暗色模式自动切换）。',
          ),
          ParkPropertyDef(
            name: 'foregroundColor',
            type: 'Color?',
            defaultVal: 'park.colors.textPrimary',
            description: '前景色：标题文字 / 返回按钮 / actions 图标颜色。',
          ),
          ParkPropertyDef(
            name: 'elevation',
            type: 'double?',
            defaultVal: '0',
            description: '阴影高度，默认 0（扁平品牌风格）。',
          ),
          ParkPropertyDef(
            name: 'bottom',
            type: 'PreferredSizeWidget?',
            defaultVal: 'null',
            description: '底部附加 Widget（如 TabBar），高度计入 preferredSize。',
          ),
          ParkPropertyDef(
            name: 'titleSpacing',
            type: 'double?',
            defaultVal: '16',
            description: '标题与 leading / actions 之间的间距（对齐 NavigationToolbar）。',
          ),
          ParkPropertyDef(
            name: 'surfaceTintColor',
            type: 'Color?',
            defaultVal: 'null',
            description:
                '表面着色（Material 3 默认有紫色 tint，传 Colors.transparent 可抑制）。',
          ),
          ParkPropertyDef(
            name: 'toolbarHeight',
            type: 'double?',
            defaultVal: 'kToolbarHeight (56)',
            description: '工具栏高度，默认 kToolbarHeight = 56。',
          ),
          ParkPropertyDef(
            name: 'flexibleSpace',
            type: 'Widget?',
            defaultVal: 'null',
            description:
                '灵活空间 Widget（背景图片等场景），显示在工具栏下方。',
          ),
          ParkPropertyDef(
            name: 'shadowColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '阴影颜色，默认 null 跟随主题。',
          ),
          ParkPropertyDef(
            name: 'shape',
            type: 'ShapeBorder?',
            defaultVal: 'null',
            description:
                '应用栏形状（如 RoundedRectangleBorder），传入后覆盖默认矩形并影响阴影。',
          ),
          ParkPropertyDef(
            name: 'iconTheme',
            type: 'IconThemeData?',
            defaultVal: 'null',
            description: '图标主题（作用于 leading / actions 图标）。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础用法（String 标题 + actions）',
            description:
                'title 传字符串走 Park 排版令牌；actions 放右侧操作按钮。',
            code: '''Scaffold(
  appBar: ParkAppBar(
    title: '首页',
    actions: [
      IconButton(icon: Icon(Icons.search), onPressed: () {}),
      IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
    ],
  ),
  body: Center(child: Text('内容区')),
)''',
            builder: (BuildContext context) => Scaffold(
              appBar: ParkAppBar(
                title: '首页',
                actions: <Widget>[
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),
              body: const Center(child: Text('内容区')),
            ),
          ),
          ParkDemoScenario(
            title: 'Widget 标题 + 居中（centerTitle）',
            description:
                'title 传自定义 Widget（图标 + 文字），centerTitle: true 居中显示。',
            code: '''ParkAppBar(
  centerTitle: true,
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.storefront, size: 20),
      SizedBox(width: 8),
      Text('品牌商城'),
    ],
  ),
)''',
            builder: (BuildContext context) => Scaffold(
              appBar: ParkAppBar(
                centerTitle: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.storefront, size: 20),
                    const SizedBox(width: 8),
                    const Text('品牌商城'),
                  ],
                ),
              ),
              body: const SizedBox.shrink(),
            ),
          ),
          ParkDemoScenario(
            title: '品牌色背景（backgroundColor / foregroundColor / elevation）',
            description:
                '背景走 park.colors.brand、前景走 park.colors.textOnBrand，elevation: 4 投影。',
            code: '''final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
ParkAppBar(
  title: '品牌色',
  backgroundColor: park.colors.brand,
  foregroundColor: park.colors.textOnBrand,
  elevation: 4,
)''',
            builder: (BuildContext context) {
              final park = Theme.of(context).extension<ParkThemeData>() ??
                  ParkThemeData.light();
              return Scaffold(
                appBar: ParkAppBar(
                  title: '品牌色',
                  backgroundColor: park.colors.brand,
                  foregroundColor: park.colors.textOnBrand,
                  elevation: 4,
                ),
                body: const SizedBox.shrink(),
              );
            },
          ),
          ParkDemoScenario(
            title: '自定义 leading + 关闭自动推断',
            description:
                'leading 传自定义头像；automaticallyImplyLeading: false 关闭自动返回按钮。',
            code: '''ParkAppBar(
  automaticallyImplyLeading: false,
  leading: CircleAvatar(child: Icon(Icons.person)),
  title: '我的',
)''',
            builder: (BuildContext context) => Scaffold(
              appBar: ParkAppBar(
                automaticallyImplyLeading: false,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: '我的',
              ),
              body: const SizedBox.shrink(),
            ),
          ),
          ParkDemoScenario(
            title: '底部附加（bottom）+ 标题间距（titleSpacing）',
            description:
                'bottom 挂搜索条（高度计入 preferredSize）；titleSpacing: 0 让标题贴近 leading。',
            code: '''ParkAppBar(
  title: '商品',
  titleSpacing: 0,
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(44),
    child: Container(
      height: 44,
      alignment: Alignment.center,
      child: Text('搜索栏占位'),
    ),
  ),
)''',
            builder: (BuildContext context) => Scaffold(
              appBar: ParkAppBar(
                title: '商品',
                titleSpacing: 0,
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(44),
                  child: SizedBox(
                    height: 44,
                    child: Center(child: Text('搜索栏占位')),
                  ),
                ),
              ),
              body: const SizedBox.shrink(),
            ),
          ),
          ParkDemoScenario(
            title: '副标题（subtitle）',
            description:
                'subtitle 在标题下方显示补充说明文字，走 bodySmall 排版令牌（14px，65% 透明度）。',
            code: '''ParkAppBar(
  title: '订单详情',
  subtitle: '订单号：20240601001',
)''',
            builder: (BuildContext context) => Scaffold(
              appBar: const ParkAppBar(
                title: '订单详情',
                subtitle: '订单号：20240601001',
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ],
        basicUsageCode: '''Scaffold(
  appBar: ParkAppBar(
    title: '页面标题',
    actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
  ),
  body: ...
)''',
        guide: '''
## 何时使用 / When to use
- 需要 Material 原生 AppBar 行为（Scaffold.appBar 插槽、bottom、elevation）又要 Park 品牌视觉时
- 从原生 AppBar 迁移收敛品牌主题（ylzj 90 处原生 AppBar 回流，B273）

## 与 ParkNavBar 的区别 / vs ParkNavBar
- ParkNavBar：完全自绘的轻量导航栏，参数面为 Park 自有设计（leftArrow / onBack / transparent）
- ParkAppBar：直接包装原生 AppBar，参数面对齐 Flutter，替换默认令牌

## 使用建议 / Usage tips
- title 传 String 即可，自动走 park.typography.h3 标题样式
- subtitle 传 String 在标题下方显示补充信息，走 park.typography.bodySmall（14px，65% 透明度）
- 可弹出路由（canPop 且无抽屉）自动显示品牌返回按钮，Semantics 标签为「返回 / Back」
- 暗色模式：背景默认 park.colors.surface，随 ParkThemeData.dark() 自动切换
- scrolledUnderElevation 固定为 0，保持扁平品牌风格

## 搭配推荐 / Compose with
- 搭配 ParkTabs / TabBar 做 bottom 二级导航
- 搭配 ParkDrawer 做侧滑抽屉（自动让位抽屉按钮）
''',
      ),

      'ParkSliverAppBar': ParkComponentSpec(
        name: 'ParkSliverAppBar',
        title: 'Sliver 应用栏 / Sliver App Bar',
        category: 'nav',
        icon: Icons.view_agenda_outlined,
        relatedComponents: const <String>['ParkAppBar', 'ParkNavBar'],
        description:
            'Sliver 应用栏，对齐 Flutter 原生 SliverAppBar 的参数面，用于 CustomScrollView，'
            '支持吸顶（pinned）/ 浮动（floating）/ 拉伸（stretch）/ 展开折叠（expandedHeight），'
            '默认值全部走 ParkTheme 设计令牌，支持暗色模式。'
            ' / Sliver app bar mirroring the native SliverAppBar for CustomScrollView with '
            'pinned / floating / stretch / expandedHeight and ParkTheme token defaults.',
        properties: const <ParkPropertyDef>[
          ParkPropertyDef(
            name: 'title',
            type: 'Object? (String | Widget)',
            defaultVal: 'null',
            description:
                '标题：String 走 Park 排版令牌（h3）；Widget 合并默认文字样式后渲染。',
          ),
          ParkPropertyDef(
            name: 'subtitle',
            type: 'String?',
            defaultVal: 'null',
            description:
                '副标题：显示在标题下方，走 Park 排版令牌 bodySmall（14px，65% 透明度）。',
          ),
          ParkPropertyDef(
            name: 'leading',
            type: 'Widget?',
            defaultVal: 'null',
            description: '自定义前置 Widget（替代默认返回按钮）。',
          ),
          ParkPropertyDef(
            name: 'automaticallyImplyLeading',
            type: 'bool',
            defaultVal: 'true',
            description:
                '未提供 leading 时是否自动推断前置控件：可弹出路由显示 Park 返回按钮。',
          ),
          ParkPropertyDef(
            name: 'actions',
            type: 'List<Widget>?',
            defaultVal: 'null',
            description: '右侧操作按钮列表。',
          ),
          ParkPropertyDef(
            name: 'centerTitle',
            type: 'bool?',
            defaultVal: 'null',
            description: '标题是否居中；null 时跟随平台默认行为。',
          ),
          ParkPropertyDef(
            name: 'backgroundColor',
            type: 'Color?',
            defaultVal: 'park.colors.surface',
            description: '背景色，默认走 ParkTheme surface 令牌（暗色模式自动切换）。',
          ),
          ParkPropertyDef(
            name: 'foregroundColor',
            type: 'Color?',
            defaultVal: 'park.colors.textPrimary',
            description: '前景色：标题文字 / 返回按钮 / actions 图标颜色。',
          ),
          ParkPropertyDef(
            name: 'elevation',
            type: 'double?',
            defaultVal: '0',
            description: '阴影高度，默认 0（扁平品牌风格）。',
          ),
          ParkPropertyDef(
            name: 'bottom',
            type: 'PreferredSizeWidget?',
            defaultVal: 'null',
            description: '底部附加 Widget（如 TabBar）。',
          ),
          ParkPropertyDef(
            name: 'titleSpacing',
            type: 'double?',
            defaultVal: '16',
            description: '标题与 leading / actions 之间的间距（对齐 NavigationToolbar）。',
          ),
          ParkPropertyDef(
            name: 'pinned',
            type: 'bool',
            defaultVal: 'false',
            description: '折叠后是否吸顶。',
          ),
          ParkPropertyDef(
            name: 'floating',
            type: 'bool',
            defaultVal: 'false',
            description: '是否浮动（向下滚动时立即出现）。',
          ),
          ParkPropertyDef(
            name: 'stretch',
            type: 'bool',
            defaultVal: 'false',
            description: '是否支持过度拉伸效果。',
          ),
          ParkPropertyDef(
            name: 'expandedHeight',
            type: 'double',
            defaultVal: '200',
            description: '展开态总高度（含折叠高度）。',
          ),
          ParkPropertyDef(
            name: 'surfaceTintColor',
            type: 'Color?',
            defaultVal: 'null',
            description:
                '表面着色（Material 3 默认有紫色 tint，传 Colors.transparent 可抑制）。',
          ),
          ParkPropertyDef(
            name: 'toolbarHeight',
            type: 'double?',
            defaultVal: 'kToolbarHeight (56)',
            description: '工具栏高度，默认 kToolbarHeight = 56。',
          ),
          ParkPropertyDef(
            name: 'flexibleSpace',
            type: 'Widget?',
            defaultVal: 'null',
            description:
                '灵活空间 Widget（背景图片等场景），显示在工具栏下方。',
          ),
          ParkPropertyDef(
            name: 'shadowColor',
            type: 'Color?',
            defaultVal: 'null',
            description: '阴影颜色，默认 null 跟随主题。',
          ),
          ParkPropertyDef(
            name: 'shape',
            type: 'ShapeBorder?',
            defaultVal: 'null',
            description:
                '应用栏形状（如 RoundedRectangleBorder），传入后覆盖默认矩形并影响阴影。',
          ),
          ParkPropertyDef(
            name: 'iconTheme',
            type: 'IconThemeData?',
            defaultVal: 'null',
            description: '图标主题（作用于 leading / actions 图标）。',
          ),
        ],
        demos: <ParkDemoScenario>[
          ParkDemoScenario(
            title: '基础用法（展开折叠 + 吸顶）',
            description:
                'expandedHeight 控制展开高度，pinned: true 折叠后吸顶保留标题与返回按钮。',
            code: '''CustomScrollView(
  slivers: [
    ParkSliverAppBar(
      title: '发现',
      pinned: true,
      expandedHeight: 240,
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ListTile(title: Text('列表项 \$index')),
        childCount: 30,
      ),
    ),
  ],
)''',
            builder: (BuildContext context) => SizedBox(
              height: 320,
              child: CustomScrollView(
                slivers: <Widget>[
                  ParkSliverAppBar(
                    title: '发现',
                    pinned: true,
                    expandedHeight: 240,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) =>
                          ListTile(title: Text('列表项 $index')),
                      childCount: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '浮动 + 拉伸（floating / stretch）',
            description:
                'floating: true 向下滚动立即出现；stretch: true 支持过度拉伸回弹。',
            code: '''ParkSliverAppBar(
  title: '消息',
  floating: true,
  stretch: true,
  expandedHeight: 160,
)''',
            builder: (BuildContext context) => SizedBox(
              height: 320,
              child: CustomScrollView(
                slivers: <Widget>[
                  const ParkSliverAppBar(
                    title: '消息',
                    floating: true,
                    stretch: true,
                    expandedHeight: 160,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) =>
                          ListTile(title: Text('会话 $index')),
                      childCount: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ParkDemoScenario(
            title: '品牌色背景 + 底部标签（bottom）',
            description:
                '背景走 park.colors.brand；bottom 挂 TabBar 需配合 DefaultTabController。',
            code: '''final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
DefaultTabController(
  length: 2,
  child: CustomScrollView(
    slivers: [
      ParkSliverAppBar(
        title: '订单',
        pinned: true,
        backgroundColor: park.colors.brand,
        foregroundColor: park.colors.textOnBrand,
        bottom: TabBar(tabs: [Tab(text: '全部'), Tab(text: '待付款')]),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 400)),
    ],
  ),
)''',
            builder: (BuildContext context) {
              final park = Theme.of(context).extension<ParkThemeData>() ??
                  ParkThemeData.light();
              return SizedBox(
                height: 320,
                child: DefaultTabController(
                  length: 2,
                  child: CustomScrollView(
                    slivers: <Widget>[
                      ParkSliverAppBar(
                        title: '订单',
                        pinned: true,
                        backgroundColor: park.colors.brand,
                        foregroundColor: park.colors.textOnBrand,
                        bottom: const TabBar(
                          tabs: <Widget>[
                            Tab(text: '全部'),
                            Tab(text: '待付款'),
                          ],
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 400),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        basicUsageCode: '''CustomScrollView(
  slivers: [
    ParkSliverAppBar(
      title: '发现',
      pinned: true,
      expandedHeight: 240,
    ),
    SliverList(...),
  ],
)''',
        guide: '''
## 何时使用 / When to use
- CustomScrollView 中需要可折叠 / 吸顶 / 浮动的品牌应用栏
- 长列表页（商品流、消息列表）的沉浸式头部

## 使用建议 / Usage tips
- pinned: true 折叠后保留标题与返回按钮；floating: true 向下滚动立即重现
- stretch 需配合可拉伸内容（FlexibleSpaceBar stretchModes）效果最佳
- expandedHeight 为展开态总高度（含折叠高度 kToolbarHeight）
- subtitle 传 String 在标题下方显示补充信息，走 park.typography.bodySmall（14px，65% 透明度）
- 暗色模式：背景默认 park.colors.surface，随 ParkThemeData.dark() 自动切换

## 搭配推荐 / Compose with
- 搭配 TabBar（bottom）做吸顶二级导航
- 搭配 SliverList / SliverGrid 做长列表
''',
      ),
    };
