import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// Empty-state size presets.
enum ParkEmptySize { small, medium, large }

/// Empty-state type variants that determine default icon, color, and
/// description text.
///
/// Consumers can still override any aspect via the corresponding
/// constructor parameters (e.g. [icon], [description]).
enum ParkEmptyType {
  /// Generic "no data" state.
  noData,

  /// No search results state.
  noResults,

  /// No permission state.
  noPermission,
}

/// An empty-state placeholder component.
///
/// Shows a centered column with an icon, description text, optional
/// action buttons, and an optional footer.
///
/// The [type] parameter selects a built-in variant that provides default
/// icon, color, and description text. All of these can be overridden
/// individually by passing explicit [icon], [image], [description],
/// or [descriptionWidget].
class ParkEmpty extends StatelessWidget {
  /// Creates a ParkEmpty.
  const ParkEmpty({
    super.key,
    this.icon,
    this.image,
    this.description,
    this.descriptionWidget,
    this.actions,
    this.footer,
    this.size = ParkEmptySize.medium,
    this.type = ParkEmptyType.noData,
  });

  /// Optional icon displayed above the description.
  ///
  /// When `null` and [image] is also `null`, a default icon is chosen
  /// based on [type].
  final IconData? icon;

  /// Custom illustration widget (takes priority over [icon] when both set).
  final Widget? image;

  /// Description text.
  ///
  /// When `null`, defaults to the [ParkLocalizations] value
  /// corresponding to [type] (e.g. `l10n.noSearchResults` for
  /// [ParkEmptyType.noResults]).
  final String? description;

  /// Rich description widget (takes priority over [description] when set).
  final Widget? descriptionWidget;

  /// Optional action buttons shown below the description.
  final List<Widget>? actions;

  /// Footer widget displayed below actions (e.g., additional links or info).
  final Widget? footer;

  /// Size preset controlling icon and text scale.
  final ParkEmptySize size;

  /// Built-in variant that supplies default icon, color, and description.
  ///
  /// Defaults to [ParkEmptyType.noData].
  final ParkEmptyType type;

  // ── Computed values ──

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

  /// Returns the default icon for the given [type].
  IconData _defaultIcon() {
    switch (type) {
      case ParkEmptyType.noData:
        return Icons.inbox;
      case ParkEmptyType.noResults:
        return Icons.search_off;
      case ParkEmptyType.noPermission:
        return Icons.lock;
    }
  }

  /// Returns the icon color for the given [type] from the theme.
  Color _iconColor(ParkThemeData park) {
    switch (type) {
      case ParkEmptyType.noData:
        return park.colors.textPlaceholder;
      case ParkEmptyType.noResults:
        return park.colors.textSecondary;
      case ParkEmptyType.noPermission:
        return park.colors.warning;
    }
  }

  /// Resolves the effective description text.
  String _resolveDescription(ParkLocalizations l10n) {
    if (description != null) return description!;
    switch (type) {
      case ParkEmptyType.noData:
        return l10n.noData;
      case ParkEmptyType.noResults:
        return l10n.noSearchResults;
      case ParkEmptyType.noPermission:
        return l10n.noPermission;
    }
  }

  /// Returns a Semantics label that describes this empty state.
  String _semanticsLabel(ParkLocalizations l10n) {
    final desc = _resolveDescription(l10n);
    switch (type) {
      case ParkEmptyType.noData:
        return '${l10n.noData}, $desc';
      case ParkEmptyType.noResults:
        return '${l10n.noSearchResults}, $desc';
      case ParkEmptyType.noPermission:
        return '${l10n.noPermission}, $desc';
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    final effectiveIcon = icon ?? _defaultIcon();
    final effectiveIconColor = _iconColor(park);
    final effectiveDescription = _resolveDescription(l10n);
    final label = _semanticsLabel(l10n);

    return Semantics(
      label: label,
      container: true,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: park.spacing.lg,
            vertical: park.spacing.base,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (image != null) ...[
                Semantics(
                  image: true,
                  label: 'Empty illustration',
                  child: image!,
                ),
                SizedBox(height: _spacing),
              ] else ...[
                Semantics(
                  image: true,
                  excludeSemantics: true,
                  child: Icon(
                    effectiveIcon,
                    size: _iconSize,
                    color: effectiveIconColor,
                  ),
                ),
                SizedBox(height: _spacing),
              ],
              descriptionWidget ??
                  Text(
                    effectiveDescription,
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
              if (footer != null) ...[
                SizedBox(height: _spacing),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
