import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 提及条目（@ 某人 / # 标签 的数据源单元）。
///
/// - [value]：选中后写入文本的值（如用户 ID / 标签 key）。
/// - [label]：下拉中展示的名称（如昵称 / 标签名）。
/// - [avatar]：可选头像 / 图标。
/// - [disabled]：是否禁用该项（不可选）。
class ParkMentionItem {
  /// 选中后写入文本的值。
  final String value;

  /// 下拉中展示的名称。
  final String label;

  /// 可选头像 / 图标。
  final Widget? avatar;

  /// 是否禁用该项。
  final bool disabled;

  const ParkMentionItem({
    required this.value,
    required this.label,
    this.avatar,
    this.disabled = false,
  });
}

/// 提及输入组件（对标 antd Mentions）。
///
/// 在文本框中输入触发符（默认 `@`，可配置为 `@` / `#` 等）后弹出建议下拉面板，
/// 选中后将标记语法（默认 `@value`）插入文本。支持受控 / 非受控、关键字过滤、
/// 自定义插入文本、键盘上下选择 + 回车确认，以及 onSearch / onSelect 回调。
///
/// 输出格式由 [mentionBuilder] 决定，默认插入 `@value` 并在其后补一个空格，
/// 例如选中 value=alice 的条目会得到文本 `@alice `。
///
/// ```dart
/// ParkMentions(
///   items: [
///     ParkMentionItem(value: 'alice', label: 'Alice'),
///     ParkMentionItem(value: 'bob', label: 'Bob'),
///   ],
///   onChanged: (text) => print(text),
/// )
/// ```
class ParkMentions extends StatefulWidget {
  /// 建议数据源。
  final List<ParkMentionItem> items;

  /// 受控值（传入时为受控模式，由外部维护 value）。
  final String? value;

  /// 文本变更回调（输出含标记语法的文本）。
  final ValueChanged<String>? onChanged;

  /// 触发符列表（默认 ['@']，可配置为 ['@', '#']）。
  final List<String> triggerChars;

  /// 占位符；为空时回退到 [ParkLocalizations.inputPlaceholder]。
  final String? placeholder;

  /// 是否启用，默认 true。
  final bool enabled;

  /// 最大行数（多行文本）。
  final int? maxLines;

  /// 最小行数（多行文本）。
  final int? minLines;

  /// 触发搜索回调（命中触发符并输入查询时触发）。
  final void Function(String query, String trigger)? onSearch;

  /// 选中条目回调。
  final void Function(ParkMentionItem item, String trigger)? onSelect;

  /// 自定义过滤逻辑（默认按 label / value 包含匹配，忽略大小写）。
  final bool Function(String query, ParkMentionItem item)? filterOption;

  /// 自定义插入文本（默认 `@value` 后补一个空格）。
  final String Function(ParkMentionItem item, String trigger)? mentionBuilder;

  /// 弹出面板最大高度（默认 240）。
  final double popupMaxHeight;

  const ParkMentions({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.triggerChars = const <String>['@'],
    this.placeholder,
    this.enabled = true,
    this.maxLines,
    this.minLines,
    this.onSearch,
    this.onSelect,
    this.filterOption,
    this.mentionBuilder,
    this.popupMaxHeight = 240.0,
  });

  @override
  State<ParkMentions> createState() => _ParkMentionsState();
}

class _ParkMentionsState extends State<ParkMentions> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  String? _activeTrigger;
  List<ParkMentionItem> _filtered = <ParkMentionItem>[];
  int _selectedIndex = 0;
  final ScrollController _popupScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ParkMentions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 受控模式：外部 value 变化时同步文本（仅在确有差异时，避免光标跳动）。
    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _hidePanel();
  }

  // --------------------------------------------------------------------------
  // 触发符检测：在光标前定位最近的有效触发符，提取查询串。
  // --------------------------------------------------------------------------

  _MentionContext? _detectContext() {
    final String text = _controller.text;
    final int caret = _controller.selection.isValid
        ? _controller.selection.baseOffset
        : text.length;
    if (caret < 0 || caret > text.length) return null;
    final String before = text.substring(0, caret);

    int bestIndex = -1;
    String bestTrigger = '';
    for (final String t in widget.triggerChars) {
      final int idx = before.lastIndexOf(t);
      if (idx >= 0 && idx > bestIndex) {
        bestIndex = idx;
        bestTrigger = t;
      }
    }
    if (bestIndex < 0) return null;

    // 触发符前需为行首或空白，避免把普通词内的 '@' 当作提及（如邮箱）。
    if (bestIndex > 0) {
      final String charBefore = before[bestIndex - 1];
      if (!charBefore.contains(RegExp(r'\s'))) return null;
    }

    final String query = before.substring(bestIndex + 1);
    // 查询串内出现空白则视为已结束当前提及。
    if (query.contains(RegExp(r'\s'))) return null;

    return _MentionContext(trigger: bestTrigger, triggerIndex: bestIndex, query: query);
  }

  void _refreshPanel() {
    if (!widget.enabled) {
      _hidePanel();
      return;
    }
    final _MentionContext? ctx = _detectContext();
    if (ctx == null) {
      _hidePanel();
      return;
    }

    final bool Function(String, ParkMentionItem) filter =
        widget.filterOption ??
        (String q, ParkMentionItem item) {
          final String lower = q.toLowerCase();
          return item.label.toLowerCase().contains(lower) ||
              item.value.toLowerCase().contains(lower);
        };

    final List<ParkMentionItem> filtered =
        widget.items.where((ParkMentionItem i) => filter(ctx.query, i)).toList();

    setState(() {
      _activeTrigger = ctx.trigger;
      _filtered = filtered;
      _selectedIndex = 0;
    });

    widget.onSearch?.call(ctx.query, ctx.trigger);

    if (filtered.isEmpty) {
      _hidePanel();
    } else {
      _showPanel();
    }
  }

  // --------------------------------------------------------------------------
  // 下拉面板（Overlay，定位在输入框下方，宽度与输入框一致）。
  // --------------------------------------------------------------------------

  void _showPanel() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(builder: (_) => _buildPanel());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePanel() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildPanel() {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return const SizedBox.shrink();
    final RenderBox box = renderObject;
    final Offset offset = box.localToGlobal(Offset.zero);

    final l10n = ParkLocalizations.of(context);

    return Positioned(
      left: offset.dx,
      top: offset.dy + box.size.height + park.spacing.xs,
      width: box.size.width,
      child: Material(
        elevation: 0,
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.popupMaxHeight),
          decoration: BoxDecoration(
            color: park.colors.surface,
            borderRadius: park.radius.brMd,
            border: Border.all(color: park.colors.border),
            boxShadow: park.shadows.md,
          ),
          child: _filtered.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(park.spacing.base),
                  child: Text(
                    l10n.noData,
                    style: TextStyle(
                      fontSize: park.typography.sizeBodySmall,
                      color: park.colors.textSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _popupScroll,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: park.spacing.xs),
                  itemCount: _filtered.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ParkMentionItem item = _filtered[index];
                    final bool highlighted = index == _selectedIndex;
                    return _MentionOptionTile(
                      item: item,
                      highlighted: highlighted,
                      park: park,
                      onTap: item.disabled ? null : () => _insertMention(item),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 选中插入。
  // --------------------------------------------------------------------------

  void _insertMention(ParkMentionItem item) {
    if (item.disabled) return;
    final String trigger = _activeTrigger ?? widget.triggerChars.first;
    final _MentionContext? ctx = _detectContext();
    final int triggerIndex = ctx?.triggerIndex ?? 0;
    final int caret = _controller.selection.isValid
        ? _controller.selection.baseOffset
        : _controller.text.length;

    final String inserted =
        widget.mentionBuilder?.call(item, trigger) ?? '$trigger${item.value} ';

    final String newText = _controller.text.replaceRange(
      triggerIndex,
      caret,
      inserted,
    );
    final int newCaret = triggerIndex + inserted.length;

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCaret),
    );
    _hidePanel();
    widget.onChanged?.call(newText);
    widget.onSelect?.call(item, trigger);
    _focusNode.requestFocus();
  }

  // --------------------------------------------------------------------------
  // 键盘导航（仅在面板展开时拦截上下 / 回车）。
  // --------------------------------------------------------------------------

  void _onKeyEvent(KeyEvent event) {
    if (_overlayEntry == null || _filtered.isEmpty) return;
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _filtered.length;
      });
      _scrollToSelected();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex =
            (_selectedIndex - 1 + _filtered.length) % _filtered.length;
      });
      _scrollToSelected();
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _insertMention(_filtered[_selectedIndex]);
    }
  }

  void _scrollToSelected() {
    if (!_popupScroll.hasClients) return;
    const double itemHeight = 44.0;
    _popupScroll.animateTo(
      _selectedIndex * itemHeight,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hidePanel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    _popupScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final String placeholder =
        widget.placeholder ?? ParkLocalizations.of(context).inputPlaceholder;

    final InputBorder border = OutlineInputBorder(
      borderRadius: park.radius.brSm,
      borderSide: BorderSide(color: park.colors.border),
    );

    return Semantics(
      label: placeholder,
      enabled: widget.enabled,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: _onKeyEvent,
        child: TextField(
          controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        onChanged: (String value) {
          widget.onChanged?.call(value);
          _refreshPanel();
        },
        onTap: () => _refreshPanel(),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textPlaceholder,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: park.radius.brSm,
            borderSide: BorderSide(color: park.colors.brand),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: park.spacing.md,
            vertical: park.spacing.sm,
          ),
        ),
        style: TextStyle(
          fontSize: park.typography.sizeBody,
          color: park.colors.textPrimary,
        ),
      ),
      ),
    );
  }
}

/// 提及上下文（触发符 + 位置 + 查询串）。
class _MentionContext {
  final String trigger;
  final int triggerIndex;
  final String query;

  const _MentionContext({
    required this.trigger,
    required this.triggerIndex,
    required this.query,
  });
}

/// 下拉面板中的单个建议项。
class _MentionOptionTile extends StatelessWidget {
  final ParkMentionItem item;
  final bool highlighted;
  final ParkThemeData park;
  final VoidCallback? onTap;

  const _MentionOptionTile({
    required this.item,
    required this.highlighted,
    required this.park,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = highlighted
        ? park.colors.brandLight
        : park.colors.surface;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: park.spacing.md),
        color: bg,
        child: Row(
          children: <Widget>[
            if (item.avatar != null) ...<Widget>[
              item.avatar!,
              SizedBox(width: park.spacing.sm),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: park.typography.sizeBodySmall,
                  color: item.disabled
                      ? park.colors.textDisabled
                      : park.colors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.value != item.label)
              Padding(
                padding: EdgeInsets.only(left: park.spacing.sm),
                child: Text(
                  '@${item.value}',
                  style: TextStyle(
                    fontSize: park.typography.sizeCaption,
                    color: park.colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
