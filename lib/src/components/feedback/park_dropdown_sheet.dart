import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';

/// 下拉面板选项项数据模型
class ParkDropdownSheetItem {
  /// 显示文字
  final String label;

  /// 选项值
  final String value;

  /// 子标题／描述
  final String? subtitle;

  /// 前置图标
  final Widget? leading;

  /// 是否禁用
  final bool disabled;

  const ParkDropdownSheetItem({
    required this.label,
    required this.value,
    this.subtitle,
    this.leading,
    this.disabled = false,
  });
}

/// 下拉面板布局模式
enum ParkDropdownSheetLayout {
  /// 列表（默认）
  list,

  /// 网格
  grid,
}

/// ParkDropdownSheet — 底部弹出式下拉面板
///
/// 点击 [trigger] 从底部弹出带标题栏的面板，支持两种内容模式：
/// - **预定义选项**：[items] 配合单选/多选，支持列表/网格布局
/// - **完全自定义**：[child] 可传入任意 Widget，面板仅提供标准外壳
///
/// 通过静态方法 [show] 或实例化、或直接使用 [ParkDropdownSheetAction] 均可。
///
/// ```dart
/// // 选项模式
/// final result = await ParkDropdownSheet.show(
///   context: context,
///   title: '选择类型',
///   items: [
///     ParkDropdownSheetItem(label: '类型 A', value: 'a'),
///     ParkDropdownSheetItem(label: '类型 B', value: 'b'),
///   ],
/// );
///
/// // 完全自定义模式
/// ParkDropdownSheet(
///   trigger: Text('点击打开'),
///   title: '自定义内容',
///   child: Column(children: [YourCustomWidget()]),
/// );
/// ```
class ParkDropdownSheet extends StatefulWidget {
  /// 触发组件
  final Widget trigger;

  /// 面板标题
  final String? title;

  /// 预定义选项列表（与 [child] 互斥，[child] 优先）
  final List<ParkDropdownSheetItem>? items;

  /// 完全自定义子组件（与 [items] 互斥，优先于 [items]）
  final Widget? child;

  /// 是否多选（仅 [items] 模式有效）
  final bool multiple;

  /// 当前选中值（单选为 value，多选为逗号分隔）
  final Set<String>? selectedValues;

  /// 选中变更回调
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// 确认回调（仅 [items] 模式，返回选中值集合）
  final ValueChanged<Set<String>>? onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 面板高度。为 null 时自动适配内容高度。
  final double? height;

  /// 布局模式
  final ParkDropdownSheetLayout layout;

  /// 网格列数（[layout] 为 grid 时生效）
  final int gridColumns;

  /// 确认按钮文字
  final String confirmText;

  /// 取消按钮文字
  final String cancelText;

  /// 是否显示搜索框（仅 [items] 模式）
  final bool searchable;

  /// 搜索占位文字
  final String searchHintText;

  /// 自定义选项构建器（仅 [items] 模式）
  final Widget Function(ParkDropdownSheetItem item, bool isSelected)?
      itemBuilder;

  /// 绑定键（点号分隔的路径）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  /// 面板顶部是否显示拖拽手柄
  final bool showHandle;

  /// 面板打开/关闭回调
  final ValueChanged<bool>? onVisibleChanged;

  const ParkDropdownSheet({
    super.key,
    required this.trigger,
    this.title,
    this.items,
    this.child,
    this.multiple = false,
    this.selectedValues,
    this.onSelectionChanged,
    this.onConfirm,
    this.onCancel,
    this.height,
    this.layout = ParkDropdownSheetLayout.list,
    this.gridColumns = 3,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.searchable = false,
    this.searchHintText = '搜索选项',
    this.itemBuilder,
    this.bindKey,
    this.bindingService,
    this.showHandle = true,
    this.onVisibleChanged,
  });

  /// 以静态方法弹出选项面板
  ///
  /// 返回用户确认选中的 values 集合，取消时返回 null。
  static Future<Set<String>?> show(
    BuildContext context, {
    String? title,
    required List<ParkDropdownSheetItem> items,
    Set<String>? selectedValues,
    bool multiple = false,
    ParkDropdownSheetLayout layout = ParkDropdownSheetLayout.list,
    int gridColumns = 3,
    double? height,
    String confirmText = '确定',
    String cancelText = '取消',
    bool searchable = false,
    String searchHintText = '搜索选项',
    Widget Function(ParkDropdownSheetItem item, bool isSelected)? itemBuilder,
    ValueChanged<Set<String>>? onConfirm,
    String? bindKey,
    ParkBindingService? bindingService,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ParkDropdownSheetContent(
        title: title,
        items: items,
        selectedValues: selectedValues ?? <String>{},
        multiple: multiple,
        layout: layout,
        gridColumns: gridColumns,
        height: height,
        confirmText: confirmText,
        cancelText: cancelText,
        searchable: searchable,
        searchHintText: searchHintText,
        itemBuilder: itemBuilder,
        onConfirm: onConfirm,
        bindKey: bindKey,
        bindingService: bindingService,
        showHandle: true,
      ),
    );
  }

  /// 以静态方法弹出自定义内容面板
  ///
  /// 返回时不做任何值处理，仅用于展示完全自定义的 UI。
  static Future<void> showCustom(
    BuildContext context, {
    String? title,
    required Widget child,
    double? height,
    String confirmText = '确定',
    String cancelText = '取消',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ParkDropdownSheetContent(
        title: title,
        child: child,
        height: height,
        confirmText: confirmText,
        cancelText: cancelText,
        onCustomConfirm: onConfirm,
        onCustomCancel: onCancel,
        showHandle: true,
      ),
    );
  }

  @override
  State<ParkDropdownSheet> createState() => _ParkDropdownSheetState();
}

class _ParkDropdownSheetState extends State<ParkDropdownSheet>
    with BindableWidgetMixin<Set<String>, ParkDropdownSheet> {
  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
  }

  void _open() {
    widget.onVisibleChanged?.call(true);

    if (widget.child != null) {
      // 完全自定义模式
      ParkDropdownSheet.showCustom(
        context,
        title: widget.title,
        child: widget.child!,
        height: widget.height,
        confirmText: widget.confirmText,
        cancelText: widget.cancelText,
        onConfirm: () {
          widget.onConfirm?.call({});
          widget.onVisibleChanged?.call(false);
        },
        onCancel: () {
          widget.onCancel?.call();
          widget.onVisibleChanged?.call(false);
        },
      );
    } else if (widget.items != null) {
      // 预定义选项模式
      ParkDropdownSheet.show(
        context,
        title: widget.title,
        items: widget.items!,
        selectedValues: widget.selectedValues,
        multiple: widget.multiple,
        layout: widget.layout,
        gridColumns: widget.gridColumns,
        height: widget.height,
        confirmText: widget.confirmText,
        cancelText: widget.cancelText,
        searchable: widget.searchable,
        searchHintText: widget.searchHintText,
        itemBuilder: widget.itemBuilder,
        onConfirm: (values) {
          widget.onSelectionChanged?.call(values);
          widget.onConfirm?.call(values);
          boundValue = values;
        },
        bindKey: widget.bindKey,
        bindingService: widget.bindingService,
      ).whenComplete(() {
        if (mounted) {
          widget.onVisibleChanged?.call(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: widget.trigger,
    );
  }
}

// ============================================================================
// 面板内容（内部组件）
// ============================================================================

class _ParkDropdownSheetContent extends StatefulWidget {
  final String? title;
  final List<ParkDropdownSheetItem>? items;
  final Widget? child;
  final Set<String> selectedValues;
  final bool multiple;
  final ParkDropdownSheetLayout layout;
  final int gridColumns;
  final double? height;
  final String confirmText;
  final String cancelText;
  final bool searchable;
  final String searchHintText;
  final Widget Function(ParkDropdownSheetItem item, bool isSelected)?
      itemBuilder;
  final ValueChanged<Set<String>>? onConfirm;
  final VoidCallback? onCustomConfirm;
  final VoidCallback? onCustomCancel;
  final String? bindKey;
  final ParkBindingService? bindingService;
  final bool showHandle;

  const _ParkDropdownSheetContent({
    this.title,
    this.items,
    this.child,
    this.selectedValues = const {},
    this.multiple = false,
    this.layout = ParkDropdownSheetLayout.list,
    this.gridColumns = 3,
    this.height,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.searchable = false,
    this.searchHintText = '搜索选项',
    this.itemBuilder,
    this.onConfirm,
    this.onCustomConfirm,
    this.onCustomCancel,
    this.bindKey,
    this.bindingService,
    this.showHandle = true,
  });

  @override
  State<_ParkDropdownSheetContent> createState() =>
      _ParkDropdownSheetContentState();
}

class _ParkDropdownSheetContentState
    extends State<_ParkDropdownSheetContent> {
  late Set<String> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedValues);
  }

  List<ParkDropdownSheetItem> get _filteredItems {
    if (widget.items == null) return [];
    if (_searchQuery.isEmpty) return widget.items!;
    return widget.items!
        .where((i) =>
            i.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleItem(ParkDropdownSheetItem item) {
    if (item.disabled) return;
    setState(() {
      if (widget.multiple) {
        if (_selected.contains(item.value)) {
          _selected.remove(item.value);
        } else {
          _selected.add(item.value);
        }
      } else {
        _selected = {item.value};
      }
    });
  }

  void _handleConfirm() {
    Navigator.pop(context, _selected);
    widget.onConfirm?.call(_selected);
    widget.onCustomConfirm?.call();
  }

  void _handleCancel() {
    Navigator.pop(context);
    widget.onCustomCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Container(
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(park.radius.lg)),
        boxShadow: park.shadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 拖拽手柄 ──
            if (widget.showHandle)
              Padding(
                padding: EdgeInsets.only(top: park.spacing.sm),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: park.colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // ── 标题栏 ──
            _buildHeader(park),

            // ── 搜索框 ──
            if (widget.searchable && widget.items != null)
              _buildSearchField(park),

            // ── 内容区 ──
            widget.child ?? _buildBody(park),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ParkThemeData park) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        park.spacing.sm,
        park.spacing.xs,
        park.spacing.sm,
        park.spacing.xs,
      ),
      child: Row(
        children: [
          // 取消按钮
          TextButton(
            onPressed: _handleCancel,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.base,
                vertical: park.spacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.cancelText,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                color: park.colors.textSecondary,
              ),
            ),
          ),

          const Spacer(),

          // 标题
          if (widget.title != null)
            Text(
              widget.title!,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                fontWeight: park.typography.weightBold,
                color: park.colors.textPrimary,
              ),
            )
          else
            const SizedBox.shrink(),

          const Spacer(),

          // 确定按钮
          TextButton(
            onPressed: _handleConfirm,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.base,
                vertical: park.spacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.confirmText,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                fontWeight: park.typography.weightBold,
                color: park.colors.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ParkThemeData park) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: park.spacing.base),
      child: Container(
        decoration: BoxDecoration(
          color: park.colors.background,
          borderRadius: park.radius.brMd,
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: widget.searchHintText,
            hintStyle: park.typography.body.copyWith(
              color: park.colors.textPlaceholder,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 18,
              color: park.colors.textPlaceholder,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: park.spacing.sm,
              horizontal: park.spacing.xs,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ParkThemeData park) {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(park.spacing.xl),
        child: Center(
          child: Text(
            _searchQuery.isNotEmpty ? '无匹配选项' : '暂无选项',
            style: park.typography.body.copyWith(
              color: park.colors.textPlaceholder,
            ),
          ),
        ),
      );
    }

    final estimatedHeight = widget.height ??
        _estimateContentHeight(items.length, park);

    return SizedBox(
      height: estimatedHeight,
      child: widget.layout == ParkDropdownSheetLayout.grid
          ? _buildGridView(park)
          : _buildListView(park),
    );
  }

  double _estimateContentHeight(int count, ParkThemeData park) {
    if (widget.layout == ParkDropdownSheetLayout.grid) {
      final rows = (count / widget.gridColumns).ceil();
      return rows * 56.0 + park.spacing.base * 2;
    }
    return (count * 48.0).clamp(100.0, 360.0);
  }

  Widget _buildListView(ParkThemeData park) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        park.spacing.base,
        park.spacing.xs,
        park.spacing.base,
        park.spacing.base,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = _selected.contains(item.value);
        return _buildListItem(item, isSelected, park);
      },
    );
  }

  Widget _buildListItem(
      ParkDropdownSheetItem item, bool isSelected, ParkThemeData park) {
    if (widget.itemBuilder != null) {
      return GestureDetector(
        onTap: () => _toggleItem(item),
        child: widget.itemBuilder!(item, isSelected),
      );
    }

    return GestureDetector(
      onTap: () => _toggleItem(item),
      child: AnimatedContainer(
        duration: ParkMotion.quick,
        curve: ParkMotion.defaultEasing,
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? park.colors.brand.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: park.radius.brSm,
        ),
        child: Row(
          children: [
            if (item.leading != null) ...[
              item.leading!,
              SizedBox(width: park.spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: park.typography.body.copyWith(
                      fontSize: park.typography.sizeBody,
                      fontWeight:
                          isSelected ? park.typography.weightBold : null,
                      color: item.disabled
                          ? park.colors.textPlaceholder
                          : isSelected
                              ? park.colors.brand
                              : park.colors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: park.typography.body.copyWith(
                        fontSize: park.typography.sizeBodySmall,
                        color: park.colors.textPlaceholder,
                      ),
                    ),
                ],
              ),
            ),
            // 选中标记
            if (widget.multiple)
              Icon(
                isSelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20,
                color: isSelected ? park.colors.brand : park.colors.textPlaceholder,
              )
            else if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: park.colors.brand,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(ParkThemeData park) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        park.spacing.base,
        park.spacing.sm,
        park.spacing.base,
        park.spacing.base,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridColumns,
        crossAxisSpacing: park.spacing.sm,
        mainAxisSpacing: park.spacing.sm,
        childAspectRatio: 2.5,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = _selected.contains(item.value);
        return _buildGridItem(item, isSelected, park);
      },
    );
  }

  Widget _buildGridItem(
      ParkDropdownSheetItem item, bool isSelected, ParkThemeData park) {
    return GestureDetector(
      onTap: () => _toggleItem(item),
      child: AnimatedContainer(
        duration: ParkMotion.quick,
        curve: ParkMotion.defaultEasing,
        decoration: BoxDecoration(
          color: isSelected
              ? park.colors.brand.withValues(alpha: 0.08)
              : park.colors.background,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color: isSelected
                ? park.colors.brand.withValues(alpha: 0.3)
                : park.colors.border,
          ),
        ),
        child: Center(
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            style: park.typography.body.copyWith(
              fontSize: park.typography.sizeBodySmall,
              fontWeight:
                  isSelected ? park.typography.weightBold : null,
              color: item.disabled
                  ? park.colors.textPlaceholder
                  : isSelected
                      ? park.colors.brand
                      : park.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
