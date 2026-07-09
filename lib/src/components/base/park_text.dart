import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/park_theme_data.dart';

/// Park 文本预设类型
enum ParkTextPreset {
  /// 超大标题（36px）
  display,

  /// 一级标题（28px）
  h1,

  /// 二级标题（22px）
  h2,

  /// 三级标题（18px）
  h3,

  /// 正文（14px）
  body,

  /// 小号正文（12px）
  bodySmall,

  /// 辅助文字（12px，次要色）
  caption,

  /// 超小文字（10px，标签/角标）
  overline,
}

/// Park 文本语义类型
enum ParkTextType {
  /// 次要文本
  secondary,

  /// 成功状态文本
  success,

  /// 警告状态文本
  warning,

  /// 危险/错误状态文本
  danger,
}

/// Park 文本断行方式
enum ParkWordBreak {
  /// 常规断行（默认）
  normal,

  /// 在任意字符间断行
  breakAll,

  /// 仅在单词边界断行
  breakWord,
}

/// Park 文本组件
///
/// 在 Flutter 原生 [Text] 基础上增加：
/// - 预设样式（display / h1 / h2 / h3 / body / caption / overline）
/// - 内置 maxLines + ellipsis 处理
/// - 主题色自动跟随
/// - 可选 selectable 模式
/// - 可复制（copyable）模式
/// - 文本装饰（strikethrough / underline）
/// - 高亮背景（highlight）
/// - 富文本混排（richSpans）
/// - 可展开/收起（expandable）
///
/// ```dart
/// ParkText('标题', preset: ParkTextPreset.h1)
/// ParkText('描述文字', preset: ParkTextPreset.body, color: Colors.grey)
/// ParkText('很长很长的文字...', maxLines: 2)
/// ParkText('可复制文本', copyable: true)
/// ParkText('已删除', strikethrough: true)
/// ```
class ParkText extends StatefulWidget {
  /// 文本内容
  final String data;

  /// 预设样式（与 [style] 同时存在时，[style] 优先）
  final ParkTextPreset? preset;

  /// 自定义样式（完全覆盖预设）
  final TextStyle? style;

  /// 文字颜色（覆盖预设和主题默认色）
  final Color? color;

  /// 文字大小（覆盖预设）
  final double? fontSize;

  /// 字重（覆盖预设）
  final FontWeight? fontWeight;

  /// 最大行数（超出自动 ellipsis）
  final int? maxLines;

  /// 是否可选中复制
  final bool selectable;

  /// 文本对齐
  final TextAlign? textAlign;

  /// 文本方向
  final TextDirection? textDirection;

  /// 溢出方式（默认 ellipsis）
  final TextOverflow? overflow;

  /// 语义标签（无障碍）
  final String? semanticsLabel;

  /// 是否可复制（显示复制图标，点击复制到剪贴板并显示"已复制"反馈）
  final bool copyable;

  /// 是否添加删除线
  final bool strikethrough;

  /// 是否添加下划线
  final bool underline;

  /// 是否高亮背景（黄色高亮）
  final bool highlight;

  /// 富文本 spans（提供后使用 Rich.Text 渲染，允许混排粗体/斜体/彩色文本）
  final List<InlineSpan>? richSpans;

  /// 是否可展开/收起
  final bool expandable;

  /// 收起状态下最大行数
  final int maxLinesCollapsed;

  /// 语义类型（secondary / success / warning / danger），自动应用对应颜色
  final ParkTextType? type;

  /// 是否使用等宽字体并添加代码块背景
  final bool code;

  /// 是否使用斜体
  final bool italic;

  /// 是否加粗（bold 快捷方式）
  final bool strong;

  /// 是否禁用（灰色显示）
  final bool disabled;

  /// 自定义高亮颜色（覆盖默认黄色高亮）
  final Color? markColor;

  /// 点击回调
  final VoidCallback? onClick;

  /// 自定义展开按钮文字（默认为"展开"）
  final String? expandText;

  /// 自定义收起按钮文字（默认为"收起"）
  final String? collapseText;

  /// 复制成功后的回调
  final VoidCallback? onCopy;

  /// 是否启用省略号（为 true 时自动设置 maxLines=1 + ellipsis）
  final bool ellipsis;

  /// 文本断行方式
  final ParkWordBreak wordBreak;

  const ParkText(
    this.data, {
    super.key,
    this.preset,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.selectable = false,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.semanticsLabel,
    this.copyable = false,
    this.strikethrough = false,
    this.underline = false,
    this.highlight = false,
    this.richSpans,
    this.expandable = false,
    this.maxLinesCollapsed = 2,
    this.type,
    this.code = false,
    this.italic = false,
    this.strong = false,
    this.disabled = false,
    this.markColor,
    this.onClick,
    this.expandText,
    this.collapseText,
    this.onCopy,
    this.ellipsis = false,
    this.wordBreak = ParkWordBreak.normal,
  });

  @override
  State<ParkText> createState() => _ParkTextState();
}

class _ParkTextState extends State<ParkText> {
  bool _expanded = false;
  bool _showCopiedFeedback = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.data));
    widget.onCopy?.call();
    if (!mounted) return;
    setState(() => _showCopiedFeedback = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCopiedFeedback = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;

    // 从预设获取基础样式
    final baseStyle = widget.preset != null ? _presetStyle(widget.preset!, typo) : typo.body;

    // 解析语义类型颜色
    Color? typeColor;
    switch (widget.type) {
      case ParkTextType.secondary:
        typeColor = colors.textSecondary;
        break;
      case ParkTextType.success:
        typeColor = colors.success;
        break;
      case ParkTextType.warning:
        typeColor = colors.warning;
        break;
      case ParkTextType.danger:
        typeColor = colors.error;
        break;
      case null:
        typeColor = null;
        break;
    }

    // 解析禁用颜色
    final effectiveColor = widget.disabled
        ? colors.textDisabled
        : (widget.color ?? typeColor ?? colors.textPrimary);

    // 解析字重（strong 优先）
    final effectiveFontWeight = widget.strong
        ? FontWeight.bold
        : (widget.fontWeight);

    // 解析字体样式（italic）
    final effectiveFontStyle = widget.italic ? FontStyle.italic : FontStyle.normal;

    // 解析等宽字体（code）
    final effectiveFontFamily = widget.code ? 'monospace' : null;

    // 合并覆盖
    final effectiveStyle = widget.style ??
        baseStyle.copyWith(
          color: effectiveColor,
          fontSize: widget.fontSize,
          fontWeight: effectiveFontWeight,
          fontStyle: effectiveFontStyle,
          fontFamily: effectiveFontFamily,
        );

    // 如果有 fontSize/fontWeight 覆盖但用了 style，也要合并
    final mergedStyle = widget.style != null
        ? widget.style!.copyWith(
            color: effectiveColor,
            fontSize: widget.fontSize ?? widget.style!.fontSize,
            fontWeight: effectiveFontWeight ?? widget.style!.fontWeight,
            fontStyle: widget.italic ? FontStyle.italic : (widget.style!.fontStyle),
            fontFamily: effectiveFontFamily ?? widget.style!.fontFamily,
          )
        : effectiveStyle;

    // 应用文本装饰
    TextDecoration? decoration;
    if (widget.strikethrough && widget.underline) {
      decoration = TextDecoration.combine([
        TextDecoration.lineThrough,
        TextDecoration.underline,
      ]);
    } else if (widget.strikethrough) {
      decoration = TextDecoration.lineThrough;
    } else if (widget.underline) {
      decoration = TextDecoration.underline;
    }

    final finalStyle = decoration != null
        ? mergedStyle.copyWith(
            decoration: decoration,
            decorationColor: mergedStyle.color,
          )
        : mergedStyle;

    // 高亮背景（支持自定义 markColor）
    final highlightColor =
        widget.highlight ? (widget.markColor ?? const Color(0xFFFFF59D)) : null;

    // code 模式背景色
    final codeBgColor = widget.code
        ? Color.lerp(colors.surface, colors.textPrimary, 0.06)!
        : null;

    final effectiveHighlight = highlightColor ?? codeBgColor;
    final bgDecoratedStyle = effectiveHighlight != null
        ? finalStyle.copyWith(
            backgroundColor: effectiveHighlight,
          )
        : finalStyle;

    // 展开/收起逻辑
    final effectiveMaxLines = widget.expandable
        ? (_expanded ? null : widget.maxLinesCollapsed)
        : widget.ellipsis
            ? 1
            : widget.maxLines;
    final effectiveOverflow = widget.expandable
        ? (_expanded ? null : TextOverflow.ellipsis)
        : widget.ellipsis
            ? TextOverflow.ellipsis
            : (widget.overflow ??
                (effectiveMaxLines != null ? TextOverflow.ellipsis : null));

    Widget textWidget;

    // richSpans 模式
    if (widget.richSpans != null && widget.richSpans!.isNotEmpty) {
      textWidget = RichText(
        text: TextSpan(
          style: bgDecoratedStyle,
          children: widget.richSpans!,
        ),
        maxLines: effectiveMaxLines,
        overflow: effectiveOverflow ?? TextOverflow.clip,
        textAlign: widget.textAlign ?? TextAlign.start,
        textDirection: widget.textDirection,
      );
    } else if (widget.selectable) {
      textWidget = SelectableText(
        widget.data,
        style: bgDecoratedStyle,
        maxLines: effectiveMaxLines,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        semanticsLabel: widget.semanticsLabel,
      );
    } else {
      textWidget = Text(
        widget.data,
        style: bgDecoratedStyle,
        maxLines: effectiveMaxLines,
        overflow: effectiveOverflow,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        semanticsLabel: widget.semanticsLabel,
      );
    }

    // 展开/收起链接
    Widget? expandToggle;
    if (widget.expandable) {
      expandToggle = GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            _expanded
                ? (widget.collapseText ?? '收起')
                : (widget.expandText ?? '展开'),
            style: TextStyle(
              color: colors.brand,
              fontSize: bgDecoratedStyle.fontSize ?? 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    // 复制图标
    Widget? copyIcon;
    if (widget.copyable) {
      copyIcon = GestureDetector(
        onTap: _copyToClipboard,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.copy,
                size: (bgDecoratedStyle.fontSize ?? 14) * 0.9,
                color: colors.textSecondary,
              ),
              if (_showCopiedFeedback) ...[
                const SizedBox(width: 2),
                Text(
                  '已复制',
                  style: TextStyle(
                    color: colors.success,
                    fontSize: (bgDecoratedStyle.fontSize ?? 14) * 0.85,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 如果没有任何附加 widget，直接返回文本
    Widget result;
    if (expandToggle == null && copyIcon == null) {
      result = textWidget;
    } else {
      // 用 Row 包裹文本和附加 widget
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: textWidget),
              ?copyIcon,
            ],
          ),
          if (expandToggle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: expandToggle,
            ),
        ],
      );
    }

    // onClick 回调包裹
    if (widget.onClick != null && !widget.disabled) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onClick,
          behavior: HitTestBehavior.opaque,
          child: result,
        ),
      );
    }

    // 禁用态透明度
    if (widget.disabled) {
      result = Opacity(opacity: 0.5, child: result);
    }

    return result;
  }

  TextStyle _presetStyle(ParkTextPreset p, dynamic typo) {
    // typo 是 ParkTypography，通过 getter 获取预设
    switch (p) {
      case ParkTextPreset.display:
        return typo.display;
      case ParkTextPreset.h1:
        return typo.h1;
      case ParkTextPreset.h2:
        return typo.h2;
      case ParkTextPreset.h3:
        return typo.h3;
      case ParkTextPreset.body:
        return typo.body;
      case ParkTextPreset.bodySmall:
        return typo.bodySmall;
      case ParkTextPreset.caption:
        return typo.caption;
      case ParkTextPreset.overline:
        return typo.overline;
    }
  }
}
