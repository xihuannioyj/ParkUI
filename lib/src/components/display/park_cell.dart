import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/park_icon_theme_data.dart';
import '../base/park_icon.dart';

/// Cell size presets.
enum ParkCellSize { small, medium, large }

/// A list-cell / settings-row component.
///
/// Shows a left icon, title + description column, and an optional
/// right-side arrow or note. Tapping triggers [onPressed].
class ParkCell extends StatefulWidget {
  /// Creates a ParkCell.
  const ParkCell({
    super.key,
    this.title,
    this.titleText,
    this.description,
    this.descriptionText,
    this.leftIcon,
    this.arrow = false,
    this.onPressed,
    this.note,
    this.bordered = true,
    this.hover = false,
    this.required = false,
    this.noteWidget,
    this.arrowIcon,
    this.disabled = false,
    this.size = ParkCellSize.medium,
    this.extra,
    this.labelWidth,
    this.clickable,
    this.backgroundColor,
    this.leftIconColor,
    this.leftIconContainerColor,
  });

  @override
  State<ParkCell> createState() => _ParkCellState();

  /// Title widget. Use [titleText] for a simple string.
  final Widget? title;

  /// Convenience string title.
  final String? titleText;

  /// Description widget below the title.
  final Widget? description;

  /// Convenience string description.
  final String? descriptionText;

  /// Widget shown on the left side (typically an Icon).
  final Widget? leftIcon;

  /// Whether to show a right chevron arrow.
  final bool arrow;

  /// Tap callback.
  final VoidCallback? onPressed;

  /// Right-side note text shown before the arrow.
  final String? note;

  /// Whether to show a bottom border divider.
  final bool bordered;

  /// When true, shows hover highlight on mouse enter.
  final bool hover;

  /// When true, shows red asterisk before title.
  final bool required;

  /// Custom widget for the right side (takes priority over [note]).
  final Widget? noteWidget;

  /// Custom arrow icon. When null, uses the default chevron_right.
  final IconData? arrowIcon;

  /// When true, the cell is greyed out and non-interactive.
  final bool disabled;

  /// Size preset controlling vertical padding.
  final ParkCellSize size;

  /// Extra widget displayed on the right side (distinct from noteWidget).
  final Widget? extra;

  /// Fixed width for the label/title area.
  final double? labelWidth;

  /// Whether the cell shows a visual affordance for being clickable.
  /// When null, defaults to true if [onPressed] is set.
  final bool? clickable;

  /// Custom background color for the cell.
  final Color? backgroundColor;

  /// Left icon color. When [leftIcon] is a [ParkIcon], this overrides its color.
  /// Falls back to [ParkIconThemeData.cellIconColor] then [ParkColors.brand].
  final Color? leftIconColor;

  /// Left icon container background color.
  /// When [leftIcon] is a [ParkIcon] with container != none, this overrides its containerColor.
  final Color? leftIconContainerColor;
}

class _ParkCellState extends State<ParkCell> {
  bool _isPressed = false;
  bool _isHovered = false;

  Widget _buildTitle(ParkThemeData park) {
    if (widget.title != null) return widget.title!;
    final titleText = Text(
      widget.titleText ?? '',
      style: TextStyle(
        fontSize: park.typography.sizeBody,
        fontWeight: park.typography.weightMedium,
        color: park.colors.textPrimary,
      ),
    );
    if (widget.required) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '* ',
            style: TextStyle(
              fontSize: park.typography.sizeBody,
              fontWeight: park.typography.weightBold,
              color: park.colors.error,
            ),
          ),
          titleText,
        ],
      );
    }
    return titleText;
  }

  Widget? _buildDescription(ParkThemeData park) {
    if (widget.description != null) return widget.description;
    if (widget.descriptionText == null) return null;
    return Padding(
      padding: EdgeInsets.only(top: park.spacing.xs),
      child: Text(
        widget.descriptionText!,
        style: TextStyle(
          fontSize: park.typography.sizeBodySmall,
          color: park.colors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final titleWidget = _buildTitle(park);
    final descWidget = _buildDescription(park);

    final isDisabled = widget.disabled;
    final verticalPadding = switch (widget.size) {
      ParkCellSize.small => park.spacing.sm,
      ParkCellSize.medium => park.spacing.md,
      ParkCellSize.large => park.spacing.base,
    };

    final leftChildren = <Widget>[];
    if (widget.leftIcon != null) {
      Widget iconWidget = widget.leftIcon!;
      // 若 leftIcon 是 ParkIcon，自动注入品牌色
      if (iconWidget is ParkIcon) {
        final effectiveColor = widget.leftIconColor ??
            park.iconTheme.cellIconColor ??
            park.colors.brand;
        final effectiveContainerColor = widget.leftIconContainerColor;
        iconWidget = ParkIcon(
          iconWidget.icon,
          size: iconWidget.size,
          pixelSize: iconWidget.pixelSize,
          color: iconWidget.color ?? effectiveColor,
          container: iconWidget.container,
          containerColor: effectiveContainerColor ?? iconWidget.containerColor,
          spin: iconWidget.spin,
        );
      }
      leftChildren.add(
        Padding(
          padding: EdgeInsets.only(right: park.spacing.md),
          child: Opacity(
            opacity: isDisabled ? 0.4 : 1.0,
            child: iconWidget,
          ),
        ),
      );
    }

    leftChildren.add(
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            titleWidget,
            ?descWidget,
          ],
        ),
      ),
    );

    final rightChildren = <Widget>[];
    if (widget.noteWidget != null) {
      rightChildren.add(
        Padding(
          padding: EdgeInsets.only(left: park.spacing.sm),
          child: widget.noteWidget!,
        ),
      );
    } else if (widget.note != null) {
      rightChildren.add(
        Padding(
          padding: EdgeInsets.only(left: park.spacing.sm),
          child: Text(
            widget.note!,
            style: TextStyle(
              fontSize: park.typography.sizeBodySmall,
              color: isDisabled ? park.colors.textDisabled : park.colors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (widget.arrow) {
      rightChildren.add(
        Padding(
          padding: EdgeInsets.only(left: (widget.note != null || widget.noteWidget != null) ? park.spacing.xs : park.spacing.sm),
          child: Icon(
            widget.arrowIcon ?? Icons.chevron_right,
            size: 20,
            color: isDisabled ? park.colors.textDisabled : park.colors.textPlaceholder,
          ),
        ),
      );
    }

    final row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: park.spacing.base,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          ...leftChildren,
          ...rightChildren,
        ],
      ),
    );

    final cell = AnimatedContainer(
      duration: park.motion.quick,
      curve: park.motion.defaultEasing,
      color: _isPressed && !isDisabled
          ? park.colors.textPrimary.withValues(alpha: 0.06)
          : _isHovered && widget.hover && !isDisabled
              ? park.colors.textPrimary.withValues(alpha: 0.04)
              : Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row,
          if (widget.bordered)
            Padding(
              padding: EdgeInsets.only(left: widget.leftIcon != null ? park.spacing.base + 20 + park.spacing.md : park.spacing.base),
              child: Container(
                height: 0.5,
                color: park.colors.divider,
              ),
            ),
        ],
      ),
    );

    Widget result;
    if (widget.onPressed != null && !isDisabled) {
      result = InkWell(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: cell,
      );
    } else {
      result = cell;
    }

    if (isDisabled) {
      result = Opacity(opacity: 0.5, child: result);
    }

    if (widget.hover && !isDisabled) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: result,
      );
    }

    return result;
  }
}
