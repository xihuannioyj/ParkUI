import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// SideBar Demo
// =============================================================================

class SideBarDemo extends StatelessWidget {
  const SideBarDemo({super.key});

  static const List<ParkSideBarItem> _menuItems = [
    ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
    ParkSideBarItem(icon: Icons.people, label: '用户管理', badge: '12'),
    ParkSideBarItem(
      icon: Icons.inventory_2,
      label: '商品管理',
      children: [
        ParkSideBarItem(icon: Icons.list, label: '商品列表'),
        ParkSideBarItem(icon: Icons.category, label: '分类管理'),
        ParkSideBarItem(icon: Icons.local_offer, label: '标签管理'),
      ],
    ),
    ParkSideBarItem(
      icon: Icons.shopping_cart,
      label: '订单中心',
      badge: '3',
      children: [
        ParkSideBarItem(icon: Icons.receipt_long, label: '全部订单'),
        ParkSideBarItem(icon: Icons.pending_actions, label: '待处理'),
        ParkSideBarItem(icon: Icons.check_circle_outline, label: '已完成'),
      ],
    ),
    ParkSideBarItem(icon: Icons.bar_chart, label: '数据分析'),
    ParkSideBarItem(icon: Icons.settings, label: '系统设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('SideBar 侧边栏', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('侧边导航栏，支持多级菜单、折叠、角标和暗色主题。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ParkSideBar(
                items: _menuItems,
                selectedIndex: _sideBarIndex,
                showCollapseButton: true,
                collapsed: _sideBarCollapsed,
                onCollapseToggle: () =>
                    setState(() => _sideBarCollapsed = !_sideBarCollapsed),
                onChanged: (index) => setState(() => _sideBarIndex = index),
                logo: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1677FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text('P',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (!_sideBarCollapsed) ...[
                        const SizedBox(width: 8),
                        const Text('Park UI',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('暗色主题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ParkSideBar(
                items: _menuItems,
                selectedIndex: _sideBarDarkIndex,
                theme: ParkSideBarTheme.dark,
                onChanged: (index) =>
                    setState(() => _sideBarDarkIndex = index),
                logo: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Text('P',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Dark Mode',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
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

int _sideBarIndex = 0;
int _sideBarDarkIndex = 0;
bool _sideBarCollapsed = false;
