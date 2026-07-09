import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _buildSwipeApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
    ),
    home: Scaffold(body: SizedBox(height: 80, child: child)),
  );
}

void main() {
  testWidgets('ParkSwipeCell 同一次拖拽中应累计位移', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildSwipeApp(
        const ParkSwipeCell(
          rightActions: <ParkSwipeAction>[
            ParkSwipeAction(label: '删除', color: Colors.red),
            ParkSwipeAction(label: '更多', color: Colors.blue),
          ],
          child: SizedBox(height: 56, child: Text('滑动内容')),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('滑动内容')));
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    final firstLeft = tester.getTopLeft(find.text('滑动内容')).dx;

    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    final secondLeft = tester.getTopLeft(find.text('滑动内容')).dx;

    expect(secondLeft, lessThan(firstLeft));

    await gesture.up();
  });

  testWidgets('ParkSwipeCell 左滑可打开右侧操作并触发回调后关闭', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      _buildSwipeApp(
        ParkSwipeCell(
          rightActions: <ParkSwipeAction>[
            ParkSwipeAction(
              label: '删除',
              color: Colors.red,
              onTap: () => tapped = true,
            ),
          ],
          child: const SizedBox(height: 56, child: Text('待操作内容')),
        ),
      ),
    );

    await tester.drag(find.text('待操作内容'), const Offset(-120, 0));
    await tester.pumpAndSettle();

    expect(find.text('删除'), findsOneWidget);

    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
    expect(find.text('删除'), findsNothing);
  });

  testWidgets('ParkSwipeCell 没有左侧操作时右滑不应位移', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildSwipeApp(
        const ParkSwipeCell(
          rightActions: <ParkSwipeAction>[
            ParkSwipeAction(label: '删除', color: Colors.red),
          ],
          child: SizedBox(height: 56, child: Text('边界内容')),
        ),
      ),
    );

    final before = tester.getTopLeft(find.text('边界内容')).dx;

    final gesture = await tester.startGesture(tester.getCenter(find.text('边界内容')));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    final after = tester.getTopLeft(find.text('边界内容')).dx;
    await gesture.up();

    expect(after, before);
  });
}