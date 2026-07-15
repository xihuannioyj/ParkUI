import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// ParkEllipsis — 文本省略组件
///
/// 超长文本自动截断并显示省略号，支持 tooltip 悬浮/长按显示完整内容。
///
/// ```dart
/// ParkEllipsis(
///   text: '这是一段很长的文本内容...',
///   maxLines: 2,
///   tooltip: true,
/// )
/// ```
class ParkEllipsis extends StatelessWidget {
  /// 完整文本内容
  final String text;

  /// 最大显示行数
  final int maxLines;

  /// 文本样式
  final TextStyle? style;

  /// 是否启用 tooltip 显示完整文本
  final bool tooltip;

  /// 自定义 tooltip 文字（默认使用 [text]）
  final String? tooltipText;

  /// 文本对齐方式
  final TextAlign? textAlign;

  /// 当 true 时显示"展开/收起"切换按钮。
  final bool expandable;

  /// 放在省略文本后面的组件（如"阅读更多"链接）。
  final Widget? suffix;

  const ParkEllipsis({
    super.key,
    required this.text,
    this.maxLines = 1,
    this.style,
    this.tooltip = true,
    this.tooltipText,
    this.textAlign,
    this.expandable = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    final effectiveStyle = style ?? park.typography.body.copyWith(
          color: park.colors.textPrimary,
        );

    if (expandable) {
      return _ParkEllipsisExpandable(
        text: text,
        maxLines: maxLines,
        style: effectiveStyle,
        textAlign: textAlign,
        park: park,
        suffix: suffix,
        tooltip: tooltip,
        tooltipText: tooltipText,
      );
    }

    Widget textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: effectiveStyle,
      textAlign: textAlign,
    );

    if (suffix != null) {
      textWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(child: textWidget),
          suffix!,
        ],
      );
    }

    if (!tooltip) return textWidget;

    return _ParkEllipsisTooltip(
      text: tooltipText ?? text,
      park: park,
      child: textWidget,
    );
  }
}

/// 内部：长按/悬浮显示完整文本的 Tooltip 包装
class _ParkEllipsisTooltip extends StatefulWidget {
  final String text;
  final ParkThemeData park;
  final Widget child;

  const _ParkEllipsisTooltip({
    required this.text,
    required this.park,
    required this.child,
  });

  @override
  State<_ParkEllipsisTooltip> createState() => _ParkEllipsisTooltipState();
}

class _ParkEllipsisTooltipState extends State<_ParkEllipsisTooltip> {
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 4,
          width: size.width.clamp(0.0, MediaQuery.of(ctx).size.width * 0.8),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(widget.park.spacing.md),
              decoration: BoxDecoration(
                color: widget.park.colors.textPrimary.withValues(alpha: 0.9),
                borderRadius: widget.park.radius.brSm,
              ),
              child: Text(
                widget.text,
                style: widget.park.typography.body.copyWith(
                  fontSize: widget.park.typography.sizeBodySmall,
                  color: widget.park.colors.textOnBrand,
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showOverlay(),
      onExit: (_) => _hideOverlay(),
      child: GestureDetector(
        onLongPressStart: (_) => _showOverlay(),
        onLongPressEnd: (_) => _hideOverlay(),
        child: widget.child,
      ),
    );
  }
}

/// 内部：可展开/收起的文本组件
class _ParkEllipsisExpandable extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;
  final TextAlign? textAlign;
  final ParkThemeData park;
  final Widget? suffix;
  final bool tooltip;
  final String? tooltipText;

  const _ParkEllipsisExpandable({
    required this.text,
    required this.maxLines,
    required this.style,
    this.textAlign,
    required this.park,
    this.suffix,
    this.tooltip = true,
    this.tooltipText,
  });

  @override
  State<_ParkEllipsisExpandable> createState() =>
      _ParkEllipsisExpandableState();
}

class _ParkEllipsisExpandableState extends State<_ParkEllipsisExpandable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? null : TextOverflow.ellipsis,
          style: widget.style,
          textAlign: widget.textAlign,
        ),
        Semantics(
          button: true,
          label: _expanded
              ? ParkLocalizations.of(context).collapseText
              : ParkLocalizations.of(context).expandText,
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
            padding: EdgeInsets.only(top: widget.park.spacing.xs),
            child: Text(
              _expanded
                  ? ParkLocalizations.of(context).collapseText
                  : ParkLocalizations.of(context).expandText,
              style: widget.style.copyWith(
                color: widget.park.colors.brand,
                fontSize: widget.park.typography.sizeBodySmall,
              ),
            ),
          ),
        ),
        ),
        if (widget.suffix != null) widget.suffix!,
      ],
    );
  }
}
