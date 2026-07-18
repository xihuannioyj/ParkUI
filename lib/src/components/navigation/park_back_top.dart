import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// Park 回到顶部按钮
///
/// 监听滚动偏移，当滚动距离超过阈值时自动显示，
/// 带有淡入 + 缩放的过渡动画。点击后平滑滚动至顶部。
///
/// ```dart
/// final controller = ScrollController();
///
/// Stack(
///   children: [
///     ListView.builder(
///       controller: controller,
///       itemCount: 100,
///       itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
///     ),
///     ParkBackTop(scrollController: controller),
///   ],
/// )
/// ```
class ParkBackTop extends StatefulWidget {
  /// 监听的滚动控制器
  final ScrollController scrollController;

  /// 触发显示的滚动偏移量（默认 300）
  final double visibleOffset;

  /// 自定义点击回调（为空时自动滚动到顶部）
  final VoidCallback? onPressed;

  /// 自定义图标（默认向上箭头）
  final IconData? icon;

  /// 按钮尺寸
  final double size;

  /// 距右下角的偏移
  final EdgeInsetsGeometry margin;

  /// 触发按钮显示的最小滚动距离（像素）。
  ///
  /// 为 null 时使用 [visibleOffset]（默认 300）。
  /// 推荐设置为 400。
  final double? visibilityHeight;

  /// 自定义目标滚动控制器。
  ///
  /// 为 null 时使用 [scrollController]。
  /// 当需要监听外部 ScrollController 时使用。
  final ScrollController? target;

  const ParkBackTop({
    super.key,
    required this.scrollController,
    this.visibleOffset = 300,
    this.onPressed,
    this.icon,
    this.size = 44,
    this.margin = const EdgeInsets.only(right: 16, bottom: 16),
    this.visibilityHeight,
    this.target,
  });

  @override
  State<ParkBackTop> createState() => _ParkBackTopState();
}

class _ParkBackTopState extends State<ParkBackTop>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  bool _visible = false;

  ScrollController get _effectiveController =>
      widget.target ?? widget.scrollController;

  double get _effectiveThreshold =>
      widget.visibilityHeight ?? widget.visibleOffset;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _effectiveController.addListener(_onScroll);
    // 初始检测
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant ParkBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.target ?? oldWidget.scrollController;
    if (oldController != _effectiveController) {
      oldController.removeListener(_onScroll);
      _effectiveController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onScroll);
    _animController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_effectiveController.hasClients) {
      if (_visible) {
        setState(() => _visible = false);
        _animController.reverse();
      }
      return;
    }

    final shouldShow =
        _effectiveController.offset >= _effectiveThreshold;
    if (shouldShow != _visible) {
      if (!mounted) return;
      setState(() => _visible = shouldShow);
      if (shouldShow) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  void _handlePress() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }
    if (!_effectiveController.hasClients) return;

    _effectiveController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final colors = park.colors;

    if (!_effectiveController.hasClients) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        if (_animController.isDismissed) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: widget.margin,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Semantics(
                  button: true,
                  label: l10n.backTop,
                  child: Tooltip(
                    message: l10n.backTop,
                    child: GestureDetector(
                      onTap: _handlePress,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          color: colors.brand,
                          shape: BoxShape.circle,
                          boxShadow: park.shadows.md,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          widget.icon ?? Icons.keyboard_arrow_up,
                          size: widget.size * 0.55,
                          color: colors.textOnBrand,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
