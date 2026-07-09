import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Empty-state size presets.
enum ParkEmptySize { small, medium, large }

/// An empty-state placeholder component.
///
/// Shows a centered column with an icon, description text, and
/// optional action buttons.
class ParkEmpty extends StatelessWidget {
  /// Creates a ParkEmpty.
  const ParkEmpty({
    super.key,
    this.icon,
    this.image,
    this.description = '暂无数据',
    this.descriptionWidget,
    this.actions,
    this.size = ParkEmptySize.medium,
    this.footer,
  });

  /// Optional icon displayed above the description.
  final IconData? icon;

  /// Custom illustration widget (takes priority over [icon] when both set).
  final Widget? image;

  /// Description text. Defaults to "暂无数据".
  final String description;

  /// Rich description widget (takes priority over [description] when set).
  final Widget? descriptionWidget;

  /// Optional action buttons shown below the description.
  final List<Widget>? actions;

  /// Footer widget displayed below actions (e.g., additional links or info).
  final Widget? footer;

  /// Size preset controlling icon and text scale.
  final ParkEmptySize size;

  double get _iconSize {
    switch (size) {
      case ParkEmptySize.small:
        return 40;
      case ParkEmptySize.medium:
        return 64;
      case ParkEmptySize.large:
        return 96;
    }
  }

  double get _fontSize {
    switch (size) {
      case ParkEmptySize.small:
        return 12;
      case ParkEmptySize.medium:
        return 14;
      case ParkEmptySize.large:
        return 16;
    }
  }

  double get _spacing {
    switch (size) {
      case ParkEmptySize.small:
        return 8;
      case ParkEmptySize.medium:
        return 12;
      case ParkEmptySize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.lg,
          vertical: park.spacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              image!,
              SizedBox(height: _spacing),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: _iconSize,
                color: park.colors.textPlaceholder,
              ),
              SizedBox(height: _spacing),
            ],
            descriptionWidget ??
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: park.colors.textSecondary,
                  ),
                ),
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: _spacing * 1.5),
              Wrap(
                spacing: park.spacing.sm,
                runSpacing: park.spacing.sm,
                alignment: WrapAlignment.center,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
