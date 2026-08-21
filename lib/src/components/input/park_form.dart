import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_service.dart';
import '../../binding/park_binding_form_scope.dart';
import '../../l10n/park_localizations.dart';
import '../../form/group/form_group_exports.dart';
import '../../form/models/form_field_schema.dart';
import '../../form/engine/form_engine.dart';
import '../../form/widgets/park_dynamic_form.dart';

/// 表单布局方式
enum ParkFormLayout {
  /// 标签在上方
  vertical,

  /// 标签在左侧，水平排列
  horizontal,

  /// 内联排列
  inline,
}

/// 必填标记样式
enum ParkRequiredMark {
  /// 可选标记（不显示任何标记）
  optional,

  /// 星号标记（显示红色 * 号）
  asterisk,

  /// 不显示任何标记
  none,
}

/// 表单尺寸
enum ParkFormSize {
  /// 小号
  small,

  /// 中号
  medium,

  /// 大号
  large,
}

/// 值变更回调签名
typedef ParkFormValuesChangeCallback = void Function(
  Map<String, dynamic> changedValues,
  Map<String, dynamic> allValues,
);

/// InheritedWidget，将表单配置传递给子组件
class ParkFormScope extends InheritedWidget {
  /// 表单布局方式
  final ParkFormLayout layout;

  /// 标签固定宽度（horizontal 布局时生效）
  final double labelWidth;

  /// 是否在标签后显示冒号
  final bool colon;

  /// 必填标记样式
  final ParkRequiredMark requiredMark;

  /// 表单尺寸（传递给子组件输入控件）
  final ParkFormSize? size;

  /// 标签列占格数（24 栅格）/ Label column span (24-grid)
  final int? labelCol;

  /// 控件列占格数（24 栅格）/ Wrapper column span (24-grid)
  final int? wrapperCol;

  /// 注册表单字段 GlobalKey（供 scrollToFirstError 使用）
  final void Function(String name, GlobalKey key)? registerFieldKey;

  /// 注销表单字段 GlobalKey
  final void Function(String name)? unregisterFieldKey;

  /// 通知值变更（供 ParkFormItem 调用）
  final void Function(String name, dynamic value)? notifyFieldChanged;

  /// 监听字段值变化
  final VoidCallback Function(String fieldName, void Function(dynamic value) callback)? watch;

  /// 取消监听字段值变化
  final void Function(String fieldName)? unwatch;

  const ParkFormScope({
    super.key,
    required this.layout,
    required this.labelWidth,
    required this.colon,
    required this.requiredMark,
    this.size,
    this.labelCol,
    this.wrapperCol,
    this.registerFieldKey,
    this.unregisterFieldKey,
    this.notifyFieldChanged,
    this.watch,
    this.unwatch,
    required super.child,
  });

  /// 获取最近的 [ParkFormScope]
  static ParkFormScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ParkFormScope>();
  }

  @override
  bool updateShouldNotify(ParkFormScope oldWidget) {
    return layout != oldWidget.layout ||
        labelWidth != oldWidget.labelWidth ||
        colon != oldWidget.colon ||
        requiredMark != oldWidget.requiredMark ||
        size != oldWidget.size ||
        labelCol != oldWidget.labelCol ||
        wrapperCol != oldWidget.wrapperCol ||
        registerFieldKey != oldWidget.registerFieldKey ||
        unregisterFieldKey != oldWidget.unregisterFieldKey ||
        notifyFieldChanged != oldWidget.notifyFieldChanged ||
        watch != oldWidget.watch ||
        unwatch != oldWidget.unwatch;
  }
}

/// Park 表单容器 — 统一入口
///
/// 支持两种使用模式：
///
/// **手动模式**（使用 [children]）：
/// 包裹 Flutter 原生 [Form]，提供 [GlobalKey<FormState>] 管理，
/// 内置提交 / 重置按钮，收集子表单字段值。
///
/// ```dart
/// ParkForm(
///   onSubmit: (values) => print('提交: $values'),
///   children: [
///     ParkFormItem(label: '姓名', child: ParkInput()),
///   ],
/// )
/// ```
///
/// **Schema 驱动模式**（使用 [schema]）：
/// 传入 [ParkFormSchema] 即可自动渲染字段、处理联动、校验和数据源加载。
///
/// ```dart
/// ParkForm(
///   schema: ParkFormSchema(
///     formKey: 'contact',
///     fields: [
///       ParkFormFieldSchema(
///         fieldId: 'f_name',
///         fieldType: ParkFieldType.text,
///         labelName: '姓名',
///         fieldName: 'name',
///         isRequired: true,
///       ),
///     ],
///   ),
///   onSchemaSubmit: (values) => print(values),
/// )
/// ```
class ParkForm extends StatefulWidget {
  /// 提交回调，参数为表单字段值的集合
  final ValueChanged<Map<String, dynamic>>? onSubmit;

  /// 重置回调
  final VoidCallback? onReset;

  /// 是否处于提交中状态。
  final bool submitting;

  /// 是否处于整体加载态。
  final bool loading;

  /// 提交按钮文字。为 null 时使用本地化默认值。
  final String? submitLabel;

  /// 重置按钮文字。为 null 时使用本地化默认值。
  final String? resetLabel;

  /// 是否显示重置按钮
  final bool showReset;

  /// 子组件间距
  final double? spacing;

  /// 表单内边距
  final EdgeInsetsGeometry? padding;

  /// 自定义底部区域。
  final Widget? footer;

  /// 是否显示默认按钮区。
  final bool showDefaultActions;

  /// 初始值集合。在 initState 时调用 setValue 逐项填充。
  final Map<String, dynamic>? initialValues;

  /// 表单布局方式。默认 [ParkFormLayout.vertical]。
  final ParkFormLayout layout;

  /// horizontal 布局时标签的固定宽度。默认 100。
  final double labelWidth;

  /// 是否在标签后显示中文冒号"："。默认 true。
  final bool colon;

  /// 必填标记样式。默认 [ParkRequiredMark.asterisk]。
  final ParkRequiredMark requiredMark;

  /// 校验失败时是否自动滚动到第一个错误字段。默认 false。
  final bool scrollToFirstError;

  /// 任意字段值变更时的回调。
  final ParkFormValuesChangeCallback? onValuesChange;

  /// 表单尺寸，传递给子组件输入控件。默认 null（各子组件使用自身尺寸）。
  final ParkFormSize? size;

  /// 绑定模型数据（可选）。
  ///
  /// 传入 [Map<String, dynamic>] 后，ParkForm 自动创建 [ParkBindingService]，
  /// 子组件可通过 [ParkBindingFormScope.of(context)] 获取绑定服务，
  /// 实现双向绑定。与 [bindingService] 二选一使用。
  final Map<String, dynamic>? model;

  /// 外部绑定服务（可选）。
  ///
  /// 传入 [ParkBindingService] 后，ParkForm 将其注入到子组件树中，
  /// 子组件可通过 [ParkBindingFormScope.of(context)] 获取绑定服务。
  /// 与 [model] 二选一使用，[bindingService] 优先级更高。
  final ParkBindingService? bindingService;

  /// 外部传入的 [FormState] 全局键。
  ///
  /// 传入后，[ParkForm] 内部 [Form] 使用此键，调用方可通过该键直接执行
  /// `formKey.currentState?.validate()` / `reset()` 等，无需依赖 [ParkForm.of]。
  /// 不传时由组件内部创建（B30 / 开发文档.md §7.8，消除 README 中"已声明却不存在"的 formKey 形参）。
  final GlobalKey<FormState>? formKey;

  /// 标签列占格数（总共 24 格）/ Label column span (out of 24 total)
  ///
  /// 与 [wrapperCol] 同时设置时，[ParkFormItem] 内部使用 [Row] + [Expanded]
  /// 按栅格比例布局标签和控件。两者之和应 ≤ 24。
  ///
  /// When both this and [wrapperCol] are set, [ParkFormItem] uses [Row] + [Expanded]
  /// to lay out label and control by grid ratio. Sum should be ≤ 24.
  final int? labelCol;

  /// 控件列占格数（总共 24 格）/ Wrapper column span (out of 24 total)
  ///
  /// 与 [labelCol] 同时设置时生效。详见 [labelCol]。
  ///
  /// Effective when [labelCol] is also set. See [labelCol].
  final int? wrapperCol;

  /// 响应式表单组（可选）。
  ///
  /// 传入 [ParkFormGroup] 后，ParkForm 以该 formGroup 为数据源，
  /// 通过 [ParkFormState.formGroup] 暴露值访问、校验、批量赋值等 API。
  /// 与 [model] / [bindingService] 可共存，formGroup 优先级最高。
  final ParkFormGroup? formGroup;

  /// Schema 驱动模式：表单结构定义。
  ///
  /// 传入 [ParkFormSchema] 后，ParkForm 自动根据 schema 渲染字段、
  /// 处理联动（reaction）、校验、数据源加载等，无需手动编写 children。
  ///
  /// 与 [children] 二选一：传入 schema 时为 schema 驱动模式，
  /// 未传入时为手动模式（使用 children 手动编排字段）。
  final ParkFormSchema? schema;

  /// Schema 模式：提交回调。
  final ValueChanged<Map<String, dynamic>>? onSchemaSubmit;

  /// Schema 模式：异步校验回调。
  final AsyncFieldValidator? asyncValidator;

  /// Schema 模式：异步校验注册表（按 asyncValidatorKey 映射）。
  final Map<String, AsyncFieldValidator> asyncValidatorRegistry;

  /// Schema 模式：引擎配置回调（注入数据源解析器等）。
  final void Function(ParkFormEngine engine)? configureEngine;

  /// 子组件列表（手动模式：表单字段）。
  ///
  /// 当 [schema] 不为 null 时，此参数被忽略。
  final List<Widget> children;

  const ParkForm({
    super.key,
    this.onSubmit,
    this.onReset,
    this.submitting = false,
    this.loading = false,
    this.submitLabel,
    this.resetLabel,
    this.showReset = false,
    this.spacing,
    this.padding,
    this.footer,
    this.showDefaultActions = true,
    this.initialValues,
    this.layout = ParkFormLayout.vertical,
    this.labelWidth = 100,
    this.colon = true,
    this.requiredMark = ParkRequiredMark.asterisk,
    this.scrollToFirstError = false,
    this.onValuesChange,
    this.size,
    this.model,
    this.bindingService,
    this.formKey,
    this.labelCol,
    this.wrapperCol,
    this.formGroup,
    this.schema,
    this.onSchemaSubmit,
    this.asyncValidator,
    this.asyncValidatorRegistry = const <String, AsyncFieldValidator>{},
    this.configureEngine,
    this.children = const <Widget>[],
  });

  /// 获取最近的 [ParkFormState]
  ///
  /// 子组件可通过此方法访问表单状态，执行提交 / 重置 / 校验等操作。
  ///
  /// 注意：此处使用 [BuildContext.findAncestorStateOfType] 查找 [State] 对象，
  /// 这是 Flutter 中跨组件树访问 State 的标准方式。与 [InheritedWidget] 不同，
  /// [State] 无法通过 `dependOnInheritedWidgetOfExactType` 获取。
  static ParkFormState? of(BuildContext context) {
    return context.findAncestorStateOfType<ParkFormState>();
  }

  @override
  State<ParkForm> createState() => ParkFormState();
}

class ParkFormState extends State<ParkForm> {
  late final GlobalKey<FormState> _formKey;

  /// 表单字段值收集器
  final Map<String, dynamic> _values = {};

  /// 字段名 → GlobalKey 映射，供 scrollToFirstError 使用
  final Map<String, GlobalKey> _fieldKeys = {};

  /// 字段 watchers，值变化时通知对应回调
  final Map<String, List<void Function(dynamic value)>> _watchers = {};

  /// 双向绑定服务（外部传入或从 model 自动创建）。
  ParkBindingService? _bindingService;

  /// 是否由本状态类拥有绑定服务（外部传入的不由我们 dispose）。
  bool _ownsBindingService = false;

  /// 自动创建服务时记录的初始 model，reset 时恢复用。
  Map<String, dynamic>? _initialModelSnapshot;

  /// Flutter Form 的 GlobalKey
  GlobalKey<FormState> get formKey => _formKey;

  /// 当前收集的表单值
  Map<String, dynamic> get values => Map<String, dynamic>.from(_values);

  /// 字段 GlobalKey 映射（只读）
  Map<String, GlobalKey> get fieldKeys =>
      Map<String, GlobalKey>.from(_fieldKeys);

  /// 获取双向绑定服务（如果已创建）。
  ParkBindingService? get bindingService => _bindingService;

  /// 获取响应式表单组（如果已提供）。
  ///
  /// FG5: 外部传入的 [ParkFormGroup]，可通过此属性访问值、校验、批量赋值等 API。
  ParkFormGroup? get formGroup => widget.formGroup;

  @override
  void initState() {
    super.initState();
    // 优先使用外部传入的 formKey（B30 / §7.8），否则内部创建。
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    // 用 initialValues 填充表单值
    if (widget.initialValues != null) {
      for (final entry in widget.initialValues!.entries) {
        _values[entry.key] = entry.value;
      }
    }
    // 优先使用外部传入的绑定服务，其次从 model 自动创建
    if (widget.bindingService != null) {
      _bindingService = widget.bindingService;
      _ownsBindingService = false;
    } else if (widget.model != null) {
      _initialModelSnapshot = Map<String, dynamic>.from(widget.model!);
      _bindingService = ParkBindingService(widget.model);
      _ownsBindingService = true;
    }
    // Seed _values from binding model so submit() includes bindKey fields
    if (_bindingService != null && _values.isEmpty) {
      _values.addAll(_bindingService!.model);
    }
  }

  /// 获取表单值（同 [values]，统一 API 入口）。
  ///
  /// FG5: 当 formGroup 存在时，优先返回 formGroup.value。
  Map<String, dynamic> getValues() {
    if (widget.formGroup != null) {
      return widget.formGroup!.value;
    }
    return Map<String, dynamic>.from(_values);
  }

  /// FG5: 批量设置 formGroup 控件值。
  ///
  /// 当 formGroup 存在时，委托给 [ParkFormGroup.patchValue]。
  void patchFormGroupValues(Map<String, dynamic> values) {
    widget.formGroup?.patchValue(values);
  }

  /// FG5: 异步校验 formGroup 所有控件。
  ///
  /// 当 formGroup 存在时，委托给 [ParkFormGroup.validate]。
  /// 返回 true 表示全部通过。
  Future<bool> validateFormGroup() async {
    if (widget.formGroup != null) {
      return widget.formGroup!.validate();
    }
    return validate();
  }

  /// 监听指定字段的值变化。
  ///
  /// 返回一个 [VoidCallback]，调用后取消本次订阅。
  VoidCallback watch(String fieldName, void Function(dynamic value) callback) {
    _watchers.putIfAbsent(fieldName, () => []);
    _watchers[fieldName]!.add(callback);
    return () => _watchers[fieldName]?.remove(callback);
  }

  /// 取消对指定字段的所有监听。
  void unwatch(String fieldName) {
    _watchers.remove(fieldName);
  }

  /// 设置表单字段值（供子组件调用）
  void setValue(String key, dynamic value) {
    final oldValue = _values[key];
    if (oldValue == value) return;
    _values[key] = value;
    // 通知 onValuesChange 回调
    widget.onValuesChange?.call(
      {key: value},
      Map<String, dynamic>.from(_values),
    );
    // 通知字段级 watchers
    final watchers = _watchers[key];
    if (watchers != null && watchers.isNotEmpty) {
      for (final callback in List<void Function(dynamic)>.from(watchers)) {
        callback(value);
      }
    }
  }

  /// 移除表单字段值
  void removeValue(String key) {
    _values.remove(key);
  }

  /// 注册字段 GlobalKey（供 ParkFormItem 调用）
  void registerFieldKey(String name, GlobalKey key) {
    _fieldKeys[name] = key;
  }

  /// 注销字段 GlobalKey
  void unregisterFieldKey(String name) {
    _fieldKeys.remove(name);
  }

  /// 通知字段值变更（供 ParkFormItem / ParkFormScope 调用）
  void notifyFieldChanged(String name, dynamic value) {
    setValue(name, value);
  }

  /// 提交表单
  bool submit() {
    if (widget.submitting || widget.loading) return false;

    final form = _formKey.currentState;
    if (form == null) return false;

    if (form.validate()) {
      form.save();
      // Merge bindingService values, but only for keys that correspond to
      // actual form fields (i.e. keys already present in _values).
      final values = Map<String, dynamic>.from(_values);
      if (_bindingService != null) {
        for (final String key in _values.keys) {
          if (_bindingService!.model.containsKey(key)) {
            values[key] = _bindingService!.model[key];
          }
        }
      }
      // 统一提交规整：所有 String 值去掉两侧空白（trim），
      // 覆盖 ParkInput / ParkTextarea / ParkSearch / ParkMentions / 表单字段等全部文本输入。
      final Map<String, dynamic> trimmedValues = values.map(
        (String key, dynamic value) => MapEntry<String, dynamic>(
          key,
          value is String ? value.trim() : value,
        ),
      );
      widget.onSubmit?.call(trimmedValues);
      return true;
    }

    // 校验失败，滚动到第一个错误字段
    if (widget.scrollToFirstError) {
      _scrollToFirstError();
    }

    return false;
  }

  /// 重置表单
  void reset() {
    if (widget.submitting || widget.loading) return;

    _formKey.currentState?.reset();
    _values.clear();
    // 补充 P1：重置后恢复 initialValues 与绑定模型种子，
    // 否则 submit() 拿到的 values 丢失所有初始字段。
    if (widget.initialValues != null) {
      _values.addAll(widget.initialValues!);
    }
    // 自动创建的服务一并恢复到初始 model
    if (_ownsBindingService &&
        _bindingService != null &&
        _initialModelSnapshot != null) {
      _bindingService!.updateModel(_initialModelSnapshot!);
      // 自动创建服务时，_values 从 model 种子
      if (_values.isEmpty) {
        _values.addAll(_bindingService!.model);
      }
    }
    widget.onReset?.call();
  }

  /// 校验表单（不触发 save）
  bool validate() {
    final result = _formKey.currentState?.validate() ?? false;

    // 校验失败，滚动到第一个错误字段
    if (!result && widget.scrollToFirstError) {
      _scrollToFirstError();
    }

    return result;
  }

  /// 滚动到第一个存在错误的字段
  void _scrollToFirstError() {
    // 延迟一帧，确保错误文本已渲染
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final entry in _fieldKeys.entries) {
        final ctx = entry.value.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Schema 驱动模式：委托给内部 schema 表单组件。
    if (widget.schema != null) {
      return ParkDynamicForm(
        schema: widget.schema!,
        onSubmit: widget.onSchemaSubmit ?? widget.onSubmit ?? (_) {},
        asyncValidator: widget.asyncValidator,
        asyncValidatorRegistry: widget.asyncValidatorRegistry,
        configureEngine: widget.configureEngine,
        bindingService: widget.bindingService,
        formGroup: widget.formGroup,
        submitText: widget.submitLabel,
        resetText: widget.resetLabel,
        showReset: widget.showReset,
      );
    }

    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final spacing = park.spacing;

    final itemSpacing = widget.spacing ?? spacing.base;
    final formPadding = widget.padding ?? EdgeInsets.zero;

    Widget formContent = ParkFormScope(
      layout: widget.layout,
      labelWidth: widget.labelWidth,
      colon: widget.colon,
      requiredMark: widget.requiredMark,
      size: widget.size,
      labelCol: widget.labelCol,
      wrapperCol: widget.wrapperCol,
      registerFieldKey: registerFieldKey,
      unregisterFieldKey: unregisterFieldKey,
      notifyFieldChanged: notifyFieldChanged,
      watch: watch,
      unwatch: unwatch,
      child: Padding(
        padding: formPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 表单字段
              ..._buildChildren(itemSpacing),

              if (widget.loading) ...<Widget>[
                SizedBox(height: spacing.lg),
                _buildLoadingState(park),
              ],

              if (widget.footer != null || widget.showDefaultActions) ...<Widget>[
                SizedBox(height: spacing.lg),
                widget.footer ?? _buildButtons(park),
              ],
            ],
          ),
        ),
      ),
    );

    // 如果有绑定服务，使用 ParkBindingFormScope 包装
    if (_bindingService != null) {
      formContent = ParkBindingFormScope(
        service: _bindingService!,
        child: formContent,
      );
    }

    return formContent;
  }

  @override
  void dispose() {
    _watchers.clear();
    _values.clear();
    _fieldKeys.clear();
    if (_ownsBindingService) {
      _bindingService?.dispose();
    }
    super.dispose();
  }

  List<Widget> _buildChildren(double itemSpacing) {
    final result = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      result.add(widget.children[i]);
      if (i < widget.children.length - 1) {
        result.add(SizedBox(height: itemSpacing));
      }
    }
    return result;
  }

  Widget _buildButtons(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;
    final l10n = ParkLocalizations.of(context);
    final effectiveSubmitLabel = widget.submitLabel ?? l10n.submitText;
    final effectiveResetLabel = widget.resetLabel ?? l10n.resetText;

    return Row(
      children: [
        // 重置按钮
        if (widget.showReset) ...[
          Expanded(
            child: _ParkFormButton(
              label: effectiveResetLabel,
              backgroundColor: colors.surface,
              foregroundColor: colors.textPrimary,
              borderColor: colors.border,
              borderRadius: radius.md,
              height: 42,
              fontSize: typo.sizeBody,
              fontWeight: typo.weightMedium,
              loading: false,
              enabled: !widget.submitting && !widget.loading,
              onPressed: reset,
            ),
          ),
          SizedBox(width: spacing.md),
        ],

        // 提交按钮
        Expanded(
          child: _ParkFormButton(
            label: effectiveSubmitLabel,
            backgroundColor: colors.brand,
            foregroundColor: colors.textOnBrand,
            borderColor: null,
            borderRadius: radius.md,
            height: 42,
            fontSize: typo.sizeBody,
            fontWeight: typo.weightMedium,
            loading: widget.submitting,
            enabled: !widget.loading,
            onPressed: () => submit(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ParkThemeData park) {
    final colors = park.colors;
    final spacing = park.spacing;
    final radius = park.radius;
    final typo = park.typography;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colors.disabledBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.borderLight.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(colors.brand),
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(
            ParkLocalizations.of(context).formLoadingText,
            style: TextStyle(
              fontSize: typo.sizeBodySmall,
              color: colors.textSecondary,
              fontWeight: typo.weightMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// 内部：表单按钮
class _ParkFormButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double height;
  final double fontSize;
  final FontWeight? fontWeight;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  const _ParkFormButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.borderRadius,
    required this.height,
    required this.fontSize,
    this.fontWeight,
    this.loading = false,
    this.enabled = true,
    required this.onPressed,
  });

  @override
  State<_ParkFormButton> createState() => _ParkFormButtonState();
}

class _ParkFormButtonState extends State<_ParkFormButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool canPress = widget.enabled && !widget.loading;
    final scale = _isPressed ? 0.97 : 1.0;
    final opacity = canPress ? (_isPressed ? 0.85 : 1.0) : 0.5;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 150),
        child: Semantics(
          button: true,
          enabled: canPress,
          label: widget.label,
          child: GestureDetector(
          onTapDown: canPress ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: canPress ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: canPress
              ? () => setState(() => _isPressed = false)
              : null,
          onTap: canPress ? widget.onPressed : null,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1.0)
                  : null,
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        widget.foregroundColor,
                      ),
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.foregroundColor,
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                    ),
                  ),
          ),
          ),
        ),
      ),
    );
  }
}
