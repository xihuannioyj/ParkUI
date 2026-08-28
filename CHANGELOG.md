## Unreleased

### Added
- ParkMap 地图组件：flutter_map + 天地图 WMTS 底图，支持标记点（自定义 widget + 点击回调）、标记聚合（flutter_map_marker_cluster，可定制「N 套」聚合节点）、地图选点（可开关）、距离圈（CircleLayer，半径可配）、列表联动（onMarkerTap + 受控 selectedMarkerId 高亮）。天地图 key 通过构造参数注入，组件库不内置业务凭据。
- ParkMap 组件 spec（ParkComponentSpec）、最小单测、example MapDemo。
- ParkSteps 新增 sticky 属性：true 时以 SliverPersistentHeader 渲染，可在 CustomScrollView 中固定头部；false（默认）随列表滚动。仅水平方向支持。
- ParkSteps sticky 回归测试（默认模式 + 固定头部模式）。

## 0.8.0 (2026-07-17)

### Fixes
- FormGroup 生命周期修复：订阅管理（addControl 订阅存储/取消）、dispose 顺序修正
- mounted 守卫补全：ParkAnchor / ParkBackTop / ParkCascader / ParkLoading 异步后检查 mounted

### Improvements
- Spec↔Code 对齐：ParkTable / ParkSelect / ParkUpload / ParkTree / ParkDynamicForm 属性与文档一致
- 测试质量提升：修正无效断言、补零覆盖组件测试

### Performance
- Table 列宽缓存（column width cache）
- Formatter format guard（科学计数法/NaN 防护）

## 0.7.0 (2026-07-16)

### Features
- Form: 声明式字段联动 (dependencies + visibleWhen/disableWhen 表达式引擎)
- Select: 远程搜索 (onSearchAsync + debounce + 竞态保护)
- i18n: 新增韩语(ko)/西班牙语(es)/法语(fr) 支持，共 6 语言
- Table: maxTagCount 支持

### Improvements
- Demo 覆盖率 81%+ (83/102 组件)
- 1008 测试全部通过
- 应用层扫码登录不再拦截首页
- 所有 warning 清理

### Fixes
- 应用层编译错误全部修复
- ThemeController Rx→普通字段迁移完成
- bookkeeping 模块编译修复

## 0.6.0 (2026-07-16)

### Features
- Table: 虚拟滚动支持 (virtualScroll)
- Table: 列筛选功能 (filterDropdown)
- FormGroup: enable/disable/markDirty/getEnabledValues API
- Tree: checkStrictly 父子独立控制
- Spec: 14 个 spec 文件迁移到 park_ui 包

### Improvements
- 性能优化: Timeline/NoticeBar/Watermark/List/Typography
- 代码质量: Toast isLoading 命名修正/Drawer 类型安全
- 测试: 128+ 测试 (FormGroup 89 + smoke 19 + golden 18 + group 22)
- Demo: 47 个示例页面 (覆盖率 46%)

### Fixes
- 5 个编译错误修复
- 23 个 warning 清理
- 14 项 P2 组件/引擎优化
- 14 项应用层修复

## 0.5.0 — Phase 37-38 (2026-07-16)
- FormGroup architecture upgrade (ParkAbstractControl/ParkFormGroup/ParkFormBuilder/ParkFormArray)
- Phase 37 urgent fixes: auth Completer pattern, QR login, retry Dio, SQLite PRAGMA, watchEffect recursion, NaN/Infinity, js_interop
- Phase 38 component fixes: ParkForm dispose, ParkSelect filterOption, ParkSlider didUpdateWidget, ParkList controller, ParkMenu, SQLite WAL
- Unified ParkForm 3 modes, reactive validation, data source linkage, reaction engine integration
- ParkFormArrayWidget UI binding, snapshot/restore/debounce/flatErrors extensions

## 0.4.0 — Phase 35-36 (2026-07-15)
- Global i18n migration (165 getters + 34 methods × 3 languages)
- CI/CD pipeline setup
- Example app rebuild
- Test expansion
- Accessibility improvements
- Performance optimization
- Conditional import migration (js_interop)

## 0.3.0 — Phase 33-34 (2026-07-14)
- ParkConfigProvider + theme token system
- 3 new components (ParkStatistic, ParkMentions, ParkSplitter, ParkTour)
- Audit fixes (B1-B61)
- Component spec completion

## 0.2.0 — Phase 5-32

- **B113 Enum 反序列化安全加固** — 为 `BkAccountType`、`BkCategoryType`、`BkTransactionType`、`BkRecurringFrequency`、`BkBudgetPeriod` 5 个枚举的 `fromJson` 增加 `_safeEnumValue` 边界检查，越界时回退到首个值而非抛出 `RangeError`
- **B118 颜色对比度修正** — `textPlaceholder` 从 `#8898AA`(3.5:1) 调深为 `#6C7E90`(4.7:1)，`textDisabled` 从 `#8792A2`(3.9:1) 调深为 `#748492`(4.5:1)，均满足 WCAG AA 4.5:1 标准

- **全量组件审计** — 审查 102 个组件，修复 3 个 Bug（`park_radio` 变量作用域、`park_popup` warning、`park_swipe_cell` 可配置性）
- **全局国际化系统** — 新增 `ParkLocalizations` 抽象类（119 getter + 23 方法） + `ParkLocalizationsWidget` + `ParkLocalizationsZh` (中文) / `ParkLocalizationsEn` (英文) / `ParkLocalizationsJa` (日文)
- **主题快捷常量** — 新增 `parkThemeDataLight` / `parkThemeDataDark` 快速 `ThemeData`
- **README 重写** — 完整的使用指南：主题注入 4 种方式、国际化 4 种方式、完整示例 App
- **B62 i18n 全量迁移** — 组件内硬编码字符串全量迁移至 `ParkLocalizations`（覆盖上传、时间选择器、日期快捷、表单校验等场景）
- **Phase 33-34** — 组件数从 93 增至 102；新增 `ParkImageViewer`、`ParkTour`、`ParkMessage` 等组件；表单反应引擎级联重算 (B14)、条件匹配器抽离
- **功能性增强**：
  - `ParkDatePicker` — 新增 `timeWithSeconds` 模式
  - `ParkSearch` — 缓存服务接口 `ParkSearchCache` + `cacheService`/`cacheScope`
  - `ParkDropdownFilter` — 视觉增强（选项卡片阴影、图标支持）
  - `ParkCard` — 新增 `description` / `icon` / `showIndicator`
  - `ParkRadio` — 新增 `buttonJoin` 紧密拼接模式
  - `ParkPopup` — 新增 `showModal` 静态方法
  - `ParkImage` — 新增 `preloadImage` / `clearCache` / `evictImage` API

## 0.1.0 — Initial Release

- Initial public release of park_ui: a Flutter component library (Stripe-inspired design language) with 102 components across 6 categories (基础/输入/导航/展示/反馈/表单), data-binding support, and a dynamic form engine.
