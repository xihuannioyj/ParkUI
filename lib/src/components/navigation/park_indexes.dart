import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 字母索引条
///
/// 在列表右侧显示垂直字母条，支持点击与拖拽跳转到对应分组。
/// 常用于通讯录、城市选择等按字母分组的列表场景。
///
/// ```dart
/// ParkIndexes(
///   indexes: ['A', 'B', 'C', 'D', 'E', 'F'],
///   onIndexSelected: (index) {
///     scrollController.jumpTo(offsets[index]);
///   },
/// )
/// ```
class ParkIndexes extends StatefulWidget {
  /// 索引字母列表（如 ['A','B','C'...] 或 ['#','A','B'...]）
  final List<String> indexes;

  /// 选中某个索引时的回调（传入索引字符串）
  final ValueChanged<String>? onIndexSelected;

  /// 激活状态颜色（默认品牌色）
  final Color? activeColor;

  /// 字母文字大小
  final double fontSize;

  /// 字母间距
  final double itemHeight;

  /// 是否显示中央浮层提示（选中时在屏幕中央显示大字）
  final bool showOverlay;

  /// 当前分组标题是否吸附到顶部。
  ///
  /// 为 true 时滚动到对应分组时标题停留在顶部直到被下一组顶掉。
  /// 此参数由外部滚动容器配合 SliverAppBar 或 StickyHeader 消费。
  final bool sticky;

  /// 当前激活索引变更时的回调。
  ///
  /// 与 [onIndexSelected] 的区别在于：
  /// [onIndexSelected] 仅在用户主动点击 / 拖拽字母条时触发，
  /// 而 [onChange] / [onChanged] 在激活索引发生任何变化时都会触发（包括程序性变化）。
  @Deprecated('Use onChanged instead')
  final ValueChanged<String>? onChange;

  /// 当前激活索引变更时的回调。
  ///
  /// 与 [onIndexSelected] 的区别在于：
  /// [onIndexSelected] 仅在用户主动点击 / 拖拽字母条时触发，
  /// 而 [onChanged] 在激活索引发生任何变化时都会触发（包括程序性变化）。
  final ValueChanged<String>? onChanged;

  /// 内部使用的有效回调：优先使用 onChanged，回退到 onChange。
  ValueChanged<String>? get _effectiveOnChanged => onChanged ?? onChange;

  /// 外部控制的当前高亮索引
  final String? currentIndex;

  /// 用于滚动同步高亮的 ScrollController。
  ///
  /// 外部列表滚动时通过此 controller 同步更新 [currentIndex]。
  final ScrollController? anchorScrollController;

  const ParkIndexes({
    super.key,
    required this.indexes,
    this.onIndexSelected,
    this.activeColor,
    this.fontSize = 11,
    this.itemHeight = 18,
    this.showOverlay = true,
    this.sticky = true,
    // ignore: deprecated_member_use_from_same_package
    this.onChange,
    this.onChanged,
    this.currentIndex,
    this.anchorScrollController,
  });

  @override
  State<ParkIndexes> createState() => _ParkIndexesState();
}

class _ParkIndexesState extends State<ParkIndexes> {
  String? _activeIndex;
  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;
  Timer? _activeResetTimer;

  /// 解析实际高亮的索引：外部 currentIndex 优先于内部 activeIndex
  String? get _effectiveActiveIndex => widget.currentIndex ?? _activeIndex;

  @override
  void initState() {
    super.initState();
    widget.anchorScrollController?.addListener(_onAnchorScroll);
  }

  @override
  void didUpdateWidget(covariant ParkIndexes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部 currentIndex 变化时同步
    if (widget.currentIndex != null &&
        widget.currentIndex != oldWidget.currentIndex) {
      _activeIndex = widget.currentIndex;
    }
    // anchorScrollController 变化时更新监听
    if (widget.anchorScrollController != oldWidget.anchorScrollController) {
      oldWidget.anchorScrollController?.removeListener(_onAnchorScroll);
      widget.anchorScrollController?.addListener(_onAnchorScroll);
    }
  }

  void _onAnchorScroll() {
    // 外部通过 currentIndex 控制高亮时，didUpdateWidget 会自动同步 _activeIndex，
    // 无需在此触发 setState 重建。仅同步内部状态即可。
    if (widget.currentIndex == null) {
      _activeIndex = null;
    }
  }

  void _onSelect(String index) {
    // 原实现与内部 _activeIndex 比较后早退：外部受控（currentIndex）时内部值
    // 可能 stale，导致"有效高亮是 A、点 A 却早退不回调"的反直觉行为；
    // 重复点击同一字母也被吞（列表内容变化后无法"重跳"）。
    // 修正：回调始终放行（由调用方决定是否忽略），仅浮层避免重复重建。
    final bool changed = _effectiveActiveIndex != index;
    setState(() => _activeIndex = index);
    widget.onIndexSelected?.call(index);
    widget._effectiveOnChanged?.call(index);

    if (widget.showOverlay && changed) {
      _showOverlay(index);
    }
  }

  void _showOverlay(String index) {
    _removeOverlay();
    final entry = OverlayEntry(
      builder: (context) {
        final park =
            Theme.of(context).extension<ParkThemeData>() ??
            ParkThemeData.light();
        return IgnorePointer(
          child: Center(
            child: Semantics(
              label: index,
              container: true,
              child: Container(
                key: const ValueKey<String>('park-indexes-overlay'),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: park.colors.brand.withValues(alpha: 0.85),
                  borderRadius: park.radius.brMd,
                ),
                alignment: Alignment.center,
                child: Text(
                  index,
                  style: TextStyle(
                    color: park.colors.textOnBrand,
                    fontSize: park.typography.sizeH1,
                    fontWeight: park.typography.weightBold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
    _overlayTimer?.cancel();

    // 自动隐藏
    _overlayTimer = Timer(const Duration(milliseconds: 600), () {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayTimer?.cancel();
    _overlayTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final index = _yToIndex(localOffset.dy);
    if (index != null) {
      _onSelect(index);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _activeResetTimer?.cancel();
    _activeResetTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _activeIndex = null);
    });
  }

  /// 根据可用高度计算实际行高。
  ///
  /// 当索引总高度（indexes.length * itemHeight）超出可用高度时，
  /// 等比压缩行高，保证整个索引条完整显示在可用区域内，避免
  /// "RenderFlex overflowed ... on the bottom" 的底部溢出报错。
  double _effectiveItemHeight(double availableHeight) {
    final double pref = widget.itemHeight > 0 ? widget.itemHeight : 18.0;
    final int count = widget.indexes.length;
    if (count > 0 &&
        availableHeight.isFinite &&
        availableHeight > 0 &&
        pref * count > availableHeight) {
      return availableHeight / count;
    }
    return pref;
  }

  String? _yToIndex(double y) {
    if (widget.indexes.isEmpty) return null;

    // 用实际渲染高度反推行高，与 build 中的自适应行高保持一致，
    // 避免行高被压缩后拖拽映射错位。
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final double availH = box?.size.height ?? 0;
    final double itemH = _effectiveItemHeight(availH);

    final int idx = (y / itemH).floor().clamp(0, widget.indexes.length - 1);
    return widget.indexes[idx];
  }

  @override
  void dispose() {
    _activeResetTimer?.cancel();
    _activeResetTimer = null;
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final actColor = widget.activeColor ?? colors.brand;
    final inactColor = colors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 高度自适应：索引总高度超过可用高度时等比压缩 itemHeight，
        // 避免索引过多（如公寓的楼层索引）导致底部 RenderFlex 溢出。
        final double itemH = _effectiveItemHeight(constraints.maxHeight);
        final double prefItemH = widget.itemHeight > 0
            ? widget.itemHeight
            : 18.0;
        final double scale = prefItemH > 0 ? itemH / prefItemH : 1.0;
        // 字号随行高等比缩放，保底可读字号，同时不超过行高以免文字被裁剪
        final double baseFont = math.min(
          math.max(widget.fontSize * scale, 8.0),
          math.max(itemH - 2.0, 8.0),
        );
        final double activeFont = baseFont + 2 <= itemH
            ? baseFont + 2
            : baseFont;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (DragStartDetails details) {
            final RenderBox? box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final Offset localOffset = box.globalToLocal(
              details.globalPosition,
            );
            final index = _yToIndex(localOffset.dy);
            if (index != null) {
              _onSelect(index);
            }
          },
          onVerticalDragUpdate: (details) =>
              _onDragUpdate(details, constraints),
          onVerticalDragEnd: _onDragEnd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.indexes.map((index) {
              final isActive = index == _effectiveActiveIndex;
              return Semantics(
                label: index,
                button: true,
                selected: isActive,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onSelect(index),
                  child: SizedBox(
                    height: itemH,
                    width: itemH + 8,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          color: isActive ? actColor : inactColor,
                          fontSize: isActive ? activeFont : baseFont,
                          fontWeight: isActive
                              ? park.typography.weightBold
                              : park.typography.weightMedium,
                          height: 1.0,
                        ),
                        child: Text(index),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
