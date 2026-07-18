import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';

/// 级联选项节点（树形结构）
class ParkCascaderOption {
  /// 显示文字
  final String label;

  /// 选项值
  final String value;

  /// 子选项列表（为 null 或空时表示叶子节点）
  final List<ParkCascaderOption>? children;

  /// 是否禁用。
  final bool disabled;

  const ParkCascaderOption({
    required this.label,
    required this.value,
    this.children,
    this.disabled = false,
  });

  /// 是否为叶子节点
  bool get isLeaf => children == null || children!.isEmpty;
}

/// 级联选择器展开子级触发方式
enum ParkCascaderExpandTrigger {
  /// 点击展开
  click,

  /// 悬停展开（仅桌面端有效，移动端降级为 click）
  hover,
}

/// Park 级联选择器
///
/// 继承 [FormField]，支持多级级联选择。
/// 点击输入框弹出底部面板，面板内按层级展示列导航。
///
/// ```dart
/// ParkCascader(
///   label: '地区',
///   hintText: '请选择省/市/区',
///   options: [
///     ParkCascaderOption(
///       label: '浙江省', value: 'zj',
///       children: [
///         ParkCascaderOption(label: '杭州市', value: 'hz'),
///         ParkCascaderOption(label: '宁波市', value: 'nb'),
///       ],
///     ),
///   ],
///   onChanged: (path) => print(path),
/// )
/// ```
class ParkCascader extends FormField<List<String>> implements ParkBindableWidget {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  /// 级联选项树
  final List<ParkCascaderOption> options;

  /// 当前选中路径（值为各级 value 的列表；[multiple] 模式下为编码后的路径列表）
  final List<String>? value;

  /// 选中路径变更回调
  final ValueChanged<List<String>?>? onChanged;

  /// 输入框占位文字
  final String? hintText;

  /// 输入框标签
  final String? label;

  /// 是否禁用。
  final bool enabled;

  /// 空态文案。
  final String? emptyText;

  /// 是否启用搜索（跨层级模糊搜索）。
  final bool searchable;

  /// 是否允许选择非叶子节点。
  ///
  /// 为 true 时选择中间层级也会触发确认。
  final bool changeOnSelect;

  /// 自定义显示文字格式化函数。
  ///
  /// 入参为已选各级 label 列表，返回显示在输入框中的文字。
  /// 为 null 时使用默认 " / " 分隔拼接。
  final String Function(List<String> selectedLabels)? displayRender;

  /// 展开子级触发方式。
  ///
  /// 默认为 [ParkCascaderExpandTrigger.click]。
  final ParkCascaderExpandTrigger expandTrigger;

  /// 是否在弹出面板顶部显示搜索输入框，实时过滤级联选项（按 label 匹配，展开/折叠匹配路径）。
  final bool showSearch;

  /// 是否启用多选模式。
  ///
  /// 为 true 时每个选项前显示复选框，父节点选中联动子节点（全部选中）或半选（部分选中）。
  /// [value] 中每项为 [`encodePath`] 编码的路径。
  final bool multiple;

  /// 路径编码分隔符（不可见字符，用于 [multiple] 模式下编码多选路径）。
  static const String pathSeparator = '\x01';

  /// 将路径编码为单字符串。
  static String encodePath(List<String> path) => path.join(pathSeparator);

  /// 将编码后的路径解码为路径列表。
  static List<String> decodePath(String encoded) => encoded.split(pathSeparator);

  ParkCascader({
    super.key,
    this.bindKey,
    this.bindingService,
    required this.options,
    this.value,
    this.onChanged,
    this.hintText,
    this.label,
    this.enabled = true,
    this.emptyText,
    this.searchable = false,
    this.changeOnSelect = false,
    this.displayRender,
    this.expandTrigger = ParkCascaderExpandTrigger.click,
    this.showSearch = false,
    this.multiple = false,
    FormFieldSetter<List<String>>? onSaved,
    FormFieldValidator<List<String>>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: value,
         onSaved: onSaved,
         validator: validator,
         autovalidateMode: autovalidateMode,
         builder: (FormFieldState<List<String>> field) {
           final state = field as _ParkCascaderState;
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

  static Widget _buildTrigger(_ParkCascaderState state, ParkThemeData park) {
    final widget = state.widget;
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final currentValue = state.value;
    final hasValue = currentValue != null && currentValue.isNotEmpty;

    // 解析显示文字
    String displayText = '';
    if (hasValue) {
      if (widget.multiple) {
        // 多选模式：解析所有已选路径的 label
        final allLabels = <String>[];
        for (final encoded in currentValue) {
          final path = decodePath(encoded);
          final labels = _resolveLabels(widget.options, path);
          if (labels.isNotEmpty) {
            allLabels.add(labels.join(' / '));
          }
        }
        displayText = widget.displayRender != null
            ? widget.displayRender!(allLabels)
            : '${ParkLocalizations.of(state.context).selectedCount(currentValue.length)}';
      } else {
        final labels = _resolveLabels(widget.options, currentValue);
        displayText = widget.displayRender != null
            ? widget.displayRender!(labels)
            : labels.join(' / ');
      }
    }

    return GestureDetector(
      onTap: widget.enabled ? () => _showSheet(state) : null,
      child: Semantics(
        button: true,
        label: hasValue ? displayText : ParkLocalizations.of(state.context).selectPlaceholder,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.md,
          ),
          decoration: BoxDecoration(
            color: widget.enabled ? colors.surface : colors.disabledBg,
            borderRadius: BorderRadius.circular(radius.md),
            border: Border.all(
              color: state.hasError ? colors.error : colors.border,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue
                      ? displayText
                      : (widget.hintText ?? ParkLocalizations.of(state.context).selectPlaceholder),
                  style: TextStyle(
                    fontSize: typo.sizeBody,
                    color: widget.enabled
                        ? (hasValue ? colors.textPrimary : colors.textPlaceholder)
                        : colors.textDisabled,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 20,
                color: colors.textPlaceholder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 沿路径解析出各级 label
  static List<String> _resolveLabels(
    List<ParkCascaderOption> options,
    List<String> path,
  ) {
    final labels = <String>[];
    var current = options;

    for (final value in path) {
      final found = current.where((o) => o.value == value).firstOrNull;
      if (found == null) break;
      labels.add(found.label);
      current = found.children ?? [];
    }

    return labels;
  }

  static void _showSheet(_ParkCascaderState state) async {
    final widget = state.widget;
    final context = state.context;
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CascaderSheet(
          options: widget.options,
          selectedPath: List<String>.from(widget.value ?? []),
          park: park,
          emptyText: widget.emptyText ?? l10n.noData,
          searchable: widget.searchable,
          changeOnSelect: widget.changeOnSelect,
          expandTrigger: widget.expandTrigger,
          showSearch: widget.showSearch,
          multiple: widget.multiple,
        );
      },
    );

    if (result != null) {
      state.didChange(result);
      widget.onChanged?.call(result);
    }
  }

  @override
  FormFieldState<List<String>> createState() => _ParkCascaderState();
}

class _ParkCascaderState extends FormFieldState<List<String>>
    with BindableFormFieldMixin<List<String>> {
  @override
  ParkCascader get widget => super.widget as ParkCascader;
}

// =============================================================================
// 内部：级联选择器底部面板
// =============================================================================

/// 级联面板中复选框的勾选状态
enum _CheckState { unchecked, checked, indeterminate }

/// 内部：级联选择器底部面板
class _CascaderSheet extends StatefulWidget {
  final List<ParkCascaderOption> options;
  final List<String> selectedPath;
  final ParkThemeData park;
  final String emptyText;
  final bool searchable;
  final bool changeOnSelect;
  final ParkCascaderExpandTrigger expandTrigger;
  final bool showSearch;
  final bool multiple;

  const _CascaderSheet({
    required this.options,
    required this.selectedPath,
    required this.park,
    required this.emptyText,
    this.searchable = false,
    this.changeOnSelect = false,
    this.expandTrigger = ParkCascaderExpandTrigger.click,
    this.showSearch = false,
    this.multiple = false,
  });

  @override
  State<_CascaderSheet> createState() => _CascaderSheetState();
}

class _CascaderSheetState extends State<_CascaderSheet> {
  /// 当前正在浏览的层级（0 = 第一级）
  late int _currentLevel;

  /// 临时选择路径（单选用）
  late List<String> _tempPath;

  /// 搜索关键词（现有 searchable 使用）
  String _searchKeyword = '';

  /// showSearch 关键词
  String _showSearchKeyword = '';

  /// 多选：已选叶子节点的编码路径集合
  late Set<String> _selectedPaths;

  @override
  void initState() {
    super.initState();
    _tempPath = List<String>.from(widget.selectedPath);
    // 定位到最后一个有子级的层级
    _currentLevel = _tempPath.isEmpty ? 0 : _tempPath.length - 1;

    if (widget.multiple) {
      _selectedPaths = Set<String>.from(widget.selectedPath);
    } else {
      _selectedPaths = <String>{};
    }
  }

  // ── 选项查询 ──

  /// 获取指定层级的选项列表
  List<ParkCascaderOption> _getOptionsAtLevel(int level) {
    var options = widget.options;
    for (int i = 0; i < level; i++) {
      final found = options.where((o) => o.value == _tempPath[i]).firstOrNull;
      if (found?.children == null) return [];
      options = found!.children!;
    }
    return options;
  }

  /// 获取指定层级经过 showSearch 过滤后的选项列表
  List<ParkCascaderOption> _getFilteredOptionsAtLevel(int level) {
    final options = _getOptionsAtLevel(level);
    final keyword = _showSearchKeyword.trim().toLowerCase();
    if (keyword.isEmpty) return options;
    return options.where((o) {
      if (o.label.toLowerCase().contains(keyword)) return true;
      if (!o.isLeaf && _hasMatchingDescendant(o.children!, keyword)) return true;
      return false;
    }).toList();
  }

  /// 判断子树中是否有匹配的选项
  bool _hasMatchingDescendant(
    List<ParkCascaderOption> options,
    String keyword,
  ) {
    return options.any((o) =>
        o.label.toLowerCase().contains(keyword) ||
        (!o.isLeaf && _hasMatchingDescendant(o.children!, keyword)));
  }

  /// 搜索所有层级的选项，返回匹配路径列表（现有 searchable 功能）
  List<List<ParkCascaderOption>> _searchAll(String keyword) {
    final results = <List<ParkCascaderOption>>[];
    if (keyword.trim().isEmpty) return results;
    final lowerKeyword = keyword.trim().toLowerCase();
    _searchRecursive(widget.options, [], lowerKeyword, results);
    return results;
  }

  void _searchRecursive(
    List<ParkCascaderOption> options,
    List<ParkCascaderOption> currentPath,
    String keyword,
    List<List<ParkCascaderOption>> results,
  ) {
    for (final option in options) {
      if (option.disabled) continue;
      final newPath = [...currentPath, option];
      if (option.label.toLowerCase().contains(keyword) ||
          option.value.toLowerCase().contains(keyword)) {
        results.add(newPath);
      }
      if (!option.isLeaf) {
        _searchRecursive(option.children!, newPath, keyword, results);
      }
    }
  }

  // ── 多选工具 ──

  /// 收集某个选项下所有叶子节点的编码路径
  void _collectLeafPaths(
    ParkCascaderOption option,
    List<String> pathSoFar,
    Set<String> result,
  ) {
    final currentPath = [...pathSoFar, option.value];
    if (option.isLeaf) {
      result.add(ParkCascader.encodePath(currentPath));
    } else {
      for (final child in option.children!) {
        _collectLeafPaths(child, currentPath, result);
      }
    }
  }

  /// 获取某个选项的复选框状态
  _CheckState _getCheckState(ParkCascaderOption option, int level) {
    if (option.isLeaf) {
      final path = ParkCascader.encodePath([..._tempPath.sublist(0, level), option.value]);
      return _selectedPaths.contains(path)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }
    final leafPaths = <String>{};
    _collectLeafPaths(option, _tempPath.sublist(0, level), leafPaths);
    final selectedCount = leafPaths.where((p) => _selectedPaths.contains(p)).length;
    if (selectedCount == 0) return _CheckState.unchecked;
    if (selectedCount == leafPaths.length) return _CheckState.checked;
    return _CheckState.indeterminate;
  }

  /// 切换某个选项的多选状态
  void _toggleMultiple(int level, ParkCascaderOption option) {
    final leafPaths = <String>{};
    _collectLeafPaths(option, _tempPath.sublist(0, level), leafPaths);
    final allSelected = leafPaths.every((p) => _selectedPaths.contains(p));
    if (!mounted) return;
    setState(() {
      if (allSelected) {
        _selectedPaths.removeAll(leafPaths);
      } else {
        _selectedPaths.addAll(leafPaths);
      }
      // 非叶子节点：展开到子级
      if (!option.isLeaf) {
        // 更新 _tempPath 以便进入子级
        if (_tempPath.length > level) {
          _tempPath = _tempPath.sublist(0, level);
        }
        if (_tempPath.length == level) {
          _tempPath.add(option.value);
        } else {
          _tempPath[level] = option.value;
        }
        _currentLevel = level + 1;
      }
    });
  }

  // ── 选择事件 ──

  void _onSelectOption(int level, ParkCascaderOption option) {
    if (widget.multiple) {
      _toggleMultiple(level, option);
      return;
    }
    if (widget.showSearch && _showSearchKeyword.trim().isNotEmpty) {
      // showSearch 搜索模式下点击即确认
      if (!mounted) return;
      setState(() {
        if (_tempPath.length > level) {
          _tempPath = _tempPath.sublist(0, level);
        }
        if (_tempPath.length == level) {
          _tempPath.add(option.value);
        } else {
          _tempPath[level] = option.value;
        }
      });
      if (widget.changeOnSelect || option.isLeaf) {
        Navigator.of(context).pop(_tempPath);
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      // 截断路径到当前层级
      if (_tempPath.length > level) {
        _tempPath = _tempPath.sublist(0, level);
      }
      // 添加当前选择
      if (_tempPath.length == level) {
        _tempPath.add(option.value);
      } else {
        _tempPath[level] = option.value;
      }

      if (!option.isLeaf) {
        // 有子级，进入下一层
        _currentLevel = level + 1;
      }
      // 叶子节点：不自动关闭，等用户确认
    });
  }

  void _onHoverOption(int level, ParkCascaderOption option) {
    if (option.isLeaf) return;
    if (!mounted) return;
    setState(() {
      if (_tempPath.length > level) {
        _tempPath = _tempPath.sublist(0, level);
      }
      if (_tempPath.length == level) {
        _tempPath.add(option.value);
      } else {
        _tempPath[level] = option.value;
      }
      _currentLevel = level + 1;
    });
  }

  bool get _canConfirm {
    if (widget.multiple) {
      return _selectedPaths.isNotEmpty;
    }
    if (_tempPath.isEmpty) return false;

    // changeOnSelect 模式下，任何已选路径都可以确认
    if (widget.changeOnSelect) return true;

    // 检查最后一级是否为叶子节点
    var options = widget.options;
    for (int i = 0; i < _tempPath.length - 1; i++) {
      final found = options.where((o) => o.value == _tempPath[i]).firstOrNull;
      if (found?.children == null) return false;
      options = found!.children!;
    }
    final lastOpt = options.where((o) => o.value == _tempPath.last).firstOrNull;
    return lastOpt?.isLeaf ?? true;
  }

  // ── 构建 ──

  @override
  Widget build(BuildContext context) {
    final park = widget.park;
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final maxHeight = MediaQuery.of(context).size.height * 0.55;

    // showSearch 激活判定
    final showSearchActive = widget.showSearch && _showSearchKeyword.trim().isNotEmpty;

    // 旧 searchable 判定
    final isSearching = _searchKeyword.trim().isNotEmpty;
    final List<List<ParkCascaderOption>> searchResults =
        isSearching ? _searchAll(_searchKeyword) : <List<ParkCascaderOption>>[];

    // showSearch 模式下使用过滤后的选项构建面包屑
    final useShowSearch = widget.showSearch;

    // 构建层级标签栏
    final tabs = <Widget>[];
    if (!showSearchActive || !useShowSearch) {
      for (int i = 0; i <= _currentLevel; i++) {
        final options = _getOptionsAtLevel(i);
        final selectedValue = i < _tempPath.length ? _tempPath[i] : null;
        final selectedLabel = selectedValue != null
            ? options.where((o) => o.value == selectedValue).firstOrNull?.label
            : null;

        tabs.add(
          GestureDetector(
            onTap: () {
              if (!mounted) return;
              setState(() => _currentLevel = i);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              child: Text(
                selectedLabel ?? ParkLocalizations.of(context).selectPlaceholder,
                style: TextStyle(
                  fontSize: typo.sizeBody,
                  color: _currentLevel == i ? colors.brand : colors.textSecondary,
                  fontWeight: _currentLevel == i
                      ? typo.weightMedium
                      : typo.weightRegular,
                ),
              ),
            ),
          ),
        );

        if (i < _currentLevel) {
          tabs.add(
            Icon(Icons.chevron_right, size: 16, color: colors.textPlaceholder),
          );
        }
      }
    }

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
            // 顶部操作栏
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
                    child: Semantics(
                      button: true,
                      label: ParkLocalizations.of(context).cancelText,
                      child: Text(
                        ParkLocalizations.of(context).cancelText,
                        style: TextStyle(
                          fontSize: typo.sizeBody,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _canConfirm
                        ? () {
                            if (widget.multiple) {
                              Navigator.of(context).pop(_selectedPaths.toList());
                            } else {
                              Navigator.of(context).pop(_tempPath);
                            }
                          }
                        : null,
                    child: Semantics(
                      button: true,
                      label: ParkLocalizations.of(context).confirmText,
                      enabled: _canConfirm,
                      child: Text(
                        ParkLocalizations.of(context).confirmText,
                        style: TextStyle(
                          fontSize: typo.sizeBody,
                          color: _canConfirm ? colors.brand : colors.textDisabled,
                          fontWeight: typo.weightMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.divider),

            // 搜索框：showSearch 优先
            if (widget.showSearch)
              _buildShowSearchField(park, context),
            if (!widget.showSearch && widget.searchable)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  spacing.sm,
                  spacing.base,
                  spacing.xs,
                ),
                child: TextField(
                  onChanged: (value) {
                    if (!mounted) return;
                    setState(() {
                      _searchKeyword = value;
                    });
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

            if (widget.showSearch && showSearchActive) ...[
              // showSearch 激活：显示过滤后的当前层级
              Flexible(child: _buildSearchFilteredList(park)),
            ] else if (widget.searchable && isSearching && !widget.showSearch) ...[
              // 旧 searchable 搜索结果
              Flexible(child: _buildSearchResults(park, searchResults)),
            ] else ...[
              // 层级面包屑导航
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                child: Row(children: tabs),
              ),
              Divider(height: 1, color: colors.divider),

              // 当前层级选项列表
              Flexible(child: _buildLevelList(park)),
            ],

            SizedBox(height: spacing.base),
          ],
        ),
      ),
    );
  }

  Widget _buildShowSearchField(ParkThemeData park, BuildContext context) {
    final radius = park.radius;
    final spacing = park.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.base,
        spacing.sm,
        spacing.base,
        spacing.xs,
      ),
      child: TextField(
        onChanged: (value) {
          if (!mounted) return;
          setState(() {
            _showSearchKeyword = value;
          });
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
    );
  }

  Widget _buildLevelList(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    final options = _getOptionsAtLevel(_currentLevel);

    if (options.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Text(
          widget.emptyText,
          style: TextStyle(
            fontSize: typo.sizeBody,
            color: colors.textPlaceholder,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected =
            !widget.multiple &&
            _currentLevel < _tempPath.length &&
            _tempPath[_currentLevel] == option.value;

        final checkState = widget.multiple
            ? _getCheckState(option, _currentLevel)
            : null;

        final Widget leading;
        if (widget.multiple && checkState != null) {
          leading = Semantics(
            label: option.label,
            selected: checkState == _CheckState.checked,
            child: Checkbox(
              value: checkState == _CheckState.checked,
              tristate: true,
              onChanged: option.disabled
                  ? null
                  : (_) => _toggleMultiple(_currentLevel, option),
              activeColor: park.colors.brand,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        } else {
          leading = const SizedBox.shrink();
        }

        final Widget trailing;
        if (widget.multiple) {
          trailing = option.isLeaf
              ? const SizedBox.shrink()
              : Icon(Icons.chevron_right, size: 18, color: colors.textPlaceholder);
        } else if (isSelected) {
          trailing = Padding(
            padding: EdgeInsets.only(right: spacing.xs),
            child: Icon(Icons.check, size: 18, color: colors.brand),
          );
        } else {
          trailing = option.isLeaf
              ? const SizedBox.shrink()
              : Icon(Icons.chevron_right, size: 18, color: colors.textPlaceholder);
        }

        final optionContent = Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.base,
            vertical: spacing.md,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: typo.sizeBody,
                    color: option.disabled
                        ? colors.textDisabled
                        : (widget.multiple
                            ? colors.textPrimary
                            : isSelected
                                ? colors.brand
                                : colors.textPrimary),
                    fontWeight: widget.multiple
                        ? typo.weightRegular
                        : (isSelected ? typo.weightMedium : typo.weightRegular),
                  ),
                ),
              ),
              trailing,
            ],
          ),
        );

        Widget result;

        if (widget.expandTrigger == ParkCascaderExpandTrigger.hover &&
            !option.isLeaf &&
            !option.disabled &&
            !widget.multiple) {
          result = MouseRegion(
            onEnter: (_) => _onHoverOption(_currentLevel, option),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: option.disabled
                  ? null
                  : () => _onSelectOption(_currentLevel, option),
              child: Semantics(
                button: true,
                label: option.label,
                selected: isSelected,
                enabled: !option.disabled,
                child: optionContent,
              ),
            ),
          );
        } else {
          result = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: option.disabled
                ? null
                : () => _onSelectOption(_currentLevel, option),
            child: Semantics(
              button: true,
              label: option.label,
              selected: isSelected || (widget.multiple && checkState == _CheckState.checked),
              enabled: !option.disabled,
              child: optionContent,
            ),
          );
        }

        return result;
      },
    );
  }

  /// showSearch 过滤后的选项列表
  Widget _buildSearchFilteredList(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    final filtered = _getFilteredOptionsAtLevel(_currentLevel);

    if (filtered.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Text(
          widget.emptyText,
          style: TextStyle(
            fontSize: typo.sizeBody,
            color: colors.textPlaceholder,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final option = filtered[index];
        final isSelected =
            !widget.multiple &&
            _currentLevel < _tempPath.length &&
            _tempPath[_currentLevel] == option.value;

        final checkState = widget.multiple
            ? _getCheckState(option, _currentLevel)
            : null;

        final Widget leading;
        if (widget.multiple && checkState != null) {
          leading = Semantics(
            label: option.label,
            selected: checkState == _CheckState.checked,
            child: Checkbox(
              value: checkState == _CheckState.checked,
              tristate: true,
              onChanged: option.disabled
                  ? null
                  : (_) => _toggleMultiple(_currentLevel, option),
              activeColor: park.colors.brand,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        } else {
          leading = const SizedBox.shrink();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: option.disabled
              ? null
              : () => _onSelectOption(_currentLevel, option),
          child: Semantics(
            button: true,
            label: option.label,
            enabled: !option.disabled,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.base,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: typo.sizeBody,
                        color: option.disabled
                            ? colors.textDisabled
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.xs),
                      child: Icon(Icons.check, size: 18, color: colors.brand),
                    ),
                  if (!option.isLeaf && !widget.multiple)
                    Icon(Icons.chevron_right, size: 18, color: colors.textPlaceholder),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(
    ParkThemeData park,
    List<List<ParkCascaderOption>> results,
  ) {
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    if (results.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Text(
          widget.emptyText,
          style: TextStyle(
            fontSize: typo.sizeBody,
            color: colors.textPlaceholder,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final path = results[index];
        final labels = path.map((o) => o.label).toList();
        final values = path.map((o) => o.value).toList();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!mounted) return;
            setState(() {
              _tempPath = values;
            });
            // 直接确认（搜索结果都是完整路径或 changeOnSelect 路径）
            if (widget.changeOnSelect || path.last.isLeaf) {
              Navigator.of(context).pop(values);
            }
          },
          child: Semantics(
            button: true,
            label: labels.join(' / '),
            child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.base,
              vertical: spacing.md,
            ),
            child: Text(
              labels.join(' / '),
              style: TextStyle(
                fontSize: typo.sizeBody,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}
