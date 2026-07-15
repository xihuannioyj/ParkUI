import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// Park Tab 指示器类型
enum ParkTabIndicatorType {
  /// 下划线指示器
  line,

  /// 卡片式背景指示器
  card,
}

/// Park Tab 位置
///
/// 控制标签栏相对于内容区域的位置。
enum ParkTabPosition {
  /// 顶部（默认）
  top,

  /// 底部
  bottom,

  /// 左侧
  left,

  /// 右侧
  right,
}

/// Park Tab 类型
///
/// 控制标签的视觉风格。
enum ParkTabType {
  /// 下划线风格（默认）
  line,

  /// 卡片风格
  card,
}

/// Park Tab 尺寸
enum ParkTabSize {
  /// 中等尺寸（默认）
  medium,

  /// 大尺寸
  large,
}

/// Park Tab 数据模型
///
/// 用于描述 [ParkTabs] 中每个标签页的配置信息。
class ParkTab {
  /// 标签文字
  final String label;

  /// 可选前置图标
  final IconData? icon;

  /// 可选角标（数字或红点文字）
  final String? badge;

  const ParkTab({required this.label, this.icon, this.badge});
}

/// Park 标签页
///
/// 提供顶部 Tab 切换导航，支持固定与可滚动两种模式，
/// 内置品牌色下划线动画指示器，可搭配 [TabBarView] 使用。
///
/// ```dart
/// ParkTabs(
///   tabs: [
///     ParkTab(label: '推荐'),
///     ParkTab(label: '热门', badge: '9'),
///     ParkTab(label: '最新', icon: Icons.new_releases),
///   ],
///   onChanged: (index) => print('切换到 $index'),
///   children: [
///     Center(child: Text('推荐内容')),
///     Center(child: Text('热门内容')),
///     Center(child: Text('最新内容')),
///   ],
/// )
/// ```
class ParkTabs extends StatefulWidget {
  /// 标签页列表
  final List<ParkTab> tabs;

  /// 初始选中索引
  final int initialIndex;

  /// 当前受控选中索引
  ///
  /// 为空时组件内部自行维护选中状态；
  /// 不为空时组件由外部完全控制选中项。
  final int? currentIndex;

  /// 切换回调
  final ValueChanged<int>? onChanged;

  /// 是否可滚动（标签多时启用）
  final bool scrollable;

  /// 指示器类型
  final ParkTabIndicatorType indicatorType;

  /// 对应每个标签页的内容 Widget（数量需与 [tabs] 一致）
  final List<Widget>? children;

  /// 标签栏位置（top / bottom / left / right）
  final ParkTabPosition tabPosition;

  /// 内容切换时是否启用动画
  final bool animated;

  /// 标签是否居中排列
  final bool centered;

  /// 标签类型（line = 下划线，card = 卡片式）
  ///
  /// 当非 null 时优先于 [indicatorType] 使用。
  final ParkTabType? type;

  /// 标签栏尾部额外内容（如设置图标等）
  final Widget? tabBarExtraContent;

  /// 是否在每个标签上显示关闭按钮（旧 API，由 [editable] 替代）
  final bool closable;

  /// 关闭标签时的回调（旧 API，由 [onTabClose] 替代）
  final ValueChanged<int>? onClose;

  /// 是否显示添加标签按钮（旧 API，由 [showAddButton] 替代）
  final bool addable;

  /// 点击添加按钮时的回调（旧 API，由 [onTabAdd] 替代）
  final VoidCallback? onAdd;

  /// 是否可编辑 — 为 true 时每个 tab 显示关闭按钮（✕），最后一个 tab 不能关闭
  final bool editable;

  /// tab 关闭回调，由调用方实现删除 tab 后的数据更新
  final ValueChanged<int>? onTabClose;

  /// 为 true 时 tab 栏末尾显示「+」添加按钮
  final bool showAddButton;

  /// 添加按钮点击回调
  final VoidCallback? onTabAdd;

  /// tab 栏右侧额外内容区域（在滚动区外的右端位置，排布在添加按钮之右）
  final Widget? extra;

  /// 是否销毁非活动标签页内容（默认 false，不销毁）
  final bool destroyInactiveTabPane;

  /// 标签之间的间距
  final double? tabBarGutter;

  /// 标签栏尺寸
  final ParkTabSize size;

  /// 标签栏自定义装饰（背景、边框、圆角等）
  final BoxDecoration? tabBarStyle;

  /// 指示器颜色（覆盖默认品牌色）
  final Color? indicatorColor;

  /// 指示器宽度（默认跟随标签宽度）
  final double? indicatorWidth;

  /// 指示器高度（默认 2px）
  final double? indicatorHeight;

  /// 自定义 Tab Widget 构建器。
  ///
  /// 当提供时，每个 Tab 的 Widget 由此构建器生成，忽略 [ParkTab] 的默认渲染。
  /// 参数为 (index, isSelected)，返回自定义 Widget。
  final Widget Function(int index, bool isSelected)? tabBuilder;

  /// 指示器内边距。
  final EdgeInsetsGeometry? indicatorPadding;

  /// 是否支持键盘方向键切换标签
  final bool keyboard;

  /// 绑定键（点号分隔的路径，如 `'selectedTab'`）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  const ParkTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.currentIndex,
    this.onChanged,
    this.scrollable = false,
    this.indicatorType = ParkTabIndicatorType.line,
    this.children,
    this.tabPosition = ParkTabPosition.top,
    this.animated = true,
    this.centered = false,
    this.type,
    this.tabBarExtraContent,
    this.closable = false,
    this.onClose,
    this.addable = false,
    this.onAdd,
    this.editable = false,
    this.onTabClose,
    this.showAddButton = false,
    this.onTabAdd,
    this.extra,
    this.destroyInactiveTabPane = false,
    this.tabBarGutter,
    this.size = ParkTabSize.medium,
    this.tabBarStyle,
    this.indicatorColor,
    this.indicatorWidth,
    this.indicatorHeight,
    this.tabBuilder,
    this.indicatorPadding,
    this.keyboard = false,
    this.bindKey,
    this.bindingService,
  }) : assert(
         children == null || children.length == tabs.length,
         '当提供 children 时，必须同时提供 tabs，且数量一致。',
       );

  @override
  State<ParkTabs> createState() => _ParkTabsState();
}

class _ParkTabsState extends State<ParkTabs>
    with SingleTickerProviderStateMixin, BindableWidgetMixin<int, ParkTabs> {
  TabController? _controller;
  bool _suppressChangeNotification = false;
  int _lastReportedIndex = 0;

  bool get _hasTabs => widget.tabs.isNotEmpty;

  bool get _isControlled => widget.currentIndex != null;

  int get _effectiveIndex {
    if (!_hasTabs) return 0;
    final int rawIndex = widget.currentIndex ?? widget.initialIndex;
    return rawIndex.clamp(0, widget.tabs.length - 1);
  }

  /// 解析实际使用的指示器类型（type 优先于 indicatorType）
  ParkTabIndicatorType get _resolvedIndicatorType {
    if (widget.type != null) {
      return widget.type == ParkTabType.card
          ? ParkTabIndicatorType.card
          : ParkTabIndicatorType.line;
    }
    return widget.indicatorType;
  }

  bool get _isVertical =>
      widget.tabPosition == ParkTabPosition.left ||
      widget.tabPosition == ParkTabPosition.right;

  /// 统一闭包编辑状态：新 API [editable] 优先，旧 API [closable] 作为降级
  bool get _effectiveEditable => widget.editable || widget.closable;

  /// 统一关闭回调：新 API [onTabClose] 优先
  ValueChanged<int>? get _effectiveOnTabClose =>
      widget.onTabClose ?? widget.onClose;

  /// 统一添加按钮：新 API [showAddButton] 优先
  bool get _effectiveShowAddButton => widget.showAddButton || widget.addable;

  /// 统一添加回调：新 API [onTabAdd] 优先
  VoidCallback? get _effectiveOnTabAdd => widget.onTabAdd ?? widget.onAdd;

  /// 统一额外内容：新 API [extra] 优先
  Widget? get _effectiveExtra => widget.extra ?? widget.tabBarExtraContent;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _createController();

    // 从 bindable 读取初始值
    final initialValue = boundValue;
    if (initialValue != null && _controller != null) {
      final int clamped = initialValue.clamp(0, widget.tabs.length - 1);
      _suppressChangeNotification = true;
      _controller!.animateTo(clamped);
      _lastReportedIndex = clamped;
    }
  }

  @override
  void didUpdateWidget(covariant ParkTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _disposeController();
      _createController();
      return;
    }

    if (!_hasTabs) {
      _disposeController();
      return;
    }

    if (_controller == null) {
      _createController();
      return;
    }

    if (oldWidget.currentIndex != widget.currentIndex) {
      _syncControllerToWidgetIndex();
    }
  }

  void _createController() {
    if (!_hasTabs) {
      _controller = null;
      _lastReportedIndex = 0;
      return;
    }

    final TabController controller = TabController(
      length: widget.tabs.length,
      initialIndex: _effectiveIndex,
      vsync: this,
    );
    controller.addListener(_handleTabChange);
    _controller = controller;
    _lastReportedIndex = controller.index;
  }

  void _disposeController() {
    _controller?.removeListener(_handleTabChange);
    _controller?.dispose();
    _controller = null;
  }

  void _syncControllerToWidgetIndex() {
    final TabController? controller = _controller;
    if (controller == null || !_hasTabs) return;

    final int targetIndex = _effectiveIndex;
    if (controller.index == targetIndex) return;

    _suppressChangeNotification = true;
    controller.animateTo(targetIndex);
    _lastReportedIndex = targetIndex;
  }

  void _handleTabChange() {
    final TabController? controller = _controller;
    if (controller == null) return;

    if (_suppressChangeNotification) {
      if (!controller.indexIsChanging) {
        _suppressChangeNotification = false;
      }
      return;
    }

    if (!controller.indexIsChanging && controller.index != _lastReportedIndex) {
      _lastReportedIndex = controller.index;
      widget.onChanged?.call(controller.index);
      boundValue = controller.index;

      if (_isControlled && controller.index != _effectiveIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_isControlled) return;
          _syncControllerToWidgetIndex();
        });
      }
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasTabs) {
      return const SizedBox.shrink();
    }

    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final TabController controller = _controller!;
    final bool hasChildren = widget.children != null;

    if (_isVertical) {
      return _buildVerticalLayout(park, controller, hasChildren);
    }
    return _buildHorizontalLayout(park, controller, hasChildren);
  }

  /// 水平布局（top / bottom）
  Widget _buildHorizontalLayout(
    ParkThemeData park,
    TabController controller,
    bool hasChildren,
  ) {
    final tabBar = _buildTabBar(park, controller);
    final content = hasChildren ? _buildContent(controller) : null;

    final List<Widget> children;
    if (widget.tabPosition == ParkTabPosition.bottom) {
      children = [
        if (content != null) Expanded(child: content),
        tabBar,
      ];
    } else {
      children = [
        tabBar,
        if (content != null) Expanded(child: content),
      ];
    }

    return Column(children: children);
  }

  /// 垂直布局（left / right）
  Widget _buildVerticalLayout(
    ParkThemeData park,
    TabController controller,
    bool hasChildren,
  ) {
    final tabBar = _buildVerticalTabBar(park, controller);
    final content = hasChildren ? _buildContent(controller) : null;

    final List<Widget> children;
    if (widget.tabPosition == ParkTabPosition.right) {
      children = [
        if (content != null) Expanded(child: content),
        tabBar,
      ];
    } else {
      children = [
        tabBar,
        if (content != null) Expanded(child: content),
      ];
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  /// 构建内容区域
  Widget _buildContent(TabController controller) {
    // destroyInactiveTabPane：仅渲染当前激活标签页的内容
    if (widget.destroyInactiveTabPane) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return widget.children![controller.index];
        },
      );
    }

    final view = TabBarView(
      controller: controller,
      children: widget.children!,
    );

    if (!widget.animated) {
      // 禁用滑动动画：用 IndexedStack 替代
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return IndexedStack(
            index: controller.index,
            children: widget.children!,
          );
        },
      );
    }

    return view;
  }

  /// 水平 TabBar（top / bottom）
  Widget _buildTabBar(ParkThemeData park, TabController controller) {
    final colors = park.colors;
    final indicator = _resolvedIndicatorType;
    final isCard = indicator == ParkTabIndicatorType.card;
    final isLarge = widget.size == ParkTabSize.large;
    final labelFontSize = isLarge
        ? park.typography.sizeBody + 2.0
        : park.typography.sizeBody;

    // 构建标签列表（支持 tabBuilder 和 gutter 间距）
    final rawTabs = widget.tabs.asMap().entries.map(
      (e) {
        if (widget.tabBuilder != null) {
          return widget.tabBuilder!(e.key, controller.index == e.key);
        }
        return _buildTab(e.value, e.key, park);
      },
    ).toList();

    final List<Widget> tabWidgets;
    if (widget.tabBarGutter != null && widget.tabBarGutter! > 0) {
      tabWidgets = [];
      for (int i = 0; i < rawTabs.length; i++) {
        tabWidgets.add(rawTabs[i]);
        if (i < rawTabs.length - 1) {
          tabWidgets.add(SizedBox(width: widget.tabBarGutter));
        }
      }
    } else {
      tabWidgets = rawTabs;
    }

    // 添加"+"按钮
    if (_effectiveShowAddButton) {
      tabWidgets.add(
        Padding(
          padding: EdgeInsets.only(left: park.spacing.sm),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _effectiveOnTabAdd,
            child: Semantics(
              button: true,
              label: 'Add tab',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(
                  Icons.add,
                  size: isLarge ? 22 : 18,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget tabBar = TabBar(
      controller: controller,
      isScrollable: widget.scrollable || widget.tabBarGutter != null,
      tabAlignment: widget.scrollable || widget.tabBarGutter != null
          ? TabAlignment.start
          : (widget.centered ? TabAlignment.center : null),
      labelColor: colors.brand,
      unselectedLabelColor: colors.textSecondary,
      labelStyle: TextStyle(
        fontSize: labelFontSize,
        fontWeight: park.typography.weightMedium,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: labelFontSize,
        fontWeight: park.typography.weightRegular,
      ),
      indicatorColor: widget.indicatorColor ?? (isCard ? Colors.transparent : colors.brand),
      indicatorWeight: widget.indicatorHeight ?? (isCard ? 0 : 2.0),
      indicatorSize: widget.indicatorWidth != null
          ? TabBarIndicatorSize.tab
          : TabBarIndicatorSize.label,
      indicatorPadding: widget.indicatorPadding ?? EdgeInsets.zero,
      indicator: isCard
          ? BoxDecoration(
              color: colors.brand.withValues(alpha: 0.1),
              borderRadius: park.radius.brSm,
            )
          : null,
      dividerColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.brand.withValues(alpha: 0.05);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.brand.withValues(alpha: 0.03);
        }
        return Colors.transparent;
      }),
      tabs: tabWidgets,
    );

    final barDecoration = widget.tabBarStyle ??
        (isCard
            ? BoxDecoration(
                color: colors.surface, borderRadius: park.radius.brMd)
            : BoxDecoration(
                color: colors.surface,
                border: Border(
                  bottom: BorderSide(color: colors.divider, width: 0.5),
                ),
              ));

    if (!widget.keyboard) {
      tabBar = Focus(descendantsAreFocusable: false, child: tabBar);
    }

    Widget bar = Container(
      decoration: barDecoration,
      child: _effectiveExtra != null
          ? Row(
              children: [
                Expanded(child: tabBar),
                Padding(
                  padding: EdgeInsets.only(right: park.spacing.sm),
                  child: _effectiveExtra!,
                ),
              ],
            )
          : tabBar,
    );

    return bar;
  }

  /// 垂直 TabBar（left / right）
  Widget _buildVerticalTabBar(ParkThemeData park, TabController controller) {
    final colors = park.colors;

    final tabs = widget.tabs.asMap().entries.map((e) {
      return _buildVerticalTabItem(e.value, e.key, park, controller);
    }).toList();

    Widget tabBar = Container(
      width: 160,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: widget.tabPosition == ParkTabPosition.left
              ? BorderSide(color: colors.divider, width: 0.5)
              : BorderSide.none,
          left: widget.tabPosition == ParkTabPosition.right
              ? BorderSide(color: colors.divider, width: 0.5)
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._insertGutters(tabs),
          if (_effectiveShowAddButton)
            Semantics(
              button: true,
              label: 'Add tab',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _effectiveOnTabAdd,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: park.spacing.md,
                    vertical: park.spacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 18, color: colors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          if (_effectiveExtra != null)
            Padding(
              padding: EdgeInsets.all(park.spacing.sm),
              child: _effectiveExtra!,
            ),
        ],
      ),
    );

    return tabBar;
  }

  /// 垂直布局中的单个 Tab 项
  Widget _buildVerticalTabItem(
    ParkTab tab,
    int index,
    ParkThemeData park,
    TabController controller,
  ) {
    final colors = park.colors;
    final isSelected = controller.index == index;
    final indicator = _resolvedIndicatorType;
    final isCard = indicator == ParkTabIndicatorType.card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.animateTo(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.md,
          vertical: park.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isCard && isSelected
              ? colors.brand.withValues(alpha: 0.1)
              : Colors.transparent,
          border: !isCard && isSelected
              ? Border(
                  left: widget.tabPosition == ParkTabPosition.left
                      ? BorderSide(color: colors.brand, width: 2)
                      : BorderSide.none,
                  right: widget.tabPosition == ParkTabPosition.right
                      ? BorderSide(color: colors.brand, width: 2)
                      : BorderSide.none,
                )
              : null,
        ),
        child: Row(
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 18,
                  color: isSelected ? colors.brand : colors.textSecondary),
              SizedBox(width: park.spacing.xs),
            ],
            Expanded(
              child: Text(
                tab.label,
                style: TextStyle(
                  color: isSelected ? colors.brand : colors.textSecondary,
                  fontSize: park.typography.sizeBody,
                  fontWeight: isSelected
                      ? park.typography.weightMedium
                      : park.typography.weightRegular,
                ),
              ),
            ),
            if (tab.badge != null) ...[
              SizedBox(width: park.spacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: park.radius.brFull,
                ),
                child: Text(
                  tab.badge!,
                  style: TextStyle(
                    color: colors.textOnBrand,
                    fontSize: park.typography.sizeOverline,
                    fontWeight: park.typography.weightMedium,
                    height: 1.2,
                  ),
                ),
              ),
            ],
            if (_effectiveEditable && index < widget.tabs.length - 1)
              _buildCloseButton(index, park),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(ParkTab tab, int index, ParkThemeData park) {
    final hasIcon = tab.icon != null;
    final hasBadge = tab.badge != null;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIcon) ...[
            Icon(tab.icon, size: 18),
            SizedBox(width: park.spacing.xs),
          ],
          Text(tab.label),
          if (hasBadge) ...[
            SizedBox(width: park.spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: park.colors.error,
                borderRadius: park.radius.brFull,
              ),
              child: Text(
                tab.badge!,
                style: TextStyle(
                  color: park.colors.textOnBrand,
                  fontSize: park.typography.sizeOverline,
                  fontWeight: park.typography.weightMedium,
                  height: 1.2,
                ),
              ),
            ),
          ],
          if (_effectiveEditable && index < widget.tabs.length - 1)
            _buildCloseButton(index, park),
        ],
      ),
    );
  }

  /// 在列表项之间插入间距 Widget（用于垂直布局的 gutter 支持）
  List<Widget> _insertGutters(List<Widget> items) {
    if (widget.tabBarGutter == null || widget.tabBarGutter! <= 0) {
      return items;
    }
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(height: widget.tabBarGutter));
      }
    }
    return result;
  }

  Widget _buildCloseButton(int index, ParkThemeData park) {
    return Semantics(
      button: true,
      label: ParkLocalizations.of(context).closeText,
      child: Padding(
        padding: EdgeInsets.only(left: park.spacing.xs),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _effectiveOnTabClose?.call(index),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              Icons.close,
              size: 16,
              color: park.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
