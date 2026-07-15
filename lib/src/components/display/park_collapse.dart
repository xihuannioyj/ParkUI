import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// Where the expand/collapse icon is placed in the panel header.
enum ParkExpandIconPosition {
  /// Icon is placed at the start (left) of the header, before the title.
  start,

  /// Icon is placed at the end (right) of the header, after the title and extra.
  end,
}

/// Controls how a collapse panel can be toggled.
enum ParkCollapseCollapsible {
  /// Can be toggled by clicking anywhere on the header.
  header,

  /// Can only be toggled by clicking the expand icon.
  icon,

  /// Cannot be toggled (disabled).
  disabled,
}

/// Data model for a single collapse item.
class ParkCollapseItem {
  /// Creates a ParkCollapseItem.
  const ParkCollapseItem({
    required this.key,
    required this.title,
    required this.content,
    this.disabled = false,
    this.icon,
    this.extra,
    this.expandIcon,
    this.headerWidget,
  });

  /// Unique identifier for this item.
  final String key;

  /// Header title text.
  final String title;

  /// Body content widget revealed when expanded.
  final Widget content;

  /// Whether this item is disabled (cannot be toggled).
  final bool disabled;

  /// Optional leading icon in the header.
  final IconData? icon;

  /// Optional extra widget displayed on the right side of the header.
  final Widget? extra;

  /// Custom expand/collapse arrow icon for this item (overrides the default arrow).
  final Widget? expandIcon;

  /// Rich header content widget (takes priority over [title] when set).
  final Widget? headerWidget;
}

/// An accordion / collapsible panel component.
///
/// Supports single or multi-expand modes via [accordion].
/// Reports state changes through [onChanged].
class ParkCollapse extends StatefulWidget {
  /// Creates a ParkCollapse.
  const ParkCollapse({
    super.key,
    required this.items,
    this.activeKeys = const {},
    this.onChanged,
    this.accordion = false,
    this.bordered = true,
    this.ghost = false,
    this.onChangeIndex,
    this.collapsible = ParkCollapseCollapsible.header,
    this.bindKey,
    this.bindingService,
    this.shape,
    this.headerPadding,
    this.contentPadding,
    this.expandIcon,
    this.expandIconPosition = ParkExpandIconPosition.end,
  });

  /// The list of collapsible items.
  final List<ParkCollapseItem> items;

  /// Currently expanded item keys.
  final Set<String> activeKeys;

  /// Called when the set of active keys changes.
  final ValueChanged<Set<String>>? onChanged;

  /// When true, only one item can be expanded at a time.
  final bool accordion;

  /// When false, removes panel borders.
  final bool bordered;

  /// When true, panels have transparent background.
  final bool ghost;

  /// Called with the list of active indexes when panels open/close.
  final ValueChanged<List<int>>? onChangeIndex;

  /// Controls how panels can be toggled (header click, icon click, or disabled).
  final ParkCollapseCollapsible collapsible;

  /// 绑定键（点号分隔的路径，如 `'collapseActiveKeys'`）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  /// The shape of the collapse panel (e.g. RoundedRectangleBorder).
  ///
  /// When provided, each panel header and content body uses this shape
  /// with the panel's background color. Mimics ExpansionTile.shape.
  final ShapeBorder? shape;

  /// Padding around the header area of each panel.
  ///
  /// When null, defaults to `EdgeInsets.symmetric(horizontal: 16, vertical: 12)`.
  final EdgeInsetsGeometry? headerPadding;

  /// Padding around the expandable content body of each panel.
  ///
  /// When null, defaults to `EdgeInsets.fromLTRB(16, 0, 16, 16)`.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom expand/collapse icon for all panels (overridden by [ParkCollapseItem.expandIcon]).
  final Widget? expandIcon;

  /// Where the expand/collapse icon is placed in the header.
  ///
  /// Defaults to [ParkExpandIconPosition.end] for backward compatibility.
  final ParkExpandIconPosition expandIconPosition;

  @override
  State<ParkCollapse> createState() => _ParkCollapseState();
}

class _ParkCollapseState extends State<ParkCollapse>
    with BindableWidgetMixin<Set<String>, ParkCollapse> {
  late Set<String> _activeKeys;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    final initialValue = boundValue;
    _activeKeys = Set.from(initialValue ?? widget.activeKeys);
  }

  @override
  void didUpdateWidget(covariant ParkCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeKeys != widget.activeKeys) {
      _activeKeys = Set.from(widget.activeKeys);
    }
  }

  void _toggle(String itemKey) {
    setState(() {
      if (_activeKeys.contains(itemKey)) {
        _activeKeys.remove(itemKey);
      } else {
        if (widget.accordion) {
          _activeKeys.clear();
        }
        _activeKeys.add(itemKey);
      }
    });
    widget.onChanged?.call(Set.from(_activeKeys));
    widget.onChangeIndex?.call(_activeIndexes);
    boundValue = Set.from(_activeKeys);
  }

  List<int> get _activeIndexes {
    return [
      for (int i = 0; i < widget.items.length; i++)
        if (_activeKeys.contains(widget.items[i].key)) i,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          _buildItem(park, widget.items[i]),
          if (widget.bordered && !widget.ghost && i < widget.items.length - 1)
            Container(height: 0.5, color: park.colors.divider),
        ],
      ],
    );
  }

  Widget _buildItem(ParkThemeData park, ParkCollapseItem item) {
    final isOpen = _activeKeys.contains(item.key);
    final isDisabled = item.disabled;

    final headerPad = widget.headerPadding ?? EdgeInsets.symmetric(
      horizontal: park.spacing.base,
      vertical: park.spacing.md,
    );

    final contentPad = widget.contentPadding ?? EdgeInsets.fromLTRB(
      park.spacing.base,
      0,
      park.spacing.base,
      park.spacing.base,
    );

    final bgColor = isDisabled
        ? park.colors.disabledBg.withValues(alpha: 0.3)
        : widget.ghost
            ? Colors.transparent
            : park.colors.surface;

    final Widget iconWidget = item.expandIcon ??
        (widget.expandIcon ??
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: isDisabled
                    ? park.colors.textDisabled
                    : park.colors.textSecondary,
              ),
            ));

    final Widget header = Semantics(
      button: true,
      label: item.title,
      expanded: isOpen,
      enabled: !isDisabled,
      child: GestureDetector(
      onTap: isDisabled ? null : () => _toggle(item.key),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: headerPad,
        decoration: widget.shape != null
            ? null
            : BoxDecoration(
                color: bgColor,
                border: widget.bordered && !widget.ghost
                    ? Border(
                        bottom: BorderSide(color: park.colors.divider, width: 0.5),
                      )
                    : null,
              ),
        child: Row(
          children: [
            if (widget.expandIconPosition == ParkExpandIconPosition.start) ...[
              iconWidget,
              SizedBox(width: park.spacing.sm),
            ],
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 20,
                color: isDisabled ? park.colors.textDisabled : park.colors.textPrimary,
              ),
              SizedBox(width: park.spacing.sm),
            ],
            Expanded(
              child: item.headerWidget ??
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: park.typography.sizeBody,
                      fontWeight: park.typography.weightMedium,
                      color: isDisabled ? park.colors.textDisabled : park.colors.textPrimary,
                    ),
                  ),
            ),
            if (item.extra != null) ...[
              item.extra!,
              SizedBox(width: park.spacing.sm),
            ],
            if (widget.expandIconPosition == ParkExpandIconPosition.end) ...[
              iconWidget,
            ],
          ],
        ),
      ),
    ),
    );

    final Widget body = AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Padding(
        padding: contentPad,
        child: item.content,
      ),
      crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      sizeCurve: Curves.easeInOut,
    );

    // When shape is provided, wrap in Material + shape to match ExpansionTile behavior
    if (widget.shape != null) {
      return Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: ShapeDecoration(
            shape: widget.shape!,
            color: bgColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [header, body],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [header, body],
    );
  }
}
