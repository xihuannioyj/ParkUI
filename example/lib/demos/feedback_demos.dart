import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Dialog Demo
// =============================================================================

class DialogDemo extends StatelessWidget {
  const DialogDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Dialog 对话框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('模态对话框，支持 alert / confirm / info 等多种类型。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础对话框', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                ParkDialog.alert(
                  context,
                  title: '提示',
                  content: '这是一个基础提示框。',
                );
              },
              child: const Text('Alert'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkDialog.confirm(
                  context,
                  title: '确认',
                  content: '确定要执行此操作吗？',
                  onConfirm: () {
                    Navigator.of(context).pop();
                  },
                );
              },
              child: const Text('Confirm'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkDialog.info(
                  context,
                  title: '信息',
                  content: '这是一条信息提示。',
                );
              },
              child: const Text('Info'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('自定义内容', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkDialog.alert(
              context,
              title: '自定义内容',
              contentWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('支持在对话框中嵌入任意 Widget：'),
                  const SizedBox(height: 12),
                  ParkInput(label: '名称', hintText: '请输入'),
                  const SizedBox(height: 8),
                  ParkSwitch(value: true, onChanged: (_) {}),
                ],
              ),
            );
          },
          child: const Text('自定义内容对话框'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Toast Demo
// =============================================================================

class ToastDemo extends StatelessWidget {
  const ToastDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Toast 轻提示', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('轻量级全局提示，自动消失。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                ParkToast.show(context, '这是一条提示');
              },
              child: const Text('Show Toast'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkToast.success(context, '操作成功');
              },
              child: const Text('Success'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkToast.error(context, '操作失败');
              },
              child: const Text('Error'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('不同位置', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkToast.show(context, '顶部提示',
                    position: ParkToastPosition.top);
              },
              child: const Text('Top'),
            ),
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkToast.show(context, '中间提示',
                    position: ParkToastPosition.center);
              },
              child: const Text('Center'),
            ),
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkToast.show(context, '底部提示',
                    position: ParkToastPosition.bottom);
              },
              child: const Text('Bottom'),
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
// Loading Demo
// =============================================================================

class LoadingDemo extends StatelessWidget {
  const LoadingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Loading 加载', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('加载指示器，可作为 Widget 或全屏展示。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkLoading(loadingSize: ParkLoadingSize.small),
            ParkLoading(loadingSize: ParkLoadingSize.medium),
            ParkLoading(loadingSize: ParkLoadingSize.large),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('带文字', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkLoading(text: '加载中...'),
        const SizedBox(height: 24),

        ParkText('容器加载', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                SizedBox(
                  height: 150,
                  child: ParkLoading(
                    loading: _containerLoading,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Center(child: Text('内容区域')),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  onPressed: () =>
                      setState(() => _containerLoading = !_containerLoading),
                  child: Text(_containerLoading ? '停止加载' : '开始加载'),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

bool _containerLoading = true;

// =============================================================================
// Notification Demo
// =============================================================================

class NotificationDemo extends StatelessWidget {
  const NotificationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Notification 通知', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('全局通知提醒，从右上角弹出，支持多实例队列。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('通知类型', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                ParkNotification.show(
                  context,
                  type: ParkNotificationType.success,
                  title: '操作成功',
                  description: '数据已成功保存到服务器。',
                );
              },
              child: const Text('Success'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkNotification.show(
                  context,
                  type: ParkNotificationType.info,
                  title: '提示',
                  description: '这是一条信息通知。',
                );
              },
              child: const Text('Info'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkNotification.show(
                  context,
                  type: ParkNotificationType.warning,
                  title: '警告',
                  description: '请注意检查输入数据。',
                );
              },
              child: const Text('Warning'),
            ),
            ParkButton(
              variant: ParkButtonVariant.danger,
              onPressed: () {
                ParkNotification.show(
                  context,
                  type: ParkNotificationType.error,
                  title: '错误',
                  description: '网络异常，请稍后重试。',
                );
              },
              child: const Text('Error'),
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
// Drawer Demo
// =============================================================================

class DrawerDemo extends StatelessWidget {
  const DrawerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Drawer 抽屉', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('从屏幕边缘滑入的面板，支持四个方向、预设尺寸。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                ParkDrawer.show(
                  context,
                  placement: ParkDrawerPlacement.left,
                  header: const Text('左侧抽屉'),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      ListTile(title: Text('菜单项 1')),
                      ListTile(title: Text('菜单项 2')),
                      ListTile(title: Text('菜单项 3')),
                    ],
                  ),
                );
              },
              child: const Text('左侧抽屉'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkDrawer.show(
                  context,
                  placement: ParkDrawerPlacement.right,
                  header: const Text('右侧抽屉'),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('这是右侧抽屉内容。'),
                  ),
                );
              },
              child: const Text('右侧抽屉'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkDrawer.show(
                  context,
                  placement: ParkDrawerPlacement.bottom,
                  size: ParkDrawerSize.small,
                  header: const Text('底部抽屉'),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('这是底部弹出的抽屉。'),
                  ),
                );
              },
              child: const Text('底部抽屉'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('预设尺寸', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkDrawer.show(
                  context,
                  placement: ParkDrawerPlacement.right,
                  size: ParkDrawerSize.small,
                  header: const Text('小尺寸 (256px)'),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('小尺寸抽屉内容。'),
                  ),
                );
              },
              child: const Text('Small'),
            ),
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkDrawer.show(
                  context,
                  placement: ParkDrawerPlacement.right,
                  size: ParkDrawerSize.medium,
                  header: const Text('中尺寸 (378px)'),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('中尺寸抽屉内容。'),
                  ),
                );
              },
              child: const Text('Medium'),
            ),
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkDrawer.show(
                  context,
                  placement: ParkDrawerPlacement.right,
                  size: ParkDrawerSize.large,
                  header: const Text('大尺寸 (520px)'),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('大尺寸抽屉内容。'),
                  ),
                );
              },
              child: const Text('Large'),
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
// Message Demo
// =============================================================================

class MessageDemo extends StatelessWidget {
  const MessageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Message 全局消息', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('全局消息提示，从顶部滑入，自动消失。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('消息类型', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {
                ParkMessage.info(context, '这是一条信息提示');
              },
              child: const Text('Info'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkMessage.success(context, '操作成功',
                    content: '数据已保存到服务器');
              },
              child: const Text('Success'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkMessage.warning(context, '请注意',
                    content: '该操作不可撤销');
              },
              child: const Text('Warning'),
            ),
            ParkButton(
              variant: ParkButtonVariant.danger,
              onPressed: () {
                ParkMessage.error(context, '操作失败',
                    content: '网络异常，请稍后重试');
              },
              child: const Text('Error'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {
                ParkMessage.loading(context, '加载中...');
              },
              child: const Text('Loading'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('不同位置', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkMessage.info(context, '顶部消息',
                    position: ParkMessagePosition.top);
              },
              child: const Text('Top'),
            ),
            ParkButton(
              variant: ParkButtonVariant.text,
              onPressed: () {
                ParkMessage.info(context, '底部消息',
                    position: ParkMessagePosition.bottom);
              },
              child: const Text('Bottom'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
