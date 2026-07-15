import 'package:flutter/material.dart';
import 'park_theme_data.dart';

/// 全局主题配置提供者。
///
/// 对标 Ant Design ConfigProvider，通过 [InheritedWidget] 机制向子树注入
/// [ParkThemeData]，根治组件内 `?? ParkThemeData.light()` 静默降级问题。
///
/// 用法：
/// ```dart
/// ParkConfigProvider(
///   theme: ParkThemeData.light(),
///   child: MaterialApp(
///     home: MyPage(),
///   ),
/// )
/// ```
///
/// 组件内消费：
/// ```dart
/// final park = ParkConfigProvider.of(context);
/// ```
///
/// 或使用扩展方法：
/// ```dart
/// final park = context.parkTheme;
/// ```
class ParkConfigProvider extends InheritedWidget {
  /// 全局主题数据。为 null 时 [of] 会触发 assert 失败。
  final ParkThemeData? theme;

  /// 创建 [ParkConfigProvider]。
  const ParkConfigProvider({
    super.key,
    this.theme,
    required super.child,
  });

  /// 获取最近的 [ParkThemeData]。
  ///
  /// 若未找到 [ParkConfigProvider] 或 [theme] 为 null，在 debug 模式下
  /// 触发 assert 错误，提示开发者包裹 [ParkConfigProvider]。
  static ParkThemeData of(BuildContext context) {
    final ParkConfigProvider? provider =
        context.dependOnInheritedWidgetOfExactType<ParkConfigProvider>();
    assert(
      provider?.theme != null,
      'ParkConfigProvider not found in widget tree. '
      'Wrap your app with ParkConfigProvider and provide a theme.',
    );
    return provider!.theme!;
  }

  /// 获取最近的 [ParkThemeData]，若不存在则返回 null。
  ///
  /// 与 [of] 不同，此方法不会触发 assert，适用于可选消费场景。
  static ParkThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ParkConfigProvider>()
        ?.theme;
  }

  @override
  bool updateShouldNotify(covariant ParkConfigProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}

/// [BuildContext] 扩展，提供便捷的主题访问方法。
extension ParkConfigProviderContextExtension on BuildContext {
  /// 获取最近的 [ParkThemeData]（需要 [ParkConfigProvider] 已注入）。
  ParkThemeData get parkTheme => ParkConfigProvider.of(this);

  /// 获取最近的 [ParkThemeData]，若不存在则返回 null。
  ParkThemeData? get maybeParkTheme => ParkConfigProvider.maybeOf(this);
}
