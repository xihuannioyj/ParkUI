import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkRefreshView Demo
// =============================================================================

class RefreshViewDemo extends StatefulWidget {
  const RefreshViewDemo({super.key});

  @override
  State<RefreshViewDemo> createState() => _RefreshViewDemoState();
}

class _RefreshViewDemoState extends State<RefreshViewDemo> {
  int _itemCount = 20;
  bool _noMore = false;

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _itemCount = 20;
      _noMore = false;
    });
  }

  Future<void> _handleLoadMore() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _itemCount += 10;
      if (_itemCount >= 40) {
        _noMore = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('RefreshView 刷新视图', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('统一页面刷新包装器：下拉刷新 + 可选上拉加载更多。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法（下拉刷新）', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: ParkRefreshView(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              itemCount: _itemCount,
              itemBuilder: (_, i) => ParkCell(
                size: ParkCellSize.small,
                titleText: '列表项 ${i + 1}',
                bordered: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('上拉加载更多', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: ParkRefreshView(
            onRefresh: _handleRefresh,
            pullUpLoadMore: true,
            onLoadMore: _handleLoadMore,
            noMore: _noMore,
            child: ListView.builder(
              itemCount: _itemCount,
              itemBuilder: (_, i) => ParkCell(
                size: ParkCellSize.small,
                titleText: '数据项 ${i + 1}',
                bordered: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('原生 RefreshIndicator 模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: ParkRefreshView(
            onRefresh: _handleRefresh,
            useMaterialRefreshIndicator: true,
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (_, i) => ParkCell(
                size: ParkCellSize.small,
                titleText: '原生刷新项 ${i + 1}',
                bordered: false,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
