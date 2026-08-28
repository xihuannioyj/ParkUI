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
import 'demos/statistic_demos.dart';
import 'demos/empty_demos.dart';
import 'demos/timeline_demos.dart';
import 'demos/progress_demos.dart';
import 'demos/result_demos.dart';
import 'demos/link_demos.dart';
import 'demos/display_extra_demos.dart';
import 'demos/input_extra_demos.dart';
import 'demos/feedback_extra_demos.dart';
import 'demos/navigation_extra_demos.dart';
import 'demos/base_extra_demos.dart';
import 'demos/base_extra2_demos.dart';
import 'demos/display_extra2_demos.dart';
import 'demos/feedback_extra2_demos.dart';
import 'demos/input_extra2_demos.dart';
import 'demos/navigation_extra2_demos.dart';
import 'demos/input_extra3_demos.dart';
import 'demos/display_extra3_demos.dart';
import 'demos/feedback_extra3_demos.dart';
import 'demos/navigation_extra3_demos.dart';
import 'demos/park_map_demo.dart';

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
      _ComponentEntry(title: 'Space 间距', builder: _buildSpaceDemo),
      _ComponentEntry(title: 'Link 链接', builder: _buildLinkDemo),
      _ComponentEntry(title: 'Flex 弹性布局', builder: _buildFlexDemo),
      _ComponentEntry(title: 'Typography 标题排版', builder: _buildTypographyDemo),
      _ComponentEntry(title: 'FloatButton 悬浮按钮', builder: _buildFloatButtonDemo),
      _ComponentEntry(title: 'InkWell 点击容器', builder: _buildInkWellDemo),
      _ComponentEntry(title: 'ButtonGroup 按钮组', builder: _buildButtonGroupDemo),
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
      _ComponentEntry(title: 'Radio 单选框', builder: _buildRadioDemo),
      _ComponentEntry(title: 'Checkbox 复选框', builder: _buildCheckboxDemo),
      _ComponentEntry(title: 'Textarea 多行输入', builder: _buildTextareaDemo),
      _ComponentEntry(title: 'Search 搜索', builder: _buildSearchDemo),
      _ComponentEntry(title: 'Stepper 步进器', builder: _buildStepperDemo),
      _ComponentEntry(title: 'Rate 评分', builder: _buildRateDemo),
      _ComponentEntry(title: 'Upload 上传', builder: _buildUploadDemo),
      _ComponentEntry(title: 'Tree 树形控件', builder: _buildTreeDemo),
      _ComponentEntry(title: 'Cascader 级联选择', builder: _buildCascaderDemo),
      _ComponentEntry(title: 'TreeSelect 树选择', builder: _buildTreeSelectDemo),
      _ComponentEntry(title: 'Calendar 日历', builder: _buildCalendarDemo),
      _ComponentEntry(title: 'Segmented 分段控制', builder: _buildSegmentedDemo),
      _ComponentEntry(title: 'Transfer 穿梭框', builder: _buildTransferDemo),
      _ComponentEntry(title: 'AutoComplete 自动完成', builder: _buildAutoCompleteDemo),
      _ComponentEntry(title: 'InputNumber 数字输入框', builder: _buildInputNumberDemo),
      _ComponentEntry(title: 'TimePicker 时间选择', builder: _buildTimePickerDemo),
      _ComponentEntry(title: 'Mentions 提及', builder: _buildMentionsDemo),
      _ComponentEntry(title: 'Picker 滚轮选择器', builder: _buildPickerDemo),
      _ComponentEntry(title: 'ColorPicker 颜色选择器', builder: _buildColorPickerDemo),
      _ComponentEntry(title: 'DateRangePicker 日期范围', builder: _buildDateRangePickerDemo),
      _ComponentEntry(title: 'InputGroup 组合输入', builder: _buildInputGroupDemo),
    ],
  ),
  _ComponentCategory(
    titleZh: '表单',
    titleEn: 'Form',
    titleJa: 'フォーム',
    icon: Icons.description,
    entries: [
      _ComponentEntry(title: 'Form 表单', builder: _buildFormDemo),
      _ComponentEntry(title: 'DynamicForm 动态表单', builder: _buildDynamicFormDemo),
      _ComponentEntry(title: 'FormBuilder 构建器', builder: _buildFormBuilderDemo),
      _ComponentEntry(title: 'FormArray 表单数组', builder: _buildFormArrayDemo),
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
      _ComponentEntry(title: 'Descriptions 描述列表', builder: _buildDescriptionsDemo),
      _ComponentEntry(title: 'Countdown 倒计时', builder: _buildCountdownDemo),
      _ComponentEntry(title: 'Statistic 统计数值', builder: _buildStatisticDemo),
      _ComponentEntry(title: 'Empty 空状态', builder: _buildEmptyDemo),
      _ComponentEntry(title: 'Timeline 时间线', builder: _buildTimelineDemo),
      _ComponentEntry(title: 'QRCode 二维码', builder: _buildQRCodeDemo),
      _ComponentEntry(title: 'Watermark 水印', builder: _buildWatermarkDemo),
      _ComponentEntry(title: 'List 列表', builder: _buildListDemo),
      _ComponentEntry(title: 'Masonry 瀑布流', builder: _buildMasonryDemo),
      _ComponentEntry(title: 'Tooltip 文字提示', builder: _buildTooltipDemo),
      _ComponentEntry(title: 'Collapse 折叠面板', builder: _buildCollapseDemo),
      _ComponentEntry(title: 'Skeleton 骨架屏', builder: _buildSkeletonDemo),
      _ComponentEntry(title: 'Swiper 轮播', builder: _buildSwiperDemo),
      _ComponentEntry(title: 'Image 图片', builder: _buildImageDemo),
      _ComponentEntry(title: 'Ellipsis 文本省略', builder: _buildEllipsisDemo),
      _ComponentEntry(title: 'Cell 单元格', builder: _buildCellDemo),
      _ComponentEntry(title: 'Grid 网格布局', builder: _buildGridDemo),
      _ComponentEntry(title: 'Footer 页脚', builder: _buildFooterDemo),
      _ComponentEntry(title: 'Splitter 分割面板', builder: _buildSplitterDemo),
      _ComponentEntry(title: 'ImageViewer 图片查看器', builder: _buildImageViewerDemo),
      _ComponentEntry(title: 'Sticky 粘性定位', builder: _buildStickyDemo),
      _ComponentEntry(title: 'AvatarGroup 头像组', builder: _buildAvatarGroupDemo),
      _ComponentEntry(title: 'Map 地图', builder: _buildMapDemo),
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
      _ComponentEntry(title: 'Drawer 抽屉', builder: _buildDrawerDemo),
      _ComponentEntry(title: 'Message 全局消息', builder: _buildMessageDemo),
      _ComponentEntry(title: 'Progress 进度条', builder: _buildProgressDemo),
      _ComponentEntry(title: 'Result 结果', builder: _buildResultDemo),
      _ComponentEntry(title: 'Tour 引导步骤', builder: _buildTourDemo),
      _ComponentEntry(title: 'Popover 气泡卡片', builder: _buildPopoverDemo),
      _ComponentEntry(title: 'Alert 警告提示', builder: _buildAlertDemo),
      _ComponentEntry(title: 'ActionSheet 操作面板', builder: _buildActionSheetDemo),
      _ComponentEntry(title: 'NoticeBar 通知栏', builder: _buildNoticeBarDemo),
      _ComponentEntry(title: 'Popconfirm 气泡确认框', builder: _buildPopconfirmDemo),
      _ComponentEntry(title: 'SwipeCell 滑动单元格', builder: _buildSwipeCellDemo),
      _ComponentEntry(title: 'Overlay 遮罩层', builder: _buildOverlayDemo),
      _ComponentEntry(title: 'Popup 弹出面板', builder: _buildPopupDemo),
      _ComponentEntry(title: 'Refresh 下拉刷新', builder: _buildRefreshDemo),
      _ComponentEntry(title: 'DropdownMenu 下拉菜单', builder: _buildDropdownMenuDemo),
      _ComponentEntry(title: 'DropdownSheet 下拉面板', builder: _buildDropdownSheetDemo),
      _ComponentEntry(title: 'DropdownFilter 筛选', builder: _buildDropdownFilterDemo),
    ],
  ),
  _ComponentCategory(
    titleZh: '导航',
    titleEn: 'Navigation',
    titleJa: 'ナビゲーション',
    icon: Icons.navigation,
    entries: [
      _ComponentEntry(title: 'TabBar 底部导航', builder: _buildTabBarDemo),
      _ComponentEntry(title: 'Tabs 标签页', builder: _buildTabsDemo),
      _ComponentEntry(title: 'Menu 导航菜单', builder: _buildMenuDemo),
      _ComponentEntry(title: 'Breadcrumb 面包屑', builder: _buildBreadcrumbDemo),
      _ComponentEntry(title: 'Pagination 分页', builder: _buildPaginationDemo),
      _ComponentEntry(title: 'SideBar 侧边栏', builder: _buildSideBarDemo),
      _ComponentEntry(title: 'NavBar 导航栏', builder: _buildNavBarDemo),
      _ComponentEntry(title: 'Steps 步骤条', builder: _buildStepsDemo),
      _ComponentEntry(title: 'BackTop 回到顶部', builder: _buildBackTopDemo),
      _ComponentEntry(title: 'Indexes 字母索引', builder: _buildIndexesDemo),
      _ComponentEntry(title: 'Anchor 锚点导航', builder: _buildAnchorDemo),
      _ComponentEntry(title: 'Layout 页面布局', builder: _buildLayoutDemo),
      _ComponentEntry(title: 'BottomNav 底部导航', builder: _buildBottomNavDemo),
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
Widget _buildSpaceDemo(BuildContext context) => const SpaceDemo();
Widget _buildInputDemo(BuildContext context) => const InputDemo();
Widget _buildSelectDemo(BuildContext context) => const SelectDemo();
Widget _buildDatePickerDemo(BuildContext context) => const DatePickerDemo();
Widget _buildSwitchDemo(BuildContext context) => const SwitchDemo();
Widget _buildSliderDemo(BuildContext context) => const SliderDemo();
Widget _buildRadioDemo(BuildContext context) => const RadioDemo();
Widget _buildCheckboxDemo(BuildContext context) => const CheckboxDemo();
Widget _buildTextareaDemo(BuildContext context) => const TextareaDemo();
Widget _buildSearchDemo(BuildContext context) => const SearchDemo();
Widget _buildStepperDemo(BuildContext context) => const StepperDemo();
Widget _buildRateDemo(BuildContext context) => const RateDemo();
Widget _buildUploadDemo(BuildContext context) => const UploadDemo();
Widget _buildTreeDemo(BuildContext context) => const TreeDemo();
Widget _buildFormDemo(BuildContext context) => const FormDemo();
Widget _buildDynamicFormDemo(BuildContext context) => const DynamicFormDemo();
Widget _buildFormBuilderDemo(BuildContext context) => const FormBuilderDemo();
Widget _buildFormArrayDemo(BuildContext context) => const FormArrayDemo();
Widget _buildTableDemo(BuildContext context) => const TableDemo();
Widget _buildCardDemo(BuildContext context) => const CardDemo();
Widget _buildAvatarDemo(BuildContext context) => const AvatarDemo();
Widget _buildBadgeDemo(BuildContext context) => const BadgeDemo();
Widget _buildTagDemo(BuildContext context) => const TagDemo();
Widget _buildDescriptionsDemo(BuildContext context) => const DescriptionsDemo();
Widget _buildCountdownDemo(BuildContext context) => const CountdownDemo();
Widget _buildDialogDemo(BuildContext context) => const DialogDemo();
Widget _buildToastDemo(BuildContext context) => const ToastDemo();
Widget _buildLoadingDemo(BuildContext context) => const LoadingDemo();
Widget _buildNotificationDemo(BuildContext context) => const NotificationDemo();
Widget _buildDrawerDemo(BuildContext context) => const DrawerDemo();
Widget _buildMessageDemo(BuildContext context) => const MessageDemo();
Widget _buildTabBarDemo(BuildContext context) => const TabBarDemo();
Widget _buildTabsDemo(BuildContext context) => const TabsDemo();
Widget _buildMenuDemo(BuildContext context) => const MenuDemo();
Widget _buildBreadcrumbDemo(BuildContext context) => const BreadcrumbDemo();
Widget _buildPaginationDemo(BuildContext context) => const PaginationDemo();
Widget _buildStatisticDemo(BuildContext context) => const StatisticDemo();
Widget _buildEmptyDemo(BuildContext context) => const EmptyDemo();
Widget _buildTimelineDemo(BuildContext context) => const TimelineDemo();
Widget _buildProgressDemo(BuildContext context) => const ProgressDemo();
Widget _buildResultDemo(BuildContext context) => const ResultDemo();
Widget _buildLinkDemo(BuildContext context) => const LinkDemo();
Widget _buildQRCodeDemo(BuildContext context) => const QRCodeDemo();
Widget _buildWatermarkDemo(BuildContext context) => const WatermarkDemo();
Widget _buildListDemo(BuildContext context) => const ListDemo();
Widget _buildMasonryDemo(BuildContext context) => const MasonryDemo();
Widget _buildTooltipDemo(BuildContext context) => const TooltipDemo();
Widget _buildCascaderDemo(BuildContext context) => const CascaderDemo();
Widget _buildTreeSelectDemo(BuildContext context) => const TreeSelectDemo();
Widget _buildCalendarDemo(BuildContext context) => const CalendarDemo();
Widget _buildSegmentedDemo(BuildContext context) => const SegmentedDemo();
Widget _buildTransferDemo(BuildContext context) => const TransferDemo();
Widget _buildTourDemo(BuildContext context) => const TourDemo();
Widget _buildPopoverDemo(BuildContext context) => const PopoverDemo();
Widget _buildSideBarDemo(BuildContext context) => const SideBarDemo();
Widget _buildFlexDemo(BuildContext context) => const FlexDemo();
Widget _buildTypographyDemo(BuildContext context) => const TypographyDemo();
Widget _buildFloatButtonDemo(BuildContext context) => const FloatButtonDemo();
Widget _buildAutoCompleteDemo(BuildContext context) => const AutoCompleteDemo();
Widget _buildInputNumberDemo(BuildContext context) => const InputNumberDemo();
Widget _buildTimePickerDemo(BuildContext context) => const TimePickerDemo();
Widget _buildMentionsDemo(BuildContext context) => const MentionsDemo();
Widget _buildPickerDemo(BuildContext context) => const PickerDemo();
Widget _buildCollapseDemo(BuildContext context) => const CollapseDemo();
Widget _buildSkeletonDemo(BuildContext context) => const SkeletonDemo();
Widget _buildSwiperDemo(BuildContext context) => const SwiperDemo();
Widget _buildImageDemo(BuildContext context) => const ImageDemo();
Widget _buildEllipsisDemo(BuildContext context) => const EllipsisDemo();
Widget _buildCellDemo(BuildContext context) => const CellDemo();
Widget _buildAlertDemo(BuildContext context) => const AlertDemo();
Widget _buildActionSheetDemo(BuildContext context) => const ActionSheetDemo();
Widget _buildNoticeBarDemo(BuildContext context) => const NoticeBarDemo();
Widget _buildPopconfirmDemo(BuildContext context) => const PopconfirmDemo();
Widget _buildSwipeCellDemo(BuildContext context) => const SwipeCellDemo();
Widget _buildNavBarDemo(BuildContext context) => const NavBarDemo();
Widget _buildStepsDemo(BuildContext context) => const StepsDemo();
Widget _buildBackTopDemo(BuildContext context) => const BackTopDemo();
Widget _buildIndexesDemo(BuildContext context) => const IndexesDemo();
Widget _buildColorPickerDemo(BuildContext context) => const ColorPickerDemo();
Widget _buildDateRangePickerDemo(BuildContext context) => const DateRangePickerDemo();
Widget _buildInputGroupDemo(BuildContext context) => const InputGroupDemo();
Widget _buildGridDemo(BuildContext context) => const GridDemo();
Widget _buildFooterDemo(BuildContext context) => const FooterDemo();
Widget _buildSplitterDemo(BuildContext context) => const SplitterDemo();
Widget _buildImageViewerDemo(BuildContext context) => const ImageViewerDemo();
Widget _buildStickyDemo(BuildContext context) => const StickyDemo();
Widget _buildOverlayDemo(BuildContext context) => const OverlayDemo();
Widget _buildPopupDemo(BuildContext context) => const PopupDemo();
Widget _buildRefreshDemo(BuildContext context) => const RefreshDemo();
Widget _buildDropdownMenuDemo(BuildContext context) => const DropdownMenuDemo();
Widget _buildDropdownSheetDemo(BuildContext context) => const DropdownSheetDemo();
Widget _buildDropdownFilterDemo(BuildContext context) => const DropdownFilterDemo();
Widget _buildAnchorDemo(BuildContext context) => const AnchorDemo();
Widget _buildLayoutDemo(BuildContext context) => const LayoutDemo();
Widget _buildInkWellDemo(BuildContext context) => const InkWellDemo();
Widget _buildButtonGroupDemo(BuildContext context) => const ButtonGroupDemo();
Widget _buildAvatarGroupDemo(BuildContext context) => const AvatarGroupDemo();
Widget _buildBottomNavDemo(BuildContext context) => const BottomNavDemo();
Widget _buildMapDemo(BuildContext context) => const MapDemo();

// =============================================================================
// 本地化标题辅助
// =============================================================================

String _categoryTitle(_ComponentCategory cat, ParkLocale locale) {
  switch (locale) {
    case ParkLocale.zh:
      return cat.titleZh;
    case ParkLocale.en:
    case ParkLocale.ko:
    case ParkLocale.es:
    case ParkLocale.fr:
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
      case ParkLocale.ko:
        return const ParkLocalizationsKo();
      case ParkLocale.es:
        return const ParkLocalizationsEs();
      case ParkLocale.fr:
        return const ParkLocalizationsFr();
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
          _locale = ParkLocale.ko;
          break;
        case ParkLocale.ko:
          _locale = ParkLocale.es;
          break;
        case ParkLocale.es:
          _locale = ParkLocale.fr;
          break;
        case ParkLocale.fr:
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
      case ParkLocale.ko:
        return '한';
      case ParkLocale.es:
        return 'ES';
      case ParkLocale.fr:
        return 'FR';
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
      case ParkLocale.ko:
      case ParkLocale.es:
      case ParkLocale.fr:
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
      case ParkLocale.ko:
      case ParkLocale.es:
      case ParkLocale.fr:
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
      case ParkLocale.ko:
      case ParkLocale.es:
      case ParkLocale.fr:
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
