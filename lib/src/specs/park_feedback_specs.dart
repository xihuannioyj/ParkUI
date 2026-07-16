// Park 反馈组件规格 — 由 Agent 填充
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

// ===========================================================================
// 命名令牌常量（对齐 ParkColors / ParkSpacing / ParkTypography 设计令牌，
// 杜绝裸字面量 / 魔法变量）
// ===========================================================================
final ParkColors _kColors = ParkColors.light();

/// 反馈组件规格字典（11 个组件）。
Map<String, ParkComponentSpec> get parkFeedbackSpecs =>
    <String, ParkComponentSpec>{
      'ParkDialog': _parkDialog,
      'ParkToast': _parkToast,
      'ParkLoading': _parkLoading,
      'ParkActionSheet': _parkActionSheet,
      'ParkPopup': _parkPopup,
      'ParkDropdownMenu': _parkDropdownMenu,
      'ParkNoticeBar': _parkNoticeBar,
      'ParkMessage': _parkMessage,
      'ParkPopover': _parkPopover,
      'ParkRefresh': _parkRefresh,
      'ParkSwipeCell': _parkSwipeCell,
    };

// ---------------------------------------------------------------------------
// ParkDialog
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDialog = ParkComponentSpec(
  name: 'ParkDialog',
  title: '对话框',
  category: 'feedback',
  description: '对话框组件，支持 alert（单按钮）和 confirm（双按钮）两种静态调用方式，通过 Overlay 弹出并返回 Future<void>。',
  icon: Icons.chat_bubble_outline,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String',
      required: true,
      description: '对话框标题',
    ),
    ParkPropertyDef(
      name: 'content',
      type: 'String?',
      defaultVal: 'null',
      description: '对话框正文内容',
    ),
    ParkPropertyDef(
      name: 'confirmText',
      type: 'String',
      defaultVal: "'确定'",
      description: '确认按钮文本',
    ),
    ParkPropertyDef(
      name: 'cancelText',
      type: 'String?',
      defaultVal: 'null',
      description: '取消按钮文本，为 null 时不显示取消按钮',
    ),
    ParkPropertyDef(
      name: 'actions',
      type: 'List<Widget>?',
      defaultVal: 'null',
      description: '自定义操作按钮列表。非 null 时将替代默认的确认/取消按钮和 footer，渲染为右对齐按钮行。各按钮的 onPressed 需由调用方自行管理。',
    ),
    ParkPropertyDef(
      name: 'barrierDismissible',
      type: 'bool',
      defaultVal: 'true',
      description: '点击遮罩是否可关闭对话框',
    ),
    ParkPropertyDef(
      name: 'centered',
      type: 'bool',
      defaultVal: 'false',
      description: '对话框是否在视口中垂直居中',
    ),
    ParkPropertyDef(
      name: 'closable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在右上角显示关闭按钮（X）',
    ),
    ParkPropertyDef(
      name: 'confirmLoading',
      type: 'bool',
      defaultVal: 'false',
      description: '确认按钮是否显示加载态',
    ),
    ParkPropertyDef(
      name: 'keyboard',
      type: 'bool',
      defaultVal: 'true',
      description: '按 Esc 键是否关闭对话框',
    ),
    ParkPropertyDef(
      name: 'width',
      type: 'double?',
      defaultVal: 'null',
      description: '自定义对话框宽度，null 时使用内置约束',
    ),
    ParkPropertyDef(
      name: 'footer',
      type: 'Widget?',
      defaultVal: 'null',
      description: '完全自定义底部区域，替换默认按钮行',
    ),
    ParkPropertyDef(
      name: 'maskClosable',
      type: 'bool',
      defaultVal: 'true',
      description: '点击遮罩层是否关闭对话框',
    ),
    ParkPropertyDef(
      name: 'contentWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义对话框主体内容（表单、列表、图片等），提供时替代 content 字符串',
    ),
    ParkPropertyDef(
      name: 'titleWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '富标题（含图标或样式化文字），提供时替代 title 字符串渲染',
    ),
    ParkPropertyDef(
      name: 'fullscreen',
      type: 'bool',
      defaultVal: 'false',
      description: '对话框是否全屏显示',
    ),
    ParkPropertyDef(
      name: 'destroyOnClose',
      type: 'bool',
      defaultVal: 'false',
      description: '关闭时是否销毁对话框内容（unmount）',
    ),
    ParkPropertyDef(
      name: 'closeIcon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义关闭图标，替换 closable 为 true 时的默认 X 图标',
    ),
    ParkPropertyDef(
      name: 'mask',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示遮罩层背景。为 false 时不渲染遮罩',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onConfirm',
      signature: 'VoidCallback?',
      description: '点击确认按钮时的回调',
    ),
    ParkEventDef(
      name: 'onCancel',
      signature: 'VoidCallback?',
      description: '点击取消按钮时的回调',
    ),
    ParkEventDef(
      name: 'afterClose',
      signature: 'VoidCallback?',
      description: '对话框关闭动画完成后的回调',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'alert',
      signature:
          'static Future<void> alert(BuildContext context, {required String title, String? content, String confirmText, VoidCallback? onConfirm, bool centered, bool closable, bool fullscreen})',
      description: '弹出 alert 对话框（仅一个确认按钮），关闭后 Future 完成',
    ),
    ParkMethodDef(
      name: 'confirm',
      signature:
          'static Future<void> confirm(BuildContext context, {required String title, String? content, String confirmText, String cancelText, VoidCallback? onConfirm, VoidCallback? onCancel, bool centered, bool closable, bool fullscreen})',
      description: '弹出 confirm 对话框（确认 + 取消两个按钮），关闭后 Future 完成',
    ),
    ParkMethodDef(
      name: 'info',
      signature:
          'static Future<void> info(BuildContext context, {required String title, String? content, String confirmText, VoidCallback? onConfirm, IconData? icon})',
      description: '弹出 info 对话框（信息提示，带信息图标，仅一个确认按钮）',
    ),
    ParkMethodDef(
      name: 'success',
      signature:
          'static Future<void> success(BuildContext context, {required String title, String? content, String confirmText, VoidCallback? onConfirm, IconData? icon})',
      description: '弹出 success 对话框（成功提示，带成功图标）',
    ),
    ParkMethodDef(
      name: 'warning',
      signature:
          'static Future<void> warning(BuildContext context, {required String title, String? content, String confirmText, VoidCallback? onConfirm, IconData? icon})',
      description: '弹出 warning 对话框（警告提示，带警告图标）',
    ),
    ParkMethodDef(
      name: 'error',
      signature:
          'static Future<void> error(BuildContext context, {required String title, String? content, String confirmText, VoidCallback? onConfirm, IconData? icon})',
      description: '弹出 error 对话框（错误提示，带错误图标）',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: 'Alert 对话框',
      description: '仅包含确认按钮的提示对话框',
      code: "ParkDialog.alert(context, title: '提示', content: '操作已完成')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.alert(
          context,
          title: '提示',
          content: '操作已完成',
        ),
        child: const Text('Alert 对话框'),
      ),
    ),
    ParkDemoScenario(
      title: '确认对话框',
      description: '带确认和取消按钮的对话框',
      code:
          "ParkDialog.confirm(context, title: '提示', content: '确定要删除这条记录吗？')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.confirm(
          context,
          title: '提示',
          content: '确定要删除这条记录吗？',
        ),
        child: const Text('确认对话框'),
      ),
    ),
    ParkDemoScenario(
      title: '自定义按钮文本',
      description: '自定义确认和取消按钮的文本',
      code:
          "ParkDialog.confirm(context, title: '退出', content: '确定要退出当前页面吗？', confirmText: '退出', cancelText: '留下')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.confirm(
          context,
          title: '退出',
          content: '确定要退出当前页面吗？',
          confirmText: '退出',
          cancelText: '留下',
        ),
        child: const Text('自定义按钮'),
      ),
    ),
    ParkDemoScenario(
      title: '带回调的对话框',
      description: '在确认或取消时执行回调逻辑',
      code:
          "ParkDialog.confirm(context, title: '保存', content: '是否保存修改？', onConfirm: () => ParkToast.show(context, '已保存'))",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.confirm(
          context,
          title: '保存',
          content: '是否保存修改？',
          onConfirm: () => ParkToast.show(context, '已保存'),
          onCancel: () => ParkToast.show(context, '已取消'),
        ),
        child: const Text('带回调'),
      ),
    ),
    ParkDemoScenario(
      title: 'Info 对话框',
      description: '带信息图标的提示对话框',
      code: "ParkDialog.info(context, title: '提示', content: '这是一条信息')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () =>
            ParkDialog.info(context, title: '提示', content: '这是一条信息'),
        child: const Text('Info 对话框'),
      ),
    ),
    ParkDemoScenario(
      title: 'Success 对话框',
      description: '带成功图标的对话框',
      code: "ParkDialog.success(context, title: '成功', content: '操作已完成')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.success(
          context,
          title: '成功',
          content: '操作已完成',
        ),
        child: const Text('Success 对话框'),
      ),
    ),
    ParkDemoScenario(
      title: 'Warning 对话框',
      description: '带警告图标的对话框',
      code: "ParkDialog.warning(context, title: '警告', content: '磁盘空间不足')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.warning(
          context,
          title: '警告',
          content: '磁盘空间不足',
        ),
        child: const Text('Warning 对话框'),
      ),
    ),
    ParkDemoScenario(
      title: 'Error 对话框',
      description: '带错误图标的对话框',
      code: "ParkDialog.error(context, title: '错误', content: '请求失败')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () =>
            ParkDialog.error(context, title: '错误', content: '请求失败'),
        child: const Text('Error 对话框'),
      ),
    ),
    ParkDemoScenario(
      title: '居中 + 可关闭',
      description: '垂直居中显示并带右上角关闭按钮的对话框',
      code:
          "ParkDialog.success(context, title: '完成', content: '已提交', centered: true, closable: true)",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkDialog.success(
          context,
          title: '完成',
          content: '已提交',
          centered: true,
          closable: true,
        ),
        child: const Text('居中 + 可关闭'),
      ),
    ),
    ParkDemoScenario(
      title: '自定义 actions 按钮',
      description: '使用 actions 参数替换默认按钮，传入自定义按钮组。各按钮的 onPressed 由调用方管理，通常调用 Navigator.pop 关闭对话框。',
      code: '''
showDialog(
  context: context,
  builder: (ctx) => ParkDialog(
    title: '操作确认',
    content: '请选择后续操作：',
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('取消'),
      ),
      OutlinedButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('暂存'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(ctx);
          // 执行保存
        },
        child: const Text('保存'),
      ),
    ],
  ),
);
''',
      builder: (BuildContext context) => ParkButton(
        onPressed: () => showDialog(
          context: context,
          builder: (ctx) => ParkDialog(
            title: '操作确认',
            content: '请选择后续操作：',
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('暂存'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // 执行保存
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
        child: const Text('自定义 actions'),
      ),
    ),
    ParkDemoScenario(
      title: 'afterClose 关闭回调',
      description: '对话框关闭后触发 afterClose / Fires afterClose after the dialog closes',
      code: '''ParkDialog(
  title: '事件演示',
  content: '关闭后触发 afterClose',
  afterClose: () => print('afterClose'),
)''',
      builder: (BuildContext context) {
        String log = '等待关闭对话框';
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext dlgCtx) {
                      VoidCallback afterClose = () {
                        log = 'afterClose 触发';
                        setState(() {});
                        ParkToast.show(context, 'afterClose 触发');
                      };
                      return ParkDialog(
                        title: '事件演示',
                        content: '关闭后触发 afterClose',
                        afterClose: afterClose,
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              afterClose();
                              Navigator.pop(dlgCtx);
                            },
                            child: const Text('关闭'),
                          ),
                        ],
                      );
                    },
                  ),
                  child: const ParkText('打开对话框'),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  basicUsageCode: '''
// Alert 对话框
ParkDialog.alert(context,
  title: '提示',
  content: '操作已完成',
);

// Confirm 对话框
await ParkDialog.confirm(context,
  title: '删除确认',
  content: '确定要删除这条记录吗？',
  confirmText: '删除',
  cancelText: '取消',
  onConfirm: () {
    // 执行删除逻辑
  },
);

// 语义化对话框
ParkDialog.success(context, title: '成功', content: '保存成功', centered: true);
ParkDialog.error(context, title: '失败', content: '网络异常');

// 自定义 actions 按钮
showDialog(
  context: context,
  builder: (ctx) => ParkDialog(
    title: '操作确认',
    content: '自定义操作按钮组',
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
      ElevatedButton(onPressed: () { Navigator.pop(ctx); }, child: const Text('确认')),
    ],
  ),
);
''',
  guide: '''
## 设计令牌参考 / Design Token Reference
- 圆角：`radius.lg` (16px)，详见 DESIGN_SYSTEM.md 5.1
- 内边距：`spacing.xl` (24px)
- 阴影：`shadows.lg`
- 遮罩色：`colors.overlay`
- 标题字号：`typography.sizeH2` (22px)
- 按钮间距：`spacing.base` (16px)

## 何时使用
- 需要用户确认的危险操作，如删除、退出
- 操作完成后的提示通知
- 重要信息的一次性告知

## 使用建议
- alert 用于纯提示（仅确认按钮），confirm 用于需用户决策的场景
- title 简明扼要，content 补充细节
- 自定义 confirmText/cancelText 使按钮语义更明确
- onConfirm 中执行实际操作，onCancel 中做取消逻辑
- 需要 3 个以上按钮时使用 actions 参数替换默认按钮组，每个按钮的 onPressed 自行管理（通常调用 Navigator.pop(ctx) 关闭对话框）

## 搭配推荐
- 搭配 ParkToast 做操作后轻提示
- 搭配 ParkButton 做触发入口
- 搭配 ParkMessage 做更轻量的全局消息
''',
);

// ---------------------------------------------------------------------------
// ParkToast
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkToast = ParkComponentSpec(
  name: 'ParkToast',
  title: '轻提示',
  category: 'feedback',
  description: '轻量级弹出提示，自动消失。支持普通、成功、错误、警告四种类型，可指定弹出位置。',
  icon: Icons.notifications_none_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'message',
      type: 'String',
      required: true,
      description: '提示文本',
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null',
      description: '前置图标',
    ),
    ParkPropertyDef(
      name: 'bgColor',
      type: 'Color?',
      defaultVal: 'Color(0xCC000000)',
      description: '背景颜色',
    ),
    ParkPropertyDef(
      name: 'position',
      type: 'ParkToastPosition',
      defaultVal: 'ParkToastPosition.center',
      description: '弹出位置：top / center / bottom',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onClick',
      signature: 'VoidCallback?',
      description: '点击 Toast 时的回调（show 方法的命名参数）',
    ),
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: 'Toast 关闭动画完成后的回调（show / warning 方法的命名参数）',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'show',
      signature:
          'static void show(BuildContext context, String message, {Duration duration, ParkToastPosition position, Color? bgColor, String? key, VoidCallback? onClick, VoidCallback? onClose, bool pauseOnHover})',
      description: '显示普通 Toast 提示',
    ),
    ParkMethodDef(
      name: 'success',
      signature:
          'static void success(BuildContext context, String message, {Duration duration, ParkToastPosition position})',
      description: '显示成功 Toast，带绿色勾号图标',
    ),
    ParkMethodDef(
      name: 'error',
      signature:
          'static void error(BuildContext context, String message, {Duration duration, ParkToastPosition position})',
      description: '显示错误 Toast，带红色错误图标',
    ),
    ParkMethodDef(
      name: 'warning',
      signature:
          'static void warning(BuildContext context, String message, {Duration duration, ParkToastPosition position})',
      description: '显示警告 Toast，带黄色警告图标',
    ),
    ParkMethodDef(
      name: 'loading',
      signature:
          'static VoidCallback loading(BuildContext context, String message, {ParkToastPosition position, String? key})',
      description: '显示带加载指示器的 Toast，返回一个关闭函数用于手动关闭',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '普通提示',
      description: '最基础的 Toast 弹出',
      code: "ParkToast.show(context, '这是一条提示')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkToast.show(context, '这是一条提示'),
        child: const Text('普通提示'),
      ),
    ),
    ParkDemoScenario(
      title: '成功提示',
      description: '带成功图标的 Toast',
      code: "ParkToast.success(context, '保存成功')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkToast.success(context, '保存成功'),
        child: const Text('成功提示'),
      ),
    ),
    ParkDemoScenario(
      title: '错误提示',
      description: '带错误图标的 Toast',
      code: "ParkToast.error(context, '网络异常')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkToast.error(context, '网络异常'),
        child: const Text('错误提示'),
      ),
    ),
    ParkDemoScenario(
      title: '顶部弹出',
      description: '指定 Toast 从顶部弹出',
      code:
          "ParkToast.warning(context, '请注意', position: ParkToastPosition.top)",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkToast.warning(
          context,
          '请注意',
          position: ParkToastPosition.top,
        ),
        child: const Text('顶部警告'),
      ),
    ),
    ParkDemoScenario(
      title: '加载提示',
      description: '带加载指示器的 Toast，需手动关闭',
      code:
          "final close = ParkToast.loading(context, '加载中...');\n// 稍后调用\nclose();",
      builder: (BuildContext context) {
        return ParkButton(
          onPressed: () {
            final close = ParkToast.loading(context, '加载中...');
            Future.delayed(const Duration(seconds: 2), close);
          },
          child: const Text('加载提示（2秒）'),
        );
      },
    ),
    ParkDemoScenario(
      title: '可点击关闭',
      description: '点击 Toast 触发 onClick，并监听 onClose',
      code:
          "ParkToast.show(context, '点我关闭', onClick: () => print('clicked'), onClose: () => print('closed'))",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkToast.show(
          context,
          '点我关闭',
          onClick: () => ParkToast.show(context, '已点击'),
          onClose: () => ParkToast.show(context, '已关闭'),
        ),
        child: const Text('可点击 Toast'),
      ),
    ),
  ],
  basicUsageCode: '''
// 普通提示
ParkToast.show(context, '这是一条提示');

// 成功提示
ParkToast.success(context, '保存成功');

// 错误提示（底部弹出、持续 3 秒）
ParkToast.error(context, '网络异常',
  duration: Duration(seconds: 3),
  position: ParkToastPosition.bottom,
);
''',
  guide: '''
## 何时使用
- 操作成功/失败的轻量级反馈
- 表单校验提示
- 不需要用户交互的短暂信息展示

## 使用建议
- show 用于普通提示，success/error/warning 带语义图标
- position: top 适合通知类，center 适合操作反馈，bottom 适合轻量提示
- duration 默认 2 秒，重要信息可适当延长
- 避免连续弹出多个 Toast，会互相遮挡

## 搭配推荐
- 搭配 ParkDialog 做确认后的操作反馈
- 搭配 ParkButton 做按钮点击反馈
- 搭配 ParkMessage 做更详细的全局消息
''',
);

// ---------------------------------------------------------------------------
// ParkLoading
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkLoading = ParkComponentSpec(
  name: 'ParkLoading',
  title: '加载',
  category: 'feedback',
  description: '加载指示组件，可作为 Widget 内嵌使用或通过静态方法全屏展示加载遮罩。',
  icon: Icons.hourglass_empty_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'type',
      type: 'ParkLoadingType',
      defaultVal: 'ParkLoadingType.circular',
      description: '加载指示器类型：circular（环形）/ dots（点阵）',
    ),
    ParkPropertyDef(
      name: 'size',
      type: 'double',
      defaultVal: '36',
      description: '指示器尺寸',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      defaultVal: 'null（使用 brand 色）',
      description: '指示器颜色',
    ),
    ParkPropertyDef(
      name: 'loadingSize',
      type: 'ParkLoadingSize',
      defaultVal: 'ParkLoadingSize.medium',
      description: '加载指示器尺寸预设：small / medium / large',
    ),
    ParkPropertyDef(
      name: 'text',
      type: 'String?',
      defaultVal: 'null',
      description: '加载提示文字',
    ),
    ParkPropertyDef(
      name: 'mask',
      type: 'bool',
      defaultVal: 'false',
      description: '是否在指示器后显示半透明遮罩',
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget?',
      defaultVal: 'null',
      description: '包裹的子内容，配合 loading 参数可显示为局部加载遮罩',
    ),
    ParkPropertyDef(
      name: 'loading',
      type: 'bool',
      defaultVal: 'true',
      description: '当提供 child 时，为 true 显示加载遮罩覆盖 child',
    ),
    ParkPropertyDef(
      name: 'delay',
      type: 'Duration?',
      defaultVal: 'null',
      description: '延迟显示加载指示器的时长，避免快速加载时闪烁',
    ),
    ParkPropertyDef(
      name: 'indicator',
      type: 'Widget?',
      defaultVal: 'null',
      description: '自定义加载指示器，替换默认 spinner',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'show',
      signature:
          'static void show(BuildContext context, {String? message, ParkLoadingType type, Color? color})',
      description: '全屏显示 loading 遮罩',
    ),
    ParkMethodDef(
      name: 'hide',
      signature: 'static void hide(BuildContext context)',
      description: '隐藏全屏 loading 遮罩',
    ),
    ParkMethodDef(
      name: 'dismiss',
      signature: 'static void dismiss()',
      description: '关闭全屏 loading（等同 hide）',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '环形加载',
      description: '默认的 circular 加载指示器',
      code: "ParkLoading()",
      builder: (BuildContext context) => const ParkLoading(),
    ),
    ParkDemoScenario(
      title: '点阵加载',
      description: 'dots 类型的加载动画',
      code: "ParkLoading(type: ParkLoadingType.dots)",
      builder: (BuildContext context) =>
          const ParkLoading(type: ParkLoadingType.dots),
    ),
    ParkDemoScenario(
      title: '带文字',
      description: '加载指示器附带提示文字',
      code: "ParkLoading(text: '加载中...')",
      builder: (BuildContext context) =>
          const ParkLoading(text: '加载中...'),
    ),
    ParkDemoScenario(
      title: '全屏加载',
      description: '通过静态方法展示全屏 loading 遮罩',
      code:
          "ParkLoading.show(context, message: '加载中...');\n// 稍后调用\nParkLoading.hide(context);",
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkLoading.show(context, message: '加载中...');
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              ParkLoading.hide(context);
            }
          });
        },
        child: const Text('全屏加载（2秒）'),
      ),
    ),
    ParkDemoScenario(
      title: '尺寸预设',
      description: '通过 loadingSize 切换 small / large 尺寸',
      code: "ParkLoading(text: '加载中', loadingSize: ParkLoadingSize.large)",
      builder: (BuildContext context) =>
          const ParkLoading(text: '加载中', loadingSize: ParkLoadingSize.large),
    ),
    ParkDemoScenario(
      title: '带遮罩',
      description: 'mask: true 时显示半透明遮罩背景',
      code: "ParkLoading(text: '加载中', mask: true)",
      builder: (BuildContext context) =>
          const ParkLoading(text: '加载中', mask: true),
    ),
    ParkDemoScenario(
      title: '局部加载',
      description: '包裹 child 并配合 loading 显示局部加载遮罩',
      code:
          "ParkLoading(loading: true, child: Center(child: Text('内容')))",
      builder: (BuildContext context) => SizedBox(
        height: 80,
        child: ParkLoading(
          loading: true,
          child: const Center(child: Text('内容区域')),
        ),
      ),
    ),
  ],
  basicUsageCode: '''
// 内嵌使用
ParkLoading(type: ParkLoadingType.circular, text: '加载中...');

// 全屏遮罩
ParkLoading.show(context, message: '加载中...');
// 稍后隐藏
ParkLoading.hide(context);
''',
  guide: '''
## 何时使用
- 数据加载、提交处理等需要等待的操作
- 全屏遮罩防止用户在加载过程中重复操作
- 局部加载区域的占位指示

## 使用建议
- 内嵌使用时作为 Widget 放置在加载区域
- 全屏使用通过 ParkLoading.show()/hide() 静态方法控制
- type: circular 环形适合通用场景，dots 点阵更活泼
- text 添加加载提示文字，让用户了解当前状态

## 搭配推荐
- 搭配 ParkSkeleton 做骨架屏过渡
- 搭配 ParkRefresh 做下拉刷新加载态
- 搭配 ParkToast 做加载完成提示
''',
);

// ---------------------------------------------------------------------------
// ParkActionSheet
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkActionSheet = ParkComponentSpec(
  name: 'ParkActionSheet',
  title: '操作面板',
  category: 'feedback',
  description: '底部操作面板，从底部弹出供用户选择操作项。通过静态方法 show 弹出，返回用户选中的 ParkAction。',
  icon: Icons.menu_open_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      defaultVal: 'null',
      description: '面板标题',
    ),
    ParkPropertyDef(
      name: 'actions',
      type: 'List<ParkAction>',
      required: true,
      description: '操作项列表，每项包含 label、icon、style、onTap',
    ),
    ParkPropertyDef(
      name: 'cancelText',
      type: 'String',
      defaultVal: "'取消'",
      description: '取消按钮文本',
    ),
    ParkPropertyDef(
      name: 'showCancel',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示底部取消按钮',
    ),
    ParkPropertyDef(
      name: 'description',
      type: 'String?',
      defaultVal: 'null',
      description: '描述文本，显示在操作项上方',
    ),
    ParkPropertyDef(
      name: 'destructiveIndex',
      type: 'int?',
      defaultVal: 'null',
      description: '标记为破坏性操作的索引（红色文本）',
    ),
    ParkPropertyDef(
      name: 'gridMode',
      type: 'bool',
      defaultVal: 'false',
      description: '是否以网格（宫格）布局展示操作项',
    ),
    ParkPropertyDef(
      name: 'gridColumns',
      type: 'int',
      defaultVal: '4',
      description: '网格模式下的列数',
    ),
    ParkPropertyDef(
      name: 'isDismissible',
      type: 'bool',
      defaultVal: 'true',
      description: '点击遮罩或返回键是否可关闭面板',
    ),
    ParkPropertyDef(
      name: 'closeOnTapAction',
      type: 'bool',
      defaultVal: 'true',
      description: '点击操作项后是否自动关闭面板',
    ),
    ParkPropertyDef(
      name: 'round',
      type: 'bool',
      defaultVal: 'true',
      description: '面板是否带有顶部圆角',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onCancel',
      signature: 'VoidCallback?',
      description: '点击取消按钮时的回调',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'show',
      signature:
          'static Future<ParkAction?> show(BuildContext context, {String? title, required List<ParkAction> actions, String cancelText, bool showCancel, bool closeOnTapAction, bool isDismissible, bool enableDrag, String? description, int? destructiveIndex, bool gridMode, int gridColumns, VoidCallback? onCancel})',
      description: '弹出操作面板，返回用户选中的 ParkAction，取消时返回 null',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础操作面板',
      description: '简单的底部操作面板',
      code:
          "ParkActionSheet.show(context, actions: [ParkAction(label: '拍照'), ParkAction(label: '从相册选择')])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          actions: const <ParkAction>[
            ParkAction(label: '拍照'),
            ParkAction(label: '从相册选择'),
          ],
        ),
        child: const Text('操作面板'),
      ),
    ),
    ParkDemoScenario(
      title: '带标题',
      description: '操作面板带标题说明',
      code:
          "ParkActionSheet.show(context, title: '请选择操作', actions: [...])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          title: '请选择操作',
          actions: const <ParkAction>[
            ParkAction(label: '编辑'),
            ParkAction(label: '复制'),
            ParkAction(label: '分享'),
          ],
        ),
        child: const Text('带标题'),
      ),
    ),
    ParkDemoScenario(
      title: '危险操作',
      description: '包含 destructive 样式项',
      code:
          "ParkActionSheet.show(context, actions: [ParkAction(label: '删除', style: ParkActionStyle.destructive)])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          actions: const <ParkAction>[
            ParkAction(label: '编辑'),
            ParkAction(label: '删除', style: ParkActionStyle.destructive),
          ],
        ),
        child: const Text('危险操作'),
      ),
    ),
    ParkDemoScenario(
      title: '带回调',
      description: '操作项带 onTap 回调',
      code:
          "ParkActionSheet.show(context, actions: [ParkAction(label: '确定', onTap: () => ParkToast.show(context, '已选择'))])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          actions: <ParkAction>[
            ParkAction(
              label: '确定选择',
              onTap: () => ParkToast.show(context, '已选择'),
            ),
            const ParkAction(
              label: '禁用项',
              style: ParkActionStyle.disabled,
            ),
          ],
        ),
        child: const Text('带回调'),
      ),
    ),
    ParkDemoScenario(
      title: '网格模式',
      description: 'gridMode 以宫格布局展示操作项',
      code:
          "ParkActionSheet.show(context, gridMode: true, actions: [ParkAction(label: '分享'), ParkAction(label: '收藏'), ParkAction(label: '删除')])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          gridMode: true,
          actions: const <ParkAction>[
            ParkAction(label: '分享'),
            ParkAction(label: '收藏'),
            ParkAction(label: '编辑'),
            ParkAction(label: '删除', style: ParkActionStyle.destructive),
          ],
        ),
        child: const Text('网格模式'),
      ),
    ),
    ParkDemoScenario(
      title: '带描述',
      description: '通过 description 在操作项上方显示说明文字',
      code:
          "ParkActionSheet.show(context, title: '分享到', description: '选择分享渠道', actions: [...])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          title: '分享到',
          description: '选择分享渠道',
          actions: const <ParkAction>[
            ParkAction(label: '微信'),
            ParkAction(label: '朋友圈'),
            ParkAction(label: '复制链接'),
          ],
        ),
        child: const Text('带描述'),
      ),
    ),
    ParkDemoScenario(
      title: '取消回调',
      description: '点击取消按钮时触发 onCancel 回调',
      code:
          "ParkActionSheet.show(context, onCancel: () => ParkToast.show(context, '已取消'), actions: [...])",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkActionSheet.show(
          context,
          onCancel: () => ParkToast.show(context, '已取消'),
          actions: const <ParkAction>[
            ParkAction(label: '确定'),
            ParkAction(label: '取消操作'),
          ],
        ),
        child: const Text('取消回调'),
      ),
    ),
  ],
  basicUsageCode: '''
final action = await ParkActionSheet.show(context,
  title: '请选择',
  actions: [
    ParkAction(label: '拍照'),
    ParkAction(label: '从相册选择'),
    ParkAction(label: '删除', style: ParkActionStyle.destructive),
  ],
);
if (action != null) {
  // 处理选中的操作
}
''',
  guide: '''
## 何时使用
- 提供多个操作选项供用户选择
- 分享、保存图片等场景的操作面板
- 替代传统 Dialog 提供更原生的底部弹出体验

## 使用建议
- title 说明操作目的，帮助用户理解选项
- ParkAction.style: destructive 用于危险操作（如删除），显示红色
- ParkAction.style: disabled 用于不可用选项
- 返回值为 null 表示用户点击了取消

## 搭配推荐
- 搭配 ParkToast 做选择后的反馈
- 搭配 ParkDialog 做二次确认
- 搭配 ParkButton 做触发入口
''',
);

// ---------------------------------------------------------------------------
// ParkPopup
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkPopup = ParkComponentSpec(
  name: 'ParkPopup',
  title: '弹出面板',
  category: 'feedback',
  description: '弹出面板组件，支持 center / bottom 两种位置，带遮罩和滑入动画。通过 visible 控制显示/隐藏。',
  icon: Icons.open_in_new_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'visible',
      type: 'bool',
      required: true,
      description: '是否显示弹出面板',
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '弹出面板的内容',
    ),
    ParkPropertyDef(
      name: 'position',
      type: 'ParkPopupPosition',
      defaultVal: 'ParkPopupPosition.center',
      description: '弹出位置：center / bottom / top',
    ),
    ParkPropertyDef(
      name: 'barrier',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示遮罩层',
    ),
    ParkPropertyDef(
      name: 'mask',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示半透明遮罩背景',
    ),
    ParkPropertyDef(
      name: 'maskClosable',
      type: 'bool',
      defaultVal: 'true',
      description: '点击遮罩是否关闭弹窗',
    ),
    ParkPropertyDef(
      name: 'dismissOnBarrierTap',
      type: 'bool',
      defaultVal: 'true',
      description: '点击遮罩区域是否关闭弹窗',
    ),
    ParkPropertyDef(
      name: 'animation',
      type: 'ParkPopupAnimation',
      defaultVal: 'ParkPopupAnimation.fade',
      description: '弹出动画类型：fade / slide / scale / none',
    ),
    ParkPropertyDef(
      name: 'borderRadius',
      type: 'double?',
      defaultVal: 'null（主题圆角）',
      description: '自定义面板圆角',
    ),
    ParkPropertyDef(
      name: 'arrow',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示指向触发元素的箭头',
    ),
    ParkPropertyDef(
      name: 'safeArea',
      type: 'bool',
      defaultVal: 'true',
      description: '是否将内容包裹在 SafeArea 中',
    ),
    ParkPropertyDef(
      name: 'destroyOnClose',
      type: 'bool',
      defaultVal: 'false',
      description: '关闭后是否销毁子组件（释放内存）',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onDismiss',
      signature: 'VoidCallback?',
      description: '面板关闭时的回调（动画完成后触发）',
    ),
    ParkEventDef(
      name: 'afterClose',
      signature: 'VoidCallback?',
      description: '弹窗关闭动画完成后的回调',
    ),
    ParkEventDef(
      name: 'beforeClose',
      signature: 'Future<bool> Function()?',
      description: '关闭前的守卫回调，返回 false 可阻止关闭',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '中心弹出',
      description: '从中心弹出的面板',
      code:
          "ParkPopup(visible: _visible, child: Container(...), position: ParkPopupPosition.center)",
      builder: (BuildContext context) => _CenterPopupDemo(),
    ),
    ParkDemoScenario(
      title: '底部弹出',
      description: '从底部滑入的面板',
      code:
          "ParkPopup(visible: _visible, child: Container(...), position: ParkPopupPosition.bottom)",
      builder: (BuildContext context) => _BottomPopupDemo(),
    ),
    ParkDemoScenario(
      title: '无遮罩',
      description: '不显示遮罩层的弹出面板',
      code:
          "ParkPopup(visible: _visible, child: Container(...), barrier: false)",
      builder: (BuildContext context) => _NoBarrierPopupDemo(),
    ),
    ParkDemoScenario(
      title: '顶部弹出',
      description: '从顶部滑入的面板',
      code:
          "ParkPopup(visible: _visible, position: ParkPopupPosition.top, child: Container(...))",
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool visible = false;
          return Stack(
            children: <Widget>[
              ParkButton(
                onPressed: () => setState(() => visible = true),
                child: const Text('顶部弹出'),
              ),
              ParkPopup(
                visible: visible,
                position: ParkPopupPosition.top,
                onDismiss: () => setState(() => visible = false),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _kColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('顶部弹出面板'),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '缩放动画',
      description: '使用 scale 动画类型弹出面板',
      code:
          "ParkPopup(visible: _visible, animation: ParkPopupAnimation.scale, child: Container(...))",
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool visible = false;
          return Stack(
            children: <Widget>[
              ParkButton(
                onPressed: () => setState(() => visible = true),
                child: const Text('缩放弹出'),
              ),
              ParkPopup(
                visible: visible,
                animation: ParkPopupAnimation.scale,
                onDismiss: () => setState(() => visible = false),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _kColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('缩放动画面板'),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: '带箭头',
      description: 'arrow: true 显示指向触发元素的箭头',
      code: "ParkPopup(visible: _visible, arrow: true, child: Container(...))",
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext ctx, void Function(void Function()) setState) {
          bool visible = false;
          return Stack(
            children: <Widget>[
              ParkButton(
                onPressed: () => setState(() => visible = true),
                child: const Text('带箭头'),
              ),
              ParkPopup(
                visible: visible,
                arrow: true,
                onDismiss: () => setState(() => visible = false),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _kColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('带箭头面板'),
                ),
              ),
            ],
          );
        },
      ),
    ),
    ParkDemoScenario(
      title: 'afterClose / beforeClose 关闭守卫',
      description:
          '演示 beforeClose 守卫（返回 false 拦截关闭）与 afterClose（关闭后触发）/ beforeClose guard & afterClose',
      code: '''ParkPopup(
  visible: _visible,
  beforeClose: () async => true,
  afterClose: () => print('afterClose'),
  child: Container(...),
)''',
      builder: (BuildContext context) {
        String log = '等待交互';
        bool visible = false;
        bool guard = true;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkButton(
                  onPressed: () {
                    visible = true;
                    setState(() {});
                  },
                  child: const ParkText('打开弹层'),
                ),
                ParkButton(
                  onPressed: () {
                    guard = !guard;
                    setState(() {});
                  },
                  child: Text('拦截：${guard ? '开' : '关'}'),
                ),
                ParkPopup(
                  visible: visible,
                  beforeClose: () async {
                    if (guard) {
                      log = 'beforeClose 拦截关闭';
                      setState(() {});
                      return false;
                    }
                    log = 'beforeClose 放行';
                    setState(() {});
                    return true;
                  },
                  afterClose: () {
                    log = 'afterClose 触发';
                    setState(() {});
                  },
                  onDismiss: () {
                    visible = false;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _kColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: <Widget>[
                        const Text('弹层内容'),
                        ParkButton(
                          onPressed: () {
                            visible = false;
                            setState(() {});
                          },
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  basicUsageCode: '''
bool _visible = false;

Stack(
  children: [
    ParkButton(
      onPressed: () => setState(() => _visible = true),
      child: Text('打开面板'),
    ),
    ParkPopup(
      visible: _visible,
      position: ParkPopupPosition.center,
      onDismiss: () => setState(() => _visible = false),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('弹出面板内容'),
            ParkButton(
              onPressed: () => setState(() => _visible = false),
              child: Text('关闭'),
            ),
          ],
        ),
      ),
    ),
  ],
);
''',
  guide: '''
## 何时使用
- 需要自定义内容的弹出面板
- 底部弹出的筛选器、分享面板
- 中心弹出的快捷操作面板

## 使用建议
- position: center 适合弹窗式交互，bottom 适合操作面板，top 适合通知面板
- barrier: true 点击遮罩可关闭，false 则需要手动关闭
- visible 由父组件 State 控制，搭配 onDismiss 同步状态
- child 支持任意 Widget，灵活定制面板内容

## 搭配推荐
- 搭配 ParkButton 做触发入口
- 搭配 ParkActionSheet 做标准操作面板
- 搭配 ParkDialog 做确认对话框
''',
);

// ---------------------------------------------------------------------------
// ParkDropdownMenu
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDropdownMenu = ParkComponentSpec(
  name: 'ParkDropdownMenu',
  title: '下拉菜单',
  category: 'feedback',
  description: '下拉菜单组件，锚定在 trigger 下方/上方展示菜单项列表，支持选中回调。',
  icon: Icons.arrow_drop_down_circle_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkDropdownMenuItem>',
      required: true,
      description: '菜单项列表，每项包含 label、value、icon、disabled',
    ),
    ParkPropertyDef(
      name: 'trigger',
      type: 'Widget',
      required: true,
      description: '触发下拉菜单的 Widget',
    ),
    ParkPropertyDef(
      name: 'direction',
      type: 'ParkDropdownDirection',
      defaultVal: 'ParkDropdownDirection.down',
      description: '下拉方向：down / up',
    ),
    ParkPropertyDef(
      name: 'multiple',
      type: 'bool',
      defaultVal: 'false',
      description: '是否允许多选（复选框样式）',
    ),
    ParkPropertyDef(
      name: 'groups',
      type: 'List<ParkDropdownGroup>?',
      defaultVal: 'null',
      description: '分组菜单项，提供时忽略 items',
    ),
    ParkPropertyDef(
      name: 'dividers',
      type: 'bool',
      defaultVal: 'true',
      description: '分组之间是否自动显示分割线',
    ),
    ParkPropertyDef(
      name: 'selectedValues',
      type: 'Set<String>',
      defaultVal: '{}',
      description: '多选模式下当前选中的值集合',
    ),
    ParkPropertyDef(
      name: 'closeOnSelect',
      type: 'bool',
      defaultVal: 'true',
      description: '选中后是否自动关闭菜单',
    ),
    ParkPropertyDef(
      name: 'closeOnTapOutside',
      type: 'bool',
      defaultVal: 'true',
      description: '点击菜单外部是否关闭菜单',
    ),
    ParkPropertyDef(
      name: 'matchTriggerWidth',
      type: 'bool',
      defaultVal: 'true',
      description: '下拉菜单宽度是否匹配触发元素宽度',
    ),
    ParkPropertyDef(
      name: 'offset',
      type: 'double',
      defaultVal: '4',
      description: '菜单与触发元素的间距',
    ),
    ParkPropertyDef(
      name: 'placement',
      type: 'ParkDropdownPlacement?',
      defaultVal: 'null（由 direction 决定）',
      description: '更细粒度的放置位置：bottomLeft / bottomRight / topLeft / topRight',
    ),
    ParkPropertyDef(
      name: 'maxHeight',
      type: 'double',
      defaultVal: '300',
      description: '下拉菜单的最大高度',
    ),
    ParkPropertyDef(
      name: 'itemBuilder',
      type: 'Widget Function(ParkDropdownMenuItem, bool)?',
      defaultVal: 'null',
      description: '自定义菜单项渲染构建器',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description: '绑定键（点号分隔的路径，如 "user.name"）。'
          '设此参数后组件进入双向绑定模式，'
          '值变化自动同步到 ParkBindingService。'
          '不设时组件行为不变（零侵入）。',
    ),
    ParkPropertyDef(
      name: 'bindingService',
      type: 'ParkBindingService?',
      defaultVal: 'null',
      description: '绑定服务实例。传入后组件通过 bindKey 自动双向绑定。'
          '如果组件位于 ParkForm/ParkDynamicForm 内且表单已注入 bindingService，'
          '此参数可省略（自动从 ParkBindingFormScope 获取）。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSelected',
      signature: 'ValueChanged<ParkDropdownMenuItem>?',
      description: '选中菜单项时的回调',
    ),
    ParkEventDef(
      name: 'onSelectionChanged',
      signature: 'ValueChanged<Set<String>>?',
      description: '多选模式下选中集合变化时的回调',
    ),
    ParkEventDef(
      name: 'onVisibleChanged',
      signature: 'ValueChanged<bool>?',
      description: '菜单展开（true）或收起（false）时的回调',
    ),
    ParkEventDef(
      name: 'onOpenChange',
      signature: 'ValueChanged<bool>?',
      description: '菜单打开/关闭变化的回调（同 onVisibleChanged）',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础下拉',
      description: '基本的下拉菜单',
      code:
          "ParkDropdownMenu(trigger: Text('菜单'), items: [ParkDropdownMenuItem(label: '编辑', value: 'edit')])",
      builder: (BuildContext context) => ParkDropdownMenu(
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('菜单'),
              Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        items: const <ParkDropdownMenuItem>[
          ParkDropdownMenuItem(label: '编辑', value: 'edit'),
          ParkDropdownMenuItem(label: '复制', value: 'copy'),
          ParkDropdownMenuItem(label: '删除', value: 'delete'),
        ],
        onSelected: (item) => ParkToast.show(context, '选择了 ${item.label}'),
      ),
    ),
    ParkDemoScenario(
      title: '带图标',
      description: '菜单项带前置图标',
      code:
          "ParkDropdownMenu(items: [ParkDropdownMenuItem(label: '编辑', value: 'edit', icon: Icon(Icons.edit))])",
      builder: (BuildContext context) => ParkDropdownMenu(
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('操作'),
              Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        items: const <ParkDropdownMenuItem>[
          ParkDropdownMenuItem(
              label: '编辑', value: 'edit', icon: Icon(Icons.edit, size: 18)),
          ParkDropdownMenuItem(
              label: '复制', value: 'copy', icon: Icon(Icons.copy, size: 18)),
          ParkDropdownMenuItem(
              label: '删除',
              value: 'delete',
              icon: Icon(Icons.delete, size: 18)),
        ],
        onSelected: (item) => ParkToast.show(context, '选择了 ${item.label}'),
      ),
    ),
    ParkDemoScenario(
      title: '向上弹出',
      description: '下拉菜单向上方展开',
      code:
          "ParkDropdownMenu(direction: ParkDropdownDirection.up, ...)",
      builder: (BuildContext context) => ParkDropdownMenu(
        direction: ParkDropdownDirection.up,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('向上弹出'),
              Icon(Icons.arrow_drop_up, size: 20),
            ],
          ),
        ),
        items: const <ParkDropdownMenuItem>[
          ParkDropdownMenuItem(label: '选项 A', value: 'a'),
          ParkDropdownMenuItem(label: '选项 B', value: 'b'),
          ParkDropdownMenuItem(
              label: '禁用项', value: 'c', disabled: true),
        ],
        onSelected: (item) => ParkToast.show(context, '选择了 ${item.label}'),
      ),
    ),
    ParkDemoScenario(
      title: '分组菜单',
      description: '通过 groups 参数展示带分组的菜单',
      code: r'''ParkDropdownMenu(
  items: const <ParkDropdownMenuItem>[],
  groups: const <ParkDropdownGroup>[
    ParkDropdownGroup(
      label: '编辑',
      items: <ParkDropdownMenuItem>[
        ParkDropdownMenuItem(label: '复制', value: 'copy'),
        ParkDropdownMenuItem(label: '粘贴', value: 'paste'),
      ],
    ),
    ParkDropdownGroup(
      label: '其他',
      items: <ParkDropdownMenuItem>[
        ParkDropdownMenuItem(label: '分享', value: 'share'),
        ParkDropdownMenuItem(label: '删除', value: 'delete'),
      ],
    ),
  ],
  trigger: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFDDDDDD)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('分组菜单'),
        Icon(Icons.arrow_drop_down, size: 20),
      ],
    ),
  ),
  onSelected: (item) => ParkToast.show(context, '选择了 ${item.label}'),
)''',
      builder: (BuildContext context) => ParkDropdownMenu(
        items: const <ParkDropdownMenuItem>[],
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('分组菜单'),
              Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        groups: const <ParkDropdownGroup>[
          ParkDropdownGroup(
            label: '编辑',
            items: <ParkDropdownMenuItem>[
              ParkDropdownMenuItem(label: '复制', value: 'copy'),
              ParkDropdownMenuItem(label: '粘贴', value: 'paste'),
            ],
          ),
          ParkDropdownGroup(
            label: '其他',
            items: <ParkDropdownMenuItem>[
              ParkDropdownMenuItem(label: '分享', value: 'share'),
              ParkDropdownMenuItem(label: '删除', value: 'delete'),
            ],
          ),
        ],
        onSelected: (item) => ParkToast.show(context, '选择了 ${item.label}'),
      ),
    ),
    ParkDemoScenario(
      title: '多选菜单',
      description: 'multiple: true 支持复选框多选',
      code:
          "ParkDropdownMenu(multiple: true, selectedValues: {...}, onSelectionChanged: (values) => ..., items: [...])",
      builder: (BuildContext context) => ParkDropdownMenu(
        multiple: true,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('多选菜单'),
              Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        items: const <ParkDropdownMenuItem>[
          ParkDropdownMenuItem(label: '选项一', value: '1'),
          ParkDropdownMenuItem(label: '选项二', value: '2'),
          ParkDropdownMenuItem(label: '选项三', value: '3'),
        ],
        onSelectionChanged: (values) =>
            ParkToast.show(context, '已选 ${values.length} 项'),
      ),
    ),
    ParkDemoScenario(
      title: '细粒度放置',
      description: '通过 placement 控制菜单相对触发元素的对齐',
      code:
          "ParkDropdownMenu(placement: ParkDropdownPlacement.bottomRight, items: [...], trigger: ...)",
      builder: (BuildContext context) => ParkDropdownMenu(
        placement: ParkDropdownPlacement.bottomRight,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('右下对齐'),
              Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        items: const <ParkDropdownMenuItem>[
          ParkDropdownMenuItem(label: '编辑', value: 'edit'),
          ParkDropdownMenuItem(label: '删除', value: 'delete'),
        ],
        onSelected: (item) => ParkToast.show(context, '选择了 ${item.label}'),
      ),
    ),
    ParkDemoScenario(
      title: 'onVisibleChanged / onOpenChange 事件',
      description: '下拉展开/收起触发 onVisibleChanged 与 onOpenChange / visibility callbacks',
      code: '''ParkDropdownMenu(
  trigger: Text('菜单'),
  onVisibleChanged: (v) => print('visible'),
  onOpenChange: (v) => print('open'),
  items: [ParkDropdownMenuItem(label: '编辑', value: 'edit')],
)''',
      builder: (BuildContext context) {
        String log = '等待交互';
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkDropdownMenu(
                  trigger: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('菜单'),
                        Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                  onVisibleChanged: (bool visible) {
                    log = 'onVisibleChanged: $visible';
                    setState(() {});
                  },
                  onOpenChange: (bool open) {
                    log = 'onOpenChange: $open';
                    setState(() {});
                  },
                  items: const <ParkDropdownMenuItem>[
                    ParkDropdownMenuItem(label: '编辑', value: 'edit'),
                    ParkDropdownMenuItem(label: '删除', value: 'delete'),
                  ],
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  basicUsageCode: '''
ParkDropdownMenu(
  trigger: Text('菜单'),
  items: [
    ParkDropdownMenuItem(label: '编辑', value: 'edit'),
    ParkDropdownMenuItem(label: '复制', value: 'copy'),
    ParkDropdownMenuItem(label: '删除', value: 'delete', disabled: true),
  ],
  onSelected: (item) {
    print('选中: \${item.label}');
  },
);
''',
  guide: '''
## 何时使用
- 工具栏、表格行等场景的操作菜单
- 需要锚定在触发元素下方的下拉选项
- 替代 PopupMenuButton 的自定义下拉菜单

## 使用建议
- trigger 通常是按钮或图标，点击后展开菜单
- direction: down 默认向下展开，up 适合底部触发的场景
- ParkDropdownMenuItem.disabled: true 禁用选项，灰色展示
- onSelected 返回选中的 ParkDropdownMenuItem，包含 label 和 value

## 搭配推荐
- 搭配 ParkButton 做触发按钮
- 搭配 ParkPopover 做更丰富内容的气泡
- 搭配 ParkToast 做选择后的反馈
''',
);

// ---------------------------------------------------------------------------
// ParkNoticeBar
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkNoticeBar = ParkComponentSpec(
  name: 'ParkNoticeBar',
  title: '通知栏',
  category: 'feedback',
  description: '通知栏组件，支持 info / success / warning / error 四种变体，可选跑马灯滚动和关闭功能。',
  icon: Icons.campaign_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'text',
      type: 'String',
      required: true,
      description: '通知文本',
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null（自动匹配变体图标）',
      description: '前置图标，为 null 时使用变体默认图标',
    ),
    ParkPropertyDef(
      name: 'closable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示关闭按钮',
    ),
    ParkPropertyDef(
      name: 'scrollable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否启用跑马灯滚动效果',
    ),
    ParkPropertyDef(
      name: 'variant',
      type: 'ParkNoticeBarVariant',
      defaultVal: 'ParkNoticeBarVariant.info',
      description: '变体类型：info / success / warning / error',
    ),
    ParkPropertyDef(
      name: 'mode',
      type: 'ParkNoticeBarMode?',
      defaultVal: 'null',
      description: '模式：closable（关闭）/ link（链接箭头）/ action（自定义操作），设置后覆盖 closable',
    ),
    ParkPropertyDef(
      name: 'wrap',
      type: 'bool',
      defaultVal: 'false',
      description: '非滚动时是否允许文本换行显示',
    ),
    ParkPropertyDef(
      name: 'closeable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示关闭按钮（等同 closable）',
    ),
    ParkPropertyDef(
      name: 'extra',
      type: 'Widget?',
      defaultVal: 'null',
      description: '右侧额外操作组件（如「查看」按钮）',
    ),
    ParkPropertyDef(
      name: 'prefixWidget',
      type: 'Widget?',
      defaultVal: 'null',
      description: '在图标前渲染的前置插槽',
    ),
    ParkPropertyDef(
      name: 'speed',
      type: 'double?',
      defaultVal: 'null（默认速度）',
      description: '跑马灯滚动速度（像素/秒）',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: '关闭通知栏时的回调',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '信息通知',
      description: '默认的 info 通知栏',
      code: "ParkNoticeBar(text: '这是一条系统通知')",
      builder: (BuildContext context) => const ParkNoticeBar(
        text: '这是一条系统通知',
      ),
    ),
    ParkDemoScenario(
      title: '警告通知',
      description: 'warning 变体的通知栏',
      code:
          "ParkNoticeBar(text: '网络连接不稳定', variant: ParkNoticeBarVariant.warning)",
      builder: (BuildContext context) => const ParkNoticeBar(
        text: '网络连接不稳定',
        variant: ParkNoticeBarVariant.warning,
      ),
    ),
    ParkDemoScenario(
      title: '可关闭',
      description: '带关闭按钮的通知栏',
      code: "ParkNoticeBar(text: '已更新到最新版本', closable: true)",
      builder: (BuildContext context) => const ParkNoticeBar(
        text: '已更新到最新版本',
        closable: true,
        variant: ParkNoticeBarVariant.success,
      ),
    ),
    ParkDemoScenario(
      title: '跑马灯',
      description: '长文本滚动展示',
      code:
          "ParkNoticeBar(text: '这是一条很长的通知...', scrollable: true)",
      builder: (BuildContext context) => const ParkNoticeBar(
        text:
            '这是一条很长的通知内容，当文本超出通知栏宽度时会自动滚动展示，确保用户可以阅读到完整信息。',
        scrollable: true,
        variant: ParkNoticeBarVariant.info,
      ),
    ),
    ParkDemoScenario(
      title: '错误通知',
      description: 'error 变体的通知栏',
      code:
          "ParkNoticeBar(text: '服务暂不可用', variant: ParkNoticeBarVariant.error)",
      builder: (BuildContext context) => const ParkNoticeBar(
        text: '服务暂不可用，请稍后重试',
        variant: ParkNoticeBarVariant.error,
        closable: true,
      ),
    ),
    ParkDemoScenario(
      title: '链接模式',
      description: 'mode: link 显示箭头并支持点击跳转',
      code: "ParkNoticeBar(text: '查看活动详情', mode: ParkNoticeBarMode.link)",
      builder: (BuildContext context) => ParkNoticeBar(
        text: '查看活动详情',
        mode: ParkNoticeBarMode.link,
        variant: ParkNoticeBarVariant.info,
        onClose: () => ParkToast.show(context, '已查看'),
      ),
    ),
    ParkDemoScenario(
      title: '操作模式',
      description: '通过 extra 在右侧放置自定义操作按钮',
      code:
          "ParkNoticeBar(text: '有 3 条新消息', extra: ParkButton(child: Text('查看')))",
      builder: (BuildContext context) => ParkNoticeBar(
        text: '有 3 条新消息',
        variant: ParkNoticeBarVariant.warning,
        extra: ParkButton(
          variant: ParkButtonVariant.text,
          onPressed: () => ParkToast.show(context, '查看消息'),
          child: const Text('查看'),
        ),
      ),
    ),
  ],
  basicUsageCode: '''
// 信息通知
ParkNoticeBar(text: '这是一条系统通知');

// 警告通知（可关闭）
ParkNoticeBar(
  text: '网络连接不稳定',
  variant: ParkNoticeBarVariant.warning,
  closable: true,
  onClose: () => print('已关闭'),
);

// 跑马灯滚动
ParkNoticeBar(
  text: '很长的通知内容...',
  scrollable: true,
);
''',
  guide: '''
## 何时使用
- 页面顶部的系统通知、公告横幅
- 版本更新提示、网络状态提醒
- 需要持续展示的通知信息（区别于 Toast 的短暂弹出）

## 使用建议
- variant 语义搭配：info 系统通知、success 成功提示、warning 警告、error 错误
- scrollable: true 适合长文本跑马灯滚动
- closable: true 允许用户手动关闭通知
- icon 为 null 时自动匹配变体默认图标

## 搭配推荐
- 搭配 ParkMessage 做短暂消息提示
- 搭配 ParkTag 做通知分类标签
- 搭配 ParkBanner 做活动横幅
''',
);

// ---------------------------------------------------------------------------
// ParkMessage
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkMessage = ParkComponentSpec(
  name: 'ParkMessage',
  title: '全局消息',
  category: 'feedback',
  description: '全局消息提示，从顶部/底部滑入并自动消失。支持 info / success / warning / error 四种类型。',
  icon: Icons.message_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'title',
      type: 'String',
      required: true,
      description: '消息标题',
    ),
    ParkPropertyDef(
      name: 'content',
      type: 'String?',
      defaultVal: 'null',
      description: '消息正文',
    ),
    ParkPropertyDef(
      name: 'duration',
      type: 'Duration',
      defaultVal: 'Duration(seconds: 3)',
      description: '自动消失的持续时间',
    ),
    ParkPropertyDef(
      name: 'closable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示手动关闭按钮',
    ),
    ParkPropertyDef(
      name: 'position',
      type: 'ParkMessagePosition',
      defaultVal: 'ParkMessagePosition.top',
      description: '弹出位置：top / bottom',
    ),
    ParkPropertyDef(
      name: 'icon',
      type: 'Widget?',
      defaultVal: 'null（自动匹配类型图标）',
      description: '前置图标',
    ),
    ParkPropertyDef(
      name: 'accentColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '强调色',
    ),
    ParkPropertyDef(
      name: 'backgroundColor',
      type: 'Color?',
      defaultVal: 'null',
      description: '背景颜色',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'VoidCallback?',
      description: '点击消息时的回调',
    ),
    ParkEventDef(
      name: 'onClick',
      signature: 'VoidCallback?',
      description: '点击消息时的回调（同 onTap 的命名别名）',
    ),
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: '消息关闭（自动消失或手动关闭）后的回调',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'info',
      signature:
          'static void info(BuildContext context, String title, {String? content, Duration duration, bool closable, ParkMessagePosition position})',
      description: '显示 info 类型的全局消息',
    ),
    ParkMethodDef(
      name: 'success',
      signature:
          'static void success(BuildContext context, String title, {String? content, Duration duration, bool closable, ParkMessagePosition position})',
      description: '显示 success 类型的全局消息',
    ),
    ParkMethodDef(
      name: 'warning',
      signature:
          'static void warning(BuildContext context, String title, {String? content, Duration duration, bool closable, ParkMessagePosition position})',
      description: '显示 warning 类型的全局消息',
    ),
    ParkMethodDef(
      name: 'error',
      signature:
          'static void error(BuildContext context, String title, {String? content, Duration duration, bool closable, ParkMessagePosition position})',
      description: '显示 error 类型的全局消息',
    ),
    ParkMethodDef(
      name: 'loading',
      signature:
          'static void loading(BuildContext context, String title, {String? content, Duration duration, bool closable, ParkMessagePosition position})',
      description: '显示带加载指示器的全局消息',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: 'Info 消息',
      description: '信息类型的全局消息',
      code: "ParkMessage.info(context, '新消息', content: '您有 3 条未读消息')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.info(
          context,
          '新消息',
          content: '您有 3 条未读消息',
        ),
        child: const Text('Info 消息'),
      ),
    ),
    ParkDemoScenario(
      title: 'Success 消息',
      description: '成功类型的全局消息',
      code: "ParkMessage.success(context, '操作成功')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.success(context, '操作成功'),
        child: const Text('Success 消息'),
      ),
    ),
    ParkDemoScenario(
      title: 'Warning 消息',
      description: '警告类型的全局消息',
      code:
          "ParkMessage.warning(context, '注意', content: '存储空间即将不足')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.warning(
          context,
          '注意',
          content: '存储空间即将不足',
        ),
        child: const Text('Warning 消息'),
      ),
    ),
    ParkDemoScenario(
      title: 'Error 消息（可关闭）',
      description: '错误类型的消息，带手动关闭按钮',
      code:
          "ParkMessage.error(context, '请求失败', content: '请检查网络后重试', closable: true)",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.error(
          context,
          '请求失败',
          content: '请检查网络后重试',
          closable: true,
        ),
        child: const Text('Error 消息'),
      ),
    ),
    ParkDemoScenario(
      title: '底部弹出',
      description: '从底部滑入的消息',
      code:
          "ParkMessage.info(context, '底部消息', position: ParkMessagePosition.bottom)",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.info(
          context,
          '底部消息',
          content: '从底部滑入的全局消息',
          position: ParkMessagePosition.bottom,
        ),
        child: const Text('底部弹出'),
      ),
    ),
    ParkDemoScenario(
      title: '加载消息',
      description: '带加载指示器的全局消息',
      code: "ParkMessage.loading(context, '正在提交', content: '请稍候...')",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.loading(
          context,
          '正在提交',
          content: '请稍候...',
          duration: const Duration(seconds: 4),
        ),
        child: const Text('加载消息'),
      ),
    ),
    ParkDemoScenario(
      title: '可点击消息',
      description: '点击消息触发 onClick 回调',
      code: "ParkMessage.info(context, '点击查看', onClick: () => print('clicked'))",
      builder: (BuildContext context) => ParkButton(
        onPressed: () => ParkMessage.info(
          context,
          '点击查看详情',
          onClick: () => ParkToast.show(context, '已点击消息'),
        ),
        child: const Text('可点击消息'),
      ),
    ),
    ParkDemoScenario(
      title: 'onTap / onClose 事件',
      description: '点击消息触发 onTap，手动关闭触发 onClose / onTap on tap, onClose on dismiss',
      code: '''ParkMessage.info(
  context,
  '标题',
  onTap: () => print('onTap'),
  onClose: () => print('onClose'),
  closable: true,
)''',
      builder: (BuildContext context) {
        String log = '等待交互';
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkButton(
                  onPressed: () => ParkMessage.info(
                    context,
                    '点击我',
                    onTap: () {
                      log = 'onTap 触发';
                      setState(() {});
                    },
                    onClose: () {
                      log = 'onClose 触发';
                      setState(() {});
                    },
                    closable: true,
                  ),
                  child: const ParkText('触发 onTap / onClose'),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  basicUsageCode: '''
// Info 消息
ParkMessage.info(context, '新消息', content: '您有 3 条未读消息');

// Success 消息
ParkMessage.success(context, '操作成功');

// Error 消息（可关闭）
ParkMessage.error(context, '请求失败',
  content: '请检查网络后重试',
  closable: true,
);

// 底部弹出
ParkMessage.info(context, '提示',
  position: ParkMessagePosition.bottom,
  duration: Duration(seconds: 5),
);
''',
  guide: '''
## 何时使用
- 全局操作反馈，如保存成功、提交失败
- 系统级通知，如网络异常、版本更新
- 比 Toast 更醒目，支持标题 + 正文 + 图标

## 使用建议
- info/success/warning/error 四种类型自动匹配图标和颜色
- position: top 从顶部滑入，bottom 从底部滑入
- duration 默认 3 秒自动消失，closable: true 可手动关闭
- accentColor 和 backgroundColor 可自定义配色

## 搭配推荐
- 搭配 ParkToast 做轻量级反馈
- 搭配 ParkNoticeBar 做持久化通知
- 搭配 ParkDialog 做需要用户确认的消息
''',
);

// ---------------------------------------------------------------------------
// ParkPopover
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkPopover = ParkComponentSpec(
  name: 'ParkPopover',
  title: '气泡弹框',
  category: 'feedback',
  description: '气泡弹出框，锚定在 trigger 附近展示内容，带箭头指示方向。支持 top / bottom / left / right 四个方向。',
  icon: Icons.chat_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'content',
      type: 'Widget',
      required: true,
      description: '气泡框内容',
    ),
    ParkPropertyDef(
      name: 'trigger',
      type: 'Widget',
      required: true,
      description: '触发气泡框的 Widget',
    ),
    ParkPropertyDef(
      name: 'direction',
      type: 'ParkPopoverDirection',
      defaultVal: 'ParkPopoverDirection.bottom',
      description: '气泡弹出方向：top / bottom / left / right',
    ),
    ParkPropertyDef(
      name: 'triggerMode',
      type: 'ParkPopoverTrigger',
      defaultVal: 'ParkPopoverTrigger.click',
      description: '触发方式：click（点击）/ hover（悬停）',
    ),
    ParkPropertyDef(
      name: 'closeOnTapOutside',
      type: 'bool',
      defaultVal: 'true',
      description: '点击气泡外部是否关闭',
    ),
    ParkPropertyDef(
      name: 'offset',
      type: 'double',
      defaultVal: '8',
      description: '气泡与触发元素的间距',
    ),
    ParkPropertyDef(
      name: 'showArrow',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示箭头（旧字段，建议用 arrow）',
    ),
    ParkPropertyDef(
      name: 'arrow',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示箭头指示器',
    ),
    ParkPropertyDef(
      name: 'maxWidth',
      type: 'double',
      defaultVal: '280',
      description: '气泡最大宽度',
    ),
    ParkPropertyDef(
      name: 'autoFlip',
      type: 'bool',
      defaultVal: 'true',
      description: '气泡超出视口时是否自动翻转方向',
    ),
    ParkPropertyDef(
      name: 'arrowPointAtCenter',
      type: 'bool',
      defaultVal: 'true',
      description: '箭头是否指向触发元素中心',
    ),
    ParkPropertyDef(
      name: 'overlayStyle',
      type: 'BoxDecoration?',
      defaultVal: 'null（主题默认气泡样式）',
      description: '自定义气泡装饰',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onVisibleChange',
      signature: 'void Function(bool visible)?',
      description: '气泡显示（true）或隐藏（false）时的回调',
    ),
    ParkEventDef(
      name: 'afterClose',
      signature: 'VoidCallback?',
      description: '气泡关闭动画完成后的回调',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '下方弹出',
      description: '气泡从下方弹出（默认）',
      code:
          "ParkPopover(trigger: Icon(Icons.more_horiz), content: Text('气泡内容'))",
      builder: (BuildContext context) => ParkPopover(
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.more_horiz, size: 20),
        ),
        content: const Text('这是一段气泡内容'),
      ),
    ),
    ParkDemoScenario(
      title: '上方弹出',
      description: '气泡从上方弹出',
      code:
          "ParkPopover(trigger: Icon(Icons.info), content: Text('提示信息'), direction: ParkPopoverDirection.top)",
      builder: (BuildContext context) => ParkPopover(
        direction: ParkPopoverDirection.top,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.info_outline, size: 20),
        ),
        content: const Text('上方弹出的提示'),
      ),
    ),
    ParkDemoScenario(
      title: '自定义内容',
      description: '气泡框中放置自定义 Widget',
      code:
          "ParkPopover(trigger: Text('菜单'), content: Column(children: [...]))",
      builder: (BuildContext context) => ParkPopover(
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('菜单'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => ParkToast.show(context, '编辑'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('编辑'),
              ),
            ),
            GestureDetector(
              onTap: () => ParkToast.show(context, '分享'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('分享'),
              ),
            ),
            GestureDetector(
              onTap: () => ParkToast.show(context, '删除'),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('删除'),
              ),
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '左侧弹出',
      description: '气泡从触发元素左侧弹出',
      code:
          "ParkPopover(trigger: Icon(Icons.info), content: Text('左侧内容'), direction: ParkPopoverDirection.left)",
      builder: (BuildContext context) => ParkPopover(
        direction: ParkPopoverDirection.left,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.info_outline, size: 20),
        ),
        content: const Text('从左侧弹出的提示'),
      ),
    ),
    ParkDemoScenario(
      title: '右侧弹出',
      description: '气泡从触发元素右侧弹出',
      code:
          "ParkPopover(trigger: Icon(Icons.info), content: Text('右侧内容'), direction: ParkPopoverDirection.right)",
      builder: (BuildContext context) => ParkPopover(
        direction: ParkPopoverDirection.right,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.info_outline, size: 20),
        ),
        content: const Text('从右侧弹出的提示'),
      ),
    ),
    ParkDemoScenario(
      title: '悬停触发',
      description: 'triggerMode: hover 鼠标悬停时弹出气泡',
      code:
          "ParkPopover(triggerMode: ParkPopoverTrigger.hover, trigger: Text('悬停我'), content: Text('悬停内容'))",
      builder: (BuildContext context) => ParkPopover(
        triggerMode: ParkPopoverTrigger.hover,
        trigger: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('悬停我'),
        ),
        content: const Text('悬停时显示的气泡内容'),
      ),
    ),
    ParkDemoScenario(
      title: 'onVisibleChange / afterClose 事件',
      description: '气泡显隐切换触发 onVisibleChange，关闭后触发 afterClose / visibility & afterClose',
      code: '''ParkPopover(
  trigger: Text('触发'),
  onVisibleChange: (v) => print('visible'),
  afterClose: () => print('afterClose'),
  content: Text('内容'),
)''',
      builder: (BuildContext context) {
        String log = '等待交互';
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkPopover(
                  trigger: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('点击我弹出'),
                  ),
                  onVisibleChange: (bool visible) {
                    log = 'onVisibleChange: $visible';
                    setState(() {});
                  },
                  afterClose: () {
                    log = 'afterClose 触发';
                    setState(() {});
                  },
                  content: const Text('气泡内容'),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  basicUsageCode: '''
ParkPopover(
  trigger: Icon(Icons.more_horiz),
  direction: ParkPopoverDirection.bottom,
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('菜单项 1'),
      Text('菜单项 2'),
    ],
  ),
);
''',
  guide: '''
## 何时使用
- 锚定在按钮或图标旁的快捷操作菜单
- 展示提示信息、操作说明
- 需要带箭头指示方向的气泡内容

## 使用建议
- direction: top/bottom/left/right 控制气泡弹出方向
- trigger 是触发气泡的 Widget，content 是气泡内容
- content 支持任意 Widget，可放置菜单项、表单等
- 与 Tooltip 区别：Popover 内容更丰富，Tooltip 仅文字提示

## 搭配推荐
- 搭配 ParkDropdownMenu 做下拉菜单
- 搭配 ParkTooltip 做简单文字提示
- 搭配 ParkButton 做触发入口
''',
);

// ---------------------------------------------------------------------------
// ParkRefresh
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkRefresh = ParkComponentSpec(
  name: 'ParkRefresh',
  title: '下拉刷新',
  category: 'feedback',
  description: '下拉刷新组件，基于 ScrollNotification 实现。包裹可滚动 Widget，下拉触发刷新回调。',
  icon: Icons.refresh_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'onRefresh',
      type: 'Future<void> Function()',
      required: true,
      description: '刷新回调，返回 Future，完成后自动收回',
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '可滚动的子 Widget（如 ListView）',
    ),
    ParkPropertyDef(
      name: 'refreshThreshold',
      type: 'double',
      defaultVal: '80.0',
      description: '触发刷新的下拉距离阈值',
    ),
    ParkPropertyDef(
      name: 'enableHapticFeedback',
      type: 'bool',
      defaultVal: 'true',
      description: '下拉/上拉触发时是否提供触觉反馈（移动端）',
    ),
    ParkPropertyDef(
      name: 'headerHeight',
      type: 'double',
      defaultVal: '60.0',
      description: '自定义下拉刷新头部的高度',
    ),
    ParkPropertyDef(
      name: 'headerBuilder',
      type: 'Widget Function(ParkRefreshState)?',
      defaultVal: 'null',
      description: '按刷新状态自定义头部指示器构建器',
    ),
    ParkPropertyDef(
      name: 'pullUpLoadMore',
      type: 'bool',
      defaultVal: 'false',
      description: '是否支持上拉到底部加载更多',
    ),
    ParkPropertyDef(
      name: 'onLoadMore',
      type: 'Future<void> Function()?',
      defaultVal: 'null',
      description: '上拉加载更多的回调',
    ),
    ParkPropertyDef(
      name: 'noMore',
      type: 'bool',
      defaultVal: 'false',
      description: '是否没有更多数据（禁用上拉加载）',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onRefresh',
      signature: 'Future<void> Function()',
      description: '下拉达到阈值后触发的刷新回调',
    ),
    ParkEventDef(
      name: 'onLoadMore',
      signature: 'Future<void> Function()?',
      description: '上拉到底部触发加载更多的回调',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础下拉刷新',
      description: '包裹 ListView 的下拉刷新',
      code:
          "ParkRefresh(onRefresh: () async { await Future.delayed(Duration(seconds: 1)); }, child: ListView(...))",
      builder: (BuildContext context) => SizedBox(
        height: 300,
        child: ParkRefresh(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              ParkToast.success(context, '刷新完成');
            }
          },
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              child: Text('列表项 ${index + 1}'),
            ),
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '自定义阈值',
      description: '设置不同的刷新触发距离',
      code:
          "ParkRefresh(refreshThreshold: 120, onRefresh: () async {...}, child: ListView(...))",
      builder: (BuildContext context) => SizedBox(
        height: 300,
        child: ParkRefresh(
          refreshThreshold: 120,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            if (context.mounted) {
              ParkToast.success(context, '刷新完成（阈值 120）');
            }
          },
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE)),
                ),
              ),
              child: Text('项目 ${index + 1}'),
            ),
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '带列表头部',
      description: '在 ParkRefresh 包裹的 ListView 中嵌入自定义头部区域，展示刷新与复杂列表布局的集成。',
      code: '''ParkRefresh(
  onRefresh: () async { ... },
  child: ListView(
    children: [
      // 自定义头部横幅
      Container(
        padding: EdgeInsets.all(16),
        color: Colors.blue.shade50,
        child: Text('最新消息'),
      ),
      // 列表项...
    ],
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 350,
        child: ParkRefresh(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (context.mounted) {
              ParkToast.success(context, '数据已更新');
            }
          },
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.campaign, size: 20),
                    SizedBox(width: 8),
                    Text('公告: 系统将于今晚 22:00 维护'),
                  ],
                ),
              ),
              ...List<Widget>.generate(8, (int index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 18,
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Text('带头部列表项 ${index + 1}'),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '加载更多',
      description: '在刷新列表底部集成"加载更多"按钮，实现刷新与分页加载的组合。',
      code: '''ParkRefresh(
  onRefresh: () async { ... },
  child: ListView.builder(
    itemCount: items.length + 1,
    itemBuilder: (context, index) {
      if (index == items.length) {
        return _LoadMoreButton();
      }
      return _ListItem(index);
    },
  ),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 350,
        child: _ParkRefreshLoadMoreDemo(),
      ),
    ),
    ParkDemoScenario(
      title: '上拉加载更多',
      description: '开启 pullUpLoadMore 后，上拉到底部自动触发 onLoadMore 加载更多数据。',
      code: '''ParkRefresh(
  pullUpLoadMore: true,
  onRefresh: () async { ... },
  onLoadMore: () async { ... },
  child: ListView.builder(...),
)''',
      builder: (BuildContext context) => SizedBox(
        height: 350,
        child: _ParkRefreshPullUpDemo(),
      ),
    ),
  ],
  basicUsageCode: '''
ParkRefresh(
  refreshThreshold: 80.0,
  onRefresh: () async {
    // 执行刷新逻辑
    await fetchData();
  },
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ListTile(
      title: Text(items[index]),
    ),
  ),
);
''',
  guide: '''
## 何时使用
- 列表页面的下拉刷新
- 需要用户手动触发数据更新的场景
- 替代 RefreshIndicator 的自定义下拉刷新

## 使用建议
- onRefresh 返回 Future，完成后自动收回刷新动画
- child 必须是可滚动 Widget（ListView、GridView 等）
- refreshThreshold 控制触发距离，默认 80 像素
- 刷新完成后可搭配 ParkToast 做成功提示

## 搭配推荐
- 搭配 ParkSkeleton 做加载占位
- 搭配 ParkLoading 做全屏加载
- 搭配 ParkSwipeCell 做列表滑动操作
''',
);

// ---------------------------------------------------------------------------
// ParkSwipeCell
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkSwipeCell = ParkComponentSpec(
  name: 'ParkSwipeCell',
  title: '滑动操作',
  category: 'feedback',
  description: '滑动操作单元格，左右滑动揭示操作按钮。常用于列表项的快捷操作。',
  icon: Icons.swipe_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '单元格主体内容',
    ),
    ParkPropertyDef(
      name: 'leftActions',
      type: 'List<ParkSwipeAction>?',
      defaultVal: 'null',
      description: '右滑揭示的左侧操作按钮列表',
    ),
    ParkPropertyDef(
      name: 'rightActions',
      type: 'List<ParkSwipeAction>?',
      defaultVal: 'null',
      description: '左滑揭示的右侧操作按钮列表',
    ),
    ParkPropertyDef(
      name: 'disabled',
      type: 'bool',
      defaultVal: 'false',
      description: '是否禁用滑动手势',
    ),
    ParkPropertyDef(
      name: 'confirmMode',
      type: 'bool',
      defaultVal: 'false',
      description: '确认模式：需二次点击操作按钮才执行',
    ),
    ParkPropertyDef(
      name: 'actionWidth',
      type: 'double?',
      defaultVal: 'null（默认 72）',
      description: '每个操作按钮的宽度',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onOpen',
      signature: 'VoidCallback?',
      description: '滑动打开操作按钮时的回调',
    ),
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: '滑动关闭操作按钮时的回调',
    ),
    ParkEventDef(
      name: 'beforeClose',
      signature: 'Future<bool> Function()?',
      description: '关闭前的守卫回调，返回 false 可阻止关闭',
    ),
  ],
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '右滑操作',
      description: '向右滑动揭示左侧操作',
      code:
          "ParkSwipeCell(child: ListTile(title: Text('列表项')), leftActions: [ParkSwipeAction(label: '置顶', color: Colors.blue)])",
      builder: (BuildContext context) => ParkSwipeCell(
        leftActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '置顶',
            color: const Color(0xFF4A90D9),
            onTap: () => ParkToast.show(context, '已置顶'),
          ),
          ParkSwipeAction(
            label: '标记',
            color: const Color(0xFFFFA726),
            onTap: () => ParkToast.show(context, '已标记'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: const Text('向右滑动查看操作'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '左滑删除',
      description: '向左滑动揭示删除按钮',
      code:
          "ParkSwipeCell(child: ListTile(...), rightActions: [ParkSwipeAction(label: '删除', color: Colors.red)])",
      builder: (BuildContext context) => ParkSwipeCell(
        rightActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '删除',
            color: const Color(0xFFE53935),
            onTap: () => ParkToast.show(context, '已删除'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: const Text('向左滑动删除'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '双向滑动',
      description: '同时支持左右滑动操作',
      code:
          "ParkSwipeCell(child: ListTile(...), leftActions: [...], rightActions: [...])",
      builder: (BuildContext context) => ParkSwipeCell(
        leftActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '置顶',
            color: const Color(0xFF4A90D9),
            onTap: () => ParkToast.show(context, '已置顶'),
          ),
        ],
        rightActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '删除',
            color: const Color(0xFFE53935),
            onTap: () => ParkToast.show(context, '已删除'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: const Text('左右均可滑动'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '带图标的自定义操作',
      description: '通过 ParkSwipeAction 的 icon 参数为操作按钮添加图标，并使用不同颜色区分操作类型。',
      code: '''ParkSwipeCell(
  leftActions: [
    ParkSwipeAction(
      label: '收藏',
      icon: Icon(Icons.star, color: Colors.white),
      color: Colors.amber,
      onTap: () {},
    ),
  ],
  rightActions: [
    ParkSwipeAction(
      label: '分享',
      icon: Icon(Icons.share, color: Colors.white),
      color: Colors.teal,
      onTap: () {},
    ),
    ParkSwipeAction(
      label: '删除',
      icon: Icon(Icons.delete, color: Colors.white),
      color: Colors.red,
      onTap: () {},
    ),
  ],
  child: ...,
)''',
      builder: (BuildContext context) => ParkSwipeCell(
        leftActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '收藏',
            icon: const Icon(Icons.star, color: Colors.white),
            color: const Color(0xFFFFB300),
            onTap: () => ParkToast.show(context, '已收藏'),
          ),
        ],
        rightActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '分享',
            icon: const Icon(Icons.share, color: Colors.white),
            color: const Color(0xFF00897B),
            onTap: () => ParkToast.show(context, '分享'),
          ),
          ParkSwipeAction(
            label: '删除',
            icon: const Icon(Icons.delete, color: Colors.white),
            color: const Color(0xFFE53935),
            onTap: () => ParkToast.show(context, '已删除'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: const Row(
            children: <Widget>[
              Icon(Icons.photo_camera, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('带图标操作'),
                    Text(
                      '左滑分享/删除，右滑收藏',
                      style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '二次确认模式',
      description: '设置 confirmMode 为 true，点击操作按钮后需再次点击确认才会真正执行，适用于删除等危险操作。',
      code: '''ParkSwipeCell(
  confirmMode: true,
  rightActions: <ParkSwipeAction>[
    ParkSwipeAction(
      label: '删除',
      color: _kColors.error,
      onTap: () => ParkToast.show(context, '已删除'),
    ),
  ],
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _kColors.divider)),
    ),
    child: const Text('左滑删除（需二次确认）'),
  ),
)''',
      builder: (BuildContext context) => ParkSwipeCell(
        confirmMode: true,
        rightActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '删除',
            color: _kColors.error,
            onTap: () => ParkToast.show(context, '已删除'),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _kColors.divider)),
          ),
          child: const Text('左滑删除（需二次确认）'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '禁用滑动',
      description: '设置 disabled 为 true 可完全禁用滑动手势，操作按钮不会被揭示，适用于只读或锁定场景。',
      code: '''ParkSwipeCell(
  disabled: true,
  rightActions: <ParkSwipeAction>[
    ParkSwipeAction(
      label: '删除',
      color: _kColors.error,
      onTap: () {},
    ),
  ],
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _kColors.divider)),
    ),
    child: const Text('该列表项不可滑动'),
  ),
)''',
      builder: (BuildContext context) => ParkSwipeCell(
        disabled: true,
        rightActions: <ParkSwipeAction>[
          ParkSwipeAction(
            label: '删除',
            color: _kColors.error,
            onTap: () {},
          ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _kColors.divider)),
          ),
          child: const Text('该列表项不可滑动'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '打开/关闭回调',
      description: '通过 onOpen 与 onClose 监听滑动状态变化，可用于埋点或在外层滚动交互时做出响应。',
      code: r'''bool open = false;
return StatefulBuilder(
  builder: (BuildContext ctx, void Function(void Function()) setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('当前状态：${open ? "已打开" : "已关闭"}'),
        const SizedBox(height: 8),
        ParkSwipeCell(
          onOpen: () {
            open = true;
            setState(() {});
          },
          onClose: () {
            open = false;
            setState(() {});
          },
          rightActions: <ParkSwipeAction>[
            ParkSwipeAction(
              label: '删除',
              color: _kColors.error,
              onTap: () => ParkToast.show(context, '已删除'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _kColors.divider)),
            ),
            child: const Text('左滑查看回调状态'),
          ),
        ),
      ],
    );
  },
);''',
      builder: (BuildContext context) {
        bool open = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('当前状态：${open ? "已打开" : "已关闭"}'),
                const SizedBox(height: 8),
                ParkSwipeCell(
                  onOpen: () {
                    open = true;
                    setState(() {});
                  },
                  onClose: () {
                    open = false;
                    setState(() {});
                  },
                  rightActions: <ParkSwipeAction>[
                    ParkSwipeAction(
                      label: '删除',
                      color: _kColors.error,
                      onTap: () => ParkToast.show(context, '已删除'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _kColors.divider)),
                    ),
                    child: const Text('左滑查看回调状态'),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: 'beforeClose 关闭守卫',
      description: '滑动展开前触发 beforeClose，返回 false 拦截展开 / beforeClose guard',
      code: '''ParkSwipeCell(
  beforeClose: () async => true,
  leftActions: [ParkSwipeAction(label: '删除', color: Colors.red)],
  child: Container(...),
)''',
      builder: (BuildContext context) {
        String log = '等待滑动';
        bool guard = true;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkText(log, preset: ParkTextPreset.bodySmall),
                ParkButton(
                  onPressed: () {
                    guard = !guard;
                    setState(() {});
                  },
                  child: Text('拦截：${guard ? '开' : '关'}'),
                ),
                ParkSwipeCell(
                  beforeClose: () async {
                    if (guard) {
                      log = 'beforeClose 拦截';
                      setState(() {});
                      return false;
                    }
                    log = 'beforeClose 放行';
                    setState(() {});
                    return true;
                  },
                  leftActions: <ParkSwipeAction>[
                    ParkSwipeAction(
                      label: '删除',
                      color: const Color(0xFFE53935),
                      onTap: () => ParkToast.show(context, '已删除'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                    ),
                    child: const Text('左滑查看 beforeClose'),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
  basicUsageCode: '''
ParkSwipeCell(
  leftActions: [
    ParkSwipeAction(
      label: '置顶',
      color: Color(0xFF4A90D9),
      onTap: () => print('置顶'),
    ),
  ],
  rightActions: [
    ParkSwipeAction(
      label: '删除',
      color: Color(0xFFE53935),
      onTap: () => print('删除'),
    ),
  ],
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Text('列表项内容'),
  ),
);
''',
  guide: '''
## 何时使用
- 列表项的快捷操作，如置顶、删除、分享
- 消息列表的标记已读、删除操作
- 替代长按弹出菜单的更直观交互

## 使用建议
- leftActions 右滑揭示，通常放置非破坏性操作（置顶、标记）
- rightActions 左滑揭示，通常放置破坏性操作（删除），用红色标识
- ParkSwipeAction.icon 添加图标增强辨识度
- child 通常是 ListTile 或自定义列表项

## 搭配推荐
- 搭配 ParkRefresh 做下拉刷新列表
- 搭配 ParkDialog 做删除二次确认
- 搭配 ParkToast 做操作反馈
''',
);

// ---------------------------------------------------------------------------
// Demo helper widgets (StatefulWidgets needed for ParkPopup demos)
// ---------------------------------------------------------------------------

class _CenterPopupDemo extends StatefulWidget {
  @override
  State<_CenterPopupDemo> createState() => _CenterPopupDemoState();
}

class _CenterPopupDemoState extends State<_CenterPopupDemo> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ParkButton(
          onPressed: () => setState(() => _visible = true),
          child: const Text('中心弹出'),
        ),
        ParkPopup(
          visible: _visible,
          position: ParkPopupPosition.center,
          onDismiss: () => setState(() => _visible = false),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('中心弹出面板'),
                const SizedBox(height: 16),
                ParkButton(
                  onPressed: () => setState(() => _visible = false),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomPopupDemo extends StatefulWidget {
  @override
  State<_BottomPopupDemo> createState() => _BottomPopupDemoState();
}

class _BottomPopupDemoState extends State<_BottomPopupDemo> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ParkButton(
          onPressed: () => setState(() => _visible = true),
          child: const Text('底部弹出'),
        ),
        ParkPopup(
          visible: _visible,
          position: ParkPopupPosition.bottom,
          onDismiss: () => setState(() => _visible = false),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('底部弹出面板'),
                const SizedBox(height: 16),
                ParkButton(
                  onPressed: () => setState(() => _visible = false),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NoBarrierPopupDemo extends StatefulWidget {
  @override
  State<_NoBarrierPopupDemo> createState() => _NoBarrierPopupDemoState();
}

class _NoBarrierPopupDemoState extends State<_NoBarrierPopupDemo> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ParkButton(
          onPressed: () => setState(() => _visible = !_visible),
          child: Text(_visible ? '关闭面板' : '无遮罩弹出'),
        ),
        ParkPopup(
          visible: _visible,
          position: ParkPopupPosition.center,
          barrier: false,
          onDismiss: () => setState(() => _visible = false),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('无遮罩面板'),
                SizedBox(height: 8),
                Text('点击其他区域不会关闭'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ParkRefreshLoadMoreDemo extends StatefulWidget {
  @override
  State<_ParkRefreshLoadMoreDemo> createState() =>
      _ParkRefreshLoadMoreDemoState();
}

class _ParkRefreshLoadMoreDemoState extends State<_ParkRefreshLoadMoreDemo> {
  int _itemCount = 8;
  bool _loadingMore = false;

  void _loadMore() {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _itemCount += 5;
          _loadingMore = false;
        });
        ParkToast.show(context, '已加载 5 条更多数据');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParkRefresh(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          setState(() => _itemCount = 8);
          ParkToast.success(context, '刷新完成，数据已重置');
        }
      },
      child: ListView.builder(
        itemCount: _itemCount + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == _itemCount) {
            return GestureDetector(
              onTap: _loadMore,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: _loadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.expand_more, size: 20),
                          SizedBox(width: 4),
                          Text('加载更多'),
                        ],
                      ),
              ),
            );
          }
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: Text('列表项 ${index + 1}'),
          );
        },
      ),
    );
  }
}

class _ParkRefreshPullUpDemo extends StatefulWidget {
  @override
  State<_ParkRefreshPullUpDemo> createState() => _ParkRefreshPullUpDemoState();
}

class _ParkRefreshPullUpDemoState extends State<_ParkRefreshPullUpDemo> {
  int _itemCount = 8;

  @override
  Widget build(BuildContext context) {
    return ParkRefresh(
      pullUpLoadMore: true,
      noMore: _itemCount >= 18,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          setState(() => _itemCount = 8);
          ParkToast.success(context, '刷新完成');
        }
      },
      onLoadMore: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          setState(() => _itemCount += 5);
          ParkToast.show(context, '已加载更多');
        }
      },
      child: ListView.builder(
        itemCount: _itemCount,
        itemBuilder: (BuildContext context, int index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEEEEEE)),
            ),
          ),
          child: Text('列表项 ${index + 1}'),
        ),
      ),
    );
  }
}
