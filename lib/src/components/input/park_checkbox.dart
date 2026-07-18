import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';

// ============================================================================
// ParkCheckbox
// ============================================================================

/// Park UI 复选框形状
enum ParkCheckboxShape {
  /// 方形（默认）
  square,

  /// 圆形
  circle,
}

/// Park UI 复选框
///
/// 基于 [FormField<bool>] 封装，支持选中、未选中、半选（indeterminate）
/// 三种状态，支持方形/圆形外观。
///
/// ```dart
/// ParkCheckbox(
///   value: true,
///   label: Text('同意协议'),
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkCheckbox extends FormField<bool> implements ParkBindableWidget {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkCheckbox({
    super.key,
    this.bindKey,
    this.bindingService,
    bool value = false,
    this.onChanged,
    this.label,
    this.shape = ParkCheckboxShape.square,
    this.size = 20,
    this.disabled = false,
    this.indeterminate = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.onFocus,
    this.onBlur,
    this.formValue,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<bool> field) {
            final state = field as _ParkCheckboxState;
            final park =
                Theme.of(state.context).extension<ParkThemeData>() ??
                    ParkThemeData.light();
            return _ParkCheckboxBuilder(state: state, park: park);
          },
        );

  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final ParkCheckboxShape shape;
  final double size;
  final bool disabled;
  final bool indeterminate;

  /// 是否只读。外观正常但不可交互。
  final bool readOnly;

  /// 是否自动获取焦点。
  final bool autoFocus;

  /// 获取焦点回调
  final VoidCallback? onFocus;

  /// 失去焦点回调
  final VoidCallback? onBlur;

  /// 表单值（用于 FormField 集成的显式值标识）
  final dynamic formValue;

  @override
  FormFieldState<bool> createState() => _ParkCheckboxState();
}

class _ParkCheckboxState extends FormFieldState<bool>
    with SingleTickerProviderStateMixin, BindableFormFieldMixin<bool> {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: ParkMotion.defaults.quick,
      vsync: this,
      value: (value ?? false) ? 1.0 : 0.0,
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    // Animation rebuild scope is handled by AnimatedBuilder in the widget tree,
    // avoiding full setState rebuilds every frame.
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void toggle() {
    final widget = this.widget as ParkCheckbox;
    if (widget.disabled || widget.readOnly) return;
    final newValue = !(value ?? false);
    didChange(newValue);
    widget.onChanged?.call(newValue);
    if (newValue) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void didChange(bool? value) {
    super.didChange(value);
    if (value == true) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }
}

class _ParkCheckboxBuilder extends StatelessWidget {
  const _ParkCheckboxBuilder({required this.state, required this.park});

  final _ParkCheckboxState state;
  final ParkThemeData park;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as ParkCheckbox;
    final isChecked = state.value ?? false;
    final isDisabled = widget.disabled;
    final isIndeterminate = widget.indeterminate;

    final borderRadius = widget.shape == ParkCheckboxShape.circle
        ? BorderRadius.circular(widget.size / 2)
        : park.radius.brXs;

    final bgColor = isDisabled
        ? park.colors.disabledBg
        : (isChecked || isIndeterminate)
            ? park.colors.brand
            : park.colors.surface;

    final borderColor = isDisabled
        ? park.colors.borderLight
        : (isChecked || isIndeterminate)
            ? park.colors.brand
            : park.colors.border;

    return Focus(
      autofocus: widget.autoFocus,
      child: Semantics(
        button: true,
        label: widget.label != null ? '${isChecked ? '✓' : '○'} ${widget.label}' : null,
        enabled: !isDisabled,
        checked: isChecked,
        child: GestureDetector(
          onTap: state.toggle,
          child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: isChecked
                ? AnimatedBuilder(
                    animation: state._scaleAnim,
                    child: Icon(
                      Icons.check_rounded,
                      size: widget.size * 0.65,
                      color: park.colors.textOnBrand,
                    ),
                    builder: (BuildContext context, Widget? child) {
                      return Transform.scale(
                        scale: state._scaleAnim.value,
                        child: child,
                      );
                    },
                  )
                : isIndeterminate
                    ? Center(
                        child: Container(
                          width: widget.size * 0.5,
                          height: 2,
                          decoration: BoxDecoration(
                            color: park.colors.textOnBrand,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      )
                    : null,
          ),
          if (widget.label != null) ...[
            SizedBox(width: park.spacing.sm),
            Flexible(
              child: DefaultTextStyle(
                style: park.typography.body.copyWith(
                  color: isDisabled
                      ? park.colors.textDisabled
                      : park.colors.textPrimary,
                ),
                child: widget.label!,
              ),
            ),
          ],
        ],
      ),
    ),
    ),
    );
  }
}


// ============================================================================
// ParkCheckboxOption
// ============================================================================

/// Park UI 复选框选项（富模型）
///
/// 相比简单的字符串选项，提供 label / value / disabled 三个字段，
/// 适用于需要精细化控制每个选项禁用状态的场景。
class ParkCheckboxOption {
  /// 显示文字
  final String label;

  /// 选项值（用于选中态匹配）
  final String value;

  /// 是否禁用
  final bool disabled;

  const ParkCheckboxOption({
    required this.label,
    required this.value,
    this.disabled = false,
  });
}

// ============================================================================
// ParkCheckboxGroup
// ============================================================================

/// Park UI 复选框组布局
enum ParkCheckboxGroupLayout {
  /// 水平排列
  horizontal,

  /// 垂直排列
  vertical,

  /// 自动换行排列
  wrap,
}

/// Park UI 复选框组
///
/// 将多个 [ParkCheckbox] 组合为一个整体，支持水平、垂直、自动换行布局，
/// 提供已选值列表的回调。
///
/// ```dart
/// ParkCheckboxGroup(
///   options: ['选项A', '选项B', '选项C'],
///   value: ['选项A'],
///   layout: ParkCheckboxGroupLayout.wrap,
///   onChanged: (selected) => print(selected),
/// )
/// ```
class ParkCheckboxGroup extends StatefulWidget {
  const ParkCheckboxGroup({
    super.key,
    this.options = const <ParkCheckboxOption>[],
    this.value = const [],
    this.onChanged,
    this.layout = ParkCheckboxGroupLayout.vertical,
    this.disabled = false,
    this.selectAll = false,
  });

  /// 选项列表（富模型，单一真源 API）。
  final List<ParkCheckboxOption> options;

  /// 已选中的值
  final List<String> value;

  /// 选中值变化回调。
  ///
  /// [values] 当前选中的值列表；[selectedOptions] 当前选中的富选项列表。
  final void Function(List<String> values, List<ParkCheckboxOption> selectedOptions)? onChanged;

  /// 布局方式
  final ParkCheckboxGroupLayout layout;

  /// 是否禁用
  final bool disabled;

  /// 是否在顶部显示"全选"复选框
  final bool selectAll;

  @override
  State<ParkCheckboxGroup> createState() => _ParkCheckboxGroupState();
}

class _ParkCheckboxGroupState extends State<ParkCheckboxGroup> {
  late List<String> _selected;

  /// 统一解析后的选项列表
  List<ParkCheckboxOption> get _resolvedOptions => widget.options;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.value);
  }

  @override
  void didUpdateWidget(covariant ParkCheckboxGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selected = List<String>.from(widget.value);
    }
  }

  void _toggle(ParkCheckboxOption option) {
    if (widget.disabled || option.disabled) return;
    setState(() {
      if (_selected.contains(option.value)) {
        _selected.remove(option.value);
      } else {
        _selected.add(option.value);
      }
    });
    _fireCallbacks();
  }

  void _toggleAll(bool allSelected) {
    if (widget.disabled) return;
    final enabledOptions =
        _resolvedOptions.where((ParkCheckboxOption o) => !o.disabled).toList();
    setState(() {
      if (allSelected) {
        // 取消全选：移除所有非禁用选项
        for (final opt in enabledOptions) {
          _selected.remove(opt.value);
        }
      } else {
        // 全选：添加所有非禁用选项
        for (final opt in enabledOptions) {
          if (!_selected.contains(opt.value)) {
            _selected.add(opt.value);
          }
        }
      }
    });
    _fireCallbacks();
  }

  void _fireCallbacks() {
    final List<ParkCheckboxOption> selected = _resolvedOptions
        .where((ParkCheckboxOption o) => _selected.contains(o.value))
        .toList();
    widget.onChanged?.call(List<String>.from(_selected), selected);
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final resolvedOptions = _resolvedOptions;

    final checkboxes = resolvedOptions.map((ParkCheckboxOption option) {
      final isSelected = _selected.contains(option.value);
      return ParkCheckbox(
        value: isSelected,
        label: Text(option.label),
        disabled: widget.disabled || option.disabled,
        onChanged: (_) => _toggle(option),
      );
    }).toList();

    // 全选逻辑
    Widget? selectAllWidget;
    if (widget.selectAll) {
      final enabledOptions = resolvedOptions
          .where((ParkCheckboxOption o) => !o.disabled)
          .toList();
      final allSelected = enabledOptions.isNotEmpty &&
          enabledOptions.every(
              (ParkCheckboxOption o) => _selected.contains(o.value));
      final someSelected = enabledOptions.any(
          (ParkCheckboxOption o) => _selected.contains(o.value));

      selectAllWidget = ParkCheckbox(
        value: allSelected,
        indeterminate: !allSelected && someSelected,
        label: Text(ParkLocalizations.of(context).selectAllText),
        disabled: widget.disabled,
        onChanged: (_) => _toggleAll(allSelected),
      );
    }

    switch (widget.layout) {
      case ParkCheckboxGroupLayout.horizontal:
        final items = <Widget>[];
        if (selectAllWidget != null) {
          items.add(Padding(
            padding: EdgeInsets.only(right: park.spacing.base),
            child: selectAllWidget,
          ));
        }
        items.addAll(checkboxes.map(
          (Widget cb) => Padding(
            padding: EdgeInsets.only(right: park.spacing.base),
            child: cb,
          ),
        ));
        return Row(mainAxisSize: MainAxisSize.min, children: items);

      case ParkCheckboxGroupLayout.vertical:
        final items = <Widget>[];
        if (selectAllWidget != null) {
          items.add(Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: selectAllWidget,
          ));
          // 全选与选项间加分隔线
          items.add(Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: Divider(height: 1, color: park.colors.borderLight),
          ));
        }
        items.addAll(checkboxes.map(
          (Widget cb) => Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: cb,
          ),
        ));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: items,
        );

      case ParkCheckboxGroupLayout.wrap:
        final items = <Widget>[];
        if (selectAllWidget != null) items.add(selectAllWidget);
        items.addAll(checkboxes);
        return Wrap(
          spacing: park.spacing.base,
          runSpacing: park.spacing.sm,
          children: items,
        );
    }
  }
}
