import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 页面布局组件
///
/// 提供 Header + Sidebar + Content + Footer 四区域标准页面布局。
///
/// ```dart
/// ParkLayout(
///   header: ParkNavBar(title: '管理系统'),
///   sidebar: ParkSideBar(items: [...]),
///   body: Center(child: Text('内容区')),
///   footer: ParkFooter(links: [...]),
/// )
/// ```
class ParkLayout extends StatelessWidget {
  /// 顶栏区域。
  final Widget? header;

  /// 侧边栏区域。
  final Widget? sidebar;

  /// 主体内容区域。
  final Widget body;

  /// 页脚区域。
  final Widget? footer;

  /// 侧边栏宽度（默认 240）。
  final double sidebarWidth;

  /// 侧边栏位置（默认 left）。
  final bool sidebarLeft;

  /// 是否显示侧边栏分割线。
  final bool showSidebarDivider;

  /// 创建 [ParkLayout]。
  const ParkLayout({
    super.key,
    this.header,
    this.sidebar,
    required this.body,
    this.footer,
    this.sidebarWidth = 240,
    this.sidebarLeft = true,
    this.showSidebarDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Scaffold(
      body: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sidebar != null && sidebarLeft) _buildSidebar(park),
                if (sidebar != null && sidebarLeft && showSidebarDivider)
                  _buildDivider(park),
                Expanded(child: body),
                if (sidebar != null && !sidebarLeft && showSidebarDivider)
                  _buildDivider(park),
                if (sidebar != null && !sidebarLeft) _buildSidebar(park),
              ],
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }

  Widget _buildSidebar(ParkThemeData park) {
    return Semantics(
      label: '侧边栏',
      container: true,
      child: SizedBox(
        width: sidebarWidth,
        child: Material(
          color: park.colors.surface,
          child: sidebar!,
        ),
      ),
    );
  }

  Widget _buildDivider(ParkThemeData park) {
    return VerticalDivider(
      width: 1,
      color: park.colors.borderLight,
    );
  }
}
