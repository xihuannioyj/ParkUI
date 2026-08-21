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

/// Collapse panel size preset.
enum ParkCollapseSize {
  /// 小尺寸（紧凑内边距、小字号、小图标）
  small,

  /// 默认尺寸
  medium,

  /// 大尺寸（宽松内边距、大字号、大图标）
  large,
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
    this.size = ParkCollapseSize.medium,
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

  /// 折叠面板尺寸（small / medium / large），控制头部与内容内边距、标题字号与图标大小。
  final ParkCollapseSize size;

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
    _activeKeys = _normalize(Set.from(initialValue ?? widget.activeKeys));
  }

  @override
  void didUpdateWidget(covariant ParkCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeKeys != widget.activeKeys) {
      _activeKeys = _normalize(Set.from(widget.activeKeys));
    }
  }

  /// accordion 模式下归一化：初始 activeKeys 含多个 key 时只保留 items 顺序中
  /// 第一个已激活的 key，避免多个面板同时展开破坏单开语义。
  Set<String> _normalize(Set<String> keys) {
    if (!widget.accordion || keys.length <= 1) return keys;
    String? firstActive;
    for (final item in widget.items) {
      if (keys.contains(item.key)) {
        firstActive = item.key;
        break;
      }
    }
    return <String>{firstActive ?? keys.first};
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

    // size 令牌：小/中/大 三档内边距、字号与图标大小
    final EdgeInsets defaultHeaderPad = switch (widget.size) {
      ParkCollapseSize.small => EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.sm,
        ),
      ParkCollapseSize.medium => EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.md,
        ),
      ParkCollapseSize.large => EdgeInsets.symmetric(
          horizontal: park.spacing.lg,
          vertical: park.spacing.base,
        ),
    };
    final EdgeInsets defaultContentPad = switch (widget.size) {
      ParkCollapseSize.small => EdgeInsets.fromLTRB(
          park.spacing.sm, 0, park.spacing.sm, park.spacing.sm),
      ParkCollapseSize.medium => EdgeInsets.fromLTRB(
          park.spacing.base, 0, park.spacing.base, park.spacing.base),
      ParkCollapseSize.large => EdgeInsets.fromLTRB(
          park.spacing.lg, 0, park.spacing.lg, park.spacing.lg),
    };
    final double iconSize = switch (widget.size) {
      ParkCollapseSize.small => 16.0,
      ParkCollapseSize.medium => 20.0,
      ParkCollapseSize.large => 24.0,
    };
    final double titleFontSize = switch (widget.size) {
      ParkCollapseSize.small => park.typography.sizeCaption,
      ParkCollapseSize.medium => park.typography.sizeBody,
      ParkCollapseSize.large => park.typography.sizeBody,
    };

    final headerPad = widget.headerPadding ?? defaultHeaderPad;

    final contentPad = widget.contentPadding ?? defaultContentPad;

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
                size: iconSize,
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
                size: iconSize,
                color: isDisabled ? park.colors.textDisabled : park.colors.textPrimary,
              ),
              SizedBox(width: park.spacing.sm),
            ],
            Expanded(
              child: item.headerWidget ??
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleFontSize,
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
