# Park UI

**Park UI** 是一套面向 Flutter 的企业级中后台组件库，遵循 **Stripe 设计语言**，提供 100+ 开箱即用的高质量组件。

## 特性

- 📐 **完整 Design System** — 详见 [`DESIGN_SYSTEM.md`](./DESIGN_SYSTEM.md)，包含完整色彩体系、字体层级、间距规则、阴影/圆角体系和 10+ 基础组件设计规范
- 🧩 **100+ 组件** — 覆盖基础、输入、展示、反馈、导航五大类别
- 🎨 **Stripe 设计语言** — 品牌紫 blurple `#635BFF`、文字 navy `#0A2540`、浅灰底色 `#F6F9FC`
- 🌓 **浅色/深色主题** — 全局 `ParkThemeData` 驱动，一键切换明暗
- 🌐 **国际化友好** — 全局 `ParkLocalizations` 系统 + 组件级参数覆盖
- 🎯 **最小三方依赖** — 仅依赖 `equatable`、`qr_flutter`、`url_launcher`、`file_picker`，不引入重状态管理库
- 🔗 **双向绑定引擎** — `ParkBindingService` + `ParkBindable<T>` 实现响应式数据绑定
- 📱 **响应式布局** — 支持移动端、桌面端、Web 端
- 🔧 **高度可定制** — Design Token 全覆盖（颜色、间距、圆角、排版、阴影、动画），所有组件使用统一令牌系统

## 安装

### 本地路径（开发）

```yaml
dependencies:
  park_ui:
    path: ../park/packages/park_ui
```

### GitHub（发布）

```yaml
dependencies:
  park_ui:
    git:
      url: https://github.com/xihuannioyj/ParkUI.git
      ref: main
```

## 快速开始

```dart
import 'package:park_ui/park_ui.dart';

MaterialApp(
  theme: parkThemeDataLight,  // 内置浅色主题
  darkTheme: parkThemeDataDark,  // 内置深色主题
  home: MyHomePage(),
)

// 使用组件
ParkButton(
  variant: ParkButtonVariant.primary,
  onPressed: () {},
  child: Text('提交'),
)
```

---

# 主题系统 — ParkThemeData

Park UI 的所有视觉风格由 Design Token 驱动。`ParkThemeData` 是 Flutter `ThemeExtension` 子类，通过 `ThemeData.extensions` 注入。

## API 参考

| 属性 | 类型 | 说明 |
|------|------|------|
| `colors` | `ParkColors` | 颜色令牌（品牌/文字/背景/边框/状态色） |
| `spacing` | `ParkSpacing` | 间距令牌（xxs/xs/sm/md/base/lg/xl/xxl/page） |
| `radius` | `ParkRadius` | 圆角令牌（xs/sm/md/lg/xl/full） |
| `typography` | `ParkTypography` | 排版令牌（字体族/字号/字重） |
| `shadows` | `ParkShadows` | 阴影令牌（xs/sm/md/lg/xl） |
| `iconTheme` | `ParkIconThemeData` | 图标主题（默认色、尺寸覆盖） |
| `motion` | `ParkMotion` | 动画令牌（standard/quick/enterEasing/defaultEasing） |

## 配置清单

```dart
// 全部可定制 Token
ParkThemeData(
  colors: ParkColors(
    brand: Color(0xFF635BFF),        // 品牌色（按钮/链接/选中态）
    textPrimary: Color(0xFF0A2540),   // 主文字
    textSecondary: Color(0xFF425466), // 次要文字
    textPlaceholder: Color(0xFF8898AA), // 占位文字
    textDisabled: Color(0xFF8792A2),  // 禁用文字
    textOnBrand: Color(0xFFFFFFFF),   // 品牌色上的文字
    surface: Color(0xFFFFFFFF),       // 表面色（卡片/面板）
    background: Color(0xFFF6F9FC),    // 底色
    border: Color(0xFFE3E8EE),        // 边框
    divider: Color(0x140A2540),       // 分割线（navy 7.8%）
    disabledBg: Color(0xFFEDF0F5),    // 禁用背景
    overlay: Color(0x730A2540),       // 遮罩（navy 45%）
    error: Color(0xFFDF1B41),         // 错误
    success: Color(0xFF1BB978),       // 成功
    warning: Color(0xFFFFB400),       // 警告
    info: Color(0xFF635BFF),          // 信息
  ),
  radius: ParkRadius(
    xs: 4, sm: 8, md: 12, lg: 16, xl: 20, full: 9999,
  ),
  spacing: ParkSpacing(
    xs: 4, sm: 8, md: 12, base: 16, lg: 20, xl: 24, xxl: 32, page: 48,
  ),
  typography: ParkTypography(
    fontFamily: 'Inter',
    sizeCaption: 13, sizeBodySmall: 14, sizeBody: 16,
    sizeH3: 18, sizeH2: 22, sizeH1: 28, sizeDisplay: 34,
  ),
)
```

## 注入方式

### 方式 1：内置预设主题（推荐）

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [ParkThemeData.light()],   // 浅色
  ),
  darkTheme: ThemeData(
    extensions: [ParkThemeData.dark()],    // 深色
  ),
  themeMode: ThemeMode.system,             // 跟随系统
  home: MyHomePage(),
)
```

快捷常量：

```dart
parkThemeDataLight  // 等效于 ThemeData(extensions: [ParkThemeData.light()])
parkThemeDataDark   // 等效于 ThemeData(extensions: [ParkThemeData.dark()])
```

### 方式 2：自定义品牌色

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      ParkThemeData(
        colors: ParkColors(
          brand: Color(0xFF1890FF),       // 改为 Ant 蓝
          textPrimary: Color(0xFF262626),
          // ... 其他颜色
        ),
      ),
    ],
  ),
)
```

### 方式 3：部分覆盖（只改想改的）

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [ParkThemeData.light().copyWith(
      brand: Color(0xFF00B96B),           // 只改品牌色
      radius: ParkRadius(sm: 6, md: 10),  // 只改圆角
    )],
  ),
)
```

## 组件内使用

组件内部通过 `Theme.of(context).extension<ParkThemeData>()` 读取：

```dart
final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

// 使用令牌
Container(
  color: park.colors.surface,
  padding: EdgeInsets.all(park.spacing.base),
  borderRadius: BorderRadius.circular(park.radius.md),
  child: Text('Hello', style: park.typography.body),
)
```

## 浅色 vs 深色

| 令牌 | 浅色 | 深色 |
|------|------|------|
| `colors.surface` | `#FFFFFF` | `#1A202C` |
| `colors.background` | `#F6F9FC` | `#0D1117` |
| `colors.textPrimary` | `#0A2540` | `#E2E8F0` |
| `colors.border` | `#E3E8EE` | `#2D3748` |

---

# 国际化 — ParkLocalizations

Park UI 内置 `ParkLocalizations` 全局国际化系统，与组件级参数覆盖协同工作。

## 架构

```
ParkLocalizations.of(context)  ← 全局注入（通过 ParkLocalizationsWidget）
         │
         ├── ParkLocalizationsZh（中文默认）
         ├── ParkLocalizationsEn（英文）
         └── 自定义实现
         
组件构造函数参数  ← 局部覆盖（优先级高于全局注入）
```

**优先级**：组件参数 > 全局 `ParkLocalizations` > 中文默认值

## API 参考

### 抽象接口方法

```dart
abstract class ParkLocalizations {
  String get confirmText;      // 确定
  String get cancelText;       // 取消
  String get clearText;        // 清空
  String get searchText;       // 搜索
  String get submitText;       // 提交
  String get saveText;         // 保存
  String get deleteText;       // 删除
  String get closeText;        // 关闭
  String get doneText;         // 完成
  String get resetText;        // 重置
  String get selectPlaceholder; // 请选择
  String get inputPlaceholder;  // 请输入
  String get searchPlaceholder; // 搜索
  String get noData;           // 暂无数据
  String get loading;          // 加载中...
  String get loadFailed;       // 加载失败
  String get retry;            // 重试
  String get success;          // 成功
  String get warning;          // 警告
  String get error;            // 错误
  String get previousStep;     // 上一步
  String get nextStep;         // 下一步
  String get noMore;           // 没有更多
  String get pullToRefresh;    // 下拉刷新
  String get releaseToRefresh; // 释放刷新
  String get refreshing;       // 刷新中...
  String get confirmDelete;    // 确认删除？
}
```

### 内置实现

| 类名 | 语言 |
|------|------|
| `ParkLocalizationsZh` | 中文（默认） |
| `ParkLocalizationsEn` | 英文 |

### 注入 Widget

```dart
ParkLocalizationsWidget(
  localizations: ParkLocalizationsEn(),  // 你选择的本地化实现
  child: child!,                          // 子树
)
```

## 注入方式

### 方式 1：全局注入（推荐）

```dart
MaterialApp(
  builder: (context, child) => ParkLocalizationsWidget(
    localizations: ParkLocalizationsEn(),
    child: child!,
  ),
  home: MyHomePage(),
)
```

### 方式 2：与主题共存

```dart
MaterialApp(
  theme: parkThemeDataLight,
  builder: (context, child) => ParkLocalizationsWidget(
    localizations: ParkLocalizationsEn(),
    child: child!,
  ),
  home: MyHomePage(),
)
```

### 方式 3：组件级覆盖（优先级最高）

```dart
// 即使全局注入的是英文，这里也会显示日文
ParkDialog(
  title: '確認',
  content: 'この操作を実行しますか？',
  confirmText: '確認',
  cancelText: 'キャンセル',
)
```

### 方式 4：自定义本地化

```dart
class ParkLocalizationsJa implements ParkLocalizations {
  @override String get confirmText => '確認';
  @override String get cancelText => 'キャンセル';
  // ... 实现全部 31 个 getter
}

MaterialApp(
  builder: (context, child) => ParkLocalizationsWidget(
    localizations: ParkLocalizationsJa(),
    child: child!,
  ),
)
```

## 优先级示例

```dart
// 假设全局注入的是 ParkLocalizationsEn（英文）

ParkDatePicker()  
// → 内部 sheet 按钮显示 "Cancel" / "OK"（来自全局英文）
//    hintText 显示 "请选择"（来自组件默认值，不受全局影响）

ParkDatePicker(hintText: 'Select date')  
// → 内部 sheet 按钮 "Cancel" / "OK"
//    hintText "Select date"（组件参数覆盖）

ParkDialog(confirmText: 'はい', cancelText: 'いいえ')
// → "はい" / "いいえ"（组件参数覆盖全局）
```

## 组件默认值对照表

以下组件的默认文字可直接通过全局 `ParkLocalizations` 统一管理，
也可通过构造函数参数单独覆盖：

| 组件 | 属性 | 默认值 |
|------|------|--------|
| `ParkDialog` | `confirmText` | `'确定'` |
| `ParkActionSheet` | `cancelText` | `'取消'` |
| `ParkPopconfirm` | `confirmText` / `cancelText` | `'确定'` / `'取消'` |
| `ParkDropdownSheet` | `confirmText` / `cancelText` | `'确定'` / `'取消'` |
| `ParkDropdownFilter` | `confirmText` / `cancelText` | `'确定'` / `'取消'` |
| `ParkSwipeAction` | `confirmText` | `'确认'` |
| `ParkInputSearchButtonConfig` | `text` | `'搜索'` |
| `ParkCascader` | `emptyText` | `'暂无数据'` |
| `ParkCascader` | `showSearch` / `multiple` | `false` |
| `ParkSearch` | `hintText` | `'搜索'` |

---

# 表单布局 — ParkFormLayout

Park UI 表单支持**纵向**（标签在上，默认）和**水平**（标签在左）两种布局。

## API 参考

| 属性 | 类型 | 所属 | 说明 |
|------|------|------|------|
| `layout` | `ParkFormLayout` | `ParkForm` / `ParkFormItem` | 布局方式，默认 `vertical` |
| `labelWidth` | `double` | `ParkForm` / `ParkFormItem(labelCol)` | 水平布局标签宽度（默认 100px） |
| `colon` | `bool` | `ParkForm` / `ParkFormItem` | 标签后显示冒号（默认 true） |

## 枚举值

| 值 | 说明 |
|------|------|
| `ParkFormLayout.vertical` | 纵向：标签在上，输入框在下 |
| `ParkFormLayout.horizontal` | 水平：标签在左，输入框在右 |
| `ParkFormLayout.inline` | 内联排列 |

## 使用方式

### 全局水平布局

```dart
ParkForm(
  layout: ParkFormLayout.horizontal,
  children: [
    ParkFormItem(label: '姓名', child: ParkInput()),
    ParkFormItem(label: '年龄', child: ParkInputNumber()),
  ],
)
```

### 单项覆盖

```dart
ParkForm(
  layout: ParkFormLayout.horizontal,
  children: [
    ParkFormItem(label: '姓名', child: ParkInput()),
    ParkFormItem(
      label: '备注',
      layout: ParkFormLayout.vertical,  // 此项改为纵向
      child: ParkInput(maxLines: 3),
    ),
  ],
)
```

### 独立使用（无 ParkForm）

```dart
ParkFormItem(
  label: '姓名',
  layout: ParkFormLayout.horizontal,
  child: ParkInput(),
)
```

---

# 主题 + 国际化完整示例

```dart
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park UI Demo',
      debugShowCheckedModeBanner: false,
      
      // ── 主题：浅色 + 自定义品牌色 ──
      theme: ThemeData(
        useMaterial3: true,
        extensions: [
          ParkThemeData(
            colors: ParkColors(
              brand: Color(0xFF1890FF),
              success: Color(0xFF52C41A),
              warning: Color(0xFFFAAD14),
              error: Color(0xFFFF4D4F),
              info: Color(0xFF1890FF),
            ),
            radius: ParkRadius(sm: 6, md: 8, lg: 12),
            spacing: ParkSpacing(xs: 4, sm: 8, base: 16),
            typography: ParkTypography(fontFamily: 'Inter'),
          ),
        ],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [ParkThemeData.dark()],
      ),
      themeMode: ThemeMode.system,

      // ── 国际化：英文 ──
      builder: (context, child) => ParkLocalizationsWidget(
        localizations: ParkLocalizationsEn(),
        child: child!,
      ),

      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    return Scaffold(
      appBar: ParkNavBar(title: l10n.confirmText),  // "OK"（来自全局英文）
      body: Padding(
        padding: EdgeInsets.all(park.spacing.base),
        child: Column(
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () => ParkDialog.alert(
                context,
                title: l10n.success,
                content: l10n.loading,
                confirmText: l10n.confirmText,
              ),
              child: Text(l10n.submitText),
            ),
            ParkDatePicker(
              label: '日期（组件参数覆盖）',
              hintText: l10n.selectPlaceholder,
              mode: ParkDatePickerMode.date,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

# 组件总览

## 基础（Base）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkButton` | 按钮 — 6 种变体、3 种尺寸、loading/disabled、异步 loading、防抖、角标 | `variant`, `size`, `loading`, `asyncOnPressed`, `badge` |
| `ParkButtonGroup` | 按钮组 — 贴合/均分两种模式 | `direction`, `mode` |
| `ParkText` | 排版 — 预设 `bodySmall` / `body` / `h3` / `h2` / `h1` | `preset`, `maxLines` |
| `ParkIcon` | 图标容器 — 统一尺寸/颜色 | `size`, `color` |
| `ParkLink` | 链接 — 支持 href 跳转 | `href`, `target`, `underline` |
| `ParkDivider` | 分割线 — 文字/图标插入 | `text`, `direction` |
| `ParkFab` | 浮动操作按钮 | `onPressed` |
| `ParkSpace` | 间距组件 — 统一子元素间距 | `size`, `direction`, `wrap` |
| `ParkInkWell` | 交互容器 — 统一点击反馈（缩放/透明度/悬停高亮/手型光标） | `onTap`, `disabled`, `borderRadius` |

## 展示（Display）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkCard` | 卡片容器 — 标题/描述/图标指示条/loading/可折叠 | `title`, `description`, `icon`, `loading`, `collapsible` |
| `ParkTag` | 标签 — 5 色主题、icon、checkable、closable、4 种变体 | `theme`, `icon`, `checkable`, `closable`, `shape` |
| `ParkBadge` | 徽标 — 数字/红点/状态点/自定义（status+color 优先级：`color` > `status` > 默认红） | `count`, `dot`, `status`, `color`, `maxCount`, `standaloneText`, `overflowCount` |
| `ParkAvatar` | 头像 — 图片/文字/图标，支持在线状态点和角标 | `src`, `name`, `size`, `status`, `statusDotSize`, `badge` |
| `ParkAvatarGroup` | 头像组 — 堆叠展示多人/在线用户，超出显示 +N | `children`, `maxCount`, `size` |
| `ParkCell` | 列表项 — 左图标+标题+说明+右箭头 | `title`, `leftIcon`, `note`, `onPressed` |
| `ParkTable` | 表格 — 排序/选择/固定列/展开行/虚拟滚动 | `columns`, `dataSource`, `rowSelection` |
| `ParkGrid` | 网格布局 | `columns`, `gap` |
| `ParkList` | 长列表 | `data`, `itemBuilder` |
| `ParkMasonry` | 瀑布流布局 — 最短列优先，响应式列数，无限滚动 | `items`, `itemBuilder`, `columns`, `spacing`, `minColumnWidth`, `onLoadMore` |
| `ParkSkeleton` | 骨架屏 | `type`, `lines` |
| `ParkEmpty` | 空状态 — 支持无数据/无搜索结果/无权限三种变体 | `type`, `icon`, `image`, `description`, `descriptionWidget`, `actions`, `size`, `footer` |
| `ParkImage` | 图片 — 缓存/占位/错误/预览/圆角/重试/懒加载 | `src`, `previewable`, `fadeInDuration`, `retry`, `lazy`, `memoryCache` |
| `ParkImageViewer` | 大图预览 — 缩放/旋转/翻转工具条 + 失败兜底 | `images`, `initialIndex`, `showToolbar`, `errorBuilder`, `onTap` |
| `ParkTooltip` | 文字提示 — 受控展开、箭头配置、8 方向、延迟、自动隐藏 | `message`, `open`, `onOpenChange`, `showArrow`, `arrowPadding`, `placement`, `trigger`, `gap`, `delay`, `duration` |
| `ParkPopover` | 气泡卡片 | `content`, `trigger` |
| `ParkTree` | 树 — 选中/多选/异步加载/受控/拖拽排序/搜索高亮 | `data`, `onSelect`, `loadChildren`, `selectedKeys`, `multiSelect`, `draggable`, `onDragReorder`, `searchQuery` |
| `ParkTimeline` | 时间线 — 支持 left/right/alternate 模式、pending 加载指示器、reverse 倒序 | `items`, `mode`, `pending`, `pendingLabel`, `reverse` |
| `ParkCollapse` | 折叠面板 — 支持 ghost/accordion/自定义展开图标/展开图标位置 | `items`, `accordion`, `ghost`, `expandIcon`, `expandIconPosition` |
| `ParkCountdown` | 倒计时数字块 — HH:MM:SS 方块 | `remaining`, `size`, `theme`, `controller` |
| `ParkDescriptions` | 描述列表 | `items`, `column`, `bordered`, `size`, `layout` |
| `ParkEllipsis` | 文字省略 | `text`, `maxLines`, `expandable` |
| `ParkFooter` | 页脚 | `content` |
| `ParkStatistic` | 统计数值 — 动画计数/千分位/精度/prefix·suffix | `value`, `title`, `prefix`, `suffix`, `precision`, `groupSeparator`, `animate` |
| `ParkProgress` | 进度条 — 支持 line / dashboard 环形仪表盘、步骤块(steps)、百分比标签、状态色 | `value`, `type`, `label`, `status`, `steps`, `formatLabel` |
| `ParkQRCode` | 二维码 | `data`, `size` |
| `ParkResult` | 结果页 — 7 种状态（success/error/info/warning/403/404/500），内置图标+配色，HTTP 状态码大图标+副标题，向后兼容 | `status`, `title`, `description`, `descriptionWidget`, `icon`, `actions`, `extra` |
| `ParkSticky` | 吸顶容器 | `offset` |
| `ParkSwiper` | 轮播 | `items`, `autoPlay`, `duration` |
| `ParkWatermark` | 水印 | `text`, `opacity` |
| `ParkSplitter` | 可拖拽分隔面板 — 水平/垂直、折叠按钮、受控比例、双击复位 | `axis`, `first`, `second`, `defaultRatio`, `minRatio`, `maxRatio`, `collapsible` |

## 输入（Input / Form）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkInput` | 文本输入框 — 前后缀/清除/搜索/密码/字数统计 | `prefixIcon`, `suffix`, `clearable`, `showCount`, `maxLength` |
| `ParkTextarea` | 多行输入框 | `minLines`, `maxLines`, `showCount` |
| `ParkSearch` | 搜索框 — 历史缓存/建议面板/加载态 | `cacheService`, `hintText`, `showCancel` |
| `ParkSelect` | 下拉选择器 | `options`, `placeholder`, `searchable`, `maxTagCount` |
| `ParkDatePicker` | 日期选择器 — 日期/时间/日期时间/年月/带秒 | `mode`, `firstDate`, `lastDate`, `format`, `presetItems` |
| `ParkDateRangePicker` | 日期范围选择器 — 快捷预设 | `startTime`, `endTime`, `presets`, `presetItems` |
| `ParkTimePicker` | 时间选择器 | `value`, `onChanged` |
| `ParkSwitch` | 开关 — loading 态、滑块图标、无障碍标签 | `value`, `onChanged`, `loading`, `checkedChild`, `uncheckedChild`, `checkedLabel`, `uncheckedLabel` |
| `ParkCheckbox` | 复选框 — 组/全选/半选 | `value`, `onChanged`, `indeterminate` |
| `ParkRadio` | 单选框 — 点式/按钮式/Join 模式/图标 | `options`, `radioStyle`, `buttonJoin`, `optionBuilder` |
| `ParkSegmented` | 分段控制器 — 单选/多选/滑块/图标/尺寸/通栏 | `items`, `value`, `multiSelect`, `size`, `block` |
| `ParkSlider` | 滑动输入条 / 范围双滑块 | `value`, `min`, `max`, `step`, `marks`, `showTooltip`, `tooltipBuilder`, `range`, `rangeStart`, `rangeEnd`, `onRangeChanged` |
| `ParkStepper` | 步进器 | `value`, `min`, `max`, `step` |
| `ParkRate` | 评分 | `value`, `count`, `allowHalf`, `character`, `characters` |
| `ParkPicker` | 滚动选择器 | `options`, `value` |
| `ParkCascader` | 级联选择器 | `options`, `value`, `changeOnSelect`, `showSearch`, `multiple` |
| `ParkTransfer` | 穿梭框 — 双栏选择、搜索过滤、单向模式、自定义标题 | `dataSource`, `targetKeys`, `showSearch`, `oneWay`, `leftTitle`, `rightTitle` |
| `ParkTreeSelect` | 树选择 — 复选框/搜索/受控选中 | `nodes`, `treeCheckable`, `showSearch`, `checkedKeys`, `onCheck` |
| `ParkAutoComplete` | 自动完成 | `options`, `onSearch`, `value` |
| `ParkMentions` | 提及输入 — @ 某人 / # 标签 下拉建议 | `items`, `triggerChars`, `onChanged`, `mentionBuilder` |
| `ParkColorPicker` | 颜色选择器 — 预设色板 + 自定义 HSV 面板（色相条+SV方块）+ HEX/RGB/HSB 格式切换 | `value`, `onChanged`, `presetColors`, `enableCustom`, `showFormatSwitch`, `format` |
| `ParkCalendar` | 日历 — 单日/范围/多选，支持 cellRender/cellBuilder/disabledDate/minDate/maxDate，范围选择新增 selectionMode/rangeStart/rangeEnd/onRangeChange | `value`, `onChanged`, `mode`, `selectionMode`, `rangeStart`, `rangeEnd`, `onRangeChange` |
| `ParkForm` | 表单 — 校验/提交/双向绑定 | `formKey`, `bindingService`, `submitLabel` |
| `ParkFormItem` | 表单项 — 标签/校验/布局 | `label`, `required`, `validator`, `bindKey` |
| `ParkFormSection` | 表单分组 | `title`, `children` |
| `ParkInputGroup` | 输入框组合 | `children` |
| `ParkDynamicForm` | 动态表单 — JSON Schema 驱动/引擎层校验/联动/自动生成 | `schema`, `bindingService`, `onSubmit` |
| `ParkBinding` | 双向绑定系统 — 响应式数据绑定/表单关联/路径解析 | `bindKey`, `bindingService` |
| `ParkInputNumber` | 数字输入框 | `value`, `min`, `max`, `step`, `bindKey`, `bindingService` |
| `ParkUpload` | 上传 — 支持自动文件选择、拖拽上传、文件类型/大小校验、自定义上传请求、多选 | `files`, `maxCount`, `onAdd`, `onChanged`, `accept`, `multiple`, `validateFile`, `customRequest`, `dragEnabled`, `onFileDrop`, `mode`(imageGrid/fileList/mixed), `listType`(text/picture/pictureCard), `maxSizeMB`, `imageOnly`, `beforeAddValidator`, `removable`, `previewable` |

## 反馈（Feedback）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkDialog` | 对话框 — alert/confirm/info/自定义内容/全屏 | `title`, `content`, `footer`, `fullscreen` |
| `ParkPopup` | 弹出面板 — 底部/居中/顶部/动画 | `visible`, `position`, `animation` |
| `ParkActionSheet` | 操作菜单 | `actions`, `cancelText` |
| `ParkToast` | 轻提示 — success/error/info/warning，支持全局静态方法和独立 widget、可配置位置/暂停悬停/自定义内容 | `message`, `icon`, `position`, `afterClose`, `destroyOnHide` |
| `ParkMessage` | 全局消息 — 支持 info/success/warning/error/loading 静态方法、独立 widget 模式、悬停暂停、关闭回调、自定义图标和强调色、顶部/底部弹出 | `title`, `content`, `closable`, `duration`, `position`, `icon`, `accentColor`, `onTap`, `onClick`, `onClose`, `pauseOnHover` |
| `ParkNotification` | 通知提醒 | `title`, `message`, `duration` |
| `ParkAlert` | 警告提示 | `type`, `message`, `closable` |
| `ParkDropdownFilter` | 筛选下拉栏 — 多标签/单多选/网格/自定义 | `items`, `style` |
| `ParkDropdownMenu` | 下拉菜单 — 支持多级子菜单嵌套 | `items`, `onSelected`, `itemBuilder` |
| `ParkDropdownSheet` | 底部下拉面板 | `title`, `options`, `child` |
| `ParkLoading` | 加载指示器 | `tip` |
| `ParkOverlay` | 遮罩层 | `visible`, `opacity` |
| `ParkPopconfirm` | 气泡确认框 | `title`, `onConfirm`, `onCancel` |
| `ParkRefresh` | 下拉刷新 | `onRefresh`, `child` |
| `ParkSwipeCell` | 滑动操作 | `leftActions`, `rightActions`, `child` |
| `ParkNoticeBar` | 通告栏 | `text`, `mode` |
| `ParkTour` | 漫游式引导 — 遮罩 + 气泡分步引导用户了解功能 | `steps`, `open`, `current`, `onChange`, `onClose`, `onFinish` |

## 导航（Navigation）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkNavBar` | 导航栏 — 居中标题、返回箭头、右侧操作、透明模式、底部附加内容、副标题、返回确认 | `title`, `leftArrow`, `onBack`, `rightActions`, `actions`, `centerTitle`, `transparent`, `bordered`, `subTitle`, `bottom`, `onBackConfirm` |
| `ParkTabs` | 标签页 — 可编辑卡片（增删）+ 额外内容，支持 line/card 两种类型 | `tabs`, `type`, `editable`, `onTabClose`, `showAddButton`, `onTabAdd`, `extra` |
| `ParkTabBar` | 标签栏 | `tabs`, `activeIndex`, `onChange` |
| `ParkMenu` | 导航菜单 — 暗色模式、inline 折叠、多级展开、选中高亮、废弃 light 兼容 | `items`, `mode`, `themeMode`, `inlineCollapsed`, `collapsedWidth`, `light`(deprecated) |
| `ParkBreadcrumb` | 面包屑 — 自定义分隔符、超长折叠溢出下拉/Popover | `items`, `separator`, `maxItems`, `overflowDropdown`, `size` |
| `ParkPagination` | 分页 — 页码导航、快速跳转、每页条数选择、简洁模式、总条数显示、禁用态、响应式窄屏 | `current`, `total`, `pageSize`, `onChange`, `showSizeChanger`, `showQuickJumper`, `pageSizeOptions`, `showTotal`, `simple`, `disabled`, `size`, `responsive`, `defaultPageSize` |
| `ParkSteps` | 步骤条 — 支持 error 状态、progressDot 圆点模式 | `current`, `steps`, `status`, `progressDot` |
| `ParkDrawer` | 抽屉 — 多级嵌套（`show()` 静态方法）、header/footer/extra、loading、4 方向 | `visible`, `placement`, `child`, `header`, `footer`, `extra`, `closable`, `loading`, `size`, `mask`, `show()` |
| `ParkBackTop` | 回到顶部 | `target`, `visibleHeight` |
| `ParkLayout` | 布局容器 | `header`, `aside`, `content`, `footer` |
| `ParkAnchor` | 锚点 — 点击跳转/滚动高亮 | `items`, `scrollController`, `offset` |
| `ParkIndexes` | 索引列表 — 字母索引条、点击/拖拽跳转、中央浮层提示、外部高亮控制、滚动联动 | `indexes`, `onIndexSelected`, `activeColor`, `fontSize`, `showOverlay`, `sticky`, `onChange`, `currentIndex`, `anchorScrollController` |
| `ParkSideBar` | 侧边导航 | `items`, `activeIndex`, `onChange` |

---

# 双向绑定引擎

Park UI 内置 `ParkBindingService` 响应式绑定引擎，支持表单级联、分组填值、跨组件数据同步。

```dart
// 创建绑定服务
final bindingService = ParkBindingService();

// 在表单中使用
ParkForm(
  bindingService: bindingService,
  model: {'name': '张三', 'age': 28},
  children: [
    ParkFormItem(
      label: '姓名',
      bindKey: 'name',
      child: ParkInput(),
    ),
    ParkFormItem(
      label: '年龄',
      bindKey: 'age',
      child: ParkInputNumber(),
    ),
  ],
)

// 外部更新绑定值
bindingService.setValue('name', '李四');

// 获取绑定值
final name = bindingService.getValue<String>('name');
```

---

# 开发

```bash
# 克隆项目
git clone https://github.com/xihuannioyj/ParkUI.git

# 安装依赖
cd ParkUI
flutter pub get

# 运行示例
cd example
flutter run

# 分析代码
flutter analyze

# 发布检查
flutter pub publish --dry-run
```

## 许可证

MIT License
