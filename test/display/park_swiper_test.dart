import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: <ParkThemeData>[ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

/// Helper to create a colored container test widget.
Widget _testCard(String label, Color color) {
  return Container(
    key: Key(label),
    color: color,
    width: 300,
    height: 150,
    alignment: Alignment.center,
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
  );
}

void main() {
  group('ParkSwiper', () {
    group('基础渲染', () {
      testWidgets('创建不抛异常', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(
          children: <Widget>[
            _testCard('red', Colors.red),
            _testCard('blue', Colors.blue),
          ],
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });

      testWidgets('单个item', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(
          children: <Widget>[_testCard('green', Colors.green)],
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });

      testWidgets('空children显示空容器', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(children: <Widget>[])));
        expect(find.byType(ParkSwiper), findsOneWidget);
        // 不应有指示器
        expect(find.byType(Row), findsNothing);
      });

      testWidgets('多children显示指示器', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(
          children: <Widget>[
            _testCard('a', Colors.red),
            _testCard('b', Colors.blue),
            _testCard('c', Colors.green),
          ],
        )));
        // 默认 dot 指示器
        expect(find.byType(ParkSwiper), findsOneWidget);
      });

      testWidgets('indicatorPosition none 不显示指示器', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(
          children: <Widget>[
            _testCard('a', Colors.red),
            _testCard('b', Colors.blue),
          ],
          indicatorPosition: ParkSwiperIndicatorPosition.none,
        )));
        // 没有 Positioned 指示器
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });

    group('viewportFraction', () {
      testWidgets('设置 viewportFraction 不抛异常', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(
          children: <Widget>[
            _testCard('a', Colors.red),
            _testCard('b', Colors.blue),
          ],
          viewportFraction: 0.8,
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });

      testWidgets('viewportFraction + scale 卡片堆叠', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 300,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
              _testCard('c', Colors.green),
            ],
            viewportFraction: 0.85,
            scale: 0.9,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
        // PageView 使用 AnimatedBuilder，应渲染 Transform.scale
        expect(find.byType(Transform), findsWidgets);
      });

      testWidgets('仅 scale 不设置 viewportFraction 也触发堆叠效果', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 300,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            scale: 0.85,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });

    group('effect fade', () {
      testWidgets('淡入淡出效果', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 200,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            effect: ParkSwiperEffect.fade,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });

      testWidgets('淡入淡出 + 自动轮播', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 200,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
              _testCard('c', Colors.green),
            ],
            effect: ParkSwiperEffect.fade,
            autoPlay: true,
            loop: true,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });

    group('custom curve', () {
      testWidgets('自定义动画曲线不抛异常', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 200,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            curve: Curves.easeOutCubic,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });

    group('drag ratio', () {
      testWidgets('自定义拖动阈值', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 200,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            dragStartRatio: 0.2,
            dragEndRatio: 0.4,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });

    group('自动轮播', () {
      testWidgets('autoPlay + loop + custom interval', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 200,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            autoPlay: true,
            loop: true,
            interval: const Duration(seconds: 1),
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });

      testWidgets('自动轮播 + 自定义动画时长', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 200,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            autoPlay: true,
            loop: true,
            animationDuration: const Duration(milliseconds: 500),
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });

    group('指示器', () {
      testWidgets('数字指示器', (tester) async {
        await tester.pumpWidget(_wrap(ParkSwiper(
          children: <Widget>[
            _testCard('a', Colors.red),
            _testCard('b', Colors.blue),
            _testCard('c', Colors.green),
          ],
          indicatorType: ParkSwiperIndicatorType.number,
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
        // 数字指示器应显示 "1 / 3"
        expect(find.text('1'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('/'), findsOneWidget);
      });
    });

    group('垂直方向', () {
      testWidgets('垂直滑动', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 300,
          child: ParkSwiper(
            children: <Widget>[
              _testCard('a', Colors.red),
              _testCard('b', Colors.blue),
            ],
            direction: Axis.vertical,
          ),
        )));
        expect(find.byType(ParkSwiper), findsOneWidget);
      });
    });
  });
}
