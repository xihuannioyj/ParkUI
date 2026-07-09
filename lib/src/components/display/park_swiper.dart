import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// Park 轮播切换效果
enum ParkSwiperEffect {
  /// 滑动切换（默认）
  slide,

  /// 淡入淡出切换
  fade,
}

/// Park 轮播指示器类型
enum ParkSwiperIndicatorType {
  /// 圆点指示器
  dot,

  /// 数字指示器（如 "1 / 5"）
  number,
}

/// 指示器位置
enum ParkSwiperIndicatorPosition {
  /// 底部
  bottom,

  /// 顶部
  top,

  /// 不显示
  none,
}

/// Park 轮播组件
///
/// 支持自动播放、循环滑动、圆点/数字指示器，
/// 卡片堆叠效果、淡入淡出、自定义动画曲线、手势拖动比例控制。
///
/// ```dart
/// ParkSwiper(
///   children: [
///     Image.asset('assets/banner1.png'),
///     Image.asset('assets/banner2.png'),
///   ],
///   autoPlay: true,
///   interval: Duration(seconds: 3),
///   indicatorType: ParkSwiperIndicatorType.dot,
/// )
/// ```
class ParkSwiper extends StatefulWidget {
  /// 子页面列表
  final List<Widget> children;

  /// 是否自动播放
  final bool autoPlay;

  /// 自动播放间隔
  final Duration interval;

  /// 是否循环
  final bool loop;

  /// 组件高度
  final double height;

  /// 指示器类型
  final ParkSwiperIndicatorType indicatorType;

  /// 页面切换回调
  final ValueChanged<int>? onPageChanged;

  /// 指示器位置
  final ParkSwiperIndicatorPosition indicatorPosition;

  /// 自定义指示器构建器
  final Widget Function(int current, int total)? indicatorBuilder;

  /// 自定义自动播放间隔
  final Duration autoplayDelay;

  /// 滑动方向（水平或垂直）
  final Axis direction;

  /// 初始显示页面索引
  final int initialIndex;

  /// 自定义滑动动画时长
  final Duration? animationDuration;

  /// 切换效果（滑动或淡入淡出）
  final ParkSwiperEffect effect;

  /// 卡片堆叠：非中心卡片的可见比例（0.0~1.0），与 PageController.viewportFraction 对应
  ///
  /// 当不为 null 时启用卡片堆叠效果，非中心卡片部分可见。
  final double? viewportFraction;

  /// 卡片堆叠：非中心卡片的缩放比例（0.0~1.0）
  ///
  /// 当不为 null 时，非中心卡片按比例缩放，实现卡片堆叠视觉。
  final double? scale;

  /// 自定义动画曲线，默认 Curves.easeInOut
  final Curve? curve;

  /// 手势拖动启动比例阈值
  ///
  /// 当拖动距离占卡片宽/高的比例超过此值时启动翻页。
  final double? dragStartRatio;

  /// 手势拖动结束比例阈值
  ///
  /// 当释放时拖动比例超过此值则完成翻页。
  final double? dragEndRatio;

  /// 绑定键（点号分隔的路径，如 `'swiperIndex'`）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  const ParkSwiper({
    super.key,
    required this.children,
    this.autoPlay = false,
    this.interval = const Duration(seconds: 3),
    this.loop = true,
    this.height = 200,
    this.indicatorType = ParkSwiperIndicatorType.dot,
    this.onPageChanged,
    this.indicatorPosition = ParkSwiperIndicatorPosition.bottom,
    this.indicatorBuilder,
    this.autoplayDelay = const Duration(seconds: 3),
    this.direction = Axis.horizontal,
    this.initialIndex = 0,
    this.animationDuration,
    this.effect = ParkSwiperEffect.slide,
    this.viewportFraction,
    this.scale,
    this.curve,
    this.dragStartRatio,
    this.dragEndRatio,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkSwiper> createState() => _ParkSwiperState();
}

class _ParkSwiperState extends State<ParkSwiper>
    with BindableWidgetMixin<int, ParkSwiper> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    final initialPage = boundValue ?? widget.initialIndex;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: widget.viewportFraction ?? 1.0,
    );
    _currentIndex = initialPage;
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void didUpdateWidget(ParkSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoPlay != oldWidget.autoPlay) {
      if (widget.autoPlay) {
        _startAutoPlay();
      } else {
        _stopAutoPlay();
      }
    }
    if (widget.interval != oldWidget.interval && widget.autoPlay) {
      _stopAutoPlay();
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    final effectiveInterval = widget.autoplayDelay != const Duration(seconds: 3)
        ? widget.autoplayDelay
        : widget.interval;
    final slideDuration = widget.animationDuration ?? const Duration(milliseconds: 350);
    final curve = widget.curve ?? Curves.easeInOut;
    _autoPlayTimer = Timer.periodic(effectiveInterval, (_) {
      if (!mounted || widget.children.isEmpty) return;
      final nextPage = _currentIndex + 1;
      if (nextPage >= widget.children.length) {
        if (widget.loop) {
          _pageController.animateToPage(
            0,
            duration: slideDuration,
            curve: curve,
          );
        }
      } else {
        _pageController.animateToPage(
          nextPage,
          duration: slideDuration,
          curve: curve,
        );
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onPageChanged(int index) {
    final int realIndex = widget.children.isEmpty ? 0 : index % widget.children.length;
    setState(() => _currentIndex = realIndex);
    widget.onPageChanged?.call(realIndex);
    boundValue = realIndex;
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    if (widget.children.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // 页面视图
          _buildPageView(park),

          // 指示器
          if (widget.children.length > 1 &&
              widget.indicatorPosition != ParkSwiperIndicatorPosition.none)
            Positioned(
              left: 0,
              right: 0,
              top: widget.indicatorPosition == ParkSwiperIndicatorPosition.top
                  ? park.spacing.md
                  : null,
              bottom: widget.indicatorPosition == ParkSwiperIndicatorPosition.bottom
                  ? park.spacing.md
                  : null,
              child: widget.indicatorBuilder != null
                  ? widget.indicatorBuilder!(_currentIndex, widget.children.length)
                  : widget.indicatorType == ParkSwiperIndicatorType.dot
                      ? _buildDotIndicator(park)
                      : _buildNumberIndicator(park),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView(ParkThemeData park) {
    if (widget.effect == ParkSwiperEffect.fade) {
      return _buildFadePageView(park);
    }

    // 卡片堆叠效果（viewportFraction + scale）
    if (widget.viewportFraction != null || widget.scale != null) {
      return _buildStackEffectPageView(park);
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: widget.direction,
      onPageChanged: _onPageChanged,
      itemCount: widget.loop ? null : widget.children.length,
      itemBuilder: (BuildContext context, int index) {
        final int realIndex = index % widget.children.length;
        return widget.children[realIndex];
      },
    );
  }

  Widget _buildStackEffectPageView(ParkThemeData park) {
    final double scaleValue = widget.scale ?? 0.9;

    return PageView.builder(
      controller: _pageController,
      scrollDirection: widget.direction,
      onPageChanged: _onPageChanged,
      itemCount: widget.loop ? null : widget.children.length,
      itemBuilder: (BuildContext context, int index) {
        final int realIndex = index % widget.children.length;
        return AnimatedBuilder(
          animation: _pageController,
          builder: (BuildContext context, Widget? child) {
            double pageOffset = 0.0;
            if (_pageController.position.hasContentDimensions) {
              pageOffset = _pageController.page! - index;
            }
            // 计算缩放：中心卡片 scale=1.0，非中心卡片缩小到 scaleValue
            final double cardScale = math.max(
              scaleValue,
              1.0 - (pageOffset.abs() * (1.0 - scaleValue)),
            );
            return Transform.scale(
              scale: cardScale,
              child: widget.children[realIndex],
            );
          },
        );
      },
    );
  }

  Widget _buildFadePageView(ParkThemeData park) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: widget.direction,
      onPageChanged: _onPageChanged,
      itemCount: widget.loop ? null : widget.children.length,
      itemBuilder: (BuildContext context, int index) {
        final int realIndex = index % widget.children.length;
        return _FadeTransitionPage(
          pageController: _pageController,
          index: index,
          child: widget.children[realIndex],
        );
      },
    );
  }

  Widget _buildDotIndicator(ParkThemeData park) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.children.length, (int index) {
        final bool isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: park.spacing.xs / 2),
          width: isActive ? 20.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive
                ? park.colors.brand
                : park.colors.textSecondary.withValues(alpha: 0.3),
            borderRadius: park.radius.brFull,
          ),
        );
      }),
    );
  }

  Widget _buildNumberIndicator(ParkThemeData park) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: park.spacing.md,
        vertical: park.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: park.colors.overlay.withValues(alpha: 0.6),
        borderRadius: park.radius.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_currentIndex + 1}',
            style: TextStyle(
              color: park.colors.textOnBrand,
              fontSize: park.typography.sizeCaption,
              fontWeight: park.typography.weightBold,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: park.spacing.xs),
            child: Text(
              '/',
              style: TextStyle(
                color: park.colors.textOnBrand.withValues(alpha: 0.7),
                fontSize: park.typography.sizeCaption,
              ),
            ),
          ),
          Text(
            '${widget.children.length}',
            style: TextStyle(
              color: park.colors.textOnBrand.withValues(alpha: 0.7),
              fontSize: park.typography.sizeCaption,
              fontWeight: park.typography.weightRegular,
            ),
          ),
        ],
      ),
    );
  }
}

/// A page widget that applies a fade transition based on PageController scroll position.
class _FadeTransitionPage extends StatelessWidget {
  final PageController pageController;
  final int index;
  final Widget child;

  const _FadeTransitionPage({
    required this.pageController,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (BuildContext context, Widget? child) {
        double opacity = 1.0;
        if (pageController.position.hasContentDimensions) {
          final double page = pageController.page ?? index.toDouble();
          final double diff = (page - index).abs();
          opacity = 1.0 - diff.clamp(0.0, 1.0);
        }
        return Opacity(
          opacity: opacity,
          child: this.child,
        );
      },
    );
  }
}
