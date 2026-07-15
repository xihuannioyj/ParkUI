import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// 下拉菜单项数据模型 — 支持子菜单嵌套。
///
/// 当 [children] 非 null 时该项为父菜单项，hover/点击展开子菜单。
/// 叶子节点（[children]=null）正常触发 [onTap]。
class ParkDropdownMenuItem {
  final String label;
  final String value;
  final Widget? icon;
  final bool disabled;

  /// 子菜单项。非 null 时该项展开子菜单而非触发 onTap。
  final List<ParkDropdownMenuItem>? children;

  const ParkDropdownMenuItem({
    required this.label,
    required this.value,
    this.icon,
    this.disabled = false,
    this.children,
  });
}

/// 下拉菜单分组
class ParkDropdownGroup {
  final String label;
  final List<ParkDropdownMenuItem> items;

  const ParkDropdownGroup({
    required this.label,
    required this.items,
  });
}

/// 下拉方向
enum ParkDropdownDirection { down, up }

/// 下拉菜单位置（更细粒度的放置选项）
enum ParkDropdownPlacement { bottomLeft, bottomRight, topLeft, topRight }

/// 子菜单生命周期控制器。
///
/// 管理所有活跃子菜单 OverlayEntry，在主菜单关闭时统一清理。
class _SubmenuController {
  final List<VoidCallback> _closeCallbacks = [];

  void registerClose(VoidCallback callback) {
    _closeCallbacks.add(callback);
  }

  void unregisterClose(VoidCallback callback) {
    _closeCallbacks.remove(callback);
  }

  void closeAll() {
    final callbacks = List<VoidCallback>.from(_closeCallbacks);
    for (final cb in callbacks) {
      cb();
    }
  }
}

/// ParkDropdownMenu — 下拉菜单组件，锚定在 trigger 下方/上方展示。
class ParkDropdownMenu extends StatefulWidget {
  final List<ParkDropdownMenuItem> items;
  final ValueChanged<ParkDropdownMenuItem>? onSelected;
  final Widget trigger;
  final ParkDropdownDirection direction;
  final bool closeOnTapOutside;
  final bool closeOnSelect;
  final bool matchTriggerWidth;
  final double offset;

  // --- New params ---
  /// When true, items can be toggled independently (checkbox style).
  final bool multiple;

  /// Grouped items with labels. When provided, [items] is ignored.
  final List<ParkDropdownGroup>? groups;

  /// When true, automatic dividers are placed between groups.
  final bool dividers;

  /// Completely custom trigger widget. When non-null, replaces [trigger].
  final Widget? customTrigger;

  /// Fires when dropdown opens (true) or closes (false).
  final ValueChanged<bool>? onVisibleChanged;

  /// Currently selected values (for [multiple] mode).
  final Set<String> selectedValues;

  /// Callback when selection changes in [multiple] mode.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Fine-grained placement of the dropdown relative to the trigger.
  /// When provided, overrides [direction].
  final ParkDropdownPlacement? placement;

  /// Custom item rendering builder.
  final Widget Function(ParkDropdownMenuItem item, bool isSelected)? itemBuilder;

  /// Maximum height of the dropdown menu.
  final double maxHeight;

  /// Alias for [closeOnTapOutside]. When non-null, takes priority.
  final bool? closeOnClickOverlay;

  /// Alias for [onVisibleChanged]. Fires when dropdown opens/closes.
  final ValueChanged<bool>? onOpenChange;

  /// 绑定键（点号分隔的路径，如 `'dropdownValues'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  const ParkDropdownMenu({
    super.key,
    required this.items,
    this.onSelected,
    required this.trigger,
    this.direction = ParkDropdownDirection.down,
    this.closeOnTapOutside = true,
    this.closeOnSelect = true,
    this.matchTriggerWidth = true,
    this.offset = 4,
    this.multiple = false,
    this.groups,
    this.dividers = true,
    this.customTrigger,
    this.onVisibleChanged,
    this.selectedValues = const {},
    this.onSelectionChanged,
    this.placement,
    this.itemBuilder,
    this.maxHeight = 300,
    this.closeOnClickOverlay,
    this.onOpenChange,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkDropdownMenu> createState() => _ParkDropdownMenuState();
}

class _ParkDropdownMenuState extends State<ParkDropdownMenu>
    with SingleTickerProviderStateMixin, BindableWidgetMixin<Set<String>, ParkDropdownMenu> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int _overlayEpoch = 0;

  final _SubmenuController _submenuController = _SubmenuController();

  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  /// Internal mutable selection state for [multiple] mode.
  late Set<String> _selectedValues;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    final initialValue = boundValue;
    if (initialValue != null) {
      _selectedValues = Set<String>.from(initialValue);
    } else {
      _selectedValues = Set<String>.from(widget.selectedValues);
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant ParkDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = Set<String>.from(widget.selectedValues);
    }
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _overlayEntry?.markNeedsBuild();
        }
      });
    }
  }

  @override
  void dispose() {
    _removeOverlayEntry();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _hideDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    if (_isOpen && _overlayEntry != null) return;

    _overlayEpoch++;
    _isOpen = true;
    widget.onVisibleChanged?.call(true);

    _overlayEntry ??= OverlayEntry(builder: (context) {
      return _ParkDropdownOverlay(
        layerLink: _layerLink,
        items: widget.groups != null ? const [] : widget.items,
        groups: widget.groups,
        dividers: widget.dividers,
        direction: widget.direction,
        fadeAnim: _fadeAnim,
        scaleAnim: _scaleAnim,
        closeOnTapOutside: widget.closeOnTapOutside,
        matchTriggerWidth: widget.matchTriggerWidth,
        offset: widget.offset,
        triggerSize: _measureTriggerSize(),
        multiple: widget.multiple,
        selectedValues: _selectedValues,
        submenuController: _submenuController,
        onSelected: (item) {
          if (widget.multiple) {
            setState(() {
              if (_selectedValues.contains(item.value)) {
                _selectedValues.remove(item.value);
              } else {
                _selectedValues.add(item.value);
              }
            });
            widget.onSelectionChanged?.call(Set.from(_selectedValues));
            boundValue = Set<String>.from(_selectedValues);
            _overlayEntry?.markNeedsBuild();
            // In multiple mode, don't close on select unless explicitly configured
            if (widget.closeOnSelect) {
              _hideDropdown();
            }
          } else {
            if (widget.closeOnSelect) {
              _hideDropdown();
            }
            widget.onSelected?.call(item);
            boundValue = <String>{item.value};
          }
        },
        onDismiss: _hideDropdown,
        placement: widget.placement,
        itemBuilder: widget.itemBuilder,
        maxHeight: widget.maxHeight,
      );
    });

    if (!_overlayEntry!.mounted) {
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    }

    _overlayEntry?.markNeedsBuild();
    _controller.forward();
  }

  void _hideDropdown() {
    final entry = _overlayEntry;
    if (entry == null || (!_isOpen && _controller.isDismissed)) return;

    // Close all open submenus first
    _submenuController.closeAll();

    _isOpen = false;
    widget.onVisibleChanged?.call(false);
    final hideEpoch = ++_overlayEpoch;

    _controller.reverse().whenCompleteOrCancel(() {
      if (_overlayEpoch != hideEpoch || _isOpen) {
        return;
      }
      _removeOverlayEntry(entry);
    });
  }

  void _removeOverlayEntry([OverlayEntry? entry]) {
    final target = entry ?? _overlayEntry;
    if (target == null) {
      return;
    }

    if (target.mounted) {
      target.remove();
    }

    if (identical(_overlayEntry, target)) {
      _overlayEntry = null;
    }
    _isOpen = false;
  }

  Size? _measureTriggerSize() {
    final renderObject = _targetKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTrigger = widget.customTrigger ?? widget.trigger;
    return CompositedTransformTarget(
      key: _targetKey,
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: effectiveTrigger,
      ),
    );
  }
}

class _ParkDropdownOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final List<ParkDropdownMenuItem> items;
  final List<ParkDropdownGroup>? groups;
  final bool dividers;
  final ParkDropdownDirection direction;
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final bool closeOnTapOutside;
  final bool matchTriggerWidth;
  final double offset;
  final Size? triggerSize;
  final bool multiple;
  final Set<String> selectedValues;
  final _SubmenuController submenuController;
  final ValueChanged<ParkDropdownMenuItem> onSelected;
  final VoidCallback onDismiss;
  final ParkDropdownPlacement? placement;
  final Widget Function(ParkDropdownMenuItem item, bool isSelected)? itemBuilder;
  final double maxHeight;

  const _ParkDropdownOverlay({
    required this.layerLink,
    required this.items,
    this.groups,
    required this.dividers,
    required this.direction,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.closeOnTapOutside,
    required this.matchTriggerWidth,
    required this.offset,
    required this.triggerSize,
    required this.multiple,
    required this.selectedValues,
    required this.submenuController,
    required this.onSelected,
    required this.onDismiss,
    this.placement,
    this.itemBuilder,
    this.maxHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double maxWidth = math.min<double>(
      screenWidth - 16,
      math.max(triggerSize?.width ?? 140, 280),
    );
    final double minWidth = matchTriggerWidth
        ? math.min<double>(triggerSize?.width ?? 140, maxWidth)
        : 140.0;

    final alignment = placement != null
        ? _placementFollowerAnchor()
        : (direction == ParkDropdownDirection.down
            ? Alignment.topLeft
            : Alignment.bottomLeft);
    final targetAlignment = placement != null
        ? _placementTargetAnchor()
        : (direction == ParkDropdownDirection.down
            ? Alignment.bottomLeft
            : Alignment.topLeft);

    final effectiveOffset = placement != null
        ? _placementOffset()
        : (direction == ParkDropdownDirection.down
            ? Offset(0, offset)
            : Offset(0, -offset));

    // Build the children list: grouped or flat
    List<Widget> children;
    if (groups != null && groups!.isNotEmpty) {
      children = _buildGroupedChildren(park, context);
    } else {
      children = items
          .map((item) => _buildItem(item, park, context))
          .toList();
    }

    return Stack(
      children: [
        // Dismiss barrier
        if (closeOnTapOutside)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              submenuController.closeAll();
              onDismiss();
            },
            child: Container(color: Colors.transparent),
          ),

        // Dropdown
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: targetAlignment,
          followerAnchor: alignment,
          offset: effectiveOffset,
          child: FadeTransition(
            opacity: fadeAnim,
            child: ScaleTransition(
              scale: scaleAnim,
              alignment: direction == ParkDropdownDirection.down
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  decoration: BoxDecoration(
                    color: park.colors.surface,
                    borderRadius: park.radius.brMd,
                    boxShadow: park.shadows.lg,
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: park.spacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedChildren(
      ParkThemeData park, BuildContext context) {
    final List<Widget> result = [];
    for (int i = 0; i < groups!.length; i++) {
      final group = groups![i];

      // Group label
      result.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            park.spacing.base,
            park.spacing.sm,
            park.spacing.base,
            park.spacing.xs,
          ),
          child: Text(
            group.label,
            style: park.typography.body.copyWith(
              fontSize: park.typography.sizeBodySmall,
              fontWeight: park.typography.weightBold,
              color: park.colors.textSecondary,
            ),
          ),
        ),
      );

      // Group items
      for (final item in group.items) {
        result.add(_buildItem(item, park, context));
      }

      // Divider between groups (not after last group)
      if (dividers && i < groups!.length - 1) {
        result.add(
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: park.spacing.xs, horizontal: park.spacing.sm),
            child: Divider(height: 1, color: park.colors.border),
          ),
        );
      }
    }
    return result;
  }

  Widget _buildItem(
      ParkDropdownMenuItem item, ParkThemeData park, BuildContext context) {
    // If item has children, render as submenu parent item
    if (item.children != null && item.children!.isNotEmpty) {
      return _ParkDropdownSubmenuItem(
        item: item,
        park: park,
        selectedValues: selectedValues,
        multiple: multiple,
        submenuController: submenuController,
        onSelected: onSelected,
        itemBuilder: itemBuilder,
        maxHeight: maxHeight,
      );
    }

    final bool isSelected = selectedValues.contains(item.value);

    // Use custom itemBuilder when provided
    if (itemBuilder != null) {
      return Semantics(
        button: true,
        label: item.label,
        child: GestureDetector(
          onTap: item.disabled ? null : () => onSelected(item),
          child: itemBuilder!(item, isSelected),
        ),
      );
    }

    final textColor = item.disabled
        ? park.colors.textSecondary.withValues(alpha: 0.4)
        : park.colors.textPrimary;

    return Semantics(
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: item.disabled ? null : () => onSelected(item),
        child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        color: isSelected && !multiple
            ? park.colors.brand.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Row(
          children: [
            if (multiple) ...[
              Icon(
                isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: 18,
                color: item.disabled
                    ? park.colors.textSecondary.withValues(alpha: 0.4)
                    : (isSelected ? park.colors.brand : park.colors.textSecondary),
              ),
              SizedBox(width: park.spacing.xs),
            ],
            if (item.icon != null) ...[
              item.icon!,
              SizedBox(width: park.spacing.sm),
            ],
            Expanded(
              child: Text(
                item.label,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeBody,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Alignment _placementFollowerAnchor() {
    switch (placement!) {
      case ParkDropdownPlacement.bottomLeft:
        return Alignment.topLeft;
      case ParkDropdownPlacement.bottomRight:
        return Alignment.topRight;
      case ParkDropdownPlacement.topLeft:
        return Alignment.bottomLeft;
      case ParkDropdownPlacement.topRight:
        return Alignment.bottomRight;
    }
  }

  Alignment _placementTargetAnchor() {
    switch (placement!) {
      case ParkDropdownPlacement.bottomLeft:
        return Alignment.bottomLeft;
      case ParkDropdownPlacement.bottomRight:
        return Alignment.bottomRight;
      case ParkDropdownPlacement.topLeft:
        return Alignment.topLeft;
      case ParkDropdownPlacement.topRight:
        return Alignment.topRight;
    }
  }

  Offset _placementOffset() {
    switch (placement!) {
      case ParkDropdownPlacement.bottomLeft:
      case ParkDropdownPlacement.bottomRight:
        return Offset(0, offset);
      case ParkDropdownPlacement.topLeft:
      case ParkDropdownPlacement.topRight:
        return Offset(0, -offset);
    }
  }
}

/// 带子菜单的下拉菜单项。
///
/// 当 [ParkDropdownMenuItem.children] 非空时渲染此项，hover/点击时在其右侧
/// 弹出子菜单面板。支持多级递归嵌套。
class _ParkDropdownSubmenuItem extends StatefulWidget {
  final ParkDropdownMenuItem item;
  final ParkThemeData park;
  final bool multiple;
  final Set<String> selectedValues;
  final _SubmenuController submenuController;
  final ValueChanged<ParkDropdownMenuItem> onSelected;
  final Widget Function(ParkDropdownMenuItem item, bool isSelected)? itemBuilder;
  final double maxHeight;

  const _ParkDropdownSubmenuItem({
    required this.item,
    required this.park,
    required this.multiple,
    required this.selectedValues,
    required this.submenuController,
    required this.onSelected,
    this.itemBuilder,
    this.maxHeight = 300,
  });

  @override
  State<_ParkDropdownSubmenuItem> createState() =>
      _ParkDropdownSubmenuItemState();
}

class _ParkDropdownSubmenuItemState extends State<_ParkDropdownSubmenuItem> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _submenuEntry;
  bool _isSubmenuOpen = false;

  @override
  void dispose() {
    _closeSubmenu();
    super.dispose();
  }

  void _openSubmenu() {
    if (_submenuEntry != null || !mounted) return;

    _isSubmenuOpen = true;
    setState(() {});

    _submenuEntry = OverlayEntry(builder: (context) {
      return _buildSubmenuOverlay(context);
    });

    Overlay.of(context).insert(_submenuEntry!);

    // Register with parent controller so it gets closed on main dismiss
    widget.submenuController.registerClose(_closeSubmenu);
  }

  void _closeSubmenu() {
    _submenuEntry?.remove();
    _submenuEntry = null;
    if (_isSubmenuOpen) {
      _isSubmenuOpen = false;
      if (mounted) setState(() {});
    }
    widget.submenuController.unregisterClose(_closeSubmenu);
  }

  void _toggleSubmenu() {
    if (_isSubmenuOpen) {
      _closeSubmenu();
    } else {
      _openSubmenu();
    }
  }

  Widget _buildSubmenuOverlay(BuildContext context) {
    // Build submenu items recursively
    final subItems = widget.item.children!
        .map((child) => _buildSubmenuItem(child, context))
        .toList();

    return Stack(
      children: [
        // Dismiss barrier for this submenu level
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeSubmenu,
          child: Container(color: Colors.transparent),
        ),
        // Submenu positioned at the right of the parent item
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(4, 0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                minWidth: 140,
                maxWidth: 280,
                maxHeight: widget.maxHeight,
              ),
              decoration: BoxDecoration(
                color: widget.park.colors.surface,
                borderRadius: widget.park.radius.brMd,
                boxShadow: widget.park.shadows.lg,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: widget.park.spacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: subItems,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmenuItem(ParkDropdownMenuItem item, BuildContext context) {
    // Recursive: if child has children, create nested submenu item
    if (item.children != null && item.children!.isNotEmpty) {
      return _ParkDropdownSubmenuItem(
        item: item,
        park: widget.park,
        multiple: widget.multiple,
        selectedValues: widget.selectedValues,
        submenuController: widget.submenuController,
        onSelected: widget.onSelected,
        itemBuilder: widget.itemBuilder,
        maxHeight: widget.maxHeight,
      );
    }

    // Leaf item in submenu
    final bool isSelected = widget.selectedValues.contains(item.value);

    if (widget.itemBuilder != null) {
      return Semantics(
        button: true,
        label: item.label,
        child: GestureDetector(
          onTap: item.disabled ? null : () {
            _closeSubmenu();
            widget.onSelected(item);
          },
          child: widget.itemBuilder!(item, isSelected),
        ),
      );
    }

    final textColor = item.disabled
        ? widget.park.colors.textSecondary.withValues(alpha: 0.4)
        : widget.park.colors.textPrimary;

    return Semantics(
      button: true,
      label: item.label,
      child: GestureDetector(
        onTap: item.disabled ? null : () {
          _closeSubmenu();
          widget.onSelected(item);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.park.spacing.base,
            vertical: widget.park.spacing.sm,
          ),
          color: isSelected && !widget.multiple
              ? widget.park.colors.brand.withValues(alpha: 0.08)
              : Colors.transparent,
          child: Row(
            children: [
              if (widget.multiple) ...[
                Icon(
                  isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: item.disabled
                      ? widget.park.colors.textSecondary.withValues(alpha: 0.4)
                      : (isSelected ? widget.park.colors.brand : widget.park.colors.textSecondary),
                ),
                SizedBox(width: widget.park.spacing.xs),
              ],
              if (item.icon != null) ...[
                item.icon!,
                SizedBox(width: widget.park.spacing.sm),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: widget.park.typography.body.copyWith(
                    fontSize: widget.park.typography.sizeBody,
                    color: textColor,
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
    final item = widget.item;
    final bool isSelected = widget.selectedValues.contains(item.value);
    final textColor = item.disabled
        ? widget.park.colors.textSecondary.withValues(alpha: 0.4)
        : widget.park.colors.textPrimary;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        button: true,
        label: item.label,
        child: GestureDetector(
          onTap: item.disabled
              ? null
              : () {
                  // Parent item with children: toggle submenu instead of onTap
                  _toggleSubmenu();
                },
          onTapDown: (_) {
            // Open submenu on tap-down for hover-like feel
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.park.spacing.base,
              vertical: widget.park.spacing.sm,
            ),
            color: isSelected && !widget.multiple
                ? widget.park.colors.brand.withValues(alpha: 0.08)
                : Colors.transparent,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  item.icon!,
                  SizedBox(width: widget.park.spacing.sm),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: widget.park.typography.body.copyWith(
                      fontSize: widget.park.typography.sizeBody,
                      color: textColor,
                    ),
                  ),
                ),
                // Right arrow indicator for submenu
                Semantics(
                  label: '展开子菜单',
                  child: Padding(
                    padding: EdgeInsets.only(left: widget.park.spacing.sm),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: widget.park.colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
