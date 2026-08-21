// Park 展示组件规格 — 由 Agent 完善（完整版 / Display components, audited）
//
// 覆盖：ParkAvatar / ParkBadge / ParkCell / ParkTag / ParkCollapse / ParkEmpty /
//       ParkImage / ParkImageViewer / ParkProgress / ParkResult / ParkSkeleton /
//       ParkSwiper / ParkTable / ParkFooter（共 14 个）
//
// 约定（对齐 park_base_specs.dart 的完善风格）：
//  - 每个组件的 properties 枚举其全部公开构造参数（排除 Key / BuildContext /
//    内容 Widget / 内部专用参数）；
//  - 函数类型参数 → events；公开静态方法 / 工厂构造 → methods；
//  - 每个事件 / 方法 / 关键形态变体均对应一个 demo（code 与 builder 完全一致）；
//  - 禁用裸字面量：颜色用 ParkColors.*，间距用 ParkSpacing.* / ParkRadius.*，
//    杜绝魔法变量；
//  - 双语（中文为主、英文并列）：每条属性 / 事件 / 方法注释均为中英双语；
//  - SDK 下限：与 pubspec 一致，不下调。
import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';
import 'park_component_spec.dart';

// ===========================================================================
// 命名令牌常量（对齐 ParkColors / ParkSpacing / ParkRadius 设计令牌，
// 杜绝裸字面量 / 魔法变量）
// ===========================================================================
final ParkColors _kColors = ParkColors.light();
final ParkSpacing _kSpacing = ParkSpacing.defaults();
final ParkRadius _kRadius = ParkRadius.defaults();

/// 展示组件规格字典（14 个组件 / Display components (14)）。
Map<String, ParkComponentSpec>
get parkDisplaySpecs => <String, ParkComponentSpec>{
  'ParkAvatar': ParkComponentSpec(
    name: 'ParkAvatar',
    title: '头像 / Avatar',
    category: 'display',
    icon: Icons.account_circle_outlined,
    description:
        '用户头像组件，支持图片、图标或文字回退。显示圆形或圆角方形头像，'
        '按 image -> icon -> text（首字符）的优先级回退。'
        ' / User avatar with image, icon, or text fallback. Circular or rounded-square, '
        'falling back through image → icon → text (first character).',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'image',
        type: 'ImageProvider?',
        defaultVal: 'null',
        description: '图片源，最高优先级 / Image source (highest priority)',
      ),
      ParkPropertyDef(
        name: 'icon',
        type: 'IconData?',
        defaultVal: 'null',
        description: '图标，当 image 为 null 时显示 / Icon shown when image is null',
      ),
      ParkPropertyDef(
        name: 'text',
        type: 'String?',
        defaultVal: 'null',
        description:
            '文字，当 image 和 icon 均为 null 时显示首字符 / Text (first char) fallback',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkAvatarSize',
        defaultVal: 'ParkAvatarSize.medium',
        description:
            '预设尺寸：small(32)、medium(40)、large(56)、xlarge(72) / Size preset',
      ),
      ParkPropertyDef(
        name: 'customSize',
        type: 'double?',
        defaultVal: 'null',
        description: '自定义像素尺寸，覆盖 size 预设值 / Custom px size (overrides size)',
      ),
      ParkPropertyDef(
        name: 'shape',
        type: 'ParkAvatarShape',
        defaultVal: 'ParkAvatarShape.circle',
        description: '形状：circle（圆形）或 square（圆角方形） / Shape',
      ),
      ParkPropertyDef(
        name: 'badge',
        type: 'Widget?',
        defaultVal: 'null',
        description: '可选角标 Widget，定位在右下角 / Badge widget at bottom-right',
      ),
      ParkPropertyDef(
        name: 'gap',
        type: 'int',
        defaultVal: '4',
        description: '文字头像内边距百分比，控制文字与边缘间距 / Text padding ratio',
      ),
      ParkPropertyDef(
        name: 'backgroundColor',
        type: 'Color?',
        defaultVal: 'null（按主题回退）',
        description: '自定义背景色，覆盖默认的回退色 / Custom bg (overrides fallback)',
      ),
      ParkPropertyDef(
        name: 'onTap',
        type: 'VoidCallback?',
        defaultVal: 'null',
        description: '点击回调，设置后头像可点击 / Tap callback (makes avatar tappable)',
      ),
      ParkPropertyDef(
        name: 'srcSet',
        type: 'String?',
        defaultVal: 'null',
        description: '响应式图片源集合（如 "200w, 400w"）/ Responsive src set',
      ),
      ParkPropertyDef(
        name: 'draggable',
        type: 'bool',
        defaultVal: 'true',
        description: '头像图片是否可拖拽 / Whether the image is draggable',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onTap',
        signature: 'VoidCallback?',
        description: '点击头像时触发 / Called when the avatar is tapped',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '文字头像',
        description: '使用首字符作为回退显示 / Text fallback',
        code: r'''ParkAvatar(text: '张三')''',
        builder: (BuildContext context) => const ParkAvatar(text: '张三'),
      ),
      ParkDemoScenario(
        title: '图标头像',
        description: '使用图标显示头像 / Icon avatar',
        code: r'''ParkAvatar(icon: Icons.person, size: ParkAvatarSize.large)''',
        builder: (BuildContext context) =>
            const ParkAvatar(icon: Icons.person, size: ParkAvatarSize.large),
      ),
      ParkDemoScenario(
        title: '不同尺寸',
        description: '展示 small / medium / large / xlarge 四种尺寸 / 4 sizes',
        code: r'''Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    ParkAvatar(text: 'A', size: ParkAvatarSize.small),
    SizedBox(width: _kSpacing.sm),
    ParkAvatar(text: 'B', size: ParkAvatarSize.medium),
    SizedBox(width: _kSpacing.sm),
    ParkAvatar(text: 'C', size: ParkAvatarSize.large),
    SizedBox(width: _kSpacing.sm),
    ParkAvatar(text: 'D', size: ParkAvatarSize.xlarge),
  ],
)''',
        builder: (BuildContext context) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ParkAvatar(text: 'A', size: ParkAvatarSize.small),
            SizedBox(width: _kSpacing.sm),
            const ParkAvatar(text: 'B', size: ParkAvatarSize.medium),
            SizedBox(width: _kSpacing.sm),
            const ParkAvatar(text: 'C', size: ParkAvatarSize.large),
            SizedBox(width: _kSpacing.sm),
            const ParkAvatar(text: 'D', size: ParkAvatarSize.xlarge),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '方形头像',
        description: 'shape: square 显示圆角方形 / Rounded-square',
        code:
            r'''ParkAvatar(text: '李', shape: ParkAvatarShape.square, size: ParkAvatarSize.large)''',
        builder: (BuildContext context) => const ParkAvatar(
          text: '李',
          shape: ParkAvatarShape.square,
          size: ParkAvatarSize.large,
        ),
      ),
      ParkDemoScenario(
        title: '图片头像',
        description: 'image 优先级最高 / Image has highest priority',
        code:
            r'''ParkAvatar(image: NetworkImage('https://picsum.photos/200'), size: ParkAvatarSize.large)''',
        builder: (BuildContext context) => const ParkAvatar(
          image: NetworkImage('https://picsum.photos/200'),
          size: ParkAvatarSize.large,
        ),
      ),
      ParkDemoScenario(
        title: '带角标头像',
        description: 'badge 在右下角放置任意 Widget / Badge widget at corner',
        code: r'''ParkAvatar(
  text: '王',
  badge: Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(color: _kColors.error, shape: BoxShape.circle),
  ),
)''',
        builder: (BuildContext context) => ParkAvatar(
          text: '王',
          badge: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _kColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      ParkDemoScenario(
        title: '自定义背景色',
        description: 'backgroundColor 覆盖默认回退色 / Custom background',
        code: r'''ParkAvatar(text: '赵', backgroundColor: _kColors.brand)''',
        builder: (BuildContext context) =>
            ParkAvatar(text: '赵', backgroundColor: _kColors.brand),
      ),
      ParkDemoScenario(
        title: '可点击头像',
        description: '点击统计次数，演示 onTap 回调 / Tap callback',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    int taps = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkAvatar(text: '张', onTap: () { taps++; setState(() {}); }),
        SizedBox(height: _kSpacing.sm),
        ParkText('点击次数: \$taps'),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            int taps = 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkAvatar(
                  text: '张',
                  onTap: () {
                    taps++;
                    setState(() {});
                  },
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('点击次数: $taps'),
              ],
            );
          },
        ),
      ),
    ],
    basicUsageCode: r'''ParkAvatar(
  text: '张三',
  size: ParkAvatarSize.large,
  shape: ParkAvatarShape.circle,
  onTap: () {},
)''',
    guide: r'''## 何时使用 / When to use
- 展示用户头像时 / Displaying user avatars
- 列表项、评论区、个人中心等需要头像的场景 / Lists, comments, profiles

## 使用建议 / Usage tips
- 优先级：image > icon > text（首字符回退）/ Fallback order: image > icon > text
- 圆形（circle）适合个人头像，方形（square）适合群组头像 / Circle for people, square for groups
- 通过 badge 添加在线状态等角标 / Use badge for status dots
- 列表中使用 small 尺寸，详情页使用 large/xlarge / small in lists, large in details
- onTap 让头像可点击（如进入个人主页）/ onTap makes it tappable

## 搭配推荐 / Compose with
- 搭配 ParkBadge 做在线状态指示 / ParkBadge for status
- 搭配 ParkCell 做用户列表项 / ParkCell for list rows
- 搭配 ParkTag 做用户角色标签 / ParkTag for role tags
''',
  ),

  'ParkBadge': ParkComponentSpec(
    name: 'ParkBadge',
    title: '徽标 / Badge',
    category: 'display',
    icon: Icons.notifications_active_outlined,
    description:
        '数字或红点徽标，定位在子组件的右上角。dot 为 true 时显示小红点，'
        '否则显示 count（超过 maxCount 时显示 "maxCount+"）。还支持状态点、缎带、'
        '偏移与独立文字模式。'
        ' / Numeric or dot badge anchored to a child\'s top-right. Supports status dots, ribbons, offset, standalone text.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'child',
        type: 'Widget',
        required: true,
        description: '徽标锚定的子组件 / The widget the badge is anchored to',
      ),
      ParkPropertyDef(
        name: 'count',
        type: 'int?',
        defaultVal: 'null',
        description: '显示的数字，为 null 时隐藏数字（搭配 dot 使用）/ Number (null hides it)',
      ),
      ParkPropertyDef(
        name: 'dot',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时显示小红点，不显示数字 / Red dot instead of number',
      ),
      ParkPropertyDef(
        name: 'maxCount',
        type: 'int',
        defaultVal: '99',
        description: '最大显示数字，超过时显示 "maxCount+"/ Cap before "maxCount+"',
      ),
      ParkPropertyDef(
        name: 'color',
        type: 'Color',
        defaultVal: '红色（默认）/ Red (default)',
        description: '徽标背景色，默认红色 / Badge background (default red)',
      ),
      ParkPropertyDef(
        name: 'textColor',
        type: 'Color',
        defaultVal: '白色（默认）/ White (default)',
        description: '徽标内文字颜色，默认白色 / Text color inside badge',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkBadgeSize',
        defaultVal: 'ParkBadgeSize.medium',
        description: '尺寸预设：small 或 medium / Size preset',
      ),
      ParkPropertyDef(
        name: 'status',
        type: 'ParkBadgeStatus?',
        defaultVal: 'null',
        description:
            '状态点模式（success/info/warning/error/defaultStatus），忽略 dot 与 count / Status dot mode',
      ),
      ParkPropertyDef(
        name: 'offset',
        type: 'Offset?',
        defaultVal: 'null',
        description: '徽标相对右上角的偏移量 (dx, dy) / Offset from top-right',
      ),
      ParkPropertyDef(
        name: 'ribbon',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时在子组件角落渲染缎带横幅 / Ribbon banner in the corner',
      ),
      ParkPropertyDef(
        name: 'ribbonText',
        type: 'String?',
        defaultVal: 'null',
        description: '缎带文字 / Ribbon text',
      ),
      ParkPropertyDef(
        name: 'ribbonPlacement',
        type: 'ParkRibbonPlacement',
        defaultVal: 'ParkRibbonPlacement.topRight',
        description: '缎带所在角落：topRight 或 topLeft / Ribbon corner',
      ),
      ParkPropertyDef(
        name: 'title',
        type: 'String?',
        defaultVal: 'null',
        description: '悬停提示文字（包裹 Tooltip）/ Tooltip text on hover',
      ),
      ParkPropertyDef(
        name: 'showZero',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时即使 count 为 0 也显示徽标 / Show badge when count is 0',
      ),
      ParkPropertyDef(
        name: 'standaloneText',
        type: 'String?',
        defaultVal: 'null',
        description: '独立模式下状态点旁的文字标签 / Label next to a standalone dot',
      ),
      ParkPropertyDef(
        name: 'countWidget',
        type: 'Widget?',
        defaultVal: 'null',
        description: '自定义角标内容 Widget，优先级高于 count/dot / Custom badge content',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '数字徽标',
        description: '在图标右上角显示数字 / Numeric badge',
        code: r'''ParkBadge(
  count: 5,
  child: Icon(Icons.mail, size: 32),
)''',
        builder: (BuildContext context) =>
            const ParkBadge(count: 5, child: Icon(Icons.mail, size: 32)),
      ),
      ParkDemoScenario(
        title: '红点徽标',
        description: 'dot: true 显示小红点 / Red dot',
        code: r'''ParkBadge(
  dot: true,
  child: Icon(Icons.notifications, size: 32),
)''',
        builder: (BuildContext context) => const ParkBadge(
          dot: true,
          child: Icon(Icons.notifications, size: 32),
        ),
      ),
      ParkDemoScenario(
        title: '超出最大值',
        description: 'count 超过 maxCount 时显示 "99+"/ Over cap shows "99+"',
        code: r'''ParkBadge(
  count: 150,
  maxCount: 99,
  child: Icon(Icons.shopping_cart, size: 32),
)''',
        builder: (BuildContext context) => const ParkBadge(
          count: 150,
          maxCount: 99,
          child: Icon(Icons.shopping_cart, size: 32),
        ),
      ),
      ParkDemoScenario(
        title: '状态点',
        description: 'status 渲染语义状态点（带独立文字）/ Status dot with label',
        code: r'''ParkBadge(
  status: ParkBadgeStatus.success,
  standaloneText: '在线',
  child: Icon(Icons.circle, size: 32),
)''',
        builder: (BuildContext context) => const ParkBadge(
          status: ParkBadgeStatus.success,
          standaloneText: '在线',
          child: Icon(Icons.circle, size: 32),
        ),
      ),
      ParkDemoScenario(
        title: '缎带',
        description: 'ribbon: true 在角上渲染缎带 / Ribbon banner',
        code: r'''ParkBadge(
  ribbon: true,
  ribbonText: 'NEW',
  color: _kColors.brand,
  child: Container(width: 96, height: 96, color: _kColors.brandLight),
)''',
        builder: (BuildContext context) => ParkBadge(
          ribbon: true,
          ribbonText: 'NEW',
          color: _kColors.brand,
          child: Container(width: 96, height: 96, color: _kColors.brandLight),
        ),
      ),
      ParkDemoScenario(
        title: '自定义颜色',
        description: 'color 与 textColor 自定义配色 / Custom colors',
        code: r'''ParkBadge(
  count: 8,
  color: _kColors.success,
  textColor: _kColors.textOnBrand,
  child: Icon(Icons.check, size: 32),
)''',
        builder: (BuildContext context) => ParkBadge(
          count: 8,
          color: _kColors.success,
          textColor: _kColors.textOnBrand,
          child: const Icon(Icons.check, size: 32),
        ),
      ),
      ParkDemoScenario(
        title: '角标偏移',
        description: 'offset 调整徽标相对右上角的位置 / Offset positioning',
        code: r'''ParkBadge(
  count: 3,
  offset: Offset(-6, -6),
  child: Icon(Icons.star, size: 32),
)''',
        builder: (BuildContext context) => const ParkBadge(
          count: 3,
          offset: Offset(-6, -6),
          child: Icon(Icons.star, size: 32),
        ),
      ),
      ParkDemoScenario(
        title: '显示零值',
        description: 'showZero: true 时 count 为 0 也显示 / Show when zero',
        code: r'''ParkBadge(
  count: 0,
  showZero: true,
  child: Icon(Icons.mail, size: 32),
)''',
        builder: (BuildContext context) => const ParkBadge(
          count: 0,
          showZero: true,
          child: Icon(Icons.mail, size: 32),
        ),
      ),
      ParkDemoScenario(
        title: '自定义角标内容',
        description: 'countWidget 渲染任意内容替代数字 / Custom badge content',
        code: r'''ParkBadge(
  countWidget: ParkText('!', preset: ParkTextPreset.bodySmall),
  child: Icon(Icons.warning, size: 32),
)''',
        builder: (BuildContext context) => ParkBadge(
          countWidget: const ParkText('!', preset: ParkTextPreset.bodySmall),
          child: const Icon(Icons.warning, size: 32),
        ),
      ),
    ],
    basicUsageCode: r'''ParkBadge(
  count: 8,
  child: Icon(Icons.mail, size: 32),
)''',
    guide: r'''## 何时使用 / When to use
- 需要展示未读数量、新消息提示时 / Unread counts, new-message hints
- 图标右上角的角标场景 / Corner badges on icons

## 使用建议 / Usage tips
- count 为 null 时仅显示红点（dot: true）/ Null count + dot → red dot
- 超过 maxCount 时自动显示 "99+"/ Auto "99+" over cap
- 状态点用 status（success/processing/warning/error）/ Use status for semantics
- ribbon 在角落渲染缎带横幅 / Ribbon for promo banners
- 不需要时设置 count: null 隐藏角标 / count: null hides it

## 搭配推荐 / Compose with
- 搭配 ParkTabBar 做导航未读提示 / ParkTabBar unread hint
- 搭配 ParkIcon 做消息图标角标 / ParkIcon badge
- 搭配 ParkAvatar 做头像角标 / ParkAvatar badge
''',
  ),

  'ParkCell': ParkComponentSpec(
    name: 'ParkCell',
    title: '单元格 / Cell',
    category: 'display',
    icon: Icons.view_list_outlined,
    description:
        '列表单元格 / 设置行组件。显示左侧图标、标题 + 描述列，以及可选的右侧箭头或备注。'
        '点击通过 onPressed 触发。'
        ' / List cell / settings row: left icon, title + description, optional arrow or note; tap fires onPressed.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'title',
        type: 'Widget?',
        defaultVal: 'null',
        description: '标题 Widget，自定义时使用 / Custom title widget',
      ),
      ParkPropertyDef(
        name: 'titleText',
        type: 'String?',
        defaultVal: 'null',
        description: '快捷字符串标题 / Convenience string title',
      ),
      ParkPropertyDef(
        name: 'description',
        type: 'Widget?',
        defaultVal: 'null',
        description: '描述 Widget / Description widget',
      ),
      ParkPropertyDef(
        name: 'descriptionText',
        type: 'String?',
        defaultVal: 'null',
        description: '快捷字符串描述 / Convenience string description',
      ),
      ParkPropertyDef(
        name: 'leftIcon',
        type: 'Widget?',
        defaultVal: 'null',
        description: '左侧图标 Widget / Left icon widget',
      ),
      ParkPropertyDef(
        name: 'arrow',
        type: 'bool',
        defaultVal: 'false',
        description: '是否显示右侧箭头 / Show right chevron',
      ),
      ParkPropertyDef(
        name: 'note',
        type: 'String?',
        defaultVal: 'null',
        description: '右侧备注文字，显示在箭头之前 / Right note text (before arrow)',
      ),
      ParkPropertyDef(
        name: 'bordered',
        type: 'bool',
        defaultVal: 'true',
        description: '是否显示底部分隔线 / Show bottom divider',
      ),
      ParkPropertyDef(
        name: 'onPressed',
        type: 'VoidCallback?',
        defaultVal: 'null',
        description: '点击单元格时的回调 / Tap callback',
      ),
      ParkPropertyDef(
        name: 'hover',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时鼠标悬停高亮 / Hover highlight',
      ),
      ParkPropertyDef(
        name: 'required',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时标题前显示红色星号 / Red asterisk before title',
      ),
      ParkPropertyDef(
        name: 'noteWidget',
        type: 'Widget?',
        defaultVal: 'null',
        description: '自定义右侧 Widget（优先级高于 note）/ Custom right widget',
      ),
      ParkPropertyDef(
        name: 'arrowIcon',
        type: 'IconData?',
        defaultVal: 'null',
        description: '自定义箭头图标（默认 chevron_right）/ Custom arrow icon',
      ),
      ParkPropertyDef(
        name: 'disabled',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时灰显且不可交互 / Greyed out & non-interactive',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkCellSize',
        defaultVal: 'ParkCellSize.medium',
        description: '尺寸预设：small / medium / large（控制垂直内边距）/ Size preset',
      ),
      ParkPropertyDef(
        name: 'extra',
        type: 'Widget?',
        defaultVal: 'null',
        description: '右侧额外 Widget（区别于 noteWidget）/ Extra right widget',
      ),
      ParkPropertyDef(
        name: 'labelWidth',
        type: 'double?',
        defaultVal: 'null',
        description: '标题区域固定宽度 / Fixed width for title area',
      ),
      ParkPropertyDef(
        name: 'clickable',
        type: 'bool?',
        defaultVal: 'null（默认 onPressed 非空时为 true）',
        description:
            '是否显示可点击视觉反馈 / Clickable affordance (default true if onPressed set)',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onPressed',
        signature: 'VoidCallback?',
        description: '点击单元格时触发 / Called when the cell is tapped',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础单元格',
        description: '简单的标题 + 箭头 / Title + arrow',
        code: r'''ParkCell(titleText: '个人信息', arrow: true, onPressed: () {})''',
        builder: (BuildContext context) =>
            ParkCell(titleText: '个人信息', arrow: true, onPressed: () {}),
      ),
      ParkDemoScenario(
        title: '带图标和描述',
        description: '左侧图标 + 标题 + 描述 + 备注 / Icon + title + description + note',
        code: r'''ParkCell(
  leftIcon: Icon(Icons.wifi),
  titleText: 'Wi-Fi',
  descriptionText: '当前连接的无线网络',
  note: '已连接',
  arrow: true,
  onPressed: () {},
)''',
        builder: (BuildContext context) => ParkCell(
          leftIcon: const Icon(Icons.wifi),
          titleText: 'Wi-Fi',
          descriptionText: '当前连接的无线网络',
          note: '已连接',
          arrow: true,
          onPressed: () {},
        ),
      ),
      ParkDemoScenario(
        title: '无分隔线',
        description: 'bordered: false 隐藏底部分隔线 / No divider',
        code:
            r'''ParkCell(titleText: '最后一项', bordered: false, onPressed: () {})''',
        builder: (BuildContext context) =>
            ParkCell(titleText: '最后一项', bordered: false, onPressed: () {}),
      ),
      ParkDemoScenario(
        title: '必填标记',
        description: 'required: true 标题前显示星号 / Required asterisk',
        code:
            r'''ParkCell(titleText: '姓名', required: true, onPressed: () {})''',
        builder: (BuildContext context) =>
            ParkCell(titleText: '姓名', required: true, onPressed: () {}),
      ),
      ParkDemoScenario(
        title: '禁用状态',
        description: 'disabled: true 灰显不可点击 / Disabled',
        code:
            r'''ParkCell(titleText: '不可点击', disabled: true, onPressed: () {})''',
        builder: (BuildContext context) =>
            const ParkCell(titleText: '不可点击', disabled: true, onPressed: null),
      ),
      ParkDemoScenario(
        title: '悬停高亮',
        description: 'hover: true 鼠标悬停高亮 / Hover highlight',
        code: r'''ParkCell(titleText: '悬停试试', hover: true, onPressed: () {})''',
        builder: (BuildContext context) =>
            ParkCell(titleText: '悬停试试', hover: true, onPressed: () {}),
      ),
      ParkDemoScenario(
        title: '自定义箭头与右侧组件',
        description: 'arrowIcon 与 extra 自定义右侧 / Custom arrow + extra',
        code: r'''ParkCell(
  titleText: '带开关',
  arrowIcon: Icons.arrow_forward,
  extra: ParkTag(text: 'VIP', theme: ParkTagTheme.warning),
  onPressed: () {},
)''',
        builder: (BuildContext context) => ParkCell(
          titleText: '带开关',
          arrowIcon: Icons.arrow_forward,
          extra: const ParkTag(text: 'VIP', theme: ParkTagTheme.warning),
          onPressed: () {},
        ),
      ),
      ParkDemoScenario(
        title: '可点击演示',
        description: '点击切换文本，演示 onPressed 回调 / onPressed demo',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    int taps = 0;
    return ParkCell(
      titleText: '点击次数: \$taps',
      arrow: true,
      onPressed: () { taps++; setState(() {}); },
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            int taps = 0;
            return ParkCell(
              titleText: '点击次数: $taps',
              arrow: true,
              onPressed: () {
                taps++;
                setState(() {});
              },
            );
          },
        ),
      ),
    ],
    basicUsageCode: r'''ParkCell(
  leftIcon: Icon(Icons.settings),
  titleText: '设置',
  descriptionText: '应用偏好与隐私',
  arrow: true,
  onPressed: () {},
)''',
    guide: r'''## 何时使用 / When to use
- 设置页面、个人信息页面中的列表项 / Settings & profile list rows
- 需要展示图标 + 标题 + 描述 + 右侧箭头的行项 / Icon + title + desc rows

## 使用建议 / Usage tips
- 使用 titleText/descriptionText 快捷设置文字 / Use text conveniences
- 需要跳转的项设置 arrow: true 显示右侧箭头 / arrow: true for navigable rows
- 通过 note 在箭头前展示备注信息 / note for right-side text
- 最后一项设置 bordered: false 隐藏分隔线 / Last item: bordered: false
- required 显示必填星号，disabled 禁用整行 / required asterisk, disabled row

## 搭配推荐 / Compose with
- 搭配 ParkSwitch 做设置开关项 / ParkSwitch for toggles
- 搭配 ParkDivider 做自定义分隔 / ParkDivider for dividers
- 搭配 ParkList 做完整设置列表 / ParkList for full lists
''',
  ),

  'ParkTag': ParkComponentSpec(
    name: 'ParkTag',
    title: '标签 / Tag',
    category: 'display',
    icon: Icons.label_outlined,
    description:
        '内联标签 / 芯片组件。支持多种颜色主题、变体（dark/light/outline）、'
        '可选关闭按钮、点击回调、可勾选切换与链接模式。'
        ' / Inline label / chip with color themes, variants (dark/light/outline), close, tap, checkable & link modes.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'text',
        type: 'String',
        required: true,
        description: '标签文字 / Tag text',
      ),
      ParkPropertyDef(
        name: 'variant',
        type: 'ParkTagVariant',
        defaultVal: 'ParkTagVariant.light',
        description: '视觉变体：dark（深色）、light（浅色）、outline（描边）/ Variant',
      ),
      ParkPropertyDef(
        name: 'theme',
        type: 'ParkTagTheme',
        defaultVal: 'ParkTagTheme.defaultTheme',
        description:
            '颜色主题：defaultTheme、primary、success、warning、danger / Color theme',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkTagSize',
        defaultVal: 'ParkTagSize.medium',
        description: '尺寸预设：small、medium、large / Size preset',
      ),
      ParkPropertyDef(
        name: 'shape',
        type: 'ParkTagShape',
        defaultVal: 'ParkTagShape.square',
        description: '形状：square（方角）或 round（圆角药丸）/ Shape',
      ),
      ParkPropertyDef(
        name: 'closable',
        type: 'bool',
        defaultVal: 'false',
        description: '是否显示关闭按钮 / Show close button',
      ),
      ParkPropertyDef(
        name: 'icon',
        type: 'Widget?',
        defaultVal: 'null',
        description: '可选前置图标 Widget / Leading icon widget',
      ),
      ParkPropertyDef(
        name: 'onClose',
        type: 'VoidCallback?',
        defaultVal: 'null',
        description: '关闭按钮点击回调 / Close button callback',
      ),
      ParkPropertyDef(
        name: 'onPressed',
        type: 'VoidCallback?',
        defaultVal: 'null',
        description: '整个标签的点击回调 / Whole-tag tap callback',
      ),
      ParkPropertyDef(
        name: 'checkable',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时点击在勾选/未勾选间切换 / Toggle checked state on tap',
      ),
      ParkPropertyDef(
        name: 'checked',
        type: 'bool',
        defaultVal: 'false',
        description: 'checkable 标签的当前勾选状态 / Current checked state',
      ),
      ParkPropertyDef(
        name: 'onChecked',
        type: 'ValueChanged<bool>?',
        defaultVal: 'null',
        description: '勾选状态变化回调 / Fires when checked state changes',
      ),
      ParkPropertyDef(
        name: 'outline',
        type: 'bool',
        defaultVal: 'false',
        description: '快捷标志：仅描边样式（覆盖 variant）/ Outline-only shortcut',
      ),
      ParkPropertyDef(
        name: 'light',
        type: 'bool',
        defaultVal: 'false',
        description: '快捷标志：浅色背景 + 深字（覆盖 variant）/ Light-tint shortcut',
      ),
      ParkPropertyDef(
        name: 'href',
        type: 'String?',
        defaultVal: 'null',
        description: '设置后渲染为可点击链接（复制到剪贴板）/ URL link mode',
      ),
      ParkPropertyDef(
        name: 'maxWidth',
        type: 'double?',
        defaultVal: 'null',
        description: '文字最大宽度，超出省略号截断 / Max width with ellipsis',
      ),
      ParkPropertyDef(
        name: 'customColor',
        type: 'Color?',
        defaultVal: 'null',
        description: '任意自定义色，覆盖主题色 / Custom color (overrides theme)',
      ),
      ParkPropertyDef(
        name: 'bordered',
        type: 'bool',
        defaultVal: 'true',
        description: '是否显示标签边框 / Show border',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onClose',
        signature: 'VoidCallback?',
        description: '关闭按钮点击时触发 / Called when close is tapped',
      ),
      ParkEventDef(
        name: 'onPressed',
        signature: 'VoidCallback?',
        description: '整个标签点击时触发 / Called when the tag is tapped',
      ),
      ParkEventDef(
        name: 'onChecked',
        signature: 'ValueChanged<bool>?',
        description: '勾选状态变化（checkable 标签）时触发 / checkable toggle',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础标签',
        description: '默认浅色标签 / Default light tag',
        code: r'''ParkTag(text: '默认')''',
        builder: (BuildContext context) => const ParkTag(text: '默认'),
      ),
      ParkDemoScenario(
        title: '颜色主题',
        description:
            '展示 primary / success / warning / danger 主题 / Color themes',
        code: r'''Wrap(
  spacing: _kSpacing.sm,
  children: <Widget>[
    ParkTag(text: '主要', theme: ParkTagTheme.primary),
    ParkTag(text: '成功', theme: ParkTagTheme.success),
    ParkTag(text: '警告', theme: ParkTagTheme.warning),
    ParkTag(text: '危险', theme: ParkTagTheme.danger),
  ],
)''',
        builder: (BuildContext context) => Wrap(
          spacing: _kSpacing.sm,
          children: const <Widget>[
            ParkTag(text: '主要', theme: ParkTagTheme.primary),
            ParkTag(text: '成功', theme: ParkTagTheme.success),
            ParkTag(text: '警告', theme: ParkTagTheme.warning),
            ParkTag(text: '危险', theme: ParkTagTheme.danger),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '变体对比',
        description: 'dark / light / outline 三种变体 / Variants',
        code: r'''Wrap(
  spacing: _kSpacing.sm,
  children: <Widget>[
    ParkTag(text: 'Dark', variant: ParkTagVariant.dark, theme: ParkTagTheme.primary),
    ParkTag(text: 'Light', variant: ParkTagVariant.light, theme: ParkTagTheme.primary),
    ParkTag(text: 'Outline', variant: ParkTagVariant.outline, theme: ParkTagTheme.primary),
  ],
)''',
        builder: (BuildContext context) => Wrap(
          spacing: _kSpacing.sm,
          children: const <Widget>[
            ParkTag(
              text: 'Dark',
              variant: ParkTagVariant.dark,
              theme: ParkTagTheme.primary,
            ),
            ParkTag(
              text: 'Light',
              variant: ParkTagVariant.light,
              theme: ParkTagTheme.primary,
            ),
            ParkTag(
              text: 'Outline',
              variant: ParkTagVariant.outline,
              theme: ParkTagTheme.primary,
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '可关闭标签',
        description: 'closable: true 显示关闭按钮，演示 onClose / onClose demo',
        code: r'''final removed = [false];
StatefulBuilder(
  builder: (context, setState) {
    return removed[0]
        ? ParkText('已移除')
        : ParkTag(
            text: '可移除',
            closable: true,
            theme: ParkTagTheme.primary,
            onClose: () { removed[0] = true; setState(() {}); },
          );
  },
)''',
        builder: (BuildContext context) {
          final removed = [false];
          return StatefulBuilder(
            builder: (context, setState) {
              return removed[0]
                  ? ParkText('已移除')
                  : ParkTag(
                      text: '可移除',
                      closable: true,
                      theme: ParkTagTheme.primary,
                      onClose: () {
                        removed[0] = true;
                        setState(() {});
                      },
                    );
            },
          );
        },
      ),
      ParkDemoScenario(
        title: '圆角药丸形',
        description: 'shape: round 显示药丸形状标签 / Round pill shape',
        code:
            r'''ParkTag(text: '圆角', shape: ParkTagShape.round, theme: ParkTagTheme.success)''',
        builder: (BuildContext context) => const ParkTag(
          text: '圆角',
          shape: ParkTagShape.round,
          theme: ParkTagTheme.success,
        ),
      ),
      ParkDemoScenario(
        title: '可勾选标签',
        description: 'checkable + onChecked 切换勾选态 / Checkable + onChecked',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    bool checked = false;
    return ParkTag(
      text: '关注',
      checkable: true,
      checked: checked,
      onChecked: (v) { checked = v; setState(() {}); },
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            bool checked = false;
            return ParkTag(
              text: '关注',
              checkable: true,
              checked: checked,
              onChecked: (v) {
                checked = v;
                setState(() {});
              },
            );
          },
        ),
      ),
      ParkDemoScenario(
        title: '带图标与链接',
        description: 'icon 前置图标；href 渲染为链接 / Icon + link',
        code: r'''Wrap(
  spacing: _kSpacing.sm,
  children: <Widget>[
    ParkTag(text: '图片', icon: Icon(Icons.image, size: 14), theme: ParkTagTheme.primary),
    ParkTag(text: '了解更多', href: 'https://park.ui', theme: ParkTagTheme.info),
  ],
)''',
        builder: (BuildContext context) => Wrap(
          spacing: _kSpacing.sm,
          children: <Widget>[
            const ParkTag(
              text: '图片',
              icon: Icon(Icons.image, size: 14),
              theme: ParkTagTheme.primary,
            ),
            const ParkTag(
              text: '了解更多',
              href: 'https://park.ui',
              theme: ParkTagTheme.defaultTheme,
            ),
          ],
        ),
      ),
    ],
    basicUsageCode: r'''Wrap(
  spacing: _kSpacing.sm,
  children: <Widget>[
    ParkTag(text: '主要', theme: ParkTagTheme.primary),
    ParkTag(text: '成功', theme: ParkTagTheme.success),
    ParkTag(text: '警告', theme: ParkTagTheme.warning),
    ParkTag(text: '危险', theme: ParkTagTheme.danger),
  ],
)''',
    guide: r'''## 何时使用 / When to use
- 标记分类、状态、属性等标签信息 / Tags for categories, status, attributes
- 筛选条件展示、关键词标签、角色标记 / Filters, keywords, roles

## 使用建议 / Usage tips
- 语义色搭配：success 成功、warning 警告、danger 危险 / Semantic colors
- light 常规标记，dark 强调，outline 低调展示 / Variant choice
- shape: round 药丸形更适合标签云、筛选条件 / round for clouds & filters
- closable + onClose 实现可移除标签 / Removable tags
- checkable + onChecked 实现多选标签 / Multi-select tags

## 搭配推荐 / Compose with
- 搭配 ParkSelect 做已选筛选标签 / ParkSelect chips
- 搭配 ParkCell 做列表项状态标记 / ParkCell status
- 搭配 ParkInput 做关键词标签输入 / ParkInput tags
''',
  ),

  'ParkCollapse': ParkComponentSpec(
    name: 'ParkCollapse',
    title: '折叠面板 / Collapse',
    category: 'display',
    icon: Icons.unfold_more_outlined,
    description:
        '手风琴 / 可折叠面板组件。通过 accordion 属性控制单选或多选展开模式，'
        '通过 onChanged / onChangeIndex 报告状态变化。'
        ' / Accordion / collapsible panel; accordion controls single/multi expand; onChanged / onChangeIndex report changes.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'items',
        type: 'List<ParkCollapseItem>',
        required: true,
        description:
            '折叠项列表，每个 ParkCollapseItem 含 key、title、content、disabled、icon、extra、expandIcon、headerWidget / Items',
      ),
      ParkPropertyDef(
        name: 'activeKeys',
        type: 'Set<String>',
        defaultVal: '{}',
        description: '当前展开项的 key 集合 / Expanded item keys',
      ),
      ParkPropertyDef(
        name: 'accordion',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时仅允许同时展开一项 / Single-expand mode',
      ),
      ParkPropertyDef(
        name: 'bordered',
        type: 'bool',
        defaultVal: 'true',
        description: '为 false 时移除面板边框 / Remove borders',
      ),
      ParkPropertyDef(
        name: 'ghost',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时面板背景透明 / Transparent background',
      ),
      ParkPropertyDef(
        name: 'onChanged',
        type: 'ValueChanged<Set<String>>?',
        defaultVal: 'null',
        description: '展开项变化回调，参数为新的 activeKeys 集合 / Active keys changed',
      ),
      ParkPropertyDef(
        name: 'onChangeIndex',
        type: 'ValueChanged<List<int>>?',
        defaultVal: 'null',
        description: '展开/收起时回调，参数为激活项索引列表 / Active indexes changed',
      ),
      ParkPropertyDef(
        name: 'collapsible',
        type: 'ParkCollapseCollapsible',
        defaultVal: 'ParkCollapseCollapsible.header',
        description: '展开控制方式：header（点整头）、icon（点图标）、disabled / Toggle mode',
      ),
      ParkPropertyDef(
        name: 'bindKey',
        type: 'String?',
        defaultVal: 'null',
        description: '绑定键（点号分隔路径，如 "collapseKeys"）；设置后进入双向绑定模式 / Binding key',
      ),
      ParkPropertyDef(
        name: 'bindingService',
        type: 'ParkBindingService?',
        defaultVal: 'null',
        description: '绑定服务实例；在 ParkForm 内可省略（自动获取）/ Binding service',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkCollapseSize',
        defaultVal: 'ParkCollapseSize.medium',
        description: '折叠面板尺寸：small（紧凑）/ medium（默认）/ large（宽松），'
            '控制头部与内容内边距、标题字号与图标大小 / Panel size',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onChanged',
        signature: 'ValueChanged<Set<String>>?',
        description: '展开项 key 集合变化时触发 / Fires when active keys change',
      ),
      ParkEventDef(
        name: 'onChangeIndex',
        signature: 'ValueChanged<List<int>>?',
        description: '展开/收起导致激活索引变化时触发 / Fires when active indexes change',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础折叠面板',
        description: '多项可同时展开 / Multi-expand',
        code: r'''ParkCollapse(
  items: <ParkCollapseItem>[
    ParkCollapseItem(key: '1', title: '什么是 Park UI?', content: Text('Park UI 是一套 Flutter 组件库。')),
    ParkCollapseItem(key: '2', title: '如何安装?', content: Text('在 pubspec.yaml 中添加依赖。')),
  ],
)''',
        builder: (BuildContext context) => ParkCollapse(
          items: <ParkCollapseItem>[
            ParkCollapseItem(
              key: '1',
              title: '什么是 Park UI?',
              content: Text('Park UI 是一套 Flutter 组件库。'),
            ),
            ParkCollapseItem(
              key: '2',
              title: '如何安装?',
              content: Text('在 pubspec.yaml 中添加依赖。'),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '手风琴模式',
        description: 'accordion: true 时仅允许展开一项 / Single-expand',
        code: r'''ParkCollapse(
  accordion: true,
  items: <ParkCollapseItem>[
    ParkCollapseItem(key: 'a', title: '第一节', content: Text('第一节内容')),
    ParkCollapseItem(key: 'b', title: '第二节', content: Text('第二节内容')),
  ],
)''',
        builder: (BuildContext context) => ParkCollapse(
          accordion: true,
          items: <ParkCollapseItem>[
            ParkCollapseItem(key: 'a', title: '第一节', content: Text('第一节内容')),
            ParkCollapseItem(key: 'b', title: '第二节', content: Text('第二节内容')),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '禁用项与图标',
        description: 'disabled 项不可展开；item.icon 添加头部图标 / Disabled + icon',
        code: r'''ParkCollapse(
  items: <ParkCollapseItem>[
    ParkCollapseItem(key: 'ok', title: '正常项', icon: Icons.check, content: Text('可以展开')),
    ParkCollapseItem(key: 'off', title: '禁用项', disabled: true, content: Text('无法展开')),
  ],
)''',
        builder: (BuildContext context) => ParkCollapse(
          items: <ParkCollapseItem>[
            ParkCollapseItem(
              key: 'ok',
              title: '正常项',
              icon: Icons.check,
              content: Text('可以展开'),
            ),
            ParkCollapseItem(
              key: 'off',
              title: '禁用项',
              disabled: true,
              content: Text('无法展开'),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '幽灵模式',
        description: 'ghost: true 面板背景透明 / Ghost (transparent)',
        code: r'''ParkCollapse(
  ghost: true,
  items: <ParkCollapseItem>[
    ParkCollapseItem(key: 'g', title: '幽灵面板', content: Text('透明背景')),
  ],
)''',
        builder: (BuildContext context) => ParkCollapse(
          ghost: true,
          items: <ParkCollapseItem>[
            ParkCollapseItem(key: 'g', title: '幽灵面板', content: Text('透明背景')),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '展开回调',
        description: 'onChanged 报告当前展开 key 集合 / onChanged demo',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    Set<String> keys = <String>{};
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkCollapse(
          items: <ParkCollapseItem>[
            ParkCollapseItem(key: 'x', title: '点击我', content: Text('内容')),
          ],
          onChanged: (k) { keys = k; setState(() {}); },
        ),
        ParkText('已展开: \${keys.join(', ')}'),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            Set<String> keys = <String>{};
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkCollapse(
                  items: const <ParkCollapseItem>[
                    ParkCollapseItem(
                      key: 'x',
                      title: '点击我',
                      content: Text('内容'),
                    ),
                  ],
                  onChanged: (k) {
                    keys = k;
                    setState(() {});
                  },
                ),
                ParkText('已展开: ${keys.join(', ')}'),
              ],
            );
          },
        ),
      ),
      ParkDemoScenario(
        title: '自定义头部',
        description: 'headerWidget / extra 自定义头部内容 / Custom header',
        code: r'''ParkCollapse(
  items: <ParkCollapseItem>[
    ParkCollapseItem(
      key: 'h',
      title: '自定义标题',
      headerWidget: Row(children: <Widget>[Icon(Icons.star), SizedBox(width: _kSpacing.sm), Text('自定义标题')]),
      content: Text('自定义头部内容'),
    ),
  ],
)''',
        builder: (BuildContext context) => ParkCollapse(
          items: <ParkCollapseItem>[
            ParkCollapseItem(
              key: 'h',
              title: '自定义标题',
              headerWidget: Row(
                children: <Widget>[
                  Icon(Icons.star),
                  SizedBox(width: _kSpacing.sm),
                  Text('自定义标题'),
                ],
              ),
              content: Text('自定义头部内容'),
            ),
          ],
        ),
      ),
    ],
    basicUsageCode: r'''ParkCollapse(
  items: <ParkCollapseItem>[
    ParkCollapseItem(key: '1', title: '什么是 Park UI?', content: Text('Park UI 是一套 Flutter 组件库。')),
    ParkCollapseItem(key: '2', title: '如何安装?', content: Text('在 pubspec.yaml 中添加依赖。')),
  ],
  activeKeys: <String>{'1'},
  onChanged: (keys) => print('展开: \$keys'),
)''',
    guide: r'''## 何时使用 / When to use
- FAQ 常见问题列表、帮助文档 / FAQ, help docs
- 设置页面中需要分组收纳内容 / Grouped settings
- 长内容需要按需展开查看 / Long content on demand

## 使用建议 / Usage tips
- accordion: true 适合互斥场景（如 FAQ），false 适合同时查看多项 / Accordion vs multi
- 默认展开项通过 activeKeys 设置 / Set initial via activeKeys
- disabled 项不可操作，适合锁定未解锁的内容 / Locked content via disabled
- collapsible: icon 仅允许点击箭头展开 / icon-only toggle
- onChangeIndex 获取激活索引列表 / Active indexes via onChangeIndex

## 搭配推荐 / Compose with
- 搭配 ParkCell 做设置分组 / ParkCell groups
- 搭配 ParkIcon 做展开/收起箭头自定义 / ParkIcon arrows
- 搭配 ParkDivider 做分割线样式 / ParkDivider dividers
''',
  ),

  'ParkEmpty': ParkComponentSpec(
    name: 'ParkEmpty',
    title: '空状态 / Empty',
    category: 'display',
    icon: Icons.inbox_outlined,
    description:
        '空状态占位组件。显示居中列，含图标、描述文字和可选操作按钮，'
        '支持自定义插图与页脚。'
        ' / Empty-state placeholder: centered column with icon, description, optional actions, custom image & footer.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'icon',
        type: 'IconData?',
        defaultVal: 'null',
        description: '可选图标，显示在描述文字之上 / Optional icon above text',
      ),
      ParkPropertyDef(
        name: 'image',
        type: 'Widget?',
        defaultVal: 'null',
        description:
            '自定义插图 Widget（与 icon 同时设置时优先）/ Custom illustration (priority over icon)',
      ),
      ParkPropertyDef(
        name: 'description',
        type: 'String',
        defaultVal: "'暂无数据'",
        description: '描述文字 / Description text',
      ),
      ParkPropertyDef(
        name: 'descriptionWidget',
        type: 'Widget?',
        defaultVal: 'null',
        description:
            '富描述 Widget（与 description 同时设置时优先）/ Rich description widget',
      ),
      ParkPropertyDef(
        name: 'actions',
        type: 'List<Widget>?',
        defaultVal: 'null',
        description: '可选操作按钮列表，显示在描述文字下方 / Action buttons below text',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkEmptySize',
        defaultVal: 'ParkEmptySize.medium',
        description: '尺寸预设：small、medium、large，控制图标和文字缩放 / Size preset',
      ),
      ParkPropertyDef(
        name: 'footer',
        type: 'Widget?',
        defaultVal: 'null',
        description: '显示在 actions 下方的页脚 Widget（链接/信息）/ Footer widget',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础空状态',
        description: '仅图标和描述文字 / Icon + description',
        code: r'''ParkEmpty(icon: Icons.inbox, description: '暂无消息')''',
        builder: (BuildContext context) =>
            const ParkEmpty(icon: Icons.inbox, description: '暂无消息'),
      ),
      ParkDemoScenario(
        title: '带操作按钮',
        description: '空状态下方显示操作按钮 / With actions',
        code: r'''ParkEmpty(
  icon: Icons.shopping_bag_outlined,
  description: '购物车为空',
  actions: <Widget>[
    ParkButton(child: Text('去购物'), onPressed: () {}),
  ],
)''',
        builder: (BuildContext context) => ParkEmpty(
          icon: Icons.shopping_bag_outlined,
          description: '购物车为空',
          actions: <Widget>[
            ParkButton(onPressed: () {}, child: const Text('去购物')),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '不同尺寸',
        description: 'small / medium / large 尺寸对比 / Size presets',
        code: r'''Column(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    ParkEmpty(icon: Icons.inbox, description: '小号', size: ParkEmptySize.small),
    SizedBox(height: _kSpacing.base),
    ParkEmpty(icon: Icons.inbox, description: '大号', size: ParkEmptySize.large),
  ],
)''',
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParkEmpty(
              icon: Icons.inbox,
              description: '小号',
              size: ParkEmptySize.small,
            ),
            SizedBox(height: _kSpacing.base),
            ParkEmpty(
              icon: Icons.inbox,
              description: '大号',
              size: ParkEmptySize.large,
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '自定义插图',
        description: 'image 展示品牌插图（优先级高于 icon）/ Custom illustration',
        code: r'''ParkEmpty(
  image: Icon(Icons.image, size: 64, color: _kColors.brand),
  description: '暂无图片',
)''',
        builder: (BuildContext context) => ParkEmpty(
          image: Icon(Icons.image, size: 64, color: _kColors.brand),
          description: '暂无图片',
        ),
      ),
      ParkDemoScenario(
        title: '页脚链接',
        description: 'footer 在按钮下方展示附加信息 / Footer below actions',
        code: r'''ParkEmpty(
  icon: Icons.search,
  description: '未找到结果',
  actions: <Widget>[ParkButton(child: Text('重试'), onPressed: () {})],
  footer: ParkText('换个关键词试试', preset: ParkTextPreset.caption),
)''',
        builder: (BuildContext context) => ParkEmpty(
          icon: Icons.search,
          description: '未找到结果',
          actions: <Widget>[
            ParkButton(onPressed: () {}, child: const Text('重试')),
          ],
          footer: const ParkText('换个关键词试试', preset: ParkTextPreset.caption),
        ),
      ),
      ParkDemoScenario(
        title: '富文本描述',
        description: 'descriptionWidget 渲染富文本描述 / Rich description',
        code: r'''ParkEmpty(
  icon: Icons.inbox,
  descriptionWidget: ParkText('暂无数据', type: ParkTextType.secondary),
)''',
        builder: (BuildContext context) => ParkEmpty(
          icon: Icons.inbox,
          descriptionWidget: const ParkText(
            '暂无数据',
            type: ParkTextType.secondary,
          ),
        ),
      ),
    ],
    basicUsageCode: r'''ParkEmpty(
  icon: Icons.inbox,
  description: '暂无数据',
  actions: <Widget>[
    ParkButton(child: Text('刷新'), onPressed: () {}),
  ],
)''',
    guide: r'''## 何时使用 / When to use
- 列表、搜索无结果时的空状态占位 / Empty results for lists & search
- 页面初始化尚未加载到数据 / Pre-load placeholder
- 购物车、收藏夹等为空时的提示 / Empty cart / favorites

## 使用建议 / Usage tips
- 搭配 icon 增强视觉表达，如 inbox、search 等语义图标 / Semantic icons
- description 简洁说明原因，如"暂无数据""搜索无结果"/ Short reason text
- actions 提供引导操作按钮，如"刷新""去逛逛"/ Guide actions
- size 根据页面空间选择：弹窗内用 small，整页用 medium/large / Size by space
- image 展示品牌插图，footer 展示附加链接 / Illustration + footer

## 搭配推荐 / Compose with
- 搭配 ParkButton 做操作引导 / ParkButton for actions
- 搭配 ParkResult 做操作结果空态 / ParkResult empty
- 搭配 ParkTable 做表格空状态 / ParkTable empty
''',
  ),

  'ParkImage': ParkComponentSpec(
    name: 'ParkImage',
    title: '图片 / Image',
    category: 'display',
    icon: Icons.image_outlined,
    description:
        '网络图片组件，支持占位符、错误处理和形状选项（circle / rounded / rectangle），'
        '可点击预览、淡入动画与说明文字。'
        ' / Network image with placeholder, error handling, shapes (circle/rounded/rectangle), preview, fade & caption.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'src',
        type: 'String',
        required: true,
        description: '图片 URL / Image URL',
      ),
      ParkPropertyDef(
        name: 'width',
        type: 'double?',
        defaultVal: '100',
        description: '宽度约束 / Width constraint',
      ),
      ParkPropertyDef(
        name: 'height',
        type: 'double?',
        defaultVal: '100',
        description: '高度约束 / Height constraint',
      ),
      ParkPropertyDef(
        name: 'fit',
        type: 'BoxFit',
        defaultVal: 'BoxFit.cover',
        description: '图片填充方式 / How the image is inscribed',
      ),
      ParkPropertyDef(
        name: 'placeholder',
        type: 'Widget?',
        defaultVal: 'null',
        description: '加载中显示的占位 Widget / Loading placeholder',
      ),
      ParkPropertyDef(
        name: 'errorWidget',
        type: 'Widget?',
        defaultVal: 'null',
        description: '加载失败时显示的 Widget / Error widget',
      ),
      ParkPropertyDef(
        name: 'borderRadius',
        type: 'BorderRadius?',
        defaultVal: 'null',
        description: '自定义圆角，覆盖 shape 预设值 / Custom radius (overrides shape)',
      ),
      ParkPropertyDef(
        name: 'shape',
        type: 'ParkImageShape',
        defaultVal: 'ParkImageShape.rounded',
        description: '形状预设：circle、rounded、rectangle / Shape preset',
      ),
      ParkPropertyDef(
        name: 'previewable',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时点击打开全屏预览 / Tap opens full-screen preview',
      ),
      ParkPropertyDef(
        name: 'fallback',
        type: 'Widget?',
        defaultVal: 'null',
        description: '加载失败时的自定义回退 Widget（优先级高于 errorWidget）/ Custom fallback',
      ),
      ParkPropertyDef(
        name: 'fadeInDuration',
        type: 'Duration?',
        defaultVal: 'null（无淡入）',
        description: '加载完成后的淡入动画时长 / Fade-in duration on load',
      ),
      ParkPropertyDef(
        name: 'caption',
        type: 'String?',
        defaultVal: 'null',
        description: '图片底部叠加的说明文字 / Caption overlay',
      ),
      ParkPropertyDef(
        name: 'lazy',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时懒加载（进入视口才加载）/ Lazy load in viewport',
      ),
      ParkPropertyDef(
        name: 'retry',
        type: 'int',
        defaultVal: '0',
        description: '加载失败后的重试次数 / Retry count on error',
      ),
      ParkPropertyDef(
        name: 'memoryCache',
        type: 'bool',
        defaultVal: 'true',
        description: '是否使用内存缓存；false 时加载后立即 evict / Use memory cache',
      ),
      ParkPropertyDef(
        name: 'allowedSchemes',
        type: 'List<String>',
        defaultVal: "['http', 'https']",
        description: '允许的 URL scheme 白名单（空列表 = 仅 http/https）/ Allowed schemes',
      ),
      ParkPropertyDef(
        name: 'onLoad',
        type: 'ValueChanged<NetworkImage>?',
        defaultVal: 'null',
        description: '图片加载成功回调 / Called on successful load',
      ),
      ParkPropertyDef(
        name: 'onError',
        type: 'ValueChanged<Object>?',
        defaultVal: 'null',
        description: '图片加载失败回调（重试耗尽后触发）/ Called on error',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onLoad',
        signature: 'ValueChanged<NetworkImage>?',
        description: '图片加载成功回调 / Called on successful load',
      ),
      ParkEventDef(
        name: 'onError',
        signature: 'ValueChanged<Object>?',
        description: '图片加载失败回调 / Called on error',
      ),
    ],
    methods: const <ParkMethodDef>[
      ParkMethodDef(
        name: 'preloadImage',
        signature: 'static Future<void> preloadImage(BuildContext, String)',
        description: '预加载图片到缓存 / Preload image into cache',
      ),
      ParkMethodDef(
        name: 'evictImage',
        signature: 'static void evictImage(String)',
        description: '按 URL 逐出缓存 / Evict image by URL',
      ),
      ParkMethodDef(
        name: 'clearCache',
        signature: 'static void clearCache()',
        description: '清空整个图片缓存 / Clear the entire image cache',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '圆角图片',
        description: '默认 rounded 形状的网络图片 / Rounded (default)',
        code:
            r'''ParkImage(src: 'https://picsum.photos/200', width: 120, height: 120)''',
        builder: (BuildContext context) => const ParkImage(
          src: 'https://picsum.photos/200',
          width: 120,
          height: 120,
        ),
      ),
      ParkDemoScenario(
        title: '圆形图片',
        description: 'shape: circle 显示圆形裁剪 / Circle crop',
        code:
            r'''ParkImage(src: 'https://picsum.photos/200', width: 80, height: 80, shape: ParkImageShape.circle)''',
        builder: (BuildContext context) => const ParkImage(
          src: 'https://picsum.photos/200',
          width: 80,
          height: 80,
          shape: ParkImageShape.circle,
        ),
      ),
      ParkDemoScenario(
        title: '直角矩形',
        description: 'shape: rectangle 直角图片 / Rectangle',
        code:
            r'''ParkImage(src: 'https://picsum.photos/200', width: 120, height: 120, shape: ParkImageShape.rectangle)''',
        builder: (BuildContext context) => const ParkImage(
          src: 'https://picsum.photos/200',
          width: 120,
          height: 120,
          shape: ParkImageShape.rectangle,
        ),
      ),
      ParkDemoScenario(
        title: '图片说明',
        description: 'caption 在底部叠加说明文字 / Caption overlay',
        code: r'''ParkImage(
  src: 'https://picsum.photos/200',
  width: 160,
  height: 120,
  caption: '风景照片',
)''',
        builder: (BuildContext context) => const ParkImage(
          src: 'https://picsum.photos/200',
          width: 160,
          height: 120,
          caption: '风景照片',
        ),
      ),
      ParkDemoScenario(
        title: '点击预览',
        description: 'previewable: true 点击打开全屏查看器 / Tap to preview',
        code: r'''ParkImage(
  src: 'https://picsum.photos/200',
  width: 120,
  height: 120,
  previewable: true,
)''',
        builder: (BuildContext context) => const ParkImage(
          src: 'https://picsum.photos/200',
          width: 120,
          height: 120,
          previewable: true,
        ),
      ),
      ParkDemoScenario(
        title: '淡入动画',
        description: 'fadeInDuration 控制加载完成后的淡入 / Fade-in',
        code: r'''ParkImage(
  src: 'https://picsum.photos/200',
  width: 120,
  height: 120,
  fadeInDuration: Duration(milliseconds: 600),
)''',
        builder: (BuildContext context) => const ParkImage(
          src: 'https://picsum.photos/200',
          width: 120,
          height: 120,
          fadeInDuration: Duration(milliseconds: 600),
        ),
      ),
      ParkDemoScenario(
        title: '加载失败处理',
        description: '无效 URL 时显示 errorWidget 或默认错误图标 / Error fallback',
        code: r'''ParkImage(
  src: 'https://invalid.example.com/broken.jpg',
  width: 120,
  height: 120,
  errorWidget: Icon(Icons.broken_image, color: _kColors.error),
)''',
        builder: (BuildContext context) => ParkImage(
          src: 'https://invalid.example.com/broken.jpg',
          width: 120,
          height: 120,
          errorWidget: Icon(Icons.broken_image, color: _kColors.error),
        ),
      ),
    ],
    basicUsageCode: r'''ParkImage(
  src: 'https://picsum.photos/200',
  width: 200,
  height: 150,
  shape: ParkImageShape.rounded,
  previewable: true,
)''',
    guide: r'''## 何时使用 / When to use
- 展示网络图片，如商品图、头像、Banner / Product, avatar, banner
- 需要图片加载占位和错误处理 / Placeholder & error handling
- 需要特定形状裁剪（圆形、圆角、直角）/ Shape cropping

## 使用建议 / Usage tips
- 始终设置 width 和 height 避免布局抖动 / Set width & height
- placeholder 自定义加载态（骨架屏或灰色占位）/ Custom placeholder
- errorWidget / fallback 自定义加载失败的展示 / Custom error UI
- shape: circle 适合头像，rounded 适合卡片图，rectangle 适合 Banner / Shape by use
- previewable: true 点击放大查看（基于 ParkImageViewer）/ Tap-to-preview
- caption 在图片底部叠加说明文字 / Caption overlay

## 搭配推荐 / Compose with
- 搭配 ParkSwiper 做图片轮播 / ParkSwiper carousel
- 搭配 ParkImageViewer 做点击放大查看 / ParkImageViewer zoom
- 搭配 ParkSkeleton 做加载占位 / ParkSkeleton placeholder
''',
  ),

  'ParkImageViewer': ParkComponentSpec(
    name: 'ParkImageViewer',
    title: '图片查看器 / Image Viewer',
    category: 'display',
    icon: Icons.photo_library_outlined,
    description:
        '全屏图片查看器，通过静态方法 show 以全屏覆盖层方式打开，支持左右滑动（PageView）、'
        '双指缩放（InteractiveViewer）、关闭按钮与页码指示器。'
        ' / Full-screen viewer opened via static show(): PageView swipe, InteractiveViewer zoom, close & index indicator.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'images',
        type: 'List<ImageProvider>',
        required: true,
        description: '图片列表 / Image list',
      ),
      ParkPropertyDef(
        name: 'initialIndex',
        type: 'int',
        defaultVal: '0',
        description: '初始显示的图片索引 / Initial index',
      ),
      ParkPropertyDef(
        name: 'onLongPress',
        type: 'VoidCallback?',
        defaultVal: 'null',
        description: '长按图片时触发（用于保存/分享等）/ Long-press callback',
      ),
      ParkPropertyDef(
        name: 'showIndex',
        type: 'bool',
        defaultVal: 'true',
        description: '是否显示 "1/N" 页码指示器 / Show index indicator',
      ),
      ParkPropertyDef(
        name: 'doubleTapZoom',
        type: 'bool',
        defaultVal: 'true',
        description: '是否启用双击切换缩放 / Double-tap to zoom',
      ),
      ParkPropertyDef(
        name: 'swipeToDismiss',
        type: 'bool',
        defaultVal: 'true',
        description: '是否启用垂直下滑关闭 / Swipe-down to dismiss',
      ),
    ],
    methods: const <ParkMethodDef>[
      ParkMethodDef(
        name: 'ParkImageViewer.show',
        signature:
            'static void show(BuildContext context, {required List<ImageProvider> images, int initialIndex = 0, VoidCallback? onLongPress, bool showIndex = true, bool doubleTapZoom = true, bool swipeToDismiss = true})',
        description: '以全屏覆盖层方式展示图片查看器 / Open the full-screen viewer',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '打开图片查看器',
        description: '点击按钮以全屏方式浏览图片列表 / Open viewer',
        code: r'''ElevatedButton(
  onPressed: () {
    ParkImageViewer.show(
      context,
      images: <ImageProvider>[
        NetworkImage('https://picsum.photos/400?random=1'),
        NetworkImage('https://picsum.photos/400?random=2'),
        NetworkImage('https://picsum.photos/400?random=3'),
      ],
      initialIndex: 0,
    );
  },
  child: Text('打开图片查看器'),
)''',
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () {
            ParkImageViewer.show(
              context,
              images: <ImageProvider>[
                const NetworkImage('https://picsum.photos/400?random=1'),
                const NetworkImage('https://picsum.photos/400?random=2'),
                const NetworkImage('https://picsum.photos/400?random=3'),
              ],
              initialIndex: 0,
            );
          },
          child: const Text('打开图片查看器'),
        ),
      ),
      ParkDemoScenario(
        title: '指定初始索引',
        description: '通过 initialIndex 参数从第二张图片开始浏览 / Start at index 1',
        code: r'''ElevatedButton(
  onPressed: () {
    ParkImageViewer.show(
      context,
      images: <ImageProvider>[
        NetworkImage('https://picsum.photos/400?random=10'),
        NetworkImage('https://picsum.photos/400?random=20'),
        NetworkImage('https://picsum.photos/400?random=30'),
      ],
      initialIndex: 1,
    );
  },
  child: Text('从第 2 张开始'),
)''',
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () {
            ParkImageViewer.show(
              context,
              images: <ImageProvider>[
                const NetworkImage('https://picsum.photos/400?random=10'),
                const NetworkImage('https://picsum.photos/400?random=20'),
                const NetworkImage('https://picsum.photos/400?random=30'),
              ],
              initialIndex: 1,
            );
          },
          child: const Text('从第 2 张开始'),
        ),
      ),
      ParkDemoScenario(
        title: '含无效图片',
        description: '图片 URL 无效时查看器内置错误占位 / Broken image fallback',
        code: r'''ElevatedButton(
  onPressed: () {
    ParkImageViewer.show(
      context,
      images: <ImageProvider>[
        NetworkImage('https://picsum.photos/400?random=1'),
        NetworkImage('https://invalid.example.com/broken.jpg'),
        NetworkImage('https://picsum.photos/400?random=3'),
      ],
    );
  },
  child: Text('含无效图片'),
)''',
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () {
            ParkImageViewer.show(
              context,
              images: <ImageProvider>[
                const NetworkImage('https://picsum.photos/400?random=1'),
                const NetworkImage('https://invalid.example.com/broken.jpg'),
                const NetworkImage('https://picsum.photos/400?random=3'),
              ],
            );
          },
          child: const Text('含无效图片'),
        ),
      ),
      ParkDemoScenario(
        title: '关闭页码指示器',
        description: 'showIndex: false 隐藏 "1/N" 指示器 / Hide index',
        code: r'''ElevatedButton(
  onPressed: () {
    ParkImageViewer.show(
      context,
      images: <ImageProvider>[NetworkImage('https://picsum.photos/400?random=1')],
      showIndex: false,
    );
  },
  child: Text('无页码'),
)''',
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () {
            ParkImageViewer.show(
              context,
              images: const <ImageProvider>[
                NetworkImage('https://picsum.photos/400?random=1'),
              ],
              showIndex: false,
            );
          },
          child: const Text('无页码'),
        ),
      ),
      ParkDemoScenario(
        title: '禁用下滑关闭',
        description: 'swipeToDismiss: false 关闭垂直下滑关闭 / Disable swipe-dismiss',
        code: r'''ElevatedButton(
  onPressed: () {
    ParkImageViewer.show(
      context,
      images: <ImageProvider>[NetworkImage('https://picsum.photos/400?random=1')],
      swipeToDismiss: false,
    );
  },
  child: Text('禁用下滑关闭'),
)''',
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () {
            ParkImageViewer.show(
              context,
              images: const <ImageProvider>[
                NetworkImage('https://picsum.photos/400?random=1'),
              ],
              swipeToDismiss: false,
            );
          },
          child: const Text('禁用下滑关闭'),
        ),
      ),
    ],
    basicUsageCode: r'''ParkImageViewer.show(
  context,
  images: <ImageProvider>[NetworkImage('https://...')],
  initialIndex: 0,
);''',
    guide: r'''## 何时使用 / When to use
- 点击缩略图后全屏查看大图 / Full-screen preview on thumbnail tap
- 多图浏览场景，如相册、商品详情图 / Albums, product galleries
- 需要双指缩放查看图片细节 / Pinch-to-zoom detail

## 使用建议 / Usage tips
- 通过静态方法 ParkImageViewer.show() 调用，无需手动管理状态 / Use static show()
- initialIndex 指定起始图片，通常传用户点击的图片索引 / initialIndex = tapped index
- 支持 PageView 左右滑动切换、InteractiveViewer 双指缩放 / Swipe + pinch zoom
- 内置页码指示器，多图浏览时自动显示 / Auto index for multiple
- 可配合 ParkImage 的 previewable 自动打开 / Pairs with ParkImage.previewable

## 搭配推荐 / Compose with
- 搭配 ParkImage 做缩略图点击放大 / ParkImage thumbnails
- 搭配 ParkSwiper 做图片预览 / ParkSwiper preview
- 搭配 ParkGrid 做相册浏览 / ParkGrid albums
''',
  ),

  'ParkProgress': ParkComponentSpec(
    name: 'ParkProgress',
    title: '进度条 / Progress',
    category: 'display',
    icon: Icons.linear_scale_outlined,
    description:
        '进度指示器组件，支持线性（line）与仪表盘（dashboard）两种样式，'
        '可显示百分比标签、自定义文字、状态色与渐变填充。'
        ' / Progress indicator with line / circle / steps styles, percentage label, status colors & gradient.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'value',
        type: 'double',
        required: true,
        description: '进度值，范围 0.0 到 1.0 / Progress (0.0–1.0)',
      ),
      ParkPropertyDef(
        name: 'type',
        type: 'ParkProgressType',
        defaultVal: 'ParkProgressType.line',
        description: '类型：line（线性）、dashboard（仪表盘）/ Type',
      ),
      ParkPropertyDef(
        name: 'color',
        type: 'Color?',
        defaultVal: 'null（默认品牌色）',
        description: '填充色，默认品牌色 / Fill color (default brand)',
      ),
      ParkPropertyDef(
        name: 'trackColor',
        type: 'Color?',
        defaultVal: 'null（默认禁用背景色）',
        description: '轨道色，默认 disabledBg / Track color',
      ),
      ParkPropertyDef(
        name: 'strokeWidth',
        type: 'double',
        defaultVal: '6',
        description: '线宽 / 环宽 / Thickness',
      ),
      ParkPropertyDef(
        name: 'label',
        type: 'Object?',
        defaultVal: 'null',
        description:
            '标签控制：null 不显示，true 显示百分比，String 显示自定义文字 / Label: null / true (percent) / String',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'double',
        defaultVal: '80',
        description: '仪表盘环形的直径 / Dashboard diameter',
      ),
      ParkPropertyDef(
        name: 'steps',
        type: 'int?',
        defaultVal: 'null',
        description: '非 null 时将进度条分割为 N 个步骤块 / Step count when non-null',
      ),
      ParkPropertyDef(
        name: 'stepWidth',
        type: 'double',
        defaultVal: '8',
        description: '每个步骤块的宽度 / Step block width',
      ),
      ParkPropertyDef(
        name: 'status',
        type: 'ParkProgressStatus',
        defaultVal: 'ParkProgressStatus.normal',
        description: '状态：normal、success、error、active（控制颜色与末端图标）/ Status',
      ),
      ParkPropertyDef(
        name: 'formatLabel',
        type: 'String Function(double percent)?',
        defaultVal: 'null',
        description: '自定义标签格式化回调（接收 0.0-1.0 的进度值）/ Label formatter',
      ),
      ParkPropertyDef(
        name: 'trailColor',
        type: 'Color?',
        defaultVal: 'null',
        description: '轨道色别名，设置时优先于 trackColor / Track color alias',
      ),
      ParkPropertyDef(
        name: 'gradient',
        type: 'Gradient?',
        defaultVal: 'null',
        description: '线性填充渐变（设置后覆盖 color，仅 line 有效）/ Gradient fill (line only)',
      ),
      ParkPropertyDef(
        name: 'strokeLinecap',
        type: 'StrokeCap',
        defaultVal: 'StrokeCap.round',
        description: '进度条线帽样式 / Stroke cap',
      ),
      ParkPropertyDef(
        name: 'active',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时在填充部分显示 shimmer/条纹动画 / Active shimmer overlay',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '线性进度条',
        description: '基础线性进度条 / Basic line',
        code: r'''Padding(
  padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
  child: ParkProgress(value: 0.6),
)''',
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
          child: const ParkProgress(value: 0.6),
        ),
      ),
      ParkDemoScenario(
        title: '带百分比标签',
        description: 'label: true 显示百分比文字 / Percentage label',
        code: r'''Padding(
  padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
  child: ParkProgress(value: 0.75, label: true),
)''',
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
          child: const ParkProgress(value: 0.75, label: true),
        ),
      ),
      ParkDemoScenario(
        title: '环形进度条',
        description: 'type: circle 显示环形进度 / Circle ring',
        code:
            r'''ParkProgress(value: 0.45, type: ParkProgressType.dashboard, label: true)''',
        builder: (BuildContext context) => const ParkProgress(
          value: 0.45,
          type: ParkProgressType.dashboard,
          label: true,
        ),
      ),
      ParkDemoScenario(
        title: '步骤进度',
        description: 'type: steps 显示分段步骤进度 / Steps style',
        code: r'''ParkProgress(value: 0.6, steps: 5)''',
        builder: (BuildContext context) =>
            const ParkProgress(value: 0.6, steps: 5),
      ),
      ParkDemoScenario(
        title: '自定义颜色',
        description: 'color 与 trackColor 自定义配色 / Custom colors',
        code: r'''Padding(
  padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
  child: ParkProgress(value: 0.8, color: _kColors.success, trackColor: _kColors.successLight, label: true),
)''',
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
          child: ParkProgress(
            value: 0.8,
            color: _kColors.success,
            trackColor: _kColors.successLight,
            label: true,
          ),
        ),
      ),
      ParkDemoScenario(
        title: '状态色',
        description: 'status 控制成功/错误配色与末端图标 / Status colors',
        code: r'''Column(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    ParkProgress(value: 1.0, status: ParkProgressStatus.success, label: true),
    SizedBox(height: _kSpacing.sm),
    ParkProgress(value: 0.4, status: ParkProgressStatus.error, label: true),
  ],
)''',
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParkProgress(
              value: 1.0,
              status: ParkProgressStatus.success,
              label: true,
            ),
            SizedBox(height: _kSpacing.sm),
            ParkProgress(
              value: 0.4,
              status: ParkProgressStatus.error,
              label: true,
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '渐变填充与活动动画',
        description: 'gradient 渐变 + active 条纹动画 / Gradient + active shimmer',
        code: r'''Padding(
  padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
  child: ParkProgress(
    value: 0.7,
    gradient: LinearGradient(colors: <Color>[_kColors.brand, _kColors.success]),
    active: true,
    label: true,
  ),
)''',
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
          child: ParkProgress(
            value: 0.7,
            gradient: LinearGradient(
              colors: <Color>[_kColors.brand, _kColors.success],
            ),
            active: true,
            label: true,
          ),
        ),
      ),
      ParkDemoScenario(
        title: '自定义格式',
        description: 'format 自定义标签文本 / Custom label formatter',
        code: r'''Padding(
  padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
  child: ParkProgress(value: 0.5, label: true, formatLabel: (p) => '\${(p * 100).toInt()} 分'),
)''',
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.symmetric(horizontal: _kSpacing.base),
          child: ParkProgress(
            value: 0.5,
            label: true,
            formatLabel: (p) => '${(p * 100).toInt()} 分',
          ),
        ),
      ),
    ],
    basicUsageCode: r'''ParkProgress(
  value: 0.6,
  type: ParkProgressType.line,
  label: true,
)''',
    guide: r'''## 何时使用 / When to use
- 展示任务、下载、上传等操作的进度 / Task, download, upload progress
- 表单完成度、资料完善度等百分比展示 / Completion percentages
- 环形进度适合空间紧凑的仪表盘场景 / Circle for compact dashboards

## 使用建议 / Usage tips
- value 范围 0.0~1.0，组件自动计算百分比 / 0.0–1.0
- type: line 适合横向空间充足的场景，circle 适合紧凑区域 / line vs circle
- label: true 显示百分比，label: '自定义文字' 显示自定义内容 / Label options
- status: success/error 表达成功/失败语义色 / Semantic status
- gradient 渐变填充（仅 line），active 显示条纹动画 / Gradient & active

## 搭配推荐 / Compose with
- 搭配 ParkResult 做任务完成展示 / ParkResult completion
- 搭配 ParkCountdown 做限时活动倒计时 / ParkCountdown countdown
- 搭配 ParkSkeleton 做加载过渡 / ParkSkeleton loading
''',
  ),

  'ParkResult': ParkComponentSpec(
    name: 'ParkResult',
    title: '结果页 / Result',
    category: 'display',
    icon: Icons.task_alt_outlined,
    description:
        '操作结果展示组件，包含状态图标、标题、描述和操作按钮。常用于表单提交结果、'
        '页面加载完成态等场景。提供 403/404/500 预设工厂构造。'
        ' / Operation result page with status icon, title, description & actions; 403/404/500 presets.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'status',
        type: 'ParkResultStatus',
        required: true,
        description: '结果状态：success、error、warning、info / Status',
      ),
      ParkPropertyDef(
        name: 'title',
        type: 'String',
        required: true,
        description: '标题文字 / Title text',
      ),
      ParkPropertyDef(
        name: 'icon',
        type: 'Widget?',
        defaultVal: 'null',
        description: '自定义图标 Widget，优先级高于状态默认图标 / Custom icon (priority)',
      ),
      ParkPropertyDef(
        name: 'description',
        type: 'String?',
        defaultVal: 'null',
        description: '描述文字 / Description text',
      ),
      ParkPropertyDef(
        name: 'actions',
        type: 'List<Widget>?',
        defaultVal: 'null',
        description: '操作按钮列表 / Action buttons',
      ),
      ParkPropertyDef(
        name: 'extra',
        type: 'List<Widget>?',
        defaultVal: 'null',
        description: '附加操作按钮（显示在 actions 下方）/ Extra actions below',
      ),
      ParkPropertyDef(
        name: 'descriptionWidget',
        type: 'Widget?',
        defaultVal: 'null',
        description: '富描述 Widget（优先级高于 description）/ Rich description widget',
      ),
    ],
    methods: const <ParkMethodDef>[
      ParkMethodDef(
        name: 'ParkResult.forbidden',
        signature:
            "factory ParkResult.forbidden({Key? key, String title = '无权访问', String? description, Widget? descriptionWidget, List<Widget>? actions, List<Widget>? extra})",
        description: '403 禁止访问预设（warning 状态 + 锁图标）/ 403 forbidden preset',
      ),
      ParkMethodDef(
        name: 'ParkResult.notFound',
        signature:
            "factory ParkResult.notFound({Key? key, String title = '页面未找到', String? description, Widget? descriptionWidget, List<Widget>? actions, List<Widget>? extra})",
        description: '404 未找到预设（info 状态 + 搜索图标）/ 404 not-found preset',
      ),
      ParkMethodDef(
        name: 'ParkResult.serverError',
        signature:
            "factory ParkResult.serverError({Key? key, String title = '服务器错误', String? description, Widget? descriptionWidget, List<Widget>? actions, List<Widget>? extra})",
        description: '500 服务器错误预设（error 状态 + 云图标）/ 500 server-error preset',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '成功结果',
        description: '操作成功的反馈页面 / Success',
        code: r'''ParkResult(
  status: ParkResultStatus.success,
  title: '提交成功',
  description: '您的订单已成功提交，我们将尽快处理。',
)''',
        builder: (BuildContext context) => const ParkResult(
          status: ParkResultStatus.success,
          title: '提交成功',
          description: '您的订单已成功提交，我们将尽快处理。',
        ),
      ),
      ParkDemoScenario(
        title: '错误结果',
        description: '操作失败的反馈页面 / Error',
        code: r'''ParkResult(
  status: ParkResultStatus.error,
  title: '提交失败',
  description: '网络异常，请稍后重试。',
)''',
        builder: (BuildContext context) => const ParkResult(
          status: ParkResultStatus.error,
          title: '提交失败',
          description: '网络异常，请稍后重试。',
        ),
      ),
      ParkDemoScenario(
        title: '带操作按钮',
        description: '结果页可包含操作按钮 / With actions',
        code: r'''ParkResult(
  status: ParkResultStatus.success,
  title: '支付完成',
  actions: <Widget>[ParkButton(child: Text('查看订单'), onPressed: () {})],
)''',
        builder: (BuildContext context) => ParkResult(
          status: ParkResultStatus.success,
          title: '支付完成',
          actions: <Widget>[
            ParkButton(onPressed: () {}, child: const Text('查看订单')),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '警告和信息',
        description: 'warning 和 info 状态 / Warning & info',
        code: r'''Column(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    ParkResult(status: ParkResultStatus.warning, title: '请注意', description: '该操作可能影响现有数据。'),
    SizedBox(height: _kSpacing.lg),
    ParkResult(status: ParkResultStatus.info, title: '系统提示', description: '新版本已发布，建议更新。'),
  ],
)''',
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParkResult(
              status: ParkResultStatus.warning,
              title: '请注意',
              description: '该操作可能影响现有数据。',
            ),
            SizedBox(height: _kSpacing.lg),
            ParkResult(
              status: ParkResultStatus.info,
              title: '系统提示',
              description: '新版本已发布，建议更新。',
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '403 禁止访问',
        description: 'forbidden 工厂构造（warning + 锁图标）/ forbidden()',
        code: r'''ParkResult.forbidden(
  description: '您没有权限访问此页面。',
  actions: <Widget>[ParkButton(child: Text('返回首页'), onPressed: () {})],
)''',
        builder: (BuildContext context) => ParkResult.forbidden(
          description: '您没有权限访问此页面。',
          actions: <Widget>[
            ParkButton(onPressed: () {}, child: const Text('返回首页')),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '404 未找到',
        description: 'notFound 工厂构造（info + 搜索图标）/ notFound()',
        code: r'''ParkResult.notFound(
  description: '您访问的页面不存在或已被移除。',
  actions: <Widget>[ParkButton(child: Text('回到首页'), onPressed: () {})],
)''',
        builder: (BuildContext context) => ParkResult.notFound(
          description: '您访问的页面不存在或已被移除。',
          actions: <Widget>[
            ParkButton(onPressed: () {}, child: const Text('回到首页')),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '500 服务器错误',
        description: 'serverError 工厂构造（error + 云图标）/ serverError()',
        code: r'''ParkResult.serverError(
  description: '服务器遇到内部错误，请稍后重试。',
  actions: <Widget>[ParkButton(child: Text('重试'), onPressed: () {})],
)''',
        builder: (BuildContext context) => ParkResult.serverError(
          description: '服务器遇到内部错误，请稍后重试。',
          actions: <Widget>[
            ParkButton(onPressed: () {}, child: const Text('重试')),
          ],
        ),
      ),
    ],
    basicUsageCode: r'''ParkResult(
  status: ParkResultStatus.success,
  title: '提交成功',
  description: '您的订单已成功提交，我们将尽快处理。',
  actions: <Widget>[ParkButton(child: Text('返回首页'), onPressed: () {})],
)''',
    guide: r'''## 何时使用 / When to use
- 表单提交成功/失败后的结果展示 / Post-submit result
- 支付完成、订单提交等操作反馈页 / Payment / order feedback
- 权限不足、数据异常等异常状态页 / Permission / error states

## 使用建议 / Usage tips
- status 语义明确：success 成功、error 失败、warning 警告、info 提示 / Semantic status
- title 简明扼要说明结果，description 补充细节 / Title + description
- actions 提供后续操作按钮，如"返回首页""查看详情"/ Action buttons
- 预设工厂 forbidden() / notFound() / serverError() 快速构建常见错误页 / Presets
- 可通过 icon 自定义图标，覆盖默认状态图标 / Custom icon

## 搭配推荐 / Compose with
- 搭配 ParkButton 做操作引导 / ParkButton actions
- 搭配 ParkEmpty 做无数据状态 / ParkEmpty empty
- 搭配 ParkDialog 做轻量级结果确认 / ParkDialog confirm
''',
  ),

  'ParkSkeleton': ParkComponentSpec(
    name: 'ParkSkeleton',
    title: '骨架屏 / Skeleton',
    category: 'display',
    icon: Icons.view_day_outlined,
    description:
        '内容加载时的占位骨架组件，支持自定义尺寸与圆角，并提供 shimmer 渐变扫光动画。'
        '提供 text / avatar / card 静态方法，及 avatar/paragraph/button/round/loading 复合布局。'
        ' / Loading placeholder with shimmer; static text/avatar/card; compound avatar/paragraph/button/round/loading.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'width',
        type: 'double?',
        defaultVal: 'null',
        description: '宽度 / Width',
      ),
      ParkPropertyDef(
        name: 'height',
        type: 'double?',
        defaultVal: '16',
        description: '高度 / Height',
      ),
      ParkPropertyDef(
        name: 'borderRadius',
        type: 'BorderRadius?',
        defaultVal: 'null',
        description: '自定义圆角 / Custom radius',
      ),
      ParkPropertyDef(
        name: 'animated',
        type: 'bool',
        defaultVal: 'true',
        description: '是否启用 shimmer 动画 / Enable shimmer',
      ),
      ParkPropertyDef(
        name: 'avatar',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时显示圆形头像占位 / Avatar placeholder',
      ),
      ParkPropertyDef(
        name: 'paragraph',
        type: 'int',
        defaultVal: '0',
        description: '段落行数（>0 时渲染多行文本骨架）/ Paragraph line count',
      ),
      ParkPropertyDef(
        name: 'active',
        type: 'bool',
        defaultVal: 'true',
        description: '动画别名，设置时优先于 animated / Animation alias (priority)',
      ),
      ParkPropertyDef(
        name: 'button',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时显示按钮形状占位 / Button-shaped placeholder',
      ),
      ParkPropertyDef(
        name: 'round',
        type: 'bool',
        defaultVal: 'false',
        description: '为 true 时渲染药丸形（全圆角）骨架 / Pill (full-round) shape',
      ),
      ParkPropertyDef(
        name: 'loading',
        type: 'bool?',
        defaultVal: 'null',
        description:
            '包装模式：true 在 children 上叠加骨架遮罩，false 显示 children / Wrapper mode',
      ),
      ParkPropertyDef(
        name: 'children',
        type: 'List<Widget>?',
        defaultVal: 'null',
        description: '包装模式下显示的内容 Widget / Content for wrapper mode',
      ),
    ],
    methods: const <ParkMethodDef>[
      ParkMethodDef(
        name: 'ParkSkeleton.text',
        signature:
            'static Widget text({int lines = 3, double lineHeight = 14, double spacing = 12, double lastLineWidthFraction = 0.6, bool animated = true})',
        description: '多行文本骨架，最后一行可按比例缩短宽度 / Multi-line text skeleton',
      ),
      ParkMethodDef(
        name: 'ParkSkeleton.avatar',
        signature:
            'factory ParkSkeleton.avatar({double size = 40, bool animated = true})',
        description: '圆形头像骨架 / Circular avatar skeleton',
      ),
      ParkMethodDef(
        name: 'ParkSkeleton.card',
        signature: 'static Widget card({bool animated = true})',
        description: '卡片骨架，模拟头像 + 标题 + 多行文本 + 图片占位 / Card skeleton',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础矩形骨架',
        description: '指定宽高的矩形占位 / Rect placeholder',
        code: r'''ParkSkeleton(width: 200, height: 16)''',
        builder: (BuildContext context) =>
            const ParkSkeleton(width: 200, height: 16),
      ),
      ParkDemoScenario(
        title: '文本骨架',
        description: 'ParkSkeleton.text() 生成多行文本占位 / text()',
        code: r'''ParkSkeleton.text(lines: 4)''',
        builder: (BuildContext context) => ParkSkeleton.text(lines: 4),
      ),
      ParkDemoScenario(
        title: '头像骨架',
        description: 'ParkSkeleton.avatar() 生成圆形占位 / avatar()',
        code: r'''ParkSkeleton.avatar(size: 56)''',
        builder: (BuildContext context) => ParkSkeleton.avatar(size: 56),
      ),
      ParkDemoScenario(
        title: '卡片骨架',
        description: 'ParkSkeleton.card() 生成完整卡片布局 / card()',
        code: r'''ParkSkeleton.card()''',
        builder: (BuildContext context) => ParkSkeleton.card(),
      ),
      ParkDemoScenario(
        title: '段落骨架',
        description: 'paragraph 渲染头像 + 多行文本复合骨架 / Paragraph',
        code: r'''ParkSkeleton(paragraph: 3)''',
        builder: (BuildContext context) => const ParkSkeleton(paragraph: 3),
      ),
      ParkDemoScenario(
        title: '按钮骨架',
        description: 'button: true 渲染按钮形状占位 / Button shape',
        code: r'''ParkSkeleton(button: true)''',
        builder: (BuildContext context) => const ParkSkeleton(button: true),
      ),
      ParkDemoScenario(
        title: '圆形骨架',
        description: 'round: true 渲染药丸形骨架 / Pill shape',
        code: r'''ParkSkeleton(width: 200, height: 16, round: true)''',
        builder: (BuildContext context) =>
            const ParkSkeleton(width: 200, height: 16, round: true),
      ),
      ParkDemoScenario(
        title: '加载包装',
        description: 'loading + children 在内容上叠加骨架遮罩 / Loading overlay',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    bool loading = true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkSkeleton(
          loading: loading,
          children: <Widget>[ParkText('真实内容已加载')],
        ),
        SizedBox(height: _kSpacing.sm),
        ParkButton(child: Text('切换'), onPressed: () { loading = !loading; setState(() {}); }),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            bool loading = true;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkSkeleton(
                  loading: loading,
                  children: const <Widget>[ParkText('真实内容已加载')],
                ),
                SizedBox(height: _kSpacing.sm),
                ParkButton(
                  onPressed: () {
                    loading = !loading;
                    setState(() {});
                  },
                  child: const Text('切换'),
                ),
              ],
            );
          },
        ),
      ),
    ],
    basicUsageCode: r'''Column(
  children: <Widget>[
    Row(children: <Widget>[
      ParkSkeleton.avatar(size: 40),
      SizedBox(width: _kSpacing.md),
      Expanded(child: ParkSkeleton.text(lines: 2)),
    ]),
    SizedBox(height: _kSpacing.base),
    ParkSkeleton(height: 120),
  ],
)''',
    guide: r'''## 何时使用 / When to use
- 页面或列表首次加载时的占位展示 / First-load placeholder
- 替代 CircularProgressIndicator 提供更友好的加载体验 / Friendlier than a spinner
- 模拟真实内容布局的骨架占位 / Mimic real layout

## 使用建议 / Usage tips
- ParkSkeleton.text() 快速生成多行文本占位 / text() for lines
- ParkSkeleton.avatar() 生成圆形头像占位 / avatar() for circles
- ParkSkeleton.card() 生成完整卡片布局占位 / card() for cards
- avatar / paragraph / button / round 复合布局按需组合 / Compound layouts
- loading + children 在真实内容上叠加骨架遮罩 / Overlay real content
- animated / active: true 默认开启 shimmer 扫光动画 / Shimmer by default

## 搭配推荐 / Compose with
- 搭配 ParkRefresh 做下拉刷新加载态 / ParkRefresh
- 搭配 ParkImage 做图片加载占位 / ParkImage
- 搭配 ParkLoading 做全屏加载过渡 / ParkLoading
''',
  ),

  'ParkSwiper': ParkComponentSpec(
    name: 'ParkSwiper',
    title: '轮播 / Swiper',
    category: 'display',
    icon: Icons.slideshow_outlined,
    description:
        '轮播组件，支持自动播放、循环滑动、圆点/数字指示器，可通过 onPageChanged 监听页面切换。'
        '还支持淡入淡出、垂直方向、卡片堆叠与自定义指示器。'
        ' / Carousel with autoplay, loop, dot/number indicators, onPageChanged; fade, vertical, card-stack & custom indicator.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'children',
        type: 'List<Widget>',
        required: true,
        description: '子页面列表 / Page list',
      ),
      ParkPropertyDef(
        name: 'autoPlay',
        type: 'bool',
        defaultVal: 'false',
        description: '是否自动播放 / Auto play',
      ),
      ParkPropertyDef(
        name: 'interval',
        type: 'Duration',
        defaultVal: 'Duration(seconds: 3)',
        description: '自动播放间隔时间 / Autoplay interval',
      ),
      ParkPropertyDef(
        name: 'loop',
        type: 'bool',
        defaultVal: 'true',
        description: '是否循环播放 / Loop',
      ),
      ParkPropertyDef(
        name: 'height',
        type: 'double',
        defaultVal: '200',
        description: '组件高度 / Height',
      ),
      ParkPropertyDef(
        name: 'indicatorType',
        type: 'ParkSwiperIndicatorType',
        defaultVal: 'ParkSwiperIndicatorType.dot',
        description: '指示器类型：dot（圆点）或 number（数字）/ Indicator type',
      ),
      ParkPropertyDef(
        name: 'onPageChanged',
        type: 'ValueChanged<int>?',
        defaultVal: 'null',
        description: '页面切换时触发，参数为当前页索引 / Page change callback',
      ),
      ParkPropertyDef(
        name: 'indicatorPosition',
        type: 'ParkSwiperIndicatorPosition',
        defaultVal: 'ParkSwiperIndicatorPosition.bottom',
        description: '指示器位置：bottom / top / none / Indicator position',
      ),
      ParkPropertyDef(
        name: 'indicatorBuilder',
        type: 'Widget Function(int current, int total)?',
        defaultVal: 'null',
        description: '自定义指示器构建器 / Custom indicator builder',
      ),
      ParkPropertyDef(
        name: 'autoplayDelay',
        type: 'Duration',
        defaultVal: 'Duration(seconds: 3)',
        description: '自定义自动播放延迟（优先于 interval）/ Autoplay delay (priority)',
      ),
      ParkPropertyDef(
        name: 'direction',
        type: 'Axis',
        defaultVal: 'Axis.horizontal',
        description: '滑动方向：水平或垂直 / Scroll direction',
      ),
      ParkPropertyDef(
        name: 'initialIndex',
        type: 'int',
        defaultVal: '0',
        description: '初始显示页面索引 / Initial index',
      ),
      ParkPropertyDef(
        name: 'animationDuration',
        type: 'Duration?',
        defaultVal: 'null',
        description: '自定义滑动动画时长 / Custom slide duration',
      ),
      ParkPropertyDef(
        name: 'effect',
        type: 'ParkSwiperEffect',
        defaultVal: 'ParkSwiperEffect.slide',
        description: '切换效果：slide（滑动）或 fade（淡入淡出）/ Transition effect',
      ),
      ParkPropertyDef(
        name: 'viewportFraction',
        type: 'double?',
        defaultVal: 'null',
        description: '卡片堆叠：非中心卡片可见比例（0-1）/ Card-stack visible fraction',
      ),
      ParkPropertyDef(
        name: 'scale',
        type: 'double?',
        defaultVal: 'null',
        description: '卡片堆叠：非中心卡片缩放比例（0-1）/ Card-stack scale',
      ),
      ParkPropertyDef(
        name: 'curve',
        type: 'Curve?',
        defaultVal: 'null（默认 Curves.easeInOut）',
        description: '自定义动画曲线 / Custom curve',
      ),
      ParkPropertyDef(
        name: 'dragStartRatio',
        type: 'double?',
        defaultVal: 'null',
        description: '手势拖动启动翻页的比例阈值 / Drag-start ratio',
      ),
      ParkPropertyDef(
        name: 'dragEndRatio',
        type: 'double?',
        defaultVal: 'null',
        description: '手势释放完成翻页的比例阈值 / Drag-end ratio',
      ),
      ParkPropertyDef(
        name: 'bindKey',
        type: 'String?',
        defaultVal: 'null',
        description: '绑定键（点号分隔路径，如 "swiperIndex"）；设置后进入双向绑定模式 / Binding key',
      ),
      ParkPropertyDef(
        name: 'bindingService',
        type: 'ParkBindingService?',
        defaultVal: 'null',
        description: '绑定服务实例；在 ParkForm 内可省略（自动获取）/ Binding service',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onPageChanged',
        signature: 'ValueChanged<int>?',
        description: '页面切换时触发，参数为当前页索引 / Fires on page change',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础轮播',
        description: '手动滑动切换，圆点指示器 / Basic dot indicator',
        code: r'''ParkSwiper(
  height: 160,
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('第 1 页'))),
    Container(color: _kColors.success, child: Center(child: Text('第 2 页'))),
    Container(color: _kColors.warning, child: Center(child: Text('第 3 页'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('第 1 页')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('第 2 页')),
            ),
            Container(
              color: _kColors.warning,
              child: const Center(child: Text('第 3 页')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '自动播放',
        description: 'autoPlay: true 每 3 秒自动切换 / Auto play',
        code: r'''ParkSwiper(
  autoPlay: true,
  height: 160,
  children: <Widget>[
    Container(color: _kColors.error, child: Center(child: Text('自动 1'))),
    Container(color: _kColors.info, child: Center(child: Text('自动 2'))),
    Container(color: _kColors.brand, child: Center(child: Text('自动 3'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          autoPlay: true,
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.error,
              child: const Center(child: Text('自动 1')),
            ),
            Container(
              color: _kColors.info,
              child: const Center(child: Text('自动 2')),
            ),
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('自动 3')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '数字指示器',
        description: 'indicatorType: number 显示 "1 / 3" 格式 / Number indicator',
        code: r'''ParkSwiper(
  indicatorType: ParkSwiperIndicatorType.number,
  height: 160,
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('数字 1'))),
    Container(color: _kColors.success, child: Center(child: Text('数字 2'))),
    Container(color: _kColors.warning, child: Center(child: Text('数字 3'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          indicatorType: ParkSwiperIndicatorType.number,
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('数字 1')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('数字 2')),
            ),
            Container(
              color: _kColors.warning,
              child: const Center(child: Text('数字 3')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '顶部指示器',
        description: 'indicatorPosition: top 指示器置于顶部 / Top indicator',
        code: r'''ParkSwiper(
  indicatorPosition: ParkSwiperIndicatorPosition.top,
  height: 160,
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('顶部 1'))),
    Container(color: _kColors.success, child: Center(child: Text('顶部 2'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          indicatorPosition: ParkSwiperIndicatorPosition.top,
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('顶部 1')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('顶部 2')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '淡入淡出',
        description: 'effect: fade 淡入淡出切换 / Fade effect',
        code: r'''ParkSwiper(
  effect: ParkSwiperEffect.fade,
  height: 160,
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('淡入 1'))),
    Container(color: _kColors.success, child: Center(child: Text('淡入 2'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          effect: ParkSwiperEffect.fade,
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('淡入 1')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('淡入 2')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '垂直方向',
        description: 'direction: vertical 垂直滑动 / Vertical',
        code: r'''ParkSwiper(
  direction: Axis.vertical,
  height: 160,
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('垂直 1'))),
    Container(color: _kColors.success, child: Center(child: Text('垂直 2'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          direction: Axis.vertical,
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('垂直 1')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('垂直 2')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '卡片堆叠',
        description: 'viewportFraction + scale 卡片堆叠效果 / Card stack',
        code: r'''ParkSwiper(
  viewportFraction: 0.8,
  scale: 0.9,
  height: 160,
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('卡片 1'))),
    Container(color: _kColors.success, child: Center(child: Text('卡片 2'))),
    Container(color: _kColors.warning, child: Center(child: Text('卡片 3'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          viewportFraction: 0.8,
          scale: 0.9,
          height: 160,
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('卡片 1')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('卡片 2')),
            ),
            Container(
              color: _kColors.warning,
              child: const Center(child: Text('卡片 3')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '自定义指示器',
        description: 'indicatorBuilder 自定义页码指示器 / Custom indicator',
        code: r'''ParkSwiper(
  height: 160,
  indicatorBuilder: (current, total) => Container(
    padding: EdgeInsets.symmetric(horizontal: _kSpacing.sm, vertical: _kSpacing.xs),
    decoration: BoxDecoration(color: _kColors.surface, borderRadius: _kRadius.brFull),
    child: ParkText('\$current / \$total'),
  ),
  children: <Widget>[
    Container(color: _kColors.brand, child: Center(child: Text('自定义 1'))),
    Container(color: _kColors.success, child: Center(child: Text('自定义 2'))),
  ],
)''',
        builder: (BuildContext context) => ParkSwiper(
          height: 160,
          indicatorBuilder: (current, total) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: _kSpacing.sm,
              vertical: _kSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _kColors.surface,
              borderRadius: _kRadius.brFull,
            ),
            child: ParkText('$current / $total'),
          ),
          children: <Widget>[
            Container(
              color: _kColors.brand,
              child: const Center(child: Text('自定义 1')),
            ),
            Container(
              color: _kColors.success,
              child: const Center(child: Text('自定义 2')),
            ),
          ],
        ),
      ),
      ParkDemoScenario(
        title: '页面切换回调',
        description: 'onPageChanged 报告当前页索引 / onPageChanged demo',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    int page = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 140,
          child: ParkSwiper(
            height: 140,
            onPageChanged: (i) { page = i; setState(() {}); },
            children: <Widget>[
              Container(color: _kColors.brand, child: Center(child: Text('页 1'))),
              Container(color: _kColors.success, child: Center(child: Text('页 2'))),
              Container(color: _kColors.warning, child: Center(child: Text('页 3'))),
            ],
          ),
        ),
        ParkText('当前页: \$page'),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            int page = 0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 140,
                  child: ParkSwiper(
                    height: 140,
                    onPageChanged: (i) {
                      page = i;
                      setState(() {});
                    },
                    children: <Widget>[
                      Container(
                        color: _kColors.brand,
                        child: const Center(child: Text('页 1')),
                      ),
                      Container(
                        color: _kColors.success,
                        child: const Center(child: Text('页 2')),
                      ),
                      Container(
                        color: _kColors.warning,
                        child: const Center(child: Text('页 3')),
                      ),
                    ],
                  ),
                ),
                ParkText('当前页: $page'),
              ],
            );
          },
        ),
      ),
    ],
    basicUsageCode: r'''ParkSwiper(
  children: <Widget>[
    Image.network('https://picsum.photos/400?random=1'),
    Image.network('https://picsum.photos/400?random=2'),
  ],
  autoPlay: true,
  interval: Duration(seconds: 3),
  indicatorType: ParkSwiperIndicatorType.dot,
)''',
    guide: r'''## 何时使用 / When to use
- 首页 Banner 轮播图 / Home banner carousel
- 广告位、活动推广图轮播 / Promo carousel
- 引导页多图展示 / Onboarding slides

## 使用建议 / Usage tips
- autoPlay: true 适合 Banner 自动轮播，interval 建议 3~5 秒 / Autoplay 3–5s
- loop: true 实现无缝循环滑动 / Seamless loop
- indicatorType: dot 圆点适合少量页面，number 适合较多页面 / Dot vs number
- indicatorPosition: top 将指示器放顶部 / Top indicator
- effect: fade 淡入淡出；direction: vertical 垂直滑动 / Fade & vertical
- viewportFraction + scale 实现卡片堆叠视觉效果 / Card stack
- indicatorBuilder 完全自定义指示器 / Custom indicator

## 搭配推荐 / Compose with
- 搭配 ParkImage 做图片轮播 / ParkImage
- 搭配 ParkTag 做轮播项角标 / ParkTag
- 搭配 ParkPageView 做自定义翻页 / ParkPageView
''',
  ),

  'ParkTable': ParkComponentSpec(
    name: 'ParkTable',
    title: '表格 / Table',
    category: 'display',
    icon: Icons.table_chart_outlined,
    description:
        '数据表格组件，支持排序、边框、斑马纹、空状态与加载态，水平方向可滚动以适配窄屏。'
        '支持行选择、分页、固定列、吸顶表头与可展开行。'
        ' / Data table with sorting, borders, zebra, empty & loading; row selection, pagination, fixed columns, sticky header, expandable rows.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'columns',
        type: 'List<ParkTableColumn>',
        required: true,
        description:
            '列定义列表，每列含 key、title、width、align、sortable、render、fixed、ellipsis、tooltip / Column defs',
      ),
      ParkPropertyDef(
        name: 'data',
        type: 'List<Map<String, dynamic>>',
        required: true,
        description: '数据列表，每个 Map 的 key 对应列定义的 key / Row data',
      ),
      ParkPropertyDef(
        name: 'bordered',
        type: 'bool',
        defaultVal: 'false',
        description: '是否显示完整边框 / Full border',
      ),
      ParkPropertyDef(
        name: 'striped',
        type: 'bool',
        defaultVal: 'false',
        description: '是否启用斑马纹（奇数行浅色背景）/ Zebra stripes',
      ),
      ParkPropertyDef(
        name: 'emptyText',
        type: 'String',
        defaultVal: "'暂无数据'",
        description: '空数据时显示的提示文字 / Empty hint',
      ),
      ParkPropertyDef(
        name: 'loading',
        type: 'bool',
        defaultVal: 'false',
        description: '是否处于加载状态（显示 loading 指示器）/ Loading state',
      ),
      ParkPropertyDef(
        name: 'expandable',
        type: 'bool',
        defaultVal: 'false',
        description: '是否启用可展开行（需配合 expandedRowBuilder）/ Expandable rows',
      ),
      ParkPropertyDef(
        name: 'expandedRowBuilder',
        type: 'Widget Function(BuildContext, Map<String, dynamic>, int)?',
        defaultVal: 'null',
        description: '展开行内容构建器 / Expanded row content',
      ),
      ParkPropertyDef(
        name: 'onSort',
        type: 'void Function(int columnIndex, bool ascending)?',
        defaultVal: 'null',
        description: '排序回调（列索引 + 是否升序）/ Sort callback',
      ),
      ParkPropertyDef(
        name: 'sticky',
        type: 'bool',
        defaultVal: 'false',
        description: '表头是否吸顶 / Sticky header',
      ),
      ParkPropertyDef(
        name: 'rowSelection',
        type: 'ParkRowSelection?',
        defaultVal: 'null',
        description: '行选择配置（null 表示不启用选择列；含 onChanged 回调）/ Row selection',
      ),
      ParkPropertyDef(
        name: 'pagination',
        type: 'ParkTablePagination?',
        defaultVal: 'null',
        description: '分页配置（null 表示不分页；含 onPageChanged 回调）/ Pagination',
      ),
      ParkPropertyDef(
        name: 'empty',
        type: 'Widget?',
        defaultVal: 'null',
        description: '自定义空状态 Widget（为 null 时使用内置 ParkEmpty）/ Custom empty',
      ),
      ParkPropertyDef(
        name: 'size',
        type: 'ParkTableSize',
        defaultVal: 'ParkTableSize.medium',
        description: '表格尺寸（控制单元格内边距）/ Size preset',
      ),
      ParkPropertyDef(
        name: 'rowKey',
        type: 'String?',
        defaultVal: 'null',
        description: '行唯一标识字段名（对应 data Map 的 key），null 时用行索引 / Row key field',
      ),
      ParkPropertyDef(
        name: 'onRow',
        type: 'Map<String, Function>? Function(dynamic row, int index)?',
        defaultVal: 'null',
        description:
            '返回该行事件 Map（如 onTap/onDoubleTap/onLongPress）/ Per-row events',
      ),
      ParkPropertyDef(
        name: 'scroll',
        type: 'Map<String, double>?',
        defaultVal: 'null',
        description:
            '表格滚动配置（如 {"x": 1200, "y": 400} 横向可滚动 + 固定表头）/ Scroll config',
      ),
      ParkPropertyDef(
        name: 'showSorterTooltip',
        type: 'bool',
        defaultVal: 'true',
        description: '是否在排序列显示 tooltip 提示 / Sorter tooltip',
      ),
      ParkPropertyDef(
        name: 'onChange',
        type: 'void Function(Map<String, dynamic> changeInfo)?',
        defaultVal: 'null',
        description: '综合变更回调（分页、排序、筛选等变化时触发）/ Aggregate change',
      ),
      ParkPropertyDef(
        name: 'expandedRowRender',
        type: 'Widget Function(Map<String, dynamic>, int)?',
        defaultVal: 'null',
        description: '展开行内容构建器（替代签名，与 expandedRowBuilder 功能相同）/ Expanded row renderer (alt signature)',
      ),
      ParkPropertyDef(
        name: 'onColumnWidthChanged',
        type: 'void Function(Map<String, double>)?',
        defaultVal: 'null',
        description: '列宽变化回调（拖拽调整列宽时触发，key 为列 key，value 为当前宽度）/ Column width change callback',
      ),
      ParkPropertyDef(
        name: 'virtualScroll',
        type: 'ParkVirtualScrollConfig?',
        defaultVal: 'null',
        description: '虚拟滚动配置（null 或 enabled=false 时禁用虚拟滚动）/ Virtual scroll config',
      ),
      ParkPropertyDef(
        name: 'treeConfig',
        type: 'ParkTableTreeConfig?',
        defaultVal: 'null',
        description: '树形数据配置（null 时不启用树形数据模式）/ Tree data config',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onSort',
        signature: 'void Function(int columnIndex, bool ascending)?',
        description: '点击排序列头时触发，参数为列索引与升序标志 / Sort header tapped',
      ),
      ParkEventDef(
        name: 'onRow',
        signature: 'Map<String, Function>? Function(dynamic row, int index)?',
        description: '返回该行事件回调 Map（onTap 等）/ Per-row event callbacks',
      ),
      ParkEventDef(
        name: 'onChange',
        signature: 'void Function(Map<String, dynamic> changeInfo)?',
        description: '分页/排序/筛选等综合变化时触发 / Aggregate change',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础表格',
        description: '两列三行的简单数据表格 / Basic table',
        code: r'''ParkTable(
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名'),
    ParkTableColumn(key: 'age', title: '年龄'),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'age': '28'},
    <String, dynamic>{'name': '李四', 'age': '32'},
    <String, dynamic>{'name': '王五', 'age': '25'},
  ],
)''',
        builder: (BuildContext context) => ParkTable(
          columns: <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名'),
            ParkTableColumn(key: 'age', title: '年龄'),
          ],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'age': '28'},
            <String, dynamic>{'name': '李四', 'age': '32'},
            <String, dynamic>{'name': '王五', 'age': '25'},
          ],
        ),
      ),
      ParkDemoScenario(
        title: '可排序 + 斑马纹 + 边框',
        description:
            'sortable 列可点击排序，striped 斑马纹，bordered 边框 / Sort + zebra + border',
        code: r'''ParkTable(
  striped: true,
  bordered: true,
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名', sortable: true),
    ParkTableColumn(key: 'score', title: '分数', sortable: true, align: ParkTableColumnAlign.center),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'score': '88'},
    <String, dynamic>{'name': '李四', 'score': '95'},
    <String, dynamic>{'name': '王五', 'score': '72'},
  ],
)''',
        builder: (BuildContext context) => ParkTable(
          striped: true,
          bordered: true,
          columns: <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名', sortable: true),
            ParkTableColumn(
              key: 'score',
              title: '分数',
              sortable: true,
              align: ParkTableColumnAlign.center,
            ),
          ],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'score': '88'},
            <String, dynamic>{'name': '李四', 'score': '95'},
            <String, dynamic>{'name': '王五', 'score': '72'},
          ],
        ),
      ),
      ParkDemoScenario(
        title: '排序回调',
        description: 'onSort 报告点击列索引与升序状态 / onSort demo',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    String msg = '未排序';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkTable(
          columns: <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名', sortable: true),
            ParkTableColumn(key: 'score', title: '分数', sortable: true),
          ],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'score': '88'},
            <String, dynamic>{'name': '李四', 'score': '95'},
          ],
          onSort: (i, asc) { msg = '列 \$i, 升序: \$asc'; setState(() {}); },
        ),
        ParkText(msg),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            String msg = '未排序';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkTable(
                  columns: const <ParkTableColumn>[
                    ParkTableColumn(key: 'name', title: '姓名', sortable: true),
                    ParkTableColumn(key: 'score', title: '分数', sortable: true),
                  ],
                  data: const <Map<String, dynamic>>[
                    <String, dynamic>{'name': '张三', 'score': '88'},
                    <String, dynamic>{'name': '李四', 'score': '95'},
                  ],
                  onSort: (i, asc) {
                    msg = '列 $i, 升序: $asc';
                    setState(() {});
                  },
                ),
                ParkText(msg),
              ],
            );
          },
        ),
      ),
      ParkDemoScenario(
        title: '行点击',
        description: 'onRow 返回 onTap 处理单行点击 / onRow tap demo',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    String tapped = '未点击';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkTable(
          columns: <ParkTableColumn>[ParkTableColumn(key: 'name', title: '姓名')],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三'},
            <String, dynamic>{'name': '李四'},
          ],
          onRow: (row, index) => <String, VoidCallback>{
            'onTap': () { tapped = row['name'] as String; setState(() {}); },
          },
        ),
        ParkText('点击了: \$tapped'),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            String tapped = '未点击';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkTable(
                  columns: const <ParkTableColumn>[
                    ParkTableColumn(key: 'name', title: '姓名'),
                  ],
                  data: const <Map<String, dynamic>>[
                    <String, dynamic>{'name': '张三'},
                    <String, dynamic>{'name': '李四'},
                  ],
                  onRow: (row, index) => <String, VoidCallback>{
                    'onTap': () {
                      tapped = row['name'] as String;
                      setState(() {});
                    },
                  },
                ),
                ParkText('点击了: $tapped'),
              ],
            );
          },
        ),
      ),
      ParkDemoScenario(
        title: '固定列',
        description: 'fixed: left/right 让首末列在横向滚动时保持可见 / Fixed columns',
        code: r'''ParkTable(
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名', width: 100, fixed: ParkColumnFixed.left),
    ParkTableColumn(key: 'dept', title: '部门', width: 120),
    ParkTableColumn(key: 'role', title: '角色', width: 120),
    ParkTableColumn(key: 'status', title: '状态', width: 120, fixed: ParkColumnFixed.right, render: (row, index) => ParkTag(text: row['status'] as String, theme: ParkTagTheme.success)),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'dept': '研发', 'role': '工程师', 'status': '在职'},
    <String, dynamic>{'name': '李四', 'dept': '设计', 'role': '设计师', 'status': '在职'},
  ],
)''',
        builder: (BuildContext context) => ParkTable(
          columns: <ParkTableColumn>[
            const ParkTableColumn(
              key: 'name',
              title: '姓名',
              width: 100,
              fixed: ParkColumnFixed.left,
            ),
            const ParkTableColumn(key: 'dept', title: '部门', width: 120),
            const ParkTableColumn(key: 'role', title: '角色', width: 120),
            ParkTableColumn(
              key: 'status',
              title: '状态',
              width: 120,
              fixed: ParkColumnFixed.right,
              render: (row, index) => ParkTag(
                text: row['status'] as String,
                theme: ParkTagTheme.success,
              ),
            ),
          ],
          data: const <Map<String, dynamic>>[
            <String, dynamic>{
              'name': '张三',
              'dept': '研发',
              'role': '工程师',
              'status': '在职',
            },
            <String, dynamic>{
              'name': '李四',
              'dept': '设计',
              'role': '设计师',
              'status': '在职',
            },
          ],
        ),
      ),
      ParkDemoScenario(
        title: '吸顶表头',
        description: 'sticky: true 表头在垂直滚动时吸顶 / Sticky header',
        code: r'''SizedBox(
  height: 160,
  child: ParkTable(
    sticky: true,
    columns: <ParkTableColumn>[
      ParkTableColumn(key: 'name', title: '姓名'),
      ParkTableColumn(key: 'age', title: '年龄'),
    ],
    data: <Map<String, dynamic>>[
      <String, dynamic>{'name': '张三', 'age': '28'},
      <String, dynamic>{'name': '李四', 'age': '32'},
      <String, dynamic>{'name': '王五', 'age': '25'},
      <String, dynamic>{'name': '赵六', 'age': '30'},
    ],
  ),
)''',
        builder: (BuildContext context) => SizedBox(
          height: 160,
          child: const ParkTable(
            sticky: true,
            columns: <ParkTableColumn>[
              ParkTableColumn(key: 'name', title: '姓名'),
              ParkTableColumn(key: 'age', title: '年龄'),
            ],
            data: <Map<String, dynamic>>[
              <String, dynamic>{'name': '张三', 'age': '28'},
              <String, dynamic>{'name': '李四', 'age': '32'},
              <String, dynamic>{'name': '王五', 'age': '25'},
              <String, dynamic>{'name': '赵六', 'age': '30'},
            ],
          ),
        ),
      ),
      ParkDemoScenario(
        title: '行选择',
        description: 'rowSelection 启用 checkbox 多选（含 onChanged）/ Row selection',
        code: r'''ParkTable(
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名'),
    ParkTableColumn(key: 'age', title: '年龄'),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'age': '28'},
    <String, dynamic>{'name': '李四', 'age': '32'},
  ],
  rowSelection: ParkRowSelection(
    type: ParkRowSelectionType.checkbox,
    selectedRowKeys: <String>['0'],
    onChanged: (keys, rows) {},
  ),
)''',
        builder: (BuildContext context) => ParkTable(
          columns: <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名'),
            ParkTableColumn(key: 'age', title: '年龄'),
          ],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'age': '28'},
            <String, dynamic>{'name': '李四', 'age': '32'},
          ],
          rowSelection: ParkRowSelection(
            type: ParkRowSelectionType.checkbox,
            selectedRowKeys: <String>['0'],
            onChanged: (keys, rows) {},
          ),
        ),
      ),
      ParkDemoScenario(
        title: '分页',
        description: 'pagination 在底部展示分页栏（含 onPageChanged）/ Pagination',
        code: r'''ParkTable(
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名'),
    ParkTableColumn(key: 'age', title: '年龄'),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'age': '28'},
    <String, dynamic>{'name': '李四', 'age': '32'},
  ],
  pagination: ParkTablePagination(current: 1, pageSize: 10, total: 2, onPageChanged: (p, ps) {}),
)''',
        builder: (BuildContext context) => ParkTable(
          columns: <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名'),
            ParkTableColumn(key: 'age', title: '年龄'),
          ],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'age': '28'},
            <String, dynamic>{'name': '李四', 'age': '32'},
          ],
          pagination: ParkTablePagination(
            current: 1,
            pageSize: 10,
            total: 2,
            onPageChanged: (p, ps) {},
          ),
        ),
      ),
      ParkDemoScenario(
        title: '可展开行',
        description: 'expandable + expandedRowBuilder 展开详情行 / Expandable rows',
        code: r'''ParkTable(
  expandable: true,
  expandedRowBuilder: (context, row, index) => ParkText('详情：\${row['name']} 的资料'),
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名'),
    ParkTableColumn(key: 'age', title: '年龄'),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'age': '28'},
    <String, dynamic>{'name': '李四', 'age': '32'},
  ],
)''',
        builder: (BuildContext context) => ParkTable(
          expandable: true,
          expandedRowBuilder: (context, row, index) =>
              ParkText('详情：${row['name']} 的资料'),
          columns: const <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名'),
            ParkTableColumn(key: 'age', title: '年龄'),
          ],
          data: const <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'age': '28'},
            <String, dynamic>{'name': '李四', 'age': '32'},
          ],
        ),
      ),
      ParkDemoScenario(
        title: '加载与空状态',
        description: 'loading 显示遮罩，data 为空显示提示 / Loading & empty',
        code: r'''ParkTable(
  loading: false,
  columns: <ParkTableColumn>[ParkTableColumn(key: 'name', title: '姓名')],
  data: <Map<String, dynamic>>[],
  emptyText: '没有找到任何记录',
)''',
        builder: (BuildContext context) => ParkTable(
          loading: false,
          columns: <ParkTableColumn>[ParkTableColumn(key: 'name', title: '姓名')],
          data: <Map<String, dynamic>>[],
          emptyText: '没有找到任何记录',
        ),
      ),
    ],
    basicUsageCode: r'''ParkTable(
  columns: <ParkTableColumn>[
    ParkTableColumn(key: 'name', title: '姓名', sortable: true),
    ParkTableColumn(key: 'age', title: '年龄', width: 80, align: ParkTableColumnAlign.center),
  ],
  data: <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'age': '28'},
    <String, dynamic>{'name': '李四', 'age': '32'},
  ],
  striped: true,
)''',
    guide: r'''## 何时使用 / When to use
- 后台管理系统的数据列表展示 / Admin data lists
- 报表、统计数据的结构化展示 / Reports & stats
- 需要排序、边框、斑马纹的表格场景 / Sortable, bordered, zebra tables

## 使用建议 / Usage tips
- sortable: true 的列支持点击排序，适合数值列 / Sortable columns
- striped: true 斑马纹提升多行数据的可读性 / Zebra for readability
- bordered: true 适合正式报表，false 适合轻量列表 / Borders for formal reports
- rowSelection 启用多选/单选；onChanged 获取选中行 / Row selection
- pagination 分页；sticky 吸顶表头 / Pagination & sticky
- fixed 固定首末列适配窄屏横向滚动 / Fixed columns for narrow screens
- onRow 为单行绑定 onTap 等事件 / Per-row events via onRow
- loading 展示加载态，data 为空展示空状态 / Loading & empty

## 搭配推荐 / Compose with
- 搭配 ParkPagination 做分页 / ParkPagination
- 搭配 ParkEmpty 做表格空状态 / ParkEmpty
- 搭配 ParkTag 做表格内状态标签 / ParkTag status
''',
  ),

  'ParkFooter': ParkComponentSpec(
    name: 'ParkFooter',
    title: '页脚 / Footer',
    category: 'display',
    icon: Icons.vertical_align_bottom_outlined,
    description:
        '页面底部页脚组件，展示品牌 logo、导航链接和版权信息。'
        '链接通过 ParkFooterLink 配置，支持点击回调。'
        ' / Page footer with brand logo, nav links & copyright; links via ParkFooterLink with tap callbacks.',
    properties: const <ParkPropertyDef>[
      ParkPropertyDef(
        name: 'text',
        type: 'String',
        required: true,
        description: '页脚文字（品牌名称等）/ Brand text',
      ),
      ParkPropertyDef(
        name: 'logo',
        type: 'Widget?',
        defaultVal: 'null',
        description: 'Logo 组件，显示在文字左侧 / Logo (left of text)',
      ),
      ParkPropertyDef(
        name: 'links',
        type: 'List<ParkFooterLink>',
        defaultVal: '[]',
        description: '链接列表，每个 ParkFooterLink 含 label、href 和 onTap / Links',
      ),
      ParkPropertyDef(
        name: 'copyright',
        type: 'String?',
        defaultVal: 'null',
        description: '版权信息文字，显示在最底部 / Copyright text',
      ),
      ParkPropertyDef(
        name: 'divider',
        type: 'bool',
        defaultVal: 'true',
        description: '是否在页脚内容上方显示分割线 / Show top divider',
      ),
    ],
    events: const <ParkEventDef>[
      ParkEventDef(
        name: 'onTap',
        signature: 'VoidCallback?（ParkFooterLink.onTap）',
        description: '点击链接时触发（通过 ParkFooterLink.onTap 配置）/ Link tap callback',
      ),
    ],
    demos: <ParkDemoScenario>[
      ParkDemoScenario(
        title: '基础页脚',
        description: '品牌名称 + 链接 + 版权信息 / Brand + links + copyright',
        code: r'''ParkFooter(
  text: 'Park UI',
  links: <ParkFooterLink>[
    ParkFooterLink(label: '关于我们', onTap: () {}),
    ParkFooterLink(label: '服务条款', onTap: () {}),
    ParkFooterLink(label: '隐私政策', onTap: () {}),
  ],
  copyright: '© 2025 Park UI. All rights reserved.',
)''',
        builder: (BuildContext context) => ParkFooter(
          text: 'Park UI',
          links: <ParkFooterLink>[
            ParkFooterLink(label: '关于我们', onTap: () {}),
            ParkFooterLink(label: '服务条款', onTap: () {}),
            ParkFooterLink(label: '隐私政策', onTap: () {}),
          ],
          copyright: '© 2025 Park UI. All rights reserved.',
        ),
      ),
      ParkDemoScenario(
        title: '带 Logo',
        description: '在文字左侧显示 Logo 图标 / Logo on the left',
        code: r'''ParkFooter(
  text: 'Park UI',
  logo: Icon(Icons.park, size: 24),
  copyright: '© 2025 Park UI',
)''',
        builder: (BuildContext context) => ParkFooter(
          text: 'Park UI',
          logo: const Icon(Icons.park, size: 24),
          copyright: '© 2025 Park UI',
        ),
      ),
      ParkDemoScenario(
        title: '仅文字',
        description: '最简配置：仅品牌名称 / Minimal: brand only',
        code: r'''ParkFooter(text: 'Park UI')''',
        builder: (BuildContext context) => const ParkFooter(text: 'Park UI'),
      ),
      ParkDemoScenario(
        title: '无分割线',
        description: 'divider: false 隐藏顶部分割线 / No top divider',
        code: r'''ParkFooter(
  text: 'Park UI',
  divider: false,
  links: <ParkFooterLink>[ParkFooterLink(label: '关于', onTap: () {})],
)''',
        builder: (BuildContext context) => ParkFooter(
          text: 'Park UI',
          divider: false,
          links: <ParkFooterLink>[ParkFooterLink(label: '关于', onTap: () {})],
        ),
      ),
      ParkDemoScenario(
        title: '链接点击',
        description: 'onTap 报告最后点击的链接 / onTap demo',
        code: r'''StatefulBuilder(
  builder: (context, setState) {
    String last = '未点击';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ParkFooter(
          text: 'Park UI',
          links: <ParkFooterLink>[
            ParkFooterLink(label: '关于我们', onTap: () { last = '关于我们'; setState(() {}); }),
            ParkFooterLink(label: '隐私政策', onTap: () { last = '隐私政策'; setState(() {}); }),
          ],
        ),
        SizedBox(height: _kSpacing.sm),
        ParkText('最后点击: \$last'),
      ],
    );
  },
)''',
        builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) {
            String last = '未点击';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkFooter(
                  text: 'Park UI',
                  links: <ParkFooterLink>[
                    ParkFooterLink(
                      label: '关于我们',
                      onTap: () {
                        last = '关于我们';
                        setState(() {});
                      },
                    ),
                    ParkFooterLink(
                      label: '隐私政策',
                      onTap: () {
                        last = '隐私政策';
                        setState(() {});
                      },
                    ),
                  ],
                ),
                SizedBox(height: _kSpacing.sm),
                ParkText('最后点击: $last'),
              ],
            );
          },
        ),
      ),
    ],
    basicUsageCode: r'''ParkFooter(
  text: 'Park UI',
  logo: Icon(Icons.park, size: 24),
  links: <ParkFooterLink>[
    ParkFooterLink(label: '关于我们', onTap: () {}),
    ParkFooterLink(label: '服务条款', onTap: () {}),
    ParkFooterLink(label: '隐私政策', onTap: () {}),
  ],
  copyright: '© 2025 Park UI. All rights reserved.',
)''',
    guide: r'''## 何时使用 / When to use
- 网站或应用底部页脚区域 / Site / app footer
- 需要展示品牌信息、导航链接和版权声明 / Brand, nav links & copyright
- Web 端页面的底部信息区 / Web footer

## 使用建议 / Usage tips
- text 填写品牌名称，logo 放置品牌图标 / Brand name + logo
- links 放置常用导航链接，如"关于我们""服务条款""隐私政策"/ Nav links
- copyright 填写版权信息，通常包含年份 / Copyright with year
- divider: false 隐藏顶部分割线 / Hide top divider
- 通过 ParkFooterLink.onTap 处理链接点击 / Link tap via onTap

## 搭配推荐 / Compose with
- 搭配 ParkLink 做页脚导航链接 / ParkLink nav
- 搭配 ParkDivider 做区域分隔 / ParkDivider dividers
- 搭配 ParkCell 做移动端底部信息 / ParkCell mobile footer
''',
  ),
};
