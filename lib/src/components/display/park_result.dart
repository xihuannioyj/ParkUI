import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 结果状态类型
enum ParkResultStatus {
  /// 成功
  success,

  /// 错误
  error,

  /// 警告
  warning,

  /// 信息
  info,
}

/// Park 结果展示组件
///
/// 用于展示操作结果状态，包含图标、标题、描述和操作按钮。
/// 常用于表单提交结果、页面加载完成态等场景。
///
/// ```dart
/// ParkResult(
///   status: ParkResultStatus.success,
///   title: '提交成功',
///   description: '您的订单已成功提交，我们将尽快处理。',
///   actions: [
///     ParkButton(child: Text('返回首页'), onPressed: () {}),
///   ],
/// )
/// ```
class ParkResult extends StatelessWidget {
  /// 结果状态
  final ParkResultStatus status;

  /// 自定义图标（优先级高于状态默认图标）
  final Widget? icon;

  /// 标题
  final String title;

  /// 描述
  final String? description;

  /// 操作按钮列表
  final List<Widget>? actions;

  /// Additional action buttons below main actions.
  final List<Widget>? extra;

  /// Rich description widget (takes priority over [description] when set).
  final Widget? descriptionWidget;

  const ParkResult({
    super.key,
    required this.status,
    this.icon,
    required this.title,
    this.description,
    this.descriptionWidget,
    this.actions,
    this.extra,
  });

  /// 403 Forbidden preset.
  factory ParkResult.forbidden({
    Key? key,
    String title = '无权访问',
    String? description = '您没有权限访问此页面，请联系管理员。',
    Widget? descriptionWidget,
    List<Widget>? actions,
    List<Widget>? extra,
  }) {
    return ParkResult(
      key: key,
      status: ParkResultStatus.warning,
      icon: const Icon(Icons.lock_outline, size: 40),
      title: title,
      description: description,
      descriptionWidget: descriptionWidget,
      actions: actions,
      extra: extra,
    );
  }

  /// 404 Not Found preset.
  factory ParkResult.notFound({
    Key? key,
    String title = '页面未找到',
    String? description = '您访问的页面不存在或已被移除。',
    Widget? descriptionWidget,
    List<Widget>? actions,
    List<Widget>? extra,
  }) {
    return ParkResult(
      key: key,
      status: ParkResultStatus.info,
      icon: const Icon(Icons.search_off, size: 40),
      title: title,
      description: description,
      descriptionWidget: descriptionWidget,
      actions: actions,
      extra: extra,
    );
  }

  /// 500 Server Error preset.
  factory ParkResult.serverError({
    Key? key,
    String title = '服务器错误',
    String? description = '服务器遇到内部错误，请稍后重试。',
    Widget? descriptionWidget,
    List<Widget>? actions,
    List<Widget>? extra,
  }) {
    return ParkResult(
      key: key,
      status: ParkResultStatus.error,
      icon: const Icon(Icons.cloud_off, size: 40),
      title: title,
      description: description,
      descriptionWidget: descriptionWidget,
      actions: actions,
      extra: extra,
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    final statusColor = _statusColor(park);
    final statusIcon = _statusIcon(park);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: park.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态图标
            icon ??
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 40,
                  ),
                ),

            SizedBox(height: park.spacing.lg),

            // 标题
            Text(
              title,
              style: TextStyle(
                color: park.colors.textPrimary,
                fontSize: park.typography.sizeH3,
                fontWeight: park.typography.weightBold,
              ),
              textAlign: TextAlign.center,
            ),

            // 描述
            if (descriptionWidget != null) ...[
              SizedBox(height: park.spacing.sm),
              descriptionWidget!,
            ] else if (description != null) ...[
              SizedBox(height: park.spacing.sm),
              Text(
                description!,
                style: TextStyle(
                  color: park.colors.textSecondary,
                  fontSize: park.typography.sizeBody,
                  fontWeight: park.typography.weightRegular,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 操作按钮
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: park.spacing.xl),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!
                    .map((action) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: park.spacing.xs,
                          ),
                          child: action,
                        ))
                    .toList(),
              ),
            ],

            // Additional action buttons
            if (extra != null && extra!.isNotEmpty) ...[
              SizedBox(height: park.spacing.md),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: extra!
                    .map((action) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: park.spacing.xs,
                          ),
                          child: action,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(ParkThemeData park) {
    switch (status) {
      case ParkResultStatus.success:
        return park.colors.success;
      case ParkResultStatus.error:
        return park.colors.error;
      case ParkResultStatus.warning:
        return park.colors.warning;
      case ParkResultStatus.info:
        return park.colors.info;
    }
  }

  IconData _statusIcon(ParkThemeData park) {
    switch (status) {
      case ParkResultStatus.success:
        return Icons.check_circle_outline;
      case ParkResultStatus.error:
        return Icons.error_outline;
      case ParkResultStatus.warning:
        return Icons.warning_amber_outlined;
      case ParkResultStatus.info:
        return Icons.info_outline;
    }
  }
}
