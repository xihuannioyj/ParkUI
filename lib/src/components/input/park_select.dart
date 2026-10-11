import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';

/// 下拉选项数据
class ParkSelectOption {
  /// 显示文字
  final String label;

  /// 选项值
  final String value;

  /// 是否禁用
  final bool disabled;

  /// 所属分组名称。
  final String? group;

  const ParkSelectOption({
    required this.label,
    required this.value,
    this.disabled = false,
    this.group,
  });
}

/// 分组选项数据 / Grouped option data
///
/// 用于将 [ParkSelectOption] 按逻辑分组展示，每组带有独立标题。
/// Used to display [ParkSelectOption] items in logical groups with headers.
///
/// ```dart
/// ParkSelect(
///   groupedOptions: [
///     ParkSelectGroupOption(
///       groupLabel: '一线城市',
///       options: [
///         ParkSelectOption(label: '北京', value: 'bj'),
///         ParkSelectOption(label: '上海', value: 'sh'),
///       ],
///     ),
///     ParkSelectGroupOption(
///       groupLabel: '其他',
///       options: [
///         ParkSelectOption(label: '成都', value: 'cd'),
///       ],
///     ),
///   ],
/// )
/// ```
class ParkSelectGroupOption {
  /// 分组标题 / Group label
  final String groupLabel;

  /// 该分组下的选项列表 / Options within this group
  final List<ParkSelectOption> options;

  const ParkSelectGroupOption({
    required this.groupLabel,
    required this.options,
  });
}

/// 选择器状态枚举
enum ParkSelectStatus { error, warning, success }

/// 选择器尺寸枚举
enum ParkSelectSize { small, medium, large }

/// Park 下拉选择器
///
/// 继承 [FormField]，支持单选 / 多选模式。
/// 点击输入框弹出底部面板展示选项列表，多选模式显示 Chips。
///
/// ```dart
/// ParkSelect(
///   label: '城市',
///   items: [
///     ParkSelectOption(label: '北京', value: 'beijing'),
///     ParkSelectOption(label: '上海', value: 'shanghai'),
///   ],
///   value: 'beijing',
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkSelect extends FormField<String> implements ParkBindableWidget {
  /// 选项列表
  final List<ParkSelectOption> items;

  /// 当前选中值（单选为单个 value，多选为逗号分隔的 values）
  final String? value;

  /// 选中值变更回调
  final ValueChanged<String?>? onChanged;

  /// 输入框占位文字
  final String? hintText;

  /// 输入框标签
  final String? label;

  /// 是否多选模式
  final bool multiple;

  /// 是否可清除
  final bool clearable;

  /// 是否只读。
  final bool readOnly;

  /// 是否处于加载中。
  final bool loading;

  /// 加载文案。
  final String? loadingText;

  /// 空态文案。
  final String? emptyText;

  /// 是否启用搜索。
  final bool searchable;

  /// 搜索输入变化回调。
  final ValueChanged<String>? onSearchChanged;

  /// 远程搜索中状态。
  final bool searching;

  /// 搜索错误文案。
  final String? searchErrorText;

  /// 是否按 group 渲染分组标题。
  final bool grouped;

  /// 多选模式下可见 chip 的最大数量，超出显示 +N。
  final int? maxTagCount;

  /// 选择器状态（error / warning），影响边框颜色。
  final ParkSelectStatus? status;

  /// 选择器尺寸。
  final ParkSelectSize size;

  /// 是否显示边框。
  final bool bordered;

  /// 无匹配选项时的自定义空态 widget。
  final Widget? notFoundContent;

  /// 是否允许用户创建新选项（tag 模式，需 searchable 为 true）。
  final bool allowCreate;

  /// 自定义后缀图标（替换默认箭头）。
  final Widget? suffixIcon;

  /// 多选模式下最大可选数量。为 null 时不限制。
  final int? maxSelection;

  /// 是否显示下拉箭头图标。默认 true。
  final bool showArrow;

  /// 清除按钮点击时的额外回调。
  final VoidCallback? onClear;

  /// 前置图标（显示在输入框内容之前）。
  final IconData? prefixIcon;

  /// 是否启用选项过滤。为 true 时使用内置过滤，为 Function 时自定义过滤逻辑。
  final Object? filterOption;

  /// 自定义选项渲染回调（每个选项的自定义 widget）
  final Widget Function(ParkSelectOption option, bool isSelected)? optionRender;

  /// 是否启用虚拟滚动（大量选项时的性能优化）
  final bool virtual;

  /// 虚拟化渲染模式 / Virtualization mode
  ///
  /// 为 `true` 时强制启用虚拟化渲染（使用 [ListView.builder]）；
  /// 为 `false` 时强制禁用；为 `null`（默认）时自动判断——
  /// 当选项数量超过 50 个时自动启用虚拟化渲染。
  ///
  /// When `true`, force virtualized rendering via [ListView.builder];
  /// when `false`, force disabled; when `null` (default), auto-detect —
  /// virtualization is enabled automatically when items exceed 50.
  final bool? virtualize;

  /// 分组选项列表 / Grouped options
  ///
  /// 设置后按分组渲染选项，每组显示分组标题。
  /// 与 [items] 二选一使用，[groupedOptions] 优先级更高。
  ///
  /// When set, options are rendered in groups with headers.
  /// Mutually exclusive with [items]; [groupedOptions] takes precedence.
  final List<ParkSelectGroupOption>? groupedOptions;

  /// 下拉面板宽度是否与选择器宽度一致。默认 true。
  final bool popupMatchSelectWidth;

  /// 搜索回调（与 onSearchChanged 等价，兼容 AntD 命名）
  final ValueChanged<String>? onSearch;

  /// 下拉面板自定义渲染（包裹在选项列表外部）
  final Widget Function(Widget menu)? dropdownRender;

  /// 远程搜索回调：输入关键字 -> 异步返回选项列表。
  ///
  /// 类似 Ant Design 的 Select + search + remote data 模式。
  /// 当用户提供此回调时，搜索框输入关键字后将：
  /// 1. 等待 [searchDebounce] 防抖时间
  /// 2. 调用此回调获取远程选项
  /// 3. 用返回的选项替换当前列表
  final Future<List<ParkSelectOption>> Function(String keyword)? onSearchAsync;

  /// 远程搜索防抖时间（默认 300ms）。
  final Duration searchDebounce;

  /// 远程搜索中的加载文案（为 null 时使用本地化默认文案）。
  final String? searchLoadingText;

  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkSelect({
    super.key,
    required this.items,
    this.bindKey,
    this.bindingService,
    this.value,
    this.onChanged,
    this.hintText,
    this.label,
    this.multiple = false,
    this.clearable = false,
    super.enabled = true,
    this.readOnly = false,
    this.loading = false,
    this.loadingText,
    this.emptyText,
    this.searchable = false,
    this.onSearchChanged,
    this.searching = false,
    this.searchErrorText,
    this.grouped = true,
    this.maxTagCount,
    this.status,
    this.size = ParkSelectSize.medium,
    this.bordered = true,
    this.notFoundContent,
    this.allowCreate = false,
    this.suffixIcon,
    this.maxSelection,
    this.showArrow = true,
    this.onClear,
    this.prefixIcon,
    this.filterOption,
    this.optionRender,
    this.virtual = false,
    this.virtualize,
    this.groupedOptions,
    this.popupMatchSelectWidth = true,
    this.onSearch,
    this.dropdownRender,
    this.onSearchAsync,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.searchLoadingText,
    super.onSaved,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: value,
         builder: (FormFieldState<String> field) {
           final state = field as _ParkSelectState;
           final park =
               Theme.of(field.context).extension<ParkThemeData>() ??
               ParkThemeData.light();

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               if (state.widget.label != null)
                 Padding(
                   padding: EdgeInsets.only(bottom: park.spacing.xs),
                   child: Text(
                     state.widget.label!,
                     style: TextStyle(
                       fontSize: park.typography.sizeBodySmall,
                       color: park.colors.textSecondary,
                       fontWeight: park.typography.weightMedium,
                     ),
                   ),
                 ),
               _buildTrigger(state, park),
               if (field.hasError)
                 Padding(
                   padding: EdgeInsets.only(top: park.spacing.xs),
                   child: Text(
                     field.errorText!,
                     style: TextStyle(
                       color: park.colors.error,
                       fontSize: park.typography.sizeCaption,
                     ),
                   ),
                 ),
             ],
           );
         },
       );

  /// 最小高度：对齐 ParkSizing 输入框令牌（32/48/56），
  /// 原硬编码 42/52 与 ParkInput 三档不一致。
  static double _minHeight(ParkSelectSize size, ParkThemeData park) {
    switch (size) {
      case ParkSelectSize.small:
        return park.sizing.inputHeightSm;
      case ParkSelectSize.medium:
        return park.sizing.inputHeightMd;
      case ParkSelectSize.large:
        return park.sizing.inputHeightLg;
    }
  }

  /// 从 items 或 groupedOptions 中查找指定 value 的选项。
  /// Find an option by value from either items or groupedOptions.
  static ParkSelectOption? _findOption(
    ParkSelect widget,
    String value,
  ) {
    // 先在 items 中查找 / Search in items first
    final opt = widget.items.where((o) => o.value == value).firstOrNull;
    if (opt != null) return opt;
    // 再在 groupedOptions 中查找 / Then search in groupedOptions
    if (widget.groupedOptions != null) {
      for (final group in widget.groupedOptions!) {
        final match = group.options.where((o) => o.value == value).firstOrNull;
        if (match != null) return match;
      }
    }
    return null;
  }

  static double _fontSize(ParkSelectSize size, ParkThemeData park) {
    switch (size) {
      case ParkSelectSize.small:
        return park.typography.sizeBodySmall;
      case ParkSelectSize.medium:
        return park.typography.sizeBody;
      case ParkSelectSize.large:
        return park.typography.sizeH3;
    }
  }

  static Color _borderColor(
    ParkSelectStatus? status,
    bool hasError,
    ParkThemeData park,
  ) {
    if (hasError || status == ParkSelectStatus.error) return park.colors.error;
    if (status == ParkSelectStatus.warning) return park.colors.warning;
    if (status == ParkSelectStatus.success) return park.colors.success;
    return park.colors.border;
  }

  static Widget _buildTrigger(_ParkSelectState state, ParkThemeData park) {
    final widget = state.widget;
    final colors = park.colors;
    final radius = park.radius;
    final spacing = park.spacing;

    final currentValue = state.value;
    final selectedValues = _parseValues(currentValue);
    final hasValue = selectedValues.isNotEmpty;
    final isDisabled = !widget.enabled || widget.readOnly || widget.loading;

    // 解析显示文字
    String displayText;
    if (!hasValue) {
      displayText = '';
    } else if (widget.multiple) {
      final labels = <String>[];
      for (final v in selectedValues) {
        final opt = _findOption(widget, v);
        if (opt != null) labels.add(opt.label);
      }
      displayText = labels.join(', ');
    } else {
      final opt = _findOption(widget, currentValue ?? '');
      displayText = opt?.label ?? currentValue ?? '';
    }

    // maxTagCount: determine visible chips and overflow count
    // Show maxTagCount-1 visible chips, then +remainCount overflow chip
    final int? maxTag = widget.maxTagCount;
    final List<String> visibleChipValues;
    final int overflowCount;
    if (widget.multiple &&
        hasValue &&
        maxTag != null &&
        maxTag > 0 &&
        selectedValues.length > maxTag) {
      // Overflow mode: show (maxTag-1) visible chips, then +N
      final int showCount = maxTag - 1;
      visibleChipValues = selectedValues.take(showCount).toList();
      overflowCount = selectedValues.length - showCount;
    } else {
      visibleChipValues = widget.multiple && hasValue
          ? selectedValues
          : <String>[];
      overflowCount = 0;
    }

    final borderColor = _borderColor(widget.status, state.hasError, park);
    final minH = _minHeight(widget.size, park);
    final fontSize = _fontSize(widget.size, park);

    return Semantics(
      button: true,
      enabled: !isDisabled,
      child: GestureDetector(
      onTap: isDisabled ? null : () => _showSheet(state),
      child: AnimatedContainer(
        duration: park.motion.standard,
        curve: park.motion.defaultEasing,
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minH),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDisabled ? colors.disabledBg : colors.surface,
          borderRadius: BorderRadius.circular(radius.md),
          border: widget.bordered
              ? Border.all(color: borderColor, width: 1.0)
              : null,
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(
                widget.prefixIcon!,
                size: 20,
                color: colors.textSecondary,
              ),
              SizedBox(width: spacing.xs),
            ],
            Expanded(
              child: widget.multiple && hasValue
                  ? Wrap(
                      spacing: spacing.xs,
                      runSpacing: spacing.xs,
                      children: [
                        ...visibleChipValues.map((v) {
                          final opt = _findOption(widget, v);
                          return _buildChip(
                            opt?.label ?? v,
                            park,
                            onRemove: () {
                              final newValues =
                                  List<String>.from(selectedValues)..remove(v);
                              final newVal = newValues.isEmpty
                                  ? null
                                  : newValues.join(',');
                              state.didChange(newVal);
                              widget.onChanged?.call(newVal);
                            },
                          );
                        }),
                        if (overflowCount > 0)
                          _buildChip(
                            '+$overflowCount',
                            park,
                            onTap: () => _showOverflowSheet(state),
                          ),
                      ],
                    )
                  : Text(
                      widget.loading
                          ? (widget.loadingText ?? ParkLocalizations.of(state.context).loadingOptionsText)
                          : hasValue
                          ? displayText
                          : (widget.hintText ?? ParkLocalizations.of(state.context).selectPlaceholder),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: isDisabled
                            ? colors.textDisabled
                            : hasValue
                            ? colors.textPrimary
                            : colors.textPlaceholder,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            SizedBox(width: spacing.xs),
            // 清除按钮
            if (widget.clearable && hasValue && !isDisabled)
              Semantics(
                label: ParkLocalizations.of(state.context).clearText,
                button: true,
                child: GestureDetector(
                onTap: () {
                  state.didChange(null);
                  widget.onChanged?.call(null);
                  widget.onClear?.call();
                },
                child: Icon(
                  Icons.cancel_outlined,
                  size: 18,
                  color: colors.textPlaceholder,
                ),
              ),
              ),
            // 后缀图标 / 下拉箭头
            if (widget.loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(colors.brand),
                ),
              )
            else if (widget.suffixIcon != null)
              widget.suffixIcon!
            else if (widget.showArrow)
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: colors.textPlaceholder,
              ),
          ],
        ),
      ),
      ),
    );
  }

  static Widget _buildChip(
    String label,
    ParkThemeData park, {
    VoidCallback? onRemove,
    VoidCallback? onTap,
  }) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;

    return Semantics(
      label: label,
      button: onTap != null || onRemove != null,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colors.brandLight.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(radius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: typo.sizeBodySmall, color: colors.brand),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 14, color: colors.brand),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  static List<String> _parseValues(String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split(',').where((v) => v.isNotEmpty).toList();
  }

  /// 显示溢出标签展开的 BottomSheet，展示所有已选项。
  static void _showOverflowSheet(_ParkSelectState state) {
    final widget = state.widget;
    final context = state.context;
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final currentValues = _parseValues(state.value);

    showModalBottomSheet<List<String>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OverflowSheet(
        selectedValues: currentValues,
        items: widget.items,
        park: park,
      ),
    ).then((result) {
      if (!state.mounted) return;
      if (result != null) {
        final newVal = result.isEmpty ? null : result.join(',');
        state.didChange(newVal);
        widget.onChanged?.call(newVal);
      }
    });
  }

  static void _showSheet(_ParkSelectState state) async {
    final widget = state.widget;
    final context = state.context;
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    final currentValues = _parseValues(state.value);

    // 计算有效虚拟化设置 / Compute effective virtualization
    final int totalItemCount = widget.groupedOptions != null
        ? widget.groupedOptions!
            .fold<int>(0, (sum, g) => sum + g.options.length)
        : widget.items.length;
    final bool effectiveVirtual = widget.virtualize ??
        (widget.virtual || totalItemCount > 50);

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SelectSheet(
          items: widget.items,
          selectedValues: List<String>.from(currentValues),
          multiple: widget.multiple,
          park: park,
          emptyText: widget.emptyText ?? l10n.selectEmptyText,
          searchable: widget.searchable,
          onSearchChanged: widget.onSearchChanged,
          searching: widget.searching,
          searchErrorText: widget.searchErrorText,
          grouped: widget.grouped,
          notFoundContent: widget.notFoundContent,
          allowCreate: widget.allowCreate,
          maxSelection: widget.maxSelection,
          virtual: effectiveVirtual,
          groupedOptions: widget.groupedOptions,
          filterOption: widget.filterOption,
          onSearchAsync: widget.onSearchAsync,
          searchDebounce: widget.searchDebounce,
          searchLoadingText: widget.searchLoadingText,
        );
      },
    );

    if (!state.mounted) return;
    if (result != null) {
      final newVal = result.isEmpty ? null : result.join(',');
      state.didChange(newVal);
      widget.onChanged?.call(newVal);
    }
  }

  @override
  FormFieldState<String> createState() => _ParkSelectState();
}

class _ParkSelectState extends FormFieldState<String> with BindableFormFieldMixin<String> {
  @override
  ParkSelect get widget => super.widget as ParkSelect;

  @override
  void didUpdateWidget(covariant FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // FormField 只在首次创建时读取 initialValue，父级改变 value 时必须自行同步，
    // 否则受控用法（重置 / 外部联动）不会更新显示（含多选的逗号分隔值）。
    if (widget.initialValue != oldWidget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

/// 内部：选项列表底部面板
class _SelectSheet extends StatefulWidget {
  final List<ParkSelectOption> items;
  final List<String> selectedValues;
  final bool multiple;
  final ParkThemeData park;
  final String emptyText;
  final bool searchable;
  final ValueChanged<String>? onSearchChanged;
  final bool searching;
  final String? searchErrorText;
  final bool grouped;
  final Widget? notFoundContent;
  final bool allowCreate;
  final int? maxSelection;
  final bool virtual;
  final List<ParkSelectGroupOption>? groupedOptions;

  /// 自定义过滤函数 / Custom filter function
  final Object? filterOption;

  /// 远程搜索回调。
  final Future<List<ParkSelectOption>> Function(String keyword)? onSearchAsync;

  /// 远程搜索防抖时间。
  final Duration searchDebounce;

  /// 远程搜索加载文案。
  final String? searchLoadingText;

  const _SelectSheet({
    required this.items,
    required this.selectedValues,
    required this.multiple,
    required this.park,
    required this.emptyText,
    required this.searchable,
    this.onSearchChanged,
    required this.searching,
    this.searchErrorText,
    required this.grouped,
    this.notFoundContent,
    required this.allowCreate,
    this.maxSelection,
    this.virtual = false,
    this.groupedOptions,
    this.filterOption,
    this.onSearchAsync,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.searchLoadingText,
  });

  @override
  State<_SelectSheet> createState() => _SelectSheetState();
}

class _SelectSheetState extends State<_SelectSheet> {
  late List<String> _tempSelected;
  String _keyword = '';
  late List<ParkSelectOption> _mutableItems;

  /// 远程搜索状态。
  Timer? _debounceTimer;
  bool _internalSearching = false;
  String? _internalSearchError;
  int _searchRequestId = 0;

  /// 原始选项快照（用于远程搜索清空时恢复）。
  late List<ParkSelectOption> _originalItems;

  /// 是否处于远程搜索模式（onSearchAsync 已提供）。
  bool get _remoteSearchActive => widget.onSearchAsync != null;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<String>.from(widget.selectedValues);
    if (widget.groupedOptions != null) {
      _mutableItems = <ParkSelectOption>[
        for (final group in widget.groupedOptions!)
          for (final opt in group.options)
            ParkSelectOption(
              label: opt.label,
              value: opt.value,
              disabled: opt.disabled,
              group: group.groupLabel,
            ),
      ];
    } else {
      _mutableItems = List<ParkSelectOption>.from(widget.items);
    }
    _originalItems = List<ParkSelectOption>.from(_mutableItems);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleItem(String value) {
    setState(() {
      if (widget.multiple) {
        if (_tempSelected.contains(value)) {
          _tempSelected.remove(value);
        } else {
          // Enforce maxSelection limit
          if (widget.maxSelection != null &&
              _tempSelected.length >= widget.maxSelection!) {
            return;
          }
          _tempSelected.add(value);
        }
      } else {
        _tempSelected = [value];
      }
    });
  }

  void _createAndSelect(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      final newOption = ParkSelectOption(label: trimmed, value: trimmed);
      _mutableItems.add(newOption);
      if (widget.multiple) {
        if (!_tempSelected.contains(trimmed)) {
          _tempSelected.add(trimmed);
        }
      } else {
        _tempSelected = [trimmed];
      }
    });
    if (!widget.multiple) {
      Navigator.of(context).pop(_tempSelected);
    }
  }

  /// 远程搜索：防抖触发。
  void _onSearchTextChanged(String value) {
    setState(() => _keyword = value);
    widget.onSearchChanged?.call(value);

    if (!_remoteSearchActive) return;

    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      // 清空搜索时恢复原始选项。
      setState(() {
        _mutableItems = List<ParkSelectOption>.from(_originalItems);
        _internalSearching = false;
        _internalSearchError = null;
      });
      return;
    }

    _debounceTimer = Timer(widget.searchDebounce, () {
      _handleRemoteSearch(value.trim());
    });
  }

  /// 远程搜索：执行异步查询。
  Future<void> _handleRemoteSearch(String keyword) async {
    final int requestId = ++_searchRequestId;
    setState(() {
      _internalSearching = true;
      _internalSearchError = null;
    });

    try {
      final List<ParkSelectOption> results =
          await widget.onSearchAsync!(keyword);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _mutableItems = List<ParkSelectOption>.from(results);
        _internalSearching = false;
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _internalSearching = false;
        _internalSearchError = e.toString();
      });
    }
  }

  List<ParkSelectOption> _filteredItems() {
    // 远程搜索模式下，选项由 onSearchAsync 返回结果决定，跳过本地过滤。
    if (_remoteSearchActive && _keyword.trim().isNotEmpty) {
      return _mutableItems;
    }
    if (_keyword.trim().isEmpty) return _mutableItems;
    final String lower = _keyword.trim().toLowerCase();
    final Object? filterOpt = widget.filterOption;
    // filterOption is a Function: call it with (searchText, option) to determine visibility
    if (filterOpt is Function) {
      return _mutableItems.where((ParkSelectOption item) {
        try {
          return filterOpt(_keyword.trim(), item) == true;
        } catch (_) {
          return false;
        }
      }).toList();
    }
    // filterOption is true (bool): use default case-insensitive contains filtering
    if (filterOpt == true) {
      return _mutableItems
          .where(
            (ParkSelectOption item) =>
                item.label.toLowerCase().contains(lower) ||
                item.value.toLowerCase().contains(lower),
          )
          .toList();
    }
    // filterOption is false: explicitly disabled, show all items (no filtering)
    if (filterOpt == false) {
      return _mutableItems;
    }
    // filterOption is null/true: use default case-insensitive contains filtering
    return _mutableItems
        .where(
          (ParkSelectOption item) =>
              item.label.toLowerCase().contains(lower) ||
              item.value.toLowerCase().contains(lower),
        )
        .toList();
  }

  bool get _canCreateNew {
    if (!widget.allowCreate || !widget.searchable) return false;
    final trimmed = _keyword.trim();
    if (trimmed.isEmpty) return false;
    final lower = trimmed.toLowerCase();
    return !_mutableItems.any(
      (o) =>
          o.label.toLowerCase() == lower || o.value.toLowerCase() == lower,
    );
  }

  List<_SelectRenderItem> _buildRenderItems(List<ParkSelectOption> items) {
    // 当提供 groupedOptions 时强制按分组渲染 / Force grouped rendering when groupedOptions is set
    final bool useGrouped = widget.grouped || widget.groupedOptions != null;

    if (!useGrouped) {
      return items
          .map((item) => _SelectRenderItem.option(option: item))
          .toList();
    }

    final List<_SelectRenderItem> renderItems = <_SelectRenderItem>[];
    String? currentGroup;

    for (final ParkSelectOption item in items) {
      final String normalizedGroup =
          (item.group == null || item.group!.trim().isEmpty)
          ? ParkLocalizations.of(context).defaultGroupLabel
          : item.group!.trim();
      if (normalizedGroup != currentGroup) {
        currentGroup = normalizedGroup;
        renderItems.add(_SelectRenderItem.group(title: normalizedGroup));
      }
      renderItems.add(_SelectRenderItem.option(option: item));
    }

    return renderItems;
  }

  /// 构建选项列表（区分虚拟滚动模式）。
  ///
  /// [renderItems] 扁平渲染项（分组头 + 选项）。
  /// [showCreateEntry] 是否展示「创建新选项」条目。
  Widget _buildOptionList(
    List<_SelectRenderItem> renderItems,
    bool showCreateEntry,
  ) {
    if (widget.virtual) {
      final int itemCount = renderItems.length + (showCreateEntry ? 1 : 0);
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          if (index < renderItems.length) {
            return _buildOptionItem(renderItems[index]);
          }
          return _buildCreateEntryItem();
        },
      );
    }
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ...renderItems.map(_buildOptionItem),
        if (showCreateEntry) _buildCreateEntryItem(),
      ],
    );
  }

  /// 构建单个渲染项（分组头或选项）。
  Widget _buildOptionItem(_SelectRenderItem renderItem) {
    final ParkThemeData park = widget.park;
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    if (renderItem.isGroupHeader) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          spacing.base,
          spacing.sm,
          spacing.base,
          spacing.xs,
        ),
        child: Text(
          renderItem.groupTitle!,
          style: TextStyle(
            fontSize: typo.sizeCaption,
            color: colors.textSecondary,
            fontWeight: typo.weightMedium,
          ),
        ),
      );
    }

    final ParkSelectOption item = renderItem.option!;
    final bool isSelected = _tempSelected.contains(item.value);
    final bool isDisabled = item.disabled;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      selected: isSelected,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled
          ? null
          : () {
              if (widget.multiple) {
                _toggleItem(item.value);
              } else {
                Navigator.of(context).pop([item.value]);
              }
            },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.base,
          vertical: spacing.md,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: typo.sizeBody,
                  color: isDisabled
                      ? colors.textDisabled
                      : isSelected
                          ? colors.brand
                          : colors.textPrimary,
                  fontWeight: isSelected ? typo.weightMedium : typo.weightRegular,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 20,
                color: isDisabled ? colors.textDisabled : colors.brand,
              ),
          ],
        ),
      ),
      ),
    );
  }

  /// 构建「创建新选项」条目。
  Widget _buildCreateEntryItem() {
    final ParkThemeData park = widget.park;
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    return Semantics(
      button: true,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _createAndSelect(_keyword.trim()),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.base,
          vertical: spacing.md,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.add, size: 18, color: colors.brand),
            SizedBox(width: spacing.xs),
            Expanded(
              child: Text(
                ParkLocalizations.of(context).createOption(_keyword.trim()),
                style: TextStyle(
                  fontSize: typo.sizeBody,
                  color: colors.brand,
                  fontWeight: typo.weightMedium,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = widget.park;
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    final List<ParkSelectOption> visibleItems = _filteredItems();
    final List<_SelectRenderItem> renderItems = _buildRenderItems(visibleItems);
    final bool showCreateEntry = _remoteSearchActive ? false : _canCreateNew;

    // 远程搜索模式下使用内部状态，否则使用外部传入状态。
    final bool effectiveSearching =
        _remoteSearchActive ? _internalSearching : widget.searching;
    final String? effectiveSearchError =
        _remoteSearchActive ? _internalSearchError : widget.searchErrorText;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部栏
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.base,
                vertical: spacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    button: true,
                    label: ParkLocalizations.of(context).cancelText,
                    child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      ParkLocalizations.of(context).cancelText,
                      style: TextStyle(
                        fontSize: typo.sizeBody,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  ),
                  if (widget.multiple)
                    Semantics(
                      button: true,
                      label: ParkLocalizations.of(context).confirmText,
                      child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(_tempSelected),
                      child: Text(
                        '${ParkLocalizations.of(context).confirmText}${_tempSelected.isNotEmpty ? ' (${_tempSelected.length})' : ''}',
                        style: TextStyle(
                          fontSize: typo.sizeBody,
                          color: colors.brand,
                          fontWeight: typo.weightMedium,
                        ),
                      ),
                    ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
            Divider(height: 1, color: colors.divider),

            if (widget.searchable)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  spacing.sm,
                  spacing.base,
                  spacing.xs,
                ),
                child: TextField(
                  onChanged: _onSearchTextChanged,
                  onSubmitted: (String value) {
                    if (showCreateEntry) {
                      _createAndSelect(value);
                    }
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: ParkLocalizations.of(context).searchOptionsHint,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.md),
                    ),
                  ),
                ),
              ),

            if (effectiveSearching)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  spacing.xs,
                  spacing.base,
                  spacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(colors.brand),
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                    Text(
                      widget.searchLoadingText ??
                          ParkLocalizations.of(context).searchingText,
                      style: TextStyle(
                        fontSize: typo.sizeCaption,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            if (effectiveSearchError != null &&
                effectiveSearchError.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  0,
                  spacing.base,
                  spacing.sm,
                ),
                child: Text(
                  effectiveSearchError,
                  style: TextStyle(
                    fontSize: typo.sizeCaption,
                    color: colors.error,
                    fontWeight: typo.weightMedium,
                  ),
                ),
              ),

            // 选项列表
            Flexible(
              child: visibleItems.isEmpty && !showCreateEntry
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(spacing.lg),
                        child: widget.notFoundContent ??
                            Text(
                              widget.emptyText,
                              style: TextStyle(
                                fontSize: typo.sizeBodySmall,
                                color: colors.textPlaceholder,
                              ),
                            ),
                      ),
                    )
                  : _buildOptionList(renderItems, showCreateEntry),
            ),

            SizedBox(height: spacing.base),
          ],
        ),
      ),
    );
  }
}

class _SelectRenderItem {
  final String? groupTitle;
  final ParkSelectOption? option;

  const _SelectRenderItem.group({required String title})
    : groupTitle = title,
      option = null;

  const _SelectRenderItem.option({required this.option}) : groupTitle = null;

  bool get isGroupHeader => groupTitle != null;
}

/// 内部：溢出标签展开面板，展示所有已选项并支持移除。
class _OverflowSheet extends StatelessWidget {
  final List<String> selectedValues;
  final List<ParkSelectOption> items;
  final ParkThemeData park;

  const _OverflowSheet({
    required this.selectedValues,
    required this.items,
    required this.park,
  });

  @override
  Widget build(BuildContext context) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final maxHeight = MediaQuery.of(context).size.height * 0.5;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示条
            Padding(
              padding: EdgeInsets.only(top: spacing.sm),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // 标题
            Padding(
              padding: EdgeInsets.all(spacing.base),
              child: Text(
                ParkLocalizations.of(context).confirmText,
                style: TextStyle(
                  fontSize: typo.sizeBody,
                  color: colors.textPrimary,
                  fontWeight: typo.weightMedium,
                ),
              ),
            ),
            Divider(height: 1, color: colors.divider),
            // 已选项列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selectedValues.length,
                itemBuilder: (context, index) {
                  final value = selectedValues[index];
                  final opt = items.where((o) => o.value == value).firstOrNull;
                  final label = opt?.label ?? value;
                  return Semantics(
                    button: true,
                    label: ParkLocalizations.of(context).deleteText,
                    child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final newValues = List<String>.from(selectedValues)
                        ..remove(value);
                      Navigator.of(context).pop(newValues);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.base,
                        vertical: spacing.md,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 18,
                            color: colors.brand,
                          ),
                          SizedBox(width: spacing.sm),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: typo.sizeBody,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.close,
                            size: 16,
                            color: colors.textPlaceholder,
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: spacing.base),
          ],
        ),
      ),
    );
  }
}
