import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Anchor Demo
// =============================================================================

class AnchorDemo extends StatelessWidget {
  const AnchorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final section1Key = GlobalKey();
    final section2Key = GlobalKey();
    final section3Key = GlobalKey();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParkText('Anchor 锚点导航', preset: ParkTextPreset.h2),
              const SizedBox(height: 8),
              ParkText('监听滚动位置，自动高亮当前区域的导航项。',
                  preset: ParkTextPreset.caption),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: ParkAnchor(
                  scrollController: scrollController,
                  items: const [
                    ParkAnchorItem(key: 'basic', label: '基础信息'),
                    ParkAnchorItem(key: 'detail', label: '详细信息'),
                    ParkAnchorItem(key: 'setting', label: '设置'),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Container(
                        key: section1Key,
                        height: 200,
                        color: Colors.blue.shade50,
                        child: const Center(child: Text('基础信息区域')),
                      ),
                      Container(
                        key: section2Key,
                        height: 200,
                        color: Colors.green.shade50,
                        child: const Center(child: Text('详细信息区域')),
                      ),
                      Container(
                        key: section3Key,
                        height: 200,
                        color: Colors.orange.shade50,
                        child: const Center(child: Text('设置区域')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Layout Demo
// =============================================================================

class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Layout 页面布局', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('Header + Sidebar + Content + Footer 标准布局。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础布局', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 350,
          child: ParkLayout(
            header: Container(
              color: Colors.blue.shade700,
              padding: const EdgeInsets.all(12),
              child: const Text('Header',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            sidebar: Container(
              color: Colors.grey.shade200,
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    title: const Text('菜单一'),
                    onTap: () {},
                  ),
                  ListTile(
                    dense: true,
                    title: const Text('菜单二'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            body: Container(
              color: Colors.white,
              child: const Center(child: Text('内容区域')),
            ),
            footer: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text('(c) 2025 Park UI',
                  style: TextStyle(fontSize: 12)),
            ),
            sidebarWidth: 150,
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// BottomNav Demo
// =============================================================================

class BottomNavDemo extends StatefulWidget {
  const BottomNavDemo({super.key});

  @override
  State<BottomNavDemo> createState() => _BottomNavDemoState();
}

class _BottomNavDemoState extends State<BottomNavDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('BottomNav 底部导航', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('底部导航栏，支持固定和移动两种类型。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ParkBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
                ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
                ParkBottomNavItem(icon: Icon(Icons.favorite), label: '收藏'),
                ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('带角标', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ParkBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                ParkBottomNavItem(
                  icon: Icon(Icons.message),
                  label: '消息',
                  badge: '5',
                ),
                ParkBottomNavItem(
                  icon: Icon(Icons.notifications),
                  label: '通知',
                  badge: '99+',
                ),
                ParkBottomNavItem(icon: Icon(Icons.settings), label: '设置'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
