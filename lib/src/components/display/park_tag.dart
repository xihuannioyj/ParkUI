import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// Tag visual variant.
enum ParkTagVariant { dark, light, outline }

/// Tag color theme.
enum ParkTagTheme { defaultTheme, primary, success, warning, danger }

/// Tag size preset.
enum ParkTagSize { small, medium, large }

/// Tag shape.
enum ParkTagShape { square, round }

/// An inline label / chip component.
///
/// Supports multiple color themes, variants (dark/light/outline),
/// optional close button, tap callback, checkable toggle, link mode,
/// and convenience [outline] / [light] shorthand flags.
class ParkTag extends StatelessWidget {
  /// Creates a ParkTag.
  const ParkTag({
    super.key,
    required this.text,
    this.variant = ParkTagVariant.light,
    this.theme = ParkTagTheme.defaultTheme,
    this.size = ParkTagSize.medium,
    this.shape = ParkTagShape.square,
    this.closable = false,
    this.onClose,
    this.icon,
    this.onPressed,
    this.checkable = false,
    this.checked = false,
    this.onChecked,
    this.outline = false,
    this.light = false,
    this.href,
    this.maxWidth,
    this.customColor,
    this.bordered = true,
  });

  /// Label text.
  final String text;

  /// Visual variant.
  final ParkTagVariant variant;

  /// Color theme.
  final ParkTagTheme theme;

  /// Size preset.
  final ParkTagSize size;

  /// Square (small radius) or round (pill) shape.
  final ParkTagShape shape;

  /// Whether to show a close button.
  final bool closable;

  /// Close button callback.
  final VoidCallback? onClose;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Tap callback for the whole tag.
  final VoidCallback? onPressed;

  /// When true, tag toggles between checked/unchecked on tap.
  final bool checkable;

  /// Current checked state for checkable tags (nullable for external control).
  final bool? checked;

  /// Fires when the checked state should change.
  final ValueChanged<bool>? onChecked;

  /// Convenience flag — renders with outline-only style
  /// (transparent background, colored border). Overrides [variant].
  final bool outline;

  /// Convenience flag — renders with light tinted background +
  /// darker text (softer appearance). Overrides [variant].
  final bool light;

  /// When set, renders as a clickable link. Tap opens the URL
  /// via platform clipboard fallback (since url_launcher is not
  /// a dependency, copies to clipboard and shows a snackbar).
  final String? href;

  /// Maximum width for the text label, truncating with ellipsis if exceeded.
  final double? maxWidth;

  /// Arbitrary custom color that overrides the theme-based color.
  final Color? customColor;

  /// Whether to show a border around the tag.
  final bool bordered;

  // -- Size helpers --

  double get _fontSize {
    switch (size) {
      case ParkTagSize.small:
        return 10;
      case ParkTagSize.medium:
        return 12;
      case ParkTagSize.large:
        return 14;
    }
  }

  double get _verticalPadding {
    switch (size) {
      case ParkTagSize.small:
        return 1;
      case ParkTagSize.medium:
        return 3;
      case ParkTagSize.large:
        return 5;
    }
  }

  double get _horizontalPadding {
    switch (size) {
      case ParkTagSize.small:
        return 4;
      case ParkTagSize.medium:
        return 8;
      case ParkTagSize.large:
        return 12;
    }
  }

  double get _iconSize {
    switch (size) {
      case ParkTagSize.small:
        return 12;
      case ParkTagSize.medium:
        return 14;
      case ParkTagSize.large:
        return 16;
    }
  }

  // -- Resolved variant (outline/light flags override) --

  ParkTagVariant get _effectiveVariant {
    if (outline) return ParkTagVariant.outline;
    if (light) return ParkTagVariant.light;
    return variant;
  }

  // -- Color helpers --

  Color _themeColor(ParkThemeData park) {
    if (customColor != null) return customColor!;
    switch (theme) {
      case ParkTagTheme.defaultTheme:
        return park.colors.textSecondary;
      case ParkTagTheme.primary:
        return park.colors.brand;
      case ParkTagTheme.success:
        return park.colors.success;
      case ParkTagTheme.warning:
        return park.colors.warning;
      case ParkTagTheme.danger:
        return park.colors.error;
    }
  }

  Color _themeLightColor(ParkThemeData park) {
    if (customColor != null) return customColor!.withValues(alpha: 0.1);
    switch (theme) {
      case ParkTagTheme.defaultTheme:
        return park.colors.disabledBg;
      case ParkTagTheme.primary:
        return park.colors.brandLight;
      case ParkTagTheme.success:
        return park.colors.successLight;
      case ParkTagTheme.warning:
        return park.colors.warningLight;
      case ParkTagTheme.danger:
        return park.colors.errorLight;
    }
  }

  Color _resolveBg(ParkThemeData park) {
    final base = _themeColor(park);
    final v = _effectiveVariant;
    switch (v) {
      case ParkTagVariant.dark:
        // When checkable and checked, use brand color
        if (checkable && _isChecked) return park.colors.brand;
        return base;
      case ParkTagVariant.light:
        if (checkable && _isChecked) return park.colors.brand.withValues(alpha: 0.1);
        return _themeLightColor(park);
      case ParkTagVariant.outline:
        if (checkable && _isChecked) return park.colors.brand.withValues(alpha: 0.06);
        return Colors.transparent;
    }
  }

  Color _resolveText(ParkThemeData park) {
    final v = _effectiveVariant;
    switch (v) {
      case ParkTagVariant.dark:
        if (checkable && _isChecked) return park.colors.textOnBrand;
        return theme == ParkTagTheme.defaultTheme
            ? park.colors.surface
            : park.colors.textOnBrand;
      case ParkTagVariant.light:
        if (checkable && _isChecked) return park.colors.brand;
        return _themeColor(park);
      case ParkTagVariant.outline:
        if (checkable && _isChecked) return park.colors.brand;
        return _themeColor(park);
    }
  }

  Color _resolveBorder(ParkThemeData park) {
    final v = _effectiveVariant;
    if (v == ParkTagVariant.outline) {
      if (checkable && _isChecked) return park.colors.brand;
      return _themeColor(park);
    }
    // Show border when checkable and checked in light mode
    if (checkable && _isChecked && v == ParkTagVariant.light) {
      return park.colors.brand.withValues(alpha: 0.3);
    }
    return Colors.transparent;
  }

  BorderRadius _resolveRadius(ParkThemeData park) {
    if (shape == ParkTagShape.round) {
      return park.radius.brFull;
    }
    return BorderRadius.circular(park.radius.xs);
  }

  /// Resolved checked state (null → false).
  bool get _isChecked => checked ?? false;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final bg = _resolveBg(park);
    final textColor = _resolveText(park);
    final borderColor = _resolveBorder(park);
    final radius = _resolveRadius(park);

    final children = <Widget>[];

    // Checked icon for checkable tags
    if (checkable && _isChecked) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: park.spacing.xxs),
          child: Icon(Icons.check, size: _iconSize, color: textColor),
        ),
      );
    }

    if (icon != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: park.spacing.xs),
          child: icon,
        ),
      );
    }

    // Text (with optional underline for href, and maxWidth truncation)
    Widget textWidget = Text(
      text,
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: park.typography.weightMedium,
        color: textColor,
        height: 1.2,
        decoration: href != null ? TextDecoration.underline : null,
        decorationColor: textColor,
      ),
      overflow: maxWidth != null ? TextOverflow.ellipsis : null,
      maxLines: maxWidth != null ? 1 : null,
    );
    if (maxWidth != null) {
      textWidget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: textWidget,
      );
    }
    children.add(textWidget);

    // Link icon for href
    if (href != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: park.spacing.xxs),
          child: Icon(Icons.open_in_new, size: _iconSize, color: textColor),
        ),
      );
    }

    if (closable) {
      children.add(
        Semantics(
          button: true,
          label: ParkLocalizations.of(context).closeText,
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(left: park.spacing.xs),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  Icons.close,
                  key: ValueKey<String>('close_$text'),
                  size: _iconSize,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final tag = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    // Determine tap behavior
    VoidCallback? tapHandler;
    if (href != null) {
      tapHandler = () {
        Clipboard.setData(ClipboardData(text: href!));
        // onPressed still fires if provided (for custom handling)
        onPressed?.call();
      };
    } else if (checkable) {
      tapHandler = () {
        onChecked?.call(!_isChecked);
        onPressed?.call();
      };
    } else if (onPressed != null) {
      tapHandler = onPressed;
    }

    if (tapHandler != null) {
      final semanticsLabel = href ?? text;
      return Semantics(
        button: !checkable,
        link: href != null,
        toggled: checkable ? _isChecked : null,
        label: semanticsLabel,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: tapHandler,
            behavior: HitTestBehavior.opaque,
            child: tag,
          ),
        ),
      );
    }

    return tag;
  }
}
