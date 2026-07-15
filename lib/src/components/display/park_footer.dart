import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 页脚链接
class ParkFooterLink {
  /// 链接文本
  final String label;

  /// 链接地址（可选）
  final String? href;

  /// 点击回调
  final VoidCallback? onTap;

  const ParkFooterLink({
    required this.label,
    this.href,
    this.onTap,
  });
}

/// Park 页脚组件
///
/// 用于页面底部展示品牌 logo、导航链接和版权信息。
///
/// ```dart
/// ParkFooter(
///   logo: Image.asset('assets/logo.png', height: 32),
///   text: 'Park UI',
///   links: [
///     ParkFooterLink(label: '关于我们', onTap: () {}),
///     ParkFooterLink(label: '服务条款', onTap: () {}),
///     ParkFooterLink(label: '隐私政策', onTap: () {}),
///   ],
///   copyright: '© 2025 Park UI. All rights reserved.',
/// )
/// ```
class ParkFooter extends StatelessWidget {
  /// 页脚文字（品牌名称等）
  final String text;

  /// Logo 组件
  final Widget? logo;

  /// 链接列表
  final List<ParkFooterLink> links;

  /// 版权信息
  final String? copyright;

  /// 是否在页脚内容上方显示分割线。
  final bool divider;

  const ParkFooter({
    super.key,
    required this.text,
    this.logo,
    this.links = const [],
    this.copyright,
    this.divider = true,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: park.spacing.xl,
        vertical: park.spacing.lg,
      ),
      decoration: BoxDecoration(
        color: park.colors.background,
        border: divider
            ? Border(
                top: BorderSide(color: park.colors.divider, width: 1),
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo + 文字
          _buildBrandRow(park),

          // 链接行
          if (links.isNotEmpty) ...[
            SizedBox(height: park.spacing.md),
            _buildLinkRow(park),
          ],

          // 版权信息
          if (copyright != null) ...[
            SizedBox(height: park.spacing.md),
            Text(
              copyright!,
              style: TextStyle(
                color: park.colors.textSecondary.withValues(alpha: 0.6),
                fontSize: park.typography.sizeCaption,
                fontWeight: park.typography.weightRegular,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandRow(ParkThemeData park) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logo != null) ...[
          logo!,
          SizedBox(width: park.spacing.sm),
        ],
        Text(
          text,
          style: TextStyle(
            color: park.colors.textSecondary,
            fontSize: park.typography.sizeBody,
            fontWeight: park.typography.weightMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkRow(ParkThemeData park) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: park.spacing.lg,
      runSpacing: park.spacing.sm,
      children: links.map((link) {
        return Semantics(
          button: true,
          label: link.label,
          child: GestureDetector(
          onTap: link.onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              link.label,
              style: TextStyle(
                color: park.colors.textSecondary,
                fontSize: park.typography.sizeBodySmall,
                fontWeight: park.typography.weightRegular,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        );
      }).toList(),
    );
  }
}
