import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import 'park_form.dart';

/// 表单校验规则
class ParkFormRule {
  /// 是否必填
  final bool required;

  /// 校验失败提示信息
  final String message;

  /// 正则表达式校验
  final RegExp? pattern;

  /// 自定义校验函数
  final String? Function(String?)? validator;

  const ParkFormRule({
    this.required = false,
    this.message = '校验失败',
    this.pattern,
    this.validator,
  });

  /// 对给定值执行校验，返回错误信息；通过则返回 null
  String? validate(String? value) {
    // 必填校验
    if (required && (value == null || value.trim().isEmpty)) {
      return message;
    }
    // 正则校验
    if (pattern != null && value != null && value.isNotEmpty) {
      if (!pattern!.hasMatch(value)) {
        return message;
      }
    }
    // 自定义校验
    if (validator != null) {
      final result = validator!(value);
      if (result != null) return result;
    }
    return null;
  }
}

/// Park 表单项容器。
///
/// 统一承载：
///
/// - label 标题
/// - required 必填标记
/// - extra 额外说明区域
/// - helpText 帮助文本
/// - errorText 错误文本
/// - child 内容区
///
/// 该组件不负责具体输入逻辑，只负责表单项外壳布局，
/// 适合作为动态表单运行时和静态表单页面的统一容器层。
class ParkFormItem extends StatefulWidget {
  /// 标题文本。
  final String? label;

  /// 自定义标题 Widget。
  final Widget? labelWidget;

  /// 是否必填。
  final bool required;

  /// 右侧扩展内容，例如"可选""说明""操作按钮"。
  final Widget? extra;

  /// 帮助文本，显示在内容区下方、错误提示上方。
  final String? helpText;

  /// 错误提示。
  final String? errorText;

  /// 是否显示错误态。
  final bool showError;

  /// 内容区 Widget。
  final Widget child;

  /// 外层边距。
  final EdgeInsetsGeometry? margin;

  /// 内层内容区上边距。
  final double? contentTopSpacing;

  /// 是否显示必填星号。
  final bool showRequiredMark;

  /// 字段名称，用于表单值收集。设置后会注册到父级 [ParkForm]。
  final String? name;

  /// 标签旁的提示文本，显示 (?) 图标，hover 时展示提示内容。
  final String? tooltip;

  /// 覆盖表单级 labelWidth 的单项标签宽度（horizontal 布局时生效）。
  final double? labelCol;

  /// 内联校验规则列表。
  final List<ParkFormRule>? rules;

  /// 覆盖表单级 colon 设置。null 时使用表单级设置。
  final bool? colon;

  /// 创建表单项容器。
  const ParkFormItem({
    super.key,
    this.label,
    this.labelWidget,
    this.required = false,
    this.extra,
    this.helpText,
    this.errorText,
    this.showError = true,
    required this.child,
    this.margin,
    this.contentTopSpacing,
    this.showRequiredMark = true,
    this.name,
    this.tooltip,
    this.labelCol,
    this.rules,
    this.colon,
  });

  @override
  State<ParkFormItem> createState() => ParkFormItemState();
}

class ParkFormItemState extends State<ParkFormItem> {
  final GlobalKey _fieldKey = GlobalKey();
  ParkFormScope? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newScope = ParkFormScope.of(context);
    if (widget.name != null && newScope != null) {
      newScope.registerFieldKey?.call(widget.name!, _fieldKey);
    }
    _scope = newScope;
  }

  @override
  void dispose() {
    if (widget.name != null) {
      _scope?.unregisterFieldKey?.call(widget.name!);
    }
    super.dispose();
  }

  /// 根据 rules 执行校验，返回第一个错误信息或 null
  String? validateByRules(String? value) {
    if (widget.rules == null || widget.rules!.isEmpty) return null;
    for (final rule in widget.rules!) {
      final error = rule.validate(value);
      if (error != null) return error;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    // 从 ParkFormScope 获取表单级配置
    final scope = ParkFormScope.of(context);
    final formLayout = scope?.layout ?? ParkFormLayout.vertical;
    final formLabelWidth = widget.labelCol ?? scope?.labelWidth ?? 100;
    final showColon = widget.colon ?? scope?.colon ?? true;
    final formRequiredMark = scope?.requiredMark ?? ParkRequiredMark.asterisk;

    final bool hasLabel =
        widget.labelWidget != null ||
        (widget.label != null && widget.label!.trim().isNotEmpty);
    final bool hasHelp =
        widget.helpText != null && widget.helpText!.trim().isNotEmpty;
    final bool hasError =
        widget.showError &&
        widget.errorText != null &&
        widget.errorText!.trim().isNotEmpty;

    // 判断是否显示必填标记
    final bool showAsterisk =
        widget.required &&
        widget.showRequiredMark &&
        formRequiredMark == ParkRequiredMark.asterisk;

    // 构建标签文本（含冒号）
    Widget? labelContent;
    if (widget.labelWidget != null) {
      labelContent = widget.labelWidget;
    } else if (widget.label != null && widget.label!.trim().isNotEmpty) {
      final labelText = showColon ? '${widget.label}：' : widget.label!;
      labelContent = Text(
        labelText,
        style: TextStyle(
          fontSize: typo.sizeBodySmall,
          color: colors.textSecondary,
          fontWeight: typo.weightMedium,
        ),
      );
    }

    // 构建 tooltip 图标
    Widget? tooltipIcon;
    if (widget.tooltip != null && widget.tooltip!.trim().isNotEmpty) {
      tooltipIcon = Padding(
        padding: EdgeInsets.only(left: spacing.xs / 2),
        child: Tooltip(
          message: widget.tooltip,
          child: Icon(
            Icons.help_outline,
            size: typo.sizeBodySmall * 1.1,
            color: colors.textPlaceholder,
          ),
        ),
      );
    }

    // horizontal 布局：标签和内容水平排列
    if (formLayout == ParkFormLayout.horizontal && hasLabel) {
      return Container(
        margin: widget.margin,
        key: _fieldKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: formLabelWidth,
                    child: Padding(
                      padding: EdgeInsets.only(top: spacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (showAsterisk)
                            Padding(
                              padding: EdgeInsets.only(right: spacing.xs / 2),
                              child: Text(
                                '*',
                                style: TextStyle(
                                  color: colors.error,
                                  fontSize: typo.sizeBody,
                                  fontWeight: typo.weightMedium,
                                  height: 1,
                                ),
                              ),
                            ),
                          Flexible(child: labelContent ?? const SizedBox.shrink()),
                          ?tooltipIcon,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(child: widget.child),
                ],
              ),
            ),
            if (widget.extra != null) ...<Widget>[
              SizedBox(height: spacing.xs),
              widget.extra!,
            ],
            if (hasHelp) ...<Widget>[
              SizedBox(height: spacing.xs),
              Text(
                widget.helpText!,
                style: TextStyle(
                  fontSize: typo.sizeCaption,
                  color: colors.textPlaceholder,
                ),
              ),
            ],
            if (hasError) ...<Widget>[
              SizedBox(height: spacing.xs),
              Text(
                widget.errorText!,
                style: TextStyle(
                  fontSize: typo.sizeCaption,
                  color: colors.error,
                  fontWeight: typo.weightMedium,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // vertical / inline 布局：标签在上，内容在下
    return Container(
      margin: widget.margin,
      key: _fieldKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasLabel)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (showAsterisk)
                        Padding(
                          padding: EdgeInsets.only(right: spacing.xs / 2),
                          child: Text(
                            '*',
                            style: TextStyle(
                              color: colors.error,
                              fontSize: typo.sizeBody,
                              fontWeight: typo.weightMedium,
                              height: 1,
                            ),
                          ),
                        ),
                      Flexible(child: labelContent ?? const SizedBox.shrink()),
                      ?tooltipIcon,
                    ],
                  ),
                ),
                if (widget.extra != null) ...<Widget>[
                  SizedBox(width: spacing.sm),
                  widget.extra!,
                ],
              ],
            ),
          if (hasLabel) SizedBox(height: widget.contentTopSpacing ?? spacing.xs),
          widget.child,
          if (hasHelp) ...<Widget>[
            SizedBox(height: spacing.xs),
            Text(
              widget.helpText!,
              style: TextStyle(
                fontSize: typo.sizeCaption,
                color: colors.textPlaceholder,
              ),
            ),
          ],
          if (hasError) ...<Widget>[
            SizedBox(height: spacing.xs),
            Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: typo.sizeCaption,
                color: colors.error,
                fontWeight: typo.weightMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
