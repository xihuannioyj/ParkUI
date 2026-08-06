import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkActionEntry Demo
// =============================================================================

class ActionEntryDemo extends StatelessWidget {
  const ActionEntryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('ActionEntry 操作入口', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('图标操作按钮与平铺操作入口，支持主色/中性/危险三种色调。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('ParkActionIconButton 色调', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ParkActionIconButton(
              icon: Icons.edit_outlined,
              onPressed: () => ParkToast.show(context, '编辑'),
              tooltip: '编辑',
            ),
            ParkActionIconButton(
              icon: Icons.share_outlined,
              onPressed: () => ParkToast.show(context, '分享'),
              tone: ParkActionTone.neutral,
              tooltip: '分享',
            ),
            ParkActionIconButton(
              icon: Icons.delete_outline,
              onPressed: () => ParkToast.show(context, '删除'),
              tone: ParkActionTone.danger,
              tooltip: '删除',
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('图标尺寸与禁用态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ParkActionIconButton(
              icon: Icons.add,
              onPressed: () => ParkToast.show(context, '新增'),
              iconSize: 22,
            ),
            ParkActionIconButton(
              icon: Icons.favorite_border,
              onPressed: null,
              tone: ParkActionTone.danger,
              tooltip: '禁用态',
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('ParkActionTile 平铺操作项', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkActionTile(
          icon: Icons.badge_outlined,
          title: '实名认证',
          subtitle: '完成认证后可发布房源',
          trailingText: '待认证',
          onTap: () => ParkToast.show(context, '进入实名认证'),
        ),
        const SizedBox(height: 12),
        ParkActionTile(
          icon: Icons.description_outlined,
          title: '合同模板',
          subtitle: '查看常用合同模板',
          onTap: () => ParkToast.show(context, '打开合同模板'),
          tone: ParkActionTone.neutral,
        ),
        const SizedBox(height: 12),
        ParkActionTile(
          icon: Icons.logout_rounded,
          title: '退出登录',
          subtitle: '退出当前账号',
          onTap: () => ParkToast.show(context, '退出登录'),
          tone: ParkActionTone.danger,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
