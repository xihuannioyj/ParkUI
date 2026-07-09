import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/park_theme_data.dart';

/// 刷新状态
enum ParkRefreshState { idle, pulling, armed, refreshing, done }

/// ParkRefresh — 下拉刷新组件，基于 `NotificationListener<ScrollNotification>` 实现。
class ParkRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final double refreshThreshold;

  /// 是否在下拉刷新时触发触觉反馈（仅移动端）。
  final bool enableHapticFeedback;

  /// 自定义下拉刷新头部高度。
  final double headerHeight;

  /// Custom indicator builder per refresh state.
  final Widget Function(ParkRefreshState state)? headerBuilder;

  /// When true, supports pull-up from bottom to load more.
  final bool pullUpLoadMore;

  /// Callback for loading more content from the bottom.
  final Future<void> Function()? onLoadMore;

  /// Custom footer builder for load-more indicator.
  final Widget Function(ParkRefreshState state)? footerBuilder;

  /// When true, indicates there is no more data to load (disables load-more).
  final bool noMore;

  const ParkRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshThreshold = 80.0,
    this.enableHapticFeedback = true,
    this.headerHeight = 60.0,
    this.headerBuilder,
    this.pullUpLoadMore = false,
    this.onLoadMore,
    this.footerBuilder,
    this.noMore = false,
  });

  @override
  State<ParkRefresh> createState() => _ParkRefreshState();
}

class _ParkRefreshState extends State<ParkRefresh>
    with SingleTickerProviderStateMixin {
  ParkRefreshState _state = ParkRefreshState.idle;
  double _pullDistance = 0.0;
  late final AnimationController _doneController;
  late final Animation<double> _doneAnim;

  bool _isLoadingMore = false;
  double _bottomPullDistance = 0.0;

  bool get _isAtTop => _lastMetrics?.extentBefore == 0;
  bool get _isAtBottom => _lastMetrics != null && _lastMetrics!.extentAfter < 1.0;
  ScrollMetrics? _lastMetrics;

  @override
  void initState() {
    super.initState();
    _doneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _doneAnim =
        CurvedAnimation(parent: _doneController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _doneController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    _lastMetrics = notification.metrics;

    if (_state == ParkRefreshState.refreshing ||
        _state == ParkRefreshState.done) {
      return false;
    }

    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical ||
        !_isAtTop) {
      return false;
    }

    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        // Pull down from top
        final gain = 1.0 - (_pullDistance / (widget.refreshThreshold * 3));
        setState(() {
          _pullDistance += (-notification.overscroll * gain.clamp(0.2, 1.0));
          if (_pullDistance >= widget.refreshThreshold) {
            _state = ParkRefreshState.armed;
          } else {
            _state = ParkRefreshState.pulling;
          }
        });
      } else if (notification.overscroll > 0 && widget.pullUpLoadMore && _isAtBottom && !_isLoadingMore) {
        // Pull up from bottom
        setState(() {
          _bottomPullDistance += notification.overscroll;
          if (_bottomPullDistance >= widget.refreshThreshold) {
            _triggerLoadMore();
          }
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_pullDistance > 0) {
        if (_state == ParkRefreshState.armed) {
          _triggerRefresh();
        } else {
          _resetPull();
        }
      }
      if (_bottomPullDistance > 0 && !_isLoadingMore) {
        setState(() => _bottomPullDistance = 0.0);
      }
    }

    return false;
  }

  void _triggerRefresh() {
    setState(() => _state = ParkRefreshState.refreshing);

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    widget.onRefresh().then((_) async {
      if (!mounted) return;
      setState(() => _state = ParkRefreshState.done);
      await _doneController.forward(from: 0.0);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _resetPull();
        _doneController.reset();
      }
    }).catchError((_) {
      if (mounted) {
        _doneController.reset();
        _resetPull();
      }
    });
  }

  void _triggerLoadMore() {
    if (_isLoadingMore || widget.onLoadMore == null) return;
    setState(() => _isLoadingMore = true);

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    widget.onLoadMore!().then((_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _bottomPullDistance = 0.0;
      });
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _bottomPullDistance = 0.0;
        });
      }
    });
  }

  void _resetPull() {
    setState(() {
      _pullDistance = 0.0;
      _state = ParkRefreshState.idle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          // Main content with pull offset
          AnimatedContainer(
            duration: _state == ParkRefreshState.refreshing ||
                    _state == ParkRefreshState.done
                ? const Duration(milliseconds: 250)
                : Duration.zero,
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0,
              _indicatorHeight.clamp(0.0, widget.refreshThreshold * 1.5),
              0,
            ),
            child: widget.child,
          ),

          // Pull indicator (top)
          if (_pullDistance > 0 ||
              _state == ParkRefreshState.refreshing ||
              _state == ParkRefreshState.done)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _state == ParkRefreshState.done
                    ? Tween<double>(begin: 1.0, end: 0.0).animate(_doneAnim)
                    : const AlwaysStoppedAnimation(1.0),
                child: _buildIndicator(park),
              ),
            ),

          // Bottom load-more indicator
          if (_isLoadingMore)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: widget.headerHeight,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(park.colors.brand),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _indicatorHeight {
    if (_state == ParkRefreshState.refreshing) {
      return widget.refreshThreshold * 0.7;
    }
    return _pullDistance;
  }

  Widget _buildIndicator(ParkThemeData park) {
    final effectiveHeight = _indicatorHeight.clamp(0.0, widget.headerHeight * 1.5);
    return Container(
      height: effectiveHeight,
      alignment: Alignment.center,
      child: _buildIndicatorContent(park),
    );
  }

  Widget _buildIndicatorContent(ParkThemeData park) {
    // Use custom headerBuilder when provided
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(_state);
    }

    switch (_state) {
      case ParkRefreshState.idle:
        return Icon(
          Icons.arrow_downward_rounded,
          size: 20,
          color: park.colors.textSecondary,
        );
      case ParkRefreshState.pulling:
        return Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: park.colors.brand,
        );
      case ParkRefreshState.armed:
        return Icon(
          Icons.keyboard_double_arrow_up_rounded,
          size: 20,
          color: park.colors.brand,
        );
      case ParkRefreshState.refreshing:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(park.colors.brand),
          ),
        );
      case ParkRefreshState.done:
        return Icon(
          Icons.check_rounded,
          size: 20,
          color: park.colors.success,
        );
    }
  }
}
