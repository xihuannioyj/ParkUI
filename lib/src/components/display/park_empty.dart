import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
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
    this.illustration,
    this.gradientPlaceholder = false,
    this.glassContainer = false,
    this.description,
    this.descriptionWidget,
    this.actions,
    this.footer,
    this.size = ParkEmptySize.medium,
    this.type = ParkEmptyType.noData,
  });

  /// 高优先级插图。
  ///
  /// 🔴 优先级最高：`illustration` > [image] > [icon]。
  /// 与 [image] 的区别是语义 —— [image] 是"用户给的图片"，
  /// [illustration] 是"用户给的插画 / 组合图形"，分开命名便于
  /// 未来对二者施加不同的无障碍描述。
  final Widget? illustration;

  /// 无插图时，是否用**渐变占位块**代替裸图标。
  ///
  /// 占位块 = 圆角渐变方块（`park.gradients.brand`）+ 居中图标，
  /// 尺寸随 [size] 变化（small 48 / medium 72 / large 96）。
  /// 图标色取 `colors.textOnBrand`（前景令牌），保证与渐变底对比度达标。
  final bool gradientPlaceholder;

  /// 插图区是否使用玻璃容器包裹。
  ///
  /// 与 glass 风格协调。⚠️ 空状态在页面上一屏只有一个时开销可接受；
  /// 若空状态出现在列表 item 内（可能有很多个），请置 false。
  final bool glassContainer;

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

  /// 渐变占位块的边长（随 [size] 变化）。
  ///
  /// 与 [_iconSize] 区分：占位块比裸图标大一圈，给渐变留出呼吸空间。
  double get _placeholderSize {
    switch (size) {
      case ParkEmptySize.small:
        return 48;
      case ParkEmptySize.medium:
        return 72;
      case ParkEmptySize.large:
        return 96;
    }
  }

  /// 渐变占位块内的图标尺寸。
  double get _placeholderIconSize => _placeholderSize * 0.44;

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

    // 插图区优先级：illustration > image > (gradientPlaceholder ? 渐变块 : 裸图标)。
    // 三者互斥，保证任何时刻只渲染一个插图。
    final Widget? topIllustration = illustration ?? image;
    final bool useGradientBlock = topIllustration == null && gradientPlaceholder;

    final Widget illustrationArea = _buildIllustrationArea(
      context: context,
      park: park,
      topIllustration: topIllustration,
      useGradientBlock: useGradientBlock,
      iconData: effectiveIcon,
      iconColor: effectiveIconColor,
    );

    return Semantics(
      label: label,
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxH = constraints.maxHeight == double.infinity
              ? double.infinity
              : constraints.maxHeight;
          final bounded = maxH != double.infinity;
          return Center(
            child: ConstrainedBox(
              constraints: bounded
                  ? BoxConstraints(maxHeight: maxH)
                  : const BoxConstraints(),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: park.spacing.lg,
                    vertical: park.spacing.base,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _withSpacing(
                        Semantics(
                          image: true,
                          excludeSemantics: useGradientBlock,
                          label: useGradientBlock ? 'Empty illustration' : null,
                          child: illustrationArea,
                        ),
                      ),
                      if (bounded)
                        Expanded(
                          child: Center(
                            child: descriptionWidget ??
                                Text(
                                  effectiveDescription,
                                  textAlign: TextAlign.center,
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    color: park.colors.textSecondary,
                                  ),
                                ),
                          ),
                        )
                      else
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
            ),
          );
        },
      ),
    );
  }

  /// 给插图区追加与描述之间的间距。
  Widget _withSpacing(Widget child) =>
      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        child,
        SizedBox(height: _spacing),
      ]);

  /// 构建插图区 —— **5 种表面风格自动联动**，无需调用方配置。
  ///
  /// 材质全部由 [ParkSurfaceTokens.resolve] 派生（组件内不判断风格）：
  /// - stripe：表面色 + 边框（现状，零回归）；
  /// - flat  ：表面色，无阴影；
  /// - glass ：半透明填充（glassContainer 时再叠背景模糊）；
  /// - neo   ：同色面 + 双柔光；
  /// - neon  ：深色面 + 品牌辉光边。
  Widget _buildIllustrationArea({
    required BuildContext context,
    required ParkThemeData park,
    required Widget? topIllustration,
    required bool useGradientBlock,
    required IconData iconData,
    required Color iconColor,
  }) {
    // 优先级 1/2：用户提供的插画 / 图片，原样渲染（不做任何包裹），
    // 以免改变用户自己设计的排版。
    if (topIllustration != null) return topIllustration;

    // 优先级 3：渐变占位块。
    if (useGradientBlock) {
      final double box = _placeholderSize;
      return DecoratedBox(
        decoration: BoxDecoration(
          // 渐变取自令牌（随预设联动），非硬编码色值。
          gradient: park.gradients.brand.asFlutter,
          // 圆角取自 ParkRadius 令牌，非魔法数。
          borderRadius: BorderRadius.circular(park.radius.md),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: park.colors.brand.withValues(alpha: 0.24),
              blurRadius: park.blur.md,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          width: box,
          height: box,
          child: Icon(
            iconData,
            // 图标色取前景令牌（反色面），与渐变底对比度达标。
            size: _placeholderIconSize,
            color: park.colors.textOnBrand,
          ),
        ),
      );
    }

    // 优先级 4：裸图标（默认，行为与改造前一致）。
    final Widget bareIcon = Icon(iconData, size: _iconSize, color: iconColor);

    if (!glassContainer) return bareIcon;

    // glassContainer：套一层玻璃容器，与 glass 风格协调。
    final ParkSurfaceTokens surface = ParkSurfaceTokens.resolve(
      style: ParkSurfaceStyleScope.of(context),
      colors: park.colors,
      radius: park.radius,
      blur: park.blur,
      bordered: false,
    );
    final double box = _iconSize * 1.6;
    return Container(
      width: box,
      height: box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: surface.fill.withValues(alpha: surface.glassAlpha),
        borderRadius: BorderRadius.circular(park.radius.lg),
        border: Border.all(
          color: park.colors.textOnBrand.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: bareIcon,
    );
  }
}
