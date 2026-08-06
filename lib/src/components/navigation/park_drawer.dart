import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../l10n/park_localizations.dart';

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
    _afterCloseTimer?.cancel();
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

    // 键盘事件监听包裹
    Widget content = _buildDrawerContent(park, colors);

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
      final maxWidth = MediaQuery.sizeOf(context).width;
      final effectiveWidth = resolvedSize.clamp(0.0, maxWidth).toDouble();
      Widget drawerContent = SizedBox(width: effectiveWidth, child: content);

      if (widget.mask) {
        result = Stack(
          key: ValueKey('dr_stack_${widget.zIndex}'),
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
      final maxHeight = MediaQuery.sizeOf(context).height;
      final effectiveHeight = resolvedSize.clamp(0.0, maxHeight).toDouble();
      Widget drawerContent =
          SizedBox(height: effectiveHeight, child: content);

      if (widget.mask) {
        result = Stack(
          key: ValueKey('dr_stack_${widget.zIndex}'),
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

  Widget _buildDrawerContent(ParkThemeData park, ParkColors colors) {
    final placement = _effectivePlacement;

    final l10n = ParkLocalizations.of(context);

    // 顶/底方向使用自定义容器
    if (!_isHorizontal) {
      return Semantics(
        container: true,
        label: l10n.navigationDrawerLabel,
        child: _buildVerticalDrawer(park, colors),
      );
    }

    // 左/右方向使用 Flutter Drawer
    return Semantics(
      container: true,
      label: l10n.navigationDrawerLabel,
      child: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: placement == ParkDrawerPlacement.left
              ? BorderRadius.only(
                  topRight: Radius.circular(park.radius.lg),
                  bottomRight: Radius.circular(park.radius.lg),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(park.radius.lg),
                  bottomLeft: Radius.circular(park.radius.lg),
                ),
        ),
        backgroundColor: colors.surface,
        child: _buildInnerContent(park, colors),
      ),
    );
  }

  Widget _buildVerticalDrawer(ParkThemeData park, ParkColors colors) {
    final placement = _effectivePlacement;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: placement == ParkDrawerPlacement.top
            ? BorderRadius.only(
                bottomLeft: Radius.circular(park.radius.lg),
                bottomRight: Radius.circular(park.radius.lg),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(park.radius.lg),
                topRight: Radius.circular(park.radius.lg),
              ),
        boxShadow: [
          BoxShadow(
            color: park.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: placement == ParkDrawerPlacement.top
                ? const Offset(0, 4)
                : const Offset(0, -4),
          ),
        ],
      ),
      child: _buildInnerContent(park, colors),
    );
  }

  Widget _buildInnerContent(ParkThemeData park, ParkColors colors) {
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
              child: _buildHeader(park, colors),
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

  Widget _buildHeader(ParkThemeData park, ParkColors colors) {
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
                    color: colors.textSecondary,
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
