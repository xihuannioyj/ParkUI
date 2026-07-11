import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import 'park_form.dart';

/// 表单校验规则的严重级别。
enum ParkRuleSeverity {
  /// 错误（阻断提交，红色提示）
  error,

  /// 警告（不阻断提交，黄色提示）
  warning,
}

/// 预定义的校验类型。
enum ParkRuleType {
  /// 字符串（默认）
  string,

  /// 数字（整型或浮点）
  number,

  /// 整数
  integer,

  /// 邮箱
  email,

  /// URL
  url,

  /// 手机号（中国大陆）
  phone,
}

/// 表单校验规则
///
/// 扩展自 Ant Design NG 的规则体系，支持：
/// - 必填 / 正则 / 自定义校验
/// - 类型校验（email/url/number/phone）
/// - 数值范围（min/max）
/// - 精确长度（len）
/// - 异步校验
/// - 警告级别（非阻断）
/// - 字段依赖（跨字段联动校验）
///
/// ```dart
/// ParkFormRule(
///   required: true,
///   type: ParkRuleType.email,
///   message: '请输入有效的邮箱地址',
/// )
///
/// ParkFormRule(
///   type: ParkRuleType.number,
///   min: 0,
///   max: 100,
///   message: '请输入 0-100 之间的数字',
/// )
///
/// ParkFormRule(
///   asyncValidator: (value) async {
///     final exists = await checkUsername(value!);
///     return exists ? '用户名已存在' : null;
///   },
/// )
/// ```
class ParkFormRule {
  /// 是否必填
  final bool required;

  /// 校验失败提示信息
  final String message;

  /// 正则表达式校验
  final RegExp? pattern;

  /// 预定义校验类型
  final ParkRuleType type;

  /// 最小值（数值）或最小长度（字符串）
  final num? min;

  /// 最大值（数值）或最大长度（字符串）
  final num? max;

  /// 精确长度（字符串）或精确值（数值）
  final num? len;

  /// 自定义校验函数
  final String? Function(String?)? validator;

  /// 异步校验函数
  final Future<String?> Function(String?)? asyncValidator;

  /// 校验严重级别（error=阻断提交, warning=不阻断）
  final ParkRuleSeverity severity;

  /// 依赖字段（跨字段校验时监听其他字段变化）
  final List<String>? dependsOn;

  /// 创建 [ParkFormRule]。
  const ParkFormRule({
    this.required = false,
    this.message = '校验失败',
    this.pattern,
    this.type = ParkRuleType.string,
    this.min,
    this.max,
    this.len,
    this.validator,
    this.asyncValidator,
    this.severity = ParkRuleSeverity.error,
    this.dependsOn,
  });

  /// 对给定值执行同步校验。
  ///
  /// 返回 `(errorMessage, severity)` — 通过时 errorMessage 为 null。
  (String?, ParkRuleSeverity) validate(String? value) {
    // 必填校验
    if (required && (value == null || value.trim().isEmpty)) {
      return (message, severity);
    }
    if (value == null || value.isEmpty) return (null, severity);

    // 类型校验
    final typeResult = _validateType(value);
    if (typeResult != null) return (typeResult, severity);

    // 范围校验
    final rangeResult = _validateRange(value);
    if (rangeResult != null) return (rangeResult, severity);

    // 精确长度校验
    if (len != null && value.length != len) {
      return ('长度必须为 $len 个字符', severity);
    }

    // 正则校验
    if (pattern != null && !pattern!.hasMatch(value)) {
      return (message, severity);
    }

    // 自定义校验
    if (validator != null) {
      final result = validator!(value);
      if (result != null) return (result, severity);
    }

    return (null, severity);
  }

  /// 类型校验。
  String? _validateType(String value) {
    switch (type) {
      case ParkRuleType.string:
        return null;
      case ParkRuleType.number:
        return double.tryParse(value) != null ? null : '请输入有效的数字';
      case ParkRuleType.integer:
        return int.tryParse(value) != null ? null : '请输入有效的整数';
      case ParkRuleType.email:
        return _emailRegExp.hasMatch(value) ? null : '请输入有效的邮箱地址';
      case ParkRuleType.url:
        return _urlRegExp.hasMatch(value) ? null : '请输入有效的 URL';
      case ParkRuleType.phone:
        return _phoneRegExp.hasMatch(value) ? null : '请输入有效的手机号';
    }
  }

  /// 范围校验（数值或长度）。
  String? _validateRange(String value) {
    if (type == ParkRuleType.number || type == ParkRuleType.integer) {
      final num? numVal = type == ParkRuleType.integer
          ? int.tryParse(value)
          : double.tryParse(value);
      if (numVal == null) return null;
      if (min != null && numVal < min!) return '不能小于 $min';
      if (max != null && numVal > max!) return '不能大于 $max';
    } else {
      if (min != null && value.length < min!) return '长度不能小于 $min';
      if (max != null && value.length > max!) return '长度不能大于 $max';
    }
    return null;
  }

  /// 执行异步校验（若配置了 asyncValidator）。
  Future<String?> validateAsync(String? value) async {
    if (asyncValidator == null) return null;
    if (value == null || value.isEmpty) return null;
    return asyncValidator!(value);
  }

  /// 此规则是否为警告级别。
  bool get isWarning => severity == ParkRuleSeverity.warning;

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _urlRegExp = RegExp(
    r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
  );
  static final RegExp _phoneRegExp = RegExp(
    r'^1[3-9]\d{9}$',
  );
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

  /// 表单项布局方式。null 时继承 [ParkForm] 或 [ParkFormScope] 的设置。
  final ParkFormLayout? layout;

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
    this.layout,
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
      final (msg, _) = rule.validate(value);
      if (msg != null) return msg;
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

    // 从 ParkFormScope 获取表单级配置，单项 layout 优先
    final scope = ParkFormScope.of(context);
    final formLayout = widget.layout ?? scope?.layout ?? ParkFormLayout.vertical;
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
