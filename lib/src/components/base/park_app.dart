import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/park_config_provider.dart';
import '../../l10n/park_localizations.dart';

/// ParkApp — 全局配置包装器
///
/// 对标 Ant Design ConfigProvider，封装 [MaterialApp] + [ParkConfigProvider] +
/// [ParkLocalizationsWidget]，统一注入主题、本地化和 Overlay context。
///
/// 使用 [ParkApp] 替代直接使用 [MaterialApp]，可自动完成：
/// - [ParkThemeData] 注入（亮色/暗色主题自动切换）
/// - [ParkLocalizations] 注入（中/英/日等语言）
/// - [ParkConfigProvider] 注入（组件内可通过 `context.parkTheme` 访问）
///
/// ```dart
/// ParkApp(
///   title: 'My App',
///   parkTheme: ParkThemeData.light(),
///   locale: ParkLocale.zh,
///   home: MyHomePage(),
/// )
/// ```
class ParkApp extends StatelessWidget {
  /// 应用标题（透传给 [MaterialApp.title]）。
  final String title;

  /// Park 主题数据（亮色预设）。
  /// 为 null 时使用 [ParkThemeData.light()]。
  final ParkThemeData? parkTheme;

  /// Park 暗色主题数据。
  /// 为 null 时使用 [ParkThemeData.dark()]。
  final ParkThemeData? parkDarkTheme;

  /// 当前主题模式（亮色/暗色/跟随系统）。
  final ThemeMode themeMode;

  /// 当前语言环境。
  final ParkLocale locale;

  /// 应用首页页面。
  final Widget? home;

  /// 自定义子组件（优先级高于 [home]）。
  final Widget? child;

  /// Flutter [MaterialApp] 常用参数透传 — 初始路由。
  final String? initialRoute;

  /// Flutter [MaterialApp] 常用参数透传 — 路由生成器。
  final RouteFactory? onGenerateRoute;

  /// Flutter [MaterialApp] 常用参数透传 — 路由表。
  final Map<String, WidgetBuilder>? routes;

  /// Flutter [MaterialApp] 常用参数透传 — 全局 builder。
  final TransitionBuilder? builder;

  /// Flutter [MaterialApp] 常用参数透传 — 暗色主题 [ThemeData]。
  final ThemeData? darkTheme;

  /// Flutter [MaterialApp] 常用参数透传 — 亮色主题 [ThemeData]。
  final ThemeData? theme;

  /// Flutter [MaterialApp] 常用参数透传 — 是否显示调试标记。
  final bool debugShowCheckedModeBanner;

  /// Flutter [MaterialApp] 常用参数透传 — 导航观察者。
  final List<NavigatorObserver>? navigatorObservers;

  /// 额外的 [ThemeExtension] 列表（追加到 [ThemeData.extensions] 中）。
  final List<ThemeExtension<dynamic>>? additionalExtensions;

  const ParkApp({
    super.key,
    this.title = 'Park App',
    this.parkTheme,
    this.parkDarkTheme,
    this.themeMode = ThemeMode.system,
    this.locale = ParkLocale.zh,
    this.home,
    this.child,
    this.initialRoute,
    this.onGenerateRoute,
    this.routes,
    this.builder,
    this.darkTheme,
    this.theme,
    this.debugShowCheckedModeBanner = false,
    this.navigatorObservers,
    this.additionalExtensions,
  });

  /// 根据 [ParkLocale] 获取对应的 [ParkLocalizations] 实例。
  static ParkLocalizations _localizationsFor(ParkLocale locale) {
    switch (locale) {
      case ParkLocale.zh:
        return const ParkLocalizationsZh();
      case ParkLocale.en:
        return const ParkLocalizationsEn();
      case ParkLocale.ja:
        return const ParkLocalizationsJa();
    }
  }

  /// 根据主题模式构建亮色和暗色 [ThemeData]。
  ThemeData _buildMaterialTheme(
    ParkThemeData parkTheme,
    bool isDark,
    ThemeData? overrideTheme,
  ) {
    final base = overrideTheme ??
        ThemeData(
          useMaterial3: true,
          brightness: isDark ? Brightness.dark : Brightness.light,
          colorSchemeSeed: parkTheme.colors.brand,
        );
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        parkTheme,
        ...?additionalExtensions,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightPark = parkTheme ?? ParkThemeData.light();
    final darkPark = parkDarkTheme ?? ParkThemeData.dark();
    final localizations = _localizationsFor(locale);

    return ParkConfigProvider(
      theme: lightPark,
      child: ParkLocalizationsWidget(
        localizations: localizations,
        child: Builder(
          builder: (innerContext) {
            return MaterialApp(
              title: title,
              debugShowCheckedModeBanner: debugShowCheckedModeBanner,
              themeMode: themeMode,
              theme: _buildMaterialTheme(lightPark, false, theme),
              darkTheme: _buildMaterialTheme(darkPark, true, darkTheme),
              initialRoute: initialRoute,
              onGenerateRoute: onGenerateRoute,
              routes: routes ?? <String, WidgetBuilder>{},
              navigatorObservers: navigatorObservers ?? const [],
              builder: (ctx, navChild) {
                // 重新注入 ParkConfigProvider 到 Navigator context 之下，
                // 确保 Overlay 弹窗（Toast/Dialog/Notification）也能获取主题。
                Widget result = navChild ?? const SizedBox.shrink();
                if (builder != null) {
                  result = builder!(ctx, result);
                }
                return ParkConfigProvider(
                  theme: ParkConfigProvider.maybeOf(innerContext) ?? lightPark,
                  child: ParkLocalizationsWidget(
                    localizations: localizations,
                    child: result,
                  ),
                );
              },
              home: routes != null ? null : (child ?? home),
            );
          },
        ),
      ),
    );
  }
}

/// Park UI 支持的语言环境枚举。
///
/// 用于 [ParkApp.locale] 参数，控制组件内文案语言。
enum ParkLocale {
  /// 中文（默认）
  zh,

  /// 英文
  en,

  /// 日文
  ja,
}
