import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 阶段 1 P0 修复定向测试（T06 ParkSelect 虚拟滚动）
///
/// virtual==false 保持原 ListView(shrinkWrap) 路径；
/// virtual==true 走 ListView.builder 路径。两者均能构造并渲染，不抛异常。
List<ParkSelectOption> _options(int n) =>
    List<ParkSelectOption>.generate(n, (int i) => ParkSelectOption(label: '选项 $i', value: '$i'));

void main() {
  group('T06 ParkSelect 虚拟滚动', () {
    testWidgets('virtual=false 正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(child: ParkSelect(items: _options(5), virtual: false)),
          ),
        ),
      );
      expect(find.byType(ParkSelect), findsOneWidget);
    });

    testWidgets('virtual=true 大数据量正常渲染（ListView.builder 路径）', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(child: ParkSelect(items: _options(1000), virtual: true)),
          ),
        ),
      );
      expect(find.byType(ParkSelect), findsOneWidget);
    });

    testWidgets('virtual=true 打开选项面板走虚拟滚动 ListView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(child: ParkSelect(items: _options(50), virtual: true)),
          ),
        ),
      );
      // 点击触发器打开底部选项面板
      await tester.tap(find.byType(ParkSelect));
      await tester.pumpAndSettle();

      // 虚拟滚动模式下面板内应渲染 ListView（ListView.builder）
      expect(find.byType(ListView), findsWidgets);
      // 选项文本可见
      expect(find.text('选项 0'), findsOneWidget);
    });
  });
}
