import 'package:flutter/material.dart';

// =============================================================================
// ParkLocalizations — park_ui 全局国际化字符串
// =============================================================================

/// park_ui 本地化字符串抽象接口。
///
/// 所有组件中用户可见的文字都可由此接口统一管理。
/// 通过 [ParkLocalizationsWidget] 注入 Widget 树，
/// 组件内通过 `ParkLocalizations.of(context)` 获取。
///
/// 内置 [ParkLocalizationsZh]（中文默认）和 [ParkLocalizationsEn]（英文）两种实现。
/// 调用方可实现此接口并注入自定义本地化。
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ParkLocalizationsWidget(
///     localizations: ParkLocalizationsEn(),
///     child: child!,
///   ),
/// )
/// ```
abstract class ParkLocalizations {
  // ── 按钮 ──
  String get confirmText;
  String get cancelText;
  String get clearText;
  String get searchText;
  String get submitText;
  String get saveText;
  String get deleteText;
  String get closeText;
  String get doneText;
  String get resetText;

  // ── 占位 ──
  String get selectPlaceholder;
  String get inputPlaceholder;
  String get searchPlaceholder;

  // ── 状态 ──
  String get noData;
  String get noSearchResults;
  String get noPermission;
  String get loading;
  String get loadFailed;
  String get retry;
  String get success;
  String get warning;
  String get error;

  // ── 步骤 ──
  String get previousStep;
  String get nextStep;

  // ── 搜索 ──
  String get searchHistory;
  String get matchedHistory;
  String get noSearchHistory;

  // ── 其他 ──
  String get noMore;
  String get pullToRefresh;
  String get releaseToRefresh;
  String get refreshing;
  String get confirmDelete;

  // ── D4 分页 ──
  String get previousPage;
  String get nextPage;
  String get jumpTo;
  String get page;
  String totalInfo(int total);
  String pageSizeOption(int size);
  String paginationSemantics(int totalPages, int currentPage);
  String pageButtonSemantics(int page);
  String pageSizeSemantics(int pageSize);

  // ── D4 通用 ──
  String disabledLabel(String label);

  // ── D4 新增 ──
  String get searchOptionsHint;
  String get searchingText;
  String get defaultGroupLabel;
  String createOption(String keyword);
  String get gotItText;

  // ── D4 分组3 新增 ──
  String get noOptions;
  String get noMatchingOptions;
  String get expandText;
  String get collapseText;
  String get selectStartDate;
  String get selectEndDate;
  String get timeFilter;
  String get resetFilter;
  String get startTime;
  String get endTime;
  String get pleaseSelectFirst;
  String get imageLoadFailed;
  String get loadedAllData;
  String get obscureTextDisplayed;
  String get obscureTextHidden;
  String get requiredHint;
  String get decreaseValue;
  String get increaseValue;

  // ── 星期 ──
  String get weekdaySun;
  String get weekdayMon;
  String get weekdayTue;
  String get weekdayWed;
  String get weekdayThu;
  String get weekdayFri;
  String get weekdaySat;

  // ── 日历 ──
  String formatYearMonth(int year, int month);

  // ── 日历范围选择语义 ──
  String get rangeStartSemantic;
  String get rangeEndSemantic;
  String get rangeMiddleSemantic;

  // ── 级联多选 ──
  String selectedCount(int count);

  // ── 复选框 ──
  String get selectAllText;

  // ── 倒计时 ──
  String countdownLabel(String formatted);

  // ── 表单 ──
  String get formLoadingText;

  // ── 自动完成 ──
  String get searchHintText;

  // ── 回到顶部 ──
  String get backTop;

  // ── 面包屑 ──
  String get breadcrumbLabel;
  String get breadcrumbExpand;
  String breadcrumbHasSubmenu(String label);

  // ── D4 group8 ──
  String get forbiddenTitle;
  String get forbiddenDesc;
  String get notFoundTitle;
  String get notFoundDesc;
  String get serverErrorTitle;
  String get serverErrorDesc;
  String get sliderValueLabel;
  String get splitterLabel;
  String get collapseFirstHorizontal;
  String get collapseSecondHorizontal;
  String get collapseFirstVertical;
  String get collapseSecondVertical;

  // ── ParkUpload ──
  String get addFileText;
  String get uploadFailed;
  String get fileTypeNotSupported;
  String get imageOnlyUpload;
  String get imageOnlyConstraint;
  String fileSizeExceedsText(double maxSizeMB);
  String supportedFormatsText(List<String> formats);
  String singleFileLimitText(double maxSizeMB);
  String get deleteFileLabel;
  String get dragUploadAreaLabel;

  // ── B62 ParkText ──
  String get copiedText;

  // ── B62 ParkTimePicker ──
  String get selectTimeText;
  String get chooseTimeText;
  String get currentSelectionText;

  // ── B62 ParkDatePicker shortcuts ──
  String get shortcutToday;
  String get shortcutLast7Days;
  String get shortcutLast30Days;
  String get shortcutThisMonth;

  // ── B62 ParkCalendar ──
  String dateSemanticFormat(int year, int month, int day);

  // ── B62 ParkFormRule validation ──
  String get validationFailed;
  String lengthMustBe(int len);
  String get invalidNumber;
  String get invalidInteger;
  String get invalidEmail;
  String get invalidUrl;
  String get invalidPhone;
  String cannotBeLessThan(num min);
  String cannotBeGreaterThan(num max);
  String lengthCannotBeLessThan(num min);
  String lengthCannotBeGreaterThan(num max);

  /// 从 [BuildContext] 获取当前 [ParkLocalizations]。
  /// 未注入时返回 [ParkLocalizationsZh] 默认值。
  static ParkLocalizations of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_ParkLocalizationsInherited>();
    if (inherited != null) return inherited.localizations;
    return const ParkLocalizationsZh();
  }
}

// =============================================================================
// ParkLocalizationsWidget — 注入本地化的 InheritedWidget 封装
// =============================================================================

/// 向 Widget 树注入 [ParkLocalizations]。
///
/// 通常放在 [MaterialApp] 的 builder 中：
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ParkLocalizationsWidget(
///     localizations: ParkLocalizationsEn(),
///     child: child!,
///   ),
/// )
/// ```
class ParkLocalizationsWidget extends StatefulWidget {
  /// 本地化实现。
  final ParkLocalizations localizations;

  /// 子组件。
  final Widget child;

  const ParkLocalizationsWidget({
    super.key,
    required this.localizations,
    required this.child,
  });

  @override
  State<ParkLocalizationsWidget> createState() =>
      _ParkLocalizationsWidgetState();
}

class _ParkLocalizationsWidgetState extends State<ParkLocalizationsWidget> {
  @override
  Widget build(BuildContext context) {
    return _ParkLocalizationsInherited(
      localizations: widget.localizations,
      child: widget.child,
    );
  }
}

class _ParkLocalizationsInherited extends InheritedWidget {
  final ParkLocalizations localizations;

  const _ParkLocalizationsInherited({
    required this.localizations,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ParkLocalizationsInherited oldWidget) =>
      oldWidget.localizations != localizations;
}

// =============================================================================
// 中文（默认）
// =============================================================================

/// park_ui 中文本地化（默认实现）。
class ParkLocalizationsZh implements ParkLocalizations {
  const ParkLocalizationsZh();

  @override
  String get confirmText => '确定';
  @override
  String get cancelText => '取消';
  @override
  String get clearText => '清空';
  @override
  String get searchText => '搜索';
  @override
  String get submitText => '提交';
  @override
  String get saveText => '保存';
  @override
  String get deleteText => '删除';
  @override
  String get closeText => '关闭';
  @override
  String get doneText => '完成';
  @override
  String get resetText => '重置';
  @override
  String get selectPlaceholder => '请选择';
  @override
  String get inputPlaceholder => '请输入';
  @override
  String get searchPlaceholder => '搜索';
  @override
  String get noData => '暂无数据';
  @override
  String get noSearchResults => '未找到搜索结果';
  @override
  String get noPermission => '暂无访问权限';
  @override
  String get loading => '加载中...';
  @override
  String get loadFailed => '加载失败';
  @override
  String get retry => '重试';
  @override
  String get success => '成功';
  @override
  String get warning => '警告';
  @override
  String get error => '错误';
  @override
  String get previousStep => '上一步';
  @override
  String get nextStep => '下一步';
  @override
  String get searchHistory => '搜索历史';
  @override
  String get matchedHistory => '匹配历史';
  @override
  String get noSearchHistory => '暂无搜索记录';
  @override
  String get noMore => '没有更多';
  @override
  String get pullToRefresh => '下拉刷新';
  @override
  String get releaseToRefresh => '释放刷新';
  @override
  String get refreshing => '刷新中...';
  @override
  String get confirmDelete => '确认删除？';

  @override
  String get previousPage => '上一页';
  @override
  String get nextPage => '下一页';
  @override
  String get jumpTo => '跳至';
  @override
  String get page => '页';
  @override
  String totalInfo(int total) => '共 $total 条';
  @override
  String pageSizeOption(int size) => '$size 条/页';
  @override
  String paginationSemantics(int totalPages, int currentPage) => '分页导航，共 $totalPages 页，当前第 $currentPage 页';
  @override
  String pageButtonSemantics(int page) => '第 $page 页';
  @override
  String pageSizeSemantics(int pageSize) => '每页显示 $pageSize 条';
  @override
  String disabledLabel(String label) => '$label（禁用）';

  @override
  String get searchOptionsHint => '搜索选项';
  @override
  String get searchingText => '搜索中…';
  @override
  String get defaultGroupLabel => '默认分组';
  @override
  String createOption(String keyword) => '创建 "$keyword"';
  @override
  String get gotItText => '我知道了';

  @override
  String get imageLoadFailed => '图片加载失败';
  @override
  String get loadedAllData => '已加载全部数据';
  @override
  String get obscureTextDisplayed => '密码已显示';
  @override
  String get obscureTextHidden => '密码已隐藏';
  @override
  String get requiredHint => '必填项';
  @override
  String get decreaseValue => '减小';
  @override
  String get increaseValue => '增大';

  @override
  String get weekdaySun => '日';
  @override
  String get weekdayMon => '一';
  @override
  String get weekdayTue => '二';
  @override
  String get weekdayWed => '三';
  @override
  String get weekdayThu => '四';
  @override
  String get weekdayFri => '五';
  @override
  String get weekdaySat => '六';
  @override
  String formatYearMonth(int year, int month) =>
      '$year年${month.toString().padLeft(2, '0')}月';
  @override
  String get rangeStartSemantic => '选中范围开始';
  @override
  String get rangeEndSemantic => '选中范围结束';
  @override
  String get rangeMiddleSemantic => '选中范围中间';
  @override
  String selectedCount(int count) => '已选 $count 项';
  @override
  String get selectAllText => '全选';
  @override
  String countdownLabel(String formatted) => '倒计时: $formatted';
  @override
  String get noOptions => '暂无选项';
  @override
  String get noMatchingOptions => '无匹配选项';
  @override
  String get expandText => '展开';
  @override
  String get collapseText => '收起';
  @override
  String get selectStartDate => '选择开始日期';
  @override
  String get selectEndDate => '选择结束日期';
  @override
  String get timeFilter => '时间筛选';
  @override
  String get resetFilter => '重置筛选';
  @override
  String get startTime => '开始时间';
  @override
  String get endTime => '结束时间';
  @override
  String get pleaseSelectFirst => '请先选择一项';
  @override
  String get formLoadingText => '表单加载中，请稍候…';
  @override
  String get searchHintText => '请输入搜索';
  @override
  String get backTop => '回到顶部';
  @override
  String get breadcrumbLabel => '面包屑导航';
  @override
  String get breadcrumbExpand => '展开更多面包屑';
  @override
  String breadcrumbHasSubmenu(String label) => '$label，有子菜单';

  @override
  String get forbiddenTitle => '无权访问';
  @override
  String get forbiddenDesc => '您没有权限访问此页面，请联系管理员。';
  @override
  String get notFoundTitle => '页面未找到';
  @override
  String get notFoundDesc => '您访问的页面不存在或已被移除。';
  @override
  String get serverErrorTitle => '服务器错误';
  @override
  String get serverErrorDesc => '服务器遇到内部错误，请稍后重试。';
  @override
  String get sliderValueLabel => '数值';
  @override
  String get splitterLabel => '拖拽分隔条，调整面板比例';
  @override
  String get collapseFirstHorizontal => '折叠左侧面板';
  @override
  String get collapseSecondHorizontal => '折叠右侧面板';
  @override
  String get collapseFirstVertical => '折叠上方面板';
  @override
  String get collapseSecondVertical => '折叠下方面板';

  // ── ParkUpload ──
  @override
  String get addFileText => '添加文件';
  @override
  String get uploadFailed => '上传失败';
  @override
  String get fileTypeNotSupported => '文件类型不支持';
  @override
  String get imageOnlyUpload => '仅支持上传图片文件';
  @override
  String get imageOnlyConstraint => '仅支持图片';
  @override
  String fileSizeExceedsText(double maxSizeMB) =>
      '文件大小不能超过 ${maxSizeMB.toStringAsFixed(maxSizeMB % 1 == 0 ? 0 : 1)}MB';
  @override
  String supportedFormatsText(List<String> formats) =>
      '支持 ${formats.join(' / ')}';
  @override
  String singleFileLimitText(double maxSizeMB) =>
      '单文件不超过 ${maxSizeMB.toStringAsFixed(maxSizeMB % 1 == 0 ? 0 : 1)}MB';
  @override
  String get deleteFileLabel => '删除文件';
  @override
  String get dragUploadAreaLabel => '拖拽上传区域';

  // ── B62 ParkText ──
  @override
  String get copiedText => '已复制';

  // ── B62 ParkTimePicker ──
  @override
  String get selectTimeText => '请选择时间';
  @override
  String get chooseTimeText => '选择时间';
  @override
  String get currentSelectionText => '当前选择';

  // ── B62 ParkDatePicker shortcuts ──
  @override
  String get shortcutToday => '今天';
  @override
  String get shortcutLast7Days => '近7天';
  @override
  String get shortcutLast30Days => '近30天';
  @override
  String get shortcutThisMonth => '本月';

  // ── B62 ParkCalendar ──
  @override
  String dateSemanticFormat(int year, int month, int day) =>
      '$year年${month}月${day}日';

  // ── B62 ParkFormRule validation ──
  @override
  String get validationFailed => '校验失败';
  @override
  String lengthMustBe(int len) => '长度必须为 $len 个字符';
  @override
  String get invalidNumber => '请输入有效的数字';
  @override
  String get invalidInteger => '请输入有效的整数';
  @override
  String get invalidEmail => '请输入有效的邮箱地址';
  @override
  String get invalidUrl => '请输入有效的 URL';
  @override
  String get invalidPhone => '请输入有效的手机号';
  @override
  String cannotBeLessThan(num min) => '不能小于 $min';
  @override
  String cannotBeGreaterThan(num max) => '不能大于 $max';
  @override
  String lengthCannotBeLessThan(num min) => '长度不能小于 $min';
  @override
  String lengthCannotBeGreaterThan(num max) => '长度不能大于 $max';
}

// =============================================================================
// 英文
// =============================================================================

/// park_ui 英文本地化。
class ParkLocalizationsEn implements ParkLocalizations {
  const ParkLocalizationsEn();

  @override
  String get confirmText => 'OK';
  @override
  String get cancelText => 'Cancel';
  @override
  String get clearText => 'Clear';
  @override
  String get searchText => 'Search';
  @override
  String get submitText => 'Submit';
  @override
  String get saveText => 'Save';
  @override
  String get deleteText => 'Delete';
  @override
  String get closeText => 'Close';
  @override
  String get doneText => 'Done';
  @override
  String get resetText => 'Reset';
  @override
  String get selectPlaceholder => 'Please select';
  @override
  String get inputPlaceholder => 'Please enter';
  @override
  String get searchPlaceholder => 'Search';
  @override
  String get noData => 'No data';
  @override
  String get noSearchResults => 'No search results';
  @override
  String get noPermission => 'No permission';
  @override
  String get loading => 'Loading...';
  @override
  String get loadFailed => 'Load failed';
  @override
  String get retry => 'Retry';
  @override
  String get success => 'Success';
  @override
  String get warning => 'Warning';
  @override
  String get error => 'Error';
  @override
  String get previousStep => 'Previous';
  @override
  String get nextStep => 'Next';
  @override
  String get searchHistory => 'Search history';
  @override
  String get matchedHistory => 'Matched history';
  @override
  String get noSearchHistory => 'No search history';
  @override
  String get noMore => 'No more';
  @override
  String get pullToRefresh => 'Pull to refresh';
  @override
  String get releaseToRefresh => 'Release to refresh';
  @override
  String get refreshing => 'Refreshing...';
  @override
  String get confirmDelete => 'Confirm delete?';

  @override
  String get searchOptionsHint => 'Search options';
  @override
  String get previousPage => 'Previous';
  @override
  String get nextPage => 'Next';
  @override
  String get jumpTo => 'Go to';
  @override
  String get page => 'Page';
  @override
  String totalInfo(int total) => 'Total $total items';
  @override
  String pageSizeOption(int size) => '$size / page';
  @override
  String paginationSemantics(int totalPages, int currentPage) => 'Pagination, $totalPages pages, current page $currentPage';
  @override
  String pageButtonSemantics(int page) => 'Page $page';
  @override
  String pageSizeSemantics(int pageSize) => '$pageSize items per page';
  @override
  String disabledLabel(String label) => '$label (disabled)';

  @override
  String get searchingText => 'Searching…';
  @override
  String get defaultGroupLabel => 'Default group';
  @override
  String createOption(String keyword) => 'Create "$keyword"';
  @override
  String get gotItText => 'Got it';

  @override
  String get imageLoadFailed => 'Image load failed';
  @override
  String get loadedAllData => 'All data loaded';
  @override
  String get obscureTextDisplayed => 'Password displayed';
  @override
  String get obscureTextHidden => 'Password hidden';
  @override
  String get requiredHint => 'Required';
  @override
  String get decreaseValue => 'Decrease';
  @override
  String get increaseValue => 'Increase';

  @override
  String get weekdaySun => 'Sun';
  @override
  String get weekdayMon => 'Mon';
  @override
  String get weekdayTue => 'Tue';
  @override
  String get weekdayWed => 'Wed';
  @override
  String get weekdayThu => 'Thu';
  @override
  String get weekdayFri => 'Fri';
  @override
  String get weekdaySat => 'Sat';
  @override
  String formatYearMonth(int year, int month) =>
      '${month.toString().padLeft(2, '0')}/$year';
  @override
  String get rangeStartSemantic => 'Selection range start';
  @override
  String get rangeEndSemantic => 'Selection range end';
  @override
  String get rangeMiddleSemantic => 'Selection range middle';
  @override
  String selectedCount(int count) => '$count selected';
  @override
  String get selectAllText => 'Select All';
  @override
  String countdownLabel(String formatted) => 'Countdown: $formatted';
  @override
  String get formLoadingText => 'Form is loading, please wait…';
  @override
  String get searchHintText => 'Please enter search';
  @override
  String get backTop => 'Back to top';
  @override
  String get breadcrumbLabel => 'Breadcrumb';
  @override
  String get breadcrumbExpand => 'Expand breadcrumbs';
  @override
  String breadcrumbHasSubmenu(String label) => '$label, has submenu';
  @override
  String get noOptions => 'No options';
  @override
  String get noMatchingOptions => 'No matching options';
  @override
  String get expandText => 'Expand';
  @override
  String get collapseText => 'Collapse';
  @override
  String get selectStartDate => 'Select start date';
  @override
  String get selectEndDate => 'Select end date';
  @override
  String get timeFilter => 'Time filter';
  @override
  String get resetFilter => 'Reset filter';
  @override
  String get startTime => 'Start time';
  @override
  String get endTime => 'End time';
  @override
  String get pleaseSelectFirst => 'Please select an item first';
  @override
  String get forbiddenTitle => 'Access Denied';
  @override
  String get forbiddenDesc => 'You do not have permission to access this page. Please contact the administrator.';
  @override
  String get notFoundTitle => 'Page Not Found';
  @override
  String get notFoundDesc => 'The page you visited does not exist or has been removed.';
  @override
  String get serverErrorTitle => 'Server Error';
  @override
  String get serverErrorDesc => 'The server encountered an internal error. Please try again later.';
  @override
  String get sliderValueLabel => 'Value';
  @override
  String get splitterLabel => 'Drag the divider to adjust panel ratio';
  @override
  String get collapseFirstHorizontal => 'Collapse left panel';
  @override
  String get collapseSecondHorizontal => 'Collapse right panel';
  @override
  String get collapseFirstVertical => 'Collapse top panel';
  @override
  String get collapseSecondVertical => 'Collapse bottom panel';

  // ── ParkUpload ──
  @override
  String get addFileText => 'Add file';
  @override
  String get uploadFailed => 'Upload failed';
  @override
  String get fileTypeNotSupported => 'File type not supported';
  @override
  String get imageOnlyUpload => 'Only image files are allowed';
  @override
  String get imageOnlyConstraint => 'Images only';
  @override
  String fileSizeExceedsText(double maxSizeMB) =>
      'File size cannot exceed ${maxSizeMB.toStringAsFixed(maxSizeMB % 1 == 0 ? 0 : 1)}MB';
  @override
  String supportedFormatsText(List<String> formats) =>
      'Supported: ${formats.join(' / ')}';
  @override
  String singleFileLimitText(double maxSizeMB) =>
      'Single file no more than ${maxSizeMB.toStringAsFixed(maxSizeMB % 1 == 0 ? 0 : 1)}MB';
  @override
  String get deleteFileLabel => 'Delete file';
  @override
  String get dragUploadAreaLabel => 'Drag and drop upload area';

  // ── B62 ParkText ──
  @override
  String get copiedText => 'Copied';

  // ── B62 ParkTimePicker ──
  @override
  String get selectTimeText => 'Please select time';
  @override
  String get chooseTimeText => 'Select time';
  @override
  String get currentSelectionText => 'Current selection';

  // ── B62 ParkDatePicker shortcuts ──
  @override
  String get shortcutToday => 'Today';
  @override
  String get shortcutLast7Days => 'Last 7 days';
  @override
  String get shortcutLast30Days => 'Last 30 days';
  @override
  String get shortcutThisMonth => 'This month';

  // ── B62 ParkCalendar ──
  @override
  String dateSemanticFormat(int year, int month, int day) =>
      '${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}/$year';

  // ── B62 ParkFormRule validation ──
  @override
  String get validationFailed => 'Validation failed';
  @override
  String lengthMustBe(int len) => 'Length must be $len characters';
  @override
  String get invalidNumber => 'Please enter a valid number';
  @override
  String get invalidInteger => 'Please enter a valid integer';
  @override
  String get invalidEmail => 'Please enter a valid email address';
  @override
  String get invalidUrl => 'Please enter a valid URL';
  @override
  String get invalidPhone => 'Please enter a valid phone number';
  @override
  String cannotBeLessThan(num min) => 'Cannot be less than $min';
  @override
  String cannotBeGreaterThan(num max) => 'Cannot be greater than $max';
  @override
  String lengthCannotBeLessThan(num min) => 'Length cannot be less than $min';
  @override
  String lengthCannotBeGreaterThan(num max) => 'Length cannot be greater than $max';
}

// =============================================================================
// 日语
// =============================================================================

/// park_ui 日文本地化。
class ParkLocalizationsJa implements ParkLocalizations {
  const ParkLocalizationsJa();

  @override
  String get confirmText => '確認';
  @override
  String get cancelText => 'キャンセル';
  @override
  String get clearText => 'クリア';
  @override
  String get searchText => '検索';
  @override
  String get submitText => '送信';
  @override
  String get saveText => '保存';
  @override
  String get deleteText => '削除';
  @override
  String get closeText => '閉じる';
  @override
  String get doneText => '完了';
  @override
  String get resetText => 'リセット';
  @override
  String get selectPlaceholder => '選択してください';
  @override
  String get inputPlaceholder => '入力してください';
  @override
  String get searchPlaceholder => '検索';
  @override
  String get noData => 'データがありません';
  @override
  String get noSearchResults => '検索結果が見つかりません';
  @override
  String get noPermission => 'アクセス権限がありません';
  @override
  String get loading => '読み込み中...';
  @override
  String get loadFailed => '読み込み失敗';
  @override
  String get retry => '再試行';
  @override
  String get success => '成功';
  @override
  String get warning => '警告';
  @override
  String get error => 'エラー';
  @override
  String get previousStep => '前へ';
  @override
  String get nextStep => '次へ';
  @override
  String get searchHistory => '検索履歴';
  @override
  String get matchedHistory => '一致履歴';
  @override
  String get noSearchHistory => '検索履歴がありません';
  @override
  String get noMore => 'これ以上ありません';
  @override
  String get pullToRefresh => '下に引っ張って更新';
  @override
  String get releaseToRefresh => '離して更新';
  @override
  String get refreshing => '更新中...';
  @override
  String get confirmDelete => '削除してもよろしいですか？';

  @override
  String get searchOptionsHint => '検索オプション';
  @override
  String get previousPage => '前へ';
  @override
  String get nextPage => '次へ';
  @override
  String get jumpTo => '移動';
  @override
  String get page => 'ページ';
  @override
  String totalInfo(int total) => '合計 $total 件';
  @override
  String pageSizeOption(int size) => '$size 件/ページ';
  @override
  String paginationSemantics(int totalPages, int currentPage) => 'ページネーション、$totalPages ページ中、現在 $currentPage ページ';
  @override
  String pageButtonSemantics(int page) => '$page ページ';
  @override
  String pageSizeSemantics(int pageSize) => '$pageSize 件/ページ表示';
  @override
  String disabledLabel(String label) => '$label（無効）';

  @override
  String get searchingText => '検索中…';
  @override
  String get defaultGroupLabel => 'デフォルトグループ';
  @override
  String createOption(String keyword) => '"$keyword"を作成';
  @override
  String get gotItText => 'わかりました';

  @override
  String get imageLoadFailed => '画像の読み込みに失敗しました';
  @override
  String get loadedAllData => 'すべてのデータを読み込みました';
  @override
  String get obscureTextDisplayed => 'パスワード表示中';
  @override
  String get obscureTextHidden => 'パスワード非表示';
  @override
  String get requiredHint => '必須項目';
  @override
  String get decreaseValue => '減らす';
  @override
  String get increaseValue => '増やす';

  @override
  String get weekdaySun => '日';
  @override
  String get weekdayMon => '月';
  @override
  String get weekdayTue => '火';
  @override
  String get weekdayWed => '水';
  @override
  String get weekdayThu => '木';
  @override
  String get weekdayFri => '金';
  @override
  String get weekdaySat => '土';
  @override
  String formatYearMonth(int year, int month) =>
      '$year年${month.toString().padLeft(2, '0')}月';
  @override
  String get rangeStartSemantic => '選択範囲開始';
  @override
  String get rangeEndSemantic => '選択範囲終了';
  @override
  String get rangeMiddleSemantic => '選択範囲中間';
  @override
  String selectedCount(int count) => '$count 件選択済み';
  @override
  String get selectAllText => 'すべて選択';
  @override
  String countdownLabel(String formatted) => 'カウントダウン: $formatted';
  @override
  String get formLoadingText => 'フォーム読み込み中、お待ちください…';
  @override
  String get searchHintText => '検索してください';
  @override
  String get backTop => 'トップへ戻る';
  @override
  String get breadcrumbLabel => 'パンくず';
  @override
  String get breadcrumbExpand => 'パンくずを展開';
  @override
  String breadcrumbHasSubmenu(String label) => '$label、サブメニューあり';
  @override
  String get noOptions => 'オプションがありません';
  @override
  String get noMatchingOptions => '一致するオプションがありません';
  @override
  String get expandText => '展開';
  @override
  String get collapseText => '折りたたむ';
  @override
  String get selectStartDate => '開始日を選択';
  @override
  String get selectEndDate => '終了日を選択';
  @override
  String get timeFilter => '時間フィルター';
  @override
  String get resetFilter => 'フィルターをリセット';
  @override
  String get startTime => '開始時間';
  @override
  String get endTime => '終了時間';
  @override
  String get pleaseSelectFirst => '先に選択してください';
  @override
  String get forbiddenTitle => 'アクセス拒否';
  @override
  String get forbiddenDesc => 'このページにアクセスする権限がありません。管理者にお問い合わせください。';
  @override
  String get notFoundTitle => 'ページが見つかりません';
  @override
  String get notFoundDesc => 'お探しのページは存在しないか、削除されました。';
  @override
  String get serverErrorTitle => 'サーバーエラー';
  @override
  String get serverErrorDesc => 'サーバーで内部エラーが発生しました。後でもう一度お試しください。';
  @override
  String get sliderValueLabel => '値';
  @override
  String get splitterLabel => '仕切りをドラッグしてパネル比率を調整';
  @override
  String get collapseFirstHorizontal => '左パネルを折りたたむ';
  @override
  String get collapseSecondHorizontal => '右パネルを折りたたむ';
  @override
  String get collapseFirstVertical => '上パネルを折りたたむ';
  @override
  String get collapseSecondVertical => '下パネルを折りたたむ';

  // ── ParkUpload ──
  @override
  String get addFileText => 'ファイルを追加';
  @override
  String get uploadFailed => 'アップロード失敗';
  @override
  String get fileTypeNotSupported => 'サポートされていないファイルタイプ';
  @override
  String get imageOnlyUpload => '画像ファイルのみアップロード可能';
  @override
  String get imageOnlyConstraint => '画像のみ';
  @override
  String fileSizeExceedsText(double maxSizeMB) =>
      'ファイルサイズは ${maxSizeMB.toStringAsFixed(maxSizeMB % 1 == 0 ? 0 : 1)}MB を超えることはできません';
  @override
  String supportedFormatsText(List<String> formats) =>
      'サポート: ${formats.join(' / ')}';
  @override
  String singleFileLimitText(double maxSizeMB) =>
      '単一ファイルは ${maxSizeMB.toStringAsFixed(maxSizeMB % 1 == 0 ? 0 : 1)}MB まで';
  @override
  String get deleteFileLabel => 'ファイルを削除';
  @override
  String get dragUploadAreaLabel => 'ドラッグ＆ドロップアップロードエリア';

  // ── B62 ParkText ──
  @override
  String get copiedText => 'コピーしました';

  // ── B62 ParkTimePicker ──
  @override
  String get selectTimeText => '時間を選択してください';
  @override
  String get chooseTimeText => '時間を選択';
  @override
  String get currentSelectionText => '現在の選択';

  // ── B62 ParkDatePicker shortcuts ──
  @override
  String get shortcutToday => '今日';
  @override
  String get shortcutLast7Days => '過去7日間';
  @override
  String get shortcutLast30Days => '過去30日間';
  @override
  String get shortcutThisMonth => '今月';

  // ── B62 ParkCalendar ──
  @override
  String dateSemanticFormat(int year, int month, int day) =>
      '$year年${month}月${day}日';

  // ── B62 ParkFormRule validation ──
  @override
  String get validationFailed => 'バリデーション失敗';
  @override
  String lengthMustBe(int len) => '長さは $len 文字である必要があります';
  @override
  String get invalidNumber => '有効な数値を入力してください';
  @override
  String get invalidInteger => '有効な整数を入力してください';
  @override
  String get invalidEmail => '有効なメールアドレスを入力してください';
  @override
  String get invalidUrl => '有効なURLを入力してください';
  @override
  String get invalidPhone => '有効な電話番号を入力してください';
  @override
  String cannotBeLessThan(num min) => '$min 未満にすることはできません';
  @override
  String cannotBeGreaterThan(num max) => '$max を超えることはできません';
  @override
  String lengthCannotBeLessThan(num min) => '長さは $min 未満にすることはできません';
  @override
  String lengthCannotBeGreaterThan(num max) => '長さは $max を超えることはできません';
}
