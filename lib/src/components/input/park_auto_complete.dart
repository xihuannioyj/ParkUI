import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 自动完成输入组件
///
/// 输入时弹出候选建议列表，支持异步加载和自定义过滤。
/// 基于 ParkInput 扩展。
///
/// ```dart
/// ParkAutoComplete(
///   options: ['apple', 'banana', 'cherry'],
///   onSelected: (value) => print('选中: $value'),
/// )
/// ```
class ParkAutoComplete extends StatefulWidget {
  /// 候选建议列表。
  final List<String> options;

  /// 选中回调。
  final ValueChanged<String>? onSelected;

  /// 自定义过滤函数（默认包含匹配）。
  final bool Function(String input, String option)? filterFn;

  /// 输入变化回调。
  final ValueChanged<String>? onChanged;

  /// 最大显示建议数（默认 6）。
  final int maxSuggestions;

  /// 占位文字。
  final String? hintText;

  /// 创建 [ParkAutoComplete]。
  const ParkAutoComplete({
    super.key,
    required this.options,
    this.onSelected,
    this.filterFn,
    this.onChanged,
    this.maxSuggestions = 6,
    this.hintText,
  });

  @override
  State<ParkAutoComplete> createState() => _ParkAutoCompleteState();
}

class _ParkAutoCompleteState extends State<ParkAutoComplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filtered = [];
  Timer? _debounceTimer;

  bool get _hasInput => _controller.text.isNotEmpty;

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);
    if (value.isEmpty) {
      _debounceTimer?.cancel();
      _hideSuggestions();
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final fn = widget.filterFn ?? ((input, opt) => opt.toLowerCase().contains(input.toLowerCase()));
      _filtered = widget.options.where((opt) => fn(value, opt)).take(widget.maxSuggestions).toList();
      if (_filtered.isEmpty) {
        _hideSuggestions();
      } else {
        _showSuggestions();
      }
    });
  }

  void _showSuggestions() {
    if (!mounted) return;
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(builder: (_) => _buildDropdown());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    if (!mounted) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _select(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: value.length));
    _hideSuggestions();
    widget.onSelected?.call(value);
  }

  Widget _buildDropdown() {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final double inputWidth = renderBox?.size.width ?? 200;

    return CompositedTransformFollower(
      link: _layerLink,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      offset: const Offset(0, 4),
      child: SizedBox(
        width: inputWidth,
        child: Material(
          elevation: 8,
          borderRadius: park.radius.brSm,
          shadowColor: park.colors.textPrimary.withValues(alpha: 0.12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: park.colors.surface,
              borderRadius: park.radius.brSm,
              border: Border.all(color: park.colors.border),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (_, i) => Semantics(
                button: true,
                label: _filtered[i],
                child: InkWell(
                  onTap: () => _select(_filtered[i]),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: park.spacing.md, vertical: park.spacing.sm + 2),
                    child: Text(_filtered[i], style: TextStyle(fontSize: park.typography.sizeBodySmall, color: park.colors.textPrimary)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _hideSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText ?? l10n.searchHintText,
              hintStyle: TextStyle(fontSize: park.typography.sizeBodySmall, color: park.colors.textPlaceholder),
              border: OutlineInputBorder(borderRadius: park.radius.brSm, borderSide: BorderSide(color: park.colors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: park.radius.brSm, borderSide: BorderSide(color: park.colors.border)),
              contentPadding: EdgeInsets.symmetric(horizontal: park.spacing.md, vertical: park.spacing.sm + 2),
              suffixIcon: _hasInput
                  ? Semantics(
                      button: true,
                      label: l10n.clearText,
                      child: IconButton(icon: Icon(Icons.close, size: 16), onPressed: () { _controller.clear(); _onTextChanged(''); }),
                    )
                  : null,
            ),
            onChanged: _onTextChanged,
            onTap: () { if (_hasInput) _onTextChanged(_controller.text); },
          ),
        ],
      ),
    );
  }
}
