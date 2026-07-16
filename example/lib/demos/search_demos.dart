import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Search Demo
// =============================================================================

class SearchDemo extends StatelessWidget {
  const SearchDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Search 搜索', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('搜索输入框，支持清除、取消按钮、自定义搜索操作。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础搜索', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSearch(
          hintText: '请输入搜索关键词',
          onChanged: (v) {},
        ),
        const SizedBox(height: 24),

        ParkText('带取消按钮', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSearch(
          hintText: '搜索商品',
          showCancel: true,
          onChanged: (v) {},
        ),
        const SizedBox(height: 24),

        ParkText('自定义操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSearch(
          hintText: '搜索',
          actionText: '搜索',
          shape: ParkSearchShape.square,
          onSearch: (v) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Search: $v')),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
