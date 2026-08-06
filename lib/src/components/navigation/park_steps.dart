import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// Park 步骤状态
enum ParkStepStatus {
  /// 等待中（灰色）
  waiting,

  /// 进行中（品牌色）
  process,

  /// 已完成（成功色 / 绿色）
  finish,

  /// 错误（错误色 / 红色）
  error,
}

/// Park 步骤方向
enum ParkStepsDirection {
  /// 水平方向
  horizontal,

  /// 垂直方向
  vertical,
}

/// Park 步骤条尺寸
enum ParkStepsSize {
  /// 小尺寸（图标 22px，文字稍小）
  small,

  /// 默认尺寸（图标 28px）
  defaultSize,
}

/// Park 步骤标签排列方式
enum ParkLabelPlacement {
  /// 描述在图标右侧（水平）
  horizontal,

  /// 描述在图标下方（垂直）
  vertical,
}

/// Park 步骤数据模型
class ParkStep {
  /// 步骤标题
  final String title;

  /// 步骤描述（可选）
  final String? description;

  /// 步骤状态（可选，默认根据 [ParkSteps.currentStep] 自动推算）
  final ParkStepStatus? status;

  /// 副标题，显示在主标题之后
  final String? subTitle;

  /// 是否禁用（灰色、不可交互）
  final bool disabled;

  /// 自定义图标（替代默认编号）
  final IconData? icon;

  const ParkStep({
    required this.title,
    this.description,
    this.status,
    this.subTitle,
    this.disabled = false,
    this.icon,
  });
}

/// Park 步骤条
///
/// 显示任务进度，以编号圆圈 + 连线的方式展示每个步骤的状态。
/// 已完成 = 绿色勾号，进行中 = 品牌色编号，等待 = 灰色，错误 = 红色叹号。
///
/// ```dart
/// ParkSteps(
///   steps: [
///     ParkStep(title: '基本信息'),
///     ParkStep(title: '详细信息', description: '填写详细资料'),
///     ParkStep(title: '完成'),
///   ],
///   currentStep: 1,
///   direction: ParkStepsDirection.horizontal,
/// )
/// ```
class ParkSteps extends StatelessWidget {
  /// 步骤列表
  final List<ParkStep> steps;

  /// 当前步骤索引（0-based）
  final int currentStep;

  /// 排列方向
  final ParkStepsDirection direction;

  /// 步骤点击回调
  final ValueChanged<int>? onStepTap;

  /// 是否启用可点击样式（鼠标指针 + hover 效果）
  ///
  /// 为 true 时步骤显示可交互样式；需配合 [onStepTap] 使用。
  final bool clickable;

  /// 当前步骤的圆形进度（0.0 ~ 1.0），为 null 时不显示
  final double? percent;

  /// 步骤条尺寸
  final ParkStepsSize size;

  /// 标签排列方式（水平 / 垂直）
  final ParkLabelPlacement labelPlacement;

  /// 自定义完成图标（替代默认勾号）
  final IconData? successIcon;

  /// 是否使用圆点样式（小圆点替代编号圆圈）
  final bool progressDot;

  /// 是否响应式布局（窄屏时自动切换为垂直方向）
  final bool responsive;

  /// 是否固定头部（SliverPersistentHeader）。
  ///
  /// - `true`：返回 [SliverPersistentHeader]（pinned），需放在 `CustomScrollView` 的 slivers 中，
  ///   滚动时步骤条固定在顶部不随内容滚走；
  /// - `false`（默认）：普通 Widget，随列表滚动。
  ///
  /// 仅水平方向支持；垂直方向忽略该属性。
  final bool sticky;

  const ParkSteps({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.direction = ParkStepsDirection.horizontal,
    this.onStepTap,
    this.clickable = false,
    this.percent,
    this.size = ParkStepsSize.defaultSize,
    this.labelPlacement = ParkLabelPlacement.horizontal,
    this.successIcon,
    this.progressDot = false,
    this.responsive = false,
    this.sticky = false,
  });

  /// 是否可交互（clickable 且提供了回调）
  bool get _isInteractive => clickable && onStepTap != null;

  double get _circleSize =>
      size == ParkStepsSize.small ? 22.0 : 28.0;

  double get _iconSize =>
      size == ParkStepsSize.small ? 13.0 : 16.0;

  double get _titleFontSize =>
      size == ParkStepsSize.small ? 12.0 : 14.0;

  double get _descFontSize =>
      size == ParkStepsSize.small ? 10.0 : 12.0;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget stepsWidget;
    if (direction == ParkStepsDirection.horizontal) {
      stepsWidget = _buildHorizontal(park, l10n);
    } else {
      stepsWidget = _buildVertical(park, l10n);
    }

    // 固定头部：用 SliverPersistentHeader 包裹，需放入 CustomScrollView 的 slivers。
    if (sticky && direction == ParkStepsDirection.horizontal) {
      return SliverPersistentHeader(
        pinned: true,
        delegate: _ParkStepsSliverDelegate(
          child: Container(
            width: double.infinity,
            color: park.colors.surface,
            padding: EdgeInsets.symmetric(
              vertical: park.spacing.sm,
              horizontal: park.spacing.base,
            ),
            child: stepsWidget,
          ),
        ),
      );
    }

    return stepsWidget;
  }

  // ==========================================================================
  // 水平布局
  // ==========================================================================

  Widget _buildHorizontal(ParkThemeData park, ParkLocalizations l10n) {
    final children = <Widget>[];

    for (int stepIdx = 0; stepIdx < steps.length; stepIdx++) {
      children.add(
        Expanded(
          flex: 2,
          child: labelPlacement == ParkLabelPlacement.vertical
              ? _buildStepCircleVertical(
                  step: steps[stepIdx],
                  index: stepIdx,
                  park: park,
                  l10n: l10n,
                )
              : _buildStepCircleHorizontal(
                  step: steps[stepIdx],
                  index: stepIdx,
                  park: park,
                  l10n: l10n,
                ),
        ),
      );

      if (stepIdx < steps.length - 1) {
        children.add(
          Expanded(
            child: _buildConnector(
              previousStepStatus: _effectiveStatus(steps[stepIdx], stepIdx),
              park: park,
              isVertical: false,
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // ==========================================================================
  // 垂直布局
  // ==========================================================================

  Widget _buildVertical(ParkThemeData park, ParkLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length * 2 - 1, (rawIndex) {
        if (rawIndex.isOdd) {
          final stepIdx = rawIndex ~/ 2;
          return _buildConnector(
            previousStepStatus: _effectiveStatus(steps[stepIdx], stepIdx),
            park: park,
            isVertical: true,
          );
        }
        final stepIdx = rawIndex ~/ 2;
        return _buildStepRow(step: steps[stepIdx], index: stepIdx, park: park, l10n: l10n);
      }),
    );
  }

  Widget _buildStepRow({
    required ParkStep step,
    required int index,
    required ParkThemeData park,
    required ParkLocalizations l10n,
  }) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCircle(step, index, park),
        SizedBox(width: park.spacing.sm),
        Expanded(
          child: _buildStepText(step, index, park),
        ),
      ],
    );

    return _wrapInteractive(content, index, l10n);
  }

  // ==========================================================================
  // 圆圈 + 文字（水平布局用 - 水平标签）
  // ==========================================================================

  Widget _buildStepCircleHorizontal({
    required ParkStep step,
    required int index,
    required ParkThemeData park,
    required ParkLocalizations l10n,
  }) {
    // 水平布局 + 水平标签：圆圈在左，文字在右
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCircle(step, index, park),
        SizedBox(width: park.spacing.xs),
        Flexible(child: _buildStepText(step, index, park)),
      ],
    );

    return _wrapInteractive(content, index, l10n);
  }

  // ==========================================================================
  // 圆圈 + 文字（水平布局用 - 垂直标签，圆圈在上文字在下）
  // ==========================================================================

  Widget _buildStepCircleVertical({
    required ParkStep step,
    required int index,
    required ParkThemeData park,
    required ParkLocalizations l10n,
  }) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCircle(step, index, park),
        SizedBox(height: park.spacing.sm),
        _buildStepText(step, index, park, centered: true),
      ],
    );

    return _wrapInteractive(content, index, l10n);
  }

  // ==========================================================================
  // 步骤文字区域
  // ==========================================================================

  Widget _buildStepText(
    ParkStep step,
    int index,
    ParkThemeData park, {
    bool centered = false,
  }) {
    final crossAxisAlignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                step.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: centered ? TextAlign.center : null,
                style: TextStyle(
                  color: _titleColor(step, index, park),
                  fontSize: _titleFontSize,
                  fontWeight: park.typography.weightMedium,
                ),
              ),
            ),
            if (step.subTitle != null) ...[
              SizedBox(width: park.spacing.xxs),
              Flexible(
                child: Text(
                  step.subTitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: park.colors.textSecondary,
                    fontSize: _descFontSize,
                    fontWeight: park.typography.weightRegular,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (step.description != null) ...[
          SizedBox(height: park.spacing.xxs),
          Text(
            step.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: centered ? TextAlign.center : null,
            style: TextStyle(
              color: park.colors.textSecondary,
              fontSize: _descFontSize,
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================================
  // 交互包裹（clickable + hover）
  // ==========================================================================

  Widget _wrapInteractive(Widget child, int index, ParkLocalizations l10n) {
    final step = steps[index];
    final status = _effectiveStatus(step, index);
    final statusStr = switch (status) {
      ParkStepStatus.finish => l10n.stepStatusFinish,
      ParkStepStatus.process => l10n.stepStatusProcess,
      ParkStepStatus.error => l10n.stepStatusError,
      ParkStepStatus.waiting => l10n.stepStatusWaiting,
    };

    Widget result;

    // 禁用步骤：不可交互
    if (step.disabled || !_isInteractive) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    } else {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _HoverableStep(
          onTap: () => onStepTap!(index),
          child: child,
        ),
      );
    }

    return Semantics(
      label: l10n.stepSemanticFormat(index, step.title, statusStr, step.description),
      excludeSemantics: true,
      child: result,
    );
  }

  // ==========================================================================
  // 圆圈本体
  // ==========================================================================

  Widget _buildCircle(ParkStep step, int index, ParkThemeData park) {
    final status = _effectiveStatus(step, index);
    final cs = _circleSize;

    final bgColor = _circleBg(status, park);
    final fgColor = _circleFg(status, park);

    // progressDot 模式：小圆点替代编号圆圈
    if (progressDot) {
      final dotColor = status == ParkStepStatus.process
          ? park.colors.brand
          : (status == ParkStepStatus.finish
              ? park.colors.success
              : (status == ParkStepStatus.error
                  ? park.colors.error
                  : park.colors.border));
      Widget dot = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      );
      if (step.disabled) {
        dot = Opacity(opacity: 0.4, child: dot);
      }
      return dot;
    }

    Widget innerChild;
    if (status == ParkStepStatus.finish) {
      // 自定义完成图标 or 默认勾号
      final finishIcon = successIcon ?? Icons.check;
      innerChild = Icon(finishIcon, size: _iconSize, color: fgColor);
    } else if (status == ParkStepStatus.error) {
      innerChild = Icon(Icons.close, size: _iconSize, color: fgColor);
    } else if (step.icon != null) {
      // 自定义图标替代编号
      innerChild = Icon(step.icon, size: _iconSize, color: fgColor);
    } else {
      innerChild = Text(
        '${index + 1}',
        style: TextStyle(
          color: fgColor,
          fontSize: size == ParkStepsSize.small ? 11.0 : park.typography.sizeBodySmall,
          fontWeight: park.typography.weightBold,
          height: 1.0,
        ),
      );
    }

    Widget circle = Container(
      width: cs,
      height: cs,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: status == ParkStepStatus.waiting || status == ParkStepStatus.process
            ? Border.all(
                color: status == ParkStepStatus.process
                    ? park.colors.brand
                    : park.colors.border,
                width: 1.5,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: innerChild,
    );

    // 圆形进度指示器（仅对当前步骤生效）
    if (percent != null && index == currentStep && status == ParkStepStatus.process) {
      circle = SizedBox(
        width: cs + 6,
        height: cs + 6,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: cs + 6,
              height: cs + 6,
              child: CustomPaint(
                painter: _StepProgressPainter(
                  percent: percent!.clamp(0.0, 1.0),
                  color: park.colors.brand,
                  strokeWidth: 2.0,
                ),
              ),
            ),
            circle,
          ],
        ),
      );
    }

    // 禁用态：降低透明度
    if (step.disabled) {
      circle = Opacity(opacity: 0.4, child: circle);
    }

    final statusLabel = status.name;
    return Semantics(
      label: '${statusLabel == 'error' ? '✕' : '${index + 1}'} - ${step.title}',
      excludeSemantics: true,
      child: circle,
    );
  }

  // ==========================================================================
  // 连接线
  // ==========================================================================

  Widget _buildConnector({
    required ParkStepStatus previousStepStatus,
    required ParkThemeData park,
    required bool isVertical,
  }) {
    Color color;
    if (previousStepStatus == ParkStepStatus.error) {
      color = park.colors.error;
    } else if (previousStepStatus == ParkStepStatus.finish) {
      color = park.colors.success;
    } else {
      color = park.colors.border;
    }
    final halfCircle = _circleSize / 2;

    if (isVertical) {
      return Padding(
        padding: EdgeInsets.only(left: halfCircle - 0.75),
        child: Container(width: 1.5, height: 24, color: color),
      );
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: halfCircle - 0.75),
      child: Container(
        height: 1.5,
        margin: EdgeInsets.symmetric(horizontal: park.spacing.xs),
        color: color,
      ),
    );
  }

  // ==========================================================================
  // 状态 & 颜色解析
  // ==========================================================================

  ParkStepStatus _effectiveStatus(ParkStep step, int index) {
    if (step.status != null) return step.status!;

    if (index < currentStep) return ParkStepStatus.finish;
    if (index == currentStep) return ParkStepStatus.process;
    return ParkStepStatus.waiting;
  }

  Color _circleBg(ParkStepStatus status, ParkThemeData park) {
    switch (status) {
      case ParkStepStatus.finish:
        return park.colors.success;
      case ParkStepStatus.process:
        return park.colors.brand.withValues(alpha: 0.1);
      case ParkStepStatus.error:
        return park.colors.error;
      case ParkStepStatus.waiting:
        return Colors.transparent;
    }
  }

  Color _circleFg(ParkStepStatus status, ParkThemeData park) {
    switch (status) {
      case ParkStepStatus.finish:
        return park.colors.textOnBrand;
      case ParkStepStatus.process:
        return park.colors.brand;
      case ParkStepStatus.error:
        return park.colors.textOnBrand;
      case ParkStepStatus.waiting:
        return park.colors.textSecondary;
    }
  }

  Color _titleColor(ParkStep step, int index, ParkThemeData park) {
    if (step.disabled) return park.colors.textSecondary.withValues(alpha: 0.5);
    final status = _effectiveStatus(step, index);
    switch (status) {
      case ParkStepStatus.finish:
        return park.colors.textPrimary;
      case ParkStepStatus.process:
        return park.colors.brand;
      case ParkStepStatus.error:
        return park.colors.error;
      case ParkStepStatus.waiting:
        return park.colors.textSecondary;
    }
  }
}

/// 可交互步骤的 hover 状态管理
class _HoverableStep extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _HoverableStep({required this.onTap, required this.child});

  @override
  State<_HoverableStep> createState() => _HoverableStepState();
}

class _HoverableStepState extends State<_HoverableStep> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered
                ? park.colors.brand.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(park.radius.sm),
          ),
          padding: EdgeInsets.all(park.spacing.xxs),
          child: widget.child,
        ),
      ),
    );
  }
}

/// 步骤圆形进度画笔
class _StepProgressPainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;

  _StepProgressPainter({
    required this.percent,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景轨道
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 进度弧
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StepProgressPainter oldDelegate) {
    return oldDelegate.percent != percent || oldDelegate.color != color;
  }
}

/// ParkSteps 固定头部委托：滚动时步骤条固定在顶部。
class _ParkStepsSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ParkStepsSliverDelegate({required this.child});

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _ParkStepsSliverDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
