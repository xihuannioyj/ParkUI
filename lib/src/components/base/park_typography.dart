import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/park_theme_data.dart';

// ============================================================================
// ParkTitle — 标题组件
// ============================================================================

/// Park 标题组件
///
/// 对标 Ant Design Typography.Title，提供语义化标题排版能力。
/// - level 1-5 对应不同字号（映射到 park.typography 的 display/h1-h3/bodySmall）
/// - 可选副标题（subtitle）
/// - 可选复制功能（copyable）
///
/// ```dart
/// ParkTitle(text: '一级标题', level: 1)
/// ParkTitle(text: '带副标题', subtitle: '这是副标题')
/// ParkTitle(text: '可复制标题', copyable: true)
/// ```
class ParkTitle extends StatelessWidget {
  /// 标题级别 1-5（1 最大，5 最小）
  final int level;

  /// 文本内容
  final String text;

  /// 副标题
  final String? subtitle;

  /// 是否可复制（显示复制图标，点击复制到剪贴板）
  final bool copyable;

  /// 文本对齐方式
  final TextAlign? textAlign;

  const ParkTitle({
    super.key,
    this.level = 1,
    required this.text,
    this.subtitle,
    this.copyable = false,
    this.textAlign,
  }) : assert(level >= 1 && level <= 5, 'level must be between 1 and 5');

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;

    // level -> TextStyle mapping
    final TextStyle titleStyle;
    switch (level) {
      case 1:
        titleStyle = typo.display;
        break;
      case 2:
        titleStyle = typo.h1;
        break;
      case 3:
        titleStyle = typo.h2;
        break;
      case 4:
        titleStyle = typo.h3;
        break;
      case 5:
        titleStyle = typo.body.copyWith(fontWeight: typo.weightMedium);
        break;
      default:
        titleStyle = typo.display;
    }

    final effectiveStyle = titleStyle.copyWith(color: colors.textPrimary);

    Widget titleRow = Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
    );

    // 复制图标
    if (copyable) {
      titleRow = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleRow),
          _ParkCopyIcon(
            text: text,
            iconSize: (effectiveStyle.fontSize ?? 28) * 0.5,
          ),
        ],
      );
    }

    // 副标题
    if (subtitle != null && subtitle!.isNotEmpty) {
      final subtitleStyle = TextStyle(
        fontSize: typo.sizeBodySmall,
        fontWeight: typo.weightRegular,
        color: colors.textSecondary,
        height: typo.lineHeightBody,
        fontFamily: typo.fontFamily,
      );
      return Column(
        crossAxisAlignment:
            textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleRow,
          SizedBox(height: park.spacing.xs),
          Text(subtitle!, style: subtitleStyle, textAlign: textAlign),
        ],
      );
    }

    return titleRow;
  }
}

// ============================================================================
// ParkParagraph — 段落组件
// ============================================================================

/// Park 段落组件
///
/// 对标 Ant Design Typography.Paragraph，提供段落排版能力。
/// - maxLines + expandable 实现文本省略 + 展开/收起
/// - copyable 实现复制到剪贴板
/// - editable 预留编辑入口（显示编辑图标，点击触发 [onEdit]）
///
/// ```dart
/// ParkParagraph(text: '长段落文本...')
/// ParkParagraph(text: '可省略段落', maxLines: 2, expandable: true)
/// ParkParagraph(text: '可复制段落', copyable: true)
/// ```
class ParkParagraph extends StatefulWidget {
  /// 文本内容
  final String text;

  /// 最大行数（超出自动省略）
  final int? maxLines;

  /// 是否可展开/收起（配合 maxLines 使用）
  final bool expandable;

  /// 是否可复制
  final bool copyable;

  /// 是否显示编辑图标
  final bool editable;

  /// 编辑按钮点击回调（editable 为 true 时有效）
  final VoidCallback? onEdit;

  /// 文本对齐方式
  final TextAlign? textAlign;

  /// 自定义展开按钮文字（默认为"展开"）
  final String? expandText;

  /// 自定义收起按钮文字（默认为"收起"）
  final String? collapseText;

  const ParkParagraph({
    super.key,
    required this.text,
    this.maxLines,
    this.expandable = false,
    this.copyable = false,
    this.editable = false,
    this.onEdit,
    this.textAlign,
    this.expandText,
    this.collapseText,
  });

  @override
  State<ParkParagraph> createState() => _ParkParagraphState();
}

class _ParkParagraphState extends State<ParkParagraph> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;

    final bodyStyle = typo.body.copyWith(color: colors.textPrimary);

    // 展开/收起逻辑
    final int? effectiveMaxLines;
    final TextOverflow? effectiveOverflow;
    if (widget.expandable) {
      effectiveMaxLines = _expanded ? null : (widget.maxLines ?? 2);
      effectiveOverflow = _expanded ? null : TextOverflow.ellipsis;
    } else {
      effectiveMaxLines = widget.maxLines;
      effectiveOverflow =
          widget.maxLines != null ? TextOverflow.ellipsis : null;
    }

    Widget textWidget = Text(
      widget.text,
      style: bodyStyle,
      maxLines: effectiveMaxLines,
      overflow: effectiveOverflow,
      textAlign: widget.textAlign,
    );

    // 操作按钮行
    final actions = <Widget>[];

    // 展开/收起链接
    if (widget.expandable) {
      actions.add(
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: EdgeInsets.only(left: park.spacing.xs),
            child: Text(
              _expanded
                  ? (widget.collapseText ?? '收起')
                  : (widget.expandText ?? '展开'),
              style: TextStyle(
                color: colors.brand,
                fontSize: bodyStyle.fontSize ?? 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    // 复制图标
    if (widget.copyable) {
      actions.add(
        _ParkCopyIcon(
          text: widget.text,
          iconSize: (bodyStyle.fontSize ?? 16) * 0.85,
        ),
      );
    }

    // 编辑图标
    if (widget.editable) {
      actions.add(
        GestureDetector(
          onTap: widget.onEdit,
          child: Padding(
            padding: EdgeInsets.only(left: park.spacing.xs),
            child: Icon(
              Icons.edit_outlined,
              size: (bodyStyle.fontSize ?? 16) * 0.9,
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return textWidget;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: textWidget),
            ...actions,
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// _ParkCopyIcon — 内部复用复制图标
// ============================================================================

/// 内部用：复制图标 + "已复制"反馈
class _ParkCopyIcon extends StatefulWidget {
  final String text;
  final double iconSize;

  const _ParkCopyIcon({required this.text, this.iconSize = 14});

  @override
  State<_ParkCopyIcon> createState() => _ParkCopyIconState();
}

class _ParkCopyIconState extends State<_ParkCopyIcon> {
  bool _showCopiedFeedback = false;
  Timer? _copiedTimer;

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _showCopiedFeedback = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showCopiedFeedback = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;

    return GestureDetector(
      onTap: _copy,
      child: Padding(
        padding: EdgeInsets.only(left: park.spacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.copy,
              size: widget.iconSize,
              color: colors.textSecondary,
            ),
            if (_showCopiedFeedback) ...[
              SizedBox(width: park.spacing.xxs),
              Text(
                '已复制',
                style: TextStyle(
                  color: colors.success,
                  fontSize: widget.iconSize * 0.85,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
