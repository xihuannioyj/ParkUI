import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

import 'demos/base_demos.dart';
import 'demos/input_demos.dart';
import 'demos/display_demos.dart';
import 'demos/feedback_demos.dart';
import 'demos/navigation_demos.dart';
import 'demos/form_demos.dart';
import 'demos/tree_demos.dart';
import 'demos/upload_demos.dart';
import 'demos/textarea_demos.dart';
import 'demos/search_demos.dart';
import 'demos/radio_demos.dart';
import 'demos/checkbox_demos.dart';
import 'demos/stepper_demos.dart';
import 'demos/rate_demos.dart';
import 'demos/countdown_demos.dart';

void main() {
  runApp(const ParkExampleApp());
}

// =============================================================================
// 分类数据模型
// =============================================================================

class _ComponentCategory {
  final String titleZh;
  final String titleEn;
  final String titleJa;
  final IconData icon;
  final List<_ComponentEntry> entries;

  const _ComponentCategory({
    required this.titleZh,
    required this.titleEn,
    required this.titleJa,
    required this.icon,
    required this.entries,
  });
}

class _ComponentEntry {
  final String title;
  final WidgetBuilder builder;

  const _ComponentEntry({required this.title, required this.builder});
}

// =============================================================================
// 组件目录
// =============================================================================

const List<_ComponentCategory> _categories = [
  _ComponentCategory(
    titleZh: '基础',
    titleEn: 'Base',
    titleJa: '基本',
    icon: Icons.widgets,
    entries: [
      _ComponentEntry(title: 'Button 按钮', builder: _buildButtonDemo),
      _ComponentEntry(title: 'Text 文本', builder: _buildTextDemo),
      _ComponentEntry(title: 'Icon 图标', builder: _buildIconDemo),
      _ComponentEntry(title: 'Divider 分割线', builder: _buildDividerDemo),
      _ComponentEntry(title: 'Fab 悬浮按钮', builder: _buildFabDemo),
    ],
  ),
  _ComponentCategory(
    titleZh: '输入',
    titleEn: 'Input',
    titleJa: '入力',
    icon: Icons.edit,
    entries: [
      _ComponentEntry(title: 'Input 输入框', builder: _buildInputDemo),
      _ComponentEntry(title: 'Select 选择器', builder: _buildSelectDemo),
      _ComponentEntry(title: 'DatePicker 日期选择', builder: _buildDatePickerDemo),
      _ComponentEntry(title: 'Switch 开关', builder: _buildSwitchDemo),
      _ComponentEntry(title: 'Slider 滑块', builder: _buildSliderDemo),
    ],
  ),
  _ComponentCategory(
    titleZh: '数据展示',
    titleEn: 'Display',
    titleJa: 'データ表示',
    icon: Icons.table_chart,
    entries: [
      _ComponentEntry(title: 'Table 表格', builder: _buildTableDemo),
      _ComponentEntry(title: 'Card 卡片', builder: _buildCardDemo),
      _ComponentEntry(title: 'Avatar 头像', builder: _buildAvatarDemo),
      _ComponentEntry(title: 'Badge 徽标', builder: _buildBadgeDemo),
      _ComponentEntry(title: 'Tag 标签', builder: _buildTagDemo),
    ],
  ),
  _ComponentCategory(
    titleZh: '反馈',
    titleEn: 'Feedback',
    titleJa: 'フィードバック',
    icon: Icons.info_outline,
    entries: [
      _ComponentEntry(title: 'Dialog 对话框', builder: _buildDialogDemo),
      _ComponentEntry(title: 'Toast 轻提示', builder: _buildToastDemo),
      _ComponentEntry(title: 'Loading 加载', builder: _buildLoadingDemo),
      _ComponentEntry(title: 'Notification 通知', builder: _buildNotificationDemo),
    ],
  ),
  _ComponentCategory(
    titleZh: '导航',
    titleEn: 'Navigation',
    titleJa: 'ナビゲーション',
    icon: Icons.navigation,
    entries: [
      _ComponentEntry(title: 'TabBar 底部导航', builder: _buildTabBarDemo),
      _ComponentEntry(title: 'Menu 导航菜单', builder: _buildMenuDemo),
      _ComponentEntry(title: 'Breadcrumb 面包屑', builder: _buildBreadcrumbDemo),
      _ComponentEntry(title: 'Pagination 分页', builder: _buildPaginationDemo),
    ],
  ),
];

// =============================================================================
// Demo builder 函数（转发到各 demo 文件中的 StatelessWidget）
// =============================================================================

Widget _buildButtonDemo(BuildContext context) => const ButtonDemo();
Widget _buildTextDemo(BuildContext context) => const TextDemo();
Widget _buildIconDemo(BuildContext context) => const IconDemo();
Widget _buildDividerDemo(BuildContext context) => const DividerDemo();
Widget _buildFabDemo(BuildContext context) => const FabDemo();
Widget _buildInputDemo(BuildContext context) => const InputDemo();
Widget _buildSelectDemo(BuildContext context) => const SelectDemo();
Widget _buildDatePickerDemo(BuildContext context) => const DatePickerDemo();
Widget _buildSwitchDemo(BuildContext context) => const SwitchDemo();
Widget _buildSliderDemo(BuildContext context) => const SliderDemo();
Widget _buildTableDemo(BuildContext context) => const TableDemo();
Widget _buildCardDemo(BuildContext context) => const CardDemo();
Widget _buildAvatarDemo(BuildContext context) => const AvatarDemo();
Widget _buildBadgeDemo(BuildContext context) => const BadgeDemo();
Widget _buildTagDemo(BuildContext context) => const TagDemo();
Widget _buildDialogDemo(BuildContext context) => const DialogDemo();
Widget _buildToastDemo(BuildContext context) => const ToastDemo();
Widget _buildLoadingDemo(BuildContext context) => const LoadingDemo();
Widget _buildNotificationDemo(BuildContext context) => const NotificationDemo();
Widget _buildTabBarDemo(BuildContext context) => const TabBarDemo();
Widget _buildMenuDemo(BuildContext context) => const MenuDemo();
Widget _buildBreadcrumbDemo(BuildContext context) => const BreadcrumbDemo();
Widget _buildPaginationDemo(BuildContext context) => const PaginationDemo();

// =============================================================================
// 本地化标题辅助
// =============================================================================

String _categoryTitle(_ComponentCategory cat, ParkLocale locale) {
  switch (locale) {
    case ParkLocale.zh:
      return cat.titleZh;
    case ParkLocale.en:
      return cat.titleEn;
    case ParkLocale.ja:
      return cat.titleJa;
  }
}

// =============================================================================
// App 入口
// =============================================================================

class ParkExampleApp extends StatefulWidget {
  const ParkExampleApp({super.key});

  @override
  State<ParkExampleApp> createState() => _ParkExampleAppState();
}

class _ParkExampleAppState extends State<ParkExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;
  ParkLocale _locale = ParkLocale.zh;

  ParkLocalizations get _localizations {
    switch (_locale) {
      case ParkLocale.zh:
        return const ParkLocalizationsZh();
      case ParkLocale.en:
        return const ParkLocalizationsEn();
      case ParkLocale.ja:
        return const ParkLocalizationsJa();
    }
  }

  ParkThemeData get _parkTheme =>
      _themeMode == ThemeMode.dark ? ParkThemeData.dark() : ParkThemeData.light();

  ThemeData get _materialTheme {
    final isDark = _themeMode == ThemeMode.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorSchemeSeed: _parkTheme.colors.brand,
      extensions: [_parkTheme],
    );
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _cycleLocale() {
    setState(() {
      switch (_locale) {
        case ParkLocale.zh:
          _locale = ParkLocale.en;
          break;
        case ParkLocale.en:
          _locale = ParkLocale.ja;
          break;
        case ParkLocale.ja:
          _locale = ParkLocale.zh;
          break;
      }
    });
  }

  String get _localeLabel {
    switch (_locale) {
      case ParkLocale.zh:
        return '中';
      case ParkLocale.en:
        return 'EN';
      case ParkLocale.ja:
        return '日';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ParkConfigProvider(
      theme: _parkTheme,
      child: ParkLocalizationsWidget(
        localizations: _localizations,
        child: MaterialApp(
          title: 'Park UI Example',
          debugShowCheckedModeBanner: false,
          theme: _materialTheme,
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: ParkThemeData.dark().colors.brand,
            extensions: [ParkThemeData.dark()],
          ),
          themeMode: _themeMode,
          builder: (ctx, child) {
            // Re-inject ParkConfigProvider below Navigator for overlay context.
            return ParkConfigProvider(
              theme: _parkTheme,
              child: ParkLocalizationsWidget(
                localizations: _localizations,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: _HomePage(
            locale: _locale,
            onToggleTheme: _toggleTheme,
            onCycleLocale: _cycleLocale,
            localeLabel: _localeLabel,
            isDark: _themeMode == ThemeMode.dark,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 首页 — 分类导航
// =============================================================================

class _HomePage extends StatelessWidget {
  final ParkLocale locale;
  final VoidCallback onToggleTheme;
  final VoidCallback onCycleLocale;
  final String localeLabel;
  final bool isDark;

  const _HomePage({
    required this.locale,
    required this.onToggleTheme,
    required this.onCycleLocale,
    required this.localeLabel,
    required this.isDark,
  });

  String get _appTitle {
    switch (locale) {
      case ParkLocale.zh:
        return 'Park UI 组件示例';
      case ParkLocale.en:
        return 'Park UI Components';
      case ParkLocale.ja:
        return 'Park UI コンポーネント';
    }
  }

  String get _subtitle {
    switch (locale) {
      case ParkLocale.zh:
        return '选择一个分类浏览组件';
      case ParkLocale.en:
        return 'Select a category to browse components';
      case ParkLocale.ja:
        return 'カテゴリを選択してコンポーネントを閲覧';
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = context.parkTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_appTitle),
        actions: [
          // 语言切换
          TextButton(
            onPressed: onCycleLocale,
            child: Text(
              localeLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          // 主题切换
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
            tooltip: isDark ? 'Light mode' : 'Dark mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _subtitle,
            style: TextStyle(
              color: park.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ..._categories.map((cat) => _buildCategoryCard(context, cat, park)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, _ComponentCategory cat, ParkThemeData park) {
    final title = _categoryTitle(cat, locale);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ParkCard(
        titleText: title,
        hoverable: true,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _CategoryPage(
                  category: cat,
                  locale: locale,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(cat.icon, color: park.colors.brand, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${cat.entries.length} '
                      '${locale == ParkLocale.zh ? "个组件" : locale == ParkLocale.ja ? "コンポーネント" : "components"}',
                      style: TextStyle(
                        color: park.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: park.colors.textPlaceholder, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cat.entries
                    .map((e) => ParkTag(
                          text: e.title.split(' ').first,
                          size: ParkTagSize.small,
                          theme: ParkTagTheme.primary,
                          variant: ParkTagVariant.outline,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 分类页面 — 组件列表
// =============================================================================

class _CategoryPage extends StatelessWidget {
  final _ComponentCategory category;
  final ParkLocale locale;

  const _CategoryPage({required this.category, required this.locale});

  String get _pageTitle {
    switch (locale) {
      case ParkLocale.zh:
        return category.titleZh;
      case ParkLocale.en:
        return category.titleEn;
      case ParkLocale.ja:
        return category.titleJa;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_pageTitle)),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: category.entries.length,
        itemBuilder: (context, index) {
          final entry = category.entries[index];
          return ListTile(
            title: Text(entry.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _DemoPage(entry: entry),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// Demo 页面
// =============================================================================

class _DemoPage extends StatelessWidget {
  final _ComponentEntry entry;

  const _DemoPage({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: entry.builder(context),
    );
  }
}
