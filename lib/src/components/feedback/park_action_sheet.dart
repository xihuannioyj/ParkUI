import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 操作项样式
enum ParkActionStyle { defaultStyle, destructive, disabled }

/// 操作面板尺寸
enum ParkActionSheetSize {
  /// 小尺寸（紧凑内边距与字号）
  small,

  /// 默认尺寸
  medium,

  /// 大尺寸（宽松内边距与字号）
  large,
}

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

  /// 操作面板尺寸（small / medium / large），控制操作项内边距与字号。
  final ParkActionSheetSize size;

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
    this.size = ParkActionSheetSize.medium,
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
    ParkActionSheetSize size = ParkActionSheetSize.medium,
  }) async {
    final result = await showModalBottomSheet<ParkAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      // 淡遮罩：避免默认 black54 全屏变暗（蒙层体验）
      barrierColor: Colors.black.withValues(alpha: 0.10),
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
          size: size,
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
      size: widget.size,
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
  final ParkActionSheetSize size;

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
    this.size = ParkActionSheetSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final effectiveCancelText = cancelText ?? l10n.cancelText;

    // size 令牌：小/中/大 三档内边距与字号
    final double actionVPadding = switch (size) {
      ParkActionSheetSize.small => park.spacing.sm,
      ParkActionSheetSize.medium => park.spacing.base,
      ParkActionSheetSize.large => park.spacing.lg,
    };
    final double gridVPadding = switch (size) {
      ParkActionSheetSize.small => park.spacing.xs,
      ParkActionSheetSize.medium => park.spacing.sm,
      ParkActionSheetSize.large => park.spacing.md,
    };
    final double actionLabelFontSize = switch (size) {
      ParkActionSheetSize.small => park.typography.sizeCaption,
      ParkActionSheetSize.medium => park.typography.sizeBody,
      ParkActionSheetSize.large => park.typography.sizeBody,
    };
    final double gridLabelFontSize = switch (size) {
      ParkActionSheetSize.small => park.typography.sizeOverline,
      ParkActionSheetSize.medium => park.typography.sizeCaption,
      ParkActionSheetSize.large => park.typography.sizeBodySmall,
    };
    // gridColumns <= 0 时钳制为 1，避免除零产生 Infinity 宽度。
    final int safeColumns = gridColumns > 0 ? gridColumns : 1;

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
                              width: MediaQuery.sizeOf(context).width / safeColumns
                                  - park.spacing.sm * 2 / safeColumns,
                              child: _buildGridActionItem(
                                  context, actions[i], park, i,
                                  vPadding: gridVPadding,
                                  labelFontSize: gridLabelFontSize),
                            ),
                        ],
                      ),
                    )
                  else
                    for (int i = 0; i < actions.length; i++)
                      _buildActionItem(context, actions[i], park, i,
                          vPadding: actionVPadding,
                          labelFontSize: actionLabelFontSize),
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
                child: _buildCancelItem(context, park, effectiveCancelText,
                    vPadding: actionVPadding),
              ),
              SizedBox(height: park.spacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    ParkAction action,
    ParkThemeData park,
    int index, {
    required double vPadding,
    required double labelFontSize,
  }) {
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
          padding: EdgeInsets.symmetric(vertical: vPadding),
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
                  fontSize: labelFontSize,
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

  Widget _buildCancelItem(
    BuildContext context,
    ParkThemeData park,
    String text, {
    required double vPadding,
  }) {
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
          padding: EdgeInsets.symmetric(vertical: vPadding),
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

  Widget _buildGridActionItem(
    BuildContext context,
    ParkAction action,
    ParkThemeData park,
    int index, {
    required double vPadding,
    required double labelFontSize,
  }) {
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
          padding: EdgeInsets.symmetric(vertical: vPadding),
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
                  fontSize: labelFontSize,
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
