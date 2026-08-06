import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import 'park_refresh.dart';

/// 统一页面刷新包装器。
///
/// 约定：
/// - 下拉刷新统一使用 [ParkRefresh]
/// - 上拉加载更多统一走 [pullUpLoadMore] + [onLoadMore]
/// - 页面仅负责自己的列表/滚动内容，不再各自拼装刷新标准
class ParkRefreshView extends StatelessWidget {
  /// 下拉刷新回调。
  final Future<void> Function() onRefresh;

  /// 页面滚动内容。
  final Widget child;

  /// 是否启用上拉加载更多。
  final bool pullUpLoadMore;

  /// 上拉加载更多回调。
  final Future<void> Function()? onLoadMore;

  /// 是否无更多数据。
  final bool noMore;

  /// 自定义下拉触发阈值。
  final double refreshThreshold;

  /// 自定义头部高度。
  final double headerHeight;

  /// 是否强制使用原生刷新组件。
  ///
  /// 说明：
  /// - 默认继续走 [ParkRefresh]；
  /// - 对 `CustomScrollView + sliver` 这类场景，如果 [ParkRefresh] 无法稳定触发，
  ///   可切到原生 `RefreshIndicator` 作为兼容实现；
  /// - 这样页面层仍然统一走 [ParkRefreshView]，不再各自拼装刷新逻辑。
  final bool useMaterialRefreshIndicator;

  /// 原生刷新组件的位移距离。
  final double materialDisplacement;

  const ParkRefreshView({
    super.key,
    required this.onRefresh,
    required this.child,
    this.pullUpLoadMore = false,
    this.onLoadMore,
    this.noMore = false,
    this.refreshThreshold = 72,
    this.headerHeight = 56,
    this.useMaterialRefreshIndicator = false,
    this.materialDisplacement = 56,
  });

  @override
  Widget build(BuildContext context) {
    if (useMaterialRefreshIndicator) {
      final park =
          Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: park.colors.brand,
        backgroundColor: park.colors.surface,
        displacement: materialDisplacement,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        child: child,
      );
    }

    return ParkRefresh(
      onRefresh: onRefresh,
      pullUpLoadMore: pullUpLoadMore,
      onLoadMore: onLoadMore,
      noMore: noMore,
      refreshThreshold: refreshThreshold,
      headerHeight: headerHeight,
      child: child,
    );
  }
}
