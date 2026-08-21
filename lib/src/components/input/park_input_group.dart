import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_sizing.dart';
import 'park_input.dart';

/// Park 紧凑组合输入组件。
///
/// 将多个输入类控件（[ParkInput] / [ParkSelect] / [ParkButton] 等）组合成一个
/// 视觉一体的紧凑容器。
///
/// - [compact] 为 `true`（默认）：外层提供单一圆角边框并裁剪，相邻子项之间以
///   1px 分隔线隔开，子项需自行设置 `bordered: false` 以去除中间边框。
/// - [compact] 为 `false`：子项各自保留边框，按 [spacing] 间距排列。
///
/// 组高由 [size] 统一控制（small:32 / medium:48 / large:56），与
/// [ParkInput] / [ParkSelect] 的高度映射一致；组内的 [ParkButton] 子项请通过
/// `ParkButton(height: <组高>)` 传入覆盖高度，做到严格等高。
///
/// ```dart
/// ParkInputGroup(
///   children: [
///     ParkInput(hintText: '姓名', bordered: false),
///     ParkSelect(
///       items: [ParkSelectOption(label: '北京', value: 'bj')],
///       bordered: false,
///     ),
///     ParkButton(height: 48, child: Text('搜索')),
///   ],
/// )
/// ```
class ParkInputGroup extends StatelessWidget {
  /// 子组件列表（通常为 ParkInput / ParkSelect / ParkButton / Text 等）。
  final List<Widget> children;

  /// 是否紧凑模式（默认 true）。
  ///
  /// 紧凑模式下外层单一圆角边框 + 裁剪 + 相邻 1px 分隔线，视觉一体；
  /// 非紧凑模式下子项各自保留边框，按 [spacing] 间距排列。
  final bool compact;

  /// 统一组高尺寸，控制容器高度（small:32 / medium:48 / large:56）。
  final ParkInputSize size;

  /// 紧凑模式下是否在相邻子项之间显示 1px 分隔线（默认 true）。
  final bool divider;

  /// 非紧凑模式下的子项间距（默认 8）。
  final double spacing;

  /// 非紧凑模式下的主轴对齐方式（默认 [MainAxisAlignment.start]）。
  final MainAxisAlignment mainAxisAlignment;

  /// 是否整体禁用（默认 false）。
  final bool disabled;

  const ParkInputGroup({
    super.key,
    required this.children,
    this.compact = true,
    this.size = ParkInputSize.medium,
    this.divider = true,
    this.spacing = 8,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.disabled = false,
  });

  /// 根据尺寸返回组高（与 ParkInput / ParkSelect 高度映射保持一致）。
  double _groupHeight(ParkSizing sizing) {
    switch (size) {
      case ParkInputSize.small:
        return sizing.inputHeightSm;
      case ParkInputSize.medium:
        return sizing.inputHeightMd;
      case ParkInputSize.large:
        return sizing.inputHeightLg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final radius = park.radius;
    final sizing = park.sizing;

    final Color borderColor = disabled ? colors.divider : colors.border;
    final Color bgColor = disabled ? colors.disabledBg : colors.surface;

    if (!compact) {
      // 非紧凑：子项各自保留边框，按间距排列，组本身不画边框。
      final Widget row = Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: spacing),
            children[i],
          ],
        ],
      );
      // P1-10：disabled 时阻断子项交互（原实现只改颜色形同虚设）
      return disabled
          ? IgnorePointer(child: row)
          : row;
    }

    // 紧凑模式：单一圆角边框 + 裁剪 + 相邻 1px 分隔线，子项填满组高。
    final List<Widget> rowChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0 && divider) {
        rowChildren.add(
          Container(
            width: 1,
            height: _groupHeight(sizing) - 16,
            color: colors.divider,
          ),
        );
      }
      rowChildren.add(Expanded(child: children[i]));
    }

    final Widget group = Container(
      // +2 用于边框（1px 上下）。子项通过 Expanded + CrossAxisAlignment.stretch
      // 自动填满内容区，无需额外留空。
      height: _groupHeight(sizing) + 2,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius.brSm,
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rowChildren,
      ),
    );
    // P1-10：disabled 时阻断子项交互（原实现只改颜色形同虚设）
    return disabled ? IgnorePointer(child: group) : group;
  }
}
