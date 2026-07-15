import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

/// 单选框布局方式
enum ParkRadioLayout {
  /// 水平排列
  horizontal,

  /// 垂直排列
  vertical,

  /// 自动换行
  wrap,
}

/// 单选框外观样式
enum ParkRadioStyle {
  /// 默认圆形指示器
  dot,

  /// 按钮式（分段器风格）
  button,
}

/// 单选框尺寸
enum ParkRadioSize {
  /// 小尺寸（指示器 16px，内圆点 8px）
  small,

  /// 中尺寸（指示器 20px，内圆点 10px）— 默认
  medium,

  /// 大尺寸（指示器 24px，内圆点 12px）
  large,
}

/// 单选选项数据
class ParkRadioOption {
  /// 显示文字
  final String label;

  /// 选项值
  final String value;

  /// 是否禁用
  final bool disabled;

  const ParkRadioOption({
    required this.label,
    required this.value,
    this.disabled = false,
  });
}

/// Park 单选框组
///
/// 支持水平 / 垂直 / 自动换行布局，带动画选中过渡效果。
/// 继承 [FormField]，可直接嵌入 [Form] 使用。
///
/// ```dart
/// ParkRadio(
///   options: [
///     ParkRadioOption(label: '选项 A', value: 'a'),
///     ParkRadioOption(label: '选项 B', value: 'b'),
///   ],
///   value: 'a',
///   onChanged: (v) => print('选中: $v'),
/// )
/// ```
class ParkRadio extends FormField<String> {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  /// 当前选中值
  final String? value;

  /// 选项列表
  final List<ParkRadioOption> options;

  /// 选中值变更回调
  final ValueChanged<String?>? onChanged;

  /// 布局方式
  final ParkRadioLayout layout;

  /// 外观样式
  final ParkRadioStyle radioStyle;

  /// 是否整体禁用
  final bool disabled;

  /// 卡片模式：每个选项渲染为一个带内边距的卡片容器。
  final bool card;

  /// 当 [card] 为 true 时，控制卡片是否显示边框。
  final bool bordered;

  /// 单选框尺寸
  final ParkRadioSize radioSize;

  /// 是否只读。外观正常但不可交互。
  final bool readOnly;

  /// 是否自动获取焦点。
  final bool autoFocus;

  /// 获取焦点回调
  final VoidCallback? onFocus;

  /// 失去焦点回调
  final VoidCallback? onBlur;

  /// 自定义选项渲染回调（覆盖默认选项渲染）
  final Widget Function(ParkRadioOption option, bool isSelected, VoidCallback? onTap)? optionBuilder;

  /// 按钮式模式下选项紧密拼接（去除间隙、合并边框）
  final bool buttonJoin;

  ParkRadio({
    super.key,
    this.bindKey,
    this.bindingService,
    this.value,
    required this.options,
    this.onChanged,
    this.layout = ParkRadioLayout.vertical,
    this.radioStyle = ParkRadioStyle.dot,
    this.disabled = false,
    this.card = false,
    this.bordered = true,
    this.radioSize = ParkRadioSize.medium,
    this.readOnly = false,
    this.autoFocus = false,
    this.onFocus,
    this.onBlur,
    this.optionBuilder,
    this.buttonJoin = false,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    bool autovalidateMode = false,
  }) : super(
          initialValue: value,
          onSaved: onSaved,
          validator: validator,
          autovalidateMode: autovalidateMode
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          builder: (FormFieldState<String> field) {
            final state = field as _ParkRadioState;
            final park = Theme.of(field.context)
                    .extension<ParkThemeData>() ??
                ParkThemeData.light();

            return Focus(
              autofocus: state.widget.autoFocus,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.widget.radioStyle == ParkRadioStyle.button)
                  _buildButtonStyle(state, park)
                else
                  _buildOptions(state, park),
                if (field.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: park.spacing.xs),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: park.colors.error,
                        fontSize: park.typography.sizeCaption,
                      ),
                    ),
                  ),
              ],
            ),
            );
          },
        );

  static Widget _buildOptions(_ParkRadioState state, ParkThemeData park) {
    final widget = state.widget;
    final colors = park.colors;
    final radius = park.radius;
    final spacing = park.spacing;
    final children = <Widget>[];

    for (final option in widget.options) {
      final isDisabled = widget.disabled || widget.readOnly || option.disabled;
      final isSelected = state.value == option.value;

      Widget item = ParkRadioItem(
        label: option.label,
        isSelected: isSelected,
        disabled: isDisabled,
        size: widget.radioSize,
        onTap: isDisabled
            ? null
            : () {
                state.didChange(option.value);
                widget.onChanged?.call(option.value);
              },
      );

      if (widget.card) {
        item = Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.base,
            vertical: spacing.sm,
          ),
          margin: EdgeInsets.only(bottom: spacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.brandLight.withValues(alpha: 0.06)
                : colors.surface,
            borderRadius: BorderRadius.circular(radius.md),
            border: widget.bordered
                ? Border.all(
                    color: isSelected ? colors.brand : colors.border,
                    width: isSelected ? 1.5 : 0.5,
                  )
                : null,
          ),
          child: item,
        );
      }

      children.add(item);
    }

    if (widget.card) {
      // Card 模式下不使用额外间距，每个卡片自带 margin
      switch (widget.layout) {
        case ParkRadioLayout.horizontal:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        case ParkRadioLayout.vertical:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          );
        case ParkRadioLayout.wrap:
          return Wrap(
            spacing: spacing.base,
            runSpacing: spacing.sm,
            children: children,
          );
      }
    }

    switch (widget.layout) {
      case ParkRadioLayout.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((c) => Padding(
                    padding: EdgeInsets.only(right: park.spacing.base),
                    child: c,
                  ))
              .toList(),
        );
      case ParkRadioLayout.vertical:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((c) => Padding(
                    padding: EdgeInsets.only(bottom: park.spacing.sm),
                    child: c,
                  ))
              .toList(),
        );
      case ParkRadioLayout.wrap:
        return Wrap(
          spacing: park.spacing.base,
          runSpacing: park.spacing.sm,
          children: children,
        );
    }
  }

  static Widget _buildButtonStyle(_ParkRadioState state, ParkThemeData park) {
    final widget = state.widget;
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final isJoin = widget.buttonJoin;

    final children = widget.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isDisabled = widget.disabled || widget.readOnly || option.disabled;
      final isSelected = state.value == option.value;

      return Expanded(
        child: Semantics(
          label: option.label,
          selected: isSelected,
          button: true,
          enabled: !isDisabled,
          child: GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  state.didChange(option.value);
                  widget.onChanged?.call(option.value);
                },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: park.motion.standard,
            curve: park.motion.enterEasing,
            padding: EdgeInsets.symmetric(
              horizontal: park.spacing.base,
              vertical: park.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colors.surface : Colors.transparent,
              borderRadius: isJoin
                  ? BorderRadius.zero
                  : radius.brXs,
              border: isJoin
                  ? Border(
                      right: index < widget.options.length - 1
                          ? BorderSide(color: colors.divider, width: 0.5)
                          : BorderSide.none,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: park.colors.overlay.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: widget.optionBuilder != null
                ? widget.optionBuilder!(option, isSelected, null)
                : Text(
                    option.label,
                    style: TextStyle(
                      fontSize: typo.sizeBody,
                      color: isDisabled
                          ? colors.textDisabled
                          : isSelected
                              ? colors.textPrimary
                              : colors.textSecondary,
                      fontWeight: isSelected
                          ? typo.weightMedium
                          : typo.weightRegular,
                    ),
                  ),
          ),
        ),
      ));
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.disabledBg,
        borderRadius: radius.brSm,
      ),
      child: isJoin ? Row(mainAxisSize: MainAxisSize.min, children: children) : Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  @override
  FormFieldState<String> createState() => _ParkRadioState();
}

class _ParkRadioState extends FormFieldState<String>
    with BindableFormFieldMixin<String> {
  @override
  ParkRadio get widget => super.widget as ParkRadio;
}

/// 单个单选框项
///
/// 带品牌色选中动画的圆形 Radio 指示器 + 标签文字。
class ParkRadioItem extends StatelessWidget {
  /// 显示文字
  final String label;

  /// 是否选中
  final bool isSelected;

  /// 是否禁用
  final bool disabled;

  /// 点击回调
  final VoidCallback? onTap;

  /// 尺寸规格
  final ParkRadioSize size;

  const ParkRadioItem({
    super.key,
    required this.label,
    this.isSelected = false,
    this.disabled = false,
    this.onTap,
    this.size = ParkRadioSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;

    // 根据尺寸计算外径和内圆点大小
    final double outerSize;
    final double innerDotSize;
    switch (size) {
      case ParkRadioSize.small:
        outerSize = 16;
        innerDotSize = 8;
      case ParkRadioSize.medium:
        outerSize = 20;
        innerDotSize = 10;
      case ParkRadioSize.large:
        outerSize = 24;
        innerDotSize = 12;
    }

    final borderColor = disabled
        ? colors.textDisabled
        : isSelected
            ? colors.brand
            : colors.border;

    final dotColor = disabled ? colors.textDisabled : colors.brand;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: park.motion.quick,
              curve: park.motion.defaultEasing,
              width: outerSize,
              height: outerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2.0 : 1.5,
                ),
                color: isSelected
                    ? colors.brandLight.withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: park.motion.quick,
                curve: park.motion.defaultEasing,
                width: isSelected ? innerDotSize : 0,
                height: isSelected ? innerDotSize : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
            ),
            SizedBox(width: park.spacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: park.typography.sizeBody,
                color: disabled ? colors.textDisabled : colors.textPrimary,
                fontWeight: isSelected
                    ? park.typography.weightMedium
                    : park.typography.weightRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
