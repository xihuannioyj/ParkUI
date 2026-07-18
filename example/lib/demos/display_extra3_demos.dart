import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Grid Demo
// =============================================================================

class GridDemo extends StatelessWidget {
  const GridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Grid 网格布局', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('等分或自适应网格布局，支持边框和分割线。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('等分三列', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkGrid(
          columnCount: 3,
          spacing: 8,
          bordered: true,
          itemHeight: 60,
          items: List.generate(
            9,
            (i) => ParkGridItem(label: '格子 ${i + 1}', icon: Icons.grid_view),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('带角标和禁用', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkGrid(
          columnCount: 4,
          spacing: 8,
          itemHeight: 70,
          items: const [
            ParkGridItem(label: '消息', icon: Icons.message, badge: '5'),
            ParkGridItem(label: '收藏', icon: Icons.star),
            ParkGridItem(label: '下载', icon: Icons.download, disabled: true),
            ParkGridItem(label: '设置', icon: Icons.settings),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Footer Demo
// =============================================================================

class FooterDemo extends StatelessWidget {
  const FooterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Footer 页脚', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('页面底部品牌链接和版权信息。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        const ParkFooter(
          text: 'Park UI',
          links: [
            ParkFooterLink(label: '关于我们'),
            ParkFooterLink(label: '服务条款'),
            ParkFooterLink(label: '隐私政策'),
          ],
          copyright: '(c) 2025 Park UI. All rights reserved.',
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Splitter Demo
// =============================================================================

class SplitterDemo extends StatelessWidget {
  const SplitterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Splitter 分割面板', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('可拖拽分隔两个面板，支持水平/垂直方向。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('水平分割', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkSplitter(
            axis: Axis.horizontal,
            first: Container(
              color: Colors.blue.shade50,
              child: const Center(child: Text('左侧面板')),
            ),
            second: Container(
              color: Colors.green.shade50,
              child: const Center(child: Text('右侧面板')),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('垂直分割', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ParkSplitter(
            axis: Axis.vertical,
            collapsible: true,
            first: Container(
              color: Colors.orange.shade50,
              child: const Center(child: Text('上方面板')),
            ),
            second: Container(
              color: Colors.purple.shade50,
              child: const Center(child: Text('下方面板')),
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
// ImageViewer Demo
// =============================================================================

class ImageViewerDemo extends StatelessWidget {
  const ImageViewerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('ImageViewer 图片查看器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('全屏查看图片，支持缩放、旋转和多图翻页。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('点击打开查看器', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkImageViewer.show(
              context,
              images: const [
                NetworkImage('https://picsum.photos/400/300?1'),
                NetworkImage('https://picsum.photos/400/300?2'),
              ],
            );
          },
          child: const Text('打开图片查看器'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Sticky Demo
// =============================================================================

class StickyDemo extends StatelessWidget {
  const StickyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParkText('Sticky 粘性定位', preset: ParkTextPreset.h2),
              const SizedBox(height: 8),
              ParkText('滚动到指定位置时子组件吸顶固定。', preset: ParkTextPreset.caption),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('向下滚动查看吸顶效果')),
                ),
                ParkSticky(
                  stickyOffset: 0,
                  child: Container(
                    color: Colors.blue.shade100,
                    padding: const EdgeInsets.all(12),
                    child: const Text('吸顶标题', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                ...List.generate(
                  15,
                  (i) => ListTile(title: Text('列表项 ${i + 1}')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// AvatarGroup Demo
// =============================================================================

class AvatarGroupDemo extends StatelessWidget {
  const AvatarGroupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('AvatarGroup 头像组', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('头像组合展示，支持重叠排列和溢出显示 +N。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkAvatarGroup(
          avatars: const [
            ParkAvatar(text: '张'),
            ParkAvatar(text: '李'),
            ParkAvatar(text: '王'),
            ParkAvatar(text: '赵'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('限制最大显示数量', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkAvatarGroup(
          maxCount: 3,
          avatars: const [
            ParkAvatar(text: 'A'),
            ParkAvatar(text: 'B'),
            ParkAvatar(text: 'C'),
            ParkAvatar(text: 'D'),
            ParkAvatar(text: 'E'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('不同尺寸', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkText('小尺寸', preset: ParkTextPreset.caption),
        const SizedBox(height: 8),
        ParkAvatarGroup(
          size: ParkAvatarSize.small,
          avatars: const [
            ParkAvatar(text: '一'),
            ParkAvatar(text: '二'),
            ParkAvatar(text: '三'),
          ],
        ),
        const SizedBox(height: 12),
        ParkText('大尺寸', preset: ParkTextPreset.caption),
        const SizedBox(height: 8),
        ParkAvatarGroup(
          size: ParkAvatarSize.large,
          avatars: const [
            ParkAvatar(icon: Icons.person),
            ParkAvatar(icon: Icons.group),
            ParkAvatar(icon: Icons.people),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
