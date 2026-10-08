import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../theme/tokens/park_gradient.dart';
import '../base/park_surface.dart';
import 'park_glass_panel.dart';

/// Tag visual variant.
enum ParkTagVariant { dark, light, outline }

/// Tag 特效维度（**与 [ParkTagVariant] 正交**，向后兼容的关键）。
///
/// ## 为什么不扩展 [ParkTagVariant]
///
/// [ParkTagVariant] 是已发布的公开 API，且用户已用 `customColor` 组合出
/// 各种效果。若把 gradient / glass / neon 塞进同一个枚举：
/// - 任何 `switch (variant)` 都会因新增值而漏分支；
/// - `variant` 的语义会从"明暗填充方式"膨胀成"明暗 + 材质"，
///    `dark` 与 `neon` 的区别变得不可解释。
///
/// 因此本枚举是**独立的正交维度**：只回答"要不要材质特效"，
/// 不回答"填充是深还是浅"。
///
/// ## 与 surfaceStyle 的关系
///
/// [effect] 为 null 时按当前风格自动推断（见 `ParkTagEffect.inferFor`），
/// 因此零配置也能随主题变化；显式传入时优先生效。
enum ParkTagEffect {
  /// 不使用任何特效（纯色填充，等价既有观感）。
  none,

  /// 渐变填充（[ShaderMask]），文字用前景令牌保证对比度。
  gradient,

  /// 玻璃拟态：半透明填充 + 背景模糊 + 高光边。
  ///
  /// ⚠️ **禁止放在长列表**（同 [ParkGlassPanel] 的性能边界）。
  glass,

  /// 霓虹：半透明品牌底 + 品牌色辉光描边 + 辉光投影。
  neon;

  /// 按当前表面风格推断默认特效。
  ///
  /// 推断规则让"零配置随主题变"成立，同时保证 **stripe 推断为
  /// [none]** —— 即现有默认主题下渲染结果与改造前**逐像素一致**。
  static ParkTagEffect inferFor(ParkSurfaceStyle style) => switch (style) {
    ParkSurfaceStyle.glass => ParkTagEffect.glass,
    ParkSurfaceStyle.neon => ParkTagEffect.neon,
    _ => ParkTagEffect.none,
  };
}

/// Tag color theme.
enum ParkTagTheme { defaultTheme, primary, success, warning, danger }

/// Tag size preset.
enum ParkTagSize { small, medium, large }

/// Tag shape.
enum ParkTagShape { square, round }

/// An inline label / chip component.
///
/// Supports multiple color themes, variants (dark/light/outline),
/// optional close button, tap callback, checkable toggle, link mode,
/// and convenience [outline] / [light] shorthand flags.
///
/// ## 特效维度
///
/// [effect] 是一个与 [variant] **正交**的新维度，提供
/// gradient / glass / neon 三种材质特效，且默认按主题风格自动推断。
/// 🔴 向后兼容保证：`effect == null` 且主题为 stripe（默认）时，
/// 推断结果为 [ParkTagEffect.none]，渲染路径与改造前**完全一致**。
class ParkTag extends StatelessWidget {
  /// Creates a ParkTag.
  const ParkTag({
    super.key,
    required this.text,
    this.variant = ParkTagVariant.light,
    this.theme = ParkTagTheme.defaultTheme,
    this.size = ParkTagSize.medium,
    this.shape = ParkTagShape.square,
    this.closable = false,
    this.onClose,
    this.icon,
    this.onPressed,
    this.checkable = false,
    this.checked = false,
    this.onChecked,
    this.outline = false,
    this.light = false,
    this.href,
    this.maxWidth,
    this.customColor,
    this.bordered = true,
    this.effect,
    this.gradient,
    this.intensity,
  });

  /// Label text.
  final String text;

  /// Visual variant.
  final ParkTagVariant variant;

  /// Color theme.
  final ParkTagTheme theme;

  /// Size preset.
  final ParkTagSize size;

  /// Square (small radius) or round (pill) shape.
  final ParkTagShape shape;

  /// Whether to show a close button.
  final bool closable;

  /// Close button callback.
  final VoidCallback? onClose;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Tap callback for the whole tag.
  final VoidCallback? onPressed;

  /// When true, tag toggles between checked/unchecked on tap.
  final bool checkable;

  /// Current checked state for checkable tags (nullable for external control).
  final bool? checked;

  /// Fires when the checked state should change.
  final ValueChanged<bool>? onChecked;

  /// Convenience flag — renders with outline-only style
  /// (transparent background, colored border). Overrides [variant].
  final bool outline;

  /// Convenience flag — renders with light tinted background +
  /// darker text (softer appearance). Overrides [variant].
  final bool light;

  /// When set, renders as a clickable link. Tap opens the URL
  /// via platform clipboard fallback (since url_launcher is not
  /// a dependency, copies to clipboard and shows a snackbar).
  final String? href;

  /// Maximum width for the text label, truncating with ellipsis if exceeded.
  final double? maxWidth;

  /// Arbitrary custom color that overrides the theme-based color.
  final Color? customColor;

  /// Whether to show a border around the tag.
  final bool bordered;

  /// 材质特效；null 时按当前主题风格自动推断。
  ///
  /// 与 [variant] 正交：`variant` 决定"深/浅/描边"，`effect` 决定
  /// "要不要渐变/玻璃/霓虹"。默认主题（stripe）下推断为
  /// [ParkTagEffect.none]，因此**现有调用方渲染结果不变**。
  final ParkTagEffect? effect;

  /// `gradient` 特效使用的渐变；null 时取主题的 `gradients.brand`。
  final ParkGradient? gradient;

  /// `glass` / `neon` 特效强度（0-1）；null 时取主题派生的默认值。
  final double? intensity;

  // -- Size helpers --

  double get _fontSize {
    switch (size) {
      case ParkTagSize.small:
        return 10;
      case ParkTagSize.medium:
        return 12;
      case ParkTagSize.large:
        return 14;
    }
  }

  double get _verticalPadding {
    switch (size) {
      case ParkTagSize.small:
        return 1;
      case ParkTagSize.medium:
        return 3;
      case ParkTagSize.large:
        return 5;
    }
  }

  double get _horizontalPadding {
    switch (size) {
      case ParkTagSize.small:
        return 4;
      case ParkTagSize.medium:
        return 8;
      case ParkTagSize.large:
        return 12;
    }
  }

  double get _iconSize {
    switch (size) {
      case ParkTagSize.small:
        return 12;
      case ParkTagSize.medium:
        return 14;
      case ParkTagSize.large:
        return 16;
    }
  }

  // -- Resolved variant (outline/light flags override) --

  ParkTagVariant get _effectiveVariant {
    if (outline) return ParkTagVariant.outline;
    if (light) return ParkTagVariant.light;
    return variant;
  }

  // -- Color helpers --

  Color _themeColor(ParkThemeData park) {
    if (customColor != null) return customColor!;
    switch (theme) {
      case ParkTagTheme.defaultTheme:
        return park.colors.textSecondary;
      case ParkTagTheme.primary:
        return park.colors.brand;
      case ParkTagTheme.success:
        return park.colors.success;
      case ParkTagTheme.warning:
        return park.colors.warning;
      case ParkTagTheme.danger:
        return park.colors.error;
    }
  }

  Color _themeLightColor(ParkThemeData park) {
    if (customColor != null) return customColor!.withValues(alpha: 0.1);
    switch (theme) {
      case ParkTagTheme.defaultTheme:
        return park.colors.disabledBg;
      case ParkTagTheme.primary:
        return park.colors.brandLight;
      case ParkTagTheme.success:
        return park.colors.successLight;
      case ParkTagTheme.warning:
        return park.colors.warningLight;
      case ParkTagTheme.danger:
        return park.colors.errorLight;
    }
  }

  Color _resolveBg(ParkThemeData park) {
    final base = _themeColor(park);
    final v = _effectiveVariant;
    switch (v) {
      case ParkTagVariant.dark:
        // When checkable and checked, use brand color
        if (checkable && _isChecked) return park.colors.brand;
        return base;
      case ParkTagVariant.light:
        if (checkable && _isChecked) return park.colors.brand.withValues(alpha: 0.1);
        return _themeLightColor(park);
      case ParkTagVariant.outline:
        if (checkable && _isChecked) return park.colors.brand.withValues(alpha: 0.06);
        return Colors.transparent;
    }
  }

  Color _resolveText(ParkThemeData park) {
    final v = _effectiveVariant;
    switch (v) {
      case ParkTagVariant.dark:
        if (checkable && _isChecked) return park.colors.textOnBrand;
        return theme == ParkTagTheme.defaultTheme
            ? park.colors.surface
            : park.colors.textOnBrand;
      case ParkTagVariant.light:
        if (checkable && _isChecked) return park.colors.brand;
        return _themeColor(park);
      case ParkTagVariant.outline:
        if (checkable && _isChecked) return park.colors.brand;
        return _themeColor(park);
    }
  }

  Color _resolveBorder(ParkThemeData park) {
    final v = _effectiveVariant;
    if (v == ParkTagVariant.outline) {
      if (checkable && _isChecked) return park.colors.brand;
      return _themeColor(park);
    }
    // Show border when checkable and checked in light mode
    if (checkable && _isChecked && v == ParkTagVariant.light) {
      return park.colors.brand.withValues(alpha: 0.3);
    }
    return Colors.transparent;
  }

  BorderRadius _resolveRadius(ParkThemeData park) {
    if (shape == ParkTagShape.round) {
      return park.radius.brFull;
    }
    return BorderRadius.circular(park.radius.xs);
  }

  /// Resolved checked state (null → false).
  bool get _isChecked => checked ?? false;

  // -- Effect (material special effects) --

  /// 解析生效的 [ParkTagEffect]。
  ///
  /// 优先级：显式 [effect] > 按当前风格推断。
  /// 🔴 推断依赖 `BuildContext`，故与 build 逻辑放在一起。
  ParkTagEffect _resolveEffect(BuildContext context) =>
      effect ?? ParkTagEffect.inferFor(ParkSurfaceStyleScope.of(context));

  /// 特效生效时的填充 / 边框 / 前景 / 阴影。
  ///
  /// 返回 null 表示"当前特效不接管渲染"，调用方回退到既有的
  /// `_resolveBg` / `_resolveText` / `_resolveBorder` 逻辑 ——
  /// 这是向后兼容的结构性保证：默认路径一行代码都没变。
  _TagEffectStyle? _resolveEffectStyle(
    BuildContext context,
    ParkThemeData park,
    ParkTagEffect active,
  ) {
    if (active == ParkTagEffect.none) return null;

    final double i = (intensity ?? 1.0).clamp(0.0, 1.0);

    // 品牌 / 主题色：特效统一以"主题色"为基底，
    // 🔴 绝不用 customColor 参与特效（避免用户传入半透明色导致特效失效）。
    final Color accent = _themeColor(park);

    switch (active) {
      case ParkTagEffect.none:
        return null;

      case ParkTagEffect.gradient:
        // 文字色必须由前景令牌决定：反色面色（明底白字/暗底黑字），
        // 禁止把 brand 当前景 —— brand 与 brand 的渐变叠加后不可读。
        final Color foreground = ParkColors.contrastRatio(
          park.colors.textOnBrand,
          accent,
        ) >= 4.5
            ? park.colors.textOnBrand
            // 回退到"与主题底色反差更大的那个"，保证渐变上的文字可读。
            : (ParkColors.contrastRatio(park.colors.textPrimary, accent) >=
                      ParkColors.contrastRatio(
                        park.colors.textOnBrand,
                        accent,
                      )
                  ? park.colors.textPrimary
                  : park.colors.textOnBrand);
        return _TagEffectStyle(
          gradient: gradient ?? park.gradients.brand,
          textColor: foreground,
          // 渐变本身即是"边框"，不再叠加实色边框。
          borderColor: null,
        );

      case ParkTagEffect.glass:
        // 玻璃标签的文字用**表面令牌标题色**（而非 accent 当前景）：
        // 玻璃底是半透明白/浅色，用品牌色当前景会在浅底上不可读。
        //
        // 同时用这份令牌决定"要不要模糊"，保证降级路径与
        // ParkGlassPanel 判定一致（同为 ParkSurfaceBlurDepth + 系统偏好）。
        final ParkSurfaceTokens glass = ParkSurfaceTokens.resolve(
          style: ParkSurfaceStyleScope.of(context),
          colors: park.colors,
          radius: park.radius,
          blur: park.blur,
          bordered: false,
        );
        final bool blurAllowed =
            !MediaQuery.disableAnimationsOf(context) &&
            ParkSurfaceBlurDepth.of(context) < 1;
        return _TagEffectStyle(
          // 半透明填充，alpha 来自材质令牌而非魔法数。
          fill: glass.fill.withValues(
            alpha: ParkGlassPanel.minFillAlpha +
                (glass.glassAlpha - ParkGlassPanel.minFillAlpha) * i,
          ),
          textColor: glass.titleColor,
          // 描边复用统一规则（暗底亮边 / 亮底暗边），避免 neon 亮底描边消失。
          borderColor: ParkGlassPanel.hairlineColorFor(
            fill: glass.fill,
            colors: park.colors,
            isDark: glass.isDark,
          ).withValues(alpha: ParkGlassPanel.hairlineAlpha * i),
          useBackdropFilter: blurAllowed,
          blurSigma: blurAllowed ? park.blur.sm * i : 0.0,
        );

      case ParkTagEffect.neon:
        // 🔴 辉光与边框一律取自 neon 风格的表面令牌
        // （ParkSurfaceTokens.resolve(style: neon)），不写魔法数 ——
        // 换预设 / 调色板时霓虹标签自动跟随，且与霓虹卡片观感一致。
        final ParkSurfaceTokens neonSurface = ParkSurfaceTokens.resolve(
          style: ParkSurfaceStyle.neon,
          colors: park.colors,
          radius: park.radius,
          blur: park.blur,
        );
        return _TagEffectStyle(
          // 底色是很淡的品牌透明层，因此前景用 accent 本身即达标；
          // 兜底仍走令牌标题色，防止未来色板变化导致不可读。
          fill: accent.withValues(alpha: 0.16 * i + 0.04),
          textColor: ParkColors.contrastRatio(accent, accent.withValues(alpha: 0.2)) >=
                      3.0
              ? accent
              : neonSurface.titleColor,
          borderColor: accent.withValues(alpha: 0.55 * i),
          // 辉光：复用材质令牌给出的霓虹阴影，按 intensity 缩放。
          shadows: neonSurface.shadows == null
              ? null
              : <BoxShadow>[
                  for (final BoxShadow s in neonSurface.shadows!)
                    BoxShadow(
                      color: s.color.withValues(alpha: s.color.a * i),
                      blurRadius: s.blurRadius * i,
                      offset: s.offset,
                    ),
                ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 特效维度与 variant 正交：effectStyle 为 null 时下面三个 resolve
    // 走的仍是与改造前逐字一致的既有逻辑（向后兼容的结构性保证）。
    final ParkTagEffect activeEffect = _resolveEffect(context);
    final _TagEffectStyle? effectStyle = _resolveEffectStyle(
      context,
      park,
      activeEffect,
    );

    final bg = effectStyle?.fill ?? _resolveBg(park);
    final textColor = effectStyle?.textColor ?? _resolveText(park);
    final borderColor = effectStyle?.borderColor ?? _resolveBorder(park);
    final radius = _resolveRadius(park);

    final children = <Widget>[];

    // Checked icon for checkable tags
    if (checkable && _isChecked) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: park.spacing.xxs),
          child: Icon(Icons.check, size: _iconSize, color: textColor),
        ),
      );
    }

    if (icon != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: park.spacing.xs),
          child: icon,
        ),
      );
    }

    // Text (with optional underline for href, and maxWidth truncation)
    Widget textWidget = Text(
      text,
      style: TextStyle(
        fontSize: _fontSize,
        fontWeight: park.typography.weightMedium,
        color: textColor,
        height: 1.2,
        decoration: href != null ? TextDecoration.underline : null,
        decorationColor: textColor,
      ),
      overflow: maxWidth != null ? TextOverflow.ellipsis : null,
      maxLines: maxWidth != null ? 1 : null,
    );
    if (maxWidth != null) {
      textWidget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: textWidget,
      );
    }
    children.add(textWidget);

    // Link icon for href
    if (href != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: park.spacing.xxs),
          child: Icon(Icons.open_in_new, size: _iconSize, color: textColor),
        ),
      );
    }

    if (closable) {
      children.add(
        Semantics(
          button: true,
          label: ParkLocalizations.of(context).closeText,
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(left: park.spacing.xs),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  Icons.close,
                  key: ValueKey<String>('close_$text'),
                  size: _iconSize,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 标签主体：渐变走 ShaderMask（背景色设为透明，由着色器提供颜色）。
    //
    // 三个局部变量在闭包里被捕获，先取出可空值再收窄，
    // 避免在 shaderCallback 闭包内反复写 `!`（那会触发
    // unnecessary_non_null_assertion 警告）。
    final ParkGradient? strokeGradient = effectStyle?.gradient;
    final bool useGlass = effectStyle?.useBackdropFilter ?? false;
    final double glassSigma = effectStyle?.blurSigma ?? 0.0;

    final Widget tagInner = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: strokeGradient == null ? bg : null,
        borderRadius: radius,
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: effectStyle?.shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    final Widget tag = strokeGradient != null
        ? ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: strokeGradient.asFlutter.createShader,
            child: tagInner,
          )
        : useGlass
        ? ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: glassSigma,
                sigmaY: glassSigma,
              ),
              child: tagInner,
            ),
          )
        : tagInner;

    // Determine tap behavior
    VoidCallback? tapHandler;
    if (href != null) {
      tapHandler = () {
        Clipboard.setData(ClipboardData(text: href!));
        // onPressed still fires if provided (for custom handling)
        onPressed?.call();
      };
    } else if (checkable) {
      tapHandler = () {
        onChecked?.call(!_isChecked);
        onPressed?.call();
      };
    } else if (onPressed != null) {
      tapHandler = onPressed;
    }

    if (tapHandler != null) {
      final semanticsLabel = href ?? text;
      return Semantics(
        button: !checkable,
        link: href != null,
        toggled: checkable ? _isChecked : null,
        label: semanticsLabel,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: tapHandler,
            behavior: HitTestBehavior.opaque,
            child: tag,
          ),
        ),
      );
    }

    return tag;
  }
}

/// 材质特效的解析结果（内部值对象）。
///
/// 把"特效如何影响外观"的决策集中在 [_resolveEffectStyle] 一处，
/// 使 `build` 只负责按本对象渲染，不含任何风格判断逻辑。
class _TagEffectStyle {
  const _TagEffectStyle({
    this.fill,
    this.textColor,
    this.borderColor,
    this.gradient,
    this.shadows,
    this.useBackdropFilter = false,
    this.blurSigma = 0.0,
  });

  /// 半透明填充色；null 表示由渐变着色器提供颜色。
  final Color? fill;

  /// 前景（文字 / 图标）色 —— 一律来自前景令牌，保证与底色对比度达标。
  final Color? textColor;

  /// 边框色；null 表示不绘制边框。
  final Color? borderColor;

  /// 渐变令牌；非 null 时用 [ShaderMask] 渲染填充。
  final ParkGradient? gradient;

  /// 辉光投影（仅 neon 使用）。
  final List<BoxShadow>? shadows;

  /// 是否需要 [BackdropFilter]（仅 glass 使用）。
  final bool useBackdropFilter;

  /// 背景模糊 sigma（取自 [ParkBlur] 令牌，非魔法数）。
  final double blurSigma;
}
