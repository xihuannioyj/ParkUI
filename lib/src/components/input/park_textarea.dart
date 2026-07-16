import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';
import 'park_input.dart';

/// Park UI 多行文本输入框
///
/// 基于 [FormField<String>] 封装，支持自动扩展高度、字数统计等功能，
/// 适用于备注、评论等长文本输入场景。
///
/// ```dart
/// ParkTextarea(
///   hintText: '请输入备注',
///   maxLength: 200,
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkTextarea extends FormField<String> {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkTextarea({
    super.key,
    this.bindKey,
    this.bindingService,
    TextEditingController? controller,
    String? initialValue,
    this.hintText,
    this.label,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 6,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
    this.autoSize = false,
    this.clearable = false,
    this.showCount = false,
    this.status,
    this.bordered = true,
    this.autofocus = false,
    this.onFocus,
    this.onBlur,
    this.size,
    this.textAlign = TextAlign.start,
    this.helperText,
    this.required = false,
    this.onCompositionStart,
    this.onCompositionEnd,
  }) : super(
          initialValue: controller?.text ?? initialValue ?? '',
          builder: (FormFieldState<String> field) {
            final state = field as _ParkTextareaState;
            final park =
                Theme.of(state.context).extension<ParkThemeData>() ??
                    ParkThemeData.light();
            return _ParkTextareaBuilder(state: state, park: park);
          },
        );

  final String? hintText;
  final String? label;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  @override
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;

  /// 是否自适应高度。为 true 时文本框随内容增长/收缩，不显示滚动条。
  /// 默认 false。
  final bool autoSize;

  /// 是否显示清除按钮（右下角）。默认 false。
  final bool clearable;

  /// 是否显示字数统计。默认 false。
  final bool showCount;

  /// 手动指定输入框状态样式，覆盖 validator 校验结果。
  final ParkInputStatus? status;

  /// 是否显示边框。为 false 时移除边框。默认 true。
  final bool bordered;

  /// 是否自动获取焦点。默认 false。
  final bool autofocus;

  /// 输入框获取焦点时的回调。
  final VoidCallback? onFocus;

  /// 输入框失去焦点时的回调。
  final VoidCallback? onBlur;

  /// 输入框尺寸，复用 [ParkInputSize]。为 null 时不额外控制尺寸。
  final ParkInputSize? size;

  /// 文本对齐方式。默认 [TextAlign.start]。
  final TextAlign textAlign;

  /// 辅助文字，显示在输入框下方（与错误文字互斥）。
  final String? helperText;

  /// 是否为必填项。为 true 时在标签前显示红色星号。
  final bool required;

  /// 输入法组合开始回调（CJK 输入法开始组合时触发）
  final ValueChanged<String>? onCompositionStart;

  /// 输入法组合结束回调（CJK 输入法结束组合时触发）
  final ValueChanged<String>? onCompositionEnd;

  @override
  FormFieldState<String> createState() => _ParkTextareaState();
}

class _ParkTextareaState extends FormFieldState<String> with BindableFormFieldMixin<String> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final widget = this.widget as ParkTextarea;
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    // 如果 bindable 已有值，同步到 TextEditingController
    // 非 String 类型（如 int）通过 toString 安全转换，避免类型转换异常
    final b = bindable;
    if (b != null) {
      _controller.text = b.value.toString();
    }
  }

  @override
  void onBindableChanged() {
    if (mounted) {
      final b = bindable;
      if (b != null) {
        final dynamic newValue = b.value;
        // 非 String 类型（如 int）通过 toString 安全转换，避免类型转换异常
        final String? safeText = newValue?.toString();
        if (safeText != null && _controller.text != safeText) {
          _controller.text = safeText;
        }
        super.onBindableChanged();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 从 ParkBindingFormScope 获取到服务后，把 bindable 初始值同步到 controller
    final b = bindable;
    if (b != null) {
      final text = b.value.toString();
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if ((widget as ParkTextarea).focusNode == null) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldTextarea = oldWidget as ParkTextarea;
    final newTextarea = widget as ParkTextarea;
    if (oldTextarea.initialValue != newTextarea.initialValue) {
      _controller.text = newTextarea.initialValue ?? '';
    }
  }

  void _onFocusChanged() {
    setState(() {});
    final w = widget as ParkTextarea;
    if (_focusNode.hasFocus) {
      w.onFocus?.call();
    } else {
      w.onBlur?.call();
    }
  }

  void _clear() {
    _controller.clear();
    setValue('');
    (widget as ParkTextarea).onChanged?.call('');
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    (widget as ParkTextarea).onChanged?.call(value ?? '');
  }

  @override
  void reset() {
    super.reset();
    _controller.text = widget.initialValue ?? '';
  }
}

class _ParkTextareaBuilder extends StatefulWidget {
  const _ParkTextareaBuilder({required this.state, required this.park});

  final _ParkTextareaState state;
  final ParkThemeData park;

  @override
  State<_ParkTextareaBuilder> createState() => _ParkTextareaBuilderState();
}

class _ParkTextareaBuilderState extends State<_ParkTextareaBuilder> {
  bool _isHovered = false;

  /// 根据 status 和 validator 计算最终边框颜色
  Color _resolveBorderColor({
    required ParkInputStatus? status,
    required bool hasError,
    required bool isFocused,
    required bool isHovered,
    required ParkColors colors,
  }) {
    if (status != null) {
      switch (status) {
        case ParkInputStatus.error:
          return colors.error;
        case ParkInputStatus.warning:
          return colors.warning;
        case ParkInputStatus.success:
          return colors.success;
      }
    }
    if (hasError) return colors.error;
    if (isFocused) return colors.brand;
    if (isHovered) return colors.textSecondary;
    return colors.border;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final park = widget.park;
    final textareaWidget = state.widget as ParkTextarea;
    final isFocused = state._focusNode.hasFocus;
    final hasError = state.hasError;
    final isDisabled = !textareaWidget.enabled;

    final borderColor = _resolveBorderColor(
      status: textareaWidget.status,
      hasError: hasError,
      isFocused: isFocused,
      isHovered: _isHovered,
      colors: park.colors,
    );

    final bgColor = isDisabled ? park.colors.disabledBg : park.colors.surface;

    final textStyle = park.typography.body.copyWith(
      color: isDisabled ? park.colors.textDisabled : park.colors.textPrimary,
    );

    final hintStyle = park.typography.body.copyWith(
      color: park.colors.textPlaceholder,
    );

    // When autoSize is true, set maxLines to null so TextField grows freely
    final int? effectiveMaxLines =
        textareaWidget.autoSize ? null : textareaWidget.maxLines;

    final inputField = TextField(
      controller: state._controller,
      focusNode: state._focusNode,
      enabled: textareaWidget.enabled,
      readOnly: textareaWidget.readOnly,
      maxLength: textareaWidget.maxLength,
      minLines: textareaWidget.minLines,
      maxLines: effectiveMaxLines,
      autofocus: textareaWidget.autofocus,
      textAlign: textareaWidget.textAlign,
      textAlignVertical: TextAlignVertical.top,
      style: textStyle,
      cursorColor: park.colors.brand,
      onChanged: (v) {
        state.didChange(v);
        // Rebuild to update clear button visibility and counter
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: textareaWidget.hintText,
        hintStyle: hintStyle,
        counterText: '',
        contentPadding: EdgeInsets.all(park.spacing.md),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );

    // Determine whether the bottom row (error + counter) should render
    final bool showCounter =
        textareaWidget.showCount && textareaWidget.maxLength != null;
    final bool showBottomRow = hasError || showCounter;

    // Determine label color based on status
    Color labelColor;
    if (textareaWidget.status != null) {
      switch (textareaWidget.status!) {
        case ParkInputStatus.error:
          labelColor = park.colors.error;
          break;
        case ParkInputStatus.warning:
          labelColor = park.colors.warning;
          break;
        case ParkInputStatus.success:
          labelColor = park.colors.success;
          break;
      }
    } else if (hasError) {
      labelColor = park.colors.error;
    } else if (isFocused) {
      labelColor = park.colors.brand;
    } else {
      labelColor = park.colors.textSecondary;
    }

    // Build the clear button overlay
    Widget? clearButton;
    if (textareaWidget.clearable &&
        state._controller.text.isNotEmpty &&
        !isDisabled &&
        !textareaWidget.readOnly) {
      clearButton = Positioned(
        right: park.spacing.sm,
        bottom: park.spacing.sm,
        child: Semantics(
          button: true,
          label: ParkLocalizations.of(context).clearText,
          child: GestureDetector(
          onTap: state._clear,
          child: Icon(
            CupertinoIcons.clear_circled_solid,
            size: 18,
            color: park.colors.textPlaceholder,
          ),
        ),
        ),
      );
    }

    // Build the bordered container
    Widget borderedContainer;
    if (textareaWidget.bordered) {
      borderedContainer = AnimatedContainer(
        duration: park.motion.standard,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color: borderColor,
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: inputField,
      );
    } else {
      borderedContainer = AnimatedContainer(
        duration: park.motion.standard,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: inputField,
      );
    }

    // Stack the clear button on top of the container
    Widget textareaArea;
    if (textareaWidget.clearable) {
      textareaArea = Semantics(
        textField: true,
        value: state._controller.text,
        child: Stack(
        children: [
          borderedContainer,
          ?clearButton,
        ],
      ),
      );
    } else {
      textareaArea = Semantics(
        textField: true,
        value: state._controller.text,
        child: borderedContainer,
      );
    }

    return MouseRegion(
      onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
      onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (textareaWidget.label != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (textareaWidget.required)
                  Padding(
                    padding: EdgeInsets.only(right: park.spacing.xs),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: park.colors.error,
                        fontSize: park.typography.sizeBody,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Flexible(
                  child: Text(
                    textareaWidget.label!,
                    style: park.typography.bodySmall.copyWith(
                      color: labelColor,
                      fontWeight: park.typography.weightMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: park.spacing.xs),
          ],
          textareaArea,
          if (showBottomRow) ...[
            SizedBox(height: park.spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasError)
                  Expanded(
                    child: Text(
                      state.errorText ?? '',
                      style: park.typography.caption.copyWith(
                        color: park.colors.error,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (showCounter)
                  Text(
                    '${state._controller.text.length}/${textareaWidget.maxLength}',
                    style: park.typography.caption.copyWith(
                      color: state._controller.text.length >=
                              textareaWidget.maxLength!
                          ? park.colors.error
                          : park.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
          // Helper text (distinct from error)
          if (textareaWidget.helperText != null && !hasError) ...[
            SizedBox(height: park.spacing.xs),
            Text(
              textareaWidget.helperText!,
              style: park.typography.caption.copyWith(
                color: park.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
