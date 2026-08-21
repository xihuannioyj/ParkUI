import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// ParkSplitter — 可拖拽分隔面板组件
///
/// 对标 antd Splitter，支持水平/垂直方向拖拽分隔两个面板，
/// 可配置最小/最大比例、默认比例、折叠按钮、受控模式与分隔条样式。
///
/// 所有视觉元素使用 park.* 设计令牌，零第三方依赖。
///
/// ```dart
/// ParkSplitter(
///   axis: Axis.horizontal,
///   first: Text('左侧面板'),
///   second: Text('右侧面板'),
/// )
/// ```
class ParkSplitter extends StatefulWidget {
  /// 布局方向：horizontal（左右分栏）/ vertical（上下分栏）
  final Axis axis;

  /// 左侧/上方面板内容
  final Widget first;

  /// 右侧/下方面板内容
  final Widget second;

  /// 默认比例（0.0 ~ 1.0），默认 0.5
  final double defaultRatio;

  /// 面板最小比例（0.0 ~ 1.0），为 null 时不限制。
  /// 默认 0.2。
  final double? minRatio;

  /// 面板最大比例（0.0 ~ 1.0），为 null 时不限制。
  /// 默认 0.8。
  final double? maxRatio;

  /// 受控比例（非 null 时外部控制当前比例）
  final double? ratio;

  /// 比例变化回调（受控 / 非受控模式下均触发）
  final ValueChanged<double>? onRatioChanged;

  /// 分隔条宽度，默认 park.spacing.xxs (2px)
  final double? dividerThickness;

  /// 分隔条颜色，默认 park.colors.divider
  final Color? dividerColor;

  /// 分隔条拖拽态颜色，默认 park.colors.brand
  final Color? dividerDragColor;

  /// 是否显示折叠按钮（点击将一侧面板折叠到最小）
  final bool collapsible;

  /// 创建 ParkSplitter。
  const ParkSplitter({
    super.key,
    this.axis = Axis.horizontal,
    required this.first,
    required this.second,
    this.defaultRatio = 0.5,
    this.minRatio,
    this.maxRatio,
    this.ratio,
    this.onRatioChanged,
    this.dividerThickness,
    this.dividerColor,
    this.dividerDragColor,
    this.collapsible = false,
  }) : assert(
         defaultRatio >= 0.0 && defaultRatio <= 1.0,
         'defaultRatio must be between 0.0 and 1.0',
       ),
       assert(
         minRatio == null || (minRatio >= 0.0 && minRatio <= 1.0),
         'minRatio must be between 0.0 and 1.0 when non-null',
       ),
       assert(
         maxRatio == null || (maxRatio >= 0.0 && maxRatio <= 1.0),
         'maxRatio must be between 0.0 and 1.0 when non-null',
       ),
       assert(
         minRatio == null || maxRatio == null || minRatio <= maxRatio,
         'minRatio must be <= maxRatio when both are non-null',
       );

  @override
  State<ParkSplitter> createState() => _ParkSplitterState();
}

class _ParkSplitterState extends State<ParkSplitter> {
  late double _ratio;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio ?? widget.defaultRatio;
  }

  @override
  void didUpdateWidget(ParkSplitter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ratio != null && widget.ratio != oldWidget.ratio) {
      _ratio = widget.ratio!;
    }
  }

  // 边界防御：minRatio > maxRatio 时 clamp 抛 ArgumentError，先归一化。
  double get _effectiveMinRatio {
    final double m = widget.minRatio ?? 0.0;
    final double M = widget.maxRatio ?? 1.0;
    return m <= M ? m : M;
  }

  double get _effectiveMaxRatio {
    final double m = widget.minRatio ?? 0.0;
    final double M = widget.maxRatio ?? 1.0;
    return m <= M ? M : m;
  }

  double get _effectiveRatio {
    final r = widget.ratio ?? _ratio;
    return r.clamp(_effectiveMinRatio, _effectiveMaxRatio);
  }

  void _updateRatio(double newRatio) {
    final clamped = newRatio.clamp(_effectiveMinRatio, _effectiveMaxRatio);
    if (widget.ratio == null) {
      setState(() {
        _ratio = clamped;
      });
    }
    widget.onRatioChanged?.call(clamped);
  }

  void _collapseFirst() {
    _updateRatio(_effectiveMinRatio);
  }

  void _collapseSecond() {
    _updateRatio(1.0 - _effectiveMinRatio);
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final thickness = widget.dividerThickness ?? park.spacing.xxs;
    final color = widget.dividerColor ?? park.colors.divider;
    final dragColor = widget.dividerDragColor ?? park.colors.brand;

    if (widget.axis == Axis.horizontal) {
      return _buildHorizontal(context, park, l10n, thickness, color, dragColor);
    } else {
      return _buildVertical(context, park, l10n, thickness, color, dragColor);
    }
  }

  Widget _buildHorizontal(
    BuildContext context,
    ParkThemeData park,
    ParkLocalizations l10n,
    double thickness,
    Color color,
    Color dragColor,
  ) {
    final ratio = _effectiveRatio;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final totalWidth = constraints.maxWidth;
        final dividerWidth = thickness;
        // 边界防御：分隔条比容器宽时 available 为负 → SizedBox 负宽断言崩溃。
        final availableWidth = math.max(0.0, totalWidth - dividerWidth);
        final firstWidth = availableWidth * ratio;
        final secondWidth = availableWidth * (1.0 - ratio);

        return Semantics(
          label: l10n.splitterLabel,
          value: '${(ratio * 100).toInt()}%',
          increasedValue: '${((ratio + 0.05).clamp(_effectiveMinRatio, _effectiveMaxRatio) * 100).toInt()}%',
          decreasedValue: '${((ratio - 0.05).clamp(_effectiveMinRatio, _effectiveMaxRatio) * 100).toInt()}%',
          onIncrease: () => _updateRatio(ratio + 0.05),
          onDecrease: () => _updateRatio(ratio - 0.05),
          child: SizedBox(
            width: totalWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 第一个面板
                SizedBox(width: firstWidth, child: widget.first),
                // 分隔条
                _buildDivider(
                  park: park,
                  l10n: l10n,
                  thickness: thickness,
                  dividerWidth: dividerWidth,
                  color: color,
                  dragColor: dragColor,
                  ratio: ratio,
                  totalExtent: totalWidth,
                  isHorizontal: true,
                ),
                // 第二个面板
                SizedBox(width: secondWidth, child: widget.second),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVertical(
    BuildContext context,
    ParkThemeData park,
    ParkLocalizations l10n,
    double thickness,
    Color color,
    Color dragColor,
  ) {
    final ratio = _effectiveRatio;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 边界防御：置于滚动容器时 maxHeight 可能为无穷 → SizedBox(height:∞)
        // 布局崩溃；退化为 minHeight/0。
        final double totalHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : (constraints.minHeight.isFinite
                ? constraints.minHeight
                : 0.0);
        final dividerHeight = thickness;
        final availableHeight = math.max(0.0, totalHeight - dividerHeight);
        final firstHeight = availableHeight * ratio;
        final secondHeight = availableHeight * (1.0 - ratio);

        return Semantics(
          label: l10n.splitterLabel,
          value: '${(ratio * 100).toInt()}%',
          increasedValue: '${((ratio + 0.05).clamp(_effectiveMinRatio, _effectiveMaxRatio) * 100).toInt()}%',
          decreasedValue: '${((ratio - 0.05).clamp(_effectiveMinRatio, _effectiveMaxRatio) * 100).toInt()}%',
          onIncrease: () => _updateRatio(ratio + 0.05),
          onDecrease: () => _updateRatio(ratio - 0.05),
          child: SizedBox(
            height: totalHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 第一个面板
                SizedBox(height: firstHeight, child: widget.first),
                // 分隔条
                _buildDivider(
                  park: park,
                  l10n: l10n,
                  thickness: thickness,
                  dividerWidth: dividerHeight,
                  color: color,
                  dragColor: dragColor,
                  ratio: ratio,
                  totalExtent: totalHeight,
                  isHorizontal: false,
                ),
                // 第二个面板
                SizedBox(height: secondHeight, child: widget.second),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider({
    required ParkThemeData park,
    required ParkLocalizations l10n,
    required double thickness,
    required double dividerWidth,
    required Color color,
    required Color dragColor,
    required double ratio,
    required double totalExtent,
    required bool isHorizontal,
  }) {
    final effectiveColor = _isDragging ? dragColor : color;

    return MouseRegion(
      cursor: isHorizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          setState(() => _isDragging = true);
        },
        onPanUpdate: (DragUpdateDetails details) {
          final delta = isHorizontal ? details.delta.dx : details.delta.dy;
          final dividerSize = thickness;
          final available = totalExtent - dividerSize;
          // 边界防御：available<=0 时 delta/0 得 NaN/Infinity → 比例错乱。
          if (available <= 0) return;
          final deltaRatio = delta / available;
          _updateRatio(ratio + deltaRatio);
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
        },
        onPanCancel: () {
          setState(() => _isDragging = false);
        },
        // 触击复位：双击恢复默认比例
        onDoubleTap: () {
          _updateRatio(widget.defaultRatio);
        },
        child: SizedBox(
          width: isHorizontal ? dividerWidth : double.infinity,
          height: isHorizontal ? double.infinity : dividerWidth,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              // 分隔条背景
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: effectiveColor,
                  ),
                ),
              ),
              // 拖拽指示条（hover/drag 时可见微条）
              if (_isDragging)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: isHorizontal ? null : 20,
                      height: isHorizontal ? 20 : null,
                      decoration: BoxDecoration(
                        color: dragColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(park.radius.xs),
                      ),
                    ),
                  ),
                ),
              // 折叠按钮：分隔条本身只有几像素厚，两个按钮（~18px）
              // 无法放进分隔条内——OverflowBox 让按钮悬浮在分隔条上
              // （类似 VS Code 折叠把手），避免 RenderFlex 溢出。
              // 注意 Positioned.fill 必须保持 Stack 直接子级。
              if (widget.collapsible)
                Positioned.fill(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    alignment: Alignment.center,
                    child: _buildCollapseButtons(
                      park: park,
                      l10n: l10n,
                      isHorizontal: isHorizontal,
                      dragColor: dragColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButtons({
    required ParkThemeData park,
    required ParkLocalizations l10n,
    required bool isHorizontal,
    required Color dragColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
          // 折叠第一个面板的按钮（向左/向上折叠）
          _CollapseButton(
            icon: isHorizontal ? Icons.chevron_left : Icons.keyboard_arrow_up,
            tooltip: isHorizontal ? l10n.collapseFirstHorizontal : l10n.collapseFirstVertical,
            onTap: _collapseFirst,
            park: park,
            dragColor: dragColor,
          ),
          SizedBox(width: isHorizontal ? 0 : 4, height: isHorizontal ? 4 : 0),
          // 折叠第二个面板的按钮（向右/向下折叠）
          _CollapseButton(
            icon: isHorizontal ? Icons.chevron_right : Icons.keyboard_arrow_down,
            tooltip: isHorizontal ? l10n.collapseSecondHorizontal : l10n.collapseSecondVertical,
            onTap: _collapseSecond,
            park: park,
            dragColor: dragColor,
          ),
        ],
    );
  }
}

/// 折叠按钮内部组件
class _CollapseButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final ParkThemeData park;
  final Color dragColor;

  const _CollapseButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.park,
    required this.dragColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: park.colors.surface,
              borderRadius: BorderRadius.circular(park.radius.xs),
              border: Border.all(color: park.colors.border, width: 0.5),
            ),
            child: Icon(
              icon,
              size: 14,
              color: park.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
