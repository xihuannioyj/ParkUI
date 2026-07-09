import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';

/// 搜索框尺寸枚举
enum ParkSearchSize {
  /// 小尺寸 — 高度 32px
  small,

  /// 中尺寸（默认）— 高度 40px
  medium,

  /// 大尺寸 — 高度 48px
  large,
}

/// 搜索框形状枚举
enum ParkSearchShape {
  /// 胶囊形（默认）
  capsule,

  /// 方形（小圆角）
  square,
}

/// Park UI 搜索框
///
/// 胶囊形搜索输入框，支持搜索图标前缀、清除按钮、取消按钮等功能。
/// 常用于页面顶部的搜索场景。
///
/// ```dart
/// ParkSearch(
///   hintText: '搜索',
///   onChanged: (v) => print(v),
///   showCancel: true,
/// )
/// ```
class ParkSearch extends StatefulWidget {
  const ParkSearch({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.showCancel = false,
    this.loading = false,
    this.disabled = false,
    this.size = ParkSearchSize.medium,
    this.shape = ParkSearchShape.capsule,
    this.actionText,
    this.onSearch,
    this.maxLength,
    this.clearable = true,
    this.bindKey,
    this.bindingService,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool showCancel;

  /// 是否处于加载状态。为 true 时搜索图标替换为加载指示器。
  /// 默认 false。
  final bool loading;

  /// 是否禁用。为 true 时渲染禁用样式，不可交互。
  /// 默认 false。
  final bool disabled;

  /// 搜索框尺寸，控制高度。默认 [ParkSearchSize.medium]。
  final ParkSearchSize size;

  /// 搜索框形状。默认 [ParkSearchShape.capsule]（胶囊形）。
  final ParkSearchShape shape;

  /// 搜索按钮自定义文字。设置后在搜索框右侧显示文字按钮。
  final String? actionText;

  /// 搜索回调（与 onSubmitted 等价，兼容 AntD 命名）
  final ValueChanged<String>? onSearch;

  /// 最大输入长度
  final int? maxLength;

  /// 是否显示清除按钮。默认 true。
  final bool clearable;

  /// 绑定键（点号分隔的路径，如 `'searchText'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  @override
  State<ParkSearch> createState() => _ParkSearchState();
}

class _ParkSearchState extends State<ParkSearch>
    with BindableWidgetMixin<String, ParkSearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showCancel = false;
  VoidCallback? _bindingSyncListener;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    // 从 bindable 读取初始值
    final initialValue = boundValue;
    if (initialValue != null) {
      _controller.text = initialValue;
    }
    // 监听外部绑定值变化，同步到 TextEditingController
    _bindingSyncListener = () {
      if (mounted) {
        final newValue = boundValue;
        if (newValue != null && _controller.text != newValue) {
          _controller.text = newValue;
        }
      }
    };
    boundListenable.addListener(_bindingSyncListener!);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    if (widget.autofocus && !widget.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (_bindingSyncListener != null) {
      boundListenable.removeListener(_bindingSyncListener!);
      _bindingSyncListener = null;
    }
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showCancel = _focusNode.hasFocus;
    });
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    boundValue = '';
  }

  void _cancel() {
    _clear();
    _focusNode.unfocus();
  }

  void _onActionTap() {
    if (widget.disabled || widget.loading) return;
    widget.onSubmitted?.call(_controller.text);
    widget.onSearch?.call(_controller.text);
    boundValue = _controller.text;
  }

  double get _height {
    switch (widget.size) {
      case ParkSearchSize.small:
        return 32;
      case ParkSearchSize.medium:
        return 40;
      case ParkSearchSize.large:
        return 48;
    }
  }

  double get _fontSize {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    switch (widget.size) {
      case ParkSearchSize.small:
        return park.typography.sizeBodySmall;
      case ParkSearchSize.medium:
        return park.typography.sizeBody;
      case ParkSearchSize.large:
        return park.typography.sizeH3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final isDisabled = widget.disabled;

    final borderRadius = widget.shape == ParkSearchShape.capsule
        ? park.radius.brFull
        : park.radius.brSm;

    final bgColor =
        isDisabled ? park.colors.disabledBg : park.colors.disabledBg;
    final textColor =
        isDisabled ? park.colors.textDisabled : park.colors.textPrimary;
    final placeholderColor =
        isDisabled ? park.colors.textDisabled : park.colors.textPlaceholder;

    // Leading icon: loading spinner or search icon
    Widget leadingIcon;
    if (widget.loading) {
      leadingIcon = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(park.colors.brand),
        ),
      );
    } else {
      leadingIcon = Icon(
        CupertinoIcons.search,
        size: 18,
        color: isDisabled ? park.colors.textDisabled : park.colors.textPlaceholder,
      );
    }

    return IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: ParkMotion.standard,
                height: _height,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: borderRadius,
                ),
                child: Row(
                  children: [
                    SizedBox(width: park.spacing.md),
                    leadingIcon,
                    SizedBox(width: park.spacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: widget.autofocus && !isDisabled,
                        enabled: !isDisabled,
                        maxLength: widget.maxLength,
                        style: park.typography.body.copyWith(
                          fontSize: _fontSize,
                          color: textColor,
                        ),
                        cursorColor: park.colors.brand,
                        onChanged: (v) {
                          widget.onChanged?.call(v);
                          boundValue = v;
                        },
                        onSubmitted: (v) {
                          widget.onSubmitted?.call(v);
                          widget.onSearch?.call(v);
                          boundValue = v;
                        },
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: park.typography.body.copyWith(
                            fontSize: _fontSize,
                            color: placeholderColor,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: park.spacing.xs,
                            vertical: 0,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (widget.clearable && _controller.text.isNotEmpty && !isDisabled)
                      GestureDetector(
                        onTap: _clear,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: park.spacing.sm,
                          ),
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 18,
                            color: park.colors.textPlaceholder,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Action text button
            if (widget.actionText != null) ...[
              SizedBox(width: park.spacing.sm),
              GestureDetector(
                onTap: widget.loading ? null : _onActionTap,
                child: Container(
                  height: _height,
                  padding: EdgeInsets.symmetric(horizontal: park.spacing.base),
                  decoration: BoxDecoration(
                    color: park.colors.brand,
                    borderRadius: borderRadius,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.actionText!,
                    style: park.typography.body.copyWith(
                      fontSize: _fontSize,
                      color: park.colors.textOnBrand,
                      fontWeight: park.typography.weightMedium,
                    ),
                  ),
                ),
              ),
            ],
            // Cancel button
            if (widget.showCancel && _showCancel && !isDisabled) ...[
              SizedBox(width: park.spacing.sm),
              GestureDetector(
                onTap: _cancel,
                child: Text(
                  '取消',
                  style: park.typography.body.copyWith(
                    color: park.colors.brand,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
