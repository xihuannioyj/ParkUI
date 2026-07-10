# Park UI

**Park UI** 是一套面向 Flutter 的企业级中后台组件库，遵循 **Stripe 设计语言**，提供 80+ 开箱即用的高质量组件。

## 特性

- 🧩 **80+ 组件** — 覆盖基础、输入、展示、反馈、导航五大类别
- 🎨 **Stripe 设计语言** — 品牌紫 blurple `#635BFF`、文字 navy `#0A2540`、浅灰底色 `#F6F9FC`
- 🌓 **浅色/深色主题** — 全局 `ParkThemeData` 驱动，一键切换明暗
- 🌐 **国际化友好** — 全局 `ParkLocalizations` 系统 + 组件级参数覆盖
- 🎯 **零第三方依赖** — 纯 Flutter Widget，不引入外部 UI 库
- 🔗 **双向绑定引擎** — `ParkBindingService` + `ParkBindable<T>` 实现响应式数据绑定
- 📱 **响应式布局** — 支持移动端、桌面端、Web 端
- 🔧 **高度可定制** — Design Token 全覆盖（颜色、间距、圆角、排版、阴影、动画）

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
| `spacing` | `ParkSpacing` | 间距令牌（xs/sm/base/md/lg/xl） |
| `radius` | `ParkRadius` | 圆角令牌（none/xs/sm/md/lg/xl/brFull） |
| `typography` | `ParkTypography` | 排版令牌（字体族/字号/字重） |
| `shadows` | `ParkShadows` | 阴影令牌（xs/sm/md/lg/xl） |
| `motion` | `ParkMotion` | 动画令牌（standard/quick/enterEasing/defaultEasing） |

## 配置清单

```dart
// 全部可定制 Token
ParkThemeData(
  colors: ParkColors(
    brand: Color(0xFF635BFF),        // 品牌色（按钮/链接/选中态）
    textPrimary: Color(0xFF0A2540),   // 主文字
    textSecondary: Color(0xFF6B7C93), // 次要文字
    textPlaceholder: Color(0xFFA0AEC0), // 占位文字
    textDisabled: Color(0xFFCBD5E0),  // 禁用文字
    textOnBrand: Color(0xFFFFFFFF),   // 品牌色上的文字
    surface: Color(0xFFFFFFFF),       // 表面色（卡片/面板）
    background: Color(0xFFF6F9FC),    // 底色
    border: Color(0xFFE3E8EE),        // 边框
    divider: Color(0xFFE3E8EE),       // 分割线
    disabledBg: Color(0xFFEDF2F7),    // 禁用背景
    overlay: Color(0x1A0A2540),       // 遮罩
    error: Color(0xFFE53E3E),         // 错误
    success: Color(0xFF38A169),       // 成功
    warning: Color(0xFFD69E2E),       // 警告
    info: Color(0xFF3182CE),          // 信息
  ),
  radius: ParkRadius(
    none: 0, xs: 2, sm: 4, md: 8, lg: 12, xl: 16, brFull: 999,
  ),
  spacing: ParkSpacing(
    xs: 4, sm: 8, base: 16, md: 24, lg: 32, xl: 48,
  ),
  typography: ParkTypography(
    fontFamily: 'Inter',
    sizeCaption: 12, sizeBodySmall: 13, sizeBody: 14,
    sizeH3: 16, sizeH2: 20, sizeH1: 24,
    weightRegular: FontWeight.w400,
    weightMedium: FontWeight.w500,
    weightBold: FontWeight.w700,
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
| `ParkSearch` | `hintText` | `'搜索'` |

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
| `ParkButtonGroup` | 按钮组 — 无缝拼接、首尾圆角 | `direction` |
| `ParkText` | 排版 — 预设 `bodySmall` / `body` / `h3` / `h2` / `h1` | `preset`, `maxLines` |
| `ParkIcon` | 图标容器 — 统一尺寸/颜色 | `size`, `color` |
| `ParkLink` | 链接 — 支持 href 跳转 | `href`, `underline` |
| `ParkDivider` | 分割线 — 文字/图标插入 | `text`, `direction` |
| `ParkFab` | 浮动操作按钮 | `onPressed` |
| `ParkSpace` | 间距组件 — 统一子元素间距 | `size`, `direction`, `wrap` |

## 展示（Display）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkCard` | 卡片容器 — 标题/描述/图标指示条/loading/可折叠 | `title`, `description`, `icon`, `loading`, `collapsible` |
| `ParkTag` | 标签 — 5 色主题、checkable、closable、4 种变体 | `theme`, `checkable`, `closable`, `shape` |
| `ParkBadge` | 徽标 — 数字/红点/自定义 | `count`, `dot`, `max` |
| `ParkAvatar` | 头像 — 图片/文字/图标 | `src`, `name`, `size` |
| `ParkCell` | 列表项 — 左图标+标题+说明+右箭头 | `title`, `leftIcon`, `note`, `onPressed` |
| `ParkTable` | 表格 — 排序/选择/固定列/展开行/虚拟滚动 | `columns`, `dataSource`, `rowSelection` |
| `ParkGrid` | 网格布局 | `columns`, `gap` |
| `ParkList` | 长列表 | `data`, `itemBuilder` |
| `ParkSkeleton` | 骨架屏 | `type`, `lines` |
| `ParkEmpty` | 空状态 | `message`, `image` |
| `ParkImage` | 图片 — 缓存/占位/错误/预览/圆角/预加载 | `src`, `previewable`, `fadeInDuration`, `retry` |
| `ParkImageViewer` | 大图预览 | `images`, `initialIndex` |
| `ParkTooltip` | 文字提示 | `message`, `position` |
| `ParkPopover` | 气泡卡片 | `content`, `trigger` |
| `ParkTree` | 树 | `data`, `onSelect` |
| `ParkTimeline` | 时间线 | `items` |
| `ParkCollapse` | 折叠面板 | `items`, `accordion` |
| `ParkCountdown` | 倒计时 | `time`, `onEnd` |
| `ParkCounter` | 数字递增 | `from`, `to`, `duration` |
| `ParkDescriptions` | 描述列表 | `items`, `column` |
| `ParkEllipsis` | 文字省略 | `text`, `maxLines`, `expandable` |
| `ParkFooter` | 页脚 | `content` |
| `ParkProgress` | 进度条 | `percent`, `strokeColor`, `status` |
| `ParkQRCode` | 二维码 | `data`, `size` |
| `ParkResult` | 结果页 | `status`, `title`, `subTitle` |
| `ParkSticky` | 吸顶容器 | `offset` |
| `ParkSwiper` | 轮播 | `items`, `autoPlay`, `duration` |
| `ParkWatermark` | 水印 | `text`, `opacity` |

## 输入（Input / Form）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkInput` | 文本输入框 — 前后缀/清除/搜索/密码/字数统计 | `prefixIcon`, `suffix`, `showCount`, `maxLength` |
| `ParkTextarea` | 多行输入框 | `minLines`, `maxLines`, `showCount` |
| `ParkSearch` | 搜索框 — 历史缓存/建议面板/加载态 | `cacheService`, `hintText`, `showCancel` |
| `ParkSelect` | 下拉选择器 | `options`, `placeholder`, `searchable` |
| `ParkDatePicker` | 日期选择器 — 日期/时间/日期时间/年月/带秒 | `mode`, `firstDate`, `lastDate`, `format` |
| `ParkDateRangePicker` | 日期范围选择器 — 快捷预设 | `startDate`, `endDate`, `presets` |
| `ParkTimePicker` | 时间选择器 | `value`, `onChanged` |
| `ParkSwitch` | 开关 | `value`, `onChanged`, `loading` |
| `ParkCheckbox` | 复选框 — 组/全选/半选 | `value`, `onChanged`, `indeterminate` |
| `ParkRadio` | 单选框 — 点式/按钮式/Join 模式/图标 | `options`, `radioStyle`, `buttonJoin`, `optionBuilder` |
| `ParkSegmented` | 分段控制器 — 单选/多选/滑块 | `items`, `value`, `multiSelect` |
| `ParkSlider` | 滑动输入条 | `value`, `min`, `max`, `step` |
| `ParkStepper` | 步进器 | `value`, `min`, `max`, `step` |
| `ParkRate` | 评分 | `value`, `count`, `allowHalf` |
| `ParkPicker` | 滚动选择器 | `options`, `value` |
| `ParkCascader` | 级联选择器 | `options`, `value`, `changeOnSelect` |
| `ParkTransfer` | 穿梭框 | `data`, `targetKeys` |
| `ParkTreeSelect` | 树选择 | `options`, `value` |
| `ParkAutoComplete` | 自动完成 | `options`, `onSearch`, `value` |
| `ParkColorPicker` | 颜色选择器 | `value`, `onChanged` |
| `ParkCalendar` | 日历 | `value`, `onChanged` |
| `ParkForm` | 表单 — 校验/提交/双向绑定 | `formKey`, `bindingService`, `submitLabel` |
| `ParkFormItem` | 表单项 — 标签/校验/布局 | `label`, `required`, `validator`, `bindKey` |
| `ParkFormSection` | 表单分组 | `title`, `children` |
| `ParkInputGroup` | 输入框组合 | `children` |
| `ParkInputNumber` | 数字输入框 | `value`, `min`, `max`, `step` |
| `ParkUpload` | 上传 | `action`, `accept`, `multiple` |

## 反馈（Feedback）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkDialog` | 对话框 — alert/confirm/info/自定义内容/全屏 | `title`, `content`, `footer`, `fullscreen` |
| `ParkPopup` | 弹出面板 — 底部/居中/顶部/动画 | `visible`, `position`, `animation` |
| `ParkActionSheet` | 操作菜单 | `actions`, `cancelText` |
| `ParkToast` | 轻提示 — success/error/info/warning | 全局静态方法 |
| `ParkMessage` | 全局消息 | 全局静态方法 |
| `ParkNotification` | 通知提醒 | `title`, `message`, `duration` |
| `ParkAlert` | 警告提示 | `type`, `message`, `closable` |
| `ParkDropdownFilter` | 筛选下拉栏 — 多标签/单多选/网格/自定义 | `items`, `style` |
| `ParkDropdownMenu` | 下拉菜单 | `items`, `onSelected` |
| `ParkDropdownSheet` | 底部下拉面板 | `title`, `options`, `child` |
| `ParkLoading` | 加载指示器 | `tip` |
| `ParkOverlay` | 遮罩层 | `visible`, `opacity` |
| `ParkPopconfirm` | 气泡确认框 | `title`, `onConfirm`, `onCancel` |
| `ParkRefresh` | 下拉刷新 | `onRefresh`, `child` |
| `ParkSwipeCell` | 滑动操作 | `leftActions`, `rightActions`, `child` |
| `ParkNoticeBar` | 通告栏 | `text`, `mode` |

## 导航（Navigation）

| 组件 | 说明 | 关键属性 |
|------|------|---------|
| `ParkNavBar` | 导航栏 | `title`, `leftWidget`, `rightWidget` |
| `ParkTabs` | 标签页 | `tabs`, `activeIndex`, `onChange` |
| `ParkTabBar` | 标签栏 | `tabs`, `activeIndex`, `onChange` |
| `ParkMenu` | 导航菜单 | `items`, `mode` |
| `ParkBreadcrumb` | 面包屑 | `items` |
| `ParkPagination` | 分页 | `current`, `total`, `pageSize`, `onChange` |
| `ParkSteps` | 步骤条 | `current`, `steps` |
| `ParkDrawer` | 抽屉 | `visible`, `position`, `child` |
| `ParkBackTop` | 回到顶部 | `target`, `visibleHeight` |
| `ParkLayout` | 布局容器 | `header`, `aside`, `content`, `footer` |
| `ParkAnchor` | 锚点 | `items`, `offset` |
| `ParkIndexes` | 索引列表 | `data`, `itemBuilder` |
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
