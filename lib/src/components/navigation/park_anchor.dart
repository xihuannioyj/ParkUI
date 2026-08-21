import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// 锚点导航组件
///
/// 监听滚动位置，自动高亮当前区域对应的导航项。
/// 点击导航项平滑滚动到目标区域。
///
/// ```dart
/// ParkAnchor(
///   items: [
///     ParkAnchorItem(key: 'basic', label: '基础信息', sectionKey: _basicKey),
///     ParkAnchorItem(key: 'detail', label: '详细信息', sectionKey: _detailKey),
///     ParkAnchorItem(key: 'setting', label: '设置', sectionKey: _settingKey),
///   ],
///   scrollController: _scrollController,
/// )
/// ```
class ParkAnchor extends StatefulWidget {
  /// 锚点项列表。
  final List<ParkAnchorItem> items;

  /// 关联的滚动控制器。
  final ScrollController? scrollController;

  /// 选中项回调。
  final void Function(String key)? onChanged;

  /// 锚点偏移量（默认 80，考虑顶栏高度）。
  final double offset;

  /// 点击跳转时的额外滚动偏移量（默认 0），用于补偿 AppBar 等固定元素的高度。
  /// 与 [offset] 叠加使用。
  final double scrollOffset;

  /// 创建 [ParkAnchor]。
  const ParkAnchor({
    super.key,
    required this.items,
    this.scrollController,
    this.onChanged,
    this.offset = 80,
    this.scrollOffset = 0,
  });

  @override
  State<ParkAnchor> createState() => _ParkAnchorState();
}

class _ParkAnchorState extends State<ParkAnchor> {
  String? _activeKey;

  /// 缓存 section 的 RenderBox 引用，避免每次滚动都做 element 树遍历。
  final Map<String, RenderBox> _anchorRenderBoxCache = <String, RenderBox>{};

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _activeKey = widget.items.first.key;
    }
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ParkAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
    if (oldWidget.items != widget.items) {
      _anchorRenderBoxCache.clear();
      // items 变化后同步高亮：空列表 → null，否则默认第一项
      // （原实现只清缓存不重置 _activeKey，新列表首项永不自动选中）。
      final String? newActive =
          widget.items.isNotEmpty ? widget.items.first.key : null;
      if (newActive != _activeKey) {
        _activeKey = newActive;
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  /// 获取滚动视口在全局坐标系中的顶部 Y。
  double? _getViewportOriginY() {
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients) return null;
    final BuildContext? scrollCtx = sc.position.context.notificationContext;
    if (scrollCtx == null || !scrollCtx.mounted) return null;
    final RenderBox? box = scrollCtx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero).dy;
  }

  /// 滚动监听：根据当前滚动位置更新高亮项。
  void _onScroll() {
    if (!mounted || widget.scrollController == null) return;
    final sc = widget.scrollController!;
    if (!sc.hasClients || widget.items.isEmpty) return;

    // 正确的高亮阈值：section 顶部越过「视口全局顶部 + offset」即激活。
    // 原实现拿 section 的全局 Y 与 sc.offset（滚动内容偏移）比较，
    // 化简后等效于以 2× 滚动速度提前激活，高亮严重"抢跑"。
    final double? originY = _getViewportOriginY();
    if (originY == null) return;
    final double threshold = originY + widget.offset;

    // 从前往后查找：最后一个越过阈值的项为当前高亮（即视口内最靠下的已激活区域）
    String? active;
    for (final item in widget.items) {
      final sectionOffset = _getSectionOffset(item);
      if (sectionOffset != null && sectionOffset <= threshold) {
        active = item.key;
      }
    }
    // 无任何区域越过阈值（如滚动到最顶部）时保持当前高亮
    active ??= _activeKey;
    if (active != null && active != _activeKey) {
      if (!mounted) return;
      setState(() => _activeKey = active);
    }
  }

  /// 获取指定 item 对应 section 在全局坐标系中的顶部 Y。
  ///
  /// 优先使用 [ParkAnchorItem.sectionKey]（GlobalKey）定位——文档示例用法，
  /// 原实现只按 `Key(key)` 搜索元素树，用户只挂 GlobalKey 时恒 miss、
  /// 高亮永不更新；其次使用缓存的 RenderBox，最后回退 element 树遍历。
  double? _getSectionOffset(ParkAnchorItem item) {
    if (!mounted) return null;

    // 快速路径 1：sectionKey（GlobalKey）定位
    final GlobalKey? sectionKey = item.sectionKey;
    if (sectionKey != null && sectionKey.currentContext != null) {
      final RenderBox? renderBox =
          sectionKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.attached) {
        return renderBox.localToGlobal(Offset.zero).dy;
      }
    }

    // 快速路径 2：缓存的 RenderBox（O(1)，无需树遍历）
    final cachedBox = _anchorRenderBoxCache[item.key];
    if (cachedBox != null && cachedBox.attached) {
      return cachedBox.localToGlobal(Offset.zero).dy;
    }

    // 缓存未命中或已失效：执行 element 树遍历（按 Key(key) 匹配）
    final matchKey = Key(item.key);
    double? result;
    void visitor(Element element) {
      if (result != null) return;
      if (element.widget.key == matchKey) {
        final renderBox = element.renderObject as RenderBox?;
        if (renderBox != null && renderBox.attached) {
          // 缓存 RenderBox 引用供后续快速查找
          _anchorRenderBoxCache[item.key] = renderBox;
          result = renderBox.localToGlobal(Offset.zero).dy;
        }
        return;
      }
      element.visitChildElements(visitor);
    }
    context.visitChildElements(visitor);
    return result;
  }

  void _handleTap(String key) {
    final item = widget.items.firstWhere((i) => i.key == key);

    if (!mounted) return;
    setState(() => _activeKey = key);
    widget.onChanged?.call(key);

    if (item.sectionKey?.currentContext != null) {
      // 通过 sectionKey 的精确定位方式
      _scrollToSection(item.sectionKey!.currentContext!);
    } else if (widget.scrollController != null &&
        widget.scrollController!.hasClients) {
      // 回退方案：全局 Y 换算为目标滚动偏移（与 _scrollToSection 同一套坐标数学，
      // 原实现直接拿全局 Y 当滚动目标导致跳转位置错误）。
      final sectionOffset = _getSectionOffset(item);
      final originY = _getViewportOriginY();
      if (sectionOffset != null && originY != null) {
        final sc = widget.scrollController!;
        final targetOffset = sc.offset +
            (sectionOffset - originY) -
            widget.offset -
            widget.scrollOffset;
        sc.animateTo(
          targetOffset.clamp(0, sc.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// 通过 [BuildContext] 定位并滚动到目标 section。
  /// 使用 [Scrollable.of] 获取最近的 Scrollable，并基于 [RenderBox.localToGlobal]
  /// 精确计算目标元素在滚动内容中的位置，减去 [offset] + [scrollOffset] 补偿。
  void _scrollToSection(BuildContext sectionContext) {
    final renderBox = sectionContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final scrollable = Scrollable.of(sectionContext);
    final scrollableRenderBox = scrollable.context.findRenderObject() as RenderBox?;
    if (scrollableRenderBox == null) return;

    final relativeOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableRenderBox,
    ).dy;

    final totalOffset = widget.offset + widget.scrollOffset;
    final currentScroll = scrollable.position.pixels;
    // targetPosition = 目标元素在滚动内容中的自然位置
    // relativeOffset = targetPosition - currentScroll
    // desired = targetPosition - totalOffset = currentScroll + relativeOffset - totalOffset
    final targetPosition = currentScroll + relativeOffset - totalOffset;

    scrollable.position.animateTo(
      targetPosition.clamp(0.0, scrollable.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.items.map((item) {
        final isActive = item.key == _activeKey;
        return Semantics(
          button: true,
          selected: isActive,
          label: l10n.anchorLabel(item.label),
          header: true,
          child: GestureDetector(
            onTap: () => _handleTap(item.key),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: park.spacing.base, vertical: park.spacing.sm),
              decoration: BoxDecoration(
                border: isActive
                    ? Border(left: BorderSide(color: park.colors.brand, width: 3))
                    : null,
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: park.typography.sizeCaption,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? park.colors.brand : park.colors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 锚点项数据模型。
class ParkAnchorItem {
  /// 锚点键（与目标 widget 的 key 匹配）。
  final String key;

  /// 显示标签。
  final String label;

  /// 目标面板的 GlobalKey，用于点击时精确定位滚动。
  /// 不填时降级为通过 element 树查找或 scrollController 滚动。
  final GlobalKey? sectionKey;

  /// 创建 [ParkAnchorItem]。
  const ParkAnchorItem({
    required this.key,
    required this.label,
    this.sectionKey,
  });
}
