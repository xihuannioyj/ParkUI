import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

// =============================================================================
// ParkTourPlacement — 气泡弹出方向
// =============================================================================

/// ParkTour 气泡相对于目标元素的弹出方向。
enum ParkTourPlacement {
  /// 显示在目标正中央（target 为 null 时默认使用此值）
  center,

  /// 上、下、左、右四个基本方向
  top,
  bottom,
  left,
  right,

  /// 上左、上右、下左、下右（气泡角对齐目标角）
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,

  /// 左上下、右上下（气泡侧边对齐目标侧边）
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
}

// =============================================================================
// ParkTourStep — 单步引导数据
// =============================================================================

/// ParkTour 的一步引导步骤数据。
class ParkTourStep {
  /// 要高亮的目标组件（[GlobalKey] 定位）。
  ///
  /// 为 `null` 时气泡居中显示（放置于 placement=center 模式）。
  final GlobalKey? target;

  /// 步骤标题。
  final String title;

  /// 步骤描述/正文。
  final String description;

  /// 气泡弹出方向。
  ///
  /// 默认跟随 Tour 的全局 placement，或根据自动判断的可用空间调整。
  final ParkTourPlacement? placement;

  /// 可选的插图/封面 Widget（如图片）。
  final Widget? cover;

  /// 是否显示箭头（默认 true，跟随 Tour 全局 arrow）。
  final bool? arrow;

  /// 是否启用此步的遮罩（默认 true，跟随 Tour 全局 mask）。
  final bool? mask;

  /// 高亮区域与目标元素之间的间距（px）。
  ///
  /// 控制高亮矩形在目标周围外扩的距离。单值 = 四周相同，
  /// 也可通过 `EdgeInsets` 精细控制。
  final EdgeInsets? gap;

  /// 高亮区域的圆角半径（px）。`null` 使用默认值 8。
  final double? borderRadius;

  /// 创建一步引导数据。
  const ParkTourStep({
    this.target,
    required this.title,
    required this.description,
    this.placement,
    this.cover,
    this.arrow,
    this.mask,
    this.gap,
    this.borderRadius,
  });
}

// =============================================================================
// ParkTour — 新手指引/功能引导组件
// =============================================================================

/// ParkTour — 新手指引/功能引导组件（对标 antd Tour）。
///
/// 通过 `Overlay` + `CustomPainter` 在页面上方绘制半透明遮罩，
/// 在目标 Widget 位置掏空矩形区域让用户聚焦，同时在该区域旁
/// 弹出气泡卡片显示引导信息。
///
/// ## 核心能力
///
/// - **步骤序列**：`List<ParkTourStep>`，每步指定 target、标题、描述和位置
/// - **遮罩+高亮**：在 target 周围掏空矩形，支持自定义圆角和外扩间距
/// - **弹出气泡**：高亮区域旁气泡卡片，显示标题、描述、可选封面图
/// - **导航控件**：上一步/下一步/跳过/完成按钮 + 步数指示器
/// - **箭头指示**：气泡朝目标方向绘制三角箭头
/// - **滚动自动跟随**：切换步骤时若目标不可见自动 `Scrollable.ensureVisible`
/// - **受控/非受控**：`current` + `onChanged` 受控，或内部维护状态
/// - **关闭逻辑**：点击遮罩关闭 / 最后一步点「完成」关闭
///
/// ## 基础用法
///
/// ```dart
/// ParkTour(
///   open: _tourVisible,
///   steps: [
///     ParkTourStep(
///       target: _step1Key,
///       title: '第一步',
///       description: '这是第一步引导说明',
///       placement: ParkTourPlacement.bottom,
///     ),
///     ParkTourStep(
///       target: _step2Key,
///       title: '第二步',
///       description: '这是第二步引导说明',
///     ),
///   ],
///   onClose: () => setState(() => _tourVisible = false),
///   onFinish: () => setState(() => _tourVisible = false),
/// )
/// ```
class ParkTour extends StatefulWidget {
  /// 引导步骤列表。
  final List<ParkTourStep> steps;

  /// 是否打开引导。
  final bool open;

  /// 当前步骤索引（受控模式）。
  ///
  /// 提供此参数时 Tour 为受控模式，由父组件管理 current。
  /// 不提供时内部维护 current 状态。
  final int? current;

  /// 步骤切换回调（受控模式）。
  ///
  /// 当用户点击上一步/下一步时触发，携带切换后的步骤索引。
  /// 仅在受控模式下有意义。
  @Deprecated('Use onChanged instead')
  final ValueChanged<int>? onChange;

  /// 步骤切换回调（受控模式）。
  ///
  /// 当用户点击上一步/下一步时触发，携带切换后的步骤索引。
  /// 仅在受控模式下有意义。
  final ValueChanged<int>? onChanged;

  /// 内部使用的有效回调：优先使用 onChanged，回退到 onChange。
  ValueChanged<int>? get _effectiveOnChanged => onChanged ?? onChange;

  /// 关闭引导回调（点击遮罩、跳过或按 Esc 时触发）。
  final VoidCallback? onClose;

  /// 完成引导回调（最后一步点击「完成」时触发）。
  final VoidCallback? onFinish;

  /// 是否启用遮罩（默认 true）。
  final bool mask;

  /// 是否显示箭头（默认 true）。可被单步的 arrow 覆盖。
  final bool arrow;

  /// 点击遮罩是否关闭引导（默认 true）。
  final bool closeOnMaskTap;

  /// 是否启用键盘快捷键（Esc 关闭，默认 true）。
  final bool keyboard;

  /// 上一步按钮文字。
  final String? prevButtonText;

  /// 下一步按钮文字。
  final String? nextButtonText;

  /// 跳过按钮文字。
  final String? skipButtonText;

  /// 完成按钮文字。
  final String? doneButtonText;

  /// 自定义步数指示器构建器。
  ///
  /// 接收当前步索引（从 0 开始）和总步数，返回自定义指示器 Widget。
  /// 不提供时使用默认 "第 X / Y 步" 格式。
  final Widget Function(int current, int total)? stepIndicatorBuilder;

  /// 高亮区域与目标元素之间的间距（px），默认 [6, 6]。
  ///
  /// 控制高亮矩形在目标周围外扩的距离。
  final EdgeInsets gap;

  /// 高亮区域的圆角半径（px），默认 8。
  final double highlightRadius;

  /// 遮罩颜色（默认使用主题 overlay 色）。
  final Color? maskColor;

  /// Tour 的 z-index 层级。
  final int zIndex;

  /// 创建 ParkTour 引导组件。
  const ParkTour({
    super.key,
    required this.steps,
    required this.open,
    this.current,
    // ignore: deprecated_member_use_from_same_package
    this.onChange,
    this.onChanged,
    this.onClose,
    this.onFinish,
    this.mask = true,
    this.arrow = true,
    this.closeOnMaskTap = true,
    this.keyboard = true,
    this.prevButtonText,
    this.nextButtonText,
    this.skipButtonText,
    this.doneButtonText,
    this.stepIndicatorBuilder,
    this.gap = const EdgeInsets.all(6),
    this.highlightRadius = 8,
    this.maskColor,
    this.zIndex = 1060,
  });

  @override
  State<ParkTour> createState() => _ParkTourState();
}

class _ParkTourState extends State<ParkTour> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  int _internalCurrent = 0;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  /// 获取当前步骤索引（受控优先）。
  int get _currentIndex => widget.current ?? _internalCurrent;

  bool get _isControlled => widget.current != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    // 受控模式 open=true 从初始即显示。
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showTour();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ParkTour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      if (widget.open) {
        _showTour();
      } else {
        _removeTour();
      }
    } else if (widget.open && _overlayEntry != null) {
      // Step index changed externally (controlled mode)
      if (_isControlled && widget.current != oldWidget.current) {
        _rebuildOverlay();
      }
    }
  }

  @override
  void dispose() {
    _cleanupTour();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ParkTour 是一个 overlay-based 组件，自身不渲染任何可见 Widget。
    // OverlayEntry 的构建在 _showTour / _buildOverlay 中。
    return const SizedBox.shrink();
  }

  // ---------------------------------------------------------------------------
  // Overlay 管理
  // ---------------------------------------------------------------------------

  void _showTour() {
    if (_overlayEntry != null) return;
    _internalCurrent = 0;
    _animController.value = 1.0;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeTour() {
    final entry = _overlayEntry;
    if (entry == null) return;
    _animController.reverse().then((_) {
      if (!mounted) { _cleanupTour(); return; }
      _cleanupTour();
    });
  }

  void _cleanupTour() {
    final entry = _overlayEntry;
    if (entry == null) return;
    if (entry.mounted) entry.remove();
    _overlayEntry = null;
  }

  void _rebuildOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  // ---------------------------------------------------------------------------
  // 导航逻辑
  // ---------------------------------------------------------------------------

  void _goTo(int index) {
    if (widget.steps.isEmpty) return;
    final clamped = index.clamp(0, widget.steps.length - 1);

    if (_isControlled) {
      widget._effectiveOnChanged?.call(clamped);
      // 受控模式下，父组件负责 setState 重建
    } else {
      setState(() {
        _internalCurrent = clamped;
      });
    }

    _scrollToTarget(widget.steps[clamped]);

    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _goNext() => _goTo(_currentIndex + 1);

  void _goPrev() => _goTo(_currentIndex - 1);

  void _close() {
    widget.onClose?.call();
    // 受控模式下父组件控制 open=false 触发移除
    _removeTour();
  }

  void _finish() {
    widget.onFinish?.call();
    _removeTour();
  }

  // ---------------------------------------------------------------------------
  // 滚动跟随
  // ---------------------------------------------------------------------------

  void _scrollToTarget(ParkTourStep step) {
    final key = step.target;
    if (key == null || key.currentContext == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Overlay 构建
  // ---------------------------------------------------------------------------

  Widget _buildOverlay(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    if (widget.steps.isEmpty || _currentIndex >= widget.steps.length) {
      return const SizedBox.shrink();
    }

    final step = widget.steps[_currentIndex];
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == widget.steps.length - 1;

    final prevText = widget.prevButtonText ?? l10n.previousStep;
    final nextText = widget.nextButtonText ?? l10n.nextStep;
    final doneText = widget.doneButtonText ?? l10n.doneText;
    final skipText = widget.skipButtonText ?? l10n.skipText;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Semantics(
        label: l10n.tourSemanticsLabel,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // === 遮罩层 ===
              if (widget.mask && step.mask != false)
                _ParkTourMask(
                  targetKey: step.target,
                  gap: step.gap ?? widget.gap,
                  borderRadius: step.borderRadius ?? widget.highlightRadius,
                  maskColor: widget.maskColor ?? park.colors.overlay,
                  onTap: widget.closeOnMaskTap ? _close : null,
                )
              else
                // 无遮罩时的拦截层
                if (widget.closeOnMaskTap)
                  GestureDetector(
                    onTap: _close,
                    child: const SizedBox.expand(),
                  ),

          // === 气泡 ===
          if (step.target != null)
            _ParkTourBubble(
              key: ValueKey('tour_bubble_$_currentIndex'),
              step: step,
              index: _currentIndex,
              total: widget.steps.length,
              park: park,
              l10n: l10n,
              isFirst: isFirst,
              isLast: isLast,
              prevText: prevText,
              nextText: nextText,
              doneText: doneText,
              skipText: skipText,
              showArrow: widget.arrow && (step.arrow ?? true),
              onPrev: _goPrev,
              onNext: _goNext,
              onClose: _close,
              onFinish: _finish,
              stepIndicatorBuilder: widget.stepIndicatorBuilder,
            )
          else
            // 居中的气泡（target == null）
            _ParkTourCenterBubble(
              step: step,
              index: _currentIndex,
              total: widget.steps.length,
              park: park,
              l10n: l10n,
              isFirst: isFirst,
              isLast: isLast,
              prevText: prevText,
              nextText: nextText,
              doneText: doneText,
              skipText: skipText,
              onPrev: _goPrev,
              onNext: _goNext,
              onClose: _close,
              onFinish: _finish,
              stepIndicatorBuilder: widget.stepIndicatorBuilder,
            ),
        ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _ParkTourMask — 半透明遮罩 + 高亮区域掏空
// =============================================================================

class _ParkTourMask extends StatelessWidget {
  final GlobalKey? targetKey;
  final EdgeInsets gap;
  final double borderRadius;
  final Color maskColor;
  final VoidCallback? onTap;

  const _ParkTourMask({
    this.targetKey,
    required this.gap,
    required this.borderRadius,
    required this.maskColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Positioned 必须是 Stack 的直接子级：将 GestureDetector 放在
    // Positioned.fill 内部，而不是把 Positioned 包在 GestureDetector 里。
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipPath(
          clipper: _TourMaskClipper(
            targetKey: targetKey,
            gap: gap,
            borderRadius: borderRadius,
          ),
          child: Container(color: maskColor),
        ),
      ),
    );
  }
}

/// 遮罩裁剪器 — 在全屏遮罩上掏空目标区域。
class _TourMaskClipper extends CustomClipper<Path> {
  final GlobalKey? targetKey;
  final EdgeInsets gap;
  final double borderRadius;

  _TourMaskClipper({
    required this.targetKey,
    required this.gap,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetKey?.currentContext == null) return path;

    final RenderBox? renderBox =
        targetKey!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || !renderBox.attached) {
      return path;
    }

    final offset = renderBox.localToGlobal(Offset.zero, ancestor: null);
    final targetRect = offset & renderBox.size;

    // 外扩间距
    final highlightRect = Rect.fromLTWH(
      targetRect.left - gap.left,
      targetRect.top - gap.top,
      targetRect.width + gap.left + gap.right,
      targetRect.height + gap.top + gap.bottom,
    );

    // 用圆角矩形掏空
    final rrect = RRect.fromRectAndRadius(
      highlightRect,
      Radius.circular(borderRadius),
    );

    path.addRRect(rrect);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant _TourMaskClipper oldDelegate) {
    return oldDelegate.targetKey != targetKey ||
        oldDelegate.gap != gap ||
        oldDelegate.borderRadius != borderRadius;
  }
}

// =============================================================================
// _ParkTourBubble — 锚定目标的气泡卡片
// =============================================================================

class _ParkTourBubble extends StatelessWidget {
  final ParkTourStep step;
  final int index;
  final int total;
  final ParkThemeData park;
  final ParkLocalizations l10n;
  final bool isFirst;
  final bool isLast;
  final String prevText;
  final String nextText;
  final String doneText;
  final String skipText;
  final bool showArrow;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onFinish;
  final Widget Function(int current, int total)? stepIndicatorBuilder;

  const _ParkTourBubble({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.park,
    required this.l10n,
    required this.isFirst,
    required this.isLast,
    required this.prevText,
    required this.nextText,
    required this.doneText,
    required this.skipText,
    required this.showArrow,
    required this.onPrev,
    required this.onNext,
    required this.onClose,
    required this.onFinish,
    this.stepIndicatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final placement = step.placement ?? ParkTourPlacement.bottom;
        final bubble = _buildBubble();

        // 当 placement 为 center 时居中显示
        if (placement == ParkTourPlacement.center) {
          return Center(child: bubble);
        }

        // 获取目标位置并定位气泡
        final key = step.target;
        if (key?.currentContext == null) {
          return Center(child: bubble);
        }

        final RenderBox? renderBox =
            key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.hasSize || !renderBox.attached) {
          return Center(child: bubble);
        }

        final offset = renderBox.localToGlobal(Offset.zero, ancestor: null);
        final targetRect = offset & renderBox.size;

        return _PositionedBubble(
          targetRect: targetRect,
          placement: placement,
          showArrow: showArrow,
          park: park,
          arrowSize: 8.0,
          offset: 12.0,
          bubble: bubble,
        );
      },
    );
  }

  Widget _buildBubble() {
    return _TourBubbleContent(
      step: step,
      index: index,
      total: total,
      park: park,
      l10n: l10n,
      isFirst: isFirst,
      isLast: isLast,
      prevText: prevText,
      nextText: nextText,
      doneText: doneText,
      skipText: skipText,
      onPrev: onPrev,
      onNext: onNext,
      onClose: onClose,
      onFinish: onFinish,
      stepIndicatorBuilder: stepIndicatorBuilder,
    );
  }
}

// =============================================================================
// _PositionedBubble — 根据目标位置和 placement 定位气泡
// =============================================================================

class _PositionedBubble extends StatelessWidget {
  final Rect targetRect;
  final ParkTourPlacement placement;
  final bool showArrow;
  final ParkThemeData park;
  final double arrowSize;
  final double offset;
  final Widget bubble;

  const _PositionedBubble({
    required this.targetRect,
    required this.placement,
    required this.showArrow,
    required this.park,
    required this.arrowSize,
    required this.offset,
    required this.bubble,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bubbleSize = _measureBubble(context);

    // 根据 placement 计算气泡位置
    final bubblePos = _calculatePosition(screenSize, bubbleSize);
    final arrowDir = _getArrowDirection();

    return Positioned(
      left: bubblePos.dx,
      top: bubblePos.dy,
      child: ConstrainedBox(
        // Positioned 未指定宽度时 child 约束为无界，必须限制在屏幕内，
        // 否则内部 Row/Column 会无限扩展导致 RenderFlex overflow。
        constraints: BoxConstraints(
          maxWidth: (screenSize.width - 16).clamp(0.0, double.infinity),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showArrow && _arrowOnTop(arrowDir))
              _buildArrow(arrowDir),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showArrow && _arrowOnRight(arrowDir))
                  _buildArrow(arrowDir),
                bubble,
                if (showArrow && _arrowOnLeft(arrowDir))
                  _buildArrow(arrowDir),
              ],
            ),
            if (showArrow && _arrowOnBottom(arrowDir))
              _buildArrow(arrowDir),
          ],
        ),
      ),
    );
  }

  Size _measureBubble(BuildContext context) {
    // 使用 RenderBox 获取气泡大小
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        return renderBox.size;
      }
    } catch (_) {
      // findRenderObject() 在 widget 未挂载时抛异常，使用 fallback 尺寸
    }
    // 估算大小
    return const Size(280, 200);
  }

  Offset _calculatePosition(Size screenSize, Size bubbleSize) {
    const gap = 12.0;
    final arrowH = showArrow ? arrowSize : 0.0;

    switch (placement) {
      case ParkTourPlacement.top:
      case ParkTourPlacement.topLeft:
      case ParkTourPlacement.topRight:
        return Offset(
          _centerX(bubbleSize.width) - bubbleSize.width / 2,
          targetRect.top - bubbleSize.height - gap - arrowH,
        )._clamp(screenSize, bubbleSize);
      case ParkTourPlacement.bottom:
      case ParkTourPlacement.bottomLeft:
      case ParkTourPlacement.bottomRight:
        return Offset(
          _centerX(bubbleSize.width) - bubbleSize.width / 2,
          targetRect.bottom + gap + arrowH,
        )._clamp(screenSize, bubbleSize);
      case ParkTourPlacement.left:
      case ParkTourPlacement.leftTop:
      case ParkTourPlacement.leftBottom:
        return Offset(
          targetRect.left - bubbleSize.width - gap - arrowH,
          _centerY(bubbleSize.height) - bubbleSize.height / 2,
        )._clamp(screenSize, bubbleSize);
      case ParkTourPlacement.right:
      case ParkTourPlacement.rightTop:
      case ParkTourPlacement.rightBottom:
        return Offset(
          targetRect.right + gap + arrowH,
          _centerY(bubbleSize.height) - bubbleSize.height / 2,
        )._clamp(screenSize, bubbleSize);
      case ParkTourPlacement.center:
        return Offset(
          (screenSize.width - bubbleSize.width) / 2,
          (screenSize.height - bubbleSize.height) / 2,
        );
    }
  }

  double _centerX(double bubbleW) {
    return targetRect.left + targetRect.width / 2;
  }

  double _centerY(double bubbleH) {
    return targetRect.top + targetRect.height / 2;
  }

  ParkTourPlacement _getArrowDirection() {
    switch (placement) {
      case ParkTourPlacement.top:
      case ParkTourPlacement.topLeft:
      case ParkTourPlacement.topRight:
        return ParkTourPlacement.bottom; // 箭头指向下
      case ParkTourPlacement.bottom:
      case ParkTourPlacement.bottomLeft:
      case ParkTourPlacement.bottomRight:
        return ParkTourPlacement.top;
      case ParkTourPlacement.left:
      case ParkTourPlacement.leftTop:
      case ParkTourPlacement.leftBottom:
        return ParkTourPlacement.right;
      case ParkTourPlacement.right:
      case ParkTourPlacement.rightTop:
      case ParkTourPlacement.rightBottom:
        return ParkTourPlacement.left;
      case ParkTourPlacement.center:
        return ParkTourPlacement.center;
    }
  }

  bool _arrowOnTop(ParkTourPlacement dir) =>
      dir == ParkTourPlacement.top;
  bool _arrowOnBottom(ParkTourPlacement dir) =>
      dir == ParkTourPlacement.bottom;
  bool _arrowOnLeft(ParkTourPlacement dir) =>
      dir == ParkTourPlacement.left;
  bool _arrowOnRight(ParkTourPlacement dir) =>
      dir == ParkTourPlacement.right;

  Widget _buildArrow(ParkTourPlacement direction) {
    return CustomPaint(
      size: direction == ParkTourPlacement.top ||
              direction == ParkTourPlacement.bottom
          ? Size(arrowSize * 2, arrowSize)
          : Size(arrowSize, arrowSize * 2),
      painter: _TourArrowPainter(
        color: park.colors.surface,
        direction: direction,
      ),
    );
  }
}

/// 为 Offset 添加 clamp 扩展方法，确保气泡在屏幕内。
extension _OffsetClamp on Offset {
  Offset _clamp(Size screenSize, Size bubbleSize) {
    final x = dx.clamp(8.0, screenSize.width - bubbleSize.width - 8.0);
    final y = dy.clamp(8.0, screenSize.height - bubbleSize.height - 8.0);
    return Offset(x, y);
  }
}

// =============================================================================
// _TourArrowPainter — 箭头绘制
// =============================================================================

class _TourArrowPainter extends CustomPainter {
  final Color color;
  final ParkTourPlacement direction;

  _TourArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (direction) {
      case ParkTourPlacement.top:
        // 箭头朝上（气泡在下）
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case ParkTourPlacement.bottom:
        // 箭头朝下（气泡在上）
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case ParkTourPlacement.left:
        // 箭头朝左（气泡在右）
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      case ParkTourPlacement.right:
        // 箭头朝右（气泡在左）
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
      default:
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TourArrowPainter oldDelegate) {
    return color != oldDelegate.color || direction != oldDelegate.direction;
  }
}

// =============================================================================
// _TourBubbleContent — 气泡卡片内容
// =============================================================================

class _TourBubbleContent extends StatelessWidget {
  final ParkTourStep step;
  final int index;
  final int total;
  final ParkThemeData park;
  final ParkLocalizations l10n;
  final bool isFirst;
  final bool isLast;
  final String prevText;
  final String nextText;
  final String doneText;
  final String skipText;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onFinish;
  final Widget Function(int current, int total)? stepIndicatorBuilder;

  const _TourBubbleContent({
    required this.step,
    required this.index,
    required this.total,
    required this.park,
    required this.l10n,
    required this.isFirst,
    required this.isLast,
    required this.prevText,
    required this.nextText,
    required this.doneText,
    required this.skipText,
    required this.onPrev,
    required this.onNext,
    required this.onClose,
    required this.onFinish,
    this.stepIndicatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.stepIndicatorFormat(index, total),
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: park.colors.surface,
          borderRadius: park.radius.brMd,
          boxShadow: park.shadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 封面图
            if (step.cover != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: step.cover!,
              ),

            // 标题 + 关闭按钮
            Padding(
              padding: EdgeInsets.fromLTRB(
                park.spacing.base,
                park.spacing.base,
                park.spacing.xs,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: park.typography.h3.copyWith(
                        color: park.colors.textPrimary,
                      ),
                    ),
                  ),
                  Semantics(
                    label: l10n.closeTourLabel,
                    child: InkWell(
                      borderRadius: park.radius.brFull,
                      onTap: onClose,
                      child: Padding(
                        padding: EdgeInsets.all(park.spacing.xs),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: park.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 描述
            Padding(
              padding: EdgeInsets.fromLTRB(
                park.spacing.base,
                park.spacing.sm,
                park.spacing.base,
                park.spacing.base,
              ),
              child: Text(
                step.description,
                style: park.typography.bodySmall.copyWith(
                  color: park.colors.textSecondary,
                ),
              ),
            ),

            // 底部操作栏
            Container(
              padding: EdgeInsets.fromLTRB(
                park.spacing.base,
                park.spacing.sm,
                park.spacing.sm,
                park.spacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: park.colors.divider),
                ),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: park.spacing.xs,
                runSpacing: park.spacing.xs,
                children: [
                  // 步数指示器
                  if (stepIndicatorBuilder != null)
                    stepIndicatorBuilder!(index, total)
                  else
                    Padding(
                      padding: EdgeInsets.only(right: park.spacing.xs),
                      child: Text(
                        l10n.stepIndicatorFormat(index, total),
                        style: park.typography.caption.copyWith(
                          color: park.colors.textPlaceholder,
                        ),
                      ),
                    ),

                  // 跳过按钮（非最后一步）
                  if (!isLast)
                    Semantics(
                      label: l10n.skipTourLabel,
                      child: TextButton(
                        onPressed: onClose,
                        style: TextButton.styleFrom(
                          foregroundColor: park.colors.textSecondary,
                          padding: EdgeInsets.symmetric(
                            horizontal: park.spacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          skipText,
                          style: park.typography.bodySmall,
                        ),
                      ),
                    ),

                  // 上一步按钮
                  if (!isFirst)
                    Semantics(
                      label: prevText,
                      child: TextButton(
                        onPressed: onPrev,
                        style: TextButton.styleFrom(
                          foregroundColor: park.colors.textPrimary,
                          padding: EdgeInsets.symmetric(
                            horizontal: park.spacing.sm,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          prevText,
                          style: park.typography.bodySmall,
                        ),
                      ),
                    ),

                  SizedBox(width: park.spacing.sm),

                  // 下一步 / 完成按钮
                  Semantics(
                    label: isLast ? doneText : nextText,
                    child: TextButton(
                      onPressed: isLast ? onFinish : onNext,
                      style: TextButton.styleFrom(
                        foregroundColor: park.colors.brand,
                        backgroundColor: park.colors.brandLight,
                        padding: EdgeInsets.symmetric(
                          horizontal: park.spacing.base,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: park.radius.brSm,
                        ),
                      ),
                      child: Text(
                        isLast ? doneText : nextText,
                        style: TextStyle(
                          fontSize: park.typography.sizeBodySmall,
                          fontWeight: park.typography.weightMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _ParkTourCenterBubble — 居中模式气泡（target == null）
// =============================================================================

class _ParkTourCenterBubble extends StatelessWidget {
  final ParkTourStep step;
  final int index;
  final int total;
  final ParkThemeData park;
  final ParkLocalizations l10n;
  final bool isFirst;
  final bool isLast;
  final String prevText;
  final String nextText;
  final String doneText;
  final String skipText;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onFinish;
  final Widget Function(int current, int total)? stepIndicatorBuilder;

  const _ParkTourCenterBubble({
    required this.step,
    required this.index,
    required this.total,
    required this.park,
    required this.l10n,
    required this.isFirst,
    required this.isLast,
    required this.prevText,
    required this.nextText,
    required this.doneText,
    required this.skipText,
    required this.onPrev,
    required this.onNext,
    required this.onClose,
    required this.onFinish,
    this.stepIndicatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _TourBubbleContent(
        step: step,
        index: index,
        total: total,
        park: park,
        l10n: l10n,
        isFirst: isFirst,
        isLast: isLast,
        prevText: prevText,
        nextText: nextText,
        doneText: doneText,
        skipText: skipText,
        onPrev: onPrev,
        onNext: onNext,
        onClose: onClose,
        onFinish: onFinish,
        stepIndicatorBuilder: stepIndicatorBuilder,
      ),
    );
  }
}
