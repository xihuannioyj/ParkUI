import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 结果状态类型
///
/// 内置 7 种状态，各自关联默认图标与配色：
/// - [success] 成功 — 绿色
/// - [error]   错误 — 红色
/// - [warning] 警告 — 橙色
/// - [info]    信息 — 蓝色（默认）
/// - [status403] 无权限 — 橙色 + 锁图标 + 大尺寸
/// - [status404] 未找到 — 灰色 + 搜索图标 + 大尺寸
/// - [status500] 服务器错误 — 红色 + bug 图标 + 大尺寸
enum ParkResultStatus {
  /// 成功
  success,

  /// 错误
  error,

  /// 警告
  warning,

  /// 信息（默认）
  info,

  /// 403 Forbidden
  status403,

  /// 404 Not Found
  status404,

  /// 500 Internal Server Error
  status500,
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
  /// 结果状态（默认 [ParkResultStatus.info]）
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
    this.status = ParkResultStatus.info,
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
      status: ParkResultStatus.status403,
      icon: const Icon(Icons.lock, size: 56),
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
      status: ParkResultStatus.status404,
      icon: const Icon(Icons.search_off, size: 56),
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
      status: ParkResultStatus.status500,
      icon: const Icon(Icons.bug_report, size: 56),
      title: title,
      description: description,
      descriptionWidget: descriptionWidget,
      actions: actions,
      extra: extra,
    );
  }

  /// 是否为 HTTP 状态码类状态（使用大图标 + 副标题）。
  bool get _isHttpStatus {
    return status == ParkResultStatus.status403 ||
        status == ParkResultStatus.status404 ||
        status == ParkResultStatus.status500;
  }

  /// HTTP 状态码文本，非 HTTP 状态返回 null。
  String? get _statusCodeText {
    switch (status) {
      case ParkResultStatus.status403:
        return '403';
      case ParkResultStatus.status404:
        return '404';
      case ParkResultStatus.status500:
        return '500';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final statusColor = _statusColor(park);
    final statusIcon = _statusIcon(park);
    final isHttp = _isHttpStatus;
    final codeText = _statusCodeText;
    final iconContainerSize = isHttp ? 96.0 : 72.0;
    final iconSize = isHttp ? 56.0 : 40.0;

    // Build semantics label
    final buffer = StringBuffer(title);
    if (description != null) {
      buffer.write('，$description');
    }
    if (codeText != null) {
      buffer.write('，状态码 $codeText');
    }

    return Semantics(
      label: buffer.toString(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: park.spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 状态图标
              icon ??
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: iconSize,
                    ),
                  ),

              SizedBox(height: park.spacing.lg),

              // HTTP 状态码副标题（仅对 403/404/500 显示）
              if (codeText != null) ...[
                Text(
                  codeText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: park.typography.sizeH1,
                    fontWeight: park.typography.weightBold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: park.spacing.xs),
              ],

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
      case ParkResultStatus.status403:
        return park.colors.warning;
      case ParkResultStatus.status404:
        return park.colors.textDisabled;
      case ParkResultStatus.status500:
        return park.colors.error;
    }
  }

  IconData _statusIcon(ParkThemeData park) {
    switch (status) {
      case ParkResultStatus.success:
        return Icons.check_circle;
      case ParkResultStatus.error:
        return Icons.error;
      case ParkResultStatus.warning:
        return Icons.warning_amber;
      case ParkResultStatus.info:
        return Icons.info;
      case ParkResultStatus.status403:
        return Icons.lock;
      case ParkResultStatus.status404:
        return Icons.search_off;
      case ParkResultStatus.status500:
        return Icons.bug_report;
    }
  }
}
