import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 操作项样式
enum ParkActionStyle { defaultStyle, destructive, disabled }

/// 操作项数据模型
class ParkAction {
  final String label;
  final Widget? icon;
  final ParkActionStyle style;
  final VoidCallback? onTap;

  const ParkAction({
    required this.label,
    this.icon,
    this.style = ParkActionStyle.defaultStyle,
    this.onTap,
  });
}

/// ParkActionSheet — 底部操作面板
class ParkActionSheet extends StatefulWidget {
  final String? title;
  final List<ParkAction> actions;
  final String? cancelText;
  final bool showCancel;
  final bool closeOnTapAction;
  final bool isDismissible;
  final bool enableDrag;

  /// 描述文本，显示在操作项上方。
  final String? description;

  /// 标记为破坏性操作的索引（红色文本）。
  final int? destructiveIndex;

  /// When true, show actions in grid layout instead of list.
  final bool gridMode;

  /// Number of columns in grid mode.
  final int gridColumns;

  /// Callback when cancel button is tapped.
  final VoidCallback? onCancel;

  /// When true, the action sheet has rounded top corners.
  final bool round;

  /// Custom close icon widget (replaces default close button).
  final Widget? closeIcon;

  const ParkActionSheet({
    super.key,
    this.title,
    required this.actions,
    this.cancelText,
    this.showCancel = true,
    this.closeOnTapAction = true,
    this.isDismissible = true,
    this.enableDrag = true,
    this.description,
    this.destructiveIndex,
    this.gridMode = false,
    this.gridColumns = 4,
    this.onCancel,
    this.round = true,
    this.closeIcon,
  });

  /// 弹出操作面板
  static Future<ParkAction?> show(
    BuildContext context, {
    String? title,
    required List<ParkAction> actions,
    String? cancelText,
    bool showCancel = true,
    bool closeOnTapAction = true,
    bool isDismissible = true,
    bool enableDrag = true,
    String? description,
    int? destructiveIndex,
    bool gridMode = false,
    int gridColumns = 4,
    VoidCallback? onCancel,
  }) async {
    final result = await showModalBottomSheet<ParkAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) {
        return _ParkActionSheetContent(
          title: title,
          actions: actions,
          cancelText: cancelText,
          showCancel: showCancel,
          closeOnTapAction: closeOnTapAction,
          description: description,
          destructiveIndex: destructiveIndex,
          gridMode: gridMode,
          gridColumns: gridColumns,
          onCancel: onCancel,
        );
      },
    );
    return result;
  }

  @override
  State<ParkActionSheet> createState() => _ParkActionSheetState();
}

class _ParkActionSheetState extends State<ParkActionSheet> {
  @override
  Widget build(BuildContext context) {
    return _ParkActionSheetContent(
      title: widget.title,
      actions: widget.actions,
      cancelText: widget.cancelText,
      showCancel: widget.showCancel,
      closeOnTapAction: widget.closeOnTapAction,
      description: widget.description,
      destructiveIndex: widget.destructiveIndex,
      gridMode: widget.gridMode,
      gridColumns: widget.gridColumns,
      onCancel: widget.onCancel,
    );
  }
}

class _ParkActionSheetContent extends StatelessWidget {
  final String? title;
  final List<ParkAction> actions;
  final String? cancelText;
  final bool showCancel;
  final bool closeOnTapAction;
  final String? description;
  final int? destructiveIndex;
  final bool gridMode;
  final int gridColumns;
  final VoidCallback? onCancel;

  const _ParkActionSheetContent({
    this.title,
    required this.actions,
    this.cancelText,
    required this.showCancel,
    required this.closeOnTapAction,
    this.description,
    this.destructiveIndex,
    this.gridMode = false,
    this.gridColumns = 4,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final effectiveCancelText = cancelText ?? l10n.cancelText;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: park.spacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Actions container
            Container(
              decoration: BoxDecoration(
                color: park.colors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(park.radius.lg),
                  topRight: Radius.circular(park.radius.lg),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    SizedBox(height: park.spacing.md),
                    Text(
                      title!,
                      style: park.typography.body.copyWith(
                        fontSize: park.typography.sizeBodySmall,
                        color: park.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: park.spacing.sm),
                    Divider(height: 1, color: park.colors.divider),
                  ],
                  if (description != null) ...[
                    SizedBox(height: park.spacing.md),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: park.spacing.base),
                      child: Text(
                        description!,
                        style: park.typography.body.copyWith(
                          fontSize: park.typography.sizeCaption,
                          color: park.colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: park.spacing.sm),
                  ],
                  if (gridMode)
                    Padding(
                      padding: EdgeInsets.all(park.spacing.sm),
                      child: Wrap(
                        children: [
                          for (int i = 0; i < actions.length; i++)
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width / gridColumns
                                  - park.spacing.sm * 2 / gridColumns,
                              child: _buildGridActionItem(context, actions[i], park, i),
                            ),
                        ],
                      ),
                    )
                  else
                    for (int i = 0; i < actions.length; i++)
                      _buildActionItem(context, actions[i], park, i),
                ],
              ),
            ),

            // Gap
            SizedBox(height: park.spacing.sm),

            // Cancel button
            if (showCancel) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: park.colors.surface,
                  borderRadius: park.radius.brLg,
                ),
                child: _buildCancelItem(context, park, effectiveCancelText),
              ),
              SizedBox(height: park.spacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, ParkAction action, ParkThemeData park, int index) {
    final isDisabled = action.style == ParkActionStyle.disabled;
    final isDestructive = action.style == ParkActionStyle.destructive ||
        (destructiveIndex != null && destructiveIndex == index);

    Color textColor;
    if (isDisabled) {
      textColor = park.colors.textSecondary.withValues(alpha: 0.5);
    } else if (isDestructive) {
      textColor = park.colors.error;
    } else {
      textColor = park.colors.textPrimary;
    }

    return Semantics(
      button: !isDisabled,
      enabled: !isDisabled,
      label: action.label,
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                action.onTap?.call();
                if (closeOnTapAction) {
                  Navigator.of(context).pop(action);
                }
              },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: park.spacing.base),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: park.colors.divider, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (action.icon != null) ...[
                action.icon!,
                SizedBox(width: park.spacing.xs),
              ],
              Text(
                action.label,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeBody,
                  fontWeight: park.typography.weightMedium,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelItem(BuildContext context, ParkThemeData park, String text) {
    return Semantics(
      button: true,
      label: text,
      child: GestureDetector(
        onTap: () {
          onCancel?.call();
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: park.spacing.base),
          child: Center(
            child: Text(
              text,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                fontWeight: park.typography.weightBold,
                color: park.colors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridActionItem(BuildContext context, ParkAction action, ParkThemeData park, int index) {
    final isDisabled = action.style == ParkActionStyle.disabled;
    final isDestructive = action.style == ParkActionStyle.destructive ||
        (destructiveIndex != null && destructiveIndex == index);

    Color textColor;
    if (isDisabled) {
      textColor = park.colors.textSecondary.withValues(alpha: 0.5);
    } else if (isDestructive) {
      textColor = park.colors.error;
    } else {
      textColor = park.colors.textPrimary;
    }

    return Semantics(
      button: !isDisabled,
      enabled: !isDisabled,
      label: action.label,
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                action.onTap?.call();
                if (closeOnTapAction) {
                  Navigator.of(context).pop(action);
                }
              },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: park.spacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (action.icon != null) ...[
                action.icon!,
                SizedBox(height: park.spacing.xs),
              ],
              Text(
                action.label,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeCaption,
                  fontWeight: park.typography.weightMedium,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
