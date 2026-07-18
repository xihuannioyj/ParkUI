import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Overlay Demo
// =============================================================================

class OverlayDemo extends StatelessWidget {
  const OverlayDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Overlay 遮罩层', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('全屏遮罩层，支持静态调用和声明式使用。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('声明式用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Container(
                color: Colors.grey.shade200,
                child: const Center(child: Text('底层内容')),
              ),
              const ParkOverlay(
                visible: true,
                child: Center(
                  child: Text('遮罩内容', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ParkText('静态调用', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkOverlay.show(
              context,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('点击遮罩关闭'),
                ),
              ),
            );
          },
          child: const Text('显示遮罩'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Popup Demo
// =============================================================================

class PopupDemo extends StatelessWidget {
  const PopupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Popup 弹出面板', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('支持中心/底部/顶部弹出，多种动画过渡。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('底部弹出', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => ParkPopup(
                visible: true,
                position: ParkPopupPosition.bottom,
                onDismiss: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: const Text('底部弹出内容'),
                ),
              ),
            );
          },
          child: const Text('底部弹出'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Refresh Demo
// =============================================================================

class RefreshDemo extends StatelessWidget {
  const RefreshDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Refresh 下拉刷新', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('下拉刷新和上拉加载更多。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ParkRefresh(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (_, i) => ListTile(title: Text('列表项 ${i + 1}')),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// DropdownMenu Demo
// =============================================================================

class DropdownMenuDemo extends StatelessWidget {
  const DropdownMenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('DropdownMenu 下拉菜单', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('悬浮/点击展开菜单，支持子菜单嵌套。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkDropdownMenu(
          items: const [
            ParkDropdownMenuItem(label: '菜单项一', value: '1'),
            ParkDropdownMenuItem(label: '菜单项二', value: '2'),
            ParkDropdownMenuItem(label: '菜单项三', value: '3'),
          ],
          trigger: ParkButton(
            variant: ParkButtonVariant.secondary,
            onPressed: () {},
            child: const Text('打开菜单'),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// DropdownSheet Demo
// =============================================================================

class DropdownSheetDemo extends StatelessWidget {
  const DropdownSheetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('DropdownSheet 下拉面板', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('底部弹出式面板，支持选项列表和自定义内容。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('选项列表模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkDropdownSheet(
          title: '选择城市',
          items: const [
            ParkDropdownSheetItem(label: '北京', value: 'bj'),
            ParkDropdownSheetItem(label: '上海', value: 'sh'),
            ParkDropdownSheetItem(label: '广州', value: 'gz'),
          ],
          onConfirm: (_) {},
          trigger: ParkButton(
            variant: ParkButtonVariant.secondary,
            onPressed: () {},
            child: const Text('选择城市'),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// DropdownFilter Demo
// =============================================================================

class DropdownFilterDemo extends StatelessWidget {
  const DropdownFilterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('DropdownFilter 筛选过滤', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('多条件筛选标签栏，点击展开下拉面板。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkDropdownFilter(
          items: [
            DropdownFilterItem(
              label: '状态',
              options: const [
                DropdownFilterOption(label: '全部', value: 'all'),
                DropdownFilterOption(label: '进行中', value: 'active'),
                DropdownFilterOption(label: '已完成', value: 'done'),
              ],
            ),
            DropdownFilterItem(
              label: '类型',
              options: const [
                DropdownFilterOption(label: '全部', value: 'all'),
                DropdownFilterOption(label: '普通', value: 'normal'),
                DropdownFilterOption(label: '紧急', value: 'urgent'),
              ],
            ),
          ],
          onFilterChanged: (_, __) {},
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
