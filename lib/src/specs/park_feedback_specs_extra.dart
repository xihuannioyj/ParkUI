// Park 反馈组件补充规格 — 由 Agent 填充（ParkOverlay）
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

/// 反馈类补充组件规格字典（4 个组件）。
Map<String, ParkComponentSpec> get parkFeedbackSpecsExtra =>
    <String, ParkComponentSpec>{
      'ParkOverlay': _parkOverlaySpec,
      'ParkDropdownSheet': _parkDropdownSheetSpec,
      'ParkDropdownFilter': _parkDropdownFilterSpec,
      'ParkTour': _parkTourSpec,
    };

// ---------------------------------------------------------------------------
// ParkOverlay
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkOverlaySpec = ParkComponentSpec(
  name: 'ParkOverlay',
  title: '遮罩层',
  category: 'feedback',
  description:
      '全屏遮罩层组件，支持声明式（visible 控制显隐）与命令式（ParkOverlay.show 静态方法）两种用法，'
      '可配置遮罩颜色、点击关闭、背景模糊与滚动锁定。',
  icon: Icons.layers_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'child',
      type: 'Widget',
      required: true,
      description: '遮罩内容。',
    ),
    ParkPropertyDef(
      name: 'visible',
      type: 'bool',
      defaultVal: 'false',
      description: '是否可见（声明式模式）。',
    ),
    ParkPropertyDef(
      name: 'onTap',
      type: 'VoidCallback?',
      description: '点击遮罩回调。',
    ),
    ParkPropertyDef(
      name: 'barrierColor',
      type: 'Color?',
      description: '遮罩背景色。',
    ),
    ParkPropertyDef(
      name: 'blocking',
      type: 'bool',
      defaultVal: 'true',
      description: '是否阻止背景点击穿透。',
    ),
    ParkPropertyDef(
      name: 'lockScroll',
      type: 'bool',
      defaultVal: 'true',
      description: '显示时是否锁定背景滚动。',
    ),
    ParkPropertyDef(
      name: 'color',
      type: 'Color?',
      description: '自定义遮罩颜色（与 barrierColor 等价，声明式与命令式通用）。',
    ),
    ParkPropertyDef(
      name: 'blur',
      type: 'double?',
      description: '背景高斯模糊 sigma 值，>0 时启用模糊。',
    ),
    ParkPropertyDef(
      name: 'duration',
      type: 'Duration',
      defaultVal: '200ms',
      description: '声明式显隐动画时长。',
    ),
    ParkPropertyDef(
      name: 'custom',
      type: 'bool',
      defaultVal: 'false',
      description: '是否为完全自定义模式（去除默认遮罩样式）。',
    ),
    ParkPropertyDef(
      name: 'transitionName',
      type: 'String',
      defaultVal: "'fade'",
      description: '过渡动画名称。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onTap',
      signature: 'VoidCallback?',
      description: '点击遮罩回调。',
    ),
    ParkEventDef(
      name: 'afterClose',
      signature: 'VoidCallback?',
      description: '关闭动画结束后回调。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkOverlay.show',
      signature:
          'static ParkOverlayHandle show(BuildContext context, {required Widget child, Color? barrierColor, bool blocking = true, Duration? autoClose, VoidCallback? onTap, Color? color, double? blur, bool lockScroll = true})',
      description: '命令式弹出全屏遮罩，返回句柄用于关闭（autoClose 可设自动关闭时间）。',
    ),
  ],
  basicUsageCode: '''
ParkOverlay(
  visible: true,
  child: Center(
    child: Card(child: Padding(padding: EdgeInsets.all(16), child: Text('内容'))),
  ),
)
''',
  guide: '''
## 何时使用
- 模态对话框、 loading、图片预览等需要遮罩的场景
- 需要临时阻断用户与背景交互时

## 使用建议
- 命令式用 ParkOverlay.show 弹出，句柄 .close() 关闭
- 声明式用 visible 在状态管理中控制显隐
- blocking / lockScroll 控制交互与滚动行为
- 自定义遮罩外观用 barrierColor / blur
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '声明式遮罩',
      description:
          'ParkOverlay 为声明式全屏遮罩，由 visible 控制显隐（此处为占位示意，运行时设 visible: true 即弹出）。',
      code: '''
ParkOverlay(
  visible: true,
  child: Center(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('遮罩内容'),
      ),
    ),
  ),
)''',
      builder: (BuildContext context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        return SizedBox(
          height: 160,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: park.colors.overlay,
              borderRadius: park.radius.brMd,
            ),
            child: Center(
                child: Card(
                child: Padding(
                padding: EdgeInsets.all(park.spacing.base),
                child: const Text('遮罩内容（运行时由 visible 控制显隐）'),
                ),
              ),
            ),
          ),
        );
      },
    ),
    ParkDemoScenario(
      title: '命令式弹出',
      description: '使用 ParkOverlay.show 在命令式场景中弹出遮罩。',
      code: '''
final handle = ParkOverlay.show(
  context,
  child: Center(child: Text('加载中…')),
);
// 关闭：handle.close();
''',
      builder: (BuildContext context) => Center(
        child: ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkOverlay.show(
              context,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('加载中…'),
                  ),
                ),
              ),
            );
          },
          child: const Text('弹出遮罩'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '声明式显隐 + 生命周期',
      description:
          '用 StatefulBuilder 维护 visible 状态，ParkOverlay(visible:) 声明式控制显隐；点击遮罩触发 onTap 关闭，afterClose 在关闭动画结束后回调。',
      code: '''
final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
bool visible = false;
StatefulBuilder(
  builder: (ctx, setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 160, child: ParkOverlay(
          visible: visible,
          onTap: () => setState(() => visible = false),
          afterClose: () => setState(() {}),
          child: Center(child: Card(child: Padding(padding: EdgeInsets.all(park.spacing.base), child: const Text('遮罩内容（点击遮罩关闭）')))),
        )),
        SizedBox(height: park.spacing.base),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () => setState(() => visible = !visible),
          child: Text(visible ? '隐藏遮罩' : '显示遮罩'),
        ),
      ],
    );
  },
)
''',
      builder: (BuildContext context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        bool visible = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 160,
                  child: ParkOverlay(
                    visible: visible,
                    onTap: () => setState(() => visible = false),
                    afterClose: () => setState(() {}),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(park.spacing.base),
                          child: const Text('遮罩内容（点击遮罩关闭）'),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: park.spacing.base),
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  onPressed: () => setState(() => visible = !visible),
                  child: Text(visible ? '隐藏遮罩' : '显示遮罩'),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '命令式显隐控制',
      description:
          '调用 ParkOverlay.show 获取句柄 ParkOverlayHandle，再次点击按钮调用 handle.close() 关闭遮罩，演示 show / hide 完整生命周期。',
      code: '''
final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
ParkOverlayHandle? handle;
bool visible = false;
StatefulBuilder(
  builder: (ctx, setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            if (visible) {
              handle?.close();
            } else {
              handle = ParkOverlay.show(
                ctx,
                onTap: () { handle?.close(); setState(() => visible = false); },
                child: Center(child: Card(child: Padding(padding: EdgeInsets.all(park.spacing.base), child: const Text('加载中…（点击遮罩或按钮关闭）')))),
              );
            }
            setState(() => visible = !visible);
          },
          child: Text(visible ? '关闭遮罩 (handle.close)' : '弹出遮罩 (show)'),
        ),
        SizedBox(height: park.spacing.base),
        Text(visible ? '遮罩已显示' : '遮罩已隐藏', style: TextStyle(color: park.colors.textSecondary)),
      ],
    );
  },
)
''',
      builder: (BuildContext context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        ParkOverlayHandle? handle;
        bool visible = false;
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  onPressed: () {
                    if (visible) {
                      handle?.close();
                    } else {
                      handle = ParkOverlay.show(
                        ctx,
                        onTap: () {
                          handle?.close();
                          setState(() => visible = false);
                        },
                        child: Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(park.spacing.base),
                              child: const Text('加载中…（点击遮罩或按钮关闭）'),
                            ),
                          ),
                        ),
                      );
                    }
                    setState(() => visible = !visible);
                  },
                  child: Text(visible ? '关闭遮罩 (handle.close)' : '弹出遮罩 (show)'),
                ),
                SizedBox(height: park.spacing.base),
                Text(
                  visible ? '遮罩已显示' : '遮罩已隐藏',
                  style: TextStyle(color: park.colors.textSecondary),
                ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '背景模糊',
      description: 'blur 参数大于 0 时启用毛玻璃背景遮罩，适合突出前景内容。',
      code: '''
ParkOverlay.show(
  context,
  blur: 4,
  child: const Center(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('背景已模糊处理'),
      ),
    ),
  ),
);
''',
      builder: (BuildContext context) => Center(
        child: ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkOverlay.show(
              context,
              blur: 4,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('背景已模糊处理'),
                  ),
                ),
              ),
            );
          },
          child: const Text('模糊遮罩'),
        ),
      ),
    ),
    ParkDemoScenario(
      title: '自动关闭',
      description: 'show 的 autoClose 支持设置定时自动关闭遮罩。',
      code: '''
ParkOverlay.show(
  context,
  autoClose: Duration(seconds: 2),
  child: const Center(
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('2 秒后自动关闭'),
      ),
    ),
  ),
);
''',
      builder: (BuildContext context) => Center(
        child: ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {
            ParkOverlay.show(
              context,
              autoClose: const Duration(seconds: 2),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('2 秒后自动关闭'),
                  ),
                ),
              ),
            );
          },
          child: const Text('2 秒后自动关闭'),
        ),
      ),
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkDropdownSheet
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDropdownSheetSpec = ParkComponentSpec(
  name: 'ParkDropdownSheet',
  title: '下拉面板',
  category: 'feedback',
  description:
      '底部弹出式下拉面板组件。点击触发组件从底部弹出带标题栏的面板，'
      '支持预定义选项列表/网格布局和完全自定义 child 两种内容模式。'
      '提供静态方法 show/showCustom 以及实例化组件两种用法。',
  icon: Icons.arrow_drop_down_circle_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'trigger',
      type: 'Widget',
      required: true,
      description: '触发组件，点击后弹出面板。',
    ),
    ParkPropertyDef(
      name: 'title',
      type: 'String?',
      defaultVal: 'null',
      description: '面板标题。',
    ),
    ParkPropertyDef(
      name: 'items',
      type: 'List<ParkDropdownSheetItem>?',
      defaultVal: 'null',
      description: '预定义选项列表（与 child 互斥，child 优先）。',
    ),
    ParkPropertyDef(
      name: 'child',
      type: 'Widget?',
      defaultVal: 'null',
      description: '完全自定义子组件（优先于 items）。',
    ),
    ParkPropertyDef(
      name: 'multiple',
      type: 'bool',
      defaultVal: 'false',
      description: '是否多选（仅 items 模式有效）。',
    ),
    ParkPropertyDef(
      name: 'layout',
      type: 'ParkDropdownSheetLayout',
      defaultVal: 'ParkDropdownSheetLayout.list',
      description: '布局模式：list（列表） / grid（网格）。',
    ),
    ParkPropertyDef(
      name: 'gridColumns',
      type: 'int',
      defaultVal: '3',
      description: '网格列数（layout 为 grid 时生效）。',
    ),
    ParkPropertyDef(
      name: 'height',
      type: 'double?',
      defaultVal: 'null（自动适配）',
      description: '面板内容区高度。',
    ),
    ParkPropertyDef(
      name: 'searchable',
      type: 'bool',
      defaultVal: 'false',
      description: '是否显示搜索框（仅 items 模式）。',
    ),
    ParkPropertyDef(
      name: 'searchHintText',
      type: 'String',
      defaultVal: "'搜索选项'",
      description: '搜索框占位文字。',
    ),
    ParkPropertyDef(
      name: 'confirmText',
      type: 'String',
      defaultVal: "'确定'",
      description: '确认按钮文字。',
    ),
    ParkPropertyDef(
      name: 'cancelText',
      type: 'String',
      defaultVal: "'取消'",
      description: '取消按钮文字。',
    ),
    ParkPropertyDef(
      name: 'showHandle',
      type: 'bool',
      defaultVal: 'true',
      description: '面板顶部是否显示拖拽手柄。',
    ),
    ParkPropertyDef(
      name: 'bindKey',
      type: 'String?',
      defaultVal: 'null',
      description: '绑定键（点号分隔路径）。',
    ),
    ParkPropertyDef(
      name: 'selectedValues',
      type: 'Set<String>?',
      defaultVal: 'null',
      description: '受控选中值（单选为单值集合，多选为逗号分隔集合）。',
    ),
    ParkPropertyDef(
      name: 'itemBuilder',
      type: 'Widget Function(ParkDropdownSheetItem item, bool isSelected)?',
      description: '自定义选项构建器（仅 items 模式），完全控制每个选项渲染。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onSelectionChanged',
      signature: 'ValueChanged<Set<String>>?',
      description: '选中值变更回调（仅 items 模式）。',
    ),
    ParkEventDef(
      name: 'onConfirm',
      signature: 'ValueChanged<Set<String>>?',
      description: '确认回调（仅 items 模式）。',
    ),
    ParkEventDef(
      name: 'onCancel',
      signature: 'VoidCallback?',
      description: '取消回调。',
    ),
    ParkEventDef(
      name: 'onVisibleChanged',
      signature: 'ValueChanged<bool>?',
      description: '面板打开/关闭回调。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkDropdownSheet.show',
      signature:
          'static Future<Set<String>?> show(BuildContext context, {String? title, required List<ParkDropdownSheetItem> items, Set<String>? selectedValues, bool multiple = false, ParkDropdownSheetLayout layout = list, int gridColumns = 3, double? height, String confirmText = \'确定\', String cancelText = \'取消\', bool searchable = false, String searchHintText = \'搜索选项\', Widget Function(ParkDropdownSheetItem, bool)? itemBuilder, ValueChanged<Set<String>>? onConfirm, String? bindKey, ParkBindingService? bindingService})',
      description: '静态弹出选项面板，返回用户确认选中的值集合，取消时返回 null。',
    ),
    ParkMethodDef(
      name: 'ParkDropdownSheet.showCustom',
      signature:
          'static Future<void> showCustom(BuildContext context, {String? title, required Widget child, double? height, String confirmText = \'确定\', String cancelText = \'取消\', VoidCallback? onConfirm, VoidCallback? onCancel})',
      description: '静态弹出自定义内容面板，返回时不做值处理，仅展示自定义 UI。',
    ),
  ],
  basicUsageCode: '''
// 选项模式 — 单选
final result = await ParkDropdownSheet.show(
  context,
  title: '选择城市',
  items: [
    ParkDropdownSheetItem(label: '北京', value: 'beijing'),
    ParkDropdownSheetItem(label: '上海', value: 'shanghai'),
    ParkDropdownSheetItem(label: '广州', value: 'guangzhou'),
  ],
);
if (result != null && result.isNotEmpty) {
  print('选中: \${result.first}');
}

// 完全自定义模式
ParkDropdownSheet.showCustom(
  context,
  title: '自定义内容',
  child: Column(
    children: [
      Text('这里可以放任意 Widget'),
      ParkButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('关闭'),
      ),
    ],
  ),
  height: 300,
);
''',
  guide: '''
## 何时使用

- 需要在底部弹出选项列表供用户选择时
- 需要在底部展示完全自定义的组件集合（日历、图表、表单等）
- 需要替代传统 flyout 下拉菜单，在移动端更自然的交互方式

## 设计理念

ParkDropdownSheet 将「触发 → 底部弹出面板」这一高频交互模式统一封装：

1. **选项模式**：传入 items 即可快速搭建单选/多选面板，支持搜索过滤、列表/网格布局
2. **自定义模式**：传入 child 可放入任意 Widget，面板仅提供标准外壳（手柄+标题+取消/确定）
3. **灵活调用**：静态方法 show/showCustom 适合"用完即弃"的场景；实例化 trigger 适合需要绑定引擎的复杂场景
4. **双向绑定**：设 bindKey 即可通过 ParkBindingService 联动表单状态

## 注意事项

- items 模式中选中的值会在确认时返回 Set<String>，取消返回 null
- Grid 布局推荐用 2-4 列，根据选项文字长度调整 gridColumns
- 多选模式会显示 Checkbox 标记，单选模式显示 CheckCircle 标记
- 自定义构建器传 itemBuilder 可完全控制每个选项的渲染
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础选项列表',
      description: '通过 show 静态方法弹出单选选项面板。',
      code: """
ParkDropdownSheet.show(
  context,
  title: '选择类型',
  items: const [
    ParkDropdownSheetItem(label: '类型 A', value: 'a'),
    ParkDropdownSheetItem(label: '类型 B', value: 'b'),
    ParkDropdownSheetItem(label: '类型 C', value: 'c'),
  ],
);
""",
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkDropdownSheet.show(
            context,
            title: '选择类型',
            items: const [
              ParkDropdownSheetItem(label: '类型 A', value: 'a'),
              ParkDropdownSheetItem(label: '类型 B', value: 'b'),
              ParkDropdownSheetItem(label: '类型 C', value: 'c'),
            ],
          );
        },
        child: const Text('基础选项列表'),
      ),
    ),
    ParkDemoScenario(
      title: '多选模式',
      description: '开启 multiple 后选项变为复选框多选，支持搜索过滤。',
      code: """
ParkDropdownSheet.show(
  context,
  title: '选择标签',
  multiple: true,
  searchable: true,
  items: const [
    ParkDropdownSheetItem(label: 'Flutter', value: 'flutter'),
    ParkDropdownSheetItem(label: 'Dart', value: 'dart'),
    ParkDropdownSheetItem(label: 'React', value: 'react'),
    ParkDropdownSheetItem(label: 'Vue', value: 'vue'),
  ],
);
""",
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkDropdownSheet.show(
            context,
            title: '选择标签',
            multiple: true,
            searchable: true,
            items: const [
              ParkDropdownSheetItem(label: 'Flutter', value: 'flutter'),
              ParkDropdownSheetItem(label: 'Dart', value: 'dart'),
              ParkDropdownSheetItem(label: 'React', value: 'react'),
              ParkDropdownSheetItem(label: 'Vue', value: 'vue'),
            ],
          );
        },
        child: const Text('多选 + 搜索'),
      ),
    ),
    ParkDemoScenario(
      title: '网格布局',
      description: '设置 layout 为 grid，以宫格排列选项。',
      code: """
ParkDropdownSheet.show(
  context,
  title: '选择图标',
  layout: ParkDropdownSheetLayout.grid,
  gridColumns: 4,
  items: const [
    ParkDropdownSheetItem(label: '微笑', value: 'smile'),
    ParkDropdownSheetItem(label: '爱心', value: 'heart'),
    ParkDropdownSheetItem(label: '星星', value: 'star'),
    ParkDropdownSheetItem(label: '闪电', value: 'bolt'),
  ],
);
""",
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkDropdownSheet.show(
            context,
            title: '选择图标',
            layout: ParkDropdownSheetLayout.grid,
            gridColumns: 4,
            items: const [
              ParkDropdownSheetItem(label: '微笑', value: 'smile'),
              ParkDropdownSheetItem(label: '爱心', value: 'heart'),
              ParkDropdownSheetItem(label: '星星', value: 'star'),
              ParkDropdownSheetItem(label: '闪电', value: 'bolt'),
            ],
          );
        },
        child: const Text('网格布局'),
      ),
    ),
    ParkDemoScenario(
      title: '自定义内容',
      description: '传入 child 在面板中展示完全自定义的组件。',
      code: """
ParkDropdownSheet.showCustom(
  context,
  title: '自定义面板',
  child: Column(
    children: [
      Text('这里可以是任意 Widget'),
      SizedBox(height: 16),
      ParkButton(
        variant: ParkButtonVariant.primary,
        onPressed: () => Navigator.pop(context),
        child: const Text('关闭'),
      ),
    ],
  ),
  height: 200,
);
""",
      builder: (BuildContext context) => ParkButton(
        onPressed: () {
          ParkDropdownSheet.showCustom(
            context,
            title: '自定义面板',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('这里可以是任意 Widget'),
                const SizedBox(height: 16),
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ],
            ),
            height: 200,
          );
        },
        child: const Text('自定义内容'),
      ),
    ),
    ParkDemoScenario(
      title: '实例化组件',
      description: '作为 StatefulWidget 实例化使用，适合需持久化的场景。',
      code: """
ParkDropdownSheet(
  trigger: const Text('点击打开'),
  title: '选择城市',
  multiple: true,
  items: const [
    ParkDropdownSheetItem(label: '北京', value: 'beijing'),
    ParkDropdownSheetItem(label: '上海', value: 'shanghai'),
  ],
)
""",
      builder: (BuildContext context) => const ParkDropdownSheet(
        trigger: Text('点击打开'),
        title: '选择城市',
        multiple: true,
        items: [
          ParkDropdownSheetItem(label: '北京', value: 'beijing'),
          ParkDropdownSheetItem(label: '上海', value: 'shanghai'),
        ],
      ),
    ),
    ParkDemoScenario(
      title: '触发 + 回调联动',
      description:
          '实例化组件通过 trigger 点击打开面板，下方实时显示 onSelectionChanged / onConfirm / onCancel / onVisibleChanged 四个回调的触发结果。',
      code: '''
final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
String lastEvent = '等待操作...';
Set<String> lastValues = {};
StatefulBuilder(
  builder: (ctx, setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ParkDropdownSheet(
          trigger: Container(
            padding: EdgeInsets.symmetric(horizontal: park.spacing.base, vertical: park.spacing.sm),
            decoration: BoxDecoration(color: park.colors.brandLight, borderRadius: park.radius.brSm),
            child: Text('点击打开', style: TextStyle(color: park.colors.brand)),
          ),
          title: '选择标签',
          multiple: true,
          onSelectionChanged: (v) => setState(() => lastEvent = 'onSelectionChanged: \$v'),
          onConfirm: (v) { lastValues = v; setState(() => lastEvent = 'onConfirm: \$v'); },
          onCancel: () => setState(() => lastEvent = 'onCancel'),
          onVisibleChanged: (open) => setState(() => lastEvent = 'onVisibleChanged: \${open ? '打开' : '关闭'}'),
          items: const [
            ParkDropdownSheetItem(label: 'Flutter', value: 'flutter'),
            ParkDropdownSheetItem(label: 'Dart', value: 'dart'),
            ParkDropdownSheetItem(label: 'React', value: 'react'),
          ],
        ),
        SizedBox(height: park.spacing.base),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(park.spacing.base),
          decoration: BoxDecoration(color: park.colors.background, borderRadius: park.radius.brSm, border: Border.all(color: park.colors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('最近回调', style: TextStyle(fontWeight: FontWeight.w600, color: park.colors.brand)),
              SizedBox(height: park.spacing.xs),
              Text(lastEvent),
              SizedBox(height: park.spacing.xs),
              Text('已确认值: \${lastValues.isEmpty ? '（无）' : lastValues.join(', ')}', style: TextStyle(color: park.colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  },
)
''',
      builder: (BuildContext context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        String lastEvent = '等待操作...';
        Set<String> lastValues = <String>{};
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ParkDropdownSheet(
                  trigger: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: park.spacing.base,
                      vertical: park.spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: park.colors.brandLight,
                      borderRadius: park.radius.brSm,
                    ),
                    child: Text(
                      '点击打开',
                      style: TextStyle(color: park.colors.brand),
                    ),
                  ),
                  title: '选择标签',
                  multiple: true,
                  onSelectionChanged: (v) =>
                      setState(() => lastEvent = 'onSelectionChanged: $v'),
                  onConfirm: (v) {
                    lastValues = v;
                    setState(() => lastEvent = 'onConfirm: $v');
                  },
                  onCancel: () => setState(() => lastEvent = 'onCancel'),
                  onVisibleChanged: (open) => setState(
                    () => lastEvent = 'onVisibleChanged: ${open ? '打开' : '关闭'}',
                  ),
                  items: const [
                    ParkDropdownSheetItem(label: 'Flutter', value: 'flutter'),
                    ParkDropdownSheetItem(label: 'Dart', value: 'dart'),
                    ParkDropdownSheetItem(label: 'React', value: 'react'),
                  ],
                ),
                SizedBox(height: park.spacing.base),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(park.spacing.base),
                  decoration: BoxDecoration(
                    color: park.colors.background,
                    borderRadius: park.radius.brSm,
                    border: Border.all(color: park.colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '最近回调',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: park.colors.brand,
                        ),
                      ),
                      SizedBox(height: park.spacing.xs),
                      Text(lastEvent),
                      SizedBox(height: park.spacing.xs),
                      Text(
                        '已确认值: ${lastValues.isEmpty ? '（无）' : lastValues.join(', ')}',
                        style: TextStyle(color: park.colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
);

// ---------------------------------------------------------------------------
// ParkDropdownFilter
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkDropdownFilterSpec = ParkComponentSpec(
  name: 'ParkDropdownFilter',
  title: '筛选下拉栏',
  category: 'feedback',
  description:
      '顶部横向筛选下拉栏组件。一行水平排列筛选标签（如"状态 ▼  来源 ▼  时间 ▼"），'
      '每个标签点击后弹出独立的底部抽屉面板进行选择。支持预定义选项列表/网格布局和完全自定义 child 两种内容模式，'
      '提供单选、多选、互斥展开、onTab/onChange/onConfirm/onReset 完整回调链。',
  icon: Icons.filter_alt_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'items',
      type: 'List<DropdownFilterItem>',
      required: true,
      description: '筛选标签配置列表，每个标签可配置 options（预定义选项）或 child（自定义面板）。',
    ),
    ParkPropertyDef(
      name: 'spacing',
      type: 'double',
      defaultVal: '8.0',
      description: '标签之间的间距。',
    ),
    ParkPropertyDef(
      name: 'labelPadding',
      type: 'EdgeInsetsGeometry?',
      defaultVal: 'null',
      description: '标签内边距。',
    ),
    ParkPropertyDef(
      name: 'scrollable',
      type: 'bool',
      defaultVal: 'true',
      description: '是否允许标签栏水平溢出滚动。',
    ),
    ParkPropertyDef(
      name: 'style',
      type: 'DropdownFilterStyle?',
      defaultVal: 'null',
      description: '标签栏样式定制（文字颜色/粗细、箭头颜色、下划线颜色等）。',
    ),
    ParkPropertyDef(
      name: 'onFilterChanged',
      type: 'void Function(int, Set<String>)?',
      defaultVal: 'null',
      description: '整体选中值变更回调，参数为标签索引和对应的选中值集合。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onFilterChanged',
      signature: 'void Function(int index, Set<String> selected)?',
      description: '任意标签的选中值变更时触发，统一监听所有筛选条件的变化。',
    ),
    ParkEventDef(
      name: 'item.onTab',
      signature: 'bool Function()?',
      description: '点击标签回调，返回 true 阻止默认展开行为。',
    ),
    ParkEventDef(
      name: 'item.onChange',
      signature: 'void Function(Set<String> selected)?',
      description: '选项变化实时回调。',
    ),
    ParkEventDef(
      name: 'item.onConfirm',
      signature: 'void Function(Set<String> selected)?',
      description: '确认回调（多选模式点击确定触发，单选模式点击选项即触发）。',
    ),
    ParkEventDef(
      name: 'item.onReset',
      signature: 'VoidCallback?',
      description: '取消/重置回调（取消时恢复进入面板前的选中值）。',
    ),
  ],
  methods: const <ParkMethodDef>[
    ParkMethodDef(
      name: 'ParkDropdownFilter (constructor)',
      signature:
          'const ParkDropdownFilter({Key? key, required List<DropdownFilterItem> items, double spacing = 8.0, EdgeInsetsGeometry? labelPadding, bool scrollable = true, DropdownFilterStyle? style, void Function(int, Set<String>)? onFilterChanged})',
      description: '创建顶部横向筛选下拉栏组件。',
    ),
  ],
  basicUsageCode: '''
ParkDropdownFilter(
  items: [
    DropdownFilterItem(
      label: '租赁状态',
      options: [
        DropdownFilterOption(label: '全部', value: ''),
        DropdownFilterOption(label: '进行中', value: 'active'),
        DropdownFilterOption(label: '已完成', value: 'completed'),
      ],
    ),
    DropdownFilterItem(
      label: '租赁来源',
      options: [
        DropdownFilterOption(label: '全部', value: ''),
        DropdownFilterOption(label: '线上', value: 'online'),
        DropdownFilterOption(label: '线下', value: 'offline'),
      ],
    ),
  ],
  onFilterChanged: (index, selected) {
    print('第 \$index 个标签筛选值: \$selected');
  },
)
''',
  guide: '''
## 何时使用

- 列表页头部需要一排横向排列的筛选标签（如"状态 ▼  来源 ▼  时间 ▼"）
- 需要多个维度的筛选条件，每个维度独立展开底部面板进行选择
- 需要完整的回调链（onTab 阻断 / onChange 实时 / onConfirm 确认 / onReset 恢复）

## 设计理念

ParkDropdownFilter 将「横向标签栏 + 多个底部抽屉面板」这一列表筛选高频交互模式统一封装：

1. **互斥展开**：同一时间只展开一个标签的面板，点击另一个标签自动收起当前
2. **双内容模式**：options 模式快速搭建单选/多选面板（列表/网格布局）；child 模式可嵌入任意 Widget（日期范围选择器等）
3. **视觉反馈**：展开/有选中值 → 文字加粗 + 主色 + 箭头向上旋转 + 底部下划线
4. **完整回调链**：onTab（预检查/阻断）→ onChange（实时） → onConfirm（确认） → onReset（取消恢复）

## 注意事项

- items 中的 options 与 child 互斥，child 优先
- 单选模式点击选项即确认关闭；多选模式需点击确定按钮
- isCheck 为 true 时，多选模式下必须至少选中一项才能确认
- 标签 disabled 为 true 时不可点击
- 内部复用 ParkDropdownSheet.showCustom 弹出自定义 child 面板，保证 UI 一致性
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础单选筛选',
      description: '使用 options 模式实现单选筛选标签。每个标签点击展开底部面板，点击选项即确认关闭。',
      code: '''
ParkDropdownFilter(
  items: [
    DropdownFilterItem(
      label: '租赁状态',
      options: [
        DropdownFilterOption(label: '全部', value: ''),
        DropdownFilterOption(label: '进行中', value: 'active'),
        DropdownFilterOption(label: '已完成', value: 'completed'),
        DropdownFilterOption(label: '已取消', value: 'cancelled'),
      ],
    ),
    DropdownFilterItem(
      label: '租赁来源',
      options: [
        DropdownFilterOption(label: '全部', value: ''),
        DropdownFilterOption(label: '线上', value: 'online'),
        DropdownFilterOption(label: '线下', value: 'offline'),
      ],
    ),
    DropdownFilterItem(
      label: '时间筛选',
      options: [
        DropdownFilterOption(label: '今天', value: 'today'),
        DropdownFilterOption(label: '本周', value: 'week'),
        DropdownFilterOption(label: '本月', value: 'month'),
      ],
    ),
  ],
)
''',
      builder: (BuildContext context) => SizedBox(
        height: 48,
        child: ParkDropdownFilter(
          items: const [
            DropdownFilterItem(
              label: '租赁状态',
              options: [
                DropdownFilterOption(label: '全部', value: ''),
                DropdownFilterOption(label: '进行中', value: 'active'),
                DropdownFilterOption(label: '已完成', value: 'completed'),
                DropdownFilterOption(label: '已取消', value: 'cancelled'),
              ],
            ),
            DropdownFilterItem(
              label: '租赁来源',
              options: [
                DropdownFilterOption(label: '全部', value: ''),
                DropdownFilterOption(label: '线上', value: 'online'),
                DropdownFilterOption(label: '线下', value: 'offline'),
              ],
            ),
            DropdownFilterItem(
              label: '时间筛选',
              options: [
                DropdownFilterOption(label: '今天', value: 'today'),
                DropdownFilterOption(label: '本周', value: 'week'),
                DropdownFilterOption(label: '本月', value: 'month'),
              ],
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '多选 + 网格布局',
      description: '开启 multiple 并使用 columns 网格布局，适合标签/分类筛选。',
      code: '''
ParkDropdownFilter(
  items: [
    DropdownFilterItem(
      label: '户型',
      multiple: true,
      columns: 3,
      options: [
        DropdownFilterOption(label: '一室', value: '1r'),
        DropdownFilterOption(label: '两室', value: '2r'),
        DropdownFilterOption(label: '三室', value: '3r'),
        DropdownFilterOption(label: '四室', value: '4r'),
        DropdownFilterOption(label: '五室+', value: '5r'),
      ],
    ),
  ],
)
''',
      builder: (BuildContext context) => SizedBox(
        height: 48,
        child: ParkDropdownFilter(
          items: const [
            DropdownFilterItem(
              label: '户型',
              multiple: true,
              columns: 3,
              options: [
                DropdownFilterOption(label: '一室', value: '1r'),
                DropdownFilterOption(label: '两室', value: '2r'),
                DropdownFilterOption(label: '三室', value: '3r'),
                DropdownFilterOption(label: '四室', value: '4r'),
                DropdownFilterOption(label: '五室+', value: '5r'),
              ],
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '自定义内容模式',
      description: 'child 模式可嵌入任意自定义 Widget，如日期范围选择器等复杂筛选控件。',
      code: '''
ParkDropdownFilter(
  items: [
    DropdownFilterItem(label: '租赁状态',
      options: [
        DropdownFilterOption(label: '全部', value: ''),
        DropdownFilterOption(label: '进行中', value: 'active'),
      ],
    ),
    DropdownFilterItem(
      label: '日期范围',
      child: Column(
        children: [Text('自定义日期选择器')],
      ),
    ),
  ],
)
''',
      builder: (BuildContext context) => SizedBox(
        height: 48,
        child: ParkDropdownFilter(
          items: [
            const DropdownFilterItem(
              label: '租赁状态',
              options: [
                DropdownFilterOption(label: '全部', value: ''),
                DropdownFilterOption(label: '进行中', value: 'active'),
              ],
            ),
            DropdownFilterItem(
              label: '日期范围',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('自定义日期选择器'),
                    const SizedBox(height: 16),
                    ParkButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    ParkDemoScenario(
      title: '回调事件演示',
      description:
          '点击标签或选中选项时，下方实时显示触发的回调事件和参数。验证 onTab / onChange / onConfirm / onReset / onFilterChanged 的完整调用链。',
      code: '''
ParkDropdownFilter(
  items: [
    DropdownFilterItem(label: '租赁状态', options: [
      DropdownFilterOption(label: '全部', value: ''),
      DropdownFilterOption(label: '进行中', value: 'active'),
    ]),
    DropdownFilterItem(
      label: '日期范围',
      multiple: true,
      columns: 2,
      options: [
        DropdownFilterOption(label: '今天', value: 'today'),
        DropdownFilterOption(label: '本周', value: 'week'),
        DropdownFilterOption(label: '本月', value: 'month'),
      ],
      onChange: (v) => print('onChange: \${v}'),
      onConfirm: (v) => print('onConfirm: \${v}'),
    ),
  ],
  onFilterChanged: (i, s) => print('filter \$i: \$s'),
)
''',
      builder: (BuildContext context) =>
          const _ParkDropdownFilterCallbackDemo(),
    ),
    ParkDemoScenario(
      title: '筛选应用（联动列表）',
      description:
          '选择筛选条件后，下方列表实时按选中值过滤，演示 selection change（onFilterChanged）到 filter application 的完整链路。',
      code: '''
final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
final Map<int, Set<String>> selected = {};
StatefulBuilder(
  builder: (ctx, setState) {
    final all = <Map<String, String>>[
      {'name': '订单 A', 'status': 'active', 'source': 'online'},
      {'name': '订单 B', 'status': 'done', 'source': 'offline'},
      {'name': '订单 C', 'status': 'active', 'source': 'offline'},
      {'name': '订单 D', 'status': 'done', 'source': 'online'},
    ];
    final statusSel = selected[0] ?? {};
    final sourceSel = selected[1] ?? {};
    final filtered = all.where((m) {
      final okStatus = statusSel.isEmpty || statusSel.contains(m['status']);
      final okSource = sourceSel.isEmpty || sourceSel.contains(m['source']);
      return okStatus && okSource;
    }).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: park.spacing.page, child: ParkDropdownFilter(
          items: const [
            DropdownFilterItem(label: '状态', options: [
              DropdownFilterOption(label: '进行中', value: 'active'),
              DropdownFilterOption(label: '已完成', value: 'done'),
            ]),
            DropdownFilterItem(label: '来源', options: [
              DropdownFilterOption(label: '线上', value: 'online'),
              DropdownFilterOption(label: '线下', value: 'offline'),
            ]),
          ],
          onFilterChanged: (index, sel) { selected[index] = sel; setState(() {}); },
        )),
        SizedBox(height: park.spacing.base),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: park.colors.background, borderRadius: park.radius.brSm, border: Border.all(color: park.colors.border)),
          child: Column(
            children: <Widget>[
              for (final m in filtered)
                ListTile(dense: true, title: Text(m['name']!), subtitle: Text('\${m['status']} · \${m['source']}'), trailing: Icon(Icons.chevron_right, color: park.colors.textPlaceholder)),
            ],
          ),
        ),
        SizedBox(height: park.spacing.sm),
        Text('共 \${filtered.length} 条结果', style: TextStyle(color: park.colors.textSecondary)),
      ],
    );
  },
)
''',
      builder: (BuildContext context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        final Map<int, Set<String>> selected = <int, Set<String>>{};
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            final all = <Map<String, String>>[
              <String, String>{
                'name': '订单 A',
                'status': 'active',
                'source': 'online',
              },
              <String, String>{
                'name': '订单 B',
                'status': 'done',
                'source': 'offline',
              },
              <String, String>{
                'name': '订单 C',
                'status': 'active',
                'source': 'offline',
              },
              <String, String>{
                'name': '订单 D',
                'status': 'done',
                'source': 'online',
              },
            ];
            final statusSel = selected[0] ?? <String>{};
            final sourceSel = selected[1] ?? <String>{};
            final filtered = all.where((m) {
              final okStatus =
                  statusSel.isEmpty || statusSel.contains(m['status']);
              final okSource =
                  sourceSel.isEmpty || sourceSel.contains(m['source']);
              return okStatus && okSource;
            }).toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: park.spacing.page,
                  child: ParkDropdownFilter(
                    items: const [
                      DropdownFilterItem(
                        label: '状态',
                        options: [
                          DropdownFilterOption(label: '进行中', value: 'active'),
                          DropdownFilterOption(label: '已完成', value: 'done'),
                        ],
                      ),
                      DropdownFilterItem(
                        label: '来源',
                        options: [
                          DropdownFilterOption(label: '线上', value: 'online'),
                          DropdownFilterOption(label: '线下', value: 'offline'),
                        ],
                      ),
                    ],
                    onFilterChanged: (index, sel) {
                      selected[index] = sel;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: park.spacing.base),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: park.colors.background,
                    borderRadius: park.radius.brSm,
                    border: Border.all(color: park.colors.border),
                  ),
                  child: Column(
                    children: <Widget>[
                      for (final m in filtered)
                        ListTile(
                          dense: true,
                          title: Text(m['name']!),
                          subtitle: Text('${m['status']} · ${m['source']}'),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: park.colors.textPlaceholder,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: park.spacing.sm),
                Text(
                  '共 \${filtered.length} 条结果',
                  style: TextStyle(color: park.colors.textSecondary),
                ),
              ],
            );
          },
        );
      },
    ),
  ],
);

/// ParkDropdownFilter 回调演示辅助组件。
///
/// 在筛选栏下方显示最近触发的回调事件和参数，便于 Demo 页验证。
class _ParkDropdownFilterCallbackDemo extends StatefulWidget {
  const _ParkDropdownFilterCallbackDemo();
  @override
  State<_ParkDropdownFilterCallbackDemo> createState() =>
      _ParkDropdownFilterCallbackDemoState();
}

class _ParkDropdownFilterCallbackDemoState
    extends State<_ParkDropdownFilterCallbackDemo> {
  String _lastEvent = '暂无事件';
  String _lastArgs = '等待操作...';

  void _logEvent(String event, String args) {
    setState(() {
      _lastEvent = event;
      _lastArgs = args;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: '状态',
                options: const [
                  DropdownFilterOption(label: '全部', value: ''),
                  DropdownFilterOption(label: '进行中', value: 'active'),
                  DropdownFilterOption(label: '已完成', value: 'done'),
                ],
                onChange: (v) => _logEvent('onChange', '选中值: $v'),
                onConfirm: (v) => _logEvent('onConfirm', '确认值: $v'),
                onReset: () => _logEvent('onReset', '已取消/重置'),
              ),
              DropdownFilterItem(
                label: '类型',
                multiple: true,
                columns: 2,
                options: const [
                  DropdownFilterOption(label: 'A类', value: 'a'),
                  DropdownFilterOption(label: 'B类', value: 'b'),
                  DropdownFilterOption(label: 'C类', value: 'c'),
                  DropdownFilterOption(label: 'D类', value: 'd'),
                ],
                onChange: (v) => _logEvent('onChange', '多选值: $v'),
                onConfirm: (v) => _logEvent('onConfirm', '确认: $v'),
                onReset: () => _logEvent('onReset', '已取消/重置'),
              ),
              DropdownFilterItem(
                label: '自定义',
                onTab: () {
                  _logEvent('onTab', '阻止默认展开');
                  return true;
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('自定义面板内容'),
                      const SizedBox(height: 12),
                      ParkButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onFilterChanged: (index, selected) {
              _logEvent('onFilterChanged', '标签[$index] 值: $selected');
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '最近回调事件',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lastEvent,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                _lastArgs,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ParkTour
// ---------------------------------------------------------------------------
final ParkComponentSpec _parkTourSpec = ParkComponentSpec(
  name: 'ParkTour',
  title: '漫游式引导',
  category: 'feedback',
  description:
      '新手指引/功能引导组件，对标 antd Tour。通过 Overlay + CustomPainter 在全屏绘制半透明遮罩，'
      '在目标 Widget 位置掏空矩形区域让用户聚焦，同时在该区域旁弹出气泡卡片显示引导信息。'
      '支持多步序列（导航/跳过/完成）、箭头指示、滚动自动跟随、受控/非受控模式。',
  icon: Icons.tour_outlined,
  properties: const <ParkPropertyDef>[
    ParkPropertyDef(
      name: 'steps',
      type: 'List<ParkTourStep>',
      required: true,
      description: '引导步骤列表，每步包含 target（GlobalKey）、title、description、placement 等。',
    ),
    ParkPropertyDef(
      name: 'open',
      type: 'bool',
      required: true,
      description: '是否打开引导。',
    ),
    ParkPropertyDef(
      name: 'current',
      type: 'int?',
      defaultVal: 'null',
      description: '当前步骤索引（受控模式）。不提供时内部维护状态。',
    ),
    ParkPropertyDef(
      name: 'onChange',
      type: 'ValueChanged<int>?',
      description: '步骤切换回调（受控模式）。',
    ),
    ParkPropertyDef(
      name: 'onClose',
      type: 'VoidCallback?',
      description: '关闭引导回调（点击遮罩、跳过或 Esc）。',
    ),
    ParkPropertyDef(
      name: 'onFinish',
      type: 'VoidCallback?',
      description: '完成引导回调（最后一步点「完成」）。',
    ),
    ParkPropertyDef(
      name: 'mask',
      type: 'bool',
      defaultVal: 'true',
      description: '是否启用全局遮罩。可被单步 mask 覆盖。',
    ),
    ParkPropertyDef(
      name: 'arrow',
      type: 'bool',
      defaultVal: 'true',
      description: '是否显示箭头。可被单步 arrow 覆盖。',
    ),
    ParkPropertyDef(
      name: 'closeOnMaskTap',
      type: 'bool',
      defaultVal: 'true',
      description: '点击遮罩是否关闭引导。',
    ),
    ParkPropertyDef(
      name: 'prevButtonText',
      type: 'String?',
      defaultVal: 'ParkLocalizations.previousStep',
      description: '上一步按钮文字。',
    ),
    ParkPropertyDef(
      name: 'nextButtonText',
      type: 'String?',
      defaultVal: 'ParkLocalizations.nextStep',
      description: '下一步按钮文字。',
    ),
    ParkPropertyDef(
      name: 'skipButtonText',
      type: 'String?',
      defaultVal: "'跳过'",
      description: '跳过按钮文字。',
    ),
    ParkPropertyDef(
      name: 'doneButtonText',
      type: 'String?',
      defaultVal: 'ParkLocalizations.doneText',
      description: '完成按钮文字。',
    ),
    ParkPropertyDef(
      name: 'gap',
      type: 'EdgeInsets',
      defaultVal: 'EdgeInsets.all(6)',
      description: '高亮区域在目标周围外扩的间距。可被单步 gap 覆盖。',
    ),
    ParkPropertyDef(
      name: 'highlightRadius',
      type: 'double',
      defaultVal: '8',
      description: '高亮区域圆角半径。可被单步 borderRadius 覆盖。',
    ),
    ParkPropertyDef(
      name: 'maskColor',
      type: 'Color?',
      defaultVal: 'park.colors.overlay',
      description: '遮罩颜色。',
    ),
    ParkPropertyDef(
      name: 'zIndex',
      type: 'int',
      defaultVal: '1060',
      description: 'Tour 的 z-index 层级。',
    ),
    ParkPropertyDef(
      name: 'stepIndicatorBuilder',
      type: 'Widget Function(int current, int total)?',
      description: '自定义步数指示器构建器。',
    ),
  ],
  events: const <ParkEventDef>[
    ParkEventDef(
      name: 'onChange',
      signature: 'ValueChanged<int>?',
      description: '步骤切换回调。',
    ),
    ParkEventDef(
      name: 'onClose',
      signature: 'VoidCallback?',
      description: '关闭引导回调。',
    ),
    ParkEventDef(
      name: 'onFinish',
      signature: 'VoidCallback?',
      description: '完成引导回调。',
    ),
  ],
  methods: const <ParkMethodDef>[],
  basicUsageCode: '''
ParkTour(
  open: _tourVisible,
  steps: [
    ParkTourStep(
      target: _step1Key,
      title: '上传文件',
      description: '点击此处上传您的文件。',
      placement: ParkTourPlacement.bottom,
    ),
    ParkTourStep(
      target: _step2Key,
      title: '保存',
      description: '完成编辑后点击此处保存修改。',
      placement: ParkTourPlacement.right,
    ),
  ],
  onClose: () => setState(() => _tourVisible = false),
  onFinish: () => setState(() => _tourVisible = false),
)
''',
  guide: '''
## 何时使用

- 新用户首次进入应用时，引导其了解核心功能
- 产品上线新功能时，引导用户发现和使用新特性
- 复杂页面中需要分步骤引导用户完成特定流程

## 使用建议

1. **步骤设计**：建议 3-5 步，每步聚焦一个明确的目标，描述简洁
2. **定位策略**：优先使用 bottom / right 方向，避免气泡遮挡关键 UI
3. **受控模式**：通过 current + onChange 实现外部控制，支持与本地存储配合实现"仅首次显示"
4. **遮罩增强**：通过 gap 和 highlightRadius 控制高亮区域的外扩和圆角
5. **自定义指示器**：使用 stepIndicatorBuilder 替换默认的 "第 X / Y 步" 显示
6. **无目标居中**：设置 target 为 null 时气泡居中，适合全局说明

## 注意事项

- target 使用 GlobalKey 定位，确保目标 Widget 已 build 且挂载
- 切换步骤时自动调用 Scrollable.ensureVisible 滚动到目标
- 点击遮罩（closeOnMaskTap=true）或按 Esc（keyboard=true）可关闭
- 所有颜色/间距/圆角/字号均走 park.* 令牌系统，支持亮暗主题切换
''',
  demos: <ParkDemoScenario>[
    ParkDemoScenario(
      title: '基础步骤引导',
      description:
          '演示三步骤基础引导流程：点击按钮打开 Tour，按步骤依次引导用户关注三个目标区域，最后点「完成」关闭。',
      code: '''
final parkTheme = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
bool visible = false;
final step1 = GlobalKey();
final step2 = GlobalKey();
final step3 = GlobalKey();
StatefulBuilder(
  builder: (ctx, setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ParkButton(key: step1, onPressed: () {}, child: const Text('上传')),
            ParkButton(key: step2, onPressed: () {}, child: const Text('编辑')),
            ParkButton(key: step3, onPressed: () {}, child: const Text('保存')),
          ],
        ),
        SizedBox(height: 16),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () => setState(() => visible = true),
          child: const Text('开始引导'),
        ),
        if (visible)
          ParkTour(
            open: visible,
            steps: [
              ParkTourStep(target: step1, title: '上传文件', description: '点击上传按钮选择您的文件。', placement: ParkTourPlacement.bottom),
              ParkTourStep(target: step2, title: '编辑内容', description: '对已上传的文件进行编辑操作。', placement: ParkTourPlacement.bottom),
              ParkTourStep(target: step3, title: '保存修改', description: '完成编辑后保存您的修改。', placement: ParkTourPlacement.top),
            ],
            onClose: () => setState(() => visible = false),
            onFinish: () => setState(() => visible = false),
          ),
      ],
    );
  },
)
''',
      builder: (BuildContext context) {
        bool visible = false;
        final step1 = GlobalKey();
        final step2 = GlobalKey();
        final step3 = GlobalKey();
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ParkButton(key: step1, onPressed: () {}, child: const Text('上传')),
                    ParkButton(key: step2, onPressed: () {}, child: const Text('编辑')),
                    ParkButton(key: step3, onPressed: () {}, child: const Text('保存')),
                  ],
                ),
                const SizedBox(height: 16),
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  onPressed: () => setState(() => visible = true),
                  child: const Text('开始引导'),
                ),
                if (visible)
                  ParkTour(
                    open: visible,
                    steps: [
                      ParkTourStep(
                        target: step1,
                        title: '上传文件',
                        description: '点击上传按钮选择您的文件。',
                        placement: ParkTourPlacement.bottom,
                      ),
                      ParkTourStep(
                        target: step2,
                        title: '编辑内容',
                        description: '对已上传的文件进行编辑操作。',
                        placement: ParkTourPlacement.bottom,
                      ),
                      ParkTourStep(
                        target: step3,
                        title: '保存修改',
                        description: '完成编辑后保存您的修改。',
                        placement: ParkTourPlacement.top,
                      ),
                    ],
                    onClose: () => setState(() => visible = false),
                    onFinish: () => setState(() => visible = false),
                  ),
              ],
            );
          },
        );
      },
    ),
    ParkDemoScenario(
      title: '嵌套目标 + 自定义 placement',
      description:
          '各步骤使用不同的 placement 方向，演示气泡从不同方向锚定目标。'
          '第一步 bottom、第二步 right、第三步 left（如果空间允许），展示 Tour 灵活的定位能力。',
      code: '''
final parkTheme = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
bool visible = false;
final ref1 = GlobalKey();
final ref2 = GlobalKey();
final ref3 = GlobalKey();
StatefulBuilder(
  builder: (ctx, setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(border: Border.all(color: parkTheme.colors.border), borderRadius: parkTheme.radius.brMd),
          child: Column(
            children: [
              Container(key: ref1, padding: EdgeInsets.all(16), color: parkTheme.colors.brandLight, child: Text('目标 A', style: TextStyle(color: parkTheme.colors.brand))),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(key: ref2, padding: EdgeInsets.all(16), color: parkTheme.colors.successLight, child: Text('目标 B', style: TextStyle(color: parkTheme.colors.success))),
                  Container(key: ref3, padding: EdgeInsets.all(16), color: parkTheme.colors.warningLight, child: Text('目标 C', style: TextStyle(color: parkTheme.colors.warning))),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () => setState(() => visible = true),
          child: const Text('开始多方向引导'),
        ),
        if (visible)
          ParkTour(
            open: visible,
            steps: [
              ParkTourStep(target: ref1, title: '目标 A', description: '气泡从下方弹出。', placement: ParkTourPlacement.bottom),
              ParkTourStep(target: ref2, title: '目标 B', description: '气泡从右侧弹出。', placement: ParkTourPlacement.right),
              ParkTourStep(target: ref3, title: '目标 C', description: '带有自定义高亮间距和圆角。', placement: ParkTourPlacement.bottom, gap: EdgeInsets.all(12), borderRadius: 16),
            ],
            onClose: () => setState(() => visible = false),
            onFinish: () => setState(() => visible = false),
          ),
      ],
    );
  },
)
''',
      builder: (BuildContext context) {
        final parkTheme = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
        bool visible = false;
        final ref1 = GlobalKey();
        final ref2 = GlobalKey();
        final ref3 = GlobalKey();
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    border: Border.all(color: parkTheme.colors.border),
                    borderRadius: parkTheme.radius.brMd,
                  ),
                  child: Column(
                    children: [
                      Container(
                        key: ref1,
                        padding: const EdgeInsets.all(16),
                        color: parkTheme.colors.brandLight,
                        child: Text('目标 A', style: TextStyle(color: parkTheme.colors.brand)),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            key: ref2,
                            padding: const EdgeInsets.all(16),
                            color: parkTheme.colors.successLight,
                            child: Text('目标 B', style: TextStyle(color: parkTheme.colors.success)),
                          ),
                          Container(
                            key: ref3,
                            padding: const EdgeInsets.all(16),
                            color: parkTheme.colors.warningLight,
                            child: Text('目标 C', style: TextStyle(color: parkTheme.colors.warning)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ParkButton(
                  variant: ParkButtonVariant.primary,
                  onPressed: () => setState(() => visible = true),
                  child: const Text('开始多方向引导'),
                ),
                if (visible)
                  ParkTour(
                    open: visible,
                    steps: [
                      ParkTourStep(
                        target: ref1,
                        title: '目标 A',
                        description: '气泡从下方弹出。',
                        placement: ParkTourPlacement.bottom,
                      ),
                      ParkTourStep(
                        target: ref2,
                        title: '目标 B',
                        description: '气泡从右侧弹出。',
                        placement: ParkTourPlacement.right,
                      ),
                      ParkTourStep(
                        target: ref3,
                        title: '目标 C',
                        description: '带有自定义高亮间距和圆角。',
                        placement: ParkTourPlacement.bottom,
                        gap: const EdgeInsets.all(12),
                        borderRadius: 16,
                      ),
                    ],
                    onClose: () => setState(() => visible = false),
                    onFinish: () => setState(() => visible = false),
                  ),
              ],
            );
          },
        );
      },
    ),
  ],
);
