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
