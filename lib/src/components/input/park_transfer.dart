import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_service.dart';
import '../../binding/park_binding_form_scope.dart';
import '../../binding/park_bindable.dart';
import '../base/park_button.dart';
import '../base/park_button_style.dart';

/// 穿梭框组件
///
/// 双栏列表选择，支持搜索、全选、单向模式。
/// 用于权限分配、角色选择、字段映射等场景。
///
/// ```dart
/// ParkTransfer(
///   dataSource: [
///     ParkTransferItem(key: '1', title: '选项A'),
///     ParkTransferItem(key: '2', title: '选项B'),
///   ],
///   targetKeys: ['2'],
///   onChanged: (keys, direction) => print('$direction: $keys'),
/// )
/// ```
///
/// [showSearch] 为 true 时左右面板顶部显示搜索框。
/// [oneWay] 为 true 时仅允许从左到右移动。
/// [leftTitle] / [rightTitle] 为自定义标题 Widget，null 时不显示。
class ParkTransfer extends StatefulWidget {
  /// 所有可选项列表。
  final List<ParkTransferItem> dataSource;

  /// 已选中的目标 key 列表。
  final List<String>? targetKeys;

  /// 选中变更回调（返回当前目标 keys + 移动方向）。
  @Deprecated('Use onChanged instead')
  final void Function(List<String> targetKeys, TransferDirection direction)? onChange;

  /// 选中变更回调（返回当前目标 keys + 移动方向）。
  final void Function(List<String> targetKeys, TransferDirection direction)? onChanged;

  /// 内部使用的有效回调：优先使用 onChanged，回退到 onChange。
  void Function(List<String> targetKeys, TransferDirection direction)? get _effectiveOnChanged =>
      onChanged ?? onChange;

  /// 左侧标题 Widget。null 时不显示标题。
  final Widget? leftTitle;

  /// 右侧标题 Widget。null 时不显示标题。
  final Widget? rightTitle;

  /// 是否显示搜索框。
  final bool showSearch;

  /// 是否仅允许从左到右单向移动。
  final bool oneWay;

  /// 是否禁用。
  final bool disabled;

  /// 自定义渲染项。
  final Widget Function(ParkTransferItem item, bool selected)? renderItem;

  /// 绑定键（点号分隔的路径）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  /// 创建 [ParkTransfer]。
  const ParkTransfer({
    super.key,
    required this.dataSource,
    this.targetKeys,
    // ignore: deprecated_member_use_from_same_package
    this.onChange,
    this.onChanged,
    this.leftTitle,
    this.rightTitle,
    this.showSearch = false,
    this.oneWay = false,
    this.disabled = false,
    this.renderItem,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkTransfer> createState() => _ParkTransferState();
}

/// 穿梭方向。
enum TransferDirection { leftToRight, rightToLeft }

/// 穿梭框项。
class ParkTransferItem {
  final String key;
  final String title;
  final String? subtitle;

  const ParkTransferItem({
    required this.key,
    required this.title,
    this.subtitle,
  });
}

class _ParkTransferState extends State<ParkTransfer> {
  late Set<String> _targetKeys;
  ParkBindable<List<String>>? _bindable;
  final _leftController = TextEditingController();
  final _rightController = TextEditingController();
  final Set<String> _leftSelected = {};
  final Set<String> _rightSelected = {};

  @override
  void initState() {
    super.initState();
    _targetKeys = Set<String>.from(widget.targetKeys ?? []);
    _tryLinkBinding();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLinkBinding();
  }

  void _tryLinkBinding() {
    final String? key = widget.bindKey;
    if (key == null || _bindable != null) return;
    final ParkBindingService? service = widget.bindingService ??
        ParkBindingFormScope.of(context)?.service;
    if (service == null) return;

    _bindable = service.bind<List<String>>(key);
    final List<String> initial = _bindable!.value;
    if (initial.isNotEmpty) {
      _targetKeys = Set<String>.from(initial);
    }
    _bindable!.addListener(_onBindableChanged);
  }

  /// model → UI 方向同步。
  void _onBindableChanged() {
    if (!mounted || _bindable == null) return;
    final List<String> value = _bindable!.value;
    final Set<String> next = Set<String>.from(value);
    if (next.length != _targetKeys.length ||
        !next.containsAll(_targetKeys)) {
      setState(() => _targetKeys = next);
    }
  }

  /// UI → model 方向同步。
  void _syncToBindable() {
    final ParkBindable<List<String>>? bindable = _bindable;
    if (bindable == null) return;
    final List<String> value = _targetKeys.toList();
    if (bindable.value.length != value.length ||
        !Set<String>.from(bindable.value).containsAll(value)) {
      // ignore: avoid_dynamic_calls
      (bindable as dynamic).value = value;
    }
  }

  @override
  void didUpdateWidget(covariant ParkTransfer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetKeys != oldWidget.targetKeys) {
      setState(() {
        _targetKeys = Set<String>.from(widget.targetKeys ?? []);
      });
    }
    if (widget.bindKey != oldWidget.bindKey ||
        widget.bindingService != oldWidget.bindingService) {
      _bindable?.removeListener(_onBindableChanged);
      _bindable = null;
      _tryLinkBinding();
    }
  }

  List<ParkTransferItem> get _leftItems =>
      widget.dataSource.where((i) => !_targetKeys.contains(i.key)).toList();
  List<ParkTransferItem> get _rightItems =>
      widget.dataSource.where((i) => _targetKeys.contains(i.key)).toList();

  List<ParkTransferItem> _filtered(List<ParkTransferItem> items, String query) {
    if (query.isEmpty) return items;
    return items.where((i) => i.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void _transfer(TransferDirection dir) {
    if (dir == TransferDirection.leftToRight) {
      _targetKeys.addAll(_leftSelected);
      _leftSelected.clear();
    } else {
      _targetKeys.removeAll(_rightSelected);
      _rightSelected.clear();
    }
    setState(() {});
    _syncToBindable();
    widget._effectiveOnChanged?.call(_targetKeys.toList(), dir);
  }

  @override
  void dispose() {
    _bindable?.removeListener(_onBindableChanged);
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final leftItems = _filtered(_leftItems, _leftController.text);
    final rightItems = _filtered(_rightItems, _rightController.text);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPanel(park, l10n, widget.leftTitle, leftItems, _leftSelected, _leftController)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: park.spacing.xl, horizontal: park.spacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: l10n.moveRightLabel,
                child: ParkButton(
                  variant: ParkButtonVariant.secondary,
                  size: ParkButtonSize.small,
                  onPressed: _leftSelected.isEmpty || widget.disabled ? null : () => _transfer(TransferDirection.leftToRight),
                  child: const Icon(Icons.chevron_right, size: 20),
                ),
              ),
              SizedBox(height: park.spacing.sm),
              if (!widget.oneWay)
                Semantics(
                  label: l10n.moveLeftLabel,
                  child: ParkButton(
                    variant: ParkButtonVariant.secondary,
                    size: ParkButtonSize.small,
                    onPressed: _rightSelected.isEmpty || widget.disabled ? null : () => _transfer(TransferDirection.rightToLeft),
                    child: const Icon(Icons.chevron_left, size: 20),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _buildPanel(park, l10n, widget.rightTitle, rightItems, _rightSelected, _rightController)),
      ],
    );
  }

  Widget _buildPanel(ParkThemeData park, ParkLocalizations l10n, Widget? title, List<ParkTransferItem> items, Set<String> selected, TextEditingController searchCtrl) {
    final allSelected = items.isNotEmpty && items.every((i) => selected.contains(i.key));
    final hasTitle = title != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title header
        if (hasTitle)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: park.spacing.base, vertical: park.spacing.sm),
            decoration: BoxDecoration(
              color: park.colors.surface,
              border: Border.all(color: park.colors.border),
              borderRadius: BorderRadius.vertical(top: Radius.circular(park.radius.sm)),
            ),
            child: Row(
              children: [
                DefaultTextStyle(
                  style: TextStyle(fontSize: park.typography.sizeBody, fontWeight: FontWeight.w600, color: park.colors.textPrimary),
                  child: title,
                ),
                const Spacer(),
                Semantics(
                  label: l10n.totalItemsCount(items.length),
                  child: Text('${items.length}', style: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textSecondary)),
                ),
              ],
            ),
          ),
        // Search
        if (widget.showSearch)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: park.spacing.sm, vertical: park.spacing.xs),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: park.colors.border),
                right: BorderSide(color: park.colors.border),
                top: hasTitle ? BorderSide.none : BorderSide(color: park.colors.border),
              ),
            ),
            child: Semantics(
              label: l10n.searchPlaceholder,
              child: TextField(
                controller: searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.searchPlaceholder,
                  hintStyle: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textPlaceholder),
                  border: InputBorder.none,
                  isDense: true,
                  prefixIconConstraints: const BoxConstraints(maxWidth: 24),
                  prefixIcon: Icon(Icons.search, size: 16, color: park.colors.textSecondary),
                ),
                style: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textPrimary),
              ),
            ),
          ),
        // Body
        SizedBox(
          height: 240,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: park.colors.border),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(park.radius.sm)),
            ),
            child: items.isEmpty
                ? Center(
                    child: Semantics(
                      label: l10n.noData,
                      child: Text(l10n.noData, style: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textPlaceholder)),
                    ),
                  )
                : Column(
                    children: [
                      // Select all
                      Semantics(
                        label: l10n.selectAllText,
                        child: InkWell(
                          onTap: () {
                            if (widget.disabled) return;
                            setState(() {
                              if (allSelected) {
                                selected.clear();
                              } else {
                                for (final i in items) {
                                  selected.add(i.key);
                                }
                              }
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: park.spacing.md, vertical: park.spacing.sm),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: park.colors.borderLight))),
                            child: Row(
                              children: [
                                Icon(allSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: park.colors.brand),
                                SizedBox(width: park.spacing.sm),
                                Text(l10n.selectAllText, style: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) => _buildItem(items[i], selected, park, l10n),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(ParkTransferItem item, Set<String> selected, ParkThemeData park, ParkLocalizations l10n) {
    final isSel = selected.contains(item.key);
    if (widget.renderItem != null) {
      final custom = widget.renderItem!(item, isSel);
      if (widget.disabled) return IgnorePointer(child: custom);
      return custom;
    }

    return Semantics(
      label: '${item.title}${item.subtitle != null ? ', ${item.subtitle}' : ''}${isSel ? ', ${l10n.selectedLabel}' : ''}',
      child: InkWell(
        onTap: widget.disabled ? null : () => setState(() { isSel ? selected.remove(item.key) : selected.add(item.key); }),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: park.spacing.md, vertical: park.spacing.sm),
          decoration: BoxDecoration(
            color: isSel ? park.colors.brand.withAlpha(13) : null,
            border: Border(bottom: BorderSide(color: park.colors.borderLight)),
          ),
          child: Row(
            children: [
              Icon(isSel ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: isSel ? park.colors.brand : park.colors.textSecondary),
              SizedBox(width: park.spacing.sm),
              Expanded(child: Text(item.title, style: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textPrimary))),
              if (item.subtitle != null)
                Text(item.subtitle!, style: TextStyle(fontSize: park.typography.sizeOverline, color: park.colors.textPlaceholder)),
            ],
          ),
        ),
      ),
    );
  }
}
