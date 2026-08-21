import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';
import 'park_skeleton.dart';

/// ParkList item layout direction.
///
/// Controls whether item avatar/image is displayed beside (horizontal)
/// or above (vertical) the content.
enum ParkListItemLayout { horizontal, vertical }

/// ParkList — 虚拟滚动列表组件
///
/// 当 [itemExtent] 不为空时使用 [ListView.builder] 虚拟化渲染，
/// 为空时使用普通 [ListView] 自动高度。
/// 支持分割线、头部/底部、空状态、加载态和"加载更多"展示。
///
/// ```dart
/// ParkList<String>(
///   items: ['A', 'B', 'C'],
///   itemBuilder: (context, item, index) => ListTile(title: Text(item)),
///   split: true,
///   header: Text('列表头部'),
///   footer: Text('列表底部'),
///   loading: false,
///   loadMore: ElevatedButton(onPressed: () {}, child: Text('加载更多')),
/// )
/// ```
class ParkList<T> extends StatefulWidget {
  /// 数据列表
  final List<T> items;

  /// 列表项构建器
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 是否显示分割线
  final bool divided;

  /// 列表内边距
  final EdgeInsetsGeometry? padding;

  /// 头部 Widget
  final Widget? header;

  /// 底部 Widget
  final Widget? footer;

  /// 空状态 Widget
  final Widget? emptyWidget;

  /// 固定行高（不为空时启用虚拟化）
  final double? itemExtent;

  /// 滚动控制器
  final ScrollController? controller;

  /// 滚动方向
  final Axis scrollDirection;

  /// 是否反向
  final bool reverse;

  /// 是否处于加载状态（显示骨架屏占位项）
  final bool loading;

  /// 骨架屏占位项数量（loading 为 true 时生效）
  final int loadingItemCount;

  /// "加载更多" Widget（显示在列表底部、footer 之上）
  final Widget? loadMore;

  /// 列表项布局方向（horizontal: 头像在旁，vertical: 头像在上）
  final ParkListItemLayout itemLayout;

  /// 是否显示分割线（与 [divided] 等效）
  final bool split;

  /// 上拉加载更多回调，当列表滚动到底部时触发
  ///
  /// 与 [loadMore] widget 插槽并存：[loadMore] 插槽优先级最高。
  final Future<void> Function()? onLoadMore;

  /// 是否正在加载更多，为 true 时显示底部 loading 指示器
  final bool loadingMore;

  /// 是否已无更多数据，为 true 时显示"已加载全部"提示
  final bool noMore;

  const ParkList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.divided = false,
    this.padding,
    this.header,
    this.footer,
    this.emptyWidget,
    this.itemExtent,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.loading = false,
    this.loadingItemCount = 3,
    this.loadMore,
    this.itemLayout = ParkListItemLayout.horizontal,
    this.split = true,
    this.onLoadMore,
    this.loadingMore = false,
    this.noMore = false,
  });

  /// Whether dividers should be shown (divided OR split)
  bool get _showDividers => divided || split;

  @override
  State<ParkList<T>> createState() => _ParkListState<T>();
}

class _ParkListState<T> extends State<ParkList<T>> {
  ScrollController? _internalController;
  ScrollController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = ScrollController();
    }
    _effectiveController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ParkList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // Remove listener from old controller
      final ScrollController? oldController =
          oldWidget.controller ?? _internalController;
      oldController?.removeListener(_onScroll);
      // If old widget used an internal controller and new one provides external, dispose it
      if (oldWidget.controller == null && widget.controller != null) {
        _internalController?.dispose();
        _internalController = null;
      }
      // If new widget has no external controller, create internal one
      if (widget.controller == null && _internalController == null) {
        _internalController = ScrollController();
      }
      // Add listener to new controller
      _effectiveController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onScroll);
    _internalController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onLoadMore == null || widget.loadingMore || widget.noMore) {
      return;
    }
    if (!_effectiveController.hasClients) return;

    final maxScroll = _effectiveController.position.maxScrollExtent;
    final currentScroll = _effectiveController.position.pixels;
    // 边界防御：内容不足一屏时 maxScrollExtent == 0，任意滚动都会满足差值，
    // 反复触发 onLoadMore。
    if (maxScroll <= 0) return;
    // 当滚动到距离底部 100px 内时触发加载更多
    if (maxScroll - currentScroll <= 100.0) {
      widget.onLoadMore!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    if (widget.items.isEmpty && !widget.loading) {
      return _buildEmpty(park);
    }

    final children = <Widget>[];

    if (widget.header != null) {
      children.add(widget.header!);
    }

    Widget listView;
    if (widget.loading) {
      // Show skeleton items
      listView = _buildSkeletonList(park);
    } else if (widget.itemExtent != null) {
      // Virtualized mode — shrinkWrap intentionally omitted to preserve
      // lazy building (R3-23). Parent Expanded widget provides bounded height.
      listView = ListView.builder(
        controller: _effectiveController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        itemCount: widget.items.length,
        itemExtent: widget.itemExtent,
        itemBuilder: (BuildContext context, int index) {
          final T item = widget.items[index];
          return _wrapWithDivider(
            widget.itemBuilder(context, item, index),
            index,
            park,
          );
        },
      );
    } else {
      // Auto-height mode
      listView = ListView(
        controller: _effectiveController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.items.asMap().entries.map((MapEntry<int, T> entry) {
          final int index = entry.key;
          final T item = entry.value;
          return _wrapWithDivider(
            widget.itemBuilder(context, item, index),
            index,
            park,
          );
        }).toList(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentChildren = <Widget>[...children];
        final shouldExpandList = constraints.hasBoundedHeight;

        contentChildren.add(
          shouldExpandList ? Expanded(child: listView) : listView,
        );

        // onLoadMore / loadingMore / noMore 状态底部指示器
        if (widget.onLoadMore != null) {
          if (widget.loadingMore) {
            contentChildren.add(_buildLoadingMoreIndicator(park));
          } else if (widget.noMore && widget.items.isNotEmpty) {
            contentChildren.add(_buildNoMoreIndicator(park));
          }
        }

        if (widget.loadMore != null) {
          contentChildren.add(widget.loadMore!);
        }

        if (widget.footer != null) {
          contentChildren.add(widget.footer!);
        }

        return Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: contentChildren,
          ),
        );
      },
    );
  }

  Widget _buildLoadingMoreIndicator(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.loading,
      container: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: park.spacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(park.colors.brand),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.loading,
              style: TextStyle(
                fontSize: park.typography.sizeCaption,
                color: park.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMoreIndicator(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.loadedAllData,
      container: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: park.spacing.sm),
        child: Center(
          child: Text(
            l10n.loadedAllData,
            style: TextStyle(
              fontSize: park.typography.sizeCaption,
              color: park.colors.textPlaceholder,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList(ParkThemeData park) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.loadingItemCount,
      itemBuilder: (BuildContext context, int index) {
        return _wrapWithDivider(
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: park.spacing.base,
              vertical: park.spacing.sm,
            ),
            child: Row(
              children: [
                ParkSkeleton.avatar(size: 40),
                SizedBox(width: park.spacing.md),
                Expanded(child: ParkSkeleton.text(lines: 2)),
              ],
            ),
          ),
          index,
          park,
        );
      },
    );
  }

  Widget _wrapWithDivider(Widget child, int index, ParkThemeData park) {
    final semanticallyWrapped = Semantics(
      container: true,
      child: child,
    );
    if (!widget._showDividers || index == 0) return semanticallyWrapped;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: park.colors.divider),
        semanticallyWrapped,
      ],
    );
  }

  Widget _buildEmpty(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    final content =
        widget.emptyWidget ??
        Semantics(
          label: l10n.noData,
          container: true,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(park.spacing.xl),
              child: Text(
                l10n.noData,
                style: TextStyle(
                  fontSize: park.typography.sizeBody,
                  color: park.colors.textPlaceholder,
                ),
              ),
            ),
          ),
        );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [?widget.header, content, ?widget.loadMore, ?widget.footer],
      ),
    );
  }
}
