import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_button.dart';
import '../base/park_button_style.dart';
import '../base/park_surface.dart';

/// 气泡确认框组件
///
/// 在目标元素附近弹出确认对话框，用于需要用户二次确认的操作。
/// 基于 [ParkPopover] 和 [ParkButton] 组合实现。
///
/// ```dart
/// ParkPopconfirm(
///   title: '确认删除？',
///   description: '删除后将无法恢复，请确认操作。',
///   onConfirm: () => print('已确认'),
///   child: ParkButton(text: '删除'),
/// )
/// ```
class ParkPopconfirm extends StatefulWidget {
  /// 确认框标题。
  final String? title;

  /// 确认框描述文字。
  final String? description;

  /// 自定义标题 widget（优先于 [title]）。
  final Widget? titleWidget;

  /// 自定义描述 widget（优先于 [description]）。
  final Widget? descriptionWidget;

  /// 确认按钮文字（默认 '确定'）。
  final String confirmText;

  /// 取消按钮文字（默认 '取消'）。
  final String cancelText;

  /// 确认回调。
  final VoidCallback? onConfirm;

  /// 取消回调。
  final VoidCallback? onCancel;

  /// 确认后是否自动关闭（默认 true）。
  final bool autoCloseAfterConfirm;

  /// 提示图标（默认 null）。
  final IconData? icon;

  /// 触发元素。
  final Widget child;

  /// 是否为危险操作（确认按钮变红色）（默认 false）。
  final bool danger;

  /// 确认按钮 loading 状态。
  final bool confirmLoading;

  /// 创建 [ParkPopconfirm]。
  const ParkPopconfirm({
    super.key,
    this.title,
    this.description,
    this.titleWidget,
    this.descriptionWidget,
    this.confirmText = '',
    this.cancelText = '',
    this.onConfirm,
    this.onCancel,
    this.autoCloseAfterConfirm = true,
    this.icon,
    required this.child,
    this.danger = false,
    this.confirmLoading = false,
  });

  @override
  State<ParkPopconfirm> createState() => _ParkPopconfirmState();
}

/// 气泡确认框表面材质的派生结果。
///
/// 与 [ParkPopoverSurface] 同构：把容器填充、圆角、阴影与文字色收敛到
/// **一个**派生结果里，避免"容器改了、文字没改"的半迁移状态。
@immutable
class ParkPopconfirmSurface {
  /// 气泡容器的填充色。
  final Color fill;

  /// 圆角（保留组件原值 `ParkRadius.lg`，不消费 `tokens.radius`）。
  final BorderRadius radius;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 是否需要背景模糊采样（glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  /// 标题文字色 —— **必须**来自表面令牌。
  final Color titleColor;

  /// 描述文字色 —— **必须**来自表面令牌。
  final Color bodyColor;

  const ParkPopconfirmSurface({
    required this.fill,
    required this.radius,
    required this.shadows,
    required this.useBlur,
    required this.blurSigma,
    required this.titleColor,
    required this.bodyColor,
  });
}

/// 气泡确认框改造前的浮层阴影（浮层兜底 floor）。
///
/// 组件原本用的是一条**自定义**阴影（overlay 10% / blur 16 / offset 0,8），
/// 并非 `park.shadows.lg`。按浮层规范第 1 条，stripe / flat 风格下
/// `tokens.shadows` 为 null，必须回落到这条原值，否则气泡会凭空换一套阴影
/// （非零回归）。
///
/// 私有而非公开：它是"改造前的字面量"，一旦公开就会被误当成可配置项，
/// 而它的正确性恰恰依赖于**不再被改动**。测试里用同样的字面量断言，
/// 两边同时漂移时才会被发现（见 test/feedback/park_popconfirm_surface_test.dart）。
List<BoxShadow> _popconfirmShadowFloor(ParkThemeData park) {
  return <BoxShadow>[
    BoxShadow(
      color: park.colors.overlay.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

/// 解析气泡确认框的表面材质（浮层规范在 Popconfirm 上的实现）。
///
/// 五条浮层规范：
/// 1. 阴影 `tokens.shadows ?? floor`（[_popconfirmShadowFloor]）——
///    风格接管优先，浮层原值兜底；
/// 2. 圆角保留组件原值 `BorderRadius.circular(park.radius.lg)`，
///    **不**消费 `tokens.radius`（那是卡片语义 brMd）；
/// 3. 无描边（组件原本就没有边框语义，故 `bordered: false`）；
/// 4. 文字色一律取 `tokens.titleColor` / `tokens.bodyColor`；
/// 5. 本组件无全屏 / 特殊形态，故没有独立分支。
///
/// ⚠️ `danger` 与 `confirmLoading` **不参与**派生：`danger` 只改确认按钮的
/// 语义色（error / brand 图标 + danger 变体按钮），`confirmLoading` 只改按钮
/// 转圈，二者都不应影响容器材质。
///
/// 抽成顶层函数（而非私有方法）是为了让单元测试能直接断言"标题 / 描述文字色
/// 与容器 fill 的对比度"。
@visibleForTesting
ParkPopconfirmSurface resolveParkPopconfirmSurface({
  required ParkThemeData park,
  required BuildContext context,
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    // 确认气泡没有描边语义（原实现无 border）。
    bordered: false,
  );

  return ParkPopconfirmSurface(
    fill: tokens.fill,
    radius: BorderRadius.circular(park.radius.lg),
    shadows: ParkSurfaceTokens.overlayShadows(
      tokens: tokens,
      floor: _popconfirmShadowFloor(park),
    ),
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
    // 🔴 标题 / 描述**都**必须来自 tokens：neon + 深色底下 fill 翻转为近白，
    // 若沿用 colors.textPrimary / textSecondary 会撞成 1.00:1（白底白字）。
    titleColor: tokens.titleColor,
    bodyColor: tokens.bodyColor,
  );
}

class _ParkPopconfirmState extends State<ParkPopconfirm>
    with SingleTickerProviderStateMixin {
  final _triggerKey = GlobalKey();
  final _bubbleKey = GlobalKey();
  bool _isVisible = false;
  OverlayEntry? _overlayEntry;
  double _bubbleTop = 0;
  double _bubbleLeft = 0;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  bool _isHiding = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  void _showPopconfirm() {
    if (_isVisible) return;

    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    // 边界防御：trigger 首帧未布局/无尺寸时直接 return 会把 _isVisible 留在 true，
    // 之后所有点击被 `if (_isVisible) return` 吞掉 → 弹窗永远无法再打开。
    if (renderBox == null || !renderBox.hasSize) return;
    _isVisible = true;

    final overlay = Overlay.of(context);
    final childPosition = renderBox.localToGlobal(Offset.zero);
    final childSize = renderBox.size;
    final viewport = MediaQuery.of(context).size;

    // Default position: below the trigger, aligned left
    _bubbleTop = childPosition.dy + childSize.height + 8;
    _bubbleLeft = childPosition.dx;

    _overlayEntry = OverlayEntry(
      builder: (_) => FadeTransition(
        opacity: _fadeAnim,
        child: _buildPopover(childPosition, childSize),
      ),
    );

    overlay.insert(_overlayEntry!);
    _animController.value = 1.0;

    // Adjust position after first layout to prevent viewport overflow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) {
        _adjustBubbleBounds(childPosition, childSize, viewport);
      }
    });
  }

  /// Checks whether the bubble overflows the viewport and adjusts position.
  ///
  /// Uses [_bubbleKey] to measure the actual rendered size of the bubble,
  /// then flips vertically or clamps horizontally as needed.
  void _adjustBubbleBounds(
      Offset childPosition, Size childSize, Size viewport) {
    final bubbleBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (bubbleBox == null || !bubbleBox.hasSize) return;

    final bubbleSize = bubbleBox.size;
    bool needsRebuild = false;

    // Vertical: flip above trigger if overflowing bottom
    final defaultTop = childPosition.dy + childSize.height + 8;
    if (defaultTop + bubbleSize.height > viewport.height) {
      final flippedTop = childPosition.dy - 8 - bubbleSize.height;
      _bubbleTop = flippedTop >= 0 ? flippedTop : 4.0;
      needsRebuild = true;
    }

    // Horizontal: clamp to prevent right overflow
    if (_bubbleLeft + bubbleSize.width > viewport.width) {
      _bubbleLeft = viewport.width - bubbleSize.width - 8;
      needsRebuild = true;
    }
    // Prevent left overflow
    if (_bubbleLeft < 0) {
      _bubbleLeft = 4.0;
      needsRebuild = true;
    }

    if (needsRebuild) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _hidePopconfirm() {
    if (!_isVisible || _isHiding) return;
    _isHiding = true;
    _animController.reverse().then((_) {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
      _isVisible = false;
      _isHiding = false;
    });
  }

  void _cleanupPopconfirm() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
    }
    _overlayEntry = null;
    _isVisible = false;
  }

  void _handleConfirm() {
    if (widget.autoCloseAfterConfirm) _hidePopconfirm();
    widget.onConfirm?.call();
  }

  void _handleCancel() {
    _hidePopconfirm();
    widget.onCancel?.call();
  }

  Widget _buildPopover(Offset childPosition, Size childSize) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final confirmLabel =
        widget.confirmText.isNotEmpty ? widget.confirmText : l10n.confirmText;
    final cancelLabel =
        widget.cancelText.isNotEmpty ? widget.cancelText : l10n.cancelText;

    // 表面材质走派生层：局部 ParkSurfaceStyleScope 覆盖自动生效。
    final ParkPopconfirmSurface surface = resolveParkPopconfirmSurface(
      park: park,
      context: context,
    );

    Widget bubble = Material(
      key: _bubbleKey,
      color: Colors.transparent,
      child: Semantics(
        label: widget.title ?? '',
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: EdgeInsets.all(park.spacing.base),
          decoration: BoxDecoration(
            color: surface.fill,
            borderRadius: surface.radius,
            boxShadow: surface.shadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题区域
              if (widget.titleWidget != null || widget.title != null)
                Padding(
                  padding: EdgeInsets.only(bottom: park.spacing.sm),
                  child: widget.titleWidget ??
                      Row(
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon,
                                size: 18,
                                color: widget.danger
                                    ? park.colors.error
                                    : park.colors.brand),
                            park.spacing.hSm,
                          ],
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: TextStyle(
                                fontSize: park.typography.sizeBody,
                                fontWeight: FontWeight.w600,
                                // 标题色来自表面令牌（防 neon 白底白字）。
                                color: surface.titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                ),
              // 描述区域
              if (widget.descriptionWidget != null ||
                  widget.description != null)
                Padding(
                  padding: EdgeInsets.only(bottom: park.spacing.base),
                  child: widget.descriptionWidget ??
                      Text(
                        widget.description!,
                        style: TextStyle(
                          fontSize: park.typography.sizeCaption,
                          // 描述色来自表面令牌（与 titleColor 成对处理）。
                          color: surface.bodyColor,
                        ),
                      ),
                ),
              // 按钮区域
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    label: cancelLabel,
                    button: true,
                    child: ParkButton(
                      child: Text(cancelLabel),
                      variant: ParkButtonVariant.secondary,
                      size: ParkButtonSize.small,
                      onPressed: _handleCancel,
                    ),
                  ),
                  SizedBox(width: park.spacing.sm),
                  Semantics(
                    label: confirmLabel,
                    button: true,
                    child: ParkButton(
                      child: Text(confirmLabel),
                      variant: widget.danger
                          ? ParkButtonVariant.danger
                          : ParkButtonVariant.primary,
                      size: ParkButtonSize.small,
                      loading: widget.confirmLoading,
                      onPressed: _handleConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // glass 风格：叠加 BackdropFilter 采样背后内容。
    //
    // 复用 ParkSurfaceBlurDepth 做嵌套降级，避免重复采样同一 backdrop。
    // 判定必须是 `< 1` 而非 `<= 1`（见 ParkSurface.canBlur 的说明）。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      bubble = ClipRRect(
        borderRadius: surface.radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: surface.blurSigma,
            sigmaY: surface.blurSigma,
          ),
          child: bubble,
        ),
      );
    }

    return Stack(
      children: [
        // 遮罩层
        Positioned.fill(
          child: GestureDetector(
            onTap: _handleCancel,
            child: Container(color: Colors.transparent),
          ),
        ),
        // 气泡
        Positioned(
          top: _bubbleTop,
          left: _bubbleLeft,
          child: bubble,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cleanupPopconfirm();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _triggerKey,
      onTap: _showPopconfirm,
      child: widget.child,
    );
  }
}
