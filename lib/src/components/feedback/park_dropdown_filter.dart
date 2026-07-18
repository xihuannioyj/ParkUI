import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';
import 'park_dropdown_sheet.dart';

// ============================================================================
// 数据模型
// ============================================================================

/// 筛选选项数据模型
class DropdownFilterOption {
  /// 显示文字
  final String label;

  /// 选项值
  final String value;

  /// 子标题
  final String? subtitle;

  /// 前置图标
  final Widget? leading;

  /// 是否禁用
  final bool disabled;

  const DropdownFilterOption({
    required this.label,
    required this.value,
    this.subtitle,
    this.leading,
    this.disabled = false,
  });
}

/// 筛选标签项配置
class DropdownFilterItem {
  /// 标签文字（如 "租赁状态"）
  final String label;

  /// 预定义选项列表（与 [child] 互斥，[child] 优先）
  final List<DropdownFilterOption>? options;

  /// 完全自定义面板内容（与 [options] 互斥）
  final Widget? child;

  /// 是否多选（仅 options 模式有效）
  final bool multiple;

  /// 网格列数（>1 时使用网格布局）
  final int columns;

  /// 面板自定义高度
  final double? height;

  /// 是否必须选中至少一项才能确认
  final bool isCheck;

  /// 点击标签回调，返回 true 阻止默认展开行为
  final bool Function()? onTab;

  /// 选项变化回调
  @Deprecated('Use onChanged instead')
  final void Function(Set<String> selected)? onChange;

  /// 选项变化回调
  final void Function(Set<String> selected)? onChanged;

  /// 内部使用的有效回调：优先使用 onChanged，回退到 onChange。
  void Function(Set<String> selected)? get _effectiveOnChanged =>
      onChanged ?? onChange;

  /// 确认回调
  final void Function(Set<String> selected)? onConfirm;

  /// 重置/取消回调
  final VoidCallback? onReset;

  /// 当前选中值（受控）
  final Set<String>? selectedValues;

  /// 当前标签是否禁用
  final bool disabled;

  const DropdownFilterItem({
    required this.label,
    this.options,
    this.child,
    this.multiple = false,
    this.columns = 1,
    this.height,
    this.isCheck = false,
    this.onTab,
    // ignore: deprecated_member_use_from_same_package
    this.onChange,
    this.onChanged,
    this.onConfirm,
    this.onReset,
    this.selectedValues,
    this.disabled = false,
  });
}

/// 筛选栏样式配置
class DropdownFilterStyle {
  /// 标签默认文字颜色
  final Color? textColor;

  /// 标签选中/展开时文字颜色（默认品牌色）
  final Color? activeColor;

  /// 标签默认文字粗细
  final FontWeight? fontWeight;

  /// 标签选中时文字粗细（默认 bold）
  final FontWeight? activeFontWeight;

  /// 底部下划线颜色（默认品牌色）
  final Color? underlineColor;

  /// 箭头图标颜色
  final Color? arrowColor;

  /// 标签背景色
  final Color? backgroundColor;

  /// 标签圆角
  final double? borderRadius;

  /// 标签高度
  final double? labelHeight;

  const DropdownFilterStyle({
    this.textColor,
    this.activeColor,
    this.fontWeight,
    this.activeFontWeight,
    this.underlineColor,
    this.arrowColor,
    this.backgroundColor,
    this.borderRadius,
    this.labelHeight,
  });
}

// ============================================================================
// ParkDropdownFilter — 顶部横向筛选下拉栏
// ============================================================================

/// ParkDropdownFilter — 顶部横向筛选下拉栏
///
/// 一行水平排列筛选标签，每个标签点击后弹出独立的底部抽屉面板。
/// 适用于列表头部「状态 ▼  来源 ▼  时间 ▼」筛选场景。
///
/// 每个标签 ([DropdownFilterItem]) 可配置：
/// - 预定义选项列表（单选/多选、列表/网格）
/// - 完全自定义 child Widget
/// - 独立的 onTab / onChange / onConfirm / onReset 回调
class ParkDropdownFilter extends StatefulWidget {
  /// 筛选标签列表
  final List<DropdownFilterItem> items;

  /// 标签之间的间距
  final double spacing;

  /// 标签内边距
  final EdgeInsetsGeometry? labelPadding;

  /// 是否允许溢出滚动
  final bool scrollable;

  /// 标签栏样式定制
  final DropdownFilterStyle? style;

  /// 整体选中值变更回调（统一监听所有标签的变化）
  final void Function(int index, Set<String> selected)? onFilterChanged;

  const ParkDropdownFilter({
    super.key,
    required this.items,
    this.spacing = 8.0,
    this.labelPadding,
    this.scrollable = true,
    this.style,
    this.onFilterChanged,
  });

  @override
  State<ParkDropdownFilter> createState() => _ParkDropdownFilterState();
}

class _ParkDropdownFilterState extends State<ParkDropdownFilter> {
  /// 当前正在展开的标签索引，null 表示无展开
  int? _currentExpandedIndex;

  /// 每个标签已选中的 value 集合
  /// key = item index, value = 已选中的 Set<String>
  final Map<int, Set<String>> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    _initSelectedValues();
  }

  @override
  void didUpdateWidget(ParkDropdownFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 items 中的 selectedValues 外部变更时同步内部状态
    for (int i = 0; i < widget.items.length; i++) {
      final external = widget.items[i].selectedValues;
      if (external != null) {
        _selectedValues[i] = Set<String>.from(external);
      }
    }
  }

  /// 从 items 初始化 _selectedValues
  void _initSelectedValues() {
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      _selectedValues[i] =
          item.selectedValues != null
              ? Set<String>.from(item.selectedValues!)
              : <String>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return SizedBox(
      height: widget.style?.labelHeight ?? 48.0,
      child: _buildFilterBar(park),
    );
  }

  /// 构建横向标签栏
  Widget _buildFilterBar(ParkThemeData park) {
    final style = widget.style;
    final labels = List.generate(widget.items.length, (index) {
      final item = widget.items[index];
      final isActive =
          _currentExpandedIndex == index ||
          (_selectedValues[index]?.isNotEmpty ?? false);
      return _FilterLabel(
        key: ValueKey('filter_label_${item.label}_$index'),
        label: item.label,
        isActive: isActive,
        isExpanded: _currentExpandedIndex == index,
        disabled: item.disabled,
        style: style,
        park: park,
        spacing: widget.spacing,
        padding: widget.labelPadding,
        onTap: () => _toggleItem(index),
      );
    });

    if (widget.scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: labels,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: labels,
    );
  }

  /// 切换标签展开/收起状态
  void _toggleItem(int index) {
    final item = widget.items[index];
    if (item.disabled) return;

    // onTab 回调：返回 true 则阻止默认展开
    if (item.onTab != null) {
      final shouldBlock = item.onTab!();
      if (shouldBlock) return;
    }

    setState(() {
      // 同一个标签点击：收起
      if (_currentExpandedIndex == index) {
        _currentExpandedIndex = null;
        return;
      }
      // 不同标签：关闭旧的，展开新的
      _currentExpandedIndex = index;
    });

    // 展开对应面板
    _openPanel(index);
  }

  /// 打开对应标签的底部面板
  void _openPanel(int index) {
    final item = widget.items[index];

    if (item.child != null) {
      // 自定义 child 模式
      _showCustomSheet(index, item);
    } else if (item.options != null && item.options!.isNotEmpty) {
      // 预定义选项模式
      _showOptionsSheet(index, item);
    }
  }

  /// 弹出预定义选项面板
  Future<void> _showOptionsSheet(int index, DropdownFilterItem item) async {
    final currentSelected = _selectedValues[index] ?? <String>{};

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OptionsSheetContent(
        title: item.label,
        options: item.options!,
        multiple: item.multiple,
        columns: item.columns,
        selectedValues: currentSelected,
        height: item.height,
        isCheck: item.isCheck,
        confirmText: ParkLocalizations.of(context).confirmText,
        cancelText: ParkLocalizations.of(context).cancelText,
        onChange: (values) {
          item._effectiveOnChanged?.call(values);
        },
        onConfirm: (values) {
          item.onConfirm?.call(values);
        },
        onReset: () {
          item.onReset?.call();
        },
      ),
    );

    if (!mounted) return;

    if (result != null) {
      // 用户确认了选择 — 回调已由 _OptionsSheetContent 内部触发
      setState(() {
        _selectedValues[index] = result;
        _currentExpandedIndex = null;
      });
      widget.onFilterChanged?.call(index, result);
    } else {
      // 用户取消了选择
      setState(() {
        _currentExpandedIndex = null;
      });
    }
  }

  /// 弹出自定义 child 面板
  Future<void> _showCustomSheet(int index, DropdownFilterItem item) async {
    // 复用 ParkDropdownSheet.showCustom 提供标准外壳
    await ParkDropdownSheet.showCustom(
      context,
      title: item.label,
      child: item.child!,
      height: item.height,
      confirmText: ParkLocalizations.of(context).confirmText,
      cancelText: ParkLocalizations.of(context).cancelText,
      onConfirm: () {
        item.onConfirm?.call(_selectedValues[index] ?? <String>{});
        widget.onFilterChanged?.call(index, _selectedValues[index] ?? <String>{});
      },
      onCancel: () {
        item.onReset?.call();
      },
    );

    if (!mounted) return;
    setState(() {
      _currentExpandedIndex = null;
    });
  }
}

// ============================================================================
// _FilterLabel — 单个筛选标签
// ============================================================================

class _FilterLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isExpanded;
  final bool disabled;
  final DropdownFilterStyle? style;
  final ParkThemeData park;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;

  const _FilterLabel({
    super.key,
    required this.label,
    required this.isActive,
    required this.isExpanded,
    required this.disabled,
    required this.style,
    required this.park,
    required this.spacing,
    required this.padding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 颜色解析
    final defaultTextColor = park.colors.textSecondary;
    final activeColor = style?.activeColor ?? park.colors.brand;
    final textColor =
        disabled
            ? park.colors.textDisabled
            : (isActive ? activeColor : (style?.textColor ?? defaultTextColor));

    final fontWeight =
        isActive
            ? (style?.activeFontWeight ?? FontWeight.w600)
            : (style?.fontWeight ?? FontWeight.w400);

    final underlineColor = style?.underlineColor ?? park.colors.brand;
    final arrowColor =
        disabled
            ? park.colors.textDisabled
            : (style?.arrowColor ?? textColor);

    final bgColor = style?.backgroundColor;
    final borderRadius = style?.borderRadius;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : onTap,
        child: AnimatedContainer(
        duration: park.motion.quick,
        curve: park.motion.defaultEasing,
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: park.spacing.sm, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          borderRadius:
              borderRadius != null
                  ? BorderRadius.circular(borderRadius)
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── 标签文字 + 箭头 ──
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: park.typography.sizeBody,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: park.spacing.xs),
                AnimatedRotation(
                  duration: park.motion.quick,
                  turns: isExpanded ? 0.5 : 0.0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: arrowColor,
                  ),
                ),
              ],
            ),

            // ── 底部下划线 ──
            AnimatedContainer(
              duration: park.motion.standard,
              curve: park.motion.defaultEasing,
              margin: EdgeInsets.only(top: park.spacing.xs),
              width: isActive ? math.max(label.length * 8.0, 20.0) : 0.0,
              height: isActive ? 2.0 : 0.0,
              decoration: BoxDecoration(
                color: isActive ? underlineColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ============================================================================
// _OptionsSheetContent — 选项面板内容
// ============================================================================

class _OptionsSheetContent extends StatefulWidget {
  final String title;
  final List<DropdownFilterOption> options;
  final bool multiple;
  final int columns;
  final Set<String> selectedValues;
  final double? height;
  final bool isCheck;
  final String? confirmText;
  final String? cancelText;
  final ValueChanged<Set<String>>? onChange;
  final ValueChanged<Set<String>>? onConfirm;
  final VoidCallback? onReset;

  const _OptionsSheetContent({
    required this.title,
    required this.options,
    required this.multiple,
    required this.columns,
    required this.selectedValues,
    this.height,
    this.isCheck = false,
    this.confirmText,
    this.cancelText,
    this.onChange,
    this.onConfirm,
    this.onReset,
  });

  @override
  State<_OptionsSheetContent> createState() => _OptionsSheetContentState();
}

class _OptionsSheetContentState extends State<_OptionsSheetContent> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedValues);
  }

  void _toggleOption(DropdownFilterOption option) {
    if (option.disabled) return;
    setState(() {
      if (widget.multiple) {
        if (_selected.contains(option.value)) {
          _selected.remove(option.value);
        } else {
          _selected.add(option.value);
        }
      } else {
        // 单选模式：点击即选中并立即确认
        _selected = {option.value};
      }
    });

    widget.onChange?.call(_selected);

    // 单选模式：立即关闭
    if (!widget.multiple) {
      widget.onConfirm?.call(_selected);
      Navigator.pop(context, _selected);
    }
  }

  void _handleConfirm() {
    // isCheck 约束：必须至少选一项
    if (widget.isCheck && _selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ParkLocalizations.of(context).pleaseSelectFirst)));
      return;
    }
    widget.onConfirm?.call(_selected);
    Navigator.pop(context, _selected);
  }

  void _handleCancel() {
    // 取消时恢复为进入面板前的选中值
    widget.onReset?.call();
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Container(
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(park.radius.lg)),
        boxShadow: park.shadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 拖拽手柄 ──
            Padding(
              padding: EdgeInsets.only(top: park.spacing.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: park.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── 标题栏 ──
            _buildHeader(park),

            // ── 选项内容区 ──
            _buildBody(park),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ParkThemeData park) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        park.spacing.sm,
        park.spacing.xs,
        park.spacing.sm,
        park.spacing.xs,
      ),
      child: Row(
        children: [
          // 取消按钮（仅多选模式显示）
          if (widget.multiple)
            _sheetButton(
              text: widget.cancelText ?? ParkLocalizations.of(context).cancelText,
              filled: false,
              park: park,
              onTap: _handleCancel,
            )
          else
            const SizedBox(width: 48),

          const Spacer(),

          // 标题
          Text(
            widget.title,
            style: TextStyle(
              fontSize: park.typography.sizeBody,
              fontWeight: park.typography.weightBold,
              color: park.colors.textPrimary,
            ),
          ),

          const Spacer(),

          // 确定按钮（仅多选模式显示）
          if (widget.multiple)
            _sheetButton(
              text: widget.confirmText ?? ParkLocalizations.of(context).confirmText,
              filled: true,
              park: park,
              onTap: _handleConfirm,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBody(ParkThemeData park) {
    final options = widget.options;
    if (options.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(park.spacing.xl),
        child: Center(
          child: Text(
            ParkLocalizations.of(context).noOptions,
            style: TextStyle(color: park.colors.textPlaceholder),
          ),
        ),
      );
    }

    final bodyHeight = widget.height ?? _estimateHeight(park);
    final isGrid = widget.columns > 1;

    return SizedBox(
      height: bodyHeight,
      child:
          isGrid ? _buildGridView(park) : _buildListView(park),
    );
  }

  double _estimateHeight(ParkThemeData park) {
    if (widget.columns > 1) {
      final rows = (widget.options.length / widget.columns).ceil();
      return rows * 56.0 + park.spacing.base * 2;
    }
    return (widget.options.length * 48.0).clamp(100.0, 360.0);
  }

  Widget _buildListView(ParkThemeData park) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        park.spacing.base,
        park.spacing.xs,
        park.spacing.base,
        park.spacing.base,
      ),
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        final option = widget.options[index];
        final isSelected = _selected.contains(option.value);
        return _buildListItem(option, isSelected, park);
      },
    );
  }

  Widget _buildListItem(
      DropdownFilterOption option, bool isSelected, ParkThemeData park) {
    return Semantics(
      button: true,
      label: option.label,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _toggleOption(option),
        child: AnimatedContainer(
        duration: park.motion.quick,
        curve: park.motion.defaultEasing,
        margin: EdgeInsets.symmetric(vertical: park.spacing.xs),
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? park.colors.brand.withValues(alpha: 0.08)
                  : park.colors.surface,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color:
                isSelected
                    ? park.colors.brand.withValues(alpha: 0.2)
                    : park.colors.border.withValues(alpha: 0.4),
          ),
             boxShadow: [
            BoxShadow(
              color: isSelected
                  ? park.colors.brand.withValues(alpha: 0.08)
                  : park.colors.textPrimary.withValues(alpha: 0.03),
              blurRadius: isSelected ? 10 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (option.leading != null) ...[
              option.leading!,
              SizedBox(width: park.spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: park.typography.sizeBody,
                      fontWeight:
                          isSelected ? park.typography.weightBold : null,
                      color:
                          option.disabled
                              ? park.colors.textPlaceholder
                              : isSelected
                              ? park.colors.brand
                              : park.colors.textPrimary,
                    ),
                  ),
                  if (option.subtitle != null)
                    Text(
                      option.subtitle!,
                      style: TextStyle(
                        fontSize: park.typography.sizeBodySmall,
                        color: park.colors.textPlaceholder,
                      ),
                    ),
                ],
              ),
            ),
            // 选中标记
            if (widget.multiple)
              Icon(
                isSelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20,
                color:
                    isSelected
                        ? park.colors.brand
                        : park.colors.textPlaceholder,
              )
            else if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: park.colors.brand,
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildGridView(ParkThemeData park) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        park.spacing.base,
        park.spacing.sm,
        park.spacing.base,
        park.spacing.base,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.columns,
        crossAxisSpacing: park.spacing.sm,
        mainAxisSpacing: park.spacing.sm,
        childAspectRatio: 2.5,
      ),
      itemCount: widget.options.length,
      itemBuilder: (context, index) {
        final option = widget.options[index];
        final isSelected = _selected.contains(option.value);
        return _buildGridItem(option, isSelected, park);
      },
    );
  }

  Widget _buildGridItem(
      DropdownFilterOption option, bool isSelected, ParkThemeData park) {
    return Semantics(
      button: true,
      label: option.label,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _toggleOption(option),
        child: AnimatedContainer(
        duration: park.motion.quick,
        curve: park.motion.defaultEasing,
        decoration: BoxDecoration(
          color: isSelected
              ? park.colors.brand.withValues(alpha: 0.08)
              : park.colors.background,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color: isSelected
                ? park.colors.brand.withValues(alpha: 0.3)
                : park.colors.border.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? park.colors.brand.withValues(alpha: 0.10)
                  : park.colors.textPrimary.withValues(alpha: 0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (option.leading != null) ...[
              SizedBox(height: 4),
              SizedBox(
                width: 24, height: 24,
                child: FittedBox(child: option.leading!),
              ),
              SizedBox(height: park.spacing.xs),
            ],
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: park.typography.sizeBodySmall,
                  fontWeight: isSelected ? park.typography.weightBold : null,
                  color: option.disabled
                      ? park.colors.textPlaceholder
                      : isSelected
                          ? park.colors.brand
                          : park.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _sheetButton({
    required String text,
    required bool filled,
    required ParkThemeData park,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: text,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: filled
              ? park.colors.brand.withValues(alpha: 0.12)
              : park.colors.surface,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color: filled
                ? park.colors.brand.withValues(alpha: 0.24)
                : park.colors.border.withValues(alpha: 0.5),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: park.colors.brand.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: park.typography.sizeBody,
            fontWeight: park.typography.weightMedium,
            color: filled
                ? park.colors.brand
                : park.colors.textSecondary,
          ),
        ),
      ),
      ),
    );
  }
}
