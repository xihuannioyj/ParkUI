import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 粘性定位组件。
///
/// 纯自定义实现，当滚动到指定偏移量时，子组件将"粘"在顶部。
/// 基于 [NotificationListener<ScrollNotification>] 监听滚动事件，
/// 通过 [CustomSingleChildLayout] 实现吸顶效果。
///
/// ```dart
/// SingleChildScrollView(
///   child: Column(
///     children: [
///       ParkSticky(
///         stickyOffset: 0,
///         child: Container(
///           color: Colors.white,
///           child: Text('吸顶标题'),
///         ),
///       ),
///       // ... 其他内容
///     ],
///   ),
/// )
/// ```
class ParkSticky extends StatefulWidget {
  /// 粘性子组件。
  final Widget child;

  /// 吸顶时距离顶部的偏移量（像素）。
  final double stickyOffset;

  /// 是否在吸顶时显示阴影。
  final bool showShadow;

  /// 背景色（吸顶时生效）。
  final Color? backgroundColor;

  /// 吸顶状态变化回调。
  final ValueChanged<bool>? onStickyChanged;

  /// 创建粘性定位组件。
  const ParkSticky({
    super.key,
    required this.child,
    this.stickyOffset = 0,
    this.showShadow = true,
    this.backgroundColor,
    this.onStickyChanged,
  });

  @override
  State<ParkSticky> createState() => _ParkStickyState();
}

class _ParkStickyState extends State<ParkSticky> {
  /// 当前是否处于吸顶状态。
  bool _isSticky = false;

  /// 子组件的全局键，用于获取其位置。
  final GlobalKey _childKey = GlobalKey();

  /// 子组件在滚动容器中的原始 Y 偏移。
  double _childOriginalY = 0;

  /// 当前滚动偏移。
  double _scrollOffset = 0;

  /// 有效吸顶偏移：优先使用 stickyOffset，为 0 时回退到 offset。
  double get _effectiveOffset => widget.stickyOffset;

  @override
  void initState() {
    super.initState();
    // 延迟一帧获取子组件位置。
    WidgetsBinding.instance.addPostFrameCallback(_measureChildPosition);
  }

  /// 测量子组件在滚动容器中的原始位置。
  void _measureChildPosition(_) {
    if (!mounted) return;
    final RenderBox? box =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    // 获取子组件相对于滚动视口的位置。
    final double dy = box.localToGlobal(Offset.zero).dy;
    setState(() {
      _childOriginalY = dy + _scrollOffset - _effectiveOffset;
    });
  }

  /// 处理滚动通知。
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      final double newOffset = notification.metrics.pixels;
      setState(() {
        _scrollOffset = newOffset;
        final bool shouldBeSticky =
            _scrollOffset >= _childOriginalY - _effectiveOffset;
        if (shouldBeSticky != _isSticky) {
          _isSticky = shouldBeSticky;
          // 统一通知：优先 onStickyChanged，同时兼容 onChange。
          widget.onStickyChanged?.call(_isSticky);
        }
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final Color bgColor = widget.backgroundColor ?? park.colors.surface;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 占位区域（始终保留原始空间）。
          if (_isSticky)
            SizedBox(
              height: _getChildHeight(),
            ),

          // 粘性/非粘性子组件。
          AnimatedContainer(
            key: _childKey,
            duration: const Duration(milliseconds: 150),
            decoration: _isSticky && widget.showShadow
                ? BoxDecoration(
                    color: bgColor,
                    boxShadow: park.shadows.sm,
                  )
                : _isSticky
                    ? BoxDecoration(color: bgColor)
                    : null,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  /// 获取子组件高度（用于吸顶时占位）。
  double _getChildHeight() {
    final RenderBox? box =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size.height ?? 0;
  }
}
