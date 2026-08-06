import 'package:flutter/material.dart';
import '../../binding/park_binding_form_scope.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';

const double _kBorderWidthSelected = 1.6;
const double _kBorderWidthDefault = 1.0;

/// A single choice item for [ParkChoiceGroup].
class ParkChoiceItem {
  /// Creates a choice item.
  const ParkChoiceItem({
    required this.value,
    this.label,
    this.leading,
    this.enabled = true,
  });

  /// Unique value identifying this option.
  final String value;

  /// Display label. When null, only [leading] is shown.
  final String? label;

  /// Optional leading icon or image (rendered at 20×20).
  final Widget? leading;

  /// Whether this option is selectable.
  final bool enabled;
}

/// A button-style single-choice group.
///
/// Renders options as selectable bordered pills with optional auto-wrap,
/// join mode (merged borders like a segment control), and leading widgets.
///
/// ```dart
/// ParkChoiceGroup(
///   items: [
///     ParkChoiceItem(value: '1', label: '整租'),
///     ParkChoiceItem(value: '2', label: '合租'),
///   ],
///   value: '1',
///   onChanged: (v) => setState(() => selected = v),
/// )
/// ```
class ParkChoiceGroup extends StatelessWidget {
  /// Creates a ParkChoiceGroup.
  const ParkChoiceGroup({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.enabled = true,
    this.readOnly = false,
    this.direction = Axis.horizontal,
    this.join = false,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 8.0,
    this.selectedColor,
    this.selectedBorderColor,
    this.unselectedColor,
    this.unselectedBorderColor,
    this.textStyle,
    this.selectedTextStyle,
    this.bindKey,
    this.bindingService,
  });

  /// Available options.
  final List<ParkChoiceItem> items;

  /// Called when the user selects an option.
  final ValueChanged<String> onChanged;

  /// Currently selected value.
  final String? value;

  /// Whether the entire group is enabled.
  final bool enabled;

  /// Whether the group is read-only (no interaction).
  final bool readOnly;

  /// Layout direction. Horizontal wraps automatically.
  final Axis direction;

  /// Whether to merge borders between adjacent items (segment control style).
  final bool join;

  /// Horizontal spacing between items (non-join mode).
  final double spacing;

  /// Vertical spacing between rows (horizontal wrap mode).
  final double runSpacing;

  /// Padding inside each button.
  final EdgeInsetsGeometry padding;

  /// Border radius of each button (non-join mode).
  final double borderRadius;

  /// Background color of the selected button.
  /// Defaults to [ParkColors.brand].
  final Color? selectedColor;

  /// Border color of the selected button.
  /// Defaults to [ParkColors.brandDark].
  final Color? selectedBorderColor;

  /// Background color of unselected buttons.
  /// Defaults to [ParkColors.surface].
  final Color? unselectedColor;

  /// Border color of unselected buttons.
  /// Defaults to [ParkColors.border].
  final Color? unselectedBorderColor;

  /// Text style for unselected items.
  final TextStyle? textStyle;

  /// Text style for the selected item.
  final TextStyle? selectedTextStyle;

  /// 绑定键（点号分隔的路径，如 `'choice'`）。
  ///
  /// 设此参数后组件进入双向绑定模式，选中值自动同步到 ParkBindingService；
  /// 不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。未传时尝试从最近的 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  bool get _interactive => enabled && !readOnly;

  @override
  Widget build(BuildContext context) {
    // 双向绑定模式（零侵入）：bindKey 解析到绑定服务后，选中值改由
    // ParkBindable 驱动（ValueListenableBuilder 监听），选择变化时回写 bindable。
    // 未设 bindKey 时组件行为完全不变。
    final ParkBindingService? service = bindKey != null
        ? (bindingService ?? ParkBindingFormScope.of(context)?.service)
        : null;
    if (service != null) {
      final bindable = service.bind<String>(bindKey!);
      return ValueListenableBuilder<String>(
        valueListenable: bindable,
        builder: (context, boundValue, _) => _buildGroup(
          context,
          boundValue,
          (v) {
            bindable.value = v;
            onChanged(v);
          },
        ),
      );
    }
    return _buildGroup(context, value, onChanged);
  }

  Widget _buildGroup(
    BuildContext context,
    String? effectiveValue,
    ValueChanged<String> effectiveOnChanged,
  ) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;

    final effSelectedColor = selectedColor ?? colors.brand;
    final effSelectedBorder = selectedBorderColor ?? colors.brandDark;
    final effUnselectedColor = unselectedColor ?? colors.surface;
    final effUnselectedBorder = unselectedBorderColor ?? colors.border;

    final effTextStyle = textStyle ??
        TextStyle(
          fontSize: typo.sizeBodySmall,
          color: colors.textPrimary,
        );

    final effSelectedTextStyle = selectedTextStyle ??
        TextStyle(
          fontSize: typo.sizeBodySmall,
          fontWeight: typo.weightMedium,
          color: colors.textOnBrand,
        );

    if (direction == Axis.vertical) {
      return _buildVertical(
        colors,
        effSelectedColor,
        effSelectedBorder,
        effUnselectedColor,
        effUnselectedBorder,
        effTextStyle,
        effSelectedTextStyle,
        effectiveValue,
        effectiveOnChanged,
      );
    }

    return _buildHorizontal(
      colors,
      effSelectedColor,
      effSelectedBorder,
      effUnselectedColor,
      effUnselectedBorder,
      effTextStyle,
      effSelectedTextStyle,
      effectiveValue,
      effectiveOnChanged,
    );
  }

  Widget _buildVertical(
    ParkColors colors,
    Color selColor,
    Color selBorder,
    Color unselColor,
    Color unselBorder,
    TextStyle txtStyle,
    TextStyle selTxtStyle,
    String? effectiveValue,
    ValueChanged<String> effectiveOnChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: join ? 0 : runSpacing),
          _buildButton(
            item: items[i],
            index: i,
            isSelected: items[i].value == effectiveValue,
            colors: colors,
            selColor: selColor,
            selBorder: selBorder,
            unselColor: unselColor,
            unselBorder: unselBorder,
            txtStyle: txtStyle,
            selTxtStyle: selTxtStyle,
            isFirst: i == 0,
            isLast: i == items.length - 1,
            onChanged: effectiveOnChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildHorizontal(
    ParkColors colors,
    Color selColor,
    Color selBorder,
    Color unselColor,
    Color unselBorder,
    TextStyle txtStyle,
    TextStyle selTxtStyle,
    String? effectiveValue,
    ValueChanged<String> effectiveOnChanged,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure each item to determine row breaks
        final rows = <List<int>>[];
        var currentRow = <int>[];
        var currentWidth = 0.0;
        final maxWidth = constraints.maxWidth;

        for (int i = 0; i < items.length; i++) {
          final itemWidth = _measureItemWidth(items[i], txtStyle, selTxtStyle);
          final neededWidth = join
              ? itemWidth
              : (currentRow.isEmpty ? itemWidth : itemWidth + spacing);

          if (currentWidth + neededWidth > maxWidth && currentRow.isNotEmpty) {
            rows.add(currentRow);
            currentRow = [i];
            currentWidth = itemWidth;
          } else {
            currentRow.add(i);
            currentWidth += neededWidth;
          }
        }
        if (currentRow.isNotEmpty) rows.add(currentRow);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: runSpacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int c = 0; c < rows[r].length; c++) ...[
                    if (c > 0 && !join) SizedBox(width: spacing),
                    _buildButton(
                      item: items[rows[r][c]],
                      index: rows[r][c],
                      isSelected: items[rows[r][c]].value == effectiveValue,
                      colors: colors,
                      selColor: selColor,
                      selBorder: selBorder,
                      unselColor: unselColor,
                      unselBorder: unselBorder,
                      txtStyle: txtStyle,
                      selTxtStyle: selTxtStyle,
                      isFirst: c == 0,
                      isLast: c == rows[r].length - 1,
                      onChanged: effectiveOnChanged,
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  double _measureItemWidth(
    ParkChoiceItem item,
    TextStyle txtStyle,
    TextStyle selTxtStyle,
  ) {
    double width = 0;
    final pad = padding.resolve(TextDirection.ltr);
    width += pad.left + pad.right;

    if (item.leading != null) {
      width += 20 + 8; // leading size + gap
    }

    if (item.label != null) {
      final painter = TextPainter(
        text: TextSpan(text: item.label, style: txtStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      width += painter.width;
      painter.dispose();
    }

    if (!join) width += 2; // border
    return width;
  }

  Widget _buildButton({
    required ParkChoiceItem item,
    required int index,
    required bool isSelected,
    required ParkColors colors,
    required Color selColor,
    required Color selBorder,
    required Color unselColor,
    required Color unselBorder,
    required TextStyle txtStyle,
    required TextStyle selTxtStyle,
    required bool isFirst,
    required bool isLast,
    required ValueChanged<String> onChanged,
  }) {
    final isDisabled = !item.enabled || !enabled;
    final interactive = _interactive && item.enabled;

    // Border
    Border border;
    BorderRadiusGeometry br;

    if (join) {
      if (direction == Axis.horizontal) {
        border = Border(
          top: BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault),
          bottom: BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault),
          left: isFirst
              ? BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault)
              : BorderSide.none,
          right: isLast
              ? BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault)
              : BorderSide.none,
        );
        br = BorderRadius.horizontal(
          left: isFirst ? Radius.circular(borderRadius) : Radius.zero,
          right: isLast ? Radius.circular(borderRadius) : Radius.zero,
        );
      } else {
        border = Border(
          left: BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault),
          right: BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault),
          top: isFirst
              ? BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault)
              : BorderSide.none,
          bottom: isLast
              ? BorderSide(color: isSelected ? selBorder : unselBorder, width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault)
              : BorderSide.none,
        );
        br = BorderRadius.vertical(
          top: isFirst ? Radius.circular(borderRadius) : Radius.zero,
          bottom: isLast ? Radius.circular(borderRadius) : Radius.zero,
        );
      }
    } else {
      border = Border.all(
        color: isSelected ? selBorder : unselBorder,
        width: isSelected ? _kBorderWidthSelected : _kBorderWidthDefault,
      );
      br = BorderRadius.circular(borderRadius);
    }

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: isDisabled
            ? colors.disabledBg
            : isSelected
                ? selColor
                : unselColor,
        border: border,
        borderRadius: br,
        boxShadow: isSelected && !isDisabled
            ? [
                BoxShadow(
                  color: selBorder.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.leading != null) ...[
            SizedBox(width: 20, height: 20, child: item.leading),
            const SizedBox(width: 8),
          ],
          if (item.label != null)
            Text(
              item.label!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: isSelected ? selTxtStyle : txtStyle.copyWith(
                color: isDisabled ? colors.textDisabled : txtStyle.color,
              ),
            ),
        ],
      ),
    );

    // Join mode: shift non-first items left to overlap borders
    if (join && !isFirst && direction == Axis.horizontal) {
      button = Transform.translate(
        offset: const Offset(-1.6, 0),
        child: button,
      );
    }
    if (join && !isFirst && direction == Axis.vertical) {
      button = Transform.translate(
        offset: const Offset(0, -1.6),
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: interactive,
      selected: isSelected,
      label: item.label ?? item.value,
      child: GestureDetector(
        onTap: interactive ? () => onChanged(item.value) : null,
        child: button,
      ),
    );
  }
}
