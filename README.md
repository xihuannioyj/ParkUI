# park_ui

A standalone, pluggable Flutter UI component library with a complete design-token
system, data-binding support, and a schema-driven dynamic form engine.

## Features

- **72 components** across 6 categories (基础 / 输入 / 导航 / 展示 / 反馈 / 表单)
- Complete design-token system (color / typography / spacing / radius / shadow / motion)
- Data-binding support (path-based two-way binding)
- Schema-driven dynamic form engine (reactions, sync / async validation, formatting)
- Zero global state dependencies (no GetX / Provider required)

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  park_ui: ^0.1.0
```

Or run:

```bash
flutter pub add park_ui
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

MaterialApp(
  theme: ThemeData(extensions: [ParkThemeData.light()]),
  darkTheme: ThemeData(extensions: [ParkThemeData.dark()]),
  home: Scaffold(
    body: Column(
      children: [
        ParkButton(
          variant: ParkButtonVariant.primary,
          onPressed: () {},
          child: Text('提交'),
        ),
        ParkInput(label: '用户名', hintText: '请输入用户名'),
      ],
    ),
  ),
);
```

## Component Index

### 基础 (6)
ParkButton · ParkText · ParkIcon · ParkDivider · ParkFab · ParkLink

### 输入 (19)
ParkInput · ParkTextarea · ParkSearch · ParkSwitch · ParkCheckbox · ParkRadio · ParkSelect · ParkDatePicker · ParkPicker · ParkCascader · ParkTreeSelect · ParkSlider · ParkStepper · ParkRate · ParkUpload · ParkForm · ParkSegmented · ParkCalendar · ParkInputGroup

### 导航 (10)
ParkTabs · ParkTabBar · ParkNavBar · ParkSideBar · ParkSteps · ParkDrawer · ParkBackTop · ParkIndexes · ParkBreadcrumb · ParkPagination

### 展示 (23)
ParkAvatar · ParkBadge · ParkCell · ParkDescriptions · ParkTag · ParkCollapse · ParkEmpty · ParkImage · ParkImageViewer · ParkProgress · ParkResult · ParkSkeleton · ParkSwiper · ParkTable · ParkCounter · ParkFooter · ParkGrid · ParkList · ParkEllipsis · ParkTimeline · ParkTooltip · ParkSticky · ParkCard

### 反馈 (12)
ParkDialog · ParkToast · ParkLoading · ParkActionSheet · ParkPopup · ParkDropdownMenu · ParkNoticeBar · ParkMessage · ParkPopover · ParkRefresh · ParkSwipeCell · ParkOverlay

### 表单 (2)
ParkDynamicForm · ParkBinding

**Total: 72 components** across 6 categories.

## Repository

https://github.com/xihuannioyj/ParkUI

## License

[MIT](./LICENSE)
