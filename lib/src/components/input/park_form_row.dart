import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// A horizontal label + field row layout widget.
///
/// Provides the consistent form-row pattern used across ylzj:
/// `[right-aligned label "XXX："] [gap] [filled rounded field area]`
///
/// The [child] can be any widget — [ParkInput], [ParkSwitch], a display
/// [Text], a picker trigger, etc.
///
/// ```dart
/// ParkFormRow(
///   label: '姓名',
///   required: true,
///   child: ParkInput(controller: nameCtrl),
/// )
///
/// ParkFormRow(
///   label: '面积',
///   suffixText: '㎡',
///   readOnly: true,
///   child: Text('85.5'),
/// )
/// ```
class ParkFormRow extends StatelessWidget {
  /// Creates a ParkFormRow.
  const ParkFormRow({
    super.key,
    required this.label,
    required this.child,
    this.labelWidth = 86.0,
    this.labelGap = 8.0,
    this.showColon = true,
    this.required = false,
    this.readOnly = false,
    this.suffixText,
    this.suffixWidth = 56.0,
    this.helperText,
    this.fieldColor,
    this.fieldBorderRadius = 16.0,
    this.fieldPadding,
    this.verticalMargin = 10.0,
    this.labelStyle,
    this.suffixStyle,
    this.helperStyle,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showFieldBackground = true,
    this.onTap,
  });

  /// Label text displayed on the left.
  final String label;

  /// The field widget displayed on the right.
  final Widget child;

  /// Width of the label area. Defaults to 86.
  final double labelWidth;

  /// Gap between label and field. Defaults to 8.
  final double labelGap;

  /// Whether to append a fullwidth colon `：` after the label.
  final bool showColon;

  /// Whether to show a required mark `*` before the label.
  final bool required;

  /// Whether the field is in read-only mode.
  /// Affects the fill alpha and interaction.
  final bool readOnly;

  /// Optional suffix text displayed after the child (e.g. unit "元", "㎡").
  final String? suffixText;

  /// Width reserved for the suffix text. Defaults to 56.
  final double suffixWidth;

  /// Optional helper text displayed below the field.
  final String? helperText;

  /// Custom field background color. When null, uses theme surface token.
  final Color? fieldColor;

  /// Border radius of the field background. Defaults to 16.
  final double fieldBorderRadius;

  /// Custom padding inside the field area.
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`.
  final EdgeInsetsGeometry? fieldPadding;

  /// Vertical margin around the entire row. Defaults to 10.
  final double verticalMargin;

  /// Custom label text style. When null, uses theme defaults.
  final TextStyle? labelStyle;

  /// Custom suffix text style. When null, uses theme defaults.
  final TextStyle? suffixStyle;

  /// Custom helper text style. When null, uses theme defaults.
  final TextStyle? helperStyle;

  /// Cross-axis alignment of the row. Defaults to center.
  /// Use [CrossAxisAlignment.start] for multi-line fields.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether to show the filled background behind the field.
  /// Set to false for borderless / transparent field areas.
  final bool showFieldBackground;

  /// Optional tap handler for the entire field area.
  /// Useful for picker triggers.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    final effectiveLabelStyle = labelStyle ??
        TextStyle(
          fontSize: typo.sizeBodySmall,
          fontWeight: typo.weightMedium,
          color: colors.textPrimary,
          height: 1.25,
        );

    final effectiveSuffixStyle = suffixStyle ??
        TextStyle(
          fontSize: typo.sizeBodySmall,
          fontWeight: typo.weightMedium,
          color: colors.brand,
        );

    final effectiveHelperStyle = helperStyle ??
        TextStyle(
          fontSize: typo.sizeCaption,
          color: colors.textSecondary,
          height: 1.4,
        );

    // Field fill: readOnly uses lower alpha
    final fieldFill = fieldColor ??
        (readOnly
            ? colors.surface.withValues(alpha: 0.55)
            : colors.surface.withValues(alpha: 0.78));

    final effectiveFieldPadding = fieldPadding ??
        EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        );

    Widget fieldContent = Row(
      children: [
        Expanded(child: child),
        if (suffixText != null) ...[
          SizedBox(width: spacing.sm),
          SizedBox(
            width: suffixWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                suffixText!,
                style: effectiveSuffixStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
        // 可点击行（picker/selector）显示右箭头，提示用户可操作
        if (onTap != null) ...[
          SizedBox(width: spacing.xs),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: colors.textSecondary.withValues(alpha: 0.6),
          ),
        ],
      ],
    );

    if (onTap != null) {
      fieldContent = Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: fieldContent,
        ),
      );
    }

    Widget fieldArea = showFieldBackground
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: effectiveFieldPadding,
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(fieldBorderRadius),
            ),
            child: fieldContent,
          )
        : fieldContent;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          // Label
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: EdgeInsets.only(
                top: crossAxisAlignment == CrossAxisAlignment.start ? 14 : 0,
              ),
              child: Text(
                required ? '*${showColon ? '$label：' : label}' : (showColon ? '$label：' : label),
                textAlign: TextAlign.right,
                textWidthBasis: TextWidthBasis.parent,
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: effectiveLabelStyle.copyWith(
                  color: required ? colors.error : effectiveLabelStyle.color,
                ),
              ),
            ),
          ),

          SizedBox(width: labelGap),

          // Field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldArea,
                if (helperText != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: spacing.xs,
                      left: 2,
                    ),
                    child: Text(
                      helperText!,
                      style: effectiveHelperStyle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
