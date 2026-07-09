import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../theme/tokens/park_motion.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../base/park_button.dart';
import '../base/park_button_style.dart';

/// 输入框状态枚举
///
/// 用于手动指定输入框的校验状态样式，覆盖默认的 validator 结果。
enum ParkInputStatus {
  /// 错误状态 — 红色边框
  error,

  /// 警告状态 — 橙色边框
  warning,

  /// 成功状态 — 绿色边框
  success,
}

/// 输入框尺寸枚举
enum ParkInputSize {
  /// 小尺寸 — 高度 32px，字号 12px
  small,

  /// 中尺寸（默认）— 高度 48px，字号 14px
  medium,

  /// 大尺寸 — 高度 56px，字号 16px
  large,
}

/// Park UI 文本输入框
///
/// 基于 [FormField<String>] 封装，支持表单校验、焦点管理、密码切换、
/// 字数统计、清除按钮等功能。
///
/// ```dart
/// ParkInput(
///   label: '用户名',
///   hintText: '请输入用户名',
///   clearable: true,
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkInput extends FormField<String> {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkInput({
    super.key,
    this.bindKey,
    this.bindingService,
    TextEditingController? controller,
    String? initialValue,
    this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.clearable = false,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    super.enabled = true,
    this.readOnly = false,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
    this.status,
    this.size = ParkInputSize.medium,
    this.bordered = true,
    this.addonBefore,
    this.addonAfter,
    this.showCount = false,
    this.inputFormatters,
    this.autofocus = false,
    this.onFocus,
    this.onBlur,
    this.textAlign = TextAlign.start,
    this.onEditingComplete,
    this.onTap,
    this.onTapOutside,
    this.labelWidget,
    this.helperText,
    this.required = false,
    this.onSearch,
    this.searchButton,
    this.prefixText,
    this.suffixText,
    this.borderless = false,
    this.readonly = false,
    this.onCompositionStart,
    this.onCompositionEnd,
  }) : super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: (FormFieldState<String> field) {
           final state = field as _ParkInputState;
           final park =
               Theme.of(state.context).extension<ParkThemeData>() ??
               ParkThemeData.light();
           return _ParkInputBuilder(state: state, park: park);
         },
       );

  final String? hintText;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// 前置 Widget（优先级低于 [prefixIcon]，可放任意 Widget）
  final Widget? prefix;

  /// 后置 Widget（优先级低于 [suffixIcon]，可放任意 Widget）
  final Widget? suffix;

  final bool clearable;
  final bool obscureText;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool readOnly;

  /// 手动指定输入框状态样式，覆盖 validator 校验结果。
  ///
  /// 设置后边框颜色与聚焦环颜色将使用对应状态色。
  final ParkInputStatus? status;

  /// 输入框尺寸，控制高度、字号和内边距。默认 [ParkInputSize.medium]。
  final ParkInputSize size;

  /// 是否显示边框。为 false 时移除边框和背景，仅在聚焦时显示底部线条。
  /// 默认 true。
  final bool bordered;

  /// 外部前置附件，放置在输入框边框之外（左侧）。
  /// 适用于前置按钮、标签等场景。
  final Widget? addonBefore;

  /// 外部后置附件，放置在输入框边框之外（右侧）。
  /// 适用于后置按钮、标签等场景。
  final Widget? addonAfter;

  /// 是否显示字数统计。仅在 [maxLength] 不为 null 时生效。
  /// 默认 false（不显示）。
  final bool showCount;

  /// 输入格式化器列表，透传给底层 [TextField]。
  final List<TextInputFormatter>? inputFormatters;

  /// 是否自动获取焦点。默认 false。
  final bool autofocus;

  /// 输入框获取焦点时的回调。
  final VoidCallback? onFocus;

  /// 输入框失去焦点时的回调。
  final VoidCallback? onBlur;

  /// 文本对齐方式。默认 [TextAlign.start]。
  final TextAlign textAlign;

  /// 编辑完成时的回调（按下键盘完成按钮）。
  final VoidCallback? onEditingComplete;

  /// 点击输入框时的回调。
  final VoidCallback? onTap;

  /// 点击输入框外部时的回调。
  final VoidCallback? onTapOutside;

  /// 自定义标签 Widget，优先级高于 [label] 字符串。
  final Widget? labelWidget;

  /// 辅助文字，显示在输入框下方（与错误文字互斥）。
  final String? helperText;

  /// 是否为必填项。为 true 时在标签前显示红色星号。
  final bool required;

  /// 搜索回调（按下搜索键或回车时触发）
  final ValueChanged<String>? onSearch;

  /// 搜索按钮配置（对齐 Ant Design 的 Input.Search）。
  ///
  /// 接受三种取值：
  /// - `null`：无搜索按钮（默认）。
  /// - `true`：渲染默认「搜索」按钮（[ParkButtonVariant.primary] + 搜索图标）。
  /// - [ParkInputSearchButtonConfig]：自定义文案 / 图标 / 变体 / loading / 回调。
  ///
  /// 与 suffixIcon / clearable / obscureText 共存不冲突；点击或回车触发 [onSearch]。
  final dynamic searchButton;

  /// 前置文本（显示在输入框内部最前方，灰色小字）
  final String? prefixText;

  /// 后置文本（显示在输入框内部最后方，灰色小字）
  final String? suffixText;

  /// 无边框变体（完全去除边框和背景，比 bordered: false 更彻底）
  final bool borderless;

  /// 是否只读（readOnly 的别名，兼容 AntD 命名）
  final bool readonly;

  /// 输入法组合开始回调（CJK 输入法开始组合时触发）
  final ValueChanged<String>? onCompositionStart;

  /// 输入法组合结束回调（CJK 输入法结束组合时触发）
  final ValueChanged<String>? onCompositionEnd;

  @override
  FormFieldState<String> createState() => _ParkInputState();
}

/// 搜索按钮配置（对齐 Ant Design 的 Input.Search）。
///
/// 配合 [ParkInput.searchButton] 使用：
/// - 传入 `true`：渲染默认「搜索」按钮（[ParkButtonVariant.primary] + 搜索图标）。
/// - 传入 [ParkInputSearchButtonConfig]：自定义文案 / 图标 / 变体 / loading / 回调。
class ParkInputSearchButtonConfig {
  /// 按钮文案，默认 '搜索'。
  final String text;

  /// 按钮图标，默认 [Icons.search]。
  final IconData? icon;

  /// 是否处于加载中（显示 spinner 并禁点），默认 false。
  final bool loading;

  /// 按钮变体，默认 [ParkButtonVariant.primary]。
  final ParkButtonVariant variant;

  /// 覆盖 [ParkInput.onSearch] 的搜索回调。
  final ValueChanged<String>? onSearch;

  const ParkInputSearchButtonConfig({
    this.text = '搜索',
    this.icon = Icons.search,
    this.loading = false,
    this.variant = ParkButtonVariant.primary,
    this.onSearch,
  });
}

class _ParkInputState extends FormFieldState<String> with BindableFormFieldMixin<String> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    final widget = this.widget as ParkInput;
    _controller = TextEditingController(text: widget.initialValue);
    _obscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    // 如果 bindable 已有值，同步到 TextEditingController
    // 非 String 类型（如 int）通过 toString 安全转换，避免类型转换异常
    final b = bindable;
    if (b != null && b.value != null) {
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
    if (b != null && b.value != null) {
      final text = b.value.toString();
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if ((widget as ParkInput).focusNode == null) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
    final w = widget as ParkInput;
    if (_focusNode.hasFocus) {
      w.onFocus?.call();
    } else {
      w.onBlur?.call();
    }
  }

  void _toggleObscure() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  void _clear() {
    _controller.clear();
    setValue('');
    (widget as ParkInput).onChanged?.call('');
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    (widget as ParkInput).onChanged?.call(value ?? '');
  }

  @override
  void reset() {
    super.reset();
    _controller.text = widget.initialValue ?? '';
  }
}

class _ParkInputBuilder extends StatefulWidget {
  const _ParkInputBuilder({required this.state, required this.park});

  final _ParkInputState state;
  final ParkThemeData park;

  @override
  State<_ParkInputBuilder> createState() => _ParkInputBuilderState();
}

class _ParkInputBuilderState extends State<_ParkInputBuilder> {
  bool _isHovered = false;

  /// 根据尺寸返回高度
  double get _height {
    switch ((widget.state.widget as ParkInput).size) {
      case ParkInputSize.small:
        return 32;
      case ParkInputSize.medium:
        return 48;
      case ParkInputSize.large:
        return 56;
    }
  }

  /// 根据尺寸返回字号
  double get _fontSize {
    final park = widget.park;
    switch ((widget.state.widget as ParkInput).size) {
      case ParkInputSize.small:
        return park.typography.sizeBodySmall;
      case ParkInputSize.medium:
        return park.typography.sizeBody;
      case ParkInputSize.large:
        return park.typography.sizeH3;
    }
  }

  /// 根据尺寸返回水平内边距
  double get _horizontalPadding {
    final park = widget.park;
    switch ((widget.state.widget as ParkInput).size) {
      case ParkInputSize.small:
        return park.spacing.sm;
      case ParkInputSize.medium:
        return park.spacing.md;
      case ParkInputSize.large:
        return park.spacing.base;
    }
  }

  /// 根据尺寸返回垂直内边距
  double get _verticalPadding {
    final park = widget.park;
    switch ((widget.state.widget as ParkInput).size) {
      case ParkInputSize.small:
        return park.spacing.xs;
      case ParkInputSize.medium:
        return park.spacing.sm;
      case ParkInputSize.large:
        return park.spacing.md;
    }
  }

  /// 根据 status 和 validator 计算最终边框颜色
  Color _resolveBorderColor({
    required ParkInputStatus? status,
    required bool hasError,
    required bool isFocused,
    required bool isHovered,
    required ParkColors colors,
  }) {
    // status 优先
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
    // 其次 validator
    if (hasError) return colors.error;
    if (isFocused) return colors.brand;
    if (isHovered) return colors.textSecondary;
    return colors.border;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final park = widget.park;
    final inputWidget = state.widget as ParkInput;
    final isFocused = state._focusNode.hasFocus;
    final hasError = state.hasError;
    final isDisabled = !inputWidget.enabled;

    final borderColor = _resolveBorderColor(
      status: inputWidget.status,
      hasError: hasError,
      isFocused: isFocused,
      isHovered: _isHovered,
      colors: park.colors,
    );

    final bgColor = isDisabled ? park.colors.disabledBg : park.colors.surface;

    final textStyle = park.typography.body.copyWith(
      fontSize: _fontSize,
      color: isDisabled ? park.colors.textDisabled : park.colors.textPrimary,
    );

    final hintStyle = park.typography.body.copyWith(
      fontSize: _fontSize,
      color: park.colors.textPlaceholder,
    );

    // Build suffix widgets
    final suffixWidgets = <Widget>[];

    if (inputWidget.clearable &&
        state._controller.text.isNotEmpty &&
        !isDisabled &&
        !inputWidget.readOnly &&
        !inputWidget.readonly) {
      suffixWidgets.add(
        GestureDetector(
          onTap: state._clear,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: park.spacing.xs),
            child: Icon(
              CupertinoIcons.clear_circled_solid,
              size: 18,
              color: park.colors.textPlaceholder,
            ),
          ),
        ),
      );
    }

    if (inputWidget.obscureText) {
      suffixWidgets.add(
        GestureDetector(
          onTap: state._toggleObscure,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: park.spacing.xs),
            child: Icon(
              state._obscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              size: 18,
              color: park.colors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (inputWidget.suffixIcon != null) {
      suffixWidgets.add(inputWidget.suffixIcon!);
    }

    if (inputWidget.suffix != null) {
      suffixWidgets.add(inputWidget.suffix!);
    }

    final inputField = TextField(
      controller: state._controller,
      focusNode: state._focusNode,
      enabled: inputWidget.enabled,
      readOnly: inputWidget.readOnly || inputWidget.readonly,
      obscureText: state._obscured,
      maxLength: inputWidget.maxLength,
      maxLines: inputWidget.maxLines,
      keyboardType: inputWidget.keyboardType,
      textInputAction: inputWidget.textInputAction,
      inputFormatters: inputWidget.inputFormatters,
      autofocus: inputWidget.autofocus,
      textAlign: inputWidget.textAlign,
      onEditingComplete: inputWidget.onEditingComplete,
      onTap: inputWidget.onTap,
      onTapOutside: inputWidget.onTapOutside != null
          ? (_) => inputWidget.onTapOutside!()
          : null,
      style: textStyle,
      cursorColor: park.colors.brand,
      onChanged: (v) {
        state.didChange(v);
      },
      onSubmitted: (v) {
        inputWidget.onSubmitted?.call(v);
        _triggerSearch(v);
      },
      decoration: InputDecoration(
        hintText: inputWidget.hintText,
        hintStyle: hintStyle,
        counterText: '',
        prefixText: inputWidget.prefixText,
        suffixText: inputWidget.suffixText,
        prefixIcon: inputWidget.prefixIcon != null
            ? IconTheme.merge(
                data: IconThemeData(
                  color: isFocused
                      ? park.colors.brand
                      : park.colors.textSecondary,
                  size: 20,
                ),
                child: inputWidget.prefixIcon!,
              )
            : null,
        suffixIcon: suffixWidgets.isNotEmpty
            ? Row(mainAxisSize: MainAxisSize.min, children: suffixWidgets)
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
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
        inputWidget.showCount && inputWidget.maxLength != null;
    final bool showBottomRow = hasError || showCounter;

    // Determine label color based on status
    Color labelColor;
    if (inputWidget.status != null) {
      switch (inputWidget.status!) {
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

    // 解析搜索按钮子项（如有），组合进输入区右侧。
    final Widget rawField = inputWidget.prefix != null
        ? Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: park.spacing.md),
                child: inputWidget.prefix!,
              ),
              Expanded(child: inputField),
            ],
          )
        : inputField;

    final Widget innerField;
    if (inputWidget.searchButton != null) {
      innerField = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: rawField),
          Container(
            width: 1,
            height: _height - 16,
            color: park.colors.divider,
          ),
          _buildSearchButton(park.colors),
        ],
      );
    } else {
      innerField = rawField;
    }

    // Build the bordered / borderless container
    Widget borderedContainer;
    if (inputWidget.bordered) {
      borderedContainer = AnimatedContainer(
        duration: ParkMotion.standard,
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          minHeight: inputWidget.maxLines == 1 ? _height : _height,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color: borderColor,
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: innerField,
      );
    } else {
      // Borderless: transparent background, bottom border only on focus
      borderedContainer = AnimatedContainer(
        duration: ParkMotion.standard,
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          minHeight: inputWidget.maxLines == 1 ? _height : _height,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isFocused ? borderColor : Colors.transparent,
              width: isFocused ? 1.5 : 0,
            ),
          ),
        ),
        child: innerField,
      );
    }

    // Wrap with addons if present
    Widget content;
    if (inputWidget.addonBefore != null || inputWidget.addonAfter != null) {
      content = Row(
        children: [
          if (inputWidget.addonBefore != null) ...[
            inputWidget.addonBefore!,
            SizedBox(width: park.spacing.sm),
          ],
          Expanded(child: borderedContainer),
          if (inputWidget.addonAfter != null) ...[
            SizedBox(width: park.spacing.sm),
            inputWidget.addonAfter!,
          ],
        ],
      );
    } else {
      content = borderedContainer;
    }

    return MouseRegion(
      onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
      onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inputWidget.labelWidget != null || inputWidget.label != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (inputWidget.required)
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
                  child: inputWidget.labelWidget ??
                      Text(
                        inputWidget.label!,
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
          content,
          // Error text and char counter row
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
                    '${state._controller.text.length}/${inputWidget.maxLength}',
                    style: park.typography.caption.copyWith(
                      color:
                          state._controller.text.length >=
                              inputWidget.maxLength!
                          ? park.colors.error
                          : park.colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
          // Helper text (distinct from error)
          if (inputWidget.helperText != null && !hasError) ...[
            SizedBox(height: park.spacing.xs),
            Text(
              inputWidget.helperText!,
              style: park.typography.caption.copyWith(
                color: park.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 触发搜索：优先使用 searchButton 配置中的 [ParkInputSearchButtonConfig.onSearch]，
  /// 否则回退到 [ParkInput.onSearch]。
  void _triggerSearch(String text) {
    final ParkInput inputWidget = widget.state.widget as ParkInput;
    final dynamic cfg = inputWidget.searchButton;
    final ValueChanged<String>? cfgOnSearch =
        (cfg is ParkInputSearchButtonConfig) ? cfg.onSearch : null;
    (cfgOnSearch ?? inputWidget.onSearch)?.call(text);
  }

  /// 构建右侧搜索按钮（仅当 [ParkInput.searchButton] 配置时调用）。
  ///
  /// 与 suffixIcon / clearable / obscureText 共存不冲突；[loading] 为 true 时
  /// 显示 spinner 并禁点。高度与输入框严格对齐（[ParkButton.height] = [_height]）。
  Widget _buildSearchButton(ParkColors colors) {
    final ParkInput inputWidget = widget.state.widget as ParkInput;
    final dynamic cfg = inputWidget.searchButton;
    final bool isCfg = cfg is ParkInputSearchButtonConfig;
    final String text = isCfg ? (cfg as ParkInputSearchButtonConfig).text : '搜索';
    final IconData? icon = isCfg ? (cfg).icon : Icons.search;
    final bool loading = isCfg ? (cfg).loading : false;
    final ParkButtonVariant variant =
        isCfg ? (cfg).variant : ParkButtonVariant.primary;
    final ValueChanged<String>? cfgOnSearch =
        isCfg ? (cfg).onSearch : null;

    final bool isDisabled = !inputWidget.enabled;
    final bool enabled = !isDisabled && !loading;

    final Widget childContent = loading
        ? Text(text)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) Icon(icon, size: 16),
              if (icon != null && text.isNotEmpty)
                const SizedBox(width: 4),
              if (text.isNotEmpty) Text(text),
            ],
          );

    return SizedBox(
      height: _height,
      child: ParkButton(
        variant: variant,
        height: _height,
        loading: loading,
        onPressed: enabled
            ? () {
                final ValueChanged<String>? cb =
                    cfgOnSearch ?? inputWidget.onSearch;
                cb?.call(widget.state._controller.text);
              }
            : null,
        child: childContent,
      ),
    );
  }
}
