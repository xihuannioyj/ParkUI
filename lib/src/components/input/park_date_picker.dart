import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';
import 'park_input.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

/// 日期选择器模式
enum ParkDatePickerMode {
  /// 仅日期（年月日）
  date,

  /// 仅时间（时分）
  time,

  /// 日期 + 时间
  dateTime,

  /// 年月
  yearMonth,
}

/// 日期选择器快捷选项
class ParkDatePickerShortcut {
  /// 显示文字
  final String label;

  /// 对应的日期值
  final DateTime date;

  const ParkDatePickerShortcut({required this.label, required this.date});

  /// 今天
  factory ParkDatePickerShortcut.today() =>
      ParkDatePickerShortcut(label: '今天', date: DateTime.now());

  /// 最近7天
  factory ParkDatePickerShortcut.last7Days() =>
      ParkDatePickerShortcut(
        label: '近7天',
        date: DateTime.now().subtract(const Duration(days: 7)),
      );

  /// 最近30天
  factory ParkDatePickerShortcut.last30Days() =>
      ParkDatePickerShortcut(
        label: '近30天',
        date: DateTime.now().subtract(const Duration(days: 30)),
      );

  /// 本月第一天
  factory ParkDatePickerShortcut.thisMonth() {
    final now = DateTime.now();
    return ParkDatePickerShortcut(
      label: '本月',
      date: DateTime(now.year, now.month, 1),
    );
  }
}

/// 日期选择器尺寸
enum ParkDatePickerSize {
  /// 小尺寸
  small,

  /// 中尺寸
  medium,

  /// 大尺寸
  large,
}

/// Park 日期选择器
///
/// 继承 [FormField]，可直接嵌入 [Form] 使用。
/// 点击输入框弹出底部面板，使用 [CupertinoDatePicker] 进行日期 / 时间选择。
///
/// ```dart
/// ParkDatePicker(
///   label: '出生日期',
///   hintText: '请选择日期',
///   mode: ParkDatePickerMode.date,
///   onChanged: (dt) => print(dt),
/// )
/// ```
class ParkDatePicker extends FormField<DateTime> {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  /// 当前选中日期
  final DateTime? value;

  /// 可选最早日期
  final DateTime? firstDate;

  /// 可选最晚日期
  final DateTime? lastDate;

  /// 日期变更回调。清除时传入 null。
  final ValueChanged<DateTime?>? onChanged;

  /// 选择器模式
  final ParkDatePickerMode mode;

  /// 输入框占位文字
  final String? hintText;

  /// 输入框标签
  final String? label;

  /// 快捷选项列表
  final List<ParkDatePickerShortcut>? shortcuts;

  /// 自定义日期格式字符串（如 'yyyy/MM/dd', 'MM-dd HH:mm'）。
  /// 支持 yyyy/MM/dd/HH/mm/ss 占位符，为 null 时使用内置格式。
  final String? format;

  /// 动态禁用日期回调，返回 true 的日期不可选。
  final bool Function(DateTime)? disabledDate;

  /// 是否显示清除按钮
  final bool clearable;

  /// 尺寸
  final ParkDatePickerSize size;

  /// 输入框状态
  final ParkInputStatus? status;

  /// 是否显示边框
  final bool bordered;

  /// 自定义后缀图标，替换默认日历图标
  final Widget? suffixIcon;

  /// 是否允许清空日期为 null。默认 false。
  final bool allowEmpty;

  /// 本地化设置（影响日期选择器的语言和格式）
  final Locale? locale;

  /// 清除日期时的回调
  final VoidCallback? onClear;

  /// 是否显示时间选择面板（dateTime 模式的快捷方式）
  final bool showTime;

  /// 预设快捷日期（key 为显示文字，value 为日期值）
  final Map<String, DateTime>? presets;

  ParkDatePicker({
    super.key,
    this.bindKey,
    this.bindingService,
    this.value,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.mode = ParkDatePickerMode.date,
    this.hintText,
    this.label,
    this.shortcuts,
    this.format,
    this.disabledDate,
    this.clearable = false,
    this.size = ParkDatePickerSize.medium,
    this.status,
    this.bordered = true,
    this.suffixIcon,
    this.allowEmpty = false,
    this.locale,
    this.onClear,
    this.showTime = false,
    this.presets,
    super.onSaved,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
         initialValue: value,
         builder: (FormFieldState<DateTime> field) {
           final state = field as _ParkDatePickerState;
           final park =
               Theme.of(field.context).extension<ParkThemeData>() ??
               ParkThemeData.light();

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               if (state.widget.label != null)
                 Padding(
                   padding: EdgeInsets.only(bottom: park.spacing.xs),
                   child: Text(
                     state.widget.label!,
                     style: TextStyle(
                       fontSize: park.typography.sizeBodySmall,
                       color: park.colors.textSecondary,
                       fontWeight: park.typography.weightMedium,
                     ),
                   ),
                 ),
               _buildInput(state, park),
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
           );
         },
       );

  static Widget _buildInput(_ParkDatePickerState state, ParkThemeData park) {
    final widget = state.widget;
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final currentValue = state.value;
    final hasValue = currentValue != null;

    // Size mapping
    final double fontSize;
    final double vPadding;
    final double hPadding;
    final double iconSz;

    switch (widget.size) {
      case ParkDatePickerSize.small:
        fontSize = typo.sizeBodySmall;
        vPadding = spacing.xs;
        hPadding = spacing.sm;
        iconSz = 16;
      case ParkDatePickerSize.medium:
        fontSize = typo.sizeBody;
        vPadding = spacing.md;
        hPadding = spacing.md;
        iconSz = 18;
      case ParkDatePickerSize.large:
        fontSize = typo.sizeH3;
        vPadding = spacing.base;
        hPadding = spacing.lg;
        iconSz = 20;
    }

    // Border color logic
    Color borderColor;
    if (widget.status != null) {
      switch (widget.status!) {
        case ParkInputStatus.error:
          borderColor = colors.error;
        case ParkInputStatus.warning:
          borderColor = colors.warning;
        case ParkInputStatus.success:
          borderColor = colors.success;
      }
    } else if (state.hasError) {
      borderColor = colors.error;
    } else if (state._isFocused || state._isHovered) {
      borderColor = colors.brand;
    } else {
      borderColor = colors.border;
    }

    // Build suffix widget
    Widget suffixWidget;
    if (widget.clearable && hasValue && widget.allowEmpty) {
      suffixWidget = GestureDetector(
        onTap: () {
          state.didChange(null);
          widget.onChanged?.call(null);
          widget.onClear?.call();
        },
        child: Icon(
          Icons.cancel_outlined,
          size: iconSz,
          color: colors.textPlaceholder,
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffixWidget = widget.suffixIcon!;
    } else {
      suffixWidget = Icon(
        _iconForMode(widget.mode),
        size: iconSz,
        color: colors.textPlaceholder,
      );
    }

    final input = GestureDetector(
      onTap: () => _showPicker(state),
      child: AnimatedContainer(
        duration: ParkMotion.standard,
        curve: ParkMotion.defaultEasing,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: hPadding,
          vertical: vPadding,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(radius.md),
          border: widget.bordered
              ? Border.all(color: borderColor, width: 1.0)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue
                    ? _formatDate(currentValue, widget.mode, widget.format)
                    : (widget.hintText ?? '请选择'),
                style: TextStyle(
                  fontSize: fontSize,
                  color: hasValue ? colors.textPrimary : colors.textPlaceholder,
                ),
              ),
            ),
            suffixWidget,
          ],
        ),
      ),
    );

    return Focus(
      onFocusChange: (hasFocus) {
        state.updateFocus(hasFocus);
      },
      child: MouseRegion(
        onEnter: (_) {
          state.updateHover(true);
        },
        onExit: (_) {
          state.updateHover(false);
        },
        child: input,
      ),
    );
  }

  static IconData _iconForMode(ParkDatePickerMode mode) {
    switch (mode) {
      case ParkDatePickerMode.date:
      case ParkDatePickerMode.yearMonth:
        return Icons.calendar_today_outlined;
      case ParkDatePickerMode.time:
        return Icons.access_time_outlined;
      case ParkDatePickerMode.dateTime:
        return Icons.calendar_today_outlined;
    }
  }

  static String _formatDate(DateTime dt, ParkDatePickerMode mode, String? format) {
    String pad(int n) => n.toString().padLeft(2, '0');

    // Custom format: replace tokens
    if (format != null) {
      return format
          .replaceAll('yyyy', dt.year.toString())
          .replaceAll('MM', pad(dt.month))
          .replaceAll('dd', pad(dt.day))
          .replaceAll('HH', pad(dt.hour))
          .replaceAll('mm', pad(dt.minute))
          .replaceAll('ss', pad(dt.second));
    }

    switch (mode) {
      case ParkDatePickerMode.date:
        return '${dt.year}-${pad(dt.month)}-${pad(dt.day)}';
      case ParkDatePickerMode.time:
        return '${pad(dt.hour)}:${pad(dt.minute)}';
      case ParkDatePickerMode.dateTime:
        return '${dt.year}-${pad(dt.month)}-${pad(dt.day)} ${pad(dt.hour)}:${pad(dt.minute)}';
      case ParkDatePickerMode.yearMonth:
        return '${dt.year}-${pad(dt.month)}';
    }
  }

  static void _showPicker(_ParkDatePickerState state) async {
    final widget = state.widget;
    final context = state.context;
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    DateTime tempDate = state.value ?? DateTime.now();

    final CupertinoDatePickerMode cupertinoMode;
    switch (widget.mode) {
      case ParkDatePickerMode.date:
        cupertinoMode = CupertinoDatePickerMode.date;
        break;
      case ParkDatePickerMode.time:
        cupertinoMode = CupertinoDatePickerMode.time;
        break;
      case ParkDatePickerMode.dateTime:
        cupertinoMode = CupertinoDatePickerMode.dateAndTime;
        break;
      case ParkDatePickerMode.yearMonth:
        cupertinoMode = CupertinoDatePickerMode.date;
        break;
    }

    await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _DatePickerSheet(
          title: widget.label,
          mode: cupertinoMode,
          initialDateTime: tempDate,
          minimumDate: widget.firstDate,
          maximumDate: widget.lastDate,
          useYearMonth: widget.mode == ParkDatePickerMode.yearMonth,
          onDateChanged: (dt) {
            tempDate = dt;
          },
          shortcuts: widget.shortcuts,
          onShortcutTap: (date) {
            tempDate = date;
            Navigator.of(ctx).pop(date);
          },
          park: park,
          disabledDate: widget.disabledDate,
        );
      },
    ).then((result) {
      if (result != null) {
        // Validate against disabledDate callback
        if (widget.disabledDate != null && widget.disabledDate!(result)) {
          return; // date is disabled, do not accept
        }
        state.didChange(result);
        widget.onChanged?.call(result);
      }
    });
  }

  @override
  FormFieldState<DateTime> createState() => _ParkDatePickerState();
}

class _ParkDatePickerState extends FormFieldState<DateTime>
    with BindableFormFieldMixin<DateTime> {
  bool _isFocused = false;
  bool _isHovered = false;

  /// 更新焦点态。
  void updateFocus(bool value) {
    setState(() => _isFocused = value);
  }

  /// 更新悬停态。
  void updateHover(bool value) {
    setState(() => _isHovered = value);
  }

  @override
  ParkDatePicker get widget => super.widget as ParkDatePicker;
}

/// 内部：日期选择器底部面板
class _DatePickerSheet extends StatefulWidget {
  final String? title;
  final CupertinoDatePickerMode mode;
  final DateTime initialDateTime;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final bool useYearMonth;
  final ValueChanged<DateTime> onDateChanged;
  final List<ParkDatePickerShortcut>? shortcuts;
  final ValueChanged<DateTime>? onShortcutTap;
  final ParkThemeData park;
  final bool Function(DateTime)? disabledDate;

  const _DatePickerSheet({
    this.title,
    required this.mode,
    required this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
    required this.useYearMonth,
    required this.onDateChanged,
    this.shortcuts,
    this.onShortcutTap,
    required this.park,
    this.disabledDate,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _tempDate;

  @override
  void initState() {
    super.initState();
    _tempDate = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final park = widget.park;
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部操作栏
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.base,
                vertical: spacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: typo.sizeBody,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: TextStyle(
                        fontSize: typo.sizeH3,
                        fontWeight: typo.weightMedium,
                        color: colors.textPrimary,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(_tempDate),
                    child: Text(
                      '确认',
                      style: TextStyle(
                        fontSize: typo.sizeBody,
                        color: colors.brand,
                        fontWeight: typo.weightMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.divider),

            // Shortcuts
            if (widget.shortcuts != null && widget.shortcuts!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  spacing.sm,
                  spacing.base,
                  spacing.xs,
                ),
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.xs,
                  children: widget.shortcuts!.map((shortcut) {
                    return GestureDetector(
                      onTap: () => widget.onShortcutTap?.call(shortcut.date),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(radius.sm),
                          border: Border.all(
                            color: colors.brand.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          shortcut.label,
                          style: TextStyle(
                            fontSize: typo.sizeBodySmall,
                            color: colors.brand,
                            fontWeight: typo.weightMedium,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: spacing.xs),
            ],

            // 日期选择器
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: widget.mode,
                initialDateTime: widget.initialDateTime,
                minimumDate: widget.minimumDate,
                maximumDate: widget.maximumDate,
                onDateTimeChanged: (dt) {
                  _tempDate = dt;
                  widget.onDateChanged(dt);
                },
              ),
            ),

            SizedBox(height: spacing.base),
          ],
        ),
      ),
    );
  }
}
