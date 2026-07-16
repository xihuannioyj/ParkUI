# Park UI Design System — 完整设计规范

> **版本**: 1.0.0 | **设计语言**: Stripe-inspired | **基础字体**: Inter
> **更新日期**: 2026-07-11 | **状态**: 已定稿

---

## 目录

1. [设计哲学](#1-设计哲学)
2. [色彩体系](#2-色彩体系)
3. [字体层级](#3-字体层级)
4. [间距规则](#4-间距规则)
5. [圆角体系](#5-圆角体系)
6. [阴影体系](#6-阴影体系)
7. [动效规范](#7-动效规范)
8. [表面风格](#8-表面风格)
9. [基础组件规范](#9-基础组件规范)
10. [可访问性](#10-可访问性)
11. [暗色模式](#11-暗色模式)
12. [设计令牌索引](#12-设计令牌索引)

---

## 1. 设计哲学

### 1.1 核心理念

Park UI 的设计语言受 **Stripe** 启发，强调：

- **清晰优先** — 减少视觉噪音，每个界面元素必须有明确目的
- **一致性强** — 所有组件共享同一套设计令牌，确保视觉统一
- **品牌温度** — 标志性 blurple (#635BFF) 点缀在关键交互点
- **包容性** — WCAG AA 级别可访问性是最低要求，非可选项

### 1.2 层级结构

```
设计令牌 (Tokens)
    ├── 颜色 (ParkColors)
    ├── 字体 (ParkTypography)
    ├── 间距 (ParkSpacing)
    ├── 圆角 (ParkRadius)
    ├── 阴影 (ParkShadows)
    └── 动效 (ParkMotion)
        │
        v
主题数据 (ParkThemeData) — ThemeExtension 打包
        │
        v
组件库 (所有 ParkXxx 组件)
        │
        v
应用层 (App 消费)
```

### 1.3 设计参数基线

| 参数 | 值 | 说明 |
|------|-----|------|
| DESIGN_VARIANCE | 4 | Offset / 适度不对称 |
| VISUAL_DENSITY | 5 | 标准应用密度 |
| MOTION_INTENSITY | 5 | 流畅停靠过渡 |
| 基准像素 | 4px | 所有间距/尺寸是 4 的倍数 |

---

## 2. 色彩体系

### 2.1 品牌色

```
品牌主色:  #635BFF  — Stripe Blurple
品牌浅色:  #F5F3FF  — 极浅紫（hover / 浅色按钮底）
品牌深色:  #4B45C6  — 按下态（active / pressed）
文字反色:  #FFFFFF  — 深色背景上的白色文字
```

#### 品牌 10 阶色板

| 阶数 | 亮色模式 | 暗色模式 | 用途 |
|------|----------|----------|------|
| 1 (最浅) | `#F5F3FF` | `#2E2A5E` | 极浅背景 |
| 2 | `#EDE9FE` | `#37307A` | hover 浅色底 |
| 3 | `#DDD6FE` | `#4238A8` | 标签/徽标浅色 |
| 4 | `#C4B5FD` | `#5147CC` | 次要高亮 |
| 5 | `#A78BFA` | `#635BFF` | 品牌辅助元素 |
| **6 (主色)** | **`#635BFF`** | **`#635BFF`** | **品牌主色** |
| 7 | `#5B54E8` | `#7A73FF` | hover 加深 |
| 8 | `#5147CC` | `#8A84FF` | active 加深 |
| 9 | `#4238A8` | `#A8A3FF` | 强调文本 |
| 10 (最深) | `#312A7A` | `#E0DDFF` | 最深强调 |

> **🔍 可访问性**: 品牌主色 `#635BFF` 在白底上对比度 5.4:1，符合 WCAG AA 标准 (≥4.5:1)。在深色背景上对比度 4.8:1。

### 2.2 功能色

| 角色 | 亮色主色 | 亮色浅色 | 暗色主色 | 暗色浅色 | 用途 |
|------|----------|----------|----------|----------|------|
| ✅ 成功 | `#1BB978` | `#D9F7EA` | `#34D399` | `#0E2A22` | 成功状态、正面反馈 |
| ⚠️ 警告 | `#FFB400` | `#FFE9B8` | `#FFC453` | `#2A2310` | 注意、提示 |
| ❌ 错误 | `#DF1B41` | `#FCE0E4` | `#F25767` | `#2C0E13` | 错误状态、危险操作 |
| ℹ️ 信息 | `#635BFF` | `#F5F3FF` | `#635BFF` | `#1A1733` | 普通提示 |

> **🔍 可访问性**: 成功色 `#1BB978` 在白底上对比度 3.5:1（仅用于大文本/图标）。错误色 `#DF1B41` 在白底上对比度 4.8:1。

### 2.3 中性色 — 文字

| 令牌 | 亮色 | 暗色 | 对比度(AA) | 用途 |
|------|------|------|-----------|------|
| `textPrimary` | `#0A2540` | `#FFFFFF` | 13.5:1 | 主要正文、标题 |
| `textSecondary` | `#425466` | `#ADB8C9` | 7.0:1 | 次要文字、说明 |
| `textPlaceholder` | `#6C7E90` | `#7A8AA0` | 4.7:1 | 占位文字 |
| `textDisabled` | `#748492` | `#5E6B7E` | 4.5:1 | 禁用状态文字 |
| `textOnBrand` | `#FFFFFF` | `#FFFFFF` | — | 品牌色背景上的文字 |

### 2.4 中性色 — 边框 & 分割线

| 令牌 | 亮色 | 暗色 | 用途 |
|------|------|------|------|
| `border` | `#E3E8EE` | `#1FFFFFFF` (白12%) | 组件边框 |
| `borderLight` | `#EDF0F5` | `#14FFFFFF` (白8%) | 轻量边框、hover 态 |
| `divider` | `#140A2540` (navy 7.8%) | `#1AFFFFFF` (白10%) | 列表分割线 |

### 2.5 中性色 — 背景

| 令牌 | 亮色 | 暗色 | 用途 |
|------|------|------|------|
| `background` | `#F6F9FC` | `#0A1B2E` | 页面背景 |
| `surface` | `#FFFFFF` | `#0F2438` | 卡片/容器表面 |
| `overlay` | `#730A2540` (navy 45%) | `#99000000` (黑 60%) | 遮罩层 |
| `disabledBg` | `#EDF0F5` | `#16283C` | 禁用状态背景 |

### 2.6 色板选择指引

```dart
// ✅ 正确用法
Container(
  color: park.colors.background,  // 页面背景
  child: Card(
    color: park.colors.surface,     // 卡片表面
    child: Text('标题', style: TextStyle(color: park.colors.textPrimary)),
  ),
)

// ❌ 错误用法 — 硬编码颜色值
Container(
  color: Color(0xFFF6F9FC),  // 应使用 park.colors.background
)
```

---

## 3. 字体层级

### 3.1 字体族

| 角色 | 字体 | 回退 |
|------|------|------|
| UI 文本 | **Inter** | `system-ui, -apple-system, sans-serif` |
| 数字/代码 | Inter（可启用 tabular-nums） | — |

> Inter 是一款专为屏幕阅读优化的无衬线字体，在 12px-34px 范围内都有良好的可读性表现。

### 3.2 字号层级

| 层级 | 令牌 | 字号 | 行高 | 字重 | 字间距 | 用途 |
|------|------|------|------|------|--------|------|
| Display | `sizeDisplay` | **34px** | ×1.25 = 42px | Semi Bold (600) | — | 页面级大标题 |
| H1 | `sizeH1` | **28px** | ×1.25 = 35px | Semi Bold (600) | — | 区块标题 |
| H2 | `sizeH2` | **22px** | ×1.25 = 27px | Semi Bold (600) | — | 卡片/面板标题 |
| H3 | `sizeH3` | **18px** | ×1.25 = 22px | Medium (500) | — | 子标题/分组标题 |
| Body | `sizeBody` | **16px** | ×1.5 = 24px | Regular (400) | — | 正文（默认） |
| Body Small | `sizeBodySmall` | **14px** | ×1.5 = 21px | Regular (400) | — | 次要正文、表单标签 |
| Caption | `sizeCaption` | **13px** | ×1.5 = 19px | Regular (400) | — | 辅助文字、时间戳 |
| Overline | `sizeOverline` | **11px** | ×1.25 = 14px | Medium (500) | +0.5px | 标签、角标、元信息 |

### 3.3 字重体系

| 字重 | Flutter 常量 | 用途 |
|------|-------------|------|
| Regular / 400 | `FontWeight.w400` | 正文、辅助文字 |
| Medium / 500 | `FontWeight.w500` | 子标题、按钮标签、导航项 |
| Semi Bold / 600 | `FontWeight.w600` | 标题（H1-H2）、重要强调 |

> 不使用 Bold (700) 及以上字重 — Semi Bold 已足够提供层级区分。

### 3.4 行高规则

- **标题行高**: 1.25（紧凑，保持标题与内容的亲密性）
- **正文行高**: 1.5（宽松，改善长篇阅读体验）

### 3.5 排版层级示例

```dart
// 页面标题
Text('订单管理', style: park.typography.display.copyWith(color: park.colors.textPrimary))

// 区块标题
Text('基本信息', style: park.typography.h1)

// 卡片标题
Text('客户详情', style: park.typography.h2)

// 表单字段标签
Text('邮箱地址', style: park.typography.bodySmall.copyWith(color: park.colors.textSecondary))

// 辅助信息
Text('最后更新: 2 分钟前', style: park.typography.caption.copyWith(color: park.colors.textPlaceholder))

// 角标文字
Text('新', style: park.typography.overline)
```

---

## 4. 间距规则

### 4.1 间距体系

采用 **4px 基准**的等比缩放间距体系：

| 令牌 | 值 | 名称 | 典型用途 |
|------|-----|------|----------|
| `xxs` | **2px** | 极细 | 图标与文字间隙、分割线偏移 |
| `xs` | **4px** | 超小 | 紧凑元素间距、Tag 内边距 |
| `sm` | **8px** | 小 | 内联元素间距、输入框内边距 |
| `md` | **12px** | 中小 | 标签与值间距、列表项内 |
| **`base`** | **16px** | **默认** | **卡片内边距、表单元素间距** |
| `lg` | **20px** | 中大 | 区块内分组间距 |
| `xl` | **24px** | 大 | 卡片间距、表单分组间距 |
| `xxl` | **32px** | 超大 | 区块间距、section 间距 |
| `page` | **48px** | 页面 | 页面级留白、大区块间距 |

### 4.2 间距使用指引

```dart
// ✅ 层级嵌套间距模式
Column(
  children: [
    // Section 1
    Card(
      child: Padding(
        padding: EdgeInsets.all(park.spacing.base), // 16px — 卡片内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('标题', style: ...),
            SizedBox(height: park.spacing.sm), // 8px — 标题与内容的间隙
            Text('内容...'),
            SizedBox(height: park.spacing.md), // 12px — 内容行间隙
            Text('更多内容...'),
          ],
        ),
      ),
    ),
    SizedBox(height: park.spacing.xl), // 24px — 卡片间距
    
    // Section 2
    Card(...),
  ],
)

// ❌ 错误用法
SizedBox(height: 10)  // 不是 4 的倍数
SizedBox(height: 15)  // 不是 4 的倍数
```

### 4.3 间距推荐速查

| 场景 | 间距值 | 令牌 |
|------|--------|------|
| 按钮水平内边距 | 24px (medium) / 32px (large) | spacing.base+sm / spacing.xxl |
| 按钮垂直内边距 | 8px (medium) | spacing.sm |
| 输入框与标签间距 | 8px | spacing.sm |
| 表单字段间距 | 24px | spacing.xl |
| 列表项间距 | 12px | spacing.md |
| 卡片内边距 | 16px | spacing.base |
| 卡片与卡片间距 | 24px | spacing.xl |
| Section 间距 | 32px | spacing.xxl |
| 弹窗内边距 | 24px | spacing.xl |
| Table 单元格内边距 | 12px 8px | spacing.md / spacing.sm |

---

## 5. 圆角体系

### 5.1 圆角层级

| 令牌 | 值 | 用途 |
|------|-----|------|
| `xs` | **4px** | Tag、Badge、小元素、输入框（small） |
| `sm` | **8px** | 按钮默认圆角、输入框（medium） |
| `md` | **12px** | 卡片、面板、对话框 |
| `lg` | **16px** | 大卡片、底部弹窗 |
| `xl` | **20px** | 模态框、大 Dialog |
| `full` | **9999px** | 胶囊按钮、头像、Switch |

### 5.2 圆角参考

| 组件 | 圆角 | 说明 |
|------|------|------|
| ParkButton (small) | `radius.xs` = 4px | 小型按钮 |
| ParkButton (medium) | `radius.sm` = 8px | 默认按钮 |
| ParkButton (large) | `radius.sm` = 8px | 大型按钮 |
| ParkButton (round) | `radius.full` = 9999px | 胶囊形 |
| ParkInput | `radius.sm` = 8px | 输入框 |
| ParkCard | `radius.md` = 12px | 卡片 |
| ParkDialog | `radius.lg` = 16px | 对话框 |
| ParkPopup | `radius.lg` = 16px | 弹出层 |
| ParkSelect | `radius.sm` = 8px | 选择器 |
| Tag/Badge | `radius.xs` = 4px | 小元素 |

---

## 6. 阴影体系

### 6.1 阴影层级 (亮色模式)

| 层级 | 阴影组合 | 用途 |
|------|----------|------|
| **sm** (小) | `0 1px 4px navy@7%` + `0 2px 8px navy@4%` | 卡片默认状态、按钮浮起 |
| **md** (中) | `0 2px 8px navy@8%` + `0 6px 16px navy@4%` | 下拉菜单、浮动面板、Select 弹出层 |
| **lg** (大) | `0 6px 16px navy@11%` + `0 12px 32px navy@7%` | 对话框、模态框、通知 |

### 6.2 阴影示例

```dart
// ✅ 小阴影 — 卡片
Container(
  decoration: BoxDecoration(
    boxShadow: park.shadows.sm,
  ),
)

// ✅ 中阴影 — 浮层
Container(
  decoration: BoxDecoration(
    boxShadow: park.shadows.md,
  ),
)

// ✅ 大阴影 — 弹窗
Container(
  decoration: BoxDecoration(
    boxShadow: park.shadows.lg,
  ),
)
```

### 6.3 暗色模式阴影

暗色模式下阴影使用黑色调而非 navy，适应深色背景：

| 层级 | 阴影组合 |
|------|----------|
| **sm** | `0 1px 4px black@25%` |
| **md** | `0 2px 8px black@32%` + `0 6px 16px black@20%` |
| **lg** | `0 6px 16px black@40%` + `0 12px 32px black@25%` |

---

## 7. 动效规范

### 7.1 时长规范

| 令牌 | 时长 | 适用场景 |
|------|------|----------|
| `quick` | **150ms** | hover、focus、pressed 即时反馈 |
| `standard` | **250ms** | 面板展开、弹窗出入、页面切换 |
| `slow` | **400ms** | 复杂动画、多元素编排、入场序列 |

### 7.2 缓动曲线

| 曲线 | 值 | 适用场景 |
|------|-----|----------|
| `defaultEasing` | `easeOutCubic` | 标准入场、元素出现 — 快入慢出 |
| `enterEasing` | `easeOut` | 进入动效 |
| `exitEasing` | `easeIn` | 退出动效 |

### 7.3 动效使用示例

```dart
// 标准过渡
AnimatedContainer(
  duration: ParkMotion.standard,
  curve: ParkMotion.defaultEasing,
)

// 即时反馈（按钮 hover）
AnimatedScale(
  duration: ParkMotion.quick,
  curve: ParkMotion.defaultEasing,
)

// 入场动效（页面切换）
SlideTransition(
  position: animation,
  child: child,
)  // 使用 standard 250ms + easeOutCubic
```

---

## 8. 表面风格

Park UI 支持 5 种表面风格 (`ParkSurfaceStyle`)，通过主题 `surfaceStyle` 切换：

| 风格 | 说明 | 阴影 | 边框 | 背景 |
|------|------|------|------|------|
| `stripe` (默认) | 条纹经典风 | 淡阴影 | 细边框 `#E3E8EE` | 纯白 |
| `flat` | 扁平化 | 无 | `borderLight` 色边框 | 纯色块 |
| `glass` | 毛玻璃 | 半透明模糊 | 浅描边 | `BackdropFilter` |
| `neo` | 新拟态 | 双柔光阴影 | 无边框 | 与背景同色 |
| `neon` | 暗夜霓虹 | 品牌色辉光 | 发光描边 | 深色面 |

### 8.1 默认 Stripe 风格的卡片渲染规则

```dart
// Card 在 stripe 风格下的渲染
Container(
  decoration: BoxDecoration(
    color: park.colors.surface,                    // #FFFFFF
    borderRadius: park.radius.brMd,                // 12px
    border: Border.all(color: park.colors.border), // #E3E8EE
    boxShadow: park.shadows.sm,                    // 淡阴影
  ),
)
```

---

## 9. 基础组件规范

### 9.1 ParkButton 设计规范

| 属性 | 规范值 |
|------|--------|
| 圆角 (默认) | `radius.sm` = 8px |
| 圆角 (round) | `radius.full` |
| 内边距 (medium) | horizontal: 24px, vertical: 8px |
| 字号 (medium) | 14px / Body Small |
| 字重 | Medium (500) |
| 高度 (medium) | 36px |
| 最小宽度 (medium) | 64px |

**变体应用规则：**

| 变体 | 背景色 | 文字色 | 边框 | Hover 态 |
|------|--------|--------|------|----------|
| `primary` | `colors.brand` | `white` | 无 | 加深 `brandDark` |
| `secondary` | `colors.surface` | `colors.textPrimary` | `colors.border` | 边框加深 |
| `text` | 透明 | `colors.textPrimary` | 无 | 背景 8% 透明度 |
| `link` | 透明 | `colors.brand` | 无 | 下划线 |
| `danger` | `colors.error` | `white` | 无 | 加深 error |
| `filled` | textPrimary 4% | `colors.textPrimary` | 无 | 6% |
| `ghost` | 透明 | `colors.brand` | `colors.brand` | 背景 4% |
| `light` | brand 8% | `colors.brand` | 无 | 12% |

### 9.2 ParkInput 设计规范

| 属性 | medium (默认) | small | large |
|------|-----------|-------|-------|
| 高度 | 48px | 32px | 56px |
| 字号 | 16px | 14px | 18px |
| 内边距 | 12px 16px | 8px 12px | 16px 20px |
| 圆角 | `radius.sm` = 8px | `radius.xs` = 4px | `radius.sm` = 8px |

**交互态边框色：**
```
默认 → border (#E3E8EE)
悬浮 → textSecondary (#425466)
聚焦 → brand (#635BFF)
错误 → error (#DF1B41)
禁用 → borderLight (#EDF0F5)
```

### 9.3 ParkCard 设计规范

| 属性 | 规范值 |
|------|--------|
| 圆角 | `radius.md` = 12px |
| 内边距 (default) | `spacing.base` = 16px |
| 内边距 (small) | `spacing.sm` = 8px |
| 阴影 (默认) | `shadows.sm` |
| Hover 阴影 | `shadows.md` |
| 边框 | `colors.border` (#E3E8EE) 1px |
| 标题字号 | `typography.h2` = 22px |

### 9.4 ParkSelect / ParkDropdown 设计规范

| 属性 | 规范值 |
|------|--------|
| 高度 | 48px (medium 级别) |
| 圆角 | `radius.sm` = 8px |
| 内边距 | 12px 16px |
| 弹出层阴影 | `shadows.md` |
| 弹出层圆角 | `radius.sm` = 8px |
| 选项项高度 | 36px |
| 选项项内边距 | 8px 16px |

### 9.5 ParkTable 设计规范

| 属性 | 规范值 |
|------|--------|
| 单元格内边距 | 12px 8px (md/sm) |
| 表头字号 | `typography.bodySmall` (14px) |
| 表头字重 | Medium (500) |
| 表头文字色 | `colors.textSecondary` |
| 表头背景 | `colors.background` |
| 表头下边框 | 2px `colors.border` |
| 行高 | 44px (紧凑) / 52px (默认) |
| 行斑马纹 | 交替 `background` / `surface` |
| 单元格边框 | 1px `colors.borderLight` |
| 圆角 | 0（直角表格风格） |

### 9.6 ParkTag 设计规范

| 属性 | 规范值 |
|--------|--------|
| 圆角 | `radius.xs` = 4px |
| 高度 | 22px |
| 内边距 | 4px 8px (xs/sm) |
| 字号 | `typography.overline` = 11px |
| 字重 | Medium (500) |
| 字间距 | +0.5px |

### 9.7 ParkDialog 设计规范

| 属性 | 规范值 |
|--------|--------|
| 圆角 | `radius.lg` = 16px |
| 内边距 | `spacing.xl` = 24px |
| 遮罩色 | `colors.overlay` |
| 标题字号 | `typography.h2` = 22px |
| 标题字重 | Semi Bold |
| 按钮间距 | `spacing.base` = 16px |
| 内容字号 | `typography.sizeBody` = 16px |
| 阴影 | `shadows.lg` |

### 9.8 ParkAlert 设计规范

| 属性 | 规范值 |
|--------|--------|
| 圆角 | `radius.sm` = 8px |
| 内边距 | 12px 16px |
| 字号 | `typography.sizeBodySmall` = 14px |
| 类型色 | success/warning/error/info 对应功能色 |
| 类型浅色底 | 对应 `*Light` 色 |
| 图标与文字间距 | `spacing.sm` = 8px |

---

## 10. 可访问性

### 10.1 颜色对比度 (WCAG AA)

| 组合 | 对比度 | 合规 |
|------|--------|------|
| textPrimary (#0A2540) 在白底上 | **13.5:1** | ✅ AAA |
| textSecondary (#425466) 在白底上 | **7.0:1** | ✅ AAA |
| brand (#635BFF) 在白底上 | **5.4:1** | ✅ AA |
| error (#DF1B41) 在白底上 | **4.8:1** | ✅ AA |
| success (#1BB978) 在白底上 | 3.5:1 | ⚠️ 仅大文本/图标 |
| textPlaceholder (#6C7E90) 在白底上 | 4.7:1 | ✅ AA |

### 10.2 触摸目标

所有交互元素最小触摸目标：**44px × 44px** (WCAG 2.5.5)

| 组件 | 默认高度 | 合规 |
|------|----------|------|
| ParkButton (small) | 28px | ❌ 需 `minWidth` ≥ 44px |
| ParkButton (medium) | 36px | ❌ 需 `minWidth` 补偿 |
| ParkButton (large) | 44px | ✅ |
| ParkInput (medium) | 48px | ✅ |
| ParkSwitch | 28px | ❌ 视觉高度不足，交互区域应扩展 |

### 10.3 键盘导航

所有交互组件必须支持：
- **Tab 键**遍历可聚焦元素
- **Enter/Space** 激活按钮和链接
- **Escape** 关闭弹窗、下拉菜单
- **箭头键**在选项间导航
- **明确的焦点指示器**(2px brand 色 outline, offset 2px)

### 10.4 动效尊重

```dart
// 尊重用户「减少动效」偏好
if (MediaQuery.of(context).disableAnimations) {
  // 使用即时切换，避免动画
} else {
  // 使用标准动效
}
```

---

## 11. 暗色模式

### 11.1 暗色模式定义

暗色模式通过 `ParkThemeData.dark()` 工厂构造启用，自动切换所有令牌。

**核心规则：**
- 背景从浅灰蓝 → 深 navy (`#F6F9FC` → `#0A1B2E`)
- 卡片从纯白 → 稍亮深色 (`#FFFFFF` → `#0F2438`)
- 文字从深 navy → 白色 (`#0A2540` → `#FFFFFF`)
- 边框从浅灰 → 半透明白 (`#E3E8EE` → `white@12%`)
- 阴影从 navy 色调 → 黑色调

### 11.2 在应用中切换

```dart
MaterialApp(
  theme: parkThemeDataLight,        // 浅色
  darkTheme: parkThemeDataDark,      // 深色
  themeMode: ThemeMode.system,       // 跟随系统
)
```

### 11.3 组件暗色适配原则

| 视觉元素 | 适配方式 |
|----------|----------|
| 纯色填充 | 使用 `colors.*` 令牌，自动亮暗切换 |
| 透明度效果 | 暗色模式下透明度应保持或略微增加 |
| 阴影 | 使用 `shadows.dark()` 工厂 |
| 品牌色阶 | 暗色下翻转渐变方向（浅色变深） |
| 图片/图标 | 使用原色，不强制反色 |

---

## 12. 设计令牌索引

### 12.1 完整令牌一览

| 类别 | 令牌类 | 文件路径 |
|------|--------|----------|
| 🎨 色彩 | `ParkColors` | `src/theme/tokens/park_colors.dart` |
| 🔤 字体 | `ParkTypography` | `src/theme/tokens/park_typography.dart` |
| 📐 间距 | `ParkSpacing` | `src/theme/tokens/park_spacing.dart` |
| ⭕ 圆角 | `ParkRadius` | `src/theme/tokens/park_radius.dart` |
| 🌑 阴影 | `ParkShadows` | `src/theme/tokens/park_shadows.dart` |
| 🎬 动效 | `ParkMotion` | `src/theme/tokens/park_motion.dart` |
| 📦 主题数据 | `ParkThemeData` | `src/theme/park_theme_data.dart` |
| 🔧 主题工具 | `ParkTheme` | `src/theme/park_theme.dart` |
| 🎯 尺寸 | `ParkSizing` | `src/theme/tokens/park_sizing.dart` |
| 🖼️ 图标主题 | `ParkIconThemeData` | `src/theme/park_icon_theme_data.dart` |

### 12.2 主题消费路径

```dart
// 🅰️ 通过 ParkTheme 静态方法
final colors = ParkTheme.colorsOf(context);
final typography = ParkTheme.typographyOf(context);
final spacing = ParkTheme.spacingOf(context);
final radius = ParkTheme.radiusOf(context);
final shadows = ParkTheme.shadowsOf(context);

// 🅱️ 通过 BuildContext 扩展
final park = context.parkTheme;
final brand = context.parkColors.brand;
final bodyStyle = context.parkTypography.body;
final cardPadding = context.parkSpacing.base;

// 🅲 通过快捷主题常量
MaterialApp(
  theme: parkThemeDataLight,
  darkTheme: parkThemeDataDark,
)
```

### 12.3 组件映射参考

| 组件 | 设计规范章节 | 代码路径 |
|------|-------------|----------|
| ParkButton | §9.1 | `src/components/base/park_button.dart` |
| ParkInput | §9.2 | `src/components/input/park_input.dart` |
| ParkCard | §9.3 | `src/components/display/park_card.dart` |
| ParkSelect | §9.4 | `src/components/input/park_select.dart` |
| ParkTable | §9.5 | `src/components/display/park_table.dart` |
| ParkTag | §9.6 | `src/components/display/park_tag.dart` |
| ParkDialog | §9.7 | `src/components/feedback/park_dialog.dart` |
| ParkAlert | §9.8 | `src/components/feedback/park_alert.dart` |

---

## 附录 A：设计合规检查清单

- [ ] 所有颜色值来自 `ParkColors`，无硬编码
- [ ] 所有尺寸/间距是 4px 的倍数
- [ ] 所有字号来自 `ParkTypography` 层级
- [ ] 圆角从 `ParkRadius` 选取
- [ ] 交互状态有 hover/focus/active/disabled 覆盖
- [ ] 暗色模式已适配
- [ ] 颜色对比度 ≥ 4.5:1 (AA) — 文本
- [ ] 触摸目标 ≥ 44px
- [ ] 键盘导航可操作
- [ ] 尊重 `disableAnimations` 系统偏好

---

*Park UI Design System v1.0.0 — 本文件是设计规范的权威数据源，代码实现应与其保持严格一致。*
