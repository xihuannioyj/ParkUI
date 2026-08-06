import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// A standardized bottom-sheet scaffold with a cancel / title / confirm header.
///
/// Used as the base structure for picker sheets, filter sheets, and any
/// modal that needs a consistent header with cancel and confirm actions.
///
/// ```dart
/// ParkSheetScaffold.show(
///   context: context,
///   title: '选择城市',
///   onConfirm: () { /* handle confirm */ },
///   child: MyPickerContent(),
/// );
/// ```
class ParkSheetScaffold extends StatelessWidget {
  /// Creates a ParkSheetScaffold.
  const ParkSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onCancel,
    this.onConfirm,
    this.cancelText,
    this.confirmText,
    this.confirmEnabled = true,
    this.bodyHeight,
    this.showDragHandle = true,
    this.header,
  });

  /// Title displayed centered in the header.
  final String title;

  /// Body content below the header.
  final Widget child;

  /// Called when the cancel button is tapped.
  /// If null, the sheet is simply popped.
  final VoidCallback? onCancel;

  /// Called when the confirm button is tapped.
  /// If null, the confirm button is disabled.
  final VoidCallback? onConfirm;

  /// Custom cancel button text. Defaults to [ParkLocalizations.cancelText].
  final String? cancelText;

  /// Custom confirm button text. Defaults to [ParkLocalizations.confirmText].
  final String? confirmText;

  /// Whether the confirm button is enabled.
  final bool confirmEnabled;

  /// Optional fixed height for the body area.
  /// When null, the body sizes itself naturally.
  final double? bodyHeight;

  /// Whether to show the drag handle pill above the header.
  final bool showDragHandle;

  /// Optional custom header widget. When provided, replaces the default
  /// cancel / title / confirm header entirely.
  final Widget? header;

  // ── Static show ──

  /// Shows a [ParkSheetScaffold] as a modal bottom sheet.
  ///
  /// Returns `true` if confirmed, `false` if cancelled, `null` if dismissed.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required Widget child,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    String? cancelText,
    String? confirmText,
    bool confirmEnabled = true,
    double? bodyHeight,
    bool showDragHandle = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    Widget? header,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ParkSheetScaffold(
        title: title,
        onCancel: onCancel ?? () => Navigator.of(ctx).pop(false),
        onConfirm: onConfirm ?? () => Navigator.of(ctx).pop(true),
        cancelText: cancelText,
        confirmText: confirmText,
        confirmEnabled: confirmEnabled,
        bodyHeight: bodyHeight,
        showDragHandle: showDragHandle,
        header: header,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;
    final radius = park.radius;

    final effectiveCancelText = cancelText ?? l10n.cancelText;
    final effectiveConfirmText = confirmText ?? l10n.confirmText;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            if (showDragHandle)
              Padding(
                padding: EdgeInsets.only(top: spacing.sm),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Header
            header ??
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.base,
                    vertical: spacing.md,
                  ),
                  child: Row(
                    children: [
                      // Cancel
                      Semantics(
                        label: effectiveCancelText,
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            if (onCancel != null) {
                              onCancel!();
                            } else {
                              Navigator.of(context).pop(false);
                            }
                          },
                          child: Text(
                            effectiveCancelText,
                            style: TextStyle(
                              fontSize: typo.sizeBody,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      // Title
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: typo.sizeH3,
                            fontWeight: typo.weightMedium,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),

                      // Confirm
                      Semantics(
                        label: effectiveConfirmText,
                        button: true,
                        enabled: confirmEnabled,
                        child: GestureDetector(
                          onTap: confirmEnabled
                              ? () {
                                  if (onConfirm != null) {
                                    onConfirm!();
                                  } else {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              : null,
                          child: Text(
                            effectiveConfirmText,
                            style: TextStyle(
                              fontSize: typo.sizeBody,
                              fontWeight: typo.weightMedium,
                              color: confirmEnabled
                                  ? colors.brand
                                  : colors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

            // Divider
            Divider(height: 1, color: colors.divider),

            // Body
            if (bodyHeight != null)
              SizedBox(height: bodyHeight, child: child)
            else
              Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
