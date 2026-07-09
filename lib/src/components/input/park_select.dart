import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

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
class ParkSelect extends FormField<String> {
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
  final String loadingText;

  /// 空态文案。
  final String emptyText;

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
  final dynamic filterOption;

  /// 自定义选项渲染回调（每个选项的自定义 widget）
  final Widget Function(ParkSelectOption option, bool isSelected)? optionRender;

  /// 是否启用虚拟滚动（大量选项时的性能优化）
  final bool virtual;

  /// 下拉面板宽度是否与选择器宽度一致。默认 true。
  final bool popupMatchSelectWidth;

  /// 搜索回调（与 onSearchChanged 等价，兼容 AntD 命名）
  final ValueChanged<String>? onSearch;

  /// 下拉面板自定义渲染（包裹在选项列表外部）
  final Widget Function(Widget menu)? dropdownRender;

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
    this.loadingText = '加载中…',
    this.emptyText = '暂无选项',
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
    this.popupMatchSelectWidth = true,
    this.onSearch,
    this.dropdownRender,
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

  static double _minHeight(ParkSelectSize size) {
    switch (size) {
      case ParkSelectSize.small:
        return 32;
      case ParkSelectSize.medium:
        return 42;
      case ParkSelectSize.large:
        return 52;
    }
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
        final opt = widget.items.where((o) => o.value == v).firstOrNull;
        if (opt != null) labels.add(opt.label);
      }
      displayText = labels.join(', ');
    } else {
      final opt = widget.items
          .where((o) => o.value == currentValue)
          .firstOrNull;
      displayText = opt?.label ?? currentValue ?? '';
    }

    // maxTagCount: determine visible chips and overflow count
    final int? maxTag = widget.maxTagCount;
    final List<String> visibleChipValues =
        (widget.multiple && hasValue && maxTag != null && maxTag >= 0)
            ? selectedValues.take(maxTag).toList()
            : (widget.multiple && hasValue ? selectedValues : <String>[]);
    final int overflowCount =
        (widget.multiple && hasValue && maxTag != null && maxTag >= 0)
            ? (selectedValues.length - maxTag).clamp(0, selectedValues.length)
            : 0;

    final borderColor = _borderColor(widget.status, state.hasError, park);
    final minH = _minHeight(widget.size);
    final fontSize = _fontSize(widget.size, park);

    return GestureDetector(
      onTap: isDisabled ? null : () => _showSheet(state),
      child: AnimatedContainer(
        duration: ParkMotion.standard,
        curve: ParkMotion.defaultEasing,
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
                          final opt = widget.items
                              .where((o) => o.value == v)
                              .firstOrNull;
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
                          ),
                      ],
                    )
                  : Text(
                      widget.loading
                          ? widget.loadingText
                          : hasValue
                          ? displayText
                          : (widget.hintText ?? '请选择'),
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
              GestureDetector(
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
    );
  }

  static Widget _buildChip(
    String label,
    ParkThemeData park, {
    VoidCallback? onRemove,
  }) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;

    return Container(
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
    );
  }

  static List<String> _parseValues(String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split(',').where((v) => v.isNotEmpty).toList();
  }

  static void _showSheet(_ParkSelectState state) async {
    final widget = state.widget;
    final context = state.context;
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final currentValues = _parseValues(state.value);

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
          emptyText: widget.emptyText,
          searchable: widget.searchable,
          onSearchChanged: widget.onSearchChanged,
          searching: widget.searching,
          searchErrorText: widget.searchErrorText,
          grouped: widget.grouped,
          notFoundContent: widget.notFoundContent,
          allowCreate: widget.allowCreate,
          maxSelection: widget.maxSelection,
          virtual: widget.virtual,
        );
      },
    );

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
  });

  @override
  State<_SelectSheet> createState() => _SelectSheetState();
}

class _SelectSheetState extends State<_SelectSheet> {
  late List<String> _tempSelected;
  String _keyword = '';
  late List<ParkSelectOption> _mutableItems;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<String>.from(widget.selectedValues);
    _mutableItems = List<ParkSelectOption>.from(widget.items);
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

  List<ParkSelectOption> _filteredItems() {
    if (_keyword.trim().isEmpty) return _mutableItems;
    final String lower = _keyword.trim().toLowerCase();
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
    if (!widget.grouped) {
      return items
          .map((item) => _SelectRenderItem.option(option: item))
          .toList();
    }

    final List<_SelectRenderItem> renderItems = <_SelectRenderItem>[];
    String? currentGroup;

    for (final ParkSelectOption item in items) {
      final String normalizedGroup =
          (item.group == null || item.group!.trim().isEmpty)
          ? '默认分组'
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
        ...renderItems.map(_buildOptionItem).toList(),
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

    return GestureDetector(
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
    );
  }

  /// 构建「创建新选项」条目。
  Widget _buildCreateEntryItem() {
    final ParkThemeData park = widget.park;
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    return GestureDetector(
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
                '创建 "${_keyword.trim()}"',
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
    final bool showCreateEntry = _canCreateNew;

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
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: typo.sizeBody,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  if (widget.multiple)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(_tempSelected),
                      child: Text(
                        '确认${_tempSelected.isNotEmpty ? '(${_tempSelected.length})' : ''}',
                        style: TextStyle(
                          fontSize: typo.sizeBody,
                          color: colors.brand,
                          fontWeight: typo.weightMedium,
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
                  onChanged: (String value) {
                    setState(() {
                      _keyword = value;
                    });
                    widget.onSearchChanged?.call(value);
                  },
                  onSubmitted: (String value) {
                    if (showCreateEntry) {
                      _createAndSelect(value);
                    }
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '搜索选项',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.md),
                    ),
                  ),
                ),
              ),

            if (widget.searching)
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
                      '搜索中…',
                      style: TextStyle(
                        fontSize: typo.sizeCaption,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.searchErrorText != null &&
                widget.searchErrorText!.trim().isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  0,
                  spacing.base,
                  spacing.sm,
                ),
                child: Text(
                  widget.searchErrorText!,
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
