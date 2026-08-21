import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_text.dart';
import 'park_loading.dart';

/// 统一的局部加载组件。
///
/// 约定三种常用场景：
/// - 页面主体空白加载：使用 [ParkInlineLoading.page]
/// - 图片/卡片局部占位：使用 [ParkInlineLoading.compact]
/// - 按钮内图标加载：使用 [ParkInlineLoading.button]
class ParkInlineLoading extends StatelessWidget {
  /// 加载尺寸。
  final double size;

  /// 加载颜色。
  final Color? color;

  /// 可选文案。
  final String? text;

  /// 是否使用白卡风格面板。
  final bool usePanel;

  /// 是否居中包裹。
  final bool centered;

  const ParkInlineLoading({
    super.key,
    this.size = 24,
    this.color,
    this.text,
    this.usePanel = false,
    this.centered = false,
  });

  /// 页面主体加载态。
  const ParkInlineLoading.page({super.key, this.text, this.color})
      : size = 26,
        usePanel = true,
        centered = true;

  /// 局部卡片/图片占位加载态。
  const ParkInlineLoading.compact({super.key, this.size = 24, this.color})
      : text = null,
        usePanel = false,
        centered = true;

  /// 按钮内图标加载态。
  const ParkInlineLoading.button({
    super.key,
    this.size = 16,
    // 主题统一：默认 null 由 ParkLoading 按主题解析（深色按钮上用反色），
    // 原硬编码 Colors.white 在暗色主题下置于深色背景上不可见。
    this.color,
  })  : text = null,
        usePanel = false,
        centered = false;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (usePanel) {
      child = ParkLoadingPanel(
        text: text ?? ParkLocalizations.of(context).loading,
        withMask: false,
      );
    } else {
      child = ParkLoading(
        type: ParkLoadingType.circular,
        size: size,
        color: color,
      );
    }

    if (centered) {
      return Center(child: child);
    }

    return child;
  }
}

/// 统一白卡式加载面板。
class ParkLoadingPanel extends StatelessWidget {
  /// 加载文案。
  final String text;

  /// 是否展示半透明遮罩。
  final bool withMask;

  const ParkLoadingPanel({super.key, required this.text, this.withMask = true});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final Widget card = RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: park.colors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A111827),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParkLoading(
              type: ParkLoadingType.circular,
              size: 26,
              color: park.colors.brand,
            ),
            const SizedBox(height: 10),
            ParkText(
              text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: park.colors.textPrimary,
            ),
          ],
        ),
      ),
    );

    if (!withMask) {
      return Center(child: card);
    }

    return AbsorbPointer(
      child: Container(
        // 主题统一：遮罩走 overlay 令牌（原硬编码白色面纱在暗色主题下刺眼）
        color: park.colors.overlay.withValues(alpha: 0.18),
        alignment: Alignment.center,
        child: card,
      ),
    );
  }
}
