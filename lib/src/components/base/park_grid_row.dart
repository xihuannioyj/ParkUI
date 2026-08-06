// ParkGridRow / ParkGridCol - 响应式断点布局组件
//
// 对标 Ant Design Grid Row/Col 系统，实现 24 格响应式栅格布局。
// ParkGridRow 使用 LayoutBuilder 获取父容器宽度，根据断点匹配每个
// ParkGridCol 的实际 span，支持 gutter、自动换行和响应式配置。

import 'package:flutter/material.dart';

// =============================================================================
// 断点定义
// =============================================================================

/// 响应式断点常量（对标 Ant Design）。
///
/// | 断点 | 宽度        | 说明         |
/// |------|-------------|-------------|
/// | xs   | <576px      | 手机竖屏     |
/// | sm   | >=576px     | 手机横屏     |
/// | md   | >=768px     | 平板         |
/// | lg   | >=992px     | 桌面         |
/// | xl   | >=1200px    | 大桌面       |
/// | xxl  | >=1600px    | 超大桌面     |
class ParkBreakpoint {
  ParkBreakpoint._();

  /// 超小屏（手机竖屏 <576px）
  static const double xs = 576;

  /// 小屏（手机横屏 >=576px）
  static const double sm = 576;

  /// 中屏（平板 >=768px）
  static const double md = 768;

  /// 大屏（桌面 >=992px）
  static const double lg = 992;

  /// 超大屏（大桌面 >=1200px）
  static const double xl = 1200;

  /// 超超大屏（超大桌面 >=1600px）
  static const double xxl = 1600;

  /// 根据给定宽度返回当前匹配的断点名称。
  ///
  /// 从大到小依次匹配，返回第一个满足 width >= breakpoint 的名称。
  /// 若均不满足则返回 `'xs'`。
  static String matchName(double width) {
    if (width >= xxl) return 'xxl';
    if (width >= xl) return 'xl';
    if (width >= lg) return 'lg';
    if (width >= md) return 'md';
    if (width >= sm) return 'sm';
    return 'xs';
  }
}

// =============================================================================
// 响应式配置
// =============================================================================

/// 响应式配置 — 为不同断点指定不同的 span 值。
///
/// ```dart
/// ParkGridCol(
///   span: 24, // 默认占满
///   responsive: const ParkGridResponsive(
///     sm: 12, // >=576px 占半行
///     md: 8,  // >=768px 占 1/3
///     lg: 6,  // >=992px 占 1/4
///   ),
/// )
/// ```
class ParkGridResponsive {
  /// <576px 时的 span
  final int? xs;

  /// >=576px 时的 span
  final int? sm;

  /// >=768px 时的 span
  final int? md;

  /// >=992px 时的 span
  final int? lg;

  /// >=1200px 时的 span
  final int? xl;

  /// >=1600px 时的 span
  final int? xxl;

  const ParkGridResponsive({
    this.xs,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.xxl,
  });

  /// 根据当前断点名称返回对应的 span 值。
  ///
  /// 若当前断点无配置，向更小断点回退查找；
  /// 若所有断点均无配置则返回 null（由调用方使用默认 span）。
  int? spanForBreakpoint(String bpName) {
    switch (bpName) {
      case 'xxl':
        return xxl ?? xl ?? lg ?? md ?? sm ?? xs;
      case 'xl':
        return xl ?? lg ?? md ?? sm ?? xs;
      case 'lg':
        return lg ?? md ?? sm ?? xs;
      case 'md':
        return md ?? sm ?? xs;
      case 'sm':
        return sm ?? xs;
      case 'xs':
        return xs;
      default:
        return null;
    }
  }
}

// =============================================================================
// 对齐 / 排列枚举
// =============================================================================

/// 栅格行垂直对齐方式（cross-axis）。
enum ParkGridRowAlign {
  /// 顶部对齐
  start,

  /// 居中对齐
  center,

  /// 底部对齐
  end,

  /// 拉伸填充
  stretch,

  /// 基线对齐
  baseline,
}

/// 栅格行水平排列方式（main-axis）。
enum ParkGridJustify {
  /// 从左开始
  start,

  /// 居中
  center,

  /// 从右开始
  end,

  /// 两端对齐
  spaceBetween,

  /// 等间距
  spaceAround,

  /// 等间距，两端各半个间距
  spaceEvenly,
}

// =============================================================================
// ParkGridRow — 栅格行容器
// =============================================================================

/// 栅格行容器 — 24 格响应式栅格系统的行包装器。
///
/// 使用 [LayoutBuilder] 获取父容器宽度，根据当前宽度匹配断点，
/// 确定每个 [ParkGridCol] 的实际 span，实现自动换行布局。
///
/// ```dart
/// ParkGridRow(
///   gutter: 16,
///   children: [
///     ParkGridCol(span: 8, child: Text('A')),
///     ParkGridCol(span: 8, child: Text('B')),
///     ParkGridCol(span: 8, child: Text('C')),
///   ],
/// )
/// ```
class ParkGridRow extends StatelessWidget {
  /// 列间距（水平 gutter，单位 px）。
  final double gutter;

  /// 行间距（垂直 gutter，单位 px）。
  final double vGutter;

  /// 垂直对齐方式。
  final ParkGridRowAlign align;

  /// 水平排列方式。
  final ParkGridJustify justify;

  /// 子组件列表（通常为 [ParkGridCol]）。
  final List<Widget> children;

  const ParkGridRow({
    super.key,
    this.gutter = 0,
    this.vGutter = 0,
    this.align = ParkGridRowAlign.start,
    this.justify = ParkGridJustify.start,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        if (containerWidth.isInfinite) {
          // 在无限宽度约束下，使用一个合理的默认值
          return _buildLayout(context, 375);
        }
        return _buildLayout(context, containerWidth);
      },
    );
  }

  Widget _buildLayout(BuildContext context, double containerWidth) {
    final bpName = ParkBreakpoint.matchName(containerWidth);

    // 解析每个子组件的实际 span
    final resolvedCols = <_ResolvedCol>[];
    for (final child in children) {
      if (child is ParkGridCol) {
        final effectiveSpan = _resolveSpan(child, bpName);
        final effectiveOffset = child.offset;
        resolvedCols.add(_ResolvedCol(
          span: effectiveSpan,
          offset: effectiveOffset,
          order: child.order,
          child: child.child ?? const SizedBox.shrink(),
        ));
      } else {
        // 非 ParkGridCol 子组件，当作 span=24 处理
        resolvedCols.add(_ResolvedCol(
          span: 24,
          offset: 0,
          order: 0,
          child: child,
        ));
      }
    }

    // 按 order 排序
    resolvedCols.sort((a, b) => a.order.compareTo(b.order));

    // 将 cols 按 24 格分行
    final rows = _splitIntoRows(resolvedCols);

    // 构建视觉行
    final crossAxis = _resolveCrossAxisAlignment(align);
    final mainAxis = _resolveMainAxisAlignment(justify);

    final halfGutter = gutter / 2;

    final rowWidgets = <Widget>[];
    for (var rowIdx = 0; rowIdx < rows.length; rowIdx++) {
      if (rowIdx > 0 && vGutter > 0) {
        rowWidgets.add(SizedBox(height: vGutter));
      }
      rowWidgets.add(_buildVisualRow(
        rows[rowIdx],
        containerWidth,
        crossAxis,
        mainAxis,
        halfGutter,
      ));
    }

    if (rowWidgets.length == 1) {
      return rowWidgets.first;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rowWidgets,
    );
  }

  /// 解析 ParkGridCol 在当前断点下的实际 span。
  int _resolveSpan(ParkGridCol col, String bpName) {
    if (col.responsive != null) {
      final responsiveSpan = col.responsive!.spanForBreakpoint(bpName);
      if (responsiveSpan != null) {
        return responsiveSpan.clamp(0, 24);
      }
    }
    return col.span.clamp(0, 24);
  }

  /// 将解析后的列按 24 格拆分为多行。
  List<List<_ResolvedCol>> _splitIntoRows(List<_ResolvedCol> cols) {
    final rows = <List<_ResolvedCol>>[];
    var currentRow = <_ResolvedCol>[];
    var currentSum = 0;

    for (final col in cols) {
      final totalNeeded = col.span + col.offset;
      if (totalNeeded <= 0) continue;

      if (currentSum + totalNeeded > 24 && currentRow.isNotEmpty) {
        rows.add(currentRow);
        currentRow = [];
        currentSum = 0;
      }

      currentRow.add(col);
      currentSum += totalNeeded;

      if (currentSum >= 24) {
        rows.add(currentRow);
        currentRow = [];
        currentSum = 0;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  /// 构建单行视觉布局。
  ///
  /// 每列用 Expanded(flex: span) 按 24 格比例分宽，列内 padding halfGutter
  /// 消化间距。注意：不能用负 padding 抵消首尾 gutter（debug 模式断言
  /// `padding.isNonNegative` 会崩溃），首尾各保留 halfGutter 空隙。
  Widget _buildVisualRow(
    List<_ResolvedCol> rowCols,
    double containerWidth,
    CrossAxisAlignment crossAxis,
    MainAxisAlignment mainAxis,
    double halfGutter,
  ) {
    // 计算已使用的格数（含 offset）
    final usedSpan = rowCols.fold<int>(
        0, (sum, col) => sum + col.span + col.offset);
    final remainingSpan = 24 - usedSpan;

    final colWidgets = <Widget>[];

    for (var i = 0; i < rowCols.length; i++) {
      final col = rowCols[i];

      // 偏移间距（按格数弹性占位）
      if (col.offset > 0) {
        colWidgets.add(Spacer(flex: col.offset));
      }

      // 列内容：flex 按 span 比例分宽，内部 padding 消化 gutter
      colWidgets.add(
        Expanded(
          flex: col.span,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: halfGutter),
            child: col.child,
          ),
        ),
      );
    }

    // justify 非 start 时，剩余空间用 Spacer 占位
    if (mainAxis != MainAxisAlignment.start && remainingSpan > 0) {
      colWidgets.add(Spacer(flex: remainingSpan));
    }

    return Row(
      crossAxisAlignment: crossAxis,
      mainAxisAlignment: mainAxis,
      children: colWidgets,
    );
  }

  CrossAxisAlignment _resolveCrossAxisAlignment(ParkGridRowAlign align) {
    switch (align) {
      case ParkGridRowAlign.start:
        return CrossAxisAlignment.start;
      case ParkGridRowAlign.center:
        return CrossAxisAlignment.center;
      case ParkGridRowAlign.end:
        return CrossAxisAlignment.end;
      case ParkGridRowAlign.stretch:
        return CrossAxisAlignment.stretch;
      case ParkGridRowAlign.baseline:
        return CrossAxisAlignment.baseline;
    }
  }

  MainAxisAlignment _resolveMainAxisAlignment(ParkGridJustify justify) {
    switch (justify) {
      case ParkGridJustify.start:
        return MainAxisAlignment.start;
      case ParkGridJustify.center:
        return MainAxisAlignment.center;
      case ParkGridJustify.end:
        return MainAxisAlignment.end;
      case ParkGridJustify.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case ParkGridJustify.spaceAround:
        return MainAxisAlignment.spaceAround;
      case ParkGridJustify.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
    }
  }
}

// =============================================================================
// ParkGridCol — 栅格列
// =============================================================================

/// 栅格列 — 24 格响应式栅格系统的列单元。
///
/// 通过 [span] 指定占格数（默认 24 即满行），[offset] 指定左侧偏移格数，
/// [responsive] 提供不同断点下的 span 覆盖。
///
/// ```dart
/// ParkGridRow(
///   gutter: 16,
///   children: [
///     ParkGridCol(span: 6, child: Text('25%')),
///     ParkGridCol(span: 6, child: Text('25%')),
///     ParkGridCol(
///       span: 24,
///       responsive: ParkGridResponsive(md: 12, lg: 6),
///       child: Text('响应式'),
///     ),
///   ],
/// )
/// ```
class ParkGridCol extends StatelessWidget {
  /// 占格数（总共 24 格）。
  final int span;

  /// 左侧偏移格数。
  final int offset;

  /// 排序值（越小越靠前）。
  final int order;

  /// 响应式配置 — 为不同断点指定不同的 span。
  final ParkGridResponsive? responsive;

  /// 子组件。
  final Widget? child;

  const ParkGridCol({
    super.key,
    this.span = 24,
    this.offset = 0,
    this.order = 0,
    this.responsive,
    this.child,
  })  : assert(span >= 0 && span <= 24, 'span must be between 0 and 24'),
        assert(offset >= 0 && offset <= 24, 'offset must be between 0 and 24');

  @override
  Widget build(BuildContext context) {
    // ParkGridCol 的实际宽度由父 ParkGridRow 通过 LayoutBuilder 计算并设置。
    // 当 ParkGridCol 脱离 ParkGridRow 独立使用时，回退为满行宽度。
    return child ?? const SizedBox.shrink();
  }
}

// =============================================================================
// 内部数据类
// =============================================================================

/// 解析后的列信息（内部用）。
class _ResolvedCol {
  final int span;
  final int offset;
  final int order;
  final Widget child;

  const _ResolvedCol({
    required this.span,
    required this.offset,
    required this.order,
    required this.child,
  });
}
