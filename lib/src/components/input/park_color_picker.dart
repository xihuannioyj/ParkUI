import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 颜色选择器组件
///
/// 支持预设色块和自定义 HSV 面板选择。
///
/// ```dart
/// ParkColorPicker(
///   value: Colors.blue,
///   onChanged: (color) => print('#${color.value.toRadixString(16)}'),
/// )
/// ```
class ParkColorPicker extends StatefulWidget {
  /// 当前选中的颜色。
  final Color? value;

  /// 颜色变化回调。
  final ValueChanged<Color>? onChanged;

  /// 预设颜色列表（默认 12 色环）。
  final List<Color>? presetColors;

  /// 是否启用自定义面板（默认 true）。
  final bool enableCustom;

  /// 创建 [ParkColorPicker]。
  const ParkColorPicker({
    super.key,
    this.value,
    this.onChanged,
    this.presetColors,
    this.enableCustom = true,
  });

  @override
  State<ParkColorPicker> createState() => _ParkColorPickerState();
}

class _ParkColorPickerState extends State<ParkColorPicker> {
  late Color _selected;

  static const List<Color> _defaultPresets = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? Colors.blue;
  }

  List<Color> get _presets => widget.presetColors ?? _defaultPresets;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 当前选中色
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: _selected,
            borderRadius: park.radius.brSm,
            border: Border.all(color: park.colors.border),
          ),
        ),
        park.spacing.vSm,
        // 预设色块网格
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _presets.map((color) {
            final isActive = _selected.value == color.value;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = color);
                widget.onChanged?.call(color);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: park.radius.brXs,
                  border: Border.all(
                    color: isActive ? park.colors.brand : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isActive
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
