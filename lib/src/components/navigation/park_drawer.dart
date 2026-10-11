import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../l10n/park_localizations.dart';
import '../base/park_surface.dart';

/// Park 抽屉位置（向后兼容）
enum ParkDrawerPosition {
  /// 左侧
  left,

  /// 右侧
  right,
}

/// Park 抽屉弹出方向
///
/// 支持四个方向：左、右、上、下。
/// 顶/底抽屉垂直滑入。
enum ParkDrawerPlacement {
  /// 左侧
  left,

  /// 右侧
  right,

  /// 顶部
  top,

  /// 底部
  bottom,
}

/// Park 抽屉预设尺寸
///
/// 左/右方向控制宽度，上/下方向控制高度。
enum ParkDrawerSize {
  /// 小尺寸（256px）
  small,

  /// 中尺寸（378px，默认）
  medium,

  /// 大尺寸（520px）
  large,
}

/// Drawer 表面材质的派生结果。
@immutable
class ParkDrawerSurface {
  final Color fill;
  final BorderRadius radius;
  final List<BoxShadow>? shadows;
  final Color bodyColor;
  final bool useBlur;
  final double blurSigma;

  /// null 保留 Flutter Drawer 原生 elevation；0 表示由令牌阴影接管。
  final double? materialElevation;

  const ParkDrawerSurface({
    required this.fill,
    required this.radius,
    required this.shadows,
    required this.bodyColor,
    required this.useBlur,
    required this.blurSigma,
    required this.materialElevation,
  });
}

List<BoxShadow> _drawerVerticalShadow(
  ParkThemeData park,
  ParkDrawerPlacement placement,
) {
  return <BoxShadow>[
    BoxShadow(
      color: park.colors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: placement == ParkDrawerPlacement.top
          ? const Offset(0, 4)
          : const Offset(0, -4),
    ),
  ];
}

/// 解析 Drawer 表面。组件没有显式 fullscreen 模式，因此尺寸恰好贴满视口时
/// 仍保留既有 Drawer 圆角/阴影语义，避免把响应式尺寸误判为全屏而破坏 stripe。
@visibleForTesting
ParkDrawerSurface resolveParkDrawerSurface({
  required BuildContext context,
  required ParkThemeData park,
  required ParkDrawerPlacement placement,
  required bool fullscreen,
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  final bool horizontal = placement == ParkDrawerPlacement.left ||
      placement == ParkDrawerPlacement.right;
  var radius = switch (placement) {
    ParkDrawerPlacement.left => BorderRadius.only(
        topRight: Radius.circular(park.radius.lg),
        bottomRight: Radius.circular(park.radius.lg),
      ),
    ParkDrawerPlacement.right => BorderRadius.only(
        topLeft: Radius.circular(park.radius.lg),
        bottomLeft: Radius.circular(park.radius.lg),
      ),
    ParkDrawerPlacement.top => BorderRadius.only(
        bottomLeft: Radius.circular(park.radius.lg),
        bottomRight: Radius.circular(park.radius.lg),
      ),
    ParkDrawerPlacement.bottom => BorderRadius.only(
        topLeft: Radius.circular(park.radius.lg),
        topRight: Radius.circular(park.radius.lg),
      ),
  };

  // 全屏形态走独立分支：抽屉 extent 覆盖整屏时不再需要单边圆角，
  // 否则会与屏幕边缘出现可见缝隙。这是浮层规范第 5 条（全屏形态独立分支）。
  if (fullscreen) {
    radius = BorderRadius.zero;
  }

  return ParkDrawerSurface(
    fill: tokens.fill,
    radius: radius,
    // 水平 Drawer 的 stripe / flat floor 是 Flutter 原生 elevation，无法用
    // BoxShadow 无损复刻；tokens 非空时才关闭原生阴影并由令牌接管。
    shadows: horizontal
        ? tokens.shadows
        : ParkSurfaceTokens.overlayShadows(
            tokens: tokens,
            floor: _drawerVerticalShadow(park, placement),
          ),
    bodyColor: tokens.bodyColor,
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
    materialElevation: horizontal && tokens.shadows == null ? null : 0,
  );
}

/// Park 抽屉
///
/// 主题化的抽屉组件，支持 header / footer 区域，可配置四个方向弹出，
/// 支持关闭按钮、键盘 Escape 关闭、加载态、预设尺寸等功能。
///
/// 可直接嵌入 [Scaffold.drawer] / [Scaffold.endDrawer]，也可作为独立面板使用。
///
/// ```dart
/// Scaffold(
///   drawer: ParkDrawer(
///     header: UserAccountsDrawerHeader(...),
///     child: ListView(
///       children: [
///         ListTile(title: Text('菜单项 1')),
///         ListTile(title: Text('菜单项 2')),
///       ],
///     ),
///     footer: Padding(
///       padding: EdgeInsets.all(16),
///       child: Text('v1.0.0'),
///     ),
///   ),
/// )
/// ```
class ParkDrawer extends StatefulWidget {
  /// 主体内容
  final Widget? child;

  /// 顶部区域（用户头像、名称等）
  final Widget? header;

  /// 底部区域（版本号、退出按钮等）
  final Widget? footer;

  /// 抽屉宽度（左/右方向时）或高度（上/下方向时）
  ///
  /// 当设置了 [size] 且 [width] 仍为默认值时，[size] 优先生效。
  final double width;

  /// 抽屉宽度占屏宽的比例（0.1 ~ 1.0，即 10% ~ 100%）。
  ///
  /// 移动端屏宽碎片化（320~430+），固定像素宽度在窄屏变全屏、宽屏又显窄，
  /// 使用百分比可自适应。设置后优先于 [width] / [size]；默认 null 保持
  /// 原有固定像素行为，完全向后兼容。
  ///
  /// ```dart
  /// ParkDrawer(widthFactor: 2 / 3) // 抽屉宽度 = 屏宽 × 2/3
  /// ```
  final double? widthFactor;

  /// 弹出位置（向后兼容，当 [placement] 非 null 时被覆盖）
  final ParkDrawerPosition position;

  /// 弹出方向（优先于 [position]）
  final ParkDrawerPlacement? placement;

  /// 是否显示关闭按钮
  final bool closable;

  /// 是否允许按 Escape 键关闭抽屉
  final bool keyboard;

  /// 头部右侧额外操作区域
  final Widget? extra;

  /// 是否显示加载骨架屏
  final bool loading;

  /// 关闭时是否卸载内容
  final bool destroyOnClose;

  /// 预设尺寸
  final ParkDrawerSize size;

  /// 是否可见（受控模式）。为 null 时组件内部管理可见状态。
  final bool? visible;

  /// 关闭回调（点击关闭按钮或按 Escape 时触发）
  final VoidCallback? onClose;

  /// 是否显示遮罩层（默认 true）
  final bool mask;

  /// 点击遮罩是否关闭抽屉（默认 true）
  final bool maskClosable;

  /// 遮罩层颜色（默认半透明黑色）
  final Color? maskColor;

  /// 层级（z-index），用于控制多个抽屉叠加时的显示顺序
  final int zIndex;

  /// 关闭动画完成后的回调
  final VoidCallback? afterClose;

  /// 打开回调（抽屉打开动画完成后触发）
  final VoidCallback? onOpen;

  /// 指定抽屉挂载的容器（默认挂载到当前 Scaffold）
  final Widget? getContainer;

  const ParkDrawer({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.width = 280,
    this.widthFactor,
    this.position = ParkDrawerPosition.left,
    this.placement,
    this.closable = true,
    this.keyboard = true,
    this.extra,
    this.loading = false,
    this.destroyOnClose = false,
    this.size = ParkDrawerSize.medium,
    this.visible,
    this.onClose,
    this.mask = true,
    this.maskClosable = true,
    this.maskColor,
    this.zIndex = 1000,
    this.afterClose,
    this.onOpen,
    this.getContainer,
  });

  /// 通过 Overlay 展示抽屉，支持多级嵌套（使用 [rootOverlay: true]）。
  ///
  /// 返回 [OverlayEntry]，调用方可随时移除以关闭抽屉。
  static OverlayEntry show(
    BuildContext context, {
    required Widget child,
    Widget? header,
    Widget? footer,
    Widget? extra,
    ParkDrawerPlacement? placement,
    ParkDrawerPosition position = ParkDrawerPosition.left,
    double width = 280,
    double? widthFactor,
    bool closable = true,
    bool keyboard = true,
    bool loading = false,
    bool destroyOnClose = false,
    ParkDrawerSize size = ParkDrawerSize.medium,
    bool mask = true,
    bool maskClosable = true,
    Color? maskColor,
    VoidCallback? onClose,
    VoidCallback? afterClose,
    VoidCallback? onOpen,
    int zIndex = 1000,
    Widget? getContainer,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) {
      return ParkDrawer(
        header: header,
        footer: footer,
        extra: extra,
        placement: placement,
        position: position,
        width: width,
        widthFactor: widthFactor,
        closable: closable,
        keyboard: keyboard,
        loading: loading,
        destroyOnClose: destroyOnClose,
        size: size,
        mask: mask,
        maskClosable: maskClosable,
        maskColor: maskColor,
        onClose: () {
          onClose?.call();
          entry.remove();
        },
        afterClose: afterClose,
        onOpen: onOpen,
        zIndex: zIndex,
        getContainer: getContainer,
        child: child,
      );
    });
    overlay.insert(entry);
    return entry;
  }

  @override
  State<ParkDrawer> createState() => _ParkDrawerState();
}

class _ParkDrawerState extends State<ParkDrawer> {
  late bool _internalVisible;
  bool _contentMounted = true;
  final FocusNode _focusNode = FocusNode();
  Timer? _afterCloseTimer;

  /// 解析实际弹出方向
  ParkDrawerPlacement get _effectivePlacement {
    if (widget.placement != null) return widget.placement!;
    return widget.position == ParkDrawerPosition.right
        ? ParkDrawerPlacement.right
        : ParkDrawerPlacement.left;
  }

  bool get _isHorizontal =>
      _effectivePlacement == ParkDrawerPlacement.left ||
      _effectivePlacement == ParkDrawerPlacement.right;

  /// 解析尺寸
  double get _resolvedSize {
    // widthFactor（屏宽比例）优先：水平方向取屏宽比例，垂直方向取屏高比例。
    final double? factor = widget.widthFactor;
    if (factor != null) {
      final double clamped = factor.clamp(0.1, 1.0);
      final double screenExtent = _isHorizontal
          ? MediaQuery.sizeOf(context).width
          : MediaQuery.sizeOf(context).height;
      return screenExtent * clamped;
    }
    // 如果用户显式传了非默认 width，优先使用
    if (widget.width != 280) return widget.width;
    switch (widget.size) {
      case ParkDrawerSize.small:
        return 256;
      case ParkDrawerSize.medium:
        return 378;
      case ParkDrawerSize.large:
        return 520;
    }
  }

  bool get _isVisible => widget.visible ?? _internalVisible;

  @override
  void initState() {
    super.initState();
    _internalVisible = widget.visible ?? true;
    _contentMounted = true;
    // 首次打开时触发回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isVisible) widget.onOpen?.call();
    });
  }

  @override
  void didUpdateWidget(covariant ParkDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasVisible = _isVisible;
    if (widget.visible != null) {
      _internalVisible = widget.visible!;
    }
    // destroyOnClose：当关闭时卸载内容
    if (widget.destroyOnClose && !_isVisible) {
      _contentMounted = false;
    } else if (_isVisible) {
      _contentMounted = true;
    }
    // visible 从关闭→打开时触发回调
    if (!wasVisible && _isVisible) {
      widget.onOpen?.call();
    }
  }

  @override
  void dispose() {
    // afterClose 补偿：show() 模式下 onClose 会同步 entry.remove() →
    // 本 State 在 300ms 定时器触发前就被销毁，若只 cancel 会让 afterClose
    // 永不回调。销毁时若存在未触发的 afterClose 定时器，取消并立即补偿触发
    // （组件已关闭并销毁，语义上"关闭后"即此刻）。
    final Timer? pending = _afterCloseTimer;
    _afterCloseTimer = null;
    if (pending != null) {
      pending.cancel();
      widget.afterClose?.call();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClose() {
    widget.onClose?.call();
    // mounted check: show() 通过 onClose 移除 OverlayEntry 后 widget 可能已 dispose
    if (widget.visible == null && mounted) {
      setState(() {
        _internalVisible = false;
        if (widget.destroyOnClose) {
          _contentMounted = false;
        }
      });
    }
    // afterClose: 关闭动画完成后回调（延迟到动画结束）
    _afterCloseTimer?.cancel();
    _afterCloseTimer = Timer(const Duration(milliseconds: 300), () {
      _afterCloseTimer = null;
      if (mounted) {
        widget.afterClose?.call();
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!widget.keyboard) return;
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _handleClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;

    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    final resolvedSize = _resolvedSize;
    final Size viewport = MediaQuery.sizeOf(context);
    final double viewportExtent =
        _isHorizontal ? viewport.width : viewport.height;
    final double effectiveExtent =
        resolvedSize.clamp(0.0, viewportExtent).toDouble();
    final bool fullscreen = effectiveExtent >= viewportExtent;
    final ParkDrawerSurface surface = resolveParkDrawerSurface(
      context: context,
      park: park,
      placement: _effectivePlacement,
      fullscreen: fullscreen,
    );

    // 键盘事件监听包裹
    Widget content = _buildDrawerContent(park, colors, surface);

    // Overlay 环境无 Material → 子内容（含用户传入的 child/header/footer）
    // 会继承 fallback DefaultTextStyle（红色 48px + 黄色下划线），
    // 必须包一层透明 Material 提供标准文本样式环境。
    content = Material(
      type: MaterialType.transparency,
      child: content,
    );

    if (widget.keyboard) {
      content = KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: content,
      );
    }

    Widget result;
    if (_isHorizontal) {
      Widget drawerContent = SizedBox(width: effectiveExtent, child: content);

      // 按方向对齐：right → 右侧，left → 左侧（Stack 默认 topStart 会把
      // 右抽屉渲染到左侧，必须显式 Align）。
      drawerContent = Align(
        alignment: _effectivePlacement == ParkDrawerPlacement.right
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: drawerContent,
      );

      if (widget.mask) {
        result = Stack(
          // key 必须唯一：同屏左右两个抽屉（默认 zIndex 相同）会导致
          // "Duplicate keys found" 崩溃，加入方向区分。
          key: ValueKey('dr_stack_${widget.zIndex}_${_effectivePlacement}'),
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.maskClosable ? _handleClose : null,
                child: Container(
                  color: widget.maskColor ?? park.colors.overlay,
                ),
              ),
            ),
            drawerContent,
          ],
        );
      } else {
        result = drawerContent;
      }
    } else {
      Widget drawerContent =
          SizedBox(height: effectiveExtent, child: content);

      // 按方向对齐：bottom → 底部，top → 顶部
      drawerContent = Align(
        alignment: _effectivePlacement == ParkDrawerPlacement.bottom
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        child: drawerContent,
      );

      if (widget.mask) {
        result = Stack(
          key: ValueKey('dr_stack_${widget.zIndex}_${_effectivePlacement}'),
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.maskClosable ? _handleClose : null,
                child: Container(
                  color: widget.maskColor ?? park.colors.overlay,
                ),
              ),
            ),
            drawerContent,
          ],
        );
      } else {
        result = drawerContent;
      }
    }

    // getContainer: 指定自定义容器，用于限定 Drawer 渲染区域
    if (widget.getContainer != null) {
      result = Stack(
        children: [
          widget.getContainer!,
          Positioned.fill(child: result),
        ],
      );
    }

    return result;
  }

  Widget _buildDrawerContent(
    ParkThemeData park,
    ParkColors colors,
    ParkDrawerSurface surface,
  ) {
    final l10n = ParkLocalizations.of(context);
    Widget panel;

    if (!_isHorizontal) {
      panel = Semantics(
        container: true,
        label: l10n.navigationDrawerLabel,
        child: _buildVerticalDrawer(park, colors, surface),
      );
    } else {
      panel = Semantics(
        container: true,
        label: l10n.navigationDrawerLabel,
        child: Drawer(
          shape: RoundedRectangleBorder(borderRadius: surface.radius),
          elevation: surface.materialElevation,
          // 遮罩由 ParkDrawer 自绘（maskColor ?? park.colors.overlay）。
          backgroundColor: surface.fill,
          child: _buildInnerContent(park, colors, surface),
        ),
      );
    }

    // glass 只允许最外层采样；全屏分支已在解析器中关闭模糊。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      panel = ClipRRect(
        borderRadius: surface.radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: surface.blurSigma,
            sigmaY: surface.blurSigma,
          ),
          child: panel,
        ),
      );
    }

    if (surface.shadows != null) {
      panel = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: surface.radius,
          boxShadow: surface.shadows,
        ),
        child: panel,
      );
    }
    return panel;
  }

  Widget _buildVerticalDrawer(
    ParkThemeData park,
    ParkColors colors,
    ParkDrawerSurface surface,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surface.fill,
        borderRadius: surface.radius,
      ),
      child: _buildInnerContent(park, colors, surface),
    );
  }

  Widget _buildInnerContent(
    ParkThemeData park,
    ParkColors colors,
    ParkDrawerSurface surface,
  ) {
    return Column(
      children: [
        // Header
        if (widget.header != null || widget.closable || widget.extra != null)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.brandLight.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: colors.divider, width: 0.5),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: _buildHeader(park, surface),
            ),
          ),

        // Body
        Expanded(
          child: widget.loading
              ? _buildLoadingPlaceholder(park, colors)
              : (_contentMounted
                  ? (widget.child ?? const SizedBox.shrink())
                  : const SizedBox.shrink()),
        ),

        // Footer
        if (widget.footer != null)
          Semantics(
            container: true,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.divider, width: 0.5),
                ),
              ),
              child: SafeArea(top: false, child: widget.footer!),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(
    ParkThemeData park,
    ParkDrawerSurface surface,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: park.spacing.md,
        vertical: park.spacing.sm,
      ),
      child: Row(
        children: [
          // Header 内容（占主要空间）
          if (widget.header != null) Expanded(child: widget.header!),

          // Extra actions
          if (widget.extra != null) ...[
            SizedBox(width: park.spacing.sm),
            widget.extra!,
          ],

          // Close button
          if (widget.closable) ...[
            SizedBox(width: park.spacing.sm),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleClose,
              child: Semantics(
                button: true,
                label: ParkLocalizations.of(context).closeText,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: surface.bodyColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ParkThemeData park, ParkColors colors) {
    return Padding(
      padding: EdgeInsets.all(park.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: park.spacing.md),
            child: Container(
              height: i == 0 ? 24 : 16,
              width: i == 0
                  ? double.infinity
                  : (i.isEven ? 180.0 : 140.0),
              decoration: BoxDecoration(
                color: colors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(park.radius.sm),
              ),
            ),
          );
        }),
      ),
    );
  }
}
