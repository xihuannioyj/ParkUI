import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

/// Park UI 开关尺寸
enum ParkSwitchSize {
  /// 小尺寸（宽 36, 高 20）
  small,

  /// 中尺寸（宽 44, 高 24）
  medium,

  /// 大尺寸（宽 52, 高 28）
  large,
}

/// Park UI 开关
///
/// 基于 [FormField<bool>] 封装的拨动开关，支持动画过渡、加载中状态、
/// 自定义激活/非激活颜色等。
///
/// ```dart
/// ParkSwitch(
///   value: true,
///   size: ParkSwitchSize.medium,
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkSwitch extends FormField<dynamic> implements ParkBindableWidget {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkSwitch({
    super.key,
    this.bindKey,
    this.bindingService,
    dynamic value = false,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.size = ParkSwitchSize.medium,
    this.disabled = false,
    this.loading = false,
    this.checkedContent,
    this.uncheckedContent,
    this.checkedValue = true,
    this.uncheckedValue = false,
    this.beforeChange,
    this.label,
    this.readOnly = false,
    this.thumbIcon,
    this.checkedChild,
    this.uncheckedChild,
    this.checkedLabel,
    this.uncheckedLabel,
    this.tooltip,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
  }) : super(
         initialValue: value,
         builder: (FormFieldState<dynamic> field) {
           final state = field as _ParkSwitchState;
           final park =
               Theme.of(state.context).extension<ParkThemeData>() ??
               ParkThemeData.light();
           return _ParkSwitchBuilder(state: state, park: park);
         },
       );

  final ValueChanged<dynamic>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final ParkSwitchSize size;
  final bool disabled;
  final bool loading;

  /// 开启态内部内容（显示在开关左侧）
  final Widget? checkedContent;

  /// 关闭态内部内容（显示在开关右侧）
  final Widget? uncheckedContent;

  /// 选中时的值，默认为 true。可自定义为任意类型（如 1、'yes'）。
  final dynamic checkedValue;

  /// 未选中时的值，默认为 false。可自定义为任意类型（如 0、'no'）。
  final dynamic uncheckedValue;

  /// 切换前的异步拦截钩子。返回 false 则取消切换。
  /// 参数 nextValue 表示即将切换到的布尔状态（true = 开启）。
  final Future<bool> Function(bool nextValue)? beforeChange;

  /// 显示在开关右侧的文字标签。
  final String? label;

  /// 是否只读。外观正常但不可交互。
  final bool readOnly;

  /// 拇指上的自定义图标。
  final IconData? thumbIcon;

  /// 选中状态下在滑块（thumb）上显示的自定义元素。
  /// 当 [loading] 为 true 时不显示。常见用法：`Icon(Icons.check)`。
  final Widget? checkedChild;

  /// 未选中状态下在滑块（thumb）上显示的自定义元素。
  /// 当 [loading] 为 true 时不显示。常见用法：`Icon(Icons.close)`。
  final Widget? uncheckedChild;

  /// 选中状态的语义标签，用于 [ParkFormItem] 和无障碍（Semantics）。
  /// 当提供时，开关开启时 Semantics.label 优先使用此值。
  final String? checkedLabel;

  /// 未选中状态的语义标签，用于 [ParkFormItem] 和无障碍（Semantics）。
  /// 当提供时，开关关闭时 Semantics.label 优先使用此值。
  final String? uncheckedLabel;

  /// 鼠标悬停时显示的提示文字。
  final String? tooltip;

  @override
  FormFieldState<dynamic> createState() => _ParkSwitchState();
}

class _ParkSwitchState extends FormFieldState<dynamic> with BindableFormFieldMixin<dynamic> {
  /// beforeChange 等待期间的 loading 状态。
  bool _pendingChange = false;

  /// 当前是否为"开启"态（通过比较 value 与 checkedValue）。
  bool get isOn => value == (widget as ParkSwitch).checkedValue;

  Future<void> toggle() async {
    final w = widget as ParkSwitch;
    if (w.disabled || w.readOnly || w.loading || _pendingChange) return;

    final nextBool = !isOn;

    if (w.beforeChange != null) {
      setState(() => _pendingChange = true);
      try {
        final allowed = await w.beforeChange!(nextBool);
        if (!allowed || !mounted) {
          if (mounted) setState(() => _pendingChange = false);
          return;
        }
      } catch (_) {
        if (mounted) setState(() => _pendingChange = false);
        return;
      }
      if (mounted) setState(() => _pendingChange = false);
    }

    final newValue = nextBool ? w.checkedValue : w.uncheckedValue;
    didChange(newValue);
    w.onChanged?.call(newValue);
  }
}

class _ParkSwitchBuilder extends StatelessWidget {
  const _ParkSwitchBuilder({required this.state, required this.park});

  final _ParkSwitchState state;
  final ParkThemeData park;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as ParkSwitch;
    final isOn = state.isOn;
    final isDisabled = widget.disabled;
    final isLoading = widget.loading || state._pendingChange;

    // Size mapping
    final double trackWidth;
    final double trackHeight;
    final double thumbSize;
    final double thumbInset;

    switch (widget.size) {
      case ParkSwitchSize.small:
        trackWidth = 36;
        trackHeight = 20;
        thumbSize = 16;
        thumbInset = 2;
      case ParkSwitchSize.medium:
        trackWidth = 44;
        trackHeight = 24;
        thumbSize = 20;
        thumbInset = 2;
      case ParkSwitchSize.large:
        trackWidth = 52;
        trackHeight = 28;
        thumbSize = 24;
        thumbInset = 2;
    }

    final activeColor = widget.activeColor ?? park.colors.brand;
    final inactiveColor = widget.inactiveColor ?? park.colors.border;

    final trackColor = isOn ? activeColor : inactiveColor;
    final finalTrackColor = isDisabled
        ? trackColor.withValues(alpha: 0.4)
        : trackColor;

    // Thumb offset: how far the thumb center is from the left edge
    final thumbOffset = isOn ? trackWidth - thumbSize - thumbInset : thumbInset;

    final semanticsLabel = isOn
        ? (widget.checkedLabel ?? widget.label ?? widget.tooltip)
        : (widget.uncheckedLabel ?? widget.label ?? widget.tooltip);

    Widget switchWidget = Semantics(
      toggled: isOn,
      button: true,
      enabled: !isDisabled && !widget.readOnly,
      label: semanticsLabel,
      onTap: state.toggle,
      child: GestureDetector(
      onTap: state.toggle,
      child: AnimatedContainer(
        duration: park.motion.standard,
        curve: park.motion.defaultEasing,
        width: trackWidth,
        height: trackHeight,
        decoration: BoxDecoration(
          color: finalTrackColor,
          borderRadius: BorderRadius.circular(park.radius.full),
        ),
        child: Stack(
          children: [
            // Track content
            if (widget.checkedContent != null || widget.uncheckedContent != null)
              AnimatedSwitcher(
                duration: park.motion.quick,
                child: isOn
                    ? widget.checkedContent != null
                        ? Padding(
                            key: const ValueKey('checked'),
                            padding: EdgeInsets.only(
                              left: thumbInset + 2,
                              right: thumbSize + thumbInset,
                            ),
                            child: Center(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: park.typography.sizeOverline,
                                  color: park.colors.textOnBrand,
                                  fontWeight: FontWeight.w500,
                                ),
                                child: widget.checkedContent!,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()
                    : widget.uncheckedContent != null
                        ? Padding(
                            key: const ValueKey('unchecked'),
                            padding: EdgeInsets.only(
                              left: thumbInset + 2,
                              right: thumbSize + thumbInset,
                            ),
                            child: Center(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: park.typography.sizeOverline,
                                  color: park.colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                child: widget.uncheckedContent!,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
            // Thumb
            AnimatedPositioned(
              duration: park.motion.standard,
              curve: park.motion.defaultEasing,
              left: thumbOffset,
              top: thumbInset,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: park.colors.surface,
                  shape: BoxShape.circle,
                  boxShadow: park.shadows.sm,
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: isOn ? activeColor : park.colors.textSecondary,
                        ),
                      )
                    : isOn && widget.checkedChild != null
                        ? widget.checkedChild!
                        : !isOn && widget.uncheckedChild != null
                            ? widget.uncheckedChild!
                            : widget.thumbIcon != null
                                ? Icon(
                                    widget.thumbIcon!,
                                    size: thumbSize * 0.55,
                                    color: isOn
                                        ? activeColor
                                        : park.colors.textSecondary,
                                  )
                                : null,
              ),
            ),
          ],
        ),
      ),
      ),
    );

    if (widget.tooltip != null) {
      switchWidget = Tooltip(
        message: widget.tooltip!,
        child: switchWidget,
      );
    }

    if (widget.label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          switchWidget,
          SizedBox(width: park.spacing.sm),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: park.typography.sizeBody,
              color: isDisabled
                  ? park.colors.textDisabled
                  : park.colors.textPrimary,
            ),
          ),
        ],
      );
    }

    return switchWidget;
  }
}
