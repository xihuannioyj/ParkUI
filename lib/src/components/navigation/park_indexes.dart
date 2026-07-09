import 'dart:async';

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
  /// 而 [onChange] 在激活索引发生任何变化时都会触发（包括程序性变化）。
  final ValueChanged<String>? onChange;

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
    this.onChange,
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
  void didUpdateWidget(covariant ParkIndexes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部 currentIndex 变化时同步
    if (widget.currentIndex != null &&
        widget.currentIndex != oldWidget.currentIndex) {
      _activeIndex = widget.currentIndex;
    }
  }

  void _onSelect(String index) {
    if (_activeIndex == index) return;
    setState(() => _activeIndex = index);
    widget.onIndexSelected?.call(index);
    widget.onChange?.call(index);

    if (widget.showOverlay) {
      _showOverlay(index);
    }
  }

  void _showOverlay(String index) {
    _removeOverlay();
    final entry = OverlayEntry(
      builder: (context) {
        final park = Theme.of(context).extension<ParkThemeData>() ??
            ParkThemeData.light();
        return IgnorePointer(
          child: Center(
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
                  fontSize: 28,
                  fontWeight: park.typography.weightBold,
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

  String? _yToIndex(double y) {
    if (widget.indexes.isEmpty) return null;

    final itemH = widget.itemHeight;
    final idx = (y / itemH).floor().clamp(0, widget.indexes.length - 1);
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
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final actColor = widget.activeColor ?? colors.brand;
    final inactColor = colors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (DragStartDetails details) {
            final RenderBox? box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final Offset localOffset = box.globalToLocal(details.globalPosition);
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
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onSelect(index),
                child: SizedBox(
                  height: widget.itemHeight,
                  width: widget.itemHeight + 8,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        color: isActive ? actColor : inactColor,
                        fontSize: isActive
                            ? widget.fontSize + 2
                            : widget.fontSize,
                        fontWeight: isActive
                            ? park.typography.weightBold
                            : park.typography.weightMedium,
                        height: 1.0,
                      ),
                      child: Text(index),
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
