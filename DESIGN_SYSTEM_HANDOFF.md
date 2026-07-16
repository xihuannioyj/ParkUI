# Park UI Design System — 开发工程师 Agent 执行文档

> **任务类型**: UI / interface (design system — Ardot 画布)
> **版本**: 1.0.0 | **语言**: 中文 | **状态**: 已定稿
> **源文件**: `packages/park_ui/DESIGN_SYSTEM.md`

---

## 目录

1. [任务概述](#1-任务概述)
2. [必需 Skill 加载指令](#2-必需-skill-加载指令)
3. [设计规范 — 完整数据](#3-设计规范--完整数据)
4. [Ardot 执行工作流](#4-ardot-执行工作流)
5. [组件画板规格](#5-组件画板规格)
6. [交付验收标准](#6-交付验收标准)

---

## 1. 任务概述

### 1.1 任务目标

在 Ardot 画布上创建 **Park UI Design System** 的完整视觉文档，包含：

| 交付物 | 内容 |
|--------|------|
| **色板页面** | 品牌色板 + 功能色 + 中性色 + 暗色模式色板 |
| **字体层级页面** | Inter 字体 8 级字号展示 + 字重/行高说明 |
| **间距体系页面** | 4px 基准 9 级间距可视化 + 场景速查表 |
| **圆角体系页面** | 6 级圆角 + 组件映射 |
| **阴影体系页面** | 3 级阴影 (sm/md/lg) + 亮/暗双模式 |
| **组件规范页面** | ParkButton / ParkInput / ParkCard / ParkDialog 的完整设计规格 |
| **可访问性页面** | WCAG AA 对比度表 + 触摸目标 + 键盘导航说明 |

### 1.2 设计理念

- **设计语言**: Stripe 启发 — 清晰优先、品牌温度
- **品牌色**: Blurple `#635BFF`
- **基准像素**: 4px（所有间距/尺寸是 4 的倍数）
- **基础字体**: Inter
- **可访问性**: WCAG AA 最低要求

---

## 2. 必需 Skill 加载指令

执行此任务前，必须加载以下 Skill：

### Step A: 加载 ardot-design-core

```markdown
@skill:ardot-design-core
```

> 这是基础工作流和硬规则，包含 Step 0-8 的标准流程、画布操作语法、验证规则。

### Step B: 加载 domain skill (通过 ardot-design-router 路由)

本任务属于 **UI / interface** 类别（design system）。按路由器规则加载：

```markdown
@skill:ardot-ui-design
```

> 提供 UI 界面设计的领域指导方针。用于 design system / 组件库任务时使用默认的 `guidelines-web-app.md`。

### Step C: 加载参考文件

执行过程中按需加载以下文件：

| 时机 | 文件 |
|------|------|
| Step 3 (领域指导) | `guidelines-web-app.md` (从 ardot-ui-design skill 加载) |
| Step 4 前 | `tool-usage/search-style-guide.md` |
| Step 5 前 | `tool-usage/build-style-guide.md` |
| Step 7 前 | `rules/effects-guide.md` |
| Step 7 中 | `tool-usage/batch-edit.md`, `tool-usage/apply-variables.md` |
| Step 8 后 | `rules/design-rules.md` (Post-Generation Validation) |

---

## 3. 设计规范 — 完整数据

### 3.1 色彩体系

#### 品牌色

| 角色 | 色值 | 用途 |
|------|------|------|
| brand (主色) | `#635BFF` | 品牌主色、主要按钮、关键交互 |
| brandLight (浅色) | `#F5F3FF` | hover、浅色按钮底 |
| brandDark (深色) | `#4B45C6` | active、pressed 按下态 |
| textOnBrand | `#FFFFFF` | 品牌色背景上的文字 |

#### 品牌 10 阶色板

| 阶 | 亮色 | 暗色 | 用途 |
|----|-------|-------|------|
| 1 | `#F5F3FF` | `#2E2A5E` | 极浅背景 |
| 2 | `#EDE9FE` | `#37307A` | hover 浅色底 |
| 3 | `#DDD6FE` | `#4238A8` | 标签/徽标浅色 |
| 4 | `#C4B5FD` | `#5147CC` | 次要高亮 |
| 5 | `#A78BFA` | `#635BFF` | 品牌辅助元素 |
| **6** | **`#635BFF`** | **`#635BFF`** | **品牌主色** |
| 7 | `#5B54E8` | `#7A73FF` | hover 加深 |
| 8 | `#5147CC` | `#8A84FF` | active 加深 |
| 9 | `#4238A8` | `#A8A3FF` | 强调文本 |
| 10 | `#312A7A` | `#C4BFFE` | 最深强调 |

> 品牌主色 `#635BFF` WCAG AA 对比度 5.4:1（白底）。

#### 功能色

| 角色 | 亮色主色 | 亮色浅色 | 暗色主色 | 暗色浅色 | 用途 |
|------|----------|----------|----------|----------|------|
| 成功 | `#1BB978` | `#D9F7EA` | `#34D399` | `#0E2A22` | 成功状态、正面反馈 |
| 警告 | `#FFB400` | `#FFE9B8` | `#FFC453` | `#2A2310` | 注意、提示 |
| 错误 | `#DF1B41` | `#FCE0E4` | `#F25767` | `#2C0E13` | 错误状态、危险操作 |
| 信息 | `#635BFF` | `#F5F3FF` | `#635BFF` | `#1A1733` | 普通提示 |

#### 中性色 — 文字

| 令牌 | 亮色 | 暗色 | 对比度(AA) | 用途 |
|------|------|------|-----------|------|
| textPrimary | `#0A2540` | `#FFFFFF` | 13.5:1 ✅ AAA | 主要正文、标题 |
| textSecondary | `#425466` | `#ADB8C9` | 7.0:1 ✅ AAA | 次要文字、说明 |
| textPlaceholder | `#6C7E90` | `#7A8AA0` | 4.7:1 ✅ AA | 占位文字 |
| textDisabled | `#748492` | `#5E6B7E` | 4.5:1 ✅ AA | 禁用状态文字 |
| textOnBrand | `#FFFFFF` | `#FFFFFF` | — | 品牌色背景上的文字 |

#### 中性色 — 边框 & 分割线

| 令牌 | 亮色 | 暗色 | 用途 |
|------|------|------|------|
| border | `#E3E8EE` | 白 12% (`#1FFFFFFF`) | 组件边框 |
| borderLight | `#EDF0F5` | 白 8% (`#14FFFFFF`) | 轻量边框、hover 态 |
| divider | navy 7.8% (`#140A2540`) | 白 10% (`#1AFFFFFF`) | 列表分割线 |

#### 中性色 — 背景

| 令牌 | 亮色 | 暗色 | 用途 |
|------|------|------|------|
| background | `#F6F9FC` | `#0A1B2E` | 页面背景 |
| surface | `#FFFFFF` | `#0F2438` | 卡片/容器表面 |
| overlay | navy 45% (`#730A2540`) | 黑 60% (`#99000000`) | 遮罩层 |
| disabledBg | `#EDF0F5` | `#16283C` | 禁用状态背景 |

### 3.2 字体层级

#### 字体族

- **UI 文本**: Inter (回退: `system-ui, -apple-system, sans-serif`)
- **数字/代码**: Inter (可启用 tabular-nums)

#### 字号层级

| 层级 | 令牌 | 字号 | 行高 | 字重 | 字间距 | 用途 |
|------|------|------|------|------|--------|------|
| Display | sizeDisplay | **34px** | ×1.25=42px | Semi Bold 600 | — | 页面级大标题 |
| H1 | sizeH1 | **28px** | ×1.25=35px | Semi Bold 600 | — | 区块标题 |
| H2 | sizeH2 | **22px** | ×1.25=27px | Semi Bold 600 | — | 卡片/面板标题 |
| H3 | sizeH3 | **18px** | ×1.25=22px | Medium 500 | — | 子标题/分组标题 |
| Body | sizeBody | **16px** | ×1.5=24px | Regular 400 | — | 正文（默认） |
| Body Small | sizeBodySmall | **14px** | ×1.5=21px | Regular 400 | — | 次要正文、表单标签 |
| Caption | sizeCaption | **13px** | ×1.5=19px | Regular 400 | — | 辅助文字、时间戳 |
| Overline | sizeOverline | **11px** | ×1.25=14px | Medium 500 | +0.5px | 标签、角标、元信息 |

#### 行高规则

- **标题行高**: 1.25（紧凑）
- **正文行高**: 1.5（宽松）

### 3.3 间距体系 (4px 基准)

| 令牌 | 值 | 典型用途 |
|------|-----|----------|
| xxs | **2px** | 图标与文字间隙、分割线偏移 |
| xs | **4px** | 紧凑元素间距、Tag 内边距 |
| sm | **8px** | 内联元素间距、输入框内边距 |
| md | **12px** | 标签与值间距、列表项内 |
| **base** | **16px** | **卡片内边距、表单元素间距（最常用）** |
| lg | **20px** | 区块内分组间距 |
| xl | **24px** | 卡片间距、表单分组间距 |
| xxl | **32px** | 区块间距、section 间距 |
| page | **48px** | 页面级留白、大区块间距 |

#### 场景速查

| 场景 | 值 | 令牌 |
|------|-----|------|
| 按钮水平内边距 (medium) | 24px | base+sm |
| 按钮垂直内边距 (medium) | 8px | sm |
| 输入框与标签间距 | 8px | sm |
| 表单字段间距 | 24px | xl |
| 卡片内边距 | 16px | base |
| 卡片间距 | 24px | xl |
| Section 间距 | 32px | xxl |
| 弹窗内边距 | 24px | xl |

### 3.4 圆角体系

| 令牌 | 值 | 用途 |
|------|-----|------|
| xs | **4px** | Tag、Badge、输入框 small |
| sm | **8px** | 按钮默认、输入框 medium |
| md | **12px** | 卡片、面板 |
| lg | **16px** | 大卡片、底部弹窗 |
| xl | **20px** | 模态框、大 Dialog |
| full | **9999px** | 胶囊按钮、头像、Switch |

#### 组件圆角映射

| 组件 | 圆角 |
|------|------|
| ParkButton (default) | 8px (sm) |
| ParkButton (round) | 9999px (full) |
| ParkInput | 8px (sm) |
| ParkCard | 12px (md) |
| ParkDialog | 16px (lg) |
| ParkSelect | 8px (sm) |
| Tag / Badge | 4px (xs) |

### 3.5 阴影体系

| 层级 | 亮色模式 | 暗色模式 | 用途 |
|------|----------|----------|------|
| **sm** | 0 1px 4px navy@7% + 0 2px 8px navy@4% | 0 1px 4px black@25% | 卡片默认、按钮浮起 |
| **md** | 0 2px 8px navy@8% + 0 6px 16px navy@4% | 0 2px 8px black@32% + 0 6px 16px black@20% | 下拉菜单、浮层面板 |
| **lg** | 0 6px 16px navy@11% + 0 12px 32px navy@7% | 0 6px 16px black@40% + 0 12px 32px black@25% | 对话框、模态框 |

### 3.6 动效规范

| 令牌 | 时长 | 适用场景 |
|------|------|----------|
| quick | **150ms** | hover、focus、pressed 即时反馈 |
| standard | **250ms** | 面板展开、弹窗出入、页面切换 |
| slow | **400ms** | 复杂动画、多元素编排、入场序列 |

**缓动曲线**:
- defaultEasing → `easeOutCubic`（快入慢出，标准入场）
- enterEasing → `easeOut`
- exitEasing → `easeIn`

### 3.7 设计参数基线

| 参数 | 值 | 说明 |
|------|-----|------|
| DESIGN_VARIANCE | 4 | Offset / 适度不对称 |
| VISUAL_DENSITY | 5 | 标准应用密度 |
| MOTION_INTENSITY | 5 | 流畅停靠过渡 |

---

## 4. Ardot 执行工作流

### Step 0: 创建设计文件

```javascript
// 调用 create_design
create_design({ fileName: "Park UI Design System" })
// 然后等待文件加载完成（fetch_file_info 确认）
```

**注意**: 这是新的设计文件，根节点 PageID = `0:1`。最多调用一次 `create_design`。

### Step 1: 读取现有状态

新文件 → 跳过（空画布，无内容可读）

### Step 2: 创意 vs 组合

→ **创意 (Creative)** — 新建设计系统文档

### Step 3: 加载领域指导方针

加载 `ardot-ui-design` 的 `references/guidelines-web-app.md`

### Step 4: 搜索 Style Guide

调用 `search_style_guide`:

```javascript
search_style_guide({
  topic: "web-app",
  designKeywords: "SaaS design system Stripe modern clean purple brand",
  colorKeywords: "purple brand navy neutral clean professional",
  typographyKeywords: "modern clean sans-serif developer",
  layoutKeywords: "component library design system tokens"
})
```

### Step 5: 构建 Style Guide

根据搜索结果投票，调用 `build_style_guide`。

> 如果搜索风格库的结果与 Park UI 的 Strip/blurple 风格不匹配，可以跳过 style/color 域的选择，使用本文件 §3 中的精确色值自行构建。

### Step 6: 定位可用空间 + 获取文件信息

```javascript
// 并行调用
fetch_file_info()
locate_available_space({ width: 2400, height: 4000 }) // 为整个设计系统预留空间
```

### Step 7: 执行设计 — batch_edit 序列

> **重要**: 每个 `batch_edit` 最多 25 个操作。按逻辑 sections 分批。

#### Batch 1: 设计系统容器框架 + 变量系统 [T1]

```javascript
// 1. 创建设计系统根容器 (FRAME)
// 2. 创建 Design Variables (apply_variables):
//    - 颜色: brand, brandLight, brandDark, success, warning, error, info,
//      textPrimary, textSecondary, textPlaceholder, textDisabled,
//      border, borderLight, divider, background, surface, overlay, disabledBg
//    - 每个变量有 Light/Dark 两个 mode
// 3. 创建子分类容器: 色板区、字体区、间距区、圆角区、阴影区、组件区
```

变量系统建议结构:
```javascript
apply_variables({
  variables: {
    "Color/Brand": {
      modes: ["Light", "Dark"],
      variables: {
        "brand": { type: "COLOR", valuesByMode: { Light: {r:0.39,g:0.36,b:1.0,a:1}, Dark: {r:0.39,g:0.36,b:1.0,a:1} } },
        "brandLight": { type: "COLOR", valuesByMode: { Light: {r:0.96,g:0.95,b:1.0,a:1}, Dark: {r:0.18,g:0.09,b:0.20,a:1} } },
        "brandDark": { type: "COLOR", valuesByMode: { Light: {r:0.29,g:0.27,b:0.78,a:1}, Dark: {r:0.29,g:0.27,b:0.78,a:1} } },
      }
    },
    "Color/Semantic": {
      modes: ["Light", "Dark"],
      variables: {
        "success": { type: "COLOR", valuesByMode: { Light: {r:0.11,g:0.73,b:0.47,a:1}, Dark: {r:0.20,g:0.83,b:0.60,a:1} } },
        "warning": { type: "COLOR", valuesByMode: { Light: {r:1.0,g:0.71,b:0.0,a:1}, Dark: {r:1.0,g:0.77,b:0.33,a:1} } },
        "error": { type: "COLOR", valuesByMode: { Light: {r:0.88,g:0.11,b:0.25,a:1}, Dark: {r:0.95,g:0.34,b:0.40,a:1} } },
        "info": { type: "COLOR", valuesByMode: { Light: {r:0.39,g:0.36,b:1.0,a:1}, Dark: {r:0.39,g:0.36,b:1.0,a:1} } },
      }
    },
    "Color/Text": {
      modes: ["Light", "Dark"],
      variables: {
        "textPrimary": { type: "COLOR", valuesByMode: { Light: {r:0.04,g:0.15,b:0.25,a:1}, Dark: {r:1.0,g:1.0,b:1.0,a:1} } },
        "textSecondary": { type: "COLOR", valuesByMode: { Light: {r:0.26,g:0.33,b:0.40,a:1}, Dark: {r:0.68,g:0.72,b:0.79,a:1} } },
        "textPlaceholder": { type: "COLOR", valuesByMode: { Light: {r:0.53,g:0.60,b:0.67,a:1}, Dark: {r:0.48,g:0.54,b:0.63,a:1} } },
        "textDisabled": { type: "COLOR", valuesByMode: { Light: {r:0.53,g:0.57,b:0.64,a:1}, Dark: {r:0.37,g:0.42,b:0.49,a:1} } },
      }
    },
    "Color/Border": {
      modes: ["Light", "Dark"],
      variables: {
        "border": { type: "COLOR", valuesByMode: { Light: {r:0.89,g:0.91,b:0.93,a:1}, Dark: {r:1.0,g:1.0,b:1.0,a:0.12} } },
        "borderLight": { type: "COLOR", valuesByMode: { Light: {r:0.93,g:0.94,b:0.96,a:1}, Dark: {r:1.0,g:1.0,b:1.0,a:0.08} } },
      }
    },
    "Color/Background": {
      modes: ["Light", "Dark"],
      variables: {
        "background": { type: "COLOR", valuesByMode: { Light: {r:0.96,g:0.98,b:0.99,a:1}, Dark: {r:0.04,g:0.11,b:0.18,a:1} } },
        "surface": { type: "COLOR", valuesByMode: { Light: {r:1.0,g:1.0,b:1.0,a:1}, Dark: {r:0.06,g:0.14,b:0.22,a:1} } },
        "overlay": { type: "COLOR", valuesByMode: { Light: {r:0.04,g:0.15,b:0.25,a:0.45}, Dark: {r:0.0,g:0.0,b:0.0,a:0.60} } },
        "disabledBg": { type: "COLOR", valuesByMode: { Light: {r:0.93,g:0.94,b:0.96,a:1}, Dark: {r:0.09,g:0.15,b:0.24,a:1} } },
      }
    },
    "Spacing": {
      modes: ["Default"],
      variables: {
        "xxs": { type: "FLOAT", value: 2 },
        "xs": { type: "FLOAT", value: 4 },
        "sm": { type: "FLOAT", value: 8 },
        "base": { type: "FLOAT", value: 16 },
        "md": { type: "FLOAT", value: 12 },
        "lg": { type: "FLOAT", value: 20 },
        "xl": { type: "FLOAT", value: 24 },
        "xxl": { type: "FLOAT", value: 32 },
        "page": { type: "FLOAT", value: 48 },
      }
    }
  }
})
```

#### Batch 2: 色板展示区 [T1 scaffolding → T3 visual]

创建色板展示页面（screenshot 验证颜色）：

**布局**: 主容器 1200×1800 → 5 个 section 垂直排列

```
色板展示区 (FRAME, 1200×1800)
├── 品牌色板 (FRAME)
│   ├── 标题: "品牌色 Brand Colors"
│   ├── 说明: "Stripe blurple #635BFF · WCAG AA 5.4:1"
│   └── 10 个色块水平排列 (每块 100×60)
│       └── 色块内标注 阶数 + 色值
├── 功能色 (FRAME)
│   ├── 4 行: success / warning / error / info
│   └── 每行: 主色块 + 浅色块 + 文字标签
├── 文字色 (FRAME)
│   ├── textPrimary / textSecondary / textPlaceholder / textDisabled
│   └── 深色块 + 白色文字标注对比度
├── 边框 & 背景色 (FRAME)
│   └── border / borderLight / background / surface / overlay / disabledBg
└── 暗色模式色板 (FRAME)
    └── 使用深 navy 背景，展示暗色色板
```

验证: `capture_screenshot(nodeIds: ["paletteSection"])`

#### Batch 3: 字体层级展示区 [T3]

```
字体层级展示区 (FRAME, 1200×800)
├── 标题: "字体层级 Typography"
├── 字体信息: "Inter · 行高: 标题 1.25 / 正文 1.5"
├── 8 行层级展示
│   ├── Display 34px Semi Bold — 示例文字
│   ├── H1 28px Semi Bold
│   ├── H2 22px Semi Bold
│   ├── H3 18px Medium
│   ├── Body 16px Regular
│   ├── Body Small 14px Regular
│   ├── Caption 13px Regular
│   └── Overline 11px Medium +0.5px 字间距
└── 字重参考: Regular 400 / Medium 500 / Semi Bold 600
```

验证: `capture_screenshot(nodeIds: ["typographySection"])`

#### Batch 4: 间距 + 圆角 + 阴影展示区 [T3]

```
间距区 (FRAME, 1200×600)
├── 标题: "间距体系 Spacing (4px 基准)"
└── 9 条水平条可视化 (每条标注令牌名 + 值 + 典型用途)

圆角区 (FRAME, 1200×400)
├── 标题: "圆角体系 Radius"
├── 6 个圆角示例卡片 (80×80) 依次排列
└── 组件圆角映射表 (文字说明)

阴影区 (FRAME, 1200×500)
├── 标题: "阴影体系 Shadows"
├── 3 张卡片展示阴影效果 (sm/md/lg)
├── 卡片内文字标注阴影参数
└── 暗色模式阴影说明
```

验证: `capture_screenshot(nodeIds: ["spacingSection", "radiusSection", "shadowSection"])`

#### Batch 5: 组件规范区 — ParkButton [T4]

```
按钮规范区 (FRAME, 1200×800)
├── 标题: "ParkButton 设计规范"
├── 尺寸对比 (small 28px / medium 36px / large 44px)
│   └── 3 个按钮水平排列，不同高度
├── 变体展示 (8 种 variant)
│   └── primary / secondary / text / link / ghost / danger / filled / light
├── 形状 (rectangle / round / circle)
├── 状态 (default / hover / active / disabled / loading)
├── 设计规格表:
│   ├── 圆角: 8px (sm), round=9999px (full)
│   ├── 内边距(medium): 水平 24px, 垂直 8px
│   ├── 字号(medium): 14px (bodySmall)
│   └── 字重: Medium 500
└── 交互反馈: hover 阴影提升 → sm, active 按压缩放
```

#### Batch 6: 组件规范区 — ParkInput + ParkCard + ParkDialog [T4]

```
输入框规范区 (FRAME, 1200×500)
├── 标题: "ParkInput 设计规范"
├── 三档尺寸: small 32px / medium 48px / large 56px
├── 状态: 默认 / 悬浮 / 聚焦(brand) / 错误(error) / 禁用
├── 圆角: 8px (sm), small 变体 4px (xs)
└── 边框色解析链: status > 错误 > 聚焦 > 悬浮 > 默认

卡片规范区 (FRAME, 1200×400)
├── 标题: "ParkCard 设计规范"
├── 圆角: 12px (md)
├── 内边距: 16px (base)
├── 阴影: sm, hover → md
├── 边框: border 1px
└── 表面风格: stripe / flat / glass / neo / neon

对话框规范区 (FRAME, 1200×400)
├── 标题: "ParkDialog 设计规范"
├── 圆角: 16px (lg)
├── 内边距: 24px (xl)
├── 阴影: lg
├── 遮罩: overlay (navy 45%)
└── 标题字号: 22px (H2)
```

#### Batch 7: 可访问性 + 设计令牌索引 [T4]

```
可访问性区 (FRAME, 1200×400)
├── 标题: "可访问性 Accessibility (WCAG AA)"
├── 对比度表 (5 行: textPrimary / textSecondary / brand / error / placeholder)
├── 触摸目标: 44px 最小交互尺寸
├── 焦点指示器: 2px brand outline, offset 2px
└── 键盘导航: Tab / Enter / Escape / Arrow

令牌索引区 (FRAME, 1200×300)
├── 完整令牌一览表
└── 消费路径: ParkTheme.of(context) → colors / typography / spacing / radius / shadows
```

### Step 8: 验证

#### 分阶段验证

| Batch | 验证类型 | 方法 |
|-------|---------|------|
| Batch 1 (结构) | T1 | `capture_layout(problemsOnly: true)` |
| Batch 2 (色板) | T4 | `capture_screenshot` + `capture_layout` 一次 |
| Batch 3 (字体) | T3 | `capture_screenshot` |
| Batch 4 (间距/圆角/阴影) | T4 | `capture_screenshot` + `capture_layout` 一次 |
| Batch 5-6 (组件) | T4 | `capture_screenshot` + `capture_layout` 一次 |
| Batch 7 (可访问性) | T3 | `capture_screenshot` |
| **最终** | T5 | 全页面 `capture_screenshot` |

#### 收敛阈值

- 最多 2 次修复迭代 / 每个 section
- 忽略 ≤4px 的间距噪音
- 一旦 section 匹配规范，不再主观润色

#### Screenshot 配置

```javascript
capture_screenshot({
  nodeIds: ["nodeId1", "nodeId2"],
  screenShotDir: ".workbuddy/screenshots"
})
```

> Screenshots 是内部验证产物，路径不应暴露给用户，不应写到 `/tmp` 或项目根目录。

---

## 5. 组件画板规格

### 5.1 画布总览

```
设计系统画布 (2400 × 4000)
├── 设计系统根容器 (2400 × 4000)
│   ├── 标题区 (顶部品牌标识 + dsecription)
│   ├── §1 色板展示区 (1200 × 1800)
│   ├── §2 字体层级区 (1200 × 800)
│   ├── §3 间距体系区 (1200 × 600)
│   ├── §4 圆角体系区 (1200 × 400)
│   ├── §5 阴影体系区 (1200 × 500)
│   ├── §6 ParkButton 组件规范 (1200 × 800)
│   ├── §7 ParkInput 组件规范 (1200 × 500)
│   ├── §8 ParkCard 组件规范 (1200 × 400)
│   ├── §9 ParkDialog 组件规范 (1200 × 400)
│   └── §10 可访问性 + 令牌索引 (1200 × 700)
```

### 5.2 组件创建原则

1. 将可复用的色块、标签、表格制作成 COMPONENT，然后通过 `type: "ref"` 插入实例
2. 先创建 Design Variables（见 Batch 1），再将变量绑定到节点属性（`fill: "$:Color/Brand:brand"`）
3. 组件规范展示中的按钮/输入框/卡片尽量使用设计系统变量引用，便于后续主题切换

### 5.3 色块组件规格

```
颜色色块 (COMPONENT, 100×60)
├── 填充: 绑定到对应颜色变量
├── 圆角: 8px
└── 内嵌文字: 色值标注 (size: 11px, fill: 根据背景色自动选择黑/白)
```

---

## 6. 交付验收标准

### ✅ 设计系统验证清单

| 检查项 | 标准 | 验证方式 |
|--------|------|----------|
| 品牌色板完整 | 10 阶 + 主色 + 浅/深 | screenshot |
| 功能色完整 | success/warning/error/info + 浅色 | screenshot |
| 中性色完整 | 文字 5 阶 + 边框 3 阶 + 背景 4 阶 | screenshot |
| 暗色模式 | 所有颜色有暗色对应值 | 切换 mode 验证 |
| 字体层级 | 8 级，字号/行高/字重准确 | screenshot |
| 间距体系 | 9 级，4px 基准 | screenshot + layout check |
| 圆角体系 | 6 级 + 组件映射 | screenshot |
| 阴影体系 | 3 级 + 亮暗双模式 | screenshot |
| Button 规范 | 8 变体 + 3 尺寸 + 形状 + 状态 | screenshot |
| Input 规范 | 3 尺寸 + 5 状态 + 边框链 | screenshot |
| Card 规范 | 圆角/间距/阴影/表面风格 | screenshot |
| Dialog 规范 | 圆角/间距/阴影/遮罩 | screenshot |
| 可访问性 | 对比度表 + 触摸目标 + 焦点 | screenshot |
| 变量系统 | 所有颜色绑定到变量 | fetch_variables 验证 |

### ⚠️ 注意事项

1. **Ardot MCP 工具限制**:
   - `create_design` 最多调用一次
   - `batch_edit` 每次最多 25 个操作
   - `capture_screenshot` 每次最多 10 个 node IDs
   - 等待文件异步加载完成后再操作

2. **颜色格式**:
   - Ardot 使用 rgba (0-1 浮点数): `#635BFF` → `{r:0.39, g:0.36, b:1.0, a:1}`
   - 16 进制 → 浮点转换: hex 值 ÷ 255

3. **变量绑定语法**: `$:<SetName>:<VariableName>`
   - 例如: `$:Color/Brand:brand`, `$:Spacing:base`

4. **禁止使用子 Agent**: 所有工作在主对话直接执行

5. **语言**: 画布上的所有文字内容使用中文生成

---

*本文档由 UI Designer 生成，供开发工程师 Agent 在 Ardot 画布上执行 Design System 构建。*
*源规范文档: `DESIGN_SYSTEM.md`（park_ui Flutter 代码仓库）*
