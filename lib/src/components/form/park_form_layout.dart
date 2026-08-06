import 'package:flutter/material.dart';

import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_button.dart';
import '../base/park_button_style.dart';
import '../base/park_divider.dart';
import '../base/park_icon.dart';
import '../display/park_card.dart';

/// 通用表单介绍区：表单顶部说明文案。
///
/// 以卡片形式展示表单标题、可选描述、图标与徽标文字。
class ParkFormIntro extends StatelessWidget {
  /// 标题文字。
  final String title;

  /// 可选描述文字。
  final String? description;

  /// 可选头部图标（默认 [Icons.description_outlined]）。
  final IconData? icon;

  /// 可选徽标文字（如「第1步 / 3」）。
  final String? badgeText;

  const ParkFormIntro({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final Color accent = colors.brand;
    return Container(
      padding: EdgeInsets.all(park.spacing.base),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(park.radius.xl),
        border: Border.all(color: colors.border),
        boxShadow: park.shadows.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParkIcon(
            icon ?? Icons.description_outlined,
            pixelSize: 24,
            color: accent,
            container: ParkIconContainer.rounded,
            containerColor: accent.withValues(alpha: 0.12),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (badgeText != null && badgeText!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(park.radius.full),
                        ),
                        child: Text(
                          badgeText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (description != null) const SizedBox(height: 8),
                if (description != null)
                  Text(
                    description ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 通用表单页体：表单页面滚动容器。
///
/// 将多个表单区块垂直排列，区块之间按 [sectionSpacing] 分隔，
/// 底部可选 [footer]（如提交按钮）。
class ParkFormPageBody extends StatelessWidget {
  /// 表单区块列表。
  final List<Widget> sections;

  /// 滚动区 padding（默认使用主题间距令牌）。
  final EdgeInsetsGeometry? padding;

  /// 底部区域（如提交按钮）。
  final Widget? footer;

  /// 区块间距（默认 16）。
  final double? sectionSpacing;

  const ParkFormPageBody({
    super.key,
    required this.sections,
    this.padding,
    this.footer,
    this.sectionSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final double spacing = sectionSpacing ?? 16;
    final List<Widget> sectionChildren = [];
    for (int index = 0; index < sections.length; index++) {
      sectionChildren.add(sections[index]);
      if (index != sections.length - 1) {
        sectionChildren.add(SizedBox(height: spacing));
      }
    }

    return ListView(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      padding:
          padding ??
          EdgeInsets.fromLTRB(
            park.spacing.base,
            park.spacing.md,
            park.spacing.base,
            park.spacing.lg,
          ),
      children: [
        ...sectionChildren,
        if (footer != null) ...[const SizedBox(height: 8), footer!],
      ],
    );
  }
}

/// 通用表单区块（卡片式）：表单分区卡片容器。
///
/// 与输入组件中的轻量分组容器 [ParkFormSection] 不同，本组件以
/// [ParkCard] 预览变体承载标题/描述/扩展区，并在子项之间自动插入分割线，
/// 适合承载表单行（如 [ParkFormRow]）等结构化内容。
class ParkFormSectionCard extends StatelessWidget {
  /// 分区标题。
  final String? title;

  /// 分区描述（显示在卡片头部下方、子项之前）。
  final String? description;

  /// 右上角扩展区。
  final Widget? extensionWidget;

  /// 可选头部图标。
  final IconData? icon;

  /// 子内容列表（之间自动插入 [ParkDivider]）。
  final List<Widget> children;

  const ParkFormSectionCard({
    super.key,
    this.title,
    this.description,
    this.extensionWidget,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final List<Widget> widgetList = [];

    if (description != null && description!.isNotEmpty) {
      widgetList.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: park.colors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    for (int index = 0; index < children.length; index++) {
      widgetList.add(children[index]);
      if (index != children.length - 1) {
        widgetList.add(const ParkDivider());
      }
    }

    return ParkCard(
      variant: ParkCardVariant.preview,
      titleText: title,
      extra: extensionWidget,
      icon: Icon(icon),
      showIndicator: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgetList,
      ),
    );
  }
}

/// 通用表单提交按钮：底部提交按钮。
///
/// 全宽品牌色胶囊按钮，高度 48。
class ParkFormSubmitButton extends StatelessWidget {
  /// 按钮文字（如「提交」「实名认证」）。
  final String text;

  /// 点击回调。
  final VoidCallback? onPressed;

  const ParkFormSubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ParkButton(
      variant: ParkButtonVariant.primary,
      block: true,
      height: 48,
      shape: ParkButtonShape.round,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

/// 通用表单分步操作：上一步/下一步按钮组。
///
/// 左侧「上一步」为幽灵按钮（[canGoBack] 为 false 时禁用），
/// 右侧「下一步」为主按钮，文字由 [nextText] 指定。
class ParkFormStepActions extends StatelessWidget {
  /// 是否可返回上一步。
  final bool canGoBack;

  /// 下一步按钮文字。
  final String nextText;

  /// 上一步回调。
  final VoidCallback? onBack;

  /// 下一步回调。
  final VoidCallback? onNext;

  const ParkFormStepActions({
    super.key,
    required this.canGoBack,
    required this.nextText,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ParkButton(
              variant: ParkButtonVariant.ghost,
              block: true,
              height: 56,
              shape: ParkButtonShape.round,
              onPressed: canGoBack ? onBack : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.previousStep),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ParkButton(
              variant: ParkButtonVariant.primary,
              block: true,
              height: 56,
              shape: ParkButtonShape.round,
              onPressed: onNext,
              child: Text(nextText),
            ),
          ),
        ],
      ),
    );
  }
}

/// 通用弹层头：弹窗标题与关闭按钮。
///
/// 左侧取消按钮、中间标题、右侧确认按钮。
class ParkFormModalHeader extends StatelessWidget {
  /// 弹层标题。
  final String title;

  /// 取消回调。
  final VoidCallback? onCancel;

  /// 确认回调。
  final VoidCallback? onConfirm;

  /// 取消按钮文字（默认取 [ParkLocalizations.cancelText]，中文为「取消」）。
  final String? cancelText;

  /// 确认按钮文字（默认取 [ParkLocalizations.confirmText]，中文为「确定」）。
  final String? confirmText;

  /// 确认按钮是否可用（为 false 时禁用并显示禁用色）。
  final bool confirmEnabled;

  const ParkFormModalHeader({
    super.key,
    required this.title,
    required this.onCancel,
    required this.onConfirm,
    this.cancelText,
    this.confirmText,
    this.confirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final Color primary = park.colors.brand;
    final Color secondary = park.colors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Row(
        children: [
          ParkButton(
            variant: ParkButtonVariant.text,
            onPressed: onCancel,
            child: Text(
              cancelText ?? l10n.cancelText,
              style: TextStyle(fontSize: 12, color: secondary),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: park.colors.textPrimary,
              ),
            ),
          ),
          ParkButton(
            variant: ParkButtonVariant.text,
            onPressed: confirmEnabled ? onConfirm : null,
            child: Text(
              confirmText ?? l10n.confirmText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: confirmEnabled ? primary : theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 通用弹层脚手架：弹层整体布局。
///
/// 组合 [ParkFormModalHeader] 与内容区，内容区可通过 [bodyHeight] 固定高度。
class ParkFormModalScaffold extends StatelessWidget {
  /// 弹层标题。
  final String title;

  /// 取消回调。
  final VoidCallback? onCancel;

  /// 确认回调。
  final VoidCallback? onConfirm;

  /// 弹层内容。
  final Widget child;

  /// 内容区高度（null 时由内容自适应）。
  final double? bodyHeight;

  /// 确认按钮是否可用。
  final bool confirmEnabled;

  const ParkFormModalScaffold({
    super.key,
    required this.title,
    required this.onCancel,
    required this.onConfirm,
    required this.child,
    this.bodyHeight,
    this.confirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParkFormModalHeader(
              title: title,
              onCancel: onCancel,
              onConfirm: onConfirm,
              confirmEnabled: confirmEnabled,
            ),
            if (bodyHeight != null)
              SizedBox(height: bodyHeight, child: child)
            else
              child,
          ],
        ),
      ),
    );
  }
}
