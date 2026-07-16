import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

// ============================================================================
// ParkColorFormat — 颜色展示/输入格式
// ============================================================================

/// 颜色展示/输入格式。
enum ParkColorFormat {
  /// 十六进制格式，如 #FF0000。
  hex,

  /// RGB 格式，如 rgb(255, 0, 0)。
  rgb,

  /// HSB 格式，如 hsb(0, 100%, 100%)。
  hsb,
}

// ============================================================================
// 颜色格式工具函数
// ============================================================================

/// 将 [color] 按 [format] 格式化为可读字符串。
String _formatColor(Color color, ParkColorFormat format) {
  switch (format) {
    case ParkColorFormat.hex:
      final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');
      return '#${hex.substring(2)}';
    case ParkColorFormat.rgb:
      final r = (color.r * 255.0).round().clamp(0, 255);
      final g = (color.g * 255.0).round().clamp(0, 255);
      final b = (color.b * 255.0).round().clamp(0, 255);
      return 'rgb($r, $g, $b)';
    case ParkColorFormat.hsb:
      final hsv = HSVColor.fromColor(color);
      final h = (hsv.hue.round()).toString();
      final s = (hsv.saturation * 100).round().toString();
      final b = (hsv.value * 100).round().toString();
      return 'hsb($h, $s%, $b%)';
  }
}

/// 颜色格式标签（用于切换按钮显示）。
String _formatLabel(ParkColorFormat format) {
  switch (format) {
    case ParkColorFormat.hex:
      return 'HEX';
    case ParkColorFormat.rgb:
      return 'RGB';
    case ParkColorFormat.hsb:
      return 'HSB';
  }
}

// ============================================================================
// ParkColorPickerHueSliderPainter — 色相渐变条绘制器
// ============================================================================

/// 绘制水平色相渐变条（0°–360°）及当前选中指示器。
class ParkColorPickerHueSliderPainter extends CustomPainter {
  /// 当前色相角度（0–360）。
  final double hue;

  /// 当前选中颜色的 HSVColor（用于指示器填充色）。
  final HSVColor currentHsv;

  ParkColorPickerHueSliderPainter({required this.hue, required this.currentHsv});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.height / 2;

    // ── 色相渐变背景 ──
    final gradient = LinearGradient(
      stops: const [0.0, 1 / 6, 2 / 6, 3 / 6, 4 / 6, 5 / 6, 1.0],
      colors: [
        HSVColor.fromAHSV(1, 0, 1, 1).toColor(),
        HSVColor.fromAHSV(1, 60, 1, 1).toColor(),
        HSVColor.fromAHSV(1, 120, 1, 1).toColor(),
        HSVColor.fromAHSV(1, 180, 1, 1).toColor(),
        HSVColor.fromAHSV(1, 240, 1, 1).toColor(),
        HSVColor.fromAHSV(1, 300, 1, 1).toColor(),
        HSVColor.fromAHSV(1, 360, 1, 1).toColor(),
      ],
    );

    final bgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      bgPaint,
    );

    // ── 指示器圆点 ──
    final indicatorX = (hue / 360.0) * size.width;
    final center = Offset(indicatorX.clamp(radius, size.width - radius), size.height / 2);

    // 白色外圈
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9, outerPaint);

    // 颜色内圈
    final innerPaint = Paint()
      ..color = currentHsv.toColor()
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 7, innerPaint);

    // 阴影边框
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 9, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ParkColorPickerHueSliderPainter old) =>
      old.hue != hue || old.currentHsv != currentHsv;
}

// ============================================================================
// ParkColorPickerHueSlider — 色相条 Widget
// ============================================================================

/// 可拖拽的色相选择条。
class ParkColorPickerHueSlider extends StatelessWidget {
  final double hue;
  final HSVColor currentHsv;
  final ValueChanged<double> onChanged;

  const ParkColorPickerHueSlider({
    super.key,
    required this.hue,
    required this.currentHsv,
    required this.onChanged,
  });

  void _handlePosition(double dx, double width) {
    final clamped = (dx / width).clamp(0.0, 1.0);
    onChanged(clamped * 360.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.hueSliderSemantic(hue.round()),
      slider: true,
      value: '${hue.round()}°',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            onTapDown: (details) => _handlePosition(details.localPosition.dx, width),
            onPanStart: (details) => _handlePosition(details.localPosition.dx, width),
            onPanUpdate: (details) => _handlePosition(
              details.localPosition.dx.clamp(0, width),
              width,
            ),
            child: CustomPaint(
              size: Size(width, 20),
              painter: ParkColorPickerHueSliderPainter(hue: hue, currentHsv: currentHsv),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// ParkColorPickerSaturationValuePainter — 饱和度/明度方形面板绘制器
// ============================================================================

/// 绘制二维饱和度（横轴）与明度（纵轴）选择面板。
///
/// 采用三层叠加渐变：
/// 1. 纯色底色（当前色相，满饱和度+明度）
/// 2. 水平左→右 白色→透明（控制饱和度）
/// 3. 垂直上→下 透明→黑色（控制明度）
class ParkColorPickerSaturationValuePainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;

  ParkColorPickerSaturationValuePainter({
    required this.hue,
    required this.saturation,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. 纯色底色（当前色相，满饱和度+明度）
    final hueColor = HSVColor.fromAHSV(1, hue, 1.0, 1.0).toColor();
    canvas.drawRect(rect, Paint()..color = hueColor);

    // 2. 水平渐变：左→右 白色→透明（控制饱和度）
    final satGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.white, Colors.transparent],
    );
    final satPaint = Paint()..shader = satGradient.createShader(rect);
    canvas.drawRect(rect, satPaint);

    // 3. 垂直渐变：上→下 透明→黑色（控制明度）
    final valGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black],
    );
    final valPaint = Paint()..shader = valGradient.createShader(rect);
    canvas.drawRect(rect, valPaint);

    // 4. 指示器
    final indicatorX = saturation * size.width;
    final indicatorY = (1.0 - value) * size.height;
    final center = Offset(indicatorX, indicatorY);

    // 白色外圈
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9, outerPaint);

    // 颜色内圈
    final innerColor = HSVColor.fromAHSV(1, hue, saturation, value).toColor();
    final innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, innerPaint);

    // 阴影边框
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 9, borderPaint);
  }

  @override
  bool shouldRepaint(covariant ParkColorPickerSaturationValuePainter old) =>
      old.hue != hue || old.saturation != saturation || old.value != value;
}

// ============================================================================
// ParkColorPickerSaturationValuePicker — 饱和度/明度面板 Widget
// ============================================================================

/// 可拖拽的二维饱和度/明度选择面板。
class ParkColorPickerSaturationValuePicker extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final ValueChanged<HSVColor> onChanged;

  const ParkColorPickerSaturationValuePicker({
    super.key,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  void _handlePosition(Offset localPosition, Size size) {
    final s = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final v = (1.0 - localPosition.dy / size.height).clamp(0.0, 1.0);
    onChanged(HSVColor.fromAHSV(1, hue, s, v));
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Semantics(
      label: ParkLocalizations.of(context).saturationValuePickerLabel,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: park.radius.brSm,
          border: Border.all(color: park.colors.border.withValues(alpha: 0.4)),
        ),
        child: ClipRRect(
          borderRadius: park.radius.brSm,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 宽度用满，高度保持正方形但不超过 200px
              final panelSize = constraints.maxWidth;
              final height = panelSize > 200.0 ? 200.0 : panelSize;
              final size = Size(panelSize, height);
              return GestureDetector(
                onTapDown: (details) =>
                    _handlePosition(details.localPosition, size),
                onPanStart: (details) =>
                    _handlePosition(details.localPosition, size),
                onPanUpdate: (details) =>
                    _handlePosition(details.localPosition, size),
                child: CustomPaint(
                  size: size,
                  painter: ParkColorPickerSaturationValuePainter(
                    hue: hue,
                    saturation: saturation,
                    value: value,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ParkColorPicker
// ============================================================================

/// 颜色选择器组件。
///
/// 支持预设色块、自定义 HSV 取色面板和格式切换。
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

  /// 预设颜色列表（默认 `null`，使用内置 20 色环）。
  ///
  /// 传入空列表 `[]` 可隐藏预设色板区域。
  final List<Color>? presetColors;

  /// 是否启用自定义 HSV 面板（默认 true）。
  ///
  /// 为 true 时在预设色板下方渲染色相条 + 饱和度/明度面板。
  final bool enableCustom;

  /// 是否在底部显示 HEX / RGB / HSB 格式切换按钮（默认 false）。
  final bool showFormatSwitch;

  /// 当前颜色展示/输入格式（默认 [ParkColorFormat.hex]）。
  final ParkColorFormat format;

  /// 创建 [ParkColorPicker]。
  const ParkColorPicker({
    super.key,
    this.value,
    this.onChanged,
    this.presetColors,
    this.enableCustom = true,
    this.showFormatSwitch = false,
    this.format = ParkColorFormat.hex,
  });

  @override
  State<ParkColorPicker> createState() => _ParkColorPickerState();
}

class _ParkColorPickerState extends State<ParkColorPicker> {
  late Color _selected;
  late ParkColorFormat _format;

  // HSV 面板状态
  late double _hue;
  late double _saturation;
  late double _value;

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
    _format = widget.format;
    _syncHsvFromColor(_selected);
  }

  @override
  void didUpdateWidget(ParkColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      _selected = widget.value!;
      _syncHsvFromColor(_selected);
    }
    if (widget.format != oldWidget.format) {
      _format = widget.format;
    }
  }

  /// 从 [color] 同步 HSV 状态变量。
  void _syncHsvFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  /// 当前显示的预设色板（null 表示不展示预设区域）。
  List<Color>? get _presets {
    // 向后兼容：presetColors == null 且 showFormatSwitch == false 时
    // 使用内置默认色板（行为不变）。
    if (widget.presetColors == null && !widget.showFormatSwitch) {
      return _defaultPresets;
    }
    // 否则按传入值展示；null → 不展示预设区域。
    return widget.presetColors;
  }

  void _selectColor(Color color) {
    setState(() {
      _selected = color;
      _syncHsvFromColor(color);
    });
    widget.onChanged?.call(color);
  }

  void _updateFromHsv(HSVColor hsv) {
    final color = hsv.toColor();
    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _selected = color;
    });
    widget.onChanged?.call(color);
  }

  void _updateHue(double newHue) {
    final hsv = HSVColor.fromAHSV(1, newHue, _saturation, _value);
    _updateFromHsv(hsv);
  }

  void _switchFormat(ParkColorFormat format) {
    setState(() => _format = format);
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 当前选中色预览 ──
        Semantics(
          label: ParkLocalizations.of(context).currentColorSemantic(_formatColor(_selected, _format)),
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: _selected,
              borderRadius: park.radius.brSm,
              border: Border.all(color: park.colors.border),
            ),
          ),
        ),

        // ── 颜色格式文字标签 ──
        Padding(
          padding: EdgeInsets.only(top: park.spacing.xs),
          child: Semantics(
            label: ParkLocalizations.of(context).colorValueSemantic(_formatColor(_selected, _format)),
            child: Text(
              _formatColor(_selected, _format),
              style: park.typography.bodySmall.copyWith(
                color: park.colors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),

        // ── 预设色块 ──
        if (_presets != null && _presets!.isNotEmpty) ...[
          park.spacing.vSm,
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presets!.map((color) {
              final isActive = _selected.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => _selectColor(color),
                child: Semantics(
                  button: true,
                  label: _formatColor(color, ParkColorFormat.hex),
                  selected: isActive,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: park.radius.brXs,
                      border: Border.all(
                        color: isActive
                            ? park.colors.brand
                            : (park.colors.border.withValues(alpha: 0.5)),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: isActive
                        ? Icon(Icons.check, size: 16, color: park.colors.textOnBrand)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        // ── 自定义 HSV 面板 ──
        if (widget.enableCustom) ...[
          park.spacing.vSm,
          ParkColorPickerSaturationValuePicker(
            hue: _hue,
            saturation: _saturation,
            value: _value,
            onChanged: _updateFromHsv,
          ),
          park.spacing.vXs,
          ParkColorPickerHueSlider(
            hue: _hue,
            currentHsv: HSVColor.fromAHSV(1, _hue, _saturation, _value),
            onChanged: _updateHue,
          ),
        ],

        // ── 格式切换 ──
        if (widget.showFormatSwitch) ...[
          park.spacing.vSm,
          Semantics(
            label: ParkLocalizations.of(context).colorFormatSwitch,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ParkColorFormat.values.map((format) {
                final isActive = _format == format;
                final l10n = ParkLocalizations.of(context);
                return GestureDetector(
                  onTap: () => _switchFormat(format),
                  child: Semantics(
                    button: true,
                    label: l10n.switchToFormat(format.name.toUpperCase()),
                    selected: isActive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? park.colors.brand : Colors.transparent,
                        borderRadius: park.radius.brXs,
                        border: Border.all(
                          color: isActive
                              ? park.colors.brand
                              : park.colors.border,
                        ),
                      ),
                      child: Text(
                        _formatLabel(format),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? park.colors.textOnBrand
                              : park.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
