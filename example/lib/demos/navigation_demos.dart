import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// TabBar Demo
// =============================================================================

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('TabBar 底部导航', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('App 底部 Tab 切换导航，支持固定与悬浮风格。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('固定式导航', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 240,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('当前 Tab: ${_tabBarIndex + 1}'),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ParkTabBar(
                      currentIndex: _tabBarIndex,
                      onTap: (i) => setState(() => _tabBarIndex = i),
                      items: const [
                        ParkTabBarItem(icon: Icons.home, label: '首页'),
                        ParkTabBarItem(icon: Icons.search, label: '发现'),
                        ParkTabBarItem(
                          icon: Icons.shopping_cart,
                          label: '购物车',
                          badge: '3',
                        ),
                        ParkTabBarItem(icon: Icons.person, label: '我的'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('悬浮式导航', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 240,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('当前 Tab: ${_floatingTabIndex + 1}'),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 8,
                    child: ParkTabBar(
                      type: ParkTabBarType.floating,
                      currentIndex: _floatingTabIndex,
                      onTap: (i) => setState(() => _floatingTabIndex = i),
                      items: const [
                        ParkTabBarItem(icon: Icons.explore, label: '浏览'),
                        ParkTabBarItem(icon: Icons.favorite, label: '收藏'),
                        ParkTabBarItem(icon: Icons.settings, label: '设置'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

int _tabBarIndex = 0;
int _floatingTabIndex = 0;

// =============================================================================
// Menu Demo
// =============================================================================

class MenuDemo extends StatelessWidget {
  const MenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Menu 导航菜单', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('支持多级展开、选中高亮、图标的导航菜单。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('垂直菜单', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ParkMenu(
                themeMode: ParkMenuThemeMode.light,
                selectedKey: _menuKey,
                items: const [
                  ParkMenuItem(
                    key: 'dashboard',
                    label: '仪表盘',
                    icon: Icons.dashboard,
                  ),
                  ParkMenuItem(
                    key: 'users',
                    label: '用户管理',
                    icon: Icons.people,
                    children: [
                      ParkMenuItem(key: 'user-list', label: '用户列表'),
                      ParkMenuItem(key: 'user-role', label: '角色管理'),
                    ],
                  ),
                  ParkMenuItem(
                    key: 'settings',
                    label: '系统设置',
                    icon: Icons.settings,
                    children: [
                      ParkMenuItem(key: 'basic', label: '基础设置'),
                      ParkMenuItem(key: 'security', label: '安全设置'),
                    ],
                  ),
                ],
                onSelect: (key) => setState(() => _menuKey = key),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

String? _menuKey = 'dashboard';

// =============================================================================
// Breadcrumb Demo
// =============================================================================

class BreadcrumbDemo extends StatelessWidget {
  const BreadcrumbDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Breadcrumb 面包屑', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('显示当前页面在导航层级中的位置。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(
              label: '首页',
              icon: Icons.home,
            ),
            ParkBreadcrumbItem(label: '列表'),
            ParkBreadcrumbItem(label: '详情'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('带分隔符', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkBreadcrumb.text(
          separator: '>',
          items: const [
            ParkBreadcrumbItem(label: '首页'),
            ParkBreadcrumbItem(label: '分类'),
            ParkBreadcrumbItem(label: '详情'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParkBreadcrumb(
              size: ParkBreadcrumbSize.small,
              items: const [
                ParkBreadcrumbItem(label: 'Small'),
                ParkBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
            const SizedBox(height: 8),
            ParkBreadcrumb(
              size: ParkBreadcrumbSize.medium,
              items: const [
                ParkBreadcrumbItem(label: 'Medium'),
                ParkBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
            const SizedBox(height: 8),
            ParkBreadcrumb(
              size: ParkBreadcrumbSize.large,
              items: const [
                ParkBreadcrumbItem(label: 'Large'),
                ParkBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Pagination Demo
// =============================================================================

class PaginationDemo extends StatelessWidget {
  const PaginationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Pagination 分页', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('页码导航，支持快速跳转和每页条数切换。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础分页', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkPagination(
              total: 100,
              current: _currentPage,
              pageSize: 10,
              onChange: (page, _) => setState(() => _currentPage = page),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('带每页条数切换', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkPagination(
              total: 500,
              current: _pageSizeCurrent,
              pageSize: _pageSize,
              showSizeChanger: true,
              showQuickJumper: true,
              onChange: (page, size) {
                setState(() {
                  _pageSizeCurrent = page;
                  _pageSize = size;
                });
              },
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                ParkPagination(
                  total: 50,
                  current: _smallPage,
                  pageSize: 10,
                  size: ParkPaginationSize.small,
                  onChange: (page, _) => setState(() => _smallPage = page),
                ),
                const SizedBox(height: 12),
                ParkPagination(
                  total: 50,
                  current: _mediumPage,
                  pageSize: 10,
                  size: ParkPaginationSize.medium,
                  onChange: (page, _) => setState(() => _mediumPage = page),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

int _currentPage = 1;
int _pageSizeCurrent = 1;
int _pageSize = 10;
int _smallPage = 1;
int _mediumPage = 1;

// =============================================================================
// Tabs Demo
// =============================================================================

class TabsDemo extends StatelessWidget {
  const TabsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Tabs 标签页', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('标签页切换导航，支持下划线/卡片风格、垂直布局。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkTabs(
            tabs: const [
              ParkTab(label: '推荐'),
              ParkTab(label: '热门', badge: '9'),
              ParkTab(label: '最新', icon: Icons.new_releases),
            ],
            children: const [
              Center(child: Text('推荐内容区域')),
              Center(child: Text('热门内容区域')),
              Center(child: Text('最新内容区域')),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ParkText('卡片风格', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkTabs(
            type: ParkTabType.card,
            tabs: const [
              ParkTab(label: '选项卡 A'),
              ParkTab(label: '选项卡 B'),
              ParkTab(label: '选项卡 C'),
            ],
            children: const [
              Center(child: Text('选项卡 A 内容')),
              Center(child: Text('选项卡 B 内容')),
              Center(child: Text('选项卡 C 内容')),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ParkText('垂直布局', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkTabs(
            tabPosition: ParkTabPosition.left,
            tabs: const [
              ParkTab(label: '设置一', icon: Icons.palette),
              ParkTab(label: '设置二', icon: Icons.security),
              ParkTab(label: '设置三', icon: Icons.info),
            ],
            children: const [
              Center(child: Text('设置一内容')),
              Center(child: Text('设置二内容')),
              Center(child: Text('设置三内容')),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ParkText('可滚动 & 居中', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTabs(
          scrollable: true,
          centered: false,
          tabs: const [
            ParkTab(label: '标签 1'),
            ParkTab(label: '标签 2'),
            ParkTab(label: '标签 3'),
            ParkTab(label: '标签 4'),
            ParkTab(label: '标签 5'),
            ParkTab(label: '标签 6'),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
