import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../park_ui.dart';

/// 单个动态字段渲染组件。
///
/// 根据 [ParkFormFieldSchema.type] 渲染对应的 Park UI 控件，
/// 所有控件通过 [value] 和 [onChanged] 实现受控模式。
/// 支持 [fieldControl] 子类型渲染不同控件变体。
class ParkFormFieldWidget extends StatelessWidget {
  /// 字段结构。
  final ParkFormFieldSchema field;

  /// 当前字段值。
  final dynamic value;

  /// 字段错误信息。
  final String? errorText;

  /// 字段值变化回调。
  final ValueChanged<dynamic> onChanged;

  /// 字段是否禁用。
  final bool disabled;

  /// 字段是否为运行时有效必填。
  final bool required;

  /// 动态选项（由联动刷新产生，优先级高于 [ParkFormFieldSchema.options]）。
  ///
  /// 当其他字段值变化导致本字段的 `dataSourceParams` 中的 `$form.xxx`
  /// 引用重新解析时，新的选项列表通过此参数注入。
  final List<Map<String, dynamic>>? dynamicOptions;

  /// 标签布局方式（inline 并排 / stacked 堆叠）。
  final ParkLabelLayout labelLayout;

  /// inline 模式下标签列宽度（px），为 null 时使用默认值 80。
  final double? labelWidth;

  /// 当前有效的选项列表。
  ///
  /// 优先使用 [dynamicOptions]，为空时退化到 [ParkFormFieldSchema.options]。
  List<Map<String, dynamic>> get _effectiveOptions =>
      dynamicOptions ?? field.options;

  /// 创建动态字段渲染组件。
  const ParkFormFieldWidget({
    super.key,
    required this.field,
    required this.value,
    required this.errorText,
    required this.onChanged,
    this.disabled = false,
    this.required = false,
    this.dynamicOptions,
    this.labelLayout = ParkLabelLayout.stacked,
    this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);
    switch (field.type) {
      case ParkFieldType.text:
      case ParkFieldType.number:
      case ParkFieldType.textarea:
      case ParkFieldType.richText:
        return _buildTextField();
      case ParkFieldType.select:
        return _buildSelect(context, l10n);
      case ParkFieldType.radio:
        return _buildRadio();
      case ParkFieldType.checkbox:
        return _buildCheckbox();
      case ParkFieldType.toggle:
        return _buildToggle();
      case ParkFieldType.date:
        return _buildDatePicker(context, l10n);
      case ParkFieldType.image:
        return _buildImagePicker(context, l10n);
      case ParkFieldType.scanner:
        return _buildScanner(context);
      case ParkFieldType.region:
        return _buildRegionSelector(context, l10n);
      case ParkFieldType.slider:
        return _buildSlider();
      case ParkFieldType.stepper:
        return _buildStepper();
      case ParkFieldType.rate:
        return _buildRate();
      case ParkFieldType.search:
        return _buildSearch(l10n);
      case ParkFieldType.cascader:
        return _buildCascader(l10n);
      case ParkFieldType.treeSelect:
        return _buildTreeSelect();
      case ParkFieldType.picker:
        return _buildPicker(context, l10n);
      case ParkFieldType.upload:
        return _buildUpload(l10n);
    }
  }

  /// 应用字段格式化配置。
  ///
  /// 若 [field.format] 不为 null，调用 [FormFormatterEngine.applyAll] 对值
  /// 进行格式化（千分位、百分比、中文大写、货币、后缀/前缀等），
  /// 否则返回原始值的字符串形式（B32）。
  String _formatValue(dynamic rawValue) {
    if (field.format == null) return rawValue?.toString() ?? '';
    return const FormFormatterEngine().applyAll(field.format!, rawValue);
  }

  // --------------------------------------------------------------------------
  // 标签与错误
  // --------------------------------------------------------------------------

  /// 将字段包裹在统一表单项容器中。
  ///
  /// 根据 [labelLayout] 决定标签与控件的排列方式：
  /// - stacked（默认）：标签在上，控件在下。
  /// - inline：标签和控件并排同行。
  Widget _wrapWithFieldContainer(Widget child) {
    if (labelLayout == ParkLabelLayout.inline) {
      final double effectiveLabelWidth = labelWidth ?? 80.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: effectiveLabelWidth,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 8),
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      if (required)
                        const TextSpan(
                          text: '* ',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      TextSpan(text: field.labelName),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  child,
                  if (field.helpText != null && field.helpText!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        field.helpText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // stacked 模式：使用 ParkFormItem 标准布局。
    return ParkFormItem(
      label: field.labelName,
      required: required,
      helpText: field.helpText,
      errorText: errorText,
      child: child,
    );
  }

  // --------------------------------------------------------------------------
  // 文本类：text / number / textarea
  // --------------------------------------------------------------------------

  /// 构建输入框。
  ///
  /// 支持 text / number / textarea / richText 类型，
  /// 根据 fieldControl 渲染子变体：password / number / phone / email / url / search。
  /// 自动消费 [ParkFieldUiConfig] 中的 prefix/suffix/rows/height/showCount。
  Widget _buildTextField() {
    final bool isMultiLine =
        field.fieldType == ParkFieldType.textarea ||
        field.fieldType == ParkFieldType.richText;
    final int effectiveMaxLines = isMultiLine
        ? (field.uiConfig.rows > 1 ? field.uiConfig.rows : 4)
        : 1;
    final double? effectiveHeight = field.uiConfig.height > 0
        ? field.uiConfig.height
        : null;

    final int? effectiveMaxLength = field.uiConfig.showCount
        ? (field.maxLength ??
              (field.fieldLength > 0 ? field.fieldLength : null))
        : null;

    // 根据 fieldControl 决定键盘类型和密码遮掩。
    final String? fc = field.fieldControl;
    TextInputType effectiveKeyboardType;
    bool obscureText = false;
    Widget? suffixIcon;

    switch (fc) {
      case 'password':
        obscureText = true;
        effectiveKeyboardType = TextInputType.text;
        suffixIcon = const Icon(Icons.lock_outline_rounded, size: 20);
        break;
      case 'number':
        effectiveKeyboardType = TextInputType.number;
        break;
      case 'phone':
        effectiveKeyboardType = TextInputType.phone;
        break;
      case 'email':
        effectiveKeyboardType = TextInputType.emailAddress;
        break;
      case 'url':
        effectiveKeyboardType = TextInputType.url;
        break;
      case 'search':
        effectiveKeyboardType = TextInputType.text;
        suffixIcon = const Icon(Icons.search_rounded, size: 20);
        break;
      default:
        effectiveKeyboardType = field.fieldType == ParkFieldType.number
            ? TextInputType.number
            : TextInputType.text;
    }

    // 前缀图标。
    Widget? prefixIcon;
    if (field.uiConfig.prefix != null && field.uiConfig.prefix!.isNotEmpty) {
      prefixIcon = Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(
          field.uiConfig.prefix!,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    final String displayValue = _formatValue(value);
    Widget input = _TextFieldAdapter(
      value: displayValue,
      readOnly: field.isReadonly || disabled,
      enabled: !disabled,
      maxLines: effectiveMaxLines,
      maxLength: effectiveMaxLength,
      keyboardType: effectiveKeyboardType,
      obscureText: obscureText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: field.fieldPrompt.isNotEmpty ? field.fieldPrompt : null,
      label: labelLayout == ParkLabelLayout.stacked ? field.labelName : null,
      onChanged: onChanged,
    );

    if (effectiveHeight != null) {
      input = SizedBox(height: effectiveHeight, child: input);
    }

    return input;
  }

  // --------------------------------------------------------------------------
  // 下拉选择：select
  // --------------------------------------------------------------------------

  /// 构建 ParkSelect 下拉选择器。
  ///
  /// 根据 fieldControl 渲染子变体：
  /// - multi → 多选下拉（multiple=true）。
  /// - searchable → 可搜索下拉（searchable=true）。
  /// - grouped → 分组下拉（grouped=true）。
  /// - single（默认）→ 标准单选下拉。
  Widget _buildSelect(BuildContext context, ParkLocalizations l10n) {
    final String lk = field.optionLabelKey;
    final String vk = field.optionValueKey;
    final String? fc = field.fieldControl;
    final bool isMulti = fc == 'multi';
    final bool isSearchable = fc == 'searchable';
    final bool isGrouped = fc == 'grouped';

    if (isMulti) {
      // 多选模式：值为 List，选项展示为已选标签列表。
      final List<dynamic> currentSelected =
          (value as List<dynamic>? ?? <dynamic>[]).toList();
      final List<Map<String, dynamic>> opts = _effectiveOptions;

      final List<String> selectedLabels = <String>[];
      for (final Map<String, dynamic> item in opts) {
        final dynamic val = item[vk];
        if (currentSelected.contains(val)) {
          selectedLabels.add(item[lk]?.toString() ?? '');
        }
      }

      return _wrapWithFieldContainer(
        GestureDetector(
          onTap: (disabled || field.isReadonly)
              ? null
              : () => _showMultiSelectBottomSheet(
                  context, opts, lk, vk, currentSelected),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selectedLabels.isEmpty
                        ? (field.fieldPrompt.isNotEmpty
                            ? field.fieldPrompt
                            : l10n.selectField(field.labelName))
                        : selectedLabels.join('\u3001'),
                    style: TextStyle(
                      color: selectedLabels.isEmpty
                          ? Colors.grey.shade500
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),
          ),
        ),
      );
    }

    // 单选 / searchable / grouped 模式。
    final List<ParkSelectOption> items = _effectiveOptions
        .map(
          (Map<String, dynamic> item) => ParkSelectOption(
            label: item[lk]?.toString() ?? '',
            value: item[vk]?.toString() ?? '',
          ),
        )
        .toList();

    return ParkSelect(
      items: items,
      value: value?.toString(),
      hintText: field.fieldPrompt.isNotEmpty
          ? field.fieldPrompt
          : l10n.selectField(field.labelName),
      label: labelLayout == ParkLabelLayout.stacked ? field.labelName : null,
      enabled: !disabled,
      readOnly: field.isReadonly || disabled,
      searchable: isSearchable,
      grouped: isGrouped,
      onChanged: (String? v) => onChanged(v),
    );
  }

  /// 显示多选底部弹窗。
  ///
  /// 弹出带搜索过滤的多选 BottomSheet，选项通过 [CheckboxListTile] 展示，
  /// 底部提供确认/取消按钮。
  /// 已选项在列表中保持勾选状态，确认后通过 [onChanged] 回传。
  Future<void> _showMultiSelectBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> opts,
    String lk,
    String vk,
    List<dynamic> currentSelected,
  ) async {
    final List<dynamic>? result = await showModalBottomSheet<List<dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            Theme.of(context).extension<ParkThemeData>()?.radius.lg ?? 16,
          ),
          topRight: Radius.circular(
            Theme.of(context).extension<ParkThemeData>()?.radius.lg ?? 16,
          ),
        ),
      ),
      builder: (BuildContext ctx) {
        return _MultiSelectSheetContent(
          options: opts,
          labelKey: lk,
          valueKey: vk,
          initialSelected: currentSelected,
        );
      },
    );
    if (result != null) {
      onChanged(result);
    }
  }

  // --------------------------------------------------------------------------
  // 单选：radio
  // --------------------------------------------------------------------------

  /// 构建 ParkRadio 单选组。
  ///
  /// 根据 fieldControl 渲染子变体：
  /// - button_style → 按钮样式单选（SegmentedButton 风格）。
  /// - single / group（默认）→ 标准单选组。
  Widget _buildRadio() {
    final String lk = field.optionLabelKey;
    final String vk = field.optionValueKey;
    final String? fc = field.fieldControl;
    final List<Map<String, dynamic>> opts = _effectiveOptions;

    // button_style 变体：使用 SegmentedButton 风格。
    if (fc == 'button_style') {
      final String currentValue = value?.toString() ?? '';
      return _wrapWithFieldContainer(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opts.map((Map<String, dynamic> item) {
            final String label = item[lk]?.toString() ?? '';
            final String val = item[vk]?.toString() ?? '';
            final bool isSelected = currentValue == val;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (disabled || field.isReadonly)
                  ? null
                  : (bool selected) {
                      if (selected) onChanged(val);
                    },
            );
          }).toList(),
        ),
      );
    }

    // 默认：标准单选组。
    final List<ParkRadioOption> options = opts
        .map(
          (Map<String, dynamic> item) => ParkRadioOption(
            label: item[lk]?.toString() ?? '',
            value: item[vk]?.toString() ?? '',
          ),
        )
        .toList();

    return _wrapWithFieldContainer(
      ParkRadio(
        options: options,
        value: value?.toString(),
        layout: ParkRadioLayout.wrap,
        disabled: disabled || field.isReadonly,
        onChanged: (String? v) => onChanged(v),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 多选：checkbox
  // --------------------------------------------------------------------------

  /// 构建 ParkCheckboxGroup 多选组。
  ///
  /// 使用 [ParkFormFieldSchema.optionLabelKey] 和 [ParkFormFieldSchema.optionValueKey]
  /// 映射选项数据。
  Widget _buildCheckbox() {
    final List<dynamic> currentSelected =
        (value as List<dynamic>? ?? <dynamic>[]).toList();

    final String lk = field.optionLabelKey;
    final String vk = field.optionValueKey;
    final List<Map<String, dynamic>> opts = _effectiveOptions;

    final List<String> optionLabels = opts
        .map((Map<String, dynamic> item) => item[lk]?.toString() ?? '')
        .toList();
    final List<String> optionValues = opts
        .map((Map<String, dynamic> item) => item[vk]?.toString() ?? '')
        .toList();

    // ParkCheckboxGroup takes List<String> for options and value.
    // We map option labels as the checkbox labels, and use option values
    // as the selected list.
    final List<String> selectedLabels = <String>[];
    for (int i = 0; i < optionValues.length; i++) {
      if (currentSelected.contains(optionValues[i]) ||
          currentSelected.contains(opts[i][vk])) {
        selectedLabels.add(optionLabels[i]);
      }
    }

    final List<ParkCheckboxOption> checkboxOptions = optionLabels
        .map((String label) => ParkCheckboxOption(label: label, value: label))
        .toList();

    return _wrapWithFieldContainer(
      ParkCheckboxGroup(
        options: checkboxOptions,
        value: selectedLabels,
        layout: ParkCheckboxGroupLayout.vertical,
        disabled: disabled || field.isReadonly,
        onChanged: (List<String> newSelectedLabels, List<ParkCheckboxOption> selectedOptions) {
          // Convert selected labels back to option values.
          final List<dynamic> newValues = <dynamic>[];
          for (int i = 0; i < optionLabels.length; i++) {
            if (newSelectedLabels.contains(optionLabels[i])) {
              newValues.add(opts[i][vk]);
            }
          }
          onChanged(newValues);
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 开关：toggle
  // --------------------------------------------------------------------------

  /// 构建 ParkSwitch 开关。
  Widget _buildToggle() {
    return _wrapWithFieldContainer(
      _SwitchAdapter(
        value: (value as bool?) ?? false,
        disabled: disabled || field.isReadonly,
        onChanged: (bool v) => onChanged(v),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 日期选择：date
  // --------------------------------------------------------------------------

  /// 构建 ParkDatePicker 日期选择器。
  ///
  /// 根据 fieldControl 渲染子变体：
  /// - date（默认）→ 日期选择。
  /// - time → 时间选择。
  /// - datetime → 日期+时间选择。
  Widget _buildDatePicker(BuildContext context, ParkLocalizations l10n) {
    final DateTime? dateValue = value is DateTime ? value as DateTime : null;
    final String? fc = field.fieldControl;

    // time 变体：使用 TimePicker。
    if (fc == 'time') {
      final TimeOfDay timeValue = dateValue != null
          ? TimeOfDay.fromDateTime(dateValue)
          : TimeOfDay.now();
      return _wrapWithFieldContainer(
        GestureDetector(
          onTap: (disabled || field.isReadonly)
              ? null
              : () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: timeValue,
                  );
                  if (picked != null) {
                    onChanged(
                      DateTime(2000, 1, 1, picked.hour, picked.minute),
                    );
                  }
                },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${timeValue.hour.toString().padLeft(2, '0')}:${timeValue.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                const Icon(Icons.access_time_rounded, size: 20),
              ],
            ),
          ),
        ),
      );
    }

    // date / datetime 变体：使用 ParkDatePicker。
    return ParkDatePicker(
      value: dateValue,
      label: labelLayout == ParkLabelLayout.stacked ? field.labelName : null,
      hintText: field.fieldPrompt.isNotEmpty
          ? field.fieldPrompt
          : l10n.selectField(field.labelName),
      mode: fc == 'datetime'
          ? ParkDatePickerMode.dateTime
          : ParkDatePickerMode.date,
      onChanged: disabled ? null : (DateTime? dt) => onChanged(dt),
    );
  }

  // --------------------------------------------------------------------------
  // 滑杆：slider
  // --------------------------------------------------------------------------

  /// 构建 ParkSlider 滑杆。
  Widget _buildSlider() {
    final double currentValue = (value is num)
        ? (value as num).toDouble()
        : ((field.config['min'] as num?)?.toDouble() ?? 0);
    final double minVal = (field.config['min'] as num?)?.toDouble() ?? 0;
    final double maxVal = (field.config['max'] as num?)?.toDouble() ?? 100;
    final double stepVal = (field.config['step'] as num?)?.toDouble() ?? 1;
    final int? divisions = stepVal > 0
        ? ((maxVal - minVal) / stepVal).round()
        : null;

    return _wrapWithFieldContainer(
      _SliderAdapter(
        value: currentValue,
        min: minVal,
        max: maxVal,
        divisions: divisions,
        disabled: disabled || field.isReadonly,
        onChanged: (double v) => onChanged(v),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 步进器：stepper
  // --------------------------------------------------------------------------

  /// 构建 ParkStepper 步进器。
  Widget _buildStepper() {
    final int currentValue = (value is num) ? (value as num).toInt() : 0;
    final int minVal = (field.config['min'] as int?) ?? 0;
    final int maxVal = (field.config['max'] as int?) ?? 99;
    final int stepVal = (field.config['step'] as int?) ?? 1;

    return _wrapWithFieldContainer(
      _StepperAdapter(
        value: currentValue,
        min: minVal,
        max: maxVal,
        step: stepVal,
        disabled: disabled || field.isReadonly,
        onChanged: (int v) => onChanged(v),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 评分：rate
  // --------------------------------------------------------------------------

  /// 构建 ParkRate 评分。
  Widget _buildRate() {
    final double currentValue = (value is num) ? (value as num).toDouble() : 0;
    final int count = (field.config['count'] as int?) ?? 5;

    return _wrapWithFieldContainer(
      _RateAdapter(
        value: currentValue,
        count: count,
        disabled: disabled || field.isReadonly,
        onChanged: (double v) => onChanged(v),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 搜索：search
  // --------------------------------------------------------------------------

  /// 构建 ParkSearch 搜索框。
  Widget _buildSearch(ParkLocalizations l10n) {
    return _wrapWithFieldContainer(
      _SearchAdapter(
        value: value?.toString() ?? '',
        hintText: field.fieldPrompt.isNotEmpty ? field.fieldPrompt : l10n.searchText,
        onChanged: (String v) => onChanged(v),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 级联选择：cascader
  // --------------------------------------------------------------------------

  /// 构建 ParkCascader 级联选择器。
  ///
  /// 使用 [ParkFormFieldSchema.optionLabelKey]、[ParkFormFieldSchema.optionValueKey]
  /// 和 [ParkFormFieldSchema.optionChildrenKey] 映射选项数据。
  Widget _buildCascader(ParkLocalizations l10n) {
    final List<ParkCascaderOption> options = _buildCascaderOptions(
      _effectiveOptions,
    );
    final List<String>? currentPath = value is List
        ? (value as List).map((dynamic e) => e.toString()).toList()
        : null;

    return ParkCascader(
      options: options,
      value: currentPath,
      label: field.labelName,
      hintText: field.fieldPrompt.isNotEmpty
          ? field.fieldPrompt
          : l10n.selectField(field.labelName),
      onChanged: (List<String>? path) => onChanged(path),
    );
  }

  /// 递归构建 ParkCascaderOption 树。
  ///
  /// [options] 原始选项列表。
  List<ParkCascaderOption> _buildCascaderOptions(
    List<Map<String, dynamic>> options,
  ) {
    final String lk = field.optionLabelKey;
    final String vk = field.optionValueKey;
    final String ck = field.optionChildrenKey;
    return options
        .map(
          (Map<String, dynamic> item) => ParkCascaderOption(
            label: item[lk]?.toString() ?? '',
            value: item[vk]?.toString() ?? '',
            children: item[ck] is List
                ? _buildCascaderOptions(
                    (item[ck] as List)
                        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
                        .toList(),
                  )
                : null,
          ),
        )
        .toList();
  }

  // --------------------------------------------------------------------------
  // 树形选择：treeSelect
  // --------------------------------------------------------------------------

  /// 构建 ParkTreeSelect 树形选择器。
  Widget _buildTreeSelect() {
    final List<ParkTreeNode> nodes = _buildTreeNodes(_effectiveOptions);
    final Set<String> selectedKeys = value is Set
        ? (value as Set).map((dynamic e) => e.toString()).toSet()
        : (value is List
              ? (value as List).map((dynamic e) => e.toString()).toSet()
              : <String>{});

    return _wrapWithFieldContainer(
      ParkTreeSelect(
        nodes: nodes,
        selectedKeys: selectedKeys,
        onChanged: (Set<String> keys) => onChanged(keys),
      ),
    );
  }

  /// 递归构建 ParkTreeNode 树。
  ///
  /// [options] 原始选项列表。
  List<ParkTreeNode> _buildTreeNodes(List<Map<String, dynamic>> options) {
    final String lk = field.optionLabelKey;
    final String vk = field.optionValueKey;
    final String ck = field.optionChildrenKey;
    return options
        .map(
          (Map<String, dynamic> item) => ParkTreeNode(
            key: item[vk]?.toString() ?? item['key']?.toString() ?? '',
            label: item[lk]?.toString() ?? '',
            children: item[ck] is List
                ? _buildTreeNodes(
                    (item[ck] as List)
                        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
                        .toList(),
                  )
                : const <ParkTreeNode>[],
          ),
        )
        .toList();
  }

  // --------------------------------------------------------------------------
  // 选择器：picker
  // --------------------------------------------------------------------------

  /// 构建 ParkPicker 选择器。
  ///
  /// 使用 [ParkFormFieldSchema.optionLabelKey] 和 [ParkFormFieldSchema.optionValueKey]
  /// 映射选项数据。
  Widget _buildPicker(BuildContext context, ParkLocalizations l10n) {
    final String lk = field.optionLabelKey;
    final String vk = field.optionValueKey;
    final List<Map<String, dynamic>> opts = _effectiveOptions;
    final List<ParkPickerItem> items = opts
        .map(
          (Map<String, dynamic> item) => ParkPickerItem(
            label: item[lk]?.toString() ?? '',
            value: item[vk]?.toString() ?? '',
          ),
        )
        .toList();

    final String currentText = resolveOptionLabel(
      options: opts,
      selectedValue: value,
      fallback: field.fieldPrompt.isNotEmpty
          ? field.fieldPrompt
          : l10n.selectField(field.labelName),
      optionLabelKey: field.optionLabelKey,
      optionValueKey: field.optionValueKey,
    );

    return _wrapWithFieldContainer(
      GestureDetector(
        onTap: (field.isReadonly || disabled)
            ? null
            : () async {
                final String? selected = await ParkPicker.show(
                  context,
                  title: l10n.selectField(field.labelName),
                  items: items,
                  value: value?.toString(),
                );
                if (selected != null) {
                  onChanged(selected);
                }
              },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(currentText)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 上传：upload
  // --------------------------------------------------------------------------

  /// 构建 ParkUpload 上传组件。
  ///
  /// 根据 fieldControl 渲染子变体：
  /// - image（默认）→ 图片上传（含裁剪）。
  /// - file → 通用文件上传。
  /// - avatar → 头像上传（圆形预览）。
  Widget _buildUpload(ParkLocalizations l10n) {
    final String? fc = field.fieldControl;
    final List<ParkUploadFile> files = <ParkUploadFile>[];
    if (value is String && (value as String).isNotEmpty) {
      files.add(ParkUploadFile(path: value as String));
    } else if (value is List) {
      for (final dynamic item in value as List) {
        if (item is String && item.isNotEmpty) {
          files.add(ParkUploadFile(path: item));
        }
      }
    }
    final service = ParkFormImageService.instance();

    // file 变体：简化文件上传 UI。
    if (fc == 'file') {
      return _wrapWithFieldContainer(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.selectedFilesCount(files.length),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: disabled
                  ? null
                  : () async {
                      final result = await service.pickFromGallery();
                      if (result?.path != null) {
                        onChanged(result!.path);
                      }
                    },
              child: Text(l10n.chooseFile),
            ),
          ],
        ),
      );
    }

    // 默认 image / avatar 变体使用 ParkUpload。
    return _wrapWithFieldContainer(
      ParkUpload(
        files: files,
        maxCount: (field.config['maxCount'] as int?) ?? 9,
        onAdd: disabled
            ? null
            : () async {
                final result = await service.pickFromGallery();
                if (result?.path != null) {
                  onChanged(result!.path);
                }
              },
        onRemove: disabled
            ? null
            : (ParkUploadFile file) {
                // B33：仅移除当前文件，回传剔除该项后的剩余路径列表，
                // 不再 onChanged(null) 清空全部（参见 开发文档.md §7.10）。
                final List<String> remaining = files
                    .where((ParkUploadFile f) => f.path != file.path)
                    .map((ParkUploadFile f) => f.path)
                    .toList();
                onChanged(remaining);
              },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 图片选择：image
  // --------------------------------------------------------------------------

  /// 构建图片选择器。
  ///
  /// 通过 [ParkFormImageService] 抽象平台差异，
  /// 原生平台使用 image_picker / image_cropper，
  /// Web 端展示"暂不支持"占位。
  Widget _buildImagePicker(BuildContext context, ParkLocalizations l10n) {
    final List<String> allowSources =
        (field.config['allowSources'] as List<dynamic>? ??
                const <dynamic>['gallery', 'camera'])
            .map((dynamic item) => item.toString())
            .toList();
    final bool allowCrop = (field.config['allowCrop'] as bool?) ?? true;
    final double previewHeight =
        (field.config['previewHeight'] as num?)?.toDouble() ?? 120;

    final String? imagePath = value is String ? value as String : null;
    final bool hasImage = imagePath != null && imagePath.isNotEmpty;
    final service = ParkFormImageService.instance();

    Widget preview = Container(
      height: previewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Center(child: Text(l10n.noImages)),
    );

    if (hasImage) {
      if (imagePath.startsWith('http')) {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ParkFormImageService.buildNetworkImage(
            imagePath,
            height: previewHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // 通过平台服务加载本地图片字节，避免直接使用 dart:io File。
        preview = FutureBuilder<List<int>?>(
          future: service.loadImageBytes(imagePath),
          builder: (BuildContext context, AsyncSnapshot<List<int>?> snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final bytes = snap.data;
            if (bytes == null || bytes.isEmpty) {
              return const Center(child: Icon(Icons.broken_image_outlined));
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                Uint8List.fromList(bytes),
                height: previewHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }
    }

    return _wrapWithFieldContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          preview,
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (allowSources.contains('gallery'))
                ParkButton(
                  variant: ParkButtonVariant.secondary,
                  onPressed: disabled
                      ? null
                      : () async {
                          final result = await service.pickFromGallery();
                          if (result?.path != null) {
                            onChanged(result!.path);
                          }
                        },
                  child: Text(l10n.selectFromAlbum),
                ),
              if (allowSources.contains('camera'))
                ParkButton(
                  variant: ParkButtonVariant.secondary,
                  onPressed: disabled
                      ? null
                      : () async {
                          final result = await service.pickFromCamera();
                          if (result?.path != null) {
                            onChanged(result!.path);
                          }
                        },
                  child: Text(l10n.takePhoto),
                ),
              if (allowCrop)
                ParkButton(
                  variant: ParkButtonVariant.secondary,
                  onPressed: (!disabled && hasImage)
                      ? () async {
                          final result =
                              await service.cropImage(imagePath);
                          if (result?.path != null) {
                            onChanged(result!.path);
                          }
                        }
                      : null,
                  child: Text(l10n.cropImageTitle),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 扫码输入：scanner
  // --------------------------------------------------------------------------

  /// 构建扫码输入控件。
  ///
  /// 通过 [ParkFormImageService] 抽象平台差异，
  /// 原生平台使用 mobile_scanner 相机扫码，
  /// Web 端展示"暂不支持"占位。
  Widget _buildScanner(BuildContext context) {
    final String simulatedValue =
        (field.config['simulatedValue'] as String?) ??
        'SIMULATED_SCAN_CODE_001';
    final service = ParkFormImageService.instance();

    return _wrapWithFieldContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          service.buildScannerWidget(
            currentValue: value?.toString(),
            onScan: (String raw) => onChanged(raw),
            simulatedValue: simulatedValue,
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 地区选择：region
  // --------------------------------------------------------------------------

  /// 构建地区选择器。
  Widget _buildRegionSelector(BuildContext context, ParkLocalizations l10n) {
    final List<Map<String, dynamic>> regionOpts = _effectiveOptions;
    final bool hasNestedChildren = regionOpts.any(
      (Map<String, dynamic> item) => item['children'] is List,
    );

    if (!hasNestedChildren) {
      final String currentText = resolveOptionLabel(
        options: regionOpts,
        selectedValue: value,
        fallback: field.fieldPrompt.isNotEmpty
            ? field.fieldPrompt
            : l10n.selectField(field.labelName),
        optionLabelKey: field.optionLabelKey,
        optionValueKey: field.optionValueKey,
      );
      return GestureDetector(
        onTap: (field.isReadonly || disabled)
            ? null
            : () async {
                final dynamic selected = await showOptionBottomSheet(
                  context,
                  title: l10n.selectField(field.labelName),
                  options: regionOpts,
                  selectedValue: value,
                  optionLabelKey: field.optionLabelKey,
                  optionValueKey: field.optionValueKey,
                );
                if (selected != null) {
                  onChanged(selected);
                }
              },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 42),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  currentText,
                  style: TextStyle(
                    color: value != null
                        ? Theme.of(context).textTheme.bodyMedium?.color
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),
      );
    }

    final int level = (field.config['level'] as int?) ?? 3;
    final String provinceKey =
        (field.config['provinceKey'] as String?) ?? 'province';
    final String cityKey = (field.config['cityKey'] as String?) ?? 'city';
    final String districtKey =
        (field.config['districtKey'] as String?) ?? 'district';

    final Map<String, dynamic> currentValue = value is Map<String, dynamic>
        ? value as Map<String, dynamic>
        : <String, dynamic>{};

    final dynamic selectedProvince = currentValue[provinceKey];
    final dynamic selectedCity = currentValue[cityKey];
    final dynamic selectedDistrict = currentValue[districtKey];

    final List<Map<String, dynamic>> provinceOptions = regionOpts;
    final List<Map<String, dynamic>> cityOptions = childrenOf(
      provinceOptions,
      selectedProvince,
      optionValueKey: field.optionValueKey,
      optionChildrenKey: field.optionChildrenKey,
    );
    final List<Map<String, dynamic>> districtOptions = childrenOf(
      cityOptions,
      selectedCity,
      optionValueKey: field.optionValueKey,
      optionChildrenKey: field.optionChildrenKey,
    );

    final Map<String, dynamic> displayValue = value is Map<String, dynamic>
        ? value as Map<String, dynamic>
        : <String, dynamic>{};
    final String provinceLabel = resolveOptionLabel(
      options: provinceOptions,
      selectedValue: displayValue[provinceKey],
      fallback: l10n.selectProvince,
      optionLabelKey: field.optionLabelKey,
      optionValueKey: field.optionValueKey,
    );
    final String cityLabel = resolveOptionLabel(
      options: cityOptions,
      selectedValue: displayValue[cityKey],
      fallback: l10n.selectCity,
      optionLabelKey: field.optionLabelKey,
      optionValueKey: field.optionValueKey,
    );
    final String districtLabel = resolveOptionLabel(
      options: districtOptions,
      selectedValue: displayValue[districtKey],
      fallback: l10n.selectDistrict,
      optionLabelKey: field.optionLabelKey,
      optionValueKey: field.optionValueKey,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: (field.isReadonly || disabled)
              ? null
              : () async {
                  final Map<String, dynamic>? selected =
                      await showRegionBottomSheet(
                        context: context,
                        provinceOptions: provinceOptions,
                        selectedProvince: selectedProvince,
                        selectedCity: selectedCity,
                        selectedDistrict: selectedDistrict,
                        level: level,
                        provinceKey: provinceKey,
                        cityKey: cityKey,
                        districtKey: districtKey,
                        labelName: field.labelName,
                        optionLabelKey: field.optionLabelKey,
                        optionValueKey: field.optionValueKey,
                        optionChildrenKey: field.optionChildrenKey,
                      );
                  if (selected != null) {
                    onChanged(selected);
                  }
                },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text('$provinceLabel / $cityLabel / $districtLabel'),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ],
            ),
          ),
        ),
        if (level < 3 && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// 多选 BottomSheet 内容组件（B10）
// =============================================================================

/// 多选底部弹窗内容。
///
/// 包含搜索框 + 选项列表（CheckboxListTile）+ 底部确认/取消按钮。
/// 支持搜索过滤，已选项在列表中保持勾选状态。
class _MultiSelectSheetContent extends StatefulWidget {
  /// 完整选项列表。
  final List<Map<String, dynamic>> options;

  /// 选项标签键名。
  final String labelKey;

  /// 选项值键名。
  final String valueKey;

  /// 初始已选值列表。
  final List<dynamic> initialSelected;

  const _MultiSelectSheetContent({
    required this.options,
    required this.labelKey,
    required this.valueKey,
    required this.initialSelected,
  });

  @override
  State<_MultiSelectSheetContent> createState() =>
      _MultiSelectSheetContentState();
}

class _MultiSelectSheetContentState
    extends State<_MultiSelectSheetContent> {
  /// 搜索文本控制器。
  final TextEditingController _searchController = TextEditingController();

  /// 当前选中值集合（用于勾选状态跟踪）。
  late Set<dynamic> _selectedValues;

  /// 搜索过滤文本。
  String _searchQuery = '';

  /// 经过搜索过滤后的选项列表。
  List<Map<String, dynamic>> get _filteredOptions {
    if (_searchQuery.isEmpty) return widget.options;
    final String query = _searchQuery.toLowerCase();
    return widget.options.where((Map<String, dynamic> opt) {
      final String label = opt[widget.labelKey]?.toString().toLowerCase() ?? '';
      final String value = opt[widget.valueKey]?.toString().toLowerCase() ?? '';
      return label.contains(query) || value.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialSelected.toSet();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 切换勾选状态。
  void _toggleSelection(dynamic value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>();
    final l10n = ParkLocalizations.of(context);
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Semantics(
        label: l10n.selectPlaceholder,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 拖拽指示条
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: park?.colors.border ?? Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 搜索框
              Padding(
                padding: EdgeInsets.fromLTRB(
                  park?.spacing.md ?? 16,
                  park?.spacing.sm ?? 8,
                  park?.spacing.md ?? 16,
                  park?.spacing.xs ?? 4,
                ),
                child: ParkInput(
                  controller: _searchController,
                  hintText: l10n.searchText,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                ),
              ),
              // 选项列表（最大高度限制）
              Flexible(
                child: _filteredOptions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: park?.spacing.lg ?? 32,
                        ),
                        child: Text(
                          l10n.noData,
                          style: TextStyle(
                            color: park?.colors.textSecondary ??
                                Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(
                          horizontal: park?.spacing.sm ?? 8,
                        ),
                        itemCount: _filteredOptions.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          final Map<String, dynamic> item =
                              _filteredOptions[index];
                          final String label =
                              item[widget.labelKey]?.toString() ?? '';
                          final dynamic val = item[widget.valueKey];
                          final bool isChecked =
                              _selectedValues.contains(val);
                          return Semantics(
                            label: label,
                            checked: isChecked,
                            child: CheckboxListTile(
                              title: Text(label),
                              value: isChecked,
                              onChanged: (_) => _toggleSelection(val),
                              dense: true,
                              controlAffinity:
                                  ListTileControlAffinity.trailing,
                              activeColor:
                                  park?.colors.brand,
                            ),
                          );
                        },
                      ),
              ),
              // 底部操作按钮
              Padding(
                padding: EdgeInsets.fromLTRB(
                  park?.spacing.md ?? 16,
                  park?.spacing.sm ?? 8,
                  park?.spacing.md ?? 16,
                  park?.spacing.md ?? 16,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ParkButton(
                        variant: ParkButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.cancelText),
                      ),
                    ),
                    SizedBox(width: park?.spacing.sm ?? 12),
                    Expanded(
                      child: ParkButton(
                        variant: ParkButtonVariant.primary,
                        onPressed: () =>
                            Navigator.of(context).pop(_selectedValues.toList()),
                        child: Text(l10n.confirmText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 受控适配器组件
//
// Park UI 的 FormField 组件管理自己的内部状态。在动态表单场景中，
// 父组件通过 value + onChanged 进行受控管理。以下适配器在外部 value
// 变化时同步内部 FormField 状态，确保表单重置等场景正常工作。
// =============================================================================

/// ParkSwitch 受控适配器。
class _SwitchAdapter extends StatefulWidget {
  final bool value;
  final bool disabled;
  final ValueChanged<bool> onChanged;

  const _SwitchAdapter({
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  @override
  State<_SwitchAdapter> createState() => _SwitchAdapterState();
}

class _SwitchAdapterState extends State<_SwitchAdapter> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _SwitchAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkSwitch(
          value: _value,
          disabled: widget.disabled,
          onChanged: (v) {
            setState(() => _value = v as bool);
            widget.onChanged(v as bool);
          },
        ),
      ],
    );
  }
}

/// ParkSlider 受控适配器。
class _SliderAdapter extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final bool disabled;
  final ValueChanged<double> onChanged;

  const _SliderAdapter({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.disabled,
    required this.onChanged,
  });

  @override
  State<_SliderAdapter> createState() => _SliderAdapterState();
}

class _SliderAdapterState extends State<_SliderAdapter> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _SliderAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disabled) {
      return Opacity(
        opacity: 0.5,
        child: ParkSlider(
          value: _value,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          showValue: true,
        ),
      );
    }
    return ParkSlider(
      value: _value,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      showValue: true,
      onChanged: (double v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}

/// ParkStepper 受控适配器。
class _StepperAdapter extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final bool disabled;
  final ValueChanged<int> onChanged;

  const _StepperAdapter({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.disabled,
    required this.onChanged,
  });

  @override
  State<_StepperAdapter> createState() => _StepperAdapterState();
}

class _StepperAdapterState extends State<_StepperAdapter> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _StepperAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParkStepper(
      value: _value,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      disabled: widget.disabled,
      onChanged: (int v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}

/// ParkRate 受控适配器。
class _RateAdapter extends StatefulWidget {
  final double value;
  final int count;
  final bool disabled;
  final ValueChanged<double> onChanged;

  const _RateAdapter({
    required this.value,
    required this.count,
    required this.disabled,
    required this.onChanged,
  });

  @override
  State<_RateAdapter> createState() => _RateAdapterState();
}

class _RateAdapterState extends State<_RateAdapter> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(covariant _RateAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParkRate(
      value: _value,
      count: widget.count,
      readOnly: widget.disabled,
      onChanged: (double v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}

/// ParkSearch 受控适配器。
class _SearchAdapter extends StatefulWidget {
  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchAdapter({
    required this.value,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<_SearchAdapter> createState() => _SearchAdapterState();
}

class _SearchAdapterState extends State<_SearchAdapter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _SearchAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParkSearch(
      controller: _controller,
      hintText: widget.hintText,
      onChanged: (String v) => widget.onChanged(v),
    );
  }
}

/// 文本类字段受控适配器（B17 / 开发文档.md §7.10）。
///
/// 文本 / 数字 / 多行 / 富文本字段此前依赖 [ParkInput] 的 `initialValue`，
/// 而 [FormField] 的 initialValue 在初始化后不再随父级 value 变化刷新，
/// 导致表单重置或外部改值后文本框内容失效（日期 / select / radio 走 value 可更新，
/// 唯独文本类失效）。
///
/// 本适配器自持 [TextEditingController]，并在 [didUpdateWidget] 中监听外部 value
/// 变化同步到控制器，确保受控刷新。
class _TextFieldAdapter extends StatefulWidget {
  final String value;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? label;
  final ValueChanged<dynamic> onChanged;

  const _TextFieldAdapter({
    required this.value,
    required this.readOnly,
    required this.enabled,
    required this.maxLines,
    required this.maxLength,
    required this.keyboardType,
    required this.obscureText,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.hintText,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_TextFieldAdapter> createState() => _TextFieldAdapterState();
}

class _TextFieldAdapterState extends State<_TextFieldAdapter> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextFieldAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部 value 变化（如表单重置）时同步文本框内容（B17）。
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParkInput(
      controller: _controller,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      hintText: widget.hintText,
      label: widget.label,
      onChanged: (String v) => widget.onChanged(v),
    );
  }
}
