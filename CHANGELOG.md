## 0.2.0

- **全量组件审计** — 审查 93 个组件，修复 3 个 Bug（`park_radio` 变量作用域、`park_popup` warning、`park_swipe_cell` 可配置性）
- **全局国际化系统** — 新增 `ParkLocalizations` 抽象类 + `ParkLocalizationsWidget` + `ParkLocalizationsZh` (中文) / `ParkLocalizationsEn` (英文)
- **主题快捷常量** — 新增 `parkThemeDataLight` / `parkThemeDataDark` 快速 `ThemeData`
- **README 重写** — 完整的使用指南：主题注入 4 种方式、国际化 4 种方式、完整示例 App
- **功能性增强**：
  - `ParkDatePicker` — 新增 `timeWithSeconds` 模式
  - `ParkSearch` — 缓存服务接口 `ParkSearchCache` + `cacheService`/`cacheScope`
  - `ParkDropdownFilter` — 视觉增强（选项卡片阴影、图标支持）
  - `ParkCard` — 新增 `description` / `icon` / `showIndicator`
  - `ParkRadio` — 新增 `buttonJoin` 紧密拼接模式
  - `ParkPopup` — 新增 `showModal` 静态方法
  - `ParkImage` — 新增 `preloadImage` / `clearCache` / `evictImage` API

## 0.1.0

- Initial public release of park_ui: a Flutter component library (Stripe-inspired design language) with 72 components across 6 categories (基础/输入/导航/展示/反馈/表单), data-binding support, and a dynamic form engine.
