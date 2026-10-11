import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../base/park_surface.dart';

/// 底部弹层（Sheet）表面材质的派生结果。
///
/// 三个 sheet 类组件（[ParkSheetScaffold] / ParkDropdownSheet /
/// ParkActionSheet）共用同一套取值规则：填充 / 阴影 / 文字色来自材质令牌，
/// 圆角保留组件原值。
@immutable
class ParkSheetSurface {
  /// 弹层填充色。
  final Color fill;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 是否需要背景模糊采样（仅 glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  /// 标题文字色 —— **必须**来自表面令牌。
  final Color titleColor;

  /// 次级文字色（取消 / 描述）—— **必须**来自表面令牌。
  final Color bodyColor;

  const ParkSheetSurface({
    required this.fill,
    required this.shadows,
    required this.useBlur,
    required this.blurSigma,
    required this.titleColor,
    required this.bodyColor,
  });
}

/// 解析底部弹层的表面材质（浮层规范在 Sheet 上的实现）。
///
/// 五条浮层规范：
/// 1. 阴影 `tokens.shadows ?? shadowFloor` —— 风格接管优先，浮层原值兜底；
///    [shadowFloor] 由调用方给出组件改造前的原值（无阴影则传空列表），
///    因此 stripe / flat 下逐字段一致；
/// 2. 圆角**不由本方法决定**：三个 sheet 各有自己的圆角语义（顶部大圆角 /
///    全圆角卡片），应保留组件原值而非消费 `tokens.radius`；
/// 3. 三个 sheet 原本都无边框，故 `bordered: false`，不凭空加边框；
/// 4. 文字色一律取 `tokens.titleColor` / `tokens.bodyColor`；
///    品牌色（确认按钮）是语义色，不参与材质派生；
/// 5. 全屏形态由调用方自行短路（本方法只负责"卡片化"的那层表面）。
@visibleForTesting
ParkSheetSurface resolveParkSheetSurface({
  required BuildContext context,
  List<BoxShadow> shadowFloor = const <BoxShadow>[],
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  return ParkSheetSurface(
    fill: tokens.fill,
    shadows: ParkSurfaceTokens.overlayShadows(
      tokens: tokens,
      floor: shadowFloor,
    ),
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
    titleColor: tokens.titleColor,
    bodyColor: tokens.bodyColor,
  );
}

/// A standardized bottom-sheet scaffold with a cancel / title / confirm header.
///
/// Used as the base structure for picker sheets, filter sheets, and any
/// modal that needs a consistent header with cancel and confirm actions.
///
/// ```dart
/// ParkSheetScaffold.show(
///   context: context,
///   title: '选择城市',
///   onConfirm: () { /* handle confirm */ },
///   child: MyPickerContent(),
/// );
/// ```
class ParkSheetScaffold extends StatelessWidget {
  /// Creates a ParkSheetScaffold.
  const ParkSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onCancel,
    this.onConfirm,
    this.cancelText,
    this.confirmText,
    this.confirmEnabled = true,
    this.bodyHeight,
    this.showDragHandle = true,
    this.header,
  });

  /// Title displayed centered in the header.
  final String title;

  /// Body content below the header.
  final Widget child;

  /// Called when the cancel button is tapped.
  /// If null, the sheet is simply popped.
  final VoidCallback? onCancel;

  /// Called when the confirm button is tapped.
  /// If null, the confirm button is disabled.
  final VoidCallback? onConfirm;

  /// Custom cancel button text. Defaults to [ParkLocalizations.cancelText].
  final String? cancelText;

  /// Custom confirm button text. Defaults to [ParkLocalizations.confirmText].
  final String? confirmText;

  /// Whether the confirm button is enabled.
  final bool confirmEnabled;

  /// Optional fixed height for the body area.
  /// When null, the body sizes itself naturally.
  final double? bodyHeight;

  /// Whether to show the drag handle pill above the header.
  final bool showDragHandle;

  /// Optional custom header widget. When provided, replaces the default
  /// cancel / title / confirm header entirely.
  final Widget? header;

  // ── Static show ──

  /// Shows a [ParkSheetScaffold] as a modal bottom sheet.
  ///
  /// Returns `true` if confirmed, `false` if cancelled, `null` if dismissed.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required Widget child,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    String? cancelText,
    String? confirmText,
    bool confirmEnabled = true,
    double? bodyHeight,
    bool showDragHandle = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    Widget? header,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      backgroundColor: Colors.transparent,
      // 淡遮罩：避免默认 black54 全屏变暗（蒙层体验）
      barrierColor: Colors.black.withValues(alpha: 0.10),
      builder: (ctx) => ParkSheetScaffold(
        title: title,
        onCancel: onCancel ?? () => Navigator.of(ctx).pop(false),
        onConfirm: onConfirm ?? () => Navigator.of(ctx).pop(true),
        cancelText: cancelText,
        confirmText: confirmText,
        confirmEnabled: confirmEnabled,
        bodyHeight: bodyHeight,
        showDragHandle: showDragHandle,
        header: header,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;
    final radius = park.radius;

    final effectiveCancelText = cancelText ?? l10n.cancelText;
    final effectiveConfirmText = confirmText ?? l10n.confirmText;

    // 表面材质走派生层：局部 ParkSurfaceStyleScope 覆盖自动生效。
    // 本组件改造前无阴影，故 floor 为空列表 —— stripe / flat 下逐字段一致。
    final ParkSheetSurface surface =
        resolveParkSheetSurface(context: context);
    final BorderRadius sheetRadius =
        BorderRadius.vertical(top: Radius.circular(radius.lg));

    Widget sheet = Container(
      decoration: BoxDecoration(
        color: surface.fill,
        borderRadius: sheetRadius,
        boxShadow: surface.shadows,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            if (showDragHandle)
              Padding(
                padding: EdgeInsets.only(top: spacing.sm),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Header
            header ??
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.base,
                    vertical: spacing.md,
                  ),
                  child: Row(
                    children: [
                      // Cancel
                      Semantics(
                        label: effectiveCancelText,
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            if (onCancel != null) {
                              onCancel!();
                            } else {
                              Navigator.of(context).pop(false);
                            }
                          },
                          child: Text(
                            effectiveCancelText,
                            style: TextStyle(
                              fontSize: typo.sizeBody,
                              // 次级文字色来自表面令牌（stripe 下 = textSecondary）。
                              color: surface.bodyColor,
                            ),
                          ),
                        ),
                      ),

                      // Title
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: typo.sizeH3,
                            fontWeight: typo.weightMedium,
                            // 标题色来自表面令牌（防 neon + 深色下白底白字）。
                            color: surface.titleColor,
                          ),
                        ),
                      ),

                      // Confirm
                      Semantics(
                        label: effectiveConfirmText,
                        button: true,
                        enabled: confirmEnabled,
                        child: GestureDetector(
                          onTap: confirmEnabled
                              ? () {
                                  if (onConfirm != null) {
                                    onConfirm!();
                                  } else {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              : null,
                          child: Text(
                            effectiveConfirmText,
                            style: TextStyle(
                              fontSize: typo.sizeBody,
                              fontWeight: typo.weightMedium,
                              color: confirmEnabled
                                  ? colors.brand
                                  : colors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

            // Divider
            Divider(height: 1, color: colors.divider),

            // Body
            if (bodyHeight != null)
              SizedBox(height: bodyHeight, child: child)
            else
              Flexible(child: child),
          ],
        ),
      ),
    );

    // glass 风格：叠加 BackdropFilter 采样背后的页面内容。
    //
    // 复用 ParkSurfaceBlurDepth 做嵌套降级，避免重复采样同一 backdrop。
    // 判定必须是 `< 1` 而非 `<= 1`（见 ParkSurface.canBlur 的说明）。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      sheet = ClipRRect(
        borderRadius: sheetRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: surface.blurSigma,
            sigmaY: surface.blurSigma,
          ),
          child: sheet,
        ),
      );
    }

    return sheet;
  }
}
