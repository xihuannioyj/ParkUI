import 'package:flutter/material.dart';
import '../../binding/park_binding_form_scope.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

const double _kBorderWidthSelected = 1.6;
const double _kBorderWidthDefault = 1.0;

/// A category in [ParkChipGridPicker].
class ParkChipGridCategory {
  /// Creates a category.
  const ParkChipGridCategory({
    required this.label,
    required this.children,
  });

  /// Display label for the category tab.
  final String label;

  /// Selectable options within this category.
  final List<ParkChipGridOption> children;
}

/// A selectable option within a [ParkChipGridCategory].
class ParkChipGridOption {
  /// Creates an option.
  const ParkChipGridOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// Unique value.
  final String value;

  /// Display label.
  final String label;

  /// Whether this option is selectable.
  final bool enabled;
}

/// A two-level picker: horizontal category tabs + grid of child options.
///
/// ```dart
/// ParkChipGridPicker(
///   categories: [
///     ParkChipGridCategory(label: '户型', children: [
///       ParkChipGridOption(value: '1', label: '一室'),
///       ParkChipGridOption(value: '2', label: '二室'),
///     ]),
///     ParkChipGridCategory(label: '朝向', children: [
///       ParkChipGridOption(value: 'south', label: '朝南'),
///     ]),
///   ],
///   selectedValues: {'1', 'south'},
///   onChanged: (values) => setState(() => selected = values),
/// )
/// ```
class ParkChipGridPicker extends StatefulWidget {
  /// Creates a ParkChipGridPicker.
  const ParkChipGridPicker({
    super.key,
    required this.categories,
    required this.onChanged,
    this.selectedValues = const {},
    this.multiSelect = true,
    this.columns = 4,
    this.categorySpacing = 8.0,
    this.optionSpacing = 8.0,
    this.optionRunSpacing = 8.0,
    this.selectedColor,
    this.selectedBorderColor,
    this.unselectedColor,
    this.unselectedBorderColor,
    this.bindKey,
    this.bindingService,
  });

  /// Category data.
  final List<ParkChipGridCategory> categories;

  /// Called when selection changes.
  final ValueChanged<Set<String>> onChanged;

  /// Currently selected values.
  final Set<String> selectedValues;

  /// Whether multiple options can be selected.
  final bool multiSelect;

  /// Number of grid columns. Defaults to 4.
  final int columns;

  /// Horizontal spacing between category tabs.
  final double categorySpacing;

  /// Horizontal spacing between grid options.
  final double optionSpacing;

  /// Vertical spacing between grid rows.
  final double optionRunSpacing;

  /// Background color of selected options.
  final Color? selectedColor;

  /// Border color of selected options.
  final Color? selectedBorderColor;

  /// Background color of unselected options.
  final Color? unselectedColor;

  /// Border color of unselected options.
  final Color? unselectedBorderColor;

  /// 绑定键（点号分隔的路径，如 `'tags'`）。
  ///
  /// 设此参数后组件进入双向绑定模式，选中集合自动同步到 ParkBindingService；
  /// 不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。未传时尝试从最近的 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  @override
  State<ParkChipGridPicker> createState() => _ParkChipGridPickerState();
}

class _ParkChipGridPickerState extends State<ParkChipGridPicker> {
  int _activeCategory = 0;

  @override
  Widget build(BuildContext context) {
    // 双向绑定模式（零侵入）：bindKey 解析到绑定服务后，选中集合改由
    // ParkBindable 驱动（ValueListenableBuilder 监听），选择变化时回写 bindable。
    // 未设 bindKey 时组件行为完全不变。
    final ParkBindingService? service = widget.bindKey != null
        ? (widget.bindingService ?? ParkBindingFormScope.of(context)?.service)
        : null;
    if (service != null) {
      final bindable = service.bind<Set<String>>(widget.bindKey!);
      return ValueListenableBuilder<Set<String>>(
        valueListenable: bindable,
        builder: (context, boundValues, _) => _buildContent(
          context,
          boundValues,
          (v) {
            bindable.value = v;
            widget.onChanged(v);
          },
        ),
      );
    }
    return _buildContent(context, widget.selectedValues, widget.onChanged);
  }

  Widget _buildContent(
    BuildContext context,
    Set<String> selectedValues,
    ValueChanged<Set<String>> onChanged,
  ) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;
    final radius = park.radius;

    final selColor = widget.selectedColor ?? colors.brand;
    final selBorder = widget.selectedBorderColor ?? colors.brandDark;
    final unselColor = widget.unselectedColor ?? colors.surface;
    final unselBorder = widget.unselectedBorderColor ?? colors.border;

    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final category = widget.categories[_activeCategory.clamp(0, widget.categories.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category tabs
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: spacing.base),
            itemCount: widget.categories.length,
            separatorBuilder: (_, __) => SizedBox(width: widget.categorySpacing),
            itemBuilder: (context, index) {
              final isActive = index == _activeCategory;
              return Semantics(
                button: true,
                selected: isActive,
                label: widget.categories[index].label,
                child: GestureDetector(
                  onTap: () => setState(() => _activeCategory = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? selColor : unselColor,
                      borderRadius: BorderRadius.circular(radius.full),
                      border: Border.all(
                        color: isActive ? selBorder : unselBorder,
                        width: isActive ? _kBorderWidthSelected : _kBorderWidthDefault,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.categories[index].label,
                        style: TextStyle(
                          fontSize: typo.sizeBodySmall,
                          fontWeight: isActive ? typo.weightMedium : typo.weightRegular,
                          color: isActive ? colors.textOnBrand : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: spacing.md),

        // Options grid
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.base),
          child: LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: widget.optionSpacing,
              runSpacing: widget.optionRunSpacing,
              children: category.children.map((option) {
                final isSelected = selectedValues.contains(option.value);
                final isDisabled = !option.enabled;

                return Semantics(
                  button: true,
                  selected: isSelected,
                  enabled: !isDisabled,
                  label: option.label,
                  child: GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            final newSet = Set<String>.from(selectedValues);
                            if (widget.multiSelect) {
                              if (isSelected) {
                                newSet.remove(option.value);
                              } else {
                                newSet.add(option.value);
                              }
                            } else {
                              newSet.clear();
                              newSet.add(option.value);
                            }
                            onChanged(newSet);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: (constraints.maxWidth -
                              widget.optionSpacing * (widget.columns - 1)) /
                          widget.columns,
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.sm,
                        vertical: spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? colors.disabledBg
                            : isSelected
                                ? selColor
                                : unselColor,
                        borderRadius: BorderRadius.circular(radius.md),
                        border: Border.all(
                          color: isSelected ? selBorder : unselBorder,
                          width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault,
                        ),
                      ),
                      child: Text(
                        option.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: typo.sizeBodySmall,
                          color: isDisabled
                              ? colors.textDisabled
                              : isSelected
                                  ? colors.textOnBrand
                                  : colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
