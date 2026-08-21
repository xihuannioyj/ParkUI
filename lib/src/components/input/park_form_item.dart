import 'dart:async';
import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';
import '../../form/group/form_group_exports.dart';
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

  /// 校验失败提示信息。为 null 时使用本地化默认值。
  final String? message;

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

  /// 数字类型校验失败提示。为 null 时使用本地化默认值。
  final String? numberMessage;

  /// 整数类型校验失败提示。为 null 时使用本地化默认值。
  final String? integerMessage;

  /// 邮箱类型校验失败提示。为 null 时使用本地化默认值。
  final String? emailMessage;

  /// URL 类型校验失败提示。为 null 时使用本地化默认值。
  final String? urlMessage;

  /// 手机号类型校验失败提示。为 null 时使用本地化默认值。
  final String? phoneMessage;

  /// 精确长度校验失败提示模板。为 null 时使用本地化默认值。
  final String? lengthMessage;

  /// 最小值校验失败提示模板。为 null 时使用本地化默认值。
  final String? minMessage;

  /// 最大值校验失败提示模板。为 null 时使用本地化默认值。
  final String? maxMessage;

  /// 最小长度校验失败提示模板。为 null 时使用本地化默认值。
  final String? minLengthMessage;

  /// 最大长度校验失败提示模板。为 null 时使用本地化默认值。
  final String? maxLengthMessage;

  /// 创建 [ParkFormRule]。
  const ParkFormRule({
    this.required = false,
    this.message,
    this.pattern,
    this.type = ParkRuleType.string,
    this.min,
    this.max,
    this.len,
    this.validator,
    this.asyncValidator,
    this.severity = ParkRuleSeverity.error,
    this.dependsOn,
    this.numberMessage,
    this.integerMessage,
    this.emailMessage,
    this.urlMessage,
    this.phoneMessage,
    this.lengthMessage,
    this.minMessage,
    this.maxMessage,
    this.minLengthMessage,
    this.maxLengthMessage,
  });

  /// 对给定值执行同步校验。
  ///
  /// 返回 `(errorMessage, severity)` — 通过时 errorMessage 为 null。
  /// [l10n] 可选，用于解析默认校验消息的本地化实例。
  (String?, ParkRuleSeverity) validate(
    String? value, [
    ParkLocalizations? l10n,
  ]) {
    // 必填校验
    final effectiveMessage = message ?? l10n?.validationFailed ?? '校验失败';
    if (required && (value == null || value.trim().isEmpty)) {
      return (effectiveMessage, severity);
    }
    if (value == null || value.isEmpty) return (null, severity);

    // 类型校验
    final typeResult = _validateType(value, l10n);
    if (typeResult != null) return (typeResult, severity);

    // 范围校验
    final rangeResult = _validateRange(value, l10n);
    if (rangeResult != null) return (rangeResult, severity);

    // 精确长度校验
    if (len != null && value.length != len) {
      return (
        lengthMessage ?? l10n?.lengthMustBe(len!.toInt()) ?? '长度必须为 $len 个字符',
        severity,
      );
    }

    // 正则校验
    if (pattern != null && !pattern!.hasMatch(value)) {
      return (effectiveMessage, severity);
    }

    // 自定义校验
    if (validator != null) {
      final result = validator!(value);
      if (result != null) return (result, severity);
    }

    return (null, severity);
  }

  /// 类型校验。
  String? _validateType(String value, [ParkLocalizations? l10n]) {
    switch (type) {
      case ParkRuleType.string:
        return null;
      case ParkRuleType.number:
        return double.tryParse(value) != null
            ? null
            : (numberMessage ?? l10n?.invalidNumber ?? '请输入有效的数字');
      case ParkRuleType.integer:
        return int.tryParse(value) != null
            ? null
            : (integerMessage ?? l10n?.invalidInteger ?? '请输入有效的整数');
      case ParkRuleType.email:
        return _emailRegExp.hasMatch(value)
            ? null
            : (emailMessage ?? l10n?.invalidEmail ?? '请输入有效的邮箱地址');
      case ParkRuleType.url:
        return _urlRegExp.hasMatch(value)
            ? null
            : (urlMessage ?? l10n?.invalidUrl ?? '请输入有效的 URL');
      case ParkRuleType.phone:
        return _phoneRegExp.hasMatch(value)
            ? null
            : (phoneMessage ?? l10n?.invalidPhone ?? '请输入有效的手机号');
    }
  }

  /// 范围校验（数值或长度）。
  String? _validateRange(String value, [ParkLocalizations? l10n]) {
    if (type == ParkRuleType.number || type == ParkRuleType.integer) {
      final num? numVal = type == ParkRuleType.integer
          ? int.tryParse(value)
          : double.tryParse(value);
      if (numVal == null) return null;
      if (min != null && numVal < min!)
        return minMessage ?? l10n?.cannotBeLessThan(min!) ?? '不能小于 $min';
      if (max != null && numVal > max!)
        return maxMessage ?? l10n?.cannotBeGreaterThan(max!) ?? '不能大于 $max';
    } else {
      if (min != null && value.length < min!)
        return minLengthMessage ??
            l10n?.lengthCannotBeLessThan(min!) ??
            '长度不能小于 $min';
      if (max != null && value.length > max!)
        return maxLengthMessage ??
            l10n?.lengthCannotBeGreaterThan(max!) ??
            '长度不能大于 $max';
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
    r'^https?:\/\/[\w\-]+(?:\.[\w\-])+[/#?]?.*$',
  );
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
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

  /// 控件列占格数（24 栅格），覆盖表单级 [ParkForm.wrapperCol]。
  /// / Wrapper column span (24-grid), overrides form-level [ParkForm.wrapperCol].
  ///
  /// 需与表单级 [ParkForm.labelCol] 或本项 [labelCol] 配合使用。
  /// Requires form-level [ParkForm.labelCol] or item-level [labelCol] to be set.
  final int? wrapperCol;

  /// 内联校验规则列表。
  final List<ParkFormRule>? rules;

  /// 覆盖表单级 colon 设置。null 时使用表单级设置。
  final bool? colon;

  /// 表单项布局方式。null 时继承 [ParkForm] 或 [ParkFormScope] 的设置。
  final ParkFormLayout? layout;

  /// 自定义校验函数（对齐 Flutter [FormField.validator] 签名）。
  ///
  /// 与 [rules] 同时生效：先执行 [validator]，再执行 [rules]。
  /// 供 [ParkForm.validate] 在提交前统一校验（B30 / 开发文档.md §7.8）。
  final String? Function(dynamic value)? validator;

  /// 绑定键（点号分隔的路径，如 `'user.name'`）。
  ///
  /// 设置后该表单项的值可双向绑定到 [ParkBindingService]（需置于已注入
  /// 绑定服务的 [ParkForm] 内）。不设时组件行为不变。
  final String? bindKey;

  /// 响应式表单控件（可选）。
  ///
  /// 传入 [ParkAbstractControl] 后，表单项自动监听控件的校验状态变化，
  /// 在控件被触碰过（touched）且校验失败时显示错误信息。
  /// 错误文本取自 [ParkAbstractControl.errors] 中第一条 [ParkFormError.message]。
  final ParkAbstractControl? control;

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
    this.wrapperCol,
    this.rules,
    this.colon,
    this.layout,
    this.validator,
    this.bindKey,
    this.control,
  });

  @override
  State<ParkFormItem> createState() => ParkFormItemState();
}

class ParkFormItemState extends State<ParkFormItem> {
  final GlobalKey _fieldKey = GlobalKey();
  ParkFormScope? _scope;

  /// 响应式控件的流订阅。
  StreamSubscription<dynamic>? _valueSub;
  StreamSubscription<String>? _statusSub;

  /// 来自响应式控件的当前错误文本。
  String? _reactiveError;

  /// 已同步到 FormField 的值（防抖/防循环）。
  String? _lastSyncedValue;

  @override
  void initState() {
    super.initState();
    _subscribeControl();
  }

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
  void didUpdateWidget(covariant ParkFormItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control != widget.control) {
      _unsubscribeControl();
      _reactiveError = null;
      _subscribeControl();
    }
  }

  @override
  void dispose() {
    if (widget.name != null) {
      _scope?.unregisterFieldKey?.call(widget.name!);
    }
    _unsubscribeControl();
    super.dispose();
  }

  /// 订阅响应式控件的值变化和状态变化流。
  void _subscribeControl() {
    final ParkAbstractControl? ctrl = widget.control;
    if (ctrl == null) return;
    _valueSub = ctrl.valueChanges.listen((dynamic _) {
      if (!mounted) return;
      _updateReactiveError();
    }, onError: (dynamic e) => debugPrint('Stream error: $e'));
    _statusSub = ctrl.statusChanges.listen((String _) {
      if (!mounted) return;
      _updateReactiveError();
    }, onError: (dynamic e) => debugPrint('Stream error: $e'));
  }

  /// 取消订阅响应式控件流。
  void _unsubscribeControl() {
    _valueSub?.cancel();
    _valueSub = null;
    _statusSub?.cancel();
    _statusSub = null;
  }

  /// 根据控件当前状态更新响应式错误文本。
  ///
  /// 仅在控件已触碰（touched）且校验失败时显示错误。
  void _updateReactiveError() {
    final ParkAbstractControl? ctrl = widget.control;
    if (ctrl == null) {
      if (_reactiveError != null) {
        setState(() => _reactiveError = null);
      }
      return;
    }
    String? newError;
    if (ctrl.touched && ctrl.invalid && ctrl.errors.isNotEmpty) {
      newError = ctrl.errors.first.message;
    }
    if (newError != _reactiveError) {
      setState(() => _reactiveError = newError);
    }
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

  /// 把子组件的真实值同步进 FormField，使 Form.validate() 能拿到实际值校验。
  ///
  /// 修复 B30 桥接缺陷：FormField 的 initialValue 恒为 null 且从未 didChange，
  /// 导致 `rules: [required]` 永远校验失败、类型规则（email/url 等）永不生效。
  /// 值来源优先级：1) 响应式 control；2) 子组件自身的 FormField<String>（如 ParkInput）。
  void _syncValue(FormFieldState<String> parent) {
    final ParkAbstractControl? ctrl = widget.control;
    if (ctrl != null) {
      _syncValueTo(parent, ctrl.value == null ? null : ctrl.value.toString());
      return;
    }
    final FormFieldState<String>? state =
        _findDescendantFormFieldState(parent.context);
    if (state == null) return;
    _syncValueTo(parent, state.value);
  }

  /// 帧末执行值同步：visitChildElements 不能在 build 期间调用。
  void _scheduleValueSync(FormFieldState<String> parent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncValue(parent);
    });
  }

  /// 校验时解析子组件真实值（FormField 内部值可能过期/为 null）。
  String? _resolveActualValue(BuildContext context) {
    final ParkAbstractControl? ctrl = widget.control;
    if (ctrl != null) return ctrl.value?.toString();
    final FormFieldState<String>? state = _findDescendantFormFieldState(context);
    return state?.value;
  }

  /// 在子元素树中查找最近的 FormField<String> 状态（DFS）。
  FormFieldState<String>? _findDescendantFormFieldState(BuildContext context) {
    FormFieldState<String>? result;
    void visit(Element element) {
      if (result != null) return;
      if (element is StatefulElement) {
        final State state = element.state;
        if (state is FormFieldState<String>) {
          result = state;
          return;
        }
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return result;
  }

  void _syncValueTo(FormFieldState<String> parent, String? value) {
    if (value == _lastSyncedValue) return;
    _lastSyncedValue = value;
    // 延迟到帧末再 didChange，避免在 build 期间触发 markNeedsBuild。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = _fieldKey.currentState as FormFieldState<String>?;
      p?.didChange(value); if (widget.name != null) _scope?.notifyFieldChanged?.call(widget.name!, value);
    });
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
    final formLayout =
        widget.layout ?? scope?.layout ?? ParkFormLayout.vertical;
    final formLabelWidth = widget.labelCol ?? scope?.labelWidth ?? 100;
    final showColon = widget.colon ?? scope?.colon ?? true;
    final formRequiredMark = scope?.requiredMark ?? ParkRequiredMark.asterisk;
    // ParkForm.size 生效：标签字号随表单档位缩放（原 size 参数声明后从未消费）
    final double labelFontSize = switch (scope?.size) {
      ParkFormSize.small => typo.sizeCaption,
      ParkFormSize.medium => typo.sizeBodySmall,
      ParkFormSize.large => typo.sizeBody,
      null => typo.sizeBodySmall,
    };
    final double labelTopPadding = switch (scope?.size) {
      ParkFormSize.small => spacing.xs,
      ParkFormSize.medium => spacing.sm,
      ParkFormSize.large => spacing.sm,
      null => spacing.sm,
    };

    final bool hasLabel =
        widget.labelWidget != null ||
        (widget.label != null && widget.label!.trim().isNotEmpty);
    final bool hasHelp =
        widget.helpText != null && widget.helpText!.trim().isNotEmpty;
    final String? helpText = hasHelp ? widget.helpText : null;

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
          fontSize: labelFontSize,
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

    // 是否有外部错误文本（由父组件控制，优先级最高）
    final bool hasExternalError =
        widget.showError &&
        widget.errorText != null &&
        widget.errorText!.trim().isNotEmpty;

    // ── B30 架构桥接：包装 FormField，使 Form.validate() 触发 validator/rules ──
    return FormField<String>(
      key: _fieldKey,
      initialValue: null,
      onSaved: (value) {
                  final String? name = widget.name; if (name != null && _scope != null) { _scope!.notifyFieldChanged?.call(name, value); }
      },
      validator: (value) {
        // 以子组件真实值为准（FormField 内部值可能为 null/过期）
        final String? actualValue = _resolveActualValue(context);
        // 先执行 widget.validator（自定义校验）
        if (widget.validator != null) {
          final result = widget.validator!(actualValue);
          if (result != null) return result;
        }
        // 再执行 rules（规则列表）
        final rulesResult = validateByRules(actualValue);
        if (rulesResult != null) return rulesResult;
        // Note: async validation via control.validate() is handled at
        // form submission time by formGroup.validate() in _handleSubmit.
        // Do NOT call it here — FormField.validator is synchronous and
        // the async result would be discarded.
        return null;
      },
      builder: (FormFieldState<String> fieldState) {
        // 值同步：让 FormField 拿到子组件的真实值，校验才不失效。
        _scheduleValueSync(fieldState);
        // 外部 errorText（如 API 返回的错误）优先级最高
        // 其次响应式控件错误（_reactiveError），再次 FormField 校验错误
        final String? displayError = hasExternalError
            ? widget.errorText
            : (_reactiveError ?? fieldState.errorText);
        final bool hasFormError =
            displayError != null && displayError.trim().isNotEmpty;

        // horizontal 布局：标签和内容水平排列
        if (formLayout == ParkFormLayout.horizontal && hasLabel) {
          // 栅格布局：当 labelCol 和 wrapperCol 都设置时使用 / Grid layout: when both labelCol and wrapperCol are set
          final int? formLabelCol = scope?.labelCol;
          final int? formWrapperCol = scope?.wrapperCol;
          final int? itemWrapperCol = widget.wrapperCol;
          final bool useGrid =
              formLabelCol != null &&
              (formWrapperCol != null || itemWrapperCol != null);
          final int effectiveLabelFlex = formLabelCol ?? 8;
          final int effectiveWrapperFlex =
              itemWrapperCol ?? formWrapperCol ?? (24 - effectiveLabelFlex);

          return Container(
            margin: widget.margin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (useGrid)
                        Expanded(
                          flex: effectiveLabelFlex,
                          child: Padding(
                            padding: EdgeInsets.only(top: labelTopPadding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (showAsterisk)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: spacing.xs / 2,
                                    ),
                                    child: Semantics(
                                      label: 'required',
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
                                  ),
                                Flexible(
                                  child:
                                      labelContent ?? const SizedBox.shrink(),
                                ),
                                if (tooltipIcon != null) tooltipIcon,
                              ],
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: formLabelWidth,
                          child: Padding(
                            padding: EdgeInsets.only(top: labelTopPadding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (showAsterisk)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: spacing.xs / 2,
                                    ),
                                    child: Semantics(
                                      label: 'required',
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
                                  ),
                                Flexible(
                                  child:
                                      labelContent ?? const SizedBox.shrink(),
                                ),
                                if (tooltipIcon != null) tooltipIcon,
                              ],
                            ),
                          ),
                        ),
                      SizedBox(width: spacing.md),
                      if (useGrid)
                        Expanded(
                          flex: effectiveWrapperFlex,
                          child: widget.child,
                        )
                      else
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
                    helpText!,
                    style: TextStyle(
                      fontSize: typo.sizeCaption,
                      color: colors.textPlaceholder,
                    ),
                  ),
                ],
                if (hasFormError) ...<Widget>[
                  SizedBox(height: spacing.xs),
                  Text(
                    displayError,
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
                              child: Semantics(
                                label: 'required',
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
                            ),
                          Flexible(
                            child: labelContent ?? const SizedBox.shrink(),
                          ),
                          if (tooltipIcon != null) tooltipIcon,
                        ],
                      ),
                    ),
                    if (widget.extra != null) ...<Widget>[
                      SizedBox(width: spacing.sm),
                      widget.extra!,
                    ],
                  ],
                ),
              if (hasLabel)
                SizedBox(height: widget.contentTopSpacing ?? spacing.xs),
              widget.child,
              if (hasHelp) ...<Widget>[
                SizedBox(height: spacing.xs),
                Text(
                  helpText!,
                  style: TextStyle(
                    fontSize: typo.sizeCaption,
                    color: colors.textPlaceholder,
                  ),
                ),
              ],
              if (hasFormError) ...<Widget>[
                SizedBox(height: spacing.xs),
                Text(
                  displayError,
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
      },
    );
  }
}
