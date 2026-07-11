import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 警告提示组件
///
/// 展示带状态颜色的提示信息，支持成功/警告/错误/信息四种类型。
/// 可配合描述文字、图标和关闭按钮使用。
///
/// ```dart
/// ParkAlert(
///   type: ParkAlertType.warning,
///   message: '系统将在今晚 23:00 进行维护',
///   description: '预计维护时长 2 小时，期间服务不可用。',
///   closable: true,
/// )
/// ```
class ParkAlert extends StatelessWidget {
  /// 提示类型（默认 info）。
  final ParkAlertType type;

  /// 提示标题。
  final String message;

  /// 详细描述（可选）。
  final String? description;

  /// 自定义标题 widget（优先于 [message]）。
  final Widget? messageWidget;

  /// 自定义描述 widget（优先于 [description]）。
  final Widget? descriptionWidget;

  /// 自定义图标 widget（覆盖默认类型图标）。
  final Widget? icon;

  /// 是否可关闭（默认 false）。
  final bool closable;

  /// 关闭回调。
  final VoidCallback? onClose;

  /// 是否显示图标（默认 true）。
  final bool showIcon;

  /// 是否为无边框 banner 风格（默认 false）。
  final bool banner;

  /// 创建 [ParkAlert]。
  const ParkAlert({
    super.key,
    this.type = ParkAlertType.info,
    required this.message,
    this.description,
    this.messageWidget,
    this.descriptionWidget,
    this.icon,
    this.closable = false,
    this.onClose,
    this.showIcon = true,
    this.banner = false,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final (Color bgColor, Color borderColor, Color iconColor, IconData defaultIcon) =
        _getTypeColors(park);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(banner ? park.spacing.md : park.spacing.base),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: banner ? null : park.radius.brSm,
        border: banner ? null : Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon)
            Padding(
              padding: EdgeInsets.only(right: park.spacing.md, top: 1),
              child: icon ??
                  Icon(defaultIcon, size: 20, color: iconColor),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (messageWidget != null)
                  messageWidget!
                else
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: park.colors.textPrimary,
                    ),
                  ),
                if (descriptionWidget != null)
                  Padding(
                    padding: EdgeInsets.only(top: park.spacing.xs),
                    child: descriptionWidget!,
                  )
                else if (description != null)
                  Padding(
                    padding: EdgeInsets.only(top: park.spacing.xs),
                    child: Text(
                      description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: park.colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (closable)
            GestureDetector(
              onTap: onClose,
              child: Padding(
                padding: EdgeInsets.only(left: park.spacing.md),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: park.colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  (Color, Color, Color, IconData) _getTypeColors(ParkThemeData park) {
    switch (type) {
      case ParkAlertType.success:
        return (
          park.colors.successLight,
          park.colors.success.withAlpha(77),
          park.colors.success,
          Icons.check_circle_outline,
        );
      case ParkAlertType.warning:
        return (
          park.colors.warningLight,
          park.colors.warning.withAlpha(77),
          park.colors.warning,
          Icons.warning_amber_outlined,
        );
      case ParkAlertType.error:
        return (
          park.colors.errorLight,
          park.colors.error.withAlpha(77),
          park.colors.error,
          Icons.error_outline,
        );
      case ParkAlertType.info:
        return (
          park.colors.infoLight,
          park.colors.info.withAlpha(77),
          park.colors.info,
          Icons.info_outline,
        );
    }
  }
}

/// 警告提示类型枚举。
enum ParkAlertType {
  /// 成功
  success,

  /// 警告
  warning,

  /// 错误
  error,

  /// 信息
  info,
}
