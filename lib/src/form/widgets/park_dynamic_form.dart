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

  /// 提交按钮文本。
  final String submitText;

  /// 重置按钮文本。
  final String resetText;

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

  /// 创建动态表单组件。
  const ParkDynamicForm({
    super.key,
    required this.schema,
    required this.onSubmit,
    this.asyncValidator,
    this.asyncValidatorRegistry = const <String, AsyncFieldValidator>{},
    this.submitText = '提交',
    this.resetText = '重置',
    this.showReset = true,
    this.configureEngine,
    this.bindingService,
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

  /// 是否正在提交中。
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    widget.configureEngine?.call(_engine);
    _values = _engine.buildInitialValues(widget.schema);
    _applyInitialReactions();
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
      _applyInitialReactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 过滤可见字段。
    final List<ParkFormFieldSchema> visibleFields = widget.schema.fields
        .where(
          (ParkFormFieldSchema field) => _engine.isFieldVisible(
            field,
            _values,
            overrides: _runtimeOverrides,
          ),
        )
        .toList();

    // 读取布局配置。
    final layout_models.ParkFormLayout? formLayout = widget.schema.layout;

    // 如果存在 section 配置，按 section 渲染；否则回退到 groupKey 分组。
    final List<Widget> formChildren = formLayout != null &&
            formLayout.sections.isNotEmpty
        ? _buildSectionBasedLayout(visibleFields, formLayout)
        : _buildGroupBasedLayout(visibleFields);

    return ParkForm(
      submitting: _submitting,
      submitLabel: widget.submitText,
      resetLabel: widget.resetText,
      showReset: widget.showReset,
      onSubmit: (_) => _handleSubmit(),
      onReset: _handleReset,
      children: formChildren,
    );
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
          title: groupName ?? groupKey ?? '未命名分组',
          children: fields.map((ParkFormFieldSchema f) => _buildField(f)).toList(),
        ),
      );
    }).toList();
  }

  /// 构建字段组件。
  ///
  /// [field] 字段结构。
  /// [formLayout] 表单布局配置（可选）。
  Widget _buildField(
    ParkFormFieldSchema field, [
    layout_models.ParkFormLayout? formLayout,
  ]) {
    final bool disabled = _engine.isFieldDisabled(
      field,
      _values,
      overrides: _runtimeOverrides,
    );
    final bool required = _engine.isFieldRequired(
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

    return Padding(
      padding: EdgeInsets.only(bottom: gutter),
      child: ParkFormFieldWidget(
        field: field,
        value: _values[field.fieldName],
        errorText: _errors[field.fieldName],
        disabled: disabled,
        required: required,
        dynamicOptions: _dynamicOptions[field.fieldName],
        labelLayout: effectiveLabelLayout,
        labelWidth: formLayout?.labelWidth,
        onChanged: (dynamic changed) {
          _handleFieldChanged(field.fieldName, changed);
        },
      ),
    );
  }

  /// 处理字段值变化。
  void _handleFieldChanged(String fieldName, dynamic changed) {
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

    // 如果有绑定服务，同步值变化
    if (widget.bindingService != null) {
      widget.bindingService!.setValue(fieldName, changed);
    }

    _refreshOptionsForFields(<String>{
      ...reactionResult.affectedFields,
      ...reactionResult.reloadFields,
    });
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
  }

  /// 刷新依赖 [changedFieldName] 的下游字段选项。
  ///
  /// 遍历所有字段，查找 [ParkFormFieldSchema.dataSourceParams] 中
  /// 引用了 `$form.[changedFieldName]` 的字段，对其调用
  /// [_engine.dataSourceResolver.resolve] 重新获取选项，
  /// 结果存入 [_dynamicOptions] 并触发重建。
  void _refreshDependentOptions(String changedFieldName) {
    final String formRef = '\$form.$changedFieldName';
    for (final ParkFormFieldSchema dep in widget.schema.fields) {
      // 跳过自身。
      if (dep.fieldName == changedFieldName) continue;
      // 仅处理有数据源且 dataSourceParams 引用了变化字段的字段。
      if (dep.dataSourceType == ParkDataSourceType.none ||
          dep.dataSourceType == ParkDataSourceType.staticOptions) {
        continue;
      }
      final bool depends = dep.dataSourceParams.values.any(
        (dynamic v) => v is String && v == formRef,
      );
      if (!depends) continue;

      _engine.dataSourceResolver.resolve(dep, currentValues: _values).then((
        List<Map<String, dynamic>> options,
      ) {
        if (!mounted) return;
        setState(() {
          _dynamicOptions[dep.fieldName] = options;
        });
      });
    }
  }

  /// 按字段集合刷新动态选项。
  void _refreshOptionsForFields(Set<String> fieldNames) {
    for (final String fieldName in fieldNames) {
      _refreshDependentOptions(fieldName);
    }

    for (final ParkFormFieldSchema field in widget.schema.fields) {
      if (!fieldNames.contains(field.fieldName)) {
        continue;
      }
      if (field.dataSourceType == ParkDataSourceType.none ||
          field.dataSourceType == ParkDataSourceType.staticOptions) {
        continue;
      }

      _engine.dataSourceResolver.resolve(field, currentValues: _values).then((
        List<Map<String, dynamic>> options,
      ) {
        if (!mounted) return;
        setState(() {
          _dynamicOptions[field.fieldName] = options;
        });
      });
    }
  }

  /// 提交表单。
  ///
  /// 先执行同步校验，再执行异步校验。
  /// 校验通过后自动定位首个错误字段或调用 [onSubmit]。
  Future<void> _handleSubmit() async {
    setState(() => _submitting = true);

    try {
      // 同步校验。
      final Map<String, String> syncErrors = _engine.validateForm(
        widget.schema,
        _values,
        overrides: _runtimeOverrides,
      );
      final Map<String, String> mergedErrors = <String, String>{...syncErrors};

      // 异步校验。
      if (widget.asyncValidator != null) {
        _engine.registerAsyncValidators(widget.asyncValidatorRegistry);
        final Map<String, String> asyncErrors = await _engine.validateFormAsync(
          widget.schema,
          _values,
          widget.asyncValidator!,
          overrides: _runtimeOverrides,
        );
        mergedErrors.addAll(asyncErrors);
      } else if (widget.asyncValidatorRegistry.isNotEmpty) {
        _engine.registerAsyncValidators(widget.asyncValidatorRegistry);
        final Map<String, String> asyncErrors = await _engine.validateFormAsync(
          widget.schema,
          _values,
          null,
          overrides: _runtimeOverrides,
        );
        mergedErrors.addAll(asyncErrors);
      }

      setState(() {
        _errors
          ..clear()
          ..addAll(mergedErrors);
      });

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

  /// 滚动到首个错误字段位置。
  ///
  /// [fieldKey] 首个错误字段的键名。
  void _scrollToFirstError(String fieldKey) {
    // 简易实现：通过 Scrollable.ensureVisible 需要 GlobalKey。
    // 当前版本暂不实现精确滚动，仅保留占位。
  }

  /// 重置表单。
  void _handleReset() {
    setState(() {
      _values = _engine.buildInitialValues(widget.schema);
      _runtimeOverrides = const ParkFormRuntimeOverrides();
      _errors.clear();
      _dynamicOptions.clear();
    });
    _applyInitialReactions();
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
