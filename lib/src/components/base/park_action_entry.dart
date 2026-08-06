import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import '../base/park_icon.dart';
import '../base/park_ink_well.dart';

/// 操作入口色调枚举：主色/中性/危险。
enum ParkActionTone {
  /// 主色（品牌色）。
  primary,

  /// 中性（次要文字色）。
  neutral,

  /// 危险（品牌危险红）。
  danger,
}

/// 通用操作图标按钮：图标+文案操作入口。
///
/// 圆角方形图标按钮，支持 [tooltip]、色调与自定义图标尺寸。
class ParkActionIconButton extends StatelessWidget {
  /// 图标。
  final IconData icon;

  /// 点击回调（null 时呈禁用态）。
  final VoidCallback? onPressed;

  /// 可选工具提示。
  final String? tooltip;

  /// 色调。
  final ParkActionTone tone;

  /// 图标尺寸（默认 18）。
  final double? iconSize;

  const ParkActionIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.tone = ParkActionTone.primary,
    this.iconSize,
  });

  Color _foregroundColor(ParkThemeData park) {
    switch (tone) {
      case ParkActionTone.danger:
        return const Color(0xFFD9485F);
      case ParkActionTone.neutral:
        return park.colors.textSecondary;
      case ParkActionTone.primary:
        return park.colors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final foreground = _foregroundColor(park);
    final Widget iconButton = SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            foreground.withValues(alpha: onPressed == null ? 0.05 : 0.08),
            park.colors.surface,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: park.colors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Center(
          child: ParkIcon(
            icon,
            pixelSize: iconSize ?? 18,
            color: foreground,
            container: ParkIconContainer.none,
          ),
        ),
      ),
    );
    final Widget buttonChild = (tooltip != null && tooltip!.isNotEmpty)
        ? Tooltip(message: tooltip!, child: iconButton)
        : iconButton;

    return Material(
      color: Colors.transparent,
      child: ParkInkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: buttonChild,
      ),
    );
  }
}

/// 通用操作平铺入口：平铺式操作项。
///
/// 带图标、标题、可选副标题与角标文字的操作卡片，右侧带箭头指示。
class ParkActionTile extends StatelessWidget {
  /// 图标。
  final IconData icon;

  /// 标题。
  final String title;

  /// 可选副标题。
  final String? subtitle;

  /// 可选角标文字。
  final String? trailingText;

  /// 点击回调。
  final VoidCallback onTap;

  /// 色调。
  final ParkActionTone tone;

  const ParkActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    required this.onTap,
    this.tone = ParkActionTone.primary,
  });

  Color _foregroundColor(ParkThemeData park) {
    switch (tone) {
      case ParkActionTone.danger:
        return const Color(0xFFD9485F);
      case ParkActionTone.neutral:
        return park.colors.textSecondary;
      case ParkActionTone.primary:
        return park.colors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final foreground = _foregroundColor(park);
    final muted = park.colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: ParkInkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              foreground.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.14 : 0.08,
              ),
              park.colors.surface,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: park.colors.border.withValues(alpha: 0.85),
            ),
            boxShadow: theme.brightness == Brightness.dark
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            children: [
              ParkIcon(
                icon,
                pixelSize: 20,
                color: foreground,
                container: ParkIconContainer.rounded,
                containerColor: foreground.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: park.colors.textPrimary,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingText != null && trailingText!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(park.radius.full),
                  ),
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              ParkIcon(
                Icons.arrow_forward_ios_rounded,
                pixelSize: 14,
                color: muted.withValues(alpha: 0.8),
                container: ParkIconContainer.none,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
