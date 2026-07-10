import 'package:flutter/material.dart';
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
  OverlayEntry? _overlayEntry;
  List<String> _filtered = [];

  bool get _hasInput => _controller.text.isNotEmpty;

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);
    if (value.isEmpty) {
      _hideSuggestions();
      return;
    }
    final fn = widget.filterFn ?? ((input, opt) => opt.toLowerCase().contains(input.toLowerCase()));
    _filtered = widget.options.where((opt) => fn(value, opt)).take(widget.maxSuggestions).toList();
    if (_filtered.isEmpty) {
      _hideSuggestions();
    } else {
      _showSuggestions();
    }
  }

  void _showSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(builder: (_) => _buildDropdown());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
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
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final height = renderBox.size.height;

    return Positioned(
      left: offset.dx,
      top: offset.dy + height + 4,
      width: renderBox.size.width,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: park.colors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: park.colors.border),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filtered.length,
            itemBuilder: (_, i) => InkWell(
              onTap: () => _select(_filtered[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(_filtered[i], style: TextStyle(fontSize: 14, color: park.colors.textPrimary)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _hideSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText ?? '请输入搜索',
            hintStyle: TextStyle(fontSize: 14, color: park.colors.textPlaceholder),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: park.colors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: park.colors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: _hasInput
                ? IconButton(icon: Icon(Icons.close, size: 16), onPressed: () { _controller.clear(); _onTextChanged(''); })
                : null,
          ),
          onChanged: _onTextChanged,
          onTap: () { if (_hasInput) _onTextChanged(_controller.text); },
        ),
      ],
    );
  }
}
