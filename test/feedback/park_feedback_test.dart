import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  Widget createTestApp(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
      ),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('ParkDialog', () {
    testWidgets('confirm 应支持遮罩点击关闭与回调区分', (WidgetTester tester) async {
      bool confirmed = false;
      bool cancelled = false;

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkDialog.confirm(
                    context,
                    title: '确认删除',
                    content: '确认后不可恢复',
                    barrierDismissible: true,
                    onConfirm: () => confirmed = true,
                    onCancel: () => cancelled = true,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('确认删除'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('确认删除'), findsNothing);
      expect(confirmed, isFalse);
      expect(cancelled, isTrue);
    });

    testWidgets('alert 在禁用遮罩关闭时仅能通过确认按钮关闭', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkDialog.alert(
                    context,
                    title: '提示',
                    content: '需要明确确认',
                    barrierDismissible: false,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('提示'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('提示'), findsNothing);
    });
  });

  group('ParkToast', () {
    testWidgets('show 应在新 toast 出现时替换旧 toast', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkToast.show(context, '第一条', duration: const Duration(seconds: 5));
                  ParkToast.show(context, '第二条', duration: const Duration(seconds: 5));
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('第一条'), findsNothing);
      expect(find.text('第二条'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('show 应支持自定义背景色与忽略过短 duration 的异常动画时机', (WidgetTester tester) async {
      const Color customColor = Color(0xFF123456);

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkToast.show(
                    context,
                    '自定义提示',
                    duration: const Duration(milliseconds: 100),
                    bgColor: customColor,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      final Container container = tester.widget<Container>(
        find
            .ancestor(of: find.text('自定义提示'), matching: find.byType(Container))
            .first,
      );
      final BoxDecoration decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, customColor);

      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('自定义提示'), findsNothing);
    });
  });

  group('ParkLoading', () {
    testWidgets('show 重复调用时应替换旧 loading，hide 后应移除', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkLoading.show(context, message: '加载中');
                  ParkLoading.show(context, message: '再次加载');
                },
                child: const Text('show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('加载中'), findsNothing);
      expect(find.text('再次加载'), findsOneWidget);

      ParkLoading.hide(tester.element(find.text('show')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('再次加载'), findsNothing);
    });

    testWidgets('组件模式应支持 dots 类型与文本', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          const ParkLoading(
            type: ParkLoadingType.dots,
            text: '处理中',
          ),
        ),
      );

      expect(find.text('处理中'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('ParkActionSheet', () {
    testWidgets('禁用项点击不应关闭，启用项点击应返回结果', (WidgetTester tester) async {
      ParkAction? selected;

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () async {
                  selected = await ParkActionSheet.show(
                    context,
                    closeOnTapAction: true,
                    actions: <ParkAction>[
                      const ParkAction(
                        label: '禁用项',
                        style: ParkActionStyle.disabled,
                      ),
                      const ParkAction(label: '可用项'),
                    ],
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('禁用项'));
      await tester.pumpAndSettle();
      expect(find.text('可用项'), findsOneWidget);
      expect(selected, isNull);

      await tester.tap(find.text('可用项'));
      await tester.pumpAndSettle();
      expect(selected?.label, '可用项');
    });

    testWidgets('应支持隐藏取消按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkActionSheet.show(
                    context,
                    showCancel: false,
                    actions: const <ParkAction>[ParkAction(label: '操作')],
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('取消'), findsNothing);
      expect(find.text('操作'), findsOneWidget);
    });
  });

  group('ParkMessage', () {
    testWidgets('closable 消息应可点击关闭', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkMessage.error(
                    context,
                    '错误提示',
                    content: '可手动关闭',
                    closable: true,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('错误提示'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('错误提示'), findsNothing);
    });

    testWidgets('新消息出现时应替换旧消息，并支持点击内容关闭', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ParkMessage.info(
                    context,
                    '第一条消息',
                    duration: const Duration(seconds: 5),
                  );
                  ParkMessage.success(
                    context,
                    '第二条消息',
                    duration: const Duration(seconds: 5),
                    position: ParkMessagePosition.bottom,
                    onTap: () {},
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('第一条消息'), findsNothing);
      expect(find.text('第二条消息'), findsOneWidget);

      await tester.tap(find.text('第二条消息'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('第二条消息'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
