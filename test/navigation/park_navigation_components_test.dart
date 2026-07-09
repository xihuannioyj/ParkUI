import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('ParkSideBar', () {
    testWidgets('选中子项时应自动展开并高亮子项', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: SizedBox(
            width: 240,
            height: 320,
            child: ParkSideBar(
              items: _sideBarItems,
              selectedIndex: 1,
              selectedChildIndex: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('用户管理'), findsOneWidget);
      expect(find.text('用户列表'), findsOneWidget);

      final Text childText = tester.widget<Text>(find.text('用户列表'));
      expect(childText.style?.color, ParkThemeData.light().colors.brand);
    });

    testWidgets('点击父项应切换展开状态并保持点击回调一致', (WidgetTester tester) async {
      int? changedIndex;

      await tester.pumpWidget(
        _TestApp(
          child: SizedBox(
            width: 240,
            height: 320,
            child: ParkSideBar(
              items: _sideBarItems,
              onChanged: (int index) => changedIndex = index,
            ),
          ),
        ),
      );

      expect(find.text('用户列表'), findsNothing);

      await tester.tap(find.text('用户管理'));
      await tester.pumpAndSettle();

      expect(changedIndex, 1);
      expect(find.text('用户列表'), findsOneWidget);

      await tester.tap(find.text('用户管理'));
      await tester.pumpAndSettle();

      expect(find.text('用户列表'), findsNothing);
    });

    testWidgets('点击子项时应回调父子索引并保持子项高亮', (WidgetTester tester) async {
      int? parentIndex;
      int? childIndex;

      await tester.pumpWidget(
        _TestApp(
          child: SizedBox(
            width: 240,
            height: 320,
            child: ParkSideBar(
              items: _sideBarItems,
              selectedIndex: 1,
              selectedChildIndex: 0,
              onChildChanged: (int parent, int child) {
                parentIndex = parent;
                childIndex = child;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('用户列表'));
      await tester.pumpAndSettle();

      expect(parentIndex, 1);
      expect(childIndex, 0);
      final Text childText = tester.widget<Text>(find.text('用户列表'));
      expect(childText.style?.color, ParkThemeData.light().colors.brand);
    });

    testWidgets('折叠模式下带角标项不应抛出布局异常', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: SizedBox(
            width: 72,
            height: 240,
            child: ParkSideBar(
              items: <ParkSideBarItem>[
                ParkSideBarItem(
                  icon: Icons.notifications_outlined,
                  label: '消息中心',
                  badge: '9',
                ),
              ],
              collapsed: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('消息中心'), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });

  group('ParkSteps', () {
    testWidgets('空步骤列表应安全渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(child: ParkSteps(steps: <ParkStep>[])),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('横向长标题在窄布局下不应产生溢出异常', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: SizedBox(
            width: 220,
            child: ParkSteps(
              currentStep: 1,
              steps: <ParkStep>[
                ParkStep(title: '第一步第一步第一步第一步', description: '说明说明说明'),
                ParkStep(title: '第二步第二步第二步第二步', description: '说明说明说明'),
                ParkStep(title: '第三步第三步第三步第三步', description: '说明说明说明'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.textContaining('第一步'), findsOneWidget);
      expect(find.textContaining('第二步'), findsOneWidget);
      expect(find.textContaining('第三步'), findsOneWidget);
    });

    testWidgets('垂直模式点击步骤应返回对应索引', (WidgetTester tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        _TestApp(
          child: ParkSteps(
            direction: ParkStepsDirection.vertical,
            onStepTap: (int index) => tappedIndex = index,
            steps: const <ParkStep>[
              ParkStep(title: '步骤一'),
              ParkStep(title: '步骤二'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('步骤二'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });
  });

  group('ParkDrawer', () {
    testWidgets('抽屉宽度不应超过可用屏幕宽度', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          screenSize: Size(320, 640),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ParkDrawer(width: 480, child: Text('drawer-body')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Size size = tester.getSize(find.byType(Drawer));
      expect(size.width, lessThanOrEqualTo(320));
      expect(find.text('drawer-body'), findsOneWidget);
    });

    testWidgets('存在头尾区域时应完整渲染并保持主体内容可见', (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ParkDrawer(
              header: SizedBox(
                height: 48,
                child: Center(child: Text('header')),
              ),
              footer: SizedBox(
                height: 40,
                child: Center(child: Text('footer')),
              ),
              child: Center(child: Text('body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('header'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('footer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

const List<ParkSideBarItem> _sideBarItems = <ParkSideBarItem>[
  ParkSideBarItem(icon: Icons.dashboard_outlined, label: '仪表盘'),
  ParkSideBarItem(
    icon: Icons.people_outline,
    label: '用户管理',
    children: <ParkSideBarItem>[
      ParkSideBarItem(icon: Icons.list_alt_outlined, label: '用户列表'),
      ParkSideBarItem(icon: Icons.security_outlined, label: '权限设置'),
    ],
  ),
];

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.screenSize = const Size(800, 600)});

  final Widget child;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }
}
