/// ParkBottomNav 渲染 + 切换测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 测试用包裹器
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(
      body: const Center(child: Text('body')),
      bottomNavigationBar: child,
    ),
  );
}

/// 辅助：构建导航项
List<ParkBottomNavItem> _navItems([int count = 3]) {
  const icons = [Icons.home, Icons.search, Icons.person, Icons.settings, Icons.favorite];
  const labels = ['首页', '搜索', '我的', '设置', '收藏'];
  return List.generate(
    count,
    (i) => ParkBottomNavItem(icon: Icon(icons[i]), label: labels[i]),
  );
}

void main() {
  group('ParkBottomNav - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
        ),
      ));
      expect(find.byType(ParkBottomNav), findsOneWidget);
    });

    testWidgets('显示所有导航项标签', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
        ),
      ));
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('搜索'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });

    testWidgets('显示图标', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
        ),
      ));
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('渲染为 BottomNavigationBar', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
        ),
      ));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('至少需要 2 个导航项', (tester) async {
      // 1 项应触发 assert
      expect(
        () => ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(1),
        ),
        throwsAssertionError,
      );
    });
  });

  group('ParkBottomNav - 切换交互', () {
    testWidgets('点击导航项触发 onTap', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (i) => tappedIndex = i,
          items: _navItems(3),
        ),
      ));

      // 点击 "搜索" 标签
      await tester.tap(find.text('搜索'));
      expect(tappedIndex, 1);
    });

    testWidgets('currentIndex 控制选中项', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 2,
          onTap: (_) {},
          items: _navItems(3),
        ),
      ));
      // BottomNavigationBar 应显示 currentIndex=2
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.currentIndex, 2);
    });
  });

  group('ParkBottomNav - 类型与样式', () {
    testWidgets('fixed 类型渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
          type: ParkBottomNavType.fixed,
        ),
      ));
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.type, BottomNavigationBarType.fixed);
    });

    testWidgets('shifting 类型渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
          type: ParkBottomNavType.shifting,
        ),
      ));
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.type, BottomNavigationBarType.shifting);
    });

    testWidgets('自定义颜色生效', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
        ),
      ));
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.selectedItemColor, Colors.red);
      expect(navBar.unselectedItemColor, Colors.grey);
    });
  });

  group('ParkBottomNav - Badge', () {
    testWidgets('带 badge 的导航项渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: const [
            ParkBottomNavItem(icon: Icon(Icons.home), label: '首页', badge: '5'),
            ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
            ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
          ],
        ),
      ));
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('ParkBottomNav - 尺寸', () {
    testWidgets('三档尺寸均可渲染且 size 预设生效', (tester) async {
      for (final size in ParkBottomNavSize.values) {
        await tester.pumpWidget(_wrap(
          ParkBottomNav(
            currentIndex: 0,
            onTap: (_) {},
            items: _navItems(3),
            size: size,
          ),
        ));
        await tester.pump();
        expect(find.byType(ParkBottomNav), findsOneWidget,
            reason: 'size=$size 应正常渲染');
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('显式 iconSize 覆盖 size 预设', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: _navItems(3),
          size: ParkBottomNavSize.small,
          iconSize: 30,
        ),
      ));
      final navBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(navBar.iconSize, 30, reason: '显式 iconSize 应覆盖 small 预设 20');
    });
  });
}
