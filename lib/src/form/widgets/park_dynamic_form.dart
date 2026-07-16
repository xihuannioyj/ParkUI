import 'dart:async';

import 'package:flutter/material.dart';
import '../../../park_ui.dart';

import '../../form/models/form_layout_schema.dart' as layout_models;

/// 动态表单组件。
///
/// 支持字段分组（ExpansionTile，按 [ParkFormFieldSchema.groupKey] 聚合）、
/// 排序（按 [ParkFormFieldSchema.order] 升序）、
/// 显隐联动（visibleRule 含 and/or/not 逻辑运算符）、
/// 禁用联动（disabledRule）、动态必填（requiredRule）。
///
/// 可选注入 [ParkDataSourceResolver] 实现异步数据源加载。
class ParkDynamicForm extends StatefulWidget {
  /// 表单结构。
  final ParkFormSchema schema;

  /// 提交回调。
  final ValueChanged<Map<String, dynamic>> onSubmit;

  /// 异步校验回调（可选）。
  final AsyncFieldValidator? asyncValidator;

  /// 异步校验注册表（按 asyncValidatorKey 映射）。
  final AsyncValidatorRegistry asyncValidatorRegistry;

  /// 提交按钮文本。为 null 时使用 l10n.submitText。
  final String? submitText;

  /// 重置按钮文本。为 null 时使用 l10n.resetText。
  final String? resetText;

  /// 是否显示重置按钮。
  final bool showReset;

  /// 数据源解析器配置回调。
  ///
  /// 允许外部为当前表单注册枚举、字典、缓存或异步选项加载逻辑。
  final void Function(ParkFormEngine engine)? configureEngine;

  /// 双向绑定服务（可选）。
  ///
  /// 传入 [ParkBindingService] 后，表单字段值变化时自动同步到服务。
  final ParkBindingService? bindingService;

  /// 响应式表单组（可选）。
  ///
  /// 传入外部创建的 [ParkFormGroup] 后，组件以该 formGroup 为数据源，
  /// 字段运行时状态（显隐/禁用/必填/选项/加载）直接从 formGroup.fields 读取，
  /// 值变化同步写入 formGroup 控件并触发 reaction 引擎。
  ///
  /// 未传入时组件自行创建内部状态（向后兼容）。
  final ParkFormGroup? formGroup;

  /// 创建动态表单组件。
  const ParkDynamicForm({
    super.key,
    required this.schema,
    required this.onSubmit,
    this.asyncValidator,
    this.asyncValidatorRegistry = const <String, AsyncFieldValidator>{},
    this.submitText,
    this.resetText,
    this.showReset = true,
    this.configureEngine,
    this.bindingService,
    this.formGroup,
  });

  @override
  State<ParkDynamicForm> createState() => _ParkDynamicFormState();
}

/// 动态表单状态。
class _ParkDynamicFormState extends State<ParkDynamicForm> {
  /// 表单引擎。
  final ParkFormEngine _engine = ParkFormEngine();

  /// reaction 运行时引擎。
  final ParkFormReactionEngine _reactionEngine = const ParkFormReactionEngine();

  /// 当前值集合。
  late Map<String, dynamic> _values;

  /// 当前错误集合。
  final Map<String, String> _errors = <String, String>{};

  /// 运行时覆盖状态。
  ParkFormRuntimeOverrides _runtimeOverrides = const ParkFormRuntimeOverrides();

  /// 动态选项集合（由 `$form.xxx` 参数引用触发的联动刷新）。
  ///
  /// 键为字段名，值为重新解析后的选项列表。
  /// 当某字段值变化时，依赖该字段的下游字段会重新请求数据源，
  /// 解析结果存入此 Map，渲染时优先使用此处选项覆盖 field.options。
  final Map<String, List<Map<String, dynamic>>> _dynamicOptions =
      <String, List<Map<String, dynamic>>>{};

  /// 字段 GlobalKey 映射（fieldName → GlobalKey），用于滚动定位首个错误字段（B11）。
  final Map<String, GlobalKey> _fieldKeys = <String, GlobalKey>{};

  /// 是否正在提交中。
  bool _submitting = false;

  /// 提交序列号（B65-Fix2）。
  ///
  /// 每次提交递增，异步校验返回后检查序列号是否匹配，
  /// 不匹配则丢弃结果，防止 await 期间用户修改值导致竞态。
  int _submitSequence = 0;

  /// 绑定服务 watchEffect 句柄（B31：双向绑定回流）。
  WatchEffectHandle? _bindingEffectHandle;

  /// 首次运行标记，初始时跳过 setState（initState 内不可调用 setState）。
  bool _bindingEffectFirstRun = true;

  // ── FormGroup 集成（FG5/FG7/FG8） ──

  /// 运行时表单组（外部传入或内部创建）。
  ParkFormGroup? _formGroup;

  /// 是否由本状态类拥有 formGroup（内部创建 = true，外部传入 = false）。
  bool _ownsFormGroup = false;

  /// 各控件的 valueChanges 流订阅（FG8：用于 reaction 引擎触发）。
  final Map<String, StreamSubscription<dynamic>> _controlSubscriptions =
      <String, StreamSubscription<dynamic>>{};

  /// 重入保护标记（B134）。
  ///
  /// 防止 _handleFieldChanged 被 valueChanges 订阅回调重入，
  /// 当 reaction 修改了触发字段自身时避免无限循环。
  bool _isProcessingChange = false;

  @override
  void initState() {
    super.initState();
    widget.configureEngine?.call(_engine);
    _values = _engine.buildInitialValues(widget.schema);

    // FG5: 初始化 formGroup — 外部传入或内部创建。
    if (widget.formGroup != null) {
      _formGroup = widget.formGroup;
      _ownsFormGroup = false;
    } else {
      _formGroup = ParkFormBuilder.fromSchema(
        widget.schema,
        initialData: _values,
      );
      _ownsFormGroup = true;
    }

    _applyInitialReactions();

    // FG7: 解析静态数据源并同步到 formGroup。
    _resolveStaticDataSources();
    _syncToFormGroup();

    // FG8: 订阅控件值变化以驱动 reaction 引擎。
    _subscribeControlListeners();

    _setupBindingSubscription();
  }

  @override
  void dispose() {
    _teardownBindingSubscription();
    _disposeControlSubscriptions();
    if (_ownsFormGroup) {
      _formGroup?.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ParkDynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.configureEngine != widget.configureEngine) {
      _engine.dataSourceResolver.clear();
      widget.configureEngine?.call(_engine);
    }
    if (oldWidget.schema != widget.schema) {
      _values = _engine.buildInitialValues(widget.schema);
      _errors.clear();
      _dynamicOptions.clear();
      _runtimeOverrides = const ParkFormRuntimeOverrides();

      // FG5: 仅在内部拥有 formGroup 时重建。
      if (_ownsFormGroup) {
        _disposeControlSubscriptions();
        _formGroup?.dispose();
        _formGroup = ParkFormBuilder.fromSchema(
          widget.schema,
          initialData: _values,
        );
        _ownsFormGroup = true;
      }

      _applyInitialReactions();
      _resolveStaticDataSources();
      _syncToFormGroup();
      _subscribeControlListeners();
    } else if (oldWidget.formGroup != widget.formGroup) {
      // 外部 formGroup 引用变化：替换为新的外部 formGroup。
      _disposeControlSubscriptions();
      if (_ownsFormGroup) {
        _formGroup?.dispose();
      }
      _formGroup = widget.formGroup;
      _ownsFormGroup = widget.formGroup == null;
      if (_formGroup != null) {
        _values = _formGroup!.value;
      }
      _syncToFormGroup();
      _subscribeControlListeners();
    }
    // 当 bindingService 或 schema 变化时重新建立绑定订阅（B31）。
    if (oldWidget.bindingService != widget.bindingService ||
        oldWidget.schema != widget.schema) {
      _teardownBindingSubscription();
      _setupBindingSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);

    // 过滤可见字段。
    final List<ParkFormFieldSchema> visibleFields = widget.schema.fields
        .where(
          (ParkFormFieldSchema field) => _isFieldVisible(field),
        )
        .toList();

    // 读取布局配置。
    final layout_models.ParkFormLayout? formLayout = widget.schema.layout;

    // 如果存在 section 配置，按 section 渲染；否则回退到 groupKey 分组。
    final List<Widget> formChildren = formLayout != null &&
            formLayout.sections.isNotEmpty
        ? _buildSectionBasedLayout(visibleFields, formLayout)
        : _buildGroupBasedLayout(visibleFields, l10n);

    // 注入 ParkBindingFormScope，使子组件可通过
    // ParkBindingFormScope.of(context) 获取绑定服务（B31）。
    Widget result = ParkForm(
      submitting: _submitting,
      submitLabel: widget.submitText ?? l10n.submitText,
      resetLabel: widget.resetText ?? l10n.resetText,
      showReset: widget.showReset,
      onSubmit: (_) => _handleSubmit(),
      onReset: _handleReset,
      children: formChildren,
    );

    if (widget.bindingService != null) {
      result = ParkBindingFormScope(
        service: widget.bindingService!,
        child: result,
      );
    }

    return result;
  }

  /// 按 ParkFormLayout.sections 分组渲染字段。
  ///
  /// 支持 card 包裹、collapsible 折叠、inline/stacked 标签布局。
  List<Widget> _buildSectionBasedLayout(
    List<ParkFormFieldSchema> visibleFields,
    layout_models.ParkFormLayout formLayout,
  ) {
    final List<Widget> children = <Widget>[];

    // 按 section 的 fieldIds 分组。
    final Map<String, List<ParkFormFieldSchema>> sectionFields =
        <String, List<ParkFormFieldSchema>>{};
    for (final layout_models.ParkFormSectionConfig section
        in formLayout.sections) {
      sectionFields[section.key] = visibleFields
          .where(
            (ParkFormFieldSchema f) => section.fieldIds.contains(f.fieldId),
          )
          .toList();
    }

    // 收集未被任何 section 包含的字段。
    final Set<String> allSectionFieldIds = formLayout.sections
        .expand((layout_models.ParkFormSectionConfig s) => s.fieldIds)
        .toSet();
    final List<ParkFormFieldSchema> unsectionedFields = visibleFields
        .where(
          (ParkFormFieldSchema f) => !allSectionFieldIds.contains(f.fieldId),
        )
        .toList();

    // 渲染未分组字段。
    if (unsectionedFields.isNotEmpty) {
      children.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: unsectionedFields
              .map(
                (ParkFormFieldSchema f) => _buildField(f, formLayout),
              )
              .toList(),
        ),
      );
    }

    // 渲染各 section。
    for (final layout_models.ParkFormSectionConfig section
        in formLayout.sections) {
      final List<ParkFormFieldSchema> fields =
          sectionFields[section.key] ?? <ParkFormFieldSchema>[];
      if (fields.isEmpty) continue;

      Widget sectionContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fields
            .map(
              (ParkFormFieldSchema f) => _buildField(f, formLayout),
            )
            .toList(),
      );

      // 可折叠包裹。
      if (section.collapsible) {
        sectionContent = _CollapsibleSection(
          title: section.title,
          defaultCollapsed: section.defaultCollapsed,
          child: sectionContent,
        );
      }

      // Card 包裹。
      if (section.card) {
        sectionContent = Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: section.collapsible
                ? sectionContent
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (section.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            section.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      sectionContent,
                    ],
                  ),
          ),
        );
      } else if (!section.collapsible) {
        // 无 card 但有标题时显示标题。
        sectionContent = Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (section.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    section.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              sectionContent,
            ],
          ),
        );
      }

      children.add(sectionContent);
    }

    return children;
  }

  /// 按 groupKey 分组渲染（原有逻辑）。
  List<Widget> _buildGroupBasedLayout(
    List<ParkFormFieldSchema> visibleFields,
    ParkLocalizations l10n,
  ) {
    final Map<String?, List<ParkFormFieldSchema>> grouped = _engine.groupFields(
      visibleFields,
    );

    return grouped.entries.map((
      MapEntry<String?, List<ParkFormFieldSchema>> entry,
    ) {
      final String? groupKey = entry.key;
      final List<ParkFormFieldSchema> fields = entry.value;
      final String? groupName = fields.isNotEmpty
          ? fields.first.groupName
          : null;

      if (groupKey == null && groupName == null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: fields.map((ParkFormFieldSchema f) => _buildField(f)).toList(),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ParkFormSection(
          title: groupName ?? groupKey ?? l10n.unnamedGroup,
          children: fields.map((ParkFormFieldSchema f) => _buildField(f)).toList(),
        ),
      );
    }).toList();
  }

  /// 判断字段是否可见。
  ///
  /// FG5: 当 formGroup 提供时，优先使用运行时字段状态 hidden。
  bool _isFieldVisible(ParkFormFieldSchema field) {
    final ParkFormField? runtimeField = _formGroup?.fields[field.fieldName];
    if (runtimeField != null) {
      return !runtimeField.hidden;
    }
    return _engine.isFieldVisible(
      field,
      _values,
      overrides: _runtimeOverrides,
    );
  }

  /// 构建字段组件。
  ///
  /// [field] 字段结构。
  /// [formLayout] 表单布局配置（可选）。
  Widget _buildField(
    ParkFormFieldSchema field, [
    layout_models.ParkFormLayout? formLayout,
  ]) {
    // FG5: 优先从 formGroup 运行时字段状态读取 disabled/required。
    final ParkFormField? runtimeField = _formGroup?.fields[field.fieldName];
    final bool disabled = runtimeField != null
        ? runtimeField.disabled
        : _engine.isFieldDisabled(
            field,
            _values,
            overrides: _runtimeOverrides,
          );
    final bool required = runtimeField != null
        ? runtimeField.required
        : _engine.isFieldRequired(
            field,
            _values,
            overrides: _runtimeOverrides,
          );
    // 确定标签布局：字段级 > 表单级 > 默认 stacked。
    final layout_models.ParkLabelLayout effectiveLabelLayout =
        field.labelLayout ??
            (formLayout?.defaultLabelLayout ??
                layout_models.ParkLabelLayout.stacked);
    final double gutter = formLayout?.gutter ?? 12.0;

    // FG6: 获取响应式控件，传递给 ParkFormFieldWidget 以集成校验状态。
    final ParkAbstractControl? control = _formGroup?.get(field.fieldName);

    final GlobalKey fieldKey =
        _fieldKeys.putIfAbsent(field.fieldName, () => GlobalKey());

    // FG7: 选项优先使用 formGroup 运行时选项，其次 _dynamicOptions，最后 schema 选项。
    final List<Map<String, dynamic>>? effectiveOptions =
        runtimeField?.options ?? _dynamicOptions[field.fieldName];

    Widget fieldWidget = ParkFormFieldWidget(
      field: field,
      value: _values[field.fieldName],
      errorText: _errors[field.fieldName],
      disabled: disabled,
      required: required,
      dynamicOptions: effectiveOptions,
      labelLayout: effectiveLabelLayout,
      labelWidth: formLayout?.labelWidth,
      onChanged: (dynamic changed) {
        _handleFieldChanged(field.fieldName, changed);
      },
    );

    // FG6: 当存在响应式控件时，用 ParkFormItem 包裹以显示响应式错误。
    if (control != null) {
      fieldWidget = ParkFormItem(
        control: control,
        child: fieldWidget,
      );
    }

    return Padding(
      key: fieldKey,
      padding: EdgeInsets.only(bottom: gutter),
      child: fieldWidget,
    );
  }

  /// 处理字段值变化。
  void _handleFieldChanged(String fieldName, dynamic changed) {
    if (_isProcessingChange) return;
    _isProcessingChange = true;
    try {
      final Map<String, dynamic> nextValues = Map<String, dynamic>.from(_values)
        ..[fieldName] = changed;
      final ParkFormReactionExecutionResult reactionResult = _reactionEngine
          .applyChange(
            schema: widget.schema,
            triggerField: fieldName,
            values: nextValues,
            overrides: _runtimeOverrides,
          );

      setState(() {
        _values = reactionResult.values;
        _runtimeOverrides = reactionResult.overrides;
        for (final String affectedField in reactionResult.affectedFields) {
          _errors.remove(affectedField);
        }
      });

      // FG5/FG8: 同步变化到 formGroup 控件和运行时字段状态。
      _syncValuesToFormGroup(reactionResult);
      _syncFieldStatesToFormGroup();

      // 如果有绑定服务，同步值变化
      if (widget.bindingService != null) {
        widget.bindingService!.setValue(fieldName, changed);
      }

      // FG7: 通知 formGroup 值变化。
      _formGroup?.notifyValueChanged(fieldName);

      _refreshOptionsForFields(<String>{
        ...reactionResult.affectedFields,
        ...reactionResult.reloadFields,
      });
    } finally {
      _isProcessingChange = false;
    }
  }

  /// 初始化时执行一次 change 型 reaction。
  void _applyInitialReactions() {
    for (final ParkFormFieldSchema field in widget.schema.fields) {
      final dynamic initialValue = _values[field.fieldName];
      if (initialValue == null &&
          !widget.schema.reactions.any(
            (ParkFormReactionSchema reaction) =>
                reaction.triggerField == field.fieldName,
          )) {
        continue;
      }

      final ParkFormReactionExecutionResult result = _reactionEngine
          .applyChange(
            schema: widget.schema,
            triggerField: field.fieldName,
            values: _values,
            overrides: _runtimeOverrides,
          );
      _values = result.values;
      _runtimeOverrides = result.overrides;
    }

    final Set<String> initReloadFields = widget.schema.fields
        .where(
          (ParkFormFieldSchema field) =>
              field.dataSourceType != ParkDataSourceType.none,
        )
        .map((ParkFormFieldSchema field) => field.fieldName)
        .toSet();
    _refreshOptionsForFields(initReloadFields);

    // FG5: 初始 reaction 完成后同步到 formGroup。
    _syncToFormGroup();
  }

  /// 刷新依赖 [changedFieldName] 的下游字段选项。
  ///
  /// 遍历所有字段，查找 [ParkFormFieldSchema.dataSourceParams] 中
  /// 引用了 `$form.[changedFieldName]` 的字段，对其调用
  /// [_engine.dataSourceResolver.resolve] 重新获取选项，
  /// 结果存入 [_dynamicOptions] 并触发重建。
  ///
  /// [resolvedFields] 已处理字段集合（B65-Fix5），
  /// 用于跨多次调用去重，防止同一字段被重复 resolve。
  void _refreshDependentOptions(
    String changedFieldName, {
    Set<String>? resolvedFields,
  }) {
    final String formRef = '\$form.$changedFieldName';
    for (final ParkFormFieldSchema dep in widget.schema.fields) {
      // 跳过自身。
      if (dep.fieldName == changedFieldName) continue;
      // 跳过已 resolve 的字段，防止重复网络请求（B65-Fix5）。
      if (resolvedFields != null && resolvedFields.contains(dep.fieldName)) {
        continue;
      }
      // 仅处理有数据源且 dataSourceParams 引用了变化字段的字段。
      if (dep.dataSourceType == ParkDataSourceType.none ||
          dep.dataSourceType == ParkDataSourceType.staticOptions) {
        continue;
      }
      final bool depends = dep.dataSourceParams.values.any(
        (dynamic v) => v is String && v == formRef,
      );
      if (!depends) continue;

      resolvedFields?.add(dep.fieldName);

      // FG7: 设置 loading 状态。
      final ParkFormField? depRuntimeField =
          _formGroup?.fields[dep.fieldName];
      if (depRuntimeField != null) {
        depRuntimeField.loading = true;
        _formGroup?.notifyFieldStateChanged(dep.fieldName);
      }

      _engine.dataSourceResolver.resolve(dep, currentValues: _values).then((
        List<Map<String, dynamic>> options,
      ) {
        if (!mounted) return;
        setState(() {
          _dynamicOptions[dep.fieldName] = options;
          // FG7: 同步选项到 formGroup 运行时字段。
          if (depRuntimeField != null) {
            depRuntimeField.options = options;
            depRuntimeField.loading = false;
          }
        });
        // FG7: 级联清除 — 依赖字段变化时清除下游字段的值。
        // Moved inside .then() to avoid clearing values before async resolve completes.
        final ParkAbstractControl? depControl =
            _formGroup?.get(dep.fieldName);
        if (depControl != null && depControl.value != null) {
          depControl.setValue(null, emitEvent: false);
          _values[dep.fieldName] = null;
          _formGroup?.notifyValueChanged(dep.fieldName);
        }
        // Fix #5: notifyFieldStateChanged inside mounted guard to prevent post-dispose mutation.
        _formGroup?.notifyFieldStateChanged(dep.fieldName);
      });
    }
  }

  /// 按字段集合刷新动态选项。
  void _refreshOptionsForFields(Set<String> fieldNames) {
    // 已处理字段集合，防止同一字段 resolve 两次触发重复网络请求（B65-Fix5）。
    final Set<String> resolvedFields = <String>{};

    for (final String fieldName in fieldNames) {
      _refreshDependentOptions(fieldName, resolvedFields: resolvedFields);
    }

    for (final ParkFormFieldSchema field in widget.schema.fields) {
      if (!fieldNames.contains(field.fieldName)) {
        continue;
      }
      // 跳过已在上一轮作为依赖字段被 resolve 过的字段（B65-Fix5）。
      if (resolvedFields.contains(field.fieldName)) {
        continue;
      }
      if (field.dataSourceType == ParkDataSourceType.none ||
          field.dataSourceType == ParkDataSourceType.staticOptions) {
        continue;
      }

      // FG7: 设置 loading 状态。
      final ParkFormField? runtimeField = _formGroup?.fields[field.fieldName];
      if (runtimeField != null) {
        runtimeField.loading = true;
        _formGroup?.notifyFieldStateChanged(field.fieldName);
      }

      _engine.dataSourceResolver.resolve(field, currentValues: _values).then((
        List<Map<String, dynamic>> options,
      ) {
        if (!mounted) return;
        setState(() {
          _dynamicOptions[field.fieldName] = options;
          // FG7: 同步选项到 formGroup 运行时字段。
          if (runtimeField != null) {
            runtimeField.options = options;
            runtimeField.loading = false;
          }
        });
        _formGroup?.notifyFieldStateChanged(field.fieldName);
      });
    }
  }

  /// 建立绑定订阅：通过 watchEffect 监听外部 bindingService 变更，
  /// 将外部值回灌到 _values 中，实现双向绑定回流（B31）。
  void _setupBindingSubscription() {
    final ParkBindingService? svc = widget.bindingService;
    if (svc == null) return;
    _bindingEffectFirstRun = true;
    _bindingEffectHandle = svc.watchEffect(() {
      bool changed = false;
      final Map<String, dynamic> newValues = Map<String, dynamic>.from(_values);
      for (final ParkFormFieldSchema field in widget.schema.fields) {
        final dynamic svcValue = svc.getValue<dynamic>(field.fieldName);
        if (svcValue != null) {
          final dynamic currentValue = newValues[field.fieldName];
          if (currentValue != svcValue) {
            newValues[field.fieldName] = svcValue;
            changed = true;
          }
        }
      }
      if (changed) {
        _values = newValues;
        // 首次运行在 initState 中，不可调用 setState。
        if (!_bindingEffectFirstRun && mounted) {
          setState(() {});
        }
      }
      _bindingEffectFirstRun = false;
    });
  }

  /// 清除绑定订阅（B31）。
  void _teardownBindingSubscription() {
    _bindingEffectHandle?.call();
    _bindingEffectHandle = null;
    _bindingEffectFirstRun = true;
  }

  /// 提交表单。
  ///
  /// 先执行同步校验，再执行异步校验。
  /// 校验通过后自动定位首个错误字段或调用 [onSubmit]。
  Future<void> _handleSubmit() async {
    setState(() => _submitting = true);
    // 递增提交序列号（B65-Fix2）。
    _submitSequence++;
    final int currentSeq = _submitSequence;
    final l10n = ParkLocalizations.of(context);

    try {
      // 同步校验。
      final Map<String, String> syncErrors = _engine.validateForm(
        widget.schema,
        _values,
        overrides: _runtimeOverrides,
      );
      final Map<String, String> mergedErrors = <String, String>{...syncErrors};

      // FG5: formGroup 模式下额外执行控件级校验，并过滤隐藏字段错误。
      if (_formGroup != null) {
        await _formGroup!.validate();
        final Map<String, List<ParkFormError>> fgErrors = _formGroup!.errors;
        for (final MapEntry<String, List<ParkFormError>> entry
            in fgErrors.entries) {
          final ParkFormField? rtField = _formGroup!.fields[entry.key];
          // 跳过隐藏字段的校验错误。
          if (rtField != null && rtField.hidden) continue;
          if (!mergedErrors.containsKey(entry.key) && entry.value.isNotEmpty) {
            mergedErrors[entry.key] = entry.value.first.message;
          }
        }
      }

      // 异步校验。
      if (widget.asyncValidator != null) {
        _engine.registerAsyncValidators(widget.asyncValidatorRegistry);
        final Map<String, String> asyncErrors = await _engine.validateFormAsync(
          widget.schema,
          _values,
          widget.asyncValidator!,
          overrides: _runtimeOverrides,
          l10n: l10n,
        );
        // 序列号不匹配说明有新的提交启动，丢弃本次结果（B65-Fix2）。
        if (_submitSequence != currentSeq) {
          if (mounted) setState(() => _submitting = false);
          return;
        }
        mergedErrors.addAll(asyncErrors);
      } else if (widget.asyncValidatorRegistry.isNotEmpty) {
        _engine.registerAsyncValidators(widget.asyncValidatorRegistry);
        final Map<String, String> asyncErrors = await _engine.validateFormAsync(
          widget.schema,
          _values,
          null,
          overrides: _runtimeOverrides,
          l10n: l10n,
        );
        // 序列号不匹配说明有新的提交启动，丢弃本次结果（B65-Fix2）。
        if (_submitSequence != currentSeq) {
          if (mounted) setState(() => _submitting = false);
          return;
        }
        mergedErrors.addAll(asyncErrors);
      }

      setState(() {
        _errors
          ..clear()
          ..addAll(mergedErrors);
      });

      if (!mounted) return;
      if (_errors.isEmpty) {
        widget.onSubmit(_engine.exportValues(_values));
      } else {
        // 滚动到首个错误字段（简易实现）。
        _scrollToFirstError(mergedErrors.keys.first);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  /// 滚动到首个错误字段位置（B11）。
  ///
  /// 通过字段对应的 [GlobalKey] 调用 [Scrollable.ensureVisible] 定位。
  /// 若字段尚未挂载或不存在可滚动祖先，则静默忽略。
  ///
  /// [fieldKey] 首个错误字段的键名。
  void _scrollToFirstError(String fieldKey) {
    final GlobalKey? key = _fieldKeys[fieldKey];
    if (key == null) return;
    final BuildContext? context = key.currentContext;
    if (context == null) return;
    try {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      // 无滚动祖先时忽略。
    }
  }

  /// 重置表单。
  void _handleReset() {
    setState(() {
      _values = _engine.buildInitialValues(widget.schema);
      _runtimeOverrides = const ParkFormRuntimeOverrides();
      _errors.clear();
      _dynamicOptions.clear();
    });

    // FG5: 重置 formGroup。
    if (_ownsFormGroup) {
      _disposeControlSubscriptions();
      _formGroup?.dispose();
      _formGroup = ParkFormBuilder.fromSchema(
        widget.schema,
        initialData: _values,
      );
      _ownsFormGroup = true;
    } else {
      _formGroup?.reset(_values);
    }

    _applyInitialReactions();
    _resolveStaticDataSources();
    _syncToFormGroup();
    _subscribeControlListeners();
  }

  // ══════════════════════════════════════════════════════════════════════
  // FormGroup 集成辅助方法（FG5 / FG7 / FG8）
  // ══════════════════════════════════════════════════════════════════════

  /// 订阅所有 formGroup 控件的 valueChanges 流。
  ///
  /// FG8: 当控件值从外部变化时（如 patchValue），自动触发 reaction 引擎。
  void _subscribeControlListeners() {
    _disposeControlSubscriptions();
    if (_formGroup == null) return;
    for (final String key in _formGroup!.fields.keys) {
      final ParkAbstractControl? control = _formGroup!.get(key);
      if (control == null) continue;
      _controlSubscriptions[key] = control.valueChanges.listen((dynamic _) {
        if (!mounted) return;
        // 从 formGroup 同步值到 _values（处理外部 patchValue 场景）。
        _values[key] = control.value;
        _handleFieldChanged(key, control.value);
      }, onError: (dynamic e) => debugPrint('Stream error: $e'));
    }
  }

  /// 取消所有控件的流订阅。
  void _disposeControlSubscriptions() {
    for (final StreamSubscription<dynamic> sub in _controlSubscriptions.values) {
      sub.cancel();
    }
    _controlSubscriptions.clear();
  }

  /// 将 reaction 执行结果同步到 formGroup 控件值。
  ///
  /// FG8: reaction 可能通过 setValue / clearValue 修改了多个字段的值，
  /// 此处将最新 _values 写入对应的 formGroup 控件。
  void _syncValuesToFormGroup(ParkFormReactionExecutionResult result) {
    if (_formGroup == null) return;
    for (final String key in result.affectedFields) {
      final ParkAbstractControl? control = _formGroup!.get(key);
      if (control == null) continue;
      final dynamic targetValue = _values[key];
      if (control.value != targetValue) {
        control.setValue(targetValue, emitEvent: false);
      }
    }
  }

  /// 将引擎计算的运行时字段状态同步到 formGroup。
  ///
  /// FG8: 将 visible / disabled / required 覆盖写入 formGroup 的 ParkFormField。
  void _syncFieldStatesToFormGroup() {
    if (_formGroup == null) return;
    for (final ParkFormFieldSchema field in widget.schema.fields) {
      final ParkFormField? runtimeField = _formGroup!.fields[field.fieldName];
      if (runtimeField == null) continue;
      runtimeField.hidden = !_isFieldVisible(field);
      runtimeField.disabled = _engine.isFieldDisabled(
        field,
        _values,
        overrides: _runtimeOverrides,
      );
      runtimeField.required = _engine.isFieldRequired(
        field,
        _values,
        overrides: _runtimeOverrides,
      );
    }
  }

  /// 全量同步：值 + 字段状态 + 选项。
  void _syncToFormGroup() {
    if (_formGroup == null) return;
    // 同步控件值。
    for (final String key in _formGroup!.fields.keys) {
      final ParkAbstractControl? control = _formGroup!.get(key);
      if (control == null) continue;
      final dynamic targetValue = _values[key];
      if (control.value != targetValue) {
        control.setValue(targetValue, emitEvent: false);
      }
    }
    _syncFieldStatesToFormGroup();
    _syncOptionsToFormGroup();
  }

  /// 将 _dynamicOptions 同步到 formGroup 运行时字段选项。
  void _syncOptionsToFormGroup() {
    if (_formGroup == null) return;
    for (final MapEntry<String, List<Map<String, dynamic>>> entry
        in _dynamicOptions.entries) {
      final ParkFormField? field = _formGroup!.fields[entry.key];
      if (field != null) {
        field.options = entry.value;
      }
    }
  }

  /// FG7: 初始化时立即解析静态数据源（enumSource / dict / cache）。
  ///
  /// 解析结果写入 _dynamicOptions 并同步到 formGroup 运行时字段选项。
  void _resolveStaticDataSources() {
    for (final ParkFormFieldSchema field in widget.schema.fields) {
      if (field.dataSourceType == ParkDataSourceType.enumSource ||
          field.dataSourceType == ParkDataSourceType.dict ||
          field.dataSourceType == ParkDataSourceType.cache) {
        _engine.dataSourceResolver.resolve(field, currentValues: _values).then(
          (List<Map<String, dynamic>> options) {
            if (!mounted) return;
            setState(() {
              _dynamicOptions[field.fieldName] = options;
              final ParkFormField? runtimeField =
                  _formGroup?.fields[field.fieldName];
              if (runtimeField != null) {
                runtimeField.options = options;
              }
            });
          },
        ).catchError((dynamic _) {});
      }
    }
  }
}

/// 可折叠分组容器。
///
/// 使用 ExpansionTile 实现折叠/展开行为，
/// 支持 [defaultCollapsed] 控制初始折叠状态。
class _CollapsibleSection extends StatefulWidget {
  /// 分组标题。
  final String title;

  /// 是否默认折叠。
  final bool defaultCollapsed;

  /// 子组件。
  final Widget child;

  /// 创建可折叠分组。
  const _CollapsibleSection({
    required this.title,
    this.defaultCollapsed = false,
    required this.child,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.defaultCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() => _isExpanded = expanded);
      },
      childrenPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      children: <Widget>[widget.child],
    );
  }
}
