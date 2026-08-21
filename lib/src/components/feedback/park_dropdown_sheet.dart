import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';
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

/// 下拉面板尺寸
enum ParkDropdownSheetSize {
  /// 小尺寸（紧凑内边距、小字号、小图标）
  small,

  /// 默认尺寸
  medium,

  /// 大尺寸（宽松内边距、大字号、大图标）
  large,
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
  final String? confirmText;

  /// 取消按钮文字
  final String? cancelText;

  /// 是否显示搜索框（仅 [items] 模式）
  final bool searchable;

  /// 搜索占位文字
  final String? searchHintText;

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

  /// 面板尺寸（small/medium/large），控制内边距、字号与图标大小。
  final ParkDropdownSheetSize size;

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
    this.confirmText,
    this.cancelText,
    this.searchable = false,
    this.searchHintText,
    this.itemBuilder,
    this.bindKey,
    this.bindingService,
    this.showHandle = true,
    this.onVisibleChanged,
    this.size = ParkDropdownSheetSize.medium,
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
    String? confirmText,
    String? cancelText,
    bool searchable = false,
    String? searchHintText,
    Widget Function(ParkDropdownSheetItem item, bool isSelected)? itemBuilder,
    ValueChanged<Set<String>>? onConfirm,
    String? bindKey,
    ParkBindingService? bindingService,
    ParkDropdownSheetSize size = ParkDropdownSheetSize.medium,
  }) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // 淡遮罩：避免默认 black54 全屏变暗（蒙层体验）
      barrierColor: Colors.black.withValues(alpha: 0.10),
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
        size: size,
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
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    ParkDropdownSheetSize size = ParkDropdownSheetSize.medium,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // 淡遮罩：避免默认 black54 全屏变暗（蒙层体验）
      barrierColor: Colors.black.withValues(alpha: 0.10),
      builder: (ctx) => _ParkDropdownSheetContent(
        title: title,
        child: child,
        height: height,
        confirmText: confirmText,
        cancelText: cancelText,
        onCustomConfirm: onConfirm,
        onCustomCancel: onCancel,
        showHandle: true,
        size: size,
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
        size: widget.size,
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
        size: widget.size,
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
  final String? confirmText;
  final String? cancelText;
  final bool searchable;
  final String? searchHintText;
  final Widget Function(ParkDropdownSheetItem item, bool isSelected)?
      itemBuilder;
  final ValueChanged<Set<String>>? onConfirm;
  final VoidCallback? onCustomConfirm;
  final VoidCallback? onCustomCancel;
  final String? bindKey;
  final ParkBindingService? bindingService;
  final bool showHandle;

  /// 面板尺寸（small/medium/large）。
  final ParkDropdownSheetSize size;

  const _ParkDropdownSheetContent({
    this.title,
    this.items,
    this.child,
    this.selectedValues = const {},
    this.multiple = false,
    this.layout = ParkDropdownSheetLayout.list,
    this.gridColumns = 3,
    this.height,
    this.confirmText,
    this.cancelText,
    this.searchable = false,
    this.searchHintText,
    this.itemBuilder,
    this.onConfirm,
    this.onCustomConfirm,
    this.onCustomCancel,
    this.bindKey,
    this.bindingService,
    this.showHandle = true,
    this.size = ParkDropdownSheetSize.medium,
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

  /// size 令牌：小/中/大 三档内边距、字号与图标大小。
  ///
  /// medium 档保持原有取值，small/large 分别更紧凑/更宽松。
  ({
    EdgeInsets headerPadding,
    EdgeInsets buttonPadding,
    double headerFontSize,
    double searchIconSize,
    EdgeInsets searchContentPadding,
    EdgeInsets listItemPadding,
    double labelFontSize,
    double subtitleFontSize,
    double checkIconSize,
    double gridLabelFontSize,
    double listRowHeight,
  }) _sizeTokens(ParkThemeData park) {
    return switch (widget.size) {
      ParkDropdownSheetSize.small => (
          headerPadding: EdgeInsets.fromLTRB(
            park.spacing.xs,
            park.spacing.xxs,
            park.spacing.xs,
            park.spacing.xxs,
          ),
          buttonPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.sm,
            vertical: park.spacing.xs,
          ),
          headerFontSize: park.typography.sizeCaption,
          searchIconSize: 16.0,
          searchContentPadding: EdgeInsets.symmetric(
            vertical: park.spacing.xs,
            horizontal: park.spacing.xs,
          ),
          listItemPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.sm,
            vertical: park.spacing.xs,
          ),
          labelFontSize: park.typography.sizeCaption,
          subtitleFontSize: park.typography.sizeCaption,
          checkIconSize: 18.0,
          gridLabelFontSize: park.typography.sizeCaption,
          listRowHeight: 40.0,
        ),
      ParkDropdownSheetSize.medium => (
          headerPadding: EdgeInsets.fromLTRB(
            park.spacing.sm,
            park.spacing.xs,
            park.spacing.sm,
            park.spacing.xs,
          ),
          buttonPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.base,
            vertical: park.spacing.sm,
          ),
          headerFontSize: park.typography.sizeBody,
          searchIconSize: 18.0,
          searchContentPadding: EdgeInsets.symmetric(
            vertical: park.spacing.sm,
            horizontal: park.spacing.xs,
          ),
          listItemPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.base,
            vertical: park.spacing.sm,
          ),
          labelFontSize: park.typography.sizeBody,
          subtitleFontSize: park.typography.sizeBodySmall,
          checkIconSize: 20.0,
          gridLabelFontSize: park.typography.sizeBodySmall,
          listRowHeight: 48.0,
        ),
      ParkDropdownSheetSize.large => (
          headerPadding: EdgeInsets.fromLTRB(
            park.spacing.md,
            park.spacing.sm,
            park.spacing.md,
            park.spacing.sm,
          ),
          buttonPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.lg,
            vertical: park.spacing.sm,
          ),
          headerFontSize: park.typography.sizeBody,
          searchIconSize: 20.0,
          searchContentPadding: EdgeInsets.symmetric(
            vertical: park.spacing.md,
            horizontal: park.spacing.sm,
          ),
          listItemPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.lg,
            vertical: park.spacing.md,
          ),
          labelFontSize: park.typography.sizeBody,
          subtitleFontSize: park.typography.sizeBodySmall,
          checkIconSize: 24.0,
          gridLabelFontSize: park.typography.sizeBody,
          listRowHeight: 56.0,
        ),
    };
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
    final t = _sizeTokens(park);
    return Padding(
      padding: t.headerPadding,
      child: Row(
        children: [
          // 取消按钮
          TextButton(
            onPressed: _handleCancel,
            style: TextButton.styleFrom(
              padding: t.buttonPadding,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.cancelText ?? ParkLocalizations.of(context).cancelText,
              style: park.typography.body.copyWith(
                fontSize: t.headerFontSize,
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
                fontSize: t.headerFontSize,
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
              padding: t.buttonPadding,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.confirmText ?? ParkLocalizations.of(context).confirmText,
              style: park.typography.body.copyWith(
                fontSize: t.headerFontSize,
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
    final t = _sizeTokens(park);
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
            hintText: widget.searchHintText ?? ParkLocalizations.of(context).searchOptionsHint,
            hintStyle: park.typography.body.copyWith(
              color: park.colors.textPlaceholder,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: t.searchIconSize,
              color: park.colors.textPlaceholder,
            ),
            border: InputBorder.none,
            contentPadding: t.searchContentPadding,
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
            _searchQuery.isNotEmpty
                ? ParkLocalizations.of(context).noMatchingOptions
                : ParkLocalizations.of(context).noOptions,
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
    final t = _sizeTokens(park);
    if (widget.layout == ParkDropdownSheetLayout.grid) {
      // gridColumns <= 0 时钳制为 1，避免除零产生 Infinity。
      final int safeColumns = widget.gridColumns > 0 ? widget.gridColumns : 1;
      final rows = (count / safeColumns).ceil();
      return rows * 56.0 + park.spacing.base * 2;
    }
    return (count * t.listRowHeight).clamp(100.0, 360.0);
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
      return Semantics(
        button: true,
        label: item.label,
        child: GestureDetector(
          onTap: () => _toggleItem(item),
          child: widget.itemBuilder!(item, isSelected),
        ),
      );
    }

    final t = _sizeTokens(park);
    return Semantics(
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: () => _toggleItem(item),
        child: AnimatedContainer(
        duration: park.motion.quick,
        curve: park.motion.defaultEasing,
        padding: t.listItemPadding,
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
                      fontSize: t.labelFontSize,
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
                        fontSize: t.subtitleFontSize,
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
                size: t.checkIconSize,
                color: isSelected ? park.colors.brand : park.colors.textPlaceholder,
              )
            else if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: t.checkIconSize,
                color: park.colors.brand,
              ),
          ],
        ),
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
        // gridColumns <= 0 时钳制为 1，避免 GridView crossAxisCount 断言崩溃。
        crossAxisCount: widget.gridColumns > 0 ? widget.gridColumns : 1,
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
    return Semantics(
      button: true,
      label: item.label,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _toggleItem(item),
        child: AnimatedContainer(
        duration: park.motion.quick,
        curve: park.motion.defaultEasing,
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
              fontSize: _sizeTokens(park).gridLabelFontSize,
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
      ),
    );
  }
}
