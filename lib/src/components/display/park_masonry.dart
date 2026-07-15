// ParkMasonry - 瀑布流布局组件
//
// 以最短列优先算法将列表项分配到多列中，形成 Pinterest 风格的瀑布流布局。
// 支持固定列数或根据 minColumnWidth 自动响应式计算列数。
// 零第三方依赖，使用 Flutter 原生 CustomScrollView + SliverList 组合。
//
// 核心能力：
//  - 固定列数 columns 或响应式 minColumnWidth 自动计算
//  - 最短列优先分配算法
//  - 自动测量子项高度（Offstage + GlobalKey）
//  - 间距自定义：统一 spacing 或分离 columnSpacing
//  - 空状态自定义 emptyBuilder
//  - 懒加载无限滚动：itemCount + onLoadMore + ScrollController

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// 瀑布流布局组件 — ParkMasonry
///
/// 以"最短列优先"（shortest-column-first）算法将泛型数据 [items]
/// 分配到多列中，形成高度参差的瀑布流（Pinterest 风格）布局。
///
/// 列数可通过 [columns] 固定，也可通过 [minColumnWidth] 让组件根据
/// 容器宽度自动响应式计算。
///
/// 用法：
/// ```dart
/// ParkMasonry<String>(
///   items: ['A', 'B', 'C', 'D', 'E', 'F'],
///   itemBuilder: (context, item, index) => Card(
///     child: SizedBox(
///       height: 80.0 + (index % 4) * 40.0,
///       child: Center(child: Text(item)),
///     ),
///   ),
///   columns: 2,
///   spacing: 12,
/// )
/// ```
class ParkMasonry<T> extends StatefulWidget {
  /// 列表数据源
  final List<T> items;

  /// 列表项构建器
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 固定列数（优先级高于 [minColumnWidth]）
  ///
  /// 默认值 2。设置此值后忽略 [minColumnWidth]。
  final int columns;

  /// 最小列宽（响应式模式）
  ///
  /// 当 [columns] 为 null 时，组件根据容器宽度和此值自动计算列数。
  /// 例如 minColumnWidth=200，父容器宽 500→2 列，宽 700→3 列。
  final double? minColumnWidth;

  /// 卡片间统一间距（同时设置行间距和列间距）
  ///
  /// 默认值为 `park.spacing.sm`（8px）。
  final double spacing;

  /// 列间距（可选，不与行间距共用）
  ///
  /// 设置此值后 [spacing] 仅用于行间距。
  final double? columnSpacing;

  /// 空状态构建器（items 为空时显示）
  ///
  /// 默认显示 ParkLocalizations 中的"暂无数据"文案。
  final Widget Function(BuildContext context)? emptyBuilder;

  /// 懒加载：项目总数（用于无限滚动）
  ///
  /// 设置此值后组件根据 [itemCount] 而不是 [items.length] 判断是否
  /// 已加载全部。
  final int? itemCount;

  /// 懒加载回调：当滚动接近底部时触发
  ///
  /// 配合 [itemCount] 使用实现无限滚动。
  final Future<void> Function()? onLoadMore;

  /// 是否正在加载更多
  final bool loadingMore;

  /// 是否已无更多数据
  final bool noMore;

  const ParkMasonry({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.columns = 2,
    this.minColumnWidth,
    this.spacing = 8.0,
    this.columnSpacing,
    this.emptyBuilder,
    this.itemCount,
    this.onLoadMore,
    this.loadingMore = false,
    this.noMore = false,
  }) : assert(columns > 0, 'columns must be greater than 0');

  @override
  State<ParkMasonry<T>> createState() => _ParkMasonryState<T>();
}

class _ParkMasonryState<T> extends State<ParkMasonry<T>> {
  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 每列包含的 items 索引列表
  List<List<int>> _columnIndices = <List<int>>[];

  /// 每列的累计高度
  List<double> _columnHeights = <double>[];

  /// 已测量过的 item 高度缓存（索引 → 高度）
  final Map<int, double> _measuredHeights = <int, double>{};

  /// 阶段：是否正在测量（首次布局或 items 变化后）
  bool _isMeasuring = true;

  /// 列数
  int _columnCount = 2;

  /// 列间距
  double get _effectiveColumnSpacing =>
      widget.columnSpacing ?? widget.spacing;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ParkMasonry<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      // 数据源变化时清除高度缓存并重新测量
      _measuredHeights.clear();
      _isMeasuring = true;
      if (mounted) setState(() {});
    } else if (oldWidget.columns != widget.columns ||
        oldWidget.minColumnWidth != widget.minColumnWidth) {
      // 列数变化时复用已缓存的高度，仅重新分配布局
      if (!_isMeasuring && _measuredHeights.isNotEmpty) {
        final heights = _getCachedHeights();
        _doLayout(_columnCount, heights);
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听：检测接近底部
  void _onScroll() {
    if (widget.onLoadMore == null) return;
    if (widget.loadingMore || widget.noMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // 距离底部 200px 时触发加载
    if (maxScroll - currentScroll <= 200.0) {
      widget.onLoadMore!();
    }
  }

  /// 根据父容器宽度计算列数
  int _calculateColumnCount(double parentWidth) {
    if (widget.minColumnWidth != null && widget.minColumnWidth! > 0) {
      final count = (parentWidth /
              (widget.minColumnWidth! + _effectiveColumnSpacing))
          .floor()
          .clamp(1, 100);
      return count;
    }
    return widget.columns;
  }

  /// 获取有效 item 数量
  int get _effectiveItemCount => widget.itemCount ?? widget.items.length;

  /// 从缓存中获取所有 item 的高度列表
  List<double> _getCachedHeights() {
    return List<double>.generate(
      widget.items.length,
      (i) => _measuredHeights[i] ?? 100.0,
    );
  }

  /// 执行最短列优先分配
  void _doLayout(int columnCount, List<double> heights) {
    final indices = List<List<int>>.generate(
      columnCount,
      (_) => <int>[],
    );
    final heightsCopy = List<double>.generate(
      columnCount,
      (i) => i < _columnHeights.length ? _columnHeights[i] : 0.0,
    );

    // 确保新列数变化时重置
    if (heightsCopy.length != columnCount) {
      heightsCopy
        ..clear()
        ..addAll(List<double>.filled(columnCount, 0.0));
    }

    for (var i = 0; i < widget.items.length; i++) {
      // 找到当前最短列
      var minHeight = double.infinity;
      var minIndex = 0;
      for (var c = 0; c < columnCount; c++) {
        if (heightsCopy[c] < minHeight) {
          minHeight = heightsCopy[c];
          minIndex = c;
        }
      }

      indices[minIndex].add(i);

      // 加上 item 高度 + 间距
      final itemHeight = i < heights.length ? heights[i] : 100.0;
      heightsCopy[minIndex] +=
          itemHeight + (i > 0 ? widget.spacing : 0.0);
    }

    _columnIndices = indices;
    _columnHeights = heightsCopy;
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 空状态
    if (widget.items.isEmpty) {
      if (widget.emptyBuilder != null) {
        return widget.emptyBuilder!(context);
      }
      final l10n = ParkLocalizations.of(context);
      return Semantics(
        label: l10n.noData,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(park.spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: park.colors.textPlaceholder,
                ),
                SizedBox(height: park.spacing.sm),
                Text(
                  l10n.noData,
                  style: TextStyle(
                    fontSize: park.typography.sizeBodySmall,
                    color: park.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final parentWidth = constraints.maxWidth;
        final columnCount = _calculateColumnCount(parentWidth);
        _columnCount = columnCount;

        if (_isMeasuring) {
          // 测量阶段：将每个 item 在 Offstage 中构建以获取高度
          return _buildMeasuringLayout(context, columnCount, parentWidth, park);
        }

        // 正常渲染阶段
        return _buildFinalLayout(context, columnCount, parentWidth, park);
      },
    );
  }

  /// 测量布局：在 Offstage 中构建所有 item 获取自然高度
  Widget _buildMeasuringLayout(
    BuildContext context,
    int columnCount,
    double parentWidth,
    ParkThemeData park,
  ) {
    final columnWidth = _columnWidth(parentWidth, columnCount);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < widget.items.length; i++)
            Offstage(
              child: SizedBox(
                width: columnWidth,
                child: Builder(
                  key: ValueKey<String>('__measure_$i'),
                  builder: (BuildContext ctx) {
                    // 调度 post-frame 回调来测量
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _measureItem(ctx, i);
                    });
                    return widget.itemBuilder(ctx, widget.items[i], i);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 测量单个 item 的实际高度
  void _measureItem(BuildContext context, int index) {
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final height = renderBox.size.height;
    if (_measuredHeights[index] != height) {
      _measuredHeights[index] = height;

      // 当所有 item 都测量完毕，进入最终布局阶段
      if (_measuredHeights.length >= widget.items.length) {
        final heights = _getCachedHeights();
        _doLayout(_columnCount, heights);
        _isMeasuring = false;
        if (mounted) setState(() {});
      }
    }
  }

  /// 列宽计算
  double _columnWidth(double parentWidth, int columnCount) {
    return (parentWidth -
            (columnCount - 1) * _effectiveColumnSpacing) /
        columnCount;
  }

  /// 最终布局渲染
  Widget _buildFinalLayout(
    BuildContext context,
    int columnCount,
    double parentWidth,
    ParkThemeData park,
  ) {
    // 构建每列的内容
    final columns = List<Widget>.generate(columnCount, (colIdx) {
      final indices = _columnIndices[colIdx];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var j = 0; j < indices.length; j++) ...[
            if (j > 0) SizedBox(height: widget.spacing),
            widget.itemBuilder(context, widget.items[indices[j]], indices[j]),
          ],
        ],
      );
    });

    // 底部加载更多指示器
    Widget? footer;
    final l10n = ParkLocalizations.of(context);

    if (widget.loadingMore) {
      footer = Padding(
        padding: EdgeInsets.all(park.spacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: park.colors.textSecondary,
              ),
            ),
            SizedBox(width: park.spacing.sm),
            Text(
              l10n.loading,
              style: TextStyle(
                fontSize: park.typography.sizeCaption,
                color: park.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    } else if (widget.noMore && _effectiveItemCount > 0) {
      footer = Padding(
        padding: EdgeInsets.all(park.spacing.base),
        child: Center(
          child: Text(
            l10n.noMore,
            style: TextStyle(
              fontSize: park.typography.sizeCaption,
              color: park.colors.textPlaceholder,
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.zero,
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (var c = 0; c < columns.length; c++) ...[
                  if (c > 0) SizedBox(width: _effectiveColumnSpacing),
                  Expanded(
                    child: columns[c],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (footer != null)
          SliverToBoxAdapter(child: footer),
      ],
    );
  }
}
