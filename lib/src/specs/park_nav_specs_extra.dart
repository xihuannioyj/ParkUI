// Park 导航组件补充规格 — 由 Agent 审计并补全（对照真实实现）
//
// 约定：
//  - properties 枚举组件公开构造参数（排除 Key / BuildContext / 内容 Widget / 内部专用）；
//  - 函数类型的参数归入 events（onChange / onTap 等）；
//  - 每个事件 / 方法 / 主要属性变体均对应一个 demo，且 code 与 builder 完全一致；
//  - 双语（中文为主、英文并列）。
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

/// 导航类补充组件规格字典（3 个组件）。
Map<String, ParkComponentSpec> get parkNavSpecsExtra =>
    <String, ParkComponentSpec>{
      'ParkBreadcrumb': _parkBreadcrumbSpec,
      'ParkPagination': _parkPaginationSpec,
      'ParkBottomNav': _parkBottomNavSpec,
    };

// ---------------------------------------------------------------------------
// ParkBreadcrumb
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkBreadcrumbSpec = ParkComponentSpec(
  name: 'ParkBreadcrumb',
  title: '面包屑 / Breadcrumb',
  category: 'nav',
  description:
      '显示当前页面在导航层级中位置的面包屑导航，支持图标、下拉子菜单、'
      '超长自动折叠（ellipsis）等常见功能。项可点击（onTap）或带下拉子菜单（overlay）。'
      ' / Shows the current page location in the navigation hierarchy; supports icons, '
      'dropdown sub-menus, auto-collapse (ellipsis) and clickable items (onTap) or overlays.',
  icon: Icons.navigation_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkBreadcrumbItem>',
      required: true,
      description: '面包屑项列表，每项含 label / icon / onTap / overlay。',
    ),
    ParkPropertyDef(
      name: 'separator',
      type: 'Widget',
      defaultVal: "Text('/')",
      description: '分隔符（字符串或自定义 Widget），默认 / 。',
    ),
    ParkPropertyDef(
      name: 'maxItems',
      type: 'int?',
      defaultVal: 'null',
      description: '最大显示项数，超出时在头部插入 "..." 折叠按钮。',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkBreadcrumbSize',
      defaultVal: 'ParkBreadcrumbSize.medium',
      description: '面包屑尺寸：small（12）/ medium（14）/ large（16）。',
    ),
    ParkPropertyDef(
      name: 'separatorIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '分隔符图标（当 separator 为 null 时使用）。',
    ),
    ParkPropertyDef(
      name: 'overlayClassName',
      type: 'String?',
      defaultVal: 'null',
      description: '下拉菜单自定义样式类名。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'VoidCallback?',
      description: '单个面包屑项的点击回调（定义在 ParkBreadcrumbItem 上，最后一项通常不设）。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkBreadcrumb.text',
      signature:
          "factory ParkBreadcrumb.text({required List<ParkBreadcrumbItem> items, String separator = '/', int? maxItems, ParkBreadcrumbSize size = ParkBreadcrumbSize.medium})",
      description: '快捷构造：使用字符串分隔符的面包屑。',
    ),
  ],
  basicUsageCode: '''
ParkBreadcrumb(
  items: [
    ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: () {}),
    ParkBreadcrumbItem(label: '列表', onTap: () {}),
    ParkBreadcrumbItem(label: '详情'),
  ],
)
''',
  guide: '''
## 何时使用 / When to use
- 需要展示页面在网站 / 应用层级中位置（如 首页 > 分类 > 详情）
- 多级导航的回退入口

## 使用建议 / Usage tips
- 最后一项通常为当前页，不设置 onTap 表示不可点击
- 项过多时使用 maxItems 自动折叠，避免占据过多横向空间
- 项可配置 overlay 下拉子菜单做快速跳转
- 带下拉的项点击展开子菜单（PopupMenuButton 实现）

## 搭配推荐 / Compose with
- 搭配 ParkNavBar 做层级导航
- 搭配 ParkMenu 做复杂下拉
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础面包屑',
      description: '首页 > 列表 > 详情 三级面包屑。',
      code: '''
ParkBreadcrumb(
  items: [
    ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: () {}),
    ParkBreadcrumbItem(label: '列表', onTap: () {}),
    ParkBreadcrumbItem(label: '详情'),
  ],
)''',
      builder: (BuildContext context) => ParkBreadcrumb(
        items: const <ParkBreadcrumbItem>[
          ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: null),
          ParkBreadcrumbItem(label: '列表', onTap: null),
          ParkBreadcrumbItem(label: '详情'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '限制最大项数',
      description: 'maxItems 超出后自动折叠为 "..." 按钮（点击展开隐藏项）。',
      code: '''
ParkBreadcrumb(
  maxItems: 3,
  items: [
    ParkBreadcrumbItem(label: '一级', onTap: () {}),
    ParkBreadcrumbItem(label: '二级', onTap: () {}),
    ParkBreadcrumbItem(label: '三级', onTap: () {}),
    ParkBreadcrumbItem(label: '四级', onTap: () {}),
    ParkBreadcrumbItem(label: '当前页'),
  ],
)''',
      builder: (BuildContext context) => ParkBreadcrumb(
        maxItems: 3,
        items: const <ParkBreadcrumbItem>[
          ParkBreadcrumbItem(label: '一级', onTap: null),
          ParkBreadcrumbItem(label: '二级', onTap: null),
          ParkBreadcrumbItem(label: '三级', onTap: null),
          ParkBreadcrumbItem(label: '四级', onTap: null),
          ParkBreadcrumbItem(label: '当前页'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '项点击（onTap）',
      description: '前两项可点击，点击后下方文本更新（演示 Item.onTap 回调）。',
      code: '''
String _last = '无';
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    ParkBreadcrumb(
      items: [
        ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: () => _last = '首页'),
        ParkBreadcrumbItem(label: '列表', onTap: () => _last = '列表'),
        ParkBreadcrumbItem(label: '详情'),
      ],
    ),
    Text('最后点击: \$_last'),
  ],
)''',
      builder: (BuildContext context) => _ParkBreadcrumbOnTapDemo(),
    ),
    ParkDemoScenario(
      title: '下拉子菜单（overlay）',
      description: '含 overlay 子菜单的项点击展开下拉，可快速跳转到子项。',
      code: '''
ParkBreadcrumb(
  items: [
    ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: () {}),
    ParkBreadcrumbItem(label: '产品', overlay: [
      ParkBreadcrumbItem(label: '手机', onTap: () {}),
      ParkBreadcrumbItem(label: '电脑', onTap: () {}),
    ]),
    ParkBreadcrumbItem(label: '详情'),
  ],
)''',
      builder: (BuildContext context) => ParkBreadcrumb(
        items: const <ParkBreadcrumbItem>[
          ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: null),
          ParkBreadcrumbItem(
            label: '产品',
            overlay: <ParkBreadcrumbItem>[
              ParkBreadcrumbItem(label: '手机', onTap: null),
              ParkBreadcrumbItem(label: '电脑', onTap: null),
            ],
          ),
          ParkBreadcrumbItem(label: '详情'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '大号尺寸',
      description: 'size: ParkBreadcrumbSize.large 放大字号。',
      code: '''
ParkBreadcrumb(
  size: ParkBreadcrumbSize.large,
  items: [
    ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: () {}),
    ParkBreadcrumbItem(label: '列表', onTap: () {}),
    ParkBreadcrumbItem(label: '详情'),
  ],
)''',
      builder: (BuildContext context) => ParkBreadcrumb(
        size: ParkBreadcrumbSize.large,
        items: const <ParkBreadcrumbItem>[
          ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: null),
          ParkBreadcrumbItem(label: '列表', onTap: null),
          ParkBreadcrumbItem(label: '详情'),
        ],
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkPagination
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkPaginationSpec = ParkComponentSpec(
  name: 'ParkPagination',
  title: '分页器 / Pagination',
  category: 'nav',
  description:
      '数据分页导航组件，支持页码切换、每页条数选择、快速跳转、总条数展示与简洁模式，'
      '可响应式适配窄屏。'
      ' / Data pagination navigation with page switching, page-size changer, quick jumper, '
      'total info and a simple mode; responsive on narrow screens.',
  icon: Icons.more_horiz_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'total',
      type: 'int',
      required: true,
      description: '数据总条数。',
    ),
    ParkPropertyDef(
      name: 'current',
      type: 'int',
      defaultVal: '1',
      description: '当前页码（1-based）。',
    ),
    ParkPropertyDef(
      name: 'pageSize',
      type: 'int',
      defaultVal: '10',
      description: '每页条数。',
    ),
    ParkPropertyDef(
      name: 'pageSizeOptions',
      type: 'List<int>',
      defaultVal: '[10, 20, 50, 100]',
      description: '每页条数可选项（配合 showSizeChanger 使用）。',
    ),
    ParkPropertyDef(
      name: 'showSizeChanger',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示每页条数选择器。',
    ),
    ParkPropertyDef(
      name: 'showQuickJumper',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示快速跳转输入框。',
    ),
    ParkPropertyDef(
      name: 'showTotal',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示总条数信息（"共 X 条"）。',
    ),
    ParkPropertyDef(
      name: 'simple',
      type: 'bool',
      defaultVal: 'false',
      description: '简洁模式（仅上 / 下翻页与 当前/总页）。',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用整个分页器。',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'ParkPaginationSize',
      defaultVal: 'ParkPaginationSize.medium',
      description: '分页器尺寸：small（按钮 24px）/ medium（按钮 32px）。',
    ),
    ParkPropertyDef(
      name: 'responsive',
      type: 'bool',
      defaultVal: 'false',
      description: '是否响应式布局（窄屏时自动隐藏部分功能）。',
    ),
    ParkPropertyDef(
      name: 'defaultPageSize',
      type: 'int',
      defaultVal: '10',
      description: '非受控模式下的默认每页条数。',
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
      name: 'onChange',
      signature: 'void Function(int page, int pageSize)?',
      description: '页码或每页条数变化时的回调。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkPagination(
  total: 100,
  current: 1,
  onChange: (int page, int size) {},
)
''',
  guide: '''
## 何时使用 / When to use
- 列表 / 表格数据分页展示
- 需要切换页码或调整每页条数

## 使用建议 / Usage tips
- 数据量大时必须分页，避免一次性渲染过多
- showSizeChanger 方便用户调整每页条数
- 移动端可开启 responsive 或 simple 模式节省空间
- 通过 onChange 回调向后台请求对应页数据

## 搭配推荐 / Compose with
- 搭配 ParkList / ParkTable 做分页数据展示
- 搭配 ParkSelect 做每页条数备选
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础分页',
      description: '共 100 条，每页 10 条的分页器。',
      code: '''
ParkPagination(
  total: 100,
  current: 1,
  onChange: (int page, int size) {},
)''',
      builder: (BuildContext context) => ParkPagination(
        total: 100,
        current: 1,
        onChange: (int page, int size) {},
      ),
    ),
    ParkDemoScenario(
      title: '受控切换（onChange）',
      description: '通过 current + onChange 受控管理页码，下方文本同步当前页。',
      code: '''
int _page = 1;
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    ParkPagination(
      total: 100,
      current: _page,
      onChange: (int p, int s) => _page = p,
    ),
    Text('当前页: \$_page'),
  ],
)''',
      builder: (BuildContext context) => _ParkPaginationOnChangeDemo(),
    ),
    ParkDemoScenario(
      title: '带每页条数与跳转',
      description: '开启 showSizeChanger 与 showQuickJumper。',
      code: '''
ParkPagination(
  total: 200,
  current: 1,
  showSizeChanger: true,
  showQuickJumper: true,
  onChange: (int page, int size) {},
)''',
      builder: (BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ParkPagination(
          total: 200,
          current: 1,
          showSizeChanger: true,
          showQuickJumper: true,
          onChange: (int page, int size) {},
        ),
      ),
    ),
    ParkDemoScenario(
      title: '显示总条数',
      description: 'showTotal: true 在左侧展示"共 X 条"。',
      code: '''
ParkPagination(
  total: 256,
  current: 1,
  showTotal: true,
  onChange: (int page, int size) {},
)''',
      builder: (BuildContext context) => ParkPagination(
        total: 256,
        current: 1,
        showTotal: true,
        onChange: (int page, int size) {},
      ),
    ),
    ParkDemoScenario(
      title: '简洁模式',
      description: 'simple: true 仅保留上 / 下翻页与 当前/总页。',
      code: '''
ParkPagination(
  total: 100,
  current: 1,
  simple: true,
  onChange: (int page, int size) {},
)''',
      builder: (BuildContext context) => ParkPagination(
        total: 100,
        current: 1,
        simple: true,
        onChange: (int page, int size) {},
      ),
    ),
  ],
);

// ==========================================================================
//  Demo helper widgets
// ==========================================================================

class _ParkBreadcrumbOnTapDemo extends StatefulWidget {
  @override
  State<_ParkBreadcrumbOnTapDemo> createState() =>
      _ParkBreadcrumbOnTapDemoState();
}

class _ParkBreadcrumbOnTapDemoState
    extends State<_ParkBreadcrumbOnTapDemo> {
  String _last = '无';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkBreadcrumb(
          items: <ParkBreadcrumbItem>[
            ParkBreadcrumbItem(
              label: '首页',
              icon: Icons.home,
              onTap: () => setState(() => _last = '首页'),
            ),
            ParkBreadcrumbItem(
              label: '列表',
              onTap: () => setState(() => _last = '列表'),
            ),
            const ParkBreadcrumbItem(label: '详情'),
          ],
        ),
        const SizedBox(height: 8),
        Text('最后点击: $_last'),
      ],
    );
  }
}

class _ParkPaginationOnChangeDemo extends StatefulWidget {
  @override
  State<_ParkPaginationOnChangeDemo> createState() =>
      _ParkPaginationOnChangeDemoState();
}

class _ParkPaginationOnChangeDemoState
    extends State<_ParkPaginationOnChangeDemo> {
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkPagination(
          total: 100,
          current: _page,
          onChange: (int p, int s) => setState(() => _page = p),
        ),
        const SizedBox(height: 8),
        Text('当前页: $_page'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ParkBottomNav
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkBottomNavSpec = ParkComponentSpec(
  name: 'ParkBottomNav',
  title: '底部导航栏',
  category: 'nav',
  description:
      '底部导航栏组件，对齐 Flutter 原生 BottomNavigationBar，使用 park_ui 主题令牌。'
      '支持 fixed / shifting 两种类型、角标 Badge、自定义颜色与图标尺寸。'
      ' / Bottom navigation bar aligned with Flutter BottomNavigationBar using park_ui theme tokens; '
      'supports fixed/shifting types, badge, custom colors and icon size.',
  icon: Icons.navigation_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'currentIndex',
      type: 'int',
      defaultVal: '—',
      description: '当前选中索引 / Current selected index',
      required: true,
    ),
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkBottomNavItem>',
      defaultVal: '—',
      description: '导航项列表（2–5 项）/ Navigation items (2–5)',
      required: true,
    ),
    ParkPropertyDef(
      name: 'type',
      type: 'ParkBottomNavType',
      defaultVal: 'fixed',
      description: '导航类型（fixed / shifting）/ Navigation type',
      required: false,
    ),
    ParkPropertyDef(
      name: 'selectedItemColor',
      type: 'Color?',
      defaultVal: 'null（品牌色）',
      description: '选中项颜色 / Selected item color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'unselectedItemColor',
      type: 'Color?',
      defaultVal: 'null（次要文字色）',
      description: '未选中项颜色 / Unselected item color',
      required: false,
    ),
    ParkPropertyDef(
      name: 'iconSize',
      type: 'double',
      defaultVal: '24',
      description: '图标尺寸 / Icon size',
      required: false,
    ),
    ParkPropertyDef(
      name: 'elevation',
      type: 'double',
      defaultVal: '0',
      description: '阴影高度 / Elevation',
      required: false,
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null（surface）',
      description: '背景色 / Background color',
      required: false,
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'ValueChanged<int>',
      description: '点击导航项回调 / Tab tap callback',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''ParkBottomNav(
  currentIndex: 0,
  onTap: (index) => setState(() => _index = index),
  items: [
    ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
    ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
    ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
  ],
)''',
  guide: '''
## 何时使用
- 应用底部主导航切换 / Bottom main navigation
- 3–5 个顶级页面间的切换 / Switching between 3–5 top-level pages

## 使用建议
- items 数量限制为 2–5 个
- shifting 类型下选中项展开、未选中仅显示图标
- 通过 ParkBottomNavItem.badge 显示角标

## 搭配推荐
- 搭配 Scaffold.bottomNavigationBar 使用
- 搭配 ParkBadge 显示未读消息数
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础底部导航',
      description: 'fixed 类型的底部导航栏 / Fixed bottom navigation',
      code: '''
ParkBottomNav(
  currentIndex: 0,
  onTap: (index) {},
  items: [
    ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
    ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
    ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
  ],
)''',
      builder: (BuildContext context) => _ParkBottomNavDemo1(),
    ),
    ParkDemoScenario(
      title: '带角标',
      description: '导航项带 Badge / Items with badge',
      code: '''
ParkBottomNav(
  currentIndex: 0,
  onTap: (index) {},
  items: [
    ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
    ParkBottomNavItem(icon: Icon(Icons.message), label: '消息', badge: '5'),
    ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
  ],
)''',
      builder: (BuildContext context) => _ParkBottomNavDemo2(),
    ),
  ],
);

class _ParkBottomNavDemo1 extends StatefulWidget {
  @override
  State<_ParkBottomNavDemo1> createState() => _ParkBottomNavDemo1State();
}

class _ParkBottomNavDemo1State extends State<_ParkBottomNavDemo1> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ParkBottomNav(
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
        items: const <ParkBottomNavItem>[
          ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
          ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
          ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

class _ParkBottomNavDemo2 extends StatefulWidget {
  @override
  State<_ParkBottomNavDemo2> createState() => _ParkBottomNavDemo2State();
}

class _ParkBottomNavDemo2State extends State<_ParkBottomNavDemo2> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ParkBottomNav(
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
        items: const <ParkBottomNavItem>[
          ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
          ParkBottomNavItem(icon: Icon(Icons.message), label: '消息', badge: '5'),
          ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
