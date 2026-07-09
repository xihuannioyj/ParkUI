import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  testWidgets('ParkTabs 应能切换标签并触发回调', (WidgetTester tester) async {
    int? changedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          body: SizedBox(
            height: 220,
            child: ParkTabs(
              tabs: const <ParkTab>[
                ParkTab(label: '推荐'),
                ParkTab(label: '热门'),
              ],
              onChanged: (int index) => changedIndex = index,
              children: const <Widget>[
                Center(child: Text('推荐内容')),
                Center(child: Text('热门内容')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('热门'));
    await tester.pumpAndSettle();

    expect(changedIndex, 1);
    expect(find.text('热门内容'), findsOneWidget);
  });

  testWidgets('ParkTabBar 应能触发点击回调', (WidgetTester tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          body: ParkTabBar(
            items: const <ParkTabBarItem>[
              ParkTabBarItem(icon: Icons.home, label: '首页'),
              ParkTabBarItem(icon: Icons.person, label: '我的'),
            ],
            onTap: (int index) => tappedIndex = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('我的'));
    await tester.pump();

    expect(tappedIndex, 1);
  });

  testWidgets('ParkNavBar 应显示标题并触发返回回调', (WidgetTester tester) async {
    bool backed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          appBar: ParkNavBar.text(
            title: '详情',
            leftArrow: true,
            onBack: () => backed = true,
          ),
        ),
      ),
    );

    expect(find.text('详情'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pump();

    expect(backed, isTrue);
  });

  testWidgets('ParkSideBar 应能切换顶层菜单', (WidgetTester tester) async {
    int? selectedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          body: ParkSideBar(
            items: const <ParkSideBarItem>[
              ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
              ParkSideBarItem(icon: Icons.settings, label: '设置'),
            ],
            onChanged: (int index) => selectedIndex = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('设置'));
    await tester.pump();

    expect(selectedIndex, 1);
  });

  testWidgets('ParkSteps 应显示步骤并触发点击回调', (WidgetTester tester) async {
    int? tappedStep;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          body: ParkSteps(
            steps: const <ParkStep>[
              ParkStep(title: '第一步'),
              ParkStep(title: '第二步'),
            ],
            onStepTap: (int index) => tappedStep = index,
          ),
        ),
      ),
    );

    expect(find.text('第一步'), findsOneWidget);
    await tester.tap(find.text('第二步'));
    await tester.pump();

    expect(tappedStep, 1);
  });

  testWidgets('ParkIndexes 应能点击索引并触发回调', (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          body: ParkIndexes(
            indexes: const <String>['A', 'B', 'C'],
            showOverlay: false,
            onIndexSelected: (String value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('B'));
    await tester.pump();

    expect(selected, 'B');
  });
}
