import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Alert Demo
// =============================================================================

class AlertDemo extends StatelessWidget {
  const AlertDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Alert 警告提示', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('展示带状态颜色的提示信息，支持成功/警告/错误/信息四种类型。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkAlert(type: ParkAlertType.info, message: '这是一条信息提示'),
        const SizedBox(height: 8),
        const ParkAlert(type: ParkAlertType.success, message: '恭喜！操作已成功完成'),
        const SizedBox(height: 8),
        const ParkAlert(type: ParkAlertType.warning, message: '注意：该操作存在风险'),
        const SizedBox(height: 8),
        const ParkAlert(type: ParkAlertType.error, message: '错误：提交数据校验失败'),
        const SizedBox(height: 24),

        ParkText('带描述', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkAlert(
          type: ParkAlertType.warning,
          message: '系统将在今晚 23:00 进行维护',
          description: '预计维护时长 2 小时，期间服务不可用。',
        ),
        const SizedBox(height: 24),

        ParkText('可关闭', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkAlert(
          type: ParkAlertType.info,
          message: '这条提示可以被关闭',
          closable: true,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// ActionSheet Demo
// =============================================================================

class ActionSheetDemo extends StatelessWidget {
  const ActionSheetDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('ActionSheet 操作面板', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('底部弹出的操作面板，提供一组操作选项。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkActionSheet.show(
              context,
              title: '请选择操作',
              actions: [
                ParkAction(label: '拍照', icon: const Icon(Icons.camera_alt)),
                ParkAction(label: '从相册选择', icon: const Icon(Icons.image)),
                ParkAction(label: '保存', icon: const Icon(Icons.save)),
              ],
            );
          },
          child: const Text('弹出操作面板'),
        ),
        const SizedBox(height: 24),

        ParkText('带描述和破坏性操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.danger,
          onPressed: () {
            ParkActionSheet.show(
              context,
              title: '删除确认',
              description: '此操作不可撤销，确定要删除吗？',
              destructiveIndex: 0,
              actions: [
                ParkAction(label: '删除'),
                ParkAction(label: '移至回收站'),
                ParkAction(label: '取消'),
              ],
            );
          },
          child: const Text('删除操作'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// NoticeBar Demo
// =============================================================================

class NoticeBarDemo extends StatelessWidget {
  const NoticeBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('NoticeBar 通知栏', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('页面顶部的通知横幅，支持滚动、关闭和多色变体。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkNoticeBar(text: '这是一条基础通知信息'),
        const SizedBox(height: 8),
        const ParkNoticeBar(
          text: '系统公告：新版本 v2.0 已发布，请前往更新。',
          variant: ParkNoticeBarVariant.success,
        ),
        const SizedBox(height: 8),
        const ParkNoticeBar(
          text: '注意：该功能将在下个月下线',
          variant: ParkNoticeBarVariant.warning,
        ),
        const SizedBox(height: 8),
        const ParkNoticeBar(
          text: '错误：服务连接异常，请稍后重试',
          variant: ParkNoticeBarVariant.error,
        ),
        const SizedBox(height: 24),

        ParkText('可关闭', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkNoticeBar(
          text: '这条通知可以被关闭',
          closable: true,
        ),
        const SizedBox(height: 24),

        ParkText('滚动通知', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkNoticeBar(
          text: '这是一条很长的通知内容，当文字超出容器宽度时会自动滚动显示，适用于公告、跑马灯等场景。',
          scrollable: true,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Popconfirm Demo
// =============================================================================

class PopconfirmDemo extends StatelessWidget {
  const PopconfirmDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Popconfirm 气泡确认框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('点击元素后弹出确认框，用于需要二次确认的操作。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ParkPopconfirm(
              title: '确认删除？',
              description: '删除后将无法恢复',
              onConfirm: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已确认删除')),
                );
              },
              child: ParkButton(
                variant: ParkButtonVariant.danger,
                child: const Text('删除'),
              ),
            ),
            ParkPopconfirm(
              title: '确认提交？',
              onConfirm: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已提交')),
                );
              },
              child: ParkButton(
                variant: ParkButtonVariant.primary,
                child: const Text('提交'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('危险操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkPopconfirm(
          title: '清空所有数据？',
          description: '此操作不可撤销，所有数据将被永久删除。',
          danger: true,
          onConfirm: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('数据已清空')),
            );
          },
          child: ParkButton(
            variant: ParkButtonVariant.danger,
            child: const Text('清空数据'),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// SwipeCell Demo
// =============================================================================

class SwipeCellDemo extends StatelessWidget {
  const SwipeCellDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('SwipeCell 滑动单元格', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('左右滑动揭示操作按钮，常用于列表项操作。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('右侧滑动操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSwipeCell(
          rightActions: [
            ParkSwipeAction(
              label: '标为已读',
              icon: const Icon(Icons.done, size: 18),
              color: Colors.blue,
              onTap: () {},
            ),
            ParkSwipeAction(
              label: '删除',
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.red,
              onTap: () {},
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.mail_outline),
                SizedBox(width: 12),
                Text('向左滑动查看操作'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('双侧操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSwipeCell(
          leftActions: [
            ParkSwipeAction(
              label: '置顶',
              icon: const Icon(Icons.vertical_align_top, size: 18),
              color: Colors.orange,
              onTap: () {},
            ),
          ],
          rightActions: [
            ParkSwipeAction(
              label: '编辑',
              icon: const Icon(Icons.edit, size: 18),
              color: Colors.blue,
              onTap: () {},
            ),
            ParkSwipeAction(
              label: '删除',
              icon: const Icon(Icons.delete, size: 18),
              color: Colors.red,
              onTap: () {},
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.article_outlined),
                SizedBox(width: 12),
                Text('左右滑动查看操作'),
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
