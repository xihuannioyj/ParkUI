import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Table Demo
// =============================================================================

class TableDemo extends StatelessWidget {
  const TableDemo({super.key});

  static const List<Map<String, dynamic>> _data = [
    {'name': '张三', 'age': 28, 'address': '北京市朝阳区'},
    {'name': '李四', 'age': 32, 'address': '上海市浦东新区'},
    {'name': '王五', 'age': 25, 'address': '广州市天河区'},
    {'name': '赵六', 'age': 30, 'address': '深圳市南山区'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Table 表格', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('数据表格，支持排序、固定列、行选择等。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础表格', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTable(
          columns: const [
            ParkTableColumn(key: 'name', title: '姓名', width: 100),
            ParkTableColumn(key: 'age', title: '年龄', width: 80,
                align: ParkTableColumnAlign.center),
            ParkTableColumn(key: 'address', title: '地址'),
          ],
          data: _data,
        ),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTable(
          size: ParkTableSize.small,
          columns: const [
            ParkTableColumn(key: 'name', title: '姓名', width: 100),
            ParkTableColumn(key: 'age', title: '年龄', width: 80),
            ParkTableColumn(key: 'address', title: '地址'),
          ],
          data: _data.take(2).toList(),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Card Demo
// =============================================================================

class CardDemo extends StatelessWidget {
  const CardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Card 卡片', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('卡片容器，支持标题、操作区、封面图、悬浮效果。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础卡片', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCard(
          titleText: '卡片标题',
          child: const Text('这是一个基础卡片示例，包含标题和内容区域。'),
        ),
        const SizedBox(height: 16),

        ParkText('带操作区', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCard(
          titleText: '操作卡片',
          extra: ParkButton(
            variant: ParkButtonVariant.text,
            onPressed: () {},
            child: const Text('更多'),
          ),
          child: const Text('右上角有额外操作按钮。'),
        ),
        const SizedBox(height: 16),

        ParkText('悬浮效果', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCard(
          titleText: 'Hoverable',
          hoverable: true,
          child: const Text('鼠标悬浮时有阴影提升效果。'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Avatar Demo
// =============================================================================

class AvatarDemo extends StatelessWidget {
  const AvatarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Avatar 头像', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('用户头像，支持图片/图标/文字回退、多种尺寸和形状。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('尺寸预设', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkAvatar(text: 'S', size: ParkAvatarSize.small),
            ParkAvatar(text: 'M', size: ParkAvatarSize.medium),
            ParkAvatar(text: 'L', size: ParkAvatarSize.large),
            ParkAvatar(text: 'XL', size: ParkAvatarSize.xlarge),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('形状变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkAvatar(text: '圆', shape: ParkAvatarShape.circle),
            ParkAvatar(text: '方', shape: ParkAvatarShape.square),
            ParkAvatar(icon: Icons.person),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('状态指示', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkAvatar(text: '在', status: ParkAvatarStatus.online),
            ParkAvatar(text: '离', status: ParkAvatarStatus.offline),
            ParkAvatar(text: '忙', status: ParkAvatarStatus.busy),
            ParkAvatar(text: '离', status: ParkAvatarStatus.away),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Badge Demo
// =============================================================================

class BadgeDemo extends StatelessWidget {
  const BadgeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Badge 徽标', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('数字角标、小红点、状态点、缎带。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('数字角标', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          children: [
            ParkBadge(
              count: 5,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            ParkBadge(
              count: 100,
              maxCount: 99,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('小红点 & 状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const ParkBadge(
              dot: true,
              child: Icon(Icons.mail, size: 28),
            ),
            const ParkBadge(status: ParkBadgeStatus.success),
            const ParkBadge(status: ParkBadgeStatus.error),
            const ParkBadge(status: ParkBadgeStatus.warning),
            const ParkBadge(status: ParkBadgeStatus.info),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Tag Demo
// =============================================================================

class TagDemo extends StatelessWidget {
  const TagDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Tag 标签', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('标记和选择，支持多种颜色主题、变体、可关闭。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('颜色主题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            ParkTag(text: '默认', theme: ParkTagTheme.defaultTheme),
            ParkTag(text: '主要', theme: ParkTagTheme.primary),
            ParkTag(text: '成功', theme: ParkTagTheme.success),
            ParkTag(text: '警告', theme: ParkTagTheme.warning),
            ParkTag(text: '危险', theme: ParkTagTheme.danger),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            ParkTag(text: 'Light', variant: ParkTagVariant.light,
                theme: ParkTagTheme.primary),
            ParkTag(text: 'Dark', variant: ParkTagVariant.dark,
                theme: ParkTagTheme.primary),
            ParkTag(text: 'Outline', variant: ParkTagVariant.outline,
                theme: ParkTagTheme.primary),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('尺寸 & 可关闭', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            const ParkTag(text: 'Small', size: ParkTagSize.small,
                theme: ParkTagTheme.primary),
            const ParkTag(text: 'Medium', size: ParkTagSize.medium,
                theme: ParkTagTheme.primary),
            const ParkTag(text: 'Large', size: ParkTagSize.large,
                theme: ParkTagTheme.primary),
            ParkTag(
              text: '可关闭',
              theme: ParkTagTheme.success,
              closable: true,
              onClose: () {},
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
// Descriptions Demo
// =============================================================================

class DescriptionsDemo extends StatelessWidget {
  const DescriptionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Descriptions 描述列表', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('以列表形式展示多个只读字段，支持边框/分隔线两种风格。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDescriptions(
          title: '用户信息',
          column: 2,
          items: [
            ParkDescriptionItem(label: '姓名', value: '张三'),
            ParkDescriptionItem(label: '手机号', value: '13800138000'),
            ParkDescriptionItem(label: '邮箱', value: 'zhangsan@example.com'),
            ParkDescriptionItem(label: '城市', value: '北京'),
            ParkDescriptionItem(label: '地址', value: '北京市朝阳区建国路88号', span: 2),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('边框风格', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDescriptions(
          title: '订单详情',
          column: 2,
          bordered: true,
          items: [
            ParkDescriptionItem(label: '订单号', value: 'DD20260701001'),
            ParkDescriptionItem(label: '状态', value: '已支付'),
            ParkDescriptionItem(label: '金额', value: '¥ 1,280.00'),
            ParkDescriptionItem(label: '创建时间', value: '2026-07-01 14:30'),
            ParkDescriptionItem(label: '备注', value: '请尽快发货', span: 2),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('垂直布局', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDescriptions(
          title: '商品信息',
          column: 3,
          bordered: true,
          layout: ParkDescriptionsLayout.vertical,
          items: [
            ParkDescriptionItem(label: '商品名称', value: 'Flutter 实战'),
            ParkDescriptionItem(label: '作者', value: '张三'),
            ParkDescriptionItem(label: '价格', value: '¥ 69.00'),
            ParkDescriptionItem(label: '出版社', value: '电子工业出版社'),
            ParkDescriptionItem(label: 'ISBN', value: '978-7-121-12345-6'),
            ParkDescriptionItem(label: '库存', value: '120'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDescriptions(
          title: '小尺寸',
          column: 2,
          size: ParkDescriptionsSize.small,
          items: [
            ParkDescriptionItem(label: '字段 A', value: '值 A'),
            ParkDescriptionItem(label: '字段 B', value: '值 B'),
          ],
        ),
        const SizedBox(height: 12),
        const ParkDescriptions(
          column: 2,
          size: ParkDescriptionsSize.large,
          items: [
            ParkDescriptionItem(label: '字段 A', value: '值 A'),
            ParkDescriptionItem(label: '字段 B', value: '值 B'),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
