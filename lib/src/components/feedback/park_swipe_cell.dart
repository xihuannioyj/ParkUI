import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 滑动操作项数据模型
class ParkSwipeAction {
  final String label;
  final Widget? icon;

  /// 操作按钮背景色。若为 null 则使用主题色 [park.colors.textPrimary]。
  final Color? color;

  final VoidCallback? onTap;

  /// 确认模式下的按钮文字（默认使用 l10n.confirmText）
  final String? confirmText;

  const ParkSwipeAction({
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.confirmText,
  });
}

/// ParkSwipeCell — 滑动操作单元格，左右滑动揭示操作按钮。
class ParkSwipeCell extends StatefulWidget {
  final Widget child;
  final List<ParkSwipeAction>? leftActions;
  final List<ParkSwipeAction>? rightActions;

  /// 禁用滑动手势。
  final bool disabled;

  /// 滑动打开时触发。
  final VoidCallback? onOpen;

  /// 滑动关闭时触发。
  final VoidCallback? onClose;

  /// When true, requires a second tap on the action to confirm (execute) it.
  final bool confirmMode;

  /// Configurable width for each action button.
  final double? actionWidth;

  /// Async guard called before closing swipe actions. Return false to prevent close.
  final Future<bool> Function()? beforeClose;

  const ParkSwipeCell({
    super.key,
    required this.child,
    this.leftActions,
    this.rightActions,
    this.disabled = false,
    this.onOpen,
    this.onClose,
    this.confirmMode = false,
    this.actionWidth,
    this.beforeClose,
  });

  @override
  State<ParkSwipeCell> createState() => _ParkSwipeCellState();
}

class _ParkSwipeCellState extends State<ParkSwipeCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _dragOffset = 0.0;
  int? _pendingConfirmIndex; // For confirmMode: index awaiting second tap

  static const double _defaultActionButtonWidth = 72.0;
  static const double _snapThreshold = 0.4;
  static const double _minFlingVelocity = 300.0;

  double get _actionButtonWidth => widget.actionWidth ?? _defaultActionButtonWidth;

  double get _leftActionsWidth =>
      (widget.leftActions?.length ?? 0) * _actionButtonWidth;
  double get _rightActionsWidth =>
      (widget.rightActions?.length ?? 0) * _actionButtonWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.addListener(() {
      setState(() => _dragOffset = _animation.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (widget.disabled) return;
    _controller.stop();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.disabled) return;
    final delta = details.primaryDelta ?? details.delta.dx;
    double newOffset = _dragOffset + delta;

    // Clamp within bounds
    newOffset = newOffset.clamp(-_rightActionsWidth, _leftActionsWidth);

    setState(() => _dragOffset = newOffset);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (widget.disabled) return;
    final velocity = details.primaryVelocity ?? 0.0;

    if (velocity.abs() >= _minFlingVelocity) {
      if (velocity > 0 && _leftActionsWidth > 0) {
        _animateTo(_leftActionsWidth);
      } else if (velocity < 0 && _rightActionsWidth > 0) {
        _animateTo(-_rightActionsWidth);
      } else {
        _animateTo(0.0);
      }
      return;
    }

    final totalWidth = _dragOffset > 0 ? _leftActionsWidth : _rightActionsWidth;
    final ratio = totalWidth > 0 ? (_dragOffset.abs() / totalWidth) : 0.0;

    double targetOffset;
    if (ratio >= _snapThreshold) {
      // Snap open
      targetOffset = _dragOffset > 0 ? _leftActionsWidth : -_rightActionsWidth;
    } else {
      // Snap closed
      targetOffset = 0.0;
    }

    _animateTo(targetOffset);
  }

  void _animateTo(double target) {
    _animation = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0.0);

    if (target != 0 && _dragOffset == 0) {
      widget.onOpen?.call();
    } else if (target == 0 && _dragOffset != 0) {
      widget.onClose?.call();
    }
  }

  void _close() {
    if (_dragOffset != 0) {
      _animateTo(0.0);
    }
  }

  @override
  void didUpdateWidget(covariant ParkSwipeCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final minOffset = -_rightActionsWidth;
    final maxOffset = _leftActionsWidth;
    if (_dragOffset < minOffset || _dragOffset > maxOffset) {
      _dragOffset = _dragOffset.clamp(minOffset, maxOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Semantics(
      container: true,
      child: GestureDetector(
      onHorizontalDragStart: widget.disabled ? null : _onHorizontalDragStart,
      onHorizontalDragUpdate: widget.disabled ? null : _onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.disabled ? null : _onHorizontalDragEnd,
      onTap: () {
        _close();
        if (_pendingConfirmIndex != null) {
          setState(() => _pendingConfirmIndex = null);
        }
      },
      child: Stack(
        children: [
          // Left actions (behind)
          if (widget.leftActions != null && _dragOffset > 0)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: _leftActionsWidth,
              child: ClipRect(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < widget.leftActions!.length; i++)
                      _buildActionButton(widget.leftActions![i], park, _dragOffset, i),
                  ],
                ),
              ),
            ),

          // Right actions (behind)
          if (widget.rightActions != null && _dragOffset < 0)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: _rightActionsWidth,
              child: ClipRect(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < widget.rightActions!.length; i++)
                      _buildActionButton(widget.rightActions![i], park, _dragOffset, i),
                  ],
                ),
              ),
            ),

          // Main content
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: Container(color: park.colors.surface, child: widget.child),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildActionButton(
    ParkSwipeAction action,
    ParkThemeData park,
    double offset,
    int index,
  ) {
    final isConfirming = widget.confirmMode && _pendingConfirmIndex == index;
    final l10n = ParkLocalizations.of(context);
    final displayText = isConfirming
        ? (action.confirmText ?? l10n.confirmText)
        : action.label;

    return Semantics(
      button: true,
      label: displayText,
      child: GestureDetector(
        onTap: () {
          if (widget.confirmMode) {
            if (isConfirming) {
              _pendingConfirmIndex = null;
              _close();
              action.onTap?.call();
            } else {
              setState(() => _pendingConfirmIndex = index);
            }
          } else {
            _close();
            action.onTap?.call();
          }
        },
        child: Container(
          width: _actionButtonWidth,
          height: double.infinity,
          color: isConfirming ? park.colors.error : (action.color ?? park.colors.textPrimary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (action.icon != null && !isConfirming) ...[
                action.icon!,
                SizedBox(height: park.spacing.xs),
              ],
              Text(
                displayText,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeCaption,
                  color: park.colors.textOnBrand,
                  fontWeight: park.typography.weightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
