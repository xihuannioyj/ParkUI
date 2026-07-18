import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

/// Park UI 评分
///
/// 基于 [FormField<double>] 封装的星级评分控件，支持整星和半星评分、
/// 只读模式、自定义星星数量和尺寸、自定义字符/图标。
///
/// ```dart
/// ParkRate(
///   value: 3.5,
///   count: 5,
///   allowHalf: true,
///   onChanged: (v) => print(v),
/// )
/// ```
///
/// 使用自定义字符：
/// ```dart
/// ParkRate(
///   value: 2,
///   count: 5,
///   character: Icon(ParkIcons.heart, color: Colors.red),
///   allowHalf: true,
///   onChanged: (v) => print(v),
/// )
/// ```
///
/// 每项独立字符：
/// ```dart
/// ParkRate(
///   value: 3,
///   count: 5,
///   characters: [
///     Icon(ParkIcons.emoji_sad),
///     Icon(ParkIcons.emoji_neutral),
///     Icon(ParkIcons.emoji_smile),
///     Icon(ParkIcons.emoji_laugh),
///     Icon(ParkIcons.emoji_celebrate),
///   ],
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkRate extends FormField<double> implements ParkBindableWidget {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkRate({
    super.key,
    this.bindKey,
    this.bindingService,
    double value = 0,
    this.count = 5,
    this.size = 24,
    this.onChanged,
    this.readOnly = false,
    this.allowHalf = false,
    this.activeColor,
    this.inactiveColor,
    this.icon,
    this.character,
    this.characters,
    this.tooltips,
    this.showText = false,
    this.textBuilder,
    this.disabled = false,
    this.gap,
    this.allowClear = true,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
  }) : super(
          initialValue: value.clamp(0, count.toDouble()),
          builder: (FormFieldState<double> field) {
            final state = field as _ParkRateState;
            final park =
                Theme.of(state.context).extension<ParkThemeData>() ??
                    ParkThemeData.light();
            return _ParkRateBuilder(state: state, park: park);
          },
        );

  final int count;
  final double size;
  final ValueChanged<double>? onChanged;
  final bool readOnly;
  final bool allowHalf;
  final Color? activeColor;
  final Color? inactiveColor;

  /// 自定义图标（替代默认星形）。
  final IconData? icon;

  /// 完全自定义的评分项 widget（覆盖 icon）。
  final Widget? character;

  /// 每个评分项的独立自定义字符（数量需与 [count] 匹配）。
  ///
  /// 优先级高于 [character]。当某个索引未提供对应字符时，降级使用 [character]
  /// 或默认星星。
  final List<Widget>? characters;

  /// 每个评分项的 tooltip 文字。
  final List<String>? tooltips;

  /// 是否在星星右侧显示 "value / count" 文字。
  final bool showText;

  /// 自定义文字格式化回调。
  final String Function(double value, int count)? textBuilder;

  /// 是否禁用。灰显且不可交互。
  final bool disabled;

  /// 星星之间的间距。为 null 时使用默认间距。
  final double? gap;

  /// 是否允许点击已选星星来清除评分。默认 true。
  final bool allowClear;

  @override
  FormFieldState<double> createState() => _ParkRateState();
}

class _ParkRateState extends FormFieldState<double>
    with BindableFormFieldMixin<double> {
  @override
  void didChange(double? value) {
    super.didChange(value);
    (widget as ParkRate).onChanged?.call(value ?? 0);
  }
}

class _ParkRateBuilder extends StatelessWidget {
  const _ParkRateBuilder({required this.state, required this.park});

  final _ParkRateState state;
  final ParkThemeData park;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as ParkRate;
    final currentValue = state.value ?? 0;
    final isInteractive = !widget.readOnly && !widget.disabled;
    final effectiveActiveColor = widget.disabled
        ? (widget.activeColor ?? park.colors.warning).withValues(alpha: 0.4)
        : (widget.activeColor ?? park.colors.warning);
    final effectiveInactiveColor = widget.disabled
        ? (widget.inactiveColor ?? park.colors.border).withValues(alpha: 0.4)
        : (widget.inactiveColor ?? park.colors.border);
    final effectiveGap = widget.gap ?? 0.0;

    final stars = List.generate(widget.count, (index) {
      // 字符优先级：characters[index] > character > 默认星星
      final bool useCharacters = widget.characters != null &&
          index < widget.characters!.length;
      final bool useCharacter = widget.character != null;

      Widget item;
      if (useCharacters) {
        item = _CharacterItem(
          index: index,
          value: currentValue,
          size: widget.size,
          activeColor: effectiveActiveColor,
          inactiveColor: effectiveInactiveColor,
          allowHalf: widget.allowHalf,
          readOnly: widget.readOnly || widget.disabled,
          allowClear: widget.allowClear,
          character: widget.characters![index],
          onTap: isInteractive
              ? (selectedValue) {
                  state.didChange(selectedValue);
                }
              : null,
        );
      } else if (useCharacter) {
        item = _CharacterItem(
          index: index,
          value: currentValue,
          size: widget.size,
          activeColor: effectiveActiveColor,
          inactiveColor: effectiveInactiveColor,
          allowHalf: widget.allowHalf,
          readOnly: widget.readOnly || widget.disabled,
          allowClear: widget.allowClear,
          character: widget.character!,
          onTap: isInteractive
              ? (selectedValue) {
                  state.didChange(selectedValue);
                }
              : null,
        );
      } else {
        item = _StarItem(
          index: index,
          value: currentValue,
          size: widget.size,
          activeColor: effectiveActiveColor,
          inactiveColor: effectiveInactiveColor,
          allowHalf: widget.allowHalf,
          readOnly: widget.readOnly || widget.disabled,
          allowClear: widget.allowClear,
          icon: widget.icon,
          onTap: isInteractive
              ? (selectedValue) {
                  state.didChange(selectedValue);
                }
              : null,
        );
      }

      // Wrap with tooltip if provided
      if (widget.tooltips != null && index < widget.tooltips!.length) {
        item = Tooltip(
          message: widget.tooltips![index],
          child: item,
        );
      }

      return item;
    });

    return Semantics(
      slider: true,
      value: currentValue.toStringAsFixed(widget.allowHalf ? 1 : 0),
      enabled: isInteractive,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < stars.length; i++) ...[
            if (i > 0) SizedBox(width: effectiveGap),
            stars[i],
          ],
          if (widget.showText) ...[
            SizedBox(width: park.spacing.sm),
            Text(
              widget.textBuilder?.call(currentValue, widget.count) ??
                  '${currentValue % 1 == 0 ? currentValue.toInt() : currentValue} / ${widget.count}',
              style: park.typography.bodySmall.copyWith(
                color: park.colors.textPrimary,
                fontWeight: park.typography.weightMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarItem extends StatelessWidget {
  const _StarItem({
    required this.index,
    required this.value,
    required this.size,
    required this.activeColor,
    required this.inactiveColor,
    required this.allowHalf,
    required this.readOnly,
    required this.onTap,
    this.icon,
    this.allowClear = true,
  });

  final int index;
  final double value;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalf;
  final bool readOnly;
  final ValueChanged<double>? onTap;
  final IconData? icon;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final starValue = index + 1.0;
    final isFull = value >= starValue;
    final isHalf = allowHalf && !isFull && value >= index + 0.5;
    final displayValue = isFull ? starValue : (isHalf ? index + 0.5 : 0.0);

    return Semantics(
      button: true,
      value: displayValue.toString(),
      child: GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              if (allowClear && value == starValue) {
                onTap!(0);
              } else if (value != starValue) {
                onTap!(starValue);
              }
            },
      child: allowHalf && !readOnly
          ? GestureDetector(
              onTap: null,
              child: Stack(
                children: [
                  _buildStar(isFull ? 1.0 : (isHalf ? 0.5 : 0.0)),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: size / 2,
                      child: GestureDetector(
                        onTap: () {
                          final halfValue = index + 0.5;
                          if (onTap != null) {
                            if (allowClear && value == halfValue) {
                              onTap!(0);
                            } else if (value != halfValue) {
                              onTap!(halfValue);
                            }
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: size / 2,
                      child: GestureDetector(
                        onTap: () {
                          final fullValue = index + 1.0;
                          if (onTap != null) {
                            if (allowClear && value == fullValue) {
                              onTap!(0);
                            } else if (value != fullValue) {
                              onTap!(fullValue);
                            }
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _buildStar(isFull ? 1.0 : 0.0),
      ),
    );
  }

  Widget _buildStar(double fill) {
    final iconData = icon ?? Icons.star_rounded;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Icon(
            iconData,
            size: size,
            color: inactiveColor,
          ),
          if (fill > 0)
            ClipRect(
              clipper: _StarClipper(fill),
              child: Icon(
                iconData,
                size: size,
                color: activeColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _CharacterItem extends StatelessWidget {
  const _CharacterItem({
    required this.index,
    required this.value,
    required this.size,
    required this.activeColor,
    required this.inactiveColor,
    required this.allowHalf,
    required this.readOnly,
    required this.character,
    required this.onTap,
    this.allowClear = true,
  });

  final int index;
  final double value;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalf;
  final bool readOnly;
  final Widget character;
  final ValueChanged<double>? onTap;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    final starValue = index + 1.0;
    final isFull = value >= starValue;
    final isHalf = allowHalf && !isFull && value >= index + 0.5;
    final double fill = isFull ? 1.0 : (isHalf ? 0.5 : 0.0);
    final displayValue = isFull ? starValue : (isHalf ? index + 0.5 : 0.0);

    Widget content = SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.25,
            child: SizedBox(
              width: size,
              height: size,
              child: FittedBox(child: character),
            ),
          ),
          if (fill > 0)
            ClipRect(
              clipper: _StarClipper(fill),
              child: SizedBox(
                width: size,
                height: size,
                child: FittedBox(child: character),
              ),
            ),
        ],
      ),
    );

    return Semantics(
      button: true,
      value: displayValue.toString(),
      child: GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              if (allowClear && value == starValue) {
                onTap!(0);
              } else if (value != starValue) {
                onTap!(starValue);
              }
            },
      child: allowHalf && !readOnly
          ? GestureDetector(
              onTap: null,
              child: Stack(
                children: [
                  content,
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: size / 2,
                      child: GestureDetector(
                        onTap: () {
                          final halfValue = index + 0.5;
                          if (onTap != null) {
                            if (allowClear && value == halfValue) {
                              onTap!(0);
                            } else if (value != halfValue) {
                              onTap!(halfValue);
                            }
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: size / 2,
                      child: GestureDetector(
                        onTap: () {
                          final fullValue = index + 1.0;
                          if (onTap != null) {
                            if (allowClear && value == fullValue) {
                              onTap!(0);
                            } else if (value != fullValue) {
                              onTap!(fullValue);
                            }
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : content,
      ),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  _StarClipper(this.fill);

  final double fill;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fill, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return oldClipper.fill != fill;
  }
}
