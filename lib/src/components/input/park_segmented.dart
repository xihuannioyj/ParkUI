import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// ParkSegmented 尺寸
enum ParkSegmentedSize {
  /// 小尺寸
  small,

  /// 中尺寸
  medium,

  /// 大尺寸
  large,
}

/// ParkSegmented 选项数据
class ParkSegmentedItem {
  /// 选项值
  final String value;

  /// 显示文字
  final String? label;

  /// 可选图标
  final IconData? icon;

  /// 是否禁用
  final bool disabled;

  /// 角标计数，为 null 时不显示
  final int? badge;

  const ParkSegmentedItem({
    required this.value,
    this.label,
    this.icon,
    this.disabled = false,
    this.badge,
  });
}

/// ParkSegmented — 分段控制器
///
/// 在一组互斥的选项中切换，选中态有滑块动画过渡。
/// 支持图标+文字或纯图标模式，支持 block 撑满宽度。
///
/// 受控 / 非受控统一：内部维护 [_selectedValue]，初值取
/// `widget.value ?? items.first.value`；所有视觉判定统一走
/// `widget.value ?? _selectedValue`；外部 [value] 变化经 [didUpdateWidget] 同步。
///
/// ```dart
/// ParkSegmented(
///   items: [
///     ParkSegmentedItem(value: 'day', label: '日'),
///     ParkSegmentedItem(value: 'week', label: '周'),
///     ParkSegmentedItem(value: 'month', label: '月'),
///   ],
///   value: 'day',
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkSegmented extends StatefulWidget {
  /// 选项列表
  final List<ParkSegmentedItem> items;

  /// 当前选中值（单选模式）。为 null 时进入非受控模式。
  final String? value;

  /// 当前多选值（多选模式）
  final List<String>? multiValues;

  /// 选中值变更回调（单选模式）
  final ValueChanged<String>? onChanged;

  /// 多选变更回调（多选模式）
  final ValueChanged<List<String>>? onMultiChanged;

  /// 是否整体禁用
  final bool disabled;

  /// 尺寸
  final ParkSegmentedSize size;

  /// 是否撑满宽度
  final bool block;

  /// 是否允许多选
  final bool multiSelect;

  /// 自定义选项渲染器
  final Widget Function(ParkSegmentedItem item, bool isSelected)? optionBuilder;

  /// 绑定键（点号分隔的路径，如 `'segmentValue'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  const ParkSegmented({
    super.key,
    required this.items,
    this.value,
    this.multiValues,
    this.onChanged,
    this.onMultiChanged,
    this.disabled = false,
    this.size = ParkSegmentedSize.medium,
    this.block = false,
    this.multiSelect = false,
    this.optionBuilder,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkSegmented> createState() => _ParkSegmentedState();
}

class _ParkSegmentedState extends State<ParkSegmented>
    with BindableWidgetMixin<dynamic, ParkSegmented> {
  /// 内部选中值（非受控模式下的真实数据源）。
  late String _selectedValue;

  /// 每个 item 的 GlobalKey，用于首帧测量真实宽度（非 block 模式）。
  late List<GlobalKey> _itemKeys;

  /// 每个 item 的测量宽度（非 block 模式滑块定位依据）。
  late List<double> _measuredWidths;

  /// 解析当前选中值：受控优先，否则取内部值。
  String _resolveSelected() => widget.value ?? _selectedValue;

  /// 单项宽度的首帧估值（在真实测量完成前使用，避免滑块初始错位）。
  double _estimateItemWidth(double hPadding) => hPadding * 2 + 60;

  /// 取第 i 项的有效宽度（测量值优先，否则估值）。
  double _itemWidth(int i, double hPadding) {
    if (i < 0 || i >= _measuredWidths.length) return _estimateItemWidth(hPadding);
    final double w = _measuredWidths[i];
    return w > 0 ? w : _estimateItemWidth(hPadding);
  }

  /// 计算非 block 模式下滑块左偏移：前序各项宽度之和。
  double _sliderLeft(int index, double hPadding) {
    double left = 0;
    for (int i = 0; i < index; i++) {
      left += _itemWidth(i, hPadding);
    }
    return left;
  }

  /// Check if an item is selected (supports both single and multi mode)
  bool _isSelected(ParkSegmentedItem item) {
    if (widget.multiSelect) {
      return widget.multiValues != null &&
          widget.multiValues!.contains(item.value);
    }
    return item.value == _resolveSelected();
  }

  void _onItemTap(ParkSegmentedItem item) {
    if (widget.multiSelect) {
      final current = widget.multiValues != null
          ? List<String>.from(widget.multiValues!)
          : <String>[];
      if (current.contains(item.value)) {
        current.remove(item.value);
      } else {
        current.add(item.value);
      }
      widget.onMultiChanged?.call(current);
      boundValue = current;
    } else {
      // 先更新内部状态（无论父组件是否维护 value，视觉即时更新）
      setState(() => _selectedValue = item.value);
      widget.onChanged?.call(item.value);
      boundValue = item.value;
    }
  }

  /// 首帧测量各项真实宽度，驱动滑块精确定位。
  void _measureItemWidths() {
    if (!mounted) return;
    bool changed = false;
    for (int i = 0; i < _itemKeys.length; i++) {
      final BuildContext? ctx = _itemKeys[i].currentContext;
      if (ctx != null && ctx.size != null) {
        final double w = ctx.size!.width;
        if (w > 0 && (_measuredWidths[i] - w).abs() > 0.01) {
          _measuredWidths[i] = w;
          changed = true;
        }
      }
    }
    if (changed && mounted) setState(() {});
  }

  void _initKeys() {
    _itemKeys = List<GlobalKey>.generate(
      widget.items.length,
      (_) => GlobalKey(),
    );
    _measuredWidths = List<double>.generate(
      widget.items.length,
      (_) => 0,
    );
  }

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    // 确定初始选中值：bindable 优先，其次 widget.value，最后第一项
    if (!widget.multiSelect) {
      final bindValue = boundValue;
      if (bindValue is String && widget.value == null) {
        _selectedValue = bindValue;
      } else {
        _selectedValue = widget.value ??
            (widget.items.isNotEmpty ? widget.items.first.value : '');
      }
    } else {
      _selectedValue = widget.value ??
          (widget.items.isNotEmpty ? widget.items.first.value : '');
    }
    _initKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemWidths());
  }

  @override
  void didUpdateWidget(covariant ParkSegmented oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 选项数量变化：重建 key 与测量缓冲。
    if (widget.items.length != oldWidget.items.length) {
      _initKeys();
    }
    // 外部 value 变化：同步内部选中值（受控模式）。
    if (widget.value != null && widget.value != _selectedValue) {
      setState(() => _selectedValue = widget.value!);
    }
    // 布局可能变化，重新测量项宽。
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureItemWidths());
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final radius = park.radius;
    final spacing = park.spacing;

    // Size mapping
    final double itemHeight;
    final double fontSize;
    final double iconSize;
    final double hPadding;

    switch (widget.size) {
      case ParkSegmentedSize.small:
        itemHeight = 28;
        fontSize = 12;
        iconSize = 14;
        hPadding = spacing.sm;
      case ParkSegmentedSize.medium:
        itemHeight = 36;
        fontSize = 14;
        iconSize = 16;
        hPadding = spacing.base;
      case ParkSegmentedSize.large:
        itemHeight = 44;
        fontSize = 16;
        iconSize = 18;
        hPadding = spacing.lg;
    }

    final selectedIndex = widget.multiSelect
        ? -1
        : widget.items.indexWhere(
            (item) => item.value == _resolveSelected(),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemWidth = widget.block
            ? totalWidth / widget.items.length
            : null;

        // 滑块定位参数（非 block 用测量宽，block 用等分宽）。
        final double sliderLeft;
        final double sliderWidth;
        if (widget.block) {
          sliderLeft = selectedIndex >= 0 ? selectedIndex * itemWidth! : 0;
          sliderWidth = itemWidth ?? 0;
        } else {
          sliderLeft = selectedIndex >= 0
              ? _sliderLeft(selectedIndex, hPadding)
              : 0;
          sliderWidth = selectedIndex >= 0
              ? _itemWidth(selectedIndex, hPadding)
              : 0;
        }

        return Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: colors.disabledBg,
            borderRadius: radius.brSm,
          ),
          child: Stack(
            children: [
              // Animated slider (single-select only)
              if (!widget.multiSelect && selectedIndex >= 0)
                AnimatedPositioned(
                  duration: park.motion.standard,
                  curve: park.motion.enterEasing,
                  left: sliderLeft,
                  top: 2,
                  bottom: 2,
                  width: sliderWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: radius.brXs,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

              // Items
              Row(
                mainAxisSize:
                    widget.block ? MainAxisSize.max : MainAxisSize.min,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = _isSelected(item);
                  final isDisabled = widget.disabled || item.disabled;

                  // Use custom optionBuilder if provided
                  if (widget.optionBuilder != null) {
                    final customContent =
                        widget.optionBuilder!(item, isSelected);

                    final badgeWidget = _buildBadge(item, park);

                    return GestureDetector(
                      key: _itemKeys[index],
                      onTap: isDisabled ? null : () => _onItemTap(item),
                      behavior: HitTestBehavior.opaque,
                      child: Opacity(
                        opacity: isDisabled ? 0.4 : 1.0,
                        child: Container(
                          width: itemWidth,
                          padding: itemWidth == null
                              ? EdgeInsets.symmetric(horizontal: hPadding)
                              : null,
                          alignment: Alignment.center,
                          child: badgeWidget != null
                              ? Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    customContent,
                                    Positioned(
                                      right: -6,
                                      top: -4,
                                      child: badgeWidget,
                                    ),
                                  ],
                                )
                              : customContent,
                        ),
                      ),
                    );
                  }

                  final textColor = isDisabled
                      ? colors.textDisabled
                      : (widget.multiSelect && isSelected)
                          ? colors.brand
                          : isSelected
                              ? colors.textPrimary
                              : colors.textSecondary;

                  final fontWeight = isSelected
                      ? park.typography.weightMedium
                      : park.typography.weightRegular;

                  Widget content;
                  if (item.icon != null && item.label != null) {
                    content = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: iconSize, color: textColor),
                        SizedBox(width: spacing.xs),
                        Text(
                          item.label!,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: textColor,
                            fontWeight: fontWeight,
                          ),
                        ),
                      ],
                    );
                  } else if (item.icon != null) {
                    content =
                        Icon(item.icon, size: iconSize, color: textColor);
                  } else {
                    content = Text(
                      item.label ?? item.value,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                        fontWeight: fontWeight,
                      ),
                    );
                  }

                  // Multi-select background highlight
                  final multiSelectBg = widget.multiSelect && isSelected
                      ? colors.brand.withValues(alpha: 0.1)
                      : null;

                  final badgeWidget = _buildBadge(item, park);

                  final itemContent = Container(
                    width: itemWidth,
                    padding: itemWidth == null
                        ? EdgeInsets.symmetric(horizontal: hPadding)
                        : null,
                    alignment: Alignment.center,
                    decoration: multiSelectBg != null
                        ? BoxDecoration(
                            color: multiSelectBg,
                            borderRadius: radius.brXs,
                          )
                        : null,
                    child: content,
                  );

                  final itemWidget = GestureDetector(
                    key: _itemKeys[index],
                    onTap: isDisabled
                        ? null
                        : () => _onItemTap(item),
                    behavior: HitTestBehavior.opaque,
                    child: badgeWidget != null
                        ? Stack(
                            clipBehavior: Clip.none,
                            children: [
                              itemContent,
                              Positioned(
                                right: -6,
                                top: -4,
                                child: badgeWidget,
                              ),
                            ],
                          )
                        : itemContent,
                  );

                  return itemWidget;
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build badge widget for a segment item, returns null if no badge.
  Widget? _buildBadge(ParkSegmentedItem item, ParkThemeData park) {
    if (item.badge == null) return null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: park.spacing.xs, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: park.colors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        item.badge! > 99 ? '99+' : '${item.badge!}',
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: park.typography.weightMedium,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
